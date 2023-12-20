-- 1.
create table os 
 as select *
     from kvet3.osoba_tab;
     
-- 2.
select count(*)
 from os;

desc os;

-- 3.
alter table os
 add constraint io_ok primary key (rod_cislo);

-- 4.
create index io_meno_priezvisko
 on os (meno, priezvisko);

-- 5.
create index io_priezvisko_meno
 on os (priezvisko, meno);

-- 6.
select *
 from user_indexes
  where table_name = 'OS';

-- 7.
select *
 from user_constraints
  where table_name = 'OS';

-- 8.
select index_name, column_name, column_position
 from user_ind_columns
  where table_name = 'OS'
   order by 1, 3 asc;

-- 9.
create table mo
 as select *
     from os
      where substr(rod_cislo, 3, 2) <= 12;

select count(*)
 from mo;

select *
 from user_indexes
  where table_name = 'MO';
  
(select meno, priezvisko
 from p_osoba)
    intersect
(select meno, priezvisko
 from os_udaje);

select o1.rod_cislo, o1.meno, o1.priezvisko, o2.rod_cislo, o2.meno, o2.priezvisko
 from p_osoba o1
  join p_osoba o2 on (o1.meno = o2.meno
                       and o1.priezvisko = o2.priezvisko)
   where o1.rod_cislo > o2.rod_cislo;

-- 10.
-- index unique scan
   -- table access by row id
-- io_pk
select meno, priezvisko
 from os
  where rod_cislo = '660227/4987';

-- 11.
-- index range scan
   -- table access by row id
-- io_priezvisko_meno
select rod_cislo, meno
 from os
  where priezvisko = 'Jurisin';

-- 12.
-- range
   -- row id
-- io m p
select rod_cislo, priezvisko
 from os
  where meno = 'Michal';

-- 13.
select /*+index(os io_meno_priezvisko)*/ rod_cislo, priezvisko
 from os
  where meno = 'Michal';
  
-- 14.
select /*+index(os io_meno_priezvisko)*/ rod_cislo, priezvisko
 from os
  where meno = 'Michal';
  
-- 15.
select rod_cislo, priezvisko
 from os
  where meno = 'Roderik';
  
-- 16.
select /*+index(os io_priezvisko_meno)*/ rod_cislo, priezvisko
 from os
  where meno = 'Roderik';

-- 17.
select /*+index(os io_pk)*/ rod_cislo, priezvisko
 from os
  where meno = 'Roderik';
  
-- 18.
drop index io_meno_priezvisko;

select rod_cislo, priezvisko
 from os
  where meno = 'Roderik';

-- 19.
select priezvisko
 from os
  where meno = 'Roderik';

-- 20.
create index io_meno_priezvisko
 on os (meno, priezvisko);

-- 21.
select meno, priezvisko
 from os
  where meno = 'Roderik'
   order by rod_cislo;

-- 22.
select 'drop index ' || index_name
 from user_indexes
  where table_name = 'OS'
   and index_name not in (select constraint_name
                           from user_constraints
                            where table_name = 'OS'
                             and constraint_type = 'P');
                             
declare
    cursor cur_prikazy is
        select ('drop index ' || index_name) as prikaz
         from user_indexes
          where table_name = 'OS'
           and index_name not in (select constraint_name
                                   from user_constraints
                                    where table_name = 'OS'
                                     and constraint_type = 'P');
    l_prikaz cur_prikazy%rowtype;
begin
    open cur_prikazy;
    
    loop
        fetch cur_prikazy into l_prikaz;
        exit when cur_prikazy%notfound;
        
        dbms_output.put_line(l_prikaz.prikaz);
        execute immediate l_prikaz.prikaz;
    end loop;
    
    close cur_prikazy;
end;
/

alter table os
 drop primary key;

drop index io_pk;

-- 23.
create unique index io_upk
 on os (rod_cislo);
 
drop index io_upk;

-- 24.
create unique index io_upk_r
 on os (rod_cislo) reverse;
 
drop index io_ukp_r;

-- 25.
select /*+index(os io_upk_r)*/ rod_cislo
 from os
  where rod_cislo < '570000/0000';
  
-- 26.
select get_pohlavie(rod_cislo)
 from os_udaje;

-- 27.
create index io_fp
 on os (get_pohlavie(rod_cislo));

-- 28.
select meno, priezvisko
 from os
  where get_pohlavie(rod_cislo) = 'muz';

-- 29.
drop index io_fp;

create bitmap index io_fp_bm
 on os (get_pohlavie(rod_cislo));
 
-- 30.
select meno, priezvisko
 from os
  where get_pohlavie(rod_cislo) = 'muz';

-- 31.
drop index io_fp_bm;

-- 32.
alter table os
 add (pohlavie char(1) generated always as
        (case
            when substr(rod_cislo, 3, 2) <= 12 then 'm'
            else 'z'
        end) not null);

create index io_pvs
 on os (pohlavie);
 
select rod_cislo, meno, priezvisko
 from os
  where pohlavie = 'z';

-- 33.
create table os2
 as select *
     from os
      where 1 = 2;

alter table os2
 add constraint io_pk2 primary key (rod_cislo);

-- 34.
-- 0.627
insert into os2
 select *
  from os;

-- 35.
create table os3
 as select *
     from os
      where 1 = 2;

alter table os3
 add constraint io_pk3 primary key (rod_cislo);

-- 36.
-- 0.250
insert /*+ APPEND */into os3
 select *
  from os;

-- 37.
select *
 from os2;

delete from os2;
commit;

-- 38.
delete from os3 truncate;
commit;

-- 39.
insert into os2
 select *
  from os
   where rownum = 1;
   
insert into os3
 select *
  from os
   where rownum = 1;
   
-- 40.
select *
 from os2;

select *
 from os3;

-- 41.
drop table os2 purge;
drop table os3 purge;
select object_name, original_name
 from recyclebin;

-- 42.
alter table os
 add (plat integer null);

-- 43.
update os
 set plat = trunc(dbms_random.value(500, 1500), 0);

select *
 from os;
 
-- 44.
create index io_plat
 on os (plat);

-- 45.
exec dbms_stats.gather_table_stats('CUPAN1', 'OS');

-- 46.
select /*+index(os io_plat)*/distinct plat
 from os;

-- 47.
alter table os
 modify (plat not null);

-- 48.
select v.rod_cislo, v.meno, v.priezvisko
 from
(
    select rod_cislo, meno, priezvisko,
        row_number() over
         (order by plat desc) as poradie
     from os
) v
 where v.poradie <= (select 0.10 * count(rod_cislo)
                      from os);
                      
select *
 from all_source
  where name = 'PSPRACUJ_OSOBA_TAB';

begin
    kvet3.pSpracuj_osoba_tab();
end;
/

select mod(substr(rod_cislo, 3, 2), 50) as mesiac, substr(rod_cislo, 5, 2) as den
 from osoba_tab;