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
select Contract
	, count(distinct Member_ID) as Unique_IDs
	, count(Distinct concat(Member_ID, Relationship_ID)) Unique_Subs_N_Deps
into #ID_Interpretation
FROM [WorkBench].[dbo].[Eligibility_All_RAW]
	group by  Contract
;

select '' '#ID_Interpretation';
select * from #ID_Interpretation
;

select * 
	, case when Unique_IDs=0 then 0 else (Unique_Subs_N_Deps - Unique_IDs)*1.0/(Unique_IDs*1.0) end as More_Subs_than_Membs
	, case when Unique_IDs=0 then cast(0 as varchar(40)) 
		when (Unique_Subs_N_Deps - Unique_IDs)*1.0/(Unique_IDs*1.0)
			 <= 0.02 then 'All Different IDs'
		else 'One Member ID Per Family' end as [Desc]
from #ID_Interpretation
where Unique_IDs not like '%[A-Za-z]%'
order by Contract
;

