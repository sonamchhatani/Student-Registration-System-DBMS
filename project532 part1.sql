
CREATE SEQUENCE log_seq
    START WITH 1000
    INCREMENT BY 1;

CREATE OR REPLACE TRIGGER Logs_Before_Insert
BEFORE INSERT ON Logs
FOR EACH ROW
BEGIN
    SELECT log_seq.NEXTVAL
    INTO :new.log#
    FROM dual;
END;


CREATE OR REPLACE PROCEDURE show_students IS
CURSOR c_students IS
    SELECT B#, first_name, last_name, st_level, gpa, email, bdate FROM Students;
BEGIN
    FOR r_student IN c_students LOOP
        DBMS_OUTPUT.PUT_LINE('B#: ' || r_student.B# || ', Name: ' || r_student.first_name || ' ' || r_student.last_name ||
                             ', Level: ' || r_student.st_level || ', GPA: ' || r_student.gpa ||
                             ', Email: ' || r_student.email || ', Birthdate: ' || r_student.bdate);
    END LOOP;
END;
/

CREATE OR REPLACE PROCEDURE show_courses IS
CURSOR c_courses IS
    SELECT dept_code, course#, title FROM Courses;
BEGIN
    FOR r_course IN c_courses LOOP
        DBMS_OUTPUT.PUT_LINE('Dept Code: ' || r_course.dept_code || ', Course#: ' || r_course.course# ||
                             ', Title: ' || r_course.title);
    END LOOP;
END;
/

CREATE OR REPLACE PROCEDURE show_course_credits IS
CURSOR c_credits IS
    SELECT course#, credits FROM Course_credit;
BEGIN
    FOR r_credit IN c_credits LOOP
        DBMS_OUTPUT.PUT_LINE('Course#: ' || r_credit.course# || ', Credits: ' || r_credit.credits);
    END LOOP;
END;
/

CREATE OR REPLACE PROCEDURE show_classes IS
CURSOR c_classes IS
    SELECT classid, dept_code, course#, sect#, year, semester, limit, class_size, room FROM Classes;
BEGIN
    FOR r_class IN c_classes LOOP
        DBMS_OUTPUT.PUT_LINE('ClassID: ' || r_class.classid || ', Dept Code: ' || r_class.dept_code ||
                             ', Course#: ' || r_class.course# || ', Section#: ' || r_class.sect# ||
                             ', Year: ' || r_class.year || ', Semester: ' || r_class.semester ||
                             ', Limit: ' || r_class.limit || ', Class Size: ' || r_class.class_size ||
                             ', Room: ' || r_class.room);
    END LOOP;
END;
/

CREATE OR REPLACE PROCEDURE show_enrollments IS
CURSOR c_enrollments IS
    SELECT G_B#, classid, score FROM G_Enrollments;
BEGIN
    FOR r_enrollment IN c_enrollments LOOP
        DBMS_OUTPUT.PUT_LINE('G_B#: ' || r_enrollment.G_B# || ', ClassID: ' || r_enrollment.classid || 
                             ', Score: ' || r_enrollment.score);
    END LOOP;
END;
/

CREATE OR REPLACE PROCEDURE show_score_grades IS
CURSOR c_grades IS
    SELECT score, lgrade FROM Score_Grade;
BEGIN
    FOR r_grade IN c_grades LOOP
        DBMS_OUTPUT.PUT_LINE('Score: ' || r_grade.score || ', Grade: ' || r_grade.lgrade);
    END LOOP;
END;
/

CREATE OR REPLACE PROCEDURE show_prerequisites IS
CURSOR c_prerequisites IS
    SELECT dept_code, course#, pre_dept_code, pre_course# FROM Prerequisites;
BEGIN
    FOR r_prerequisite IN c_prerequisites LOOP
        DBMS_OUTPUT.PUT_LINE('Dept Code: ' || r_prerequisite.dept_code || ', Course#: ' || r_prerequisite.course# ||
                             ', Pre-Dept Code: ' || r_prerequisite.pre_dept_code || ', Pre-Course#: ' || r_prerequisite.pre_course#);
    END LOOP;
END;
/

CREATE OR REPLACE PROCEDURE show_logs IS
CURSOR c_logs IS
    SELECT log#, user_name, op_time, table_name, operation, tuple_keyvalue FROM Logs;
BEGIN
    FOR r_log IN c_logs LOOP
        DBMS_OUTPUT.PUT_LINE('Log#: ' || r_log.log# || ', User: ' || r_log.user_name ||
                             ', Operation Time: ' || r_log.op_time || ', Table: ' || r_log.table_name ||
                             ', Operation: ' || r_log.operation || ', Tuple Key: ' || r_log.tuple_keyvalue);
    END LOOP;
END;
/


CREATE OR REPLACE PROCEDURE ListStudentsByClass(p_classid IN CHAR) IS
    -- Variable to check if any student was found
    v_student_exists BOOLEAN := FALSE;

    -- Cursor to find students in a given class
    CURSOR c_students IS
        SELECT s.B#, s.first_name, s.last_name
        FROM Students s
        JOIN G_Enrollments e ON s.B# = e.G_B#
        WHERE e.classid = p_classid;
BEGIN
    -- Check if any student exists for the classid
    FOR r_student IN c_students LOOP
        v_student_exists := TRUE;
        DBMS_OUTPUT.PUT_LINE('B#: ' || r_student.B# || ', Name: ' || r_student.first_name || ' ' || r_student.last_name);
    END LOOP;

    -- If no student was found, check if classid is actually invalid
    IF NOT v_student_exists THEN
        -- Check for existence of classid
        DECLARE
            v_class_count NUMBER;
        BEGIN
            SELECT COUNT(*)
            INTO v_class_count
            FROM Classes
            WHERE classid = p_classid;

            IF v_class_count = 0 THEN
                DBMS_OUTPUT.PUT_LINE('The classid is invalid.');
            ELSE
                DBMS_OUTPUT.PUT_LINE('No students enrolled in this class.');
            END IF;
        END;
    END IF;
END ListStudentsByClass;
/


CREATE OR REPLACE PROCEDURE ListAllPrerequisites(p_dept_code IN VARCHAR2, p_course# IN NUMBER) IS
    -- Variable to store concatenated course identifier for error message
    v_course_id VARCHAR2(10) := p_dept_code || p_course#;

    -- Variable to check if the course exists
    v_course_exists NUMBER;

BEGIN
    -- First, check if the given course exists
    SELECT COUNT(*)
    INTO v_course_exists
    FROM Courses
    WHERE dept_code = p_dept_code AND course# = p_course#;

    IF v_course_exists = 0 THEN
        DBMS_OUTPUT.PUT_LINE(v_course_id || ' does not exist.');
    ELSE
        -- If the course exists, find all prerequisites
        FOR r_prerequisite IN (
            SELECT DISTINCT pre_dept_code || pre_course# AS prerequisite
            FROM Prerequisites
            START WITH dept_code = p_dept_code AND course# = p_course#
            CONNECT BY PRIOR pre_dept_code = dept_code AND PRIOR pre_course# = course#
            ORDER BY 1 -- Ordering by the concatenated prerequisite code
        ) LOOP
            DBMS_OUTPUT.PUT_LINE('Prerequisite: ' || r_prerequisite.prerequisite);
        END LOOP;
    END IF;
END ListAllPrerequisites;
/



CREATE OR REPLACE PROCEDURE EnrollGraduateStudent(p_B# IN CHAR, p_classid IN CHAR) IS
    v_st_level VARCHAR2(10);
    v_class_year NUMBER;
    v_class_semester VARCHAR2(10);
    v_class_size NUMBER;
    v_class_limit NUMBER;
    v_enrollment_count NUMBER;
    v_prerequisite_met BOOLEAN := TRUE;
    v_required_credit NUMBER;
    
BEGIN
    -- Check if the B# exists and is a graduate student
    SELECT st_level INTO v_st_level FROM Students WHERE B# = p_B#;
    IF v_st_level IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'The B# is invalid.');
    ELSIF v_st_level NOT IN ('master', 'PhD') THEN
        RAISE_APPLICATION_ERROR(-20002, 'This is not a graduate student.');
    END IF;
    
    -- Check if the classid exists and is offered in the current semester
    SELECT year, semester, class_size, limit INTO v_class_year, v_class_semester, v_class_size, v_class_limit 
    FROM Classes WHERE classid = p_classid;
    IF SQL%NOTFOUND THEN
        RAISE_APPLICATION_ERROR(-20003, 'The classid is invalid.');
    ELSIF v_class_year != 2021 OR v_class_semester != 'Spring' THEN
        RAISE_APPLICATION_ERROR(-20004, 'Cannot enroll into a class from a previous semester.');
    ELSIF v_class_size >= v_class_limit THEN
        RAISE_APPLICATION_ERROR(-20005, 'The class is already full.');
    END IF;

    -- Check if the student is already in the class
    SELECT COUNT(*) INTO v_enrollment_count FROM G_Enrollments WHERE G_B# = p_B# AND classid = p_classid;
    IF v_enrollment_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20006, 'The student is already in the class.');
    END IF;

    -- Check if the student is enrolled in more than five classes in the same semester
    SELECT COUNT(*) INTO v_enrollment_count FROM G_Enrollments 
    JOIN Classes ON G_Enrollments.classid = Classes.classid
    WHERE G_B# = p_B# AND year = 2021 AND semester = 'Spring';
    IF v_enrollment_count >= 5 THEN
        RAISE_APPLICATION_ERROR(-20007, 'Students cannot be enrolled in more than five classes in the same semester.');
    END IF;

    -- Check if prerequisites are met
    FOR r_prereq IN (SELECT pre_dept_code, pre_course# FROM Prerequisites WHERE dept_code = (SELECT dept_code FROM Classes WHERE classid = p_classid) AND course# = (SELECT course# FROM Classes WHERE classid = p_classid))
    LOOP
        SELECT COUNT(*) INTO v_enrollment_count FROM G_Enrollments
        JOIN Classes ON G_Enrollments.classid = Classes.classid
        WHERE G_B# = p_B# AND dept_code = r_prereq.pre_dept_code AND course# = r_prereq.pre_course# AND score >= 'C';
        IF v_enrollment_count = 0 THEN
            v_prerequisite_met := FALSE;
            EXIT;
        END IF;
    END LOOP;
    
    IF NOT v_prerequisite_met THEN
        RAISE_APPLICATION_ERROR(-20008, 'Prerequisite not satisfied.');
    END IF;

    -- Insert the new enrollment
    INSERT INTO G_Enrollments (G_B#, classid, score) VALUES (p_B#, p_classid, NULL);

    -- Increment class size (will be managed by a trigger outside this procedure)
    DBMS_OUTPUT.PUT_LINE('Enrollment successful for ' || p_B# || ' in class ' || p_classid);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Data validation error occurred.');
END EnrollGraduateStudent;
/

CREATE OR REPLACE TRIGGER AfterEnrollment
AFTER INSERT ON G_Enrollments
FOR EACH ROW
BEGIN
    UPDATE Classes SET class_size = class_size + 1
    WHERE classid = :NEW.classid;
END;
/

CREATE OR REPLACE PROCEDURE DropGraduateStudent(p_B# IN CHAR, p_classid IN CHAR) IS
    v_st_level VARCHAR2(10);
    v_class_year NUMBER;
    v_class_semester VARCHAR2(10);
    v_enrolled_classes NUMBER;

BEGIN
    -- Validate the student's B#
    BEGIN
        SELECT st_level INTO v_st_level FROM Students WHERE B# = p_B#;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20001, 'The B# is invalid.');
    END;

    -- Check if the student is a graduate
    IF v_st_level NOT IN ('master', 'PhD') THEN
        RAISE_APPLICATION_ERROR(-20002, 'This is not a graduate student.');
    END IF;

    -- Validate the classid and check semester
    BEGIN
        SELECT year, semester INTO v_class_year, v_class_semester 
        FROM Classes WHERE classid = p_classid;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20003, 'The classid is invalid.');
    END;

    -- Verify the semester and year
    IF v_class_year != 2021 OR v_class_semester != 'Spring' THEN
        RAISE_APPLICATION_ERROR(-20004, 'Only enrollment in the current semester can be dropped.');
    END IF;

    -- Check if the student is enrolled in the class
    SELECT COUNT(*) INTO v_enrolled_classes FROM G_Enrollments 
    WHERE G_B# = p_B# AND classid = p_classid;
    IF v_enrolled_classes = 0 THEN
        RAISE_APPLICATION_ERROR(-20005, 'The student is not enrolled in the class.');
    END IF;

    -- Ensure this is not the only class for the student in Spring 2021
    SELECT COUNT(*) INTO v_enrolled_classes FROM G_Enrollments 
    JOIN Classes ON G_Enrollments.classid = Classes.classid
    WHERE G_B# = p_B# AND year = 2021 AND semester = 'Spring';
    IF v_enrolled_classes = 1 THEN
        RAISE_APPLICATION_ERROR(-20006, 'This is the only class for this student in Spring 2021 and cannot be dropped.');
    END IF;

    -- Proceed to drop the student from the class
    DELETE FROM G_Enrollments WHERE G_B# = p_B# AND classid = p_classid;
    DBMS_OUTPUT.PUT_LINE('Student dropped successfully from ' || p_classid);

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An unexpected error occurred: ' || SQLERRM);
END DropGraduateStudent;
/

CREATE OR REPLACE TRIGGER AfterDropEnrollment
AFTER DELETE ON G_Enrollments
FOR EACH ROW
BEGIN
    UPDATE Classes
    SET class_size = class_size - 1
    WHERE classid = :OLD.classid;
END;
/


CREATE OR REPLACE PROCEDURE DropGraduateStudent(p_B# IN CHAR, p_classid IN CHAR) IS
    v_st_level VARCHAR2(10);
    v_class_year NUMBER;
    v_class_semester VARCHAR2(10);
    v_enrolled_classes NUMBER;

BEGIN
    -- Validate the student's B#
    BEGIN
        SELECT st_level INTO v_st_level FROM Students WHERE B# = p_B#;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20001, 'The B# is invalid.');
    END;

    -- Check if the student is a graduate
    IF v_st_level NOT IN ('master', 'PhD') THEN
        RAISE_APPLICATION_ERROR(-20002, 'This is not a graduate student.');
    END IF;

    -- Validate the classid and check semester
    BEGIN
        SELECT year, semester INTO v_class_year, v_class_semester 
        FROM Classes WHERE classid = p_classid;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20003, 'The classid is invalid.');
    END;

    -- Verify the semester and year
    IF v_class_year != 2021 OR v_class_semester != 'Spring' THEN
        RAISE_APPLICATION_ERROR(-20004, 'Only enrollment in the current semester can be dropped.');
    END IF;

    -- Check if the student is enrolled in the class
    SELECT COUNT(*) INTO v_enrolled_classes FROM G_Enrollments 
    WHERE G_B# = p_B# AND classid = p_classid;
    IF v_enrolled_classes = 0 THEN
        RAISE_APPLICATION_ERROR(-20005, 'The student is not enrolled in the class.');
    END IF;

    -- Ensure this is not the only class for the student in Spring 2021
    SELECT COUNT(*) INTO v_enrolled_classes FROM G_Enrollments 
    JOIN Classes ON G_Enrollments.classid = Classes.classid
    WHERE G_B# = p_B# AND year = 2021 AND semester = 'Spring';
    IF v_enrolled_classes = 1 THEN
        RAISE_APPLICATION_ERROR(-20006, 'This is the only class for this student in Spring 2021 and cannot be dropped.');
    END IF;

    -- Proceed to drop the student from the class
    DELETE FROM G_Enrollments WHERE G_B# = p_B# AND classid = p_classid;
    DBMS_OUTPUT.PUT_LINE('Student dropped successfully from ' || p_classid);

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An unexpected error occurred: ' || SQLERRM);
END DropGraduateStudent;
/

CREATE OR REPLACE TRIGGER trg_delete_enrollments
AFTER DELETE ON Students
FOR EACH ROW
BEGIN
    -- Delete all enrollments associated with the student
    DELETE FROM G_Enrollments WHERE G_B# = :OLD.B#;
    DBMS_OUTPUT.PUT_LINE('All enrollments for student B# ' || :OLD.B# || ' have been deleted.');
END;
/

CREATE OR REPLACE TRIGGER Log_Student_Deletion
AFTER DELETE ON students
FOR EACH ROW
BEGIN
    INSERT INTO Logs (user_name, op_time, table_name, operation, tuple_keyvalue)
    VALUES (USER, SYSDATE, 'Students', 'DELETE', :old.B#);
END;
/

CREATE OR REPLACE TRIGGER Log_Enrollment_Insertion
AFTER INSERT ON g_enrollments
FOR EACH ROW
BEGIN
    INSERT INTO Logs (user_name, op_time, table_name, operation, tuple_keyvalue)
    VALUES (USER, SYSDATE, 'G_Enrollments', 'INSERT', :new.g_B# || ',' || :new.classid);
END;
/

CREATE OR REPLACE TRIGGER Log_Enrollment_Deletion
AFTER DELETE ON g_enrollments
FOR EACH ROW
BEGIN
    INSERT INTO Logs (user_name, op_time, table_name, operation, tuple_keyvalue)
    VALUES (USER, SYSDATE, 'G_Enrollments', 'DELETE', :old.g_B# || ',' || :old.classid);
END;
/

Test
-- Insert a test student
INSERT INTO students (B#, first_name, last_name, st_level, gpa, email, bdate) VALUES ('B00000001', 'John', 'Doe', 'freshman', 3.5, 'john.doe@example.com', TO_DATE('2000-01-01', 'YYYY-MM-DD'));

-- Delete the test student
DELETE FROM students WHERE B# = 'B00000001';

-- Insert a test enrollment
INSERT INTO g_enrollments (g_B#, classid, score) VALUES ('B00000001', 'c0001', 85.00);

-- Delete the test enrollment
DELETE FROM g_enrollments WHERE g_B# = 'B00000001' AND classid = 'c0001';

-- Check the logs
SELECT * FROM Logs;
