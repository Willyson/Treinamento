-- =================================================================================
-- = ATUALIZA OS CLIENTES DO DIMENSIONAL QUE J� EST�O NA BASE POR�M HOUVE ALTERA��O
-- =================================================================================
USE DW_DB
GO

UPDATE DIMENSAOCLIENTE 
SET DATAFIMVALIDADE = GETDATE()
WHERE CHAVECLIENTE IN 
(
	SELECT 
		DC.CHAVECLIENTE
	FROM DIMENSAOCLIENTE DC 
	INNER JOIN ERP_DB.dbo.CLIENTES EC ON (DC.IDCLIENTE = EC.IDCLIENTE) 
	WHERE DC.DATAFIMVALIDADE IS NULL  
	AND 
	(
		EC.CLIENTE <> DC.CLIENTE OR  EC.ESTADO <> DC.ESTADO OR EC.SEXO <> DC.SEXO OR EC.STATUS <> DC.STATUS
	)
)


-- =============================
-- = PRIMEIRA CARGA DE CLIENTES 
-- =============================

INSERT INTO DIMENSAOCLIENTE (IDCLIENTE, CLIENTE, ESTADO, SEXO, STATUS, DATAINICIOVALIDADE, DATAFIMVALIDADE)
SELECT 
	EC.IDCLIENTE, 
	EC.CLIENTE,
	EC.ESTADO,
	EC.SEXO,
	EC.STATUS,
	GETDATE(),
	NULL
FROM ERP_DB.dbo.CLIENTES EC
WHERE EC.IDCLIENTE IN 
(
	SELECT 
		DC.CHAVECLIENTE
	FROM DIMENSAOCLIENTE DC 
	INNER JOIN ERP_DB.dbo.CLIENTES EC ON (DC.IDCLIENTE = EC.IDCLIENTE) 
	WHERE DC.DATAFIMVALIDADE IS NULL  
	AND 
	(
		EC.CLIENTE <> DC.CLIENTE OR  EC.ESTADO <> DC.ESTADO OR EC.SEXO <> DC.SEXO OR EC.STATUS <> DC.STATUS
	)
)
OR EC.IDCLIENTE NOT IN (SELECT IDCLIENTE FROM DIMENSAOCLIENTE)






-- ===================================================
-- = VERIFICA SE HOUVE ALTERA��O NO NOME DO VENDEDOR.
-- =================================================== 

UPDATE DIMENSAOVENDEDOR
SET DATAFIMVALIDADE = GETDATE()
WHERE IDVENDEDOR IN 
(
	SELECT 
		EV.IDVENDEDOR
	FROM DIMENSAOVENDEDOR DV 
	INNER JOIN ERP_DB.dbo.VENDEDORES EV ON (DV.IDVENDEDOR = EV.IDVENDEDOR ) 
	WHERE DV.DATAFIMVALIDADE IS NULL AND EV.NOME <> DV.NOME
)

INSERT INTO DIMENSAOVENDEDOR (IDVENDEDOR, NOME, DATAINICIOVALIDADE, DATAFIMVALIDADE)
SELECT 
	EV.IDVENDEDOR, EV.NOME, GETDATE(), NULL
FROM ERP_DB.dbo.VENDEDORES EV
WHERE EV.IDVENDEDOR IN 
(
	SELECT 
		EV.IDVENDEDOR
	FROM DIMENSAOVENDEDOR DV 
	INNER JOIN ERP_DB.dbo.VENDEDORES EV ON (DV.IDVENDEDOR = EV.IDVENDEDOR ) 
	WHERE DV.DATAFIMVALIDADE IS NULL AND EV.NOME <> DV.NOME
)
OR 
EV.IDVENDEDOR NOT IN 
(
	SELECT DV.IDVENDEDOR FROM DIMENSAOVENDEDOR DV
)


-- ===================================
-- = CARGA DE PRODUTOS NA DIMENSIONAL
-- ===================================

UPDATE DIMENSAOPRODUTO 
SET DATAFIMVALIDADE = GETDATE()
WHERE  IDPRODUTO IN 
(
	SELECT EP.IDPRODUTO
	FROM ERP_DB.dbo.PRODUTOS EP 
	INNER JOIN DIMENSAOPRODUTO DP ON (EP.IDPRODUTO = DP.IDPRODUTO)
	WHERE DP.DATAINICIOVALIDADE IS NULL 
	AND (EP.PRODUTO <> DP.PRODUTO)
)

INSERT INTO DIMENSAOPRODUTO (IDPRODUTO, PRODUTO, DATAINICIOVALIDADE, DATAFIMVALIDADE)
SELECT 
	IDPRODUTO, PRODUTO, GETDATE(), NULL
FROM ERP_DB.dbo.PRODUTOS EP 
WHERE EP.IDPRODUTO IN 
(
	SELECT EP.IDPRODUTO
	FROM ERP_DB.dbo.PRODUTOS EP 
	INNER JOIN DIMENSAOPRODUTO DP ON (EP.IDPRODUTO = DP.IDPRODUTO)
	WHERE DP.DATAINICIOVALIDADE IS NULL 
	AND (EP.PRODUTO <> DP.PRODUTO)
) OR 
EP.IDPRODUTO NOT IN 
(
	SELECT IDPRODUTO
	FROM DIMENSAOPRODUTO
)



-- ===========================
-- = CARGA DA FATO DE JANEIRO 
-- ===========================


INSERT INTO fatovendas(chavevendedor, chavecliente, chaveproduto, chavetempo, quantidade, valorunitario, valortotal, VALORDESCONTO, VALORLIQUIDO)
SELECT
	VDD.CHAVEVENDEDOR,
    C.CHAVECLIENTE,
    P.CHAVEPRODUTO,
    T.CHAVETEMPO,
    IV.QUANTIDADE,
    IV.VALORUNITARIO,
	IV.VALORUNITARIO * IV.QUANTIDADE AS VALORTOTAL, 
    IV.DESCONTO,
	IV.VALORTOTAL - IV.DESCONTO AS VALORLIQUIDO
FROM ERP_DB.DBO.VENDAS V
INNER JOIN DIMENSAOVENDEDOR VDD
	ON V.IDVENDEDOR = VDD.IDVENDEDOR AND VDD.DATAFIMVALIDADE IS NULL /*DATAFIMVALIDADE IS NULL REPRESENTA O REGISTRO ATUAL DO VENDEDOR PARA A CARGA DA FATO NO MOMENTO*/
INNER JOIN ERP_DB.DBO.ITENSVENDA IV
	ON V.IDVENDA = IV.IDVENDA
INNER JOIN DIMENSAOCLIENTE C
	ON V.IDCLIENTE = C.IDCLIENTE AND C.DATAFIMVALIDADE IS NULL /*DATAFIMVALIDADE IS NULL REPRESENTA O REGISTRO ATUAL DO CLIENTE PARA A CARGA DA FATO NO MOMENTO*/
INNER JOIN DIMENSAOPRODUTO P
	ON IV.IDPRODUTO = P.IDPRODUTO AND P.DATAFIMVALIDADE IS NULL /*DATAFIMVALIDADE IS NULL REPRESENTA O REGISTRO ATUAL DO PRODUTO PARA A CARGA DA FATO NO MOMENTO*/
INNER JOIN DIMENSAOTEMPO T
	ON V.DATA = T.DATA

WHERE MONTH(V.DATA) = 01


-- ====================================
-- = CARGA DO MES DE FEVEREIRO DA FATO 
-- ====================================

INSERT INTO FATOVENDAS(CHAVEVENDEDOR, CHAVECLIENTE, CHAVEPRODUTO, CHAVETEMPO, QUANTIDADE, VALORUNITARIO, VALORTOTAL, VALORDESCONTO, VALORLIQUIDO)
SELECT
	VDD.CHAVEVENDEDOR,
    C.CHAVECLIENTE,
    P.CHAVEPRODUTO,
    T.CHAVETEMPO,
    IV.QUANTIDADE,
    IV.VALORUNITARIO,
	IV.VALORUNITARIO * IV.QUANTIDADE AS VALORTOTAL, 
    IV.DESCONTO,
	IV.VALORTOTAL - IV.DESCONTO AS VALORLIQUIDO
FROM ERP_DB.DBO.VENDAS V
INNER JOIN DIMENSAOVENDEDOR VDD
	ON V.IDVENDEDOR = VDD.IDVENDEDOR AND VDD.DATAFIMVALIDADE IS NULL /*DATAFIMVALIDADE IS NULL REPRESENTA O REGISTRO ATUAL DO VENDEDOR PARA A CARGA DA FATO NO MOMENTO*/
INNER JOIN ERP_DB.DBO.ITENSVENDA IV
	ON V.IDVENDA = IV.IDVENDA
INNER JOIN DIMENSAOCLIENTE C
	ON V.IDCLIENTE = C.IDCLIENTE AND C.DATAFIMVALIDADE IS NULL /*DATAFIMVALIDADE IS NULL REPRESENTA O REGISTRO ATUAL DO CLIENTE PARA A CARGA DA FATO NO MOMENTO*/
INNER JOIN DIMENSAOPRODUTO P
	ON IV.IDPRODUTO = P.IDPRODUTO AND P.DATAFIMVALIDADE IS NULL /*DATAFIMVALIDADE IS NULL REPRESENTA O REGISTRO ATUAL DO PRODUTO PARA A CARGA DA FATO NO MOMENTO*/
INNER JOIN DIMENSAOTEMPO T
	ON V.DATA = T.DATA

WHERE MONTH(V.DATA) = 02



-- =================
-- = CARGA DE MAR�O 
-- =================

INSERT INTO FATOVENDAS(CHAVEVENDEDOR, CHAVECLIENTE, CHAVEPRODUTO, CHAVETEMPO, QUANTIDADE, VALORUNITARIO, VALORTOTAL, VALORDESCONTO, VALORLIQUIDO)
SELECT
	VDD.CHAVEVENDEDOR,
    C.CHAVECLIENTE,
    P.CHAVEPRODUTO,
    T.CHAVETEMPO,
    IV.QUANTIDADE,
    IV.VALORUNITARIO,
	IV.VALORUNITARIO * IV.QUANTIDADE AS VALORTOTAL, 
    IV.DESCONTO,
	IV.VALORTOTAL - IV.DESCONTO AS VALORLIQUIDO
FROM ERP_DB.DBO.VENDAS V
INNER JOIN DIMENSAOVENDEDOR VDD
	ON V.IDVENDEDOR = VDD.IDVENDEDOR AND VDD.DATAFIMVALIDADE IS NULL /*DATAFIMVALIDADE IS NULL REPRESENTA O REGISTRO ATUAL DO VENDEDOR PARA A CARGA DA FATO NO MOMENTO*/
INNER JOIN ERP_DB.DBO.ITENSVENDA IV
	ON V.IDVENDA = IV.IDVENDA
INNER JOIN DIMENSAOCLIENTE C
	ON V.IDCLIENTE = C.IDCLIENTE AND C.DATAFIMVALIDADE IS NULL /*DATAFIMVALIDADE IS NULL REPRESENTA O REGISTRO ATUAL DO CLIENTE PARA A CARGA DA FATO NO MOMENTO*/
INNER JOIN DIMENSAOPRODUTO P
	ON IV.IDPRODUTO = P.IDPRODUTO AND P.DATAFIMVALIDADE IS NULL /*DATAFIMVALIDADE IS NULL REPRESENTA O REGISTRO ATUAL DO PRODUTO PARA A CARGA DA FATO NO MOMENTO*/
INNER JOIN DIMENSAOTEMPO T
	ON V.DATA = T.DATA

WHERE MONTH(V.DATA) = 03


-- =========================
-- = CARGA DOS DEMAIS MESES 
-- =========================

INSERT INTO FATOVENDAS(CHAVEVENDEDOR, CHAVECLIENTE, CHAVEPRODUTO, CHAVETEMPO, QUANTIDADE, VALORUNITARIO, VALORTOTAL, VALORDESCONTO, VALORLIQUIDO)
SELECT
	VDD.CHAVEVENDEDOR,
    C.CHAVECLIENTE,
    P.CHAVEPRODUTO,
    T.CHAVETEMPO,
    IV.QUANTIDADE,
    IV.VALORUNITARIO,
	IV.VALORUNITARIO * IV.QUANTIDADE AS VALORTOTAL, 
    IV.DESCONTO,
	IV.VALORTOTAL - IV.DESCONTO AS VALORLIQUIDO
FROM ERP_DB.DBO.VENDAS V
INNER JOIN DIMENSAOVENDEDOR VDD
	ON V.IDVENDEDOR = VDD.IDVENDEDOR AND VDD.DATAFIMVALIDADE IS NULL /*DATAFIMVALIDADE IS NULL REPRESENTA O REGISTRO ATUAL DO VENDEDOR PARA A CARGA DA FATO NO MOMENTO*/
INNER JOIN ERP_DB.DBO.ITENSVENDA IV
	ON V.IDVENDA = IV.IDVENDA
INNER JOIN DIMENSAOCLIENTE C
	ON V.IDCLIENTE = C.IDCLIENTE AND C.DATAFIMVALIDADE IS NULL /*DATAFIMVALIDADE IS NULL REPRESENTA O REGISTRO ATUAL DO CLIENTE PARA A CARGA DA FATO NO MOMENTO*/
INNER JOIN DIMENSAOPRODUTO P
	ON IV.IDPRODUTO = P.IDPRODUTO AND P.DATAFIMVALIDADE IS NULL /*DATAFIMVALIDADE IS NULL REPRESENTA O REGISTRO ATUAL DO PRODUTO PARA A CARGA DA FATO NO MOMENTO*/
INNER JOIN DIMENSAOTEMPO T
	ON V.DATA = T.DATA

WHERE MONTH(V.DATA) > 3


-- ========================
-- = CARGA DE FAIXA ET�RIA 
-- ========================

INSERT INTO DIMENSAOFAIXAETARIA (CHAVEINICIO, CHAVEFIM, DEFAIXA)
VALUES 
('0', '12', '0 a 12 Anos'), 
('13','17','13 a 17 Anos'),
('18','25','18 a 25 Anos'),
('26','45','26 a 45 Anos'),
('46','60','46 a 60 Anos'),
('61','999','Acima de 60 Anos'),
('-1','-1','N�o informada')


-- ======================
-- = CARGA DE LOCALIDADE
-- ======================

INSERT INTO DIMENSAOLOCALIDADE (SGESTADO, NOESTADO, NOREGIAO) VALUES ('AM', 'Amazonas ', 'Norte')
INSERT INTO DIMENSAOLOCALIDADE (SGESTADO, NOESTADO, NOREGIAO) VALUES ('RR', 'Roraima ', 'Norte')
INSERT INTO DIMENSAOLOCALIDADE (SGESTADO, NOESTADO, NOREGIAO) VALUES ('AP', 'Amap� ', 'Norte')
INSERT INTO DIMENSAOLOCALIDADE (SGESTADO, NOESTADO, NOREGIAO) VALUES ('PA', 'Par� ', 'Norte')
INSERT INTO DIMENSAOLOCALIDADE (SGESTADO, NOESTADO, NOREGIAO) VALUES ('TO', 'Tocantins ', 'Norte')
INSERT INTO DIMENSAOLOCALIDADE (SGESTADO, NOESTADO, NOREGIAO) VALUES ('RO', 'Rond�nia ', 'Norte')
INSERT INTO DIMENSAOLOCALIDADE (SGESTADO, NOESTADO, NOREGIAO) VALUES ('AC', 'Acre ', 'Norte')
INSERT INTO DIMENSAOLOCALIDADE (SGESTADO, NOESTADO, NOREGIAO) VALUES ('MA', 'Maranh�o ', 'Nordeste')
INSERT INTO DIMENSAOLOCALIDADE (SGESTADO, NOESTADO, NOREGIAO) VALUES ('PI', 'Piau� ', 'Nordeste')
INSERT INTO DIMENSAOLOCALIDADE (SGESTADO, NOESTADO, NOREGIAO) VALUES ('CE', 'Cear� ', 'Nordeste')
INSERT INTO DIMENSAOLOCALIDADE (SGESTADO, NOESTADO, NOREGIAO) VALUES ('RN', 'Rio Grande do Norte ', 'Nordeste')
INSERT INTO DIMENSAOLOCALIDADE (SGESTADO, NOESTADO, NOREGIAO) VALUES ('PE', 'Pernambuco ', 'Nordeste')
INSERT INTO DIMENSAOLOCALIDADE (SGESTADO, NOESTADO, NOREGIAO) VALUES ('PB', 'Para�ba ', 'Nordeste')
INSERT INTO DIMENSAOLOCALIDADE (SGESTADO, NOESTADO, NOREGIAO) VALUES ('SE', 'Sergipe ', 'Nordeste')
INSERT INTO DIMENSAOLOCALIDADE (SGESTADO, NOESTADO, NOREGIAO) VALUES ('AL', 'Alagoas ', 'Nordeste')
INSERT INTO DIMENSAOLOCALIDADE (SGESTADO, NOESTADO, NOREGIAO) VALUES ('BA', 'Bahia ', 'Nordeste')
INSERT INTO DIMENSAOLOCALIDADE (SGESTADO, NOESTADO, NOREGIAO) VALUES ('MT', 'Mato Grosso ', 'Centro-Oeste')
INSERT INTO DIMENSAOLOCALIDADE (SGESTADO, NOESTADO, NOREGIAO) VALUES ('MS', 'Mato Grosso do Sul ', 'Centro-Oeste')
INSERT INTO DIMENSAOLOCALIDADE (SGESTADO, NOESTADO, NOREGIAO) VALUES ('GO', 'Goi�s ', 'Centro-Oeste')
INSERT INTO DIMENSAOLOCALIDADE (SGESTADO, NOESTADO, NOREGIAO) VALUES ('SP', 'S�o Paulo ', 'Sudeste')
INSERT INTO DIMENSAOLOCALIDADE (SGESTADO, NOESTADO, NOREGIAO) VALUES ('RJ', 'Rio de Janeiro ', 'Sudeste')
INSERT INTO DIMENSAOLOCALIDADE (SGESTADO, NOESTADO, NOREGIAO) VALUES ('ES', 'Esp�rito Santo ', 'Sudeste')
INSERT INTO DIMENSAOLOCALIDADE (SGESTADO, NOESTADO, NOREGIAO) VALUES ('MG', 'Minas Gerais ', 'Sudeste')
INSERT INTO DIMENSAOLOCALIDADE (SGESTADO, NOESTADO, NOREGIAO) VALUES ('PR', 'Paran� ', 'Sul')
INSERT INTO DIMENSAOLOCALIDADE (SGESTADO, NOESTADO, NOREGIAO) VALUES ('RS', 'Rio Grande do Sul ', 'Sul')
INSERT INTO DIMENSAOLOCALIDADE (SGESTADO, NOESTADO, NOREGIAO) VALUES ('SC', 'Santa Catarina ', 'Sul')
INSERT INTO DIMENSAOLOCALIDADE (SGESTADO, NOESTADO, NOREGIAO) VALUES ('DF', 'Distrito Federal', 'Centro-Oeste')





-- ===================
-- = INSERE ODSVENDAS
-- ===================

INSERT INTO ODSVENDAS 
SELECT CHAVEVENDEDOR, 
		CHAVECLIENTE,
		CHAVEPRODUTO, 
		CHAVETEMPO, 
		QUANTIDADE,
		VALORUNITARIO,
		VALORLIQUIDO AS VALORTOTAL, 
		VALORDESCONTO 
FROM [dbo].[FATOVENDAS]


-- ===================================
-- = ATUALIZA A FAIXA DE CADA CLIENTE
-- ===================================

UPDATE FATOVENDAS
SET CHAVEFAIXA = TAB.CHAVEFAIXA
FROM 
(
	SELECT 
	IDCLIENTE,
	
	(
		SELECT
			FAIXA.CHAVEFAIXA  
		FROM DIMENSAOFAIXAETARIA FAIXA
		WHERE DATEDIFF(YEAR, DTNASCIMENTO, GETDATE()) >= CHAVEINICIO AND DATEDIFF(YEAR, DTNASCIMENTO, GETDATE()) <= CHAVEFIM
	) AS CHAVEFAIXA

	FROM ERP_DB.dbo.CLIENTE_ATR CA 
) AS TAB
WHERE CHAVECLIENTE = TAB.IDCLIENTE



-- ================================
-- = ATUALIZA A LOCALIDADE NA FATO
-- ================================

UPDATE FATOVENDAS
SET CHAVELOCALIDADE = TAB.CHAVELOCALIDADE
FROM 
(
	SELECT IDCLIENTE,
		(
			SELECT 
				CHAVELOCALIDADE 
			FROM DIMENSAOLOCALIDADE LOCALIDADE
			WHERE CLI_END.ESTADO = LOCALIDADE.SGESTADO
		
		) AS CHAVELOCALIDADE
	FROM ERP_DB.DBO.[CLIENTES] CLI_END
) TAB
WHERE CHAVECLIENTE = TAB.IDCLIENTE


-- ================
-- = TERCEIRO ITEM
-- ================


INSERT INTO FATOVENDASMES
SELECT 
	CHAVEVENDEDOR,
	CHAVELOCALIDADE,
	CHAVEFAIXA,
	CHAVEPRODUTO, 
	NEW_TEMPO.CHAVETEMPO_NEW AS CHAVETEMPO, 
	SUM(QUANTIDADE) QUANTIDADE,
	SUM(VALORTOTAL) VALORTOTAL,
	SUM(VALORDESCONTO) VALORDESCONTO,
	SUM(VALORLIQUIDO) VALORLIQUIDO
FROM FATOVENDAS FATO
INNER JOIN DIMENSAOTEMPO TEMPO ON (FATO.CHAVETEMPO = TEMPO.CHAVETEMPO)

INNER JOIN 
(
	SELECT 
		FORMAT(TEMPO.DATA, 'yyyy-MM-01') AS PRIMEIRO_DIA, FATO.CHAVEVENDAS,
		(
			SELECT CHAVETEMPO
			FROM DIMENSAOTEMPO 
			WHERE FORMAT(TEMPO.DATA, 'yyyy-MM-01') = DATA
		) AS CHAVETEMPO_NEW
	FROM FATOVENDAS FATO
	INNER JOIN DIMENSAOTEMPO TEMPO ON (FATO.CHAVETEMPO = TEMPO.CHAVETEMPO)
) AS NEW_TEMPO ON (FATO.CHAVEVENDAS = NEW_TEMPO.CHAVEVENDAS)
GROUP BY 
	CHAVEVENDEDOR,
	CHAVELOCALIDADE,
	CHAVEFAIXA,
	CHAVEPRODUTO,
	NEW_TEMPO.CHAVETEMPO_NEW



SELECT * 
FROM DIMENSAOTEMPO DT 
WHERE DT.DATA IN 
(
	SELECT FORMAT(TEMPO.DATA, 'yyyy-MM-01') AS PRIMEIRO_DIA, FATO.CHAVEVENDAS 
	FROM FATOVENDAS FATO
	INNER JOIN DIMENSAOTEMPO TEMPO ON (FATO.CHAVETEMPO = TEMPO.CHAVETEMPO)
)


-- ================================
-- = PREENCHE TABELA POR TRIMESTRE
-- ================================


WITH TRIMESTRE AS 
(
	
		
		SELECT 
			TEMPO.CHAVETEMPO,
			TEMPO.DATA,
			TEMPO.TRIMESTRE
		FROM 
			DIMENSAOTEMPO TEMPO
		INNER JOIN 
		(

			SELECT  
				MIN(DATA) AS PRIMEIRO_DIA_TRIMESTRE,
				TRIMESTRE
			FROM 
				FATOVENDAS FATO 
			INNER JOIN DIMENSAOTEMPO TEMPO ON (FATO.CHAVETEMPO = TEMPO.CHAVETEMPO)
			
			GROUP BY 
				TEMPO.TRIMESTRE
	
		) INFO_TRIMESTRE ON (PRIMEIRO_DIA_TRIMESTRE = TEMPO.DATA)
	

)

INSERT INTO FATOVENDASTRIMESTRE 

SELECT 
	CHAVEVENDEDOR,
	CHAVELOCALIDADE, 
	CHAVEFAIXA,  
	CHAVEPRODUTO,
	TRIMESTRE.CHAVETEMPO,
	SUM(QUANTIDADE)    AS QUANTIDADE, 
	SUM(VALORTOTAL)    AS VALORTOTAL, 
	SUM(VALORDESCONTO) AS VALORDESCONTO,
	SUM(VALORLIQUIDO)  AS VALORLIQUIDO

FROM FATOVENDAS FATO 

INNER JOIN DIMENSAOTEMPO TEMPO_FATO ON (FATO.CHAVETEMPO = TEMPO_FATO.CHAVETEMPO)
INNER JOIN TRIMESTRE ON (TRIMESTRE.TRIMESTRE = TEMPO_FATO.TRIMESTRE)
GROUP BY 
	CHAVEVENDEDOR,
	CHAVECLIENTE, 
	CHAVELOCALIDADE, 
	CHAVEFAIXA, 
	CHAVEPRODUTO,
	TRIMESTRE.CHAVETEMPO


	