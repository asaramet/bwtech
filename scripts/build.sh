#!/usr/bin/env bash

MD="`dirname $(readlink -f ${0})`/.."
MD_FOLDER="${MD}/md_files"
OUT_FOLDER="${MD}/prod"

# Get the sections i.e list of folders in md_files
SECTIONS=`cd $MD_FOLDER && ls -d */ | cut -f1 -d'/'`

# Exit if no sections found
[[ -z $SECTIONS ]] && echo "No folders found in $MD_FOLDER" && exit 1

# List of sections in format ["x","y"]
SECTIONS_LIST=`for i in $SECTIONS; do echo \"$i\"; done`
SECTIONS_LIST="["`echo $SECTIONS_LIST | sed "s/ /, /g"`"]"

convert_js()
{
  # convert.js content
  cat << EOF
'use strict';

const marked = require('marked'); // converts markedown to html
const fs = require('fs');
const path = require('path');

// List of sections i.e folders in md_files
EOF

  echo "const sections = $SECTIONS_LIST"

  cat << EOF

// Loop through sections and convert files
sections.forEach(section => {
  // Convert section files
  fs.readdir(path.join('./md_files',section), (err, files) => {
    files.forEach( file => {
      const mdFile = path.join("./md_files", section, file);
      const htmlFile = path.join("./prod", section, path.basename(file, 'md').concat('html'));

      // write the head
      fs.writeFile(htmlFile, fs.readFileSync(path.join("./prod", "std", "head.html")), (err) => {
        if (err) {console.log(err);}

        // Convert the mdFile and write output to htmlFile
        fs.writeFile(htmlFile, marked(fs.readFileSync(mdFile, "utf8")), {flag:'a'}, (err) => {
          if (err) {console.log(err);}

          // add footer and JS scripts
          fs.writeFile(htmlFile, \`</section>
            <footer id="footer"></footer>
            <script type="text/javascript" src="js/main.js"></script>\`, {flag:'a'}, (err) => {
            if (err) {console.log(err);}

            if (section != "main") { // ignore adding the main.js if the section with this name exists
              fs.writeFile(htmlFile, '<script type="text/javascript" src="js/' + section + '.js"></script>', {flag:'a'}, (err) => {
                if (err) {console.log(err);}

                // append the foot
                fs.appendFile(htmlFile, fs.readFileSync(path.join("./prod", "std", "foot.html")), (err) => {
                  if (err) {console.log(err);}
                });
              });
            } else {
              fs.appendFile(htmlFile, fs.readFileSync(path.join("./prod", "std", "foot.html")), (err) => {
                if (err) {console.log(err);}
              });
            }
          });
        });
      });
    });
  });
});
EOF
}

main_js()
{
  # main.js file
  cat << EOF
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

  // attach footer
  addFooter();

  /* Load specific nav menu and HTML elements */
  // redundant if condition but neded for automation and later use of "else if"
  if (currentLocation.includes("/home")) {
    loadNavHpc("home");
  }
EOF

for i in ${SECTIONS}
  do
  cat << EOF
  else if (currentLocation.includes("/$i")) {
    loadNavHpc("$i");
  }
EOF
  done

  cat << EOF
  else {
    loadNavHpc("home");
  }
}

main();
EOF
}

section_js()
{
  # "$SECTION".js files
  local section=$1

  cat << EOF
'use strict';

// load ${section} specfic navbar
// loadHtml function is defined in main.js and loaded in the html file
loadHtml("navItems", stdFolder + "nav${section}.html").then(function () {
  let navbar = document.getElementById("navbar${section}");
  clearActive(navbar);

  if (currentLocation.includes("/${section}/index.html")) {
    setActive("About");
  }
EOF

  local articles=`ls ${OUT_FOLDER}/${section} | xargs basename -s ".html"`

  for article in $articles; do
    [[ $article == "index" ]] && continue
    echo "  else if (currentLocation.includes('$article')) { setActive('$article');}"
  done

  echo "});"
}

foot_html()
{
  cat << EOF

    <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js" integrity="sha384-DfXdz2htPH0lsSSs5nCTpuj/zy4C+OGpamoFVy38MVBnE+IbbVYUew+OrCXaRkfj" crossorigin="anonymous"></script>
    <script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.0/dist/umd/popper.min.js" integrity="sha384-Q6E9RHvbIyZFJoft+2mJbHaEWldlvI9IOYy5n3zV9zzTtmI3UksdQRVvoxMfooAo" crossorigin="anonymous"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.0/js/bootstrap.min.js" integrity="sha384-OgVRvuATP1z7JjHLkuOU7Xw704+h835Lr+6QL9UvYjZE3Ipu6Tp75j7Bh/kR0JKI" crossorigin="anonymous"></script>
  </body>
</html>
EOF
}

footer_html()
{
  echo "  <strong>© Alex Saramet</strong>&nbsp;|&nbsp;bwTech"
}

head_html()
{
  cat << EOF
<!DOCTYPE html>
<html lang="en" dir="ltr">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>saramet</title>
    <base href="..">
    <link rel="stylesheet" href="./css/styles.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Architects+Daughter&family=Prompt:wght@300&display=swap" rel="stylesheet">
    <!-- Bootstrap CSS -->
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.0/css/bootstrap.min.css"
      integrity="sha384-9aIt2nRpC12Uk9gS9baDl411NQApFmC26EwAOH8WgZl5MYYxFfc+NcPb1dKGj7Sk" crossorigin="anonymous">
  </head>
  <body>

    <header class="row" id="header"> </header>

    <section id="nav-menu" class="row">
      <!-- Navmenu to select section -->
      <div id="navSections"></div>

      <!-- Section specfic navmenu -->
      <div id="navItems"></div>
    </section>

    <!-- Content -->
    <section class="content">

EOF
}

header_html()
{
  cat << EOF
<div id="logo">
  <a href="."><img src="img/me.png" alt="My portrait Gorillaz style"></a>
</div>

<div id="title">
  <h1>Bandwith Tetrachloro-p-hydroquinone</h1>
</div>
EOF
}

navSections_html()
{
  local sections=$1
  cat << EOF
<!-- Navmenu to select a section/category -->

<nav class="navbar navbar-expand-md navbar-light navbar-custom">
  <!-- toggle button for responsive design -->
  <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navTab"
    aria-controls="#navTab" aria-expanded="false" aria-label="Toggle navigation">
    <span class="navbar-toggler-icon"></span>
  </button>
  <div class="collapse navbar-collapse" id="navTab">
    <div class="navbar-nav">
      <a class="nav-item nav-link active" id="home" href="index.html">Home</a>
EOF

  for section in ${SECTIONS}; do
    [[ $section == "main" ]] && continue
    echo "     <a class='nav-item nav-link' id='${section}' href='${section}/index.html'>${section}</a>"
  done

  cat << EOF
    </div>
  </div>
</nav>
EOF
}

navSection_html()
{
  local section=$1

  cat << EOF
<nav class='navbar navbar-expand-lg navbar-light'>
  <!-- toggle button for responsive design -->
  <button class='navbar-toggler' type='button' data-toggle='collapse' data-target='#navbar${section}'
    aria-controls='#navbar${section}' aria-expanded='false' aria-label='Toggle navigation'>
    <span class='navbar-toggler-icon'></span>
  </button>
  <div class='collapse navbar-collapse' id='navbar${section}'>
    <div class='navbar-nav'>
      <a class='nav-item nav-link active' id='About' href='${section}/index.html'>About</a>
EOF
  for i in `ls ${OUT_FOLDER}/${section}`; do
    [[ $i == "index.html" ]] && continue
    local id=`basename -s ".html" $i`
    echo "      <a class='nav-item nav-link' id='${id}' href='${section}/${i}'>${id}</a>"
  done

  cat << EOF
    </div>
  </div>
</nav>
EOF
}

css_file()
{
  cat << EOF
/* Global reset of paddings and margins for all HTML elements */
* { margin:0; padding: 0; }

body {
  width: 99vw;
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  align-items: center;
  font-family: 'Maven Pro', sans-serif;
}

h3, h4, p, li, td, th, .download-link {
  font-family: 'Prompt', sans-serif;
}

a, h1, h2 {
  font-family: 'Architects Daughter', cursive;
}

strong {
  color: #b6163d;
}

.row {
  display: flex;
  flex-direction: row;
  flex-wrap: nowrap;
  align-items: center;
}

footer {
  text-align: center;
  width: 80vw;
  opacity: 60%;
  margin-top: auto;
}

header {
  justify-content: space-between;
  width: 80vw;
  padding: 2vh 0;
}

/* Banner */
#logo {
  width: 10vw;
}

#logo > a > img {
  height: 10vh;
}

#title {
  width: 60vw;
}

#title > h1 {
  text-align: right;
}

/* Navbar */
.navbar .navbar-collapse .navbar-nav .nav-item {
  color: #b6163d;
}

.navbar .navbar-collapse .navbar-nav .nav-item.active {
  color: #193058;
}

.navbar .navbar-collapse .navbar-nav .nav-item:hover {
  color: #00aadc;
}

#nav-menu {
  width: 75vw;
  justify-content: space-between;
  align-items: flex-start;
}

#navSections, #navItems {
  width: 35vw;
}

#navTab {
  justify-content: flex-start;
}

.content {
  margin-top: 2vh;
  width: 75vw;
  flex-direction: column;
  align-items: flex-start;
}
EOF

  for section in ${SECTIONS}; do
    [[ section == "main" ]] && continue
    cat << EOF
#navbar${section} {
  justify-content: flex-end;
}
EOF
  done
}

# Images
[[ -d ${OUT_FOLDER} ]] && rm -fr ${OUT_FOLDER}
mkdir -p ${OUT_FOLDER}
cp -r ${MD}/source/img ${OUT_FOLDER}

# Create html folders
for i in $SECTIONS; do mkdir -p ${OUT_FOLDER}/$i; done

# HTML files
mkdir -p ${OUT_FOLDER}/std
foot_html > ${OUT_FOLDER}/std/foot.html
footer_html > ${OUT_FOLDER}/std/footer.html
head_html > ${OUT_FOLDER}/std/head.html
header_html > ${OUT_FOLDER}/std/header.html
# Build the convert.js File
convert_js > "${OUT_FOLDER}/convert.js"
node ${OUT_FOLDER}/convert.js

# Build html nav sections
navSections_html > ${OUT_FOLDER}/std/navSections.html
for i in ${SECTIONS}; do
  [[ $i == "main" ]] && continue
  navSection_html $i > ${OUT_FOLDER}/std/nav${i}.html
done


# Build the main.js File
mkdir -p ${OUT_FOLDER}/js
main_js > ${OUT_FOLDER}/js/main.js

# Build sections specfic js files
for i in ${SECTIONS}; do
  [[ $i == "main" ]] && continue
  section_js $i > ${OUT_FOLDER}/js/${i}.js
done

# CSS
mkdir -p ${OUT_FOLDER}/css
css_file > ${OUT_FOLDER}/css/styles.css
