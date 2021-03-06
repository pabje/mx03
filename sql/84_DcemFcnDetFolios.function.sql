IF OBJECT_ID ('dbo.DcemFcnDetFolios') IS NOT NULL
   DROP FUNCTION dbo.[DcemFcnDetFolios]
GO

create function [dbo].[DcemFcnDetFolios](@year1 SMALLINT, @periodid SMALLINT)
returns xml 
--Prop�sito. Nodo Detalle auxiliar de folios
--02/2015 jmg Creaci�n
--08/04/15 jcf Ajuste de llamada a funciones
--29/01/18 jcf Cambia atributos para v1.3
--
as
begin
 declare @cncp xml;
 WITH XMLNAMESPACES
(
    'http://www.sat.gob.mx/esquemas/ContabilidadE/1_3/AuxiliarFolios' as "RepAux"    
)
select @cncp = 
(
	select 
		jrnentry				'@NumUnIdenPol',
		cast(trxdate as date)	'@Fecha',
		DBO.DcemFcnDocNacFolio(ORCTRNUM, ORTRXTYP, SOURCDOC, ORMSTRID, SERIES),
		DBO.DcemFcnDocExtFolio(ORCTRNUM, ORTRXTYP, SOURCDOC, SERIES)
	from dbo.dcemvwtransaccion
	where YEAR(trxdate) = @year1
	  and month(trxdate) = @periodid
	FOR XML path('RepAux:DetAuxFol'), type
)
 return @cncp
end

go
IF (@@Error = 0) PRINT 'Creaci�n exitosa de la funci�n: DcemFcnDetFolios()'
ELSE PRINT 'Error en la creaci�n de la funci�n: DcemFcnDetFolios()'
GO
