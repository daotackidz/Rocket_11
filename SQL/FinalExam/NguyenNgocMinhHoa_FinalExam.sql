DROP DATABASE IF EXISTS ThucTap;
CREATE DATABASE ThucTap;
USE	ThucTap;

DROP TABLE IF EXISTS Country;
CREATE TABLE IF NOT EXISTS Country
(	country_id					INT AUTO_INCREMENT PRIMARY KEY,
	country_name				NVARCHAR(50) NOT NULL
);
INSERT INTO Country(country_name) values
(N'Việt Nam'),
(N'Việt Nam'),
(N'Nhật Bản'),
(N'Hàn Quóc');

DROP TABLE IF EXISTS Location;
CREATE TABLE IF NOT EXISTS Location (
    location_id INT AUTO_INCREMENT PRIMARY KEY,
    street_address NVARCHAR(50) NOT NULL,
    postal_code INT,
    country_id INT,
    FOREIGN KEY (country_id)
        REFERENCES Country (country_id)
);
insert into Location(street_address,postal_code,country_id) values
(N'Hà Nội' ,10938,1),
(N'Mỹ Đình',12841,3),
(N'Tokyo'  ,23451,2),
(N'Seoul'  ,23566,4);
DROP TABLE IF EXISTS Employee;
CREATE TABLE IF NOT EXISTS Employee (
    employee_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name NVARCHAR(50) NOT NULL,
    email NVARCHAR(50),
    location_id INT,
FOREIGN KEY (location_id)
        REFERENCES Location(location_id))
;
insert into Employee(full_name,email,location_id) values 
(N'Nguyễn Văn Minh','nn03@gmail.com',1),
(N'Nguyễn Đức Anh','nn05@gmail.com',2),
(N'Lưu Hương Ly','nn01@gmail.com',4),
(N'Đỗ Minh Chiến','nn08@gmail.com',3);


-- 2. Viết lệnh để
-- a) Lấy tất cả các nhân viên thuộc Việt nam
SELECT 
    *
FROM
    employee
        JOIN
    location ON employee.location_id = location.location_id
        JOIN
    country ON location.country_id = country.country_id
WHERE
    country_name = N'Việt Nam'; 
-- b) Lấy ra tên quốc gia của employee có email là "nn03@gmail.com"
SELECT 
    *
FROM
    employee e
        LEFT JOIN
    location l ON e.location_id = l.location_id
    where email = 'nn03@gmail.com'
    ;
-- c) Thống kê mỗi country, mỗi location có bao nhiêu employee đang làm việc.
SELECT 
    country.country_name,
    location.location_id,
    COUNT(employee.employee_id) AS 'Số employee làm việc'
FROM
    location
        JOIN
    employee ON location.location_id= employee.location_id
        RIGHT JOIN
    country ON location.country_id = country.country_id
GROUP BY location.location_id , country.country_id; 

-- 3. Tạo trigger cho table Employee chỉ cho phép insert mỗi quốc gia có tối đa 10 employee

DELIMITER $$
CREATE TRIGGER Employee_before_insert 
BEFORE INSERT
	ON Orders FOR EACH ROW
	BEGIN 
    IF 
   (SELECT COUNT(Total_employee) FROM (SELECT COUNT(Total_employee) AS Total_employee FROM (SELECT Country.OLD.Country_name AS Country, Employee.OLD.Employee_id AS Total_employee 
FROM Country INNER JOIN Location
ON Country.OLD.Country_id= Location.OLD.Country_id INNER JOIN Employee ON Employee.OLD.Location_id = Location.OLD.Location_id) tb GROUP BY Total_employee) tb_old
   UNION ALL
    (SELECT COUNT(Total_employee) AS Total_employee FROM (SELECT Country.NEW.Country_name AS Country, Employee.NEW.Employee_id AS Total_employee 
FROM Country INNER JOIN Location
ON Country.NEW.Country_id= Location.NEW.Country_id INNER JOIN Employee ON Employee.NEW.Location_id = Location.NEW.Location_id) tb GROUP BY Total_employee) ) > 10 THEN SIGNAL SQLSTATE
'45000' SET MESSAGE_TEXT ='More than 10 employee in each country';
    END IF;
    END$$
DELIMITER ;

-- 4. Hãy cấu hình table sao cho khi xóa 1 location nào đó thì tất cả employee ở location đó sẽ có location_id = null
CREATE TABLE Employee
(employee_id INT(10) PRIMARY KEY AUTO_INCREMENT,
full_name VARCHAR(50),
email VARCHAR(50),
location_id INT(10),
FOREIGN KEY (location_id) REFERENCES location(location_id) ON DELETE SET NULL
);