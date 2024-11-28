create
or replace PACKAGE VDIR_PACK_REGISTRO_PRODUCTOS AS
/* ---------------------------------------------------------------------
Copyright  Tecnolog¿a Inform¿tica Coomeva - Colombia
Package     : VDIR_PACK_REGISTRO_PRODUCTOS
Caso de Uso : 
Descripci¿n : Procesos para la ejecucion del requerimiento Registro de productos - VENTA DIRECTA
--------------------------------------------------------------------
Autor : diego.castillo@kalettre.com
Fecha : 10-12-2018  
--------------------------------------------------------------------
Procedimiento :     Descripcion:
--------------------------------------------------------------------
Historia de Modificaciones
---------------------------------------------------------------------
Fecha Autor Modificaci¿n
----------------------------------------------------------------- */
----------------------------------------------------------------------------
-- Declaracion de estructuras dinamicas
----------------------------------------------------------------------------
TYPE type_cursor IS REF CURSOR;

/*---------------------------------------------------------------------
fn_get_producto: Traer los programas de cada producto en un string con estructura de objeto
----------------------------------------------------------------------- */
FUNCTION fn_get_producto (
   pty_cod_producto in vdir_producto.cod_producto % type,
   inu_codPlan IN VDIR_PLAN_PROGRAMA.COD_PLAN % TYPE
) RETURN type_cursor;

/*---------------------------------------------------------------------
fn_get_programaxproducto_str: Traer los programas de cada producto en un string con estructura de objeto
----------------------------------------------------------------------- */
FUNCTION fn_get_programaxproducto_str (
   pty_cod_producto in vdir_producto.cod_producto % type,
   inu_codPlan IN VDIR_PLAN_PROGRAMA.COD_PLAN % TYPE
) RETURN VARCHAR2;

/*---------------------------------------------------------------------
fn_get_promocion_producto: Trae la el valor de la promocion a la que aplica un producto
----------------------------------------------------------------------- */
FUNCTION fn_get_promocion_producto (
   pty_cod_producto in vdir_producto.cod_producto % type
) RETURN NUMBER;

/*---------------------------------------------------------------------
fn_get_tarifa: Traer tarifa beneficiario por programa
----------------------------------------------------------------------*/
FUNCTION fn_get_tarifa (
   pty_cod_beneficiario in vdir_persona.cod_persona % type,
   pty_cod_programa in vdir_programa.cod_programa % type,
   pty_cod_afiliacion in vdir_afiliacion.cod_afiliacion % type
) RETURN vdir_tarifa.cod_tarifa % type;

/*---------------------------------------------------------------------
fn_get_valor_tarifa: Traer el valor de la tarifa
---------------------------------------------------------------------- */
FUNCTION fn_get_valor_tarifa (pty_cod_tarifa in vdir_tarifa.cod_tarifa % type) RETURN vdir_tarifa.valor % type;

/*---------------------------------------------------------------------
sp_quitar_beneficiario_programa: Quitar registros diferentes a estado 1 en la tabla vdir_beneficiario_programa
----------------------------------------------------------------------- */
PROCEDURE sp_quitar_benefi_programa (
   pty_cod_usuario in vdir_usuario.cod_usuario % type
);

/*---------------------------------------------------------------------
sp_registra_benefi_programa: Agregar beneficiario programa 
----------------------------------------------------------------------*/
PROCEDURE sp_registra_benefi_programa (
   p_cod_beneficiario in vdir_persona.cod_persona % type,
   p_cod_programa in vdir_programa.cod_programa % type,
   p_cod_afiliacion in vdir_afiliacion.cod_afiliacion % type,
   p_cod_estado in vdir_estado.cod_estado % type,
   p_cod_tipoSolicitud in vdir_tipo_solicitud.cod_tipo_solicitud % type,
   p_val_tarifa out number,
   p_replica_val_tarifa out number
);

/*---------------------------------------------------------------------
sp_registra_factura: Registrar factura de compra productos (linea, programa, beneficiario) 
----------------------------------------------------------------------*/
PROCEDURE sp_registra_factura (
   pty_cod_usuario in vdir_usuario.cod_usuario % type,
   pty_cod_afiliacion in vdir_afiliacion.cod_afiliacion % type,
   pty_cod_factura out vdir_factura.cod_factura % type
);

/*---------------------------------------------------------------------
fn_get_benficiarios_programas: Traer los beneficiarios que estan registrados a un programa
---------------------------------------------------------------------- */
FUNCTION fn_get_benficiarios_programas (
   pty_cod_usuario in vdir_usuario.cod_usuario % type
) RETURN type_cursor;

/*---------------------------------------------------------------------
fn_get_codPrograma_homologa: Traer el codigo de hologacion del programa plan
----------------------------------------------------------------------- */
FUNCTION fn_get_codPrograma_homologa (
   pty_cod_programa in vdir_programa.cod_programa % type,
   pty_cod_plan in vdir_plan.cod_plan % type
) RETURN vdir_plan_programa.cod_programa_homologa % type;

/*---------------------------------------------------------------------
sp_set_estado_benefi_program: Actualizar estado alos pregamas agragados a un beneficiario temporalmente de una afiliacion pendiente
----------------------------------------------------------------------- */
PROCEDURE sp_set_estado_benefi_program (
   pty_cod_usuario in vdir_usuario.cod_usuario % type,
   pty_cod_estado in vdir_estado.cod_estado % type
);

END VDIR_PACK_REGISTRO_PRODUCTOS;