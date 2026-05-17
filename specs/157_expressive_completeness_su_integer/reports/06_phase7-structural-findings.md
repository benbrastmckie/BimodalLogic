# Phase 7 Research: elimExtFromSep_correct Structural Induction

**Date**: 2026-05-17
**Researcher**: lean-research-agent
**Task**: 157 Phase 7 — atom_elim_correct / elimExtFromSep_correct

---

## 1. Function Definitions

### `elimExtFromSep`

Defined at lines 623–646 of `ExpressiveCompleteness.lean`.

```lean
private noncomputable def elimExtFromSep
    (constSubs : List (Atom × Formula))
    (lt_atom gt_atom : Atom) : Formula → Formula
  | .atom a =>
    applySubsts (.atom a) (constSubs ++ [(lt_atom, .bot), (gt_atom, .bot)])
  | .bot => .bot
  | .imp φ ψ => .imp (elimExtFromSep constSubs lt_atom gt_atom φ)
                      (elimExtFromSep constSubs lt_atom gt_atom ψ)
  | .box φ => .box φ
  | .all_past φ =>
    .all_past (applySubsts φ (constSubs ++ [(lt_atom, Formula.neg .bot), (gt_atom, .bot)]))
  | .all_future φ =>
    .all_future (applySubsts φ (constSubs ++ [(lt_atom, .bot), (gt_atom, Formula.neg .bot)]))
  | .snce φ ψ =>
    .snce (applySubsts φ (constSubs ++ [(lt_atom, Formula.neg .bot), (gt_atom, .bot)]))
          (applySubsts ψ (constSubs ++ [(lt_atom, Formula.neg .bot), (gt_atom, .bot)]))
  | .untl φ ψ =>
    .untl (applySubsts φ (constSubs ++ [(lt_atom, .bot), (gt_atom, Formula.neg .bot)]))
          (applySubsts ψ (constSubs ++ [(lt_atom, .bot), (gt_atom, Formula.neg .bot)]))
```

Key structural observation: `elimExtFromSep` is NOT recursive on its last argument (the Formula). Each constructor case either:
- Applies `applySubsts` to the immediate subformula(s) flat (atom, all_past, all_future, snce, untl), or
- Recursively calls `elimExtFromSep` on sub-formulas (imp only), or
- Passes through unchanged (box).

This makes structural induction on the `Formula` argument align perfectly: the `imp` case uses the IH on both conjuncts; the `all_past / all_future / snce / untl` cases do NOT recurse into `elimExtFromSep` — instead they apply `applySubsts` directly to the raw subformulas.

### `quantElimFormula`

Defined at lines 672–685. It wraps `elimExtFromSep` inside a disjunction over all assignments σ:

```lean
private noncomputable def quantElimFormula
    (atomMap : sig.preds → Atom) (extAM : (extSignature sig).preds → Atom)
    (B_sep : Formula) : Formula :=
  let lt_atom := extAM .lt_ref
  let gt_atom := extAM .gt_ref
  let origSubs := origSubsList atomMap extAM
  let assignments := (Finset.univ : Finset (sig.preds → Bool)).toList
  let branches := assignments.map fun σ =>
    Formula.and (guardFormula atomMap σ)
                (elimExtFromSep (origSubs ++ constSubsList extAM σ) lt_atom gt_atom B_sep)
  match branches with
  | [] => .bot
  | [b] => b
  | b :: bs => bs.foldl Formula.or b
```

So `quantElimFormula atomMap freshAM B_sep` = `∨_σ (guard_σ ∧ elimExtFromSep(origSubs ++ constSubs_σ, lt, gt) B_sep)`.

The `constSubs` passed to `elimExtFromSep` include both `origSubsList` (mapping `freshAM (.orig p) ↦ Formula.atom (atomMap p)`) and `constSubsList` (mapping `freshAM (.const_at_ref p) ↦ ⊤` or `⊥` depending on σ(p)).

### `applySubsts`

Defined at lines 614–616:

```lean
private noncomputable def applySubsts (φ : Formula) : List (Atom × Formula) → Formula
  | [] => φ
  | (a, r) :: rest => applySubsts (Separation.subst_formula φ a r) rest
```

Sequential left-to-right substitution. Already proved correct via `applySubsts_past_correct` and `applySubsts_future_correct` (Tasks 7.5b, lines 742–783).

---

## 2. Induction Structure

### Is structural induction on Formula correct here?

Yes. The key insight is that `elimExtFromSep` pattern-matches on the Formula argument and:

- Does NOT recurse for `atom`, `bot`, `all_past`, `all_future`, `snce`, `untl` — these are leaf cases from the induction's perspective.
- DOES recurse for `imp` — this is the single inductive case.
- `box` is a leaf that passes through unchanged.

Therefore structural induction on `B_sep : Formula` is perfectly aligned with `elimExtFromSep`'s definition. No well-founded induction on formula size is needed.

The proof of `elimExtFromSep_correct` should be stated as:

```lean
private theorem elimExtFromSep_correct {sig : MonadicSignature}
    (atomMap : sig.preds → Atom) (hinj : Function.Injective atomMap)
    (freshAM : (extSignature sig).preds → Atom) (freshAM_inj : Function.Injective freshAM)
    (h_disj : ∀ p ep, atomMap p ≠ freshAM ep)  -- disjointness hypothesis
    (M : IntStructureFromSig sig) (t : Int)
    (σ : sig.preds → Bool)  -- the fixed assignment
    (B_sep : Formula) (hB_sep : Separation.is_properly_separated B_sep = true) :
    Separation.int_truth (to_int_struct (extIntStruct M t) freshAM) t B_sep ↔
    Separation.int_truth (to_int_struct M atomMap) t
      (elimExtFromSep (origSubsList atomMap freshAM ++ constSubsList freshAM σ)
                      (freshAM .lt_ref) (freshAM .gt_ref) B_sep)
```

where σ is chosen to match M at t: `σ p = decide (M.interp p t)`.

---

## 3. Constructor Cases — Proof Sketch per Case

### Abbreviations used below

- `M_ext := to_int_struct (extIntStruct M t) freshAM`
- `M_orig := to_int_struct M atomMap`
- `constSubs_σ := origSubsList atomMap freshAM ++ constSubsList freshAM σ`
- `lt := freshAM .lt_ref`, `gt := freshAM .gt_ref`
- `σ*(p) := decide (M.interp p t)` — the canonical assignment matching M at t

### Case `.atom a`

LHS: `int_truth M_ext t (.atom a)` = `t ∈ M_ext.val a`

RHS: `int_truth M_orig t (elimExtFromSep constSubs_σ lt gt (.atom a))`
   = `int_truth M_orig t (applySubsts (.atom a) (constSubs_σ ++ [(lt, bot), (gt, bot)]))`

The atom `a` is of the form `freshAM ep` for some `ep : ExtPred sig` (because M_ext only has atoms from freshAM's range, and by injectivity those are distinct).

Case split on `ep`:
- `ep = .orig p`: `a = freshAM (.orig p)`. LHS gives `M.interp p t` (by `to_int_struct_mem_freshAM` + `extIntStruct` def: `interp (.orig p) z = M.interp p z` at `z = t`). After `applySubsts`, the pair `(freshAM (.orig p), Formula.atom (atomMap p))` is in `origSubsList`, so `a` gets replaced by `Formula.atom (atomMap p)`. RHS = `int_truth M_orig t (Formula.atom (atomMap p))` = `t ∈ M_orig.val (atomMap p)` = `M.interp p t` (by `to_int_struct_mem_atomMap`). Both sides equal `M.interp p t`. ✓

- `ep = .const_at_ref p`: `a = freshAM (.const_at_ref p)`. LHS gives `M.interp p t` (= `(extIntStruct M t).interp (.const_at_ref p) z = M.interp p t` regardless of z, evaluated at z=t). After `applySubsts`, `a = freshAM (.const_at_ref p)` gets replaced by `if σ*(p) then neg bot else bot`. With `σ* = decide(M.interp p t)`, this is `⊤` if `M.interp p t`, else `⊥`. Both sides equal `M.interp p t`. ✓ (requires disjointness: `atomMap p ≠ freshAM ep'` to ensure origSubsList substitution does not further modify the result).

- `ep = .lt_ref`: `a = freshAM .lt_ref = lt`. LHS = `t ∈ M_ext.val lt` = `(extIntStruct M t).interp .lt_ref t = (t < t) = False`. The subst list ends with `(lt, bot)`, so `a = lt` gets replaced by `⊥`. RHS = `int_truth M_orig t bot = False`. Both False. ✓

- `ep = .gt_ref`: Symmetric to lt_ref. Both False. ✓

**Key requirement**: disjointness between `atomMap`'s range and `freshAM`'s range, so that after the `origSubsList` substitution replaces `freshAM (.orig p)` with `Formula.atom (atomMap p)`, subsequent substitutions in `constSubsList` (which target `freshAM (.const_at_ref p')`) do not further modify `Formula.atom (atomMap p)`. This is the core blocker identified in the handoff.

### Case `.bot`

Both sides are `False`. `elimExtFromSep ... .bot = .bot`. Trivial. ✓

### Case `.imp φ ψ` (hB_sep decomposes to `hφ` and `hψ`)

LHS = `int_truth M_ext t (φ → ψ)` = `int_truth M_ext t φ → int_truth M_ext t ψ`

RHS = `int_truth M_orig t (elimExtFromSep ... φ → elimExtFromSep ... ψ)`
    = `int_truth M_orig t (elimExtFromSep ... φ) → int_truth M_orig t (elimExtFromSep ... ψ)`

Use IH on φ (hφ from is_properly_separated) and IH on ψ (hψ). Then use `Iff.imp` or direct reasoning:

```lean
exact ⟨fun h hψ => (ih_ψ ...).mp (h ((ih_φ ...).mpr hψ)),
       fun h hφ => (ih_ψ ...).mpr (h ((ih_φ ...).mp hφ))⟩
```

Note: `is_properly_separated (.imp φ ψ) = is_properly_separated φ && is_properly_separated ψ`, so `hB_sep` decomposes via `Bool.and_eq_true`. ✓

### Case `.box φ`

`elimExtFromSep ... (.box φ) = .box φ` (passes through unchanged).

`is_properly_separated (.box _) = true` always.

Both sides: `int_truth M_ext t (.box φ) = True` and `int_truth M_orig t (.box φ) = True`. Trivially `Iff.rfl`. ✓

Note: the inner φ is NOT substituted. This is correct because `box` is treated as a modal modality that is semantically degenerate (always True) in the integer temporal semantics. The φ inside box does not affect int_truth.

### Case `.all_past φ` (hB_sep gives `is_past_only φ = true`)

`elimExtFromSep ... (.all_past φ) = .all_past (applySubsts φ (constSubs_σ ++ [(lt, neg bot), (gt, bot)]))`

LHS: `int_truth M_ext t (.all_past φ)` = `∀ s < t, int_truth M_ext s φ`

RHS: `int_truth M_orig t (.all_past (applySubsts φ ...))` = `∀ s < t, int_truth M_orig s (applySubsts φ ...)`

For each fixed `s < t`, we need: `int_truth M_ext s φ ↔ int_truth M_orig s (applySubsts φ (constSubs_σ ++ [(lt, neg bot), (gt, bot)]))`

Apply `applySubsts_past_correct` with the full substitution list `constSubs_σ ++ [(lt, neg bot), (gt, bot)]` and the model M_orig evaluated at s (with s ≤ t since s < t):

- **h_reps_po**: Every replacement formula in the list must be past-only.
  - `origSubsList` entries: `Formula.atom (atomMap p)` — is_past_only = true ✓
  - `constSubsList` entries: `neg bot` or `bot` — is_past_only = true ✓
  - `(lt, neg bot)`: is_past_only (neg bot) = true ✓
  - `(gt, bot)`: is_past_only bot = true ✓

- **h_match**: For each `(a, r)` in the list and each `u ≤ s`:
  - `(freshAM (.orig p), Formula.atom (atomMap p))`: need `int_truth M_orig u (Formula.atom (atomMap p)) ↔ u ∈ M_orig.val (freshAM (.orig p))`.
    But wait — the model here is M_orig = `to_int_struct M atomMap`, not M_ext. We need to check: `u ∈ M_orig.val (freshAM (.orig p))`. But `M_orig.val a = {z | ∃ p, atomMap p = a ∧ M.interp p z}`. So `u ∈ M_orig.val (freshAM (.orig p))` requires `atomMap q = freshAM (.orig p)` for some q. This requires `atomMap q = freshAM (.orig q)` for the unique q by injectivity. **This is exactly where disjointness matters**: if `atomMap q = freshAM (.orig q)` is not guaranteed, the h_match condition cannot be discharged.

  Actually, re-examining: `applySubsts_past_correct` takes model `M : Separation.IntStructure` and the match condition is:
  ```
  h_match : ∀ (a : Atom) (r : Formula), (a, r) ∈ subs →
    ∀ s : Int, s ≤ t → (Separation.int_truth M s r ↔ s ∈ M.val a)
  ```
  The model `M` here is `M_ext` (NOT M_orig). We're evaluating `applySubsts φ subs` in `M_ext`, and we want it to equal `int_truth M_ext s φ`.

  So the correct application of `applySubsts_past_correct` is with `M = M_ext`:
  - `(freshAM (.orig p), Formula.atom (atomMap p))`: need `int_truth M_ext u (Formula.atom (atomMap p)) ↔ u ∈ M_ext.val (freshAM (.orig p))`.
    - LHS = `u ∈ M_ext.val (atomMap p)` = `∃ ep, freshAM ep = atomMap p ∧ (extIntStruct M t).interp ep u`.
    - This requires `atomMap p` to be in freshAM's range, i.e., `freshAM ep = atomMap p` for some ep.
    - **If disjointness holds** (atomMap range ∩ freshAM range = ∅), then `u ∈ M_ext.val (atomMap p) = False`, while `u ∈ M_ext.val (freshAM (.orig p)) = (extIntStruct M t).interp (.orig p) u = M.interp p u`.

  This reveals the fundamental mismatch. The `applySubsts_past_correct` approach works when the model is M_orig, not M_ext.

**Revised approach for all_past case**:

The correct proof strategy for the `.all_past` case is a two-stage argument:

Stage 1: Use `past_only_is_pure_past` to replace M_ext with a model that agrees with M_orig on all relevant atoms at times s < t. Specifically, show that for s < t:
- `int_truth M_ext s φ ↔ int_truth M_orig s φ_subst`

where `φ_subst` is obtained by substituting each extended atom appropriately.

Stage 2: The substitution list in `applySubsts` correctly encodes what M_ext would say about each atom at past times. Concretely, for s < t:
- `freshAM (.orig p)` in M_ext at time s = `M.interp p s` — this should map to `Formula.atom (atomMap p)` in M_orig, where `int_truth M_orig s (Formula.atom (atomMap p)) = M.interp p s`. ✓
- `freshAM (.const_at_ref p)` in M_ext at time s = `M.interp p t` (constant) — maps to `⊤` or `⊥` based on σ*(p) = decide(M.interp p t). ✓
- `freshAM .lt_ref` in M_ext at time s (s < t) = `(s < t) = True` — maps to `neg bot = ⊤`. ✓
- `freshAM .gt_ref` in M_ext at time s (s < t) = `(t < s) = False` (since s < t) — maps to `bot = ⊥`. ✓

The proof therefore proceeds by showing `int_truth M_ext s (applySubsts φ subs_past) ↔ int_truth M_orig s (applySubsts φ subs_past)` using the fact that for s < t, both models agree at atoms in the substituted formula.

**Cleanest formulation**: Use `applySubsts_past_correct` with model `M_ext` and show the h_match conditions hold for s < t by case-splitting on ep using `to_int_struct_mem_freshAM`. Then observe the resulting `int_truth M_ext s φ` (after substitution undoes all extended atoms) equals `int_truth M_orig s φ` by the fact that φ is past-only and the orig-atom values agree in M_ext and M_orig at past times.

Wait — there's still a gap: after applying all substitutions in `applySubsts φ subs_past`, the resulting formula contains only `Formula.atom (atomMap p)` terms (no freshAM atoms). Now `int_truth M_ext s (φ') = int_truth M_orig s (φ')` where φ' has only `atomMap p` atoms, because both M_ext and M_orig agree that `atomMap p` is in their valuation iff `M.interp p s`. (This follows from `to_int_struct_mem_freshAM` for M_ext and `to_int_struct_mem_atomMap` for M_orig — both give `M.interp p s`.)

**Summary for all_past**: 3-step proof:
1. `applySubsts_past_correct` (with M_ext) converts `int_truth M_ext s (applySubsts φ subs_past) ↔ int_truth M_ext s φ` — so we need it in reverse: first get IH.
2. Direct atom-by-atom correspondence via `to_int_struct_mem_freshAM` establishes h_match.
3. After substitution, the resulting formula has only atomMap atoms, for which M_ext and M_orig agree via `to_int_struct_mem_atomMap`.

Actually the cleanest approach: prove the biconditional directly by showing both sides reduce to the same function of M.interp p at past times. The `past_only_is_pure_past` lemma lets us replace M_ext with a model that has exactly M.interp's behavior.

### Case `.all_future φ` (hB_sep gives `is_future_only φ = true`)

Symmetric to `.all_past`. Use `applySubsts_future_correct`. At future times s > t:
- `freshAM .lt_ref` at s: `(s < t) = False` → substitution maps to `bot = ⊥`. ✓
- `freshAM .gt_ref` at s: `(t < s) = True` → substitution maps to `neg bot = ⊤`. ✓
- `freshAM (.orig p)` at s = `M.interp p s` → maps to `Formula.atom (atomMap p)`. ✓
- `freshAM (.const_at_ref p)` at s = `M.interp p t` → maps to σ*(p) value. ✓

Same 3-step proof structure. ✓

### Case `.snce φ ψ` (hB_sep gives `is_past_only φ = true` and `is_past_only ψ = true`)

`elimExtFromSep ... (.snce φ ψ) = .snce (applySubsts φ subs_past) (applySubsts ψ subs_past)`

LHS: `∃ s < t, int_truth M_ext s φ ∧ ∀ r, s < r → r < t → int_truth M_ext r ψ`

RHS: `∃ s < t, int_truth M_orig s (applySubsts φ subs_past) ∧ ∀ r, s < r → r < t → int_truth M_orig r (applySubsts ψ subs_past)`

For the witness s: `s < t`, so lt_ref is True and gt_ref is False at all past times ≤ s.

Use the same atom-correspondence argument as the `.all_past` case:
- For each past time u ≤ s < t: `int_truth M_ext u φ ↔ int_truth M_orig u (applySubsts φ subs_past)` (same argument as all_past)
- For each r with s < r < t: same correspondence for ψ.

The key is that the substitution list `subs_past` with `(lt → neg bot, gt → bot)` works correctly for ALL past times (not just times less than t), which holds because s < t implies all relevant evaluation times are < t. ✓

### Case `.untl φ ψ` (hB_sep gives `is_future_only φ = true` and `is_future_only ψ = true`)

Symmetric to `.snce`, using `subs_future` with `(lt → bot, gt → neg bot)`. ✓

---

## 4. Relationship Between `elimExtFromSep` and `quantElimFormula`

They are NOT the same function. Their relationship:

```
quantElimFormula atomMap freshAM B_sep
  = ∨_{σ} (guard(atomMap, σ) ∧ elimExtFromSep(origSubs ++ constSubs_σ, lt, gt, B_sep))
```

The `atom_elim_correct` proof has two components:

**Component 1** (`elimExtFromSep_correct`): For the unique matching σ* (defined by σ*(p) = decide(M.interp p t)):

```
int_truth M_ext t B_sep ↔
  int_truth M_orig t (elimExtFromSep (origSubs ++ constSubs_{σ*}) lt gt B_sep)
```

**Component 2** (`quantElimFormula_correct_iff`): The disjunction over all σ is equivalent to just the σ* branch:

```
int_truth M_orig t (quantElimFormula atomMap freshAM B_sep) ↔
  int_truth M_orig t (guardFormula atomMap σ* ∧ elimExtFromSep ... B_sep)
```

because:
- The guard `guardFormula atomMap σ*` is true in M_orig at t (by `guardFormula_correct` with σ* = decide ∘ M.interp p t).
- For all σ ≠ σ*, the guard `guardFormula atomMap σ` is false in M_orig at t.

Combining: `atom_elim_correct` = `elimExtFromSep_correct` + `quantElimFormula_correct_iff` + `guardFormula_correct`.

---

## 5. Side Conditions for `applySubsts_past/future_correct`

### `h_reps_po` (for past correct)

Every replacement formula `r` in `constSubs_σ ++ [(lt, neg bot), (gt, bot)]` must satisfy `is_past_only r = true`:
- `Formula.atom (atomMap p)` — is_past_only = true ✓
- `neg bot` — `is_past_only (neg bot) = is_past_only (.imp bot bot) = true && true = true` ✓
- `bot` — is_past_only = true ✓
- `if σ p then neg bot else bot` — both branches are past_only ✓

All conditions discharge by `simp [Separation.is_past_only]`.

### `h_reps_fo` (for future correct)

Symmetric. All replacements in `constSubs_σ ++ [(lt, bot), (gt, neg bot)]` are future_only. Same reasoning. ✓

### `h_match` (the critical condition)

For past substitutions, for each `(a, r)` in the substitution list and each `s ≤ t`:
```
int_truth M s r ↔ s ∈ M.val a
```
where M = M_ext = `to_int_struct (extIntStruct M_base t) freshAM`.

Case split on which pair `(a, r)` we're examining:

1. `a = freshAM (.orig p)`, `r = Formula.atom (atomMap p)`:
   - `s ∈ M_ext.val (freshAM (.orig p))` = `(extIntStruct M_base t).interp (.orig p) s` = `M_base.interp p s` (by `to_int_struct_mem_freshAM` + freshAM_inj)
   - `int_truth M_ext s (Formula.atom (atomMap p))` = `s ∈ M_ext.val (atomMap p)` = `∃ ep, freshAM ep = atomMap p ∧ (extIntStruct M_base t).interp ep s`
   - **This requires `atomMap p` to NOT be in freshAM's range** (disjointness), so that `s ∈ M_ext.val (atomMap p) = False`, which contradicts `M_base.interp p s` in general.
   - **Resolution**: The h_match condition must be checked in M_orig (not M_ext). Looking at `applySubsts_past_correct` again: its model parameter is the model in which both `applySubsts φ subs` and `φ` are evaluated. If we apply it to M_orig, then h_match reads: `int_truth M_orig s r ↔ s ∈ M_orig.val a`, i.e., for `(freshAM (.orig p), Formula.atom (atomMap p))`: `M_base.interp p s ↔ s ∈ M_orig.val (freshAM (.orig p))`. But `M_orig.val` is indexed by atomMap atoms, and `freshAM (.orig p) ≠ atomMap q` for any q (disjointness) — so `M_orig.val (freshAM (.orig p)) = ∅`. This gives `M_base.interp p s ↔ False`, which fails.

**Conclusion**: `applySubsts_past_correct` CANNOT be applied directly to either M_ext or M_orig for the `origSubsList` entries. The only correct approach is:

- A direct model-switching argument showing that after all substitutions in `applySubsts φ subs_past` are applied, the result formula has no freshAM atoms (only atomMap atoms or constants), and then M_ext and M_orig agree on atomMap atoms.
- OR: Define an intermediate "bridge" model that has both freshAM and atomMap atoms correctly valued, apply `applySubsts_past_correct` to this bridge, and then show the bridge agrees with M_orig on the final atomMap-only formula.

The bridge model approach: define `M_bridge` where:
- `M_bridge.val (freshAM (.orig p))` = `{s | M_base.interp p s}`
- `M_bridge.val (freshAM (.const_at_ref p))` = `{s | M_base.interp p t}` (constant set)
- `M_bridge.val (freshAM .lt_ref)` = `{s | s < t}`
- `M_bridge.val (freshAM .gt_ref)` = `{s | t < s}`
- `M_bridge.val (atomMap p)` = `{s | M_base.interp p s}` (same as M_orig)
- `M_bridge.val a` = `∅` for all other atoms

Then:
- `int_truth M_bridge t B_sep = int_truth M_ext t B_sep` (by `past_only_is_pure_past` applied to B_sep, since both agree on freshAM atoms)
- `applySubsts_past_correct` applies to M_bridge with h_match holding for both freshAM atoms (by definition) and (lt, neg bot), (gt, bot)
- After substitution, result formula has only atomMap atoms → M_bridge and M_orig agree

This is the cleanest path but requires constructing M_bridge explicitly, which adds ~20 LOC.

Alternatively: prove `elimExtFromSep_correct` by direct induction without using `applySubsts_past_correct` as an intermediate, instead directly establishing the correspondence atom-by-atom using `to_int_struct_mem_freshAM` and `to_int_struct_mem_atomMap`.

---

## 6. The Disjointness Requirement

The handoff document correctly identifies this as the core blocker. Here is the precise formulation:

**Required**: `∀ p : sig.preds, ∀ ep : ExtPred sig, atomMap p ≠ freshAM ep`

**Why**: In `applySubsts (.atom (freshAM (.orig p))) (constSubs_σ ++ [(lt, bot), (gt, bot)])`, the origSubsList replaces `freshAM (.orig p)` with `Formula.atom (atomMap p)`. Then subsequent substitutions check if `atomMap p = freshAM (.const_at_ref p')` (for each p' in constSubs_σ). If they are equal, `Formula.atom (atomMap p)` would be replaced by `⊤` or `⊥`, corrupting the result.

**Top-level call**: `atomMap p = Atom.mk_fresh "p" idx`, `freshAM ep = Atom.mk_fresh "e" idx'`. Since "p" ≠ "e", they cannot be equal. Disjointness holds trivially. ✓

**Recursive levels**: In `.ex alpha`, the new `freshAM = fun ep => Atom.mk_fresh "e" idx_ep`. The outer `atomMap` was the previous level's `freshAM` (also "e" prefix). Index collision possible.

**Fix (Option B from handoff)**: Change the freshAM construction from:
```lean
fun ep => Atom.mk_fresh "e" (Fintype.equivFin (extSignature sig).preds ep).val
```
to:
```lean
fun ep => Atom.mk_fresh "e" (offset + (Fintype.equivFin (extSignature sig).preds ep).val)
```
where `offset > max index used by atomMap's range`. Since atomMap at recursion depth k uses indices in `[k_start, k_start + card(sig.preds)]`, and the freshAM at depth k uses `[offset_k, offset_k + card(ExtPred sig)]`, choosing `offset_k = offset_{k-1} + card(ExtPred sig_{k-1})` guarantees disjointness at all levels.

---

## 7. Proof Decomposition for `atom_elim_correct`

The full proof of `atom_elim_correct` decomposes into 4 lemmas:

### Lemma A: `elimExtFromSep_correct` (Task 7.6c)

~100 LOC. Structural induction on B_sep. Requires:
- `h_disj : ∀ p ep, atomMap p ≠ freshAM ep` (from freshAM construction fix)
- `freshAM_inj`, `hinj`
- `hB_sep : is_properly_separated B_sep = true`
- σ fixed as σ* (matching M at t)

### Lemma B: `guardFormula_correct` (Task 7.6b — already proved, line 842)

Already at line 842. Proves `int_truth M_orig t (guardFormula atomMap σ) ↔ ∀ p, σ p = true ↔ M.interp p t`.

### Lemma C: `quantElimFormula_correct_iff` (Task 7.6d)

~40 LOC. Unfolds the foldl-or disjunction. Uses classical reasoning to extract the unique matching σ*. Uses `guardFormula_correct` for uniqueness. Relies on `int_truth_foldl_or` (analog of the existing `int_truth_foldl_and` at line 822 — needs to be added).

### Lemma D: `atom_elim_correct` (glue, Task 7.6e — currently has `sorry`)

~15 LOC. Combines Lemmas A, B, C. Sets σ* = decide ∘ M.interp · t. Shows guard is true (B), then uses A to convert M_ext truth to M_orig truth of the σ* branch. C then gives equivalence to the full disjunction.

---

## 8. Missing Pieces

1. **freshAM disjointness fix** (prerequisite for everything):
   - Modify the `freshAM` construction in both `.ex` and `.all` cases of `expressiveness_inner` (lines ~981–988 and ~1035–1040) to use offset indices.
   - Estimated: 10 LOC change + 20 LOC disjointness proof.
   - This must be done BEFORE attempting `elimExtFromSep_correct`.

2. **`int_truth_foldl_or` helper** (needed for `quantElimFormula_correct_iff`):
   - Analog of `int_truth_foldl_and` at line 822 but for `foldl Formula.or`.
   - Estimated: ~15 LOC.
   - Note: `quantElimFormula` uses `foldl Formula.or` (line 685), so this is needed.

3. **`elimExtFromSep_correct`** (Lemma A, the hard core):
   - Structural induction, 8 constructor cases.
   - atom case is the complex one (requires disjointness).
   - all_past/all_future/snce/untl cases use the atom correspondence argument.
   - Estimated: 80–120 LOC.
   - Best approach: direct induction without `applySubsts_past_correct` as intermediate, instead use `to_int_struct_mem_freshAM` + `to_int_struct_mem_atomMap` directly.
   - Alternative: bridge model approach (adds ~20 LOC but makes `applySubsts_past_correct` applicable).

4. **`quantElimFormula_correct_iff`** (Lemma C):
   - Needs `int_truth_foldl_or` helper.
   - Needs classical reasoning for unique σ* witness.
   - Estimated: 40 LOC.

5. **The `.box` case non-recursion**: Note that `elimExtFromSep` passes `.box φ` through unchanged (the inner φ gets NO substitution applied). This is correct because `int_truth M t (.box φ) = True` always. But it means any extended atoms inside a box formula remain unsubstituted. Since `is_properly_separated (.box _) = true` regardless of what's inside, B_sep can have arbitrary formulas under box. The proof for box must NOT try to recurse or substitute inside — it just proves `True ↔ True`. This is fine.

---

## 9. Confidence Assessment

| Component | Confidence | Key Risk |
|-----------|------------|----------|
| Structural induction is correct approach | Very High | None |
| bot, imp, box cases | Very High | Trivial |
| all_past / all_future cases (with disjointness) | High | h_match discharge for origSubsList |
| snce / untl cases | High | Same as all_past/future |
| atom case (with disjointness) | High | Requires careful case split on ep |
| freshAM disjointness fix | High | Index arithmetic in Nat |
| quantElimFormula_correct_iff | Medium | foldl_or unfolding + classical unique witness |
| Full atom_elim_correct | Medium-High | Depends on all above |

Overall: The proof is structurally sound and feasible. The central mathematical insight (that lt→⊤ for past times, gt→⊥ for past times, and the orig/const substitutions encode the model exactly) is correct. The main technical barrier is the disjointness fix and correctly formulating h_match so that `applySubsts_past_correct` can be applied (or replaced with a direct argument).

**Recommended implementation order**:
1. Fix freshAM offset construction (prerequisite)
2. Add `int_truth_foldl_or` helper
3. Prove `elimExtFromSep_correct` by direct structural induction
4. Prove `quantElimFormula_correct_iff`
5. Close `atom_elim_correct` sorry

**Total estimated LOC**: 150–180 (within the 4-hour estimate).
