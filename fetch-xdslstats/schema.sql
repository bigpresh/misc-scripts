CREATE TABLE xdslstats (
    timestamp TIMESTAMP DEFAULT NOW(),
    router     VARCHAR(255),
    status     VARCHAR(255),
    training   VARCHAR(255),
    rate_up    FLOAT,
    rate_down  FLOAT,
    snr_up     FLOAT,
    snr_down   FLOAT,
    power_up   FLOAT,
    power_down FLOAT,
    attn_up    FLOAT,
    attn_down  FLOAT,
    crc_up_per_sec FLOAT,
    crc_down_per_sec FLOAT,
    fec_up_per_sec FLOAT,
    fec_down_per_sec FLOAT
);

