
-- ================
-- = PRIMEIRO ITEM
-- ================

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


-- ===============
-- = SEGUNDO ITEM
-- ===============

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

--INSERT INTO DIMENSAOLOCALIDADE (SGESTADO, NOESTADO, NOREGIAO) VALUES ('DF', 'Distrito Federal', 'Centro-Oeste')

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


-- ==============
-- = QUARTO ITEM
-- ==============


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


	