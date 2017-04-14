-- 1
SELECT SURNAME, NAME, STARTDATE, ENDDATE, TYPE
FROM CONTRACTS
NATURAL JOIN CLIENTS
JOIN PRODUCTS ON CONTRACT_TYPE=PRODUCT_NAME
WHERE (SYSDATE BETWEEN STARTDATE AND ENDDATE)
OR (ENDDATE IS NULL AND STARTDATE<=SYSDATE)
ORDER BY SURNAME, NAME;
-- 4423 rows

-- 2
SELECT * FROM (
SELECT ACTOR, COUNT(TITLE)
FROM CASTS
JOIN MOVIES ON CASTS.TITLE=MOVIES.MOVIE_TITLE
WHERE COUNTRY='USA'
GROUP BY ACTOR
ORDER BY COUNT(TITLE) DESC
) WHERE ROWNUM<=5;
-- Robert De Niro	45
-- Morgan Freeman	36
-- Bruce Willis		35
-- Matt Damon		35
-- Steve Buscemi	33

-- 3
SELECT CLIENT, TITLE, SEASON
FROM LIC_SERIES
NATURAL JOIN SEASONS
GROUP BY CLIENT, TITLE, SEASON, EPISODES
HAVING COUNT(EPISODE)=EPISODES;
-- 2104 rows

-- 4
SELECT A.month, ACTOR, A.top
FROM (
		SELECT MAX(counter) as top, month
		FROM (
			SELECT TO_CHAR(VIEW_DATETIME, 'MON-YYYY') AS month, ACTOR, COUNT(TAPS_MOVIES.TITLE) AS counter
			FROM TAPS_MOVIES
			JOIN CASTS ON TAPS_MOVIES.TITLE=CASTS.TITLE
			GROUP BY TO_CHAR(VIEW_DATETIME, 'MON-YYYY'), ACTOR
		)
			GROUP BY month
			ORDER BY TO_DATE(month, 'MON-YYYY')
) A
JOIN
(
	SELECT TO_CHAR(VIEW_DATETIME, 'MON-YYYY') AS month, ACTOR, COUNT(TAPS_MOVIES.TITLE) AS counter
	FROM TAPS_MOVIES
	JOIN CASTS ON TAPS_MOVIES.TITLE=CASTS.TITLE
	GROUP BY TO_CHAR(VIEW_DATETIME, 'MON-YYYY'), ACTOR
) B
ON A.top=B.counter AND A.month=B.month
ORDER BY TO_DATE(month, 'MON-YYYY');
--MONTH    ACTOR                                                     TOP
---------- -------------------------------------------------- ----------
--ENE-2016 Robert De Niro                                            188
--FEB-2016 Robert De Niro                                            177
--MAR-2016 Robert De Niro                                            194
--ABR-2016 Robert De Niro                                            202
--MAY-2016 Robert De Niro                                            200
--JUN-2016 Robert De Niro                                            205
--JUL-2016 Robert De Niro                                            197
--AGO-2016 Robert De Niro                                            206
--SEP-2016 Robert De Niro                                            228
--OCT-2016 Robert De Niro                                            228
--NOV-2016 Robert De Niro                                            222
--DIC-2016 Morgan Freeman                                            230
