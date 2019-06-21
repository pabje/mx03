IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].vwPmTransaccionesContabYSusAplicaciones'))
DROP VIEW [dbo].vwPmTransaccionesContabYSusAplicaciones
GO


--Propósito. Muestra todas las transacciones PM contabilizadas y sus respectivos comprobantes aplicados
--26/04/19 jcf Creación
--
create VIEW [dbo].vwPmTransaccionesContabYSusAplicaciones
AS
                          SELECT   o.VCHRNMBR, o.VENDORID, o.DOCTYPE, o.DOCDATE, o.DOCNUMBR, o.DOCAMNT, o.CURTRXAM, o.TRXDSCRN, o.VOIDED, o.CURNCYID, 
                                    'OPEN' AS ESTATUS, 
									CASE WHEN o.DOCTYPE > 3 then B.APTVCHNM 
										else B.VCHRNMBR 
										--WHEN 6 THEN B.APTVCHNM 
										--WHEN 1 THEN B.VCHRNMBR 
									END AS DocAplic, 
                                    CASE WHEN o.DOCTYPE > 3 then B.APTODCTY 
										else B.DOCTYPE 
										--WHEN 6 THEN B.APTODCTY 
										--WHEN 1 THEN B.DOCTYPE 
									END AS DocTipoAplic
                            FROM    dbo.PM20000 AS o 
									LEFT OUTER JOIN dbo.PM20100 AS B 
									ON CASE WHEN o.DOCTYPE > 3 then B.DOCTYPE
										else B.APTODCTY
											--WHEN 6 THEN B.DOCTYPE 
											--WHEN 1 THEN B.APTODCTY 
										END = o.DOCTYPE 
									AND CASE WHEN o.DOCTYPE > 3 then B.VCHRNMBR 
										else B.APTVCHNM 
											--WHEN 6 THEN B.VCHRNMBR 
											--WHEN 1 THEN B.APTVCHNM 
										END = o.VCHRNMBR
                            UNION all
                            SELECT  o.VCHRNMBR, o.VENDORID, o.DOCTYPE, o.DOCDATE, o.DOCNUMBR, o.DOCAMNT, o.CURTRXAM, o.TRXDSCRN, o.VOIDED, o.CURNCYID, 
                                    'HIST' AS ESTATUS, 
									CASE WHEN o.DOCTYPE > 3 then B.APTVCHNM 
										else B.VCHRNMBR 
										--WHEN 6 THEN B.APTVCHNM 
										--WHEN 1 THEN B.VCHRNMBR 
									END AS Expr1, 
                                    CASE WHEN o.DOCTYPE > 3 then B.APTODCTY 
										else B.DOCTYPE 
										--WHEN 6 THEN B.APTODCTY 
										--WHEN 1 THEN B.DOCTYPE 
									END AS Expr2
                            FROM    dbo.PM30200 AS o 
									LEFT OUTER JOIN dbo.PM30300 AS B 
									ON CASE WHEN o.DOCTYPE > 3 then B.DOCTYPE 
										else B.APTODCTY 
										--WHEN 6 THEN B.DOCTYPE 
										--WHEN 1 THEN B.APTODCTY 
									END = o.DOCTYPE 
									AND CASE WHEN o.DOCTYPE > 3 then B.VCHRNMBR 
										else B.APTVCHNM 
										--WHEN 6 THEN B.VCHRNMBR 
										--WHEN 1 THEN B.APTVCHNM 
									END = o.VCHRNMBR
go