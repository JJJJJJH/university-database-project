-- Program Evaluation System Database Setup
-- Based on Draft team project 14_FIXED.docx
-- Fall 2025

-- ============================================
-- Step 1: Create Database and User (Optional)
-- ============================================
-- Uncomment and modify if you need to create a new database and user
CREATE DATABASE IF NOT EXISTS program_evaluation;
CREATE USER IF NOT EXISTS 'eval_user'@'localhost' IDENTIFIED BY 'eval_password';
GRANT ALL PRIVILEGES ON program_evaluation.* TO 'eval_user'@'localhost';
FLUSH PRIVILEGES;

-- ============================================
-- Step 2: Use Database
-- ============================================
USE program_evaluation;

-- ============================================
-- Step 3: Drop existing tables if they exist
-- (in reverse order of dependencies)
-- ============================================
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS `evaluation`;
DROP TABLE IF EXISTS `evaluation_method`;
DROP TABLE IF EXISTS `degree_course_objective`;
DROP TABLE IF EXISTS `degree_objective`;
DROP TABLE IF EXISTS `degree_course`;
DROP TABLE IF EXISTS `section`;
DROP TABLE IF EXISTS `semester`;
DROP TABLE IF EXISTS `objective`;
DROP TABLE IF EXISTS `instructor`;
DROP TABLE IF EXISTS `course`;
DROP TABLE IF EXISTS `degree`;
SET FOREIGN_KEY_CHECKS = 1;

-- ============================================
-- Step 4: Create Tables
-- ============================================

-- Create Degree table
CREATE TABLE `degree` (
  `name` varchar(255) NOT NULL,
  `level` enum('BA','BS','MS','PhD','Cert') NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`name`,`level`)
);

-- Create Course table
CREATE TABLE `course` (
  `course_id` varchar(10) NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`course_id`),
  UNIQUE KEY `unique_course_name` (`name`)
);

-- Create Instructor table
CREATE TABLE `instructor` (
  `instructor_id` varchar(20) NOT NULL,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) DEFAULT NULL,
  `department` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`instructor_id`),
  UNIQUE KEY `unique_email` (`email`)
);

-- Create Semester table
CREATE TABLE `semester` (
  `year` int NOT NULL,
  `term` enum('Spring','Summer','Fall') NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`year`,`term`),
  CONSTRAINT `semester_chk_1` CHECK ((`year` >= 2000))
);

-- Create Section table
CREATE TABLE `section` (
  `course_id` varchar(10) NOT NULL,
  `year` int NOT NULL,
  `term` enum('Spring','Summer','Fall') NOT NULL,
  `section_number` varchar(3) NOT NULL,
  `instructor_id` varchar(20) NOT NULL,
  `enrollment_count` int DEFAULT 0,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`course_id`,`year`,`term`,`section_number`),
  KEY `fk_section_course` (`course_id`),
  KEY `fk_section_semester` (`year`,`term`),
  KEY `fk_section_instructor` (`instructor_id`),
  CONSTRAINT `fk_section_course` FOREIGN KEY (`course_id`) REFERENCES `course` (`course_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_section_semester` FOREIGN KEY (`year`,`term`) REFERENCES `semester` (`year`,`term`) ON DELETE CASCADE,
  CONSTRAINT `fk_section_instructor` FOREIGN KEY (`instructor_id`) REFERENCES `instructor` (`instructor_id`) ON DELETE RESTRICT,
  CONSTRAINT `section_chk_1` CHECK ((`enrollment_count` >= 0))
);

-- Create Objective table
CREATE TABLE `objective` (
  `objective_id` varchar(20) NOT NULL,
  `title` varchar(120) NOT NULL,
  `description` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`objective_id`),
  UNIQUE KEY `unique_objective_title` (`title`)
);

-- Create Degree_Course association table
CREATE TABLE `degree_course` (
  `degree_name` varchar(255) NOT NULL,
  `degree_level` enum('BA','BS','MS','PhD','Cert') NOT NULL,
  `course_id` varchar(10) NOT NULL,
  `is_core` tinyint(1) DEFAULT 0 COMMENT '0 = No, 1 = Yes',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`degree_name`,`degree_level`,`course_id`),
  KEY `fk_degree_course_degree` (`degree_name`,`degree_level`),
  KEY `fk_degree_course_course` (`course_id`),
  CONSTRAINT `fk_degree_course_degree` FOREIGN KEY (`degree_name`,`degree_level`) REFERENCES `degree` (`name`,`level`) ON DELETE CASCADE,
  CONSTRAINT `fk_degree_course_course` FOREIGN KEY (`course_id`) REFERENCES `course` (`course_id`) ON DELETE CASCADE
);

-- Create Degree_Objective association table
CREATE TABLE `degree_objective` (
  `degree_name` varchar(255) NOT NULL,
  `degree_level` enum('BA','BS','MS','PhD','Cert') NOT NULL,
  `objective_id` varchar(20) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`degree_name`,`degree_level`,`objective_id`),
  KEY `fk_degree_objective_degree` (`degree_name`,`degree_level`),
  KEY `fk_degree_objective_objective` (`objective_id`),
  CONSTRAINT `fk_degree_objective_degree` FOREIGN KEY (`degree_name`,`degree_level`) REFERENCES `degree` (`name`,`level`) ON DELETE CASCADE,
  CONSTRAINT `fk_degree_objective_objective` FOREIGN KEY (`objective_id`) REFERENCES `objective` (`objective_id`) ON DELETE CASCADE
);

-- Create Degree_Course_Objective association table
CREATE TABLE `degree_course_objective` (
  `degree_name` varchar(255) NOT NULL,
  `degree_level` enum('BA','BS','MS','PhD','Cert') NOT NULL,
  `course_id` varchar(10) NOT NULL,
  `objective_id` varchar(20) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`degree_name`,`degree_level`,`course_id`,`objective_id`),
  KEY `fk_dco_degree` (`degree_name`,`degree_level`),
  KEY `fk_dco_course` (`course_id`),
  KEY `fk_dco_objective` (`objective_id`),
  CONSTRAINT `fk_dco_degree` FOREIGN KEY (`degree_name`,`degree_level`) REFERENCES `degree` (`name`,`level`) ON DELETE CASCADE,
  CONSTRAINT `fk_dco_course` FOREIGN KEY (`course_id`) REFERENCES `course` (`course_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_dco_objective` FOREIGN KEY (`objective_id`) REFERENCES `objective` (`objective_id`) ON DELETE CASCADE
);

-- Create Evaluation_Method table
CREATE TABLE `evaluation_method` (
  `name` varchar(100) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`name`)
);

-- Create Evaluation table
CREATE TABLE `evaluation` (
  `degree_name` varchar(255) NOT NULL,
  `degree_level` enum('BA','BS','MS','PhD','Cert') NOT NULL,
  `course_id` varchar(10) NOT NULL,
  `year` int NOT NULL,
  `term` enum('Spring','Summer','Fall') NOT NULL,
  `section_number` varchar(3) NOT NULL,
  `objective_id` varchar(20) NOT NULL,
  `method_name` varchar(100) NOT NULL,
  `count_A` int DEFAULT 0,
  `count_B` int DEFAULT 0,
  `count_C` int DEFAULT 0,
  `count_F` int DEFAULT 0,
  `improvement_suggestion` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`degree_name`,`degree_level`,`course_id`,`year`,`term`,`section_number`,`objective_id`),
  KEY `fk_evaluation_degree` (`degree_name`,`degree_level`),
  KEY `fk_evaluation_section` (`course_id`,`year`,`term`,`section_number`),
  KEY `fk_evaluation_objective` (`objective_id`),
  KEY `fk_evaluation_method` (`method_name`),
  CONSTRAINT `fk_evaluation_degree` FOREIGN KEY (`degree_name`,`degree_level`) REFERENCES `degree` (`name`,`level`) ON DELETE CASCADE,
  CONSTRAINT `fk_evaluation_section` FOREIGN KEY (`course_id`,`year`,`term`,`section_number`) REFERENCES `section` (`course_id`,`year`,`term`,`section_number`) ON DELETE CASCADE,
  CONSTRAINT `fk_evaluation_objective` FOREIGN KEY (`objective_id`) REFERENCES `objective` (`objective_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_evaluation_method` FOREIGN KEY (`method_name`) REFERENCES `evaluation_method` (`name`) ON DELETE RESTRICT,
  CONSTRAINT `fk_evaluation_dco` FOREIGN KEY (`degree_name`,`degree_level`,`course_id`,`objective_id`) REFERENCES `degree_course_objective` (`degree_name`,`degree_level`,`course_id`,`objective_id`) ON DELETE CASCADE,
  CONSTRAINT `evaluation_chk_1` CHECK ((`count_A` >= 0)),
  CONSTRAINT `evaluation_chk_2` CHECK ((`count_B` >= 0)),
  CONSTRAINT `evaluation_chk_3` CHECK ((`count_C` >= 0)),
  CONSTRAINT `evaluation_chk_4` CHECK ((`count_F` >= 0))
);

-- ============================================
-- Step 5: Insert Initial Data
-- ============================================

-- Insert initial evaluation methods
INSERT INTO `evaluation_method` (`name`) VALUES
  ('Homework'),
  ('Project'),
  ('Quiz'),
  ('Oral Presentation'),
  ('Report'),
  ('Mid-term'),
  ('Final Exam');

-- ============================================
-- Step 6: Create Additional Indexes
-- ============================================
-- Indexes for frequently queried fields
CREATE INDEX `idx_section_semester_instructor` ON `section` (`year`, `term`, `instructor_id`);
CREATE INDEX `idx_evaluation_section_degree` ON `evaluation` (`course_id`, `year`, `term`, `degree_name`, `degree_level`);

-- ============================================
-- Completion Message
-- ============================================
SELECT 'Database setup completed successfully!' AS Status;

