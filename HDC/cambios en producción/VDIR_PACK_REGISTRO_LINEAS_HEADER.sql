create
or replace PACKAGE VDIR_PACK_REGISTRO_LINEAS AS
/* ---------------------------------------------------------------------
Copyright  Tecnología Informática Coomeva - Colombia
Package     : VDIR_PACK_REGISTRO_LINEAS
Caso de Uso : 
Descripción : Procesos para el registro del los programas asociados al 
plan - VENTA DIRECTA
--------------------------------------------------------------------
Autor : katherine.latorre@kalettre.com
Fecha : 25-01-2018  
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
-- prGuardarPlanPrograma
-- ---------------------------------------------------------------------
PROCEDURE prGuardarPlanPrograma (
    inu_codPlan IN VDIR_PLAN_PROGRAMA.COD_PLAN % TYPE,
    inu_codPrograma IN VDIR_PLAN_PROGRAMA.COD_PROGRAMA % TYPE,
    inu_codEstado IN VDIR_PLAN_PROGRAMA.COD_ESTADO % TYPE,
    ivc_coberturaInicial IN VDIR_PLAN_PROGRAMA.COBERTURA_INICIAL % TYPE,
    ivc_coberturaFinal IN VDIR_PLAN_PROGRAMA.COBERTURA_FINAL % TYPE,
    ivc_codProgramaHologa IN VDIR_PLAN_PROGRAMA.COD_PROGRAMA_HOMOLOGA % TYPE,
    ivc_cuenta IN VDIR_PLAN_PROGRAMA.CUENTA % TYPE,
    ivc_sub_cuenta IN VDIR_PLAN_PROGRAMA.SUB_CUENTA % TYPE,
    ivc_programa IN VDIR_PLAN_PROGRAMA.PROGRAMA % TYPE,
    ivc_tarifa IN VDIR_PLAN_PROGRAMA.TARIFA % TYPE,
    ivc_edadIni IN VDIR_PLAN_PROGRAMA.EDAD_INI % TYPE,
    ivc_edadFin IN VDIR_PLAN_PROGRAMA.EDAD_FIN % TYPE,
    ivc_errorMesg IN VDIR_PLAN_PROGRAMA.MENSAJE_ERROR % TYPE,
    ivc_isFree IN VDIR_PLAN_PROGRAMA.SWITCH_MES % TYPE,
    ivc_fechaPrimerMes IN VDIR_PLAN_PROGRAMA.FECHA_FIN_PROMOCION % TYPE
);

-- ---------------------------------------------------------------------
-- prActualizarPlanPrograma
-- ---------------------------------------------------------------------
PROCEDURE prActualizarPlanPrograma (
    inu_codPlanPrograma IN VDIR_PLAN_PROGRAMA.COD_PLAN_PROGRAMA % TYPE,
    inu_codPlan IN VDIR_PLAN_PROGRAMA.COD_PLAN % TYPE,
    inu_codPrograma IN VDIR_PLAN_PROGRAMA.COD_PROGRAMA % TYPE,
    inu_codEstado IN VDIR_PLAN_PROGRAMA.COD_ESTADO % TYPE,
    ivc_coberturaInicial IN VDIR_PLAN_PROGRAMA.COBERTURA_INICIAL % TYPE,
    ivc_coberturaFinal IN VDIR_PLAN_PROGRAMA.COBERTURA_FINAL % TYPE,
    ivc_codProgramaHologa IN VDIR_PLAN_PROGRAMA.COD_PROGRAMA_HOMOLOGA % TYPE,
    ivc_cuenta IN VDIR_PLAN_PROGRAMA.CUENTA % TYPE,
    ivc_sub_cuenta IN VDIR_PLAN_PROGRAMA.SUB_CUENTA % TYPE,
    ivc_programa IN VDIR_PLAN_PROGRAMA.PROGRAMA % TYPE,
    ivc_tarifa IN VDIR_PLAN_PROGRAMA.TARIFA % TYPE,
    ivc_edadIni IN VDIR_PLAN_PROGRAMA.EDAD_INI % TYPE,
    ivc_edadFin IN VDIR_PLAN_PROGRAMA.EDAD_FIN % TYPE
);

END VDIR_PACK_REGISTRO_LINEAS;