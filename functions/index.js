const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.sendNotificationOnMessage = functions.firestore
    .document('messages/{messageId}')
    .onCreate(async (snap, context) => {
        const messageData = snap.data();

        // Buscar o token do dispositivo do destinatário
        const userSnapshot = await admin.firestore().collection('users').doc(messageData.recipientUID).get();
        const userToken = userSnapshot.data()?.deviceToken;

        if (userToken) {
            const payload = {
                notification: {
                    title: `New message from ${messageData.senderName}`,
                    body: messageData.content,
                }
            };

            return admin.messaging().sendToDevice(userToken, payload)
                .then(response => {
                    // Tratamento de resposta
                })
                .catch(error => {
                    console.error("Error sending notification: ", error);
                });
        }
    });
