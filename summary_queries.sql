-- Queries behind the numbers in the README's executive summary. Run after setup.sql, before the solution file changes the data.

USE ndap;

-- Farmers covered per state over 2018 to 2021 (9.15, 8.94, 7.24 and 6.82 million); the fourth running share is the top-4 share (63.9%)
SELECT
    srcStateName,
    ROUND(SUM(TotalFarmersCovered) / 1000000, 2) AS farmers_covered_million,
    ROUND(100 * SUM(SUM(TotalFarmersCovered)) OVER (ORDER BY SUM(TotalFarmersCovered) DESC ROWS UNBOUNDED PRECEDING)
              / SUM(SUM(TotalFarmersCovered)) OVER (), 1) AS running_share_pct
FROM FarmersInsuranceData
GROUP BY srcStateName
ORDER BY SUM(TotalFarmersCovered) DESC
LIMIT 4;

-- Largest sums insured: Madhya Pradesh (84,132 crore, a quarter of the total) and Rajasthan (53,635 crore)
SELECT
    srcStateName,
    ROUND(SUM(SumInsured) / 100) AS sum_insured_crore,
    ROUND(100 * SUM(SumInsured) / SUM(SUM(SumInsured)) OVER (), 1) AS share_of_total_pct
FROM FarmersInsuranceData
GROUP BY srcStateName
ORDER BY SUM(SumInsured) DESC
LIMIT 2;

-- Premium split: gross 43,007 crore; farmers 5,624 (13.1%), states 19,740 (45.9%), centre 17,643 crore (41.0%)
SELECT
    ROUND(SUM(GrossPremiumAmountToBePaid) / 100) AS gross_premium_crore,
    ROUND(SUM(FarmersPremiumAmount) / 100)       AS farmers_crore,
    ROUND(SUM(StatePremiumAmount) / 100)         AS states_crore,
    ROUND(SUM(GOVPremiumAmount) / 100)           AS centre_crore,
    ROUND(100 * SUM(FarmersPremiumAmount) / SUM(GrossPremiumAmountToBePaid), 1) AS farmers_pct,
    ROUND(100 * SUM(StatePremiumAmount)   / SUM(GrossPremiumAmountToBePaid), 1) AS states_pct,
    ROUND(100 * SUM(GOVPremiumAmount)     / SUM(GrossPremiumAmountToBePaid), 1) AS centre_pct
FROM FarmersInsuranceData;

-- Per year: rows (525, 505, 429, 411), states reporting (24 to 20), farmers covered (15.0 to 10.8 million),
-- gross premium (7,263 to 13,119 crore), farmers' share of premium (19.1% to 10.6%), coverage of population (1.41% to 1.63%)
SELECT
    srcYear,
    COUNT(*)                                       AS district_rows,
    COUNT(DISTINCT srcStateName)                   AS states_reporting,
    ROUND(SUM(TotalFarmersCovered) / 1000000, 1)   AS farmers_covered_million,
    ROUND(SUM(GrossPremiumAmountToBePaid) / 100)   AS gross_premium_crore,
    ROUND(100 * SUM(FarmersPremiumAmount) / SUM(GrossPremiumAmountToBePaid), 1) AS farmers_share_pct,
    ROUND(100 * SUM(TotalFarmersCovered) / SUM(TotalPopulation), 2)             AS coverage_pct_of_population
FROM FarmersInsuranceData
GROUP BY srcYear
ORDER BY srcYear;

-- States that report only some years (Andhra Pradesh, Gujarat, Jharkhand and Telangana 2018 and 2019; West Bengal 2018)
SELECT
    srcStateName,
    GROUP_CONCAT(DISTINCT srcYear ORDER BY srcYear) AS years_reported
FROM FarmersInsuranceData
GROUP BY srcStateName
HAVING COUNT(DISTINCT srcYear) < 4
ORDER BY srcStateName;

-- Highest state-years for farmers covered as a share of population (Chhattisgarh 2021 4.97%, Tripura 2020 4.68%)
SELECT
    srcStateName,
    srcYear,
    ROUND(100 * SUM(TotalFarmersCovered) / SUM(TotalPopulation), 2) AS coverage_pct_of_population
FROM FarmersInsuranceData
GROUP BY srcStateName, srcYear
ORDER BY SUM(TotalFarmersCovered) / SUM(TotalPopulation) DESC
LIMIT 2;

-- Districts with the most farmers covered (Bid first, 1.43 million)
SELECT
    srcStateName,
    srcDistrictName,
    ROUND(SUM(TotalFarmersCovered) / 1000000, 2) AS farmers_covered_million
FROM FarmersInsuranceData
GROUP BY srcStateName, srcDistrictName
ORDER BY SUM(TotalFarmersCovered) DESC
LIMIT 3;

-- The record with the highest single-year farmers' premium (Bid, 2019, 72.4 crore) also has the largest sum insured
SELECT
    srcStateName,
    srcDistrictName,
    srcYear,
    ROUND(FarmersPremiumAmount / 100, 1) AS farmers_premium_crore,
    SumInsured = (SELECT MAX(SumInsured) FROM FarmersInsuranceData) AS has_largest_sum_insured
FROM FarmersInsuranceData
WHERE FarmersPremiumAmount = (SELECT MAX(FarmersPremiumAmount) FROM FarmersInsuranceData);

-- Districts where farmers paid more than 100 crore (10,000 lakh) in total: Bid, Ujjain and Latur
SELECT
    srcStateName,
    srcDistrictName,
    ROUND(SUM(FarmersPremiumAmount) / 100, 1) AS farmers_premium_crore
FROM FarmersInsuranceData
GROUP BY srcStateName, srcDistrictName
HAVING SUM(FarmersPremiumAmount) > 10000
ORDER BY SUM(FarmersPremiumAmount) DESC;

-- Karnataka: 736,375 farmers covered against a total sum insured of 3.18 lakh
SELECT
    SUM(TotalFarmersCovered)  AS farmers_covered,
    ROUND(SUM(SumInsured), 2) AS sum_insured_lakh
FROM FarmersInsuranceData
WHERE srcStateName = 'KARNATAKA';

-- The data section: 1,870 rows, 44 columns, 27 states and union territories, 565 state and district pairs
SELECT
    COUNT(*) AS table_rows,
    (SELECT COUNT(*)
     FROM INFORMATION_SCHEMA.COLUMNS
     WHERE TABLE_SCHEMA = 'ndap'
       AND TABLE_NAME = 'FarmersInsuranceData') AS table_columns,
    COUNT(DISTINCT srcStateName)                  AS states,
    COUNT(DISTINCT srcStateName, srcDistrictName) AS state_district_pairs
FROM FarmersInsuranceData;
