importScripts('https://www.gstatic.com/firebasejs/9.22.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.22.0/firebase-messaging-compat.js');

firebase.initializeApp({
    apiKey: "AIzaSyCojhi4w6PPlMOM5rRReMe1sFzQ5Uf1R_E",
    authDomain: "fahis-inspector.firebaseapp.com",
    projectId: "fahis-inspector",
    storageBucket: "fahis-inspector.appspot.com",
    messagingSenderId: "447449059567",
    appId: "1:447449059567:web:04a8a581628bb66ff74b1a",
    measurementId: "G-M5C414KYW7"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  self.registration.showNotification(
    payload.notification.title,
    {
      body: payload.notification.body,
      icon: '/icons/Icon-192.png',
    }
  );
});
