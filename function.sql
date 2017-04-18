-- Bill a given month/year to a given customer with a given product;
-- Returns NUMBER (6.2).

CREATE OR REPLACE FUNCTION bill(client_id VARCHAR2, PERIOD_TO_BILL VARCHAR2, product_type VARCHAR2)
  RETURN NUMBER
IS
  TOTAL_PRICE        NUMBER(6, 2); --coste total a cobrar(returning value)
  COST_OF_MOVIES     NUMBER;
  COST_OF_SERIES     NUMBER;
  PROMOTION_DISCOUNT NUMBER;

  --CURSOR TO GET THE TABLE REGARDING MOVIES CONSUMED IN THE MONTH PROVIDED
  CURSOR BILL_ALL_MOVIES (CLIENT_ID VARCHAR2, PERIOD_TO_BILL VARCHAR2, PRODUCT_TYPE VARCHAR2)
  IS
    SELECT
      CLIENTID,
      CONTRACTID,
      MOVIE_DURATION,
      PRODUCT_NAME,
      VIEW_DATETIME,
      TYPE,
      ZAPP,
      PP,
      PPM,
      PPD,
      PROMO,
      PCT,
      DATETIME AS PURCHASE_DATETIME,
      CONTRACT_STARTDATE
    FROM
      (
        SELECT
          CLIENTID,
          CONTRACTID,
          DURATION AS MOVIE_DURATION,
          PRODUCT_NAME,
          VIEW_DATETIME,
          TYPE,
          ZAPP,
          PP,
          PPM,
          PPD,
          PROMO,
          PCT,
          TITLE    AS MOVIE_TITLE,
          CONTRACT_STARTDATE
        FROM
          (
            SELECT
              CLIENTID,
              CONTRACTID,
              TITLE,
              PRODUCT_NAME,
              VIEW_DATETIME,
              TYPE,
              ZAPP,
              TAP_COST AS PP,
              PPM,
              PPD,
              PROMO,
              PCT,
              CONTRACT_STARTDATE
            FROM
              (
                SELECT
                  CLIENTID,
                  CONTRACTID,
                  TITLE,
                  CONTRACT_TYPE,
                  VIEW_DATETIME,
                  PCT,
                  STARTDATE AS CONTRACT_STARTDATE
                FROM
                  (
                    SELECT
                      TITLE,
                      CONTRACTID,
                      VIEW_DATETIME,
                      PCT
                    FROM TAPS_MOVIES
                    )
                  NATURAL JOIN CONTRACTS
                )
              JOIN PRODUCTS ON PRODUCT_NAME = CONTRACT_TYPE
            WHERE (CLIENTID = CLIENT_ID AND TO_CHAR(VIEW_DATETIME, 'MON-YYYY') = PERIOD_TO_BILL AND
                   PRODUCT_NAME = PRODUCT_TYPE)
            )
          JOIN MOVIES ON TITLE = MOVIE_TITLE
        )
      JOIN LIC_MOVIES ON MOVIE_TITLE = TITLE AND CLIENTID = CLIENT;

  --CURSOR TO GET THE TABLE REGARDING SERIES CONSUMED IN THE MONTH PROVIDED
  CURSOR BILL_ALL_SERIES (CLIENT_ID VARCHAR2, PERIOD_TO_BILL VARCHAR2, PRODUCT_TYPE VARCHAR2)
  IS
    SELECT
      CLIENTID,
      CONTRACTID,
      PRODUCT_NAME,
      VIEW_DATETIME,
      TYPE,
      ZAPP,
      PP,
      PPM,
      PPD,
      PROMO,
      SEASON_SERIES,
      SERIES_TITLE,
      AVGDURATION,
      PCT,
      DATETIME AS PURCHASE_DATETIME
    FROM
      (
        SELECT
          CLIENTID,
          CONTRACTID,
          PRODUCT_NAME,
          VIEW_DATETIME,
          TYPE,
          ZAPP,
          TAP_COST AS PP,
          PPM,
          PPD,
          PROMO,
          SEASON_SERIES,
          SERIES_TITLE,
          AVGDURATION,
          PCT
        FROM
          (
            SELECT
              CLIENTID,
              CONTRACTID,
              CONTRACT_TYPE,
              VIEW_DATETIME,
              SEASON_SERIES,
              SERIES_TITLE,
              AVGDURATION,
              PCT
            FROM
              (
                SELECT
                  CONTRACTID,
                  VIEW_DATETIME,
                  SEASON AS SEASON_SERIES,
                  SERIES_TITLE,
                  AVGDURATION,
                  PCT
                FROM
                  (
                    SELECT
                      CONTRACTID,
                      VIEW_DATETIME,
                      TITLE  AS SERIES_TITLE,
                      PCT,
                      SEASON AS SEASON_SERIES
                    FROM TAPS_SERIES
                    )
                  JOIN SEASONS
                    ON TITLE = SERIES_TITLE AND SEASON = SEASON_SERIES
                )
              NATURAL JOIN CONTRACTS
            )
          JOIN PRODUCTS ON PRODUCT_NAME = CONTRACT_TYPE
        WHERE
          (CLIENTID = CLIENT_ID AND TO_CHAR(VIEW_DATETIME, 'MON-YYYY') = PERIOD_TO_BILL AND PRODUCT_NAME = PRODUCT_TYPE)
        )
      JOIN LIC_SERIES ON SERIES_TITLE = TITLE AND CLIENTID = CLIENT;


  CURSOR CHECK_PROMOTION (CLIENT_ID VARCHAR2, PRODUCT_TYPE VARCHAR2)
  IS
    SELECT
      STARTDATE,
      ENDDATE,
      CONTRACT_TYPE
    FROM CONTRACTS
    WHERE CLIENTID = CLIENT_ID AND CONTRACT_TYPE = PRODUCT_TYPE;

  --BEGIN WITH THE FUNCTION
  BEGIN
    TOTAL_PRICE := 0;
    COST_OF_MOVIES := 0;
    COST_OF_SERIES := 0;
    PROMOTION_DISCOUNT := 0;

    --OPEN BILL_ALL_MOVIES;
    FOR CLIENTID IN BILL_ALL_MOVIES(CLIENT_ID, PERIOD_TO_BILL, PRODUCT_TYPE)
    LOOP
      PROMOTION_DISCOUNT := CLIENTID.PROMO;
      IF CLIENTID.ZAPP <= CLIENTID.PCT
      THEN
        CASE CLIENTID.TYPE
          WHEN 'V'
          THEN COST_OF_MOVIES :=
          COST_OF_MOVIES + CLIENTID.PP * 2 + CLIENTID.PPM * CEIL(CLIENTID.MOVIE_DURATION * CLIENTID.PCT / 100) +
          CLIENTID.PPD; -- TODO PPD
          WHEN 'C'
          THEN
            IF (NOT CLIENTID.PURCHASE_DATETIME < CLIENTID.VIEW_DATETIME)
            --TODO ESTO PUEDE JODER LOS CALCULOS, TENER EN CUENTA!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1
            THEN
              COST_OF_MOVIES := COST_OF_MOVIES + CLIENTID.PP * 2 + CLIENTID.PPM * CLIENTID.MOVIE_DURATION +
                                CLIENTID.PPD; --TODO IF EL CONTENT SE VE EN OTRO DIA? COMO VA EL PPD?
            END IF;
        END CASE;
      END IF;
    END LOOP;
    --CLOSE BILL_ALL_MOVIES;


    --OPEN BILL_ALL_SERIES;
    FOR CLIENTID IN BILL_ALL_SERIES(CLIENT_ID, PERIOD_TO_BILL, PRODUCT_TYPE)
    LOOP
      IF CLIENTID.ZAPP <= CLIENTID.PCT
      THEN
        CASE CLIENTID.TYPE
          WHEN 'V'
          THEN COST_OF_SERIES :=
          COST_OF_SERIES + CLIENTID.PP + CLIENTID.PPM * CEIL(CLIENTID.AVGDURATION * CLIENTID.PCT / 100) + CLIENTID.PPD;
          WHEN 'C'
          THEN
            IF (NOT CLIENTID.PURCHASE_DATETIME < CLIENTID.VIEW_DATETIME)
            --TODO ESTO PUEDE JODER LOS CALCULOS, TENER EN CUENTA!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1
            THEN
              COST_OF_SERIES := COST_OF_MOVIES + CLIENTID.PP + CLIENTID.PPM * CLIENTID.AVGDURATION +
                                CLIENTID.PPD; --TODO IF EL CONTENT SE VE EN OTRO DIA? COMO VA EL PPD?
            END IF;
        END CASE;
      END IF;
    END LOOP;
    --CLOSE BILL_ALL_SERIES;
    --TODO MIRAR LO DE LOS CURSORES

    TOTAL_PRICE := COST_OF_MOVIES + COST_OF_SERIES;

    CASE PRODUCT_TYPE
      WHEN 'Free Rider'
      THEN TOTAL_PRICE := TOTAL_PRICE + 10;
      WHEN 'Premium Rider'
      THEN TOTAL_PRICE := TOTAL_PRICE + 39;
      WHEN 'TVrider'
      THEN TOTAL_PRICE := TOTAL_PRICE + 29;
      WHEN 'Flat Rate Lover'
      THEN TOTAL_PRICE := TOTAL_PRICE + 39;
      WHEN 'Short Timer'
      THEN TOTAL_PRICE := TOTAL_PRICE + 15;
      WHEN 'Content Master'
      THEN TOTAL_PRICE := TOTAL_PRICE + 20;
      WHEN 'Boredom Fighter'
      THEN TOTAL_PRICE := TOTAL_PRICE + 10;
      WHEN 'Low Cost Rate'
      THEN TOTAL_PRICE := TOTAL_PRICE + 0;
    END CASE;

    --CHECK IF THE CURRENT MONTH IS ELEGIBLE FOR A PROMOTION
    --OPEN CHECK_PROMOTION;
    FOR CLIENTID IN CHECK_PROMOTION(CLIENT_ID, PRODUCT_TYPE)
    LOOP
      IF REMAINDER(ROUND(MONTHS_BETWEEN(SYSDATE, CLIENTID.STARTDATE), 0), 8) = 0
      THEN
        TOTAL_PRICE := TOTAL_PRICE - (TOTAL_PRICE * PROMOTION_DISCOUNT / 100);
      END IF;
    END LOOP;
    --CLOSE CHECK_PROMOTION;

    RETURN TOTAL_PRICE;
  END;
/

--PROCEDURE TO CALL THE FUNCTION
DECLARE
BEGIN
  --MES EN ESPAÑOL
  SYS.DBMS_OUTPUT.PUT_LINE(BILL('86/83744772/18T', 'MAR-2016', 'Low Cost Rate') || '$');
END;
/
