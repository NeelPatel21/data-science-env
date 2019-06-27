import sys
import os

os.environ['DEBUSSY'] = '1'
os.environ['FSDB'] = '1'

SEP = '/'
env = {
'HADOOP_ENV_PATH': 'etc/hadoop/hadoop-env.sh',
'CORE_SITE_PATH': 'etc/hadoop/core-site.xml',
'HDFS_SITE_PATH': 'etc/hadoop/hdfs-site.xml',
'FILES_PATH': 'hadoop/psudo_distributed/files'
}


def configHadoopEnv():
	with open(env['HADOOP_HOME'] + SEP + env['HADOOP_ENV_PATH'], 'a') as f:
		f.write('export JAVA_HOME="{}"'.format(env['JAVA_HOME']))
	return 0


def configHadoopCoreSite():
	with open(env['HADOOP_HOME'] + SEP + env['CORE_SITE_PATH'], 'w') as t:
		with open(env['MODULE_PATH'] + SEP + env['FILES_PATH'] + SEP + 'core-site.xml', 'r') as s:
			for l in s:
				t.write(l.format(**env))
	return 0


def configHadoopHdfsSite():
	with open(env['HADOOP_HOME'] + SEP + env['HDFS_SITE_PATH'], 'w') as t:
		with open(env['MODULE_PATH'] + SEP + env['FILES_PATH'] + SEP + 'hdfs-site.xml', 'r') as s:
			for l in s:
				t.write(l.format(**env))
	return 0


if __name__ == '__main__':
	program_name = sys.argv[0]
	arguments = sys.argv[1:]
	env['MODULE_PATH'] = os.environ['MODULE_PATH'].rstrip(SEP)
	env['HADOOP_HOME'] = os.environ['HADOOP_HOME'].rstrip(SEP)
	env['HADOOP_STORAGE'] = os.environ['HADOOP_STORAGE'].rstrip(SEP)
	env['JAVA_HOME'] = os.environ['JAVA_HOME'].rstrip(SEP)
	configHadoopEnv()
	configHadoopCoreSite()
	configHadoopHdfsSite()
