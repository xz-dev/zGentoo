# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson

NV_DRIVERVER="525.89.02"

DESCRIPTION="VA-API implementation that uses NVDEC as a backend"
HOMEPAGE="https://github.com/elFarto/nvidia-vaapi-driver/"
SRC_URI="
    https://github.com/elFarto/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
    https://github.com/NVIDIA/open-gpu-kernel-modules/archive/refs/tags/${NV_DRIVERVER}.tar.gz -> open-gpu-kernel-modules-${NV_DRIVERVER}.tar.gz
"

IUSE="+direct"
LICENSE="MIT Expat"
KEYWORDS="~amd64"
SLOT="0"

BDEPEND="
    media-libs/nv-codec-headers
    media-video/ffmpeg[nvenc]
"
RDEPEND="=x11-drivers/nvidia-drivers-${NV_DRIVERVER}"

src_prepare() {
    default
    cp ${FILESDIR}/99nvidia-vaapi ${S}/99nvidia-vaapi
    if use direct; then
        echo "Enabeling direct access.."
        "./${S}/extract_headers.sh" "${WORKDIR}/open-gpu-kernel-modules-${NV_DRIVERVER}"
        echo "NVD_BACKEND=direct" >> ${S}/99nvidia-vaapi
    fi
}

src_install() {
    meson_src_install
    dosym /usr/lib64/dri/nvidia_drv_video.so /usr/lib64/va/drivers/nvidia_drv_video.so
    doenvd ${S}/99nvidia-vaapi
}
