create table attendance(
	st_id number,
	course_id number,
	total_class number default 0,
	present_cnt number default 0,
	att_marks number default 0,
	constraints pk_att primary key(st_id, course_id),
	constraints fk_att_std_crse foreign key(st_id, course_id) references student_course
);

insert into attendance(st_id, course_id) values(160041048, 4107);
insert into attendance(st_id, course_id) values(160041048, 4105);
insert into attendance(st_id, course_id) values(160041048, 4141);
insert into attendance(st_id, course_id) values(160041048, 4143);
insert into attendance(st_id, course_id) values(160041048, 4147);
insert into attendance(st_id, course_id) values(160041048, 4145);
insert into attendance(st_id, course_id) values(160041048, 4144);
insert into attendance(st_id, course_id) values(160041048, 4142);
insert into attendance(st_id, course_id) values(160041048, 4108);
insert into attendance(st_id, course_id) values(160041048, 4104);

----------------------------------------------- Procedures/Functions -------------------------------------------------------------------

/* formula for finding attendance:
		(presence/total_class) * (credit * 10)
*/
create or replace procedure calc_att(c_id in number, total_class in number, presence in number, att_marks out number) as
	course_credit number;

	begin
		select credit into course_credit
			from course
			where course_id = c_id;

		att_marks := (presence / total_class) * (course_credit * 10);
	end;
/

------------------------------------------------------- Trigger(s) --------------------------------------------------------

-- on validation of entered attendence info, find attendance marks and add that to the total_marks in student_course table and set got_attendance to 1
create or replace trigger update_att_trig
	before update on attendance
	for each row

	declare
	attendance_marks number;

begin
		if(:new.total_class < :new.present_cnt) then
			dbms_output.put_line('presence can not be greater than total class');
			:new.total_class := 0;
			:new.present_cnt := 0;
		else
			calc_att(:new.course_id, :new.total_class, :new.present_cnt, attendance_marks);
			
			:new.att_marks := attendance_marks;

			update student_course
				set total_marks = total_marks + attendance_marks,
					got_attendance = 1
				where st_id = :new.st_id and course_id = :new.course_id;
		end if;
end update_att_trig;
/

-- invalid marks
update ATTENDANCE set TOTAL_CLASS=15,PRESENT_CNT=30 WHERE ST_ID=160041048 and COURSE_ID=4107;

-- valid marks
update ATTENDANCE set TOTAL_CLASS=30,PRESENT_CNT=15 WHERE ST_ID=160041048 and COURSE_ID=4107;
	