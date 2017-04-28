git_release_version_files=(
  mix.exs
  package.json
)

git_release_request_get_last(){
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
