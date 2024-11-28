create
or replace PACKAGE VDIR_PACK_CONSULTA_TARIFAS AS
/* ---------------------------------------------------------------------
Copyright  Tecnolog¿a Inform¿tica Coomeva - Colombia
Package     : VDIR_PACK_CONSULTA_TARIFAS
Caso de Uso : 
Descripci¿n : Procesos para la consulta las tarifas - VENTA DIRECTA
--------------------------------------------------------------------
Autor : katherine.latorre@kalettre.com
Fecha : 28-01-2019 
--------------------------------------------------------------------
Procedimiento :     Descripcion:
--------------------------------------------------------------------
Historia de Modificaciones
---------------------------------------------------------------------
Fecha Autor Modificaci¿n
----------------------------------------------------------------- */
-- ---------------------------------------------------------------------
-- Declaracion de estructuras dinamicas
-- ---------------------------------------------------------------------
TYPE type_cursor IS REF CURSOR;

-- ---------------------------------------------------------------------
-- fnGetTarifas
-- ---------------------------------------------------------------------
FUNCTION fnGetTarifas RETURN type_cursor;

-- ---------------------------------------------------------------------
-- fnGetTipoTarifas
-- ---------------------------------------------------------------------
FUNCTION fnGetTipoTarifas RETURN type_cursor;

-- ---------------------------------------------------------------------
-- fnGetProgramasPlan
-- ---------------------------------------------------------------------
FUNCTION fnGetProgramasPlan (inu_codPlan IN VDIR_PLAN_PROGRAMA.COD_PLAN % TYPE) RETURN type_cursor;

-- ---------------------------------------------------------------------
-- fnGetGeneros
-- ---------------------------------------------------------------------
FUNCTION fnGetGeneros RETURN type_cursor;

-- ---------------------------------------------------------------------
-- fnGetCondicionTarifa
-- ---------------------------------------------------------------------
FUNCTION fnGetCondicionTarifa RETURN type_cursor;

-- ---------------------------------------------------------------------
-- fnGetNumUsuarios
-- ---------------------------------------------------------------------
FUNCTION fnGetNumUsuarios RETURN type_cursor;

-- ---------------------------------------------------------------------
-- fnGetTarifa
-- ---------------------------------------------------------------------
FUNCTION fnGetTarifa (inu_codTarifa IN VDIR_TARIFA.COD_TARIFA % TYPE) RETURN type_cursor;

-- ---------------------------------------------------------------------
-- fnGetExisteTarifa
-- ---------------------------------------------------------------------
FUNCTION fnGetExisteTarifa (
    ivc_codTarifaMP IN VDIR_TARIFA.COD_TARIFA_MP % TYPE
) RETURN VDIR_TARIFA.COD_TARIFA % TYPE;

END VDIR_PACK_CONSULTA_TARIFAS;