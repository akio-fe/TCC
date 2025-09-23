/*Deletando o banco de dados imperium para evitar conflitos*/
DROP DATABASE IF EXISTS imperium;

/*Criação do banco de dados imperium*/
CREATE DATABASE imperium;

/*Definindo o banco de dados imperium a ser ultilizado*/
USE imperium;

/*Criação da tabela Usuario*/
CREATE TABLE Usuario (
    -- Definindo UsuId como chave primaria e dando ela auto incremento --
    UsuId INTEGER(11) PRIMARY KEY NOT NULL AUTO_INCREMENT,
    UsuCpf VARCHAR(14),
    UsuLoginNome VARCHAR(150),
    UsuDataNasc DATE,
    UsuSenha VARCHAR(150),
    UsuEmail VARCHAR(150),
    UsuTel VARCHAR(15),
    UsuNome VARCHAR(50),
    UsuSobrenome VARCHAR(50),
    UsuFuncao SMALLINT(1),
    UNIQUE (UsuEmail, UsuTel, UsuCpf)
);

/* Criação da tabela Carrinho */
CREATE TABLE Carrinho (
    -- Definindo CarId como chave primaria e dando ela auto incremento --
    CarId INTEGER(11) PRIMARY KEY NOT NULL AUTO_INCREMENT,
    CarDataCre DATE,
    CarDataAtu DATE,
    UsuId INTEGER(11)
);
/* Criação da chave estrangeira entre as tabelas Usuario e Carrinho */
ALTER TABLE Carrinho ADD CONSTRAINT FK_Carrinho_1
    FOREIGN KEY (UsuId)
    REFERENCES Usuario (UsuId);

/* Endereço de entrega: */
CREATE TABLE EnderecoEntrega (
    -- Definindo EndEntId como chave primaria e dando ela auto incremento --
    EndEntId INTEGER(11) PRIMARY KEY,
    EndEntRef VARCHAR(50),
    EndEntRua VARCHAR(150),
    EndEntCep VARCHAR(9),
    EndEntNum INTEGER(7),
    EndEntBairro VARCHAR(100),
    EndEntCid VARCHAR(150),
    EndEntEst VARCHAR(50),
    EndEntComple VARCHAR(100),
    UsuId INTEGER(11)
);
/* Criação da chave estrangeira entre as tabelas Usuario e Endereço de entrega */
ALTER TABLE EnderecoEntrega ADD CONSTRAINT FK_EnderecoEntrega_2
    FOREIGN KEY (UsuId)
    REFERENCES Usuario (UsuId);

/* Criação da tabela Estoque: */
CREATE TABLE Estoque (
    -- Definindo EstoId como chave primaria e dando ela auto incremento --
    EstoId INTEGER(11) PRIMARY KEY  NOT NULL AUTO_INCREMENT,
    EstoQtd INTEGER(11),
    EstoNum VARCHAR(15),
    EstoEst VARCHAR(50),
    EstoCid VARCHAR(50),
    EstoRua VARCHAR(150),
    EstoBairro VARCHAR(100),
    EstoCep VARCHAR(9),
    EstoDesc VARCHAR(150)
);

/* Criação da tabela Categoria da Roupa: */
CREATE TABLE CatRoupa (
    -- Definindo CatRId como chave primaria e dando ela auto incremento --
    CatRId INTEGER(11) PRIMARY KEY  NOT NULL AUTO_INCREMENT,
    CatRSexo VARCHAR(50),
    CatRTipo VARCHAR(100),
    CatRSessao VARCHAR(100)
);

/* Criação da tabela Roupa: */
CREATE TABLE Roupa (
    -- Definindo RoupaId como chave primaria e dando ela auto incremento --
    RoupaId INT  NOT NULL AUTO_INCREMENT PRIMARY KEY,
    RoupaNome VARCHAR(100),
    RoupaCor VARCHAR(50),
    RoupaImg LONGBLOB,
    RoupaValor DECIMAL(10,2),
    CatRId INT,
    EstoId INT,
    UNIQUE (RoupaNome),
    INDEX idx_roupaimg (RoupaImg(255))
);
/*Criação da chave estrangeira entre as tabelas Estoque e Roupa*/
ALTER TABLE Roupa ADD CONSTRAINT FK_Roupa_2
    FOREIGN KEY (EstoId)
    REFERENCES Estoque (EstoId);
/* Criação da chave estrangeira entre as tabelas Categoria da Roupa e Roupa*/
ALTER TABLE Roupa ADD CONSTRAINT FK_Roupa_4
    FOREIGN KEY (CatRId)
    REFERENCES CatRoupa (CatRId);

/* Criação da tabela CarrinhoProduto: */
CREATE TABLE CarrinhoProduto (
    -- Definindo CarProID como chave primaria e dando ela auto incremento --
    CarProID INTEGER(11) PRIMARY KEY NOT NULL AUTO_INCREMENT,
    CarProQtd INTEGER(11),
    CarProPreco DECIMAL(10,2),
    CarId INTEGER(11),
    RoupaId INTEGER(11)
);
/*Criação da chave estrangeira entre as tabelas Carrinho e CarrinhoProduto*/
ALTER TABLE CarrinhoProduto ADD CONSTRAINT FK_CarrinhoProduto_2
    FOREIGN KEY (CarId)
    REFERENCES Carrinho (CarId);
 /*Criação da chave estrangeira entre as tabelas Roupa e CarrinhoProduto*/
ALTER TABLE CarrinhoProduto ADD CONSTRAINT FK_CarrinhoProduto_3
    FOREIGN KEY (RoupaId)
    REFERENCES Roupa (RoupaId);
    
/* Criação da tabela Pedido: */
CREATE TABLE Pedido (
    -- Definindo PedId como chave primaria e dando ela auto incremento --
    PedId INT AUTO_INCREMENT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    PedValor DECIMAL(10,2),
    PedFormEnt SMALLINT(1),
    PedStatus SMALLINT(1),
    PedFormPag SMALLINT(1),
    CarProId1 INT,
    CarProId2 INT,
    CarProId3 INT,
    CarProId4 INT,
    CarProId5 INT,
    CarProId6 INT,
    CarProId7 INT,
    CarProId8 INT,
    CarProId9 INT,
    CarProId10 INT,
    /*Crição das chaves estrangeiras entre as tabelas CarrinhoProduto e Pedido*/
    FOREIGN KEY (CarProId1) REFERENCES CarrinhoProduto(CarProId),
    FOREIGN KEY (CarProId2) REFERENCES CarrinhoProduto(CarProId),
    FOREIGN KEY (CarProId3) REFERENCES CarrinhoProduto(CarProId),
    FOREIGN KEY (CarProId4) REFERENCES CarrinhoProduto(CarProId),
    FOREIGN KEY (CarProId5) REFERENCES CarrinhoProduto(CarProId),
    FOREIGN KEY (CarProId6) REFERENCES CarrinhoProduto(CarProId),
    FOREIGN KEY (CarProId7) REFERENCES CarrinhoProduto(CarProId),
    FOREIGN KEY (CarProId8) REFERENCES CarrinhoProduto(CarProId),
    FOREIGN KEY (CarProId9) REFERENCES CarrinhoProduto(CarProId),
    FOREIGN KEY (CarProId10) REFERENCES CarrinhoProduto(CarProId)
);
  
/* Criação da tabela Pagemento: */
CREATE TABLE Pagamento (
    -- Definindo PagId como chave primaria e dando ela auto incremento --
    PagId INTEGER(11) PRIMARY KEY NOT NULL AUTO_INCREMENT,
    PagDataHora DATETIME,
    PagMet SMALLINT(1),
    PagDesc DECIMAL(10,2),
    PagValor DECIMAL(10,2),
    PagValorTotal DECIMAL(10,2),
    PedId INTEGER(11)
);
/*Criação da chave estrangeira entre as tabelas Pedido e Pagamento*/
ALTER TABLE Pagamento ADD CONSTRAINT FK_Pagamento_1
    FOREIGN KEY (PedId)
    REFERENCES Pedido (PedId);    