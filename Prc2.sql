SET SERVEROUTPUT ON
SET PAGESIZE 100
SET LINESIZE 120

CREATE OR REPLACE PROCEDURE prc_product_demand (v_prodID IN CHAR, v_year IN VARCHAR) IS
v_prodName Product.ProductName%TYPE;
v_unitPrice Product.UnitPrice%TYPE;
v_qty NUMBER(4);
v_totalSales NUMBER(9,2);
v_prodStatus VARCHAR(30);

CURSOR prodCursor IS 
SELECT * 
FROM (SELECT ProductName, UnitPrice, SUM(Qty) AS TotalQuantity, (UnitPrice * SUM(Qty)) AS TotalSales
FROM OrderDetails OD, Product P,Orders O
WHERE OD.productID = P.productID 
AND OD.OrderID = O.OrderID
AND P.productID = v_prodID 
AND EXTRACT(YEAR FROM OrderDate) = v_year
GROUP BY ProductName, UnitPrice);
BEGIN

OPEN prodCursor;
 LOOP
  FETCH prodCursor INTO v_prodName, v_unitPrice, v_qty, v_totalSales;
  EXIT WHEN prodCursor%NOTFOUND;
 END LOOP;
CLOSE prodCursor;

IF (v_qty <= 130) THEN
 v_prodStatus := 'Low Demand';
ELSE 
 v_prodStatus := 'High Demand';
END IF;

DBMS_OUTPUT.PUT_LINE(LPAD('=',120, '='));
DBMS_OUTPUT.PUT_LINE(CHR(10));
DBMS_OUTPUT.PUT_LINE('Sales And Demand Details Of ' || v_prodID || ' In Year ' || v_year);
DBMS_OUTPUT.PUT_LINE(LPAD('=',120, '='));
DBMS_OUTPUT.PUT_LINE(RPAD('Product Name',30, ' ') || ' ' ||
RPAD('Quantity Sold',20, ' ') || ' ' ||
RPAD('Price per Unit',20, ' ') || ' ' ||
RPAD('Demand of Product',20, ' ') || ' ' ||
RPAD('Total Sales',14, ' '));
DBMS_OUTPUT.PUT_LINE(LPAD('=',120, '='));
DBMS_OUTPUT.PUT_LINE(RPAD(v_prodName,30, ' ') || ' ' ||
RPAD(v_qty,16, ' ') || ' ' ||
RPAD(TO_CHAR(v_unitPrice,'$9,999.99'),24, ' ') || ' ' ||
RPAD(v_prodStatus,15, ' ') || ' ' ||
RPAD(TO_CHAR(v_totalSales,'$999,999.99'),14, ' '));
DBMS_OUTPUT.PUT_LINE(LPAD('=',120, '='));
END;
/
--EXEC prc_product_demand ('P7', '2022')
