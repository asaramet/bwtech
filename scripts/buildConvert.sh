#!/usr/bin/env bash

MD="`dirname $(readlink -f ${0})`/.."
MD_FOLDER="${MD}/md_files"
OUT_FOLDER="${MD}/prod"
JS_FILE="${OUT_FOLDER}/convert.js"

# Get the sections i.e list of folders in md_files
SECTIONS=`cd $MD_FOLDER && ls -d */ | cut -f1 -d'/'`

# Exit if no sections found
[[ -z $SECTIONS ]] && echo "No folders found in $MD_FOLDER" && exit 1

# List of sections in format ["x","y"]
SECTIONS_LIST=`for i in $SECTIONS; do echo \"$i\"; done`
SECTIONS_LIST="["`echo $SECTIONS_LIST | sed "s/ /, /"`"]"

js_file()
{
  # JS_FILE content
  cat << EOF
'use strict';

const marked = require('marked'); // converts markedown to html
const fs = require('fs');
const path = require('path');

// Convert function. Input: 1.MD file, 2.converted HTML file
function convert(inMD, outHTML) {
  // Convert the inMD file and write to outHTML
  fs.writeFile(outHTML, marked(fs.readFileSync(inMD, "utf8")), (err)=>{
    if (err) {
      console.log(err);
    }
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
      convert(mdFile, htmlFile);
    });
  });
});
EOF
}

# Create html folders
for i in $SECTIONS; do mkdir -p ${OUT_FOLDER}/$i; done

# Build the JS File
js_file > ${JS_FILE}
