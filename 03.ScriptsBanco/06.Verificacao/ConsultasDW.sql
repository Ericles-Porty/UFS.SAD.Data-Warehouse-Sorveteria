use REDE_SORVETERIA

-- Qual o n�mero de vendas hoje? 
SELECT SUM(FV.QUANTIDADE) AS QUANTIDADE FROM FATO_VENDA FV
	JOIN DIM_TEMPO T ON(FV.ID_DATA_DA_VENDA = T.ID)
WHERE T.DATA = '20200101'

-- Qual o n�mero de vendas nos �ltimos 2 meses? 
SELECT SUM(FV.QUANTIDADE) AS QUANTIDADE FROM FATO_VENDA FV
	JOIN DIM_TEMPO T ON(FV.ID_DATA_DA_VENDA = T.ID)
WHERE T.DATA >= DATEADD(MONTH, -2, '20200101')

-- Qual o n�mero de vendas por m�s? 
SELECT T.MES, T.ANO, SUM(FV.QUANTIDADE) AS QUANTIDADE FROM FATO_VENDA FV
	JOIN DIM_TEMPO T ON(FV.ID_DATA_DA_VENDA = T.ID)
GROUP BY T.MES, T.ANO

-- Qual o n�mero de vendas por estabelecimento?
SELECT E.NOME, SUM(FV.QUANTIDADE) AS QUANTIDADE FROM FATO_VENDA FV
	JOIN DIM_ESTABELECIMENTO E ON(FV.ID_ESTABELECIMENTO = E.ID)
GROUP BY E.NOME

-- Qual o n�mero de vendas por m�s? Por estabelecimento?
SELECT T.MES, T.ANO, E.NOME, SUM(FV.QUANTIDADE) AS QUANTIDADE FROM FATO_VENDA FV
	JOIN DIM_TEMPO T ON(FV.ID_DATA_DA_VENDA = T.ID)
	JOIN DIM_ESTABELECIMENTO E ON(FV.ID_ESTABELECIMENTO = E.ID)
GROUP BY T.MES, T.ANO, E.NOME

-- Qual o rendimento por m�s? Por estabelecimento?
SELECT T.MES, T.ANO, E.NOME, SUM(FV.VALOR) AS VALOR FROM FATO_VENDA FV
	JOIN DIM_TEMPO T ON(FV.ID_DATA_DA_VENDA = T.ID)
	JOIN DIM_ESTABELECIMENTO E ON(FV.ID_ESTABELECIMENTO = E.ID)
GROUP BY T.MES, T.ANO, E.NOME

-- Qual o rendimento por produto? Por m�s? Por estabelecimento?
SELECT T.MES, T.ANO, E.NOME, P.PRODUTO, SUM(FV.VALOR) AS VALOR FROM FATO_VENDA FV
	JOIN DIM_TEMPO T ON(FV.ID_DATA_DA_VENDA = T.ID)
	JOIN DIM_ESTABELECIMENTO E ON(FV.ID_ESTABELECIMENTO = E.ID)
	JOIN DIM_PRODUTO P ON(FV.ID_PRODUTO = P.ID)
GROUP BY T.MES, T.ANO, E.NOME, P.PRODUTO

-- Qual o rendimento por produto?
SELECT P.PRODUTO, SUM(FV.VALOR) AS VALOR FROM FATO_VENDA FV
	JOIN DIM_PRODUTO P ON(FV.ID_PRODUTO = P.ID)
GROUP BY P.PRODUTO
ORDER BY SUM(FV.VALOR) DESC

-- Qual o rendimento por m�s? 
SELECT T.MES, T.ANO, SUM(FV.VALOR) AS VALOR FROM FATO_VENDA FV
	JOIN DIM_TEMPO T ON(FV.ID_DATA_DA_VENDA = T.ID)
GROUP BY T.MES, T.ANO

-- Qual o rendimento por estabelecimento? 
SELECT E.NOME, SUM(FV.VALOR) AS VALOR FROM FATO_VENDA FV
	JOIN DIM_ESTABELECIMENTO E ON(FV.ID_ESTABELECIMENTO = E.ID)
GROUP BY E.NOME
ORDER BY SUM(FV.VALOR) DESC

-- Qual o n�mero de sorvetes vendidos por sabor? 
SELECT S.SABOR, SUM(FV.QUANTIDADE) AS QUANTIDADE FROM FATO_VENDA FV
	JOIN DIM_PRODUTO P ON(FV.ID_PRODUTO = P.ID)
	JOIN DIM_SABOR S ON(S.ID = FV.ID_SABOR)
WHERE P.PRODUTO = 'BOLA DE SORVETE'
GROUP BY S.SABOR

-- Qual o n�mero de sorvetes vendidos por m�s? 
SELECT T.MES, T.ANO, SUM(FV.QUANTIDADE) AS QUANTIDADE FROM FATO_VENDA FV
	JOIN DIM_TEMPO T ON(FV.ID_DATA_DA_VENDA = T.ID)
	JOIN DIM_PRODUTO P ON(FV.ID_PRODUTO = P.ID)
WHERE P.PRODUTO = 'BOLA DE SORVETE'
GROUP BY T.MES, T.ANO

-- Qual o n�mero de sorvetes vendidos por estabelecimento? 
SELECT E.NOME, SUM(FV.QUANTIDADE) AS QUANTIDADE FROM FATO_VENDA FV
	JOIN DIM_ESTABELECIMENTO E ON(FV.ID_ESTABELECIMENTO = E.ID)
	JOIN DIM_PRODUTO P ON(FV.ID_PRODUTO = P.ID)
WHERE P.PRODUTO = 'BOLA DE SORVETE'
GROUP BY E.NOME
ORDER BY SUM(FV.QUANTIDADE) DESC


-- Qual o n�mero de sorvetes vendidos por sabor? Por m�s? 
SELECT T.MES, T.ANO, S.SABOR, SUM(FV.QUANTIDADE) AS QUANTIDADE FROM FATO_VENDA FV
	JOIN DIM_TEMPO T ON(FV.ID_DATA_DA_VENDA = T.ID)
	JOIN DIM_SABOR S ON(S.ID = FV.ID_SABOR)
	JOIN DIM_PRODUTO P ON(FV.ID_PRODUTO = P.ID)
WHERE P.PRODUTO = 'BOLA DE SORVETE'
GROUP BY T.MES, T.ANO, S.SABOR
ORDER BY T.MES, T.ANO

-- Qual o n�mero de sorvetes vendidos por sabor? Por m�s? Por estabelecimento?
SELECT  S.SABOR, T.MES, T.ANO, E.NOME, SUM(FV.QUANTIDADE) AS QUANTIDADE FROM FATO_VENDA FV
	JOIN DIM_TEMPO T ON(FV.ID_DATA_DA_VENDA = T.ID)
	JOIN DIM_ESTABELECIMENTO E ON(FV.ID_ESTABELECIMENTO = E.ID)
	JOIN DIM_SABOR S ON(S.ID = FV.ID_SABOR)
	JOIN DIM_PRODUTO P ON(FV.ID_PRODUTO = P.ID)
WHERE P.PRODUTO = 'BOLA DE SORVETE'
GROUP BY S.SABOR, T.MES, T.ANO, E.NOME

-- Qual o n�mero de picol�s vendidos por sabor? Por m�s?
SELECT T.MES, T.ANO, S.SABOR, SUM(FV.QUANTIDADE) AS QUANTIDADE FROM FATO_VENDA FV
	JOIN DIM_TEMPO T
	ON (T.ID = FV.ID_DATA_DA_VENDA)
	JOIN DIM_PRODUTO P
	ON (P.ID = FV.ID_PRODUTO)
	JOIN DIM_SABOR S
	ON (FV.ID_SABOR = S.ID)
WHERE P.PRODUTO = 'PICOL�'
GROUP BY T.MES, T.ANO, S.SABOR
ORDER BY T.ANO, T.MES

-- Qual o n�mero de picol�s vendidos por sabor? Por m�s? Por estabelecimento?
SELECT T.MES, T.ANO, S.SABOR, E.NOME, SUM(FV.QUANTIDADE) AS QUANTIDADE FROM FATO_VENDA FV
	JOIN DIM_TEMPO T
	ON (T.ID = FV.ID_DATA_DA_VENDA)
	JOIN DIM_PRODUTO P
	ON (P.ID = FV.ID_PRODUTO)
	JOIN DIM_SABOR S
	ON (FV.ID_SABOR = S.ID)
	JOIN DIM_ESTABELECIMENTO E
	ON (E.ID = FV.ID_ESTABELECIMENTO)
WHERE P.PRODUTO = 'PICOL�'
GROUP BY T.MES, T.ANO, S.SABOR, E.NOME
ORDER BY T.ANO, T.MES

-- Qual o n�mero de a�a� vendidos por tamanho? Por m�s?
SELECT T.MES, T.ANO, P.PRODUTO, SUM(FV.QUANTIDADE) AS QUANTIDADE FROM FATO_VENDA FV
	JOIN DIM_TEMPO T
	ON (T.ID = FV.ID_DATA_DA_VENDA)
	JOIN DIM_PRODUTO P
	ON (P.ID = FV.ID_PRODUTO)
WHERE P.PRODUTO IN ('A�A� G', 'A�A� M', 'A�A� P')
GROUP BY T.MES, T.ANO, P.PRODUTO
ORDER BY T.ANO, T.MES

-- Qual o n�mero de a�a� vendidos por tamanho? Por m�s? Por estabelecimento?
SELECT T.MES, T.ANO, P.PRODUTO, E.NOME, SUM(FV.QUANTIDADE) AS QUANTIDADE FROM FATO_VENDA FV
	JOIN DIM_TEMPO T
	ON (T.ID = FV.ID_DATA_DA_VENDA)
	JOIN DIM_PRODUTO P
	ON (P.ID = FV.ID_PRODUTO)
	JOIN DIM_ESTABELECIMENTO E
	ON (E.ID = FV.ID_ESTABELECIMENTO)
WHERE P.PRODUTO IN ('A�A� G', 'A�A� M', 'A�A� P')
GROUP BY T.MES, T.ANO, P.PRODUTO, E.NOME
ORDER BY T.ANO, T.MES

-- Qual o n�mero de sundae vendidos por sabor? Por m�s?
SELECT T.MES, T.ANO, S.SABOR, SUM(FV.QUANTIDADE) AS QUANTIDADE FROM FATO_VENDA FV
	JOIN DIM_TEMPO T
	ON (T.ID = FV.ID_DATA_DA_VENDA)
	JOIN DIM_PRODUTO P
	ON (P.ID = FV.ID_PRODUTO)
	JOIN DIM_SABOR S
	ON (FV.ID_SABOR = S.ID)
WHERE P.PRODUTO = 'SUNDAE'
GROUP BY T.MES, T.ANO, S.SABOR
ORDER BY T.ANO, T.MES

-- Qual o n�mero de sundae vendidos por sabor? Por m�s? Por estabelecimento?
SELECT T.MES, T.ANO, S.SABOR, E.NOME, SUM(FV.QUANTIDADE) AS QUANTIDADE FROM FATO_VENDA FV
	JOIN DIM_TEMPO T
	ON (T.ID = FV.ID_DATA_DA_VENDA)
	JOIN DIM_PRODUTO P
	ON (P.ID = FV.ID_PRODUTO)
	JOIN DIM_SABOR S
	ON (FV.ID_SABOR = S.ID)
	JOIN DIM_ESTABELECIMENTO E
	ON (E.ID = FV.ID_ESTABELECIMENTO)
WHERE P.PRODUTO = 'SUNDAE'
GROUP BY T.MES, T.ANO, S.SABOR, E.NOME
ORDER BY T.ANO, T.MES

-- Qual o n�mero de adicionais vendidos por m�s? Por estabelecimento?
SELECT T.MES, T.ANO, A.ADICIONAL, E.NOME, SUM(QUANTIDADE) AS QUANTIDADE FROM FATO_VENDA FV
	JOIN DIM_TEMPO T
	ON (T.ID = FV.ID_DATA_DA_VENDA)
	JOIN DIM_GRUPO_ADICIONAL GA
	ON (GA.ID = FV.ID_GRUPO_ADICIONAIS)
	JOIN BRIDGE_ADICIONAL BA
	ON (BA.ID_GRUPO = GA.ID)
	JOIN DIM_ADICIONAL A
	ON (A.ID = BA.ID_ADICIONAL)
	JOIN DIM_ESTABELECIMENTO E
	ON (E.ID = FV.ID_ESTABELECIMENTO)
GROUP BY T.MES, T.ANO, A.ADICIONAL, E.NOME
ORDER BY T.ANO, T.MES

-- Qual o n�mero de adicionais vendidos por a�a�? Por m�s? Por estabelecimento?
SELECT T.MES, T.ANO, A.ADICIONAL, P.PRODUTO, E.NOME, SUM(QUANTIDADE) AS QUANTIDADE FROM FATO_VENDA FV
	JOIN DIM_TEMPO T
	ON (T.ID = FV.ID_DATA_DA_VENDA)
	JOIN DIM_PRODUTO P
	ON (P.ID = FV.ID_PRODUTO)
	JOIN DIM_GRUPO_ADICIONAL GA
	ON (GA.ID = FV.ID_GRUPO_ADICIONAIS)
	JOIN BRIDGE_ADICIONAL BA
	ON (BA.ID_GRUPO = GA.ID)
	JOIN DIM_ADICIONAL A
	ON (A.ID = BA.ID_ADICIONAL)
	JOIN DIM_ESTABELECIMENTO E
	ON (E.ID = FV.ID_ESTABELECIMENTO)
WHERE P.PRODUTO IN ('A�A� G', 'A�A� M', 'A�A� P')
GROUP BY T.MES, T.ANO, A.ADICIONAL, P.PRODUTO, E.NOME
ORDER BY T.ANO, T.MES

-- Qual o n�mero de adicionais vendidos por sundae? Por m�s? Por estabelecimento?
SELECT T.MES, T.ANO, A.ADICIONAL, P.PRODUTO, E.NOME, SUM(QUANTIDADE) AS QUANTIDADE FROM FATO_VENDA FV
	JOIN DIM_TEMPO T
	ON (T.ID = FV.ID_DATA_DA_VENDA)
	JOIN DIM_PRODUTO P
	ON (P.ID = FV.ID_PRODUTO)
	JOIN DIM_GRUPO_ADICIONAL GA
	ON (GA.ID = FV.ID_GRUPO_ADICIONAIS)
	JOIN BRIDGE_ADICIONAL BA
	ON (BA.ID_GRUPO = GA.ID)
	JOIN DIM_ADICIONAL A
	ON (A.ID = BA.ID_ADICIONAL)
	JOIN DIM_ESTABELECIMENTO E
	ON (E.ID = FV.ID_ESTABELECIMENTO)
WHERE P.PRODUTO = 'SUNDAE'
GROUP BY T.MES, T.ANO, A.ADICIONAL, P.PRODUTO, E.NOME
ORDER BY T.ANO, T.MES

-- Qual o n�mero de vendas? Por produto? Por m�s? Por cidade?
SELECT T.MES, T.ANO, P.PRODUTO, L.CIDADE, SUM(FVLM.QUANTIDADE) AS QUANTIDADE FROM FATO_VENDA_LOCAL_MES FVLM
	JOIN DIM_TEMPO T
	ON (T.ID = FVLM.ID_MES)
	JOIN DIM_PRODUTO P
	ON (P.ID = FVLM.ID_PRODUTO)
	JOIN DIM_LOCAL L
	ON (L.ID = FVLM.ID_LOCAL)
GROUP BY T.MES, T.ANO, P.PRODUTO, L.CIDADE
ORDER BY T.ANO, T.MES, L.CIDADE

-- Qual o n�mero de vendas? Por produto? Por m�s? Por estado?
SELECT T.MES, T.ANO, P.PRODUTO, L.ESTADO, SUM(FVLM.QUANTIDADE) AS QUANTIDADE FROM FATO_VENDA_LOCAL_MES FVLM
	JOIN DIM_TEMPO T
	ON (T.ID = FVLM.ID_MES)
	JOIN DIM_PRODUTO P
	ON (P.ID = FVLM.ID_PRODUTO)
	JOIN DIM_LOCAL L
	ON (L.ID = FVLM.ID_LOCAL)
GROUP BY T.MES, T.ANO, P.PRODUTO, L.ESTADO
ORDER BY T.ANO, T.MES, L.ESTADO

-- Qual o rendimento? Por produto? Por m�s? Por estado?
SELECT T.MES, T.ANO, P.PRODUTO, L.ESTADO, SUM(FVLM.VALOR) AS QUANTIDADE FROM FATO_VENDA_LOCAL_MES FVLM
	JOIN DIM_TEMPO T
	ON (T.ID = FVLM.ID_MES)
	JOIN DIM_PRODUTO P
	ON (P.ID = FVLM.ID_PRODUTO)
	JOIN DIM_LOCAL L
	ON (L.ID = FVLM.ID_LOCAL)
GROUP BY T.MES, T.ANO, P.PRODUTO, L.ESTADO
ORDER BY T.ANO, T.MES, L.ESTADO

-- Qual o rendimento? Por produto? Por m�s? Por cidade?
SELECT T.MES, T.ANO, P.PRODUTO, L.ESTADO, SUM(FVLM.VALOR) AS QUANTIDADE FROM FATO_VENDA_LOCAL_MES FVLM
	JOIN DIM_TEMPO T
	ON (T.ID = FVLM.ID_MES)
	JOIN DIM_PRODUTO P
	ON (P.ID = FVLM.ID_PRODUTO)
	JOIN DIM_LOCAL L
	ON (L.ID = FVLM.ID_LOCAL)
GROUP BY T.MES, T.ANO, P.PRODUTO, L.ESTADO
ORDER BY T.ANO, T.MES, L.ESTADO