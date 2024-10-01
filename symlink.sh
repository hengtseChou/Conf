function symlink {
	help() {
		echo "Usage:symlink <dotfile> [--to-home] [--to-config] [--custom-dir <path>]" >&2
	}

	if [ $# -lt 1 ]; then
	  help
	  return 1
	fi

	source="$1"
	shift
	PARSED=$(getopt -o '' --long to-home,to-config,custom-dir: -- "$@")
	if [[ $? -ne 0 ]]; then
	  return 1
	fi
	eval set -- "$PARSED"

	target_dir=""
	while true; do
	  case "$1" in
		--to-home)
		  target_dir="$HOME"
		  shift
		  ;;
		--to-config)
		  target_dir="$HOME/.config"
		  shift
		  ;;
		--custom-dir)
		  target_dir="$2"
		  shift 2
		  ;;
		--)
		  shift # End of options
		  break
		  ;;
		*)
		  echo "Invalid option: $1" >&2
		  return 1
		  ;;
	  esac
	done

	# If no valid options were provided (target_dir is empty), show an error and exit
	if [ -z "$target_dir" ]; then
	  help
	  return 1
	fi

	target="$target_dir/$(basename $source)"

	if [ -L "${target}" ]; then
		# is a symlink
		rm ${target}
		ln -s ${source} ${target}
		echo ":: Existing symlink ${target} removed."
		echo ":: Symlink ${source} -> ${target} created."
	elif [ -d ${target} ]; then
		# is a dir
		rm -rf ${target}/
		ln -s ${source} ${target}
		echo ":: Existing directory ${target} removed."
		echo ":: Symlink ${source} -> ${target} created."
	elif [ -f ${target} ]; then
		# is a file
		rm ${target}
		ln -s ${source} ${target}
		echo ":: Existing file ${target} removed."
		echo ":: Symlink ${source} -> ${target} created."
	else
		ln -s ${source} ${target}
		echo ":: New symlink ${source} -> ${target} created."
	fi
}
