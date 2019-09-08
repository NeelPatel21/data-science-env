#!/bin/bash

function createConfig(){
	# args: $1:config path
	echo "INFO: Creating directory $2 with environment script.."
	mkdir -p $1

	echo "#!/bin/bash" > $1/git-env
	echo "alias gd=\"git diff\"" >> $1/git-env
	echo "alias gs=\"git status\"" >> $1/git-env
	echo "alias ga=\"git add\"" >> $1/git-env
	echo "alias gc=\"git commit\"" >> $1/git-env
	echo "alias gf=\"git pull\"" >> $1/git-env
	echo "alias gp=\"git push\"" >> $1/git-env
	echo "INFO: environment file created."
}

function updateBashrc(){
	# args: $1:config path
	config_path="$1/git-env"
	if eval "grep \"^source $config_path$\" $HOME/.bashrc" > /dev/null; then
		echo "INFO: \"source $config_path\" is already present in bashrc."
		return 1
	else
	    echo "INFO: Inserting \"source $config_path\" into bashrc."
		echo "# Git Environment Configuration." >> $HOME/.bashrc
		echo "source $config_path" >> $HOME/.bashrc
		return 1
	fi
}

function start(){	
	config_path="$HOME/config"
	
	echo "PROMPT: Do you want to create conifg file with alias and environment variables."
	read var
	if [[ $var == "y" ]]; then
		createConfig $config_path
		updateBashrc $config_path
	fi
}

start
