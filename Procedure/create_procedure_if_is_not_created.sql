
CREATE PROCEDURE [dbo].[create_procedure_if_is_not_created]
(
  @proc_name  NVARCHAR (MAX)
)AS
BEGIN

  DECLARE @sql_command  NVARCHAR (MAX) ='
  IF NOT EXISTS (SELECT * FROM sys.objects WHERE type = ''P'' AND OBJECT_ID = OBJECT_ID(''dbo.##proc_name##''))
  EXEC(''CREATE PROCEDURE [dbo].[##proc_name##] AS BEGIN SET NOCOUNT ON; END'')'
  SET @sql_command = REPLACE(@sql_command, N'##proc_name##' , @proc_name)
  EXECUTE SP_EXECUTESQL @sql_command

END
