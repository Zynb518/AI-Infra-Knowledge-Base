#!/usr/bin/env bash
set -u
set -o pipefail

check_log_path() {
  if [ "$#" -eq 0 ]; then
    printf '至少需要提供一个路径参数\n' >&2
    exit 1
  fi
  if [ ! -f "$1" ]; then
    printf '参数1不是合法的日志路径\n' >&2
    exit 2
  fi

}

main() {
  check_log_path "$@"
  # tr -s '\n' 只能处理\n
  # grep -v '^[[:space:]]*$' file.txt 可以去除空行
  log_content=$(grep -v '^[[:space:]]*$' "$1")

  log_count=$(printf '%s\n' "$log_content" | wc -l)
  log_service=$(printf '%s' "$log_content" | cut -d ',' -f 2 | sort | uniq -c)
  log_status=$(printf '%s' "$log_content" | cut -d ',' -f 4 | sort | uniq -c)
  log_error=$(printf '%s' "$log_content" | cut -d ',' -f 3 | grep -i 'error' | sort | uniq -c)

  printf 'log_count=%s\n' "$log_count" | tee /tmp/log-analysis.txt
  printf 'log_service:\n%s\n' "$log_service" | tee -a /tmp/log-analysis.txt
  printf 'log_status:\n%s\n' "$log_status" | tee -a /tmp/log-analysis.txt
  printf 'log_error:\n%s\n' "$log_error" | tee -a /tmp/log-analysis.txt
  
}

main "$@"

# 待改进：
# 1. 当日志过滤后只剩空内容时，log_count 可能把空内容统计为 1。
# 2. 当前只检查至少存在一个参数，多余参数会被静默忽略。
