IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[daceFnValidaAplicacionCFDICompra]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [dbo].[daceFnValidaAplicacionCFDICompra]
GO

--Propósito. Valida si un pago está bien aplicado
--Atención. En caso de facturas PUE, debe haber un pago por factura o varios pagos aplicados a una factura. 
--			Pero no puede haber un pago aplicado a varias facturas porque no se sabría el folio fiscal del pago.
--05/02/19 jcf Creación
--26/04/19 jcf Agrega CfdiXml_Total, CfdiXml_Moneda y mejora las observaciones
--11/06/19 jcf Agrega validaciones.CfdiXml_Folio
--
CREATE FUNCTION [dbo].[daceFnValidaAplicacionCFDICompra](@CNTRLNUM char(21), @DOCTYPE smallint)  
RETURNS table
AS   
return(

SELECT validaciones.VCHRNMBR, validaciones.DOCTYPE, validaciones.VENDORID, validaciones.DOCDATE, validaciones.DOCNUMBR, validaciones.DOCAMNT, validaciones.CURNCYID, validaciones.TRXDSCRN, validaciones.UUID, 
	validaciones.CfdiXml_Folio, validaciones.CfdiXml_MetodoPago, validaciones.CfdiXml_Moneda, validaciones.CfdiXml_Total,
	case when min(validaciones.OBSERVACIONES) = max(validaciones.OBSERVACIONES) 
			and min(validaciones.OBSERVACIONES) not like 'Error%' 
			and max(validaciones.OBSERVACIONES) not like 'Error%' then 
			'OK' 
		else min(validaciones.OBSERVACIONES)
	end observaciones,
	count(*) numComprobantesAplicados
FROM (
	SELECT a.VCHRNMBR, a.DOCTYPE, a.VENDORID, a.DOCDATE, a.DOCNUMBR, a.DOCAMNT, a.CURNCYID, a.TRXDSCRN, a.DocAplic, a.DocTipoAplic, aplicado.MexFolioFiscal, 
			CASE a.DOCTYPE 
				WHEN 6 THEN 
					CASE WHEN cfdiDelAplicado.METODOPAGO = 'PUE' AND isnull(asoc.MexFolioFiscal, '') = '' THEN 
							aplicado.MexFolioFiscal
						ELSE 
							asoc.MexFolioFiscal
					END 
				ELSE 
					asoc.MexFolioFiscal
			END AS UUID, 
			isnull(CFDI.FOLIO, '')			CfdiXml_Folio,
			isnull(CFDI.MONEDA, '')			CfdiXml_Moneda,
			isnull(CFDI.TOTAL, 0)			CfdiXml_Total,
			ISNULL(CFDI.METODOPAGO, '')		CfdiXml_MetodoPago, 
			CASE WHEN ISNULL(CFDI.METODOPAGO, '') = 'PUE' OR cfdiDelAplicado.METODOPAGO = 'PUE' THEN 
					CASE WHEN a.DOCTYPE = 1 AND ISNULL(aplicado.MexFolioFiscal, '') = '' AND a.DocAplic IS NOT NULL THEN 
							'OK' 
						ELSE 
							CASE WHEN a.DOCTYPE = 6 AND ISNULL(asoc.MexFolioFiscal, '') = '' THEN 
									'OK '
								ELSE 'Error de documento PUE: No es factura ni pago; o el pago tiene asociado un folio fiscal; o la factura no está aplicada.'
							END 
					END 
				ELSE 
					CASE WHEN uuidRelacionadosAlPago.numFolios > 0 THEN 
							'OK' 
						ELSE 'Error de documento PPD: Las facturas aplicadas en el cfdi xml no correspon a las aplicaciones en GP.'
					END 
			END AS OBSERVACIONES
	FROM    dbo.vwPmTransaccionesContabYSusAplicaciones a
			LEFT OUTER JOIN  dbo.ACA_IETU00400 AS asoc 
				ON asoc.DOCTYPE = a.DOCTYPE 
				AND asoc.VCHRNMBR = a.VCHRNMBR 
			LEFT OUTER JOIN dbo.ACA_IETU00400 AS aplicado 
				ON aplicado.DOCTYPE = a.DocTipoAplic 
				AND aplicado.VCHRNMBR = a.DocAplic 
			LEFT OUTER JOIN dace.ComprobanteCFDI AS CFDI 
				ON CFDI.TIPOCOMPROBANTE = CASE a.DOCTYPE WHEN 6 THEN 'P' WHEN 1 THEN 'I' END 
				AND CFDI.UUID = asoc.MexFolioFiscal 
			LEFT OUTER JOIN dace.ComprobanteCFDI AS cfdiDelAplicado 
				ON cfdiDelAplicado.TIPOCOMPROBANTE = CASE a.DOCTYPE WHEN 6 THEN 'I' END 
				AND cfdiDelAplicado.UUID = aplicado.MexFolioFiscal
			outer apply (select count(*) numFolios
						from dace.ComprobanteCFDIRelacionado rel
						where rel.CFDI_UUID = CASE a.DOCTYPE WHEN 1 THEN aplicado.MexFolioFiscal
															WHEN 6 THEN asoc.MexFolioFiscal 
												END
						and rel.UUIDRELACIONADO = CASE a.DOCTYPE WHEN 1 THEN asoc.MexFolioFiscal 
																WHEN 6 THEN aplicado.MexFolioFiscal 
												END
						) uuidRelacionadosAlPago
	where 
	a.DOCTYPE = @DOCTYPE and 
	a.VCHRNMBR = @CNTRLNUM 
	--a.VOIDED = 0
	) validaciones
GROUP BY validaciones.VCHRNMBR, validaciones.DOCTYPE, validaciones.VENDORID, validaciones.DOCDATE, validaciones.DOCNUMBR, validaciones.DOCAMNT, validaciones.CURNCYID, validaciones.TRXDSCRN, validaciones.UUID, 
	validaciones.CfdiXml_Folio, validaciones.CfdiXml_MetodoPago, validaciones.CfdiXml_Moneda, validaciones.CfdiXml_Total
)
-------------------------------------------

--GRANT  execute  ON [dbo].[daceFnValidaAplicacionCFDICompra]  TO [DYNGRP] 
--GO 

