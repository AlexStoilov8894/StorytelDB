CREATE DATABASE StorytelDB;
USE StorytelDB;

CREATE TABLE Customer(
id INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
first_name VARCHAR(30) NOT NULL,
last_name VARCHAR(30) NOT NULL,
gender ENUM('M' , 'F') NOT NULL,
phone_number VARCHAR(10) NOT NULL UNIQUE,
age INT NOT NULL
);

CREATE TABLE Subscription(
id INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
sub_type VARCHAR(30) NOT NULL,
price DECIMAL (4,2),
start_time DATETIME
);

CREATE TABLE Account(
id INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
customer_id INT,
username VARCHAR(30) NOT NULL UNIQUE,
email VARCHAR(30) NOT NULL UNIQUE,
subscription_id INT,
FOREIGN KEY(customer_id) REFERENCES Customer(id),
FOREIGN KEY(subscription_id) REFERENCES Subscription(id)
);

CREATE TABLE Author(
id INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
first_name VARCHAR(30) NOT NULL,
last_name VARCHAR(30) NOT NULL,
country VARCHAR(30) NOT NULL,
age int NOT NULL
);

CREATE TABLE Doubler(
id INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
first_name VARCHAR(30) NOT NULL,
last_name VARCHAR(30) NOT NULL,
country VARCHAR(30) NOT NULL,
age int NOT NULL
);

CREATE TABLE Book(
id INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
name VARCHAR(30) NOT NULL,
genre VARCHAR(30) NOT NULL,
author_id INT,
doubler_id INT,
duration INT NOT NULL,
FOREIGN KEY(author_id) REFERENCES Author(id),
FOREIGN KEY(doubler_id) REFERENCES Doubler(id)
);

CREATE TABLE Stream_details(
id INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
username_id INT,
book_id INT,
rating DOUBLE(3,2),
stream_date DATE
);

INSERT INTO Customer(first_name, last_name, gender, phone_number, age)
VALUES ('Dimitar', 'Raichev', 'M', '0878452565', 21), 
('Gergana', 'Marinova', 'F', '0895646248', 40), 
('Georgi', 'Ivanov', 'M', '0888442658', 18), 
('Iva', 'Trifonova', 'F', '0889234487', 30),
('Stoqn', 'Stoqnov', 'M', '0877454589', 25),
('Yordanka', 'Yordanova', 'F', '0885642569', 25) ;

INSERT INTO Subscription(sub_type, price, start_time)
VALUES ('Weekly', 5.99, '2021-10-07 20:00:00'),
('Monthly' , 11.99, '2021-09-14 16:00:00'),
('Annual', 49.95, '2020-10-15 12:30:00');

INSERT INTO Account(customer_id, username, email, subscription_id)
VALUES (1, 'username12', 'username12@abv.bg', 3),
(2, 'username22', 'username22@abv.bg', 1),
(3, 'username32', 'username32@abv.bg', 1),
(4, 'username42', 'username42@abv.bg', 2),
(5, 'username52', 'username12@abv.5g', 3),
(6, 'username62', 'username62@abv.bg', 2);

INSERT INTO Author(first_name, last_name, country, age)
VALUES ('Alice' , 'Walker', 'USA', 77),
('Stephen', 'King', 'UK', 74),
('JK', 'Rowling', 'UK', 56),
('Rachel', 'Kushner', 'USA', 53);

INSERT INTO Doubler(first_name, last_name, country, age)
VALUES ('Vanya' , 'Serafimova', 'Bulgaria', 46),
('Georgi', 'Georgiev', 'Bulgaria', 70),
('Stefka', 'Stoqnova', 'Bulgaria', 33),
('Venelin', 'Ivanov', 'Bulgaria', 44);

INSERT INTO Book(name, genre, author_id, doubler_id, duration)
VALUES('The Mars Room','Fantasy', 4, 2, 145),
('The Flamethrowers','Novel', 4, 4, 202),
('It','Horror', 2, 1, 134),
('The Shining','Horror', 2, 2, 225),
('The Color Purple','Novel',1, 1, 100),
('Meridian','Fiction', 1, 4, 86),
('Harry Potter', 'Fantasy', 3, 3, 246),
('The Ickabog','Fantasy', 3, 3, 166);

INSERT INTO Stream_details(username_id, book_id, rating, stream_date)
VALUES(1, 3, 5.25, '2021-06-08'),
(2, 1, 9.50, '2021-10-12'),
(3, 2, 6.00, '2021-10-08'),
(4, 3, 7.25, '2021-09-22'),
(1, 4, 5.50, '2020-11-08'),
(5, 5, 9.99, '2020-12-20'),
(6, 2, 4.25, '2021-09-27'),
(1, 6, 7.50, '2021-04-27'),
(5, 1, 5.25, '2021-07-14'),
(2, 4, 8.20, '2021-10-11'),
(4, 6, 7.75, '2021-09-30'),
(6, 3, 8.00, '2021-02-14');

DELIMITER // 

CREATE PROCEDURE getStreamData()
BEGIN

SELECT a.username, a.email, c.last_name, c.phone_number, c.age, b.name, s.rating, s.stream_date FROM Customer c
JOIN Account a ON c.id = a.customer_id
JOIN Stream_details s ON s.username_id = a.id
JOIN Book b ON s.book_id = b.id
GROUP BY a.username, c.last_name, b.name, s.rating, s.stream_date
ORDER BY s.stream_date ;

END // 

CREATE PROCEDURE getCustomerData()
BEGIN

SELECT c.first_name, c.last_name, c.gender, c.phone_number, a.username, a.email, s.sub_type, s.price FROM Customer c
JOIN Account a ON c.id = a.customer_id
JOIN Subscription s ON a.subscription_id = s.id
GROUP BY c.first_name, a.username, s.sub_type
ORDER BY s.price;

END //

CREATE PROCEDURE getBookData()
BEGIN

SELECT b.name, b.genre, b.duration, a.first_name, a.last_name, a.country, d.last_name, d.country FROM Book b
JOIN Author a ON a.id = b.author_id
JOIN Doubler d ON d.id = b.doubler_id
GROUP BY b.name, a.first_name, d.last_name;

END // 

CREATE PROCEDURE getRating()
BEGIN

SELECT a.username, b.name, cast(b.duration/60 as decimal(3,2)), s.rating FROM stream_details s
JOIN Account a ON a.id = s.username_id
JOIN Book b ON b.id = s.book_id
GROUP BY a.username, b.name, s.rating
ORDER BY s.rating ;

END //

CREATE TRIGGER customer_age
BEFORE INSERT ON Customer
FOR EACH ROW
IF NEW.age < 18 THEN
SIGNAL SQLSTATE '50001' SET MESSAGE_TEXT = 'Person must be older than 18.';
END IF; //

DELIMITER ;

CALL getStreamData();
CALL getCustomerData();
CALL getBookData();
CALL getRating();

INSERT INTO Customer(first_name, last_name, gender, phone_number, age)
VALUES ('Ico', 'Stoqnov', 'M', '0878452565', 16) ;


 