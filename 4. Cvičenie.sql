-- nova tabulka
create table kontakty (
    rod_cislo varchar2(11),
    typ_kontaktu char(1) check (typ_kontaktu in ('m', 'e')),
    cislo varchar2(50)    
);

-- naplnenie tabulky cez select
-- poradie dat v selecte nie je date
   -- naplnam iba cez jeden select
insert into kontakty
 select rod_cislo, 'm', meno || '.' || priezvisko || '@fri.uniza.sk'
  from os_udaje;
  
commit;

-- nove zaznamy v tabulke os_udaje
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
  
-- zoznam vsetkych rocnikov z xml dokumentu
-- nefunguje pretoze rocnik obsahuje viacero elementov
select extractvalue(xml, 'student/udaj/rocnik')
 from tab_xml;
 
-- je to pole, mozem pouzit index
select extractvalue(xml, 'student/udaj/rocnik[1]')
 from tab_xml;
 
-- mozem pouzit extract
   -- takyto dokument nie je dobre formulovany
select extract(xml, 'student/udaj/rocnik')
 from tab_xml;

-- vytvorit tabulku xml dokumentov
-- rodne cislo bude atribut studenta
create table tab_of_xml of xmltype;

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

delete from tab_of_xml2;

-- na zapocte bude typ ulohy na transformaciu xml atributu na xml objekt

-- DOKONCIT:
-- vypisat len jednotlive rocniky a potlacit duplicity
   -- xml je objekt, nejde pouzit distinct
   -- xml nepodporuje map ani order by funkciu
-- zadanie z cvicenia
   -- BONUSOVE zadanie z cvicenia do dalsieho cvicenia