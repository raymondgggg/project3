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
    eventLen decimal(10, 2) NOT NULL,
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
    weeklyHrs decimal(10, 2) NOT NULL,
    hourlyRate decimal(10, 2) NOT NULL,
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
    maxTime decimal(10, 2) NOT NULL,
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
    hours_assigned decimal(10, 2) NOT NULL,
    hrsWorked decimal(10, 2) NOT NULL,
    status varchar(25),
    CONSTRAINT prisonerAssignments_pk PRIMARY KEY (id, endDate),
    CONSTRAINT prisonerAssignments_fk1 FOREIGN KEY (jailID) REFERENCES jails (id),
    CONSTRAINT prisonerAssignments_fk2 FOREIGN KEY (crimeID) REFERENCES crimes (id),
    CONSTRAINT prisonerAssignments_fk3 FOREIGN KEY (id) REFERENCES prisoners (id),
    CONSTRAINT prisonerAssignments_fk4 FOREIGN KEY (status) REFERENCES statuses (statusType)
)
;
-- NOTE: MAKE SURE TO ADD THE COUNTY AND STATE COLUMNS as migrating foreign keys to match the design
-- OR COME UP WITH MORE QUERIES THAT DO NOT REQUIRE ME TO CHANGE THE SCHEMA
-- triggers

-- Makes sure that there are two guards working an event before a prisoner is allowed to work
create trigger twoguards before
insert on
prisonereventdates
for
each
row
begin
    declare guardcount int;
select count(*)
into guardcount
from guardEventDates
where guardEventDates.event=new.event;
if guardcount<2 then
            signal sqlstate '45000'
set message_text
='not enough guards';

end
if;
end;

-- Makes sure that there are two guards working an event before a prisoner is allowed to work
create trigger twoguardsUpdate before
update on prisonereventdates
    for each row
begin
    declare guardcount int;
select count(*)
into guardcount
from guardEventDates
where guardEventDates.event=new.event;
if guardcount<2 then
            signal sqlstate '45000'
set message_text
='not enough guards';

end
if;
end;

-- Whatever time a prisoner worked, it adds the time into their hours worked after insert
#
create trigger insertWorked after
insert on
prisonereventdates
#
for each row
begin
#
declare tim decimal
(10,2);
#
declare currenttim decimal
(10,2);
#
select eventLen
into tim
#         from prisonereventdates inner join eventDates on prisonerEventDates.event= eventDates.event
#         where new.event=eventDates.event;
#
select hrsWorked
into currenttim
#         from prisonerAssignments
#             where prisonerAssignments.id=new.id;
#
update prisonerAssignments
#
set prisonerAssignments
.hrsWorked=
(tim+currenttim)
#     where prisonerAssignments.id=new.id;
#
#
end;

-- Whatever time a prisoner worked, it adds the time into their hours worked after update
create trigger updateWorked after
update on prisonereventdates
    for each row
begin
    declare tim decimal
    (10,2);
    declare currenttim decimal
    (10,2);
    select eventLen
    into tim
    from prisonereventdates inner join eventDates on prisonerEventDates.event= eventDates.event
    where new.event=eventDates.event;
    select hrsWorked
    into currenttim
    from prisonerAssignments
    where prisonerAssignments.id=new.id;
    update prisonerAssignments
    set prisonerAssignments.hrsWorked=(tim+currenttim)
    where prisonerAssignments.id=new.id;

end;

-- tested: makes status on prisoner assigment before insert
create trigger statusinsert before
insert on
prisonerAssignments
for
each
row
begin
    if new.hours_Assigned <= new.hrsWorked and curdate()<=new.endDate then
    set new
    .status= 'completed';
elseif  new.hours_Assigned<= new.hrsWorked and curdate
()>new.endDate then
set new
.status='completed late';
    elseif new.hours_Assigned> new.hrsWorked and curdate
()>new.endDate then
set new
.status= 'not complete';
    else
set new
.status='in progress';
end
if;
    end;

-- tested: makes status on prisoner assignment after update
create trigger statupdate before
update on prisonerAssignments
    for each row
begin
    if new.hours_Assigned <= new.hrsWorked and curdate()<=new.endDate then
    set new
    .status= 'completed';
elseif  new.hours_Assigned<= new.hrsWorked and curdate
()>new.endDate then
set new
.status='completed late';
    elseif new.hours_Assigned> new.hrsWorked and curdate
()>new.endDate then
set new
.status= 'not complete';
    else
set new
.status='in progress';
end
if;
    end;

-- Makes sure event is not longer than 24 hrs before insert
create trigger insertTime24 before
insert on
eventDates
for
each
row
begin
    if new.eventLen> 24 then
        signal sqlstate '45000'
    set message_text
    ='Cannot make event longer than 24 hours';
end
if;
end;

-- makes sure event is not longer than 24 hrs before update
create trigger updateTime24 before
update  on eventDates
    for each row
begin
    if new.eventLen> 24 then
        signal sqlstate '45000'
    set message_text
    ='Cannot make event longer than 24 hours';
end
if;
end;

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
    ('341 Pine St, Irvine, CA, 92606', 'Holiday Community Service Day', '2021-12-20', 4.75),
    ('440 Mesa Dr, Oceanside, CA, 92056', 'Food Pantry Distribution', '2022-01-10', 5.00),
    ('205 Gold Ct, Carlin, NV, 89822', 'Outdoor Volunteer Day', '2022-01-02', 6.00),
    ('754 E St Hawthorne, NV, 89415', 'Trail Volunteer Event', '2021-12-22', 4.00),
    ('754 E St Hawthorne, NV, 89415', 'Volunteer at Riverside City Mission', '2022-01-03', 6.25),
    ('1100 Shady Ln, Belton, TX, 76513', 'Beach Cleanup', '2022-01-05', 6.00),
    ('145 Curlew Ave, Naples, FL, 34102', 'Holiday Toy Drive', '2021-12-19', 4.5),
    ('145 Curlew Ave, Naples, FL, 34102', 'Volunteer with Angel Tree', '2021-12-28', 4.5),
    ('341 Pine St, Irvine, CA, 92606', 'Native Garden Volunteer Day', '2022-02-10', 4.75),
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
    ('Volunteer with Angel Tree', 'Respectability'),
    ('Annual Holiday Outreach', 'Enthusiasm'),
    ('Pet Rescue Pilots', 'Compassion'),
    ('Food Pantry Distribution', 'Cooperation'),
    ('Native Garden Volunteer Day', 'Dedication'),
    ('Outdoor Volunteer Day', 'Motivation'),
    ('Friends & Neighbors Day of Service', 'Friendliness'),
    ('Holiday Community Service Day', 'Patience'),
    ('Trail Volunteer Event', 'Compassion'),
    ('Volunteer at Riverside City Mission', 'Motivation'),
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
    (34456, '75 Birmingham Rd Burbank, CA, 91504', 'Annual Holiday Outreach'),
    (78956, '75 Birmingham Rd Burbank, CA, 91504', 'Annual Holiday Outreach'),
    (78956, '341 Pine St, Irvine, CA, 92606', 'Pet Rescue Pilots'),
    (34456, '341 Pine St, Irvine, CA, 92606', 'Pet Rescue Pilots'),
    (22348, '341 Pine St, Irvine, CA, 92606', 'Holiday Community Service Day'),
    (78956, '341 Pine St, Irvine, CA, 92606', 'Holiday Community Service Day'),
    (26756, '440 Mesa Dr, Oceanside, CA, 92056', 'Food Pantry Distribution'),
    (34587, '440 Mesa Dr, Oceanside, CA, 92056', 'Food Pantry Distribution'),
    (89786, '205 Gold Ct, Carlin, NV, 89822', 'Outdoor Volunteer Day'),
    (45673, '205 Gold Ct, Carlin, NV, 89822', 'Outdoor Volunteer Day'),
    (34587, '754 E St Hawthorne, NV, 89415', 'Trail Volunteer Event'),
    (45673, '754 E St Hawthorne, NV, 89415', 'Trail Volunteer Event'),
    (34456, '1100 Shady Ln, Belton, TX, 76513', 'Beach Cleanup'),
    (22348, '1100 Shady Ln, Belton, TX, 76513', 'Beach Cleanup'),
    (78956, '145 Curlew Ave, Naples, FL, 34102', 'Holiday Toy Drive'),
    (34587, '145 Curlew Ave, Naples, FL, 34102', 'Holiday Toy Drive'),
    (22348, '145 Curlew Ave, Naples, FL, 34102', 'Volunteer with Angel Tree'),
    (34456, '145 Curlew Ave, Naples, FL, 34102', 'Volunteer with Angel Tree'),
    (89786, '341 Pine St, Irvine, CA, 92606', 'Native Garden Volunteer Day'),
    (34456, '341 Pine St, Irvine, CA, 92606', 'Native Garden Volunteer Day'),
    (34456, '440 Mesa Dr, Oceanside, CA, 92056', 'Friends & Neighbors Day of Service'),
    (45673, '440 Mesa Dr, Oceanside, CA, 92056', 'Friends & Neighbors Day of Service');

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


-- (89089, '440 Mesa Dr, Oceanside, CA, 92056', 'Friends & Neighbors Day of Service'), insert data test
-- (45632, '754 E St Hawthorne, NV, 89415', 'Volunteer at Riverside City Mission'),
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
    (67654, '440 Mesa Dr, Oceanside, CA, 92056', 'Food Pantry Distribution'),
    (67654, '145 Curlew Ave, Naples, FL, 34102', 'Volunteer with Angel Tree'),
    (38938, '205 Gold Ct, Carlin, NV, 89822', 'Outdoor Volunteer Day'),
    (38938, '341 Pine St, Irvine, CA, 92606', 'Native Garden Volunteer Day'),
    (32738, '754 E St Hawthorne, NV, 89415', 'Trail Volunteer Event'),
    (32738, '1100 Shady Ln, Belton, TX, 76513', 'Beach Cleanup'),
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
    (jailID, crimeID, id, endDate ,hours_Assigned, hrsWorked)
values
    (3674745, 1, 12445, '2021-05-13', 30, 2),
    (6372622, 2, 24567, '2022-06-12', 20, 5.50),
    (7462521, 3, 89089, '2017-04-13', 50, 8.75),
    (8373652, 4, 67654, '2016-03-11', 10, 9.5),
    (7363622, 5, 38938, '2022-10-12', 31, 0),
    (3383722, 6, 32738, '2017-07-10', 5, 5),
    (1192233, 7, 45632, '2022-05-12', 3, 0),
    (3383722, 1, 14934, '2022-08-13', 17, 6),
    (1192233, 2, 34853, '2021-11-13', 25, 4.5);

update prisonerAssignments
set hrsWorked=3
where id=45632;




-- Find how many hours a person needs, has completed, and how long they have left, as well as
-- their skills for all the events they have been assigned. (uses aggregate function)
SELECT distinct firstName, lastName, hours_assigned, DATEDIFF(startDate, endDate) AS "Days to complete assignment", skillName
FROM persons
    JOIN prisoners p on persons.stateID = p.id
    JOIN prisonerAssignments pA on p.id = pA.id
    JOIN prisonerEventDates pED on p.id = pED.id
    JOIN eventDates eD on pED.location = eD.location and pED.event = eD.event
    JOIN events e on eD.event = e.eventName
    JOIN eventSkills eS on e.eventName = eS.eventName;

-- List individuals by most amount of time required, as well as their best skill (how would we do best skill)
SELECT hours_assigned AS "Time required (hrs)", firstName, lastName, skillName
FROM persons
    JOIN prisoners p on persons.stateID = p.id
    JOIN prisonerAssignments pA on p.id = pA.id
    JOIN prisonerEventDates pED on p.id = pED.id
    JOIN eventDates eD on pED.location = eD.location and pED.event = eD.event
    JOIN events e on eD.event = e.eventName
    JOIN eventSkills eS on e.eventName = eS.eventName
group by DATEDIFF(startDate, endDate)
ORDER BY hours_assigned desc;

-- List individual by completion status as well as final date given (uses aggregate function)
SELECT firstName,
    lastName,
    COALESCE((hrsWorked / hours_assigned) * 100, 100.00) AS "Completion Status (%)",
    endDate                                       AS "Final Date"
FROM persons
    JOIN prisoners p on persons.stateID = p.id
    JOIN prisonerAssignments pA on p.id = pA.id;

-- Find individuals who are not halfway through their times by the halfway point (uses aggregate function)
SELECT firstName, lastName, COALESCE((hrsWorked / hours_assigned) * 100, 100) AS "Completion %"
FROM persons
    JOIN prisoners p on persons.stateID = p.id
    JOIN prisonerAssignments pA on p.id = pA.id
WHERE (hrsWorked / hours_assigned) < .5;


-- Show all the events the guards have worked
SELECT firstName, lastName, event
FROM persons
    JOIN guards g on persons.stateID = g.id
    JOIN guardEventDates gED on g.id = gED.id;

-- Show all the events a prisoner has worked
SELECT firstName, lastName, event
FROM persons
    JOIN prisoners p on persons.stateID = p.id
    JOIN prisonerEventDates pED on p.id = pED.id;

-- Show each guard and the counties they are a part of.
SELECT firstName, lastName, county
FROM persons
    JOIN guards g on persons.stateID = g.id
    JOIN counties c on g.state = c.state and g.county = c.countyName;

-- Show how many events a guard has worked
SELECT firstName, lastName, COUNT(event) AS "Events Worked"
FROM persons
    JOIN guards g on persons.stateID = g.id
    JOIN guardEventDates gED on g.id = gED.id
GROUP BY firstName, lastName;

-- Show how many events a prisoner has worked
SELECT firstName, lastName, COUNT(event) AS "Events Worked"
FROM persons
    JOIN prisoners p on persons.stateID = p.id
    JOIN prisonerEventDates pED on p.id = pED.id
GROUP BY firstName, lastName;

CREATE VIEW prisonerSkillCount
AS
    SELECT firstName, lastName, COUNT(skillName)
    FROM persons
        JOIN prisoners p on persons.stateID = p.id
        JOIN prisonerEventDates pED on p.id = pED.id
        JOIN eventDates eD on pED.location = eD.location and pED.event = eD.event
        JOIN events e on eD.event = e.eventName
        JOIN eventSkills eS on e.eventName = eS.eventName
    GROUP BY firstName, lastName;

SELECT firstName, lastName, state
FROM persons
    JOIN guards g on persons.stateID = g.id
    JOIN prisoners p on persons.stateID = p.id
    JOIN prisonerAssignments pA on p.id = pA.id;


CREATE VIEW getLACounty
AS
    SELECT county
    FROM persons
        JOIN guards g2 on persons.stateID = g2.id
    WHERE county LIKE 'Los Angeles County';
-- Show all the guards who are not in Los Angeles County (uses subquery)
SELECT firstName, lastName
FROM persons
    JOIN guards g on persons.stateID = g.id
WHERE county NOT IN
      (
          SELECT *
FROM getLACounty
      );

CREATE VIEW getToyDriveEvent
AS
    SELECT eventName
    FROM events
    WHERE eventName LIKE 'Holiday Toy Drive';
-- Show all the guards who did not work the Holiday Toy Drive event (uses subquery)
SELECT DISTINCT firstName, lastName
FROM persons
    JOIN guards g on persons.stateID = g.id
    JOIN guardEventDates gED on g.id = gED.id
    JOIN eventDates eD on gED.location = eD.location and gED.event = eD.event
WHERE gED.event NOT IN
      (
        SELECT *
FROM gettoydriveevent
      );



CREATE VIEW DateDiffGreater30
AS
    SELECT DATEDIFF(startDate, endDate)
    FROM prisonerassignments
    WHERE DATEDIFF(startDate, endDate) > 30;
-- Show all the prisoners who have 30 days or less to complete their assignment (uses subquery)
SELECT firstName, lastName, DATEDIFF(startDate, endDate) AS DaysLeft
FROM persons
    JOIN prisoners p on persons.stateID = p.id
    JOIN prisonerAssignments pA on p.id = pA.id
WHERE DATEDIFF(startDate, endDate) NOT IN (
    SELECT *
FROM datediffgreater30
);


CREATE VIEW getBeachAndFoodEvents
AS
    SELECT eventName
    FROM events
    WHERE eventName LIKE 'Beach Cleanup'
        OR 'Food Pantry Distribution';
-- Show all the prisoners that did not work the Beach Cleanup or Food Pantry Distribution Events (uses subquery)
SELECT distinct firstName, lastName
FROM persons
    JOIN prisoners p on persons.stateID = p.id
    JOIN prisonerEventDates pED on p.id = pED.id
WHERE event NOT IN (
    select *
FROM getBeachAndFoodEvents
);


CREATE VIEW getOrangeCounty
AS
    SELECT county
    FROM locations
    WHERE county LIKE 'Orange County';
-- Show all the events happening outside of LA county (not working?)
SELECT event
FROM locations
    JOIN eventDates eD on locations.address = eD.location
WHERE location NOT IN (
    SELECT *
FROM getOrangeCounty
);


-- list out the guard that worked the most times with a prisoner
select firstName, lastName, status, endDate
from prisoners inner join persons p on prisoners.id = p.stateID inner join prisonerAssignments pA on prisoners.id = pA.id;


-- gets events a guard and prisoner worked together
select p.firstName, p.lastName, p4.lastName, p4.firstName, gEd.event, pA.event, count(pa.event)
from prisoners inner join persons p on prisoners.id = p.stateID inner join prisonereventdates pA on prisoners.id = pA.id inner join eventdates e on pA.event = e.event inner join events e2 on e.event = e2.eventName
    inner join eventSkills eS on e2.eventName = eS.eventName inner join skills s on eS.skillName = s.skillName
    inner join locations l on e.location = l.address inner join guardEventDates gED on pA.location = gED.location
        and e.event = gED.event inner join guards g on gED.id = g.id inner join persons p4 on g.id=p4.stateID
GROUP BY p.firstName, p.lastName, p4.lastName, p4.firstName, gEd.event, pA.event;














