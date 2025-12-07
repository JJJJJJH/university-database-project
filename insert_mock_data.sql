-- Program Evaluation System - Mock Data Insert Script
-- Based on create_database.sql schema
-- This script inserts sample data for testing purposes
-- Make sure to run create_database.sql first

USE program_evaluation;

-- ============================================
-- Clear existing data (optional - uncomment if needed)
-- ============================================
-- SET FOREIGN_KEY_CHECKS = 0;
-- TRUNCATE TABLE evaluation;
-- TRUNCATE TABLE evaluation_method;
-- TRUNCATE TABLE degree_course_objective;
-- TRUNCATE TABLE degree_objective;
-- TRUNCATE TABLE degree_course;
-- TRUNCATE TABLE section;
-- TRUNCATE TABLE semester;
-- TRUNCATE TABLE objective;
-- TRUNCATE TABLE instructor;
-- TRUNCATE TABLE course;
-- TRUNCATE TABLE degree;
-- SET FOREIGN_KEY_CHECKS = 1;

-- Note: evaluation_method data is already inserted in create_database.sql

-- ============================================
-- Insert Degree Data
-- ============================================
INSERT INTO `degree` (`name`, `level`) VALUES
  ('Computer Science', 'BS'),
  ('Computer Science', 'MS'),
  ('Data Science', 'MS'),
  ('Information Systems', 'BS'),
  ('Cybersecurity', 'MS');

-- ============================================
-- Insert Course Data
-- ============================================
INSERT INTO `course` (`course_id`, `name`, `description`) VALUES
  ('CS5330', 'Database Systems', 'Introduction to database design, SQL, and database management systems'),
  ('CS5331', 'Advanced Database Systems', 'Advanced topics in database systems including distributed databases and NoSQL'),
  ('CS5343', 'Data Structures and Algorithms', 'Fundamental data structures and algorithm design techniques'),
  ('CS5348', 'Operating Systems', 'Principles of operating systems design and implementation'),
  ('DS6300', 'Machine Learning', 'Introduction to machine learning algorithms and applications'),
  ('IS6340', 'Business Intelligence', 'Data warehousing, OLAP, and business intelligence systems'),
  ('CS7380', 'Database Security', 'Security principles and practices for database systems'),
  ('CS7390', 'Big Data Analytics', 'Large-scale data processing and analytics');

-- ============================================
-- Insert Instructor Data
-- ============================================
INSERT INTO `instructor` (`instructor_id`, `name`, `email`, `department`) VALUES
  ('INST001', 'Dr. John Smith', 'john.smith@smu.edu', 'Computer Science'),
  ('INST002', 'Dr. Sarah Johnson', 'sarah.johnson@smu.edu', 'Computer Science'),
  ('INST003', 'Dr. Michael Chen', 'michael.chen@smu.edu', 'Computer Science'),
  ('INST004', 'Dr. Emily Davis', 'emily.davis@smu.edu', 'Data Science'),
  ('INST005', 'Dr. Robert Wilson', 'robert.wilson@smu.edu', 'Information Systems');

-- ============================================
-- Insert Semester Data
-- ============================================
INSERT INTO `semester` (`year`, `term`) VALUES
  (2024, 'Fall'),
  (2024, 'Spring'),
  (2025, 'Fall'),
  (2025, 'Spring'),
  (2025, 'Summer');

-- ============================================
-- Insert Objective Data
-- ============================================
INSERT INTO `objective` (`objective_id`, `title`, `description`) VALUES
  ('OBJ001', 'Database Design', 'Students should be able to design normalized database schemas'),
  ('OBJ002', 'SQL Proficiency', 'Students should be able to write complex SQL queries'),
  ('OBJ003', 'Data Modeling', 'Students should understand ER modeling and relational model concepts'),
  ('OBJ004', 'Algorithm Analysis', 'Students should be able to analyze time and space complexity of algorithms'),
  ('OBJ005', 'System Programming', 'Students should understand system calls and process management'),
  ('OBJ006', 'Machine Learning Fundamentals', 'Students should understand basic ML algorithms and applications'),
  ('OBJ007', 'Data Warehousing', 'Students should understand data warehouse design and ETL processes'),
  ('OBJ008', 'Database Security', 'Students should understand security principles for database systems'),
  ('OBJ009', 'Big Data Processing', 'Students should be able to process large-scale data using distributed systems');

-- ============================================
-- Insert Section Data
-- ============================================
INSERT INTO `section` (`course_id`, `year`, `term`, `section_number`, `instructor_id`, `enrollment_count`) VALUES
  -- Fall 2024
  ('CS5330', 2024, 'Fall', '001', 'INST001', 35),
  ('CS5330', 2024, 'Fall', '002', 'INST001', 28),
  ('CS5343', 2024, 'Fall', '001', 'INST002', 40),
  ('CS5348', 2024, 'Fall', '001', 'INST003', 32),
  -- Spring 2025
  ('CS5330', 2025, 'Spring', '001', 'INST001', 38),
  ('CS5331', 2025, 'Spring', '001', 'INST002', 25),
  ('DS6300', 2025, 'Spring', '001', 'INST004', 30),
  ('IS6340', 2025, 'Spring', '001', 'INST005', 28),
  -- Fall 2025
  ('CS5330', 2025, 'Fall', '001', 'INST001', 36),
  ('CS5330', 2025, 'Fall', '002', 'INST001', 33),
  ('CS5343', 2025, 'Fall', '001', 'INST002', 42),
  ('CS7380', 2025, 'Fall', '001', 'INST002', 22),
  ('CS7390', 2025, 'Fall', '001', 'INST004', 24);

-- ============================================
-- Insert Degree-Course Associations
-- ============================================
-- Computer Science BS courses
INSERT INTO `degree_course` (`degree_name`, `degree_level`, `course_id`, `is_core`) VALUES
  ('Computer Science', 'BS', 'CS5330', 1),  -- Core
  ('Computer Science', 'BS', 'CS5343', 1),  -- Core
  ('Computer Science', 'BS', 'CS5348', 1),  -- Core
  ('Computer Science', 'BS', 'CS5331', 0);  -- Elective

-- Computer Science MS courses
INSERT INTO `degree_course` (`degree_name`, `degree_level`, `course_id`, `is_core`) VALUES
  ('Computer Science', 'MS', 'CS5330', 1),  -- Core
  ('Computer Science', 'MS', 'CS5331', 1),  -- Core
  ('Computer Science', 'MS', 'CS7380', 0),  -- Elective
  ('Computer Science', 'MS', 'CS7390', 0);  -- Elective

-- Data Science MS courses
INSERT INTO `degree_course` (`degree_name`, `degree_level`, `course_id`, `is_core`) VALUES
  ('Data Science', 'MS', 'DS6300', 1),      -- Core
  ('Data Science', 'MS', 'CS5330', 1),      -- Core
  ('Data Science', 'MS', 'CS7390', 0);      -- Elective

-- Information Systems BS courses
INSERT INTO `degree_course` (`degree_name`, `degree_level`, `course_id`, `is_core`) VALUES
  ('Information Systems', 'BS', 'IS6340', 1), -- Core
  ('Information Systems', 'BS', 'CS5330', 1); -- Core

-- Cybersecurity MS courses
INSERT INTO `degree_course` (`degree_name`, `degree_level`, `course_id`, `is_core`) VALUES
  ('Cybersecurity', 'MS', 'CS7380', 1),     -- Core
  ('Cybersecurity', 'MS', 'CS5330', 1);     -- Core

-- ============================================
-- Insert Degree-Objective Associations
-- ============================================
-- Computer Science BS objectives
INSERT INTO `degree_objective` (`degree_name`, `degree_level`, `objective_id`) VALUES
  ('Computer Science', 'BS', 'OBJ001'),
  ('Computer Science', 'BS', 'OBJ002'),
  ('Computer Science', 'BS', 'OBJ003'),
  ('Computer Science', 'BS', 'OBJ004'),
  ('Computer Science', 'BS', 'OBJ005');

-- Computer Science MS objectives
INSERT INTO `degree_objective` (`degree_name`, `degree_level`, `objective_id`) VALUES
  ('Computer Science', 'MS', 'OBJ001'),
  ('Computer Science', 'MS', 'OBJ002'),
  ('Computer Science', 'MS', 'OBJ008'),
  ('Computer Science', 'MS', 'OBJ009');

-- Data Science MS objectives
INSERT INTO `degree_objective` (`degree_name`, `degree_level`, `objective_id`) VALUES
  ('Data Science', 'MS', 'OBJ001'),
  ('Data Science', 'MS', 'OBJ002'),
  ('Data Science', 'MS', 'OBJ006'),
  ('Data Science', 'MS', 'OBJ009');

-- Information Systems BS objectives
INSERT INTO `degree_objective` (`degree_name`, `degree_level`, `objective_id`) VALUES
  ('Information Systems', 'BS', 'OBJ001'),
  ('Information Systems', 'BS', 'OBJ002'),
  ('Information Systems', 'BS', 'OBJ007');

-- Cybersecurity MS objectives
INSERT INTO `degree_objective` (`degree_name`, `degree_level`, `objective_id`) VALUES
  ('Cybersecurity', 'MS', 'OBJ001'),
  ('Cybersecurity', 'MS', 'OBJ008');

-- ============================================
-- Insert Degree-Course-Objective Associations
-- ============================================
-- CS5330 (Database Systems) for Computer Science BS
INSERT INTO `degree_course_objective` (`degree_name`, `degree_level`, `course_id`, `objective_id`) VALUES
  ('Computer Science', 'BS', 'CS5330', 'OBJ001'),
  ('Computer Science', 'BS', 'CS5330', 'OBJ002'),
  ('Computer Science', 'BS', 'CS5330', 'OBJ003');

-- CS5330 for Computer Science MS
INSERT INTO `degree_course_objective` (`degree_name`, `degree_level`, `course_id`, `objective_id`) VALUES
  ('Computer Science', 'MS', 'CS5330', 'OBJ001'),
  ('Computer Science', 'MS', 'CS5330', 'OBJ002');

-- CS5331 (Advanced Database Systems) for Computer Science MS
INSERT INTO `degree_course_objective` (`degree_name`, `degree_level`, `course_id`, `objective_id`) VALUES
  ('Computer Science', 'MS', 'CS5331', 'OBJ001'),
  ('Computer Science', 'MS', 'CS5331', 'OBJ002'),
  ('Computer Science', 'MS', 'CS5331', 'OBJ008');

-- CS5343 (Data Structures) for Computer Science BS
INSERT INTO `degree_course_objective` (`degree_name`, `degree_level`, `course_id`, `objective_id`) VALUES
  ('Computer Science', 'BS', 'CS5343', 'OBJ004');

-- CS5348 (Operating Systems) for Computer Science BS
INSERT INTO `degree_course_objective` (`degree_name`, `degree_level`, `course_id`, `objective_id`) VALUES
  ('Computer Science', 'BS', 'CS5348', 'OBJ005');

-- DS6300 (Machine Learning) for Data Science MS
INSERT INTO `degree_course_objective` (`degree_name`, `degree_level`, `course_id`, `objective_id`) VALUES
  ('Data Science', 'MS', 'DS6300', 'OBJ006'),
  ('Data Science', 'MS', 'DS6300', 'OBJ009');

-- IS6340 (Business Intelligence) for Information Systems BS
INSERT INTO `degree_course_objective` (`degree_name`, `degree_level`, `course_id`, `objective_id`) VALUES
  ('Information Systems', 'BS', 'IS6340', 'OBJ007'),
  ('Information Systems', 'BS', 'IS6340', 'OBJ002');

-- CS7380 (Database Security) for Computer Science MS and Cybersecurity MS
INSERT INTO `degree_course_objective` (`degree_name`, `degree_level`, `course_id`, `objective_id`) VALUES
  ('Computer Science', 'MS', 'CS7380', 'OBJ008'),
  ('Cybersecurity', 'MS', 'CS7380', 'OBJ008');

-- CS7390 (Big Data Analytics) for Computer Science MS and Data Science MS
INSERT INTO `degree_course_objective` (`degree_name`, `degree_level`, `course_id`, `objective_id`) VALUES
  ('Computer Science', 'MS', 'CS7390', 'OBJ009'),
  ('Data Science', 'MS', 'CS7390', 'OBJ009');

-- CS5330 for Data Science MS
INSERT INTO `degree_course_objective` (`degree_name`, `degree_level`, `course_id`, `objective_id`) VALUES
  ('Data Science', 'MS', 'CS5330', 'OBJ001'),
  ('Data Science', 'MS', 'CS5330', 'OBJ002');

-- CS5330 for Information Systems BS
INSERT INTO `degree_course_objective` (`degree_name`, `degree_level`, `course_id`, `objective_id`) VALUES
  ('Information Systems', 'BS', 'CS5330', 'OBJ001'),
  ('Information Systems', 'BS', 'CS5330', 'OBJ002');

-- CS5330 for Cybersecurity MS
INSERT INTO `degree_course_objective` (`degree_name`, `degree_level`, `course_id`, `objective_id`) VALUES
  ('Cybersecurity', 'MS', 'CS5330', 'OBJ001');

-- ============================================
-- Insert Evaluation Data (Sample evaluations)
-- Note: Each (degree_name, degree_level, course_id, year, term, section_number, objective_id) 
--       combination can only have ONE evaluation record (based on PRIMARY KEY constraint)
--       The method_name, count_A, count_B, count_C, count_F, and improvement_suggestion 
--       represent the overall evaluation for that objective in that section
-- ============================================
-- Evaluations for CS5330, Fall 2025, Section 001, Computer Science BS
INSERT INTO `evaluation` (`degree_name`, `degree_level`, `course_id`, `year`, `term`, `section_number`, `objective_id`, `method_name`, `count_A`, `count_B`, `count_C`, `count_F`, `improvement_suggestion`) VALUES
  ('Computer Science', 'BS', 'CS5330', 2025, 'Fall', '001', 'OBJ001', 'Final Exam', 14, 13, 7, 1, 'Students showed improvement in normalization concepts. More practice problems on normalization would be helpful'),
  ('Computer Science', 'BS', 'CS5330', 2025, 'Fall', '001', 'OBJ002', 'Project', 15, 12, 7, 1, 'Project helped students understand complex queries. Need more SQL practice exercises'),
  ('Computer Science', 'BS', 'CS5330', 2025, 'Fall', '001', 'OBJ003', 'Final Exam', 13, 14, 7, 1, NULL);

-- Evaluations for CS5330, Fall 2025, Section 002, Computer Science BS
INSERT INTO `evaluation` (`degree_name`, `degree_level`, `course_id`, `year`, `term`, `section_number`, `objective_id`, `method_name`, `count_A`, `count_B`, `count_C`, `count_F`, `improvement_suggestion`) VALUES
  ('Computer Science', 'BS', 'CS5330', 2025, 'Fall', '002', 'OBJ001', 'Mid-term', 10, 14, 7, 2, 'Consider adding more examples in lectures'),
  ('Computer Science', 'BS', 'CS5330', 2025, 'Fall', '002', 'OBJ002', 'Project', 13, 13, 6, 1, 'Project requirements were clear and achievable'),
  ('Computer Science', 'BS', 'CS5330', 2025, 'Fall', '002', 'OBJ003', 'Final Exam', 12, 15, 5, 1, NULL);

-- Evaluations for CS5343, Fall 2025, Section 001, Computer Science BS
INSERT INTO `evaluation` (`degree_name`, `degree_level`, `course_id`, `year`, `term`, `section_number`, `objective_id`, `method_name`, `count_A`, `count_B`, `count_C`, `count_F`, `improvement_suggestion`) VALUES
  ('Computer Science', 'BS', 'CS5343', 2025, 'Fall', '001', 'OBJ004', 'Final Exam', 18, 14, 8, 2, 'Overall improvement in algorithm analysis skills. Some students initially struggled with time complexity analysis');

-- Evaluations for CS7380, Fall 2025, Section 001, Computer Science MS
INSERT INTO `evaluation` (`degree_name`, `degree_level`, `course_id`, `year`, `term`, `section_number`, `objective_id`, `method_name`, `count_A`, `count_B`, `count_C`, `count_F`, `improvement_suggestion`) VALUES
  ('Computer Science', 'MS', 'CS7380', 2025, 'Fall', '001', 'OBJ008', 'Final Exam', 8, 9, 4, 1, 'Security project was well-received. Need to cover authentication mechanisms in more depth');

-- Evaluations for CS5330, Spring 2025, Section 001, Computer Science MS
INSERT INTO `evaluation` (`degree_name`, `degree_level`, `course_id`, `year`, `term`, `section_number`, `objective_id`, `method_name`, `count_A`, `count_B`, `count_C`, `count_F`, `improvement_suggestion`) VALUES
  ('Computer Science', 'MS', 'CS5330', 2025, 'Spring', '001', 'OBJ001', 'Mid-term', 14, 15, 7, 2, NULL),
  ('Computer Science', 'MS', 'CS5330', 2025, 'Spring', '001', 'OBJ002', 'Project', 16, 13, 7, 2, 'Advanced database project demonstrated good understanding');

-- Evaluations for DS6300, Spring 2025, Section 001, Data Science MS
INSERT INTO `evaluation` (`degree_name`, `degree_level`, `course_id`, `year`, `term`, `section_number`, `objective_id`, `method_name`, `count_A`, `count_B`, `count_C`, `count_F`, `improvement_suggestion`) VALUES
  ('Data Science', 'MS', 'DS6300', 2025, 'Spring', '001', 'OBJ006', 'Project', 14, 9, 5, 2, 'ML project results were excellent. More practice with different ML algorithms needed'),
  ('Data Science', 'MS', 'DS6300', 2025, 'Spring', '001', 'OBJ009', 'Final Exam', 13, 11, 5, 1, NULL);

-- Evaluations for IS6340, Spring 2025, Section 001, Information Systems BS
INSERT INTO `evaluation` (`degree_name`, `degree_level`, `course_id`, `year`, `term`, `section_number`, `objective_id`, `method_name`, `count_A`, `count_B`, `count_C`, `count_F`, `improvement_suggestion`) VALUES
  ('Information Systems', 'BS', 'IS6340', 2025, 'Spring', '001', 'OBJ007', 'Report', 10, 12, 5, 1, 'Reports showed good understanding of data warehousing concepts'),
  ('Information Systems', 'BS', 'IS6340', 2025, 'Spring', '001', 'OBJ002', 'Final Exam', 11, 13, 3, 1, NULL);

-- ============================================
-- Verification Queries (Optional - uncomment to verify)
-- ============================================
-- SELECT 'Total Degrees:' AS Info, COUNT(*) AS Count FROM degree
-- UNION ALL
-- SELECT 'Total Courses:', COUNT(*) FROM course
-- UNION ALL
-- SELECT 'Total Instructors:', COUNT(*) FROM instructor
-- UNION ALL
-- SELECT 'Total Semesters:', COUNT(*) FROM semester
-- UNION ALL
-- SELECT 'Total Sections:', COUNT(*) FROM section
-- UNION ALL
-- SELECT 'Total Objectives:', COUNT(*) FROM objective
-- UNION ALL
-- SELECT 'Total Evaluations:', COUNT(*) FROM evaluation;

SELECT 'Mock data insertion completed successfully!' AS Status;

