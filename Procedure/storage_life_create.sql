EXEC create_procedure_if_is_not_created 'storage_life_create'
GO
--�������� ������� storage life
ALTER PROCEDURE [dbo].[storage_life_create]
AS BEGIN

  CREATE TABLE [dbo].[storage_life]
  (
    id              INT   NOT NULL IDENTITY(1,1),
    date_commit     DATE  NOT NULL,
    id_part         INT   NOT NULL,
    id_guds_unit    INT   NOT NULL
  )

END