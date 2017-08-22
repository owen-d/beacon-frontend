'use strict';


var Elm = require('../elm/Main.elm');
var mountNode = document.getElementById('main');

// .embed() can take an optional second argument. This would be an object describing the data we need to start a program, i.e. a userID or some token
var app = Elm.Main.embed(mountNode);

app.ports.storageGet.subscribe(function(key) {
  app.ports.storageReceive.send([key, localstorage.getItem(key)]);
});

app.ports.storageSet.subscribe(function(key, val) {
  localStorage.setItem(key, val);
  app.porst.storageSetReceive.send(null);
});
