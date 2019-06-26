import sys
import os


SEP = '/'
HADOOP_ENV_PATH = 'etc/hadoop/hadoop-env.sh'
CORE_SITE_PATH = 'etc/hadoop/core-site.xml'
HDFS_SITE_PATH = 'etc/hadoop/hdfs-site.xml'
MODULE_PATH = '/hadoop/psudo_distributed/files'


def configHadoopEnv(hadoop_path, java_path):
	with open(hadoop_path + SEP + HADOOP_ENV_PATH, 'a') as f:
		f.write('export JAVA_HOME="{}"'.format(java_path))
	return 0


def configHadoopCoreSite(hadoop_path):
	with open(hadoop_path + SEP + CORE_SITE_PATH, 'w') as t:
		with open(MODULE_PATH+SEP+'core-site.xml', 'r') as s:
			for l in s:
				t.write(l)
	return 0


def configHadoopHdfsSite(hadoop_path):
	with open(hadoop_path + SEP + HDFS_SITE_PATH, 'w') as t:
		with open(MODULE_PATH+SEP+'hdfs-site.xml', 'r') as s:
			for l in s:
				t.write(l)
	return 0


if __name__ == '__main__':
	program_name = sys.argv[0]
	arguments = sys.argv[1:]
	if len(arguments) < 3:
		raise Exception('Insuficient arguments, 3 arguments required')
	MODULE_PATH = arguments[0].rstrip(SEP) + MODULE_PATH
	hadoop_path = arguments[1].rstrip(SEP)
	java_path = arguments[2].rstrip(SEP)
	configHadoopEnv(hadoop_path, java_path)
	configHadoopCoreSite(hadoop_path)
	configHadoopHdfsSite(hadoop_path)
