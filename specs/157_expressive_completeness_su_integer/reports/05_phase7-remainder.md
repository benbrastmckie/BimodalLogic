# Phase 7 Remainder: Exact Requirements for atom_elim_correct

**Date**: 2026-05-17
**Task**: 157 (expressive-completeness-su-integer)
**File under study**: `Theories/Bimodal/Metalogic/WeakCanonical/ExpressiveCompleteness.lean` (1016 lines)

---

## Current State: Exact Sorry Obligations from lean_goal

There are exactly **3 sorries** remaining, all in `expressiveness_inner`. All three need the same
biconditional:

```
int_truth (to_int_struct (extIntStruct M t) freshAM) t B_sep
  ↔
int_truth (to_int_struct M atomMap) t (quantElimFormula atomMap freshAM B_sep)
```

abbreviated below as `M_ext ↔ M_orig`.

### Sorry 1 (line 893) — `.ex` case, final chain step

Goal before sorry:
```
⊢ (∃ x, eval (int_to_ordered sig M) (Fin.cons x fun x ↦ t) alpha)
  ↔ int_truth (to_int_struct M atomMap) t A
```

Context has `h_chain : (∃ z, ...) ↔ int_truth M_ext t B_sep`. The sorry fills the gap:
```
(sorry : int_truth M_ext t B_sep ↔ int_truth (to_int_struct M atomMap) t A)
```
where `A = quantElimFormula atomMap freshAM B_sep`.

Usage: `h_chain.trans sorry` closes the whole `.ex` goal.

### Sorry 2 (line 940) — `.all` case, mp direction

Goal before sorry (case mp):
```
h_all : ∀ x, eval (int_to_ordered sig M) (Fin.cons x fun x ↦ t) alpha
h_Aex : int_truth (to_int_struct M atomMap) t A_ex
⊢ False
```

The sorry is the backward direction of atom_elim_correct:
```
(sorry : int_truth M_ext t B_sep ↔ int_truth (to_int_struct M atomMap) t A_ex).mpr h_Aex
```
produces `h_bsep : int_truth M_ext t B_sep`, then `h_chain_neg.mpr h_bsep` gives `⟨z, hz⟩`
contradicting `h_all z`.

### Sorry 3 (line 947) — `.all` case, mpr direction

Goal before sorry (case mpr):
```
h_neg : ¬int_truth (to_int_struct M atomMap) t A_ex
h_bsep : int_truth M_ext t B_sep
⊢ False
```

The sorry is the forward direction:
```
(sorry : int_truth M_ext t B_sep ↔ int_truth (to_int_struct M atomMap) t A_ex).mp h_bsep
```
produces something that contradicts `h_neg`.

### Summary

All three sorries are instances of exactly one biconditional:
```
atom_elim_correct : int_truth M_ext t B_sep ↔ int_truth (to_int_struct M atomMap) t
                      (quantElimFormula atomMap freshAM B_sep)
```

---

## atom_elim_correct Specification (Exact Lean 4 Type)

```lean
private theorem atom_elim_correct
    {sig : MonadicSignature}
    (atomMap : sig.preds → Atom)
    (freshAM : (extSignature sig).preds → Atom)
    (freshAM_inj : Function.Injective freshAM)
    (M : IntStructureFromSig sig)
    (t : Int)
    (B_sep : Formula)
    (hB_sep : Separation.is_properly_separated B_sep = true)
    -- freshAM maps distinct ext-predicates to distinct atoms (needed to separate
    -- orig, const_at_ref, lt_ref, gt_ref contributions in to_int_struct)
    -- The model M_ext is exactly to_int_struct (extIntStruct M t) freshAM
    :
    Separation.int_truth (to_int_struct (extIntStruct M t) freshAM) t B_sep
    ↔
    Separation.int_truth (to_int_struct M atomMap) t
      (quantElimFormula atomMap freshAM B_sep) := by
  sorry
```

**Key parameters**:
- `sig` — the base monadic signature
- `atomMap : sig.preds → Atom` — the original atom map (need not be injective for this
  lemma; injectivity is used elsewhere)
- `freshAM : (extSignature sig).preds → Atom` — the fresh atom map, MUST be injective so
  that `to_int_struct (extIntStruct M t) freshAM` correctly separates ext-pred contributions
- `M : IntStructureFromSig sig` — the base model
- `t : Int` — the reference time (the "present" point)
- `B_sep : Formula` — a properly separated formula (over the extended signature, but as a
  temporal formula; the atoms in `B_sep` are `freshAM ep` for various `ep : ExtPred sig`)
- `hB_sep : is_properly_separated B_sep = true`

**The conclusion** is an iff between:
- LHS: `B_sep` evaluated at time `t` in the "extended" IntStructure (which uses `freshAM` to
  name atoms of `extSignature sig`)
- RHS: `quantElimFormula atomMap freshAM B_sep` evaluated at time `t` in the "original"
  IntStructure (which uses `atomMap` to name atoms of `sig`)

---

## Proof Strategy Per Constructor Case

The proof is by structural induction on `B_sep`, using `hB_sep` at each step.

### Understanding the semantic models

**M_ext** = `to_int_struct (extIntStruct M t) freshAM`:
```
(M_ext).val a = {z : Int | ∃ ep : ExtPred sig,
  freshAM ep = a ∧ (extIntStruct M t).interp ep z}
```
Breaking down by `ep`:
- `ep = .orig p`:    `freshAM (.orig p)` is some atom; truth at `z` = `M.interp p z`
- `ep = .const_at_ref p`: `freshAM (.const_at_ref p)` is some atom; truth at `z` = `M.interp p t`  (constant in z!)
- `ep = .lt_ref`:   `freshAM .lt_ref` is some atom; truth at `z` = `z < t`
- `ep = .gt_ref`:   `freshAM .gt_ref` is some atom; truth at `z` = `t < z`

Because `freshAM` is injective, each atom `freshAM ep` is distinct, so membership in
`(M_ext).val (freshAM ep)` at time `z` equals exactly `(extIntStruct M t).interp ep z`.

**M_orig** = `to_int_struct M atomMap`:
```
(M_orig).val a = {z : Int | ∃ p : sig.preds, atomMap p = a ∧ M.interp p z}
```
So `z ∈ (M_orig).val (atomMap p) ↔ M.interp p z`.

**quantElimFormula** (abbreviated `QEF`) produces:
```
∨_σ (guardFormula atomMap σ ∧ elimExtFromSep (origSubs ++ constSubsList freshAM σ) lt_atom gt_atom B_sep)
```
where:
- `lt_atom = freshAM .lt_ref`, `gt_atom = freshAM .gt_ref`
- `origSubs = [(freshAM (.orig p), Formula.atom (atomMap p)) | p ∈ sig.preds]`
- `constSubsList freshAM σ = [(freshAM (.const_at_ref p), if σ p then ¬⊥ else ⊥) | p ∈ sig.preds]`
- `guardFormula atomMap σ = ∧_p (if σ p then atom(atomMap p) else ¬atom(atomMap p))`

The overall strategy: case-split on the assignment `σ : sig.preds → Bool` such that
`σ p = true ↔ M.interp p t`. Exactly one branch of the disjunction matches this σ, and
the guard for that σ is true in M_orig at t (since `M_orig.val (atomMap p)` at `t` iff
`M.interp p t` iff `σ p = true`). Then the elimination formula for that σ is semantically
equivalent to B_sep in M_ext.

### Constructor Cases

**Case `atom a`** (where `a : Atom` is `freshAM ep` for some `ep`):
- `is_properly_separated (.atom a) = true` always.
- `elimExtFromSep constSubs lt gt (.atom a) = applySubsts (.atom a) (constSubs ++ [(lt, ⊥), (gt, ⊥)])`
- The substitution replaces `a` by the corresponding term in `constSubs`:
  - If `ep = .orig p`: sub is `(freshAM (.orig p), atom (atomMap p))`, so result is `atom (atomMap p)`.
    - LHS: `t ∈ M_ext.val (freshAM (.orig p)) ↔ M.interp p t`
    - RHS: `t ∈ M_orig.val (atomMap p) ↔ M.interp p t`. Match.
  - If `ep = .const_at_ref p`: sub is `(freshAM (.const_at_ref p), if σ p then ¬⊥ else ⊥)`.
    - LHS: `t ∈ M_ext.val (freshAM (.const_at_ref p)) ↔ M.interp p t`
    - RHS: guard forces `σ p = (M.interp p t : Bool)`, so replacement is correct. Match.
  - If `ep = .lt_ref`: sub is `(lt_atom, ⊥)`.
    - LHS: `t ∈ M_ext.val (freshAM .lt_ref) ↔ t < t = False`
    - RHS: `int_truth M_orig t ⊥ = False`. Match.
  - If `ep = .gt_ref`: sub is `(gt_atom, ⊥)`.
    - LHS: `t ∈ M_ext.val (freshAM .gt_ref) ↔ t < t = False`
    - RHS: `int_truth M_orig t ⊥ = False`. Match.

**Case `bot`**:
- `elimExtFromSep constSubs lt gt .bot = .bot`.
- LHS = `int_truth M_ext t .bot = False`.
- RHS = `int_truth M_orig t .bot = False`. Trivial.

**Case `imp φ ψ`** (where both `φ, ψ` are properly separated by `hB_sep`):
- `elimExtFromSep ... (.imp φ ψ) = .imp (elimExtFromSep ... φ) (elimExtFromSep ... ψ)`.
- Apply induction hypothesis to `φ` and `ψ` separately, compose with `Iff.imp`.

**Case `box φ`**:
- `elimExtFromSep ... (.box φ) = .box φ`.
- `int_truth M t (.box _) = True` always (box is degenerate in IntStructure).
- Both sides are `True`. Trivial.

**Case `all_past φ`** (where `is_past_only φ = true` by `hB_sep`):
- `elimExtFromSep constSubs lt gt (.all_past φ) = .all_past (applySubsts φ (constSubs ++ [(lt, ¬⊥), (gt, ⊥)]))`
- LHS: `int_truth M_ext t (.all_past φ) = ∀ s < t, int_truth M_ext s φ`
- RHS: `int_truth M_orig t (.all_past (...)) = ∀ s < t, int_truth M_orig s (applySubsts φ ...)`
- Key insight: for `s < t`, the relevant facts about `M_ext.val (freshAM ep)` at time `s`:
  - `ep = .orig p`:    `M.interp p s` — same in `M_orig.val (atomMap p)`
  - `ep = .const_at_ref p`:  `M.interp p t` (CONSTANT, independent of s)
  - `ep = .lt_ref`:   `s < t` — TRUE for all s < t
  - `ep = .gt_ref`:   `t < s` — FALSE for all s < t
- The substitutions in the past case are `(lt → ¬⊥ = True, gt → ⊥ = False)`, matching!
- For orig and const_at_ref:
  - orig subs: `freshAM (.orig p) → atom (atomMap p)` — correct by `applySubsts_past_correct`
    (since `atom (atomMap p)` is past-only, and at s ≤ t, `int_truth M_orig s (atom (atomMap p))
    ↔ M.interp p s ↔ s ∈ M_ext.val (freshAM (.orig p))`)
  - const subs: for s < t, `M_ext.val (freshAM (.const_at_ref p))` at s = `M.interp p t`.
    With `σ p = (M.interp p t)`, the sub is `(freshAM (.const_at_ref p), if σ p then ¬⊥ else ⊥)`.
    Truth of the replacement at any s: `int_truth M_orig s (¬⊥) = True = M.interp p t` when
    `σ p = true`, and `int_truth M_orig s ⊥ = False = M.interp p t` when `σ p = false`. Match.
- Use `applySubsts_past_correct` with appropriate `h_reps_po` and `h_match` arguments.
- Use `past_only_is_pure_past` to transfer between M_ext and M_orig at past times.

**Case `all_future φ`** (where `is_future_only φ = true` by `hB_sep`):
- Symmetric to `all_past`. Substitutions: `(lt → ⊥, gt → ¬⊥ = True)`.
- For `s > t`:
  - `ep = .lt_ref`: `s < t` is FALSE — matches sub `lt → ⊥`
  - `ep = .gt_ref`: `t < s` is TRUE — matches sub `gt → ¬⊥`
- Use `applySubsts_future_correct`.
- Use `future_only_is_pure_future`.

**Case `snce φ ψ`** (where `is_past_only φ = true`, `is_past_only ψ = true` by `hB_sep`):
- `elimExtFromSep constSubs lt gt (.snce φ ψ) =
    .snce (applySubsts φ (constSubs ++ [(lt, ¬⊥), (gt, ⊥)]))
          (applySubsts ψ (constSubs ++ [(lt, ¬⊥), (gt, ⊥)]))`
- LHS: `∃ s < t, int_truth M_ext s φ ∧ ∀ r, s < r < t → int_truth M_ext r ψ`
- RHS: `∃ s < t, int_truth M_orig s (applySubsts φ ...) ∧ ∀ r, s < r < t → int_truth M_orig r (applySubsts ψ ...)`
- Use `applySubsts_past_correct` for both φ and ψ (at each sub-time s ≤ t or r < t).
- Then use `past_only_is_pure_past` to transfer between M_ext and M_orig at those sub-times.

**Case `untl φ ψ`** (where `is_future_only φ = true`, `is_future_only ψ = true` by `hB_sep`):
- Symmetric to `snce`. Use `applySubsts_future_correct` and `future_only_is_pure_future`.

---

## Missing Infrastructure

### 1. Guard correctness lemma (NEW, ~30 LOC)

```lean
private theorem guardFormula_correct {sig : MonadicSignature}
    (atomMap : sig.preds → Atom)
    (σ : sig.preds → Bool)
    (M : IntStructureFromSig sig)
    (t : Int) :
    Separation.int_truth (to_int_struct M atomMap) t (guardFormula atomMap σ)
    ↔ (∀ p, σ p = true ↔ M.interp p t) := by
  ...
```

This is needed to prove "exactly one σ matches the model" in the quantElimFormula disjunction.

### 2. quantElimFormula disjunction lemma (NEW, ~40 LOC)

The `quantElimFormula` is a disjunction over all assignments σ. To use it, we need:

```lean
private theorem quantElimFormula_correct_iff {sig : MonadicSignature}
    (atomMap : sig.preds → Atom)
    (freshAM : (extSignature sig).preds → Atom)
    (freshAM_inj : Function.Injective freshAM)
    (M : IntStructureFromSig sig) (t : Int) (B_sep : Formula)
    (hB_sep : is_properly_separated B_sep = true) :
    int_truth (to_int_struct M atomMap) t (quantElimFormula atomMap freshAM B_sep)
    ↔ ∃ σ : sig.preds → Bool,
        (∀ p, σ p = true ↔ M.interp p t) ∧
        int_truth (to_int_struct M atomMap) t
          (elimExtFromSep (origSubsList atomMap freshAM ++ constSubsList freshAM σ)
                          (freshAM .lt_ref) (freshAM .gt_ref) B_sep)
```

This requires unfolding the List.foldl disjunction and finding the unique matching σ.

### 3. elimExtFromSep correctness lemma (THE CORE, ~100 LOC)

The heart of `atom_elim_correct`:

```lean
private theorem elimExtFromSep_correct {sig : MonadicSignature}
    (atomMap : sig.preds → Atom)
    (freshAM : (extSignature sig).preds → Atom)
    (freshAM_inj : Function.Injective freshAM)
    (M : IntStructureFromSig sig) (t : Int)
    (σ : sig.preds → Bool)
    (hσ : ∀ p, σ p = true ↔ M.interp p t)
    (B_sep : Formula)
    (hB_sep : is_properly_separated B_sep = true) :
    Separation.int_truth (to_int_struct (extIntStruct M t) freshAM) t B_sep
    ↔
    Separation.int_truth (to_int_struct M atomMap) t
      (elimExtFromSep (origSubsList atomMap freshAM ++ constSubsList freshAM σ)
                      (freshAM .lt_ref) (freshAM .gt_ref) B_sep)
```

By structural induction on `B_sep`. Uses the constructor analysis above.

### 4. Atom membership lemmas for to_int_struct (NEW, ~30 LOC)

Two or three simp lemmas needed for unfolding `M_ext.val (freshAM ep)`:

```lean
-- z ∈ (to_int_struct (extIntStruct M t) freshAM).val (freshAM (.orig p)) ↔ M.interp p z
-- z ∈ (to_int_struct (extIntStruct M t) freshAM).val (freshAM (.const_at_ref p)) ↔ M.interp p t
-- z ∈ (to_int_struct (extIntStruct M t) freshAM).val (freshAM .lt_ref) ↔ z < t
-- z ∈ (to_int_struct (extIntStruct M t) freshAM).val (freshAM .gt_ref) ↔ t < z
```

These require `freshAM_inj` to separate contributions. Each proof: unfold `to_int_struct`,
`Set.mem_setOf_eq`, use injectivity to rule out other predicates.

### 5. applySubsts h_match side conditions (MEDIUM, ~40 LOC across cases)

For each case using `applySubsts_past_correct` or `applySubsts_future_correct`, need to supply:
- `h_reps_po` / `h_reps_fo`: each replacement formula in the substitution list is past-only or
  future-only. All the formulas we use (`atom (atomMap p)`, `¬⊥`, `⊥`) satisfy this trivially.
- `h_match`: for each `(a, r)` in the sub list, `∀ s ≤ t, int_truth M_orig s r ↔ s ∈ M_ext.val a`.
  This is the semantic content of each substitution.

---

## Implementation Order

The dependencies form a small DAG:

```
(4) Atom membership lemmas
          ↓
(3) elimExtFromSep_correct  (+ applySubsts_past/future_correct from existing code)
          ↓
(2) quantElimFormula_correct_iff  (+ (1) guardFormula_correct)
          ↓
atom_elim_correct
          ↓
3 sorries at lines 893, 940, 947
```

**Step 1**: Write atom membership simp lemmas (4 lemmas, ~30 LOC). These are straightforward
  unfold-and-use-injectivity proofs.

**Step 2**: Write `guardFormula_correct` (~30 LOC). Unfold the `foldl` over
  `Finset.univ.toList`, split on each predicate, use Finset membership.

**Step 3**: Write `elimExtFromSep_correct` by structural induction on `B_sep` (~100 LOC).
  For each case invoke the relevant atom membership lemma and `applySubsts_past/future_correct`.
  The past/future cases are the hardest and need careful `h_match` witnesses.

**Step 4**: Write `quantElimFormula_correct_iff` (~40 LOC). Unfolds the disjunction by
  `Finset.univ.toList` membership, finds the unique matching σ using `guardFormula_correct`.

**Step 5**: Combine into `atom_elim_correct` (~15 LOC). Use `quantElimFormula_correct_iff` then
  `elimExtFromSep_correct` at the witness σ extracted from the model.

**Step 6**: Close the 3 sorries using `atom_elim_correct` (~5 LOC total, trivial substitutions).

---

## LOC Estimate

| Component | LOC | Difficulty |
|-----------|-----|------------|
| Atom membership simp lemmas (4 lemmas) | 30 | Easy |
| `guardFormula_correct` | 30 | Medium |
| `elimExtFromSep_correct` (structural induction) | 100 | Hard |
| `quantElimFormula_correct_iff` (disjunction unfolding) | 40 | Medium |
| `atom_elim_correct` (gluing step) | 15 | Easy |
| Sorry closure at lines 893, 940, 947 | 5 | Trivial |
| **Total** | **~220** | |

---

## Confidence Level

**High confidence** on the architecture: the sorry goals are clear from `lean_goal`, the
definitions `quantElimFormula`, `elimExtFromSep`, `origSubsList`, `constSubsList`, and
`guardFormula` are all fully concrete, and `applySubsts_past_correct` and
`applySubsts_future_correct` are already proved in the file.

**Medium confidence** on the hardest step (`elimExtFromSep_correct`): the constructor cases
for `all_past` and `all_future` require marshalling several side conditions for
`applySubsts_past_correct` / `applySubsts_future_correct`, and the `h_match` witnesses
for the extended atoms (orig, const_at_ref, lt_ref, gt_ref) need careful formulation.
The atom membership simp lemmas must be in place first.

**Potential pitfall**: `freshAM_inj` must be threaded through everywhere. The current code
already has `freshAM_inj` in scope at the sorry sites, so the lemma signature above
correctly includes it.

**Potential pitfall**: The `quantElimFormula` disjunction uses `List.foldl Formula.or` over
`assignments.map ...` where `assignments = (Finset.univ : Finset (sig.preds → Bool)).toList`.
Unfolding this disjunction requires either Finset membership lemmas or a match/case split
over `assignments`. The key fact needed is: given the model M and time t, define σ* by
`σ* p = decide (M.interp p t)`; then exactly one branch (the σ* branch) has its guard true,
and all other branches have their guards false. This requires classical reasoning since
`M.interp p t` is a Prop.

**No missing axioms**: The proof is constructive in all cases except the existential witness
for σ (use `Classical.choice` or `Finset.exists_unique`). This is consistent with the
existing `noncomputable` markers.

---

## Additional Notes

### The Handoff Says 5 Sorries, But There Are Now 3

The handoff (phase-7-handoff-20260517e.md) mentions 5 sorries (including `applySubsts_past_correct`
and `applySubsts_future_correct`). Inspection of the file at the current HEAD shows these two
are now fully proved (lines 742-783). Only 3 sorries remain, all at lines 893, 940, 947.

### The 3 Sorries Are Textually Identical Except for Direction

- Line 893: used as a `.trans` — needs the iff itself
- Line 940: uses `.mpr` direction — B_sep in M_ext → A in M_orig
- Line 947: uses `.mp` direction — B_sep in M_ext → A in M_orig

All three will be closed by `exact atom_elim_correct ...` with the appropriate arguments
substituted. The `.trans sorry` at line 893 can be replaced by `h_chain.trans (atom_elim_correct ...)`.

### freshAM Injectivity Is Available at All Sorry Sites

At all three sorry sites, the local context contains:
```
freshAM_inj : Function.Injective freshAM
```
So `atom_elim_correct` can require this as a hypothesis without any changes to the calling code.
