Demo Flow (single machine)
=========

Pre-requests
------------

1. Docker 1.12 for Mac (or Windows)
2. Docker Compose
3. Bash


1. Deploy Voting App 
----

Run in root directory: 

    $ ./1_deploy.sh
	
Docker-compose starts all 5 containers, the example-voting-application consists of.

The voting app will run at [http://localhost:5000](http://localhost:5000)  
The results app will run at [http://localhost:5001](http://localhost:5001)

2. Deploy Tugbot Testing Framework
----

Run in root directory:

    $ ./2_deploy_tugbot.sh

Docker-compose starts tugbot, tugbot-collect and tugbot-result-service.  
It also starts Elasticsearch and Kibana containers; while it is not mandatory to run both of them on the same host, we added the containers to this script to make the demo preparation easier.  
Elasticsearch serves as a database for the results collected by tugbot and Kibana is the UI layer.

Run in root directory:

    $ ./2a_configure_kibana.sh

This script configures some objects for Kibana to make seeing the results easier.  
*** NOTE: *** The UI is still not usable until tugbot sends at least 1 result to Elasticsearch.

3. Open Voting App and Tugbot Dashboard
----

    $ ./3_open_app.sh

[Tugbot Dashboard (Kibana)](http://localhost:5061)

**Expected:** see empty dashboard.

4. Run Integration and Functional Tests
----
    
    $ ./4_run_tests.sh
    $ TODO: run selected docker-bench-tests tests

**Expected:** ALL test must pass now.

5. Modify Application
----

Run in root directory:
 
    $ ./1_deploy.sh bad
	
**Expected:** Two tests should fail now. "Bad" image contains a bug that prevents the verification in application UI that user has voted as expected. Visually, there is no v sign near your selection and so 2 tests related to the verification are failed. Others still OK, since other parts of UI as well as the backend data flow are not affected by the bug.

6. Fix Application
----

Run in root directory:
 
    $ ./1_deploy.sh

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
