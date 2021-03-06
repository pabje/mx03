
IF OBJECT_ID ('dbo.DcemFcnAuxiliarCtas') IS NOT NULL
   DROP FUNCTION dbo.[DcemFcnAuxiliarCtas]
GO

create function [dbo].[DcemFcnAuxiliarCtas](@periodid SMALLINT, @year1 SMALLINT)
returns xml 
as
--Prop�sito. Nodo auxiliar de cuentas
--02/2015 jmg Creaci�n
--09/04/15 jcf Replanteo de consulta
--29/01/18 jcf Cambia atributos para v1.3
--
begin
 declare @cncp xml;
 WITH XMLNAMESPACES
(
    'http://www.w3.org/2001/XMLSchema-instance' as "xsi",
    'http://www.sat.gob.mx/esquemas/ContabilidadE/1_3/AuxiliarCtas' as "AuxiliarCtas"
)
 --
 select @cncp = (
	SELECT
		'http://www.sat.gob.mx/esquemas/ContabilidadE/1_3/AuxiliarCtas http://www.sat.gob.mx/esquemas/ContabilidadE/1_3/AuxiliarCtas/AuxiliarCtas_1_3.xsd' '@xsi:schemaLocation',
		'1.3'												'@Version',
		 ltrim(rtrim( replace(cia.TAXREGTN, 'RFC ', '' )))	'@RFC',
		 right( '00' + cast( @periodid AS varchar(2)), 2 )	'@Mes',
		 dbo.DcemFcnReplace(@YEAR1)							'@Anio',
		'AF'												'@TipoSolicitud',
		dbo.dcemfcnctasblz(@periodid, @YEAR1)
	FROM DYNAMICS..SY01500 cia
	where cia.INTERID = DB_NAME()
	FOR XML path('AuxiliarCtas:AuxiliarCtas'), type
)
 return @cncp
end
go

IF (@@Error = 0) PRINT 'Creaci�n exitosa de la funci�n: [DcemFcnAuxiliarCtas]()'
ELSE PRINT 'Error en la creaci�n de la funci�n: [DcemFcnAuxiliarCtas]()'
GO
