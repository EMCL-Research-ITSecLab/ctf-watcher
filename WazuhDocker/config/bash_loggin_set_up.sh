#!/bin/bash

GLOBAL_BASHRC: "/etc/bash.bashrc"
COMMAND_LOG_BASH: "
# log last bash command to local6.debug which is located in /var/log/commands.log
export PROMPT_COMMAND='RETRN_VAL=$?;logger -t bash_commands -p local6.debug "User $(whoami) @ $(pwd) [$$]: $(history 1 | sed "s/^[ ]*[0–9]\+[ ]*//" )"'
"

if [ -e $(GLOBAL_BASHRC) ]; then
 echo -e "\033[31mThis is red text\033[0m"
else
  echo -e "\033[31m[ERROR]:\033[0m Gloabal BASHRC script not found in $(GLOBAL_BASHRC). Please enter the correct path in 'WazuhDocker/config/bash_loggin_set_up.sh'"
  exit 0
fi

echo COMMAND_LOG_BASH >> Global_BASHRC
