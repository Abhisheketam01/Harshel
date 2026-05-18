# Harshel

-- ============================================================
--  PROBLEM 8 — Triggers on Employees2
-- ============================================================

CREATE TABLE Employees2 (
    emp_id   INT PRIMARY KEY,
    emp_name VARCHAR(100) NOT NULL,
    salary   DECIMAL(10,2)
);

INSERT INTO Employees2 VALUES
(1, 'Alice',  45000), (2, 'Bob',   72000),
(3, 'Carol',  55000), (4, 'David', 38000),
(5, 'Eva',    90000);

-- i. Validate salary on INSERT
DELIMITER $$
CREATE TRIGGER trg_insert_salary
BEFORE INSERT ON Employees2
FOR EACH ROW
BEGIN
    IF NEW.salary <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Salary must be greater than 0.';
    END IF;
END$$

-- Validate salary on UPDATE
CREATE TRIGGER trg_update_salary
BEFORE UPDATE ON Employees2
FOR EACH ROW
BEGIN
    IF NEW.salary <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Salary must be greater than 0.';
    END IF;
END$$

-- ii. Prevent DELETE of high salary employees
CREATE TRIGGER trg_delete_salary
BEFORE DELETE ON Employees2
FOR EACH ROW
BEGIN
    IF OLD.salary >= 80000 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot delete high salary employee.';
    END IF;
END$$
DELIMITER ;

-- Test (uncomment to verify errors):
-- INSERT INTO Employees2 VALUES (6, 'Test', -500);   -- ERROR
-- UPDATE Employees2 SET salary = 0 WHERE emp_id = 1; -- ERROR
-- DELETE FROM Employees2 WHERE emp_id = 5;           -- ERROR (salary 90000)

DELETE FROM Employees2 WHERE emp_id = 4; -- OK (salary 38000)

SELECT * FROM Employees2;



-///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


CREATE TABLE Department (
    Dept_ID   INT NOT NULL PRIMARY KEY,
    Dept_Name VARCHAR(50)
);

-- ii. Student
CREATE TABLE Student (
    Student_ID   INT PRIMARY KEY,
    Student_Name VARCHAR(100),
    Email        VARCHAR(100),
    Age          INT,
    Dept_ID      INT,
    FOREIGN KEY (Dept_ID) REFERENCES Department(Dept_ID),
    CHECK (Age >= 20)
);

-- iii. Course
CREATE TABLE Course (
    Course_ID   INT PRIMARY KEY,
    Course_Name VARCHAR(100) NOT NULL,
    Credits     INT,
    Dept_ID     INT,
    FOREIGN KEY (Dept_ID) REFERENCES Department(Dept_ID),
    CHECK (Credits >= 1 AND Credits <= 5)
);

-- iv. Enrollments
CREATE TABLE Enrollments (
    Enrollment_ID INT PRIMARY KEY,
    Student_ID    INT,
    Course_name   VARCHAR(100) NOT NULL,
    Semester      VARCHAR(20)  NOT NULL,
    FOREIGN KEY (Student_ID) REFERENCES Student(Student_ID)
);

-- v. Insert 5 records each
INSERT INTO Department VALUES
(1,'Computer Science'),(2,'Information Technology'),
(3,'Electronics'),(4,'Mechanical'),(5,'Civil');

INSERT INTO Student VALUES
(101,'Alice Sharma', 'alice@college.edu',21,1),
(102,'Bob Mehta',    'bob@college.edu',  22,2),
(103,'Carol Patil',  'carol@college.edu',20,1),
(104,'David Joshi',  'david@college.edu',23,3),
(105,'Eva Desai',    'eva@college.edu',  25,4);

INSERT INTO Course VALUES
(201,'Database Management',4,1),(202,'Operating Systems',3,1),
(203,'Data Structures',4,2),(204,'Digital Electronics',3,3),
(205,'Thermodynamics',4,4);

INSERT INTO Enrollments VALUES
(301,101,'Database Management','Sem-IV'),
(302,102,'Data Structures','Sem-III'),
(303,103,'Operating Systems','Sem-IV'),
(304,104,'Digital Electronics','Sem-V'),
(305,105,'Thermodynamics','Sem-V');

-- vi. Display all records
SELECT * FROM Department;
SELECT * FROM Student;
SELECT * FROM Course;
SELECT * FROM Enrollments;

-- vii. Add UNIQUE on Email, verify with duplicate
ALTER TABLE Student ADD CONSTRAINT uq_email UNIQUE (Email);

-- INSERT INTO Student VALUES (106,'Frank','alice@college.edu',21,1); -- ERROR: Duplicate





////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- ============================================================
--  PROBLEM 6.2 — Subqueries
-- ============================================================

CREATE TABLE Customer (
    customer_id   INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    city          VARCHAR(50)
);

CREATE TABLE Product (
    Product_id   INT PRIMARY KEY,
    Product_name VARCHAR(100) NOT NULL,
    Price        DECIMAL(10,2)
);

CREATE TABLE `Order` (
    Order_id    INT PRIMARY KEY,
    customer_id INT,
    Product_id  INT,
    quantity    INT,
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id),
    FOREIGN KEY (Product_id)  REFERENCES Product(Product_id)
);

-- i. Insert 5 records
INSERT INTO Customer VALUES
(1,'Rahul Verma','Pune'),(2,'Sneha Kulkarni','Mumbai'),
(3,'Amit Shah','Delhi'),(4,'Priya Nair','Bangalore'),
(5,'Karan Mehta','Chennai');

INSERT INTO Product VALUES
(10,'Laptop',55000),(11,'Mouse',450),(12,'Keyboard',1200),
(13,'Monitor',14000),(14,'Headphones',2500);

-- customer_id 5 has no order (used in NOT IN query)
INSERT INTO `Order` VALUES
(1001,1,10,1),(1002,2,11,2),(1003,3,12,3),
(1004,4,13,2),(1005,1,14,3);

-- ii. Customers who HAVE placed orders
SELECT customer_id, customer_name FROM Customer
WHERE customer_id IN (SELECT DISTINCT customer_id FROM `Order`);

-- iii. Customers who have NOT placed any order
SELECT customer_id, customer_name FROM Customer
WHERE customer_id NOT IN (SELECT DISTINCT customer_id FROM `Order`);

-- iv. Customers with total purchase > 30,000
SELECT c.customer_id, c.customer_name FROM Customer c
WHERE c.customer_id IN (
    SELECT o.customer_id FROM `Order` o
    JOIN Product p ON o.Product_id = p.Product_id
    GROUP BY o.customer_id
    HAVING SUM(p.Price * o.quantity) > 30000
);

-- v. Products more expensive than average price
SELECT Product_id, Product_name, Price FROM Product
WHERE Price > (SELECT AVG(Price) FROM Product);

-- vi. Customers who ordered at least one product (EXISTS)
SELECT customer_id, customer_name FROM Customer c
WHERE EXISTS (SELECT 1 FROM `Order` o WHERE o.customer_id = c.customer_id);



///////////////////////////////////////////////////////////////////////////////////////////////////////////////


- ============================================================
--  PROBLEM 6.2 — Subqueries
-- ============================================================

CREATE TABLE Customer (
    customer_id   INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    city          VARCHAR(50)
);

CREATE TABLE Product (
    Product_id   INT PRIMARY KEY,
    Product_name VARCHAR(100) NOT NULL,
    Price        DECIMAL(10,2)
);

CREATE TABLE `Order` (
    Order_id    INT PRIMARY KEY,
    customer_id INT,
    Product_id  INT,
    quantity    INT,
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id),
    FOREIGN KEY (Product_id)  REFERENCES Product(Product_id)
);

-- i. Insert 5 records
INSERT INTO Customer VALUES
(1,'Rahul Verma','Pune'),(2,'Sneha Kulkarni','Mumbai'),
(3,'Amit Shah','Delhi'),(4,'Priya Nair','Bangalore'),
(5,'Karan Mehta','Chennai');

INSERT INTO Product VALUES
(10,'Laptop',55000),(11,'Mouse',450),(12,'Keyboard',1200),
(13,'Monitor',14000),(14,'Headphones',2500);

-- customer_id 5 has no order (used in NOT IN query)
INSERT INTO `Order` VALUES
(1001,1,10,1),(1002,2,11,2),(1003,3,12,3),
(1004,4,13,2),(1005,1,14,3);

-- ii. Customers who HAVE placed orders
SELECT customer_id, customer_name FROM Customer
WHERE customer_id IN (SELECT DISTINCT customer_id FROM `Order`);

-- iii. Customers who have NOT placed any order
SELECT customer_id, customer_name FROM Customer
WHERE customer_id NOT IN (SELECT DISTINCT customer_id FROM `Order`);

-- iv. Customers with total purchase > 30,000
SELECT c.customer_id, c.customer_name FROM Customer c
WHERE c.customer_id IN (
    SELECT o.customer_id FROM `Order` o
    JOIN Product p ON o.Product_id = p.Product_id
    GROUP BY o.customer_id
    HAVING SUM(p.Price * o.quantity) > 30000
);

-- v. Products more expensive than average price
SELECT Product_id, Product_name, Price FROM Product
WHERE Price > (SELECT AVG(Price) FROM Product);

-- vi. Customers who ordered at least one product (EXISTS)
SELECT customer_id, customer_name FROM Customer c
WHERE EXISTS (SELECT 1 FROM `Order` o WHERE o.customer_id = c.customer_id);


//////////////////////////////////// GHE BHAIII ZAL TUZ KAAAAM 25 /////////////////////////////////////////////////////////////////S
