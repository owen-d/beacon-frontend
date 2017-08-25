'use strict';


var Elm = require('../elm/Main.elm');
var mountNode = document.getElementById('main');

// .embed() can take an optional second argument. This would be an object describing the data we need to start a program, i.e. a userID or some token
var app = Elm.Main.embed(mountNode, {jwt: localStorage.getItem('sharecrows-jwt')});

// localstorage support

app.ports.storageGet.subscribe(function(key) {
  app.ports.storageReceive.send([key, localstorage.getItem(key)]);
});

app.ports.storageSet.subscribe(function(tuple) {
  localStorage.setItem(tuple[0], tuple[1]);
  app.ports.storageSetReceive.send(null);
});

app.ports.storageRemove.subscribe(function(key) {
  localStorage.removeItem(key);
});
