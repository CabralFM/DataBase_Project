
-- 1	O utilizador que mais pesquisou no site		
SELECT nome, count(*) AS Visualizacoes
FROM visualizacao v, utilizador u
WHERE v.idutilizador = u.idutilizador
GROUP BY nome
ORDER BY Visualizacoes DESC
LIMIT 1;

-- 2 TOP 5 filmes mais procurados
SELECT f.titulo, COUNT(*) AS Visualizações
FROM visualizacao v, filme f
WHERE v.idfilme = f.idfilme
GROUP BY f.titulo
ORDER BY COUNT(*) DESC
LIMIT 5;

-- 3   Top 3 filmes (em rating)
SELECT filme.titulo AS `Top 3 Filmes`, ROUND(AVG(pontuacao)) AS `Rating`
FROM pontuacao, filme
WHERE pontuacao.idfilme = filme.idfilme
GROUP BY filme.titulo 
ORDER BY `Rating` DESC
LIMIT 3;

-- 4 Filme mais antigo disponivel		
SELECT titulo, ano 
FROM filme
GROUP BY titulo, ano 
HAVING ano <= ALL (
  SELECT ano 
  FROM filme
  GROUP BY ano
);

-- 5 Filme mais recente
SELECT titulo, ano 
FROM filme
GROUP BY titulo, ano 
HAVING ano >= ALL (
  SELECT ano 
  FROM filme
  GROUP BY ano
);

-- 6 Filmes com média de pontuação superior ou igual a 9
SELECT titulo, ROUND(AVG(pontuacao))
FROM pontuacao, filme
WHERE pontuacao.idfilme=filme.idfilme 
GROUP BY filme.titulo
HAVING ROUND(AVG(pontuacao)) >= 9

-- 7 Comentario mais longo		
SELECT comentario, LENGTH(comentario)
FROM `pontuacao` 
GROUP BY comentario
HAVING LENGTH(comentario) >= ALL (
	SELECT LENGTH(comentario)
	FROM `pontuacao` 
);

-- 8 Ator com mais participações nos filmes		
SELECT p.nome, count(*)
FROM pessoa p, ator a 
WHERE p.idpessoa = a.idpessoa
GROUP BY a.idpessoa, p.nome
HAVING 
	count(*) >= ALL (
    SELECT count(*)
    FROM pessoa p, ator a 
    WHERE p.idpessoa = a.idpessoa
    GROUP BY a.idpessoa
);

-- 9 Generos de filmes que não aparecem na lista de favoritos
SELECT g.nome 
FROM genero g
GROUP BY g.nome
HAVING g.nome NOT IN(
  SELECT DISTINCT g.nome 
  FROM 	genero g, 
        filme f, 
        filmegenero fg, 
	listafilmeconteudo lfc, 
	listafilme lf,
	listadesignacaopadronizada ldp,
	designacaopadonizada dp
  WHERE	f.idfilme = fg.idfilme AND
        fg.idgenero = g.idgenero AND
        f.idfilme = lfc.idFilme AND
        lfc.idListaFilme = ldp.idListaFilme AND
        ldp.idDesignacaoPadronizada = dp.idDesignacaoPadronizada AND
	dp.Designacao = "Favoritos"
);

-- 10 Genero de filmes favorito pelo publico
SELECT g.nome, COUNT(*)
FROM visualizacao v, filme f, filmegenero fg, genero g
WHERE v.idfilme = f.idfilme AND
	f.idfilme = fg.idfilme AND
    fg.idgenero = g.idgenero
GROUP BY g.nome
HAVING COUNT(*) >= ALL (
	SELECT COUNT(*)
	FROM visualizacao v, filme f, filmegenero fg, genero g
	WHERE v.idfilme = f.idfilme AND
		f.idfilme = fg.idfilme AND
    	fg.idgenero = g.idgenero
	GROUP BY g.nome
);   

-- 11 Idioma mais assistido
SELECT idioma.idioma, COUNT(*) AS `Quantidade Filmes`
FROM `idioma`, filme 
WHERE idioma.siglaidioma = filme.siglaidoma
GROUP BY idioma.idioma


--12 Utilizador com a maior lista de filmes padronizada 
SELECT Designacao, COUNT(listafilmeconteudo.idListaFilme), utilizador.nome
FROM listafilmeconteudo, listadesignacaopadronizada, designacaopadonizada, listafilme, utilizador
WHERE listafilmeconteudo.idListaFilme = listadesignacaopadronizada.idListaFilme 
AND designacaopadonizada.idDesignacaoPadronizada = listadesignacaopadronizada.idDesignacaoPadronizada 
AND listafilme.idlistafilme = listafilmeconteudo.idListaFilme 
AND listafilme.idutilizador = utilizador.idutilizador
GROUP BY Designacao, utilizador.nome, listafilme.idlistafilme
HAVING COUNT(*) >= ALL(SELECT COUNT(listafilmeconteudo.idListaFilme) 
FROM listafilmeconteudo, listadesignacaopadronizada, designacaopadonizada, listafilme
WHERE listafilmeconteudo.idListaFilme = listadesignacaopadronizada.idListaFilme 
AND designacaopadonizada.idDesignacaoPadronizada = listadesignacaopadronizada.idDesignacaoPadronizada 
AND listafilme.idlistafilme = listafilmeconteudo.idListaFilme
GROUP BY Designacao, idutilizador, listafilme.idlistafilme)
