CREATE TABLE stats (
    id int(11)    NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `timestamp`   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `key`         VARCHAR(200),
    `value`       VARCHAR(200)
);

CREATE TABLE eventlog (
    id int(11)    NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `timestamp`   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `first_time`  VARCHAR(200),
    `last_time`   VARCHAR(200),
    `priority`    VARCHAR(200),
    `description` VARCHAR(250)
);
