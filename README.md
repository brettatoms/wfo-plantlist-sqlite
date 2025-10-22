# World Flora Online Plant List SQLite Utilities

This repo holds some utilities to help convert the data from the [World Flora Online Plant List](https://wfoplantlist.org) into a SQLite database.

You can download the latest WFO Plant List datasets at [10.5281/zenodo.7460141](https://doi.org/10.5281/zenodo.7460141)

### wfo_plantlist_to_sqlite.sh

Import the tab delimited plant list files into a SQLite database


Example usage:
```sh
# Import the database into the database file named wfo_plantlist_2024_06.db
wfo_plantlist_to_sqlite.sh wfo_plantlist_2024_06.db <path to the .tsv files>
```

### denormalize.sql

Denormalize the `name.rank` and `name.code` columns into separate lookup tables

Example usage:

```sh
sqlite3 wfo_plantlist_2024_06.db < denormalize.sql
```
