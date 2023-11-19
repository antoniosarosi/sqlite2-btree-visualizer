# SQLite 2.8.1 for learning / debugging

Modified version of SQLite 2.8.1 with custom options for visualizing the BTree
structure easily. Original source code downloaded from here:
https://www.sqlite.org/src/info/590f963b6599e4e2

## Why SQLite 2.8.1?

I wanted to visualize how the BTree pages evolve on disk as records are added to
database tables. Initially, I cloned the
[current version of SQLite](https://github.com/sqlite/sqlite) (3.x.x), but I
quickly found out that SQLite is not a such a "small and simple" codebase these
days.

After that, I tried
[SQLite 2.5.0](https://github.com/davideuler/SQLite-2.5.0-for-code-reading) but
run into some seg faults. So I looked up a version that fixes important issues
and compiles easily with modern GCC requiring minor changes to the source code.
See here:

- [Release History](https://www.sqlite.org/changes.html)
- [Check-ins (commits) from 2003](https://www.sqlite.org/src/timeline?c=590f963b65&y=ci&b=2003-04-24+01:45:04)

## Compilation

Create a `build` directory, use the [`./configure`](./configure) script to
generate the Makefile and then call `make`:

```bash
mkdir build
cd build
../configure
make
```

## Visualizing the BTree

SQLite 2.x.x has a function called `sqliteBtreePageDump` which
prints an entire BTree to `STDOUT`, including page numbers, children pointers
and payload (key + data). I added some options to the SQLite shell to avoid
uncommenting and recompiling the code all over again when you need to print the
BTree:

```bash
sqlite> .help

# Default SQLite options here...

CUSTOM OPTIONS
.path ON|OFF           Prints the page numbers acquired when executing SQL
.keyhash ON|OFF        Prints the hash generated for the given key in an SQL statement
.btree PAGE FILE       Prints the Btree rooted on PAGE to FILE (or STDOUT if ommited)
```

Here's an example of how you can use these options. First, create a database
file and open the SQLite shell:

```bash
# Move back to the root if you're still inside the build directory
cd ..

# Create the DB file
touch db.sqlite

# Open the shell
./build/sqlite ./db.sqlite
```

Now create a simple table like this one:

```sql
CREATE TABLE users (id INT PRIMARY KEY, name VARCHAR(255));
```

Once that's done, you need to populate the table with some records. Open a new
terminal and use the [`inserts.sh`](./inserts.sh) script to generate a `.sql`
file that you can execute at once:

```bash
./inserts.sh > inserts.sql
```

Go back to the SQLite shell that you opened previously and execute the SQL file:

```bash
.read inserts.sql
```

This will insert 10000 users with primary keys in ascending order (`1`, `2`,
`3`, ..., `10000`). More details on this later. Now you need to find the root
page number of the primary key index and the root page of the table data (they
are 2 different B-Trees stored in the same file). For that you can use the
`sqlite_master` table:

```sql
SELECT type, name, rootpage FROM sqlite_master;
```

You'll get something like this as the output:

```text
table|users|4
index|(users autoindex 1)|3
```

In this case, the root page of the index is `3` while the root page of the data
is `4`. Dump both B-Trees in their own file:

```
.btree 3 users.index
.btree 4 users.data
```

You'll see something like this if you open the files:

`users.index`
```bash
PAGE 3:
cell  0: i=8..31      chld=68   nk=11   nd=0    payload: key=b0G2da  data=484 ..........
cell  1: i=32..55     chld=69   nk=11   nd=0    payload: key=b0G2l8  data=968 ..........
cell  2: i=56..79     chld=132  nk=11   nd=0    payload: key=b0G2si  data=1452..........
cell  3: i=80..103    chld=195  nk=11   nd=0    payload: key=b0G2|G  data=1936..........
cell  4: i=104..127   chld=258  nk=12   nd=0    payload: key=b0G3Wbq data=2420..........

# Rest of cells and page
```

`users.data`

```bash
PAGE 4:
cell  0: i=8..47      chld=297  nk=4    nd=23   payload: key=2223 data=...2223.User Name
cell  1: i=48..87     chld=298  nk=4    nd=23   payload: key=4420 data=...4420.User Name
cell  2: i=88..127    chld=585  nk=4    nd=23   payload: key=6617 data=...6617.User Name
cell  3: i=128..167   chld=872  nk=4    nd=23   payload: key=8645 data=...8645.User Name
                right_chld=1160

# Rest of pages
```

Now turn on all the custom options:

```
.path ON
.keyhash ON
```

Execute a simple statement like this one:

```sql
SELECT rowid, * FROM users WHERE id = 25;
```

You'll get an output similar to this:

```text
Reading page 1
Reading page 4
Reading page 1
Reading page 3
Generate hash for 25.000000 -> 0G1v
Reading page 3
Reading page 68
Reading page 8
Reading page 4
Reading page 297
Reading page 29
Reading page 6
25|25|User Name 25
```

Copy the generated hash for key `25` (`0G1v` in this example) and
<kbd>CTRL</kbd> + <kbd>F</kbd> it in the `users.index` file. You'll find a line
like this one:

```text
payload: key=b0G1v data=25
```

The data, `25`, is the `ROWID`, not the `PRIMARY KEY` value. The `ROWID` is a
unique identifier for a single row that is independent of primary keys or other
unique fields. The `ROWID` starts at `1` and increments by `1` every time you
add a new row, and since we added primary keys in ascending order then
`ROWID == PRIMARY KEY`.

The last user we added has `id=10000` and `ROWID=10000`, if you add a new user
with `id=20000` you'll see that `ROWID=10001`, not `20000`. You can also insert
10000 users in reverse order by tweaking the script that generates the SQL file
and you'll see that `ROWID != PRIMARY KEY` in all cases.

Now back to B-Tree traversal. In this example, key `0G1v` is located on page
`8` and points to row ID `25`. You can see in the path above that the index
traversal starts at page `3` and stops at `8` and then the data traversal starts
at page `4` and stops at `6`.

The index B-Tree is only used to obtain the `ROWID` of the record, and then the
data B-Tree is used to get the actual tuple (columns). You can
<kbd>CTRL</kbd> + <kbd>F</kbd> the `ROWID` in the data file to check that
the B-Tree traversal is correct.

You can also experiment with different page sizes by changing the value of
`SQLITE_PAGE_SIZE` at [`./src/pager.h`](./src/pager.h#27).

## Debugging

I added [`.vscode/launch.json`](./.vscode/launch.json) to easily step through
the source. I suggest setting up a break point on line 1090 at
[`./src/shell.c`](./src/shell.c#L1090) and then clicking on the Run/Debug icon.
You can see where the code goes from there by writing commands or SQL in the
`sqlite` shell that opens up.
