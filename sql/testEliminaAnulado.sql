select --cfdi.*, 
asig.*
--delete asig
  from dace.ComprobanteCFDI cfdi
	inner join dbo.ACA_IETU00400 asig
		on rtrim(asig.MexFolioFiscal) = cfdi.UUID
	inner join dbo.vwPmTransaccionesTodas pm
		on pm.VCHRNMBR = asig.VCHRNMBR
	--	and pm.DOCTYPE = asig.DOCTYPE
where cfdi.UUID = '2C06B0CE-4ACA-4C3E-BAB3-73C30E0805A4'