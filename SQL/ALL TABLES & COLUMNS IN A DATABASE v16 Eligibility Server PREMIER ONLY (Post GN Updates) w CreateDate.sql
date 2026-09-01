DROP TABLE IF EXISTS #column_data;


SELECT
    'Premier' as [Server],
    s.name                    AS schema_name,
    t.name                    AS table_name,
    c.column_id               AS ordinal_position,
    c.name                    AS column_name,
    ty.name                   AS data_type,
    CASE 
        WHEN ty.name IN ('nchar','nvarchar','ntext') AND c.max_length > 0 THEN c.max_length / 2
        WHEN c.max_length = -1 THEN -1  -- MAX types
        ELSE c.max_length
    END                       AS max_length,
    c.precision,
    c.scale,
    c.is_nullable,
    c.is_identity,
    dc.definition             AS default_definition,
    cc.definition             AS computed_definition,
    CASE WHEN i.is_primary_key = 1 THEN 1 ELSE 0 END AS is_in_primary_key
into #column_data
FROM [PRODELGBLTY1].[PREMIER_Eligibility_Staging].sys.tables t
JOIN [PRODELGBLTY1].[PREMIER_Eligibility_Staging].sys.schemas s           ON s.schema_id = t.schema_id
JOIN [PRODELGBLTY1].[PREMIER_Eligibility_Staging].sys.columns c           ON c.object_id = t.object_id
JOIN [PRODELGBLTY1].[PREMIER_Eligibility_Staging].sys.types ty            ON c.user_type_id = ty.user_type_id
LEFT JOIN [PRODELGBLTY1].[PREMIER_Eligibility_Staging].sys.default_constraints dc
                             ON dc.parent_object_id = c.object_id
                            AND dc.parent_column_id = c.column_id
LEFT JOIN [PRODELGBLTY1].[PREMIER_Eligibility_Staging].sys.computed_columns cc
                             ON cc.object_id = c.object_id
                            AND cc.column_id = c.column_id
LEFT JOIN [PRODELGBLTY1].[PREMIER_Eligibility_Staging].sys.index_columns ic
                             ON ic.object_id = c.object_id
                            AND ic.column_id = c.column_id
LEFT JOIN [PRODELGBLTY1].[PREMIER_Eligibility_Staging].sys.indexes i
                             ON i.object_id  = ic.object_id
                            AND i.index_id   = ic.index_id
                            AND i.is_primary_key = 1
WHERE t.is_ms_shipped = 0
ORDER BY s.name, t.name, c.column_id;

 

----------------------------------------

----------------------------------------

delete from #column_data
where table_name NOT LIKE '%RAWFILE' 
/*
	REMOVING FILES WE DON'T NEED - ONLY NEED _RAWFILE, NOT STAGING. 
	SOME COMPANIES DON'T HAVE THAT; MANUALLY CORRECTING FOR THAT RIGHT NOW

	FIGURE OUT WHICH NEW MOUNTAIN IS NEWEST IN AUTOMATED VERSION; FOR NOW PICKING BIGGEST TABLE
*/
	AND table_name not in 
		(
			 'AUTONATION_PREMIER_MASTER_ELIGIBILITY'
			,'CAMBIA_STAGING'
			,'MACMILLAN_PREMIER_RAWFILE_STAGING'
			--,'New_mountain'
			,'newmountain'
			--,'Seattle_Fire_Fighters_STAGING'
			,'Tbl_Fidelity_Disney_Dependent_Raw'

		)
;
  
DROP TABLE IF EXISTS #schema_summary;

SELECT
    c.[Server],
	c.[schema_name]  AS [schema_name],
    c.table_name  AS table_name,
    STRING_AGG(QUOTENAME(c.column_name), ', ') WITHIN GROUP (ORDER BY c.ordinal_position) AS columns_csv
into #schema_summary
FROM #column_data c
--WHERE t.is_ms_shipped = 0
GROUP BY c.[Server], c.[schema_name] , c.table_name
ORDER BY c.[Server], c.[schema_name] , c.table_name;

 
 select * from #schema_summary
 ----select * from  [WorkBench].[dbo].[xxEligibility_All_RAW]
 --select count(distinct table_name) as schema_summary_tables from #schema_summary
 -- select count(distinct Source_table) as xxElig_Raw_Tables from [WorkBench].[dbo].[xxEligibility_All_RAW]


 select ',''['+s.table_name+']''',s.*
 from #schema_summary s
 left join (select distinct Source_Table from [WorkBench].[dbo].[xxEligibility_All_RAW]) xe
 on '[PRODELGBLTY1].[PREMIER_Eligibility_Staging].dbo.['+s.table_name+']' = xe.Source_Table
 where xe.Source_Table IS NULL


 DECLARE @sql_QC nvarchar(max)='';

SELECT @sql_QC += '
SELECT * 
FROM [PRODELGBLTY1].[PREMIER_Eligibility_Staging].dbo.['+table_name+'];'
FROM #schema_summary s
LEFT JOIN (
    SELECT DISTINCT Source_Table
    FROM [WorkBench].[dbo].[xxEligibility_All_RAW]
) xe
ON '[PRODELGBLTY1].[PREMIER_Eligibility_Staging].dbo.['+s.table_name+']' = xe.Source_Table
WHERE xe.Source_Table IS NULL;

EXEC sp_executesql @sql_QC;

drop table if exists #Table_with_ID_Info;

SELECT 
	  [Server] 
	, table_name
	, case 
		 when columns_csv like '%MEMB_SUBSCRIBER_NUMBER%' then 'MEMB_SUBSCRIBER_NUMBER' 
		 when columns_csv like '%MEMBER ID (Assigned In Data Warehouse)%' then 'MEMBER ID (Assigned In Data Warehouse)' 
		 when columns_csv like '%MEMBER ID%' then 'MEMBER ID' 
		 when columns_csv like '%Alternate_ID%' then 'Alternate_ID' 
		 when columns_csv like '%group_reporting_MEMBER_ID%' then 'group_reporting_MEMBER_ID'
		 when columns_csv like '%MEMBER[_]ID%' then 'MEMBER_ID'
		 when columns_csv like '%EmployeeID%' then 'EmployeeID' 
 		 when columns_csv like '%ContractID%' then 'ContractID'  --For Bloomberg (Employers)
		 when columns_csv like '%UNIQUE_ID%' then 'UNIQUE_ID' --Baker Donelson BCBS & UMR (Premier)
		 when columns_csv like '%MemberID%'  AND columns_csv NOT like '%alternatememberidentifier%'  then 'MemberID' --Jupiter Medical (Premier)
		 when columns_csv like '%Employee Number%' then 'Employee Number' --Little Mendelson (Premier)
		 when columns_csv like '%Employer[_]ID%' then 'Employer_ID' --LMI (Premier)
		 when columns_csv like '%Member[_]Person[_]Code%' then 'Member_Person_Code' --LMI (Premier)
		 when columns_csv like '%Permanent Profile number%' then 'Permanent Profile number' --AG1
		 when columns_csv like '%Employee[_]ID%' then 'Employee_ID' --DWT
		 when columns_csv like '%Insured ID%' then 'Insured ID' --iHeart
		 when columns_csv like '%Insured[_]ID%' then 'Insured_ID' --Isuzu
		 when columns_csv like '%PID#%' then 'PID#' --Loeb & Loeb
		 when columns_csv like '%CurSubNum%' then 'CurSubNum' --U Cali
		 when columns_csv like '%Member[_]Number%' then 'Member_Number' --Orion (empty table)
		 when columns_csv like '%SLNO%' then 'SLNO' --TBL_FIDELITY_DISNEY
		ELSE 'NULL' END as [Member Identifier]
	, case 
		 when columns_csv like '%Individual[_]Relationship[_]Code%' then 'Individual_Relationship_Code' -- disney fidelity
		 when columns_csv like '%MBR[_]NBR[_]Actual%' then 'MBR_NBR_Actual' -- enbridge
		 when columns_csv like '%MemberNumber%' then 'MemberNumber' 
		 when columns_csv like '%MBR[_]NBR%' then 'MBR_NBR' 
		 when columns_csv like '%MEMB[_]NBR%' then 'MEMB_NBR' 
		 when columns_csv like '%Member Relationship To Subscriber%' then 'Member Relationship To Subscriber' 
		 when columns_csv like '%Relationship[_]Code%' then 'Relationship_Code' 
		 when columns_csv like '%RELATIONSHIPTOEMP%' then 'RELATIONSHIPTOEMP' --Mercedes
		 when columns_csv like '%Relationship[_]TO[_]EMP%' then 'Relationship_TO_EMP' 
		 when columns_csv like '%Relationship%' then 'Relationship' 
		 when columns_csv like '%MidNumber%' then 'MidNumber' 
		 when columns_csv like '%Member[_]Person[_]Code%' then 'Member_Person_Code' --iHeart
		 when columns_csv like '%Dependent Type%' then 'Dependent Type' --AG1
		 when columns_csv like '%ELATIONSHIP[_]TO[_]EMP%' then 'ELATIONSHIP_TO_EMP' --Chewy
		 when columns_csv like '%RELATION%' then 'RELATION' --NEW Mountain
		 when columns_csv like '%MBRID%' then 'MBRID' --U Cali
		ELSE 'NULL' END as [Relationship Identifier]	
	, case 
		 when columns_csv like '%DEPENDENT[_]FIRST[_]NAME%' AND table_name = 'Tbl_Fidelity_Disney_Dependent_Raw' then 'DEPENDENT_FIRST_NAME'
		 when columns_csv like '%MEMBER FIRST NAME%' then 'MEMBER FIRST NAME' 
		 when columns_csv like '%MEMB[_]FIRST[_]NAME%' then 'MEMB_FIRST_NAME' 
		 when columns_csv like '%MEMBERFIRSTNAME%' then 'MEMBERFIRSTNAME' --CAMBIA
		 when columns_csv like '%MEMBER[_]FIRST[_]NAME%' then 'MEMBER_FIRST_NAME' 
		 when columns_csv like '%MEMBERS[_]FIRST[_]NAME%' then 'MEMBERS_FIRST_NAME' 
		 when columns_csv like '%LEGAL FIRST NAME%' then 'LEGAL FIRST NAME' --AG1
		 when columns_csv like '%FIRST[_]NAME%' then 'FIRST_NAME' 
		 when columns_csv like '%FIRST NAME%' then 'FIRST NAME' 
		 when columns_csv like '%Memb[_]FirstName%' then 'Memb_FirstName' 
		 when columns_csv like '%FirstName%' then 'FirstName' 
		 when columns_csv like '%SUBFNAME%' then 'SUBFNAME' --uCali
		 when columns_csv like '%FNAME%' then 'FNAME' 
		 when columns_csv like '%FIRST AND MIDDLE%' then 'FIRST AND MIDDLE' --iHeart Meritain
		 when columns_csv like '%FIRST[_]AND[_]MIDDLE%' then 'FIRST_AND_MIDDLE' --isuzu
		ELSE 'NULL' END as [First Name Identifier]
	, case 
		 when columns_csv like '%DEPENDENT[_]LAST[_]NAME%' AND table_name = 'Tbl_Fidelity_Disney_Dependent_Raw' then 'DEPENDENT_LAST_NAME'
		 when columns_csv like '%MEMBER LAST NAME%' then 'MEMBER LAST NAME' 
		 when columns_csv like '%MEMB[_]LAST[_]NAME%' then 'MEMB_LAST_NAME' 
		 when columns_csv like '%MEMBERLASTNAME%' then 'MEMBERLASTNAME' --CAMBIA
		 when columns_csv like '%MEMBER[_]LAST[_]NAME%' then 'MEMBER_LAST_NAME' 
		 when columns_csv like '%MEMBERS[_]LAST[_]NAME%' then 'MEMBERS_LAST_NAME' 
		 when columns_csv like '%LEGAL LAST NAME%' then 'LEGAL LAST NAME' --AG1
		 when columns_csv like '%LAST[_]NAME%' then 'LAST_NAME' 
		 when columns_csv like '%LAST NAME%' then 'LAST NAME' 
		 when columns_csv like '%Memb[_]LastName%' then 'Memb_LastName' 
		 when columns_csv like '%LastName%' then 'LastName' 
		 when columns_csv like '%subLNAME%' then 'SUBLNAME' --U CALI
		 when columns_csv like '%LNAME%' then 'LNAME' 
		ELSE 'NULL' END as [Last Name Identifier]
	, case 
		 when columns_csv like '%MEMB[_]EMAIL[_]ID%' then 'MEMB_EMAIL_ID' 
		 when columns_csv like '%MEMB[_]EMAIL%' then 'MEMB_EMAIL' 
		 when columns_csv like '%personal[_]email[_]address%' then 'personal_email_address' 
		 when columns_csv like '%personal email%' then 'personal email' 
		 when columns_csv like '%Preferred[_]Email[_]Address%' then 'Preferred_Email_Address' 
		 when columns_csv like '%email address%' then 'email address' 
		 when columns_csv like '%email[_]address%' then 'email_address' 
		 when columns_csv like '%EmailAddress%' then 'EmailAddress' 
		 when columns_csv like '%WorkEmail%' then 'WorkEmail' 
		 when columns_csv like '%Work[_]Email%' then 'Work_Email' 
		 when columns_csv like '%MailEmail%' then 'MailEmail' 
		  when columns_csv like '%Sub[_]Email%' then 'Sub_Email' --U Cali
		  when columns_csv like '%Email%' then 'Email' 
		ELSE 'NULL' END as [Email Identifier]
	, case 
		 when columns_csv like '%CELL[_]PHONE%' then 'CELL_PHONE' 
		 when columns_csv like '%MailPHONE%' then 'MailPHONE' 
		 when columns_csv like '%MEMB[_]PHONE1%' THEN 'MEMB_PHONE1'
		 when columns_csv like '%MEMB[_]PRIMARY[_]PHONE[_]NUMBER%' then 'MEMB_PRIMARY_PHONE_NUMBER' 
		 when columns_csv like '%MEMB[_]PHONE[_]NUMBER1%' then 'MEMB_PHONE_NUMBER1' 
		 when columns_csv like '%MEMBER PHONE NUMBER%' then 'MEMBER PHONE NUMBER' 
		 when columns_csv like '%MEMB[_]PHONE[_]NUMBER%' then 'MEMB_PHONE_NUMBER' 
		 when columns_csv like '%Home[_]Phone[_]Number%' then 'Home_Phone_Number' 
		 when columns_csv like '%HomeTelephoneNumber%' then 'HomeTelephoneNumber' 
		 when columns_csv like '%Work[_]Phone[_]Number%' then 'Work_Phone_Number' 
		 when columns_csv like '%Phone Number%' then 'Phone Number' 
		 when columns_csv like '%Phone[_]Number%' then 'Phone_Number' 
		 when columns_csv like '%Work Phone%' then 'Work Phone' 
		 when columns_csv like '%WORK[_]PHONE%' then 'WORK_PHONE' 
		 when columns_csv like '%Private[_]phone[_]switch%' then 'Private_phone_switch' 
		 when columns_csv like '%Home Phone%' then 'Home Phone' 
		 when columns_csv like '%HOME[_]PHONE%' then 'HOME_PHONE' 
		 when columns_csv like '%PRIMARY PHONE%' then 'PRIMARY PHONE' 
		 when columns_csv like '%PRIMARY[_]PHONE%' then 'PRIMARY_PHONE' 
		 when columns_csv like '%PRIMARY[_]CONTACT_PHONE%' then 'PRIMARY_CONTACT_PHONE' 
		 when columns_csv like '%Phone%' then 'Phone' 
		ELSE 'NULL' END as [Main Phone Identifier]
	, case 
		 when columns_csv like '%Home address - street address%' then 'Home address - street address' 
		 when columns_csv like '%MEMB[_]STREET1%' then 'MEMB_STREET1' 
		 when columns_csv like '%MEMBerStreetAddress1%' then 'MEMBerStreetAddress1' 
		 when columns_csv like '%MEMB_Street_Address_1%' then 'MEMB_Street_Address_1' 
		 when columns_csv like '%MEMB_STREET%' then 'MEMB_STREET' 
		 when columns_csv like '%MEMBER ADDRESS LINE1%' then 'MEMBER ADDRESS LINE1' -- SAGE
		 when columns_csv like '%MEMB[_]ADDRESS1%' then 'MEMB_ADDRESS1' 
		 when columns_csv like '%Mailing[_]Address1%' then 'Mailing_Address1' 
		 when columns_csv like '%MEMBER[_]ADDRESS1%' then 'MEMBER_ADDRESS1' 
		 when columns_csv like '%Address1%' then 'Address1' 
		 when columns_csv like '%ADDRESS[_]1%' then 'ADDRESS_1' 
		 when columns_csv like '%MEMB[_]ADDRESS%' then 'MEMB_ADDRESS' 
		 when columns_csv like '%Address Line 1%' then 'Address Line 1' 
		 when columns_csv like '%MailAddressLine1%' then 'MailAddressLine1' --Cambia 
		 when columns_csv like '%ADDRESS LINE1%' then 'ADDRESS LINE1' --iHeart Meritain
		 when columns_csv like '%ADDRESS_LINE1%' then 'ADDRESS_LINE1' --Isuzu
		 when columns_csv like '%ADDRESS[_]LINE_1%' then 'ADDRESS_LINE_1' 
		 when columns_csv like '%Members[_]ADDRESS%' then 'Members_ADDRESS' --iHeart Trustmark
		 when columns_csv like '%Street ADDRESS%' then 'Street ADDRESS' 
		 when columns_csv like '%ADDRESS%' then 'ADDRESS' 
		 when columns_csv like '%SUBADR1%' then 'SUBADR1' --uCali
		ELSE 'NULL' END as [Street Address Identifier]
	, case 
		 when columns_csv like '%MEMB[_]STREET2%' then 'MEMB_STREET2' 
		 when columns_csv like '%MEMBerStreetAddress2%' then 'MEMBerStreetAddress2' 
		 when columns_csv like '%MEMB[_]Street_Address_2%' then 'MEMB_Street_Address_2' 
		 when columns_csv like '%ADDRESS[_]2%' then 'ADDRESS_2' 
		 when columns_csv like '%MEMBER ADDRESS LINE2%' then 'MEMBER ADDRESS LINE2' -- SAGE
		 when columns_csv like '%MEMB[_]ADDRESS2%' then 'MEMB_ADDRESS2' 
		 when columns_csv like '%MEMBER[_]ADDRESS2%' then 'MEMBER_ADDRESS2' 
		 when columns_csv like '%Address2%' then 'Address2' 
		 when columns_csv like '%MailAddressLine2%' then 'MailAddressLine2' --Cambia 
		 when columns_csv like '%Address Line2%' then 'Address Line2'--iHeart Meritain 
		 when columns_csv like '%Address_Line2%' then 'Address_Line2'--Isuzu
		 when columns_csv like '%Address Line 2%' then 'Address Line 2' 
		 when columns_csv like '%Address_Line_2%' then 'Address_Line_2' --Orion
		 when columns_csv like '%Mailing[_]Address2%' then 'Mailing_Address2' 
		 when columns_csv like '%SUBADR2%' then 'SUBADR2' --uCali
		ELSE 'NULL' END as [Address 2 Identifier]

	, CASE 
           When columns_csv like '%Home address - City%' then 'Home address - City' 
           When columns_csv like '%MailCity%' then 'MailCity' 
		   WHEN columns_csv like '%MEMB[_]CITY%' then 'MEMB_CITY'	
		   WHEN columns_csv like '%CITY[_]OR[_]TOWN%' then 'CITY_OR_TOWN'	
		   WHEN columns_csv like '%MEMBERCITY%' then 'MEMBERCITY'	
		   WHEN columns_csv like '%MEMBER CITY%' then 'MEMBER CITY'	
		   WHEN columns_csv like '%MEMBER[_]CITY%' then 'MEMBER_CITY'	
		   WHEN columns_csv like '%MEMBERs[_]CITY%' then 'MEMBERS_CITY' --iHeart Trustmark & United Rentals	
		   WHEN columns_csv like '%subCITY%' then 'SUBCITY' --uCali
		   WHEN columns_csv like '%CITY%' then 'CITY'
			ELSE 'NULL' end as [City Identifier]
	, case 
           When columns_csv like '%Home address - State%' then 'Home address - State' 
           When columns_csv like '%MailState%' then 'MailState' 
           When columns_csv like '%USPS[_]State[_]Code%' then 'USPS_State_Code' 
		  when columns_csv like '%MEMB[_]STATE%' then 'MEMB_STATE' 
		 when columns_csv like '%MEM[_]STATE[_]CD%' then 'MEM_STATE_CD' 
		 when columns_csv like '%MEMBER[_]STATE%' then 'MEMBER_STATE' 
		 when columns_csv like '%MEMBER STATE%' then 'MEMBER STATE'
	   WHEN columns_csv like '%MEMBERstate%' then 'MEMBERstate'	
		 when columns_csv like '%MEMBERS[_]STATE%' then 'MEMBERS_STATE' --iHeart TrustmarkUnited Rentals
		 when columns_csv like '%STATE[_]OR[_]PROVINCE%' then 'STATE_OR_PROVINCE' 
		 when columns_csv like '%STATE%' then 'STATE' 
		 WHEN columns_csv like '%SUBST%' then 'SUBST' --uCali

		ELSE 'NULL' END as [State Identifier]
	, case 
           When columns_csv like '%Home address - Zip%' then 'Home address - Zip' 
		   When columns_csv like '%MailZip%' then 'MailZip' 

		 when columns_csv like '%MEMB[_]Zip[_]Code%' then 'MEMB_Zip_Code' 
		 when columns_csv like '%MEMB[_]ZipCode%' then 'MEMB_ZipCode' 
		 when columns_csv like '%MEMBER[_]ZIPCODE%' then 'MEMBER_ZIPCODE' 
		 when columns_csv like '%MEMBERZIPCODE%' then 'MEMBERZIPCODE' 
		 when columns_csv like '%MEMBER ZIPCODE%' then 'MEMBER ZIPCODE' 
		 when columns_csv like '%MEMBER ZIP%' then 'MEMBER ZIP' 
		 when columns_csv like '%MEMB[_]ZIP%' then 'MEMB_ZIP' 
		 when columns_csv like '%MEM[_]ZIP[_]CD%' then 'MEM_ZIP_CD' 
		 --when columns_csv like '%PROVIDER_ZIPCODE%' then 'PROVIDER_ZIPCODE' 
		 --when columns_csv like '%Work_Location_Zip_Code%' then 'Work_Location_Zip_Code' 
		 when columns_csv like '%Zip Code%' then 'Zip Code' 
		 when columns_csv like '%Zip[_]Code%' then 'Zip_Code' 
		 when columns_csv like '%ZipCode%' then 'ZipCode' 
		 when columns_csv like '%homeZIP%' then 'HOMEZIP' --U Cali 
		 when columns_csv like '%Members_ZIP%' then 'Members_ZIP' 
		 when columns_csv like '%ZIP%' then 'ZIP' 
		 when columns_csv like '%Postal_Code%' then 'Postal_Code' --tbl_fidelity_disn
		ELSE 'NULL' END as [Zip Identifier]

	, case 
		 when columns_csv like '%DEPENDENT[_]DATE[_]OF[_]BIRTH%' AND table_name = 'Tbl_Fidelity_Disney_Dependent_Raw' then 'DEPENDENT_DATE_OF_BIRTH'
		 when columns_csv like '%MEMB[_]DOB%' then 'MEMB_DOB' 
		 when columns_csv like '%MEMBERDOB%' then 'MEMBERDOB' 
		 when columns_csv like '%MEM[_]DOB%' then 'MEM_DOB' 
		 when columns_csv like '%MEMBER[_]DOB%' then 'MEMBER_DOB' 
		 when columns_csv like '%MEMBERS_DOB%' then 'MEMBERS_DOB' 
		 when columns_csv like '%DATE[_]OF[_]BIRTH%' then 'DATE_OF_BIRTH' 
		 when columns_csv like '%MEMBER DATE OF BIRTH%' then 'MEMBER DATE OF BIRTH' 
		 when columns_csv like '%DATE OF BIRTH%' then 'DATE OF BIRTH' 
		 when columns_csv like '%DateOfBirth%' then 'DateOfBirth' 
		 when columns_csv like '%BirthDate%' then 'BirthDate' 
		 when columns_csv like '%Birth Date%' then 'Birth Date' 
		 when columns_csv like '%Member_Birth_Date%' then 'Member_Birth_Date' 
		 when columns_csv like '%MBRDOB%' then 'MBRDOB' 
		 when columns_csv like '%DOB%' then 'DOB' 
		ELSE 'NULL' END as [Birthday Identifier]
	 , case 
		when columns_csv like '%FERTILITY[_]ELIG[_]EFF[_]START[_]DATE%' then 'FERTILITY_ELIG_EFF_START_DATE' 
		when columns_csv like '%MEDICAL[_]ELIG[_]EFF[_]START[_]DATE%' then 'MEDICAL_ELIG_EFF_START_DATE' 
		when columns_csv like '%HEALTHPLAN[_]ELIG_EFF[_]START[_]DATE%' then 'HEALTHPLAN_ELIG_EFF_START_DATE' 
		when columns_csv like '%HEALTH[_]PLAN[_]ELIG_EFF[_]START[_]DATE%' then 'HEALTH_PLAN_ELIG_EFF_START_DATE' 
		when columns_csv like '%ELIG[_]EFF[_]START[_]DATE%' then 'ELIG_EFF_START_DATE' 
		when columns_csv like '%MEMB[_]COV[_]START[_]DATE%' then 'MEMB_COV_START_DATE' 		 
		when columns_csv like '%CovEffDate%' then 'CovEffDate' 
		when columns_csv like '%RATE[_]EFFECTIVE_DT[_]start%' then 'RATE_EFFECTIVE_DT_start' 
		when columns_csv like '%Start date%' then 'Start date' 
		when columns_csv like '%Member[_]Effective[_]Date%' then 'Member_Effective_Date' 
		when columns_csv like '%EligibleFromDt%' then 'EligibleFromDt' 
		when columns_csv like '%Med Effective%' then 'Med Effective' 
		when columns_csv like '%Med[_]Effective%' then 'Med_Effective' 
		when columns_csv like '%Coverage_Eff_Date%' then 'Coverage_Eff_Date' 
		when columns_csv like '%Medical Enrollment Date%' then 'Medical Enrollment Date' 
		when columns_csv like '%EFFSTARTDATE%' then 'EFFSTARTDATE' 
		when columns_csv like '%Benefit[_]Begin[_]Date%' then 'Benefit_Begin_Date' 
		when columns_csv like '%Benefit[_]Start[_]Date%' then 'Start_Date' 
		when columns_csv like '%Start[_]Date%' then 'Start_Date' 
		when columns_csv like '%ACTSTDT%' then 'ACTSTDT' 
		when columns_csv like '%StructureEffectiveDate%' then 'StructureEffectiveDate' 
		when columns_csv like '%Individual Original Effective Date at Aetna%' then 'Individual Original Effective Date at Aetna' 
		ELSE 'NULL' END as [Start Date Identifier] 	
	, case 
		when columns_csv like '%FERTILITY[_]ELIG[_]EFF[_]END[_]DATE%' then 'FERTILITY_ELIG_EFF_END_DATE' 
		when columns_csv like '%MEDICAL[_]ELIG_EFF[_]END[_]DATE%' then 'MEDICAL_ELIG_EFF_END_DATE' 
		when columns_csv like '%HEALTHPLAN[_]ELIG[_]EFF[_]END[_]DATE%' then 'HEALTHPLAN_ELIG_EFF_END_DATE' 
		when columns_csv like '%HEALTH[_]PLAN[_]ELIG[_]EFF[_]END[_]DATE%' then 'HEALTH_PLAN_ELIG_EFF_END_DATE' 
		when columns_csv like '%ELIG[_]EFF[_]END[_]DATE%' then 'ELIG_EFF_END_DATE' 
		when columns_csv like '%MEMB[_]COV[_]END[_]DATE%' then 'MEMB_COV_END_DATE' 
		when columns_csv like '%TermDate%' then 'TermDate' 
		when columns_csv like '%RATE[_]EFFECTIVE_DT[_][_]End%' then 'RATE_EFFECTIVE_DT__End' 
		when columns_csv like '%Last Day of Work%' then 'Last Day of Work' 
		when columns_csv like '%Member[_]Cancel[_]Date%' then 'Member_Cancel_Date' 
		when columns_csv like '%EligibleToDt%' then 'EligibleToDt' 
		when columns_csv like '%EligibleThruDt%' then 'EligibleThruDt' 
		when columns_csv like '%Med Termination%' then 'Med Termination' 
		when columns_csv like '%Med[_]Termination%' then 'Med_Termination' 
		when columns_csv like '%Coverage[_]Term[_]Date%' then 'Coverage_Term_Date' 
		when columns_csv like '%Medical Termination Date%' then 'Medical Termination Date' 
		when columns_csv like '%EFFENDDATE%' then 'EFFENDDATE' 
		when columns_csv like '%Benefit[_]End[_]Date%' then 'Benefit_End_Date' 
		when columns_csv like '%End[_]Date%' then 'End_Date' 
		when columns_csv like '%ACTENDDT%' then 'ACTENDDT' 
		when columns_csv like '%StructureCancelDate%' then 'StructureCancelDate' 
		when columns_csv like '%Individual Cancel Date at Aetna%' then 'Individual Cancel Date at Aetna' 
		ELSE 'NULL' END as [End Date Identifier] 	

	, case 
		when columns_csv like '%File[_]Name%' then 'File_Name' 
		when columns_csv like '%FileName%' then 'FileName' 
		when columns_csv like '%FilesName%' then 'FilesName' 
	 ELSE 'NULL' END as [Source File Name Identifier] 

	, case 
		when columns_csv like '%EDIT[_]STATUS%' then 'EDIT_STATUS' 
	 ELSE 'NULL' END as [Void Row Identifier] 
into #Table_with_ID_Info
from #schema_summary s;

  

/*
	U CALI HAS THE SUBSCRIBER AND DEPENDENT NAMES IN SEPARATE COLUMNS
	
	[PRODELGBLTY1].[PREMIER_Eligibility_Staging].dbo.
	Orion_SUREST_PREMIER_RAWFILE - HAS NO LINES
	Tbl_Fidelity_Disney_Dependent_Raw MAYBE HAS SLNO AND SSN, BUT NO MEMBER ID. DOUBLE CHECK...
*/

 
 
  
    
DELETE FROM #Table_with_ID_Info
WHERE ISNULL([Member Identifier],'')='';
 

update #Table_with_ID_Info 
set table_name = '['+table_name+']'
from #Table_with_ID_Info
where left(table_name,1)<>'[';
  
   

drop table if exists [WorkBench].[dbo].[Eligibility_Table_Identifiers_RAW];
select
	  t.[Server]
	, e.Contract
	, t.table_name
	, e.Full_Table_Name
	, t.[Member Identifier]
	, t.[Relationship Identifier]
	, t.[First Name Identifier]
	, t.[Last Name Identifier]
	, t.[Email Identifier]
	, t.[Main Phone Identifier]
	, t.[Street Address Identifier]
	, t.[Address 2 Identifier]
	, t.[City Identifier]
	, t.[State Identifier]
	, t.[Zip Identifier]
	, t.[Birthday Identifier]
	, t.[Start Date Identifier]
	, t.[End Date Identifier]
	, t.[Void Row Identifier]
	, t.[Source File Name Identifier]
into [WorkBench].[dbo].[Eligibility_Table_Identifiers_RAW]
from #Table_with_ID_Info t
left join  [WorkBench].[dbo].[Eligibility_Table_Names_by_Client_RAW_Premier] e
	on  t.table_name = ('['+e.Table_Name+']')
; 