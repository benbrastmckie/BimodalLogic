#!/usr/bin/env bash
# Task 298 - Phase 3/4 driver: wait for native build, c4 spot-check, c7 regeneration.
# Launch detached:  setsid nohup bash specs/298_fix_c7_labeling_bug_and_regenerate_dataset/run-c7-regen.sh &
# Resumable: safe to re-run; lake caches compiled .o.export files.

set -uo pipefail
cd /home/benjamin/Projects/BimodalLogic || exit 1

LOG_DIR="specs/298_fix_c7_labeling_bug_and_regenerate_dataset/logs"
mkdir -p "$LOG_DIR"
DRIVER_LOG="$LOG_DIR/driver.log"

log() { echo "[$(date -Is)] $*" | tee -a "$DRIVER_LOG"; }

# RSS watchdog: kill generator if it exceeds LIMIT_KB (12GB), the task-298 failure signature.
# 12GB (not 20GB): earlyoom runs with -m10 --prefer ^(lean|lake|claude)$ on this 31GB host and
# would kill the generator or the session first. The fix bounds RSS well below 12GB, so crossing
# that line is itself a genuine regression signal.
watchdog() {
  local pid=$1 limit_kb=$((12 * 1024 * 1024)) peak=0
  while kill -0 "$pid" 2>/dev/null; do
    local rss
    rss=$(ps -o rss= -p "$pid" 2>/dev/null | tr -d ' ')
    if [ -n "$rss" ]; then
      [ "$rss" -gt "$peak" ] && peak=$rss
      if [ "$rss" -gt "$limit_kb" ]; then
        log "WATCHDOG: RSS $((rss/1024))MB exceeded 12GB limit - killing $pid (task-298 regression signature)"
        kill -9 "$pid" 2>/dev/null
        echo "$peak" > "$LOG_DIR/peak_rss_kb"
        return 1
      fi
    fi
    sleep 5
  done
  echo "$peak" > "$LOG_DIR/peak_rss_kb"
  log "watchdog: peak RSS $((peak/1024))MB"
  return 0
}

# Step 1: wait for any in-flight lake exe build to finish (native compile is ~410 C files).
log "=== Step 1: waiting for in-flight native build (if any) ==="
while pgrep -f "lake exe dataset_generator" >/dev/null 2>&1; do sleep 30; done
log "no in-flight lake exe; ensuring binary is built"

log "=== Step 2: build dataset_generator binary ==="
if ! lake build dataset_generator >>"$LOG_DIR/build.log" 2>&1; then
  log "FAIL: dataset_generator build failed - see $LOG_DIR/build.log"
  exit 1
fi
log "binary built OK"

# Step 3: c4 spot-check - must stay sound against the existing c4 baseline.
# NOT an exact record-count match: the 806-record baseline is from 2026-06-08 and predates
# ~525 commits to FormalSystem/ (a new structural_invalid_prefilter, plus this fix's own
# adaptive-fuel change), so the count legitimately moved to ~3087. check-c4-spotcheck.py
# gates on what must actually hold - no valid<->invalid flips, >=99% baseline coverage,
# and no rise in timeout rate.
log "=== Step 3: c4 spot-check (soundness vs data/bmlogic-c4.jsonl) ==="
./.lake/build/bin/dataset_generator --max-complexity 4 --mode exhaustive \
  --output "$LOG_DIR/test-c4.jsonl" >>"$LOG_DIR/c4.log" 2>&1 &
C4_PID=$!
watchdog "$C4_PID" &
wait "$C4_PID"; C4_RC=$?
C4_COUNT=$(wc -l < "$LOG_DIR/test-c4.jsonl" 2>/dev/null || echo 0)
log "c4 exit=$C4_RC records=$C4_COUNT (baseline 806, drift expected)"
if [ "$C4_RC" != "0" ]; then
  log "FAIL: c4 generator exited $C4_RC. Aborting before touching c7."
  exit 1
fi
if ! python3 specs/298_fix_c7_labeling_bug_and_regenerate_dataset/check-c4-spotcheck.py \
     data/bmlogic-c4.jsonl "$LOG_DIR/test-c4.jsonl" 2>&1 | tee -a "$DRIVER_LOG"; then
  log "FAIL: c4 soundness regression. Aborting before touching c7."
  exit 1
fi
rm -f "$LOG_DIR/test-c4.jsonl"
log "c4 spot-check PASSED"

# Step 4: c7 regeneration (the actual task-298 payload).
log "=== Step 4: c7 regeneration ==="
AVAIL=$(free -m | awk '/^Mem:/{print $7}')
log "available memory: ${AVAIL}MB"
if [ "$AVAIL" -lt 12000 ]; then
  log "FAIL: only ${AVAIL}MB available, need >=12GB headroom. Aborting."
  exit 1
fi

[ -f data/bmlogic-c7_metadata.json ] && cp data/bmlogic-c7_metadata.json data/bmlogic-c7_metadata.json.bak
[ -f data/bmlogic-c7.jsonl ] && cp data/bmlogic-c7.jsonl data/bmlogic-c7.jsonl.bak && \
  log "backed up existing c7 ($(wc -l < data/bmlogic-c7.jsonl) records) to data/bmlogic-c7.jsonl.bak"

./.lake/build/bin/dataset_generator --max-complexity 7 --mode exhaustive \
  --output data/bmlogic-c7.jsonl --wallclock-timeout 2000 >>"$LOG_DIR/c7.log" 2>&1 &
C7_PID=$!
watchdog "$C7_PID" &
wait "$C7_PID"; C7_RC=$?
C7_COUNT=$(wc -l < data/bmlogic-c7.jsonl 2>/dev/null || echo 0)
log "c7 exit=$C7_RC records=$C7_COUNT (prior stall was 13749)"

if [ "$C7_RC" != "0" ] || [ "$C7_COUNT" -le 13749 ]; then
  log "FAIL: c7 regeneration did not surpass the 13,749 stall point. Restoring backup."
  [ -f data/bmlogic-c7.jsonl.bak ] && cp data/bmlogic-c7.jsonl.bak data/bmlogic-c7.jsonl
  [ -f data/bmlogic-c7_metadata.json.bak ] && cp data/bmlogic-c7_metadata.json.bak data/bmlogic-c7_metadata.json
  exit 1
fi

log "=== Label distribution ==="
{
  echo "valid:   $(grep -c '"valid"' data/bmlogic-c7.jsonl)"
  echo "invalid: $(grep -c '"invalid"' data/bmlogic-c7.jsonl)"
  echo "timeout: $(grep -c '"timeout"' data/bmlogic-c7.jsonl)"
} | tee -a "$DRIVER_LOG"

rm -f data/bmlogic-c7.jsonl.bak data/bmlogic-c7_metadata.json.bak
log "SUCCESS: c7 regenerated with $C7_COUNT records, no stall at 13,750"
