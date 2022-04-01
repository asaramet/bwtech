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

function main() {
  // load header
  loadHtml("header", stdFolder + "header.html");
  console.log(stdFolder + "header.html");

  // attach footer
  addFooter();
}

main();
