#!/bin/bash
# run-perf-harness.sh
#
# Stage 5 perf harness runner (PERF.md). Runs ScreenPerformanceHarnessTests
# against any destination (Simulator or a real device, Debug or Release)
# and turns the XCTAttachment JSON it produces into bare perf-output/*.json
# files. This indirection exists because the harness's JSON hand-off uses
# XCTAttachment-in-.xcresult (the only mechanism that works on both
# Simulator and a real device) rather than a direct file write from the
# test process, which is Simulator-only (real devices sandbox the test
# runner's filesystem access).
#
# Usage:
#   iOS/scripts/run-perf-harness.sh 'platform=iOS Simulator,name=iPhone 16' Debug
#   iOS/scripts/run-perf-harness.sh 'platform=iOS,id=<device-udid>' Release
#
# Real-device Release runs require the device to already be trusted/paired
# with Xcode and covered by a valid provisioning profile.

set -euo pipefail

DESTINATION="${1:?usage: run-perf-harness.sh <destination> [configuration]}"
CONFIGURATION="${2:-Debug}"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PERF_OUTPUT_DIR="$REPO_ROOT/perf-output"
RESULT_BUNDLE="$PERF_OUTPUT_DIR/.perf-run.xcresult"
ATTACHMENTS_DIR="$PERF_OUTPUT_DIR/.raw-attachments"

mkdir -p "$PERF_OUTPUT_DIR"
rm -rf "$RESULT_BUNDLE" "$ATTACHMENTS_DIR"

xcodebuild test \
  -project "$REPO_ROOT/iOS/SwiftUISDUI/SwiftUISDUI.xcodeproj" \
  -scheme SwiftUISDUI \
  -configuration "$CONFIGURATION" \
  -destination "$DESTINATION" \
  -only-testing:SwiftUISDUIUITests/ScreenPerformanceHarnessTests \
  -resultBundlePath "$RESULT_BUNDLE" \
  | xcbeautify

xcrun xcresulttool export attachments --path "$RESULT_BUNDLE" --output-path "$ATTACHMENTS_DIR"

for name in static-home-perf.json sdui-home_all-perf.json; do
  exported_path=$(jq -r --arg name "$name" \
    '.[] | .attachments[] | select(.suggestedHumanReadableName == $name) | .exportedFileName' \
    "$ATTACHMENTS_DIR/manifest.json" | head -n 1)
  if [ -z "$exported_path" ] || [ "$exported_path" = "null" ]; then
    echo "warning: no attachment named $name found in result bundle" >&2
    continue
  fi
  cp "$ATTACHMENTS_DIR/$exported_path" "$PERF_OUTPUT_DIR/$name"
done

rm -rf "$RESULT_BUNDLE" "$ATTACHMENTS_DIR"
echo "Wrote perf JSON to $PERF_OUTPUT_DIR"
