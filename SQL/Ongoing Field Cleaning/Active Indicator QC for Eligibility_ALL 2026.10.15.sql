/*INITIALIZATION AND VIEWING*/

drop table if exists #active_base;
  select distinct 
	Contract
	, [Active_Indicator]
	, Coverage_End_Date
	, Chosen_Date
	, datediff(day,Chosen_Date,Coverage_End_Date) as End_Date_MINUS_Chosen
	, count(*) as [Row_Count]
into #active_base
FROM [WorkBench].[dbo].[Eligibility_All_RAW]
group by Contract, [Active_Indicator], Coverage_End_Date, Chosen_Date
order by Contract, [Active_Indicator], Coverage_End_Date, Chosen_Date
;

select 'TOP 10000' '#active_base';
select top 10000 * from #active_base;


DROP TABLE IF EXISTS #indicator_summary;
select 
	[Contract]
	, MAX(Case when Active_Indicator IS NULL then 1 else 0 end) as Has_Null_Indicator 
	, MAX(Case when Active_Indicator = '' then 1 else 0 end) as Has_Blank_Indicator 
	--, MAX(Case when Active_Indicator IS NULL then 1 else 0 end) as Has_Null_Indicator 
	, MAX(Case when End_Date_Minus_Chosen < 0 and trim(Active_Indicator) in ('Active','A','Yes','FT') then 1 else 0 end) as Erroneous_Marked_Active_Expired_ENdDate
into #indicator_summary
from #active_base
GROUP BY [Contract]
ORDER BY [Contract]
;


select '' '#indicator_summary';
select * from #indicator_summary
order by contract;


select 'CONTRACTS WITH BAD INDICATORS' '#active_Base';
DROP TABLE IF EXISTS #CONTRACTS_w_Bad_Indicators
select distinct contract
into #CONTRACTS_w_Bad_Indicators
FROM #active_Base
where Active_Indicator in ( 'Blue Shield EPO' 
, 'Blue Shield HDHP w/HSA' 
, 'Blue Shield HMO Full' 
, 'Blue Shield HMO Trio' 
, 'Blue Shield PPO 3000' 
, 'Blue Shield PPO 750' 
, 'COBRA' 
, 'L' 
, 'P' 
, 'PT' 
, 'R' 
, 'S' 
, 'U' 
)
;


select '' '#CONTRACTS_w_Bad_Indicators';
select * from #CONTRACTS_w_Bad_Indicators;


select 'Erroneous_EndDate_Indicator_Combo = 0' '#indicator_summary';
DROP TABLE IF EXISTS #One_Wrong_Indicator_Name_Contracts;
select * 
into #One_Wrong_Indicator_Name_Contracts
from #indicator_summary
where Erroneous_Marked_Active_Expired_ENdDate = 0
	and (
			(Has_Null_Indicator = 1 and Has_Blank_Indicator = 0)
			OR
			(Has_Null_Indicator = 0 and Has_Blank_Indicator = 1)
		);


select '' '#One_Wrong_Indicator_Name_Contracts';		
select * 
from #One_Wrong_Indicator_Name_Contracts
order by Contract
;

select 'w Count' 'Active Indicators by Contract';
drop table if exists #missing_indicator_summary;
  select distinct ear.Contract, o.Has_Null_Indicator
  , count(distinct ear.[Active_Indicator]) as Indicators --, count(*) as [Row_Count]
  ,  o.Has_Null_Indicator+count(distinct ear.[Active_Indicator]) as Total_Indicators
into #missing_indicator_summary
FROM #One_Wrong_Indicator_Name_Contracts o
JOIN [WorkBench].[dbo].[Eligibility_All_RAW] ear
		on o.Contract = ear.Contract
group by ear.Contract, o.Has_Null_Indicator--, ear.[Active_Indicator]
order by ear.Contract--, ear.[Active_Indicator]
;


select '' '#missing_indicator_summary';
select * from #missing_indicator_summary
order by Contract;



drop table if exists #indicator_summary_v2;
select i.contract
	, i.Erroneous_Marked_Active_Expired_EndDate
	, i.Has_Blank_Indicator
	, i.Has_Null_Indicator
	, mis.Indicators
	, mis.Total_Indicators
into #indicator_summary_v2
from #indicator_summary i
left JOIN #missing_indicator_summary mis
	on i.Contract = mis.Contract
;

select '' '#indicator_summary_v2';
select * 
from #indicator_summary_v2;


/*END INITIALIZATION*/
---------------------------------------------------------------------------

/*BEGIN VIEWING*/

select 'TOP 10000' '#active_base';
select top 10000 * from #active_base;

select '' '#indicator_summary';
select * from #indicator_summary;

select '' '#indicator_summary_v2';
select * 
from #indicator_summary_v2;


select '' '#missing_indicator_summary';
select * from #missing_indicator_summary
order by Contract;


select 'SUCCINCT SUMMARY' '#indicator_summary';
select
	count(distinct Contract) as Unique_Contracts
	, sum(case when Has_Null_Indicator=0 and Has_Blank_Indicator=0 and Erroneous_Marked_Active_Expired_ENdDate=0 then 1 else 0 end) as No_Issues
	, sum(Has_Null_Indicator) as w_Null_Indicators
	, sum(Has_Blank_Indicator) as w_Blank_Indicators
	, sum(Erroneous_Marked_Active_Expired_ENdDate) as Has_Bad_Indicator_EndDates
FROM #indicator_summary
;

--# |  DATE ISSUES |  NULLS   |   BLANKS | notes                  |  count
------------------------------------------------------------------------------
--1 |  Y           |  Y       |   Y	 	  | ALL 3 PROBLEMS        | (iii)
--2 |  N           |  N       |   N		  | ZERO PROBLEMS         |    
--3 |  Y           |  N       |   N	      | DATE ISSUES ONLY	  | (i)  
--4 |  Y           |  Y       |   N		  | DATE ISSUES + NULLS	  | (ii)  
--5 |  N           |  Y       |   N		  | (i)    | NULLS ONLY : Subsection with a lot of semi-usability
--6 |  N           |  Y       |   Y	      | NULLS + BLANKS	      | (ii) 
--7 |  N           |  N       |   Y	      | BLANKS ONLY           | (i)
--8 |  Y           |  N       |   Y	      | BLANKS + DATES	      | (ii) 

--1
select 
	  count(distinct [Contract]) 
		as [(#1) All 3 Problems]
	, string_agg([Contract],', ') as Contract_List
FROM #indicator_summary_v2
where Erroneous_Marked_Active_Expired_EndDate = 1
	and Has_Blank_Indicator = 1
	and Has_Null_Indicator = 1
;

--2
select 
	  count(distinct [Contract]) 
		as [(#2) Zero Problems]
	, string_agg([Contract],', ') as Contract_List
FROM #indicator_summary_v2
where Erroneous_Marked_Active_Expired_EndDate = 0
	and Has_Blank_Indicator = 0
	and Has_Null_Indicator = 0
;
--3
select 
	  count(distinct [Contract]) 
		as [(#3) Date Issues Only]
	, string_agg([Contract],', ') as Contract_List
FROM #indicator_summary_v2
where Erroneous_Marked_Active_Expired_EndDate = 1
	and Has_Blank_Indicator = 0
	and Has_Null_Indicator = 0
;
--4
select 
	  count(distinct [Contract]) 
		as [(#4) Date Issues AND Nulls]
	, string_agg([Contract],', ') as Contract_List
FROM #indicator_summary_v2
where Erroneous_Marked_Active_Expired_EndDate = 1
	and Has_Blank_Indicator = 0
	and Has_Null_Indicator = 1
;
--5
select 
	  count(distinct [Contract]) 
		as [(#5) NULLS Only]
	, string_agg([Contract],', ') as Contract_List
FROM #indicator_summary_v2
where Erroneous_Marked_Active_Expired_EndDate = 0
	and Has_Blank_Indicator = 0
	and Has_Null_Indicator = 1
;
--6
select 
	  count(distinct [Contract]) 
		as [(#6) NULLS AND Blanks]
	, string_agg([Contract],', ') as Contract_List
FROM #indicator_summary_v2
where Erroneous_Marked_Active_Expired_EndDate = 0
	and Has_Blank_Indicator = 1
	and Has_Null_Indicator = 1
;
--7
select 
	  count(distinct [Contract]) 
		as [(#7) BLANKS Only]
	, string_agg([Contract],', ') as Contract_List
FROM #indicator_summary_v2
where Erroneous_Marked_Active_Expired_EndDate = 0
	and Has_Blank_Indicator = 1
	and Has_Null_Indicator = 0
;
--8
select 
	  count(distinct [Contract]) 
		as [(#8) Date Issues + BLANKS]
	, string_agg([Contract],', ') as Contract_List
FROM #indicator_summary_v2
where Erroneous_Marked_Active_Expired_EndDate = 1
	and Has_Blank_Indicator = 1
	and Has_Null_Indicator = 0
;


/*BREAKDOWN OF ITEM #5*/
SELECT 'breakdown of #5' 'NULLS ONLY - MANY STILL USABLE';

SELECT COUNT(DISTINCT CONTRACT) AS [(#5a - usable) NULL = INACTIVE]
from #missing_indicator_summary
where Total_Indicators = 2 and Has_Null_Indicator = 1;

SELECT COUNT(DISTINCT CONTRACT) AS [(#5b - usable) no indicators period]
from #missing_indicator_summary
where Total_Indicators = 1 AND Has_Null_Indicator = 1;


SELECT COUNT(DISTINCT CONTRACT) AS [(#5c - usable) nulls & 2+ NONBLANK indicators]
from #indicator_summary_v2
where Total_Indicators > 2 AND Has_Null_Indicator = 1 and Has_Blank_Indicator=0;

