#!/bin/sh

ls -a kubernetes/ | perl -e 'print "<html><body><ul>"; while(<>) { chop $_; print "<li><a href=\"./kubernetes/$_\">$_</a></li>";} print "</ul></body></html>"' > index.html
