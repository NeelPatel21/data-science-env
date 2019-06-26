call pip install --user virtualenv
mkdir %conda%
copy .\* %conda%\
call python -m virtualenv %conda%/conda-env
call %conda%\aconda.bat
pip install -r environment.txt
