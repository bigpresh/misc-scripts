# html-table-dump

A quick Perl script to take either an URL to fetch or some HTML on STDIN, and
dump details of all tables found by
[HTML::TableExtract](https://metacpan.org/pod/HTML::TableExtract)

Useful when scraping data from tables, and you want a quick view of what's
there.

Output is JSON, with details of each table, the "coordinates" (depth and count),
and the rows of the table.

Leading and trailing whitespace is stripped from each cell.
