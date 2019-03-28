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
  INTO numbers
  FROM gen
  option (maxrecursion 10000)
