# Task 342 Completion Summary — Interior-Restricted Owner Index and Tie-Admitting Weak Orders

- **Task**: 342 — rework kvE2_sep arrangement carrier with interior-restricted owner index and
  tie-admitting weak orders
- **Session**: sess_1783617988_38e7cf (final phase); 9 phases across the orchestrated run
- **Status**: all 9 phases `[COMPLETED]`; task-level exit gate PASSED in full
- **File scope**: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean`
  (plus a one-session doc edit to `OuterGate.lean` in Phase 5, later reverted to diff-empty per gate)
- **Final commit**: `52adcac84` (`task 342 phase 9: tie-reporting honest order and kvE2_sepBody_complete_holds'`)

## What the task fixed

Two machine-certified defects in the kvE2_sep completeness layer, repaired together because they
rewrite the same declarations:

1. **The `hLR` interiority hypothesis was unsatisfiable** — `kvE2_sepHonest_hLR_absurd` certifies
   that every honest evaluation has positive owners in non-interior classes, so the four
   completeness theorems conditional on `hLR` were vacuous. Fix (Part I, Phases 1-5): the
   interior-restricted owner index `kvE2_sepPosI` — a single two-zone order-preserving filter of
   `kvE2_sepPos` — makes interiority a construction invariant of the arrangement index
   (Rabinovich §5, p.7 ψ0/ψ1/φ split), never a hypothesis. `hLR` deleted from all four theorems.

2. **The global-`Nodup` payload conjunct made equality-case order types unrepresentable** —
   honest tie models realized no disjunct (a completeness hole). Fix (Part II, Phases 6-9):
   tie-admitting weak orders. Ties are INDEX-LEVEL data only (strict-quotient guard): the emitted
   disjunct is a strict Def-3.1 bracket, one slot per tie class, point type = the meet of the
   tied types. Forced by Def 3.1 (p.4); Lemma 3.2(1) states the closure without printed proof;
   corroborated by the k=m split (p.7) and Def 7.5 (p.13).

## Phase-by-phase

| Phase | Deliverable |
|---|---|
| 1 | `kvE2_sepPosI` (single two-zone filter; `_mem`/`_subset`/`_zone`/`_nodup`) + transfer-lemma foundation (non-interior owners contribute empty slot blocks) |
| 2 | Slot-family layer `kvE2_sepAllSlots` re-anchored to `kvE2_sepPosI` (value-equal via the flatMap transfer; `kvE2_sepSlotsL/R` deliberately stay over `kvE2_sepPos`) |
| 3 | Arrangement enumeration `kvE2_sepOrderTypes` + membership lemmas re-anchored to the interior index |
| 4 | `kvE2_sepCoincidentOrder` / `kvE2_sepHonestOrder` re-anchored (rank machinery repair); honest-order membership made UNCONDITIONAL |
| 5 | `hLR` deleted from all four completeness theorems; `kvE2_sepDisjunct_extract` restated; exactly one `(hLR :` binder file-wide remains, inside the permanent guard `kvE2_sepHonest_hLR_absurd` (verbatim) |
| 6 | Tie-admitting validity: conjunct (iii) replaced by (iii′) `kvE2_sepAnchorDistinct` + (iv) `kvE2_sepTieRead`; tie-class grouping `kvE2_sepTieGroupedL/R`; foreign-type leaf read `kvE2_sepClosedLeafAt` |
| 7 | Meet-folded grouped disjunct builder `kvE2_sepDisjunct'` (`kvE2_sepClassType` + `_eval_iff`/`_eval_mem`, `kvE2_sepSegsG`); `kvE2_sepBody` rewired; singleton-compat `kvE2_sepDisjunct'_singleton_iff`; singleton-variant `kvE2_sepBody_complete_holds` |
| 8 | F5 foreign-base CLOSED-key discharges (`kvE2_sepClosedLeafAt_discharge`, `_discharge_honest`, `kvE2_sepTieRead_of_discharge`); endpoint/pivot honesty pack (`kvE2_sepEpL/PtW/EpR_eval_of_honest`, public `kvE2_sepProjFresh_eval`) |
| 9 | Tie-reporting honest order: `kvE2_sepSlotHonestVIdx` value-only rank (payload law `kvE2_sepSlotHonestVIdx_eq_iff`: EQUAL indices exactly where honest values coincide), `kvE2_sepHonestOrder'` + `_mem_orderTypes`/`_anchorDistinct`/`_tieRead`/`_mem_arr'`, and the target `kvE2_sepBody_complete_holds'` |

## Phase 9 detail (this session)

- `kvE2_ordRank_eq_iff` (general): under any family, ranks are equal iff values are equal —
  `mpr` definitional, `mp` by trichotomy + `kvE2_ordRank_strictMono`. This single lemma is what
  turns the value-only rank into a TIE-REPORTING payload.
- `kvE2_sepSlotHonestVIdx` drops the slot-index lex tiebreak of `kvE2_sepSlotHonestGIdx`
  (`kvE2_ordRank` needs no injectivity). The banked lex machinery is untouched (new parallel
  definition, as the plan mandates).
- `kvE2_sepHonestOrder'_mem_arr'` conjuncts: (i) `kvE2_sepCoincidentOwner_valid_left/right`
  reused VERBATIM; (ii) `kvE2_sepConsistentBlock_honestV` — own-slot ties cannot occur because
  each owner's region values are strictly separated (`kvE2_sepSlotValue_region_rank_mono`);
  (iii′) the 5A keystone route — distinct anchor VALUES via `nf_eval_unique`, distinct ranks via
  `kvE2_ordRank_eq_iff`; (iv) NOT vacuous (unlike the lex order's): equal ranks give equal honest
  values, the anchor slot's value is `kvE2_sepAnchorVal`, the tied base slot realizes its type at
  that value (`kvE2_sepSlotValue_baseType_spec`), and `kvE2_sepClosedLeafAt_discharge_honest`
  closes the CLOSED-key read.
- `kvE2_sepBody_complete_holds'` (PRIMARY): no `hLR`; owners from `kvE2_sepPosI`; `hdisj` taken
  directly over `kvE2_sepDisjunct' … (kvE2_sepTieGroupedL/R (kvE2_sepHonestOrder' …))` — the
  tie-grouped shape, so genuinely-tied honest models (non-singleton tie classes) are covered.
  The Phase 7 `kvE2_sepBody_complete_holds` is retained; its docstring now marks it as the
  singleton (tie-free degenerate) variant.

## D1/D2/D7 audit corrections (binding citation discipline, applied throughout)

- **D1**: Rabinovich's Lemma 3.2 has NO printed proof ("It is clear that"). No artifact writes
  "per the proof of Lemma 3.2(1)". Sanctioned phrasing used verbatim: tie collapse is *forced by
  Def 3.1 (p.4)*; Lemma 3.2(1) *states the closure without printed proof*; corroborated by the
  k=m split (p.7) and Def 7.5 (p.13).
- **D2**: the k=m split concerns coincident FREE-VARIABLE pinnings at the §5 negation stage —
  cited as corroboration only; the outer points are strictly ordered by `hxw`/`hwt`, so k=m never
  arises in kvE2_sep; admissible ties are witness-level (base-base, base-foreign-anchor).
- **D7**: anchor-anchor tie exclusion (`kvE2_sepAnchorDistinct`) is a Lean-side, machine-checked
  pruning justified by `nf_eval_unique` (distinct positive owners provably cannot share a fresh
  anchor) with NO Rabinovich counterpart — documented exactly as such in every relevant
  docstring, never as paper content.

## Final verification numbers (task-level exit gate, measured post-commit)

| Check | Result |
|---|---|
| `lake build` | GREEN (1720 jobs) |
| Axioms: `kvE2_sepBody_complete_holds'`, `kvE2_sepHonestOrder'_mem_arr'` (+`_tieRead`, `_anchorDistinct`, `_mem_orderTypes`, `kvE2_sepSlotHonestVIdx_eq_iff`), `kvE2_sepBody_complete_holds`, `kvE2_sepBody_complete`, `kvE2_sepCoincidentOrder_mem_arr'`, `kvE2_sepHonestOrder_mem_arr'`, `kvE2_sepHonest_hLR_absurd`, `kvE2_sepHonest_engineInputs`, `kvE2_sepHonest_witnesses`, `kvE2_sepHonestBaseRealizerL/R` | exactly `{propext, Classical.choice, Quot.sound}` (each) |
| `kvE2_sepBracketN_construct` (private, not visible to external `#print axioms`) | compiles in the green build; file has 0 code sorries — axiom-clean by containment |
| `kvE2_sepHonest_hLR_absurd` | VERBATIM (text diff vs `010527e6b` empty) |
| Sorries in landed declarations | 0 (`SharedWitness.lean`/`OuterGate.lean` grep hits are comment-only; repo-wide census 163, all pre-existing outside task files) |
| `kvE_sub2_` open-key marker count (F5) | **107** (== baseline cap) |
| `x1 <` count (LITMUS) | **73** (== baseline cap) |
| `kvE2_sepPosI_eq_pos` | 0 repo-wide (vacuity bridge never recreated) |
| `(hLR :` binders | exactly 1 (the guard) |
| `ExistsForallNF.lean` / `NavigatedSpine.lean` / `OuterGate.lean` | diff EMPTY vs `1e5d3420c` |
| Vacuous-definition scan | 1 (pre-existing Examples baseline) |
| `^axiom` count in Theories/ | 2 (baseline; no new axioms) |
| Sorry inventory | EMPTY (no strategic sorries; `skeleton: false`) |

## Hand-off to task 337

The parent task's `.holds` builder should target `kvE2_sepBody_complete_holds'`: construct the
realization of the grouped disjunct
`kvE2_sepDisjunct' charBase charK qnf (kvE2_sepTieGroupedL (kvE2_sepHonestOrder' …)) (kvE2_sepTieGroupedR (kvE2_sepHonestOrder' …))`
from the honest engine inputs (`kvE2_sepHonest_engineInputs`, `kvE2_sepBracketN_construct`,
`kvE2_sepClassType_eval_iff`, and the endpoint/pivot honesty pack from Phase 8 (b)).
