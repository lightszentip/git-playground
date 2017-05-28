#!/bin/bash
minor=$(git log 0.0.2..HEAD --no-merges --pretty=oneline | grep -c "XXX:.*Minor" 2>&1)
major=$(git log 0.0.2..HEAD --no-merges --pretty=oneline | grep -c "XXX:.*Major" 2>&1)
currenttag=$(git describe --tags --dirty --always --long | grep -P '[0-9]+.[0-9]+.[0-9]+' -o 2>&1)
echo $currenttag
version_major=$(echo $currenttag| awk -F \. {'print $1'})
version_minor=$(echo $currenttag| awk -F \. {'print $2'})
version_patch=$(echo $currenttag | awk -F \. {'print $3'})
echo $version_major.$version_minor.$version_patch
# Patch is by default - no major or minor => patch
annotated_tag=true
if [ $major > 0 ]
then
   	echo "Major"
	version_major=$(($version_major+1))
	version_minor=0
	version_patch=0
elif [ $minor > 0 ]
then
   	echo "Minor"
	version_minor=$(($version_minor+1))
	version_patch=0
else
   	echo "Patch"
	#for patches only lightweigth
	annotated_tag=false
	version_patch=$(($version_patch+1))
fi
new_version=$version_major.$version_minor.$version_patch
echo $new_version
echo "Check exist tag"
exist_tag=$(git tag | grep -c $new_version 2>&1)
if [ $exist_tag > 0 ]
then
	echo "Text exist - break"
else
	if [ $annotated_tag ]
	then
		git tag -a $new_version -m "new version by script"
	else
		git tag $new_version -m "lw tag new version by script"	
	fi
fi

