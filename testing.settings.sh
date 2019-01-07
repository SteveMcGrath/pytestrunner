TESTING_PYTHON_VERSIONS=("2.7" "3.4.9" "3.5.6" "3.6.7" "3.7.1")

function perform_cleanup {
    echo "Cleaning up the Nessus Reports."
    rm -f *.nessus
}

function run_tests {
    pytest --vcr-record=none --cov=tenable tests
    return $?
}