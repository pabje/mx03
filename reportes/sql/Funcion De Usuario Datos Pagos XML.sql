IF OBJECT_ID ('dbo.fCfdiDatosPagosXmlCompras') IS NOT NULL
   drop function dbo.fCfdiDatosPagosXml
go

create function dbo.fCfdiDatosPagosXmlCompras(@archivoXml xml)returns table
--Propósito. Obtiene los datos de la factura electrónica
--Usado por. vwCfdTransaccionesDeVenta
--Requisitos. CFDI
--25/10/17 jcf Creación cfdi 3.3
--25/01/18 jcf Agrega receptorRfc
--
return(	
	WITH XMLNAMESPACES('http://www.sat.gob.mx/TimbreFiscalDigital' as "tfd", 
						'http://www.sat.gob.mx/cfd/3' as "cfdi",
						'http://www.sat.gob.mx/Pagos' as "pago10")
   	select
	--A.n.value('(//tfd:TimbreFiscalDigital/@Version)[1]', 'varchar(5)') [version],
	A.n.value('(//tfd:TimbreFiscalDigital/@UUID)[1]', 'varchar(50)') UUID,
	--A.n.value('(//tfd:TimbreFiscalDigital/@FechaTimbrado)[1]', 'varchar(20)') FechaTimbrado,
	--A.n.value('(//tfd:TimbreFiscalDigital/@RfcProvCertif)[1]', 'varchar(20)') RfcPAC,
	--@archivoXml.value('(//tfd:TimbreFiscalDigital/@Leyenda)[1]', 'varchar(150)') Leyenda,
	--A.n.value('(//tfd:TimbreFiscalDigital/@SelloCFD)[1]', 'varchar(8000)') SelloCFD,
	--A.n.value('(//tfd:TimbreFiscalDigital/@NoCertificadoSAT)[1]', 'varchar(20)') NoCertificadoSAT,
	--A.n.value('(//tfd:TimbreFiscalDigital/@SelloSAT)[1]', 'varchar(8000)') SelloSAT,
	--B.n.value('(//cfdi:Comprobante/@Sello)[1]', 'varchar(8000)') Sello,
	--B.n.value('(//cfdi:Comprobante/@NoCertificado)[1]', 'varchar(20)') NoCertificado,
	--B.n.value('(//@FormaPago)[1]', 'varchar(50)') FormaPago,
	--A.n.value('(//@MetodoPago)[1]', 'varchar(21)') MetodoPago,
	  --A.n.value('(//cfdi:Receptor/@Rfc)[1]', 'varchar(15)') receptorRfc,
	A.n.value('(//cfdi:Receptor/@UsoCFDI)[1]', 'varchar(4)') UsoCFDI,
	--D.n.value('(//cfdi:CfdiRelacionados/@TipoRelacion)[1]', 'varchar(4)') TipoRelacion,
	--D.n.value('(//cfdi:CfdiRelacionado/@UUID)[1]', 'varchar(60)') UUIDrelacionado,
	--AGREGO CAMPOS
	A.n.value('(//cfdi:Concepto/@ClaveProdServ)[1]', 'varchar(8)')ClaveProdServ,
	A.n.value('(//cfdi:Concepto/@Descripcion)[1]', 'varchar(150)')Descripcion,
	A.n.value('(//cfdi:Concepto/@Importe)[1]', 'varchar(10)')Importe, 
	--detalle se repite
    --A.n.value('(//cfdi:Traslado/@Importe)[1]', 'varchar(10)')ImpuestoValorAgregado,
	--A.n.value('(//cfdi:Traslado/@TasaOCuota)[1]', 'varchar(10)')TasaCuota,			
	A.n.value('@NumParcialidad','varchar(1)')NumParcialidad,
 	A.n.value('@IdDocumento','varchar(50)')IdDocumento,
	A.n.value('@MetodoDePagoDR','varchar(21)')MetodoDePagoDR,
 	A.n.value('@ImpSaldoAnt','varchar(10)')ImpSaldoAnt,
	A.n.value('@ImpPagado','varchar(10)')ImpPagado,
	A.n.value('@ImpSaldoInsoluto','varchar(10)')ImpSaldoInsoluto,
	A.n.value('../@MonedaP','varchar(3)')MonedaDelPago,
    A.n.value('../@FechaPago','varchar(20)')FechaDelPago,
	A.n.value('../@TipoCambioP','varchar(10)')TasaDeCambio,
    A.n.value('../@Monto','varchar(10)')Monto
	FROM
	@archivoXmL.nodes('//cfdi:Complemento/pago10:Pagos/pago10:Pago/pago10:DoctoRelacionado') AS A(n)
	)
	go