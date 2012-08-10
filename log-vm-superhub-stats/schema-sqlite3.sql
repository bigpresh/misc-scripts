CREATE TABLE stats (
    id INTEGER PRIMARY KEY,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    key VARCHAR,
    value VARCHAR
);

CREATE TABLE eventlog (
    id           INTEGER PRIMARY KEY,
    timestamp    DATETIME DEFAULT CURRENT_TIMESTAMP,
    first_time   VARCHAR,
    last_time    VARCHAR,
    priority     VARCHAR,
    description  VARCHAR
);

