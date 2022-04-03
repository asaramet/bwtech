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

// Convert function. Input: 1.MD file, 2.converted HTML file
function convert(inMD, outHTML) {
  // Convert the inMD file and write to outHTML
  fs.writeFile(outHTML, marked(fs.readFileSync(inMD, "utf8")), {flag:'a'}, (err)=>{
    if (err) {console.log(err);}
  });
}

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
      fs.writeFile(htmlFile, fs.readFileSync(path.join("./source", "html", "std", "head.html")), (err) => {
        if (err) {console.log(err);}
      });

      // convert and append data
      convert(mdFile, htmlFile);

      // add footer
      fs.writeFile(htmlFile, '<footer id="footer"></footer>', {flag:'a'}, (err) => {
        if (err) {console.log(err);}
      });

      // add JS scripts
      fs.writeFile(htmlFile, '<script type="text/javascript" src="js/main.js"></script>', {flag:'a'}, (err) => {
        if (err) {console.log(err);}

        if (section != "main") { // ignore adding the main.js if the section with this name exists
          fs.writeFile(htmlFile, '<script type="text/javascript" src="js/' + section + '.js"></script>', {flag:'a'}, (err) => {
            if (err) {console.log(err);}

            // append the foot
            fs.appendFile(htmlFile, fs.readFileSync(path.join("./source", "html", "std", "foot.html")), (err) => {
              if (err) {console.log(err);}
            });
          });
        } else {
          fs.appendFile(htmlFile, fs.readFileSync(path.join("./source", "html", "std", "foot.html")), (err) => {
            if (err) {console.log(err);}
          });
        }
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
    <!-- JavaScript Bundle with Popper -->
    <!--
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"
      integrity="sha384-ka7Sk0Gln4gmtz2MlQnikT1wXgYsOg+OMhuP+IlRH9sENBO0LRn5q+8nbTov4+1p" crossorigin="anonymous"></script>
    -->

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
    <link href="https://fonts.googleapis.com/css2?family=Josefin+Slab:wght@400;700&family=Maven+Pro:wght@400;700&display=swap"
      rel="stylesheet">
    <!-- Bootstrap CSS -->
    <!--
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet"
      integrity="sha384-1BmE4kWBq78iYhFldvKuhfTAU6auU8tT94WrHftjDbrCEXSU1oBoqyl2QvZ6jIW3" crossorigin="anonymous">
    -->
  </head>
  <body>

    <header class="row" id="header"> </header>

    <section id="nav-menu" class="row">
      <!-- Navmenu to select section -->
      <div id="navSections"></div>

      <!-- Section specfic navmenu -->
      <div id="navItems"></div>
    </section>

    <!-- Loaded objects on the home page -->
EOF
}

header_html()
{
  cat << EOF
<a href="."><img src="img/me.jpg" alt="My portrait Gorillaz style"></a>
<h1>Bandwith Tetrachloro-p-hydroquinone</h1>
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
      <a class="nav-item nav-link" id="home" href="index.html">Home</a>
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
  <button class='navbar-toggler' type='button' data-toggle='collapse' data-target='#navbar${section}Info'
    aria-controls='#navbar${section}Info' aria-expanded='false' aria-label='Toggle navigation'>
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

# Create html folders
for i in $SECTIONS; do mkdir -p ${OUT_FOLDER}/$i; done

# Build the convert.js File
convert_js > "${OUT_FOLDER}/convert.js"

# Build the main.js File
[[ ! -d ${OUT_FOLDER}/js ]] && mkdir -p ${OUT_FOLDER}/js
main_js > ${OUT_FOLDER}/js/main.js

# Build sections specfic js files
for i in ${SECTIONS}; do
  [[ $i == "main" ]] && continue
  section_js $i > ${OUT_FOLDER}/js/${i}.js
done

# HTML files
[[ -d ${OUT_FOLDER}/std ]] && rm -fr ${OUT_FOLDER}/std && mkdir -p ${OUT_FOLDER}/std
foot_html > ${OUT_FOLDER}/std/foot.html
footer_html > ${OUT_FOLDER}/std/footer.html
head_html > ${OUT_FOLDER}/std/head.html
header_html > ${OUT_FOLDER}/std/header.html
navSections_html > ${OUT_FOLDER}/std/navSections.html
for i in ${SECTIONS}; do
  [[ $i == "main" ]] && continue
  navSection_html $i > ${OUT_FOLDER}/std/nav${i}.html
done
