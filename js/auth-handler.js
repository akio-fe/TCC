// js/auth-handler.js
import { initializeApp } from "https://www.gstatic.com/firebasejs/9.23.0/firebase-app.js";
import {
  getAuth,
  confirmPasswordReset,
  verifyPasswordResetCode,
  applyActionCode,
  onAuthStateChanged,
  reload,
} from "https://www.gstatic.com/firebasejs/9.23.0/firebase-auth.js";
import {
  getFirestore,
  doc,
  getDoc,
  deleteDoc,
} from "https://www.gstatic.com/firebasejs/9.23.0/firebase-firestore.js";

// Sua configuração do Firebase
const firebaseConfig = {
  apiKey: "AIzaSyBtblDahBpfrT4CaLl2viS0D2890iJ_RFE",
  authDomain: "imperium-0001.firebaseapp.com",
  projectId: "imperium-0001",
  storageBucket: "imperium-0001.firebasestorage.app",
  messagingSenderId: "961834611988",
  appId: "1:961834611988:web:0a2ad6089630324094be01",
  measurementId: "G-M39V86RLKS",
};

// Inicializar Firebase
const app = initializeApp(firebaseConfig);
const auth = getAuth(app);
const db = getFirestore(app);

document.addEventListener("DOMContentLoaded", function () {
  const authTitle = document.getElementById("authTitle");
  const authMessage = document.getElementById("authMessage");
  const urlParams = new URLSearchParams(window.location.search);
  const mode = urlParams.get("mode");
  const oobCode = urlParams.get("oobCode");

  if (!mode || !oobCode) {
    authTitle.textContent = "Erro";
    authMessage.textContent =
      "Link de autenticação inválido. Por favor, tente novamente.";
    return;
  }

  switch (mode) {
    case "resetPassword":
      handleResetPassword(oobCode);
      break;
    case "verifyEmail":
      handleVerifyEmail(oobCode);
      break;
    default:
      authTitle.textContent = "Ação desconhecida";
      authMessage.textContent =
        "Ação de autenticação não reconhecida. Redirecionando...";
      setTimeout(() => (window.location.href = "index.html"), 3000);
      break;
  }

  // Função de verificação de e-mail modificada
  async function handleVerifyEmail(oobCode) {
    authTitle.textContent = "Verificação de E-mail";
    authMessage.textContent = "Verificando sua conta...";

    try {
      await applyActionCode(auth, oobCode);

      // O e-mail foi verificado com sucesso.
      const user = auth.currentUser;
      if (!user) {
        authMessage.textContent =
          "Sessão de usuário não encontrada. Por favor, faça login para continuar.";
        setTimeout(() => (window.location.href = "../html/cadastro_login.html"), 3000);
        return;
      }

      // Acessar dados temporários no Firestore
      const docRef = doc(db, "unverified_users", user.uid);
      const docSnap = await getDoc(docRef);

      if (docSnap.exists()) {
        const userData = docSnap.data();

        // Enviar os dados para o seu servidor de backend
        const idToken = await user.getIdToken();
        const response = await fetch("../php/checkout.php", {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            Authorization: `Bearer ${idToken}`,
          },
          body: JSON.stringify(userData),
        });

        const result = await response.json();

        if (result.success) {
          authMessage.textContent =
            "E-mail verificado e dados salvos! Redirecionando...";
          // Apagar o documento temporário do Firestore
          await deleteDoc(docRef);
          setTimeout(() => (window.location.href = "../index.html"), 3000);
        } else {
          authMessage.textContent =
            "E-mail verificado, mas ocorreu um erro ao salvar dados. Entre em contato com o suporte.";
          console.error("Erro no servidor:", result.message);
        }
      } else {
        authMessage.textContent =
          "E-mail verificado, mas dados adicionais não encontrados. Entre em contato com o suporte.";
      }
    } catch (error) {
      authTitle.textContent = "Erro na Verificação";
      authMessage.textContent =
        "O link de verificação é inválido ou já foi usado. Tente fazer login e reenviar o e-mail.";
      console.error(error);
    }
  }
});
