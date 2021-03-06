
IF OBJECT_ID ('dbo.dcemfcnctas') IS NOT NULL
   DROP FUNCTION dbo.[dcemfcnctas]
GO

create function [dbo].[dcemfcnctas](@periodid SMALLINT, @year1 SMALLINT)

returns xml 
as
--Prop�sito. Acumulacion de Saldos por Cta
--../12/14 jmg Creaci�n
--07/04/15 jcf Replanteo de consulta
--02/02/16 JCF Optimiza consulta
--19/11/19 jcf Corrie bug. No mostraba cuentas sin movimiento en el mes
--
begin
 declare @cncp xml;
 WITH XMLNAMESPACES
(
    'http://www.sat.gob.mx/esquemas/ContabilidadE/1_3/BalanzaComprobacion' as "BCE"
) 
  select @cncp = 
 (
	  select 
		left(ltrim(rtrim(ct.ACTNUMST)), 100)			'@NumCta',
		cast(isnull(sa.saldo, 0) as numeric(19,2))		'@SaldoIni',
		cast(isnull(periodo.debitamt, 0) as numeric(19,2))    '@Debe',
		cast(isnull(periodo.CRDTAMNT, 0) as numeric(19,2))    '@Haber',
		cast(isnull(sa.saldo, 0) + (isnull(periodo.debitamt, 0) - isnull(periodo.CRDTAMNT, 0)) as numeric(19,2)) '@SaldoFin'
	  from 	GL00105 ct
		left join dcemvwSaldos periodo
			on periodo.ACTINDX = ct.ACTINDX
			and periodo.PERIODID = @periodid
			and periodo.year1 = @year1
	   	outer apply dbo.DcemFcnObtieneSaldoTab(ct.ACTINDX, @periodid ,@year1) sa
	 where isnull(sa.saldo, 0) != 0
	 or isnull(periodo.debitamt, 0) != 0 
	 or isnull(periodo.CRDTAMNT, 0) != 0
	 order by periodo.actindx asc, periodo.YEAR1 asc, periodo.PERIODID asc
	 --
	 FOR XML path('BCE:Ctas'), type
     )
 return @cncp
end
go

IF (@@Error = 0) PRINT 'Creaci�n exitosa de la funci�n: [dcemfcnctas]()'
ELSE PRINT 'Error en la creaci�n de la funci�n: [dcemfcnctas]()'
GO


--select dbo.dcemfcnctas(1, 2016)
