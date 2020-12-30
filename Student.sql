-- holds info about a student
Create table student(
	id number,
	name varchar2(20),
	dept varchar2(10),
	cgpa number default 0,
	constraints pk_student primary key(id)
	);
	

insert into student(id, name, dept) values(160041048, 'Imtiaj', 'CSE');
insert into student(id, name, dept) values(160041046, 'Ziad', 'CSE');
insert into student(id, name, dept) values(160041057, 'Rezwan', 'CSE');
insert into student(id, name, dept) values(160041010, 'Zahid', 'CSE');
insert into student(id, name, dept) values(160041002, 'Farabi', 'CSE');

-------------------------------- Procedures/Functions ----------------------------------------------



-------------------------------- Trigger(s) --------------------------------------------------------

