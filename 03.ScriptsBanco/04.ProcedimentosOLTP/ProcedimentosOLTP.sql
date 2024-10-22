-- ETL OLTP TO STAGING AREA
-- PRODUTO
GO
CREATE OR ALTER PROCEDURE SP_ETL_OLTP_TO_STAGING_PRODUTO(@DATA_CARGA DATETIME)
AS
BEGIN
	DELETE AUX_PRODUTO 
	WHERE DATA_CARGA = @DATA_CARGA

	INSERT INTO AUX_PRODUTO(DATA_CARGA, ID, PRODUTO, VALOR)
	SELECT @DATA_CARGA, P.ID, P.PRODUTO, P.VALOR FROM TB_PRODUTO P
END

-- SABOR
GO
CREATE OR ALTER PROCEDURE SP_ETL_OLTP_TO_STAGING_SABOR(@DATA_CARGA DATETIME)
AS
BEGIN
	DELETE AUX_SABOR 
	WHERE DATA_CARGA = @DATA_CARGA

	INSERT INTO AUX_SABOR(DATA_CARGA, ID, SABOR)
	SELECT @DATA_CARGA, S.ID, S.SABOR FROM TB_SABOR S
END

-- ESTABELECIMENTO
GO
CREATE OR ALTER PROCEDURE SP_ETL_OLTP_TO_STAGING_ESTABELECIMENTO(@DATA_CARGA DATETIME)
AS
BEGIN
	DELETE AUX_ESTABELECIMENTO
	WHERE DATA_CARGA = @DATA_CARGA

	INSERT INTO AUX_ESTABELECIMENTO(DATA_CARGA, ID, ID_LOCAL, NOME, CNPJ)
	SELECT @DATA_CARGA, E.ID,E.ID_LOCAL, E.NOME, E.CNPJ FROM TB_ESTABELECIMENTO E
END

-- LOCAL
GO
CREATE OR ALTER PROCEDURE SP_ETL_OLTP_TO_STAGING_LOCAL(@DATA_CARGA DATETIME)
AS
BEGIN
	DELETE AUX_LOCAL
	WHERE DATA_CARGA = @DATA_CARGA

	INSERT INTO AUX_LOCAL(DATA_CARGA, ID, ESTADO, CIDADE, BAIRRO, RUA, NUMERO)
	SELECT @DATA_CARGA, L.ID, L.ESTADO, L.CIDADE, L.BAIRRO, L.RUA, L.NUMERO FROM TB_LOCAL L
END

-- ADICIONAL
GO
CREATE OR ALTER PROCEDURE SP_ETL_OLTP_TO_STAGING_ADICIONAL(@DATA_CARGA DATETIME)
AS
BEGIN
	DELETE AUX_ADICIONAL
	WHERE DATA_CARGA = @DATA_CARGA

	INSERT INTO AUX_ADICIONAL(DATA_CARGA, ID, ADICIONAL, VALOR)
	SELECT @DATA_CARGA, A.ID, A.ADICIONAL, A.VALOR FROM TB_ADICIONAL A
END

-- FATO VENDA
GO
CREATE OR ALTER PROCEDURE SP_ETL_OLTP_TO_STAGING_FATO_VENDA(@DATA_CARGA DATETIME, @DATA_INICIAL DATETIME, @DATA_FINAL DATETIME)
AS
BEGIN
	DECLARE @DATA_VENDA DATETIME, @ID_VENDA INT, @ID_ITEM INT, @ID_SABOR INT, @ID_ESTABELECIMENTO INT, 
			@ID_LOCAL INT, @ID_PRODUTO INT, @VALOR DECIMAL(10, 2)

	DELETE AUX_FATO_VENDA
	WHERE DATA_CARGA = @DATA_CARGA AND DATA_VENDA BETWEEN @DATA_INICIAL AND @DATA_FINAL

	DECLARE C_VENDA CURSOR FOR 
	SELECT V.DATA_VENDA, V.ID, I.ID, S.ID, E.ID, L.ID, P.ID, I.VALOR FROM TB_VENDA V
		LEFT JOIN TB_ITEM I ON(I.ID_VENDA = V.ID)
		LEFT JOIN TB_SABOR S ON(I.ID_SABOR = S.ID)
		LEFT JOIN TB_PRODUTO P ON(P.ID = I.ID_PRODUTO)
		LEFT JOIN TB_ESTABELECIMENTO E ON(V.ID_ESTABELECIMENTO = E.ID)
		LEFT JOIN TB_LOCAL L ON(E.ID_LOCAL = L.ID)
	WHERE DATA_VENDA BETWEEN @DATA_INICIAL AND @DATA_FINAL

	OPEN C_VENDA
	FETCH C_VENDA INTO @DATA_VENDA, @ID_VENDA, @ID_ITEM, @ID_SABOR, @ID_ESTABELECIMENTO, @ID_LOCAL, @ID_PRODUTO, @VALOR
	WHILE(@@FETCH_STATUS = 0)
	BEGIN
		-- CASO UM A�A� TENHA UM SABOR
		IF (SELECT P.PRODUTO FROM TB_PRODUTO P
					WHERE P.ID = @ID_PRODUTO) IN('A�A� P', 'A�A� M', 'A�A� G') AND @ID_SABOR IS NOT NULL
		BEGIN
			INSERT INTO VIO_FATO_VENDA(DATA_CARGA, DATA_VENDA, ID_VENDA, ID_ITEM, ID_SABOR, ID_ESTABELECIMENTO, ID_LOCAL, ID_PRODUTO, VALOR, DATA_ERRO, VIOLACAO)
			VALUES(@DATA_CARGA, @DATA_VENDA, @ID_VENDA, @ID_ITEM, @ID_SABOR, @ID_ESTABELECIMENTO, @ID_LOCAL, @ID_PRODUTO, @VALOR, GETDATE(), 'ESTE PRODUTO NAO DEVERIA POSSUIR UM SABOR')
				
			FETCH C_VENDA INTO @DATA_VENDA, @ID_VENDA, @ID_ITEM, @ID_SABOR, @ID_ESTABELECIMENTO, @ID_LOCAL, @ID_PRODUTO, @VALOR
			CONTINUE 
		END
		-- CASO UM SORVETE, SUNDAE OU PICOL� N�O TENHA UM SABOR
		IF (SELECT P.PRODUTO FROM TB_PRODUTO P
					WHERE P.ID = @ID_PRODUTO) IN('PICOL�', 'BOLA DE SORVETE', 'SUNDAE') AND @ID_SABOR IS NULL
		BEGIN
			INSERT INTO VIO_FATO_VENDA(DATA_CARGA, DATA_VENDA, ID_VENDA, ID_ITEM, ID_SABOR, ID_ESTABELECIMENTO, ID_LOCAL, ID_PRODUTO, VALOR, DATA_ERRO, VIOLACAO)
			VALUES(@DATA_CARGA, @DATA_VENDA, @ID_VENDA, @ID_ITEM, @ID_SABOR, @ID_ESTABELECIMENTO, @ID_LOCAL, @ID_PRODUTO, @VALOR, GETDATE(), 'ESTE PRODUTO DEVERIA POSSUIR UM SABOR')

			FETCH C_VENDA INTO @DATA_VENDA, @ID_VENDA, @ID_ITEM, @ID_SABOR, @ID_ESTABELECIMENTO, @ID_LOCAL, @ID_PRODUTO, @VALOR
			CONTINUE 
		END
		-- CASO UM SORVETE OU PICOL� TENHA UM ADICIONAL
		IF EXISTS (SELECT IA.ID_ITEM FROM TB_ITEM_ADICIONAL IA WHERE IA.ID_ITEM = @ID_ITEM) AND
			(SELECT P.PRODUTO FROM TB_PRODUTO P WHERE P.ID = @ID_PRODUTO) IN ('BOLA DE SORVETE', 'PICOL�')
		BEGIN
			INSERT INTO VIO_FATO_VENDA(DATA_CARGA, DATA_VENDA, ID_VENDA, ID_ITEM, ID_SABOR, ID_ESTABELECIMENTO, ID_LOCAL, ID_PRODUTO, VALOR, DATA_ERRO, VIOLACAO)
			VALUES(@DATA_CARGA, @DATA_VENDA, @ID_VENDA, @ID_ITEM, @ID_SABOR, @ID_ESTABELECIMENTO, @ID_LOCAL, @ID_PRODUTO, @VALOR, GETDATE(), 'ESTE PRODUTO N�O DEVERIA POSSUIR UM ADICIONAL')

			FETCH C_VENDA INTO @DATA_VENDA, @ID_VENDA, @ID_ITEM, @ID_SABOR, @ID_ESTABELECIMENTO, @ID_LOCAL, @ID_PRODUTO, @VALOR
			CONTINUE 
		END
		INSERT INTO AUX_FATO_VENDA(DATA_CARGA, DATA_VENDA, ID_VENDA, ID_ITEM, ID_SABOR, ID_ESTABELECIMENTO, ID_LOCAL, ID_PRODUTO, VALOR)
		VALUES(@DATA_CARGA, @DATA_VENDA, @ID_VENDA, @ID_ITEM, @ID_SABOR, @ID_ESTABELECIMENTO, @ID_LOCAL, @ID_PRODUTO, @VALOR)

		FETCH C_VENDA INTO @DATA_VENDA, @ID_VENDA, @ID_ITEM, @ID_SABOR, @ID_ESTABELECIMENTO, @ID_LOCAL, @ID_PRODUTO, @VALOR
	END

	CLOSE C_VENDA
	DEALLOCATE C_VENDA
END

-- ITEM ADICIONAL
GO
CREATE OR ALTER PROCEDURE SP_ETL_OLTP_TO_STAGING_AUX_ITEM_ADICIONAL(@DATA_CARGA DATETIME)
AS
BEGIN
	DELETE AUX_ITEM_ADICIONAL
	WHERE DATA_CARGA = @DATA_CARGA

	INSERT INTO AUX_ITEM_ADICIONAL(DATA_CARGA, ID_ADICIONAL, ID_ITEM)
	SELECT @DATA_CARGA, IA.ID_ADICIONAL, IA.ID_ITEM FROM TB_ITEM_ADICIONAL IA
	
END


-- DQL
GO
CREATE OR ALTER PROCEDURE ETL_TODOS_PROCEDURE(@DATA_CARGA DATETIME, @DATA_INICIAL DATETIME, @DATA_FINAL DATETIME)
AS
BEGIN
	EXEC SP_ETL_OLTP_TO_STAGING_ADICIONAL @DATA_CARGA
	EXEC SP_ETL_OLTP_TO_STAGING_PRODUTO @DATA_CARGA
	EXEC SP_ETL_OLTP_TO_STAGING_LOCAL @DATA_CARGA
	EXEC SP_ETL_OLTP_TO_STAGING_ESTABELECIMENTO @DATA_CARGA
	EXEC SP_ETL_OLTP_TO_STAGING_SABOR @DATA_CARGA
	EXEC SP_ETL_OLTP_TO_STAGING_AUX_ITEM_ADICIONAL @DATA_CARGA
	EXEC SP_ETL_OLTP_TO_STAGING_FATO_VENDA @DATA_CARGA, @DATA_INICIAL, @DATA_FINAL
END

SELECT * FROM DIM_TEMPO

EXEC ETL_TODOS_PROCEDURE '2001-09-11', '2022-01-01', '2022-01-03'

SELECT * FROM AUX_FATO_VENDA 
SELECT * FROM VIO_FATO_VENDA

UPDATE AUX_PRODUTO
SET PRODUTO = 'PICOL'
WHERE ID_PRODUTO = 1

