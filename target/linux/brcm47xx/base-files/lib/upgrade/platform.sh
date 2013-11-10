PART_NAME=linux

get_fw_mtd () {
	grep "\"$PART_NAME\"" < /proc/mtd | cut -d':' -f1
}

get_current_magic_long () {
	dd bs=4 count=1 2>/dev/null < /dev/"$(get_fw_mtd)" | hexdump -v -n 4 -e '1/1 "%02x"'
}

platform_check_image() {
	[ "$ARGC" -gt 1 ] && return 1

	magic="$(get_magic_long "$1")"
	# For Belkin support, check on magic in current image.
	cmagic="$(get_current_magic_long)"

	case "$cmagic" in
	78563412) # Belkin F7Dxxxx QA Firmware
		if [ $magic = 78563412 ] ; then
			return 0
		else
			echo "Invalid image for this router."
			echo "Please use a openwrt-f7dxxxx-*.bin file"
			return 1
		fi
		;;
	*)
		case "$magic" in
			# .trx files
			48445230) return 0;;
			*)
				echo "Invalid image type. Please use only .trx files"
				return 1
			;;
		esac
		;;
	esac
}

# use default for platform_do_upgrade()
