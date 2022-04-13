## Syslog in Linux

### syslogd daemon
Captures system events and logs them in Syslog. Uses Port _TCP 514_

Projects:
  - syslog - year 1980
  - syslog-ng - year 1998
  - rsyslog - year 2004


The daemon can be started, stopped, restarted etc.:
  - Status: `$ service syslog status` or `$ service rsyslog status`
  - Restart: `$ service rsyslog restart`
  - ...
  - Check syslog version: `$ ps -ef | grep syslog`

### Configuration file
- `/etc/syslog.conf` for syslog
- `/etc/syslog-ng.conf` for syslog-ng
- `/etc/rsyslog.conf` for rsyslog

Rules in this file consists of 2 fields separated by one or more spaces/tabs, a selector field and an action field.

One rule can be divided into through several lines with (`\`).

Empty lines and lines starting with (`#`) are ignored.

The services and their priorities that have to be logged are written in the first column, the selector field. In the actions field, the second column, are usually written the destinations where logs must be saved.

Ex:
```
*.info;mail.none;authpriv.none;cron.none      /var/log/messages
```

### Selectors
The selector field contains facilities (aka services) and priorities, separated by a period (`.`). Ex: `kern.info`. One line can contain more selectors separated by a semicolon (`;`). Ex: `kern.info;mail.*`. Multiple facilities with the same priority pattern can be specified using a comma (`,`). Ex: `auth,mail,cron.debug`

#### Facilities (messages)
- `auth` - security/authorization
- `authpriv` - security/authorization private
- `cron` - clock daemon (`cron` and `at`)
- `daemon` - system daemons without separate facility value
- `kern` - kernel
- `local0` through `local7` - local use
- `local7` - boot
- `lpr` - line printer subsystem
- `mail` - mail subsystem
- `news` - news subsystem
- `syslog` - messages generated internally by syslogd
- `user` - generic user-level
- `uucp` - UUCP subsystem

#### Priorities
In ascending level of urgency:
1. debug
2. info
3. notice
4. warning
5. err
6. crit
7. alert
8. emerg
9. \* - all level messages
10. none - no messages to be logged

The `syslogd` has a syntax extension to the original BSD source. That means, that every priority can be preceded with an equation sign (`=`) to specify only this one single priority and not any of the above. The preceded exclamation mark sign (`!`), will make the priority and all the above it to be ignored, i.e extract the priority and any higher. Used both (`!=`), means extract only this priority.

### Actions/Destinations:
Describes the abstract term "logfile", which has to actually be a real file of following types:

#### Regular file
Real local files, specified with a full path starting with a slash (`/`). It is possible to prefix each entry with a dash (`-`) to omit syncing the file after logging, with the risk to lose information on a system crash at the write attempt and gaining some performance.
Ex.:
```
*.info              /var/log/messages
cron.*              -/var/log/cron.log
```

#### Named Pipes
Logging output to named pipes (fifos) which can be used as a destination for log messages by prepending a pipe symbol ('|') to the name of the file. The fifo must be created by `mkfifo` command before the syslog service is started.

#### Terminal and Console
Specify the tty. The special tty handling will be done, same with /dev/console.

#### Remote Machine
The messages can be forwarded to a remote syslog server, which will store them locally. The remote server can be specified by IP or a hostname preceded by `@` sign.
Ex:
```
# redirect all messages to server with hostname `syslogserver`
*.*                 @syslogserver
```

#### List of Users
It is possible to specify the list of users that shall get the messages by writing the login and separating them with comma (`,`). Users will get the messages only if they are logged in.
Ex:
````
# messages of the priority `alert` will be directed to logged in users root, admin or me
*.alert             root,admin,me
````

#### Everyone logged on
Emergency messages often must go to all users currently online. This so called `wall` features is specified using asterisk (`*`)
Ex:
```
# Display emergency messages using wall
*.=emerg            *
```
### Examples
The line:

```
*.info;mail.none;authpriv.none;cron.none      /var/log/messages
```

means that in the `/var/log/messages` should be logged all the messages at the `info` level except any message from `mail`, `authpriv` and `cron`.

In rhlx11:/etc/rsyslog.conf
```
$ModLoad imuxsock         # provides support for local system logging
$ModLoad imklog           # provides kernel logging support
$ActionFileDefaultTemplate RSYSLOG_TraditionalFileFormat
$FileOwner root
$FileGroup root
$FileCreateMode            0640
$DirCreateMode             0755
$Umask 0022
$WorkDirectory             /var/spool/rsyslog
$IncludeConfig              /etc/rsyslog.d/*.conf

auth,authpriv.*            /var/log/auth.log
*.*;auth,authpriv.none     -/var/log/syslog
daemon.*                   -/var/log/daemon.log
kern.*                     -/var/log/kern.log
lpr.*                      -/var/log/lpr.log
mail.*                     -/var/log/mail.log
user.*                     -/var/log/user.log

mail.info                  -/var/log/mail.info
mail.warn                  -/var/log/mail.warn
mail.err                   /var/log/mail.err

news.crit                  /var/log/news/news.crit
news.err                   /var/log/news/news.err
news.notice                -/var/log/news/news.notice

*.=debug;\
	auth,authpriv.none;\
	news.none;mail.none      -/var/log/debug
```
