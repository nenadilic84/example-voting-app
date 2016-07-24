var request = require('request');
var pg = require('pg');

describe('E2E voting tests', function () {

var appHost='localhost:5000';
var dbHost='localhost';
if(process.env.appHost) {
  appHost=process.env.appHost;
}
if(process.env.dbHost) {
  dbHost=process.env.dbHost
}


  var votesA=0, votesB=0;

  it('check database before voting', function (done) {
    pg.connect('postgres://postgres@'+dbHost+'/postgres').then(function (client) {
      client.query('SELECT vote, COUNT(id) AS count FROM votes GROUP BY vote', [], function (errrr, result) {
        if (errrr) {
          console.error("Error performing query: " + errrr);
        } else {
          result.rows.forEach(function (row) {
            if (row.vote === 'a') {
              votesA = row.count;
            } else if (row.vote === 'b') {
              votesB = row.count;
            }
          }, result);
          console.log('before - votesA: ' + votesA);
          console.log('before - votesB: ' + votesB);
          done();
        }
      });
    }, function (err) {
      console.log('error');
    });
  });

  it('vote cats and verify', function (done) {
    var options = {
      url: 'http://'+appHost,
      method: 'POST',
      formData: {
        vote: 'a'
      }
    };
    request(options, function (error, resp, body) {
      expect(resp.statusCode).equal(200);
      var ind = body.indexOf('var vote');
      expect(ind).to.be.above(-1);
      var votedA = body.substring(ind, ind + 15).indexOf('= "a"');
      var votedB = body.substring(ind, ind + 15).indexOf('= "b"');
      expect(votedA).to.be.above(1);
      expect(votedB).equal(-1);
//      console.log(body);
      done();
    })
  });


  it('check database after voting', function (done) {
    var voteA = 0;
    var voteB = 0;
    pg.connect('postgres://postgres@'+dbHost+'/postgres').then(function (client) {
      client.query('SELECT vote, COUNT(id) AS count FROM votes GROUP BY vote', [], function (errrr, result) {
        if (errrr) {
          console.error("Error performing query: " + errrr);
        } else {
          result.rows.forEach(function (row) {
            if (row.vote === 'a') {
              voteA = row.count;
            } else if (row.vote === 'b') {
              voteB = row.count;
            }
          }, result);

          console.log('voteA=' + voteA);
          console.log('voteB=' + voteB);
          if(voteA){
            expect(voteA-votesA).equal(1);
          }
          if(voteB){
            expect(voteB-votesB).equal(0);
          }
          done();
        }
      });
    }, function (err) {
      console.log('error');
    });
  });

});
