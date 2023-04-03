# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PN="${PN/gnome-shell-extension-/}"

DESCRIPTION="Extension for visualizing asusctl-ctrl(asusd) settings and status."
HOMEPAGE="https://gitlab.com/asus-linux/${MY_PN}"
SRC_AID="3c9ea3ea8550f03bff793a12e7d7035a" # attachment-id
SRC_URI="https://gitlab.com/asus-linux/${MY_PN}/uploads/${SRC_AID}/${MY_PN}_asus-linux.org.zip -> ${P}.zip"
S="${WORKDIR}/${MY_PN}@asus-linux.org"

LICENSE="GPL-3"
SLOT="0/4"
KEYWORDS="~amd64"
IUSE=""

RDEPEND="
	!!gnome-extra/gnome-shell-extension-asus-nb-gex
	!!gnome-extra/gnome-shell-extension-asusctl-gex
	!!<=gnome-base/gnome-shell-42.0
	>=gnome-base/gnome-shell-43.0
	app-eselect/eselect-gnome-shell-extensions
"
DEPEND="${RDEPEND}
	dev-libs/glib:2
"

src_unpack() {
	mkdir -p "${S}"
	cd "${S}" && unpack "${P}.zip"
}

src_install() {
	insinto "/usr/share/gnome-shell/extensions/${MY_PN}@asus-linux.org"
    doins -r ${S}/*
}

pkg_postinst() {
	ebegin "Updating list of installed extensions"
	eselect gnome-shell-extensions update
	eend $?
}