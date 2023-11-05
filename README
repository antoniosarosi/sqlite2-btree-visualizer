# SQLite 2.8.1 for learning / debugging

Original source code downloaded from here:
https://www.sqlite.org/src/info/590f963b6599e4e2

## Why SQLite 2.8.1 ?

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

SQLite 2.x.x has the function `sqliteBtreePageDump` which
prints the entire BTree to STDOUT, including page numbers, children pointers and
table data:

```text
PAGE 4:
cell  0: i=8..47      chld=48   nk=4    nd=21   payload=...\...347.User Nam
right_child: 49
freeblock  0: i=48..1023   size=976  total=976

PAGE 48:
cell  0: i=8..43      chld=5    nk=4    nd=19   payload=.......28.User Name
cell  1: i=44..79     chld=6    nk=4    nd=19   payload=...:...57.User Name
cell  2: i=80..115    chld=9    nk=4    nd=19   payload=...W...86.User Name
cell  3: i=116..155   chld=11   nk=4    nd=21   payload=...r...113.User Nam
cell  4: i=156..195   chld=12   nk=4    nd=21   payload=.......139.User Nam
cell  5: i=196..235   chld=14   nk=4    nd=21   payload=.......165.User Nam
cell  6: i=236..275   chld=15   nk=4    nd=21   payload=.......191.User Nam
cell  7: i=276..315   chld=17   nk=4    nd=21   payload=.......217.User Nam
cell  8: i=316..355   chld=19   nk=4    nd=21   payload=.......243.User Nam
cell  9: i=356..395   chld=20   nk=4    nd=21   payload=.......269.User Nam
cell 10: i=396..435   chld=22   nk=4    nd=21   payload=...(...295.User Nam
cell 11: i=436..475   chld=23   nk=4    nd=21   payload=...B...321.User Nam
right_child: 25

...
```

The function is called [here](./src/btree.c#L2659), you can comment it out to
remove the print statements. As for generating the BTree I suggest creating a
simple table and populating it with about 1000 records. First, if you're still
located in the `build` directory, go back to the root, then create the database
file and start the `sqlite` shell program:

```bash
cd ..
touch db.sqlite
./build/sqlite ./db.sqlite
```

Now create a simple table:

```sql
CREATE TABLE users (id INT PRIMARY KEY, name VARCHAR(255));
```

Then open another terminal and generate a script to insert many users at once:

```bash
file="insert.sql"

echo "BEGIN TRANSACTION;" > $file
for i in {1..1000}; do
    echo "INSERT INTO users (id, name) VALUES ($i, 'User Name $i');" >> $file
done
echo "COMMIT;" >> $file

```

Go back to `sqlite` shell again and execute the SQL script:

```bash
.read insert.sql
```

Next time you insert a new row, the entire BTree is going to be printed again,
so you can simply close the current `sqlite` shell
using <kbd>CTRL</kbd> + <kbd>D</kbd> or `.quit`, open a new one and redirect
STDOUT to a file:

```bash
./build/sqlite ./db.sqlite > pages.txt
```

You won't see any output, but you can still write SQL statements:

```sql
INSERT INTO users (id, name) VALUES (0, 'Print the Btree!');
```

Now you can close the shell again and you should see all the pages in your file.

## Debugging

I added [`.vscode/launch.json`](./.vscode/launch.json) to easily step through
the source. I suggest setting up a break point on line 1000 at
[`./src/shell.c`](./src/shell.c#1000) and then clicking on the Run/Debug icon.
You can see where the code goes from there by writing commands or SQL in the
`sqlite` shell that opens up.
