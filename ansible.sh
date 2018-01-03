#!/bin/bash

ANSIBLE_PLAYBOOK_REPO_PATTERN="VHTx/ansible_deployment"
ANSIBLE_DOCKER_IMAGE_TAG="virtualhold/ansible"

function aws_common {
  # export relevant environment variables
  export AWS_ACCESS_KEY_ID
  export AWS_SECRET_ACCESS_KEY
  export AWS_REGION=${AWS_REGION:-us-east-1}

  # setup a wicked-cool prompt
  PS1="$(prompt_effect ${1}_bg)$(prompt_effect black)\t($(date +%Z)) | aws:$(prompt_effect bold)${AWS_ACCOUNT}$(prompt_effect unbold)@\${AWS_REGION} | \h:\w$(prompt_effect default_bg)$(prompt_effect default)\n[\\!]\\$ "

  # add the ansible-playbook alias that uses all the environment variables
  alias ansible-playbook='docker run -ti --rm -v /etc/passwd:/etc/passwd -v /etc/group:/etc/group --user $(id -u):$(id -g) -v ${SSH_AUTH_SOCK}:${SSH_AUTH_SOCK} -e SSH_AUTH_SOCK=${SSH_AUTH_SOCK} -v ${ANSIBLE_PLAYBOOK}:/playbook -w /playbook -e HOME=/tmp -e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} -e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} -e AWS_REGION=${AWS_REGION} ${ANSIBLE_DOCKER_IMAGE_TAG}'
  which notify-send >> /dev/null && [[ -n "${DISPLAY}" ]] && notify-send --urgency=low --icon=terminal ${AWS_ACCOUNT} "ansible-playbook alias is ready"
}

function prompt_effect {
  case $1 in
    black)
      echo -n "\e[30m"
      ;;
    red)
      echo -n "\e[31m"
      ;;
    green)
      echo -n "\e[32m"
      ;;
    blue)
      echo -n "\e[34m"
      ;;
    red_bg)
      echo -n "\e[41m"
      ;;
    green_bg)
      echo -n "\e[42m"
      ;;
    blue_bg)
      echo -n "\e[44m"
      ;;
    bold)
      echo -n "\e[1m"
      ;;
    unbold)
      echo -n "\e[21m"
      ;;
    default)
      echo -n "\e[39m"
      ;;
    default_bg)
      echo -n "\e[49m"
      ;;
    *)
      ;;
  esac
}

function create_alias {
  alias ${1}="AWS_ACCOUNT=${1} \${SHELL}"
}

if [ "${AWS_ACCOUNT}" -a -f ~/.ansible-key.${AWS_ACCOUNT} ]; then
  source ~/.ansible-key.${AWS_ACCOUNT}
  aws_common ${AWS_ACCOUNT_COLOR}
else
  # create aliases
  for keyfile in ~/.ansible-key.*; do
    create_alias ${keyfile##*.ansible-key.}
  done
  # clear these guys
  unset AWS_ACCESS_KEY_ID
  unset AWS_SECRET_ACCESS_KEY
fi

if [ -z "${ANSIBLE_PLAYBOOK}" ]; then
  if [ -f ~/.ansible_playbook ]; then
    source ~/.ansible_playbook
  else
    # this is a one-time thing
    # you can avoid this by creating your own ~/.ansible_playbook file with the appropriate shell command(s)
    echo "Finding your ANSIBLE_PLAYBOOK...."
    ANSIBLE_PLAYBOOK=$(find ~ -type d -exec grep -q ${ANSIBLE_PLAYBOOK_REPO_PATTERN} {}/.git/config 2> /dev/null \; -print)
    export ANSIBLE_PLAYBOOK
    echo -e "$(prompt_effect red)Using ANSIBLE_PLAYBOOK=${ANSIBLE_PLAYBOOK}$(prompt_effect default)"
    echo "Persisting to ~/.ansible_playbook"
    # this is what creates the file
    echo "export ANSIBLE_PLAYBOOK=${ANSIBLE_PLAYBOOK}" > ~/.ansible_playbook
  fi
fi
