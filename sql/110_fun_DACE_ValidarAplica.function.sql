/****** Object:  UserDefinedFunction [dbo].[fun_DACE_ValidarAplica]    Script Date: 11/28/2018 14:23:14 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fun_DACE_ValidarAplica]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[fun_DACE_ValidarAplica]
GO

/****** Object:  UserDefinedFunction [dbo].[fun_DACE_ValidarAplica]    Script Date: 11/28/2018 14:23:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fun_DACE_ValidarAplica](@UUIDPago varchar(50),@UUIDaValidar varchar(50))  
RETURNS int   
AS   
-- Returns the stock level for the product.  
BEGIN  
    DECLARE @ret int;

    SELECT @ret = COUNT(*) from dace.ComprobanteCFDIRelacionado where @UUIDPago=CFDI_UUID and @UUIDaValidar=UUIDRELACIONADO;  
     IF (@ret=0)   
        SET @ret = -99;  
    RETURN @ret;  
END; 
GO


GRANT  execute  ON [dbo].[fun_DACE_ValidarAplica]  TO [DYNGRP] 
GO 

