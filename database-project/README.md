# CSCI 362 — Database Project

Design a relational database, implement it in PostgreSQL, and use SQL to answer meaningful questions.

| Project details | |
| --- | --- |
| **Course** | CSCI 362 — Databases and Data Mining |
| **Assignment** | Group project; 3–4 students per group, or as assigned |
| **Project options** | 10 topics; assigned by the instructor |
| **Platform** | Supabase (PostgreSQL) |
| **Total points** | 100 |
| **Submission** | One ZIP file per group through Brightspace |
| **Deadline** | As posted on Brightspace |

**Jump to:** [Project topics](#project-topics) · [Requirements](#project-requirements) · [Submission](#submission-requirements) · [Rubric](#grading-rubric) · [Collaboration and integrity](#group-collaboration-and-academic-integrity)

> [!IMPORTANT]
> Brightspace is the authority for project assignments, deadlines, submission directions, and schedule changes.

## Project Overview

Your group will design and implement a relational database for a realistic application. Each group will receive a different project topic, but all groups must meet the same technical requirements.

The objective is to demonstrate your understanding of database design, entity relationships, normalization, SQL implementation, and data retrieval.

You are **not required to build a website, mobile application, or graphical interface**. The focus is on the database itself.

## Project Topics

Use the topic assigned to your group. Complete both its specific requirements below and the shared requirements that follow. The same 100-point rubric applies to every project.

**How to use each project brief:** design your own tables, attributes, key choices, and ER diagram to meet its rules. The relationship descriptions are requirements, not a supplied schema or diagram to copy. Show minimum and maximum participation (such as zero-or-many or exactly-one) on both ends of every relationship.

**Queries and tests:** the two required query questions belong within your eight queries; use one as Query 8 and the other in a compatible Query 1–7 slot. Both must be answered, and every SQL technique in the shared query table must still appear. Additional queries are allowed. Each question may produce multiple result tables when needed. The two topic-specific integrity tests replace the generic examples in Part 4; they are not two extra tests.

**Enforcement scope:** implement keys, foreign keys, uniqueness, required values, and rules about values in the same row with database constraints where appropriate. For rules involving multiple rows, tables, or time intervals, use database enforcement if you know how, or provide an executable validation query and a documented workflow for detecting and correcting violations. Triggers and advanced locking are not required. Clearly distinguish an operation PostgreSQL rejects automatically from a violation your validation detects; validation alone does not prevent concurrent conflicting writes. Test failed attempts separately so they do not break the normal setup scripts.

| Project | Topic |
| --- | --- |
| **Project 1** | [Student Club Management System](#project-1-student-club-management-system) |
| **Project 2** | [Library Borrowing Management System](#project-2-library-borrowing-management-system) |
| **Project 3** | [Campus Equipment Checkout System](#project-3-campus-equipment-checkout-system) |
| **Project 4** | [Campus Tutoring Appointment System](#project-4-campus-tutoring-appointment-system) |
| **Project 5** | [Online Store Order Management System](#project-5-online-store-order-management-system) |
| **Project 6** | [Crime Incident Reporting System](#project-6-crime-incident-reporting-system) |
| **Project 7** | [Parking Permit Management System](#project-7-parking-permit-management-system) |
| **Project 8** | [Volunteer and Community Service Management System](#project-8-volunteer-and-community-service-management-system) |
| **Project 9** | [Campus Maintenance Request System](#project-9-campus-maintenance-request-system) |
| **Project 10** | [Animal Shelter Adoption Management System](#project-10-animal-shelter-adoption-management-system) |

### Project 1: Student Club Management System

Design a database that manages student organizations and their activities.

The system should track:

- Student members and their contact information.
- Clubs and membership records.
- Events organized by clubs.
- Student registrations or attendance at events.

**Sample questions:** Which club has the most members? Which students attended more than one event?

**Required relationships and ER diagram**
- Model students and clubs as many-to-many through membership records. Store the join date and role for each membership.
- Each event belongs to exactly one organizing club; a club may organize many events.
- Model students and events as many-to-many through registration records, including attendance status. A student may register for an event without joining its organizing club.
- Show membership and event registration as separate relationships. Include a student with no club membership and an event with no registrations in your examples.

**Business rules**
1. A student can have only one membership record per club and one registration per event. Membership renewal history is outside this project's scope.
2. Each event has a positive capacity. Cancelled registrations do not count toward capacity; document which other statuses count.
3. Only a student with a registration record can be marked as having attended that event.

**Required query questions**
- For each club, report its member count and event count without multiplying either count through joins; include clubs with zero events.
- Identify events with remaining registration capacity and report the number of available places.

**Required integrity tests**
- Attempt a duplicate student-club membership.
- Test an event at capacity and one additional registration; show how your chosen enforcement or validation identifies the excess.

---

### Project 2: Library Borrowing Management System

Design a database that tracks books and borrowing activity.

The system should track:

- Books and authors.
- Library members.
- Individual copies of books.
- Borrowing and return records.

**Sample questions:** Which books are currently borrowed? Which members have overdue books?

**Required relationships and ER diagram**
- Distinguish a book title or edition from a physical copy. One title may have many copies, each with a unique copy identifier.
- Model books and authors as many-to-many through a separate authorship relationship.
- Each loan connects exactly one member to one physical copy. Members and copies may each have many loans over time.
- Show that a copy can exist without any loan history. Include a book with multiple authors and multiple copies in your examples.

**Business rules**
1. A physical copy may have at most one unreturned loan at a time.
2. A due date must be later than the checkout date; a return date, when present, cannot precede checkout.
3. Overdue means unreturned and past its due date as of a clearly stated reference date. A title is not itself a borrowable copy.

**Required query questions**
- List overdue loans with member, title, physical copy, and days overdue, using a stated reference date.
- Report available physical-copy counts for every title, including titles with no available copies. Avoid counting authorship rows as extra copies.

**Required integrity tests**
- Attempt a second unreturned loan for the same physical copy.
- Attempt a loan with a due date before checkout.

---

### Project 3: Campus Equipment Checkout System

Design a database for managing equipment borrowed from a college laboratory.

The system should track:

- Equipment items and categories.
- Students borrowing equipment.
- Checkout and return dates.
- Equipment availability and condition.

**Sample questions:** Which equipment is currently checked out? Which equipment has been borrowed most frequently?

**Required relationships and ER diagram**
- Each physical equipment item belongs to one category and has a unique asset tag; a category can contain many items.
- A student may make many checkout transactions. Each transaction can contain multiple equipment items through checkout-detail records.
- An item may appear in many transactions over time. Record its outgoing and return condition and return time on the individual detail record.
- Show that items from one checkout can be returned separately. Include a transaction with at least two items and only one returned item.

**Business rules**
1. A physical item cannot be on two unreturned checkout-detail records at the same time.
2. An item's return time cannot precede its checkout time. A returned item must have a recorded return condition.
3. An item marked unavailable for maintenance cannot be newly checked out. Distinguish maintenance status from availability derived from active borrowing.

**Required query questions**
- List outstanding items with the borrower, transaction, due date, and outgoing condition, including partially returned transactions.
- Rank equipment categories by total item checkouts; count borrowed items rather than transaction headers.

**Required integrity tests**
- Attempt to check out an already outstanding physical item.
- Attempt to check out an item marked unavailable for maintenance.

---

### Project 4: Campus Tutoring Appointment System

Design a database for managing tutoring sessions.

The system should track:

- Students requesting tutoring.
- Tutors and subjects.
- Tutoring appointments.
- Session status and student feedback.

**Sample questions:** Which tutors conduct the most sessions? What is the average feedback rating for each tutor?

**Required relationships and ER diagram**
- Model tutors and subjects as many-to-many through tutor qualification records.
- Each appointment connects one student, one tutor, and one subject, with start and end times and a session status.
- Each appointment has zero or one feedback record; feedback belongs to exactly one appointment.
- Show optional feedback and the tutor-subject qualification relationship. Include a tutor qualified in multiple subjects and a completed appointment without feedback.

**Business rules**
1. The assigned tutor must be qualified in the appointment's subject.
2. End time must be after start time. Scheduled or completed appointments cannot overlap for the same tutor or student; cancelled appointments do not reserve time.
3. Feedback is allowed only for completed appointments, with a rating from 1 to 5 and at most one feedback record per appointment.

**Required query questions**
- Report each tutor's completed-session count, number of received ratings, and average rating; include tutors with no completed sessions and do not treat missing ratings as zero.
- Identify subjects whose completed-appointment count exceeds the average completed-appointment count across all subjects, including subjects with zero completions in the baseline.

**Required integrity tests**
- Attempt an appointment for a tutor who is not qualified in its subject.
- Attempt an appointment that overlaps an existing scheduled appointment for the same tutor.

---

### Project 5: Online Store Order Management System

Design a database for a small online store.

The system should track:

- Customers.
- Products and categories.
- Customer orders.
- Products included in each order.
- Order status.

**Sample questions:** Which products generate the most revenue? What is the total amount spent by each customer?

**Required relationships and ER diagram**
- Each customer can place many orders; each order belongs to one customer.
- Each product belongs to one category. Connect orders and products through order-line records that store quantity and the unit price charged at purchase.
- Show order lines as a relationship with its own attributes, distinct from the product's current catalog price.
- Include an order with multiple products, a product appearing in multiple orders, and a customer with no orders.

**Business rules**
1. Each order-product pair appears at most once; its quantity must be positive and its charged unit price nonnegative.
2. Updating a product's current price must not change the historical price charged on an existing order line.
3. Define permitted order statuses. For this project, only completed orders count toward revenue; taxes, shipping charges, refunds, and discounts are outside scope.

**Required query questions**
- Report completed-order revenue by product using quantities and historical charged prices; include products with zero revenue.
- Identify customers whose completed-order spending exceeds the average spending across all customers, counting customers with no completed orders as zero.

**Required integrity tests**
- Attempt an order line with quantity zero.
- Change a catalog price and verify that an existing completed order's calculated total stays unchanged.

---

### Project 6: Crime Incident Reporting System

Design a simplified database for recording and reviewing incident reports.

The system should track:

- Incident reports and their categories.
- Incident locations.
- Reporting dates.
- Officers or staff assigned to incidents.
- Investigation status.

**Sample questions:** Which incident categories occur most frequently? How many incidents remain unresolved?

Use **fictional or synthetic records only**. Do not include real victims, confidential information, or actual law-enforcement records.

**Required relationships and ER diagram**
- Each incident has one primary category and one location; categories and locations can each be associated with many incidents.
- Model incidents and assigned staff as many-to-many through assignment records with assignment date and role.
- Record status changes in a separate incident-status history, with the status and change time for each entry.
- Show that an incident may initially have no assigned staff. Include an incident with multiple staff and multiple status-history entries.

**Business rules**
1. Each incident-staff pair can have at most one assignment record. Reassignment history is outside scope.
2. Status-history timestamps cannot precede the reporting timestamp. Define a deterministic order if two status entries have the same timestamp.
3. Determine the current status from the latest status-history entry. Clearly define which statuses count as unresolved and include an initial status for each incident.

**Required query questions**
- Count unresolved incidents by primary category using each incident's latest status, including categories with zero unresolved incidents.
- Report unresolved assigned incidents per staff member, including staff with none. Explain why summing staff workloads can exceed the number of distinct incidents.

**Required integrity tests**
- Attempt a duplicate incident-staff assignment.
- Attempt a status-history entry dated before the incident was reported.

---

### Project 7: Parking Permit Management System

Design a database for managing campus parking permits.

The system should track:

- Registered drivers.
- Vehicles.
- Parking permits and permit types.
- Parking areas.
- Permit expiration dates.

**Sample questions:** Which permits have expired? How many active permits exist for each parking area?

**Required relationships and ER diagram**
- Each vehicle belongs to one registered driver for this project's scope; a driver may register multiple vehicles.
- Each permit is issued to one vehicle and has one permit type and a validity period. Preserve expired permits as history.
- Model permit types and parking areas as many-to-many through an area-authorization relationship.
- Show that a permit's permitted areas depend on its type rather than a single area stored on the vehicle. Include a type authorized for multiple areas.

**Business rules**
1. Permit numbers and vehicle registration identifiers must be unique. State how you distinguish registrations issued by different jurisdictions.
2. A permit's expiration date cannot precede its start date. For this project, validity includes both endpoint dates.
3. A vehicle cannot hold permits with overlapping validity periods. Expired and future permits can remain in the database.

**Required query questions**
- Using a stated reference date, count valid permits authorized for each parking area, including areas with none. Explain why area counts may sum to more than the number of distinct valid permits.
- Find registered vehicles with no valid permit as of that date, including vehicles that have never had a permit.

**Required integrity tests**
- Attempt a permit with an expiration date before its start date.
- Attempt a second permit whose validity overlaps an existing permit for the same vehicle.

---

### Project 8: Volunteer and Community Service Management System

Design a database for organizing volunteers and community service activities.

The system should track:

- Volunteers and their contact information.
- Partner organizations.
- Service opportunities hosted by organizations.
- Volunteer signups for service opportunities.
- Attendance and completed service hours for each signup.

**Sample questions:** Which opportunities still have open volunteer spots? How many service hours has each volunteer completed?

**Required relationships and ER diagram**
- Each service opportunity belongs to one partner organization; an organization may host many opportunities.
- Model volunteers and opportunities as many-to-many through signup records.
- Record attendance and approved completed hours for each signup. Choose either attributes on the signup or a separate optional completion record, and justify the choice.
- Show that signing up does not guarantee attendance. Include a cancelled signup, a no-show, and an opportunity with no signups.

**Business rules**
1. Each volunteer-opportunity pair has at most one signup record, including cancelled signups.
2. Opportunity capacity must be positive. Define which signup statuses reserve a place; cancelled signups do not reserve places.
3. Approved completed hours must be nonnegative and cannot be positive for a cancelled signup or no-show. Capacity cannot be exceeded by place-reserving signups.

**Required query questions**
- List upcoming opportunities with remaining places as of a stated reference time, including opportunities with no signups.
- Report approved service hours per volunteer and per partner organization; include volunteers with zero hours and exclude cancelled signups and no-shows from completed service.

**Required integrity tests**
- Test a full opportunity and one additional place-reserving signup.
- Attempt to record positive approved hours for a no-show.

---

### Project 9: Campus Maintenance Request System

Design a database for tracking campus maintenance requests and assigned work.

The system should track:

- Campus buildings and rooms.
- People submitting maintenance requests.
- Requests, categories, priorities, and reporting dates.
- Maintenance staff and work assignments.
- Request status and completion dates.

**Sample questions:** Which buildings have the most unresolved requests? What is the average completion time for each request category?

**Required relationships and ER diagram**
- Each room belongs to one building; room numbers are unique within a building, but may repeat across buildings.
- Each maintenance request has one requester, one room, one category, a priority, and a reporting timestamp.
- Model staff and requests as many-to-many through work assignments, with assigned time and hours worked for each assignment.
- Show that a request can exist before staff are assigned. Include a request with multiple assigned staff and rooms with the same room number in different buildings.

**Business rules**
1. Prevent duplicate room numbers within the same building.
2. Hours worked cannot be negative, and assignment timestamps cannot precede the request's reporting timestamp.
3. A completed request must have a completion timestamp no earlier than reporting; an open request must not have a completion timestamp. Define allowed statuses and how they map to open or completed.

**Required query questions**
- Report unresolved request counts by building, including buildings with none, without double-counting requests assigned to multiple staff.
- Calculate average completion time per request category using completed requests only, and report the number of completed requests contributing to each average.

**Required integrity tests**
- Attempt a duplicate room number in the same building; also demonstrate that the same number in another building is allowed.
- Attempt to mark a request completed without a completion timestamp.

---

### Project 10: Animal Shelter Adoption Management System

Design a database for managing shelter animals and adoption applications.

The system should track:

- Animals and their intake dates and adoption availability.
- Animal species or categories.
- Prospective adopters.
- Adoption applications and application status.
- Completed adoptions and their dates.

**Sample questions:** Which animals are currently available for adoption? What is the average time from intake to adoption for each animal category?

**Required relationships and ER diagram**
- Each animal belongs to one species or category; a category can contain many animals.
- Model adopters and animals as many-to-many through adoption applications, each with a submission date and status.
- Each completed adoption must reference exactly one application; an application has zero or one completed adoption. Preserve unsuccessful applications.
- Show that an animal may have multiple applicants but, for this project's scope, only one completed adoption. Include an animal with multiple applications and one with none.

**Business rules**
1. Each adopter-animal pair has at most one application. Repeat applications, returns, and re-adoptions are outside scope.
2. A completed adoption must reference an approved application for that same animal and adopter. Prevent multiple completed adoptions for one animal.
3. An application cannot predate the animal's intake, and adoption cannot predate its application. Determine adoption availability consistently from the animal's eligibility and completed adoption records.

**Required query questions**
- List eligible animals with no completed adoption, including animals with no applications, and show each animal's pending-application count.
- Report average time from intake to completed adoption by species or category, with the number of adopted animals contributing to each average. Keep never-adopted animals out of that average.

**Required integrity tests**
- Attempt to complete an adoption from a pending or rejected application.
- Attempt a second completed adoption for the same animal using another application.

---

## Project Requirements

Every group must complete the following requirements, regardless of its assigned topic.

### Part 1: Database Design

1. Identify at least **4 related tables**, adding all tables needed for your assigned project’s required relationships. Four is a minimum, not a target or maximum.
2. Create your own Entity-Relationship (ER) diagram showing entities, attributes, primary keys, foreign keys, junction tables, and relationships. Label cardinality and optional or mandatory participation on both ends of every relationship. The diagram must match your implemented schema and your assigned project’s requirements.
3. Design the database to satisfy **Third Normal Form (3NF)**, or explain any justified exceptions.
4. Provide a brief explanation of the database structure and important design decisions. Map each required relationship and business rule to its table, constraint, or validation approach; explain any assumptions.

### Part 2: Database Implementation

Using Supabase PostgreSQL:

1. Create all required tables using SQL `CREATE TABLE` statements.
2. Define appropriate primary keys and foreign keys.
3. Use suitable data types and integrity constraints, including `NOT NULL`, `UNIQUE`, or `CHECK` where appropriate.
4. Insert at least **10 sample records per table** using realistic synthetic data.
5. Demonstrate that the tables are properly connected through foreign keys. Include the scenarios requested in your topic brief and enough varied data to exercise both required query questions and both integrity tests.

### Part 3: SQL Queries

Write and execute at least **8 SQL queries** demonstrating the following:

| Query | Requirement |
| --- | --- |
| 1 | Basic `SELECT` with `WHERE` |
| 2 | Sorting using `ORDER BY` |
| 3 | `INNER JOIN` involving at least two tables |
| 4 | `LEFT JOIN` involving at least two tables |
| 5 | Aggregate function such as `COUNT`, `SUM`, or `AVG` |
| 6 | `GROUP BY` with `HAVING` |
| 7 | Subquery |
| 8 | Analytical query answering a meaningful question about your project |

Each query must include a short SQL comment describing its purpose.

All queries must execute successfully and return meaningful results using your sample data.

### Part 4: Testing and Documentation

1. Demonstrate at least **two integrity checks** using the two required tests in your assigned project brief. For each, show the starting state, attempted change, expected outcome, and actual outcome. Include the test SQL and any validation SQL in the report; keep deliberately invalid test data out of `insert_data.sql`.
2. Explain why PostgreSQL accepts or rejects each attempted operation. If a cross-table or cross-row rule is checked through a validation query, show that it flags the violation and document the correction or rollback; do not describe it as an automatic database rejection.
3. Include screenshots showing the created tables and sample query results.
4. Write a brief project summary describing what your database can do and one limitation or possible future improvement.

---

## Submission Requirements

Each group must submit one ZIP file containing:

| Required file | Contents |
| --- | --- |
| `ER_Diagram.pdf` | Database relationship diagram |
| `create_tables.sql` | Table definitions and constraints |
| `insert_data.sql` | Sample data |
| `queries.sql` | All eight required queries with comments |
| `Project_Report.pdf` | A short report (2–3 pages) describing the design, normalization decisions, integrity tests, query results, and group contributions |

**Important:** SQL files must run in PostgreSQL. Screenshots do not replace executable SQL.

## Grading Rubric

The following rubric applies equally to all groups across the ten project topics.

| Criteria | Points |
| --- | ---: |
| ER diagram, relationships, and key identification | 20 |
| Relational design and normalization | 15 |
| SQL table creation, data types, and constraints | 15 |
| Sample data and successful implementation | 10 |
| Eight SQL queries (5 points each) | 40 |
| **Total** | **100** |

**Topic-specific relationships, business rules, query questions, documentation, and integrity checks** will be evaluated within the corresponding rubric criteria; there are no additional points beyond 100. Documentation and integrity checks will be considered within the relevant design and implementation criteria. Missing required submission files may prevent the corresponding work from being evaluated.

## Group Collaboration and Academic Integrity

Each group member is expected to make a meaningful contribution to database design, SQL implementation, testing, or documentation.

Include a brief contribution statement identifying the responsibilities of each group member. Submit an independently developed design, diagram, SQL, and report for your assigned topic. Renaming another group’s tables or reusing its diagram does not meet this requirement. You may use course examples as references, but explain how your design meets your own topic’s relationships and rules.

AI tools may be used for learning, troubleshooting, and understanding SQL concepts. Any AI assistance must be disclosed according to the course policy. All group members must understand and be able to explain the submitted work.

The instructor may ask any group member to explain an ER relationship, SQL query, or implementation decision.

**Final Reminder:** A successful project is a properly designed, working relational database. Focus on correctness, meaningful relationships, data integrity, and SQL functionality rather than unnecessary application features.
