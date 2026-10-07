--USE [WorkBench]
--GO

----CREATE PROCEDURE [dbo].[[sp_Eligibility_Aggregation_RAW_Staging_to_Final]

----SET ANSI_NULLS ON
----GO
----SET QUOTED_IDENTIFIER ON
----GO

--ALTER PROCEDURE [dbo].[sp_Eligibility_Aggregation_RAW_Load_to_Staging]

----STAGING TABLE: [xxEligibility_All_RAW]: RENAME TO Eligibility_ALL_Raw_DB_Extraction
----Transformation: Eligibility_ALL_RAW_DB_STAGING
----Load/Finaltable: Eligibility_ALL_RAW_DB_FINAL

--AS BEGIN

DROP TABLE IF EXISTS WorkBench.dbo.Eligibility_RawFileNames_v4_Combined;
select 'Begin Creation' 'Eligibility_RawFileNames_v4_Combined';
select * into WorkBench.dbo.Eligibility_RawFileNames_v4_Combined from
(
	select r.RawFileNameFull, r.RawFileDateTime, r.[FileSize (KB)]
		, r.RecordCt, r.RawFileNameOnly
		, LEFT(
        RIGHT(r.RawFileNameFull, CHARINDEX('\', REVERSE(r.RawFileNameFull)) - 1),
        CHARINDEX('.', RIGHT(r.RawFileNameFull, CHARINDEX('\', REVERSE(r.RawFileNameFull)) - 1)) - 1
		 ) as Cleaned_Name
		from WorkBench.dbo.Eligibility_RawFileNames r
		left JOIN  WorkBench.dbo.Eligibility_RawFileNames og
			on r.RawFileNameFull = og.RawFileNameFull
	where og.RawFileNameFULL IS NULL

	UNION ALL

	SELECT V3.RawFileNameFull, v3.RawFileDateTime, v3.[FileSize (KB)]
		, v3.RecordCt, v3.RawFileNameOnly
		, LEFT(
        RIGHT(v3.RawFileNameFull, CHARINDEX('\', REVERSE(v3.RawFileNameFull)) - 1),
        CHARINDEX('.', RIGHT(v3.RawFileNameFull, CHARINDEX('\', REVERSE(v3.RawFileNameFull)) - 1)) - 1
		 ) as Cleaned_Name
		from WorkBench.dbo.Eligibility_RawFileNames_v3_Archive v3
		left JOIN  WorkBench.dbo.Eligibility_RawFileNames og
			on v3.RawFileNameFull = og.RawFileNameFull
	where og.RawFileNameFULL IS NULL
) a;

select 'END Creation' 'Eligibility_RawFileNames_v4_Combined';

select 'Begin Creation' '#temp_staging ';
DROP TABLE IF EXISTS #temp_staging;
SELECT i.[Contract]
      , i.[Member_ID]
      , i.[Relationship_ID]
      , i.[First_Name]
      , i.[Last_Name]
      , i.[Email]
      , i.[Main_Phone]
      , i.[Street_Address]
      , i.[Address_2]
      , i.[City]
      , i.[State]
      , i.[Zip]
      , i.[Date_of_Birth]
      , i.[Coverage_Start_Date]
      , i.[Coverage_End_Date]
      --, i.[File_Name]
      --, i.[IS_CreatedDate]
      , i.[Gender]
      , i.[Active_Indicator]
      , i.[Record_Type]
      , i.[Source_Table]
, i.[File_Name] AS [File_Name]
, cast(0 as VARCHAR(500)) AS New_Relationship
, cast(0 as int) as File_Size
, i.IS_CreatedDate
, cast(0 as NVARCHAR(MAX)) AS File_Name_Date
, cast(0 as DATETIME) AS File_Name_Date_CLEANED
, cast(0 as DATETIME) AS Raw_File_TimeStamp
, cast(0 as DATETIME) AS Chosen_Date
, cast(0 as int) as [Chosen_Date_Year_Month]
--, cast(0 as int) as [Chosen_Date_Year]
, cast(0 as int) as Month_Order
--, cast(0 as nvarchar(20)) as Order_Desc
, cast(0 as varchar(500)) as Table_Type
INTO #temp_staging
FROM WorkBench.dbo.xxEligibility_All_RAW--Eligibility_ALL_Raw_DB_Extraction 
i

select 'initialization complete' '#temp_staging'
;

--select count(*) as xxEligibility_All_RAW_Count from WorkBench.dbo.xxEligibility_All_RAW;
--select 'top 200 *' '#temp_staging';
--select top 200 * from #temp_staging;
--select 'end top 200 *' '#temp_staging';

--ASSUMING SSIS CREATED TABLE IS NAMED Eligibility_Raw_File_Names


--UPDATE stage 
--SET File_Size = RFN.File_Size
--from #temp_staging stage
--JOIN WorkBench.dbo.Eligibility_RawFileNames rfn
--ON stage.[Contract] = rfn.[Contract]

;

  ------ FILE NAME DATE - COMBINING ALL REGEX LOGIC FROM "File_Name_Date_RegEx.sql":
select 'File_Name_Date Update BEGIN' 'File_Name_Date';
  UPDATE #temp_staging
  SET  File_Name_Date =
    CASE WHEN  [File_Name]  like '05712109%' and [File_Name]  like '%[_][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][_]%' 
		THEN substring([File_Name],patindex('%[_][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][_]%', [File_Name])+1,8)
	WHEN  [File_Name]  like '05712109%' and [File_Name]  like '%[_][2][0][0-9][0-9][0-1][0-9][_][2][0][0-9][0-9][0-1][0-9]%' 
		 THEN substring([File_Name],patindex('%[_][2][0][0-9][0-9][0-1][0-9][_][2][0][0-9][0-9][0-1][0-9]%', [File_Name])+1,6)
	WHEN ([File_Name] like '%AM' or [File_Name] like '%PM' or [File_Name] like '%AM (%'	or [File_Name] like '%PM (%')
			and [File_Name] like '%[0-1][0-9]_[0-3][0-9]_[2][0][0-9][0-9]%'
		THEN substring([File_Name],patindex('%[0-1][0-9]_[0-3][0-9]_[2][0][0-9][0-9]%', [File_Name]),10) 
    WHEN File_Name_Date = 0 AND [File_Name] like '%[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]%' 
              AND  [File_Name] NOT like '%AM' and [File_Name] NOT like '%PM' and [File_Name] NOT like '%AM (%' and [File_Name] NOT like '%PM (%' and [File_Name] NOT like '05712109%' 
		THEN substring([File_Name],PATINDEX('%[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]%', [File_Name]),8)
    WHEN File_Name_Date = 0 and [File_Name] like '%[0-9][0-9][0-9][0-9][0-9][0-9]%' 
			and [File_Name] NOT like '%[0-9][0-9][0-9][0-9][0-9][0-9][0-9]%' 
			AND  [File_Name] NOT like '%AM' and [File_Name] NOT like '%PM' and [File_Name] NOT like '%AM (%' and [File_Name] NOT like '%PM (%' and [File_Name] NOT like '05712109%' 
      THEN substring([File_Name],patindex('%[0-9][0-9][0-9][0-9][0-9][0-9]%', [File_Name]),6)
    WHEN File_Name_Date = 0 and [File_Name] like '%[0-9][0-9][0-9][0-9]_[0-9][0-9]_[0-9][0-9]%' 
        AND  [File_Name] NOT like '%AM' and [File_Name] NOT like '%PM' and [File_Name] NOT like '%AM (%' and [File_Name] NOT like '%PM (%' and [File_Name] NOT like '05712109%' 
      THEN substring([File_Name], patindex( '%[0-9][0-9][0-9][0-9]_[0-9][0-9]_[0-9][0-9]%', [File_Name]),10)
    WHEN File_Name_Date = '0' and [File_Name] like '%[0-9][0-9][0-9][0-9]_[0-9][0-9]%'
        AND  [File_Name] NOT like '%AM' and [File_Name] NOT like '%PM' and [File_Name] NOT like '%AM (%' and [File_Name] NOT like '%PM (%' and [File_Name] NOT like '05712109%' 
      THEN substring([File_Name], patindex( '%[0-9][0-9][0-9][0-9]_[0-9][0-9]%', [File_Name]),7)
    WHEN File_Name_Date = '0' and [File_Name] like '%[0-9][0-9]_[0-9][0-9]_[0-9][0-9][0-9][0-9]%'
        AND  [File_Name] NOT like '%AM' and [File_Name] NOT like '%PM' and [File_Name] NOT like '%AM (%' and [File_Name] NOT like '%PM (%' and [File_Name] NOT like '05712109%' 
      THEN substring([File_Name], patindex( '%[0-9][0-9]_[0-9][0-9]_[0-9][0-9][0-9][0-9]%', [File_Name]),10)
    WHEN File_Name_Date = '0' and [File_Name] like '%[0-9]_[0-9][0-9]_[0-9][0-9][0-9][0-9]%'
        AND  [File_Name] NOT like '%AM' and [File_Name] NOT like '%PM' and [File_Name] NOT like '%AM (%' and [File_Name] NOT like '%PM (%' and [File_Name] NOT like '05712109%' 
      THEN substring([File_Name], patindex( '%[0-9]_[0-9][0-9]_[0-9][0-9][0-9][0-9]%', [File_Name]),9)
    WHEN File_Name_Date = '0' and [File_Name] like '%[2][0-9][^A-Za-z0-9][1-9][^A-Za-z0-9][2][0][0-9][0-9]%'
        AND  [File_Name] NOT like '%AM' and [File_Name] NOT like '%PM' and [File_Name] NOT like '%AM (%' and [File_Name] NOT like '%PM (%' and [File_Name] NOT like '05712109%' 
      THEN substring([File_Name], patindex( '%[2][0-9][^A-Za-z0-9][1-9][^A-Za-z0-9][2][0][0-9][0-9]%', [File_Name]),9)
   WHEN File_Name_Date = '0' and [File_Name] like '%[3][0-1][^A-Za-z0-9][1-9][^A-Za-z0-9][2][0][0-9][0-9]%'
         AND  [File_Name] NOT like '%AM' and [File_Name] NOT like '%PM' and [File_Name] NOT like '%AM (%' and [File_Name] NOT like '%PM (%' and [File_Name] NOT like '05712109%' 
     THEN substring([File_Name], patindex( '%[3][0-1][^A-Za-z0-9][1-9][^A-Za-z0-9][2][0][0-9][0-9]%', [File_Name]),9)
	WHEN File_Name_Date = '0' and [File_Name] like '%[0-9]_[0-9]_[0-9][0-9][0-9][0-9]%'
        AND  [File_Name] NOT like '%AM' and [File_Name] NOT like '%PM' and [File_Name] NOT like '%AM (%' and [File_Name] NOT like '%PM (%' and [File_Name] NOT like '05712109%' 
      THEN substring([File_Name], patindex( '%[0-9]_[0-9]_[0-9][0-9][0-9][0-9]%', [File_Name]),8)
    WHEN File_Name_Date = '0' and [File_Name] like '%[0-9][0-9]_[0-9][0-9]_[0-9][0-9]%' 
        AND  [File_Name] NOT like '%AM' and [File_Name] NOT like '%PM' and [File_Name] NOT like '%AM (%' and [File_Name] NOT like '%PM (%' and [File_Name] NOT like '05712109%' 
       THEN substring([File_Name], patindex( '%[0-9][0-9]_[0-9][0-9]_[0-9][0-9]%', [File_Name]),8) 
    WHEN File_Name_Date = '0' and [File_Name] like '%[0-9][0-9]_[0-9]_[0-9][0-9]%'
        AND  [File_Name] NOT like '%AM' and [File_Name] NOT like '%PM' and [File_Name] NOT like '%AM (%' and [File_Name] NOT like '%PM (%' and [File_Name] NOT like '05712109%' 
       THEN substring([File_Name], patindex( '%[0-9][0-9]_[0-9]_[0-9][0-9]%', [File_Name]),8)
    WHEN File_Name_Date = '0' and [File_Name] like '%[0-9]_[0-9][0-9]_[0-9][0-9]%'
        AND  [File_Name] NOT like '%AM' and [File_Name] NOT like '%PM' and [File_Name] NOT like '%AM (%' and [File_Name] NOT like '%PM (%' and [File_Name] NOT like '05712109%' 
       THEN substring([File_Name], patindex( '%[0-9]_[0-9][0-9]_[0-9][0-9]%', [File_Name]),7)        
    WHEN File_Name_Date = '0' and [File_Name] like '%[0-9]_[0-9]_[0-9][0-9]%'
        AND  [File_Name] NOT like '%AM' and [File_Name] NOT like '%PM' and [File_Name] NOT like '%AM (%' and [File_Name] NOT like '%PM (%' and [File_Name] NOT like '05712109%' 
       THEN substring([File_Name], patindex( '%[0-9]_[0-9]_[0-9][0-9]%', [File_Name]),6)
    WHEN File_Name_Date = '0' and [File_Name] like '%Jan_[0-9][0-9][0-9][0-9]%' 
        AND  [File_Name] NOT like '%AM' and [File_Name] NOT like '%PM' and [File_Name] NOT like '%AM (%' and [File_Name] NOT like '%PM (%' and [File_Name] NOT like '05712109%' 
       THEN substring([File_Name], patindex('%Jan_[0-9][0-9][0-9][0-9]%', [File_Name]),8)
    WHEN File_Name_Date = '0' and [File_Name] like '%Feb_[0-9][0-9][0-9][0-9]%'
        AND  [File_Name] NOT like '%AM' and [File_Name] NOT like '%PM' and [File_Name] NOT like '%AM (%' and [File_Name] NOT like '%PM (%' and [File_Name] NOT like '05712109%' 
        then substring([File_Name], patindex('%Feb_[0-9][0-9][0-9][0-9]%', [File_Name]),8)
	when File_Name_Date = '0' and [File_Name] like '%March_[0-9][0-9][0-9][0-9]%' 
        AND  [File_Name] NOT like '%AM' and [File_Name] NOT like '%PM' and [File_Name] NOT like '%AM (%' and [File_Name] NOT like '%PM (%' and [File_Name] NOT like '05712109%' 
        then substring([File_Name], patindex('%March_[0-9][0-9][0-9][0-9]%', [File_Name]),10)
    when File_Name_Date = '0' and [File_Name] like '%Mar_[0-9][0-9][0-9][0-9]%' 
        AND  [File_Name] NOT like '%AM' and [File_Name] NOT like '%PM' and [File_Name] NOT like '%AM (%' and [File_Name] NOT like '%PM (%' and [File_Name] NOT like '05712109%' 
        then substring([File_Name], patindex('%Mar_[0-9][0-9][0-9][0-9]%', [File_Name]),8)
    when File_Name_Date = '0' and [File_Name] like '%April_[0-9][0-9][0-9][0-9]%' 
        AND  [File_Name] NOT like '%AM' and [File_Name] NOT like '%PM' and [File_Name] NOT like '%AM (%' and [File_Name] NOT like '%PM (%' and [File_Name] NOT like '05712109%' 
        then substring([File_Name], patindex('%April_[0-9][0-9][0-9][0-9]%', [File_Name]),10)
    when File_Name_Date = '0' and [File_Name] like '%Apr_[0-9][0-9][0-9][0-9]%' 
         AND  [File_Name] NOT like '%AM' and [File_Name] NOT like '%PM' and [File_Name] NOT like '%AM (%' and [File_Name] NOT like '%PM (%' and [File_Name] NOT like '05712109%' 
       then substring([File_Name], patindex('%Apr_[0-9][0-9][0-9][0-9]%', [File_Name]),8)
    when File_Name_Date = '0' and [File_Name] like '%May_[0-9][0-9][0-9][0-9]%' 
        AND  [File_Name] NOT like '%AM' and [File_Name] NOT like '%PM' and [File_Name] NOT like '%AM (%' and [File_Name] NOT like '%PM (%' and [File_Name] NOT like '05712109%' 
        then substring([File_Name], patindex('%May_[0-9][0-9][0-9][0-9]%', [File_Name]),8)
    when File_Name_Date = '0' and [File_Name] like '%Jun_[0-9][0-9][0-9][0-9]%' 
        AND  [File_Name] NOT like '%AM' and [File_Name] NOT like '%PM' and [File_Name] NOT like '%AM (%' and [File_Name] NOT like '%PM (%' and [File_Name] NOT like '05712109%' 
        then substring([File_Name], patindex('%Jun_[0-9][0-9][0-9][0-9]%', [File_Name]),8)
    when File_Name_Date = '0' and [File_Name] like '%Jul_[0-9][0-9][0-9][0-9]%' 
        AND  [File_Name] NOT like '%AM' and [File_Name] NOT like '%PM' and [File_Name] NOT like '%AM (%' and [File_Name] NOT like '%PM (%' and [File_Name] NOT like '05712109%' 
        then substring([File_Name], patindex('%Jul_[0-9][0-9][0-9][0-9]%', [File_Name]),8)
    when File_Name_Date = '0' and [File_Name] like '%Aug_[0-9][0-9][0-9][0-9]%' 
         AND  [File_Name] NOT like '%AM' and [File_Name] NOT like '%PM' and [File_Name] NOT like '%AM (%' and [File_Name] NOT like '%PM (%' and [File_Name] NOT like '05712109%' 
       then substring([File_Name], patindex('%Aug_[0-9][0-9][0-9][0-9]%', [File_Name]),8)
    when File_Name_Date = '0' and [File_Name] like '%Sept_[0-9][0-9][0-9][0-9]%' 
        AND  [File_Name] NOT like '%AM' and [File_Name] NOT like '%PM' and [File_Name] NOT like '%AM (%' and [File_Name] NOT like '%PM (%' and [File_Name] NOT like '05712109%' 
        then substring([File_Name], patindex('%Sept_[0-9][0-9][0-9][0-9]%', [File_Name]),9)
    when File_Name_Date = '0' and [File_Name] like '%October_[0-9][0-9][0-9][0-9]%' 
        AND  [File_Name] NOT like '%AM' and [File_Name] NOT like '%PM' and [File_Name] NOT like '%AM (%' and [File_Name] NOT like '%PM (%' and [File_Name] NOT like '05712109%' 
        then substring([File_Name], patindex('%October_[0-9][0-9][0-9][0-9]%', [File_Name]),12)
    when File_Name_Date = '0' and [File_Name] like '%Oct_[0-9][0-9][0-9][0-9]%' 
        AND  [File_Name] NOT like '%AM' and [File_Name] NOT like '%PM' and [File_Name] NOT like '%AM (%' and [File_Name] NOT like '%PM (%' and [File_Name] NOT like '05712109%' 
        then substring([File_Name], patindex('%Oct_[0-9][0-9][0-9][0-9]%', [File_Name]),8)
    when File_Name_Date = '0' and [File_Name] like '%Nov_[0-9][0-9][0-9][0-9]%' 
        AND  [File_Name] NOT like '%AM' and [File_Name] NOT like '%PM' and [File_Name] NOT like '%AM (%' and [File_Name] NOT like '%PM (%' and [File_Name] NOT like '05712109%' 
        then substring([File_Name], patindex('%Nov_[0-9][0-9][0-9][0-9]%', [File_Name]),8)
    when File_Name_Date = '0' and [File_Name] like '%Dec_[0-9][0-9][0-9][0-9]%' 
         AND  [File_Name] NOT like '%AM' and [File_Name] NOT like '%PM' and [File_Name] NOT like '%AM (%' and [File_Name] NOT like '%PM (%' and [File_Name] NOT like '05712109%' 
       then substring([File_Name], patindex('%Dec_[0-9][0-9][0-9][0-9]%', [File_Name]),8)
    else '0' end;

select 'File_Name_Date Update END' 'File_Name_Date';

	--select count(*) as xxEligibility_All_RAW_Count from WorkBench.dbo.xxEligibility_All_RAW;
	----NO INCREASES
	--select top 200 * from #temp_staging;

SELECT 'File_Name_Date_Cleaned BEGAN' '#temp_staging Update';
UPDATE #temp_staging
  SET  File_Name_Date_Cleaned = 
	case 
		-- 1 --(27)
		when File_Name_Date_Cleaned = 0
				and len(File_Name_Date) = 10
			and File_Name_Date like '[2][0][0-9][0-9][^A-Za-z0-9][0-1][0-9][^A-Za-z0-9][0-3][0-9]'	
		THEN datefromparts(left(File_Name_Date,4),substring(File_Name_Date,6,2),right(File_Name_Date,2))

		-- 2 --(22)
		when File_Name_Date_Cleaned = 0
			and len(File_Name_Date) = 8
			and File_Name_Date like '[2][0][0-9][0-9][0-1][0-9][0-3][0-9]'
		then datefromparts(left(File_Name_Date,4),substring(File_Name_Date,5,2),right(File_Name_Date,2))

		--3 --26		
		when File_Name_Date_Cleaned = 0
				and len(File_Name_Date) = 10
			and File_Name_Date like '[0-1][0-9][^A-Za-z0-9][0-3][0-9][^A-Za-z0-9][2][0][0-9][0-9]'	
		THEN datefromparts(right(File_Name_Date,4),left(File_Name_Date,2),substring(File_Name_Date,4,2))

		--4 --(23)
		when File_Name_Date_Cleaned = 0
			and len(File_Name_Date) = 8
			and File_Name_Date like '[0-1][0-9][0-3][0-9][2][0][0-9][0-9]'
		then datefromparts(right(File_Name_Date,4),left(File_Name_Date,2),substring(File_Name_Date,3,2))

		--5 --25		
		when len(File_name_Date) = 9
			and File_Name_date like '[0-9]_[0-9][0-9]_[0-9][0-9][0-9][0-9]'
			and File_Name_Date_CLeaned = 0
		then datefromparts(right(File_Name_Date,4),left(File_name_Date,1),substring(File_Name_Date,3,2))
	
	--6 (NEW)
	when len(File_name_Date) = 9
			and ([File_Name] like '[2][0-9][^A-Za-z0-9][1-9][^A-Za-z0-9][2][0][0-9][0-9]'
					or [File_Name] like '[3][0-1][^A-Za-z0-9][1-9][^A-Za-z0-9][2][0][0-9][0-9]')
			and File_Name_Date_CLeaned = 0
		then datefromparts(right(File_Name_Date,4),substring(File_Name_Date,4,1),left(File_name_Date,2))
	

	--7 --3
	when len(File_name_Date) = 8 and 
			(File_name_Date like '%.%' or File_Name_Date like '%-%') --and File_Name_Date not like '%_%'
			and left(File_Name_date,1) <> 0
			and right(File_Name_Date,4) in ('2019','2020','2021','2022','2023','2024','2025','2026','2027','2028','2029','2030')
			and File_Name_Date not like '%[a-z]%'
	then datefromparts(right(File_Name_Date,4),substring(File_Name_Date,1,1),substring(File_Name_Date,3,1))

	--8  (--14)		
	when File_Name_Date_Cleaned = 0
		and len(File_Name_Date) = 6
		and File_Name_Date like '[0-9][^A-Za-z0-9][0-9][^A-Za-z0-9][0-9][0-9]'
	then datefromparts(concat(20,right(File_Name_Date,2)),left(File_Name_Date,1),substring(File_Name_Date,3,1))

	--9 --(15)
	when File_Name_Date_Cleaned = 0
		and len(File_Name_Date) = 7
		and File_Name_Date like '[0-9][^A-Za-z0-9][0-9][0-9][^A-Za-z0-9][0-9][0-9]'
	then datefromparts(concat(20,right(File_Name_Date,2)),left(File_Name_Date,1),substring(File_Name_Date,3,2))

	--10 (--12)
	when File_Name_Date_Cleaned = 0
		and len(File_name_Date) = 6 and File_name_Date not like '%.%'
		and File_Name_Date not like '%-%' --and File_Name_Date not like '%_%'
		and left(File_Name_Date,2) in ('19','20','21','22','23','24','25','26','27','28','29','30')
		and File_Name_Date like '[0-9][0-9][0-9][0-9][0-9][0-9]'
		and File_Name_Date_Cleaned = 0
		and  substring(File_Name_Date,3,2) in ('01','02','03','04','05','06','07','08','09','10','11','12')
	then 	datefromparts(concat(20,left(File_Name_Date,2)),substring(File_Name_Date,3,2),substring(File_Name_Date,5,2))
	
	--11 --13		
	when File_Name_Date_Cleaned = 0
		and len(File_name_Date) = 6 and File_name_Date not like '%.%'
		and File_Name_Date not like '%-%' --and File_Name_Date not like '%_%'
		and right(File_Name_Date,2) in ('19','20','21','22','23','24','25','26','27','28','29','30')
		and File_Name_Date like '[0-9][0-9][0-9][0-9][0-9][0-9]'
		and  substring(File_Name_Date,1,2) in ('01','02','03','04','05','06','07','08','09','10','11','12')
	then datefromparts(concat(20,right(File_Name_Date,2)),left(File_Name_Date,2),substring(File_Name_Date,3,2))

	--12  --5
	when len(File_name_Date) = 6 and File_name_Date not like '%.%'
			and File_Name_Date not like '%-%' --and File_Name_Date not like '%_%'
			and left(File_Name_Date,2) in ('19','20','21','22','23','24','25','26','27','28','29','30')
			and File_Name_Date like '%[0-9][0-9][0-9][0-9][0-9][0-9]%'
			and substring(File_Name_Date,3,2) NOT in ('01','02','03','04','05','06','07','08','09','10','11','12')
	then datefromparts(concat(20,left(File_Name_Date,2)),substring(File_Name_Date,5,2),substring(File_Name_Date,3,2))

	--13  --16
	when File_Name_Date_Cleaned = 0
		and len(File_Name_Date) = 7
		and File_Name_Date like '[0-1][0-9][^A-Za-z0-9][0-9][^A-Za-z0-9][0-9][0-9]'
	then datefromparts(concat(20,right(File_Name_Date,2)),left(File_Name_Date,2),substring(File_Name_Date,4,1))

	--14  --18
	when File_Name_Date_Cleaned = 0
		and File_Name_Date like '[2][0][0-9][0-9][^A-Za-z0-9][0-1][0-9]'
	then datefromparts(left(File_Name_Date,4),right(File_Name_Date,2),1)

	--15 --19
	when File_Name_Date_Cleaned = 0
		and len(File_Name_Date) = 7
		and File_Name_Date like '[0-1][0-9][^A-Za-z0-9][2][0][0-9][0-9]'
	then datefromparts(right(File_Name_Date,4),left(File_Name_Date,2),1)
		
	--16
	when File_Name_Date_Cleaned = 0 
		and File_Name_Date like '[2][0][0-9][0-9][0-1][0-9]'
	then datefromparts(right(File_Name_Date,4),left(File_Name_Date,2),1)

	-- 17 --31
	when File_Name_Date_CLeaned = 0
				and File_Name_date like '%[A-Za-z][A-Za-z][A-Za-z]_[0-9][0-9][0-9][0-9]%'
			then dateFromparts(
											right(File_Name_Date,4),
											case when File_Name_Date like 'Jan%' then 1
												 when File_Name_Date like 'Feb%' then 2
												 when File_Name_Date like 'Mar%' then 3
												 when File_Name_Date like 'Apr%' then 4
												 when File_Name_Date like 'May%' then 5
												 when File_Name_Date like 'Jun%' then 6
												 when File_Name_Date like 'Jul%' then 7
												 when File_Name_Date like 'Aug%' then 8
												 when File_Name_Date like 'Sep%' then 9
												 when File_Name_Date like 'Oct%' then 10
												 when File_Name_Date like 'Nov%' then 11
												 when File_Name_Date like 'Dec%' then 12
												 else 0 end
											,1
											)
			
			else cast(0 as datetime) end;

--------------------------------------------------------------------------------------



	update s
	set s.File_Size = RFN_v4.[FileSize (KB)]
	, s.Raw_File_TimeStamp = RFN_v4.RawFileDateTime
	from 	#temp_staging s
	JOIN WorkBench.dbo.Eligibility_RawFileNames_v4_Combined RFN_v4 
		on s.[File_Name] = RFN_v4.RawFileNameOnly
	where s.[File_Name] like '%.csv' or s.[File_Name] like '%.txt'
		;

	update s
	set s.File_Size = RFN_v4.[FileSize (KB)]
	, s.Raw_File_TimeStamp = RFN_v4.RawFileDateTime
	from 	#temp_staging s
	JOIN WorkBench.dbo.Eligibility_RawFileNames_v4_Combined RFN_v4 
		on s.[File_Name] =  RFN_v4.Cleaned_Name 
	where s.[File_Name] NOT like '%.csv' or s.[File_Name] NOT like '%.txt'
		;

	update s
	set s.New_Relationship = r.Standardized_SubDep_Code
	FROM #temp_staging s
	JOIN [WorkBench].[dbo].[Eligibility_Relationship_Xref] r 
	ON s.Contract = r.Contract_Raw_All_DB
		and s.Relationship_id = r.Relationship_ID;

	select count(distinct [File_Name]) as Unique_Files
	FROM #temp_staging;

	select count(distinct [File_Name]) as [Deleted?]
	FROM #temp_staging
	where is_createddate <> datefromparts(1900,1,1)
	and file_name_date_cleaned <> datefromparts(1900,1,1) 
	and raw_file_timestamp = datefromparts(1900,1,1);

SELECT 'File_Name_Date_Cleaned ENDED' '#temp_staging Update';


--where RawFileDateTime = datefromparts(1900,1,1);
--\\winhsqlelgblty1\EligibilityFiles\AnthemEligibility\WLPprod\WPDNC_MASTER_DNC_20251122.csv

/*8 Combinations/Scenarios of possibilities */
--Scenario					1 |	2 |	3 |	4 |	5 |	6 |	7 |	8
-----------------------------------------------------------
--IS_CreatedDate			Y |	N |	Y |	N |	N |	Y |	Y |	N
-----------------------------------------------------------
--File_Name_Date_Cleaned	Y |	N |	N |	Y |	N |	Y |	N |	Y
-----------------------------------------------------------
--Raw_File_Timestamp		Y |	N |	N |	N |	Y |	N |	Y |	Y

--MAYBE RETHINK TO TAKE FILE NAME CLEANED DATE MORE SERIOUSLY?

SELECT 'Chosen_Date BEGAN' '#temp_staging Update';
	UPDATE #temp_staging
	set Chosen_Date = 
			case 
			--when 	Raw_File_TimeStamp <> datefromparts(1900,1,1) and Raw_File_TimeStamp IS NOT NULL
			--	and IS_CreatedDate <> datefromparts(1900,1,1) and IS_CreatedDate IS NOT NULL
			--	and File_Name_Date_Cleaned <> datefromparts(1900,1,1) and File_Name_Date_Cleaned IS NOT NULL 
			--	and File_Name_Date_Cleaned < Raw_File_TimeStamp AND File_Name_Date_Cleaned < IS_CreatedDate
			--	AND DATEDIFF(DAY,File_Name_Date_Cleaned,Raw_File_TimeStamp) <= 60
			--	then File_Name_Date_Cleaned
			when 
			--Scenario 1A (R-Y, I-Y, F-Y): when all three values are present, pick the lowest
			Raw_File_TimeStamp <> datefromparts(1900,1,1) and Raw_File_TimeStamp IS NOT NULL
			and IS_CreatedDate <> datefromparts(1900,1,1) and IS_CreatedDate IS NOT NULL
			and File_Name_Date_Cleaned <> datefromparts(1900,1,1) and File_Name_Date_Cleaned IS NOT NULL
			and Raw_File_TimeStamp <= IS_CreatedDate
			and Raw_File_TimeStamp <= File_Name_Date_Cleaned
				then cast(Raw_File_TimeStamp as DATE)
			--Scenario 1B (R-Y, I-Y, F-Y):when all three values are present, pick the lowest
			when 	Raw_File_TimeStamp <> datefromparts(1900,1,1) and Raw_File_TimeStamp IS NOT NULL
				and IS_CreatedDate <> datefromparts(1900,1,1) and IS_CreatedDate IS NOT NULL
				and File_Name_Date_Cleaned <> datefromparts(1900,1,1) and File_Name_Date_Cleaned IS NOT NULL 
				and IS_CreatedDate <= Raw_File_TimeStamp
				and IS_CreatedDate <= File_Name_Date_Cleaned
				then CAST(IS_CreatedDate AS DATE)
			--Scenario 1C (R-Y, I-Y, F-Y):when all three values are present, pick the lowest
			when 	Raw_File_TimeStamp <> datefromparts(1900,1,1) and Raw_File_TimeStamp IS NOT NULL
				and IS_CreatedDate <> datefromparts(1900,1,1) and IS_CreatedDate IS NOT NULL
				and File_Name_Date_Cleaned <> datefromparts(1900,1,1) and File_Name_Date_Cleaned IS NOT NULL 
				and File_Name_Date_Cleaned <= Raw_File_TimeStamp
				and File_Name_Date_Cleaned <= IS_CreatedDate
				then CAST(File_Name_Date_Cleaned AS DATE)			--Scenario 4 (R-N, I-N, F-Y) when no other options use File_Name_Date_Cleaned
			when (Raw_File_TimeStamp = datefromparts(1900,1,1) or Raw_File_TimeStamp IS NULL)
				and (IS_CreatedDate = datefromparts(1900,1,1) or IS_CreatedDate IS NULL)
				and File_Name_Date_Cleaned <> datefromparts(1900,1,1) and File_Name_Date_Cleaned IS NOT NULL
				then CAST(File_Name_Date_Cleaned AS DATE)
			--Scenario 3 (R-N, I-Y, F-N) when no other options use this
			when (Raw_File_TimeStamp = datefromparts(1900,1,1) or Raw_File_TimeStamp IS NULL)
				and IS_CreatedDate <> datefromparts(1900,1,1) and IS_CreatedDate IS NOT NULL
				and (File_Name_Date_Cleaned = datefromparts(1900,1,1) or FIle_Name_Date_Cleaned IS NULL)
				then CAST(IS_CreatedDate AS DATE)
			--Scenario 5 (R-Y, I-N, F-N) when no other options use this
			when Raw_File_TimeStamp <> datefromparts(1900,1,1) and Raw_File_TimeStamp IS NOT NULL
				and (IS_CreatedDate = datefromparts(1900,1,1) or IS_CreatedDate IS NULL)
				and (File_Name_Date_Cleaned = datefromparts(1900,1,1) or File_Name_Date_Cleaned IS NULL)
				then Raw_File_TimeStamp
			--Scenario 6 (R-N, I-Y, F-Y) when there is no raw file date
			when (Raw_File_TimeStamp = datefromparts(1900,1,1) or Raw_File_TimeStamp IS NULL)
				and IS_CreatedDate <> datefromparts(1900,1,1) and IS_CreatedDate IS NOT NULL
				and File_Name_Date_Cleaned <> datefromparts(1900,1,1) and File_name_Date_Cleaned IS NOT NULL
				and File_Name_Date_Cleaned <= IS_CreatedDate
				then CAST(File_Name_Date_Cleaned AS DATE)
			--Scenario 7A (R-Y, I-Y, F-N) when there is no file name date
			when Raw_File_TimeStamp <> datefromparts(1900,1,1) and Raw_File_TimeStamp IS NOT NULL
				and IS_CreatedDate <> datefromparts(1900,1,1) and IS_CreatedDate IS NOT NULL
				and (File_Name_Date_Cleaned = datefromparts(1900,1,1) or File_Name_Date_Cleaned IS NULL)
				and IS_CreatedDate <= Raw_File_TimeStamp
				then CAST(IS_CreatedDate AS DATE)
			--Scenario 7B (R-Y, I-Y, F-N) when there is no file name date
			when Raw_File_TimeStamp <> datefromparts(1900,1,1) and Raw_File_TimeStamp IS NOT NULL
				and IS_CreatedDate <> datefromparts(1900,1,1) and IS_CreatedDate IS NOT NULL
				and (File_Name_Date_Cleaned = datefromparts(1900,1,1) OR File_Name_Date_Cleaned IS NULL)
					and Raw_File_TimeStamp <= IS_CreatedDate
				then CAST(Raw_File_TimeStamp AS DATE)
			--Scenario 8A (R-Y, I-Y, F-N) when there is no IS date; 0 examples as of 2026/06/22
			when Raw_File_TimeStamp <> datefromparts(1900,1,1) and Raw_File_TimeStamp IS NOT NULL
				 and (
						IS_CreatedDate = datefromparts(1900,1,1) OR IS_CreatedDate IS NULL
					  )
				 and File_Name_Date_Cleaned <> datefromparts(1900,1,1) and FIle_Name_Date_Cleaned IS NOT NULL
				 AND Raw_File_TimeStamp <= File_Name_Date_Cleaned
				then CAST(Raw_File_TimeStamp AS DATE)
			--Scenario 8B (R-Y, I-Y, F-N) when there is no IS date; 0 examples as of 2026/06/22
			when Raw_File_TimeStamp <> datefromparts(1900,1,1)  and Raw_File_TimeStamp IS NOT NULL
				and 
					(IS_CreatedDate = datefromparts(1900,1,1) OR IS_CreatedDate IS NULL)
				and File_Name_Date_Cleaned <> datefromparts(1900,1,1) and File_Name_Date_Cleaned IS NOT NULL
					and File_Name_Date_Cleaned <= Raw_File_TimeStamp
				then CAST(File_Name_Date_Cleaned AS DATE)
			else CAST(Chosen_Date AS DATE) end;

SELECT 'Chosen_Date ENDED' '#temp_staging Update';

--SELECT * FROM #temp_staging;
--SELECT * FROM #temp_staging;

SELECT 'Chosen_Date_Year_Month BEGAN' '#temp_staging Update';
UPDATE #temp_staging
set Chosen_Date_Year_Month = concat(year(Chosen_date),format(month(Chosen_Date),'00'))
	--, Chosen_Date_Year = year(Chosen_Date)
;
SELECT 'Chosen_Date_Year_Month ended' '#temp_staging Update';



select 'DELETE ALREADY EXISTING RECORDS FROM PREUPLOAD' '#temp_staging BEGIN';
DELETE t
FROM #temp_staging t
INNER JOIN WorkBench.dbo.Eligibility_ALL_RAW s
on s.[Contract] = t.[Contract]
			and s.Member_ID = t.Member_ID
			and s.Relationship_ID = t.Relationship_ID
			and s.First_Name = t.First_Name
			and s.Last_Name = t.Last_Name
			and s.Email = t.Email
			and s.Main_Phone = t.Main_Phone
			and s.Street_Address = t.Street_Address
			and s.Address_2 = t.Address_2
			and s.City = t.City
			and s.[State] = t.[State] 
			and s.Zip = t.Zip
			and s.Date_of_Birth = t.Date_of_Birth
			and s.Coverage_Start_Date = t.Coverage_Start_Date
			and s.Coverage_End_Date = t.Coverage_End_date
			and s.Gender = t.Gender
			and s.Active_Indicator = t.Active_Indicator
			and s.[File_Name] = t.[File_Name]
			and s.Source_Table = t.Source_Table
			and s.File_Size = t.File_Size
			and s.IS_CreatedDate = t.IS_CreatedDate
			and s.File_Name_Date = t.File_Name_Date
			and s.File_Name_Date_Cleaned = t.File_Name_Date_Cleaned
			and s.Raw_File_TimeStamp = t.Raw_File_TimeStamp
			and s.Chosen_Date = t.Chosen_Date 
			and s.Chosen_date_Year_Month = t.Chosen_Date_Year_Month
	--		and s.Month_Order = t.Month_Order
;
select 'DELETE ALREADY EXISTING RECORDS FROM PREUPLOAD' '#temp_staging END';

SELECT 'DROP INDEX BEGIN' '[Contract]';
DROP INDEX [Contract] ON [dbo].[Eligibility_All_RAW]
SELECT 'DROP INDEX BEGIN' '[File_Name]';
DROP INDEX [File_Name] ON [dbo].[Eligibility_All_RAW]
SELECT 'DROP INDEX BEGIN' '[File_Name_Date_Cleaned]';
DROP INDEX [File_Name_Date_Cleaned] ON [dbo].[Eligibility_All_RAW]
SELECT 'DROP INDEX BEGIN' '[Member_ID]';
DROP INDEX [Member_ID] ON [dbo].[Eligibility_All_RAW]


SELECT 'CREATE INDEX BEGIN' '[Contract]';
CREATE NONCLUSTERED INDEX [Contract] ON [dbo].[Eligibility_All_RAW]
(
	[Contract] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

SELECT 'CREATE INDEX BEGIN' '[File_Name]';
CREATE NONCLUSTERED INDEX [File_Name] ON [dbo].[Eligibility_All_RAW]
(
	[File_Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

SELECT 'CREATE INDEX BEGIN' '[File_Name_Date_CLEANED]';
CREATE NONCLUSTERED INDEX [File_Name_Date_Cleaned] ON [dbo].[Eligibility_All_RAW]
(
	[File_Name_Date_CLEANED] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

SELECT 'CREATE INDEX BEGIN' '[Member_ID]';
CREATE NONCLUSTERED INDEX [Member_ID] ON [dbo].[Eligibility_All_RAW]
(
	[Member_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]



SELECT 'INSERT INTO - BEGAN' 'Eligibility_ALL_RAW';
INSERT INTO WorkBench.dbo.Eligibility_ALL_RAW 
(  [Contract], Member_ID, Relationship_ID, New_Relationship, First_Name, Last_Name, Email	, Main_Phone, Street_Address
		, Address_2, City, [State], Zip, Date_of_Birth, Coverage_Start_Date, Coverage_End_Date, Gender, Active_Indicator
		, [File_Name], Source_Table, File_Size, IS_CreatedDate , File_Name_Date
		, File_Name_Date_Cleaned, Raw_File_TimeStamp, Chosen_Date
		, Chosen_Date_Year_Month--, Chosen_Date_Year--, Month_Order
		)
SELECT [Contract], Member_ID, Relationship_ID, New_Relationship, First_Name, Last_Name, Email	, Main_Phone, Street_Address
		, Address_2, City, [State], Zip, Date_of_Birth, Coverage_Start_Date, Coverage_End_Date, Gender, Active_Indicator
		, [File_Name], Source_Table, File_Size, IS_CreatedDate , File_Name_Date
		, File_Name_Date_Cleaned, Raw_File_TimeStamp, Chosen_Date
		, Chosen_Date_Year_Month--, Chosen_Date_Year--, Month_Order
		
FROM #temp_staging
;
SELECT 'INSERT INTO - ENDED' 'Eligibility_ALL_RAW';


drop TABLE IF EXISTS #Distinct_File_Names;

SELECT 'CREATION BEGUN' '#Distinct_File_Names';
WITH DISTINCT_ROWS AS
  (
		SELECT --TOP (1000) 
		DISTINCT
	   [Contract]
      ,[Source_Table]
      ,[File_Name]
      ,[File_Size]
      ,[IS_CreatedDate]
      ,[File_Name_Date]
      ,[File_Name_Date_CLEANED]
      ,[Raw_File_TimeStamp]
      ,[Chosen_Date]
	  , Chosen_Date_Year_Month
	   FROM WorkBench.dbo.Eligibility_ALL_RAW --#temp_staging
  )
  SELECT * 
	,	row_number() over
	(
		partition by Contract
			, Chosen_Date_Year_Month
		order by Contract, Chosen_Date_Year_Month, Chosen_Date
	)
		as Month_Order
  INTO #Distinct_File_Names 
  from DISTINCT_ROWS 
;
SELECT 'CREATION ENDED' '#Distinct_File_Names';


DROP TABLE IF EXISTS #change_file_base;
SELECT 'CREATION BEGUN' '#change_file_base';

SELECT DISTINCT
	 [File_Name]
	 , IS_CreatedDate
	 , File_Name_Date_Cleaned
	 , Raw_File_TimeStamp
	 , Chosen_Date
	 , Contract
	 , Chosen_Date_Year_Month
	 , Month_Order
	 , Order_Desc
	 , File_Size
	 , cast(0 as int) as RecordCt
	 , cast('' as Varchar(500)) as File_Type
	 , cast(0 as float) as Deviation_from_max_monthly
into #change_file_base
 FROM WorkBench.dbo.Eligibility_ALL_RAW
 order by Contract, Chosen_Date
 ;
 SELECT 'CREATION ENDED' '#change_file_base';

 SELECT 'RecordCt UPDATE BEGUN' '#change_file_base';
 update c
	SET RecordCt = rfn.RecordCt
 FROM #change_file_base c
 LEFT JOIN [WorkBench].[dbo].[Eligibility_RawFileNames] rfn
	on  c.[File_Name] = case when  c.[File_Name] like '%.txt' 
						or c.[File_Name] like '%.csv'
		then rfn.RawFileNameOnly
		else replace(replace(rfn.RawFileNameOnly,'.txt',''),'.csv','')
		END ;
 SELECT 'RecordCt UPDATE ENDED' '#change_file_base';

 select 'Record Count' '#change_file_base';
 select * from #change_file_base;

 SELECT 'RecordCt Update' '#change_file_base';
  update c
	SET RecordCt = rfn.RecordCt
 FROM #change_file_base c
 LEFT JOIN [WorkBench].[dbo].[Eligibility_RawFileNames] rfn
	on  c.[File_Name] = case when  c.[File_Name] like '%.txt' 
						or c.[File_Name] like '%.csv'
		then rfn.RawFileNameOnly
		else replace(replace(rfn.RawFileNameOnly,'.txt',''),'.csv','')
		END ;

 SELECT 'RecordCt Update round 2 begin' '#change_file_base';
with new_count as
(
	select 
		  c.Contract
		, c.[File_Name]
		, count(distinct concat(e.Member_ID, e.Relationship_ID, e.First_Name)) as new_total 
	FROM #change_file_base c
	JOIN WorkBench.dbo.Eligibility_ALL_RAW e
		on c.Contract = e.Contract 
			and c.[File_Name] = e.[File_Name]
	group by c.Contract
		, c.[File_Name]
)
  update c
	SET RecordCt = nc.new_total
 FROM #change_file_base c
 JOIN new_count nc
	on c.Contract = nc.Contract 
		and c.[File_Name] = nc.[File_Name]
where c.RecordCt IS NULL;
 SELECT 'RecordCt Update round 2 end' '#change_file_base';


  SELECT 'Deviation_from_max_monthly Update begin' '#change_file_base';
with MonthlyMax as
(
	SELECT 
		Contract
		, Chosen_date_Year_Month
		--, Month_Order
		--, RecordCt
		--, Order_Desc
		, MAX(RecordCt) as Max_Monthly_Record--OVER (PARTITION BY Contract, Chosen_date_Year_Month ORDER BY Month_Order) AS PriorRecordCt
	FROM #change_file_base
		group by 	Contract
		, Chosen_date_Year_Month
)
UPDATE cb
	set Deviation_from_max_monthly =
		case --when cb.Order_Desc in ('First & Last','First') then 0
		 when (mm.Max_Monthly_Record = 0 or mm.Max_Monthly_Record IS NULL) and cb.RecordCt = 0 then 0
		 --when (mm.Max_Monthly_Record = 0 or mm.Max_Monthly_Record IS NULL) and cb.RecordCt > 0 then 1
	else --cast(
	((cb.RecordCt - mm.Max_Monthly_Record)*1.0/mm.Max_Monthly_Record*1.0)-- as decimal(18,6))
	END
FROM #change_file_base cb
LEFT JOIN MonthlyMax mm
	on cb.Contract = mm.Contract
		and cb.Chosen_date_Year_Month = mm.Chosen_Date_Year_Month
--		and cb.Month_Order = mm.Month_Order
;
  SELECT 'Deviation_from_max_monthly Update end' '#change_file_base';

  SELECT 'File_Type Update begin' '#change_file_base';
 UPDATE #change_file_base 
 SET File_Type = case when Deviation_from_Max_Monthly > -.10 then 'Full File'
					  when Deviation_from_Max_Monthly < -.10 then 'Change File'
					  else 'BLANK FILE'
				end;
  SELECT 'File_Type Update end' '#change_file_base';


  SELECT 'Table_Type Update begin' '#change_file_base';
UPDATE ear
set ear.Table_Type = cfb.File_Type
FROM WorkBench.dbo.Eligibility_ALL_RAW ear
JOIN #change_file_base cfb
	on ear.Contract = cfb.Contract
		and ear.[File_Name] = cfb.[File_Name]
		and ear.Chosen_Date = cfb.Chosen_Date;
  SELECT 'Table_Type Update end' '#change_file_base';


SELECT TOP 1000 * FROM WorkBench.dbo.Eligibility_ALL_RAW

SELECT distinct
	  Contract
	, Chosen_Date
	, Chosen_date_year_month
	, Month_Order
	--, Order_Desc
    FROM [WorkBench].[dbo].[Eligibility_All_RAW] ear
--where contract like '%Latham%'
order by   Contract
	, Chosen_Date
	, Month_Order
;

;


--END

	
select distinct 
	  [File_Name]
	, file_name_date
	, file_name_date_cleaned
	, is_createddate
	, raw_file_timestamp
	, Chosen_Date
	, case 	
		when (datediff(day,Chosen_Date, raw_file_timestamp)>10 and raw_file_timestamp <> datefromparts(1900,1,1)) 
				then 'Raw File TimeStamp Diff'
		   when (datediff(day,Chosen_Date, file_name_date_cleaned)>10 and file_name_date_cleaned <> datefromparts(1900,1,1)) 
				then 'File_name_Date_Cleaned Issue'
			when (datediff(day,Chosen_Date, IS_CreatedDate)>10 and IS_CreatedDate <> datefromparts(1900,1,1)) 
				then 'IS Date Issue'
			else '' end
			as [Raises Flags?]
	, count(*) as [Count]
	FROM WorkBench.dbo.Eligibility_ALL_RAW
	where (datediff(day,Chosen_Date, IS_CreatedDate)>10 and IS_CreatedDate <> datefromparts(1900,1,1)) 
				OR (datediff(day,Chosen_Date, file_name_date_cleaned)>10 and file_name_date_cleaned <> datefromparts(1900,1,1)) 
				OR (datediff(day,Chosen_Date, raw_file_timestamp)>10 and raw_file_timestamp <> datefromparts(1900,1,1)) 
	GROUP BY is_createddate, [File_Name], file_name_date, file_name_date_cleaned, raw_file_timestamp, Chosen_Date
	order by 
		case 	
		when (datediff(day,Chosen_Date, raw_file_timestamp)>10 and raw_file_timestamp <> datefromparts(1900,1,1)) 
				then 'Raw File TimeStamp Diff'
		   when (datediff(day,Chosen_Date, file_name_date_cleaned)>10 and file_name_date_cleaned <> datefromparts(1900,1,1)) 
				then 'File_name_Date_Cleaned Issue'
			when (datediff(day,Chosen_Date, IS_CreatedDate)>10 and IS_CreatedDate <> datefromparts(1900,1,1)) 
				then 'IS Date Issue'
			else '' end
;
