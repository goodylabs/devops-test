# Task for a junior DevOps candidate 

## Time: max 1 hour

Create a Bash script named `log_cleanup.sh` that does the following:

1. It searches for log files (*.log) older than 7 days in a specified directory `/var/log/nginx/`.
2. It moves these older log files to an archive directory `/var/log/archive/`.
3. Ensure the script logs its activities in a separate log file located at `/var/log/log_cleanup_activity.log`.
4. Make sure the script is executable and handles scenarios like empty directories or absence of log files.
