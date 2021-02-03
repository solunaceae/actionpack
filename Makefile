SYSTEM_PYTHON = $(shell which python3)
PROJECT_NAME = $(shell basename $(CURDIR))
VENV = $(PROJECT_NAME)-venv
VENV_PYTHON = $(VENV)/bin/python
TESTDIR = tests


all: venv install

.PHONY: build # builds a distributable artifact
build: $(VENV) $(VENV_PYTHON)
	@$(VENV_PYTHON) setup.py bdist_wheel

.PHONY: clean # deletes build residues, virtual environment, and python metafiles
clean: clean-build clean-venv clean-pyc

.PHONY: clean-build # deletes all build residues
clean-build:
	@rm -rf build
	@rm -rf dist

.PHONY: clean-pyc # deletes python metafiles
clean-pyc:
	@find . -name '*.pyc' -exec rm -f {} +
	@find . -name '*.pyo' -exec rm -f {} +
	@find . -name '*~' -exec rm -f {} +
	@find . -name '__pycache__' -exec rm -fr {} +

.PHONY: clean-venv # deletes virtualenv
clean-venv:
	@rm -rf $(VENV)

.PHONY: commands # lists all Makefile commands
commands:
	@echo
	@tput bold setaf 2; echo $(shell basename $(CURDIR)); echo
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$' | sed 's/^/  ->  /'
	@tput sgr0
	@echo

.PHONY: git-tag
git-tag:
	@echo $(shell git describe --tags)

.PHONY: install # installs project and dep to virtual environment
install: build $(VENV) $(VENV_PYTHON) clean-build
	@$(VENV_PYTHON) -m pip install -e .

.PHONY: reinstall # uninstall then install
reinstall: uninstall install

.PHONY: release # uploads package to pypi
release:
	$(error Not yet implemented)

.PHONY: tests # runs all tests
tests: $(VENV_PYTHON)
	@$(VENV_PYTHON) -m unittest $(TESTDIR).$(PROJECT_NAME)$(if $(TESTCASE),.$(TESTCASE),)

.PHONY: tree # prints the directory structure
tree:
	@tree -C $(CURDIR) -I '.*|$(VENV)|__pycache__|*.egg-info|build|dist'

.PHONY: uninstall # uninstalls project and dep from virtual environment
uninstall: $(VENV) $(VENV_PYTHON) clean-install
	@$(VENV_PYTHON) -m pip uninstall $(PROJECT_NAME)
	@rm -rf *.egg-info

.PHONY: venv # builds the virtual environment
venv:
	@if [ ! -d $(VENV) ]; then \
		$(SYSTEM_PYTHON) -m pip install virtualenv --user; \
		$(SYSTEM_PYTHON) -m virtualenv $(VENV) >/dev/null; \
	fi
