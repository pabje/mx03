IF OBJECT_ID ('dbo.DcemFcnTransaccion') IS NOT NULL
   DROP FUNCTION dbo.DcemFcnTransaccion
GO

create function [dbo].[DcemFcnTransaccion](@year1 SMALLINT, @periodid SMALLINT, @cuenta INTEGER, @JRNENTRY INTEGER, @trxdate datetime)
returns xml 
as
--Prop�sito. Obtiene nodo Transaccion
--12/2014 jmg Creaci�n
--08/04/15 jcf Modifica par�metros de funciones
--13/06/17 jcf Corrige filtro. No es necesario @cuenta ni @dex_row_id
--
begin
 declare @cncp xml;
  WITH XMLNAMESPACES
(
    'http://www.sat.gob.mx/esquemas/ContabilidadE/1_3/PolizasPeriodo' as "PLZ"
)

 select @cncp = (
	 SELECT
		left(rtrim(VW.actnumst), 100)          '@NumCta',
		dbo.DcemFcnReplace(rtrim(VW.actdescr)) '@DesCta',
		case when VW.DSCRIPTN = '' then '-' else dbo.DcemFcnReplace(rtrim(VW.DSCRIPTN)) end '@Concepto',
		cast(VW.DEBITAMT as numeric(16,2))    '@Debe',
		cast(VW.CRDTAMNT as numeric(16,2))    '@Haber',
		DBO.DcemFcnDocNac(ORCTRNUM, ORTRXTYP, SOURCDOC, ORMSTRID, SERIES),
		dbo.DcemFcnDocExt(ORCTRNUM, ORTRXTYP, SOURCDOC, SERIES),
		DBO.DcemFcnCheque(ORCTRNUM, ORTRXTYP, SOURCDOC),
		DBO.DcemFcnTransferencia(ORCTRNUM, ORTRXTYP, SOURCDOC),
		DBO.DcemFcnOtro(ORCTRNUM, ORTRXTYP, SOURCDOC)
	from dbo.dcemvwtransaccion VW
	where --VW.ACTINDX        = @cuenta
	  VW.JRNENTRY    = @JRNENTRY
	  and VW.trxdate = @trxdate
	  --AND VW.dex_row_id     = @dex_row_id  
FOR XML path('PLZ:Transaccion'), type
)
 return @cncp
end
go
IF (@@Error = 0) PRINT 'Creaci�n exitosa de la funci�n: DcemFcnTransaccion()'
ELSE PRINT 'Error en la creaci�n de la funci�n: DcemFcnTransaccion()'
GO
