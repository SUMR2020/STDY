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
        const task = context.params.uid;
        const due = change.get('due').seconds;

        const token = await db.collection('users').get(); // Get Single Token document
        // const key = token.toString(); // Get Token Key

        console.log(token);
        // console.log(key);
        const payload = {
            notification: {
                title: `New message from ${task}`,
                body: ` Subject : ${due}`,
            }
        };
        return fcm.sendToDevice('fX63zN1tyO0:APA91bGbAz-4XGjOyUw_1nHOETAm9QBMDjXgJxpRjP8HQANiEWBP7Ki3mrhsuAp6aKDy9m0BdqZqXspxuvsoo5hGQtgvHPG-FWpiVikMrekhgQV9Gl-i7xkUVzPIObM3MRpB7iWxCeIE', payload);
    });
