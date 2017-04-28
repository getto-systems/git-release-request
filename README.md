# git-release-request

dump version, changelog and pull request

## Usage

```bash
$ git release-request
```

* find {mix.exs,package.json,elm-package.json} in git-root
* dump version : format `$(date "+%Y.%-m.%-d")`
* dump changelog : to `CHANGELOG/${version}.md`
* git branch-and-post : [GitHub](https://github.com/sanzen-sekai/git-branch-and-post)

## Requirements

* [git-branch-and-post](https://github.com/sanzen-sekai/git-branch-and-post)
* [git-post](https://github.com/sanzen-sekai/git-post)
* [git-pub](https://github.com/sanzen-sekai/git-pub)

## Install

using zplug

```
zplug "getto-systems/git-release-request", as:command, use:"bin/*"
```

setup manual

```
git clone https://github.com/getto-systems/git-release-request.git
```

```
export PATH=/path/to/git-release-request/bin:$PATH
```

## .git_release_request.rc.sh

additional dump-version files

```bash
# $git_root/.git_release_request.rc.sh

git_release_request_dump_version_local(){
  local file
  for file in some/path/*.txt; do
    sed -i 's/version : [0-9.-]\+/version : '$version'/' $file
    git add $file
  done
}
```

