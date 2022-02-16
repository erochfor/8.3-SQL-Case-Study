/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 1 of the case study, which means that there'll be more guidance for you about how to 
setup your local SQLite connection in PART 2 of the case study. 

The questions in the case study are exactly the same as with Tier 2. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */

Select name
From Facilities
Where membercost >0


/* Q2: How many facilities do not charge a fee to members? */

Select name
From Facilities
Where membercost = 0

There are 4 facilities that do not charge a fee to the members.


/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

Select facid, name, membercost, monthlymaintenance 
From Facilities 
Where membercost > 0
And membercost > (monthlymaintenance * .2)


/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */

Select * 
From `Facilities` 
Where (FACID = 1 Or FACID = 5)


/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */

Select name, monthlymaintenance, 
Case When monthlymaintenance > 100 Then 'expensive'
     Else 'cheap' End As label
From Facilities


/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */

Select firstname, surname
From Members
Where joindate = (Select MAX(joindate) from Members)


/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

Select Members.firstname || ' ' || Members.surname As Name, Facilities.name as facility
From Members
Inner Join Bookings On Bookings.memid = Members.memid
Inner Join Facilities On Facilities.facid = Bookings.facid
Where Facilities.name In ('Tennis Court 1', 'Tennis Court 2')
Order by Name


/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

Select Facilities.name, Members.firstname || ' ' || Members.surname As member,
Case When Bookings.memid = 0
Then Facilities.guestcost * Bookings.slots
Else Facilities.membercost * Bookings.slots
End as Cost
From Bookings
Inner Join Facilities On Bookings.facid = Facilities.facid
And Bookings.starttime like '2012-09-14%'
And ((Bookings.memid = 0) And Facilities.guestcost * Bookings.slots > 30)
Or ((Bookings.memid != 0) And Facilities.membercost * Bookings.slots > 30)
Inner Join Members On Bookings.memid = Members.memid
Order By Cost desc;
        

/* Q9: This time, produce the same result as in Q8, but using a subquery. */

Select *
From (
Select Facilities.name, Members.firstname || ' ' || Members.surname As member,
Case When Bookings.memid = 0
Then Facilities.guestcost * Bookings.slots
Else Facilities.membercost * Bookings.slots
End as Cost
From Bookings
Inner Join Facilities On Bookings.facid = Facilities.facid
And Bookings.starttime like '2012-09-14%'
Inner Join Members On Bookings.memid = Members.memid
) sub
Where sub.cost > 30
Order by sub.cost desc;



/* PART 2: SQLite
/* We now want you to jump over to a local instance of the database on your machine. 

Copy and paste the LocalSQLConnection.py script into an empty Jupyter notebook, and run it. 

Make sure that the SQLFiles folder containing thes files is in your working directory, and
that you haven't changed the name of the .db file from 'sqlite\db\pythonsqlite'.

You should see the output from the initial query 'SELECT * FROM FACILITIES'.

Complete the remaining tasks in the Jupyter interface. If you struggle, feel free to go back
to the PHPMyAdmin interface as and when you need to. 

You'll need to paste your query into value of the 'query1' variable and run the code block again to get an output.
 
QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

Select Facilities.name,
SUM(Case When Bookings.memid = 0
Then Facilities.guestcost * Bookings.slots
Else Facilities.membercost * Bookings.slots
End) as Revenue
From Bookings
Inner Join Facilities on Bookings.facid = Facilities.facid
Group by Facilities.name
Having SUM(Case When Bookings.memid = 0
Then Facilities.guestcost * Bookings.slots
Else Facilities.membercost * Bookings.slots End) < 1000
Order by Revenue;

/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */

Select m.firstname || ' ' || m.surname as Recommended_by, 
reco.firstname || ' ' || reco.surname As Member 
From Members m 
Inner Join Members reco On reco.recommendedby = m.memid
Where m.memid > 0
order by m.firstname, m.surname, reco.firstname, reco.surname;


/* Q12: Find the facilities with their usage by member, but not guests */

Select f.name, m.firstname || ' ' || m.surname as Member, Count(f.name) As bookings
From Members m
Inner Join Bookings bks On bks.memid = m.memid
Inner Join Facilities f On bks.facid = f.facid
Where bks.memid > 0 
Group By f.name, m.firstname || ' ' || m.surname
Order By f.name, m.firstname, m.surname;


/* Q13: Find the facilities usage by month, but not guests */

Select extract(month From starttime) As Month, name,
Count(name) As 'usage'
From Bookings
Left Join Facilities On Bookings.facid = Facilities.facid
Where memid != 0
Group by month, name;


