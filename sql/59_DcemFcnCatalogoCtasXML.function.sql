
IF OBJECT_ID ('dbo.DcemFcnCatalogoCtasXML') IS NOT NULL
   DROP FUNCTION dbo.[DcemFcnCatalogoCtasXML]
GO

create function [dbo].[DcemFcnCatalogoCtasXML]()
returns xml 
as
--Prop�sito. Catalogo de cuentas, corporativas y SAT
--12/2014 jmg Creaci�n
--7/4/15 jcf Corrige llamada a funci�n DcemFcnReplace
--
begin
 declare @cncp xml;
 
 WITH XMLNAMESPACES
(
    'http://www.sat.gob.mx/esquemas/ContabilidadE/1_3/CatalogoCuentas' as "catalogocuentas"
)

 select @cncp = (
  SELECT 
		dbo.DcemFcnReplace(ltrim(rtrim(A.USERDEF1)))        '@CodAgrup',
		left(ltrim(rtrim(B.ACTNUMST)), 100)					'@NumCta',
		dbo.DcemFcnReplace(ltrim(rtrim(A.ACTDESCR)))		'@Desc',
		'2'          '@Nivel',
     CASE TPCLBLNC
      WHEN '0' THEN 'D'
      WHEN '1' THEN 'A'
     END          '@Natur'
    FROM GL00100 A, 
         GL00105 B
   WHERE A.ACTINDX = B.ACTINDX
   and A.USERDEF1 <> ''
  FOR XML path('catalogocuentas:Ctas'), type
  )
 return @cncp
end


go
IF (@@Error = 0) PRINT 'Creaci�n exitosa de la funci�n: DcemFcnCatalogoCtasXML()'
ELSE PRINT 'Error en la creaci�n de la funci�n: DcemFcnCatalogoCtasXML()'
GO
