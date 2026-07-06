import Bimodal.Metalogic.WeakCanonical.Kamp.NfZoneFlattenNavigable
-- NOTE (task 307 Phase 7): `import ...KampPrior` was REMOVED to break the import cycle that blocked
-- wiring this bridge into `KampPrior.lean:391`. The two symbols this file used from KampPrior
-- (`nf_quant_clause_tl`/`_correct`, `atomKind_arity1_is_pred`) were relocated to
-- `NfDepth0Generalized` and reach here transitively via `NfZoneFlattenNavigable`.

/-!
# Multi-Anchor Characteristic Formula Bridge (task 308)

A new **leaf** file (nothing imports it; it imports nothing beyond
`NfZoneFlattenNavigable` — which transitively pulls `VecEATranslation`,
`NfZoneDepthK`, `NfDepth0Generalized` — and `KampPrior`). It hosts the
sorry-free depth-graded two-anchor characteristic-formula bridge deliverables.

## Deliverables (built across the task-308 phases)
1. `nf_char2_formula : NormalForm sig (k+1) 2 → Formula` (Phase 3).
2. `nf_zone_flatten_navigable` at arbitrary depth `k` (Phase 5).

## This file — Phase 1 (bottom-of-recursion bases)
- `nf_char2_atom_layer`: the **diagonal depth-0 atom-layer** iff — the depth-0
  characteristic formula of an arity-1 NF characterizes the arity-2 evaluation of
  its diagonal value-duplication `diagDup` on the constant env `[t,t]`. Built from
  `nf_depth0_char_formula` + `diagDup_eval_zero` (i.e. `renameNF_eval_diag0`).
- `nf_zone_flatten_navigable_zero`: the `k = 0` base of deliverable 2 — the arity-3
  tail-diagonal existential of a duplicated NF `diagDup3` on `[w,t,t]` equals the
  arity-2 existential on `[w,t]`. Endpoints are atom/anchor types via
  `renameNF_eval_diag0`; **no `bracketBuild*` navigation yet**.

## Postmortem forbidden-route list (BINDING — read before writing any construction)

Every future dispatch on this file MUST check each candidate construction against
these three refuted routes (task-305 Phase-11b lineage + task-307 blocker audit):

- **(a) Do NOT** re-attempt a projection-based VecEA2 bridge for the `x=t` diagonal
  case. `liftIdx(totalUnskip)` is non-injective; the coupled quant layer does not
  factor through per-variable projections. Split the coupled `∃w` **directly** on the
  full env `[w,x,t]` (`exists_nested_split3` / `exists_trichotomy_split`) and discharge
  through `nf_char3_eq_succ_iff`'s joint decomposition — never per-variable projection.
- **(b) Do NOT** re-attempt a flat single-interval atomic bracket absorption. A depth-0
  atomic `BracketFormula` is confined to `[x,t]` and cannot capture exterior-`w`
  realizability. Endpoint types MUST be **navigated** recursive `bracketBuild*`
  `TemporalPred`s, not depth-0 atomic brackets.
- **(c) Do NOT** re-attempt an arity-1-collapse repair for the diagonal arm
  (`char_k1 (diagCollapse sub_nf)`). At depth `k+1` this is the documented **non-theorem**
  (`NfDepth0Generalized.lean:1691-1719`; `liftIdx r` non-injective, `←` fails).

**Settled**: the diagonal collapse (`renameNF_eval_diag0`) is used **only at the depth-0
atom layer**, where it is a proven iff. The depth-`(k+1)` quant layer goes through the
honest arity-3 navigated existential — **never** collapsed to arity 1.

## References
- Rabinovich 2014, "A Proof of Kamp's Theorem", Cor 5.4 (`F_i` chain).
- `specs/308_multi_anchor_char_formula_bridge/plans/01_multi-anchor-bridge-plan.md`
- `specs/308_multi_anchor_char_formula_bridge/reports/01_multi-anchor-bridge-research.md`
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical
open Bimodal.Metalogic.WeakCanonical.Separation
  (nf_depth0_char_formula nf_depth0_char_formula_correct
   formula_conjList formula_conjList_iff)

/-! ## Phase 1a: diagonal depth-0 atom layer (deliverable-1 base)

The atom part of the two-anchor characteristic on the diagonal env `[t,t]`. On that
env all order atoms are constant-false (`t < t`) and both predicate positions reduce to
the single point `t`; this is exactly the diagonal value-duplication `diagDup` of an
arity-1 NF. The depth-0 characteristic formula of the arity-1 NF therefore characterizes
the arity-2 evaluation of `diagDup nf1` — via `renameNF_eval_diag0` (as packaged by
`diagDup_eval_zero`) at the **depth-0 atom layer only**. -/

/-- **Diagonal depth-0 atom-layer iff.** The depth-0 characteristic formula of an arity-1
NF `nf1` holds at `t` iff the diagonal value-duplication `diagDup nf1` evaluates on the
constant arity-2 env `[t,t]`. This is the diagonal atom layer of deliverable 1, discharged
by `nf_depth0_char_formula_correct` + `diagDup_eval_zero` (the depth-0 instance of
`renameNF_eval_diag0`). The diagonal collapse appears here, at depth 0, where it is a
proven iff — never at the depth-`(k+1)` quant layer (forbidden route (c)). -/
theorem nf_char2_atom_layer {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (nf1 : NormalForm sig 0 1) (t : M.carrier) :
    temporal_truth M atomMap t (nf_depth0_char_formula atomMap h_surj nf1) ↔
    nf_eval_nf M 0 2 (fun _ => t) (diagDup nf1) := by
  rw [nf_depth0_char_formula_correct, diagDup_eval_zero]
  simp only [nf_eval_nf]
  constructor
  · intro h a
    obtain ⟨p, rfl⟩ := atomKind_arity1_is_pred a
    simp only [atom_eval]
    exact h p
  · intro h p
    have hp := h (.pred p ⟨0, by omega⟩)
    simpa only [atom_eval] using hp

/-! ## Phase 1b: `k = 0` base of the navigated zone-flatten (deliverable-2 base)

The bottom of the depth recursion of deliverable 2. At `k = 0` there is no navigation:
the arity-3 env `[w,t,t]` has its two `t`-anchors collapsed, so the diagonal
value-duplication `diagDup3` of an arity-2 NF evaluates on `[w,t,t]` iff the arity-2 NF
evaluates on `[w,t]`. The `∃w`-wrapped form is the `k = 0` base consumed by the Phase-2/5
recursion (where `k ≥ 1` replaces the endpoints with navigated `bracketBuild*` chains). -/

/-- Tail-expansion `Fin 2 → Fin 3`: the arity-2 positions embed as the first two
arity-3 positions (`0 ↦ 0`, `1 ↦ 1`). -/
def tailExpand3 : Fin 2 → Fin 3 := fun i => ⟨i.val, by omega⟩

/-- Tail-merge `Fin 3 → Fin 2`: the two trailing anchor positions collapse onto one
(`0 ↦ 0`, `1 ↦ 1`, `2 ↦ 1`). -/
def tailMerge3 : Fin 3 → Fin 2 := fun i => if i.val = 0 then 0 else 1

/-- Retraction: merging after expanding is the identity on `Fin 2`. -/
theorem tailMerge3_expand3_id : ∀ i : Fin 2, tailMerge3 (tailExpand3 i) = i := by
  decide

/-- A constant-tail environment `Fin.cons w (fun _ => t)` (any arity) takes value `w`
at position `0` and `t` at every other position. -/
private theorem cons_const_apply {α : Type*} (w t : α) {m : Nat} (k : Fin (m + 1)) :
    (Fin.cons w (fun _ => t) : Fin (m + 1) → α) k = if k.val = 0 then w else t := by
  induction k using Fin.cases with
  | zero => simp [Fin.cons_zero]
  | succ j => simp [Fin.cons_succ]

/-- **Tail value-duplication** of an arity-2 NF to arity 3 (depth 0): duplicate the
second anchor onto both trailing positions. `renameNF tailMerge3 tailExpand3`. -/
def diagDup3 {sig : MonadicSignature}
    (q2 : NormalForm sig 0 2) : NormalForm sig 0 3 :=
  renameNF tailMerge3 tailExpand3 q2

/-- **Depth-0 tail-diagonal duplication equivalence.** On the arity-3 env `[w,t,t]`
(both trailing anchors `= t`), the tail-duplicated `diagDup3 q2` evaluates iff the
arity-2 `q2` evaluates on `[w,t]`. Direct instance of `renameNF_eval_diag0`. -/
theorem diagDup3_eval_zero {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (q2 : NormalForm sig 0 2) (w t : M.carrier) :
    nf_eval_nf M 0 3 (Fin.cons w (fun _ => t)) (diagDup3 q2) ↔
    nf_eval_nf M 0 2 (Fin.cons w (fun _ => t)) q2 := by
  simp only [diagDup3]
  refine renameNF_eval_diag0 M tailExpand3 tailMerge3
    (Fin.cons w (fun _ => t)) (Fin.cons w (fun _ => t))
    ?_ ?_ tailMerge3_expand3_id q2
  · intro i
    rw [cons_const_apply w t i, cons_const_apply w t (tailExpand3 i)]
    simp only [tailExpand3]
  · intro i
    rw [cons_const_apply w t i, cons_const_apply w t (tailMerge3 i)]
    by_cases h : i.val = 0 <;> simp [tailMerge3, h]

/-- **`k = 0` base of deliverable 2 (navigated zone-flatten).** The arity-3 tail-diagonal
existential of a duplicated NF `diagDup3 q2` on `[w,t,t]` equals the arity-2 existential
of `q2` on `[w,t]`. Endpoints are atom/anchor types via `renameNF_eval_diag0`; no
`bracketBuild*` navigation is used at `k = 0`. This is the bottom of the depth recursion
that Phases 2 and 5 unfold at `k ≥ 1` with navigated endpoints. -/
theorem nf_zone_flatten_navigable_zero {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (q2 : NormalForm sig 0 2) (t : M.carrier) :
    (∃ w, nf_eval_nf M 0 3 (Fin.cons w (fun _ => t)) (diagDup3 q2)) ↔
    (∃ w, nf_eval_nf M 0 2 (Fin.cons w (fun _ => t)) q2) :=
  exists_congr (fun w => diagDup3_eval_zero M q2 w t)

/-! ## Phase 2: diagonal three-zone navigated quant-clause converter (deliverable 2 at `x = t`)

`nf_char2_diag_exist_tl` is the diagonal (`x = t`) specialization of deliverable 2: it converts the
coupled arity-3 existential `∃ w, nf_eval_nf M k 3 [w, t, t] qnf` into a temporal formula. Following
Rabinovich 2014 Cor 5.4, the single boundary `t` splits `∃ w` into the three order zones
(`w < t` / `w = t` / `t < w`); the two OPEN zones are realized by NAVIGATED brackets
(`bracketBuildLeft` for the past, `bracketBuildRight` for the future), and the `w = t` point zone by
the diagonal characteristic.

Exactly as the arity-1 template `nf_succ_char_formula` (KampPrior.lean:107) is parametric over its
depth-`k` existential converter `exist_tl_fn`, this arity-up converter is parametric over the three
zone-endpoint **hooks** — the depth-`k` characteristic of `qnf` at the navigated point (the recursion
hook; at `k = 0` these bottom out in `nf_zone_flatten_navigable_zero` / the depth-0 diagonal). The
depth-`k` recursion (task-308 Phases 4-5) supplies the hooks; here the three-zone assembly and its
correctness are proven once, sorry-free.

### Route audit (Postmortem forbidden-route guards)
- **(a)** The coupled `∃ w` is split DIRECTLY on the full env `Fin.cons w (fun _ => t) = [w, t, t]`
  via `exists_trichotomy_split` — no per-variable projection of the coupled quant layer.
- **(b)** Both open-zone endpoints are NAVIGATED recursive `bracketBuild*` `TemporalPred`s
  (`navigated_bracket_reaches_exterior_past` / `_future`), never depth-0 atomic brackets.
- **(c)** The arity-3 evaluation is characterized by the endpoint hooks, never collapsed to arity 1.
-/

/-- **Diagonal three-zone navigated existential converter** (deliverable 2 at `x = t`). Given the
three zone-endpoint hooks — `pastEnd` (navigated `Since` endpoint for `w < t`), `futureEnd`
(navigated `Until` endpoint for `t < w`), and `diagChar` (point characteristic for `w = t`) — build
the temporal formula whose truth at `t` captures `∃ w, nf_eval_nf M k 3 [w, t, t] qnf`. The two open
zones use navigated `bracketBuild*` chains (route (b) guard). -/
noncomputable def nf_char2_diag_exist_tl {sig : MonadicSignature} {k : Nat}
    (pastEnd futureEnd : NormalForm sig k 3 → TemporalPred)
    (diagChar : NormalForm sig k 3 → Formula)
    (qnf : NormalForm sig k 3) : Formula :=
  Formula.or
    (bracketBuildLeft (BracketFormula.trivial TemporalPred.top) (pastEnd qnf))
    (Formula.or
      (diagChar qnf)
      (bracketBuildRight (BracketFormula.trivial TemporalPred.top) (futureEnd qnf)))

/-- **Correctness of the diagonal three-zone converter.** Under the three hook-correctness
hypotheses (each zone endpoint characterizes the coupled arity-3 evaluation at its navigated
witness), the assembled formula holds at `t` iff `∃ w, nf_eval_nf M k 3 [w, t, t] qnf`. Assembled
from `exists_trichotomy_split` (route (a): direct full-env split) + the navigated-reach pillars
(route (b)) + the diagonal-point hook. Endpoints stay arity-3 (route (c)). -/
theorem nf_char2_diag_exist_tl_correct {sig : MonadicSignature} {k : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) (t : M.carrier)
    (pastEnd futureEnd : NormalForm sig k 3 → TemporalPred)
    (diagChar : NormalForm sig k 3 → Formula)
    (qnf : NormalForm sig k 3)
    (h_past : ∀ w : M.carrier, w < t →
      ((pastEnd qnf).eval_at M atomMap w ↔
        nf_eval_nf M k 3 (Fin.cons w (fun _ => t)) qnf))
    (h_fut : ∀ w : M.carrier, t < w →
      ((futureEnd qnf).eval_at M atomMap w ↔
        nf_eval_nf M k 3 (Fin.cons w (fun _ => t)) qnf))
    (h_diag : temporal_truth M atomMap t (diagChar qnf) ↔
      nf_eval_nf M k 3 (Fin.cons t (fun _ => t)) qnf) :
    temporal_truth M atomMap t
        (nf_char2_diag_exist_tl pastEnd futureEnd diagChar qnf) ↔
      ∃ w : M.carrier, nf_eval_nf M k 3 (Fin.cons w (fun _ => t)) qnf := by
  simp only [nf_char2_diag_exist_tl]
  rw [temporal_truth_or, temporal_truth_or,
      navigated_bracket_reaches_exterior_past,
      navigated_bracket_reaches_exterior_future,
      exists_trichotomy_split (fun w => nf_eval_nf M k 3 (Fin.cons w (fun _ => t)) qnf) t]
  exact or_congr (exists_congr fun w => and_congr_right fun hw => h_past w hw)
    (or_congr h_diag (exists_congr fun w => and_congr_right fun hw => h_fut w hw))

/-! ## Phase 3: assemble `nf_char2_formula` + `_correct` (Deliverable 1 COMPLETE)

Mirrors the arity-1 template `nf_succ_char_formula` (KampPrior.lean:107) exactly, one arity up:
`nf_char2_formula sub_nf := formula_conjList (atom_part :: quant_clauses)`, where `atom_part` is the
diagonal depth-0 atom characteristic (Phase 1's layer, generalized here to an arbitrary
`sub_nf.1 : NormalForm sig 0 2` — the Phase-1-deferred order-atom / pred-agreement guard) and each
`quant_clause` wraps the Phase-2 diagonal three-zone navigated existential
`nf_char2_diag_exist_tl` via `nf_quant_clause_tl`.

Like the arity-1 template (parametric over `exist_tl_fn`), deliverable 1 stays parametric over the
three Phase-2 recursion hooks `pastEnd`/`futureEnd`/`diagChar`; correctness takes the assembled
Phase-2 converter iff as a hypothesis (`h_exist_correct`), exactly as `nf_succ_char_formula_correct`
takes `h_exist_correct`. Phases 4-5 supply the hooks and discharge that hypothesis via
`nf_char2_diag_exist_tl_correct`. Diagonal collapse is used ONLY at the depth-0 atom layer
(route (c) guard); the depth-`(k+1)` quant layer routes through the honest arity-3 navigated
existential (route (a)/(b) guards). -/

/-- **Arity-2 diagonal depth-0 atom characteristic.** The atom part of the two-anchor
characteristic on the diagonal env `[t,t]` for an arbitrary `nf2 : NormalForm sig 0 2`. On the
diagonal, every order atom evaluates false (`t < t`) and the two predicate positions coincide, so the
atom layer is satisfiable iff `nf2` is *diagonal-consistent* (all order atoms `false`, predicate
positions agree); in that case it reduces to the arity-1 predicate characteristic
(`nf_depth0_char_formula`). Otherwise it is `⊥` — the non-diagonal cases collapse to `⊥`, discharging
the Phase-1-deferred order-atom / pred-agreement guard. -/
noncomputable def nf_char2_atom_part {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (nf2 : NormalForm sig 0 2) : Formula :=
  if (∀ p : sig.preds, nf2 (.pred p 0) = nf2 (.pred p 1)) ∧
      (∀ (i j : Fin 2) (h : i ≠ j), nf2 (.order i j h) = false) then
    nf_depth0_char_formula atomMap h_surj
      (fun a => match a with
        | .pred p _ => nf2 (.pred p 0)
        | .order i j h => absurd (Subsingleton.elim i j) h)
  else
    Formula.bot

/-- **Correctness of the arity-2 diagonal atom characteristic.** Holds at `t` iff the arity-2 NF
`nf2` evaluates on the constant diagonal env `[t,t]`. The diagonal collapse appears here at the
depth-0 atom layer, where it is a proven iff (route (c) guard). -/
theorem nf_char2_atom_part_correct {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (nf2 : NormalForm sig 0 2) (t : M.carrier) :
    temporal_truth M atomMap t (nf_char2_atom_part atomMap h_surj nf2) ↔
    nf_eval_nf M 0 2 (fun _ => t) nf2 := by
  simp only [nf_char2_atom_part]
  by_cases hcons : (∀ p : sig.preds, nf2 (.pred p 0) = nf2 (.pred p 1)) ∧
      (∀ (i j : Fin 2) (h : i ≠ j), nf2 (.order i j h) = false)
  · rw [if_pos hcons, nf_depth0_char_formula_correct]
    simp only [nf_eval_nf]
    constructor
    · intro hpred a
      cases a with
      | pred p i =>
        have hp := hpred p
        have hi : nf2 (.pred p i) = nf2 (.pred p 0) := by
          match i with
          | 0 => rfl
          | 1 => exact (hcons.1 p).symm
        rw [hi]
        simpa only [atom_eval] using hp
      | order i j h =>
        simp only [atom_eval]
        rw [hcons.2 i j h]
        simp only [Bool.false_eq_true, iff_false]
        intro hlt
        exact absurd hlt (by simpa using lt_irrefl t)
    · intro hall p
      have hp := hall (.pred p 0)
      simpa only [atom_eval] using hp
  · rw [if_neg hcons]
    simp only [temporal_truth]
    constructor
    · exact False.elim
    · intro heval
      apply hcons
      simp only [nf_eval_nf] at heval
      refine ⟨fun p => ?_, fun i j hij => ?_⟩
      · have h0 := heval (.pred p 0)
        have h1 := heval (.pred p 1)
        simp only [atom_eval] at h0 h1
        have hiff : (nf2 (.pred p 0) = true) ↔ (nf2 (.pred p 1) = true) := h0.symm.trans h1
        cases hb0 : nf2 (.pred p 0) <;> cases hb1 : nf2 (.pred p 1) <;> simp_all
      · have ho := heval (.order i j hij)
        simp only [atom_eval] at ho
        have hfalse : ¬ ((fun (_ : Fin 2) => t) i < (fun (_ : Fin 2) => t) j) := by
          simpa using lt_irrefl t
        cases hb : nf2 (.order i j hij)
        · rfl
        · exact absurd (ho.mpr hb) hfalse

/-- **Deliverable 1: the two-anchor characteristic FORMULA builder.** Mirrors
`nf_succ_char_formula` (arity 1) one arity up. Parametric over the three Phase-2 recursion hooks
`pastEnd`/`futureEnd`/`diagChar` (exactly as the arity-1 template is parametric over `exist_tl_fn`);
Phases 4-5 supply the hooks. Assembles the diagonal atom characteristic conjoined with one quant
clause per arity-3 sub-NF, each wrapping the Phase-2 navigated diagonal existential. -/
noncomputable def nf_char2_formula {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    {k : Nat}
    (pastEnd futureEnd : NormalForm sig k 3 → TemporalPred)
    (diagChar : NormalForm sig k 3 → Formula)
    (sub_nf : NormalForm sig (k + 1) 2) : Formula :=
  let atom_part := nf_char2_atom_part atomMap h_surj (sub_nf.1 : NormalForm sig 0 2)
  let quant_clauses := (Finset.univ.toList : List (NormalForm sig k 3)).map
    (fun qnf => nf_quant_clause_tl
      (nf_char2_diag_exist_tl pastEnd futureEnd diagChar qnf) (sub_nf.2 qnf))
  formula_conjList (atom_part :: quant_clauses)

/-- **Correctness of deliverable 1.** Under the Phase-2 converter iff (the `h_exist_correct`
hypothesis, discharged by `nf_char2_diag_exist_tl_correct` once Phases 4-5 supply the hooks), the
assembled formula holds at `t` iff `sub_nf` evaluates on the constant diagonal two-anchor env `[t,t]`.
Assembled from `formula_conjList_iff` + `nf_char2_atom_part_correct` (atom layer, route (c) guard) +
`nf_quant_clause_tl_correct` per clause (quant layer through the arity-3 navigated existential). -/
theorem nf_char2_formula_correct {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    {k : Nat}
    (pastEnd futureEnd : NormalForm sig k 3 → TemporalPred)
    (diagChar : NormalForm sig k 3 → Formula)
    (M : OrderedMonadicStructure sig) (t : M.carrier)
    (h_exist_correct : ∀ (qnf : NormalForm sig k 3),
      temporal_truth M atomMap t
          (nf_char2_diag_exist_tl pastEnd futureEnd diagChar qnf) ↔
        ∃ w : M.carrier, nf_eval_nf M k 3 (Fin.cons w (fun _ => t)) qnf)
    (sub_nf : NormalForm sig (k + 1) 2) :
    temporal_truth M atomMap t
        (nf_char2_formula atomMap h_surj pastEnd futureEnd diagChar sub_nf) ↔
      nf_eval_nf M (k + 1) 2 (fun _ => t) sub_nf := by
  simp only [nf_char2_formula]
  rw [formula_conjList_iff]
  change _ ↔ (∀ (a : AtomKind sig 2), atom_eval M (fun _ => t) a ↔ (sub_nf.1 a = true)) ∧
    (∀ (qnf : NormalForm sig k 3),
      (∃ (w : M.carrier), nf_eval_nf M k 3 (Fin.cons w (fun _ => t)) qnf) ↔
        (sub_nf.2 qnf = true))
  have quant_mem : ∀ qnf : NormalForm sig k 3,
      nf_quant_clause_tl (nf_char2_diag_exist_tl pastEnd futureEnd diagChar qnf) (sub_nf.2 qnf) ∈
        List.map (fun qnf => nf_quant_clause_tl
            (nf_char2_diag_exist_tl pastEnd futureEnd diagChar qnf) (sub_nf.2 qnf))
          Finset.univ.toList :=
    fun qnf => List.mem_map.mpr
      ⟨qnf, Finset.mem_toList.mpr (Finset.mem_univ qnf), rfl⟩
  constructor
  · intro h_all
    constructor
    · have h_atom := h_all _ (.head _)
      rw [nf_char2_atom_part_correct] at h_atom
      simpa only [nf_eval_nf] using h_atom
    · intro qnf
      have h_clause := h_all _ (.tail _ (quant_mem qnf))
      rw [nf_quant_clause_tl_correct M atomMap t _ _ _ (h_exist_correct qnf)] at h_clause
      exact h_clause
  · intro ⟨h_atoms, h_quants⟩ φ h_mem
    cases h_mem with
    | head =>
      rw [nf_char2_atom_part_correct]
      simpa only [nf_eval_nf] using h_atoms
    | tail _ h_tail =>
      obtain ⟨qnf, _, rfl⟩ := List.mem_map.mp h_tail
      rw [nf_quant_clause_tl_correct M atomMap t _ _ _ (h_exist_correct qnf)]
      exact h_quants qnf

/-! ## Phase 4: general zone-flatten decomposition helpers (arbitrary anchors `(x,t)`)

The three named sorry-free helpers that Phase 5 assembles into deliverable 2 at arbitrary
anchors `(x, t)` (not just the diagonal `x = t` of Phases 1-2). Everything routes through the
preserved sorry-free NfZoneDepthK machinery (`nf_char3_eq_succ_iff`,
`nf_characteristic_quant_split3`, `exists_nested_split3`) — consumed verbatim, never re-derived.

### Route audit (Postmortem forbidden-route guards)
- **(a)** The five-zone split and the deeper coupled layer split the existential DIRECTLY on the
  full env (`zoneEnv3 w x t` / `Fin.cons w (zoneEnv3 y x t)`) — no per-variable projection.
- **(b)** The deeper layer keeps the endpoint obligation as `char[·] = q` (fed to navigated
  brackets in P5), never a flat depth-0 atomic bracket.
- **(c)** The arity-invariance lemma certifies the env arity never grows past `{w,x,t}=3` (anchor
  set stays `{x,t}=2` when the outer witness is peeled) — no arity-1 collapse.
-/

/-- **Arity-invariance guardrail (R-C termination).** The env arity of the navigated existential
never exceeds `{w, x, t} = 3`, reducing to the two-anchor set `{x, t} = 2` when the outer witness
is peeled, and the anchor set of the outer formula stays exactly `{x, t}`:

1. peeling the outer witness `y` from the arity-3 zone env `[y, x, t]` returns the canonical
   arity-2 anchor env `[x, t]` (`Fin.cons x (fun _ => t)`) — witness-independent, so the anchor
   set stays `{x, t}` (Rabinovich ≤2 free-variable cap);
2. peeling a deeper witness `w` from the arity-4 coupled env `[w, y, x, t]` returns the arity-3
   zone env `[y, x, t]` — the coupled layer does NOT grow the anchor set (route (c) guard). -/
theorem zoneEnv3_arity_invariant {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (y x t : M.carrier) :
    Fin.tail (zoneEnv3 y x t) = Fin.cons x (fun _ => t) ∧
    (∀ w : M.carrier,
      Fin.tail (Fin.cons w (zoneEnv3 y x t) : Fin 4 → M.carrier) = zoneEnv3 y x t) := by
  refine ⟨?_, ?_⟩
  · simp only [zoneEnv3, Fin.tail_cons]
  · intro w
    simp only [Fin.tail_cons]

/-- Generic **two-boundary five-zone split** of an existential: any witness lies below `x`, at `x`,
strictly between `x` and `t`, at `t`, or above `t`. Unconditionally valid (nested `lt_trichotomy`);
degenerate anchor orders merely empty/overlap zones, which a disjunction tolerates. The atom of the
outer `y`-zone decomposition — the mirror of the inner `exists_nested_split3`. -/
theorem exists_zone_split5 {α : Type*} [LinearOrder α] (P : α → Prop) (x t : α) :
    (∃ w, P w) ↔
      (∃ w, w < x ∧ P w) ∨ P x ∨
      (∃ w, x < w ∧ w < t ∧ P w) ∨ P t ∨ (∃ w, t < w ∧ P w) := by
  constructor
  · rintro ⟨w, hw⟩
    rcases lt_trichotomy w x with hwx | hwx | hwx
    · exact Or.inl ⟨w, hwx, hw⟩
    · exact Or.inr (Or.inl (hwx ▸ hw))
    · rcases lt_trichotomy w t with hwt | hwt | hwt
      · exact Or.inr (Or.inr (Or.inl ⟨w, hwx, hwt, hw⟩))
      · exact Or.inr (Or.inr (Or.inr (Or.inl (hwt ▸ hw))))
      · exact Or.inr (Or.inr (Or.inr (Or.inr ⟨w, hwt, hw⟩)))
  · rintro (⟨w, _, hw⟩ | hx | ⟨w, _, _, hw⟩ | ht | ⟨w, _, hw⟩)
    · exact ⟨w, hw⟩
    · exact ⟨x, hx⟩
    · exact ⟨w, hw⟩
    · exact ⟨t, ht⟩
    · exact ⟨w, hw⟩

/-- **Five-zone witness split of the arity-3 zone existential** over arbitrary anchors `(x, t)`.
Splits `∃ w, nf_eval_nf M k 3 [w, x, t] q` into the five order zones of `w` relative to `x`, `t`
(`w < x`, `w = x`, `x < w < t`, `w = t`, `t < w`), tolerating degenerate anchor orders. The coupled
existential is split DIRECTLY on the full env `zoneEnv3 w x t` (route (a) guard), never projected.
The open zones feed `bracketBuild*` and the point zones the diagonal collapse in Phase 5. -/
theorem nf_char2_zone_split5 {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (k : Nat)
    (q : NormalForm sig k 3) (x t : M.carrier) :
    (∃ w, nf_eval_nf M k 3 (zoneEnv3 w x t) q) ↔
      (∃ w, w < x ∧ nf_eval_nf M k 3 (zoneEnv3 w x t) q) ∨
      nf_eval_nf M k 3 (zoneEnv3 x x t) q ∨
      (∃ w, x < w ∧ w < t ∧ nf_eval_nf M k 3 (zoneEnv3 w x t) q) ∨
      nf_eval_nf M k 3 (zoneEnv3 t x t) q ∨
      (∃ w, t < w ∧ nf_eval_nf M k 3 (zoneEnv3 w x t) q) :=
  exists_zone_split5 (fun w => nf_eval_nf M k 3 (zoneEnv3 w x t) q) x t

/-- **Deeper coupled-layer decomposition** one recursion down (arity-4 `[w, y, x, t]`).
`char[y, x, t] = q` at depth `k+1` holds iff the atom layers agree pointwise at the anchors AND,
for every depth-`k` sub-form `sub`, the coupled inner realizability set — split into the SEVEN inner
`w`-zones relative to `y, x, t` (`nf_characteristic_quant_split3` / `exists_nested_split3`) — matches
`q`'s quant assignment. Combines `nf_char3_eq_succ_iff` (the complete atom+quant decomposition) with
the inner seven-zone split. The coupled `∃ w` is split DIRECTLY on the full arity-4 env
`Fin.cons w (zoneEnv3 y x t)` (route (a) guard); the endpoint stays a `char[·] = q` obligation that
Phase 5 navigates with `bracketBuild*` (route (b) guard), never arity-collapsed (route (c) guard). -/
theorem nf_char3_deeper_split {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (k : Nat) (y x t : M.carrier)
    (q : NormalForm sig (k + 1) 3) :
    nf_characteristic M (k + 1) 3 (zoneEnv3 y x t) = q ↔
      (∀ a : AtomKind sig 3, atom_eval M (zoneEnv3 y x t) a ↔ (q.atom_assgn a = true)) ∧
      (∀ sub : NormalForm sig k 4,
        ((∃ w, w < y ∧ nf_eval_nf M k 4 (Fin.cons w (zoneEnv3 y x t)) sub) ∨
          nf_eval_nf M k 4 (Fin.cons y (zoneEnv3 y x t)) sub ∨
          (∃ w, y < w ∧ w < x ∧ nf_eval_nf M k 4 (Fin.cons w (zoneEnv3 y x t)) sub) ∨
          nf_eval_nf M k 4 (Fin.cons x (zoneEnv3 y x t)) sub ∨
          (∃ w, x < w ∧ w < t ∧ nf_eval_nf M k 4 (Fin.cons w (zoneEnv3 y x t)) sub) ∨
          nf_eval_nf M k 4 (Fin.cons t (zoneEnv3 y x t)) sub ∨
          (∃ w, t < w ∧ nf_eval_nf M k 4 (Fin.cons w (zoneEnv3 y x t)) sub)) ↔
          (q.quant_assgn sub = true)) := by
  rw [nf_char3_eq_succ_iff]
  refine and_congr Iff.rfl (forall_congr' fun sub => iff_congr ?_ Iff.rfl)
  exact exists_nested_split3
    (fun w => nf_eval_nf M k 4 (Fin.cons w (zoneEnv3 y x t)) sub) y x t

/-! ## Phase 5: assemble `nf_zone_flatten_navigable` + `_correct` (Deliverable 2 COMPLETE)

The general navigated bounded-existential **corollary** at arbitrary anchors `(x, t)`, assembled from
the Phase-4 five-zone split (`nf_char2_zone_split5`) and the two navigated-reach pillars
(`navigated_bracket_reaches_exterior_past` / `_future`). This is the arbitrary-anchor generalization
of the Phase-2 diagonal converter `nf_char2_diag_exist_tl` (which handled the single-boundary `x = t`
case): here there are TWO boundaries `x < t`, so the coupled arity-3 existential
`∃ w, nf_eval_nf M k 3 (zoneEnv3 w x t) q` splits into FIVE zones of `w` relative to `(x, t)` —
`w < x` (past exterior of `x`), `w = x`, `x < w < t` (bounded interior), `w = t`, `t < w`
(future exterior of `t`).

Following Rabinovich 2014 Cor 5.4 (`F_i` chain), the two OPEN EXTERIOR zones are realized by NAVIGATED
`bracketBuild*` chains — `bracketBuildLeft` walking into the past exterior `w < x` from origin `x`,
`bracketBuildRight` walking into the future exterior `t < w` from origin `t` — each with a trivial
(`top`) segment, so the navigated bracket collapses to the bare exterior existential and its endpoint
`TemporalPred` (the depth-`k` characteristic of `q` at the navigated witness) is checked exactly at the
exterior witness. The two point zones (`w = x`, `w = t`) and the bounded interior (`x < w < t`) stay as
depth-`k` residuals, discharged one depth down by the IH / `nf_char3_deeper_split` at the caller
(exactly as the arity-1 template `nf_succ_char_formula` threads its recursion through `exist_tl_fn`,
and as Phase 2 threads the point zone through `diagChar`).

Recursion on `k` is threaded through the two navigated endpoint HOOKS `pastEnd` / `futureEnd`
(mirroring the Phase-2 hook parametricity, plan-sanctioned R-B): at `k = 0` these bottom out in
`nf_zone_flatten_navigable_zero` (Phase 1); at `k ≥ 1` the caller supplies endpoints whose
`.eval_at` correctness one depth down is the IH. The assembly and its correctness iff are proven here
once, sorry-free.

### Route audit (Postmortem forbidden-route guards)
- **(a)** The coupled `∃ w` is split DIRECTLY on the full env `zoneEnv3 w x t = [w, x, t]` via
  `nf_char2_zone_split5` — no per-variable projection of the coupled quant layer.
- **(b)** Both open-exterior-zone endpoints are NAVIGATED recursive `bracketBuild*` `TemporalPred`s
  (via `navigated_bracket_reaches_exterior_past` / `_future`), never depth-0 atomic brackets.
- **(c)** Every residual stays an honest arity-3 `nf_eval_nf` on the full env `zoneEnv3 · x t`
  (anchor set `{x, t}`, env arity `≤ 3` per `zoneEnv3_arity_invariant`); nothing is collapsed to
  arity 1.
-/

/-- **Deliverable 2: the general navigated bounded-existential corollary (RHS shape).** The five-zone
navigated disjunction that characterizes `∃ w, nf_eval_nf M k 3 (zoneEnv3 w x t) q` at arbitrary
anchors `(x, t)`. Parametric over the two navigated endpoint hooks `pastEnd` (past-exterior `Since`
endpoint, checked at `x`) and `futureEnd` (future-exterior `Until` endpoint, checked at `t`) — exactly
as the Phase-2 diagonal converter and the arity-1 template are parametric over their recursion hooks.
The two open exterior zones are navigated `bracketBuild*` chains (route (b) guard); the two point zones
and the bounded interior stay honest arity-3 `nf_eval_nf` residuals on the full env (routes (a)/(c)
guards). `w` is always a bracket witness, never a named free anchor. -/
noncomputable def nf_zone_flatten_navigable {sig : MonadicSignature} {k : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (x t : M.carrier)
    (pastEnd futureEnd : NormalForm sig k 3 → TemporalPred)
    (q : NormalForm sig k 3) : Prop :=
  temporal_truth M atomMap x
      (bracketBuildLeft (BracketFormula.trivial TemporalPred.top) (pastEnd q)) ∨
    nf_eval_nf M k 3 (zoneEnv3 x x t) q ∨
    (∃ w, x < w ∧ w < t ∧ nf_eval_nf M k 3 (zoneEnv3 w x t) q) ∨
    nf_eval_nf M k 3 (zoneEnv3 t x t) q ∨
    temporal_truth M atomMap t
      (bracketBuildRight (BracketFormula.trivial TemporalPred.top) (futureEnd q))

/-- **Correctness of deliverable 2.** Under the two navigated-endpoint-hook correctness hypotheses
(each exterior endpoint `.eval_at` at its navigated witness characterizes the coupled arity-3
evaluation one depth down — the recursion IH at `k ≥ 1`, the Phase-1 base at `k = 0`), the coupled
arity-3 existential over arbitrary anchors `(x, t)` holds iff the five-zone navigated disjunction
holds. Assembled from `nf_char2_zone_split5` (route (a): direct full-env five-zone split) + the two
navigated-reach pillars (route (b)); the three residual zones match definitionally (route (c):
arity stays 3, anchor set `{x, t}`). -/
theorem nf_zone_flatten_navigable_correct {sig : MonadicSignature} {k : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (x t : M.carrier)
    (pastEnd futureEnd : NormalForm sig k 3 → TemporalPred)
    (q : NormalForm sig k 3)
    (h_past : ∀ w : M.carrier, w < x →
      ((pastEnd q).eval_at M atomMap w ↔
        nf_eval_nf M k 3 (zoneEnv3 w x t) q))
    (h_fut : ∀ w : M.carrier, t < w →
      ((futureEnd q).eval_at M atomMap w ↔
        nf_eval_nf M k 3 (zoneEnv3 w x t) q)) :
    (∃ w, nf_eval_nf M k 3 (zoneEnv3 w x t) q) ↔
      nf_zone_flatten_navigable M atomMap x t pastEnd futureEnd q := by
  rw [nf_char2_zone_split5]
  simp only [nf_zone_flatten_navigable]
  rw [navigated_bracket_reaches_exterior_past,
      navigated_bracket_reaches_exterior_future]
  refine or_congr (exists_congr fun w => and_congr_right fun hw => (h_past w hw).symm) ?_
  refine or_congr Iff.rfl (or_congr Iff.rfl (or_congr Iff.rfl ?_))
  exact exists_congr fun w => and_congr_right fun hw => (h_fut w hw).symm

/-! ## Task 307, Phase 3: the A_diag arm (`x = t` diagonal disjunct of the `:391` trichotomy)

Task 307's `nf_zone_exists_trichotomy_k1` (NfZoneFlattenNavigable.lean) splits the `:391` RHS
existential `∃ x, nf_eval_nf M (k+1) 2 (Fin.cons x (fun _ => t)) sub_nf` into three order zones of
`x` relative to the fixed origin `t`. The **diagonal** (middle) disjunct is
`nf_eval_nf M (k+1) 2 (Fin.cons t (fun _ => t)) sub_nf` — the arity-2 sub-NF evaluated on the
constant env `[t, t]` (both anchors collapse onto `t`).

Task 307's Phase-3 BLOCKER (recorded in the plan + the OBSTRUCTION note in
`NfZoneFlattenNavigable.lean`) established that the originally-planned arity-1-collapse route
(`char_k1 (diagCollapse sub_nf)`) is a genuine **non-theorem** at depth `k+1` (forbidden route (c)).
Task 308 supplies the correct object: `nf_char2_formula` (deliverable 1) is the two-anchor
characteristic FORMULA builder, and `nf_char2_formula_correct` gives exactly
`temporal_truth M atomMap t (nf_char2_formula …) ↔ nf_eval_nf M (k+1) 2 (fun _ => t) sub_nf` — the
diagonal disjunct, since `(Fin.cons t (fun _ => t) : Fin 2 → M.carrier) = (fun _ => t)`.

This arm is **pure consumption glue** (assets only, no new mathematics): it instantiates
`nf_char2_formula_correct`, discharging its `h_exist_correct` hypothesis via the Phase-2 diagonal
converter correctness `nf_char2_diag_exist_tl_correct`. It stays **hook-parametric** over the three
depth-`k` recursion hooks `pastEnd`/`futureEnd`/`diagChar` and their correctness `h_past`/`h_fut`/
`h_diag` (the depth-`k` arity-3 IH), exactly as `nf_char2_formula`/`_correct` are — the induction
(task-307 Phase 4 / the `nf_nvar_exist_all_depths` recursion) supplies the hooks.

**File placement note (deviation from plan Phase-3 "land in NfZoneFlattenNavigable.lean").** The A_diag
arm consumes `nf_char2_formula`, which lives in this file (`NfMultiAnchorBridge`), and this file
already imports `NfZoneFlattenNavigable`. Placing the arm in `NfZoneFlattenNavigable` would require
that file to import `NfMultiAnchorBridge`, an import cycle. This leaf file is the only valid home;
it stays off the live import path (no importers), preserving the live-path sorry baseline (2). -/

/-- **A_diag arm** (task 307 Phase 3): the diagonal (`x = t`) disjunct of the `:391` trichotomy,
realized by task 308's two-anchor characteristic formula builder `nf_char2_formula`. Definitionally
`nf_char2_formula` at the three depth-`k` recursion hooks; named for the Phase-7 assembly
`A := A_past ∨ A_diag ∨ A_future`. -/
noncomputable def A_diag {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    {k : Nat}
    (pastEnd futureEnd : NormalForm sig k 3 → TemporalPred)
    (diagChar : NormalForm sig k 3 → Formula)
    (sub_nf : NormalForm sig (k + 1) 2) : Formula :=
  nf_char2_formula atomMap h_surj pastEnd futureEnd diagChar sub_nf

/-- **A_diag arm correctness** (task 307 Phase 3). Under the three depth-`k` recursion-hook
correctness hypotheses (`h_past`/`h_fut` — the navigated exterior endpoints characterize the coupled
arity-3 evaluation at their witnesses; `h_diag` — the point characteristic at `w = t`), the A_diag
formula holds at `t` iff the diagonal disjunct `nf_eval_nf M (k+1) 2 (Fin.cons t (fun _ => t)) sub_nf`
holds. Pure composition of `nf_char2_formula_correct` (whose `h_exist_correct` is discharged per-`qnf`
by `nf_char2_diag_exist_tl_correct`) with the constant-env identity
`(Fin.cons t (fun _ => t) : Fin 2 → M.carrier) = (fun _ => t)`. No arity-1 collapse (route (c) guard):
the depth-`(k+1)` quant layer routes through the honest arity-3 navigated existential. -/
theorem A_diag_correct {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    {k : Nat}
    (pastEnd futureEnd : NormalForm sig k 3 → TemporalPred)
    (diagChar : NormalForm sig k 3 → Formula)
    (M : OrderedMonadicStructure sig) (t : M.carrier)
    (h_past : ∀ (qnf : NormalForm sig k 3) (w : M.carrier), w < t →
      ((pastEnd qnf).eval_at M atomMap w ↔
        nf_eval_nf M k 3 (Fin.cons w (fun _ => t)) qnf))
    (h_fut : ∀ (qnf : NormalForm sig k 3) (w : M.carrier), t < w →
      ((futureEnd qnf).eval_at M atomMap w ↔
        nf_eval_nf M k 3 (Fin.cons w (fun _ => t)) qnf))
    (h_diag : ∀ (qnf : NormalForm sig k 3),
      temporal_truth M atomMap t (diagChar qnf) ↔
        nf_eval_nf M k 3 (Fin.cons t (fun _ => t)) qnf)
    (sub_nf : NormalForm sig (k + 1) 2) :
    temporal_truth M atomMap t
        (A_diag atomMap h_surj pastEnd futureEnd diagChar sub_nf) ↔
      nf_eval_nf M (k + 1) 2 (Fin.cons t (fun _ => t)) sub_nf := by
  simp only [A_diag]
  have h_env : (Fin.cons t (fun _ => t) : Fin 2 → M.carrier) = (fun _ => t) := by
    funext i
    rw [cons_const_apply t t i]
    by_cases h : i.val = 0 <;> simp [h]
  rw [h_env]
  exact nf_char2_formula_correct atomMap h_surj pastEnd futureEnd diagChar M t
    (fun qnf => nf_char2_diag_exist_tl_correct M atomMap t pastEnd futureEnd diagChar qnf
      (h_past qnf) (h_fut qnf) (h_diag qnf)) sub_nf

/-! ## Task 307, Phase 4: the general-`k` navigated flattening brick (arbitrary anchors `(x, t)`)

The load-bearing constructive brick for the `:391` past/future arms (Phases 5/6). Task 308 already
SHIPPED it as deliverable 2, `nf_zone_flatten_navigable` / `nf_zone_flatten_navigable_correct`
(above): the coupled inner-`w` arity-3 existential `∃ w, nf_eval_nf M k 3 (zoneEnv3 w x t) q` equals
the five-zone navigated disjunction (`w < x` past-exterior via `bracketBuildLeft` from origin `x`;
`w = x`; bounded interior `x < w < t`; `w = t`; `t < w` future-exterior via `bracketBuildRight` from
origin `t`), under the two navigated-endpoint-hook correctness hypotheses `h_past`/`h_fut` — which
ARE the depth-`k` IH (bottoming out at `k = 0` in `nf_zone_flatten_navigable_zero`).

Phase 4 therefore **consumes 308's deliverable 2 verbatim, hook-parametric, without rebuilding**
(exactly as Phase 3 consumed deliverable 1). The theorem below re-exposes the brick equivalence under
a Phase-4 name as the single stable citation point that Phases 5/6 invoke — the past-exterior open
zone is already the `bracketBuildLeft` navigation from `x` (Phase 5, `A_past`), the future-exterior
open zone the `bracketBuildRight` navigation from `t` (Phase 6, `A_future`). The two point zones
(`w = x`, `w = t`) and the bounded interior stay honest arity-3 residuals the caller discharges one
depth down (via `nf_char3_deeper_split`), never arity-collapsed (route (c) guard). `w` is always a
bracket witness, never a named free anchor; env arity never grows past `{w, x, t} = 3` reducing to
`{x, t} = 2` (`zoneEnv3_arity_invariant`, Rabinovich ≤2 free-variable cap). -/

/-- **Task 307 Phase 4 brick** — the general-`k` navigated flattening at arbitrary anchors `(x, t)`,
consumed verbatim from task 308's deliverable 2. Under the two navigated-endpoint-hook correctness
hypotheses (the depth-`k` IH), the coupled inner existential `∃ w, nf_eval_nf M k 3 (zoneEnv3 w x t) q`
equals the five-zone navigated disjunction `nf_zone_flatten_navigable`. This is
`nf_zone_flatten_navigable_correct` re-exposed as the Phase-5/6 citation point (NOT rebuilt). -/
theorem nf_zone_flatten_navigable_brick {sig : MonadicSignature} {k : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (x t : M.carrier)
    (pastEnd futureEnd : NormalForm sig k 3 → TemporalPred)
    (q : NormalForm sig k 3)
    (h_past : ∀ w : M.carrier, w < x →
      ((pastEnd q).eval_at M atomMap w ↔
        nf_eval_nf M k 3 (zoneEnv3 w x t) q))
    (h_fut : ∀ w : M.carrier, t < w →
      ((futureEnd q).eval_at M atomMap w ↔
        nf_eval_nf M k 3 (zoneEnv3 w x t) q)) :
    (∃ w, nf_eval_nf M k 3 (zoneEnv3 w x t) q) ↔
      nf_zone_flatten_navigable M atomMap x t pastEnd futureEnd q :=
  nf_zone_flatten_navigable_correct M atomMap x t pastEnd futureEnd q h_past h_fut

end Bimodal.Metalogic.WeakCanonical.Kamp
