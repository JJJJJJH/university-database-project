-- ============================================
-- Program Evaluation System - Backend CRUD Queries
-- For Backend Developers
-- ============================================
-- This file contains all CRUD operations and validation queries
-- for the Program Evaluation System database
-- ============================================

USE program_evaluation;

-- ============================================
-- 1. DEGREE TABLE - CRUD Operations
-- ============================================

-- CREATE - Insert a new degree
-- Parameters: @degree_name, @degree_level
INSERT INTO `degree` (`name`, `level`) 
VALUES (?, ?);

-- READ - Get all degrees
SELECT `name`, `level`, `created_at`, `updated_at`
FROM `degree`
ORDER BY `name`, `level`;

-- READ - Get a specific degree by name and level
SELECT `name`, `level`, `created_at`, `updated_at`
FROM `degree`
WHERE `name` = ? AND `level` = ?;

-- READ - Get all degrees by name
SELECT `name`, `level`, `created_at`, `updated_at`
FROM `degree`
WHERE `name` = ?
ORDER BY `level`;

-- READ - Get all degrees by level
SELECT `name`, `level`, `created_at`, `updated_at`
FROM `degree`
WHERE `level` = ?
ORDER BY `name`;

-- UPDATE - Update degree information (only timestamps are auto-updated)
-- Note: Primary key cannot be updated, only timestamps change automatically
SELECT 'Note: Degree primary key (name, level) cannot be updated. Only timestamps are auto-updated.' AS info;

-- DELETE - Delete a degree (CASCADE will remove related records)
DELETE FROM `degree`
WHERE `name` = ? AND `level` = ?;

-- ============================================
-- VALIDATION QUERIES FOR DEGREE
-- ============================================

-- Check if degree exists before inserting
SELECT COUNT(*) AS count
FROM `degree`
WHERE `name` = ? AND `level` = ?;

-- Check if degree is used in other tables (before deletion)
SELECT 
    (SELECT COUNT(*) FROM `degree_course` WHERE `degree_name` = ? AND `degree_level` = ?) AS degree_course_count,
    (SELECT COUNT(*) FROM `degree_objective` WHERE `degree_name` = ? AND `degree_level` = ?) AS degree_objective_count,
    (SELECT COUNT(*) FROM `degree_course_objective` WHERE `degree_name` = ? AND `degree_level` = ?) AS degree_course_objective_count,
    (SELECT COUNT(*) FROM `evaluation` WHERE `degree_name` = ? AND `degree_level` = ?) AS evaluation_count;

-- Validate degree level enum
SELECT 'Valid levels: BA, BS, MS, PhD, Cert' AS valid_levels;

-- ============================================
-- 2. COURSE TABLE - CRUD Operations
-- ============================================

-- CREATE - Insert a new course
-- Parameters: @course_id, @name, @description
INSERT INTO `course` (`course_id`, `name`, `description`)
VALUES (?, ?, ?);

-- READ - Get all courses
SELECT `course_id`, `name`, `description`, `created_at`, `updated_at`
FROM `course`
ORDER BY `course_id`;

-- READ - Get a specific course by ID
SELECT `course_id`, `name`, `description`, `created_at`, `updated_at`
FROM `course`
WHERE `course_id` = ?;

-- READ - Search courses by name (partial match)
SELECT `course_id`, `name`, `description`, `created_at`, `updated_at`
FROM `course`
WHERE `name` LIKE CONCAT('%', ?, '%')
ORDER BY `course_id`;

-- UPDATE - Update course information
UPDATE `course`
SET 
    `name` = ?,
    `description` = ?
WHERE `course_id` = ?;

-- UPDATE - Update only course name
UPDATE `course`
SET `name` = ?
WHERE `course_id` = ?;

-- UPDATE - Update only course description
UPDATE `course`
SET `description` = ?
WHERE `course_id` = ?;

-- DELETE - Delete a course (CASCADE will remove related records)
DELETE FROM `course`
WHERE `course_id` = ?;

-- ============================================
-- VALIDATION QUERIES FOR COURSE
-- ============================================

-- Check if course_id exists
SELECT COUNT(*) AS count
FROM `course`
WHERE `course_id` = ?;

-- Check if course name already exists (unique constraint)
SELECT COUNT(*) AS count
FROM `course`
WHERE `name` = ? AND `course_id` != ?;

-- Check if course is used in other tables (before deletion)
SELECT 
    (SELECT COUNT(*) FROM `degree_course` WHERE `course_id` = ?) AS degree_course_count,
    (SELECT COUNT(*) FROM `degree_course_objective` WHERE `course_id` = ?) AS degree_course_objective_count,
    (SELECT COUNT(*) FROM `section` WHERE `course_id` = ?) AS section_count,
    (SELECT COUNT(*) FROM `evaluation` WHERE `course_id` = ?) AS evaluation_count;

-- ============================================
-- 3. INSTRUCTOR TABLE - CRUD Operations
-- ============================================

-- CREATE - Insert a new instructor
-- Parameters: @instructor_id, @name, @email, @department
INSERT INTO `instructor` (`instructor_id`, `name`, `email`, `department`)
VALUES (?, ?, ?, ?);

-- READ - Get all instructors
SELECT `instructor_id`, `name`, `email`, `department`, `created_at`, `updated_at`
FROM `instructor`
ORDER BY `name`;

-- READ - Get a specific instructor by ID
SELECT `instructor_id`, `name`, `email`, `department`, `created_at`, `updated_at`
FROM `instructor`
WHERE `instructor_id` = ?;

-- READ - Search instructors by name (partial match)
SELECT `instructor_id`, `name`, `email`, `department`, `created_at`, `updated_at`
FROM `instructor`
WHERE `name` LIKE CONCAT('%', ?, '%')
ORDER BY `name`;

-- READ - Get instructors by department
SELECT `instructor_id`, `name`, `email`, `department`, `created_at`, `updated_at`
FROM `instructor`
WHERE `department` = ?
ORDER BY `name`;

-- UPDATE - Update instructor information
UPDATE `instructor`
SET 
    `name` = ?,
    `email` = ?,
    `department` = ?
WHERE `instructor_id` = ?;

-- UPDATE - Update only instructor name
UPDATE `instructor`
SET `name` = ?
WHERE `instructor_id` = ?;

-- UPDATE - Update only instructor email
UPDATE `instructor`
SET `email` = ?
WHERE `instructor_id` = ?;

-- UPDATE - Update only instructor department
UPDATE `instructor`
SET `department` = ?
WHERE `instructor_id` = ?;

-- DELETE - Delete an instructor (RESTRICT - will fail if sections exist)
DELETE FROM `instructor`
WHERE `instructor_id` = ?;

-- ============================================
-- VALIDATION QUERIES FOR INSTRUCTOR
-- ============================================

-- Check if instructor_id exists
SELECT COUNT(*) AS count
FROM `instructor`
WHERE `instructor_id` = ?;

-- Check if email already exists (unique constraint)
SELECT COUNT(*) AS count
FROM `instructor`
WHERE `email` = ? AND `instructor_id` != ?;

-- Check if instructor teaches any sections (before deletion - RESTRICT)
SELECT COUNT(*) AS section_count
FROM `section`
WHERE `instructor_id` = ?;

-- Get all sections taught by an instructor
SELECT s.`course_id`, s.`year`, s.`term`, s.`section_number`, s.`enrollment_count`,
       c.`name` AS course_name
FROM `section` s
JOIN `course` c ON s.`course_id` = c.`course_id`
WHERE s.`instructor_id` = ?
ORDER BY s.`year` DESC, s.`term`, s.`course_id`;

-- ============================================
-- 4. SEMESTER TABLE - CRUD Operations
-- ============================================

-- CREATE - Insert a new semester
-- Parameters: @year, @term
INSERT INTO `semester` (`year`, `term`)
VALUES (?, ?);

-- READ - Get all semesters
SELECT `year`, `term`, `created_at`
FROM `semester`
ORDER BY `year` DESC, 
         CASE `term` 
             WHEN 'Spring' THEN 1 
             WHEN 'Summer' THEN 2 
             WHEN 'Fall' THEN 3 
         END;

-- READ - Get a specific semester
SELECT `year`, `term`, `created_at`
FROM `semester`
WHERE `year` = ? AND `term` = ?;

-- READ - Get all semesters for a specific year
SELECT `year`, `term`, `created_at`
FROM `semester`
WHERE `year` = ?
ORDER BY CASE `term` 
             WHEN 'Spring' THEN 1 
             WHEN 'Summer' THEN 2 
             WHEN 'Fall' THEN 3 
         END;

-- UPDATE - Update semester (only timestamps change automatically)
-- Note: Primary key cannot be updated
SELECT 'Note: Semester primary key (year, term) cannot be updated. Only timestamps are auto-updated.' AS info;

-- DELETE - Delete a semester (CASCADE will remove related records)
DELETE FROM `semester`
WHERE `year` = ? AND `term` = ?;

-- ============================================
-- VALIDATION QUERIES FOR SEMESTER
-- ============================================

-- Check if semester exists
SELECT COUNT(*) AS count
FROM `semester`
WHERE `year` = ? AND `term` = ?;

-- Validate year (must be >= 2000)
SELECT CASE 
    WHEN ? >= 2000 THEN 'Valid year'
    ELSE 'Invalid year - must be >= 2000'
END AS validation_result;

-- Validate term enum
SELECT 'Valid terms: Spring, Summer, Fall' AS valid_terms;

-- Check if semester is used in sections (before deletion)
SELECT COUNT(*) AS section_count
FROM `section`
WHERE `year` = ? AND `term` = ?;

-- ============================================
-- 5. SECTION TABLE - CRUD Operations
-- ============================================

-- CREATE - Insert a new section
-- Parameters: @course_id, @year, @term, @section_number, @instructor_id, @enrollment_count
INSERT INTO `section` (`course_id`, `year`, `term`, `section_number`, `instructor_id`, `enrollment_count`)
VALUES (?, ?, ?, ?, ?, ?);

-- READ - Get all sections
SELECT s.`course_id`, s.`year`, s.`term`, s.`section_number`, 
       s.`instructor_id`, s.`enrollment_count`, s.`created_at`, s.`updated_at`,
       c.`name` AS course_name,
       i.`name` AS instructor_name
FROM `section` s
JOIN `course` c ON s.`course_id` = c.`course_id`
JOIN `instructor` i ON s.`instructor_id` = i.`instructor_id`
ORDER BY s.`year` DESC, s.`term`, s.`course_id`, s.`section_number`;

-- READ - Get a specific section
SELECT s.`course_id`, s.`year`, s.`term`, s.`section_number`, 
       s.`instructor_id`, s.`enrollment_count`, s.`created_at`, s.`updated_at`,
       c.`name` AS course_name,
       i.`name` AS instructor_name
FROM `section` s
JOIN `course` c ON s.`course_id` = c.`course_id`
JOIN `instructor` i ON s.`instructor_id` = i.`instructor_id`
WHERE s.`course_id` = ? AND s.`year` = ? AND s.`term` = ? AND s.`section_number` = ?;

-- READ - Get all sections for a course
SELECT s.`course_id`, s.`year`, s.`term`, s.`section_number`, 
       s.`instructor_id`, s.`enrollment_count`, s.`created_at`, s.`updated_at`,
       c.`name` AS course_name,
       i.`name` AS instructor_name
FROM `section` s
JOIN `course` c ON s.`course_id` = c.`course_id`
JOIN `instructor` i ON s.`instructor_id` = i.`instructor_id`
WHERE s.`course_id` = ?
ORDER BY s.`year` DESC, s.`term`, s.`section_number`;

-- READ - Get all sections for a semester
SELECT s.`course_id`, s.`year`, s.`term`, s.`section_number`, 
       s.`instructor_id`, s.`enrollment_count`, s.`created_at`, s.`updated_at`,
       c.`name` AS course_name,
       i.`name` AS instructor_name
FROM `section` s
JOIN `course` c ON s.`course_id` = c.`course_id`
JOIN `instructor` i ON s.`instructor_id` = i.`instructor_id`
WHERE s.`year` = ? AND s.`term` = ?
ORDER BY s.`course_id`, s.`section_number`;

-- READ - Get all sections taught by an instructor in a semester
SELECT s.`course_id`, s.`year`, s.`term`, s.`section_number`, 
       s.`instructor_id`, s.`enrollment_count`, s.`created_at`, s.`updated_at`,
       c.`name` AS course_name
FROM `section` s
JOIN `course` c ON s.`course_id` = c.`course_id`
WHERE s.`instructor_id` = ? AND s.`year` = ? AND s.`term` = ?
ORDER BY s.`course_id`, s.`section_number`;

-- UPDATE - Update section information
UPDATE `section`
SET 
    `instructor_id` = ?,
    `enrollment_count` = ?
WHERE `course_id` = ? AND `year` = ? AND `term` = ? AND `section_number` = ?;

-- UPDATE - Update only enrollment count
UPDATE `section`
SET `enrollment_count` = ?
WHERE `course_id` = ? AND `year` = ? AND `term` = ? AND `section_number` = ?;

-- UPDATE - Update only instructor
UPDATE `section`
SET `instructor_id` = ?
WHERE `course_id` = ? AND `year` = ? AND `term` = ? AND `section_number` = ?;

-- DELETE - Delete a section (CASCADE will remove related evaluations)
DELETE FROM `section`
WHERE `course_id` = ? AND `year` = ? AND `term` = ? AND `section_number` = ?;

-- ============================================
-- VALIDATION QUERIES FOR SECTION
-- ============================================

-- Check if section exists
SELECT COUNT(*) AS count
FROM `section`
WHERE `course_id` = ? AND `year` = ? AND `term` = ? AND `section_number` = ?;

-- Validate enrollment_count (must be >= 0)
SELECT CASE 
    WHEN ? >= 0 THEN 'Valid enrollment count'
    ELSE 'Invalid enrollment count - must be >= 0'
END AS validation_result;

-- Check if course exists (before inserting section)
SELECT COUNT(*) AS count
FROM `course`
WHERE `course_id` = ?;

-- Check if semester exists (before inserting section)
SELECT COUNT(*) AS count
FROM `semester`
WHERE `year` = ? AND `term` = ?;

-- Check if instructor exists (before inserting section)
SELECT COUNT(*) AS count
FROM `instructor`
WHERE `instructor_id` = ?;

-- Check if section has evaluations (before deletion)
SELECT COUNT(*) AS evaluation_count
FROM `evaluation`
WHERE `course_id` = ? AND `year` = ? AND `term` = ? AND `section_number` = ?;

-- ============================================
-- 6. OBJECTIVE TABLE - CRUD Operations
-- ============================================

-- CREATE - Insert a new objective
-- Parameters: @objective_id, @title, @description
INSERT INTO `objective` (`objective_id`, `title`, `description`)
VALUES (?, ?, ?);

-- READ - Get all objectives
SELECT `objective_id`, `title`, `description`, `created_at`, `updated_at`
FROM `objective`
ORDER BY `objective_id`;

-- READ - Get a specific objective by ID
SELECT `objective_id`, `title`, `description`, `created_at`, `updated_at`
FROM `objective`
WHERE `objective_id` = ?;

-- READ - Search objectives by title (partial match)
SELECT `objective_id`, `title`, `description`, `created_at`, `updated_at`
FROM `objective`
WHERE `title` LIKE CONCAT('%', ?, '%')
ORDER BY `objective_id`;

-- UPDATE - Update objective information
UPDATE `objective`
SET 
    `title` = ?,
    `description` = ?
WHERE `objective_id` = ?;

-- UPDATE - Update only objective title
UPDATE `objective`
SET `title` = ?
WHERE `objective_id` = ?;

-- UPDATE - Update only objective description
UPDATE `objective`
SET `description` = ?
WHERE `objective_id` = ?;

-- DELETE - Delete an objective (CASCADE will remove related records)
DELETE FROM `objective`
WHERE `objective_id` = ?;

-- ============================================
-- VALIDATION QUERIES FOR OBJECTIVE
-- ============================================

-- Check if objective_id exists
SELECT COUNT(*) AS count
FROM `objective`
WHERE `objective_id` = ?;

-- Check if objective title already exists (unique constraint)
SELECT COUNT(*) AS count
FROM `objective`
WHERE `title` = ? AND `objective_id` != ?;

-- Validate title length (must be <= 120 characters)
SELECT CASE 
    WHEN LENGTH(?) <= 120 THEN 'Valid title length'
    ELSE 'Invalid title - must be <= 120 characters'
END AS validation_result;

-- Check if objective is used in other tables (before deletion)
SELECT 
    (SELECT COUNT(*) FROM `degree_objective` WHERE `objective_id` = ?) AS degree_objective_count,
    (SELECT COUNT(*) FROM `degree_course_objective` WHERE `objective_id` = ?) AS degree_course_objective_count,
    (SELECT COUNT(*) FROM `evaluation` WHERE `objective_id` = ?) AS evaluation_count;

-- ============================================
-- 7. EVALUATION_METHOD TABLE - CRUD Operations
-- ============================================

-- CREATE - Insert a new evaluation method
-- Parameters: @method_name
INSERT INTO `evaluation_method` (`name`)
VALUES (?);

-- READ - Get all evaluation methods
SELECT `name`, `created_at`
FROM `evaluation_method`
ORDER BY `name`;

-- READ - Get a specific evaluation method
SELECT `name`, `created_at`
FROM `evaluation_method`
WHERE `name` = ?;

-- UPDATE - Update evaluation method (only timestamps change automatically)
-- Note: Primary key cannot be updated
SELECT 'Note: Evaluation method name (primary key) cannot be updated. Only timestamps are auto-updated.' AS info;

-- DELETE - Delete an evaluation method (RESTRICT - will fail if used in evaluations)
DELETE FROM `evaluation_method`
WHERE `name` = ?;

-- ============================================
-- VALIDATION QUERIES FOR EVALUATION_METHOD
-- ============================================

-- Check if evaluation method exists
SELECT COUNT(*) AS count
FROM `evaluation_method`
WHERE `name` = ?;

-- Check if evaluation method is used in evaluations (before deletion - RESTRICT)
SELECT COUNT(*) AS evaluation_count
FROM `evaluation`
WHERE `method_name` = ?;

-- ============================================
-- 8. DEGREE_COURSE TABLE - CRUD Operations
-- ============================================

-- CREATE - Associate a course with a degree
-- Parameters: @degree_name, @degree_level, @course_id, @is_core
INSERT INTO `degree_course` (`degree_name`, `degree_level`, `course_id`, `is_core`)
VALUES (?, ?, ?, ?);

-- READ - Get all degree-course associations
SELECT dc.`degree_name`, dc.`degree_level`, dc.`course_id`, dc.`is_core`, dc.`created_at`,
       d.`name` AS degree_display,
       c.`name` AS course_name
FROM `degree_course` dc
JOIN `degree` d ON dc.`degree_name` = d.`name` AND dc.`degree_level` = d.`level`
JOIN `course` c ON dc.`course_id` = c.`course_id`
ORDER BY dc.`degree_name`, dc.`degree_level`, dc.`course_id`;

-- READ - Get all courses for a specific degree
SELECT dc.`course_id`, dc.`is_core`, dc.`created_at`,
       c.`name` AS course_name, c.`description`
FROM `degree_course` dc
JOIN `course` c ON dc.`course_id` = c.`course_id`
WHERE dc.`degree_name` = ? AND dc.`degree_level` = ?
ORDER BY dc.`is_core` DESC, c.`course_id`;

-- READ - Get only core courses for a degree
SELECT dc.`course_id`, dc.`created_at`,
       c.`name` AS course_name, c.`description`
FROM `degree_course` dc
JOIN `course` c ON dc.`course_id` = c.`course_id`
WHERE dc.`degree_name` = ? AND dc.`degree_level` = ? AND dc.`is_core` = 1
ORDER BY c.`course_id`;

-- READ - Get only elective courses for a degree
SELECT dc.`course_id`, dc.`created_at`,
       c.`name` AS course_name, c.`description`
FROM `degree_course` dc
JOIN `course` c ON dc.`course_id` = c.`course_id`
WHERE dc.`degree_name` = ? AND dc.`degree_level` = ? AND dc.`is_core` = 0
ORDER BY c.`course_id`;

-- READ - Get all degrees that include a specific course
SELECT dc.`degree_name`, dc.`degree_level`, dc.`is_core`, dc.`created_at`
FROM `degree_course` dc
JOIN `degree` d ON dc.`degree_name` = d.`name` AND dc.`degree_level` = d.`level`
WHERE dc.`course_id` = ?
ORDER BY dc.`degree_name`, dc.`degree_level`;

-- UPDATE - Update is_core flag
UPDATE `degree_course`
SET `is_core` = ?
WHERE `degree_name` = ? AND `degree_level` = ? AND `course_id` = ?;

-- DELETE - Remove course from degree
DELETE FROM `degree_course`
WHERE `degree_name` = ? AND `degree_level` = ? AND `course_id` = ?;

-- ============================================
-- VALIDATION QUERIES FOR DEGREE_COURSE
-- ============================================

-- Check if degree-course association exists
SELECT COUNT(*) AS count
FROM `degree_course`
WHERE `degree_name` = ? AND `degree_level` = ? AND `course_id` = ?;

-- Check if degree exists (before creating association)
SELECT COUNT(*) AS count
FROM `degree`
WHERE `name` = ? AND `level` = ?;

-- Check if course exists (before creating association)
SELECT COUNT(*) AS count
FROM `course`
WHERE `course_id` = ?;

-- Validate is_core value (must be 0 or 1)
SELECT CASE 
    WHEN ? IN (0, 1) THEN 'Valid is_core value'
    ELSE 'Invalid is_core - must be 0 or 1'
END AS validation_result;

-- Check if degree-course is used in degree_course_objective (before deletion)
SELECT COUNT(*) AS count
FROM `degree_course_objective`
WHERE `degree_name` = ? AND `degree_level` = ? AND `course_id` = ?;

-- ============================================
-- 9. DEGREE_OBJECTIVE TABLE - CRUD Operations
-- ============================================

-- CREATE - Associate an objective with a degree
-- Parameters: @degree_name, @degree_level, @objective_id
INSERT INTO `degree_objective` (`degree_name`, `degree_level`, `objective_id`)
VALUES (?, ?, ?);

-- READ - Get all degree-objective associations
SELECT do.`degree_name`, do.`degree_level`, do.`objective_id`, do.`created_at`,
       o.`title` AS objective_title
FROM `degree_objective` do
JOIN `objective` o ON do.`objective_id` = o.`objective_id`
ORDER BY do.`degree_name`, do.`degree_level`, do.`objective_id`;

-- READ - Get all objectives for a specific degree
SELECT do.`objective_id`, do.`created_at`,
       o.`title`, o.`description`
FROM `degree_objective` do
JOIN `objective` o ON do.`objective_id` = o.`objective_id`
WHERE do.`degree_name` = ? AND do.`degree_level` = ?
ORDER BY do.`objective_id`;

-- READ - Get all degrees that have a specific objective
SELECT do.`degree_name`, do.`degree_level`, do.`created_at`
FROM `degree_objective` do
JOIN `degree` d ON do.`degree_name` = d.`name` AND do.`degree_level` = d.`level`
WHERE do.`objective_id` = ?
ORDER BY do.`degree_name`, do.`degree_level`;

-- UPDATE - No updateable fields (only primary key fields)
SELECT 'Note: Degree-objective associations cannot be updated. Delete and recreate to change.' AS info;

-- DELETE - Remove objective from degree
DELETE FROM `degree_objective`
WHERE `degree_name` = ? AND `degree_level` = ? AND `objective_id` = ?;

-- ============================================
-- VALIDATION QUERIES FOR DEGREE_OBJECTIVE
-- ============================================

-- Check if degree-objective association exists
SELECT COUNT(*) AS count
FROM `degree_objective`
WHERE `degree_name` = ? AND `degree_level` = ? AND `objective_id` = ?;

-- Check if degree exists (before creating association)
SELECT COUNT(*) AS count
FROM `degree`
WHERE `name` = ? AND `level` = ?;

-- Check if objective exists (before creating association)
SELECT COUNT(*) AS count
FROM `objective`
WHERE `objective_id` = ?;

-- ============================================
-- 10. DEGREE_COURSE_OBJECTIVE TABLE - CRUD Operations
-- ============================================

-- CREATE - Associate an objective with a course within a degree
-- Parameters: @degree_name, @degree_level, @course_id, @objective_id
INSERT INTO `degree_course_objective` (`degree_name`, `degree_level`, `course_id`, `objective_id`)
VALUES (?, ?, ?, ?);

-- READ - Get all degree-course-objective associations
SELECT dco.`degree_name`, dco.`degree_level`, dco.`course_id`, dco.`objective_id`, dco.`created_at`,
       c.`name` AS course_name,
       o.`title` AS objective_title
FROM `degree_course_objective` dco
JOIN `course` c ON dco.`course_id` = c.`course_id`
JOIN `objective` o ON dco.`objective_id` = o.`objective_id`
ORDER BY dco.`degree_name`, dco.`degree_level`, dco.`course_id`, dco.`objective_id`;

-- READ - Get all objectives for a course within a degree
SELECT dco.`objective_id`, dco.`created_at`,
       o.`title`, o.`description`
FROM `degree_course_objective` dco
JOIN `objective` o ON dco.`objective_id` = o.`objective_id`
WHERE dco.`degree_name` = ? AND dco.`degree_level` = ? AND dco.`course_id` = ?
ORDER BY dco.`objective_id`;

-- READ - Get all courses with their objectives for a degree
SELECT dco.`course_id`, dco.`objective_id`, dco.`created_at`,
       c.`name` AS course_name,
       o.`title` AS objective_title
FROM `degree_course_objective` dco
JOIN `course` c ON dco.`course_id` = c.`course_id`
JOIN `objective` o ON dco.`objective_id` = o.`objective_id`
WHERE dco.`degree_name` = ? AND dco.`degree_level` = ?
ORDER BY dco.`course_id`, dco.`objective_id`;

-- UPDATE - No updateable fields (only primary key fields)
SELECT 'Note: Degree-course-objective associations cannot be updated. Delete and recreate to change.' AS info;

-- DELETE - Remove objective from course within degree
DELETE FROM `degree_course_objective`
WHERE `degree_name` = ? AND `degree_level` = ? AND `course_id` = ? AND `objective_id` = ?;

-- ============================================
-- VALIDATION QUERIES FOR DEGREE_COURSE_OBJECTIVE
-- ============================================

-- Check if degree-course-objective association exists
SELECT COUNT(*) AS count
FROM `degree_course_objective`
WHERE `degree_name` = ? AND `degree_level` = ? AND `course_id` = ? AND `objective_id` = ?;

-- Check if degree-course association exists (before creating degree-course-objective)
SELECT COUNT(*) AS count
FROM `degree_course`
WHERE `degree_name` = ? AND `degree_level` = ? AND `course_id` = ?;

-- Check if degree-objective association exists (should exist but not required)
SELECT COUNT(*) AS count
FROM `degree_objective`
WHERE `degree_name` = ? AND `degree_level` = ? AND `objective_id` = ?;

-- Check if degree-course-objective is used in evaluations (before deletion)
SELECT COUNT(*) AS count
FROM `evaluation`
WHERE `degree_name` = ? AND `degree_level` = ? AND `course_id` = ? AND `objective_id` = ?;

-- ============================================
-- 11. EVALUATION TABLE - CRUD Operations
-- ============================================

-- CREATE - Insert a new evaluation
-- Parameters: @degree_name, @degree_level, @course_id, @year, @term, @section_number, 
--             @objective_id, @method_name, @count_A, @count_B, @count_C, @count_F, @improvement_suggestion
INSERT INTO `evaluation` (
    `degree_name`, `degree_level`, `course_id`, `year`, `term`, `section_number`,
    `objective_id`, `method_name`, `count_A`, `count_B`, `count_C`, `count_F`, `improvement_suggestion`
)
VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);

-- READ - Get all evaluations
SELECT e.`degree_name`, e.`degree_level`, e.`course_id`, e.`year`, e.`term`, e.`section_number`,
       e.`objective_id`, e.`method_name`, e.`count_A`, e.`count_B`, e.`count_C`, e.`count_F`,
       e.`improvement_suggestion`, e.`created_at`, e.`updated_at`,
       c.`name` AS course_name,
       o.`title` AS objective_title,
       (e.`count_A` + e.`count_B` + e.`count_C` + e.`count_F`) AS total_students
FROM `evaluation` e
JOIN `course` c ON e.`course_id` = c.`course_id`
JOIN `objective` o ON e.`objective_id` = o.`objective_id`
ORDER BY e.`year` DESC, e.`term`, e.`course_id`, e.`section_number`, e.`objective_id`;

-- READ - Get a specific evaluation
SELECT e.`degree_name`, e.`degree_level`, e.`course_id`, e.`year`, e.`term`, e.`section_number`,
       e.`objective_id`, e.`method_name`, e.`count_A`, e.`count_B`, e.`count_C`, e.`count_F`,
       e.`improvement_suggestion`, e.`created_at`, e.`updated_at`,
       c.`name` AS course_name,
       o.`title` AS objective_title,
       (e.`count_A` + e.`count_B` + e.`count_C` + e.`count_F`) AS total_students
FROM `evaluation` e
JOIN `course` c ON e.`course_id` = c.`course_id`
JOIN `objective` o ON e.`objective_id` = o.`objective_id`
WHERE e.`degree_name` = ? AND e.`degree_level` = ? AND e.`course_id` = ? 
      AND e.`year` = ? AND e.`term` = ? AND e.`section_number` = ? AND e.`objective_id` = ?;

-- READ - Get all evaluations for a section
SELECT e.`degree_name`, e.`degree_level`, e.`objective_id`, e.`method_name`, 
       e.`count_A`, e.`count_B`, e.`count_C`, e.`count_F`, e.`improvement_suggestion`,
       e.`created_at`, e.`updated_at`,
       o.`title` AS objective_title,
       (e.`count_A` + e.`count_B` + e.`count_C` + e.`count_F`) AS total_students
FROM `evaluation` e
JOIN `objective` o ON e.`objective_id` = o.`objective_id`
WHERE e.`course_id` = ? AND e.`year` = ? AND e.`term` = ? AND e.`section_number` = ?
ORDER BY e.`objective_id`;

-- READ - Get all evaluations for a section filtered by degree
SELECT e.`objective_id`, e.`method_name`, 
       e.`count_A`, e.`count_B`, e.`count_C`, e.`count_F`, e.`improvement_suggestion`,
       e.`created_at`, e.`updated_at`,
       o.`title` AS objective_title,
       (e.`count_A` + e.`count_B` + e.`count_C` + e.`count_F`) AS total_students
FROM `evaluation` e
JOIN `objective` o ON e.`objective_id` = o.`objective_id`
WHERE e.`course_id` = ? AND e.`year` = ? AND e.`term` = ? AND e.`section_number` = ?
      AND e.`degree_name` = ? AND e.`degree_level` = ?
ORDER BY e.`objective_id`;

-- READ - Get all evaluations for an instructor in a semester
SELECT e.`degree_name`, e.`degree_level`, e.`course_id`, e.`section_number`,
       e.`objective_id`, e.`method_name`, 
       e.`count_A`, e.`count_B`, e.`count_C`, e.`count_F`, e.`improvement_suggestion`,
       c.`name` AS course_name,
       o.`title` AS objective_title
FROM `evaluation` e
JOIN `section` s ON e.`course_id` = s.`course_id` 
                   AND e.`year` = s.`year` 
                   AND e.`term` = s.`term` 
                   AND e.`section_number` = s.`section_number`
JOIN `course` c ON e.`course_id` = c.`course_id`
JOIN `objective` o ON e.`objective_id` = o.`objective_id`
WHERE s.`instructor_id` = ? AND e.`year` = ? AND e.`term` = ?
ORDER BY e.`course_id`, e.`section_number`, e.`objective_id`;

-- READ - Get all evaluations for a degree
SELECT e.`course_id`, e.`year`, e.`term`, e.`section_number`,
       e.`objective_id`, e.`method_name`, 
       e.`count_A`, e.`count_B`, e.`count_C`, e.`count_F`, e.`improvement_suggestion`,
       c.`name` AS course_name,
       o.`title` AS objective_title
FROM `evaluation` e
JOIN `course` c ON e.`course_id` = c.`course_id`
JOIN `objective` o ON e.`objective_id` = o.`objective_id`
WHERE e.`degree_name` = ? AND e.`degree_level` = ?
ORDER BY e.`year` DESC, e.`term`, e.`course_id`, e.`section_number`, e.`objective_id`;

-- READ - Get evaluations by objective
SELECT e.`degree_name`, e.`degree_level`, e.`course_id`, e.`year`, e.`term`, e.`section_number`,
       e.`method_name`, e.`count_A`, e.`count_B`, e.`count_C`, e.`count_F`, e.`improvement_suggestion`,
       c.`name` AS course_name
FROM `evaluation` e
JOIN `course` c ON e.`course_id` = c.`course_id`
WHERE e.`objective_id` = ?
ORDER BY e.`year` DESC, e.`term`, e.`course_id`, e.`section_number`;

-- UPDATE - Update evaluation data
UPDATE `evaluation`
SET 
    `method_name` = ?,
    `count_A` = ?,
    `count_B` = ?,
    `count_C` = ?,
    `count_F` = ?,
    `improvement_suggestion` = ?
WHERE `degree_name` = ? AND `degree_level` = ? AND `course_id` = ? 
      AND `year` = ? AND `term` = ? AND `section_number` = ? AND `objective_id` = ?;

-- UPDATE - Update only evaluation counts
UPDATE `evaluation`
SET 
    `count_A` = ?,
    `count_B` = ?,
    `count_C` = ?,
    `count_F` = ?
WHERE `degree_name` = ? AND `degree_level` = ? AND `course_id` = ? 
      AND `year` = ? AND `term` = ? AND `section_number` = ? AND `objective_id` = ?;

-- UPDATE - Update only improvement suggestion
UPDATE `evaluation`
SET `improvement_suggestion` = ?
WHERE `degree_name` = ? AND `degree_level` = ? AND `course_id` = ? 
      AND `year` = ? AND `term` = ? AND `section_number` = ? AND `objective_id` = ?;

-- UPDATE - Update only method name
UPDATE `evaluation`
SET `method_name` = ?
WHERE `degree_name` = ? AND `degree_level` = ? AND `course_id` = ? 
      AND `year` = ? AND `term` = ? AND `section_number` = ? AND `objective_id` = ?;

-- DELETE - Delete an evaluation
DELETE FROM `evaluation`
WHERE `degree_name` = ? AND `degree_level` = ? AND `course_id` = ? 
      AND `year` = ? AND `term` = ? AND `section_number` = ? AND `objective_id` = ?;

-- ============================================
-- VALIDATION QUERIES FOR EVALUATION
-- ============================================

-- Check if evaluation exists
SELECT COUNT(*) AS count
FROM `evaluation`
WHERE `degree_name` = ? AND `degree_level` = ? AND `course_id` = ? 
      AND `year` = ? AND `term` = ? AND `section_number` = ? AND `objective_id` = ?;

-- Validate count values (must be >= 0)
SELECT CASE 
    WHEN ? >= 0 AND ? >= 0 AND ? >= 0 AND ? >= 0 THEN 'Valid counts'
    ELSE 'Invalid counts - must be >= 0'
END AS validation_result;

-- Check if section exists (before inserting evaluation)
SELECT COUNT(*) AS count
FROM `section`
WHERE `course_id` = ? AND `year` = ? AND `term` = ? AND `section_number` = ?;

-- Check if degree exists (before inserting evaluation)
SELECT COUNT(*) AS count
FROM `degree`
WHERE `name` = ? AND `level` = ?;

-- Check if objective exists (before inserting evaluation)
SELECT COUNT(*) AS count
FROM `objective`
WHERE `objective_id` = ?;

-- Check if evaluation method exists (before inserting evaluation)
SELECT COUNT(*) AS count
FROM `evaluation_method`
WHERE `name` = ?;

-- Check if degree-course-objective association exists (before inserting evaluation)
SELECT COUNT(*) AS count
FROM `degree_course_objective`
WHERE `degree_name` = ? AND `degree_level` = ? AND `course_id` = ? AND `objective_id` = ?;

-- Check if counts match enrollment (optional validation)
SELECT 
    s.`enrollment_count` AS section_enrollment,
    (e.`count_A` + e.`count_B` + e.`count_C` + e.`count_F`) AS evaluation_total,
    CASE 
        WHEN (e.`count_A` + e.`count_B` + e.`count_C` + e.`count_F`) <= s.`enrollment_count` 
        THEN 'Valid' 
        ELSE 'Warning: Evaluation total exceeds enrollment count' 
    END AS validation_result
FROM `evaluation` e
JOIN `section` s ON e.`course_id` = s.`course_id` 
                   AND e.`year` = s.`year` 
                   AND e.`term` = s.`term` 
                   AND e.`section_number` = s.`section_number`
WHERE e.`degree_name` = ? AND e.`degree_level` = ? AND e.`course_id` = ? 
      AND e.`year` = ? AND e.`term` = ? AND e.`section_number` = ? AND e.`objective_id` = ?;

-- ============================================
-- BUSINESS LOGIC QUERIES
-- ============================================

-- Get sections for an instructor in a semester (for evaluation entry flow)
SELECT s.`course_id`, s.`section_number`, s.`enrollment_count`,
       c.`name` AS course_name
FROM `section` s
JOIN `course` c ON s.`course_id` = c.`course_id`
WHERE s.`instructor_id` = ? AND s.`year` = ? AND s.`term` = ?
ORDER BY s.`course_id`, s.`section_number`;

-- Get objectives for a course within a degree (for evaluation entry)
SELECT dco.`objective_id`, o.`title`, o.`description`
FROM `degree_course_objective` dco
JOIN `objective` o ON dco.`objective_id` = o.`objective_id`
WHERE dco.`degree_name` = ? AND dco.`degree_level` = ? AND dco.`course_id` = ?
ORDER BY dco.`objective_id`;

-- Check evaluation completion status for a section (what's entered vs what's required)
SELECT 
    dco.`objective_id`,
    o.`title` AS objective_title,
    CASE 
        WHEN e.`objective_id` IS NOT NULL THEN 'Entered'
        ELSE 'Not Entered'
    END AS status,
    e.`method_name`,
    e.`count_A`, e.`count_B`, e.`count_C`, e.`count_F`,
    e.`improvement_suggestion`
FROM `degree_course_objective` dco
JOIN `objective` o ON dco.`objective_id` = o.`objective_id`
LEFT JOIN `evaluation` e ON dco.`degree_name` = e.`degree_name` 
                          AND dco.`degree_level` = e.`degree_level`
                          AND dco.`course_id` = e.`course_id`
                          AND dco.`objective_id` = e.`objective_id`
                          AND e.`year` = ?
                          AND e.`term` = ?
                          AND e.`section_number` = ?
WHERE dco.`degree_name` = ? AND dco.`degree_level` = ? AND dco.`course_id` = ?
ORDER BY dco.`objective_id`;

-- Get summary statistics for a section
SELECT 
    COUNT(DISTINCT e.`objective_id`) AS objectives_evaluated,
    (SELECT COUNT(*) 
     FROM `degree_course_objective` 
     WHERE `degree_name` = ? AND `degree_level` = ? AND `course_id` = ?) AS total_objectives,
    SUM(e.`count_A`) AS total_A,
    SUM(e.`count_B`) AS total_B,
    SUM(e.`count_C`) AS total_C,
    SUM(e.`count_F`) AS total_F,
    SUM(e.`count_A` + e.`count_B` + e.`count_C` + e.`count_F`) AS total_students
FROM `evaluation` e
WHERE e.`degree_name` = ? AND e.`degree_level` = ? 
      AND e.`course_id` = ? AND e.`year` = ? AND e.`term` = ? AND e.`section_number` = ?;

-- ============================================
-- END OF CRUD QUERIES FILE
-- ============================================

