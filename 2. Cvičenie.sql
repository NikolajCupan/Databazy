-- predmety, ktore si nikto nikdy nezapisal
select cis_predm, nazov
 from predmet
  where cis_predm not in (select cis_predm
                           from zap_predmety);

select cis_predm, nazov
 from predmet
  where not exists (select 'x'
                     from zap_predmety
                      where zap_predmety.cis_predm = predmet.cis_predm);

-- zoznam predmetov, ktore mali zapisane maximalne 4 studenti
select cis_predm, nazov
 from predmet
  left join zap_predmety using (cis_predm)
   group by cis_predm, nazov
    having count(os_cislo) <= 4
     order by 2;
     
-- pouzivam not in, pretoze cis_predm vobec nemusi byt v table zap_predmety     
select cis_predm, nazov
 from predmet
  where cis_predm not in (select cis_predm
                          from zap_predmety
                           group by cis_predm
                            having count(os_cislo) > 4)
   order by 2;
   
-- kazdemu dam pristup na select na danu tabulku
-- public znamena, ze dam kazdemu
grant select on os_udaje to public;

-- select, ktory vygeneruje prikazy na udelenie prava na tabulky
-- v tomto pripade sa nepouziva bodkociarka
-- prikaz musi byt syntakticky validny
select 'grant select on ' || table_name || ' to public'
 from tabs;

-- dynamicke spustenie jednotlivych prikazov
-- vykonava sa pomocou kurzorov
-- kurzor je vzdy nutne zavriet
-- rovnako je nutne kontrolovat, ci kurzor obsahuje dalsi zaznam
declare
    cursor cur_prikazy is
     select 'grant select on ' || table_name || ' to public'
      from tabs;
    prikaz varchar(100);
begin
    open cur_prikazy;
    
    loop
        fetch cur_prikazy into prikaz;
        exit when cur_prikazy%notfound;
        dbms_output.put_line(prikaz);
        execute immediate prikaz;
    end loop;
    
    close cur_prikazy;
end;
/

declare
    cursor cur_prikazy is
     select 'revoke select on ' || table_name || ' from public'
      from tabs;
    prikaz varchar(100);
begin
    open cur_prikazy;
    
    loop
        fetch cur_prikazy into prikaz;
        exit when cur_prikazy%notfound;
        dbms_output.put_line(prikaz);
        execute immediate prikaz;
    end loop;
    
    close cur_prikazy;
end;
/

-- rebuildovat vsetky indexy
-- alter index <nazov> rebuild
select *
 from user_indexes;
declare
    cursor cur_indexy is
     select 'alter index ' || index_name || ' rebuild'
      from user_indexes;
    prikaz varchar(100);
begin
    open cur_indexy;
    
    loop
        fetch cur_indexy into prikaz;
        exit when cur_indexy%notfound;
        dbms_output.put_line(prikaz);
        execute immediate prikaz;
    end loop;
    
    close cur_indexy;
end;
/

-- kurzor moze fungovat aj ako atribut selectu
   -- takyto kurzor nie je nutne zatvorit
-- vypisat osoby a k nim studentske informacie
-- ak zadefinujem alias, tak ho musim pouzit
-- vo vnutri kurzoru pridam vazobnu podmienku aka by bola pri exists
-- pre kazdu osobu sa vytvori kurzor obsahujuci vsetky osobne cisla danej osoby
   -- kolekcia retazcov (kurzor) je novym atributom
   -- neefektivny pristup, pre kazdy riadok tabulky os_udaje sa spusti vnutorny select
select meno, priezvisko, cursor(select os_cislo
                                 from student st
                                  where st.rod_cislo = os.rod_cislo)
 from os_udaje os;
 
-- efektivnejsie pomocou agregacnej funkcie
   -- listagg
      -- 1. parameter: co chcem agregovat
      -- 2. parameter: podla coho budem oddelovat (nepovinny parameter)
-- prazdny retazec a null je to iste
select meno, priezvisko, listagg(os_cislo, ',')
                          within group (order by os_cislo) 
 from os_udaje
  left join student using (rod_cislo)
   group by meno, priezvisko, rod_cislo;

-- nezadefinovana hodnota ma hodnotu null   
   -- vypise sa prazdny retazec
-- dojde k implicitnej konverzii
declare
    i integer;
begin
    i := '1';
    dbms_output.put_line('hodnota: ' || i);
end;
/

-- exception handler sa dava na koniec
declare
    i integer;
begin
    i := 'x';
    dbms_output.put_line('hodnota: ' || i);
    
    exception
        when others then dbms_output.put_line('Chyba konverzie');
end;
/

-- premenna typu exception
-- pouzijem na odchytenie konkretnej vynimky
-- cislo chyby je vzdy zaporne cislo
-- exception 'others' musi byt vzdy posledne, pretoze zachyti vsetky vynimky
declare
    i integer;
    chyba exception;
    pragma exception_init(chyba, -6502);
begin
    i := 'x';
    dbms_output.put_line('hodnota: ' || i);
    
    exception
        when chyba then dbms_output.put_line('Chyba konverzie');
        when others then dbms_output.put_line('Ina chyba');
end;
/

-- vlastne chyby z intervalu <-20 999, -20 000>
declare
    i integer;
    chyba exception;
    pragma exception_init(chyba, -6502);
begin
    i := 1;
    dbms_output.put_line('hodnota: ' || i);
    
    if i > 0
        then raise_application_error(-20000, 'Moja chyba');
    end if;
end;
/

-- exception handler je pouzitelny len na telo prikazu
   -- nezachyti chybu v deklaracnej casti
-- obalim do ineho bloku
begin
    declare
        i integer := 'x';
    begin
        dbms_output.put_line('hodnota: ' || i);
    
        exception
            when others then dbms_output.put_line('Chyba konverzie');
    end;
    
     exception
        when others then dbms_output.put_line('Vonkajsia chyba');   
end;
/

-- premenna ma platnost len v ramci bloku, v ktorom je zadefinovana
-- bloky mozno pomenovat
   -- pristupujem pomocou bodkovej notacie
<<vonkajsi>>
declare
    cislo integer := 5;
begin
    dbms_output.put_line('hodnota: ' || vonkajsi.cislo);
    dbms_output.put_line('hodnota: ' || cislo);
end;
/

-- meno osoby s najdlhsim priezviskom
select priezvisko, length(priezvisko)
 from os_udaje
  where length(priezvisko) in (select max(length(priezvisko)) 
                                from os_udaje);

select priezvisko, length(priezvisko)
 from os_udaje
  where length(priezvisko) in (select max(dlzka) 
                                from (select length(priezvisko) as dlzka
                                       from os_udaje));
                                       
-- osoba, ktora mala zapisanych najviac predmetov
-- max(count(x)) -> agregacna funkcia z agregacnej funkcie
   -- v Oracle to je povolene
select meno, priezvisko, rod_cislo, count(cis_predm)
 from os_udaje
  join student using (rod_cislo)
   join zap_predmety using (os_cislo)
    group by meno, priezvisko, rod_cislo
     having count(cis_predm) in (select max(count(cis_predm))
                                  from zap_predmety
                                   group by os_cislo);
                                   
select meno, priezvisko, rod_cislo, count(cis_predm)
 from os_udaje
  join student using (rod_cislo)
   join zap_predmety using (os_cislo)
    group by meno, priezvisko, rod_cislo
     having count(cis_predm) in (select max(count(cis_predm))
                                  from student
                                   join zap_predmety using (os_cislo)
                                    group by os_cislo);
                                   
select rod_cislo, count(cis_predm)
 from student
  join zap_predmety using (os_cislo)
   group by rod_cislo
    order by 2 desc;
    
-- iba unikatne predmety
select meno, priezvisko, rod_cislo
 from os_udaje
  join student using (rod_cislo)
   join zap_predmety using (os_cislo)
    group by meno, priezvisko, rod_cislo
     having count(distinct cis_predm) = (select max(count(distinct cis_predm))
                                         from zap_predmety
                                          group by os_cislo);
-- ku kazdej osobe vypisat rocnik
select meno, priezvisko, rocnik
 from os_udaje
  left join student on (os_udaje.rod_cislo = student.rod_cislo);
  
-- iba osoby, ktore maju rocnik 2
-- v tomto pripade je outer join zbytocny
select meno, priezvisko, rocnik
 from os_udaje
  left join student on (os_udaje.rod_cislo = student.rod_cislo)
   where rocnik = 2;
   
-- podmienka v on
   -- nie je to to iste ako ked je podmienka vo where
select meno, priezvisko, rocnik
 from os_udaje
  left join student on (os_udaje.rod_cislo = student.rod_cislo
                         and rocnik = 2); 