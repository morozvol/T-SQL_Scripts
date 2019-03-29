--EXEC create_procedure_if_is_not_created 'storage_life_update'
--GO

--замена данных в таблице storage_life в заданном диапозоне
--ALTER PROCEDURE [dbo].[storage_life_update]
--(
DECLARE
  @date_from  DATE = '2020-01-01',
  @date_to    DATE = '2022-03-28'
--)AS
--BEGIN

  DECLARE
    @sql_сommand            NVARCHAR (MAX),
    @create_constraint_sql  NVARCHAR(MAX),
    @cursor                 CURSOR,
    @date                   DATE

  SET @date_from = DATEADD(DAY, DATEDIFF(DAY, 0, EOMONTH(@date_from, -1)), 1)
  SET @date_to   = DATEADD(DAY, DATEDIFF(DAY, 0, EOMONTH(@date_to)), 1)

  SET @cursor  = CURSOR SCROLL FOR
  SELECT
    date_value
  FROM dim_date
  WHERE
         date_value        >=  @date_from 
    AND  date_value        <   @date_to

  OPEN @cursor
  FETCH NEXT FROM @cursor INTO @date

  WHILE @@FETCH_STATUS = 0
  BEGIN

    BEGIN TRANSACTION
    
    IF(@date = DATEADD(DAY, DATEDIFF(DAY, 0, EOMONTH(@date, -1)), 1))--первый день месяца
    BEGIN

    SET @sql_сommand = '
    ALTER TABLE storage_life SWITCH PARTITION $PARTITION.PF_stronge_life_date_range(##date##) TO storage_life_non_partition
    '
      SET @sql_сommand = REPLACE(@sql_сommand, '##date##',''''+CONVERT(NVARCHAR(MAX), @date, 23)+'''')
      EXECUTE SP_EXECUTESQL @sql_сommand
      TRUNCATE TABLE storage_life_non_partition

    END

    INSERT INTO storage_life_non_partition EXEC [insert_data_for_one_day] @date

    IF(@date = EOMONTH(@date))
    BEGIN

      SELECT *FROM storage_life_non_partition
       SET @create_constraint_sql = '
  IF EXISTS (SELECT * FROM sys.objects WHERE type = ''C'' AND OBJECT_ID = OBJECT_ID(''check_date''))
  BEGIN
  ALTER TABLE storage_life_non_partition DROP CONSTRAINT check_date
  END
  ALTER TABLE [dbo].[storage_life_non_partition]  WITH CHECK ADD  CONSTRAINT [check_date] CHECK  (([date_commit]>=''##@date_from##'' AND [date_commit]<''##@date_to##''))
  ALTER TABLE [dbo].[storage_life_non_partition] CHECK CONSTRAINT [check_date]
  '
      SET @create_constraint_sql = REPLACE(@create_constraint_sql, '##@date_from##',  CONVERT(NVARCHAR(MAX), DATEADD(DAY, DATEDIFF(DAY, 0, EOMONTH(@date, -1)), 1), 23))
      SET @create_constraint_sql = REPLACE(@create_constraint_sql, '##@date_to##',    CONVERT(NVARCHAR(MAX),DATEADD(DAY, DATEDIFF(DAY, 0, EOMONTH(@date)), 1), 23))
      PRINT @create_constraint_sql
      EXECUTE SP_EXECUTESQL @create_constraint_sql
      SET @sql_сommand = '
  ALTER TABLE storage_life_non_partition SWITCH TO storage_life PARTITION $PARTITION.PF_stronge_life_date_range(##date##)
    '
      SET @sql_сommand = REPLACE(@sql_сommand, '##date##',''''+CONVERT(NVARCHAR(MAX), @date, 23)+'''')
      PRINT @sql_сommand
      EXECUTE SP_EXECUTESQL @sql_сommand
      TRUNCATE TABLE storage_life_non_partition
       ALTER TABLE storage_life_non_partition DROP CONSTRAINT check_date
    END

    COMMIT
    FETCH NEXT FROM @cursor INTO @date

  END
--END


--EXEC storage_life_update '2020-01-01','2022-03-28'
--EXEC period_fill_in_table '2020-01-01','2021-03-28','storage_life'
--SELECT * FROM storage_life ORDER BY (date_commit)
--SELECT * FROM sys.all_objects WHERE name = 'check_date'