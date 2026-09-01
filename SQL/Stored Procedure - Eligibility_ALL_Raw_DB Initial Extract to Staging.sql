USE [WorkBench]
GO

CREATE PROCEDURE [dbo].[sp_Eligibility_Aggregation_RAW_Load_to_Staging]

AS BEGIN

DROP TABLE IF EXISTS WorkBench.dbo.Eligibility_ALL_RAW_DB_STAGING;
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
, cast(0 as int) as File_Size
, i.IS_CreatedDate
, cast(0 as NVARCHAR(MAX)) AS File_Name_Date
, cast(0 as DATETIME) AS File_Name_Date_CLEANED
, cast(0 as DATETIME) AS Raw_File_TimeStamp
, cast(0 as DATETIME) AS Chosen_Date
INTO WorkBench.dbo.Eligibility_ALL_RAW_DB_STAGING
FROM WorkBench.dbo.xxEligibility_All_RAW--Eligibility_ALL_Raw_DB_Extraction 
i
;
select count(*) as xxEligibility_All_RAW_Count from WorkBench.dbo.xxEligibility_All_RAW;
select top 200 * from WorkBench.dbo.Eligibility_ALL_RAW_DB_STAGING;


  ------ FILE NAME DATE - COMBINING ALL REGEX LOGIC FROM "File_Name_Date_RegEx.sql":
  UPDATE WorkBench.dbo.Eligibility_ALL_RAW_DB_STAGING
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

	select count(*) as xxEligibility_All_RAW_Count from WorkBench.dbo.xxEligibility_All_RAW;
	--NO INCREASES
	select top 200 * from WorkBench.dbo.Eligibility_ALL_RAW_DB_STAGING;


UPDATE WorkBench.dbo.Eligibility_ALL_RAW_DB_STAGING
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
	from 	WorkBench.dbo.Eligibility_ALL_RAW_DB_STAGING s
	JOIN WorkBench.dbo.Eligibility_RawFileNames_v4_Combined RFN_v4 
		on s.[File_Name] = RFN_v4.RawFileNameOnly
	where s.[File_Name] like '%.csv' or s.[File_Name] like '%.txt'
		;

	update s
	set s.File_Size = RFN_v4.[FileSize (KB)]
	, s.Raw_File_TimeStamp = RFN_v4.RawFileDateTime
	from 	WorkBench.dbo.Eligibility_ALL_RAW_DB_STAGING s
	JOIN WorkBench.dbo.Eligibility_RawFileNames_v4_Combined RFN_v4 
		on s.[File_Name] =  RFN_v4.Cleaned_Name 
	where s.[File_Name] NOT like '%.csv' or s.[File_Name] NOT like '%.txt'
		;



/*8 Combinations/Scenarios of possibilities */
--Scenario					1 |	2 |	3 |	4 |	5 |	6 |	7 |	8
-----------------------------------------------------------
--IS_CreatedDate			Y |	N |	Y |	N |	N |	Y |	Y |	N
-----------------------------------------------------------
--File_Name_Date_Cleaned	Y |	N |	N |	Y |	N |	Y |	N |	Y
-----------------------------------------------------------
--Raw_File_Timestamp		Y |	N |	N |	N |	Y |	N |	Y |	Y


select count(distinct [File_Name]) as Deleted_Files
from WorkBench.dbo.Eligibility_ALL_RAW_DB_STAGING
	where Raw_File_TimeStamp = datefromparts(1900,1,1) 
		and IS_CreatedDate <> datefromparts(1900,1,1) 
		and File_Name_Date_Cleaned <> datefromparts(1900,1,1)

select count(distinct [File_Name]) as All_Files
from WorkBench.dbo.Eligibility_ALL_RAW_DB_STAGING


select distinct top 2000 [Contract], [File_Name]
from WorkBench.dbo.Eligibility_ALL_RAW_DB_STAGING
	where Raw_File_TimeStamp = datefromparts(1900,1,1) 
		and IS_CreatedDate <> datefromparts(1900,1,1) 
		and File_Name_Date_Cleaned <> datefromparts(1900,1,1)
	
	UPDATE WorkBench.dbo.Eligibility_ALL_RAW_DB_STAGING
	set Chosen_Date = 
		case when 
			--Scenario 1 (R-Y, I-Y, F-Y): when all three values are present and the raw file time stamp is lower than IS', it's the most reliable
			Raw_File_TimeStamp <> datefromparts(1900,1,1) and IS_CreatedDate <> datefromparts(1900,1,1) and File_Name_Date_Cleaned <> datefromparts(1900,1,1) and Raw_File_TimeStamp <= IS_CreatedDate
				then Raw_File_TimeStamp
			--Scenario 1B (R-Y, I-Y, F-Y):when all three values are present and the raw file time stamp > IS', it likely means it was re-saved after its original date
				-- (File_Name_Date helped validate this in samples were RawFileStamp > IS)
			when Raw_File_TimeStamp <> datefromparts(1900,1,1) and IS_CreatedDate <> datefromparts(1900,1,1) and File_Name_Date_Cleaned <> datefromparts(1900,1,1) and Raw_File_TimeStamp >= IS_CreatedDate
				then IS_CreatedDate
			--Scenario 4 (R-N, I-N, F-Y) when no other options use File_Name_Date_Cleaned
			when Raw_File_TimeStamp = datefromparts(1900,1,1) and IS_CreatedDate = datefromparts(1900,1,1) and File_Name_Date_Cleaned <> datefromparts(1900,1,1) 
				then File_Name_Date_Cleaned
			--Scenario 3 (R-N, I-Y, F-N) when no other options use this
			when Raw_File_TimeStamp = datefromparts(1900,1,1) and IS_CreatedDate <> datefromparts(1900,1,1) and File_Name_Date_Cleaned = datefromparts(1900,1,1) 
				then IS_CreatedDate
			--Scenario 5 (R-Y, I-N, F-N) when no other options use this
			when Raw_File_TimeStamp <> datefromparts(1900,1,1) and IS_CreatedDate = datefromparts(1900,1,1) and File_Name_Date_Cleaned = datefromparts(1900,1,1) 
				then Raw_File_TimeStamp
			--Scenario 6 (R-N, I-Y, F-Y) when there is no raw file date
			when Raw_File_TimeStamp = datefromparts(1900,1,1) and IS_CreatedDate <> datefromparts(1900,1,1) and File_Name_Date_Cleaned <> datefromparts(1900,1,1)
					and File_Name_Date_Cleaned <= IS_CreatedDate
				then File_Name_Date_Cleaned
			--Scenario 7A (R-Y, I-Y, F-N) when there is no file name date
			when Raw_File_TimeStamp <> datefromparts(1900,1,1) and IS_CreatedDate <> datefromparts(1900,1,1) and File_Name_Date_Cleaned = datefromparts(1900,1,1)
				and IS_CreatedDate <= Raw_File_TimeStamp
				then IS_CreatedDate
			--Scenario 7B (R-Y, I-Y, F-N) when there is no file name date
			when Raw_File_TimeStamp <> datefromparts(1900,1,1) and IS_CreatedDate <> datefromparts(1900,1,1) and File_Name_Date_Cleaned = datefromparts(1900,1,1)
					and Raw_File_TimeStamp <= IS_CreatedDate
				then Raw_File_TimeStamp
			--Scenario 8A (R-Y, I-Y, F-N) when there is no IS date; 0 examples as of 2026/06/22
			when Raw_File_TimeStamp <> datefromparts(1900,1,1) and IS_CreatedDate = datefromparts(1900,1,1) and File_Name_Date_Cleaned <> datefromparts(1900,1,1)
				 AND Raw_File_TimeStamp <= File_Name_Date_Cleaned
				then Raw_File_TimeStamp
			--Scenario 8B (R-Y, I-Y, F-N) when there is no IS date; 0 examples as of 2026/06/22
			when Raw_File_TimeStamp <> datefromparts(1900,1,1) and IS_CreatedDate = datefromparts(1900,1,1) and File_Name_Date_Cleaned <> datefromparts(1900,1,1)
					and File_Name_Date_Cleaned <= Raw_File_TimeStamp
				then Raw_File_TimeStamp
			else Chosen_Date end;


	;
/*QC'ING THE LOGIC*/
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
	FROM WorkBench.dbo.Eligibility_ALL_RAW_DB_STAGING
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

END

