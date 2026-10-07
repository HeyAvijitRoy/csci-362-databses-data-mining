# CSCI 362 — Lesson 6A SQL Live Lab

## Joining Related Tables

**PostgreSQL + Supabase**

**Released after class for review and practice.**

### Class pattern

**Predict → Run → Inspect → Explain → Modify**

For joins, add one more question before you run anything:

> **What should one result row represent?**

Keep the [Module 6 SQL Quick Reference](Module-6-SQL-Quick-Reference.md) open beside the SQL Editor.

---

# Before we begin

Module 6 continues with the same database from [Module 5](../Module%205%20-%20SQL%20Labs/README.md):

```text
public.clubs
public.events
```

Run the existing:

[Module 5 Reset and Seed](../Module%205%20-%20SQL%20Labs/Module-5-Reset-and-Seed.sql)

**once** before beginning this lesson so everyone starts from:

```text
6 clubs
24 events
```

Then run [Module 6 Database Verification](Module-6-Database-Verification.sql).

The reset intentionally removes the changes you made during Lesson 5B. This gives the entire class the same data for prediction and comparison.

---

# 1 — The problem that Module 5 left us with

At the end of [Lesson 5B](../Module%205%20-%20SQL%20Labs/Module-5B-SQL-Live-Lab.md), we could ask questions such as:

```sql
SELECT
    title,
    club_id
FROM public.events
ORDER BY event_id;
```

The query works, but `club_id = 4` is not what a person normally wants to read.

A user wants something closer to:

```text
Cybersecurity Club | Capture the Flag
Data Club          | SQL Starter Lab
Robotics Club      | Robot Demo
```

The information already exists. It is simply stored in two different relations.

`events` knows **which club ID** owns an event.

`clubs` knows **which club name** belongs to that ID.

This is exactly what normalization was supposed to do: store one fact in the place where it belongs instead of repeating the club name in every event row.

Now we need a way to reconstruct the information when we query it.

That is the job of a **join**.

---

# 2 — First analogy: two contact lists and one shared identifier

Imagine that one sheet contains:

```text
student_id | student_name
```

and another sheet contains:

```text
student_id | parking_space
```

If both sheets contain `student_id`, we can match rows that refer to the same student.

The database does the same thing with:

```text
clubs.club_id
```

and:

```text
events.club_id
```

The shared value is not there just for decoration. It is the **matching rule**.

In our schema:

```text
CLUBS
club_id  PRIMARY KEY
   ↑
   │
   │  EVENTS.club_id is a FOREIGN KEY
   │
EVENTS
```

A foreign key gives us a relationship we can later follow in a query.

---

# 3 — Inspect both tables before joining them

First look at a few club rows:

```sql
SELECT
    club_id,
    club_name
FROM public.clubs
ORDER BY club_id;
```

Now look at a few event rows:

```sql
SELECT
    event_id,
    club_id,
    title
FROM public.events
ORDER BY event_id;
```

### Predict before moving on

Find:

- the `club_id` for Data Club;
- the `club_id` stored in the `SQL Starter Lab` event;
- the `club_id` for Robotics Club;
- the `club_id` stored in `Robot Demo`.

You should notice that the numeric values connect the rows.

---

# 4 — Your first INNER JOIN

Run:

```sql
SELECT
    e.event_id,
    e.title,
    c.club_name
FROM public.events AS e
INNER JOIN public.clubs AS c
    ON e.club_id = c.club_id
ORDER BY e.event_id;
```

Expected result count:

```text
24 rows
```

## Read the query in English

```sql
FROM public.events AS e
```

means:

> Start from the events table and call it `e` inside this query.

```sql
INNER JOIN public.clubs AS c
```

means:

> Combine each event with a matching row from clubs, and call clubs `c`.

```sql
ON e.club_id = c.club_id
```

means:

> A row matches when the event's club ID equals the club's club ID.

The `ON` clause is therefore not random syntax.

It describes the relationship being used to match rows.

---

# 5 — Why do we use aliases?

Without aliases, the previous query could be written as:

```sql
SELECT
    public.events.event_id,
    public.events.title,
    public.clubs.club_name
FROM public.events
INNER JOIN public.clubs
    ON public.events.club_id = public.clubs.club_id;
```

It works, but it becomes difficult to read quickly.

Aliases create short names:

```text
e = events
c = clubs
```

Then we can write:

```sql
e.title
c.club_name
```

instead of repeatedly writing complete table names.

### Important

The alias exists only while the query runs.

It does **not** rename the real table.

---

# 6 — Why did the INNER JOIN return 24 rows?

Before running another query, think about this.

We have:

```text
24 event rows
6 club rows
```

Yet the result contains:

```text
24 rows
```

Why not 6?

Why not 30?

Because the result contains one row for each **matching row combination**.

One club can match many events.

For example, Data Club appears only once in `clubs`, but several event rows contain:

```text
club_id = 1
```

Therefore the Data Club row participates in several result rows.

## Important mental model

> **JOIN does not mean “merge two tables into one row each.”**
>
> It creates a result row for each pair of rows that satisfies the matching condition.

---

# 7 — Trace one relationship manually

Run:

```sql
SELECT
    e.event_id,
    e.title,
    e.club_id
FROM public.events AS e
WHERE e.club_id = 1
ORDER BY e.event_id;
```

You should see **7 Data Club events** in the reset dataset.

Now inspect the club row:

```sql
SELECT
    club_id,
    club_name
FROM public.clubs
WHERE club_id = 1;
```

There is only one matching club row.

When we join them, that one club row is matched to each of its seven event rows.

This is why the readable club name appears seven times in the query result without being stored seven times in `clubs`.

That is a useful consequence of normalization.

---

# 8 — INNER JOIN is the “matched rows only” join

Think of an `INNER JOIN` as a guest list.

Two pieces of information must agree before a row enters the result.

In our query:

```sql
ON e.club_id = c.club_id
```

an event enters the result only if a club with the same `club_id` can be found.

## Venn-diagram memory aid

You may see `INNER JOIN` drawn as the overlapping center of two circles.

That is useful for remembering:

> Keep only matches.

But do not take the Venn diagram too literally.

A Venn diagram does **not** show row multiplication. One club can match seven event rows, so one row on the club side can produce many joined rows.

Use the diagram as an inclusion/exclusion memory aid, not as a complete execution model.

---

# 9 — What happens if every row already has a match?

Our schema has a foreign key:

```sql
events.club_id REFERENCES clubs(club_id)
```

That prevents an event from containing a `club_id` that points to no club.

Also, the reset dataset gives every one of the six clubs at least one event.

Therefore this query:

```sql
SELECT
    c.club_name,
    e.title
FROM public.clubs AS c
INNER JOIN public.events AS e
    ON e.club_id = c.club_id
ORDER BY c.club_name, e.event_date;
```

returns the same 24 matched event/club combinations we expect.

A simple outer join on the same relationship can initially look very similar because our starting data has matches everywhere.

That is not a SQL problem.

It means the data currently contains no unmatched rows for that particular relationship.

---

# 10 — LEFT JOIN: preserve the left side

A `LEFT JOIN` says:

> Keep every row from the table on the left. Attach matching rows from the right when they exist. If no right-side row matches, keep the left row anyway and fill the right-side columns with `NULL`.

A useful analogy is a class roster and assignment submissions.

If the roster is on the left:

```text
ROSTER LEFT JOIN SUBMISSIONS
```

then every enrolled student remains visible even if somebody submitted nothing.

The missing submission columns become `NULL`.

---

# 11 — Make LEFT JOIN behavior visible without changing our database

Every club has at least one event, so this query alone will not show an unmatched club:

```sql
SELECT
    c.club_name,
    e.title
FROM public.clubs AS c
LEFT JOIN public.events AS e
    ON e.club_id = c.club_id;
```

Instead, ask a more specific question:

> Show every club, and attach its Workshop events when it has any.

Run:

```sql
SELECT
    c.club_name,
    e.title AS workshop_title
FROM public.clubs AS c
LEFT JOIN public.events AS e
    ON e.club_id = c.club_id
   AND e.category = 'Workshop'
ORDER BY c.club_name, e.event_date;
```

### Predict before running

Which club has no Workshop in the reset dataset?

Expected observation:

```text
Debate Society | NULL
```

Every club remains because `clubs` is on the left.

The event side is allowed to be missing.

Expected result count:

```text
9 rows
```

There are 8 Workshop events, plus one preserved Debate Society row with no matching Workshop.

---

# 12 — Why did the filter go inside ON?

Look carefully at this part:

```sql
ON e.club_id = c.club_id
AND e.category = 'Workshop'
```

The question is:

> For each club, find a matching event that belongs to that club **and** is a Workshop.

If no such event exists, the `LEFT JOIN` still preserves the club.

Now compare it with this query:

```sql
SELECT
    c.club_name,
    e.title AS workshop_title
FROM public.clubs AS c
LEFT JOIN public.events AS e
    ON e.club_id = c.club_id
WHERE e.category = 'Workshop'
ORDER BY c.club_name, e.event_date;
```

Expected result count:

```text
8 rows
```

`Debate Society` disappears.

Why?

The `LEFT JOIN` initially preserved it, but its event columns were `NULL`.

Then the `WHERE` clause asked:

```sql
e.category = 'Workshop'
```

A missing event does not satisfy that condition, so the row is filtered out afterward.

## Important distinction

> `ON` decides how rows match during the join.
>
> `WHERE` filters the joined result afterward.

This difference becomes extremely important with outer joins.

---

# 13 — Find what is missing with LEFT JOIN + IS NULL

A common database question is not:

> What exists?

but:

> What is missing?

For example:

> Which clubs have no Workshop event?

Run:

```sql
SELECT
    c.club_id,
    c.club_name
FROM public.clubs AS c
LEFT JOIN public.events AS e
    ON e.club_id = c.club_id
   AND e.category = 'Workshop'
WHERE e.event_id IS NULL
ORDER BY c.club_id;
```

Expected result:

```text
Debate Society
```

This pattern is extremely useful:

```text
LEFT JOIN
+
WHERE right_side_key IS NULL
=
find left-side rows with no match
```

---

# 14 — INNER JOIN versus LEFT JOIN: choose based on the question

Do not memorize join types as isolated definitions.

Ask:

> Which rows must survive even when there is no match?

If the answer is:

> Only matched events and clubs matter.

then an `INNER JOIN` is appropriate.

If the answer is:

> Every club must appear, even if it has no matching event.

then put `clubs` on the left and use a `LEFT JOIN`.

The join operator follows the information requirement.

---

# 15 — RIGHT JOIN

`RIGHT JOIN` preserves the table on the right.

For example:

```sql
SELECT
    c.club_name,
    e.title
FROM public.events AS e
RIGHT JOIN public.clubs AS c
    ON e.club_id = c.club_id;
```

This preserves every club because `clubs` is on the right.

In practice, many developers prefer rewriting the query as a `LEFT JOIN` by reversing the table order:

```sql
SELECT
    c.club_name,
    e.title
FROM public.clubs AS c
LEFT JOIN public.events AS e
    ON e.club_id = c.club_id;
```

The second form is often easier to reason about because you can read:

> Keep the left table.

You should recognize `RIGHT JOIN`, but you do not need to make it your default style.

---

# 16 — FULL OUTER JOIN

A `FULL OUTER JOIN` preserves unmatched rows from both sides.

Conceptually:

```text
matched left/right rows
+
unmatched left rows
+
unmatched right rows
```

In our normal `clubs` / `events` relationship, referential integrity prevents orphan event rows, and every seeded club has an event.

Therefore a normal full join on:

```sql
e.club_id = c.club_id
```

has no unmatched rows to reveal in the reset dataset.

That is useful evidence that **join behavior depends on both the operator and the data**.

## First, run the full join on our complete tables

```sql
SELECT
    c.club_id AS club_table_id,
    c.club_name,
    e.club_id AS event_club_id,
    e.title
FROM public.clubs AS c
FULL OUTER JOIN public.events AS e
    ON c.club_id = e.club_id
ORDER BY c.club_id, e.event_id;
```

Expected result count: **24 rows**.

Every event has a matching club, and every club has at least one event. The result therefore contains the same matched pairs as the inner join.

## Make both unmatched sides visible

To see what a full join adds, use two small selections from our existing tables:

- Left input: Data Club and Robotics Club (`club_id` 1 and 2).
- Right input: Robot Demo and Open Studio (`event_id` 2 and 4).

The parenthesized `SELECT` statements below are **subqueries**: each supplies a smaller input to this join. Their aliases are still `c` and `e`. They do not change the stored tables.

### Predict before running

Which event matches a club in the left input? Which club has no event in the right input? Which event has no club in the left input?

Run:

```sql
SELECT
    c.club_id AS club_table_id,
    c.club_name,
    e.club_id AS event_club_id,
    e.title
FROM (
    SELECT club_id, club_name
    FROM public.clubs
    WHERE club_id IN (1, 2)
) AS c
FULL OUTER JOIN (
    SELECT event_id, club_id, title
    FROM public.events
    WHERE event_id IN (2, 4)
) AS e
    ON c.club_id = e.club_id
ORDER BY c.club_id NULLS LAST, e.event_id;
```

Expected result:

```text
club_table_id | club_name     | event_club_id | title
1             | Data Club     | NULL          | NULL
2             | Robotics Club | 2             | Robot Demo
NULL          | NULL          | 3             | Open Studio
```

Expected result count: **3 rows**.

Read each row:

- Data Club survives as an unmatched left row; the event columns become `NULL`.
- Robotics Club matches Robot Demo; both sides supply values.
- Open Studio survives as an unmatched right row; the club columns become `NULL`.

Open Studio is **not an orphan event in the database**. Arts Collective exists in `public.clubs`, but it was excluded from this query's left input. Here, “unmatched” means no match in the inputs supplied to the join.

### Modify and compare

Keep both inputs and the `ON` condition unchanged. Replace only `FULL OUTER JOIN` with each of these operators:

| Join type | Expected rows | What survives |
|---|---:|---|
| `INNER JOIN` | 1 | Robotics Club / Robot Demo |
| `LEFT JOIN` | 2 | The match and unmatched Data Club |
| `RIGHT JOIN` | 2 | The match and unmatched Open Studio |
| `FULL OUTER JOIN` | 3 | The match and both unmatched rows |

Explain which row disappears each time.

Use the [Interactive JOIN Explorer](https://avijitroy.com/docs/sql-join-explorer.html) to compare the inclusion rules visually.

---

# 17 — CROSS JOIN

A `CROSS JOIN` does not use a normal matching condition.

It pairs **every row on one side with every row on the other side**.

If we cross joined:

```text
6 clubs
```

with:

```text
24 events
```

we would produce:

```text
6 × 24 = 144 rows
```

That is called a Cartesian product.

We usually do **not** want that when matching events to their actual clubs.

A missing or incorrect join condition can therefore produce far more rows than expected.

Do not run a large cross join just to “see what happens” in production systems.

## Run an explicit CROSS JOIN

For this small reset dataset, run:

```sql
SELECT
    c.club_id AS candidate_club_id,
    c.club_name AS candidate_club_name,
    e.event_id,
    e.title,
    e.club_id AS actual_event_club_id
FROM public.clubs AS c
CROSS JOIN public.events AS e
ORDER BY c.club_id, e.event_id;
```

Expected result count: **144 rows**.

One result row represents a **candidate club/event pair**, whether or not that club actually owns the event. Notice that `CROSS JOIN` has no `ON` clause.

Each club appears with all 24 events. Each event appears with all 6 clubs.

For example, `Robot Demo` appears beside Data Club, Robotics Club, and the other four clubs. Only the Robotics Club pairing has:

```text
candidate_club_id = actual_event_club_id
```

The other pairs are part of the Cartesian product; they do not describe actual ownership.

### Modify and compare

Add this condition before `ORDER BY`:

```sql
WHERE c.club_id = e.club_id
```

Predict the new count, then run it.

Expected result count: **24 rows**.

The `WHERE` clause keeps only pairs whose IDs match. For this equality condition, the result is equivalent to our earlier `INNER JOIN ... ON c.club_id = e.club_id`.

Use the explicit inner join when the question is about actual ownership. Use a cross join when the question requires every possible combination, such as every club paired with every proposed meeting time.

---

# 18 — Ambiguous column names

Both tables contain:

```text
club_id
```

If we write a joined query and then simply request:

```sql
SELECT club_id
```

PostgreSQL may not know which table's `club_id` we mean.

Use the table alias:

```sql
SELECT
    e.club_id,
    c.club_id
```

Even when the values are expected to match, explicit qualification makes the query easier to read and prevents ambiguity.

---

# 19 — Add filtering after a normal INNER JOIN

Now answer a useful question:

> Which open events belong to the Cybersecurity Club?

Run:

```sql
SELECT
    e.event_id,
    e.title,
    e.event_date,
    c.club_name
FROM public.events AS e
INNER JOIN public.clubs AS c
    ON e.club_id = c.club_id
WHERE c.club_name = 'Cybersecurity Club'
  AND e.is_open = true
ORDER BY e.event_date;
```

Expected result count:

```text
3 rows
```

Notice the sequence of ideas:

```text
FROM/JOIN → connect the related rows
WHERE     → keep only the rows that answer the question
ORDER BY  → control presentation order
```

---

# 20 — Filter using information from either table

Once tables are joined, a query can use columns from either source.

Example:

> Show paid events from clubs founded in or after 2019.

```sql
SELECT
    c.club_name,
    c.founded_year,
    e.title,
    e.fee
FROM public.events AS e
INNER JOIN public.clubs AS c
    ON e.club_id = c.club_id
WHERE e.fee > 0
  AND c.founded_year >= 2019
ORDER BY e.fee DESC, e.title;
```

The filter combines:

```text
e.fee          → EVENTS
c.founded_year → CLUBS
```

That is one major reason joins are powerful: one information question can depend on facts stored in different relations.

---

# 21 — Your turn: predict before you write

For each task:

1. Say what one result row should represent.
2. Decide which table or tables contain the required information.
3. Identify the relationship.
4. Decide whether unmatched rows must survive.
5. Write the SQL.
6. Predict the approximate result before pressing Run.

## Task A — Event directory

Return:

```text
club_name | title | event_date
```

for every event.

Sort first by club name, then by event date.

---

## Task B — Free events with readable club names

Return:

```text
club_name | title | fee
```

for events with:

```text
fee = 0
```

Sort by club name and title.

---

## Task C — Photography Club events

Return all Photography Club event titles and dates without manually writing:

```text
club_id = 6
```

Use the club name in the condition.

---

## Task D — Every club and its Seminar events

Show every club, even if that club has no Seminar.

Return:

```text
club_name | seminar_title
```

Hint: this requires preserving the club side.

---

## Task E — Clubs with no Seminar

Starting from Task D, return only the clubs that do not have any Seminar event.

Do not hard-code club names.

---

# 22 — Debugging joins

When a join result looks wrong, do not randomly change syntax.

Ask these questions in order:

### 1. What does one result row represent?

If you cannot answer this, the query is not yet clear.

### 2. Which rows are supposed to match?

Check the `ON` clause.

### 3. Is the match one-to-one or one-to-many?

A one-to-many relationship can legitimately repeat one side.

### 4. Which side must survive unmatched?

That determines whether an outer join is required and which table belongs on the preserved side.

### 5. Did a `WHERE` condition accidentally remove the `NULL` rows created by a `LEFT JOIN`?

Move a right-table restriction into `ON` when the requirement is “preserve the left row, but only match this kind of right row.”

### 6. Did you forget the relationship entirely?

A missing matching condition can create a Cartesian product.

---

# 23 — Checkpoint: explain these without running them

## Question 1

Why is this correct?

```sql
ON e.club_id = c.club_id
```

### Expected reasoning

`events.club_id` is the foreign key identifying which club owns the event, and `clubs.club_id` is the club's primary key.

---

## Question 2

Why can Data Club appear many times in a joined result even though it appears once in `clubs`?

### Expected reasoning

Several event rows reference the same Data Club row. A join produces one result row for each matching combination.

---

## Question 3

What is the difference between:

```sql
LEFT JOIN public.events AS e
    ON e.club_id = c.club_id
   AND e.category = 'Workshop'
```

and:

```sql
LEFT JOIN public.events AS e
    ON e.club_id = c.club_id
WHERE e.category = 'Workshop'
```

### Expected reasoning

The first limits which event rows may match while still preserving every club. The second filters the result after the join and removes clubs whose event columns are `NULL`.

---

# 24 — End-of-class challenge

Write one query answering:

> Show every club founded in or after 2019 and any Competition events it has. Clubs meeting the founding-year rule must still appear even if they have no Competition.

Return:

```text
club_name
founded_year
competition_title
```

Sort by club name.

Before running it, identify:

- the preserved table;
- the join type;
- which condition belongs in `ON`;
- which condition belongs in `WHERE`.

---

# What Lesson 6A should leave you able to do

You should now be able to explain:

```text
Why JOIN exists
How PK/FK values create the match
INNER JOIN = matched rows only
LEFT JOIN = preserve the left side
RIGHT JOIN = preserve the right side
FULL OUTER JOIN = preserve unmatched rows from both sides
CROSS JOIN = every possible pair of input rows
ON = matching logic
WHERE = filtering after matching
IS NULL = useful for finding missing relationships
One-to-many joins can repeat rows
```

Most importantly, do not begin a join by asking:

> Which JOIN keyword do I remember?

Begin with:

> What information do I need, where is it stored, and which rows must survive?

---

# Coming next — Lesson 6B

A join can produce useful detail rows, but analysts often need summaries:

```text
How many events does each club have?
What is the average capacity by club?
Which clubs have at least four events?
Which events have above-average capacity?
```

Those questions introduce:

```text
COUNT
SUM
AVG
MIN
MAX
GROUP BY
HAVING
subqueries
```

That is the next step.
