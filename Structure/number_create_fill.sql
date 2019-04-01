  DECLARE
    @startnum INT=1,
    @endnum INT=465000

SELECT 
  num = ones.n + 10*tens.n + 100*hundreds.n + 1000*thousands.n + 10000 * thousands1.n + 100000 * thousands2.n
INTO numbers
FROM (VALUES(0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) ones(n),
     (VALUES(0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) tens(n),
     (VALUES(0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) hundreds(n),
     (VALUES(0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) thousands(n),
     (VALUES(0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) thousands1(n),
     (VALUES(0),(1),(2),(3),(4),(5),(6),(7),(8),(9)) thousands2(n)
WHERE ones.n + 10 * tens.n + 100 * hundreds.n + 1000 * thousands.n + 10000 * thousands1.n + 100000 * thousands2.n BETWEEN @startnum AND @endnum
ORDER BY 1