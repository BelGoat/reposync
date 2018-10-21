#!/bin/bash
#================================================================
# HEADER
#================================================================
# DESCRIPTION
#    This is a simple bash script aim to download centos
#    repositories.
#    This script is for use in BelGoat/reposync:centos7 docker
#
# IMPLEMENTATION
#    version         0.1.0
#    author          BelGoat <BelGoat@gmail.com>
#    copyright       Copyright (c) BelGoat
#    license         GNU General Public License v3.0
#
#================================================================
#  HISTORY
#     2017/08/21 : BelGoat : Updated more repos
#     2017/08/20 : BelGoat : Script Creation
# 
#================================================================
# END_OF_HEADER
#================================================================

SCRIPT_NAME=`basename "$0"`
VERSION=0.1.0
USAGE="`basename "$0"` [-hvuVcd] [-p prefix] [-q suffix] [-r \"repo list\"] [path_to_download]"
HELP="
 DESCRIPTION
    This script download centos repos to directory
    to start any good shell script.

 OPTIONS
    -r \"list of repos\"    List of repos to download
                            (Supported repos:
                              base, base-debuginfo
                              updates 
                              extras
                              centosplus
                              contrib
                              epel, epel-source, epel-debuginfo
                              c6-media
                              openstack-juno
                              sclo-rh
                              sclo-sclo
                              virt-xen )

    -p prefix               prefix addition to repo directory name
    -q suffix               suffix addition to repo directory name
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

    REPO_BASE_DOWNLOAD                  no|yes
    REPO_BASE_SOURCE_DOWNLOAD           no|yes
    REPO_BASE_DEBUGINFO_DOWNLOAD        no|yes
    REPO_UPDATES_DOWNLOAD               no|yes
    REPO_UPDATES_SOURCE_DOWNLOAD        no|yes
    REPO_EXTRAS_DOWNLOAD                no|yes
    REPO_EXTRAS_SOURCE_DOWNLOAD         no|yes
    REPO_CENTOSPLUS_DOWNLOAD            no|yes
    REPO_CENTOSPLUS_UPDATES_DOWNLOAD    no|yes
    REPO_CONTRIB_UPDATES_DOWNLOAD       no|yes
    REPO_EPEL_DOWNLOAD                  no|yes
    REPO_EPEL_SOURCE_DOWNLOAD           no|yes
    REPO_EPEL_DEBUGINFO_DOWNLOAD        no|yes
    REPO_C6_MEDIA_DOWNLOAD              no|yes
    REPO_OPENSTACK_JUNO_DOWNLOAD        no|yes
    REPO_SCLO_RH_DOWNLOAD               no|yes
    REPO_SCLO_SCLO_DOWNLOAD             no|yes
    REPO_VIRT_XEN_DOWNLOAD              no|yes

    REPOSYNC_VERBOSE         no|yes
    CREATEREPO_VERBOSE       no|yes

    DELETE_LOCAL_PACKAGES    no|yes

    (All Defaults are no/empty)

 EXAMPLES
   With Params:
    ${SCRIPT_NAME} -p \"\`date +%Y%m%d\`\" -r 'base extras centosplus' /opt/repos/
   With Variables:
    REPO_NAME_PREFIX=\"\`date +%Y%m%d\`\" REPO_DOWNLOAD_LOCATION='/opt/repos/' REPO_BASE_DOWNLOAD='yes' REPO_EPEL_DOWNLOAD='yes' ${SCRIPT_NAME}
"

#####################
# Variable Handling #
#####################

# General Variables Defaults
if [ -z "${REPOSYNC_VERBOSE}" ] && [ "${REPOSYNC_VERBOSE}" == "yes" ]
then
  REPOSYNC_VERBOSE_VAR=""
else
  REPOSYNC_VERBOSE_VAR="-q"
fi

if [ -z "${CREATEREPO_VERBOSE}" ] && [ "${CREATEREPO_VERBOSE}" == "yes" ]
then
    CREATEREPO_VERBOSE_VAR="--verbose"
else
    CREATEREPO_VERBOSE_VAR=""
fi

if [ -z "${DELETE_LOCAL_PACKAGES}" ] && [ "${DELETE_LOCAL_PACKAGES}" == "yes" ]
then
    DELETE_LOCAL_PACKAGES_VAR="--delete"
else
    DELETE_LOCAL_PACKAGES_VAR=""
fi

if [[ -z "${REPO_NAME_PREFIX}" ]]
then
  REPO_NAME_PREFIX=""
fi

if [[ -z "${REPO_NAME_POSTFIX}" ]]
then
  REPO_NAME_POSTFIX=""
fi

function setRepoIDVariables {
    while [ ! -z $1 ]
    do
        case "$1" in
            "base")
                REPO_BASE_DOWNLOAD=yes
            ;;
            "base-debuginfo")
                REPO_BASE_DEBUGINFO_DOWNLOAD=yes
            ;;
            "updates")
                REPO_UPDATES_DOWNLOAD=yes
            ;;
            "extras")
                REPO_EXTRAS_DOWNLOAD=yes
            ;;
            "centosplus")
                REPO_CENTOSPLUS_DOWNLOAD=yes
            ;;
            "centosplus-updates")
                REPO_CENTOSPLUS_UPDATES_DOWNLOAD=yes
            ;;
            "contrib")
                REPO_CONTRIB_DOWNLOAD=yes
            ;;
            "epel")
                REPO_EPEL_DOWNLOAD=yes
            ;;
            "epel-source")
                REPO_EPEL_SOURCE_DOWNLOAD=yes
            ;;
            "epel-debuginfo")
                REPO_EPEL_DEBUGINFO_DOWNLOAD=yes
            ;;
            "c6-media")
                REPO_C6_MEDIA_DOWNLOAD=yes
            ;;
            "openstack-juno")
                REPO_OPENSTACK_JUNO_DOWNLOAD=yes
            ;;
            "sclo-rh")
                REPO_SCLO_RH_DOWNLOAD=yes
            ;;
            "sclo-sclo")
                REPO_SCLO_SCLO_DOWNLOAD=yes
            ;;
            "virt-xen")
                REPO_VIRT_XEN_DOWNLOAD=yes
            ;;
            *)
                echo "WARNING: Repository \"$1\" not available, Ignoring"
            ;;
        esac
        shift
    done
}

# Options processing
while getopts "Vhr:vcp:q:d:" optname
  do
    case "$optname" in
      "V")
        echo "Version $VERSION"
        exit 0;
        ;;
      "h")
        echo $USAGE
        echo "$HELP"
        exit 0;
        ;;
      "r")
        setRepoIDVariables $OPTARG
        ;;
      "v")
        # Overide ENV Variable REPOSYNC_VERBOSE
        REPOSYNC_VERBOSE_VAR=""
        ;;
      "c")
        # Overide ENV Variable CREATEREPO_VERBOSE
        CREATEREPO_VERBOSE_VAR="--verbose"
        ;;
      "p")
        # Overide ENV Variable REPO_NAME_PREFIX
        REPO_NAME_PREFIX=$OPTARG
        ;;
      "q")
        # Overide ENV Variable REPO_NAME_POSTFIX
        REPO_NAME_POSTFIX=$OPTARG
        ;;
      "d")
        # Overide ENV Variable DELETE_LOCAL_PACKAGES
        DELETE_LOCAL_PACKAGES_VAR="--delete"
        ;;
      "?")
        echo "Unknown option $OPTARG"
        exit 0;
        ;;
      ":")
        echo "No argument value for option $OPTARG"
        exit 0;
        ;;
      *)
        echo "Unknown error while processing options"
        exit 0;
        ;;
    esac
  done

# Set download path - cmd var -or- env var -or- default
shift $(expr $OPTIND - 1 )

if [[ -z $1 ]]
then
    if [[ -z "${REPO_DOWNLOAD_LOCATION}" ]]
    then
        DOWNLOAD_PATH="/opt/repos"
    else
        DOWNLOAD_PATH="${REPO_DOWNLOAD_LOCATION}"
    fi
else
    DOWNLOAD_PATH=$1
fi

# Check if download directory exist
if [ ! -d "$DOWNLOAD_PATH" ]
then
    echo "ERROR: download path $DOWNLOAD_PATH does not exist!"
    exit 1
fi

################################
# Downloading the repositories #
################################

# Base RepoSync Func
function syncRepo {
    repoID=$1
    repoDirName="${REPO_NAME_PREFIX}${repoID}${REPO_NAME_POSTFIX}"
    
    cmd_line="/usr/bin/reposync $REPOSYNC_VERBOSE_VAR $DELETE_LOCAL_PACKAGES_VAR -l --norepopath --downloadcomps --download-metadata --repoid=${repoID} --download_path=${DOWNLOAD_PATH}/${repoDirName}"

    if [ ! -d ${DOWNLOAD_PATH}/${repoDirName} ]
    then
        mkdir ${DOWNLOAD_PATH}/${repoDirName}
    fi

    echo "###########################################################"
    echo "# Downloading repo: $repoID"
    echo "# Running: ${cmd_line}"
    echo "###########################################################"

    $cmd_line

    echo "###########################################################"
    echo "# Generating Repo from downloaded files for $repoID"
    echo "###########################################################"
    if [[ -e ${DOWNLOAD_PATH}/${repoDirName}/comps.xml ]]
    then
        createrepo $CREATEREPO_VERBOSE_VAR  ${DOWNLOAD_PATH}/${repoDirName} -g ${DOWNLOAD_PATH}/${repoDirName}/comps.xml
    else
        createrepo $CREATEREPO_VERBOSE_VAR  ${DOWNLOAD_PATH}/${repoDirName}
    fi
}

# Repo Download
if [ ! -z $REPO_BASE_DOWNLOAD ] && [ ${REPO_BASE_DOWNLOAD} == "yes" ]
then
    syncRepo base 
fi
if [ ! -z $REPO_BASE_DEBUGINFO_DOWNLOAD ] && [ ${REPO_BASE_DEBUGINFO_DOWNLOAD} == "yes" ]
then
    syncRepo base-debuginfo
fi
if [ ! -z $REPO_UPDATES_DOWNLOAD ] && [ ${REPO_UPDATES_DOWNLOAD} == "yes" ]
then
    syncRepo updates
fi
if [ ! -z  ${REPO_EXTRAS_DOWNLOAD} ] && [ ${REPO_EXTRAS_DOWNLOAD} == "yes" ]
then
    syncRepo extras
fi
if [ ! -z $REPO_CENTOSPLUS_DOWNLOAD ] && [ ${REPO_CENTOSPLUS_DOWNLOAD} == "yes" ]
then
    syncRepo centosplus
fi
if [ ! -z  ${REPO_CONTRIB_DOWNLOAD} ] && [ ${REPO_CONTRIB_DOWNLOAD} == "yes" ]
then
    syncRepo contrib
fi
if [ ! -z ${REPO_EPEL_DOWNLOAD} ] && [ ${REPO_EPEL_DOWNLOAD} == "yes" ]
then
    syncRepo epel
fi
if [ ! -z ${REPO_EPEL_SOURCE_DOWNLOAD} ] && [ ${REPO_EPEL_SOURCE_DOWNLOAD} == "yes" ]
then
    syncRepo epel-source
fi
if [ ! -z ${REPO_EPEL_DEBUGINFO_DOWNLOAD} ] && [ ${REPO_EPEL_DEBUGINFO_DOWNLOAD} == "yes" ]
then
    syncRepo epel-debuginfo
fi
if [ ! -z ${REPO_C6_MEDIA_DOWNLOAD} ] && [ ${REPO_C6_MEDIA_DOWNLOAD} == "yes" ]
then
    syncRepo c6-media
fi
if [ ! -z ${REPO_OPENSTACK_JUNO_DOWNLOAD} ] && [ ${REPO_OPENSTACK_JUNO_DOWNLOAD} == "yes" ]
then
    syncRepo centos-openstack-juno
fi
if [ ! -z ${REPO_SCLO_RH_DOWNLOAD} ] && [ ${REPO_SCLO_RH_DOWNLOAD} == "yes" ]
then
    syncRepo centos-sclo-rh
fi
if [ ! -z ${REPO_SCLO_SCLO_DOWNLOAD} ] && [ ${REPO_SCLO_SCLO_DOWNLOAD} == "yes" ]
then
    syncRepo centos-sclo-sclo
fi
if [ ! -z ${REPO_VIRT_XEN_DOWNLOAD} ] && [ ${REPO_VIRT_XEN_DOWNLOAD} == "yes" ]
then
    syncRepo centos-virt-xen
fi
