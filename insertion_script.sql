-- INSERTION_SCRIPT.SQL
-- Import data from the obsolete database of LOCOCO.
-- LAB ASSIGNMENT FSDB 1
-- AUTHOR: GUILLERMO ESCOBERO HERNANDEZ, RAUL OLMEDO CHECA
-- MARCH 2017

INSERT INTO PRODUCTS VALUES('Free Rider',10,'C',2.5,5,0,0.95,5);
INSERT INTO PRODUCTS VALUES('Premium Rider',39,'V',0.5,0,0.01,0,3);
INSERT INTO PRODUCTS VALUES('TVrider',29,'C',2,8,0,0.5,0);
INSERT INTO PRODUCTS VALUES('Flat Rate Lover',39,'C',2.5,0,0,0,5);
INSERT INTO PRODUCTS VALUES('Short Timer',15,'C',2.5,5,0.01,0,3);
INSERT INTO PRODUCTS VALUES('Content Master',20,'C',1.75,4,1.02,0,3);
INSERT INTO PRODUCTS VALUES('Boredom Fighter',10,'V',1,1,0,0.95,0);
INSERT INTO PRODUCTS VALUES('Low Cost Rate',0,'V',0.95,4,0,1.45,3);

INSERT INTO CLIENTS (CLIENTID, EMAIL, DNI, NAME, SURNAME, SEC_SURNAME, BIRTHDATE, PHONEN)
SELECT DISTINCT CLIENTID, EMAIL, DNI, NAME, SURNAME, SEC_SURNAME, TO_DATE(BIRTHDATE, 'YYYY-MM-DD'), TO_NUMBER(PHONEN, '99999999999999') FROM FSDB.OLD_CONTRACTS;

INSERT INTO CONTRACTS (CONTRACTID, CLIENTID, ZIPCODE, TOWN, ADDRESS, COUNTRY, STARTDATE, ENDDATE, CONTRACT_TYPE)
SELECT CONTRACTID, CLIENTID, ZIPCODE, TOWN, ADDRESS, COUNTRY, TO_DATE(STARTDATE, 'YYYY-MM-DD'), TO_DATE(ENDDATE, 'YYYY-MM-DD'), CONTRACT_TYPE FROM FSDB.OLD_CONTRACTS;

INSERT INTO MOVIES (COLOR, DIRECTOR_NAME, NUM_CRITIC_FOR_REVIEWS, DURATION, DIRECTOR_FACEBOOK_LIKES, ACTOR_3_FACEBOOK_LIKES, ACTOR_2_NAME, ACTOR_1_FACEBOOK_LIKES, GROSS, GENRES, ACTOR_1_NAME, MOVIE_TITLE, NUM_VOTED_USERS, CAST_TOTAL_FACEBOOK_LIKES, ACTOR_3_NAME, FACENUMBER_IN_POSTER, PLOT_KEYWORDS, MOVIE_IMDB_LINK, NUM_USER_FOR_REVIEWS, FILMING_LANGUAGE, COUNTRY, CONTENT_RATING, BUDGET, TITLE_YEAR, ACTOR_2_FACEBOOK_LIKES, IMDB_SCORE, ASPECT_RATIO, MOVIE_FACEBOOK_LIKES)
SELECT COLOR, DIRECTOR_NAME, TO_NUMBER(NUM_CRITIC_FOR_REVIEWS), TO_NUMBER(DURATION), TO_NUMBER(DIRECTOR_FACEBOOK_LIKES), TO_NUMBER(ACTOR_3_FACEBOOK_LIKES), ACTOR_2_NAME, TO_NUMBER(ACTOR_1_FACEBOOK_LIKES), TO_NUMBER(GROSS), GENRES, ACTOR_1_NAME, MOVIE_TITLE, TO_NUMBER(NUM_VOTED_USERS), TO_NUMBER(CAST_TOTAL_FACEBOOK_LIKES), ACTOR_3_NAME, TO_NUMBER(FACENUMBER_IN_POSTER), PLOT_KEYWORDS, MOVIE_IMDB_LINK, TO_NUMBER(NUM_USER_FOR_REVIEWS), FILMING_LANGUAGE, COUNTRY, CONTENT_RATING, TO_NUMBER(BUDGET), TO_DATE(TITLE_YEAR, 'YYYY'), TO_NUMBER(ACTOR_2_FACEBOOK_LIKES), TO_NUMBER(IMDB_SCORE, '99.9'), TO_NUMBER(ASPECT_RATIO, '99.99'), TO_NUMBER(MOVIE_FACEBOOK_LIKES) FROM FSDB.OLD_MOVIES;

INSERT INTO TVSERIES (TITLE, TOTAL_SEASONS, SEASON, AVGDURATION, EPISODES)
SELECT TITLE, TO_NUMBER(TOTAL_SEASONS, '999'), TO_NUMBER(SEASON, '99'), TO_NUMBER(AVGDURATION, '999'), TO_NUMBER(EPISODES, '999') FROM FSDB.OLD_TVSERIES;

INSERT INTO TAPSTV (CLIENT, TITLE, DURATION, SEASON, EPISODE, VIEWDATE, VIEWPCT)
SELECT CLIENT, TITLE, TO_NUMBER(DURATION), TO_NUMBER(SEASON), TO_NUMBER(EPISODE), TO_DATE(VIEWDATE || ' ' || VIEWHOUR, 'YYYY-MM-DD HH24:MI'), TO_NUMBER(SUBSTR(VIEWPCT, 1, INSTR(VIEWPCT, '%')-1), '999') FROM FSDB.OLD_TAPS NATURAL JOIN TVSeries;

INSERT INTO TAPSMOVIES (CLIENT, TITLE, VIEWDATE, VIEWPCT)
SELECT CLIENT, TITLE, TO_DATE(VIEWDATE || ' ' || VIEWHOUR, 'YYYY-MM-DD HH24:MI'), TO_NUMBER(SUBSTR(VIEWPCT, 1, INSTR(VIEWPCT, '%')-1), '999') FROM FSDB.OLD_TAPS JOIN MOVIES ON TITLE = MOVIE_TITLE WHERE SEASON IS NULL;
