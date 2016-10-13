
Demo Flow (Swarm Cluster)
=========

Pre-requests
------------

1. Docker 1.12 for Mac (or Windows)
2. Bash
4. Browser on `localhost` with network accessibility (open ports) to docker host

0. Create Swarm cluster
----

Run in cloned directory:

    $ swarm/0_swarm_cluster_mac.sh

New Swarm cluster will be created on localhost. By default, Swarm cluster will consist from one master and 3 worker nodes. It's possible to control number of worker nodes by overwriting `NUM_WORKERS` environment variable.
We are using Docker-in-Docker to run swarm nodes, so you do not need to install any VM soft on your machine.

**Note:** in case of failure try to run this script once again

To see your Swarm cluster, open [Swarm Visualizer](http://localhost:8000).

- the voting app will run at `http://localhost:<x>5000`
- the results app will run at `http://localhost:<x>5001]`
- ... where `x` represent worker index: 1,2,3... (check Swarm Visuzalizer for right index)

1. Deploy Voting application

Run in cloned directory:

    $ swarm/1_deploy.sh

2. Deploy Tugbot Testing Framework
----

Run in cloned directory:

    $ ./2_deploy_tugbot.sh

The following Docker services will run: `es`, `kibana, ``tugbot-leader`, `tugbot-run`, `tugbot-collect` and `tugbot-result-service-es`.
Elasticsearch serves as a database for the results collected by tugbot and Kibana is the UI layer.

3. Import Dashboard Setting Into Kibana
----

Run in cloned directory:

    $ swarm/3_configure_kibana.sh

This script configures some objects for Kibana to make seeing the results easier.
Kibana dashboard is now accessible at `http://localhost:<x>5601`

**NOTE:** The UI is still not usable until `tugbot` sends at least 1 result to Elasticsearch

4. Run Integration and Functional Tests
----

Run in cloned directory:

    $ swarm/4_run_tests.sh

**Expected:** ALL test must pass now.
You should see now the test results in Kibana Dashboard

5. Modify Application
----

Run in cloned directory:

    $ swarm/5_bug_on_off.sh

This script will re/deploy **bad** and **good** version of Vote app

6. Fix Application
----

Run in cloned directory:

    $ swarm/1_deploy.sh

**Expected:** We returned the "Good" image, hence - All tests should pass now.
You should see now the test results in Kibana Dashboard at [http://localhost:5601](http://localhost:5601)

7. Simulate network problems
----

Run Pumba (as "interactive" Docker container) to introduce 3 seconds delay for all egress traffic from `result-app` container. Network emulation is activated every minute and lasts for 30 seconds only, after that connection is restored to work normally.
To stop network emulation, exit Pumba with `Ctrl-C`; wait till Pumba exits gracefully.

    $ swarm/7_run_pumba.sh
    $ # Use Ctrl-C to stop Pumba

**Expected**: some test might fail now, but should pass, once network emulation stopped.

8. Cleanup
----

To clean tugbot only:

    $ swarm/8_clean_tugbot.sh

To clean tugbot and the voting app:

    $ swarm/9_clean.sh

To destroy local Swarm cluster:

    $ swarm/9_x_clean_swarm_mac.sh

**NOTE:** The scripts above leave a volume on the docker host, used by elasticsearch, so if you re-deploy tugbot this volume will reattached to elasticsearch and you will see your old data in Kibana.
If you want to remove the volume you need to add the `all` param to the scripts, for instance: `./8_clean_tugbot.sh all` and `./9_clean.sh all`
