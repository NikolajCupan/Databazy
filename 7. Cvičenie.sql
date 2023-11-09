-- tabulka xml dokumentov
create table xml_studium of xmltype;
/

insert into xml_studium
select
    xmlroot(
        xmlelement("osoba",
            xmlelement("meno", meno),
            xmlelement("priezvisko", priezvisko),
            xmlelement("studium",
                xmlagg(
                    xmlelement("odbor", 
                        xmlattributes(os_cislo as "oc"),
                    st_odbor)
                )
            )
        ), version '1.0'
    )
 from os_udaje
  join student using (rod_cislo)
   group by meno, priezvisko, rod_cislo;
   
-- rovnaka struktura ale vo formate json
   -- zdroj relacna tabulka
   -- v json_arrayagg agregujem json_object-s
select
    json_object(
        'meno' value meno,
        'priezvisko' value priezvisko,
        'studium' value json_arrayagg(
            json_object(
                'oc' value os_cislo,
                'odbor' value st_odbor
            )
        )
    )
 from os_udaje
  join student using (rod_cislo)
   group by meno, priezvisko, rod_cislo;

-- zdroj xml tabulka
   -- 1. z xml tabulky ziskam data do relacnej formy
   -- 2. z relacnych dat vytvorim json
-- odbor_tab je xml dokument
   -- table() vytvori tabulku xml dokumentov
   -- stlpec je pomenovany column_value
select
    extractvalue(value(t), 'osoba/meno') as meno,
    extractvalue(value(t), 'osoba/priezvisko') as priezvisko,
    extractvalue(odbory_tab.column_value, 'odbor') as odbor,
    extractvalue(odbory_tab.column_value, 'odbor/@oc') as os_cislo
 from xml_studium t, table(xmlsequence(extract(value(t), 'osoba/studium/odbor'))) odbory_tab;

-- vytvorim json
select
    json_object(
        'meno' value meno,
        'priezvisko' value priezvisko,
        'studium' value json_arrayagg(
            json_object(
                'oc' value os_cislo,
                'odbor' value st_odbor
            )
        )
    )
 from
(
    select
        extractvalue(value(t), 'osoba/meno') as meno,
        extractvalue(value(t), 'osoba/priezvisko') as priezvisko,
        extractvalue(odbory_tab.column_value, 'odbor') as st_odbor,
        extractvalue(odbory_tab.column_value, 'odbor/@oc') as os_cislo
     from xml_studium t, table(xmlsequence(extract(value(t), 'osoba/studium/odbor'))) odbory_tab
)
 group by meno, priezvisko;

-- vysledok ulozim do tabulky
   -- tabulka s atributom json
   -- tabulka json objektov neexistuje
create table json_tab
(
    data clob check (data is json)
);

insert into json_tab
select
    json_object(
        'meno' value meno,
        'priezvisko' value priezvisko,
        'studium' value json_arrayagg(
            json_object(
                'oc' value os_cislo,
                'odbor' value st_odbor
            )
        )
    )
 from
(
    select
        extractvalue(value(t), 'osoba/meno') as meno,
        extractvalue(value(t), 'osoba/priezvisko') as priezvisko,
        extractvalue(odbory_tab.column_value, 'odbor') as st_odbor,
        extractvalue(odbory_tab.column_value, 'odbor/@oc') as os_cislo
     from xml_studium t, table(xmlsequence(extract(value(t), 'osoba/studium/odbor'))) odbory_tab
)
 group by meno, priezvisko;

select *
 from json_tab;

-- z json tabulky vytvorim xml a pridam do tabulky, ktora ma xml dokument ako atribut
   -- 1. z json tabulky ziskam data do relacnej formy
   -- 2. z relacnych dat vytvorim xml
create table xml_studium2
(
    xml xmltype
);

insert into xml_studium2
select
    xmlroot(
        xmlelement("osoba",
            xmlelement("meno", meno),
            xmlelement("priezvisko", priezvisko),
            xmlelement("studium",
                xmlagg(
                    xmlelement("odbor", 
                        xmlattributes(os_cislo as "oc"),
                    st_odbor)
                )
            )
        ), version '1.0'
    )
 from
(
    select jt.meno, jt.priezvisko, jt.st_odbor, jt.os_cislo
     from json_tab j, json_table(j.data, '$'
                                  columns(meno varchar2(50) path '$.meno',
                                          priezvisko varchar2(50) path '$.priezvisko',
                                          nested path '$.studium[*]' columns(st_odbor varchar2(50) path '$.odbor',
                                                                             os_cislo varchar2(50) path '$.oc'
                                                                            )
                                         )
                                 ) jt
)
 group by meno, priezvisko;
 
select *
 from xml_studium2;