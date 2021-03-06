EXEC create_procedure_if_is_not_created 'storage_life_update'
GO

--замена данных в таблице storage_life в заданном диапозоне
ALTER PROCEDURE [dbo].[storage_life_update]
(
  @date_from  DATE,
  @date_to    DATE
)AS
BEGIN

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

    IF(@date = DATEADD(DAY, DATEDIFF(DAY, 0, EOMONTH(@date, -1)), 1))--первый день месяца
    BEGIN

      IF EXISTS (SELECT * FROM sys.objects WHERE type = 'C' AND OBJECT_ID = OBJECT_ID('check_stronge_life_date_commit'))
      BEGIN
        ALTER TABLE storage_life_non_partition DROP CONSTRAINT check_stronge_life_date_commit --если ограничение существует удаляем ег
      END

      SET @create_constraint_sql = '
  ALTER TABLE [dbo].[storage_life_non_partition]  WITH CHECK ADD  CONSTRAINT [check_stronge_life_date_commit] CHECK  (([date_commit]>=''##@date_from##'' AND [date_commit]<''##@date_to##''))
  ALTER TABLE [dbo].[storage_life_non_partition] CHECK CONSTRAINT [check_stronge_life_date_commit]
  '
      SET @create_constraint_sql = REPLACE(@create_constraint_sql, '##@date_from##',  CONVERT(NVARCHAR(MAX), DATEADD(DAY, DATEDIFF(DAY, 0, EOMONTH(@date, -1)), 1), 23))
      SET @create_constraint_sql = REPLACE(@create_constraint_sql, '##@date_to##',    CONVERT(NVARCHAR(MAX), DATEADD(DAY, DATEDIFF(DAY, 0, EOMONTH(@date)), 1), 23))
      EXECUTE SP_EXECUTESQL @create_constraint_sql

    END

    INSERT INTO storage_life_non_partition EXEC [insert_data_for_one_day] @date -- вставка данных в таблицу за 1 день

    IF(@date = EOMONTH(@date)) -- последний день месяца 
    BEGIN
      BEGIN TRANSACTION

      SET @sql_сommand = '
    ALTER TABLE storage_life SWITCH PARTITION $PARTITION.PF_stronge_life_date_commit(##date##) TO storage_life_switch
    '
      SET @sql_сommand = REPLACE(@sql_сommand, '##date##',''''+CONVERT(NVARCHAR(MAX), @date, 23)+'''')
      EXECUTE SP_EXECUTESQL @sql_сommand
      TRUNCATE TABLE storage_life_switch

      SET @sql_сommand = '
  ALTER TABLE storage_life_non_partition SWITCH TO storage_life PARTITION $PARTITION.PF_stronge_life_date_commit(''##date##'')
    '
      SET @sql_сommand = REPLACE(@sql_сommand, '##date##',CONVERT(NVARCHAR(MAX), @date, 23))
      EXECUTE SP_EXECUTESQL @sql_сommand
      TRUNCATE TABLE storage_life_non_partition

      COMMIT
    END

    FETCH NEXT FROM @cursor INTO @date

  END
END


--EXEC storage_life_update '2020-01-01','2022-03-28'
--SELECT * FROM storage_life ORDER BY (date_commit)