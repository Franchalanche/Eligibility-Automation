/*GW*/


drop table if exists #unique_files;
select distinct [FILE_NAME]
      ,[TIME_OF_ENTRY]  
into #unique_files
FROM [CIGNAIL_Eligibility_Staging].[dbo].[GW_CIGNAIL_WINFERT_RAWFILE]
;


drop table if exists #first_Files;
with earliest_monthly_file as
(
	select month(Time_of_Entry) as Mth
	, year(Time_of_Entry) as Yr
	, min(TIME_OF_ENTRY) as First_File_Date
	FROM #unique_files
	where year(Time_of_Entry) = 2026
	group by month(Time_of_Entry) --as Mth
	, year(Time_of_Entry)
)
select emf.*
, uf.FILE_Name
into #first_Files
FROM earliest_monthly_file emf
JOIN #unique_files uf
	on emf.First_File_Date = uf.Time_of_Entry
	;


UPDATE #first_files
SET First_File_Date = '2026-07-02 00:04:18.210'
	, [File_Name] = 'winf_mnthly_elig_extract_20260701_220020.txt'
WHERE Mth = 7
;

UPDATE #first_files
SET First_File_Date = '2026-06-02 00:08:42.707'
	, [File_Name] = 'winf_mnthly_elig_extract_20260601_220019.txt'
WHERE Mth = 6
;

UPDATE #first_files
SET First_File_Date =  '2026-05-04 00:05:29.683'
	, [File_Name] = 'winf_mnthly_elig_extract_20260502_220019.txt'
WHERE Mth = 5
;

UPDATE #first_files
SET First_File_Date = '2026-04-02 00:16:45.513'
	, [File_Name] = 'winf_mnthly_elig_extract_20260401_220016.txt'
WHERE Mth = 4
;

UPDATE #first_files
SET First_File_Date = '2026-02-03 00:20:16.413' 
	, [File_Name] = 'winf_mnthly_elig_extract_20260202_220016.txt'
WHERE Mth = 2
;

UPDATE #first_files
SET First_File_Date = '2026-01-09 00:17:15.547' 
	, [File_Name] = 'winf_mnthly_elig_extract_20260107_220020.txt'
WHERE Mth = 1
;
	
DROP TABLE IF EXISTS #GW_Cigna_Base;
select ff.*
	, MEMB_SUBSCRIBER_NUMBER
	, [FILE_MEMB_SUBSCRIBER_NUMBER]
	, MIN(MEMB_ENROLL_DATE) AS MEMB_ENROLL_DATE
	, MAX(MEMB_TERM_DATE) AS MEMB_TERM_DATE
INTO #GW_Cigna_Base
FROM #first_Files ff
join [CIGNAIL_Eligibility_Staging].[dbo].[GW_CIGNAIL_WINFERT_RAWFILE] e
	on ff.[File_Name] = e.[File_Name]
--WHERE 	  year(Time_of_ENtry) = 2026 
GROUP BY ff.Mth
	, ff.Yr
	, Ff.First_File_Date
	, ff.[File_Name]
	, MEMB_SUBSCRIBER_NUMBER
	, [FILE_MEMB_SUBSCRIBER_NUMBER]
;

drop table if exists #GW_Cigna_Base_2;

select gw.*
	, case when year(memb_enroll_date) < Yr 
				and year(memb_term_date) > Yr
			then 1
	       when year(memb_enroll_date) < Yr 
				and year(memb_term_date) = Yr
				and month(memb_term_date) >= Mth
			then 1
		   when year(memb_enroll_date) = Yr 
				and month(memb_enroll_date) <= Mth
				and year(memb_term_date) >= Yr
				--and month(memb_term_date) >= Mth
			then 1
		   when year(memb_enroll_date) = Yr 
				and month(memb_enroll_date) <= Mth
				and year(memb_term_date) = Yr
				and month(memb_term_date) >= Mth
			then 1
		else 0 end
		as Eligible
 into #GW_Cigna_Base_2
 from #GW_Cigna_Base gw
 ;

select 'summary' '#GW_Cigna_Base_2';
SELECT
	  Mth
	, Yr
	, COUNT(DISTINCT [FILE_MEMB_SUBSCRIBER_NUMBER]) AS Total_Count
	, COUNT(DISTINCT MEMB_SUBSCRIBER_NUMBER) AS Employees
	, COUNT(DISTINCT [FILE_MEMB_SUBSCRIBER_NUMBER]) - COUNT(DISTINCT MEMB_SUBSCRIBER_NUMBER) as Dependents
FROM #GW_Cigna_Base_2
WHERE 
	  Eligible = 1 
group by 
	  Mth
	, Yr
order by 
	  Mth
	, Yr
;

/*CE*/
--ONLY HAS AUGUST 2026
-- DOESN'T HAVE FILE NAMES
DROP TABLE IF EXISTS #CE_Cigna_Base;
select 
	month(CreatedDate) as Mth
	, year(CreatedDate) as Yr
	, case 
		when len(MEMB_SUBSCRIBER_NUMBER) > 2 
			then left(MEMB_SUBSCRIBER_NUMBER, len(MEMB_SUBSCRIBER_NUMBER)-2) 
		else MEMB_SUBSCRIBER_NUMBER end 
			AS Unique_Employee_ID
	, MEMB_SUBSCRIBER_NUMBER as Unique_ID
	, min(memb_cov_start_Date) as memb_cov_start_Date
	, max(memb_cov_end_date) as memb_cov_end_date
INTO #CE_Cigna_Base
FROM [CIGNAIL_Eligibility_Staging].[dbo].[CE_CIGNAIL_WINFERT_RAWFILE_STAGING]
where year(CreatedDate) = 2026
group by 	month(CreatedDate) -- Mth
	, year(CreatedDate) --as Yr
	, case when len(MEMB_SUBSCRIBER_NUMBER) > 2 
			then left(MEMB_SUBSCRIBER_NUMBER, len(MEMB_SUBSCRIBER_NUMBER)-2) 
		else MEMB_SUBSCRIBER_NUMBER end 
	, MEMB_SUBSCRIBER_NUMBER -- Unique_ID
  

drop table if exists #CE_Cigna_Base_2;

select CE.*
	, case when year(memb_cov_start_Date) < Yr 
				and year(memb_cov_end_date) > Yr
			then 1
	       when year(memb_cov_start_Date) < Yr 
				and year(memb_cov_end_date) = Yr
				and month(memb_cov_end_date) >= Mth
			then 1
		   when year(memb_cov_start_Date) = Yr 
				and month(memb_cov_start_Date) <= Mth
				and year(memb_cov_end_date) >= Yr
				--and month(memb_cov_end_date) >= Mth
			then 1
		   when year(memb_cov_start_Date) = Yr 
				and month(memb_cov_start_Date) <= Mth
				and year(memb_cov_end_date) = Yr
				and month(memb_cov_end_date) >= Mth
			then 1
		else 0 end
		as Eligible
 into #CE_Cigna_Base_2
 from #CE_Cigna_Base CE
 ;

 select 'summary' '#CE_Cigna_Base_2';
SELECT
	  Mth
	, Yr
	, COUNT(DISTINCT Unique_ID) AS Total_Count
	, COUNT(DISTINCT Unique_Employee_ID) AS Employees
	, COUNT(DISTINCT Unique_ID) - COUNT(DISTINCT Unique_Employee_ID) as Dependents
FROM #CE_Cigna_Base_2
WHERE 
	  Eligible = 1 
group by 
	  Mth
	, Yr
order by 
	  Mth
	, Yr
;
