# Phase 2 Handoff — Retire EANegation backward-direction closure

## Immediate Next Action
Phase 3: Boneyard `#exit` and header normalization (mechanical scripted pass over
TB = `Theories/Bimodal/Boneyard/` and KB = `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Boneyard/`,
now including the 2 files created in Phases 1–2). Re-run the census first to fix the work list.

## Current State
- Phases 1 and 2 COMPLETED (of 4).
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EANegation.lean`: 8-decl removal set excised
  (B2: `BracketFormula.partialBracketExist`, `neg_partialBracketExist_sufficient`,
  `neg_bracket_zero_is_vbracket`, `neg_bracket_is_vbracket`, `neg_partialBracketExist_is_vbracket`;
  B3 trio: `neg_orderedPointsExist_zero_false`, `neg_orderedPointsExist_one`,
  `neg_orderedPointsExist_one_is_bracket`). File is now 677 lines, ZERO sorry tokens
  (only prose mentions of "sorry-free" in comments). Module docstring updated; breadcrumb
  comment placed before the closing `end`.
- New archive: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Boneyard/EANegationVBracketBackward.lean`
  (613 lines): imports + `ARCHIVED (Boneyard)` module docstring + `#exit` + the 8 decls verbatim,
  including the impossibility note and both Rabinovich docstrings ("Lemma 5.1 (Rabinovich 2014,
  pp.7-11)", "Corollary 5.4") byte-identical (sed-extracted).
- Verification: full `lake build` GREEN (1789 jobs); no removed-decl code references outside
  Boneyard (comment mentions only); `lean_verify` on
  `Bimodal.Metalogic.BXCanonical.completeness_discrete` → exactly
  `[propext, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]`, no sorryAx,
  no warnings.

## Key Decisions
- Excision ranges (pre-edit line numbers): :73–:114 (B3 trio + docs), :571–:577
  (`partialBracketExist` + doc), :714–:1250 (tail: Corollary 5.4 forward doc through final
  `sorry`, including the "Lemma 5.1" section docstring which framed only removed decls).
- Archive content assembled by verbatim `sed` extraction to guarantee byte-identical
  preservation of the impossibility note and Rabinovich labels.
- The pre-existing `sorryAx` on the non-discrete `completeness` theorem
  (`BXCanonical/Completeness.lean:388`) is outside this task's baseline (baseline is
  `completeness_discrete` only) and was present before this phase.

## Sorry Inventory
[] (empty — this phase removed the tree's EANegation sorries; none introduced)
