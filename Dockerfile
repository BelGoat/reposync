FROM centos:6
MAINTAINER BelGoat <belgoat@gmail.com>

ENV REPO_DOWNLOAD_LOCATION "/opt/repos"

# Repo dir names Additions
ENV REPO_NAME_PREFIX ""
ENV REPO_NAME_POSTFIX ""

# Repos to download
ENV REPO_BASE_DOWNLOAD no
ENV REPO_BASE_SOURCE_DOWNLOAD no
ENV REPO_BASE_DEBUGINFO_DOWNLOAD no
ENV REPO_UPDATES_DOWNLOAD no
ENV REPO_UPDATES_SOURCE_DOWNLOAD no
ENV REPO_EXTRAS_DOWNLOAD no
ENV REPO_EXTRAS_SOURCE_DOWNLOAD no
ENV REPO_CENTOSPLUS_DOWNLOAD no
ENV REPO_CENTOSPLUS_UPDATES_DOWNLOAD no
ENV REPO_CONTRIB_UPDATES_DOWNLOAD no
ENV REPO_EPEL_DOWNLOAD no
ENV REPO_EPEL_SOURCE_DOWNLOAD no
ENV REPO_EPEL_DEBUGINFO_DOWNLOAD no
ENV REPO_C6_MEDIA_DOWNLOAD no
ENV REPO_OPENSTACK_JUNO_DOWNLOAD no
ENV REPO_SCLO_RH_DOWNLOAD no
ENV REPO_SCLO_SCLO_DOWNLOAD no
ENV REPO_VIRT_XEN_DOWNLOAD no

# Other download Variables
ENV REPOSYNC_VERBOSE no
ENV CREATEREPO_VERBOSE no
ENV DELETE_LOCAL_PACKAGES no

# Install:
#   external repositories files
#   dependencies for downloading and creating repos
# + Cleaning
RUN yum install -y \
        centos-release \
        epel-release \
        centos-release-openstack \
        centos-release-scl-rh \
        centos-release-scl \
        centos-release-xen \
        centos-release-virt-common \
        yum-utils deltarpm createrepo \
     && yum --enablerepo=* clean all \
     && rm -rf /var/cache/yum


COPY repo_downloader.sh /root/repo_downloader.sh

RUN mkdir /opt/repos

ENTRYPOINT ["/bin/bash", "/root/repo_downloader.sh"]

CMD [""]
