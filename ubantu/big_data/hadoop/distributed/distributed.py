import sys
import os

os.environ['DEBUSSY'] = '1'
os.environ['FSDB'] = '1'

SEP = '/'
env = {
'HADOOP_ENV_PATH': 'etc/hadoop/hadoop-env.sh',
'CORE_SITE_PATH': 'etc/hadoop/core-site.xml',
'HDFS_SITE_PATH': 'etc/hadoop/hdfs-site.xml',
'MAPRED_PATH': 'etc/hadoop/mapred-site.xml',
'YARN_SITE': 'etc/hadoop/yarn-site.xml',
'HADOOP_SLAVE_PATH': 'etc/hadoop/slaves',
'FILES_PATH': 'hadoop/distributed/files'
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


def configHadoopMepredSite():
	with open(env['HADOOP_HOME'] + SEP + env['MAPRED_PATH'], 'w') as t:
		with open(env['MODULE_PATH'] + SEP + env['FILES_PATH'] + SEP + 'mapred-site.xml', 'r') as s:
			for l in s:
				t.write(l.format(**env))
	return 0


def configHadoopYarnSite():
	with open(env['HADOOP_HOME'] + SEP + env['YARN_SITE'], 'w') as t:
		with open(env['MODULE_PATH'] + SEP + env['FILES_PATH'] + SEP + 'yarn-site.xml', 'r') as s:
			for l in s:
				t.write(l.format(**env))
	return 0


def configHadoopSlave():
	with open(env['HADOOP_HOME'] + SEP + env['HADOOP_SLAVE_PATH'], 'w') as t:
		print('slave dir {}'.format(env['HADOOP_HOME'] + SEP + env['HADOOP_SLAVE_PATH']))
		for l in env['HADOOP_SLAVES'].split(','):
			t.write('{}\n'.format(l.strip()))
	return 0


if __name__ == '__main__':
	program_name = sys.argv[0]
	arguments = sys.argv[1:]
	env['MODULE_PATH'] = os.environ['MODULE_PATH'].rstrip(SEP)
	env['HADOOP_SLAVES'] = os.environ['HADOOP_SLAVE']
	env['SLAVES_NUM'] = len(env['HADOOP_SLAVES'].split(','))
	env['HADOOP_HOME'] = os.environ['HADOOP_HOME'].rstrip(SEP)
	env['HADOOP_STORAGE'] = os.environ['HADOOP_STORAGE'].rstrip(SEP)
	env['JAVA_HOME'] = os.environ['JAVA_HOME'].rstrip(SEP)
	print('env: {}'.format(env))
	configHadoopEnv()
	configHadoopCoreSite()
	configHadoopHdfsSite()
	configHadoopMepredSite()
	configHadoopYarnSite()
	configHadoopSlave()
