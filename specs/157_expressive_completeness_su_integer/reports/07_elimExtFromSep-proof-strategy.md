# Phase 7 Research: Proof Strategy for `atom_elim_correct`

**Date**: 2026-05-17
**Agent**: lean-research-agent
**Status**: Research complete

---

## 1. Exact Definitions Found

### `elimExtFromSep` (lines 623-646)

```lean
private noncomputable def elimExtFromSep
    (constSubs : List (Atom × Formula))
    (lt_atom gt_atom : Atom) : Formula → Formula
  | .atom a =>
    -- Present level substitution
    applySubsts (.atom a) (constSubs ++ [(lt_atom, .bot), (gt_atom, .bot)])
  | .bot => .bot
  | .imp φ ψ => .imp (elimExtFromSep constSubs lt_atom gt_atom φ)
                      (elimExtFromSep constSubs lt_atom gt_atom ψ)
  | .box φ => .box φ
  | .all_past φ =>
    -- Past-only: lt_ref → ⊤ (True), gt_ref → ⊥
    .all_past (applySubsts φ (constSubs ++ [(lt_atom, Formula.neg .bot), (gt_atom, .bot)]))
  | .all_future φ =>
    -- Future-only: lt_ref → ⊥, gt_ref → ⊤ (True)
    .all_future (applySubsts φ (constSubs ++ [(lt_atom, .bot), (gt_atom, Formula.neg .bot)]))
  | .snce φ ψ =>
    -- Past-only args
    .snce (applySubsts φ (constSubs ++ [(lt_atom, Formula.neg .bot), (gt_atom, .bot)]))
          (applySubsts ψ (constSubs ++ [(lt_atom, Formula.neg .bot), (gt_atom, .bot)]))
  | .untl φ ψ =>
    -- Future-only args
    .untl (applySubsts φ (constSubs ++ [(lt_atom, .bot), (gt_atom, Formula.neg .bot)]))
          (applySubsts ψ (constSubs ++ [(lt_atom, .bot), (gt_atom, Formula.neg .bot)]))
```

Key observation: `elimExtFromSep` does NOT recurse into the body of temporal operators. For `all_past φ`, it calls `applySubsts φ pastSubs` directly (not `elimExtFromSep` on `φ`). This is correct because `is_properly_separated` guarantees `φ` is already past-only (flat atoms, no nested temporal structure).

### `quantElimFormula` (lines 672-685)

```lean
private noncomputable def quantElimFormula
    (atomMap : sig.preds → Atom) (extAM : (extSignature sig).preds → Atom)
    (B_sep : Formula) : Formula :=
  let lt_atom := extAM .lt_ref
  let gt_atom := extAM .gt_ref
  let origSubs := origSubsList atomMap extAM
  -- origSubs : [(extAM(.orig p), Formula.atom(atomMap p)) | p ∈ sig.preds]
  let assignments := (Finset.univ : Finset (sig.preds → Bool)).toList
  let branches := assignments.map fun σ =>
    Formula.and (guardFormula atomMap σ)
                (elimExtFromSep (origSubs ++ constSubsList extAM σ) lt_atom gt_atom B_sep)
  -- constSubsList extAM σ : [(extAM(.const_at_ref p), if σ p then ¬⊥ else ⊥) | p ∈ sig.preds]
  match branches with
  | [] => .bot
  | [b] => b
  | b :: bs => bs.foldl Formula.or b
```

The formula is a disjunction over all truth-assignments σ of `guard(σ) ∧ elimExt(B_sep)[σ]`.

### The `atom_elim_correct` theorem (lines 949-958)

Proof state at the sorry (line 958):

```
sig : MonadicSignature
atomMap : sig.preds → Atom
hinj : Function.Injective atomMap
freshAM : (extSignature sig).preds → Atom
freshAM_inj : Function.Injective freshAM
h_disj : ∀ (p : sig.preds) (ep : (extSignature sig).preds), atomMap p ≠ freshAM ep
M : IntStructureFromSig sig
t : ℤ
B_sep : Formula
hB_sep : is_properly_separated B_sep = true
hB_atoms : formula_atoms B_sep ⊆ Set.range freshAM
⊢ int_truth (to_int_struct (extIntStruct M t) freshAM) t B_sep ↔
    int_truth (to_int_struct M atomMap) t (quantElimFormula atomMap freshAM B_sep)
```

---

## 2. Why Is This Hard? The Time-Dependent Semantics Problem

### lt_ref and gt_ref atoms

`ExtPred sig` has four variants:
- `.orig p` — original predicate, truth at z depends on M.interp p z
- `.const_at_ref p` — truth at z is M.interp p t_ref (constant in z!)
- `.lt_ref` — truth at z is `z < t_ref`
- `.gt_ref` — truth at z is `t_ref < z`

In `extIntStruct M t_ref`:
- `lt_ref` at time z = (z < t_ref): TRUE for z < t, FALSE for z = t, FALSE for z > t
- `gt_ref` at time z = (t_ref < z): FALSE for z < t, FALSE for z = t, TRUE for z > t

### Why uniform replacement fails

If you tried to replace `freshAM(.lt_ref)` with a single formula `r`, you would need:
- `r` false at the present time t (since t < t is false)
- `r` true at all past times s < t (since s < t)
- `r` false at all future times s > t (since t < s is false for lt_ref)

No single formula in the language can simultaneously be true at all past times and false at the present, because `all_past r` would require r true at all times s < t and we evaluate the outer formula at t.

The correct solution (which `elimExtFromSep` implements) is: use DIFFERENT substitutions for the two temporal contexts:
- In **past-only** subformulas (arguments of `all_past`, `snce`): replace `lt_ref` with `¬⊥` (True) and `gt_ref` with `⊥` (False), because at any past time s < t, `s < t` is always true.
- In **future-only** subformulas (arguments of `all_future`, `untl`): replace `gt_ref` with `¬⊥` (True) and `lt_ref` with `⊥` (False), because at any future time s > t, `t < s` is always true.
- At the **present level** (atoms, boolean combinations): replace both `lt_ref` and `gt_ref` with `⊥`, since t < t and t < t are both false.

### What "level-aware substitution" means

The `is_properly_separated` predicate guarantees that:
- `all_past φ` and `snce φ ψ` require `is_past_only φ = true` (and `is_past_only ψ = true`)
- `all_future φ` and `untl φ ψ` require `is_future_only φ = true` (and `is_future_only ψ = true`)
- The outer boolean structure contains only atoms, bot, imp, and box

This means: the formula's structure is FLAT at temporal constructors. Each temporal operator's body is a purely past-only or purely future-only formula — no nesting of temporal operators within temporal operators. The `elimExtFromSep` function takes advantage of this flatness: it handles the bodies of temporal operators by calling `applySubsts` directly (not recursing into `elimExtFromSep`), using the correct level-specific substitution list.

---

## 3. Available Helper Lemmas

### From ExpressiveCompleteness.lean (private to this file)

1. **`applySubsts_past_correct`** (lines 742-761): If `φ` is past-only, `M` is a model, and every replacement `r` in `subs` is past-only with `int_truth M s r ↔ s ∈ M.val a` for all `s ≤ t`, then `int_truth M t (applySubsts φ subs) ↔ int_truth M t φ`.

2. **`applySubsts_future_correct`** (lines 764-783): Symmetric version for future-only formulas, with condition `s ≥ t`.

3. **`to_int_struct_mem_freshAM`** (lines 793-805): `z ∈ (to_int_struct (extIntStruct M t) freshAM).val (freshAM ep) ↔ (extIntStruct M t).interp ep z`.

4. **`to_int_struct_mem_atomMap`** (lines 808-817): `z ∈ (to_int_struct M atomMap).val (atomMap p) ↔ M.interp p z`.

5. **`int_truth_foldl_and`** (lines 822-839): Truth of a foldl-and list.

6. **`guardFormula_correct`** (lines 842-881): `int_truth (to_int_struct M atomMap) t (guardFormula atomMap σ) ↔ (∀ p, σ p = true ↔ M.interp p t)`.

7. **`int_truth_depends_on_atoms`** (lines 894-939): Truth depends only on atoms in the formula.

8. **`subst_preserves_past_only`** / **`subst_preserves_future_only`**: Substitution preserves syntactic purity predicates.

### From Separation module

- **`past_only_subst_correct`** / **`future_only_subst_correct`**: Substituting an atom in a past/future-only formula is correct when the replacement matches the atom at all relevant times.
- **`subst_correctness`**: `int_truth M t (subst_formula φ target r) ↔ int_truth (M.withAtom target {s | int_truth M s r}) t φ`.

### MISSING helpers that need to be proved

The handoff mentions `applySubsts_atom_hit`, `applySubsts_atom_miss`, `int_truth_foldl_or`, and `guardFormula_unique` as things the previous agent added. But searching the file shows NO such theorems exist in the current file. They appear to have been discussed but NOT committed. The implementer will need to prove these from scratch.

---

## 4. The Core Proof Strategy

The proof is an iff, so we need to prove both directions.

### High-Level Architecture

**Key insight**: The `quantElimFormula` is a disjunction over all assignments σ. Exactly one branch is "active" — the branch where σ matches the model M at time t:

Define `σ₀ : sig.preds → Bool` by `σ₀ p = true ↔ M.interp p t` (i.e., σ₀ is the "true assignment").

- The guard formula `guardFormula atomMap σ₀` is true in `to_int_struct M atomMap` at t (by `guardFormula_correct`).
- For all other σ ≠ σ₀, the guard formula `guardFormula atomMap σ` is false (by `guardFormula_correct` + uniqueness).

So the proof reduces to:

**Forward** (ext model → orig model): Show the σ₀ branch is true.
**Backward** (orig model → ext model): From the disjunction being true, extract the unique true branch (which must be σ₀), then use correctness.

### Step 1: Define σ₀ by Classical Choice

```lean
-- The "true assignment" at t
let σ₀ : sig.preds → Bool := fun p => decide (M.interp p t)
```

This gives `σ₀ p = true ↔ M.interp p t` (by `decide` and classical reasoning).

### Step 2: Prove `guardFormula_correct` applies to σ₀

```lean
have hguard₀ : Separation.int_truth (to_int_struct M atomMap) t (guardFormula atomMap σ₀) :=
  (guardFormula_correct atomMap hinj σ₀ M t).mpr (fun p => by simp [σ₀, decide_eq_true_iff])
```

### Step 3: The elimExtFromSep Correctness

This is the heart of the proof. We need:

```lean
Separation.int_truth (to_int_struct (extIntStruct M t) freshAM) t B_sep ↔
Separation.int_truth (to_int_struct M atomMap) t
  (elimExtFromSep (origSubs ++ constSubsList freshAM σ₀) (freshAM .lt_ref) (freshAM .gt_ref) B_sep)
```

This is the **`elimExtFromSep_correct`** lemma that needs to be proved as a sub-lemma.

---

## 5. Case-by-Case Proof of `elimExtFromSep_correct`

Let:
- `M_ext := to_int_struct (extIntStruct M t) freshAM` (the extended model)
- `M_orig := to_int_struct M atomMap` (the original model)
- `constSubs := origSubs ++ constSubsList freshAM σ₀`
  - `origSubs` maps `freshAM(.orig p) → Formula.atom (atomMap p)`
  - `constSubsList freshAM σ₀` maps `freshAM(.const_at_ref p) → if σ₀ p then ¬⊥ else ⊥`
- `lt_atom := freshAM .lt_ref`, `gt_atom := freshAM .gt_ref`

**Claim**: For all `B_sep` with `is_properly_separated B_sep = true` and `formula_atoms B_sep ⊆ Set.range freshAM`:
```
int_truth M_ext t B_sep ↔
int_truth M_orig t (elimExtFromSep constSubs lt_atom gt_atom B_sep)
```

### Case `.atom a`

Since `formula_atoms (.atom a) ⊆ Set.range freshAM`, there exists `ep : ExtPred sig` with `freshAM ep = a`.

`elimExtFromSep constSubs lt_atom gt_atom (.atom a) = applySubsts (.atom a) (constSubs ++ [(lt_atom, ⊥), (gt_atom, ⊥)])`

The full substitution list is:
```
origSubs ++ constSubsList freshAM σ₀ ++ [(freshAM .lt_ref, ⊥), (freshAM .gt_ref, ⊥)]
```

By exhaustion on `ep`:

**Subcase `ep = .orig p`**: `a = freshAM (.orig p)`
- LHS: `int_truth M_ext t (.atom a)` = `t ∈ M_ext.val (freshAM (.orig p))` = `(extIntStruct M t).interp (.orig p) t` = `M.interp p t`
- The substitution list contains `(freshAM (.orig p), Formula.atom (atomMap p))`. Since freshAM is injective, no other entry in `constSubs` matches `freshAM (.orig p)` (the const entries use `freshAM (.const_at_ref q)`, the lt/gt entries use `freshAM .lt_ref` / `freshAM .gt_ref`, all different by injectivity).
- So `applySubsts (.atom a) subs` reduces to `Formula.atom (atomMap p)`.
- RHS: `int_truth M_orig t (Formula.atom (atomMap p))` = `t ∈ M_orig.val (atomMap p)` = `M.interp p t` (by `to_int_struct_mem_atomMap`).
- **Match**. Confidence: HIGH.

**Subcase `ep = .const_at_ref p`**: `a = freshAM (.const_at_ref p)`
- LHS: `t ∈ M_ext.val (freshAM (.const_at_ref p))` = `(extIntStruct M t).interp (.const_at_ref p) t` = `M.interp p t` (constant in z!)
- The substitution list contains `(freshAM (.const_at_ref p), if σ₀ p then ¬⊥ else ⊥)`.
- RHS becomes: `int_truth M_orig t (if σ₀ p then ¬⊥ else ⊥)` = `σ₀ p = true` (since `¬⊥` is always true and `⊥` is always false).
- Since `σ₀ p = true ↔ M.interp p t`, LHS = RHS. **Match**. Confidence: HIGH.

**Subcase `ep = .lt_ref`**: `a = freshAM .lt_ref`
- LHS: `t ∈ M_ext.val (freshAM .lt_ref)` = `(extIntStruct M t).interp .lt_ref t` = `t < t` = False.
- Substitution contains `(freshAM .lt_ref, ⊥)` at end. After substitution: `⊥`.
- RHS: `int_truth M_orig t ⊥` = False. **Match**. Confidence: HIGH.

**Subcase `ep = .gt_ref`**: symmetric to `.lt_ref`, both False at t. **Match**. Confidence: HIGH.

**Key helper needed**: `applySubsts_atom_hit` and the disjointness argument. Need a lemma:

```lean
-- If (a, r) is the first entry in subs where a = target, then
-- applySubsts (.atom target) subs = applySubsts r rest
-- (because subst_formula (.atom target) target r = r, and
--  subsequent entries don't affect r's atoms if disjoint)
```

Actually the simpler approach: unfold `applySubsts` step-by-step via induction on the substitution list, using the fact that (a) the list entries use freshAM which is injective (so no two entries share the same atom), and (b) the first matching entry substitutes the atom and further substitutions don't hit it (since freshAM atoms are used exactly once).

### Case `.bot`

`elimExtFromSep constSubs lt_atom gt_atom .bot = .bot`
Both sides are False. Trivial. Confidence: HIGH.

### Case `.imp φ ψ`

`elimExtFromSep constSubs lt_atom gt_atom (.imp φ ψ) = .imp (elimExtFromSep ... φ) (elimExtFromSep ... ψ)`

By `is_properly_separated (.imp φ ψ) = true`, both `φ` and `ψ` are properly separated.
By `formula_atoms (.imp φ ψ) = formula_atoms φ ∪ formula_atoms ψ ⊆ Set.range freshAM`,
both `formula_atoms φ` and `formula_atoms ψ` are in range of freshAM.

Use IH on both φ and ψ:

```lean
simp only [elimExtFromSep, Separation.int_truth]
exact Iff.imp (IH_φ) (IH_ψ)
```

Confidence: HIGH. This is structural and the IH applies directly.

### Case `.box φ`

`elimExtFromSep constSubs lt_atom gt_atom (.box φ) = .box φ`

`int_truth M_ext t (.box φ) = True` and `int_truth M_orig t (.box φ) = True` (since `box _ => True` in the semantics).

Both sides are True. Trivial. Confidence: HIGH.

### Case `.all_past φ`

`is_properly_separated (.all_past φ) = true` implies `is_past_only φ = true`.

`elimExtFromSep constSubs lt_atom gt_atom (.all_past φ) = .all_past (applySubsts φ pastSubs)`
where `pastSubs = constSubs ++ [(lt_atom, ¬⊥), (gt_atom, ⊥)]`.

**LHS**: `int_truth M_ext t (.all_past φ)` = `∀ s < t, int_truth M_ext s φ`

**RHS**: `int_truth M_orig t (.all_past (applySubsts φ pastSubs))` = `∀ s < t, int_truth M_orig s (applySubsts φ pastSubs)`

We need: `int_truth M_ext s φ ↔ int_truth M_orig s (applySubsts φ pastSubs)` for all s < t.

Apply `applySubsts_past_correct` to `M_orig` (not M_ext!) with:
- The formula φ is past-only: `hpo : is_past_only φ = true` — guaranteed by `hB_sep`.
- The substitution list `pastSubs` contains past-only replacements:
  - origSubs entries: `Formula.atom (atomMap p)` — is_past_only? Yes (atoms are past-only).
  - constSubsList entries: `¬⊥` or `⊥` — both past-only (no temporal operators).
  - `(lt_atom, ¬⊥)` — ¬⊥ is past-only.
  - `(gt_atom, ⊥)` — ⊥ is past-only.
- The h_match condition: for all `(a, r) ∈ pastSubs`, for all s ≤ ... (actually we need s ≤ u for the application point u = s, but since φ is past-only, `applySubsts_past_correct` applies at time s with condition for times ≤ s).

Wait — `applySubsts_past_correct` requires `h_match : ∀ (a r), (a, r) ∈ subs → ∀ u, u ≤ t → (int_truth M u r ↔ u ∈ M.val a)`. But here the model is M_orig (not M_ext) and the atoms in `pastSubs` come from `freshAM` (in origSubs and constSubsList), while M_orig uses atomMap. These atoms are DISJOINT by `h_disj`.

This is the critical difficulty. The `applySubsts_past_correct` lemma works when you have a matching condition for the substitution target atoms IN THE TARGET MODEL (M_orig). But:
- `freshAM (.orig p)` is not in the range of `atomMap` (by h_disj), so `M_orig.val (freshAM (.orig p))` = ∅ for any time.
- But the replacement `Formula.atom (atomMap p)` evaluated in M_orig at s gives `M.interp p s`.

**The bridge**: We need to show the multi-substitution `applySubsts φ pastSubs` evaluated in M_orig equals `int_truth M_ext s φ` for past times s < t.

**Approach**: Use `int_truth_depends_on_atoms` to transfer from M_ext to a "bridged" model, then use `applySubsts_past_correct` with the bridged model.

Alternatively, prove `elimExtFromSep_correct` for the temporal subformula DIRECTLY without going through `applySubsts_past_correct`:

**Direct approach for `.all_past φ`** (RECOMMENDED):

Define a bridge model `M_bridge` that agrees with M_ext on freshAM atoms:
```
M_bridge.val a = M_orig.val a  -- for atomMap atoms
M_bridge.val (freshAM (.orig p)) = M_orig.val (atomMap p)  -- orig: same as atomMap
M_bridge.val (freshAM (.const_at_ref p)) = {s | s ∈ M_ext.val (freshAM .const_at_ref p)}  = {s | M.interp p t}  -- constant!
M_bridge.val (freshAM .lt_ref) = {s | s < t}  -- past: all s in range are < t, so this is {s | True} restricted appropriately
M_bridge.val (freshAM .gt_ref) = ∅  -- for past subformulas, gt_ref is always False
```

Wait, this approach is overly complex. Let me think more carefully.

**The clean approach** is to prove a SEPARATE standalone lemma:

```lean
private theorem applySubsts_past_extModel
    (φ : Formula) (hpo : Separation.is_past_only φ = true)
    (h_atoms : formula_atoms φ ⊆ Set.range freshAM)
    (M : IntStructureFromSig sig) (t s : Int) (hs : s < t) :
    Separation.int_truth M_orig s (applySubsts φ pastSubs) ↔
    Separation.int_truth M_ext s φ
```

where `M_ext = to_int_struct (extIntStruct M t) freshAM` and `pastSubs = constSubs ++ [(freshAM .lt_ref, ¬⊥), (freshAM .gt_ref, ⊥)]`.

This requires showing that for each atom `freshAM ep` in φ:
- `int_truth M_orig s (replacement for ep) ↔ s ∈ M_ext.val (freshAM ep)`

Breaking this into cases for each ep type:
- `ep = .orig p`: replacement = `Formula.atom (atomMap p)`, and `s ∈ M_ext.val (freshAM (.orig p))` = `M.interp p s` = `s ∈ M_orig.val (atomMap p)`. **Match**.
- `ep = .const_at_ref p`: replacement = `if σ₀ p then ¬⊥ else ⊥`, and `s ∈ M_ext.val (freshAM (.const_at_ref p))` = `(extIntStruct M t).interp (.const_at_ref p) s` = `M.interp p t` = `σ₀ p = true`. So replacement truth = `σ₀ p = true` = `M.interp p t`. **Match**.
- `ep = .lt_ref`: replacement = `¬⊥` (True), and `s ∈ M_ext.val (freshAM .lt_ref)` = `s < t`. Since `hs : s < t`, this is True. **Match**.
- `ep = .gt_ref`: replacement = `⊥` (False), and `s ∈ M_ext.val (freshAM .gt_ref)` = `t < s`. Since `hs : s < t`, this is False. **Match**.

**This is the key insight**: The pastSubs substitution is precisely designed so that for each `freshAM ep`, `int_truth M_orig s (replacement for ep) ↔ s ∈ M_ext.val (freshAM ep)` for all `s < t`. Confidence: HIGH.

The implementation for `.all_past φ`:

```lean
| .all_past φ =>
  simp only [is_properly_separated] at hB_sep
  -- hB_sep : is_past_only φ = true
  simp only [elimExtFromSep, Separation.int_truth]
  constructor
  · intro h_ext s hs
    -- Goal: int_truth M_orig s (applySubsts φ pastSubs)
    apply (applySubsts_past_correct hB_sep pastSubs M_orig s _ _).mpr
    -- Need: int_truth M_orig s φ with M_orig having freshAM atoms = M_ext atoms
    -- Use: int_truth M_ext s φ = int_truth M_orig s φ  [after transfer]
    ...
  · ...
```

Actually, the cleanest implementation uses `applySubsts_past_correct` applied directly to M_ext with a reformulation. Let me think more carefully.

`applySubsts_past_correct` says: if φ is past-only, and for all (a,r) in subs, for all u ≤ t, `int_truth M u r ↔ u ∈ M.val a`, then `int_truth M t (applySubsts φ subs) ↔ int_truth M t φ`.

Apply this with `M = M_orig`, evaluating at time s (not t), with pastSubs. The condition becomes: for all (a, r) in pastSubs, for all u ≤ s, `int_truth M_orig u r ↔ u ∈ M_orig.val a`.

But the atoms `a` in pastSubs are `freshAM ep` atoms, and `M_orig.val (freshAM ep)` = ∅ for all ep (since freshAM ep ∉ range atomMap by h_disj). So `u ∈ M_orig.val (freshAM ep) = False` for all u. This does NOT match (the replacement for `.lt_ref` is `¬⊥` = True, not False).

**Conclusion**: `applySubsts_past_correct` cannot be applied to M_orig with these subs. The mismatch is fundamental.

**The correct approach** for temporal cases: Use `int_truth_depends_on_atoms` (or a direct induction on the past-only formula φ) to reduce `int_truth M_ext s φ` to `int_truth M_orig s (applySubsts φ pastSubs)`.

**Alternative cleaner formulation**: Prove a NEW lemma `applySubsts_ext_to_orig_past`:

```lean
private theorem applySubsts_ext_to_orig_past
    {sig : MonadicSignature}
    (freshAM : (extSignature sig).preds → Atom) (freshAM_inj : Function.Injective freshAM)
    (atomMap : sig.preds → Atom) (hinj : Function.Injective atomMap)
    (h_disj : ∀ p ep, atomMap p ≠ freshAM ep)
    (M : IntStructureFromSig sig) (t : Int)
    (σ₀ : sig.preds → Bool) (hσ₀ : ∀ p, σ₀ p = true ↔ M.interp p t)
    (φ : Formula) (hpo : Separation.is_past_only φ = true)
    (h_atoms : Separation.formula_atoms φ ⊆ Set.range freshAM)
    (s : Int) (hs : s < t) :
    Separation.int_truth (to_int_struct (extIntStruct M t) freshAM) s φ ↔
    Separation.int_truth (to_int_struct M atomMap) s
        (applySubsts φ (origSubs ++ constSubsList freshAM σ₀ ++
                        [(freshAM .lt_ref, Formula.neg .bot), (freshAM .gt_ref, .bot)]))
```

This should be proved by induction on the past-only formula φ, using the 4-case atom analysis above and the h_atoms condition to case-split on which ep type each atom is.

Confidence: HIGH for correctness, MEDIUM for ease of implementation (needs careful atom bookkeeping).

### Case `.all_future φ`

Exactly symmetric to `.all_past φ`, but:
- `is_properly_separated (.all_future φ) = true` implies `is_future_only φ = true`
- Past substitutions swap: `lt_ref → ⊥` (False at future times s > t), `gt_ref → ¬⊥` (True at future times s > t)
- For s > t: `s > t` means `t < s` so gt_ref is True, lt_ref is False. The futureSubs = `constSubs ++ [(lt_atom, ⊥), (gt_atom, ¬⊥)]` correctly captures this.

Confidence: HIGH (mirror of all_past).

### Case `.snce φ ψ`

`is_properly_separated (.snce φ ψ) = true` implies `is_past_only φ = true` and `is_past_only ψ = true`.

`elimExtFromSep constSubs lt_atom gt_atom (.snce φ ψ) = .snce (applySubsts φ pastSubs) (applySubsts ψ pastSubs)`

LHS: `int_truth M_ext t (.snce φ ψ)` = `∃ s < t, int_truth M_ext s φ ∧ ∀ r, s < r → r < t → int_truth M_ext r ψ`

RHS: `int_truth M_orig t (.snce (applySubsts φ pastSubs) (applySubsts ψ pastSubs))`
    = `∃ s < t, int_truth M_orig s (applySubsts φ pastSubs) ∧ ∀ r, s < r → r < t → int_truth M_orig r (applySubsts ψ pastSubs)`

Apply the same `applySubsts_ext_to_orig_past` lemma at each past time `s < t` and `r < t`.

**Key**: All times s appearing in the snce semantics satisfy `s < t`, and all intermediate times `r` satisfy `s < r < t < t`, so the past-time condition `r < t` holds throughout.

Confidence: HIGH.

### Case `.untl φ ψ`

Exactly symmetric to `.snce`, using future semantics and `futureSubs`. For all `s > t`, `t < s`, so gt_ref is True, lt_ref is False.

Confidence: HIGH.

---

## 6. The Outer Disjunction

After establishing `elimExtFromSep_correct` (with σ₀ as the true assignment), the full `atom_elim_correct` proof structure is:

### Forward direction (M_ext → quantElimFormula)

1. Define σ₀ by `fun p => decide (M.interp p t)`.
2. σ₀ ∈ assignments (it's in Finset.univ).
3. The σ₀ branch of `quantElimFormula` is true:
   - `guardFormula atomMap σ₀` is true by `guardFormula_correct`.
   - `elimExtFromSep (constSubs σ₀) lt gt B_sep` is true by `elimExtFromSep_correct`.
4. The σ₀ branch being true makes the disjunction true.
   - Need `int_truth_foldl_or` (analog of `int_truth_foldl_and`).

```lean
-- int_truth_foldl_or:
-- int_truth M t (bs.foldl Formula.or b) ↔
-- int_truth M t b ∨ ∃ f ∈ bs, int_truth M t f
```

This lemma needs to be proved. It is symmetric to the existing `int_truth_foldl_and`.

### Backward direction (quantElimFormula → M_ext)

1. The disjunction is true; use `int_truth_foldl_or` to extract some branch (some σ) that is true.
2. The guard for that σ is true, so by `guardFormula_correct`, σ = σ₀ (the true assignment at t).
3. For that σ = σ₀, `elimExtFromSep_correct` gives: `int_truth M_ext t B_sep`.

**Uniqueness**: The guard formulas for different σ cannot both be true (because if `guardFormula atomMap σ` and `guardFormula atomMap τ` are both true, then for all p, `σ p = true ↔ M.interp p t` and `τ p = true ↔ M.interp p t`, so σ = τ by `funext`). This means at most one σ has a true branch.

---

## 7. Missing Lemmas That Need to Be Proved

### Required new lemmas

1. **`int_truth_foldl_or`**: Analog of `int_truth_foldl_and` for disjunction.
   ```lean
   private theorem int_truth_foldl_or (M : Separation.IntStructure) (t : Int)
       (init : Formula) (fs : List Formula) :
       Separation.int_truth M t (fs.foldl Formula.or init) ↔
       Separation.int_truth M t init ∨ ∃ f ∈ fs, Separation.int_truth M t f
   ```
   This is straightforward by induction on `fs`, mirroring `int_truth_foldl_and`. HIGH confidence.

2. **`applySubsts_ext_to_orig_past`** (the key bridge lemma):
   For past-only φ with atoms in range freshAM, for s < t:
   `int_truth M_ext s φ ↔ int_truth M_orig s (applySubsts φ pastSubs)`
   
   Proof: induction on φ. Base case: atom analysis on ep type (4 cases). Recursive cases: `.bot` trivial, `.imp` by iff.imp, `.box` trivial, `.all_past` apply IH at all past times, `.snce` apply IH at witness times. HIGH confidence.

3. **`applySubsts_ext_to_orig_future`**: Symmetric version for future-only formulas. HIGH confidence.

4. **`sigma0_exists`** (or inline): Classical choice of the true assignment σ₀.
   ```lean
   have ⟨σ₀, hσ₀⟩ : ∃ σ : sig.preds → Bool, ∀ p, σ p = true ↔ M.interp p t :=
     ⟨fun p => decide (M.interp p t), fun p => by simp [decide_eq_true_iff]⟩
   ```
   HIGH confidence (standard Lean classical reasoning).

5. **`origSubs_correct`** (the atom case for orig predicates):
   For any s, `s ∈ (to_int_struct (extIntStruct M t) freshAM).val (freshAM (.orig p))` ↔
   `int_truth (to_int_struct M atomMap) s (Formula.atom (atomMap p))`
   Follows from `to_int_struct_mem_freshAM` and `to_int_struct_mem_atomMap`. HIGH confidence.

### Already proved

- `subst_preserves_past_only`, `subst_preserves_future_only`
- `applySubsts_past_correct`, `applySubsts_future_correct`
- `guardFormula_correct`
- `int_truth_depends_on_atoms`
- `to_int_struct_mem_freshAM`, `to_int_struct_mem_atomMap`

---

## 8. Recommended Proof Template

```lean
private theorem atom_elim_correct {sig : MonadicSignature}
    (atomMap : sig.preds → Atom) (hinj : Function.Injective atomMap)
    (freshAM : (extSignature sig).preds → Atom) (freshAM_inj : Function.Injective freshAM)
    (h_disj : ∀ (p : sig.preds) (ep : (extSignature sig).preds), atomMap p ≠ freshAM ep)
    (M : IntStructureFromSig sig) (t : Int)
    (B_sep : Formula) (hB_sep : Separation.is_properly_separated B_sep = true)
    (hB_atoms : Separation.formula_atoms B_sep ⊆ Set.range freshAM) :
    Separation.int_truth (to_int_struct (extIntStruct M t) freshAM) t B_sep ↔
    Separation.int_truth (to_int_struct M atomMap) t (quantElimFormula atomMap freshAM B_sep) := by
  -- Step 1: Define the true assignment σ₀
  let σ₀ : sig.preds → Bool := fun p => decide (M.interp p t)
  have hσ₀ : ∀ p, σ₀ p = true ↔ M.interp p t := fun p => by simp [σ₀, decide_eq_true_iff]
  -- Step 2: Unfold quantElimFormula
  simp only [quantElimFormula]
  -- The branches list: need to show the disjunction = true iff B_sep true in M_ext
  -- Step 3: Establish elimExtFromSep_correct for σ₀
  have h_elim_correct :
    Separation.int_truth (to_int_struct (extIntStruct M t) freshAM) t B_sep ↔
    Separation.int_truth (to_int_struct M atomMap) t
      (elimExtFromSep (origSubsList atomMap freshAM ++ constSubsList freshAM σ₀)
                      (freshAM .lt_ref) (freshAM .gt_ref) B_sep) :=
    elimExtFromSep_correctness atomMap hinj freshAM freshAM_inj h_disj M t σ₀ hσ₀ B_sep hB_sep hB_atoms
  -- Step 4: Show the σ₀ branch is true/false with B_sep, using guardFormula_correct
  have hguard_σ₀ :
    Separation.int_truth (to_int_struct M atomMap) t (guardFormula atomMap σ₀) :=
    (guardFormula_correct atomMap hinj σ₀ M t).mpr hσ₀
  -- Step 5: Use int_truth_foldl_or to reason about the disjunction
  -- σ₀ is in the assignments list, so its branch appears in branches
  -- Forward: B_sep true in M_ext → σ₀ branch true → disjunction true
  -- Backward: extract the unique true branch σ, show σ = σ₀ by guard uniqueness
  constructor
  · intro h_ext
    -- σ₀ branch is true
    have h_branch_true :
      Separation.int_truth (to_int_struct M atomMap) t
        (Formula.and (guardFormula atomMap σ₀)
                     (elimExtFromSep ...)) :=
      ⟨hguard_σ₀, h_elim_correct.mp h_ext⟩
    -- Show this branch appears in the branches list and the disjunction holds
    ...
  · intro h_disj_true
    -- Extract the true branch (some σ)
    -- Show its guard forces σ = σ₀
    -- Apply h_elim_correct (or the corresponding lemma for σ) backwards
    ...
```

---

## 9. Technical Subtlety: The `h_base_ne` Condition in the Caller

In `expressiveness_inner`, the call to `atom_elim_correct` is:
```lean
exact h_chain.trans (atom_elim_correct atomMap hinj freshAM freshAM_inj h_disj M t B_sep hB_sep hB_atoms)
```

The `h_disj` hypothesis (`atomMap p ≠ freshAM ep` for all p, ep) follows from the freshBase construction:
- `atomMap p = mk_fresh atomMap_base n`
- `freshAM ep = mk_fresh freshBase m`
- `atomMap_base ≠ freshBase` (by the `h_base_ne` chain)
- `mk_fresh_base_ne` gives the disjointness.

This is already established in the expressiveness_inner code, so `atom_elim_correct` receives a valid `h_disj`.

---

## 10. Confidence Assessment

| Case | Proof Obligation | Confidence | Main Risk |
|------|-----------------|------------|-----------|
| `.atom a` | Atom ep case-split, 4 subcases | HIGH | Bookkeeping with applySubsts on injective freshAM |
| `.bot` | Trivial | HIGH | None |
| `.imp φ ψ` | IH on both | HIGH | None |
| `.box φ` | Both sides True | HIGH | None |
| `.all_past φ` | Bridge past lemma | MEDIUM-HIGH | `applySubsts_ext_to_orig_past` needs careful proof |
| `.all_future φ` | Bridge future lemma | MEDIUM-HIGH | Symmetric to past |
| `.snce φ ψ` | Witness + bridge | MEDIUM-HIGH | Same bridge lemma at quantified times |
| `.untl φ ψ` | Symmetric | MEDIUM-HIGH | Same as snce |
| Outer disjunction | foldl_or + guard uniqueness | MEDIUM | foldl_or shape of quantElimFormula's match |

**Overall confidence**: MEDIUM-HIGH. The math is clear; the Lean mechanics require careful attention to:
1. The specific form of `quantElimFormula` (it uses `match branches` which creates different structures for 0, 1, 2+ assignments).
2. The disjointness between origSubs atoms and constSubsList atoms (both using freshAM but at different constructors — guaranteed by freshAM_inj).
3. The fact that `applySubsts` applies substitutions LEFT-TO-RIGHT: origSubs runs first, then constSubsList, then lt/gt. Since freshAM is injective, each atom appears at most once in the list.

---

## 11. The Shape Problem for `quantElimFormula`

A subtle issue: `quantElimFormula` uses a `match branches` that produces different Lean terms depending on the number of assignments:

```lean
match branches with
| [] => .bot
| [b] => b
| b :: bs => bs.foldl Formula.or b
```

For any non-trivial sig with at least one predicate, `sig.preds → Bool` has at least 2 elements (e.g., for 1 predicate: `true` and `false`). So the `[] => .bot` case is impossible for any real sig, and the `[b] => b` case occurs only for the 0-predicate signature. In general we'll have `b :: bs` with `bs` non-empty.

This means `int_truth_foldl_or` must handle `bs.foldl Formula.or b`. Note the order: the first branch `b` is the "init" and `bs` are the remaining branches. This is the left-fold order.

**Important**: `int_truth_foldl_or` needs to express that `bs.foldl Formula.or b` is true iff `b` is true or some element of `bs` is true. This is exactly what the analog of `int_truth_foldl_and` should say for `or`.

---

## 12. Recommended Implementation Order

1. **Prove `int_truth_foldl_or`** (5-10 lines, mirror of `int_truth_foldl_and`).

2. **Prove `applySubsts_ext_to_orig_past`** and **`applySubsts_ext_to_orig_future`** (20-40 lines each, induction on past/future-only formula, 4 atom subcases).

3. **Prove `elimExtFromSep_correctness`** (the core bridge: given σ₀ is the true assignment, elimExtFromSep at σ₀ transfers truth from M_ext to M_orig). Uses the bridge lemmas from step 2.

4. **Prove `atom_elim_correct`** using steps 1-3 plus `guardFormula_correct` and classical reasoning for σ₀.

This modular decomposition avoids attempting a monolithic proof and instead builds up the necessary infrastructure piece by piece.
