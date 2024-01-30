ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY';
SET SERVEROUTPUT ON
SET PAGESIZE 180
SET LINESIZE 180

--Extra efforts: Function
CREATE OR REPLACE FUNCTION getName (v_branchId IN VARCHAR)
RETURN VARCHAR IS 
v_branchName VARCHAR(30);
BEGIN
SELECT BranchName INTO v_branchName
FROM Branch
WHERE BranchID = v_branchID;
RETURN v_branchName;
END;
/

CREATE OR REPLACE PROCEDURE prc_top10_prod_of_branch (v_branchID IN VARCHAR, v_startDate IN VARCHAR, v_endDate IN VARCHAR) IS
v_prodID Product.productID%TYPE;
v_prodName Product.productname%TYPE;
v_unitPrice Product.unitprice%TYPE;
v_orderQty NUMBER(4);
v_totalSales NUMBER(9,2);
v_grandTotal NUMBER(9,2);

CURSOR prodCursor IS
SELECT *
FROM (SELECT P.productID, productname, unitprice, SUM(Qty) AS TotalQuantity, SUM(unitprice * Qty) AS TotalSales
FROM Product P,OrderDetails OD,Orders O, Staff S,Branch B
WHERE P.ProductID = OD.ProductID
AND O.OrderID = OD.OrderID
AND O.StaffID = S.StaffID
AND S.BranchID = B.BranchID
AND orderDate BETWEEN v_startDate AND v_endDate
AND B.BranchID = v_branchId 
GROUP BY P.productID, productName, unitPrice
ORDER BY TotalQuantity desc)
WHERE ROWNUM <= 3;
BEGIN 

OPEN prodCursor;
 v_grandTotal := 0;
 DBMS_OUTPUT.PUT_LINE(LPAD('=',120, '='));
 DBMS_OUTPUT.PUT_LINE(CHR(10));
 DBMS_OUTPUT.PUT_LINE('Top 3 Product Sales In ' || getName(v_branchID) ||' from ' || v_startDate || ' to ' || v_endDate);
 DBMS_OUTPUT.PUT_LINE(LPAD('=',120, '='));
 DBMS_OUTPUT.PUT_LINE(RPAD('Product ID',18, ' ') || ' ' ||
 RPAD('Product Name',24, ' ') || ' ' ||
 RPAD('Price per Unit',20, ' ') || ' ' ||
 RPAD('Quantity Sold',24, ' ') || ' ' ||
 RPAD('Total Sales',14, ' '));
 DBMS_OUTPUT.PUT_LINE(LPAD('=',120, '='));
 LOOP
  FETCH prodCursor INTO v_prodID, v_prodName, v_unitPrice, v_orderQty, v_totalSales;
  EXIT WHEN prodCursor%NOTFOUND;
  DBMS_OUTPUT.PUT_LINE(RPAD(v_prodID,15, ' ') || ' ' ||
  RPAD(v_prodName,28, ' ') || ' ' ||
  RPAD(TO_CHAR(v_unitPrice,'$9,999.99'),22, ' ') || ' ' ||
  RPAD(v_orderQty,17, ' ') || ' ' ||
  RPAD(TO_CHAR(v_totalSales,'$9,999,999.99'),14, ' '));
  v_grandTotal := v_grandTotal + v_totalSales;
 END LOOP;
 DBMS_OUTPUT.PUT_LINE(LPAD('=',120, '='));
 DBMS_OUTPUT.PUT_LINE(RPAD('Total amount of TOP 3 product sales: ',86,' ') || TO_CHAR(v_grandTotal,'$9,999,999.99'));
 DBMS_OUTPUT.PUT_LINE(LPAD('=',120, '='));
CLOSE prodCursor;
END;
/
--EXEC prc_top10_prod_of_branch ('B5','14/06/2020', '14/08/2022')