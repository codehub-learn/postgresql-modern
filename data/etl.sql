-- Download from https://github.com/aleaugustoplus/tpch-data
-- Extract *.tbl FROM *.gz files
-- Run first sed -i 's/|$//' *.tbl to remove the trailing pipe

COPY region
    FROM '/data/region.tbl'
    WITH (FORMAT csv, DELIMITER '|', HEADER false, NULL '', QUOTE '"');
COPY nation
    FROM '/data/nation.tbl'
    WITH (FORMAT csv, DELIMITER '|', HEADER false, NULL '', QUOTE '"');
COPY customer
    FROM '/data/customer.tbl'
    WITH (FORMAT csv, DELIMITER '|', HEADER false, NULL '', QUOTE '"');
COPY orders
    FROM '/data/orders.tbl'
    WITH (FORMAT csv, DELIMITER '|', HEADER false, NULL '', QUOTE '"');
COPY part
    FROM '/data/part.tbl'
    WITH (FORMAT csv, DELIMITER '|', HEADER false, NULL '', QUOTE '"');
COPY supplier
    FROM '/data/supplier.tbl'
    WITH (FORMAT csv, DELIMITER '|', HEADER false, NULL '', QUOTE '"');
COPY partsupp
    FROM '/data/partsupp.tbl'
    WITH (FORMAT csv, DELIMITER '|', HEADER false, NULL '', QUOTE '"');
COPY lineitem
    FROM '/data/lineitem.tbl'
    WITH (FORMAT csv, DELIMITER '|', HEADER false, NULL '', QUOTE '"');
