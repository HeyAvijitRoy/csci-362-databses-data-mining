# CSCI 362 — Databases and Data Mining

[![Database: PostgreSQL](https://img.shields.io/badge/database-PostgreSQL-336791?style=flat-square&logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![Language: Python](https://img.shields.io/badge/language-Python-3776AB?style=flat-square&logo=python&logoColor=white)](https://www.python.org/)
[![Course: CSCI 362](https://img.shields.io/badge/course-CSCI%20362-243B53?style=flat-square)](https://avijitroy.com/teaching/)

Course resources, guided activities, and technical examples for learning relational database design, SQL, data analysis, and introductory data mining.

**[Start with Module 1](#module-catalog)** · **[Find the current syllabus](https://avijitroy.com/teaching/)** · **[Open Brightspace](https://brightspace.cuny.edu/)**

> Design the data. State the relationships. Test the query or model. Explain what the result means.

## Course Snapshot

| | |
| --- | --- |
| **Course** | CSCI 362 — Databases and Data Mining |
| **Institution** | John Jay College of Criminal Justice, CUNY |
| **Instructor** | Avijit Roy |
| **Department** | Mathematics and Computer Science |
| **Current syllabus** | Select CSCI 362 on the [teaching page](https://avijitroy.com/teaching/) |

This repository connects the two major parts of the course: designing, storing, querying, and protecting relational data; and preparing, analyzing, modeling, and communicating findings from data. Materials emphasize executable work, careful interpretation, and the ability to explain each design or analytical decision.

> [!IMPORTANT]
> The current syllabus provides the official course outline and semester framework. **Brightspace is the authority for weekly materials, announcements, assignments, due dates, submissions, grades, feedback, and schedule changes.**

## Start Here

1. Check Brightspace for the current module, instructions, and due dates.
2. Open the matching module folder in this repository.
3. Read the activity instructions before changing any file.
4. Keep an untouched copy of the starter file when one is provided.
5. Complete the activity, test your work, and explain your decisions in plain language.
6. Submit through the method stated on Brightspace; a GitHub link is not a submission unless the assignment explicitly requests one.

The goal is not only to produce a working database, query, notebook, or model. The goal is to understand the data, justify the method, verify the result, and communicate its limitations.

## Module Catalog

| Module | Focus | Materials |
| --- | --- | --- |
| Module 1 | Databases, data, information, and data-modeling fundamentals | [Lecture 1A: Club Spreadsheet Activity](Module%201/Lecture%201/CSCI362_Lecture1A_Club_Spreadsheet_Activity.xlsx) |

Additional SQL scripts, notebooks, sample datasets, labs, and technical examples may be added as the course progresses. Follow the sequence and release guidance posted on Brightspace.

## How the Materials Are Designed

- **Question first:** identify what the database or analysis must help someone understand.
- **Structure before implementation:** define entities, attributes, keys, relationships, constraints, features, and targets before choosing commands or models.
- **Executable work:** keep working spreadsheets, SQL scripts, and notebooks rather than relying only on screenshots.
- **Small tests:** use understandable examples to verify designs, queries, transformations, and predictions.
- **Interpretation:** explain results in plain language instead of reporting output without context.
- **Responsible claims:** document assumptions, data-quality concerns, uncertainty, and limitations.

Examples may prioritize instructional clarity and step-by-step reasoning over production-level complexity. Later modules will combine earlier techniques in larger database and data-mining projects.

## Course Topic Map

The repository may support practice with:

- database, DBMS, schema, instance, and data-independence concepts;
- entity-relationship modeling and ER-to-relational mapping;
- relational schemas, keys, constraints, and referential integrity;
- functional dependencies, decomposition, and normalization;
- PostgreSQL data definition, data modification, and queries;
- joins, grouping, aggregation, subqueries, and analytical SQL;
- transactions, access control, security, indexes, and performance;
- Python, pandas, data cleaning, exploration, and visualization;
- regression, classification, model evaluation, and overfitting; and
- similarity, nearest neighbors, evidence-based interpretation, and communication.

## Repository Layout

```text
.
├── README.md
└── Module 1/
    └── Lecture 1/
        └── CSCI362_Lecture1A_Club_Spreadsheet_Activity.xlsx
```

Module folders may contain:

- guided activities and starter files;
- executable `.sql` scripts;
- `.ipynb` notebooks or `.py` files;
- sample datasets appropriate for public instructional use;
- diagrams, documentation, or reflection prompts; and
- module-specific `README.md` guides as materials expand.

## Tools & Workflow

The course may use the following tools as directed in class or on Brightspace:

- **PostgreSQL** for relational database and SQL work;
- **DBeaver Community** as an optional desktop database client;
- **Google Colab** for browser-based Python notebooks; and
- **Python 3**, including pandas, NumPy, Matplotlib, and scikit-learn as needed.

No paid software is required for the core course workflow. Setup instructions and any browser-accessible alternatives will be provided with the relevant activity.

## Working with Course Files

- Download or clone the repository so that you can edit activity files locally.
- Save working SQL as `.sql` files and Python analysis as `.ipynb` or `.py` files.
- Preserve provided column names, table names, and starter structure unless an activity says otherwise.
- Use meaningful filenames and keep backups of database scripts, notebooks, datasets, and project documentation.
- Before submission, reopen every file and verify that it contains the intended work.
- Never commit passwords, database connection strings, API keys, cloud credentials, or private student information.

## Git and GitHub Practice

This repository publicly distributes supplemental course resources. GitHub is not required for submission unless a specific assignment says otherwise.

If you use Git for your own work:

- commit source files and documentation, not credentials, local database storage, caches, or generated clutter;
- make small commits with descriptive messages;
- review `git status` before committing; and
- confirm whether graded work must remain private before publishing it.

Do not publish assignment solutions, restricted datasets, classmate information, or other content that should remain private. Follow the repository and submission instructions for each activity.

## Academic Use

These materials are provided for learning and review in CSCI 362. Unless explicitly permitted, repository examples and starter materials must not be submitted unchanged as completed homework, project, quiz, or exam solutions.

Students are responsible for understanding and explaining every database design, query, notebook, model, and result they submit. Any permitted outside help, including AI tools, must be disclosed under the course policy and the instructions for the specific activity.

## Useful Links

- [Teaching page and current syllabi](https://avijitroy.com/teaching/)
- [Brightspace](https://brightspace.cuny.edu/)
- [PostgreSQL documentation](https://www.postgresql.org/docs/)
- [DBeaver Community](https://dbeaver.io/)
- [Google Colab](https://colab.research.google.com/)
- [pandas documentation](https://pandas.pydata.org/docs/)
- [scikit-learn documentation](https://scikit-learn.org/stable/)

## About This Repository

This repository is independently maintained by Avijit Roy as a supplemental teaching resource. It may be updated throughout each term and is not an official publication of John Jay College or CUNY.

© Avijit Roy
