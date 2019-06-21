
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_dace_smartlist1]'))
DROP VIEW [dbo].[vw_dace_smartlist1]
GO


--Propósito. Controla la aplicación de cfdis de compras
--31/12/18 LT Creación
--05/02/19 jcf Reformulación de consulta
--26/04/19 jcf Agrega CfdiXml_Total, voided
--11/06/19 jcf Agrega validaciones.CfdiXml_Folio
--
create VIEW [dbo].[vw_dace_smartlist1]
AS
SELECT  0 CNTRLTYP, m.DOCTYPE [Tipo de documento], m.VCHRNMBR [Num. comprobante], m.DOCNUMBR [Num. documento], m.DOCDATE [Fecha], m.VENDORID [Id. proveedor], m.VOIDED Anulado, 
		isnull(validaciones.DOCAMNT, 0) [Monto documento], isnull(validaciones.CURNCYID, '') [Moneda], validaciones.TRXDSCRN [Referencia],
		validaciones.UUID [UUID del Cfdi xml], validaciones.CfdiXml_MetodoPago MetodoPago, 
		validaciones.CfdiXml_Folio [Folio del Cfdi xml], validaciones.CfdiXml_MetodoPago [Metodo pago del Cfdi xml], validaciones.CfdiXml_Moneda [Moneda del Cfdi xml], validaciones.CfdiXml_Total [Total del Cfdi xml],  
		isnull(validaciones.observaciones, '') observaciones, 
		3 DCSTATUS, m.TXRGNNUM [RFC], m.VENDNAME [Nombre del proveedor], validaciones.numComprobantesAplicados
FROM dbo.vwPmTransaccionesTodas m 
	 cross apply [dbo].[daceFnValidaAplicacionCFDICompra](m.VCHRNMBR, m.DOCTYPE) validaciones  

GO

GRANT  SELECT ON [dbo].[vw_dace_smartlist1] TO [DYNGRP] 
GO 
------------------------------------------------------------------------------------------------
