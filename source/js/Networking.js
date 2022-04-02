'use strict';

// load Networking specfic navbar
// loadHtml function is defined in main.js and loaded in the html file
loadHtml("navItems", stdFolder + "navNetworking.html").then(function () {
  let navbar = document.getElementById("navbarNetworking");
  clearActive(navbar);

  if (currentLocation.includes("/Networking/index.html")) {
    setActive("About");
  } else if (currentLocation.includes("A.Work")) {
    setActive("A.Work");
  } else if (currentLocation.includes("B.Work")) {
    setActive("B.Work");
  }
});
