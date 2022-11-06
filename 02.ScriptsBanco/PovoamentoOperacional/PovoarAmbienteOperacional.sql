use REDE_SORVETERIA

CREATE SEQUENCE SQ_VENDA
START WITH 1
INCREMENT BY 1;

CREATE SEQUENCE SQ_ITEM
START WITH 1
INCREMENT BY 1;

GO
CREATE OR ALTER FUNCTION dbo.FN_ALEATORIO(@rand float, @maior_valor int, @menor_valor int =1)
RETURNS INT 
AS
BEGIN
    RETURN (SELECT FLOOR(@rand*(@maior_valor-@menor_valor+1))+@menor_valor);
END

GO
CREATE OR ALTER PROCEDURE SP_INSERT_ITEM_PRODUTO(@data datetime,
                                                  @categoria varchar(100))
AS
BEGIN
	set nocount on
    declare @cod_sabor int,
	        @cod_produto int,
	        @cod_venda int,
	        @cod_adicional int,
	        @cod_local int,
	        @cod_loja int,
	        @valor NUMERIC(10, 2),
			@total_itens int,
			@contador_itens int = 0,
			@volume int,
			@valor_total NUMERIC(10, 2),
			@id_venda int,
			@id_item int,

			@MAX_SABOR int,
			@MAX_PRODUTO int,
			@MAX_VENDA int,
			@MAX_ADICIONAL int,
			@MAX_VALOR int,
			@MAX_LOCAL int,
			@MAX_LOJA int,
			@MAX_VOLUME int

	SET @total_itens = (SELECT dbo.fn_aleatorio(rand(), 10,1))

	CREATE TABLE #tb_volume_max (categoria varchar(100), volume int)
	INSERT INTO #tb_volume_max values('PICOLÉ',5)
	INSERT INTO #tb_volume_max values ('BOLA DE SORVETE', 8)
	INSERT INTO #tb_volume_max values ('SUNDAE', 4)
	INSERT INTO #tb_volume_max values ('AÇAÍ P', 5)
	INSERT INTO #tb_volume_max values ('AÇAÍ M', 5)
	INSERT INTO #tb_volume_max values ('AÇAÍ G', 5)

	CREATE TABLE #tb_local (id int identity(1,1), cod_local int)
	INSERT INTO #tb_local SELECT l.id FROM tb_local l
	SET @MAX_LOCAL = (SELECT count(*) FROM #tb_local)

	SET @cod_local = (SELECT cod_local 
						FROM #tb_local
						WHERE id = (SELECT dbo.FN_ALEATORIO(rand(), @MAX_LOCAL,1))
						)

	CREATE TABLE #tb_loja (id int identity(1,1), cod_loja int)
	INSERT INTO #tb_loja SELECT l.id FROM tb_loja l WHERE l.ID_LOCAL = @cod_local
	SET @MAX_LOJA = (SELECT count(*) FROM #tb_loja)

	CREATE TABLE #tb_sabor (id int identity(1,1), cod_sabor int)
	INSERT INTO #tb_sabor SELECT s.id FROM tb_sabor s
	SET @MAX_SABOR = (SELECT count(*) FROM #tb_sabor)

	CREATE TABLE #tb_adicional (id int identity(1,1), cod_adicional int)
	INSERT INTO #tb_adicional SELECT a.id FROM TB_ADICIONAL a
	SET @MAX_ADICIONAL = (SELECT count(*) FROM #tb_adicional)

	SET @cod_loja = (SELECT cod_loja 
						FROM #tb_loja
						WHERE id = (SELECT dbo.FN_ALEATORIO(rand(), @MAX_LOJA,1))
						)

	SET @cod_produto = (SELECT ID FROM TB_PRODUTO WHERE PRODUTO = @categoria)
	SET @valor_total = 0
	SET @id_venda = NEXT VALUE FOR SQ_VENDA

	INSERT INTO TB_VENDA(ID, ID_LOJA, DATA_VENDA, VALOR)
	VALUES(@id_venda, @cod_loja, @data, 0)

	WHILE @contador_itens < @total_itens
	BEGIN
		IF @categoria IN ('PICOLÉ', 'BOLA DE SORVETE', 'SUNDAE')
		BEGIN
			SET @cod_sabor = (SELECT cod_sabor 
							 FROM #tb_sabor
							 WHERE id = (SELECT dbo.FN_ALEATORIO(rand(), @MAX_SABOR,1))
							 )
		END
		ELSE 
			SET @cod_sabor = NULL

		IF @categoria IN ('SUNDAE', 'AÇAÍ P', 'AÇAÍ M', 'AÇAÍ G')
		BEGIN
			SET @cod_adicional = (SELECT cod_adicional 
							 FROM #tb_adicional
							 WHERE id = (SELECT dbo.FN_ALEATORIO(rand(), @MAX_ADICIONAL,1))
							 )
		END
		ELSE 
			SET @cod_adicional = NULL

		set @MAX_VOLUME = (select volume from #tb_volume_max 
	                    where categoria = @categoria)

		 set @volume = (select dbo.fn_aleatorio(rand(), @MAX_VOLUME,1))

		 set @valor = @volume * (select valor from tb_produto 
	                         where ID = @cod_produto)
	
		SET @valor_total = @valor_total + @valor
		
		SET @id_item = NEXT VALUE FOR SQ_ITEM

		INSERT INTO TB_ITEM(ID, ID_PRODUTO, ID_SABOR, ID_VENDA, VALOR)
		VALUES(@id_item, @cod_produto, @cod_sabor, @id_venda, @valor)
		SET @contador_itens = @contador_itens + 1

		IF @categoria IN ('SUNDAE', 'AÇAÍ P', 'AÇAÍ M', 'AÇAÍ G')
		BEGIN
			INSERT INTO TB_ITEMADICIONAL(ID_ADICIONAL, ID_ITEM)
			VALUES(@cod_adicional, @id_item)
		END
	END

	UPDATE TB_VENDA
	SET VALOR = @valor_total
	WHERE ID = @id_venda
END

GO
CREATE OR ALTER PROCEDURE SP_POVOAR_VENDAS(@DATA_INICIAL DATETIME, @DATA_FINAL DATETIME)
AS
BEGIN
	set nocount on
    declare @max_vendas_picole int = 10, 
	        @min_vendas_picole int = 1,
			@max_vendas_bola_sorvete int = 10,
			@min_vendas_bola_sorvete int = 1,
			@max_vendas_sundae int = 10, 
	        @min_vendas_sundae int = 1,
			@max_vendas_acai_p int = 10, 
	        @min_vendas_acai_p int = 1,
			@max_vendas_acai_m int = 10, 
	        @min_vendas_acai_m int = 1,
			@max_vendas_acai_g int = 10, 
	        @min_vendas_acai_g int = 1,
			@total_vendas_dia_picole int,
			@total_vendas_dia_bola_sorvete int,
			@total_vendas_dia_sundae int,
			@total_vendas_dia_acai_p int,
			@total_vendas_dia_acai_m int,
			@total_vendas_dia_acai_g int,
			@contador_vendas int = 0,
			@semente float
			
    SELECT @semente = rand(10)
	WHILE (@DATA_INICIAL < @DATA_FINAL)
	BEGIN
		SET @total_vendas_dia_picole = 
	               (SELECT dbo.fn_aleatorio(rand(), @max_vendas_picole,@min_vendas_picole))
		SET @contador_vendas = 0
		PRINT 'total venda picolé:' + str(@total_vendas_dia_picole)
		WHILE (@contador_vendas < @total_vendas_dia_picole)
			BEGIN
				EXEC SP_INSERT_ITEM_PRODUTO @DATA_INICIAL, 'PICOLÉ'
				SET @contador_vendas = @contador_vendas + 1
			END

		SET @total_vendas_dia_bola_sorvete = 
	               (SELECT dbo.fn_aleatorio(rand(), @max_vendas_bola_sorvete,@min_vendas_bola_sorvete))
		SET @contador_vendas = 0
		PRINT 'total venda bola de sorvete:' + str(@total_vendas_dia_bola_sorvete)
		WHILE (@contador_vendas < @total_vendas_dia_bola_sorvete)
			BEGIN
				EXEC SP_INSERT_ITEM_PRODUTO @DATA_INICIAL, 'BOLA DE SORVETE'
				SET @contador_vendas = @contador_vendas + 1
			END

		SET @total_vendas_dia_sundae = 
	               (SELECT dbo.fn_aleatorio(rand(), @max_vendas_sundae,@min_vendas_sundae))
		SET @contador_vendas = 0
		PRINT 'total venda sundae:' + str(@total_vendas_dia_sundae)
		WHILE (@contador_vendas < @total_vendas_dia_sundae)
			BEGIN
				EXEC SP_INSERT_ITEM_PRODUTO @DATA_INICIAL, 'SUNDAE'
				SET @contador_vendas = @contador_vendas + 1
			END

		SET @total_vendas_dia_acai_p = 
	               (SELECT dbo.fn_aleatorio(rand(), @max_vendas_acai_p,@min_vendas_acai_p))
		SET @contador_vendas = 0
		PRINT 'total venda açaí P:' + str(@total_vendas_dia_acai_p)
		WHILE (@contador_vendas < @total_vendas_dia_acai_p)
			BEGIN
				EXEC SP_INSERT_ITEM_PRODUTO @DATA_INICIAL, 'AÇAÍ P'
				SET @contador_vendas = @contador_vendas + 1
			END

		SET @total_vendas_dia_acai_m = 
	               (SELECT dbo.fn_aleatorio(rand(), @max_vendas_acai_m,@min_vendas_acai_m))
		SET @contador_vendas = 0
		PRINT 'total venda açaí M:' + str(@total_vendas_dia_acai_m)
		WHILE (@contador_vendas < @total_vendas_dia_acai_m)
			BEGIN
				EXEC SP_INSERT_ITEM_PRODUTO @DATA_INICIAL, 'AÇAÍ M'
				SET @contador_vendas = @contador_vendas + 1
			END

		SET @total_vendas_dia_acai_g = 
	               (SELECT dbo.fn_aleatorio(rand(), @max_vendas_acai_g,@min_vendas_acai_g))
		SET @contador_vendas = 0
		PRINT 'total venda açaí G:' + str(@total_vendas_dia_acai_g)
		WHILE (@contador_vendas < @total_vendas_dia_acai_g)
			BEGIN
				EXEC SP_INSERT_ITEM_PRODUTO @DATA_INICIAL, 'AÇAÍ G'
				SET @contador_vendas = @contador_vendas + 1
			END

		SET @DATA_INICIAL = @DATA_INICIAL + 1
	END
END
SELECT * FROM TB_ADICIONAL A
JOIN TB_ITEMADICIONAL IA ON(A.ID = IA.ID_ADICIONAL)
SELECT V.VALOR, P.PRODUTO, A.ADICIONAL, S.SABOR, L.NOME, LO.CIDADE FROM TB_VENDA V
LEFT join TB_ITEM I ON (V.ID = I.ID_VENDA)
LEFT JOIN TB_ITEMADICIONAL IA ON (IA.ID_ITEM = I.ID)
LEFT JOIN TB_ADICIONAL A ON(IA.ID_ADICIONAL = A.ID)
LEFT JOIN TB_SABOR S ON (S.ID = I.ID_SABOR)
LEFT JOIN TB_LOJA L ON(L.ID = V.ID_LOJA)
LEFT JOIN TB_LOCAL LO ON(L.ID_LOCAL = LO.ID)
LEFT JOIN TB_PRODUTO P ON(P.ID = I.ID_PRODUTO)
EXEC SP_POVOAR_VENDAS '2020-01-01', '2020-10-01'