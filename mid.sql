create table mid(
	st_id number,
	course_id number,
	marks number default 0,
	constraints pk_mid primary key(st_id, course_id),
	constraints fk_mid_std_crse foreign key(st_id, course_id) references student_course
);

insert into mid(st_id, course_id) values(160041048, 4107);
insert into mid(st_id, course_id) values(160041048, 4105);
insert into mid(st_id, course_id) values(160041048, 4141);
insert into mid(st_id, course_id) values(160041048, 4143);
insert into mid(st_id, course_id) values(160041048, 4147);
insert into mid(st_id, course_id) values(160041048, 4145);
insert into mid(st_id, course_id) values(160041048, 4144);
insert into mid(st_id, course_id) values(160041048, 4142);
insert into mid(st_id, course_id) values(160041048, 4108);
insert into mid(st_id, course_id) values(160041048, 4104);

----------------------------------------------- Procedures/Functions -------------------------------------------------------------------
-- check if entered mid_marks is more than the highest obtainable mid_marks in a course set is_consistent to false otherwise set to true
create or replace procedure check_mid_marks_validity(c_id in number, new_marks in number, is_consistent out boolean) as

course_credit number;

	begin
		-- find credit of the course
		select credit into course_credit
			from course
			where course_id = c_id;

		-- if marks is greatar than 25% of course_mark
		if((course_credit * 25) < new_marks) then
			is_consistent := false; -- not consistent
		else
			is_consistent := true;
		end if;
	end;
/

------------------------------------------------------- Trigger(s) --------------------------------------------------------

-- first check the validity of entered marks
-- on validation, trigger will update the 'got_mid' and 'total_marks' field in student_course whenever new mark is entered

create or replace trigger update_mid_marks_trig
	before update of marks on mid
	for each row

	declare
	new_st_id number;
	new_mid_marks number;
	new_course_id number;
	is_consistent boolean;
	begin
		new_st_id := :new.st_id;
		new_mid_marks := :new.marks;
		new_course_id := :new.course_id;
		
		-- check if marks entered is consistent with course_credit
		check_mid_marks_validity(new_course_id, new_mid_marks, is_consistent);
		if(not is_consistent) then
			dbms_output.put_line('Invalid mid marks. Please Correct');
			:new.marks := 0;
		else
			update student_course
				set total_marks = total_marks + new_mid_marks,
					got_mid = 1
				where st_id = new_st_id and course_id = new_course_id;
		end if;

end update_mid_marks_trig;
/

-- invalid marks
update mid set MARKS=170 where ST_ID=160041048 and COURSE_ID=4107;
