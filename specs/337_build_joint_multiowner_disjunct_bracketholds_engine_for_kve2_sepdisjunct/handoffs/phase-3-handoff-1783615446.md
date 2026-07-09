# Task 337 Phase 3 Handoff — cycle 11 (sess_1783610916_b79fd5)

## Immediate Next Action
Do NOT re-dispatch Phase 3 as planned. The Phase-3/4 hypothesis package `h ∧ hLR` is
UNSATISFIABLE — machine-checked, landed green + axiom-clean as
`kvE2_sepHonest_hLR_absurd` (SharedWitness.lean, commit `050f32650`). Spawn an upstream
interface-redesign task (affects the shape of `kvE2_sepBody_complete` /
`kvE2_sepBody_complete_holds` / this task's Phases 3–4) before any further 337 dispatch.

## The finding (four-element defect bar)

1. **Counterexample (machine-checked, universal)**: for ANY honest instance, the
   characteristic depth-1 type `σ_w := nf_characteristic M 1 4 (Fin.cons w (Fin.cons w
   (Fin.cons x (fun _ => t))))` is realized with witness `x1 := w`
   (`nf_characteristic_satisfies`, NormalForm.lean:224). `h`'s quantifier layer
   (`nf_eval_nf` depth-2, NormalForm.lean:203-207) then forces `qnf.2 σ_w = true`, so
   `σ_w ∈ kvE2_sepPos qnf`. Its ordering channel at the `w`-coordinate is `(false, false)`
   (`w < w` irreflexive; `nf0_zoneSpec`, NfEFold.lean:153), while `kvE2_sep_zXW3` /
   `kvE2_sep_zWT3` demand `(true, false)` / `(false, true)` there → `hLR σ_w` is refuted.
   The same construction at `x1 := x` / `x1 := t` populates `zAtX3` / `zAtT3`: every honest
   `qnf` has positive owners in at least three non-interior classes.
2. **Current behavior**: every hLR-conditional completeness theorem —
   `kvE2_sepBody_complete` (task 336), `kvE2_sepCoincidentOrder_mem_arr'` (337 v3 asset),
   `kvE2_sepBody_complete_holds` (task 340 Phase 5D), and the planned Phase-3/4 builders —
   is vacuously true: no instance satisfies its hypotheses. Task 335's planned consumption
   of `kvE2_sepBody_holds_of_honest` can never be instantiated.
3. **Required behavior**: a completeness statement whose hypotheses admit honest instances:
   the boundary/self-zone positive classes (`zAtX3`/`zAtW3`/`zAtT3` minimum; `zPastX3`/
   `zFutT3` when populated) must be CARRIED by the endpoint/pivot literal machinery
   (`kvE2_sepEpL`/`kvE2_sepEpR`/`kvE2_sepPtW` already enumerate their `kvE2_sepHasPos`
   bits) rather than excluded by hypothesis. The realization obligation for `kvE2_sepPtW`'s
   `zAtW3` `charK` literals then becomes POSITIVE at exactly the honesty-forced owners.
4. **Isolation**: the defect is the `hLR` hypothesis SHAPE (introduced at task 336's
   `hL → hLR` generalization), not any single lemma's proof. All landed proofs remain
   correct as stated; the carrier (334/338/339/340) is untouched.

## Secondary design caution (for the redesigned interior fragment)

Even with a satisfiable interior restriction, the joint bracket demands a STRICTLY
monotone per-slot witness family (`IntervalPattern.holds_eq_succ`, ExistsForallNF.lean:188),
but the slot lists `kvE2_sepSlotsLOf/ROf wo` are the FULL per-slot multiset for every
`wo ∈ kvE2_sepArr'`, and honest models need not provide distinct realizers per slot:
(a) two same-type slots of different owners (`.lXU σ χ` and `.lXU σ' χ`, both forced
positive by honest completeness of `σ'`) can share a SINGLE χ-realizing point;
(b) a base slot value can coincide with a foreign anchor (cycle-8's own "resolution (a)
is FALSE in general"). Either tie makes the full-multiset bracket unrealizable by any
strict witness family. The redesign therefore also needs coincidence-MERGED slot lists
(the §5 meet realized at the FORMULA level — merged point types at tied positions) or a
model-side distinct-realizer guarantee. Rabinovich's Def 7.13 multi-owner UNION (dedup)
is the paper-side analogue.

## Current State
- Phases 1–2 remain COMPLETE and green. Phase 3 is [BLOCKED] (plan updated with the full
  blocker note). Phases 4–5 NOT STARTED (blocked transitively).
- New green + axiom-clean (`{propext, Classical.choice, Quot.sound}`) additions to
  SharedWitness.lean, all additive, zero sorries:
  - `kvE2_sepBracketN_construct` (commit `c4b31500d`) — the generic N-slot bracket
    construction (mpr dual of `kvE2_sepDisjunct_extract`; lift of `k1v_bracket_construct3`):
    all six `holds_eq_succ` obligations discharged from list-shaped inputs (combined
    strictly-sorted witness list `usL ++ w :: usR`, per-index point types, pivot `ptW`,
    three gap-shape segment families). REUSABLE under any redesign — this is the
    bracket-entangled structural core Phase 3 was sized around.
  - `kvE2_sepHonest_hLR_absurd` (commit `050f32650`) — the inconsistency certificate.
- Full `lake build` GREEN (1720 jobs). sorry count in SharedWitness.lean: 0.
- All 334/336/338/339/340 INPUT declarations byte-for-byte untouched (additive-only diff).

## Key Decisions (this dispatch)
1. Landed the generic construction lemma FIRST (green checkpoint) before the honest
   instantiation, per the plan's overflow directive.
2. During per-slot witness analysis, the strict-monotonicity tie obstruction (secondary
   caution above) triggered adversarial re-verification of the hypothesis package instead
   of continuing to build against it; that produced the inconsistency finding.
3. Did NOT close Phase 3 via `(kvE2_sepHonest_hLR_absurd …).elim`: a vacuous close would
   satisfy the letter (sorry-free) but violate F2 (non-vacuous realizers), which is part
   of this phase's own acceptance gate, and would hand task 335 an uninstantiable lemma.
   BLOCKED + redesign flag is the truthful outcome.

## Sorry Inventory
[] (empty — zero sorries introduced; pre-existing EANegation.lean:834,1129 (task 305) and
Boneyard/ legacy sorries are out of scope and untouched)

## References
- Plan: specs/337_.../plans/04_joint-disjunct-holds-codesign.md (Phase 3 BLOCKED note has
  the full defect documentation)
- Evidence lemma: SharedWitness.lean `kvE2_sepHonest_hLR_absurd` (directly before the
  "O3 extraction theorems" section)
- Structural core: SharedWitness.lean `kvE2_sepBracketN_construct` (same section)
- Phase-2 handoff: handoffs/phase-2-handoff-1783610916.md (banked assets list)
