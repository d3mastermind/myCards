/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

import {setGlobalOptions} from "firebase-functions";
// import {onRequest} from "firebase-functions/https";
import * as logger from "firebase-functions/logger";
import * as functions from "firebase-functions/v1";
import * as admin from "firebase-admin";

// Start writing functions
// https://firebase.google.com/docs/functions/typescript

// For cost control, you can set the maximum number of containers that can be
// running at the same time. This helps mitigate the impact of unexpected
// traffic spikes by instead downgrading performance. This limit is a
// per-function limit. You can override the limit for each function using the
// `maxInstances` option in the function's options, e.g.
// `onRequest({ maxInstances: 5 }, (req, res) => { ... })`.
// NOTE: setGlobalOptions does not apply to functions using the v1 API. V1
// functions should each use functions.runWith({ maxInstances: 10 }) instead.
// In the v1 API, each function can only serve one request per container, so
// this will be the maximum concurrent request count.
setGlobalOptions({ maxInstances: 10 });

// export const helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
// Initialize Firebase Admin
if (!admin.apps.length) {
    admin.initializeApp();
}

export const onUserCreated = functions.runWith({
  maxInstances: 10}).auth.user().onCreate(async (user) => {

  if (!user || !user.uid) {
    console.log("No user data found");
    return;
  }

  const userDocRef = admin.firestore().collection("users").doc(user.uid);
  const userSnapshot = await userDocRef.get();
  if (userSnapshot.exists) {
    console.log(`User document already exists for: ${user.uid}`);
    return;
  }

  const userData = {
    userId: user.uid,
    email: user.email || null,
    phoneNumber: user.phoneNumber || null,
    name: user.displayName || null,
    creditBalance: 10,
    purchasedCards: [],
    likedCards: [],
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  };

  await userDocRef.set(userData);

  // Create credits subcollection with initial balance
  await userDocRef.collection("credits").doc("balance").set({
    balance: 10,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  // Create receivedCards subcollection (empty collection)
  // Each document in this collection will represent a received card
  // with its own properties like cardId, senderId, receivedAt, etc.

  // Create initial transaction record
  await userDocRef.collection("transactions").add({
    userId: user.uid,
    amount: 10,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    type: "purchase",
    status: "completed",
    description: "Welcome bonus credits",
    paymentMethod: "signup_bonus",
  });

  logger.info(`User document and credits created successfully for: ${user.uid}`, {
    structuredData: true,
  });
});