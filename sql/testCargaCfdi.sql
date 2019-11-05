
--carga de comprobantes cfdi
select *
from dace.ComprobanteCFDI


select *
from dbo.vwPmTransaccionesTodas a
LEFT OUTER JOIN  dbo.ACA_IETU00400 AS asoc 
				ON asoc.DOCTYPE = a.DOCTYPE 
				AND asoc.VCHRNMBR = a.VCHRNMBR 

select *
from dace.ComprobanteCFDIRelacionado

