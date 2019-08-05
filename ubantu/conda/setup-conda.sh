#!/bin/bash
function setupPip(){
	if ! pip3 --version &>>/dev/null; then
		echo "INFO: pip3 not found. installing pip3..."
		if sudo apt install python3-pip &>> logs.txt; then
			echo "INFO: pip3 installed."
			return 1
		else
			echo "ERROR: error while installing pip3"
			return 0
		fi
	else
		echo "INFO: pip3 is already installed"
		return 1
	fi
}

function createConfig(){
	# args: $1:conda path
	# args: $2:config path
	echo "INFO: Creating directory $2 with environment script.."
	mkdir -p $2

	echo "#!/bin/bash" > $2/conda-env
	echo "export conda=\"$1\"" >> $2/conda-env
	echo "alias aconda=\"source $conda/conda-env/bin/activate\"" >> $2/conda-env
	echo "alias slab=\"aconda && python3 -m jupyter lab\"" >> $2/conda-env
	echo "INFO: environment file created."
}

function updateBashrc(){
	# args: $1:config path
	config_path="$1/conda-env"
	if eval "grep \"^source $config_path$\" $HOME/.bashrc" > /dev/null; then
		echo "INFO: \"source $config_path\" is already present in bashrc."
		return 1
	else
	    echo "INFO: Inserting \"source $config_path\" into bashrc."
		echo "source $config_path" >> $HOME/.bashrc
		return 1
	fi
}

function setupEnv(){
	# args: $1:conda path
	echo "INFO: installing virtualenv."
	pip3 install virtualenv
	echo "INFO: creating virtual environment."
	python3 -m virtualenv $1/conda-env
	source $1/conda-env/bin/activate
	pip3 install -r environment.txt
	deactivate
	echo "INFO: virtual environment created."
	return 1
}

function start(){
	setupPip
	
	root_path="$HOME/conda"
	config_path="$HOME/config"
	
	echo "PROMPT: Do you want to continue with default path ($root_path) for conda environment: (y or n)"
	read var
	#echo "--$var--"
	if [[ $var != "y" ]]; then
		echo "Specify directory for Conda \(directory will be created if not exist.\):" 
		read root_path
	fi
	setupEnv $root_path
	
	echo "PROMPT: Do you want to create conifg file with alias and environment variables."
	read var
	if [[ $var == "y" ]]; then
		createConfig $root_path $config_path
		updateBashrc $config_path
	fi
}

start