# CSCI 362 · Module 7A

[Module 7 guide](README.md) · [Course repository](../README.md) · [Review Module 6](../Module%206%20-%20SQL%20Analytical%20Queries/README.md)

## Integrity, Transactions, and Concurrency
**Tuesday, October 13, 2026 · Asynchronous online learning**  
**Estimated time:** 65–75 minutes  
**Prerequisites:** Keys and constraints, INSERT/UPDATE/DELETE, joins, relational design, PostgreSQL basics.

> **Learning outcome:** Explain why correct SQL statements are not sufficient for a reliable multi-user database. Predict which data changes persist after a transaction, recognize concurrency anomalies, and choose a reasonable isolation strategy.

### Your learning route
Read Sections 1–7 (~45–50 minutes). Work through the three annotated examples as you read (~15 minutes). Complete the Brightspace knowledge check (~10 minutes). No live meeting or database account is required today; the code snippets are designed for reasoning, not for executing against your project tables. Bring your answers to the Wednesday workshop.

All SQL fragments use hypothetical tables, not the Module 5–6 `clubs` / `events` schema. Assume each named row exists and required numeric columns are `NOT NULL`. Check [Brightspace](https://brightspace.cuny.edu/) for the knowledge check, submission instructions, and any schedule changes.

---

## 1. Integrity: the database must reject invalid states

A relational schema is more than column names. It declares which database states are permitted. Recall the rules introduced in relational modeling:

| Constraint | Intended guarantee | Example |
|---|---|---|
| Primary key | Every row has a unique, non-null identifier | `equipment_id` cannot be duplicated |
| Foreign key | A reference points to a permitted parent record | A checkout references an existing equipment item |
| NOT NULL | Required information must be supplied | `due_at` must have a value |
| UNIQUE | A value/composite value does not repeat where prohibited | One institutional email per user |
| CHECK | A testable row-level condition holds | `quantity >= 0` |
| Application/business rule | A rule potentially spanning data, authorization, and workflow | An item cannot have two active checkouts |

**NULL matters:** `CHECK (quantity >= 0)` rejects negative values but permits `NULL`; add `NOT NULL` when a quantity is required. PostgreSQL's ordinary `UNIQUE` permits multiple `NULL` values, and a nullable foreign-key column can omit a parent reference. Pair these constraints with `NOT NULL` when the rule requires a value.

**Important distinction:** A foreign key establishes referential integrity; it does not by itself prove a checkout is authorized, that a student is eligible, or that the item is available. Some cross-row rules require carefully designed transactions, unique partial indexes, triggers, or application logic.

**Check yourself:** `CHECK (balance >= 0)` rejects a negative balance, but does it guarantee that transferring money between two accounts preserves the combined balance? No. That requires both changes to be executed as one correctly implemented unit of work.

## 2. A transaction is one logical unit of work

Imagine a campus equipment desk checking out a camera. A workflow might (1) verify the item is available, (2) create a checkout record, and (3) change the item status. If step 2 succeeds and step 3 fails, the database can contradict itself unless the steps are controlled together.

A **transaction** groups operations into a unit that either commits successfully or is rolled back. Its boundary is explicit in PostgreSQL:

```sql
BEGIN;
-- Perform the changes that belong together.
COMMIT; -- Persist the completed transaction.
```

Or, when abandoning the work:

```sql
BEGIN;
-- Provisional changes here.
ROLLBACK; -- Discard all uncommitted changes in this transaction.
```

Without an explicit `BEGIN`, a typical PostgreSQL session runs each standalone statement in its own implicit transaction (*autocommit*, assuming the client has not disabled it). One statement can be atomic while an entire multi-statement business process is not. Also note that `COMMIT` is not an undo button: a later mistake requires a new compensating transaction or an appropriate recovery process.

### Worked example A: transfers and failure

Initial balances: Account 101 = $500, Account 202 = $300. We intend to transfer $120.

```sql
BEGIN;
UPDATE account SET balance = balance - 120 WHERE account_id = 101;
UPDATE account SET balance = balance + 120 WHERE account_id = 202;
COMMIT;
```

Expected final balances: $380 and $420. The total remains $800. If the second update fails, the transaction can be rolled back, leaving $500 and $300. **However**, wrapping code in a transaction does not guarantee that the SQL itself enforces the intended business invariant: an accidental `+ 12` instead of `+ 120` could commit unless validated.

**A missing row is not a SQL error:** If Account 202 does not exist, its `UPDATE` affects zero rows, and the debit could still commit. The application must verify that each update affected exactly one row and roll back if it did not. Atomicity groups the operations; it does not detect an incomplete business workflow.

## 3. ACID: four different guarantees

| Property | Meaning | Failure question to ask |
|---|---|---|
| **Atomicity** | A transaction's changes take effect as a unit or not at all. | Did a transfer debit one account but not credit the other? |
| **Consistency** | Each successful transaction is expected to preserve declared database constraints and correctly implemented business invariants. | Did the resulting state violate a key, CHECK, or intended domain rule? |
| **Isolation** | Concurrent transactions interact under defined visibility and ordering rules. | Did another transaction see or overwrite something it should not? |
| **Durability** | Once successfully committed, changes survive a subsequent crash within the database's durability guarantees. | Would a power failure erase an acknowledged commit? |

**ACID does not mean every query is logically correct or every application is secure.** Database constraints enforce the rules actually encoded; the developer still must design valid workflows and authorization checks.

### Worked example B: a failed statement in PostgreSQL

```sql
BEGIN;
UPDATE account SET balance = balance - 20 WHERE account_id = 101;
-- Suppose the next statement raises a CHECK or syntax error.
UPDATE account SET balance = -999 WHERE account_id = 202;
-- A PostgreSQL transaction with a statement error is now aborted.
ROLLBACK;
```

With an appropriate `CHECK (balance >= 0)`, the second statement fails. In PostgreSQL, ordinary subsequent commands in that failed transaction are rejected until `ROLLBACK` (or rollback to an established savepoint). The earlier debit must not remain committed.

After the rollback, the balances are still **$500 and $300**, assuming the initial state from example A. Sending `COMMIT` while the transaction is aborted also rolls it back; it cannot preserve the earlier debit. Rollback undoes these table changes, but sequence counters used to generate IDs can still advance, so gaps in IDs do not prove that rows were committed.

## 4. Transaction control: COMMIT, ROLLBACK, and SAVEPOINT

`COMMIT` completes a successful transaction. `ROLLBACK` cancels the entire uncommitted transaction. `SAVEPOINT` establishes a position to which part of a transaction can be undone without abandoning the whole transaction.

```sql
BEGIN;
UPDATE inventory SET available_units = available_units - 1 WHERE item_id = 7;
SAVEPOINT optional_note;
INSERT INTO checkout_notes(item_id, note) VALUES (7, 'Condition uncertain');
ROLLBACK TO SAVEPOINT optional_note;  -- Undo note only.
COMMIT;                               -- Keep the inventory change.
```

This illustrative fragment assumes the mentioned tables exist. Rolling back to a savepoint does **not** commit the earlier operations; they remain uncommitted until the final `COMMIT`. A savepoint is useful for optional tasks or recoverable errors; it is not a substitute for correct validation.

### Trace it: predict the final value

Initial `quantity = 8`:

```sql
BEGIN;
UPDATE stock SET quantity = quantity - 2 WHERE item_id = 5;
SAVEPOINT before_adjustment;
UPDATE stock SET quantity = quantity - 3 WHERE item_id = 5;
ROLLBACK TO SAVEPOINT before_adjustment;
COMMIT;
```

**Stop and calculate before checking the answer:** The committed quantity is **6**, not 3 and not 8.

## 5. Concurrency: two users, one database

Concurrency means transactions can overlap. Simply having valid SQL statements does not remove race conditions.

### Timeline: the lost-update problem

Consider two application sessions that read the same quantity and then each write an absolute value calculated outside the database.

| Time | Session A | Session B |
|---|---|---|
| T1 | Reads `quantity = 10` | |
| T2 | | Reads `quantity = 10` |
| T3 | Computes 10 − 1 = 9 | |
| T4 | | Computes 10 − 1 = 9 |
| T5 | Writes `quantity = 9` | |
| T6 | | Writes `quantity = 9` |

Both users believe they checked out one item, but the stored count fell by only one. The intended result is 8. This is a **lost update** due to a read-modify-write workflow that did not protect the underlying state.

Assume both sessions use Read Committed and commit their writes, with A committing before B's write completes. A row lock during each `UPDATE` does not fix a value already calculated from a stale read: B still writes the literal value `9`.

A safer approach uses a condition in the update:

```sql
UPDATE inventory
SET available_units = available_units - 1
WHERE item_id = 7 AND available_units > 0
RETURNING available_units;
```

This single SQL statement performs the decrement on the database's current row value and returns a row only if the condition held. A multi-step checkout still needs a surrounding transaction and appropriate control of its other changes.

At Read Committed, an update may wait for a concurrent updater, then recheck its condition against the updated row. **No returned row means no decrement occurred**: the item may be missing or have no units available. The application must handle that outcome before creating a checkout.

### Other concurrency problems to recognize

- **Dirty read:** Transaction A sees a change from B that B has not committed. PostgreSQL does not permit dirty reads even when `READ UNCOMMITTED` is requested.
- **Nonrepeatable read:** A transaction runs the same row query twice and sees a different committed value because another transaction updated it.
- **Phantom read:** Repeating a predicate query yields a changed set of matching rows due to another transaction's writes.
- **Deadlock:** Two transactions hold locks each other needs. PostgreSQL detects the deadlock and aborts one transaction; applications should be prepared to retry the complete operation when appropriate.

### Worked example C: concurrent reservations

A camera has one unit available. Two students click “Reserve” nearly simultaneously. If both simply execute `SELECT available_units` and separately create reservations, both might conclude that the item is free. A reliable implementation checks and changes availability atomically, and should define what to do when the update returns no row.

Using the conditional update above inside each checkout transaction:

1. Session A changes availability from 1 to 0 and receives a returned row.
2. Session B tries the same update and waits while A's transaction is open.
3. A inserts its checkout and commits both changes together.
4. B rechecks `available_units > 0`, receives no row, and abandons its checkout without inserting a reservation. The application reports that the camera is unavailable.

If A's insert fails and A rolls back, its decrement is undone; B can then acquire the available unit. This trace assumes Read Committed. At Repeatable Read or Serializable, B may instead receive a serialization error and must retry the whole transaction.

## 6. Isolation levels in PostgreSQL

Isolation level determines which effects of other concurrent transactions may be observed. **PostgreSQL defaults to READ COMMITTED** for ordinary transactions.

| Isolation | Practical behavior for this course |
|---|---|
| READ UNCOMMITTED | PostgreSQL treats it as READ COMMITTED; dirty reads still do not occur. |
| READ COMMITTED | An ordinary SELECT sees data committed before the statement began, plus the transaction's own earlier changes. Repeated statements may see different results; updates can wait and recheck changed rows. |
| REPEATABLE READ | Uses a stable snapshot established by the first data-access statement, plus the transaction's own changes. Prevents nonrepeatable reads and phantoms in PostgreSQL, but not every serialization anomaly; concurrent updates can require retries. |
| SERIALIZABLE | Strongest level: transactions behave as though executed in some serial order; a conflicting transaction may fail with a serialization error and require a full retry. |

Set isolation level at the start of a transaction, before data-access statements:

```sql
BEGIN ISOLATION LEVEL REPEATABLE READ;
SELECT * FROM inventory WHERE item_id = 7;
-- Other transaction may commit a change here.
SELECT * FROM inventory WHERE item_id = 7;
COMMIT;
```

**Serialization anomaly:** Committed concurrent transactions produce a result that no one-at-a-time ordering could produce. For example, two on-duty staff each see the other on duty and independently mark themselves off duty. Both changes can commit under Repeatable Read, leaving nobody on duty; either serial ordering would have made the second person stay.

**Design trade-off:** Stronger isolation reduces certain anomalies but can add monitoring overhead and retry requirements. PostgreSQL's Serializable conflict detection does not add blocking beyond Repeatable Read. Explicit row locks can make competing operations wait. An appropriate solution can combine row locks (`SELECT ... FOR UPDATE`), atomic conditional updates, and uniqueness enforcement. Retry the whole transaction after a serialization failure, using fresh reads; do not simply resend its last statement or retry a business rejection such as “no units available.”

## 7. Reliability is a system property

Transactions ensure a bounded group of changes has clear commit/rollback semantics. Constraints reject classes of invalid states. Locking and isolation coordinate concurrent work. Backups, recovery, and operational controls address other failure modes. None of these replaces user authorization or data minimization: those are the focus of Wednesday's Module 7B.

### Final application exercise (write 3–5 sentences)

A media lab has one camera available. Two students submit checkout requests at the same moment. The software first queries availability and later inserts a checkout row. Both checkouts succeed, and the camera appears assigned to two students.

1. Identify the race condition.
2. Explain why a transaction alone, with an unprotected read, may still be insufficient.
3. Propose **two complementary protections** (for example, an atomic conditional update and a database constraint that forbids multiple active checkouts).
4. Explain what the application should do when the item is no longer available.

### Completion checklist

- [ ] I can distinguish integrity constraints from workflow/business rules.
- [ ] I can predict the effects of COMMIT, ROLLBACK, and SAVEPOINT.
- [ ] I can explain ACID using a concrete example.
- [ ] I can diagnose lost updates and describe the difference between dirty, nonrepeatable, and phantom reads.
- [ ] I know PostgreSQL's default isolation level and why concurrency may require retries.
- [ ] I completed the Module 7A Brightspace knowledge check.

## PostgreSQL references

These references support the PostgreSQL-specific behavior in this reading; they are optional follow-up reading.

- [Constraints](https://www.postgresql.org/docs/current/ddl-constraints.html): keys, `CHECK`, and `NULL` behavior.
- [Transactions](https://www.postgresql.org/docs/current/tutorial-transactions.html): transaction boundaries and savepoints.
- [Transaction isolation](https://www.postgresql.org/docs/current/transaction-iso.html): snapshots, conditional updates, isolation levels, retries, and sequence behavior.
- [Explicit locking](https://www.postgresql.org/docs/current/explicit-locking.html): row locks and deadlocks.
- [COMMIT](https://www.postgresql.org/docs/current/sql-commit.html): completing a successful transaction.

