/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

const cors = require('cors')({ origin: true });

exports.sendNotification = functions.https.onRequest((req, res) => {
    cors(req, res, () => {
        const token = req.body.token;
        const title = req.body.title;
        const body = req.body.body;

        if (!token || !title || !body) {
            return res.status(400).send('Missing required fields');
        }

        const message = {
            notification: { title, body },
            token,
        };

        admin.messaging().send(message)
            .then(response => {
                res.status(200).send({ success: true });
            })
            .catch(error => {
                res.status(500).send(error.message);
            });
    });
});


// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
