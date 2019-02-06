/****** Object:  UserDefinedFunction [dbo].[daceFnValidaAplicacionCFDICompra]    Script Date: 11/28/2018 14:23:14 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[daceFnValidaAplicacionCFDICompra]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [dbo].[daceFnValidaAplicacionCFDICompra]
GO

/****** Object:  UserDefinedFunction [dbo].[daceFnValidaAplicacionCFDICompra]    Script Date: 11/28/2018 14:23:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--Propósito. Valida si un pago está bien aplicado
--Atención. En caso de facturas PUE, debe haber un pago por factura o varios pagos aplicados a una factura. 
--			Pero no puede haber un pago aplicado a varias facturas porque no se sabría el folio fiscal del pago.
--05/02/19 jcf Creación
--
CREATE FUNCTION [dbo].[daceFnValidaAplicacionCFDICompra](@CNTRLNUM char(21), @DOCTYPE smallint)  
RETURNS table
AS   
return(

SELECT validaciones.VCHRNMBR, validaciones.DOCTYPE, validaciones.VENDORID, validaciones.DOCDATE, validaciones.DOCNUMBR, validaciones.DOCAMNT, validaciones.CURNCYID, validaciones.TRXDSCRN, validaciones.CFDI_ASOC, validaciones.MetodoPago, 
	case when min(validaciones.OBSERVACIONES) = max(validaciones.OBSERVACIONES) and min(validaciones.OBSERVACIONES) not like 'Error%' and max(validaciones.OBSERVACIONES) not like 'Error%' then 'OK' else 'Aplicado inconsistente del CFDI' end observaciones,
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
			END AS CFDI_ASOC, 
			ISNULL(CFDI.METODOPAGO, '') AS MetodoPago, 
			CASE WHEN CFDI.METODOPAGO = 'PUE' OR cfdiDelAplicado.METODOPAGO = 'PUE' THEN 
					CASE WHEN a.DOCTYPE = 1 AND ISNULL(aplicado.MexFolioFiscal, '') = '' AND a.DocAplic IS NOT NULL THEN 
							'OK' 
						ELSE 
							CASE WHEN a.DOCTYPE = 6 AND ISNULL(asoc.MexFolioFiscal, '') = '' THEN 
									'OK ' + aplicado.MexFolioFiscal 
								ELSE 'Error de caso PUE'	--Documento PUE no es factura ni pago o pago tiene asociado un folio fiscal o factura no está aplicada
							END 
					END 
				ELSE 
					CASE WHEN uuidRelacionadosAlPago.numFolios > 0 THEN 
							'OK' 
						ELSE 'Error de caso PPD'			--Las facturas aplicadas en el cfdi no correspon a las aplicaciones en GP
					END 
			END AS OBSERVACIONES
	FROM         
                          (SELECT   o.VCHRNMBR, o.VENDORID, o.DOCTYPE, o.DOCDATE, o.DOCNUMBR, o.DOCAMNT, o.CURTRXAM, o.TRXDSCRN, o.VOIDED, o.CURNCYID, 
                                    'OPEN' AS ESTATUS, 
									CASE o.DOCTYPE 
										WHEN 6 THEN B.APTVCHNM 
										WHEN 1 THEN B.VCHRNMBR 
									END AS DocAplic, 
                                    CASE o.DOCTYPE 
										WHEN 6 THEN B.APTODCTY 
										WHEN 1 THEN B.DOCTYPE 
									END AS DocTipoAplic
                            FROM    dbo.PM20000 AS o 
									LEFT OUTER JOIN dbo.PM20100 AS B 
									ON CASE o.DOCTYPE 
											WHEN 6 THEN B.DOCTYPE 
											WHEN 1 THEN B.APTODCTY 
										END = o.DOCTYPE 
									AND CASE o.DOCTYPE 
											WHEN 6 THEN B.VCHRNMBR 
											WHEN 1 THEN B.APTVCHNM 
										END = o.VCHRNMBR
                            UNION
                            SELECT  o.VCHRNMBR, o.VENDORID, o.DOCTYPE, o.DOCDATE, o.DOCNUMBR, o.DOCAMNT, o.CURTRXAM, o.TRXDSCRN, o.VOIDED, o.CURNCYID, 
                                    'HIST' AS ESTATUS, 
									CASE o.DOCTYPE 
										WHEN 6 THEN B.APTVCHNM 
										WHEN 1 THEN B.VCHRNMBR 
									END AS Expr1, 
                                    CASE o.DOCTYPE 
										WHEN 6 THEN B.APTODCTY 
										WHEN 1 THEN B.DOCTYPE 
									END AS Expr2
                            FROM    dbo.PM30200 AS o 
									LEFT OUTER JOIN dbo.PM30300 AS B 
									ON CASE o.DOCTYPE 
										WHEN 6 THEN B.DOCTYPE 
										WHEN 1 THEN B.APTODCTY 
									END = o.DOCTYPE 
									AND CASE o.DOCTYPE 
										WHEN 6 THEN B.VCHRNMBR 
										WHEN 1 THEN B.APTVCHNM 
									END = o.VCHRNMBR
							) AS a
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
	a.VCHRNMBR = @CNTRLNUM and
	a.VOIDED = 0
	) validaciones
GROUP BY validaciones.VCHRNMBR, validaciones.DOCTYPE, validaciones.VENDORID, validaciones.DOCDATE, validaciones.DOCNUMBR, validaciones.DOCAMNT, validaciones.CURNCYID, validaciones.TRXDSCRN, validaciones.CFDI_ASOC, validaciones.MetodoPago
)
-------------------------------------------

--GRANT  execute  ON [dbo].[daceFnValidaAplicacionCFDICompra]  TO [DYNGRP] 
--GO 

