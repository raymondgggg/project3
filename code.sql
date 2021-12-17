

/*Table structure for table states */
CREATE TABLE states
(
    name varchar(30) NOT NULL,
    abbreviation varchar(20) NOT NULL,
    CONSTRAINT states_pk PRIMARY KEY (name)
)
;


/*Table structure for table counties */
CREATE TABLE counties
(
    state varchar(30) NOT NULL,
    countyName varchar(20) NOT NULL,
    CONSTRAINT counties_pk PRIMARY KEY (state, countyName),
    CONSTRAINT counties_fk FOREIGN KEY (state) REFERENCES states (name)
)
;

/*Table structure for table locations */
CREATE TABLE locations
(
    state varchar(30) NOT NULL,
    county varchar(20) NOT NULL,
    name varchar(30) NOT NULL,
    address varchar(60) NOT NULL,
    CONSTRAINT locations_pk PRIMARY KEY (address),
    CONSTRAINT locations_fk FOREIGN KEY (state, county) REFERENCES counties (state, countyName)
)
;

/*Table structure for table events */
CREATE TABLE events
(
    eventName varchar(40) NOT NULL,
    CONSTRAINT events_pk PRIMARY KEY (eventName)
)
;

/*Table structure for table event_dates */
CREATE TABLE eventDates
(
    location varchar(60) NOT NULL,
    event varchar(40) NOT NULL,
    date date NOT NULL,
    eventLen decimal(10,2) NOT NULL,
    CONSTRAINT eventDates_pk PRIMARY KEY (location, event),
    CONSTRAINT eventDates_fk1 FOREIGN KEY (location) REFERENCES locations (address),
    CONSTRAINT eventDates_fk2 FOREIGN KEY (event) REFERENCES events (eventName)

)
;

/*Table structure for table skills */
CREATE TABLE skills
(
    skillName varchar(30) NOT NULL,
    CONSTRAINT skills_pk PRIMARY KEY (skillName)
)
;

/*Table structure for table event_skills */
CREATE TABLE eventSkills
(
    eventName varchar(40) NOT NULL,
    skillName varchar(30) NOT NULL,
    CONSTRAINT eventSkills_pk PRIMARY KEY (eventName, skillName),
    CONSTRAINT eventSkills_fk1 FOREIGN KEY (eventName) REFERENCES events (eventName),
    CONSTRAINT eventSkills_fk2 FOREIGN KEY (skillName) REFERENCES skills (skillName)
)
;

/*Table structure for table persons */
CREATE TABLE persons
(
    stateID int NOT NULL,
    firstName varchar(30) NOT NULL,
    lastName varchar(30) NOT NULL,
    CONSTRAINT persons_pk PRIMARY KEY (stateID)
)
;

/*Table structure for table guards */
CREATE TABLE guards
(
    id int NOT NULL,
    guardID int NOT NULL,
    weeklyHrs decimal(10,2) NOT NULL,
    hourlyRate decimal(10,2) NOT NULL,
    state varchar(30) NOT NULL,
    county varchar(20) NOT NULL,
    CONSTRAINT guards_pk PRIMARY KEY (id),
    CONSTRAINT guards_fk1 FOREIGN KEY (id) REFERENCES persons (stateID),
    CONSTRAINT guards_fk2 FOREIGN KEY (state, county) REFERENCES counties (state, countyName)
)
;

/*Table structure for table guard_event_dates */
CREATE TABLE guardEventDates
(
    id int NOT NULL,
    location varchar(60) NOT NULL,
    event varchar(40) NOT NULL,
    CONSTRAINT guardEventDates_pk PRIMARY KEY (id, location, event),
    CONSTRAINT guardEventDates_fk1 FOREIGN KEY (id) REFERENCES guards (id),
    CONSTRAINT guardEventDates_fk2 FOREIGN KEY (location, event) REFERENCES eventDates (location, event)
)
;

/*Table structure for table prisoners */
CREATE TABLE prisoners
(
    id int NOT NULL,
    prisonerID int NOT NULL,
    CONSTRAINT prisoners_pk PRIMARY KEY (id),
    CONSTRAINT prisoners_fk FOREIGN KEY (id) REFERENCES persons (stateID)
)
;

/*Table structure for table prisoner_event_dates */
CREATE TABLE prisonerEventDates
(
    id int NOT NULL,
    location varchar(60) NOT NULL,
    event varchar(40) NOT NULL,
    CONSTRAINT prisonerEventDates_pk PRIMARY KEY (id, location, event),
    CONSTRAINT prisonerEventDates_fk1 FOREIGN KEY (id) REFERENCES prisoners (id),
    CONSTRAINT prisonerEventDates_fk2 FOREIGN KEY (location, event) REFERENCES eventDates (location, event)
)
;

/*Table structure for table statuses */
CREATE TABLE statuses
(
    statusType varchar(25) NOT NULL,
    CONSTRAINT statuses_pk PRIMARY KEY (statusType)
)
;

/*Table structure for table jails */
CREATE TABLE jails
(
    id int NOT NULL,
    name varchar(40) NOT NULL,
    CONSTRAINT jails_pk PRIMARY KEY (id)
)
;

/*Table structure for table crimes */
CREATE TABLE crimes
(
    id int NOT NULL,
    crime varchar(40) NOT NULL,
    maxTime decimal(10,2) NOT NULL,
    CONSTRAINT crimes_pk PRIMARY KEY (id)
)
;

/*Table structure for table prisoner_assignments */
CREATE TABLE prisonerAssignments
(
    jailID int NOT NULL,
    crimeID int NOT NULL,
    id int NOT NULL,
    startDate date,
    endDate date,
    hrsLeft decimal(10,2) NOT NULL,
    hrsWorked decimal(10,2) NOT NULL,
    status varchar(25),
    CONSTRAINT prisonerAssignments_pk PRIMARY KEY (id,endDate),
    CONSTRAINT prisonerAssignments_fk1 FOREIGN KEY (jailID) REFERENCES jails (id),
    CONSTRAINT prisonerAssignments_fk2 FOREIGN KEY (crimeID) REFERENCES crimes (id),
    CONSTRAINT prisonerAssignments_fk3 FOREIGN KEY (id) REFERENCES prisoners (id),
    CONSTRAINT prisonerAssignments_fk4 FOREIGN KEY (status) REFERENCES statuses (statusType)
)
;



/*Data for the table states */
insert into states
    (name, abbreviation)
values
    ('Alabama', 'AL'),
    ('Nevada', 'NV'),
    ('California', 'CA'),
    ('Texas', 'TX'),
    ('Florida', 'FL'),
    ('Georgia', 'GA'),
    ('New York', 'NY'),
    ('New Mexico', 'NM'),
    ('Ohio', 'OH');

/*Data for the table counties */
insert into counties
    (state, countyName)
values
    ('California', 'Los Angeles County'),
    ('California', 'Orange County'),
    ('California', 'San Diego County'),
    ('Nevada', 'Elko County'),
    ('Nevada', 'Mineral County'),
    ('Texas', 'Bell County'),
    ('Florida', 'Union County');

/*Data for the table locations */
insert into locations
    (state, county, name, address)
values
    ('California', 'Los Angeles County', 'West Court Building', '75 Birmingham Rd Burbank, CA, 91504'),
    ('California', 'Orange County', 'East Court Building', '341 Pine St, Irvine, CA, 92606'),
    ('California', 'San Diego County', 'South Court Tower', '440 Mesa Dr, Oceanside, CA, 92056'),
    ('Nevada', 'Elko County', 'Downtown Justice Center', '205 Gold Ct, Carlin, NV, 89822'),
    ('Nevada', 'Mineral County', 'Mineral Regional Center', '754 E St Hawthorne, NV, 89415'),
    ('Texas', 'Bell County', 'South Court Tower', '1100 Shady Ln, Belton, TX, 76513'),
    ('Florida', 'Union County', 'Union Detention Facility', '145 Curlew Ave, Naples, FL, 34102');

/*Data for the table events */
insert into events
    (eventName)
values
    ('Volunteer with Angel Tree'),
    ('Annual Holiday Outreach'),
    ('Pet Rescue Pilots'),
    ('Food Pantry Distribution'),
    ('Native Garden Volunteer Day'),
    ('Outdoor Volunteer Day'),
    ('Friends & Neighbors Day of Service'),
    ('Holiday Community Service Day'),
    ('Trail Volunteer Event'),
    ('Volunteer at Riverside City Mission'),
    ('Holiday Toy Drive'),
    ('Beach Cleanup');

/*Data for the table eventDates */
insert into eventDates
    (location, event, date, eventLen)
values
    ('75 Birmingham Rd Burbank, CA, 91504', 'Annual Holiday Outreach', '2021-12-20', 6.00),
    ('341 Pine St, Irvine, CA, 92606', 'Pet Rescue Pilots', '2021-12-21', 5.50),
    ('341 Pine St, Irvine, CA, 92606', 'Holiday Community Service Day', '2021-12-20', 4.75 ),
    ('440 Mesa Dr, Oceanside, CA, 92056', 'Food Pantry Distribution', '2022-01-10', 5.00 ),
    ('205 Gold Ct, Carlin, NV, 89822', 'Outdoor Volunteer Day', '2022-01-02', 6.00),
    ('754 E St Hawthorne, NV, 89415', 'Trail Volunteer Event', '2021-12-22', 4.00 ),
    ('754 E St Hawthorne, NV, 89415', 'Volunteer at Riverside City Mission', '2022-01-03', 6.25),
    ('1100 Shady Ln, Belton, TX, 76513', 'Beach Cleanup', '2022-01-05', 6.00),
    ('145 Curlew Ave, Naples, FL, 34102', 'Holiday Toy Drive', '2021-12-19', 4.5  ),
    ('145 Curlew Ave, Naples, FL, 34102', 'Volunteer with Angel Tree', '2021-12-28', 4.5 ),
    ('341 Pine St, Irvine, CA, 92606', 'Native Garden Volunteer Day', '2022-02-10', 4.75 ),
    ('440 Mesa Dr, Oceanside, CA, 92056', 'Friends & Neighbors Day of Service', '2022-02-02', 4.00);


/*Data for the table skills */
insert into skills
    (skillName)
values
    ('Communication'),
    ('Compassion'),
    ('Cooperation'),
    ('Teamwork'),
    ('Organization'),
    ('Creativity'),
    ('Empathy'),
    ('Enthusiasm'),
    ('Friendliness'),
    ('Patience'),
    ('Respectability'),
    ('Dedication'),
    ('Motivation');

/*Data for the table eventSkills */
insert into eventSkills
    (eventName, skillName)
values
    ('Volunteer with Angel Tree', 'Respectability' ),
    ('Annual Holiday Outreach', 'Enthusiasm'),
    ('Pet Rescue Pilots', 'Compassion' ),
    ('Food Pantry Distribution', 'Cooperation'),
    ('Native Garden Volunteer Day', 'Dedication' ),
    ('Outdoor Volunteer Day', 'Motivation' ),
    ('Friends & Neighbors Day of Service', 'Friendliness'),
    ('Holiday Community Service Day', 'Patience' ),
    ('Trail Volunteer Event', 'Compassion' ),
    ('Volunteer at Riverside City Mission', 'Motivation' ),
    ('Holiday Toy Drive', 'Enthusiasm'),
    ('Beach Cleanup', 'Teamwork');

/*Data for the table persons */
insert into persons
    (stateID, firstName, lastName)
values
    (12445, 'James', 'King'),
    (24567, 'Elizabeth', 'Perez'),
    (89089, 'Robert', 'Hayes'),
    (67654, 'Michael', 'Smith'),
    (38938, 'Kimberly', 'Kelly'),
    (32738, 'John', 'Henderson'),
    (45632, 'Betty', 'Ford'),
    (14934, 'Richard', 'Ford'),
    (34853, 'William', 'Diaz'),

    (45673, 'David', 'Jackson'),
    (34587, 'Rayne', 'Andrews'),
    (89786, 'Margarita', 'Berry'),
    (26756, 'Colt', 'Baird'),
    (22348, 'Samiyah', 'Neal'),
    (78956, 'Rachel', 'Barnhart'),
    (34456, 'Jasper', 'Mcdonald');

/*Data for the table guards */
insert into guards
    (id, guardID, weeklyHrs, hourlyRate, state, county)
values
    (34456, 675, 40, 22, 'California', 'Los Angeles County'),
    (78956, 785, 38, 23, 'California', 'Orange County'),
    (22348, 847, 44, 23, 'California', 'San Diego County'),
    (26756, 957, 50, 26, 'Nevada', 'Elko County'),
    (89786, 958, 29, 26, 'Nevada', 'Mineral County'),
    (34587, 932, 33, 30, 'Texas', 'Bell County'),
    (45673, 654, 28, 26, 'Florida', 'Union County');

/*Data for the table guardEventDates */
insert into guardEventDates
    (id, location, event)
values
    (34456, '75 Birmingham Rd Burbank, CA, 91504', 'Annual Holiday Outreach' ),
    (78956, '341 Pine St, Irvine, CA, 92606', 'Pet Rescue Pilots'),
    (22348, '341 Pine St, Irvine, CA, 92606', 'Holiday Community Service Day'),
    (26756, '440 Mesa Dr, Oceanside, CA, 92056', 'Food Pantry Distribution'),
    (89786, '205 Gold Ct, Carlin, NV, 89822', 'Outdoor Volunteer Day'),
    (34587, '754 E St Hawthorne, NV, 89415', 'Trail Volunteer Event'),
    (45673, '754 E St Hawthorne, NV, 89415', 'Volunteer at Riverside City Mission'),
    (34456, '1100 Shady Ln, Belton, TX, 76513', 'Beach Cleanup'),
    (78956, '145 Curlew Ave, Naples, FL, 34102', 'Holiday Toy Drive'),
    (22348, '145 Curlew Ave, Naples, FL, 34102', 'Volunteer with Angel Tree'),
    (89786, '341 Pine St, Irvine, CA, 92606', 'Native Garden Volunteer Day'),
    (34456, '440 Mesa Dr, Oceanside, CA, 92056', 'Friends & Neighbors Day of Service');

/*Data for the table prisoners */
insert into prisoners
    (id, prisonerID)
values
    (12445, 10),
    (24567, 11),
    (89089, 12),
    (67654, 13),
    (38938, 14),
    (32738, 15),
    (45632, 16),
    (14934, 17),
    (34853, 18);

/*Data for the table prisonerEventDates */
insert into prisonerEventDates
    (id, location, event)
VALUES
    (12445, '75 Birmingham Rd Burbank, CA, 91504', 'Annual Holiday Outreach'),
    (12445, '440 Mesa Dr, Oceanside, CA, 92056', 'Food Pantry Distribution'),
    (12445, '1100 Shady Ln, Belton, TX, 76513', 'Beach Cleanup'),
    (12445, '145 Curlew Ave, Naples, FL, 34102', 'Volunteer with Angel Tree'),
    (24567, '341 Pine St, Irvine, CA, 92606', 'Pet Rescue Pilots'),
    (89089, '341 Pine St, Irvine, CA, 92606', 'Holiday Community Service Day'),
    (89089, '440 Mesa Dr, Oceanside, CA, 92056', 'Friends & Neighbors Day of Service'),
    (67654, '440 Mesa Dr, Oceanside, CA, 92056', 'Food Pantry Distribution'),
    (67654, '145 Curlew Ave, Naples, FL, 34102', 'Volunteer with Angel Tree'),
    (38938, '205 Gold Ct, Carlin, NV, 89822', 'Outdoor Volunteer Day'),
    (38938, '341 Pine St, Irvine, CA, 92606', 'Native Garden Volunteer Day'),
    (32738, '754 E St Hawthorne, NV, 89415', 'Trail Volunteer Event'),
    (32738, '1100 Shady Ln, Belton, TX, 76513', 'Beach Cleanup'),
    (45632, '754 E St Hawthorne, NV, 89415', 'Volunteer at Riverside City Mission'),
    (14934, '1100 Shady Ln, Belton, TX, 76513', 'Beach Cleanup'),
    (34853, '145 Curlew Ave, Naples, FL, 34102', 'Holiday Toy Drive');

/*Data for the table statuses */
insert into statuses
    (statusType)
values
    ('in progress'),
    ('completed'),
    ('not complete'),
    ('completed late');

/*Data for the table jails */
insert into jails
    (id, name)
values
    (3674745, 'Metropolitan Detention Center'),
    (6372622, 'High Desert Detention Center'),
    (7462521, 'Facility 8 Detention Facility'),
    (8373652, 'Otay Mesa Detention Center'),
    (7363622, 'Smith Correctional Facility'),
    (3383722, 'Inmate Reception Center'),
    (1192233, 'Lincoln Heights Jail');

/*Data for the table crimes */
insert into crimes
    (id, crime, maxTime)
values
    (1, 'Kidnapping', 30),
    (2, 'Manslaughter', 10),
    (3, 'Prostitution', 1),
    (4, 'Assault 1st degree', 25),
    (5, 'Burglary 1st degree', 20),
    (6, 'Drug possession', 4),
    (7, 'Drug Trafficking', 20),
    (8, 'Handgun Possession', 3),
    (9, 'Robbery', 15);

/*Data for the table prisonerAssignments */
insert into prisonerAssignments
    (jailID, crimeID, id, endDate, startDate ,hrsLeft, hrsWorked)
values
    (3674745, 1, 12445, '2017-04-13', '2017-05-13', 0, 21.5),
    (6372622, 2, 24567, '2017-05-12', '2017-06-12', 18, 5.50),
    (7462521, 3, 89089, '2017-03-13', '2017-04-13', 20, 8.75),
    (8373652, 4, 67654, '2017-02-11', '2017-03-11', 21, 9.5),
    (7363622, 5, 38938, '2017-09-11', '2017-10-12', 31, 10.75),
    (3383722, 6, 32738, '2017-03-11', '2017-07-10', 12, 10),
    (1192233, 7, 45632, '2017-02-11', '2017-05-12', 3, 6.25),
    (3383722, 1, 14934, '2017-09-11', '2017-08-13', 17, 6),
    (1192233, 2, 34853, '2017-03-11', '2017-11-13', 25, 4.5);


-- list out the guard that worked the most times with a prisoner


-- Find how many hours a person needs, has completed, and how long they have left, as well as
-- their skills for all the events they have been assigned. (uses aggregate function)
SELECT distinct firstName, lastName, hrsLeft, DATEDIFF(startDate, endDate) AS "Days to complete assignment", skillName
FROM persons
    JOIN prisoners p on persons.stateID = p.id
    JOIN prisonerAssignments pA on p.id = pA.id
    JOIN prisonerEventDates pED on p.id = pED.id
    JOIN eventDates eD on pED.location = eD.location and pED.event = eD.event
    JOIN events e on eD.event = e.eventName
    JOIN eventSkills eS on e.eventName = eS.eventName;

-- show all the guards and prisoners who events on the same day (does not work)
SELECT guard.firstName, guard.LastName, prisoner.firstName, prisoner.LastName
FROM persons guard, persons prisoner
    JOIN prisoners p2 on prisoner.stateID = p2.id
    JOIN prisonerEventDates D on p2.id = D.id
    JOIN eventDates eD on D.location = eD.location and D.event = eD.event
    JOIN guardEventDates gED on gED.location = D.location and D.event = gED.event
WHERE gED.location LIKE d.location AND gED.event LIKE d.event
GROUP BY guard.firstName, guard.LastName, prisoner.firstName, prisoner.LastName;


-- find individuals who are not halfway through their times by the halfway point



-- List individuals by most amount of time required, as well as their best skill (how would we do best skill)
SELECT hrsLeft AS "Time required (hrs)", firstName, lastName, skillName
FROM persons
    JOIN prisoners p on persons.stateID = p.id
    JOIN prisonerAssignments pA on p.id = pA.id
    JOIN prisonerEventDates pED on p.id = pED.id
    JOIN eventDates eD on pED.location = eD.location and pED.event = eD.event
    JOIN events e on eD.event = e.eventName
    JOIN eventSkills eS on e.eventName = eS.eventName
group by DATEDIFF(startDate, endDate)
ORDER BY hrsLeft desc;


-- view: how long an event is







