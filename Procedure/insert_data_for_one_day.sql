EXEC create_procedure_if_is_not_created 'insert_data_for_one_day'
GO
ALTER PROCEDURE [dbo].[insert_data_for_one_day]
@date DATE
AS BEGIN
  DECLARE
    @startnum INT=1,
    @endnum INT=1000


    --создаём таблицу с цифрами от @startnum до @endnum
  ;WITH gen AS 
  (
    SELECT
      num = @startnum

    UNION ALL

    SELECT
      num+1
    FROM gen
    WHERE num + 1 <= @endnum
  )

  SELECT num 
  INTO #numbers
  FROM gen
  option (maxrecursion 10000)

  INSERT INTO @res_table
    SELECT
      date_commit   = @date,
      id_part       = ABS(CHECKSUM(NEWID()) % 10000), -- генерация рандомного числами  от 0 до (10000-1)
      id_guds_unit  = ABS(CHECKSUM(NEWID()) % 10000)
    FROM #numbers

END
GO
