-- ================================
-- Create User-defined Table Type
-- ================================
USE [Moroz]
GO

-- Create the data type
CREATE TYPE [dbo].[DATAFORDAY] AS TABLE 
  (
    [date_commit]   DATE,
    [id_part]       INT,
    [id_guds_unit]  INT
  )
GO
