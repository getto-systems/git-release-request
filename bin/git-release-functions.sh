#!/bin/bash

declare -a git_release_version_files

git_release_request_setup(){
  local git_root
  local current

  current=$(git show --format="%H" | head -1)
  if [ -z "$(git show origin "$current" --format="%H")" ]; then
    echo "current commit has not pushed"
    exit 1
  fi

  git_root=$(git rev-parse --show-toplevel)
  if [ ! -d "$git_root" ]; then
    echo "current directory not in git"
    exit 1
  fi
  cd $git_root

  git_release_version_files=(
    mix.exs
    package.json
    $GIT_RELEASE_VERSION_FILE
  )

  git_release_request_set_last
}
git_release_request_purge(){
  git purge

  if [ "$(git symbolic-ref --short HEAD)" != master ]; then
    echo "allow only master branch"
    exit 1
  fi
}

git_release_request_set_last(){
  local file

  for file in ${git_release_version_files[@]}; do
    if [ -f "$file" ]; then
      case "$file" in
        mix.exs)
          last=$(grep 'version:' $file | cut -d'"' -f2)
          ;;
        package.json)
          last=$(grep '"version":' $file | cut -d'"' -f4)
          ;;
        *.rb)
          last=$(grep 'VERSION =' $file | cut -d'"' -f2)
          ;;
      esac
    fi
    if [ -n "$last" ]; then
      return
    fi
  done
}
git_release_request_dump_version(){
  local file
  local cmd
  local local_rc

  local_rc=.git_release_request.rc.sh

  for file in ${git_release_version_files[@]}; do
    if [ -f "$file" ]; then
      case "$file" in
        mix.exs)
          sed -i 's/version: "[0-9.-]\+"/version: "'$version'"/' $file
          ;;
        package.json|elm-package.json)
          sed -i 's/"version": "[0-9.-]\+"/"version": "'$version'"/' $file
          ;;
        *.rb)
          sed -i 's/VERSION = "[0-9.-]\+"/VERSION = "'$version'"/' $file
          ;;
      esac
      git add $file
    fi
  done

  if [ -e "$local_rc" ]; then
    . $local_rc

    cmd=git_release_request_dump_version_local
    if [ "$(type -t $cmd)" == "function" ]; then
      $cmd
    fi
  fi
}

git_release_request_build_version(){
  if [[ "${last%%.*}" -lt 2000 ]]; then
    git_release_request_next_version_normal
  else
    git_release_request_next_version_date
  fi
}
git_release_request_next_version_normal(){
  local tmp

  if [ -n "$(git_release_request_changelog | grep 'major version up')" ]; then
    version=$((${last%%.*} + 1)).0.0
  else
    if [ -n "$(git_release_request_changelog | grep 'minor version up')" ]; then
      tmp=${last#*.}
      version=${last%%.*}.$((${tmp%%.*} + 1)).0
    else
      if [ -n "$last" ]; then
        version=${last%.*}.$((${last##*.} + 1))
      else
        version=0.0.1
      fi
    fi
  fi
}
git_release_request_next_version_date(){
  local last_date
  local date
  local count

  last_date=$(echo "$last" | cut -d'-' -f1)
  date=$(date "+%Y.%-m.%-d")

  if [ "$last_date" == $date ]; then
    count=$(echo "$last" | cut -d'-' -f2)
    count=$((count+1))
  else
    count=1
  fi

  version=${date}-${count}
}
git_release_request_version_confirm(){
  local finish
  local confirm_version
  local confirm

  confirm_version=$version

  while [ -z "$finish" ]; do
    read -p "release: '$confirm_version'. OK? [Enter|version] " confirm
    case "$confirm" in
      Y*|y*|"")
        finish=1
        ;;
      *)
        if [[ "$confirm" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[0-9a-zA-Z_-]+)?$ ]]; then
          confirm_version=$confirm
        else
          echo "'$confirm' is not valid version number"
        fi
        ;;
    esac
  done

  version=$confirm_version
}

git_release_request_build_changelog(){
  local message
  local changelog_root
  local changelog_main
  local changelog_tmp
  local changelog

  message=$1; shift

  changelog_root=CHANGELOG
  changelog_main=CHANGELOG.md
  changelog_tmp=CHANGELOG.tmp
  changelog=$changelog_root/${version}.md

  rm -f $changelog_tmp

  echo "# Version : $version" >> $changelog_tmp
  echo "" >> $changelog_tmp
  echo "$message" >> $changelog_tmp
  echo "" >> $changelog_tmp
  if [ -f $changelog_main ]; then
    cat $changelog_main >> $changelog_tmp
  fi

  mv -f $changelog_tmp $changelog_main

  mkdir -p $changelog_root

  echo "# Version : $version" >> $changelog
  echo "" >> $changelog
  echo "$message" >> $changelog
  echo "" >> $changelog
  echo "## commits" >> $changelog
  echo "" >> $changelog
  git_release_request_changelog >> $changelog

  git add $changelog $changelog_main
}
git_release_request_changelog(){
  if [ -n "$(git tag | grep $last)" ]; then
    git log "${last}.." --no-merges --format="* %s"
  else
    git log --no-merges --format="* %s"
  fi
}