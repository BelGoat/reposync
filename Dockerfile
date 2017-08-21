FROM centos:7
MAINTAINER BelGoat <belgoat@gmail.com>

ENV REPO_DOWNLOAD_LOCATION "/opt/repos"

# Repo dir names Additions
ENV REPO_NAME_PREFIX "" \
    REPO_NAME_POSTFIX ""

# Repos to download
ENV REPO_BASE_DOWNLOAD no               \
    REPO_BASE_SOURCE_DOWNLOAD no        \
    REPO_BASE_DEBUGINFO_DOWNLOAD no     \
    REPO_UPDATES_DOWNLOAD no            \
    REPO_UPDATES_SOURCE_DOWNLOAD no     \
    REPO_EXTRAS_DOWNLOAD no             \
    REPO_EXTRAS_SOURCE_DOWNLOAD no      \
    REPO_CENTOSPLUS_DOWNLOAD no         \
    REPO_CENTOSPLUS_UPDATES_DOWNLOAD no \
    REPO_CR_DOWNLOAD no                 \
    REPO_FASTTRACK_DOWNLOAD no          \
    REPO_EPEL_DOWNLOAD no               \
    REPO_EPEL_SOURCE_DOWNLOAD no        \
    REPO_EPEL_DEBUGINFO_DOWNLOAD no     \
    REPO_C7_MEDIA_DOWNLOAD no           \
    REPO_OPENSHIFT_ORIGIN_DOWNLOAD no   \
    REPO_OPENSTACK_KILO_DOWNLOAD no     \
    REPO_OPSTOOLS_RELEASE_DOWNLOAD no   \
    REPO_SCLO_RH_DOWNLOAD no            \
    REPO_SCLO_SCLO_DOWNLOAD no

# Other download Variables
ENV REPOSYNC_VERBOSE no     \
    CREATEREPO_VERBOSE no   \
    DELETE_LOCAL_PACKAGES no

# Install:
#   external repositories files
#   dependencies for downloading and creating repos
# + Cleaning
RUN yum install -y \
        centos-release \
        epel-release \
        centos-release-openshift-origin \
        centos-release-openstack \
        centos-release-opstools \
        centos-release-scl-rh \
        centos-release-scl \
        yum-utils deltarpm createrepo \
     && yum --enablerepo=* clean all \
     && rm -rf /var/cache/yum


COPY repo_downloader.sh /root/repo_downloader.sh

RUN mkdir /opt/repos

ENTRYPOINT ["/bin/bash", "/root/repo_downloader.sh"]

CMD [""]
