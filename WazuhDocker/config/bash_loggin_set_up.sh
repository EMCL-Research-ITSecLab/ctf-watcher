#!/bin/bash

GLOBAL_BASHRC="/etc/bash.bashrc"
COMMAND_LOG_BASH="
# log last bash command to local6.debug which is located in /var/log/commands.log
export PROMPT_COMMAND='RETRN_VAL=\$?;logger -t bash_commands -p local6.debug \"User \$(whoami) @ \$(pwd) [$$]: \$(history 1 | sed \"s/^[ ]*[0-9]\+[ ]*//\" )\"'
"
PATH_BASH_CONF="/etc/rsyslog.d/bash.conf"
LOG_DESTINATION="local6.* /var/log/commands.log"

# Check if the GLOBAL_BASHRC file exists
if [ -e "$GLOBAL_BASHRC" ]; then
  echo -e "[INFO]: Global BASHRC script found"
else
  echo -e "\033[31m[ERROR]:\033[0m Global BASHRC script not found in $GLOBAL_BASHRC. Please enter the correct path in 'WazuhDocker/config/bash_loggin_set_up.sh'"
  exit 0
fi

# Append the command to the GLOBAL_BASHRC file
echo "$COMMAND_LOG_BASH" >> "$GLOBAL_BASHRC"

source /etc/bashrc

echo "$LOG_DESTINATION" >> "$PATH_BASH_CONF"

systemctl restart rsyslog
