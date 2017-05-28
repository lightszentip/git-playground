#!/bin/bash
currenttag=$(git describe --tags --dirty --always --long | grep -P '^[0-9]+.[0-9]+.[0-9]+' -o 2>&1)
count_commits=$(git log $currenttag..HEAD --no-merges --pretty=oneline  | grep -c .*[a-zA-Z].* 2>&1)
minor=$(git log $currenttag..HEAD --no-merges --pretty=oneline | grep -c "XXX:.*Minor" 2>&1)
major=$(git log $currenttag..HEAD --no-merges --pretty=oneline | grep -c "XXX:.*Major" 2>&1)
echo "Current version:" $currenttag
echo "changes:" $count_commits
if [ $count_commits -eq 0 ]
then
	echo "NO changes"
	exit 0
fi

version_major=$(echo $currenttag| awk -F \. {'print $1'})
version_minor=$(echo $currenttag| awk -F \. {'print $2'})
version_patch=$(echo $currenttag | awk -F \. {'print $3'})
echo $version_major.$version_minor.$version_patch
# Patch is by default - no major or minor => patch
annotated_tag=true
if [ $major -gt 0 ]
then
   	echo "Change Major"
	version_major=$(($version_major+1))
	version_minor=0
	version_patch=0
elif [ $minor -gt 0 ]
then
   	echo "Change Minor"
	version_minor=$(($version_minor+1))
	version_patch=0
else
   	echo "Change Patch"
	#for patches only lightweigth
	annotated_tag=false
	version_patch=$(($version_patch+1))
fi
new_version=$version_major.$version_minor.$version_patch
echo "New Version:" $new_version
echo "Check exist tag"
exist_tag=$(git tag | grep -c $new_version 2>&1)
if [ $exist_tag -gt 0 ]
then
	echo "Tag exist - break"
else
	echo "Create new Tag"
	if [ $annotated_tag ]
	then
		echo "Create a annotated tag"
		git tag -a $new_version -m "new version by script"
	else
		echo "Create a lw tag"
		git tag $new_version -m "lw tag new version by script"	
	fi
fi
echo "Finish"

