import Bimodal.Metalogic.WeakCanonical.Kamp.NfZoneFlattenNavigable
import Bimodal.Metalogic.WeakCanonical.Kamp.NfEFold
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

end Bimodal.Metalogic.WeakCanonical.Kamp
