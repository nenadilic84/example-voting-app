Instavote
=========

Getting started
---------------

Download [Docker for Mac or Windows](https://www.docker.com).

Run in root directory:

    $ docker-compose up

The vote app will be running at [http://localhost:5000](http://localhost:5000)
The results will be running at [http://localhost:5001](http://localhost:5001)

Architecture
-----

![Architecture diagram](architecture.png)

* A Python webapp which lets you vote between two options
* A Redis queue which collects new votes
* A Java worker which consumes votes and stores them in…
* A Postgres database backed by a Docker volume
* A Node.js webapp which shows the results of the voting in real time

Tugbot Demo
----
[Demo Flow](./DEMO-FLOW.md)

Tugbot Swarm Demo
----
[Swarm Demo Flow](./DEMO-FLOW-SWARM.md)
