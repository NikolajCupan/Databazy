-- pripojenie cez sqlplus
   -- cupan1@"obelix.fri.uniza.sk:1521/orcl.fri.uniza.sk"
   -- <heslo>

-- obnovenie tabulky do stavu v minulosti
   -- aj po commite
   -- funguje na zaklade transakcnych logov
      -- aby sa tabulka dala obnovit musia existovat
flashback table student to timestamp sysdate - 1;

-- nutne povolit zmenu row id
   -- pri zmene row id sa vsetky indexy stavaju unusable
alter table student enable row movement;

-- zmena struktury tabulky => nemozny flashback
   -- napriklad pridany atribut

-- zobrazenie stavu tabulky v minulosti
   -- realne sa nemeni to co v nej je
select *
 from student
  as of timestamp sysdate - interval '5' minute;

-- nova tabulka
create table moja_zaloha as
 select *
  from os_udaje;

-- po drope tabulky nemozem obnovit
   -- ani pomocou transakcnych logov
drop table moja_zaloha;

-- drop premenuje tabulku a vlozi ju do recycle bin
select original_name, object_name
 from recyclebin
  where original_name = 'MOJA_ZALOHA';

-- nad tabulkou v kosi nemozem robit zmenove operacie
   -- select vykonat mozem
select *
 from "BIN$VndTWX2dTdWON7VsPFsewg==$0";
 
-- obnovenie tabulky z kosa
flashback table moja_zaloha to before drop;

select *
 from moja_zaloha;

drop table moja_zaloha;

-- obnovim tabulku a zaroven ju aj premenujem
flashback table moja_zaloha to before drop rename to obnovena;

select *
 from obnovena;

-- tabulka je vymazana uplne
   -- nie je v kosi
drop table obnovena purge;

show recyclebin;

-- vyprazdnenie kosa
purge recyclebin;

-- v kosi moze byt viacero tabuliek s rovnakym nazvom
-- ako prva sa obnovi ta, ktora bola odstranena naposledy

-- obnovovanie celych tabuliek nepouziva logicky zurnal
-- obnovovanie dat z tabuliek pouziva logicky zurnal
   -- undo a redo
   -- logy

-- praca s transakciami
create table moja_zaloha (
    id integer
);

create or replace procedure vloz
    (id integer)
is
begin
    insert into moja_zaloha
     values (id);
end;
/

-- vlozim data do tabulky
begin
    for i in  1..5
    loop
        insert into moja_zaloha
         values (i);

        vloz(-i);
    end loop;
end;
/

-- v tabulke je 10 zaznamov
-- v inej session by bolo vidiet 0 zaznamov
   -- transakcia nie je potvrdena
   -- vlastnost izolovanosti
select *
 from moja_zaloha;

-- po commite budu data viditelne aj z inych session
commit;

-- uprava anonymneho bloku
begin
    for i in  1..5
    loop
        insert into moja_zaloha
         values (i);
        rollback;

        vloz(-i);
        commit;
    end loop;
end;
/

-- 5 hodnot
commit;
select *
 from moja_zaloha;
 
create or replace procedure vloz2
    (id integer)
is
begin
    insert into moja_zaloha
     values (id);
    rollback;
end;
/

begin
    for i in  1..5
    loop
        insert into moja_zaloha
         values (i);
        rollback;

        vloz2(-i);
        commit;
    end loop;
end;
/

-- 0 zaznamov
-- tzv. hniezdena transakcia
   -- zasahuje aj do PL SQL
-- vloz2(-i) sa v podstate nahradi s:
   -- insert...
   -- rollback
select *
 from moja_zaloha;
 
-- opakom je autonomna transakcia
   -- procedura si vytvori novy transakciu nezavislu od hlavnej
   -- nie je ovplyvnena hlavnou transakciou
-- ak pouzijem pragma autonomous_transaction, tak na konci procedury musim pouzit rollback alebo commit
   -- inak nastane vynimka
   -- transakcia musi byt ukoncena
create or replace procedure vloz3
    (id integer)
is
    pragma autonomous_transaction;
begin
    insert into moja_zaloha
     values (id);
    rollback;
end;
/

begin
    for i in  1..5
    loop
        insert into moja_zaloha
         values (i);
        vloz3(-i);
        commit;
    end loop;
end;
/

-- 5 zaznamov
   -- procedura nemala vplyv na hlavnu transakciu
select *
 from moja_zaloha;

-- napojenie na obelix orcladm
-- student01/student01@"obelix.fri.uniza.sk:1522/orcladm.fri.uniza.sk"
--           ^^^^^^^^^
--           heslo

-- vytvorenie pouzivatela
create user nikolaj
 identified by heslo;

-- prihlasenie
-- connect nikolaj@"obelix.fri.uniza.sk:1522/orcladm.fri.uniza.sk"
-- <heslo>

-- novy pouzivatel nema pravo na prihlasenie
grant connect to nikolaj;

-- with admin option
   -- pouzivatel s tymto pravom moze pravo udelovat aj dalej
   -- systemove prava
-- with grant option
   -- tabulkove prava
-- ak chcem dat pravo vsetkym tak pouzijem to public
grant resource to nikolaj
 with admin option;

-- pridelenie kvoty
   -- pouzivatel musi mat pridelene miesto, kde moze tabulky vytvarat
grant unlimited tablespace to nikolaj;

-- zrusenie pouzivatela
   -- ruseny pouzivatel nemoze byt prihlaseny
drop user nikolaj;

-- stale nejde zrusit, nakolko pouzivatel uz ma nejake objekty
   -- takto zrusim najskor jeho objekty a potom samotneho pouzivatela
drop user nikolaj
 cascade;

-- uloha
   -- 1. vytvorim pouzivatela
   -- 2. pridelim mu prava
   -- 3. vytvorim tabulku
   -- 4. tabulku naplnim datami
   -- 5. prihlasim sa na asterix
   -- 6. do tabulky na asterixe ziskam data zo vzdialeneho servera
   -- 7. nutne vytvorit database link -> student01 - 10

-- databazovy link
create database link db_link_student
 connect to student10
  identified by student10
   using '(DESCRIPTION =
            (ADDRESS = (PROTOCOL = TCP)
            (HOST = obelix.fri.uniza.sk)
            (PORT = 1522))
           (CONNECT_DATA =(SERVER = DEDICATED)  
           (SERVICE_NAME = orcladm.fri.uniza.sk)))';

create table tabulka_cas as
 select * from nikolaj.tab_cas@db_link_student;

select *
 from tabulka_cas;