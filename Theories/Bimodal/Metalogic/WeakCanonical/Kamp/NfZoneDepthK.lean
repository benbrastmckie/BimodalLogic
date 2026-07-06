import Bimodal.Metalogic.WeakCanonical.Kamp.VecEADecomp

/-!
# Phase 11 (11a): Depth-k atom/order extraction groundwork for the two-anchor zone converter

This module is the depth-`k` generalization scaffold for the two-anchor arity-3 zone
converter (Rabinovich 2014 §5, Cor 5.4 `F_i` chain). It is **off the live import path**
(nothing in the `completeness_discrete` chain imports it) and is **fully sorry-free**.

## What this file lands (sorry-free)

The forward direction of every depth-0 zone lemma (`nf_3var_zone_*_correct`,
`VecEADecomp.lean:518-731`) begins by extracting, from `nf_eval_nf M 0 3 [y,x,t] ssn`, the
per-variable predicate facts and the six pairwise order facts (`h_o_yx`, `h_o_yt`, …). At
depth 0 those extractions are inlined per-atom. Here they are generalized to **arbitrary
depth `k`** as reusable lemmas:

* `nf_eval_atom_layer` — from `nf_eval_nf M k n env nf` recover the atom-layer iff
  `atom_eval M env a ↔ (nf.atom_assgn a = true)` at ANY depth `k` (the atom layer is present
  at every depth: it is `nf` itself at `k = 0` and `nf.1` at `k+1`).
* `nf3_order_iff` — specialize the atom layer to an order atom on the two-anchor env
  `[y, x, t]`, giving `(env i < env j) ↔ (qnf.atom_assgn (.order i j h) = true)` for any
  `i ≠ j : Fin 3`, at any depth `k`.
* `nf3_order_yx`/`_yt`/`_xy`/`_xt`/`_ty`/`_tx` — the six concrete pairwise order facts, the
  exact `h_o_*` hypotheses `reconstruct_nf_3var` consumes, now at depth `k`.

These are the pieces of the depth-k zone converter that genuinely generalize; they de-risk the
forward direction and the Phase-14 order-atom 3-way split, and are reused verbatim by Phases
12/13/14.

## DIVERGENCE NOTE — why the depth-k zone converter is NOT finished here (Phase 11b crux)

The depth-0 zone converters express `∃ y, nf_eval_nf M 0 3 [y,x,t] ssn` as a `VecEA2` whose
endpoint/witness `TemporalPred`s are the **independent per-variable projections**
(`nf_x_proj3`, `nf_t_proj3`, `nf_y_proj` via `nfPred`) glued by the order atoms
(`reconstruct_nf_3var`). This works at depth 0 **only because a depth-0 NF is purely atomic**:
`NormalForm sig 0 3 = AtomKind sig 3 → Bool` factors completely into per-variable predicate
assignments plus pairwise order atoms, so the three variables are independent given the order
facts.

At depth `k+1`, `NormalForm sig (k+1) 3 = (AtomKind sig 3 → Bool) × (NormalForm sig k 4 → Bool)`
carries a **quant layer** `qnf.2 : NormalForm sig k 4 → Bool` whose semantics
(`nf_eval_nf`, NormalForm.lean:203-207) is
`∀ sub, (∃ w, nf_eval_nf M k 4 (Fin.cons w [y,x,t]) sub) ↔ (qnf.2 sub = true)`.
This condition couples `y`, `x`, `t` **simultaneously** through the shared quantified `w`; it
does **not** factor through per-variable projections. Consequently the naive projection-based
`VecEA2` (endpoint/witness = per-variable characteristic formulas) satisfies only the `→`
direction: its `.holds` is a conjunction of independent per-anchor facts, strictly weaker than
`∃ y, nf_eval_nf M k 3 [y,x,t] qnf`. The `←` direction is a genuine **NON-theorem** — the exact
structural failure already diagnosed for the x=t arm in Phase 10 (`liftIdx (totalUnskip)`
non-injectivity cannot recover non-diagonal-realizable coupled sub-forms; see the Phase 10
"Re-scoped on resume" note and the PARTIAL diagnosis, plan v39:243-285).

The faithful depth-k converter therefore requires Rabinovich's genuine inductive step (§5): the
`∃ y` must be pushed **through** the coupled quant layer using the characteristic types of the
**joint** `(w, y)` configuration relative to the two anchors, fed as segment/point
`TemporalPred`s through `bracketBuildLeft`/`bracketBuildRight`. That construction — and the x=t
arm folded in from Phase 10, which is downstream of it — is the irreducible Phase 11b crux and is
scoped to the next dispatch. No strategic `sorry` is stated here for it, because any
non-vacuous statement of the faithful converter presupposes that construction (an existential
`∃ formula, …` is vacuous — closed by `Classical.choice` — and is explicitly forbidden by the
plan's Postmortem Constraints); the honest artifact is the sorry-free extraction layer below plus
this note.

## References
- Rabinovich 2014 §5 (interval split), Cor 5.4 (`F_i` chain)
- `VecEADecomp.lean:407-744` (depth-0 templates: `reconstruct_nf_3var`, `nf_3var_zone_*`)
- `NormalForm.lean:134-207` (`NormalForm`, `nf_eval_nf`, `atom_eval`)
- plan v39 Phase 11; Phase 10 "Re-scoped on resume" note
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical

/-! ## Uniform depth-k atom-layer extraction -/

/-- From a satisfied normal form at ANY depth `k`, recover the atom-layer equivalence:
    each atom's semantic evaluation matches its atom-layer assignment. At `k = 0` the whole
    `nf` is the atom layer; at `k+1` it is the first projection `nf.1`. This is the
    depth-general form of the per-atom extractions inlined in the depth-0 zone proofs. -/
theorem nf_eval_atom_layer {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (k n : Nat)
    (env : Fin n → M.carrier) (nf : NormalForm sig k n)
    (h : nf_eval_nf M k n env nf) (a : AtomKind sig n) :
    atom_eval M env a ↔ (nf.atom_assgn a = true) := by
  cases k with
  | zero => exact h a
  | succ k =>
    obtain ⟨atomA, quantA⟩ := nf
    exact h.1 a

/-! ## Depth-k order extraction on the two-anchor env `[y, x, t]`

Variable 0 = y (existential), Variable 1 = x (free anchor), Variable 2 = t (free anchor),
matching the depth-0 projection convention (`VecEADecomp.lean:30`). -/

/-- The two-anchor arity-3 environment `Fin.cons y (Fin.cons x (fun _ => t))`. -/
noncomputable def zoneEnv3 {sig : MonadicSignature} {M : OrderedMonadicStructure sig}
    (y x t : M.carrier) : Fin 3 → M.carrier :=
  Fin.cons y (Fin.cons x (fun _ => t))

/-- General depth-k order extraction: for any two distinct positions `i ≠ j : Fin 3`, the
    strict order between the corresponding carrier values matches the NF's order-atom
    assignment. This is the depth-`k` generalization of the inlined `h_o_*` extractions in
    every depth-0 `nf_3var_zone_*_correct` forward proof. -/
theorem nf3_order_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (k : Nat)
    (qnf : NormalForm sig k 3) (y x t : M.carrier)
    (h : nf_eval_nf M k 3 (Fin.cons y (Fin.cons x (fun _ => t))) qnf)
    (i j : Fin 3) (hij : i ≠ j) :
    ((Fin.cons y (Fin.cons x (fun _ : Fin 1 => t)) : Fin 3 → M.carrier) i <
      (Fin.cons y (Fin.cons x (fun _ : Fin 1 => t)) : Fin 3 → M.carrier) j) ↔
    (qnf.atom_assgn (.order i j hij) = true) := by
  have hlayer := nf_eval_atom_layer M k 3 _ qnf h (.order i j hij)
  simpa only [atom_eval] using hlayer

/-! ### The six concrete pairwise order facts at depth k

These are the exact `h_o_yx`, `h_o_yt`, `h_o_xy`, `h_o_xt`, `h_o_ty`, `h_o_tx` hypotheses that
`reconstruct_nf_3var` (`VecEADecomp.lean:407`) consumes — here generalized to depth `k` and
oriented so the carrier-side is the plain `<` on `y`, `x`, `t`. -/

/-- Depth-k order fact `y < x`. -/
theorem nf3_order_yx {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (k : Nat)
    (qnf : NormalForm sig k 3) (y x t : M.carrier)
    (h : nf_eval_nf M k 3 (Fin.cons y (Fin.cons x (fun _ => t))) qnf) :
    (y < x) ↔ (qnf.atom_assgn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = true) := by
  have hgen := nf3_order_iff M k qnf y x t h ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)
  simpa [Fin.cons] using hgen

/-- Depth-k order fact `y < t`. -/
theorem nf3_order_yt {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (k : Nat)
    (qnf : NormalForm sig k 3) (y x t : M.carrier)
    (h : nf_eval_nf M k 3 (Fin.cons y (Fin.cons x (fun _ => t))) qnf) :
    (y < t) ↔ (qnf.atom_assgn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true) := by
  have hgen := nf3_order_iff M k qnf y x t h ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)
  simpa [Fin.cons] using hgen

/-- Depth-k order fact `x < y`. -/
theorem nf3_order_xy {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (k : Nat)
    (qnf : NormalForm sig k 3) (y x t : M.carrier)
    (h : nf_eval_nf M k 3 (Fin.cons y (Fin.cons x (fun _ => t))) qnf) :
    (x < y) ↔ (qnf.atom_assgn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true) := by
  have hgen := nf3_order_iff M k qnf y x t h ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)
  simpa [Fin.cons] using hgen

/-- Depth-k order fact `x < t`. -/
theorem nf3_order_xt {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (k : Nat)
    (qnf : NormalForm sig k 3) (y x t : M.carrier)
    (h : nf_eval_nf M k 3 (Fin.cons y (Fin.cons x (fun _ => t))) qnf) :
    (x < t) ↔ (qnf.atom_assgn (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = true) := by
  have hgen := nf3_order_iff M k qnf y x t h ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)
  simpa [Fin.cons] using hgen

/-- Depth-k order fact `t < y`. -/
theorem nf3_order_ty {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (k : Nat)
    (qnf : NormalForm sig k 3) (y x t : M.carrier)
    (h : nf_eval_nf M k 3 (Fin.cons y (Fin.cons x (fun _ => t))) qnf) :
    (t < y) ↔ (qnf.atom_assgn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = true) := by
  have hgen := nf3_order_iff M k qnf y x t h ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)
  simpa [Fin.cons] using hgen

/-- Depth-k order fact `t < x`. -/
theorem nf3_order_tx {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (k : Nat)
    (qnf : NormalForm sig k 3) (y x t : M.carrier)
    (h : nf_eval_nf M k 3 (Fin.cons y (Fin.cons x (fun _ => t))) qnf) :
    (t < x) ↔ (qnf.atom_assgn (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = true) := by
  have hgen := nf3_order_iff M k qnf y x t h ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)
  simpa [Fin.cons] using hgen

/-! ## Phase 11b: the joint characteristic-type reduction

The DIVERGENCE NOTE above refutes the *projection* route. The faithful route (Rabinovich §5)
keeps the witness `y` and the shared quantified `w` **jointly**, working with the
**characteristic normal form** of `[y, x, t]` rather than per-variable projections. The lemmas
below are the sorry-free foundation of that route: they replace the existential over
`nf_eval_nf` by an existential over *characteristic-type equality*, and expose the quant layer
as a genuine (non-projected) coupling condition. -/

/-- Quant-layer companion to `nf_eval_atom_layer`: from a satisfied depth-`k+1` normal form,
    recover the quantifier-layer equivalence — for every depth-`k` sub-form with one extra
    variable, existential realizability over the extended env `Fin.cons w env` matches the
    quant assignment. This is the other half of the succ-case decomposition of `nf_eval_nf`
    (11a landed the atom half); together they characterize a satisfied depth-`k+1` NF. The
    `∃ w` here is the coupling the projection route cannot factor — it is carried *verbatim*
    into the zone converter's realizability obligations. -/
theorem nf_eval_quant_layer {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (k n : Nat)
    (env : Fin n → M.carrier) (nf : NormalForm sig (k + 1) n)
    (h : nf_eval_nf M (k + 1) n env nf) (sub : NormalForm sig k (n + 1)) :
    (∃ w, nf_eval_nf M k (n + 1) (Fin.cons w env) sub) ↔ (nf.quant_assgn sub = true) := by
  obtain ⟨atomA, quantA⟩ := nf
  exact h.2 sub

/-- **Characteristic-type reduction** (foundational for the depth-`k` zone converter). The
    two-anchor arity-3 existential over the witness `y` is equivalent to the existence of a
    witness whose *characteristic normal form* at `[y, x, t]` is exactly `qnf`. By
    `nf_exists_unique`, `[y, x, t]` satisfies `qnf` iff `qnf` is its characteristic NF, so the
    `∃ y` ranges over exactly the witnesses realizing `qnf` as a characteristic type. This is
    the genuine (non-projection) reformulation on which Rabinovich's zone split (§5, Cor 5.4)
    operates: the zone converter now reasons about *which characteristic types occur* as `y`
    ranges over each zone, rather than gluing independent per-variable projections. -/
theorem nf_zone_exists_iff_char {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (k : Nat)
    (qnf : NormalForm sig k 3) (x t : M.carrier) :
    (∃ y, nf_eval_nf M k 3 (zoneEnv3 y x t) qnf) ↔
    (∃ y, nf_characteristic M k 3 (zoneEnv3 y x t) = qnf) := by
  constructor
  · rintro ⟨y, hy⟩
    exact ⟨y, nf_eval_unique M k 3 (zoneEnv3 y x t) _ _
      (nf_characteristic_satisfies M k 3 (zoneEnv3 y x t)) hy⟩
  · rintro ⟨y, hy⟩
    refine ⟨y, ?_⟩
    rw [← hy]
    exact nf_characteristic_satisfies M k 3 (zoneEnv3 y x t)

/-! ## Phase 11b: the witness zone partition (Rabinovich §5 / Cor 5.4 F_i chain)

With the target existential reduced to characteristic-type equality
(`nf_zone_exists_iff_char`), the witness `y` is split by its order position relative to the two
anchors `x`, `t`. This is the semantic skeleton of Rabinovich's `F_i` chain: five zones
`y < x`, `y = x`, `x < y < t`, `y = t`, `t < y`. The partition is **unconditionally valid** (it
case-splits on the actual order relations; degenerate anchor orders merely empty/overlap zones,
which a disjunction tolerates). Each zone existential is later converted to a temporal formula
by feeding the depth-`k` IH through `bracketBuildLeft` (past zones) / `bracketBuildRight`
(future zones). -/

/-- Generic single-boundary trichotomy split of an existential: any witness lies below, at, or
    above a fixed boundary `c`. The atom of the zone decomposition. -/
theorem exists_trichotomy_split {α : Type*} [LinearOrder α] (P : α → Prop) (c : α) :
    (∃ y, P y) ↔
      (∃ y, y < c ∧ P y) ∨ P c ∨ (∃ y, c < y ∧ P y) := by
  constructor
  · rintro ⟨y, hy⟩
    rcases lt_trichotomy y c with h | h | h
    · exact Or.inl ⟨y, h, hy⟩
    · exact Or.inr (Or.inl (h ▸ hy))
    · exact Or.inr (Or.inr ⟨y, h, hy⟩)
  · rintro (⟨y, _, hy⟩ | hc | ⟨y, _, hy⟩)
    · exact ⟨y, hy⟩
    · exact ⟨c, hc⟩
    · exact ⟨y, hy⟩

/-- **Five-zone witness partition** of the characteristic-type existential (Rabinovich's `F_i`
    chain, §5 / Cor 5.4). Splits `∃ y, char[y,x,t] = qnf` into the five order zones of `y`
    relative to the anchors `x`, `t`. Unconditionally valid; the converter dispatches on the
    compile-time `x`/`t` order (from `qnf`'s order atoms) to select which zones are live and
    which bracket builder consumes each. The `y = x` / `y = t` point zones become the diagonal
    (two-value-collision) sub-problems handled by `renameNF_eval_diag0`; the open zones
    (`y<x`, `x<y<t`, `t<y`) become `Since`/`Until` brackets over the depth-`k` IH. -/
theorem nf_zone_partition5 {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (k : Nat)
    (qnf : NormalForm sig k 3) (x t : M.carrier) :
    (∃ y, nf_characteristic M k 3 (zoneEnv3 y x t) = qnf) ↔
      (∃ y, y < x ∧ nf_characteristic M k 3 (zoneEnv3 y x t) = qnf) ∨
      (nf_characteristic M k 3 (zoneEnv3 x x t) = qnf) ∨
      (∃ y, x < y ∧ y < t ∧ nf_characteristic M k 3 (zoneEnv3 y x t) = qnf) ∨
      (nf_characteristic M k 3 (zoneEnv3 t x t) = qnf) ∨
      (∃ y, t < y ∧ nf_characteristic M k 3 (zoneEnv3 y x t) = qnf) := by
  constructor
  · rintro ⟨y, hy⟩
    rcases lt_trichotomy y x with hyx | hyx | hyx
    · exact Or.inl ⟨y, hyx, hy⟩
    · exact Or.inr (Or.inl (hyx ▸ hy))
    · rcases lt_trichotomy y t with hyt | hyt | hyt
      · exact Or.inr (Or.inr (Or.inl ⟨y, hyx, hyt, hy⟩))
      · exact Or.inr (Or.inr (Or.inr (Or.inl (hyt ▸ hy))))
      · exact Or.inr (Or.inr (Or.inr (Or.inr ⟨y, hyt, hy⟩)))
  · rintro (⟨y, _, hy⟩ | hx | ⟨y, _, _, hy⟩ | ht | ⟨y, _, hy⟩)
    · exact ⟨y, hy⟩
    · exact ⟨x, hx⟩
    · exact ⟨y, hy⟩
    · exact ⟨t, ht⟩
    · exact ⟨y, hy⟩

/-- The two-anchor arity-3 existential, fully split into its five witness zones (composition of
    `nf_zone_exists_iff_char` with `nf_zone_partition5`). This is the exact statement the
    depth-`k` zone converter must realize as a nested `Since`/`Until` bracket: LHS is the
    semantic target `∃ y, nf_eval_nf …`, RHS is the zone-partitioned characteristic-type form
    whose open zones feed the bracket builders and whose point zones feed the diagonal
    collapse. -/
theorem nf_zone_exists_partition5 {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (k : Nat)
    (qnf : NormalForm sig k 3) (x t : M.carrier) :
    (∃ y, nf_eval_nf M k 3 (zoneEnv3 y x t) qnf) ↔
      (∃ y, y < x ∧ nf_characteristic M k 3 (zoneEnv3 y x t) = qnf) ∨
      (nf_characteristic M k 3 (zoneEnv3 x x t) = qnf) ∨
      (∃ y, x < y ∧ y < t ∧ nf_characteristic M k 3 (zoneEnv3 y x t) = qnf) ∨
      (nf_characteristic M k 3 (zoneEnv3 t x t) = qnf) ∨
      (∃ y, t < y ∧ nf_characteristic M k 3 (zoneEnv3 y x t) = qnf) :=
  (nf_zone_exists_iff_char M k qnf x t).trans (nf_zone_partition5 M k qnf x t)

end Bimodal.Metalogic.WeakCanonical.Kamp
