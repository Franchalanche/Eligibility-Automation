SELECT TOP (1000) [Contract]
      ,[Member_ID]
      ,[Relationship_ID]
      ,[New_Relationship]
      ,[First_Name]
      ,[Last_Name]
      ,[Email]
      ,[Main_Phone]
      ,[Street_Address]
      ,[Address_2]
      ,[City]
      ,[State]
      ,[Zip]
      ,[Date_of_Birth]
      ,[Coverage_Start_Date]
      ,[Coverage_End_Date]
      ,[Gender]
      ,[Active_Indicator]
      ,[Record_Type]
      ,[Source_Table]
      ,[File_Name]
      ,[File_Size]
      ,[IS_CreatedDate]
      ,[File_Name_Date]
      ,[File_Name_Date_CLEANED]
      ,[Raw_File_TimeStamp]
      ,[Chosen_Date]
      ,[Chosen_Date_Year_Month]
      ,[Month_Order]
      ,[Order_Desc]
      ,[Table_Type]
  FROM [WorkBench].[dbo].[Eligibility_All_RAW]

  select distinct [Active_Indicator]
    FROM [WorkBench].[dbo].[Eligibility_All_RAW]
order by [Active_Indicator]

  select distinct Contract, [Active_Indicator], count(*) as [Row_Count]
    FROM [WorkBench].[dbo].[Eligibility_All_RAW]
group by Contract, [Active_Indicator]
order by Contract, [Active_Indicator]
;

drop table if exists 
  select distinct 
	Contract
	, [Active_Indicator]
	, Coverage_End_Date
	, Chosen_Date
	, datediff(day,Chosen_Date,Coverage_End_Date) as End_Date_MINUS_Chosen
	, count(*) as [Row_Count]
    FROM [WorkBench].[dbo].[Eligibility_All_RAW]
group by Contract, [Active_Indicator], Coverage_End_Date, Chosen_Date
order by Contract, [Active_Indicator], Coverage_End_Date, Chosen_Date
;

  SELECT --TOP (1000)
	   DISTINCT
	  -- 
	  [Contract]
     -- ,	 [Member_ID]
      --	  ,	  [Coverage_Start_Date]
     -- 
	 , Chosen_Date
	 ,	  [Coverage_End_Date]
      ,[Active_Indicator]
	  , datediff(day,Chosen_Date,[Coverage_End_Date]) as [Expired Already?]
	  , case when datediff(day,Chosen_Date,[Coverage_End_Date])  < 0 then 'Expired' ELSE '' end as Status
	  , COUNT(*) AS [Count]
  FROM [WorkBench].[dbo].[Eligibility_All_RAW]
  GROUP BY 	 --  
  [Contract]
     -- ,[Member_ID]
      --	  ,	  [Coverage_Start_Date]     
	 , Chosen_Date
	  ,	  [Coverage_End_Date]
      ,[Active_Indicator]


select distinct 
[Active_Indicator], count(*) as [Count]
  FROM [WorkBench].[dbo].[Eligibility_All_RAW]
  WhERE Contract not like '%banc%'
group by [Active_Indicator]
;

select DISTINCT CONTRACT
  FROM [WorkBench].[dbo].[Eligibility_All_RAW]
  WhERE Contract not like '%banc%'
AND [Active_Indicator] IN ('P','PT')
;

with total as
(
select distinct 
Contract, count(*) as [TotalCount]
  FROM [WorkBench].[dbo].[Eligibility_All_RAW]
  WhERE Contract not like '%banc%'
group by Contract
)
--,
--contract_summary as
--(
select distinct 
e.Contract
--, count(e.Contract) as Contract_Lines
, [Active_Indicator]
, count(*) as [Count]
, count(*)*1.0/t.TotalCount*1.0 as [Percent]
  FROM [WorkBench].[dbo].[Eligibility_All_RAW] e
 left JOIN total t
	on e.Contract = t.Contract
  WhERE e.Contract not like '%banc%'
group by e.Contract, [Active_Indicator], t.TotalCount
--
order by e.Contract, [Active_Indicator];
--),
-- contract_lines as 
-- (
--	select contract, count(*) as Contract_Lines
--	FROM contract_summary
--	group by contract
-- )
-- select cs.*, cl.Contract_Lines
-- FROM contract_summary cs
--left join contract_lines cl
--	on cs.contract = cl.contract
--;

/*clients without the active indicator:
BRADLEY 
, CAMBIA
, Disney Fidelity Dependents
, Global Health Labs-Premier
, Gulliver
, Hertz-UMR-Premier
, Highmark Employees-Highmark-Premier
, iHeart Media-Trustmark-Premier
, iHeart Media-UMR-Premier
, Isuzu
, JBSS-John B Sanfilippo & Son-Premier
, Jupiter Medical Center-BCBS-SC-Premier
, Jupiter Medical Center-UHC-Premier
, Loeb & Loeb
, Macmillan-Anthem-Premier
, New Mountain
, Sage
, United Rentals
, University of California-BS California-Premier
, University of Colorado
, Warner Music Group-Cigna-Premier
*/

/*LOOK INTO:
Magic Leap-UMR-Premier - 67% NULL
marsh mclennan - 98.7% NULL
Tractor Supply Company-UHC-Premier - 47% NULL
WPP Premier - 36% NULL
*/

/*ACTIVE INDICATORS TO LOOK FOR: 
A
Active
FT
PT
Yes
*/

--SELECT * 
--  FROM [WorkBench].[dbo].[Eligibility_All_RAW]
--WhERE ([Active_Indicator] LIKE 'bLUE%' 
--OR [Active_Indicator] LIKE 'C%' 
--OR [Active_Indicator] LIKE 'u%')
--and Contract not like '%banc%'
--;


--SELECT DISTINCT CONTRACT
--  FROM [WorkBench].[dbo].[Eligibility_All_RAW]
--WhERE ([Active_Indicator] LIKE 'bLUE%' 
--OR [Active_Indicator] LIKE 'C%' 
--OR [Active_Indicator] LIKE 'u%')
--and Contract not like '%banc%'
--;

----SELECT * FROM DLDB.DBO.DL_DW_LUFAXCONTRACT
----WHERE CONTRACTDESC LIKE '%BAKER DONEL%'

--SELECT 
----*
--distinct
--contractdesc
--, ACTIVE
--, CONTRACT_TERM_DT
--, TERMED_OUT
--FROM DLDB.DBO.DL_DW_LUFAXCONTRACT
--WHERE CONTRACTDESC LIKE '%BAKER DONEL%'
--	or CONTRACTDESC LIKE '%banc of calif%' 
--	or CONTRACTDESC LIKE '%borgwarner%' 
--	or CONTRACTDESC LIKE '%hospital for special%' 
--	or CONTRACTDESC LIKE '%iheart%' 
--	or CONTRACTDESC LIKE '%lurie%' 
--	or CONTRACTDESC LIKE '%marsh%' 
--	or CONTRACTDESC LIKE '%mercedes%' 
--	or CONTRACTDESC LIKE '%prudential%' 
--	or CONTRACTDESC LIKE '%spokane%' 
--	or CONTRACTDESC LIKE '%trane%' 
--	or CONTRACTDESC LIKE '%wpp%' 
--order by  ContractDESC, Active
--;
--select top 100 *  FROM Eligibility_Table_Identifiers_RAW

--SELECT cONTRACT
--	, [Full_Table_Name]
--	, [Active Indicator Identifier]
--FROM Eligibility_Table_Identifiers_RAW
--WHERE CONTRACT LIKE '%BAKER DONEL%'
--	or CONTRACT LIKE '%banc of calif%' 
--	or CONTRACT LIKE '%borgwarner%' 
--	or CONTRACT LIKE '%hospital for special%' 
--	or CONTRACT LIKE '%iheart%' 
--	or CONTRACT LIKE '%lurie%' 
--	or CONTRACT LIKE '%marsh%' 
--	or CONTRACT LIKE '%mercedes%' 
--	or CONTRACT LIKE '%prudential%' 
--	or CONTRACT LIKE '%spokane%' 
--	or CONTRACT LIKE '%trane%' 
--	or CONTRACT LIKE '%wpp%' 


--SELECT TOP 5 * FROM [PRODELGBLTY1].[PREMIER_Eligibility_Staging].dbo.[Baker_Donelson_Premier_Rawfile]
--SELECT TOP 5 * FROM [PRODELGBLTY1].[PREMIER_Eligibility_Staging].dbo.[BANC_OF_CALIFORNIA_RAWFILE]
--SELECT TOP 5 * FROM [PRODELGBLTY1].[PREMIER_Eligibility_Staging].dbo.[BorgWarner_PREMIER_RAWFILE]
--SELECT TOP 5 * FROM [PRODELGBLTY1].[PREMIER_Eligibility_Staging].dbo.[Hospital_for_Special_Surgery_PREMIER_RAWFILE]
--SELECT TOP 5 * FROM [PRODELGBLTY1].[PREMIER_Eligibility_Staging].dbo.[Iheart_Meritian_Rawfile]
--SELECT TOP 5 * FROM [PRODELGBLTY1].[PREMIER_Eligibility_Staging].dbo.[Iheart_Trustmark_Rawfile]
--SELECT TOP 5 * FROM [PRODELGBLTY1].[PREMIER_Eligibility_Staging].dbo.[IHEART_UMR_RAWFILE]
--SELECT TOP 5 * FROM [PRODELGBLTY1].[PREMIER_Eligibility_Staging].dbo.[LURIE_PREMIER_RAWFILE]
--SELECT TOP 5 * FROM [PRODELGBLTY1].[PREMIER_Eligibility_Staging].dbo.[MARSH_MCLENNAN_RAWFILE]
--SELECT TOP 5 * FROM [PRODELGBLTY1].[PREMIER_Eligibility_Staging].dbo.[MercedesBenz_RAWFILE]
--SELECT TOP 5 * FROM [PRODELGBLTY1].[PREMIER_Eligibility_Staging].dbo.[SPOKANE_RAWFILE]
--SELECT TOP 5 * FROM [PRODELGBLTY1].[PREMIER_Eligibility_Staging].dbo.[TRANE_RAWFILE]
--SELECT TOP 5 * FROM [PRODELGBLTY1].[PREMIER_Eligibility_Staging].dbo.[WPP_PREMIER_RAWFILE]
--SELECT TOP 5 * FROM [PRODELGBLTY1].[PREMIER_Eligibility_Staging].dbo.[Xo_health_RAWFILE]

--/*EXISTING FILE DATA IS MESSY, PROBLEM #1. TERMED BANC OF CA HAS A LOT OF HP DATA IN ADDITION TO 'A' for 'ACTIVE' INDICATORS*/
--SELECT distinct benefit_status_code FROM [PRODELGBLTY1].[PREMIER_Eligibility_Staging].dbo.[Baker_Donelson_Premier_Rawfile]
--SELECT distinct benefit_status_code FROM [PRODELGBLTY1].[PREMIER_Eligibility_Staging].dbo.[BANC_OF_CALIFORNIA_RAWFILE]
--SELECT distinct benefit_status_code FROM [PRODELGBLTY1].[PREMIER_Eligibility_Staging].dbo.[BorgWarner_PREMIER_RAWFILE]
--SELECT  distinct benefit_status_code FROM [PRODELGBLTY1].[PREMIER_Eligibility_Staging].dbo.[Hospital_for_Special_Surgery_PREMIER_RAWFILE]
--SELECT  distinct [Employee Status] FROM [PRODELGBLTY1].[PREMIER_Eligibility_Staging].dbo.[Iheart_Meritian_Rawfile]
----SELECT  distinct benefit_status_code FROM [PRODELGBLTY1].[PREMIER_Eligibility_Staging].dbo.[Iheart_Trustmark_Rawfile]
--SELECT  distinct Active_Indicator FROM [PRODELGBLTY1].[PREMIER_Eligibility_Staging].dbo.[IHEART_UMR_RAWFILE]
--SELECT  distinct benefit_status_code FROM [PRODELGBLTY1].[PREMIER_Eligibility_Staging].dbo.[LURIE_PREMIER_RAWFILE]
--SELECT  distinct benefit_status_code FROM [PRODELGBLTY1].[PREMIER_Eligibility_Staging].dbo.[MARSH_MCLENNAN_RAWFILE]
--SELECT  distinct benefitstatuscode FROM [PRODELGBLTY1].[PREMIER_Eligibility_Staging].dbo.[MercedesBenz_RAWFILE]
--SELECT  distinct MEMB_ACTIVE_IND FROM [PRODELGBLTY1].[PREMIER_Eligibility_Staging].dbo.[SPOKANE_RAWFILE]
--SELECT  distinct benefit_status_code FROM [PRODELGBLTY1].[PREMIER_Eligibility_Staging].dbo.[TRANE_RAWFILE]
--SELECT  distinct benefit_status_code FROM [PRODELGBLTY1].[PREMIER_Eligibility_Staging].dbo.[WPP_PREMIER_RAWFILE]
--SELECT  distinct MEMB_ACTIVE_IND FROM [PRODELGBLTY1].[PREMIER_Eligibility_Staging].dbo.[Xo_health_RAWFILE]


--FROM DLDB.DBO.DL_DW_LUFAXCONTRACT
--WHERE CONTRACTDESC LIKE '%BAKER DONEL%'

	    SELECT --TOP (1000)
	   DISTINCT
	  -- 
	  [Contract]
     -- ,	 [Member_ID]
      --	  ,	  [Coverage_Start_Date]
     -- 
	 , Chosen_Date
	 , [Coverage_End_Date]
      , [Active_Indicator]
	  , datediff(day,Chosen_Date,[Coverage_End_Date]) as [Expired Already?]
	  , case when datediff(day,Chosen_Date,[Coverage_End_Date])  < 0 then 'Expired' ELSE '' end as [Status]
	  , COUNT(*) AS [Count]
  FROM [WorkBench].[dbo].[Eligibility_All_RAW]
  WHERE (
			datediff(day,Chosen_Date,[Coverage_End_Date]) < 0 
			and Active_Indicator in ('A','Active','FT','PT','Yes','C','COBRA') 
		)
		--OR 
		--(
		--	datediff(day,Chosen_Date,[Coverage_End_Date]) >= 0 
		--	and Active_Indicator NOT in ('A','Active','FT','PT','Yes') 
		--	and Active_Indicator IS NOT NULL
		--)
  GROUP BY 	 --  
  [Contract]
     -- ,[Member_ID]
      --	  ,	  [Coverage_Start_Date]     
	 , Chosen_Date
	  ,	  [Coverage_End_Date]
      ,[Active_Indicator]
;




WITH TOTAL_ROWS AS
(
SELECT COUNT(*) AS [TOTAL ROWS IN TABLE]
  FROM [WorkBench].[dbo].[Eligibility_All_RAW]
),
TOTAL_MISMATCHED_ROWS AS
(
    SELECT COUNT(*) AS [ROWS WITH MISMATCHED COVERAGE END & ACTIVE INDICATOR]
  FROM [WorkBench].[dbo].[Eligibility_All_RAW]
  WHERE (
			datediff(day,Chosen_Date,[Coverage_End_Date]) < 0 
			and Active_Indicator in ('A','Active','FT','PT','Yes') 
		)
		--OR 
		--(
		--	datediff(day,Chosen_Date,[Coverage_End_Date]) >= 0 
		--	and Active_Indicator NOT in ('A','Active','FT','PT','Yes') 
		--	and Active_Indicator IS NOT NULL
		--)
--;
)
SELECT 'TOTAL_ROWS' AS [DESC]
	, cast([TOTAL ROWS IN TABLE] as int) AS [VALUE]
FROM total_rows
UNION ALL
SELECT 'MISMATCHED_ROWS' AS [DESC]
	, cast([ROWS WITH MISMATCHED COVERAGE END & ACTIVE INDICATOR] as int) AS [VALUE]
FROM TOTAL_MISMATCHED_ROWS
UNION ALL
SELECT 'MISMATCHED PERCENTAGE' AS [DESC]
	, --format(
	(TOTAL_MISMATCHED_ROWS.[ROWS WITH MISMATCHED COVERAGE END & ACTIVE INDICATOR]*1.0)/(TOTAL_ROWS.[TOTAL ROWS IN TABLE]*1.0)--,'P') 
	AS [VALUE]
from TOTAL_MISMATCHED_ROWS Cross join total_rows
;

SELECT COUNT(DISTINCT CONTRACT) AS [unique contract count]
  FROM [WorkBench].[dbo].[Eligibility_All_RAW]
  ;

    SELECT COUNT(DISTINCT CONTRACT) AS [CONTRACT COUNT WITH MISMATCHED COVERAGE END & ACTIVE INDICATOR]
  FROM [WorkBench].[dbo].[Eligibility_All_RAW]
  WHERE (
			datediff(day,Chosen_Date,[Coverage_End_Date]) < 0 
			and Active_Indicator in ('A','Active','FT','PT','Yes') 
		)
		--OR 
		--(
		--	datediff(day,Chosen_Date,[Coverage_End_Date]) >= 0 
		--	and Active_Indicator NOT in ('A','Active','FT','PT','Yes') 
		--	and Active_Indicator IS NOT NULL
		--)
;

    SELECT DISTINCT CONTRACT AS [CONTRACTS WITH MISMATCHED COVERAGE END & ACTIVE INDICATOR]
  FROM [WorkBench].[dbo].[Eligibility_All_RAW]
  WHERE (
			datediff(day,Chosen_Date,[Coverage_End_Date]) < 0 
			and Active_Indicator in ('A','Active','FT','PT','Yes') 
		)
		--OR 
		--(
		--	datediff(day,Chosen_Date,[Coverage_End_Date]) >= 0 
		--	and Active_Indicator NOT in ('A','Active','FT','PT','Yes') 
		--	and Active_Indicator IS NOT NULL
		--)
;

