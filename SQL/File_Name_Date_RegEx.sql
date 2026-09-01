--select distinct
--[File_Name] 
--from Workbench.dbo.xxEligibility_All_RAW;

drop table if exists #date_substring;
select distinct
[File_Name] 
, cast(0 as nvarchar(max))  as YYYYMMDD
into #date_substring
from Workbench.dbo.xxEligibility_All_RAW
;
select * from #date_substring;


update #date_substring
SET YYYYMMDD = substring([File_Name],patindex('%[_][0-9][0-9][0-9][0-9][0-9][0-9][_]%',[File_Name])+1,6)
where YYYYMMDD = 0 
	and [File_Name]  like '05712109%'
	
select * from #date_substring
where [File_Name]  like '05712109%'

update #date_substring
SET YYYYMMDD = substring([File_Name],PATINDEX('%[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]%',[File_Name]),8)
where YYYYMMDD = 0
	and [File_Name] like '%[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]%'
	--and [File_Name] NOT like '05712109%'
	;

select * from #date_substring;

select * from #date_substring
where YYYYMMDD not like '%[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]%';

--update #date_substring
--SET YYYYMMDD = ''
--where YYYYMMDD not like '%[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]%'

--select * from #date_substring;

--select * from #date_substring
--where YYYYMMDD not like '%[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]%';

	

update #date_substring
SET YYYYMMDD = substring([File_Name],patindex('%[0-9][0-9][0-9][0-9][0-9][0-9]%',[File_Name]),6)
where YYYYMMDD = 0 and [File_Name] like '%[0-9][0-9][0-9][0-9][0-9][0-9]%'
	and [File_Name] NOT like '05712109%'

select * from #date_substring
where [File_Name] not like '%[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]%'
and  [File_Name] like '%[0-9][0-9][0-9][0-9][0-9][0-9]%'

select * from #date_substring
where YYYYMMDD = 0
;

update #date_substring
set YYYYMMDD = substring([File_Name], patindex( '%[0-9][0-9][0-9][0-9]_[0-9][0-9]_[0-9][0-9]%',[File_Name]),10)
where YYYYMMDD = 0 and [File_Name] like '%[0-9][0-9][0-9][0-9]_[0-9][0-9]_[0-9][0-9]%' 
and [File_Name] NOT like '%AM'
and [File_Name] NOT like '%PM'
;


select * from #date_substring
where [File_Name] like '%[0-9][0-9][0-9][0-9]_[0-9][0-9]_[0-9][0-9]%'
	and  [File_Name] not like '%[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]%'

select * from #date_substring
where YYYYMMDD = '0'
;


update #date_substring
set YYYYMMDD = substring([File_Name], patindex( '%[0-9][0-9][0-9][0-9]_[0-9][0-9]%',[File_Name]),7)
where YYYYMMDD = '0' and [File_Name] like '%[0-9][0-9][0-9][0-9]_[0-9][0-9]%'

select * from #date_substring
where len(YYYYMMDD) = 7 --
--select * from #date_substring
--where [File_Name] like '%[0-9][0-9][0-9][0-9]_[0-9][0-9]%'
--and  [File_Name]  like '%[0-9][0-9][0-9][0-9]_[0-9][0-9]_[^0-9]%'

select * from #date_substring
where YYYYMMDD = '0'
;

update #date_substring
set YYYYMMDD = substring([File_Name], patindex( '%[0-9][0-9]_[0-9][0-9]_[0-9][0-9][0-9][0-9]%',[File_Name]),10)
where YYYYMMDD = '0' and [File_Name] like '%[0-9][0-9]_[0-9][0-9]_[0-9][0-9][0-9][0-9]%';


select * from #date_substring
where [File_Name] like '%[0-9][0-9]_[0-9][0-9]_[0-9][0-9][0-9][0-9]%'
and len(YYYYMMDD)=10;

select * from #date_substring
where YYYYMMDD = '0'
;

update #date_substring
set YYYYMMDD = substring([File_Name], patindex( '%[0-9]_[0-9][0-9]_[0-9][0-9][0-9][0-9]%',[File_Name]),9)
where YYYYMMDD = '0' and [File_Name] like '%[0-9]_[0-9][0-9]_[0-9][0-9][0-9][0-9]%';

select * from #date_substring
where YYYYMMDD = '0'
;


update #date_substring
set YYYYMMDD = substring([File_Name], patindex( '%[0-9]_[0-9]_[0-9][0-9][0-9][0-9]%',[File_Name]),8)
where YYYYMMDD = '0' and [File_Name] like '%[0-9]_[0-9]_[0-9][0-9][0-9][0-9]%';

select * from #date_substring
where YYYYMMDD = '0'
;

update #date_substring
set YYYYMMDD = substring([File_Name], patindex( '%[0-9][0-9]_[0-9][0-9]_[0-9][0-9]%',[File_Name]),8)
where YYYYMMDD = '0' and [File_Name] like '%[0-9][0-9]_[0-9][0-9]_[0-9][0-9]%';

select * from #date_substring
where YYYYMMDD = '0'
;

update #date_substring
set YYYYMMDD = substring([File_Name], patindex( '%[0-9][0-9]_[0-9]_[0-9][0-9]%',[File_Name]),8)
where YYYYMMDD = '0' and [File_Name] like '%[0-9][0-9]_[0-9]_[0-9][0-9]%';

select * from #date_substring
where YYYYMMDD = '0'
;

update #date_substring
set YYYYMMDD = substring([File_Name], patindex( '%[0-9]_[0-9][0-9]_[0-9][0-9]%',[File_Name]),7)
where YYYYMMDD = '0' and [File_Name] like '%[0-9]_[0-9][0-9]_[0-9][0-9]%';

select * from #date_substring
where YYYYMMDD = '0'
;

update #date_substring
set YYYYMMDD = substring([File_Name], patindex( '%[0-9]_[0-9]_[0-9][0-9]%',[File_Name]),6)
where YYYYMMDD = '0' and [File_Name] like '%[0-9]_[0-9]_[0-9][0-9]%';

select * from #date_substring
where YYYYMMDD = '0'
and [File_Name] like '%[0-9][0-9][0-9][0-9]%'
;


select * from #date_substring
where YYYYMMDD = '0'

update #date_substring
SET YYYYMMDD = case when [File_Name] like '%Jan_[0-9][0-9][0-9][0-9]%' then substring([File_Name], patindex('%Jan_[0-9][0-9][0-9][0-9]%',[File_Name]),8)
					when [File_Name] like '%Feb_[0-9][0-9][0-9][0-9]%' then substring([File_Name], patindex('%Feb_[0-9][0-9][0-9][0-9]%',[File_Name]),8)
					when [File_Name] like '%March_[0-9][0-9][0-9][0-9]%' then substring([File_Name], patindex('%March_[0-9][0-9][0-9][0-9]%',[File_Name]),10)
					when [File_Name] like '%Mar_[0-9][0-9][0-9][0-9]%' then substring([File_Name], patindex('%Mar_[0-9][0-9][0-9][0-9]%',[File_Name]),8)
					when [File_Name] like '%April_[0-9][0-9][0-9][0-9]%' then substring([File_Name], patindex('%April_[0-9][0-9][0-9][0-9]%',[File_Name]),10)
					when [File_Name] like '%Apr_[0-9][0-9][0-9][0-9]%' then substring([File_Name], patindex('%Apr_[0-9][0-9][0-9][0-9]%',[File_Name]),8)
					when [File_Name] like '%May_[0-9][0-9][0-9][0-9]%' then substring([File_Name], patindex('%May_[0-9][0-9][0-9][0-9]%',[File_Name]),8)
					when [File_Name] like '%Jun_[0-9][0-9][0-9][0-9]%' then substring([File_Name], patindex('%Jun_[0-9][0-9][0-9][0-9]%',[File_Name]),8)
					when [File_Name] like '%Jul_[0-9][0-9][0-9][0-9]%' then substring([File_Name], patindex('%Jul_[0-9][0-9][0-9][0-9]%',[File_Name]),8)
					when [File_Name] like '%Aug_[0-9][0-9][0-9][0-9]%' then substring([File_Name], patindex('%Aug_[0-9][0-9][0-9][0-9]%',[File_Name]),8)
					when [File_Name] like '%Sept_[0-9][0-9][0-9][0-9]%' then substring([File_Name], patindex('%Sept_[0-9][0-9][0-9][0-9]%',[File_Name]),9)
					when [File_Name] like '%October_[0-9][0-9][0-9][0-9]%' then substring([File_Name], patindex('%October_[0-9][0-9][0-9][0-9]%',[File_Name]),12)
					when [File_Name] like '%Oct_[0-9][0-9][0-9][0-9]%' then substring([File_Name], patindex('%Oct_[0-9][0-9][0-9][0-9]%',[File_Name]),8)
					when [File_Name] like '%Nov_[0-9][0-9][0-9][0-9]%' then substring([File_Name], patindex('%Nov_[0-9][0-9][0-9][0-9]%',[File_Name]),8)
					when [File_Name] like '%Dec_[0-9][0-9][0-9][0-9]%' then substring([File_Name], patindex('%Dec_[0-9][0-9][0-9][0-9]%',[File_Name]),8)
					else '0' end
where YYYYMMDD = '0' 
	and (
		[File_Name] like '%Jan_[0-9][0-9][0-9][0-9]%' 
		OR [File_Name] like '%Feb_[0-9][0-9][0-9][0-9]%'
		OR [File_Name] like '%March_[0-9][0-9][0-9][0-9]%'
		OR [File_Name] like '%Mar_[0-9][0-9][0-9][0-9]%'
		OR [File_Name] like '%April_[0-9][0-9][0-9][0-9]%'
		OR [File_Name] like '%Apr_[0-9][0-9][0-9][0-9]%' 
		OR [File_Name] like '%May_[0-9][0-9][0-9][0-9]%'
		OR [File_Name] like '%Jun_[0-9][0-9][0-9][0-9]%' 
		OR [File_Name] like '%Jul_[0-9][0-9][0-9][0-9]%' 
		OR [File_Name] like '%Aug_[0-9][0-9][0-9][0-9]%' 
		OR [File_Name] like '%Sept_[0-9][0-9][0-9][0-9]%' 
		OR [File_Name] like '%October_[0-9][0-9][0-9][0-9]%'
		OR [File_Name] like '%Oct_[0-9][0-9][0-9][0-9]%' 
		OR [File_Name] like '%Nov_[0-9][0-9][0-9][0-9]%' 
		OR [File_Name] like '%Dec_[0-9][0-9][0-9][0-9]%' 	

		)


select * from #date_substring
where YYYYMMDD = '0'

select * from #date_substring
where 1=1
	and ([File_Name] like '%Jan%' 
	OR [File_Name] like '%Feb%'
	OR [File_Name] like '%Mar%'
	OR [File_Name] like '%Apr%'
	OR [File_Name] like '%May%'
	OR [File_Name] like '%Jun%' 
	OR [File_Name] like '%Jul%' 
	OR [File_Name] like '%Aug%' 
	OR [File_Name] like '%Sep%' 
	OR [File_Name] like '%Oct%'
	OR [File_Name] like '%Nov%' 
	OR [File_Name] like '%Dec%' 
	--OR [File_Name] like 
	--OR [File_Name] like 
	--OR [File_Name] like 
	--OR [File_Name] like 
	--OR [File_Name] like 
	)


select top 100 * from Workbench.dbo.xxEligibility_All_RAW
