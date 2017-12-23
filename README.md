# git-release-request

dump version, create changelog and pull request

```bash
git release-status

next version: 1.0.1
commits
* fix some typos
* add feature A
```

```bash
git release-request "- add feature A"

# ...merged

git release-tag
```

###### Table of Contents

- [Requirements](#requirements)
- [Usage](#usage)
- [License](#license)


<a id="requirements"></a>
## Requirements

- GNU bash, version 4.3.48(1)-release (x86_64-alpine-linux-musl)
- git version 2.14.2
- [sanzen-sekai/git-pub : GitHub](https://github.com/sanzen-sekai/git-pub)
- [sanzen-sekai/git-post : GitHub](https://github.com/sanzen-sekai/git-post)

<a id="usage"></a>
## Usage

to install git-release-request, clone into your bash-scripts directory, and export PATH

```bash
INSTALL_DIR=path/to/scripts/git-release-request

git clone https://github.com/getto-systems/git-release-request.git $INSTALL_DIR

export PATH=$INSTALL_DIR/bin:$PATH
```

- requirements: you have to install [git-pub](https://github.com/sanzen-sekai/git-pub) and [git-post](https://github.com/sanzen-sekai/git-post)


### git release-status

show next version and commits since previous release

```bash
git release-status #=> (output)

next version: 1.0.1
commits
* fix some typos
* add feature A
```

available version files:

- mix.exs
- package.json
- elm-package.json

#### add version file

you can setup your version file path

```bash
export GIT_RELEASE_VERSION_FILE=/gems/lib/my/project/version.rb
```

### git release-request

dump version, create changelog and pull request

```bash
git release-request "- add feature A
- fix some typos" #=>
  create changelog &&
  git add $version_file $changelog &&
  git create-work-branch "version dump : $version"
```

create changelogs:

- CHANGELOG.md : put summary
- CHANGELOG/$version.md : summary and commits

#### add dumping-version files

you can setup your dumping-version files in `$GIT_ROOT/.git_release_request.rc.sh`

```bash
git_release_request_dump_version_local(){
  local file
  for file in some/path/*.txt; do
    sed -i 's/version : [0-9.-]\+/version : '$version'/' $file
    git add $file
  done
}
```

this function call before commit

you can rewrite some files and add index for version-dump commit

- $version : new version string


### git release-tag

tag latest release version

```bash
git release-tag #=> git tag $latest_release_version
```


<a id="license"></a>
## License

git-release-request is licensed under the [MIT](LICENSE) license.

Copyright &copy; since 2017 shun@getto.systems
