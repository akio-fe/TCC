import { initializeApp } from "https://www.gstatic.com/firebasejs/9.23.0/firebase-app.js";
import {
  getAuth,
  createUserWithEmailAndPassword,
  sendEmailVerification,
  signInWithPopup,
  GoogleAuthProvider,
} from "https://www.gstatic.com/firebasejs/9.23.0/firebase-auth.js";
import {
  getFirestore,
  doc,
  setDoc,
} from "https://www.gstatic.com/firebasejs/9.23.0/firebase-firestore.js";

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
const provider = new GoogleAuthProvider();
const db = getFirestore(app);

document
  .getElementById("googleButton")
  .addEventListener("click", signInWithGoogle);

document.addEventListener("DOMContentLoaded", function () {
  const formCadastro = document.getElementById("form-cadastro");
  const mensagemFirebase = document.getElementById("mensagem-firebase");
  const senhaConfInput = document.getElementById("senhaconf");

  formCadastro.addEventListener("submit", function (event) {
    event.preventDefault();

    const email = document.getElementById("email").value;
    const senha = document.getElementById("senha").value;
    const senhaconf = senhaConfInput.value;
    const nome = document.getElementById("nome").value;
    const sobrenome = document.getElementById("sobrenome").value;
    const cpf = document.getElementById("cpf").value;
    const tel = document.getElementById("tel").value;
    const datanasc = document.getElementById("datanasc").value;

    // Limpa mensagens anteriores
    mensagemFirebase.innerHTML = "";

    // Verifica se as senhas coincidem
    if (senha !== senhaconf) {
      senhaConfInput.setCustomValidity("As senhas não conferem");
      mensagemFirebase.textContent = "As senhas não coincidem.";
      mensagemFirebase.style.color = "red";
      return;
    } else {
      senhaConfInput.setCustomValidity("");
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
          sobrenome: sobrenome,
          cpf: cpf,
          tel: tel,
          datanasc: datanasc,
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
});

async function signInWithGoogle() {
  try {
    const result = await signInWithPopup(auth, provider);
    const user = result.user;

    // Processa a autenticação no backend, assim como no login por email/senha
    await processBackendLogin(user);
  } catch (error) {
    const errorCode = error.code;
    const errorMessage = error.message;
    console.error("Erro de login com Google:", errorMessage);
    messageElement.innerText =
      "Erro ao fazer login com o Google: " + errorMessage;
  }
}
