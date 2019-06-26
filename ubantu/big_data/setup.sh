function updateBashrc(){
	export x="$1"
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
	tar -xvzf "$1/spark/spark-2.4.3-bin-hadoop2.7.tgz"  -C "$1/spark/" && echo "INFO: spark extracted successfully."
	export SPARK_HOME="$1/spark/spark-2.4.3-bin-hadoop2.7"
	updateBashrc SPARK_HOME
}

function downloadHadoop(){
	echo "INFO: Installing Hadoop."
	#read -s “Specify hadoop home (directory will be created if not exist): ” var
	mkdir -p "$1/hadoop/"
	#wget  -P "$1/hadoop/" "http://mirrors.estointernet.in/apache/hadoop/common/hadoop-2.9.2/hadoop-2.9.2.tar.gz"
	echo "INFO: Hadoop downloaded."  
	tar -xvzf "$1/hadoop/hadoop-2.9.2.tar.gz" -C "$1/hadoop/" && echo "INFO: hadoop extracted successfully."
	export HADOOP_HOME="$1/hadoop/hadoop-2.9.2"
	updateBashrc HADOOP_HOME
}

function psudoDistributedHadoop(){
	echo "INFO: Configuring Hadoop in psudo-distributed mode."
	echo "$HADOOP_HOME $JAVA_HOME"
	python3 ./hadoop/psudo_distributed/psudo_distributed.py "$script_root" "$HADOOP_HOME" "$JAVA_HOME"
	eval "$HADOOP_HOME/bin/hdfs namenode -format" >> logs.txt
	eval "$HADOOP_HOME/sbin/start-all.sh" >> logs.txt
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
	echo “Specify directory for hadoop and spark \(directory will be created if not exist\): ”
	read var
	if [[ $1 == "all" ]] || [[ $1 == "hadoop" ]]; then
		downloadHadoop $var || echo "ERROR: Hadoop download failed"
		psudoDistributedHadoop
	fi
	if [[ $1 == "all" ]] || [[ $1 == "spark" ]]; then
		downloadSpark $var || echo "ERROR: Spark download failed"
	fi
	return 0
}

function exportPath(){
	export script_root=$(pwd)
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