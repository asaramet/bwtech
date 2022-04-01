'use strict';

const express = require('express');
const fs = require('fs');
const logger = require('morgan');

const app = express();
app.use(logger('dev'));
//app.use(express.static('./bwGRiD'));
app.use(express.static('./prod'));

app.use(function(req, res, next) {
  //fs.createReadStream('./bwGRiD/index.html').pipe(res);
  fs.createReadStream('./prod/index.html').pipe(res);
});

module.exports = app;
