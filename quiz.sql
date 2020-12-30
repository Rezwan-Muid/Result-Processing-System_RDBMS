create table quiz(
	st_id number,
	course_id number,
	quiz_1 number,
	quiz_2 number,
	quiz_3 number,
	quiz_4 number,
	update_total_marks number(1), -- quiz mark will only be added to total_marks when this field is set to 1
	constraints pk_quiz primary key(st_id, course_id),
	constraints fk_quiz_std_crse foreign key(st_id, course_id) references student_course
);

insert into quiz(st_id, course_id) values(160041048, 4107);
insert into quiz(st_id, course_id) values(160041048, 4105);
insert into quiz(st_id, course_id) values(160041048, 4141);
insert into quiz(st_id, course_id) values(160041048, 4143);
insert into quiz(st_id, course_id) values(160041048, 4147);
insert into quiz(st_id, course_id) values(160041048, 4145);
insert into quiz(st_id, course_id) values(160041048, 4144);
insert into quiz(st_id, course_id) values(160041048, 4142);
insert into quiz(st_id, course_id) values(160041048, 4108);
insert into quiz(st_id, course_id) values(160041048, 4104);	

----------------------------------------------- Procedures/Functions -------------------------------------------------------------------

create or replace procedure add_best_3_of_4(s_id in number, c_id in number, best out number) as
	q_1 number;
	q_2 number;
	q_3 number;
	q_4 number; 
	s_123 number;
	s_124 number;
	s_234 number;
	s_134 number;

	begin
		
		select quiz_1, quiz_2, quiz_3, quiz_4 into q_1, q_2, q_3, q_4
			from QUIZ
			where ST_ID=s_id and COURSE_ID=c_id;

		s_123 := q_1 + q_2 + q_3;
		s_124 := q_1 + q_2 + q_4;
		s_234 := q_2 + q_3 + q_4;
		s_134 := q_1 + q_3 + q_4;

		case
			when s_123 >= s_124 and s_123 >= s_234 and s_123 >= s_134 then best := s_123;
			when s_124 >= s_123 and s_124 >= s_234 and s_124 >= s_134 then best := s_124;
			when s_234 >= s_124 and s_234 >= s_123 and s_234 >= s_134 then best := s_234;
			else best := s_134;
		end case;
	end;
/

create or replace trigger update_quiz_trig
	for update of update_total_marks on quiz
	compound trigger
	
	go_on boolean;
	new_st_id number;
	new_course_id number;

	after each row is
	begin
		if(:new.update_total_marks = 1) then
			new_st_id := :new.st_id;
			new_course_id := :new.course_id;
			go_on := true;
		else
			go_on := false;
		end if;
	end after each row;

	after statement is
	total_quiz_marks number;
	begin
		if(not go_on) then
			dbms_output.put_line('update_total_marks not set');
		else
			add_best_3_of_4(new_st_id, new_course_id, total_quiz_marks);
			dbms_output.put_line('quiz marks:' || total_quiz_marks);
			update student_course
				set total_marks = total_marks + total_quiz_marks,
					got_quiz = 1
				where st_id = new_st_id and course_id = new_course_id;
		end if;		
	end after statement;
end update_quiz_trig;
/

update quiz set QUIZ_1=13, QUIZ_2=12, QUIZ_3=11, QUIZ_4=12 where ST_ID=160041048 and COURSE_ID=4105;
update QUIZ set UPDATE_TOTAL_MARKS=1 where ST_ID=160041048 and COURSE_ID=4105;



update quiz set QUIZ_1=0, QUIZ_2=0, QUIZ_3=0, QUIZ_4=0;