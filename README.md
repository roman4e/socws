# Socat-driven web server handled by bash and perl handlers
It was written just for experience.

Requires socat v1.7.3+

Change work dir into the project directory before start.

* Run:
`sudo ./alived username ./handler`
`sudo ./alived username ./phandler`

  Where username is your default user (not root).

* Stop:
`sudo ./alived -k`

* Restart:
`sudo ./alived -s`

* Debug handler:
`sudo ALIVED_DEBUG=1 ./alived username ./handler`

* Debug daemon:
`sudo ALIVED_BASHDEBUG=1 ./alived username ./handler`


Realized first level mapping:
_/logs_ and _/logs/asdf_ is mapped on *logs* handler.

Handlers are placed in /routing folder.
