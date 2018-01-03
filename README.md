# ansible.sh

A convenient shell system to utilize an ansible container for deployments.

## How to use

### Installation

The script is designed to be consumed by `bash` each time the shell is invoked. Thus, it should be sourced into your `~/.bashrc` script. The following steps will achieve this result.

```bash
mkdir -p ~/work
cd ~/work
git clone https://github.com/glyphrider/ansible.sh.git
echo 'source ~/work/ansible.sh/ansible.sh' >> ~/.bashrc
```

You will need to identify your ansible playbook location. If, for example, you have your playbook(s) in the directory `~/work/ansible_plays`, then you would configure this with the following:

```bash
echo 'ANSIBLE_PLAYBOOK=~/work/ansible_plays' > ~./ansible_playbook
```

If you don't configure your ansible playbook, then the script will attempt to do that the first time it runs. It will try to find a directory that is a git repository with a remote that matches `VHTx/ansible_deployment`. If you have such directory, then this value will be set for you automatically.

### Pre-Requisites

You must be running the `ssh-agent` and have the necessary keys loaded. Without this, ansible playbooks will not have reliable access the servers they create.

### Environments

You will need to configure some number of _environments_ for ansible. Create any number of files of the form ~/.ansible-key._environment-name_. These text files should contain a setting of the AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY variables, as well as an AWS_ACCOUNT_COLOR setting. An example file might be `~/.ansible-key.production` and contain the following:

```bash
AWS_ACCESS_KEY_ID="SOMELEGITIMATEACCESSID"
AWS_SECRET_ACCESS_KEY="SOMESUPERSECRETACCEESSKEY"
AWS_ACCOUNT_COLOR=red
```

## Get your shell on

Once all this is done, you will be ready to use the script.

Restart bash (`exec $SHELL`). If you are not using bash as your default shell, this won't work; however, you can use `SHELL=/bin/bash exec /bin/bash` to overcome your shell inadequacies.

## What just happened

A quick check of `alias` will show a new alias for each of your ~/.ansible-key._environment-name_ files. Each alias will match _environment-name_ and will setup ansible to use your new environment.

## Exciting Environment Variables that you can change while in the SHELL

`AWS_REGION` defaults to `us-east-1`, but you can set it at any time so your commands will execute in a different region.

`ANSISBLE_PLAYBOOK` defaults to the value in the ~/.ansible_playbook file. However, you can use it to point to an alternate playbook directory.

**You cannot use the cool shell shortcut to set the environment variables on the same commandline as `ansible-playbook`**

`AWS_REGION=us-east-2 ansible-playbook blah` **does not work**

This is because the environment variables are interpretted/expanded before they are reset. Shell magic.

```bash
AWS_REGION=us-east-2
ansible-playbook blah
```

This works.

## N.B.

The super obnoxious prompt is intensional; the British spelling of intentional is not.

## Getting Out

To stop using ansible, just `exit` the shell.
