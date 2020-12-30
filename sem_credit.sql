-- holds total credit of each semester
create table sem_credit(
	semester number,
	total_credit number,
	constraints pk_sem_credit primary key(semester)
);

INSERT into SEM_CREDIT values (1, 22);
INSERT into SEM_CREDIT values (2, 22.75);
INSERT into SEM_CREDIT values (3, 22.75);
INSERT into SEM_CREDIT values (4, 22.25);
INSERT into SEM_CREDIT values (5, 24.25);
INSERT into SEM_CREDIT values (6, 24.5);
INSERT into SEM_CREDIT values (7, 22.5);
INSERT into SEM_CREDIT values (8, 22.25);
