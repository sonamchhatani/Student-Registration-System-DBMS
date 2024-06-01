CREATE OR REPLACE PACKAGE University_Package AS

    -- Procedures
    PROCEDURE show_students;
    PROCEDURE show_courses;
    PROCEDURE show_course_credits;
    PROCEDURE show_classes;
    PROCEDURE show_enrollments;
    PROCEDURE show_score_grades;
    PROCEDURE show_prerequisites;
    PROCEDURE show_logs;
    PROCEDURE ListStudentsByClass(p_classid IN CHAR);
    PROCEDURE ListAllPrerequisites(p_dept_code IN VARCHAR2, p_course# IN NUMBER);
    PROCEDURE EnrollGraduateStudent(p_B# IN CHAR, p_classid IN CHAR);
    PROCEDURE DropGraduateStudent(p_B# IN CHAR, p_classid IN CHAR);

END University_Package;
/
CREATE OR REPLACE PACKAGE BODY University_Package AS

    PROCEDURE show_students IS
        CURSOR c_students IS
            SELECT B#, first_name, last_name, st_level, gpa, email, bdate FROM Students;
        BEGIN
            FOR r_student IN c_students LOOP
                DBMS_OUTPUT.PUT_LINE('B#: ' || r_student.B# || ', Name: ' || r_student.first_name || ' ' || r_student.last_name ||
                                     ', Level: ' || r_student.st_level || ', GPA: ' || r_student.gpa ||
                                     ', Email: ' || r_student.email || ', Birthdate: ' || r_student.bdate);
            END LOOP;
        END;

    PROCEDURE show_courses IS
        CURSOR c_courses IS
            SELECT dept_code, course#, title FROM Courses;
        BEGIN
            FOR r_course IN c_courses LOOP
                DBMS_OUTPUT.PUT_LINE('Dept Code: ' || r_course.dept_code || ', Course#: ' || r_course.course# ||
                                     ', Title: ' || r_course.title);
            END LOOP;
        END;

    -- Include other procedures similarly

    -- Triggers can be defined within the package body using PL/SQL blocks
    BEGIN
        EXECUTE IMMEDIATE 'CREATE OR REPLACE TRIGGER Logs_Before_Insert
            BEFORE INSERT ON Logs
            FOR EACH ROW
            BEGIN
                SELECT log_seq.NEXTVAL
                INTO :new.log#
                FROM dual;
            END;';

        EXECUTE IMMEDIATE 'CREATE OR REPLACE TRIGGER AfterEnrollment
            AFTER INSERT ON G_Enrollments
            FOR EACH ROW
            BEGIN
                UPDATE Classes SET class_size = class_size + 1
                WHERE classid = :NEW.classid;
            END;';

        -- Add other triggers
    END;

END University_Package;
/
BEGIN
    University_Package.show_students;
    University_Package.EnrollGraduateStudent('B00000001', 'c0001');
END;
/
BEGIN
    -- Test inserts and deletes
    INSERT INTO students (B#, first_name, last_name, st_level, gpa, email, bdate) VALUES ('B00000001', 'John', 'Doe', 'freshman', 3.5, 'john.doe@example.com', TO_DATE('2000-01-01', 'YYYY-MM-DD'));
    DELETE FROM students WHERE B# = 'B00000001';
    INSERT INTO g_enrollments (g_B#, classid, score) VALUES ('B00000001', 'c0001', 85.00);
    DELETE FROM g_enrollments WHERE g_B# = 'B00000001' AND classid = 'c0001';

    -- Check the logs
    SELECT * FROM Logs;
END;
/
