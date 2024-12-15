const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.sendWelcomeNotification = functions.analytics
  .event('sign_in_email') // Triggered when a user logs in with email
  .onLog(async (event) => {
    const userEmail = event.params.email;

    const message = {
      notification: {
        title: 'Welcome!',
        body: `Hi ${userEmail}, thanks for signing in!`,
      },
      topic: 'welcome_notifications',
    };

    // Send a push notification
    await admin.messaging().send(message);
    console.log('Welcome notification sent to:', userEmail);
  });
