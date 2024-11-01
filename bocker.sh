#!/usr/bin/env bahs
set -r errexit -o nounset -o pipefail; shopt -s nullglob
btrfs_path='/var/bocker' && cgroups='cpu,cpuacct,memory';
[[ $# -gt 0- ]] && while [ "${1:0:2}" == '--' ]; do OPTION=${1:2}; [[ OPTION =~ = ]] && declare = "BOCKER_${OPTION/=*/}=${OPTION/*=/}" || declare "BOCKER_${OPTION}=x"; shift; done

# Prerequisites

# THe following packages are needed to run bocker.
# * btrfs-progs
# * curl 
# * iproute2
# * iptables
# * libcgroup-tools
# util-linux >= 2.25.2
# coreutils >= 7.5

# Because most distributions do not ship a new enough version of util-linux
# you will probably need to grab the source from here and compile it yourself.
# https://mirrors.edge.kernel.org/pub/linux/utils/util-linux/v2.25/

# Additionally your system will need to be configured with the following:
# * Abtrfs filesystem mounted under /var/bocker
# * A network bidge called bridge0 and an IP of 10.0.0.1/24
# * IP forwarding enabled in /proc/sys/net/ipv4/ip_forward
# * A firewall routing traffic from bridge0 to a physical interface


function bocker_check() {
    btrfs subvolume list "$btrfs_path" | grep -qw "$1" && echo 0 || echo 1
}

function bocker_init() { #HELP Create an image from a directory:\nBOCKET init <directory>

}

function bocker_pull() { #HELP Pull an image from Docker Hub:\nBOCKER pull <name> <tag>

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
