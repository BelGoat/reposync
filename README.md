# reposync
Basic Docker image that provide repository download (for preservation of fixed repo image)
It includes repo_downloader.sh that can work without the docker.
The docker image helps you download the repo without the need to have a working OS of the same version

**Highly Suggested:** use --rm flag - there is no need to preserve the container after the work.

# Short HowTo:
```
docker run --rm -v /path/to/repo/dest:/opt/repos BelGoat/reposync:centos7 {OPTIONS}
# Help:
docker run --rm BelGoat/reposync:centos7 -h
```
**Examples**
```
# Download base, updates, extras repos
docker run -rm -v /backup/centos7.x/repos:/opt/repos BelGoat/reposync:centos7 -r "base updates extras"

# Download updates with specific time (preserve specific repo image)
docker run -rm -v /backup/centos7.x/repos:/opt/repos BelGoat/reposync:centos7 -p `date +%Y%m%d`_ -r "updates"
# result in /backup/centos7.x/repos/YYYYMMDD_extras directory
```


# HowTo's
You can use this project in 3 different ways (See below full explanations):
1. Use the docker as is and provide options/environments
1. Build your own version to provide your own version of docker (no need for elaborated run liners)
1. Use the repo_downloader.sh on existing server (pending dependencies)

## Option 1 - Use the docker as is
See short example from above and Option 3 for more options

## Option 2 - Build your own
If you want your own version of the docker image just edit the docker file.
The docker file is full of ENV Variables including all available options in the 
repo_downloader.sh
(repo_downloader.sh can get ENV variables instead of command line arguments
 Although the command line arguments will win when both are in place)

Unique Dockerfile example (sync only EPEL and UPDATES and delete obselete packages with verbose mode):
```
FROM BelGoat/reposync:centos7

ENV REPO_DOWNLOAD_LOCATION "/opt/repos"
# Repos to download
ENV REPO_UPDATES_DOWNLOAD yes
ENV REPO_EPEL_DOWNLOAD yes

# Other download Variables
ENV REPOSYNC_VERBOSE yes
ENV CREATEREPO_VERBOSE yes
ENV DELETE_LOCAL_PACKAGES yes
```

This example will not need any options - only mount for the download (-v).
Every time you run the docker it will download only updates and epel or update the existing repo

## Option 3 - Use the repo_downloader.sh
repo_downloader.sh is self explanatory:
```
[root@docker-server]# ./repo_downloader.sh  -h
repo_downloader.sh [-hvuVcd] [-p prefix] [-q postfix] [-r "repo list"] [path_to_download]

 DESCRIPTION
    This script download centos repos to directory
    to start any good shell script.

 OPTIONS
    -r "list of repos"    List of repos to download
                            (Support: base updates extras centosplus cr fasttrack epel)
    -p prefix               prefix addition to repo directory name
    -q postfix              postfix addition to repo directory name
    -h                      Print this help
    -u                      Print usage
    -V                      Print script information
    -v                      Print output of the reposync command (verbose)
                            (stronger then ENV REPOSYNC_VERBOSE)
    -c                      Print output of the createrepo command (verbose)
                            (stronger then ENV CREATEREPO_VERBOSE)
    -d                      Delete Local packages not existing in remote repo
                            (stronger then ENV DELETE_LOCAL_PACKAGES)

 Or Use ENVIRONMENT VARIABLES Instead (Aimed for Docker)
    REPO_DOWNLOAD_LOCATION '/opt/repos'
      (/opt/repos is default if not specified in command line/env)

    REPO_NAME_PREFIX ''
    REPO_NAME_POSTFIX ''

    REPO_BASE_DOWNLOAD       no|yes
    REPO_CENTOSPLUS_DOWNLOAD no|yes
    REPO_EXTRAS_DOWNLOAD     no|yes
    REPO_CR_DOWNLOAD         no|yes
    REPO_FASTTRACK_DOWNLOAD  no|yes
    REPO_EPEL_DOWNLOAD       no|yes

    REPOSYNC_VERBOSE         no|yes
    CREATEREPO_VERBOSE       no|yes

    DELETE_LOCAL_PACKAGES    no|yes

    (All Defaults are no/empty)

 EXAMPLES
   With Params:
     -p "`date +%Y%m%d`" -r 'base extras centosplus' /opt/repos/
   With Variables:
    REPO_NAME_PREFIX="`date +%Y%m%d`" REPO_DOWNLOAD_LOCATION='/opt/repos/' REPO_BASE_DOWNLOAD='yes' REPO_EPEL_DOWNLOAD='yes' 
```

