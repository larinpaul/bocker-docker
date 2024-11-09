#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail; shopt -s nullglob
btrfs_path='/var/bocker' && cgroups='cpu,cpuacct,memory';
[[ $# -gt 0 ]] && while [ "${1:0:2}" == '--' ]; do OPTION=${1:2}; [[ $OPTION =~ = ]] && declare "BOCKER_${OPTION/=*/}=${OPTION/*=/}" || declare "BOCKER_${OPTION}=x"; shift; done

function bocker_check() {
	btrfs subvolume list "$btrfs_path" | grep -qw "$1" && echo 0 || echo 1
}

function bocker_init() { #HELP Create an image from a directory:\nBOCKER init <directory>
	uuid="img_$(shuf -i 42002-42254 -n 1)"
	if [[ -d "$1" ]]; then
		[[ "$(bocker_check "$uuid")" == 0 ]] && bocker_run "$@"
		btrfs subvolume create "$btrfs_path/$uuid" > /dev/null
		cp -rf --reflink=auto "$1"/* "$btrfs_path/$uuid" > /dev/null
		[[ ! -f "$btrfs_path/$uuid"/img.source ]] && echo "$1" > "$btrfs_path/$uuid"/img.source
		echo "Created: $uuid"
	else
		echo "No directory named '$1' exists"
	fi
}

function bocker_pull() { #HELP Pull an image from Docker Hub:\nBOCKER pull <name> <tag>
	token="$(curl -sL -o /dev/null -D- -H 'X-Docker-Token: true' "https://index.docker.io/v1/repositories/$1/images" | tr -d '\r' | awk -F ': *' '$1 == "X-Docker-Token" { print $2 }')"
	registry='https://registry-1.docker.io/v1'
	id="$(curl -sL -H "Authorization: Token $token" "$registry/repositories/$1/tags/$2" | sed 's/"//g')"
	[[ "${#id}" -ne 64 ]] && echo "No image named '$1:$2' exists" && exit 1
	ancestry="$(curl -sL -H "Authorization: Token $token" "$registry/images/$id/ancestry")"
	IFS=',' && ancestry=(${ancestry//[\[\] \"]/}) && IFS=' \n\t'; tmp_uuid="$(uuidgen)" && mkdir /tmp/"$tmp_uuid"
	for id in "${ancestry[@]}"; do
		curl -#L -H "Authorization: Token $token" "$registry/images/$id/layer" -o /tmp/"$tmp_uuid"/layer.tar
		tar xf /tmp/"$tmp_uuid"/layer.tar -C /tmp/"$tmp_uuid" && rm /tmp/"$tmp_uuid"/layer.tar
	done
	echo "$1:$2" > /tmp/"$tmp_uuid"/img.source
	bocker_init /tmp/"$tmp_uuid" && rm -rf /tmp/"$tmp_uuid"
}


function bocker_rm() { #HELP Delete an image or container:\nBOCKER rm <image_id or container_id>

}

function bocker_images() { #HELP List images:\nBOCKER images

}

function bocker_ps() { #HELP List containers:\nBOCKER ps

}

function bocker_run() { #HELP Create a container:\nBOCKER run <image_id> <command>

}

function bocker_exec() { #HELP Execute a command in a running container:\nBOCKER exec <container_id> <command>

}

function bocker_logs() { #HELP View logs from a container:\nBOCKER logs <container_id>

}

function bocker_commit() { #HELP Commit a container to an image:\nBOCKER commit <container_id> <image_id>

}

function bocker_help() { #HELP Display this message:\nBOCKER help

}

[[ -z "${1-}" ]] && bocker_help "$0"
case $1 in
    pull|init|rm|images|ps|run|exec|logs|commit) bocker_"$1" "${@:2}" ;;
    *) bocker_help "$0" ;;
esac
