--Validando la función de usuario
IF OBJECT_ID ('dbo.fCfdiDatosPagosXmlCompras') IS NOT NULL
   drop function dbo.fCfdiDatosPagosXmlCompras
go

--Creando la función
create function dbo.fCfdiDatosPagosXmlCompras(@archivoXml xml)returns table
return(	
	WITH XMLNAMESPACES('http://www.sat.gob.mx/TimbreFiscalDigital' as "tfd", 
						'http://www.sat.gob.mx/cfd/3' as "cfdi",
						'http://www.sat.gob.mx/Pagos' as "pago10")
   	select	
	A.n.value('(//tfd:TimbreFiscalDigital/@UUID)[1]', 'varchar(50)') UUID,
	A.n.value('(//cfdi:Receptor/@UsoCFDI)[1]', 'varchar(4)') UsoCFDI,
	A.n.value('(//cfdi:Concepto/@ClaveProdServ)[1]', 'varchar(8)')ClaveProdServ,
	A.n.value('(//cfdi:Concepto/@Descripcion)[1]', 'varchar(150)')Descripcion,
	A.n.value('(//cfdi:Concepto/@Importe)[1]', 'varchar(10)')Importe, 
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