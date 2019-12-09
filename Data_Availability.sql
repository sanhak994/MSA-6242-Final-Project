--SQL Cursor to collect information about data availability for each column
--Create a table with (tablename, colname, minyearcount, maxyearcount, minyear, maxyear)

DROP TABLE IF EXISTS #Temp
DROP TABLE IF EXISTS dbo.Data_Availability 

CREATE TABLE dbo.Data_Availability
(tablename nvarchar(255),
 colname nvarchar(255),
 minyearcount int,
 maxyearcount int,
 minyear int,
 maxyear int)
 
DECLARE @tablename nvarchar(255)
DECLARE @colname nvarchar(255)
DECLARE @minyearcount int
DECLARE @maxyearcount int
DECLARE @minyear int
DECLARE @maxyear int
DECLARE @minyearcountquery nvarchar(max)
DECLARE @maxyearcountquery nvarchar(max)
DECLARE @minyearquery nvarchar(max)
DECLARE @maxyearquery nvarchar(max)

SELECT a.TABLE_NAME, a.COLUMN_NAME INTO #Temp FROM (
SELECT TABLE_NAME, COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = N'States_Demographic'
UNION
SELECT TABLE_NAME, COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = N'States_Education'
UNION
SELECT TABLE_NAME, COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = N'States_EF'
UNION
SELECT TABLE_NAME, COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = N'States_Govt'
UNION
SELECT TABLE_NAME, COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = N'States_Health'
UNION
SELECT TABLE_NAME, COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = N'States_OPI'
UNION
SELECT TABLE_NAME, COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = N'States_Policy'
) a
WHERE a.COLUMN_NAME NOT IN ('stateyear','year','state','st','stateno','state_fips','state_icpsr')

INSERT INTO dbo.Data_Availability (tablename, colname)
SELECT TABLE_NAME, COLUMN_NAME FROM #Temp


DECLARE colCursor CURSOR FOR SELECT TABLE_NAME, COLUMN_NAME FROM #Temp


OPEN colCursor
FETCH NEXT FROM colCursor INTO @tablename, @colname
--Loop through the column names
WHILE @@FETCH_STATUS = 0
BEGIN

	--Get the "availability" metrics for each column name
	SET @minyearcountquery = 
	'SELECT @minyearcount = MIN(a.yearcount) FROM ('+
	'SELECT [state], COUNT(*) as yearcount FROM '+@tablename+' '+
	'WHERE [year] > 2002 AND '+@colname+' IS NOT NULL '+
	'GROUP BY [state]) a'

	EXEC sp_executesql @minyearcountquery, N'@minyearcount int out', @minyearcount out


	SET @maxyearcountquery = 
	'SELECT @maxyearcount = MAX(a.yearcount) FROM ('+
	'SELECT [state], COUNT(*) as yearcount FROM '+@tablename+' '+
	'WHERE [year] > 2002 AND '+@colname+' IS NOT NULL '+
	'GROUP BY [state]) a'

	EXEC sp_executesql @maxyearcountquery, N'@maxyearcount int out', @maxyearcount out


	SET @minyearquery = 
	'SELECT @minyear = MIN([year]) FROM '+@tablename+' '+
	'WHERE [year] > 2002 AND '+@colname+' IS NOT NULL '

	EXEC sp_executesql @minyearquery, N'@minyear int out', @minyear out


	SET @maxyearquery = 
	'SELECT @maxyear = MAX([year]) FROM '+@tablename+' '+
	'WHERE [year] > 2002 AND '+@colname+' IS NOT NULL '

	EXEC sp_executesql @maxyearquery, N'@maxyear int out', @maxyear out

	--Update Data_Availability with data retrieved above
	UPDATE dbo.Data_Availability SET minyearcount = @minyearcount
	WHERE tablename = @tablename AND colname = @colname

	UPDATE dbo.Data_Availability SET maxyearcount = @maxyearcount
	WHERE tablename = @tablename AND colname = @colname

	UPDATE dbo.Data_Availability SET minyear = @minyear
	WHERE tablename = @tablename AND colname = @colname

	UPDATE dbo.Data_Availability SET maxyear = @maxyear
	WHERE tablename = @tablename AND colname = @colname
	

	FETCH NEXT FROM colCursor INTO @tablename, @colname

END
CLOSE colCursor
DEALLOCATE colCursor