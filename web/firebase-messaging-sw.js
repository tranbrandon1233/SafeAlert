importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-messaging.js");

firebase.initializeApp({
    apiKey: 'AIzaSyD2Tw95W_WH7HbHtB5EQweaBAvoeqAvtZE',
    appId: '1:826371401282:web:8d52d6005653fb408eafdb',
    messagingSenderId: '826371401282',
    projectId: 'lahack-14f69',
    authDomain: 'lahack-14f69.firebaseapp.com',
    databaseURL: 'https://lahack-14f69-default-rtdb.firebaseio.com',
    storageBucket: 'lahack-14f69.appspot.com',
    measurementId: 'G-QVCLG7NB3K',
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((message) => {
  console.log("onBackgroundMessage", message);
});