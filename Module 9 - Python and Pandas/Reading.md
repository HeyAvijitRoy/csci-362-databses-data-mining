# Python and pandas: short reading
CSCI 362 · Module 9 · November 9 and 11, 2026

## 1. From SQL results to DataFrames
A database stores and manages related tables. A pandas DataFrame is an in-memory labeled table used for analysis. Reading a CSV does not give it database constraints, a primary key, or a server. Know the grain before counting: in our file, a row is one observed system date/hour. Summing `cnt` counts rentals; counting rows counts observed hours.

## 2. Python you need
`x = 5` assigns a value; `x == 5` compares it. Strings have quotes. A list such as `[7, 8, 9]` is ordered and indexed from zero. A dictionary such as `{'hr': 8}` maps names to values. Indentation groups statements under `if`, `for`, and `def`. A function takes arguments and can return a result. `import pandas as pd` gives the library the short name `pd`. A method is called on an object: `df.head()`.

## 3. A notebook is a sequence of shared state
Text cells explain; code cells execute. A variable exists only after its defining code runs in the current runtime. Running cells out of order can hide dependencies. Restart and run all cells to check the saved analysis. Colab runtime files are temporary; keep the notebook and original CSV outside the runtime. CPU is enough for this lesson.

## 4. Load, inspect, select
`pd.read_csv('hour.csv', parse_dates=['dteday'])` loads the supplied CSV. `shape`, `head()`, `info()`, and `isna().sum()` reveal structure. A numeric dtype does not prove a variable is a quantity: season codes are categories. `df['cnt']` is a Series; `df[['hr', 'cnt']]` is a DataFrame. `iloc` chooses positions; `loc` chooses labels or a Boolean mask. Combine column conditions using `&`, `|`, and parentheses, not `and`/`or`. Use `.isin([7, 8, 9])` for membership.

## 5. Summaries need denominators
`sum()` counts all rentals; `mean()` measures average rentals per observed hour. A mean gives each observed row equal weight. The ratio of totals and the mean of per-hour ratios answer different questions. For the overall registered-user share, divide total registered rentals by total rentals. The file has no rider identifiers, so neither quantity is a percentage of unique people. Missing hours are not automatically zero-rental hours.

## 6. Aggregate or transform?
`df.groupby('hr')['cnt'].mean()` reduces the table to an average for each hour. `df.groupby('hr')['cnt'].transform('mean')` returns a Series aligned with all original rows, repeating each hour's mean for its members. Subtract this baseline from `cnt` to compare each record with that hour's historical average. A baseline computed on the full dataset describes that dataset; it is not a validated prediction.

## 7. Interpret responsibly
Report units, grain, timeframe, and group sizes. Associations do not establish causes. Workingday=0 includes both weekends and holidays. Weather and seasonal fields are codes or normalized measures, not all raw physical units. System-level counts cannot support station-specific claims. For prediction later, casual and registered counts would leak the answer because their sum is cnt.

## Optional official references
- Python tutorial, introduction: https://docs.python.org/3/tutorial/introduction.html
- pandas introductory tutorials: https://pandas.pydata.org/docs/getting_started/intro_tutorials/
- pandas selection: https://pandas.pydata.org/docs/user_guide/indexing.html
- pandas groupby and transformation: https://pandas.pydata.org/docs/user_guide/groupby.html
- Colab introductory notebook: https://colab.research.google.com/notebooks/intro.ipynb
- Dataset and attribution: https://doi.org/10.24432/C5W894
