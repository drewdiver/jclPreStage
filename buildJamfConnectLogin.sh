#!/bin/sh

pkgname="JamfConnectLoginPreStage"
identifier="com.company.${pkgname}"
version="1.5.2"

PATH=/usr/bin:/bin:/usr/sbin:/sbin export PATH

projectfolder=$(dirname "$0")

pkgbuild --root "${projectfolder}/payload" \
         --identifier "${identifier}" \
         --version "${version}" \
         --scripts "${projectfolder}/scripts" \
         --install-location "/" \
         --sign "XXXXXXXXXX" \
         "${projectfolder}/${pkgname}"

productbuild --package "${projectfolder}/${pkgname}" \
  "${projectfolder}/${pkgname}-${version}.pkg"

rm "${projectfolder}/${pkgname}"

productsign --sign 'Developer ID Installer: My Company (XXXXXXXXXX)' \
	"${projectfolder}/${pkgname}-${version}.pkg" "${projectfolder}/${pkgname}-${version}-signed.pkg"

rm "${projectfolder}/${pkgname}-${version}.pkg"