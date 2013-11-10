PART_NAME=linux

get_fw_mtd () {
	grep "\"$PART_NAME\"" < /proc/mtd | cut -d':' -f1
}

get_current_magic_long () {
	dd bs=4 count=1 2>/dev/null < /dev/"$(get_fw_mtd)" | hexdump -v -n 4 -e '1/1 "%02x"'
}

get_machine() {
	awk 'BEGIN{FS="[ \t]+:[ \t]"} /machine/ {print $2}' /proc/cpuinfo
}

platform_check_image() {
	[ "$ARGC" -gt 1 ] && return 1

	magic="$(get_magic_long "$1")"
	# For Belkin support, check on magic in current image.
	cmagic="$(get_current_magic_long)"

	case "$cmagic" in
	22031020) # F7D3301
		if [ $magic = 22031020 ] || [ $magic = 78563412 ]; then
			return 0
		else
			echo "Invalid image for this router."
			echo "Either f7d3301 or f7dxxxx-qa .bin files required."
			return 1
		fi
		;;
	28090920) # F7D3302
		if [ $magic = 28090920 ] || [ $magic = 78563412 ]; then
			return 0
		else
			echo "Invalid image for this router."
			echo "Either f7d3302 or f7dxxxx-qa .bin files required."
			return 1
		fi
		;;
	06101020) # F7D4302
		if [ $magic = 06101020 ] || [ $magic = 78563412 ]; then
			return 0
		else
			echo "Invalid image for this router."
			echo "Either f7d4302 or f7dxxxx-qa .bin files required."
			return 1
		fi
		;;
	17850100) # F7D4401
		if [ $magic = 17850100 ] || [ $magic = 78563412 ]; then
			return 0
		else
			echo "Invalid image for this router."
			echo "Either f7d4401 or f7dxxxx-qa .bin files required."
			return 1
		fi
		;;
	78563412) # Belkin F7Dx30x QA Firmware
		if [ $magic = 78563412 ] ; then
			return 0
		else
			echo "Potentially invalid image for this router."
			echo "Please use a f7dxxxx-qa .bin file (or force)"
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
