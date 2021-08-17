drop database aviation;
create database aviation;
use aviation;
create table AIRPORT(
	Airport_code varchar(10) not null unique,
	Name  varchar(255) not null,
	City varchar(30),
	State varchar(20),	 	 	 		
	constraint primary key(Airport_code)
);

create table AIRPLANE_TYPE(
	Airplane_type_name varchar(10) not null unique,
	Max_seats int not null,
	Company varchar(20) not null,
	constraint primary key(Airplane_type_name)
);

create table FLIGHT(
	Flight_number varchar(20) not null unique,
	Airline  varchar(30) not null,
	Weekdays varchar(7) not null,	 	 		
	constraint primary key(Flight_number)
);

create table FLIGHT_LEG(
	Flight_number varchar(20) not null,
	Leg_number int not null,
	Departure_airport_code varchar(10) not null,
	Arrival_airport_code varchar(10) not null,
	Scheduled_departure_time time not null,
	Scheduled_arrival_time time not null,
	constraint primary key(Flight_number,Leg_number),
	constraint foreign key(Flight_number) references FLIGHT(Flight_number),
	constraint foreign key(Departure_airport_code) references AIRPORT(Airport_code),
	constraint foreign key(Arrival_airport_code) references AIRPORT(Airport_code)
);

create table AIRPLANE(
	Airplane_id int not null auto_increment,
	Airplane_type varchar(10) not null,
	Total_number_of_seats int not null,
	constraint primary key(Airplane_id),
	constraint foreign key(Airplane_type) references AIRPLANE_TYPE(Airplane_type_name)
);


create table LEG_INSTANCE(
	Flight_number varchar(20) not null,
	Leg_number int not null,
	DATE date not null,
	Number_of_available_seats int not null,
	Airplane_id int not null,
	Departure_airport_code varchar(10) not null,
	Arrival_airport_code varchar(10) not null,
	Departure_time time not null,
	Arrival_time time not null,
	constraint primary key(Flight_number,Leg_number,Date),
	constraint foreign key(Flight_number) references FLIGHT(Flight_number),
	constraint foreign key(Airplane_id) references AIRPLANE(Airplane_id),
	constraint foreign key(Departure_airport_code) references AIRPORT(Airport_code),
	constraint foreign key(Arrival_airport_code) references AIRPORT(Airport_code)
);

create table FARE(
	Flight_number varchar(20) not null,
	Fare_code varchar(5) not null,
	Amount int not null,
	Restrictions varchar(255),
	constraint primary key(Flight_number,Fare_code),
	constraint foreign key(Flight_number) references FLIGHT(Flight_number)
);

create table CAN_LAND(
	Airplane_type_name varchar(10) not null,
	Airport_code varchar(10) not null,
	constraint primary key(Airplane_type_name,Airport_code),
	constraint foreign key(Airplane_type_name) references AIRPLANE_TYPE(Airplane_type_name),
	constraint foreign key(Airport_code) references AIRPORT(Airport_code)
);


create table SEAT_RESERVATION(
	Flight_number varchar(20) not null,
	Leg_number int not null,
	DATE date not null,
	Seat_number int not null,
	Customer_Name varchar(30) not null,
	Customer_phone varchar(30) not null,
	constraint primary key(Flight_number,Leg_number,Date,Seat_number),
	constraint foreign key(Flight_number) references FLIGHT(Flight_number)
);

delimiter //
CREATE TRIGGER fare_amount BEFORE INSERT
ON FARE
FOR EACH ROW
BEGIN
   IF NEW.Amount < 0 OR NEW.Amount > 10000
   THEN
       signal sqlstate '45000'
       SET MESSAGE_TEXT = 'Fare amount should be between 0 and 10000.';
   END IF;
END;//
delimiter ;


delimiter //
CREATE TRIGGER airplane_type_seats BEFORE INSERT
ON AIRPLANE_TYPE
FOR EACH ROW
BEGIN
   IF NEW.Max_seats >600
   THEN
       signal sqlstate '45000'
       SET MESSAGE_TEXT = 'Max_seats cannot exceed 600';
   END IF;
END;//
delimiter ;

delimiter //
CREATE TRIGGER leg_number_limit BEFORE INSERT
ON FLIGHT_LEG
FOR EACH ROW
BEGIN
   IF (SELECT count(*) from FLIGHT_LEG where Flight_number=new.Flight_number) >= 4
   THEN
       signal sqlstate '45000'
       SET MESSAGE_TEXT = 'A flight cannot have more than 4 legs';
   END IF;
END;//
delimiter ;


delimiter //
CREATE TRIGGER les_instance_date BEFORE INSERT
ON LEG_INSTANCE
FOR EACH ROW
BEGIN
   IF NEW.Date < CURDATE()
   THEN
       signal sqlstate '45000'
       SET MESSAGE_TEXT = 'A flight can only be today or future dates.';
   END IF;
END;//
delimiter ;


INSERT INTO AIRPORT VALUES ("SFO","San Francisco Internation Airport","San Francisco","CA");
INSERT INTO AIRPORT VALUES ("LAX","Los Angeles Internation Airport","Los Angeles","CA");
INSERT INTO AIRPORT VALUES ("IAD","Washington Dulles International Airport","Washington DC","DC");
INSERT INTO AIRPORT VALUES ("BWI","Baltimore Washington International Airport","Baltimore","MD");
INSERT INTO FLIGHT VALUES ("United 189","United","MF");
INSERT INTO FLIGHT VALUES ("United 321","United","MF");
INSERT INTO FLIGHT VALUES ("Alaska 321","Alaska","TTh");
INSERT INTO FLIGHT VALUES ("Alaska 322","Alaska","TTh");

INSERT INTO FLIGHT_LEG values ("United 189",1,"SFO","BWI","12:00:00","17:32:00");
INSERT INTO FLIGHT_LEG values ("United 189",2,"BWI","IAD","19:00:00","22:32:00");
INSERT INTO FLIGHT_LEG values ("United 189",3,"IAD","LAX","23:00:00","23:52:00");
INSERT INTO FLIGHT_LEG values ("United 321",1,"LAX","BWI","12:00:00","17:32:00");
INSERT INTO FLIGHT_LEG values ("United 321",2,"BWI","SFO","19:00:00","22:32:00");
INSERT INTO FLIGHT_LEG values ("United 321",3,"SFO","IAD","23:00:00","23:52:00");
INSERT INTO FLIGHT_LEG values ("Alaska 321",1,"SFO","BWI","12:00:00","17:32:00");
INSERT INTO FLIGHT_LEG values ("Alaska 322",3,"BWI","SFO","19:00:00","22:32:00");


INSERT INTO AIRPLANE_TYPE values("B737",200,"Boeing"),("B777",400,"Boeing"),("A330",350,"AirBus");
INSERT CAN_LAND(Airport_code,Airplane_type_name) values ("SFO","B777"),("IAD","B777"),("IAD","A330"),("IAD","B737"),("LAX","B777"),("LAX","A330"),("BWI","B777"),("BWI","A330");

INSERT INTO AIRPLANE (Airplane_type,Total_number_of_seats) values
("B737",101),("B737",102),("B737",101),("B737",200),
("B777",300),("B777",300),("B777",350),("B777",350),
("A330",150),("A330",250),("A330",350);

INSERT INTO LEG_INSTANCE values 
("United 189",1,"2021-08-20",44,1,"SFO","BWI","12:12:12","16:44:42"),
("United 189",2,"2021-08-20",44,1,"BWI","IAD","12:12:12","16:44:42"),
("United 189",3,"2021-08-20",44,1,"IAD","LAX","12:12:12","16:44:42"),
("United 321",1,"2021-08-20",44,2,"LAX","BWI","12:12:12","16:44:42"),
("United 321",2,"2021-08-20",44,2,"BWI","SFO","12:12:12","16:44:42"),
("United 321",3,"2021-08-20",44,2,"SFO","IAD","12:12:12","16:44:42"),
("United 189",1,"2021-08-21",44,1,"SFO","BWI","12:12:12","16:44:42"),
("United 189",2,"2021-08-21",44,1,"BWI","IAD","12:12:12","16:44:42"),
("United 189",3,"2021-08-21",44,1,"IAD","LAX","12:12:12","16:44:42"),
("United 321",1,"2021-08-21",44,2,"LAX","BWI","12:12:12","16:44:42"),
("United 321",2,"2021-08-21",44,2,"BWI","SFO","12:12:12","16:44:42"),
("United 321",3,"2021-08-21",44,2,"SFO","IAD","12:12:12","16:44:42"),
("United 189",1,"2021-08-27",44,1,"SFO","BWI","12:12:12","16:44:42"),
("United 189",2,"2021-08-27",44,1,"BWI","IAD","12:12:12","16:44:42"),
("United 189",3,"2021-08-27",44,1,"IAD","LAX","12:12:12","16:44:42"),
("United 321",1,"2021-08-27",44,2,"LAX","BWI","12:12:12","16:44:42"),
("United 321",2,"2021-08-27",44,2,"BWI","SFO","12:12:12","16:44:42"),
("United 321",3,"2021-08-27",44,2,"SFO","IAD","12:12:12","16:44:42"),
("Alaska 321",1,"2021-08-20",1,2,"SFO","BWI","12:12:12","16:44:42"),
("Alaska 322",3,"2021-08-20",3,2,"BWI","SFO","12:12:12","16:44:42"),
("Alaska 321",1,"2021-08-27",1,2,"SFO","BWI","12:12:12","16:44:42"),
("Alaska 322",3,"2021-08-27",2,2,"BWI","SFO","12:12:12","16:44:42");

INSERT INTO FARE VALUES 
("United 189","A",1000,"a"),
("United 189","B",2000,"a"),
("United 189","C",3000,"a"),
("United 321","C",300,"a"),
("Alaska 321","C",400,"a"),
("Alaska 322","C",500,"a");

select * from CAN_LAND natural join AIRPLANE_TYPE where Airport_code = 'IAD';

select * from FARE where Flight_number='United 189';

select * from LEG_INSTANCE natural join FLIGHT_LEG  where date="2021-08-20" and LEG_INSTANCE.Departure_airport_code="BWI" 
and LEG_INSTANCE.Arrival_airport_code="SFO" and Number_of_available_seats > 2;


select * from LEG_INSTANCE natural join FLIGHT_LEG  where date="2021-08-27" and LEG_INSTANCE.Departure_airport_code="SFO" 
and LEG_INSTANCE.Arrival_airport_code="BWI";