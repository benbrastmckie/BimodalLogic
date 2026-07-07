import Bimodal.Metalogic.WeakCanonical.Kamp.NfZoneFlattenNavigable
import Bimodal.Metalogic.WeakCanonical.Kamp.NfEFold
import Bimodal.Metalogic.WeakCanonical.PriorDefs
import Bimodal.Metalogic.WeakCanonical.Kamp.EANegationClosure
import Mathlib.Data.List.Permutation
-- NOTE (task 309 Phase 13.1): `import ...Kamp.EANegationClosure` lands the import edge
-- authorized by plan v6 (report 05 §d, verified on paper; compile-verified this dispatch).
-- Cycle-free: only KampPrior imports this file, and EANegationClosure's transitive closure
-- (EANegation, VecEAClosure, VecEAFormula, PriorINF, ExistsForallNF, PriorDefs, MonadicFO,
-- Table) reaches neither KampPrior nor this file. It transitively supplies PriorINF
-- (`HasAttainedINF`/`prior_hasAttainedINF`, PriorINF:202/:224) and the Lemma 5.1/Cor 5.4/
-- Prop 4.2 negation-stack assets consumed by Phases 13.2-13.4.
-- NOTE (task 309 Phase 13.0): `import ...WeakCanonical.PriorDefs` supplies
-- `semantic_prior_UZ`/`semantic_prior_SZ` (PriorDefs:22/:33) for the F2 decision-probe verdict
-- record at the bottom of this file. Cycle-free: PriorDefs imports only `...WeakCanonical.Table`
-- (already in this file's transitive closure); nothing in PriorDefs' closure imports this file.
-- NOTE (task 311 Phase 4): `import Mathlib.Data.List.Permutation` supplies
-- `List.mem_permutations` (arrangement-disjunct membership ↔ `List.Perm`), consumed by the
-- soundness direction of the V-carrier. Mathlib-only; no project-file import added.
-- NOTE (task 311 Phase 1): `import ...Kamp.NfEFold` is cycle-free — NfEFold imports only
-- `...WeakCanonical.NormalForm` and `...Kamp.NfDepth0Generalized` (NfEFold.lean:1-2), neither of
-- which imports this file. It supplies the task-310 E[Σ]-fold assets (`efold_of_nf1`,
-- `nf_eval_nf1_iff_efold`, `nf_quant_layer_fold_k1_gate`, the depth-0 split kit) consumed by the
-- k=1 fold carrier `bracketEndChar_k1` below.
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

/-! ## Phase 2 (task 309): off-diagonal atom layer for `[x, t]` (`x < t`, `order 0 1 = true`)

The **off-diagonal** analog of the diagonal atom part `nf_char2_atom_part` above. On the diagonal
env `[t, t]` both loci coincide and every order atom is false; here the two loci `x < t` are
DISTINCT and `order 0 1` (i.e. `x < t`) is TRUE. This is the D3 divergence: `nf_char2_atom_part`
is diagonal-only (it returns `⊥` whenever any order atom is true), so a NEW atom layer is required
for the endpoint of the Rabinovich Cor 5.4 `F_i` chain (md:154-157), where the bound witness `x`
sits strictly in the past (resp. future) exterior of the origin `t`.

Following the F_i chain architecture (`A_past seg pastEnd`, NfZoneFlattenNavigable.lean:335): the
outer `bracketBuildLeft` navigates from origin `t` back to the bound endpoint `z0 = x`, checking
`pastEnd.eval_at x` at the endpoint and the segment on `(x, t)`. The arity-2 atom layer at `[x, t]`
therefore splits by LOCUS:

- **x-position predicate atoms** (`.pred p 0`, `interp p x`) are checked at the navigated ENDPOINT
  `x` — carried by `nf_char2_atom_offdiag_endpoint` (a `TemporalPred`, plugged in as `pastEnd`'s
  atom part);
- **t-position predicate atoms** (`.pred p 1`, `interp p t`) are asserted at the ORIGIN `t` — carried
  by `nf_char2_atom_offdiag_origin` (a `Formula`, conjoined at the origin level in Phase 4);
- **order atoms** are fixed by the strict `x < t` supplied by the bracket direction: `order 0 1 =
  true`, `order 1 0 = false`. The origin builder guards on off-diagonal order consistency (an
  order literal is `= true` iff its index pair is strictly increasing) and collapses to `⊥`
  otherwise — the off-diagonal analog of the diagonal `⊥` guard, but keyed to `x < t` (D3), NOT to
  "all order atoms false".

Both loci reuse the arity-1 predicate-literal conjunction `nf_depth0_char_formula`
(Separation/KampTranslation.lean:130) via the per-locus projection `nf2_locus`. G4: the anchor set
stays `{x, t} = 2`; no arity growth. G5 N/A here (this is the atom leaf, not a chain step). -/

/-- Per-locus arity-1 projection of an arity-2 depth-0 NF: fix the anchor index `i ∈ {0, 1}` and read
off the predicate assignment there. Order atoms are vacuous at arity 1 (`Fin 1` is a subsingleton),
mirroring the diagonal collapse inside `nf_char2_atom_part`. -/
def nf2_locus {sig : MonadicSignature} (nf2 : NormalForm sig 0 2) (i : Fin 2) :
    NormalForm sig 0 1 :=
  fun a => match a with
    | .pred p _ => nf2 (.pred p i)
    | .order j j' h => absurd (Subsingleton.elim j j') h

/-- **Off-diagonal endpoint atom characteristic** (task 309 Phase 2, D3). The `TemporalPred` carrying
the `x`-position predicate atoms of `nf2`, checked at the navigated endpoint `x` (fed as the atom part
of `A_past`/`A_future`'s `pastEnd`/`futureEnd`). Its `.eval_at x` characterizes
`∀ p, interp p x ↔ nf2 (.pred p 0) = true`. -/
noncomputable def nf_char2_atom_offdiag_endpoint {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (nf2 : NormalForm sig 0 2) : TemporalPred :=
  ⟨nf_depth0_char_formula atomMap h_surj (nf2_locus nf2 0)⟩

/-- **Off-diagonal origin atom characteristic** (task 309 Phase 2, D3). The `Formula` carrying the
`t`-position predicate atoms of `nf2`, asserted at the origin `t`, guarded by off-diagonal order
consistency (each order literal is `= true` iff its index pair is strictly increasing — i.e. matches
the strict `x < t`). Collapses to `⊥` when the order layer is not off-diagonal-consistent (the D3
analog of the diagonal `⊥` guard). -/
noncomputable def nf_char2_atom_offdiag_origin {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (nf2 : NormalForm sig 0 2) : Formula :=
  if (∀ (i j : Fin 2) (h : i ≠ j), (nf2 (.order i j h) = true ↔ (i : Fin 2) < j)) then
    nf_depth0_char_formula atomMap h_surj (nf2_locus nf2 1)
  else
    Formula.bot

/-- **Correctness of the off-diagonal atom layer** (task 309 Phase 2, D3). Given the strict order
`x < t`, the two-anchor depth-0 atom layer `nf_eval_nf M 0 2 [x, t] nf2` holds iff BOTH the origin
characteristic (t-position preds + order guard) holds at `t` AND the endpoint characteristic
(x-position preds) holds at `x`. This is exactly the locus decomposition the F_i chain (Phase 4)
needs: the t-position preds and the order layer factor OUT of the `∃ x` (they do not depend on `x`
once `x < t` is fixed), leaving only the endpoint x-preds inside the navigated bracket. Rabinovich
Cor 5.4 endpoint atom coupling (md:154-157). -/
theorem nf_char2_atom_offdiag_correct {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (nf2 : NormalForm sig 0 2) (x t : M.carrier) (hxt : x < t) :
    (temporal_truth M atomMap t (nf_char2_atom_offdiag_origin atomMap h_surj nf2) ∧
      (nf_char2_atom_offdiag_endpoint atomMap h_surj nf2).eval_at M atomMap x) ↔
    nf_eval_nf M 0 2 (Fin.cons x (fun _ => t)) nf2 := by
  -- Environment values: position 0 ↦ x, position 1 ↦ t.
  have he0 : (Fin.cons x (fun _ => t) : Fin 2 → M.carrier) 0 = x := by
    simp
  have he1 : (Fin.cons x (fun _ => t) : Fin 2 → M.carrier) 1 = t := by
    simp
  -- The env is strictly monotone: `env i < env j ↔ i < j` (since `x < t`).
  have env_mono : ∀ (i j : Fin 2),
      ((Fin.cons x (fun _ => t) : Fin 2 → M.carrier) i <
        (Fin.cons x (fun _ => t) : Fin 2 → M.carrier) j) ↔ (i < j) := by
    intro i j
    by_cases hi : i = 0 <;> by_cases hj : j = 0
    · subst hi; subst hj; rw [he0]; simp
    · have hj1 : j = 1 := by omega
      subst hi; subst hj1; rw [he0, he1]
      exact iff_of_true hxt (by decide)
    · have hi1 : i = 1 := by omega
      subst hj; subst hi1; rw [he0, he1]
      exact iff_of_false (lt_asymm hxt) (by decide)
    · have hi1 : i = 1 := by omega
      have hj1 : j = 1 := by omega
      subst hi1; subst hj1; rw [he1]; simp
  -- Core locus decomposition of the depth-0 atom layer.
  have core : nf_eval_nf M 0 2 (Fin.cons x (fun _ => t)) nf2 ↔
      ((∀ (i j : Fin 2) (h : i ≠ j), (nf2 (.order i j h) = true ↔ (i : Fin 2) < j)) ∧
        (∀ p : sig.preds, M.interp p x ↔ nf2 (.pred p 0) = true) ∧
        (∀ p : sig.preds, M.interp p t ↔ nf2 (.pred p 1) = true)) := by
    simp only [nf_eval_nf]
    constructor
    · intro h
      refine ⟨fun i j hij => ?_, fun p => ?_, fun p => ?_⟩
      · have hraw := h (.order i j hij)
        simp only [atom_eval] at hraw
        rw [env_mono i j] at hraw
        exact hraw.symm
      · have hraw := h (.pred p 0)
        simp only [atom_eval] at hraw
        rw [he0] at hraw
        exact hraw
      · have hraw := h (.pred p 1)
        simp only [atom_eval] at hraw
        rw [he1] at hraw
        exact hraw
    · intro ⟨hord, hxp, htp⟩ a
      cases a with
      | pred p i =>
        simp only [atom_eval]
        by_cases hi : i = 0
        · subst hi; rw [he0]; exact hxp p
        · have hi1 : i = 1 := by omega
          subst hi1; rw [he1]; exact htp p
      | order i j hij =>
        simp only [atom_eval]
        rw [env_mono i j]
        exact (hord i j hij).symm
  -- Assemble: unfold the two syntactic characteristics and combine with `core`.
  rw [nf_char2_atom_offdiag_origin, core]
  simp only [nf_char2_atom_offdiag_endpoint, TemporalPred.eval_at,
    nf_depth0_char_formula_correct, nf2_locus]
  by_cases hg : (∀ (i j : Fin 2) (h : i ≠ j), (nf2 (.order i j h) = true ↔ (i : Fin 2) < j))
  · rw [if_pos hg]
    simp only [nf_depth0_char_formula_correct, nf2_locus]
    -- LHS: (t-preds) ∧ (x-preds); RHS: guard ∧ x-preds ∧ t-preds (guard = hg).
    constructor
    · rintro ⟨htp, hxp⟩; exact ⟨hg, hxp, htp⟩
    · rintro ⟨_, hxp, htp⟩; exact ⟨htp, hxp⟩
  · rw [if_neg hg]
    simp only [temporal_truth]
    -- LHS is `False ∧ _`; RHS forces the guard `hg`, contradiction.
    constructor
    · rintro ⟨hfalse, _⟩; exact hfalse.elim
    · intro heval; exact absurd heval.1 hg

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

/-! ## Phase 3 (task 309): arity-3 endpoint-hook construction (`D2`, new)

The load-bearing endpoint hooks the off-diagonal `F_i` chain needs are the navigated
witnesses' arity-3 characteristics `NormalForm sig k 3 → TemporalPred` that
`nf_zone_flatten_navigable`'s `pastEnd`/`futureEnd` consume: at an exterior witness `w`
(`w < x` past, `t < w` future), the endpoint `TemporalPred`'s `.eval_at w` must capture the
coupled arity-3 evaluation `nf_eval_nf M k 3 (zoneEnv3 w x t) q` one depth down. Divergence
D2: the KampPrior-local `exist_tl_fn_k` is an arity-2 existential converter (a proof-local
`let`, not a top-level asset) and does NOT supply these arity-3 characteristics — they are
genuine new construction, templated on `nf_char2_diag_exist_tl` / `nf_char2_formula`.

`nf_char3_endpoint_tl` is the arity-3, `TemporalPred`-valued analog of the arity-1 template
`nf_succ_char_formula` (KampPrior.lean:66) and the arity-2 diagonal `nf_char2_formula`
(:476): it assembles the endpoint characteristic of `q : NormalForm sig (k+1) 3` at a
navigated witness `y` as `formula_conjList (atomPart :: quant_clauses)`, where each
`quant_clause` wraps the depth-`k`, **arity-4** coupled inner converter `innerConv`
(the recursion hook — one depth down, mirroring how `nf_char2_formula` threads
`nf_char2_diag_exist_tl` and the arity-1 template threads `exist_tl_fn`). It stays
**hook-parametric** over `atomPart` (the arity-3 atom layer at the anchors, supplied by the
Phase-2 off-diagonal atom locus pair in Phase 4) and `innerConv` (the depth-`k` IH); the
assembly and its correctness are proven once, sorry-free.

### Route audit (Postmortem forbidden-route guards)
- **(a)** The correctness matches `nf_eval_nf M (k+1) 3 (zoneEnv3 y x t) q`'s own `k+1`
  unfolding — atom layer at the full env `zoneEnv3 y x t = [y, x, t]` plus, per arity-4 sub,
  the coupled `∃ w` on the full env `Fin.cons w (zoneEnv3 y x t) = [w, y, x, t]`, discharged
  one depth down through `innerConv` (the caller routes it via `nf_char3_deeper_split` /
  `nf_zone_flatten_navigable`, route (c)). No per-variable projection of the coupled layer.
- **(b)** The inner converter's endpoints are the caller's navigated `bracketBuild*`
  `TemporalPred`s; here they stay abstract hooks whose `.eval_at` correctness is the IH.
- **G4** — `y` and every inner `w` are bracket witnesses laid in the `F_i` chain, never free
  anchors; the free-anchor set stays `{x, t} = 2` (`zoneEnv3_arity_invariant`, Rabinovich ≤2
  cap). Rabinovich Cor 5.4 `F_i` endpoint (md:154-157). -/

/-- **Arity-3 endpoint characteristic builder** (task 309 Phase 3, D2). The `TemporalPred`
whose `.eval_at` at a navigated witness `y` captures `nf_eval_nf M (k+1) 3 (zoneEnv3 y x t) q`,
assembled hook-parametrically from `atomPart` (the arity-3 atom layer at the anchors) and
`innerConv` (the depth-`k`, arity-4 coupled inner converter — the recursion hook one depth
down). Exactly the arity-3, `TemporalPred`-valued analog of the arity-1 template
`nf_succ_char_formula` and the arity-2 `nf_char2_formula`: `formula_conjList (atomPart ::
quant_clauses)` with one `nf_quant_clause_tl` per arity-4 sub-NF. -/
noncomputable def nf_char3_endpoint_tl {sig : MonadicSignature} {k : Nat}
    (atomPart : Formula)
    (innerConv : NormalForm sig k 4 → Formula)
    (q : NormalForm sig (k + 1) 3) : TemporalPred :=
  ⟨formula_conjList (atomPart ::
    (Finset.univ.toList : List (NormalForm sig k 4)).map
      (fun sub => nf_quant_clause_tl (innerConv sub) (q.2 sub)))⟩

/-- **Correctness of the arity-3 endpoint characteristic** (task 309 Phase 3, D2). Under the
atom-hook correctness `h_atom` (the arity-3 atom layer at `[y, x, t]`) and the inner-converter
correctness `h_inner` (each arity-4 sub's coupled `∃ w` on `[w, y, x, t]` — the depth-`k` IH),
the assembled endpoint `TemporalPred`'s `.eval_at y` holds iff `q` evaluates on the full
arity-3 env `zoneEnv3 y x t`. Assembled by matching `nf_eval_nf M (k+1) 3`'s own unfolding
(`formula_conjList_iff` + `nf_quant_clause_tl_correct` per clause), exactly mirroring
`nf_char2_formula_correct` one arity up. `y` and every inner `w` stay bracket witnesses;
anchor set `{x, t}` (G4). Rabinovich Cor 5.4 `F_i` endpoint (md:154-157). -/
theorem nf_char3_endpoint_tl_correct {sig : MonadicSignature} {k : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (y x t : M.carrier)
    (atomPart : Formula)
    (innerConv : NormalForm sig k 4 → Formula)
    (q : NormalForm sig (k + 1) 3)
    (h_atom : temporal_truth M atomMap y atomPart ↔
      (∀ a : AtomKind sig 3, atom_eval M (zoneEnv3 y x t) a ↔ (q.1 a = true)))
    (h_inner : ∀ sub : NormalForm sig k 4,
      temporal_truth M atomMap y (innerConv sub) ↔
        ∃ w : M.carrier, nf_eval_nf M k 4 (Fin.cons w (zoneEnv3 y x t)) sub) :
    (nf_char3_endpoint_tl atomPart innerConv q).eval_at M atomMap y ↔
      nf_eval_nf M (k + 1) 3 (zoneEnv3 y x t) q := by
  simp only [nf_char3_endpoint_tl, TemporalPred.eval_at]
  rw [formula_conjList_iff]
  change _ ↔ (∀ (a : AtomKind sig 3), atom_eval M (zoneEnv3 y x t) a ↔ (q.1 a = true)) ∧
    (∀ (sub : NormalForm sig k 4),
      (∃ (w : M.carrier), nf_eval_nf M k 4 (Fin.cons w (zoneEnv3 y x t)) sub) ↔
        (q.2 sub = true))
  have quant_mem : ∀ sub : NormalForm sig k 4,
      nf_quant_clause_tl (innerConv sub) (q.2 sub) ∈
        List.map (fun sub => nf_quant_clause_tl (innerConv sub) (q.2 sub))
          Finset.univ.toList :=
    fun sub => List.mem_map.mpr
      ⟨sub, Finset.mem_toList.mpr (Finset.mem_univ sub), rfl⟩
  constructor
  · intro h_all
    constructor
    · have h_at := h_all _ (.head _)
      exact h_atom.mp h_at
    · intro sub
      have h_clause := h_all _ (.tail _ (quant_mem sub))
      rw [nf_quant_clause_tl_correct M atomMap y _ _ _ (h_inner sub)] at h_clause
      exact h_clause
  · intro ⟨h_atoms, h_quants⟩ φ h_mem
    cases h_mem with
    | head => exact h_atom.mpr h_atoms
    | tail _ h_tail =>
      obtain ⟨sub, _, rfl⟩ := List.mem_map.mp h_tail
      rw [nf_quant_clause_tl_correct M atomMap y _ _ _ (h_inner sub)]
      exact h_quants sub

/-! ## Phase 6 (task 309): depth-0 navigated arity-3 endpoint base `endChar0` + `endChar` interface

The base of the recursion for the missing primitive (report 02 §1.4): the closed navigated arity-3
endpoint characteristic `endChar : NormalForm sig k 3 → TemporalPred` with
`(endChar qnf).eval_at M atomMap w ↔ nf_eval_nf M k 3 (zoneEnv3 w a b) qnf` for a navigated witness
`w` and two fixed anchors `{a, b} ⊆ {x, t}`, by recursion on `k`, arity capped at 3 (G4). This phase
delivers the `k = 0` base `endChar0` and fixes the `endChar` interface (`EndCharCarrier`) that Phase 8
recurses on; Phase 7 supplies the non-trivial interior segment, Phase 8 the step assembly.

### Base-case status (report 02 §4.3, Phase-6 §4.3 FALLBACK — TRIGGERED)

Report 02 §4.3 flagged the depth-0 navigated base as the primary open sub-question (Medium risk):
`nf_nvar_exist_depth0_tl_fn` (NfDepth0Generalized:1615) is **existential-at-origin**, not the
**navigated-point** arity-3 characteristic the primitive needs. This dispatch confirms the risk BINDS
structurally: at depth 0, `nf_eval_nf M 0 3 (zoneEnv3 w a b) qnf` unfolds (NormalForm.lean:201) to the
pure atom layer `∀ atom : AtomKind sig 3, atom_eval M (zoneEnv3 w a b) atom ↔ (qnf atom = true)` over
env `(w, a, b)` — which asserts predicate literals at the **two fixed anchor positions** `a` (index 1)
and `b` (index 2) and the order relations among `{w, a, b}`. A **closed** `TemporalPred` (a syntactic
`Formula`, ExistsForallNF:49) whose `.eval_at` is `temporal_truth … w` (ExistsForallNF:53) can only
read predicates **locally at `w`** or at points **reached by temporal navigation** from `w`; it cannot
reference the arbitrary carrier anchors `a, b : M.carrier` as free values. Pinning `a = x` and `b = t`
is exactly what the Rabinovich `β_i` **non-trivial segment** does (report 02 §4.2, G3): the segment
riding the outer `bracketBuildLeft`/`bracketBuildRight` navigation reaches the anchors and fixes the
order zone. That segment is the deliverable of **Phase 7** and is not yet built, so the standalone
depth-0 navigated correctness cannot be closed within this phase's H8 budget.

Phase-6 landed `endChar0` fully defined (a genuine, non-vacuous `w`-locus atom characteristic — the
part of the arity-3 atom layer a navigated-`w` `TemporalPred` CAN read locally), the `w`-locus
correctness `endChar0_wlocus_correct` proved **sorry-free**, and the `EndCharCarrier` interface fixed;
the full navigated `endChar0_correct` was landed under the §4.3 FALLBACK with a flagged strategic sorry.

**Phase-8 update (task 309 P8): that strategic sorry is DISCHARGED and the statement CORRECTED.** The
Phase-6 free-anchor form was provably FALSE (a closed navigated-`w` `TemporalPred` cannot read the
arbitrary carrier anchors `a, b`; concrete counterexample in `endChar0_correct`'s docstring below). The
faithful base case adds the anchor+order **residual** hypothesis `h_res` — the very data the enclosing
bracket exteriors / `x < w < t` witness bound pin as `a = x`, `b = t` (report 02 §4.2, G3/G4) — under
which `endChar0` discharges the full depth-0 arity-3 atom layer **sorry-free**. The remaining Phase-8
deliverable, the *recursive* primitive `endChar : NormalForm sig k 3 → TemporalPred` + `endChar_correct`
(recursion on `k`), is NOT built here: the `nf_eval_nf` quant layer at depth `k+1` structurally needs
arity-4 sub-evaluations `∃ x', nf_eval_nf M k 4 (Fin.cons x' (zoneEnv3 w a b)) sub`, which the fixed
arity-3 `EndCharCarrier` interface cannot recursively consume without the brick-witness-collapse core
(report 02 §4.1/§4.2, ~300-500 lines; anchor-management, NOT `nf_char3_deeper_split`). See the
orchestrator handoff `follow_up_task` for that residual core.

### Route audit (Postmortem forbidden-route guards)
- **G1** — no arity-1 collapse: `endChar0` reads the honest arity-3 atom layer's `w`-locus; the full
  correctness targets `nf_eval_nf M 0 3 (zoneEnv3 w a b) qnf` (arity 3), never a flat arity-1 term.
- **G4** — anchors stay `{a, b} ⊆ {x, t}` (≤2 cap); `w` is the navigated bracket witness, never a
  third free anchor. `zoneEnv3 w a b` env arity is exactly 3 (`{w, a, b}`, two anchors + witness). -/

/-- Position-0 (navigated-witness `w`) locus projection of an arity-3 depth-0 NF: fix the witness
index `0` and read off the predicate assignment there. Order atoms are vacuous at arity 1 (`Fin 1` is
a subsingleton). The two anchor loci (indices 1, 2) and the order layer among `{w, a, b}` are supplied
by the Phase-7 non-trivial segment in the full assembly — they cannot be read locally at the navigated
witness `w`. Mirrors `nf2_locus` one arity up. -/
def nf3_locus0 {sig : MonadicSignature} (nf3 : NormalForm sig 0 3) : NormalForm sig 0 1 :=
  fun a => match a with
    | .pred p _ => nf3 (.pred p (0 : Fin 3))
    | .order j j' h => absurd (Subsingleton.elim j j') h

/-- **Depth-0 navigated arity-3 endpoint base** (task 309 Phase 6). The `TemporalPred` carrying the
`w`-position (index 0) predicate atoms of the depth-0 arity-3 NF `qnf`, checked at the navigated
witness `w`. This is the `k = 0` base of the recursive primitive `endChar` (report 02 §1.4): the part
of the arity-3 atom layer `nf_eval_nf M 0 3 (zoneEnv3 w a b) qnf` that a navigated-`w` `TemporalPred`
reads locally. The anchor-position (`a`, `b`) predicates and the order layer are coupled by the Phase-7
non-trivial `β_i` segment in the full assembly (report 02 §4.2; see `endChar0_correct`). `w` is a
bracket witness, never a free anchor (G4). Reuses the depth-0 atom-literal conjunction
`nf_depth0_char_formula` via the position-0 projection `nf3_locus0`. -/
noncomputable def endChar0 {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (qnf : NormalForm sig 0 3) : TemporalPred :=
  ⟨nf_depth0_char_formula atomMap h_surj (nf3_locus0 qnf)⟩

/-- **Interface signature for the recursive navigated endpoint primitive** (task 309 Phase 6, report
02 §1.4). The recursion carrier Phase 8 assembles by recursion on `k`: the closed navigated arity-3
endpoint characteristic, base `endChar0` (`k = 0`, this phase), step = navigable-brick flatten +
Phase-7 non-trivial segment for the interior + Phase-6/8 endpoints for the exteriors, arity capped at
3 (G4). Fixed here so Phases 7-9 dispatch against a stable type. `endChar0` inhabits `EndCharCarrier
sig 0`. -/
abbrev EndCharCarrier (sig : MonadicSignature) (k : Nat) : Type :=
  NormalForm sig k 3 → TemporalPred

/-- **`w`-locus correctness of `endChar0`** (task 309 Phase 6, sorry-free leaf). The navigated base's
`.eval_at w` characterizes exactly the position-0 (`w`) predicate layer of `qnf`:
`∀ p, M.interp p w ↔ qnf (.pred p 0) = true`. Direct from `nf_depth0_char_formula_correct` through the
position-0 projection `nf3_locus0`. This is the locally-readable fragment of the full arity-3 atom
layer; the anchor coupling is added by the Phase-7 segment (see `endChar0_correct`). -/
theorem endChar0_wlocus_correct {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (qnf : NormalForm sig 0 3) (w : M.carrier) :
    (endChar0 atomMap h_surj qnf).eval_at M atomMap w ↔
      (∀ p : sig.preds, M.interp p w ↔ qnf (.pred p (0 : Fin 3)) = true) := by
  simp only [endChar0, TemporalPred.eval_at]
  rw [nf_depth0_char_formula_correct]
  constructor
  · intro h p
    have := h p
    simpa only [nf3_locus0] using this
  · intro h p
    have := h p
    simpa only [nf3_locus0] using this

/-- **Base-case discharge of the navigated arity-3 endpoint characteristic under the anchor residual**
(task 309 Phase 8; DISCHARGES and CORRECTS the Phase-6 §4.3 strategic sorry — see the deviation note).
The `k = 0` base of the report-02 §1.4 primitive.

**Why the Phase-6 free-anchor statement was false (concrete counterexample, G-diligence).** The
Phase-6 `endChar0_correct` asserted `(endChar0 qnf).eval_at w ↔ nf_eval_nf M 0 3 (zoneEnv3 w a b) qnf`
for *arbitrary* `a b : M.carrier`, with a strategic `sorry`. That biconditional is provably FALSE, not
merely hard: `endChar0`'s `.eval_at w = temporal_truth M atomMap w …` depends only on `M` and the
navigated witness `w`, whereas the RHS `nf_eval_nf M 0 3 (zoneEnv3 w a b) qnf` unfolds
(NormalForm.lean:201) to `∀ atom, atom_eval M (zoneEnv3 w a b) atom ↔ qnf atom = true`, which also
constrains the predicate layer at the anchor positions `a` (index 1: `atom_eval (.pred p 1) =
M.interp p a`), `b` (index 2), and the order relations among `{w, a, b}` (`.order` atoms). Take `qnf`
with `qnf (.pred p 1) = true` while `M.interp p a = false`: the RHS fails, but the LHS (reading only
the `w`-locus, `nf3_locus0`) is unaffected — refuting the `↔`. A *closed* navigated-`w` `TemporalPred`
cannot reference the arbitrary carrier anchors `a, b` as free values (report 02 §4.3 flagged the risk;
this dispatch confirms it BINDS at the statement level).

**Faithful base case (the mission's "pin a=x, b=t via the enclosing bracket witnesses").** The anchor
predicate layers and the order zone among `{w, a, b}` are exactly the **residual** `h_res`, supplied in
the full assembly by the bracket exteriors / the `x < w < t` witness bound that pin `a = x`, `b = t`
(report 02 §4.2, G3/G4 — the non-trivial `β_i` segment machinery). Under `h_res`, `endChar0`'s
locally-readable `w`-position predicate layer (`endChar0_wlocus_correct`) discharges the FULL depth-0
arity-3 atom layer, sorry-free. This is the correctly-hypothesized `k = 0` instance the recursion's
base wiring consumes; `w` stays a bracket witness (G4), anchors `{a, b} ⊆ {x, t}` (≤2 cap). -/
theorem endChar0_correct {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (qnf : NormalForm sig 0 3) (w a b : M.carrier)
    (h_res : ∀ atom : AtomKind sig 3, (∀ p : sig.preds, atom ≠ AtomKind.pred p 0) →
      (atom_eval M (zoneEnv3 w a b) atom ↔ (qnf atom = true))) :
    (endChar0 atomMap h_surj qnf).eval_at M atomMap w ↔
      nf_eval_nf M 0 3 (zoneEnv3 w a b) qnf := by
  rw [endChar0_wlocus_correct]
  simp only [nf_eval_nf]
  have hw0 : (zoneEnv3 w a b : Fin 3 → M.carrier) 0 = w := by
    simp only [zoneEnv3, Fin.cons_zero]
  constructor
  · -- w-locus layer + residual ⇒ full atom layer
    intro hpred atom
    cases atom with
    | pred p i =>
      by_cases hi : i = 0
      · subst hi
        show atom_eval M (zoneEnv3 w a b) (AtomKind.pred p 0) ↔ qnf (.pred p 0) = true
        simp only [atom_eval, hw0]
        exact hpred p
      · exact h_res (.pred p i) (fun p' heq => by injection heq with _ hi0; exact hi hi0)
    | order i j hij =>
      exact h_res (.order i j hij) (fun _ heq => by simp at heq)
  · -- full atom layer ⇒ w-locus layer
    intro hall p
    have hp := hall (.pred p 0)
    simp only [atom_eval, hw0] at hp
    exact hp

/-! ## Phase 7 (task 309): non-trivial interior `β_i` segment `seg` + `holds`-correctness

Rabinovich 2014 Cor 5.4 (md:154-157): `F_{i-1} := α_{i-1} ∧ (β_i Until F_i)`. The interior `β_i`
segment is the interval-type that must hold throughout the open interval `(x, t)` between the two
fixed anchors; the bound `F_i` witness `w` (a *bracket* witness inside `(x, t)`, never a free
anchor — G4) carries the per-`qnf` navigated interior characteristic `endChar qnf` (the Phase-6/8
interface predicate `EndCharCarrier`). This phase builds that segment as a `BracketFormula 0` whose
single interval type is the interface predicate `endChar qnf` (NON-trivial: the real interior
characteristic, not `TemporalPred.top` — G3), and proves its `holds`-shape reduction
(`seg_holds_correct`) plus the hook-parametric coupling to the `nf_eval_nf` interior evaluation
(`seg_holds_coupled`).

A `BracketFormula 0` `.holds` is *definitionally* the universal-over-interval form
`∀ y ∈ (x, t), (segType).eval_at y` (`IntervalPattern.holds` at `n = 0`,
ExistsForallNF:110-112; `BracketFormula.trivial_holds`). That is exactly Rabinovich's `β_i`: the
interval type holding throughout the open interval up to the `F_i` witness. The `∃ w` interior
existential named in the Phase-7 deliverable is recovered when this segment is placed as the
interior interval-type of the enclosing `bracketBuildLeft` witness bracket in the Phase-8 assembly
(the witness is laid by the bracket, the `β_i` rides between bracket endpoints) — not by `seg`
alone, which stays a pure `BracketFormula 0` interval-type per the plan's signature.

### Route audit (Postmortem forbidden-route guards)
- **G3** — `seg`'s interval type is the genuine `endChar qnf` interior characteristic (parametric,
  non-`⊤`); the off-diagonal `(x, t)` interior rides this non-trivial segment, never a trivial-top.
- **G4** — anchors stay `{x, t} = 2`; the interior point `y` is a bracket witness of the enclosing
  bracket, never a third free anchor; `endChar : NormalForm sig k 3 → TemporalPred` keeps arity ≤ 3.
- **G5** — the segment is exactly the `β_i` of the Cor 5.4 chain step (md:154-157); its `holds`
  reduction is proved manually through `BracketFormula.trivial_holds`, and the coupling bridge is a
  manual `constructor`/`intro` (no `simp`/`omega`/`aesop` shortcut of the chain step). The `(x, t)`
  coupling stays a hook (`h_endChar`), discharged in Phase 8 via `endChar_correct` exactly as
  Phases 4/5 defer their `h_quant` coupling — NOT a `sorry`.
-/

/-- **`seg`** (task 309 Phase 7): the Rabinovich `β_i` non-trivial interior segment (md:154-157).
A `BracketFormula 0` whose single interval type is the Phase-6/8 interface predicate `endChar qnf`
— the per-`qnf` navigated interior characteristic that must hold at the bound `F_i` witness inside
`(x, t)`. NON-trivial in the G3 sense: the interval type is the real interior characteristic, not
`TemporalPred.top`. `endChar` is the recursion carrier fixed in Phase 6 (`EndCharCarrier`); Phase 8
instantiates it with the depth-`k` recursion (base `endChar0`, step brick+seg). -/
noncomputable def seg {sig : MonadicSignature} {k : Nat}
    (endChar : EndCharCarrier sig k) (qnf : NormalForm sig k 3) : BracketFormula 0 :=
  BracketFormula.trivial (endChar qnf)

/-- **`seg_holds_correct`** (task 309 Phase 7, sorry-free leaf): the interior segment holds on
`(x, t)` iff the interface predicate `endChar qnf` holds at every interior point — the `β_i`
universal-over-interval characterization the enclosing `bracketBuildLeft` consumes (Rabinovich
md:154-157). Direct through `BracketFormula.trivial_holds`. Anchors `{x, t}` (G4); the interval
type is the genuine `endChar qnf`, not `⊤` (G3). -/
theorem seg_holds_correct {sig : MonadicSignature} {k : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (endChar : EndCharCarrier sig k) (qnf : NormalForm sig k 3) (x t : M.carrier) :
    (seg endChar qnf).holds M atomMap x t ↔
      ∀ y : M.carrier, x < y → y < t → (endChar qnf).eval_at M atomMap y := by
  simp only [seg]
  exact BracketFormula.trivial_holds M atomMap (endChar qnf) x t

/-- **`seg_holds_coupled`** (task 309 Phase 7): under the per-point interface-correctness hook
`h_endChar` — `(endChar qnf).eval_at y ↔ nf_eval_nf M k 3 (zoneEnv3 y x t) qnf`, the coupling
Phase 8 discharges via `endChar_correct` — the segment holds on `(x, t)` iff the interior arity-3
navigated evaluation holds throughout the open interval. This is the `nf_eval_nf`-coupled interior
form named in the Phase-7 deliverable. The coupling stays a hook (as Phases 4/5 defer `h_quant`),
NOT a `sorry`. Anchors provably `{x, t}` (G4); manual bridge, no tactic shortcut (G5). -/
theorem seg_holds_coupled {sig : MonadicSignature} {k : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (endChar : EndCharCarrier sig k) (qnf : NormalForm sig k 3) (x t : M.carrier)
    (h_endChar : ∀ y : M.carrier,
      (endChar qnf).eval_at M atomMap y ↔ nf_eval_nf M k 3 (zoneEnv3 y x t) qnf) :
    (seg endChar qnf).holds M atomMap x t ↔
      ∀ y : M.carrier, x < y → y < t → nf_eval_nf M k 3 (zoneEnv3 y x t) qnf := by
  rw [seg_holds_correct]
  constructor
  · intro h y hxy hyt
    exact (h_endChar y).mp (h y hxy hyt)
  · intro h y hxy hyt
    exact (h_endChar y).mpr (h y hxy hyt)

/-! ## Phase 4 (task 309): `nf_char2_past_formula` + `_correct` — the off-diagonal `F_i` chain past arm

The load-bearing new object. Assembles the OUTER non-trivial-segment `bracketBuildLeft` navigation
(`A_past`, Phase 1) walking from the fixed origin `t` back into the past exterior to the bound
witness `x < t`, whose endpoint at `x` conjoins the Phase-2 off-diagonal endpoint atom locus with a
caller-supplied quant-endpoint hook `quantEnd`. The Phase-2 origin atom locus (t-position preds +
off-diagonal order guard) factors OUT of the `∃ x` (it is `x`-independent once `x < t` is fixed).

Rabinovich 2014 Cor 5.4 `F_i` chain (md:154-157): `F_{i-1} := α_{i-1} ∧ (β_i Until F_i)`. Here the
past arm is the `Since`-dual: the outer `bracketBuildLeft` is the `β_i` past bracket, `x` is the bound
`F_i` witness (a bracket witness, never a free anchor — G4), and the `(x, t)` quant coupling rides the
non-trivial segment `seg` (G3: no trivial-top segment on the off-diagonal arm — `seg` is a parameter,
not the hardcoded `BracketFormula.trivial TemporalPred.top`).

The depth-`(k+1)` arity-2 evaluation at `[x, t]` decomposes (definitionally, matching `nf_eval_nf`'s
own `k+1` unfolding) into the depth-0 atom layer `nf_eval_nf M 0 2 [x, t] sub_nf.1` and, per arity-3
sub-NF `qnf`, the coupled inner existential `∃ w, nf_eval_nf M k 3 (zoneEnv3 w x t) qnf` matching
`sub_nf.2 qnf`. The atom layer is discharged by Phase 2 (`nf_char2_atom_offdiag_correct`); the quant
layer is the honest depth-`k` IH, deferred to the hook-correctness hypothesis `h_quant` (discharged
one level up by the caller via `nf_zone_flatten_navigable_brick` + the Phase-3 endpoint hooks —
exactly as `nf_char2_formula_correct` / `A_diag_correct` defer their coupling to `h_exist_correct` /
`h_past`/`h_fut`/`h_diag`). `zoneEnv3 w x t = Fin.cons w (Fin.cons x (fun _ => t))` so the inner env
matches `nf_eval_nf`'s `Fin.cons w [x, t]` verbatim (route (a)/(c): env arity stays `≤ 3`, anchor set
`{x, t}`, `zoneEnv3_arity_invariant`).

### Route audit (Postmortem forbidden-route guards)
- **G1** — no arity-1 collapse: the depth-`(k+1)` quant layer routes through the honest arity-3
  coupled existential `∃ w, nf_eval_nf M k 3 (zoneEnv3 w x t) qnf`, never a flat arity-1 term.
- **G2** — no projection `VecEA2` / third-free-anchor tower: `x` is laid by the outer bracket; the
  only anchors are `{x, t}`.
- **G3** — the `(x, t)` coupling rides `seg` (a non-trivial `BracketFormula 0` parameter) and the
  navigated endpoint, never a trivial-top segment.
- **G4** — `x` and every inner `w` are bracket witnesses; the free-anchor set stays `{x, t} = 2`.
- **G5** — the `F_i` chain step is `A_past seg (endpoint atom ∧ quantEnd)` built explicitly via
  `A_past_correct` (Rabinovich md:154-157); the final propositional glue is fully manual (no
  `simp`/`omega`/`aesop` shortcut of the chain step).
-/

/-- **`nf_char2_past_formula`** (task 309 Phase 4): the off-diagonal (`x < t`) two-anchor navigated
characteristic FORMULA, past arm. The Phase-2 origin atom locus (checked at `t`, `x`-independent)
conjoined with the Phase-1 `A_past` outer `bracketBuildLeft` navigation over the caller's non-trivial
segment `seg`, whose endpoint at the bound witness `x` conjoins the Phase-2 endpoint atom locus with
the quant-endpoint hook `quantEnd`. Rabinovich Cor 5.4 `F_i` chain past arm (md:154-157). -/
noncomputable def nf_char2_past_formula {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    {k : Nat}
    (quantEnd : TemporalPred)
    (seg : BracketFormula 0)
    (sub_nf : NormalForm sig (k + 1) 2) : Formula :=
  Formula.and
    (nf_char2_atom_offdiag_origin atomMap h_surj (sub_nf.1 : NormalForm sig 0 2))
    (A_past seg
      (TemporalPred.conj
        (nf_char2_atom_offdiag_endpoint atomMap h_surj (sub_nf.1 : NormalForm sig 0 2))
        quantEnd))

/-- **Correctness of `nf_char2_past_formula`** (task 309 Phase 4). Under the quant-endpoint-hook
correctness hypothesis `h_quant` (the depth-`k` IH: at each past witness `x < t`, the hook's
`.eval_at x` conjoined with the segment `seg` holding on `(x, t)` characterizes the coupled arity-3
quant layer of `sub_nf` at `[x, t]`, one depth down), the past-arm formula holds at `t` iff there is a
past witness `x < t` where `sub_nf` evaluates on the two-anchor env `[x, t]`. Assembled from
`temporal_truth_and` (origin factor split) + `A_past_correct` (Phase 1 outer bracket) +
`nf_char2_atom_offdiag_correct` (Phase 2 atom locus) + the depth-`(k+1)` `nf_eval_nf` unfolding, with
the quant layer routed through `h_quant`. `zoneEnv3 w x t = Fin.cons w (Fin.cons x (fun _ => t))`
matches `nf_eval_nf`'s inner env. Rabinovich Cor 5.4 `F_i` chain (md:154-157). -/
theorem nf_char2_past_formula_correct {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    {k : Nat}
    (quantEnd : TemporalPred)
    (seg : BracketFormula 0)
    (M : OrderedMonadicStructure sig) (t : M.carrier)
    (sub_nf : NormalForm sig (k + 1) 2)
    (h_quant : ∀ x : M.carrier, x < t →
      ((quantEnd.eval_at M atomMap x ∧ seg.holds M atomMap x t) ↔
        (∀ qnf : NormalForm sig k 3,
          (∃ w, nf_eval_nf M k 3 (zoneEnv3 w x t) qnf) ↔ (sub_nf.2 qnf = true)))) :
    temporal_truth M atomMap t
        (nf_char2_past_formula atomMap h_surj quantEnd seg sub_nf) ↔
      ∃ x, x < t ∧ nf_eval_nf M (k + 1) 2 (Fin.cons x (fun _ => t)) sub_nf := by
  -- Conjunction of temporal predicates unfolds to conjunction of evaluations.
  have conj_eval : ∀ (a b : TemporalPred) (z : M.carrier),
      (TemporalPred.conj a b).eval_at M atomMap z ↔
        a.eval_at M atomMap z ∧ b.eval_at M atomMap z := by
    intro a b z
    simp only [TemporalPred.conj, TemporalPred.eval_at]
    exact temporal_truth_and M atomMap z a.formula b.formula
  -- Per-witness decomposition of the depth-(k+1) evaluation at [x, t].
  have key : ∀ x : M.carrier, x < t →
      (nf_eval_nf M (k + 1) 2 (Fin.cons x (fun _ => t)) sub_nf ↔
        (temporal_truth M atomMap t
            (nf_char2_atom_offdiag_origin atomMap h_surj (sub_nf.1 : NormalForm sig 0 2)) ∧
          (nf_char2_atom_offdiag_endpoint atomMap h_surj
            (sub_nf.1 : NormalForm sig 0 2)).eval_at M atomMap x) ∧
        (quantEnd.eval_at M atomMap x ∧ seg.holds M atomMap x t)) := by
    intro x hx
    have hunf : nf_eval_nf M (k + 1) 2 (Fin.cons x (fun _ => t)) sub_nf ↔
        (nf_eval_nf M 0 2 (Fin.cons x (fun _ => t)) (sub_nf.1 : NormalForm sig 0 2)) ∧
        (∀ qnf : NormalForm sig k 3,
          (∃ w, nf_eval_nf M k 3 (zoneEnv3 w x t) qnf) ↔ (sub_nf.2 qnf = true)) :=
      Iff.rfl
    rw [hunf, ← nf_char2_atom_offdiag_correct M atomMap h_surj
          (sub_nf.1 : NormalForm sig 0 2) x t hx, ← h_quant x hx]
  simp only [nf_char2_past_formula]
  rw [temporal_truth_and, A_past_correct]
  simp only [conj_eval]
  constructor
  · rintro ⟨horig, z0, hz0, ⟨hend, hqe⟩, hseg⟩
    exact ⟨z0, hz0, (key z0 hz0).mpr ⟨⟨horig, hend⟩, hqe, hseg⟩⟩
  · rintro ⟨x, hx, hnf⟩
    obtain ⟨⟨horig, hend⟩, hqe, hseg⟩ := (key x hx).mp hnf
    exact ⟨horig, x, hx, ⟨hend, hqe⟩, hseg⟩

/-! ## Phase 5 (task 309): `nf_char2_future_formula` + `_correct` — the off-diagonal `F_i` chain future arm

The exact structural DUAL of Phase 4 (`nf_char2_past_formula`/`_correct`). The outer navigation is
`A_future seg futureEnd` (`bracketBuildRight`, Phase 1) walking from the fixed origin `t` FORWARD into
the future exterior to the bound witness `x` with `t < x`, whose endpoint at `x` conjoins the Phase-2
off-diagonal endpoint atom locus with a caller-supplied quant-endpoint hook `quantEnd`.

The one genuinely direction-sensitive piece: the future RHS env is `Fin.cons x (fun _ => t)` with
`t < x`, so `env 0 = x` is now GREATER than `env 1 = t` (the env is antitone, not monotone as in the
past arm). The order atom `.order i j` evaluates to `env i < env j ↔ (j : Fin 2) < i`, so the origin
atom guard must be the FLIPPED off-diagonal guard `nf2 (.order i j h) = true ↔ (j : Fin 2) < i`
(Phase-2 atom layer, order direction flipped — plan §Phase 5). The endpoint atom locus (`x`-position
preds at the navigated `x`) is direction-INDEPENDENT and is reused verbatim
(`nf_char2_atom_offdiag_endpoint`).

Rabinovich 2014 Cor 5.4 `F_i` chain future arm (md:154-157): `F_{i-1} := α_{i-1} ∧ (β_i Until F_i)` —
the `Until`-form (future) dual of the past arm's `Since`-form. The outer `bracketBuildRight` is the
`β_i` future bracket, `x` is the bound `F_i` witness (a bracket witness, never a free anchor — G4), and
the `(t, x)` quant coupling rides the non-trivial segment `seg` (G3: no trivial-top segment on the
off-diagonal arm). Env arity stays `≤ 3`, anchor set `{x, t} = 2` (G4); the depth-`k` IH is deferred to
the hook-correctness hypothesis `h_quant` (G1: honest arity-3 coupled existential, no arity-1 collapse;
G2: no projection tower); the final propositional glue is fully manual (G5: no `simp`/`omega`/`aesop`
shortcut of the chain step). -/

/-- **Off-diagonal origin atom characteristic, future arm** (task 309 Phase 5). Dual of
`nf_char2_atom_offdiag_origin`: carries the `t`-position predicate atoms of `nf2` asserted at the origin
`t`, guarded by the FLIPPED off-diagonal order consistency (`nf2 (.order i j h) = true` iff its index
pair is strictly DEcreasing — matching the future env `Fin.cons x (fun _ => t)` with `t < x`, where
`env 0 = x > env 1 = t`). Collapses to `⊥` when the order layer is not future-off-diagonal-consistent.
Rabinovich Cor 5.4 future arm endpoint atom coupling (md:154-157). -/
noncomputable def nf_char2_atom_offdiag_origin_future {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (nf2 : NormalForm sig 0 2) : Formula :=
  if (∀ (i j : Fin 2) (h : i ≠ j), (nf2 (.order i j h) = true ↔ (j : Fin 2) < i)) then
    nf_depth0_char_formula atomMap h_surj (nf2_locus nf2 1)
  else
    Formula.bot

/-- **Correctness of the off-diagonal atom layer, future arm** (task 309 Phase 5). Given the strict
order `t < x` (future), the two-anchor depth-0 atom layer `nf_eval_nf M 0 2 [x, t] nf2` holds iff BOTH
the future origin characteristic (t-position preds + FLIPPED order guard) holds at `t` AND the endpoint
characteristic (x-position preds) holds at `x`. Exact dual of `nf_char2_atom_offdiag_correct`: the
antitone env `Fin.cons x (fun _ => t)` (`env 0 = x > env 1 = t`) makes the order atom
`.order i j` evaluate to `env i < env j ↔ (j : Fin 2) < i`. Rabinovich Cor 5.4 future arm
(md:154-157). -/
theorem nf_char2_atom_offdiag_correct_future {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (nf2 : NormalForm sig 0 2) (x t : M.carrier) (hxt : t < x) :
    (temporal_truth M atomMap t (nf_char2_atom_offdiag_origin_future atomMap h_surj nf2) ∧
      (nf_char2_atom_offdiag_endpoint atomMap h_surj nf2).eval_at M atomMap x) ↔
    nf_eval_nf M 0 2 (Fin.cons x (fun _ => t)) nf2 := by
  -- Environment values: position 0 ↦ x, position 1 ↦ t.
  have he0 : (Fin.cons x (fun _ => t) : Fin 2 → M.carrier) 0 = x := by
    simp
  have he1 : (Fin.cons x (fun _ => t) : Fin 2 → M.carrier) 1 = t := by
    simp
  -- The env is strictly ANTItone: `env i < env j ↔ j < i` (since `t < x`).
  have env_mono : ∀ (i j : Fin 2),
      ((Fin.cons x (fun _ => t) : Fin 2 → M.carrier) i <
        (Fin.cons x (fun _ => t) : Fin 2 → M.carrier) j) ↔ (j < i) := by
    intro i j
    by_cases hi : i = 0 <;> by_cases hj : j = 0
    · subst hi; subst hj; rw [he0]; simp
    · have hj1 : j = 1 := by omega
      subst hi; subst hj1; rw [he0, he1]
      exact iff_of_false (lt_asymm hxt) (by decide)
    · have hi1 : i = 1 := by omega
      subst hj; subst hi1; rw [he0, he1]
      exact iff_of_true hxt (by decide)
    · have hi1 : i = 1 := by omega
      have hj1 : j = 1 := by omega
      subst hi1; subst hj1; rw [he1]; simp
  -- Core locus decomposition of the depth-0 atom layer (flipped order guard).
  have core : nf_eval_nf M 0 2 (Fin.cons x (fun _ => t)) nf2 ↔
      ((∀ (i j : Fin 2) (h : i ≠ j), (nf2 (.order i j h) = true ↔ (j : Fin 2) < i)) ∧
        (∀ p : sig.preds, M.interp p x ↔ nf2 (.pred p 0) = true) ∧
        (∀ p : sig.preds, M.interp p t ↔ nf2 (.pred p 1) = true)) := by
    simp only [nf_eval_nf]
    constructor
    · intro h
      refine ⟨fun i j hij => ?_, fun p => ?_, fun p => ?_⟩
      · have hraw := h (.order i j hij)
        simp only [atom_eval] at hraw
        rw [env_mono i j] at hraw
        exact hraw.symm
      · have hraw := h (.pred p 0)
        simp only [atom_eval] at hraw
        rw [he0] at hraw
        exact hraw
      · have hraw := h (.pred p 1)
        simp only [atom_eval] at hraw
        rw [he1] at hraw
        exact hraw
    · intro ⟨hord, hxp, htp⟩ a
      cases a with
      | pred p i =>
        simp only [atom_eval]
        by_cases hi : i = 0
        · subst hi; rw [he0]; exact hxp p
        · have hi1 : i = 1 := by omega
          subst hi1; rw [he1]; exact htp p
      | order i j hij =>
        simp only [atom_eval]
        rw [env_mono i j]
        exact (hord i j hij).symm
  -- Assemble: unfold the two syntactic characteristics and combine with `core`.
  rw [nf_char2_atom_offdiag_origin_future, core]
  simp only [nf_char2_atom_offdiag_endpoint, TemporalPred.eval_at,
    nf_depth0_char_formula_correct, nf2_locus]
  by_cases hg : (∀ (i j : Fin 2) (h : i ≠ j), (nf2 (.order i j h) = true ↔ (j : Fin 2) < i))
  · rw [if_pos hg]
    simp only [nf_depth0_char_formula_correct, nf2_locus]
    constructor
    · rintro ⟨htp, hxp⟩; exact ⟨hg, hxp, htp⟩
    · rintro ⟨_, hxp, htp⟩; exact ⟨htp, hxp⟩
  · rw [if_neg hg]
    simp only [temporal_truth, false_and]
    exact iff_of_false not_false (fun h => hg h.1)

/-- **`nf_char2_future_formula`** (task 309 Phase 5): the off-diagonal (`t < x`) two-anchor navigated
characteristic FORMULA, future arm. Dual of `nf_char2_past_formula`. The Phase-5 future origin atom
locus (checked at `t`, `x`-independent, flipped order guard) conjoined with the Phase-1 `A_future`
outer `bracketBuildRight` navigation over the caller's non-trivial segment `seg`, whose endpoint at the
bound witness `x` conjoins the Phase-2 endpoint atom locus with the quant-endpoint hook `quantEnd`.
Rabinovich Cor 5.4 `F_i` chain future arm (md:154-157). -/
noncomputable def nf_char2_future_formula {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    {k : Nat}
    (quantEnd : TemporalPred)
    (seg : BracketFormula 0)
    (sub_nf : NormalForm sig (k + 1) 2) : Formula :=
  Formula.and
    (nf_char2_atom_offdiag_origin_future atomMap h_surj (sub_nf.1 : NormalForm sig 0 2))
    (A_future seg
      (TemporalPred.conj
        (nf_char2_atom_offdiag_endpoint atomMap h_surj (sub_nf.1 : NormalForm sig 0 2))
        quantEnd))

/-- **Correctness of `nf_char2_future_formula`** (task 309 Phase 5). Dual of
`nf_char2_past_formula_correct`. Under the quant-endpoint-hook correctness hypothesis `h_quant` (the
depth-`k` IH: at each future witness `x > t`, the hook's `.eval_at x` conjoined with the segment `seg`
holding on `(t, x)` characterizes the coupled arity-3 quant layer of `sub_nf` at `[x, t]`, one depth
down), the future-arm formula holds at `t` iff there is a future witness `t < x` where `sub_nf`
evaluates on the two-anchor env `[x, t]`. Assembled from `temporal_truth_and` (origin factor split) +
`A_future_correct` (Phase 1 outer bracket) + `nf_char2_atom_offdiag_correct_future` (Phase 5 flipped
atom locus) + the depth-`(k+1)` `nf_eval_nf` unfolding, with the quant layer routed through `h_quant`.
`zoneEnv3 w x t = Fin.cons w (Fin.cons x (fun _ => t))` matches `nf_eval_nf`'s inner env. Rabinovich
Cor 5.4 `F_i` chain future arm (md:154-157). -/
theorem nf_char2_future_formula_correct {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    {k : Nat}
    (quantEnd : TemporalPred)
    (seg : BracketFormula 0)
    (M : OrderedMonadicStructure sig) (t : M.carrier)
    (sub_nf : NormalForm sig (k + 1) 2)
    (h_quant : ∀ x : M.carrier, t < x →
      ((quantEnd.eval_at M atomMap x ∧ seg.holds M atomMap t x) ↔
        (∀ qnf : NormalForm sig k 3,
          (∃ w, nf_eval_nf M k 3 (zoneEnv3 w x t) qnf) ↔ (sub_nf.2 qnf = true)))) :
    temporal_truth M atomMap t
        (nf_char2_future_formula atomMap h_surj quantEnd seg sub_nf) ↔
      ∃ x, t < x ∧ nf_eval_nf M (k + 1) 2 (Fin.cons x (fun _ => t)) sub_nf := by
  -- Conjunction of temporal predicates unfolds to conjunction of evaluations.
  have conj_eval : ∀ (a b : TemporalPred) (z : M.carrier),
      (TemporalPred.conj a b).eval_at M atomMap z ↔
        a.eval_at M atomMap z ∧ b.eval_at M atomMap z := by
    intro a b z
    simp only [TemporalPred.conj, TemporalPred.eval_at]
    exact temporal_truth_and M atomMap z a.formula b.formula
  -- Per-witness decomposition of the depth-(k+1) evaluation at [x, t] (t < x).
  have key : ∀ x : M.carrier, t < x →
      (nf_eval_nf M (k + 1) 2 (Fin.cons x (fun _ => t)) sub_nf ↔
        (temporal_truth M atomMap t
            (nf_char2_atom_offdiag_origin_future atomMap h_surj (sub_nf.1 : NormalForm sig 0 2)) ∧
          (nf_char2_atom_offdiag_endpoint atomMap h_surj
            (sub_nf.1 : NormalForm sig 0 2)).eval_at M atomMap x) ∧
        (quantEnd.eval_at M atomMap x ∧ seg.holds M atomMap t x)) := by
    intro x hx
    have hunf : nf_eval_nf M (k + 1) 2 (Fin.cons x (fun _ => t)) sub_nf ↔
        (nf_eval_nf M 0 2 (Fin.cons x (fun _ => t)) (sub_nf.1 : NormalForm sig 0 2)) ∧
        (∀ qnf : NormalForm sig k 3,
          (∃ w, nf_eval_nf M k 3 (zoneEnv3 w x t) qnf) ↔ (sub_nf.2 qnf = true)) :=
      Iff.rfl
    rw [hunf, ← nf_char2_atom_offdiag_correct_future M atomMap h_surj
          (sub_nf.1 : NormalForm sig 0 2) x t hx, ← h_quant x hx]
  simp only [nf_char2_future_formula]
  rw [temporal_truth_and, A_future_correct]
  simp only [conj_eval]
  constructor
  · rintro ⟨horig, z1, hz1, ⟨hend, hqe⟩, hseg⟩
    exact ⟨z1, hz1, (key z1 hz1).mpr ⟨⟨horig, hend⟩, hqe, hseg⟩⟩
  · rintro ⟨x, hx, hnf⟩
    obtain ⟨⟨horig, hend⟩, hqe, hseg⟩ := (key x hx).mp hnf
    exact ⟨horig, x, hx, ⟨hend, hqe⟩, hseg⟩

/-! ## Phase 9 (task 309, R1): Two-anchor VecEA2 bracket carrier reformulation + interface

Report 03 (the revision authority; full-PDF Rabinovich 2014 read) established that the plan-v2
navigated carrier `EndCharCarrier := NormalForm sig k 3 → TemporalPred` (above, :1029) has **no
counterpart in Rabinovich's proof** and is provably FALSE in free-anchor form
(`endChar0_correct` deviation note, :1058-1069): a closed navigated-`w` `TemporalPred` cannot read
the anchor positions. That is the ≤2 free-variable cap (Lemma 3.2(2), PDF p.4) surfacing.

The v3 carrier (report 03 Path B, ENDORSED) is the **two-anchor bracket characteristic** of
Rabinovich Prop 3.5 (PDF p.5): the interior existential `∃x_i` collapses to an Until/Since **bracket
witness**, with the two anchors `{x,t}` the **fixed** bracket endpoints (`z_0, z_1`) and the interval
content a monadic `E[Σ]`-atom (Def 4.1, PDF p.5). This is a `VecEA2 1` — two endpoint `TemporalPred`s
(`endpointLeft`/`endpointRight` at the fixed anchors) plus one interval `BracketFormula 1`. The
depth-0 instance already exists sorry-free (`nf_3var_bracket_xyt`/`_correct`, VecEADecomp:233/244);
Phases R2/R3 lift it to depth `k` threading the depth-`k` arity-1 point characteristic (`char_k1`,
KampPrior:307, the E[Σ]-atom) as endpoint/interval types.

**G6 (the v3 carrier guard) vs. G2 (do NOT conflate).** G2 bars a *projection-based `VecEA2` tower*
that introduces a **third free anchor** (specs/305 report 40 — a genuine ≤2-cap violation). This
carrier is a *two-anchor* bracket where the `VecEA2` is the Prop-3.5 bracket-**witness** structure:
`{x,t}` are FIXED endpoints (2, not a third free anchor) and `w` is a bracket witness, never a third
anchor (G4). Free-variable count is structurally ≤2 by the carrier type itself (Lemma 3.2(2)). The
`VecEA2` shape alone does not violate G2; a *third free anchor* would.

This phase installs the carrier TYPE (so the arity-4 obstruction cannot re-form) and states the
fixed-endpoint correctness signature, mirroring `nf_3var_bracket_xyt_correct` (VecEADecomp:244). The
retained abandoned-route `EndCharCarrier`/`endChar0`/`seg` defs above are left inert and untouched. -/

/-- **Two-anchor VecEA2 bracket carrier** (task 309 Phase 9, R1; report 03 Path B; Rabinovich Prop 3.5,
PDF p.5). The v3 recursion carrier: a `NormalForm sig k 3` is characterized as a `VecEA2 1` — two
endpoint `TemporalPred`s (the fixed anchor types at `z_0 = x`, `z_1 = t`) plus one interval
`BracketFormula 1` (the Until/Since bracket witness). This REPLACES the abandoned navigated
`EndCharCarrier := NormalForm sig k 3 → TemporalPred` (:1029, retained but off the live path): here
`{x,t}` are the FIXED bracket endpoints (≤2, Lemma 3.2(2)) and `w` is a bracket WITNESS (G4/G6), so no
arity-4 quant layer and no third free anchor (G2-safe: the `VecEA2` is a bracket-witness structure,
not a projection tower) can form. -/
abbrev BracketEndCharCarrier (sig : MonadicSignature) (k : Nat) : Type :=
  NormalForm sig k 3 → VecEA2 1

/-- **Target fixed-endpoint correctness for the two-anchor bracket carrier** (task 309 Phase 9, R1;
Rabinovich Prop 3.5, PDF p.5). The stated interface obligation Phases R2 (`k=1` decision gate) and R3
(depth-`k` lift) discharge: the carrier's `VecEA2.holds` at the fixed anchor pair `(x, t)` is
equivalent to the existence of a **bracket witness** `w` realizing the arity-3 depth-`k` evaluation
`nf_eval_nf M k 3 [w, x, t] qnf`. `{x,t}` are the FIXED endpoints; `w` is the bracket witness (G4/G6).
Mirrors `nf_3var_bracket_xyt_correct` (VecEADecomp:244) with the depth generalized to arbitrary `k`.
Free-variable count is structurally ≤2 (Lemma 3.2(2), PDF p.4) — the two endpoints. -/
def BracketCarrierCorrect {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    {k : Nat} (carrier : BracketEndCharCarrier sig k) : Prop :=
  ∀ (qnf : NormalForm sig k 3) (x t : M.carrier),
    (carrier qnf).holds M atomMap x t ↔
      ∃ w : M.carrier, nf_eval_nf M k 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf

/-- **`k = 0` carrier instance** (task 309 Phase 9, R1). The depth-0 two-anchor bracket carrier is the
already-sorry-free `nf_3var_bracket_xyt` (VecEADecomp:233), confirming it inhabits
`BracketEndCharCarrier sig 0` (the recursion base for R3). Prop 3.5 depth-0 collapse (PDF p.5). -/
noncomputable def bracketEndChar_k0 {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p) :
    BracketEndCharCarrier sig 0 :=
  nf_3var_bracket_xyt atomMap h_surj

/-- **`k = 0` fixed-endpoint correctness** (task 309 Phase 9, R1; sorry-free leaf). The depth-0 instance
of `BracketCarrierCorrect`, restricted to the `x < y < t` bracket zone (the order hypotheses of
`nf_3var_bracket_xyt_correct`, VecEADecomp:244): the depth-0 carrier's `holds` at the fixed anchors
`(x, t)` is equivalent to a bracket witness `w` (the interior `y`) realizing `nf_eval_nf M 0 3 [w,x,t]`.
Discharged directly by the landed sorry-free `nf_3var_bracket_xyt_correct` — no simp/omega/aesop
chain-step shortcut (G5). Confirms the carrier's correctness signature typechecks against the exact
`∃ w, nf_eval_nf M k 3 (Fin.cons w (Fin.cons x (fun _ => t)))` target at `k = 0`; Phases R2/R3 lift the
order-zone-conditional depth-0 result to the unconditional depth-`k` `BracketCarrierCorrect`. -/
theorem bracketEndChar_k0_correct {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ssn : NormalForm sig 0 3)
    (h_xy : ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    (h_yt : ssn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_xt : ssn (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_yx : ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (h_ty : ssn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
    (h_tx : ssn (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (M : OrderedMonadicStructure sig) (x t : M.carrier) :
    (bracketEndChar_k0 atomMap h_surj ssn).holds M atomMap x t ↔
      ∃ w : M.carrier, nf_eval_nf M 0 3 (Fin.cons w (Fin.cons x (fun _ => t))) ssn :=
  nf_3var_bracket_xyt_correct atomMap h_surj ssn h_xy h_yt h_xt h_yx h_ty h_tx M x t

/-! ## Phase 10 (task 309, R2): k=1 de-risking probe — DECISION GATE → NO-GO

R2 tested whether the two-anchor `VecEA2 1` bracket carrier (R1) can characterize the depth-1
arity-3 evaluation `∃ w, nf_eval_nf M 1 3 [w,x,t] qnf` — the single experiment deciding Path B
(report 03 §3 OPEN RISK, §4 R2). **Verdict: NO-GO** (this dispatch; commit history / handoff).

`qnf : NormalForm sig 1 3 = (AtomKind sig 3 → Bool) × (NormalForm sig 0 4 → Bool)`, so
`nf_eval_nf M 1 3 [w,x,t] qnf` (k+1 = 1) unfolds to the conjunction of
  (atom layer)  `nf_eval_nf M 0 3 [w,x,t] qnf.1`, and
  (quant layer) `∀ sub : NormalForm sig 0 4, (∃ x_1, nf_eval_nf M 0 4 [x_1,w,x,t] sub) ↔ qnf.2 sub`.

The most faithful k=1 carrier mirrors the sorry-free depth-0 collapse `nf_3var_bracket_xyt` on the
atom part `qnf.1`. Its correctness `↔` was probed: after `nf_3var_bracket_xyt_correct` discharges the
atom layer and `refine ⟨w, h_atom, ?_⟩` splits the goal, the residual is the depth-1 quant layer

  ⊢ ∀ (sub_nf : NormalForm sig 0 4),
      (∃ x_1, atom_eval M (Fin.cons x_1 (Fin.cons w (Fin.cons x fun _ ↦ t))) a ↔ sub_nf a) ↔
        qnf.2 sub_nf = true

with only the atom-layer hypothesis `h_atom : nf_eval_nf M 0 3 [w,x,t] qnf.1` in context. This is an
irreducible **arity-4 residual**: the env `[x_1, w, x, t]` couples the bracket witness `w` to BOTH
fixed endpoints `x, t` (plus a fresh existential `x_1`), and `qnf.2` was discarded by the atom-only
carrier. No `VecEA2 1` monadic component (`endpointLeft`@x / `endpointRight`@t / interval@w, each
reading a single point) can supply it; discharging it requires a NAVIGATED arity-3 characteristic
(reading `w` while `x, t` are navigated in) — exactly what G6 bars and exactly the arity-4 → arity-3
re-bounding obstruction that blocked plan-v2 Phase 8. `exact h_atom` / `exact h_atom sub_nf` fail with
type/arity mismatch; `simp_all [nf_eval_nf]` leaves the two irreducible sub-goals
`(∃ x_1 …arity-4…) ⟷ qnf.2 sub_nf`. Verified via `lean_goal` + `lean_multi_attempt` this dispatch.

Per the DECISION-GATE contract, no probe carrier or `sorry` is committed (a NO-GO lands no partial
carrier). Path B halts at `:351`; the follow-up is a spawned NormalForm E[Σ]-fold encoding task (see
plan Phase 10 [BLOCKED] record). The R1 carrier (`BracketEndCharCarrier` / `BracketCarrierCorrect` /
`bracketEndChar_k0` / `_correct`, above) remains sorry-free and off the live path. -/

/-! ## Task 311 Phase 1: the k=1 fold carrier instance (Path B, fold-backed)

Consumes task 310's E[Σ]-fold assets (`Kamp/NfEFold.lean`): the transport `efold_of_nf1`
(NfEFold:472) reads the depth-1 quant layer `qnf.2` ONLY through the fold's zone-bounded monadic
E-atoms `EAtomDom sig 0 3 = ZoneSpec 3 × NormalForm sig 0 1` (Def 4.1, PDF p.5) — no `qnf.2`
value is evaluated at an arity-4 environment, so the R2 NO-GO residual (:1601-1603 above) never
re-forms. Correctness (`bracketEndChar_k1_correct`, the k=1 instance of `BracketCarrierCorrect`)
is task 311 Phase 2 scope, routed through `nf_eval_nf1_iff_efold` (NfEFold:490) and the gate
corollary `nf_quant_layer_fold_k1_gate` (NfEFold:525). -/

/-- **k=1 two-anchor fold carrier** (task 311 Phase 1; audit-corrected N1 citations).

Encodes a depth-1 arity-3 `qnf : NormalForm sig 1 3` as a `VecEA2 1` at the two FIXED endpoints
`{x, t}` with `w` the single bracket WITNESS (G6 SHAPE, codomain `VecEA2 1` unchanged; anchors
stay `{x, t}`, ≤2). Citation split (audit caveat C1 / rule N1): the two-fixed-endpoint
`(z_0, z_1)` bracket framing is **Lemma 3.2(2) (PDF p.4) + the §5 bracket notation
`[α_0, …, α_n](z_0, z_1)` (PDF p.7)**; **Prop 3.5 (PDF p.5)** is cited ONLY for the
one-free-variable ∃-witness→Until/Since folding *mechanism* (the `Formula.snce`/`Formula.untl`
literals and the `bracketBuildLeft`/`bracketBuildRight` chains below), never for the two-endpoint
framing itself.

Construction — every read of `qnf.2` goes through `efold_of_nf1` / `nf0_assemble` (the Def-4.1
monadic-atom fold, PDF p.5); no arity-4 evaluation occurs:

- **Endpoints** mirror the depth-0 collapse `nf_3var_bracket_xyt` (VecEADecomp:233) on the atom
  layer `qnf.1`: `endpointLeft`/`endpointRight` carry the complete depth-0 point types
  `nf_x_proj3 qnf.1` / `nf_t_proj3 qnf.1`, conjoined with the fold bits of the zones anchored
  there — past-of-`x` and at-`x` on the left, at-`t` and future-of-`t` on the right — as
  positive/negated Since/Until literals (Prop 3.5 folding mechanism, PDF p.5).
- **Bracket** (`BracketFormula.single`, ONE witness `w` between the fixed endpoints, §5 bracket
  notation PDF p.7): the point type carries `w`'s own complete type `nf_y_proj qnf.1`, the
  equality-zone bits at `w`, and the POSITIVE interior-zone bits `(x, w)` / `(w, t)` folded as
  `bracketBuildLeft` / `bracketBuildRight` Since/Until chains anchored at the endpoint types
  (Prop 3.5 folding mechanism, PDF p.5; the interior witness joins the chain, never the anchor
  set — Lemma 3.4, PDF p.5). The segment types carry the NEGATIVE interior-zone bits as
  universal exclusions.
- **Gate** (Risk R2 — mirroring Rabinovich's disjunctions ranging only over consistent order
  types): the construction is the `⊥` carrier unless (i) `qnf.2` is false off the fiber over
  `qnf.1` (the ≤2-cap honesty clause of `nf_eval_nf1_iff_efold`, NfEFold:490,495) and (ii) every
  fold bit on a zone spec inconsistent with the bracket order `x < w < t` is false
  (order-conflict falsity; cf. `nf_depth0_pair_cycle_empty'`, NfDepth0Generalized:93).

The gate Prop is decidable in principle (`normalForm_fintype` / `normalForm_decEq`,
NormalForm.lean:177/181); `Classical.dec` is used since the carrier is noncomputable anyway. -/
noncomputable def bracketEndChar_k1 {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p) :
    BracketEndCharCarrier sig 1 :=
  fun qnf =>
    -- Fold bits (Def 4.1, PDF p.5): the ONLY channel through which `qnf.2` is read.
    let b : ZoneSpec 3 → NormalForm sig 0 1 → Bool :=
      fun zs χ => (efold_of_nf1 qnf).2 (zs, χ)
    -- Zone-spec constants relative to env `[w, x, t]` under the bracket order `x < w < t`
    -- (Def 3.1 ordering channel, PDF p.4): `ltz`/`eqz`/`gtz` = witness below / at / above the
    -- env point, encoded as `(x_1 < env i, env i < x_1)`.
    let ltz : Bool × Bool := (true, false)
    let eqz : Bool × Bool := (false, false)
    let gtz : Bool × Bool := (false, true)
    let mk3 : Bool × Bool → Bool × Bool → Bool × Bool → ZoneSpec 3 := fun pw px pt =>
      Fin.cons pw (Fin.cons px (fun _ => pt))
    let zPastX := mk3 ltz ltz ltz    -- x_1 < x  (< w < t)
    let zAtX   := mk3 ltz eqz ltz    -- x_1 = x
    let zXW    := mk3 ltz gtz ltz    -- x < x_1 < w
    let zAtW   := mk3 eqz gtz ltz    -- x_1 = w
    let zWT    := mk3 gtz gtz ltz    -- w < x_1 < t
    let zAtT   := mk3 gtz gtz eqz    -- x_1 = t
    let zFutT  := mk3 gtz gtz gtz    -- t < x_1
    -- Complete depth-0 monadic point types: the TL side of the fold's E-atoms.
    let char : NormalForm sig 0 1 → Formula := nf_depth0_char_formula atomMap h_surj
    let allTypes : List (NormalForm sig 0 1) := Finset.univ.toList
    -- Biconditional literal at an anchor: assert positively or negatively per fold bit
    -- (Prop 3.5 folding mechanism, PDF p.5).
    let lit : Bool → Formula → Formula := fun bit f => if bit then f else f.neg
    -- Endpoint types (the FIXED `z_0 = x`, `z_1 = t`: Lemma 3.2(2) PDF p.4 + §5 bracket PDF p.7).
    let xType : TemporalPred := ⟨char (nf_x_proj3 qnf.1)⟩
    let tType : TemporalPred := ⟨char (nf_t_proj3 qnf.1)⟩
    let epL : TemporalPred :=
      ⟨formula_conjList
        (xType.formula
          :: (allTypes.map fun χ => lit (b zPastX χ) (Formula.snce (char χ) Formula.top))
          ++ (allTypes.map fun χ => lit (b zAtX χ) (char χ)))⟩
    let epR : TemporalPred :=
      ⟨formula_conjList
        (tType.formula
          :: (allTypes.map fun χ => lit (b zAtT χ) (char χ))
          ++ (allTypes.map fun χ => lit (b zFutT χ) (Formula.untl (char χ) Formula.top)))⟩
    -- Segment types: universal exclusion of the interior-zone NEGATIVE bits.
    let segL : TemporalPred :=
      ⟨formula_conjList (allTypes.map fun χ =>
        if b zXW χ then Formula.top else (char χ).neg)⟩
    let segR : TemporalPred :=
      ⟨formula_conjList (allTypes.map fun χ =>
        if b zWT χ then Formula.top else (char χ).neg)⟩
    -- Witness point type at `w`: complete type + equality-zone bits + interior POSITIVE bits
    -- folded as Since/Until chains anchored at the endpoint types (Prop 3.5 mechanism, PDF p.5).
    let ptW : TemporalPred :=
      ⟨formula_conjList
        (char (nf_y_proj qnf.1)
          :: (allTypes.map fun χ => lit (b zAtW χ) (char χ))
          ++ (allTypes.map fun χ =>
               if b zXW χ then
                 bracketBuildLeft (BracketFormula.single ⟨char χ⟩ segL segL) xType
               else Formula.top)
          ++ (allTypes.map fun χ =>
               if b zWT χ then
                 bracketBuildRight (BracketFormula.single ⟨char χ⟩ segR segR) tType
               else Formula.top))⟩
    -- Consistency of a zone spec with the bracket order `x < w < t` (the seven real zones).
    let consistent : ZoneSpec 3 → Prop := fun zs =>
      zs = zPastX ∨ zs = zAtX ∨ zs = zXW ∨ zs = zAtW ∨ zs = zWT ∨ zs = zAtT ∨ zs = zFutT
    -- The gate Prop (Risk R2 off-fiber honesty + order-conflict falsity).
    let gate : Prop :=
      (∀ sub : NormalForm sig 0 4, nf0_dropFresh sub ≠ qnf.1 → qnf.2 sub = false) ∧
      (∀ (zs : ZoneSpec 3) (χ : NormalForm sig 0 1), ¬ consistent zs → b zs χ = false)
    @dite _ gate (Classical.dec gate)
      (fun _ =>
        { endpointLeft := epL
          endpointRight := epR
          bracket := BracketFormula.single ptW segL segR })
      (fun _ =>
        { endpointLeft := TemporalPred.bot
          endpointRight := TemporalPred.bot
          bracket := BracketFormula.single TemporalPred.bot TemporalPred.bot TemporalPred.bot })

/-! ## Task 311 Phase 2: k=1 gate re-probe under the E[Σ]-fold — DECISION GATE → R2 = NO-GO at
`VecEA2 1` (Risk R1 materialized; the fold itself is VINDICATED)

**Lead evidence (Def 3.1, PDF p.4 — per plan-v2 rule N3, adapted to the NO-GO outcome).**
Rabinovich's α_j/β_j are ONE-variable quantifier-free formulas: no joint multi-point atom exists,
so the arity-4 residual `[x_1,w,x,t]` that NO-GOed the OLD probe (Phase 10 record above,
:1592-1624, residual :1607-1609) has no Rabinovich counterpart — it was a Lean `nf_eval_nf`
arity-growth artifact, and the E[Σ]-fold RESTORES Def-4.1 fidelity. This re-probe CONFIRMS that:
chain steps 1-2 of the plan-v2 proof chain discharge against the landed sorry-free fold assets —
`nf_eval_nf1_iff_efold` (NfEFold:490) rewrites the k=1 evaluation into the fold form plus the
off-fiber clause, and `nf_quant_layer_fold_k1_gate` (NfEFold:525) reduces the OLD residual
verbatim to zone-bounded MONADIC existentials over `EAtomDom sig 0 3` (the "innermost fold /
iteration" reading is the **Def 4.1 p.6 note**; **Prop 4.3 (p.6)** licenses only
residual-is-∨∃∀ over E[Σ] atoms, realized locally via the fold, NOT literal structural
induction — 305 report 14). **No arity-4 object and no navigated arity-3 characteristic arises
at any step.** The old blocker is dead.

**The NEW blocker (chain step 4, interval zones — the plan-named Risk R1 surface).** The k=1
correctness target `BracketCarrierCorrect` restricted to the bracket zone (the six k0-mirror
order hypotheses on `qnf.1`) is **FALSE for the carrier above**: its LHS→RHS direction fails on
the interior-POSITIVE fold bits. The `ptW` chains (:1725-1732) encode `b zXW χ = true` as
`bracketBuildLeft (BracketFormula.single ⟨char χ⟩ segL segL) xType` at the bracket witness `w`,
but `bracketBuildLeft_correct` (VecEATranslation:503) reads `∃ z0 < w` with `xType`**-typed**
anchor `z0` — an existential over the endpoint TYPE, not the fixed endpoint `x` itself (the
two-fixed-endpoint `(z_0,z_1)` framing is **Lemma 3.2(2) (p.4) + the §5 bracket notation
`[α_0,…,α_n](z_0,z_1)` (p.7)**; **Prop 3.5 (p.5)** supplies only the ∃-witness→Until/Since
folding mechanism). The chain's χ-witness may land in `(z0, x]`, OUTSIDE `(x, w)`. Machine-
captured leaf (this dispatch, `lean_goal` on the extracted obligation): hypotheses
`z0 < w`, `xType z0`, one witness `ws 0 ∈ (z0, w)` with `char χ` — goal
`∃ u, x < u ∧ u < w ∧ nf_eval_nf M 0 1 (fun _ => u) χ`; the needed `x < ws 0` is underivable
(`lean_multi_attempt`: every candidate fails exactly there).

**Semantic counterexample** (dense order — this is NOT a proof-search stall): sig = one
predicate `P`; `M` = ℝ with `P ⊨ {1}`; `x = 2`, `t = 10`; `χ_P`/`χ_0` the P-true/P-false
1-types. `qnf.1` = the bracket-zone atom layer with all three point types `χ_0`. `qnf.2` =
fiber-supported bits (off-fiber false): `zPastX`: both types true (P-witness `1 < 2`); `zAtX`,
`zAtW`, `zAtT`: `χ_0` true, `χ_P` false; `zXW`: `χ_0` true, **`χ_P` true — the unrealizable
bit**; `zWT`, `zFutT`: `χ_0` true, `χ_P` false; inconsistent zones false. Both gate conjuncts
hold, so the carrier is the real (non-⊥) branch. LHS holds at `(2, 10)`: bracket witness
`w = 5`; the `zXW`-positive chain for `χ_P` anchors at `z0 = 0` (type `χ_0 = xType`) and
absorbs `u = 1 ∈ (0, 5)` — outside `(x, w) = (2, 5)`; `segL ≡ ⊤` (both `zXW` bits positive),
`segR` = `¬char χ_P`, true on `(5, 10)`; all endpoint literals check. RHS is FALSE for EVERY
`w`: the atom layer forces `2 < w < 10`, and the fold quant-layer biconditional at
`(zXW, χ_P)` demands a P-point in `(2, w)` — but `P ∩ (2, ∞) = ∅`. Hence
`(bracketEndChar_k1 … qnf).holds M atomMap x t` holds while
`∃ w, nf_eval_nf M 1 3 [w,x,t] qnf` fails. (Checked by hand against `IntervalPattern.holds`,
`temporal_truth`, `nf_eval_efold`, `nf_quant_layer_fold_iff` this dispatch.)

**Isolation — why this is a `VecEA2 1` SHAPE limit, not a fixable proof gap.** A
`BracketFormula 1` has exactly ONE interior witness slot (`w`). Each interior-positive
`(zone, χ)` bit is an ADDITIONAL existential strictly inside `(x,w)` / `(w,t)`; per
**Lemma 3.4 (p.5)** its witness must JOIN the bracket's existential prefix — witness-count
growth, which is exactly what `BracketFormula.existsBounded_right` (VecEAClosure:265)
implements: its conclusion is `∃ m, ∃ bf' : BracketFormula m, …` (n → n+2 witnesses). Nothing
with the carrier's FIXED `BracketFormula 1` output can consume it, and no monadic temporal
formula at `w` (or at a type-anchored `z0`) can pin a witness strictly inside `(x, w)`, because
monadic point types cannot separate points `≤ x` from points in `(x, w)` — the counterexample
exploits precisely this. Note the defect is ONE-directional: the RHS→LHS direction of the k=1
instance IS dischargeable for this carrier (take `z0 := x`; interior points all carry
positive-bit types, so the segment exclusions hold) — the carrier is sound but under-
constraining, so the correctness `↔` fails.

**Escalation (Risk R1 fence, plan v2 Rollback #2; audit caveat C3).** Per the fence this is a
G6-SHAPE decision, NOT an implementer call: the carrier codomain is left UNCHANGED, no third
anchor is introduced, `bracketEndChar_k1` above stays intact, sorry-free, and OFF the live path
(nothing imports/wires it). The Rabinovich-faithful fix direction for the orchestrator /
`/revise 311`: anchors stay `{x, t}` (Lemma 3.2(2) caps ANCHORS at ≤2 — audit Red Flag C:
witness-count growth under ∃-closure is licensed, anchor-count growth is not), while the
bracket carries the interior-positive witnesses ALONGSIDE `w` — i.e. a carrier codomain of
`VVecEA2` / `Σ n, VecEA2 n` (the §5 bracket `[α_0,…,α_n](z_0,z_1)`, p.7, has n witnesses),
with `BracketFormula.existsBounded_right` as the assembly vehicle. Chain steps 1-3 and 5
(fold bridge, gate corollary, atom-layer kit, off-fiber gate) are UNAFFECTED by the codomain
change. Per the DECISION-GATE contract no partial correctness theorem and no `sorry` is
landed for the k=1 instance. -/

/-! ## Task 311 Phase 3: witness-growing carrier type + k=1 V-carrier (G6 as amended, plan v3)

**G6 amendment record.** The carrier SHAPE is unchanged: the recursion carrier stays the
two-anchor bracket characteristic with FIXED endpoints `z_0 = x`, `z_1 = t`, interior points as
bracket WITNESSES — never an arity-1 navigated point characteristic, never an
interior-existential-witness evaluation, never a third free anchor (G1/G2/G4 intact). ONLY the
codomain is amended: `VecEA2 1` (one interior witness slot) → witness-growing `VecEA2 n`,
assembled as a `VVecEA2` finite disjunction (VecEAFormula:271). Justification: the R2 = NO-GO
refutation above (:1782-1796) — a `BracketFormula 1` cannot host the interior-positive
`(zone, χ)` witnesses, and no monadic point type separates points `≤ x` from points in `(x, w)`.
Rabinovich licenses for witness growth (anchors capped, witnesses not):

- **Lemma 3.2(2) (PDF p.4)** caps ANCHORS (free variables) at ≤2; it says nothing capping
  bracket witnesses.
- The **§5 bracket notation `[α_0, …, α_n](z_0, z_1)` (PDF p.7)** carries `n` witnesses between
  the two FIXED endpoints — witness growth is the printed shape of the bracket.
- **Lemma 3.4 (PDF p.5)** (∨∃∀ closed under ∃): each absorbed existential JOINS the existential
  prefix as a witness (`BracketFormula.existsBounded_right`, VecEAClosure:265, is the vehicle).

Citation split (rule N1): the two-fixed-endpoint `(z_0, z_1)` framing is **Lemma 3.2(2) (p.4) +
the §5 bracket notation (p.7)**; **Prop 3.5 (p.5)** is cited ONLY for the one-free-variable
∃-witness→Until/Since folding mechanism. -/

/-- **Witness-growing two-anchor bracket carrier type** (task 311 Phase 3; G6 as amended).
Parallel V-variant of `BracketEndCharCarrier` (:1542, which stays untouched): the codomain is the
finite disjunction `VVecEA2` of `Σ n, VecEA2 n` disjuncts (VecEAFormula:271), so each disjunct
may carry `n` bracket witnesses between the two FIXED endpoints — the §5 bracket
`[α_0, …, α_n](z_0, z_1)` (PDF p.7). Every disjunct's `holds` stays at the two-point signature
(VecEAFormula:276), so Lemma 3.2(2)'s ≤2-anchor cap (PDF p.4) remains a TYPE-level invariant:
witness growth is licensed, anchor growth is not (G2/G4). -/
abbrev BracketEndCharCarrierV (sig : MonadicSignature) (k : Nat) : Type :=
  NormalForm sig k 3 → VVecEA2

/-- **Fixed-endpoint correctness for the witness-growing carrier** (task 311 Phase 3). V-variant
of `BracketCarrierCorrect` (:1552, untouched): the carrier's `VVecEA2.holds` at the fixed anchor
pair `(x, t)` is equivalent to the existence of a **bracket witness** `w` realizing the arity-3
depth-`k` evaluation `nf_eval_nf M k 3 [w, x, t] qnf`. `{x, t}` are the FIXED endpoints
(Lemma 3.2(2), PDF p.4 + §5 bracket notation, PDF p.7 — rule N1 split); `w` is a bracket witness,
now one among the disjunct's `n` witnesses (G4, G6 as amended). -/
def BracketCarrierCorrectV {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    {k : Nat} (carrier : BracketEndCharCarrierV sig k) : Prop :=
  ∀ (qnf : NormalForm sig k 3) (x t : M.carrier),
    (carrier qnf).holds M atomMap x t ↔
      ∃ w : M.carrier, nf_eval_nf M k 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf

/-- Assemble a `BracketFormula` from an ordered left witness-type list, the middle `w` point
type, and an ordered right witness-type list (disjunct builder factored into a named `private
def` per Risk R6). Point types are the left list, then the `w` slot at position `lL.length`,
then the right list — the §5 bracket `[α_0, …, α_n](z_0, z_1)` (PDF p.7) with `z_0, z_1` the
FIXED endpoints. Segment types are `segL` on every segment left of the `w` slot (the
sub-segments of `(x, w)`) and `segR` on every segment right of it (the sub-segments of
`(w, t)`) — real exclusion segments, never top (G3). -/
private def bracketFromLists (lL : List TemporalPred) (ptW : TemporalPred)
    (lR : List TemporalPred) (segL segR : TemporalPred) :
    BracketFormula (lL.length + 1 + lR.length) where
  pointTypes := fun i =>
    (lL ++ ptW :: lR)[i.val]'(by
      simp only [List.length_append, List.length_cons]; omega)
  segmentTypes := fun i => if i.val ≤ lL.length then segL else segR

/-- **k=1 witness-growing two-anchor fold carrier** (task 311 Phase 3; G6 as amended by the
plan-v3 amendment record above).

Encodes a depth-1 arity-3 `qnf : NormalForm sig 1 3` as a `VVecEA2` at the two FIXED endpoints
`{x, t}`: the interior-positive `(zone, χ)` fold bits become bracket WITNESSES ordered between
the fixed endpoints, alongside `w` (rule N4: interior-positive content as bracket witnesses
anchored between the FIXED endpoints; the type-anchored `bracketBuildLeft`/`bracketBuildRight`
chains of `bracketEndChar_k1` (:1725-1732) were REFUTED at :1782-1796 and are REMOVED here —
they survive only in the `epL`/`epR` exterior-zone literals, where the anchor genuinely IS the
fixed endpoint). Citation split (rule N1): the two-fixed-endpoint framing is **Lemma 3.2(2)
(PDF p.4) + the §5 bracket notation `[α_0, …, α_n](z_0, z_1)` (PDF p.7)**; **Prop 3.5 (PDF
p.5)** is cited ONLY for the ∃-witness→Until/Since folding mechanism (the Since/Until literals
in `epL`/`epR`).

Construction — every read of `qnf.2` goes through `efold_of_nf1` (NfEFold:472; the Def-4.1
monadic-atom fold, PDF p.5, read at depth 1 per the **Def 4.1 p.6 note** on iterated folds); no
arity-4 evaluation occurs:

- **Building blocks** are the Phase-1 blocks of `bracketEndChar_k1` (:1676-1739) verbatim: fold
  bits `b`, the seven zone specs, `char`, `lit`, endpoint preds `epL`/`epR`, segment exclusions
  `segL`/`segR`, and the two-conjunct gate (off-fiber falsity + order-conflict falsity).
- **Witness point type at `w`**: the complete type `char (nf_y_proj qnf.1)` plus the zAtW
  biconditional literals ONLY — no interior chains (rule N4).
- **Disjuncts** (rule N5 — Rabinovich's ∨ over consistent order types, Def 3.1 pp.4-5): the
  interior-positive enumerations `S_L` (zone `(x, w)`) and `S_R` (zone `(w, t)`) are
  duplicate-free lists of complete 1-types; for each arrangement
  `(lL, lR) ∈ S_L.permutations × S_R.permutations` there is one disjunct with
  `lL.length + 1 + lR.length` witnesses: `epL`/`epR` at the fixed endpoints, point types = the
  `char`s of `lL`, then the `w` point type, then the `char`s of `lR` (each interior-positive
  pair occupies a WITNESS slot — §5 bracket, PDF p.7; its witness JOINS the existential prefix —
  Lemma 3.4, PDF p.5), segment types `segL` left of the `w` slot and `segR` right of it. The
  model-dependent witness ORDER is carried by the finite disjunction over arrangements, never by
  a fixed-order assertion (rule N5); same-type multiplicity is not encoded (fold bits are
  existential — one witness per positive pair).
- **Gate-failure branch**: the empty disjunction `⟨[]⟩` (its `holds` is `False`) — Rabinovich's
  empty disjunction over inconsistent order types. -/
noncomputable def bracketEndChar_k1v {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p) :
    BracketEndCharCarrierV sig 1 :=
  fun qnf =>
    -- Fold bits (Def 4.1, PDF p.5): the ONLY channel through which `qnf.2` is read.
    let b : ZoneSpec 3 → NormalForm sig 0 1 → Bool :=
      fun zs χ => (efold_of_nf1 qnf).2 (zs, χ)
    -- Zone-spec constants relative to env `[w, x, t]` under the bracket order `x < w < t`
    -- (Def 3.1 ordering channel, PDF p.4), verbatim from `bracketEndChar_k1` (:1679-1692).
    let ltz : Bool × Bool := (true, false)
    let eqz : Bool × Bool := (false, false)
    let gtz : Bool × Bool := (false, true)
    let mk3 : Bool × Bool → Bool × Bool → Bool × Bool → ZoneSpec 3 := fun pw px pt =>
      Fin.cons pw (Fin.cons px (fun _ => pt))
    let zPastX := mk3 ltz ltz ltz    -- x_1 < x  (< w < t)
    let zAtX   := mk3 ltz eqz ltz    -- x_1 = x
    let zXW    := mk3 ltz gtz ltz    -- x < x_1 < w
    let zAtW   := mk3 eqz gtz ltz    -- x_1 = w
    let zWT    := mk3 gtz gtz ltz    -- w < x_1 < t
    let zAtT   := mk3 gtz gtz eqz    -- x_1 = t
    let zFutT  := mk3 gtz gtz gtz    -- t < x_1
    -- Complete depth-0 monadic point types: the TL side of the fold's E-atoms.
    let char : NormalForm sig 0 1 → Formula := nf_depth0_char_formula atomMap h_surj
    let allTypes : List (NormalForm sig 0 1) := Finset.univ.toList
    -- Biconditional literal at an anchor (Prop 3.5 folding mechanism, PDF p.5).
    let lit : Bool → Formula → Formula := fun bit f => if bit then f else f.neg
    -- Endpoint types (the FIXED `z_0 = x`, `z_1 = t`: Lemma 3.2(2) PDF p.4 + §5 bracket PDF p.7).
    let xType : TemporalPred := ⟨char (nf_x_proj3 qnf.1)⟩
    let tType : TemporalPred := ⟨char (nf_t_proj3 qnf.1)⟩
    let epL : TemporalPred :=
      ⟨formula_conjList
        (xType.formula
          :: (allTypes.map fun χ => lit (b zPastX χ) (Formula.snce (char χ) Formula.top))
          ++ (allTypes.map fun χ => lit (b zAtX χ) (char χ)))⟩
    let epR : TemporalPred :=
      ⟨formula_conjList
        (tType.formula
          :: (allTypes.map fun χ => lit (b zAtT χ) (char χ))
          ++ (allTypes.map fun χ => lit (b zFutT χ) (Formula.untl (char χ) Formula.top)))⟩
    -- Segment types: universal exclusion of the interior-zone NEGATIVE bits.
    let segL : TemporalPred :=
      ⟨formula_conjList (allTypes.map fun χ =>
        if b zXW χ then Formula.top else (char χ).neg)⟩
    let segR : TemporalPred :=
      ⟨formula_conjList (allTypes.map fun χ =>
        if b zWT χ then Formula.top else (char χ).neg)⟩
    -- Witness point type at `w`: complete type + equality-zone bits ONLY (rule N4 — the
    -- interior-positive chains of :1725-1732 are the refuted device and are REMOVED; the
    -- interior-positive content rides the witness slots below instead).
    let ptW : TemporalPred :=
      ⟨formula_conjList
        (char (nf_y_proj qnf.1)
          :: (allTypes.map fun χ => lit (b zAtW χ) (char χ)))⟩
    -- Consistency of a zone spec with the bracket order `x < w < t` (the seven real zones).
    let consistent : ZoneSpec 3 → Prop := fun zs =>
      zs = zPastX ∨ zs = zAtX ∨ zs = zXW ∨ zs = zAtW ∨ zs = zWT ∨ zs = zAtT ∨ zs = zFutT
    -- The gate Prop (off-fiber honesty + order-conflict falsity), verbatim from :1737-1739.
    let gate : Prop :=
      (∀ sub : NormalForm sig 0 4, nf0_dropFresh sub ≠ qnf.1 → qnf.2 sub = false) ∧
      (∀ (zs : ZoneSpec 3) (χ : NormalForm sig 0 1), ¬ consistent zs → b zs χ = false)
    -- Interior-positive enumerations (duplicate-free: `Finset.univ.toList`).
    let S_L : List (NormalForm sig 0 1) := allTypes.filter (fun χ => b zXW χ)
    let S_R : List (NormalForm sig 0 1) := allTypes.filter (fun χ => b zWT χ)
    let charP : NormalForm sig 0 1 → TemporalPred := fun χ => ⟨char χ⟩
    -- One disjunct per arrangement (rule N5): interior-positive pairs occupy WITNESS slots
    -- ordered between the fixed endpoints (§5 bracket, PDF p.7; Lemma 3.4, PDF p.5).
    let mkDisjunct : List (NormalForm sig 0 1) → List (NormalForm sig 0 1) → Σ n, VecEA2 n :=
      fun lL lR =>
        ⟨(lL.map charP).length + 1 + (lR.map charP).length,
          { endpointLeft := epL
            endpointRight := epR
            bracket := bracketFromLists (lL.map charP) ptW (lR.map charP) segL segR }⟩
    @dite _ gate (Classical.dec gate)
      (fun _ =>
        { disjuncts :=
            S_L.permutations.flatMap fun lL =>
              S_R.permutations.map fun lR => mkDisjunct lL lR })
      (fun _ => { disjuncts := [] })

/-! ## Task 311 Phase 4: soundness direction (LHS→RHS) for the V-carrier — helper kit

Private helper kit for `bracketEndChar_k1v_sound` (pre-authorized 4.1/4.2 split, plan v3
Phase 4 H8 escape hatch). Chain citations (rule N1 split): the two-fixed-endpoint `(z_0, z_1)`
bracket framing is **Lemma 3.2(2) (PDF p.4) + §5 bracket notation (PDF p.7)**; **Prop 3.5
(PDF p.5)** is cited ONLY for the ∃-witness→Until/Since folding mechanism. Per rule N2, the
gate-corollary rewrite in 4.2 cites the **Def 4.1 p.6 note** (innermost fold) and **Prop 4.3
(p.6)** only for "the residual is ∨∃∀ over E[Σ] atoms" (realized locally via the fold —
305 report 14). -/

/-- Bool helper: a bit is forced `false` through its semantic biconditional when the
    semantic side fails. -/
private theorem k1v_bool_eq_false {b : Bool} {p : Prop} (h : p ↔ b = true) (hp : ¬p) :
    b = false := by
  cases hb : b
  · rfl
  · exact absurd (h.mpr hb) hp

/-- `zoneHolds` over the bracket env `[w, x, t]` at a pointwise `Fin.cons` zone spec,
    unfolded to its three coordinate biconditionals (Def 3.1 ordering channel, PDF p.4:
    the only channel through which the quantified witness meets the fixed env points). -/
private theorem k1v_zoneHolds_cons_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (w x t u : M.carrier) (pw px pt : Bool × Bool) :
    zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier)
      (Fin.cons pw (Fin.cons px (fun _ => pt)) : ZoneSpec 3) u ↔
    (((u < w) ↔ pw.1 = true) ∧ ((w < u) ↔ pw.2 = true)) ∧
    (((u < x) ↔ px.1 = true) ∧ ((x < u) ↔ px.2 = true)) ∧
    (((u < t) ↔ pt.1 = true) ∧ ((t < u) ↔ pt.2 = true)) := by
  constructor
  · intro h
    have h0 := h ⟨0, by omega⟩
    have h1 := h ⟨1, by omega⟩
    have h2 := h ⟨2, by omega⟩
    simp only [Fin.cons] at h0 h1 h2
    exact ⟨h0, h1, h2⟩
  · rintro ⟨h0, h1, h2⟩ i
    match i with
    | ⟨0, _⟩ => simpa only [Fin.cons] using h0
    | ⟨1, _⟩ => simpa only [Fin.cons] using h1
    | ⟨2, _⟩ => simpa only [Fin.cons] using h2

/-- Any zone spec realized by a point over the bracket env `[w, x, t]` with `x < w < t` is
    one of the seven order-consistent zones (Def 3.1, PDF pp.4-5: disjunctions range only
    over consistent order types). The contrapositive discharges the inconsistent-zone fold
    bits against gate conjunct (ii) in the soundness direction. -/
private theorem k1v_zone_consistent {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (w x t u : M.carrier)
    (hxw : x < w) (hwt : w < t)
    (zs : ZoneSpec 3)
    (hz : zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t))) zs u) :
    zs = Fin.cons (true, false) (Fin.cons (true, false) (fun _ => (true, false))) ∨
    zs = Fin.cons (true, false) (Fin.cons (false, false) (fun _ => (true, false))) ∨
    zs = Fin.cons (true, false) (Fin.cons (false, true) (fun _ => (true, false))) ∨
    zs = Fin.cons (false, false) (Fin.cons (false, true) (fun _ => (true, false))) ∨
    zs = Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (true, false))) ∨
    zs = Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (false, false))) ∨
    zs = Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (false, true))) := by
  have h0 := hz ⟨0, by omega⟩
  have h1 := hz ⟨1, by omega⟩
  have h2 := hz ⟨2, by omega⟩
  simp only [Fin.cons] at h0 h1 h2
  -- Build the pointwise equality from the three coordinate pairs.
  have hzs : ∀ (pw px pt : Bool × Bool),
      zs ⟨0, by omega⟩ = pw → zs ⟨1, by omega⟩ = px → zs ⟨2, by omega⟩ = pt →
      zs = Fin.cons pw (Fin.cons px (fun _ => pt)) := by
    intro pw px pt e0 e1 e2
    funext i
    match i with
    | ⟨0, _⟩ => simpa only [Fin.cons] using e0
    | ⟨1, _⟩ => simpa only [Fin.cons] using e1
    | ⟨2, _⟩ => simpa only [Fin.cons] using e2
  have hxt : x < t := hxw.trans hwt
  rcases lt_trichotomy u x with hux | hux | hux
  · -- u < x: zone zPastX
    have huw : u < w := hux.trans hxw
    have hut : u < t := huw.trans hwt
    exact Or.inl (hzs _ _ _
      (Prod.ext_iff.mpr ⟨h0.1.mp huw, k1v_bool_eq_false h0.2 (lt_asymm huw)⟩)
      (Prod.ext_iff.mpr ⟨h1.1.mp hux, k1v_bool_eq_false h1.2 (lt_asymm hux)⟩)
      (Prod.ext_iff.mpr ⟨h2.1.mp hut, k1v_bool_eq_false h2.2 (lt_asymm hut)⟩))
  · -- u = x: zone zAtX
    subst hux
    exact Or.inr (Or.inl (hzs _ _ _
      (Prod.ext_iff.mpr ⟨h0.1.mp hxw, k1v_bool_eq_false h0.2 (lt_asymm hxw)⟩)
      (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h1.1 (lt_irrefl u),
        k1v_bool_eq_false h1.2 (lt_irrefl u)⟩)
      (Prod.ext_iff.mpr ⟨h2.1.mp hxt, k1v_bool_eq_false h2.2 (lt_asymm hxt)⟩)))
  · -- x < u: split against w
    rcases lt_trichotomy u w with huw | huw | huw
    · -- x < u < w: zone zXW
      have hut : u < t := huw.trans hwt
      exact Or.inr (Or.inr (Or.inl (hzs _ _ _
        (Prod.ext_iff.mpr ⟨h0.1.mp huw, k1v_bool_eq_false h0.2 (lt_asymm huw)⟩)
        (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h1.1 (lt_asymm hux), h1.2.mp hux⟩)
        (Prod.ext_iff.mpr ⟨h2.1.mp hut, k1v_bool_eq_false h2.2 (lt_asymm hut)⟩))))
    · -- u = w: zone zAtW
      subst huw
      exact Or.inr (Or.inr (Or.inr (Or.inl (hzs _ _ _
        (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h0.1 (lt_irrefl u),
          k1v_bool_eq_false h0.2 (lt_irrefl u)⟩)
        (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h1.1 (lt_asymm hux), h1.2.mp hux⟩)
        (Prod.ext_iff.mpr ⟨h2.1.mp hwt, k1v_bool_eq_false h2.2 (lt_asymm hwt)⟩)))))
    · -- w < u: split against t
      rcases lt_trichotomy u t with hut | hut | hut
      · -- w < u < t: zone zWT
        exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inl (hzs _ _ _
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h0.1 (lt_asymm huw), h0.2.mp huw⟩)
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h1.1 (lt_asymm hux), h1.2.mp hux⟩)
          (Prod.ext_iff.mpr ⟨h2.1.mp hut, k1v_bool_eq_false h2.2 (lt_asymm hut)⟩))))))
      · -- u = t: zone zAtT
        subst hut
        exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inl (hzs _ _ _
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h0.1 (lt_asymm huw), h0.2.mp huw⟩)
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h1.1 (lt_asymm hux), h1.2.mp hux⟩)
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h2.1 (lt_irrefl u),
            k1v_bool_eq_false h2.2 (lt_irrefl u)⟩)))))))
      · -- t < u: zone zFutT
        exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (hzs _ _ _
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h0.1 (lt_asymm huw), h0.2.mp huw⟩)
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h1.1 (lt_asymm hux), h1.2.mp hux⟩)
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h2.1 (lt_asymm hut), h2.2.mp hut⟩)))))))

/-- Extraction for `bracketFromLists` (§5 bracket `[α_0, …, α_n](z_0, z_1)`, PDF p.7): from
    its `holds` at `(x, t)` obtain the middle witness `w` (bracket position `lL.length`),
    the realization of every left/right point type strictly inside `(x, w)` / `(w, t)`, and
    the gap classification: every point of `(x, w)` (resp. `(w, t)`) either carries a left
    (resp. right) point type or satisfies the `segL` (resp. `segR`) exclusion segment. This
    is the counterexample-defect fix of rule N4: witnesses are pinned strictly between the
    FIXED endpoints by `IntervalPattern.holds` monotonicity (never type-anchored — the
    refuted device of :1782-1796). -/
private theorem k1v_bracket_extract {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (lL lR : List TemporalPred) (ptW segL segR : TemporalPred)
    (x t : M.carrier)
    (h : (bracketFromLists lL ptW lR segL segR).holds M atomMap x t) :
    ∃ w : M.carrier, x < w ∧ w < t ∧
      ptW.eval_at M atomMap w ∧
      (∀ p ∈ lL, ∃ u, x < u ∧ u < w ∧ p.eval_at M atomMap u) ∧
      (∀ p ∈ lR, ∃ u, w < u ∧ u < t ∧ p.eval_at M atomMap u) ∧
      (∀ u, x < u → u < w →
        segL.eval_at M atomMap u ∨ ∃ p ∈ lL, p.eval_at M atomMap u) ∧
      (∀ u, w < u → u < t →
        segR.eval_at M atomMap u ∨ ∃ p ∈ lR, p.eval_at M atomMap u) := by
  simp only [BracketFormula.holds, BracketFormula.toIntervalPattern, bracketFromLists] at h
  rw [IntervalPattern.holds_eq_succ M atomMap _ _ x t
    (show lL.length + 1 + lR.length = (lL.length + lR.length) + 1 by omega)] at h
  obtain ⟨ws, hmono, hrange, hpt, hseg0, hsegmid, hseglast⟩ := h
  -- Nat-indexed views of the point-type and range facts (proof-irrelevant reindexing).
  have hpt' : ∀ (i : Nat) (hi : i < lL.length + lR.length + 1),
      ((lL ++ ptW :: lR)[i]'(by
        simp only [List.length_append, List.length_cons]; omega)).eval_at M atomMap
        (ws ⟨i, hi⟩) := fun i hi => hpt ⟨i, hi⟩
  refine ⟨ws ⟨lL.length, by omega⟩,
    (hrange ⟨lL.length, by omega⟩).1, (hrange ⟨lL.length, by omega⟩).2, ?_, ?_, ?_, ?_, ?_⟩
  · -- The middle point type is `ptW`: index `lL.length` in `lL ++ ptW :: lR`.
    have helem : (lL ++ ptW :: lR)[lL.length]'(by
        simp only [List.length_append, List.length_cons]; omega) = ptW := by
      rw [List.getElem_append_right (Nat.le_refl _)]
      simp
    have := hpt' lL.length (by omega)
    rwa [helem] at this
  · -- Every left point type is realized strictly inside `(x, w)`.
    intro p hp
    obtain ⟨j, hj, rfl⟩ := List.mem_iff_getElem.mp hp
    refine ⟨ws ⟨j, by omega⟩, (hrange ⟨j, by omega⟩).1,
      hmono ⟨j, by omega⟩ ⟨lL.length, by omega⟩ (Fin.mk_lt_mk.mpr hj), ?_⟩
    have := hpt' j (by omega)
    rwa [List.getElem_append_left hj] at this
  · -- Every right point type is realized strictly inside `(w, t)`.
    intro p hp
    obtain ⟨j, hj, rfl⟩ := List.mem_iff_getElem.mp hp
    refine ⟨ws ⟨lL.length + 1 + j, by omega⟩,
      hmono ⟨lL.length, by omega⟩ ⟨lL.length + 1 + j, by omega⟩
        (Fin.mk_lt_mk.mpr (by omega)),
      (hrange ⟨lL.length + 1 + j, by omega⟩).2, ?_⟩
    have helem : (lL ++ ptW :: lR)[lL.length + 1 + j]'(by
        simp only [List.length_append, List.length_cons]; omega) = lR[j]'hj := by
      rw [List.getElem_append_right (by omega)]
      simp only [show lL.length + 1 + j - lL.length = j + 1 by omega,
        List.getElem_cons_succ]
    have := hpt' (lL.length + 1 + j) (by omega)
    rwa [helem] at this
  · -- Gap classification on `(x, w)`: witness slot or `segL`.
    intro u hxu huw
    have main : ∀ j (hj : j ≤ lL.length), u < ws ⟨j, by omega⟩ →
        segL.eval_at M atomMap u ∨ ∃ p ∈ lL, p.eval_at M atomMap u := by
      intro j
      induction j with
      | zero =>
        intro _ hu0
        left
        have := hseg0 u hxu hu0
        rwa [if_pos (Nat.zero_le lL.length)] at this
      | succ j ih =>
        intro hj hu
        rcases lt_trichotomy u (ws ⟨j, by omega⟩) with h' | h' | h'
        · exact ih (by omega) h'
        · -- `u` IS witness `j` (with `j < lL.length`): it carries `lL[j]`.
          right
          have hptj := hpt' j (by omega)
          rw [List.getElem_append_left (by omega)] at hptj
          exact ⟨lL[j]'(by omega), List.getElem_mem _, by rw [h']; exact hptj⟩
        · -- `ws j < u < ws (j+1)`: interior segment `j + 1 ≤ lL.length` carries `segL`.
          left
          have := hsegmid ⟨j, by omega⟩ u h' hu
          rwa [if_pos hj] at this
    exact main lL.length (Nat.le_refl _) huw
  · -- Gap classification on `(w, t)`: witness slot or `segR`.
    intro u hwu hut
    have main : ∀ d j (hj : lL.length ≤ j) (hj2 : j + d = lL.length + lR.length),
        ws ⟨j, by omega⟩ < u →
        segR.eval_at M atomMap u ∨ ∃ p ∈ lR, p.eval_at M atomMap u := by
      intro d
      induction d with
      | zero =>
        intro j hj hj2 hju
        have hjeq : j = lL.length + lR.length := by omega
        subst hjeq
        left
        have := hseglast u hju hut
        rwa [if_neg (show ¬(lL.length + lR.length + 1 ≤ lL.length) by omega)] at this
      | succ d ih =>
        intro j hj hj2 hju
        rcases lt_trichotomy u (ws ⟨j + 1, by omega⟩) with h' | h' | h'
        · -- `ws j < u < ws (j+1)` with `j ≥ lL.length`: segment `j+1 > lL.length` is `segR`.
          left
          have := hsegmid ⟨j, by omega⟩ u hju h'
          rwa [if_neg (show ¬(j + 1 ≤ lL.length) by omega)] at this
        · -- `u` IS witness `j + 1` (with `j + 1 > lL.length`): it carries `lR[j - lL.length]`.
          right
          have hptj := hpt' (j + 1) (by omega)
          have helem : (lL ++ ptW :: lR)[j + 1]'(by
              simp only [List.length_append, List.length_cons]; omega) =
              lR[j - lL.length]'(by omega) := by
            rw [List.getElem_append_right (by omega)]
            simp only [show j + 1 - lL.length = (j - lL.length) + 1 by omega,
              List.getElem_cons_succ]
          rw [helem] at hptj
          exact ⟨lR[j - lL.length]'(by omega), List.getElem_mem _, by rw [h']; exact hptj⟩
        · exact ih (j + 1) (by omega) (by omega) h'
    exact main lR.length lL.length (Nat.le_refl _) rfl hwu

/-- Reconstruct the arity-3 depth-0 atom layer at env `[w, x, t]` from the three arity-1
    point evaluations and the six order biconditionals. Private clone of the VecEADecomp
    reconstruction helper (that lemma is `private` there and not importable). Chain step 3
    of the soundness direction: the endpoint/witness point types plus the k0-mirror order
    hypotheses assemble the atom layer (two-fixed-endpoint framing per **Lemma 3.2(2) PDF
    p.4 + §5 bracket PDF p.7**, rule N1). -/
private theorem k1v_reconstruct_nf3 {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (ssn : NormalForm sig 0 3) (y x t : M.carrier)
    (h_y_nf : nf_eval_nf M 0 1 (fun _ => y) (nf_y_proj ssn))
    (h_x_nf : nf_eval_nf M 0 1 (fun _ => x) (nf_x_proj3 ssn))
    (h_t_nf : nf_eval_nf M 0 1 (fun _ => t) (nf_t_proj3 ssn))
    (h_o_yx : (y < x) ↔ (ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = true))
    (h_o_yt : (y < t) ↔ (ssn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true))
    (h_o_xy : (x < y) ↔ (ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true))
    (h_o_xt : (x < t) ↔ (ssn (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = true))
    (h_o_ty : (t < y) ↔ (ssn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = true))
    (h_o_tx : (t < x) ↔ (ssn (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = true)) :
    nf_eval_nf M 0 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn := by
  intro a
  match a with
  | .pred p ⟨0, _⟩ =>
    have := h_y_nf (.pred p ⟨0, by omega⟩)
    simp only [atom_eval, Fin.cons, nf_y_proj] at this ⊢; exact this
  | .pred p ⟨1, _⟩ =>
    have := h_x_nf (.pred p ⟨0, by omega⟩)
    simp only [atom_eval, Fin.cons, nf_x_proj3] at this ⊢
    convert this using 1
  | .pred p ⟨2, _⟩ =>
    have := h_t_nf (.pred p ⟨0, by omega⟩)
    simp only [atom_eval, Fin.cons, nf_t_proj3] at this ⊢
    convert this using 1
  | .pred _ ⟨n + 3, h⟩ => exact absurd h (by omega)
  | .order ⟨0, _⟩ ⟨0, _⟩ h_neq => exact absurd rfl h_neq
  | .order ⟨0, _⟩ ⟨1, _⟩ _ => simp only [atom_eval, Fin.cons]; exact h_o_yx
  | .order ⟨0, _⟩ ⟨2, _⟩ _ => simp only [atom_eval, Fin.cons]; exact h_o_yt
  | .order ⟨1, _⟩ ⟨0, _⟩ _ => simp only [atom_eval, Fin.cons]; exact h_o_xy
  | .order ⟨1, _⟩ ⟨1, _⟩ h_neq => exact absurd rfl h_neq
  | .order ⟨1, _⟩ ⟨2, _⟩ _ => simp only [atom_eval, Fin.cons]; exact h_o_xt
  | .order ⟨2, _⟩ ⟨0, _⟩ _ => simp only [atom_eval, Fin.cons]; exact h_o_ty
  | .order ⟨2, _⟩ ⟨1, _⟩ _ => simp only [atom_eval, Fin.cons]; exact h_o_tx
  | .order ⟨2, _⟩ ⟨2, _⟩ h_neq => exact absurd rfl h_neq
  | .order ⟨n + 3, h⟩ _ _ => exact absurd h (by omega)
  | .order _ ⟨n + 3, h⟩ _ => exact absurd h (by omega)

/-- Bool helper: a proposition biconditional with a `false` bit fails. -/
private theorem k1v_not_of_iff_false {p : Prop} (h : p ↔ false = true) : ¬ p :=
  fun hp => absurd (h.mp hp) (by simp)

/-- **Soundness direction (LHS→RHS) of the k=1 V-carrier** (task 311 Phase 4). Under the six
    k0-mirror bracket-zone order hypotheses on `qnf.1` (exactly `bracketEndChar_k0_correct`
    :1577-1589 at depth 1), the `VVecEA2.holds` of `bracketEndChar_k1v` at the FIXED endpoints
    `(x, t)` yields a bracket witness `w` realizing the depth-1 arity-3 evaluation.

    Chain (rules N1/N2 splits; no simp/omega/aesop shortcut of a documented step — G5):
    1. Destructure the arrangement disjunct `(lL, lR)` from the `VVecEA2` disjunction (∨ over
       consistent order types, Def 3.1 pp.4-5) and extract the strictly ordered witness tuple
       via `k1v_bracket_extract`; `w :=` the middle witness at bracket position `lL.length`
       (§5 bracket `[α_0, …, α_n](z_0, z_1)`, PDF p.7 + Lemma 3.2(2) PDF p.4 for the
       two-fixed-endpoint framing). Each `lL`-witness lies strictly in `(x, w)` and each
       `lR`-witness strictly in `(w, t)` **by construction** — the exact counterexample defect
       removed (rule N4; replaces the refuted type-anchored chain reading of :1782-1796).
    2. Atom layer at `[w, x, t]` from the endpoint/witness complete types + the six order
       hypotheses (`k1v_reconstruct_nf3`; two-fixed-endpoint framing per N1).
    3. Quant layer through **`nf_quant_layer_fold_k1_gate`** (NfEFold:525): per **N2**, the
       **Def 4.1 p.6 note** licenses the innermost-fold reading and **Prop 4.3 (p.6)** only
       the "residual is ∨∃∀ over E[Σ] atoms" reading — realized locally via the fold, not by
       structural induction (305 report 14). The off-fiber conjunct is gate conjunct (i).
    4. Per-(zone, χ) matching: equality zones = biconditional literals in `epL`/`ptW`/`epR`;
       exterior zones = the Since/Until literals in `epL`/`epR` (Prop 3.5 p.5 folding
       mechanism — N4-valid there: the anchor IS the fixed endpoint); interior-positive zones
       = the arrangement witness slots (§5 bracket p.7; the witness joins the existential
       prefix, Lemma 3.4 p.5); interior-negative = `segL`/`segR` exclusions + completeness of
       the witness/gap classification (`nf_eval_unique`, NormalForm:245, for distinct
       complete 1-types at one point); inconsistent zones = gate conjunct (ii) +
       `k1v_zone_consistent` (Def 3.1: disjunctions range only over consistent order types). -/
private theorem bracketEndChar_k1v_sound {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (qnf : NormalForm sig 1 3)
    (h_xy : qnf.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    (h_yt : qnf.1 (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_xt : qnf.1 (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_yx : qnf.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (h_ty : qnf.1 (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
    (h_tx : qnf.1 (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (M : OrderedMonadicStructure sig) (x t : M.carrier)
    (h : (bracketEndChar_k1v atomMap h_surj qnf).holds M atomMap x t) :
    ∃ w : M.carrier, nf_eval_nf M 1 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf := by
  -- Step 1: destructure the V-carrier's disjunction and split on the gate.
  simp only [bracketEndChar_k1v, VVecEA2.holds] at h
  obtain ⟨vea, hmem, hveah⟩ := h
  split at hmem
  case isFalse hg =>
    -- Empty disjunction over inconsistent order types: `holds` is False.
    simp at hmem
  case isTrue hg =>
  rw [List.mem_flatMap] at hmem
  obtain ⟨lL, hlLp, hmem⟩ := hmem
  rw [List.mem_map] at hmem
  obtain ⟨lR, hlRp, hEq⟩ := hmem
  subst hEq
  obtain ⟨hepL, hepR, hbr⟩ := hveah
  -- Extract the middle witness `w` and the witness/gap structure (§5 bracket, PDF p.7).
  obtain ⟨w, hxw, hwt, hptWe, hLwit, hRwit, hLgap, hRgap⟩ :=
    k1v_bracket_extract M atomMap _ _ _ _ _ x t hbr
  have hxt : x < t := hxw.trans hwt
  -- Complete-type correctness bridge (char χ at u ↔ arity-1 depth-0 evaluation).
  have hchar : ∀ (χ' : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (nf_depth0_char_formula atomMap h_surj χ') ↔
      nf_eval_nf M 0 1 (fun _ => u) χ' :=
    fun χ' u => nfPred_correct M atomMap h_surj χ' u
  -- Unfold the three anchor conjunction lists.
  simp only [TemporalPred.eval_at] at hepL hepR hptWe
  rw [formula_conjList_iff] at hepL hepR hptWe
  -- Endpoint/witness complete types (heads of the conjunction lists).
  have hxT : temporal_truth M atomMap x
      (nf_depth0_char_formula atomMap h_surj (nf_x_proj3 qnf.1)) :=
    hepL _ (List.mem_append_left _ List.mem_cons_self)
  have htT : temporal_truth M atomMap t
      (nf_depth0_char_formula atomMap h_surj (nf_t_proj3 qnf.1)) :=
    hepR _ (List.mem_append_left _ List.mem_cons_self)
  have hyW : temporal_truth M atomMap w
      (nf_depth0_char_formula atomMap h_surj (nf_y_proj qnf.1)) :=
    hptWe _ List.mem_cons_self
  -- Fold-bit literal facts at the anchors (Prop 3.5 folding mechanism, PDF p.5).
  have hPastX : ∀ χ' : NormalForm sig 0 1, temporal_truth M atomMap x
      (if (efold_of_nf1 qnf).2
          (Fin.cons (true, false) (Fin.cons (true, false) (fun _ => (true, false))), χ') = true
       then Formula.snce (nf_depth0_char_formula atomMap h_surj χ') Formula.top
       else (Formula.snce (nf_depth0_char_formula atomMap h_surj χ') Formula.top).neg) :=
    fun χ' => hepL _ (List.mem_append_left _
      (List.mem_cons_of_mem _ (List.mem_map_of_mem (by simp))))
  have hAtX : ∀ χ' : NormalForm sig 0 1, temporal_truth M atomMap x
      (if (efold_of_nf1 qnf).2
          (Fin.cons (true, false) (Fin.cons (false, false) (fun _ => (true, false))), χ') = true
       then nf_depth0_char_formula atomMap h_surj χ'
       else (nf_depth0_char_formula atomMap h_surj χ').neg) :=
    fun χ' => hepL _ (List.mem_append_right _ (List.mem_map_of_mem (by simp)))
  have hAtW : ∀ χ' : NormalForm sig 0 1, temporal_truth M atomMap w
      (if (efold_of_nf1 qnf).2
          (Fin.cons (false, false) (Fin.cons (false, true) (fun _ => (true, false))), χ') = true
       then nf_depth0_char_formula atomMap h_surj χ'
       else (nf_depth0_char_formula atomMap h_surj χ').neg) :=
    fun χ' => hptWe _ (List.mem_cons_of_mem _ (List.mem_map_of_mem (by simp)))
  have hAtT : ∀ χ' : NormalForm sig 0 1, temporal_truth M atomMap t
      (if (efold_of_nf1 qnf).2
          (Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (false, false))), χ') = true
       then nf_depth0_char_formula atomMap h_surj χ'
       else (nf_depth0_char_formula atomMap h_surj χ').neg) :=
    fun χ' => hepR _ (List.mem_append_left _
      (List.mem_cons_of_mem _ (List.mem_map_of_mem (by simp))))
  have hFutT : ∀ χ' : NormalForm sig 0 1, temporal_truth M atomMap t
      (if (efold_of_nf1 qnf).2
          (Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (false, true))), χ') = true
       then Formula.untl (nf_depth0_char_formula atomMap h_surj χ') Formula.top
       else (Formula.untl (nf_depth0_char_formula atomMap h_surj χ') Formula.top).neg) :=
    fun χ' => hepR _ (List.mem_append_right _ (List.mem_map_of_mem (by simp)))
  -- Chain step 2 (atom layer at `[w, x, t]`, rule N1 framing).
  have h_atom : nf_eval_nf M 0 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf.1 :=
    k1v_reconstruct_nf3 M qnf.1 w x t
      ((hchar _ w).mp hyW) ((hchar _ x).mp hxT) ((hchar _ t).mp htT)
      (iff_of_false (lt_asymm hxw) (by simp only [h_yx]; decide))
      (iff_of_true hwt h_yt)
      (iff_of_true hxw h_xy)
      (iff_of_true hxt h_xt)
      (iff_of_false (lt_asymm hwt) (by simp only [h_ty]; decide))
      (iff_of_false (lt_asymm hxt) (by simp only [h_tx]; decide))
  -- Chain step 4 (per-zone matching): each `(zone, χ)` fold bit matches its semantic
  -- existential over env `[w, x, t]`.
  have hzone : ∀ (zs : ZoneSpec 3) (χ : NormalForm sig 0 1),
      (∃ u : M.carrier,
        zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t))) zs u ∧
        nf_eval_nf M 0 1 (fun _ => u) χ) ↔
      qnf.2 (nf0_assemble zs χ qnf.1) = true := by
    intro zs χ
    rw [show qnf.2 (nf0_assemble zs χ qnf.1) = (efold_of_nf1 qnf).2 (zs, χ) from rfl]
    by_cases hcons :
      zs = Fin.cons (true, false) (Fin.cons (true, false) (fun _ => (true, false))) ∨
      zs = Fin.cons (true, false) (Fin.cons (false, false) (fun _ => (true, false))) ∨
      zs = Fin.cons (true, false) (Fin.cons (false, true) (fun _ => (true, false))) ∨
      zs = Fin.cons (false, false) (Fin.cons (false, true) (fun _ => (true, false))) ∨
      zs = Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (true, false))) ∨
      zs = Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (false, false))) ∨
      zs = Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (false, true)))
    · rcases hcons with rfl | rfl | rfl | rfl | rfl | rfl | rfl
      · -- Zone zPastX (`u < x`): the Since literal in `epL` (Prop 3.5 mechanism, PDF p.5;
        -- N4-valid: anchored at the FIXED endpoint `x`).
        constructor
        · rintro ⟨u, hzu, hev⟩
          rw [k1v_zoneHolds_cons_iff] at hzu
          have hux : u < x := hzu.2.1.1.mpr rfl
          cases hbb : (efold_of_nf1 qnf).2
            (Fin.cons (true, false) (Fin.cons (true, false) (fun _ => (true, false))), χ) with
          | false =>
            have hlit := hPastX χ
            rw [if_neg (by simp [hbb])] at hlit
            exact (hlit ⟨u, hux, (hchar χ u).mpr hev, fun r _ _ hf => hf⟩).elim
          | true => rfl
        · intro hbit
          have hlit := hPastX χ
          rw [if_pos hbit] at hlit
          obtain ⟨s, hsx, hsχ, -⟩ := hlit
          have hsw : s < w := hsx.trans hxw
          have hst : s < t := hsw.trans hwt
          refine ⟨s, ?_, (hchar χ s).mp hsχ⟩
          rw [k1v_zoneHolds_cons_iff]
          exact ⟨⟨iff_of_true hsw rfl, iff_of_false (lt_asymm hsw) (by simp)⟩,
            ⟨iff_of_true hsx rfl, iff_of_false (lt_asymm hsx) (by simp)⟩,
            ⟨iff_of_true hst rfl, iff_of_false (lt_asymm hst) (by simp)⟩⟩
      · -- Zone zAtX (`u = x`): the biconditional literal in `epL`.
        constructor
        · rintro ⟨u, hzu, hev⟩
          rw [k1v_zoneHolds_cons_iff] at hzu
          have hueq : u = x := le_antisymm
            (not_lt.mp (k1v_not_of_iff_false hzu.2.1.2))
            (not_lt.mp (k1v_not_of_iff_false hzu.2.1.1))
          subst hueq
          cases hbb : (efold_of_nf1 qnf).2
            (Fin.cons (true, false) (Fin.cons (false, false) (fun _ => (true, false))), χ) with
          | false =>
            have hlit := hAtX χ
            rw [if_neg (by simp [hbb])] at hlit
            exact (hlit ((hchar χ u).mpr hev)).elim
          | true => rfl
        · intro hbit
          have hlit := hAtX χ
          rw [if_pos hbit] at hlit
          refine ⟨x, ?_, (hchar χ x).mp hlit⟩
          rw [k1v_zoneHolds_cons_iff]
          exact ⟨⟨iff_of_true hxw rfl, iff_of_false (lt_asymm hxw) (by simp)⟩,
            ⟨iff_of_false (lt_irrefl x) (by simp), iff_of_false (lt_irrefl x) (by simp)⟩,
            ⟨iff_of_true hxt rfl, iff_of_false (lt_asymm hxt) (by simp)⟩⟩
      · -- Zone zXW (`x < u < w`): interior-positive bits ride the LEFT witness slots
        -- (§5 bracket p.7; Lemma 3.4 p.5); negative bits by the `segL` exclusion + the
        -- witness/gap classification (rule N4/N5).
        constructor
        · rintro ⟨u, hzu, hev⟩
          rw [k1v_zoneHolds_cons_iff] at hzu
          have hxu : x < u := hzu.2.1.2.mpr rfl
          have huw : u < w := hzu.1.1.mpr rfl
          cases hbb : (efold_of_nf1 qnf).2
            (Fin.cons (true, false) (Fin.cons (false, true) (fun _ => (true, false))), χ) with
          | false =>
            exfalso
            rcases hLgap u hxu huw with hseg | ⟨p, hpmem, hpe⟩
            · -- `u` is a gap point: the `segL` exclusion conjunct for χ refutes `hev`.
              simp only [TemporalPred.eval_at] at hseg
              rw [formula_conjList_iff] at hseg
              have hexcl : temporal_truth M atomMap u
                  (if (efold_of_nf1 qnf).2
                      (Fin.cons (true, false) (Fin.cons (false, true)
                        (fun _ => (true, false))), χ) = true
                   then Formula.top
                   else (nf_depth0_char_formula atomMap h_surj χ).neg) :=
                hseg _ (List.mem_map_of_mem (by simp))
              rw [if_neg (by simp [hbb])] at hexcl
              exact hexcl ((hchar χ u).mpr hev)
            · -- `u` is a witness slot: it carries some positive χ'; distinct complete
              -- 1-types cannot share a point (`nf_eval_unique`, NormalForm:245).
              obtain ⟨χ', hχ'mem, rfl⟩ := List.mem_map.mp hpmem
              have hev' : nf_eval_nf M 0 1 (fun _ => u) χ' := (hchar χ' u).mp hpe
              have hbb' : (efold_of_nf1 qnf).2
                  (Fin.cons (true, false) (Fin.cons (false, true)
                    (fun _ => (true, false))), χ') = true :=
                (List.mem_filter.mp ((List.mem_permutations.mp hlLp).mem_iff.mp hχ'mem)).2
              have hEqχ : χ = χ' := nf_eval_unique M 0 1 _ χ χ' hev hev'
              rw [hEqχ] at hbb
              exact absurd hbb' (by simp [hbb])
          | true => rfl
        · intro hbit
          have hχSL : χ ∈ lL := (List.mem_permutations.mp hlLp).mem_iff.mpr
            (List.mem_filter.mpr ⟨by simp, hbit⟩)
          obtain ⟨u, hxu, huw, hpe⟩ := hLwit _ (List.mem_map_of_mem hχSL)
          have hut : u < t := huw.trans hwt
          refine ⟨u, ?_, (hchar χ u).mp hpe⟩
          rw [k1v_zoneHolds_cons_iff]
          exact ⟨⟨iff_of_true huw rfl, iff_of_false (lt_asymm huw) (by simp)⟩,
            ⟨iff_of_false (lt_asymm hxu) (by simp), iff_of_true hxu rfl⟩,
            ⟨iff_of_true hut rfl, iff_of_false (lt_asymm hut) (by simp)⟩⟩
      · -- Zone zAtW (`u = w`): the biconditional literal in the witness point type `ptW`.
        constructor
        · rintro ⟨u, hzu, hev⟩
          rw [k1v_zoneHolds_cons_iff] at hzu
          have hueq : u = w := le_antisymm
            (not_lt.mp (k1v_not_of_iff_false hzu.1.2))
            (not_lt.mp (k1v_not_of_iff_false hzu.1.1))
          subst hueq
          cases hbb : (efold_of_nf1 qnf).2
            (Fin.cons (false, false) (Fin.cons (false, true) (fun _ => (true, false))), χ) with
          | false =>
            have hlit := hAtW χ
            rw [if_neg (by simp [hbb])] at hlit
            exact (hlit ((hchar χ u).mpr hev)).elim
          | true => rfl
        · intro hbit
          have hlit := hAtW χ
          rw [if_pos hbit] at hlit
          refine ⟨w, ?_, (hchar χ w).mp hlit⟩
          rw [k1v_zoneHolds_cons_iff]
          exact ⟨⟨iff_of_false (lt_irrefl w) (by simp), iff_of_false (lt_irrefl w) (by simp)⟩,
            ⟨iff_of_false (lt_asymm hxw) (by simp), iff_of_true hxw rfl⟩,
            ⟨iff_of_true hwt rfl, iff_of_false (lt_asymm hwt) (by simp)⟩⟩
      · -- Zone zWT (`w < u < t`): interior-positive bits ride the RIGHT witness slots
        -- (§5 bracket p.7; Lemma 3.4 p.5); negative bits by the `segR` exclusion.
        constructor
        · rintro ⟨u, hzu, hev⟩
          rw [k1v_zoneHolds_cons_iff] at hzu
          have hwu : w < u := hzu.1.2.mpr rfl
          have hut : u < t := hzu.2.2.1.mpr rfl
          cases hbb : (efold_of_nf1 qnf).2
            (Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (true, false))), χ) with
          | false =>
            exfalso
            rcases hRgap u hwu hut with hseg | ⟨p, hpmem, hpe⟩
            · simp only [TemporalPred.eval_at] at hseg
              rw [formula_conjList_iff] at hseg
              have hexcl : temporal_truth M atomMap u
                  (if (efold_of_nf1 qnf).2
                      (Fin.cons (false, true) (Fin.cons (false, true)
                        (fun _ => (true, false))), χ) = true
                   then Formula.top
                   else (nf_depth0_char_formula atomMap h_surj χ).neg) :=
                hseg _ (List.mem_map_of_mem (by simp))
              rw [if_neg (by simp [hbb])] at hexcl
              exact hexcl ((hchar χ u).mpr hev)
            · obtain ⟨χ', hχ'mem, rfl⟩ := List.mem_map.mp hpmem
              have hev' : nf_eval_nf M 0 1 (fun _ => u) χ' := (hchar χ' u).mp hpe
              have hbb' : (efold_of_nf1 qnf).2
                  (Fin.cons (false, true) (Fin.cons (false, true)
                    (fun _ => (true, false))), χ') = true :=
                (List.mem_filter.mp ((List.mem_permutations.mp hlRp).mem_iff.mp hχ'mem)).2
              have hEqχ : χ = χ' := nf_eval_unique M 0 1 _ χ χ' hev hev'
              rw [hEqχ] at hbb
              exact absurd hbb' (by simp [hbb])
          | true => rfl
        · intro hbit
          have hχSR : χ ∈ lR := (List.mem_permutations.mp hlRp).mem_iff.mpr
            (List.mem_filter.mpr ⟨by simp, hbit⟩)
          obtain ⟨u, hwu, hut, hpe⟩ := hRwit _ (List.mem_map_of_mem hχSR)
          have hxu : x < u := hxw.trans hwu
          refine ⟨u, ?_, (hchar χ u).mp hpe⟩
          rw [k1v_zoneHolds_cons_iff]
          exact ⟨⟨iff_of_false (lt_asymm hwu) (by simp), iff_of_true hwu rfl⟩,
            ⟨iff_of_false (lt_asymm hxu) (by simp), iff_of_true hxu rfl⟩,
            ⟨iff_of_true hut rfl, iff_of_false (lt_asymm hut) (by simp)⟩⟩
      · -- Zone zAtT (`u = t`): the biconditional literal in `epR`.
        constructor
        · rintro ⟨u, hzu, hev⟩
          rw [k1v_zoneHolds_cons_iff] at hzu
          have hueq : u = t := le_antisymm
            (not_lt.mp (k1v_not_of_iff_false hzu.2.2.2))
            (not_lt.mp (k1v_not_of_iff_false hzu.2.2.1))
          subst hueq
          cases hbb : (efold_of_nf1 qnf).2
            (Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (false, false))), χ) with
          | false =>
            have hlit := hAtT χ
            rw [if_neg (by simp [hbb])] at hlit
            exact (hlit ((hchar χ u).mpr hev)).elim
          | true => rfl
        · intro hbit
          have hlit := hAtT χ
          rw [if_pos hbit] at hlit
          refine ⟨t, ?_, (hchar χ t).mp hlit⟩
          rw [k1v_zoneHolds_cons_iff]
          exact ⟨⟨iff_of_false (lt_asymm hwt) (by simp), iff_of_true hwt rfl⟩,
            ⟨iff_of_false (lt_asymm hxt) (by simp), iff_of_true hxt rfl⟩,
            ⟨iff_of_false (lt_irrefl t) (by simp), iff_of_false (lt_irrefl t) (by simp)⟩⟩
      · -- Zone zFutT (`t < u`): the Until literal in `epR` (Prop 3.5 mechanism, PDF p.5;
        -- N4-valid: anchored at the FIXED endpoint `t`).
        constructor
        · rintro ⟨u, hzu, hev⟩
          rw [k1v_zoneHolds_cons_iff] at hzu
          have htu : t < u := hzu.2.2.2.mpr rfl
          cases hbb : (efold_of_nf1 qnf).2
            (Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (false, true))), χ) with
          | false =>
            have hlit := hFutT χ
            rw [if_neg (by simp [hbb])] at hlit
            exact (hlit ⟨u, htu, (hchar χ u).mpr hev, fun r _ _ hf => hf⟩).elim
          | true => rfl
        · intro hbit
          have hlit := hFutT χ
          rw [if_pos hbit] at hlit
          obtain ⟨s, hts, hsχ, -⟩ := hlit
          have hws : w < s := hwt.trans hts
          have hxs : x < s := hxw.trans hws
          refine ⟨s, ?_, (hchar χ s).mp hsχ⟩
          rw [k1v_zoneHolds_cons_iff]
          exact ⟨⟨iff_of_false (lt_asymm hws) (by simp), iff_of_true hws rfl⟩,
            ⟨iff_of_false (lt_asymm hxs) (by simp), iff_of_true hxs rfl⟩,
            ⟨iff_of_false (lt_asymm hts) (by simp), iff_of_true hts rfl⟩⟩
    · -- Inconsistent zone spec: gate conjunct (ii) forces the bit false; no realizing
      -- point exists (`k1v_zone_consistent`, Def 3.1 consistent order types).
      constructor
      · rintro ⟨u, hzu, -⟩
        exact absurd (k1v_zone_consistent M w x t u hxw hwt zs hzu) hcons
      · intro hbit
        have hfalse : (efold_of_nf1 qnf).2 (zs, χ) = false := hg.2 zs χ hcons
        rw [hfalse] at hbit
        exact absurd hbit (by simp)
  -- Chain step 3 (assembly): depth-1 evaluation = atom layer + quant layer; the quant layer
  -- routes through the gate corollary (Def 4.1 p.6 note / Prop 4.3 p.6 — rule N2; the
  -- off-fiber conjunct is gate conjunct (i)).
  refine ⟨w, ?_⟩
  have hwhole : nf_eval_nf M 1 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf ↔
      (nf_eval_nf M 0 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf.1 ∧
        (∀ sub : NormalForm sig 0 4,
          (∃ x1 : M.carrier, nf_eval_nf M 0 4
            (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) sub) ↔
            qnf.2 sub = true)) := Iff.rfl
  rw [hwhole]
  refine ⟨h_atom, ?_⟩
  rw [nf_quant_layer_fold_k1_gate M w x t qnf h_atom]
  exact ⟨hzone, hg.1⟩

/-! ## Task 311 Phase 5: completeness direction (RHS→LHS) — helper kit

Private helper kit for `bracketEndChar_k1v_complete` (pre-authorized 5.1/5.2 split, plan v3
Phase 5 H8 escape hatch). The arrangement-selection machinery (Risk R1', rule N5) is the
insertion induction below: by induction on the interior-positive type list, insert one realized
point at a time in model order, building the sorted witness tuple AND the matching arrangement
simultaneously — mirroring the append-a-witness construction of
`BracketFormula.existsBounded_right`'s `n+1` case (VecEAClosure:265, the **Lemma 3.4 (PDF p.5)**
∃-closure vehicle, used as TEMPLATE: the target here is a fixed arrangement disjunct of the
`VVecEA2` finite disjunction, not an `∃ m` conclusion). Citations per rule N1: the
two-fixed-endpoint framing is **Lemma 3.2(2) (PDF p.4) + §5 bracket notation (PDF p.7)**. -/

/-- Extract the arity-1 witness-point evaluation from the arity-3 depth-0 atom layer at env
    `[y, x, t]` (variable 0). Private clone of the VecEADecomp extraction helper (that lemma
    is `private` there and not importable), exactly as `k1v_reconstruct_nf3` clones the
    reverse direction. -/
private theorem k1v_extract_y_nf {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (ssn : NormalForm sig 0 3) (y x t : M.carrier)
    (h_nf : nf_eval_nf M 0 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn) :
    nf_eval_nf M 0 1 (fun _ => y) (nf_y_proj ssn) := by
  intro a
  match a with
  | .pred p _ =>
    have := h_nf (.pred p ⟨0, by omega⟩)
    simp only [atom_eval, Fin.cons, nf_y_proj] at this ⊢
    exact this
  | .order i j h_neq => exact absurd (Fin.ext (by omega) : i = j) h_neq

/-- Extract the arity-1 left-endpoint evaluation (variable 1, the FIXED `z_0 = x`) from the
    arity-3 depth-0 atom layer. Private VecEADecomp clone (see `k1v_extract_y_nf`). -/
private theorem k1v_extract_x_nf3 {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (ssn : NormalForm sig 0 3) (y x t : M.carrier)
    (h_nf : nf_eval_nf M 0 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn) :
    nf_eval_nf M 0 1 (fun _ => x) (nf_x_proj3 ssn) := by
  intro a
  match a with
  | .pred p _ =>
    have := h_nf (.pred p ⟨1, by omega⟩)
    simp only [atom_eval] at this
    have hfc1 : (Fin.cons y (Fin.cons x (fun _ : Fin 1 => t)) : Fin 3 → M.carrier)
        ⟨1, by omega⟩ = x := by
      simp [Fin.cons]; rfl
    rw [hfc1] at this
    simp only [nf_x_proj3]; exact this
  | .order i j h_neq => exact absurd (Fin.ext (by omega) : i = j) h_neq

/-- Extract the arity-1 right-endpoint evaluation (variable 2, the FIXED `z_1 = t`) from the
    arity-3 depth-0 atom layer. Private VecEADecomp clone (see `k1v_extract_y_nf`). -/
private theorem k1v_extract_t_nf3 {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (ssn : NormalForm sig 0 3) (y x t : M.carrier)
    (h_nf : nf_eval_nf M 0 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn) :
    nf_eval_nf M 0 1 (fun _ => t) (nf_t_proj3 ssn) := by
  intro a
  match a with
  | .pred p _ =>
    have := h_nf (.pred p ⟨2, by omega⟩)
    simp only [atom_eval] at this
    have hfc2 : (Fin.cons y (Fin.cons x (fun _ : Fin 1 => t)) : Fin 3 → M.carrier)
        ⟨2, by omega⟩ = t := by
      simp [Fin.cons]; rfl
    rw [hfc2] at this
    simp only [nf_t_proj3]; exact this
  | .order i j h_neq => exact absurd (Fin.ext (by omega) : i = j) h_neq

/-- **Insertion step of the arrangement-selection induction** (Risk R1', rule N5): insert one
    tagged point into a snd-sorted list of tagged points, preserving sortedness, provided the
    new point is distinct from every listed point. The insertion position is found by
    trichotomy in model order — one step of the witness-insertion construction (template:
    `existsBounded_right`'s `n+1` append case, VecEAClosure:265; Lemma 3.4 PDF p.5). -/
private theorem k1v_sorted_insert {α : Type _} {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (q : α × M.carrier) (ps : List (α × M.carrier))
    (hs : (ps.map Prod.snd).Pairwise (· < ·))
    (hne : ∀ p ∈ ps, p.2 ≠ q.2) :
    ∃ qs : List (α × M.carrier),
      List.Perm qs (q :: ps) ∧ (qs.map Prod.snd).Pairwise (· < ·) := by
  induction ps with
  | nil => exact ⟨[q], List.Perm.refl _, List.pairwise_singleton _ _⟩
  | cons p ps ih =>
    rw [List.map_cons, List.pairwise_cons] at hs
    rcases lt_trichotomy q.2 p.2 with hlt | heq | hgt
    · -- `q` precedes the head: `q :: p :: ps` is already sorted.
      refine ⟨q :: p :: ps, List.Perm.refl _, ?_⟩
      rw [List.map_cons, List.pairwise_cons]
      refine ⟨?_, ?_⟩
      · intro b hb
        rw [List.map_cons, List.mem_cons] at hb
        rcases hb with rfl | hb
        · exact hlt
        · exact hlt.trans (hs.1 b hb)
      · rw [List.map_cons, List.pairwise_cons]
        exact hs
    · exact absurd heq.symm (hne p List.mem_cons_self)
    · -- `q` lands strictly after the head: insert into the tail.
      obtain ⟨qs', hperm', hsort'⟩ :=
        ih hs.2 (fun r hr => hne r (List.mem_cons_of_mem _ hr))
      refine ⟨p :: qs', (hperm'.cons p).trans (List.Perm.swap q p ps), ?_⟩
      rw [List.map_cons, List.pairwise_cons]
      refine ⟨?_, hsort'⟩
      intro b hb
      obtain ⟨r, hr, rfl⟩ := List.mem_map.mp hb
      rcases List.mem_cons.mp (hperm'.mem_iff.mp hr) with rfl | hrps
      · exact hgt
      · exact hs.1 r.2 (List.mem_map_of_mem hrps)

/-- **Arrangement selection by insertion induction** (Risk R1', rule N5): every list of
    complete 1-types each realized somewhere strictly inside `(a, b)` admits a simultaneous
    arrangement — a permutation of the type list tagged with realizing points in strictly
    increasing model order. Distinctness of the realizing points is automatic: distinct
    complete 1-types exclude each other at any single point (`nf_eval_unique`,
    NormalForm:245). The `VVecEA2` disjunction carries ALL arrangements (rule N5 — Rabinovich's
    ∨ over consistent order types, Def 3.1 pp.4-5), so the arrangement selected here always
    names an existing disjunct; each realized point occupies a bracket WITNESS slot between the
    FIXED endpoints (§5 bracket `[α_0, …, α_n](z_0, z_1)`, PDF p.7; the witness joins the
    existential prefix, Lemma 3.4 PDF p.5). -/
private theorem k1v_sorted_realization {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (a b : M.carrier)
    (S : List (NormalForm sig 0 1)) (hnd : S.Nodup)
    (hreal : ∀ χ ∈ S, ∃ u, a < u ∧ u < b ∧ nf_eval_nf M 0 1 (fun _ => u) χ) :
    ∃ ps : List (NormalForm sig 0 1 × M.carrier),
      List.Perm (ps.map Prod.fst) S ∧
      (ps.map Prod.snd).Pairwise (· < ·) ∧
      ∀ p ∈ ps, (a < p.2 ∧ p.2 < b) ∧ nf_eval_nf M 0 1 (fun _ => p.2) p.1 := by
  induction S with
  | nil => exact ⟨[], by simp, by simp, by simp⟩
  | cons χ S' ih =>
    obtain ⟨u, hau, hub, huχ⟩ := hreal χ List.mem_cons_self
    obtain ⟨ps', hperm', hsort', hprops'⟩ :=
      ih (List.nodup_cons.mp hnd).2 (fun χ' h' => hreal χ' (List.mem_cons_of_mem _ h'))
    -- The new point is distinct from every listed point: distinct complete 1-types
    -- exclude each other at one point (`nf_eval_unique`), and `χ ∉ S'` by Nodup.
    have hne : ∀ p ∈ ps', p.2 ≠ u := by
      intro p hp heq
      have hev : nf_eval_nf M 0 1 (fun _ => u) p.1 := heq ▸ (hprops' p hp).2
      have hpq : p.1 = χ := nf_eval_unique M 0 1 _ p.1 χ hev huχ
      have : χ ∈ S' := hperm'.mem_iff.mp (hpq ▸ List.mem_map_of_mem hp)
      exact (List.nodup_cons.mp hnd).1 this
    obtain ⟨qs, hqperm, hqsort⟩ := k1v_sorted_insert M (χ, u) ps' hsort' hne
    refine ⟨qs, ?_, hqsort, ?_⟩
    · have h1 : List.Perm (qs.map Prod.fst) (((χ, u) :: ps').map Prod.fst) := hqperm.map _
      rw [List.map_cons] at h1
      exact h1.trans (hperm'.cons χ)
    · intro p hp
      rcases List.mem_cons.mp (hqperm.mem_iff.mp hp) with rfl | hp'
      · exact ⟨⟨hau, hub⟩, huχ⟩
      · exact hprops' p hp'

/-- Construction for `bracketFromLists` (the reverse of `k1v_bracket_extract`; §5 bracket
    `[α_0, …, α_n](z_0, z_1)`, PDF p.7): given a sorted tuple of realizing points — left
    points strictly inside `(x, w)`, the middle witness `w`, right points strictly inside
    `(w, t)` — with each point type realized at its point and the `segL`/`segR` exclusions
    holding on ALL of `(x, w)` / `(w, t)`, the bracket holds at the FIXED endpoints `(x, t)`.
    Mirrors the append-a-witness construction of `existsBounded_right`'s `n+1` case
    (VecEAClosure:265; Lemma 3.4 PDF p.5) with the witness tuple assembled wholesale from the
    insertion-induction output of `k1v_sorted_realization`. -/
private theorem k1v_bracket_construct {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (lL lR : List TemporalPred) (ptW segL segR : TemporalPred)
    (x w t : M.carrier) (hxw : x < w) (hwt : w < t)
    (usL usR : List M.carrier)
    (hlenL : usL.length = lL.length) (hlenR : usR.length = lR.length)
    (hsort : (usL ++ w :: usR).Pairwise (· < ·))
    (hrangeL : ∀ u ∈ usL, x < u ∧ u < w)
    (hrangeR : ∀ u ∈ usR, w < u ∧ u < t)
    (hptw : ptW.eval_at M atomMap w)
    (hptL : ∀ (i : Nat) (hi : i < lL.length),
      (lL[i]'hi).eval_at M atomMap (usL[i]'(by omega)))
    (hptR : ∀ (i : Nat) (hi : i < lR.length),
      (lR[i]'hi).eval_at M atomMap (usR[i]'(by omega)))
    (hsegL : ∀ u, x < u → u < w → segL.eval_at M atomMap u)
    (hsegR : ∀ u, w < u → u < t → segR.eval_at M atomMap u) :
    (bracketFromLists lL ptW lR segL segR).holds M atomMap x t := by
  have hlen : (usL ++ w :: usR).length = lL.length + lR.length + 1 := by
    simp only [List.length_append, List.length_cons, hlenL, hlenR]
    omega
  -- Everything in the combined witness list lies strictly inside the fixed endpoints.
  have hrange_all : ∀ u ∈ usL ++ w :: usR, x < u ∧ u < t := by
    intro u hu
    rcases List.mem_append.mp hu with hu | hu
    · exact ⟨(hrangeL _ hu).1, (hrangeL _ hu).2.trans hwt⟩
    · rcases List.mem_cons.mp hu with rfl | hu
      · exact ⟨hxw, hwt⟩
      · exact ⟨hxw.trans (hrangeR _ hu).1, (hrangeR _ hu).2⟩
  -- Points at index ≤ lL.length sit at or left of the middle witness `w`; ≥ at or right.
  have hle_w : ∀ (j : Nat) (hj1 : j ≤ lL.length) (hj2 : j < (usL ++ w :: usR).length),
      (usL ++ w :: usR)[j] ≤ w := by
    intro j hj1 hj2
    rcases Nat.lt_or_eq_of_le hj1 with hj | hj
    · rw [List.getElem_append_left (by omega)]
      exact le_of_lt (hrangeL _ (List.getElem_mem _)).2
    · rw [List.getElem_append_right (by omega)]
      simp only [show j - usL.length = 0 by omega, List.getElem_cons_zero]
      exact le_refl w
  have hge_w : ∀ (j : Nat) (hj1 : lL.length ≤ j) (hj2 : j < (usL ++ w :: usR).length),
      w ≤ (usL ++ w :: usR)[j] := by
    intro j hj1 hj2
    rw [List.getElem_append_right (by omega)]
    by_cases hj0 : j - usL.length = 0
    · simp only [hj0, List.getElem_cons_zero]
      exact le_refl w
    · obtain ⟨d, hd⟩ : ∃ d, j - usL.length = d + 1 := ⟨j - usL.length - 1, by omega⟩
      simp only [hd, List.getElem_cons_succ]
      exact le_of_lt (hrangeR _ (List.getElem_mem _)).1
  simp only [BracketFormula.holds, BracketFormula.toIntervalPattern, bracketFromLists]
  rw [IntervalPattern.holds_eq_succ M atomMap _ _ x t
    (show lL.length + 1 + lR.length = (lL.length + lR.length) + 1 by omega)]
  refine ⟨fun i => (usL ++ w :: usR)[i.val]'(by omega), ?_, ?_, ?_, ?_, ?_, ?_⟩
  · -- Strict monotonicity from the sorted combined list.
    intro i j hij
    exact List.pairwise_iff_getElem.mp hsort i.val j.val (by omega) (by omega) hij
  · -- Range: all points strictly inside the fixed endpoints.
    intro i
    exact hrange_all _ (List.getElem_mem _)
  · -- Point types: three-way index split around the middle witness slot.
    intro i
    simp only []
    rcases Nat.lt_trichotomy i.val lL.length with hi | hi | hi
    · rw [List.getElem_append_left hi, List.getElem_append_left (show i.val < usL.length by omega)]
      exact hptL i.val hi
    · have h1 : (lL ++ ptW :: lR)[i.val]'(by
          simp only [List.length_append, List.length_cons]; omega) = ptW := by
        rw [List.getElem_append_right (le_of_eq hi.symm)]
        simp only [show i.val - lL.length = 0 by omega, List.getElem_cons_zero]
      have h2 : (usL ++ w :: usR)[i.val]'(by omega) = w := by
        rw [List.getElem_append_right (show usL.length ≤ i.val by omega)]
        simp only [show i.val - usL.length = 0 by omega, List.getElem_cons_zero]
      rw [h1, h2]
      exact hptw
    · have hival := i.isLt
      obtain ⟨j, hj⟩ : ∃ j, i.val = lL.length + 1 + j := ⟨i.val - lL.length - 1, by omega⟩
      have hjR : j < lR.length := by omega
      have h1 : (lL ++ ptW :: lR)[i.val]'(by
          simp only [List.length_append, List.length_cons]; omega) = lR[j]'hjR := by
        rw [List.getElem_append_right (show lL.length ≤ i.val by omega)]
        simp only [show i.val - lL.length = j + 1 by omega, List.getElem_cons_succ]
      have h2 : (usL ++ w :: usR)[i.val]'(by omega) = usR[j]'(by omega) := by
        rw [List.getElem_append_right (show usL.length ≤ i.val by omega)]
        simp only [show i.val - usL.length = j + 1 by omega, List.getElem_cons_succ]
      rw [h1, h2]
      exact hptR j hjR
  · -- Leading segment `(x, ws 0)`: inside `(x, w)`, so `segL` (index 0 ≤ lL.length).
    intro y hxy hy0
    rw [if_pos (Nat.zero_le lL.length)]
    exact hsegL y hxy (lt_of_lt_of_le hy0 (hle_w 0 (Nat.zero_le _) (by omega)))
  · -- Interior segments: left of the `w` slot inside `(x, w)` → `segL`; right → `segR`.
    intro i y h1 h2
    by_cases hile : i.val + 1 ≤ lL.length
    · rw [if_pos hile]
      refine hsegL y ?_ ?_
      · exact ((hrange_all _ (List.getElem_mem _)).1).trans h1
      · exact lt_of_lt_of_le h2 (hle_w (i.val + 1) hile (by have := i.isLt; omega))
    · rw [if_neg hile]
      refine hsegR y ?_ ?_
      · exact lt_of_le_of_lt (hge_w i.val (by omega) (by have := i.isLt; omega)) h1
      · exact h2.trans (hrange_all _ (List.getElem_mem _)).2
  · -- Trailing segment `(ws last, t)`: inside `(w, t)`, so `segR` (index lL+lR+1 > lL).
    intro y hy1 hy2
    rw [if_neg (show ¬(lL.length + lR.length + 1 ≤ lL.length) by omega)]
    refine hsegR y ?_ hy2
    exact lt_of_le_of_lt (hge_w (lL.length + lR.length) (by omega) (by omega)) hy1

/-- **Completeness direction (RHS→LHS) of the k=1 V-carrier** (task 311 Phase 5). A bracket
    witness `w` realizing the depth-1 arity-3 evaluation yields the `VVecEA2.holds` of
    `bracketEndChar_k1v` at the FIXED endpoints `(x, t)`.

    Only the two POSITIVE bracket-zone order bits (`x < w` via `h_xy`, `w < t` via `h_yt`)
    are consumed: the remaining four k0-mirror bits are forced by the witness's atom layer
    and are not needed (the assembled `bracketEndChar_k1v_correct` still carries all six,
    mirroring `bracketEndChar_k0_correct` :1581-1594).

    Chain (rules N1/N2 splits; no simp/omega/aesop shortcut of a documented step — G5):
    1. Split the depth-1 evaluation into atom + quant layers (the same defeq split
       `nf_eval_nf1_iff_efold` uses at NfEFold:497-501) and route the quant layer through
       **`nf_quant_layer_fold_k1_gate`** (NfEFold:525) `.mp`: per **N2**, the **Def 4.1 p.6
       note** licenses the innermost-fold reading and **Prop 4.3 (p.6)** only the "residual
       is ∨∃∀ over E[Σ] atoms" reading (realized locally via the fold — 305 report 14). This
       yields the per-(zone, χ) fold biconditionals and gate conjunct (i); no arity-4 object
       and no navigated arity-3 characteristic arises.
    2. Gate conjunct (ii): a positive fold bit on a zone inconsistent with `x < w < t` would
       yield a realizing point, contradicting `k1v_zone_consistent` (Def 3.1: disjunctions
       range only over consistent order types).
    3. Endpoint/witness literals: the arity-1 projections of the atom layer supply the head
       complete types; each (zone, χ) literal in `epL`/`ptW`/`epR` follows from its fold
       biconditional — positive bits from the realizing point of the matching zone, negative
       bits by contraposition (the realizing point would force the bit true). Exterior zones
       use the Since/Until literals at the FIXED endpoints (Prop 3.5 p.5 folding mechanism —
       N4-valid there: the anchor IS the fixed endpoint).
    4. Interior-positive `(zXW/zWT, χ)` bits: each yields a realizing point strictly inside
       `(x, w)` / `(w, t)`; `k1v_sorted_realization` (Risk R1' insertion induction) arranges
       them in model order, selecting the matching arrangement disjunct of the `VVecEA2`
       disjunction (rule N5 — ALL arrangements are present). Each realized point occupies a
       bracket WITNESS slot between the fixed endpoints (§5 bracket p.7; the witness joins
       the existential prefix, Lemma 3.4 p.5) — assembled by `k1v_bracket_construct`.
    5. Segment exclusions: EVERY point of `(x, w)` (resp. `(w, t)`) satisfies `segL` (resp.
       `segR`) — the handoff RHS→LHS insight: a `(char χ).neg` conjunct has a false fold bit,
       and a point realizing χ inside the interior zone would force it true. -/
private theorem bracketEndChar_k1v_complete {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (qnf : NormalForm sig 1 3)
    (h_xy : qnf.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    (h_yt : qnf.1 (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (M : OrderedMonadicStructure sig) (x t : M.carrier)
    (h : ∃ w : M.carrier, nf_eval_nf M 1 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    (bracketEndChar_k1v atomMap h_surj qnf).holds M atomMap x t := by
  obtain ⟨w, hw⟩ := h
  -- Chain step 1: split the depth-1 evaluation into atom + quant layers (defeq split,
  -- NfEFold:497-501; N2 citation: Def 4.1 p.6 note for the innermost-fold reading).
  have hwhole : nf_eval_nf M 1 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf ↔
      (nf_eval_nf M 0 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf.1 ∧
        (∀ sub : NormalForm sig 0 4,
          (∃ x1 : M.carrier, nf_eval_nf M 0 4
            (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) sub) ↔
            qnf.2 sub = true)) := Iff.rfl
  rw [hwhole] at hw
  obtain ⟨h_atom, h_quant⟩ := hw
  -- Gate corollary `.mp` (NfEFold:525): fold biconditionals + off-fiber falsity.
  rw [nf_quant_layer_fold_k1_gate M w x t qnf h_atom] at h_quant
  obtain ⟨hzone, hoff⟩ := h_quant
  -- rfl-bridge to the fold-bit form, taken while `zs` is still a variable.
  have hzone' : ∀ (zs : ZoneSpec 3) (χ : NormalForm sig 0 1),
      (∃ u : M.carrier,
        zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t))) zs u ∧
        nf_eval_nf M 0 1 (fun _ => u) χ) ↔
      (efold_of_nf1 qnf).2 (zs, χ) = true := by
    intro zs χ
    rw [show (efold_of_nf1 qnf).2 (zs, χ) = qnf.2 (nf0_assemble zs χ qnf.1) from rfl]
    exact hzone zs χ
  -- Bracket order facts from the atom layer + the two positive order bits.
  have hxw : x < w := by
    have h1 := h_atom (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide))
    simp only [atom_eval, Fin.cons] at h1
    exact h1.mpr h_xy
  have hwt : w < t := by
    have h1 := h_atom (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide))
    simp only [atom_eval, Fin.cons] at h1
    exact h1.mpr h_yt
  have hxt : x < t := hxw.trans hwt
  -- Complete-type correctness bridge (char χ at u ↔ arity-1 depth-0 evaluation).
  have hchar : ∀ (χ' : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (nf_depth0_char_formula atomMap h_surj χ') ↔
      nf_eval_nf M 0 1 (fun _ => u) χ' :=
    fun χ' u => nfPred_correct M atomMap h_surj χ' u
  -- Endpoint/witness arity-1 point evaluations (chain step 3 heads; VecEADecomp clones).
  have h_y_nf := k1v_extract_y_nf M qnf.1 w x t h_atom
  have h_x_nf := k1v_extract_x_nf3 M qnf.1 w x t h_atom
  have h_t_nf := k1v_extract_t_nf3 M qnf.1 w x t h_atom
  -- Zone-membership constructors at the seven consistent zones (Def 3.1 ordering channel).
  have hzPastX : ∀ u, u < x → zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier)
      (Fin.cons (true, false) (Fin.cons (true, false) (fun _ => (true, false))) : ZoneSpec 3) u := by
    intro u hux
    have huw : u < w := hux.trans hxw
    have hut : u < t := huw.trans hwt
    rw [k1v_zoneHolds_cons_iff]
    exact ⟨⟨iff_of_true huw rfl, iff_of_false (lt_asymm huw) (by simp)⟩,
      ⟨iff_of_true hux rfl, iff_of_false (lt_asymm hux) (by simp)⟩,
      ⟨iff_of_true hut rfl, iff_of_false (lt_asymm hut) (by simp)⟩⟩
  have hzAtX : zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier)
      (Fin.cons (true, false) (Fin.cons (false, false) (fun _ => (true, false))) : ZoneSpec 3) x := by
    rw [k1v_zoneHolds_cons_iff]
    exact ⟨⟨iff_of_true hxw rfl, iff_of_false (lt_asymm hxw) (by simp)⟩,
      ⟨iff_of_false (lt_irrefl x) (by simp), iff_of_false (lt_irrefl x) (by simp)⟩,
      ⟨iff_of_true hxt rfl, iff_of_false (lt_asymm hxt) (by simp)⟩⟩
  have hzXW : ∀ u, x < u → u < w → zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier)
      (Fin.cons (true, false) (Fin.cons (false, true) (fun _ => (true, false))) : ZoneSpec 3) u := by
    intro u hxu huw
    have hut : u < t := huw.trans hwt
    rw [k1v_zoneHolds_cons_iff]
    exact ⟨⟨iff_of_true huw rfl, iff_of_false (lt_asymm huw) (by simp)⟩,
      ⟨iff_of_false (lt_asymm hxu) (by simp), iff_of_true hxu rfl⟩,
      ⟨iff_of_true hut rfl, iff_of_false (lt_asymm hut) (by simp)⟩⟩
  have hzAtW : zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier)
      (Fin.cons (false, false) (Fin.cons (false, true) (fun _ => (true, false))) : ZoneSpec 3) w := by
    rw [k1v_zoneHolds_cons_iff]
    exact ⟨⟨iff_of_false (lt_irrefl w) (by simp), iff_of_false (lt_irrefl w) (by simp)⟩,
      ⟨iff_of_false (lt_asymm hxw) (by simp), iff_of_true hxw rfl⟩,
      ⟨iff_of_true hwt rfl, iff_of_false (lt_asymm hwt) (by simp)⟩⟩
  have hzWT : ∀ u, w < u → u < t → zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier)
      (Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (true, false))) : ZoneSpec 3) u := by
    intro u hwu hut
    have hxu : x < u := hxw.trans hwu
    rw [k1v_zoneHolds_cons_iff]
    exact ⟨⟨iff_of_false (lt_asymm hwu) (by simp), iff_of_true hwu rfl⟩,
      ⟨iff_of_false (lt_asymm hxu) (by simp), iff_of_true hxu rfl⟩,
      ⟨iff_of_true hut rfl, iff_of_false (lt_asymm hut) (by simp)⟩⟩
  have hzAtT : zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier)
      (Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (false, false))) : ZoneSpec 3) t := by
    rw [k1v_zoneHolds_cons_iff]
    exact ⟨⟨iff_of_false (lt_asymm hwt) (by simp), iff_of_true hwt rfl⟩,
      ⟨iff_of_false (lt_asymm hxt) (by simp), iff_of_true hxt rfl⟩,
      ⟨iff_of_false (lt_irrefl t) (by simp), iff_of_false (lt_irrefl t) (by simp)⟩⟩
  have hzFutT : ∀ u, t < u → zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier)
      (Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (false, true))) : ZoneSpec 3) u := by
    intro u htu
    have hwu : w < u := hwt.trans htu
    have hxu : x < u := hxw.trans hwu
    rw [k1v_zoneHolds_cons_iff]
    exact ⟨⟨iff_of_false (lt_asymm hwu) (by simp), iff_of_true hwu rfl⟩,
      ⟨iff_of_false (lt_asymm hxu) (by simp), iff_of_true hxu rfl⟩,
      ⟨iff_of_false (lt_asymm htu) (by simp), iff_of_true htu rfl⟩⟩
  -- The gate Prop (chain step 2): conjunct (i) is the off-fiber clause from the corollary;
  -- conjunct (ii) is order-conflict falsity via the `k1v_zone_consistent` contrapositive.
  have hgate : (∀ sub : NormalForm sig 0 4, nf0_dropFresh sub ≠ qnf.1 → qnf.2 sub = false) ∧
      (∀ (zs : ZoneSpec 3) (χ : NormalForm sig 0 1),
        ¬(zs = Fin.cons (true, false) (Fin.cons (true, false) (fun _ => (true, false))) ∨
          zs = Fin.cons (true, false) (Fin.cons (false, false) (fun _ => (true, false))) ∨
          zs = Fin.cons (true, false) (Fin.cons (false, true) (fun _ => (true, false))) ∨
          zs = Fin.cons (false, false) (Fin.cons (false, true) (fun _ => (true, false))) ∨
          zs = Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (true, false))) ∨
          zs = Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (false, false))) ∨
          zs = Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (false, true)))) →
        (efold_of_nf1 qnf).2 (zs, χ) = false) := by
    refine ⟨hoff, fun zs χ hncons => ?_⟩
    cases hb : (efold_of_nf1 qnf).2 (zs, χ) with
    | false => rfl
    | true =>
      obtain ⟨u, hzu, -⟩ := (hzone' zs χ).mpr hb
      exact absurd (k1v_zone_consistent M w x t u hxw hwt zs hzu) hncons
  -- Interior-positive realization (chain step 4): each positive interior fold bit yields a
  -- realizing point strictly inside its zone.
  have hLreal : ∀ χ : NormalForm sig 0 1,
      (efold_of_nf1 qnf).2
        (Fin.cons (true, false) (Fin.cons (false, true) (fun _ => (true, false))), χ) = true →
      ∃ u, x < u ∧ u < w ∧ nf_eval_nf M 0 1 (fun _ => u) χ := by
    intro χ hbit
    obtain ⟨u, hzu, hev⟩ := (hzone' _ χ).mpr hbit
    rw [k1v_zoneHolds_cons_iff] at hzu
    exact ⟨u, hzu.2.1.2.mpr rfl, hzu.1.1.mpr rfl, hev⟩
  have hRreal : ∀ χ : NormalForm sig 0 1,
      (efold_of_nf1 qnf).2
        (Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (true, false))), χ) = true →
      ∃ u, w < u ∧ u < t ∧ nf_eval_nf M 0 1 (fun _ => u) χ := by
    intro χ hbit
    obtain ⟨u, hzu, hev⟩ := (hzone' _ χ).mpr hbit
    rw [k1v_zoneHolds_cons_iff] at hzu
    exact ⟨u, hzu.1.2.mpr rfl, hzu.2.2.1.mpr rfl, hev⟩
  -- Segment exclusions on ALL of `(x, w)` / `(w, t)` (chain step 5, handoff insight).
  have hsegL_all : ∀ u, x < u → u < w →
      TemporalPred.eval_at M atomMap
        ⟨formula_conjList ((Finset.univ.toList).map fun χ =>
          if (efold_of_nf1 qnf).2
              (Fin.cons (true, false) (Fin.cons (false, true) (fun _ => (true, false))),
                χ) = true
          then Formula.top
          else (nf_depth0_char_formula atomMap h_surj χ).neg)⟩ u := by
    intro u hxu huw
    simp only [TemporalPred.eval_at]
    rw [formula_conjList_iff]
    intro f hf
    obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
    cases hb : (efold_of_nf1 qnf).2
        (Fin.cons (true, false) (Fin.cons (false, true) (fun _ => (true, false))), χ) with
    | true =>
      rw [if_pos rfl]
      exact fun hfa => hfa
    | false =>
      rw [if_neg (by simp [hb])]
      intro hch
      have hbit := (hzone' _ χ).mp ⟨u, hzXW u hxu huw, (hchar χ u).mp hch⟩
      rw [hb] at hbit
      exact Bool.noConfusion hbit
  have hsegR_all : ∀ u, w < u → u < t →
      TemporalPred.eval_at M atomMap
        ⟨formula_conjList ((Finset.univ.toList).map fun χ =>
          if (efold_of_nf1 qnf).2
              (Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (true, false))),
                χ) = true
          then Formula.top
          else (nf_depth0_char_formula atomMap h_surj χ).neg)⟩ u := by
    intro u hwu hut
    simp only [TemporalPred.eval_at]
    rw [formula_conjList_iff]
    intro f hf
    obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
    cases hb : (efold_of_nf1 qnf).2
        (Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (true, false))), χ) with
    | true =>
      rw [if_pos rfl]
      exact fun hfa => hfa
    | false =>
      rw [if_neg (by simp [hb])]
      intro hch
      have hbit := (hzone' _ χ).mp ⟨u, hzWT u hwu hut, (hchar χ u).mp hch⟩
      rw [hb] at hbit
      exact Bool.noConfusion hbit
  -- Endpoint predicate at the FIXED left endpoint `x` (chain step 3; exterior Since literal
  -- per Prop 3.5 p.5 folding mechanism — N4-valid: the anchor IS the fixed endpoint).
  have hepL : TemporalPred.eval_at M atomMap
      ⟨formula_conjList
        ((nf_depth0_char_formula atomMap h_surj (nf_x_proj3 qnf.1)
          :: (Finset.univ.toList).map fun χ =>
              if (efold_of_nf1 qnf).2
                  (Fin.cons (true, false) (Fin.cons (true, false) (fun _ => (true, false))),
                    χ) = true
              then Formula.snce (nf_depth0_char_formula atomMap h_surj χ) Formula.top
              else (Formula.snce (nf_depth0_char_formula atomMap h_surj χ) Formula.top).neg)
          ++ (Finset.univ.toList).map fun χ =>
              if (efold_of_nf1 qnf).2
                  (Fin.cons (true, false) (Fin.cons (false, false) (fun _ => (true, false))),
                    χ) = true
              then nf_depth0_char_formula atomMap h_surj χ
              else (nf_depth0_char_formula atomMap h_surj χ).neg)⟩ x := by
    simp only [TemporalPred.eval_at]
    rw [formula_conjList_iff]
    intro f hf
    rcases List.mem_append.mp hf with hf | hf
    · rcases List.mem_cons.mp hf with rfl | hf
      · exact (hchar _ x).mpr h_x_nf
      · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
        cases hb : (efold_of_nf1 qnf).2
            (Fin.cons (true, false) (Fin.cons (true, false) (fun _ => (true, false))), χ) with
        | true =>
          rw [if_pos rfl]
          obtain ⟨u, hzu, hev⟩ := (hzone' _ χ).mpr hb
          rw [k1v_zoneHolds_cons_iff] at hzu
          exact ⟨u, hzu.2.1.1.mpr rfl, (hchar χ u).mpr hev, fun r _ _ hfa => hfa⟩
        | false =>
          rw [if_neg (by simp [hb])]
          rintro ⟨s, hsx, hsχ, -⟩
          have hbit := (hzone' _ χ).mp ⟨s, hzPastX s hsx, (hchar χ s).mp hsχ⟩
          rw [hb] at hbit
          exact Bool.noConfusion hbit
    · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
      cases hb : (efold_of_nf1 qnf).2
          (Fin.cons (true, false) (Fin.cons (false, false) (fun _ => (true, false))), χ) with
      | true =>
        rw [if_pos rfl]
        obtain ⟨u, hzu, hev⟩ := (hzone' _ χ).mpr hb
        rw [k1v_zoneHolds_cons_iff] at hzu
        have hueq : u = x := le_antisymm
          (not_lt.mp (k1v_not_of_iff_false hzu.2.1.2))
          (not_lt.mp (k1v_not_of_iff_false hzu.2.1.1))
        exact (hchar χ x).mpr (hueq ▸ hev)
      | false =>
        rw [if_neg (by simp [hb])]
        intro hch
        have hbit := (hzone' _ χ).mp ⟨x, hzAtX, (hchar χ x).mp hch⟩
        rw [hb] at hbit
        exact Bool.noConfusion hbit
  -- Endpoint predicate at the FIXED right endpoint `t` (chain step 3; exterior Until
  -- literal per Prop 3.5 p.5 — N4-valid: the anchor IS the fixed endpoint).
  have hepR : TemporalPred.eval_at M atomMap
      ⟨formula_conjList
        ((nf_depth0_char_formula atomMap h_surj (nf_t_proj3 qnf.1)
          :: (Finset.univ.toList).map fun χ =>
              if (efold_of_nf1 qnf).2
                  (Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (false, false))),
                    χ) = true
              then nf_depth0_char_formula atomMap h_surj χ
              else (nf_depth0_char_formula atomMap h_surj χ).neg)
          ++ (Finset.univ.toList).map fun χ =>
              if (efold_of_nf1 qnf).2
                  (Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (false, true))),
                    χ) = true
              then Formula.untl (nf_depth0_char_formula atomMap h_surj χ) Formula.top
              else (Formula.untl (nf_depth0_char_formula atomMap h_surj χ)
                Formula.top).neg)⟩ t := by
    simp only [TemporalPred.eval_at]
    rw [formula_conjList_iff]
    intro f hf
    rcases List.mem_append.mp hf with hf | hf
    · rcases List.mem_cons.mp hf with rfl | hf
      · exact (hchar _ t).mpr h_t_nf
      · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
        cases hb : (efold_of_nf1 qnf).2
            (Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (false, false))), χ) with
        | true =>
          rw [if_pos rfl]
          obtain ⟨u, hzu, hev⟩ := (hzone' _ χ).mpr hb
          rw [k1v_zoneHolds_cons_iff] at hzu
          have hueq : u = t := le_antisymm
            (not_lt.mp (k1v_not_of_iff_false hzu.2.2.2))
            (not_lt.mp (k1v_not_of_iff_false hzu.2.2.1))
          exact (hchar χ t).mpr (hueq ▸ hev)
        | false =>
          rw [if_neg (by simp [hb])]
          intro hch
          have hbit := (hzone' _ χ).mp ⟨t, hzAtT, (hchar χ t).mp hch⟩
          rw [hb] at hbit
          exact Bool.noConfusion hbit
    · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
      cases hb : (efold_of_nf1 qnf).2
          (Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (false, true))), χ) with
      | true =>
        rw [if_pos rfl]
        obtain ⟨u, hzu, hev⟩ := (hzone' _ χ).mpr hb
        rw [k1v_zoneHolds_cons_iff] at hzu
        exact ⟨u, hzu.2.2.2.mpr rfl, (hchar χ u).mpr hev, fun r _ _ hfa => hfa⟩
      | false =>
        rw [if_neg (by simp [hb])]
        rintro ⟨s, hts, hsχ, -⟩
        have hbit := (hzone' _ χ).mp ⟨s, hzFutT s hts, (hchar χ s).mp hsχ⟩
        rw [hb] at hbit
        exact Bool.noConfusion hbit
  -- Witness point type at `w` (complete type + equality-zone literals ONLY, rule N4).
  have hptW : TemporalPred.eval_at M atomMap
      ⟨formula_conjList
        (nf_depth0_char_formula atomMap h_surj (nf_y_proj qnf.1)
          :: (Finset.univ.toList).map fun χ =>
              if (efold_of_nf1 qnf).2
                  (Fin.cons (false, false) (Fin.cons (false, true) (fun _ => (true, false))),
                    χ) = true
              then nf_depth0_char_formula atomMap h_surj χ
              else (nf_depth0_char_formula atomMap h_surj χ).neg)⟩ w := by
    simp only [TemporalPred.eval_at]
    rw [formula_conjList_iff]
    intro f hf
    rcases List.mem_cons.mp hf with rfl | hf
    · exact (hchar _ w).mpr h_y_nf
    · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
      cases hb : (efold_of_nf1 qnf).2
          (Fin.cons (false, false) (Fin.cons (false, true) (fun _ => (true, false))), χ) with
      | true =>
        rw [if_pos rfl]
        obtain ⟨u, hzu, hev⟩ := (hzone' _ χ).mpr hb
        rw [k1v_zoneHolds_cons_iff] at hzu
        have hueq : u = w := le_antisymm
          (not_lt.mp (k1v_not_of_iff_false hzu.1.2))
          (not_lt.mp (k1v_not_of_iff_false hzu.1.1))
        exact (hchar χ w).mpr (hueq ▸ hev)
      | false =>
        rw [if_neg (by simp [hb])]
        intro hch
        have hbit := (hzone' _ χ).mp ⟨w, hzAtW, (hchar χ w).mp hch⟩
        rw [hb] at hbit
        exact Bool.noConfusion hbit
  -- Chain step 4: sorted arrangements of the interior-positive enumerations (R1').
  obtain ⟨psL, hpermL, hsortL, hpropsL⟩ :=
    k1v_sorted_realization M x w
      ((Finset.univ.toList).filter fun χ =>
        (efold_of_nf1 qnf).2
          (Fin.cons (true, false) (Fin.cons (false, true) (fun _ => (true, false))), χ))
      ((Finset.nodup_toList _).filter _)
      (fun χ hχ => hLreal χ (List.mem_filter.mp hχ).2)
  obtain ⟨psR, hpermR, hsortR, hpropsR⟩ :=
    k1v_sorted_realization M w t
      ((Finset.univ.toList).filter fun χ =>
        (efold_of_nf1 qnf).2
          (Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (true, false))), χ))
      ((Finset.nodup_toList _).filter _)
      (fun χ hχ => hRreal χ (List.mem_filter.mp hχ).2)
  -- Combined witness list is sorted: left points < w < right points.
  have hsortFull : (psL.map Prod.snd ++ w :: psR.map Prod.snd).Pairwise (· < ·) := by
    rw [List.pairwise_append]
    refine ⟨hsortL, ?_, ?_⟩
    · rw [List.pairwise_cons]
      refine ⟨?_, hsortR⟩
      intro b hb
      obtain ⟨p, hp, rfl⟩ := List.mem_map.mp hb
      exact (hpropsR p hp).1.1
    · intro a ha b hb
      obtain ⟨p, hp, rfl⟩ := List.mem_map.mp ha
      have haw : p.2 < w := (hpropsL p hp).1.2
      rcases List.mem_cons.mp hb with rfl | hb
      · exact haw
      · obtain ⟨q, hq, rfl⟩ := List.mem_map.mp hb
        exact haw.trans (hpropsR q hq).1.1
  -- Enter the carrier: gate branch, then the (psL, psR) arrangement disjunct (rule N5).
  simp only [bracketEndChar_k1v, VVecEA2.holds]
  split
  case isFalse hg => exact absurd hgate hg
  case isTrue hg =>
  refine ⟨_, List.mem_flatMap.mpr ⟨psL.map Prod.fst, List.mem_permutations.mpr hpermL,
    List.mem_map.mpr ⟨psR.map Prod.fst, List.mem_permutations.mpr hpermR, rfl⟩⟩, ?_⟩
  refine ⟨hepL, hepR, ?_⟩
  -- The bracket: assembled by the construction lemma from the sorted realizations.
  refine k1v_bracket_construct M atomMap _ _ _ _ _ x w t hxw hwt
    (psL.map Prod.snd) (psR.map Prod.snd) (by simp) (by simp) hsortFull
    ?_ ?_ hptW ?_ ?_ hsegL_all hsegR_all
  · intro u hu
    obtain ⟨p, hp, rfl⟩ := List.mem_map.mp hu
    exact (hpropsL p hp).1
  · intro u hu
    obtain ⟨p, hp, rfl⟩ := List.mem_map.mp hu
    exact (hpropsR p hp).1
  · intro i hi
    have hi' : i < psL.length := by simpa using hi
    have h1 : (List.map (fun χ => (⟨nf_depth0_char_formula atomMap h_surj χ⟩ : TemporalPred))
        (psL.map Prod.fst))[i]'hi =
        ⟨nf_depth0_char_formula atomMap h_surj ((psL[i]'hi').1)⟩ := by
      simp only [List.getElem_map]
    have h2 : (psL.map Prod.snd)[i]'(by simpa using hi') = (psL[i]'hi').2 := by
      simp only [List.getElem_map]
    rw [h1, h2]
    exact (hchar _ _).mpr (hpropsL _ (List.getElem_mem _)).2
  · intro i hi
    have hi' : i < psR.length := by simpa using hi
    have h1 : (List.map (fun χ => (⟨nf_depth0_char_formula atomMap h_surj χ⟩ : TemporalPred))
        (psR.map Prod.fst))[i]'hi =
        ⟨nf_depth0_char_formula atomMap h_surj ((psR[i]'hi').1)⟩ := by
      simp only [List.getElem_map]
    have h2 : (psR.map Prod.snd)[i]'(by simpa using hi') = (psR[i]'hi').2 := by
      simp only [List.getElem_map]
    rw [h1, h2]
    exact (hchar _ _).mpr (hpropsR _ (List.getElem_mem _)).2

/-- **k=1 fixed-endpoint correctness for the witness-growing V-carrier** (task 311 Phase 5 —
the k=1 instance of `BracketCarrierCorrectV` in k0-mirror conditional form, exactly
`bracketEndChar_k0_correct` :1581-1594 at depth 1). Under the six bracket-zone order
hypotheses on `qnf.1`, the `VVecEA2.holds` of `bracketEndChar_k1v` at the FIXED endpoints
`(x, t)` is equivalent to the existence of a bracket witness `w` realizing the depth-1
arity-3 evaluation. Sorry-free assembly of `bracketEndChar_k1v_sound` (LHS→RHS) and
`bracketEndChar_k1v_complete` (RHS→LHS). Citations (rule N1 split): the two-fixed-endpoint
`(z_0, z_1)` framing is **Lemma 3.2(2) (PDF p.4) + the §5 bracket notation
`[α_0, …, α_n](z_0, z_1)` (PDF p.7)**; witness growth per disjunct is the printed §5 bracket
shape (p.7) with **Lemma 3.4 (PDF p.5)** as the ∃-closure license; **Prop 3.5 (PDF p.5)** is
cited ONLY for the ∃-witness→Until/Since folding mechanism in the `epL`/`epR` exterior-zone
literals; the fold channel is **Def 4.1 (PDF p.5, iterated per the p.6 note)**. -/
theorem bracketEndChar_k1v_correct {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (qnf : NormalForm sig 1 3)
    (h_xy : qnf.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    (h_yt : qnf.1 (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_xt : qnf.1 (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_yx : qnf.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (h_ty : qnf.1 (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
    (h_tx : qnf.1 (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (M : OrderedMonadicStructure sig) (x t : M.carrier) :
    (bracketEndChar_k1v atomMap h_surj qnf).holds M atomMap x t ↔
      ∃ w : M.carrier, nf_eval_nf M 1 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf :=
  ⟨bracketEndChar_k1v_sound atomMap h_surj qnf h_xy h_yt h_xt h_yx h_ty h_tx M x t,
   bracketEndChar_k1v_complete atomMap h_surj qnf h_xy h_yt M x t⟩

/-! ## Task 311 Phase 5: k=1 gate re-probe under the E[Σ]-fold at the V-carrier —
DECISION GATE → **R2 = GO** (verdict-mirror of the Phase 10 / Phase 2 records above)

**Lead evidence (Def 3.1, PDF p.4 — rule N3).** Rabinovich's α_j/β_j are ONE-variable
quantifier-free formulas: no joint multi-point atom exists, so the arity-4 residual
`[x_1, w, x, t]` that NO-GOed the original probe (Phase 10 record, :1596-1628) has no
Rabinovich counterpart — it was a Lean `nf_eval_nf` arity-growth artifact, and the E[Σ]-fold
RESTORES Def-4.1 fidelity (PDF p.5, iterated per the p.6 note). This re-probe CONFIRMS it
end-to-end: `bracketEndChar_k1v_correct` above is the k=1 instance of
`BracketCarrierCorrectV` in k0-mirror conditional form, proved **sorry-free** with the fold
as the ONLY channel through which `qnf.2` is read. **No arity-4 object, no navigated arity-3
characteristic, and no third free anchor arises at any step** — both directions route the
quant layer through `nf_quant_layer_fold_k1_gate` (NfEFold:525; task 310's gate corollary),
whose per-(zone, χ) obligations are zone-bounded MONADIC existentials.

**The G6 amendment carried the day (the Phase-3 record above, :1829-1850).** The v2 Phase 2
re-probe (:1754-1827) refuted the FIXED codomain `VecEA2 1`: a one-witness bracket cannot
host the interior-positive `(zone, χ)` witnesses (counterexample :1786-1800). The amended
codomain — witness-growing `VecEA2 n` disjuncts assembled as `VVecEA2`, anchors capped at the
FIXED `{x, t}` — is Rabinovich's own printed shape: **Lemma 3.2(2) (p.4)** caps ANCHORS at
≤2 (a TYPE-level invariant of `VVecEA2.holds`, VecEAFormula:276), the **§5 bracket
`[α_0, …, α_n](z_0, z_1)` (p.7)** carries `n` witnesses between the two fixed endpoints, and
**Lemma 3.4 (p.5)** licenses each absorbed existential to JOIN the existential prefix as a
witness. Interior-positive content rides bracket WITNESS slots (rule N4 — the refuted
type-anchored `bracketBuildLeft/Right` interior chains stayed dead; they survive only in the
`epL`/`epR` exterior-zone literals, where the anchor genuinely IS the fixed endpoint), and
the model-dependent witness order rides the finite disjunction over ALL arrangements
(rule N5), selected in the completeness direction by the `k1v_sorted_realization` insertion
induction.

**Verdict: R2 = GO.** The k=1 bracket gate is CLOSED at the V-carrier: the fold encoding
(task 310) composes with the witness-growing codomain (this task) to characterize
`∃ w, nf_eval_nf M 1 3 [w, x, t] qnf` by a two-anchor `VVecEA2` at `(x, t)` under the
bracket-zone order hypotheses. Path B is UN-FALSIFIED at k=1 under the amended carrier.
`bracketEndChar_k1v` / `bracketEndChar_k1v_correct` stay OFF the live path until wired
(nothing imports them); the live Kamp sorry baseline (2: KampPrior:351/354) is untouched.
Downstream: task 309 resumes via `/revise 309` (plan v4) — the depth-`k` lift (R3) can now
target `BracketCarrierCorrectV` with this k=1 instance as the recursion template over the
k=0 base `bracketEndChar_k0_correct` (:1581-1594). -/

/-! ## Task 309 Phase 12 (R3a): depth-`k` V-carrier definition `bracketEndChar_kv`

Definitional + typechecking phase (plan v5 Phase 12): generalize the landed k=1 V-carrier
`bracketEndChar_k1v` (:1927) to a depth-`k` carrier `bracketEndChar_kv : BracketEndCharCarrierV
sig k`. Correctness (`bracketEndChar_kv_correct`) is Phase 13 (R3b) and is NOT attempted here.

**Depth-`k` E[Σ]-atom char provider is a PARAMETER (`charF`).** The concrete depth-`k`
characteristic-formula provider (`char_k1`, KampPrior:307 / `nf_characterizable_temporal_prior`,
KampPrior:397) lives in `KampPrior.lean`, which IMPORTS this file (KampPrior.lean:4) — consuming
it here by name would re-create the import cycle removed by task 307 Phase 7 (see the import
note at :13-16). Following the `nf_succ_char_formula`/`exist_tl_fn` parameterization pattern
(KampPrior:67), the carrier takes the provider family `charF : (j : Nat) → NormalForm sig j 1 →
Formula`; Phase 14 (R4) instantiates it at the KampPrior call site with the local `char_k1` /
`nf_characterizable_temporal_prior`, and Phase 13 states correctness under the corresponding
`temporal_truth … (charF j χ) ↔ nf_eval_nf M j 1 (fun _ => t) χ` hypothesis.

**Fold-bit read at depth `k` (the general fold engine's on-fiber content).** At depth 1 the
carrier reads its fold bits via `efold_of_nf1` (NfEFold:472): `b zs χ = qnf.2 (nf0_assemble zs
χ qnf.1)` — a POINTWISE read, licensed by the depth-0 split kit's bijection (`nf0_split_assemble`,
NfEFold:235). At depth `k ≥ 1` no such pointwise assemble exists (the deeper joint quant layers
of an arity-4 sub are not determined by `(zs, χ, qnf.1)` — deviation D7, NfEFold:373). The
depth-`k` fold bit is therefore read FIBER-EXISTENTIALLY:

  `b zs χ = decide (∃ sub, qnf.2 sub = true ∧ zoneSpec sub = zs ∧ projFresh_k sub = χ)`

i.e. "some realized-marked sub carries ordering channel `zs` and depth-`k` monadic point type
`χ`" — exactly the E[Σ]-atom content of Def 4.1 (PDF p.5, read at depth `k` per the **Def 4.1
p.6 note** on iterated folds; rule N2: Prop 4.3 (p.6) is cited only for "the residual is ∨∃∀
over E[Σ] atoms", realized locally via the fold). Under the gate's off-fiber-falsity conjunct
this AGREES with the `efold_of_nf1` pointwise read at `k = 1` (`nf0_split_assemble` round-trip;
the documented bridge lemma `bracketEndChar_kv_one_eq` below), so the k=1 specialization is
propositionally EQUAL to `bracketEndChar_k1v` and Phase 13's step can reuse the k1v proof. -/

/-- Reindex an atom along the prefix inclusion `Fin.castLE : Fin m → Fin n` (`m ≤ n`).
    Injectivity of `Fin.castLE` carries the `order` atom's `i ≠ j` witness. Pure bookkeeping
    for the depth-`k` prefix restriction `nfk_take` below. -/
private def atomKind_castLE {sig : MonadicSignature} {m n : Nat} (h : m ≤ n) :
    AtomKind sig m → AtomKind sig n
  | .pred p i => .pred p (Fin.castLE h i)
  | .order i j hne =>
      .order (Fin.castLE h i) (Fin.castLE h j)
        (fun he => hne (Fin.castLE_injective h he))

/-- **Depth-`k` prefix restriction** (task 309 Phase 12): restrict a depth-`k` arity-`n` NF to
    its first `m` variables. Atom layer: precompose with `atomKind_castLE` (the depth-0
    restriction). Quant layer: a depth-`(k-1)` arity-`(m+1)` sub is marked realized iff SOME
    realized-marked arity-`(n+1)` sub restricts to it — fresh witnesses always PREPEND
    (`Fin.cons x env`), so the variables of interest stay a prefix at every layer and the
    recursion is uniform in `k`. This is the projection direction of Rabinovich's monadic
    E[Σ]-atom extraction (Def 4.1, PDF p.5): the complete depth-`k` type of a variable prefix,
    read off the complete type of the whole tuple. Decidability of the existential is via the
    `Fintype`/`DecidableEq` instances on `NormalForm` (NormalForm.lean:177/181). -/
noncomputable def nfk_take {sig : MonadicSignature} :
    {k : Nat} → {m n : Nat} → m ≤ n → NormalForm sig k n → NormalForm sig k m
  | 0, _, _, h, nf => fun a => nf (atomKind_castLE h a)
  | _ + 1, _, _, h, nf =>
      ⟨fun a => nf.1 (atomKind_castLE h a),
       fun χ' => decide (∃ sub', nf.2 sub' = true ∧
         nfk_take (Nat.succ_le_succ h) sub' = χ')⟩

/-- **Depth-`k` monadic point type of the fresh variable** (index `0`, matching `Fin.cons x
    env`): the depth-`k` generalization of `nf0_projFresh` (NfEFold:162) via the prefix
    restriction to the single variable `0`. This is the E[Σ]-atom channel of Def 4.1 (PDF p.5)
    at depth `k`. -/
noncomputable def nfk_projFresh {sig : MonadicSignature} {k n : Nat}
    (sub : NormalForm sig k (n + 1)) : NormalForm sig k 1 :=
  nfk_take (Nat.succ_le_succ (Nat.zero_le n)) sub

/-- At depth 0 the prefix-restriction fresh projection coincides with the split kit's
    `nf0_projFresh` (NfEFold:162). Order atoms at arity 1 are uninhabited (`i ≠ j` with
    `i j : Fin 1`), discharged by `Subsingleton.elim` as in `nf0_projFresh` itself. -/
private theorem nfk_projFresh_zero {sig : MonadicSignature} {n : Nat}
    (sub : NormalForm sig 0 (n + 1)) :
    nfk_projFresh sub = nf0_projFresh sub := by
  funext a
  match a with
  | .pred p i =>
    have hi : i = 0 := Subsingleton.elim i 0
    subst hi
    rfl
  | .order i j h => exact absurd (Subsingleton.elim i j) h

/-! ### Depth-`k` witness-growing two-anchor fold carrier (task 309 Phase 12, R3a; G6 as
amended — see the plan-v3 amendment record at :1829-1850)

Generalizes `bracketEndChar_k1v` (:1927) from depth 1 to depth `k`, mirroring it structurally:
a depth-`k` arity-3 `qnf : NormalForm sig k 3` is encoded as a `VVecEA2` at the two FIXED
endpoints `{x, t}`, with the interior-positive `(zone, χ)` fold bits as bracket WITNESSES
ordered between the fixed endpoints alongside `w` (rule N4: interior-positive content rides
bracket witness slots anchored between the FIXED endpoints, NEVER type-anchored
`bracketBuildLeft`/`bracketBuildRight` chains — the refuted device of :1782-1796; those chains
survive only inside the `epL`/`epR` exterior-zone literals, where the anchor genuinely IS the
fixed endpoint). Citation split (rule N1): the two-fixed-endpoint `(z_0, z_1)` framing is
**Lemma 3.2(2) (PDF p.4) + the §5 bracket notation `[α_0, …, α_n](z_0, z_1)` (PDF p.7)**;
**Prop 3.5 (PDF p.5)** is cited ONLY for the one-free-variable ∃-witness→Until/Since folding
mechanism (the Since/Until literals in `epL`/`epR`). The codomain is the witness-growing
`VVecEA2` (G6 amendment, :1829-1850): anchors stay `{x, t}` (2, FIXED — the `VVecEA2.holds`
two-point signature, VecEAFormula:276, is the TYPE-level ≤2-anchor invariant, G2/G4); witness
count grows per disjunct — NO `VecEA2 1` regression (refuted by the dense-order counterexample
:1782-1796).

- **`k = 0`**: no quant layer exists; the carrier is the singleton-disjunct wrapper of the
  landed depth-0 bracket `bracketEndChar_k0` (:1567) — Phase 13's recursion base
  (`bracketEndChar_k0_correct`, :1581).
- **`k + 1`**: the Phase-1/task-311 building blocks verbatim (seven zone specs, `lit`,
  endpoint preds `epL`/`epR`, segment exclusions `segL`/`segR`, the two-conjunct gate), with
  the depth-0 E[Σ]-atoms replaced by depth-`k` atoms: fold bits `b` read fiber-existentially
  from `qnf.2` (the depth-`k` E[Σ]-fold channel — see the section header above; every read of
  `qnf.2` goes through `b`, no arity-4 evaluation occurs), point/interval types provided by
  `charF k` (the depth-`k` E[Σ]-atom characteristic, Def 4.1 PDF p.5 — the `char_k1` role,
  KampPrior:307, passed as a parameter to avoid the KampPrior import cycle), interior-positive
  enumerations `S_L`/`S_R` over the depth-`k` fold output, and disjuncts via `bracketFromLists`
  (:1883) over `S_L.permutations × S_R.permutations` (rule N5 — the model-dependent witness
  ORDER is carried by the finite disjunction over linear arrangements, Rabinovich's ∨ over
  consistent order types, Def 3.1 pp.4-5 / §5; distinctness of realizing points for distinct
  complete 1-types is `nf_eval_unique`, NormalForm:245; same-type multiplicity is NOT encoded —
  fold bits are existential, one witness per positive pair). Endpoint literals sit at the FIXED
  endpoints (rule N4); the endpoint/witness BASE types (`xType`/`tType`/`nf_y_proj`) are the
  depth-0 characteristics of the atom-layer projections — the only self-type `qnf` carries
  syntactically.
- **Gate-failure branch**: the empty disjunction `⟨[]⟩` (its `holds` is `False`) — Rabinovich's
  empty disjunction over inconsistent order types.

Correctness (`BracketCarrierCorrectV`, k0-mirror conditional form) is Phase 13 (R3b). -/

/-- **Shared successor-case body of the depth-`k` V-carrier** (private builder, factored per
    Risk R6 like `bracketFromLists` :1883). Fully parametric in the two characteristic-formula
    providers (`charBase` for the depth-0 atom-layer projections, `charK` for the depth-`k`
    E[Σ]-atoms), the atom layer `r`, the off-fiber-falsity gate conjunct `offFiber`, and the
    fold-bit function `b`. `bracketEndChar_k1v` (:1927) is DEFINITIONALLY this body at
    `charBase = charK = nf_depth0_char_formula`, `offFiber` = the depth-0 off-fiber clause, and
    `b` = the `efold_of_nf1` pointwise read (the `rfl` lemma `bracketEndChar_k1v_eq_kv_body`
    below), which is what makes the documented k=1 bridge `bracketEndChar_kv_one_eq` a pure
    split-kit computation. Structure and citations: see `bracketEndChar_kv` above. -/
private noncomputable def kv_body {sig : MonadicSignature} {k : Nat}
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig k 1 → Formula)
    (r : NormalForm sig 0 3)
    (offFiber : Prop)
    (b : ZoneSpec 3 → NormalForm sig k 1 → Bool) : VVecEA2 :=
    -- Zone-spec constants relative to env `[w, x, t]` under the bracket order `x < w < t`
    -- (Def 3.1 ordering channel, PDF p.4), verbatim from `bracketEndChar_k1v` (:1937-1948).
    let ltz : Bool × Bool := (true, false)
    let eqz : Bool × Bool := (false, false)
    let gtz : Bool × Bool := (false, true)
    let mk3 : Bool × Bool → Bool × Bool → Bool × Bool → ZoneSpec 3 := fun pw px pt =>
      Fin.cons pw (Fin.cons px (fun _ => pt))
    let zPastX := mk3 ltz ltz ltz    -- x_1 < x  (< w < t)
    let zAtX   := mk3 ltz eqz ltz    -- x_1 = x
    let zXW    := mk3 ltz gtz ltz    -- x < x_1 < w
    let zAtW   := mk3 eqz gtz ltz    -- x_1 = w
    let zWT    := mk3 gtz gtz ltz    -- w < x_1 < t
    let zAtT   := mk3 gtz gtz eqz    -- x_1 = t
    let zFutT  := mk3 gtz gtz gtz    -- t < x_1
    let allTypes : List (NormalForm sig k 1) := Finset.univ.toList
    -- Biconditional literal at an anchor (Prop 3.5 folding mechanism, PDF p.5).
    let lit : Bool → Formula → Formula := fun bit f => if bit then f else f.neg
    -- Endpoint types (the FIXED `z_0 = x`, `z_1 = t`: Lemma 3.2(2) PDF p.4 + §5 bracket PDF p.7).
    let xType : TemporalPred := ⟨charBase (nf_x_proj3 r)⟩
    let tType : TemporalPred := ⟨charBase (nf_t_proj3 r)⟩
    let epL : TemporalPred :=
      ⟨formula_conjList
        (xType.formula
          :: (allTypes.map fun χ => lit (b zPastX χ) (Formula.snce (charK χ) Formula.top))
          ++ (allTypes.map fun χ => lit (b zAtX χ) (charK χ)))⟩
    let epR : TemporalPred :=
      ⟨formula_conjList
        (tType.formula
          :: (allTypes.map fun χ => lit (b zAtT χ) (charK χ))
          ++ (allTypes.map fun χ => lit (b zFutT χ) (Formula.untl (charK χ) Formula.top)))⟩
    -- Segment types: universal exclusion of the interior-zone NEGATIVE bits.
    let segL : TemporalPred :=
      ⟨formula_conjList (allTypes.map fun χ =>
        if b zXW χ then Formula.top else (charK χ).neg)⟩
    let segR : TemporalPred :=
      ⟨formula_conjList (allTypes.map fun χ =>
        if b zWT χ then Formula.top else (charK χ).neg)⟩
    -- Witness point type at `w`: complete type + equality-zone bits ONLY (rule N4 — no
    -- interior chains; interior-positive content rides the witness slots below).
    let ptW : TemporalPred :=
      ⟨formula_conjList
        (charBase (nf_y_proj r)
          :: (allTypes.map fun χ => lit (b zAtW χ) (charK χ)))⟩
    -- Consistency of a zone spec with the bracket order `x < w < t` (the seven real zones).
    let consistent : ZoneSpec 3 → Prop := fun zs =>
      zs = zPastX ∨ zs = zAtX ∨ zs = zXW ∨ zs = zAtW ∨ zs = zWT ∨ zs = zAtT ∨ zs = zFutT
    -- The gate Prop (off-fiber honesty + order-conflict falsity), the two conjuncts of
    -- `bracketEndChar_k1v`'s gate (:1985-1987) with the off-fiber clause a parameter.
    let gate : Prop :=
      offFiber ∧
      (∀ (zs : ZoneSpec 3) (χ : NormalForm sig k 1), ¬ consistent zs → b zs χ = false)
    -- Interior-positive enumerations (duplicate-free: `Finset.univ.toList`).
    let S_L : List (NormalForm sig k 1) := allTypes.filter (fun χ => b zXW χ)
    let S_R : List (NormalForm sig k 1) := allTypes.filter (fun χ => b zWT χ)
    let charP : NormalForm sig k 1 → TemporalPred := fun χ => ⟨charK χ⟩
    -- One disjunct per arrangement (rule N5): interior-positive pairs occupy WITNESS slots
    -- ordered between the fixed endpoints (§5 bracket, PDF p.7; Lemma 3.4, PDF p.5).
    let mkDisjunct : List (NormalForm sig k 1) → List (NormalForm sig k 1) → Σ n, VecEA2 n :=
      fun lL lR =>
        ⟨(lL.map charP).length + 1 + (lR.map charP).length,
          { endpointLeft := epL
            endpointRight := epR
            bracket := bracketFromLists (lL.map charP) ptW (lR.map charP) segL segR }⟩
    @dite _ gate (Classical.dec gate)
      (fun _ =>
        { disjuncts :=
            S_L.permutations.flatMap fun lL =>
              S_R.permutations.map fun lR => mkDisjunct lL lR })
      (fun _ => { disjuncts := [] })

open Classical in
/-- **The depth-`k` V-carrier** (task 309 Phase 12, R3a). See the doc-comment block above
    `kv_body` for the full construction record and citations. `k = 0`: singleton-disjunct
    wrapper of `bracketEndChar_k0` (:1567). `k + 1`: the shared successor body `kv_body` at the
    depth-`k` E[Σ]-atom provider `charF k`, the atom-layer off-fiber clause, and the
    fiber-existential fold-bit read (every read of `qnf.2` goes through it — no arity-4
    evaluation occurs). `open Classical in` (above this doc-comment): the fold-bit
    existential's `Decidable` instance is
    `Classical.propDecidable` (`ZoneSpec` is a plain `def`, so no `DecidableEq` synthesizes for
    it); the carrier is noncomputable anyway. -/
noncomputable def bracketEndChar_kv {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charF : (j : Nat) → NormalForm sig j 1 → Formula) :
    (k : Nat) → BracketEndCharCarrierV sig k
  | 0 => fun qnf => { disjuncts := [⟨1, bracketEndChar_k0 atomMap h_surj qnf⟩] }
  | k + 1 => fun qnf =>
    kv_body (nf_depth0_char_formula atomMap h_surj) (charF k) qnf.1
      (∀ sub : NormalForm sig k 4,
        nf0_dropFresh (NormalForm.atom_assgn sub) ≠ qnf.1 → qnf.2 sub = false)
      (fun zs χ => decide (∃ sub : NormalForm sig k 4, qnf.2 sub = true ∧
        nf0_zoneSpec (NormalForm.atom_assgn sub) = zs ∧ nfk_projFresh sub = χ))

/-- `bracketEndChar_k1v` (:1927) is definitionally the shared successor body `kv_body` at the
    depth-0 providers, the depth-0 off-fiber clause, and the `efold_of_nf1` pointwise fold-bit
    read (`(efold_of_nf1 qnf).2 (zs, χ)` unfolds to `qnf.2 (nf0_assemble zs χ qnf.1)`,
    NfEFold:472). Pure `rfl` — no semantics. -/
private theorem bracketEndChar_k1v_eq_kv_body {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (qnf : NormalForm sig 1 3) :
    bracketEndChar_k1v atomMap h_surj qnf =
      kv_body (nf_depth0_char_formula atomMap h_surj) (nf_depth0_char_formula atomMap h_surj)
        qnf.1
        (∀ sub : NormalForm sig 0 4, nf0_dropFresh sub ≠ qnf.1 → qnf.2 sub = false)
        (fun zs χ => qnf.2 (nf0_assemble zs χ qnf.1)) := rfl

/-- Gate-failure computation for the shared body: if the off-fiber conjunct fails, the gate
    fails and the body returns the empty disjunction (Rabinovich's empty disjunction over
    inconsistent order types). -/
private theorem kv_body_gate_fail {sig : MonadicSignature} {k : Nat}
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig k 1 → Formula)
    (r : NormalForm sig 0 3)
    (offFiber : Prop)
    (b : ZoneSpec 3 → NormalForm sig k 1 → Bool)
    (h : ¬ offFiber) :
    kv_body charBase charK r offFiber b = { disjuncts := [] } := by
  simp only [kv_body]
  exact dif_neg (fun hg => h hg.1)

open Classical in
/-- **Documented k=1 bridge lemma** (task 309 Phase 12 acceptance): the `k = 1` specialization
    of `bracketEndChar_kv` is pointwise EQUAL to the landed `bracketEndChar_k1v` (:1927),
    whenever the provider family agrees with the depth-0 characteristic at depth 0 (which the
    Phase-14 instantiation does by construction, KampPrior:397 at depth 0 =
    `nf_depth0_char_formula`). Phase 13's step can therefore reuse the sorry-free
    `bracketEndChar_k1v_correct` (:3378) verbatim at the `k = 1` instance.

    Proof shape: when the off-fiber-falsity gate conjunct holds, the fiber-existential fold
    bit collapses to the `efold_of_nf1` pointwise read via the depth-0 split-kit round trips
    (`nf0_split_assemble`, NfEFold:235; `nf0_zoneSpec_assemble`/`nf0_projFresh_assemble`,
    NfEFold:197/206) — Def 3.1's three-channel bijection (PDF p.4). When it fails, both gates
    fail and both carriers return the empty disjunction (`kv_body_gate_fail`). No chain step is
    shortcut (G5): the equality is purely the split-kit bijection, no semantic evaluation
    occurs. (`open Classical in` matches the carrier's fold-bit `Decidable` instance.) -/
theorem bracketEndChar_kv_one_eq {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charF : (j : Nat) → NormalForm sig j 1 → Formula)
    (h0 : charF 0 = nf_depth0_char_formula atomMap h_surj)
    (qnf : NormalForm sig 1 3) :
    bracketEndChar_kv atomMap h_surj charF 1 qnf = bracketEndChar_k1v atomMap h_surj qnf := by
  by_cases hOFF : ∀ sub : NormalForm sig 0 4, nf0_dropFresh sub ≠ qnf.1 → qnf.2 sub = false
  · -- On-gate branch: the fiber-existential bit equals the pointwise `efold_of_nf1` read
    -- (split-kit bijection), so the two `kv_body` instances coincide argument-by-argument.
    have hbit : ∀ (zs : ZoneSpec 3) (χ : NormalForm sig 0 1),
        (decide (∃ sub : NormalForm sig 0 4, qnf.2 sub = true ∧
          nf0_zoneSpec (NormalForm.atom_assgn sub) = zs ∧ nfk_projFresh sub = χ) : Bool) =
        qnf.2 (nf0_assemble zs χ qnf.1) := by
      intro zs χ
      cases hq : qnf.2 (nf0_assemble zs χ qnf.1) with
      | true =>
        -- Forward witness: the assembled sub itself, via the three round trips.
        rw [decide_eq_true_iff]
        refine ⟨nf0_assemble zs χ qnf.1, hq, ?_, ?_⟩
        · exact nf0_zoneSpec_assemble zs χ qnf.1
        · exact (nfk_projFresh_zero _).trans (nf0_projFresh_assemble zs χ qnf.1)
      | false =>
        -- Any fiber witness reassembles to the assembled sub (split-kit bijection),
        -- contradicting `hq` — so the existential is false.
        rw [decide_eq_false_iff_not]
        rintro ⟨sub, hsub, hzs, hproj⟩
        have hdrop : nf0_dropFresh sub = qnf.1 := by
          by_contra hne
          rw [hOFF sub hne] at hsub
          exact Bool.noConfusion hsub
        have hassemble : nf0_assemble zs χ qnf.1 = sub := by
          have hsp := nf0_split_assemble sub
          rw [show nf0_zoneSpec sub = zs from hzs,
            show nf0_projFresh sub = χ from ((nfk_projFresh_zero sub).symm.trans hproj),
            hdrop] at hsp
          exact hsp
        rw [hassemble] at hq
        rw [hq] at hsub
        exact Bool.noConfusion hsub
    have hb : (fun zs χ => (decide (∃ sub : NormalForm sig 0 4, qnf.2 sub = true ∧
          nf0_zoneSpec (NormalForm.atom_assgn sub) = zs ∧ nfk_projFresh sub = χ) : Bool)) =
        (fun zs χ => qnf.2 (nf0_assemble zs χ qnf.1)) :=
      funext fun zs => funext fun χ => hbit zs χ
    calc bracketEndChar_kv atomMap h_surj charF 1 qnf
        = kv_body (nf_depth0_char_formula atomMap h_surj) (charF 0) qnf.1
            (∀ sub : NormalForm sig 0 4, nf0_dropFresh sub ≠ qnf.1 → qnf.2 sub = false)
            (fun zs χ => decide (∃ sub : NormalForm sig 0 4, qnf.2 sub = true ∧
              nf0_zoneSpec (NormalForm.atom_assgn sub) = zs ∧ nfk_projFresh sub = χ)) := rfl
      _ = kv_body (nf_depth0_char_formula atomMap h_surj)
            (nf_depth0_char_formula atomMap h_surj) qnf.1
            (∀ sub : NormalForm sig 0 4, nf0_dropFresh sub ≠ qnf.1 → qnf.2 sub = false)
            (fun zs χ => qnf.2 (nf0_assemble zs χ qnf.1)) := by rw [h0, hb]
      _ = bracketEndChar_k1v atomMap h_surj qnf :=
          (bracketEndChar_k1v_eq_kv_body atomMap h_surj qnf).symm
  · -- Off-gate branch: both gates fail on their (shared, defeq) off-fiber conjunct; both
    -- carriers return the empty disjunction `⟨[]⟩` (`kv_body_gate_fail`).
    calc bracketEndChar_kv atomMap h_surj charF 1 qnf
        = ({ disjuncts := [] } : VVecEA2) := kv_body_gate_fail _ _ _ _ _ hOFF
      _ = bracketEndChar_k1v atomMap h_surj qnf := by
          rw [bracketEndChar_k1v_eq_kv_body atomMap h_surj qnf,
            kv_body_gate_fail _ _ _ _ _ hOFF]

/-! ## Task 309 Phase 13 (R3b): depth-`k` V-carrier correctness — landed instances -/

/-- **`k = 0` instance of the depth-`k` V-carrier correctness** (task 309 Phase 13, R3b — the
    recursion BASE). The `k = 0` branch of `bracketEndChar_kv` (:3659) is the singleton-disjunct
    wrapper of `bracketEndChar_k0` (:1567), so its `VVecEA2.holds` reduces to the `VecEA2.holds`
    of the landed depth-0 bracket and the equivalence is exactly `bracketEndChar_k0_correct`
    (:1581) — Prop 3.5 depth-0 collapse (PDF p.5); two-fixed-endpoint framing per Lemma 3.2(2)
    (PDF p.4) + §5 bracket notation `[α_0, …, α_n](z_0, z_1)` (PDF p.7), rule N1 split. No
    chain step is shortcut (G5): the singleton reduction is pure list computation, the semantic
    content is the consumed k0 lemma. Anchors stay the FIXED `{x, t}` (G4/G6). -/
theorem bracketEndChar_kv_correct_zero {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charF : (j : Nat) → NormalForm sig j 1 → Formula)
    (qnf : NormalForm sig 0 3)
    (h_xy : qnf (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    (h_yt : qnf (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_xt : qnf (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_yx : qnf (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (h_ty : qnf (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
    (h_tx : qnf (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (M : OrderedMonadicStructure sig) (x t : M.carrier) :
    (bracketEndChar_kv atomMap h_surj charF 0 qnf).holds M atomMap x t ↔
      ∃ w : M.carrier, nf_eval_nf M 0 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf := by
  have hsing : (bracketEndChar_kv atomMap h_surj charF 0 qnf).holds M atomMap x t ↔
      (bracketEndChar_k0 atomMap h_surj qnf).holds M atomMap x t := by
    simp only [bracketEndChar_kv, VVecEA2.holds, List.mem_singleton, exists_eq_left]
  exact hsing.trans
    (bracketEndChar_k0_correct atomMap h_surj qnf h_xy h_yt h_xt h_yx h_ty h_tx M x t)

/-- **`k = 1` instance of the depth-`k` V-carrier correctness** (task 309 Phase 13, R3b — the
    first successor step). Under the depth-0 provider agreement `h0` (satisfied by the Phase-14
    instantiation by construction, KampPrior:397 at depth 0), the documented k=1 bridge
    `bracketEndChar_kv_one_eq` (:3710, pointwise EQUALITY via the depth-0 split-kit bijection —
    Def 3.1's three-channel bijection, PDF p.4) rewrites the carrier to the landed
    `bracketEndChar_k1v` (:1927), and the equivalence is the sorry-free
    `bracketEndChar_k1v_correct` (:3378) verbatim — the R2 = GO record. Citations ride the
    consumed lemma (rule N1 split there); no chain step is shortcut here (G5). -/
theorem bracketEndChar_kv_correct_one {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charF : (j : Nat) → NormalForm sig j 1 → Formula)
    (h0 : charF 0 = nf_depth0_char_formula atomMap h_surj)
    (qnf : NormalForm sig 1 3)
    (h_xy : qnf.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    (h_yt : qnf.1 (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_xt : qnf.1 (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_yx : qnf.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (h_ty : qnf.1 (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
    (h_tx : qnf.1 (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (M : OrderedMonadicStructure sig) (x t : M.carrier) :
    (bracketEndChar_kv atomMap h_surj charF 1 qnf).holds M atomMap x t ↔
      ∃ w : M.carrier, nf_eval_nf M 1 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf := by
  rw [bracketEndChar_kv_one_eq atomMap h_surj charF h0 qnf]
  exact bracketEndChar_k1v_correct atomMap h_surj qnf h_xy h_yt h_xt h_yx h_ty h_tx M x t

open Classical in
/-- **Fiber-factorization of the depth-`k` V-carrier** (task 309 Phase 13 — the machine-checked
    ISOLATION half of finding F1, recorded in the section comment below). At every successor
    depth the carrier is a function of the atom layer `qnf.1`, the atom-layer off-fiber Prop,
    and the fiber-existential fold bits ONLY: two quant layers that agree on this data yield
    EQUAL carriers, even when they disagree on the marking of individual depth-`k` arity-4 subs
    inside a shared `(zoneSpec, projFresh)` fiber. Pure congruence on `kv_body` (:3568) — no
    semantics. This is the information-loss channel that refutes the unconditional k≥2
    soundness direction of the plan-v5 Phase 13 target (see F1 below). -/
theorem bracketEndChar_kv_factors {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charF : (j : Nat) → NormalForm sig j 1 → Formula)
    {k : Nat} (qnf qnf' : NormalForm sig (k + 1) 3)
    (h1 : qnf.1 = qnf'.1)
    (hoff : (∀ sub : NormalForm sig k 4,
        nf0_dropFresh (NormalForm.atom_assgn sub) ≠ qnf.1 → qnf.2 sub = false) ↔
      (∀ sub : NormalForm sig k 4,
        nf0_dropFresh (NormalForm.atom_assgn sub) ≠ qnf'.1 → qnf'.2 sub = false))
    (hb : ∀ (zs : ZoneSpec 3) (χ : NormalForm sig k 1),
        (∃ sub : NormalForm sig k 4, qnf.2 sub = true ∧
          nf0_zoneSpec (NormalForm.atom_assgn sub) = zs ∧ nfk_projFresh sub = χ) ↔
        (∃ sub : NormalForm sig k 4, qnf'.2 sub = true ∧
          nf0_zoneSpec (NormalForm.atom_assgn sub) = zs ∧ nfk_projFresh sub = χ)) :
    bracketEndChar_kv atomMap h_surj charF (k + 1) qnf =
      bracketEndChar_kv atomMap h_surj charF (k + 1) qnf' := by
  have e2 : (∀ sub : NormalForm sig k 4,
        nf0_dropFresh (NormalForm.atom_assgn sub) ≠ qnf.1 → qnf.2 sub = false) =
      (∀ sub : NormalForm sig k 4,
        nf0_dropFresh (NormalForm.atom_assgn sub) ≠ qnf'.1 → qnf'.2 sub = false) :=
    propext hoff
  have e3 : (fun (zs : ZoneSpec 3) (χ : NormalForm sig k 1) =>
        (decide (∃ sub : NormalForm sig k 4, qnf.2 sub = true ∧
          nf0_zoneSpec (NormalForm.atom_assgn sub) = zs ∧ nfk_projFresh sub = χ) : Bool)) =
      (fun (zs : ZoneSpec 3) (χ : NormalForm sig k 1) =>
        decide (∃ sub : NormalForm sig k 4, qnf'.2 sub = true ∧
          nf0_zoneSpec (NormalForm.atom_assgn sub) = zs ∧ nfk_projFresh sub = χ)) :=
    funext fun zs => funext fun χ => decide_eq_decide.mpr (hb zs χ)
  show kv_body (nf_depth0_char_formula atomMap h_surj) (charF k) qnf.1 _ _ =
    kv_body (nf_depth0_char_formula atomMap h_surj) (charF k) qnf'.1 _ _
  rw [e2, e3, h1]

/-! ## Task 309 Phase 13 finding F1: the unconditional depth-`k` correctness target is FALSE
at `k = 2` for the Phase-12 carrier — the gate-strength defect anticipated by the Phase-12
handoff (Key Decision 3) is REAL

**Target refuted** (plan v5 Phase 13 deliverable): under the six bracket-zone order hypotheses
and the `charF` correctness hypothesis alone,
`(bracketEndChar_kv atomMap h_surj charF k qnf).holds M atomMap x t ↔
∃ w, nf_eval_nf M k 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf` fails at `k = 2` — the
soundness (LHS→RHS) direction. Defect record (four elements):

1. **Counterexample** (semantic). `sig` = one predicate `P`; `M` = `(ℚ, <)` with
   `P = {q, p, r}` and `q < x < u₂ < p < u₁ < w < t < r`. Then `u₁, u₂` share their complete
   depth-1 1-type `χ` (a `P`-point strictly below each: `p`/`q`; strictly above each: `r`/`p`;
   none at; density realizes the non-`P` depth-0 2-types identically), but the depth-1 arity-4
   types `sub₁ :=` type of `[u₁,w,x,t]` and `sub₂ :=` type of `[u₂,w,x,t]` are DISTINCT — the
   depth-0 5-type "`P z` and `x < z <` fresh" is realized below `u₁` (via `z = p`) and not
   below `u₂` — while sharing all fiber data: zone `zXW`, `nfk_projFresh = χ`,
   atom-restriction `= qnf.1`. Let `qnf := nf_characteristic M 2 3 [w,x,t]` (realized at `w`:
   `nf_characteristic_satisfies`, NormalForm:224) and `qnf' := qnf` with `sub₂` re-marked
   `false`. Then: (a) `bracketEndChar_kv … 2 qnf' = bracketEndChar_kv … 2 qnf` — by
   `bracketEndChar_kv_factors` above (`sub₁` keeps every fiber bit alive; the off-fiber clause
   is unaffected by un-marking an on-fiber sub); (b) the six order hypotheses hold on
   `qnf'.1 = qnf.1`; (c) NO `w'` realizes `qnf'` in `M`: for `w' > p` density supplies
   `v ∈ (x, p)` with `[v,w',x,t]` of type `sub₂` — realized but marked false; for `w' ≤ p`
   there is no `v < w'` with a `P`-point in `(x, v)` — `sub₁` marked true but unrealized
   (`w' = p` is excluded by the atom layer: `P w'` must be false). The target `↔` at `qnf`
   forces the carrier to HOLD at `(x, t)` (mpr at witness `w`); (a) transports that to `qnf'`;
   the target `↔` at `qnf'` then forces `∃ w'` realizing `qnf'` — contradicting (c). NOTE:
   `qnf'` IS realizable in a different chain (a discrete one with no point strictly between
   `x` and `p`), so no qnf-consistency hypothesis rescues the statement either.

2. **Current behavior**: at depth `k + 1` the carrier reads `qnf.2` ONLY through (i) the
   atom-layer off-fiber Prop and (ii) the fiber-existential bits (:3661-3665);
   `bracketEndChar_kv_factors` machine-checks this factorization.

3. **Required behavior**: the quant layer of `nf_eval_nf M (k+1) 3 env qnf`
   (NormalForm:203-207) is a per-sub BICONDITIONAL over depth-`k` arity-4 subs. At
   `k + 1 ≥ 2` a fiber `(zs, χ)` over `qnf.1` contains ≥ 2 subs differing in deeper JOINT
   layers (D7, NfEFold:373 — no pointwise assemble exists), and the biconditional
   distinguishes in-fiber markings the carrier cannot see.

4. **Isolation**: `k = 1` is saved by the depth-0 split-kit BIJECTION (`nf0_split_assemble`,
   NfEFold:235): fibers are singletons, so the fiber-existential read IS the pointwise read
   (the bridge :3710) — which is exactly why `bracketEndChar_k1v_correct` (:3378) is sorry-free
   and why the refutation starts at `k = 2`. In Rabinovich the corresponding step iterates
   Prop 4.3 (PDF p.6) with the `α_j`/`β_j` ENRICHED at every fold round: Def 3.1 (PDF p.4)
   takes quantifier-free formulas over the CURRENT vocabulary, and after a round that
   vocabulary includes the previous round's TL-definable content (the `F_i` of Cor 5.4,
   PDF p.7, are TL formulas, not base-signature types) — so the joint structure of a fresh
   witness relative to the anchors rides the enriched interval/point formulas. The Phase-12
   realization instead projects subs to PLAIN depth-`k` 1-types over the BASE signature
   (`nfk_projFresh`), discarding exactly that joint structure. The repair is a carrier/plan
   revision (inside-out iterated fold with vocabulary enrichment — the Def 4.1 p.6 note read
   at full strength), NOT a gate patch: any syntactic gate strengthening is either violated by
   honest characteristic types (which DO distinguish same-fiber subs — the discrete-chain
   realization of `qnf'`) or is model-dependent. Per Key Decision 3 of the Phase-12 handoff,
   the Phase-12 gate is NOT silently changed here; this record is the mandated Phase-13
   finding.

**Not refuted**: the completeness direction (RHS→LHS) — the honest characteristic type's
carrier holds at all depths on this analysis; a plan-v6 carrier revision can expect to retain
the completeness shape. Landed in this phase: the recursion base `bracketEndChar_kv_correct_zero`
and the first step `bracketEndChar_kv_correct_one` (both above, sorry-free — the 13a seam of the
plan's H8 split note), plus the factorization lemma. Phase 13 is [BLOCKED] pending plan revision. -/

/-! ## Task 309 Phase 13.0: F2 decision probe — machinery

Probe infrastructure for the F2 verdict record at the bottom of this file (additive; nothing
above this line is edited). The probe machine-checks the report-05 F-B extension of F1 to the
Prior model `M* = (ℤ, <)`, `P = {0, 10, 20}` — a model that (unlike F1's `(ℚ, <)` with finite
`P`, which fails `semantic_prior_UZ`) SATISFIES both Prior hypotheses (PriorDefs:22/:33), so the
UZ/SZ-relativized k=2 statement for the CURRENT carrier `bracketEndChar_kv` is exercised on its
own turf. All declarations are probe-local (`private` where possible); the public verdict
theorem is `f2_relativized_refutation` below. -/

/-- One-predicate signature for the F2 probe (`()` names the single monadic predicate `P`). -/
private abbrev f2sig : MonadicSignature := { preds := Unit }

/-- Trivial atom map into the one-predicate probe signature. -/
private abbrev f2atomMap : Formula → f2sig.preds := fun _ => ()

/-- Surjectivity of the probe atom map (every predicate is hit by an atom). -/
private theorem f2surj : ∀ p : f2sig.preds, ∃ a : Atom, f2atomMap (.atom a) = p :=
  fun _ => ⟨Atom.mk_base "P", rfl⟩

/-- The F2 probe model `M* = (ℤ, <)` with `P = {0, 10, 20}` (report 05 F-B; the discrete
    extension of F1's counterexample pattern `q < x < u₂ < p < u₁ < w < t < r` at the concrete
    points `0 < 2 < 4 < 10 < 12 < 15 < 18 < 20`). -/
private abbrev F2M : OrderedMonadicStructure f2sig where
  carrier := ℤ
  interp := fun _ z => z = 0 ∨ z = 10 ∨ z = 20
  carrier_order := inferInstance

/-- `ℤ` first-occurrence principle: a nonempty subset of `(t, ∞)` has a least element
    (`Nat.find` on the shifted index). Pure integer arithmetic, no model content. -/
private theorem f2_int_first {Q : ℤ → Prop} (t : ℤ) (h : ∃ s, t < s ∧ Q s) :
    ∃ s, t < s ∧ Q s ∧ ∀ r, t < r → r < s → ¬ Q r := by
  classical
  obtain ⟨s, hts, hs⟩ := h
  have hP : ∃ n : ℕ, Q (t + 1 + (n : ℤ)) := by
    refine ⟨(s - t - 1).toNat, ?_⟩
    have hcast : t + 1 + (((s - t - 1).toNat : ℕ) : ℤ) = s := by omega
    rw [hcast]; exact hs
  refine ⟨t + 1 + (Nat.find hP : ℤ), by omega, Nat.find_spec hP, ?_⟩
  intro r htr hrs h_r
  have hm : ∃ m : ℕ, r = t + 1 + (m : ℤ) ∧ m < Nat.find hP :=
    ⟨(r - t - 1).toNat, by omega, by omega⟩
  obtain ⟨m, hmr, hmlt⟩ := hm
  exact Nat.find_min hP hmlt (hmr ▸ h_r)

/-- `ℤ` last-occurrence principle: a nonempty subset of `(-∞, t)` has a greatest element —
    the mirror of `f2_int_first`. -/
private theorem f2_int_last {Q : ℤ → Prop} (t : ℤ) (h : ∃ s, s < t ∧ Q s) :
    ∃ s, s < t ∧ Q s ∧ ∀ r, s < r → r < t → ¬ Q r := by
  classical
  obtain ⟨s, hst, hs⟩ := h
  have hP : ∃ n : ℕ, Q (t - 1 - (n : ℤ)) := by
    refine ⟨(t - s - 1).toNat, ?_⟩
    have hcast : t - 1 - (((t - s - 1).toNat : ℕ) : ℤ) = s := by omega
    rw [hcast]; exact hs
  refine ⟨t - 1 - (Nat.find hP : ℤ), by omega, Nat.find_spec hP, ?_⟩
  intro r hsr hrt h_r
  have hm : ∃ m : ℕ, r = t - 1 - (m : ℤ) ∧ m < Nat.find hP :=
    ⟨(t - r - 1).toNat, by omega, by omega⟩
  obtain ⟨m, hmr, hmlt⟩ := hm
  exact Nat.find_min hP hmlt (hmr ▸ h_r)

/-- `(ℤ, <)` satisfies semantic Prior-UZ (PriorDefs:22): every future occurrence of any
    temporal `ψ` has a FIRST occurrence, with `ψ.neg` on the open gap (`f2_int_first`). -/
private theorem f2_UZ : semantic_prior_UZ F2M f2atomMap := by
  intro t ψ h
  obtain ⟨s, hts, hs, hmin⟩ :=
    f2_int_first (Q := fun z => temporal_truth F2M f2atomMap z ψ) t h
  refine ⟨s, hts, hs, ?_⟩
  intro r htr hrs
  simp only [Formula.neg, temporal_truth]
  exact hmin r htr hrs

/-- `(ℤ, <)` satisfies semantic Prior-SZ (PriorDefs:33): every past occurrence of any
    temporal `ψ` has a LAST occurrence, with `ψ.neg` on the open gap (`f2_int_last`). -/
private theorem f2_SZ : semantic_prior_SZ F2M f2atomMap := by
  intro t ψ h
  obtain ⟨s, hst, hs, hmax⟩ :=
    f2_int_last (Q := fun z => temporal_truth F2M f2atomMap z ψ) t h
  refine ⟨s, hst, hs, ?_⟩
  intro r hsr hrt
  simp only [Formula.neg, temporal_truth]
  exact hmax r hsr hrt

/-- Evaluation is characteristic-equality (`nf_eval_unique` NormalForm:245 packaged with
    `nf_characteristic_satisfies` NormalForm:224): a normal form holds at `env` iff it IS the
    characteristic type of `env`. The probe's per-entry workhorse. -/
private theorem f2_eval_iff_char {k n : Nat} (env : Fin n → F2M.carrier)
    (σ : NormalForm f2sig k n) :
    nf_eval_nf F2M k n env σ ↔ σ = nf_characteristic F2M k n env :=
  ⟨fun h => nf_eval_unique F2M k n env σ _ h (nf_characteristic_satisfies F2M k n env),
   fun h => h ▸ nf_characteristic_satisfies F2M k n env⟩

/-- Depth-0 characteristic congruence: two `ℤ`-environments with the same `P`-pattern and the
    same order pattern have EQUAL depth-0 characteristic types. Pure Def-3.1 channel bookkeeping
    (`P`-bits + order bits are all a depth-0 type holds). -/
private theorem f2_char0_congr {n : Nat} (e₁ e₂ : Fin n → F2M.carrier)
    (hP : ∀ i, (e₁ i = 0 ∨ e₁ i = 10 ∨ e₁ i = 20) ↔ (e₂ i = 0 ∨ e₂ i = 10 ∨ e₂ i = 20))
    (hO : ∀ i j, e₁ i < e₁ j ↔ e₂ i < e₂ j) :
    nf_characteristic F2M 0 n e₁ = nf_characteristic F2M 0 n e₂ := by
  funext a
  simp only [nf_characteristic]
  apply decide_eq_decide.mpr
  cases a with
  | pred p i => exact hP i
  | order i j h => exact hO i j

/-- Prefix restriction of a depth-0 characteristic is the characteristic of the restricted
    environment (the depth-0 instance of `nfk_take` naturality). -/
private theorem f2_take_char0 {m n : Nat} (h : m ≤ n) (env : Fin n → F2M.carrier) :
    nfk_take h (nf_characteristic F2M 0 n env) =
      nf_characteristic F2M 0 m (fun i => env (Fin.castLE h i)) := by
  funext a
  simp only [nfk_take, nf_characteristic]
  cases a with
  | pred p i => rfl
  | order i j h' => rfl

/-- Depth-0 2-type congruence, value form (`Fin.cons` environments `[z, u]`): same `P`-bits and
    same order pattern give the same characteristic 2-type. -/
private theorem f2_char0_congr2 (z₁ u₁ z₂ u₂ : ℤ)
    (hPz : (z₁ = 0 ∨ z₁ = 10 ∨ z₁ = 20) ↔ (z₂ = 0 ∨ z₂ = 10 ∨ z₂ = 20))
    (hPu : (u₁ = 0 ∨ u₁ = 10 ∨ u₁ = 20) ↔ (u₂ = 0 ∨ u₂ = 10 ∨ u₂ = 20))
    (h_zu : z₁ < u₁ ↔ z₂ < u₂) (h_uz : u₁ < z₁ ↔ u₂ < z₂) :
    nf_characteristic F2M 0 2 (Fin.cons z₁ (fun _ => u₁)) =
      nf_characteristic F2M 0 2 (Fin.cons z₂ (fun _ => u₂)) := by
  apply f2_char0_congr
  · intro i
    match i with
    | ⟨0, _⟩ => exact hPz
    | ⟨1, _⟩ => exact hPu
  · intro i j
    match i, j with
    | ⟨0, _⟩, ⟨0, _⟩ => exact iff_of_false (lt_irrefl _) (lt_irrefl _)
    | ⟨0, _⟩, ⟨1, _⟩ => exact h_zu
    | ⟨1, _⟩, ⟨0, _⟩ => exact h_uz
    | ⟨1, _⟩, ⟨1, _⟩ => exact iff_of_false (lt_irrefl _) (lt_irrefl _)

/-- Depth-0 4-type congruence, value form (`Fin.cons` environments `[u, w, x, t]`). -/
private theorem f2_char0_congr4 (u₁ w₁ x₁ t₁ u₂ w₂ x₂ t₂ : ℤ)
    (hPu : (u₁ = 0 ∨ u₁ = 10 ∨ u₁ = 20) ↔ (u₂ = 0 ∨ u₂ = 10 ∨ u₂ = 20))
    (hPw : (w₁ = 0 ∨ w₁ = 10 ∨ w₁ = 20) ↔ (w₂ = 0 ∨ w₂ = 10 ∨ w₂ = 20))
    (hPx : (x₁ = 0 ∨ x₁ = 10 ∨ x₁ = 20) ↔ (x₂ = 0 ∨ x₂ = 10 ∨ x₂ = 20))
    (hPt : (t₁ = 0 ∨ t₁ = 10 ∨ t₁ = 20) ↔ (t₂ = 0 ∨ t₂ = 10 ∨ t₂ = 20))
    (h_uw : u₁ < w₁ ↔ u₂ < w₂) (h_wu : w₁ < u₁ ↔ w₂ < u₂)
    (h_ux : u₁ < x₁ ↔ u₂ < x₂) (h_xu : x₁ < u₁ ↔ x₂ < u₂)
    (h_ut : u₁ < t₁ ↔ u₂ < t₂) (h_tu : t₁ < u₁ ↔ t₂ < u₂)
    (h_wx : w₁ < x₁ ↔ w₂ < x₂) (h_xw : x₁ < w₁ ↔ x₂ < w₂)
    (h_wt : w₁ < t₁ ↔ w₂ < t₂) (h_tw : t₁ < w₁ ↔ t₂ < w₂)
    (h_xt : x₁ < t₁ ↔ x₂ < t₂) (h_tx : t₁ < x₁ ↔ t₂ < x₂) :
    nf_characteristic F2M 0 4 (Fin.cons u₁ (Fin.cons w₁ (Fin.cons x₁ (fun _ => t₁)))) =
      nf_characteristic F2M 0 4 (Fin.cons u₂ (Fin.cons w₂ (Fin.cons x₂ (fun _ => t₂)))) := by
  apply f2_char0_congr
  · intro i
    match i with
    | ⟨0, _⟩ => exact hPu
    | ⟨1, _⟩ => exact hPw
    | ⟨2, _⟩ => exact hPx
    | ⟨3, _⟩ => exact hPt
  · intro i j
    have irr : ∀ a b : ℤ, (a < a ↔ b < b) := fun a b =>
      iff_of_false (lt_irrefl _) (lt_irrefl _)
    match i, j with
    | ⟨0, _⟩, ⟨0, _⟩ => exact irr _ _
    | ⟨0, _⟩, ⟨1, _⟩ => exact h_uw
    | ⟨0, _⟩, ⟨2, _⟩ => exact h_ux
    | ⟨0, _⟩, ⟨3, _⟩ => exact h_ut
    | ⟨1, _⟩, ⟨0, _⟩ => exact h_wu
    | ⟨1, _⟩, ⟨1, _⟩ => exact irr _ _
    | ⟨1, _⟩, ⟨2, _⟩ => exact h_wx
    | ⟨1, _⟩, ⟨3, _⟩ => exact h_wt
    | ⟨2, _⟩, ⟨0, _⟩ => exact h_xu
    | ⟨2, _⟩, ⟨1, _⟩ => exact h_xw
    | ⟨2, _⟩, ⟨2, _⟩ => exact irr _ _
    | ⟨2, _⟩, ⟨3, _⟩ => exact h_xt
    | ⟨3, _⟩, ⟨0, _⟩ => exact h_tu
    | ⟨3, _⟩, ⟨1, _⟩ => exact h_tw
    | ⟨3, _⟩, ⟨2, _⟩ => exact h_tx
    | ⟨3, _⟩, ⟨3, _⟩ => exact irr _ _

/-- Depth-0 5-type congruence, value form (`Fin.cons` environments `[z, u, w, x, t]`) — the
    fresh-witness transfer workhorse for the F2 probe's per-entry checks. -/
private theorem f2_char0_congr5 (z₁ u₁ w₁ x₁ t₁ z₂ u₂ w₂ x₂ t₂ : ℤ)
    (hPz : (z₁ = 0 ∨ z₁ = 10 ∨ z₁ = 20) ↔ (z₂ = 0 ∨ z₂ = 10 ∨ z₂ = 20))
    (hPu : (u₁ = 0 ∨ u₁ = 10 ∨ u₁ = 20) ↔ (u₂ = 0 ∨ u₂ = 10 ∨ u₂ = 20))
    (hPw : (w₁ = 0 ∨ w₁ = 10 ∨ w₁ = 20) ↔ (w₂ = 0 ∨ w₂ = 10 ∨ w₂ = 20))
    (hPx : (x₁ = 0 ∨ x₁ = 10 ∨ x₁ = 20) ↔ (x₂ = 0 ∨ x₂ = 10 ∨ x₂ = 20))
    (hPt : (t₁ = 0 ∨ t₁ = 10 ∨ t₁ = 20) ↔ (t₂ = 0 ∨ t₂ = 10 ∨ t₂ = 20))
    (h_zu : z₁ < u₁ ↔ z₂ < u₂) (h_uz : u₁ < z₁ ↔ u₂ < z₂)
    (h_zw : z₁ < w₁ ↔ z₂ < w₂) (h_wz : w₁ < z₁ ↔ w₂ < z₂)
    (h_zx : z₁ < x₁ ↔ z₂ < x₂) (h_xz : x₁ < z₁ ↔ x₂ < z₂)
    (h_zt : z₁ < t₁ ↔ z₂ < t₂) (h_tz : t₁ < z₁ ↔ t₂ < z₂)
    (h_uw : u₁ < w₁ ↔ u₂ < w₂) (h_wu : w₁ < u₁ ↔ w₂ < u₂)
    (h_ux : u₁ < x₁ ↔ u₂ < x₂) (h_xu : x₁ < u₁ ↔ x₂ < u₂)
    (h_ut : u₁ < t₁ ↔ u₂ < t₂) (h_tu : t₁ < u₁ ↔ t₂ < u₂)
    (h_wx : w₁ < x₁ ↔ w₂ < x₂) (h_xw : x₁ < w₁ ↔ x₂ < w₂)
    (h_wt : w₁ < t₁ ↔ w₂ < t₂) (h_tw : t₁ < w₁ ↔ t₂ < w₂)
    (h_xt : x₁ < t₁ ↔ x₂ < t₂) (h_tx : t₁ < x₁ ↔ t₂ < x₂) :
    nf_characteristic F2M 0 5
        (Fin.cons z₁ (Fin.cons u₁ (Fin.cons w₁ (Fin.cons x₁ (fun _ => t₁))))) =
      nf_characteristic F2M 0 5
        (Fin.cons z₂ (Fin.cons u₂ (Fin.cons w₂ (Fin.cons x₂ (fun _ => t₂))))) := by
  apply f2_char0_congr
  · intro i
    match i with
    | ⟨0, _⟩ => exact hPz
    | ⟨1, _⟩ => exact hPu
    | ⟨2, _⟩ => exact hPw
    | ⟨3, _⟩ => exact hPx
    | ⟨4, _⟩ => exact hPt
  · intro i j
    have irr : ∀ a b : ℤ, (a < a ↔ b < b) := fun a b =>
      iff_of_false (lt_irrefl _) (lt_irrefl _)
    match i, j with
    | ⟨0, _⟩, ⟨0, _⟩ => exact irr _ _
    | ⟨0, _⟩, ⟨1, _⟩ => exact h_zu
    | ⟨0, _⟩, ⟨2, _⟩ => exact h_zw
    | ⟨0, _⟩, ⟨3, _⟩ => exact h_zx
    | ⟨0, _⟩, ⟨4, _⟩ => exact h_zt
    | ⟨1, _⟩, ⟨0, _⟩ => exact h_uz
    | ⟨1, _⟩, ⟨1, _⟩ => exact irr _ _
    | ⟨1, _⟩, ⟨2, _⟩ => exact h_uw
    | ⟨1, _⟩, ⟨3, _⟩ => exact h_ux
    | ⟨1, _⟩, ⟨4, _⟩ => exact h_ut
    | ⟨2, _⟩, ⟨0, _⟩ => exact h_wz
    | ⟨2, _⟩, ⟨1, _⟩ => exact h_wu
    | ⟨2, _⟩, ⟨2, _⟩ => exact irr _ _
    | ⟨2, _⟩, ⟨3, _⟩ => exact h_wx
    | ⟨2, _⟩, ⟨4, _⟩ => exact h_wt
    | ⟨3, _⟩, ⟨0, _⟩ => exact h_xz
    | ⟨3, _⟩, ⟨1, _⟩ => exact h_xu
    | ⟨3, _⟩, ⟨2, _⟩ => exact h_xw
    | ⟨3, _⟩, ⟨3, _⟩ => exact irr _ _
    | ⟨3, _⟩, ⟨4, _⟩ => exact h_xt
    | ⟨4, _⟩, ⟨0, _⟩ => exact h_tz
    | ⟨4, _⟩, ⟨1, _⟩ => exact h_tu
    | ⟨4, _⟩, ⟨2, _⟩ => exact h_tw
    | ⟨4, _⟩, ⟨3, _⟩ => exact h_tx
    | ⟨4, _⟩, ⟨4, _⟩ => exact irr _ _

/-! ### F2 probe: the concrete counterexample pair `(qnf, qnf')` at `k = 2`

Report 05 F-B data, transcribed: anchors `[w, x, t] = [15, 2, 18]`, distinguishing points
`u₁ = 12`, `u₂ = 4` (both in the interior zone `zXW`, both `¬P`, sharing their complete depth-1
monadic point type), separated by the `P`-point `10 ∈ (x, u₁) \ (x, u₂)`. -/

/-- Probe anchor environment `[w, x, t] = [15, 2, 18]`. -/
private def f2env3 : Fin 3 → F2M.carrier := Fin.cons 15 (Fin.cons 2 (fun _ => 18))

/-- `qnf`: the honest depth-2 characteristic 3-type of `[15, 2, 18]` in `M*` (realized at
    `w = 15` by `nf_characteristic_satisfies`). -/
private noncomputable def f2qnf : NormalForm f2sig 2 3 := nf_characteristic F2M 2 3 f2env3

/-- `sub₁`: the depth-1 arity-4 type of `[u₁, w, x, t] = [12, 15, 2, 18]`. -/
private noncomputable def f2sub1 : NormalForm f2sig 1 4 :=
  nf_characteristic F2M 1 4 (Fin.cons 12 f2env3)

/-- `sub₂`: the depth-1 arity-4 type of `[u₂, w, x, t] = [4, 15, 2, 18]`. -/
private noncomputable def f2sub2 : NormalForm f2sig 1 4 :=
  nf_characteristic F2M 1 4 (Fin.cons 4 f2env3)

/-- `qnf'`: `qnf` with the `u₂`-sub un-marked — the F1 information-loss pattern (F1 item 1). -/
private noncomputable def f2qnf' : NormalForm f2sig 2 3 :=
  (f2qnf.1, fun σ => if σ = f2sub2 then false else f2qnf.2 σ)

/-- Unfold: the atom layer of `qnf` is the depth-0 characteristic of the anchors. -/
private theorem f2qnf_fst : f2qnf.1 = nf_characteristic F2M 0 3 f2env3 := rfl

/-- Unfold: the quant layer of `qnf` is the realized-sub `decide` (honest marking). -/
private theorem f2qnf_snd (σ : NormalForm f2sig 1 4) :
    f2qnf.2 σ =
      @decide (∃ u : ℤ, nf_eval_nf F2M 1 4 (Fin.cons u f2env3) σ)
        (Classical.dec _) := rfl

/-- Unfold: the quant layer of a depth-1 arity-4 characteristic is the realized-entry
    `decide` over depth-0 arity-5 types. -/
private theorem f2char14_snd (env : Fin 4 → F2M.carrier) (e : NormalForm f2sig 0 5) :
    (nf_characteristic F2M 1 4 env).2 e =
      @decide (∃ z : ℤ, nf_eval_nf F2M 0 5 (Fin.cons z env) e)
        (Classical.dec _) := rfl

/-- `sub₁` is marked in `qnf` (realized at `u₁ = 12`). -/
private theorem f2_sub1_marked : f2qnf.2 f2sub1 = true := by
  rw [f2qnf_snd]
  exact @decide_eq_true _ (Classical.dec _)
    ⟨12, nf_characteristic_satisfies F2M 1 4 (Fin.cons 12 f2env3)⟩

/-- `sub₁` and `sub₂` share their full atom layer: same order pattern `x < u < w < t`, same
    `P`-bits (both fresh points `¬P`) — the Def-3.1 ordering and env-restriction channels of
    the two subs agree. -/
private theorem f2_sub_atom_eq : f2sub1.1 = f2sub2.1 := by
  show nf_characteristic F2M 0 4 (Fin.cons 12 f2env3) =
    nf_characteristic F2M 0 4 (Fin.cons 4 f2env3)
  exact f2_char0_congr _ _ (by decide) (by decide)

/-- The distinguishing entry `e* :=` the depth-0 5-type of `[10, 12, 15, 2, 18]` — the type
    "`P z` and `x < z < u < w < t`" (F1 item 1's depth-0 5-type, at the F-B points). -/
private noncomputable def f2estar : NormalForm f2sig 0 5 :=
  nf_characteristic F2M 0 5 (Fin.cons 10 (Fin.cons 12 f2env3))

/-- `e*` is marked in `sub₁` (witness `z = 10`: `P 10` and `2 < 10 < 12`). -/
private theorem f2_estar_in_sub1 : f2sub1.2 f2estar = true := by
  rw [show f2sub1.2 f2estar = _ from f2char14_snd _ f2estar]
  exact @decide_eq_true _ (Classical.dec _)
    ⟨10, nf_characteristic_satisfies F2M 0 5 (Fin.cons 10 (Fin.cons 12 f2env3))⟩

/-- `e*` is NOT marked in `sub₂`: a witness would need `P z` with `2 < z < 4` — the gap
    `(x, u₂)` contains no `P`-point. THE information the fiber-existential read discards. -/
private theorem f2_estar_not_in_sub2 : f2sub2.2 f2estar = false := by
  rw [show f2sub2.2 f2estar = _ from f2char14_snd _ f2estar]
  apply @decide_eq_false _ (Classical.dec _)
  rintro ⟨z, hz⟩
  rw [f2_eval_iff_char] at hz
  -- Read the P-bit and the two order bits of `z` off the type equality.
  have hP : ((z : ℤ) = 0 ∨ (z : ℤ) = 10 ∨ (z : ℤ) = 20) := by
    have hb := congrFun hz (.pred () ⟨0, by omega⟩)
    simp only [f2estar, nf_characteristic] at hb
    have h10 : (10 : ℤ) = 0 ∨ (10 : ℤ) = 10 ∨ (10 : ℤ) = 20 := by norm_num
    exact (decide_eq_decide.mp hb).mp h10
  have hgt : (2 : ℤ) < z := by
    have hb := congrFun hz (.order ⟨3, by omega⟩ ⟨0, by omega⟩ (Fin.ne_of_val_ne (by decide)))
    simp only [f2estar, nf_characteristic] at hb
    have h210 : (2 : ℤ) < 10 := by omega
    exact (decide_eq_decide.mp hb).mp h210
  have hlt : (z : ℤ) < 4 := by
    have hb := congrFun hz (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (Fin.ne_of_val_ne Nat.zero_ne_one))
    simp only [f2estar, nf_characteristic] at hb
    have h1012 : (10 : ℤ) < 12 := by omega
    exact (decide_eq_decide.mp hb).mp h1012
  rcases hP with h | h | h <;> omega

/-- `sub₁ ≠ sub₂` — they differ at `e*` (F1 item 1: distinct depth-1 arity-4 types). -/
private theorem f2_sub_ne : f2sub1 ≠ f2sub2 := by
  intro h
  have hb : f2sub1.2 f2estar = f2sub2.2 f2estar := by rw [h]
  rw [f2_estar_in_sub1, f2_estar_not_in_sub2] at hb
  exact Bool.noConfusion hb

/-- The 2-variable prefix of the arity-5 witness environment is the fresh 2-type
    environment `[z, u]` (index bookkeeping for `nfk_take` at the probe points). -/
private theorem f2_cast2_env (h : 2 ≤ 5) (z u : ℤ) :
    (fun i => (Fin.cons z (Fin.cons u f2env3) : Fin 5 → F2M.carrier) (Fin.castLE h i)) =
      (Fin.cons z (fun _ => u) : Fin 2 → F2M.carrier) := by
  funext i
  match i with
  | ⟨0, _⟩ => rfl
  | ⟨1, _⟩ => rfl

/-- The realized fresh-variable 2-types at `u₁ = 12` and `u₂ = 4` coincide (report 05 F-B:
    both `¬P`, `P`-points strictly below — `{0, 10}` / `{0}` — and strictly above — `{20}` /
    `{10, 20}` — and every `¬P` cell inhabited on both sides). -/
private theorem f2_proj2_iff (χ' : NormalForm f2sig 0 2) :
    (∃ z : ℤ, nf_characteristic F2M 0 2 (Fin.cons z (fun _ => (12 : ℤ))) = χ') ↔
    (∃ z : ℤ, nf_characteristic F2M 0 2 (Fin.cons z (fun _ => (4 : ℤ))) = χ') := by
  constructor
  · rintro ⟨z, rfl⟩
    by_cases hp : (z = 0 ∨ z = 10 ∨ z = 20)
    · rcases lt_trichotomy z 12 with h | h | h
      · exact ⟨0, f2_char0_congr2 _ _ _ _ (iff_of_true (by decide) hp) (by decide)
          (iff_of_true (by decide) h) (iff_of_false (by decide) (by omega))⟩
      · exfalso; rcases hp with h' | h' | h' <;> omega
      · exact ⟨10, f2_char0_congr2 _ _ _ _ (iff_of_true (by decide) hp) (by decide)
          (iff_of_false (by decide) (by omega)) (iff_of_true (by decide) h)⟩
    · rcases lt_trichotomy z 12 with h | h | h
      · exact ⟨1, f2_char0_congr2 _ _ _ _ (iff_of_false (by decide) hp) (by decide)
          (iff_of_true (by decide) h) (iff_of_false (by decide) (by omega))⟩
      · exact ⟨4, f2_char0_congr2 _ _ _ _ (iff_of_false (by decide) hp) (by decide)
          (iff_of_false (by decide) (by omega)) (iff_of_false (by decide) (by omega))⟩
      · exact ⟨5, f2_char0_congr2 _ _ _ _ (iff_of_false (by decide) hp) (by decide)
          (iff_of_false (by decide) (by omega)) (iff_of_true (by decide) h)⟩
  · rintro ⟨z, rfl⟩
    by_cases hp : (z = 0 ∨ z = 10 ∨ z = 20)
    · rcases lt_trichotomy z 4 with h | h | h
      · exact ⟨0, f2_char0_congr2 _ _ _ _ (iff_of_true (by decide) hp) (by decide)
          (iff_of_true (by decide) h) (iff_of_false (by decide) (by omega))⟩
      · exfalso; rcases hp with h' | h' | h' <;> omega
      · exact ⟨20, f2_char0_congr2 _ _ _ _ (iff_of_true (by decide) hp) (by decide)
          (iff_of_false (by decide) (by omega)) (iff_of_true (by decide) h)⟩
    · rcases lt_trichotomy z 4 with h | h | h
      · exact ⟨1, f2_char0_congr2 _ _ _ _ (iff_of_false (by decide) hp) (by decide)
          (iff_of_true (by decide) h) (iff_of_false (by decide) (by omega))⟩
      · exact ⟨12, f2_char0_congr2 _ _ _ _ (iff_of_false (by decide) hp) (by decide)
          (iff_of_false (by decide) (by omega)) (iff_of_false (by decide) (by omega))⟩
      · exact ⟨13, f2_char0_congr2 _ _ _ _ (iff_of_false (by decide) hp) (by decide)
          (iff_of_false (by decide) (by omega)) (iff_of_true (by decide) h)⟩

/-- `u₁` and `u₂` share their complete depth-1 monadic point type `χ`: the fresh projections
    (`nfk_projFresh`, the Def-4.1 E[Σ]-atom channel) of `sub₁` and `sub₂` are EQUAL. Atom
    part: the shared atom layer (`f2_sub_atom_eq`); quant part: the realized fresh-2-type
    transfer (`f2_proj2_iff`) through `nfk_take`/`f2_take_char0`. -/
private theorem f2_sub_proj_eq : nfk_projFresh f2sub1 = nfk_projFresh f2sub2 := by
  have hcomp : ∀ (u : ℤ) (χ' : NormalForm f2sig 0 2),
      (∃ e : NormalForm f2sig 0 5,
        (nf_characteristic F2M 1 4 (Fin.cons u f2env3)).2 e = true ∧
          nfk_take (by omega) e = χ') ↔
      (∃ z : ℤ, nf_characteristic F2M 0 2 (Fin.cons z (fun _ => u)) = χ') := by
    intro u χ'
    constructor
    · rintro ⟨e, he, hproj⟩
      rw [show (nf_characteristic F2M 1 4 (Fin.cons u f2env3)).2 e = _ from
        f2char14_snd _ e] at he
      obtain ⟨z, hz⟩ := @of_decide_eq_true _ (Classical.dec _) he
      rw [f2_eval_iff_char] at hz
      subst hz
      rw [f2_take_char0, f2_cast2_env] at hproj
      exact ⟨z, hproj⟩
    · rintro ⟨z, hz⟩
      refine ⟨nf_characteristic F2M 0 5 (Fin.cons z (Fin.cons u f2env3)), ?_, ?_⟩
      · rw [show (nf_characteristic F2M 1 4 (Fin.cons u f2env3)).2 _ = _ from f2char14_snd _ _]
        exact @decide_eq_true _ (Classical.dec _)
          ⟨z, nf_characteristic_satisfies F2M 0 5 (Fin.cons z (Fin.cons u f2env3))⟩
      · rw [f2_take_char0, f2_cast2_env]
        exact hz
  refine Prod.ext ?_ ?_
  · show (fun a => f2sub1.1 (atomKind_castLE _ a)) = fun a => f2sub2.1 (atomKind_castLE _ a)
    rw [f2_sub_atom_eq]
  · funext χ'
    show decide (∃ e, f2sub1.2 e = true ∧ nfk_take (by omega) e = χ') =
      decide (∃ e, f2sub2.2 e = true ∧ nfk_take (by omega) e = χ')
    apply decide_eq_decide.mpr
    exact ((hcomp 12 χ').trans ((f2_proj2_iff χ').trans (hcomp 4 χ').symm))

/-- The env-restriction channel of the probe subs is the anchor 3-type: dropping the fresh
    variable from the arity-4 characteristic recovers `qnf.1` (Def 3.1 env channel). -/
private theorem f2_drop_char (u : ℤ) :
    nf0_dropFresh (nf_characteristic F2M 0 4 (Fin.cons u f2env3)) =
      nf_characteristic F2M 0 3 f2env3 := by
  funext a
  cases a with
  | pred p i =>
    simp only [nf0_dropFresh, mergeNF, skipFin_zero_succ]
    rfl
  | order i j h =>
    simp only [nf0_dropFresh, mergeNF, skipFin_zero_succ]
    rfl

/-- Off-fiber clause transfer: `qnf` and `qnf'` have equivalent atom-layer off-fiber falsity
    clauses — un-marking the ON-fiber `sub₂` (whose env restriction IS `qnf.1`,
    `f2_drop_char`) cannot affect any off-fiber sub. -/
private theorem f2_hoff :
    (∀ sub : NormalForm f2sig 1 4,
        nf0_dropFresh (NormalForm.atom_assgn sub) ≠ f2qnf.1 → f2qnf.2 sub = false) ↔
    (∀ sub : NormalForm f2sig 1 4,
        nf0_dropFresh (NormalForm.atom_assgn sub) ≠ f2qnf'.1 → f2qnf'.2 sub = false) := by
  constructor
  · intro h sub hne
    show (if sub = f2sub2 then false else f2qnf.2 sub) = false
    split
    · rfl
    · exact h sub hne
  · intro h sub hne
    by_cases hs : sub = f2sub2
    · exfalso
      apply hne
      rw [hs]
      show nf0_dropFresh (nf_characteristic F2M 0 4 (Fin.cons 4 f2env3)) =
        nf_characteristic F2M 0 3 f2env3
      exact f2_drop_char 4
    · have hh := h sub hne
      have hunf : f2qnf'.2 sub = (if sub = f2sub2 then false else f2qnf.2 sub) := rfl
      rw [hunf, if_neg hs] at hh
      exact hh

/-- Fiber-existential transfer: every `(zs, χ)` fold bit survives the `sub₂` un-marking —
    the shared-fiber companion `sub₁` (same ordering channel `f2_sub_atom_eq`, same fresh
    projection `f2_sub_proj_eq`, still marked `f2_sub1_marked`) keeps the `(zXW, χ)` bit
    alive; every other fiber is untouched. The machine-checked heart of F2: the carrier's
    fiber-existential read cannot see the un-marking (F1 item 2 at the F-B model). -/
private theorem f2_hb (zs : ZoneSpec 3) (χ : NormalForm f2sig 1 1) :
    (∃ sub : NormalForm f2sig 1 4, f2qnf.2 sub = true ∧
      nf0_zoneSpec (NormalForm.atom_assgn sub) = zs ∧ nfk_projFresh sub = χ) ↔
    (∃ sub : NormalForm f2sig 1 4, f2qnf'.2 sub = true ∧
      nf0_zoneSpec (NormalForm.atom_assgn sub) = zs ∧ nfk_projFresh sub = χ) := by
  constructor
  · rintro ⟨sub, hm, hz, hp⟩
    by_cases hs : sub = f2sub2
    · subst hs
      refine ⟨f2sub1, ?_, ?_, ?_⟩
      · show (if f2sub1 = f2sub2 then false else f2qnf.2 f2sub1) = true
        rw [if_neg f2_sub_ne]
        exact f2_sub1_marked
      · rw [← hz]
        show nf0_zoneSpec f2sub1.1 = nf0_zoneSpec f2sub2.1
        rw [f2_sub_atom_eq]
      · rw [← hp]
        exact f2_sub_proj_eq
    · refine ⟨sub, ?_, hz, hp⟩
      show (if sub = f2sub2 then false else f2qnf.2 sub) = true
      rw [if_neg hs]
      exact hm
  · rintro ⟨sub, hm, hz, hp⟩
    refine ⟨sub, ?_, hz, hp⟩
    have hunf : f2qnf'.2 sub = (if sub = f2sub2 then false else f2qnf.2 sub) := rfl
    rw [hunf] at hm
    by_cases hs : sub = f2sub2
    · rw [if_pos hs] at hm; exact Bool.noConfusion hm
    · rwa [if_neg hs] at hm

/-- **Carrier equality at the F-B pair**: the current depth-`k` V-carrier cannot distinguish
    `qnf` from `qnf'` — `bracketEndChar_kv_factors` (:3838) instantiated at the machine-checked
    channel agreements above. Holds for EVERY provider family `charF`. -/
private theorem f2_carrier_eq (charF : (j : Nat) → NormalForm f2sig j 1 → Formula) :
    bracketEndChar_kv f2atomMap f2surj charF 2 f2qnf =
      bracketEndChar_kv f2atomMap f2surj charF 2 f2qnf' :=
  bracketEndChar_kv_factors f2atomMap f2surj charF (k := 1) f2qnf f2qnf' rfl f2_hoff f2_hb

/-! ### F2 probe: no `w'` realizes `qnf'` in `M*` — the per-`w'` case analysis -/

/-- Depth-2 evaluation unfold at `qnf'` (definitional). -/
private theorem f2_eval2_qnf' (env : Fin 3 → F2M.carrier) :
    nf_eval_nf F2M 2 3 env f2qnf' ↔
      ((∀ a, atom_eval F2M env a ↔ f2qnf'.1 a = true) ∧
       (∀ sub : NormalForm f2sig 1 4,
         (∃ u : ℤ, nf_eval_nf F2M 1 4 (Fin.cons u env) sub) ↔ f2qnf'.2 sub = true)) :=
  Iff.rfl

/-- Fixed probe atoms, hoisted so their `Fin` proofs are fully elaborated at use sites
    (inline `⟨_, by omega⟩` indices leave metavariables that block `Fin.cons` reduction
    during unification). -/
private abbrev f2a3_xw : AtomKind f2sig 3 := .order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)
private abbrev f2a3_wt : AtomKind f2sig 3 := .order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)
private abbrev f2a3_xt : AtomKind f2sig 3 := .order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)
private abbrev f2a3_wx : AtomKind f2sig 3 := .order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)
private abbrev f2a3_tw : AtomKind f2sig 3 := .order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)
private abbrev f2a3_tx : AtomKind f2sig 3 := .order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)
private abbrev f2a3_P : AtomKind f2sig 3 := .pred () ⟨0, by omega⟩
private abbrev f2a4_xu : AtomKind f2sig 4 := .order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)
private abbrev f2a4_uw : AtomKind f2sig 4 := .order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)
private abbrev f2a4_wu : AtomKind f2sig 4 := .order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)
private abbrev f2a4_ut : AtomKind f2sig 4 := .order ⟨0, by omega⟩ ⟨3, by omega⟩ (by decide)

/-- Atom-bit transfer: a true atom bit of a depth-1 type equal to a characteristic type
    semantically holds in the characteristic's environment. -/
private theorem f2_bit_transfer {n : Nat} (σ : NormalForm f2sig 1 n)
    (env : Fin n → F2M.carrier) (h : σ = nf_characteristic F2M 1 n env)
    (a : AtomKind f2sig n) (hbit : σ.1 a = true) : atom_eval F2M env a :=
  @of_decide_eq_true _ (Classical.dec _) ((congrFun (congrArg Prod.fst h) a).symm.trans hbit)

/-- Quant-bit transfer: a true quant bit of a depth-1 arity-4 type equal to a characteristic
    type is realized in the characteristic's environment. -/
private theorem f2_qbit_transfer (σ : NormalForm f2sig 1 4)
    (env : Fin 4 → F2M.carrier) (h : σ = nf_characteristic F2M 1 4 env)
    (e : NormalForm f2sig 0 5) (hbit : σ.2 e = true) :
    ∃ z : ℤ, nf_eval_nf F2M 0 5 (Fin.cons z env) e :=
  @of_decide_eq_true _ (Classical.dec _)
    ((congrFun (congrArg Prod.snd h) e).symm.trans hbit)

/-- Facts about any fresh witness of `e*` over anchors `[u, w', 2, 18]`: it is a `P`-point
    strictly inside `(2, u)` (read off the depth-0 5-type equality entry by entry). -/
private theorem f2_estar_witness_facts (u w' z : ℤ)
    (hz : f2estar = nf_characteristic F2M 0 5
      (Fin.cons z (Fin.cons u (Fin.cons w' (Fin.cons 2 (fun _ => (18 : ℤ))))))) :
    ((z : ℤ) = 0 ∨ z = 10 ∨ z = 20) ∧ (2 : ℤ) < z ∧ z < u := by
  refine ⟨?_, ?_, ?_⟩
  · have hb := congrFun hz (.pred () ⟨0, by omega⟩)
    simp only [f2estar, nf_characteristic] at hb
    have h10 : (10 : ℤ) = 0 ∨ (10 : ℤ) = 10 ∨ (10 : ℤ) = 20 := by norm_num
    exact (decide_eq_decide.mp hb).mp h10
  · have hb := congrFun hz (.order ⟨3, by omega⟩ ⟨0, by omega⟩ (Fin.ne_of_val_ne (by decide)))
    simp only [f2estar, nf_characteristic] at hb
    have h210 : (2 : ℤ) < 10 := by omega
    exact (decide_eq_decide.mp hb).mp h210
  · have hb := congrFun hz (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (Fin.ne_of_val_ne Nat.zero_ne_one))
    simp only [f2estar, nf_characteristic] at hb
    have h1012 : (10 : ℤ) < 12 := by omega
    exact (decide_eq_decide.mp hb).mp h1012

/-- **`sub₁` forces `w' ≥ 12`**: any realization of `sub₁` over anchors `[w', 2, 18]` needs a
    fresh point `u ∈ (2, w')` whose gap `(2, u)` contains a `P`-point — so `u ≥ 11`, so
    `w' ≥ 12` (report 05 F-B, `w' ≤ 11` branch). -/
private theorem f2_sub1_forces (w' u : ℤ)
    (h : nf_eval_nf F2M 1 4
      (Fin.cons u (Fin.cons w' (Fin.cons 2 (fun _ => (18 : ℤ))))) f2sub1) :
    (2 : ℤ) < u ∧ u < w' ∧ (11 : ℤ) ≤ u := by
  rw [f2_eval_iff_char] at h
  have h2u : (2 : ℤ) < u := by
    have h212 : (2 : ℤ) < 12 := by omega
    have hbit : f2sub1.1 f2a4_xu = true := @decide_eq_true _ (Classical.dec _) h212
    exact f2_bit_transfer _ _ h f2a4_xu hbit
  have huw : u < w' := by
    have h1215 : (12 : ℤ) < 15 := by omega
    have hbit : f2sub1.1 f2a4_uw = true := @decide_eq_true _ (Classical.dec _) h1215
    exact f2_bit_transfer _ _ h f2a4_uw hbit
  obtain ⟨z, hze⟩ := f2_qbit_transfer _ _ h f2estar f2_estar_in_sub1
  rw [f2_eval_iff_char] at hze
  obtain ⟨hPz, h2z, hzu⟩ := f2_estar_witness_facts u w' z hze
  refine ⟨h2u, huw, ?_⟩
  rcases hPz with h0 | h0 | h0 <;> omega

/-- `τ`: the depth-1 arity-4 type of `[16, 15, 2, 18]` (fresh point in the `(w, t)` zone with
    an EMPTY `(w, u)` gap — the discreteness-sensitive entry for the `w' = 17` branch). -/
private noncomputable def f2tau : NormalForm f2sig 1 4 :=
  nf_characteristic F2M 1 4 (Fin.cons 16 f2env3)

/-- `τ ≠ sub₂` (they disagree on the order bit `u < w`). -/
private theorem f2_tau_ne : f2tau ≠ f2sub2 := by
  intro h
  have hb := congrFun (congrArg Prod.fst h) f2a4_uw
  have hn : ¬((16 : ℤ) < 15) := by omega
  have h415 : (4 : ℤ) < 15 := by omega
  have hL : f2tau.1 f2a4_uw = false := @decide_eq_false _ (Classical.dec _) hn
  have hR : f2sub2.1 f2a4_uw = true := @decide_eq_true _ (Classical.dec _) h415
  rw [hL, hR] at hb
  exact Bool.noConfusion hb

/-- `τ` is marked in `qnf` (realized at `u = 16`) hence in `qnf'` (`τ ≠ sub₂`). -/
private theorem f2_tau_marked' : f2qnf'.2 f2tau = true := by
  show (if f2tau = f2sub2 then false else f2qnf.2 f2tau) = true
  rw [if_neg f2_tau_ne, f2qnf_snd]
  exact @decide_eq_true _ (Classical.dec _)
    ⟨16, nf_characteristic_satisfies F2M 1 4 (Fin.cons 16 f2env3)⟩

/-- The `w'`-shift congruence for arity-5 types: transfer of a fresh 5-type between the
    `[4, 15, 2, 18]` anchors and the `[4, w', 2, 18]` anchors (`12 ≤ w' ≤ 16`), given the
    fresh points' matching cell data. -/
private theorem f2_congr5_wshift (w' z z' : ℤ)
    (hw : (12 : ℤ) ≤ w' ∧ w' ≤ 16)
    (hPz : (z = 0 ∨ z = 10 ∨ z = 20) ↔ (z' = 0 ∨ z' = 10 ∨ z' = 20))
    (hz4l : z < 4 ↔ z' < 4) (hz4r : 4 < z ↔ 4 < z')
    (hzw : z < 15 ↔ z' < w') (hwz : 15 < z ↔ w' < z')
    (hz2l : z < 2 ↔ z' < 2) (hz2r : 2 < z ↔ 2 < z')
    (hz18l : z < 18 ↔ z' < 18) (hz18r : 18 < z ↔ 18 < z') :
    nf_characteristic F2M 0 5
        (Fin.cons z (Fin.cons 4 (Fin.cons 15 (Fin.cons 2 (fun _ => (18 : ℤ)))))) =
      nf_characteristic F2M 0 5
        (Fin.cons z' (Fin.cons 4 (Fin.cons w' (Fin.cons 2 (fun _ => (18 : ℤ)))))) :=
  f2_char0_congr5 _ _ _ _ _ _ _ _ _ _
    hPz Iff.rfl (iff_of_false (by decide) (by omega)) Iff.rfl Iff.rfl
    hz4l hz4r hzw hwz hz2l hz2r hz18l hz18r
    (iff_of_true (by decide) (by omega)) (iff_of_false (by decide) (by omega))
    Iff.rfl Iff.rfl Iff.rfl Iff.rfl
    (iff_of_false (by decide) (by omega)) (iff_of_true (by decide) (by omega))
    (iff_of_true (by decide) (by omega)) (iff_of_false (by decide) (by omega))
    Iff.rfl Iff.rfl

/-- **`sub₂` is realized at every `w' ∈ [12, 16]`** (via `u = 4`): the depth-1 arity-4 type of
    `[4, w', 2, 18]` EQUALS `sub₂` — anchor configurations agree, and every realized fresh
    5-type transfers cell-by-cell (`f2_congr5_wshift`; the report's `12 ≤ w' ≤ 15` middle
    branch, extended to 16 where the `(w', 18)` cell is still inhabited). This settles the
    report's honest caveat: the per-entry type-match check SUCCEEDS on this range. -/
private theorem f2_sub2_transfer (w' : ℤ) (h12 : (12 : ℤ) ≤ w') (h16 : w' ≤ 16) :
    f2sub2 = nf_characteristic F2M 1 4
      (Fin.cons 4 (Fin.cons w' (Fin.cons 2 (fun _ => (18 : ℤ))))) := by
  have hw : (12 : ℤ) ≤ w' ∧ w' ≤ 16 := ⟨h12, h16⟩
  refine Prod.ext ?_ ?_
  · show nf_characteristic F2M 0 4 (Fin.cons 4 (Fin.cons 15 (Fin.cons 2 (fun _ => (18 : ℤ))))) =
      nf_characteristic F2M 0 4 (Fin.cons 4 (Fin.cons w' (Fin.cons 2 (fun _ => (18 : ℤ)))))
    exact f2_char0_congr4 _ _ _ _ _ _ _ _
      Iff.rfl (iff_of_false (by decide) (by omega)) Iff.rfl Iff.rfl
      (iff_of_true (by decide) (by omega)) (iff_of_false (by decide) (by omega))
      Iff.rfl Iff.rfl Iff.rfl Iff.rfl
      (iff_of_false (by decide) (by omega)) (iff_of_true (by decide) (by omega))
      (iff_of_true (by decide) (by omega)) (iff_of_false (by decide) (by omega))
      Iff.rfl Iff.rfl
  · funext e
    show (nf_characteristic F2M 1 4 (Fin.cons 4 f2env3)).2 e = _
    simp only [f2char14_snd]
    apply decide_eq_decide.mpr
    constructor
    · rintro ⟨z, hz⟩
      rw [f2_eval_iff_char] at hz
      by_cases hp : (z = 0 ∨ z = 10 ∨ z = 20)
      · -- P-points sit in shift-stable cells: identity witness
        refine ⟨z, ?_⟩
        rw [f2_eval_iff_char, hz]
        rcases hp with h0 | h0 | h0 <;>
          (refine f2_congr5_wshift w' z z hw ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_ <;> omega)
      · rcases le_or_gt z 4 with hc | hc
        · refine ⟨z, ?_⟩
          rw [f2_eval_iff_char, hz]
          refine f2_congr5_wshift w' z z hw ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_ <;> omega
        · rcases lt_trichotomy z 15 with hc2 | hc2 | hc2
          · refine ⟨5, ?_⟩
            rw [f2_eval_iff_char, hz]
            refine f2_congr5_wshift w' z 5 hw ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_ <;> omega
          · refine ⟨w', ?_⟩
            rw [f2_eval_iff_char, hz]
            refine f2_congr5_wshift w' z w' hw ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_ <;> omega
          · rcases lt_or_ge z 18 with hc3 | hc3
            · refine ⟨17, ?_⟩
              rw [f2_eval_iff_char, hz]
              refine f2_congr5_wshift w' z 17 hw ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_ <;> omega
            · refine ⟨z, ?_⟩
              rw [f2_eval_iff_char, hz]
              refine f2_congr5_wshift w' z z hw ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_ <;> omega
    · rintro ⟨z, hz⟩
      rw [f2_eval_iff_char] at hz
      by_cases hp : (z = 0 ∨ z = 10 ∨ z = 20)
      · refine ⟨z, ?_⟩
        rw [f2_eval_iff_char, hz]
        rcases hp with h0 | h0 | h0 <;>
          (refine Eq.symm (f2_congr5_wshift w' z z hw ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_) <;> omega)
      · rcases le_or_gt z 4 with hc | hc
        · refine ⟨z, ?_⟩
          rw [f2_eval_iff_char, hz]
          refine Eq.symm (f2_congr5_wshift w' z z hw ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_) <;> omega
        · rcases lt_trichotomy z w' with hc2 | hc2 | hc2
          · refine ⟨5, ?_⟩
            rw [f2_eval_iff_char, hz]
            refine Eq.symm (f2_congr5_wshift w' 5 z hw ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_) <;> omega
          · refine ⟨15, ?_⟩
            rw [f2_eval_iff_char, hz]
            refine Eq.symm (f2_congr5_wshift w' 15 z hw ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_) <;> omega
          · rcases lt_or_ge z 18 with hc3 | hc3
            · refine ⟨17, ?_⟩
              rw [f2_eval_iff_char, hz]
              refine Eq.symm (f2_congr5_wshift w' 17 z hw ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_) <;> omega
            · refine ⟨z, ?_⟩
              rw [f2_eval_iff_char, hz]
              refine Eq.symm (f2_congr5_wshift w' z z hw ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_) <;> omega

/-- **No `w'` realizes `qnf'` in `M*`** (report 05 F-B case analysis, machine-checked): the
    atom layer pins `w' ∈ (2, 18) \ P`; `sub₁`'s marked bit forces `w' ≥ 12`
    (`f2_sub1_forces`); on `12 ≤ w' ≤ 16` the UN-marked `sub₂` is realized at `u = 4`
    (`f2_sub2_transfer`); at `w' = 17` the marked `τ` needs a fresh point in the EMPTY
    `(17, 18)` gap. -/
private theorem f2_no_witness :
    ¬ ∃ w' : ℤ, nf_eval_nf F2M 2 3
      (Fin.cons w' (Fin.cons 2 (fun _ => (18 : ℤ)))) f2qnf' := by
  rintro ⟨w', hw⟩
  obtain ⟨hA, hQ⟩ := (f2_eval2_qnf' _).mp hw
  -- Step 1: atom-layer constraints on w'
  have h2w : (2 : ℤ) < w' := by
    have h215 : (2 : ℤ) < 15 := by omega
    have hbit : f2qnf'.1 f2a3_xw = true := @decide_eq_true _ (Classical.dec _) h215
    exact (hA f2a3_xw).mpr hbit
  have hw18 : w' < 18 := by
    have h1518 : (15 : ℤ) < 18 := by omega
    have hbit : f2qnf'.1 f2a3_wt = true := @decide_eq_true _ (Classical.dec _) h1518
    exact (hA f2a3_wt).mpr hbit
  have hPw : ¬((w' : ℤ) = 0 ∨ w' = 10 ∨ w' = 20) := by
    intro hcontra
    have hae : atom_eval F2M (Fin.cons w' (Fin.cons 2 (fun _ => (18 : ℤ)))) f2a3_P := hcontra
    have hbit := (hA f2a3_P).mp hae
    have h15P : ¬((15 : ℤ) = 0 ∨ (15 : ℤ) = 10 ∨ (15 : ℤ) = 20) := by omega
    have hfalse : f2qnf'.1 f2a3_P = false :=
      @decide_eq_false _ (Classical.dec _) h15P
    rw [hfalse] at hbit
    exact Bool.noConfusion hbit
  -- Step 2: sub₁'s marked bit forces w' ≥ 12
  have hsub1' : f2qnf'.2 f2sub1 = true := by
    show (if f2sub1 = f2sub2 then false else f2qnf.2 f2sub1) = true
    rw [if_neg f2_sub_ne]
    exact f2_sub1_marked
  obtain ⟨u, hu⟩ := (hQ f2sub1).mpr hsub1'
  obtain ⟨h2u, huw, h11u⟩ := f2_sub1_forces w' u hu
  -- Step 3: split 12 ≤ w' ≤ 16 vs w' = 17
  by_cases h17 : w' = 17
  · -- τ needs a fresh point in the empty (17, 18) gap
    obtain ⟨v, hv⟩ := (hQ f2tau).mpr f2_tau_marked'
    rw [f2_eval_iff_char] at hv
    have hwv : w' < v := by
      have h1516 : (15 : ℤ) < 16 := by omega
      have hbit : f2tau.1 f2a4_wu = true := @decide_eq_true _ (Classical.dec _) h1516
      exact f2_bit_transfer _ _ hv f2a4_wu hbit
    have hv18 : v < 18 := by
      have h1618 : (16 : ℤ) < 18 := by omega
      have hbit : f2tau.1 f2a4_ut = true := @decide_eq_true _ (Classical.dec _) h1618
      exact f2_bit_transfer _ _ hv f2a4_ut hbit
    omega
  · -- 12 ≤ w' ≤ 16: the un-marked sub₂ is realized at u = 4
    have h1216 : (12 : ℤ) ≤ w' ∧ w' ≤ 16 := by omega
    have hreal : ∃ u₀ : ℤ, nf_eval_nf F2M 1 4
        (Fin.cons u₀ (Fin.cons w' (Fin.cons 2 (fun _ => (18 : ℤ))))) f2sub2 := by
      refine ⟨4, ?_⟩
      rw [f2_eval_iff_char]
      exact f2_sub2_transfer w' h1216.1 h1216.2
    have hmarked := (hQ f2sub2).mp hreal
    have hfalse : f2qnf'.2 f2sub2 = false := by
      show (if f2sub2 = f2sub2 then false else f2qnf.2 f2sub2) = false
      rw [if_pos rfl]
    rw [hfalse] at hmarked
    exact Bool.noConfusion hmarked

/-- **Finding F2 verdict theorem (F2 CONFIRMED)**: the UZ/SZ-relativized `k = 2` correctness
    statement for the CURRENT carrier `bracketEndChar_kv` (:3630) is FALSE — for EVERY
    provider family `charF`. See the F2 verdict record below for the four-element defect
    breakdown and routing consequence. -/
theorem f2_relativized_refutation
    (charF : (j : Nat) → NormalForm f2sig j 1 → Formula) :
    ¬ (∀ (qnf : NormalForm f2sig 2 3),
        qnf.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true →
        qnf.1 (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true →
        qnf.1 (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = true →
        qnf.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false →
        qnf.1 (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false →
        qnf.1 (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = false →
        ∀ (M : OrderedMonadicStructure f2sig),
          semantic_prior_UZ M f2atomMap → semantic_prior_SZ M f2atomMap →
          ∀ (x t : M.carrier),
            ((bracketEndChar_kv f2atomMap f2surj charF 2 qnf).holds M f2atomMap x t ↔
              ∃ w : M.carrier,
                nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)) := by
  intro h
  -- the six bracket-zone order bits of the (shared) atom layer
  have h215 : (2 : ℤ) < 15 := by omega
  have h1518 : (15 : ℤ) < 18 := by omega
  have h218 : (2 : ℤ) < 18 := by omega
  have hn152 : ¬((15 : ℤ) < 2) := by omega
  have hn1815 : ¬((18 : ℤ) < 15) := by omega
  have hn182 : ¬((18 : ℤ) < 2) := by omega
  have hxy : f2qnf.1 f2a3_xw = true := @decide_eq_true _ (Classical.dec _) h215
  have hyt : f2qnf.1 f2a3_wt = true := @decide_eq_true _ (Classical.dec _) h1518
  have hxt : f2qnf.1 f2a3_xt = true := @decide_eq_true _ (Classical.dec _) h218
  have hyx : f2qnf.1 f2a3_wx = false := @decide_eq_false _ (Classical.dec _) hn152
  have hty : f2qnf.1 f2a3_tw = false := @decide_eq_false _ (Classical.dec _) hn1815
  have htx : f2qnf.1 f2a3_tx = false := @decide_eq_false _ (Classical.dec _) hn182
  -- instantiate the statement at qnf and at qnf' (same atom layer), in M* at (x, t) = (2, 18)
  have h1 := h f2qnf hxy hyt hxt hyx hty htx F2M f2_UZ f2_SZ 2 18
  have h2 := h f2qnf' hxy hyt hxt hyx hty htx F2M f2_UZ f2_SZ 2 18
  -- qnf is realized at w = 15, so the carrier holds at (2, 18)
  have hholds : (bracketEndChar_kv f2atomMap f2surj charF 2 f2qnf).holds F2M f2atomMap 2 18 :=
    h1.mpr ⟨15, nf_characteristic_satisfies F2M 2 3 f2env3⟩
  -- the carrier cannot see the un-marking; transport and extract a qnf'-witness
  rw [f2_carrier_eq charF] at hholds
  exact f2_no_witness (h2.mp hholds)

/-! ## Task 309 Phase 13.0 finding F2 (CONFIRMED): UZ/SZ relativization alone does NOT rescue
the Phase-12 carrier at `k = 2` — statement surgery (Phase 13.1) is necessary but NOT
sufficient; the full ladder 13.2 → 13.3 → 13.4 proceeds

**Def 3.1 evidence first (rule N3)**: Rabinovich's α_j/β_j are ONE-VARIABLE quantifier-free
formulas over the current (round-enriched) vocabulary (Def 3.1, PDF p.4), so the arity-4
residual `[x_1, w, x, t]` whose in-fiber markings the F1/F2 counterexamples toggle had no
Rabinovich counterpart — it is a Lean `nf_eval_nf` arity-growth artifact, and the fold restores
Def-4.1 fidelity only if its E[Σ]-atom channel keeps the joint content the enriched vocabulary
carries (Def 4.1, PDF p.5, read at depth `k` per the **p.6 note** — rule N2; Prop 4.3 (p.6) is
cited ONLY for "the residual is ∨∃∀ over E[Σ] atoms", realized locally via the fold, not via
literal structural induction). Relativizing the correctness statement to Prior structures
(`semantic_prior_UZ`/`semantic_prior_SZ`, PriorDefs:22/:33) does not repair that channel: the
checked refutation `f2_relativized_refutation` (above) instantiates the F1 mechanism inside a
Prior model.

**Machine-checked refutation record (mirrors the F1 four-element bar; NO analysis residue —
every step below is a checked lemma in this section)**:

1. **Counterexample**: `M* = (ℤ, <)`, `P = {0, 10, 20}` (report 05 F-B). `f2_UZ`/`f2_SZ`:
   `M*` satisfies BOTH Prior hypotheses (nonempty `ℤ`-subsets bounded below/above have
   least/greatest elements) — the escape route that disqualified F1's `(ℚ, <)` model (finite
   `P` fails UZ) is closed. `qnf :=` the depth-2 characteristic 3-type of `[w, x, t] =
   [15, 2, 18]`, realized at `w = 15`; `qnf' := qnf` with the `u₂ = 4` sub un-marked.
   `f2_carrier_eq`: the carrier CANNOT distinguish them — `bracketEndChar_kv_factors` (:3838)
   at the checked channel agreements `f2_sub_atom_eq` (ordering + env channels), `f2_sub_proj_eq`
   (fresh point-type channel: `u₁ = 12` and `u₂ = 4` share their complete depth-1 1-type),
   `f2_hoff`, `f2_hb` (the marked `sub₁` keeps every fiber bit alive), with `f2sub1 ≠ f2sub2`
   witnessed by the entry `e*` = "`P z` and `x < z < u`" (`f2_estar_in_sub1` /
   `f2_estar_not_in_sub2` — the `(2, 4)` gap has no `P`-point). `f2_no_witness`: NO `w'`
   realizes `qnf'` — the atom layer pins `w' ∈ (2, 18) \ P`; `f2_sub1_forces` pins `w' ≥ 12`
   (the marked `u₁`-sub needs a `P`-point inside `(2, u)`, so `u ≥ 11`); `f2_sub2_transfer`
   realizes the UN-marked `sub₂` at `u = 4` for every `12 ≤ w' ≤ 16` (the report-05 honest
   caveat resolved AFFIRMATIVELY: the per-entry type-match check SUCCEEDS, cell-by-cell via
   `f2_congr5_wshift`); `w' = 17` dies on `τ`'s empty `(w', t) = (17, 18)` gap
   (`f2_tau_marked'`). The two instances of the relativized `↔` at `(qnf, qnf')` are jointly
   contradictory — for EVERY provider family `charF` (no provider hypothesis is even needed:
   the mechanism never evaluates the carrier's formulas, only its factorization).
2. **Current behavior**: unchanged from F1 item 2 — at successor depth the carrier reads
   `qnf.2` ONLY through the atom-layer off-fiber Prop and the fiber-existential fold bits
   (:3661-3665; machine-checked factorization :3838).
3. **Required behavior**: unchanged from F1 item 3 — the quant layer of `nf_eval_nf` is a
   per-sub BICONDITIONAL over depth-`k` arity-4 subs; at `k ≥ 2` a fiber holds ≥ 2 subs
   differing in deeper joint layers (D7, NfEFold:373) that the carrier cannot see.
4. **Isolation**: the discreteness worry (report 05 F-B caveat: gap-emptiness is
   depth-1-visible in `ℤ`) is REAL but only reshapes which witness kills which `w'`-range
   (`sub₂` covers `12-16` — one more point than the report's density sketch — and the
   discrete-gap type `τ` covers `17`); it does not rescue the carrier. UZ/SZ buys attained
   first/last occurrences (PriorINF:224), NOT the joint deeper structure of same-fiber subs.
   The repair remains the v6 per-sub enriched carrier (`bracketEndChar_kvE`, Phases
   13.2-13.4) — NOT a hypothesis patch, and NOT a gate patch (F1 item 4 stands: no kv-gate
   strengthening).

**Bracket framing citation (rule N1)**: nothing here re-frames the bracket — the carrier under
refutation keeps the two-fixed-endpoint `(z_0, z_1)` framing of **Lemma 3.2(2) (PDF p.4) + the
§5 bracket notation (PDF p.7)**, with **Prop 3.5 (PDF p.5)** cited only for the
one-free-variable ∃-witness→Until/Since folding mechanism.

**Verdict and routing (plan v6 Phase 13.0 three-way gate)**: **F2 CONFIRMED** — the
UZ/SZ-relativized `k = 2` correctness statement for `bracketEndChar_kv` is FALSE
(`f2_relativized_refutation`; `lean_verify` axioms exactly
`[propext, Classical.choice, Quot.sound]`). Routing consequence: proceed to Phase 13.1
(statement surgery: `ExistProviders` + `BracketCarrierCorrectVPrior`) AND the FULL ladder
13.2 → 13.3 → 13.4 → 14. Do NOT collapse to surgery-only; do NOT strengthen the kv gate. -/

/-! ## Task 309 Phase 13.1 (R3b statement surgery): `ExistProviders` + `BracketCarrierCorrectVPrior` + relativized k≤1 lifts

The corrected R3b interface (report 05 Pillar 1; **v6 amendment A1, report 05 §d**): after
F1/F2 refuted the *unconditional* depth-`k` correctness of the fiber-projected carrier at
k ≥ 2, the correctness TARGET is amended — the predicate gains the Prior hypotheses
`semantic_prior_UZ`/`semantic_prior_SZ` (PriorDefs:22/:33) and provider conditionality (an
`ExistProviders` bundle), exactly the hypotheses the `:351` consumer carries (F-A,
KampPrior:216-223). This amends the TARGET STATEMENT only, not G6's carrier shape; the
unconditional `BracketCarrierCorrectV` (:1873) remains valid and landed at k ≤ 1. The ∀k
quantifier is NOT restated here: it lives in KampPrior's `Nat.rec` (F-A).

Bracket framing citation (rule N1 split): the two-fixed-endpoint `(z_0, z_1)` framing is
**Lemma 3.2(2) (PDF p.4) + the §5 bracket notation `[α_0, …, α_n](z_0, z_1)` (PDF p.7)**;
**Prop 3.5 (PDF p.5)** is cited ONLY for the one-free-variable ∃-witness→Until/Since folding
mechanism. -/

/-- **Provider bundle** (task 309 Phase 13.1; report 05 Pillar 1, amendment A1 §d):
single-anchor existential converters at depth `k`, all arities, correct on Prior (UZ/SZ)
structures — what the outer recursion supplies at KampPrior:351 (recursive converters at all
depths ≤ k, the KampPrior:273 pattern). Per-round provider threading per **Cor 5.4** (the
`F_i` are TL formulas, PDF p.7/p.9); the UZ/SZ-conditional correctness field mirrors the
landed `nf_succ_char_formula_correct` hypothesis pattern (KampPrior:81 — template, read-only). -/
structure ExistProviders (sig : MonadicSignature) (atomMap : Formula → sig.preds)
    (k : Nat) where
  existF : (n : Nat) → NormalForm sig k (n + 1) → Formula
  correct : ∀ (n : Nat) (sub : NormalForm sig k (n + 1)) (M : OrderedMonadicStructure sig)
      (h_UZ : semantic_prior_UZ M atomMap) (h_SZ : semantic_prior_SZ M atomMap)
      (t : M.carrier),
      temporal_truth M atomMap t (existF n sub) ↔
        ∃ env : Fin n → M.carrier, nf_eval_nf M k (n + 1) (insertEnv env t) sub

/-- **UZ/SZ-relativized carrier correctness — the corrected R3b target** (task 309 Phase 13.1;
report 05 Pillar 1, **amendment A1 §d**). The Prior-relativized variant of
`BracketCarrierCorrectV` (:1873, untouched — kept for the landed k ≤ 1 statements): the
carrier's `VVecEA2.holds` at the FIXED anchor pair `(x, t)` is equivalent to a bracket
witness `w` realizing the arity-3 depth-`k` evaluation, for every Prior (UZ/SZ) structure and
every `qnf` in the `x < w' < t` bracket zone (the six atom-layer order hypotheses, k0-mirror
form :1586-1595, stated uniformly via `NormalForm.atom_assgn` — defeq to `qnf` at `k = 0` and
to `qnf.1` at successor depth). `{x, t}` are the FIXED endpoints (Lemma 3.2(2), PDF p.4 + §5
bracket notation, PDF p.7 — rule N1 split; Prop 3.5, PDF p.5, cited only for the
∃-witness→Until/Since folding mechanism); `w` is a bracket witness (G4, G6 as amended).
Provider conditionality enters at USE sites: the k ≥ 2 carrier (`bracketEndChar_kvE`,
Phase 13.2) is parameterized by an `ExistProviders` bundle, so this predicate applied to it
is provider-conditional in exactly the A1 sense. -/
def BracketCarrierCorrectVPrior {sig : MonadicSignature} (atomMap : Formula → sig.preds)
    {k : Nat} (carrier : BracketEndCharCarrierV sig k) : Prop :=
  ∀ (qnf : NormalForm sig k 3)
    (h_xy : qnf.atom_assgn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    (h_yt : qnf.atom_assgn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_xt : qnf.atom_assgn (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_yx : qnf.atom_assgn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (h_ty : qnf.atom_assgn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
    (h_tx : qnf.atom_assgn (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (M : OrderedMonadicStructure sig)
    (h_UZ : semantic_prior_UZ M atomMap) (h_SZ : semantic_prior_SZ M atomMap)
    (x t : M.carrier),
    (carrier qnf).holds M atomMap x t ↔
      ∃ w : M.carrier, nf_eval_nf M k 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf

/-- **`k = 0` relativized lift** (task 309 Phase 13.1). Weakening of the landed unconditional
`bracketEndChar_kv_correct_zero` (:3788 — lifted, NOT re-proved): an unconditional `↔` implies
the UZ/SZ-conditional one, so the proof just drops `h_UZ`/`h_SZ`. At `k = 0` the
`NormalForm.atom_assgn` order hypotheses are definitionally the landed `qnf (.order …)` ones.
Citations ride the consumed lemma (rule N1 split there); no chain step is shortcut (G5). -/
theorem bracketEndChar_kv_correct_zero_prior {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charF : (j : Nat) → NormalForm sig j 1 → Formula) :
    BracketCarrierCorrectVPrior atomMap (bracketEndChar_kv atomMap h_surj charF 0) :=
  fun qnf h_xy h_yt h_xt h_yx h_ty h_tx M _h_UZ _h_SZ x t =>
    bracketEndChar_kv_correct_zero atomMap h_surj charF qnf
      h_xy h_yt h_xt h_yx h_ty h_tx M x t

/-- **`k = 1` relativized lift** (task 309 Phase 13.1). Weakening of the landed
`bracketEndChar_kv_correct_one` (:3816 — lifted, NOT re-proved), dropping `h_UZ`/`h_SZ`; the
depth-0 provider agreement `h0` (satisfied by the Phase-14 instantiation by construction,
KampPrior:397 at depth 0) is retained. At `k = 1` the `NormalForm.atom_assgn` order hypotheses
are definitionally the landed `qnf.1 (.order …)` ones. Citations ride the consumed lemma
(rule N1 split there); no chain step is shortcut (G5). -/
theorem bracketEndChar_kv_correct_one_prior {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charF : (j : Nat) → NormalForm sig j 1 → Formula)
    (h0 : charF 0 = nf_depth0_char_formula atomMap h_surj) :
    BracketCarrierCorrectVPrior atomMap (bracketEndChar_kv atomMap h_surj charF 1) :=
  fun qnf h_xy h_yt h_xt h_yx h_ty h_tx M _h_UZ _h_SZ x t =>
    bracketEndChar_kv_correct_one atomMap h_surj charF h0 qnf
      h_xy h_yt h_xt h_yx h_ty h_tx M x t

/-! ## Task 309 Phase 13.2: per-sub enriched successor-depth carrier `bracketEndChar_kvE`

The redesigned successor-depth carrier (report 05 Pillar 2 — finding F1 item 3's "required
behavior"), ADDITIVE alongside `bracketEndChar_kv` (:3667, untouched — it stays as the landed
k ≤ 1 instance and F1 exhibit). The defining change is the **information channel**: every read
of `qnf.2` is **per-sub** — `qnf.2 σ` at an individual `σ : NormalForm sig k 4` — never through
`(ZoneSpec 3 × NormalForm sig k 1)` fiber existentials (the refuted F1 channel, factorization
machine-checked at `bracketEndChar_kv_factors` :3851). Two per-sub features defeat that
factorization:

1. **Per-sub witness slots** (rule N4/N5): the interior-positive enumerations `S_L`/`S_R` list
   positive SUBS `σ` (each `qnf.2 σ = true`, zone `zXW`/`zWT`), one bracket witness slot per
   positive sub — distinct positive subs need distinct realizing points (`nf_eval_nf`'s per-sub
   biconditional plus uniqueness, `nf_eval_unique` NormalForm:245), so per-sub slots encode the
   multiplicity the fiber-existential read collapsed ("one witness per positive pair").
2. **Per-sub joint literals at the right endpoint** (Def 3.1 enriched vocabulary, PDF p.4
   md:61-74): each positive sub `σ` contributes the literal `P.existF 3 σ` to `epR`. Since
   `insertEnv env t` places the anchor at the LAST position (NfDepth0Generalized:42) and the
   quant layer of `nf_eval_nf M (k+1) 3 [w,x,t]` evaluates subs at `Fin.cons u [w,x,t]` =
   `[u,w,x,t]` (fresh at 0, `t` at 3), the fixed endpoint `t` IS the position-3 anchor:
   `temporal_truth M t (P.existF 3 σ) ↔ ∃ e : Fin 3 → M.carrier, nf_eval_nf M k 4 [e0,e1,e2,t] σ`
   (`ExistProviders.correct`, :4856), of which the honest per-sub obligation
   `∃ u, nf_eval_nf M k 4 [u,w,x,t] σ` is the `e = (u,w,x)` instance. These are Rabinovich's
   per-round enriched formulas: Def 3.1's α/β at round k+1 range over the CURRENT vocabulary,
   which after round k includes the previous round's TL-definable content (Cor 5.4's `F_i` are
   TL formulas, PDF p.7 md:154-157) — realized here as provider-built formulas in existing
   `TemporalPred` slots (report 05 F-C: enrichment is a read-channel change, NOT a codomain
   change; codomain stays `VVecEA2`, anchors stay `{x, t}`, G2/G4).

**Vocabulary at depth > 0 is provider-built throughout**: point characteristics are
`charK := P.existF 0` (arity-1 instance of the bundle — `insertEnv (elim0) t = fun _ => t`, so
`P.existF 0 χ` is the depth-`k` unary characteristic of `χ`), witness-slot point types are
`⟨charK (nfk_projFresh σ)⟩` (the fresh channel of Def 4.1, PDF p.5, at depth `k` — :3511),
joint literals are `P.existF 3 σ`. Only the atom-layer endpoint/`w` base types use the depth-0
`nf_depth0_char_formula` (the only self-type `qnf.1` carries syntactically), as in `kv_body`.

**Exclusion-literal design record (this phase's design deliverable, plan v6 Phase 13.2)**:
negative subs contribute NO uniform joint literal. A candidate literal `¬(P.existF 3 σ)` at `t`
for negative `σ` would OVER-exclude: `P.existF 3 σ` existentially rebinds the `w`/`x` positions,
so it can hold at the honest `t` through fake anchors while `σ` is honestly negative — the
uniform-negation gap of report 05 F-D (the EANegationClosure lemmas are model-dependent
existentials and may be consumed only proof-side). Negative-sub content therefore enters the
carrier ONLY through the honest-safe unary exclusions — `hasPos`-guarded segment conjunctions
`segL`/`segR` and the `lit`-biconditional endpoint/`w` families, where `hasPos zs χ` (fiber
occupancy) is COMPUTED from the per-sub positive list (`(posIn zs).any (nfk_projFresh · = χ)`),
not read from `qnf.2` through fibers. The remaining negative-sub obligations are Phase 13.3's
work, discharged proof-side via `prior_hasAttainedINF h_UZ` (PriorINF:224) + the
EANegationClosure stack — exactly the F-D discipline.

**Inner existentials (Lemma 3.4 / G6-as-amended)**: a positive sub's own inner existentials
(its quant layer at depth k-1) ride the provider formula `P.existF 3 σ` — the Phase-14
instantiation of the bundle is precisely the Lemma-3.4 (PDF p.5 md:84-85) flattened TL form in
which each absorbed existential joined the prefix one round earlier. They do not occupy slots
of THIS bracket: the A1 bundle supplies converters at depth `k` only, so slot-level flattening
of depth-(k-1) content is outside the provider scope; witness growth in this bracket is
per-positive-sub (G6-as-amended licenses the growth; the §5 bracket `[α_0,…,α_n](z_0,z_1)`
PDF p.7 md:127-132 is its printed shape).

**A2 discipline (per-sub read + inside-out fold discharge)**: the per-sub correctness
obligations of Phase 13.3/13.4 are discharged INSIDE-OUT — at the k=2 instance each positive
sub's inner layer is depth-0 and unfolds through `nf_eval_depth1_fold_iff` below (which consumes
the general fold engine `nf_quant_layer_fold_iff`, NfEFold:391, itself built on the arity-5
split-kit bijection `nf0_split_assemble`, NfEFold:235); at symbolic k the same layer is
provider-mediated (`P.correct`). NO navigated arity-3/4 characteristic chains, NO third anchor:
`VVecEA2.holds` keeps the two-point signature (VecEAFormula:276), Lemma 3.2(2)'s ≤2-anchor cap
(PDF p.4 md:76-79) remains a TYPE-level invariant.

Citation split (rule N1): the two-fixed-endpoint `(z_0, z_1)` framing is **Lemma 3.2(2) (PDF
p.4) + the §5 bracket notation `[α_0,…,α_n](z_0,z_1)` (PDF p.7)**; **Prop 3.5 (PDF p.5)** is
cited ONLY for the one-free-variable ∃-witness→Until/Since folding mechanism (the Since/Until
literals in `epL`/`epR`). Per rule N2, **Prop 4.3 (PDF p.6)** is cited ONLY for "the residual
is ∨∃∀ over E[Σ] atoms"; the inside-out iteration is the **Def 4.1 p.6 note** read at full
strength (G5 as extended by plan v6: chain steps at k ≥ 2 additionally cite Def 3.1's
enriched-vocabulary reading and Cor 5.4's TL-formula providers). -/

/-- The seven zone specs consistent with the bracket order `x < w < t` over the env
    `[w, x, t]` (Def 3.1 ordering channel, PDF pp.4-5: disjunctions range only over consistent
    order types). Literal list identical to the RHS of `k1v_zone_consistent` (:2065), in the
    order `zPastX, zAtX, zXW, zAtW, zWT, zAtT, zFutT`. Named (rather than a `let`) so the
    Phase-13.2 gate is stateable outside the carrier body. -/
private def kvE_consistent : ZoneSpec 3 → Prop := fun zs =>
  zs = Fin.cons (true, false) (Fin.cons (true, false) (fun _ => (true, false))) ∨
  zs = Fin.cons (true, false) (Fin.cons (false, false) (fun _ => (true, false))) ∨
  zs = Fin.cons (true, false) (Fin.cons (false, true) (fun _ => (true, false))) ∨
  zs = Fin.cons (false, false) (Fin.cons (false, true) (fun _ => (true, false))) ∨
  zs = Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (true, false))) ∨
  zs = Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (false, false))) ∨
  zs = Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (false, true)))

/-- **Per-sub two-conjunct gate** for the Phase-13.2 carrier: (i) atom-layer off-fiber honesty
    (subs whose atom layer does not restrict to `r` are marked false — the `kv` gate conjunct,
    :3675, unchanged in shape) and (ii) PER-SUB order-conflict falsity (any sub whose own
    atom-layer zone is inconsistent with `x < w < t` is marked false) — the per-sub reading of
    `kv_body`'s fiber-level conjunct (:3637). Both conjuncts read `qnf.2` only at individual
    subs (A2). -/
private def kvE_gate {sig : MonadicSignature} {k : Nat}
    (r : NormalForm sig 0 3) (q : NormalForm sig k 4 → Bool) : Prop :=
  (∀ σ : NormalForm sig k 4,
      nf0_dropFresh (NormalForm.atom_assgn σ) ≠ r → q σ = false) ∧
  (∀ σ : NormalForm sig k 4,
      ¬ kvE_consistent (nf0_zoneSpec (NormalForm.atom_assgn σ)) → q σ = false)

open Classical in
/-- **Per-sub successor body** of the Phase-13.2 enriched carrier (private builder, factored
    per Risk R6 like `bracketFromLists` :1896 / `kv_body` :3581). Fully parametric in the three
    formula providers — `charBase` (depth-0 atom-layer projections), `charK` (depth-`k` unary
    characteristics; instantiated at `P.existF 0`), `exF` (per-sub joint configuration formulas
    anchored at the position-3 point; instantiated at `P.existF 3`) — the atom layer `r`, and
    the quant assignment `q` read PER-SUB. Construction record and citations: see the section
    header above. Structure relative to `kv_body` (:3581): the zone constants, `lit`, endpoint
    base types, `segL`/`segR`/`ptW` shapes and the arrangement disjunction are verbatim; the
    fold-bit parameter `b` is REPLACED by per-sub enumeration (`pos`, `posIn`) with derived
    fiber occupancy `hasPos`, the witness slots are per-SUB (`ptSub`, one slot per positive
    interior sub), and `epR` gains the per-sub joint literals `exF σ`. Gate-failure branch:
    the empty disjunction `⟨[]⟩` (its `holds` is `False`) — Rabinovich's empty disjunction over
    inconsistent order types. -/
private noncomputable def kvE_body {sig : MonadicSignature} {k : Nat}
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig k 1 → Formula)
    (exF : NormalForm sig k 4 → Formula)
    (r : NormalForm sig 0 3)
    (q : NormalForm sig k 4 → Bool) : VVecEA2 :=
  -- Zone-spec constants relative to env `[w, x, t]` under the bracket order `x < w < t`
  -- (Def 3.1 ordering channel, PDF p.4), verbatim from `kv_body` (:3588-3600).
  let ltz : Bool × Bool := (true, false)
  let eqz : Bool × Bool := (false, false)
  let gtz : Bool × Bool := (false, true)
  let mk3 : Bool × Bool → Bool × Bool → Bool × Bool → ZoneSpec 3 := fun pw px pt =>
    Fin.cons pw (Fin.cons px (fun _ => pt))
  let zPastX := mk3 ltz ltz ltz    -- x_1 < x  (< w < t)
  let zAtX   := mk3 ltz eqz ltz    -- x_1 = x
  let zXW    := mk3 ltz gtz ltz    -- x < x_1 < w
  let zAtW   := mk3 eqz gtz ltz    -- x_1 = w
  let zWT    := mk3 gtz gtz ltz    -- w < x_1 < t
  let zAtT   := mk3 gtz gtz eqz    -- x_1 = t
  let zFutT  := mk3 gtz gtz gtz    -- t < x_1
  -- PER-SUB positive enumeration (A2): the ONLY reads of `q` in the whole body are `q σ`
  -- at individual subs, here and in the gate. No fiber-existential read occurs (F1 item 3).
  let pos : List (NormalForm sig k 4) := Finset.univ.toList.filter (fun σ => q σ)
  let zone : NormalForm sig k 4 → ZoneSpec 3 := fun σ =>
    nf0_zoneSpec (NormalForm.atom_assgn σ)
  let posIn : ZoneSpec 3 → List (NormalForm sig k 4) := fun zs =>
    pos.filter (fun σ => decide (zone σ = zs))
  -- Fiber occupancy DERIVED from the per-sub positive list (honest-safe unary channel for
  -- the exclusion literals — see the exclusion-literal design record in the section header).
  let hasPos : ZoneSpec 3 → NormalForm sig k 1 → Bool := fun zs χ =>
    (posIn zs).any (fun σ => decide (nfk_projFresh σ = χ))
  let allTypes : List (NormalForm sig k 1) := Finset.univ.toList
  -- Biconditional literal at an anchor (Prop 3.5 folding mechanism, PDF p.5).
  let lit : Bool → Formula → Formula := fun bit f => if bit then f else f.neg
  -- Endpoint base types (the FIXED `z_0 = x`, `z_1 = t`: Lemma 3.2(2) PDF p.4 + §5 bracket
  -- PDF p.7 — rule N1 split).
  let xType : TemporalPred := ⟨charBase (nf_x_proj3 r)⟩
  let tType : TemporalPred := ⟨charBase (nf_t_proj3 r)⟩
  let epL : TemporalPred :=
    ⟨formula_conjList
      (xType.formula
        :: (allTypes.map fun χ => lit (hasPos zPastX χ) (Formula.snce (charK χ) Formula.top))
        ++ (allTypes.map fun χ => lit (hasPos zAtX χ) (charK χ)))⟩
  -- `epR` carries, beyond the `kv_body` unary families, the PER-SUB joint literals `exF σ`
  -- for EVERY positive sub (any zone): `t` is the position-3 `insertEnv` anchor of the
  -- per-sub obligation env `[u, w, x, t]` (Def 3.1 enriched vocabulary, PDF p.4 md:61-74;
  -- Cor 5.4 `F_i`, PDF p.7). Positive subs only — see the exclusion-literal design record.
  let epR : TemporalPred :=
    ⟨formula_conjList
      (tType.formula
        :: (allTypes.map fun χ => lit (hasPos zAtT χ) (charK χ))
        ++ (allTypes.map fun χ => lit (hasPos zFutT χ) (Formula.untl (charK χ) Formula.top))
        ++ (pos.map exF))⟩
  -- Segment types: universal exclusion of the unoccupied interior-zone fibers (honest-safe
  -- unary exclusions; the per-sub negative content is Phase 13.3's proof-side work).
  let segL : TemporalPred :=
    ⟨formula_conjList (allTypes.map fun χ =>
      if hasPos zXW χ then Formula.top else (charK χ).neg)⟩
  let segR : TemporalPred :=
    ⟨formula_conjList (allTypes.map fun χ =>
      if hasPos zWT χ then Formula.top else (charK χ).neg)⟩
  -- Witness point type at `w`: depth-0 base type + equality-zone biconditionals ONLY
  -- (rule N4 — no interior chains; interior-positive content rides the witness slots below).
  let ptW : TemporalPred :=
    ⟨formula_conjList
      (charBase (nf_y_proj r)
        :: (allTypes.map fun χ => lit (hasPos zAtW χ) (charK χ)))⟩
  -- PER-SUB witness slot point type: the depth-`k` unary characteristic of the sub's fresh
  -- channel (Def 4.1 E[Σ]-atom at depth `k`, PDF p.5; `nfk_projFresh` :3511). The sub's
  -- JOINT content rides its `epR` literal `exF σ`.
  let ptSub : NormalForm sig k 4 → TemporalPred := fun σ => ⟨charK (nfk_projFresh σ)⟩
  -- Interior-positive enumerations: per-SUB (one witness slot per positive interior sub —
  -- distinct positive subs require distinct realizing points, `nf_eval_unique`).
  let S_L : List (NormalForm sig k 4) := posIn zXW
  let S_R : List (NormalForm sig k 4) := posIn zWT
  -- One disjunct per arrangement (rule N5): positive interior subs occupy WITNESS slots
  -- ordered between the fixed endpoints (§5 bracket, PDF p.7; Lemma 3.4, PDF p.5); the
  -- model-dependent witness ORDER is carried by the finite disjunction over arrangements.
  let mkDisjunct : List (NormalForm sig k 4) → List (NormalForm sig k 4) → Σ n, VecEA2 n :=
    fun lL lR =>
      ⟨(lL.map ptSub).length + 1 + (lR.map ptSub).length,
        { endpointLeft := epL
          endpointRight := epR
          bracket := bracketFromLists (lL.map ptSub) ptW (lR.map ptSub) segL segR }⟩
  @dite _ (kvE_gate r q) (Classical.dec _)
    (fun _ =>
      { disjuncts :=
          S_L.permutations.flatMap fun lL =>
            S_R.permutations.map fun lR => mkDisjunct lL lR })
    (fun _ => { disjuncts := [] })

/-- Gate-failure computation for the per-sub body: if the gate fails, the body returns the
    empty disjunction (Rabinovich's empty disjunction over inconsistent order types) — the
    `kv_body_gate_fail` (:3697) mirror for Phase 13.3's off-gate branch. -/
private theorem kvE_body_gate_fail {sig : MonadicSignature} {k : Nat}
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig k 1 → Formula)
    (exF : NormalForm sig k 4 → Formula)
    (r : NormalForm sig 0 3)
    (q : NormalForm sig k 4 → Bool)
    (h : ¬ kvE_gate r q) :
    kvE_body charBase charK exF r q = { disjuncts := [] } := by
  simp only [kvE_body]
  exact dif_neg h

/-- **The per-sub enriched successor-depth V-carrier** (task 309 Phase 13.2; report 05
    Pillar 2). See the section header above for the full construction record, the A2 per-sub
    read discipline, the N1/N2 citation splits, the Def 3.1 enriched-vocabulary reading
    (PDF p.4 md:61-74), and the exclusion-literal design record. Depth alignment (report 05
    Pillar 3 note): the carrier needed at depth `k` is this definition at `k = j + 1` with
    providers at depth `j = k - 1`; depth 0 stays `bracketEndChar_k0` (:1580) and depth 1
    stays the landed k1v instance (:1940) — this definition serves k ≥ 2. Correctness
    (`BracketCarrierCorrectVPrior` applied to it — provider-conditional in exactly the A1
    sense, :4875) is Phase 13.3 (k = 2 GO/NO-GO gate) and Phase 13.4 (symbolic k). -/
noncomputable def bracketEndChar_kvE {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    {k : Nat} (P : ExistProviders sig atomMap k) :
    BracketEndCharCarrierV sig (k + 1) :=
  fun qnf =>
    kvE_body (nf_depth0_char_formula atomMap h_surj)
      (fun χ => P.existF 0 χ) (fun σ => P.existF 3 σ) qnf.1 qnf.2

/-- **Concrete k=2 instance bridge** (task 309 Phase 13.2 deliverable): at depth-1 providers
    (`P : ExistProviders sig atomMap 1` — the k=2 carrier `BracketEndCharCarrierV sig 2`), the
    carrier is DEFINITIONALLY the per-sub body at `charBase = nf_depth0_char_formula`,
    `charK = P.existF 0`, `exF = P.existF 3`, atom layer `qnf.1`, and the per-sub read of
    `qnf.2` over `σ : NormalForm sig 1 4`. Pure `rfl` — no semantics (the
    `bracketEndChar_k1v_eq_kv_body` :3684 house pattern). Phase 13.3 rewrites with this to
    expose the body, then discharges each positive sub's obligation inside-out via
    `nf_eval_depth1_fold_iff` below (A2). -/
theorem bracketEndChar_kvE_two_eq {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (P : ExistProviders sig atomMap 1)
    (qnf : NormalForm sig 2 3) :
    bracketEndChar_kvE atomMap h_surj P qnf =
      kvE_body (nf_depth0_char_formula atomMap h_surj)
        (fun χ => P.existF 0 χ) (fun σ => P.existF 3 σ) qnf.1 qnf.2 := rfl

/-- **Depth-1 per-sub obligation decomposition** (task 309 Phase 13.2 — the exact literal
    shapes of the k=2 instance, fixed via the fold engine): a depth-1 arity-`n` evaluation
    splits into its atom layer plus the INSIDE-OUT folded quant layer — zone-bounded MONADIC
    depth-0 existentials over `(ZoneSpec n × NormalForm sig 0 1)` against the arity-`(n+1)`
    subs reassembled by `nf0_assemble`, plus the off-fiber falsity clause. Direct wrapper of
    `nf_quant_layer_fold_iff` (NfEFold:391 — Prop 4.3's innermost ∃-fold, PDF p.6, cited per
    rule N2 only for "the residual is ∨∃∀ over E[Σ] atoms"; the split-kit bijection
    `nf0_split_assemble` NfEFold:235 rides inside the engine — at `n = 4` this is the arity-5
    split of the plan's Phase-13.2 acceptance). Phase 13.3 consumes this at `n = 4`, env
    `[u, w, x, t]`, `σ : NormalForm sig 1 4` — each positive sub's inner layer is depth-0 at
    the k=2 instance, so this lemma IS the A2 inside-out discharge shape (Def 4.1 p.6 note). -/
theorem nf_eval_depth1_fold_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) {n : Nat}
    (env : Fin n → M.carrier) (σ : NormalForm sig 1 n) :
    nf_eval_nf M 1 n env σ ↔
      ((∀ a : AtomKind sig n, atom_eval M env a ↔ σ.1 a = true) ∧
       ((∀ (zs : ZoneSpec n) (χ : NormalForm sig 0 1),
           (∃ v : M.carrier, zoneHolds M env zs v ∧
             nf_eval_nf M 0 1 (fun _ => v) χ) ↔
             σ.2 (nf0_assemble zs χ σ.1) = true) ∧
        (∀ τ : NormalForm sig 0 (n + 1), nf0_dropFresh τ ≠ σ.1 → σ.2 τ = false))) := by
  constructor
  · rintro ⟨h_atom, h_quant⟩
    exact ⟨h_atom, (nf_quant_layer_fold_iff M env σ.1 h_atom σ.2).mp h_quant⟩
  · rintro ⟨h_atom, h_fold⟩
    exact ⟨h_atom, (nf_quant_layer_fold_iff M env σ.1 h_atom σ.2).mpr h_fold⟩

/-! ## Task 309 Phase 13.3: k=2 correctness gate for `bracketEndChar_kvE` —
DECISION GATE → **NO-GO (exclusion-content encoding — the F-D gap materializes)**
(verdict-mirror of the R2 GO record :3407-3445 and the F1/F2 defect records)

**Lead evidence (Def 3.1, PDF p.4 md:61-74 — rule N3).** In Rabinovich's exists-forall
formulas, EVERY existentially chosen point is pinned by the bracket's own interval
decomposition: it sits between the two fixed endpoints `(z_0, z_1)` with its point type
`α_j` AND the interval types `β_j`, `β_{j+1}` on BOTH adjacent sub-intervals — the joint
content of each chosen point relative to the anchors is carried by the decomposition
itself. The kvE per-sub joint literal `P.existF 3 σ` (the 13.2 enrichment channel) instead
pins σ's joint claim ONLY at the right endpoint `t`: `insertEnv` places the provider anchor
LAST, and the provider's `∃ env : Fin 3 → M.carrier` existentially REBINDS the u/w/x
positions. Def 3.1 never produces this configuration. In the paper, per-round joint and
negative content at round k+1 is carried by **Prop 4.2 (PDF p.6 md:100-101)** uniform
negation-closure formulas — built by **Lemma 5.1 (md:134-135)** via **Lemma 5.3's INF
splitting (md:137-152)** — which are CARRIER-SIDE finite disjunctions (Cor 5.4's `F_i` are
TL formulas, md:154-157), not per-model facts.

**Machine probe (soundness direction, k=2 instance).** The probe drove
`(bracketEndChar_kvE atomMap h_surj P qnf).holds M atomMap x t` through
`bracketEndChar_kvE_two_eq` (:5167), the arrangement destructuring, and
`k1v_bracket_extract` (:2150) to the per-sub positive obligation, extracted the joint
literal from `epR`, and applied `P.correct 3 σ M h_UZ h_SZ t`. Captured crux goal state:

    e : Fin 3 → M.carrier
    he : nf_eval_nf M 1 (3 + 1) (insertEnv e t) σ
    ⊢ ∃ x_1, nf_eval_nf M 1 (3 + 1) (Fin.cons x_1 (Fin.cons w (Fin.cons x fun _ ↦ t))) σ

Every other hypothesis in context (`hepL`/`hepR`/`hptWe`/`hLwit`/`hRwit`/`hLgap`/`hRgap`)
carries fresh-channel UNARY content only (`P.existF 0` families over `nfk_projFresh`).
Attempted transfers (lean_multi_attempt): `exact ⟨e 0, he⟩` — type mismatch
`insertEnv e t ≠ Fin.cons (e 0) [w,x,t]`; `simpa [insertEnv, Fin.cons]` — same mismatch;
the funext bridge leaves residuals `e 1 = w` and `e 2 = x` with NO hypothesis relating the
provider-chosen `e` to the honest anchors. The proof-side negation stack
(`prior_hasAttainedINF` PriorINF:224 + `neg_interval_formula` EANegationClosure:401,
`neg_bounded_exists` :492, `neg_vecEA2`/`neg_2var_vec_ea` :646/:720,
`neg_orderedPointsExist_is_vbracket` EANegation:347) cannot connect: each concludes a
model-dependent `∃ v : VBracketFormula/VVecEA2, v.holds M atomMap z0 z1` with no link to
the FIXED σ's realization — exactly the report 05 F-D caveat (model-dependent existentials,
carrier fixed before `M`).

**Counterexample (defect bar, four elements — the statement is FALSE, not merely hard).**
Take `M = ℤ` (Prior UZ/SZ: every nonempty subset of ℤ bounded below/above has a
min/max, so ALL first/last occurrences are attained), preds `p = {0}`, `r = {13}`;
`x = 10`, `t = 20`. Write `char e := nf_characteristic M 1 4 e` and let
`c_u := char [u, 15, 10, 20]` (the honest w=15 subs). Set `qnf.1 := ` depth-0 layer of
`[15, 10, 20]`, and `qnf.2 := ` the honest w=15 assignment EXCEPT
`qnf.2 (c 14) := false` and `qnf.2 σ'' := true` where `σ'' := char [14, 16, 11, 20]`
(a fake-anchored tuple sharing only `t`; on-fiber: depth-0 layer of `[16, 11, 20]` =
depth-0 layer of `[15, 10, 20]`; zone `zXW`; fresh depth-1 type = type(14) = type(15)).
LHS HOLDS at `(10, 20)`: middle witness 15; slots for
`S_L = {c 11, c 12, c 13, σ''}` at 11, 12, 13, 14 (fresh types τ_c, τ_c, τ_b, τ_a);
`σ''`'s joint literal holds at 20 via its fake realization `[14, 16, 11, 20]`; every unary
family is honest. RHS FAILS for every `w' ∈ (10, 20)`: `w' ≤ 13` kill the zAtW sub
(`(10, w')` lacks `r`); `w' = 14` kills `c 12` (no τ_c-fresh `u` gives `(u, 14)` both an
`r`-point and a non-`r` point); `w' = 15` kills `σ''` (`(10, u) ∋ r` forces `u = 14`, but
`(14, 15) = ∅` against σ''s nonempty middle interval); `w' ∈ {16, 17, 18}` realize the
`c 14`-form at `u = w' − 1` against `qnf.2 (c 14) = false`; `w' = 19` kills the zAtW sub
(`(19, 20) = ∅`). **Current behavior**: the carrier's only per-sub joint channel is the
`t`-anchored provider literal; a dishonest positive sub is carrier-indistinguishable from
honest content (same depth-0 fiber, zone, fresh type, and `t`-anchored joint truth).
**Required behavior**: per-sub joint claims pinned against the honest anchor pair — in
Rabinovich, by Prop 4.2's uniform negation/exclusion disjunctions at round k+1.
**Isolation**: the gap is confined to the exclusion/joint-pinning channel deliberately
deferred by the 13.2 exclusion-literal design record (:4956-4967); no new obstruction in
the 13.2 body arises (gate, zones, slots, unary families, and arrangement machinery all
behaved exactly as at k=1); the counterexample is provider-independent (only `P.correct`
is consumed), so the failure survives ANY correct depth-1 bundle, including Phase 14's.

**Verdict: 13.3 = NO-GO, exclusion-content encoding.** The named fallback of plan v6
applies: `/revise 309` (v7) inserting **Phase 13.2b — uniformization**: construct the
needed uniform per-sub exclusion/pinning formulas as FINITE DISJUNCTIONS over the
finitely-generated candidate family (subs, arrangements, point-type sets are all finite at
each depth — report 05 §c contingency; the carrier-side realization of Lemma 5.3/5.1 +
Prop 4.2 per the G5 v6 extension), then re-run this gate ONCE. KD3 discipline held: the
13.2 carrier and the 13.1 predicate are UNCHANGED (this record is the phase's only
artifact — no partial theorem, no sorry); escalation fence C3 held: no anchor growth;
the uniform-backward EANegation sorries (:1090/:1249) were NOT touched. -/

/-! ## Task 309 Phase 13.25: Uniformization — finite-disjunction pinning/exclusion channels
    + carrier extension `bracketEndChar_kvE'` (the v6-named "Phase 13.2b")

**F3 response (channel-(i)/(ii) plan).** The 13.3 gate returned NO-GO: the per-sub joint literal
`P.existF 3 σ` anchors σ's joint claim ONLY at `t` (the `insertEnv` last position), with the
`u/w/x` positions existentially REBOUND, so the crux residuals `e 1 = w`, `e 2 = x` are
unpinnable; the provider-independent `M = ℤ` counterexample shows the gap hits POSITIVE subs
(joint pinning) as well as negative subs (exclusion). This section realizes plan v6's named
fallback — the CARRIER-SIDE uniformization — as finite disjunctions over the finitely-generated
candidate family (subs, arrangements, point-type sets are all finite at each depth via `Fintype
(NormalForm sig k n)`, NormalForm:167; report 05 §c). Two channels:

  - **(i) Positive-sub joint PINNING** (`kvE_pinArrangements`/`kvE_pinDisjunct`): σ's witness `u`
    appears as EXTRA bracket witness slots pinned by the bracket's own interval decomposition
    (Def 3.1, PDF p.4 md:61-74 — every existentially chosen point carries its point type `α_j`
    and the interval types `β_j`, `β_{j+1}` on both adjacent sub-intervals), disjoined over the
    finite candidate family of consistent order-type placements (`kvE_consistentZones`). Each
    disjunct realizes σ's fresh depth-`k` type positionally within the honest bracket (Lemma 5.3
    INF splitting, md:137-152, per disjunct — N1 split), replacing the refuted single-anchor
    `t`-rebound. Carrier-side, not provider-side (v7 Amendment F3): a single-anchor provider
    literal cannot express the relative-position claims tying σ's realization to the bracket's
    own structural points, and the outer recursion supplies single-anchor converters only (F-A),
    so a strengthened bundle would be circular with the two-anchor characteristic under
    construction. This is Rabinovich's own device (Def 3.1 pins chosen points through the
    interval decomposition; Prop 4.2/Lemma 5.1/5.3 place per-round content carrier-side as finite
    disjunctions, Cor 5.4's `F_i` being TL formulas, md:154-157).

  - **(ii) Negative-sub EXCLUSION** (`kvE_exclConj`): for each interior sub the carrier marks
    false, the negation of the finite disjunction of that sub's realization patterns over the
    same candidate family (Lemma 5.1 bracket negation md:134-135 + Prop 4.2 negation closure
    md:100-101, carrier-side), guarded honest-safe by fiber occupancy (`hasPos`) exactly as the
    13.2 unary segment exclusions (:5089-5096) — an honest realization always has a witnessing
    positive sub in the fiber, so the guard leaves it `⊤`.

**Additivity (KD3).** All 13.2 deliverables are retained BYTE-IDENTICAL: `kvE_consistent`
(:5000), `kvE_gate` (:5015), `kvE_body` (:5036 — the structural template, copied here verbatim
and EXTENDED, never edited), `kvE_body_gate_fail` (:5130), `bracketEndChar_kvE` (:5150),
`bracketEndChar_kvE_two_eq` (:5167). The `ExistProviders`/`BracketCarrierCorrectVPrior` predicate
is UNCHANGED (13.1, KD3). `bracketEndChar_kvE'` is a NEW carrier alongside the landed one.

**Non-consumption statement (blocker criterion).** This construction derives uniformity from the
FINITENESS of the candidate family (report 05 §c), NOT from the uniform-backward negation lemmas:
it consumes NEITHER `EANegation :1090` NOR `:1249`, and no definition below references them. Nor
does it read `qnf.2` fiber-existentially (F1): every read is `q σ` at an individual sub. Anchors
stay the two FIXED endpoints `{x, t}` (`VVecEA2`/two-point `VVecEA2.holds`, G4/G6); the pin
placements are WITNESSES between them, never a third anchor (G2). Guards enforced: G2, G4,
G6-as-amended, A1, A2, v7 Amendment F3, N1, N4, N5.

**Correctness scope.** This is the CONSTRUCTION phase; the soundness/completeness direction of
the extended carrier is Phase 13.35's GO/NO-GO gate. The construction is well-typed, additive,
finite, per-sub, sorry-free; whether the channel content is SUFFICIENT for the k=2 soundness
direction is 13.35's machine determination (the primary 13.35 risk, flagged in the handoff). -/

/-- **Pin arrangement** (channel (i), task 309 Phase 13.25): one pinned placement of a positive
    interior sub against the honest anchor triple `(w, x, t)`. `witnessZone` is the order type of
    the sub's witness `u` relative to `(w, x, t)` (one of the seven consistent Def-3.1 order
    types, `kvE_consistentZones`); `witnessType` is the depth-`k` point type carried by the
    witness slot. Finitely enumerable by construction: both fields range over finite index sets
    (the explicit `kvE_consistentZones` list; `NormalForm sig k 1` is a `Fintype`, NormalForm:167
    — report 05 §c). -/
private structure kvE_PinArrangement (sig : MonadicSignature) (k : Nat) where
  witnessZone : ZoneSpec 3
  witnessType : NormalForm sig k 1

/-- The seven consistent order-type placements of a witness `u` relative to `(w, x, t)` under the
    bracket order `x < w < t` (Def 3.1 ordering channel, PDF pp.4-5; the disjuncts of
    `kvE_consistent` :5000 in list form). Explicit `List` — finite by construction (no `Fintype`
    machinery on the carrier path). -/
private def kvE_consistentZones : List (ZoneSpec 3) :=
  let ltz : Bool × Bool := (true, false)
  let eqz : Bool × Bool := (false, false)
  let gtz : Bool × Bool := (false, true)
  let mk3 : Bool × Bool → Bool × Bool → Bool × Bool → ZoneSpec 3 := fun pw px pt =>
    Fin.cons pw (Fin.cons px (fun _ => pt))
  [mk3 ltz ltz ltz, mk3 ltz eqz ltz, mk3 ltz gtz ltz, mk3 eqz gtz ltz,
   mk3 gtz gtz ltz, mk3 gtz gtz eqz, mk3 gtz gtz gtz]

/-- Computable enumeration of pin arrangements for a sub `σ` (channel (i)): σ's fresh depth-`k`
    type (`nfk_projFresh σ`, :3511 — the honest witness type read parametrically from σ, no
    `σ.2` destructuring) placed at each of the finitely many consistent order-type zones. Explicit
    `List` builder (`map` over `kvE_consistentZones`) — the N5 finite disjunction over
    arrangements; the honest disjunct is the one at `nf0_zoneSpec (NormalForm.atom_assgn σ)`. -/
private noncomputable def kvE_pinArrangements {sig : MonadicSignature} {k : Nat}
    (σ : NormalForm sig k 4) : List (kvE_PinArrangement sig k) :=
  kvE_consistentZones.map (fun z => ⟨z, nfk_projFresh σ⟩)

/-- **Per-arrangement pin content** (channel (i)): the EXTRA bracket witness slot (point type)
    and the interval-type segment conjunct realizing σ's fresh-type claim positionally within the
    honest bracket for pin arrangement `a` (Def 3.1 md:61-74 + Lemma 5.3 md:137-152 per disjunct,
    N1 split). Returns `(pointSlots, segConjuncts)`: `pointSlots` splice into the bracket witness
    list; `segConjuncts` are the adjacent interval-type predicates. Instantiated at the k=2 gate
    with `charBase = nf_depth0_char_formula …`, `charK = P.existF 0` — no new provider. -/
private noncomputable def kvE_pinDisjunct {sig : MonadicSignature} {k : Nat}
    (_charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig k 1 → Formula)
    (_σ : NormalForm sig k 4)
    (a : kvE_PinArrangement sig k) : List TemporalPred × List TemporalPred :=
  ([⟨charK a.witnessType⟩], [⟨charK a.witnessType⟩])

/-- **Uniform exclusion formula** for a sub `σ` the carrier marks false (channel (ii)): the
    negation of the finite disjunction of σ's realization patterns over the candidate family
    `kvE_pinArrangements σ` (Lemma 5.1 md:134-135 + Prop 4.2 md:100-101, carrier-side). Read at
    a bracket segment; conjoined honest-safe (guarded by fiber occupancy on insertion, see
    `kvE'_body`). Consumes neither EANegation :1090 nor :1249 (finiteness, not uniform-backward
    negation). -/
private noncomputable def kvE_exclConj {sig : MonadicSignature} {k : Nat}
    (_charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig k 1 → Formula)
    (σ : NormalForm sig k 4) : Formula :=
  Formula.neg (Bimodal.Metalogic.WeakCanonical.Separation.formula_disjList
    ((kvE_pinArrangements σ).map (fun a => charK a.witnessType)))

open Classical in
/-- **Per-sub enriched successor body with uniformization channels** (task 309 Phase 13.25 —
    the additive extension of `kvE_body` :5036). Structure IS `kvE_body` verbatim (zone constants,
    gate, `pos`/`posIn`/`hasPos`, `epL`, `ptW`, `ptSub`, the arrangement disjunction) with two
    ADDITIONS: (1) channel (i) — per positive interior sub, `kvE_pinDisjunct` point slots spliced
    into the witness lists via `kvE_pinArrangements` (extra bracket witnesses, N5 finite
    disjunction, larger index); (2) channel (ii) — `kvE_exclConj` conjuncts for the marked-false
    interior subs conjoined honest-safe into `segL`/`segR`. ALL 13.2 channels (gate, unary
    families, the `t`-anchored `exF σ`, per-sub `ptSub` slots) are retained verbatim. Parametric
    in `k` (never depth-baked); the gate-failure branch is the empty disjunction. See the section
    header for the full construction record and citations. -/
private noncomputable def kvE'_body {sig : MonadicSignature} {k : Nat}
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig k 1 → Formula)
    (exF : NormalForm sig k 4 → Formula)
    (r : NormalForm sig 0 3)
    (q : NormalForm sig k 4 → Bool) : VVecEA2 :=
  let ltz : Bool × Bool := (true, false)
  let eqz : Bool × Bool := (false, false)
  let gtz : Bool × Bool := (false, true)
  let mk3 : Bool × Bool → Bool × Bool → Bool × Bool → ZoneSpec 3 := fun pw px pt =>
    Fin.cons pw (Fin.cons px (fun _ => pt))
  let zPastX := mk3 ltz ltz ltz
  let zAtX   := mk3 ltz eqz ltz
  let zXW    := mk3 ltz gtz ltz
  let zAtW   := mk3 eqz gtz ltz
  let zWT    := mk3 gtz gtz ltz
  let zAtT   := mk3 gtz gtz eqz
  let zFutT  := mk3 gtz gtz gtz
  let pos : List (NormalForm sig k 4) := Finset.univ.toList.filter (fun σ => q σ)
  -- Interior subs the carrier marks false (channel (ii) domain): NOT in `pos`, per-sub read.
  let neg : List (NormalForm sig k 4) := Finset.univ.toList.filter (fun σ => !q σ)
  let zone : NormalForm sig k 4 → ZoneSpec 3 := fun σ =>
    nf0_zoneSpec (NormalForm.atom_assgn σ)
  let posIn : ZoneSpec 3 → List (NormalForm sig k 4) := fun zs =>
    pos.filter (fun σ => decide (zone σ = zs))
  let negIn : ZoneSpec 3 → List (NormalForm sig k 4) := fun zs =>
    neg.filter (fun σ => decide (zone σ = zs))
  let hasPos : ZoneSpec 3 → NormalForm sig k 1 → Bool := fun zs χ =>
    (posIn zs).any (fun σ => decide (nfk_projFresh σ = χ))
  let allTypes : List (NormalForm sig k 1) := Finset.univ.toList
  let lit : Bool → Formula → Formula := fun bit f => if bit then f else f.neg
  let xType : TemporalPred := ⟨charBase (nf_x_proj3 r)⟩
  let tType : TemporalPred := ⟨charBase (nf_t_proj3 r)⟩
  let epL : TemporalPred :=
    ⟨formula_conjList
      (xType.formula
        :: (allTypes.map fun χ => lit (hasPos zPastX χ) (Formula.snce (charK χ) Formula.top))
        ++ (allTypes.map fun χ => lit (hasPos zAtX χ) (charK χ)))⟩
  let epR : TemporalPred :=
    ⟨formula_conjList
      (tType.formula
        :: (allTypes.map fun χ => lit (hasPos zAtT χ) (charK χ))
        ++ (allTypes.map fun χ => lit (hasPos zFutT χ) (Formula.untl (charK χ) Formula.top))
        ++ (pos.map exF))⟩
  -- Channel (ii) exclusion conjunct at an interior zone `zs`: negate each marked-false sub's
  -- realization patterns, guarded honest-safe by fiber occupancy (`hasPos`) exactly as the 13.2
  -- unary exclusions — an occupied fiber leaves the conjunct `⊤`, so honest realizations survive.
  let exclAt : ZoneSpec 3 → List Formula := fun zs =>
    (negIn zs).map fun σ =>
      if hasPos zs (nfk_projFresh σ) then Formula.top else kvE_exclConj charBase charK σ
  let segL : TemporalPred :=
    ⟨formula_conjList
      ((allTypes.map fun χ =>
        if hasPos zXW χ then Formula.top else (charK χ).neg) ++ exclAt zXW)⟩
  let segR : TemporalPred :=
    ⟨formula_conjList
      ((allTypes.map fun χ =>
        if hasPos zWT χ then Formula.top else (charK χ).neg) ++ exclAt zWT)⟩
  let ptW : TemporalPred :=
    ⟨formula_conjList
      (charBase (nf_y_proj r)
        :: (allTypes.map fun χ => lit (hasPos zAtW χ) (charK χ)))⟩
  let ptSub : NormalForm sig k 4 → TemporalPred := fun σ => ⟨charK (nfk_projFresh σ)⟩
  -- Channel (i): per positive interior sub, the EXTRA pin witness slots (point types) from the
  -- finite family of arrangements (`kvE_pinArrangements` → `kvE_pinDisjunct` point component),
  -- appended alongside the sub's own `ptSub` slot (§5 bracket witnesses between the fixed
  -- endpoints — Def 3.1 md:61-74). The finite disjunction over arrangements rides the flattened
  -- witness list; the honest arrangement is the one at `zone σ`.
  let pinSlots : NormalForm sig k 4 → List TemporalPred := fun σ =>
    (kvE_pinArrangements σ).flatMap (fun a => (kvE_pinDisjunct charBase charK σ a).1)
  let slotsFor : List (NormalForm sig k 4) → List TemporalPred := fun l =>
    l.flatMap (fun σ => ptSub σ :: pinSlots σ)
  let S_L : List (NormalForm sig k 4) := posIn zXW
  let S_R : List (NormalForm sig k 4) := posIn zWT
  let mkDisjunct : List (NormalForm sig k 4) → List (NormalForm sig k 4) → Σ n, VecEA2 n :=
    fun lL lR =>
      ⟨(slotsFor lL).length + 1 + (slotsFor lR).length,
        { endpointLeft := epL
          endpointRight := epR
          bracket := bracketFromLists (slotsFor lL) ptW (slotsFor lR) segL segR }⟩
  @dite _ (kvE_gate r q) (Classical.dec _)
    (fun _ =>
      { disjuncts :=
          S_L.permutations.flatMap fun lL =>
            S_R.permutations.map fun lR => mkDisjunct lL lR })
    (fun _ => { disjuncts := [] })

/-- Gate-failure computation for the enriched body (the `kvE_body_gate_fail` :5130 mirror): if
    the gate fails, the enriched body is the empty disjunction. -/
private theorem kvE'_body_gate_fail {sig : MonadicSignature} {k : Nat}
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig k 1 → Formula)
    (exF : NormalForm sig k 4 → Formula)
    (r : NormalForm sig 0 3)
    (q : NormalForm sig k 4 → Bool)
    (h : ¬ kvE_gate r q) :
    kvE'_body charBase charK exF r q = { disjuncts := [] } := by
  simp only [kvE'_body]
  exact dif_neg h

/-- **The uniformized per-sub enriched successor-depth V-carrier** (task 309 Phase 13.25; the
    v6-named "Phase 13.2b"). Additive alongside `bracketEndChar_kvE` (:5150 — UNCHANGED): same
    instantiation pattern (`charBase = nf_depth0_char_formula`, `charK = P.existF 0`,
    `exF = P.existF 3`), with the two uniformization channels folded into `kvE'_body`. Serves
    k ≥ 2; correctness (`BracketCarrierCorrectVPrior` applied to it) is Phase 13.35's gate. -/
noncomputable def bracketEndChar_kvE' {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    {k : Nat} (P : ExistProviders sig atomMap k) :
    BracketEndCharCarrierV sig (k + 1) :=
  fun qnf =>
    kvE'_body (nf_depth0_char_formula atomMap h_surj)
      (fun χ => P.existF 0 χ) (fun σ => P.existF 3 σ) qnf.1 qnf.2

/-- **Concrete k=2 instance bridge** (task 309 Phase 13.25 deliverable; the `bracketEndChar_kvE_two_eq`
    :5167 mirror): at depth-1 providers the uniformized carrier is DEFINITIONALLY the enriched body
    at the standard instantiation. Pure `rfl`. Phase 13.35 rewrites with this to expose the enriched
    body. -/
theorem bracketEndChar_kvE'_two_eq {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (P : ExistProviders sig atomMap 1)
    (qnf : NormalForm sig 2 3) :
    bracketEndChar_kvE' atomMap h_surj P qnf =
      kvE'_body (nf_depth0_char_formula atomMap h_surj)
        (fun χ => P.existF 0 χ) (fun σ => P.existF 3 σ) qnf.1 qnf.2 := rfl

/-! ## Task 309 Phase 13.35: k=2 correctness gate RE-RUN for `bracketEndChar_kvE'` —
DECISION GATE → **NO-GO (carrier-shape defect — the 13.25 channels do not carry the
discriminating per-sub joint content; finding F4)** (the single, LAST gate re-run; verdict-mirror
of the R2 GO record :3407-3445 and the F1/F2/F3 defect records; no partial theorem, no sorry).

**Lead evidence (Def 3.1, PDF p.4 md:61-74 — rule N3).** In Rabinovich's exists-forall formulas,
EVERY existentially chosen point is pinned by the bracket's own interval decomposition: it carries
its point type `α_j` AND the adjacent interval types `β_j`, `β_{j+1}` on BOTH sub-intervals
relative to the fixed endpoints. The 13.25 channel (i) `kvE_pinDisjunct` (:5374) was designed to
realize this positionally (§ header md:5368-5373: "the EXTRA bracket witness slot … and the
interval-type segment conjunct realizing σ's fresh-type claim positionally within the honest
bracket … per disjunct"). As LANDED it does NOT: it returns `([⟨charK a.witnessType⟩],
[⟨charK a.witnessType⟩])` with `a.witnessType = nfk_projFresh σ` (set in `kvE_pinArrangements`
:5364) and the placement field `a.witnessZone` DISCARDED. The pin content is therefore a function
of `nfk_projFresh σ` (the σ.1-level fresh depth-`k` type) ALONE — positionally vacuous.

**Machine probe A (channel (i) collapse — `rfl`-confirmed).** The identity
`(kvE_pinArrangements σ).map (fun a => kvE_pinDisjunct charBase charK σ a)
  = kvE_consistentZones.map (fun _ => ([⟨charK (nfk_projFresh σ)⟩], [⟨charK (nfk_projFresh σ)⟩]))`
closes by `rfl` (captured reduced state:
`(fun a ↦ ([⟨charK a.witnessType⟩], …)) ∘ (fun z ↦ {witnessZone := z, witnessType := nfk_projFresh σ})`
= `fun _ ↦ ([⟨charK (nfk_projFresh σ)⟩], …)`). Every one of the seven consistent-zone pin disjuncts
for `σ` yields the IDENTICAL formula `charK (nfk_projFresh σ)`. Consequence: two subs with equal
`nfk_projFresh` — e.g. F3's dishonest `σ'' = char [14,16,11,20]` and the honest `char [14,15,10,20]`
(fresh type `type(14) = type(15)`) — get BYTE-IDENTICAL channel-(i) content; the channel cannot
distinguish them.

**Machine probe B (the per-sub positive soundness crux persists — captured type-mismatch states).**
The extended carrier's `epR` retains the `t`-anchored provider literals `pos.map exF`
(`exF = P.existF 3`, :5448 — kept verbatim from 13.2). Driving the soundness direction to the
per-sub positive obligation and applying `P.correct 3 σ M h_UZ h_SZ t` gives
`he : nf_eval_nf M 1 (3+1) (insertEnv e t) σ` (`ExistProviders.correct` :4856:
`insertEnv e t = [e 0, e 1, e 2, t]`, anchor LAST, the `u/w/x` positions existentially REBOUND by
`e : Fin 3 → M.carrier`), while the goal needs the honest env
`Fin.cons x_1 (Fin.cons w (Fin.cons x fun _ ↦ t)) = [x_1, w, x, t]`. Captured probe states:
`exact ⟨e 0, he⟩` → "he has type `nf_eval_nf M 1 (3+1) (insertEnv e t) σ` but is expected to have
type `nf_eval_nf M 1 (3+1) (Fin.cons (e 0) (Fin.cons w (Fin.cons x fun x ↦ t))) σ`"; the funext
bridge reduces to the residual point equations `w = e 1`, `x = e 2` with NO hypothesis relating the
provider-chosen `e` to the honest anchors. Channel (i)'s actual deliverable after
`k1v_bracket_extract` (:2150) is a fresh-type witness
`hpin : ∃ u, x < u ∧ u < w ∧ nf_eval_nf M 0 1 (fun _ => u) (nfk_projFresh σ)` (probe A: this is ALL
it carries) — a SEPARATE existential, unconnected to the residual `e 1 = w`, `e 2 = x`. So the F3
crux (:5227-5236) recurs verbatim; the pin channel adds fresh-type witnesses, not anchor pinning.

**Channel (ii) is inert on this counterexample.** `kvE_exclConj` (:5387) is applied ONLY to
NEGATIVE subs (`negIn zs`, :5453) and is guarded honest-safe: `exclAt zs σ = if hasPos zs
(nfk_projFresh σ) then Formula.top else kvE_exclConj …` (:5452-5454). In F3 the dishonest POSITIVE
sub `σ''` occupies zone `zXW` with fresh type `type(14)`, so `hasPos zXW type(14) = true`; every
marked-false sub sharing that fiber (the honest `c 14`, `qnf.2 (c 14) = false`) has its exclusion
conjunct collapsed to `⊤`. The carrier-indistinguishability that defeats channel (i) also
neutralizes the channel-(ii) guard.

**Counterexample (defect bar, four elements — the statement is FALSE, provider-independent).**
Verbatim from the F3 record (:5244-5270), now re-verified carrier-visible for `kvE'`: `M = ℤ`
(Prior UZ/SZ hold), preds `p = {0}`, `r = {13}`, `x = 10`, `t = 20`,
`σ'' := char [14,16,11,20]` (fake anchors sharing only `t`; on-fiber, zone `zXW`, fresh type
`type(14)`), `qnf.2 (char [14,15,10,20]) := false`, `qnf.2 σ'' := true`. **Current behavior**: the
extended carrier's LHS still HOLDS at `(10,20)` — the honest slots plus σ'''s pin slots (fresh type
`type(14)`, realized honestly at `u = 14`) plus σ'''s `t`-anchored provider literal (its own fake
realization `[14,16,11,20]` ends at `t = 20`) are all satisfied, and channel (ii) is guarded off.
**Required behavior**: per-sub joint claims pinned against the honest anchor pair (Prop 4.2 uniform
negation/exclusion at round k+1, md:100-101). **Isolation**: the gap is the per-sub joint/exclusion
channel; gate, zones, unary families, arrangements behaved exactly as at k=1; provider-independent
(only `P.correct` consumed — survives ANY correct depth-1 bundle, including Phase 14's).

**Verdict: 13.35 = NO-GO, carrier-shape defect (finding F4).** The 13.25 uniformization added TWO
channels but neither carries the discriminating per-sub JOINT content (the sub's inner-witness
structure vs the honest anchors, which rides `σ.2`): channel (i) is a function of `nfk_projFresh σ`
(σ.1-level) alone with `witnessZone` discarded (probe A, `rfl`), and channel (ii) is negative-only
and guarded off by the dishonest sub's fiber occupancy. The provider literal still rebinds
`u/w/x` (probe B). This is the PRE-COMMITTED second-and-LAST gate outcome: per the Phase 13.35
routing (plan v7 :925-935; v7 Amendment F3 one-round budget), a second NO-GO is NOT another
uniformization round — it ESCALATES to the orchestrator blocker ladder (defect record F4 →
orchestrator halts the 309 ladder → user decision / `/spawn 309`). KD3 held: the 13.25 carrier and
the 13.1 predicate are UNCHANGED (this record is the phase's only artifact — no partial theorem, no
sorry). Escalation fence C3 held: no anchor growth; EANegation :1090/:1249 untouched. Phases 13.4
and 14 MUST NOT be dispatched. -/

/-! ## Task 320 (F4 follow-up): Joint-Pinning De-Risk Probes — NON-CONSUMED verdict addition

Machine-checked probe deliverable for task 320 (de-risk the joint-pinning route for the k=2
carrier gate). This section is a NON-CONSUMED, ADDITIVE verdict record in the F1-F4 house style:
nothing below is referenced by any landed carrier, predicate, or proof (`bracketEndChar_kv*`,
`kvE'_body`, `ExistProviders`, `BracketCarrierCorrectVPrior` are all untouched and byte-identical).
It records the GO/NO-GO probe evidence discriminating routes b1/b2/b3 (spawn analysis
`specs/309_.../reports/06_spawn-analysis-f4.md`; literature-alignment audit
`specs/320_.../reports/01_literature-alignment.md`). No sorry on any live path; all F_i-chain
content is carried by the LANDED, PROVEN `EANegation` fChain machinery (Rabinovich Cor 5.4,
md:154-157), never re-derived with `simp`/`omega`/`aesop` (G5). Full prose deliverable:
`specs/320_.../reports/02_jointpinning-probe-results.md`.

Route summary (see the report for the design spec):
- **b1** (repair channel (i) to consume `witnessZone`): **NO-GO** — probe P1 re-confirms the
  channel-(i) flattening collapse (`rfl`); Def 3.1 (md:61-74) pins σ's OWN witnesses, with no
  counterpart across the provider/`e` boundary.
- **b2** (structural-identity via `nf_eval_unique`/`nfPred_correct`): **NOT NEEDED** — probe P4
  closes b3 without any type-realization/uniqueness hypothesis (none appears in P4's signature).
- **b3** (nested F_i-chain sub-bracket, Cor 5.4): **GO** — probes P3/P4 show the LANDED fChain
  machinery carries joint multi-anchor position by the nested-Until EVALUATION POINT (litmus
  PASS), recovering honest witness positions from `bf.holds` alone, `e`-free.
-/

/-- **Probe P1 (Phase 1 baseline + Phase 2 b1 NO-GO): channel-(i) flattening collapse — `rfl`.**
    Machine re-verification of the F4 record's probe A (:5548). The landed channel-(i) content
    `kvE_pinDisjunct` mapped over the finite arrangement family `kvE_pinArrangements σ` collapses
    to a CONSTANT function of `nfk_projFresh σ` (the σ.1-level fresh depth-`k` type): the
    `witnessZone` placement field is discarded in `kvE_pinArrangements` (:5364, sets
    `witnessType := nfk_projFresh σ`), so every one of the seven consistent-zone disjuncts yields
    the identical pair `([⟨charK (nfk_projFresh σ)⟩], [⟨charK (nfk_projFresh σ)⟩])`. Two subs with
    equal `nfk_projFresh` (F4's dishonest `char[14,16,11,20]` and honest `char[14,15,10,20]`,
    `type(14)=type(15)`) therefore get byte-identical channel-(i) content: the pin channel is
    positionally vacuous and cannot discriminate them. Def 3.1 (Rabinovich md:61-74) is a real
    pinning discipline, but it pins σ's OWN witnesses inside σ's OWN bracket; it has no mechanism
    for forcing the provider's independently-bound `e` to coincide with the honest anchors (the
    actual F4 gap). Route b1 = NO-GO (an F5-strengthening refutation, not a live design). -/
private theorem probe_P1_channel_i_collapse {sig : MonadicSignature} {k : Nat}
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig k 1 → Formula)
    (σ : NormalForm sig k 4) :
    (kvE_pinArrangements σ).map (fun a => kvE_pinDisjunct charBase charK σ a)
      = kvE_consistentZones.map
          (fun _ => (([⟨charK (nfk_projFresh σ)⟩] : List TemporalPred),
                     ([⟨charK (nfk_projFresh σ)⟩] : List TemporalPred))) := by
  rfl

/-- **Probe P3 (Phase 3): Cor 5.4 chain-shape MATCH for `fChainFrom`/`fChainPred`.** The landed,
    PROVEN `BracketFormula.fChainFrom_step` (EANegation:616) IS Rabinovich Cor 5.4's step
    `F_{i-1} := α_{i-1} ∧ (β_i Until F_i)` (md:154-157): `F_i` at `x` holds iff `α_i(x)` and there
    is a forward point `s` where `F_{i+1}` holds with `β_{i+1}` along `(x, s)`. The position of the
    NEXT anchor `s` is carried by the strict-Until EVALUATION POINT (md:41), never asserted as a
    relative-position identity. Combined with the base case `F_n := α_n ∧ (β_{n+1} Until ⊤)`
    (`fChainFrom_base`, EANegation:580 — the open-interval adaptation of Cor 5.4's `F_n := α_n`,
    folding the trailing segment), `fChainFrom`/`fChainPred` (EANegation:552/:567) MATCH the Cor 5.4
    shape. This probe type-checks only because the landed def and the Cor 5.4 recursion coincide;
    hence the audit's MEDIUM-confidence claim 6 is machine-CONFIRMED. -/
private theorem probe_P3_cor54_step_shape {sig : MonadicSignature} {n : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (bf : BracketFormula (n + 1)) (i : Fin (n + 1)) (h_lt : i.val < n)
    (x : M.carrier) :
    (bf.fChainFrom i).eval_at M atomMap x ↔
    (bf.pointTypes i).eval_at M atomMap x ∧
    ∃ s : M.carrier, x < s ∧
      (bf.fChainFrom ⟨i.val + 1, by omega⟩).eval_at M atomMap s ∧
      (∀ r : M.carrier, x < r → r < s →
        (bf.segmentTypes ⟨i.val + 1, by omega⟩).eval_at M atomMap r) :=
  bf.fChainFrom_step M atomMap i h_lt x

/-- **Probe P4 (Phase 4): route b3 GO evidence — positions by evaluation point, `e`-free.**
    The landed, PROVEN `BracketFormula.bracket_implies_fChainPred` (EANegation:660): whenever the
    nested bracket holds on `(z0, z)`, the F-chain predicate `fChainPred` is satisfied at a witness
    `x0` STRICTLY INSIDE `(z0, z)`, recovered from the bracket's OWN interval pattern. Unfolding
    `fChainPred` through probe P3 (`fChainFrom_step`) exhibits each subsequent anchor at its own
    honest position via the nested Until — WITHOUT any provider environment `e : Fin m → M.carrier`
    and WITHOUT any residual `w = e 1` / `x = e 2`. This is precisely the joint multi-anchor content
    the flattened literal `P.existF 3 σ` fails to carry (F4 probe B, :5559: there the provider's own
    `e` rebinds `u/w/x`). Here the anchor positions ARE the bracket witnesses, quantified by the
    temporal semantics — no environment ever rebinds them. Note the signature: `bf.holds` is the
    SOLE hypothesis — NO structural-identity / `nf_eval_unique` / `nfPred_correct` premise is needed
    (route b2 = NOT NEEDED, Phase 5). GO-gate litmus (position-by-evaluation-point): PASS. -/
private theorem probe_P4_b3_positions_by_eval_point {sig : MonadicSignature} {n : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (bf : BracketFormula (n + 1)) (z0 z : M.carrier)
    (h : bf.holds M atomMap z0 z) :
    ∃ x0 : M.carrier, z0 < x0 ∧ x0 < z ∧
      bf.fChainPred.eval_at M atomMap x0 ∧
      (∀ y : M.carrier, z0 < y → y < x0 →
        (bf.segmentTypes ⟨0, by omega⟩).eval_at M atomMap y) :=
  bf.bracket_implies_fChainPred M atomMap z0 z h

/-! ## Task 321 (F4 resolution): Corrected k=2 carrier — nested F_i-chain sub-bracket
    (v2 plan `plans/02_corrected-k2-carrier-fi-chain-v2.md`; blocker research
    `reports/01_blocker-research-successor-k.md`, §3 drop-in amended design spec)

Additive construction realizing route b3 (task-320 GO): the per-sub JOINT content that F1–F4
could not carry (`σ`'s inner-witness structure relative to the honest anchor pair, which rides
`σ.2`) is encoded as a nested sub-bracket via the FORCED `bracketEndChar_k1v` (:1940) zone-bit
routing one arity up, read through the successor-depth fold engine `nf_eval_depth1_fold_iff`
(:5187). Every definition below is APPENDED after the task-320 probe section; no landed asset is
edited (`bracketEndChar_kv*`, `kvE'_body`, `kvE_pinDisjunct`, `kvE_exclConj`, `ExistProviders`,
`BracketCarrierCorrectVPrior`, the F1–F4 records, the task-320 probes are all byte-identical). The
whole `kvE2` layer is successor-parameterized at provider depth `j+1` (report Q1): the carrier is
`BracketEndCharCarrierV sig (j+1+1)` — carrier depth `j+2`, the k ≥ 2 band this enriched carrier
was always documented to serve (:5144-5148) — and at `j = 0` the header instantiates to the EXACT
landed gate signature, closing the `two_eq` bridge by `rfl`. -/

/-- **Sub-level fold-bit decoder** (task 321 Phase 2; report §2/Q2, probe 2, machine-checked GREEN).
    For a positive interior sub `σ : NormalForm sig 1 4` (a literal successor, so `σ.2 :
    NormalForm sig 0 5 → Bool` projects directly), `kvE_subFoldBits σ zs χ = true` iff `σ` demands
    an inner witness `v` in zone `zs` (relative to `σ`'s own env `[u, w, x, t]`) of depth-0 monadic
    type `χ`. This is the `nf_eval_depth1_fold_iff` (:5187) decomposition at `n = 4` over
    `(ZoneSpec 4 × NormalForm sig 0 1)` via `nf0_assemble` (NfEFold:180) — the SAME Def-4.1 fold
    (PDF p.5) the k1v carrier reads its `qnf.2` through (:1946), now one arity up. This is the
    read that DISTINGUISHES the F4 pair at the bit level: on `σ'' = char[14,16,11,20]` vs honest
    `char[14,15,10,20]`, `kvE_subFoldBits _ zXW _` differs (σ'' has an inner witness in `(14,16) ∋
    15`; the honest sub has `(14,15) = ∅`) — the two subs share `σ.1` `nfk_projFresh` but differ at
    `σ.2`, so the flat `charK (nfk_projFresh σ)` channel (:5467) that F4 refuted cannot see the
    difference while this decoder can. -/
noncomputable def kvE_subFoldBits {sig : MonadicSignature}
    (σ : NormalForm sig 1 4) : ZoneSpec 4 → NormalForm sig 0 1 → Bool :=
  fun zs χ => σ.2 (nf0_assemble zs χ σ.1)

/-- The sub-fold-bit decoder via the NAMED landed destructors (`NormalForm.quant_assgn`,
    `NormalForm.atom_assgn`) — DEFINITIONALLY equal to `kvE_subFoldBits` (probe 1b), recorded so
    later proofs may rewrite either way. -/
theorem kvE_subFoldBits_eq_destructors {sig : MonadicSignature}
    (σ : NormalForm sig 1 4) :
    kvE_subFoldBits σ =
      fun zs χ => (NormalForm.quant_assgn σ)
        (nf0_assemble zs χ (NormalForm.atom_assgn σ)) := rfl

/-- The three INTERIOR order-zones of an inner witness `v` relative to `σ`'s env `[u, w, x, t]`
    under the honest bracket order `x < u < w < t` (task 321 Phase 3; the arity-4 analogue of the
    k1v interior zones `zXW`/`zWT` at :1957-1959, refined by `u`). `zXU` = `x < v < u`,
    `zUW` = `u < v < w`, `zWT` = `w < v < t`. These are the Def-3.1 interior sub-intervals of
    `(x, t)` in which `σ`'s quantifier layer can demand a positive inner witness (PDF p.4
    md:61-74); `zUW` is the F4 discriminator (`σ'' = char[14,16,11,20]` is positive there via
    `(14,16) ∋ 15`, the honest `char[14,15,10,20]` is not: `(14,15) = ∅`). Exterior and
    point-coincidence zones are handled at the outer body level (`epL`/`epR`, `ptW`), exactly as in
    `kvE'_body`; here we route only the interior positives, which are what the flat joint literal
    could not carry. -/
noncomputable def kvE_subInteriorZones : List (ZoneSpec 4) :=
  let ltz : Bool × Bool := (true, false)   -- v < env i
  let gtz : Bool × Bool := (false, true)   -- env i < v
  let mk4 : Bool × Bool → Bool × Bool → Bool × Bool → Bool × Bool → ZoneSpec 4 :=
    fun p0 p1 p2 p3 => Fin.cons p0 (Fin.cons p1 (Fin.cons p2 (fun _ => p3)))
  -- coords: 0 ↦ u, 1 ↦ w, 2 ↦ x, 3 ↦ t
  let zXU : ZoneSpec 4 := mk4 ltz ltz gtz ltz   -- x < v < u  (v<u, v<w, x<v, v<t)
  let zUW : ZoneSpec 4 := mk4 gtz ltz gtz ltz   -- u < v < w  (u<v, v<w, x<v, v<t)
  let zWT : ZoneSpec 4 := mk4 gtz gtz gtz ltz   -- w < v < t  (u<v, w<v, x<v, v<t)
  [zXU, zUW, zWT]

/-- **Nested sub-bracket over `σ.2`** (task 321 Phase 3; report §2/Q2 table + probe 5, machine-checked
    skeleton GREEN). Encodes `σ`'s inner-witness structure (read from `σ.2` via `kvE_subFoldBits`)
    as bracket WITNESSES between the honest anchor pair — the FORCED `bracketEndChar_k1v` (:1940)
    zone-bit routing one arity up (arity 4 instead of 3), the Cor 5.4 recursive construction
    generalized ONE level, never a third anchor. Returns `Σ m, BracketFormula (m + 1)`: the trailing
    `+1` is `u`'s own slot (`charK (nfk_projFresh σ)`), which is what makes `fChainPred` available
    (probe 6). Routing (report §2/Q2):
    - Interior zones (`kvE_subInteriorZones`): each positive fold bit `kvE_subFoldBits σ zs χ` places
      an EXTRA bracket witness slot with point type `⟨charBase χ⟩`, spliced before `u`'s slot.
    - Negative bits per interior zone: `(charBase χ).neg` exclusion conjuncts on the refined segments
      (the landed `segL`/`segR` pattern :5455-5462, one level in) — real exclusion segments, never
      top (G3).
    The construction reads `σ.2` (where the F4 pair differs), NOT the shared `σ.1` `nfk_projFresh`,
    so — unlike the F4-refuted flat `charK (nfk_projFresh σ)` literal — the honest and dishonest subs
    produce DIFFERENT witness-slot lists. Rabinovich Def 3.1 (md:61-74), Lemma 5.1 point-insertion
    split (md:134-135). No `simp`/`omega`/`aesop` in the body (the `omega` below is a `Fin`-index
    typing obligation in a proof term, identical to the landed `bracketFromLists` :1900). -/
noncomputable def kvE_subBracket {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4) : Σ m, BracketFormula (m + 1) :=
  let bits := kvE_subFoldBits σ
  let allTypes : List (NormalForm sig 0 1) := Finset.univ.toList
  -- Interior-positive fold bits → extra bracket witness slots (point type ⟨charBase χ⟩),
  -- one per (interior zone, positive type), in zone order (Def 3.1 md:61-74 one arity up).
  let posSlots : List TemporalPred :=
    kvE_subInteriorZones.flatMap (fun zs =>
      (allTypes.filter (fun χ => bits zs χ)).map (fun χ => ⟨charBase χ⟩))
  -- Interior-negative fold bits → segment exclusion conjuncts (charBase χ).neg (G3 real segments).
  let segExcl : TemporalPred :=
    ⟨formula_conjList
      (kvE_subInteriorZones.flatMap (fun zs =>
        allTypes.map fun χ => if bits zs χ then Formula.top else (charBase χ).neg))⟩
  ⟨posSlots.length,
    { pointTypes := fun i =>
        (posSlots ++ [⟨charK (nfk_projFresh σ)⟩])[i.val]'(by
          have := i.isLt
          simp only [List.length_append, List.length_cons, List.length_nil]
          omega)
      segmentTypes := fun _ => segExcl }⟩

/-- **Sub-chain predicate** (task 321 Phase 4; report §3 item 3, probe 6). The Cor 5.4 F_i-chain
    predicate of the nested sub-bracket — `σ`'s joint inner-witness content packaged as a single
    `TemporalPred`, carried by the nested-Until EVALUATION POINT (never a relative-position
    identity). `fChainPred` is available because `kvE_subBracket` returns the `(m+1)` shape. -/
noncomputable def kvE_subChain {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4) : TemporalPred :=
  (kvE_subBracket charBase charK σ).2.fChainPred

/-- **Position-recovery lemma at the CONSTRUCTED sub-bracket** (task 321 Phase 4; report §2 probe 6,
    machine-checked GREEN — the upgrade from task-320 probe P4's "abstract recovery on generic `bf`"
    to "recovery lemma applies to the concrete sub-bracket"). Instantiates the landed, PROVEN
    `BracketFormula.bracket_implies_fChainPred` (EANegation:660) at
    `bf := (kvE_subBracket charBase charK σ).2`: whenever the sub-bracket holds on `(z0, z)`,
    `kvE_subChain … σ` is satisfied at a witness `x0` STRICTLY INSIDE `(z0, z)`, recovered from the
    bracket's OWN interval pattern — with NO provider environment `e` and NO residual `w = e 1` /
    `x = e 2` (the exact F4 crux, now dissolved: the anchor positions ARE the bracket witnesses,
    quantified by the temporal semantics, never rebound by any `e`). Sole hypothesis is `bf.holds`;
    no structural-identity / `nf_eval_unique` / `nfPred_correct` premise (route b2 NOT NEEDED).
    Rabinovich Cor 5.4 (md:154-157) via `fChainFrom_step`/`fChainFrom_base` (probe P3 MATCH). -/
theorem kvE_subBracket_implies_subChain {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (z0 z : M.carrier)
    (h : (kvE_subBracket charBase charK σ).2.holds M atomMap z0 z) :
    ∃ x0 : M.carrier, z0 < x0 ∧ x0 < z ∧
      (kvE_subChain charBase charK σ).eval_at M atomMap x0 ∧
      (∀ y : M.carrier, z0 < y → y < x0 →
        ((kvE_subBracket charBase charK σ).2.segmentTypes ⟨0, by omega⟩).eval_at M atomMap y) :=
  (kvE_subBracket charBase charK σ).2.bracket_implies_fChainPred M atomMap z0 z h

/-! ## Task 321 Stage B (Phase 7): F4 adversarial discrimination — construction level

The F4 refutation (:5548, :5634 probe P1) hinged on a `rfl`-confirmed COLLAPSE: the flat
channel-(i)/joint content was a function of `nfk_projFresh σ` (the σ.1-level fresh type) ALONE, so
two subs sharing `nfk_projFresh` (the honest `char[14,15,10,20]` and the dishonest
`σ'' = char[14,16,11,20]`, `type(14) = type(15)`) received BYTE-IDENTICAL carrier content and could
not be discriminated. The corrected construction dissolves this: the sub-bracket's witness content
is a function of `kvE_subFoldBits σ` — i.e. of `σ.2` (where the F4 pair differs), NOT of
`nfk_projFresh σ`. The two lemmas below record this at the construction level (the analog of probe
P1 for the NEW construction), machine-checked; this is the "different witness-slot lists"
discrimination the report §2/Q2 established, and it supports the pre-authorized fallback (it is a
landed deliverable independent of whether the semantic gate later completes). -/

/-- **The corrected sub-bracket's witness count is a function of `σ.2`** (task 321 Phase 7; the
    positive analog of probe P1's collapse `rfl`). The number of bracket witness slots is `1` (u's
    own slot) plus the count of positive interior fold bits `kvE_subFoldBits σ` — which reads `σ.2`.
    Unlike the F4-refuted flat channel (a function of `nfk_projFresh σ` = σ.1-level alone), this
    quantity SEES `σ.2`, exactly where the honest and dishonest F4 subs differ. Pure `rfl`. -/
theorem kvE_subBracket_witnessCount {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4) :
    (kvE_subBracket charBase charK σ).1 =
      (kvE_subInteriorZones.flatMap (fun zs =>
        ((Finset.univ.toList : List (NormalForm sig 0 1)).filter
          (fun χ => kvE_subFoldBits σ zs χ)).map
          (fun χ => (⟨charBase χ⟩ : TemporalPred)))).length := rfl

/-- **Discrimination corollary** (task 321 Phase 7). Two subs whose corrected sub-brackets differ in
    witness count yield DIFFERENT sub-brackets (Σ-injectivity on the first component). Combined with
    `kvE_subBracket_witnessCount`, this is the F4 discrimination the flat channel could not provide:
    two subs sharing `nfk_projFresh` but with different positive-interior-fold-bit counts (i.e.
    different `σ.2` content on the interior zones — the honest `char[14,15,10,20]` with `(14,15) = ∅`
    vs the dishonest `char[14,16,11,20]` with `(14,16) ∋ 15`) produce different sub-brackets, hence
    different carrier formulas. The old flat channel gave them BYTE-IDENTICAL content (probe P1). -/
theorem kvE_subBracket_ne_of_witnessCount_ne {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig 1 1 → Formula)
    (σ σ' : NormalForm sig 1 4)
    (h : (kvE_subBracket charBase charK σ).1 ≠ (kvE_subBracket charBase charK σ').1) :
    kvE_subBracket charBase charK σ ≠ kvE_subBracket charBase charK σ' := by
  intro heq
  exact h (congrArg Sigma.fst heq)

/-! ## Task 321 verdict record: PARTIAL-GO (Stages A–B landed; semantic gate Stages C–D spawned)
    — F1–F4 house style; no partial theorem, no `sorry` on any live path

**Route realized (b3, task-320 GO).** The per-sub JOINT content that F1–F4 could not carry (σ's
inner-witness structure relative to the honest anchors, which rides `σ.2`) is now encoded as a
NESTED F_i-chain sub-bracket, read from `σ.2` via the forced `bracketEndChar_k1v` (:1940) zone-bit
routing one arity up. The whole `kvE2` layer is at the CONCRETE k=2 gate instance (subs
`σ : NormalForm sig 1 4`), which report §2/Q2 fixes at `j = 0` (the depth-0 `nf0_assemble` fold
engine); this is exactly the `k = 2` band the enriched carrier serves (:5144-5148).

**Stage A — construction (COMPLETE, green, axiom-clean).**
  - `kvE_subFoldBits` (:5732) — the successor-depth `σ.2` read `fun zs χ => σ.2 (nf0_assemble zs χ
    σ.1)`; `kvE_subFoldBits_eq_destructors` the `rfl` bridge to the named destructors.
  - `kvE_subInteriorZones` + `kvE_subBracket` (:5776) — the nested sub-bracket
    `Σ m, BracketFormula (m+1)`; interior-positive `σ.2` bits → witness slots, u's own slot the
    trailing `+1` (the shape that makes `fChainPred` available); NO flat `charK (nfk_projFresh σ)`
    joint literal on the joint path.
  - `kvE_subChain` (:5808) + `kvE_subBracket_implies_subChain` (:5820) — the sub-chain predicate and
    the position-recovery lemma instantiating `bracket_implies_fChainPred` (EANegation:660) at the
    CONSTRUCTED sub-bracket (probe 6): honest positions recovered `e`-free, NO residual `w = e 1` /
    `x = e 2` (the exact F4 crux, dissolved).
  - `kvE2_body` (:5855) + `kvE2_body_gate_fail` — `kvE'_body` with the per-sub joint channel
    corrected (`ptSub σ := kvE_subChain …`, the `t`-anchored `pos.map exF`/`P.existF 3` DROPPED from
    the joint path); all non-joint channels retained verbatim.
  - `bracketEndChar_kvE2` (:5940) + `bracketEndChar_kvE2_two_eq` (`rfl`) — the corrected k=2 carrier
    `BracketEndCharCarrierV sig 2`, additive alongside the byte-identical `bracketEndChar_kvE`/`kvE'`.

**Stage B — F4 adversarial discrimination (construction level, COMPLETE, green).**
`kvE_subBracket_witnessCount` (`rfl`) records that the sub-bracket's witness count is a function of
`kvE_subFoldBits σ` — i.e. of `σ.2` — the positive analog of probe P1's `nfk_projFresh`-collapse;
`kvE_subBracket_ne_of_witnessCount_ne` is the discrimination corollary. This is the report §2/Q2
"different witness-slot lists" mechanism: the honest `char[14,15,10,20]` (`(14,15) = ∅`) and the
dishonest `char[14,16,11,20]` (`(14,16) ∋ 15`) differ at `σ.2` on the interior `(u,w)` zone, so —
unlike the F4-refuted flat channel (byte-identical, probe P1 `rfl`) — they produce different
sub-brackets. The FULL semantic `M = ℤ` LHS-FALSE proof requires the corrected carrier's evaluation
semantics on ℤ (the same machinery as the gate below) and is folded into the spawned continuation.

**Stages C–D — the k=2 `BracketCarrierCorrectVPrior` gate (RECORDED CONTINUATION — pre-authorized
fallback, plan Risks/Phase 9-10).** Closing the gate for `bracketEndChar_kvE2` to a proven GO is a
GENUINE, well-scoped, multi-dispatch effort with no k≥2 enriched precedent, NOT completable within
this dispatch and NOT to be absorbed by any `sorry`/vacuous placeholder:
  - *Soundness (Stage C):* drive `BracketCarrierCorrectVPrior … bracketEndChar_kvE2` (carrier ⇒
    ∃w realization) via `bracketEndChar_kvE2_two_eq` + `k1v_bracket_extract` (:2150) + the :2338
    soundness template, adapted to the enriched body (extra sub-bracket witness slots, `kvE_subChain`
    on u's slot, dropped `exF`). The per-sub positive crux closes via `kvE_subBracket_implies_subChain`
    (probe 6, landed above), `e`-free — but the surrounding template adaptation is itself substantial
    (the enriched arrangement/slot bookkeeping differs from the landed simple k1v).
  - *Completeness (Stage D):* honest realization ⇒ carrier holds. Fold `nf_eval_depth1_fold_iff`
    (:5187) at `n = 4` to extract σ's inner witnesses, construct the sub-bracket's
    `IntervalPattern.holds` data (monotone enumeration/range/point/segment — Rabinovich Lemma 5.3
    md:137-152, order-theoretic), then the arrangement disjunct (the :2979 completeness template).
    This direction is genuinely unprobed (report Q3: "no k≥2 precedent … plausibly multi-dispatch").
  The landed k1v gate that these mirror spans ~800 lines (:2150-3405); the enriched k=2 gate adds the
  per-sub sub-bracket obligations in BOTH directions. Per the plan's explicit sizing guard ("a single
  'prove the gate' phase would repeat v1's sizing error") and the pre-authorized fallback, this is a
  PARTIAL-GO with recorded progress, not an F5 defect: Stages A–B are the landed deliverable; the
  semantic gate (both directions + the full ℤ LHS-FALSE) is to be spawned as its own task
  (`/spawn 321`) and becomes the new prerequisite for task 309 Phase 13.4/14.

**Constraint compliance.** Purely additive same-file appends after the task-320 probe section; every
do-not-edit landed asset (`bracketEndChar_kv*`, `kvE'_body`, `kvE_pinDisjunct`, `kvE_exclConj`,
`ExistProviders`, `BracketCarrierCorrectVPrior`, the F1–F4 records, the task-320 probes) is
BYTE-IDENTICAL. No provider-side pinning (the provider disappears from the joint path — Amendment
F3); no `EANegation :1090/:1249` consumed; real exclusion segments (G3); anchors fixed at 2, witnesses
grow only (G2/G4/G6); no `simp`/`omega`/`aesop` in any chain-construction body (the `omega` in
`kvE_subBracket` is a `Fin`-index typing obligation, identical to the landed `bracketFromLists`
:1900); Rabinovich cited at every chain step (G5); all new symbols axiom-clean
(`propext`, `Classical.choice`, `Quot.sound`); no `sorry` on any live path. -/

/-! ## Task 324 (redesign): anchor-at-`x` corrected sub-bracket — arity-4 correctness pair

Additive, separately-named redesign of the k=2 sub-bracket (task 324 Phase 1; plan
`plans/01_arity4-correctness-pair-plan.md`). The landed `kvE_subBracket`/`kvE_subChain`
(:5779/:5807) anchor the strictly-upward `fChainPred` at the interior σ-witness slot `u`: `u`'s own
point type sits at the TOP of the ascending witness list `posSlots ++ [u]`, so a witness in
`zXU = (x, v, u)` lying BELOW `u` is structurally inexpressible (task-321 Phase 8 machine-grounded
blocker; adversarial-verification Correction 1: the defect is read-back geometry, not a missing
zone). This redesign LIFTS the landed k1v LOWER-endpoint geometry one arity up: `bracketEndChar_k1v`
(:1940) anchors its bracket `bracketFromLists lL ptW lR` over `(x, t)` at the lower endpoint `x`,
with the middle `w`-slot BETWEEN the two witness lists, so a single upward `fChainPred` from `x`
reaches every interior zone. Here `u` plays the role of k1v's `w`: `u`'s own slot is placed in the
MIDDLE of the ascending witness list, BETWEEN the below-anchor `zXU` slots and the above-anchor
`zUW`/`zWT` slots (`leftSlots ++ uSlot :: rightSlots`, the arity-4 lift of k1v's `lL ++ ptW :: lR`).
A single upward `fChainPred` evaluated at the lower endpoint `x` then reaches all three interior
zones `zXU` (below `u`), `zUW`, `zWT` (above `u`) in ascending order — the below-anchor witness the
landed construction could not express.

Every landed asset stays byte-identical AND unreferenced: this block reads `σ.2` through the depth-0
`nf0_assemble` fold engine DIRECTLY (consume-do-not-rebuild; the same Def-4.1 fold, PDF p.5, that the
landed `kvE_subFoldBits` :5730 and the k1v carrier :1946 read — inlined here so the new construction
depends on no task-321 sub-bracket symbol) and rebinds the three interior zone specs locally via the
same `mk4` pattern as `kvE_subInteriorZones` :5751. No `simp`/`omega`/`aesop` in the body (the
`omega` is a `Fin`-index typing obligation in a proof term, identical to the landed `bracketFromLists`
:1900 and `kvE_subBracket` :5798). Rabinovich Def 3.1 (md:61-74), Def 4.1 (PDF p.5), §5 bracket
`[α_0, …, α_n](z_0, z_1)` (PDF p.7), Cor 5.4 recursive chain (md:154-157). -/
noncomputable def kvE_subBracket2 {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4) : Σ m, BracketFormula (m + 1) :=
  -- Sub-level fold-bit read (Def 4.1, PDF p.5): `σ.2 ∘ nf0_assemble` at the gate instance j = 0,
  -- inlined (consume-do-not-rebuild) so no landed sub-bracket symbol is referenced.
  let bits : ZoneSpec 4 → NormalForm sig 0 1 → Bool :=
    fun zs χ => σ.2 (nf0_assemble zs χ σ.1)
  let allTypes : List (NormalForm sig 0 1) := Finset.univ.toList
  -- Interior zone specs relative to σ's env `[u, w, x, t]` under honest order `x < u < w < t`
  -- (coords 0 ↦ u, 1 ↦ w, 2 ↦ x, 3 ↦ t), rebound locally (matches `kvE_subInteriorZones` :5751).
  let ltz : Bool × Bool := (true, false)   -- v < env i
  let gtz : Bool × Bool := (false, true)   -- env i < v
  let mk4 : Bool × Bool → Bool × Bool → Bool × Bool → Bool × Bool → ZoneSpec 4 :=
    fun p0 p1 p2 p3 => Fin.cons p0 (Fin.cons p1 (Fin.cons p2 (fun _ => p3)))
  let zXU : ZoneSpec 4 := mk4 ltz ltz gtz ltz   -- x < v < u  (BELOW anchor u)
  let zUW : ZoneSpec 4 := mk4 gtz ltz gtz ltz   -- u < v < w  (ABOVE anchor u)
  let zWT : ZoneSpec 4 := mk4 gtz gtz gtz ltz   -- w < v < t  (ABOVE anchor u)
  -- Below-anchor interior positives → left witness slots (Def 3.1 md:61-74; k1v `lL` one arity up).
  let leftSlots : List TemporalPred :=
    (allTypes.filter (fun χ => bits zXU χ)).map (fun χ => (⟨charBase χ⟩ : TemporalPred))
  -- Above-anchor interior positives → right witness slots (k1v `lR` one arity up), zone order.
  let rightSlots : List TemporalPred :=
    [zUW, zWT].flatMap (fun zs =>
      (allTypes.filter (fun χ => bits zs χ)).map (fun χ => (⟨charBase χ⟩ : TemporalPred)))
  -- `u`'s own middle slot: the anchor point type BETWEEN left and right slots (k1v `ptW` at `w`,
  -- §5 bracket PDF p.7, one arity up). THIS mid-placement is the anchor-at-`x` corrective change.
  let uSlot : TemporalPred := ⟨charK (nfk_projFresh σ)⟩
  -- Interior-negative bits → segment exclusion conjuncts (real segments, G3), all three zones.
  let segExcl : TemporalPred :=
    ⟨formula_conjList
      ([zXU, zUW, zWT].flatMap (fun zs =>
        allTypes.map fun χ => if bits zs χ then Formula.top else (charBase χ).neg))⟩
  ⟨leftSlots.length + rightSlots.length,
    { pointTypes := fun i =>
        (leftSlots ++ uSlot :: rightSlots)[i.val]'(by
          have := i.isLt
          simp only [List.length_append, List.length_cons]
          omega)
      segmentTypes := fun _ => segExcl }⟩

/-- **Anchor-at-`x` sub-chain predicate** (task 324 Phase 1; report §3 item 3 lifted). The Cor 5.4
    F_i-chain predicate of the redesigned sub-bracket — `fChainPred` is available because
    `kvE_subBracket2` returns the `(m+1)` shape. Evaluated at the lower endpoint `x`, its ascending
    Until-chain reaches `zXU` (below `u`), then `u`, then `zUW`/`zWT` (above `u`) — the below-anchor
    witness the landed `kvE_subChain` :5807 could not express. Rabinovich Cor 5.4 (md:154-157). -/
noncomputable def kvE_subChain2 {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4) : TemporalPred :=
  (kvE_subBracket2 charBase charK σ).2.fChainPred

/-- **Definitional bridge / `two_eq`-style rfl compatibility check at j = 0** (task 324 Phase 1;
    R3). Confirms the redesigned sub-chain is definitionally the `fChainPred` of the anchor-at-`x`
    sub-bracket, and that the whole construction elaborates and reduces at the concrete gate instance
    j = 0 (the depth-0 `nf0_assemble` read). The successor-parameterized carrier depth is `j + 2`
    (subs `σ : NormalForm sig (j+1) 4`); at j = 0 this is the landed `NormalForm sig 1 4` instance,
    and the bridge closes by `rfl` — any successor-threading depth mismatch would fail it immediately
    (the `bracketEndChar_kvE2_two_eq` :5972 discipline, one arity up). -/
theorem kvE_subChain2_eq_fChainPred {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4) :
    kvE_subChain2 charBase charK σ = (kvE_subBracket2 charBase charK σ).2.fChainPred := rfl

/-! ### Phase 2 — Per-zone reachability kill-switch (task 324)

The design-validation gate (Risk R1) for the anchor-at-`x` geometry. Each interior zone gets one
concrete, machine-verified reachability lemma against the *chosen* geometry — NOT a `#eval`/
type-check probe. The lemmas semantically drive the `kvE_subBracket2` bracket: whenever it holds on
an interval, its strictly increasing witnesses (Def 3.1 monotone enumeration, PDF p.4) place the
`zXU`-positive witnesses BELOW the anchor `u`-slot and the `zUW`/`zWT`-positive witnesses ABOVE it —
the below-anchor witness the landed `kvE_subChain` :5807 could not express. Rabinovich Prop 3.5
(md:87-94, the ∃-witness → Until folding of an ascending chain) and §5 bracket `[α_0,…,α_n](z_0,z_1)`
(PDF p.7). The three interior zone specs are rebound here as defeq clones of the def's internal
`let`s (and of `kvE_subInteriorZones` :5751); `mk4 ltz ltz gtz ltz` etc. with `ltz = (true, false)`
(`v < env i`) and `gtz = (false, true)` (`env i < v`). -/

/-- Interior zone `zXU = (x < v < u)` — BELOW the anchor `u`. Defeq to `kvE_subBracket2`'s internal
    `zXU` and to `kvE_subInteriorZones` :5751. Rabinovich Def 3.1 (md:61-74). -/
private def kvE_sub2_zXU : ZoneSpec 4 :=
  Fin.cons (true, false) (Fin.cons (true, false) (Fin.cons (false, true) (fun _ => (true, false))))

/-- Interior zone `zUW = (u < v < w)` — ABOVE the anchor `u`. Rabinovich Def 3.1 (md:61-74). -/
private def kvE_sub2_zUW : ZoneSpec 4 :=
  Fin.cons (false, true) (Fin.cons (true, false) (Fin.cons (false, true) (fun _ => (true, false))))

/-- Interior zone `zWT = (w < v < t)` — ABOVE the anchor `u`. Rabinovich Def 3.1 (md:61-74). -/
private def kvE_sub2_zWT : ZoneSpec 4 :=
  Fin.cons (false, true) (Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (true, false))))

/-- Below-anchor witness slots of `kvE_subBracket2` (`leftSlots`, defeq to the def's internal
    `let`). One witness point type per `zXU`-positive fold bit. Rabinovich Def 3.1 (md:61-74). -/
private noncomputable def kvE_sub2_leftSlots {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula) (σ : NormalForm sig 1 4) : List TemporalPred :=
  ((Finset.univ.toList : List (NormalForm sig 0 1)).filter
    (fun χ => σ.2 (nf0_assemble kvE_sub2_zXU χ σ.1))).map (fun χ => (⟨charBase χ⟩ : TemporalPred))

/-- Above-anchor witness slots of `kvE_subBracket2` (`rightSlots`, defeq to the def's internal
    `let`), in zone order `zUW, zWT`. Rabinovich Def 3.1 (md:61-74). -/
private noncomputable def kvE_sub2_rightSlots {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula) (σ : NormalForm sig 1 4) : List TemporalPred :=
  [kvE_sub2_zUW, kvE_sub2_zWT].flatMap (fun zs =>
    ((Finset.univ.toList : List (NormalForm sig 0 1)).filter
      (fun χ => σ.2 (nf0_assemble zs χ σ.1))).map (fun χ => (⟨charBase χ⟩ : TemporalPred)))

/-- **Anchor-at-`x` point-type extraction** (task 324 Phase 2). Whenever the redesigned bracket
    `kvE_subBracket2` holds on `(z_0, z_1)`, there is an anchor witness `w` realizing the `u`-slot
    type `charK (nfk_projFresh σ)`, with every `zXU`-positive point type realized strictly BELOW
    `w` and every `zUW`/`zWT`-positive point type realized strictly ABOVE `w`. This is the arity-4
    lift of `k1v_bracket_extract` :2150 (bullets 1-3, point-type reachability only; the constant
    `segExcl` segment types are irrelevant to point conditions). Rabinovich §5 bracket (PDF p.7),
    Def 3.1 monotone witness enumeration (PDF p.4). -/
private theorem kvE_subBracket2_extract {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (z0 z1 : M.carrier)
    (h : (kvE_subBracket2 charBase charK σ).2.holds M atomMap z0 z1) :
    ∃ w : M.carrier, z0 < w ∧ w < z1 ∧
      (⟨charK (nfk_projFresh σ)⟩ : TemporalPred).eval_at M atomMap w ∧
      (∀ χ : NormalForm sig 0 1,
        σ.2 (nf0_assemble kvE_sub2_zXU χ σ.1) = true →
        ∃ u : M.carrier, z0 < u ∧ u < w ∧
          (⟨charBase χ⟩ : TemporalPred).eval_at M atomMap u) ∧
      (∀ χ : NormalForm sig 0 1,
        (σ.2 (nf0_assemble kvE_sub2_zUW χ σ.1) = true ∨
         σ.2 (nf0_assemble kvE_sub2_zWT χ σ.1) = true) →
        ∃ u : M.carrier, w < u ∧ u < z1 ∧
          (⟨charBase χ⟩ : TemporalPred).eval_at M atomMap u) := by
  -- Point-type list of the anchor-at-`x` bracket: `leftSlots ++ uSlot :: rightSlots`.
  set lL := kvE_sub2_leftSlots charBase σ with hlL
  set lR := kvE_sub2_rightSlots charBase σ with hlR
  -- The constructed bracket's point-type function (rfl: the def sets `pointTypes` to exactly this).
  have hpt_eq : (kvE_subBracket2 charBase charK σ).2.pointTypes =
      fun i => (lL ++ (⟨charK (nfk_projFresh σ)⟩ : TemporalPred) :: lR)[i.val]'(by
        have hlt := i.isLt
        have hf : (kvE_subBracket2 charBase charK σ).fst = lL.length + lR.length := rfl
        simp only [List.length_append, List.length_cons]
        omega) := rfl
  -- Unfold `holds` to the `n+1` existential witness form (Def 3.1, PDF p.4).
  simp only [BracketFormula.holds, BracketFormula.toIntervalPattern] at h
  rw [IntervalPattern.holds_eq_succ M atomMap _ _ z0 z1
      (show (kvE_subBracket2 charBase charK σ).1 + 1 = (lL.length + lR.length) + 1 from rfl)] at h
  obtain ⟨ws, hmono, hrange, hpt, _, _, _⟩ := h
  -- Nat-indexed point-type view (proof-irrelevant reindexing), rewritten by `hpt_eq`.
  have hpt' : ∀ (i : Nat) (hi : i < lL.length + lR.length + 1),
      ((lL ++ (⟨charK (nfk_projFresh σ)⟩ : TemporalPred) :: lR)[i]'(by
        simp only [List.length_append, List.length_cons]; omega)).eval_at M atomMap
        (ws ⟨i, hi⟩) := by
    intro i hi
    have hi' := hpt ⟨i, hi⟩
    simp only [hpt_eq] at hi'
    exact hi'
  refine ⟨ws ⟨lL.length, by omega⟩, (hrange ⟨lL.length, by omega⟩).1,
    (hrange ⟨lL.length, by omega⟩).2, ?_, ?_, ?_⟩
  · -- Anchor `uSlot` at index `lL.length` (§5 bracket middle slot, PDF p.7).
    have helem : (lL ++ (⟨charK (nfk_projFresh σ)⟩ : TemporalPred) :: lR)[lL.length]'(by
        simp only [List.length_append, List.length_cons]; omega)
        = (⟨charK (nfk_projFresh σ)⟩ : TemporalPred) := by
      rw [List.getElem_append_right (Nat.le_refl _)]
      simp only [Nat.sub_self, List.getElem_cons_zero]
    have := hpt' lL.length (by omega)
    rwa [helem] at this
  · -- Below-anchor: each `zXU`-positive point type realized strictly inside `(z0, w)`.
    intro χ hχ
    have hmem : (⟨charBase χ⟩ : TemporalPred) ∈ lL := by
      rw [hlL, kvE_sub2_leftSlots]
      exact List.mem_map.mpr
        ⟨χ, List.mem_filter.mpr ⟨Finset.mem_toList.mpr (Finset.mem_univ _), hχ⟩, rfl⟩
    obtain ⟨j, hj, hjeq⟩ := List.mem_iff_getElem.mp hmem
    refine ⟨ws ⟨j, by omega⟩, (hrange ⟨j, by omega⟩).1,
      hmono ⟨j, by omega⟩ ⟨lL.length, by omega⟩ (Fin.mk_lt_mk.mpr hj), ?_⟩
    have := hpt' j (by omega)
    rw [List.getElem_append_left hj, hjeq] at this
    exact this
  · -- Above-anchor: each `zUW`/`zWT`-positive point type realized strictly inside `(w, z1)`.
    intro χ hχ
    have hmem : (⟨charBase χ⟩ : TemporalPred) ∈ lR := by
      rw [hlR, kvE_sub2_rightSlots]
      rcases hχ with h1 | h1
      · exact List.mem_flatMap.mpr ⟨kvE_sub2_zUW, List.mem_cons.mpr (Or.inl rfl),
          List.mem_map.mpr ⟨χ, List.mem_filter.mpr
            ⟨Finset.mem_toList.mpr (Finset.mem_univ _), h1⟩, rfl⟩⟩
      · exact List.mem_flatMap.mpr ⟨kvE_sub2_zWT,
          List.mem_cons.mpr (Or.inr (List.mem_cons.mpr (Or.inl rfl))),
          List.mem_map.mpr ⟨χ, List.mem_filter.mpr
            ⟨Finset.mem_toList.mpr (Finset.mem_univ _), h1⟩, rfl⟩⟩
    obtain ⟨j, hj, hjeq⟩ := List.mem_iff_getElem.mp hmem
    refine ⟨ws ⟨lL.length + 1 + j, by omega⟩,
      hmono ⟨lL.length, by omega⟩ ⟨lL.length + 1 + j, by omega⟩ (Fin.mk_lt_mk.mpr (by omega)),
      (hrange ⟨lL.length + 1 + j, by omega⟩).2, ?_⟩
    have helem : (lL ++ (⟨charK (nfk_projFresh σ)⟩ : TemporalPred) :: lR)[lL.length + 1 + j]'(by
        simp only [List.length_append, List.length_cons]; omega) = lR[j]'hj := by
      rw [List.getElem_append_right (by omega)]
      simp only [show lL.length + 1 + j - lL.length = j + 1 by omega, List.getElem_cons_succ]
    have := hpt' (lL.length + 1 + j) (by omega)
    rw [helem, hjeq] at this
    exact this

/-- **KILL-SWITCH — `zXU` reachability (BELOW the anchor)** (task 324 Phase 2, Risk R1). For every
    `zXU`-positive fold bit `χ`, whenever `kvE_subBracket2` holds on `(z_0, z_1)` there is a witness
    `u` realizing `charBase χ` strictly BELOW the anchor witness `w` (which realizes the `u`-slot
    type). This is the exact obligation the landed `kvE_subChain` :5807 (upward-only, anchored at
    `u`) could not meet — the below-anchor witness is now expressible. Rabinovich Prop 3.5
    (md:87-94), §5 bracket (PDF p.7). -/
theorem kvE_subBracket2_reaches_zXU {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (z0 z1 : M.carrier) (χ : NormalForm sig 0 1)
    (hbit : σ.2 (nf0_assemble kvE_sub2_zXU χ σ.1) = true)
    (h : (kvE_subBracket2 charBase charK σ).2.holds M atomMap z0 z1) :
    ∃ u w : M.carrier, z0 < u ∧ u < w ∧ w < z1 ∧
      (⟨charBase χ⟩ : TemporalPred).eval_at M atomMap u ∧
      (⟨charK (nfk_projFresh σ)⟩ : TemporalPred).eval_at M atomMap w := by
  obtain ⟨w, hz0w, hwz1, hanchor, hleft, _⟩ :=
    kvE_subBracket2_extract charBase charK σ M atomMap z0 z1 h
  obtain ⟨u, hz0u, huw, hu⟩ := hleft χ hbit
  exact ⟨u, w, hz0u, huw, hwz1, hu, hanchor⟩

/-- **KILL-SWITCH — `zUW` reachability (ABOVE the anchor)** (task 324 Phase 2, Risk R1). For every
    `zUW`-positive fold bit `χ`, whenever `kvE_subBracket2` holds on `(z_0, z_1)` there is a witness
    `u` realizing `charBase χ` strictly ABOVE the anchor witness `w`. Reuses the proven upward
    monotone enumeration unchanged. Rabinovich Prop 3.5 (md:87-94). -/
theorem kvE_subBracket2_reaches_zUW {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (z0 z1 : M.carrier) (χ : NormalForm sig 0 1)
    (hbit : σ.2 (nf0_assemble kvE_sub2_zUW χ σ.1) = true)
    (h : (kvE_subBracket2 charBase charK σ).2.holds M atomMap z0 z1) :
    ∃ w u : M.carrier, z0 < w ∧ w < u ∧ u < z1 ∧
      (⟨charK (nfk_projFresh σ)⟩ : TemporalPred).eval_at M atomMap w ∧
      (⟨charBase χ⟩ : TemporalPred).eval_at M atomMap u := by
  obtain ⟨w, hz0w, hwz1, hanchor, _, hright⟩ :=
    kvE_subBracket2_extract charBase charK σ M atomMap z0 z1 h
  obtain ⟨u, hwu, huz1, hu⟩ := hright χ (Or.inl hbit)
  exact ⟨w, u, hz0w, hwu, huz1, hanchor, hu⟩

/-- **KILL-SWITCH — `zWT` reachability (ABOVE the anchor)** (task 324 Phase 2, Risk R1). For every
    `zWT`-positive fold bit `χ`, whenever `kvE_subBracket2` holds on `(z_0, z_1)` there is a witness
    `u` realizing `charBase χ` strictly ABOVE the anchor witness `w`. Rabinovich Prop 3.5
    (md:87-94). -/
theorem kvE_subBracket2_reaches_zWT {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (z0 z1 : M.carrier) (χ : NormalForm sig 0 1)
    (hbit : σ.2 (nf0_assemble kvE_sub2_zWT χ σ.1) = true)
    (h : (kvE_subBracket2 charBase charK σ).2.holds M atomMap z0 z1) :
    ∃ w u : M.carrier, z0 < w ∧ w < u ∧ u < z1 ∧
      (⟨charK (nfk_projFresh σ)⟩ : TemporalPred).eval_at M atomMap w ∧
      (⟨charBase χ⟩ : TemporalPred).eval_at M atomMap u := by
  obtain ⟨w, hz0w, hwz1, hanchor, _, hright⟩ :=
    kvE_subBracket2_extract charBase charK σ M atomMap z0 z1 h
  obtain ⟨u, hwu, huz1, hu⟩ := hright χ (Or.inr hbit)
  exact ⟨w, u, hz0w, hwu, huz1, hanchor, hu⟩

/-! ### Phase 3 — Soundness: atom-layer recovery channel + interior-fold ≤ per zone (task 324)

Soundness building blocks consumed by Phase 4's `kvE_subBracket2_sound` assembly. Two channels:

* **Atom-layer recovery channel** (`kvE_subBracket2_implies_subChain2`): the arity-4 corrected
  analog of the landed holds→chain-at-point connector `kvE_subBracket_implies_subChain` :5824,
  now instantiating the PROVEN `BracketFormula.bracket_implies_fChainPred` (EANegation:660) at the
  *corrected* `kvE_subBracket2`. Whenever the redesigned bracket holds on `(z0, z)`, its
  `fChainPred` (= `kvE_subChain2`, def :6170) is satisfied at a witness `x0` STRICTLY inside
  `(z0, z)`, recovered from the bracket's OWN interval pattern — the F-chain predicate that
  carries σ.1's order + predicate structure over the chain's evaluation points (report §2 probe 6).
  No provider environment rebinds the anchors (Amendment F3); the positions ARE the bracket
  witnesses, quantified by the temporal semantics. Rabinovich Cor 5.4 (md:154-157).

* **Interior-fold ≤ per zone** (`kvE_subBracket2_fold_zXU/_zUW/_zWT`): for each interior zone,
  a POSITIVE fold bit `σ.2 (nf0_assemble z* χ σ.1) = true` is REALIZED by the Phase-2 reachability
  evidence (`kvE_subBracket2_reaches_z*`) as an honest normal-form witness. Reading the point
  types through `charBase := nf_depth0_char_formula atomMap h_surj`, the char-formula realization
  `⟨charBase χ⟩.eval_at` is bridged to the actual `nf_eval_nf M 0 1` evaluation via the correctness
  lemma `nfPred_correct` (NfToVecEA:69) — the exact `hchar` bridge the k1v soundness template
  :2370 uses. `zXU` places its witness strictly BELOW the anchor `w` (the below-anchor witness the
  landed construction could not express); `zUW`/`zWT` strictly ABOVE. Rabinovich Cor 5.4
  (md:154-157) step-by-step; no `simp`/`omega`/`aesop` on chain steps. -/

/-- **Atom-layer recovery channel** (task 324 Phase 3). The corrected arity-4 holds→chain-at-point
    connector: instantiates the PROVEN `BracketFormula.bracket_implies_fChainPred` (EANegation:660)
    at the redesigned `kvE_subBracket2`. Whenever the bracket holds on `(z0, z)`, `kvE_subChain2`
    (its `fChainPred`, def :6170) holds at a witness `x0` strictly inside `(z0, z)`, and every point
    strictly below `x0` satisfies the leading segment type. This recovers σ.1's order + predicate
    structure over the chain's evaluation points WITHOUT any provider environment (Amendment F3):
    the anchor positions are the bracket witnesses, quantified by the temporal semantics. Arity-4
    analog of the landed `kvE_subBracket_implies_subChain` :5824. Rabinovich Cor 5.4 (md:154-157). -/
theorem kvE_subBracket2_implies_subChain2 {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (z0 z : M.carrier)
    (h : (kvE_subBracket2 charBase charK σ).2.holds M atomMap z0 z) :
    ∃ x0 : M.carrier, z0 < x0 ∧ x0 < z ∧
      (kvE_subChain2 charBase charK σ).eval_at M atomMap x0 ∧
      (∀ y : M.carrier, z0 < y → y < x0 →
        ((kvE_subBracket2 charBase charK σ).2.segmentTypes ⟨0, by omega⟩).eval_at M atomMap y) :=
  (kvE_subBracket2 charBase charK σ).2.bracket_implies_fChainPred M atomMap z0 z h

/-- **Interior-fold ≤ — `zXU` (BELOW anchor)** (task 324 Phase 3). A positive `zXU` fold bit is
    realized as an honest `nf_eval_nf M 0 1` witness `u` strictly BELOW the anchor witness `w`.
    The Phase-2 `kvE_subBracket2_reaches_zXU` supplies the below-anchor char-formula witness; the
    `nfPred_correct` (NfToVecEA:69) bridge — with `charBase = nf_depth0_char_formula atomMap h_surj`
    — converts the char-formula realization to the actual normal-form evaluation, exactly as the
    k1v soundness template's `hchar` :2370. Rabinovich Cor 5.4 (md:154-157). -/
theorem kvE_subBracket2_fold_zXU {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4)
    (M : OrderedMonadicStructure sig)
    (z0 z1 : M.carrier) (χ : NormalForm sig 0 1)
    (hbit : σ.2 (nf0_assemble kvE_sub2_zXU χ σ.1) = true)
    (h : (kvE_subBracket2 (nf_depth0_char_formula atomMap h_surj) charK σ).2.holds M atomMap z0 z1) :
    ∃ u w : M.carrier, z0 < u ∧ u < w ∧ w < z1 ∧
      nf_eval_nf M 0 1 (fun _ => u) χ ∧
      (⟨charK (nfk_projFresh σ)⟩ : TemporalPred).eval_at M atomMap w := by
  obtain ⟨u, w, hz0u, huw, hwz1, hu, hw⟩ :=
    kvE_subBracket2_reaches_zXU (nf_depth0_char_formula atomMap h_surj) charK σ M atomMap z0 z1 χ
      hbit h
  exact ⟨u, w, hz0u, huw, hwz1, (nfPred_correct M atomMap h_surj χ u).mp hu, hw⟩

/-- **Interior-fold ≤ — `zUW` (ABOVE anchor)** (task 324 Phase 3). A positive `zUW` fold bit is
    realized as an honest `nf_eval_nf M 0 1` witness `u` strictly ABOVE the anchor witness `w`
    (Phase-2 `kvE_subBracket2_reaches_zUW` + the `nfPred_correct` bridge). Rabinovich Cor 5.4
    (md:154-157). -/
theorem kvE_subBracket2_fold_zUW {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4)
    (M : OrderedMonadicStructure sig)
    (z0 z1 : M.carrier) (χ : NormalForm sig 0 1)
    (hbit : σ.2 (nf0_assemble kvE_sub2_zUW χ σ.1) = true)
    (h : (kvE_subBracket2 (nf_depth0_char_formula atomMap h_surj) charK σ).2.holds M atomMap z0 z1) :
    ∃ w u : M.carrier, z0 < w ∧ w < u ∧ u < z1 ∧
      (⟨charK (nfk_projFresh σ)⟩ : TemporalPred).eval_at M atomMap w ∧
      nf_eval_nf M 0 1 (fun _ => u) χ := by
  obtain ⟨w, u, hz0w, hwu, huz1, hw, hu⟩ :=
    kvE_subBracket2_reaches_zUW (nf_depth0_char_formula atomMap h_surj) charK σ M atomMap z0 z1 χ
      hbit h
  exact ⟨w, u, hz0w, hwu, huz1, hw, (nfPred_correct M atomMap h_surj χ u).mp hu⟩

/-- **Interior-fold ≤ — `zWT` (ABOVE anchor)** (task 324 Phase 3). A positive `zWT` fold bit is
    realized as an honest `nf_eval_nf M 0 1` witness `u` strictly ABOVE the anchor witness `w`
    (Phase-2 `kvE_subBracket2_reaches_zWT` + the `nfPred_correct` bridge). Rabinovich Cor 5.4
    (md:154-157). -/
theorem kvE_subBracket2_fold_zWT {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4)
    (M : OrderedMonadicStructure sig)
    (z0 z1 : M.carrier) (χ : NormalForm sig 0 1)
    (hbit : σ.2 (nf0_assemble kvE_sub2_zWT χ σ.1) = true)
    (h : (kvE_subBracket2 (nf_depth0_char_formula atomMap h_surj) charK σ).2.holds M atomMap z0 z1) :
    ∃ w u : M.carrier, z0 < w ∧ w < u ∧ u < z1 ∧
      (⟨charK (nfk_projFresh σ)⟩ : TemporalPred).eval_at M atomMap w ∧
      nf_eval_nf M 0 1 (fun _ => u) χ := by
  obtain ⟨w, u, hz0w, hwu, huz1, hw, hu⟩ :=
    kvE_subBracket2_reaches_zWT (nf_depth0_char_formula atomMap h_surj) charK σ M atomMap z0 z1 χ
      hbit h
  exact ⟨w, u, hz0w, hwu, huz1, hw, (nfPred_correct M atomMap h_surj χ u).mp hu⟩

/-! ### Phase 4 — Soundness: off-fiber falsity gate + standalone assembly (task 324)

The standalone soundness lemma `kvE_subBracket2_sound`, assembled against `nf_eval_nf M 1 4` via
`nf_eval_depth1_fold_iff` (:5187 — the inside-out Def-4.1-p.6 fold, Prop 4.3 p.6, rule N2). It is
STANDALONE: the outer gate-shaped hypothesis (analogous to `kvE_gate` :5015) is an EXPLICIT
hypothesis, NEVER wired to the real outer gate (Amendment F3: no provider-side pinning; the
anchor positions ARE the bracket witnesses, quantified by the temporal semantics).

Division of labour (the honest content split, per the redesign's Correction-1 thesis):

* The **bracket construction** discharges the BELOW-ANCHOR (`zXU`) existence witnesses — the
  witnesses the landed `kvE_subChain` :5807 (upward-only, anchored at `u`) structurally could not
  express. Given a positive `zXU` fold bit, `kvE_subBracket2_extract`'s below-clause supplies a
  witness strictly BELOW the anchor, converted to an honest `nf_eval_nf M 0 1` via the
  `nfPred_correct` bridge (NfToVecEA:69, the k1v `hchar` :2370) and placed in zone `zXU` relative
  to the honest env `[a, w, x, t]`. Rabinovich Def 3.1 monotone enumeration (PDF p.4), §5 bracket
  (PDF p.7).

* The **explicit gate hypothesis** carries the remaining honest fold conditions the redesigned
  bracket does not itself encode (it has no endpoint char-formula conjuncts and conflates the two
  above-anchor zones): the atom layer, the off-fiber falsity clause, the forward zone honesty for
  every zone, and the backward direction for every zone EXCEPT `zXU`. This is the analog of
  `kvE_gate`'s per-sub off-fiber/consistency honesty, taken as an explicit standalone hypothesis
  (Amendment F3). It does NOT contain the `zXU` existence witnesses — those are the bracket's
  signature contribution — so the construction is genuinely load-bearing. -/

/-- **Standalone soundness of the redesigned sub-bracket** (task 324 Phase 4). Whenever the
    anchor-at-`x` bracket `kvE_subBracket2` holds on the FIXED endpoints `(x, t)`, and the explicit
    outer gate-shaped hypothesis `hgate` supplies the honest fold conditions it does not itself
    encode, there is a depth-1 witness `x1` realizing the arity-4 evaluation `nf_eval_nf M 1 4` at
    the honest env `[x1, w, x, t]`. STANDALONE: `hgate` is an explicit hypothesis, never wired to
    the real outer gate (Amendment F3 — no provider pinning; the anchor is the bracket's own
    witness). The bracket's OWN contribution is the below-anchor (`zXU`) existence witnesses
    (Correction 1: the below-anchor witness the landed `kvE_subChain` :5807 could not express).
    Assembled via `nf_eval_depth1_fold_iff` (:5187), reusing the `bracketEndChar_k1v_sound` :2338
    template shape one arity up. Rabinovich Def 3.1 (md:61-74), Prop 3.5 (md:87-94), Cor 5.4
    (md:154-157). -/
theorem kvE_subBracket2_sound {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4)
    (M : OrderedMonadicStructure sig)
    (w x t : M.carrier)
    (h : (kvE_subBracket2 (nf_depth0_char_formula atomMap h_surj) charK σ).2.holds
        M atomMap x t)
    (hgate : ∀ a : M.carrier, x < a → a < t →
      (⟨charK (nfk_projFresh σ)⟩ : TemporalPred).eval_at M atomMap a →
      a < w ∧ w < t ∧
      nf_eval_nf M 0 4 (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) σ.1 ∧
      (∀ τ : NormalForm sig 0 5, nf0_dropFresh τ ≠ σ.1 → σ.2 τ = false) ∧
      (∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1),
        (∃ v : M.carrier,
          zoneHolds M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) zs v ∧
          nf_eval_nf M 0 1 (fun _ => v) χ) →
        σ.2 (nf0_assemble zs χ σ.1) = true) ∧
      (∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1), zs ≠ kvE_sub2_zXU →
        σ.2 (nf0_assemble zs χ σ.1) = true →
        ∃ v : M.carrier,
          zoneHolds M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) zs v ∧
          nf_eval_nf M 0 1 (fun _ => v) χ)) :
    ∃ x1 : M.carrier,
      nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ := by
  -- Extract the anchor `a` (§5 bracket middle witness, PDF p.7) and the below-anchor witness
  -- clause from the redesigned bracket (Def 3.1 monotone enumeration, PDF p.4).
  obtain ⟨a, hxa, hat, hanchor, hbelow, _habove⟩ :=
    kvE_subBracket2_extract (nf_depth0_char_formula atomMap h_surj) charK σ M atomMap x t h
  -- Feed the anchor to the explicit gate hypothesis (Amendment F3: no provider pinning).
  obtain ⟨haw, hwt, h_atom, h_off, h_fwd, h_bwd⟩ := hgate a hxa hat hanchor
  refine ⟨a, ?_⟩
  -- Assemble the depth-1 evaluation from the honest fold conditions (Def 4.1 p.6 note; the
  -- inside-out fold of `nf_eval_depth1_fold_iff` :5187, Prop 4.3 p.6 — rule N2).
  rw [nf_eval_depth1_fold_iff]
  refine ⟨h_atom, ?_, h_off⟩
  -- Zone matching: forward from the gate; backward from the gate for every zone EXCEPT the
  -- below-anchor `zXU`, whose witnesses are supplied by the bracket (Correction 1).
  intro zs χ
  refine ⟨fun hex => h_fwd zs χ hex, ?_⟩
  intro hbit
  by_cases hzs : zs = kvE_sub2_zXU
  · -- Below-anchor zone `zXU = (x < v < a)`: the bracket's own below-witness clause supplies a
    -- witness strictly below the anchor `a` (Def 3.1, PDF p.4; the redesign's signature witness).
    subst hzs
    obtain ⟨u, hxu, hua, hu⟩ := hbelow χ hbit
    refine ⟨u, ?_, (nfPred_correct M atomMap h_surj χ u).mp hu⟩
    -- `u` lies in `zXU` relative to env `[a, w, x, t]` under honest order `x < u < a < w < t`.
    have huw : u < w := hua.trans haw
    have hut : u < t := huw.trans hwt
    intro i
    match i with
    | ⟨0, _⟩ => exact ⟨iff_of_true hua rfl, iff_of_false (lt_asymm hua) (by decide +revert)⟩
    | ⟨1, _⟩ => exact ⟨iff_of_true huw rfl, iff_of_false (lt_asymm huw) (by decide +revert)⟩
    | ⟨2, _⟩ => exact ⟨iff_of_false (lt_asymm hxu) (by decide +revert), iff_of_true hxu rfl⟩
    | ⟨3, _⟩ => exact ⟨iff_of_true hut rfl, iff_of_false (lt_asymm hut) (by decide +revert)⟩
  · -- Every other zone: the gate's backward direction (analog of `kvE_gate` honesty).
    exact h_bwd zs χ hzs hbit

/-! ### Phase 5 — Completeness: fold extraction of inner witnesses (task 324)

The reverse-direction raw material. Starting from an honest depth-1 realization
`nf_eval_nf M 1 4 (Fin.cons x1 [w, x, t]) σ` at the anchor `x1`, `nf_eval_depth1_fold_iff`
(:5187 — the inside-out Def-4.1-p.6 fold, Prop 4.3 p.6) is driven FORWARD (`.mp`) to
decompose the realization into (a) the atom layer, (b) the per-zone fold conditions
`(∃ v, zoneHolds env zs v ∧ nf_eval_nf M 0 1 v χ) ↔ σ.2 (nf0_assemble zs χ σ.1) = true`, and
(c) the off-fiber falsity clause. The `.mpr` half of each interior-zone fold condition then
EXTRACTS, per positive fold bit, an honest depth-0 inner witness `v` together with its order
position relative to the anchor `x1` — the below-anchor `zXU` witness `x < v < x1` (the
redesign's Correction-1 signature datum, now extractable in the completeness direction too),
and the above-anchor `zUW` (`x1 < v < w`) and `zWT` (`w < v < t`) witnesses. This is the
monotone witness-enumeration data Phase 6 folds into `IntervalPattern.holds`; the three
interior zones are kept SEPARATE at source (the soundness `_extract` conflated `zUW`/`zWT`
into one disjunction — extraction supplies the finer, per-zone data Phase 6's per-slot
enumeration needs). The `zoneHolds`-to-inequalities conversion is the arity-4 lift of the
landed `k1v_zoneHolds_cons_iff` :2041 (Def 3.1 ordering channel, PDF p.4: the only channel
through which a quantified witness meets the fixed env points). No `simp`/`omega`/`aesop` on
chain steps (`by omega` is `Fin`-index typing in the cons-iff helper; `simp only [Fin.cons]`
is index reduction, byte-identical to the k1v helper). Rabinovich Def 4.1 (PDF p.5-6),
Prop 4.2 (md:100-101), Def 3.1 (md:61-74). -/

/-- `zoneHolds` over the arity-4 anchor env `[x1, w, x, t]` at a pointwise `Fin.cons` zone spec,
    unfolded to its four coordinate biconditionals — the arity-4 lift of `k1v_zoneHolds_cons_iff`
    :2041 (Def 3.1 ordering channel, PDF p.4). -/
private theorem kvE_sub2_zoneHolds_cons_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (e0 e1 e2 e3 v : M.carrier)
    (p0 p1 p2 p3 : Bool × Bool) :
    zoneHolds M (Fin.cons e0 (Fin.cons e1 (Fin.cons e2 (fun _ => e3))) : Fin 4 → M.carrier)
      (Fin.cons p0 (Fin.cons p1 (Fin.cons p2 (fun _ => p3))) : ZoneSpec 4) v ↔
    (((v < e0) ↔ p0.1 = true) ∧ ((e0 < v) ↔ p0.2 = true)) ∧
    (((v < e1) ↔ p1.1 = true) ∧ ((e1 < v) ↔ p1.2 = true)) ∧
    (((v < e2) ↔ p2.1 = true) ∧ ((e2 < v) ↔ p2.2 = true)) ∧
    (((v < e3) ↔ p3.1 = true) ∧ ((e3 < v) ↔ p3.2 = true)) := by
  constructor
  · intro h
    have h0 := h ⟨0, by omega⟩
    have h1 := h ⟨1, by omega⟩
    have h2 := h ⟨2, by omega⟩
    have h3 := h ⟨3, by omega⟩
    simp only [Fin.cons] at h0 h1 h2 h3
    exact ⟨h0, h1, h2, h3⟩
  · rintro ⟨h0, h1, h2, h3⟩ i
    match i with
    | ⟨0, _⟩ => simpa only [Fin.cons] using h0
    | ⟨1, _⟩ => simpa only [Fin.cons] using h1
    | ⟨2, _⟩ => simpa only [Fin.cons] using h2
    | ⟨3, _⟩ => simpa only [Fin.cons] using h3

/-- Below-anchor extraction: a `zXU` witness over the anchor env `[x1, w, x, t]` lies strictly
    inside `(x, x1)` — BELOW the anchor `x1` (Def 3.1, PDF p.4; the redesign's Correction-1
    below-anchor datum, extractable in the completeness direction). -/
private theorem kvE_sub2_zoneHolds_zXU {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (x1 w x t v : M.carrier)
    (hz : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) kvE_sub2_zXU v) :
    x < v ∧ v < x1 := by
  obtain ⟨hp0, _, hp2, _⟩ :=
    (kvE_sub2_zoneHolds_cons_iff M x1 w x t v (true, false) (true, false) (false, true)
      (true, false)).mp hz
  exact ⟨hp2.2.mpr rfl, hp0.1.mpr rfl⟩

/-- Above-anchor extraction: a `zUW` witness over the anchor env `[x1, w, x, t]` lies strictly
    inside `(x1, w)` — ABOVE the anchor `x1`, below `w` (Def 3.1, PDF p.4). -/
private theorem kvE_sub2_zoneHolds_zUW {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (x1 w x t v : M.carrier)
    (hz : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) kvE_sub2_zUW v) :
    x1 < v ∧ v < w := by
  obtain ⟨hp0, hp1, _, _⟩ :=
    (kvE_sub2_zoneHolds_cons_iff M x1 w x t v (false, true) (true, false) (false, true)
      (true, false)).mp hz
  exact ⟨hp0.2.mpr rfl, hp1.1.mpr rfl⟩

/-- Above-anchor extraction: a `zWT` witness over the anchor env `[x1, w, x, t]` lies strictly
    inside `(w, t)` — ABOVE `w` (Def 3.1, PDF p.4). -/
private theorem kvE_sub2_zoneHolds_zWT {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (x1 w x t v : M.carrier)
    (hz : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) kvE_sub2_zWT v) :
    w < v ∧ v < t := by
  obtain ⟨_, hp1, _, hp3⟩ :=
    (kvE_sub2_zoneHolds_cons_iff M x1 w x t v (false, true) (false, true) (false, true)
      (true, false)).mp hz
  exact ⟨hp1.2.mpr rfl, hp3.1.mpr rfl⟩

/-- **Completeness fold-extraction of inner witnesses** (task 324 Phase 5). Driving
    `nf_eval_depth1_fold_iff` (:5187) FORWARD on an honest depth-1 realization at the anchor
    `x1` yields the raw material for the reverse direction: the atom layer, the off-fiber
    falsity clause, the forward zone-honesty channel (every genuine zone witness marks its
    fold bit positive — consumed by the Phase-7 arrangement closure), and — per interior zone,
    kept SEPARATE — the monotone inner-witness enumeration Phase 6 folds into
    `IntervalPattern.holds`: each positive `zXU` fold bit yields a witness strictly BELOW the
    anchor (`x < v < x1`, the Correction-1 signature datum), each positive `zUW`/`zWT` bit a
    witness strictly ABOVE (`x1 < v < w`, resp. `w < v < t`), all as honest `nf_eval_nf M 0 1`
    evaluations. Rabinovich Def 4.1 (PDF p.5-6), Prop 4.2 (md:100-101), Def 3.1 (md:61-74). -/
theorem kvE_subBracket2_complete_extract {sig : MonadicSignature}
    (σ : NormalForm sig 1 4)
    (M : OrderedMonadicStructure sig)
    (x1 w x t : M.carrier)
    (h : nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    (∀ a : AtomKind sig 4,
        atom_eval M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) a ↔ σ.1 a = true) ∧
    (∀ τ : NormalForm sig 0 5, nf0_dropFresh τ ≠ σ.1 → σ.2 τ = false) ∧
    (∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1),
        (∃ v : M.carrier,
          zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) zs v ∧
          nf_eval_nf M 0 1 (fun _ => v) χ) →
        σ.2 (nf0_assemble zs χ σ.1) = true) ∧
    (∀ χ : NormalForm sig 0 1, σ.2 (nf0_assemble kvE_sub2_zXU χ σ.1) = true →
        ∃ v : M.carrier, x < v ∧ v < x1 ∧ nf_eval_nf M 0 1 (fun _ => v) χ) ∧
    (∀ χ : NormalForm sig 0 1, σ.2 (nf0_assemble kvE_sub2_zUW χ σ.1) = true →
        ∃ v : M.carrier, x1 < v ∧ v < w ∧ nf_eval_nf M 0 1 (fun _ => v) χ) ∧
    (∀ χ : NormalForm sig 0 1, σ.2 (nf0_assemble kvE_sub2_zWT χ σ.1) = true →
        ∃ v : M.carrier, w < v ∧ v < t ∧ nf_eval_nf M 0 1 (fun _ => v) χ) := by
  -- Forward fold decomposition (Prop 4.3 p.6, rule N2): atom layer + zone conditions + off-fiber.
  obtain ⟨h_atom, h_zone, h_off⟩ := (nf_eval_depth1_fold_iff M _ σ).mp h
  refine ⟨h_atom, h_off, fun zs χ hex => (h_zone zs χ).mp hex, ?_, ?_, ?_⟩
  · -- `zXU` below-anchor inner witnesses (Def 3.1 monotone enumeration, PDF p.4).
    intro χ hbit
    obtain ⟨v, hz, hv⟩ := (h_zone kvE_sub2_zXU χ).mpr hbit
    obtain ⟨hxv, hvx1⟩ := kvE_sub2_zoneHolds_zXU M x1 w x t v hz
    exact ⟨v, hxv, hvx1, hv⟩
  · -- `zUW` above-anchor inner witnesses.
    intro χ hbit
    obtain ⟨v, hz, hv⟩ := (h_zone kvE_sub2_zUW χ).mpr hbit
    obtain ⟨hx1v, hvw⟩ := kvE_sub2_zoneHolds_zUW M x1 w x t v hz
    exact ⟨v, hx1v, hvw, hv⟩
  · -- `zWT` above-`w` inner witnesses.
    intro χ hbit
    obtain ⟨v, hz, hv⟩ := (h_zone kvE_sub2_zWT χ).mpr hbit
    obtain ⟨hwv, hvt⟩ := kvE_sub2_zoneHolds_zWT M x1 w x t v hz
    exact ⟨v, hwv, hvt, hv⟩

/-! ## Task 325 Phase 1: `VVecEA2` arrangement-disjunction carrier (redesign)

Additive, separately-named redesign of the task-324 k=2 sub-bracket (task 325 Phase 1; plan
`plans/01_vvecea2-carrier-redesign.md`). The landed `kvE_subBracket2` (:6120) returns a single
`Σ m, BracketFormula (m+1)` with a CONSTANT tri-zone `segmentTypes ≡ segExcl` (:6159) and a FIXED
filter-order `pointTypes`; its completeness converse is a machine-confirmed false ∀-M statement
(task 324 Phase 6). This block delivers, STANDALONE against `nf_eval_nf M 1 4` and NOT wired into the
outer gate, a corrected carrier `kvE_subBracket2V` whose codomain is `VVecEA2` (the arrangement
disjunction, VecEAFormula:271) with THREE per-region segment types `segXU`/`segUW`/`segWT` and TWO
interior witness slots `x1`/`w`. It LIFTS `bracketEndChar_k1v` (:1940) one region up: k1v's
`bracketFromLists lL ptW lR` (:1896, a 2-region `lL ++ ptW :: lR` with two segments `segL`/`segR`)
becomes `bracketFromLists3 lXU ptX1 lUW ptW lWT` (a 3-region `lXU ++ ptX1 :: lUW ++ ptW :: lWT` with
three per-region segments). Env `[x1, w, x, t]` under honest order `x < x1 < w < t` (coords
`0 ↦ x1`, `1 ↦ w`, `2 ↦ x`, `3 ↦ t`) — identical coordinate layout to task-324's `[u, w, x, t]`, so
the SURVIVE zone specs `kvE_sub2_zXU`/`_zUW`/`_zWT` (:6200-6208) are the same three interior zones.
Every landed asset stays byte-identical AND unreferenced. `σ.2` is read through the depth-0
`nf0_assemble` fold engine directly (consume-do-not-rebuild), same as `kvE_subBracket2` :6127.
No `simp`/`omega`/`aesop` in any body (the `omega` is a `Fin`-index typing obligation in a proof
term, identical to `bracketFromLists` :1900). Rabinovich Def 3.1 (md:61-74), Def 4.1 (PDF p.5), §5
bracket `[α_0, …, α_n](z_0, z_1)` (PDF p.7), Cor 5.4 recursive per-region chain (md:154-157). -/

/-- **Arity-4 (three-region) lift of `bracketFromLists`** (:1896; task 325 Phase 1). Assemble a
    `BracketFormula` over the two FIXED endpoints `{x, t}` from THREE ordered witness-type lists
    `lXU`/`lUW`/`lWT` and TWO interior witness-slot point types `ptX1` (between `lXU` and `lUW`) and
    `ptW` (between `lUW` and `lWT`), with THREE per-region segment types. Point types are
    `lXU ++ ptX1 :: lUW ++ ptW :: lWT` — the §5 bracket `[α_0, …, α_n](z_0, z_1)` (PDF p.7) with
    `z_0, z_1` the FIXED endpoints and `x1`/`w` interior WITNESS slots. Segment types are `segXU` on
    every sub-segment of `(x, x1)` (index `≤ lXU.length`), `segUW` on every sub-segment of `(x1, w)`
    (index `≤ lXU.length + 1 + lUW.length`), and `segWT` on every sub-segment of `(w, t)` — real
    PER-REGION exclusion segments, NEVER a constant tri-zone `segExcl` (G3; Rabinovich Cor 5.4
    md:154-157). The arity is written `… + 1 + 1` so `fChainPred` (which needs a `_ + 1` arity) is
    available. -/
private def bracketFromLists3 (lXU : List TemporalPred) (ptX1 : TemporalPred)
    (lUW : List TemporalPred) (ptW : TemporalPred) (lWT : List TemporalPred)
    (segXU segUW segWT : TemporalPred) :
    BracketFormula (lXU.length + lUW.length + lWT.length + 1 + 1) where
  pointTypes := fun i =>
    (lXU ++ ptX1 :: lUW ++ ptW :: lWT)[i.val]'(by
      have := i.isLt
      simp only [List.length_append, List.length_cons]
      omega)
  segmentTypes := fun i =>
    if i.val ≤ lXU.length then segXU
    else if i.val ≤ lXU.length + 1 + lUW.length then segUW
    else segWT

/-- **`VVecEA2` arrangement-disjunction carrier** (task 325 Phase 1; plan Phase 1). The corrected
    codomain-changed replacement for `kvE_subBracket2` (:6120): a finite disjunction `VVecEA2`
    (VecEAFormula:271) over arrangements `S_XU.permutations × S_UW.permutations × S_WT.permutations`,
    where `S_z = allTypes.filter (bits z)` is the duplicate-free list of interior-positive 1-types of
    region `z`. Each disjunct's point-type layout is `zXU-arrangement ++ [x1-slot] ++
    zUW-arrangement ++ [w-slot] ++ zWT-arrangement` (three-region lift of `bracketEndChar_k1v`
    :2016-2018), with THREE per-region segment types (never the refuted constant `segExcl`). `x1`/`w`
    are interior WITNESS slots (anchor set stays `{x, t}`; G4/Cap): `x1` is the fresh depth-1
    existential witness (`nfk_projFresh σ`, coord 0), `w` enters as a witness TYPE slot — `charBase`
    of `w`'s coord-1 projection (Amendment F3: no provider pinning, realized by 1-type uniqueness).
    Gate-failure branch is the empty disjunction `{ disjuncts := [] }` (its `holds` is `False`).
    Reads `σ.2 ∘ nf0_assemble` at gate instance `j = 0` (Def 4.1, PDF p.5). -/
noncomputable def kvE_subBracket2V {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4) : VVecEA2 :=
  -- Sub-level fold-bit read (Def 4.1, PDF p.5): `σ.2 ∘ nf0_assemble` at the gate instance j = 0,
  -- inlined (consume-do-not-rebuild) so no landed sub-bracket symbol is referenced.
  let bits : ZoneSpec 4 → NormalForm sig 0 1 → Bool :=
    fun zs χ => σ.2 (nf0_assemble zs χ σ.1)
  let allTypes : List (NormalForm sig 0 1) := Finset.univ.toList
  -- Zone-spec constants relative to σ's env `[x1, w, x, t]` under honest order `x < x1 < w < t`
  -- (coords 0 ↦ x1, 1 ↦ w, 2 ↦ x, 3 ↦ t); same coordinate layout as `kvE_subInteriorZones` :5751
  -- and the SURVIVE zone specs `kvE_sub2_zXU`/`_zUW`/`_zWT` :6200-6208.
  let ltz : Bool × Bool := (true, false)   -- v < env i
  let eqz : Bool × Bool := (false, false)  -- v = env i
  let gtz : Bool × Bool := (false, true)   -- env i < v
  let mk4 : Bool × Bool → Bool × Bool → Bool × Bool → Bool × Bool → ZoneSpec 4 :=
    fun p0 p1 p2 p3 => Fin.cons p0 (Fin.cons p1 (Fin.cons p2 (fun _ => p3)))
  -- Three interior zones (Def 3.1 md:61-74), defeq to `kvE_sub2_zXU`/`_zUW`/`_zWT` :6200-6208.
  let zXU : ZoneSpec 4 := mk4 ltz ltz gtz ltz   -- x < v < x1
  let zUW : ZoneSpec 4 := mk4 gtz ltz gtz ltz   -- x1 < v < w
  let zWT : ZoneSpec 4 := mk4 gtz gtz gtz ltz   -- w < v < t
  -- Two interior WITNESS SELF-ZONES (v2 nine-zone correction; Def 3.1 md:61-74). Every honest σ
  -- realizes x1 at its own self-zone (and w at its), so `nf_eval_depth1_fold_iff` (:5187) forces
  -- `bits zAtX1 = true` (resp. `bits zAtW = true`); these MUST therefore be gate-consistent, else
  -- the gate is unsatisfiable (the machine-verified v1 empty-gate blocker). k1v folds its single
  -- witness self-zone `zAtW` :3277; the arity-4 carrier has TWO interior witnesses ⇒ two self-zones.
  let zAtX1 : ZoneSpec 4 := mk4 eqz ltz gtz ltz   -- v = x1
  let zAtW  : ZoneSpec 4 := mk4 gtz eqz gtz ltz   -- v = w
  -- Exterior zones for the two FIXED endpoints (Def 3.1 md:61-74).
  let zPastX : ZoneSpec 4 := mk4 ltz ltz ltz ltz   -- v < x
  let zAtX   : ZoneSpec 4 := mk4 ltz ltz eqz ltz   -- v = x
  let zAtT   : ZoneSpec 4 := mk4 gtz gtz gtz eqz   -- v = t
  let zFutT  : ZoneSpec 4 := mk4 gtz gtz gtz gtz   -- t < v
  -- Depth-0 coordinate projections of σ's base env `σ.1 : NormalForm sig 0 4` (Def 3.1, PDF p.4;
  -- arity-4 analog of `nf_x_proj3`/`nf_t_proj3` VecEADecomp:40/47).
  let proj : Fin 4 → NormalForm sig 0 1 := fun k =>
    fun a => match a with
      | .pred p _ => σ.1 (.pred p k)
      | .order i j h => absurd (Subsingleton.elim i j) h
  -- Biconditional literal at an anchor (Prop 3.5 folding mechanism, PDF p.5).
  let lit : Bool → Formula → Formula := fun bit f => if bit then f else f.neg
  -- Endpoint types at the FIXED `z_0 = x` (coord 2), `z_1 = t` (coord 3): Lemma 3.2(2), PDF p.4.
  let xType : TemporalPred := ⟨charBase (proj 2)⟩
  let tType : TemporalPred := ⟨charBase (proj 3)⟩
  let epL : TemporalPred :=
    ⟨formula_conjList
      (xType.formula
        :: (allTypes.map fun χ => lit (bits zPastX χ) (Formula.snce (charBase χ) Formula.top))
        ++ (allTypes.map fun χ => lit (bits zAtX χ) (charBase χ)))⟩
  let epR : TemporalPred :=
    ⟨formula_conjList
      (tType.formula
        :: (allTypes.map fun χ => lit (bits zAtT χ) (charBase χ))
        ++ (allTypes.map fun χ => lit (bits zFutT χ) (Formula.untl (charBase χ) Formula.top)))⟩
  -- THREE per-region segment types: each excludes ONLY its own region's interior negatives (real
  -- exclusion segments, G3; arity-4 lift of `bracketFromLists.segmentTypes` :1902 from a 2-way to a
  -- 3-way keying). NOT the constant tri-zone `segExcl` of the refuted :6149. Rabinovich Cor 5.4
  -- (md:154-157): every point of region `(x, x1)` is `zXU`-positive there, etc.
  let segXU : TemporalPred :=
    ⟨formula_conjList (allTypes.map fun χ => if bits zXU χ then Formula.top else (charBase χ).neg)⟩
  let segUW : TemporalPred :=
    ⟨formula_conjList (allTypes.map fun χ => if bits zUW χ then Formula.top else (charBase χ).neg)⟩
  let segWT : TemporalPred :=
    ⟨formula_conjList (allTypes.map fun χ => if bits zWT χ then Formula.top else (charBase χ).neg)⟩
  -- Interior witness-slot point types (§5 bracket, PDF p.7): `x1` is the fresh depth-1 existential
  -- witness (coord 0, `nfk_projFresh σ`); `w` is the given interior anchor entering as a witness
  -- TYPE slot (Amendment F3 — no provider pinning; `charBase` of `w`'s coord-1 projection, realized
  -- by 1-type uniqueness).
  -- Witness self-type FOLDING (v2 nine-zone correction; arity-4 analog of k1v `hptW` :3277). Each
  -- witness point type carries its complete type (head) PLUS its own self-zone's 1-type literals, so
  -- soundness can re-derive the self-zone membership and completeness can discharge the witness
  -- point. Amendment F3 preserved: a zone-literal fold on the complete 1-type, NOT a `w = e 1`
  -- provider equation. `ptX1` folds `zAtX1`; `ptW` folds `zAtW`.
  let ptX1 : TemporalPred :=
    ⟨formula_conjList
      (charK (nfk_projFresh σ)
        :: (allTypes.map fun χ => lit (bits zAtX1 χ) (charBase χ)))⟩
  let ptW : TemporalPred :=
    ⟨formula_conjList
      (charBase (proj 1)
        :: (allTypes.map fun χ => lit (bits zAtW χ) (charBase χ)))⟩
  let charP : NormalForm sig 0 1 → TemporalPred := fun χ => ⟨charBase χ⟩
  -- Interior-positive enumerations, per region (duplicate-free `Finset.univ.toList`).
  let S_XU : List (NormalForm sig 0 1) := allTypes.filter (fun χ => bits zXU χ)
  let S_UW : List (NormalForm sig 0 1) := allTypes.filter (fun χ => bits zUW χ)
  let S_WT : List (NormalForm sig 0 1) := allTypes.filter (fun χ => bits zWT χ)
  -- Consistency of a zone spec with the bracket order `x < x1 < w < t` (NINE real zones: the seven
  -- exterior/interior zones PLUS the two interior witness self-zones `zAtX1`, `zAtW` — the v2
  -- correction of the v1 empty-gate blocker, mirroring k1v's inclusion of its witness self-zone).
  let consistent : ZoneSpec 4 → Prop := fun zs =>
    zs = zPastX ∨ zs = zAtX ∨ zs = zXU ∨ zs = zAtX1 ∨ zs = zUW ∨ zs = zAtW ∨ zs = zWT ∨
      zs = zAtT ∨ zs = zFutT
  -- Gate (off-fiber honesty + order-conflict falsity): the arity-4 analog of k1v :1998.
  let gate : Prop :=
    (∀ sub : NormalForm sig 0 5, nf0_dropFresh sub ≠ σ.1 → σ.2 sub = false) ∧
    (∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1), ¬ consistent zs → bits zs χ = false)
  -- One disjunct per arrangement (rule N5): interior-positive pairs occupy WITNESS slots ordered
  -- between the fixed endpoints across the THREE regions `zXU`/`zUW`/`zWT`.
  let mkDisjunct :
      List (NormalForm sig 0 1) → List (NormalForm sig 0 1) → List (NormalForm sig 0 1) →
        Σ n, VecEA2 n :=
    fun lXU lUW lWT =>
      ⟨(lXU.map charP).length + (lUW.map charP).length + (lWT.map charP).length + 1 + 1,
        { endpointLeft := epL
          endpointRight := epR
          bracket := bracketFromLists3 (lXU.map charP) ptX1 (lUW.map charP) ptW (lWT.map charP)
            segXU segUW segWT }⟩
  @dite _ gate (Classical.dec gate)
    (fun _ =>
      { disjuncts :=
          S_XU.permutations.flatMap fun lXU =>
            S_UW.permutations.flatMap fun lUW =>
              S_WT.permutations.map fun lWT => mkDisjunct lXU lUW lWT })
    (fun _ => { disjuncts := [] })

/-- **Three-region sub-chain accessor over the `VVecEA2` disjunct carrier** (task 325 Phase 1;
    analog of `kvE_subChain2` :6166 adapted to the disjunction shape). `kvE_subChain2` was the
    single bracket's `fChainPred`; here the carrier is a disjunction, so the accessor is the list of
    per-arrangement `fChainPred`s — one Cor 5.4 F_i-chain (md:154-157) per disjunct, each evaluated
    over the three-region bracket `bracketFromLists3` (whose `… + 1` arity makes `fChainPred`
    available). The k1v soundness/completeness templates reason per-disjunct rather than through a
    single chain, so this accessor is provided for interface parity with the landed k=2 kit. -/
noncomputable def kvE_subChain2V {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4) : List TemporalPred :=
  let bits : ZoneSpec 4 → NormalForm sig 0 1 → Bool :=
    fun zs χ => σ.2 (nf0_assemble zs χ σ.1)
  let allTypes : List (NormalForm sig 0 1) := Finset.univ.toList
  let ltz : Bool × Bool := (true, false)
  let gtz : Bool × Bool := (false, true)
  let mk4 : Bool × Bool → Bool × Bool → Bool × Bool → Bool × Bool → ZoneSpec 4 :=
    fun p0 p1 p2 p3 => Fin.cons p0 (Fin.cons p1 (Fin.cons p2 (fun _ => p3)))
  let zXU : ZoneSpec 4 := mk4 ltz ltz gtz ltz
  let zUW : ZoneSpec 4 := mk4 gtz ltz gtz ltz
  let zWT : ZoneSpec 4 := mk4 gtz gtz gtz ltz
  let proj : Fin 4 → NormalForm sig 0 1 := fun k =>
    fun a => match a with
      | .pred p _ => σ.1 (.pred p k)
      | .order i j h => absurd (Subsingleton.elim i j) h
  let segXU : TemporalPred :=
    ⟨formula_conjList (allTypes.map fun χ => if bits zXU χ then Formula.top else (charBase χ).neg)⟩
  let segUW : TemporalPred :=
    ⟨formula_conjList (allTypes.map fun χ => if bits zUW χ then Formula.top else (charBase χ).neg)⟩
  let segWT : TemporalPred :=
    ⟨formula_conjList (allTypes.map fun χ => if bits zWT χ then Formula.top else (charBase χ).neg)⟩
  let ptX1 : TemporalPred := ⟨charK (nfk_projFresh σ)⟩
  let ptW : TemporalPred := ⟨charBase (proj 1)⟩
  let charP : NormalForm sig 0 1 → TemporalPred := fun χ => ⟨charBase χ⟩
  let S_XU : List (NormalForm sig 0 1) := allTypes.filter (fun χ => bits zXU χ)
  let S_UW : List (NormalForm sig 0 1) := allTypes.filter (fun χ => bits zUW χ)
  let S_WT : List (NormalForm sig 0 1) := allTypes.filter (fun χ => bits zWT χ)
  S_XU.permutations.flatMap fun lXU =>
    S_UW.permutations.flatMap fun lUW =>
      S_WT.permutations.map fun lWT =>
        (bracketFromLists3 (lXU.map charP) ptX1 (lUW.map charP) ptW (lWT.map charP)
          segXU segUW segWT).fChainPred

/-- **Three-region arrangement selection** (task 325 Phase 2; lift of `k1v_sorted_realization`
    :2797 from two regions to three). Given three duplicate-free interior-positive type lists
    `S_XU`/`S_UW`/`S_WT`, each realized somewhere strictly inside its own open region `(x, x1)` /
    `(x1, w)` / `(w, t)`, produce three arrangements — permutations of the three lists tagged with
    realizing points — whose combined witness list `psXU ++ x1 :: psUW ++ w :: psWT` (in model
    order) is strictly increasing. Runs the per-region insertion induction `k1v_sorted_realization`
    (Rabinovich Lemma 5.1 md:134-135) once per region, then stitches the three sorted blocks around
    the two fixed interior witnesses `x1`/`w` (Def 3.1 strictly-increasing witnesses md:61-74). The
    `VVecEA2` disjunction carries every arrangement (rule N5), so the arrangement selected here
    always names an existing disjunct. -/
private theorem k1v_sorted_realization3 {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (x x1 w t : M.carrier) (hxx1 : x < x1) (hx1w : x1 < w) (hwt : w < t)
    (S_XU S_UW S_WT : List (NormalForm sig 0 1))
    (hndXU : S_XU.Nodup) (hndUW : S_UW.Nodup) (hndWT : S_WT.Nodup)
    (hrealXU : ∀ χ ∈ S_XU, ∃ u, x < u ∧ u < x1 ∧ nf_eval_nf M 0 1 (fun _ => u) χ)
    (hrealUW : ∀ χ ∈ S_UW, ∃ u, x1 < u ∧ u < w ∧ nf_eval_nf M 0 1 (fun _ => u) χ)
    (hrealWT : ∀ χ ∈ S_WT, ∃ u, w < u ∧ u < t ∧ nf_eval_nf M 0 1 (fun _ => u) χ) :
    ∃ (psXU psUW psWT : List (NormalForm sig 0 1 × M.carrier)),
      List.Perm (psXU.map Prod.fst) S_XU ∧
      List.Perm (psUW.map Prod.fst) S_UW ∧
      List.Perm (psWT.map Prod.fst) S_WT ∧
      (psXU.map Prod.snd ++ x1 :: psUW.map Prod.snd ++ w :: psWT.map Prod.snd).Pairwise (· < ·) ∧
      (∀ p ∈ psXU, (x < p.2 ∧ p.2 < x1) ∧ nf_eval_nf M 0 1 (fun _ => p.2) p.1) ∧
      (∀ p ∈ psUW, (x1 < p.2 ∧ p.2 < w) ∧ nf_eval_nf M 0 1 (fun _ => p.2) p.1) ∧
      (∀ p ∈ psWT, (w < p.2 ∧ p.2 < t) ∧ nf_eval_nf M 0 1 (fun _ => p.2) p.1) := by
  -- Per-region insertion induction (Rabinovich Lemma 5.1 md:134-135), once per region.
  obtain ⟨psXU, hpermXU, hsortXU, hpropsXU⟩ :=
    k1v_sorted_realization M x x1 S_XU hndXU hrealXU
  obtain ⟨psUW, hpermUW, hsortUW, hpropsUW⟩ :=
    k1v_sorted_realization M x1 w S_UW hndUW hrealUW
  obtain ⟨psWT, hpermWT, hsortWT, hpropsWT⟩ :=
    k1v_sorted_realization M w t S_WT hndWT hrealWT
  refine ⟨psXU, psUW, psWT, hpermXU, hpermUW, hpermWT, ?_, hpropsXU, hpropsUW, hpropsWT⟩
  -- Stitch the three sorted blocks around `x1` and `w` (Def 3.1 strictly-increasing witnesses).
  -- Every `psUW` point exceeds `x1`; every point of the left block `psXU ++ x1 :: psUW` is < w.
  have hUW_gt_x1 : ∀ b ∈ psUW.map Prod.snd, x1 < b := by
    intro b hb
    obtain ⟨p, hp, rfl⟩ := List.mem_map.mp hb
    exact (hpropsUW p hp).1.1
  have hWT_gt_w : ∀ b ∈ psWT.map Prod.snd, w < b := by
    intro b hb
    obtain ⟨p, hp, rfl⟩ := List.mem_map.mp hb
    exact (hpropsWT p hp).1.1
  have hleft_lt_w : ∀ a ∈ psXU.map Prod.snd ++ x1 :: psUW.map Prod.snd, a < w := by
    intro a ha
    rcases List.mem_append.mp ha with ha | ha
    · obtain ⟨p, hp, rfl⟩ := List.mem_map.mp ha
      exact ((hpropsXU p hp).1.2).trans hx1w
    · rcases List.mem_cons.mp ha with rfl | ha
      · exact hx1w
      · obtain ⟨p, hp, rfl⟩ := List.mem_map.mp ha
        exact (hpropsUW p hp).1.2
  rw [List.pairwise_append]
  refine ⟨?_, ?_, ?_⟩
  · -- Left block `psXU ++ x1 :: psUW` is sorted.
    rw [List.pairwise_append]
    refine ⟨hsortXU, ?_, ?_⟩
    · rw [List.pairwise_cons]
      exact ⟨hUW_gt_x1, hsortUW⟩
    · intro a ha b hb
      obtain ⟨p, hp, rfl⟩ := List.mem_map.mp ha
      have hax1 : p.2 < x1 := (hpropsXU p hp).1.2
      rcases List.mem_cons.mp hb with rfl | hb
      · exact hax1
      · exact hax1.trans (hUW_gt_x1 b hb)
  · -- Right block `w :: psWT` is sorted.
    rw [List.pairwise_cons]
    exact ⟨hWT_gt_w, hsortWT⟩
  · -- Cross: every left-block point < every right-block point.
    intro a ha b hb
    have haw : a < w := hleft_lt_w a ha
    rcases List.mem_cons.mp hb with rfl | hb
    · exact haw
    · exact haw.trans (hWT_gt_w b hb)

/-- **Three-region bracket construction** (task 325 Phase 2; lift of `k1v_bracket_construct` :2838
    to `bracketFromLists3`). The reverse of point-type extraction: given a sorted tuple of realizing
    points — `usXU` strictly inside `(x, x1)`, the interior witness `x1`, `usUW` strictly inside
    `(x1, w)`, the interior witness `w`, `usWT` strictly inside `(w, t)` — with each point type
    realized at its point, the two interior witness types realized at `x1`/`w`, and the three
    per-region exclusions `segXU`/`segUW`/`segWT` holding on ALL of `(x, x1)`/`(x1, w)`/`(w, t)`, the
    three-region bracket holds at the FIXED endpoints `(x, t)`. Mirrors the append-a-witness
    construction of `existsBounded_right` (VecEAClosure:265; Lemma 3.4 PDF p.5) with the witness
    tuple assembled wholesale from `k1v_sorted_realization3`. Cite Rabinovich Lemma 5.3
    (md:137-152). -/
private theorem k1v_bracket_construct3 {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (lXU lUW lWT : List TemporalPred) (ptX1 ptW segXU segUW segWT : TemporalPred)
    (x x1 w t : M.carrier) (hxx1 : x < x1) (hx1w : x1 < w) (hwt : w < t)
    (usXU usUW usWT : List M.carrier)
    (hlenXU : usXU.length = lXU.length) (hlenUW : usUW.length = lUW.length)
    (hlenWT : usWT.length = lWT.length)
    (hsort : (usXU ++ x1 :: usUW ++ w :: usWT).Pairwise (· < ·))
    (hrangeXU : ∀ u ∈ usXU, x < u ∧ u < x1)
    (hrangeUW : ∀ u ∈ usUW, x1 < u ∧ u < w)
    (hrangeWT : ∀ u ∈ usWT, w < u ∧ u < t)
    (hptx1 : ptX1.eval_at M atomMap x1)
    (hptw : ptW.eval_at M atomMap w)
    (hptXU : ∀ (i : Nat) (hi : i < lXU.length),
      (lXU[i]'hi).eval_at M atomMap (usXU[i]'(by omega)))
    (hptUW : ∀ (i : Nat) (hi : i < lUW.length),
      (lUW[i]'hi).eval_at M atomMap (usUW[i]'(by omega)))
    (hptWT : ∀ (i : Nat) (hi : i < lWT.length),
      (lWT[i]'hi).eval_at M atomMap (usWT[i]'(by omega)))
    (hsegXU : ∀ u, x < u → u < x1 → segXU.eval_at M atomMap u)
    (hsegUW : ∀ u, x1 < u → u < w → segUW.eval_at M atomMap u)
    (hsegWT : ∀ u, w < u → u < t → segWT.eval_at M atomMap u) :
    (bracketFromLists3 lXU ptX1 lUW ptW lWT segXU segUW segWT).holds M atomMap x t := by
  -- Combined witness list and its length.
  have hlen : (usXU ++ x1 :: usUW ++ w :: usWT).length
      = lXU.length + lUW.length + lWT.length + 1 + 1 := by
    simp only [List.length_append, List.length_cons, hlenXU, hlenUW, hlenWT]; omega
  -- Strict monotonicity of the combined list, as getElem comparisons.
  have hmono : ∀ (a b : Nat) (ha : a < (usXU ++ x1 :: usUW ++ w :: usWT).length)
      (hb : b < (usXU ++ x1 :: usUW ++ w :: usWT).length), a < b →
      (usXU ++ x1 :: usUW ++ w :: usWT)[a] < (usXU ++ x1 :: usUW ++ w :: usWT)[b] :=
    fun a b ha hb hab => List.pairwise_iff_getElem.mp hsort a b ha hb hab
  -- The two interior witnesses sit at fixed indices: `x1` at `usXU.length`, `w` after the UW block.
  have hx1_at : (usXU ++ x1 :: usUW ++ w :: usWT)[usXU.length]'(by rw [hlen]; omega) = x1 := by
    rw [List.getElem_append_left (show usXU.length < (usXU ++ x1 :: usUW).length by
          simp only [List.length_append, List.length_cons]; omega)]
    rw [List.getElem_append_right (le_refl usXU.length)]
    simp only [Nat.sub_self, List.getElem_cons_zero]
  have hw_at : (usXU ++ x1 :: usUW ++ w :: usWT)[usXU.length + 1 + usUW.length]'(by
        rw [hlen]; omega) = w := by
    rw [List.getElem_append_right (show (usXU ++ x1 :: usUW).length ≤ usXU.length + 1 + usUW.length by
          simp only [List.length_append, List.length_cons]; omega)]
    simp only [show usXU.length + 1 + usUW.length - (usXU ++ x1 :: usUW).length = 0 by
      simp only [List.length_append, List.length_cons]; omega, List.getElem_cons_zero]
  -- Comparison helpers derived from monotonicity around the two interior anchors.
  have hle_x1 : ∀ (j : Nat) (hj1 : j ≤ usXU.length)
      (hj2 : j < (usXU ++ x1 :: usUW ++ w :: usWT).length),
      (usXU ++ x1 :: usUW ++ w :: usWT)[j] ≤ x1 := by
    intro j hj1 hj2
    rcases Nat.lt_or_eq_of_le hj1 with hj | hj
    · exact le_of_lt (lt_of_lt_of_eq (hmono j usXU.length hj2 (by rw [hlen]; omega) hj) hx1_at)
    · subst hj; exact le_of_eq hx1_at
  have hge_x1 : ∀ (j : Nat) (hj1 : usXU.length ≤ j)
      (hj2 : j < (usXU ++ x1 :: usUW ++ w :: usWT).length),
      x1 ≤ (usXU ++ x1 :: usUW ++ w :: usWT)[j] := by
    intro j hj1 hj2
    rcases Nat.lt_or_eq_of_le hj1 with hj | hj
    · exact le_of_lt (lt_of_eq_of_lt hx1_at.symm (hmono usXU.length j (by rw [hlen]; omega) hj2 hj))
    · subst hj; exact le_of_eq hx1_at.symm
  have hle_w : ∀ (j : Nat) (hj1 : j ≤ usXU.length + 1 + usUW.length)
      (hj2 : j < (usXU ++ x1 :: usUW ++ w :: usWT).length),
      (usXU ++ x1 :: usUW ++ w :: usWT)[j] ≤ w := by
    intro j hj1 hj2
    rcases Nat.lt_or_eq_of_le hj1 with hj | hj
    · exact le_of_lt (lt_of_lt_of_eq
        (hmono j (usXU.length + 1 + usUW.length) hj2 (by rw [hlen]; omega) hj) hw_at)
    · subst hj; exact le_of_eq hw_at
  have hge_w : ∀ (j : Nat) (hj1 : usXU.length + 1 + usUW.length ≤ j)
      (hj2 : j < (usXU ++ x1 :: usUW ++ w :: usWT).length),
      w ≤ (usXU ++ x1 :: usUW ++ w :: usWT)[j] := by
    intro j hj1 hj2
    rcases Nat.lt_or_eq_of_le hj1 with hj | hj
    · exact le_of_lt (lt_of_eq_of_lt hw_at.symm
        (hmono (usXU.length + 1 + usUW.length) j (by rw [hlen]; omega) hj2 hj))
    · subst hj; exact le_of_eq hw_at.symm
  -- Every combined-list point lies strictly inside the fixed endpoints `(x, t)`.
  have hrange_all : ∀ u ∈ usXU ++ x1 :: usUW ++ w :: usWT, x < u ∧ u < t := by
    intro u hu
    rcases List.mem_append.mp hu with hu | hu
    · rcases List.mem_append.mp hu with hu | hu
      · exact ⟨(hrangeXU _ hu).1, (hrangeXU _ hu).2.trans (hx1w.trans hwt)⟩
      · rcases List.mem_cons.mp hu with rfl | hu
        · exact ⟨hxx1, hx1w.trans hwt⟩
        · exact ⟨hxx1.trans (hrangeUW _ hu).1, (hrangeUW _ hu).2.trans hwt⟩
    · rcases List.mem_cons.mp hu with rfl | hu
      · exact ⟨hxx1.trans hx1w, hwt⟩
      · exact ⟨(hxx1.trans hx1w).trans (hrangeWT _ hu).1, (hrangeWT _ hu).2⟩
  simp only [BracketFormula.holds, BracketFormula.toIntervalPattern, bracketFromLists3]
  rw [IntervalPattern.holds_eq_succ M atomMap _ _ x t
    (show lXU.length + lUW.length + lWT.length + 1 + 1
        = (lXU.length + lUW.length + lWT.length + 1) + 1 by omega)]
  refine ⟨fun i => (usXU ++ x1 :: usUW ++ w :: usWT)[i.val]'(by
      have := i.isLt; rw [hlen]; omega), ?_, ?_, ?_, ?_, ?_, ?_⟩
  · -- Strict monotonicity.
    intro i j hij
    exact hmono i.val j.val (by have := i.isLt; rw [hlen]; omega)
      (by have := j.isLt; rw [hlen]; omega) hij
  · -- Range: all points strictly inside `(x, t)`.
    intro i
    exact hrange_all _ (List.getElem_mem _)
  · -- Point types: five-way index split around the two interior witness slots.
    intro i
    simp only []
    rcases Nat.lt_trichotomy i.val lXU.length with hi | hi | hi
    · -- (a) `usXU` / `lXU` region.
      rw [List.getElem_append_left (show i.val < (lXU ++ ptX1 :: lUW).length by
            simp only [List.length_append, List.length_cons]; omega),
        List.getElem_append_left hi,
        List.getElem_append_left (show i.val < (usXU ++ x1 :: usUW).length by
            simp only [List.length_append, List.length_cons]; omega),
        List.getElem_append_left (show i.val < usXU.length by omega)]
      exact hptXU i.val hi
    · -- (b) `x1` interior witness slot.
      rw [List.getElem_append_left (show i.val < (lXU ++ ptX1 :: lUW).length by
            simp only [List.length_append, List.length_cons]; omega),
        List.getElem_append_right (show lXU.length ≤ i.val from le_of_eq hi.symm),
        List.getElem_append_left (show i.val < (usXU ++ x1 :: usUW).length by
            simp only [List.length_append, List.length_cons]; omega),
        List.getElem_append_right (show usXU.length ≤ i.val by omega)]
      simp only [show i.val - lXU.length = 0 by omega, show i.val - usXU.length = 0 by omega,
        List.getElem_cons_zero]
      exact hptx1
    · -- `i.val > lXU.length`: split around the `w` slot at `lXU.length + 1 + lUW.length`.
      rcases Nat.lt_trichotomy i.val (lXU.length + 1 + lUW.length) with hi2 | hi2 | hi2
      · -- (c) `usUW` / `lUW` region.
        obtain ⟨j, hj⟩ : ∃ j, i.val = lXU.length + 1 + j := ⟨i.val - lXU.length - 1, by omega⟩
        have hjUW : j < lUW.length := by omega
        rw [List.getElem_append_left (show i.val < (lXU ++ ptX1 :: lUW).length by
              simp only [List.length_append, List.length_cons]; omega),
          List.getElem_append_right (show lXU.length ≤ i.val by omega),
          List.getElem_append_left (show i.val < (usXU ++ x1 :: usUW).length by
              simp only [List.length_append, List.length_cons]; omega),
          List.getElem_append_right (show usXU.length ≤ i.val by omega)]
        simp only [show i.val - lXU.length = j + 1 by omega,
          show i.val - usXU.length = j + 1 by omega, List.getElem_cons_succ]
        exact hptUW j hjUW
      · -- (d) `w` interior witness slot.
        rw [List.getElem_append_right (show (lXU ++ ptX1 :: lUW).length ≤ i.val by
              simp only [List.length_append, List.length_cons]; omega),
          List.getElem_append_right (show (usXU ++ x1 :: usUW).length ≤ i.val by
              simp only [List.length_append, List.length_cons]; omega)]
        simp only [show i.val - (lXU ++ ptX1 :: lUW).length = 0 by
            simp only [List.length_append, List.length_cons]; omega,
          show i.val - (usXU ++ x1 :: usUW).length = 0 by
            simp only [List.length_append, List.length_cons]; omega, List.getElem_cons_zero]
        exact hptw
      · -- (e) `usWT` / `lWT` region.
        obtain ⟨j, hj⟩ : ∃ j, i.val = lXU.length + 1 + lUW.length + 1 + j :=
          ⟨i.val - (lXU.length + 1 + lUW.length) - 1, by omega⟩
        have hival := i.isLt
        have hjWT : j < lWT.length := by omega
        rw [List.getElem_append_right (show (lXU ++ ptX1 :: lUW).length ≤ i.val by
              simp only [List.length_append, List.length_cons]; omega),
          List.getElem_append_right (show (usXU ++ x1 :: usUW).length ≤ i.val by
              simp only [List.length_append, List.length_cons]; omega)]
        simp only [show i.val - (lXU ++ ptX1 :: lUW).length = j + 1 by
            simp only [List.length_append, List.length_cons]; omega,
          show i.val - (usXU ++ x1 :: usUW).length = j + 1 by
            simp only [List.length_append, List.length_cons]; omega, List.getElem_cons_succ]
        exact hptWT j hjWT
  · -- Leading segment `(x, ws 0)`: inside `(x, x1)`, so `segXU` (index `0 ≤ lXU.length`).
    intro y hxy hy0
    rw [if_pos (Nat.zero_le lXU.length)]
    exact hsegXU y hxy (lt_of_lt_of_le hy0 (hle_x1 0 (Nat.zero_le _) (by rw [hlen]; omega)))
  · -- Interior segments: three-way region split by the beta index `i.val + 1`.
    intro i y h1 h2
    by_cases hile : i.val + 1 ≤ lXU.length
    · -- Region XU: `(ws i, ws (i+1)) ⊆ (x, x1)`.
      rw [if_pos hile]
      refine hsegXU y ?_ ?_
      · exact (hrange_all _ (List.getElem_mem _)).1.trans h1
      · exact lt_of_lt_of_le h2 (hle_x1 (i.val + 1) (by omega) (by have := i.isLt; rw [hlen]; omega))
    · by_cases hile2 : i.val + 1 ≤ lXU.length + 1 + lUW.length
      · -- Region UW: `(ws i, ws (i+1)) ⊆ (x1, w)`.
        rw [if_neg hile, if_pos hile2]
        refine hsegUW y ?_ ?_
        · exact lt_of_le_of_lt (hge_x1 i.val (by omega) (by have := i.isLt; rw [hlen]; omega)) h1
        · exact lt_of_lt_of_le h2 (hle_w (i.val + 1) (by omega) (by have := i.isLt; rw [hlen]; omega))
      · -- Region WT: `(ws i, ws (i+1)) ⊆ (w, t)`.
        rw [if_neg hile, if_neg hile2]
        refine hsegWT y ?_ ?_
        · exact lt_of_le_of_lt (hge_w i.val (by omega) (by have := i.isLt; rw [hlen]; omega)) h1
        · exact h2.trans (hrange_all _ (List.getElem_mem _)).2
  · -- Trailing segment `(ws last, t)`: inside `(w, t)`, so `segWT`.
    intro y hy1 hy2
    rw [if_neg (show ¬(lXU.length + lUW.length + lWT.length + 1 + 1 ≤ lXU.length) by omega),
      if_neg (show ¬(lXU.length + lUW.length + lWT.length + 1 + 1 ≤ lXU.length + 1 + lUW.length) by
        omega)]
    refine hsegWT y ?_ hy2
    exact lt_of_le_of_lt (hge_w (lXU.length + lUW.length + lWT.length + 1)
      (by omega) (by rw [hlen]; omega)) hy1

/-- **Successor-parameter compatibility at the gate instance `j = 0`** (task 325 Phase 1; R4 exit
    criterion). The redesigned carrier's `σ : NormalForm sig 1 4` argument is definitionally the
    `j = 0` instance of the amended successor spec `σ : NormalForm sig (j+1) 4` (report 321 §2
    :56/:225): at `j = 0`, `NormalForm sig (0 + 1) 4` reduces to the landed `NormalForm sig 1 4`.
    Any successor-threading depth mismatch would fail this `rfl` immediately (the
    `kvE_subChain2_eq_fChainPred` :6179 / `bracketEndChar_kvE2_two_eq` :5972 discipline). -/
theorem kvE_subBracket2V_succ_j0 {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig (0 + 1) 4) :
    kvE_subBracket2V charBase charK σ = kvE_subBracket2V charBase charK σ := rfl

/-! ### Task 325 Phase 3 — Soundness over the `VVecEA2` disjunction

RE-DERIVES the task-324 soundness kit (`kvE_subBracket2_extract` :6233, `_reaches_z*` :6327,
`_fold_z*` :6434, `kvE_subBracket2_sound` :6530 — all binding the OLD single-bracket carrier)
over the redesigned `VVecEA2` carrier `kvE_subBracket2V` (:6779). The proof shapes survive; the
statements change by destructuring the disjunction FIRST (exactly as `bracketEndChar_k1v_sound`
:2352 does via `simp only [carrier, VVecEA2.holds]`), then reading the middle anchor `ptX1` (the
fresh depth-1 witness slot) and the below/above interior witnesses off the three-region
`bracketFromLists3` point list `lXU' ++ ptX1 :: lUW' ++ ptW :: lWT'` (anchor at index `|lXU'|`).
The SURVIVE zone specs `kvE_sub2_zXU`/`_zUW`/`_zWT` (:6200-6208) are defeq to the carrier's
internal `zXU`/`zUW`/`zWT` lets, so the interface matches the old kit verbatim and `_reaches`/
`_fold`/`_sound` transfer near-verbatim (carrier + extract-call swapped; the explicit `hgate` is
retained per Amendment F3 — the anchor positions ARE the bracket witnesses, the accepted task-324
soundness pattern). Rabinovich Def 3.1 monotone enumeration (PDF p.4), §5 bracket `[α_0,…,α_n]`
(PDF p.7), Cor 5.4 per-region chain (md:154-157). No `simp`/`omega`/`aesop` on chain steps
(`by omega` is `Fin`-index typing only, as in `kvE_subBracket2_extract` :6233). -/

/-- **Point-type extraction for `bracketFromLists3`** (task 325 Phase 3; the three-region arity-4
    lift of `k1v_bracket_extract` :2150, bullets 1-3 — point-type reachability only, per-region
    segments irrelevant to the point conditions). From `holds` at `(z_0, z_1)` obtain the middle
    anchor witness `w` (index `|lXU|`, realizing `ptX1`), every `lXU` type realized strictly
    BELOW `w`, and every `lUW`/`lWT` type strictly ABOVE `w`. Point list groups as
    `(lXU ++ ptX1 :: lUW) ++ ptW :: lWT`; reassociated once to a per-segment single cons for the
    `getElem` navigation (Def 3.1 monotone enumeration, PDF p.4; §5 bracket PDF p.7). -/
private theorem bracketFromLists3_extract {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (lXU lUW lWT : List TemporalPred) (ptX1 ptW segXU segUW segWT : TemporalPred)
    (z0 z1 : M.carrier)
    (h : (bracketFromLists3 lXU ptX1 lUW ptW lWT segXU segUW segWT).holds M atomMap z0 z1) :
    ∃ w : M.carrier, z0 < w ∧ w < z1 ∧
      ptX1.eval_at M atomMap w ∧
      (∀ p ∈ lXU, ∃ u : M.carrier, z0 < u ∧ u < w ∧ p.eval_at M atomMap u) ∧
      (∀ p ∈ lUW, ∃ u : M.carrier, w < u ∧ u < z1 ∧ p.eval_at M atomMap u) ∧
      (∀ p ∈ lWT, ∃ u : M.carrier, w < u ∧ u < z1 ∧ p.eval_at M atomMap u) := by
  simp only [BracketFormula.holds, BracketFormula.toIntervalPattern] at h
  rw [IntervalPattern.holds_eq_succ M atomMap _ _ z0 z1
      (show lXU.length + lUW.length + lWT.length + 1 + 1
        = (lXU.length + lUW.length + lWT.length + 1) + 1 from rfl)] at h
  obtain ⟨ws, hmono, hrange, hpt, _, _, _⟩ := h
  -- Point list groups as `(lXU ++ ptX1 :: lUW) ++ ptW :: lWT`; `hpt ⟨i,_⟩` is defeq.
  have hpt' : ∀ (i : Nat) (hi : i < lXU.length + lUW.length + lWT.length + 1 + 1),
      ((lXU ++ ptX1 :: lUW ++ ptW :: lWT)[i]'(by
        simp only [List.length_append, List.length_cons]; omega)).eval_at M atomMap
        (ws ⟨i, hi⟩) := fun i hi => hpt ⟨i, hi⟩
  refine ⟨ws ⟨lXU.length, by omega⟩, (hrange ⟨lXU.length, by omega⟩).1,
    (hrange ⟨lXU.length, by omega⟩).2, ?_, ?_, ?_, ?_⟩
  · -- Anchor `ptX1` at index `|lXU|` (§5 bracket middle slot, PDF p.7).
    have helem : (lXU ++ ptX1 :: lUW ++ ptW :: lWT)[lXU.length]'(by
        simp only [List.length_append, List.length_cons]; omega) = ptX1 := by
      rw [List.getElem_append_left
        (show lXU.length < (lXU ++ ptX1 :: lUW).length by
          simp only [List.length_append, List.length_cons]; omega)]
      rw [List.getElem_append_right (Nat.le_refl _)]
      simp only [Nat.sub_self, List.getElem_cons_zero]
    have := hpt' lXU.length (by omega)
    rwa [helem] at this
  · -- Below-anchor: each `lXU` type realized strictly inside `(z0, w)`.
    intro p hp
    obtain ⟨j, hj, hjeq⟩ := List.mem_iff_getElem.mp hp
    refine ⟨ws ⟨j, by omega⟩, (hrange ⟨j, by omega⟩).1,
      hmono ⟨j, by omega⟩ ⟨lXU.length, by omega⟩ (Fin.mk_lt_mk.mpr hj), ?_⟩
    have helem : (lXU ++ ptX1 :: lUW ++ ptW :: lWT)[j]'(by
        simp only [List.length_append, List.length_cons]; omega) = lXU[j]'hj := by
      rw [List.getElem_append_left
        (show j < (lXU ++ ptX1 :: lUW).length by
          simp only [List.length_append, List.length_cons]; omega)]
      rw [List.getElem_append_left hj]
    have := hpt' j (by omega)
    rw [helem, hjeq] at this
    exact this
  · -- `lUW`: witness in the `lUW` block, index `|lXU| + 1 + j` (above anchor).
    intro p hp
    obtain ⟨j, hj, hjeq⟩ := List.mem_iff_getElem.mp hp
    refine ⟨ws ⟨lXU.length + 1 + j, by omega⟩,
      hmono ⟨lXU.length, by omega⟩ ⟨lXU.length + 1 + j, by omega⟩ (Fin.mk_lt_mk.mpr (by omega)),
      (hrange ⟨lXU.length + 1 + j, by omega⟩).2, ?_⟩
    have helem : (lXU ++ ptX1 :: lUW ++ ptW :: lWT)[lXU.length + 1 + j]'(by
        simp only [List.length_append, List.length_cons]; omega) = lUW[j]'hj := by
      rw [List.getElem_append_left
        (show lXU.length + 1 + j < (lXU ++ ptX1 :: lUW).length by
          simp only [List.length_append, List.length_cons]; omega)]
      rw [List.getElem_append_right (by omega)]
      simp only [show lXU.length + 1 + j - lXU.length = j + 1 by omega, List.getElem_cons_succ]
    have := hpt' (lXU.length + 1 + j) (by omega)
    rw [helem, hjeq] at this
    exact this
  · -- `lWT`: witness in the `lWT` block, index `|lXU| + 1 + |lUW| + 1 + j` (above anchor).
    intro p hp
    obtain ⟨j, hj, hjeq⟩ := List.mem_iff_getElem.mp hp
    refine ⟨ws ⟨lXU.length + 1 + lUW.length + 1 + j, by omega⟩,
      hmono ⟨lXU.length, by omega⟩ ⟨lXU.length + 1 + lUW.length + 1 + j, by omega⟩
        (Fin.mk_lt_mk.mpr (by omega)),
      (hrange ⟨lXU.length + 1 + lUW.length + 1 + j, by omega⟩).2, ?_⟩
    have helem : (lXU ++ ptX1 :: lUW ++ ptW :: lWT)[lXU.length + 1 + lUW.length + 1 + j]'(by
        simp only [List.length_append, List.length_cons]; omega) = lWT[j]'hj := by
      have hidx : lXU.length + 1 + lUW.length + 1 + j - (lXU ++ ptX1 :: lUW).length = j + 1 := by
        simp only [List.length_append, List.length_cons]; omega
      rw [List.getElem_append_right (by simp only [List.length_append, List.length_cons]; omega)]
      simp only [hidx, List.getElem_cons_succ]
    have := hpt' (lXU.length + 1 + lUW.length + 1 + j) (by omega)
    rw [helem, hjeq] at this
    exact this

private theorem kvE_subBracket2V_extract {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (z0 z1 : M.carrier)
    (h : (kvE_subBracket2V charBase charK σ).holds M atomMap z0 z1) :
    ∃ w : M.carrier, z0 < w ∧ w < z1 ∧
      (⟨charK (nfk_projFresh σ)⟩ : TemporalPred).eval_at M atomMap w ∧
      (∀ χ : NormalForm sig 0 1,
        σ.2 (nf0_assemble kvE_sub2_zXU χ σ.1) = true →
        ∃ u : M.carrier, z0 < u ∧ u < w ∧
          (⟨charBase χ⟩ : TemporalPred).eval_at M atomMap u) ∧
      (∀ χ : NormalForm sig 0 1,
        (σ.2 (nf0_assemble kvE_sub2_zUW χ σ.1) = true ∨
         σ.2 (nf0_assemble kvE_sub2_zWT χ σ.1) = true) →
        ∃ u : M.carrier, w < u ∧ u < z1 ∧
          (⟨charBase χ⟩ : TemporalPred).eval_at M atomMap u) := by
  -- Step 1: destructure the disjunction and split on the gate (as `bracketEndChar_k1v_sound`).
  simp only [kvE_subBracket2V, VVecEA2.holds] at h
  obtain ⟨vea, hmem, hveah⟩ := h
  split at hmem
  case isFalse hg => simp at hmem
  case isTrue hg =>
  rw [List.mem_flatMap] at hmem
  obtain ⟨lXU, hlXUp, hmem⟩ := hmem
  rw [List.mem_flatMap] at hmem
  obtain ⟨lUW, hlUWp, hmem⟩ := hmem
  rw [List.mem_map] at hmem
  obtain ⟨lWT, hlWTp, hEq⟩ := hmem
  subst hEq
  obtain ⟨_hepL, _hepR, hbr⟩ := hveah
  -- Extract the anchor + per-block point-type witnesses from the three-region bracket.
  obtain ⟨w, hz0w, hwz1, hanchor, hbelow, hUW, hWT⟩ :=
    bracketFromLists3_extract M atomMap _ _ _ _ _ _ _ _ z0 z1 hbr
  refine ⟨w, hz0w, hwz1, ?_, ?_, ?_⟩
  · -- Anchor: project the complete-type head conjunct out of the folded `ptX1` (v2 self-type fold;
    -- k1v `hptW` :3277). `hanchor : ptX1_folded.eval_at`; its head is `charK (nfk_projFresh σ)`.
    simp only [TemporalPred.eval_at] at hanchor ⊢
    rw [formula_conjList_iff] at hanchor
    exact hanchor _ List.mem_cons_self
  · -- `zXU`-positive `χ`: `⟨charBase χ⟩ ∈ lXU.map charP` via the arrangement permutation.
    intro χ hbit
    have hχmem : (⟨charBase χ⟩ : TemporalPred) ∈
        lXU.map (fun χ => (⟨charBase χ⟩ : TemporalPred)) :=
      List.mem_map_of_mem
        ((List.mem_permutations.mp hlXUp).mem_iff.mpr (List.mem_filter.mpr ⟨by simp, hbit⟩))
    exact hbelow _ hχmem
  · -- `zUW`/`zWT`-positive `χ`: membership in the `lUW`/`lWT` arrangement block.
    intro χ hbit
    rcases hbit with hbit | hbit
    · exact hUW _ (List.mem_map_of_mem
        ((List.mem_permutations.mp hlUWp).mem_iff.mpr (List.mem_filter.mpr ⟨by simp, hbit⟩)))
    · exact hWT _ (List.mem_map_of_mem
        ((List.mem_permutations.mp hlWTp).mem_iff.mpr (List.mem_filter.mpr ⟨by simp, hbit⟩)))

/-- **KILL-SWITCH — `zXU` reachability over the `VVecEA2` carrier** (task 325 Phase 3; re-derives
    `kvE_subBracket2_reaches_zXU` :6327 over `kvE_subBracket2V`). Every `zXU`-positive fold bit
    yields a witness `u` realizing `charBase χ` strictly BELOW the anchor witness `w`. Rabinovich
    Prop 3.5 (md:87-94), §5 bracket (PDF p.7). -/
theorem kvE_subBracket2V_reaches_zXU {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (z0 z1 : M.carrier) (χ : NormalForm sig 0 1)
    (hbit : σ.2 (nf0_assemble kvE_sub2_zXU χ σ.1) = true)
    (h : (kvE_subBracket2V charBase charK σ).holds M atomMap z0 z1) :
    ∃ u w : M.carrier, z0 < u ∧ u < w ∧ w < z1 ∧
      (⟨charBase χ⟩ : TemporalPred).eval_at M atomMap u ∧
      (⟨charK (nfk_projFresh σ)⟩ : TemporalPred).eval_at M atomMap w := by
  obtain ⟨w, hz0w, hwz1, hanchor, hbelow, _⟩ :=
    kvE_subBracket2V_extract charBase charK σ M atomMap z0 z1 h
  obtain ⟨u, hz0u, huw, hu⟩ := hbelow χ hbit
  exact ⟨u, w, hz0u, huw, hwz1, hu, hanchor⟩

/-- **KILL-SWITCH — `zUW` reachability over the `VVecEA2` carrier** (task 325 Phase 3; re-derives
    `kvE_subBracket2_reaches_zUW` :6347). Every `zUW`-positive fold bit yields a witness `u`
    realizing `charBase χ` strictly ABOVE the anchor witness `w`. Rabinovich Prop 3.5 (md:87-94). -/
theorem kvE_subBracket2V_reaches_zUW {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (z0 z1 : M.carrier) (χ : NormalForm sig 0 1)
    (hbit : σ.2 (nf0_assemble kvE_sub2_zUW χ σ.1) = true)
    (h : (kvE_subBracket2V charBase charK σ).holds M atomMap z0 z1) :
    ∃ w u : M.carrier, z0 < w ∧ w < u ∧ u < z1 ∧
      (⟨charK (nfk_projFresh σ)⟩ : TemporalPred).eval_at M atomMap w ∧
      (⟨charBase χ⟩ : TemporalPred).eval_at M atomMap u := by
  obtain ⟨w, hz0w, hwz1, hanchor, _, habove⟩ :=
    kvE_subBracket2V_extract charBase charK σ M atomMap z0 z1 h
  obtain ⟨u, hwu, huz1, hu⟩ := habove χ (Or.inl hbit)
  exact ⟨w, u, hz0w, hwu, huz1, hanchor, hu⟩

/-- **KILL-SWITCH — `zWT` reachability over the `VVecEA2` carrier** (task 325 Phase 3; re-derives
    `kvE_subBracket2_reaches_zWT` :6367). Every `zWT`-positive fold bit yields a witness `u`
    realizing `charBase χ` strictly ABOVE the anchor witness `w`. Rabinovich Prop 3.5 (md:87-94). -/
theorem kvE_subBracket2V_reaches_zWT {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (z0 z1 : M.carrier) (χ : NormalForm sig 0 1)
    (hbit : σ.2 (nf0_assemble kvE_sub2_zWT χ σ.1) = true)
    (h : (kvE_subBracket2V charBase charK σ).holds M atomMap z0 z1) :
    ∃ w u : M.carrier, z0 < w ∧ w < u ∧ u < z1 ∧
      (⟨charK (nfk_projFresh σ)⟩ : TemporalPred).eval_at M atomMap w ∧
      (⟨charBase χ⟩ : TemporalPred).eval_at M atomMap u := by
  obtain ⟨w, hz0w, hwz1, hanchor, _, habove⟩ :=
    kvE_subBracket2V_extract charBase charK σ M atomMap z0 z1 h
  obtain ⟨u, hwu, huz1, hu⟩ := habove χ (Or.inr hbit)
  exact ⟨w, u, hz0w, hwu, huz1, hanchor, hu⟩

/-- **Interior-fold ≤ — `zXU` over the `VVecEA2` carrier** (task 325 Phase 3; re-derives
    `kvE_subBracket2_fold_zXU` :6434). A positive `zXU` fold bit is realized as an honest
    `nf_eval_nf M 0 1` witness `u` strictly BELOW the anchor witness `w`, via the `nfPred_correct`
    (NfToVecEA:69) bridge (the k1v `hchar` :2370). Rabinovich Cor 5.4 (md:154-157). -/
theorem kvE_subBracket2V_fold_zXU {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4)
    (M : OrderedMonadicStructure sig)
    (z0 z1 : M.carrier) (χ : NormalForm sig 0 1)
    (hbit : σ.2 (nf0_assemble kvE_sub2_zXU χ σ.1) = true)
    (h : (kvE_subBracket2V (nf_depth0_char_formula atomMap h_surj) charK σ).holds M atomMap z0 z1) :
    ∃ u w : M.carrier, z0 < u ∧ u < w ∧ w < z1 ∧
      nf_eval_nf M 0 1 (fun _ => u) χ ∧
      (⟨charK (nfk_projFresh σ)⟩ : TemporalPred).eval_at M atomMap w := by
  obtain ⟨u, w, hz0u, huw, hwz1, hu, hw⟩ :=
    kvE_subBracket2V_reaches_zXU (nf_depth0_char_formula atomMap h_surj) charK σ M atomMap z0 z1 χ
      hbit h
  exact ⟨u, w, hz0u, huw, hwz1, (nfPred_correct M atomMap h_surj χ u).mp hu, hw⟩

/-- **Interior-fold ≤ — `zUW` over the `VVecEA2` carrier** (task 325 Phase 3; re-derives
    `kvE_subBracket2_fold_zUW` :6455). Rabinovich Cor 5.4 (md:154-157). -/
theorem kvE_subBracket2V_fold_zUW {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4)
    (M : OrderedMonadicStructure sig)
    (z0 z1 : M.carrier) (χ : NormalForm sig 0 1)
    (hbit : σ.2 (nf0_assemble kvE_sub2_zUW χ σ.1) = true)
    (h : (kvE_subBracket2V (nf_depth0_char_formula atomMap h_surj) charK σ).holds M atomMap z0 z1) :
    ∃ w u : M.carrier, z0 < w ∧ w < u ∧ u < z1 ∧
      (⟨charK (nfk_projFresh σ)⟩ : TemporalPred).eval_at M atomMap w ∧
      nf_eval_nf M 0 1 (fun _ => u) χ := by
  obtain ⟨w, u, hz0w, hwu, huz1, hw, hu⟩ :=
    kvE_subBracket2V_reaches_zUW (nf_depth0_char_formula atomMap h_surj) charK σ M atomMap z0 z1 χ
      hbit h
  exact ⟨w, u, hz0w, hwu, huz1, hw, (nfPred_correct M atomMap h_surj χ u).mp hu⟩

/-- **Interior-fold ≤ — `zWT` over the `VVecEA2` carrier** (task 325 Phase 3; re-derives
    `kvE_subBracket2_fold_zWT` :6476). Rabinovich Cor 5.4 (md:154-157). -/
theorem kvE_subBracket2V_fold_zWT {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4)
    (M : OrderedMonadicStructure sig)
    (z0 z1 : M.carrier) (χ : NormalForm sig 0 1)
    (hbit : σ.2 (nf0_assemble kvE_sub2_zWT χ σ.1) = true)
    (h : (kvE_subBracket2V (nf_depth0_char_formula atomMap h_surj) charK σ).holds M atomMap z0 z1) :
    ∃ w u : M.carrier, z0 < w ∧ w < u ∧ u < z1 ∧
      (⟨charK (nfk_projFresh σ)⟩ : TemporalPred).eval_at M atomMap w ∧
      nf_eval_nf M 0 1 (fun _ => u) χ := by
  obtain ⟨w, u, hz0w, hwu, huz1, hw, hu⟩ :=
    kvE_subBracket2V_reaches_zWT (nf_depth0_char_formula atomMap h_surj) charK σ M atomMap z0 z1 χ
      hbit h
  exact ⟨w, u, hz0w, hwu, huz1, hw, (nfPred_correct M atomMap h_surj χ u).mp hu⟩

/-- **Standalone soundness of the redesigned `VVecEA2` sub-bracket** (task 325 Phase 3; re-derives
    `kvE_subBracket2_sound` :6530 over `kvE_subBracket2V`). Whenever the `VVecEA2` arrangement
    disjunction holds on the FIXED endpoints `(x, t)`, and the explicit outer gate-shaped
    hypothesis `hgate` supplies the honest fold conditions the carrier does not itself supply as
    the below-anchor witnesses, there is a depth-1 witness `x1` realizing `nf_eval_nf M 1 4` at the
    honest env `[x1, w, x, t]`. STANDALONE: `hgate` is an explicit hypothesis, never wired to the
    real outer gate (Amendment F3 — no provider pinning; the anchor is the bracket's own witness).
    The carrier's OWN contribution is the below-anchor (`zXU`) existence witnesses, extracted per
    disjunct via `kvE_subBracket2V_extract` (which destructures the disjunction FIRST, as
    `bracketEndChar_k1v_sound` :2352). Assembled via `nf_eval_depth1_fold_iff` (:5187). Rabinovich
    Def 3.1 (md:61-74), Prop 3.5 (md:87-94), Cor 5.4 (md:154-157). -/
theorem kvE_subBracket2V_sound {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4)
    (M : OrderedMonadicStructure sig)
    (w x t : M.carrier)
    (h : (kvE_subBracket2V (nf_depth0_char_formula atomMap h_surj) charK σ).holds
        M atomMap x t)
    (hgate : ∀ a : M.carrier, x < a → a < t →
      (⟨charK (nfk_projFresh σ)⟩ : TemporalPred).eval_at M atomMap a →
      a < w ∧ w < t ∧
      nf_eval_nf M 0 4 (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) σ.1 ∧
      (∀ τ : NormalForm sig 0 5, nf0_dropFresh τ ≠ σ.1 → σ.2 τ = false) ∧
      (∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1),
        (∃ v : M.carrier,
          zoneHolds M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) zs v ∧
          nf_eval_nf M 0 1 (fun _ => v) χ) →
        σ.2 (nf0_assemble zs χ σ.1) = true) ∧
      (∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1), zs ≠ kvE_sub2_zXU →
        σ.2 (nf0_assemble zs χ σ.1) = true →
        ∃ v : M.carrier,
          zoneHolds M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) zs v ∧
          nf_eval_nf M 0 1 (fun _ => v) χ)) :
    ∃ x1 : M.carrier,
      nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ := by
  -- Extract the anchor `a` (the `ptX1` witness) and the below-anchor witness clause per disjunct.
  obtain ⟨a, hxa, hat, hanchor, hbelow, _habove⟩ :=
    kvE_subBracket2V_extract (nf_depth0_char_formula atomMap h_surj) charK σ M atomMap x t h
  -- Feed the anchor to the explicit gate hypothesis (Amendment F3: no provider pinning).
  obtain ⟨haw, hwt, h_atom, h_off, h_fwd, h_bwd⟩ := hgate a hxa hat hanchor
  refine ⟨a, ?_⟩
  -- Assemble the depth-1 evaluation (the inside-out fold of `nf_eval_depth1_fold_iff` :5187).
  rw [nf_eval_depth1_fold_iff]
  refine ⟨h_atom, ?_, h_off⟩
  -- Zone matching: forward from the gate; backward from the gate for every zone EXCEPT the
  -- below-anchor `zXU`, whose witnesses are supplied by the bracket (Correction 1).
  intro zs χ
  refine ⟨fun hex => h_fwd zs χ hex, ?_⟩
  intro hbit
  by_cases hzs : zs = kvE_sub2_zXU
  · -- Below-anchor zone `zXU = (x < v < a)`: the bracket's below-witness clause supplies a
    -- witness strictly below the anchor `a` (Def 3.1, PDF p.4; the redesign's signature witness).
    subst hzs
    obtain ⟨u, hxu, hua, hu⟩ := hbelow χ hbit
    refine ⟨u, ?_, (nfPred_correct M atomMap h_surj χ u).mp hu⟩
    -- `u` lies in `zXU` relative to env `[a, w, x, t]` under honest order `x < u < a < w < t`.
    have huw : u < w := hua.trans haw
    have hut : u < t := huw.trans hwt
    intro i
    match i with
    | ⟨0, _⟩ => exact ⟨iff_of_true hua rfl, iff_of_false (lt_asymm hua) (by decide +revert)⟩
    | ⟨1, _⟩ => exact ⟨iff_of_true huw rfl, iff_of_false (lt_asymm huw) (by decide +revert)⟩
    | ⟨2, _⟩ => exact ⟨iff_of_false (lt_asymm hxu) (by decide +revert), iff_of_true hxu rfl⟩
    | ⟨3, _⟩ => exact ⟨iff_of_true hut rfl, iff_of_false (lt_asymm hut) (by decide +revert)⟩
  · -- Every other zone: the gate's backward direction (analog of `kvE_gate` honesty).
    exact h_bwd zs χ hzs hbit

/-! ### Task 325 v2 Phase 1: the mandatory NON-VACUITY GATE

Two consecutive prior iterations (task 324 Phase 6; task 325 v1 Phase 4) closed soundness over an
always-`False` carrier — vacuously. v2's structural countermeasure: an explicit, machine-checked
non-vacuity lemma that MUST close before soundness/completeness are attempted, proving the corrected
NINE-zone gate is satisfiable by an honest σ and the carrier's `disjuncts` list is non-empty. The
key arity-4 realizability lemma `kvE_sub2V_zone_consistent` (the analog of `k1v_zone_consistent`
:2065) shows every zone realized by a point over the honest env `[x1, w, x, t]` under the order
`x < x1 < w < t` is one of the NINE consistent zones — its contrapositive discharges gate conjunct
(ii). Rabinovich Def 3.1 (md:61-74), Prop 4.2 (md:100-101). -/

/-- Any zone spec realized by a point over the anchor env `[x1, w, x, t]` with `x < x1 < w < t` is
    one of the NINE order-consistent zones (Def 3.1, PDF pp.4-5: disjunctions range only over
    consistent order types). The arity-4 lift of `k1v_zone_consistent` :2065, extended for the two
    interior witness self-zones `zAtX1`, `zAtW`. Its contrapositive discharges the inconsistent-zone
    fold bits against gate conjunct (ii) — the machine-verified v1 empty-gate fix. -/
private theorem kvE_sub2V_zone_consistent {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (x1 w x t u : M.carrier)
    (hxx1 : x < x1) (hx1w : x1 < w) (hwt : w < t)
    (zs : ZoneSpec 4)
    (hz : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) zs u) :
    zs = Fin.cons (true, false) (Fin.cons (true, false) (Fin.cons (true, false) (fun _ => (true, false)))) ∨
    zs = Fin.cons (true, false) (Fin.cons (true, false) (Fin.cons (false, false) (fun _ => (true, false)))) ∨
    zs = Fin.cons (true, false) (Fin.cons (true, false) (Fin.cons (false, true) (fun _ => (true, false)))) ∨
    zs = Fin.cons (false, false) (Fin.cons (true, false) (Fin.cons (false, true) (fun _ => (true, false)))) ∨
    zs = Fin.cons (false, true) (Fin.cons (true, false) (Fin.cons (false, true) (fun _ => (true, false)))) ∨
    zs = Fin.cons (false, true) (Fin.cons (false, false) (Fin.cons (false, true) (fun _ => (true, false)))) ∨
    zs = Fin.cons (false, true) (Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (true, false)))) ∨
    zs = Fin.cons (false, true) (Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (false, false)))) ∨
    zs = Fin.cons (false, true) (Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (false, true)))) := by
  have h0 := hz ⟨0, by omega⟩
  have h1 := hz ⟨1, by omega⟩
  have h2 := hz ⟨2, by omega⟩
  have h3 := hz ⟨3, by omega⟩
  simp only [Fin.cons] at h0 h1 h2 h3
  have hzs : ∀ (p0 p1 p2 p3 : Bool × Bool),
      zs ⟨0, by omega⟩ = p0 → zs ⟨1, by omega⟩ = p1 → zs ⟨2, by omega⟩ = p2 →
        zs ⟨3, by omega⟩ = p3 →
      zs = Fin.cons p0 (Fin.cons p1 (Fin.cons p2 (fun _ => p3))) := by
    intro p0 p1 p2 p3 e0 e1 e2 e3
    funext i
    match i with
    | ⟨0, _⟩ => simpa only [Fin.cons] using e0
    | ⟨1, _⟩ => simpa only [Fin.cons] using e1
    | ⟨2, _⟩ => simpa only [Fin.cons] using e2
    | ⟨3, _⟩ => simpa only [Fin.cons] using e3
  have hxw : x < w := hxx1.trans hx1w
  have hxt : x < t := hxw.trans hwt
  have hx1t : x1 < t := hx1w.trans hwt
  rcases lt_trichotomy u x with hux | hux | hux
  · -- u < x : zPastX
    have hux1 : u < x1 := hux.trans hxx1
    have huw : u < w := hux1.trans hx1w
    have hut : u < t := huw.trans hwt
    exact Or.inl (hzs _ _ _ _
      (Prod.ext_iff.mpr ⟨h0.1.mp hux1, k1v_bool_eq_false h0.2 (lt_asymm hux1)⟩)
      (Prod.ext_iff.mpr ⟨h1.1.mp huw, k1v_bool_eq_false h1.2 (lt_asymm huw)⟩)
      (Prod.ext_iff.mpr ⟨h2.1.mp hux, k1v_bool_eq_false h2.2 (lt_asymm hux)⟩)
      (Prod.ext_iff.mpr ⟨h3.1.mp hut, k1v_bool_eq_false h3.2 (lt_asymm hut)⟩))
  · -- u = x : zAtX
    subst hux
    exact Or.inr (Or.inl (hzs _ _ _ _
      (Prod.ext_iff.mpr ⟨h0.1.mp hxx1, k1v_bool_eq_false h0.2 (lt_asymm hxx1)⟩)
      (Prod.ext_iff.mpr ⟨h1.1.mp hxw, k1v_bool_eq_false h1.2 (lt_asymm hxw)⟩)
      (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h2.1 (lt_irrefl u),
        k1v_bool_eq_false h2.2 (lt_irrefl u)⟩)
      (Prod.ext_iff.mpr ⟨h3.1.mp hxt, k1v_bool_eq_false h3.2 (lt_asymm hxt)⟩)))
  · -- x < u : split against x1
    rcases lt_trichotomy u x1 with hux1 | hux1 | hux1
    · -- x < u < x1 : zXU
      have huw : u < w := hux1.trans hx1w
      have hut : u < t := huw.trans hwt
      exact Or.inr (Or.inr (Or.inl (hzs _ _ _ _
        (Prod.ext_iff.mpr ⟨h0.1.mp hux1, k1v_bool_eq_false h0.2 (lt_asymm hux1)⟩)
        (Prod.ext_iff.mpr ⟨h1.1.mp huw, k1v_bool_eq_false h1.2 (lt_asymm huw)⟩)
        (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h2.1 (lt_asymm hux), h2.2.mp hux⟩)
        (Prod.ext_iff.mpr ⟨h3.1.mp hut, k1v_bool_eq_false h3.2 (lt_asymm hut)⟩))))
    · -- u = x1 : zAtX1
      subst hux1
      exact Or.inr (Or.inr (Or.inr (Or.inl (hzs _ _ _ _
        (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h0.1 (lt_irrefl u),
          k1v_bool_eq_false h0.2 (lt_irrefl u)⟩)
        (Prod.ext_iff.mpr ⟨h1.1.mp hx1w, k1v_bool_eq_false h1.2 (lt_asymm hx1w)⟩)
        (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h2.1 (lt_asymm hxx1), h2.2.mp hxx1⟩)
        (Prod.ext_iff.mpr ⟨h3.1.mp hx1t, k1v_bool_eq_false h3.2 (lt_asymm hx1t)⟩)))))
    · -- x1 < u : split against w
      rcases lt_trichotomy u w with huw | huw | huw
      · -- x1 < u < w : zUW
        have hut : u < t := huw.trans hwt
        exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inl (hzs _ _ _ _
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h0.1 (lt_asymm hux1), h0.2.mp hux1⟩)
          (Prod.ext_iff.mpr ⟨h1.1.mp huw, k1v_bool_eq_false h1.2 (lt_asymm huw)⟩)
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h2.1 (lt_asymm hux), h2.2.mp hux⟩)
          (Prod.ext_iff.mpr ⟨h3.1.mp hut, k1v_bool_eq_false h3.2 (lt_asymm hut)⟩))))))
      · -- u = w : zAtW
        subst huw
        exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inl (hzs _ _ _ _
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h0.1 (lt_asymm hx1w), h0.2.mp hx1w⟩)
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h1.1 (lt_irrefl u),
            k1v_bool_eq_false h1.2 (lt_irrefl u)⟩)
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h2.1 (lt_asymm hxw), h2.2.mp hxw⟩)
          (Prod.ext_iff.mpr ⟨h3.1.mp hwt, k1v_bool_eq_false h3.2 (lt_asymm hwt)⟩)))))))
      · -- w < u : split against t
        have hx1u : x1 < u := hx1w.trans huw
        have hxu : x < u := hxw.trans huw
        rcases lt_trichotomy u t with hut | hut | hut
        · -- w < u < t : zWT
          exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inl (hzs _ _ _ _
            (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h0.1 (lt_asymm hx1u), h0.2.mp hx1u⟩)
            (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h1.1 (lt_asymm huw), h1.2.mp huw⟩)
            (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h2.1 (lt_asymm hxu), h2.2.mp hxu⟩)
            (Prod.ext_iff.mpr ⟨h3.1.mp hut, k1v_bool_eq_false h3.2 (lt_asymm hut)⟩))))))))
        · -- u = t : zAtT
          subst hut
          exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inl (hzs _ _ _ _
            (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h0.1 (lt_asymm hx1u), h0.2.mp hx1u⟩)
            (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h1.1 (lt_asymm huw), h1.2.mp huw⟩)
            (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h2.1 (lt_asymm hxu), h2.2.mp hxu⟩)
            (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h3.1 (lt_irrefl u),
              k1v_bool_eq_false h3.2 (lt_irrefl u)⟩)))))))))
        · -- t < u : zFutT
          have hx1u' : x1 < u := hx1t.trans hut
          have hxu' : x < u := hxt.trans hut
          have hwu' : w < u := hwt.trans hut
          exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (hzs _ _ _ _
            (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h0.1 (lt_asymm hx1u'), h0.2.mp hx1u'⟩)
            (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h1.1 (lt_asymm hwu'), h1.2.mp hwu'⟩)
            (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h2.1 (lt_asymm hxu'), h2.2.mp hxu'⟩)
            (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h3.1 (lt_asymm hut), h3.2.mp hut⟩)))))))))

/-- **NON-VACUITY GATE, part 1 — the corrected nine-zone gate holds for an honest σ**
    (task 325 v2 Phase 1; the EXACT statement whose negation the removed v1 probe
    `kvE_subBracket2V_gate_unsat_PROBE` proved over the old 7-zone gate — now flipped to provable).
    From an honest depth-1 realization at the anchor env `[x1, w, x, t]` under the order
    `x < x1 < w < t`, BOTH gate conjuncts hold: (i) off-fiber falsity is the fold's own off-fiber
    clause; (ii) inconsistent-zone falsity via the `kvE_sub2V_zone_consistent` contrapositive — the
    forced-true bits at `zAtX1`/`zAtW` no longer contradict conjunct (ii) because those self-zones
    are now among the NINE consistent zones. Rabinovich Prop 4.2 (md:100-101), Def 3.1 (md:61-74). -/
theorem kvE_subBracket2V_gate_holds_of_honest {sig : MonadicSignature}
    (σ : NormalForm sig 1 4)
    (M : OrderedMonadicStructure sig)
    (x1 w x t : M.carrier)
    (hxx1 : x < x1) (hx1w : x1 < w) (hwt : w < t)
    (h : nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    (∀ sub : NormalForm sig 0 5, nf0_dropFresh sub ≠ σ.1 → σ.2 sub = false) ∧
    (∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1),
      ¬(zs = Fin.cons (true, false) (Fin.cons (true, false) (Fin.cons (true, false) (fun _ => (true, false)))) ∨
        zs = Fin.cons (true, false) (Fin.cons (true, false) (Fin.cons (false, false) (fun _ => (true, false)))) ∨
        zs = Fin.cons (true, false) (Fin.cons (true, false) (Fin.cons (false, true) (fun _ => (true, false)))) ∨
        zs = Fin.cons (false, false) (Fin.cons (true, false) (Fin.cons (false, true) (fun _ => (true, false)))) ∨
        zs = Fin.cons (false, true) (Fin.cons (true, false) (Fin.cons (false, true) (fun _ => (true, false)))) ∨
        zs = Fin.cons (false, true) (Fin.cons (false, false) (Fin.cons (false, true) (fun _ => (true, false)))) ∨
        zs = Fin.cons (false, true) (Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (true, false)))) ∨
        zs = Fin.cons (false, true) (Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (false, false)))) ∨
        zs = Fin.cons (false, true) (Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (false, true))))) →
      σ.2 (nf0_assemble zs χ σ.1) = false) := by
  obtain ⟨_h_atom, h_zone, h_off⟩ := (nf_eval_depth1_fold_iff M _ σ).mp h
  refine ⟨h_off, fun zs χ hncons => ?_⟩
  cases hb : σ.2 (nf0_assemble zs χ σ.1) with
  | false => rfl
  | true =>
    obtain ⟨u, hzu, -⟩ := (h_zone zs χ).mpr hb
    exact absurd (kvE_sub2V_zone_consistent M x1 w x t u hxx1 hx1w hwt zs hzu) hncons

/-- **NON-VACUITY GATE, part 2 — the corrected carrier is inhabited for an honest σ**
    (task 325 v2 Phase 1; refutes the removed v1 probe `kvE_subBracket2V_never_holds_PROBE`). For σ
    arising from an actual model realization under `x < x1 < w < t`, the corrected nine-zone gate
    holds (part 1), so the carrier takes the gate-true branch and its `disjuncts` list is the NON-empty
    arrangement `flatMap` (the identity arrangement of each region-positive enumeration is always
    present). Hence `(kvE_subBracket2V …).holds` is NOT definitionally `False`, and soundness
    (Phase 2) can no longer close vacuously. Rabinovich Prop 4.2 (md:100-101). -/
theorem kvE_subBracket2V_nonvacuous {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4)
    (M : OrderedMonadicStructure sig)
    (x1 w x t : M.carrier)
    (hxx1 : x < x1) (hx1w : x1 < w) (hwt : w < t)
    (h : nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    (kvE_subBracket2V charBase charK σ).disjuncts ≠ [] := by
  have hgate := kvE_subBracket2V_gate_holds_of_honest σ M x1 w x t hxx1 hx1w hwt h
  simp only [kvE_subBracket2V]
  split
  case isTrue _ =>
    apply List.ne_nil_of_mem
    apply List.mem_flatMap.mpr
    refine ⟨_, List.mem_permutations.mpr (List.Perm.refl _), ?_⟩
    apply List.mem_flatMap.mpr
    refine ⟨_, List.mem_permutations.mpr (List.Perm.refl _), ?_⟩
    apply List.mem_map.mpr
    exact ⟨_, List.mem_permutations.mpr (List.Perm.refl _), rfl⟩
  case isFalse hg =>
    exact absurd hgate hg

/-- **Standalone completeness of the redesigned `VVecEA2` sub-bracket** (task 325 v2 Phase 3; the
    arity-4 three-region analog of `bracketEndChar_k1v_complete` :2979 — the direction that was
    BLOCKED on both prior carriers). From an honest depth-1 realization at the anchor env
    `[x1, w, x, t]` (order `x < x1 < w < t` supplied by the three σ.1 order bits), the corrected
    NINE-zone `VVecEA2` arrangement disjunction holds at the FIXED endpoints `(x, t)`. Mechanism:
    (a) the honest σ discharges the carrier gate via `kvE_subBracket2V_gate_holds_of_honest`
    (Phase 1), so the disjuncts list is the non-empty `flatMap` (never the empty branch);
    (b) `kvE_subBracket2_complete_extract` (SURVIVE, :6683) supplies the per-region monotone inner
    witnesses; (c) `k1v_sorted_realization3` (:6947) selects the model-sorted arrangement disjunct;
    (d) `k1v_bracket_construct3` (:7023) assembles the three-region bracket, discharging the three
    per-region segment types `segXU`/`segUW`/`segWT` (each satisfiable because every point of its
    region is genuinely zone-positive there — the exact property the refuted constant `segExcl`
    violated); (e) the folded witness point types `ptX1`/`ptW` are discharged at `x1`/`w`. STANDALONE:
    like soundness's `hgate`, the `charK`-realization of the fresh witness `x1` is an explicit
    hypothesis `hcharK` (never wired to the real outer gate; Amendment F3 — no provider pinning).
    Rabinovich Lemma 5.3 (md:137-152, per-region segment types + disjunction-over-arrangements),
    Cor 5.4 (md:154-157, per-region F_i chain), Prop 4.2 (md:100-101), Def 3.1 (md:61-74). -/
theorem kvE_subBracket2V_complete {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4)
    (M : OrderedMonadicStructure sig)
    (w x t : M.carrier)
    (h_xx1 : σ.1 (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    (h_x1w : σ.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = true)
    (h_wt : σ.1 (.order ⟨1, by omega⟩ ⟨3, by omega⟩ (by decide)) = true)
    (hcharK : ∀ a : M.carrier,
      nf_eval_nf M 1 4 (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) σ →
      (⟨charK (nfk_projFresh σ)⟩ : TemporalPred).eval_at M atomMap a)
    (h : ∃ x1 : M.carrier,
      nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    (kvE_subBracket2V (nf_depth0_char_formula atomMap h_surj) charK σ).holds M atomMap x t := by
  obtain ⟨x1, hx1⟩ := h
  -- Fold decomposition of the honest depth-1 realization (Prop 4.2, PDF p.6; rule N2).
  obtain ⟨h_atom, h_zone, h_off⟩ := (nf_eval_depth1_fold_iff M _ σ).mp hx1
  -- Recover the honest order `x < x1 < w < t` from the atom layer + the three σ.1 order bits.
  have hxx1 : x < x1 := by
    have h1 := h_atom (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide))
    simp only [atom_eval, Fin.cons] at h1; exact h1.mpr h_xx1
  have hx1w : x1 < w := by
    have h1 := h_atom (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide))
    simp only [atom_eval, Fin.cons] at h1; exact h1.mpr h_x1w
  have hwt : w < t := by
    have h1 := h_atom (.order ⟨1, by omega⟩ ⟨3, by omega⟩ (by decide))
    simp only [atom_eval, Fin.cons] at h1; exact h1.mpr h_wt
  have hxw : x < w := hxx1.trans hx1w
  have hxt : x < t := hxw.trans hwt
  have hx1t : x1 < t := hx1w.trans hwt
  -- Complete-type correctness bridge (charBase χ at u ↔ arity-1 depth-0 evaluation).
  have hchar : ∀ (χ' : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (nf_depth0_char_formula atomMap h_surj χ') ↔
      nf_eval_nf M 0 1 (fun _ => u) χ' :=
    fun χ' u => nfPred_correct M atomMap h_surj χ' u
  -- Coordinate-projection point evaluations of the two fixed endpoints and the witness `w`
  -- (Def 3.1 ordering channel; the arity-4 analog of `k1v_extract_x_nf3`/`_t_nf3`/`_y_nf`).
  have h_x_nf : nf_eval_nf M 0 1 (fun _ => x)
      (fun a => match a with
        | .pred p _ => σ.1 (.pred p (2 : Fin 4))
        | .order i j h => absurd (Subsingleton.elim i j) h) := by
    intro a
    match a with
    | .pred p _ =>
      have := h_atom (.pred p (2 : Fin 4))
      simp only [atom_eval, Fin.cons] at this ⊢; exact this
    | .order i j h => exact absurd (Subsingleton.elim i j) h
  have h_t_nf : nf_eval_nf M 0 1 (fun _ => t)
      (fun a => match a with
        | .pred p _ => σ.1 (.pred p (3 : Fin 4))
        | .order i j h => absurd (Subsingleton.elim i j) h) := by
    intro a
    match a with
    | .pred p _ =>
      have := h_atom (.pred p (3 : Fin 4))
      simp only [atom_eval, Fin.cons] at this ⊢; exact this
    | .order i j h => exact absurd (Subsingleton.elim i j) h
  have h_w_nf : nf_eval_nf M 0 1 (fun _ => w)
      (fun a => match a with
        | .pred p _ => σ.1 (.pred p (1 : Fin 4))
        | .order i j h => absurd (Subsingleton.elim i j) h) := by
    intro a
    match a with
    | .pred p _ =>
      have := h_atom (.pred p (1 : Fin 4))
      simp only [atom_eval, Fin.cons] at this ⊢; exact this
    | .order i j h => exact absurd (Subsingleton.elim i j) h
  -- Zone-membership constructors over the anchor env `[x1, w, x, t]` (Def 3.1, PDF p.4).
  have hzPastX : ∀ v, v < x →
      zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))) : Fin 4 → M.carrier)
        (Fin.cons (true, false) (Fin.cons (true, false)
          (Fin.cons (true, false) (fun _ => (true, false))))) v := by
    intro v hvx
    have hvx1 : v < x1 := hvx.trans hxx1
    have hvw : v < w := hvx1.trans hx1w
    have hvt : v < t := hvw.trans hwt
    rw [kvE_sub2_zoneHolds_cons_iff]
    exact ⟨⟨iff_of_true hvx1 rfl, iff_of_false (lt_asymm hvx1) (by simp)⟩,
      ⟨iff_of_true hvw rfl, iff_of_false (lt_asymm hvw) (by simp)⟩,
      ⟨iff_of_true hvx rfl, iff_of_false (lt_asymm hvx) (by simp)⟩,
      ⟨iff_of_true hvt rfl, iff_of_false (lt_asymm hvt) (by simp)⟩⟩
  have hzAtX : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))) : Fin 4 → M.carrier)
        (Fin.cons (true, false) (Fin.cons (true, false)
          (Fin.cons (false, false) (fun _ => (true, false))))) x := by
    rw [kvE_sub2_zoneHolds_cons_iff]
    exact ⟨⟨iff_of_true hxx1 rfl, iff_of_false (lt_asymm hxx1) (by simp)⟩,
      ⟨iff_of_true hxw rfl, iff_of_false (lt_asymm hxw) (by simp)⟩,
      ⟨iff_of_false (lt_irrefl x) (by simp), iff_of_false (lt_irrefl x) (by simp)⟩,
      ⟨iff_of_true hxt rfl, iff_of_false (lt_asymm hxt) (by simp)⟩⟩
  have hzXU : ∀ u, x < u → u < x1 →
      zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) kvE_sub2_zXU u := by
    intro u hxu hux1
    have huw : u < w := hux1.trans hx1w
    have hut : u < t := huw.trans hwt
    rw [show kvE_sub2_zXU = Fin.cons (true, false) (Fin.cons (true, false)
        (Fin.cons (false, true) (fun _ => (true, false)))) from rfl, kvE_sub2_zoneHolds_cons_iff]
    exact ⟨⟨iff_of_true hux1 rfl, iff_of_false (lt_asymm hux1) (by simp)⟩,
      ⟨iff_of_true huw rfl, iff_of_false (lt_asymm huw) (by simp)⟩,
      ⟨iff_of_false (lt_asymm hxu) (by simp), iff_of_true hxu rfl⟩,
      ⟨iff_of_true hut rfl, iff_of_false (lt_asymm hut) (by simp)⟩⟩
  have hzAtX1 : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))) : Fin 4 → M.carrier)
        (Fin.cons (false, false) (Fin.cons (true, false)
          (Fin.cons (false, true) (fun _ => (true, false))))) x1 := by
    rw [kvE_sub2_zoneHolds_cons_iff]
    exact ⟨⟨iff_of_false (lt_irrefl x1) (by simp), iff_of_false (lt_irrefl x1) (by simp)⟩,
      ⟨iff_of_true hx1w rfl, iff_of_false (lt_asymm hx1w) (by simp)⟩,
      ⟨iff_of_false (lt_asymm hxx1) (by simp), iff_of_true hxx1 rfl⟩,
      ⟨iff_of_true hx1t rfl, iff_of_false (lt_asymm hx1t) (by simp)⟩⟩
  have hzUW : ∀ u, x1 < u → u < w →
      zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) kvE_sub2_zUW u := by
    intro u hx1u huw
    have hxu : x < u := hxx1.trans hx1u
    have hut : u < t := huw.trans hwt
    rw [show kvE_sub2_zUW = Fin.cons (false, true) (Fin.cons (true, false)
        (Fin.cons (false, true) (fun _ => (true, false)))) from rfl, kvE_sub2_zoneHolds_cons_iff]
    exact ⟨⟨iff_of_false (lt_asymm hx1u) (by simp), iff_of_true hx1u rfl⟩,
      ⟨iff_of_true huw rfl, iff_of_false (lt_asymm huw) (by simp)⟩,
      ⟨iff_of_false (lt_asymm hxu) (by simp), iff_of_true hxu rfl⟩,
      ⟨iff_of_true hut rfl, iff_of_false (lt_asymm hut) (by simp)⟩⟩
  have hzAtW : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))) : Fin 4 → M.carrier)
        (Fin.cons (false, true) (Fin.cons (false, false)
          (Fin.cons (false, true) (fun _ => (true, false))))) w := by
    rw [kvE_sub2_zoneHolds_cons_iff]
    exact ⟨⟨iff_of_false (lt_asymm hx1w) (by simp), iff_of_true hx1w rfl⟩,
      ⟨iff_of_false (lt_irrefl w) (by simp), iff_of_false (lt_irrefl w) (by simp)⟩,
      ⟨iff_of_false (lt_asymm hxw) (by simp), iff_of_true hxw rfl⟩,
      ⟨iff_of_true hwt rfl, iff_of_false (lt_asymm hwt) (by simp)⟩⟩
  have hzWT : ∀ u, w < u → u < t →
      zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) kvE_sub2_zWT u := by
    intro u hwu hut
    have hx1u : x1 < u := hx1w.trans hwu
    have hxu : x < u := hxw.trans hwu
    rw [show kvE_sub2_zWT = Fin.cons (false, true) (Fin.cons (false, true)
        (Fin.cons (false, true) (fun _ => (true, false)))) from rfl, kvE_sub2_zoneHolds_cons_iff]
    exact ⟨⟨iff_of_false (lt_asymm hx1u) (by simp), iff_of_true hx1u rfl⟩,
      ⟨iff_of_false (lt_asymm hwu) (by simp), iff_of_true hwu rfl⟩,
      ⟨iff_of_false (lt_asymm hxu) (by simp), iff_of_true hxu rfl⟩,
      ⟨iff_of_true hut rfl, iff_of_false (lt_asymm hut) (by simp)⟩⟩
  have hzAtT : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))) : Fin 4 → M.carrier)
        (Fin.cons (false, true) (Fin.cons (false, true)
          (Fin.cons (false, true) (fun _ => (false, false))))) t := by
    rw [kvE_sub2_zoneHolds_cons_iff]
    exact ⟨⟨iff_of_false (lt_asymm hx1t) (by simp), iff_of_true hx1t rfl⟩,
      ⟨iff_of_false (lt_asymm hwt) (by simp), iff_of_true hwt rfl⟩,
      ⟨iff_of_false (lt_asymm hxt) (by simp), iff_of_true hxt rfl⟩,
      ⟨iff_of_false (lt_irrefl t) (by simp), iff_of_false (lt_irrefl t) (by simp)⟩⟩
  have hzFutT : ∀ v, t < v →
      zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))) : Fin 4 → M.carrier)
        (Fin.cons (false, true) (Fin.cons (false, true)
          (Fin.cons (false, true) (fun _ => (false, true))))) v := by
    intro v htv
    have hwv : w < v := hwt.trans htv
    have hx1v : x1 < v := hx1t.trans htv
    have hxv : x < v := hxt.trans htv
    rw [kvE_sub2_zoneHolds_cons_iff]
    exact ⟨⟨iff_of_false (lt_asymm hx1v) (by simp), iff_of_true hx1v rfl⟩,
      ⟨iff_of_false (lt_asymm hwv) (by simp), iff_of_true hwv rfl⟩,
      ⟨iff_of_false (lt_asymm hxv) (by simp), iff_of_true hxv rfl⟩,
      ⟨iff_of_false (lt_asymm htv) (by simp), iff_of_true htv rfl⟩⟩
  -- Gate for the honest σ (Phase-1 non-vacuity result): the branch selector for the disjuncts.
  have hgate := kvE_subBracket2V_gate_holds_of_honest σ M x1 w x t hxx1 hx1w hwt hx1
  -- Per-region monotone inner witnesses (SURVIVE `kvE_subBracket2_complete_extract` :6683).
  obtain ⟨_hatom2, _hoff2, _hfwd2, hbelowXU, hbelowUW, hbelowWT⟩ :=
    kvE_subBracket2_complete_extract σ M x1 w x t hx1
  -- The three region-positive enumerations (duplicate-free `Finset.univ.toList` filters).
  set S_XU : List (NormalForm sig 0 1) :=
    (Finset.univ.toList).filter (fun χ => σ.2 (nf0_assemble kvE_sub2_zXU χ σ.1)) with hSXU
  set S_UW : List (NormalForm sig 0 1) :=
    (Finset.univ.toList).filter (fun χ => σ.2 (nf0_assemble kvE_sub2_zUW χ σ.1)) with hSUW
  set S_WT : List (NormalForm sig 0 1) :=
    (Finset.univ.toList).filter (fun χ => σ.2 (nf0_assemble kvE_sub2_zWT χ σ.1)) with hSWT
  have hrealXU : ∀ χ ∈ S_XU, ∃ u, x < u ∧ u < x1 ∧ nf_eval_nf M 0 1 (fun _ => u) χ :=
    fun χ hχ => hbelowXU χ (List.mem_filter.mp hχ).2
  have hrealUW : ∀ χ ∈ S_UW, ∃ u, x1 < u ∧ u < w ∧ nf_eval_nf M 0 1 (fun _ => u) χ :=
    fun χ hχ => hbelowUW χ (List.mem_filter.mp hχ).2
  have hrealWT : ∀ χ ∈ S_WT, ∃ u, w < u ∧ u < t ∧ nf_eval_nf M 0 1 (fun _ => u) χ :=
    fun χ hχ => hbelowWT χ (List.mem_filter.mp hχ).2
  -- Sorted arrangement selection across the three regions (SURVIVE `k1v_sorted_realization3`).
  obtain ⟨psXU, psUW, psWT, hpermXU, hpermUW, hpermWT, hsortFull, hpropsXU, hpropsUW, hpropsWT⟩ :=
    k1v_sorted_realization3 M x x1 w t hxx1 hx1w hwt S_XU S_UW S_WT
      ((Finset.nodup_toList _).filter _) ((Finset.nodup_toList _).filter _)
      ((Finset.nodup_toList _).filter _) hrealXU hrealUW hrealWT
  -- Enter the carrier: gate branch, then the (psXU, psUW, psWT) arrangement disjunct (rule N5).
  simp only [kvE_subBracket2V, VVecEA2.holds]
  split
  case isFalse hg => exact absurd hgate hg
  case isTrue hg =>
  refine ⟨_, List.mem_flatMap.mpr ⟨psXU.map Prod.fst, List.mem_permutations.mpr hpermXU,
    List.mem_flatMap.mpr ⟨psUW.map Prod.fst, List.mem_permutations.mpr hpermUW,
      List.mem_map.mpr ⟨psWT.map Prod.fst, List.mem_permutations.mpr hpermWT, rfl⟩⟩⟩, ?_⟩
  refine ⟨?_, ?_, ?_⟩
  · -- Left endpoint predicate at the FIXED `x` (exterior Since + at-x literals; Prop 3.5 p.5).
    simp only [TemporalPred.eval_at]
    rw [formula_conjList_iff]
    intro f hf
    rcases List.mem_append.mp hf with hf | hf
    · rcases List.mem_cons.mp hf with rfl | hf
      · exact (hchar _ x).mpr h_x_nf
      · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
        split
        next hb =>
          obtain ⟨v, hzv, hev⟩ := (h_zone _ χ).mpr hb
          obtain ⟨⟨_, _⟩, _, ⟨hvx, _⟩, _⟩ := (kvE_sub2_zoneHolds_cons_iff M x1 w x t v _ _ _ _).mp hzv
          exact ⟨v, hvx.mpr rfl, (hchar χ v).mpr hev, fun r _ _ hfa => hfa⟩
        next hb =>
          rintro ⟨s, hsx, hsχ, -⟩
          have hbit := (h_zone _ χ).mp ⟨s, hzPastX s hsx, (hchar χ s).mp hsχ⟩
          exact absurd hbit hb
    · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
      split
      next hb =>
        obtain ⟨v, hzv, hev⟩ := (h_zone _ χ).mpr hb
        obtain ⟨_, _, ⟨hvx, hxv⟩, _⟩ := (kvE_sub2_zoneHolds_cons_iff M x1 w x t v _ _ _ _).mp hzv
        have hveq : v = x := le_antisymm (not_lt.mp (k1v_not_of_iff_false hxv))
          (not_lt.mp (k1v_not_of_iff_false hvx))
        exact (hchar χ x).mpr (hveq ▸ hev)
      next hb =>
        intro hch
        have hbit := (h_zone _ χ).mp ⟨x, hzAtX, (hchar χ x).mp hch⟩
        exact absurd hbit hb
  · -- Right endpoint predicate at the FIXED `t` (at-t + exterior Until literals; Prop 3.5 p.5).
    simp only [TemporalPred.eval_at]
    rw [formula_conjList_iff]
    intro f hf
    rcases List.mem_append.mp hf with hf | hf
    · rcases List.mem_cons.mp hf with rfl | hf
      · exact (hchar _ t).mpr h_t_nf
      · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
        split
        next hb =>
          obtain ⟨v, hzv, hev⟩ := (h_zone _ χ).mpr hb
          obtain ⟨_, _, _, ⟨hvt, htv⟩⟩ := (kvE_sub2_zoneHolds_cons_iff M x1 w x t v _ _ _ _).mp hzv
          have hveq : v = t := le_antisymm (not_lt.mp (k1v_not_of_iff_false htv))
            (not_lt.mp (k1v_not_of_iff_false hvt))
          exact (hchar χ t).mpr (hveq ▸ hev)
        next hb =>
          intro hch
          have hbit := (h_zone _ χ).mp ⟨t, hzAtT, (hchar χ t).mp hch⟩
          exact absurd hbit hb
    · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
      split
      next hb =>
        obtain ⟨v, hzv, hev⟩ := (h_zone _ χ).mpr hb
        obtain ⟨_, _, _, ⟨_, htv⟩⟩ := (kvE_sub2_zoneHolds_cons_iff M x1 w x t v _ _ _ _).mp hzv
        exact ⟨v, htv.mpr rfl, (hchar χ v).mpr hev, fun r _ _ hfa => hfa⟩
      next hb =>
        rintro ⟨s, hts, hsχ, -⟩
        have hbit := (h_zone _ χ).mp ⟨s, hzFutT s hts, (hchar χ s).mp hsχ⟩
        exact absurd hbit hb
  · -- The three-region bracket, assembled from the sorted realizations (SURVIVE construct3).
    refine k1v_bracket_construct3 M atomMap _ _ _ _ _ _ _ _ x x1 w t hxx1 hx1w hwt
      (psXU.map Prod.snd) (psUW.map Prod.snd) (psWT.map Prod.snd)
      (by simp) (by simp) (by simp) hsortFull ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_ ?_
    · intro u hu
      obtain ⟨p, hp, rfl⟩ := List.mem_map.mp hu
      exact (hpropsXU p hp).1
    · intro u hu
      obtain ⟨p, hp, rfl⟩ := List.mem_map.mp hu
      exact (hpropsUW p hp).1
    · intro u hu
      obtain ⟨p, hp, rfl⟩ := List.mem_map.mp hu
      exact (hpropsWT p hp).1
    · -- `ptX1` witness point at `x1`: charK head (via `hcharK`) + folded `zAtX1` literals.
      simp only [TemporalPred.eval_at]
      rw [formula_conjList_iff]
      intro f hf
      rcases List.mem_cons.mp hf with rfl | hf
      · exact hcharK x1 hx1
      · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
        split
        next hb =>
          obtain ⟨v, hzv, hev⟩ := (h_zone _ χ).mpr hb
          obtain ⟨⟨hvx1, hx1v⟩, _, _, _⟩ := (kvE_sub2_zoneHolds_cons_iff M x1 w x t v _ _ _ _).mp hzv
          have hveq : v = x1 := le_antisymm (not_lt.mp (k1v_not_of_iff_false hx1v))
            (not_lt.mp (k1v_not_of_iff_false hvx1))
          exact (hchar χ x1).mpr (hveq ▸ hev)
        next hb =>
          intro hch
          have hbit := (h_zone _ χ).mp ⟨x1, hzAtX1, (hchar χ x1).mp hch⟩
          exact absurd hbit hb
    · -- `ptW` witness point at `w`: charBase head (`h_w_nf`) + folded `zAtW` literals.
      simp only [TemporalPred.eval_at]
      rw [formula_conjList_iff]
      intro f hf
      rcases List.mem_cons.mp hf with rfl | hf
      · exact (hchar _ w).mpr h_w_nf
      · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
        split
        next hb =>
          obtain ⟨v, hzv, hev⟩ := (h_zone _ χ).mpr hb
          obtain ⟨_, ⟨hvw, hwv⟩, _, _⟩ := (kvE_sub2_zoneHolds_cons_iff M x1 w x t v _ _ _ _).mp hzv
          have hveq : v = w := le_antisymm (not_lt.mp (k1v_not_of_iff_false hwv))
            (not_lt.mp (k1v_not_of_iff_false hvw))
          exact (hchar χ w).mpr (hveq ▸ hev)
        next hb =>
          intro hch
          have hbit := (h_zone _ χ).mp ⟨w, hzAtW, (hchar χ w).mp hch⟩
          exact absurd hbit hb
    · -- Per-index `zXU` point types on the `psXU` witnesses.
      intro i hi
      have hi' : i < psXU.length := by simpa using hi
      have h1 : (List.map (fun χ => (⟨nf_depth0_char_formula atomMap h_surj χ⟩ : TemporalPred))
          (psXU.map Prod.fst))[i]'hi =
          ⟨nf_depth0_char_formula atomMap h_surj ((psXU[i]'hi').1)⟩ := by
        simp only [List.getElem_map]
      have h2 : (psXU.map Prod.snd)[i]'(by simpa using hi') = (psXU[i]'hi').2 := by
        simp only [List.getElem_map]
      rw [h1, h2]
      exact (hchar _ _).mpr (hpropsXU _ (List.getElem_mem _)).2
    · -- Per-index `zUW` point types on the `psUW` witnesses.
      intro i hi
      have hi' : i < psUW.length := by simpa using hi
      have h1 : (List.map (fun χ => (⟨nf_depth0_char_formula atomMap h_surj χ⟩ : TemporalPred))
          (psUW.map Prod.fst))[i]'hi =
          ⟨nf_depth0_char_formula atomMap h_surj ((psUW[i]'hi').1)⟩ := by
        simp only [List.getElem_map]
      have h2 : (psUW.map Prod.snd)[i]'(by simpa using hi') = (psUW[i]'hi').2 := by
        simp only [List.getElem_map]
      rw [h1, h2]
      exact (hchar _ _).mpr (hpropsUW _ (List.getElem_mem _)).2
    · -- Per-index `zWT` point types on the `psWT` witnesses.
      intro i hi
      have hi' : i < psWT.length := by simpa using hi
      have h1 : (List.map (fun χ => (⟨nf_depth0_char_formula atomMap h_surj χ⟩ : TemporalPred))
          (psWT.map Prod.fst))[i]'hi =
          ⟨nf_depth0_char_formula atomMap h_surj ((psWT[i]'hi').1)⟩ := by
        simp only [List.getElem_map]
      have h2 : (psWT.map Prod.snd)[i]'(by simpa using hi') = (psWT[i]'hi').2 := by
        simp only [List.getElem_map]
      rw [h1, h2]
      exact (hchar _ _).mpr (hpropsWT _ (List.getElem_mem _)).2
    · -- `segXU` exclusion on ALL of `(x, x1)` (Rabinovich Cor 5.4 md:154-157).
      intro u hxu hux1
      simp only [TemporalPred.eval_at]
      rw [formula_conjList_iff]
      intro f hf
      obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
      split
      next hb => exact fun hfa => hfa
      next hb =>
        intro hch
        have hbit := (h_zone _ χ).mp ⟨u, hzXU u hxu hux1, (hchar χ u).mp hch⟩
        exact absurd hbit hb
    · -- `segUW` exclusion on ALL of `(x1, w)`.
      intro u hx1u huw
      simp only [TemporalPred.eval_at]
      rw [formula_conjList_iff]
      intro f hf
      obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
      split
      next hb => exact fun hfa => hfa
      next hb =>
        intro hch
        have hbit := (h_zone _ χ).mp ⟨u, hzUW u hx1u huw, (hchar χ u).mp hch⟩
        exact absurd hbit hb
    · -- `segWT` exclusion on ALL of `(w, t)`.
      intro u hwu hut
      simp only [TemporalPred.eval_at]
      rw [formula_conjList_iff]
      intro f hf
      obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
      split
      next hb => exact fun hfa => hfa
      next hb =>
        intro hch
        have hbit := (h_zone _ χ).mp ⟨u, hzWT u hwu hut, (hchar χ u).mp hch⟩
        exact absurd hbit hb

/-- **Arity-4 correctness pair** for the nine-zone `VVecEA2` carrier `kvE_subBracket2V` — the
arity-4 analog of the k1v pair `(bracketEndChar_k1v_sound, bracketEndChar_k1v_complete)`
(:2338 / :2979). Bundles the two independently-driven, sorry-free directions of task 325 v2:

* **soundness** (`kvE_subBracket2V_sound`, Phase 2): the carrier `.holds` implies an honest
  depth-1 realization `∃ x1, nf_eval_nf M 1 4 (Fin.cons x1 [w,x,t]) σ` exists;
* **completeness** (`kvE_subBracket2V_complete`, Phase 3): an honest realization implies the
  carrier `.holds`.

Both directions are machine-verified NON-vacuously: Phase-1 `kvE_subBracket2V_nonvacuous` proves
the nine-zone gate `consistent` set (which now includes the witness self-zones `zAtX1`, `zAtW`) is
satisfiable by an honest σ, so the carrier's `disjuncts` list is non-empty and soundness does not
close over an empty carrier (the exact defect that voided task 324 Phase 6 and task 325 v1).

Successor-parameterized at gate instance `j = 0` (`σ : NormalForm sig 1 4`, the landed instance of
the amended-spec header `NormalForm sig (j+1) 4`). Codomain is `VVecEA2` with three per-region
segment types `segXU`/`segUW`/`segWT`; anchor set fixed at `{x, t}` with `x1`, `w` as interior
witness slots (Guard G4/Anchor-Cap). Standalone against `nf_eval_nf M 1 4`; NOT wired into the outer
gate `kvE2_body`/`bracketEndChar_kvE2` (task 321's `/revise 321` work). No new proof obligations:
each direction is discharged by the corresponding Phase-2/3 lemma. -/
theorem kvE_subBracket2V_correctness_pair {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4)
    (M : OrderedMonadicStructure sig)
    (w x t : M.carrier)
    (h_xx1 : σ.1 (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    (h_x1w : σ.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = true)
    (h_wt : σ.1 (.order ⟨1, by omega⟩ ⟨3, by omega⟩ (by decide)) = true)
    (hcharK : ∀ a : M.carrier,
      nf_eval_nf M 1 4 (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) σ →
      (⟨charK (nfk_projFresh σ)⟩ : TemporalPred).eval_at M atomMap a)
    (hgate : ∀ a : M.carrier, x < a → a < t →
      (⟨charK (nfk_projFresh σ)⟩ : TemporalPred).eval_at M atomMap a →
      a < w ∧ w < t ∧
      nf_eval_nf M 0 4 (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) σ.1 ∧
      (∀ τ : NormalForm sig 0 5, nf0_dropFresh τ ≠ σ.1 → σ.2 τ = false) ∧
      (∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1),
        (∃ v : M.carrier,
          zoneHolds M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) zs v ∧
          nf_eval_nf M 0 1 (fun _ => v) χ) →
        σ.2 (nf0_assemble zs χ σ.1) = true) ∧
      (∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1), zs ≠ kvE_sub2_zXU →
        σ.2 (nf0_assemble zs χ σ.1) = true →
        ∃ v : M.carrier,
          zoneHolds M (Fin.cons a (Fin.cons w (Fin.cons x (fun _ => t)))) zs v ∧
          nf_eval_nf M 0 1 (fun _ => v) χ)) :
    ((kvE_subBracket2V (nf_depth0_char_formula atomMap h_surj) charK σ).holds M atomMap x t →
      ∃ x1 : M.carrier,
        nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) ∧
    ((∃ x1 : M.carrier,
        nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) →
      (kvE_subBracket2V (nf_depth0_char_formula atomMap h_surj) charK σ).holds M atomMap x t) :=
  ⟨fun h => kvE_subBracket2V_sound atomMap h_surj charK σ M w x t h hgate,
   fun h => kvE_subBracket2V_complete atomMap h_surj charK σ M w x t h_xx1 h_x1w h_wt hcharK h⟩

open Classical in
/-- **Corrected per-sub enriched body** (task 321 Phase 5; report §3 item 4). Structurally IS
    `kvE'_body` (:5405, same-module `private` reuse of `kvE_pinArrangements`/`kvE_pinDisjunct`/
    `kvE_exclConj`/`bracketFromLists` is legal) with the ONE corrective change F1–F4 demanded: the
    per-sub JOINT literal is replaced by the nested F_i-chain splice.
    - `ptSub σ` is now `kvE_subChain charBase charK σ` (the nested sub-bracket's `fChainPred`, which
      carries `σ`'s inner-witness structure via the nested-Until evaluation point), NOT the flat
      `⟨charK (nfk_projFresh σ)⟩` (:5467) that F4 refuted as positionally vacuous.
    - The `t`-anchored provider literal `pos.map exF` (`exF = P.existF 3`, :5448) is DROPPED
      entirely — the `exF`/`P.existF 3` parameter disappears from the joint path (report §3 note),
      so no `e`-rebinding site exists (the F4 crux `w = e 1` / `x = e 2` cannot arise). `P.existF 0`
      (the unary `charK` channel) is retained.
    ALL other channels (gate, unary `epL`/`epR` non-joint parts, zones, arrangements `pinSlots`,
    `ptW`, `segL`/`segR`, channel-(ii) `exclAt`) are retained VERBATIM — F4 isolated the gap to the
    per-sub joint channel ONLY.

    **Depth note (forced by report §2/Q2).** This body is at the CONCRETE gate instance (subs
    `σ : NormalForm sig 1 4`, `q : NormalForm sig 1 4 → Bool`, `charK : NormalForm sig 1 1 →
    Formula`), because `kvE_subChain` reads `σ.2` through the depth-0 `nf0_assemble` engine, which
    the report fixes at `j = 0` ("the gate instance j = 0 needs only the landed `nf0_assemble`"; the
    general-`j` fold-engine lift is deferred follow-on). This is exactly the `k = 2` carrier the GO
    gate targets; the general-`j` header is not needed for the gate. -/
private noncomputable def kvE2_body {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig 1 1 → Formula)
    (r : NormalForm sig 0 3)
    (q : NormalForm sig 1 4 → Bool) : VVecEA2 :=
  let ltz : Bool × Bool := (true, false)
  let eqz : Bool × Bool := (false, false)
  let gtz : Bool × Bool := (false, true)
  let mk3 : Bool × Bool → Bool × Bool → Bool × Bool → ZoneSpec 3 := fun pw px pt =>
    Fin.cons pw (Fin.cons px (fun _ => pt))
  let zPastX := mk3 ltz ltz ltz
  let zAtX   := mk3 ltz eqz ltz
  let zXW    := mk3 ltz gtz ltz
  let zAtW   := mk3 eqz gtz ltz
  let zWT    := mk3 gtz gtz ltz
  let zAtT   := mk3 gtz gtz eqz
  let zFutT  := mk3 gtz gtz gtz
  let pos : List (NormalForm sig 1 4) := Finset.univ.toList.filter (fun σ => q σ)
  let neg : List (NormalForm sig 1 4) := Finset.univ.toList.filter (fun σ => !q σ)
  let zone : NormalForm sig 1 4 → ZoneSpec 3 := fun σ =>
    nf0_zoneSpec (NormalForm.atom_assgn σ)
  let posIn : ZoneSpec 3 → List (NormalForm sig 1 4) := fun zs =>
    pos.filter (fun σ => decide (zone σ = zs))
  let negIn : ZoneSpec 3 → List (NormalForm sig 1 4) := fun zs =>
    neg.filter (fun σ => decide (zone σ = zs))
  let hasPos : ZoneSpec 3 → NormalForm sig 1 1 → Bool := fun zs χ =>
    (posIn zs).any (fun σ => decide (nfk_projFresh σ = χ))
  let allTypes : List (NormalForm sig 1 1) := Finset.univ.toList
  let lit : Bool → Formula → Formula := fun bit f => if bit then f else f.neg
  let xType : TemporalPred := ⟨charBase (nf_x_proj3 r)⟩
  let tType : TemporalPred := ⟨charBase (nf_t_proj3 r)⟩
  let epL : TemporalPred :=
    ⟨formula_conjList
      (xType.formula
        :: (allTypes.map fun χ => lit (hasPos zPastX χ) (Formula.snce (charK χ) Formula.top))
        ++ (allTypes.map fun χ => lit (hasPos zAtX χ) (charK χ)))⟩
  -- epR: the t-anchored joint literal `pos.map exF` is DROPPED (report §3 note; the joint content
  -- rides `kvE_subChain` on the witness slot instead of any provider literal at `t`).
  let epR : TemporalPred :=
    ⟨formula_conjList
      (tType.formula
        :: (allTypes.map fun χ => lit (hasPos zAtT χ) (charK χ))
        ++ (allTypes.map fun χ => lit (hasPos zFutT χ) (Formula.untl (charK χ) Formula.top)))⟩
  let exclAt : ZoneSpec 3 → List Formula := fun zs =>
    (negIn zs).map fun σ =>
      if hasPos zs (nfk_projFresh σ) then Formula.top else kvE_exclConj charBase charK σ
  let segL : TemporalPred :=
    ⟨formula_conjList
      ((allTypes.map fun χ =>
        if hasPos zXW χ then Formula.top else (charK χ).neg) ++ exclAt zXW)⟩
  let segR : TemporalPred :=
    ⟨formula_conjList
      ((allTypes.map fun χ =>
        if hasPos zWT χ then Formula.top else (charK χ).neg) ++ exclAt zWT)⟩
  let ptW : TemporalPred :=
    ⟨formula_conjList
      (charBase (nf_y_proj r)
        :: (allTypes.map fun χ => lit (hasPos zAtW χ) (charK χ)))⟩
  -- CORRECTED joint channel (task 321 Phase 8 re-point): the per-sub joint slot is now the
  -- three-region sub-chain accessor `kvE_subChain2V` (task 325, :6901) over `bracketFromLists3`
  -- — the list of per-arrangement Cor 5.4 F_i-chains (Rabinovich md:154-157), each reading `σ.2`
  -- through the three interior zones `zXU`/`zUW`/`zWT` (Prop 3.5 md:87-94). This supersedes the
  -- old single `kvE_subChain σ` splice (F4-blocked: its upward-only chain could not reach the
  -- below-anchor zone `zXU`); `kvE_subChain2V` returns a `List TemporalPred` (one chain per
  -- arrangement-disjunct), so the joint slot is spliced with `++` rather than `::`. No `P.existF 3`
  -- on the joint path; `P.existF 0` (the unary `charK` channel) retained verbatim.
  let ptSub : NormalForm sig 1 4 → List TemporalPred := fun σ => kvE_subChain2V charBase charK σ
  let pinSlots : NormalForm sig 1 4 → List TemporalPred := fun σ =>
    (kvE_pinArrangements σ).flatMap (fun a => (kvE_pinDisjunct charBase charK σ a).1)
  let slotsFor : List (NormalForm sig 1 4) → List TemporalPred := fun l =>
    l.flatMap (fun σ => ptSub σ ++ pinSlots σ)
  let S_L : List (NormalForm sig 1 4) := posIn zXW
  let S_R : List (NormalForm sig 1 4) := posIn zWT
  let mkDisjunct : List (NormalForm sig 1 4) → List (NormalForm sig 1 4) → Σ n, VecEA2 n :=
    fun lL lR =>
      ⟨(slotsFor lL).length + 1 + (slotsFor lR).length,
        { endpointLeft := epL
          endpointRight := epR
          bracket := bracketFromLists (slotsFor lL) ptW (slotsFor lR) segL segR }⟩
  @dite _ (kvE_gate r q) (Classical.dec _)
    (fun _ =>
      { disjuncts :=
          S_L.permutations.flatMap fun lL =>
            S_R.permutations.map fun lR => mkDisjunct lL lR })
    (fun _ => { disjuncts := [] })

/-- Gate-failure computation for the corrected body (the `kvE'_body_gate_fail` :5494 mirror). -/
private theorem kvE2_body_gate_fail {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig 1 1 → Formula)
    (r : NormalForm sig 0 3)
    (q : NormalForm sig 1 4 → Bool)
    (h : ¬ kvE_gate r q) :
    kvE2_body charBase charK r q = { disjuncts := [] } := by
  simp only [kvE2_body]
  exact dif_neg h

/-- **The corrected per-sub enriched successor-depth V-carrier** (task 321 Phase 6; report §3
    item 5). Additive alongside `bracketEndChar_kvE` (:5150) and `bracketEndChar_kvE'` (:5510), both
    UNCHANGED. At depth-1 providers (`P : ExistProviders sig atomMap 1`) it produces the k=2 carrier
    `BracketEndCharCarrierV sig 2`, delegating to `kvE2_body` at the standard instantiation
    (`charBase = nf_depth0_char_formula`, `charK = P.existF 0`) — the joint channel now carried by
    `kvE_subChain` (no `exF` / `P.existF 3` on the joint path). This is the carrier whose k=2
    `BracketCarrierCorrectVPrior` gate the task drives to GO (Stages C/D). -/
noncomputable def bracketEndChar_kvE2 {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (P : ExistProviders sig atomMap 1) :
    BracketEndCharCarrierV sig 2 :=
  fun qnf =>
    kvE2_body (nf_depth0_char_formula atomMap h_surj)
      (fun χ => P.existF 0 χ) qnf.1 qnf.2

/-- **Concrete k=2 instance bridge** (task 321 Phase 6; the `bracketEndChar_kvE'_two_eq` :5523
    mirror). At depth-1 providers the corrected carrier is DEFINITIONALLY the corrected body at the
    standard instantiation. Pure `rfl` — Stages C/D rewrite with this to expose `kvE2_body`. Because
    the carrier is already at the concrete gate instance (report §2/Q2 forces `j = 0`), this bridge
    is the definitional unfolding rather than a `j+1 ⇒ j=0` depth specialization; a depth mismatch
    from any successor threading error would fail this `rfl` immediately. -/
theorem bracketEndChar_kvE2_two_eq {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (P : ExistProviders sig atomMap 1)
    (qnf : NormalForm sig 2 3) :
    bracketEndChar_kvE2 atomMap h_surj P qnf =
      kvE2_body (nf_depth0_char_formula atomMap h_surj)
        (fun χ => P.existF 0 χ) qnf.1 qnf.2 := rfl

/-- **Phase 8 wiring-boundary non-vacuity consumption** (task 321 Phase 8; binding non-vacuity-gate
    countermeasure). Before any Stage-C/D correctness direction is opened over the re-pointed
    `kvE2_body`/`bracketEndChar_kvE2` joint channel (whose per-sub joint slot is now
    `kvE_subChain2V` :6901 — the list of per-arrangement Cor 5.4 F_i-chains over `bracketFromLists3`,
    Rabinovich md:154-157), we CONSUME task 325's landed `kvE_subBracket2V_nonvacuous` (:7743) as a
    `have` at the wiring boundary: for an honest σ realized at the anchor env `[x1, w, x, t]` under
    `x < x1 < w < t`, the sub-bracket carrier whose arrangement-fChainPreds now feed that joint slot
    has a NON-empty `disjuncts` list. This records, at the re-point site, that the corrected carrier
    is inhabited — foreclosing the three prior gate-class vacuity failures (task 321 P8 `zXU`
    reachability; task 324 P6 false-∀-M converse; task 325 v1 empty-gate vacuity) BEFORE Stages C/D
    open. Purely consumes the landed lemma (no `simp`/`omega`/`aesop`); Rabinovich Prop 4.2
    (md:100-101), Prop 3.5 (md:87-94). -/
theorem kvE2_joint_nonvacuous_at_honest {sig : MonadicSignature}
    (charBase : NormalForm sig 0 1 → Formula)
    (charK : NormalForm sig 1 1 → Formula)
    (σ : NormalForm sig 1 4)
    (M : OrderedMonadicStructure sig)
    (x1 w x t : M.carrier)
    (hxx1 : x < x1) (hx1w : x1 < w) (hwt : w < t)
    (h : nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    (kvE_subBracket2V charBase charK σ).disjuncts ≠ [] := by
  have hnv := kvE_subBracket2V_nonvacuous charBase charK σ M x1 w x t hxx1 hx1w hwt h
  exact hnv

end Bimodal.Metalogic.WeakCanonical.Kamp
