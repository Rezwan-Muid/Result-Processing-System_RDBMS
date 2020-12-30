-- holds semester-wise gpa of a student
create table student_sem(
	st_id number,
	semester number,
	total_gpa number default 0,
	constraints pk_student_sem primary key(st_id, semester),
	constraints fk_student_sem_student foreign key(st_id) references student
	);



insert into student_sem(st_id, semester) values (160041048, 1);
insert into student_sem(st_id, semester) values (160041048, 2);
insert into student_sem(st_id, semester) values (160041048, 3);
insert into student_sem(st_id, semester) values (160041048, 4);
insert into student_sem(st_id, semester) values (160041048, 5);
insert into student_sem(st_id, semester) values (160041048, 6);
insert into student_sem(st_id, semester) values (160041048, 7);
insert into student_sem(st_id, semester) values (160041048, 8);



-------------------------------- Procedures/Functions ----------------------------------------------

-- calculate cgpa from total_gpa of all semesters
-- formula for calculating cgpa: sum(total_gpa*total_credit)/sum(total_credit);

create or replace procedure calc_cgpa(id in number, new_cgpa out number) as
	passed_sem number;
	sem_total_credit number;
	sem_total_gpa number;
	total_credit_sum number;
	total_gpa_credit_sum number;

	begin
		-- find number of passed semesters
		select count(*) into passed_sem 
			from student_sem
			where st_id = id and total_gpa != 0;

		/* for each of the passed semesters, find total credit of those semesters
		   and then calculate the cgpa
		*/
		total_credit_sum := 0;
		total_gpa_credit_sum := 0;
		for i in 1 .. passed_sem loop
			select sum(credit) into sem_total_credit
				from course
				where semester=i;

			-- sum(total_credit)
			total_credit_sum := total_credit_sum + sem_total_credit;

			select total_gpa into sem_total_gpa
				from student_sem
				where st_id = id and SEMESTER=i;

			-- sum(total_gpa*total_credit)
			total_gpa_credit_sum := total_gpa_credit_sum + (sem_total_credit * sem_total_gpa);
		end loop;
		
		if(passed_sem != 0) then
			new_cgpa := total_gpa_credit_sum / sem_total_credit;
		else
			new_cgpa := 0;
		end if;
	end;
/
-------------------------------- Trigger(s) --------------------------------------------------------

-- update the 'cgpa' field on STUDENT table whenever the 'total_gpa' field is updated on STUDENT_SEM field
create or replace trigger update_cgpa_trig
	for update on student_sem
	compound trigger

	new_st_id number;

	after each row is

	begin
		new_st_id := :new.st_id;  
	end after each row;

	after statement is

	new_cgpa number;

	begin
		calc_cgpa(new_st_id, new_cgpa);

		-- update STUDENT table
		update student
		set cgpa=new_cgpa
		where id=new_st_id;
		
	end after statement;
end update_cgpa_trig;
/
show errors;

update STUDENT_SEM set TOTAL_GPA=3.97 where ST_ID=160041048 and SEMESTER=1;
