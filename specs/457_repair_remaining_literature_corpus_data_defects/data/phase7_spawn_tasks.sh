#!/usr/bin/env bash
# phase7_spawn_tasks.sh - Spawn the four Phase 7 follow-up tasks into specs/state.json,
# following the pattern established by .claude/scripts/literature-create-setup-task.sh.
set -euo pipefail

PROJECT_ROOT="/home/benjamin/Projects/BimodalLogic"
STATE_FILE="$PROJECT_ROOT/specs/state.json"
TMP_DIR="$PROJECT_ROOT/specs/tmp"
mkdir -p "$TMP_DIR"

created="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

add_task() {
  local slug="$1" title="$2" desc="$3" topic="$4"
  local next_num
  next_num=$(jq -r '.next_project_number // 1' "$STATE_FILE")
  local tmp_file="$TMP_DIR/state-spawn-${slug}.json"
  jq --argjson num "$next_num" \
     --arg slug "$slug" \
     --arg title "$title" \
     --arg desc "$desc" \
     --arg created "$created" \
     --arg topic "$topic" \
     '
     .next_project_number = ($num + 1) |
     .active_projects += [{
       "project_number": $num,
       "project_name": $slug,
       "status": "not_started",
       "task_type": "general",
       "topic": $topic,
       "priority": "medium",
       "created": $created,
       "last_updated": $created,
       "title": $title,
       "description": $desc,
       "artifacts": [],
       "dependencies": [],
       "next_artifact_number": 1
     }]
     ' "$STATE_FILE" > "$tmp_file"
  if ! jq empty "$tmp_file" 2>/dev/null; then
    echo "Error: jq produced invalid JSON for $slug" >&2
    rm -f "$tmp_file"
    exit 1
  fi
  mv "$tmp_file" "$STATE_FILE"
  echo "$next_num $slug"
}

add_task \
  "migrate_12_legacy_literature_entries_to_v2_schema" \
  "Migrate the 12 remaining legacy chunks_dir-only literature entries to the v2 schema" \
  "Follow-up to task 457's SCOPE 7 (provenance adjudication for 3 named legacy entries). 12 further legacy chunks_dir-only entries remain in ~/Projects/Literature/index.json beyond the 3 SCOPE 7 named and migrated (Jonsson-Tarski 1951/1952, Goldblatt 2006): brics-rs-96-35, cattani-winskel-2005-profunctors, brics-rs-94-7, schultz-spivak-temporal-type-theory, fong-speranzon-spivak-temporal-landscapes, schultz-spivak-vasilakopoulou-dynamical-systems-sheaves, thomason-1970-indeterminist-time, rutten-2000-universal-coalgebra, jacobs-coalgebra-intro-draft, danos-krivine-rccs, reynolds-2003-ockhamist, rumberg-zanardo-2019-transition-structures. Each needs: a manual chunk-read fidelity adjudication (grounded, not from an automated ratio alone -- literature-fidelity-audit.sh does not cover these since they sit outside sources/, so its output cannot corroborate; see task 457 Phase 6 phase notes for the code-level reason), path/token_count population per the SCOPE 1 directory-path convention (chars/4+20 over concatenated chunk_*.md text), and doc_type/source_format population per the SCOPE 5 evidence-grounded approach (inspect the actual source file if present; record as a reasoned exclusion if not). Use task 457's Phase 6 adjudication process as the template: take a backup before mutating, open at least one chunk per document and read it by hand, stamp provenance_fidelity only after that read, then run literature-build-index.sh --global and confirm the FTS row count did not drop." \
  "literature"

add_task \
  "deduplicate_8_stale_literature_entries" \
  "Deduplicate 8 stale placeholder entries in the global literature index" \
  "Discovered during task 457 Phase 3 (SCOPE 3 bulk token_count re-baseline). ~/Projects/Literature/index.json has 369 total entries but only 361 distinct ids: 8 ids each appear TWICE. In every one of the 8 cases, one instance carries provenance=\"migrated from ingest schema (doc_id/source_path/chunks_dir)\", token_count=0, empty summary, and thinner metadata (a stale placeholder from an incomplete earlier migration), while the other instance (same id, same path) is the already-correct, fully-populated v2 entry with real authors/summary/keywords/token_count. Affected ids: calcagno_2007_local-action-abstract-separation-logic, docherty_pym_2019_stone-dualities-separation-logics, jung_2018_iris-from-the-ground-up, ohearn_2007_resources-concurrency-local-reasoning, ohearn_2019_separation-logic-cacm, reynolds_2002_separation-logic, brookes_2007_semantics-concurrent-separation-logic, jipsen_litak_2017_algebraic-glimpse-bunched-implications. Task 457 corrected the stale duplicates' token_count only (to unblock its own SCOPE 3 defect-class-empty verification gate) but did NOT remove the duplicate records -- that structural fix (delete the stale placeholder, keeping the fully-populated entry) is this task's scope. After removal, confirm entry count drops from 369 to 361, JSON still parses, and literature-build-index.sh --global still exits 0 with FTS row count >= the pre-dedup baseline (removing a duplicate doc removes duplicate chunks too, so the row count is expected to change compared to the pre-457 baseline -- record the new baseline rather than expecting equality)." \
  "literature"

add_task \
  "acquire_gabbay_2003_many_dimensional_modal_logics" \
  "Acquire a usable copy of Gabbay, Kurucz, Wolter and Zakharyaschev 2003 (Many-Dimensional Modal Logics)" \
  "SCOPE 8 acquisition gap identified by task 457's research and re-confirmed at implementation time: the source is present in the user's Zotero library under item key Kurucz2003, but the stored PDF has a broken/custom font encoding with no usable ToUnicode CMap and is not text-extractable by any available tool (pdftotext yields ~69.5% printable characters, scrambled letters). This is an acquisition/OCR problem, not an index-schema defect -- do NOT attempt to fix by re-running the standard ingest pipeline with LITERATURE_CONVERTER=pymupdf; that path previously produced 2260 chunks of control-character mojibake that passed the quality gate and had to be manually purged from the corpus and FTS index (see task 457's research report for this precedent). Needed: either a cleaner PDF copy (different scan/source) or an OCR pass (e.g. ocrmypdf) that produces usable, non-garbled text, followed by a normal /literature ingest." \
  "literature"

add_task \
  "acquire_goldblatt_1989_varieties_of_complex_algebras" \
  "Acquire Goldblatt 1989 'Varieties of complex algebras' (Annals of Pure and Applied Logic)" \
  "SCOPE 8 acquisition gap identified by task 457's research and re-confirmed at implementation time: this paper is absent from both the ~/Projects/Literature corpus and the Zotero library, and is named as a prerequisite by other tasks in this repo working on the Jonsson-Tarski representation theorem. Note: goldblatt_2003 already present in the corpus is a DIFFERENT paper (Erdos Graphs Resolve Fine's Canonicity Problem) -- do not conflate the two. Needed: locate and acquire a copy of Goldblatt 1989 (Annals of Pure and Applied Logic 44, pp. 173-242), add it to Zotero, then run a normal /literature ingest." \
  "literature"
