import { initializeApp } from "https://www.gstatic.com/firebasejs/9.6.1/firebase-app.js";
import {
  getAuth,
  createUserWithEmailAndPassword,
  sendEmailVerification,
  signInWithEmailAndPassword,
  signInWithPopup,
  GoogleAuthProvider,
} from "https://www.gstatic.com/firebasejs/9.6.1/firebase-auth.js";

import {
  getFirestore,
  doc,
  setDoc,
} from "https://www.gstatic.com/firebasejs/9.6.1/firebase-firestore.js"; // <--- Importação corrigida aqui!

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
const googleProvider = new GoogleAuthProvider();
const db = getFirestore(app);
const loginForm = document.getElementById("login-form");
const emailInput = document.getElementById("email-login");
const passwordInput = document.getElementById("senha-login");
const messageElement = document.getElementById("login-message");

const formCadastro = document.getElementById("form-cadastro");
const mensagemFirebase = document.getElementById("mensagem-firebase");
const senhaconfInput = document.getElementById("confirma_senha"); // <--- Variavel corrigida para o input
const emailInputCadastro = document.getElementById("email");
const senhaInputCadastro = document.getElementById("senha");
const nomeInputCadastro = document.getElementById("nome");
const cpfInputCadastro = document.getElementById("CPF");
const telInputCadastro = document.getElementById("tel"); // Assumindo que você tem um campo de telefone

document
  .getElementById("googleButton")
  .addEventListener("click", signInWithGoogle);

loginForm.addEventListener("submit", async (e) => {
  e.preventDefault();
  messageElement.innerText = "";
  const email = emailInput.value;
  const password = passwordInput.value;
  try {
    const userCredential = await signInWithEmailAndPassword(
      auth,
      email,
      password
    );
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

formCadastro.addEventListener("submit", function (event) {
  event.preventDefault();

  // Limpa mensagens anteriores
  mensagemFirebase.innerHTML = "";

  // Pega os valores dentro do event listener
  const email = emailInputCadastro.value;
  const senha = senhaInputCadastro.value;
  const senhaconf = senhaconfInput.value;
  const nome = nomeInputCadastro.value;
  const cpf = cpfInputCadastro.value;
  const tel = telInputCadastro.value;

  // Verifica se as senhas coincidem
  if (senha !== senhaconf) {
    senhaconfInput.setCustomValidity("As senhas não conferem");
    mensagemFirebase.textContent = "As senhas não coincidem.";
    mensagemFirebase.style.color = "red";
    return;
  } else {
    senhaconfInput.setCustomValidity("");
  }

  // Exibe mensagem de carregamento para o usuário
  mensagemFirebase.textContent = "Processando cadastro...";
  mensagemFirebase.style.color = "blue";

  // 1. Criar o usuário no Firebase Authentication
  createUserWithEmailAndPassword(auth, email, senha)
    .then((userCredential) => {
      const user = userCredential.user;

      // 2. Salvar dados adicionais no Firestore
      return setDoc(doc(db, "unverified_users", user.uid), {
        nome: nome,
        cpf: cpf,
        tel: tel,
        email: user.email,
        uid: user.uid,
      });
    })
    .then(() => {
      // 3. Enviar o e-mail de verificação
      const user = auth.currentUser;
      if (user) {
        return sendEmailVerification(user);
      } else {
        throw new Error("Usuário não encontrado após o cadastro.");
      }
    })
    .then(() => {
      // 4. Exibir mensagem de sucesso
      mensagemFirebase.textContent =
        "Cadastro realizado com sucesso! Um e-mail de verificação foi enviado. Por favor, verifique sua caixa de entrada para ativar sua conta.";
      mensagemFirebase.style.color = "green";
      formCadastro.reset();
    })
    .catch((error) => {
      const errorCode = error.code;
      let errorMessage =
        "Ocorreu um erro ao cadastrar. Por favor, tente novamente.";

      if (errorCode === "auth/email-already-in-use") {
        errorMessage = "Este e-mail já está em uso.";
      } else if (errorCode === "auth/weak-password") {
        errorMessage = "A senha deve ter pelo menos 6 caracteres.";
      } else if (errorCode === "auth/invalid-email") {
        errorMessage = "O endereço de e-mail é inválido.";
      } else if (errorCode === "permission-denied") {
        errorMessage =
          "Erro de permissão no Firestore. Verifique suas regras de segurança.";
      }

      mensagemFirebase.textContent = errorMessage;
      mensagemFirebase.style.color = "red";
      console.error(errorCode, error.message);
    });
});

async function signInWithGoogle() {
  try {
    const result = await signInWithPopup(auth, googleProvider);
    const user = result.user;
    await processBackendLogin(user);
  } catch (error) {
    const errorCode = error.code;
    const errorMessage = error.message;
    console.error("Erro de login com Google:", errorMessage);
    messageElement.innerText =
      "Erro ao fazer login com o Google: " + errorMessage;
  }
}

async function processBackendLogin(user) {
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