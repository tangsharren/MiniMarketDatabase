ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY';
SET LINESIZE 180
SET PAGESIZE 100
--To check the format of staff id whether it is a ‘ST’ followed by 2 digits
CREATE OR REPLACE FUNCTION fun_validID (id_in IN CHAR)
RETURN boolean IS
BEGIN
RETURN REGEXP_LIKE(id_in, 'ST\d{1,3}$');
END;
/
 
-- To check the staff age whether he/she is older than 18 years old
CREATE OR REPLACE FUNCTION fun_validAge (dob_in IN DATE)
RETURN boolean IS
BEGIN
RETURN extract(YEAR FROM (SYSDATE - dob_in) YEAR TO MONTH) > 18;
END;
/

 
--To check the format of the staff phone whether it is 
--starts with a + symbol followed by 1 to 3 digits 
--and followed by a space, 3 digits, a space, 3 digits, a space and 4 digits
CREATE OR REPLACE FUNCTION fun_validPhone (phone_in IN VARCHAR2)
RETURN boolean IS
BEGIN
RETURN REGEXP_LIKE(phone_in, '[+]\d{1,3} \d{3} \d{3} \d{4}$');
END;
/
/*
--Declare user-defined exception
TOO_YOUNG EXCEPTION;
PRAGMA EXCEPTION_INIT(TOO_YOUNG,-20001);
BEGIN
 IF (NOT(fun_validAge(:NEW.staffDob))) THEN
*/  
CREATE OR REPLACE TRIGGER trg_manage_staff
BEFORE INSERT OR UPDATE OR DELETE ON Staff
FOR EACH ROW
 
DECLARE
v_numStaff NUMBER(2);
v_maxStaff NUMBER(2);
--TOO_YOUNG EXCEPTION;
--PRAGMA EXCEPTION_INIT(TOO_YOUNG,-20000);
BEGIN
CASE
 WHEN INSERTING THEN
    IF (NOT(fun_validID(:NEW.staffID))) THEN
        RAISE_APPLICATION_ERROR(-20000,'Invalid Staff ID');
    END IF;
 
    IF (NOT(fun_validAge(:NEW.staffDob))) THEN
        --RAISE TOO_YOUNG;
        RAISE_APPLICATION_ERROR(-20000,'Invalid Staff Age');
    END IF;
 
    IF (NOT(fun_validPhone(:NEW.phone))) THEN
        RAISE_APPLICATION_ERROR(-20000,'Invalid Staff Phone Number');
    END IF;
 
    v_maxStaff := 3;
    SELECT countStaff INTO v_numStaff
    FROM (
            SELECT branchID, department, staffRole, COUNT(staffID) AS countStaff
            FROM Staff
            WHERE branchID = :NEW.branchID    
            AND department = :NEW.department
            AND staffRole = :NEW.staffRole
            GROUP BY branchID, department,staffRole);
    IF(v_numStaff >= v_maxStaff) THEN
        RAISE_APPLICATION_ERROR(-20000,'Number of staff reach maximum.');
    END IF;
 
 WHEN UPDATING THEN
    IF (NOT(fun_validID(:NEW.staffID))) THEN
        RAISE_APPLICATION_ERROR(-20000,'Invalid Staff ID');
    END IF;
 
    IF (NOT(fun_validAge(:NEW.staffDob))) THEN
        RAISE_APPLICATION_ERROR(-20000,'Invalid Staff Age');
    END IF;
 
    IF (NOT(fun_validPhone(:NEW.phone))) THEN
        RAISE_APPLICATION_ERROR(-20000,'Invalid Staff Phone Number');
    END IF;
 WHEN DELETING THEN
    RAISE_APPLICATION_ERROR(-20000,'Cannot delete staff record.');
END CASE;
 

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        v_numStaff := 0;
    --WHEN TOO_YOUNG THEN
        --DBMS_OUTPUT.PUT_LINE('OK');
END;
/

SELECT branchID, department, staffRole, COUNT(staffID) AS countStaff
FROM Staff
WHERE branchID = 'B5'
AND StaffRole = 'Baggers'
AND Department = 'Production'
GROUP BY branchID, department,staffRole;
 
--No.of staff reach maximum
INSERT INTO Staff(StaffID, Name, Gender, StaffDOB, Phone, StaffRole, Salary, Address, RegDate, ExperienceInYear, Department, BranchID)
VALUES ('ST450', 'Tan', 'F', '21/02/1993', '+3 804 335 5222', 'Baggers', 3748, '165 Magdeline Drive', '28/04/2018', 8, 'Production', 'B5');
 
-- Invalid ID
INSERT INTO Staff
VALUES ('S2', 'Ferdinand Sturt', 'F', '20/04/1999', '+1 321 553 2269', 'Product Buyer', 4372, '0476 Southridge Court', '26/08/2015', 5, 'Human Resources', 'B7');
 
--Invalid age
INSERT INTO  Staff
VALUES ('ST12', 'Ebeneser Janus', 'F', '21/10/2010', '+1 763 710 4612', 'Department Manager', 3622, '5429 Merchant Junction', '20/06/2019', 3, 'Marketing', 'B3');
 
--Invalid phone no
INSERT INTO  Staff
VALUES('ST6', 'Mathilda Marzella', 'M', '27/12/1999', '3 321 565 1915', 'Shipping and receiving clerks', 2350, '02227 Loomis Court', '28/12/2020', 8, 'Human Resources', 'B9');
 
--Insert new valid staff
INSERT INTO Staff
VALUES('ST999', 'Yeoh', 'M', '30/11/2001', '+7 894 478 1553', 'Product Buyer', 4894, '8485 Buell Parkway', '24/06/2019', 4, 'Human Resources', 'B9');
 
--Show new staff added
SELECT StaffID,StaffDOB,Phone,StaffRole,Department,BranchID
FROM Staff
WHERE StaffID = 'ST999';
 
--Update staff with invalid id
UPDATE Staff
SET StaffID = 'S999'
WHERE Name = 'Yeoh';
 
--Update staff with invalid age
UPDATE Staff
SET StaffDOB = '23/12/2010'
WHERE Name = 'Yeoh';
 
--Update staff with invalid phone
UPDATE Staff
SET Phone = '7 894 478 1553'
WHERE Name = 'Yeoh';
 
--Cannot delete staff record
DELETE FROM Staff
WHERE Name = 'Yeoh';