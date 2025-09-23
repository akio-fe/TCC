<?php

//EMAIL
use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;
use Twilio\Rest\Client;
use Twilio\Exceptions\RestException;

// Inclua os arquivos do Composer
require '../vendor/autoload.php';

$option = $_POST['recoveryOption'];

if ($option == 'email') {

    //email usuario
    $usuEmail = $_POST['email'];

    // Crie uma nova instância do PHPMailer
    $mail = new PHPMailer(true);

    // Gerar o código de verificação
    $codigo = gerarCodigoDeVerificacao();

    try {
        // Configurações do servidor (SMTP)
        $mail->isSMTP();
        $mail->Host       = 'smtp.gmail.com'; //servidor do gmail
        $mail->SMTPAuth   = true;
        $mail->Username   = 'fe.akio20@gmail.com'; //email ultilizado pelo SMTP
        $mail->Password   = 'ichc hhlu norv huvo';
        $mail->SMTPSecure = PHPMailer::ENCRYPTION_SMTPS;
        $mail->Port       = 465;

        // Configurações do remetente e destinatário
        $mail->setFrom('fe.akio20@gmail.com', 'Fernando');
        $mail->addAddress($usuEmail, 'Nome do Destinatário'); //email do destinatário

        // Conteúdo do email
        $mail->isHTML(true);
        $mail->Subject = 'Código de Verificação'; //titulo do email
        $mail->Body    = "Olá,<br><br>Seu código de verificação é: <b>$codigo</b><br><br>Por favor, use este código para completar seu registro.<br><br>Obrigado!";
        $mail->AltBody = "Olá, Seu código de verificação é: $codigo. Por favor, use este código para completar seu registro. Obrigado!";

        $mail->send();
        echo 'Mensagem enviada com sucesso!';
    } catch (Exception $e) {
        echo "A mensagem não pôde ser enviada. Erro do Mailer: {$mail->ErrorInfo}";
    }

    
} elseif ($option == 'tel') {

    //Celular do usuario
    $usuTel  = $_POST['tel'];

    // Exemplo de uso:
    $numeroDoForms = '(11)98765-4321';
    $numeroFormatado = formatarNumeroParaTwilio($usuTel, '+55');

    // Seus Twilio Account SID e Auth Token
    $sid = 'ACbfe0db55a7c1d5fd51be4a50fee06f60'; // Account SID so Twilio
    $token = 'your_auth_token'; //Auth Token do Twilio
    $twilio = new Client($sid, $token);

    // Gerar o código de verificação
    $codigo = gerarCodigoDeVerificacao();

    // Número de telefone do destinatário (com código do país)
    $numeroDestino = '+55' . $usuTel;

    // Número de telefone do Twilio
    $numeroTwilio = '+15017122661';

    try {
        $message = $twilio->messages
            ->create(
                $numeroDestino, //para qual numero sera enviado
                array(
                    "from" => $numeroTwilio, // de que numero sera enviado
                    "body" => "Seu código de verificação é: " . $codigo //texto do sms
                )
            );

        print($message->sid);
        echo 'Mensagem SMS enviada com sucesso!';
    } catch (Exception $e) {
        echo "Erro ao enviar SMS: " . $e->getMessage();
    }
}

//função de gerar o código
function gerarCodigoDeVerificacao($tamanho = 6)
{
    $caracteres = '0123456789';
    $codigo = '';
    for ($i = 0; $i < $tamanho; $i++) {
        $codigo .= $caracteres[rand(0, strlen($caracteres) - 1)];
    }
    return $codigo;
}

/**
 * Formata um número de telefone mascarado para o formato E.164 do Twilio.
 * @param string $numeroMascarado O número com máscara (ex: "(11)98765-4321").
 * @param string $codigoPais O código do país no formato (+xx) (ex: "+55" para o Brasil).
 * @return string O número formatado no padrão E.164.
 */
function formatarNumeroParaTwilio($numeroMascarado, $codigoPais)
{
    // Remove todos os caracteres que não são dígitos (0-9)
    $apenasNumeros = preg_replace('/\D/', '', $numeroMascarado);

    // Concatena o código do país ao início do número limpo
    return $codigoPais . $apenasNumeros;
}
