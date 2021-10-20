# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

QT5_MODULE="qtwayland"
inherit qt5-build

DESCRIPTION="Wayland platform plugin for Qt"

if [[ ${QT5_BUILD_TYPE} == release ]]; then
	KEYWORDS="~amd64 ~arm ~arm64 ~hppa ~ppc ~ppc64 ~riscv ~sparc ~x86"
fi

SLOT=5/${QT5_PV} # bug 815646
IUSE="vulkan X"

DEPEND="
	=dev-qt/qtcore-${QT5_PV}*:5=
	=dev-qt/qtgui-${QT5_PV}*:5=[egl,libinput,vulkan=,X?]
	media-libs/libglvnd
	x11-libs/libxkbcommon
	vulkan? ( dev-util/vulkan-headers )
	X? (
		=dev-qt/qtgui-${QT5_PV}*[-gles2-only]
		x11-libs/libX11
		x11-libs/libXcomposite
	)
"
RDEPEND="${DEPEND}"

# QT5_TARGET_SUBDIRS=(
# 	src/client
# 	src/hardwareintegration/client
# 	src/plugins/decorations
# 	src/plugins/hardwareintegration/client
# 	src/plugins/platforms
# )

src_prepare() {
	_qt_use_disable_compositor() {
		[[ $# -ge 2 ]] || die "${FUNCNAME}() requires at least two arguments"

		local module=$1
		shift 1

		echo "$@" | xargs sed -i -e "s/qtHaveModule(${module})/false/g" || die
	}

	_qt_use_disable_compositor waylandcompositor \
		src/plugins/hardwareintegration/hardwareintegration.pro \
		src/imports/imports.pro \
		examples/wayland/wayland.pro \
		tests/auto/auto.pro

	qt5-build_src_prepare
}

src_configure() {
	local myqmakeargs=(
		--
		-no-feature-wayland-server
	)

	qt5-build_src_configure
}
