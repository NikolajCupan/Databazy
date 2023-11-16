-- cisla od 1 do 12
-- tabulka musi mat aspon 12 zaznamov
select rownum
 from student
  where rownum <= 12;

-- connect by level
   -- standardne v kombinacii s tabulkou dual
-- tabulku dual pouzijem 1000000-krat
-- v podstate kartezsky sucin
select rownum
 from dual
  connect by level <= 1000000;

-- vygenerovanie kalendaru
   -- level ide pouzit aj v klauzule select
select trunc(sysdate, 'YYYY') + level - 1
 from dual
  connect by level <= 365;

select trunc(sysdate, 'YYYY') + level - 1
 from dual
  connect by level <= (select 365
                        from dual);

-- berie do uvahy aj priestupne roky
select trunc(sysdate, 'YYYY') + level - 1
 from dual
  connect by level <= (select add_months(trunc(sysdate, 'YYYY'), 12) - trunc(sysdate, 'YYYY')
                        from dual);

-- rekurzivny vztah
   -- vzdy neidentifikacny vztah
create table person_rec (
    person_id integer primary key,
    name varchar2(20), 
    surname varchar2(20),
    mother_id integer, 
    father_id integer
);

alter table person_rec add foreign key (mother_id)
 references person_rec(person_id);

alter table person_rec add foreign key (father_id)
 references person_rec(person_id);

insert into person_rec values(1,'Emily','Burney',null,null);
insert into person_rec values(2,'Adam','Smith',null,null);
insert into person_rec values(3,'Grace','Smith',1,2);
insert into person_rec values(4,'Daniel','Phue',null,null);
insert into person_rec values(5,'Harry','Smith',1,2);
insert into person_rec values(6,'Olivia','Clarke',null,null);
insert into person_rec values(7,'Bella','Smith',1,2);
insert into person_rec values(8,'Peter','Roger',null,null);
insert into person_rec values(9,'James','Smith',6,5);
insert into person_rec values(10,'Sofia','Smith',6,5);
insert into person_rec values(11,'Lautaro','Smith',6,5);
insert into person_rec values(12,'Jack','Robinson',null,null);
insert into person_rec values(13,'Jacob','Robinson',10,12);
insert into person_rec values(14,'William','Robinson',10,12);

-- vypisat ku kazdej osobe surodenca
   -- where podmienka na zabranenie tomu, aby sa osoba spojila sama so sebou
select osoba.name, osoba.surname, surodenec.name, surodenec.surname
 from person_rec osoba
  join person_rec surodenec using (mother_id)
   where osoba.person_id > surodenec.person_id;
   
-- vypisat ku kazdej osobe matku
select osoba.name, osoba.surname, matka.name, matka.surname
 from person_rec osoba
  left join person_rec matka on (osoba.mother_id = matka.person_id);

-- vypisat ku kazdej osobe staru matku
   -- hierarchia rodokmena
-- v connect by prior definujem podla coho sa buduje hierarchia
   -- primarny a cudzi kluc
   -- na poradi atributov zalezi

-- vrchna uroven matka, nizsie urovne deti
select lpad(' ', 2 * level) || name || ' ' || surname
 from person_rec
  connect by prior person_id = mother_id;

-- vrchna uroven deti, nizsie urovne matka
select lpad(' ', 2 * level) || name || ' ' || surname
 from person_rec
  connect by prior mother_id = person_id;

-- iba konkretny podstrom
select lpad(' ', 2 * level) || name || ' ' || surname
 from person_rec
  start with person_id = 5
   connect by prior mother_id = person_id;

-- kandidat primarneho kluca splna vsetky podmienky primarneho kluca
   -- unikatny
   -- minimalny
   -- not null
create table t_zam (
    rod_cislo char(11) primary key, 
    login varchar(20) not null unique, 
    meno varchar(20),
    priezvisko varchar(20),
    id_oddelenie integer not null
); 

create table t_oddelenie (
    id_oddelenie integer primary key, 
    nazov varchar(20) not null, 
    veduci varchar(20) not null
);

alter table t_zam
 add foreign key (id_oddelenie) references t_oddelenie (id_oddelenie);

alter table t_oddelenie
 add foreign key (veduci) references t_zam (login);

-- vlastnosti cudzieho kluca
   -- moze nadobudnut hodnoty
      -- hodnota primarneho kluca
      -- null
   -- moze sa odkazovat na akykolvek unikatny atribut, nie len na primarny kluc
      -- t. j. kandidat primarneho kluca

-- tabulky maju medzi sebou vzajomny vztah
   -- nie je mozne vlozit zaznam do ani jednej z nich
-- odlozim kontrolu referencnej integrity na koniec transakcie
select constraint_name
 from user_constraints
  where table_name = 'T_ZAM'
   and constraint_type = 'R';
   
alter table t_zam
 drop constraint SYS_C00139467;
 
select constraint_name
 from user_constraints
  where table_name = 'T_ODDELENIE'
   and constraint_type = 'R';
   
alter table t_oddelenie
 drop constraint SYS_C00139468;

alter table t_zam
 add foreign key (id_oddelenie) references t_oddelenie (id_oddelenie)
  deferrable;

alter table t_oddelenie
 add foreign key (veduci) references t_zam (login)
  deferrable;

-- vlozenie zaznamov
insert into t_zam
 values ('123456/1234', 'Cupan', 'Nikolaj', 'Cupan', 1);
 
-- nutne upravit session, aby to povolila
alter session
 set constraints = deferred;
 
insert into t_zam
 values ('123456/1234', 'Cupan', 'Nikolaj', 'Cupan', 1);

insert into t_oddelenie
 values (1, 'KI', 'Cupan');
 
-- ukoncim transakciu
   -- vykona sa kontrola referencnej integrity
commit;

insert into t_zam
 values ('123456/1235', 'Cupan2', 'Nikolaj', 'Cupan', 2);

insert into t_zam
 values ('123456/1236', 'Cupan3', 'Nikolaj', 'Cupan', 3);
 
insert into t_oddelenie
 values (2, 'KMMOA', 'Cupan2');

-- narusenie referencnej integrity
   -- nevykona sa commit, ale rollback
   -- cela transakcia sa zrusi, v tabulkach mam povodne zaznamy
-- vzdy sa vykona bud cela transakcia alebo sa transakcia nevykona vobec
   -- nemoze sa vykonat iba cast transakcie
commit;

-- databazovy link
   -- odkaz na inu databazu
-- premenna prostredia
   -- nazov TNS_ADMIN
   -- odkazuje na adresar, kde sa nachadza subor tnsnames.ora
-- odkaz na vzdialenu tabulku
   -- za nazvom tabulky '@<nazov_db_linku>'
   -- napriklad os_udaje@db_link
-- v 1 SQL prikaze mozno kombinovat vzdialene a lokalne pripojenie
   -- tzv. distribuovana transakcia

-- Bonusova uloha:
-- vytvorit hierarchiu fakulty
-- vypisat hierarchiu pre katedru informatiky
   -- od tejto katedry nahor