ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY';
SET LINESIZE 180 
SET PAGESIZE 100 

COLUMN BranchID FORMAT A15 HEADING 'Branch ID' 
COLUMN BranchName FORMAT A25 HEADING 'Branch Name' 
COLUMN BranchEmail FORMAT A35 HEADING 'Branch Email' 
COLUMN BranchAddress FORMAT A30 HEADING 'Branch Address'
COLUMN Sales FORMAT $999,999.99 HEADING 'Total Sales' 

PROMPT This query will generate top 3 outlet based on sales with given input as following 
ACCEPT v_year char FORMAT 'A4' PROMPT 'Enter the year : ' 

CREATE OR REPLACE VIEW QUERY1 
AS SELECT * 
FROM( 
SELECT B.BranchID, BranchName,BranchEmail,BranchAddress,SUM(Grandtotal) AS Sales
FROM Branch B, Staff S, Orders O
WHERE B.BranchID = S.BranchID 
AND S.StaffID = O.StaffID 
AND EXTRACT(YEAR FROM OrderDate) = '&v_year'
GROUP BY B.BranchID,BranchName,BranchEmail,BranchAddress
ORDER BY SUM(Grandtotal) DESC)
WHERE ROWNUM < 4;

COMPUTE SUM LABEL 'SUM' OF Sales ON REPORT
BREAK ON REPORT;

TTITLE LEFT 'The Top 3 Branch Based On Sales In Year '&v_year''SKIP2
SELECT * FROM QUERY1;

CLEAR BREAKS
CLEAR COMPUTES
CLEAR COLUMNS
TTITLE OFF