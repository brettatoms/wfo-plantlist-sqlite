#!/usr/bin/env bash
#
# Add foreign key constraints to WFO Plant List tables
#
# Usage: ./add_foreign_keys.sh wfo_plantlist_2024_06.db
#
# This reads the current schema from each table and recreates it with FK constraints.

set -e

if [ $# -ne 1 ]; then
    echo "Usage: $0 <database.db>"
    exit 1
fi

DB="$1"

# Get column names from a table as comma-separated list
get_columns() {
    local table="$1"
    sqlite3 "$DB" "PRAGMA table_info($table);" | cut -d'|' -f2 | paste -sd','
}

# Get column definitions (name TEXT) from a table, comma-separated
get_column_defs() {
    local table="$1"
    sqlite3 "$DB" "PRAGMA table_info($table);" | awk -F'|' '{
        type = ($3 == "" ? "TEXT" : $3)
        printf "%s    %s %s", sep, $2, type
        sep = ",\n"
    }'
}

# Rebuild a table with foreign key constraints
# Arguments: table_name fk_constraint1 [fk_constraint2 ...]
rebuild_with_fks() {
    local table="$1"
    shift
    local fk_constraints=("$@")
    
    echo "Rebuilding $table with foreign keys..."
    
    local columns
    columns=$(get_columns "$table")
    
    local column_defs
    column_defs=$(get_column_defs "$table")
    
    # Build FK constraint lines
    local fk_lines=""
    for i in "${!fk_constraints[@]}"; do
        if [ $i -gt 0 ]; then
            fk_lines="$fk_lines,"$'\n'
        fi
        fk_lines="$fk_lines    FOREIGN KEY ${fk_constraints[$i]}"
    done
    
    # Build and execute the migration
    sqlite3 "$DB" <<EOF
PRAGMA foreign_keys = OFF;

CREATE TABLE ${table}_new (
$column_defs,
$fk_lines
);

INSERT INTO ${table}_new SELECT $columns FROM $table;
DROP TABLE $table;
ALTER TABLE ${table}_new RENAME TO $table;

PRAGMA foreign_keys = ON;
EOF
}

# Rebuild tables with their foreign key constraints

rebuild_with_fks "name" \
    "(referenceID) REFERENCES reference(ID)" \
    "(basionymID) REFERENCES name(ID)"

rebuild_with_fks "taxon" \
    "(nameID) REFERENCES name(ID)" \
    "(parentID) REFERENCES taxon(ID)" \
    "(accordingToID) REFERENCES reference(ID)"

# Recreate indexes for taxon (lost during rebuild)
echo "Recreating taxon indexes..."
sqlite3 "$DB" "CREATE INDEX taxon_id_idx ON taxon(ID);"
sqlite3 "$DB" "CREATE INDEX taxon_name_id_idx ON taxon(nameID);"
sqlite3 "$DB" "CREATE INDEX taxon_parent_id_idx ON taxon(parentID);"

rebuild_with_fks "synonym" \
    "(accordingToID) REFERENCES reference(ID)" \
    "(taxonID) REFERENCES taxon(ID)" \
    "(nameID) REFERENCES name(ID)"

rebuild_with_fks "typematerial" \
    "(nameID) REFERENCES name(ID)"

echo "Vacuuming..."
sqlite3 "$DB" "VACUUM;"

echo "Done."
