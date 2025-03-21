--Checking for duplicates
with dub_cte as (
select 
Employee_Name,
row_number() over(PARTITION BY Employee_Name,
Employee_Name order by Employee_Name) as dub
from work.dbo.[hr data]
)
select *
from dub_cte
where dub > 1;

select *
from work.dbo.[hr data]


--Total Employees  by Employement status 
select  EmploymentStatus, count(Employee_Name) as Total_Emp, cast(count(Employee_Name) * 100 / sum(count(Employee_Name)) over() as DECIMAL(10,2)) as percentage
from work.dbo.[hr data]
group by EmploymentStatus

--Total Employees by Sex
select count(EmploymentStatus) as Total_Employee, cast(count(EmploymentStatus) * 100 / sum(count(EmploymentStatus)) over() AS DECIMAL(10,2)) AS percentage, Sex
from work.dbo.[hr data]
where EmploymentStatus like '%Active%'
group by Sex;


--Total Employees by department
select count(EmploymentStatus) as Total_Employee, Department
from work.dbo.[hr data]
where EmploymentStatus like '%Active%'
group by Department;

--Total Employees by position
select count(EmploymentStatus) as Total_Employee, Position
from work.dbo.[hr data]
where EmploymentStatus like '%Active%'
group by Position;


--Total Employees who have left the company by position
select count(EmploymentStatus) as Total_Employee_Attrition, Position
from work.dbo.[hr data]
where EmploymentStatus like '%Terminated%'
group by Position;

--Total Employees who have left the company by Sex
select count(EmploymentStatus) as Total_Employee_Attrition, Sex
from work.dbo.[hr data]
where EmploymentStatus like '%Terminated%'
group by Sex;


--Total Employees who have left the company by department
select count(EmploymentStatus) as Total_Employee_Attrition, Department
from work.dbo.[hr data]
where EmploymentStatus like '%Terminated%'
group by Department;


--peak years of Turnover
with count_cte as (
	select count(EmploymentStatus) as Nu_Empl_left, YEAR(DateofTermination) as Yr_left
	from work.dbo.[hr data]
	where EmploymentStatus like '%Terminated%'
	group by YEAR(DateofTermination)
)
select *
from count_cte

--years worked for terminated workers
select EmpID,Employee_Name,DateofHire,DateofTermination,DATEDIFF(YEAR,DateofHire,DateofTermination) as Years_Worked
from work.dbo.[hr data]
where DateofTermination is not null

--Years worked for active members 
select EmpID,Employee_Name,DateofHire,DateofTermination,DATEDIFF(YEAR,DateofHire, GETDATE()) as Active_Years_Worked
from work.dbo.[hr data]
where DateofTermination is  null

--Average years worked for active members 
select avg(DATEDIFF(YEAR,DateofHire, GETDATE())) as Act_Avg_Years_Worked
from work.dbo.[hr data]
where DateofTermination is  null;

--Average years worked for  members who have left  
select avg(DATEDIFF(YEAR,DateofHire, GETDATE())) as Avg_Years_Worked
from work.dbo.[hr data]
where DateofTermination is not null;

--Adding Employee last_name and first_name column 
ALTER TABLE work.dbo.[hr data]
ADD EmpLast_Name  varchar(max);

ALTER TABLE work.dbo.[hr data]
ADD EmpFirst_Name  varchar(max);

--Seperating employees name into first name and last name
with LasFi_cte as (
	select Employee_Name,
	trim(value) as r,
	row_number() over(PARTITION BY Employee_Name order by Employee_name) as rn
	from work.dbo.[hr data]
	cross apply string_split(Employee_Name, ',')
),
emp_cte as (
select Employee_Name,
max(case when rn = 1 then r end ) as EmpLast_Names,
max(case when rn = 2 then r end) as EmpFirst_Names
from LasFi_cte
group by Employee_Name
)

update t1
set t1.EmpLast_Name = t2.EmpLast_Names,
	t1.EmpFirst_Name = t2.EmpFirst_Names
from work.dbo.[hr data] t1
join emp_cte t2 
	on t1.Employee_Name = t2.Employee_Name


--Total EMployees salary 
select  sum(Salary) as Total_Salary_paid
from work.dbo.[hr data] 
where EmploymentStatus like '%Active'

--Total male and female salary
select  sum(Salary) as Total_Salary_paid, Sex
from work.dbo.[hr data] 
where EmploymentStatus like '%Active'
group by Sex


--Total salary for each dept
select Department,sum(Salary) as Total_Dept_salary,
ROW_NUMBER() over(partition by Department,sum(Salary) order by Department)
from work.dbo.[hr data]
where EmploymentStatus like '%Active'
group by Department
order by sum(Salary)  desc


--Average salary for each position 
select Position,avg(Salary) as Avg_Posi_salary,
ROW_NUMBER() over(partition by Position, avg(Salary) order by Position)
from work.dbo.[hr data]
where EmploymentStatus like '%Active'
group by Position
order by avg(Salary)  desc


--Total Employeee in each dept 
select Department, count(Sex)as Employee_Count,
ROW_NUMBER() over(partition by department, count(Sex) order by department) 
from work.dbo.[hr data]
where EmploymentStatus like '%Active'
group by Department


--Total male in each dept 
select Department, count(Sex)as Male_count,
ROW_NUMBER() over(partition by department, count(Sex) order by department) 
from work.dbo.[hr data]
where EmploymentStatus like '%Active' and Trim(Sex) like '%M'
group by Department


--Total female in each dept 
select Department, count(Sex)as Female_count,
ROW_NUMBER() over(partition by department, count(Sex) order by department) 
from work.dbo.[hr data]
where EmploymentStatus like '%Active' and Trim(Sex) like '%F'
group by Department






--Total employees(Female and male) who are married, single, widowed, divorced

	select  count(Employee_Name) as Total_Emp, MaritalDesc
	from work.dbo.[hr data]
	where EmploymentStatus like '%Active' 
	group by MaritalDesc
	



--which citizen are employed the most
select CitizenDesc, count(CitizenDesc) as citizens_count
from work.dbo.[hr data]
group by CitizenDesc
order by CitizenDesc desc


--managers and dept
select ManagerName, Department
from work.dbo.[hr data]
where EmploymentStatus like '%Active' 
group by ManagerName, Department


--Company Source of Recuirement
select RecruitmentSource, count(Employee_Name)as empl_count
from work.dbo.[hr data]
group by RecruitmentSource
order by count(Employee_Name) desc


--Dominated race
select RaceDesc, count(Employee_Name)as empl_count
from work.dbo.[hr data]
where EmploymentStatus like '%Active' 
group by RaceDesc
order by count(Employee_Name) desc





