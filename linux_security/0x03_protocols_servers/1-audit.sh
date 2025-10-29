#!/bin/bash
grep -vE '^#|^$|^Port|^Protocol|^HostKey|^SyslogFacility|^LogLevel|^PermitEmptyPasswords|^ChallengeResponseAuthentication' /etc/ssh/sshd_config
