
-- 1> Write a SQL query to find the nth highest salary from employee table. 
-- Example: finding 3rd highest salary from employee table

with salary_ranking as (
	select 
		salary,
		rank() over(order by salary desc) as rank
	from
		employee
	group by salary
)

select 
	*
from 
	salary_ranking sr 
where sr.rank = 1
group by sr.salary

-- 1b> Write a SQL function that lets you get the nth highest salary from employee table
drop function get_nth_highest_salary

create function get_nth_highest_salary(rank_num integer)
returns integer
as
$$
declare nthRankingSalary integer;
begin

	with salary_ranking as (
		select 
			salary,
			rank() over(order by salary desc) as rank
		from
			employee
		group by salary
	)
	
	select 
		sr.salary into nthRankingSalary
	from -- 10> Write a SQL query to get combine name (first name and last name) of employees from employee table
		salary_ranking sr 
	where sr.rank = rank_num
	group by sr.salary;
	
	return nthRankingSalary;
end;
$$ language plpgsql;

select get_nth_highest_salary(1)


-- 2> Write a SQL query to find top n records?
--    Example: finding top 5 records from employee table
select * 
from 
	employee 
limit 5


-- 3> Write a SQL query to find the count of employees working in department 'Admin'
select 
	count(*)
from
	employee
where department = 'Admin'


-- 4> Write a SQL query to fetch department wise count employees sorted by 
--    department count in desc order.
select
	department,
	count(*)
from	
	employee
group by department
order by count(*) desc


-- 5>  Write a query to fetch only the first name(string before space) 
--     from the FullName column of user_name table.
select 
	split_part(full_names, ' ', 1) 
from user_name


-- 6> Write a SQL query to find all the employees 
--    from employee table who are also managers
select * from employee

select 
	manager.*
from
	employee e inner join employee manager
	on e.manager_id = manager.employee_id
	
-- 7> Write a SQL query to find all employees who have bonus record in bonus table

-- the results below can produce duplicate results if we do not do a group by
select 
	e.*
from
	employee e inner join bonus b 
	on e.employee_id = b.employee_ref_id
	
select * 
from 
	employee 
where employee_id 
	in (
		select employee_ref_id 
		from bonus 
		where employee.employee_id = bonus.employee_ref_id
	);


-- 8> Write a SQL query to find only odd rows from employee table
select * from employee where employee_id % 2 != 0


-- 9> Write a SQL query to fetch first_name from employee table in upper case
select upper(first_name) from employee


-- 10> Write a SQL query to get combine name (first name and last name) 
--     of employees from employee table
select first_name || ' ' || last_name as full_name from employee


-- 11> Write a SQL query to print details of employee of employee 'Jennifer' and 'James'.
select
	e.*
from 
	employee e
where 
	first_name = 'Jennifer' or first_name = 'James'


-- 12> Write a SQL query to fetch records of employee whose salary lies between 100000 and 500000
select
	e.*
from
	employee e
where salary between 100000 and 500000


-- 13> Write a SQL query to get records of employe who have joined in Jan 2017
-- 2 solutions for working with dates below
select
	e.*
from
	employee e
where 
	joining_date::date > '2017-01-01' and joining_date::date < '2017-02-01'

select 
	e.*
from employee e
where extract(year from joining_date) = 2017 and extract(month from joining_date) = 1


-- 14> Write a SQL query to get the list of employees with the same salary
create view emp_same_salary_count as 
select 
	salary,
	count(*)
from
	employee e
group by  salary;

select 
	e.*
from 
	emp_same_salary_count ec join employee e
	on ec.salary = e.salary
where ec.count > 1


-- another solution without using agg functions
select
	e1.first_name,
	e2.last_name
from
	employee e1, employee e2
where e1.salary = e2.salary and e1.employee_id != e2.employee_id


-- 15> Write a SQL query to show all departments along with the number of people working there. 
select
	department,
	count(*)
from
	employee
group by department


-- 16> Write a SQL query to show the last record from a table.
select * from employee where employee_id = (select max(employee_id) from employee)


-- 17> Write a SQL query to show the first record from a table.
select * from employee where employee_id = (select min(employee_id) from employee)


-- 18> Write a SQL query to get last five records from a employee table.
select
	*
from 
	employee e
order by e.employee_id desc
limit 5


-- 19> Write a SQL query to find employees having the highest salary in each department. 

select 
	e.first_name,
	e.last_name,
	salaries.department,
	salaries.maxsalary
from
(
	select
		department,
		max(salary) as maxsalary
	from
		employee e
	group by department
) salaries
inner join employee e
on e.salary = salaries.maxsalary


-- 20> Write a SQL query to fetch three max salaries from employee table.
create view salary_ranking as
select
	salary,
	rank() over(order by salary desc)
from
	employee;
	
select * from salary_ranking
where rank in (1,2,3)

-- another solution without using rank
select
	distinct salary
from employee 
order by salary desc
limit 3


-- 21> Write a SQL query to fetch departments along with the total salaries paid for each of them.
select
	department,
	sum(salary)
from
	employee
group by department


-- 22> Write a SQL query to find employee with highest salary in an organization from employee table.
select
	first_name,
	last_name,
	salary
from employee
where salary = (select max(salary) from employee)


-- 23>     Write an SQL query that makes recommendations using the  pages that your friends liked. 
-- Assume you have two tables: a two-column table of users and their friends, and a two-column table of 
-- users and the pages they liked. It should not recommend pages you already like.

-- user table columns
-- id int
-- friend_id

-- pages_liked table
-- user_id int,
-- pages_liked 


-- 24> write a SQL query to find employee (first name, last name, department and bonus) with highest bonus.
select
	e.first_name,
	e.last_name,
	e.department,
	b.bonus_amount
from
	employee e inner join bonus b
	on e.employee_id = b.employee_ref_id
where b.bonus_amount = (select max(bonus_amount) from bonus)


-- 25> write a SQL query to find employees with same salary
select
	e1.first_name,
	e2.last_name
from
	employee e1, employee e2
	where e1.salary = e2.salary and e1.employee_id != e2.employee_id
	
	
-- 26> Write SQL to find out what percent of students attend school 
-- on their birthday from attendance_events and all_students tables?

select
	count(students.*) * 100.0 / (select count(*) from all_students) as percent 
from
	all_students students inner join attendance_events events
	on students.student_id = events.student_id
where 
	students.date_of_birth::date = events.date_event::date and
	events.attendance = 'present'
	
-- 27> Given timestamps of logins, figure out how many people on Facebook were active all seven days
--  of a week on a mobile phone from login info table?

select
	count(*)
from
(
	select 
		user_id,
		date_trunc('week', login_time),
		count(distinct date_trunc('day', login_time)) as login_days
	from login_info
	group by date_trunc('week', login_time), user_id
) login_freq
where login_freq.login_days = 7





