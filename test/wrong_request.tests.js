var BaaSServer = require('..').Server;

var Socket = require('net').Socket;

describe('wrong requests', function () {
  var server, address;

  before(function (done) {

    server = new BaaSServer({logLevel: 'error'});

    server.start(function (err, addr) {
      if (err) return done(err);
      address = addr;
      done();
    });
  });

  after(function () {
    server.stop();
  });

  it('should disconnect the socket on unknown message', function (done) {
    var socket = new Socket();
    var ResponseMessage  = require('../messages').Response;
    // I'm going to make the server fail by sending a Response message from the client.
    socket.connect(address.port, address.address)
      .once('connect', function () {
        socket.write(new ResponseMessage({
          request_id: '123',
        }).encodeDelimited().toBuffer());
      }).once('close', function () {
        done();
      });

  });

});
