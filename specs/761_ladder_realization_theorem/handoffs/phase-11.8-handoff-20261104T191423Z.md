# Phase 11.8 Handoff — The Interface Half That Landed, and the Half That Is Blocked

- **Phase**: 11.8, status `[BLOCKED]` (the plan's own contingency marker for the not-closing case)
- **Immediate next action**: nothing in this plan is enterable. 11.8's remaining two declarations
  need a construction with no landed component; Phases 11.6, 11.7, 12.2 and 13-18 remain behind
  Phase 11.9's INCONCLUSIVE verdict.

## What landed, green and committed

`FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean`, in the Cascade section:

- `exists_ladderPath_at_region_of_pend_past` — the plan's ordered FIRST task, three lines,
  `exists_spliced_ladderPath_of_pend_past` composed with `spliced_at_region`. Its elaborated
  signature matches the recorded block; `{g a l}` are explicit implicit binders because the
  Cascade section, unlike the Splice section the companion lives in, declares none.
- The section docstring's refuted-name sentence UPGRADED from "not landed" to "**REFUTED IN THE
  IDLE-PAST REGIME, not merely absent**", with the mechanism stated (`spliceCnt` raises the pin at
  `a`'s region start by exactly `l` against `pinCompat_of_ladderPath`'s necessity, and the demand
  becomes `s - v + l ≤ s - v` at a tight pin pair) and the compiled object cited by PATH
  (`tightChain_slack_zero` in
  `specs/evidence/seam-gluing-ray-product/ladder-tight-chain-nonliftability.lean`).
- A closing note recording, in the module itself, exactly what the idle-past half needs and why
  none of it is available from what is landed.

Wiring: one `#guard_msgs` + `#print axioms` pin; three generated inventory blocks; `status.typ`.

## Why the other two declarations are BLOCKED

`exists_ladderPath_at_region_of_idle_past` and `exists_ladderPath_at_region` are NOT landed and
both names are claimed by nothing.

**The goal state.** The conclusion is
`∃ g', IsLadderPath step pend g' ∧ objAt g' v = objAt g v ∧ cntAt g' v = cntAt g v + l`. Its FIRST
conjunct is what no landed object supplies, and the reason is a chain of three landed facts:

1. `cntAt_eq_of_obj_eq` — two ladder paths with the same object walk carry the same countdown at
   every position. So any `g'` with `cntAt g' v = cntAt g v + l` must have a DIFFERENT object walk
   from `g`; the surgery cannot be confined to the countdown.
2. `spliceObj g a l` is the one alternative walk the library has, and in THIS regime it is
   refuted, by the mechanism above on the compiled tight doubling chain (every pin pair tight,
   every `v ≤ 0` idle).
3. No third walk exists. Phase 11.2 landed the cascade's BOOKKEEPING —
   `pinnedRegions_subset_Ico`, `pinnedRegions_finite`, `pinnedRegions_ncard_le`,
   `pin_deficit_le_of_lengthen`, `cascadeDemand`, `cascadeDemand_add_succ`,
   `cascadeDemand_le_cascadeBound` — and nothing else. No declaration anywhere builds an
   idle-insertion walk, proves it is a ladder path, or iterates the construction over the pins.

**The failing pin pair**, as the carried blocker names it: `(s, v)` with `s` the region start of
`a`'s region and `v` an earlier region start whose region ends below `s`. The original supplies
`((cntAt g (s+1) : ℤ) - cntAt g (v+1)).natAbs ≤ (s - v).natAbs` through
`pinCompat_of_ladderPath`; the spliced walk needs the same with `+ l` on the left; and at a tight
pair the two are `s - v + l ≤ s - v`, false for `l > 0`.

**What a successor owes.** The insertion construction itself: a walk inserting `d` idle positions
into idle runs strictly BELOW the comparison position's region start (so the walk at and above
that start stays pointwise fixed and `objAt g' v = objAt g v` survives by construction), its
ladder-path proof, and the iteration over the finitely many constraining pins whose displacement
is the doubling recurrence `cascadeDemand` already encodes. The restated existential is OPEN, not
known: the refutation that kills the `spliceObj`-shaped conclusion establishes nothing about it,
and the cascade is a mechanism rather than a proof. `LadderAgree.lean` has **42 lines** of
headroom (2,558 against its in-source 2,600 baseline), so a successor should expect to take the
pre-authorized length remedy — the contingency module `LadderCascade.lean` plus its two import
edges, which this phase's `Files to modify` already lists.

## Statement-level finding, recorded not substituted

**The unconditional join cannot be `regime_exhaustive_of_clipIdx_eq`.** That lemma's dichotomy is
between TWO ladder paths meeting at a `clipIdx` collision at a fixed next deadline; it consumes
`hB : 2 ≤ B`, a second path `g'`, a second position `z'`, `hn : nxtAt g z = nxtAt g' z'`, `hne`
and the `clipIdx` equality — none of which the three recorded signatures carry. The join those
signatures admit is the plain excluded middle on `hidle : ∃ p ≤ a, pend (objAt g p) = false`,
whose negation `push_neg`s to `hpast`. A future revision should name that instead. Nothing was
silently substituted: the item is unreachable until the idle-past half lands.

## Phase 15's inherited contingency

The admissibility half of the counter-lift lemma is UNCONDITIONAL in the pending-forever regime
and CONDITIONAL in the idle-past regime, and no declaration anywhere claims otherwise. Phase 15 —
the single consumer — needs it unconditional, and inherits that as its own contingency. The
agreement does not depend on it: no phase of 11.3-11.7 does, because the cell-level route spends
no pin budget. Phase 11.2's three landed facts are left standing and untouched.

## Prohibited workarounds: NOT taken

No pin hypothesis of `exists_spliced_ladderPath` was dropped or relaxed. `spliced_at_region`,
`pinCompat_of_ladderPath`, `exists_spliced_ladderPath`, `exists_spliced_ladderPath_of_pend_past`
and `spliceObj_of_lt` are unmodified — the whole deletion set of this phase's diff is the four
docstring lines that were replaced. The `spliceObj`-shaped conclusion was not re-attempted in the
idle-past regime in any form. No `sorry`, axiom, `native_decide` or vacuous definition was
written, no checklist item was annotated and walked past, `LadderPump.lean`, `LadderPin.lean` and
`LadderChain.lean` were not edited, and no certificate object was reached for.

## Verification evidence

- Guarded scoped build of `LadderAgree.lean` and of the axiom test: each exit 0 with 0 warnings.
  Full guarded `lake build`: exit 0, `Build completed successfully (2895 jobs)`, zero `error:`.
- `#print axioms` on `exists_ladderPath_at_region_of_pend_past`:
  `[propext, Classical.choice, Quot.sound]`, pinned under `#guard_msgs`. No `sorryAx`, no custom
  axiom, no `native_decide`.
- The conclusion contains no `spliceObj` and no `spliceCnt` (read the statement).
- The refuted name is unclaimed: `grep -rn 'exists_spliced_ladderPath_of_idle_past'
  FormalSystem/ Tests/` returns only docstring prose, and that prose names the statement as
  refuted in the idle-past regime rather than merely absent. The same holds for
  `exists_ladderPath_at_region_of_idle_past` and `exists_ladderPath_at_region`.
- The certificate-freedom grep (the extended form) over `LadderAgree.lean` returns 0, and the
  import list is unchanged at `AnchorLayer` and `CounterQuotient`.
- Length ceiling holds: 2,558 against 2,600.
- `lean-sorry-census.sh FormalSystem Tests`: exit 0, `sorry_count: 0`. Module-scoped vacuous grep
  over `LadderAgree.lean`: 0. Repository-wide vacuous grep: 1, unchanged. `^axiom ` counts: 10 / 2,
  unchanged.
- `typst-sync-check.sh`, `readme-lint.sh`, `check-evidence-probes.sh` (PASS, 49 wired) and
  `check-task-references.sh --quiet`: each exit 0. `check-module-invariants.sh`: only the
  pre-existing `C16` finding at `LadderChain.lean:2136`, unchanged in content and count.
