IF OBJECT_ID ('dbo.DcemFcnBalance') IS NOT NULL
   DROP FUNCTION dbo.[DcemFcnBalance]
GO

create function [dbo].[DcemFcnBalance](@periodid SMALLINT, @year1 SMALLINT)
returns xml 
as
--Prop�sito. Balance de cuentas para el SAT
--12/2014 jmg Creaci�n
--07/04/15 jcf Correcci�n de llamada a dcemfcnctas y replanteo de consulta
--25/01/18 jcf Modificaciones para versi�n 1.3
--
begin
 declare @cncp xml;
  --
 WITH XMLNAMESPACES
(
    'http://www.w3.org/2001/XMLSchema-instance' as "xsi",
    'http://www.sat.gob.mx/esquemas/ContabilidadE/1_3/BalanzaComprobacion' as "BCE"
)
 --
  select @cncp = (
 
	SELECT
		'http://www.sat.gob.mx/esquemas/ContabilidadE/1_3/BalanzaComprobacion http://www.sat.gob.mx/esquemas/ContabilidadE/1_3/BalanzaComprobacion/BalanzaComprobacion_1_3.xsd' as '@xsi:schemaLocation',
		'1.3'												'@Version',
		ltrim(rtrim(replace(cia.TAXREGTN, 'RFC ', '')))		'@RFC',
		right( '00' + cast( @periodid AS varchar(2)), 2 )	'@Mes',
		@YEAR1 												'@Anio',
		'N'													'@TipoEnvio',
		dbo.dcemfcnctas(@periodid, @YEAR1)
	FROM DYNAMICS..SY01500 cia
	where cia.INTERID = DB_NAME()
	FOR XML path('BCE:Balanza'), type
)
 return @cncp
end

go

IF (@@Error = 0) PRINT 'Creaci�n exitosa de la funci�n: DcemFcnBalance()'
ELSE PRINT 'Error en la creaci�n de la funci�n: DcemFcnBalance()'
GO

