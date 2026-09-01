SET QUOTED_IDENTIFIER OFF
DECLARE @SQL nVARCHAR(MAX) = '';

SELECT  @SQL =  STRING_AGG(CONVERT( VARCHAR(MAX), " SELECT  
Contract = '" + [Contract] + "', " 
+ "Member_ID = CONVERT(varchar(50), " + CASE WHEN [Member Identifier] <> 'NULL' THEN QUOTENAME([Member Identifier]) ELSE 'NULL' END   + "), "
+ "Relationship_ID = CONVERT(varchar(50), " + CASE WHEN [Relationship Identifier] <> 'NULL' THEN QUOTENAME([Relationship Identifier]) ELSE 'NULL' END   + "), "
+ "First_Name = CONVERT(varchar(50), " + CASE WHEN [First Name Identifier] <> 'NULL' THEN QUOTENAME([First Name Identifier]) ELSE 'NULL' END   + "), "
+ "Last_Name = CONVERT(varchar(50), " + CASE WHEN [Last Name Identifier] <> 'NULL' THEN QUOTENAME([Last Name Identifier]) ELSE 'NULL'  END  + "), "
+ "Email = CONVERT(varchar(50), " + CASE WHEN [Email Identifier] <> 'NULL' THEN QUOTENAME([Email Identifier]) ELSE 'NULL' END + "), "
+ "Main_Phone = CONVERT(varchar(50), " + CASE WHEN [Main Phone Identifier] <> 'NULL' THEN QUOTENAME([Main Phone Identifier]) ELSE 'NULL' END + "), "
+ "Street_Address = CONVERT(varchar(500), " + CASE WHEN [Street Address Identifier] <> 'NULL' THEN QUOTENAME([Street Address Identifier])  ELSE 'NULL' END + "), "
+ "Address_2 = CONVERT(varchar(500), " + CASE WHEN [Address 2 Identifier] <> 'NULL' THEN QUOTENAME([Address 2 Identifier])  ELSE 'NULL' END + "), "  
+ "City = CONVERT(varchar(50), " + CASE WHEN [City Identifier] <> 'NULL' THEN QUOTENAME([City Identifier])  ELSE 'NULL' END + "), "    
+ "State = CONVERT(varchar(50), " + CASE WHEN [State Identifier] <> 'NULL' THEN QUOTENAME([State Identifier])  ELSE 'NULL' END + "), "    
+ "Zip = CONVERT(varchar(50), " + CASE WHEN [Zip Identifier] <> 'NULL' THEN QUOTENAME([Zip Identifier])  ELSE 'NULL' END + "), "
+ "Date_of_Birth = TRY_CONVERT(date, " + CASE WHEN [Birthday Identifier] <> 'NULL' THEN   QUOTENAME([Birthday Identifier])  ELSE 'NULL' END + "), "   
+ "Coverage_Start_Date = TRY_CONVERT(date , " + CASE WHEN [Start Date Identifier] <> 'NULL' THEN   QUOTENAME([Start Date Identifier])  ELSE 'NULL' END + "), "  
+ "Coverage_End_Date =  TRY_CONVERT(date, " + CASE WHEN [End Date Identifier] <> 'NULL' THEN   QUOTENAME([End Date Identifier])  ELSE 'NULL' END + "), " 
+ "File_Name =  CONVERT(varchar(500), " + CASE WHEN [source file name identifier] <> 'NULL' THEN   QUOTENAME([source file name identifier])  ELSE 'NULL' END + "), " 
+ "Source_Table =  CONVERT(varchar(500), " + CASE WHEN [Full_Table_Name] <> 'NULL' THEN CONCAT('''', [Full_Table_Name], '''')  ELSE 'NULL' END + ") " 
+ " FROM " + [Full_Table_Name]), ' UNION ALL ')  
 FROM WorkBench.dbo.Eligibility_Table_Identifiers_RAW 
WHERE  --[Void Row Identifier]='null'
	table_name in (
		--'[Orion_SUREST_PREMIER_RAWFILE --empty
		--,'[ISUZU_MERITAIN_RAWFILE]'  --empty
		--,'[Enbridge_RAWFILE]' --added
		--,
		'[BorgWarner_PREMIER_RAWFILE]'
		,'[SEATTLE_FIRE_FIGHTERS_STAGING_RAWFILE]'
		--,"[JBSS_RAWFILE]"
		,'[newmountain]'
		--,'[SPOKANE_RAWFILE]'
		--,'[Xo_health_RAWFILE]'
		--,'[Orion_UHC_PREMIER_RAWFILE]' --empty
		--,'[OGLETREE_PREMIER_RAWFILE]' --empty
		)
SELECT @sql;

SET @SQL = CONVERT(VARCHAR(MAX), --"DROP TABLE IF EXISTS  WorkBench.dbo.xxEligibility_All_RAW; 
		"insert INTO Workbench.dbo.xxEligibility_All_RAW     (
        Contract,
        Member_ID,
        Relationship_ID,
        First_Name,
        Last_Name,
        Email,
        Main_Phone,
        Street_Address,
        Address_2,
        City,
        State,
        Zip,
        Date_of_Birth,
        Coverage_Start_Date,
        Coverage_End_Date,
		File_Name,
        Source_Table
    ) "+ @SQL + " ")
SELECT @SQL
EXEC (@SQL)

 


 
  