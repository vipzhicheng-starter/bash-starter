#!/usr/bin/env bash

# -E 确保 trap 能够捕捉到任意信号
# -e 当命令失败立即退出
# -u 遇到未定义变量，报错并立即退出
# -o pipefail 确保正确返回错误码

set -Eeuo pipefail

# 捕捉信号，执行清理脚本
trap cleanup SIGINT SIGTERM ERR EXIT

# 确定当前脚本目录，并尝试切换到脚本所在目录
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

# 使用帮助
usage() {
  cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [-h] [-v] [-f] -p param_value arg1 [arg2...]
Script description here.
Available options:
-h, --help      Print this help and exit
-v, --verbose   Print script debug info
-f, --flag      Some flag description
-p, --param     Some param description
EOF
  exit
}

# 清理脚本
cleanup() {
  trap - SIGINT SIGTERM ERR EXIT
  # 在这里写清理脚本
}

# 设置颜色
setup_colors() {
  if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
    NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' YELLOW='\033[1;33m'
  else
    NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW=''
  fi
}

# 打印带颜色的消息
msg() {
  echo >&2 -e "${1-}"
}

# 退出脚本
die() {
  local msg=$1
  local code=${2-1} # default exit status 1
  msg "$msg"
  exit "$code"
}

# 解析选项和参数
parse_params() {
  # default values of variables set from params
  flag=0
  param=''

  while :; do
    case "${1-}" in
    -h | --help) usage ;;
    -v | --verbose) set -x ;;
    --no-color) NO_COLOR=1 ;;
    -f | --flag) flag=1 ;; # example flag
    -p | --param) # example named parameter
      param="${2-}"
      shift
      ;;
    -?*) die "Unknown option: $1" ;;
    *) break ;;
    esac
    shift
  done

  args=("$@")

  # 检查必填选项
  [[ -z "${param-}" ]] && die "Missing required parameter: param"
  # 检查是否输出参数
  [[ ${#args[@]} -eq 0 ]] && die "Missing script arguments"

  return 0
}

parse_params "$@"
setup_colors

# 在这里写脚本逻辑

msg "${RED}Read parameters:${NOFORMAT}"
msg "- flag: ${flag}"
msg "- param: ${param}"
msg "- arguments: ${args[*]-}"