# Phase 10b Handoff — task 350 (dispatch sess_1783988294_843145 continuation, 2026-07-13)

## Immediate Next Action

Dispatch Phase 10b-ii units 2+: the A_i/B_i split machinery (Rabinovich chunk_0017) at the
attained first-`¬β0` pin, the `BracketFormula.negFix` recursion (Cases 1-3 with gates), the
boundary simplifications (d)/(e), and `negFix_iff`. Estimated ~500-900 lines. Both consumer
devices are now delivered and green:
- **Case 2**: `negBoundedRightFixAnchored_iff` / `negBoundedLeftFixAnchored_iff` — the shape
  `(…).holds z0 z1 ↔ ¬∃ z ∈ (z0,z1), α(z) ∧ bf.holds …` with the peeled point type `α` as
  the anchor (EANegationFix.lean, section "Anchored Corollary 5.4 mirrors").
- **Case 3 gluing**: `VBracketFormula.concatPin_holds_iff` — `(VL.concatPin pin VR).holds
  z0 z1 ↔ ∃ r ∈ (z0,z1), VL.holds z0 r ∧ pin(r) ∧ VR.holds r z1` (section "The
  pinned-concatenation builder").

## Current State

- 10a COMPLETE (commits a928ccf3f, 53d7f123e, 138c03fda) — see phase-10-handoff-20260713.md.
- **10b-i COMPLETE and green** (commit 054818233, +475 lines): anchored Cor 5.4 mirrors.
  `untilFoldAnchored α` / `sinceFoldAnchored α` (innermost fold goal = α, base of the Phase 9
  code is the `α := ⊤` instance), `untilChainPredsAnchored` / `sinceChainPredsAnchored`
  (last/first chain entry = α), anchored chain observations
  `exists_bracketOf_right_anchored_iff` / `exists_bracketSnocOf_left_anchored_iff` (relink
  `y ≤ c / y > c` case split unchanged, exactly as design note 1 predicted), assemblies
  `negBoundedRightFixAnchored(_iff)` (h_INF) and `negBoundedLeftFixAnchored(_iff)`
  (h_INF + h_SUP). Pin brackets `rightPinBracket`/`leftPinBracket` reused as-is
  (parametric in the fold argument).
- **10b-ii unit 1 COMPLETE and green** (commit 37e24dce2, +112 lines): pinned-concatenation
  builder. `bracketOf_append_pin_holds_iff` (list-level split of `[s, …ps…, pin, b, …qs…]`
  at the pin), `BracketFormula.concatPin` (witness count kept as the list length of the
  combined fold pairs — deliberately NOT cast to `nL + 1 + nR`, avoiding Fin casts; the
  V-level consumer stores it under `Σ n`), `VBracketFormula.concatPin(_holds_iff)`
  (flatMap × map product of disjunct lists; `∃ r` + fixed pin distribute over both).
- Verification: full `lake build` green (1739 jobs); EANegationFix.lean sorry-free; axioms
  on `negBoundedRightFixAnchored_iff`, `negBoundedLeftFixAnchored_iff`,
  `VBracketFormula.concatPin_holds_iff` exactly [propext, Classical.choice, Quot.sound];
  no vacuous defs; no new axioms.
- Sorry inventory: EMPTY for task-350 scope. (Kamp/ census shows 6 pre-existing out-of-scope
  sorries: Boneyard/EndpointNegation.lean:160, Boneyard/FOToVEA.lean:118, EANegation.lean:1090
  and :1249 (superseded pre-task-350 file), KampPrior.lean:361 and :364 (task-358 territory,
  G6 guard). None introduced or inherited by task 350.)

## Key Decisions

1. Anchored versions ADDED alongside the Phase 9 `⊤`-instances (copy-adaptation per the
   binding design note), not a refactor-with-instantiation — Phase 9/10a consumers untouched,
   zero churn on delivered proofs.
2. `BracketFormula.concatPin`'s index is the fold-pair list length (defeq `nL + 1 + nR` but
   not syntactically); do NOT add a cast lemma unless 10b-ii actually needs the numeral form —
   the `Σ n` in `VBracketFormula.disjuncts` absorbs it.
3. Seam taken after 10b-ii unit 1: the A_i/B_i split is the recursion core whose disjunct-list
   shape should be settled in one dispatch against chunk_0017 — landing further fragments
   before that design is fixed invites churn (H6).

## Design Notes for 10b-ii units 2+ (carried forward, binding)

1. Case 3 = A_i/B_i decomposition at the attained first-`¬β0` pin r0 (chunk_0017): r0 = i-th
   witness / r0 interior to segment i; negation = conjunction of `¬A_i`/`¬B_i^±` by IH on
   strictly smaller brackets, glued by `concatPin` across the pin + `conjFull` (Phase 7) for
   the `Cond_i ∧ Form_i` products, plus the paper's (d)/(e) boundary simplifications.
2. The n=1 deliverables (`negFixOne` shape, backward-lemma pattern, cover pattern) are the
   specialization targets: the general disjuncts must reduce to {A, B1, B2, B3, B4, B4′} at
   n=1.
3. Case 2 consumes the ANCHORED mirrors (never the plain `negBoundedRightFix` — refuted on
   discrete carriers, 10a design note 1).

## References

- Plan Phase 10 (seam status updated): `specs/350_.../plans/02_offdiag-k1-aggregate-discharge.md`
- Prior handoff: `specs/350_.../handoffs/phase-10-handoff-20260713.md`
- Literature: `~/Projects/Literature/sources/rabinovich_2014/chunk_0016.md` (Cases 1-3),
  `chunk_0017.md` (A_i/B_i split, boundary simplifications).
- Delivered code: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EANegationFix.lean`
  sections "Anchored Corollary 5.4 mirrors" and "The pinned-concatenation builder".
