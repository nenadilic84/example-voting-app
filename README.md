Instavote
=========

Getting started
---------------

Download [Docker for Mac or Windows](https://www.docker.com).

Run in this directory:

    $ docker-compose up

The app will be running at [http://localhost:5000](http://localhost:5000), and the results will be at [http://localhost:5001](http://localhost:5001).

Run on Docker 1.12 with Swarm mode
-----

Run in this directory

    $ ./deploy.sh

The new Swarm cluster (one master node) will be created and the app will be deployed there as services. Each service can be scaled and updated later with corresponding `docker service scale/update` command.

The app will be running at [http://localhost:5000](http://localhost:5000), and the results will be at [http://localhost:5001](http://localhost:5001).

Run Integration and Functional Tests
----

    docker service create --name votests --network voteapp --env appHost=voting-app:80 --env dbHost=db --restart-condition none gaiaadm/example-voting-app-tests npm test

Architecture
-----

![Architecture diagram](architecture.png)

* A Python webapp which lets you vote between two options
* A Redis queue which collects new votes
* A Java worker which consumes votes and stores them in…
* A Postgres database backed by a Docker volume
* A Node.js webapp which shows the results of the voting in real time
