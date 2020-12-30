# Result-Processing-System_RDBMS

1. Project Background:
The main objective of this project is to demonstrate our knowledge on SQL specially Oracle PL/SQL. With this end in view, we have done a heavy use of PL/SQL in our project.
We have designed our project to both show our learning from the course and to implement a functional database system for result processing of students in the university.

2. Project Description:
In our project there are in total 8 schema tables that are all inter-connected.  Associated with each table, there are procedures and triggers that smoothly update the marks and corresponding GPA's of students.
We have used compound triggers that were recently introduced in Oracle from version 11g to have our way around the mutating-table errors.
The flow of our system is such that whenever the quiz or mid_semester or semester_final or attendance information of a particular student in a particular course are updated in their corresponding table, the total marks of that student are also updated automatically using triggers. And when all course marks have been updated, the total_gpa of that semester and also the CGPA is automatically updated using triggers.
We also used a bunch of procedures to assist the triggers in calculations and to make a readable code structure. Also we have made good use of loops and if-else blocks to maintain a smooth flow in our project. In addition, we have well commented the codes so that everyone who reads the code will find an easy time understanding the code.
To calculate grades, we have followed the grading system of IUT.

3. List of Procedures:
	Calc_cgpa(id in number, new_cgpa out number)
	check_consistency(c_id in number, marks in number, is_consistent out boolean)
	check_marks(sem_final in number, mid in number, quiz in number, att in number, is_present out boolean)
	calc_sem_gpa(id in number, sem in number, new_sem_gpa out boolean)
	calc_course_gpa(c_id in number, marks in number, course_gpa out number)
	check_final_marks_validity
	check_mid_marks_validity(c_id in number, new_marks in number, is_consistent out boolean)
	calc_att(c_id in number, total_class in number, presence in number, att_marks out number)
	add_best_3_of_4(s_id in number, c_id in number, best out number)

4. List of Triggers:
	update_cgpa_trig
	update_total_gpa_trig
	update_final_marks_trig
	update_mid_marks_trig
	update_att_trig
	update_quiz_trig


