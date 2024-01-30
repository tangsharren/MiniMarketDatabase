SET linesize 150
SET pagesize 120

ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY';
SET SERVEROUTPUT ON
/*
DECLARE
 out_of_stock EXCEPTION;
 QtyInStock := 0;
BEGIN
 IF QtyInStock < 1 THEN
   RAISE out_of_stock;
 END IF;
EXCEPTION
 WHEN out_of_stock THEN
  DBMS_OUTPUT.PUT_LINE('Out of stock');
END;
/
*/
CREATE OR REPLACE TRIGGER trg_manage_order
BEFORE INSERT OR UPDATE OR DELETE ON OrderDetails
FOR EACH ROW
DECLARE
v_qtyInStock Product.QtyInStock%TYPE;
v_orderID Orders.OrderID%TYPE;
v_adjustedQty Product.QtyInStock%TYPE;
BEGIN
 CASE
 WHEN INSERTING THEN
    SELECT OrderID INTO v_orderID
    FROM Orders 
    WHERE OrderID = :NEW.OrderID;

    SELECT QtyInStock INTO v_qtyInStock
    FROM Product
    WHERE ProductID = :NEW.ProductID;

  IF (:NEW.Qty <= v_qtyInStock) THEN
    UPDATE Product
    SET QtyInStock = QtyInStock - :NEW.Qty
    WHERE ProductID = :NEW.ProductID;
  ELSE
    RAISE_APPLICATION_ERROR(-20000,'Quantity In Stock not enough.');
  END IF;

 WHEN UPDATING THEN
    SELECT QtyInStock INTO v_qtyInStock
    FROM Product
    WHERE ProductID = :NEW.ProductID;

    SELECT OrderID INTO v_orderID FROM Orders 
    WHERE OrderID = :NEW.OrderID;
    v_adjustedQty := :NEW.Qty - :OLD.Qty;

IF(:NEW.Qty > :OLD.Qty) THEN
    IF (v_adjustedQty <= v_qtyInStock) THEN
        UPDATE Product
        SET QtyInStock = QtyInStock - v_adjustedQty
        WHERE ProductID = :NEW.ProductID;
    ELSE
        DBMS_OUTPUT.PUT_LINE('Quantity In Stock not enough.');
    END IF;
ELSE
    UPDATE Product
    SET QtyInStock = QtyInStock - v_adjustedQty
    WHERE ProductID = :NEW.ProductID;
END IF;

 WHEN DELETING THEN
    UPDATE Product
    SET QtyInStock = QtyInStock + :OLD.Qty
    WHERE ProductID = :OLD.ProductID;
 END CASE;
EXCEPTION

WHEN NO_DATA_FOUND THEN
RAISE_APPLICATION_ERROR(-20000,'Order / Product not exist.');
END;
/
--Show the product's initial QtyInStock
select *
from product
where productID='P4';

--Invalid input
--Try to insert new order details(qty > qtyInStock)
--Show the raise error
insert into OrderDetails (OrderID, ProductID, Qty, SellingPrice, Subtotal) 
values ('OR5', 'P4', 8000, 167, 253);

--Valid input
--insert new order details(qty < qtyInStock)
insert into OrderDetails (OrderID, ProductID, Qty, SellingPrice, Subtotal) 
values ('OR5', 'P4', 300, 167, 253);

--Show the product's latest QtyInStock
select *
from product
where productID='P4';

--Update the order details inserted just now(qty < qtyInStock)
UPDATE OrderDetails
SET Qty = 400
WHERE ProductID = 'P4'
AND OrderID = 'OR5';

--Display the orderdetails inserted just now
select * 
from orderdetails
where orderId = 'OR5' 
and productId = 'P4';


--Show the product's latest qtyInstock(initial - ordered)
select *
from product
where productID='P4';

--Delete the order details inserted just now
DELETE FROM OrderDetails
WHERE ProductID = 'P4'
AND OrderID = 'OR5';

--The qtyInStock back to original value
select *
from product
where productID='P4';
