#!/bin/bash

# Run the pyenv initalization process.
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# Stubbed functions to be overloaded within the testing.settings.sh file.
function perform_cleanup {
    echo "Nothing here"
}
function run_tests {
    echo "Nothing here"
}

# Sourcing in the testing.settings.sh file.
source testing.settings.sh

# Build the pyenv virtualenv for the purpose of testing.
function build_venv {
    pyenv virtualenv $1 pytenable$1 &> /dev/null
    pyenv activate pytenable$1
    if [[ "$1" == *"pypy"* ]];then
        # A Shim for pypy as the cryptography library doesn't have a bdist.
        pip install cryptography                             \
            --global-option=build_ext                        \
            --global-option="-L/usr/local/opt/openssl/lib"   \
            --global-option="-I/usr/local/opt/openssl/include"
    fi
    pip install -r dev-requirements.txt &> /dev/null
}


# Teardown the virtualenv
function teardown_venv {
    pyenv deactivate
    pyenv uninstall -f pytenable$1
}


# a simple wrapper for running the test suite.
function test_package {
    local version=$1
    echo "Building the Virtualenvironment for testing in Python ${version}..."
    build_venv ${version}
    echo "Testing package using Python ${version}"
    run_tests
    local return_code=$?
    teardown_venv ${version}
    return ${return_code}
}


# The main testing loop
function main {
    local vcheck=$1
    local return_code=0

    # A simple check to make sure that the TESTING_PYTHON_VERSIONS var is set.
    if [ "$TESTING_PYTHON_VERSIONS" == "" ];then
        echo "The TESTING_PYTHON_VERSIONS variable has not been set.  Stopping."
        exit
    fi

    # Run through all of the python versions stored in pyenv.
    for pyver in ${TESTING_PYTHON_VERSIONS[@]};do
        
        # if we only want to run against a specific version of python,
        # then the vcheck var will have a non-null value.  Check to
        # make sure that we have a match, and if so, run the test suite.
        if [ "${vcheck}" != "" ] && [ "${vcheck}" == "${pyver}" ];then
            test_package ${pyver}
            return_code=$?
        
        # If nothing was passed, then just run the python version as
        # configured.
        elif [ "${vcheck}" == "" ];then
            test_package ${pyver}
            return_code=$?
        fi

        # if the return code from the test suite is a non-zero response
        # then we will throw an error.
        if [ "${return_code}" -ne 0 ];then
            echo "Testing Failure in Python ${pyver}"
            break
        fi 
    done
    perform_cleanup    
}

# Run the main loop.
main $1