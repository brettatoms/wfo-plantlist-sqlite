-- Denormalize the name.rank and name.code tables. This will help decrease the size of the
-- sqlite database file.

drop table if exists name_rank;

create table name_rank (
  ID integer primary key autoincrement,
  name text not null
);

alter table name
add column rankID integer;

insert into name_rank (name)
select distinct rank from name;

update name
set rankID = (select id from name_rank where name_rank.name = name.rank);

alter table name
drop column rank;

drop table if exists name_code;

create table name_code (
  id integer primary key autoincrement,
  name text not null
);

alter table name
add column codeID integer;

insert into name_code (name)
select distinct code from name;

update name
set codeID = (select id from name_code where name_code.name = name.code);

alter table name
drop column code;

vacuum;
