--DROP TABLE dace.ComprobanteCFDIRelacionado;
--DROP TABLE dace.ComprobanteCFDI;


IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'dace')
BEGIN
    EXEC( 'create schema dace authorization rol_contaelectr;' );
END
go

--Agregar el campo validado si no existe
IF OBJECT_ID('dace.ComprobanteCFDI', 'U') IS not NULL
begin
	IF not exists (
		SELECT TABLE_CATALOG, TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, COLUMN_DEFAULT 
		FROM INFORMATION_SCHEMA.COLUMNS  
		WHERE TABLE_NAME = N'ComprobanteCFDI'
		and TABLE_SCHEMA = 'dace'
		and COLUMN_NAME = 'VALIDADO')
	begin
		alter table dace.ComprobanteCFDI add VALIDADO SMALLINT DEFAULT 0;
	end

	IF not exists (
		SELECT TABLE_CATALOG, TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, COLUMN_DEFAULT 
		FROM INFORMATION_SCHEMA.COLUMNS  
		WHERE TABLE_NAME = N'ComprobanteCFDI'
		and TABLE_SCHEMA = 'dace'
		and COLUMN_NAME = 'archivoXML')
	begin
		alter table dace.ComprobanteCFDI add archivoXML xml default ''
	end
	--declare @id varchar(50), @sql varchar(250)
	--select @id = left(replace(replace(convert(varchar(50), getdate(), 127), ':', ''), '-', ''), 15);
	--select @sql = 'select * into _ComprobanteCFDI_' + @id + ' from dace.ComprobanteCFDI;';
	--exec (@sql);
end

-- ------------------------------------------------------------
-- Guarda datos relevantes de los CFDIs recibidos del proveedor
-- ------------------------------------------------------------
IF OBJECT_ID('dace.ComprobanteCFDI', 'U') IS NULL
begin

	CREATE TABLE dace.ComprobanteCFDI (
	  UUID VARCHAR(50)  NOT NULL  ,
	  TIPOCOMPROBANTE VARCHAR(1)  NOT NULL  ,
	  FOLIO VARCHAR(35)    ,
	  FECHA VARCHAR(20)  NOT NULL  ,
	  TOTAL NUMERIC(19,5)  NOT NULL DEFAULT 0 ,
	  MONEDA VARCHAR(15)  NOT NULL  ,
	  METODOPAGO VARCHAR(5)    ,
	  EMISOR_RFC VARCHAR(30)  NOT NULL  ,
	  RESUMENCFDI VARCHAR(100)    ,
	  NOMBREARCHIVO VARCHAR(255)  NOT NULL  ,
	  CARPETAARCHIVO VARCHAR(255)  NOT NULL    ,
	  VALIDADO SMALLINT DEFAULT 0,
	  archivoXML xml default '',
	PRIMARY KEY(UUID, TIPOCOMPROBANTE));
end

GO

-- ------------------------------------------------------------
-- Contiene los cfdis relacionados al pago.
-- ------------------------------------------------------------
--IF not EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = OBJECT_ID(N'dace.daceComprobanteCFDI') AND OBJECTPROPERTY(id,N'IsTable') = 1)
IF OBJECT_ID('dace.ComprobanteCFDIRelacionado', 'U') IS NULL
begin
CREATE TABLE dace.ComprobanteCFDIRelacionado (
  CFDI_TIPOCOMPROBANTE VARCHAR(1)  NOT NULL  ,
  CFDI_UUID VARCHAR(50)  NOT NULL  ,
  UUIDRELACIONADO VARCHAR(50)  NOT NULL    ,
  FOREIGN KEY(CFDI_UUID, CFDI_TIPOCOMPROBANTE)
    REFERENCES dace.ComprobanteCFDI(UUID, TIPOCOMPROBANTE)
      ON DELETE CASCADE);


end

GO

IF EXISTS (SELECT 1 FROM sysindexes WHERE Name = 'daceComprobanteCFDIRelacionado_FKIndex1') 
	DROP INDEX dace.ComprobanteCFDIRelacionado.daceComprobanteCFDIRelacionado_FKIndex1;

CREATE UNIQUE INDEX daceComprobanteCFDIRelacionado_FKIndex1 ON dace.ComprobanteCFDIRelacionado (CFDI_UUID, CFDI_TIPOCOMPROBANTE, UUIDRELACIONADO);
GO

