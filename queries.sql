-- 1
SELECT DISTINCT CLIENTS.SURNAME, CLIENTS.NAME, CONTRACTS.STARTDATE, CONTRACTS.ENDDATE, PRODUCTS.TYPE
FROM CONTRACTS
INNER JOIN CLIENTS ON CONTRACTS.CLIENTID=CLIENTS.CLIENTID
INNER JOIN PRODUCTS ON CONTRACTS.CONTRACT_TYPE=PRODUCTS.PRODUCT_NAME
WHERE SYSDATE BETWEEN CONTRACTS.STARTDATE AND CONTRACTS.ENDDATE
ORDER BY CLIENTS.SURNAME, CLIENTS.NAME ASC;
