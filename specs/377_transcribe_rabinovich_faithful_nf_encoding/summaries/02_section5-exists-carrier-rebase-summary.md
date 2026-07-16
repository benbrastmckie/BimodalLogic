# Implementation Summary — Phase 9 (terminal)

**Task**: 377 `transcribe_rabinovich_faithful_nf_encoding` | **Phase**: 9 of 9 (terminal)
**Session**: `sess_1784164229_854c1a` | **Date**: 2026-07-15 | **Commit**: `346946c13`
**Outcome**: **Adjudicated — the residual stands.** The plan's expected second terminus.

---

## Phase executed

**Phase 9: Retire KampPrior.lean:520, or adjudicate it** -> `[COMPLETED]` via adjudication.

Phases 6-8 remain `[DEFERRED]` to task 378 per user directive; not attempted. Phase 9 depends only
on Phases 1 and 5 (plan lines 680-683), both landed, so the adjudication is complete on its own
terms and is not contingent on 6-8.

## Theorems/lemmas proved

No theorem in `Theories/` was proved or altered this phase — correctly. The phase's sanctioned
deliverable is an evidenced adjudication, and the residual's in-code note carries an explicit
"Do NOT discharge here". Two machine-checked probe theorems were landed as report artifacts:

| Theorem | File | Result |
|---|---|---|
| `nf4_not_pathShaped` | `reports/05_...probe.lean` | `¬ PathShaped (nfCouples 4)` — axiom-free |
| `nf2_pathShaped` | `reports/05_...probe.lean` | `PathShaped (nfCouples 2)` — axiom-free |

## What was found

1. **The ownership chain is dead end-to-end.** The in-code note named task 358; 358 is abandoned,
   374 completed by transferring to 376, and 376 is abandoned. The note named a non-existent owner.
2. **The note also mis-described the obstruction** — the more important finding. It is not a
   "frozen-interface gap" but an **arity cap**. The `rungK` gate *carries* an arity-4 joint
   realization obligation guarded only by a unary point type. Consumer binds
   `charF : NormalForm sig j 1 -> Formula`; the only producer binds
   `charFib : NormalForm sig j 4 -> Formula`, and that producer is unwired, circular, and
   fiber-refuted.
3. **Rabinovich has no arity-4 object** (Def 3.1 p.4: one variable; Lemma 3.2(2) p.4: <=2 free
   variables; Def 4.1 p.5: unary E[Σ]). The frozen producer's unarity is **faithfulness**, not a
   defect. This is the same defect that abandoned task 376.
4. **The `chain_split` probe was executed** and is non-applicable at *all seven* zones — its
   precondition is a path constraint graph, but an arity-4 NF is the complete graph K₄.
5. **Positive**: the trichotomy assembly (`:250`) is already general in `k`, as is the `rungK`
   gate. Only the per-`k` arm triple is missing.

## Final verification

| Gate | Result |
|---|---|
| `lake build` | **EXIT 0, 1766 jobs** = baseline |
| Sorry census over `Kamp/` (tactic-position) | **5 = baseline**; 3 live gate + 2 dead Boneyard. **Zero added** |
| `#print axioms nf_nvar_exist_all_depths` | `[propext, sorryAx, Classical.choice, Quot.sound]` = Phase 1 baseline verbatim; `sorryAx` persists |
| `#print axioms completeness_discrete` | `sorryAx` present — **DoD terminal check NOT met** |
| Preserved arms (`arm_k0`, `arm_k1`, `rungK_gate_match`) | each `[propext, Classical.choice, Quot.sound]` — unregressed |
| Probe `05_...lean` | EXIT 0, axiom-free |
| Vacuous definitions | 0 |
| New axioms | 0 |
| Files deleted | 0 |
| Feferman-Vaught attempted | **No** |
| Novel mathematics attempted | **No** |

## Sorry inventory

Unchanged from baseline — the amended gate exactly (`e74f129d1`):
`KampPrior.lean:520` (re-adjudicated; now UNOWNED), `EANegation.lean:1090`, `EANegation.lean:1249`
(both untouched, out of scope, ruled unfixable). Plus 2 dead in `Boneyard/`.

## Plan deviations

- **Phase 9's central instruction was void.** "Confirm task 358 is the correct owner" cannot be
  executed — 358 is abandoned. Re-scoped to adjudicating the gating rationale on its own terms and
  recommending a live owner. Annotated inline in the plan.
- **The dispatch's zone framing was inverted.** It suggested `chain_split` on non-interval zones
  assuming interval zone 3 was already discharged; the landed code is the reverse. Immaterial to
  the verdict — every zone's fiber is arity-4.

## Task-level consequence

**Task 377 cannot reach `completed` via its own DoD.** The remaining half requires a
re-architecture with no live owner. Recommendation: close 377 as **PARTIAL** with its landed
deliverables recorded, and spawn a new owner for the unary-E[Σ] re-architecture, sequenced after
378 — **not** filed into 378, 375, or 361. Full justification: `reports/06_...md` §6.
