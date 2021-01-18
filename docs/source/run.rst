Starting application
--------------------

Running application (web server)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

To run with default (SQLite) database and default url (localhost:8000):

::

    rfhub2

To run with PostgreSQL database:

::

    RFHUB_DB_URI=postgresql://postgres:postgres@localhost:5432/postgres rfhub2

To run application using docker image with default (SQLite) database:

::

    docker run -it -p 8000:8000 pbylicki/rfhub2

To run application using docker image with Postgres database:

::

    docker run -it -p 8000:8000 --network=host \
    -e RFHUB_DB_URI="postgresql://postgres:postgres@localhost:5432/postgres" \
    pbylicki/rfhub2:postgres

Populating application with keywords documentation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

To populate application running on localhost:

::

    rfhub2-cli ../your_repo ../your_other_repo

To populate app running on another host, with non-default credentials:

::

    rfhub2-cli -a http://your_host:8000 -u user -p password \
    ../your_repo ../your_other_repo

To populate app but to skip loading RFWK installed libraries:

::

    rfhub2-cli --no-installed-keywords ../your_repo ../your_other_repo

Rfhub2-cli for keywords documentation can be run in three load-modes:
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

-  | ``insert``, default mode, that will clean up existing collections app
   | and load all collections found in provided paths
   | ``rfhub2-cli --load-mode=insert ../your_repo ../your_other_repo``
-  | ``append``, which will only add collections form provided paths
   | ``rfhub2-cli --load-mode=append ../your_repo ../your_other_repo``
-  | ``update``, which will compare existing collections with newly found
   | ones, and update existing, remove obsolete and add new ones
   | ``rfhub2-cli --load-mode=update ../your_repo ../your_other_repo``
-  | ``merge``, adds new and updates only matched collections, does nothing with not matched ones.
   | ``rfhub2-cli --load-mode=merge ../your_repo ../your_other_repo``

Populating application with keywords execution statistics
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Gather keywords execution statistics:
''''''''''''''''''''''''''''''''''''''''

::

    rfhub2-cli --mode=statistics ../your_exec_dir ../your_other_exec_dir

Since execution statistics from specific run does not change over time, there is no load-mode needed.
Application will scan all of the executions and try to send aggregated data from each run to application.
rfhub2-cli will complain that there are existing statistics for particular timestamp,
and will proceed with next ones.

Full list of rfhub2-cli options:
''''''''''''''''''''''''''''''''

::


  -a, --app-url               Specifies IP, URI or host of rfhub2 web
                              application. Default value is
                              http://localhost:8000.

  -u, --user                  Specifies rfhub2 user to authenticate on
                              endpoints that requires that. Default value
                              is rfhub.

  -p, --password              Specifies rfhub2 password to authenticate on
                              endpoints that requires that. Default value
                              is rfhub.

  --no-installed-keywords     Flag specifying if package should skip
                              loading commonly installed libraries, such
                              as BuiltIn, Collections, DateTime etc.

  -m, --mode [keywords|statistics]
                              Choice parameter specifying what kind of
                              data package should add:

                              - `keywords` - default value, application is
                              working with keywords documentation

                              - `statistics` - application is working with
                              data about keywords execution.

  -l, --load-mode [insert|append|update|merge]
                              Choice parameter specifying in what load
                              mode package should run:

                              - `insert` - default value, removes all
                              existing collections from app and add ones
                              found in paths

                              - `append` - adds collections found in paths
                              without removal of existing ones

                              - `update` - removes collections not found
                              in paths, adds new ones and updates existing
                              ones.

                              - `merge`, adds new and updates only matched
                              collections, does nothing with not matched ones.

