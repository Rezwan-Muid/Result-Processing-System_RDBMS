-- holds info about the courses
create table course(
	course_id number,
	course_name varchar2(40),
	semester number,
	credit number,
	constraints pk_course primary key(course_id)
	);


insert into course values (4105, 'Computing for Engineers', 3);
insert into course values (4107, 'Structured Programming I', 3);
insert into course values (4141, 'Physics I', 3);
insert into course values (4143, 'Geometry and Differential Calculus', 4);
insert into course values (4147, 'Technology, Environment and Society', 3);
insert into course values (4145, 'Islamiat', 2);
insert into course values (4144, 'Arabic I', 1);
insert into course values (4142, 'Physics I Lab', 0.75);
insert into course values (4108, 'Structured Programming I Lab', 1.5);
insert into course values (4104, 'Engineering Drawing Lab', 0.75);
