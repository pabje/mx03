IF OBJECT_ID ('dbo.DcemFcnCheque') IS NOT NULL
   DROP FUNCTION dbo.[DcemFcnCheque]
GO

create function [dbo].[DcemFcnCheque](@ORCTRNUM varchar(21), @ORTRXTYP smallint, @SOURCDOC VARCHAR(11))
returns xml 
as
--Prop�sito. Cheque
--12/2014 jmg Creaci�n
--07/04/15 jcf Corrige docdate y agrega tipo de documento a filtro 
--22/04/15 jcf SAT v2 no requiere cobros en p�liza
--25/01/18 jcf Agrega Cobros
--
begin
 declare @cncp xml;
  WITH XMLNAMESPACES
(
    'http://www.sat.gob.mx/esquemas/ContabilidadE/1_3/PolizasPeriodo' as "PLZ"
)
 select @cncp = (
		select 
			   dbo.DcemFcnReplace(rtrim(docnumbr))       '@Num',
			   dbo.DcemFcnReplace(rtrim(bancoOrigenSat))  '@BanEmisNal',
			   dbo.DcemFcnReplace(rtrim(banOriExt))       '@BanEmisExt',       
			   dbo.DcemFcnReplace(rtrim(ctaorigensat))    '@CtaOri',
			   cast(docdate as date)					'@Fecha',
			   dbo.DcemFcnReplace(rtrim(beneficiariosat)) '@Benef',
			   dbo.DcemFcnReplace(rtrim(txrgnnum))        '@RFC',
			   cast(docamnt as numeric(16,2))             '@Monto',
			   dbo.DcemFcnReplace(rtrim(ISOCURRC))        '@Moneda',
			   cast(xchgrate as numeric(19,5))            '@TipCamb'
		  from dbo.dcemFnGetDocumentoOriginal(@ORCTRNUM, @ORTRXTYP, @SOURCDOC)
		where codMetodoPago = '02'
		and voided = 0
		and (
			(@SOURCDOC in ('PMPAY', 'PMCHK', 'PMTRX')
			and @ORTRXTYP = 6)
			or
			(@SOURCDOC in ('CRJ', 'SJ')	--'RMJ', 
			and @ORTRXTYP = 9)
			)
FOR XML path('PLZ:Cheque'), type
)
 return @cncp
end

go
IF (@@Error = 0) PRINT 'Creaci�n exitosa de la funci�n: DcemFcnCheque()'
ELSE PRINT 'Error en la creaci�n de la funci�n: DcemFcnCheque()'
GO
