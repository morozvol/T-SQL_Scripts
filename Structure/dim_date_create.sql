CREATE TABLE dbo.dim_date
(
    date_key            INT     NOT NULL PRIMARY KEY,
    date_value          DATE    NOT NULL,
    month_day_number    INT     NOT NULL
)
