-- objekt
   -- atributy
      -- primitivne
      -- objektove
   -- metody
create type t_kniha as object
(
    nazov varchar2(30),
    zaner varchar2(30),
    vydavatelstvo varchar2(30),
    rok_vydania integer
);
/

-- uprava objektu
-- funkcie maju vzdy navratovu hodnotu
-- v tomto pripade sa neuvadza kolko ma varchar znakov
alter type t_kniha
 add member function vypis return varchar;
/
 
-- vytvorenie tela
-- objekt je na iny objekt zavisly vzdy cez hlavicku
-- rpad
   -- 1. parameter: co chcem vypisat
   -- 2. parameter: kolko znakov
create or replace type body t_kniha
is
    member function vypis return varchar
    is
    begin
        return rpad(nazov, 20) || rpad(zaner, 20) ||
               rpad(vydavatelstvo, 20) || rok_vydania;
    end;
end;
/

-- praca s objektom v ramci tabuliek
   -- tabulka objektov
   -- tabulka, kde je objekt ako atribut
-- praca s objektmi v ramci bloku prikazov
declare
    v_kniha t_kniha;
    v_vysledok varchar2(250);
    v_vysledok2 varchar2(250);
begin
    -- objekt vytvorim zavolanim konstruktora
    -- parametre v poradi ako su definovane (implicitny konstruktor)
    v_kniha := t_kniha('Zaklinac', 'fantasy', 'Leonardo', 2017);
    v_vysledok := v_kniha.vypis();
    dbms_output.put_line(v_vysledok);
    
    -- iny sposob volania funkcie
    -- volanie v klauzule select into
    select v_kniha.vypis() into v_vysledok2
     from dual;
    dbms_output.put_line(v_vysledok2);
end;
/

-- tabulka objektov
-- nie je nutne definovat strukturu tabulky
   -- struktura sa preberie zo samotneho objektu
create table kniha_tab of t_kniha;

-- tvari sa rovnako ako obycajna relacna tabulka
desc kniha_tab;
select * from kniha_tab;

-- zadefinujem primarny kluc pre tabulku
alter table kniha_tab
 add constraint kniha_tab_pk primary key (nazov);
 
-- nelisi sa od klasickeho insertu, hoci ide o tabulku objektov
insert into kniha_tab
 values ('PDBS', 'Ucebnica', 'edis', 2020);
 
-- mozno vlozit aj pomocou konstruktora
insert into kniha_tab
 values (t_kniha('DO', 'Ucebnica', 'edis', 2007));
 
select nazov
 from kniha_tab;
 
-- ziskam samotny objekt a zavolam metodu
select value(k).vypis()
 from kniha_tab k;
 
-- mozem pristupovat aj k atributom objektu
select value(k).zaner
 from kniha_tab k;
 
-- vrati objekt
select value(k)
 from kniha_tab k;
 
-- triedenie podla atributu
select *
 from kniha_tab
  order by zaner;
  
-- triedenie podla objektu
-- najskor musim metodu na triedenie zadefinovat v objekte
select *
 from kniha_tab k
  order by value(k);
  
-- dve moznosti triedenia pri objektoch
   -- map -> nema parameter, vracia typ, ktory sa da lahko zoradit
   -- order by -> parameter je iny objekt, s ktorym porovnavam self objekt, vracia 1, 0, -1
-- pridam funkciu map
-- nejde to urobit nakolko iny objekt je na nom zavisly
   -- existuje tabulka objektov
alter type t_kniha
 add map member function tried return integer;
/

-- toto funguje
alter type t_kniha
 add map member function tried return integer
  cascade;
/

-- upravim telo
create or replace type body t_kniha
is
    member function vypis return varchar
    is
    begin
        return rpad(nazov, 20) || rpad(zaner, 20) ||
               rpad(vydavatelstvo, 20) || rok_vydania;
    end;
    
    map member function tried return integer
    is
        poradie integer;
    begin
        -- sposob akym ziskam vysledok metody je lubovolny
        select case lower(zaner)
                when 'ucebnica' then 1
                when 'e-book' then 2
                else 3
               end into poradie
         from dual;
        
        return poradie || ascii(nazov);
    end;
end;
/

-- teraz uz mozem triedit podla objektu
select *
 from kniha_tab k
  order by value(k);
  
-- dedicnost
-- t_ebook je potomkom t_kniha
-- objekt je defaultne final => nemoze mat potomkov
   -- musim explicitne zadefinovat, ze objekt moze mat potomkov
-- zmenim t_kniha na not final
alter type t_kniha 
 not final
  cascade;
/

create type t_ebook under t_kniha
(
    format char(4)
);

-- overriding -> pretazena metoda
alter type t_ebook
 add overriding member function vypis return varchar;
/

create or replace type body t_ebook
is
    overriding member function vypis return varchar
    is
    begin
        -- zavolam metodu predka
        -- pretypujem sameho seba na predka
        return (self as t_kniha).vypis() || format ;
    end;
end;
/

-- poradie parametrov: najskor predok, potom potomok
-- insert da chybu, hoci by mal prejst
   -- jedna sa o bug
   -- t_kniha bola definovana ako final a az neskor zmenena na not final
insert into kniha_tab
 values (t_ebook('Harry Potter', 'Fantasy', 'edis', 2023, 'PDF'));
 
-- nova tabulka
create table kniha_tab2 of t_kniha;

insert into kniha_tab2
 select value(k)
  from kniha_tab k;

insert into kniha_tab2
 values (t_ebook('Harry Potter', 'Fantasy', 'edis', 2023, 'PDF'));
 
-- order je zdedeny
select value(k).vypis()
 from kniha_tab2 k
  order by value(k);

-- nutne pretypovat na potomka, ak chcem atribut potomka
select k.*, treat(value(k) as t_ebook).format as format
 from kniha_tab2 k
  order by value(k);
  
-- vypise vsetky, pretoze aj t_ebook je t_kniha
select k.*, treat(value(k) as t_ebook).format as format
 from kniha_tab2 k
  where value(k) is of (t_kniha)
   order by value(k);
   
select k.*, treat(value(k) as t_ebook).format as format
 from kniha_tab2 k
  where value(k) is of (only t_kniha)
   order by value(k);
   
-- tabulka s objektovym atributom
create table kniha_tab_atr
(
    id integer,
    kniha t_kniha
);

-- auto-inkrement = sekvencia + trigger
create sequence seq_kniha;

insert into kniha_tab_atr
 select seq_kniha.nextval, value(k)
  from kniha_tab2 k;
  
-- neukaze jednotlive atributu objektu, ale samotny objekt
   -- rozdiel od tabulky objektov
select *
 from kniha_tab_atr;
 
-- nie je nutne pouzit value(), ale pouzijem priamo objektovy atribut
select *
 from kniha_tab_atr
  order by kniha;
  
-- spristupnenie atributu objektoveho atributu
-- nutne pouzit alias tabulky
   -- pri praci s objektami je najlepsie vzdy pouzivat alias tabulky
select k.kniha.nazov
 from kniha_tab_atr k;
 
-- mozne zavolat aj metodu
select id, k.kniha.zaner, k.kniha.rok_vydania, k.kniha.vypis()
 from kniha_tab_atr k;