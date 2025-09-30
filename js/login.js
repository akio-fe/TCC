import { initializeApp } from "https://www.gstatic.com/firebasejs/9.6.1/firebase-app.js";
import {
  getAuth,
  signInWithEmailAndPassword,
  signInWithPopup,
  GoogleAuthProvider,
  AppleAuthProvider,
} from "https://www.gstatic.com/firebasejs/9.6.1/firebase-auth.js";

const firebaseConfig = {
  apiKey: "AIzaSyBtblDahBpfrT4CaLl2viS0D2890iJ_RFE",
  authDomain: "imperium-0001.firebaseapp.com",
  projectId: "imperium-0001",
  storageBucket: "imperium-0001.firebasestorage.app",
  messagingSenderId: "961834611988",
  appId: "1:961834611988:web:0a2ad6089630324094be01",
  measurementId: "G-M39V86RLKS",
};

const app = initializeApp(firebaseConfig);
const auth = getAuth(app);

// MUDANÇA 1: Renomear a variável para ser específica do Google.
const googleProvider = new GoogleAuthProvider(); 

const loginForm = document.getElementById("login-form");
const emailInput = document.getElementById("email-login");
const passwordInput = document.getElementById("senha-login");
const messageElement = document.getElementById("login-message");
const appleButton = document.getElementById("appleButton");
// Certifique-se de que este elemento existe no seu HTML
const appleMessageDiv = document.getElementById("apple-message"); 

appleButton.addEventListener("click", async () => {
  // MUDANÇA 2: Usar um nome específico para o provedor da Apple.
  const appleProvider = new AppleAuthProvider();

  try {
    // MUDANÇA 3: Usar a nova variável do provedor da Apple.
    const result = await signInWithPopup(auth, appleProvider);

    const idToken = await result.user.getIdToken();

    const response = await fetch("../php/apple_login.php", {
      method: "POST",
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: `idToken=${encodeURIComponent(idToken)}`,
    });

    const data = await response.json();

    if (data.success) {
      appleMessageDiv.textContent = `Login com Apple bem-sucedido! UID: ${data.uid}`;
      appleMessageDiv.style.color = "green";
    } else {
      appleMessageDiv.textContent = `Erro no backend: ${data.message}`;
      appleMessageDiv.style.color = "red";
    }
  } catch (error) {
    appleMessageDiv.textContent = `Erro: ${error.message}`;
    appleMessageDiv.style.color = "red";
    console.error("Erro no login com Apple:", error);
  }
});

document
  .getElementById("googleButton")
  .addEventListener("click", signInWithGoogle);

loginForm.addEventListener("submit", async (e) => {
    // ... (o seu código de login com email e senha permanece o mesmo, está correto)
    e.preventDefault();
    messageElement.innerText = "";
    const email = emailInput.value;
    const password = passwordInput.value;
    try {
        const userCredential = await signInWithEmailAndPassword(auth, email, password);
        const user = userCredential.user;
        await processBackendLogin(user);
    } catch (error) {
        console.error("Erro de login:", error.code, error.message);
        let errorMessage = "Ocorreu um erro no login.";
        switch (error.code) {
            case "auth/user-not-found":
                errorMessage = "Nenhum usuário encontrado com este e-mail.";
                break;
            case "auth/wrong-password":
                errorMessage = "Senha incorreta.";
                break;
            case "auth/invalid-email":
                errorMessage = "Formato de e-mail inválido.";
                break;
            default:
                errorMessage = "Erro desconhecido. Por favor, tente novamente.";
                break;
        }
        messageElement.innerText = errorMessage;
    }
});

async function signInWithGoogle() {
  try {
    // MUDANÇA 4: Usar a variável específica do provedor do Google.
    const result = await signInWithPopup(auth, googleProvider); 
    const user = result.user;
    await processBackendLogin(user);
  } catch (error) {
    const errorCode = error.code;
    const errorMessage = error.message;
    console.error("Erro de login com Google:", errorMessage);
    messageElement.innerText = "Erro ao fazer login com o Google: " + errorMessage;
  }
}

async function processBackendLogin(user) {
    // ... (esta função permanece a mesma, está correta)
    try {
        const idToken = await user.getIdToken();
        const response = await fetch("../php/login_handler.php", {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                Authorization: `Bearer ${idToken}`,
            },
        });
        const result = await response.json();
        if (result.success) {
            messageElement.innerText = "Login bem-sucedido! Redirecionando...";
            console.log("Login com sucesso:", user);
            setTimeout(() => {
                window.location.href = "../php/login.php";
            }, 2000);
        } else {
            messageElement.innerText = result.message;
        }
    } catch (error) {
        console.error("Erro ao enviar token para o backend:", error);
        messageElement.innerText = "Erro na comunicação com o servidor.";
    }
}