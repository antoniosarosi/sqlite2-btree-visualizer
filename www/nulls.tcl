#
# Run this script to generated a nulls.html output file
#
set rcsid {$Id: nulls.tcl,v 1.1 2002/09/02 14:11:04 drh Exp $}

puts {<html>
<head>
<title>NULL Handling In SQLite Versus Other Database Engines</title>
</head>
<body bgcolor="white">
<h1 align="center">
NULL Handling in SQLite Versus Other Database Engines
</h1>
}
puts "<p align=\"center\">
(This page was last modified on [lrange $rcsid 3 4] UTC)
</p>"

puts {
<p>
The goal is
to make SQLite handle NULLs in a standards-compliant way.
But the descriptions in the SQL standards on how to handle
NULLs seem ambiguous. 
It is not clear from the standards documents exactly how NULLs should
be handled in all circumstances.
</p>

<p>
So instead of going by the standards documents, various popular
SQL engines were tested to see how they handle NULLs.  The idea
was to make SQLite work like all the other engines.
A SQL test script was developed and run by volunteers on various
SQL RDBMSes and the results of those tests were used to deduce
how each engine processed NULL values.
A copy of the test script is found at the end of this document.
</p>

<p>
SQLite was originally coded in such a way that the answer to
all questions in the chart below would be "Yes".  But the
expriments run on other SQL engines showed that none of them
worked this way.  So SQLite was modified to work the same as
Oracle, PostgreSQL, and DB2.  This involved making NULLs
indistinct for the purposes of the SELECT DISTINCT statement and
for the UNION operator in a SELECT.  NULLs are still distinct
in a UNIQUE index.  This seems somewhat arbitrary, but the desire
to be compatible with other engines outweighted that objection.
</p>

<p>
It is possible to make SQLite treat NULLs as distinct for the
purposes of the SELECT DISTINCT and UNION.  To do so, one should
change the value of the NULL_ALWAYS_DISTINCT #define in the
<tt>sqliteInt.h</tt> source file and recompile.
</p>

<p>
The following table shows the results of the NULL handling experiments.
</p>

<table border=1 cellpadding=5 width="100%">
<tr><th>&nbsp&nbsp;</th>
<th>SQLite</th>
<th>PostgreSQL</th>
<th>Oracle</th>
<th>Informix</th>
<th>DB2</th>
<th>MS-SQL</th>
<th>MySQL</th>
<th>OCELOT</th>
<th>Firebird</th>
</tr>

<tr><td>Adding anything to null gives null</td>
<td valign="center" align="center" bgcolor="#a9c7a9">Yes</td>
<td valign="center" align="center" bgcolor="#a9c7a9">Yes</td>
<td valign="center" align="center" bgcolor="#a9c7a9">Yes</td>
<td valign="center" align="center" bgcolor="#a9c7a9">Yes</td>
<td valign="center" align="center" bgcolor="#a9c7a9">Yes</td>
<td valign="center" align="center" bgcolor="#a9c7a9">Yes</td>
<td valign="center" align="center" bgcolor="#a9c7a9">Yes</td>
<td valign="center" align="center" bgcolor="#a9c7a9">Yes</td>
<td valign="center" align="center" bgcolor="#a9c7a9">Yes</td>
</tr>
<tr><td>Multiplying null by zero gives null</td>
<td valign="center" align="center" bgcolor="#a9c7a9">Yes</td>
<td valign="center" align="center" bgcolor="#a9c7a9">Yes</td>
<td valign="center" align="center" bgcolor="#a9c7a9">Yes</td>
<td valign="center" align="center" bgcolor="#a9c7a9">Yes</td>
<td valign="center" align="center" bgcolor="#a9c7a9">Yes</td>
<td valign="center" align="center" bgcolor="#a9c7a9">Yes</td>
<td valign="center" align="center" bgcolor="#a9c7a9">Yes</td>
<td valign="center" align="center" bgcolor="#a9c7a9">Yes</td>
<td valign="center" align="center" bgcolor="#a9c7a9">Yes</td>
</tr>
<tr><td>nulls are distinct in a UNIQUE index</td>
<td valign="center" align="center" bgcolor="#a9c7a9">Yes</td>
<td valign="center" align="center" bgcolor="#a9c7a9">Yes</td>
<td valign="center" align="center" bgcolor="#a9c7a9">Yes</td>
<td valign="center" align="center" bgcolor="#c7a9a9">No</td>
<td valign="center" align="center" bgcolor="#a9c7a9">Yes</td>
<td valign="center" align="center" bgcolor="#c7a9a9">No</td>
<td valign="center" align="center" bgcolor="#a9c7a9">Yes</td>
<td valign="center" align="center" bgcolor="#a9c7a9">Yes</td>
<td valign="center" align="center" bgcolor="#a9c7a9">Yes</td>
</tr>
<tr><td>nulls are distinct in SELECT DISTINCT</td>
<td valign="center" align="center" bgcolor="#c7a9a9">No</td>
<td valign="center" align="center" bgcolor="#c7a9a9">No</td>
<td valign="center" align="center" bgcolor="#c7a9a9">No</td>
<td valign="center" align="center" bgcolor="#c7a9a9">No</td>
<td valign="center" align="center" bgcolor="#c7a9a9">No</td>
<td valign="center" align="center" bgcolor="#c7a9a9">No</td>
<td valign="center" align="center" bgcolor="#c7a9a9">No</td>
<td valign="center" align="center" bgcolor="#a9c7a9">Yes</td>
<td valign="center" align="center" bgcolor="#aaaad2">(Note 1)</td>
</tr>
<tr><td>nulls are distinct in a UNION</td>
<td valign="center" align="center" bgcolor="#c7a9a9">No</td>
<td valign="center" align="center" bgcolor="#c7a9a9">No</td>
<td valign="center" align="center" bgcolor="#c7a9a9">No</td>
<td valign="center" align="center" bgcolor="#c7a9a9">No</td>
<td valign="center" align="center" bgcolor="#c7a9a9">No</td>
<td valign="center" align="center" bgcolor="#c7a9a9">No</td>
<td valign="center" align="center" bgcolor="#aaaad2">(Note 3)</td>
<td valign="center" align="center" bgcolor="#a9c7a9">Yes</td>
<td valign="center" align="center" bgcolor="#aaaad2">(Note 1)</td>
</tr>
<tr><td>"CASE WHEN null THEN 1 ELSE 0 END" is 0?</td>
<td valign="center" align="center" bgcolor="#a9c7a9">Yes</td>
<td valign="center" align="center" bgcolor="#a9c7a9">Yes</td>
<td valign="center" align="center" bgcolor="#a9c7a9">Yes</td>
<td valign="center" align="center" bgcolor="#a9c7a9">Yes</td>
<td valign="center" align="center" bgcolor="#a9c7a9">Yes</td>
<td valign="center" align="center" bgcolor="#a9c7a9">Yes</td>
<td valign="center" align="center" bgcolor="#a9c7a9">Yes</td>
<td valign="center" align="center" bgcolor="#a9c7a9">Yes</td>
<td valign="center" align="center" bgcolor="#aaaad2">(Note 2)</td>
</tr>
<tr><td>"null OR true" is true</td>
<td valign="center" align="center" bgcolor="#a9c7a9">Yes</td>
<td valign="center" align="center" bgcolor="#a9c7a9">Yes</td>
<td valign="center" align="center" bgcolor="#a9c7a9">Yes</td>
<td valign="center" align="center" bgcolor="#a9c7a9">Yes</td>
<td valign="center" align="center" bgcolor="#a9c7a9">Yes</td>
<td valign="center" align="center" bgcolor="#a9c7a9">Yes</td>
<td valign="center" align="center" bgcolor="#a9c7a9">Yes</td>
<td valign="center" align="center" bgcolor="#c7a9a9">No</td>
<td valign="center" align="center" bgcolor="#a9c7a9">Yes</td>
</tr>
<tr><td>"not (null AND false)" is true</td>
<td valign="center" align="center" bgcolor="#a9c7a9">Yes</td>
<td valign="center" align="center" bgcolor="#a9c7a9">Yes</td>
<td valign="center" align="center" bgcolor="#a9c7a9">Yes</td>
<td valign="center" align="center" bgcolor="#a9c7a9">Yes</td>
<td valign="center" align="center" bgcolor="#a9c7a9">Yes</td>
<td valign="center" align="center" bgcolor="#a9c7a9">Yes</td>
<td valign="center" align="center" bgcolor="#c7a9a9">No</td>
<td valign="center" align="center" bgcolor="#c7a9a9">No</td>
<td valign="center" align="center" bgcolor="#a9c7a9">Yes</td>
</tr>
</table>

<table border=0 align="right" cellpadding=0 cellspacing=0>
<tr>
<td valign="top" rowspan=3>Notes:&nbsp;&nbsp;</td>
<td>1.&nbsp;</td>
<td>Firebird omits all NULLs from SELECT DISTINCT and from UNION.</td>
</tr>
<tr><td>2.&nbsp;</td>
<td>Test data unavailable.</td></tr>
<tr><td>3.&nbsp;</td>
<td>The version of MySQL tested (3.23.41) does not support UNION.</td></tr>
</table>
<br clear="both">

<p>&nbsp;</p>
<p>
The following script was used to gather information for the table
above.
</p>

<pre>
-- I have about decided that SQL's treatment of NULLs is capricious and cannot be
-- deduced by logic.  It must be discovered by experiment.  To that end, I have 
-- prepared the following script to test how various SQL databases deal with NULL.
-- My aim is to use the information gather from this script to make SQLite as much
-- like other databases as possible.
--
-- If you could please run this script in your database engine and mail the results
-- to me at drh@hwaci.com, that will be a big help.  Please be sure to identify the
-- database engine you use for this test.  Thanks.
--
-- If you have to change anything to get this script to run with your database
-- engine, please send your revised script together with your results.
--

-- Create a test table with data
create table t1(a int, b int, c int);
insert into t1 values(1,0,0);
insert into t1 values(2,0,1);
insert into t1 values(3,1,0);
insert into t1 values(4,1,1);
insert into t1 values(5,null,0);
insert into t1 values(6,null,1);
insert into t1 values(7,null,null);

-- Check to see what CASE does with NULLs in its test expressions
select a, case when b<>0 then 1 else 0 end from t1;
select a+10, case when not b<>0 then 1 else 0 end from t1;
select a+20, case when b<>0 and c<>0 then 1 else 0 end from t1;
select a+30, case when not (b<>0 and c<>0) then 1 else 0 end from t1;
select a+40, case when b<>0 or c<>0 then 1 else 0 end from t1;
select a+50, case when not (b<>0 or c<>0) then 1 else 0 end from t1;
select a+60, case b when c then 1 else 0 end from t1;
select a+70, case c when b then 1 else 0 end from t1;

-- What happens when you multiple a NULL by zero?
select a+80, b*0 from t1;
select a+90, b*c from t1;

-- What happens to NULL for other operators?
select a+100, b+c from t1;

-- Test the treatment of aggregate operators
select count(*), count(b), sum(b), avg(b), min(b), max(b) from t1;

-- Check the behavior of NULLs in WHERE clauses
select a+110 from t1 where b<10;
select a+120 from t1 where not b>10;
select a+130 from t1 where b<10 OR c=1;
select a+140 from t1 where b<10 AND c=1;
select a+150 from t1 where not (b<10 AND c=1);
select a+160 from t1 where not (c=1 AND b<10);

-- Check the behavior of NULLs in a DISTINCT query
select distinct b from t1;

-- Check the behavior of NULLs in a UNION query
select b from t1 union select b from t1;

-- Create a new table with a unique column.  Check to see if NULLs are considered
-- to be distinct.
create table t2(a int, b int unique);
insert into t2 values(1,1);
insert into t2 values(2,null);
insert into t2 values(3,null);
select * from t2;

drop table t1;
drop table t2;
</pre>

<p><hr /></p>
<p><a href="index.html"><img src="/goback.jpg" border=0 />
Back to the SQLite Home Page</a>
</p>
</body>
</html>
}
