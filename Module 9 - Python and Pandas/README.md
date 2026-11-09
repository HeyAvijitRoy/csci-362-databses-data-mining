# Module 9: Python and pandas for Data Analysis

CSCI 362 · Professor [Avijit Roy](https://avijitroy.com/teaching/)

Module 8 introduced analysis questions, row grain, data quality, and the difference between description and prediction. This module applies those ideas in Python using pandas. You will explore historical bike-sharing records, work through examples, and explain what your summaries can support.

## Learning goals

By the end of this module, you should be able to:

- Use basic Python values, lists, dictionaries, and functions to follow notebook examples.
- Load a CSV into a pandas DataFrame and inspect its rows, columns, types, and missing values.
- Select columns, filter rows, and sort results using pandas.
- Create calculated columns and explain the denominators in rental percentages.
- Summarize groups with observation counts, means, and totals.
- Use `transform` to attach group statistics to original rows and explain the limits of historical comparisons.

## Materials

Keep these files together in the Module 9 folder. Start with this README; the separate `Readme.txt` is the original dataset documentation.

| File | Purpose |
| --- | --- |
| [Module notebook](CSCI362_Module09_Student.ipynb) | Main lesson with concepts, worked examples, six exercises, and written-response spaces |
| [Short reading](Reading.md) | Python and pandas concepts to read before class and review during practice |
| [Lab checklist](Student_Lab.md) | Exercise requirements and the evidence to keep from both meetings |
| [Hourly dataset](hour.csv) | Supplied UCI bike-sharing records used throughout the notebook; keep the filename unchanged |
| [Data provenance and dictionary](Data_Provenance.md) | Attribution, source information, field meanings, and limits on interpretation |
| [Original dataset documentation](Readme.txt) | Unchanged UCI source readme; also describes a daily CSV that is not needed or included here |
| [Local requirements](requirements.txt) | Packages for the optional local Jupyter setup |

## How to work through the module

1. Read Sections 1–4 of the [short reading](Reading.md) before the first class if possible. Review the dataset's grain and dictionary in [Data_Provenance.md](Data_Provenance.md).
2. Open [Google Colab](https://colab.research.google.com/), choose **File → Upload notebook**, and select `CSCI362_Module09_Student.ipynb`. Save your own copy in Drive and connect to a Python runtime. A CPU runtime is enough; Colab requires no package installation for this lesson.
3. Upload `hour.csv` through Colab's folder sidebar. Run the notebook from the top with **Shift+Enter**. Confirm that the file loads as **17,379 rows and 17 columns** before continuing.
4. Follow **predict → run → inspect → practice → explain**. Read the concept, predict the example's result, run the code, and inspect its output and units. Try the exercise, then double-click its **My interpretation** text cell to write your explanation. Use the [lab checklist](Student_Lab.md) to check the requirements.
5. On the first class path, work through selection, calculated columns, summaries, grouping, Exercises 1–4, and the exit ticket. Exercise 4 can continue at the next meeting if needed. Review Sections 5–7 of the short reading before the continuation.
6. On the second class path, restart the kernel/session and run from the top, uploading the CSV again if it is missing. Finish earlier practice, then complete two-key grouping and Exercises 5–6. Export the five requested records to `top_deviations.csv` and save your work as described below.

The notebook contains the lesson and practice; separate slides are unnecessary. Its detailed “What this code does” notes are references to revisit after each example. You do not need to memorize the file-search code. Check Brightspace for the current meeting schedule.

## Readings and references

### Start with the short reading and notebook

Read [Reading.md](Reading.md) for the connection from SQL results to DataFrames, essential Python syntax, notebook state, selection, denominators, aggregation, transformation, and responsible interpretation. Sections 1–4 prepare you for the first meeting; Sections 5–7 support summaries and the continuation.

Then work through the notebook alongside the [lab checklist](Student_Lab.md). The notebook provides the detailed explanations and runnable examples. Use [Data_Provenance.md](Data_Provenance.md) for the classroom dictionary, including the documented differences between current UCI metadata and the original source readme.

### Supporting documentation

The [optional official references](Reading.md#optional-official-references) in the short reading provide supporting detail. Use them selectively; you do not need to read every page before class.

| Reference | What to focus on | Connection to the module |
| --- | --- | --- |
| Python tutorial: introduction | Numbers, strings, lists, and indexing | Follow the Python examples before working with columns |
| pandas introductory tutorials | Reading tabular data, inspecting a DataFrame, and creating columns | Load the CSV and understand the worked examples |
| pandas selection guide | `loc`, `iloc`, Boolean conditions, and column selection | Choose the records and fields needed for a question |
| pandas groupby guide | Aggregation and transformation | Distinguish a group summary from a baseline aligned with original rows |
| Colab introductory notebook | Code and text cells, running code, and saving notebooks | Work in order and keep a reproducible notebook |

### Ideas to carry into the activities

**The meaning of one row still matters.** In this file, a row represents one observed system date/hour. Counting rows and summing rental counts answer different questions. A missing date/hour is not automatically a zero-rental hour.

**A percentage needs a stated denominator.** An overall rental share and a mean of hourly shares weight observations differently. State the question and denominator before interpreting a percentage. Rental counts do not identify unique people.

**Aggregation and transformation return different shapes.** Aggregation creates a summary for each group. Transformation repeats a group's statistic beside its original rows. Choose the operation based on whether you need a smaller summary or context for individual records.

**Historical comparisons have limits.** These records describe system-wide activity in 2011–2012. Group differences do not establish causes, and large deviations from a historical mean do not by themselves prove anomalies or validate a forecast.

### Check your understanding

After reading, explain:

1. What does one row represent, and how does counting rows differ from summing `cnt`?
2. Why might an overall rental percentage differ from the mean of hourly percentages?
3. When would you choose `transform` instead of aggregation?
4. Why does comparing working-day groups not establish that working-day status causes a difference in rentals?

## Save your work

Before finishing, restart the kernel/session and run all cells in order. A restart clears variables; disconnecting and deleting the runtime also removes uploaded files. If `hour.csv` is missing, upload it again.

Download your completed notebook with outputs using **File → Download → Download .ipynb**. After Exercise 6, download `top_deviations.csv` through the folder sidebar's file menu. Confirm that the notebook contains your code and written interpretations and that the CSV has five rows and the five requested columns, without an extra index column. Colab's temporary files are not saved just because the notebook is in Drive.

Brightspace provides official submission directions, deadlines, and grading information. The files here do not create a new graded assignment. If AI or external help is permitted and used, disclose it according to the syllabus and be ready to explain every line.

## Optional local setup

If you use Jupyter locally, run these commands from the Module 9 folder:

```powershell
python -m pip install -r requirements.txt
python -m jupyter lab
```

Open `CSCI362_Module09_Student.ipynb` and select a Python kernel with those packages installed. Keep `hour.csv` beside the notebook and run cells in order.
