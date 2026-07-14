# Phase 10 Handoff — task 350 (dispatch sess_1783988294_843145, 2026-07-13)

## Immediate Next Action

Dispatch Phase 10b: general `BracketFormula.negFix` recursion + `negFix_iff`, in two
sub-steps:
- **10b-i**: anchored generalization of the Cor 5.4 machinery (see Design Note 1 below) —
  parametrize the innermost fold goal of `untilFold`/`sinceFold` by the peeled point type
  (delivered code = the `⊤`-anchored instance). ~200-350 lines, copy-adaptation of
  EANegationFix.lean:430-780 (Until side) / 782-1002 (Since side).
- **10b-ii**: paper Case 3 A_i/B_i split machinery (chunk_0017) + pinned-concatenation
  builder + the `negFix` recursion and iff. ~600-1,000 lines.

## Current State

- Phase 10a COMPLETE and green (per the plan's authorized H8 seam): probes + n=1 instance.
- Commits: `a928ccf3f` (10.1, ℤ R2 gate), `53d7f123e` (10.2, n=1 gate-complete list + iff).
- **R2 gate verdict: GO** — machine-checked in `NegFixGateProbe` (EANegationFix.lean):
  `bfZ_not_holds` + `caseA/B1/B2/B3_not_holds` + `caseB4_holds`. The gate-free 4-list is
  incomplete; the two-point gated B4/B4′ shapes are unavoidable.
- Delivered API (all in `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EANegationFix.lean`,
  namespace `Bimodal.Metalogic.WeakCanonical.Kamp`):
  - `bracketOne (s0 p s1) : BracketFormula 1` + `bracketOne_holds_iff`
  - `negFix1A/B1/B2/B3/B4/B4c` disjunct builders; `negFixOne` (six-disjunct list)
  - six private `negFix1*_backward` lemmas (each disjunct alone refutes the bracket; NO
    attainment hypotheses needed)
  - `negFixOne_cover` (consumes `HasAttainedINF` + `HasAttainedSUP`)
  - `negFixOne_iff` — the full n=1 biconditional Lemma 5.1 instance
- Verification: full `lake build` green; 0 sorries in Kamp/ (file sorry-free); axioms on
  `negFixOne_iff` and `NegFixGateProbe.caseB4_holds` exactly
  `[propext, Classical.choice, Quot.sound]`; no new axioms; no vacuous defs.
- Sorry inventory: EMPTY (nothing introduced, nothing inherited in scope).

## Key Decisions

1. ℤ probe landed as NAMED theorems in `namespace NegFixGateProbe` instead of anonymous
   `example`s (citable R2 verdict). ℤ-instance proofs use defeq re-typing
   (`have h : (a : ℤ) < b := h'`) + `decide` because `omega` cannot see atoms typed at
   `MZ.carrier` (even with `abbrev`).
2. n=1 cover case tree: A (p never occurs) → B1 (s0 fails before attained first-p) →
   B2 (s1 fails after attained last-p) → pin y0 := first ¬s0-point (INF), y1 := last
   ¬s1-point (SUP); trichotomy y0 < y1 → B3, y0 = y1 → B4′, y1 < y0 → B4 with the ¬p
   corridor lemma (`∀ x ∈ [y1, y0], ¬p(x)`).
3. Backward lemmas deliberately take NO attainment hypotheses — the disjuncts are
   self-refuting via trichotomy; only the cover needs INF/SUP.

## Design Notes for 10b (binding)

1. **Case 2 gap**: the delivered endpoint-free `negBoundedRightFix`/`negBoundedLeftFix`
   CANNOT consume the peeled bracket as black boxes — peeling the outermost point type α
   leaves `¬∃z ∈ (z0,z1), α(z) ∧ peeled.holds …` with α AT the moving endpoint, and no
   bracket expresses a point type at its own endpoint (`front.snoc α ⊤` needs a point
   strictly between the witness and the moving endpoint — refuted on discrete carriers).
   Fix: ANCHORED Cor 5.4 — innermost fold goal = α; chain preds carry α; the relink
   case split (`y ≤ c / y > c`, EANegationFix.lean:911-917/945-962) survives unchanged.
   Base-case check (by hand): `∃z ∈ (z0,z1), α(z) ∧ (β on (z0,z))` ⟺
   `(β Until α)(z0) ∧ ∃c ∈ (z0,z1), α(c)` — relink: witness y ≤ chain point c → take y;
   y > c → take c (α(c) from the chain, β on (z0,c) ⊂ (z0,y)).
2. **Case 3**: A_i/B_i decomposition at the attained first-`¬β0` pin (paper chunk_0017),
   pinned-concatenation builder for gluing IH outputs across the pin, `conjFull` (Phase 7)
   for `Cond_i ∧ Form_i` products, boundary simplifications (d)/(e).
3. The n=1 shapes are the specialization targets: whatever 10b builds must reduce to
   `{A, B1, B2, B3, B4, B4′}` at n=1.

## References

- Plan Phase 10 (updated with seam status + design notes):
  `specs/350_.../plans/02_offdiag-k1-aggregate-discharge.md`
- Literature: `~/Projects/Literature/sources/rabinovich_2014/chunk_0015.md` (case setup,
  end of file), `chunk_0016.md` (Cases 1-3 + INF formula 5.3), `chunk_0017.md` (A_i/B_i).
- Boneyard backward-gap documentation: `Kamp/Boneyard/NegationIndep.lean:331-363`.
