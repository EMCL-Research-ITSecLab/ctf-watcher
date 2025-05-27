#!/bin/bash

GLOBAL_BASHRC="/etc/bash.bashrc"
CONTAINER_NAME="${ENV_CONTAINER_NAME}"
PATH_BASH_CONF="/etc/rsyslog.d/bash.conf"
LOG_DESTINATION="local6.* /var/log/commands.log"
PRIVAT_LOG=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --privat_log=*)
      PRIVAT_LOG="${1#*=}"
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
  shift
done

if [ -z "$CONTAINER_NAME" ]; then CONTAINER_NAME=$(hostname); fi

COMMAND_LOG_BASH="
# log last bash command to local6.debug which is located in /var/log/commands.log
export PROMPT_COMMAND='RETRN_VAL=\$?;logger -t bash_commands -p local6.debug \"Container $CONTAINER_NAME User \$(whoami) @ \$(pwd) [$$]: \$(history 1 | sed \"s/^[ ]*[0-9]\+[ ]*//\" )\"'
"

# Check if the GLOBAL_BASHRC file exists
if [ -e "$GLOBAL_BASHRC" ]; then
  :
else
  echo -e "\033[31m[ERROR]:\033[0m $CONTAINER_NAME: Bash logging set up \033[31m[FAILURE]\033[0m. Bashrc not found in $GLOBAL_BASHRC. Please enter the correct path in 'WazuhDocker/config/bash_loggin_set_up.sh'"
  exit 0
fi

# Append the command to the GLOBAL_BASHRC file
echo "$COMMAND_LOG_BASH" >> "$GLOBAL_BASHRC"

source "$GLOBAL_BASHRC"

echo "$LOG_DESTINATION" >> "$PATH_BASH_CONF"

if [ -n "$PRIVAT_LOG" ]; then
  echo "local6.* $PRIVAT_LOG" >> "$PATH_BASH_CONF"
fi

systemctl restart rsyslog

echo -e "\e[34m[Info]:\e[0m $CONTAINER_NAME: Bash logging set up \033[32m[SUCCESS]\033[0m"


