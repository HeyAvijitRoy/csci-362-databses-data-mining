# CSCI 362 — Module 6: SQL for Multi-Table and Analytical Queries

**PostgreSQL + Supabase**  
**Database used:** the same `public.clubs` / `public.events` database from Module 5

Module 6 continues directly from Module 5. We are **not switching to a new database**.

In [Module 5](../Module%205%20-%20SQL%20Labs/README.md), you learned to create, inspect, filter, insert, update, and delete rows. The last problem in [Lesson 5B](../Module%205%20-%20SQL%20Labs/Module-5B-SQL-Live-Lab.md) exposed the next limitation: an event stores `club_id`, but the readable club name lives in another table.

Module 6 answers that problem with `JOIN`, then moves from row-level retrieval into analytical SQL with aggregate functions, `GROUP BY`, `HAVING`, and subqueries.

## Main idea

> **Normalization separates facts into related tables. JOIN reconstructs the information we need. GROUP BY summarizes it. Subqueries let one SQL question feed another.**

## Starting database

To review the earlier queries, open [Lesson 5A](../Module%205%20-%20SQL%20Labs/Module-5A-SQL-Live-Lab.md) or [Lesson 5B](../Module%205%20-%20SQL%20Labs/Module-5B-SQL-Live-Lab.md) in the Module 5 folder.

Use the exact existing reset file:

- [Module 5 Reset and Seed](../Module%205%20-%20SQL%20Labs/Module-5-Reset-and-Seed.sql)

At the start of Module 6, run the reset once when instructed so you begin from the expected state:

```text
public.clubs  = 6 rows
public.events = 24 rows
```

The reset removes the changes you made during Lesson 5B. Starting from this shared dataset lets you compare your predictions and query results with the expected results.

## Lesson availability

Lessons 6A and 6B are released after their respective class sessions for review and practice. They are not posted before class. Follow Brightspace for weekly instructions and release announcements.

## Learning sequence

### Class 1 — Lesson 6A: Joining Related Tables

Use:

1. [Interactive JOIN Explorer](https://avijitroy.com/docs/sql-join-explorer.html)
2. [Lesson 6A — Joins Live Lab](Module-6A-Joins-Live-Lab.md) - review after class
3. [Module 6 Starter SQL](Module-6-Starter.sql) — Parts A–C
4. [Module 6 SQL Quick Reference](Module-6-SQL-Quick-Reference.md)

After Lesson 6A, you should be able to:

- explain why joins are needed after normalization;
- trace a foreign-key match from `events.club_id` to `clubs.club_id`;
- write an `INNER JOIN`;
- write a `LEFT JOIN`;
- explain which side of an outer join is preserved;
- predict when a joined row repeats;
- distinguish a filter in `ON` from a filter in `WHERE`;
- use `IS NULL` after a `LEFT JOIN` to find missing relationships;
- recognize `RIGHT JOIN` and `FULL OUTER JOIN` without treating them as the main day-to-day patterns.

### Class 2 — Lesson 6B: Aggregation and Subqueries

Use:

1. [Lesson 6B — Grouping, Aggregates, HAVING, and Subqueries](Module-6B-Grouping-Aggregates-Subqueries-Live-Lab.md) - review after class
2. [Module 6 Starter SQL](Module-6-Starter.sql) — Parts D–F

After Lesson 6B, you should be able to:

- use `COUNT`, `SUM`, `AVG`, `MIN`, and `MAX`;
- explain the difference between one aggregate result and grouped aggregate results;
- use `GROUP BY` correctly;
- explain `WHERE` versus `HAVING`;
- aggregate across a joined result;
- read and write simple scalar, `IN`, `EXISTS`, and `NOT EXISTS` subqueries;
- answer a practical information-retrieval question using multiple SQL ideas together.

## Learning resources

| Resource | Purpose |
| --- | --- |
| [Module 5 Reset and Seed](../Module%205%20-%20SQL%20Labs/Module-5-Reset-and-Seed.sql) | Exact existing Module 5 reset; reused unchanged for Module 6 |
| [Module 6 Database Verification](Module-6-Database-Verification.sql) | Read-only verification of the expected 6-club / 24-event starting state |
| [Interactive JOIN Explorer](https://avijitroy.com/docs/sql-join-explorer.html) | Interactive JOIN / GROUP BY / subquery visualizer hosted on the course instructor's website |
| [Lesson 6A — Joins Live Lab](Module-6A-Joins-Live-Lab.md) | Join lesson for review and practice after class |
| [Lesson 6B — Grouping, Aggregates, HAVING, and Subqueries](Module-6B-Grouping-Aggregates-Subqueries-Live-Lab.md) | Analytical SQL lesson for review and practice after class |
| [Module 6 Starter SQL](Module-6-Starter.sql) | Practice SQL with TODO prompts and partial scaffolds |
| [Module 6 SQL Quick Reference](Module-6-SQL-Quick-Reference.md) | Compact reference for joins, aggregates, grouping, HAVING, and subqueries |

## Important database note

The normal relationship is:

```text
CLUBS
club_id  PRIMARY KEY
   ↑
   │
   │ events.club_id  FOREIGN KEY
   │
EVENTS
```

Because the foreign key requires every event to reference an existing club, a normal `events JOIN clubs ON events.club_id = clubs.club_id` has no orphan event rows. Also, in the reset dataset every one of the six clubs has at least one event.

That means a plain `INNER JOIN` and a plain `LEFT JOIN` can appear to return the same information. Remember: **different join operators can produce the same result when the data happens to contain matches for every row.**

To make outer-join behavior visible without adding fake rows or changing the reset database, Lesson 6A uses a meaningful condition such as “match only Workshop events.” `Debate Society` has no Workshop in the reset dataset, so the `LEFT JOIN` visibly preserves that club and fills the event columns with `NULL`.

## Practice pattern

Continue the Module 5 class habit:

> **Predict → Run → Inspect → Explain → Modify**

Before you run a Module 6 query, ask:

> **What should one result row represent?**

That question prevents many join and grouping mistakes.

## Safety and workflow

- Use the CSCI 362 practice Supabase project only.
- The Module 6 lesson queries are read-only unless your instructor explicitly asks you to add data.
- Do not paste passwords, API keys, connection strings, or real student information into SQL.
- Run the reset only when instructed; it deletes and recreates `public.events` and `public.clubs`.
- Save working SQL, not screenshots alone.
