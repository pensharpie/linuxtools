##
##  This is only for FEDORA 35/36
##  - FEDORA-35 is unsupported. for honister.
##  - you will see
#   - WARNING: Host distribution "fedora-35" has not been validated with this version of the build system; you may possibly experience unexpected failures. It is recommended that you use a tested distribution.
# so, 
# -- fix to change/add prefix  "from pysqlite3._sqlite3"
cp ./dbapi2.py /usr/local/lib/python3.10/sqlite3/dbapi2.py
# comment WAL mode pragma
cp ./persist_data.py ~/el/poky/bitbake/lib/bb/persist_data.py
# comment WAL mode pragma
cp ./__init__.py ~/el/poky/bitbake/lib/hashserv/__init__.py
