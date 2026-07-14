# Task 350 Phase 10 (10b-ii units 2+): negFix recursion core — Summary

## Result

Phase 10 [COMPLETED]. `BracketFormula.negFix` (Rabinovich Lemma 5.1 general
fixed-formula negation, gates riding in the disjuncts) and the full
biconditional `BracketFormula.negFix_iff` landed sorry-free in
`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EANegationFix.lean` (~570 new
lines), in four independently committed green seams.

## Seams delivered

1. **Seam 1** (f38a5563c): V-level helpers — `VBracketFormula.trivialTrue`,
   `VBracketFormula.conjEverywhere(_holds_iff)`,
   `VBracketFormula.conjFull(_holds_iff)` — and the pin dichotomy
   `firstNegPin_or_all` (Classical.byCases + `HasAttainedINF.first_occ_tp` on
   `s.neg`: either `s` everywhere on `(z0,z1)`, or an attained first-`¬s` pin).
2. **Seam 2** (39b6cac58): the chunk_0017 A_i/B_i split —
   `SplitEntry`/`splitsAt` (all placements of an interior point relative to a
   bracket's witnesses), `splitsAt_rightPairs_length_le` (termination measure),
   `bracketOf_splitsAt_iff` (both directions; gluing via
   `TemporalPred.eval_at_glue`); the pinned DNF machinery — `PinnedItem`,
   `PinnedItem.conj(_holdsAt_iff)`, `pinnedConj(_holdsAt_iff)`,
   `pinnedConjAll(_holdsAt_iff)`, `pinnedListToV(_holds_iff)` (glue into a
   V-bracket via `concatPin` with gateSeg/gatePin).
3. **Seam 3** (c10db282f): `negFixList` recursion (well-founded on pair-list
   length) + wrapper `BracketFormula.negFix`. Case 2 disjunct =
   `negBoundedLeftFixAnchored a tail` gated by `s`-`conjEverywhere`; Case 3 =
   `pinnedListToV (pinnedConjAll items) s s.neg` where items are per-placement
   failure triples (anchored A-failure / pin-type failure / recursive
   B-failure).
4. **Seam 4** (41c182a1f): `negFixList_nil_iff`, `negFixList_iff` (strong
   induction on pair-list length), `BracketFormula.negFix_iff` via the
   `holds_iff_bracketOf` bridge.

## Verification

- Full `lake build` green (1739 jobs).
- EANegationFix.lean: 0 sorries; no vacuous definitions; no new axioms.
- `lean_verify Bimodal.Metalogic.WeakCanonical.Kamp.BracketFormula.negFix_iff`:
  axioms exactly `[propext, Classical.choice, Quot.sound]`, no warnings.
- Preserved assets intact: `negFixOne_iff`, anchored mirrors
  (`negBounded{Right,Left}FixAnchored_iff`), `concatPin_holds_iff`,
  `NegFixGateProbe` theorems all still build.
- G6 territory guard honored: no edits to KampPrior.lean,
  ExteriorPinnedConverseK.lean, ExteriorPinnedConversePastK.lean.

## Plan deviations (annotated inline in the plan)

- Recursion base is n = 0 (`negFixList s [] = [⊤, ¬s, ⊤]`), not a special
  n = 1 case; `negFixOne(_iff)` retained as independent validation.
- Case 2 consumes the ANCHORED left mirror (per design note 1), and the same
  anchored mirror also consumes Case 3's A-failures on `(z0, r0)` — this is
  the termination-enabling move: only B-failures (strictly shorter right
  parts) recurse.
- Boundary simplifications (d)/(e) are absorbed (seg-0 placement vacuous under
  `¬s(pin)`) rather than emitted as separate disjuncts.

## Sorry inventory

Empty for Phase 10 scope. Pre-existing task-305 documented sorries in
EANegation.lean (Boneyard-forward path) untouched.
