SET linesize 120
SET pagesize 100
ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY';
SET SERVEROUTPUT ON

CREATE OR REPLACE PROCEDURE prc_report1 (v_startDate IN DATE,v_endDate IN DATE) IS
v_orderID Orders.orderID%TYPE;
v_orderDate Orders.orderDate%TYPE;
v_customerName Customer.custName%TYPE;
v_staffName Staff.name%TYPE;
v_subtotal NUMBER(11,2);
v_grandTotal NUMBER(11,2);
v_totalValue NUMBER(15,2);

CURSOR orderCursor IS
 SELECT orderID, orderDate, custName, name
 FROM Orders O, Customer C, Staff S
 WHERE O.custID = C.custID 
 AND O.staffID = S.staffID 
 AND orderDate BETWEEN v_startDate AND v_endDate
 ORDER BY orderDate;
CURSOR orderDetailCursor IS
 SELECT OD.productID, productName, unitPrice, qty, unitPrice * qty AS subtotal
 FROM OrderDetails OD, Product P
 WHERE P.productID = OD.productID AND orderID = v_orderID;
 ordRec orderDetailCursor%ROWTYPE;
BEGIN
v_totalValue := 0;
OPEN orderCursor;
 DBMS_OUTPUT.PUT_LINE(CHR(10));
 DBMS_OUTPUT.PUT_LINE(LPAD('=',20, '=') || '=' || RPAD('Report of Orders from ' || v_startDate || ' to ' || v_endDate , 71 ,'='));
 DBMS_OUTPUT.PUT_LINE(CHR(10));
 LOOP
  FETCH orderCursor INTO v_orderID, v_orderDate, v_customerName, v_staffName;
  EXIT WHEN orderCursor%NOTFOUND;

  DBMS_OUTPUT.PUT_LINE(LPAD('=',92,'='));
  DBMS_OUTPUT.PUT_LINE(LPAD('*',1,' ') || LPAD('Order '|| v_orderID, 47 ,' '));
  DBMS_OUTPUT.PUT_LINE(LPAD('=',92,'=') || CHR(10));
  DBMS_OUTPUT.PUT_LINE('Order Date: '|| v_orderDate);
  DBMS_OUTPUT.PUT_LINE('Customer Name: '|| v_customerName);
  DBMS_OUTPUT.PUT_LINE('Staff Name: '|| v_staffName || CHR(10));
  DBMS_OUTPUT.PUT_LINE(LPAD('=',92,'='));
  DBMS_OUTPUT.PUT_LINE(RPAD('Product ID',15,' ')|| ' ' ||
  RPAD('Product Name',30,' ')|| ' ' ||
  RPAD('Unit Price',17,' ')|| ' ' ||
  RPAD('Quantity',15,' ')|| ' ' ||
  LPAD('Subtotal',10,' '));
  DBMS_OUTPUT.PUT_LINE(LPAD('=',92,'='));

  OPEN orderDetailCursor;
  v_grandTotal := 0;
   LOOP
    FETCH orderDetailCursor INTO ordRec;
    IF (orderDetailCursor%ROWCOUNT = 0) THEN
     DBMS_OUTPUT.PUT_LINE('No such order');
    END IF;
    EXIT WHEN orderDetailCursor%NOTFOUND;
    v_grandTotal := v_grandTotal + ordRec.subtotal;
    DBMS_OUTPUT.PUT_LINE(RPAD(ordRec.productID,13,' ')|| ' ' || 
    RPAD(ordRec.productName,29,' ') || ' ' ||
    RPAD(TO_CHAR(ordRec.unitPrice,'$9,999.99'),23,' ')|| ' ' ||
    RPAD(ordRec.qty,11,' ') || ' ' || 
    RPAD(TO_CHAR(ordRec.subtotal,'$999,999.99'),15,' '));
   END LOOP;
 
  v_totalValue := v_totalValue + v_grandTotal;
  DBMS_OUTPUT.PUT_LINE(LPAD('=',92,'='));
  DBMS_OUTPUT.PUT_LINE(RPAD('*',50, ' ') || LPAD('Grand Total: '|| TO_CHAR(v_grandTotal,'$999,999,999.99'),42,' '));
  DBMS_OUTPUT.PUT_LINE('No. of products: '|| orderDetailCursor%ROWCOUNT);
  DBMS_OUTPUT.PUT_LINE(CHR(10));
 CLOSE orderDetailCursor;
END LOOP; 

DBMS_OUTPUT.PUT_LINE(LPAD(' ',38,'=') || RPAD('End of Report ',54,'='));
 
DBMS_OUTPUT.PUT_LINE('Total number of orders : ' || orderCursor%ROWCOUNT);
DBMS_OUTPUT.PUT_LINE('Total value of all orders in between ' || v_startDate || ' to ' || v_endDate || ': ' || TO_CHAR(v_totalValue,'$999,999,999,999.99'));
CLOSE orderCursor;
END;
/
--EXEC prc_report1('01/05/2021','01/08/2021')