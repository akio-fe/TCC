<?php
// php/login_handler.php

session_start();

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Authorization, Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

require __DIR__ . '/vendor/autoload.php';

use Kreait\Firebase\Factory;
use Kreait\Firebase\Exception\Auth\ExpiredIdToken;
use Kreait\Firebase\Exception\Auth\RevokedIdToken;
use Kreait\Firebase\Exception\Auth\InvalidToken;
use Kreait\Firebase\Exception\Auth\AuthException;
use \InvalidArgumentException;

$factory = (new Factory)
    ->withServiceAccount('imperium-0001-firebase-adminsdk-fbsvc-ffc86182cf.json');
$auth = $factory->createAuth();

$headers = getallheaders();
$idToken = null;

if (isset($headers['Authorization'])) {
    $idToken = str_replace('Bearer ', '', $headers['Authorization']);
}

if (!$idToken) {
    http_response_code(401);
    echo json_encode(['success' => false, 'message' => 'Token de autenticação não fornecido.']);
    exit;
}

try {
    // 1. Tenta verificar o token
    $verifiedIdToken = $auth->verifyIdToken($idToken);
    
    // A partir daqui, o token é considerado válido e seguro para uso.
    // As chamadas para ->claims() agora estão seguras.
    $uid = $verifiedIdToken->claims()->get('sub');

    // 2. O token é válido, inicia a sessão do PHP
    $_SESSION['firebase_uid'] = $uid;
    $_SESSION['logged_in'] = true;
    $_SESSION['email'] = $verifiedIdToken->claims()->get('email');

    echo json_encode([
        'success' => true,
        'message' => 'Sessão iniciada com sucesso.',
        'uid' => $uid
    ]);

} catch (ExpiredIdToken $e) {
    // Captura se o token expirou
    http_response_code(401);
    echo json_encode(['success' => false, 'message' => 'Sessão expirada. Faça login novamente.']);
} catch (RevokedIdToken $e) {
    // Captura se o token foi revogado
    http_response_code(401);
    echo json_encode(['success' => false, 'message' => 'Sessão revogada. Faça login novamente.']);
} catch (InvalidToken $e) {
    // Captura tokens inválidos de forma geral
    http_response_code(401);
    echo json_encode(['success' => false, 'message' => 'Token de autenticação inválido.']);
} catch (AuthException $e) {
    // Captura outras exceções de autenticação
    http_response_code(401);
    echo json_encode(['success' => false, 'message' => 'Erro de autenticação: ' . $e->getMessage()]);
} catch (InvalidArgumentException $e) {
    // Captura tokens mal formatados ou outros erros de argumento
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Formato de token inválido: ' . $e->getMessage()]);
} catch (\Exception $e) {
    // Captura qualquer outro erro inesperado
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Erro interno do servidor: ' . $e->getMessage()]);
}