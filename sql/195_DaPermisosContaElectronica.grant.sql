--M�xico 
--Contabilidad Electr�nica
--Prop�sito. Rol que da accesos a objetos de contabilidad electr�nica
--Requisitos. Ejecutar en la compa��a.
--15/1/15 JCF Creaci�n
--
-----------------------------------------------------------------------------------
--use mtp1

IF DATABASE_PRINCIPAL_ID('rol_contaelectr') IS NULL
	create role rol_contaelectr;

--Objetos que usa contabilidad electr�nica
grant execute on dbo.DcemFcnCatalogoXML to rol_contaelectr;
grant execute on dbo.DcemFcnBalance to rol_contaelectr;
grant execute on dbo.DcemFcnPolizas to rol_contaelectr;
grant execute on dbo.DCEMFCNAUXILIARFOLIOS to rol_contaelectr;
grant execute on dbo.DCEMFCNAUXILIARCTAS to rol_contaelectr;
--grant execute on dcem.dcemCorrigePoliza to rol_contaelectr;  --es el owner
grant select on dbo.DcemVwContabilidad to rol_contaelectr;
grant select on dbo.vwPopPmDocumentosDeCompraLoteAbieHist to rol_contaelectr;
grant execute on [dbo].[DcemFcnTransaccion] to rol_contaelectr;

grant select, update, insert on dbo.pm00200 to rol_contaelectr;
grant select, update, insert on dbo.pm10000 to rol_contaelectr;
grant select, update, insert on dbo.pm10500 to rol_contaelectr;
grant select, update, insert on dbo.pm10100 to rol_contaelectr;
grant select on dbo.pm20000 to rol_contaelectr;
grant select on dbo.pm30200 to rol_contaelectr;
grant select, update, insert on ACA_IETU00400 to rol_contaelectr;
grant select, update, insert on dbo.pop10300 to rol_contaelectr;
grant execute on dcem.dcemMarcarPolizasConError to rol_contaelectr;
grant execute on dcem.dcemCorrigePoliza to rol_contaelectr;

grant execute on dace.spComprobanteCFDIInsDel to rol_contaelectr;
GRANT  SELECT ON [dbo].[vw_dace_smartlist1] TO rol_contaelectr;
GRANT  SELECT ON dace.vwComprobanteCFDI to rol_contaelectr;

----------------------------------------------------------------------------
use dynamics;
IF DATABASE_PRINCIPAL_ID('rol_contaelectr') IS NULL
	create role rol_contaelectr;

grant select on SY01500 to dyngrp, rol_contaelectr;
grant select on mc40200 to dyngrp, rol_contaelectr;



