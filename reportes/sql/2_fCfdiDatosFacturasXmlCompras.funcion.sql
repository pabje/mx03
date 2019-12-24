--Validando la existencia de la función
IF OBJECT_ID ('dbo.fCfdiDatosFacturasXmlCompras') IS NOT NULL
   drop function dbo.fCfdiDatosFacturasXmlCompras
go

--Creando la función
create function dbo.fCfdiDatosFacturasXmlCompras(@archivoXml xml)returns table
return(	
	WITH XMLNAMESPACES('http://www.sat.gob.mx/TimbreFiscalDigital' as "tfd", 
						'http://www.sat.gob.mx/cfd/3' as "cfdi")   	
	SELECT 	
	A.n.value('(//tfd:TimbreFiscalDigital/@UUID)[1]', 'varchar(50)') UUID,	
	A.n.value('(//cfdi:Comprobante/@Moneda)[1]', 'varchar(10)') Moneda,
	A.n.value('(//cfdi:Comprobante/@TipoCambio)[1]', 'varchar(10)') TaseDeCambio,
	A.n.value('(//cfdi:Receptor/@UsoCFDI)[1]', 'varchar(4)') UsoCFDI,
	A.n.value('../../../@ClaveProdServ','varchar(8)')ClaveProdServ,
	A.n.value('../../../@Descripcion','varchar(150)')Descripcion,
	A.n.value('../../../@Importe','varchar(10)')Importe,	
	A.n.value('@Importe','varchar(10)') ImpuestoValorAgregado,
	A.n.value('@TasaOCuota','varchar(10)')TasaCuota
	FROM
	@archivoXmL.nodes('//cfdi:Conceptos/cfdi:Concepto/cfdi:Impuestos/cfdi:Traslados/cfdi:Traslado') AS A(n)
	)	
	go