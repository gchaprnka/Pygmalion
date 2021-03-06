all: run

run: venv conf.json
	export RPM_MODE=false; \
	venv/bin/python setup.py install
	venv/bin/pygmalion-server -c conf.json

conf.json:
	cp contrib/conf.json conf.json
	echo "Copied default conf.json from /contrib/conf.json. Feel free to edit it to your heart's content."

tables: venv
	venv/bin/python ./create-table-migration.py

venv: venv/bin/activate

venv/bin/activate: requirements.txt
	python3 -m venv venv
	venv/bin/pip install -Ur requirements.txt
	touch venv/bin/activate

clean:
	-rm -rf venv
	-find . -name \*.pyc -delete
	-find . -name __pycache__ -delete
	-rm -rf dist
	-rm *.rpm
	-rm -rf pygmalion.egg-info/
	-rm -rf build/

rpm: venv
	export RPM_MODE=true; \
	venv/bin/python setup.py bdist_rpm --release $(shell git rev-list $(shell git tag)..HEAD --count)

deps_rpm: venv
	venv/bin/python build-deps.py

venv/bin/crossbar: venv
	venv/bin/pip install crossbar
	venv/bin/crossbar init

crossbar: venv/bin/crossbar
	venv/bin/crossbar start
