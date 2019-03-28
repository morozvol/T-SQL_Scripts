EXEC create_procedure_if_is_not_created 'storage_life_update'
GO
--замена данных в таблице storage_life в заданном диапозоне
ALTER PROCEDURE [dbo].[storage_life_update]
(
@date_from DATE,
@date_to DATE
)AS
BEGIN

  DECLARE
  @sql_сommand  NVARCHAR (MAX),
  @cursor       CURSOR,
  @date         DATE

  SET @date_from = DATEADD(DAY, DATEDIFF(DAY, 0, EOMONTH(@date_from, -1)), 1)
  SET @date_to   = DATEADD(DAY, DATEDIFF(DAY, 0, EOMONTH(@date_to)), 1)

  SET @cursor  = CURSOR SCROLL
  FOR
    SELECT date_value
    FROM dim_date
    WHERE month_day_number  =   1 
      AND date_value        >=  @date_from 
      AND date_value        <   @date_to

  OPEN @cursor
  FETCH NEXT FROM @cursor INTO @date

  WHILE @@FETCH_STATUS = 0
  BEGIN
  BEGIN TRANSACTION

  SET @sql_сommand = '
  ALTER TABLE storage_life SWITCH PARTITION $PARTITION.PF_stronge_life_date_range(##date##) TO storage_life_non_partition
  '
    SET @sql_сommand = REPLACE(@sql_сommand, '##date##',''''+CONVERT(NVARCHAR(MAX), @date, 23)+'''')
    EXEC period_fill_in_table @date, @date, 'storage_life_non_partition'
    EXECUTE SP_EXECUTESQL @sql_сommand
    TRUNCATE TABLE storage_life_non_partition
  COMMIT

  FETCH NEXT FROM @cursor INTO @date

  END
END


--EXEC storage_life_update '20180102','20180302'
--EXEC period_fill_in_table '20180102','20180302','storage_life'
--SELECT * FROM storage_life ORDER BY (date_commit)