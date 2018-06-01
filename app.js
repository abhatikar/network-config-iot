var express = require('express');
var app = express();

var bodyParser = require("body-parser");
app.use(bodyParser.urlencoded({ extended: false }));

app.get('/', function (req, res) {
    res.sendFile('/home/abhatikar/nodeapp/index.html');
});

app.post('/reboot', function (req, res) {
    const exec = require('child_process').exec;
    var netcfgcript = exec('ls -l ',
		    (error, stdout, stderr) => {
		    console.log(`${stdout}`);
		    console.log(`${stderr}`);
		    if (error !== null) {
		    console.log(`exec error: ${error}`);
		    }
		    });   
    res.send(' rebooted Successfully!');
});



app.post('/submit-ssid-data', function (req, res) {
    const exec = require('child_process').exec;
    var netcfgcript = exec('sh delete_network.sh ' + req.body.SSID +' ' + req.body.Password ,
		    (error, stdout, stderr) => {
		    console.log(`${stdout}`);
		    console.log(`${stderr}`);
		    if (error !== null) {
		    console.log(`exec error: ${error}`);
		    }
		    });   
    res.sendFile('/home/abhatikar/nodeapp/submit.html');
});

var server = app.listen(5000, function () {
    console.log('Node server is running..');
});
