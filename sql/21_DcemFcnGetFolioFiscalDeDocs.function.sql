
IF OBJECT_ID ('dbo.DcemFnGetFolioFiscalDeDocumento') IS NOT NULL
   DROP FUNCTION dbo.[DcemFnGetFolioFiscalDeDocumento]
GO

create function [dbo].[DcemFnGetFolioFiscalDeDocumento]
(
@ORCTRNUM varchar(21) 
,@ORTRXTYP smallint 
) returns table
as
--Prop�sito. Obtiene folio fiscal del documento
--25/01/18 jcf Creaci�n
--
return ( 
   select rtrim(dx.UUID) foliofiscal,
          rtrim(dx.receptorRfc) RFC 
     from dbo.vwCfdiDatosDelXml dx
	where dx.soptype = @ORTRXTYP
		and dx.sopnumbe = @ORCTRNUM
		and dx.estado = 'emitido'
          ) 
GO

IF (@@Error = 0) PRINT 'Creaci�n exitosa de la funci�n: [DcemFnGetFolioFiscalDeDocumento]()'
ELSE PRINT 'Error en la creaci�n de la funci�n: [DcemFnGetFolioFiscalDeDocumento]()'
GO
