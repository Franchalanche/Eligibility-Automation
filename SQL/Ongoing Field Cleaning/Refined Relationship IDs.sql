select top 100 *
FROM [WorkBench].[dbo].[Eligibility_All_RAW]


select Contract
	, Relationship_ID
	, count(*) as [Count]
FROM [WorkBench].[dbo].[Eligibility_All_RAW]
group by Contract
	, Relationship_ID
order by Contract
	, Relationship_ID
	;



drop table if exists #ID_Interpretation;
--with distinct combos as 
--(
--	select distinct contract
--	,	 Relationship_ID
--	FROM [WorkBench].[dbo].[Eligibility_All_RAW]
--	group by  Contract
--)
select ear.Contract
	, count(distinct ear.Member_ID) as Unique_IDs
	, count(Distinct concat(ear.Member_ID, ear.Relationship_ID)) Unique_Subs_N_Deps
	, cast(0 as nvarchar(max)) 
--	, string_agg(distinct c.Relationship_ID,', ') 
		as Relationship_ID_List
into #ID_Interpretation
FROM [WorkBench].[dbo].[Eligibility_All_RAW] ear
--join combos c
--	on ear.Contract = c.Contract
group by ear.Contract
;

select '' '#ID_Interpretation';
select * from #ID_Interpretation;

with combos as 
(
	select distinct 
		contract
		, Relationship_ID
	FROM [WorkBench].[dbo].[Eligibility_All_RAW] ear
),
string_aggs as
(
select contract
	, string_agg(cast(c.Relationship_ID as nvarchar(max)),', ') as Relationship_ID_List
	from combos c
	group by contract
)
update id
set Relationship_ID_List = s.Relationship_ID_List
from #ID_Interpretation id
JOIN string_aggs s
	on id.Contract = s.Contract
; 


select '' '#ID_Interpretation';
select * from #ID_Interpretation;


--DROP TABLE IF EXISTS #ID_Interpretation;

--WITH Distinct_Relationships AS (
--    SELECT DISTINCT
--        Contract,
--        Relationship_ID
--    FROM [WorkBench].[dbo].[Eligibility_All_RAW]
--)
--SELECT
--    e.Contract,
--    COUNT(DISTINCT e.Member_ID) AS Unique_IDs,
--    COUNT(DISTINCT CONCAT(e.Member_ID, e.Relationship_ID))
--        AS Unique_Subs_N_Deps,
--    STRING_AGG(
--        CAST(d.Relationship_ID AS VARCHAR(MAX)),
--        ', '
--    ) AS Relationship_ID_List
--INTO #ID_Interpretation
--FROM [WorkBench].[dbo].[Eligibility_All_RAW] e
--LEFT JOIN Distinct_Relationships d
--    ON e.Contract = d.Contract
--GROUP BY e.Contract;

select '' '#ID_Interpretation';
select * from #ID_Interpretation
;

DROP TABLE IF EXISTS WorkBench.dbo.Eligibility_Relationship_Rules;

select ii.Contract
	, ii.Unique_IDs
	, ii.Unique_Subs_N_Deps
	, ii.Relationship_ID_List
	, case when Unique_IDs=0 then 0 else (Unique_Subs_N_Deps - Unique_IDs)*1.0/(Unique_IDs*1.0) end as More_Subs_than_Membs
	, case when Unique_IDs=0 then cast(0 as varchar(40)) 
		when (Unique_Subs_N_Deps - Unique_IDs)*1.0/(Unique_IDs*1.0)
			 <= 0.02 then 'All Different IDs'
		else 'One Member ID Per Family' end as [Desc]
	, eti.[Member Identifier]
	, cast(0 as nvarchar(max)) as Notes
	, case when len(relationship_id_list) - len(replace(relationship_id_list,',','')) > 1	
	then 'Has Children'
	else 'Employee & Spouse Only' 
	end as Family_Description
	, eti.Full_Table_Name
	, eti.Table_Name
into WorkBench.dbo.Eligibility_Relationship_Rules
from #ID_Interpretation ii
join WorkBench.dbo.Eligibility_Table_Identifiers_RAW eti
	on 	ii.Contract = eti.Contract
where Unique_IDs not like '%[A-Za-z]%'
order by ii.Contract
;

select '' 'Eligibility_Relationship_Rules';
select * 
from WorkBench.dbo.Eligibility_Relationship_Rules;

delete from WorkBench.dbo.Eligibility_Relationship_Rules
where Full_Table_Name = '[PRODELGBLTY1].[PREMIER_Eligibility_Staging].dbo.[AUTONATION_PREMIER_MASTER_ELIGIBILITY]'
OR Full_Table_Name = '[PRODELGBLTY1].[PREMIER_Eligibility_Staging].dbo.[Tbl_Fidelity_Disney_Dependent_Raw]'
;

UPDATE WorkBench.dbo.Eligibility_Relationship_Rules
set Notes = 'If dependents are included in the file, they do not share a base ID with members. Address_1 is only way to connect; policy_type and relationship_to_emp have no rhyme or reason'
WHERE contract  = 'Atlantic UnionBank'

UPDATE WorkBench.dbo.Eligibility_Relationship_Rules
set Notes = 'Emloyee_ID is unique identifier'
WHERE contract  = 'Autonation'
;

UPDATE WorkBench.dbo.Eligibility_Relationship_Rules
set Notes = 'No discernible dependent data'
WHERE contract  = 'Clifford Chance US LLP-Premier'
;


UPDATE WorkBench.dbo.Eligibility_Relationship_Rules
set Notes = 'No discernible dependent data'
WHERE contract  = 'Clifford Chance US LLP-Premier'
;

UPDATE WorkBench.dbo.Eligibility_Relationship_Rules
set Notes = 'Address_1 and Address_2 might be better employee household identifiers'
WHERE contract  = 'Disney - 21CF'
;

select distinct contract from WorkBench.dbo.Eligibility_Relationship_Rules;

UPDATE WorkBench.dbo.Eligibility_Relationship_Rules
set Family_Description = 'Employee & Spouse Only'
WHERE cONTRACT IN ('Cambia','Global Health Labs-Premier','AMERITAS')
;

select '' 'Eligibility_Relationship_Rules';
select * 
from WorkBench.dbo.Eligibility_Relationship_Rules;

select '' 'Eligibility_Relationship_Rules';
select * 
from WorkBench.dbo.Eligibility_Relationship_Rules
where [desc] = 'All Different IDs';

select '' 'Eligibility_Relationship_Rules';
select * 
from WorkBench.dbo.Eligibility_Relationship_Rules
where [desc] = 'One Member ID Per Family' and Family_Description = 'Has Children';



select '' 'Eligibility_Relationship_Rules';
select * 
from WorkBench.dbo.Eligibility_Relationship_Rules;

select '' 'Eligibility_Relationship_Xref';
select * 
FROM WorkBench.dbo.Eligibility_Relationship_Xref
order by Contract_Raw_all_DB
, TableName
, Standardized_SUbDep_Code
,Relationship_ID
;


DROP TABLE IF EXISTS #Working_Table;

select r.Contract
, r.Unique_IDs
, r.Unique_Subs_N_Deps
, r.Relationship_ID_List
, x.Relationship_ID as Employee_Identifier
, cast(0 as nvarchar(max)) as Spouse_Identifier
, cast(0 as nvarchar(max)) as Child_Identifier
, r.More_Subs_Than_Membs
, r.[Desc]
, r.[Member Identifier]
, r.Notes
, r.Family_Description
, r.Full_Table_Name
, x.TableName
INTO #Working_Table
FROM WorkBench.dbo.Eligibility_Relationship_Rules r
JOIN WorkBench.dbo.Eligibility_Relationship_Xref x
	on replace(replace(r.Table_Name,']',''),'[','') = x.TableName
where x.Standardized_SubDep_Code = 'S'
;

select '' '#Working_Table';
select * from
#Working_Table
order by Contract
;

	select distinct 
		contract
		, Relationship_ID
	FROM [WorkBench].[dbo].[Eligibility_All_RAW] ear
	order by contract
		, Relationship_ID
;

with combos as 
(
	select distinct 
		contract
		, Relationship_ID
	FROM [WorkBench].[dbo].[Eligibility_All_RAW] ear
)
update wt 
SET Spouse_Identifier = c.Relationship_ID
from #Working_Table wt
JOIN Combos c
	on wt.Contract = c.Contract
		and wt.Employee_IDentifier<>Relationship_ID
where len(Relationship_ID_List)-len(replace(Relationship_ID_List,',','')) = 1
;

select 'Post Spouse Identifier Update for 2 MBR_ID list' '#Working_Table';
select * from
#Working_Table
order by Contract
;


select 'Post Spouse Identifier Update for 2 MBR_ID list' '#Working_Table';
select * from
#Working_Table
where len(Relationship_ID_List)-len(replace(Relationship_ID_List,',','')) <> 1
and Family_Description<>'Employee & Spouse Only'
order by Contract
;


select 'Post Spouse Identifier Update for 2 MBR_ID list' '#Working_Table';
select sum(Unique_IDs) as Unique_Employees
, sum(Unique_Subs_N_Deps) as Unique_Subs_N_Deps
from
#Working_Table
where len(Relationship_ID_List)-len(replace(Relationship_ID_List,',','')) <> 1
and Family_Description<>'Employee & Spouse Only'
--;

--drop table if exists #contracts_w_children;
--select ear.* 
--, wt.[Desc]
--, wt.Family_Description
--into #contracts_w_children
--from [WorkBench].[dbo].[Eligibility_All_RAW] ear 
--JOIN #Working_Table wt
--	on ear.Contract = wt.contract
--where len(wt.Relationship_ID_List)-len(replace(wt.Relationship_ID_List,',','')) <> 1
--and wt.Family_Description<>'Employee & Spouse Only'
----order by wt.Contract
--;

--select '' '#contracts_w_children';
--select * from #contracts_w_children
--;


select '' '#Working_Table';
select * from
#Working_Table
order by Contract

select top 1000 * 
from #contracts_w_children

select top 1000 * 
from #contracts_w_children
order by contract, member_Id, relationship_ID

drop table if exists WorkBench.dbo.Eligibility_w_Children;
select * 
into WorkBench.dbo.Eligibility_w_Children
FROM #contracts_w_children
;

select top 100
* from WorkBench.dbo.Eligibility_w_Children
;

select top 100 * from #working_Table;

ALTER TABLE WorkBench.dbo.Eligibility_w_Children
ADD New_Member_Base nvarchar(max);
;


select top 100
* from WorkBench.dbo.Eligibility_w_Children
;

UPDATE ewc
set New_Member_Base = 
	case when wt.[Desc] = 'All Different IDs' and len(ewc.Member_ID)> 2 
			then left(ewc.Member_ID,len(ewc.Member_ID)-2)
		else ewc.Member_ID end
FROM WorkBench.dbo.Eligibility_w_Children ewc
JOIN #Working_Table wt
	on ewc.Contract = wt.Contract
;

select top 100
* from WorkBench.dbo.Eligibility_w_Children
;

select top 100 * from #working_Table;


drop table if exists #combo_staging;

select 
	distinct 
		contract
		, New_Member_Base
		, Relationship_ID
into #combo_staging
FROM WorkBench.dbo.Eligibility_w_Children
group by contract
		, New_Member_Base
		, Relationship_ID
		;

select top 2000 * from #combo_staging
where contract like '%kantar%'
;
select count(*) from #combo_staging
;

drop table if exists #id_popularity

select distinct cs.contract, cs.Relationship_ID, count(*) as [Count]
, --max(
	case when wt.Employee_Identifier IS NOT NULL then 'EMPLOYEE ID' else '' END--) 
		AS [Employee ID?]
, 0 as row_num
into #id_popularity
FROM #combo_Staging cs
left JOIN #working_table wt
	ON cs.Contract = wt.Contract
		and cs.Relationship_ID = wt.Employee_Identifier
group by cs.contract, cs.Relationship_ID
, wt.Employee_Identifier
order by cs.contract, cs.Relationship_ID;

select * from #id_popularity
order by contract, Relationship_ID
;

with order_base as
(
	select [Contract]
		, isnull(Relationship_ID,'NULL') as Relationship_ID 
		--, [Count]
		, row_number() over (PARTITION BY [Contract] ORDER BY [Count] DESC, isnull(relationship_ID,'NULL') asc) as row_num
	from #id_popularity
	group by [Contract]
		, Relationship_ID
		, [Count]
	--order by [Contract]
	--	, Relationship_ID
)
update id 
set id.row_num = ob.row_num
from #id_popularity id
JOIN order_base ob
	on id.[Contract] = ob.[Contract]
		and isnull(id.Relationship_ID,'NULL') = ob.Relationship_ID
;

select '' '#id_popularity';
select * from #id_popularity
order by contract, Relationship_ID
;
select '#id_popularity' 'contracts with more than 1 Employee ID or who need an addresss id or other special rules' ;
select distinct contract
FROM #id_popularity
where [Employee ID?] = 'EMPLOYEE ID' and row_num <> 1
order by contract
;
select 'contracts with more than 1 Employee ID' '#id_popularity';
select *
FROM #id_popularity
where contract in
(select distinct contract
	FROM #id_popularity
	where [Employee ID?] = 'EMPLOYEE ID'
		and row_num <> 1) 
order by contract, relationship_ID, row_num
;


--select * from #working_table
;

select id.* 
, wt.Notes
from #id_popularity id
LEFT JOIN #working_table wt
	on id.Contract = wt.Contract



drop table if exists #combos;
select distinct
	contract
	, new_Member_Base
	, count(*) as Rel_ID_Counts
	, string_agg(Relationship_ID,', ') WITHIN GROUP (order by Relationship_ID asc) as Rel_ID_Grouping
into #combos
FROM #combo_staging
WHERE Relationship_ID is not null
GROUP BY
	Contract
	, new_Member_Base
;


select '' '#combo_staging';
select top 10000 * from #combo_staging
where contract like '%kantar%'
and new_member_base like '%128785998%'

--where contract like '%duane%'
--order by Contract, new_member_Base, Rel_ID_Counts DESC
;

select *
from workbench.dbo.eligibility_all_raw
where contract like '%kantar%'
and member_ID like '%128785998%'
;

select '' '#combos';
select top 10000 * from #combos
where contract like '%kantar%'
;

select '' '#combos Summary';
drop table if exists #combos_summary;
select distinct c.Contract
	, Rel_ID_Counts
	, Rel_ID_Grouping
	, count(*) as [Count]
	, count(*)*1.0 / ((sum(count(*)) OVER (Partition BY c.Contract))*1.0) as Percentage_of_Total
	, wt.[Desc]
	, wt.Family_Description
into #combos_summary
FROM #combos c
JOIN #working_Table wt
	on c.Contract = wt.Contract
--WHERE Rel_ID_Counts = 1
group by c.Contract, Rel_ID_Grouping, wt.[Desc]
	, wt.Family_Description	, Rel_ID_Counts
order by c.Contract, Rel_ID_Grouping, wt.[Desc]
	, wt.Family_Description	--, Rel_ID_Counts

;

select '' '#combos_summary';
select * from #combos_summary
order by contract, Rel_ID_Grouping;


select '' '#id_popularity';
select * from #id_popularity
order by contract, Relationship_ID
;

drop table if exists #EMPid_in_group_analysis
;
WITH combo_summary AS
(
    SELECT DISTINCT
        Rel_ID_Grouping,
        Contract,
		Percentage_of_Total
    FROM #combos_summary
),
emp_IDs AS
(
    SELECT DISTINCT
        Contract,
        Relationship_ID
    FROM #id_popularity
    WHERE [Employee ID?] = 'Employee ID'
)
SELECT
    cs.*,
    CASE
        WHEN EXISTS
        (
            SELECT 1
            FROM STRING_SPLIT(cs.Rel_ID_Grouping, ',') s
            WHERE LTRIM(RTRIM(s.value)) = CAST(id.Relationship_ID AS VARCHAR(50))
        )
        THEN 'Good'
        ELSE 'DOES NOT CONTAIN MAIN ID'
    END AS [IS Emp ID in All?]
into #EMPid_in_group_analysis
FROM combo_summary cs
JOIN emp_IDs id
    ON cs.Contract = id.Contract;

select '' '#combos_summary';
select * from #combos_summary
order by contract, Rel_ID_Grouping;


select '' '#id_popularity';
select * from #id_popularity
order by contract, Relationship_ID
;

select '' '#EMPid_in_group_analysis';
select * from #EMPid_in_group_analysis
order by Contract, Rel_ID_Grouping;

select 'w table name' '#id_popularity';
select id.* 
	, eti.Full_Table_Name
from #id_popularity id
JOIN workbench.dbo.eligibility_table_identifiers_raw eti
	on id.Contract = eti.Contract
order by id.contract, id.Relationship_ID
;

SELECT 'WHERE [IS Emp ID in All?] <> Good' '#EMPid_in_group_analysis';
select *--distinct Contract as EMP_ID_NOT_IN_ALL_RELATIONSHIP_GROUPS
FROM #EMPid_in_group_analysis 
where [IS Emp ID in All?] <> 'Good'
order by Contract;

select 'WHERE [IS Emp ID in All?] <> Good' '* from from #combos c';
select c.*
, ' or subscriber_id like ''%'+trim(new_member_base)+'%''' as Copy_Paste
from #combos c
JOIN #EMPid_in_group_analysis emp_id
	on c.Contract = emp_id.Contract
		and c.Rel_ID_Grouping = emp_ID.rel_ID_Grouping
where [IS Emp ID in All?] <> 'Good'
AND C.cONTRACT NOT LIKE '%IHEART%'
order by Contract;

select '' '#working_table';
select * from #working_table
order by contract;

select distinct contract from #working_table order by contract;

select '' '#combos Summary';
select distinct c.Contract
	, Rel_ID_Counts
	, Rel_ID_Grouping
	, count(*) as [Count]
	, count(*)*1.0 / ((sum(count(*)) OVER (Partition BY c.Contract))*1.0) as Percentage_of_Total
	, wt.[Desc]
	, wt.Family_Description
FROM #combos c
JOIN #working_Table wt
	on c.Contract = wt.Contract
--WHERE Rel_ID_Counts = 1
WHERE c.Contract in
(
	  'AV Squad' 
	, 'Bill and Melinda Gates Companies' 
	, 'Borgwarner' 
	, 'Duane Morris-Premier' 
	, 'Enbridge-BCBSTX-Premier' 
	, 'EPIC Brokers' 
	, 'Evercore-Aetna-Premier' 
	, 'Fisher Phillips' 
	, 'Gilbane - which?' 
	, 'Highmark Employees-Highmark-Premier' 
	, 'iHeart Media-Meritain-Premier' 
	, 'iHeart Media-Trustmark-Premier' 
	, 'JBSS-John B Sanfilippo & Son-Premier' 
	, 'Jupiter Medical Center-BCBS-SC-Premier' 
	, 'Kantar-Premier' 
	, 'Latham' 
	, 'Littler Mendelson' 
	, 'Magic Leap-UMR-Premier' 
	, 'Munger, Tolles & Olson-Premier' 
	, 'Prudential-XO Health-Premier' 
	, 'Reproductive Freedom for All' 
	, 'Susquehanna-Aetna-Premier' 
	, 'University of California-BS California-Premier' 
)
group by c.Contract, Rel_ID_Grouping, wt.[Desc]
	, wt.Family_Description	, Rel_ID_Counts
order by c.Contract, Rel_ID_Grouping, wt.[Desc]
	, wt.Family_Description	--, Rel_ID_Counts
;



select 'Rel_ID_Counts = 1' '#combos Summary';
select distinct Contract, Rel_ID_Grouping
FROM #combos
WHERE Rel_ID_Counts = 1
order by Contract, Rel_ID_Grouping
;

select '' '#combos';
select top 10000 * from #combos
where contract like '%duane%'
order by Contract, new_member_Base, Rel_ID_Counts DESC
;

select '' '#working_Table';
select * from #working_Table



select id.Contract 
, eti.Full_Table_Name
from #ID_Interpretation id
JOIN WorkBench.dbo.Eligibility_Table_Identifiers_RAW eti
on id.Contract = eti.Contract
where Unique_IDs = 0



select id.Contract 
, eti.*
from #ID_Interpretation id
JOIN WorkBench.dbo.Eligibility_Table_Identifiers_RAW eti
on id.Contract = eti.Contract
where Unique_IDs = 0



