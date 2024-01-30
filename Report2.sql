ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY';
SET SERVEROUTPUT ON
SET LINESIZE 150
SET PAGESIZE 120

CREATE INDEX Name
ON Product (productName);

CREATE OR REPLACE PROCEDURE prc_report2 IS
v_supplierID Supplier.supplierID%TYPE;
v_supplierName Supplier.supplierName%TYPE;
v_subtotal NUMBER(11,2);
v_grandTotal NUMBER(11,2);
v_totalvalue NUMBER(15,2);

CURSOR supplierCursor IS
 SELECT DISTINCT S.supplierID, supplierName
 FROM Supplier S, Supply SI
 WHERE S.supplierID = SI.supplierID
 ORDER BY LENGTH(S.supplierID), S.supplierID;

  CURSOR productDetailCursor IS
   SELECT DISTINCT P.productID, productName, productCategory, supplyPrice, SUM(supplyQty) AS quantity, supplyPrice * SUM(supplyQty) AS Subtotal
   FROM Product P, Supply SI, Supplier S
   WHERE S.supplierID = v_supplierID 
   AND supplierName = v_supplierName 
   AND P.productID = SI.productID 
   AND S.supplierID = SI.supplierID 
   GROUP BY P.productID, productName, supplyPrice, productCategory
   ORDER BY LENGTH(P.productID),P.productID, productName;
   prodRec productDetailCursor%ROWTYPE;
   BEGIN
   v_totalValue := 0;
    DBMS_OUTPUT.PUT_LINE(LPAD('=',27, '=') || '=' || RPAD('Report of Products Supplied by Each Supplier', 72, '='));
    DBMS_OUTPUT.PUT_LINE(CHR(10));
    OPEN supplierCursor;
      LOOP
       FETCH supplierCursor INTO v_supplierID, v_supplierName;
       EXIT WHEN supplierCursor%NOTFOUND;
       DBMS_OUTPUT.PUT_LINE(LPAD('=',100, '='));
       DBMS_OUTPUT.PUT_LINE(CHR(10));
       DBMS_OUTPUT.PUT_LINE('Supplier ID: '|| v_supplierID);
       DBMS_OUTPUT.PUT_LINE('Supplier Name: '|| v_supplierName);
       DBMS_OUTPUT.PUT_LINE(CHR(10));
       DBMS_OUTPUT.PUT_LINE(LPAD('=',100,'='));
       DBMS_OUTPUT.PUT_LINE(RPAD('Product ID',10,' ') || ' ' ||
       RPAD('Product Name', 28, ' ') || ' ' ||
       RPAD('Product Category', 20, ' ') || ' ' ||
       RPAD('Quantity',9,' ')|| ' ' ||
       RPAD(' Buy Price',10,' ')|| ' ' ||
       LPAD('Subtotal',16,' '));
       DBMS_OUTPUT.PUT_LINE(LPAD('=',100,'='));

       OPEN productDetailCursor;
        v_grandTotal := 0;
        LOOP
         FETCH productDetailCursor INTO prodRec;
         IF (productDetailCursor%ROWCOUNT = 0) THEN
          DBMS_OUTPUT.PUT_LINE('No such product');
         END IF;
         EXIT WHEN productDetailCursor%NOTFOUND;
         v_grandTotal := v_grandTotal + prodRec.Subtotal;
         DBMS_OUTPUT.PUT_LINE(RPAD(prodRec.productID, 10, ' ') || ' ' || 
         RPAD(prodRec.productName, 28, ' ') || ' ' ||
         RPAD(prodRec.productCategory, 20, ' ') || ' ' ||
         RPAD(prodRec.quantity, 9, ' ') || ' ' ||
         RPAD(TO_CHAR(prodRec.supplyPrice, '$9,999.99'), 12, ' ') || ' ' ||
         RPAD(TO_CHAR(prodRec.Subtotal, '$9,999,999.99'), 20, ' '));
        END LOOP;

        v_totalValue := v_totalValue + v_grandTotal;
        DBMS_OUTPUT.PUT_LINE(LPAD('=',100, '='));
        DBMS_OUTPUT.PUT_LINE(RPAD('*', 50, ' ') || LPAD('Grand Total: ' || 
        TO_CHAR(v_grandTotal, '$999,999,999.99'), 47, ' '));
        DBMS_OUTPUT.PUT_LINE('Total Record: ' || productDetailCursor%ROWCOUNT);
        
        DBMS_OUTPUT.PUT_LINE(CHR(10));
       CLOSE productDetailCursor;
      END LOOP;
    DBMS_OUTPUT.PUT_LINE(LPAD('=',43, '=') || '=' || RPAD('End of Report', 56, '='));
    DBMS_OUTPUT.PUT_LINE(CHR(10));
    DBMS_OUTPUT.PUT_LINE('Total number of Supplier: ' || supplierCursor%ROWCOUNT);
    DBMS_OUTPUT.PUT_LINE('Total value of all product supplies: ' || TO_CHAR(v_totalValue, '$999,999,999,999.99'));
    CLOSE supplierCursor;
END;
/ 
DROP INDEX Name;
--EXEC prc_report2