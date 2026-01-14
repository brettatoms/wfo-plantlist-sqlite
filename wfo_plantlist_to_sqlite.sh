#!/usr/bin/env bash
#
# Import WFO Plant List TSV files into a SQLite database
#
# Usage: ./wfo_plantlist_to_sqlite.sh wfo_plantlist_2025-06.db ../wfo_plantlist_2025-06
#
# Tables are auto-created from TSV headers, making this resilient to schema changes.
# Run add_foreign_keys.sql after import to add FK constraints.

set -e

if [ $# -ne 2 ]; then
    echo "Usage: $0 <database.db> <path-to-tsv-files>"
    exit 1
fi

DB="$1"
TSV_DIR="$2"

sqlite3 "$DB" "pragma journal_mode = memory;"

echo "Importing reference..."
sqlite3 "$DB" ".mode tabs" ".import $TSV_DIR/reference.tsv reference"

echo "Importing name..."
sqlite3 "$DB" ".mode tabs" ".import $TSV_DIR/name.tsv name"

echo "Importing taxon..."
sqlite3 "$DB" ".mode tabs" ".import $TSV_DIR/taxon.tsv taxon"

echo "Importing synonym..."
sqlite3 "$DB" ".mode tabs" ".import $TSV_DIR/synonym.tsv synonym"

echo "Importing typematerial..."
sqlite3 "$DB" ".mode tabs" ".import $TSV_DIR/typematerial.tsv typematerial"

echo "Creating indexes..."
sqlite3 "$DB" "CREATE INDEX taxon_id_idx ON taxon(ID);"
sqlite3 "$DB" "CREATE INDEX taxon_name_id_idx ON taxon(nameID);"
sqlite3 "$DB" "CREATE INDEX taxon_parent_id_idx ON taxon(parentID);"

echo "Vacuuming..."
sqlite3 "$DB" "vacuum;"

echo "Done."
