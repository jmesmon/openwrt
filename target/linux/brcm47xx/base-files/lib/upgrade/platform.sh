PART_NAME=linux

get_current_magic_long () {
	dd bs=4 count=1 2>/dev/null < "$(find_mtd_part $PART_NAME)" | hexdump -v -n 4 -e '1/1 "%02x"'
}

belkin_check () {
	local m=$1
	local n=$2

	if [ $cmagic != $m ]; then
		return 0
	fi

	if [ $magic = $m ] || [ $magic = 78563412 ]; then
		ok=true
		return 0
	else
		echo "Invalid image for this router."
		echo "Either $n or f7dxxxx .bin files required."
		return 1
	fi
}

platform_check_image() {
	[ "$ARGC" -gt 1 ] && return 1

	ok=false
	magic="$(get_magic_long "$1")"
	# For Belkin support, check on magic in current image.
	cmagic="$(get_current_magic_long)"

	belkin_check 22031020 f7d3301 || return 1
	belkin_check 28090920 f7d3302 || return 1
	belkin_check 06101020 f7d4302 || return 1
	belkin_check 17850100 f7d4401 || return 1

	$ok && return 0

	local b_qa=78563412
	if [ $cmagic == $b_qa ]; then

		if [ $magic = $b_qa ] ; then
			return 0
		else
			echo "Potentially invalid image for this router."
			echo "Please use a openwrt-f7dxxxx-*.bin file"
			return 1
		fi
	fi

	if [ $magic = 48445230 ]; then
		return 0
	else
		echo "Invalid image type. Please use only .trx files"
		return 1
	fi
}

# use default for platform_do_upgrade()
