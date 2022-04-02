"use strict";

/* Env constats */
const mainFolder = "../";
const stdFolder = mainFolder + "std/";

/* Load a html file in a div defined by a certain id */
// fetch text from an html file located at 'url'
async function fetchHtmlAsText(url) {
    let response = await fetch(url);
    return await response.text();
}

// load html file content into div mentioned by id
async function loadHtml(id, html) {
    const contentDiv = document.getElementById(id);
    contentDiv.innerHTML = await fetchHtmlAsText(html);
}

// atach footer to body
async function addFooter() {
  let footer = document.getElementById("footer");
  footer.innerHTML = await fetchHtmlAsText(stdFolder + "footer.html");
}

// get page pathname
let currentLocation = window.location.pathname;

/* Clear active class from a navbar menu*/
function clearActive(navbar) {
  // reset active link to null
  let active = navbar.getElementsByClassName("active");
  active[0].className = active[0].className.replace("active", "");
}

/* Add 'active' to a navbar link */
function setActive(elementID) {
  document.getElementById(elementID).className += " active";
}

// load navigation menu
function loadNavHpc(sectionID) {
  loadHtml("navSections", stdFolder + "navSections.html").then(function () {
    let navbar = document.getElementById("navTab");
    clearActive(navbar);
    setActive(sectionID);
  });
}

function main() {
  // load header
  loadHtml("header", stdFolder + "header.html");
  console.log(stdFolder + "header.html");

  // attach footer
  addFooter();

  /* Load specific nav menu and HTML elements */
  if (currentLocation.includes("/Networking")) {
    loadNavHpc("Networking");
  } else if (currentLocation.includes("/Security")) {
    loadNavHpc("Security");
  }
  else {
    loadNavHpc("home");
  }
}

main();
