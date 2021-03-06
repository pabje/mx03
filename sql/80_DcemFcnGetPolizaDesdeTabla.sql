	-------------------------------------------------------------------------------------------------
IF OBJECT_ID ('dbo.DcemFcnGetPolizaDesdeTabla') IS NOT NULL
   DROP FUNCTION dbo.[DcemFcnGetPolizaDesdeTabla]
GO

create function [dbo].[DcemFcnGetPolizaDesdeTabla](@year1 SMALLINT, @periodid SMALLINT)
returns xml 
as
--Prop�sito. P�liza
--Requisito. Las p�lizas deben estar en una tabla
--14/6/17 jcf Creaci�n
--
begin
 declare @cncp xml;
  WITH XMLNAMESPACES
(
    'http://www.sat.gob.mx/esquemas/ContabilidadE/1_3/PolizasPeriodo' as "PLZ"
)

 select @cncp = (
	 select 
		jrnentry							'@NumUnIdenPol',
		cast(trxdate as date)				'@Fecha',
		dbo.DcemFcnReplace(rtrim(refrence)) '@Concepto',
		nodoTransaccion.query('.')
	from dcem.dcemPoliza
	where YEAR(trxdate) = @year1
	  and month(trxdate) = @periodid
FOR XML path('PLZ:Poliza'), type
)
 return @cncp
end
go
IF (@@Error = 0) PRINT 'Creaci�n exitosa de la funci�n: [DcemFcnGetPolizaDesdeTabla]()'
ELSE PRINT 'Error en la creaci�n de la funci�n: [DcemFcnGetPolizaDesdeTabla]()'
GO
--------------------------------------------------------------------
--test
--select dbo.DcemFcnGetPolizaDesdeTabla(2017, 1)
