// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript
//
// export const helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });
import * as admin from 'firebase-admin';
admin.initializeApp();
import * as functions from 'firebase-functions';
const db = admin.firestore();
const fcm = admin.messaging();

exports.useMultipleWildcard = functions.firestore
    .document('users/{uid}/Grades/{course}/Tasks/{id}')
    .onCreate(async (change, context) => {
        const uid = context.params.uid;
        const name = change.get('name');
        const type = change.get('type');
        const course = change.get('onlyCourse');
        let due = change.get('due').seconds;
        // let d = new Date();
        const unixtime = due.valueOf();
        due = new Date(unixtime*1000);

        const token = await db.collection('users').doc(`${uid}`).get();
        const key = await token?.data()?.token; // Get Single Token document 

        console.log(key);
        const payload = {
            notification: {
                title: `You have a ${type} due today!`,
                body: `${name} for ${course} is due today, make sure to get it done!`,
            }
        };
        return fcm.sendToDevice(key, payload);
    });
