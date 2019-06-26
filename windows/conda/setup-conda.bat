call pip install virtualenv
mkdir %conda%
copy .\* %conda%\
call virtualenv %conda%/conda-env
call %conda%\aconda.bat
pip install -r environment.txt
