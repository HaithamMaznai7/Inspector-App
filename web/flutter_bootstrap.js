// Import the functions you need from the SDKs you need
// import { initializeApp } from "firebase/app";
// import { getAnalytics } from "firebase/analytics";
// TODO: Add SDKs for Firebase products that you want to use
// https://firebase.google.com/docs/web/setup#available-libraries

// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
const firebaseConfig = {
  apiKey: "AIzaSyAeOwl-Srk6IRJYyDtGRTu0R1NL8F-rGow",
  authDomain: "fahis-inspector-v1.firebaseapp.com",
  projectId: "fahis-inspector-v1",
  storageBucket: "fahis-inspector-v1.firebasestorage.app",
  messagingSenderId: "11004766009",
  appId: "1:11004766009:web:14d35adcd365a8e1356ae8",
  measurementId: "G-2GGPNY66J3"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const analytics = getAnalytics(app);