-- 創建學生資料表
CREATE TABLE Students (
    student_id INT PRIMARY KEY,
    name VARCHAR(50),
    age INT,
    major VARCHAR(50)
);

-- 插入學生資料
INSERT INTO Students VALUES (1, '王小明', 20, '資訊工程');
INSERT INTO Students VALUES (2, '李小華', 21, '資訊工程');
INSERT INTO Students VALUES (3, '張大山', 19, '企業管理');
INSERT INTO Students VALUES (4, '陳美美', 22, '資訊工程');
INSERT INTO Students VALUES (5, '林小雨', 20, '企業管理');

-- 創建課程資料表
CREATE TABLE Courses (
    course_id INT PRIMARY KEY,
    title VARCHAR(50),
    credits INT,
    department VARCHAR(50)
);

-- 插入課程資料
INSERT INTO Courses VALUES (101, '資料庫系統', 3, '資訊工程');
INSERT INTO Courses VALUES (102, '程式設計', 4, '資訊工程');
INSERT INTO Courses VALUES (103, '管理學', 3, '企業管理');
INSERT INTO Courses VALUES (104, '資料結構', 4, '資訊工程');
INSERT INTO Courses VALUES (105, '行銷管理', 3, '企業管理');

-- 創建選課資料表
CREATE TABLE Enrollments (
    student_id INT,
    course_id INT,
    semester VARCHAR(20),
    grade FLOAT,
    PRIMARY KEY (student_id, course_id),
    FOREIGN KEY (student_id) REFERENCES Students(student_id),
    FOREIGN KEY (course_id) REFERENCES Courses(course_id)
);

-- 插入選課資料
INSERT INTO Enrollments VALUES (1, 101, '2023秋季', 85);
INSERT INTO Enrollments VALUES (1, 102, '2023秋季', 92);
INSERT INTO Enrollments VALUES (2, 101, '2023秋季', 78);
INSERT INTO Enrollments VALUES (2, 104, '2023秋季', 88);
INSERT INTO Enrollments VALUES (3, 103, '2023秋季', 90);
INSERT INTO Enrollments VALUES (4, 101, '2023秋季', 95);
INSERT INTO Enrollments VALUES (4, 102, '2023秋季', 82);
INSERT INTO Enrollments VALUES (5, 103, '2023秋季', 87);
INSERT INTO Enrollments VALUES (5, 105, '2023秋季', 92);

-- 創建教師資料表
CREATE TABLE Teachers (
    teacher_id INT PRIMARY KEY,
    name VARCHAR(50),
    department VARCHAR(50)
);

-- 插入教師資料
INSERT INTO Teachers VALUES (201, '黃教授', '資訊工程');
INSERT INTO Teachers VALUES (202, '劉教授', '資訊工程');
INSERT INTO Teachers VALUES (203, '張教授', '企業管理');
INSERT INTO Teachers VALUES (204, '林教授', '企業管理');

-- 創建教授課程資料表
CREATE TABLE TeachingAssignments (
    teacher_id INT,
    course_id INT,
    semester VARCHAR(20),
    PRIMARY KEY (teacher_id, course_id, semester),
    FOREIGN KEY (teacher_id) REFERENCES Teachers(teacher_id),
    FOREIGN KEY (course_id) REFERENCES Courses(course_id)
);

-- 插入教授課程資料
INSERT INTO TeachingAssignments VALUES (201, 101, '2023秋季');
INSERT INTO TeachingAssignments VALUES (202, 102, '2023秋季');
INSERT INTO TeachingAssignments VALUES (202, 104, '2023秋季');
INSERT INTO TeachingAssignments VALUES (203, 103, '2023秋季');
INSERT INTO TeachingAssignments VALUES (204, 105, '2023秋季');
