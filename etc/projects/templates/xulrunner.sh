#!/bin/bash
#
# Copyright (C) 2008  June Tate-Gans, All Rights Reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

project-pre-hook()
{
    local project_name=$1

    : do nothing
}

project-editor-hook()
{
    local project_name=$1

    : do nothing
}

project-pre-scm-hook()
{
    local project_name=$1
    local project_dir=$2
    local scm_type=$3
    local scm_url=$4

    mkdir -p $project_dir
    cat > $project_dir/application.ini <<EOT
[App]
Vendor=Nobody
Name=$project_name
Version=0.1
BuildID=$(date +%Y%m%d)
Copyright=Copyright (c) $(date +%Y) Nobody
ID=xulapp@example.com

[Gecko]
MinVersion=1.8
MaxVersion=1.9.0.*
EOT
    cat > $project_dir/Makefile <<EOT
run:
	xulrunner application.ini

clean:
	find -type f -iname \*~ -exec rm '{}' ';'

deploy:
	zip -9r $project_dir/chrome/content.jar $project_dir/chrome/content
	sed -e 's|^content $project_name file:content/|content $project_name file:content.jar!/|' -i $project_dir/chrome/chrome.manifest
	rm -r $project_dir/chrome/content
	zip -9r $project_name.jar .
	mkdir -p $project_dir/chrome/content
	unzip $project_dir/chrome/content.jar -d $project_dir/chrome/content
	rm $project_dir/chrome/content.jar
	sed -e 's|^content $project_name file:content.jar!/|content $project_name file:content/|' -i $project_dir/chrome/chrome.manifest

.PHONY: run clean deploy
EOT

    mkdir -p $project_dir/chrome
    cat > $project_dir/chrome/chrome.manifest <<EOT
content $project_name file:content/
EOT

    mkdir -p $project_dir/chrome/content
    cat > $project_dir/chrome/content/main.xul <<EOT
<?xml version="1.0"?>
<?xml-stylesheet href="chrome://global/skin/" type="text/css"?>

<window id="main" title="$project_name"
        xmlns="http://www.mozilla.org/keymaster/gatekeeper/there.is.only.xul">
  <caption label="Hello World" />
</window>
EOT

    mkdir -p $project_dir/defaults/preferences
    cat > $project_dir/defaults/preferences/prefs.js <<EOT
pref("toolkit.defaultChromeURI", "chrome://$project_name/content/main.xul");

// pref("toolkit.defaultChromeFeatures", "");
// pref("toolkit.singletonWindowType", "")
EOT
}

project-post-scm-hook()
{
    local project_name=$1
    local project_dir=$2
    local scm_type=$3
    local scm_url=$4

    : do nothing
}

project-post-hook()
{
    local project_name=$1

    : do nothing
}
