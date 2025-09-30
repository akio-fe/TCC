<?php
// Em qualquer outra página PHP
session_start();

if (!isset($_SESSION['logged_in']) || $_SESSION['logged_in'] !== true) {
    // O usuário não está logado, redireciona para a página de login
    header('Location: ../html/cadastro_login.html');
    exit;
}

// Se o código chegou aqui, o usuário está logado.
// Você pode acessar o UID e o e-mail do Firebase na sessão
$firebaseUid = $_SESSION['firebase_uid'];
$userEmail = $_SESSION['email'];

echo "Bem-vindo, " . htmlspecialchars($userEmail) . "! Seu UID é: " . htmlspecialchars($firebaseUid);
?>