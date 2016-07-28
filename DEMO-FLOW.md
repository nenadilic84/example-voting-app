Demo Flow (single machine)
=========

Pre-requests
------------

1. Docker 1.12 for Mac (or Windows)
2. Bash


1. Deploy Voting App (as services)
-----

Run in root directory to create new swarm cluster and deploy all application services on it.

    $ ./1_deploy.sh

The new Swarm cluster (one master node) will be created and the app will be deployed there as services. Each service can be scaled and updated later with corresponding `docker service scale/update` command.

The voting app will run at [http://localhost:5000](http://localhost:5000)
The results app will run at [http://localhost:5001](http://localhost:5001)

**Note:** run `docker service ls` command to see that all services are up and running

2. Deploy Tugbot Testing Framework (as services)
----

Run in root directory to deploy all Tugbot services on it.

    $ ./2_deploy_tugbot.sh

**Note:** run `docker service ls` command to see that all services are up and running

3. Open Voting App and Tugbot Dashboard
----

    $ ./3_open_app.sh

[Tugbot Dashboard](http://localhost:8080) **TODO**: now it is configured to run on `8080`. make sure to run it on port `4000`.

**Expected:** see empty dashboard.

4. Run Integration and Functional Tests
----
    
    $ ./4_run_tests.sh
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

Run Pumba (as "interactive" Docker container) to introduce 3 seconds delay for all egress traffic from `result-app` container. Network emulation is activated every minute and lasts for 30 seconds only, after that connection is restored to work normally.
To stop network emulation, exit Pumba with `Ctrl-C`; wait till Pumba exits gracefully.

    $ ./7_run_pumba.sh
    $ # Use Ctrl-C to stop Pumba

**Expected**: some test might fail now, but should pass, once network emulation stopped.

8. Cleanup
----
    $ ./8_clean_tugbot.sh
    $ ./9_clean.sh
