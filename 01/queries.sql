
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
	from 
		salary_ranking sr 
	where sr.rank = rank_num
	group by sr.salary;
	
	return nthRankingSalary;
end;
$$ language plpgsql;

select get_nth_highest_salary(7)


-- 2> Write a SQL query to find top n records?
-- Example: finding top 5 records from employee table