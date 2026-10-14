-- Farmers' Insurance Analysis (PMFBY): schema, table, data load and indexes.
-- Run it from the repository root so the relative path to data/data.csv resolves:
--     mysql --local-infile=1 -u root -p < setup.sql
-- The server has to allow local loads as well: SET GLOBAL local_infile = 1;

CREATE SCHEMA IF NOT EXISTS ndap;
USE ndap;

DROP TABLE IF EXISTS FarmersInsuranceData;

-- Column names follow the course starter. Money columns are in lakh INR
-- (1 lakh = 100,000 rupees) and InsuredLandArea is in thousand hectares,
-- as listed in data/column_description.csv.
CREATE TABLE FarmersInsuranceData (
    rowID                           INT           NOT NULL,
    srcYear                         SMALLINT      NOT NULL,
    srcStateName                    VARCHAR(50)   NOT NULL,
    srcDistrictName                 VARCHAR(50)   NOT NULL,
    InsuranceUnits                  INT           NOT NULL,
    TotalFarmersCovered             INT           NOT NULL,
    ApplicationsLoaneeFarmers       INT           NOT NULL,
    ApplicationsNonLoaneeFarmers    INT           NOT NULL,
    InsuredLandArea                 DECIMAL(8,2)  NOT NULL,
    FarmersPremiumAmount            DECIMAL(12,4) NOT NULL,
    StatePremiumAmount              DECIMAL(12,4) NOT NULL,
    GOVPremiumAmount                DECIMAL(12,4) NOT NULL,
    GrossPremiumAmountToBePaid      DECIMAL(12,4) NOT NULL,
    SumInsured                      DECIMAL(12,4) NOT NULL,
    PercentageMaleFarmersCovered    DECIMAL(5,2),
    PercentageFemaleFarmersCovered  DECIMAL(5,2),
    PercentageOthersCovered         DECIMAL(5,2),
    PercentageSCFarmersCovered      DECIMAL(5,2),
    PercentageSTFarmersCovered      DECIMAL(5,2),
    PercentageOBCFarmersCovered     DECIMAL(5,2),
    PercentageGeneralFarmersCovered DECIMAL(5,2),
    PercentageMarginalFarmers       DECIMAL(5,2),
    PercentageSmallFarmers          DECIMAL(5,2),
    PercentageOtherFarmers          DECIMAL(5,2),
    YearCode                        SMALLINT      NOT NULL,
    Year                            VARCHAR(40)   NOT NULL,  -- text label, e.g. 'Calendar Year (Jan - Dec), 2020'
    Country                         VARCHAR(20)   NOT NULL,
    StateCode                       SMALLINT      NOT NULL,
    DistrictCode                    SMALLINT      NOT NULL,
    TotalPopulation                 INT           NOT NULL,
    TotalPopulationUrban            INT           NOT NULL,
    TotalPopulationRural            INT           NOT NULL,
    TotalPopulationMale             INT           NOT NULL,
    TotalPopulationMaleUrban        INT           NOT NULL,
    TotalPopulationMaleRural        INT           NOT NULL,
    TotalPopulationFemale           INT           NOT NULL,
    TotalPopulationFemaleUrban      INT           NOT NULL,
    TotalPopulationFemaleRural      INT           NOT NULL,
    NumberOfHouseholds              INT           NOT NULL,
    NumberOfHouseholdsUrban         INT           NOT NULL,
    NumberOfHouseholdsRural         INT           NOT NULL,
    LandAreaUrban                   DOUBLE,                  -- census areas in hectares, stored as given
    LandAreaRural                   DOUBLE,
    LandArea                        DOUBLE,
    PRIMARY KEY (rowID),
    UNIQUE KEY uq_state_district_year (srcStateName, srcDistrictName, srcYear)  -- one row per district per year
);

-- Blank fields arrive as '' and NULLIF turns them into NULL. Only the
-- percentage and land-area columns have blanks; every other column is complete.
-- The file has Windows line endings, so the last field also loses its '\r'.
LOAD DATA LOCAL INFILE 'data/data.csv'
INTO TABLE FarmersInsuranceData
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(rowID, srcYear, srcStateName, srcDistrictName, InsuranceUnits, TotalFarmersCovered,
 ApplicationsLoaneeFarmers, ApplicationsNonLoaneeFarmers, InsuredLandArea,
 FarmersPremiumAmount, StatePremiumAmount, GOVPremiumAmount,
 GrossPremiumAmountToBePaid, SumInsured,
 @pct_male, @pct_female, @pct_others, @pct_sc, @pct_st, @pct_obc, @pct_general,
 @pct_marginal, @pct_small, @pct_other_farmers,
 YearCode, Year, Country, StateCode, DistrictCode,
 TotalPopulation, TotalPopulationUrban, TotalPopulationRural,
 TotalPopulationMale, TotalPopulationMaleUrban, TotalPopulationMaleRural,
 TotalPopulationFemale, TotalPopulationFemaleUrban, TotalPopulationFemaleRural,
 NumberOfHouseholds, NumberOfHouseholdsUrban, NumberOfHouseholdsRural,
 @land_area_urban, @land_area_rural, @land_area)
SET PercentageMaleFarmersCovered    = NULLIF(@pct_male, ''),
    PercentageFemaleFarmersCovered  = NULLIF(@pct_female, ''),
    PercentageOthersCovered         = NULLIF(@pct_others, ''),
    PercentageSCFarmersCovered      = NULLIF(@pct_sc, ''),
    PercentageSTFarmersCovered      = NULLIF(@pct_st, ''),
    PercentageOBCFarmersCovered     = NULLIF(@pct_obc, ''),
    PercentageGeneralFarmersCovered = NULLIF(@pct_general, ''),
    PercentageMarginalFarmers       = NULLIF(@pct_marginal, ''),
    PercentageSmallFarmers          = NULLIF(@pct_small, ''),
    PercentageOtherFarmers          = NULLIF(@pct_other_farmers, ''),
    LandAreaUrban                   = NULLIF(@land_area_urban, ''),
    LandAreaRural                   = NULLIF(@land_area_rural, ''),
    LandArea                        = NULLIF(TRIM(TRAILING '\r' FROM @land_area), '');

SHOW WARNINGS;

-- Secondary indexes, built after the bulk load. The unique key above already
-- serves the state filters (Q4, Q21, Q28), DISTINCT states (Q1) and the
-- district-level joins in Q16 and Q17.
CREATE INDEX idx_src_year        ON FarmersInsuranceData (srcYear);               -- year filters: Q3, Q5, Q6, Q10, Q29
CREATE INDEX idx_farmers_premium ON FarmersInsuranceData (FarmersPremiumAmount);  -- Q17 matches each peak premium back to its row

-- Expect 1,870 rows: 21 without the percentage breakdown and 29 without LandArea.
SELECT
    COUNT(*)                                  AS rows_loaded,
    SUM(PercentageMaleFarmersCovered IS NULL) AS rows_without_percentages,
    SUM(LandArea IS NULL)                     AS rows_without_land_area
FROM FarmersInsuranceData;
