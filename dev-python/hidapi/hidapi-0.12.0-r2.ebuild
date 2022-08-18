# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( pypy3 python3_{9..10} )

inherit edos2unix distutils-r1

MY_PV=${PVR/-r/.post}

DESCRIPTION="A Cython interface to the hidapi from https://github.com/libusb/hidapi"
HOMEPAGE="https://pypi.org/project/hidapi"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${PN}-${MY_PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${PN}-${MY_PV}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 ~x86"
IUSE="test"
RESTRICT="!test? ( test )"

DEPEND="dev-python/hid[${PYTHON_USEDEP}]
	dev-python/setuptools[${PYTHON_USEDEP}]"

python_test() {
	"${PYTHON}" setup.py test || die
}
