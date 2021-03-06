-------------------------------------------------------------------------------------------------
IF OBJECT_ID ('dbo.DcemFcnDocNacFolio') IS NOT NULL
   DROP FUNCTION dbo.DcemFcnDocNacFolio
GO

create function [dbo].[DcemFcnDocNacFolio]
(
@ORCTRNUM  varchar(21), 
@ORTRXTYP  smallint, 
@SOURCDOC  VARCHAR(11),
@ORMSTRID  varchar(31),
@SERIES    smallint
)
returns xml 
as
--Prop�sito. Facturas y pagos Nacionales
--02/2015 jmg Creaci�n
--07/04/15 jcf Replanteo de consulta. Correcci�n de par�metros.
--29/01/18 jcf Cambia atributos para v1.3
--	
begin
declare @cncp xml;
WITH XMLNAMESPACES
  (    'http://www.sat.gob.mx/esquemas/ContabilidadE/1_3/AuxiliarFolios' as "RepAux"    )
select @cncp = 
(
		select 
			rtrim(left(docu.MexFolioFiscal, 36)) '@UUID_CFDI',
			cast(docu.docamnt as numeric(16,2))  '@MontoTotal',
			dbo.DcemFcnReplace(docu.txrgnnum)    '@RFC',
			rtrim(docu.codMetodoPago)			'@MetPagoAux',
			rtrim(docu.ISOCURRC)				 '@Moneda',
			cast(docu.xchgrate as numeric(19,5)) '@TipCamb'
		from dbo.dcemFnGetDocumentoOriginal(@ORCTRNUM, @ORTRXTYP, @SOURCDOC) docu
		WHERE upper(docu.ccode) in ('MEX', 'MX', '')
			AND @SERIES in (3, 4)
			and docu.MexFolioFiscal is not null
		FOR XML path('RepAux:ComprNal'), type
)
 return @cncp
end
go


IF (@@Error = 0) PRINT 'Creaci�n exitosa de la funci�n: DcemFcnDocNacFolio()'
ELSE PRINT 'Error en la creaci�n de la funci�n: DcemFcnDocNacFolio()'
GO

