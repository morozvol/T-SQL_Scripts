EXEC create_procedure_if_is_not_created 'insert_data_for_one_day'
GO

 -- возвращает данные на один день
ALTER PROCEDURE [dbo].[insert_data_for_one_day]
(
  @date DATE
) AS
BEGIN

  SELECT
    date_commit   = @date,
    id_part       = ABS(CHECKSUM(NEWID()) % 10000), -- генерация рандомного числами  от 0 до 10000
    id_guds_unit  = ABS(CHECKSUM(NEWID()) % 10000)
  FROM numbers

END
