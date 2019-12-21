IF OBJECT_ID ('dbo.fCfdiDatosFacturasXmlCompras') IS NOT NULL
   drop function dbo.fCfdiDatosFacturasXmlCompras
go

create function dbo.fCfdiDatosFacturasXmlCompras(@archivoXml xml)returns table
--Propósito. Obtiene los datos de la factura electrónica
--Usado por. vwCfdTransaccionesDeVenta
--Requisitos. CFDI
--25/10/17 jcf Creación cfdi 3.3
--25/01/18 jcf Agrega receptorRfc
--returns table

return(	
	WITH XMLNAMESPACES('http://www.sat.gob.mx/TimbreFiscalDigital' as "tfd", 
						'http://www.sat.gob.mx/cfd/3' as "cfdi")    
   	
	SELECT 
	--A.n.value('(//tfd:TimbreFiscalDigital/@Version)[1]', 'varchar(5)') [version],
	--A.n.value('@version','varchar(5)')AS version,
	A.n.value('(//tfd:TimbreFiscalDigital/@UUID)[1]', 'varchar(50)') UUID,
	--A.n.value('@UUID','varchar(50)') AS UUID,
	--A.n.value('(//tfd:TimbreFiscalDigital/@FechaTimbrado)[1]', 'varchar(20)') FechaTimbrado,
	--A.n.value('@FechaTimbrado','varchar(20)')FechaTimbrado,
    --A.n.value('(//tfd:TimbreFiscalDigital/@RfcProvCertif)[1]', 'varchar(20)') RfcPAC,
	--A.n.value('(//tfd:TimbreFiscalDigital/@Leyenda)[1]', 'varchar(150)') Leyenda,
	--A.n.value('(//tfd:TimbreFiscalDigital/@SelloCFD)[1]', 'varchar(8000)') SelloCFD,
	--A.n.value('(//tfd:TimbreFiscalDigital/@NoCertificadoSAT)[1]', 'varchar(20)') NoCertificadoSAT,
	--A.n.value('(//tfd:TimbreFiscalDigital/@SelloSAT)[1]', 'varchar(8000)') SelloSAT,
	--B.n.value('(//cfdi:Comprobante/@Sello)[1]', 'varchar(8000)') Sello,
	--B.n.value('(//cfdi:Comprobante/@NoCertificado)[1]', 'varchar(20)') NoCertificado,
	--B.n.value('(//cfdi:Comprobante/@FormaPago)[1]', 'varchar(50)') FormaPago,
	--B.n.value('(//cfdi:Comprobante/@MetodoPago)[1]', 'varchar(21)') MetodoPago,
	A.n.value('(//cfdi:Comprobante/@Moneda)[1]', 'varchar(10)') Moneda,
	A.n.value('(//cfdi:Comprobante/@TipoCambio)[1]', 'varchar(10)') TaseDeCambio,
	--C.n.value('(//cfdi:Receptor/@Rfc)[1]', 'varchar(15)') receptorRfc,
    A.n.value('(//cfdi:Receptor/@UsoCFDI)[1]', 'varchar(4)') UsoCFDI,
	--D.n.value('(//cfdi:CfdiRelacionados/@TipoRelacion)[1]', 'varchar(4)') TipoRelacion,
	--D.n.value('(//cfdi:CfdiRelacionado/@UUID)[1]', 'varchar(60)') UUIDrelacionado,
	--AGREGO CAMPOS
	--E.n.value('(//cfdi:Conceptos/@ClaveProdServ)[1]', 'varchar(8)')ClaveProdServ,
	--A.n.value('(./cfdi:Complemento/@UUID','varchar(50)')UUID,
	A.n.value('../../../@ClaveProdServ','varchar(8)')ClaveProdServ,
	--E.n.value('(//cfdi:Conceptos/@Descripcion)[1]', 'varchar(150)')Descripcion,
	A.n.value('../../../@Descripcion','varchar(150)')Descripcion,
	--E.n.value('(//cfdi:Conceptos/@Importe)[1]', 'varchar(10)')Importe
	A.n.value('../../../@Importe','varchar(10)')Importe,
	--E.n.query('.'),
	--F.n.value('(//cfdi:Traslados/@Importe)[1]', 'varchar(10)')ImpuestoValorAgregado,
	--A.n.value('@Impuesto','varchar(5)')CodigoImpuesto,
	A.n.value('@Importe','varchar(10)') ImpuestoValorAgregado,
	--F.n.value('(//cfdi:Traslados/@TasaOCuota)[1]', 'varchar(10)')TasaCuota
	A.n.value('@TasaOCuota','varchar(10)')TasaCuota
	FROM
	@archivoXmL.nodes('//cfdi:Conceptos/cfdi:Concepto/cfdi:Impuestos/cfdi:Traslados/cfdi:Traslado') AS A(n)
	--OUTER APPLY
	--A.n.nodes('//cfdi:Conceptos') as B(n)
	--A.n.nodes('//cfdi:Comprobante') AS B(n)
	--OUTER APPLY
	--B.n.nodes('//cfdi:Receptor')AS C(n)
	--OUTER APPLY
	--C.n.nodes('//cfdi:CfdiRelacionados')AS D(n)
	--OUTER APPLY
	--D.n.nodes('//cfdi:Conceptos')AS E(n)
	--OUTER APPLY
	--E.n.nodes('//cfdi:Traslados') AS F(n)
	)	
	go