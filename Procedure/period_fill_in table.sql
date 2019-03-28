EXEC create_procedure_if_is_not_created 'period_fill_in_table'
GO
-- заполняет storage_life данными входящими в диапазон таблиц dim_date на произвольное время (минимальная гранулярность - месяц)
ALTER PROCEDURE [dbo].[period_fill_in_table]
(
  @date_from  DATE,
  @date_to    DATE,
  @table_name  NVARCHAR(MAX)
) AS
BEGIN

  DECLARE
    @date_с DATE,
    @sql_command NVARCHAR(MAX),
    @cursor CURSOR

  DECLARE @T AS DATAFORDAY

  -- выравниваем период на начало и конец месяца (+1 день)
  SET @date_from = DATEADD(DAY, DATEDIFF(DAY, 0, EOMONTH(@date_from, -1)), 1)
  SET @date_to   = DATEADD(DAY, DATEDIFF(DAY, 0, EOMONTH(@date_to)), 1)
  SET @sql_command ='
  INSERT INTO ##@table_name##(date_commit , id_part, id_guds_unit)Select date_commit, id_part, id_guds_unit from @T
  '
   SET @sql_command = REPLACE(@sql_command, N'##@table_name##' , @table_name)

  --курсор по дням из диапазона где все даты больше @date_from и меньше @date_to
  SET @cursor = CURSOR SCROLL FOR
  SELECT
    date_value
  FROM [dbo].[dim_date]
  WHERE date_value >= @date_from
    AND date_value <  @date_to

  OPEN @cursor
  FETCH NEXT FROM @cursor INTO @date_с
  WHILE @@FETCH_STATUS = 0
  BEGIN
  BEGIN TRANSACTION
  DELETE FROM @T
  INSERT @T EXEC [insert_data_for_one_day] @date_с
  EXECUTE SP_EXECUTESQL @sql_command, N' @T DATAFORDAY READONLY', @T;
  FETCH NEXT FROM @cursor INTO @date_с
  COMMIT
  END

END

--SELECT * FROM [dbo].[storage_life]
--TRUNCATE TABLE [dbo].[storage_life]
--EXEC [dbo].[period_fill_in_table] '2018-01-12', '2019-05-12','storage_life'