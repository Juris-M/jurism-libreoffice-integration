#!/bin/bash

set -e

# Release-dance code goes here.

# Constants
PRODUCT="Juris-M LibreOffice Integration"
IS_BETA="false"
FORK="jurism-libreoffice-integration"
BRANCH="master"
CLIENT="jurism-libreoffice-integration"
VERSION_ROOT="3.5.10m"
COMPILED_PLUGIN_URL="https://download.zotero.org/integration/Zotero-LibreOffice-Plugin-3.5.10.xpi"
SIGNED_STUB="juris_m_libreoffice_integration-"

function xx-make-build-directory () {
    if [ -d "build" ]; then
        rm -fR build
    fi
    mkdir build
}

function xx-retrieve-compiled-plugin () {
    trap booboo ERR
    wget -O compiled-plugin.xpi "${COMPILED_PLUGIN_URL}" >> "${LOG_FILE}" 2<&1
    trap - ERR
    unzip compiled-plugin.xpi >> "${LOG_FILE}" 2<&1
    rm -f compiled-plugin.xpi
}

function xx-grab-install-rdf () {
    cp ../install.rdf .
}

function xx-fix-product-ids () {
    # LO
    sed -si "s/zoteroOpenOfficeIntegration@zotero.org/jurismOpenOfficeIntegration@juris-m.github.io/g" resource/installer.jsm
    # Mac
    sed -si "s/zoteroMacWordIntegration@zotero.org/jurismMacWordIntegration@juris-m.github.io/g" resource/installer.jsm
    # Win
    sed -si "s/zoteroWinWordIntegration@zotero.org/jurismWinWordIntegration@juris-m.github.io/g" resource/installer.jsm
}

function xx-fix-product-name () {
    sed -si "/Copyright.*Zotero/n;/Zotero *=/n;s/Zotero\( \|\"\|$\)/Juris-M\\1/g" install.rdf
    sed -si "/Copyright.*Zotero/n;/Zotero *=/n;s/Zotero\( \|\"\|$\)/Juris-M\\1/g" components/zoteroOpenOfficeIntegration.js
    sed -si "/Copyright.*Zotero/n;/Zotero *=/n;s/Zotero\( \|\"\|$\)/Juris-M\\1/g" resource/installer.jsm
}

function xx-fix-contributor () {
    sed -si "/<\/em:developer>/a\    <em:contributor>Frank Bennett</em:contributor>" install.rdf
}

function xx-install-icon () {
    cp ../additives/mlz_z_32px.png install/zotero.png
    cp ../additives/mlz_z_32px.png chrome/zotero.png
}

function xx-add-install-check-module () {
    cp ../additives/install_check.jsm resource
}

function xx-fix-uuids () {
    sed -si "s/f43193a1-7060-41a3-8e82-481d58b71e6f/62645C66-2DD5-11E5-B434-93CF1D5D46B0/g" chrome.manifest
    sed -si "s/f43193a1-7060-41a3-8e82-481d58b71e6f/62645C66-2DD5-11E5-B434-93CF1D5D46B0/g" components/zoteroOpenOfficeIntegration.js
    sed -si "s/8478cd98-5ba0-4848-925a-75adffff2dbf/2AD30C00-2DDC-11E5-98C6-7BD91D5D46B0/g" chrome.manifest
    sed -si "s/8478cd98-5ba0-4848-925a-75adffff2dbf/2AD30C00-2DDC-11E5-98C6-7BD91D5D46B0/g" components/zoteroOpenOfficeIntegration.js
    sed -si "s/82483c48-304c-460e-ab31-fac872f20379/44AF3E96-2DDC-11E5-952E-8DD91D5D46B0/g" chrome.manifest
    sed -si "s/82483c48-304c-460e-ab31-fac872f20379/44AF3E96-2DDC-11E5-952E-8DD91D5D46B0/g" components/zoteroOpenOfficeIntegration.js
}

function xx-fix-install () {
    # ID everywhere
    sed -si "s/zotero@chnm.gmu.edu/juris-m@juris-m.github.io/g" resource/installer.jsm
    sed -si "s/zotero@chnm.gmu.edu/juris-m@juris-m.github.io/g" resource/installer_common.jsm
    # URLs
    sed -si "s/\(url: *\"\)\([^\"]*\)/\\1juris-m.github.io\/downloads/g" resource/installer.jsm
}

# Are we clever enough now not to need this?
function xx-insert-copyright-blocks () {
    sed -si "/BEGIN LICENSE/r ../additives/copyright_block.txt" resource/installer.jsm
    sed -si "/END OF INSERT/,/END LICENSE/d" resource/installer.jsm
    sed -si "/BEGIN LICENSE/r ../additives/copyright_block.txt" resource/installer_common.jsm
    sed -si "/END OF INSERT/,/END LICENSE/d" resource/installer_common.jsm
    sed -si "/BEGIN LICENSE/r ../additives/copyright_block.txt" components/zoteroOpenOfficeIntegration.js
    sed -si "/END OF INSERT/,/END LICENSE/d" components/zoteroOpenOfficeIntegration.js
}

function xx-apply-patch () {
    patch -p1 < ../additives/word-install-check.patch >> "${LOG_FILE}" 2<&1
}

function xx-make-the-bundle () {
    zip -r "${XPI_FILE}" * >> "${LOG_FILE}"
}

function build-the-plugin () {
        xx-make-build-directory
        cd build
        xx-retrieve-compiled-plugin
        xx-grab-install-rdf
        set-install-version
        xx-install-icon
        xx-fix-product-ids
        xx-fix-product-name
        xx-fix-contributor
        xx-install-icon
        xx-add-install-check-module
        xx-fix-uuids
        xx-fix-install
        xx-apply-patch
        xx-insert-copyright-blocks
        xx-make-the-bundle
        cd ..
    }
    
. jm-sh/frontend.sh
