#!/bin/bash

log_dir="/var/log/"
src_dir="/var/log/nginx/"
dst_dir="/var/log/archive/"
script_log="$log_dir/log_cleanup_activity.log"
threshold_days=7

if [ ! -d "$log_dir" ]; then
  echo "Error: Log directory '$log_dir' does not exist"
  exit 1
fi

touch "$script_log"

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$script_log"
}

log "Script has started"

if [ ! -d "$src_dir" ]; then
  log "Error: Source directory '$src_dir' does not exist"
  exit 1
fi

if [ ! -d "$dst_dir" ]; then
  log "$dst_dir does not exist"
  mkdir -p "$dst_dir"
  log "Created $dst_dir successfully"
fi

find "$src_dir" -type f -name "*.log" -mtime +$threshold_days -exec mv {} "$dst_dir" \;
log "Log files has been moved to $dst_dir"

log "Script has ended"