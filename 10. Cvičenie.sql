-- praca s BLOB-mi

-- object oracle directory
   -- vlastnikom je sys
   -- automaticky dostanem prava read a write
create directory cupan1directory as 'C:\Bloby_student\cupan1\';

create table blob_table (
    id integer,
    nazov varchar2(50),
    subor blob,
    pripona varchar2(5)
);

-- blob
   -- pointer na blob
   -- hodnota blobu
-- empty_blob() vytvori iba smernikovu strukturu, hodnota je prazdna
-- premenna typu bfile
   -- 1. arguemnt -> nazov oracle directory (vsetko velkymi pismenami)
   -- 2. argument -> nazov suboru
-- loadfromfile vytvori docasny blob
   -- je potrebne z neho urobit trvaly blob pomocou update
declare
    v_source_blob BFILE := BFILENAME('CUPAN1DIRECTORY', 'download.jpg');
    v_size_blob integer;
    v_blob BLOB := EMPTY_BLOB();
begin
    -- nacitam bfile
    DBMS_LOB.OPEN(v_source_blob, DBMS_LOB.LOB_READONLY);
    v_size_blob := DBMS_LOB.GETLENGTH(v_source_blob);
    
    -- v tabulke vytvorim prazdny BLOB
    insert into blob_table(id, nazov, subor, pripona)
     values(1, 'fotka', empty_blob(), '.jpg')
      returning subor into v_blob;
    
    -- docasny BLOB
    DBMS_LOB.LOADFROMFILE(v_blob, v_source_blob, v_size_blob);

    DBMS_LOB.CLOSE(v_source_blob);
    
    -- urobim z neho trvaly BLOB
       -- ulozim ho do tabulky
    update blob_table
     set subor = v_blob
      where id = 1;
end;
/

select *
 from blob_table;

-- objednavky
create table objednavky (
    id_zak number(*,0), 
    meno_zak varchar2(20 char), 
    id_obj number(*,0), 
    id_prod number(*,0), 
    nazov_prod varchar2(20 char), 
    mnozstvo number
);

create table objednavky2 (
    id_zak number(*,0), 
    meno_zak varchar2(20 char), 
    id_obj number(*,0), 
    id_prod number(*,0), 
    nazov_prod varchar2(20 char), 
    mnozstvo number
);

REM INSERTING into OBJEDNAVKY
SET DEFINE OFF;
Insert into OBJEDNAVKY (ID_ZAK,MENO_ZAK,ID_OBJ,ID_PROD,NAZOV_PROD,MNOZSTVO) values ('50042','Peter Sedlacek','421','4280','Tehly-paleta','110');
Insert into OBJEDNAVKY (ID_ZAK,MENO_ZAK,ID_OBJ,ID_PROD,NAZOV_PROD,MNOZSTVO) values ('50042','Peter Sedlacek','421','6520','Dlazobne kocky','140');

REM INSERTING into OBJEDNAVKY2
SET DEFINE OFF;
Insert into OBJEDNAVKY2 (ID_ZAK,MENO_ZAK,ID_OBJ,ID_PROD,NAZOV_PROD,MNOZSTVO) values ('51069','Emil Krsak','422','4280','Tehly-paleta','80');
Insert into OBJEDNAVKY2 (ID_ZAK,MENO_ZAK,ID_OBJ,ID_PROD,NAZOV_PROD,MNOZSTVO) values ('51069','Emil Krsak','422','6520','Dlazobne kocky','80');
Insert into OBJEDNAVKY2 (ID_ZAK,MENO_ZAK,ID_OBJ,ID_PROD,NAZOV_PROD,MNOZSTVO) values ('50741','Stefan Toth','423','4280','Tehly-paleta','60');
Insert into OBJEDNAVKY2 (ID_ZAK,MENO_ZAK,ID_OBJ,ID_PROD,NAZOV_PROD,MNOZSTVO) values ('50741','Stefan Toth','423','6520','Dlazobne kocky','40');

ALTER TABLE OBJEDNAVKY MODIFY (MENO_ZAK NOT NULL ENABLE);
ALTER TABLE OBJEDNAVKY MODIFY (ID_PROD NOT NULL ENABLE);
ALTER TABLE OBJEDNAVKY MODIFY (NAZOV_PROD NOT NULL ENABLE);
ALTER TABLE OBJEDNAVKY MODIFY (MNOZSTVO NOT NULL ENABLE);

ALTER TABLE OBJEDNAVKY2 MODIFY (MENO_ZAK NOT NULL ENABLE);
ALTER TABLE OBJEDNAVKY2 MODIFY (ID_PROD NOT NULL ENABLE);
ALTER TABLE OBJEDNAVKY2 MODIFY (NAZOV_PROD NOT NULL ENABLE);
ALTER TABLE OBJEDNAVKY2 MODIFY (MNOZSTVO NOT NULL ENABLE);

-- skladove zasoby
CREATE TABLE skladove_zasoby (
    id number(*,0), 
    produkt_id number(*,0), 
    nazov varchar2(20 char), 
    id_nakupu number(*,0), 
    datum_nakupu date, 
    id_lokality number(*,0), 
    sklad number(*,0), 
    regal varchar2(1), 
    pozicia number(*,0), 
    mnozstvo number
);

REM INSERTING into SKLADOVE_ZASOBY
SET DEFINE OFF;
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1379','7870','Piesok','760',to_date('29.08.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'2','1','A','2','39');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1466','4160','Skridla','776',to_date('22.12.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'3','1','A','3','48');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1421','4280','Tehly-paleta','767',to_date('23.10.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'4','1','A','4','37');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1394','5310','Cement','762',to_date('24.09.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'5','1','A','5','48');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1196','5430','Fasadna omietka','728',to_date('25.02.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'9','1','A','9','41');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1289','7790','Malta','744',to_date('28.05.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'12','1','A','12','48');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1217','4040','Porobetonove kocky','731',to_date('21.03.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'13','1','A','13','48');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1262','6520','Dlazobne kocky','739',to_date('26.04.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'16','1','A','16','48');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1448','5310','Cement','772',to_date('24.11.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'17','1','A','17','48');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1361','4160','Skridla','756',to_date('22.08.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'18','1','A','18','48');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1151','7870','Piesok','719',to_date('19.12.2017 00:00:00','DD.MM.YYYY HH24:MI:SS'),'23','1','A','23','48');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1343','7790','Malta','754',to_date('28.07.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'24','1','A','24','3');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1271','4040','Porobetonove kocky','741',to_date('21.05.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'25','1','A','25','5');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1295','7950','Doska','745',to_date('31.05.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'27','1','A','27','48');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1163','5310','Cement','722',to_date('24.01.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'28','1','A','28','41');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1316','6520','Dlazobne kocky','729',to_date('26.02.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'29','1','A','29','14');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1415','4160','Skridla','766',to_date('22.10.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'30','1','A','30','48');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1349','7950','Doska','755',to_date('31.07.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'34','1','B','2','39');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1382','7870','Piesok','760',to_date('29.08.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'39','1','B','7','48');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1340','6600','Mineralna vata','753',to_date('27.07.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'40','1','B','8','16');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1199','5430','Fasadna omietka','728',to_date('25.02.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'46','1','B','14','48');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1436','7870','Piesok','770',to_date('29.10.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'51','1','B','19','42');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1184','4160','Skridla','726',to_date('22.02.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'53','1','B','21','29');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1253','5430','Fasadna omietka','738',to_date('25.04.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'58','1','B','26','44');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1346','7790','Malta','754',to_date('28.07.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'61','1','B','29','48');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1274','4040','Porobetonove kocky','741',to_date('21.05.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'62','1','B','30','48');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1457','7950','Doska','775',to_date('30.11.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'63','1','B','31','6');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1478','6520','Dlazobne kocky','779',to_date('26.12.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'64','1','B','32','43');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1193','4280','Tehly-paleta','727',to_date('23.02.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'65','1','C','1','36');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1418','4160','Skridla','766',to_date('22.10.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'67','1','C','3','48');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1319','6520','Dlazobne kocky','749',to_date('26.06.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'69','1','C','5','70');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1166','5310','Cement','722',to_date('24.01.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'71','1','C','7','48');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1400','7790','Malta','764',to_date('28.09.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'73','1','C','9','7');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1328','4040','Porobetonove kocky','751',to_date('21.07.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'74','1','C','10','3');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1352','7950','Doska','755',to_date('31.07.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'76','1','C','12','48');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1205','6520','Dlazobne kocky','729',to_date('26.02.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'77','1','C','13','20');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1220','5310','Cement','732',to_date('24.03.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'82','1','C','18','44');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1454','7790','Malta','774',to_date('28.11.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'85','1','C','21','31');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1439','7870','Piesok','770',to_date('29.10.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'87','1','C','23','48');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1406','7950','Doska','765',to_date('30.09.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'88','1','C','24','42');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1397','6600','Mineralna vata','763',to_date('27.09.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'89','1','C','25','19');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1187','4160','Skridla','726',to_date('22.02.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'90','1','C','26','48');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1256','5430','Fasadna omietka','738',to_date('25.04.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'95','1','C','31','48');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1460','7950','Doska','775',to_date('30.11.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'100','1','D','4','48');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1451','6600','Mineralna vata','773',to_date('27.11.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'101','1','D','5','8');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1241','4160','Skridla','736',to_date('22.04.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'102','1','D','6','31');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1310','5430','Fasadna omietka','748',to_date('25.06.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'107','1','D','11','40');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1403','7790','Malta','764',to_date('28.09.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'110','1','D','14','48');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1208','7870','Piesok','730',to_date('28.02.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'111','1','D','15','41');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1331','4040','Porobetonove kocky','751',to_date('21.07.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'112','1','D','16','48');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1250','4280','Tehly-paleta','737',to_date('23.04.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'114','1','D','18','39');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1376','6520','Dlazobne kocky','759',to_date('26.08.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'115','1','D','19','48');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1223','5310','Cement','732',to_date('24.03.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'116','1','D','20','48');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1385','4040','Porobetonove kocky','761',to_date('21.09.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'123','1','D','27','7');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1409','7950','Doska','765',to_date('30.09.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'125','1','D','29','48');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1277','5310','Cement','742',to_date('24.05.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'126','1','D','30','40');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1190','4160','Skridla','726',to_date('22.02.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'127','1','D','31','48');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1430','6520','Dlazobne kocky','769',to_date('26.10.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'129','2','A','1','72');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1172','7790','Malta','724',to_date('28.01.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'133','2','A','5','6');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1244','4160','Skridla','736',to_date('22.04.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'139','2','A','11','48');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1472','5430','Fasadna omietka','778',to_date('25.12.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'143','2','A','15','6');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1313','5430','Fasadna omietka','748',to_date('25.06.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'144','2','A','16','48');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1211','7870','Piesok','730',to_date('28.02.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'147','2','A','19','48');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1178','7950','Doska','725',to_date('31.01.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'148','2','A','20','41');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1169','6600','Mineralna vata','723',to_date('27.01.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'149','2','A','21','19');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1298','4160','Skridla','746',to_date('22.06.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'151','2','A','23','27');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1367','5430','Fasadna omietka','758',to_date('25.08.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'156','2','A','28','39');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1265','7870','Piesok','740',to_date('29.04.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'158','2','A','30','44');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1388','4040','Porobetonove kocky','761',to_date('21.09.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'160','2','A','32','48');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1307','4280','Tehly-paleta','747',to_date('23.06.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'163','2','B','3','35');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1280','5310','Cement','742',to_date('24.05.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'164','2','B','4','48');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1433','6520','Dlazobne kocky','729',to_date('26.02.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'165','2','B','5','14');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1175','7790','Malta','724',to_date('28.01.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'170','2','B','10','48');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1442','4040','Porobetonove kocky','771',to_date('21.11.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'172','2','B','12','31');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1334','5310','Cement','752',to_date('24.07.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'175','2','B','15','39');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1247','4160','Skridla','736',to_date('22.04.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'176','2','B','16','48');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1154','7950','Doska','720',to_date('20.12.2017 00:00:00','DD.MM.YYYY HH24:MI:SS'),'179','2','B','19','36');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1475','5430','Fasadna omietka','778',to_date('25.12.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'180','2','B','20','48');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1229','7790','Malta','734',to_date('28.03.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'182','2','B','22','8');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1157','4040','Porobetonove kocky','721',to_date('21.01.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'183','2','B','23','6');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1181','7950','Doska','725',to_date('31.01.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'185','2','B','25','48');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1202','6520','Dlazobne kocky','729',to_date('26.02.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'186','2','B','26','24');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1301','4160','Skridla','746',to_date('22.06.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'188','2','B','28','48');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1370','5430','Fasadna omietka','758',to_date('25.08.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'193','2','C','1','48');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1268','7870','Piesok','740',to_date('29.04.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'196','2','C','4','48');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1235','7950','Doska','735',to_date('31.03.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'197','2','C','5','44');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1226','6600','Mineralna vata','733',to_date('27.03.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'198','2','C','6','21');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1469','4280','Tehly-paleta','777',to_date('23.12.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'199','2','C','7','19');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1355','4160','Skridla','756',to_date('22.08.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'200','2','C','8','26');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1424','5430','Fasadna omietka','768',to_date('25.10.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'205','2','C','13','42');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1481','7870','Piesok','780',to_date('29.12.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'208','2','C','16','6');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1322','7870','Piesok','750',to_date('29.06.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'209','2','C','17','40');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1364','4280','Tehly-paleta','757',to_date('23.08.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'212','2','C','20','34');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1337','5310','Cement','752',to_date('24.07.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'215','2','C','23','48');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1232','7790','Malta','734',to_date('28.03.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'219','2','C','27','48');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1160','4040','Porobetonove kocky','721',to_date('21.01.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'220','2','C','28','48');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1373','6520','Dlazobne kocky','759',to_date('26.08.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'223','2','C','31','21');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1463','4160','Skridla','776',to_date('22.12.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'224','2','C','32','30');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1304','4160','Skridla','746',to_date('22.06.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'225','2','D','1','48');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1391','5310','Cement','762',to_date('24.09.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'227','2','D','3','42');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1286','7790','Malta','744',to_date('28.05.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'231','2','D','7','5');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1214','4040','Porobetonove kocky','731',to_date('21.03.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'232','2','D','8','8');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1259','6520','Dlazobne kocky','739',to_date('26.04.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'233','2','D','9','26');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1238','7950','Doska','735',to_date('31.03.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'234','2','D','10','48');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1445','5310','Cement','772',to_date('24.11.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'236','2','D','12','6');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1358','4160','Skridla','756',to_date('22.08.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'237','2','D','13','48');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1427','5430','Fasadna omietka','768',to_date('25.10.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'242','2','D','18','48');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1148','7870','Piesok','719',to_date('19.12.2017 00:00:00','DD.MM.YYYY HH24:MI:SS'),'244','2','D','20','11');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1484','7870','Piesok','780',to_date('29.12.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'245','2','D','21','48');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1325','7870','Piesok','750',to_date('29.06.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'246','2','D','22','48');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1283','6600','Mineralna vata','743',to_date('27.05.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'247','2','D','23','17');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1412','4160','Skridla','766',to_date('22.10.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'249','2','D','25','29');
Insert into SKLADOVE_ZASOBY (ID,PRODUKT_ID,NAZOV,ID_NAKUPU,DATUM_NAKUPU,ID_LOKALITY,SKLAD,REGAL,POZICIA,MNOZSTVO) values ('1292','7950','Doska','745',to_date('31.05.2018 00:00:00','DD.MM.YYYY HH24:MI:SS'),'252','2','D','28','40');

ALTER TABLE SKLADOVE_ZASOBY MODIFY (PRODUKT_ID NOT NULL ENABLE);
ALTER TABLE SKLADOVE_ZASOBY MODIFY (NAZOV NOT NULL ENABLE);
ALTER TABLE SKLADOVE_ZASOBY MODIFY (ID_NAKUPU NOT NULL ENABLE);
ALTER TABLE SKLADOVE_ZASOBY MODIFY (DATUM_NAKUPU NOT NULL ENABLE);
ALTER TABLE SKLADOVE_ZASOBY MODIFY (ID_LOKALITY NOT NULL ENABLE);
ALTER TABLE SKLADOVE_ZASOBY MODIFY (SKLAD NOT NULL ENABLE);
ALTER TABLE SKLADOVE_ZASOBY MODIFY (REGAL NOT NULL ENABLE);
ALTER TABLE SKLADOVE_ZASOBY MODIFY (POZICIA NOT NULL ENABLE);
ALTER TABLE SKLADOVE_ZASOBY MODIFY (MNOZSTVO NOT NULL ENABLE);

select *
 from objednavky;
 
select *
 from objednavky2;

select *
 from skladove_zasoby;
 
-- poziadavka, tovar, odkial, kolko mam
-- funkcia sum pouzita ako analyticka funkcia
   -- window clause (lava a prava hranica)
      -- rows between
      -- range between
-- z current row nemusim brat cele mnozstvo
select produkt_id, nazov, obj_mn, skl_mn, sklad, regal, pozicia, datum_nakupu,
    kum_suma + least(skl_mn, obj_mn - kum_suma)
 from
(
    select s.produkt_id, s.nazov, o.mnozstvo as obj_mn, s.mnozstvo as skl_mn, s.sklad, s.regal, s.pozicia, s.datum_nakupu,
        sum(s.mnozstvo) 
         over (partition by s.produkt_id
                order by s.datum_nakupu
                 rows between unbounded preceding and 1 preceding) as kum_suma
     from objednavky o
      join skladove_zasoby s on (o.id_prod = s.produkt_id)
       order by produkt_id, datum_nakupu
)
 where obj_mn >= kum_suma;
 
select produkt_id, nazov, obj_mn, skl_mn, sklad, regal, pozicia, datum_nakupu,
    kum_suma + least(skl_mn, obj_mn - kum_suma),
    dense_rank() over
     (order by sklad, regal) as d_rank
 from
(
    select s.produkt_id, s.nazov, o.mnozstvo as obj_mn, s.mnozstvo as skl_mn, s.sklad, s.regal, s.pozicia, s.datum_nakupu,
        sum(s.mnozstvo) 
         over (partition by s.produkt_id
                order by s.datum_nakupu
                 rows between unbounded preceding and 1 preceding) as kum_suma
     from objednavky o
      join skladove_zasoby s on (o.id_prod = s.produkt_id)
       order by produkt_id, datum_nakupu
)
 where obj_mn >= kum_suma
  order by sklad, regal, case
                          when mod(d_rank, 2) = 1 then pozicia
                          else -pozicia
                         end;
                         
select produkt_id, nazov, obj_mn, skl_mn, sklad, regal, pozicia, datum_nakupu,
    kum_suma + least(skl_mn, obj_mn - kum_suma),
    dense_rank() over
     (partition by sklad
       order by sklad, regal) as d_rank
 from
(
    select s.produkt_id, s.nazov, o.mnozstvo as obj_mn, s.mnozstvo as skl_mn, s.sklad, s.regal, s.pozicia, s.datum_nakupu,
        sum(s.mnozstvo) 
         over (partition by s.produkt_id
                order by s.datum_nakupu
                 rows between unbounded preceding and 1 preceding) as kum_suma
     from objednavky o
      join skladove_zasoby s on (o.id_prod = s.produkt_id)
       order by produkt_id, datum_nakupu
)
 where obj_mn >= kum_suma
  order by sklad, regal, case
                          when mod(d_rank, 2) = 1 then pozicia
                          else -pozicia
                         end;

-- vytvorit rovnaky select, ale pre tabulku objednavky2
   -- kolko tovarov beriem celkovo
   -- rozdelene kolko beriem na ktoru obejdnavku
   -- 5 ... 5/0 
   -- 7 ... 12/0
   -- 6 ... 15/3
   -- az kym nepokryjem obe objednavky
   -- agregovane alebo kolko beriem

-- rozdelit tabulku student po 10 studentov na jednotlive terminy
   -- vopred definovana velkost skupiny, neobmedzeny pocet skupin
select meno, priezvisko, rod_cislo, ceil(poradie / 10) as termin
 from
(
select meno, priezvisko, rod_cislo, row_number() over (order by rod_cislo) as poradie
 from student
  join os_udaje using (rod_cislo)
);

-- studenti rozdeleni na 10 skupin, vopred definovany pocet skupin
select meno, priezvisko, rod_cislo, mod(poradie, 10)
 from
(
select meno, priezvisko, rod_cislo, row_number() over (order by rod_cislo) as poradie
 from student
  join os_udaje using (rod_cislo)
);

-- rozdelit studentov do skupin (vopred nepoznam)
   -- zaroven zabezpecit, aby boli rozdeleni rovnomerne