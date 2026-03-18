-- =====================================================
-- TPC-H Schema for PostgreSQL
-- Compatible with SF=1 dataset
-- =====================================================

-- REGION
CREATE TABLE region
(
    r_regionkey INTEGER PRIMARY KEY,
    r_name      TEXT NOT NULL,
    r_comment   TEXT
);

-- NATION
CREATE TABLE nation
(
    n_nationkey INTEGER PRIMARY KEY,
    n_name      TEXT    NOT NULL,
    n_regionkey INTEGER NOT NULL REFERENCES region (r_regionkey),
    n_comment   TEXT
);

CREATE INDEX idx_nation_region
    ON nation (n_regionkey);

-- CUSTOMER
CREATE TABLE customer
(
    c_custkey    INTEGER PRIMARY KEY,
    c_name       TEXT    NOT NULL,
    c_address    TEXT    NOT NULL,
    c_nationkey  INTEGER NOT NULL REFERENCES nation (n_nationkey),
    c_phone      TEXT,
    c_acctbal    NUMERIC(15, 2),
    c_mktsegment TEXT,
    c_comment    TEXT
);

CREATE INDEX idx_customer_nation
    ON customer (c_nationkey);

CREATE INDEX idx_customer_segment
    ON customer (c_mktsegment);

-- ORDERS
CREATE TABLE orders
(
    o_orderkey      INTEGER PRIMARY KEY,
    o_custkey       INTEGER NOT NULL REFERENCES customer (c_custkey),
    o_orderstatus   CHAR(1),
    o_totalprice    NUMERIC(15, 2),
    o_orderdate     DATE,
    o_orderpriority TEXT,
    o_clerk         TEXT,
    o_shippriority  INTEGER,
    o_comment       TEXT
);

CREATE INDEX idx_orders_customer
    ON orders (o_custkey);

CREATE INDEX idx_orders_date
    ON orders (o_orderdate);

-- PART
CREATE TABLE part
(
    p_partkey     INTEGER PRIMARY KEY,
    p_name        TEXT,
    p_mfgr        TEXT,
    p_brand       TEXT,
    p_type        TEXT,
    p_size        INTEGER,
    p_container   TEXT,
    p_retailprice NUMERIC(15, 2),
    p_comment     TEXT
);

CREATE INDEX idx_part_type
    ON part (p_type);

CREATE INDEX idx_part_brand
    ON part (p_brand);

-- SUPPLIER
CREATE TABLE supplier
(
    s_suppkey   INTEGER PRIMARY KEY,
    s_name      TEXT,
    s_address   TEXT,
    s_nationkey INTEGER NOT NULL REFERENCES nation (n_nationkey),
    s_phone     TEXT,
    s_acctbal   NUMERIC(15, 2),
    s_comment   TEXT
);

CREATE INDEX idx_supplier_nation
    ON supplier (s_nationkey);

-- PARTSUPP
CREATE TABLE partsupp
(
    ps_partkey    INTEGER NOT NULL REFERENCES part (p_partkey),
    ps_suppkey    INTEGER NOT NULL REFERENCES supplier (s_suppkey),
    ps_availqty   INTEGER,
    ps_supplycost NUMERIC(15, 2),
    ps_comment    TEXT,
    PRIMARY KEY (ps_partkey, ps_suppkey)
);

CREATE INDEX idx_partsupp_supp
    ON partsupp (ps_suppkey);

-- LINEITEM (Largest Table)
CREATE TABLE lineitem
(
    l_orderkey      INTEGER NOT NULL REFERENCES orders (o_orderkey),
    l_partkey       INTEGER NOT NULL REFERENCES part (p_partkey),
    l_suppkey       INTEGER NOT NULL REFERENCES supplier (s_suppkey),
    l_linenumber    INTEGER,
    l_quantity      NUMERIC(15, 2),
    l_extendedprice NUMERIC(15, 2),
    l_discount      NUMERIC(15, 2),
    l_tax           NUMERIC(15, 2),
    l_returnflag    CHAR(1),
    l_linestatus    CHAR(1),
    l_shipdate      DATE,
    l_commitdate    DATE,
    l_receiptdate   DATE,
    l_shipinstruct  TEXT,
    l_shipmode      TEXT,
    l_comment       TEXT,
    PRIMARY KEY (l_orderkey, l_linenumber)
);

CREATE INDEX idx_lineitem_order
    ON lineitem (l_orderkey);

CREATE INDEX idx_lineitem_part
    ON lineitem (l_partkey);

CREATE INDEX idx_lineitem_supp
    ON lineitem (l_suppkey);

CREATE INDEX idx_lineitem_shipdate
    ON lineitem (l_shipdate);
