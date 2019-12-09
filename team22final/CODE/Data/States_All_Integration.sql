/*
File: States_All_Integration.sql
Author: Fred Sackfield
Date: 11/9/2019

Description: This file documents a portion of our project's data integration process. We've gathered year- and state-level data
from various public data sources, and the goal is to clean, standardize, and combine into one master source/table to use for modeling. 


Import Process:

-First we import all of our tables, most of which are .csv files downloaded from the web. 
-The first table imported is the "master" States_All table, which is our initial dataset found in Kaggle. 
-The subsequent tables all contain year- and state-level data with supplemental factors that we would like to include for modeling. 
	-We are interested in finding all data relevant to state-level education (both predictor and response variables)
	-These supplemental factors can be either directly related to education (e.g. student-teacher ratio or hs drop out rate), or 
	 tangentially related (e.g. poverty rate, food security, state partisanship)
-We use the SQL Server Import Wizard to connect to our source files and import the following tables:
	dbo.States_All
	dbo.States_Demographic
	dbo.States_EF
	dbo.States_Education
	dbo.States_Govt
	dbo.States_Health
	dbo.States_Policy
	dbo.States_OPI

Cleaning Process:


Missing Data Analysis:



Integration Process:


*/

-------------------DATA CLEANING---------------------------

SELECT * FROM dbo.States_Demographic WHERE [year] > 2002

DELETE FROM dbo.States_Demographic WHERE stateno = 8.5 --Done
DELETE FROM dbo.States_Education WHERE stateno = 8.5 --Done
DELETE FROM dbo.States_EF WHERE stateno = 8.5 --Done
DELETE FROM dbo.States_Health WHERE stateno = 8.5 --Done
DELETE FROM dbo.States_Policy WHERE stateno = 8.5 --Done
DELETE FROM dbo.States_OPI WHERE stateno = 8.5 --Done
DELETE FROM dbo.States_Govt WHERE stateno = 8.5 --Done

ALTER TABLE dbo.States_All ALTER COLUMN [YEAR] nvarchar(50) --Done

ALTER TABLE dbo.States_Demographic ALTER COLUMN [year] nvarchar(50) --Done
ALTER TABLE dbo.States_Demographic ALTER COLUMN foreign_born float --Done

ALTER TABLE dbo.States_Education ALTER COLUMN [year] nvarchar(50) --Done
ALTER TABLE dbo.States_Education ALTER COLUMN dropout_rate float --Done
ALTER TABLE dbo.States_Education ALTER COLUMN grad_rate float --Done
ALTER TABLE dbo.States_Education ALTER COLUMN mathscore4th float --Done
ALTER TABLE dbo.States_Education ALTER COLUMN readscore4th float --Done
ALTER TABLE dbo.States_Education ALTER COLUMN twoyear_tuition float --Done
ALTER TABLE dbo.States_Education ALTER COLUMN fouryear_tuition float --Done

ALTER TABLE dbo.States_EF ALTER COLUMN [year] nvarchar(50) --Done
ALTER TABLE dbo.States_EF ALTER COLUMN lotticksales float --Done
ALTER TABLE dbo.States_EF ALTER COLUMN persfree float --Done
ALTER TABLE dbo.States_EF ALTER COLUMN persrank float --Done
ALTER TABLE dbo.States_EF ALTER COLUMN foodinsecure float --Done
ALTER TABLE dbo.States_EF ALTER COLUMN marginallyfoodinsecure float --Done
ALTER TABLE dbo.States_EF ALTER COLUMN verylowfoodsecure float --Done

ALTER TABLE dbo.States_Govt ALTER COLUMN [year] nvarchar(50) --Done

UPDATE dbo.States_Health SET lowinc_children = REPLACE(lowinc_children, ',','') --Done
ALTER TABLE dbo.States_Health ALTER COLUMN [year] nvarchar(50) --Done
ALTER TABLE dbo.States_Health ALTER COLUMN pop_govhealthins float --Done
ALTER TABLE dbo.States_Health ALTER COLUMN pop_nohealthins float --Done
ALTER TABLE dbo.States_Health ALTER COLUMN quality_of_life_rank float --Done
ALTER TABLE dbo.States_Health ALTER COLUMN wellbeing float --Done
ALTER TABLE dbo.States_Health ALTER COLUMN health_rank float --Done
ALTER TABLE dbo.States_Health ALTER COLUMN lowinc_children float --Done

ALTER TABLE dbo.States_OPI ALTER COLUMN [year] nvarchar(50) --Done


ALTER TABLE dbo.States_Policy ALTER COLUMN [year] nvarchar(50) --Done
ALTER TABLE dbo.States_Policy ALTER COLUMN charterschoolslaw int --Done
ALTER TABLE dbo.States_Policy ALTER COLUMN comp_age_lower int --Done
ALTER TABLE dbo.States_Policy ALTER COLUMN comp_age_upper int --Done
ALTER TABLE dbo.States_Policy ALTER COLUMN comp_years int --Done
ALTER TABLE dbo.States_Policy ALTER COLUMN evol_wkns_allowed int --Done
ALTER TABLE dbo.States_Policy ALTER COLUMN frdmn_grade_prvt float --Done
ALTER TABLE dbo.States_Policy ALTER COLUMN homeschool_records_extent int --Done
ALTER TABLE dbo.States_Policy ALTER COLUMN stnd_testing_rqd int --Done
ALTER TABLE dbo.States_Policy ALTER COLUMN teacher_qual_rqd int --Done
ALTER TABLE dbo.States_Policy ALTER COLUMN kind_att_rqd int --Done
ALTER TABLE dbo.States_Policy ALTER COLUMN mand_lic_teach float --Done
ALTER TABLE dbo.States_Policy ALTER COLUMN prvt_curric_control_extent int --Done
ALTER TABLE dbo.States_Policy ALTER COLUMN taxcredit_parents int --Done
ALTER TABLE dbo.States_Policy ALTER COLUMN voucher_law float --Done


ALTER TABLE dbo.States_All ADD STATEYEAR AS [YEAR]+'_'+[STATE] PERSISTED --Done
ALTER TABLE dbo.States_Demographic ADD stateyear AS [year]+'_'+REPLACE([state],' ','_') PERSISTED --Done
ALTER TABLE dbo.States_Education ADD stateyear AS [year]+'_'+REPLACE([state],' ','_') PERSISTED --Done
ALTER TABLE dbo.States_EF ADD stateyear AS [year]+'_'+REPLACE([state],' ','_') PERSISTED --Done
ALTER TABLE dbo.States_Govt ADD stateyear AS [year]+'_'+REPLACE([state],' ','_') PERSISTED --Done
ALTER TABLE dbo.States_Health ADD stateyear AS [year]+'_'+REPLACE([state],' ','_') PERSISTED --Done
ALTER TABLE dbo.States_OPI ADD stateyear AS [year]+'_'+REPLACE([state],' ','_') PERSISTED --Done
ALTER TABLE dbo.States_Policy ADD stateyear AS [year]+'_'+REPLACE([state],' ','_') PERSISTED --Done

--Update gradrate with additional years from NCES 2018 table
UPDATE a SET a.grad_rate = b.gradrate
FROM dbo.States_Education a JOIN dbo.[TEMP_GradRates_10-16] b ON a.stateyear = b.stateyear --Done


--------------------------MISSING DATA ANALYSIS---------------------
-- **Data_Availability table is created in Data_Availability.sql
-- The queries below are for preliminary analysis, but the full availability metrics are in Data_Availability.

--yearcount for all states
SELECT [state], COUNT(*) as yearcount
FROM dbo.States_Demographic 
WHERE [year] > 2002 AND foreign_born IS NOT NULL
GROUP BY [state]
ORDER BY COUNT(*)

--minyearcount 
SELECT MIN(a.yearcount) FROM (
SELECT [state], COUNT(*) as yearcount
FROM dbo.States_Demographic 
WHERE [year] > 2002 AND foreign_born IS NOT NULL
GROUP BY [state]
) a

--maxyearcount
SELECT MAX(a.yearcount) FROM (
SELECT [state], COUNT(*) as yearcount
FROM dbo.States_Demographic 
WHERE [year] > 2002 AND foreign_born IS NOT NULL
GROUP BY [state]
) a

--minyear
SELECT MIN([year]) as minyear
FROM dbo.States_Demographic 
WHERE [year] > 2002 AND foreign_born IS NOT NULL

--maxyear
SELECT MAX([year]) as maxyear
FROM dbo.States_Demographic 
WHERE [year] > 2002 AND foreign_born IS NOT NULL


SELECT * FROM dbo.States_Demographic WHERE [year] > 2002 AND foreign_born IS NOT NULL
ORDER BY [state], [year]

SELECT * FROM dbo.States_Education WHERE [year] > 2002
ORDER BY [state], [year]


-------------------------DATA INTEGRATION-------------------------

