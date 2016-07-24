var request = require('request');
var pg = require('pg');

var appHost='localhost:5000';
var dbHost='localhost';
if(process.env.appHost) {
  appHost=process.env.appHost;
}
if(process.env.dbHost) {
  dbHost=process.env.dbHost
}

describe('Voting page tests', function () {

  console.log('AppHost: '+appHost);
  console.log('DbHost: '+dbHost);

  it('open ui and check title', function (done) {
    var options = {
      url: 'http://'+appHost,
      method: 'GET'
    };
    request(options, function (error, resp, body) {
      expect(resp.statusCode).equal(200);
      var titleStart = body.indexOf('<title>');
      var titleEnd = body.indexOf('</title>');
      expect(body.substring(titleStart + '<title>'.length, titleEnd - 1).indexOf(' vs ')).to.be.above(-1);
//      console.log(body);
      done();
    })
  });

  it('vote cats', function (done) {
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

});
