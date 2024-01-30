ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY';
SET LINESIZE 180 
SET PAGESIZE 100 

COLUMN ProductID FORMAT A15 HEADING 'Product ID' 
COLUMN ProdcutName FORMAT A25 HEADING 'Product Name' 
COLUMN ProductCategory FORMAT A40 HEADING 'Product Category' 
COLUMN Sales FORMAT $999,999.99 HEADING 'Total Sales' 

PROMPT This query will generate top 5 products within a date range as following 
ACCEPT v_startDate DATE FORMAT 'DD/MM/YYYY' PROMPT 'Enter the start date (DD/MM/YYYY) : ' 
ACCEPT v_endDate DATE FORMAT 'DD/MM/YYYY' PROMPT 'Enter the end date (DD/MM/YYYY) : '
CREATE OR REPLACE VIEW QUERY2
AS SELECT * 
FROM( 
SELECT P.ProductID,ProductName,ProductCategory,SUM(Qty * UnitPrice) AS Sales
FROM Product P,OrderDetails OD,Orders O
WHERE P.ProductID = OD.ProductID
AND O.OrderID = OD.OrderID
AND OrderDate BETWEEN '&v_startDate' AND '&v_endDate'
GROUP BY P.ProductID,ProductName,ProductCategory
ORDER BY Sales DESC)
WHERE ROWNUM < 5;

COMPUTE SUM LABEL 'SUM' OF Sales ON REPORT
BREAK ON REPORT;

TTITLE LEFT 'The Top 5 Product From '&v_startDate' TO '&v_endDate''SKIP2
SELECT * FROM QUERY2;

CLEAR BREAKS
CLEAR COMPUTES
CLEAR COLUMNS
TTITLE OFF
