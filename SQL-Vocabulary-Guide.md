# CSCI 362 — SQL Vocabulary Guide

## Relational Databases, PostgreSQL, and Supabase

This guide defines the vocabulary used in CSCI 362 database discussions, SQL examples, labs, and project instructions. Use it before class, during practice, and when explaining your work.

The goal is not merely to recognize a term. You should be able to:

1. define the term in plain language;
2. identify it in a database or SQL statement;
3. distinguish it from related terms; and
4. explain why it matters in a database design or query.

> [!IMPORTANT]
> This is a reference guide, not a substitute for the current lab or assignment instructions. Brightspace remains the authority for required work, deadlines, submissions, and course-specific changes.

## How to Read This Guide

- **Formal relational term** identifies language from the relational model.
- **Common SQL term** identifies language commonly used with database software.
- **PostgreSQL** identifies behavior or syntax specific to the DBMS used in this course.
- SQL keywords appear in uppercase, such as `SELECT`, but PostgreSQL accepts them in lowercase as well.
- Examples use a small fictional bookstore database and are not solutions to course assignments.

SQL may be pronounced “S-Q-L” or “sequel.” Both pronunciations are common.

## Guide Sections

1. [Database and Relational Foundations](#i-database-and-relational-foundations)
2. [Keys, Relationships, and Integrity](#ii-keys-relationships-and-integrity)
3. [Functional Dependencies and Normalization](#iii-functional-dependencies-and-normalization)
4. [SQL Language and Statement Anatomy](#iv-sql-language-and-statement-anatomy)
5. [Defining and Changing Database Structure](#v-defining-and-changing-database-structure)
6. [Adding, Changing, and Removing Rows](#vi-adding-changing-and-removing-rows)
7. [Querying and Interpreting Results](#vii-querying-and-interpreting-results)
8. [Transactions, Security, and Performance](#viii-transactions-security-and-performance)
9. [Supabase Lab Vocabulary](#ix-supabase-lab-vocabulary)
10. [Commonly Confused Terms](#x-commonly-confused-terms)
11. [Reading a Complete Example](#xi-reading-a-complete-example)
12. [Lab Communication Checklist](#xii-lab-communication-checklist)

## Quick Mental Model

```text
Database management system (PostgreSQL)
└── Database
    └── Schema
        ├── Table
        │   ├── Column
        │   ├── Constraint
        │   └── Row
        ├── View
        └── Other database objects
```

A useful theory-to-SQL translation is:

| Relational-model term | Common SQL term |
| --- | --- |
| Relation | Table |
| Tuple | Row or record |
| Attribute | Column |
| Domain | Allowed values represented through a data type and constraints |
| Relation schema | Table definition |
| Relation state | The rows currently stored in the table |

These pairs are closely related, but they are not always perfectly interchangeable. The relational model is mathematical; SQL database systems are practical implementations with additional features and behavior.

## I. Database and Relational Foundations

### Data

Raw facts, measurements, symbols, or observations that can be stored and processed. A date, price, identifier, or category can be data.

**Example:** `29.95` stored as a book price is one piece of data.

### Information

Data interpreted in context so that it answers a question or supports a decision. A list of prices is data; identifying the average price by category produces information.

**Example:** Calculating that the average book price is `$24.10` turns stored prices into information.

### Database

An organized collection of related data. A database also includes structures and rules that help store, retrieve, and protect that data.

Do not use *database* when you mean one table. A database usually contains multiple related tables and other objects.

**Example:** A bookstore database can contain authors, books, customers, and orders.

### Database Management System (DBMS)

Software that creates, stores, queries, secures, and manages databases. **PostgreSQL** is the primary DBMS used in this course.

**Example:** PostgreSQL accepts a query, checks permissions, finds the requested rows, and returns the result.

### Relational Database

A database organized primarily around relations. In SQL systems, relations are implemented mainly as tables connected through keys and constraints.

**Example:** The `authors` and `books` tables form part of a relational database when `books.author_id` refers to `authors.author_id`.

### Data Model

A set of concepts for describing data, relationships, rules, and permitted operations. The relational model organizes data through relations, attributes, tuples, domains, and keys.

**Example:** A relational data model describes books as relations with attributes, keys, and integrity rules.

### Entity

A distinguishable real-world object or concept about which the database stores data, such as an author, book, customer, or order.

**Example:** One particular author is an entity about which the bookstore stores data.

### Entity Type and Entity Instance

- An **entity type** defines a category and its properties, such as `Book`.
- An **entity instance** is one specific member of that category, such as one particular book.

**Example:** `Book` is an entity type; the book with `book_id = 101` is an entity instance.

### Relationship

An association among entity types or instances. During relational mapping, relationships are represented through foreign keys or associative tables, depending on their cardinality.

**Example:** The statement “an author writes books” describes a relationship.

### Entity-Relationship Diagram (ERD)

A conceptual model showing entity types, attributes, identifiers, relationships, cardinalities, and participation rules. An ERD is a design artifact; it is not the database itself.

**Example:** An ERD can show `Author` and `Book` connected by a one-to-many relationship.

### ER-to-Relational Mapping

The process of translating an ER model into relations, keys, foreign keys, and constraints that can be implemented as SQL tables.

**Example:** The `Author` entity becomes an `authors` table, and its one-to-many relationship is implemented with `books.author_id`.

### Schema

The word *schema* has two related meanings:

1. **Database-design meaning:** the overall logical structure of the database—its tables, columns, keys, relationships, and constraints.
2. **PostgreSQL meaning:** a named namespace inside a database that groups objects. The default user schema is often named `public`.

Always use context to determine which meaning is intended.

**Example:** `public.books` names the `books` table inside PostgreSQL’s `public` schema.

### Database Instance or Database State

The data stored in the database at a particular moment. The schema describes the structure; the instance or state describes the current contents.

**Example:** After a new book is inserted, the database state contains one more row even though the schema is unchanged.

### Relation

A formal relational-model structure consisting of a heading and a set of tuples. In introductory SQL work, a relation is commonly represented by a table.

**Example:** `Books(book_id, title, price)` describes a relation heading with tuples that follow it.

### Table

A named SQL database object organized into columns and rows. A table definition specifies its columns, data types, and constraints.

**Example:** `books` is a table containing one row for each stored book.

### Attribute

A named property in a relation. In SQL practice, an attribute is represented by a column.

**Example:** `title` is an attribute of the `Book` relation.

### Column

A named component of a table. Every column has a data type and may have constraints.

**Example:** `books.price` is a column whose values use a numeric data type.

### Field

An informal and sometimes ambiguous term used for a column, an input area, or one value within a row. In formal explanations, use the more precise term—usually *column* or *value*.

**Example:** Instead of saying “the price field,” say `price` column when referring to the table definition.

### Tuple

A single collection of related attribute values in a relation. In SQL practice, a tuple is represented by a row.

**Example:** `(101, 'Kindred', 14.99)` can represent one tuple in a book relation.

### Row or Record

One stored item in a table. A row contains one value—or `NULL`—for each table column.

**Example:** The row with `book_id = 101` stores the values for one book.

### Domain

The permitted set of values for an attribute. In PostgreSQL, a domain is commonly represented through a data type plus constraints, although PostgreSQL also supports named domain objects.

For example, the domain of a rating might be integers from 1 through 5. The type `INTEGER` alone does not enforce that entire rule; a `CHECK` constraint may also be needed.

**Example:** A rating domain may allow only integers from 1 through 5.

### Data Type

A classification that determines how a value is represented and which operations are valid. Examples include `INTEGER`, `NUMERIC`, `TEXT`, `DATE`, `BOOLEAN`, and `TIMESTAMP`.

**Example:** `DATE` is appropriate for `published_date`, while `NUMERIC(8, 2)` can represent a price.

### `NULL`

A marker indicating that a value is unknown, missing, or not applicable. `NULL` is not zero, an empty string, the word `NULL`, or a blank space.

Most comparisons with `NULL` do not evaluate to true or false; they evaluate to unknown. Use `IS NULL` or `IS NOT NULL`, not `= NULL`.

```sql
SELECT title
FROM books
WHERE published_date IS NULL;
```

**Example:** A `NULL` return date can mean that a borrowed book has not yet been returned.

## II. Keys, Relationships, and Integrity

### Key

One column or a combination of columns used to identify rows or connect tables.

**Example:** `book_id` can be used as a key to locate one book row.

### Superkey

Any set of attributes that uniquely identifies a tuple. A superkey may include unnecessary attributes.

**Example:** `{book_id, title}` is a superkey when `book_id` alone already identifies every book.

### Candidate Key

A minimal superkey: it uniquely identifies a row, and no attribute can be removed without losing uniqueness.

**Example:** If both `book_id` and `isbn` uniquely identify a book, each can be a candidate key.

### Primary Key

The candidate key selected as the table’s main row identifier. A primary key must be unique and not `NULL`.

```sql
book_id INTEGER PRIMARY KEY
```

**Example:** Selecting `book_id` as `PRIMARY KEY` makes it the table’s main row identifier.

### Alternate Key

A candidate key that was not selected as the primary key. It is often enforced with a `UNIQUE` constraint.

**Example:** If `book_id` is primary, a unique `isbn` can serve as an alternate key.

### Composite Key

A key formed from two or more columns.

```sql
PRIMARY KEY (order_id, book_id)
```

**Example:** `PRIMARY KEY (order_id, book_id)` identifies one book line within one order.

### Natural Key

A key based on a meaningful real-world value, such as a standardized identifier. Natural keys can be useful, but they may change or carry formatting complications.

**Example:** An ISBN is a possible natural key because it has meaning outside the database.

### Surrogate Key

An artificial identifier created for the database, such as a generated integer. It has no business meaning beyond identifying a row.

**Example:** A generated `book_id` is a surrogate key because the number exists only to identify a database row.

### Foreign Key

A column or column group whose values must match a candidate key—usually a primary key—in another table or the same table. Foreign keys represent and enforce relationships.

```sql
author_id INTEGER REFERENCES authors(author_id)
```

A foreign key is not automatically unique and is not automatically `NOT NULL`.

**Example:** `books.author_id` can reference `authors.author_id`.

### Parent and Child Tables

In a foreign-key relationship:

- the **parent table** contains the referenced key; and
- the **child table** contains the foreign key.

These names describe the relationship, not the overall importance of either table.

**Example:** In that relationship, `authors` is the parent table and `books` is the child table.

### Cardinality

The number or pattern of possible relationships between entity instances, such as one-to-one, one-to-many, or many-to-many.

In query results, *cardinality* may also refer to the number of rows. Pay attention to context.

**Example:** One author may be related to many books, producing one-to-many cardinality.

### Associative or Junction Table

A table used to implement a many-to-many relationship. It contains foreign keys referencing the related parent tables and may contain attributes belonging to the relationship itself.

**Example:** `order_items(order_id, book_id, quantity)` implements the many-to-many relationship between orders and books.

### Constraint

A rule enforced by the DBMS to protect valid data. Common constraints include `PRIMARY KEY`, `FOREIGN KEY`, `NOT NULL`, `UNIQUE`, and `CHECK`.

**Example:** `CHECK (price >= 0)` prevents a negative book price.

### `NOT NULL`

A constraint requiring a column to contain a non-`NULL` value in every row.

**Example:** `title TEXT NOT NULL` requires every book row to contain a title.

### `UNIQUE`

A constraint preventing duplicate non-`NULL` values in a column or column group. In PostgreSQL’s default behavior, a unique constraint can permit more than one `NULL` because `NULL` represents an unknown value.

**Example:** `isbn TEXT UNIQUE` prevents two non-`NULL` rows from storing the same ISBN.

### `CHECK`

A constraint requiring inserted or updated data to satisfy a Boolean condition.

```sql
price NUMERIC(8, 2) CHECK (price >= 0)
```

**Example:** `rating INTEGER CHECK (rating BETWEEN 1 AND 5)` restricts valid ratings.

### `DEFAULT`

A value PostgreSQL supplies when an `INSERT` statement omits that column. A default does not prevent a user from explicitly providing another permitted value.

**Example:** `is_available BOOLEAN DEFAULT TRUE` supplies `TRUE` when an insert omits the column.

### Entity Integrity

The rule that every row must have a unique, non-`NULL` primary-key value.

**Example:** PostgreSQL rejects a book row whose primary key is `NULL`.

### Referential Integrity

The rule that every non-`NULL` foreign-key value must match an existing referenced key. This prevents orphaned references.

**Example:** PostgreSQL rejects `author_id = 99` when no referenced author 99 exists.

### Cascade

An action that automatically propagates a parent-table change to related child rows, such as `ON DELETE CASCADE`. Cascades must be chosen deliberately because they can affect many rows.

**Example:** With `ON DELETE CASCADE`, deleting an order can automatically delete its related order-item rows.

## III. Functional Dependencies and Normalization

### Redundancy

The unnecessary repetition of the same fact. Redundancy can waste storage and create inconsistent copies of data.

**Example:** Repeating an author’s email in every book row stores the same fact many times.

### Anomaly

An undesirable effect caused by a poor table design:

- an **insertion anomaly** prevents storing one fact without an unrelated fact;
- an **update anomaly** requires the same fact to be changed in multiple rows; and
- a **deletion anomaly** causes an unrelated fact to disappear when a row is deleted.

**Example:** If the email is repeated in five rows, updating only four creates an update anomaly.

### Functional Dependency

A relationship between attribute sets. `X → Y` means that each value of `X` determines exactly one value of `Y` within the relation.

```text
book_id → title, author_id, price
```

The dependency is a rule about the meaning of the data, not merely a pattern noticed in the current rows.

**Example:** `book_id → title, price` states that one book identifier determines one title and price.

### Determinant

The attribute or attribute set on the left side of a functional dependency. In `X → Y`, `X` is the determinant.

**Example:** In `book_id → title`, `book_id` is the determinant.

### Dependent Attribute

An attribute on the right side of a functional dependency. In `X → Y`, `Y` is functionally dependent on `X`.

**Example:** In `book_id → title`, `title` is the dependent attribute.

### Full Functional Dependency

A dependency in which an attribute depends on an entire composite determinant and not on any proper subset of it.

**Example:** In an order-item table keyed by `(order_id, book_id)`, `quantity` can depend on the entire composite key.

### Partial Dependency

A dependency in which a non-key attribute depends on only part of a composite candidate key.

**Example:** If `book_title` depends only on `book_id` within a table keyed by `(order_id, book_id)`, that is a partial dependency.

### Transitive Dependency

An indirect dependency in which a key determines a non-key attribute through another non-key determinant.

**Example:** If `book_id → publisher_id` and `publisher_id → publisher_name`, then `publisher_name` is transitively dependent on `book_id`.

### Normalization

A structured process for analyzing relations and reducing avoidable redundancy and anomalies while preserving required information and dependencies.

Normalization is not simply “splitting tables.” Each decomposition must be justified by dependencies and design goals.

**Example:** Moving publisher details into a separate `publishers` table can reduce repeated publisher facts.

### Decomposition

Replacing one relation with two or more relations to improve design quality.

**Example:** A combined `books_and_publishers` relation can be decomposed into `books` and `publishers`.

### Lossless Decomposition

A decomposition that allows the original relation to be reconstructed through joins without losing information or creating spurious rows.

**Example:** Joining the decomposed `books` and `publishers` tables on `publisher_id` reconstructs the original facts without invented rows.

### Dependency Preservation

A property allowing important functional dependencies to be enforced within the decomposed relations without joining them first.

**Example:** A unique ISBN rule remains enforceable directly in `books` after decomposition.

### First Normal Form (1NF)

In the course’s introductory use, each row-column position contains one value from the column’s domain, and repeating groups are removed.

**Example:** Store one author identifier per row instead of a comma-separated list such as `'4,7,9'`.

### Second Normal Form (2NF)

A relation is in 2NF when it is in 1NF and every non-key attribute is fully dependent on each candidate key. Partial dependencies are the central concern when composite keys exist.

**Example:** Move `book_title`, which depends only on `book_id`, out of a table keyed by `(order_id, book_id)`.

### Third Normal Form (3NF)

A relation is in 3NF when it is in 2NF and non-key facts do not depend transitively on a candidate key through another non-key determinant. Formally, for every nontrivial functional dependency `X → A`, either `X` is a superkey or `A` is a prime attribute.

**Example:** Store `publisher_name` in `publishers` rather than in `books` when it depends on `publisher_id`.

### Boyce-Codd Normal Form (BCNF)

A stronger normal form requiring every determinant in a nontrivial functional dependency to be a superkey.

**Example:** A relation violates BCNF when a non-superkey attribute set determines another attribute.

### Prime Attribute

An attribute that belongs to at least one candidate key. A non-prime attribute belongs to no candidate key.

**Example:** In candidate key `(order_id, book_id)`, both `order_id` and `book_id` are prime attributes.

## IV. SQL Language and Statement Anatomy

### SQL

Structured Query Language: the language used to define, query, modify, control, and manage data in relational database systems.

**Example:** `SELECT title FROM books;` is an SQL instruction.

### SQL Statement

A complete instruction sent to the DBMS. Statements normally end with a semicolon.

```sql
SELECT title FROM books;
```

**Example:** `UPDATE books SET price = 20 WHERE book_id = 101;` is one complete SQL statement.

### Keyword

A word with a defined SQL meaning, such as `SELECT`, `FROM`, `WHERE`, `CREATE`, or `PRIMARY KEY`.

**Example:** `SELECT`, `FROM`, and `WHERE` are keywords in a query.

### Identifier

A name assigned to a database object, such as `books`, `book_id`, or `published_date`. Prefer lowercase `snake_case` identifiers in PostgreSQL and avoid spaces or unnecessarily quoted names.

**Example:** `books`, `book_id`, and `published_date` are identifiers.

### Literal

A value written directly in SQL.

```sql
'Database Systems' -- text literal
29.95              -- numeric literal
DATE '2000-01-01'  -- date literal
```

**Example:** In `WHERE price > 20`, `20` is a numeric literal.

### Expression

A combination of values, columns, operators, or functions that PostgreSQL evaluates to produce a value.

```sql
price * 0.90
```

**Example:** `price * 0.90` is an expression that calculates a discounted price.

### Operator

A symbol or keyword that performs an operation. Examples include `+`, `-`, `=`, `<>`, `<`, `>`, `AND`, `OR`, `LIKE`, and `IN`.

**Example:** The `>=` operator compares two values in `price >= 20`.

### Predicate

An expression evaluated as true, false, or unknown and used to test a condition.

```sql
price >= 20 AND is_available = TRUE
```

**Example:** `price >= 20 AND is_available = TRUE` is a predicate.

### Clause

A named part of a SQL statement, such as the `SELECT`, `FROM`, `WHERE`, `GROUP BY`, `HAVING`, or `ORDER BY` clause.

**Example:** `WHERE price >= 20` is the `WHERE` clause of a query.

### Function

A named operation that accepts inputs and returns a value. Examples include `UPPER(title)`, `ROUND(price, 2)`, and `CURRENT_DATE`.

**Example:** `UPPER(title)` returns an uppercase version of each title.

### Comment

Text PostgreSQL ignores during execution. Use comments to explain purpose or reasoning, not to restate obvious syntax.

```sql
-- Single-line comment

/* Multi-line
   comment */
```

**Example:** `-- Return currently available books` documents a query without changing its result.

### Syntax

The formal rules governing how a valid SQL statement must be written.

**Example:** `SELECT title FROM books;` follows valid SQL syntax; `SELECT FROM title books;` does not.

### Semantics

The meaning and effect of a valid statement. A statement can be syntactically valid but still express the wrong question or make an unsafe change.

**Example:** A syntactically valid query using `price < 0` may still ask the wrong question when prices cannot be negative.

## V. Defining and Changing Database Structure

SQL command categories are useful classroom labels, but sources do not always classify every command identically.

### Data Definition Language (DDL)

Statements that define or change database structures. Common DDL commands include `CREATE`, `ALTER`, and `DROP`.

**Example:** `CREATE TABLE`, `ALTER TABLE`, and `DROP TABLE` change database structure.

### `CREATE`

Creates a database object.

```sql
CREATE TABLE authors (
    author_id INTEGER PRIMARY KEY,
    author_name TEXT NOT NULL
);
```

**Example:** `CREATE VIEW available_books AS SELECT * FROM books WHERE is_available = TRUE;` creates a view.

### `CREATE TABLE`

Creates a table and defines its columns, data types, and constraints.

```sql
CREATE TABLE books (
    book_id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    author_id INTEGER REFERENCES authors(author_id),
    price NUMERIC(8, 2) CHECK (price >= 0)
);
```

**Example:** `CREATE TABLE authors (author_id INTEGER PRIMARY KEY, author_name TEXT NOT NULL);` creates an authors table.

### `ALTER TABLE`

Changes an existing table definition, such as adding a column or constraint.

```sql
ALTER TABLE books
ADD COLUMN is_available BOOLEAN DEFAULT TRUE;
```

**Example:** `ALTER TABLE books ADD COLUMN pages INTEGER;` adds a column.

### `DROP`

Removes a database object and its definition. `DROP` is destructive and should be used only after confirming the exact target and consequences.

**Example:** `DROP TABLE books;` removes the table definition and its stored rows.

### `TRUNCATE`

Removes all rows from a table efficiently while retaining the table definition. It differs from `DROP TABLE`, which removes the table itself.

**Example:** `TRUNCATE TABLE staging_books;` removes every staging row but retains the table.

## VI. Adding, Changing, and Removing Rows

### Data Manipulation Language (DML)

Statements that retrieve or change stored data. Common introductory examples include `SELECT`, `INSERT`, `UPDATE`, and `DELETE`.

**Example:** `INSERT`, `SELECT`, `UPDATE`, and `DELETE` operate on stored data.

### `INSERT`

Adds one or more new rows.

```sql
INSERT INTO authors (author_id, author_name)
VALUES (1, 'Octavia Butler');
```

**Example:** `INSERT INTO authors (author_id, author_name) VALUES (1, 'Octavia Butler');` adds one author.

### `UPDATE`

Changes values in existing rows.

```sql
UPDATE books
SET price = 24.95
WHERE book_id = 101;
```

An `UPDATE` without an appropriate `WHERE` clause may change every row.

**Example:** `UPDATE books SET price = 19.95 WHERE book_id = 101;` changes one matching book.

### `DELETE`

Removes rows from a table.

```sql
DELETE FROM books
WHERE book_id = 101;
```

A `DELETE` without an appropriate `WHERE` clause may remove every row while leaving the table structure intact.

**Example:** `DELETE FROM books WHERE book_id = 101;` removes one matching book.

### CRUD

A common application-oriented abbreviation:

- **Create** data with `INSERT`;
- **Read** data with `SELECT`;
- **Update** data with `UPDATE`; and
- **Delete** data with `DELETE`.

CRUD describes data operations, not the SQL `CREATE` command used for database objects.

**Example:** Adding, viewing, revising, and removing a book correspond to create, read, update, and delete.

## VII. Querying and Interpreting Results

### Query

A request for data or a derived result. A query does not merely display stored rows; it can filter, combine, calculate, summarize, and reorder data.

**Example:** `SELECT title FROM books WHERE price < 25;` asks for titles of books below a price.

### Result Set

The rows and columns returned by a query. Unless the query includes `ORDER BY`, row order is not guaranteed.

**Example:** That query may return three rows and one column as its result set.

### `SELECT`

Specifies the columns or expressions returned by a query.

```sql
SELECT title, price
FROM books;
```

**Example:** `SELECT title, price` specifies two output columns.

### `FROM`

Identifies the source tables, views, or derived results used by a query.

**Example:** `FROM books` identifies `books` as the row source.

### `WHERE`

Filters individual rows before grouping or aggregation.

```sql
SELECT title, price
FROM books
WHERE price < 25;
```

**Example:** `WHERE price < 25` keeps only rows meeting the condition.

### Projection

A relational operation that chooses attributes. In SQL practice, the `SELECT` list determines the returned columns or expressions.

**Example:** Returning only `title` and `price` projects those attributes.

### Selection

A relational operation that chooses rows satisfying a condition. In SQL practice, `WHERE` performs this role.

Do not confuse the relational operation *selection* with the SQL keyword `SELECT`.

**Example:** Keeping only rows with `price < 25` performs selection.

### Alias

A temporary name assigned within a query using `AS` or an implied alias.

```sql
SELECT b.title AS book_title
FROM books AS b;
```

**Example:** `books AS b` lets the query refer to the table as `b`.

### `DISTINCT`

Removes duplicate rows from a query’s result set. It does not permanently change stored data.

**Example:** `SELECT DISTINCT author_id FROM books;` returns each represented author identifier once.

### `ORDER BY`

Sorts the final result set by one or more expressions.

```sql
SELECT title, price
FROM books
ORDER BY price DESC, title ASC;
```

**Example:** `ORDER BY price DESC` places higher-priced results first.

### `LIMIT`

Restricts the number of returned rows. Use `ORDER BY` when the particular rows returned must be predictable.

**Example:** `ORDER BY price DESC LIMIT 5` returns at most the five highest-priced rows.

### Pattern Matching

Comparison based on a pattern. With `LIKE`, `%` represents any sequence of characters and `_` represents one character.

```sql
WHERE title LIKE 'Data%'
```

**Example:** `title LIKE 'Data%'` matches titles beginning with `Data`.

### Aggregate Function

A function that summarizes multiple input rows. Common examples are `COUNT`, `SUM`, `AVG`, `MIN`, and `MAX`.

**Example:** `AVG(price)` calculates one average from multiple price values.

### `GROUP BY`

Forms groups of rows that share specified values so that aggregates can be calculated for each group.

```sql
SELECT author_id, COUNT(*) AS book_count
FROM books
GROUP BY author_id;
```

**Example:** `GROUP BY author_id` creates one group for each represented author.

### `HAVING`

Filters groups after `GROUP BY`. Use `WHERE` for row-level filtering before grouping and `HAVING` for group-level filtering after aggregation.

```sql
SELECT author_id, COUNT(*) AS book_count
FROM books
GROUP BY author_id
HAVING COUNT(*) >= 2;
```

**Example:** `HAVING COUNT(*) >= 2` keeps groups containing at least two rows.

### Join

An operation that combines rows from two sources according to a condition. A correct join condition should reflect the actual relationship between the tables.

**Example:** A query can join `books` to `authors` so each title appears with its author’s name.

### Join Condition

The predicate determining which rows from the joined sources match.

```sql
ON b.author_id = a.author_id
```

**Example:** `ON books.author_id = authors.author_id` states how author and book rows match.

### Inner Join

Returns only rows that satisfy the join condition in both sources.

```sql
SELECT b.title, a.author_name
FROM books AS b
INNER JOIN authors AS a
    ON b.author_id = a.author_id;
```

**Example:** An inner join omits a book whose `author_id` has no matching author.

### Outer Join

Preserves unmatched rows from one or both sources. A `LEFT JOIN` keeps every row from the left source; unmatched right-side columns appear as `NULL`.

**Example:** A left join can return every author, including authors who currently have no books.

### Cross Join

Returns every possible pairing of rows from two sources. This is a Cartesian product and can become very large.

**Example:** Three authors cross-joined with four categories produce twelve row combinations.

### Self-Join

A table joined to itself using different aliases, often to represent relationships among rows in the same table.

**Example:** An `employees` table can join to itself to match each employee with a manager.

### Subquery

A query nested inside another SQL statement. The outer statement uses the subquery’s value or result set.

**Example:** `WHERE price > (SELECT AVG(price) FROM books)` compares each price with the overall average.

### View

A named query stored in the database and used like a virtual table. A standard view stores its definition, not a separate copy of every result row.

**Example:** An `available_books` view can store the query that returns books currently available.

### Logical Query Processing Order

SQL is written beginning with `SELECT`, but a useful conceptual processing order is:

```text
FROM / JOIN
WHERE
GROUP BY
HAVING
SELECT
DISTINCT
ORDER BY
LIMIT
```

This model helps explain why a `WHERE` clause cannot normally use an aggregate result and why `HAVING` is evaluated after grouping.

**Example:** A query conceptually forms joined rows before `WHERE` filters them and before `SELECT` produces output columns.

## VIII. Transactions, Security, and Performance

### Transaction

A logical unit of work containing one or more database operations. A transaction should either complete successfully as intended or leave the database in an acceptable state.

**Example:** Recording an order and all its order items can be handled as one transaction.

### ACID

Four widely used transaction properties:

- **Atomicity:** the transaction’s work is treated as an all-or-nothing unit.
- **Consistency:** completed work preserves defined database rules.
- **Isolation:** concurrent transactions are controlled so their interaction is predictable.
- **Durability:** committed changes survive system failures within the DBMS’s guarantees.

**Example:** If an order-item insert fails, atomicity allows the entire order transaction to roll back.

### `BEGIN`

Starts an explicit transaction block in PostgreSQL.

**Example:** `BEGIN;` starts an explicit transaction block.

### `COMMIT`

Makes a transaction’s successful changes permanent.

**Example:** `COMMIT;` makes a successfully completed price update permanent.

### `ROLLBACK`

Cancels uncommitted changes in the current transaction.

```sql
BEGIN;

UPDATE books
SET price = price * 0.90
WHERE author_id = 1;

ROLLBACK;
```

**Example:** `ROLLBACK;` cancels uncommitted test changes.

### Concurrency

Multiple users or processes accessing the database during overlapping periods. A DBMS coordinates concurrent work to protect correctness and performance.

**Example:** Two customers may attempt to purchase the final copy of a book at nearly the same time.

### Role

A PostgreSQL identity that can own objects and receive privileges. A role may represent a user, application, or group.

**Example:** A `lab_reader` role can represent users who only need read access.

### Privilege

Permission to perform an operation on a database object, such as `SELECT`, `INSERT`, `UPDATE`, or `DELETE` on a table.

**Example:** `SELECT` on `books` is a privilege that may be granted to a role.

### `GRANT`

Gives a role specified privileges.

**Example:** `GRANT SELECT ON books TO lab_reader;` gives read access.

### `REVOKE`

Removes specified privileges from a role.

**Example:** `REVOKE INSERT ON books FROM lab_reader;` removes insert permission.

### Row Level Security (RLS)

A PostgreSQL mechanism that uses policies to control which rows a role may access or modify. RLS does not replace table privileges; both layers matter.

**Example:** An RLS policy can allow a user to see only that user’s own saved reading list.

### Policy

A rule used by RLS to determine which rows a role can select, insert, update, or delete.

**Example:** A policy can use `user_id = auth.uid()` to restrict rows to the signed-in user.

### Principle of Least Privilege

Give each user or role only the permissions required for its task and no more.

**Example:** A reporting role receives `SELECT` but not `DELETE` permission.

### SQL Injection

A security vulnerability caused when untrusted input is combined with SQL text in a way that changes the intended command.

**Example:** Concatenating a user-entered title directly into SQL may allow the input to alter the intended statement.

### Parameterized Query

A query that keeps SQL structure separate from input values. Parameterization is a primary defense against SQL injection; manually adding quotation marks is not an adequate substitute.

**Example:** A client sends `SELECT * FROM books WHERE book_id = $1` separately from the identifier value.

### Index

A database structure that can accelerate certain lookups, joins, and sorting operations. Indexes consume storage and add work to data changes. An index also does not guarantee output order; use `ORDER BY`.

**Example:** An index on `books(author_id)` can speed searches for one author’s books.

### Query Plan

The strategy PostgreSQL chooses to execute a query, such as which scan or join method to use.

**Example:** `EXPLAIN` may show whether PostgreSQL chose a sequential scan or an index scan.

## IX. Supabase Lab Vocabulary

### Supabase

A platform that provides a managed PostgreSQL database and related services. In this course, Supabase is the environment; PostgreSQL and SQL are the database technologies being learned.

**Example:** A student opens Supabase to use a managed PostgreSQL database for a lab.

### Organization

A Supabase container for projects, members, and billing settings. The organization is not a PostgreSQL schema.

**Example:** The `CSCI 362` organization can contain the student’s course project.

### Project

A Supabase-managed environment containing a dedicated PostgreSQL database and related services.

**Example:** `CSCI 362 - ARoy` is one Supabase project with its own database.

### Project Dashboard

The Supabase web interface used to access project tools and configuration.

**Example:** The dashboard shows the project status and links to tools such as the SQL Editor.

### SQL Editor

The dashboard tool used to write and execute SQL statements against the project database.

**Example:** A student pastes a reviewed `CREATE TABLE` statement into the SQL Editor and runs it.

### Database Client

Software that connects to a database server and sends commands or queries. The Supabase SQL Editor and DBeaver are database clients; PostgreSQL is the DBMS processing their requests.

**Example:** DBeaver connects to PostgreSQL and sends a `SELECT` query.

### Table Editor

A graphical interface for viewing and changing table structures or rows. It does not replace the need to understand or preserve executable SQL.

**Example:** The Table Editor can display rows from `books` in a grid.

### Data API

Supabase’s API layer for accessing permitted database objects. Creating a PostgreSQL table and allowing an API role to access that table are separate decisions.

**Example:** An application may request permitted `books` rows through the Data API.

### Database Password

A secret credential used for direct database connections. Never place it in screenshots, submissions, notebooks, chat messages, or public repositories.

**Example:** The password used in a PostgreSQL connection must be stored privately.

### Connection String

A structured value containing the information a client needs to connect to a database. It may contain a username, password, host, port, and database name and must be protected as a credential.

**Example:** A connection string tells DBeaver which host, port, database, and credentials to use.

### Project Region

The geographic area where project infrastructure is hosted. A nearby region generally reduces network latency.

**Example:** Selecting `Americas` places the project in an appropriate regional pool for this course.

### Paused Project

A Free Plan project temporarily stopped after low activity. It can be resumed from the Supabase Dashboard before a lab.

**Example:** A student selects `Resume project` before class when a Free Plan project is paused.

## X. Commonly Confused Terms

### Database vs. Table

- A **database** contains related schemas, tables, and other objects.
- A **table** stores rows under a defined set of columns.

**Example:** `bookstore` can be the database, while `books` is one table inside it.

### Query vs. Statement

- A **statement** is any complete SQL instruction.
- A **query** requests data or a derived result.

Every query is expressed through a statement, but statements such as `CREATE TABLE` and `UPDATE` are not normally described as queries in this guide.

**Example:** `SELECT title FROM books;` is a query and a statement; `DROP TABLE books;` is a statement but not a query in this guide.

### Schema vs. Instance

- The **schema** defines structure and rules.
- The **instance** or **state** is the data stored at a particular time.

**Example:** Adding a `pages` column changes the schema; inserting a new book changes the instance.

### Primary Key vs. Foreign Key

- A **primary key** identifies a row in its own table.
- A **foreign key** refers to a candidate key in a parent table and enforces a relationship.

**Example:** `authors.author_id` identifies an author, while `books.author_id` refers to that author.

### `NULL` vs. Zero or Empty Text

- `NULL` means unknown, missing, or not applicable.
- `0` is a known number.
- `''` is a known text value containing zero characters.

**Example:** An unknown price is `NULL`; a free item has price `0`; a known empty note is `''`.

### `WHERE` vs. `HAVING`

- `WHERE` filters rows before grouping.
- `HAVING` filters groups after aggregation.

**Example:** `WHERE price > 0` filters book rows, while `HAVING COUNT(*) > 2` filters author groups.

### `DELETE` vs. `TRUNCATE` vs. `DROP`

- `DELETE` removes selected rows and can use `WHERE`.
- `TRUNCATE` removes all table rows while retaining the table.
- `DROP TABLE` removes the table definition itself.

**Example:** Delete book 101 with `DELETE`, empty a staging table with `TRUNCATE`, or remove that table with `DROP`.

### `DISTINCT` vs. `UNIQUE`

- `DISTINCT` removes duplicate rows from one query result.
- `UNIQUE` is a stored integrity constraint preventing prohibited duplicate values.

**Example:** `DISTINCT` removes repeated author IDs from one result; `UNIQUE` prevents duplicate ISBN values in storage.

### Join vs. Foreign Key

- A **foreign key** is a stored integrity rule.
- A **join** is a query operation combining rows.

A join can be written without a foreign key, and a foreign key does not automatically join tables in a query.

**Example:** A foreign key enforces the author relationship; a join retrieves book and author data together.

### RLS vs. Table Privileges

- **Privileges** determine whether a role may access an object or perform an operation.
- **RLS policies** determine which rows an allowed role may access or change.

**Example:** A role first needs `SELECT` privilege on `books`; an RLS policy can then limit which book rows it sees.

### SQL vs. PostgreSQL vs. Supabase

- **SQL** is the language.
- **PostgreSQL** is the DBMS that implements SQL and adds PostgreSQL-specific features.
- **Supabase** manages the PostgreSQL environment and provides additional services and interfaces.

**Example:** SQL is the instruction, PostgreSQL executes it, and Supabase hosts the PostgreSQL project.

## XI. Reading a Complete Example

Consider this query:

```sql
SELECT
    a.author_name,
    COUNT(b.book_id) AS book_count,
    ROUND(AVG(b.price), 2) AS average_price
FROM authors AS a
INNER JOIN books AS b
    ON b.author_id = a.author_id
WHERE b.price IS NOT NULL
GROUP BY a.author_id, a.author_name
HAVING COUNT(b.book_id) >= 2
ORDER BY average_price DESC;
```

Vocabulary in the example:

1. `authors` and `books` are table identifiers.
2. `a` and `b` are table aliases.
3. `INNER JOIN` combines matching author and book rows.
4. `ON` introduces the join condition.
5. `WHERE` removes rows with a `NULL` price before grouping.
6. `COUNT` and `AVG` are aggregate functions.
7. `GROUP BY` forms one group per author.
8. `HAVING` retains groups containing at least two books.
9. `AS` assigns result-column aliases.
10. `ORDER BY` sorts the final result by the calculated average.

Before executing a query, state in plain language what one result row should represent. For this example, one result row represents one qualifying author and summarizes that author’s books with known prices.

## XII. Lab Communication Checklist

When explaining SQL work, be prepared to answer:

- What question does the statement answer or what change does it make?
- Which tables and columns does it use?
- What does one input row represent?
- What does one result row represent?
- Which keys or relationships connect the tables?
- Which predicates filter rows or groups?
- How are `NULL` values handled?
- Could the statement affect more rows than intended?
- Which constraints protect the data?
- What assumptions or limitations should be documented?

## Official References

- [PostgreSQL documentation](https://www.postgresql.org/docs/current/)
- [PostgreSQL SQL language documentation](https://www.postgresql.org/docs/current/sql.html)
- [PostgreSQL data-definition documentation](https://www.postgresql.org/docs/current/ddl.html)
- [PostgreSQL data-manipulation documentation](https://www.postgresql.org/docs/current/dml.html)
- [PostgreSQL query documentation](https://www.postgresql.org/docs/current/queries.html)
- [Supabase Database documentation](https://supabase.com/docs/guides/database/overview)
- [Supabase Row Level Security documentation](https://supabase.com/docs/guides/database/postgres/row-level-security)

## Course Boundary

This guide supports learning and review. It does not authorize collaboration, outside resources, AI assistance, or reuse of examples on graded work. Follow the instructions for each activity and disclose permitted assistance under the course policy.

© Avijit Roy
