-- nova tabulka
create table kontakty (
    rod_cislo varchar2(11),
    typ_kontaktu char(1) check (typ_kontaktu in ('m', 'e')),
    cislo varchar2(50)    
);

-- naplnenie tabulky cez select
-- poradie dat v selecte nie je dane
   -- naplnam iba cez jeden select
insert into kontakty
 select rod_cislo, 'm', meno || '.' || priezvisko || '@fri.uniza.sk'
  from os_udaje;
  
commit;

insert into kontakty
 values (null, 'e', 'uniza@fri.uniza.sk');
 
insert into os_udaje
 values ('111111/1122', 'Nikolaj', 'Cupan', null, null, null);
 
-- vsetky osoby, ku ktorym nemame kontakt
-- v pripade not in vo vnorenom selecte nemoze byt null
   -- staci jedna null hodnota a select nebude korektny (nevrati nic)
   -- riesenim je pouzit not exists
   -- alebo potlacit null hodnoty vo vnorenom selecte
-- in porovnava na zaklade rovnosti
   -- porovnavanie s null => cela podmienka je vyhodnotena ako null
select *
 from os_udaje
  where rod_cislo not in (select nvl(rod_cislo, 0)
                           from kontakty);
                           
select *
 from os_udaje
  where not exists (select 'x'
                     from kontakty
                      where kontakty.rod_cislo = os_udaje.rod_cislo);
                      
-- nova tabulka s xml atributom
-- v xml type bude rocnik, zaciatok, koniec
create table tab_xml (
    rod_cislo varchar2(11),
    xml xmltype
);

-- nazov elementu je v uvodzovkach, nie v apostrofoch
-- pre spravne naformatovanie elementu ho zabalim do xmlroot
   -- pouzivam v ramci xml maximalne 1-krat
-- pre kazdeho studenta vznikne osobitny xml dokument
select
    xmlroot(
        xmlelement("udaj",
            xmlelement("rocnik", rocnik),
            xmlelement("zaciatok", dat_zapisu),
            xmlelement("koniec", ukoncenie)
        ), version '1.0'
    )
 from student;

-- zlucim vsetky studentske informacie 1 osoby do 1 xml dokumentu
-- dobre formulovany xml dokument 
   -- ma prave 1 korenovy element
   -- elementy su korektne vnarane
   -- jednotlive elementy musia byt od seba odlisitelne
-- spravny xml dokument
   -- porovnavam podla xml schemy alebo DTD
   -- ak nemam schemu a DTD, tak neviem urcit, ci je spravny
-- na zapocte -> vediet aky je spravny, dobre formulovany xml dokument
select
    xmlroot(
        xmlelement("student",
            xmlagg(
                xmlelement("udaj",
                    xmlattributes(os_cislo as "osobne_cislo"),
                    xmlelement("rocnik", rocnik),
                    xmlelement("zaciatok", to_char(dat_zapisu, 'DD.MM.YYYY')),
                    xmlelement("koniec", to_char(ukoncenie, 'DD.MM.YYYY'))
                )
            )
        ), version '1.0'
    )
 from student
  group by rod_cislo;
  
insert into tab_xml
select rod_cislo,
    xmlroot(
        xmlelement("student",
            xmlagg(
                xmlelement("udaj",
                    xmlattributes(os_cislo as "osobne_cislo"),
                    xmlelement("rocnik", rocnik),
                    xmlelement("zaciatok", to_char(dat_zapisu, 'DD.MM.YYYY')),
                    xmlelement("koniec", to_char(ukoncenie, 'DD.MM.YYYY'))
                )
            )
        ), version '1.0'
    )
 from student
  group by rod_cislo;

select *
 from tab_xml;
 
-- zoznam vsetkych rocnikov z xml dokumentu
-- nefunguje pretoze udaj obsahuje viacero rocnikov
   -- extractvalue musi vratit prave jeden zaznam
select extractvalue(xml, 'student/udaj/rocnik')
 from tab_xml;
 
-- je to pole, mozem pouzit index
select extractvalue(xml, 'student/udaj/rocnik[0]')
 from tab_xml;
 
select extractvalue(xml, 'student/udaj/rocnik[1]')
 from tab_xml;
 
-- mozem pouzit extract
   -- moze vratit viac ako jeden zaznam
   -- takyto dokument nie je dobre formulovany
select extract(xml, 'student/udaj/rocnik')
 from tab_xml;
 
-- vypisat len jednotlive rocniky a potlacit duplicity
   -- xml je objekt, nejde pouzit distinct
   -- xml nepodporuje map ani order by funkciu
select distinct extract(t.xml, 'student/udaj/rocnik').getStringVal()
 from tab_xml t;
 
select distinct t.rocnik
 from tab_xml xt, xmltable('student/udaj'
                            passing xt.xml
                             columns rocnik varchar2(20) path 'rocnik') t;

 
-- tabulka xml dokumentov
-- rodne cislo bude atribut studenta
create table tab_of_xml of xmltype;

-- pri datumoch v xml sa vzdy pouziva to_char
insert into tab_of_xml
select
    xmlroot(
        xmlelement("student",
            xmlattributes(rod_cislo as "rodne_cislo"),
            xmlagg(
                xmlelement("udaj",
                    xmlattributes(os_cislo as "osobne_cislo"),
                    xmlelement("rocnik", rocnik),
                    xmlelement("zaciatok", to_char(dat_zapisu, 'DD.MM.YYYY')),
                    xmlelement("koniec", to_char(ukoncenie, 'DD.MM.YYYY'))
                )
            )
        ), version '1.0'
    )
 from student
  group by rod_cislo;
  
select value(t) from tab_of_xml t;
select * from tab_of_xml;

-- iny sposob naplnenia tabulky
   -- vychadzam z xml atributu
   -- na zapocte bude typ ulohy na transformaciu xml atributu na xml objekt
create table tab_of_xml2 of xmltype;

insert into tab_of_xml2
select 
    xmlroot(
        xmlelement("student",
            xmlattributes(rod_cislo as "rodne_cislo"),
            extract(xml, 'student/udaj')
            ), version '1.0'
    )
 from tab_xml;
 
select value(s)
 from tab_of_xml2 s;

-- zadanie z cvicenia
-- 1.
create table osoba_xml of xmltype;

-- 2.
-- vlozenie cez values
insert into osoba_xml
values
(
    xmltype
    ('
        <osoba rc="841106/9999">
            <meno>Nikolaj</meno>
            <priezvisko>Cupan</priezvisko>
        </osoba>
    ')
);

insert into osoba_xml
values
(
    xmltype
    ('
        <osoba rc="841106/9997">
            <meno>Meno</meno>
            <priezvisko>Priezvisko</priezvisko>
        </osoba>
    ')
);

-- vlozenie cez select
insert into osoba_xml
select
    xmlelement("osoba",
        xmlattributes(rod_cislo as "rc"),
        xmlelement("meno", meno),
        xmlelement("priezvisko", priezvisko)
    )
 from os_udaje
  where rod_cislo like '87%';

-- 3.
select value(t)
 from osoba_xml t;
 
-- 4.
select extractvalue(value(t), 'osoba/meno')
 from osoba_xml t;
 
-- 5.
select extractvalue(value(t), 'osoba/priezvisko')
 from osoba_xml t
  where extractvalue(value(t), 'osoba/meno') = 'Nikolaj';
  
update osoba_xml t
set value(t) = updatexml
(
    value(t),
    'osoba/priezvisko/text()', 'Novy'
)
 where extractvalue(value(t), 'osoba/meno') = 'Nikolaj';
 
-- 6.
select extractvalue(value(t), 'osoba/@rc')
 from osoba_xml t
  where extractvalue(value(t), 'osoba/meno') = 'Nikolaj';
  
update osoba_xml t
set value(t) = updatexml
(
    value(t),
    'osoba/@rc', '111111/1111'
)
 where extractvalue(value(t), 'osoba/meno') = 'Nikolaj';
 
-- 7.
insert into os_udaje (rod_cislo, meno, priezvisko)
select
    extractvalue(value(t), 'osoba/@rc'),
    extractvalue(value(t), 'osoba/meno'),
    extractvalue(value(t), 'osoba/priezvisko')
 from osoba_xml t
  where extractvalue(value(t), 'osoba/@rc') not in (select rod_cislo
                                                     from os_udaje);
                                                     
select *
 from os_udaje
  where exists (select 'x'
                 from osoba_xml t
                  where os_udaje.rod_cislo = extractvalue(value(t), 'osoba/@rc'));
                  
-- 8.1.2
create table xml_predmety of xmltype;

-- v 2 dokumentoch
select
    xmlroot(
        xmlelement("predmet",
            xmlattributes(priklad_db2.zap_predmety.cis_predm as "cislo",
                          priklad_db2.predmet.nazov as "nazov"),
            xmlagg(
                xmlelement("student",
                    xmlelement("oc", priklad_db2.zap_predmety.os_cislo),
                    xmlelement("meno", priklad_db2.os_udaje.meno || ' ' || priklad_db2.os_udaje.priezvisko),
                    xmlelement("skupina", priklad_db2.student.st_skupina)
                )                
            )
        ), version '1.0'
    )
 from priklad_db2.zap_predmety
  join priklad_db2.predmet on (priklad_db2.zap_predmety.cis_predm = priklad_db2.predmet.cis_predm)
   join priklad_db2.student on (priklad_db2.zap_predmety.os_cislo = priklad_db2.student.os_cislo)
    join priklad_db2.os_udaje on (priklad_db2.student.rod_cislo = priklad_db2.os_udaje.rod_cislo)
     where (priklad_db2.zap_predmety.cis_predm = 'A914'
             or priklad_db2.zap_predmety.cis_predm = 'A913')
      and priklad_db2.zap_predmety.skrok = 2005
       group by priklad_db2.zap_predmety.cis_predm, priklad_db2.predmet.nazov;

-- v 1 dokumente
select  
    xmlroot(
        xmlagg(
            xmlelement("predmety", xml_dokument)
       ), version '1.0'
    )
from
(
select
    xmlelement("predmet",
        xmlattributes(priklad_db2.zap_predmety.cis_predm as "cislo",
                      priklad_db2.predmet.nazov as "nazov"),
        xmlagg(
            xmlelement("student",
                xmlelement("oc", priklad_db2.zap_predmety.os_cislo),
                xmlelement("meno", priklad_db2.os_udaje.meno || ' ' || priklad_db2.os_udaje.priezvisko),
                xmlelement("skupina", priklad_db2.student.st_skupina)
            )                
        )
    ) xml_dokument
 from priklad_db2.zap_predmety
  join priklad_db2.predmet on (priklad_db2.zap_predmety.cis_predm = priklad_db2.predmet.cis_predm)
   join priklad_db2.student on (priklad_db2.zap_predmety.os_cislo = priklad_db2.student.os_cislo)
    join priklad_db2.os_udaje on (priklad_db2.student.rod_cislo = priklad_db2.os_udaje.rod_cislo)
     where (priklad_db2.zap_predmety.cis_predm = 'A914'
             or priklad_db2.zap_predmety.cis_predm = 'A913')
      and priklad_db2.zap_predmety.skrok = 2005
       group by priklad_db2.zap_predmety.cis_predm, priklad_db2.predmet.nazov
);

-- BONUS
-- kredity za neabsolvovane predmety, alebo za predmety so znamkou F, sa nezapocitavaju
select
    xmlroot(
        xmlelement("report",
            xmlelement("hlavicka",
                xmlelement("title", 'Kontrola studia'),
                xmlelement("os_cislo", os_cislo),
                xmlelement("meno", meno),
                xmlelement("priezvisko", priezvisko),
                xmlelement("st_skupina", st_skupina)
            ),
            xmlelement("telo",
                xmlagg(xml_dokument order by skrok),
                xmlelement("spolu",
                    xmlelement("priemer", trunc(sum(suma_znamky) / sum(pocet_znamky), 2)),
                    xmlelement("kredit", sum(kredity))
                )
            ),
            xmlelement("zaver",
                xmlattributes('V Ziline' as "miesto",
                              to_char(sysdate, 'DD.MM.YYYY') as "datum",
                              user as "kto"
                )
            )
        ), version '1.0'
    )
from
(
    select os_cislo, skrok, sum(case 
                                    when lower(vysledok) = 'f' then 0
                                    when vysledok is null then 0
                                    else ects
                                end) as kredity, sum(case
                                                        when lower(vysledok) = 'a' then 1
                                                        when lower(vysledok) = 'b' then 2
                                                        when lower(vysledok) = 'c' then 3
                                                        when lower(vysledok) = 'd' then 4
                                                        when lower(vysledok) = 'e' then 5
                                                        when lower(vysledok) = 'f' then 6
                                                        when vysledok is null then null
                                                      end) as suma_znamky, count(vysledok) as pocet_znamky,
        xmlelement("skrok",
            xmlattributes(skrok as "rok"),
            xmlagg(
                xmlelement("predmet",
                    xmlelement("cis_predm", cis_predm),
                    xmlelement("nazov", nazov),
                    xmlelement("znamka", case
                                            when lower(vysledok) = 'a' then 1
                                            when lower(vysledok) = 'b' then 2
                                            when lower(vysledok) = 'c' then 3
                                            when lower(vysledok) = 'd' then 4
                                            when lower(vysledok) = 'e' then 5
                                            when lower(vysledok) = 'f' then 6
                                            when lower(vysledok) is null then null
                                         end),
                    xmlelement("kredit", ects)
                )
            )
        ) xml_dokument
     from zap_predmety
      join predmet using (cis_predm)
       group by skrok, os_cislo
) vn
 right join student using (os_cislo)
  join os_udaje using (rod_cislo)
   group by os_cislo, meno, priezvisko, st_skupina;