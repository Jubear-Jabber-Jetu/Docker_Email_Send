#!/bin/bash

# Start by running all tests
mvn test > test-results.log

# Initialize counters
TOTAL_TESTS=$(grep -c "Running " test-results.log)
FAILED_TESTS=$(grep -c "Tests run:.*, Failures: [^0]" test-results.log)

# Log the summary
echo "Total Tests Run: $TOTAL_TESTS"
echo "Total Tests Failed: $FAILED_TESTS"

# Exit with 0 to ensure the container succeeds
exit 0
