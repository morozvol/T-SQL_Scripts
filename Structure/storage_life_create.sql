EXEC create_procedure_if_is_not_created 'storage_life_create'
GO
--создание таблици storage life
ALTER PROCEDURE [dbo].[storage_life_create]
AS
BEGIN

  CREATE TABLE [dbo].[storage_life]
  (
    [id] [int] IDENTITY(1,1) NOT NULL,
    [date_commit] [date] NOT NULL,
    [id_part] [int] NOT NULL,
    [id_guds_unit] [int] NOT NULL,
    CONSTRAINT [PK_storage_life] PRIMARY KEY CLUSTERED 
    (
      [id] ASC
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY]

END
GO
