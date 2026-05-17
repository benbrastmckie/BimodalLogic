# Alternative Decomposition for atom_elim_correct

**Date**: 2026-05-17
**Researcher**: lean-research-agent
**Task**: 157 — Research alternative proof paths that avoid or restructure elimExtFromSep_correct

---

## 1. Current State (Exact Sorry Count)

There is exactly **1 sorry** in the file at line 958, inside `atom_elim_correct` itself:

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
  sorry
```

There are also **2 additional sorries** at lines 1139 and 1217, both in the atom containment part of `expressiveness_inner` (the `.ex` and `.all` cases respectively). These say `formula_atoms (quantElimFormula atomMap freshAM B_sep) ⊆ Set.range atomMap`. These sorries are INDEPENDENT of `atom_elim_correct` — they are about atom containment, not truth transfer.

---

## 2. What quantElimFormula Actually Computes

```lean
quantElimFormula atomMap freshAM B_sep
  = ∨_{σ : sig.preds → Bool} (guardFormula atomMap σ  ∧  elimExtFromSep(origSubs ++ constSubs_σ, lt, gt, B_sep))
```

where:
- `origSubs` maps `freshAM(.orig p) ↦ Formula.atom (atomMap p)` for each `p : sig.preds`
- `constSubs_σ` maps `freshAM(.const_at_ref p) ↦ (if σ p then neg bot else bot)` for each `p`
- `lt = freshAM .lt_ref`, `gt = freshAM .gt_ref`
- `guardFormula atomMap σ` is the conjunction `∧_p (if σ p then atom(atomMap p) else ¬atom(atomMap p))`

The disjunction is implemented as a `foldl Formula.or` over the list of all `2^n` Boolean assignments σ.

This is a finite disjunction with `2^(card sig.preds)` branches.

---

## 3. Exact Type of the Block

The difficulty is NOT about the disjunction structure — `guardFormula_correct` is already proved (line 842) and shows that exactly the branch for `σ* = fun p => decide (M.interp p t)` has a true guard.

The core block is proving, for that unique matching σ*:
```
int_truth M_ext t B_sep ↔ int_truth M_orig t (elimExtFromSep(origSubs ++ constSubs_{σ*}, lt, gt, B_sep))
```

where `M_ext = to_int_struct (extIntStruct M t) freshAM` and `M_orig = to_int_struct M atomMap`.

---

## 4. Alternative A: Inline elimExtFromSep_correct at the atom_elim_correct Sorry

**Description**: Prove `atom_elim_correct` by direct structural induction on `B_sep` at its call site, WITHOUT extracting a separate `elimExtFromSep_correct` theorem first. The induction is INSIDE `atom_elim_correct`, combining both the "pick the right σ branch" and the "substitution correctness" reasoning in a single proof.

**Proof structure**:

```lean
-- Step 1: pick σ* = fun p => decide (M.interp p t)
let σ_star : sig.preds → Bool := fun p => decide (M.interp p t)
-- Step 2: show the σ* guard is true in M_orig
have h_guard : Separation.int_truth M_orig t (guardFormula atomMap σ_star) :=
  (guardFormula_correct atomMap hinj σ_star M t).mpr (fun p => by simp [σ_star, decide_eq_true_iff])
-- Step 3: show all other guards are false (for uniqueness / isolation of σ* branch)
--   follows from guardFormula_correct + the fact that if σ ≠ σ* then ∃ p, σ p ≠ σ* p
-- Step 4: prove int_truth_foldl_or to convert ∨_{σ} to "∃ branch with true guard"
-- Step 5: reduce to: int_truth M_ext t B_sep ↔ int_truth M_orig t (elim... B_sep)
--   by structural induction on B_sep
```

In step 5, the induction is structurally aligned with `elimExtFromSep`:

- `.bot`: both sides False. Trivial.
- `.imp`: by IH on both arms.
- `.box`: both sides True (int_truth .box _ = True always).
- `.atom a`: need to show `a ∈ M_ext.val a ↔ int_truth M_orig t (applySubsts (.atom a) (constSubs ++ [(lt,bot),(gt,bot)]))`. This is the hard case — see Section 5 below.
- `.all_past φ`: case-split on the semantics.
- `.all_future φ`, `.snce`, `.untl`: symmetric.

**Feasibility**: FEASIBLE. The atom case is the core difficulty but is mathematically sound. Steps 2, 3, 4 are all proved or provable with existing helpers.

**Confidence**: HIGH (85%). The math is correct. The Lean mechanics for the atom case require careful handling.

---

## 5. The Atom Case in Detail

For `.atom a` with `hB_atoms : {a} ⊆ Set.range freshAM`, we get `ep : ExtPred sig` such that `freshAM ep = a`. Case split on `ep`:

### ep = .orig p

- LHS: `int_truth M_ext t (.atom (freshAM (.orig p)))` = `t ∈ M_ext.val (freshAM (.orig p))` = `M.interp p t` (by `to_int_struct_mem_freshAM` + `extIntStruct` definition).
- RHS: `applySubsts (.atom (freshAM (.orig p))) (origSubs ++ constSubs_σ* ++ [(lt,bot),(gt,bot)])`. The first matching entry in origSubs is `(freshAM (.orig p), Formula.atom (atomMap p))`. Since `h_disj` guarantees `freshAM (.orig p) ≠ atomMap p'` for any `p'`, the atom `atomMap p` is NOT matched by any subsequent substitution step. So the result is `Formula.atom (atomMap p)`. Its truth in M_orig is `M.interp p t`. Both sides equal `M.interp p t`. ✓

### ep = .const_at_ref p

- LHS: `(extIntStruct M t).interp (.const_at_ref p) t` = `M.interp p t` (const_at_ref is constant in time by definition).
- RHS: constSubs_σ* maps `freshAM (.const_at_ref p)` to `if σ*(p) then neg bot else bot`. With `σ*(p) = decide (M.interp p t)`, truth = `M.interp p t`. Both sides agree. ✓

### ep = .lt_ref

- LHS: `(extIntStruct M t).interp .lt_ref t` = `(t < t)` = False.
- RHS: After all origSubs and constSubs pass through (disjointness ensures no match), the `(lt_atom, .bot)` entry at the end matches. Result = `.bot`. Truth = False. ✓

### ep = .gt_ref

- LHS: `(extIntStruct M t).interp .gt_ref t` = `(t < t)` = False.
- RHS: `(gt_atom, .bot)` at the end. Result = `.bot`. Truth = False. ✓

**Key mechanism for the atom case**: The proof of "no subsequent substitution matches atomMap p after origSubs replaces freshAM(.orig p)" uses `h_disj`: `∀ p ep, atomMap p ≠ freshAM ep`. This is already a hypothesis of `atom_elim_correct`.

---

## 6. The Past/Future Cases in Detail

For `.all_past φ`, `elimExtFromSep` maps it to `.all_past (applySubsts φ constSubs_past)` where `constSubs_past = origSubs ++ constSubs_σ* ++ [(lt, neg bot), (gt, bot)]`.

LHS: `∀ s < t, int_truth M_ext s φ`
RHS: `∀ s < t, int_truth M_orig s (applySubsts φ constSubs_past)`

For each fixed `s < t`, the inner biconditional holds by the same atom-correspondence argument: for each atom `freshAM ep` in `φ` (which is past-only by `hB_sep`):
- `freshAM(.orig p)` in M_ext at time s = `M.interp p s`. After applySubsts: `Formula.atom (atomMap p)` in M_orig at s = `M.interp p s`. ✓
- `freshAM(.const_at_ref p)` in M_ext at s = `M.interp p t` (constant). After applySubsts: σ*(p) truth = `M.interp p t`. ✓
- `freshAM .lt_ref` in M_ext at s (s < t) = `(s < t)` = True. After applySubsts: `neg bot` = True. ✓
- `freshAM .gt_ref` in M_ext at s (s < t) = `(t < s)` = False. After applySubsts: `bot` = False. ✓

This argument is NOT directly an application of `applySubsts_past_correct` — it requires reasoning about how `applySubsts` behaves step by step using `to_int_struct_mem_freshAM`.

The cleanest formulation uses `int_truth_depends_on_atoms` (already proved at line 894): prove that for each atom `a` appearing in `applySubsts φ constSubs_past`, M_ext and a model M_result (built from M_orig by assigning atoms correctly) agree. Then use `int_truth_depends_on_atoms` to transfer.

---

## 7. Alternative B: Use a Bridge Model

**Description**: Construct an intermediate `M_bridge : Separation.IntStructure` defined atom-by-atom:
```
M_bridge.val (freshAM (.orig p)) := {s | M.interp p s}
M_bridge.val (freshAM (.const_at_ref p)) := {s | M.interp p t}  -- constant
M_bridge.val (freshAM .lt_ref) := {s | s < t}
M_bridge.val (freshAM .gt_ref) := {s | t < s}
M_bridge.val (atomMap p) := {s | M.interp p s}
M_bridge.val _ := ∅
```

Then prove two sub-lemmas:
1. `int_truth M_ext t B_sep ↔ int_truth M_bridge t B_sep`  (M_ext and M_bridge agree on `freshAM` atoms)
2. `int_truth M_bridge t (applySubsts φ constSubs_{σ*}) ↔ int_truth M_orig t (applySubsts φ constSubs_{σ*})`  (after subst, only atomMap atoms remain, and M_bridge = M_orig there)

Sub-lemma 1 uses `int_truth_depends_on_atoms`. Sub-lemma 2 also uses `int_truth_depends_on_atoms`.

Then `applySubsts_past_correct` can be applied to M_bridge with the h_match condition holding by definition of M_bridge.

**Feasibility**: FEASIBLE. More structured but adds ~25 LOC for defining and working with M_bridge.

**Confidence**: HIGH (80%). The bridge model approach is more mechanical but also more boilerplate.

---

## 8. Alternative C: Use decide/native_decide

**Description**: Since `sig.preds` is a `Fintype` and the formulas are finite, one might try `decide` to discharge the atom case.

**Analysis**: NOT applicable. The statement of `atom_elim_correct` involves `Prop`-valued predicates (`M.interp p t : Prop`, `int_truth : Prop`), not `Bool`-valued computations. The `Int` domain is infinite. `decide` cannot discharge statements about infinite domains.

**Feasibility**: NOT FEASIBLE.

---

## 9. Alternative D: Use Finset Machinery Directly for the Disjunction

**Description**: Instead of `int_truth_foldl_or` (which doesn't yet exist), use Mathlib's `List.foldl_or` or `Finset.exists_iff` to reason about the disjunction in `quantElimFormula` directly.

**Analysis**: The `quantElimFormula` uses `List.foldl Formula.or` (not Finset.sum). To reason about this, one needs either:
- A `int_truth_foldl_or` analog of the existing `int_truth_foldl_and` (line 822), OR
- Reasoning by induction on the list directly at the call site

The existing `int_truth_foldl_and` is ~20 LOC. A `int_truth_foldl_or` analog would be symmetric and similarly ~20 LOC.

**Feasibility**: FEASIBLE and NECESSARY regardless of which alternative is chosen for the main proof. The disjunction unfolding is needed.

---

## 10. Alternative E: Bypass quantElimFormula and Prove atom_elim_correct Differently

**Description**: Instead of factoring through `quantElimFormula` = "disjunction over guards + elimExtFromSep", prove `atom_elim_correct` by constructing the proof term directly using the σ* witness, without going through the disjunction-unfolding step.

That is: prove `atom_elim_correct` by:
1. Setting σ* directly
2. Showing `int_truth M_orig t (quantElimFormula ...)` ↔ `int_truth M_orig t (guard_σ* ∧ elimExt_{σ*}(B_sep))` — this is `quantElimFormula_correct_iff` (needs `int_truth_foldl_or`)
3. Splitting the conjunction: the guard is true by `guardFormula_correct`, so the conjunction ↔ the elimExt part
4. Proving `int_truth M_ext t B_sep ↔ int_truth M_orig t (elimExt_{σ*} B_sep)` — this is `elimExtFromSep_correct`

This is EXACTLY the original plan. There is no structural bypass here — step 4 is the `elimExtFromSep_correct` difficulty.

**Conclusion**: This alternative is identical to the original plan. No bypass exists.

---

## 11. Alternative F: Atom Containment Sorries (Lines 1139, 1217) — Separate Issue

**Description**: The two sorries at lines 1139 and 1217 say:
```
formula_atoms (quantElimFormula atomMap freshAM B_sep) ⊆ Set.range atomMap
```

This is INDEPENDENT of the `atom_elim_correct` truth transfer sorry. It concerns whether all atoms in the output formula belong to `atomMap`'s range.

**Why this is easier**: After `elimExtFromSep` runs:
- `freshAM(.orig p)` atoms get replaced by `Formula.atom (atomMap p)` — these are in `Set.range atomMap`. ✓
- `freshAM(.const_at_ref p)` atoms get replaced by `neg bot` or `bot` — no atoms. ✓
- `freshAM .lt_ref` gets replaced by `bot` or `neg bot` — no atoms. ✓
- `freshAM .gt_ref` same. ✓
- `guardFormula` contains atoms `atomMap p` — in `Set.range atomMap`. ✓

So the proof is: all freshAM atoms in B_sep get replaced by atomMap atoms or constants, and guardFormula introduces only atomMap atoms.

**Proof approach**: Need a `formula_atoms_applySubsts_subset` lemma:
```lean
theorem formula_atoms_applySubsts_subset (φ : Formula) (subs : List (Atom × Formula))
    (S : Set Atom)
    (h_phi : formula_atoms φ ⊆ {a | ∃ (a', r), (a', r) ∈ subs ∧ a = a'} ∪ S)
    (h_reps : ∀ a r, (a, r) ∈ subs → formula_atoms r ⊆ S) :
    formula_atoms (applySubsts φ subs) ⊆ S
```

Or more directly by induction on `subs`. This lemma would also need a `formula_atoms_subst_formula` characterization:
```lean
formula_atoms (subst_formula φ target r) ⊆ (formula_atoms φ \ {target}) ∪ formula_atoms r
```

Both are provable by structural induction on `Formula` with no difficult cases.

**Feasibility**: HIGH. These two sorries can be closed independently of `atom_elim_correct`.

---

## 12. Recommended Proof Path

### Priority 1: Close the atom containment sorries independently

The two sorries at lines 1139 and 1217 do NOT depend on `atom_elim_correct`. They require:

1. A lemma `formula_atoms_subst_formula`:
   ```lean
   private theorem formula_atoms_subst_formula (φ : Formula) (target : Atom) (r : Formula) :
       Separation.formula_atoms (Separation.subst_formula φ target r) ⊆
       (Separation.formula_atoms φ \ {target}) ∪ Separation.formula_atoms r
   ```
   Proof: structural induction on φ. ~20 LOC.

2. A corollary `formula_atoms_applySubsts_subset`:
   ```lean
   private theorem formula_atoms_applySubsts_subset (φ : Formula)
       (subs : List (Atom × Formula)) (S : Set Atom)
       (h_atoms : ∀ a ∈ Separation.formula_atoms φ, a ∉ Set.range freshAM ∨ ∃ r, (a, r) ∈ subs)
       (h_reps : ∀ a r, (a, r) ∈ subs → Separation.formula_atoms r ⊆ S)
       (h_base : Separation.formula_atoms φ \ {a | ∃ r, (a, r) ∈ subs} ⊆ S) :
       Separation.formula_atoms (applySubsts φ subs) ⊆ S
   ```
   Or equivalently, a simpler version sufficient for the use case:
   ```lean
   -- If every atom in φ is a key in subs, and every value in subs has atoms ⊆ S,
   -- then formula_atoms (applySubsts φ subs) ⊆ S
   ```
   ~30 LOC.

3. Instantiate for `elimExtFromSep`: the substitution list maps all freshAM atoms to either `Formula.atom (atomMap p)` (atoms ⊆ range atomMap) or `bot`/`neg bot` (no atoms). All atoms of B_sep are in `Set.range freshAM` (by `hB_atoms`). Therefore `formula_atoms (elimExtFromSep ...) ⊆ Set.range atomMap`.

4. Guardformula atoms are in `Set.range atomMap` by definition.

5. Combine: `formula_atoms (Formula.and (guardFormula ...) (elimExtFromSep ...)) ⊆ Set.range atomMap`.

6. The foldl-or combining all branches: atoms of the disjunction = union of atoms of each branch, all ⊆ Set.range atomMap.

**Estimated LOC**: 60–80 total. **No dependency on atom_elim_correct**.

### Priority 2: Prove atom_elim_correct by Alternative A (direct structural induction)

The recommended approach is **Alternative A**: inline the proof at the `atom_elim_correct` sorry, structured as follows:

**Step 1**: Add `int_truth_foldl_or` (~20 LOC, symmetric to existing `int_truth_foldl_and`):
```lean
private theorem int_truth_foldl_or (M : Separation.IntStructure) (t : Int)
    (init : Formula) (fs : List Formula) :
    Separation.int_truth M t (fs.foldl Formula.or init) ↔
    Separation.int_truth M t init ∨ ∃ f ∈ fs, Separation.int_truth M t f
```

**Step 2**: Extract a helper `quantElimFormula_correct_iff` (~35 LOC):
```lean
private theorem quantElimFormula_correct_iff {sig : MonadicSignature}
    (atomMap : sig.preds → Atom) (hinj : Function.Injective atomMap)
    (freshAM : (extSignature sig).preds → Atom)
    (B_sep : Formula) (M : IntStructureFromSig sig) (t : Int) :
    Separation.int_truth (to_int_struct M atomMap) t (quantElimFormula atomMap freshAM B_sep) ↔
    ∃ σ : sig.preds → Bool,
      (∀ p, σ p = true ↔ M.interp p t) ∧
      Separation.int_truth (to_int_struct M atomMap) t
        (elimExtFromSep (origSubsList atomMap freshAM ++ constSubsList freshAM σ)
                        (freshAM .lt_ref) (freshAM .gt_ref) B_sep)
```
Proof: unfold quantElimFormula, use `int_truth_foldl_or`, use `guardFormula_correct`, show exactly one branch has a true guard (by `guardFormula_unique` or direct uniqueness argument), extract the unique σ* witness.

**Step 3**: Prove `elimExtFromSep_correct` as a separate theorem (~90 LOC) OR inline it directly into `atom_elim_correct`. Since the induction structure is straightforward (8 cases, all mathematically clear), the **bridge model approach (Alternative B)** for the past/future/snce/untl cases is cleaner because it makes `applySubsts_past_correct` directly applicable, avoiding ad-hoc atom-correspondence reasoning.

**Bridge model definition** (needed for past/future cases):
```lean
private noncomputable def bridgeModel {sig : MonadicSignature}
    (atomMap : sig.preds → Atom) (freshAM : (extSignature sig).preds → Atom)
    (M : IntStructureFromSig sig) (t : Int) (σ : sig.preds → Bool) :
    Separation.IntStructure where
  val a :=
    if ∃ p, freshAM (.orig p) = a then {s | M.interp (Classical.choose ‹_›) s}
    else if ∃ p, freshAM (.const_at_ref p) = a then
      {s | σ (Classical.choose ‹_›) = true}
    else if a = freshAM .lt_ref then {s | s < t}
    else if a = freshAM .gt_ref then {s | t < s}
    else if ∃ p, atomMap p = a then {s | M.interp (Classical.choose ‹_›) s}
    else ∅
```

This formulation is messy due to the `Classical.choose`. A cleaner alternative is to use `to_int_struct (extIntStruct M t) freshAM` directly (which IS M_ext) and leverage the fact that for atoms not in `Set.range freshAM`, `M_ext.val a = ∅`.

Actually, M_ext = `to_int_struct (extIntStruct M t) freshAM` already has the right values at `freshAM ep` atoms by `to_int_struct_mem_freshAM`. The problem is only for `atomMap p` atoms (which are not in freshAM's range by h_disj, so M_ext.val (atomMap p) = ∅). The h_match failure comes precisely because `applySubsts_past_correct` is applied to M_ext, but M_ext doesn't "know" about atomMap atoms.

The minimal fix is to prove `applySubsts_past_correct` can be applied to a modified model, OR to bypass `applySubsts_past_correct` entirely and use `int_truth_depends_on_atoms` instead.

**Recommended concrete approach for elimExtFromSep_correct**:

Use `int_truth_depends_on_atoms` directly (it's already proved). For each case:
- Show that `int_truth M_ext t B_case ↔ int_truth M_ext t (applySubsts B_case subs)` by direct induction using `past_only_subst_correct` / `future_only_subst_correct` individually for each substitution step.
- Show that `int_truth M_ext t (fully_substituted_formula) ↔ int_truth M_orig t (fully_substituted_formula)` using `int_truth_depends_on_atoms`, noting that after all substitutions, only `atomMap p` atoms remain (by `formula_atoms_applySubsts_subset`), and M_ext and M_orig agree on these (`to_int_struct_mem_atomMap` gives same value in both).

This avoids the bridge model entirely and uses only already-proved tools.

---

## 13. Concrete New Lemma Signatures

The following new lemmas should be added (in order):

```lean
-- (1) ~20 LOC — needed for quantElimFormula_correct_iff
private theorem int_truth_foldl_or (M : Separation.IntStructure) (t : Int)
    (init : Formula) (fs : List Formula) :
    Separation.int_truth M t (fs.foldl Formula.or init) ↔
    Separation.int_truth M t init ∨ ∃ f ∈ fs, Separation.int_truth M t f

-- (2) ~20 LOC — needed for atom containment sorries
private theorem formula_atoms_subst_formula (φ : Formula) (target : Atom) (r : Formula) :
    Separation.formula_atoms (Separation.subst_formula φ target r) ⊆
    (Separation.formula_atoms φ \ {target}) ∪ Separation.formula_atoms r

-- (3) ~30 LOC — needed for atom containment sorries
private theorem formula_atoms_applySubsts (φ : Formula) (subs : List (Atom × Formula)) :
    Separation.formula_atoms (applySubsts φ subs) ⊆
    (Separation.formula_atoms φ \ {a | ∃ r, (a, r) ∈ subs}) ∪
    ⋃ (ar : Atom × Formula) (_ : ar ∈ subs), Separation.formula_atoms ar.2

-- (4) ~15 LOC — needed for atom containment sorries  
private theorem formula_atoms_elimExtFromSep_subset {sig : MonadicSignature}
    (atomMap : sig.preds → Atom)
    (freshAM : (extSignature sig).preds → Atom)
    (freshAM_inj : Function.Injective freshAM)
    (h_disj : ∀ p ep, atomMap p ≠ freshAM ep)
    (B_sep : Formula)
    (hB_atoms : Separation.formula_atoms B_sep ⊆ Set.range freshAM)
    (σ : sig.preds → Bool) :
    Separation.formula_atoms
      (elimExtFromSep (origSubsList atomMap freshAM ++ constSubsList freshAM σ)
                      (freshAM .lt_ref) (freshAM .gt_ref) B_sep) ⊆
    Set.range atomMap

-- (5) ~90 LOC — the core missing piece
private theorem elimExtFromSep_correct {sig : MonadicSignature}
    (atomMap : sig.preds → Atom) (hinj : Function.Injective atomMap)
    (freshAM : (extSignature sig).preds → Atom) (freshAM_inj : Function.Injective freshAM)
    (h_disj : ∀ p ep, atomMap p ≠ freshAM ep)
    (M : IntStructureFromSig sig) (t : Int)
    (σ : sig.preds → Bool) (hσ : ∀ p, σ p = true ↔ M.interp p t)
    (B_sep : Formula) (hB_sep : Separation.is_properly_separated B_sep = true)
    (hB_atoms : Separation.formula_atoms B_sep ⊆ Set.range freshAM) :
    Separation.int_truth (to_int_struct (extIntStruct M t) freshAM) t B_sep ↔
    Separation.int_truth (to_int_struct M atomMap) t
      (elimExtFromSep (origSubsList atomMap freshAM ++ constSubsList freshAM σ)
                      (freshAM .lt_ref) (freshAM .gt_ref) B_sep)

-- (6) ~35 LOC — wraps elimExtFromSep_correct for use in atom_elim_correct
private theorem quantElimFormula_correct_iff {sig : MonadicSignature}
    (atomMap : sig.preds → Atom) (hinj : Function.Injective atomMap)
    (freshAM : (extSignature sig).preds → Atom) (freshAM_inj : Function.Injective freshAM)
    (h_disj : ∀ p ep, atomMap p ≠ freshAM ep)
    (M : IntStructureFromSig sig) (t : Int)
    (B_sep : Formula) (hB_sep : Separation.is_properly_separated B_sep = true)
    (hB_atoms : Separation.formula_atoms B_sep ⊆ Set.range freshAM) :
    Separation.int_truth (to_int_struct M atomMap) t (quantElimFormula atomMap freshAM B_sep) ↔
    ∃ σ : sig.preds → Bool, (∀ p, σ p = true ↔ M.interp p t) ∧
      Separation.int_truth (to_int_struct M atomMap) t
        (elimExtFromSep (origSubsList atomMap freshAM ++ constSubsList freshAM σ)
                        (freshAM .lt_ref) (freshAM .gt_ref) B_sep)
```

---

## 14. Can We Bypass elimExtFromSep_correct Entirely?

NO. The question was whether `atom_elim_correct` can be proved without a separate `elimExtFromSep_correct`. The answer is: the THEOREM itself is the same theorem whether stated as a separate lemma or inlined. The proof structure is identical. There is no bypass.

What IS possible is to skip `elimExtFromSep_correct` as a NAMED standalone theorem and inline its proof directly into `atom_elim_correct`. This saves one theorem declaration but not any proof work.

The fundamental mathematical content — that `elimExtFromSep` with the right substitution list transfers truth from M_ext to M_orig — must be proved in some form. There is no shortcut.

---

## 15. Can We Use native_decide for the Atom Case?

The atom case requires showing that `applySubsts (.atom (freshAM ep)) subs` evaluates to the right formula. This IS a computation on concrete data (given concrete `ep` and `subs`), but in the proof context, `ep`, `subs`, `freshAM`, `atomMap` are all universally quantified variables, not concrete values. `native_decide` applies only to closed decidable propositions.

However, for the sub-goal "the first match in `subs` for atom `freshAM(.orig p)` is `(freshAM(.orig p), Formula.atom (atomMap p))`", this can be proved using:
- `List.find_mem` or direct `List.mem_map` reasoning about `origSubsList`
- Injectivity of freshAM to show no earlier entry in the list matches

This is straightforward but requires ~15 LOC per case.

---

## 16. Summary and Confidence

| Alternative | Feasibility | LOC | Confidence | Recommended |
|-------------|-------------|-----|------------|-------------|
| A: Inline elimExtFromSep_correct into atom_elim_correct | High | 150–180 total | 85% | YES (primary) |
| B: Bridge model approach for past/future cases | High | +25 vs. A | 80% | Fallback for past/future |
| C: decide/native_decide | NOT feasible | — | 0% | NO |
| D: Finset machinery for disjunction | Necessary helper | 20 | 90% | YES (int_truth_foldl_or) |
| E: Bypass quantElimFormula entirely | NOT possible | — | 0% | NO |
| F: Atom containment sorries (lines 1139, 1217) | High | 60–80 | 95% | YES (independent, do first) |

**Overall recommended implementation order**:
1. Add `int_truth_foldl_or` (~20 LOC)
2. Add `formula_atoms_subst_formula` and `formula_atoms_applySubsts` (~50 LOC)
3. Close the two atom containment sorries (lines 1139, 1217) using those helpers (~30 LOC at the call sites)
4. Prove `elimExtFromSep_correct` by structural induction, using `int_truth_depends_on_atoms` for the past/future/snce/untl cases to avoid the bridge model (~90 LOC)
5. Prove `quantElimFormula_correct_iff` using `int_truth_foldl_or` + `guardFormula_correct` (~35 LOC)
6. Close `atom_elim_correct` sorry by combining steps 4+5 (~10 LOC)

**Total estimated LOC**: ~235, concentrated in steps 4–5.

**Key insight not previously documented**: The `int_truth_depends_on_atoms` theorem (line 894) is the right tool for the past/future/snce/untl cases in `elimExtFromSep_correct`. It allows transferring truth from M_ext to M_orig directly, after establishing atom-by-atom agreement on the output formula's atoms. This avoids both the bridge model complexity and the `applySubsts_past_correct` h_match failure. The output formula of `applySubsts φ constSubs_past` only contains `atomMap p` atoms (no freshAM atoms), and both M_ext and M_orig agree that `atomMap p ∈ M.val (atomMap p) ↔ M.interp p s` for all `s`.
