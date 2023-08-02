
/*Creating a University Model Database*/
CREATE DATABASE UniversityModel;
GO
/*There are total of 17 tables*/

/* Creating all tables */

USE UniversityModel
GO



CREATE TABLE UniversityCampus(
CampusID int not null Identity(200,1),
CampusName varchar(30),
CampusLocation varchar(30) CHECK (CampusLocation IN ('Boston','Gainsville','Chicago','Long Beach','Raleigh','Buffalo','Rochester','New York City','Madison','Seattle')),
CONSTRAINT University_Campus_PK PRIMARY KEY (CampusID)
);

CREATE TABLE CourseOffering(
    CourseID INT NOT NULL identity(6000,1),
    CourseName NVARCHAR(80),
    CourseDescription VARCHAR(300),
    Credits INT NOT NULL,
    CourseType NVARCHAR(45) CHECK(CourseType IN('InPerson', 'Online'))
    CONSTRAINT COURSE_OFFERING_PK PRIMARY KEY(CourseID)
);

/*alter table Courseoffering alter column CourseDescription nvarchar(150);*/


CREATE TABLE CourseCatalog(
CourseID int not null,
CampusID int not null,
RevisionDate Date,
AcademicTerm varchar(20) CHECK(AcademicTerm IN ('Fall', 'Spring', 'Summer')),
CONSTRAINT CourseCatalog_PK1 PRIMARY KEY (CourseID, CampusID),
CONSTRAINT CourseCatalog_FK1 FOREIGN KEY (CourseID) REFERENCES CourseOffering(CourseID)
);



CREATE TABLE Section(
    SectionID INT NOT NULL identity(1,1),
    [Location] NVARCHAR(30)
    CONSTRAINT SECTION_PK PRIMARY KEY(SectionID)
);



CREATE TABLE Department(
    DepartmentID INT NOT NULL identity(1000,1),
    DepartmentName NVARCHAR(30)
    CONSTRAINT DEPARTMENT_PK PRIMARY KEY(DepartmentID)
);


CREATE TABLE Advisor(
    AdvisorID INT NOT NULL IDENTITY(101,1),
    DepartmentID INT,
    AdvisorName NVARCHAR(30)
    CONSTRAINT ADVISOR_PK PRIMARY KEY(AdvisorID),
    CONSTRAINT ADVISOR_FK FOREIGN KEY(DepartmentID) REFERENCES DEPARTMENT(DepartmentID)
);


CREATE TABLE Student(
    StudentID INT NOT NULL identity(100,1),
    SectionID INT,
    AdvisorID INT,
    StudentName NVARCHAR(80),
    Semester int,
    CONSTRAINT STUDENT_PK  PRIMARY KEY(StudentID),
    CONSTRAINT STUDENT_FK1 FOREIGN KEY(SectionID) REFERENCES Section(SectionID),
    CONSTRAINT STUDENT_FK2 FOREIGN KEY(AdvisorID) REFERENCES Advisor(AdvisorID)
);


CREATE TABLE CourseRegistration(
    RegID INT NOT NULL,
    RegStatus NVARCHAR(30),
    RegDate DATE,
    CourseID INT,
    StudentID INT,
    CONSTRAINT COURSE_REGISTRATION_PK  PRIMARY KEY(RegID),
    CONSTRAINT COURSE_REGISTRATION_FK1 FOREIGN KEY(CourseID) REFERENCES CourseOffering(CourseID),
    CONSTRAINT COURSE_REGISTRATION_FK2 FOREIGN KEY(StudentID) REFERENCES Student(StudentID)
);

CREATE TABLE Staff (
StaffID int not null identity(300,1),
StaffName varchar(30),
StaffType varchar(5) CHECK (StaffType IN ('P','C')),
CONSTRAINT Staff_PK PRIMARY KEY (StaffID)
);

CREATE TABLE StaffPermanent(
PStaffID int not null,
Salary int,
CONSTRAINT StaffPermanent_PK PRIMARY KEY (PStaffID),
CONSTRAINT StaffPermanent_FK FOREIGN KEY (PStaffID) REFERENCES Staff(StaffID)
);

CREATE TABLE StaffContract(
CStaffID int not null,
HourlyRate decimal(4,2),
CONSTRAINT StaffContract_PK PRIMARY KEY (CStaffID),
CONSTRAINT StaffContract_FK FOREIGN KEY (CStaffID) REFERENCES Staff(StaffID)
);


Create TABLE Professor(
ProfessorID int not null identity(500,1),
DepartmentID int,
ProfessorName VARCHAR(40),
[Location] VARCHAR(20),
ProfessorType VARCHAR (20) CHECK (ProfessorType IN ('P','C')),
CONSTRAINT Professor_PK primary key (ProfessorID),
CONSTRAINT Professor_FK FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID)
);



Create Table ProfPermanent(
PProfID int not null,
Salary int,
CONSTRAINT ProfPermanent_PK PRIMARY KEY (PProfID),
CONSTRAINT ProfPermanent_FK FOREIGN KEY (PProfID) REFERENCES Professor(ProfessorID)
);

Create table ProfContract(
CProfID int not null,
HourlyRate decimal(4,2),
CONSTRAINT contract_PK primary key (CProfID),
CONSTRAINT contract_FK FOREIGN KEY (CProfID) REFERENCES Professor(ProfessorID)
);

create TABLE Teaches(
CourseID int not NULL,
ProfessorID int not null,
Semester VARCHAR(15),
Term VARCHAR(10) CHECK(Term IN ('Fall', 'Spring', 'Summer')),
CONSTRAINT Teaches_PK primary key (CourseID,ProfessorID),
CONSTRAINT Teaches_FK1 FOREIGN KEY (CourseID) REFERENCES CourseOffering(CourseID),
CONSTRAINT Teaches_FK2 FOREIGN KEY (ProfessorID) REFERENCES Professor(ProfessorID)
);

CREATE TABLE Building(  
 BuildingID INT NOT NULL identity(800,1),  
 BuildingName VARCHAR(45),  
 BuildingLocation VARCHAR(45), 
 CampusID INT, 
 DepartmentID INT,  
 CONSTRAINT BUILDING_PK PRIMARY KEY(BuildingID),  
 CONSTRAINT BUILDING_FK1 FOREIGN KEY(CampusID) REFERENCES UniversityCampus(CampusID),  
 CONSTRAINT BUILDING_FK2 FOREIGN KEY(DepartmentID) REFERENCES Department(DepartmentID) 
 );



 /*Computed Columns based on a function
 A computed column to determine the grade from the cgpa*/
 Go
 CREATE FUNCTION CGPAToGrade(@cgpa decimal(3,2))
 RETURNS char(2)
 AS
 BEGIN
	 DECLARE @res varchar(20)
	 SELECT @res=  CASE WHEN (@cgpa>3.9 and @cgpa<=4) THEN 'A' 
	 WHEN (@cgpa<3.9 AND @cgpa>3.7) THEN  'A-' 
	 WHEN (@cgpa>3.5 AND @cgpa<3.7)  THEN'B' 
	 WHEN (@cgpa>3.2 AND @cgpa<3.5) THEN 'C' 
	 WHEN (@cgpa>2.5 AND @cgpa<3.2) THEN  'D' 
	 ELSE 'F'
	 END
	 RETURN @res
 END
 Go

 CREATE TABLE Grades(  
 CourseID INT NOT NULL,
 StudentID INT NOT NULL,  
 CGPA decimal(3,2) CHECK(CGPA<=4.00),  
 Result VARCHAR(45),
 Grade as dbo.CGPAToGrade(CGPA) /*Computed Columns based on a function*/
 CONSTRAINT GRADES_PK PRIMARY KEY(CourseID,StudentID),  
 CONSTRAINT GRADES_FK1 FOREIGN KEY(CourseID) REFERENCES COURSEOFFERING(CourseID),  
 CONSTRAINT GRADES_FK2 FOREIGN KEY(StudentID) REFERENCES STUDENT(StudentID) 
 )


 /*TRIGGERS*/

/*Creating a trigger to log any updates to the existing grades
Creating a audit trail table for 'Grades'*/
GO
CREATE TABLE GradesChange(  
 CourseID INT NOT NULL,
 StudentID INT NOT NULL,  
 CGPA decimal(3,2),  
 Result VARCHAR(45), 
 Grade VARCHAR(20),
 [Action] [char],
 [ActionDate] datetime
 );
 GO


/*GradeChange trigger*/
 
CREATE TRIGGER GradeChge on Grades
FOR UPDATE
AS
BEGIN
IF UPDATE(CGPA)
INSERT INTO [dbo].[GradesChange]
           ([CourseID]
           ,[StudentID]
           ,[CGPA]
           ,[Result]
		   ,[Grade]
           ,[Action]
           ,[ActionDate])
     SELECT [CourseID]
           ,[StudentID]
           ,[CGPA]
           ,[Result]
		   , [Grade]
           ,'U' as [Action]
           ,getdate() as [ActionDate]
		   from deleted
END
GO

/*Creating a trigger to log any new insertions into Grades table*/

CREATE TRIGGER GradeInsert on Grades
FOR INSERT
AS
BEGIN
INSERT INTO [dbo].[GradesChange]
           ([CourseID]
           ,[StudentID]
           ,[CGPA]
           ,[Result]
		   ,[Grade]
           ,[Action]
           ,[ActionDate])
     SELECT [CourseID]
           ,[StudentID]
           ,[CGPA]
           ,[Result]
		   , [Grade]
           ,'I' as [Action]
           ,getdate() as [ActionDate]
		   from inserted
END
GO

/*Creating a trigger to log any new insertions into the Course Registration Table*/

/*Creating a CourseRegistrationInsert Table*/

CREATE TABLE CourseRegistrationInsert(
    RegID INT NOT NULL,
    RegStatus NVARCHAR(30),
    RegDate DATE,
    CourseID INT,
    StudentID INT,
	[Action] [char],
	[ActionDate] datetime
  );
GO
/*Trigger for Course Registration*/
/*when a record gets inserted into course registration...*/
CREATE TRIGGER CourseRegInsert  on CourseRegistration
FOR INSERT
AS
BEGIN
INSERT INTO [dbo].[CourseRegistrationInsert]
           ([RegID]
           ,[RegStatus]
           ,[RegDate]
           ,[CourseID]
           ,[StudentID]
           ,[Action]
           ,[ActionDate])
	SELECT [RegID]
           ,[RegStatus]
           ,[RegDate]
           ,[CourseID]
           ,[StudentID]
           ,'I' as [Action]
           ,getdate()  as [ActionDate]
		   from inserted
END
Go

/*when a record gets updated in course registration...*/
CREATE TRIGGER CourseRegUpdate  on CourseRegistration
FOR Update
AS
BEGIN
INSERT INTO [dbo].[CourseRegistrationInsert]
           ([RegID]
           ,[RegStatus]
           ,[RegDate]
           ,[CourseID]
           ,[StudentID]
           ,[Action]
           ,[ActionDate])
	SELECT [RegID]
           ,[RegStatus]
           ,[RegDate]
           ,[CourseID]
           ,[StudentID]
           ,'U' as [Action]
           ,getdate()  as [ActionDate]
		   from deleted
END

/*VIEWS*/

/*Using a centralized database to track overall student�s academic performance regardless of the department
they belong to and determine the list of students with lower grades. This will help the University and
the Professors to focus more on these students and look at ways to assist them.*/

Go
CREATE VIEW StudentsWithLowGrades AS

SELECT d.DepartmentID, s.StudentID, s.SectionID, s.StudentName, g.CourseID, g.CGPA,g.Result, co.CourseName, co.CourseType, t.Semester, p.ProfessorID,p.ProfessorName, d.DepartmentName 
FROM student s 
LEFT JOIN Grades g ON s.StudentID = g.StudentID 
LEFT JOIN CourseOffering co ON g.CourseID = co.CourseID
LEFT JOIN Teaches t ON co.CourseID = t.CourseID
LEFT JOIN Professor p ON t.ProfessorID = p.ProfessorID
LEFT JOIN Department d ON p.DepartmentID = d.DepartmentID
WHERE g.Result = 'Fail';

/*Determine the number of courses handled by Professors and ensure that sections per course 
is evenly split between Professors. Also, determine the number of sections required based on course registrations.*/

Go
CREATE VIEW NumberofCoursesByProfessors AS

select p.professorID, p.professorName, COUNT(t.CourseID) as CountOfCourses from teaches t
join professor p on t.ProfessorID = p.ProfessorID
group by p.professorID, p.professorName;

/*Making sure each student is assigned an advisor. Having a centralized database, gives 
the student flexibility to choose an Academic Advisor (from any Department) or a counsellor they are comfortable with.*/
Go

CREATE VIEW NoOfStudentsAssignedbyAdvisor AS
Select a.advisorid, a.advisorname,a.departmentid, count(studentid) NoOfStudents from student s
left join advisor a on a.advisorid = s.advisorid
group by a.advisorid, a.advisorname,a.departmentid


/*list of professors in university by campus with Professor ID,Profesor Name, 
Department Name,Campus  and courses teaching*/
go
create VIEW professorInfo AS
 select distinct uc.campusname,c.campusid,t.professorid,p.professorname,d.departmentid,d.departmentname, co.courseid,co.coursename from coursecatalog c
inner join teaches t on c.courseid=t.courseid
inner join universitycampus uc on c.campusid=uc.campusid
inner join professor p on t.professorid=p.professorid
inner join department d on d.departmentid=p.departmentid
inner join courseoffering co on  c.courseid=co.courseid

/*list of students registered for different course*/
Go
create VIEW NoOfStudentsByCourse AS
select co.courseid,co.coursename,count(studentid) as TotalStudents
from courseoffering co inner join courseregistration cr
 on co.courseid=cr.courseid 
 group by co.courseid,co.coursename

 /*STORED PROCEDURES*/
 --STORED PROCEDURE 1: get all prof data by dept 
Go
CREATE PROCEDURE getAllProfDataByDept 
(@department_name  varchar(45), @profCount INT OUTPUT) AS 
BEGIN 
Select * from professor p inner join department d on p.DepartmentID=d.DepartmentID 
inner join TEACHES t on t.ProfessorID=p.ProfessorID 
inner join CourseOffering c on t.CourseID=c.CourseID where DepartmentName = @department_name;  
Select @profCount = @@ROWCOUNT; 
END; 



--STORED PROCEDURE 2: update course registration status for a student 
Go
CREATE PROCEDURE updateCourseRegStatus (@StudentID INT, @CourseID INT, @NoofDroppedCoursesByStudent INT OUTPUT) AS 
BEGIN 
Update CourseRegistration set RegStatus='Dropped', RegDate= getdate()
where StudentID=@StudentID and CourseID = @CourseID
select @NoofDroppedCoursesByStudent = Count(*) from courseregistration cr where regstatus = 'Dropped' and StudentID = @StudentID
IF @@ROWCOUNT =0 PRINT 'Warning:No rows were updated'
END



Go

--STORED PROCEDURE 3: to get prof and course details for all students with a particular grade 
CREATE PROCEDURE getStudentsByGrade(@Grade varchar(5), @countOfStudentsWithThisGrade int OUTPUT) AS  
BEGIN  
SELECT * FROM STUDENT s inner join GRADES g on s.StudentID =g.StudentID
inner join TEACHES t on g.CourseID=t.CourseID where grade=@Grade  
SELECT @countOfStudentsWithThisGrade = Count(*) FROM STUDENT s inner join GRADES g on s.StudentID =g.StudentID
inner join TEACHES t on g.CourseID=t.CourseID where grade=@Grade 
END  



Go
--STORED PROCEDURE 4: total number of courses offered by a campus for a particular academic term  

CREATE PROCEDURE getAllCourseDetailsByCampusName(@CampusName  varchar(45),@academic_term varchar(45), @courseCount INT OUTPUT)
AS 
BEGIN 
Select * from universitycampus uc inner join coursecatalog cc on uc.CampusID=cc.CampusID 
inner join courseoffering co on cc.CourseID=co.CourseID where uc.CampusName=@CampusName AND cc.AcademicTerm=@academic_term 
SELECT @courseCount = @@ROWCOUNT; 
END


Go
--STORED PROCEDURE 5: All students assigned to an advisor
CREATE PROCEDURE getAllStudentDataAssgToAdvisor
( @advisor_name  varchar(45), @stuCount INT OUTPUT ) AS 

BEGIN 

Select * from Student s inner join Advisor a on s.AdvisorID=a.AdvisorID where a.AdvisorName=@advisor_name

Select @stuCount = @@ROWCOUNT; 

END 

--CREATION OF NON-CLUSTERED INDEXES

--Create non-clustered Index on StudentName in the Student Table
CREATE NONCLUSTERED INDEX IX_Student_StudentName ON Student(StudentName ASC); 
Go
--Create non-clustered Index on CGPA in the Grades Table
CREATE NONCLUSTERED INDEX IX_Student_Grades ON Grades(CGPA ASC)


/* Column Level Encryption*/
Go
ALTER TABLE Student ADD Username VARCHAR(50),[Password] VARBINARY(400)
Go
--creating a master key for the database
CREATE MASTER KEY
ENCRYPTION BY PASSWORD = 'Group8@123'

--Now we are checking if the key exists or not
/*SELECT name KeyName,
symmetric_key_id KeyID,
key_length KeyLength,
algorithm_desc KeyAlgorithm
FROM sys.symmetric_keys*/
Go
--Creating a self signed certificate and naming it StudentPass
CREATE CERTIFICATE StudentPass
WITH SUBJECT = 'Student  Password'
Go
--Encryption by creating a symmettric key
CREATE SYMMETRIC KEY StudentPass_SM
WITH ALGORITHM = AES_256
ENCRYPTION BY CERTIFICATE StudentPass
Go




 
