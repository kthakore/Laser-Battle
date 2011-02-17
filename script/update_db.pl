
`rm robots.db`;

`sqlite3 robots.db < robots.sql`;

`script/laser_battle_create.pl model DB DBIC::Schema Laser::Battle::Schema create=static overwrite_modifications 'dbi:SQLite:dbname=robots.db' '' ''`
