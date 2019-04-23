
IF (OBJECT_ID ('dace.vwComprobanteCFDI', 'V') IS NULL)
   exec('create view dace.vwComprobanteCFDI as SELECT 1 as t');
go

--IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'dace.vwComprobanteCFDI') AND OBJECTPROPERTY(id,N'IsView') = 1)
--    DROP view dace.vwComprobanteCFDI;
--GO

alter VIEW dace.vwComprobanteCFDI  AS  
--Propósito. Obtiene los cfdis cargados
--
  select cfdi.UUID,
	cfdi.TIPOCOMPROBANTE,
	cfdi.FOLIO,
	cfdi.FECHA,
	cfdi.TOTAL,
	cfdi.MONEDA,
	cfdi.METODOPAGO,
	cfdi.EMISOR_RFC,
	cfdi.RESUMENCFDI,
	cfdi.NOMBREARCHIVO,
	cfdi.CARPETAARCHIVO,
	isnull(cfdi.VALIDADO, 0) VALIDADO,
	isnull(asig.VCHRNMBR, '') VCHRNMBR,
	isnull(asig.DOCTYPE, 0) DOCTYPE
  from dace.ComprobanteCFDI cfdi
  left join dbo.ACA_IETU00400 asig
	on rtrim(asig.MexFolioFiscal) = cfdi.UUID

GO


IF (@@Error = 0) PRINT 'Creación exitosa de la vista: dace.vwComprobanteCFDI'
ELSE PRINT 'Error en la creación de la vista: dace.vwComprobanteCFDI'
GO


--SELECT TABLE_CATALOG, TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, COLUMN_DEFAULT, *  
--FROM INFORMATION_SCHEMA.COLUMNS  
--WHERE TABLE_NAME = N'ComprobanteCFDI'
--and TABLE_SCHEMA = 'dace'

----------------------------------------------------------------------------------
  
--select *
--from dace.vwComprobanteCFDI

--sp_columns aca_ietu00400
