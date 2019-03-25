-- ================================
-- Create User-defined Table Type
-- ================================
USE [Moroz]
GO
-- Create the data type
CREATE TYPE [dbo].[TABLEDATE] AS TABLE 
(
[date]          DATE NOT NULL,
[id_part]       INT  NOT NULL,
[id_guds unit]  INT  NOT NULL
)
GO
