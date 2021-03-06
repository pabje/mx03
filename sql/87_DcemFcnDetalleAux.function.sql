
IF OBJECT_ID ('dbo.DcemFcnDetalleAux') IS NOT NULL
   DROP FUNCTION dbo.[DcemFcnDetalleAux]
GO

create function [dbo].[DcemFcnDetalleAux](@periodid SMALLINT, @year1 SMALLINT, @ACTINDX int)
returns xml 
as
--Prop�sito. Detalle
--02/2015 jmg Creaci�n
--09/04/15 jcf Cambia a group by debido a posible repetici�n
--29/01/18 jcf Cambia atributos para v1.3
--
begin
 declare @cncp xml;
   WITH XMLNAMESPACES
(
    'http://www.sat.gob.mx/esquemas/ContabilidadE/1_3/AuxiliarCtas' as "AuxiliarCtas"
)

 select @cncp = (
	select 
		cast(trxdate as date)				'@Fecha',
		jrnentry							'@NumUnIdenPol',
		dbo.DcemFcnReplace(rtrim(refrence))	'@Concepto',
		sum(cast(DEBITAMT as numeric(19,2)))'@Debe',
		sum(cast(CRDTAMNT as numeric(19,2)))'@Haber'
	from dbo.dcemvwtransaccion 
	where YEAR(trxdate) = @year1
	  and month(trxdate) = @periodid
	  and actindx = @ACTINDX
	 group by cast(trxdate as date), JRNENTRY, refrence
	FOR XML path('AuxiliarCtas:DetalleAux'), type
)
 return @cncp
end
go

IF (@@Error = 0) PRINT 'Creaci�n exitosa de la funci�n: DcemFcnDetalleAux()'
ELSE PRINT 'Error en la creaci�n de la funci�n: DcemFcnDetalleAux()'
GO