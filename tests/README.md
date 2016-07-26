##Tests for example-voting-app

### Dockerization:
- Build
  - docker build -t gaiadocker/example-voting-app-tests .
- Run standalone
  - docker run -it --name votests  gaiadocker/example-voting-app-tests
- Run for example-voting-app swarm
  - docker service create --name votests --network voteapp --env appHost=voting-app:80 --env dbHost=db --restart-condition none gaiadocker/example-voting-app-tests
- NOTES:
  - if appHost and dbHost are not provided, default values applied (localhost:5000 and localhost accordingly)


### Functional:
- Functional tests - voting
  - Name: open ui and check title
    - How to fail:
      - modify title in vote/templates/index.html so than no 'vs' appears in the title
      - modify option_a or option_b in vote/app.py
  - Name: vote cats
    - How to fail:
      - comment out vote=vote line in vote/app.py

### End-to-end:
- Integration tests - voting
  - Name: check database before voting
    - How to fail:
      - stop Postgres DB
  - Name: vote cats and verify
    - How to fail:
      - comment out vote=vote line in vote/app.py
  - Name: check database after voting
    - How to fail:
      - stop Postgres DB
      - modify UpdateVote function in worker/src/Worker/Program.cs (e.g., change table name from votes to vote in INSERT INTO and UPDATE statements)



## Extra - how to switch from Cats&Dogs to Rabbits&Fishes
NOTE: This change should not affect tests behaviour

### Voting
- change in vote/app.py:
  - option_a = os.getenv('OPTION_A', "Rabbits")
  - option_b = os.getenv('OPTION_B', "Fishes")

### Results
- change in result/views/index.html
  - \<title\>Rabbits vs Fishes -- Result\</title\>
  - \<div class="label"\>Rabbits\</div\>
  - \<div class="label"\>Fishes\</div\>
