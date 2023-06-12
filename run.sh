#! /usr/bin/env bash

# Author            : Fabio Scatozza <s315216@studenti.polito.it>
# Date              : 31.05.2023
# Last Modified Date: 02.06.2023

# Copyright (c) 2023 Fabio Scatozza <s315216@studenti.polito.it>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

script_name=${0##*/}
proj_dir=$(pwd)

usage()
{
  echo "Usage: $script_name [connection-parameters] [-c | --clean] 
              toolchain-parameters top-module [vsim-options]
       Run QuestaSIM remotely or locally to simulate 'top-module'
   
   or: $script_name connection-parameters --push
       Upload the project directory
   
   or: $script_name connection-parameters [-c | --clean] --pull
       Download the project directory
   
   or: $script_name [-h | --help]
       Show this help

  Syntax 1)
  Connection parameters are optional. If provided, QuestaSIM is executed remotely:
    * the project directory
        '$proj_dir'
      is uploaded to the server
    
    * '$script_name' is launched remotely: QuestaSIM executes './scripts/main.do'
      passing 'top-module' and 'vsim-options' as arguments. 
      
      If provided, 'vsim-options' are appended to the simulation command run
      inside 'main.do'.
    
    * changes in the project directory are downloaded. If '-c | --clean' is 
      specified, the project folder is deleted from the server.
            
  Otherwise, QuestaSIM is executed locally.

  Connection Parameters

    -r, --remote  = user@host
                    e.g. 2023-socv-N@led-x3850-2.polito.it

    -p, --port    = port
                    e.g. 100XX

    -D, --dest    = remote path where to upload the project directory. 
                    By default, home. Otherwise, a path relative to home: 
                    if the path doesn't exist, it's created.
                    e.g. Desktop/folder_name/subfolder_name

    -n, --dry-run = perform a trial run

  Mandatory Toolchain Parameters

    -m, --mentor  = specifies how to initialize QuestaSIM.
    
                    If connection parameters are provided, this option specifies
                    the alias name to be called remotely.
                    e.g. setmentor 
                    In this case, after having uploaded the project directory,
                    '$script_name' calls itself on the remote machine: the simulation script
                    is then run locally relative to the server, building the -m option
                    as \"\${BASH_ALIASES[\$mentor]}\".

                    Otherwise, this option specifies the alias replacement, namely
                    the explicit command to be executed locally. 
                    e.g.  \"\${BASH_ALIASES[setmentor]}\"

  Syntax 2) Connection parameters are mandatory. The project directory is
            uploaded to the server.
    --push        = choose syntax 2)

  Syntax 3) Connection parameters are mandatory. The project directory is
            downloaded from the server.
    --pull        = choose syntax 3)
    -c, --clean   = delete project directory from the server"
}

# parse command line arguments
# getopt returns a standardized version of whatever the user input.
#   :   ->  value is required
#   ::  ->  value is optional
#       ->  no value
 
short_options=r:,p:,D:,n,c,m:,h
long_options=remote:,port:,dest:,dry-run,clean,mentor:,push,pull,help
opts=$(getopt -a -n $script_name --options $short_options --longoptions $long_options -- "$@")

# $? -> getopt exits with 0 in case of no errors
if [ $? -ne 0 ]; then
  usage 
  exit 1
fi

# replace input arguments
eval set -- "$opts"
unset opts

# defaults
clean="0"
push="0"
pull="0"

while true; do
  case "$1" in 
    -r | --remote )
      remote="$2"
      shift 2
      ;;
    -p | --port )
      port="$2"
      shift 2
      ;;
    -D | --dest )
      dest="$2"
      shift 2
      ;;
    -n | --dry-run )
      dry="--dry-run"
      shift
      ;;
    -c | --clean )
      clean="1"
      shift
      ;;
    -m | --mentor )
      mentor="$2"
      shift 2;
      ;;
    --push )
      push="1"
      shift
      ;;
    --pull )
      pull="1"
      shift
      ;;
    -h | --help )
      usage
      exit 0
      ;;
    -- )
      shift
      break
      ;;
    * )
      echo "Internal error!"
      exit 1
      ;;
  esac
done

# parse the remaining args
tcl_args="$@"

# transform mentor to bool 
mentor_bool=${mentor:+1}
mentor_bool=${mentor_bool:-0}

# check for conflicting options
if (( $push + $pull + $mentor_bool != 1 )) || (( $push && $clean )); then
  echo "Invalid combination of options"
  echo "Try with $script_name -h"
  exit 1
fi

# validate syntax 1)
if (( mentor_bool )) && [[ -z "$tcl_args" ]]; then
  echo "Missing 'top-module'"
  echo "Try with $script_name -h"
  exit 1
fi

# validate syntax 2), 3)
if (( !mentor_bool )); then

  if [[ -z "$remote" ]]; then
    echo "Missing 'connection-parameters'"
    echo "Try with $script_name -h"
    exit 1
  
  elif (( $# != 0 )); then
    echo "Unexpected args"
    echo "Try with $script_name -h"
    exit 1
  fi  

fi


if [[ -n "$remote" ]] && [[ -n "$port" ]]; then
  # specified connection parameters: remote execution
  
  # commands are built dynamically with an array: prepare rsync parameters
  # archive, verbose, human-readable, discard dangerous links, display progress bar
  rsync_opt=("-avh" "--safe-links" "--progress")

  # push dry run option, if present
  if [[ -n "$dry" ]]; then 
    rsync_opt+=($dry)
  fi

  # push port option, if present
  if [[ -n "$port" ]]; then
    rsync_opt+=("-e")
    rsync_opt+=("ssh -p $port")
  fi
 
  # clean destination path
  # try and remove ./ prefix
  dest=${dest#.}
  dest=${dest#/}
  # try and remove / suffix
  dest=${dest%/}

  # upload
  if (( push )) || (( mentor_bool )); then
    # local copy of rsync options
    rsync_opt_up=("${rsync_opt[@]}")

    # delete differences in the remote folder
    rsync_opt_up+=("--delete" "--force")

    # unfortunately remote server doesn't support --mkpath
    # preliminarily create destination folder
    if [[ -n "$dest" ]]; then 
      rsync_opt_up+=("--rsync-path")
      rsync_opt_up+=("mkdir -p ~/$dest && rsync")
    fi

    # source directory
    rsync_opt_up+=("$proj_dir")

    # destination directory
    rsync_opt_up+=("${remote}:$dest")

    rsync "${rsync_opt_up[@]}"
    
    # check for errors
    if (( $? )); then 
      echo "$script_name: rsync: upload failed."
      exit 1
    fi

  fi

  # locate remote project directory
  remote_proj_dir=$(basename "$proj_dir")
  if [[ -n "$dest" ]]; then
    remote_proj_dir="${dest}/$remote_proj_dir"
  fi

  # launch this script remotely for local execution 
  if (( mentor_bool )); then

    # enter project directory
    remote_opt=("cd $remote_proj_dir")

    # run the script found inside the project directory 
    # define the string that, once replaced, provides the command corresponding to setmentor
    remote_opt+=("&&" "bash" "./$script_name" "-m" "\"\${BASH_ALIASES[$mentor]}\"")

    # additional arguments may start with a dash
    if [[ -n "$tcl_args" ]]; then
      remote_opt+=("--" "$tcl_args")
    fi
    
    # connection parameters
    ssh_opt=("$remote" "-p $port" "${remote_opt[@]}")

    # login and run
    ssh ${ssh_opt[@]}
    ssh_exit_code="$?"

    # check exit code    
    if (( $ssh_exit_code == 255 )); then
      echo "$script_name: ssh: remote execution failed."
      exit 1
    else
      echo "$script_name: ssh: remote returned $ssh_exit_code"
    fi
  fi

  # fetch changes
  if (( pull )) || (( mentor_bool )); then
    # local copy of rsync options
    rsync_opt_do=("${rsync_opt[@]}")

    # source directory
    # / so to target the folder content
    rsync_opt_do+=("${remote}:$remote_proj_dir/")

    # destination directory
    rsync_opt_do+=("$proj_dir")

    rsync "${rsync_opt_do[@]}"

    # check for errors
    if (( $? )); then 
      echo "$script_name: rsync: download failed."
      exit 1
    fi

    if (( clean )); then
      ssh_opt=("$remote" "-p $port" "rm -rf $remote_proj_dir")
      ssh ${ssh_opt[@]}
    fi
  fi

else
  # local execution

  # 'main.do' uses TCL_PROJ_DIR as the base directory for completing paths
  export TCL_PROJ_DIR="$proj_dir"
  # 'main.do' uses TCL_ARGS for completing vsim command
  export TCL_ARGS="$tcl_args"

  # call setmentor 
  eval "$mentor"

  # run QuestaSIM
  vsim -c -do "do $proj_dir/scripts/main.do"

  if (( $? )); then 
    echo "$script_name: vsim error."
    exit 1
  fi

fi

exit 0

