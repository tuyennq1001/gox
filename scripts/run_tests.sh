#!/bin/bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
cd "$DIR"

echo "Building and running Gox unit tests..."
clang++ -std=c++11 -O2 -w -I Sources/Gox/engine \
    Sources/Gox/tests/test_session_reset.cpp \
    Sources/Gox/engine/Engine.cpp \
    Sources/Gox/engine/Vietnamese.cpp \
    Sources/Gox/engine/Macro.cpp \
    Sources/Gox/engine/SmartSwitchKey.cpp \
    Sources/Gox/engine/ConvertTool.cpp \
    -o /tmp/gox_test_runner

/tmp/gox_test_runner
rm -f /tmp/gox_test_runner
echo "All tests completed successfully."
