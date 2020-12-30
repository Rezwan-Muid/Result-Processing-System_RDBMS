create table sem_final(
	st_id number,
	course_id number,
	marks number default 0,
	constraints pk_sem_final primary key(st_id, course_id),
	constraints fk_sem_final_std_crse foreign key(st_id, course_id) references student_course
);

insert into sem_final(st_id, course_id) values(160041048, 4107);
insert into sem_final(st_id, course_id) values(160041048, 4105);
insert into sem_final(st_id, course_id) values(160041048, 4141);
insert into sem_final(st_id, course_id) values(160041048, 4143);
insert into sem_final(st_id, course_id) values(160041048, 4147);
insert into sem_final(st_id, course_id) values(160041048, 4145);
insert into sem_final(st_id, course_id) values(160041048, 4144);
insert into sem_final(st_id, course_id) values(160041048, 4142);
insert into sem_final(st_id, course_id) values(160041048, 4108);
insert into sem_final(st_id, course_id) values(160041048, 4104);


----------------------------------------------- Procedures/Functions -------------------------------------------------------------------

-- check if entered final_marks is more than the highest obtainable final_marks in a course set is_consistent to false otherwise set to true
create or replace procedure check_final_marks_validity(c_id in number, new_marks in number, is_consistent out boolean) as

course_credit number;

	begin
		-- find credit of the course
		select credit into course_credit
			from course
			where course_id = c_id;

		-- if marks is greatar than 50% of course_mark
		if((course_credit * 50) < new_marks) then
			is_consistent := false; -- not consistent
		else
			is_consistent := true;
		end if;
	end;
/

------------------------------------------------------- Trigger(s) --------------------------------------------------------

-- first check the validity of entered marks
-- on validation, trigger will update the 'got_final' and 'total_marks' field in student_course whenever new mark is entered

create or replace trigger update_final_marks_trig
	before update of marks on sem_final
	for each row

	declare
	new_st_id number;
	new_final_marks number;
	new_course_id number;
	is_consistent boolean;
	begin
		new_st_id := :new.st_id;
		new_final_marks := :new.marks;
		new_course_id := :new.course_id;
		
		-- check if marks entered is consistent with course_credit
		check_final_marks_validity(new_course_id, new_final_marks, is_consistent);
		if(not is_consistent) then
			dbms_output.put_line('Invalid final marks. Please Correct');
			:new.marks := 0;
			
		else
			update student_course
				set total_marks = total_marks + new_final_marks,
					got_final = 1
				where st_id = new_st_id and course_id = new_course_id;
		end if;	
end update_final_marks_trig;
/

-- invalid marks
update sem_final set MARKS=170 where ST_ID=160041048 and COURSE_ID=4107;	

-- valid marks
			