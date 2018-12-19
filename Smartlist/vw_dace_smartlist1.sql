

/****** Object:  View [dbo].[vw_dace_smartlist1]    Script Date: 12/06/2018 18:01:37 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_dace_smartlist1]'))
DROP VIEW [dbo].[vw_dace_smartlist1]
GO


/****** Object:  View [dbo].[vw_dace_smartlist1]    Script Date: 12/06/2018 18:01:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_dace_smartlist1]
AS
SELECT     m.CNTRLTYP, m.DOCTYPE, m.CNTRLNUM, m.DOCNUMBR, m.DOCDATE, m.VENDORID, a.DOCAMNT, a.CURNCYID, a.TRXDSCRN, 
                      CASE m.DOCTYPE WHEN 6 THEN CASE WHEN MAX(CFDIA.METODOPAGO) = 'PUE' AND MAX(isnull(asoc.MexFolioFiscal, '')) = '' THEN MAX(APLICADO.MexFolioFiscal) 
                      ELSE MAX(asoc.MexFolioFiscal) END ELSE MAX(asoc.MexFolioFiscal) END AS CFDI_ASOC, CASE m.DOCTYPE WHEN 1 THEN CASE WHEN (CFDI.METODOPAGO) 
                      = 'PUE' THEN MAX(asoc.MexFolioFiscal) ELSE MAX(aplicado.MexFolioFiscal) END WHEN 6 THEN CASE WHEN (CFDIa.METODOPAGO) 
                      = 'PUE' THEN MAX(aplicado.MexFolioFiscal) ELSE MAX(aplicado.MexFolioFiscal) END END AS CFDI_Apli, ISNULL(CFDI.METODOPAGO, '') AS MetodoPago, 
                      CFDIA.METODOPAGO AS cfdia_metodopago, CASE WHEN CFDI.METODOPAGO = 'PUE' OR
                      CFDIA.METODOPAGO = 'PUE' THEN CASE WHEN m.DOCTYPE = 1 AND ISNULL(MAX(aplicado.MexFolioFiscal), '') = '' AND MAX(a.DocAplic) IS NOT NULL 
                      THEN 'CFDI SE APLICO OK' ELSE CASE WHEN m.DOCTYPE = 6 AND ISNULL(MAX(asoc.MexFolioFiscal), '') 
                      = '' THEN 'CFDI SE APLICO OK' ELSE 'CFDI SE APLICO ERRADO' END END ELSE CASE WHEN MIN(dbo.fun_DACE_ValidarAplica(CASE m.DOCTYPE WHEN 1 THEN aplicado.MexFolioFiscal
                       WHEN 6 THEN asoc.MexFolioFiscal END, CASE m.DOCTYPE WHEN 1 THEN asoc.MexFolioFiscal WHEN 6 THEN aplicado.MexFolioFiscal END)) 
                      > 0 THEN 'CFDI SE APLICO OK' ELSE 'CFDI SE APLICO ERRADO' END END AS OBSERVACIONES, m.DCSTATUS
FROM         dbo.PM00400 AS m LEFT OUTER JOIN
                          (SELECT     o.VCHRNMBR, o.VENDORID, o.DOCTYPE, o.DOCDATE, o.DOCNUMBR, o.DOCAMNT, o.CURTRXAM, o.TRXDSCRN, o.VOIDED, o.CURNCYID, 
                                                   'OPEN' AS ESTATUS, CASE o.DOCTYPE WHEN 6 THEN B.APTVCHNM WHEN 1 THEN B.VCHRNMBR END AS DocAplic, 
                                                   CASE o.DOCTYPE WHEN 6 THEN B.APTODCTY WHEN 1 THEN B.DOCTYPE END AS DocTipoAplic
                            FROM          dbo.PM20000 AS o LEFT OUTER JOIN
                                                   dbo.PM20100 AS B ON CASE o.DOCTYPE WHEN 6 THEN B.DOCTYPE WHEN 1 THEN B.APTODCTY END = o.DOCTYPE AND 
                                                   CASE o.DOCTYPE WHEN 6 THEN B.VCHRNMBR WHEN 1 THEN B.APTVCHNM END = o.VCHRNMBR
                            UNION
                            SELECT     o.VCHRNMBR, o.VENDORID, o.DOCTYPE, o.DOCDATE, o.DOCNUMBR, o.DOCAMNT, o.CURTRXAM, o.TRXDSCRN, o.VOIDED, o.CURNCYID, 
                                                  'HIST' AS ESTATUS, CASE o.DOCTYPE WHEN 6 THEN B.APTVCHNM WHEN 1 THEN B.VCHRNMBR END AS Expr1, 
                                                  CASE o.DOCTYPE WHEN 6 THEN B.APTODCTY WHEN 1 THEN B.DOCTYPE END AS Expr2
                            FROM         dbo.PM30200 AS o LEFT OUTER JOIN
                                                  dbo.PM30300 AS B ON CASE o.DOCTYPE WHEN 6 THEN B.DOCTYPE WHEN 1 THEN B.APTODCTY END = o.DOCTYPE AND 
                                                  CASE o.DOCTYPE WHEN 6 THEN B.VCHRNMBR WHEN 1 THEN B.APTVCHNM END = o.VCHRNMBR) AS a ON m.DOCTYPE = a.DOCTYPE AND 
                      m.CNTRLNUM = a.VCHRNMBR LEFT OUTER JOIN
                      dbo.ACA_IETU00400 AS asoc ON asoc.DOCTYPE = a.DOCTYPE AND asoc.VCHRNMBR = a.VCHRNMBR LEFT OUTER JOIN
                      dbo.ACA_IETU00400 AS aplicado ON aplicado.DOCTYPE = a.DocTipoAplic AND aplicado.VCHRNMBR = a.DocAplic LEFT OUTER JOIN
                      dace.ComprobanteCFDI AS CFDI ON CFDI.TIPOCOMPROBANTE = CASE M.DOCTYPE WHEN 6 THEN 'P' WHEN 1 THEN 'I' END AND 
                      CFDI.UUID = asoc.MexFolioFiscal LEFT OUTER JOIN
                      dace.ComprobanteCFDI AS CFDIA ON CFDIA.TIPOCOMPROBANTE = CASE M.DOCTYPE WHEN 6 THEN 'I' END AND CFDIA.UUID = aplicado.MexFolioFiscal
WHERE     (a.VOIDED = 0)
GROUP BY m.DOCTYPE, m.CNTRLNUM, m.DOCNUMBR, m.DOCDATE, m.VENDORID, a.DOCAMNT, a.CURNCYID, a.TRXDSCRN, asoc.MexFolioFiscal, CFDI.METODOPAGO, 
                      CFDIA.METODOPAGO, m.DCSTATUS, m.CNTRLTYP

GO

GRANT  SELECT ,  INSERT ,  DELETE ,  UPDATE  ON [dbo].[vw_dace_smartlist1] TO [DYNGRP] 
GO 
