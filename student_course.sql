create table student_course(
	st_id number,
	course_id number,
	semester number,
	got_final number(1) default 0,
	got_mid number(1) default 0,
	got_quiz number(1) default 0,
	got_attendance number(1) default 0,
	total_marks number default 0,
	gpa number default 0,
	constraints pk_std_crse primary key(st_id, course_id),
	constraints fk_std_crse_std foreign key(st_id, semester) references student_sem,
	constraints fk_std_crse_course foreign key(course_id) references course
);

insert into student_course(st_id, course_id, semester) values(160041048, 4107, 1);
insert into student_course(st_id, course_id, semester) values(160041048, 4105, 1);
insert into student_course(st_id, course_id, semester) values(160041048, 4141, 1);
insert into student_course(st_id, course_id, semester) values(160041048, 4143, 1);
insert into student_course(st_id, course_id, semester) values(160041048, 4147, 1);
insert into student_course(st_id, course_id, semester) values(160041048, 4145, 1);
insert into student_course(st_id, course_id, semester) values(160041048, 4144, 1);
insert into student_course(st_id, course_id, semester) values(160041048, 4142, 1);
insert into student_course(st_id, course_id, semester) values(160041048, 4108, 1);
insert into student_course(st_id, course_id, semester) values(160041048, 4104, 1);


----------------------------------------------- Procedures/Functions -------------------------------------------------------------------

-- check if entered total_marks is more than the highest obtainable marks in a course set is_consistent to false otherwise set to true
create or replace procedure check_consistency(c_id in number, marks in number, is_consistent out boolean) as
	course_credit number;

	begin
		-- find credit of the course
		select credit into course_credit
			from course
			where course_id = c_id;

		-- if marks is greatar than 100% of course_mark
		if((course_credit * 100) < marks) then
			is_consistent := false; -- not consistent
		else
			is_consistent := true;
		end if;
	end;
/

-- check if all marks are available
create or replace procedure check_marks(sem_final in number, mid in number, quiz in number, att in number, is_present out boolean) as
	begin
		if(sem_final = 1 and mid = 1 and quiz = 1 and att=1) then
			is_present := true;
		else
			is_present := false;
		end if;
	end;
/


-- calculate total_gpa of a student in a particular semester

/* semester gpa will be calculated only if all the courses of a semester have been assigned total_marks
	otherwise the new_sem_gpa out variable will be 0
*/

-- formula for calculating sem_gpa: sum(gpa*credit)/sum(credit);

create or replace procedure calc_sem_gpa(id in number, sem in number, new_sem_gpa out boolean) as
	sem_total_course number;
	assigned_marks_course_count number;
	gpa_sum number;
	sem_total_credit number;
	
	begin
		select count(*) into sem_total_course
			from course
			where semester=sem;

		select count(*) into assigned_marks_course_count
			from STUDENT_COURSE
			where ST_ID=id and SEMESTER=sem and TOTAL_MARKS != 0;

		-- if marks of all courses are not assigned then dont't calculate semester_gpa
		if(assigned_marks_course_count < sem_total_course) then
			new_sem_gpa := 0;
		else		
			select sum(gpa * credit) into gpa_sum
				from student_course sc, course c
				where sc.st_id=id and sc.semester=sem and c.course_id=sc.COURSE_ID;
	
			select sum(credit) into sem_total_credit
				from course
				where semester=sem;
	
			new_sem_gpa := gpa_sum / sem_total_credit;
			
		end if;
	end;
/

-- calculate course_gpa from total_marks and credit of a particular course
create or replace procedure calc_course_gpa(c_id in number, marks in number, course_gpa out number) as

	course_credit number;
	percentage number;

	begin
		
		-- fetch course credit from course table
		select credit into course_credit
			from course
			where course_id = c_id;

		percentage := marks / course_credit;
		case
			when percentage >= 80 then course_gpa := 4.00;
			when percentage >= 75 and percentage < 80 then course_gpa := 3.75;
			when percentage >= 70 and percentage < 75 then course_gpa := 3.5;
			when percentage >= 65 and percentage < 70 then course_gpa := 3.25;
			when percentage >= 60 and percentage < 65 then course_gpa := 3.00;
			when percentage >= 55 and percentage < 60 then course_gpa := 2.75;
			when percentage >= 50 and percentage < 55 then course_gpa := 2.50;
			when percentage >= 45 and percentage < 50 then course_gpa := 2.25;
			when percentage >= 40 and percentage < 45 then course_gpa := 2.00;
			else course_gpa := 0.0;
		end case;
	end;
/

------------------------------------------------------- Trigger(s) --------------------------------------------------------

-- check validity of entered_marks
-- update the 'total_gpa' field on STUDENT_SEM table whenever the 'gpa' and 'total_marks' field is updated on STUDENT_COURSE field
-- and all the 'got' fields should be available i.e each of mid, final, quiz and attendance should be available to calculate and update the 'gpa' of a course
create or replace trigger update_total_gpa_trig
	for update of total_marks on student_course
	compound trigger

	new_st_id number;
	new_semester number;
	new_total_marks number;
	new_course_id number;
	new_got_final number(1);
	new_got_mid number(1);
	new_got_quiz number(1);
	new_got_attendance number(1);
	go_on boolean;

	before each row is
	is_consistent boolean;
	begin
		new_st_id := :new.st_id;
		new_semester := :new.semester;
		new_total_marks := :new.total_marks;
		new_course_id := :new.course_id;
		new_got_final := :new.got_final;
		new_got_mid := :new.got_mid;
		new_got_quiz := :new.got_quiz;
		new_got_attendance := :new.got_attendance;

		-- check if marks entered is consistent with course_credit
		check_consistency(new_course_id, new_total_marks, is_consistent);
		if(not is_consistent) then
			dbms_output.put_line('Invalid total marks. Please Correct');
			:new.total_marks := 0;
			:new.got_final := 0;
			:new.got_mid := 0;
			:new.got_quiz := 0;
			:new.got_attendance := 0;
			go_on := false;
		else
			go_on := true;
		end if;
	end before each row;

	after statement is

	new_sem_gpa number;
	new_course_gpa number;
	all_marks_is_present boolean;

	begin

		if(not go_on) then
			NULL;
		else
			-- check if all marks are present
			check_marks(new_got_final, new_got_mid, new_got_quiz, new_got_attendance, all_marks_is_present);
	
			-- if not present do nothing
			if(not all_marks_is_present) then
				dbms_output.put_line('All marks of the course are not present');
			else
				calc_course_gpa(new_course_id, new_total_marks, new_course_gpa);
			
				-- update gpa of a particular course in student_course table based on total marks
				update student_course
					set gpa = new_course_gpa
					where st_id = new_st_id and course_id = new_course_id;
			
				-- calculate total gpa of a semester from all the course_gpa's of that semester
				calc_sem_gpa(new_st_id, new_semester, new_sem_gpa);
	
				-- new_sem_gpa will be 0 if all courses are not assigned
				-- in that case, we won't update student_sem table
				if(new_sem_gpa = 0) then
					dbms_output.put_line('All courses dont have assigned gpas');
				else		
				-- update STUDENT_SEM table
					update student_sem
						set total_gpa = new_sem_gpa
						where st_id = new_st_id and semester = new_semester;
				end if;
			end if;
		end if;
	end after statement;
end update_total_gpa_trig;
/

update STUDENT_COURSE set TOTAL_MARKS=240,GOT_FINAL=1,GOT_MID=1,GOT_QUIZ=1,GOT_ATTENDANCE=1 WHERE ST_ID=160041048 and COURSE_ID=4105 and SEMESTER=1; 
update STUDENT_COURSE set TOTAL_MARKS=240,GOT_FINAL=1,GOT_MID=1,GOT_QUIZ=1,GOT_ATTENDANCE=1 WHERE ST_ID=160041048 and COURSE_ID=4107 and SEMESTER=1; 
update STUDENT_COURSE set TOTAL_MARKS=240,GOT_FINAL=1,GOT_MID=1,GOT_QUIZ=1,GOT_ATTENDANCE=1 WHERE ST_ID=160041048 and COURSE_ID=4141 and SEMESTER=1; 
update STUDENT_COURSE set TOTAL_MARKS=340,GOT_FINAL=1,GOT_MID=1,GOT_QUIZ=1,GOT_ATTENDANCE=1 WHERE ST_ID=160041048 and COURSE_ID=4143 and SEMESTER=1; 
update STUDENT_COURSE set TOTAL_MARKS=240,GOT_FINAL=1,GOT_MID=1,GOT_QUIZ=1,GOT_ATTENDANCE=1 WHERE ST_ID=160041048 and COURSE_ID=4147 and SEMESTER=1; 
update STUDENT_COURSE set TOTAL_MARKS=170,GOT_FINAL=1,GOT_MID=1,GOT_QUIZ=1,GOT_ATTENDANCE=1 WHERE ST_ID=160041048 and COURSE_ID=4145 and SEMESTER=1; 
update STUDENT_COURSE set TOTAL_MARKS=85,GOT_FINAL=1,GOT_MID=1,GOT_QUIZ=1,GOT_ATTENDANCE=1 WHERE ST_ID=160041048 and COURSE_ID=4144 and SEMESTER=1; 
update STUDENT_COURSE set TOTAL_MARKS=60,GOT_FINAL=1,GOT_MID=1,GOT_QUIZ=1,GOT_ATTENDANCE=1 WHERE ST_ID=160041048 and COURSE_ID=4142 and SEMESTER=1; 
update STUDENT_COURSE set TOTAL_MARKS=120,GOT_FINAL=1,GOT_MID=1,GOT_QUIZ=1,GOT_ATTENDANCE=1 WHERE ST_ID=160041048 and COURSE_ID=4108 and SEMESTER=1; 
update STUDENT_COURSE set TOTAL_MARKS=60,GOT_FINAL=1,GOT_MID=1,GOT_QUIZ=1,GOT_ATTENDANCE=1 WHERE ST_ID=160041048 and COURSE_ID=4104 and SEMESTER=1; 

update STUDENT_COURSE set TOTAL_MARKS=0,GOT_FINAL=0,GOT_MID=0,GOT_QUIZ=0,GOT_ATTENDANCE=0, GPA=0; 