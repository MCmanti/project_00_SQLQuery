/*1. Nombre total d’appartements vendus au 1er semestre 2020.*/

SELECT 
count(V.idvente) AS "total appartements vendus"
FROM
vente as V
JOIN
bien as B on V.idbien = B.idbien
WHERE
B.typelocal = 'appartement';

/*2. Le nombre de ventes d’appartement par région pour le 1er semestre
2020.*/ 

SELECT
count(V.idvente) AS "total appartements vendus",
R.regnom
FROM
vente as V
JOIN
bien as B on V.idbien = B.idbien
JOIN
commune as C on B.idcoddepcodcom = C.idcoddepcodcom
JOIN
region as R on R.idregion = C.codreg
WHERE
B.typelocal = 'appartement' 
GROUP BY 
R.regnom
ORDER BY
count(V.idvente) DESC;

/*3. Proportion des ventes d’appartements par le nombre de pièces.*/

WITH ventes_appartements AS (
    SELECT idvente, pieces
    FROM bien as B
    Join vente as V on V.idbien = B.idbien
    WHERE typelocal = 'appartement'
)

SELECT 
    pieces,
    COUNT(idvente) AS nombre_de_ventes,
    COUNT(idvente) / (SELECT COUNT(*) FROM ventes_appartements) * 100 AS proportion
FROM 
    ventes_appartements
GROUP BY 
    pieces
ORDER BY 
    pieces;


/*4. Liste des 10 départements où le prix du mètre carré est le plus élevé.*/

SELECT
C.CODDEP as 'Département',
AVG(V.valeurfonciere/B.surfacetot) AS 'prix m2'
FROM
vente as V
JOIN
bien as B on V.idbien = B.idbien
JOIN
commune as C on B.idcoddepcodcom = C.idcoddepcodcom
JOIN
region as R on R.idregion = C.CODREG
GROUP BY 
C.CODDEP
ORDER BY
AVG(V.valeurfonciere/B.surfacetot) DESC
LIMIT
10;

/*5. Prix moyen du mètre carré d’une maison en Île-de-France.*/

SELECT
R.regnom,
AVG(V.valeurfonciere/B.surfacetot) AS 'prix m2'
FROM
vente as V
JOIN
bien as B on V.idbien = B.idbien
JOIN
commune as C on B.idcoddepcodcom = C.idcoddepcodcom
JOIN
region as R on R.idregion = C.CODREG
WHERE 
B.typelocal = 'maison' AND C.CODREG = 11;

/*6. Liste des 10 appartements les plus chers avec la région et le nombre
de mètres carrés.*/

SELECT
B.novoie,
B.typevoie,
B.voie,
B.cp,
R.regnom,
B.surfacetot,
V.valeurfonciere
FROM
vente as V
JOIN
bien as B on V.idbien = B.idbien
JOIN
commune as C on B.idcoddepcodcom = C.idcoddepcodcom
JOIN
region as R on R.idregion = C.CODREG
WHERE
B.typelocal = 'appartement'
ORDER BY
V.valeurfonciere DESC
LIMIT
10;

/*7. Taux d’évolution du nombre de ventes entre le premier et le second trimestre de 2020.*/

WITH ventes_1trimestre AS (
    SELECT 
        COUNT(V.idvente) AS nombre_ventesT1, 
        QUARTER(V.datemutation) AS trimestre
    FROM vente AS V
    JOIN bien AS B ON V.idbien = B.idbien
    WHERE QUARTER(V.datemutation) = 1
    GROUP BY QUARTER(V.datemutation)
),
ventes_2trimestre AS (
    SELECT 
        COUNT(V.idvente) AS nombre_ventesT2, 
        QUARTER(V.datemutation) AS trimestre
    FROM vente AS V
    JOIN bien AS B ON V.idbien = B.idbien
    WHERE QUARTER(V.datemutation) = 2
    GROUP BY QUARTER(V.datemutation)
)
SELECT 
(nombre_ventesT2-nombre_ventesT1)/nombre_ventesT2 * 100 AS 'tx_evolution'
FROM 
    ventes_1trimestre,ventes_2trimestre;

/*8. Le classement des régions par rapport au prix au mètre carré des
appartement de plus de 4 pièces.*/

SELECT
R.regnom,
AVG(V.valeurfonciere/B.surfacetot) AS "prix m2 des appartements › 4 pieces"
FROM
vente as V
JOIN
bien as B on V.idbien = B.idbien
JOIN
commune as C on B.idcoddepcodcom = C.idcoddepcodcom
JOIN
region as R on R.idregion = C.CODREG
WHERE
B.typelocal = 'appartement' AND B.pieces > 4
GROUP BY
R.regnom
ORDER BY
AVG(V.valeurfonciere/B.surfacetot)DESC;

/*9. Liste des communes ayant eu au moins 50 ventes au 1er trimestre*/

SELECT
    C.COM,
    COUNT(V.idvente) AS NombreVentes
FROM
    vente as V
JOIN
    bien as B on V.idbien = B.idbien
JOIN
    commune as C on B.idcoddepcodcom = C.idcoddepcodcom
JOIN
    region as R on R.idregion = C.CODREG
GROUP BY
    C.COM
HAVING
    COUNT(V.idvente) > 50
    
ORDER BY
	COUNT(V.idvente) DESC;


/*10. Différence en pourcentage du prix au mètre carré entre un
appartement de 2 pièces et un appartement de 3 pièces.*/

WITH prixM2_2pieces AS (
    SELECT 
        B.pieces,
        SUM(V.valeurfonciere) / SUM(B.surfacetot) AS 'prixm2_2pieces'
    FROM vente AS V
    JOIN bien AS B ON B.idbien = V.idbien
    WHERE B.typelocal = 'appartement' AND B.pieces = 2
    GROUP BY B.pieces
),
prixM2_3pieces AS (
    SELECT 
        B.pieces,
        SUM(V.valeurfonciere) / SUM(B.surfacetot) AS 'prixm2_3pieces'
    FROM vente AS V
    JOIN bien AS B ON B.idbien = V.idbien
    WHERE B.typelocal = 'appartement' AND B.pieces = 3
    GROUP BY B.pieces
)
SELECT 
    (prixm2_3pieces - prixm2_2pieces) / prixm2_2pieces * 100 AS difference_pourcentage
FROM prixM2_2pieces, prixM2_3pieces;

/*11. Les moyennes de valeurs foncières pour le top 3 des communes des
départements 6, 13, 33, 59 et 69.*/

WITH top_communes AS (
    SELECT 
        C.coddep,
        C.com,
        AVG(V.valeurfonciere) AS moyenne_valeurfonciere,
        ROW_NUMBER() OVER (PARTITION BY C.coddep ORDER BY AVG(V.valeurfonciere) DESC) AS row_num
    FROM 
        vente AS V 
    JOIN bien AS B ON V.idbien = B.idbien
    JOIN commune AS C ON C.idcoddepcodcom = B.idcoddepcodcom
    WHERE 
        C.coddep IN ('6', '13', '33', '59', '69')
    GROUP BY 
        C.coddep, C.com
)
SELECT 
    coddep,
    com,
    moyenne_valeurfonciere
FROM 
    top_communes
WHERE 
    row_num <= 3;


/*12. Les 20 communes avec le plus de transactions pour 1000 habitants
pour les communes qui dépassent les 10 000 habitants.*/

SELECT 
    C.COM AS Commune,
    B.cp,
    C.PTOT,
    COUNT(V.idvente) / (C.PTOT / 1000) AS TransactionsPar1000Habitants
FROM 
    vente AS V
JOIN 
    bien AS B ON V.idbien = B.idbien
JOIN 
    commune AS C ON B.idcoddepcodcom = C.idcoddepcodcom
WHERE 
    C.PTOT > 10000
GROUP BY 
    C.COM,C.PTOT,B.cp
ORDER BY 
    TransactionsPar1000Habitants DESC
LIMIT 20;


