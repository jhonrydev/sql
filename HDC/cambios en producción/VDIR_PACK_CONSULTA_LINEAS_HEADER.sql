create
or replace PACKAGE VDIR_PACK_CONSULTA_LINEAS AS
/* ---------------------------------------------------------------------
Copyright  Tecnología Informática Coomeva - Colombia
Package     : VDIR_PACK_CONSULTA_LINEAS
Caso de Uso : 
Descripción : Procesos para la consulta los productos - VENTA DIRECTA
--------------------------------------------------------------------
Autor : katherine.latorre@kalettre.com
Fecha : 23-01-2018  
--------------------------------------------------------------------
Procedimiento :     Descripcion:
--------------------------------------------------------------------
Historia de Modificaciones
---------------------------------------------------------------------
Fecha Autor Modificación
----------------------------------------------------------------- */
-- ---------------------------------------------------------------------
-- Declaracion de estructuras dinamicas
-- ---------------------------------------------------------------------
TYPE type_cursor IS REF CURSOR;

-- ---------------------------------------------------------------------
-- fnGetLineas
-- ---------------------------------------------------------------------
FUNCTION fnGetLineas RETURN type_cursor;

-- ---------------------------------------------------------------------
-- fnGetProductos
-- ---------------------------------------------------------------------
FUNCTION fnGetProductos RETURN type_cursor;

-- ---------------------------------------------------------------------
-- fnGetProgramas
-- ---------------------------------------------------------------------
FUNCTION fnGetProgramas (
	inu_codProducto IN VDIR_PRODUCTO.COD_PRODUCTO % TYPE
) RETURN type_cursor;

-- ---------------------------------------------------------------------
-- fnGetPlanes
-- ---------------------------------------------------------------------
FUNCTION fnGetPlanes RETURN type_cursor;

-- ---------------------------------------------------------------------
-- fnGetEstados
-- ---------------------------------------------------------------------
FUNCTION fnGetEstados (inuTipo IN VDIR_ESTADO.IND_TIPO % TYPE DEFAULT 1) RETURN type_cursor;

-- ---------------------------------------------------------------------
-- fnGetPlanPrograma
-- ---------------------------------------------------------------------
FUNCTION fnGetPlanPrograma (
	inuCodPlanPrograma IN VDIR_PLAN_PROGRAMA.COD_PLAN_PROGRAMA % TYPE
) RETURN type_cursor;

-- ---------------------------------------------------------------------
-- fnGetCoberturas
-- ---------------------------------------------------------------------
FUNCTION fnGetCoberturas (
	inu_codPrograma IN VDIR_PLAN_PROGRAMA.COD_PROGRAMA % TYPE,
	inu_codPlan IN VDIR_PLAN_PROGRAMA.COD_PLAN % TYPE
) RETURN type_cursor;

END VDIR_PACK_CONSULTA_LINEAS;