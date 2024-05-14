importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-messaging.js");

firebase.initializeApp({
  apiKey: "AIzaSyBq358c85xFpsEiAiVK3uaxoYSEr_UDHpw",
  authDomain: "coldiary-72f1c.firebaseapp.com",
  projectId: "coldiary-72f1c",
  storageBucket: "coldiary-72f1c.appspot.com",
  messagingSenderId: "901079657910",
  appId: "1:901079657910:web:989a470a4267d7e680a517",
});


const messaging = firebase.messaging();
// Optional:
messaging.onBackgroundMessage((payload) => {
  console.log(
      '[firebase-messaging-sw.js] Received background message ',
      payload
  );
});
