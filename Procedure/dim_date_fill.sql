EXEC create_procedure_if_is_not_created 'dim_date_fill'
GO
-- dim_date ���������� �������
ALTER PROCEDURE [dbo].[dim_date_fill]
    @date_from    DATE = '2017-01-01',
    @date_to      DATE = '2019-12-31'
AS
BEGIN
  BEGIN TRANSACTION

    ;WITH date_dimension AS
    (
      SELECT
        date_value = @date_from

      UNION ALL

      SELECT
        date_value = DATEADD(DAY, 1 , date_value)
      FROM date_dimension
      WHERE DATEADD(DAY, 1 , date_value) <= @date_to
    )
    INSERT INTO dbo.dim_date
    (
      date_key, 
      date_value,
      month_day_number
    )
    SELECT
      date_key            = CAST(CONVERT(VARCHAR(9), date_value, 112) AS INT),
      date_value          = date_value,
      month_day_number    = DATEPART(DAY, date_value)
    FROM date_dimension
    ORDER BY
      date_value
    option (maxrecursion 0)

  COMMIT
END

--EXEC [dbo].[dim_date_fill] 
--DELETE dim_date

--DELETE storage_life
--EXEC [dbo].[storage_life_fell]
--SELECT *FROM [dbo].[storage_life] ORDER BY date_commit