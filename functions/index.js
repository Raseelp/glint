// /**
//  * Import function triggers from their respective submodules:
//  *
//  * const {onCall} = require("firebase-functions/v2/https");
//  * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
//  *
//  * See a full list of supported triggers at https://firebase.google.com/docs/functions
//  */

// // const {onRequest} = require("firebase-functions/v2/https");
// // const logger = require("firebase-functions/logger");

// // Create and deploy your first functions
// // https://firebase.google.com/docs/functions/get-started

// // exports.helloWorld = onRequest((request, response) => {
// //   logger.info("Hello logs!", {structuredData: true});
// //   response.send("Hello from Firebase!");
// // });

// const functions = require("firebase-functions");
// const admin = require("firebase-admin");

// admin.initializeApp();

// exports.incrementThemeSetterIndex=
// functions.pubsub.schedule("every 24 hours").onRun(async (context) => {
//   const groupsSnapshot = await admin.firestore().collection("groups").get();
//   const batch = admin.firestore().batch();
//   groupsSnapshot.forEach((doc) =>{
//     const currentIndex = doc.data().themesetterindex;
//     const members = doc.data().members.length; // Get the number of members

//     // Calculate the new index
//     const newIndex = (currentIndex + 1) % members;

//     // Set the new index in the Firestore document
//     batch.update(doc.ref, {themesetterindex: newIndex});
//   });

//   await batch.commit(); // Commit all updates
// });

