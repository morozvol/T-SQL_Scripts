EXEC create_procedure_if_is_not_created 'storage_life_fill'
GO

-- ��������� storage_life ������� ��������� � �������� ������ dim_date �� ������������ ����� (����������� ������������� - �����)
ALTER PROCEDURE [dbo].[storage_life_fill]
(
  @date_from  DATE,
  @date_to    DATE
) AS
BEGIN

  DECLARE
    @date_c DATE,
    @res_date_table_for_one_day DATE,
    @cursor CURSOR


      -- ����������� ������ �� ������ � ����� ������ (+1 ����)
  SET @date_from = DATEADD(DAY, DATEDIFF(DAY, 0, EOMONTH(@date_from, -1)), 1)
  SET @date_to   = DATEADD(DAY, DATEDIFF(DAY, 0, EOMONTH(@date_to)), 1)


  --������ �� ���� �� ��������� ��� ��� ���� ������ @date_from � ������ @date_to
  SET @cursor = CURSOR SCROLL FOR
  SELECT
    date_value
  FROM [dbo].[dim_date]
  WHERE date_value >= @date_from
    AND date_value <  @date_to

  OPEN @cursor
  FETCH NEXT FROM @cursor INTO @date_c
  WHILE @@FETCH_STATUS = 0
  BEGIN

    INSERT INTO storage_life EXEC [insert_data_for_one_day] @date_c
    FETCH NEXT FROM @cursor INTO @date_c

  END
END

--SELECT * FROM [dbo].[storage_life]
--DELETE [dbo].[storage_life]
--EXEC [dbo].[storage_life_fill] '2018-01-12', '2019-05-12'