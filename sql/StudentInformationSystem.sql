-- StudentInformationSystem.sql
-- Comprehensive SQL setup for Student Information System
-- Created: 2024

-- -----------------------------------------------------
-- Database Creation and Selection
-- -----------------------------------------------------
CREATE DATABASE IF NOT EXISTS StudentInformationSystem;
USE StudentInformationSystem;

-- -----------------------------------------------------
-- Table `Department`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Department` (
    `department_id` INT PRIMARY KEY AUTO_INCREMENT,
    `department_name` VARCHAR(100) NOT NULL,
    `hod_name` VARCHAR(100),
    `establishment_year` YEAR,
    `contact_email` VARCHAR(100),
    `office_location` VARCHAR(100),
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE INDEX `department_name_UNIQUE` (`department_name` ASC)
);

-- -----------------------------------------------------
-- Table `Program`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Program` (
    `program_id` INT PRIMARY KEY AUTO_INCREMENT,
    `program_name` VARCHAR(100) NOT NULL,
    `department_id` INT NOT NULL,
    `duration_years` INT NOT NULL,
    `total_semesters` INT NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`department_id`) REFERENCES `Department`(`department_id`),
    UNIQUE INDEX `program_name_UNIQUE` (`program_name` ASC)
);

-- -----------------------------------------------------
-- Table `Faculty`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Faculty` (
    `faculty_id` INT PRIMARY KEY AUTO_INCREMENT,
    `first_name` VARCHAR(50) NOT NULL,
    `last_name` VARCHAR(50) NOT NULL,
    `department_id` INT NOT NULL,
    `designation` VARCHAR(50),
    `email` VARCHAR(100),
    `phone` VARCHAR(15),
    `joining_date` DATE,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`department_id`) REFERENCES `Department`(`department_id`)
);

-- -----------------------------------------------------
-- Table `Student`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Student` (
    `student_id` INT PRIMARY KEY AUTO_INCREMENT,
    `first_name` VARCHAR(50) NOT NULL,
    `last_name` VARCHAR(50) NOT NULL,
    `enrollment_number` VARCHAR(20) UNIQUE NOT NULL,
    `program_id` INT NOT NULL,
    `batch_year` YEAR NOT NULL,
    `date_of_birth` DATE,
    `gender` ENUM('Male', 'Female', 'Other'),
    `email` VARCHAR(100),
    `phone` VARCHAR(15),
    `address` TEXT,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`program_id`) REFERENCES `Program`(`program_id`)
);

-- -----------------------------------------------------
-- Table `Course`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Course` (
    `course_id` INT PRIMARY KEY AUTO_INCREMENT,
    `course_code` VARCHAR(20) UNIQUE NOT NULL,
    `course_name` VARCHAR(100) NOT NULL,
    `program_id` INT NOT NULL,
    `semester` INT NOT NULL,
    `credits` INT NOT NULL,
    `faculty_id` INT,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`program_id`) REFERENCES `Program`(`program_id`),
    FOREIGN KEY (`faculty_id`) REFERENCES `Faculty`(`faculty_id`)
);

-- -----------------------------------------------------
-- Table `Enrollment`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Enrollment` (
    `enrollment_id` INT PRIMARY KEY AUTO_INCREMENT,
    `student_id` INT NOT NULL,
    `course_id` INT NOT NULL,
    `semester` INT NOT NULL,
    `academic_year` VARCHAR(9) NOT NULL,
    `enrollment_date` DATE NOT NULL,
    `status` ENUM('Active', 'Completed', 'Dropped') DEFAULT 'Active',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`student_id`) REFERENCES `Student`(`student_id`),
    FOREIGN KEY (`course_id`) REFERENCES `Course`(`course_id`),
    UNIQUE INDEX `unique_enrollment` (`student_id`, `course_id`, `academic_year`)
);

-- -----------------------------------------------------
-- Table `Attendance`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Attendance` (
    `attendance_id` INT PRIMARY KEY AUTO_INCREMENT,
    `enrollment_id` INT NOT NULL,
    `date` DATE NOT NULL,
    `status` ENUM('Present', 'Absent', 'Late') NOT NULL,
    `remarks` TEXT,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`enrollment_id`) REFERENCES `Enrollment`(`enrollment_id`),
    UNIQUE INDEX `unique_attendance` (`enrollment_id`, `date`)
);

-- -----------------------------------------------------
-- Table `Grade`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Grade` (
    `grade_id` INT PRIMARY KEY AUTO_INCREMENT,
    `enrollment_id` INT NOT NULL,
    `assessment_type` ENUM('Internal', 'MidTerm', 'EndTerm', 'Project', 'Assignment') NOT NULL,
    `marks_obtained` DECIMAL(5,2) NOT NULL,
    `max_marks` DECIMAL(5,2) NOT NULL,
    `grade_letter` CHAR(2),
    `remarks` TEXT,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`enrollment_id`) REFERENCES `Enrollment`(`enrollment_id`)
);

-- -----------------------------------------------------
-- Table `EventInfo`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `EventInfo` (
    `event_id` INT PRIMARY KEY AUTO_INCREMENT,
    `event_name` VARCHAR(100) NOT NULL,
    `event_type` ENUM('Technical', 'Cultural', 'Sports', 'Academic', 'Other') NOT NULL,
    `start_date` DATE NOT NULL,
    `end_date` DATE NOT NULL,
    `venue` VARCHAR(100),
    `description` TEXT,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- -----------------------------------------------------
-- Table `EventParticipation`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `EventParticipation` (
    `participation_id` INT PRIMARY KEY AUTO_INCREMENT,
    `event_id` INT NOT NULL,
    `student_id` INT NOT NULL,
    `participation_type` ENUM('Participant', 'Organizer', 'Volunteer', 'Speaker', 'Presenter') NOT NULL,
    `achievement` VARCHAR(100),
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`event_id`) REFERENCES `EventInfo`(`event_id`),
    FOREIGN KEY (`student_id`) REFERENCES `Student`(`student_id`),
    UNIQUE INDEX `unique_participation` (`event_id`, `student_id`)
);

-- -----------------------------------------------------
-- Views
-- -----------------------------------------------------
CREATE OR REPLACE VIEW `StudentEventSummary` AS
SELECT 
    s.student_id,
    CONCAT(s.first_name, ' ', s.last_name) as student_name,
    e.event_id,
    e.event_name,
    e.event_type,
    ep.participation_type,
    ep.achievement
FROM Student s
JOIN EventParticipation ep ON s.student_id = ep.student_id
JOIN EventInfo e ON ep.event_id = e.event_id;

CREATE OR REPLACE VIEW `StudentAcademicSummary` AS
SELECT 
    s.student_id,
    CONCAT(s.first_name, ' ', s.last_name) as student_name,
    p.program_name,
    c.course_code,
    c.course_name,
    g.assessment_type,
    g.marks_obtained,
    g.grade_letter
FROM Student s
JOIN Enrollment e ON s.student_id = e.student_id
JOIN Course c ON e.course_id = c.course_id
JOIN Grade g ON e.enrollment_id = g.enrollment_id
JOIN Program p ON s.program_id = p.program_id;

CREATE OR REPLACE VIEW `StudentAttendanceSummary` AS
SELECT 
    s.student_id,
    CONCAT(s.first_name, ' ', s.last_name) as student_name,
    c.course_code,
    c.course_name,
    COUNT(CASE WHEN a.status = 'Present' THEN 1 END) as total_present,
    COUNT(CASE WHEN a.status = 'Absent' THEN 1 END) as total_absent,
    COUNT(CASE WHEN a.status = 'Late' THEN 1 END) as total_late,
    ROUND((COUNT(CASE WHEN a.status = 'Present' THEN 1 END) * 100.0 / COUNT(*)), 2) as attendance_percentage
FROM Student s
JOIN Enrollment e ON s.student_id = e.student_id
JOIN Course c ON e.course_id = c.course_id
JOIN Attendance a ON e.enrollment_id = a.enrollment_id
GROUP BY s.student_id, c.course_id;

-- -----------------------------------------------------
-- Inserting Sample Data
-- -----------------------------------------------------

-- Department Data
INSERT INTO `Department` (`department_name`, `hod_name`, `establishment_year`, `contact_email`, `office_location`) VALUES
('Computer Science & Engineering', 'Dr. Rajesh Kumar', 2010, 'hod.cse@college.edu', 'Block A, Floor 2'),
('Electronics & Communication', 'Dr. Priya Sharma', 2010, 'hod.ece@college.edu', 'Block B, Floor 1'),
('Mechanical Engineering', 'Dr. Suresh Verma', 2011, 'hod.mech@college.edu', 'Block C, Floor 1'),
('Information Technology', 'Dr. Amit Patel', 2012, 'hod.it@college.edu', 'Block A, Floor 3'),
('Electrical Engineering', 'Dr. Meena Gupta', 2010, 'hod.ee@college.edu', 'Block B, Floor 2');

-- Program Data
INSERT INTO `Program` (`program_name`, `department_id`, `duration_years`, `total_semesters`) VALUES
('B.Tech Computer Science', 1, 4, 8),
('B.Tech Electronics', 2, 4, 8),
('B.Tech Mechanical', 3, 4, 8),
('B.Tech Information Technology', 4, 4, 8),
('B.Tech Electrical', 5, 4, 8),
('M.Tech Computer Science', 1, 2, 4),
('M.Tech Electronics', 2, 2, 4);

-- Faculty Data
INSERT INTO `Faculty` (`first_name`, `last_name`, `department_id`, `designation`, `email`, `phone`, `joining_date`) VALUES
('Anand', 'Krishnan', 1, 'Professor', 'anand.k@college.edu', '9876543210', '2015-06-15'),
('Deepa', 'Mehta', 1, 'Associate Professor', 'deepa.m@college.edu', '9876543211', '2016-07-20'),
('Ramesh', 'Singh', 2, 'Professor', 'ramesh.s@college.edu', '9876543212', '2014-08-10'),
('Sunita', 'Reddy', 2, 'Assistant Professor', 'sunita.r@college.edu', '9876543213', '2017-06-25'),
('Vikram', 'Bhat', 3, 'Professor', 'vikram.b@college.edu', '9876543214', '2013-12-01'),
('Neha', 'Kapoor', 4, 'Associate Professor', 'neha.k@college.edu', '9876543215', '2018-01-15'),
('Arun', 'Kumar', 5, 'Professor', 'arun.k@college.edu', '9876543216', '2015-07-01');

-- Student Data
INSERT INTO `Student` (`first_name`, `last_name`, `enrollment_number`, `program_id`, `batch_year`, `date_of_birth`, `gender`, `email`, `phone`, `address`) VALUES
('Rahul', 'Sharma', 'CSE2020001', 1, 2020, '2002-05-15', 'Male', 'rahul.s@college.edu', '9898989801', 'Mumbai, Maharashtra'),
('Priya', 'Patel', 'CSE2020002', 1, 2020, '2002-07-22', 'Female', 'priya.p@college.edu', '9898989802', 'Ahmedabad, Gujarat'),
('Amit', 'Singh', 'ECE2020001', 2, 2020, '2002-03-10', 'Male', 'amit.s@college.edu', '9898989803', 'Delhi'),
('Sneha', 'Gupta', 'ECE2020002', 2, 2020, '2002-09-18', 'Female', 'sneha.g@college.edu', '9898989804', 'Jaipur, Rajasthan'),
('Arjun', 'Kumar', 'ME2020001', 3, 2020, '2002-11-30', 'Male', 'arjun.k@college.edu', '9898989805', 'Chennai, Tamil Nadu'),
('Ananya', 'Reddy', 'IT2020001', 4, 2020, '2002-04-25', 'Female', 'ananya.r@college.edu', '9898989806', 'Hyderabad, Telangana'),
('Rohan', 'Verma', 'EE2020001', 5, 2020, '2002-08-12', 'Male', 'rohan.v@college.edu', '9898989807', 'Pune, Maharashtra');

-- Course Data
INSERT INTO `Course` (`course_code`, `course_name`, `program_id`, `semester`, `credits`, `faculty_id`) VALUES
('CS101', 'Introduction to Programming', 1, 1, 4, 1),
('CS102', 'Data Structures', 1, 2, 4, 2),
('EC101', 'Basic Electronics', 2, 1, 4, 3),
('EC102', 'Digital Circuits', 2, 2, 4, 4),
('ME101', 'Engineering Mechanics', 3, 1, 4, 5),
('IT101', 'Database Management', 4, 1, 4, 6),
('EE101', 'Basic Electrical', 5, 1, 4, 7);

-- Enrollment Data
INSERT INTO `Enrollment` (`student_id`, `course_id`, `semester`, `academic_year`, `enrollment_date`, `status`) VALUES
(1, 1, 1, '2020-2021', '2020-07-15', 'Completed'),
(1, 2, 2, '2020-2021', '2021-01-15', 'Active'),
(2, 1, 1, '2020-2021', '2020-07-15', 'Completed'),
(2, 2, 2, '2020-2021', '2021-01-15', 'Active'),
(3, 3, 1, '2020-2021', '2020-07-15', 'Completed'),
(4, 3, 1, '2020-2021', '2020-07-15', 'Completed'),
(5, 5, 1, '2020-2021', '2020-07-15', 'Completed');

-- Attendance Data
INSERT INTO `Attendance` (`enrollment_id`, `date`, `status`, `remarks`) VALUES
(1, '2020-07-20', 'Present', NULL),
(1, '2020-07-21', 'Present', NULL),
(1, '2020-07-22', 'Absent', 'Medical Leave'),
(2, '2021-01-20', 'Present', NULL),
(3, '2020-07-20', 'Present', NULL),
(4, '2020-07-20', 'Late', 'Traffic delay'),
(5, '2020-07-20', 'Present', NULL);

-- Grade Data
INSERT INTO `Grade` (`enrollment_id`, `assessment_type`, `marks_obtained`, `max_marks`, `grade_letter`, `remarks`) VALUES
(1, 'Internal', 85.00, 100.00, 'A', 'Excellent performance'),
(1, 'MidTerm', 75.00, 100.00, 'B', 'Good performance'),
(2, 'Internal', 90.00, 100.00, 'A', 'Outstanding performance'),
(3, 'Internal', 82.00, 100.00, 'A', 'Very good performance'),
(4, 'MidTerm', 78.00, 100.00, 'B', 'Good performance'),
(5, 'Internal', 88.00, 100.00, 'A', 'Excellent work');

-- Event Data
INSERT INTO `EventInfo` (`event_name`, `event_type`, `start_date`, `end_date`, `venue`, `description`) VALUES
('TechFest 2024', 'Technical', '2024-03-15', '2024-03-17', 'Main Auditorium', 'Annual Technical Festival'),
('Cultural Night', 'Cultural', '2024-02-20', '2024-02-20', 'Open Air Theatre', 'Annual Cultural Evening'),
('Code Sprint', 'Technical', '2024-04-05', '2024-04-06', 'CS Lab Complex', '24-Hour Coding Hackathon'),
('Sports Meet 2024', 'Sports', '2024-01-25', '2024-01-27', 'College Ground', 'Annual Sports Competition'),
('Technical Symposium', 'Academic', '2024-03-10', '2024-03-10', 'Seminar Hall', 'Department Technical Symposium');

-- Event Participation Data
INSERT INTO `EventParticipation` (`event_id`, `student_id`, `participation_type`, `achievement`) VALUES
(1, 1, 'Participant', 'First Prize in Coding Competition'),
(1, 2, 'Volunteer', NULL),
(2, 3, 'Participant', 'Best Performance Award'),
(3, 1, 'Participant', 'Second Prize'),
(3, 4, 'Organizer', NULL),
(4, 5, 'Participant', 'Gold Medal in Athletics'),
(5, 2, 'Presenter', 'Best Paper Presentation'); 

