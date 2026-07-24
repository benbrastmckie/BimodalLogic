import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.Base
import Bimodal.Metalogic.WeakCanonical.Kamp.Boneyard.NfMultiAnchorBridgeRetired.Lemma32Reduction
import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.CarrierKv

/-!
# ARCHIVED — refuted single-point `EndCharCarrier → TemporalPred` scaffold (task 349, v6 rebase)

**This module is dead code.** It holds the refuted single-point navigated endpoint scaffold that
was moved off the live `NavigatedEndChar.lean` declaration surface during the task-349 v6 archival
swap (plan `06_faithful-two-endpoint-carrier.md`, Phase 1). Nothing on the critical path depends on
it. Retained only so the historical construction and the machine-checked non-theorem narrative stay
compiled (they do not rot) while the faithful two-endpoint carrier is rebuilt in `CarrierK1V.lean`.

## Why it was retired (4th strike; reports 04 / 06 / 07)

The single-point carrier reads a closed `TemporalPred`/`Formula` at ONE navigated witness `w` and
tries to certify the arity-3 characterization `nf_eval_nf M k 3 (zoneEnv3 w x t) qnf` at the free
enclosing anchors `{x, t}`. Two converging audits proved this UNFAITHFUL:

* **report 04** — `navPieceForm_correct` (the inner-`Formula` converter's correctness biconditional)
  is a machine-checked NON-THEOREM by parameter independence: a closed `Formula` read only at `w`
  cannot see the anchor predicate/order layer at `x, t`.
* **report 06** (`06_phase3-gate-adjudication.md`) — the `k+1` step correctness `endChar_correct_step`
  reduces exactly to that non-theorem residual-threading obligation (the FEASIBILITY GATE `[BLOCKED]`
  narrative below); no residual is threadable from the in-scope `h_res`.
* **report 07** (`07_rabinovich-faithfulness-deep-check.md`) — the discriminator is the two-endpoint,
  `x,t`-EXPLICIT carrier `BracketEndCharCarrierV := NormalForm sig k 3 → VVecEA2` (CarrierK1V:365),
  green at k=0 and k=1, which is immune to the parameter-independence refutation.

The forbidden unconditional world-local form is `endCharN0_correct_infeasible` (Base.lean:1779).

## What lives here (all green / sorry-free as defs; the non-theorems are NEVER asserted)

* `navPieceForm` — the refuted inner-`Formula` converter def (its `_correct` is the report-04
  non-theorem, NOT stated).
* `endCharStep` / `endChar` — the single-point recursion skeleton built over `navPieceForm`.
* `endChar_correct_zero` — the (genuinely green) `k=0` base; superseded by the two-endpoint
  `bracketEndChar_k0_correct` on the faithful path.
* the Phase-3b-v5 FEASIBILITY-GATE narrative for `endChar_correct_step` (a doc-comment only; the
  `[BLOCKED]` non-theorem is never asserted).

## Demand-driven Boneyard restore rule (recorded, not executed in Phase 1)

The faithful arity-2 two-endpoint carrier references NONE of the four `Kamp/Boneyard/` files today
(`NegationIndep`, `RabinovichTranslation`, `EAVecNegationClosure`, `VecEA_m`). Per the v6 plan,
`NegationIndep` (`neg_vecEA2_indep`) and `RabinovichTranslation` are zero-cost restore-on-demand
candidates: restore ONLY at first genuine code reference in Phases 3-4. Leave `EAVecNegationClosure`
/ `VecEA_m` (arity-m) and the `NfZone*Probe` files archived. No restore is forced now.
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical
open Bimodal.Metalogic.WeakCanonical.Separation

/-! ## Phase 3 (task 349): arity-3 inner-realizability navigator `navPieceForm` / `_correct`
(the load-bearing core)

`navPieceForm` is the closed-`Formula` converter that discharges the depth-`(k+1)`
inner-realizability obligation `h_inner` of `nf_char3_endpoint_tl_correct` (Base.lean:885): for
each arity-4 `sub`, its `temporal_truth` at the navigated point `y` characterizes the coupled
inner existential `∃ w, nf_eval_nf M k 4 (Fin.cons w (zoneEnv3 y x t)) sub`.

### Design (SETTLED — plan v4 Phase 3)

The arity-4 inner `nf_eval_nf` is reduced to arity-`≤3` pieces by task 351's
`nfEval_le2_reduction` (`nfEval3_reduction`, the Rabinovich Lemma 3.2(2) reduction) **under a
single shared witness** — the witness `w` stays OUTSIDE the reduced inner form (order-theoretic
`∃w ∀ij` merge, never a per-pair `∀ij ∃w` distribution). Each resulting arity-3 realizability
piece is NAVIGATED over its enclosing anchor pair by the green two-anchor navigation form
`nf_zone_flatten_navigable` (Base.lean:667) via the arity-3 bridges `nfEval_pair_arity3_flatten`
(Lemma32Reduction.lean:318) and `nfEval_pair_arity3_interior` (:344), with BOTH endpoint hooks
`pastEnd`/`futureEnd` instantiated to the parametric depth-`(k-1)` arity-3 IH `rec`. Navigation
NEVER climbs past anchor arity 3.

`navPieceForm rec sub` is assembled as the disjunction of the two navigated `bracketBuild*`
chains (`bracketBuildLeft` walking into the past exterior, `bracketBuildRight` into the future
exterior) whose interior is the genuine non-trivial β-segment `seg rec q3` (G3 — never
`TemporalPred.top`) and whose exterior endpoints are `rec q3`, where `q3 := nfk_take (3 ≤ 4) sub`
is the arity-3 prefix restriction of the arity-4 `sub` (CarrierKv.lean:70). Every deeper witness
is a bracket witness, never a free anchor; the free-anchor set stays `{x, t}` (G2/G4), arity
capped at 3.

### Route audit
- **G1** — no arity-1 collapse: `q3` is arity 3, every navigated `nf_eval_nf` residual is arity 3.
- **G2/G4** — `w` and every bracket witness ride `Until`/`Since` brackets, never a third free
  anchor; anchors `{x, t} ⊆ {x, t}`, `≤ 2`.
- **G3** — the interior slot is the non-trivial `seg rec q3`, never `TemporalPred.top`.
- **G5** — the correctness is assembled by manual `exists_congr`/`or_congr`/`and_congr_right`
  bridges over the reduction and the two navigated-reach pillars; no `simp`/`omega`/`aesop`
  shortcut of a Rabinovich chain step.
- **FORBIDDEN** — no `nf_char3_deeper_split` (would grow the anchor set to 4); no per-pair
  `∀ij ∃w` distribution; no arity-collapsing quant `nfRestrict`; no free-standing `NavResidual`. -/

/-- **Arity-3 inner-realizability navigator** (task 349 Phase 3, load-bearing core). The closed
`Formula` whose `temporal_truth` at a navigated point captures the arity-4 inner realizability
`∃ w, nf_eval_nf M k 4 (Fin.cons w (zoneEnv3 y x t)) sub`, by NAVIGATING the arity-3 pieces of the
task-351 reduction over the enclosing anchor pair. Parametric in the depth-`(k-1)` arity-3 IH hook
`rec : NormalForm sig k 3 → TemporalPred` (used for BOTH exterior endpoints). Assembled as the
disjunction of the past-exterior `bracketBuildLeft` and future-exterior `bracketBuildRight`
navigated chains, each carrying the non-trivial β-segment `seg rec q3` as its interior (G3) and
`rec q3` as its exterior endpoint, where `q3 = nfk_take (3 ≤ 4) sub` is the arity-3 prefix
restriction of `sub`. Arity capped at 3 (G1/G4); witnesses are bracket witnesses (G2). -/
noncomputable def navPieceForm {sig : MonadicSignature} {k : Nat}
    (rec : NormalForm sig k 3 → TemporalPred)
    (sub : NormalForm sig k 4) : Formula :=
  let q3 : NormalForm sig k 3 := nfk_take (by omega : 3 ≤ 4) sub
  Formula.or
    (bracketBuildLeft (seg rec q3) (rec q3))
    (bracketBuildRight (seg rec q3) (rec q3))

/-! ### Phase 3b (correctness `navPieceForm_correct`) — DEFERRED, contingency-triggered

The correctness biconditional `temporal_truth M atomMap y (navPieceForm rec sub) ↔
∃ w, nf_eval_nf M k 4 (Fin.cons w (zoneEnv3 y x t)) sub` is NOT landed in this dispatch. The
`lean_goal`-verified reduced target (via `navPiece_reduce`) is

```
⊢ (∃ w, nfEvalRHS M k 4 (Fin.cons w (zoneEnv3 y x t)) sub)  ↔  temporal_truth M atomMap y (navPieceForm rec sub)
```

whose LHS atom layer ranges over ALL pairs `(i, j) : Fin 4` — i.e. the FOUR anchors `{w, y, x, t}`
of the env `Fin.cons w (zoneEnv3 y x t)` — plus, at `k+1`, an arity-5 quant layer. Navigating this
full Fin-4 pairwise/quant structure into a single closed `Formula` read at `y` requires an
**arity-4-enclosing-pair navigation bridge** (a disjunction over the possible enclosing pairs
threading the single witness `w` through the linear order), which is NOT among the green consumed
assets (`nfEval_pair_arity3_flatten`/`_interior` navigate a FIXED arity-3 pair only, and the
single-pair arity-4→3 bi-implication is machine-checked a NON-THEOREM — Lemma32Reduction.lean:290-306).
Per the plan v4 Phase-3 Contingency Trigger, this is recorded for a dedicated follow-up (`/spawn 349`
for the missing arity-4-enclosing-pair navigation bridge) rather than closed by a collapse, a
single-anchor reshape, a per-pair `∀ij ∃w` distribution, or a mis-stated/vacuous theorem. The
`navPieceForm` def (above) and `navPiece_reduce` (the SETTLED witness-outside reduction step) are the
landed, green, sorry-free 3a deliverables; the def structure is expected to be enriched alongside the
new bridge. -/

/-! ## Phase 1 (task 349, v5): residual-conditioned spec freeze + `endChar` skeleton + base case

**Faithful v5 architecture (report 05 §3).** This section supersedes the v4 Phase-3 interface (the
refuted inner-`Formula` `nf_char3_endpoint_tl` / `navPieceForm_correct` converter — a machine-checked
NON-THEOREM by parameter independence, report 04 — DELETED from the critical path). The v5 recursion
reduces the arity-4 inner existential to a ≤2-anchor conjunction FIRST (consuming the green
`navPiece_reduce` / `nfEval_le2_reduction`), characterizes each conjunct with the Prop-valued,
x,t-EXPLICIT `nf_zone_flatten_navigable_correct` (Base.lean:687), rides the bounded interior on the
non-trivial `seg` (G3), and collapses to a closed `Formula` ONLY at the base `endChar0` (Step D).

### FROZEN spec — `endChar_correct` (report 05 §3.2; residual-conditioned, x,t-EXPLICIT)

Stated at EVERY depth `k` carrying the anchor-residual `h_res` (generalizing the green base
`endChar0_correct`, Base.lean:1056). Pinned here; CLOSED in Phase 4 by induction on `k` (base =
`endChar_correct_zero` below; step = the Phase-3 `endCharStep` k+1 discharge):

```
theorem endChar_correct {sig} (M) (atomMap)
    (h_surj : ∀ p, ∃ a : Atom, atomMap (.atom a) = p) :
    ∀ (k : Nat) (qnf : NormalForm sig k 3) (w x t : M.carrier)
      (h_res : ∀ atom : AtomKind sig 3, (∀ p, atom ≠ AtomKind.pred p 0) →
        (atom_eval M (zoneEnv3 w x t) atom ↔ (qnf atom = true))),
    (endChar atomMap h_surj k qnf).eval_at M atomMap w ↔
      nf_eval_nf M k 3 (zoneEnv3 w x t) qnf
```

**FORBIDDEN — the unconditional world-local form** (`endCharN0_correct_infeasible`, Base.lean:1779):
`(endChar k qnf).eval_at M atomMap y ↔ nf_eval_nf M k 3 (zoneEnv3 y x t) qnf` for ARBITRARY,
x,t-IMPLICIT anchors is a machine-checked NON-THEOREM (counterexample narrative Base.lean:1036-1047):
a closed navigated-`w` `TemporalPred`, read only at `w`, cannot certify the predicate/order layer at
the free anchors. The discriminator (report 05 §5.2) is the pair: (i) `h_res` — supplying the
anchor predicate/order residual the world-local read cannot see — and (ii) `x, t` appearing
EXPLICITLY as parameters so `h_res` pins `{x, t}` (≤2 anchors, G2/G4; `w` a bracket witness, never a
third free anchor). Re-freezing the unconditional/x,t-implicit shape is FORBIDDEN.

### Skeleton (report 05 §3.3)

```
endChar 0     qnf = endChar0 atomMap h_surj qnf                     -- closed-Formula collapse only at base
endChar (k+1) qnf = endCharStep atomMap h_surj (endChar k) qnf      -- Phase-2/3 navigated builder (hole)
```
-/

/-- **`endCharStep` — recursion step builder (Phase 3, task 349 v5; report 05 §3.3/§3.4).** The
depth-`(k+1)` navigated endpoint builder consuming the depth-`k` interior/exterior hook
`rec : EndCharCarrier sig k`. Read at the navigated witness `w`, the returned `TemporalPred`
assembles — as a single closed `Formula` — the depth-`(k+1)` characterization of
`nf_eval_nf M (k+1) 3 (zoneEnv3 w x t) qnf`, whose `nfEval_step_unfold_gen` unfolding splits into:

* the **atom layer** — supplied by the position-0 locus `endChar0 atomMap h_surj qnf.1` (Step D,
  the closed-`Formula` Prop-3.5 collapse at the base; anchor positions pinned by `h_res` in the
  correctness proof); and
* the **quant layer** `∀ sub : NormalForm sig k 4, (∃ v, nf_eval_nf M k 4 [v,w,x,t] sub) ↔
  qnf.2 sub` — encoded as the finite conjunction (`formula_conjList` over the `Fintype`
  `NormalForm sig k 4`) of per-`sub` clauses `nf_quant_clause_tl (navPieceForm rec sub) (qnf.2 sub)`.
  Each per-`sub` inner existential is navigated by `navPieceForm rec sub` (report 05 §3.4 Steps B/C:
  the disjunction of the past-exterior `bracketBuildLeft` and future-exterior `bracketBuildRight`
  navigated chains, each carrying the non-trivial β-segment `seg rec q3` as interior — G3 — and
  `rec q3` as exterior endpoint, `q3 := nfk_take (3 ≤ 4) sub`).

Assembled from `bracketBuildLeft`/`bracketBuildRight` (navigation, via `navPieceForm`), `seg`
(interior, via `navPieceForm`), and the position-0 locus (`endChar0`), arity capped at 3 (G1/G4;
witnesses `v`/bracket witnesses never free anchors — G2). This CONSUMES the retained-green
`navPieceForm` **def** (NavigatedEndChar.lean:196; only its `_correct` biconditional is forbidden —
the report-04 non-theorem — and is NOT stated here). It replaces the v4 Phase-1 scaffold
(`fun qnf => endChar0 … qnf.1`) fix-forward (`_rec` → `rec`). The `k+1` correctness discharge is the
Phase-3 residual-threading feasibility gate. -/
noncomputable def endCharStep {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    {k : Nat} (rec : EndCharCarrier sig k) : EndCharCarrier sig (k + 1) :=
  fun qnf =>
    ⟨formula_conjList
      ((endChar0 atomMap h_surj qnf.1).formula ::
        (Finset.univ.toList : List (NormalForm sig k 4)).map
          (fun sub => nf_quant_clause_tl (navPieceForm rec sub) (qnf.2 sub)))⟩

/-- **The recursive navigated arity-3 endpoint primitive `endChar` (skeleton, report 05 §3.3).** Base
`endChar 0 = endChar0` (the closed-`Formula` Prop-3.5 collapse, ≤1 free); step
`endChar (k+1) = endCharStep (endChar k)` (the Phase-2/3 navigated builder). Arity fixed at 3 (G1: no
arity-1 collapse; closed-`Formula` read occurs only at the base). The step body is the Phase-1
scaffold until Phase 3 installs the real navigated builder; the recursion structure is frozen here so
Phases 2–4 dispatch against a stable definition. -/
noncomputable def endChar {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p) :
    (k : Nat) → EndCharCarrier sig k
  | 0 => endChar0 atomMap h_surj
  | (k + 1) => endCharStep atomMap h_surj (endChar atomMap h_surj k)

/-- **Base case (`k = 0`) of the frozen `endChar_correct` (report 05 §3.2), sorry-free.** Under the
anchor-residual `h_res`, the navigated base `endChar … 0 qnf` (which unfolds definitionally to
`endChar0 … qnf` by the `Nat`-recursion zero branch) read at `w` is equivalent to the FULL depth-0
arity-3 atom layer `nf_eval_nf M 0 3 (zoneEnv3 w x t) qnf`. This is DEFINITIONALLY the green
`endChar0_correct` (Base.lean:1056). It is the base building block Phase 4 feeds to the induction on
`k`; `x, t` are EXPLICIT and `h_res` pins the `{x, t}` residual (≤2 anchors, G2/G4; `w` a bracket
witness), NEVER the refuted unconditional world-local form. -/
theorem endChar_correct_zero {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (qnf : NormalForm sig 0 3) (w x t : M.carrier)
    (h_res : ∀ atom : AtomKind sig 3, (∀ p : sig.preds, atom ≠ AtomKind.pred p 0) →
      (atom_eval M (zoneEnv3 w x t) atom ↔ (qnf atom = true))) :
    (endChar atomMap h_surj 0 qnf).eval_at M atomMap w ↔
      nf_eval_nf M 0 3 (zoneEnv3 w x t) qnf :=
  endChar0_correct M atomMap h_surj qnf w x t h_res

/-! ## Phase 3b (task 349, v5): `k+1` correctness discharge — FEASIBILITY GATE **[BLOCKED]**

The `k+1` case of the frozen `endChar_correct` spec — the residual-threading feasibility gate
(report 05 §5.1 claim 6, FEASIBLE-PENDING-RESIDUAL-THREADING) — is **NOT landed** in this dispatch.
The `endCharStep` **def (3a) is green above**; the step-correctness **proof (3b) is blocked** on a
machine-located obligation that, as a closed biconditional, is the report-04 non-theorem.

### The pinned `k+1` statement (typechecks; NOT asserted here)

```
theorem endChar_correct_step {sig} {k}
    (M) (atomMap) (h_surj : ∀ p, ∃ a : Atom, atomMap (.atom a) = p)
    (rec : EndCharCarrier sig k)
    (ih : ∀ (q : NormalForm sig k 3) (w' x' t' : M.carrier),
      (∀ atom : AtomKind sig 3, (∀ p, atom ≠ AtomKind.pred p 0) →
        (atom_eval M (zoneEnv3 w' x' t') atom ↔ (NormalForm.atom_assgn q atom = true))) →
      ((rec q).eval_at M atomMap w' ↔ nf_eval_nf M k 3 (zoneEnv3 w' x' t') q))
    (qnf : NormalForm sig (k + 1) 3) (w x t : M.carrier)
    (h_res : ∀ atom : AtomKind sig 3, (∀ p, atom ≠ AtomKind.pred p 0) →
      (atom_eval M (zoneEnv3 w x t) atom ↔ (qnf.1 atom = true))) :
    (endCharStep atomMap h_surj rec qnf).eval_at M atomMap w ↔
      nf_eval_nf M (k + 1) 3 (zoneEnv3 w x t) qnf
```

The `ih` hook is the depth-`k` IH (residual form, worded via the depth-uniform `NormalForm.atom_assgn`
accessor); `h_res` pins the top-level `qnf.1` atom layer at `{x, t}` (≤2, G2/G4; `w` a bracket witness).

### Where the proof reaches, and the exact stuck goal (verbatim `lean_goal`)

Driving `simp only [endCharStep, TemporalPred.eval_at]; rw [formula_conjList_iff,
nfEval_step_unfold_gen, List.forall_mem_cons]; refine and_congr ?_ ?_` splits into:

* **Atom layer (Step D)** — `temporal_truth w ((endChar0 … qnf.1).formula) ↔
  ∀ a, atom_eval M (zoneEnv3 w x t) a ↔ qnf.1 a = true` — DISCHARGEABLE (`endChar0_wlocus_correct`
  + `h_res`, exactly as `endChar0_correct`). NOT the gate.
* **Quant layer** — after `rw [List.forall_mem_map]; forall_congr'` per `sub : NormalForm sig k 4`
  and `nf_quant_clause_tl_correct` (with `P := ∃ v, nf_eval_nf M k 4 (Fin.cons v (zoneEnv3 w x t)) sub`),
  the residual side-obligation is, **verbatim**:

  ```
  ⊢ temporal_truth M atomMap w (navPieceForm rec sub) ↔
      ∃ v, nf_eval_nf M k 4 (Fin.cons v (zoneEnv3 w x t)) sub
  ```

### Why this is BLOCKED (not stubbable)

This side-obligation is **exactly `navPieceForm_correct`** — the machine-checked report-04
NON-THEOREM as a closed biconditional. LHS `temporal_truth M atomMap w (navPieceForm rec sub)` is a
CLOSED `Formula` read only at `w` (depends solely on `M`, `atomMap`, `w`); RHS `∃ v, nf_eval_nf M k 4
[v,w,x,t] sub` constrains the anchor-`{x,t}` predicate layers and the order relations among
`{v,w,x,t}`. It holds only UNDER a residual pinning those anchors for THIS `sub`'s arity-4 layer — and
that per-`sub` residual is **not threadable** from the in-scope `h_res` (which conditions only the
depth-0 atom layer of the top-level `qnf` at `{x,t}`, not the arity-4 sub-evaluation at the fresh
witness `v`). Discharging it would require a **residual-threading lemma** delivering, for each `sub`,
the anchor/order residual of `nf_eval_nf M k 4 [v,w,x,t] sub` from the bracket-exterior structure — the
sole open obligation of the v5 architecture (report 05 §5.1 row 6, §5.2).

Landing it via `sorry`, a vacuous def, an arity-4 enclosing-pair collapse
(`Lemma32Reduction.lean:290-306` non-theorem), a single-anchor reshape, a per-pair `∀ij ∃v`
distribution, or by asserting `navPieceForm_correct`/the unconditional world-local form is FORBIDDEN
(plan Postmortem Constraints). Escalated via `/spawn 349` for a dedicated residual-threading lemma.
The `endCharStep` def (3a) and all Phase-1/2 assets remain green and sorry-free. -/

end Bimodal.Metalogic.WeakCanonical.Kamp
