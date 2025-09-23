<?php

declare(strict_types=1);

require __DIR__ . '/vendor/autoload.php';

// Inicia a sessão no topo do script
session_start();

use Kreait\Firebase\Factory;
use Kreait\Firebase\Exception\Auth\InvalidIdToken;

header('Content-Type: application/json');

// Função para retornar uma resposta JSON e encerrar o script
function json_response(bool $success, string $message, ?string $uid = null): void
{
    $response = ['success' => $success, 'message' => $message];
    if ($uid) {
        $response['uid'] = $uid;
    }
    echo json_encode($response);
    exit;
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    json_response(false, 'Método de requisição inválido.');
}

$idToken = $_POST['idToken'] ?? null;

if (!$idToken) {
    json_response(false, 'O ID Token da Apple não foi fornecido.');
}

$factory = (new Factory)
    ->withServiceAccount(__DIR__ . '/seu-arquivo-de-credenciais.json'); // <-- IMPORTANTE: Altere para o caminho do seu arquivo de credenciais

$auth = $factory->createAuth();

try {
    // Use signInWithIdpIdToken para provedores OAuth como Apple, Google, etc.
    // O primeiro parâmetro é o ID do provedor. Para a Apple, é 'apple.com'.
    $signInResult = $auth->signInWithIdpIdToken('apple.com', $idToken);

    // Login bem-sucedido!
    $uid = $signInResult->firebaseUserId();

    // Armazena o UID do usuário na sessão para mantê-lo logado
    $_SESSION['firebase_user_id'] = $uid;
    $_SESSION['user_data'] = $signInResult->data(); // Armazena outros dados se necessário

    json_response(true, 'Login com Apple realizado com sucesso!', $uid);
} catch (InvalidIdToken $e) {
    json_response(false, 'O ID Token da Apple é inválido ou expirou: ' . $e->getMessage());
} catch (\Throwable $e) {
    // Captura outras exceções genéricas
    json_response(false, 'Ocorreu um erro inesperado: ' . $e->getMessage());
}