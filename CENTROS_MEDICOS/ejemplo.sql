--SELECT * FROM por_ciudad order by id desc;
--SELECT * FROM por_especialidad order by id desc;
--SELECT * FROM por_centros_medicos order by id desc;
--SELECT * FROM por_especialidad_x_ciudad order by id desc;
--DROP TRIGGER
DECLARE ID NUMBER;

BEGIN
--PCMED_SNPCENTROSMEDICOS.insert_por_ciudad('1111','TURBO','1',ID);
--PCMED_SNPCENTROSMEDICOS.update_por_ciudad('276','1111','CALI','1');
--PCMED_SNPCENTROSMEDICOS.update_por_ciudad('274','1111','TURBO2','1');
--PCMED_SNPCENTROSMEDICOS.delete_por_ciudad('276');
--PCMED_SNPCENTROSMEDICOS.insert_por_especialidad('003','ONCOLOGIA','','1',ID);
--PCMED_SNPCENTROSMEDICOS.update_por_especialidad('44','003','ONCOLOGIA2','','1');
--PCMED_SNPCENTROSMEDICOS.update_por_especialidad('44','003','ONCOLOGIA',null,'0');
--PCMED_SNPCENTROSMEDICOS.delete_por_especialidad('44');
--PCMED_SNPCENTROSMEDICOS.insert_por_cmedicos('centro_prueba','ciudad_prueba','dirección_prueba','12345','54321','999999','6:00 am','','imagen_prueba','1','direccion2_prueba',ID);
--PCMED_SNPCENTROSMEDICOS.update_por_cmedicos('45','2centro_prueba','2ciudad_prueba','dirección_prueba','12345','54321','6:00 am','','55555','imagen_prueba','1','direccion2_prueba');
--PCMED_SNPCENTROSMEDICOS.update_por_cmedicos('45','2centro_prueba','ciudad_prueba','dirección_prueba','12345','54321','6:00 am',null,'55555','imagen_prueba','1','direccion2_prueba');
--PCMED_SNPCENTROSMEDICOS.delete_por_cmedicos('45');
--PCMED_SNPCENTROSMEDICOS.insert_por_esp_x_ciudad(1,10);
PCMED_SNPCENTROSMEDICOS.update_por_esp_x_ciudad ('44', '1', '2');

END;

/*

Ejemplo Java

CallableStatement cstmt = null;
ResultSet rs = null;
Connection connection = null;
String sql = "";
try {
connection = DataHelperOracle.getConection();
//sql = "{CALL SALUDMP.Sp_InfoRegionalUsuario(?) }";
sql = "{CALL PCMED_SNPCENTROSMEDICOS.INSERT_POR_CIUDAD(?,?,?,?) }";
cstmt = connection.prepareCall(sql);            
cstmt.setString(1, "10000");
cstmt.setString(2, "cali7");
cstmt.setString(3, "1");
cstmt.registerOutParameter(4, Types.NUMERIC);
cstmt.executeUpdate();
rs = cstmt.getResultSet();
int  idServicioCreado = cstmt.getInt(4);


 */