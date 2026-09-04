-- ============================================================
-- Oracle DBA Portfolio
-- Project: SQL Basics
-- File: basic_database_objects.sql
-- Purpose: Demonstrate common Oracle database objects
-- ============================================================

-- ============================================================
-- 1. CREATE TABLE
-- ============================================================

CREATE TABLE employees (
    employee_id   NUMBER(6),
    employee_name VARCHAR2(100),
    department    VARCHAR2(50),
    salary        NUMBER(10,2),
    hire_date     DATE,
    CONSTRAINT pk_employees PRIMARY KEY (employee_id)
);


-- ============================================================
-- 2. INSERT SAMPLE DATA
-- ============================================================

INSERT INTO employees
    (employee_id, employee_name, department, salary, hire_date)
VALUES
    (1001, 'John Smith', 'IT', 75000, DATE '2023-01-15');

INSERT INTO employees
    (employee_id, employee_name, department, salary, hire_date)
VALUES
    (1002, 'Jane Doe', 'Finance', 68000, DATE '2022-06-20');

INSERT INTO employees
    (employee_id, employee_name, department, salary, hire_date)
VALUES
    (1003, 'Robert Brown', 'IT', 82000, DATE '2021-09-10');

COMMIT;


-- ============================================================
-- 3. BASIC SELECT
-- ============================================================

SELECT
    employee_id,
    employee_name,
    department,
    salary,
    hire_date
FROM employees;


-- ============================================================
-- 4. CREATE INDEX
-- ============================================================

CREATE INDEX idx_employees_department
ON employees (department);


-- ============================================================
-- 5. CREATE VIEW
-- ============================================================

CREATE OR REPLACE VIEW employee_summary AS
SELECT
    employee_id,
    employee_name,
    department,
    salary
FROM employees;


-- ============================================================
-- 6. QUERY THE VIEW
-- ============================================================

SELECT *
FROM employee_summary;


-- ============================================================
-- 7. DATABASE OBJECT INFORMATION
-- ============================================================

SELECT
    object_name,
    object_type,
    status
FROM user_objects
WHERE object_name IN (
    'EMPLOYEES',
    'EMPLOYEE_SUMMARY',
    'IDX_EMPLOYEES_DEPARTMENT'
)
ORDER BY object_type, object_name;


-- ============================================================
-- 8. TABLE INFORMATION
-- ============================================================

SELECT
    table_name,
    num_rows
FROM user_tables
WHERE table_name = 'EMPLOYEES';


-- ============================================================
-- End of Script
-- ============================================================