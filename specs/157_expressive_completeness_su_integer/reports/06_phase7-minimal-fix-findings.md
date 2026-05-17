# Phase 7 Minimal Fix Research: atom_elim_correct

**Date**: 2026-05-17
**Status**: RESEARCH COMPLETE

---

## Current State

There is exactly 1 sorry remaining in `ExpressiveCompleteness.lean`, at line 916, inside `atom_elim_correct`. The proof state at that sorry is:

```
sig : MonadicSignature
atomMap : sig.preds → Atom
hinj : Function.Injective atomMap
freshAM : (extSignature sig).preds → Atom
freshAM_inj : Function.Injective freshAM
M : IntStructureFromSig sig
t : ℤ
B_sep : Formula
hB_sep : is_properly_separated B_sep = true
⊢ int_truth (to_int_struct (extIntStruct M t) freshAM) t B_sep ↔
    int_truth (to_int_struct M atomMap) t (quantElimFormula atomMap freshAM B_sep)
```

The theorem has exactly the hypotheses listed above and nothing else. No disjointness hypothesis is available at the sorry site.

---

## Exact Blocker

There are **two independent blockers** that must both be resolved:

### Blocker 1: The "B_sep atom origin" problem (PRIMARY)

`B_sep` is an **arbitrary** properly-separated formula. Its atoms need not all lie in the image of `freshAM`. They come from `h_sep (q_exists A_ext)`, which uses classical choice (`Classical.choose`) to produce a properly-separated formula semantically equivalent to `q_exists A_ext`. This choice is existential; it may produce a formula whose atoms are entirely fresh (not in `freshAM`'s range).

The `.atom a` case of the structural induction exposes this exactly. After unfolding `quantElimFormula` and `elimExtFromSep`, the goal becomes:

```
(∃ p, freshAM p = a ∧ (extIntStruct M t).interp p t) ↔
  int_truth { val := fun a ↦ {t | ∃ p, atomMap p = a ∧ M.interp p t} } t
    (match List.map (fun σ ↦ (guardFormula atomMap σ).and
                (applySubsts (.atom a) (origSubsList atomMap freshAM ++
                  constSubsList freshAM σ ++
                  [(freshAM .lt_ref, .bot), (freshAM .gt_ref, .bot)]))) ...)
```

The LHS requires `a = freshAM ep` for some `ep`. If `a` is not in `freshAM`'s image, the LHS is always `False`, while the RHS may or may not be `False`. The proof strategy of doing structural induction on `B_sep` does not immediately work because one cannot case-split on whether each atom is in `freshAM`'s image unless this is guaranteed syntactically.

**Resolution**: `atom_elim_correct` must assume (or prove) that `B_sep` only mentions atoms from `freshAM`'s image. There are two paths:

- **Path A (add hypothesis)**: Add `hB_atoms : ∀ a ∈ B_sep.atoms, ∃ ep, freshAM ep = a` as a parameter to `atom_elim_correct`. This must then be threaded through the call site (line 1026 and line 1073). At the call site, `B_sep` is the `Classical.choose` of `h_sep (q_exists A_ext)`, so proving this hypothesis requires knowing that the separation procedure can be made to output a formula with atoms only from a given set — which is NOT generally true for an arbitrary `h_sep`.

- **Path B (replace h_sep with a stronger version)**: Use a separation that respects the atom set of its input. If `h_sep` guarantees that the output formula `B_sep` has atoms contained in those of its input, then `q_exists A_ext` has atoms only from `freshAM`'s image, and `B_sep` inherits this. This requires amending the `h_sep` hypothesis type used throughout `expressiveness_inner`.

- **Path C (semantic approach)**: Do NOT do structural induction on `B_sep`. Instead use the semantic equivalence `hB_equiv : int_equiv (q_exists A_ext) B_sep` to reduce everything to a statement about `q_exists A_ext`, whose atoms are all in `freshAM`'s range by construction (since `A_ext = ihExt.val` and `ihExt` uses `freshAM` as its `atomMap`). This avoids needing to know anything about `B_sep`'s atoms syntactically.

Path C is the correct approach and is described in the proof sketch in the comments (lines 883-908). The proof sketch says "by structural induction on B_sep" — but this is misleading. The actual proof should proceed through `q_exists A_ext` using `hB_equiv`.

### Blocker 2: The disjointness problem (SECONDARY, conditional)

If the proof proceeds by structural induction on `B_sep` (which it should NOT, per analysis above), then `applySubsts` applies `origSubsList ++ constSubsList ++ [(lt_atom, .bot), (gt_atom, .bot)]` sequentially. The `origSubsList` maps `freshAM (.orig p) → .atom (atomMap p)`. After this substitution, the resulting formula contains atoms `atomMap p`. If subsequently `atomMap p = freshAM (.const_at_ref q)` for some `q`, the `constSubsList` would incorrectly further substitute it.

This disjointness issue arises only if the atom-origin problem is not first resolved. If the proof uses **Path C** (semantic, through `q_exists A_ext`), the disjointness problem does not arise because `q_exists A_ext` already has a specific atom structure where `applySubsts` is applied to an atom `freshAM ep` (not `atomMap p`), and the sequential substitution order is designed correctly.

The disjointness problem is real at the implementation level of `expressiveness_inner`: both `freshAM` and the outer `atomMap` at a recursive level use `mk_fresh "e"` with indices from `Fintype.equivFin`. At depth 2+, the `atomMap` for one level is the `freshAM` of the previous level, so their index ranges can coincide. This means `origSubsList atomMap freshAM` contains entries `(freshAM (.orig p), .atom (atomMap p))` where `atomMap p = mk_fresh "e" i` and `freshAM (.const_at_ref q) = mk_fresh "e" j` might coincide — BUT only if `i = j`, which is excluded by `freshAM_inj` since `.orig p ≠ .const_at_ref q`. So in fact the disjointness holds as a consequence of `freshAM_inj` alone: `freshAM (.orig p) ≠ freshAM (.const_at_ref q)` because freshAM is injective and `.orig p ≠ .const_at_ref q`. The secondary disjointness concern from the handoff is already resolved by `freshAM_inj` + `atomMap_inj`.

---

## Recommended Proof Strategy (Path C)

The correct proof of `atom_elim_correct` does NOT do structural induction on `B_sep`. Instead it proceeds semantically:

**Step 1.** Note that `B_sep` and `q_exists A_ext` are semantically equivalent (via `hB_equiv`), but `atom_elim_correct` is called with only `B_sep` and `hB_sep` — it has no access to `A_ext` or `hB_equiv`. This is the fundamental design issue.

**Step 2.** The theorem as currently stated (with only `B_sep` and `hB_sep`) is **not provable** in general, because `B_sep` can be any properly-separated formula and the `quantElimFormula atomMap freshAM B_sep` cannot relate to `int_truth (to_int_struct (extIntStruct M t) freshAM) t B_sep` without knowing which atoms of `B_sep` come from `freshAM`.

**Consequence**: `atom_elim_correct` needs to be restated or the call site needs to be restructured.

---

## Minimal Set of New Lemmas Needed

### Option 1: Add an atoms-in-image hypothesis to atom_elim_correct

Restate `atom_elim_correct` with an explicit hypothesis:

```lean
private theorem atom_elim_correct {sig : MonadicSignature}
    (atomMap : sig.preds → Atom) (hinj : Function.Injective atomMap)
    (freshAM : (extSignature sig).preds → Atom) (freshAM_inj : Function.Injective freshAM)
    (M : IntStructureFromSig sig) (t : Int)
    (B_sep : Formula) (hB_sep : Separation.is_properly_separated B_sep = true)
    (hB_atoms : ∀ a ∈ B_sep.atoms, ∃ ep : ExtPred sig, freshAM ep = a) :
    Separation.int_truth (to_int_struct (extIntStruct M t) freshAM) t B_sep ↔
    Separation.int_truth (to_int_struct M atomMap) t
      (quantElimFormula atomMap freshAM B_sep) := by
  induction B_sep with
  | atom a => ...  -- use hB_atoms to case split on ep
  | bot => simp [quantElimFormula, int_truth]
  | imp φ ψ ihφ ihψ => ...
  | box _ => simp [quantElimFormula, elimExtFromSep, int_truth]
  | all_past φ => ...  -- use applySubsts_past_correct
  | all_future φ => ... -- use applySubsts_future_correct
  | snce φ ψ => ...
  | untl φ ψ => ...
```

Then at the call site, one needs to prove `hB_atoms`. This requires proving:

```lean
-- Needed lemma: if phi has atoms from a set S, then so does the separated version
lemma separation_preserves_atom_set (S : Finset Atom) (phi : Formula)
    (h : ∀ a ∈ phi.atoms, a ∈ S) (hB : Separation.is_properly_separated B = true)
    (hequiv : Separation.int_equiv phi B) :
    ∀ a ∈ B.atoms, a ∈ S := ...
```

This lemma is **not generally true** without additional hypotheses on how separation works.

### Option 2: Inline the atom_elim step at the call site (recommended)

Remove `atom_elim_correct` as a standalone theorem and inline the proof in `expressiveness_inner` at the `.ex` and `.all` cases. At those call sites, `A_ext` and `hB_equiv` are available. The proof would:

1. Use `hB_equiv` to replace `int_truth M_ext t B_sep` with `int_truth M_ext t (q_exists A_ext)`
2. Prove `int_truth M_ext t (q_exists A_ext) ↔ int_truth (to_int_struct M atomMap) t A` directly, where `A_ext` has known atom structure (all atoms are `freshAM ep` for various `ep`)

This avoids `atom_elim_correct` entirely and collapses the proof into the `.ex`/`.all` cases.

The key lemma needed for this inline approach is:

```lean
private theorem qelim_correct_for_A_ext {sig : MonadicSignature}
    (atomMap : sig.preds → Atom) (hinj : Function.Injective atomMap)
    (freshAM : (extSignature sig).preds → Atom) (freshAM_inj : Function.Injective freshAM)
    (M : IntStructureFromSig sig) (t : Int)
    (A_ext : Formula)
    (hA_atoms : ∀ a ∈ A_ext.atoms, ∃ ep : ExtPred sig, freshAM ep = a) :
    Separation.int_truth (to_int_struct (extIntStruct M t) freshAM) t (q_exists A_ext) ↔
    Separation.int_truth (to_int_struct M atomMap) t
      (quantElimFormula atomMap freshAM (Classical.choose (h_sep (q_exists A_ext)))) := by
  ...
```

But this still requires knowing atoms of `A_ext` lie in `freshAM`'s image.

### Option 3: Add a "atom image" hypothesis to h_sep (cleanest solution)

Change the `h_sep` hypothesis in `expressiveness_inner` from:

```lean
h_sep : ∀ phi : Formula, Separation.is_properly_separable phi
```

to:

```lean
h_sep : ∀ phi : Formula, ∃ B : Formula,
    Separation.is_properly_separated B = true ∧
    Separation.int_equiv phi B ∧
    ∀ a ∈ B.atoms, a ∈ phi.atoms
```

This says the separation can always be done within the original formula's atom set. This is **mathematically true** for the constructive separation in `SeparationThm.lean` (since separation introduces no new atoms — it rearranges temporal structure), but requires proving this additional property in `SeparationThm.lean`.

Then `atom_elim_correct` can be proved because `B_sep.atoms ⊆ (q_exists A_ext).atoms ⊆ freshAM's image`.

### Required lemma for Option 3 (in SeparationThm.lean)

```lean
theorem proper_separation_preserves_atoms (phi : Formula) :
    let B := Classical.choose (proper_separation_theorem_int phi)
    ∀ a ∈ B.atoms, a ∈ phi.atoms
```

Estimated: 80-150 LOC (depends on the complexity of the separation proof's structural induction; the separation proof itself is already proved, so this is an annotation pass over it).

---

## What the Current Partial Proof Is Doing

The current code at line 916 contains only `sorry`. There is NO partial proof attempt. The proof sketch in the comments (lines 883-908) describes the intended strategy in outline, but no Lean proof terms have been written for this theorem. The supporting infrastructure (`guardFormula_correct`, `applySubsts_past_correct`, `applySubsts_future_correct`, `to_int_struct_mem_freshAM`, `to_int_struct_mem_atomMap`, `int_truth_foldl_and`) is all in place.

---

## Simpler Reformulation

The simplest reformulation that avoids the atom-origin problem is to **eliminate B_sep from the interface entirely** and work with `A_ext` directly. The call sites in `expressiveness_inner` should NOT call a standalone `atom_elim_correct` but instead prove the combined step inline:

```lean
-- At the .ex case, after constructing A_ext and B_sep:
-- Combined step: int_truth M_ext t B_sep ↔ int_truth (to_int_struct M atomMap) t A
-- Proof: B_sep ↔ q_exists A_ext  (by hB_equiv)
--        q_exists A_ext in M_ext ↔ ∃z, A_ext in M_ext at z  (by q_exists_correct)
--        THIS STEP is equivalent to: (∃z, int_truth M_ext z A_ext) ↔ int_truth M_orig t A
-- The final step still requires knowing A_ext's atoms lie in freshAM's image.
```

Even with inlining, the atom-origin problem persists because we need to relate `A_ext`'s atoms to `freshAM`'s image. The ultimate fix is **Option 3**: strengthen `h_sep` to preserve atom sets, then the proof at the `atom` case works: if `a ∈ B_sep.atoms ⊆ (q_exists A_ext).atoms`, then `a = freshAM ep` for some `ep` (since `A_ext`'s atoms are all `freshAM ep` by its construction from `to_int_struct`).

---

## Minimal Fix Summary

**Recommended approach**: Option 3 (strengthen h_sep) + structural induction on B_sep.

**New lemmas required** (in order of dependency):

1. **`atoms_in_freshAM_image`** (in `ExpressiveCompleteness.lean`): Prove that when `A_ext` is the formula produced by the induction hypothesis using `freshAM` as `atomMap`, all atoms of `q_exists A_ext` lie in `freshAM`'s image.
   - Type: `∀ a ∈ (q_exists A_ext).atoms, ∃ ep, freshAM ep = a`
   - This follows from the definition of `to_int_struct` and the IH construction.
   - Estimated: 20-40 LOC (structural induction on A_ext's construction, using that atoms of `to_int_struct M freshAM` only mention `freshAM`-range atoms).

2. **`proper_separation_atoms_subset`** (in `SeparationThm.lean`): The separation of `phi` only uses atoms appearing in `phi`.
   - Type: `∀ (phi : Formula), ∀ a ∈ (Classical.choose (proper_separation_theorem_int phi)).atoms, a ∈ phi.atoms`
   - Estimated: 50-120 LOC depending on how the separation proof is structured.

3. **`atom_elim_correct`** with `hB_atoms` hypothesis (the currently sorry'd theorem, with one added parameter):
   - Structural induction on `B_sep` using `hB_atoms` for the `.atom a` case
   - Past/future cases use `applySubsts_past_correct` / `applySubsts_future_correct`
   - The guard uniqueness (exactly one σ* matching M at t) must be proved for the disjunction unfolding
   - Estimated: 80-150 LOC

4. **`int_truth_foldl_or`** helper (parallel to existing `int_truth_foldl_and`):
   - Type: `int_truth M t (fs.foldl Formula.or b) ↔ int_truth M t b ∨ ∃ f ∈ fs, int_truth M t f`
   - Needed to unfold `quantElimFormula`'s disjunction
   - Estimated: 15-25 LOC

5. **`guardFormula_unique`**: exactly one assignment σ satisfies `guardFormula atomMap σ` in `to_int_struct M atomMap` at t (when `atomMap` is injective).
   - Type: `∀ σ τ, int_truth (to_int_struct M atomMap) t (guardFormula atomMap σ) → int_truth (to_int_struct M atomMap) t (guardFormula atomMap τ) → σ = τ`
   - Estimated: 20-30 LOC (uses `guardFormula_correct` twice + function extensionality)

**Total estimated LOC**: 185-365 LOC (wide range due to uncertainty in `proper_separation_atoms_subset`)

---

## Confidence Assessment

- **Confidence that the approach is correct**: HIGH. The mathematical argument is sound; the proof is a standard substitution-correctness argument.
- **Confidence in LOC estimate for lemmas 1, 4, 5**: HIGH (these are routine Lean bookkeeping).
- **Confidence in LOC estimate for lemma 2 (`proper_separation_atoms_subset`)**: MEDIUM. It depends on how `SeparationThm.lean` is structured; if the separation proof is highly opaque (e.g., uses Classical.choice without explicit construction), a separate proof may be needed.
- **Confidence in lemma 3 (`atom_elim_correct`)**: HIGH for structure, MEDIUM for total LOC (temporal cases with `applySubsts` may require careful matching).

The single greatest risk is lemma 2. If `SeparationThm.lean` uses a non-constructive existence proof for separation, extracting the atom-preservation property may require restructuring or adding a parallel constructive witness. In that case, Option 2 (inline, avoiding B_sep) may be more tractable by using `hB_equiv` at the call site and working with `q_exists A_ext` directly, whose atom structure is known by construction.
