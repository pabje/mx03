IF EXISTS (
  SELECT * 
    FROM INFORMATION_SCHEMA.ROUTINES 
   WHERE SPECIFIC_SCHEMA = 'dcem'
     AND SPECIFIC_NAME = 'PreprocesaArchivosDeContaElectronica' 
)
   DROP PROCEDURE dcem.PreprocesaArchivosDeContaElectronica;
GO
------------------------------------------------------------------------------------------------------
--Prop�sito. Acelerar la generaci�n de archivos xml para contabilidad electr�nica
--Requisito. Este sp debe ejecutarse en un job todos los d�as en cada compa��a
--14/6/17 jcf Guarda p�lizas xml
-- modificar la aplicaci�n:
--	1. update dcempoliza set nodoTransaccion = dbo.dcemfcntransaccion(...) where error = 1
--  2. armar el xml desde la tabla
--	3. validar cada asiento
--  4. actualizar la tabla dcempoliza. Marcar los asientos con error
--
CREATE PROCEDURE dcem.PreprocesaArchivosDeContaElectronica
AS
	declare @fechaIni datetime, @fechaFin datetime;
	set @fechaFin = GETDATE();
	set @fechaIni = @fechaFin - 30;

	INSERT into dcem.dcemPoliza(jrnentry, trxdate, refrence, nodoTransaccion) 
	select t.jrnentry, t.trxdate, t.refrence, dbo.dcemfcntransaccion(0, 0, 0, t.jrnentry, t.TRXDATE)
	from dbo.dcemvwtransaccion t
	where not exists (
		select p.jrnentry 
		from dcem.dcemPoliza p
		where p.jrnentry = t.jrnentry
		and datediff(day, p.trxdate, t.trxdate) = 0
	)
	and datediff(day, @fechaIni, trxdate) >= 0
	and datediff(day, @fechaFin, trxdate) <= 0
	GROUP BY t.JRNENTRY, t.TRXDATE, t.refrence
GO

	--BEGIN TRAN;
	----P�lizas
	--MERGE dcem.dcemPoliza AS T
	--USING (
	--	select jrnentry, trxdate, refrence, dbo.dcemfcntransaccion(0, 0, 0, jrnentry, trxdate) nodoPoliza
	--	from dbo.dcemvwtransaccion
	--	where datediff(day, @fechaIni, trxdate) >= 0
	--	and datediff(day, @fechaFin, trxdate) <= 0
	--	--and jrnentry between 92000 and 92300
	--	GROUP BY JRNENTRY, TRXDATE, refrence
	--) AS S
	--ON (T.jrnentry = S.jrnentry
	--	and datediff(day, T.trxdate, S.trxdate) = 0)
	----WHEN MATCHED AND convert(varchar(max), isnull(T.nodoTransaccion, '')) !=  convert(varchar(max), S.nodoPoliza)
	----	THEN UPDATE SET T.nodoTransaccion = S.nodoPoliza
	--WHEN NOT MATCHED BY TARGET 
	--	THEN INSERT(jrnentry, trxdate, refrence, nodoTransaccion) 
	--	VALUES(S.jrnentry, S.trxdate, S.refrence, S.nodoPoliza);
	----OUTPUT $action, inserted.*, deleted.*;
	--COMMIT TRAN;

IF (@@Error = 0) PRINT 'Creaci�n exitosa de: dcem.PreprocesaArchivosDeContaElectronica'
ELSE PRINT 'Error en la creaci�n de: dcem.PreprocesaArchivosDeContaElectronica'
GO

----------------------------------------------------------------------------------------------------
-- =============================================
-- test
-- =============================================
