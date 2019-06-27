function updateBashrc(){
	export x="$1"
	echo "INFO: Updating bashrc, adding $1=\"${!x}\""
	echo "export $1=\"${!x}\"" >> $HOME/.bashrc
}

function setupJava(){
	if ! javac -version &>>/dev/null; then
		echo "INFO: Java not found."
		echo "INFO: Installing Java 8"
		sudo apt install -y openjdk-8-jdk-headless >> logs.txt
		updateBashrc JAVA_HOME
	else
		echo "INFO: Java 8 is already installed"
	fi
	export JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64"	
}

function setupSsh(){
	echo "INFO: installing openssh client and server"
	sudo apt install -y openssh-client=1:7.6p1-4 >> logs.txt
	sudo apt install -y openssh-server >> logs.txt
	echo "INFO: openssh client and server is installed"
	echo "INFO: configuring key based authentication"
	ssh-keygen -t rsa -P "" -f $HOME/.ssh/id_rsa
	ssh-copy-id -i $HOME/.ssh/id_rsa.pub localhost || cat $HOME/.ssh/id_rsa.pub >> $HOME/.ssh/authorized_keys
}

function setupScala(){
	if ! scala -version &>/dev/null; then
		#sudo apt install scala >> logs.txt
		echo "INFO: Scala not found."
		echo "INFO: Downloading Scala 2.12.2"
		curl -O "https://downloads.lightbend.com/scala/2.12.2/scala-2.12.2.deb"
		echo "INFO: Installing Scala 2.12.2"
		sudo dpkg -i scala-2.12.2.deb >> logs.txt
		rm -rf scala-2.12.2.deb
		echo "INFO: Scala 2.12.2 Installed"
	else
		echo "INFO: Scala is already installed"
	fi
}

function setupPython3(){
	if ! python3 --version &>/dev/null; then
		echo "INFO: Python3 not found."
		echo "INFO: Installing Python3"
		sudo apt install -y python3 >> logs.txt
	else
		echo "INFO: Python3 is already installed"
	fi
}

function downloadSpark(){
	echo "INFO: Installing Spark."
	mkdir -p "$1/spark/"
	wget -P "$1/spark/" "http://mirrors.estointernet.in/apache/spark/spark-2.4.3/spark-2.4.3-bin-hadoop2.7.tgz"
	echo "INFO: Spark downloaded"
	tar -xzf "$1/spark/spark-2.4.3-bin-hadoop2.7.tgz"  -C "$1/spark/" && echo "INFO: spark extracted successfully."
	export SPARK_HOME="$1/spark/spark-2.4.3-bin-hadoop2.7"
	updateBashrc SPARK_HOME
}

function downloadHadoop(){
	echo "INFO: Installing Hadoop."
	mkdir -p "$1/hadoop/"
	if [ -f $1/hadoop/hadoop-2.9.2.tar.gz ]; then
		echo "INFO: Hadoop binary tar exist, using existing tar"
	else
		echo "INFO: Downloading Hadoop 2.9.2"
		if wget -P "$1/hadoop/" "http://mirrors.estointernet.in/apache/hadoop/common/hadoop-2.9.2/hadoop-2.9.2.tar.gz"; then
			echo "INFO: Hadoop downloaded." 
		else
			echo "ERROR: Error while Downloading Hadoop."
			return 0
		fi
	fi
	echo "INFO: Extracting Hadoop."
	if tar -xzf "$1/hadoop/hadoop-2.9.2.tar.gz" -C "$1/hadoop/" &>> logs.txt; then
		echo "INFO: hadoop extracted successfully."
	else
		echo "ERROR: Error while Extracting Hadoop."
	fi
	export HADOOP_HOME="$1/hadoop/hadoop-2.9.2"
}

function psudoDistributedHadoop(){
	if ! downloadHadoop $root_path; then
		echo "ERROR: Hadoop download failed"
		return 0
	fi
	
	updateBashrc HADOOP_HOME

	echo "INFO: Configuring Hadoop in psudo-distributed mode."
	# check if environment variables configured
	export HADOOP_STORAGE="$1/hadoop/hdfs"
	export MODULE_PATH="$SCRIPT_ROOT"
	if python3 ./hadoop/psudo_distributed/psudo_distributed.py &>> logs.txt; then
		echo "INFO: Hadoop in psudo-distributed mode configured."
	else
		echo "ERROR: Error while configuring Hadoop in psudo-distributed mode."
		return 0
	fi

	echo "INFO: Formating name node."
	if eval "$HADOOP_HOME/bin/hdfs namenode -format" &>> logs.txt; then
		echo "INFO: Name node formated."
	else
		echo "ERROR: Error while formating name node."
		return 0
	fi
	
	echo "INFO: starting all processes."
	if ! eval "$HADOOP_HOME/sbin/start-all.sh" &>> logs.txt; then
		echo "ERROR: Error while staring all hadoop processed."
		return 0
	fi
	echo "INFO: checking java processes"
	jps
}

function setupEnvironment(){
	if [[ $1 == "all" ]] || [[ $1 == "java" ]]; then
		setupJava
	fi
	if [[ $1 == "all" ]] || [[ $1 == "scala" ]]; then
		setupScala
	fi
	if [[ $1 == "all" ]] || [[ $1 == "python3" ]]; then
		setupPython3
	fi
}

function setupHadoopSpark(){
	root_path="$HOME/bigdata"
	echo "PROMPT: Do you want to continue with default path ($root_path) for hadoop & spark: (y or n)"
	read var
	#echo "--$var--"
	if [[ $var != "y" ]]; then
		echo Specify directory for hadoop and spark \(directory will be created if not exist.\): 
		read root_path
	fi
	if [[ $1 == "all" ]] || [[ $1 == "hadoop" ]]; then
		psudoDistributedHadoop $root_path
	fi
	if [[ $1 == "all" ]] || [[ $1 == "spark" ]]; then
		downloadSpark $var || echo "ERROR: Spark download failed"
	fi
	return 0
}

function exportPath(){
	export SCRIPT_ROOT=$(pwd)
}

function start(){
	exportPath
	if [[ $# -eq 0 ]]; then
			setupEnvironment "all"
		setupHadoopSpark "all"
		return 1
	fi
	
	for i in "$@"; do
  		if [[ $i == "java" ]] || [[ $i == "scala" ]] || [[ $i == "python3" ]]; then
  			setupEnvironment $i
  		fi
	done
	
	for i in "$@"; do
  		if [[ $i == "hadoop" ]] || [[ $i == "spark" ]]; then
  			setupHadoopSpark $i
  		fi
	done
	
	for i in "$@"; do
  		if [[ $i == "ssh" ]]; then
  			setupSsh $i
  		fi
	done
}

start $*