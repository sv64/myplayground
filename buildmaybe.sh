#!/bin/bash

set -e

if [[ ! -v FIRST ]]; then
    FIRST=false ;
fi

if $FIRST; then
  dnf -y update ;
  dnf -y install \
    "dnf-command(builddep)" \
    appstream-devel \
    expat-devel \
    git \
    glslc \
    graphviz \
    libabigail \
    libjpeg-turbo-devel \
    python3-jinja2 \
    python3-packaging \
    python3-pygments \
    python3-toml \
    python3-typogrify \
    sassc \
    vala ;
  dnf -y build-dep gtk4 ;
  dnf -y remove gi-docgen ;

  if [ ! -d gtk ]; then
    git clone https://github.com/GNOME/gtk.git --depth=1 ;
  fi
  cd gtk ;

fi

read -p "Continue? " ;

meson build --prefix=/usr \
                -Dgtk_doc=true \
                -Ddemos=true \
                -Dbuild-examples=false \
                -Dbuild-tests=false \
                -Dbuild-testsuite=false ;
cd build ;
ninja ;
sudo ninja install ;
