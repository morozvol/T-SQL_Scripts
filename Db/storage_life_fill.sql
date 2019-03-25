
-- ��������� storage_life ������� ��������� � �������� ������ dim_date �� ������������ ����� (����������� ������������� - �����)
ALTER PROCEDURE [dbo].[storage_life_fill]
(
  @date_from  DATE,
  @date_to    DATE
) AS
BEGIN

  -- ����������� ������ �� ������ � ����� ������ (+1 ����)
  SET @date_from = DATEADD(DAY, DATEDIFF(DAY, 0, EOMONTH(@date_from, -1)), 1)
  SET @date_to   = DATEADD(DAY, DATEDIFF(DAY, 0, EOMONTH(@date_to)), 1)
  DECLARE @date DATE,
    @cursor CURSOR,
    @startnum INT=1,
    @endnum INT=1000
    --������ ������� � ������� �� @startnum �� @endnum
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

  --������ �� ���� �� ��������� ��� ��� ���� ������ @date_from � ������ @date_to
  SET @cursor = CURSOR SCROLL FOR
  SELECT
    date_value
  FROM [dbo].[dim_date]
  WHERE date_value >= @date_from
    AND date_value <  @date_to

  OPEN @cursor
  FETCH NEXT FROM @cursor INTO @date
  WHILE @@FETCH_STATUS = 0
  BEGIN

    BEGIN TRANSACTION
    INSERT INTO [dbo].[storage_life]
    SELECT
      date_commit   = @date,
      id_part       = ABS(CHECKSUM(NEWID()) % 10000), -- ���������� ���������� �������  �� 0 �� (10000-1)
      id_guds_unit  = ABS(CHECKSUM(NEWID()) % 10000)
    FROM #numbers
    COMMIT

    FETCH NEXT FROM @cursor INTO @date

  END

END

--SELECT * FROM [dbo].[storage_life] ORDER BY date_commit
--DELETE [dbo].[storage_life]
--EXEC [dbo].[storage_life_fill] '20180102','20180302'