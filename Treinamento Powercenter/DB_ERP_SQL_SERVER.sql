USE MASTER 
GO 

IF NOT EXISTS (SELECT 1 FROM SYS.DATABASES WHERE NAME = 'ERP_DB') 
BEGIN
	CREATE DATABASE ERP_DB 
END 
GO 

USE ERP_DB
GO


IF NOT EXISTS (SELECT 1 FROM SYS.TABLES WHERE NAME = 'CATEGORIA')
BEGIN 
	CREATE TABLE CATEGORIA 
	(	
		IDCATEGORIA INT NOT NULL IDENTITY, 
		CATEGORIA   VARCHAR(100)

		PRIMARY KEY (IDCATEGORIA)
	)
END
GO 

--------------------------------------------------------
--  DDL for Table CLIENTES
--------------------------------------------------------

IF NOT EXISTS (SELECT 1 FROM SYS.TABLES WHERE NAME = 'CLIENTES')
BEGIN 
	CREATE TABLE CLIENTES 
	(	
		IDCLIENTE  INT NOT NULL IDENTITY, 
		CLIENTE    VARCHAR(50), 
		ESTADO     CHAR(2), 
		SEXO       CHAR(1), 
		STATUS     VARCHAR(50)

		PRIMARY KEY (IDCLIENTE)
	)
END
GO 
  
  
--------------------------------------------------------
--  DDL for Table CLIENTE_ATR
--------------------------------------------------------

IF NOT EXISTS (SELECT 1 FROM SYS.TABLES WHERE NAME = 'CLIENTE_ATR')
BEGIN 
	CREATE TABLE CLIENTE_ATR 
	(	
		IDCLIENTE    INT  NOT NULL, 
		DTNASCIMENTO DATE NOT NULL
	
		FOREIGN KEY (IDCLIENTE) REFERENCES CLIENTES (IDCLIENTE)
	)
END
GO



--------------------------------------------------------
--  DDL for Table PRODUTOS
--------------------------------------------------------

IF NOT EXISTS (SELECT 1 FROM SYS.TABLES WHERE NAME = 'PRODUTOS')
BEGIN 
	CREATE TABLE PRODUTOS 
	(
		IDPRODUTO INT NOT NULL IDENTITY, 
		PRODUTO   VARCHAR(100), 
		PRECO	  DECIMAL(6,2)

		PRIMARY KEY (IDPRODUTO)
	)
END
GO  


--------------------------------------------------------
--  DDL for Table VINCULACAO_PRODUTO_CATEGORIA
--------------------------------------------------------

IF NOT EXISTS (SELECT 1 FROM SYS.TABLES WHERE NAME = 'VINCULACAO_PRODUTO_CATEGORIA')
BEGIN 
	CREATE TABLE VINCULACAO_PRODUTO_CATEGORIA 
	(
		IDVINCULACAO INT NOT NULL, 
		IDCATEGORIA  INT NOT NULL, 
		IDPRODUTO    INT NOT NULL

		PRIMARY KEY (IDVINCULACAO), 

		FOREIGN KEY (IDCATEGORIA) REFERENCES CATEGORIA (IDCATEGORIA),
		FOREIGN KEY (IDPRODUTO)   REFERENCES PRODUTOS  (IDPRODUTO)
	) 
END
GO

--------------------------------------------------------
--  DDL for Table VENDEDORES
--------------------------------------------------------

IF NOT EXISTS (SELECT 1 FROM SYS.TABLES WHERE NAME = 'VENDEDORES')
BEGIN  
	CREATE TABLE VENDEDORES 
	(	
		IDVENDEDOR INT NOT NULL IDENTITY, 
		NOME       VARCHAR(50)

		PRIMARY KEY (IDVENDEDOR)
	)
END 
GO 

   

--------------------------------------------------------
--  DDL for Table VENDAS
--------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM SYS.TABLES WHERE NAME = 'VENDAS')
BEGIN 
	CREATE TABLE VENDAS 
	(
		IDVENDA    INT NOT NULL IDENTITY, 
		IDVENDEDOR INT, 
		IDCLIENTE  INT, 
		DATA       DATE, 
		TOTAL	   DECIMAL(10,2)

		PRIMARY KEY (IDVENDA),

		FOREIGN KEY (IDCLIENTE)  REFERENCES CLIENTES   (IDCLIENTE),
		FOREIGN KEY (IDVENDEDOR) REFERENCES VENDEDORES (IDVENDEDOR)
	)
END 
GO

--------------------------------------------------------
--  DDL for Table ITENSVENDA
--------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM SYS.TABLES WHERE NAME = 'ITENSVENDA') 
BEGIN 
	CREATE TABLE ITENSVENDA 
	(	
		IDPRODUTO     INT NOT NULL, 
		IDVENDA       INT NOT NULL, 
		QUANTIDADE    INT, 
		VALORUNITARIO DECIMAL(10,2), 
		VALORTOTAL    DECIMAL(10,2), 
		DESCONTO      DECIMAL(10,2)

		PRIMARY KEY (IDPRODUTO, IDVENDA)

		FOREIGN KEY (IDPRODUTO) REFERENCES PRODUTOS (IDPRODUTO),
		FOREIGN KEY (IDVENDA)   REFERENCES VENDAS (IDVENDA)
  
	)
END 
GO
