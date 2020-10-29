# Fetch DSL/VDSL line stats from xdslctl info

A quick script I threw together to SSH to my Zyxel VMG3925-B10C ADSL
modem/router (supplied by my ISP, Andrews & Arnold), and parse out
line performance statistics from the output of `xdslctl info --stats`.

A bit ugly, but works for me.

TODO: document more.

If you find this before I have documented it, and it would be helpful to you,
poke me at davidp@preshweb.co.uk and I'll be happy to hurry up with documenting
it properly!


## Graphing via Munin

I have the data collected here graphed by Munin for easy visualisation, using 
[munin_db_query](https://github.com/bigpresh/misc-scripts/tree/master/munin_db_query)

I set up the config in `/etc/munin/plugin-conf.d/munin-node` along the lines
of:

```
[xdslstats_signal]
env.title DSL signal stats
env.vlabel dB
env.category Network
env.query1 select snr_up from xdslstats where router = '192.168.1.1' and timestamp > date_sub(now(), interval 2 minute) order by timestamp desc limit 1
env.label1 Upstream SNR
env.query2 select snr_down from xdslstats where router = '192.168.1.1' and timestamp > date_sub(now(), interval 2 minute) order by timestamp desc limit 1
env.label2 Downstream SNR
env.query3 select attn_up from xdslstats where router = '192.168.1.1' and timestamp > date_sub(now(), interval 2 minute) order by timestamp desc limit 1
env.label3 Upstream Attenuation
env.query4 select attn_down from xdslstats where router = '192.168.1.1' and timestamp > date_sub(now(), interval 2 minute) order by timestamp desc limit 1
env.label4 Downstream Attenuation
env.query5 select power_up from xdslstats where router = '192.168.1.1' and timestamp > date_sub(now(), interval 2 minute) order by timestamp desc limit 1
env.label5 Upstream Power
env.query6 select power_down from xdslstats where router = '192.168.1.1' and timestamp > date_sub(now(), interval 2 minute) order by timestamp desc limit 1
env.label6 Downstream Power
env.dsn DBI:mysql:davidp
env.db_user munin


[xdslstats_errors]
env.title DSL errors
env.vlabel errors per second
env.category Network
env.query1 select fec_up_per_sec from xdslstats where router = '192.168.1.1' and timestamp > date_sub(now(), interval 2 minute) order by timestamp desc limit 1
env.label1 Upstream FEC/sec
env.query2 select fec_down_per_sec from xdslstats where router = '192.168.1.1' and timestamp > date_sub(now(), interval 2 minute) order by timestamp desc limit 1
env.label2 Downstream FEC/sec
env.query3 select crc_up_per_sec from xdslstats where router = '192.168.1.1' and timestamp > date_sub(now(), interval 2 minute) order by timestamp desc limit 1
env.label3 Upstream CRC/sec
env.query4 select crc_down_per_sec from xdslstats where router = '192.168.1.1' and timestamp > date_sub(now(), interval 2 minute) order by timestamp desc limit 1
env.label4 Downstream CRC/sec
env.dsn DBI:mysql:davidp
env.db_user munin

[xdslstats_linerate]
env.title DSL Line rate
env.vlabel Kbps
env.category Network
env.query1 select rate_up from xdslstats where router = '192.168.1.1' and timestamp > date_sub(now(), interval 2 minute) order by timestamp desc limit 1
env.label1 Upstream Kbps
env.query2 select rate_down from xdslstats where router = '192.168.1.1' and timestamp > date_sub(now(), interval 2 minute) order by timestamp desc limit 1
env.label2 Downstream Kbps
env.dsn DBI:mysql:davidp
env.db_user munin
```

Then create symlinks with those names - `xdslstats_signal`, `xdslstats_errors`,
`xdslstats_linerate` in `/etc/munin/plugins` all pointing at `munin_db_query`.


