// web/firebase-messaging-sw.js

importScripts('https://www.gstatic.com/firebasejs/9.22.1/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.22.1/firebase-messaging-compat.js');

// Your web app's Firebase configuration (same as your web app)
const firebaseConfig = {
  apiKey: "AIzaSyB-pJfFVndCqQENAsYHNjd9-kLVwz-wXsw",
  authDomain: "farm-to-home-8c520.firebaseapp.com",
  projectId: "farm-to-home-8c520",
  storageBucket: "farm-to-home-8c520.firebasestorage.app",
  messagingSenderId: "1066615778167",
  appId: "1:1066615778167:web:eb326011ac316be1a18f72",
  measurementId: "G-H9GD71QDLP"
};

firebase.initializeApp(firebaseConfig);

const messaging = firebase.messaging();

// Handle background messages
messaging.onBackgroundMessage((payload) => {
  console.log('Received background message: ', payload);
  // Customize notification here
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: '/icons/Icon-192.png' // optional
  };
  self.registration.showNotification(notificationTitle, notificationOptions);
});