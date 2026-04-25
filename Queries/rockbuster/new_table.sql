DROP TABLE IF EXISTS analytics._stg_rockbuster;

CREATE TABLE analytics._stg_rockbuster (
    rental_date           timestamp,
    return_date           timestamp,
    amount                numeric(5,2),
    payment_date          timestamp,

    customer_first_name   varchar(45),
    customer_last_name    varchar(45),
    customer_email        varchar(50),
    customer_active       boolean,
    customer_create_date  date,

    customer_address      varchar(50),
    customer_address2     varchar(50),
    customer_district     varchar(50),
    customer_postal_code  varchar(10),
    customer_phone        varchar(20),

    customer_city         varchar(50),
    customer_country      varchar(50),

    title                 varchar(255),
    description           text,
    release_year          int,
    rental_duration       int,
    rental_rate           numeric(4,2),
    length                int,
    replacement_cost      numeric(5,2),
    rating                varchar(10),
    language_name         varchar(20),

    category_name         varchar(25),

    actor_first_name      varchar(45),
    actor_last_name       varchar(45),

    store_number          int,

    staff_first_name      varchar(45),
    staff_last_name       varchar(45),
    staff_email           varchar(50)
);

COPY analytics._stg_rockbuster
FROM '/docker-entrypoint-initdb.d/data/rockbuster/rockbuster_denormalized.csv'
CSV HEADER
NULL 'NULL';