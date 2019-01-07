# Testrunner

Testrunner is a simple testing tool that leverages pyenv & virtualenv together to build single-use python environments for the purposes of testing.  Originally written to attempt to build an environment for local testing that would work similarly to my Travis builds for pytenable, their may be use cases outside of that for other folks.

Testrunner requires 2 files to be included within the root of the repository you wish to test.  a `dev-requirements.txt` file for the purposes of building the test environment, and a `testing.settings.sh` file with ad a minimum, 2 functions defined.

* `run_tests`: The function that is performing the tests.  Id though return the exit code of whatever your tests are.
* `perform_cleanup`: What cleanup actions are needed upon completion of all of the tests.

An environment variable also needs to be set defining an array of the python versions that are installed that you wish to test against.

## Installation

Installation of testrunner is easy.  First install pyenv and pyenv-virtualenv, then plud the testrunner script into a location that you can run it from.

    brew install pyenv pyenv-virtualenv
    cp testrunner.sh ~/bin

## Usage

Testrunner can be run in 2 modes.  The first mode is when you simply run `testrunner` from a repository with the dev-requirements and settings files.  It will iterate over all of the configured python versions and test through them.  The second mode is when you call out a specific python version as the first parameter. it will only test against the specific version requested.