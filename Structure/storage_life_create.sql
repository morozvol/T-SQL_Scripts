EXEC create_procedure_if_is_not_created 'storage_life_create'
GO
--создание таблици storage life
ALTER PROCEDURE [dbo].[storage_life_create] 
AS
BEGIN

    CREATE TABLE [dbo].[storage_life]
    (
      id              INT   NOT NULL IDENTITY(1,1),
      date_commit     DATE  NOT NULL,
      id_part         INT   NOT NULL,
      id_guds_unit    INT   NOT NULL,
     constraint [PK_storage_life_id] primary key clustered (id),
     index IX_storage_life_date_commit (date_commit)
) 

END
GO
