const { onDocumentCreated, onDocumentUpdated } = require("firebase-functions/v2/firestore");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const { setGlobalOptions } = require("firebase-functions/v2");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

// Global options (Region aur Memory set karne ke liye)
setGlobalOptions({ region: "us-central1" });

/**
 * Trigger: When an appointment status is updated
 */
exports.onappointmentstatusupdate = onDocumentUpdated("appointments/{appointmentId}", async (event) => {
    const newData = event.data.after.data();
    const oldData = event.data.before.data();

    if (newData.status !== oldData.status) {
        const status = newData.status;
        const patientId = newData.patientId;
        const doctorId = newData.doctorId;

        let doctorName = 'Doctor';
        const doctorUserSnap = await db.collection('users').where('doctorId', '==', doctorId).limit(1).get();
        if (!doctorUserSnap.empty) {
            doctorName = doctorUserSnap.docs[0].data().name;
        }

        const title = `Appointment ${status}`;
        const body = `Your appointment with Dr. ${doctorName} for ${newData.appointmentDate} is now ${status}.`;

        return sendPushNotification(patientId, 'patientId', title, body, {
            type: 'appointment_status',
            appointmentId: event.params.appointmentId
        });
    }
    return null;
});

/**
 * Trigger: When a new appointment is booked
 */
exports.onnewappointmentbooked = onDocumentCreated("appointments/{appointmentId}", async (event) => {
    const appointment = event.data.data();
    const appointmentId = event.params.appointmentId;

    const [doctorSnap, patientSnap] = await Promise.all([
        db.collection('users').where('doctorId', '==', appointment.doctorId).limit(1).get(),
        db.collection('users').where('patientId', '==', appointment.patientId).limit(1).get()
    ]);

    const doctorData = !doctorSnap.empty ? doctorSnap.docs[0].data() : null;
    const patientData = !patientSnap.empty ? patientSnap.docs[0].data() : null;

    const doctorName = doctorData ? doctorData.name : 'Doctor';
    const patientName = patientData ? patientData.name : 'Patient';

    // 1. Notify Doctor
    if (doctorData && doctorData.fcmToken) {
        await admin.messaging().send({
            notification: {
                title: 'New Booking!',
                body: `New appointment: ${patientName} on ${appointment.appointmentDate} at ${appointment.timeSlot}.`,
            },
            token: doctorData.fcmToken,
            data: {
                type: 'new_booking',
                appointmentId: appointmentId,
                click_action: 'FLUTTER_NOTIFICATION_CLICK'
            }
        });
    }

    // 2. Notify Patient
    if (patientData && patientData.fcmToken) {
        const patientTitle = 'Booking Successful!';
        const patientBody = `Your appointment with Dr. ${doctorName} is booked for ${appointment.appointmentDate} at ${appointment.timeSlot}.`;

        await admin.messaging().send({
            notification: { title: patientTitle, body: patientBody },
            token: patientData.fcmToken,
            data: {
                type: 'booking_confirmation',
                appointmentId: appointmentId,
                click_action: 'FLUTTER_NOTIFICATION_CLICK'
            }
        });
    }
    return null;
});

/**
 * Trigger: When a payment is successfully made
 */
exports.onpaymentcreated = onDocumentCreated("payments/{paymentId}", async (event) => {
    const payment = event.data.data();
    const title = 'Payment Successful';
    const body = `Payment of ₹${payment.amount} for your appointment has been received. Transaction ID: ${payment.transactionId}`;

    return sendPushNotification(payment.patientId, 'patientId', title, body, {
        type: 'payment_success',
        paymentId: event.params.paymentId
    });
});

/**
 * Scheduler: Reminder for Upcoming Follow-up Date
 */
exports.upcomingfollowupreminder = onSchedule("0 8 * * *", async (event) => {
    const tomorrow = new Date();
    tomorrow.setDate(tomorrow.getDate() + 1);
    const tomorrowStr = tomorrow.toISOString().split('T')[0];

    const prescriptionsSnap = await db.collection('prescriptions')
        .where('followUpDate', '==', tomorrowStr)
        .get();

    if (prescriptionsSnap.empty) return null;

    const promises = [];
    prescriptionsSnap.forEach(doc => {
        const prescription = doc.data();
        const title = 'Follow-up Reminder';
        const body = `Reminder: You have a follow-up visit tomorrow with Dr. ${prescription.doctorName}.`;

        promises.push(sendPushNotification(prescription.patientId, 'patientId', title, body, {
            type: 'follow_up_reminder',
            prescriptionId: doc.id
        }));
    });

    return Promise.all(promises);
});

/**
 * Helper function
 */
async function sendPushNotification(id, idType, title, body, extraData = {}) {
    const userSnap = await db.collection('users').where(idType, '==', id).limit(1).get();
    if (userSnap.empty) return null;

    const userData = userSnap.docs[0].data();
    const fcmToken = userData.fcmToken;
    if (!fcmToken) return null;

    const message = {
        notification: { title, body },
        data: {
            ...extraData,
            click_action: 'FLUTTER_NOTIFICATION_CLICK',
        },
        token: fcmToken,
    };

    try {
        await admin.messaging().send(message);
    } catch (error) {
        console.error(`Error sending to ${id}:`, error);
    }
}
