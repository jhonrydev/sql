create
or replace PACKAGE VDIR_PACK_REGISTRO_TARIFAS AS
/* ---------------------------------------------------------------------
Copyright  Tecnología Informática Coomeva - Colombia
Package     : VDIR_PACK_REGISTRO_TARIFAS
Caso de Uso : 
Descripción : Procesos para el registro del las tarifas - VENTA DIRECTA
--------------------------------------------------------------------
Autor : katherine.latorre@kalettre.com
Fecha : 28-01-2018  
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
-- prGuardarTarifa
-- ---------------------------------------------------------------------
PROCEDURE prGuardarTarifa (
    inu_codPlanPrograma IN VDIR_TARIFA.COD_PLAN_PROGRAMA % TYPE,
    inu_codPlan IN VDIR_TARIFA.COD_PLAN % TYPE,
    inu_codEstado IN VDIR_TARIFA.COD_ESTADO % TYPE,
    inu_codTipoTarifa IN VDIR_TARIFA.COD_TIPO_TARIFA % TYPE,
    inu_valorTarifa IN VDIR_TARIFA.VALOR % TYPE,
    idt_fecVigenciaIni IN VDIR_TARIFA.FECHA_VIGE_INICIAL % TYPE,
    idt_fecVigenciaFin IN VDIR_TARIFA.FECHA_VIGE_FIN % TYPE,
    inu_codCondicion IN VDIR_TARIFA.COD_CONDICION_TARIFA % TYPE,
    inu_codNumUsuarios IN VDIR_TARIFA.COD_NUM_USUARIOS_TARIFA % TYPE,
    inu_codSexo IN VDIR_TARIFA.COD_SEXO % TYPE,
    inu_edadInicial IN VDIR_TARIFA.EDAD_INICIAL % TYPE,
    inu_edadFinal IN VDIR_TARIFA.EDAD_FINAL % TYPE,
    ivc_codTarifaMP IN VDIR_TARIFA.COD_TARIFA_MP % TYPE
);

-- ---------------------------------------------------------------------
-- prActualizarTarifa
-- ---------------------------------------------------------------------
PROCEDURE prActualizarTarifa (
    inu_codTarifa IN VDIR_TARIFA.COD_TARIFA % TYPE,
    inu_codPlanPrograma IN VDIR_TARIFA.COD_PLAN_PROGRAMA % TYPE,
    inu_codPlan IN VDIR_TARIFA.COD_PLAN % TYPE,
    inu_codEstado IN VDIR_TARIFA.COD_ESTADO % TYPE,
    inu_codTipoTarifa IN VDIR_TARIFA.COD_TIPO_TARIFA % TYPE,
    inu_valorTarifa IN VDIR_TARIFA.VALOR % TYPE,
    idt_fecVigenciaIni IN VDIR_TARIFA.FECHA_VIGE_INICIAL % TYPE,
    idt_fecVigenciaFin IN VDIR_TARIFA.FECHA_VIGE_FIN % TYPE,
    inu_codCondicion IN VDIR_TARIFA.COD_CONDICION_TARIFA % TYPE,
    inu_codNumUsuarios IN VDIR_TARIFA.COD_NUM_USUARIOS_TARIFA % TYPE,
    inu_codSexo IN VDIR_TARIFA.COD_SEXO % TYPE,
    inu_edadInicial IN VDIR_TARIFA.EDAD_INICIAL % TYPE,
    inu_edadFinal IN VDIR_TARIFA.EDAD_FINAL % TYPE
);

END VDIR_PACK_REGISTRO_TARIFAS;