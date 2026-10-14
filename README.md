# Farmers' Insurance Analysis (PMFBY) in SQL

Answering 29 questions in MySQL about India's crop insurance scheme, Pradhan Mantri Fasal
Bima Yojana (PMFBY), on 1,870 district-year records from 2018 to 2021.

## Executive summary

Madhya Pradesh (9.15 million farmers covered, summed over 2018 to 2021), Maharashtra
(8.94 million), Uttar Pradesh (7.24 million) and Rajasthan (6.82 million) account for
63.9% of all coverage. Madhya Pradesh also has the largest sum insured, ₹84,132 crore or
a quarter of the total, ahead of Rajasthan at ₹53,635 crore.

Farmers paid ₹5,624 crore of the ₹43,007 crore gross premium, or 13.1%. State governments
paid ₹19,740 crore (45.9%) and the central government ₹17,643 crore (41.0%). The farmers'
share fell every year, from 19.1% in 2018 to 10.6% in 2021, while gross premium rose from
₹7,263 crore to ₹13,119 crore.

Coverage fell from 15.0 million farmers in 2018 to 10.8 million in 2021, and the number
of reporting states dropped from 24 to 20. Andhra Pradesh, Gujarat, Jharkhand and
Telangana report only for 2018 and 2019, and West Bengal only for 2018. Each year, the
farmers covered equal 1.41% to 1.63% of the population of the reporting districts.
The highest state-years are Chhattisgarh in 2021 (4.97%) and Tripura in 2020 (4.68%).

Bid in Maharashtra has more farmers covered than any other district (1.43 million) and
the highest single-year farmers' premium (₹72.4 crore in 2019). Its 2019 record also has
the largest sum insured in the data. Bid, Ujjain and Latur are the only districts where
farmers paid more than ₹100 crore in total.

Karnataka's money columns look broken at source: 736,375 farmers covered against a total
sum insured of ₹3.18 lakh.

The queries behind these figures are in `summary_queries.sql`.

## Assumptions

- Money columns are in lakh rupees (scaling factor 100,000 in `column_description.csv`).
  So 500,000 rupees in Q9 means `SumInsured > 5`, 20 crore in Q17 is 2,000 lakh and
  100 crore in Q18 is 10,000 lakh.
- `Year` is a text label such as "Calendar Year (Jan - Dec), 2020", so every year filter
  uses the numeric `srcYear`, Q3 and Q29 included.
- Five district names (Balrampur, Bilaspur, Hamirpur, Pratapgarh, Raigarh) exist in two
  states, so districts are always grouped together with their state.
- A row is one district in one year. Q11 and Q19 compare rows. Q20 and Q23 use totals
  over all years; row by row, Q20 would return nothing, because the record with the
  highest premium (Bid, 2019) also has the largest sum insured.
- Q12 follows the course brief, which asks for the top 3 states in each year, ranked by
  farmers covered as a percentage of population. Sorted by that figure, the first three
  rows are also the overall top 3 that the question file asks for.
- Q16's INNER JOIN is a self-join on state, district and year, so only years with more
  than 10 insurance units count. Joining on state and district alone repeats each row once
  per year and would put Bid at ₹581 crore instead of ₹145 crore.
- Q17 reports the year and population of each district's peak year.
- `TotalPopulation` repeats a Census figure every year, so Q21 compares states within a
  single year; summing across years would count each district up to four times. Uttar
  Pradesh comes out on top either way.
- Q24's running total is partitioned by state and district.
- 13 district codes carry more than one name (Tamil Nadu's 2021 "I" and "II" splits,
  Assam codes reused in 2021, and a few clashes elsewhere), so a plain `SELECT DISTINCT`
  would break the `districts` primary key. Each code keeps its most frequent name, newest
  year first on ties, which gives 555 districts.
- Q28 changes only the `Year` text. Q29 then deletes 190 rows from 2020, including six
  from Himachal Pradesh and rowID 1, the record Q27 had just updated.

## The data

The course's copy of the data is derived from the PMFBY figures on the National Data and
Analytics Platform (NDAP). `data.csv` has 1,870 rows and 44 columns. Each row is one
district in one year and holds the PMFBY figures (insurance units, farmers covered,
loanee and non-loanee applications, insured area, the three premium parts, gross
premium, sum insured and the farmer mix in percent) next to Census figures for the
district (population by sex and urban or rural, households, land area).

It covers 27 states and union territories and 565 state and district pairs, but not
every state reports every year: 525 rows in 2018, 505 in 2019, 429 in 2020 and 411 in
2021. Money is in lakh rupees (1 lakh = 100,000 rupees, 100 lakh = 1 crore) and
`InsuredLandArea` is in thousand hectares. The summary above converts money to crore.

Blank fields become NULL during the load, through `NULLIF(@x, '')` in `setup.sql`. Only
two groups of columns have blanks. The ten percentage columns are blank in 21 rows, which
are exactly the 21 rows where no farmers were covered (all in Karnataka), so the shares
are undefined there and stay NULL. The Census land-area columns are blank in 2, 28 and 29
rows. Every column the questions filter or aggregate on is complete, and `NOT NULL`
constraints hold it to that, so the aggregates need no `IFNULL` padding. `COALESCE`
handles the outer join in Q18 and `NULLIF` guards the division in Q12.

Karnataka's premiums and sums insured are far too small for the number of farmers it
reports, which is why Karnataka fills the Q11 list and drops out of Q9. `DistrictCode` is
also unreliable as a key (see Assumptions).

## Approach

The 29 questions follow the course's ten sections:

| Section | Questions | What the SQL does |
|---|---|---|
| Select and filter | Q1 to Q6 | `DISTINCT`, `WHERE` on text and numbers, totals per state and per district |
| Aggregation | Q7 to Q9 | `AVG` and `SUM` with `GROUP BY`, the lakh conversion in Q9 |
| Sorting | Q10 to Q12 | `ORDER BY ... LIMIT`, a derived table that picks rows before sorting them (Q11), CTEs with `ROW_NUMBER()` for a top 3 per year (Q12) |
| String functions | Q13 to Q15 | `LEFT()`, `LIKE 'B%'` and `LIKE '%pur'` |
| Joins | Q16 to Q18 | a self-join on the natural key, a join back to a grouped derived table, a `LEFT JOIN` of two district-level aggregates |
| Subqueries | Q19 to Q21 | scalar subqueries in `WHERE` and `HAVING`, nested two deep in Q21 |
| Window functions | Q22 to Q24 | `ROW_NUMBER()`, `RANK()` over grouped totals, a running `SUM()` with an explicit frame |
| Constraints | Q25 and Q26 | primary, unique and foreign keys with `ON UPDATE CASCADE` and `ON DELETE RESTRICT`, filled with `INSERT ... SELECT` |
| Updates and deletes | Q27 to Q29 | keyed `UPDATE` and `DELETE`, kept last so they cannot change earlier answers |

Q12 ranks states inside each year with a window function over a grouped CTE:

```sql
WITH state_year_coverage AS (
    SELECT
        srcStateName,
        srcYear,
        100 * SUM(TotalFarmersCovered) / NULLIF(SUM(TotalPopulation), 0) AS farmers_to_population_pct
    FROM FarmersInsuranceData
    GROUP BY srcStateName, srcYear
),
ranked_states AS (
    SELECT
        srcStateName,
        srcYear,
        farmers_to_population_pct,
        ROW_NUMBER() OVER (PARTITION BY srcYear ORDER BY farmers_to_population_pct DESC, srcStateName) AS rank_in_year
    FROM state_year_coverage
)
SELECT
    srcStateName,
    srcYear,
    farmers_to_population_pct,
    rank_in_year
FROM ranked_states
WHERE rank_in_year <= 3
ORDER BY farmers_to_population_pct DESC;
```

Q17 finds each district's peak premium in a grouped derived table, then joins back to the
base rows to recover the year it happened:

```sql
SELECT
    records.srcStateName,
    records.srcDistrictName,
    records.Year,
    records.TotalPopulation,
    peaks.max_farmers_premium_lakh
FROM FarmersInsuranceData AS records
INNER JOIN (
    SELECT
        srcStateName,
        srcDistrictName,
        MAX(FarmersPremiumAmount) AS max_farmers_premium_lakh
    FROM FarmersInsuranceData
    GROUP BY srcStateName, srcDistrictName
    HAVING MAX(FarmersPremiumAmount) > 2000
) AS peaks
    ON  peaks.srcStateName             = records.srcStateName
    AND peaks.srcDistrictName          = records.srcDistrictName
    AND peaks.max_farmers_premium_lakh = records.FarmersPremiumAmount
ORDER BY peaks.max_farmers_premium_lakh DESC;
```

The table has a primary key on `rowID` and a unique key on (`srcStateName`,
`srcDistrictName`, `srcYear`), which enforces one row per district per year and doubles
as the index for state filters, `DISTINCT` states and the district-level joins. Two more
indexes cover year filters and premium lookups. The `EXPLAIN` in Q17 shows the derived
table grouped straight off the unique key and each peak matched back through
`idx_farmers_premium`. All three data changes in Q27 to Q29 go through an index, so they
also run under MySQL Workbench's safe update mode.

The solution file runs top to bottom on a fresh load with no errors or warnings. As a
cross-check I recomputed every result except the Q25 table definitions in pandas from
the CSV, and they all matched.

## How to run

MySQL 8.0.16 or later (window functions, CTEs and `EXPLAIN FORMAT=TREE`).

```bash
# Allow local file loads on the server (once, needs admin rights)
mysql -u root -p -e "SET GLOBAL local_infile = 1;"

# From the repository root, so the relative path data/data.csv resolves
mysql --local-infile=1 -u root -p < setup.sql
mysql -u root -p < summary_queries.sql
mysql -u root -p < SQL_Farmers_Insurance_Analysis_Shubham_Kumar_Singh.sql
```

The CSV files are course material and are not committed: put `data.csv` and
`column_description.csv` in `data/` first. Q27 to Q29 change the data, so run `setup.sql`
again before a second run. In MySQL Workbench, the load also needs `OPT_LOCAL_INFILE=1`
under the connection's Advanced options and an absolute path to `data.csv` in
`setup.sql`, because Workbench does not start in the repository folder.

## Repository contents

| File | What it is |
|---|---|
| `setup.sql` | Creates the `ndap` schema and `FarmersInsuranceData`, loads the CSV, adds the indexes |
| `SQL_Farmers_Insurance_Analysis_Shubham_Kumar_Singh.sql` | The course question file with all 29 answers |
| `summary_queries.sql` | The queries behind the executive summary |
| `data/` | Where `data.csv` and `column_description.csv` go (not committed) |
| `.gitignore` | Keeps the course data and `.DS_Store` out of git |

---

**Shubham Kumar Singh**, MSc Artificial Intelligence and Computer Science, Northeastern University London

Originally completed as a case study in the upGrad and IIIT Bangalore Data Science Programme.

[LinkedIn](https://linkedin.com/in/shubham-singh-00236a191) · [GitHub](https://github.com/Shubham-afk-del)
