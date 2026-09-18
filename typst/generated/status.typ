// ============================================================================
// generated/status.typ
//
// GENERATED FILE -- never edit by hand. Regenerate via:
//   scripts/typst-status-counts.sh
//
// Reproduces the SYNC-MAP.md Phase 1 ground-truth-counts methodology.
// Stamped from live source at commit 8ce53d8af (2026-09-18).
// ============================================================================

#let stamp-commit = "8ce53d8af"
#let stamp-date = "2026-09-18"

#let axiom-count = 29
#let rule-count = 7
#let base-count = 23
#let dense-only-count = 2
#let ztime-only-count = 2
#let rtime-only-count = 2

#let sorry-total = 4
#let sorry-total-excl-boneyard = 0

#let sorry-table = (
  ("Algebraic/", 0),
  ("BXCanonical/", 0),
  ("Bundle/", 0),
  ("WeakCanonical/ (live)", 0),
  ("WeakCanonical/ (archived, Boneyard/Kamp/)", 4),
  ("Core/, Decidability/, SoundnessLemmas/, top-level", 0),
)

// The WeakCanonical row is SPLIT because the un-split row printed an ARCHIVED
// count beside `sorry-total-excl-boneyard`, which is a LIVE figure: a reader saw
// "0 sorries outside the archive" next to "WeakCanonical/: 4" and had no way to
// tell the 4 was entirely archived. The generator already computes both halves,
// so the split costs nothing and removes the contradiction.

#let axiom-report-table = (
  ("FormalSystem.Metalogic.BXCanonical.completeness", "BXCanonical/Completeness.lean", "propext, Classical.choice, Quot.sound", "no"),
  ("FormalSystem.Metalogic.BXCanonical.derivable_of_validDense", "?", "propext, Classical.choice, Quot.sound", "no"),
  ("FormalSystem.Metalogic.BXCanonical.derivable_of_validZTime", "?", "propext, Classical.choice, Quot.sound", "no"),
  ("FormalSystem.Metalogic.BXCanonical.completeness_rtime_engine", "BXCanonical/CompletenessDedekind.lean", "propext, Classical.choice, Quot.sound", "no"),
  ("FormalSystem.Metalogic.BXCanonical.Chronicle.countermodel_dense", "BXCanonical/Chronicle/ChronicleToCountermodelBasic.lean", "propext, Classical.choice, Quot.sound", "no"),
)
