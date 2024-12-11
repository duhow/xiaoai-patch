PACKAGE_NAME="FFmpeg"
PACKAGE_VERSION="4.4"
PACKAGE_SRC="https://github.com/FFmpeg/FFmpeg/archive/refs/tags/n${PACKAGE_VERSION}.tar.gz"
PACKAGE_DEPENDS="openssl libxml lame opus soxr speex libvorbis"

configure_package() {
	export PKG_CONFIG_LIBDIR="${BUILD_PKG_CONFIG_LIBDIR}"
	export PKG_CONFIG_SYSROOT_DIR="${BUILD_PKG_CONFIG_SYSROOT_DIR}"

	ENCODERS=""
	for COD in aac ac3 alac aptx aptx_hd flac g723_1 opus vorbis zlib \
		pcm_alaw pcm_mulaw pcm_s16be pcm_s16le pcm_s24be pcm_s24le pcm_u16be pcm_u16le pcm_u24be pcm_u24le ; do
		ENCODERS="${ENCODERS} --enable-encoder=${COD}"
	done

	DIS_DECODERS=""
	for COD in h261 h263 h263_v4l2m2m h263p h264_v4l2m2m h264 hevc \
		mpeg1video mpeg2video mpeg4 mpeg4_v4l2m2m msmpeg4v2 msmpeg4v3 ; do
		DIS_DECODERS="${DIS_DECODERS} --disable-encoder=${COD} --disable-decoder=${COD}"
	done

	VID_FILTERS=""
	for FIL in addroi alphaextract alphamerge amplify ass atadenoise avgblur bbox bilateral \
		bitplanenoise blackdetect blackframe blend bm3d boxblur bwdif cas chromahold \
		chromakey chromanr chromashift ciescope colorbalance colorcontrast colorcorrect colorchannelmixer \
		colorize colorkey colorhold colorlevels colormatrix colorspace convolution convolve \
		coreimage crop cropdetect cue curves datascope dblur deband deblock decimate dedot deflicker \
		derain deshake dilation displace drawbox exposure find_rect freezedetect freezeframes gblur gradfun \
		histeq histogram hue interlace lagfun lenscorrection lensfun lumakey \
		maskfun median monochrome msad ocr ocv overlay palettegen phase pixscope \
		pseudocolor rotate scale scroll sr swapuv telecine transpose vflip vignette xbr xfade \
		yadif zoompan zscale ; do
		VID_FILTERS="${VID_FILTERS} --disable-filter=${FIL}"
	done

	DIS_OPTS=""
	for OPTS in libx264 libx265 crystalhd dxva2 cuda cuvid nvenc avisynth frei0r \
		libopencore-amrnb libopencore-amrwb libdc1394 libgsm libilbc libvo-amrwbenc \
		symver swscale ; do
		DIS_OPTS="${DIS_OPTS} --disable-${OPTS}"
	done

	# compile with -fpic flag, otherwise the soxr package will fail to build
	./configure \
		--prefix=${INSTALL_PREFIX} \
		--arch=${BUILD_TARGET} \
		--target-os=linux \
		--cross-prefix=${BUILD_TARGET}- \
		--cc="${BUILD_CC} -fPIC" \
		--cxx="${BUILD_CXX}" \
		--extra-cflags="${BUILD_CFLAGS} -w" \
		--extra-ldflags="${BUILD_LDFLAGS}" \
		--pkg-config="/usr/bin/pkg-config" \
		--enable-openssl \
		--enable-shared --disable-static \
		--enable-small \
		--disable-runtime-cpudetect \
		--disable-doc --disable-htmlpages --disable-manpages \
		--enable-gpl --enable-nonfree \
		--disable-ffprobe \
		--enable-ffmpeg \
		--enable-ffplay \
		${DIS_DECODERS} \
		${DIS_OPTS} \
		--enable-libfdk-aac \
		--enable-libmp3lame \
		--enable-libvorbis \
		--enable-libspeex \
		--enable-libopus \
		--enable-libsoxr

		#${VID_FILTERS} \
		#${DIS_OPTS} \

		# --disable-avfilter # REQUIRED by MPD

}

make_package() {
	make -j${MAKE_JOBS}
}

install_package() {
	make DESTDIR=${STAGING_DIR} install
}

postinstall_package() {
	rm -rvf ${STAGING_DIR}/usr/share/ffmpeg

	if [ ! -f "${STAGING_DIR}/${INSTALL_PREFIX}/bin/ffmpeg" ]; then
		echo_error "Error: ffmpeg binary not found!"
		return 1
	fi
}
