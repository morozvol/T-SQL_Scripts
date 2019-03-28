EXEC create_procedure_if_is_not_created 'storage_life_create'
GO
--создание таблици storage life
ALTER PROCEDURE [dbo].[storage_life_create]
(
  @date_from  DATE,
  @date_to    DATE
)
 AS
BEGIN

  SET @date_from = DATEADD(DAY, DATEDIFF(DAY, 0, EOMONTH(@date_from, -1)), 1)
  SET @date_to   = DATEADD(DAY, DATEDIFF(DAY, 0, EOMONTH(@date_to)), 1)
  DECLARE @sql_command NVARCHAR(MAX) = '
  CREATE TABLE [dbo].[storage_life]
  (
    id              INT   NOT NULL IDENTITY(1,1),
    date_commit     DATE  NOT NULL
      CHECK(date_commit >=  ''##@date_from##''
        AND date_commit <   ''##@date_to##'' ),
    id_part         INT   NOT NULL,
    id_guds_unit    INT   NOT NULL
  )
  '
  SET @sql_command = REPLACE(@sql_command, N'##@date_from##',  @date_from)
  SET @sql_command = REPLACE(@sql_command, N'##@date_to##',    @date_to)
  EXECUTE SP_EXECUTESQL @sql_command
  print @sql_command
END