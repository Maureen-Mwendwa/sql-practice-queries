-- =====================DATABASES & TABLES===============================================
-- ======================================================================================
--                     CREATE & USE A DATABASE
-- =======================================================================================
CREATE database company_db;
USE company_db;
SHOW databases;  -- List all databases
-- DROP database company_db; -- delete (irreversible!)

-- =======================================================================================
--                     CREATE TABLES - SAMPLE SCHEMA
-- =======================================================================================
-- Departments
CREATE TABLE departments (
dept_id int auto_increment Primary Key,
dept_name varchar(100) not null unique
);

-- Employees
CREATE TABLE employees (
emp_id int auto_increment primary key,
first_name varchar(50) not null,
last_name varchar(50) not null,
email varchar(100) unique,
salary decimal(10,2) default 30000.00, /* 10 = the precision → the total number of digits allowed both before and after the decimal point */
hire_date date not null,
dept_id int,
is_active tinyint(1) default 1, -- a small integer column used as a true/false flag, defaulting to true (1)
foreign key (dept_id) references departments(dept_id) 
on delete set null
/* This line defines a foreign key constraint and tells MySQL what to do when related data is deleted.
Any matching dept_id values in this table are automatically set to NULL (instead of deleting the row).
*/
);

-- Projects
CREATE TABLE projects (
project_id INT auto_increment PRIMARY KEY,
project_name varchar(150) NOT NULL,
budget decimal(12,2),
start_date date,
end_date date
);

-- Many-to-many: employees + projects
CREATE TABLE emp_projects (
emp_id int,
project_id int,
role varchar(80),
primary key (emp_id, project_id),
/* It Means:
- The combination of emp_id and project_id must be unique
- Neither emp_id nor project_id can be NULL
- It uniquely identifies each row in the table
- This table represents a many-to-many relationship between employees and projects.
- One employee can be in many projects
- One project can have many employees
- Using both columns ensures: An employee cannot be assigned to the same project more than once
- This design is very standard for junction tables (many-to-many relationships). It keeps your data clean and prevents duplicates without needing an extra ID column.
*/
Foreign key (emp_id) references employees(emp_id),
foreign key (project_id) references projects(project_id)
);

-- =======================================================================================
--                           MODIFY TABLES
-- =======================================================================================
alter table employees add column phone varchar(20);
alter table employees modify column phone varchar(30);
alter table employees rename column phone to phones;
alter table employees drop column phones;
alter table employees rename to staff;  -- rename table
alter table staff rename to employees; 
describe employees;     -- see table structure including fields, datatypes, whether null, primary keys, default settings, extra 

-- ======================== CRUD OPERATIONS==================================================
-- ===========================================================================================
--                         INSERT - ADD DATA
-- ============================================================================================

-- Insert departments
insert into departments (dept_name) values
('Engineering'),
('Marketing'),
('Finance'),
('HR');

-- Insert employees
insert into employees (first_name, last_name, email, salary, hire_date, dept_id) values
('Alice', 'Njeri', 'alice@company.com', 85000.00, '2020-03-15', 1),
('Brian',   'Omondi',   'brian@company.com',   72000.00, '2019-07-01', 1),
('Carol',   'Wambua',   'carol@company.com',   65000.00, '2021-01-10', 2),
('David',   'Kamau',    'david@company.com',   90000.00, '2018-11-20', 3),
('Eva',     'Muthoni', 'eva@company.com',     58000.00, '2022-06-05', 4),
('Frank',   'Otieno',  'frank@company.com',  78000.00, '2020-09-18', 1),
('Grace',   'Akinyi',  'grace@company.com',  67000.00, '2021-04-22', 2),
('Henry',   'Kiptoo',  'henry@company.com',  95000.00, '2017-08-30', 3);

-- Insert projects
INSERT INTO projects (project_name, budget, start_date, end_date) VALUES
    ('Website Redesign',    150000.00, '2024-01-01', '2024-06-30'),
    ('ERP Migration',       500000.00, '2024-03-01', '2025-03-01'),
    ('Marketing Campaign',  80000.00,  '2024-04-01', '2024-09-30');
    
-- Link employees to projects
INSERT INTO emp_projects VALUES
    (1, 1, 'Lead Developer'),
    (2, 1, 'Backend Dev'),
    (1, 2, 'Architect'),
    (4, 2, 'Finance Lead'),
    (3, 3, 'Campaign Manager'),
    (7, 3, 'Content Creator');

-- ===========================================================================================
--                         SELECT - READ DATA
-- ============================================================================================
SELECT * FROM employees;    -- all columns
SELECT first_name, last_name, salary FROM employees; -- specific columns
SELECT first_name as "Name", salary as "Monthly Pay" from employees;

-- ===========================================================================================
--                         UPDATE - MODIFY DATA
-- ============================================================================================
-- Give Alice a 10% raise
update employees
set salary = salary * 1.10
where emp_id = 1;

-- Raise all Engineering staff by 5%
update employees
set salary = salary * 1.05
where dept_id = 1;

-- ********************************************************************************************
/* NEVER run UPDATE or DELETE without a WHERE clause unless you intentionally mean to affect every row. Always test
with a SELECT using the same WHERE first. */

-- ===========================================================================================
--                         DELETE - REMOVE DATA
-- ============================================================================================
delete from employees where emp_id = 5;
/* INSERT INTO employees (first_name, last_name, email, salary, hire_date, dept_id) value
('Eva',     'Muthoni', 'eva@company.com',     58000.00, '2022-06-05', 4); */

-- Soft delete (preferred in production)
update employees
set is_active = 0
where emp_id = 9;

-- Truncate (delete all rows, reset auto-increment)
truncate table emp_projects;

-- =====================FILTERING, SORTING & LIMITING =====================================================
-- ======================================================================================
--                     WHERE with operators
-- =======================================================================================
select * from employees where salary > 70000;
select * from employees where dept_id =1 and salary > 80000;
select * from employees where dept_id = 2 or dept_id = 3;

-- ======================================================================================
--                     BETWEEN
-- =======================================================================================
select * from employees where salary between 60000 and 90000;

-- ======================================================================================
--                     IN / NOT IN
-- =======================================================================================
select * from employees where dept_id in (1, 3);
select * from employees where dept_id not in (2, 4);

-- ======================================================================================
--                     LIKE (Pattern Match)
-- =======================================================================================
select * from employees where first_name like "A%"; -- Starts with A
select * from employees where last_name like "%i"; -- Ends with i 
select * from employees where first_name like "%o%"; -- contains "a"

-- ======================================================================================
--                     Is Null / Is Not Null
-- =======================================================================================
select * from employees where dept_id is not null;

-- ======================================================================================
--                     ORDER BY
-- =======================================================================================
select * from employees order by salary desc;
select * from employees order by first_name asc, salary desc;  -- orders by first_name only

-- ======================================================================================
--                     LIMIT & OFFSET (Pagination)
-- =======================================================================================
select * from employees limit 5;  -- Outputs the first 5 rows
select * from employees limit 5 offset 5; -- rows 6-10

-- ======================================================================================
--                     DISTINCT
-- ======================================================================================
select distinct dept_id from employees;

-- =====================JOINS===============================================
-- ======================================================================================
--                     INNER JOIN - ONLY MATCHING ROWS
-- ======================================================================================
select employees.first_name, employees.last_name, departments.dept_name, employees.salary
from employees
inner join departments on employees.dept_id = departments.dept_id
order by departments.dept_name desc;

-- ======================================================================================
--                     MULTI-TABLE JOIN
-- ======================================================================================

-- Employees, their department, and projects
select 
employees.first_name,
employees.last_name,
departments.dept_name,
projects.project_name,
emp_projects.role
from employees
join departments on employees.dept_id = departments.dept_id
join emp_projects on employees.emp_id = emp_projects.emp_id
join projects on projects.project_id = emp_projects.project_id;

-- =====================Aggregate Functions & Group By =====================================================
-- ======================================================================================
--                     Basic aggregates
-- =======================================================================================

select 
count(*) As total_employees,
avg(salary) As avg_salary,
max(salary) As highest_salary,
min(salary) As lowest_salary,
sum(salary) As total_payroll

from employees;

-- ======================================================================================
--                     GROUP BY - summary per department
-- =======================================================================================
select
departments.dept_name,
count(employees.emp_id) As headcount,
avg(employees.salary) As avg_salary,
sum(employees.salary) As dept_payroll

from employees
join departments on employees.dept_id = departments.dept_id
group by departments.dept_name
order by dept_payroll desc;

-- ======================================================================================
--                     HAVING - filter on aggregate (Where can't do this)
-- =======================================================================================
select 
departments.dept_name,
avg(employees.salary) As avg_salary

from employees
join departments on employees.dept_id = departments.dept_id
group by departments.dept_name
having avg(employees.salary) > 70000;

-- ======================================================================================
--                     GROUP_CONCAT - combine rows into one string
-- =======================================================================================
select
departments.dept_name,
group_concat(employees.first_name order by employees.first_name separator ", ") As members

from employees
join departments on employees.dept_id = departments.dept_id
group by departments.dept_name;

-- =====================SUBQUERIES =====================================================
-- ======================================================================================
-- Employees earning above company average
select 
first_name,
last_name,
salary
from employees
where salary > (select avg(salary) from employees);

-- Employees assigned to at least one project
select * from employees
where emp_id in (select distinct emp_id from emp_projects);


