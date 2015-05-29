% Chat server readme
% by Noah Schoem

Acknowledgements: This readme is adapted from the readme 
for the CS 240h Lab 2, which can be found at:
http://www.scs.stanford.edu/14sp-cs240h/labs/lab2.html

Operation: This program executes a basic chat server. 
It supports any number of clients and allows 
them to join and leave at any time.

Notes on initializing the server:
* To run the chat server, build the project (see below for how to
  do this).  The project can then be run by invoking

        cabal run
  in your favorite terminal session.
* Clients and the server communicate over TCP.
* The server reads the `CHAT_SERVER_PORT` environment variable,
  which should contain an `Int`, and listens on that port for clients.
  If `CHAT_SERVER_PORT` is undefined or empty, the server will default
  to port 4242.  If `CHAT_SERVER_PORT` is defined but is not a valid 
  port number, the server will crash.  I have not tested the myriad
  ways in which this might happen.

Notes on connecting clients to the server:
* To connect to the server, type

        telnet [host] [port]

  into your favorite terminal session.  This will connect you to the server.
  To exit the server, type the escape character 
  (which is ^] on my system) and then type ^D to close the connection.
* Clients have a username picked for them automatically by the
  server. Usernames are simply a number, and the server simply
  maintains a counter (starting from 1) for which client this is by
  ordering of connection. I.e., first client to connect gets username
  1, second client gets username 2.
* When a client C with username U joins the server, the server broadcasts
  this message to all clients (including C): "U has joined".
  Likewise, when a client C with username U quits the server, 
  the server broadcasts: "U has left".


## Example Transcript

1 has joined
2 has joined
1: hello!
2: hi
3 has joined
3: hi
1 has left
2: hi 3


## Building the executable

To get up and running (using Cabal), issue the following commands:

        cabal sandbox init

This will initiate a self-contained build environment where any
dependencies you need are installed locally in the current directory.
This helps avoid cabal hell. If your
version of cabal is older and doesn't have the `sandbox`
command, then just proceed without it and it should all be fine.

Next, you want to build the project. For that, issue the following
commands:

        cabal install --only-dependencies --enable-tests
        cabal configure --enable-tests
        cabal build

After that, you should also be able to run the test harness simply by
typing:

        cabal test
