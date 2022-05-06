# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module systemd

DESCRIPTION="Like Prometheus, but for logs."
HOMEPAGE="https://grafana.com/loki/"
SRC_URI="https://github.com/grafana/loki/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

IUSE="fluent-bit promtail +server tools systemd"

RESTRICT="mirror strip"

RDEPEND="acct-group/grafana
	acct-user/${PN}
	fluent-bit? ( app-admin/fluent-bit )"
DEPEND="${RDEPEND}"

PATCHES=("${FILESDIR}/${P}-fix-go18.patch")

src_compile() {
	BUILD_VERSION="${PV}"
	BUILD_BRANCH="${PV}"
	BUILD_REVISION="${PV}"
	BUILD_USER="${P}"
	BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"`

	VPREFIX="github.com/grafana/${PN}/vendor/github.com/prometheus/common/version"

	EGO_LDFLAGS="-s -w -X ${VPREFIX}.Branch=${BUILD_BRANCH} -X ${VPREFIX}.Version=${BUILD_VERSION} -X ${VPREFIX}.Revision=${BUILD_REVISION} -X ${VPREFIX}.BuildUser=${BUILD_USER} -X ${VPREFIX}.BuildDate=${BUILD_DATE}"

	if use server; then
		einfo "Building cmd/${PN}/${PN}..."
		mkdir -p cmd/${PN} || die
		CGO_ENABLED=0 go build -ldflags "-extldflags \"-static\" ${EGO_LDFLAGS}" -tags netgo -mod vendor -o cmd/${PN}/${PN} ./cmd/${PN} || die
	fi
	if use tools; then
		einfo "Building cmd/logcli/logcli..."
		mkdir -p cmd/logcli || die
		CGO_ENABLED=0 go build -ldflags "-extldflags \"-static\" ${EGO_LDFLAGS}" -tags netgo -mod vendor -o cmd/logcli/logcli ./cmd/logcli || die
		einfo "Building cmd/${PN}-canary/${PN}-canary..."
		mkdir -p cmd/${PN}-canary || die
		CGO_ENABLED=0 go build -ldflags "-extldflags \"-static\" ${EGO_LDFLAGS}" -tags netgo -mod vendor -o cmd/${PN}-canary/${PN}-canary ./cmd/${PN}-canary || die
	fi
	if use promtail; then
		einfo "Building cmd/${PN}/promtail..."
		mkdir -p cmd/promtail || die
		if use systemd; then
			CGO_ENABLED=1 go build -ldflags "${EGO_LDFLAGS}" -tags netgo -mod vendor -o cmd/promtail/promtail ./cmd/promtail || die
		else
			CGO_ENABLED=0 go build -ldflags "${EGO_LDFLAGS}" -tags netgo -mod vendor -o cmd/promtail/promtail ./cmd/promtail || die
		fi
	fi
	if use fluent-bit; then
		einfo "Building cmd/fluent-bit/out_${PN}..."
		mkdir -p cmd/fluent-bit/ || die
		go build -ldflags "${EGO_LDFLAGS}" -tags netgo -mod vendor -buildmode=c-shared -o cmd/fluent-bit/out_${PN}.so ./cmd/fluent-bit || die
	fi
}

src_install() {
	if use server; then
		dobin "${S}/cmd/${PN}/${PN}"

		newconfd "${FILESDIR}/${PN}.confd" "${PN}"
		newinitd "${FILESDIR}/${PN}.initd" "${PN}"
        use systemd && systemd_newunit "${FILESDIR}"/${PN}.service ${PN}.service

		insinto "/etc/${PN}"
		doins "${S}/cmd/${PN}/${PN}-local-config.yaml"
		keepdir "/etc/${PN}"
		keepdir "/var/lib/${PN}"
		fowners ${PN}:grafana "/etc/${PN}"
		fowners ${PN}:grafana "/var/lib/${PN}"
	fi
	if use tools; then
		dobin "${S}/cmd/logcli/logcli"
		dobin "${S}/cmd/${PN}-canary/${PN}-canary"
	fi
	if use promtail; then
		dobin "${S}/cmd/promtail/promtail"

		newconfd "${FILESDIR}/promtail.confd" "promtail"
		newinitd "${FILESDIR}/promtail.initd" "promtail"
		use systemd && systemd_newunit "${FILESDIR}"/promtail.service promtail.service

		insinto "/etc/${PN}"
		doins "${S}/cmd/promtail/promtail-local-config.yaml"
		keepdir "/etc/${PN}"
		keepdir "/var/lib/${PN}"
		fowners ${PN}:grafana "/etc/${PN}"
		fowners ${PN}:grafana "/var/lib/${PN}"
	fi
	if use fluent-bit; then
		insinto "/usr/$(get_libdir)/${PN}"
		dolib.so "${S}/cmd/fluent-bit/out_${PN}.so"
	fi
}
