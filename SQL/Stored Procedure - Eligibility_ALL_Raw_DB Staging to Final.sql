USE [WorkBench]
GO

CREATE PROCEDURE [dbo].[sp_Eligibility_Aggregation_RAW_Staging_to_Final]

--ALTER PROCEDURE [dbo].[sp_Eligibility_Aggregation_RAW_Staging_to_Final]

--STAGING TABLE: [xxEligibility_All_RAW]: RENAME TO Eligibility_ALL_Raw_DB_Extraction
--Transformation: Eligibility_ALL_RAW_DB_STAGING
--Load/Finaltable: Eligibility_ALL_RAW_DB_FINAL
AS
BEGIN

MERGE WorkBench.dbo.Eligibility_ALL_RAW_DB eFL
	USING WorkBench.dbo.Eligibility_ALL_RAW_DB_STAGING s
		on efl.[Contract] = s.[Contract]
			and eFL.Member_ID = s.Member_ID
			and eFL.Relationship_ID = s.Relationship_ID
			and eFL.First_Name = s.First_Name
			and eFL.Last_Name = s.Last_Name
			and eFL.Email = s.Email
			and eFL.Main_Phone = s.Main_Phone
			and eFL.Street_Address = s.Street_Address
			and eFL.Address_2 = s.Address_2
			and eFL.City = s.City
			and eFL.[State] = s.[State] 
			and eFL.Zip = s.Zip
			and eFL.Date_of_Birth = s.Date_of_Birth
			and eFL.Coverage_Start_Date = s.Coverage_Start_Date
			and eFL.Coverage_End_Date = s.Coverage_End_date
			and eFL.[File_Name] = s.[File_Name]
			and eFL.Source_Table = s.Source_Table
			and eFL.File_Size = s.File_Size
			and eFL.IS_CreatedDate = s.IS_CreatedDate
			and eFL.File_Name_Date = s.File_Name_Date
			and eFL.File_Name_Date_Cleaned = s.File_Name_Date_Cleaned
			and eFL.Raw_File_TimeStamp = s.Raw_File_TimeStamp
			and eFL.Chosen_Date = s.Chosen_Date
	WHEN NOT MATCHED THEN
	INSERT 
	(
		  [Contract]
		, Member_ID
		, Relationship_ID
		, First_Name
		, Last_Name
		, Email
		, Main_Phone
		, Street_Address
		, Address_2
		, City
		, [State]
		, Zip
		, Date_of_Birth
		, Coverage_Start_Date
		, Coverage_End_Date
		, [File_Name]
		, Source_Table
		, File_Size
		, IS_CreatedDate 
		, File_Name_Date
		, File_Name_Date_Cleaned
		, Raw_File_TimeStamp
		, Chosen_Date
	) VALUES
	(
		  s.[Contract]
		, s.Member_ID
		, s.Relationship_ID
		, s.First_Name
		, s.Last_Name
		, s.Email
		, s.Main_Phone
		, s.Street_Address
		, s.Address_2
		, s.City
		, s.[State]
		, s.Zip
		, s.Date_of_Birth
		, s.Coverage_Start_Date
		, s.Coverage_End_Date
		, s.[File_Name]
		, s.Source_Table
		, s.File_Size
		, s.IS_CreatedDate 
		, s.File_Name_Date
		, s.File_Name_Date_Cleaned
		, s.Raw_File_TimeStamp
		, s.Chosen_Date
	);
END
