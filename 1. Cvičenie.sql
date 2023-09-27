-- struktura tabulky
desc os_udaje;

-- tabs je alias pre user_tables
select table_name
 from tabs;

select table_name
 from user_tables;
 
-- obmedzenia
select table_name
 from user_constraints;

select table_name
 from all_constraints;
 
-- indexy
select table_name
 from user_indexes;
 
select table_name
 from all_indexes;
 
-- vsetky osoby, ktore nikdy neboli studentami
-- pouzitie not in alebo not exists
select *
 from os_udaje
  where rod_cislo not in (select rod_cislo
                           from student);

select *
 from os_udaje
  where not exists (select 'x'
                     from student
                      where os_udaje.rod_cislo = student.rod_cislo);
-- "where os_udaje.rod_cislo = student.rod_cislo" vazobna podmienka
   -- vazobna podmienka je spravidla medzi PK a FK
   -- okrem nich ide pridat aj dalsie podmienky
-- not exists ma podmienku navyse
-- pri in nemoze byt ziskavana hodnota null, vtedy je nutne pouzit exists

-- studijne odbory, ktore nemaju ziadneho studenta
-- v danom studijnom odbore nie je zaradeny ziaden student
-- pri kompozitnom primarnom kluci je nutne pouzit (not) exists
select *
 from st_odbory so
  where not exists (select 'x'
                     from student st
                       where so.st_odbor = st.st_odbor
                        and so.st_zameranie = st.st_zameranie);

-- ide urobit aj s in, ale exists je lepsie
-- exists je univerzalnejsie riesenie ako in
select *
 from st_odbory so
  where (so.st_odbor, so.st_zameranie) not in (select st.st_odbor, st.st_zameranie
                                                from student st);
                                                
-- agregacne funkcie
   -- vacsinou v kombinacii s group by
   -- ignoruju null hodnoty

-- kazda osoba, kolko ma predmetov
-- nutne pouzit left join, pretoze osoba nemusi byt studentom a student nemusi mat ziadny predmet
-- v group by musi byt vsetko co je za select okrem agregacnych funkcii
   -- + primarny kluc
select meno, priezvisko, count(cis_predm)
 from os_udaje
  left join student using (rod_cislo)
   left join zap_predmety using (os_cislo)
    group by meno, priezvisko, rod_cislo;
    
-- iba unikatne predmety  
select meno, priezvisko, count(distinct cis_predm)
 from os_udaje
  left join student using (rod_cislo)
   left join zap_predmety using (os_cislo)
    group by meno, priezvisko, rod_cislo;
    
-- osoba, ktora ma najviac zapisanych predmetov
select meno, priezvisko, count(cis_predm)
 from os_udaje
  left join student using (rod_cislo)
   left join zap_predmety using (os_cislo)
    group by meno, priezvisko, rod_cislo
     having count(cis_predm) in (select max(count(cis_predm))
                                  from os_udaje
                                   left join student using (rod_cislo)
                                    left join zap_predmety using (os_cislo)
                                     group by meno, priezvisko, rod_cislo);

-- iny vseobecnejsi sposob                                     
select meno, priezvisko, count(cis_predm)
 from os_udaje
  left join student using (rod_cislo)
   left join zap_predmety using (os_cislo)
    group by meno, priezvisko, rod_cislo
     having count(cis_predm) in (select max(tmp.pocet)
                                  from (select count(cis_predm) pocet
                                         from os_udaje
                                          left join student using (rod_cislo)
                                           left join zap_predmety using (os_cislo)
                                            group by meno, priezvisko, rod_cislo) tmp);                                     
-- poradie jednotlivych klauzul: from, join, where, group by, having, select, order by
-- alias stlpca nemozno ziskat vo from, join, where, group by, having

-- kolkokrat bola osoba studentom
-- nespravne vysledky, konstanta 1
select meno, priezvisko, os_udaje.rod_cislo, count(1) as pocet
 from os_udaje
  left join student on (os_udaje.rod_cislo = student.rod_cislo)
   group by meno, priezvisko, os_udaje.rod_cislo;
   
-- spravny vysledok
select meno, priezvisko, os_udaje.rod_cislo, count(os_cislo) as pocet
 from os_udaje
  left join student on (os_udaje.rod_cislo = student.rod_cislo)
   group by meno, priezvisko, os_udaje.rod_cislo;
   
select meno, priezvisko, os_udaje.rod_cislo, count(os_cislo)
 from os_udaje
  left join student on (os_udaje.rod_cislo = student.rod_cislo)
   group by meno, priezvisko, os_udaje.rod_cislo
    having count(os_cislo) >= 2;
   
select *
 from (select meno, priezvisko, os_udaje.rod_cislo, count(os_cislo) pocet
        from os_udaje
         left join student on (os_udaje.rod_cislo = student.rod_cislo)
          group by meno, priezvisko, os_udaje.rod_cislo)
  where pocet >= 2;
  
-- jedno rodne cislo, nie je nutne dat pred meno atributu meno tabulky
select rod_cislo
 from os_udaje
  join student using (rod_cislo);
  
-- dve rodne cisla, prve z tabulky os_udaje, druhe z tabulky student
-- je nutne dat meno tabulky pred meno atributu
select os_udaje.rod_cislo, student.rod_cislo
 from os_udaje
  join student on (os_udaje.rod_cislo = student.rod_cislo);
  
-- praca s casom
-- aktualny cas
select sysdate from dual;

-- zmena formatu zobrazovaneho casu
set serveroutput on;
alter session set nls_date_format = 'DD.MM.YYYY HH24:MI:SS';

-- pripocitanie dni
-- robi sa priamo cez +
select sysdate + 1 from dual;

-- pripocitanie hodiny
select sysdate + 1/24 from dual;

-- pouzitie datoveho typu interval
select sysdate + interval '5' second from dual;
select sysdate + interval '2:05:16' hour to second from dual;

-- pridanie mesiacov
select add_months(sysdate, 1) from dual;

-- pridanie 1 roka / odobranie 1 roka
select add_months(sysdate, 12) from dual;
select add_months(sysdate, -12) from dual;

-- orezanie na dni
select trunc(sysdate) from dual;
select trunc(sysdate, 'MM') from dual;
select trunc(sysdate, 'YYYY') from dual;

-- posledny den v roku
select trunc(add_months(sysdate, 12), 'YYYY') - 1 from dual;

-- iba cast datumu
select extract(year from sysdate) from dual;
select extract(month from sysdate) from dual;
select extract(day from sysdate) from dual;

select to_char(sysdate, 'DD.MM')
 from dual;
 
-- kurzory
-- objekt, ktory spristupnuje zaznamy (sekvencne) ziskane pomocou prikazu select
-- %type vrati typ daneho stlpca
-- praca s kurzorom
   -- 1. otvorim kurzor
   -- 2. vyberam zaznamy
   -- 3. zavriem kurzor
-- pri kontrole, ci uz nie su dalsie zaznamy
   -- 1. fetch (vyberiem udaje)
   -- 2. skontrolujem, ci uz nie su dalsie udaje (%notfound)
   -- na poradi zalezi
-- dbms_output.put_line vypise iba ak som zadal set serveroutput on
declare
    cursor cur_osoba is
     select meno, priezvisko, rod_cislo
      from os_udaje;
    v_meno varchar(30);  
    v_priezvisko os_udaje.priezvisko%type;
    v_rod_cislo os_udaje.rod_cislo%type;
begin
    open cur_osoba;
    
    loop
        fetch cur_osoba into v_meno, v_priezvisko, v_rod_cislo;
        exit when cur_osoba%notfound;
        dbms_output.put_line(v_meno || ' ' || v_priezvisko || ' ' || v_rod_cislo);
    end loop;
    
    close cur_osoba;
end;
/

-- parametricky kurzor
-- nutne dbat na to, aby nazvy premennych boli jedinecne
-- atribut moze mat typ tabulka
   -- za meno premennej dam row a datovy typ ziskam pomocou tabulka%rowtype
   -- takyto atribut nasledne pouzivam ako tabulku
   -- t. j. <meno tabulkoveho atributu>.<meno atributu v danej tabulke>
   -- ak zadefinujem alias, musim pouzit tento namiesto povodneho nazvu
declare
    cursor cur_osoba is
     select meno, priezvisko, rod_cislo
      from os_udaje;
    v_meno varchar(30);  
    v_priezvisko os_udaje.priezvisko%type;
    v_rod_cislo os_udaje.rod_cislo%type;
    
    cursor cur_student (p_rod_cislo os_udaje.rod_cislo%type) is
     select os_cislo as oc
      from student
       where rod_cislo = p_rod_cislo;
    student_row cur_student%rowtype;
begin
    open cur_osoba;
    
    loop
        fetch cur_osoba into v_meno, v_priezvisko, v_rod_cislo;
        exit when cur_osoba%notfound;
        dbms_output.put_line(v_meno || ' ' || v_priezvisko || ' ' || v_rod_cislo);
        
        open cur_student(v_rod_cislo);
        
        loop
            fetch cur_student into student_row;
            exit when cur_student%notfound;
            dbms_output.put_line('     ' || student_row.oc);
        end loop;
        
        close cur_student;
    end loop;
    
    close cur_osoba;
end;
/

-- for kurzory
-- podobne foreach-u
declare
begin
    for osoba in (select meno, priezvisko, rod_cislo from os_udaje)
    loop
        dbms_output.put_line(osoba.meno || ' ' || osoba.priezvisko || ' ' || osoba.rod_cislo);
    end loop;
end;
/

declare
begin
    for osoba in (select meno, priezvisko, os_cislo from os_udaje)
    loop
        dbms_output.put_line(osoba.meno || ' ' || osoba.priezvisko || ' ' || osoba.os_cislo);
        for student in (select os_cislo from student where rod_cislo = osoba.rod_cislo)
        loop
            dbms_output.put_line(student.os_cislo);
        end loop;
    end loop;
end;
/

-- generovanie prikazov
-- prikaz mozno vykonat pomocou kurzoru
select 'drop table ' || table_name as prikaz from tabs;

declare
    cursor cur_prikaz is
     select 'delete from ' || table_name || ' where 1 = 2'
      from tabs;
    prikaz varchar2(200);
begin
    open cur_prikaz;
    loop
        fetch cur_prikaz into prikaz;
        exit when cur_prikaz%notfound;
        execute immediate prikaz;
    end loop;
    close cur_prikaz;
end;
/

declare
    cursor cur_tab is
     select table_name
      from tabs;
    v_tab varchar2(50);
    v_prikaz varchar2(100);
begin
    open cur_tab;
    loop
        fetch cur_tab into v_tab;
        exit when cur_tab%notfound;
        v_prikaz := 'delete from ' || v_tab || ' where 1 = 2';
        execute immediate v_prikaz;
    end loop;
    close cur_tab;
end;
/