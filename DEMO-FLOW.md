
Demo Flow (single machine)
=========

[![demo video](https://img.youtube.com/vi/s0AJnEUrlt4/0.jpg)](https://www.youtube.com/embed/s0AJnEUrlt4)

Pre-requests
------------

1. Docker 1.12 for Mac (or Windows)
2. Docker Compose
3. Bash
4. Browser on `localhost` with network acessability (open ports) to docker host 

1. Deploy Voting App 
----

Run in cloned directory: 

    $ ./1_deploy.sh
	
Docker-compose starts all 5 containers, the example-voting-application consists of.

The voting app will run at [http://localhost:5000](http://localhost:5000)  
The results app will run at [http://localhost:5001](http://localhost:5001)

2. Deploy Tugbot Testing Framework
----

Run in cloned directory:

    $ ./2_deploy_tugbot.sh

Docker-compose starts tugbot, tugbot-collect and tugbot-result-service-es.  
It also starts Elasticsearch and Kibana containers; while it is not mandatory to run both of them on the same host, we added the containers to this script to make the demo preparation easier.  
Elasticsearch serves as a database for the results collected by tugbot and Kibana is the UI layer.

3. Import Dashboard Setting Into Kibana 
----

Run in cloned directory:

    $ ./3_configure_kibana.sh

This script configures some objects for Kibana to make seeing the results easier.  
Kibana dashboard is now acessible at [http://localhost:5601](http://localhost:5601)

**NOTE:** The UI is still not usable until tugbot sends at least 1 result to Elasticsearch

4. Run Integration and Functional Tests
----
    
Run in cloned directory:

    $ ./4_run_tests.sh
    $ TODO: run selected docker-bench-tests tests

**Expected:** ALL test must pass now.
You should see now the test results in Kibana Dashboard at [http://localhost:5601](http://localhost:5601)

5. Modify Application
----

Run in cloned directory:
 
    $ ./1_deploy.sh bad
	
**Expected:** Two tests should fail now. "Bad" image contains a bug that prevents the verification in application UI that user has voted as expected. Visually, there is no v sign near your selection and so 2 tests related to the verification are failed. Others still OK, since other parts of UI as well as the backend data flow are not affected by the bug.
You should see now the test results in Kibana Dashboard at [http://localhost:5601](http://localhost:5601)

6. Fix Application
----

Run in cloned directory:
 
    $ ./1_deploy.sh

**Expected:** We returned the "Good" image, hence - All tests should pass now.
You should see now the test results in Kibana Dashboard at [http://localhost:5601](http://localhost:5601)

7. Simulate network problems
----

Run Pumba (as "interactive" Docker container) to introduce 3 seconds delay for all egress traffic from `result-app` container. Network emulation is activated every minute and lasts for 30 seconds only, after that connection is restored to work normally.
To stop network emulation, exit Pumba with `Ctrl-C`; wait till Pumba exits gracefully.

    $ ./7_run_pumba.sh
    $ # Use Ctrl-C to stop Pumba

**Expected**: some test might fail now, but should pass, once network emulation stopped.

8. Cleanup
----

To clean tugbot only:

    $ ./8_clean_tugbot.sh

To clean tugbot and the voting app:

    $ ./9_clean.sh


**NOTE:** The scripts leave a volume on the docker host, used by elasticsearch, so if you re-deploy tugbot this volume will reattached to elasticsearch and you will see your old data in Kibana.
If you want to remove the volume you need to add the `all` param to the scripts, for instance: `./8_clean_tugbot.sh all` and `./9_clean.sh all`
