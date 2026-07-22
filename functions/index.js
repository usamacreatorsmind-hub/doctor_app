const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

/**
 * Trigger: When an appointment status is updated (Confirmed, Cancelled, etc.)
 */
exports.onAppointmentStatusUpdate = functions.firestore
    .document('appointments/{appointmentId}')
    .onUpdate(async (change, context) => {
        const newData = change.after.data();
        const oldData = change.before.data();

        if (newData.status !== oldData.status) {
            const status = newData.status;
            const targetUid = newData.patientId;
            const title = `Appointment ${status}`;
            const body = `Your appointment with Dr. ${newData.doctorName} for ${newData.appointmentDate} is now ${status}.`;

            return sendPushNotification(targetUid, title, body, {
                type: 'appointment_status',
                appointmentId: context.params.appointmentId
            });
        }
        return null;
    });

/**
 * Trigger: When a new appointment is booked
 */
exports.onNewAppointmentBooked = functions.firestore
    .document('appointments/{appointmentId}')
    .onCreate(async (snapshot, context) => {
        const appointment = snapshot.data();

        // 1. Notify Doctor
        const doctorUsersSnap = await admin.firestore().collection('users')
            .where('doctorId', '==', appointment.doctorId)
            .limit(1).get();

        if (!doctorUsersSnap.empty) {
            const doctorToken = doctorUsersSnap.docs[0].data().fcmToken;
            if (doctorToken) {
                await admin.messaging().send({
                    notification: {
                        title: 'New Booking!',
                        body: `New appointment: ${appointment.patientName} on ${appointment.appointmentDate} at ${appointment.timeSlot}.`,
                    },
                    token: doctorToken,
                    data: { type: 'new_booking', appointmentId: context.params.appointmentId }
                });
            }
        }

        // 2. Notify Patient (Confirmation)
        const patientTitle = 'Booking Successful!';
        const patientBody = `Your appointment with Dr. ${appointment.doctorName} is booked for ${appointment.appointmentDate} at ${appointment.timeSlot}.`;

        return sendPushNotification(appointment.patientId, patientTitle, patientBody, {
            type: 'booking_confirmation',
            appointmentId: context.params.appointmentId
        });
    });

/**
 * Trigger: When a payment is successfully made
 */
exports.onPaymentCreated = functions.firestore
    .document('payments/{paymentId}')
    .onCreate(async (snapshot, context) => {
        const payment = snapshot.data();
        const title = 'Payment Successful';
        const body = `Payment of ₹${payment.amount} for your appointment has been received. Transaction ID: ${payment.transactionId}`;

        return sendPushNotification(payment.patientId, title, body, {
            type: 'payment_success',
            paymentId: context.params.paymentId
        });
    });

/**
 * Scheduler: Reminder for Upcoming Follow-up Date (1 Day Before)
 * This runs every morning at 8:00 AM
 */
exports.upcomingFollowUpReminder = functions.pubsub.schedule('0 8 * * *')
    .timeZone('Asia/Kolkata')
    .onRun(async (context) => {
        // Calculate tomorrow's date string (yyyy-MM-dd)
        const tomorrow = new Date();
        tomorrow.setDate(tomorrow.getDate() + 1);
        const tomorrowStr = tomorrow.toISOString().split('T')[0];

        console.log(`Checking for follow-ups on: ${tomorrowStr}`);

        // Search prescriptions where followUpDate is tomorrow
        const prescriptionsSnap = await admin.firestore().collection('prescriptions')
            .where('followUpDate', '==', tomorrowStr)
            .get();

        if (prescriptionsSnap.empty) {
            console.log('No follow-ups found for tomorrow.');
            return null;
        }

        const promises = [];
        prescriptionsSnap.forEach(doc => {
            const prescription = doc.data();
            const title = 'Follow-up Reminder';
            const body = `Reminder: You have a follow-up visit tomorrow with Dr. ${prescription.doctorName}.`;

            promises.push(sendPushNotification(prescription.patientId, title, body, {
                type: 'follow_up_reminder',
                prescriptionId: doc.id
            }));
        });

        return Promise.all(promises);
    });

/**
 * Helper function to send push notifications by UID
 */
async function sendPushNotification(uid, title, body, extraData = {}) {
    const userDoc = await admin.firestore().collection('users').doc(uid).get();
    if (!userDoc.exists) return null;

    const fcmToken = userDoc.data().fcmToken;
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
        console.log(`Notification sent to ${uid}`);
    } catch (error) {
        console.error(`Error sending to ${uid}:`, error);
    }
}
