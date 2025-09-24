/*Deletando o banco de dados imperium para evitar conflitos*/
DROP DATABASE IF EXISTS imperium;

/*Criação do banco de dados imperium*/
CREATE DATABASE imperium;

/*Definindo o banco de dados imperium a ser ultilizado*/
USE imperium;

/*
Tabela: Usuario
Propósito: Armazena as informações de todos os usuários cadastrados no sistema, sejam clientes ou administradores.
*/
CREATE TABLE Usuario (
    -- Chave primária da tabela, identificador único para cada usuário.
    UsuId INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    -- UID (User ID) fornecido por um serviço de autenticação externo (ex: Firebase, Auth0).
    -- Esta é a forma moderna e segura de identificar um usuário, sem armazenar senhas no banco de dados.
    UsuUID VARCHAR(255) UNIQUE NOT NULL,
    -- E-mail do usuário, usado para login e comunicação. Deve ser único.
    UsuEmail VARCHAR(150) UNIQUE NOT NULL,
    -- Nome completo do usuário.
    UsuNome VARCHAR(255) NOT NULL,
    -- O CPF e o Telefone podem ser nulos inicialmente e preenchidos depois pelo usuário.
    UsuCpf VARCHAR(14) UNIQUE NULL,
    UsuTel VARCHAR(15) UNIQUE NULL,
    UsuDataNasc DATE NULL,
    -- Define o papel do usuário no sistema. Ex: 1 = Administrador, 2 = Cliente. O padrão é ser cliente.
    UsuFuncao SMALLINT(1) NULL DEFAULT 2
);

/*
Tabela: CatRoupa (Categoria da Roupa)
Propósito: Define as categorias para classificar as roupas, facilitando a busca e organização dos produtos no site.
*/
CREATE TABLE CatRoupa (
    -- Chave primária da tabela, identificador único para cada categoria.
    CatRId INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    -- Gênero ao qual a categoria se aplica (ex: 'Masculino', 'Feminino', 'Unissex').
    CatRSexo VARCHAR(50) NOT NULL,
    -- Tipo de peça de roupa (ex: 'Camiseta', 'Calça', 'Jaqueta').
    CatRTipo VARCHAR(100) NOT NULL,
    -- Sessão ou coleção a que pertence (ex: 'Verão 2024', 'Esportiva', 'Casual').
    CatRSessao VARCHAR(100) NOT NULL
);

/*
Tabela: Roupa
Propósito: Tabela central do e-commerce, armazena os detalhes de cada produto (roupa) disponível para venda.
*/
CREATE TABLE Roupa (
    -- Chave primária da tabela, identificador único para cada produto.
    RoupaId INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    -- Nome do produto (ex: 'Camiseta Gola V').
    RoupaNome VARCHAR(100) NOT NULL,
    -- Cor principal do produto.
    RoupaCor VARCHAR(50) NOT NULL,
    --  URL aonde a imagem 3D da roupa fica guardado dentro do servidor
    RoupaImgUrl VARCHAR(255) UNIQUE NOT NULL,
    -- Preço de venda do produto.
    RoupaValor DECIMAL(10, 2) NOT NULL,
    -- Chave estrangeira que liga a roupa a uma categoria.
    CatRId INT NOT NULL,
    -- Garante que a combinação de nome e cor da roupa seja única, evitando produtos duplicados.
    UNIQUE INDEX idx_roupa_nome_cor (RoupaNome, RoupaCor)
);
/* Criação da chave estrangeira entre as tabelas CatRoupa e Roupa*/
ALTER TABLE Roupa
ADD CONSTRAINT FK_Roupa_4 FOREIGN KEY (CatRId) REFERENCES CatRoupa (CatRId);

/*
Tabela: Carrinho
Propósito: Armazena o dados do carrinho que será criado para cada usuario e usado para agrupar os CarrinhoProdutos.
*/
CREATE TABLE Carrinho (
    -- Definindo CarId como chave primaria e dando ela auto incremento --
    CarId INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    -- Data e hora em que o carrinho foi criado. Importante para análises de carrinhos abandonados.
    CarDataCre DATETIME NOT NULL,
    -- Data e hora da última modificação no carrinho (adição/remoção de item).
    CarDataAtu DATETIME NOT NULL,
    -- Chave estrangeira que liga o carrinho a um usuário específico.
    UsuId INT NOT NULL
);
/* Criação da chave estrangeira entre as tabelas Usuario e Carrinho */
ALTER TABLE Carrinho
ADD CONSTRAINT FK_Carrinho_1 FOREIGN KEY (UsuId) REFERENCES Usuario (UsuId);

/*
Tabela: CarrinhoProduto
Propósito: Tabela de junção (N-N) que lista os produtos que um usuário adicionou ao seu carrinho de compras.
*/
CREATE TABLE CarrinhoProduto (
    -- Definindo CarProID como chave primaria e dando ela auto incremento --
    CarProID INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    -- Quantidade do produto no carrinho.
    CarProQtd INT NOT NULL,
    -- Preço do produto no momento em que foi adicionado ao carrinho, para evitar problemas com alteração de preços.
    CarProPreco DECIMAL(10, 2) NOT NULL,
    CarId INT NOT NULL,
    RoupaId INT NOT NULL,
    -- Garante que não é possível adicionar o mesmo produto duas vezes no mesmo carrinho (deve-se apenas atualizar a quantidade).
    UNIQUE INDEX idx_car_roupa (CarId, RoupaId)
);
/*Criação da chave estrangeira entre as tabelas Carrinho e CarrinhoProduto*/
ALTER TABLE CarrinhoProduto
ADD CONSTRAINT FK_CarrinhoProduto_2 FOREIGN KEY (CarId) REFERENCES Carrinho (CarId);
/*Criação da chave estrangeira entre as tabelas Roupa e CarrinhoProduto*/
ALTER TABLE CarrinhoProduto
ADD CONSTRAINT FK_CarrinhoProduto_3 FOREIGN KEY (RoupaId) REFERENCES Roupa (RoupaId);

/*
Tabela: EnderecoEntrega
Propósito: Armazena os múltiplos endereços de entrega que um usuário pode cadastrar em sua conta.
*/
CREATE TABLE EnderecoEntrega (
    -- Chave primária da tabela, identificador único para cada endereço.
    EndEntId INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    -- Referência para o endereço, ex: "Casa", "Trabalho", para fácil identificação pelo usuário.
    EndEntRef VARCHAR(50) NOT NULL,
    EndEntRua VARCHAR(150) NOT NULL,
    EndEntCep VARCHAR(9) NOT NULL,
    EndEntNum INTEGER(7) NOT NULL,
    EndEntBairro VARCHAR(100) NOT NULL,
    EndEntCid VARCHAR(150) NOT NULL,
    -- Sigla do estado (UF) com 2 caracteres é o padrão (ex: 'SP', 'RJ').
    EndEntEst VARCHAR(2) NOT NULL,
    -- Complemento do endereço (ex: "Apto 101", "Bloco B"). Pode ser opcional.
    EndEntComple VARCHAR(100) NULL,
    -- Chave estrangeira que liga o endereço a um usuário.
    UsuId INT NOT NULL
);
/* Criação da chave estrangeira entre as tabelas Usuario e Endereço de entrega */
ALTER TABLE EnderecoEntrega
ADD CONSTRAINT FK_EnderecoEntrega_2 FOREIGN KEY (UsuId) REFERENCES Usuario (UsuId);

/*
Tabela: Estoque
Propósito: Gerencia os locais físicos de armazenamento dos produtos (armazéns, depósitos, lojas físicas).
*/
CREATE TABLE Estoque (
    -- Chave primária da tabela, identificador único para cada local de estoque.
    EstoId INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    -- Número ou código de identificação do local de estoque.
    EstoNum VARCHAR(15) NOT NULL,
    EstoEst VARCHAR(50) NOT NULL,
    EstoCid VARCHAR(50) NOT NULL,
    EstoRua VARCHAR(150) NOT NULL,
    EstoBairro VARCHAR(100) NOT NULL,
    EstoCep VARCHAR(9) NOT NULL,
    -- Descrição do estoque
    EstoDesc VARCHAR(150) NOT NULL
);

/*
Tabela: EstoqueProduto
Propósito: Tabela de junção (N-N) que controla a quantidade de cada produto (Roupa) em cada local de estoque (Estoque).
*/
CREATE TABLE EstoqueProduto (
    -- Chave primária da tabela.
    EstProId INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    -- Quantidade do produto específico neste local de estoque. Não pode ser negativa.
    EstProQtd INT NOT NULL DEFAULT 0,
    -- Data e hora da última atualização do registro de estoque. Atualiza automaticamente sempre que a linha é modificada.
    EstProDataAtu TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    -- Chave estrangeira que identifica o local de estoque.
    EstoId INT NOT NULL,
    -- Chave estrangeira que identifica o produto (roupa).
    RoupaId INT NOT NULL,
    -- Garante que existe apenas um registro de quantidade para cada produto em cada estoque.
    UNIQUE INDEX idx_esto_roupa (EstoId, RoupaId),
    FOREIGN KEY (EstoId) REFERENCES Estoque (EstoId),
    FOREIGN KEY (RoupaId) REFERENCES Roupa (RoupaId)
);
/*
Tabela: Pedido
Propósito: Armazena o cabeçalho de cada pedido realizado, com informações gerais da compra, status e entrega.
Os itens específicos do pedido são armazenados em uma tabela separada (PedidoProduto)
para permitir um número ilimitado de itens por pedido.
*/
CREATE TABLE Pedido (
    -- Chave primária da tabela, identificador único para cada pedido.
    PedId INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    -- Data e hora em que o pedido foi finalizado pelo cliente.
    PedData DATETIME NOT NULL,
    -- Valor total do pedido, incluindo todos os itens e possíveis taxas.
    PedValorTotal DECIMAL(10, 2) NOT NULL,
    -- Código para a forma de entrega. 1 = Correios, 2 = Transportadora, 3 = Retirar na Loja.
    PedFormEnt SMALLINT(1) NOT NULL,
    -- Código para o status atual do pedido.1 = Aguardando Pagamento, 2 = Pago, 3 = Em Separação, 4 = Enviado, 5 = Entregue, 6 = Cancelado.
    PedStatus SMALLINT(1) NOT NULL,
    -- Código para a forma de pagamento escolhida. Ex: 1 = Cartão de Crédito, 2 = Boleto, 3 = PIX.
    PedFormPag SMALLINT(1) NOT NULL,
    -- Chave estrangeira que identifica o usuário que fez o pedido.
    UsuId INT NOT NULL,
    -- Chave estrangeira que identifica o endereço de entrega selecionado para este pedido.
    EndEntId INT NOT NULL,
    FOREIGN KEY (UsuId) REFERENCES Usuario (UsuId),
    FOREIGN KEY (EndEntId) REFERENCES EnderecoEntrega (EndEntId)
);

/* Tabela de associação para os itens de um pedido (relação N-N entre Pedido e Roupa) */
CREATE TABLE PedidoProduto (
    -- Chave primária da tabela.
    PedProId INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    -- Quantidade do produto específico neste pedido.
    PedProQtd INT NOT NULL,
    -- Preço unitário do produto no momento da compra, para garantir a integridade histórica do pedido.
    PedProPrecoUnitario DECIMAL(10, 2) NOT NULL,
    -- Chave estrangeira que liga este item ao pedido correspondente.
    PedId INT NOT NULL,
    -- Chave estrangeira que identifica o produto comprado.
    RoupaId INT NOT NULL,
    FOREIGN KEY (PedId) REFERENCES Pedido (PedId),
    FOREIGN KEY (RoupaId) REFERENCES Roupa (RoupaId)
);

/*
Tabela: Pagamento
Propósito: Registra as transações de pagamento associadas a um pedido. Permite múltiplos pagamentos por pedido, se necessário.
*/
CREATE TABLE Pagamento (
    -- Chave primária da tabela, identificador único para cada transação de pagamento.
    PagId INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    -- Data e hora em que o pagamento foi processado.
    PagDataHora DATETIME NOT NULL,
    -- Valor efetivamente pago nesta transação.
    PagValor DECIMAL(10, 2) NOT NULL,
    -- Código de transação retornado pelo gateway de pagamento, se houver.
    PagTransacaoCod VARCHAR(255) NULL,
    -- Chave estrangeira que liga o pagamento ao pedido.
    PedId INT NOT NULL
);
/*Criação da chave estrangeira entre as tabelas Pedido e Pagamento*/
ALTER TABLE Pagamento
ADD CONSTRAINT FK_Pagamento_1 FOREIGN KEY (PedId) REFERENCES Pedido (PedId);