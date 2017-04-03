-- 1
SELECT DISTINCT SURNAME, NAME, STARTDATE, ENDDATE, TYPE
FROM CONTRACTS
JOIN CLIENTS ON CONTRACTS.CLIENTID=CLIENTS.CLIENTID
JOIN PRODUCTS ON CONTRACTS.CONTRACT_TYPE=PRODUCTS.PRODUCT_NAME
WHERE (SYSDATE BETWEEN STARTDATE AND ENDDATE)
OR (ENDDATE IS NULL AND STARTDATE<=SYSDATE)
ORDER BY CLIENTS.SURNAME, CLIENTS.NAME;
-- 4423 rows

-- 2
SELECT * FROM (
SELECT DISTINCT ACTOR, COUNT(CASTS.TITLE)
FROM CASTS
INNER JOIN MOVIES ON CASTS.TITLE=MOVIES.MOVIE_TITLE
WHERE MOVIES.COUNTRY='USA'
GROUP BY ACTOR
ORDER BY COUNT(CASTS.TITLE) DESC
) WHERE ROWNUM<=5;
-- Robert De Niro	45
-- Morgan Freeman	36
-- Bruce Willis		35
-- Matt Damon		35
-- Steve Buscemi	33

-- 3 --------------- IN PROGRESS ---------------------------
SELECT LIC_SERIES.CLIENT, LIC_SERIES.TITLE, LIC_SERIES.SEASON
FROM LIC_SERIES
JOIN SEASONS ON LIC_SERIES.TITLE=SEASONS.TITLE AND LIC_SERIES.SEASON=SEASONS.SEASON
GROUP BY LIC_SERIES.CLIENT, LIC_SERIES.TITLE, LIC_SERIES.SEASON
HAVING COUNT(*) OVER (LIC_SERIES.CLIENT, LIC_SERIES.TITLE, LIC_SERIES.SEASON)=SEASONS.EPISODES;
-- ---------------- IN PROGRESS ------------------

SELECT LIC_SERIES.CLIENT, SEASONS.TITLE, SEASONS.SEASON
FROM SEASONS
JOIN LIC_SERIES ON SEASONS.TITLE=LIC_SERIES.TITLE AND SEASONS.SEASON=LIC_SERIES.SEASON AND SEASONS.EPISODES=COUNT(EPISODE)
GROUP BY LIC_SERIES.CLIENT, LIC_SERIES.TITLE, LIC_SERIES.SEASON;

CREATE OR REPLACE FUNCTION bill(
  date_bill IN DATE,
  client IN VARCHAR2(XXX),
  product IN VARCHAR2(XXX))
  RETURN NUMBER
  IS total NUMBER(6,2);
  BEGIN
    SELECT FEE
    INTO total
    FROM CONTRACTS
    JOIN CLIENTS ON CONTRACTS.CLIENTID=CLIENTS.CLIENTID
    JOIN PRODUCTS ON CONTRACT_TYPE=TYPE
    WHERE (client=CONTRACTS.CLIENTID)
    AND (date_bill BETWEEN STARTDATE AND ENDDATE)
    AND (product=CONTRACTS.CONTRACT_TYPE);
    RETURN(total);
  END;
