const { onDocumentCreated, onDocumentUpdated, onDocumentDeleted } = require("firebase-functions/v2/firestore");
const { onCall, onRequest, HttpsError } = require("firebase-functions/v2/https");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const { setGlobalOptions } = require("firebase-functions/v2");
const admin = require("firebase-admin");
const Razorpay = require("razorpay");
const crypto = require("crypto");

admin.initializeApp();
const db = admin.firestore();

// Razorpay Initialization
const razorpay = new Razorpay({
    key_id: 'rzp_live_TUN2EGCy4mg6kn',
    key_secret: 'NgzygHKv7CLzLStEm697eu1u',
});

// Global options
setGlobalOptions({ region: "us-central1" });

/**
 * Trigger: Create Razorpay Order (for standard patient checkout)
 */
exports.createRazorpayOrder = onCall(async (request) => {
    const amount = request.data.amount; // In Paisa (e.g. 5000 for ₹50)
    const currency = request.data.currency || "INR";
    const appointmentId = request.data.appointmentId;
    const patientId = request.data.patientId;
    const receipt = `receipt_${Date.now()}`;

    if (!amount || !appointmentId || !patientId) {
        throw new HttpsError("invalid-argument", "Amount, appointmentId, and patientId are required");
    }

    try {
        const order = await razorpay.orders.create({
            amount: amount,
            currency: currency,
            receipt: receipt,
            notes: {
                appointmentId: appointmentId,
                patientId: patientId
            }
        });
        return order;
    } catch (error) {
        console.error("Razorpay Order Error:", error);
        throw new HttpsError("internal", "Failed to create Razorpay order");
    }
});

/**
 * Trigger: Create Razorpay QR Code for Walk-In / Counter Payments
 */
exports.createRazorpayQrCode = onCall(async (request) => {
    try {
        const { amount, appointmentId, patientId } = request.data;
        if (!amount) {
            throw new HttpsError("invalid-argument", "Amount is required");
        }

        const qrCode = await razorpay.qrCode.create({
            type: "upi_qr",
            name: "Ayu Veda Care",
            usage: "single_use",
            fixed_amount: true,
            payment_amount: amount, // in paisa
            description: "Walk-in Consultation Fee",
            notes: {
                appointmentId: appointmentId || 'WALKIN',
                patientId: patientId || ""
            }
        });

        return qrCode;
    } catch (error) {
        console.error("Razorpay QR Code Error:", error);
        throw new HttpsError("internal", error.message || "Failed to create Razorpay QR code");
    }
});

/**
 * 1. createOrder: Creates an order and generates a Razorpay UPI QR code (expires in 5 minutes)
 */
exports.createOrder = onCall(async (request) => {
    if (!request.auth) {
        throw new HttpsError("unauthenticated", "User must be logged in to create a payment order.");
    }

    const { amount, description, customerName } = request.data;
    if (!amount || amount <= 0 || amount > 100000) {
        throw new HttpsError("invalid-argument", "Invalid amount provided.");
    }
    if (!customerName || customerName.trim().length === 0) {
        throw new HttpsError("invalid-argument", "Customer name is required.");
    }

    const sanitizedName = customerName.trim().substring(0, 50);
    const sanitizedDesc = (description || "Consultation & Service Fee").trim().substring(0, 100);
    const uid = request.auth.uid;

    const now = new Date();
    const expiresAt = new Date(now.getTime() + 5 * 60 * 1000); // 5 minutes from now
    const closeTimestamp = Math.floor(expiresAt.getTime() / 1000);

    const orderRef = db.collection('orders').doc();
    const orderId = orderRef.id;

    try {
        const qrCode = await razorpay.qrCode.create({
            type: "upi_qr",
            name: sanitizedName,
            usage: "single_use",
            fixed_amount: true,
            payment_amount: Math.round(amount * 100), // convert rupees to paise
            description: sanitizedDesc,
            close_by: closeTimestamp,
            notes: {
                orderId: orderId,
                createdBy: uid
            }
        });

        const orderData = {
            amount: amount,
            description: sanitizedDesc,
            customerName: sanitizedName,
            status: "created",
            createdBy: uid,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            expiresAt: admin.firestore.Timestamp.fromDate(expiresAt),
            qrId: qrCode.id,
            qrImageUrl: qrCode.image_url,
            qrImageContent: qrCode.image_content || null,
        };

        await orderRef.set(orderData);

        return {
            orderId: orderId,
            qrId: qrCode.id,
            qrImageUrl: qrCode.image_url,
            qrImageContent: qrCode.image_content || null,
            expiresAt: expiresAt.toISOString(),
        };
    } catch (error) {
        console.error("createOrder Razorpay Error:", error);
        throw new HttpsError("internal", error.message || "Failed to generate Razorpay QR code.");
    }
});

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

        // 1. Notify Patient
        await sendPushNotification(patientId, 'patientId', title, body, {
            type: 'appointment_status',
            appointmentId: event.params.appointmentId
        });

        // 2. Notify Doctor if status becomes Confirmed (e.g. after payment)
        if (status === 'Confirmed') {
            const doctorUserSnap = await db.collection('users').where('doctorId', '==', doctorId).limit(1).get();
            if (!doctorUserSnap.empty && doctorUserSnap.docs[0].data().fcmToken) {
                await admin.messaging().send({
                    notification: {
                        title: 'New Booking Confirmed!',
                        body: `Appointment confirmed for ${newData.appointmentDate} at ${newData.timeSlot}.`,
                    },
                    token: doctorUserSnap.docs[0].data().fcmToken,
                    data: {
                        type: 'new_booking',
                        appointmentId: event.params.appointmentId,
                        click_action: 'FLUTTER_NOTIFICATION_CLICK'
                    }
                });
            }
        }
        return null;
    }
    return null;
});

const MSG91_AUTH_KEY = "566174ACoxByk72v6a955369P1";
const MSG91_TEMPLATE_ID = "6a95551467221b0f4e010bb2";
const WEBHOOK_SECRET = "AyuVeda_Secret_2024";

/**
 * Razorpay Webhook to verify and confirm payments (Supports QR codes & standard payments)
 */
exports.razorpayWebhook = onRequest(async (req, res) => {
    const signature = req.headers["x-razorpay-signature"];
    const rawBody = req.rawBody ? req.rawBody.toString() : JSON.stringify(req.body);

    const expectedSignature = crypto
        .createHmac("sha256", WEBHOOK_SECRET)
        .update(rawBody)
        .digest("hex");

    if (signature !== expectedSignature) {
        console.error("Webhook Signature Mismatch!");
        return res.status(400).send("Invalid signature");
    }

    const event = req.body.event;
    const eventId = req.body.id || (req.body.payload && req.body.payload.payment ? req.body.payload.payment.entity.id : null);
    console.log(`Received Razorpay Webhook Event: ${event}, ID: ${eventId}`);

    try {
        // Idempotency check
        if (eventId) {
            const eventRef = db.collection('processedEvents').doc(eventId);
            const eventDoc = await eventRef.get();
            if (eventDoc.exists) {
                console.log(`Event ${eventId} already processed. Skipping.`);
                return res.status(200).send("Event already processed");
            }
            await eventRef.set({ processedAt: admin.firestore.FieldValue.serverTimestamp() });
        }

        if (event === "qr_code.credited" || event === "payment.captured") {
            const paymentData = req.body.payload.payment ? req.body.payload.payment.entity : null;
            const qrData = req.body.payload.qr_code ? req.body.payload.qr_code.entity : null;

            const notes = (paymentData && paymentData.notes) || (qrData && qrData.notes) || {};
            let orderId = notes.orderId;
            const qrId = qrData ? qrData.id : (paymentData && paymentData.qr_code_id ? paymentData.qr_code_id : null);

            // If orderId not in notes, search order by qrId
            if (!orderId && qrId) {
                const orderSnap = await db.collection('orders').where('qrId', '==', qrId).limit(1).get();
                if (!orderSnap.empty) {
                    orderId = orderSnap.docs[0].id;
                }
            }

            if (orderId) {
                const orderRef = db.collection('orders').doc(orderId);
                const orderDoc = await orderRef.get();

                if (orderDoc.exists && orderDoc.data().status !== 'paid') {
                    const orderData = orderDoc.data();
                    const paidAmount = paymentData ? paymentData.amount / 100 : orderData.amount;

                    if (Math.abs(paidAmount - orderData.amount) < 1.0) {
                        await orderRef.update({
                            status: 'paid',
                            paymentId: paymentData ? paymentData.id : 'UPI_QR_DIRECT',
                            paymentMethod: paymentData ? paymentData.method : 'upi',
                            paidAt: admin.firestore.FieldValue.serverTimestamp(),
                        });
                        console.log(`Order ${orderId} successfully marked as paid.`);

                        // Create Payment Record
                        await db.collection('payments').add({
                            orderId: orderId,
                            amount: paidAmount,
                            paymentMethod: paymentData ? paymentData.method : 'upi',
                            transactionId: paymentData ? paymentData.id : 'QR_TXN',
                            paymentDate: new Date().toISOString(),
                            status: 'Success',
                            createdAt: admin.firestore.FieldValue.serverTimestamp(),
                        });
                    }
                }
            }

            // Also support legacy appointment metadata if present in notes
            const appointmentId = notes.appointmentId;
            const patientId = notes.patientId;
            if (appointmentId && paymentData) {
                const batch = db.batch();
                const apptRef = db.collection('appointments').doc(appointmentId);
                batch.update(apptRef, {
                    status: 'Confirmed',
                    paymentStatus: 'Booking Charge Paid',
                    bookingCharge: paymentData.amount / 100,
                    transactionId: paymentData.id,
                    razorpayOrderId: paymentData.order_id,
                    updatedAt: admin.firestore.FieldValue.serverTimestamp()
                });
                const paymentRef = db.collection('payments').doc();
                batch.set(paymentRef, {
                    appointmentId: appointmentId,
                    patientId: patientId || 'unknown',
                    amount: paymentData.amount / 100,
                    paymentMethod: paymentData.method,
                    transactionId: paymentData.id,
                    razorpayOrderId: paymentData.order_id,
                    paymentDate: new Date().toISOString(),
                    status: 'Success',
                    createdAt: admin.firestore.FieldValue.serverTimestamp()
                });
                await batch.commit();
            }
        } else if (event === "qr_code.closed") {
            const qrEntity = req.body.payload.qr_code ? req.body.payload.qr_code.entity : null;
            const qrId = qrEntity ? qrEntity.id : null;
            if (qrId) {
                const orderSnap = await db.collection('orders').where('qrId', '==', qrId).where('status', '==', 'created').limit(1).get();
                if (!orderSnap.empty) {
                    await orderSnap.docs[0].ref.update({ status: 'expired' });
                }
            }
        }

        return res.status(200).send("ok");
    } catch (error) {
        console.error("Webhook error:", error);
        return res.status(500).send("Internal server error");
    }
});

/**
 * 3. verifyOrder: Fallback verification by checking QR code payments via Razorpay SDK
 */
exports.verifyOrder = onCall(async (request) => {
    if (!request.auth) {
        throw new HttpsError("unauthenticated", "Authentication required.");
    }

    const { orderId } = request.data;
    if (!orderId) {
        throw new HttpsError("invalid-argument", "Order ID is required.");
    }

    const orderRef = db.collection('orders').doc(orderId);
    const orderDoc = await orderRef.get();

    if (!orderDoc.exists) {
        throw new HttpsError("not-found", "Order not found.");
    }

    const orderData = orderDoc.data();
    if (orderData.status === 'paid') {
        return { status: 'paid' };
    }

    if (!orderData.qrId) {
        return { status: orderData.status };
    }

    try {
        const payments = await razorpay.qrCode.fetchAllPayments(orderData.qrId);
        if (payments && payments.items && payments.items.length > 0) {
            const capturedPayment = payments.items.find(p => p.status === 'captured');
            if (capturedPayment) {
                const paidAmount = capturedPayment.amount / 100;
                if (Math.abs(paidAmount - orderData.amount) < 1.0) {
                    await orderRef.update({
                        status: 'paid',
                        paymentId: capturedPayment.id,
                        paymentMethod: capturedPayment.method,
                        paidAt: admin.firestore.FieldValue.serverTimestamp(),
                    });

                    await db.collection('payments').add({
                        orderId: orderId,
                        amount: paidAmount,
                        paymentMethod: capturedPayment.method,
                        transactionId: capturedPayment.id,
                        paymentDate: new Date().toISOString(),
                        status: 'Success',
                        createdAt: admin.firestore.FieldValue.serverTimestamp(),
                    });

                    return { status: 'paid' };
                }
            }
        }
    } catch (error) {
        console.error("verifyOrder Razorpay SDK error:", error);
    }

    if (orderData.expiresAt.toDate() < new Date() && orderData.status === 'created') {
        await orderRef.update({ status: 'expired' });
        return { status: 'expired' };
    }

    return { status: orderData.status };
});

/**
 * 4. expireStaleOrders: Scheduled cron every 5 minutes to mark stale orders as expired
 */
exports.expireStaleOrders = onSchedule("*/5 * * * *", async (event) => {
    const now = admin.firestore.Timestamp.now();
    const staleOrdersSnap = await db.collection('orders')
        .where('status', '==', 'created')
        .where('expiresAt', '<', now)
        .get();

    if (staleOrdersSnap.empty) return null;

    const batch = db.batch();
    staleOrdersSnap.forEach(doc => {
        batch.update(doc.ref, { status: 'expired' });
    });

    await batch.commit();
    console.log(`Marked ${staleOrdersSnap.size} stale orders as expired.`);
    return null;
});

/**
 * Trigger: Send OTP via MSG91
 */
exports.sendMsg91Otp = onCall(async (request) => {
    let mobile = request.data.mobile;
    if (!mobile) {
        throw new HttpsError("invalid-argument", "Mobile number is required.");
    }
    mobile = mobile.toString().trim();

    const url = `https://control.msg91.com/api/v5/otp?template_id=${MSG91_TEMPLATE_ID}&mobile=${mobile}&authkey=${MSG91_AUTH_KEY}`;

    try {
        const response = await fetch(url, { method: 'POST' });
        const result = await response.json();
        console.log(`Sent OTP to ${mobile}. Result:`, result);
        if (result.type === "success") {
            return { success: true, message: "OTP sent successfully" };
        } else {
            console.error("MSG91 Error:", result);
            throw new HttpsError("internal", result.message || "Failed to send OTP.");
        }
    } catch (error) {
        console.error("Fetch Error:", error);
        throw new HttpsError("internal", "Failed to communicate with SMS service.");
    }
});

/**
 * Trigger: Verify OTP via MSG91 and return Firebase Custom Token
 */
exports.verifyMsg91Otp = onCall(async (request) => {
    let mobile = request.data.mobile;
    let otp = request.data.otp;

    if (!mobile || !otp) {
        throw new HttpsError("invalid-argument", "Mobile number and OTP are required.");
    }
    mobile = mobile.toString().trim();
    otp = otp.toString().trim();

    // Use URLSearchParams for safe encoding
    const params = new URLSearchParams({
        otp: otp,
        mobile: mobile,
        authkey: MSG91_AUTH_KEY
    });

    const url = `https://control.msg91.com/api/v5/otp/verify?${params.toString()}`;

    try {
        console.log(`Verifying OTP for ${mobile}.`);
        const response = await fetch(url, { method: 'GET' });

        if (!response.ok) {
            const errorText = await response.text();
            console.error("MSG91 API Error:", response.status, errorText);
            throw new HttpsError("internal", `SMS Gateway Error: ${response.status}`, errorText);
        }

        const result = await response.json();
        console.log(`MSG91 Response for ${mobile}:`, JSON.stringify(result));

        if (result.type === "success") {
            // OTP verified.
            let mobileForSearch = mobile;
            if (mobile.startsWith("91") && mobile.length === 12) {
                mobileForSearch = mobile.substring(2);
            }

            console.log(`Step 1: Searching for user with mobile: ${mobileForSearch}`);
            try {
                const userSnap = await db.collection('users').where('mobile', '==', mobileForSearch).limit(1).get();

                if (!userSnap.empty) {
                    const userId = userSnap.docs[0].id;
                    console.log(`Step 2: User found (ID: ${userId}). Creating custom token...`);
                    const customToken = await admin.auth().createCustomToken(userId);
                    console.log(`Step 3: Token created successfully.`);
                    return { success: true, customToken: customToken, isRegistered: true };
                } else {
                    console.log("Step 2: User not found in Firestore users collection.");
                    return { success: true, isRegistered: false };
                }
            } catch (dbError) {
                console.error("Firestore/Auth Error:", dbError);
                throw new HttpsError("internal", "Database error occurred after verification.", dbError.message);
            }
        } else {
            console.error("MSG91 Verify Logic Error:", result);
            const msg = result.message || "Invalid OTP. Please enter the correct code.";
            throw new HttpsError("unauthenticated", msg);
        }
    } catch (error) {
        if (error instanceof HttpsError) throw error;
        console.error("Fetch/Process Error:", error);
        throw new HttpsError("internal", "Verification failed. Please try again later.", error.message);
    }
});

/**
 * Trigger: When a user document is deleted from Firestore,
 * cleanup their Firebase Auth account automatically.
 */
exports.cleanupauthonuserdelete = onDocumentDeleted("users/{userId}", async (event) => {
    const userId = event.params.userId;
    try {
        await admin.auth().deleteUser(userId);
        console.log(`Successfully deleted auth user: ${userId}`);
    } catch (error) {
        console.error(`Error deleting auth user: ${userId}`, error);
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

    // ONLY notify if the appointment is already Confirmed (e.g. Walk-in by receptionist)
    // If it's Pending (awaiting payment), skip notification for now.
    if (appointment.status !== 'Confirmed') {
        console.log(`Skipping notification for ${appointmentId} as it is in ${appointment.status} status.`);
        return null;
    }

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
