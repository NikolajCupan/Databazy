-- kolekcie
   -- neobmedzena velkost
      -- index-by table
      -- nested table
   -- obmedzena velkost
      -- varray
-- count nie je nikdy vacsi ako last
-- next -> index dalsieho prvku, ktory nie je null

-- delete -> maze smernik
-- trim -> maze cely prvok
-- pole(index) := null -> nastavim hodnotu, na ktoru ukazuje smernik na null

-- 3 rozne situacie
   -- zmazanie hodnoty
   -- zmazanie smernika
   -- zmazanie elementu
   
-- nested table celych cisel
create or replace type t_cisla is table of integer;
/

-- tabulka s atributom typu nested table
create table cisla_tab
(
    id integer primary key,
    pole t_cisla
) nested table pole store as cisla_nested;
/

-- pridanie hodnot do tabulky
insert into cisla_tab
 values (1, t_cisla(1, 2, 3));
 
insert into cisla_tab
 values (2, t_cisla(4, 5, 6));

-- pridanie dalsej hodnoty do pola
declare
    temp_cisla t_cisla;
begin
    select pole into temp_cisla
     from cisla_tab
      where id = 2;
    
    temp_cisla.extend(1);
    temp_cisla(temp_cisla.last) := 7;
    
    update cisla_tab
     set pole = temp_cisla
      where id = 2;
end;
/

select *
 from cisla_tab;
 
-- v 2. kolekcii nahradit vsetky neprarne cisla nulou
declare
    temp_cisla t_cisla;
begin
    select pole into temp_cisla
     from cisla_tab
      where id = 2;
      
    for i in 1..temp_cisla.last
    loop
        if temp_cisla.exists(i) then
            if mod(temp_cisla(i), 2) = 1 then
                temp_cisla(i) := 0;
            end if;
        end if;
    end loop;
    
    update cisla_tab
     set pole = temp_cisla
      where id = 2;
end;
/

-- pridat novy prvok do kolekcie v jazyku sql
select c.pole
 from cisla_tab c
  where c.id = 2;

insert into table(select pole
                   from cisla_tab
                    where id = 2)
 values (3);
    
-- nastavit vsetky parne hodnoty v kolekcii na -1
-- prvok pola sa vola column_value
   -- v pripade ak sa jedna o primitivny datovy typ
update table(select pole
              from cisla_tab
               where id = 2)
 set column_value = -1
  where mod(column_value, 2) = 0;
  
-- transformacia kolekcie na tabulku 
select *
 from table(select pole
             from cisla_tab
              where id = 2);
              
-- funkcia, ktora vrati vek osoby
create or replace function get_vek
    (p_rod_cislo p_osoba.rod_cislo%type)
return integer
is
    l_vek integer;
    l_datum_osoba date;
    l_datum_cur date;
    
    l_mesiac_test integer;
begin
    select mod(substr(p_rod_cislo, 3, 2), 50) into l_mesiac_test
     from dual;
    
    if l_mesiac_test > 12 then
        return -1;
    end if;

    select to_date(
                19 || substr(p_rod_cislo, 1, 2) || '.' ||
                mod(substr(p_rod_cislo, 3, 2), 50) || '.' ||
                substr(p_rod_cislo, 5, 2), 'YYYY.MM.DD'
           ) into l_datum_osoba
     from dual;
     
    select abs(months_between(l_datum_osoba, sysdate)) / 12 into l_vek
     from dual;
      
    return l_vek;
    
    exception
        when others then
            return -1;
end;
/

select rod_cislo, get_vek(rod_cislo)
 from p_osoba
  order by 2 asc;
  
-- 3 najstarsi studenti
-- featch first N rows
   -- pripad, ked N = 2:
      -- only -> vzdy vrati prave 2
      -- with ties -> vrati dalsich M zaznamov, kde porovnavany atribut je rovny
      --              hodnote zaznamu na 2. mieste
select distinct o.meno, o.priezvisko, s.rod_cislo, get_vek(o.rod_cislo)
 from os_udaje o
  join student s on (o.rod_cislo = s.rod_cislo)
   order by 4 desc
    fetch first 4 rows
     with ties;
     
-- 3 najstarsi studenti pre kazdy rocnik
-- potrebujem si ocislovat jednotlivych studentov podla veku
   -- pre kazdy rocnik osobitne
   -- skupiny pre jednotlive rocniky
-- analyticke funkcie
   -- row_number() -> kazdy riadok dostane nasledujuce cislo
   -- rank()       -> riadky s rovnakou hodnotou dostanu rovnake cislo,
   --                 vynechane hodnoty
   -- dense_rank() -> riadky s rovnakou hodnotou dostanu rovnake cislo,
   --                 ziadne hodnoty vynechane nie su
-- vysledok analytickej funkcie nejde pouzit vo where
   -- nutnost vnoreneho selectu
select *
 from
(
select meno, priezvisko, get_vek(rod_cislo) as vek, rocnik, row_number() over
                                                             (partition by rocnik
                                                              order by get_vek(rod_cislo) desc) as poradie
 from os_udaje
  join student using (rod_cislo)
   order by vek desc
)
 where poradie <= 3
  order by 4, 5;
  
-- import dat
create table rekonstrukcia(datum date, aktivita varchar2(100));

insert into rekonstrukcia values(trunc(sysdate -30), 'obhliadka domu'); 
insert into rekonstrukcia values(trunc(sysdate -29), 'škriabanie stien');
insert into rekonstrukcia values(trunc(sysdate -28), 'škriabanie stien');
insert into rekonstrukcia values(trunc(sysdate -27), 'sekanie drážok na elektriku');
insert into rekonstrukcia values(trunc(sysdate -26), 'sekanie drážok na elektriku');
insert into rekonstrukcia values(trunc(sysdate -25), 'sekanie drážok na elektriku');
insert into rekonstrukcia values(trunc(sysdate -24), 'sekanie drážok na elektriku');
insert into rekonstrukcia values(trunc(sysdate -23), 'elektroinštalá?né práce');
insert into rekonstrukcia values(trunc(sysdate -22), 'murovanie');
insert into rekonstrukcia values(trunc(sysdate -21), 'murovanie');
insert into rekonstrukcia values(trunc(sysdate -20), 'vodoinštalatérske práce');
insert into rekonstrukcia values(trunc(sysdate -19), 'murovanie');
insert into rekonstrukcia values(trunc(sysdate -18), 'penetrácia a kožovanie stien');
insert into rekonstrukcia values(trunc(sysdate -17), 'penetrácia a kožovanie stien');
insert into rekonstrukcia values(trunc(sysdate -16), 'penetrácia a kožovanie stien');
insert into rekonstrukcia values(trunc(sysdate -15), '?akanie - schnutie');
insert into rekonstrukcia values(trunc(sysdate -14), '?akanie - schnutie');
insert into rekonstrukcia values(trunc(sysdate -13), 'ma?ovanie radiátorov a stien');
insert into rekonstrukcia values(trunc(sysdate -12), 'ma?ovanie radiátorov a stien');
insert into rekonstrukcia values(trunc(sysdate -11), '?akanie - schnutie');
insert into rekonstrukcia values(trunc(sysdate -10), '?akanie - schnutie');
insert into rekonstrukcia values(trunc(sysdate -9), 'elektroinštalá?né práce');
insert into rekonstrukcia values(trunc(sysdate -8), 'vodoinštalatérske práce');
insert into rekonstrukcia values(trunc(sysdate -7), 'finalizácia práce');
insert into rekonstrukcia values(trunc(sysdate -6), 'odovzdanie diela');

commit;
----------------------------------------------------------------------------------------
create table teplota_tab(datum date, hodnota integer);
insert into teplota_tab values(trunc(sysdate) + interval '6' hour, 24);
insert into teplota_tab values(trunc(sysdate) + interval '7' hour, 24);
insert into teplota_tab values(trunc(sysdate) + interval '8' hour, 25);
insert into teplota_tab values(trunc(sysdate) + interval '9' hour, 27);
insert into teplota_tab values(trunc(sysdate) + interval '10' hour, 28);
insert into teplota_tab values(trunc(sysdate) + interval '11' hour, 28);
insert into teplota_tab values(trunc(sysdate) + interval '12' hour, 29);
insert into teplota_tab values(trunc(sysdate) + interval '13' hour, 29);
insert into teplota_tab values(trunc(sysdate) + interval '14' hour, 30);
insert into teplota_tab values(trunc(sysdate) + interval '15' hour, 29);
insert into teplota_tab values(trunc(sysdate) + interval '16' hour, 27);
insert into teplota_tab values(trunc(sysdate) + interval '17' hour, 26);
insert into teplota_tab values(trunc(sysdate) + interval '18' hour, 25);
insert into teplota_tab values(trunc(sysdate) + interval '19' hour, 23);
insert into teplota_tab values(trunc(sysdate) + interval '20' hour, 22);
insert into teplota_tab values(trunc(sysdate) + interval '21' hour, 21);
insert into teplota_tab values(trunc(sysdate) + interval '22' hour, 21);
insert into teplota_tab values(trunc(sysdate) + interval '23' hour, 21);
commit;

-- vypisat kedy aktivita skoncila a kedy zacala
   -- v 1 den je maximalne 1 aktivita
   -- aktivity nie su spojite
-- hranice datumu ziskam cez funkcie min a max
-- ocislujem jednotlive aktivity pomocou analytickej funkcie
desc rekonstrukcia;

-- identifikovanie spojitych intervalov
   -- na urovni dni
select min(datum), max(datum), aktivita
 from
(
select datum, aktivita, datum - row_number() over
                                 (partition by aktivita
                                  order by datum) as rozdiel
 from rekonstrukcia
)
 group by aktivita, rozdiel
  order by 1;
  
-- podobne, ale pre teploty
select min(hodina), max(hodina), hodnota
 from
(
    select to_char(datum, 'HH24') as hodina, hodnota, row_number() over
                                                       (partition by hodnota
                                                        order by datum) as rn
     from teplota_tab
)
 group by hodnota, hodina - rn
  order by 1 asc;
  
-- pre kazdu hodinu ziskat informaciu, ci sa teplota znizila, zvysila alebo ostala rovnaka
-- ocislovanie podla datumu
-- dve reprezentacie, druhu posuniem o jeden riadok
-- porovnavam 1. zaznam s 2. zaznamom, 2. s 3. a tak dalej
select pr.datum, dr.datum, pr.hodnota, dr.hodnota, pr.poradie, dr.poradie,
 case
    when pr.hodnota < dr.hodnota then 'Teplota narastla'
    when pr.hodnota = dr.hodnota then 'Teplota sa nezmenila'
    when pr.hodnota > dr.hodnota then 'Teplota poklesla'
 end as zmena
  from (select datum, hodnota, row_number() over
                                (order by datum asc) poradie
         from teplota_tab) pr
   full join (select datum, hodnota, row_number() over
                                      (order by datum asc) poradie
               from teplota_tab) dr on (pr.poradie = dr.poradie - 1);

-- iny sposob pomocou funkcie lag()
select vn.datum, vn.hodnota, case
                                when vn.predchadzajuca < vn.hodnota then 'Teplota sa zvysila'
                                when vn.predchadzajuca > vn.hodnota then 'Teplota sa znizila'
                                when vn.predchadzajuca = vn.hodnota then 'Teplota sa nezmenila'
                             end
 from
(
select datum, hodnota, lag(hodnota, 1) over
                        (order by datum asc) as predchadzajuca
 from teplota_tab
  order by datum asc
) vn; 