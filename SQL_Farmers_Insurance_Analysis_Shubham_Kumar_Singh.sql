-- Farmers' Insurance Analysis (PMFBY data) in MySQL 8
-- Shubham Kumar Singh
-- Run setup.sql first. Q27 to Q29 change the data, so reload with setup.sql before running this file again.

USE ndap;


-- ----------------------------------------------------------------------------------------------
-- SECTION 1. 
-- SELECT Queries [5 Marks]

-- 	Q1.	Retrieve the names of all states (srcStateName) from the dataset.
-- ###
-- 	[2 Marks]
-- ###
-- TYPE YOUR CODE BELOW >
-- <write your answers in the empty spaces given, the length of solution queries (and the solution writing space) can vary>
SELECT DISTINCT srcStateName
FROM FarmersInsuranceData
ORDER BY srcStateName;

###

-- 	Q2.	Retrieve the total number of farmers covered (TotalFarmersCovered) 
-- 		and the sum insured (SumInsured) for each state (srcStateName), ordered by TotalFarmersCovered in descending order.
-- ###
-- 	[3 Marks]
-- ###
-- TYPE YOUR CODE BELOW >
SELECT
    srcStateName,
    SUM(TotalFarmersCovered) AS total_farmers_covered,
    SUM(SumInsured)          AS total_sum_insured_lakh
FROM FarmersInsuranceData
GROUP BY srcStateName
ORDER BY total_farmers_covered DESC;

-- ###

-- --------------------------------------------------------------------------------------
-- SECTION 2. 
-- Filtering Data (WHERE) [15 Marks]

-- 	Q3.	Retrieve all records where Year is '2020'.
-- ###
-- 	[2 Marks]
-- ###
-- TYPE YOUR CODE BELOW >
-- Assumption: Year holds a text label ('Calendar Year (Jan - Dec), 2020'), so year filters here and below use the numeric srcYear.
SELECT *
FROM FarmersInsuranceData
WHERE srcYear = 2020;

-- ###

-- 	Q4.	Retrieve all rows where the TotalPopulationRural is greater than 1 million and the srcStateName is 'HIMACHAL PRADESH'.
-- ###
-- 	[3 Marks]
-- ###
-- TYPE YOUR CODE BELOW >
SELECT *
FROM FarmersInsuranceData
WHERE srcStateName = 'HIMACHAL PRADESH'
  AND TotalPopulationRural > 1000000;

-- ###

-- 	Q5.	Retrieve the srcStateName, srcDistrictName, and the sum of FarmersPremiumAmount for each district in the year 2018, 
-- 		and display the results ordered by FarmersPremiumAmount in ascending order.
-- ###
-- 	[5 Marks]
-- ###
-- TYPE YOUR CODE BELOW >
SELECT
    srcStateName,
    srcDistrictName,
    SUM(FarmersPremiumAmount) AS total_farmers_premium_lakh
FROM FarmersInsuranceData
WHERE srcYear = 2018
GROUP BY srcStateName, srcDistrictName
ORDER BY total_farmers_premium_lakh ASC, srcStateName, srcDistrictName;

-- ###

-- 	Q6.	Retrieve the total number of farmers covered (TotalFarmersCovered) and the sum of premiums (GrossPremiumAmountToBePaid) for each state (srcStateName) 
-- 		where the insured land area (InsuredLandArea) is greater than 5.0 and the Year is 2018.
-- ###
-- 	[5 Marks]
-- ###
-- TYPE YOUR CODE BELOW >
SELECT
    srcStateName,
    SUM(TotalFarmersCovered)        AS total_farmers_covered,
    SUM(GrossPremiumAmountToBePaid) AS total_gross_premium_lakh
FROM FarmersInsuranceData
WHERE InsuredLandArea > 5.0
  AND srcYear = 2018
GROUP BY srcStateName
ORDER BY total_farmers_covered DESC;

-- ###
-- ------------------------------------------------------------------------------------------------

-- SECTION 3.
-- Aggregation (GROUP BY) [10 marks]

-- 	Q7. 	Calculate the average insured land area (InsuredLandArea) for each year (srcYear).
-- ###
-- 	[3 Marks]
-- ###
-- TYPE YOUR CODE BELOW >
SELECT
    srcYear,
    ROUND(AVG(InsuredLandArea), 2) AS avg_insured_land_area_thousand_ha
FROM FarmersInsuranceData
GROUP BY srcYear
ORDER BY srcYear;

-- ###

-- 	Q8. 	Calculate the total number of farmers covered (TotalFarmersCovered) for each district (srcDistrictName) where Insurance units is greater than 0.
-- ###
-- 	[3 Marks]
-- ###
-- TYPE YOUR CODE BELOW >
-- Assumption: districts are grouped together with their state, because five district names (Bilaspur, Hamirpur and others) exist in two states.
SELECT
    srcStateName,
    srcDistrictName,
    SUM(TotalFarmersCovered) AS total_farmers_covered
FROM FarmersInsuranceData
WHERE InsuranceUnits > 0
GROUP BY srcStateName, srcDistrictName
ORDER BY total_farmers_covered DESC, srcStateName, srcDistrictName;

-- ###

-- 	Q9.	For each state (srcStateName), calculate the total premium amounts (FarmersPremiumAmount, StatePremiumAmount, GOVPremiumAmount) 
-- 		and the total number of farmers covered (TotalFarmersCovered). Only include records where the sum insured (SumInsured) is greater than 500,000 (remember to check for scaling).
-- ###
-- 	[4 Marks]
-- ###
-- TYPE YOUR CODE BELOW >
-- Assumption: SumInsured is in lakh INR (scaling factor 100,000), so 500,000 rupees means SumInsured > 5.
SELECT
    srcStateName,
    SUM(FarmersPremiumAmount) AS total_farmers_premium_lakh,
    SUM(StatePremiumAmount)   AS total_state_premium_lakh,
    SUM(GOVPremiumAmount)     AS total_gov_premium_lakh,
    SUM(TotalFarmersCovered)  AS total_farmers_covered
FROM FarmersInsuranceData
WHERE SumInsured > 5
GROUP BY srcStateName
ORDER BY srcStateName;

-- ###

-- -------------------------------------------------------------------------------------------------
-- SECTION 4.
-- Sorting Data (ORDER BY) [10 Marks]

-- 	Q10.	Retrieve the top 5 districts (srcDistrictName) with the highest TotalPopulation in the year 2020.
-- ###
-- 	[2 Marks]
-- ###
-- TYPE YOUR CODE BELOW >
SELECT
    srcStateName,
    srcDistrictName,
    TotalPopulation
FROM FarmersInsuranceData
WHERE srcYear = 2020
ORDER BY TotalPopulation DESC
LIMIT 5;

-- ###

-- 	Q11.	Retrieve the srcStateName, srcDistrictName, and SumInsured for the 10 districts with the lowest non-zero FarmersPremiumAmount, 
-- 		ordered by insured sum and then the FarmersPremiumAmount.
-- ###
-- 	[3 Marks]
-- ###
-- TYPE YOUR CODE BELOW >
-- Assumption: rows are district-years, so the 10 lowest non-zero premiums are taken first (a district can appear for two years) and then sorted as asked.
SELECT
    srcStateName,
    srcDistrictName,
    SumInsured,
    srcYear,
    FarmersPremiumAmount
FROM (
    SELECT
        srcStateName,
        srcDistrictName,
        SumInsured,
        srcYear,
        FarmersPremiumAmount
    FROM FarmersInsuranceData
    WHERE FarmersPremiumAmount > 0
    ORDER BY FarmersPremiumAmount ASC, SumInsured ASC
    LIMIT 10
) AS lowest_premiums
ORDER BY SumInsured ASC, FarmersPremiumAmount ASC;

###

-- 	Q12. 	Retrieve the top 3 states (srcStateName) along with the year (srcYear) where the ratio of insured farmers (TotalFarmersCovered) to the total population (TotalPopulation) is highest. 
-- 		Sort the results by the ratio in descending order.
-- ###
-- 	[5 Marks]
-- ###
-- TYPE YOUR CODE BELOW >
-- Assumption: read as the top 3 states in each year, ranked on SUM(TotalFarmersCovered) / SUM(TotalPopulation) shown as a percentage; the first 3 rows are also the overall top 3.
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

-- ###

-- -------------------------------------------------------------------------------------------------

-- SECTION 5.
-- String Functions [6 Marks]

-- 	Q13. 	Create StateShortName by retrieving the first 3 characters of the srcStateName for each unique state.
-- ###
-- 	[2 Marks]
-- ###
-- TYPE YOUR CODE BELOW >
SELECT DISTINCT
    srcStateName,
    LEFT(srcStateName, 3) AS StateShortName
FROM FarmersInsuranceData
ORDER BY srcStateName;

-- ###

-- 	Q14. 	Retrieve the srcDistrictName where the district name starts with 'B'.
-- ###
-- 	[2 Marks]
-- ###
-- TYPE YOUR CODE BELOW >
SELECT DISTINCT srcDistrictName
FROM FarmersInsuranceData
WHERE srcDistrictName LIKE 'B%'
ORDER BY srcDistrictName;

-- ###

-- 	Q15. 	Retrieve the srcStateName and srcDistrictName where the district name contains the word 'pur' at the end.
-- ###
-- 	[2 Marks]
-- ###
-- TYPE YOUR CODE BELOW >
SELECT DISTINCT
    srcStateName,
    srcDistrictName
FROM FarmersInsuranceData
WHERE srcDistrictName LIKE '%pur'
ORDER BY srcStateName, srcDistrictName;

-- ###

-- -------------------------------------------------------------------------------------------------

-- SECTION 6.
-- Joins [14 Marks]

-- 	Q16. 	Perform an INNER JOIN between the srcStateName and srcDistrictName columns to retrieve the aggregated FarmersPremiumAmount for districts where the district’s Insurance units for an individual year are greater than 10.
-- ###
-- 	[4 Marks]
-- ###
-- TYPE YOUR CODE BELOW >
-- Assumption: a self-join that pairs each district-year with itself on state, district and year, so only years with more than 10 insurance units are summed and nothing is counted twice.
SELECT
    premiums.srcStateName,
    premiums.srcDistrictName,
    SUM(premiums.FarmersPremiumAmount) AS total_farmers_premium_lakh
FROM FarmersInsuranceData AS premiums
INNER JOIN FarmersInsuranceData AS units
    ON  units.srcStateName    = premiums.srcStateName
    AND units.srcDistrictName = premiums.srcDistrictName
    AND units.srcYear         = premiums.srcYear
WHERE units.InsuranceUnits > 10
GROUP BY premiums.srcStateName, premiums.srcDistrictName
ORDER BY total_farmers_premium_lakh DESC, premiums.srcStateName, premiums.srcDistrictName;

-- ###

-- 	Q17.	Write a query that retrieves srcStateName, srcDistrictName, Year, TotalPopulation for each district and the the highest recorded FarmersPremiumAmount for that district over all available years
-- 		Return only those districts where the highest FarmersPremiumAmount exceeds 20 crores.
-- ###
-- 	[5 Marks]
-- ###
-- TYPE YOUR CODE BELOW >
-- Assumption: 20 crore = 2,000 lakh; Year and TotalPopulation come from the year in which the district's highest premium was recorded.
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

-- Plan check: the peaks table is grouped straight off an ordered scan of uq_state_district_year, and each peak is matched back through idx_farmers_premium.
EXPLAIN FORMAT=TREE
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

-- ###

-- 	Q18.	Perform a LEFT JOIN to combine the total population statistics with the farmers’ data (TotalFarmersCovered, SumInsured) for each district and state. 
-- 		Return the total premium amount (FarmersPremiumAmount) and the average population count for each district aggregated over the years, where the total FarmersPremiumAmount is greater than 100 crores.
-- 		Sort the results by total farmers' premium amount, highest first.
-- ###
-- 	[5 Marks]
-- ###
-- TYPE YOUR CODE BELOW >
-- Assumption: 100 crore = 10,000 lakh; both sides are aggregated per district before the join, so no year is counted twice.
SELECT
    population.srcStateName,
    population.srcDistrictName,
    farmers.total_farmers_covered,
    farmers.total_sum_insured_lakh,
    farmers.total_farmers_premium_lakh,
    population.avg_population
FROM (
    SELECT
        srcStateName,
        srcDistrictName,
        ROUND(AVG(TotalPopulation)) AS avg_population
    FROM FarmersInsuranceData
    GROUP BY srcStateName, srcDistrictName
) AS population
LEFT JOIN (
    SELECT
        srcStateName,
        srcDistrictName,
        SUM(TotalFarmersCovered)  AS total_farmers_covered,
        SUM(SumInsured)           AS total_sum_insured_lakh,
        SUM(FarmersPremiumAmount) AS total_farmers_premium_lakh
    FROM FarmersInsuranceData
    GROUP BY srcStateName, srcDistrictName
) AS farmers
    ON  farmers.srcStateName    = population.srcStateName
    AND farmers.srcDistrictName = population.srcDistrictName
WHERE COALESCE(farmers.total_farmers_premium_lakh, 0) > 10000
ORDER BY farmers.total_farmers_premium_lakh DESC;

-- ###

-- -------------------------------------------------------------------------------------------------

-- SECTION 7.
-- Subqueries [10 Marks]

-- 	Q19.	Write a query to find the districts (srcDistrictName) where the TotalFarmersCovered is greater than the average TotalFarmersCovered across all records.
-- ###
-- 	[2 Marks]
-- ###
-- TYPE YOUR CODE BELOW >
-- Assumption: the comparison is record by record, so a district is listed if any one of its years is above the average.
SELECT DISTINCT
    srcStateName,
    srcDistrictName
FROM FarmersInsuranceData
WHERE TotalFarmersCovered > (
    SELECT AVG(TotalFarmersCovered)
    FROM FarmersInsuranceData
)
ORDER BY srcStateName, srcDistrictName;

-- ###

-- 	Q20.	Write a query to find the srcStateName where the SumInsured is higher than the SumInsured of the district with the highest FarmersPremiumAmount.
-- ###
-- 	[3 Marks]
-- ###
-- TYPE YOUR CODE BELOW >
-- Assumption: states and districts are compared on totals over all years; record by record nothing qualifies, because the top-premium row (Bid, 2019) also has the largest SumInsured.
SELECT
    srcStateName,
    SUM(SumInsured) AS total_sum_insured_lakh
FROM FarmersInsuranceData
GROUP BY srcStateName
HAVING SUM(SumInsured) > (
    SELECT SUM(SumInsured)
    FROM FarmersInsuranceData
    GROUP BY srcStateName, srcDistrictName
    ORDER BY SUM(FarmersPremiumAmount) DESC
    LIMIT 1
)
ORDER BY total_sum_insured_lakh DESC;

-- ###

-- 	Q21.	Write a query to find the srcDistrictName where the FarmersPremiumAmount is higher than the average FarmersPremiumAmount of the state that has the highest TotalPopulation.
-- ###
-- 	[5 Marks]
-- ###
-- TYPE YOUR CODE BELOW >
-- Assumption: TotalPopulation repeats the Census figure every year, so the most populous state is picked within a single year instead of summing across years.
SELECT DISTINCT
    srcStateName,
    srcDistrictName
FROM FarmersInsuranceData
WHERE FarmersPremiumAmount > (
    SELECT AVG(FarmersPremiumAmount)
    FROM FarmersInsuranceData
    WHERE srcStateName = (
        SELECT srcStateName
        FROM FarmersInsuranceData
        GROUP BY srcStateName, srcYear
        ORDER BY SUM(TotalPopulation) DESC
        LIMIT 1
    )
)
ORDER BY srcStateName, srcDistrictName;

-- ###

-- -------------------------------------------------------------------------------------------------

-- SECTION 8.
-- Advanced SQL Functions (Window Functions) [10 Marks]

-- 	Q22.	Use the ROW_NUMBER() function to assign a row number to each record in the dataset ordered by total farmers covered in descending order.
-- ###
-- 	[3 Marks]
-- ###
-- TYPE YOUR CODE BELOW >
SELECT
    ROW_NUMBER() OVER (ORDER BY TotalFarmersCovered DESC, rowID) AS row_num,
    rowID,
    srcYear,
    srcStateName,
    srcDistrictName,
    TotalFarmersCovered
FROM FarmersInsuranceData
ORDER BY row_num;

-- ###

-- 	Q23.	Use the RANK() function to rank the districts (srcDistrictName) based on the SumInsured (descending) and partition by alphabetical srcStateName.
-- ###
-- 	[3 Marks]
-- ###
-- TYPE YOUR CODE BELOW >
-- Assumption: each district is ranked on its SumInsured totalled over all years.
SELECT
    srcStateName,
    srcDistrictName,
    SUM(SumInsured) AS total_sum_insured_lakh,
    RANK() OVER (PARTITION BY srcStateName ORDER BY SUM(SumInsured) DESC) AS sum_insured_rank
FROM FarmersInsuranceData
GROUP BY srcStateName, srcDistrictName
ORDER BY srcStateName, sum_insured_rank, srcDistrictName;

-- ###

-- 	Q24.	Use the SUM() window function to calculate a cumulative sum of FarmersPremiumAmount for each district (srcDistrictName), ordered ascending by the srcYear, partitioned by srcStateName.
-- ###
-- 	[4 Marks]
-- ###
-- TYPE YOUR CODE BELOW >
-- Assumption: the window is partitioned by state and district, so each district gets its own running total (district names repeat across states).
SELECT
    srcStateName,
    srcDistrictName,
    srcYear,
    FarmersPremiumAmount,
    SUM(FarmersPremiumAmount) OVER (
        PARTITION BY srcStateName, srcDistrictName
        ORDER BY srcYear
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_farmers_premium_lakh
FROM FarmersInsuranceData
ORDER BY srcStateName, srcDistrictName, srcYear;

-- ###

-- -------------------------------------------------------------------------------------------------

-- SECTION 9.
-- Data Integrity (Constraints, Foreign Keys) [4 Marks]

-- 	Q25.	Create a table 'districts' with DistrictCode as the primary key and columns for DistrictName and StateCode. 
-- 		Create another table 'states' with StateCode as primary key and column for StateName.
-- ###
-- 	[2 Marks]
-- ###
-- TYPE YOUR CODE BELOW >
DROP TABLE IF EXISTS districts, states;

CREATE TABLE states (
    StateCode SMALLINT    NOT NULL,
    StateName VARCHAR(50) NOT NULL,
    PRIMARY KEY (StateCode),
    UNIQUE KEY uq_states_state_name (StateName)
);

CREATE TABLE districts (
    DistrictCode SMALLINT    NOT NULL,
    DistrictName VARCHAR(50) NOT NULL,
    StateCode    SMALLINT    NOT NULL,
    PRIMARY KEY (DistrictCode)
);

-- ###

-- 	Q26.	Add a foreign key constraint to the districts table that references the StateCode column from a states table.
-- ###
-- 	[2 Marks]
-- ###
-- TYPE YOUR CODE BELOW >
-- A state's code changes flow through to its districts; a state that still has districts cannot be deleted.
ALTER TABLE districts
    ADD CONSTRAINT fk_districts_states
    FOREIGN KEY (StateCode) REFERENCES states (StateCode)
    ON UPDATE CASCADE
    ON DELETE RESTRICT;

-- Load both tables from the main table, states first; every district row is now checked by the foreign key.
INSERT INTO states (StateCode, StateName)
SELECT DISTINCT
    StateCode,
    srcStateName
FROM FarmersInsuranceData;

-- Assumption: 13 DistrictCodes carry more than one name (for example 2021's 'Thanjavur I' and 'Thanjavur II'), so each code keeps its most frequent name, newest year first on ties.
INSERT INTO districts (DistrictCode, DistrictName, StateCode)
SELECT
    DistrictCode,
    srcDistrictName,
    StateCode
FROM (
    SELECT
        DistrictCode,
        srcDistrictName,
        StateCode,
        ROW_NUMBER() OVER (
            PARTITION BY DistrictCode
            ORDER BY COUNT(*) DESC, MAX(srcYear) DESC, srcDistrictName
        ) AS name_rank
    FROM FarmersInsuranceData
    GROUP BY DistrictCode, srcDistrictName, StateCode
) AS ranked_names
WHERE name_rank = 1;

-- Check: 27 states, 555 districts, and every district finds its state.
SELECT
    (SELECT COUNT(*) FROM states)    AS state_rows,
    (SELECT COUNT(*) FROM districts) AS district_rows,
    (SELECT COUNT(*)
     FROM districts
     INNER JOIN states
         ON states.StateCode = districts.StateCode) AS districts_with_state;

-- The constraint at work (left commented out so the script runs end to end):
-- INSERT INTO districts VALUES (999, 'Nowhere', 99);   -- ERROR 1452: no state 99
-- DELETE FROM states WHERE StateCode = 2;              -- ERROR 1451: Himachal Pradesh still has districts

-- ###

-- -------------------------------------------------------------------------------------------------

-- SECTION 10.
-- UPDATE and DELETE [6 Marks]

-- 	Q27.	Update the FarmersPremiumAmount to 500.0 for the record where rowID is 1.
-- ###
-- 	[2 Marks]
-- ###
-- TYPE YOUR CODE BELOW >
UPDATE FarmersInsuranceData
SET FarmersPremiumAmount = 500.0
WHERE rowID = 1;

-- ###

-- 	Q28.	Update the Year to '2021' for all records where srcStateName is 'HIMACHAL PRADESH'.
-- ###
-- 	[2 Marks]
-- ###
-- TYPE YOUR CODE BELOW >
-- Assumption: only the text column Year changes; srcYear and YearCode keep the real year.
UPDATE FarmersInsuranceData
SET Year = '2021'
WHERE srcStateName = 'HIMACHAL PRADESH';

-- ###

-- 	Q29.	Delete all records where the TotalFarmersCovered is less than 10000 and Year is 2020.
-- ###
-- 	[2 Marks]
-- ###
-- TYPE YOUR CODE BELOW >
-- Assumption: as in Q3 the filter uses srcYear, so Himachal Pradesh's 2020 rows still count as 2020 after Q28 relabelled their Year text.
DELETE FROM FarmersInsuranceData
WHERE TotalFarmersCovered < 10000
  AND srcYear = 2020;

-- ###
