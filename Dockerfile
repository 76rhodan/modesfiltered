FROM debian:buster-20211201-slim

ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
    MODESFILTERED_PROG_PATH="/home/pi/modesfiltered" \
    MODESFILTERED_LOG_PATH="/var/log/modesfiltered"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update && apt-get install -o APT::Autoremove::RecommendsImportant=0 -o APT::Autoremove::SuggestsImportant=0 -o Dpkg::Options::="--force-confold" -y --no-install-recommends  --no-install-suggests ca-certificates gnupg2 software-properties-common

RUN set -x && \
# define packages needed for installation and general management of the container:
    TEMP_PACKAGES=() && \
    KEPT_PACKAGES=() && \
    KEPT_PIP_PACKAGES=() && \
    KEPT_RUBY_PACKAGES=() && \
# Required for building multiple packages.
    KEPT_PACKAGES+=(pkg-config) && \
    TEMP_PACKAGES+=(git) && \
# logging:
    KEPT_PACKAGES+=(gawk) && \
    KEPT_PACKAGES+=(pv) && \
# required for S6 overlay
# curl kept for healthcheck
# ca-certificates kept for python
    TEMP_PACKAGES+=(file) && \
    KEPT_PACKAGES+=(curl) && \
# a few KEPT_PACKAGES for debugging - they can be removed in the future
    KEPT_PACKAGES+=(psmisc procps nano) && \
#
# add your own packages here between the (), repeat lines for each added package:
    KEPT_PACKAGES+=(unzip) && \
    KEPT_PACKAGES+=(wget) && \
    KEPT_PACKAGES+=(gnupg2) && \
    KEPT_PACKAGES+=(libatomic1) && \
#    KEPT_PIP_PACKAGES+=() && \
#    KEPT_RUBY_PACKAGES+=() && \
# keep the TEMP package names around so we can uninstall them later:
    echo ${TEMP_PACKAGES[*]} > /tmp/vars.tmp && \
#
# Install all the KEPT packages:
    apt-get update && \
    apt-get install -o APT::Autoremove::RecommendsImportant=0 -o APT::Autoremove::SuggestsImportant=0 -o Dpkg::Options::="--force-confold" -y --no-install-recommends  --no-install-suggests\
        ${KEPT_PACKAGES[@]} && \

    wget -qO - https://adoptopenjdk.jfrog.io/adoptopenjdk/api/gpg/key/public | apt-key add - && \
    add-apt-repository --yes https://adoptopenjdk.jfrog.io/adoptopenjdk/deb/ && \
    apt-get update && apt-get install -o APT::Autoremove::RecommendsImportant=0 -o APT::Autoremove::SuggestsImportant=0 -o Dpkg::Options::="--force-confold" -y --no-install-recommends  --no-install-suggests\
    adoptopenjdk-8-hotspot-jre && \
#
# Add the following if you have PIP or GEM packages to install:
#    pip install ${KEPT_PIP_PACKAGES[@]} && \
#    gem install ${KEPT_RUBY_PACKAGES} && \
#
echo "Done installing KEPT packages"
#

# Now copy the files from the rootfs directory into place:
COPY rootfs/ /
COPY .git/HEAD /tmp

RUN set -x && \
#
# First install the TEMP_PACKAGES. We do this here, so we can delete them again from the layer once installation is complete
    TEMP_PACKAGES="$(</tmp/vars.tmp)" && \
    apt-get install -o APT::Autoremove::RecommendsImportant=0 -o APT::Autoremove::SuggestsImportant=0 -o Dpkg::Options::="--force-confold" -y --no-install-recommends  --no-install-suggests ${TEMP_PACKAGES[@]} && \
    git config --global advice.detachedHead false && \
# Create Directories for modesfiltered
    mkdir -p "$MODESFILTERED_PROG_PATH" && \
# pulling the script from the interwebs
    wget https://www.live-military-mode-s.eu/Rpi/modesfiltered.zip && \
# and extract it
    unzip modesfiltered.zip -d "$MODESFILTERED_PROG_PATH" && \
# Backup blacklist, whitelist and callsigns
    cp "$MODESFILTERED_PROG_PATH/blacklist.txt" "$MODESFILTERED_PROG_PATH/blacklist.install" && \
    cp "$MODESFILTERED_PROG_PATH/whitelist.txt" "$MODESFILTERED_PROG_PATH/whitelist.install" && \
    cp "$MODESFILTERED_PROG_PATH/callsigns.txt" "$MODESFILTERED_PROG_PATH/callsigns.install" && \
# the rest is done by the modes run script
#
# This is useful while debugging your container:
    echo "alias dir=\"ls -alsv\"" >> /root/.bashrc && \
    echo "alias nano=\"nano -l\"" >> /root/.bashrc && \
#
# install S6 Overlay
    curl --compressed -s https://raw.githubusercontent.com/mikenye/deploy-s6-overlay/master/deploy-s6-overlay.sh | sh && \
#
# write git commit version and time to log:
a=$(cat tmp/HEAD) && \
echo "${a##*/}_($(git ls-remote https://github.com/76rhodan/modesfiltered HEAD | awk '{ print substr($1,1,7)}'))_$(date +%Y-%m-%d_%T%Z)" > /.build_version && \
#
#
# Clean up
    TEMP_PACKAGES="$(</tmp/vars.tmp)" && \
    echo Uninstalling $TEMP_PACKAGES && \
    apt-get remove -y $TEMP_PACKAGES && \
    apt-get autoremove -o APT::Autoremove::RecommendsImportant=0 -o APT::Autoremove::SuggestsImportant=0 -y && \
    apt-get clean -y && \
    rm -rf \
	     /src/* \
	     /tmp/* \
	     /var/lib/apt/lists/* \
	     /.dockerenv \
	     /git

ENTRYPOINT [ "/init" ]
