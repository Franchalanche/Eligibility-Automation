# Eligibility-Automation
The purpose of this project is to combine data from tables with totally different structures & column names into one.  The field names were extracted and organized using sys schema (System Catalog Views) for metadata (see "ALL TABLES & COLUMNS[...].sql" file). A combination of regex & Visual Studio had to be used to determine the most appropriate date for a given raw file source.  The project continues to evolve as more requirements and unique client rules enter the picture.


## SQL File Order
1) [ALL TABLES & COLUMNS IN A DATABASE v16 Eligibility Server PREMIER ONLY (Post GN Updates) w CreateDate].sql
   creates a table of table names and their corresponding column names

2) [Eligibility Aggregate No Fetch - GN Edits w FP Edits].sql
     creates the first extracted table, using only values from the original sources

3) [Stored Procedure - Eligibility_ALL_Raw_DB Initial Extract to Staging].sql
     transforms initialized table by adding calculated fields
