--VALIDACION DE LA VISTA
IF OBJECT_ID('dbo.vwListadoCfdisCompras') IS NOT NULL
			DROP VIEW dbo.vwListadoCfdisCompras
GO
--CREANDO LA VISTA
CREATE VIEW dbo.vwListadoCfdisCompras
AS
(SELECT a.VENDORID,
		a.VENDNAME AS Vendedor,
		a.txrgnnum AS NumeroCont,
		NULL ReferenciaDePago,
		asoc.MexFolioFiscal AS MexFolioFiscal,
		CAST(com.FECHA AS datetime) AS Fecha,
		f.ClaveProdServ AS ClaveProdServ,
		f.Descripcion AS Descripcion,
		CAST(f.Importe AS decimal) AS Importe,		
		CAST(f.ImpuestoValorAgregado AS decimal) AS ImpuestoValorAgregado,
		NULL ImpuestoRetenciones,					 	
		CAST(f.Importe AS decimal) + CAST(f.ImpuestoValorAgregado AS decimal) AS ImporteTotal,
		CASE WHEN f.Moneda <> 'MXN' THEN CAST(f.Importe AS decimal) * CAST(f.TaseDeCambio AS decimal) END AS ImporteMXN,
		CASE WHEN f.Moneda <> 'MXN' THEN CAST(f.ImpuestoValorAgregado AS decimal) * CAST(f.TaseDeCambio AS decimal) END AS ImpuestoValorAgregadoMXN,
		NULL ImpuestoRetencionesMXN, 		
		CASE WHEN f.Moneda <> 'MXN' THEN (CAST(f.Importe AS decimal) + CAST(f.ImpuestoValorAgregado AS decimal))* CAST(f.TaseDeCambio AS decimal) END AS ImporteTotalMXN,
		CAST(com.TOTAL AS decimal) AS Total,
		CASE WHEN f.Moneda <> 'MXN' THEN CAST(com.TOTAL AS decimal) * CAST(f.TaseDeCambio AS decimal) END AS TotalMXN,
		f.TasaCuota AS TasaCuota,
		CASE WHEN f.Moneda <> 'MXN' THEN CAST(f.TasaCuota AS decimal) * CAST(f.TaseDeCambio AS decimal) END AS TasaCuotaMXN,
		com.METODOPAGO AS MetodoPagoFact,
		NULL NumParcialidad,
		NULL IdDocumento,		
		NULL FechaDR,
		NULL MetodoDePagoDR,
		CASE WHEN f.Moneda <>'MXN' THEN CAST(f.TaseDeCambio AS decimal) END AS TasaDeCambio,
 		NULL ImpSaldoAnt,
		NULL ImpSaldoAntMXN,
		NULL ImpPagado,
		NULL ImpPagadoMXN,
		NULL ImpSaldoInsoluto,
		NULL ImpSaldoInsolutoMXN,
		f.UsoCFDI AS USOcfdi,
		NULL NombreInstitucionFinanciera,		
		Null MonedaDelPago,
		Null FechaDelPago,
		Null Monto,
		NULL MontoMXN,
		NULL FechaDePublicacion	
		FROM dbo.vwPmTransaccionesTodas a
		LEFT JOIN dbo.ACA_IETU00400 asoc ON a.VCHRNMBR = asoc.VCHRNMBR
		LEFT JOIN dace.ComprobanteCFDI com on asoc.MexFolioFiscal = com.UUID
		OUTER APPLY dbo.fCfdiDatosFacturasXmlCompras(archivoXML) f
		WHERE TIPOCOMPROBANTE = 'I'
		)
UNION ALL
(
SELECT  a.VENDORID,
		a.VENDNAME AS Vendedor,
		a.txrgnnum AS NumeroCont,
		a.TRXDSCRN AS ReferenciaDePago,
		asoc.MexFolioFiscal AS MexFolioFiscal,
		CAST(com.FECHA AS datetime) AS Fecha,	
		p.ClaveProdServ AS ClaveProdServ,
		p.Descripcion AS Descripcion,
		CAST(p.Importe AS decimal) As Importe,
		NULL ImpuestoValorAgregado,
		NULL ImpuestoRetenciones,	
		NULL ImporteTotal,	
		CASE WHEN p.MonedaDelPago <> 'MXN' THEN CAST(p.Importe AS decimal) * CAST(p.TasaDeCambio AS decimal) END AS ImporteMXN,		
		NULL ImpuestoValorAgregadoMXN,	
		NULL ImpuestoRetencionesMXN,
		NULL ImporteTotalMXN,		
		com.TOTAL AS Total,
		CASE WHEN p.MonedaDelPago <> 'MXN' THEN CAST(com.TOTAL AS decimal) * CAST(p.TasaDeCambio AS decimal) END AS TotalMXN,
		Null TasaCuota,
		Null TasaCuotaMXN,
		com.METODOPAGO AS MetodoPago,
		p.NumParcialidad AS NumeroParcialidad,		
		p.IdDocumento AS IdDocumento,		
		CAST((Select FECHA from dace.ComprobanteCFDI where UUID = IdDocumento) AS datetime) AS FechaDR,	
		p.MetodoDePagoDR AS MetodoDePagoDR,	
		CASE WHEN p.MonedaDelPago <>'MXN' THEN CAST(p.TasaDeCambio as decimal) END AS TasaDeCambio,
		CAST(p.ImpSaldoAnt AS DECIMAL) AS ImpSaldoAnt,	
		CASE WHEN p.MonedaDelPago <> 'MXN' THEN CAST(p.ImpSaldoAnt AS decimal) * CAST(p.TasaDeCambio AS decimal) END AS ImpSaldoAntMXN,
		CAST(p.ImpPagado AS DECIMAL) AS ImpPagado,
		CASE WHEN p.MonedaDelPago <> 'MXN' THEN CAST(p.ImpPagado AS decimal) * CAST(p.TasaDeCambio AS decimal) END AS ImpPagadoMXN,
		CAST(p.ImpSaldoInsoluto AS decimal) AS ImpSaldoInsoluto,
		CASE WHEN p.MonedaDelPago <> 'MXN' THEN CAST(p.ImpSaldoInsoluto AS decimal) * CAST(p.TasaDeCambio AS decimal) END AS ImpSaldoInsolutoMXN,
		p.UsoCFDI AS UsoCFDI,
		NULL NombreInstitucionFinanciera,
		p.MonedaDelPago AS MonedaDelPago,
		CAST(p.FechaDelPago AS datetime) AS FechaDePago,
		CAST(p.Monto AS DECIMAL)AS Monto,		
		CASE WHEN p.MonedaDelPago <> 'MXN' THEN CAST(p.Monto AS decimal) * CAST(p.TasaDeCambio AS decimal) END AS MontoMXN,
		NULL FechaDePublicacion
		FROM dbo.vwPmTransaccionesTodas a
		LEFT JOIN dbo.ACA_IETU00400 asoc ON a.VCHRNMBR = asoc.VCHRNMBR
		LEFT JOIN dace.ComprobanteCFDI com on asoc.MexFolioFiscal = com.UUID
		OUTER APPLY dbo.fCfdiDatosPagosXmlCompras(archivoXML) p
		WHERE TIPOCOMPROBANTE = 'P'
)
GO