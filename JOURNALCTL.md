# JOURNALCTL CLI Tutorial

journalctl is the command-line utility for querying and viewing
logs collected by systemd's logging service (the systemd journal).
It provides a unified way to see logs from the kernel, system services,
and user processes, without having to hunt
through multiple log files in /var/log/.

Below is a practical guide to help you use journalctl effectively:

## 1. Checking System Logs

### Basic Usage

Simply run:

    journalctl

This outputs all available journal entries from oldest to newest.
Because it can be a large amount of text,
you might want to apply filters like time ranges,
service names, etc.

## 2. Common journalctl Options

### Follow (Real-Time Tail)

Similar to tail -f for a log file:

    journalctl -f

This displays new log entries in real time.

### Unit (Service) Logs

If you want to see logs for a specific systemd service,
for example nginx.service:

    journalctl -u nginx

Or for ssh.service:

    journalctl -u ssh

Tip: On many distributions,
the service name might be ssh.service or sshd.service.
You can tab-complete or list units
in /lib/systemd/system/ or /etc/systemd/system/.

Follow a Single Service
Combine -u with -f to follow real-time output:

    journalctl -u nginx -f

### Filtering by Time Range

You can filter logs to show entries after a certain date/time,
before a certain date/time, or a combination of both.

Since a date/time:

    journalctl --since "2023-03-01 00:00:00"

Until a date/time:

    journalctl --until "2023-03-02 12:00:00"

Both:

    journalctl --since "2023-03-01 00:00:00" --until "2023-03-01 23:59:59"

Relative times (e.g., “1 hour ago”):

    journalctl --since "1 hour ago"

### Limiting Number of Lines

If you just need the most recent logs (e.g., last 50 lines):

    journalctl -n 50

You can combine with other options, e.g.:

    journalctl -u nginx -n 50

### Priority/Severity Filtering

Logs have priorities ranging from 0 (emergency) to 7 (debug).
You can filter by priority:

Show only error messages and above (0 to 3):

    journalctl -p err

or the numeric equivalent:

    journalctl -p 3

Show only warning and above:

    journalctl -p warning

Show only critical:

    journalctl -p crit

The priority keywords are:

emerg (0)
alert (1)
crit (2)
err (3)
warning (4)
notice (5)
info (6)
debug (7)

### Output Formatting

journalctl supports various output formats via -o <FORMAT>, for example:

verbose (very detailed, raw metadata)
json or json-pretty (JSON output)

For example:

    journalctl -u nginx -o json-pretty

This can be useful for parsing logs programmatically.

## 3. Managing the Journal

### Persistent Storage of Logs

By default, some systems store logs only in memory
(they’re lost on reboot). To keep them persistent,
you can create a directory /var/log/journal,
then give it the right permissions:

    sudo mkdir -p /var/log/journal
    sudo systemd-tmpfiles --create --prefix /var/log/journal
    sudo systemctl restart systemd-journald

Systemd will automatically detect this directory and store logs persistently.

### Checking Current Journal Disk Usage

    journalctl --disk-usage

This shows how much disk space the journal logs are consuming.

### Limit or Clear Logs

You can configure maximum storage
in /etc/systemd/journald.conf using directives like:

```cong
[Journal]
SystemMaxUse=200M
Then restart systemd-journald:
```

    sudo systemctl restart systemd-journald

Alternatively, you can vacuum old logs.
For example, to shrink logs down to 500MB total:

    sudo journalctl --vacuum-size=500M

Or remove older entries than 2weeks:

    sudo journalctl --vacuum-time=2weeks 4. Examples Recap

View All Logs:

    journalctl

Follow Logs in Real Time:

    journalctl -f

Logs for a Specific Service:

    journalctl -u nginx

Follow a Specific Service:

    journalctl -u nginx -f

Most Recent 50 Lines:

    journalctl -n 50

Error and Above:

    journalctl -p err

Filter by Date/Time:

    journalctl --since "2023-03-01 10:00:00" --until "2023-03-01 12:00:00"

Vacuum Old Logs (limit to 500 MB):

    sudo journalctl --vacuum-size=500M 5. Putting It All Together

Start simple:

    journalctl -u <service> -f

is often your go-to for live troubleshooting.

Add filters for time or priority when investigating
specific time windows or error-only logs.
Set up persistent storage if you want to keep logs across reboots.
Clean up old logs via vacuum commands or journald config to avoid filling your disk.

Conclusion
journalctl is a powerful, unified logging tool
for systemd-based systems. By learning a few key filters
(-u, -f, --since, -p), you can quickly and effectively
find the logs you need for troubleshooting.
