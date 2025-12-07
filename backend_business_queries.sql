-- ============================================
-- Program Evaluation System - Business Logic Queries
-- For Backend Developers
-- ============================================
-- This file contains complex queries for business logic
-- including evaluation entry workflow, reports, and analytics
-- ============================================

USE program_evaluation;

-- ============================================
-- EVALUATION ENTRY WORKFLOW QUERIES
-- ============================================

-- Get all sections taught by an instructor in a semester
-- Used for: Evaluation entry - Step 1 (select instructor and semester)
SELECT s.`course_id`, s.`section_number`, s.`enrollment_count`,
       c.`name` AS course_name
FROM `section` s
JOIN `course` c ON s.`course_id` = c.`course_id`
WHERE s.`instructor_id` = ? AND s.`year` = ? AND s.`term` = ?
ORDER BY s.`course_id`, s.`section_number`;

-- Get sections with evaluation completion status for an instructor
-- Used for: Evaluation entry - Overview of what needs to be entered
SELECT 
    s.`course_id`, 
    s.`section_number`, 
    c.`name` AS course_name,
    s.`enrollment_count`,
    COUNT(DISTINCT dco.`objective_id`) AS total_objectives,
    COUNT(DISTINCT e.`objective_id`) AS evaluated_objectives,
    CASE 
        WHEN COUNT(DISTINCT dco.`objective_id`) = 0 THEN 'No objectives defined'
        WHEN COUNT(DISTINCT dco.`objective_id`) = COUNT(DISTINCT e.`objective_id`) THEN 'Complete'
        ELSE CONCAT(COUNT(DISTINCT e.`objective_id'), '/', COUNT(DISTINCT dco.`objective_id`), ' evaluated')
    END AS completion_status
FROM `section` s
JOIN `course` c ON s.`course_id` = c.`course_id`
JOIN `degree_course_objective` dco ON s.`course_id` = dco.`course_id`
LEFT JOIN `evaluation` e ON dco.`degree_name` = e.`degree_name` 
                          AND dco.`degree_level` = e.`degree_level`
                          AND dco.`course_id` = e.`course_id`
                          AND dco.`objective_id` = e.`objective_id`
                          AND e.`year` = s.`year`
                          AND e.`term` = s.`term`
                          AND e.`section_number` = s.`section_number`
WHERE s.`instructor_id` = ? AND s.`year` = ? AND s.`term` = ?
      AND dco.`degree_name` = ? AND dco.`degree_level` = ?
GROUP BY s.`course_id`, s.`section_number`, c.`name`, s.`enrollment_count`
ORDER BY s.`course_id`, s.`section_number`;

-- Get objectives for a section within a degree
-- Used for: Evaluation entry - Step 2 (show objectives that need evaluation)
SELECT 
    dco.`objective_id`,
    o.`title` AS objective_title,
    o.`description` AS objective_description,
    CASE 
        WHEN e.`objective_id` IS NOT NULL THEN 'Entered'
        ELSE 'Not Entered'
    END AS evaluation_status,
    e.`method_name`,
    e.`count_A`, 
    e.`count_B`, 
    e.`count_C`, 
    e.`count_F`,
    e.`improvement_suggestion`,
    e.`updated_at` AS last_updated
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

-- Get available evaluation methods
-- Used for: Evaluation entry - Method selection dropdown
SELECT `name` AS method_name
FROM `evaluation_method`
ORDER BY `name`;

-- ============================================
-- EVALUATION STATISTICS AND REPORTS
-- ============================================

-- Get summary statistics for a section
-- Used for: Section evaluation summary
SELECT 
    COUNT(DISTINCT e.`objective_id`) AS objectives_evaluated,
    (SELECT COUNT(*) 
     FROM `degree_course_objective` 
     WHERE `degree_name` = ? AND `degree_level` = ? AND `course_id` = ?) AS total_objectives,
    SUM(e.`count_A`) AS total_A,
    SUM(e.`count_B`) AS total_B,
    SUM(e.`count_C`) AS total_C,
    SUM(e.`count_F`) AS total_F,
    SUM(e.`count_A` + e.`count_B` + e.`count_C` + e.`count_F`) AS total_students,
    ROUND(SUM(e.`count_A`) * 100.0 / NULLIF(SUM(e.`count_A` + e.`count_B` + e.`count_C` + e.`count_F`), 0), 2) AS percent_A,
    ROUND(SUM(e.`count_B`) * 100.0 / NULLIF(SUM(e.`count_A` + e.`count_B` + e.`count_C` + e.`count_F`), 0), 2) AS percent_B,
    ROUND(SUM(e.`count_C`) * 100.0 / NULLIF(SUM(e.`count_A` + e.`count_B` + e.`count_C` + e.`count_F`), 0), 2) AS percent_C,
    ROUND(SUM(e.`count_F`) * 100.0 / NULLIF(SUM(e.`count_A` + e.`count_B` + e.`count_C` + e.`count_F`), 0), 2) AS percent_F,
    ROUND((SUM(e.`count_A`) + SUM(e.`count_B`)) * 100.0 / NULLIF(SUM(e.`count_A` + e.`count_B` + e.`count_C` + e.`count_F`), 0), 2) AS pass_rate
FROM `evaluation` e
WHERE e.`degree_name` = ? AND e.`degree_level` = ? 
      AND e.`course_id` = ? AND e.`year` = ? AND e.`term` = ? AND e.`section_number` = ?;

-- Get evaluation statistics by objective for a section
-- Used for: Detailed objective-level performance
SELECT 
    e.`objective_id`,
    o.`title` AS objective_title,
    e.`method_name`,
    e.`count_A`, 
    e.`count_B`, 
    e.`count_C`, 
    e.`count_F`,
    (e.`count_A` + e.`count_B` + e.`count_C` + e.`count_F`) AS total_students,
    ROUND(e.`count_A` * 100.0 / NULLIF((e.`count_A` + e.`count_B` + e.`count_C` + e.`count_F`), 0), 2) AS percent_A,
    ROUND(e.`count_B` * 100.0 / NULLIF((e.`count_A` + e.`count_B` + e.`count_C` + e.`count_F`), 0), 2) AS percent_B,
    ROUND(e.`count_C` * 100.0 / NULLIF((e.`count_A` + e.`count_B` + e.`count_C` + e.`count_F`), 0), 2) AS percent_C,
    ROUND(e.`count_F` * 100.0 / NULLIF((e.`count_A` + e.`count_B` + e.`count_C` + e.`count_F`), 0), 2) AS percent_F,
    ROUND((e.`count_A` + e.`count_B`) * 100.0 / NULLIF((e.`count_A` + e.`count_B` + e.`count_C` + e.`count_F`), 0), 2) AS pass_rate,
    e.`improvement_suggestion`
FROM `evaluation` e
JOIN `objective` o ON e.`objective_id` = o.`objective_id`
WHERE e.`degree_name` = ? AND e.`degree_level` = ? 
      AND e.`course_id` = ? AND e.`year` = ? AND e.`term` = ? AND e.`section_number` = ?
ORDER BY e.`objective_id`;

-- Get course performance across all sections in a semester
-- Used for: Course-level analysis
SELECT 
    s.`section_number`,
    s.`instructor_id`,
    i.`name` AS instructor_name,
    s.`enrollment_count`,
    COUNT(DISTINCT e.`objective_id`) AS objectives_evaluated,
    SUM(e.`count_A`) AS total_A,
    SUM(e.`count_B`) AS total_B,
    SUM(e.`count_C`) AS total_C,
    SUM(e.`count_F`) AS total_F,
    SUM(e.`count_A` + e.`count_B` + e.`count_C` + e.`count_F`) AS total_students,
    ROUND((SUM(e.`count_A`) + SUM(e.`count_B`)) * 100.0 / NULLIF(SUM(e.`count_A` + e.`count_B` + e.`count_C` + e.`count_F`), 0), 2) AS pass_rate
FROM `section` s
JOIN `instructor` i ON s.`instructor_id` = i.`instructor_id`
LEFT JOIN `evaluation` e ON s.`course_id` = e.`course_id` 
                          AND s.`year` = e.`year` 
                          AND s.`term` = e.`term` 
                          AND s.`section_number` = e.`section_number`
                          AND e.`degree_name` = ?
                          AND e.`degree_level` = ?
WHERE s.`course_id` = ? AND s.`year` = ? AND s.`term` = ?
GROUP BY s.`section_number`, s.`instructor_id`, i.`name`, s.`enrollment_count`
ORDER BY s.`section_number`;

-- Get objective performance across all sections in a course
-- Used for: Objective-level analysis across sections
SELECT 
    e.`objective_id`,
    o.`title` AS objective_title,
    COUNT(DISTINCT CONCAT(e.`year`, '-', e.`term`, '-', e.`section_number`)) AS section_count,
    SUM(e.`count_A`) AS total_A,
    SUM(e.`count_B`) AS total_B,
    SUM(e.`count_C`) AS total_C,
    SUM(e.`count_F`) AS total_F,
    SUM(e.`count_A` + e.`count_B` + e.`count_C` + e.`count_F`) AS total_students,
    ROUND(SUM(e.`count_A`) * 100.0 / NULLIF(SUM(e.`count_A` + e.`count_B` + e.`count_C` + e.`count_F`), 0), 2) AS percent_A,
    ROUND((SUM(e.`count_A`) + SUM(e.`count_B`)) * 100.0 / NULLIF(SUM(e.`count_A` + e.`count_B` + e.`count_C` + e.`count_F`), 0), 2) AS pass_rate
FROM `evaluation` e
JOIN `objective` o ON e.`objective_id` = o.`objective_id`
WHERE e.`degree_name` = ? AND e.`degree_level` = ? 
      AND e.`course_id` = ? AND e.`year` = ? AND e.`term` = ?
GROUP BY e.`objective_id`, o.`title`
ORDER BY e.`objective_id`;

-- ============================================
-- DEGREE PROGRAM ANALYSIS
-- ============================================

-- Get all courses for a degree with evaluation statistics
-- Used for: Degree program overview
SELECT 
    dc.`course_id`,
    c.`name` AS course_name,
    dc.`is_core`,
    COUNT(DISTINCT s.`section_number`) AS sections_offered,
    COUNT(DISTINCT e.`objective_id`) AS objectives_evaluated,
    SUM(e.`count_A` + e.`count_B` + e.`count_C` + e.`count_F`) AS total_students_evaluated,
    ROUND((SUM(e.`count_A`) + SUM(e.`count_B`)) * 100.0 / NULLIF(SUM(e.`count_A` + e.`count_B` + e.`count_C` + e.`count_F`), 0), 2) AS overall_pass_rate
FROM `degree_course` dc
JOIN `course` c ON dc.`course_id` = c.`course_id`
LEFT JOIN `section` s ON dc.`course_id` = s.`course_id`
LEFT JOIN `evaluation` e ON s.`course_id` = e.`course_id` 
                         AND s.`year` = e.`year` 
                         AND s.`term` = e.`term` 
                         AND s.`section_number` = e.`section_number`
                         AND e.`degree_name` = dc.`degree_name`
                         AND e.`degree_level` = dc.`degree_level`
WHERE dc.`degree_name` = ? AND dc.`degree_level` = ?
GROUP BY dc.`course_id`, c.`name`, dc.`is_core`
ORDER BY dc.`is_core` DESC, dc.`course_id`;

-- Get objective performance across all courses in a degree
-- Used for: Degree-level objective analysis
SELECT 
    do.`objective_id`,
    o.`title` AS objective_title,
    COUNT(DISTINCT e.`course_id`) AS courses_evaluated,
    COUNT(DISTINCT CONCAT(e.`course_id`, '-', e.`year`, '-', e.`term`, '-', e.`section_number`)) AS sections_evaluated,
    SUM(e.`count_A`) AS total_A,
    SUM(e.`count_B`) AS total_B,
    SUM(e.`count_C`) AS total_C,
    SUM(e.`count_F`) AS total_F,
    SUM(e.`count_A` + e.`count_B` + e.`count_C` + e.`count_F`) AS total_students,
    ROUND(SUM(e.`count_A`) * 100.0 / NULLIF(SUM(e.`count_A` + e.`count_B` + e.`count_C` + e.`count_F`), 0), 2) AS percent_A,
    ROUND((SUM(e.`count_A`) + SUM(e.`count_B`)) * 100.0 / NULLIF(SUM(e.`count_A` + e.`count_B` + e.`count_C` + e.`count_F`), 0), 2) AS pass_rate
FROM `degree_objective` do
JOIN `objective` o ON do.`objective_id` = o.`objective_id`
LEFT JOIN `evaluation` e ON do.`degree_name` = e.`degree_name` 
                          AND do.`degree_level` = e.`degree_level`
                          AND do.`objective_id` = e.`objective_id`
WHERE do.`degree_name` = ? AND do.`degree_level` = ?
GROUP BY do.`objective_id`, o.`title`
ORDER BY do.`objective_id`;

-- Get evaluation trends over time for a course in a degree
-- Used for: Historical performance analysis
SELECT 
    e.`year`,
    e.`term`,
    COUNT(DISTINCT e.`section_number`) AS section_count,
    COUNT(DISTINCT e.`objective_id`) AS objectives_evaluated,
    SUM(e.`count_A`) AS total_A,
    SUM(e.`count_B`) AS total_B,
    SUM(e.`count_C`) AS total_C,
    SUM(e.`count_F`) AS total_F,
    SUM(e.`count_A` + e.`count_B` + e.`count_C` + e.`count_F`) AS total_students,
    ROUND((SUM(e.`count_A`) + SUM(e.`count_B`)) * 100.0 / NULLIF(SUM(e.`count_A` + e.`count_B` + e.`count_C` + e.`count_F`), 0), 2) AS pass_rate
FROM `evaluation` e
WHERE e.`degree_name` = ? AND e.`degree_level` = ? AND e.`course_id` = ?
GROUP BY e.`year`, e.`term`
ORDER BY e.`year` DESC, 
         CASE e.`term` 
             WHEN 'Spring' THEN 1 
             WHEN 'Summer' THEN 2 
             WHEN 'Fall' THEN 3 
         END;

-- ============================================
-- INSTRUCTOR PERFORMANCE ANALYSIS
-- ============================================

-- Get instructor's sections with evaluation completion status
-- Used for: Instructor dashboard
SELECT 
    s.`course_id`,
    c.`name` AS course_name,
    s.`year`,
    s.`term`,
    s.`section_number`,
    s.`enrollment_count`,
    COUNT(DISTINCT dco.`objective_id`) AS total_objectives,
    COUNT(DISTINCT e.`objective_id`) AS evaluated_objectives,
    CASE 
        WHEN COUNT(DISTINCT dco.`objective_id`) = 0 THEN 'No objectives'
        WHEN COUNT(DISTINCT dco.`objective_id`) = COUNT(DISTINCT e.`objective_id`) THEN 'Complete'
        ELSE CONCAT(COUNT(DISTINCT e.`objective_id'), '/', COUNT(DISTINCT dco.`objective_id`))
    END AS completion_status
FROM `section` s
JOIN `course` c ON s.`course_id` = c.`course_id`
LEFT JOIN `degree_course_objective` dco ON s.`course_id` = dco.`course_id`
LEFT JOIN `evaluation` e ON dco.`degree_name` = e.`degree_name` 
                          AND dco.`degree_level` = e.`degree_level`
                          AND dco.`course_id` = e.`course_id`
                          AND dco.`objective_id` = e.`objective_id`
                          AND e.`year` = s.`year`
                          AND e.`term` = s.`term`
                          AND e.`section_number` = s.`section_number`
WHERE s.`instructor_id` = ?
GROUP BY s.`course_id`, c.`name`, s.`year`, s.`term`, s.`section_number`, s.`enrollment_count`
ORDER BY s.`year` DESC, 
         CASE s.`term` 
             WHEN 'Spring' THEN 1 
             WHEN 'Summer' THEN 2 
             WHEN 'Fall' THEN 3 
         END,
         s.`course_id`, s.`section_number`;

-- Get instructor's overall performance statistics
-- Used for: Instructor performance report
SELECT 
    COUNT(DISTINCT CONCAT(s.`course_id`, '-', s.`year`, '-', s.`term`, '-', s.`section_number`)) AS sections_taught,
    COUNT(DISTINCT s.`course_id`) AS courses_taught,
    SUM(s.`enrollment_count`) AS total_enrollment,
    COUNT(DISTINCT e.`objective_id`) AS objectives_evaluated,
    SUM(e.`count_A` + e.`count_B` + e.`count_C` + e.`count_F`) AS total_students_evaluated,
    ROUND((SUM(e.`count_A`) + SUM(e.`count_B`)) * 100.0 / NULLIF(SUM(e.`count_A` + e.`count_B` + e.`count_C` + e.`count_F`), 0), 2) AS overall_pass_rate
FROM `section` s
LEFT JOIN `evaluation` e ON s.`course_id` = e.`course_id` 
                          AND s.`year` = e.`year` 
                          AND s.`term` = e.`term` 
                          AND s.`section_number` = e.`section_number`
WHERE s.`instructor_id` = ?;

-- ============================================
-- IMPROVEMENT SUGGESTIONS ANALYSIS
-- ============================================

-- Get all improvement suggestions for a course
-- Used for: Course improvement tracking
SELECT 
    e.`year`,
    e.`term`,
    e.`section_number`,
    e.`objective_id`,
    o.`title` AS objective_title,
    e.`improvement_suggestion`,
    e.`updated_at`
FROM `evaluation` e
JOIN `objective` o ON e.`objective_id` = o.`objective_id`
WHERE e.`degree_name` = ? AND e.`degree_level` = ? 
      AND e.`course_id` = ?
      AND e.`improvement_suggestion` IS NOT NULL 
      AND e.`improvement_suggestion` != ''
ORDER BY e.`year` DESC, 
         CASE e.`term` 
             WHEN 'Spring' THEN 1 
             WHEN 'Summer' THEN 2 
             WHEN 'Fall' THEN 3 
         END,
         e.`section_number`, e.`objective_id`;

-- Get improvement suggestions for an objective across all courses
-- Used for: Objective-level improvement tracking
SELECT 
    e.`course_id`,
    c.`name` AS course_name,
    e.`year`,
    e.`term`,
    e.`section_number`,
    e.`improvement_suggestion`,
    e.`updated_at`
FROM `evaluation` e
JOIN `course` c ON e.`course_id` = c.`course_id`
WHERE e.`degree_name` = ? AND e.`degree_level` = ? 
      AND e.`objective_id` = ?
      AND e.`improvement_suggestion` IS NOT NULL 
      AND e.`improvement_suggestion` != ''
ORDER BY e.`year` DESC, 
         CASE e.`term` 
             WHEN 'Spring' THEN 1 
             WHEN 'Summer' THEN 2 
             WHEN 'Fall' THEN 3 
         END,
         e.`course_id`, e.`section_number`;

-- ============================================
-- DATA COMPLETENESS QUERIES
-- ============================================

-- Check evaluation completeness for all sections in a semester
-- Used for: Administrative dashboard
SELECT 
    s.`course_id`,
    c.`name` AS course_name,
    s.`section_number`,
    i.`name` AS instructor_name,
    COUNT(DISTINCT dco.`objective_id`) AS total_objectives,
    COUNT(DISTINCT e.`objective_id`) AS evaluated_objectives,
    CASE 
        WHEN COUNT(DISTINCT dco.`objective_id`) = 0 THEN 'No objectives defined'
        WHEN COUNT(DISTINCT dco.`objective_id`) = COUNT(DISTINCT e.`objective_id`) THEN 'Complete'
        ELSE 'Incomplete'
    END AS status
FROM `section` s
JOIN `course` c ON s.`course_id` = c.`course_id`
JOIN `instructor` i ON s.`instructor_id` = i.`instructor_id`
JOIN `degree_course_objective` dco ON s.`course_id` = dco.`course_id`
LEFT JOIN `evaluation` e ON dco.`degree_name` = e.`degree_name` 
                          AND dco.`degree_level` = e.`degree_level`
                          AND dco.`course_id` = e.`course_id`
                          AND dco.`objective_id` = e.`objective_id`
                          AND e.`year` = s.`year`
                          AND e.`term` = s.`term`
                          AND e.`section_number` = s.`section_number`
WHERE s.`year` = ? AND s.`term` = ?
      AND dco.`degree_name` = ? AND dco.`degree_level` = ?
GROUP BY s.`course_id`, c.`name`, s.`section_number`, i.`name`
ORDER BY s.`course_id`, s.`section_number`;

-- Get sections missing evaluations for a degree
-- Used for: Administrative report
SELECT DISTINCT
    s.`course_id`,
    c.`name` AS course_name,
    s.`year`,
    s.`term`,
    s.`section_number`,
    i.`name` AS instructor_name,
    dco.`objective_id`,
    o.`title` AS objective_title
FROM `section` s
JOIN `course` c ON s.`course_id` = c.`course_id`
JOIN `instructor` i ON s.`instructor_id` = i.`instructor_id`
JOIN `degree_course_objective` dco ON s.`course_id` = dco.`course_id`
JOIN `objective` o ON dco.`objective_id` = o.`objective_id`
LEFT JOIN `evaluation` e ON dco.`degree_name` = e.`degree_name` 
                          AND dco.`degree_level` = e.`degree_level`
                          AND dco.`course_id` = e.`course_id`
                          AND dco.`objective_id` = e.`objective_id`
                          AND e.`year` = s.`year`
                          AND e.`term` = s.`term`
                          AND e.`section_number` = s.`section_number`
WHERE dco.`degree_name` = ? AND dco.`degree_level` = ?
      AND e.`objective_id` IS NULL
ORDER BY s.`year` DESC, 
         CASE s.`term` 
             WHEN 'Spring' THEN 1 
             WHEN 'Summer' THEN 2 
             WHEN 'Fall' THEN 3 
         END,
         s.`course_id`, s.`section_number`, dco.`objective_id`;

-- ============================================
-- END OF BUSINESS LOGIC QUERIES FILE
-- ============================================

