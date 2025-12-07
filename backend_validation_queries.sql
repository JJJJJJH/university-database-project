-- ============================================
-- Program Evaluation System - Backend Validation Queries
-- For Backend Developers
-- ============================================
-- This file contains comprehensive validation queries
-- for data integrity, foreign key constraints, and business rules
-- ============================================

USE program_evaluation;

-- ============================================
-- GENERAL VALIDATION FUNCTIONS
-- ============================================

-- Check if a value is NULL or empty string
-- Returns: 1 if valid (not NULL and not empty), 0 if invalid
-- Usage: SELECT CASE WHEN ? IS NOT NULL AND ? != '' THEN 1 ELSE 0 END AS is_valid;

-- Check if a string length is within range
-- Returns: 1 if valid, 0 if invalid
-- Usage: SELECT CASE WHEN LENGTH(?) BETWEEN ? AND ? THEN 1 ELSE 0 END AS is_valid_length;

-- ============================================
-- 1. DEGREE VALIDATION
-- ============================================

-- Validate degree name (not NULL, not empty)
SELECT CASE 
    WHEN ? IS NOT NULL AND ? != '' THEN 1
    ELSE 0
END AS is_valid_degree_name;

-- Validate degree level enum
SELECT CASE 
    WHEN ? IN ('BA', 'BS', 'MS', 'PhD', 'Cert') THEN 1
    ELSE 0
END AS is_valid_degree_level;

-- Check if degree already exists (for INSERT validation)
SELECT COUNT(*) AS exists_count
FROM `degree`
WHERE `name` = ? AND `level` = ?;

-- Check if degree is referenced before DELETE
SELECT 
    (SELECT COUNT(*) FROM `degree_course` 
     WHERE `degree_name` = ? AND `degree_level` = ?) AS degree_course_count,
    (SELECT COUNT(*) FROM `degree_objective` 
     WHERE `degree_name` = ? AND `degree_level` = ?) AS degree_objective_count,
    (SELECT COUNT(*) FROM `degree_course_objective` 
     WHERE `degree_name` = ? AND `degree_level` = ?) AS degree_course_objective_count,
    (SELECT COUNT(*) FROM `evaluation` 
     WHERE `degree_name` = ? AND `degree_level` = ?) AS evaluation_count;

-- Comprehensive degree validation for INSERT
SELECT 
    CASE WHEN ? IS NULL OR ? = '' THEN 'Degree name is required' ELSE NULL END AS name_error,
    CASE WHEN ? NOT IN ('BA', 'BS', 'MS', 'PhD', 'Cert') THEN 'Invalid degree level' ELSE NULL END AS level_error,
    CASE WHEN (SELECT COUNT(*) FROM `degree` WHERE `name` = ? AND `level` = ?) > 0 
         THEN 'Degree already exists' ELSE NULL END AS duplicate_error;

-- ============================================
-- 2. COURSE VALIDATION
-- ============================================

-- Validate course_id format (typically: 2-4 letters + 3-4 digits, max 10 chars)
SELECT CASE 
    WHEN ? REGEXP '^[A-Z]{2,4}[0-9]{3,4}$' AND LENGTH(?) <= 10 THEN 1
    ELSE 0
END AS is_valid_course_id_format;

-- Validate course name (not NULL, not empty, unique)
SELECT CASE 
    WHEN ? IS NULL OR ? = '' THEN 0
    ELSE 1
END AS is_valid_course_name;

-- Check if course_id already exists
SELECT COUNT(*) AS exists_count
FROM `course`
WHERE `course_id` = ?;

-- Check if course name already exists (excluding current course_id)
SELECT COUNT(*) AS exists_count
FROM `course`
WHERE `name` = ? AND `course_id` != ?;

-- Check if course is referenced before DELETE
SELECT 
    (SELECT COUNT(*) FROM `degree_course` WHERE `course_id` = ?) AS degree_course_count,
    (SELECT COUNT(*) FROM `degree_course_objective` WHERE `course_id` = ?) AS degree_course_objective_count,
    (SELECT COUNT(*) FROM `section` WHERE `course_id` = ?) AS section_count,
    (SELECT COUNT(*) FROM `evaluation` WHERE `course_id` = ?) AS evaluation_count;

-- Comprehensive course validation for INSERT
SELECT 
    CASE WHEN ? IS NULL OR ? = '' THEN 'Course ID is required' ELSE NULL END AS course_id_error,
    CASE WHEN ? NOT REGEXP '^[A-Z]{2,4}[0-9]{3,4}$' THEN 'Invalid course ID format' ELSE NULL END AS course_id_format_error,
    CASE WHEN LENGTH(?) > 10 THEN 'Course ID too long (max 10 characters)' ELSE NULL END AS course_id_length_error,
    CASE WHEN ? IS NULL OR ? = '' THEN 'Course name is required' ELSE NULL END AS name_error,
    CASE WHEN (SELECT COUNT(*) FROM `course` WHERE `course_id` = ?) > 0 
         THEN 'Course ID already exists' ELSE NULL END AS duplicate_id_error,
    CASE WHEN (SELECT COUNT(*) FROM `course` WHERE `name` = ?) > 0 
         THEN 'Course name already exists' ELSE NULL END AS duplicate_name_error;

-- Comprehensive course validation for UPDATE
SELECT 
    CASE WHEN ? IS NULL OR ? = '' THEN 'Course name is required' ELSE NULL END AS name_error,
    CASE WHEN (SELECT COUNT(*) FROM `course` WHERE `name` = ? AND `course_id` != ?) > 0 
         THEN 'Course name already exists' ELSE NULL END AS duplicate_name_error;

-- ============================================
-- 3. INSTRUCTOR VALIDATION
-- ============================================

-- Validate instructor_id format
SELECT CASE 
    WHEN ? REGEXP '^[A-Z0-9]{3,20}$' THEN 1
    ELSE 0
END AS is_valid_instructor_id_format;

-- Validate email format
SELECT CASE 
    WHEN ? REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN 1
    WHEN ? IS NULL THEN 1  -- Email is optional
    ELSE 0
END AS is_valid_email_format;

-- Check if instructor_id already exists
SELECT COUNT(*) AS exists_count
FROM `instructor`
WHERE `instructor_id` = ?;

-- Check if email already exists (excluding current instructor_id)
SELECT COUNT(*) AS exists_count
FROM `instructor`
WHERE `email` = ? AND `email` IS NOT NULL AND `instructor_id` != ?;

-- Check if instructor teaches sections before DELETE (RESTRICT)
SELECT COUNT(*) AS section_count
FROM `section`
WHERE `instructor_id` = ?;

-- Comprehensive instructor validation for INSERT
SELECT 
    CASE WHEN ? IS NULL OR ? = '' THEN 'Instructor ID is required' ELSE NULL END AS instructor_id_error,
    CASE WHEN ? NOT REGEXP '^[A-Z0-9]{3,20}$' THEN 'Invalid instructor ID format' ELSE NULL END AS instructor_id_format_error,
    CASE WHEN ? IS NULL OR ? = '' THEN 'Instructor name is required' ELSE NULL END AS name_error,
    CASE WHEN ? IS NOT NULL AND ? NOT REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' 
         THEN 'Invalid email format' ELSE NULL END AS email_error,
    CASE WHEN (SELECT COUNT(*) FROM `instructor` WHERE `instructor_id` = ?) > 0 
         THEN 'Instructor ID already exists' ELSE NULL END AS duplicate_id_error,
    CASE WHEN ? IS NOT NULL AND (SELECT COUNT(*) FROM `instructor` WHERE `email` = ?) > 0 
         THEN 'Email already exists' ELSE NULL END AS duplicate_email_error;

-- Comprehensive instructor validation for UPDATE
SELECT 
    CASE WHEN ? IS NULL OR ? = '' THEN 'Instructor name is required' ELSE NULL END AS name_error,
    CASE WHEN ? IS NOT NULL AND ? NOT REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' 
         THEN 'Invalid email format' ELSE NULL END AS email_error,
    CASE WHEN ? IS NOT NULL AND (SELECT COUNT(*) FROM `instructor` WHERE `email` = ? AND `instructor_id` != ?) > 0 
         THEN 'Email already exists' ELSE NULL END AS duplicate_email_error;

-- ============================================
-- 4. SEMESTER VALIDATION
-- ============================================

-- Validate year (must be >= 2000)
SELECT CASE 
    WHEN ? >= 2000 THEN 1
    ELSE 0
END AS is_valid_year;

-- Validate term enum
SELECT CASE 
    WHEN ? IN ('Spring', 'Summer', 'Fall') THEN 1
    ELSE 0
END AS is_valid_term;

-- Check if semester already exists
SELECT COUNT(*) AS exists_count
FROM `semester`
WHERE `year` = ? AND `term` = ?;

-- Check if semester is referenced before DELETE
SELECT COUNT(*) AS section_count
FROM `section`
WHERE `year` = ? AND `term` = ?;

-- Comprehensive semester validation for INSERT
SELECT 
    CASE WHEN ? IS NULL THEN 'Year is required' ELSE NULL END AS year_error,
    CASE WHEN ? < 2000 THEN 'Year must be >= 2000' ELSE NULL END AS year_range_error,
    CASE WHEN ? NOT IN ('Spring', 'Summer', 'Fall') THEN 'Invalid term' ELSE NULL END AS term_error,
    CASE WHEN (SELECT COUNT(*) FROM `semester` WHERE `year` = ? AND `term` = ?) > 0 
         THEN 'Semester already exists' ELSE NULL END AS duplicate_error;

-- ============================================
-- 5. SECTION VALIDATION
-- ============================================

-- Validate section_number format
SELECT CASE 
    WHEN ? REGEXP '^[0-9]{3}$' THEN 1
    ELSE 0
END AS is_valid_section_number_format;

-- Validate enrollment_count (must be >= 0)
SELECT CASE 
    WHEN ? IS NULL OR ? >= 0 THEN 1
    ELSE 0
END AS is_valid_enrollment_count;

-- Check if section already exists
SELECT COUNT(*) AS exists_count
FROM `section`
WHERE `course_id` = ? AND `year` = ? AND `term` = ? AND `section_number` = ?;

-- Validate foreign key: course exists
SELECT COUNT(*) AS course_exists
FROM `course`
WHERE `course_id` = ?;

-- Validate foreign key: semester exists
SELECT COUNT(*) AS semester_exists
FROM `semester`
WHERE `year` = ? AND `term` = ?;

-- Validate foreign key: instructor exists
SELECT COUNT(*) AS instructor_exists
FROM `instructor`
WHERE `instructor_id` = ?;

-- Comprehensive section validation for INSERT
SELECT 
    CASE WHEN ? IS NULL OR ? = '' THEN 'Course ID is required' ELSE NULL END AS course_id_error,
    CASE WHEN (SELECT COUNT(*) FROM `course` WHERE `course_id` = ?) = 0 
         THEN 'Course does not exist' ELSE NULL END AS course_not_found_error,
    CASE WHEN ? IS NULL THEN 'Year is required' ELSE NULL END AS year_error,
    CASE WHEN ? IS NULL THEN 'Term is required' ELSE NULL END AS term_error,
    CASE WHEN (SELECT COUNT(*) FROM `semester` WHERE `year` = ? AND `term` = ?) = 0 
         THEN 'Semester does not exist' ELSE NULL END AS semester_not_found_error,
    CASE WHEN ? IS NULL OR ? = '' THEN 'Section number is required' ELSE NULL END AS section_number_error,
    CASE WHEN ? NOT REGEXP '^[0-9]{3}$' THEN 'Invalid section number format (must be 3 digits)' ELSE NULL END AS section_number_format_error,
    CASE WHEN ? IS NULL OR ? = '' THEN 'Instructor ID is required' ELSE NULL END AS instructor_id_error,
    CASE WHEN (SELECT COUNT(*) FROM `instructor` WHERE `instructor_id` = ?) = 0 
         THEN 'Instructor does not exist' ELSE NULL END AS instructor_not_found_error,
    CASE WHEN ? IS NOT NULL AND ? < 0 THEN 'Enrollment count must be >= 0' ELSE NULL END AS enrollment_error,
    CASE WHEN (SELECT COUNT(*) FROM `section` WHERE `course_id` = ? AND `year` = ? AND `term` = ? AND `section_number` = ?) > 0 
         THEN 'Section already exists' ELSE NULL END AS duplicate_error;

-- ============================================
-- 6. OBJECTIVE VALIDATION
-- ============================================

-- Validate objective_id format
SELECT CASE 
    WHEN ? REGEXP '^[A-Z0-9]{3,20}$' THEN 1
    ELSE 0
END AS is_valid_objective_id_format;

-- Validate title length (must be <= 120 characters)
SELECT CASE 
    WHEN ? IS NOT NULL AND LENGTH(?) <= 120 THEN 1
    ELSE 0
END AS is_valid_title_length;

-- Check if objective_id already exists
SELECT COUNT(*) AS exists_count
FROM `objective`
WHERE `objective_id` = ?;

-- Check if objective title already exists (excluding current objective_id)
SELECT COUNT(*) AS exists_count
FROM `objective`
WHERE `title` = ? AND `objective_id` != ?;

-- Check if objective is referenced before DELETE
SELECT 
    (SELECT COUNT(*) FROM `degree_objective` WHERE `objective_id` = ?) AS degree_objective_count,
    (SELECT COUNT(*) FROM `degree_course_objective` WHERE `objective_id` = ?) AS degree_course_objective_count,
    (SELECT COUNT(*) FROM `evaluation` WHERE `objective_id` = ?) AS evaluation_count;

-- Comprehensive objective validation for INSERT
SELECT 
    CASE WHEN ? IS NULL OR ? = '' THEN 'Objective ID is required' ELSE NULL END AS objective_id_error,
    CASE WHEN ? NOT REGEXP '^[A-Z0-9]{3,20}$' THEN 'Invalid objective ID format' ELSE NULL END AS objective_id_format_error,
    CASE WHEN ? IS NULL OR ? = '' THEN 'Objective title is required' ELSE NULL END AS title_error,
    CASE WHEN LENGTH(?) > 120 THEN 'Title too long (max 120 characters)' ELSE NULL END AS title_length_error,
    CASE WHEN (SELECT COUNT(*) FROM `objective` WHERE `objective_id` = ?) > 0 
         THEN 'Objective ID already exists' ELSE NULL END AS duplicate_id_error,
    CASE WHEN (SELECT COUNT(*) FROM `objective` WHERE `title` = ?) > 0 
         THEN 'Objective title already exists' ELSE NULL END AS duplicate_title_error;

-- Comprehensive objective validation for UPDATE
SELECT 
    CASE WHEN ? IS NULL OR ? = '' THEN 'Objective title is required' ELSE NULL END AS title_error,
    CASE WHEN LENGTH(?) > 120 THEN 'Title too long (max 120 characters)' ELSE NULL END AS title_length_error,
    CASE WHEN (SELECT COUNT(*) FROM `objective` WHERE `title` = ? AND `objective_id` != ?) > 0 
         THEN 'Objective title already exists' ELSE NULL END AS duplicate_title_error;

-- ============================================
-- 7. EVALUATION_METHOD VALIDATION
-- ============================================

-- Validate method name (not NULL, not empty)
SELECT CASE 
    WHEN ? IS NOT NULL AND ? != '' THEN 1
    ELSE 0
END AS is_valid_method_name;

-- Check if evaluation method already exists
SELECT COUNT(*) AS exists_count
FROM `evaluation_method`
WHERE `name` = ?;

-- Check if evaluation method is used before DELETE (RESTRICT)
SELECT COUNT(*) AS evaluation_count
FROM `evaluation`
WHERE `method_name` = ?;

-- Comprehensive evaluation method validation for INSERT
SELECT 
    CASE WHEN ? IS NULL OR ? = '' THEN 'Evaluation method name is required' ELSE NULL END AS name_error,
    CASE WHEN (SELECT COUNT(*) FROM `evaluation_method` WHERE `name` = ?) > 0 
         THEN 'Evaluation method already exists' ELSE NULL END AS duplicate_error;

-- ============================================
-- 8. DEGREE_COURSE VALIDATION
-- ============================================

-- Validate is_core (must be 0 or 1)
SELECT CASE 
    WHEN ? IN (0, 1) THEN 1
    ELSE 0
END AS is_valid_is_core;

-- Check if degree-course association already exists
SELECT COUNT(*) AS exists_count
FROM `degree_course`
WHERE `degree_name` = ? AND `degree_level` = ? AND `course_id` = ?;

-- Validate foreign key: degree exists
SELECT COUNT(*) AS degree_exists
FROM `degree`
WHERE `name` = ? AND `level` = ?;

-- Validate foreign key: course exists
SELECT COUNT(*) AS course_exists
FROM `course`
WHERE `course_id` = ?;

-- Comprehensive degree-course validation for INSERT
SELECT 
    CASE WHEN ? IS NULL OR ? = '' THEN 'Degree name is required' ELSE NULL END AS degree_name_error,
    CASE WHEN ? NOT IN ('BA', 'BS', 'MS', 'PhD', 'Cert') THEN 'Invalid degree level' ELSE NULL END AS degree_level_error,
    CASE WHEN (SELECT COUNT(*) FROM `degree` WHERE `name` = ? AND `level` = ?) = 0 
         THEN 'Degree does not exist' ELSE NULL END AS degree_not_found_error,
    CASE WHEN ? IS NULL OR ? = '' THEN 'Course ID is required' ELSE NULL END AS course_id_error,
    CASE WHEN (SELECT COUNT(*) FROM `course` WHERE `course_id` = ?) = 0 
         THEN 'Course does not exist' ELSE NULL END AS course_not_found_error,
    CASE WHEN ? NOT IN (0, 1) THEN 'is_core must be 0 or 1' ELSE NULL END AS is_core_error,
    CASE WHEN (SELECT COUNT(*) FROM `degree_course` WHERE `degree_name` = ? AND `degree_level` = ? AND `course_id` = ?) > 0 
         THEN 'Degree-course association already exists' ELSE NULL END AS duplicate_error;

-- ============================================
-- 9. DEGREE_OBJECTIVE VALIDATION
-- ============================================

-- Check if degree-objective association already exists
SELECT COUNT(*) AS exists_count
FROM `degree_objective`
WHERE `degree_name` = ? AND `degree_level` = ? AND `objective_id` = ?;

-- Validate foreign key: degree exists
SELECT COUNT(*) AS degree_exists
FROM `degree`
WHERE `name` = ? AND `level` = ?;

-- Validate foreign key: objective exists
SELECT COUNT(*) AS objective_exists
FROM `objective`
WHERE `objective_id` = ?;

-- Comprehensive degree-objective validation for INSERT
SELECT 
    CASE WHEN ? IS NULL OR ? = '' THEN 'Degree name is required' ELSE NULL END AS degree_name_error,
    CASE WHEN ? NOT IN ('BA', 'BS', 'MS', 'PhD', 'Cert') THEN 'Invalid degree level' ELSE NULL END AS degree_level_error,
    CASE WHEN (SELECT COUNT(*) FROM `degree` WHERE `name` = ? AND `level` = ?) = 0 
         THEN 'Degree does not exist' ELSE NULL END AS degree_not_found_error,
    CASE WHEN ? IS NULL OR ? = '' THEN 'Objective ID is required' ELSE NULL END AS objective_id_error,
    CASE WHEN (SELECT COUNT(*) FROM `objective` WHERE `objective_id` = ?) = 0 
         THEN 'Objective does not exist' ELSE NULL END AS objective_not_found_error,
    CASE WHEN (SELECT COUNT(*) FROM `degree_objective` WHERE `degree_name` = ? AND `degree_level` = ? AND `objective_id` = ?) > 0 
         THEN 'Degree-objective association already exists' ELSE NULL END AS duplicate_error;

-- ============================================
-- 10. DEGREE_COURSE_OBJECTIVE VALIDATION
-- ============================================

-- Check if degree-course-objective association already exists
SELECT COUNT(*) AS exists_count
FROM `degree_course_objective`
WHERE `degree_name` = ? AND `degree_level` = ? AND `course_id` = ? AND `objective_id` = ?;

-- Validate foreign key: degree-course exists (recommended but not required)
SELECT COUNT(*) AS degree_course_exists
FROM `degree_course`
WHERE `degree_name` = ? AND `degree_level` = ? AND `course_id` = ?;

-- Validate foreign key: degree exists
SELECT COUNT(*) AS degree_exists
FROM `degree`
WHERE `name` = ? AND `level` = ?;

-- Validate foreign key: course exists
SELECT COUNT(*) AS course_exists
FROM `course`
WHERE `course_id` = ?;

-- Validate foreign key: objective exists
SELECT COUNT(*) AS objective_exists
FROM `objective`
WHERE `objective_id` = ?;

-- Comprehensive degree-course-objective validation for INSERT
SELECT 
    CASE WHEN ? IS NULL OR ? = '' THEN 'Degree name is required' ELSE NULL END AS degree_name_error,
    CASE WHEN ? NOT IN ('BA', 'BS', 'MS', 'PhD', 'Cert') THEN 'Invalid degree level' ELSE NULL END AS degree_level_error,
    CASE WHEN (SELECT COUNT(*) FROM `degree` WHERE `name` = ? AND `level` = ?) = 0 
         THEN 'Degree does not exist' ELSE NULL END AS degree_not_found_error,
    CASE WHEN ? IS NULL OR ? = '' THEN 'Course ID is required' ELSE NULL END AS course_id_error,
    CASE WHEN (SELECT COUNT(*) FROM `course` WHERE `course_id` = ?) = 0 
         THEN 'Course does not exist' ELSE NULL END AS course_not_found_error,
    CASE WHEN ? IS NULL OR ? = '' THEN 'Objective ID is required' ELSE NULL END AS objective_id_error,
    CASE WHEN (SELECT COUNT(*) FROM `objective` WHERE `objective_id` = ?) = 0 
         THEN 'Objective does not exist' ELSE NULL END AS objective_not_found_error,
    CASE WHEN (SELECT COUNT(*) FROM `degree_course` WHERE `degree_name` = ? AND `degree_level` = ? AND `course_id` = ?) = 0 
         THEN 'Warning: Degree-course association does not exist' ELSE NULL END AS degree_course_warning,
    CASE WHEN (SELECT COUNT(*) FROM `degree_course_objective` WHERE `degree_name` = ? AND `degree_level` = ? AND `course_id` = ? AND `objective_id` = ?) > 0 
         THEN 'Degree-course-objective association already exists' ELSE NULL END AS duplicate_error;

-- ============================================
-- 11. EVALUATION VALIDATION
-- ============================================

-- Validate count values (must be >= 0)
SELECT CASE 
    WHEN ? >= 0 AND ? >= 0 AND ? >= 0 AND ? >= 0 THEN 1
    ELSE 0
END AS are_valid_counts;

-- Check if evaluation already exists
SELECT COUNT(*) AS exists_count
FROM `evaluation`
WHERE `degree_name` = ? AND `degree_level` = ? AND `course_id` = ? 
      AND `year` = ? AND `term` = ? AND `section_number` = ? AND `objective_id` = ?;

-- Validate foreign key: section exists
SELECT COUNT(*) AS section_exists
FROM `section`
WHERE `course_id` = ? AND `year` = ? AND `term` = ? AND `section_number` = ?;

-- Validate foreign key: degree exists
SELECT COUNT(*) AS degree_exists
FROM `degree`
WHERE `name` = ? AND `level` = ?;

-- Validate foreign key: objective exists
SELECT COUNT(*) AS objective_exists
FROM `objective`
WHERE `objective_id` = ?;

-- Validate foreign key: evaluation method exists
SELECT COUNT(*) AS method_exists
FROM `evaluation_method`
WHERE `name` = ?;

-- Validate foreign key: degree-course-objective exists (required constraint)
SELECT COUNT(*) AS dco_exists
FROM `degree_course_objective`
WHERE `degree_name` = ? AND `degree_level` = ? AND `course_id` = ? AND `objective_id` = ?;

-- Validate counts against enrollment (warning only, not error)
SELECT 
    s.`enrollment_count` AS section_enrollment,
    CASE 
        WHEN (? + ? + ? + ?) <= s.`enrollment_count` THEN 1
        ELSE 0
    END AS counts_valid_vs_enrollment
FROM `section` s
WHERE s.`course_id` = ? AND s.`year` = ? AND s.`term` = ? AND s.`section_number` = ?;

-- Comprehensive evaluation validation for INSERT
SELECT 
    CASE WHEN ? IS NULL OR ? = '' THEN 'Degree name is required' ELSE NULL END AS degree_name_error,
    CASE WHEN ? NOT IN ('BA', 'BS', 'MS', 'PhD', 'Cert') THEN 'Invalid degree level' ELSE NULL END AS degree_level_error,
    CASE WHEN (SELECT COUNT(*) FROM `degree` WHERE `name` = ? AND `level` = ?) = 0 
         THEN 'Degree does not exist' ELSE NULL END AS degree_not_found_error,
    CASE WHEN ? IS NULL OR ? = '' THEN 'Course ID is required' ELSE NULL END AS course_id_error,
    CASE WHEN ? IS NULL THEN 'Year is required' ELSE NULL END AS year_error,
    CASE WHEN ? IS NULL THEN 'Term is required' ELSE NULL END AS term_error,
    CASE WHEN ? IS NULL OR ? = '' THEN 'Section number is required' ELSE NULL END AS section_number_error,
    CASE WHEN (SELECT COUNT(*) FROM `section` WHERE `course_id` = ? AND `year` = ? AND `term` = ? AND `section_number` = ?) = 0 
         THEN 'Section does not exist' ELSE NULL END AS section_not_found_error,
    CASE WHEN ? IS NULL OR ? = '' THEN 'Objective ID is required' ELSE NULL END AS objective_id_error,
    CASE WHEN (SELECT COUNT(*) FROM `objective` WHERE `objective_id` = ?) = 0 
         THEN 'Objective does not exist' ELSE NULL END AS objective_not_found_error,
    CASE WHEN ? IS NULL OR ? = '' THEN 'Evaluation method is required' ELSE NULL END AS method_error,
    CASE WHEN (SELECT COUNT(*) FROM `evaluation_method` WHERE `name` = ?) = 0 
         THEN 'Evaluation method does not exist' ELSE NULL END AS method_not_found_error,
    CASE WHEN (SELECT COUNT(*) FROM `degree_course_objective` WHERE `degree_name` = ? AND `degree_level` = ? AND `course_id` = ? AND `objective_id` = ?) = 0 
         THEN 'Degree-course-objective association does not exist' ELSE NULL END AS dco_not_found_error,
    CASE WHEN ? IS NULL OR ? < 0 THEN 'count_A must be >= 0' ELSE NULL END AS count_A_error,
    CASE WHEN ? IS NULL OR ? < 0 THEN 'count_B must be >= 0' ELSE NULL END AS count_B_error,
    CASE WHEN ? IS NULL OR ? < 0 THEN 'count_C must be >= 0' ELSE NULL END AS count_C_error,
    CASE WHEN ? IS NULL OR ? < 0 THEN 'count_F must be >= 0' ELSE NULL END AS count_F_error,
    CASE WHEN (SELECT COUNT(*) FROM `evaluation` WHERE `degree_name` = ? AND `degree_level` = ? AND `course_id` = ? 
               AND `year` = ? AND `term` = ? AND `section_number` = ? AND `objective_id` = ?) > 0 
         THEN 'Evaluation already exists' ELSE NULL END AS duplicate_error;

-- Comprehensive evaluation validation for UPDATE
SELECT 
    CASE WHEN ? IS NULL OR ? = '' THEN 'Evaluation method is required' ELSE NULL END AS method_error,
    CASE WHEN (SELECT COUNT(*) FROM `evaluation_method` WHERE `name` = ?) = 0 
         THEN 'Evaluation method does not exist' ELSE NULL END AS method_not_found_error,
    CASE WHEN ? IS NULL OR ? < 0 THEN 'count_A must be >= 0' ELSE NULL END AS count_A_error,
    CASE WHEN ? IS NULL OR ? < 0 THEN 'count_B must be >= 0' ELSE NULL END AS count_B_error,
    CASE WHEN ? IS NULL OR ? < 0 THEN 'count_C must be >= 0' ELSE NULL END AS count_C_error,
    CASE WHEN ? IS NULL OR ? < 0 THEN 'count_F must be >= 0' ELSE NULL END AS count_F_error;

-- ============================================
-- BUSINESS RULE VALIDATIONS
-- ============================================

-- Validate that all required evaluations are entered for a section
-- Returns objectives that are required but not yet evaluated
SELECT 
    dco.`objective_id`,
    o.`title` AS objective_title
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
      AND e.`objective_id` IS NULL
ORDER BY dco.`objective_id`;

-- Validate evaluation counts don't exceed enrollment
SELECT 
    e.`objective_id`,
    o.`title` AS objective_title,
    (e.`count_A` + e.`count_B` + e.`count_C` + e.`count_F`) AS evaluation_total,
    s.`enrollment_count` AS section_enrollment,
    CASE 
        WHEN (e.`count_A` + e.`count_B` + e.`count_C` + e.`count_F`) > s.`enrollment_count` 
        THEN 'Warning: Evaluation total exceeds enrollment'
        ELSE 'OK'
    END AS validation_status
FROM `evaluation` e
JOIN `section` s ON e.`course_id` = s.`course_id` 
                   AND e.`year` = s.`year` 
                   AND e.`term` = s.`term` 
                   AND e.`section_number` = s.`section_number`
JOIN `objective` o ON e.`objective_id` = o.`objective_id`
WHERE e.`degree_name` = ? AND e.`degree_level` = ? 
      AND e.`course_id` = ? AND e.`year` = ? AND e.`term` = ? AND e.`section_number` = ?
      AND (e.`count_A` + e.`count_B` + e.`count_C` + e.`count_F`) > s.`enrollment_count`;

-- ============================================
-- END OF VALIDATION QUERIES FILE
-- ============================================

