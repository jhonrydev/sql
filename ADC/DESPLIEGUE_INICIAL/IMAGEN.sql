
INSERT INTO "SMP_ADM"."ADM_IMAGES_HOME" (ID, NOMBRE, FECHA_EXPIRACION, FECHA_INICIO, FECHA_REGISTRO, USUARIO_REGISTRO, VERSION, ESTADO, TIPO) VALUES ('1', 'diciembre', TO_DATE('2024-12-31 19:14:35', 'YYYY-MM-DD HH24:MI:SS'), TO_DATE('2024-11-27 19:14:45', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2024-11-27 19:16:54.199676400', 'YYYY-MM-DD HH24:MI:SS.FF'), 'VICTOR', '1', '1', 'SPLASH');

INSERT INTO "SMP_ADM"."ADM_DETAIL_IMAGES_HOME" (ID, IMAGE_HOME_ID, DEVICE, SIZE_IMAGE, URL_IMAGE, STATUS) VALUES ('1', '1', 'android', 'mdpi', 'https://www.coomeva.com.co/info/coomeva/media/galeria209624.jpg', '1');
INSERT INTO "SMP_ADM"."ADM_DETAIL_IMAGES_HOME" (ID, IMAGE_HOME_ID, DEVICE, SIZE_IMAGE, URL_IMAGE, STATUS) VALUES ('2', '1', 'android', 'hdpi', 'https://www.coomeva.com.co/info/coomeva/media/galeria209625.jpg', '1');
INSERT INTO "SMP_ADM"."ADM_DETAIL_IMAGES_HOME" (ID, IMAGE_HOME_ID, DEVICE, SIZE_IMAGE, URL_IMAGE, STATUS) VALUES ('3', '1', 'android', 'xhdpi', 'https://www.coomeva.com.co/info/coomeva/media/galeria209626.jpg', '1');
INSERT INTO "SMP_ADM"."ADM_DETAIL_IMAGES_HOME" (ID, IMAGE_HOME_ID, DEVICE, SIZE_IMAGE, URL_IMAGE, STATUS) VALUES ('4', '1', 'android', 'xxhdpi', 'https://www.coomeva.com.co/info/coomeva/media/galeria209627.jpg', '1');
INSERT INTO "SMP_ADM"."ADM_DETAIL_IMAGES_HOME" (ID, IMAGE_HOME_ID, DEVICE, SIZE_IMAGE, URL_IMAGE, STATUS) VALUES ('5', '1', 'android', 'xxxhdpi', 'https://www.coomeva.com.co/info/coomeva/media/galeria209628.jpg', '1');
INSERT INTO "SMP_ADM"."ADM_DETAIL_IMAGES_HOME" (ID, IMAGE_HOME_ID, DEVICE, SIZE_IMAGE, URL_IMAGE, STATUS) VALUES ('6', '1', 'ios', '1x', 'https://www.coomeva.com.co/info/coomeva/media/galeria209629.jpg', '1');
INSERT INTO "SMP_ADM"."ADM_DETAIL_IMAGES_HOME" (ID, IMAGE_HOME_ID, DEVICE, SIZE_IMAGE, URL_IMAGE, STATUS) VALUES ('7', '1', 'ios', '2x', 'https://www.coomeva.com.co/info/coomeva/media/galeria209630.jpg', '1');
INSERT INTO "SMP_ADM"."ADM_DETAIL_IMAGES_HOME" (ID, IMAGE_HOME_ID, DEVICE, SIZE_IMAGE, URL_IMAGE, STATUS) VALUES ('8', '1', 'ios', '3x', 'https://www.coomeva.com.co/info/coomeva/media/galeria209631.jpg', '1');


INSERT INTO "SMP_ADM"."ADM_IMAGES_HOME" (ID, NOMBRE, FECHA_EXPIRACION, FECHA_INICIO, FECHA_REGISTRO, USUARIO_REGISTRO, VERSION, ESTADO, TIPO) VALUES ('2', 'home_diciembre', TO_CHAR(SYSDATE, 'DD/MM/YYYY'), TO_CHAR(SYSDATE, 'DD/MM/YYYY'), TO_CHAR(SYSTIMESTAMP, 'DD/MM/YY HH:MI:SS,FF9 AM'), 'VICTOR', '1', '1', 'HOME');

INSERT INTO "SMP_ADM"."ADM_DETAIL_IMAGES_HOME" (ID, IMAGE_HOME_ID, DEVICE, SIZE_IMAGE, URL_IMAGE, STATUS) VALUES ('9', '2', 'android', 'mdpi', 'https://www.coomeva.com.co/info/coomeva/media/galeria209253.jpg', '1');
INSERT INTO "SMP_ADM"."ADM_DETAIL_IMAGES_HOME" (ID, IMAGE_HOME_ID, DEVICE, SIZE_IMAGE, URL_IMAGE, STATUS) VALUES ('10', '2', 'android', 'hdpi', '	https://www.coomeva.com.co/info/coomeva/media/galeria209254.jpg', '1');
INSERT INTO "SMP_ADM"."ADM_DETAIL_IMAGES_HOME" (ID, IMAGE_HOME_ID, DEVICE, SIZE_IMAGE, URL_IMAGE, STATUS) VALUES ('11', '2', 'android', 'https://www.coomeva.com.co/info/coomeva/media/galeria209255.jpg', '1');
INSERT INTO "SMP_ADM"."ADM_DETAIL_IMAGES_HOME" (ID, IMAGE_HOME_ID, DEVICE, SIZE_IMAGE, URL_IMAGE, STATUS) VALUES ('12', '2', 'android', 'xxhdpi', 'https://www.coomeva.com.co/info/coomeva/media/galeria209256.jpg', '1');
INSERT INTO "SMP_ADM"."ADM_DETAIL_IMAGES_HOME" (ID, IMAGE_HOME_ID, DEVICE, SIZE_IMAGE, URL_IMAGE, STATUS) VALUES ('13', '2', 'android', 'xxxhdpi', 'https://www.coomeva.com.co/info/coomeva/media/galeria209257.jpg', '1');
INSERT INTO "SMP_ADM"."ADM_DETAIL_IMAGES_HOME" (ID, IMAGE_HOME_ID, DEVICE, SIZE_IMAGE, URL_IMAGE, STATUS) VALUES ('14', '2', 'ios', '1x', 'https://www.coomeva.com.co/info/coomeva/media/galeria209258.jpg', '1');
INSERT INTO "SMP_ADM"."ADM_DETAIL_IMAGES_HOME" (ID, IMAGE_HOME_ID, DEVICE, SIZE_IMAGE, URL_IMAGE, STATUS) VALUES ('15', '2', 'ios', '2x', 'https://www.coomeva.com.co/info/coomeva/media/galeria209259.jpg', '1');
INSERT INTO "SMP_ADM"."ADM_DETAIL_IMAGES_HOME" (ID, IMAGE_HOME_ID, DEVICE, SIZE_IMAGE, URL_IMAGE, STATUS) VALUES ('16', '2', 'ios', '3x', 'https://www.coomeva.com.co/info/coomeva/media/galeria209260.jpg', '1');

COMMIT;