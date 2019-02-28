
ROOT_DIR=${CURDIR}

PLATFORMS_SUPPORTED=win linux macos
ifeq (${OS},Windows_NT)
	PLATFORM:=win
else
	UNAME_S=${shell uname -s}
	ifeq (${UNAME_S},Linux)
		PLATFORM:=linux
	endif
	ifeq (${UNAME_S},Darwin)
		PLATFORM:=macos
	endif
endif

QT_SRC_FILE=qt-everywhere-src-5.12.1.tar.xz
QT_SRC_MD5=6a37466c8c40e87d4a19c3f286ec2542
QT_SRC_URL=https://download.qt.io/official_releases/qt/5.12/5.12.1/single/qt-everywhere-src-5.12.1.tar.xz
QT_SRC_DIR=qt-everywhere-src-5.12.1
QT_BUILD_DIR=${QT_SRC_DIR}/build
QT_PREFIX=${ROOT_DIR}/qt

BUILD_THREADS:=4

PACKAGE_FILE=cutter-deps-${PLATFORM}.tar.gz

all: qt pkg

.PHONY: clean
clean: clean-qt

.PHONY: distclean
distclean: distclean-qt

# Download Targets

define download_extract
	curl -L "$1" -o "$2"
	echo "$3 $2" | md5sum -c -
	tar -xf "$2"
endef

${QT_SRC_DIR}:
	@echo ""
	@echo "#########################"
	@echo "# Downloading Qt Source #"
	@echo "#########################"
	@echo ""
	$(call download_extract,${QT_SRC_URL},${QT_SRC_FILE},${QT_SRC_MD5})


qt: ${QT_SRC_DIR}
	@echo ""
	@echo "#########################"
	@echo "# Building Qt           #"
	@echo "#########################"
	@echo ""

	mkdir -p "${QT_BUILD_DIR}"
	cd "${QT_BUILD_DIR}" && \
		../configure \
			-prefix "${QT_PREFIX}" \
			-opensource -confirm-license \
			-release \
			-xcb \
			-gtk \
			-qt-libpng \
			-qt-libjpeg \
			-no-opengl \
			-no-feature-cups \
			-no-feature-icu \
			-no-sql-db2 \
			-no-sql-ibase \
			-no-sql-mysql \
			-no-sql-oci \
			-no-sql-odbc \
			-no-sql-psql \
			-no-sql-sqlite2 \
			-no-sql-sqlite \
			-no-sql-tds \
			-nomake tests \
			-nomake examples \
			-skip qtwebengine \
			-skip qt3d \
			-skip qtcanvas3d \
			-skip qtcharts \
			-skip qtconnectivity \
			-skip qtdeclarative \
			-skip qtdoc \
			-skip qtscript \
			-skip qtdatavis3d \
			-skip qtgamepad \
			-skip qtlocation \
			-skip qtgraphicaleffects \
			-skip qtmultimedia \
			-skip qtpurchasing \
			-skip qtscxml \
			-skip qtsensors \
			-skip qtserialbus \
			-skip qtserialport \
			-skip qtspeech \
			-skip qttools \
			-skip qttranslations \
			-skip qtvirtualkeyboard \
			-skip qtwebglplugin \
			-skip qtwebsockets \
			-skip qtwebview

	cd "${QT_BUILD_DIR}" && make -j${BUILD_THREADS} > /dev/null
	cd "${QT_BUILD_DIR}" && make install > /dev/null

.PHONY: clean-qt
clean-qt:
	rm -f "${QT_SRC_FILE}"
	rm -rf "${QT_SRC_DIR}"

.PHONY: distclean-qt
distclean-qt: clean-qt
	rm -rf "${QT_PREFIX}"

${PACKAGE_FILE}: qt
	tar -czf "${PACKAGE_FILE}" qt

.PHONY: pkg
pkg: ${PACKAGE_FILE}

.PHONY: distclean-pkg
distclean-pkg:
	rm -f "${PACKAGE_FILE}"



