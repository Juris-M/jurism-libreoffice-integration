function set-install-version () {
    sed -si "s/<em:version>.*<\/em:version>/<em:version>${VERSION}<\/em:version>/" install.rdf
    sed -si "s/<em:updateURL>.*<\/em:updateURL>/<em:updateURL>https:\/\/juris-m.github.io\/juris-m\/${CLIENT}\/update.rdf<\/em:updateURL>/" install.rdf
}

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

function xx-fix-product-id () {
    sed -si "s/zoteroMacWordIntegration@zotero.org/jurismMacWordIntegration@juris-m.github.io/g" install.rdf
}

function xx-fix-product-name () {
    sed -si "s/Zotero/Juris-M/g" install.rdf
}

function xx-fix-contributor () {
    sed -si "/<\/em:developer>/a\        <em:contributor>Frank Bennett</em:contributor>" install.rdf
}

function xx-install-icon () {
    cp ../additives/mlz_z_32px.png install/zotero.png
}

function xx-fix-homepage-url () {
    sed -si "s/<em:homepageURL>.*<\/em:homepageURL>/<em:homepageURL>https:\/\/juris-m.github.io\/downloads<\/em:homepageURL>/" install.rdf
}

function xx-fix-icon-url () {
    sed -si "s/<em:iconURL>.*<\/em:iconURL>/<em:iconURL>chrome:\/\/zotero\/skin\/mlz_z_32px.png<\/em:iconURL>/" install.rdf
}

function xx-fix-target-id () {
    sed -si "s/zotero@chnm.gmu.edu/juris-m@juris-m.github.io/g" install.rdf
}

function xx-add-update-key () {
    sed -si "/<\/em:unpack>/a\        <em:updateKey>MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDJqWvOZqiHGp8hLJI92KIp6t1pKP2Q2t+5glUh7JSl+2pdt8y9ANHT1Bx3YrKDi1xwXJ7FNi4mss5XFqEmuJf2TDn02+V6D0hFsNEsSlkCcsznwnCYzeU8GKAhlgjeXz7YPQswLLSk61af/hIhdYUEyYQbxmIAOHDHgMeRcuYJ+QIDAQAB</em:updateKey>" install.rdf

}

function xx-add-install-check-module () {
    cp ../additives/install_check.jsm resource
}

function xx-apply-patch () {
    patch -p1 < ../additives/macword-install-check.patch >> "${LOG_FILE}" 2<&1
}


function xx-make-the-bundle () {
    zip -r "${XPI_FILE}" * >> "${LOG_FILE}"
}

function build-the-plugin () {
        xx-make-build-directory
        cd build
        xx-retrieve-compiled-plugin
        set-install-version
        xx-install-icon
        xx-fix-product-id
        xx-fix-product-name
        xx-fix-contributor
        xx-install-icon
        xx-fix-homepage-url
        xx-fix-icon-url
        xx-fix-target-id
        xx-add-update-key
        xx-add-install-check-module
        xx-apply-patch
        xx-make-the-bundle
        cd ..
    }
    