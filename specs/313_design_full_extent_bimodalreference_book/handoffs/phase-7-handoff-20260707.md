# Phase 7 Handoff: Part II Chapter — Frame Classes and Extensions

**Status**: COMPLETED
**Files touched**: `chapters/p2-frame-classes.typ` (filled from Phase-5 shell), `chapters/06-notes.typ` (discrepancy correction), `sync-check-whitelist.txt`

## What was done

- Wrote the full chapter: the `FrameClass` partial order (`ProofSystem/Axioms.lean:422-442`),
  the frame-condition semantic typeclass hierarchy (`FrameConditions/FrameClass.lean`,
  `Validity.lean`, `Soundness.lean`, `Compatibility.lean` — sorry-free), the DF/DN/CO paper
  correspondence (Discreteness/Density formalized ✓, Completeness class ○ unformalized), the
  Next/Previous derived-operator characterization, and a fresh-atom conservative-extension
  result (`lift_derivation_qfree`).
- Used a dedicated Explore research dispatch (per-fact verification against live source,
  not the plan's guessed names) before writing any prose, per the phase's own instruction to
  "resolve the exact declaration name from source before writing it."

## Deviations from plan (both are corrections surfaced by verification, not scope changes)

1. **`FrameClass` file attribution corrected.** The plan's source-mapping table assumed the
   `FrameClass` inductive and its partial order live in `FrameConditions/FrameClass.lean`.
   Live-source verification found they are entirely in `ProofSystem/Axioms.lean:422-442`;
   `FrameConditions/FrameClass.lean` instead defines an unrelated typeclass hierarchy
   (`LinearTemporalFrame`/`SerialFrame`/`DenseTemporalFrame`/`DiscreteTemporalFrame`) over a
   generic duration type. The chapter documents both correctly and calls out the correction
   explicitly rather than silently repeating the plan's assumption.
2. **Next/Previous guard convention corrected.** The plan's task text guessed
   `X φ := ⊥ U φ` (event-second). Live source (`Syntax/Formula.lean:415,419`) shows the
   opposite Burgess convention: `next φ := φ U ⊥` / `prev φ := φ S ⊥` (event-first, guard
   second). The chapter states the verified convention, not the guessed one.
3. **Conservative-extension purpose corrected, and a discrepancy note added to `06-notes.typ`.**
   The plan expected `Metalogic/ConservativeExtension/` to formalize the paper's
   $cal(L)$-vs-$cal(L)^+$ (H/G-primitive vs. Until/Since-extended) conservativity theorem.
   Live-source verification found its actual (and only) theorem, `lift_derivation_qfree`
   (`Lifting.lean:683-695`), is a Goldblatt/BdRV-style fresh-atom naming lemma supporting the
   *irreflexivity* argument — its own doc comment calls it "the key result enabling the
   irreflexivity proof," unrelated to the paper's base/extended-language split. No other
   module implements that split. Per the postmortem rule against unverified per-result
   correspondences and the binding rule to route discrepancies to `06-notes.typ`'s register
   rather than silently drop them, I corrected `06-notes.typ`'s "Language Basis" section (which
   had inherited the same over-attribution from an earlier revision) with an explicit
   discrepancy-correction paragraph, and the new chapter states only what
   `lift_derivation_qfree` actually proves.
4. **`thm:BLplus-NextPrevious` does not exist** as a Lean name (confirmed by grep); the chapter
   cites it as a paper-only (○) label with an explicit "no such Lean declaration" note, added
   to the whitelist as a deliberate negative-resolution citation.

## Verification

`typst compile BimodalReference.typ build/BimodalReference.pdf` exits 0. `bash
scripts/typst-sync-check.sh` exits 0 (all 4 checks PASS, 289 backtick candidates, up from 233).
