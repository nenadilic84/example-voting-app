Demo Flow (single machine)
=========

Pre-requests
------------

1. Docker 1.12 for Mac (or Windows)
2. Bash


1. Deploy Voting App (as services)
-----

Run in root directory to create new swarm cluster and deploy all application services on it.

    $ ./deploy.sh

The new Swarm cluster (one master node) will be created and the app will be deployed there as services. Each service can be scaled and updated later with corresponding `docker service scale/update` command.

The voting app will run at [http://localhost:5000](http://localhost:5000)
The results app will run at [http://localhost:5001](http://localhost:5001)

2. Deploy Tugbot Testing Framework (as services)
----

Run in root directory to deploy all Tugbot services on it.

    $ ./deploy_tugbot.sh

3. Open Tugbot Dashboard
----

[Thubot Dashboard](http://localhost:4000) **TODO**: make sure to run it on port `4000`.

**Expected:** see empty dashboard.

4. Run Integration and Functional Tests
----

    $ docker service create --name votests \
        --network voteapp \
        --env appHost=voting-app:80 \
        --env dbHost=db \
        --restart-condition none \
        gaiaadm/example-voting-app-tests

    $ TODO: run selected docker-bench-tests tests

**Expected:** ALL test must pass now.

5. Modify Application
----

**TODO:** introduce defect; build new image (or use prepared images); update service

**Expected:** Some test must fail now.

6. Fix Application
----

**TODO:** fix defect and update service.

**Expected:** All test must pass now.

7. Simulate network problems
----

**TODO**: @alexei

**Expected**: some test might fail now, but should pass, once network emulation stopped.

8. Cleanup
----
    $ ./clean.sh
