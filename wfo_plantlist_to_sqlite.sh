#!/usr/bin/env bash
#
# Usage ./wfo_plantlist_to_sqlite.sh wfo_plantlist_2024_06.db ../wfo_plantlist

#
# Create the name table
#
sqlite3 "$1" <<'SQL'
pragma journal_mode = memory;
pragma foreign_keys = on;

drop table if exists name;

create table name (
    ID text,
    alternativeID text,
    basionymID text,
    scientificName text,
    authorship text,
    rank text,
    uninomial text,
    genus text,
    infragenericEpithet text,
    specificEpithet text,
    infraspecificEpithet text,
    code text,
    referenceID text,
    publishedInYear text,
    link text
);

-- create index name_id_idx on name (ID);
-- create index name_scientific_name_idx on name (scientificName);
SQL

#
# Import the name table
#
echo "Importing the name table..."
sqlite3 "$1" ".mode tabs" ".import --skip 1 $2/name.tsv name"

#
# Create the reference table
#
sqlite3 "$1" <<'SQL'
pragma journal_mode = memory;
pragma foreign_keys = on;

drop table if exists reference;

create table reference (
  id text,
  citation text,
  link text,
  doi text,
  remarks text
);

-- create index reference_id_idx on reference (id);

SQL

#
# Import the reference table
#
echo "Importing the reference table..."
sqlite3 "$1" ".mode tabs" ".import --skip 1 $2/reference.tsv reference"

#
# Create the synonym table
#
sqlite3 "$1" <<'SQL'
pragma journal_mode = memory;
pragma foreign_keys = on;

drop table if exists synonym;

create table synonym (
    id text,
    taxonID text,
    nameID text,
    accordingToID text,
    referenceID text,
    link text
);

-- create index synonym_id_idx on synonym (id);

SQL

#
# Import the synonym table
#
echo "Importing the synonym table..."
sqlite3 "$1" ".mode tabs" ".import --skip 1 $2/synonym.tsv synonym"

#
# Create the taxon table
#
sqlite3 "$1" <<'SQL'
pragma journal_mode = memory;
pragma foreign_keys = on;

drop table if exists taxon;

create table taxon (
    id text,
    nameID text,
    parentID text,
    accordingToID text,
    scrutinizer text,
    scrutinizerID text,
    scrutinizerDate text,
    referenceID text,
    link text,

    foreign key(nameID) references name(ID)
);

create index taxon_id_idx on taxon (id);
create index taxon_name_id_idx on taxon(nameID);
create index taxon_parent_id_idx on taxon(parentID);

SQL

#
# Import the taxon table
#
echo "Importing the taxon table..."
sqlite3 "$1" ".mode tabs" ".import --skip 1 $2/taxon.tsv taxon"

sqlite3 "$1" "vacuum;"
