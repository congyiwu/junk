Links to good resources, mostly sorted alphabetically (as opposed to goodness).

# Shell scripts
* https://www.shellcheck.net/wiki/: list of checks in [ShellCheck](https://github.com/koalaman/shellcheck), the defacto standard shell script linter
* https://mywiki.wooledge.org/BashFAQ
* POSIX shells and basishms not supported by all POSIX shells
  * https://mywiki.wooledge.org/Bashism
  * https://pubs.opengroup.org/onlinepubs/009695399/utilities/test.html POSIX `test` spec
  * https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html POSIX `sh` spec
  * https://wiki.ubuntu.com/DashAsBinSh
  * https://www.etalabs.net/sh_tricks.html

# SQL

Preferred:
* Well-organized:
  * https://docs.microsoft.com/en-us/sql/sql-server: I'd always check the official docs first
  * https://www.mssqltips.com: specifically the Beginner, Tutorials, and T-SQL sections in the navigation bar
  * https://use-the-index-luke.com: SQL performance guide
* Less organized (blogs, articles):
  * https://www.mssqltips.com/sql-server-developer-resources
  * https://www.brentozar.com/blog: deep dives, a lot of esoteric stuff from a SQL Server consulting and training firm
    * https://www.erikdarlingdata.com/blog/: Brent Ozar alumni
    * https://littlekendra.com/: Brent Ozar cofounder/alumni
  * https://www.sommarskog.se: a small set of *exhaustive* deep-dives into complex subjects and working around SQL Server limitations:
    * [The Curse and Blessings of Dynamic SQL](https://www.sommarskog.se/dynamic_sql.html): how you use dynamic SQL, when you should - and when you should not
    * [Dynamic Search Conditions](https://www.sommarskog.se/dyn-search.html): how to write a stored procedure that permits users to select among many search conditions, using both dynamic and static SQL.
    * [Error and Transaction Handling in SQL Server](https://www.sommarskog.se/error_handling/Part1.html)
    * [Using a Table of Numbers](https://www.sommarskog.se/Short%20Stories/table-of-numbers.html): This short story shows how a one-column table of consecutive numbers (or dates or hours etc) can be a powerful asset in your database to help you to write certain type of queries
  * https://sqlperformance.com
    * https://sqlperformance.com/2013/02/t-sql-queries/halloween-problem-part-1
  * https://www.sqlshack.com

Loose articles:
* https://weblogs.sqlteam.com/dang/2007/10/28/conditional-insertupdate-race-condition/
* https://weblogs.sqlteam.com/dang/2009/01/31/upsert-race-condition-with-merge/

Not preferred:
* https://blog.sqlauthority.com/:  for some reason I don't love how the articles are presented, but it keeps popping up in Google
* https://stackoverflow.com/ and other sites in https://stackexchange.com/sites: a lot of the answers to SQL questions are especially bad.
