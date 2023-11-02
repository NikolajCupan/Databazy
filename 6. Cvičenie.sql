-- objekt
   -- 1. hlavicka
   -- 2. telo (implementacia)
create type o_osoba as object
(
    meno varchar(20),
    priezvisko varchar(20),
    map member function tried
     return integer
);
/

create or replace type body o_osoba
is
    map member function tried
    return integer
    is
    begin
        return length(priezvisko);
    end;
end;
/

-- vytvorenie kolekcie objektov
   -- jedna sa o kolekciu typu nested table
create or replace type col_o_osoba is table of o_osoba;
/

-- vytvorenie tabulky
   -- tabulka obsahuje atribut typu kolekcia nested table
create table osoba_tab
(
    rocnik integer,
    pole col_o_osoba
) nested table pole store as col_o_osoba_nested;
/

-- do kolekcie vyskladam zoznam mien a priezvisk
   -- z mena a priezviska vytvorim objekt
      -- za pomoci (implicitneho) konstruktora
      -- NAZOV_OBJEKTU(PARAMETER_1,...)
   -- nasledne ich spojim do kolekcie
   
-- objekty
select o_osoba(meno, priezvisko)
 from os_udaje;
 
-- objekty spojim do kolekcie pomocou 2 funkcii
   -- 1. funkcia -> collect(), vrati typ anydata
   --            -> z relacnej tabulky urobim kolekciu
   -- 2. funkcia -> cast()
   --            -> pretypujem vysledok funkcie collect()
   --            -> pretypujem na typ, ktory som si zadefinoval
-- kolekcia objektov (vsetky rocniky spolu)
select cast(collect(o_osoba(meno, priezvisko)) as col_o_osoba)
 from os_udaje;

-- pre kazdy rocnik chcem osobitnu kolekciu
   -- pomocou group by
select rocnik, cast(collect(o_osoba(meno, priezvisko)) as col_o_osoba)
 from os_udaje
  join student using (rod_cislo)
   group by rocnik
    order by 1 asc;
    
-- ziskane data vlozim do tabulky
insert into osoba_tab
 select rocnik, cast(collect(o_osoba(meno, priezvisko)) as col_o_osoba)
  from os_udaje
   join student using (rod_cislo)
    group by rocnik
     order by 1 asc;

select *
 from osoba_tab;

-- transformacia kolekcie na relacnu tabulku
   -- vnoreny select musi vratit 1 tabulku
select *
 from table(select pole
            from osoba_tab
             where rocnik = 1);
             
-- vsetkym prvakom zmenim krstne meno na Michal
   -- v update pri kolekcii objektov pristupujem k jednotlivym atributom daneho objektu
   -- ak by sa jednalo o kolekciu cisel (alebo ineho primitivneho typu), tak menim hodnotu stlpca column_value
update table(select pole
             from osoba_tab
              where rocnik = 1)
 set meno = 'Michal';

-- celu kolekciu prvakov ulozim do premennej
   -- vykonam v bloku prikazov
declare
    l_pole col_o_osoba;
begin
    -- kolekciu nacitam do premennej l_pole
    select pole into l_pole
     from osoba_tab
      where rocnik = 1;
    
    -- obsah premennej vypisem
    for i in 1..l_pole.last
    loop
        -- jednotlive elementy kolekcie su objekty
           -- pristupujem k atributom objektu
        dbms_output.put_line('Student ' || l_pole(i).meno || ' ' || l_pole(i).priezvisko);
    end loop;
end;
/

-- prvky kolekcie nie je mozne priamo triedit
   -- mozem utriedit pri inserte
-- cely objekt dam do selectu, utriedim, vlozim
   -- objekt podporuje funkciu map
   -- triedim podla objektu
select cast(collect(vn.obj) as col_o_osoba)
 from
(
select o_osoba(meno, priezvisko) obj
 from os_udaje
  order by obj
) vn;

-- partition by pri analytickych funkciach je ekvivalent group by pri agregacnych funkciach
   -- pre kazdu particiu (skupinu) cisluje osobitne
-- osoba s najdlhsim priezviskom pre kazdy rocnik osobitne
   -- pre kazdy rocnik jedna osoba
select vn.meno, vn.priezvisko, vn.rocnik, vn.dlzka, vn.poradie
 from
(
select meno, priezvisko, rocnik, length(priezvisko) as dlzka, row_number() over
                                                               (partition by rocnik
                                                                order by length(priezvisko) desc) as poradie
 from os_udaje
  join student using (rod_cislo)
) vn
 where vn.poradie = 1
  order by 3 asc;
  
-- osoba s najdlhsim priezviskom pre kazdy rocnik osobitne
   -- ak vyhovuje viacero osob, tak vypisem vsetky
select vn.meno, vn.priezvisko, vn.rocnik, vn.dlzka, vn.poradie
 from
(
select meno, priezvisko, rocnik, length(priezvisko) as dlzka, rank() over
                                                               (partition by rocnik
                                                                order by length(priezvisko) desc) as poradie
 from os_udaje
  join student using (rod_cislo)
) vn
 where vn.poradie = 1
  order by 3 asc;

-- mozno urobit aj bez analytickej funkcie
   -- menej efektivne
   -- menej univerzalne
select *
 from (select meno, priezvisko, rocnik, length(priezvisko) as dlzka
        from os_udaje
         join student using (rod_cislo))
  where (rocnik, dlzka) in (select rocnik, max(length(priezvisko))
                             from os_udaje
                              join student using (rod_cislo)
                               group by rocnik)
   order by 3 asc;
        
select os_udaje.meno, os_udaje.priezvisko, student.rocnik, length(os_udaje.priezvisko)
 from os_udaje
  join student using (rod_cislo)
   join (select rocnik, max(length(priezvisko)) as najdlhsie
          from os_udaje
           join student using (rod_cislo)
            group by rocnik) vn on (length(os_udaje.priezvisko) = vn.najdlhsie
                                    and student.rocnik = vn.rocnik)
    order by 3 asc;
    
-- xml
   -- meno, priezvisko, odbor
   -- atribut osobne cislo
-- xmlelement(NAZOV_ELEMENTU, HODNOTA_ELEMENTU)
-- xmlroot kontroluje, ci je xml dokument dobre formulovany
   -- prave 1 korenovy element => dobre formulovany xml dokument
   -- inak dobre formulovany nie je
-- do group by okrem mena a priezviska pridam aj rodne cislo, aby som nezlucil menovcov
-- iba osoby, ktore boli studentom viac ako jedenkrat
select
xmlroot(
    xmlelement("osoba",
        xmlelement("meno", meno),
        xmlelement("priezvisko", priezvisko),
        xmlelement("studium",
            xmlagg(
                xmlelement("odbor",
                    xmlattributes(os_cislo as "oc"), st_odbor
                )
            )
        )
    ), version '1.0'
)
 from os_udaje
  join student using (rod_cislo)
   group by meno, priezvisko, rod_cislo
    having count(os_cislo) > 1;
    
-- vysledok ulozit do tabulky xml dokumentov
create table xml_studenti of xmltype
/

insert into xml_studenti
select
xmlroot(
    xmlelement("osoba",
        xmlelement("meno", meno),
        xmlelement("priezvisko", priezvisko),
        xmlelement("studium",
            xmlagg(
                xmlelement("odbor",
                    xmlattributes(os_cislo as "oc"), st_odbor
                )
            )
        )
    ), version '1.0'
)
 from os_udaje
  join student using (rod_cislo)
   group by meno, priezvisko, rod_cislo;
    
-- vypisat vsetky priezviska z tabulky
   -- ak mam tabulku xml dokumentov (alebo tabulku objektov) pouzivam funkciu value()
select extractvalue(value(t), 'osoba/priezvisko')
 from xml_studenti t;
 
-- vypisat vsetky osobne cisla z tabulky
   -- extractvalue musi vratit prave 1 hodnotu
   -- 1 osoba moze mat viac ako 1 osobne cislo
select extractvalue(value(t), 'osoba/studium/odbor/@oc')
 from xml_studenti t;
 
-- nevhodny select
   -- extract by mal vratit xml dokument, v tomto pripade ale vracia hodnotu
   -- hodnoty su spojene dokopy => nechcene
select extract(value(t), 'osoba/studium/odbor/@oc') as h
 from xml_studenti t;

-- pouzijem extractvalue, vysledok vlozim do kolekcie, pretypujem na tabulku
   -- 'table(xmlsequence(extract(value(t), 'osoba/studium/odbor')))'
   -- -> pre 1 xml dokument pre kazdy odbor
select extractvalue(value(s), 'odbor/@oc')
 from xml_studenti t, table(xmlsequence(extract(value(t), 'osoba/studium/odbor'))) s;
  
-- statistika
   -- pre kazdy rocnik pocet studentov, pocet zien a pocet muzov
-- count ignoruje null
   -- 0 by zapocital, preto ju tam nedam
select rocnik, count(case
                      when substr(rod_cislo, 3, 1) in ('5', '6') then 1
                      else null
                     end) as pocet_zien, 
               sum(case
                    when substr(rod_cislo, 3, 1) in ('0', '1') then 1
                    else 0
                   end) as pocet_muzov
 from student
  group by rocnik;
  
-- vypisat 10 % studentov (nahodnych) z kazdeho rocnika
   -- potrebujem nahodnych studentov => nezalezi podla coho triedim
-- na vysledok analytickej funkcie sa nemozem odkazovat vo where
   -- obalim do ineho selectu

-- 10 % z celkoveho poctu
select *
 from (select rocnik, os_cislo, meno, priezvisko, row_number() over
                                                   (partition by rocnik
                                                     order by null) as poradie
       from os_udaje
        join student using (rod_cislo))
  where poradie <= (select 0.1 * count(*)
                     from student);

-- 10 % individualne pre kazdy rocnik
   -- aliasy atributov vnoreneho selectu uz nie su platne mimo tento select
   -- urobim alias pre cely vnoreny select (tabulku)
select *
 from (select rocnik, os_cislo, meno, priezvisko, row_number() over
                                                   (partition by rocnik
                                                     order by null) as poradie
        from os_udaje
         join student using (rod_cislo)) s1
  where poradie <= (select trunc(0.1 * count(*)) + 1
                     from student s2
                      where s1.rocnik = s2.rocnik)
   order by 1 asc;