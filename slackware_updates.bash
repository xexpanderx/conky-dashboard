#!/usr/bin/env bash
# shellcheck source=/dev/null


###############################
# Functions
###############################
_check_args()
{
    if [[ ! $2 || $2 == "-"* ]]; then
        echo "Argument $1 requires an argument. Exciting... "
        exit 1
    fi
}


_printhelp(){
    echo -e "### Prompt for Slackware and optional updates. ###\n"
	echo -e "Syntax ./slackware_updates.bash\n\
			 \n-r|--release \t[14.2/current]\n\
			 \nOptional\
			 \n--sbopkg \t\tShow Sbopkg update\
			 \n--nvidia \t\tShow Nvidia update\
			 \n--google-chrome \tShow Google-Chrome update\
			 \n--skype \t\tShow Skype update\
			 \n--kernel \t\tShow Linux update"
	exit 0
}

_sbopkg_version_web()
{
	if [[ "$1" == "current" ]]; then
		readonly GITHUB="https://raw.githubusercontent.com/"
		readonly PONCE=$GITHUB"Ponce/slackbuilds/master/ChangeLog.txt"
		readonly SBOPKG_VERSION_WEB=$(curl -s "$PONCE" | head -n1)
	elif [[ "$1" == "14.2" ]]; then
		readonly SBOPKG_VERSION_WEB=$(curl \
		                              -s \
					                  "https://slackbuilds.org/ChangeLog.txt" \
					                  | head -n1)
	else
		echo "$1 not supported."
		exit 1
	fi
}

_sbopkg_version_local()
{
	if [[ "$1" == "current" ]]; then
		readonly SBOPKG_VERSION_LOCAL=$(< \
		                                /var/lib/sbopkg/SBo-git/ChangeLog.txt \
		                                head -n1)
	elif [[ "$1" == "14.2" ]]; then
		readonly SBOPKG_VERSION_LOCAL=$(< /var/lib/sbopkg/SBo/ChangeLog.txt \
		                                head -n1)
	else
		echo "$1 not supported."
		exit 1
	fi
}

_check_slackpkg_updates()
{
	rm /var/lock/slackpkg.* > /dev/null 2>&1 # Unlock

	if /usr/sbin/slackpkg check-updates 2> /dev/null \
	   | grep -q "AVAILABLE UPDATES" ; then
		echo "Slackpkg: Updates available"
	else
		echo "Slackpkg: No updates available"
	fi

	rm /var/lock/slackpkg.* > /dev/null 2>&1 # Unlock
}

_check_sbopkg_updates()
{
	_sbopkg_version_web "$RELEASE"
	_sbopkg_version_local "$RELEASE"

	if [[ -n $SBOPKG_VERSION_WEB ]]; then

		if [[ "$SBOPKG_VERSION_WEB" == "$SBOPKG_VERSION_LOCAL" ]]; then
			echo "Sbopkg: No updates available"
		else
			echo "Sbopkg: Updates available"
		fi
	fi
}

_kernel_version_web()
{
	VERSION=$(echo "$1" | awk -F "." '{print $1}')
	SUBVERSION=$(echo "$1" | awk -F "." '{print $2}')
	KERNEL_LINK="https://cdn.kernel.org/pub/linux/kernel/v"
	readonly KERNEL_VERSION_WEB=$(w3m \
	                              -dump \
				                  "$KERNEL_LINK$VERSION.x"/ \
				                  | grep "ChangeLog-$VERSION.$SUBVERSION" \
				                  | sort -V \
				                  | tail -n1 \
								  | awk '{print $1}' \
				                  | sed 's/ChangeLog-//g')
}

_kernel_version_local()
{
	readonly KERNEL_VERSION_LOCAL=$(uname -r)
}

_check_kernel_updates()
{
	_kernel_version_local
	_kernel_version_web "$KERNEL_VERSION_LOCAL"

	if [[ -n "$KERNEL_VERSION_WEB" ]]; then

		if [[ "$KERNEL_VERSION_WEB" == "$KERNEL_VERSION_LOCAL" ]]; then
			echo "Linux: No updates available"
		else
			echo "Linux: Updates available"
		fi
	fi
}

_nvidia_version_local()
{
	readonly NVIDIA_VER_LOCAL=$(nvidia-smi \
	                            | grep "Driver Version" \
					            | awk '{print $6}')
}

_nvidia_version_web()
{
	readonly NVIDIA_VER_WEB=$(curl \
	                          "https://developer.nvidia.com/vulkan-driver" -s \
							  | grep "Vulkan Beta Driver Downloads" \
							  | awk -F "Linux driver version " '{print $2}' \
							  | awk '{print $1}' \
							  | tr -d '[:space:]')
}

_check_nvidia_updates()
{
	_nvidia_version_local
	_nvidia_version_web

	if [[ -n "$NVIDIA_VER_WEB" ]]; then

		if [[ "$NVIDIA_VER_WEB" == "$NVIDIA_VER_LOCAL" ]]; then
			echo "Nvidia: No updates available"
		else
			echo "Nvidia: Updates available"
		fi
	fi
}

_check_google_chrome_updates()
{
	ROOT_LINK=https://dl.google.com/linux/direct/
	RPM_LINK=google-chrome-stable_current_x86_64.rpm
	VAR_LOG=/var/log/packages/google-chrome-

	GOOGLE_CHROME_VERSION=$(wget -qO- $ROOT_LINK$RPM_LINK \
							| head -c96 \
							| strings \
							| rev \
							| awk -F"[:-]" '/emorhc/ { print $1 "-" $2 }' \
							| rev)

	if echo "$GOOGLE_CHROME_VERSION" | grep -Fq '-'; then
		GOOGLE_CHROME_VERSION=${GOOGLE_CHROME_VERSION%-*}
	fi

	if /bin/ls "$VAR_LOG$GOOGLE_CHROME_VERSION"-* >/dev/null 2>&1 ; then
		echo "Google-Chrome: No updates available"
	else
		echo "Google-Chrome: Updates available"
 	fi


}

_check_skype_updates()
{
	ROOT_LINK=https://repo.skype.com/latest/
	RPM_LINK=skypeforlinux-64.rpm
	VAR_LOG=/var/log/packages/skypeforlinux-

	SKYPE_VERSION=$(wget -qO- $ROOT_LINK$RPM_LINK \
					| head -c96 \
					| strings \
					| rev \
					| awk -F"[:-]" '/xunilrofepyks/ { print $2 }' \
					| rev)

	if /bin/ls "$VAR_LOG$SKYPE_VERSION"-* >/dev/null 2>&1 ; then
		echo "Skype: No updates available"
	else
		echo "Skype: Updates available"
 	fi


}
###############################
# Check arguments
###############################
while (( "$#" )); do
    case "$1" in
		-h|--help)
			_printhelp
			exit 0
			;;
    	-r|--release)
			_check_args "$1" "$2"
			readonly RELEASE="$2"
			shift 2
			;;
    	-k|--kernel)
			readonly KERNEL="True"
			shift 1
			;;
    	--nvidia)
			readonly NVIDIA="True"
			shift 1
			;;
    	--sbopkg)
			readonly SBOPKG="True"
			shift 1
			;;
    	--google-chrome)
			readonly GOOGLE_CHROME="True"
			shift 1
			;;
    	--skype)
			readonly SKYPE="True"
			shift 1
			;;
    	-*) # unsupported flags
      		echo "Invalid argument $1. Exciting... "
      		exit 1
      		;;
  esac
done


###############################
# Main script
###############################
_check_slackpkg_updates

if [[ -n $SBOPKG ]]; then
	_check_sbopkg_updates
fi

if [[ -n $KERNEL ]]; then
	_check_kernel_updates
fi

if [[ -n $NVIDIA ]]; then
	_check_nvidia_updates
fi

if [[ -n $GOOGLE_CHROME ]]; then
	_check_google_chrome_updates
fi

if [[ -n $SKYPE ]]; then
	_check_skype_updates
fi
