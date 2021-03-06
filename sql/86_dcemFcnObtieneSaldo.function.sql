
IF OBJECT_ID ('dbo.DcemFcnObtieneSaldo') IS NOT NULL
   DROP FUNCTION dbo.[DcemFcnObtieneSaldo]
GO

create function [dbo].[DcemFcnObtieneSaldo] (@cta int, @periodid SMALLINT, @year1 SMALLINT) returns numeric(19,6)
--Prop�sito. Obtiene acumulado de resumen de cuentas
--7/4/15 

as
begin
	return(
		select isnull(sum(debitamt) - SUM(crdtamnt),0) 
		  from dcemvwSaldos b
		where ACTINDX = @cta			
		and year1 = @year1
		and PERIODID < @periodid	
	)

end
go

IF (@@Error = 0) PRINT 'Creaci�n exitosa de la funci�n: [DcemFcnObtieneSaldo]()'
ELSE PRINT 'Error en la creaci�n de la funci�n: [DcemFcnObtieneSaldo]()'
GO