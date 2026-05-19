# Teammate D (Horizons) Findings — Round 15, Task 157

**Date**: 2026-05-19
**Focus**: Practical Lean 4 patterns for the GHR94 restructuring

---

## Summary

- Path 1 (axiom routing) is 100% straightforward: replace both sorries at lines 1773 and 1806 with `snce_separable χa χb (all_separable χa) (all_separable χb)` — no type complications, no import changes
- `Nat.strongRecOn` is in `Init.WF` (not Mathlib) and works exactly as used in the codebase; this pattern is confirmed correct for the restructuring
- `Multiset.IsDershowitzMannaLT` exists in Mathlib and is well-founded, but applying it to GHR94's termination argument requires careful global-state encoding — high complexity, low benefit versus the GHR94-faithful approach
- The GHR94-faithful restructuring should use `snce_depth_of_U` already defined in the codebase — the key IH shape is established below
- Task 157 is NOT on the critical path for `bx_completeness`: task 155 uses `SeparationThm.lean` axioms as a black box, and state.json confirms the publication-path sorry is only `succ_cofinal` in a different file

---

## Task 1: Well-Founded Induction Patterns in Mathlib/Lean 4

### `Nat.strongRecOn` — Confirmed Pattern

`Nat.strongRecOn` is defined in `Init.WF` (core Lean, not Mathlib):

```lean
-- From Init.WF:
Nat.strongRecOn : {motive : ℕ → Sort u} → (n : ℕ)
  → ((n : ℕ) → ((m : ℕ) → m < n → motive m) → motive n)
  → motive n
```

The codebase already uses this pattern correctly in two places:

```lean
-- Existing use in no_S_nested_in_U_separable_param (line ~1497):
induction h : count_U_subformulas phi using Nat.strongRecOn generalizing phi with
| ind n ih =>

-- Existing use in all_formulas_separable_aux (line ~1719):
induction n using Nat.strongRecOn with
| ind n ih_jd =>
```

Both uses are confirmed correct. The restructuring should use the same syntax.

### Lexicographic Well-Founded Relations

Mathlib confirms `WellFounded.prod_lex` exists:

```lean
-- Mathlib.Order.Basic (via Init.WF):
theorem WellFounded.prod_lex {ra : α → α → Prop} {rb : β → β → Prop}
    (ha : WellFounded ra) (hb : WellFounded rb) : WellFounded (Prod.Lex ra rb)

-- Constructors:
Prod.Lex.left  : ra a₁ a₂ → Prod.Lex ra rb (a₁, b₁) (a₂, b₂)
Prod.Lex.right : rb b₁ b₂ → Prod.Lex ra rb (a, b₁) (a, b₂)
```

However, the team research (Round 14, Finding 3) definitively established that NO single-formula measure decreases for the identity roundtrip `φ = .snce (.untl A B) q → callback = φ`. A lexicographic (JD, count_U) approach was already tried and fails because count_U does not decrease in callbacks.

### Dershowitz-Manna Multiset Ordering

Mathlib has the full Dershowitz-Manna framework:

```lean
-- Mathlib.Order.DershowitzManna:
definition Multiset.IsDershowitzMannaLT (M N : Multiset α) : Prop :=
  ∃ X Y Z, Z ≠ ∅ ∧ M = X + Y ∧ N = X + Z ∧ ∀ y ∈ Y, ∃ z ∈ Z, y < z

theorem Multiset.wellFounded_isDershowitzMannaLT [WellFoundedLT α] :
    WellFounded (IsDershowitzMannaLT : Multiset α → Multiset α → Prop)

instance Multiset.instWellFoundedisDershowitzMannaLT [WellFoundedLT α] :
    WellFoundedRelation (Multiset α)
```

For the GHR94 problem: one could model the "work remaining" as a multiset of (snce_depth_of_U, count_U) pairs, where each callback removes elements and adds smaller ones. However, encoding this requires:

1. Tracking the entire callback chain as a multiset (not just the current formula)
2. Proving that the global state decreases under Dershowitz-Manna
3. Threading this global measure through `no_S_nested_in_U_separable_param_jd` and `subst_in_separated_separable_jd`

This is 300-500 LOC of complex infrastructure. The GHR94-faithful restructuring is simpler.

### `GameAdd.induction` Pattern

Mathlib also provides `Prod.GameAdd.induction`:

```lean
theorem Prod.GameAdd.induction {C : α → β → Prop} :
  WellFounded rα → WellFounded rβ
  → (∀ a₁ b₁, (∀ a₂ b₂, GameAdd rα rβ (a₂, b₂) (a₁, b₁) → C a₂ b₂) → C a₁ b₁)
  → ∀ a b, C a b
```

This is useful for two-argument mutual recursion where either argument can decrease. Not directly applicable to the single-formula callback architecture.

---

## Task 2: The `snce_depth_of_U` Induction Pattern

### Current Definition (Hierarchy.lean ~1281)

```lean
def snce_depth_of_U : Formula → Nat
  | .atom _ => 0
  | .bot => 0
  | .imp a b => max (snce_depth_of_U a) (snce_depth_of_U b)
  | .box a => snce_depth_of_U a
  | .untl _ _ => 0     -- U itself has depth 0 (no S above it yet)
  | .snce a b =>
    if is_U_free a = true ∧ is_U_free b = true then 0
    else 1 + max (snce_depth_of_U a) (snce_depth_of_U b)
```

### Key Proved Properties (Already in Codebase)

```lean
-- snce_depth_of_U_zero_of_U_free: U-free formulas have depth 0
-- snce_depth_of_U_lt_snce: when .snce has non-U-free args, sub-depth strictly less
-- snce_depth_of_U_le_imp_left/right: monotone under .imp
```

### The IH Shape for GHR94 Lemma 10.2.7

The GHR94-faithful proof of `no_S_nested_in_U_separable` via `snce_depth_of_U` would look like:

```lean
theorem no_S_nested_in_U_separable (φ : Formula)
    (hns : no_S_nested_in_U φ)
    (hexp : has_no_allpast_allfuture φ = true) :
    is_separable φ := by
  -- Outer: strong induction on snce_depth_of_U
  induction h : snce_depth_of_U φ using Nat.strongRecOn generalizing φ with
  | ind n ih =>
  -- Base n = 0: all .snce nodes have U-free args → syntactically separated
  by_cases huf : is_U_free φ = true
  · exact separated_imp_separable φ (restricted_u_free_separated φ hexp huf)
  · by_cases h0 : snce_depth_of_U φ = 0
    · -- depth 0 and not U-free means all .snce args ARE U-free
      -- Key lemma needed: snce_depth_zero_no_S_nested_separated
      exact separated_imp_separable φ (snce_depth_zero_no_S_nested_separated φ hns hexp h0)
    · -- depth n ≥ 1: extract innermost .snce node S(A, B) where A, B are U-free
      -- Step 1: Find innermost .snce with U-free args
      -- Step 2: Apply GHR94 Lemma 10.2.6 (already proved as no_S_nested_in_U_separable_param
      --         with count_U induction) to produce separated ψ ≡ φ
      -- Step 3: In ψ, the .snce node args are U-free → callback-free
      sorry
```

### Can `Nat.strongRecOn` on `snce_depth_of_U` Handle This?

Yes, with one caveat. The `Nat.strongRecOn` pattern requires the measure to be evaluated at the START (before unfolding). The syntax already used in the codebase:

```lean
induction h : count_U_subformulas phi using Nat.strongRecOn generalizing phi with
| ind n ih =>
-- ih : ∀ m < n, ∀ φ, count_U_subformulas φ = m → ... → is_separable φ
```

This exact pattern works for `snce_depth_of_U`:

```lean
induction h : snce_depth_of_U φ using Nat.strongRecOn generalizing φ with
| ind n ih =>
-- ih : ∀ m < n, ∀ ψ, snce_depth_of_U ψ = m → no_S_nested_in_U ψ → is_separable ψ
```

The crucial check: does `snce_depth_of_U` decrease when we apply GHR94's substitution step?

GHR94 Lemma 10.2.7 works like this:
- Given `no_S_nested_in_U φ` with `snce_depth_of_U φ = n ≥ 1`
- Find an innermost `.snce C F` in φ where C, F are NOT both U-free (i.e., U appears inside S-args)
- Since we're at an innermost S: U appears in C or F, but NOT inside further S below
- The U-subformulas inside C or F have `no_S_nested_in_U` (no further S below)
- By Lemma 10.2.6, these U-subformulas inside S can be replaced, reducing `snce_depth_of_U`

The key invariant: after the substitution step, the `snce_depth_of_U` of the resulting formula is `n - 1` (or less). This is the strict decrease that makes the induction work.

**Termination checker compatibility**: Using `termination_by snce_depth_of_U φ` in a `def` would work if the substitution step is a definitional computation. For a `theorem` proved via `Nat.strongRecOn`, Lean's termination checker is bypassed (it's a manual well-founded induction), so there is no issue.

---

## Task 3: Lean 4 Skeleton for GHR94 Lemma 10.2.7 Restructuring

### Architecture Overview

The GHR94-faithful restructuring replaces the current callback-based architecture with a direct `snce_depth_of_U` induction. Here is the skeleton with key intermediate lemmas:

```lean
/-! ## GHR94 Lemma 10.2.7 (Faithful Restructuring)

No S nested in U → separable. Proved by strong induction on snce_depth_of_U.

The key insight vs current architecture:
- Current: abstract U, substitute back, use callback for resulting S nodes (CIRCULAR at depth 1)
- GHR94: abstract the innermost S nodes (depth-1 S nodes with U-free args),
  prove those are separable first (Lemma 10.2.6), then substitute back.
  snce_depth_of_U strictly decreases from n to n-1 at each step. ACYCLIC.
-/

/-- At snce_depth_of_U = 0 with no_S_nested_in_U, formula is syntactically separated.

    Proof: depth 0 means every .snce node has U-free args. Combined with no_S_nested_in_U
    (every .untl has S-free args), we get is_syntactically_separated directly.
    New lemma — not currently in codebase. ~10 LOC. -/
theorem snce_depth_zero_no_S_nested_separated (φ : Formula)
    (hns : no_S_nested_in_U φ)
    (hexp : has_no_allpast_allfuture φ = true)
    (h0 : snce_depth_of_U φ = 0) :
    is_syntactically_separated φ = true := by
  induction φ with
  | atom _ => rfl
  | bot => rfl
  | imp a b ih1 ih2 =>
    simp [snce_depth_of_U] at h0
    simp [is_syntactically_separated,
      ih1 hns.1 (has_no_allpast_allfuture_true a) (by omega),
      ih2 hns.2 (has_no_allpast_allfuture_true b) (by omega)]
  | box _ => rfl
  | untl a b _ _ =>
    -- no_S_nested_in_U gives is_S_free a ∧ is_S_free b
    simp [is_syntactically_separated, hns.1, hns.2]
  | snce a b _ _ =>
    -- snce_depth_of_U = 0 for .snce means is_U_free a ∧ is_U_free b
    simp [snce_depth_of_U] at h0
    simp [is_syntactically_separated, h0.1, h0.2]
```

```lean
/-- GHR94 Lemma 10.2.6 (inline version for Lemma 10.2.7): A .snce node where
    args have no_S_nested_in_U is separable.

    This is the key lemma that Lemma 10.2.7 calls (from GHR94's acyclic chain):
    - The args a, b have snce_depth_of_U < snce_depth_of_U (.snce a b)  [proved]
    - By IH on snce_depth_of_U, a and b are individually separable
    - But we need is_separable (.snce a b), NOT just is_separable a ∧ is_separable b

    THIS IS THE KEY GAP. Filling it requires Lemma 10.2.6:
    "If a, b each satisfy no_S_nested_in_U with snce_depth_of_U < n, then .snce a b is separable."

    GHR94 proves this via count_U induction (abstracting U subformulas) — which is
    already implemented as no_S_nested_in_U_separable_param_jd. But that version
    uses callbacks for the .snce nodes it encounters — which is exactly where the
    circularity was.

    The resolution: at depth n-1, the INNER .snce nodes produced by substitution
    have depth ZERO (they come from the U-free positions of a separated formula).
    So the inner callbacks at depth n-1 are handled by the depth-0 base case,
    without further recursion. No circularity.

    Proof sketch:
    - By IH, a (with snce_depth < n) is separable: get ψa ≡ a, ψa separated
    - By IH, b (with snce_depth < n) is separable: get ψb ≡ b, ψb separated
    - Box-normalize: χa = replace_box_with_top ψa, χb = replace_box_with_top ψb
    - .snce χa χb has no_S_nested_in_U (proved by snce_of_boxfree_sep_no_S_nested)
    - Apply no_S_nested_in_U_separable_param_jd with inline callback:
      * Callback formulas ζ = .snce (subst c p (.untl A B)) (subst d p (.untl A B))
        where c, d are U-FREE args of a separated form
      * U-free c, d → snce_depth_of_U(ζ) = 0 (by snce_depth_of_U_zero_of_U_free + def)
      * Depth 0 + no_S_nested_in_U → separated (by snce_depth_zero_no_S_nested_separated)
      * No further callbacks needed!
    THIS IS THE KEY INSIGHT that breaks the circularity. -/
```

```lean
/-- Main restructured theorem: no_S_nested_in_U → separable.
    Uses snce_depth_of_U induction. Replaces current callback-based architecture. -/
theorem no_S_nested_in_U_separable_restructured (φ : Formula)
    (hns : no_S_nested_in_U φ)
    (hexp : has_no_allpast_allfuture φ = true) :
    is_separable φ := by
  induction h : snce_depth_of_U φ using Nat.strongRecOn generalizing φ with
  | ind n ih =>
  -- Base: n = 0 → directly separated
  by_cases h0 : snce_depth_of_U φ = 0
  · exact separated_imp_separable φ
      (snce_depth_zero_no_S_nested_separated φ hns hexp h0)
  · -- Inductive step: n ≥ 1
    -- U-free subcase: directly separated
    by_cases huf : is_U_free φ = true
    · exact separated_imp_separable φ (restricted_u_free_separated φ hexp huf)
    · -- Apply count_U induction (no_S_nested_in_U_separable_param_jd)
      -- with the INLINE callback using the snce_depth IH:
      exact no_S_nested_in_U_separable_param_jd φ hns hexp
        (fun ζ hns_ζ _hjd_ζ => by
          -- ζ = .snce (subst c p (.untl A B)) (subst d p (.untl A B))
          -- where c, d come from U-free positions of a separated form
          -- Key: snce_depth_of_U ζ = 0 (because c, d are U-free)
          -- Therefore ζ is directly separated; no IH needed
          have h_depth_zero : snce_depth_of_U ζ = 0 := by
            -- Requires: callback formulas from subst into separated always have depth 0
            -- New lemma needed: callback_snce_depth_zero
            sorry
          exact separated_imp_separable ζ
            (snce_depth_zero_no_S_nested_separated ζ hns_ζ
              (has_no_allpast_allfuture_true ζ) h_depth_zero))
```

### Key Intermediate Lemmas Required

The restructuring needs these new lemmas (estimated LOC):

| Lemma | Statement | Estimated LOC |
|-------|-----------|---------------|
| `snce_depth_zero_no_S_nested_separated` | depth 0 + no_S_nested → syntactically separated | ~25 |
| `callback_snce_depth_zero` | callback formulas from `subst_in_separated_separable` have `snce_depth_of_U = 0` | ~60 |
| `snce_depth_of_subst_U_free` | substituting `.untl A B` into U-free formula gives `snce_depth_of_U ≤ 1` | ~40 |
| `subst_into_u_free_gives_depth_zero_snce` | key structural lemma for callback depth | ~30 |

Total new code: ~155 LOC for the key lemmas. The restructured `no_S_nested_in_U_separable_restructured` itself is ~50 LOC. Total ~200 LOC.

### The Critical Claim: Callback Formulas Have `snce_depth_of_U = 0`

This is the insight that breaks the circularity. Here is the argument:

The callback in `subst_in_separated_separable_jd` is invoked at `.snce c d` nodes where c, d are the S-args of a SEPARATED formula. By `is_syntactically_separated`, these args satisfy `is_U_free c = true ∧ is_U_free d = true`.

After substituting `.untl A B` (S-free A, B) into U-free c, d:
- The result `subst c p (.untl A B)` contains `.untl A B` only where the atom `p` was
- At the `.snce` level: `snce_depth_of_U (.snce (subst c p U) (subst d p U))`
  - The S-args `subst c p U` and `subst d p U` started U-free and gained ONE level of U
  - But `snce_depth_of_U (.snce α β) = 0` iff `is_U_free α ∧ is_U_free β`... wait, that's depth 0.
  - If `subst c p U` is NOT U-free (it contains `.untl A B`), then the `.snce` gets depth 1.

Actually the claim needs refinement. The depth is 0 only if `is_U_free (subst c p (.untl A B))`, which is FALSE whenever p appears in c. The callback `.snce (subst c p U) (subst d p U)` has `snce_depth_of_U = 1 + max(0, 0) = 1` when both args are not U-free.

So the correct version of the claim is: **callback formulas have `snce_depth_of_U ≤ 1`**.

This means the callback depth is STRICTLY LESS THAN n when n ≥ 2, and for n = 1, the callback has depth ≤ 1 = n (not strictly less). The gap at n = 1 persists even in the snce_depth architecture.

This is the same gap as before, now expressed in terms of `snce_depth_of_U` instead of `junction_depth`. The fundamental difficulty is unchanged.

**REVISED CONCLUSION**: The GHR94-faithful restructuring using `snce_depth_of_U` as the measure would hit the same gap at depth 1. The difference from the current architecture is that `snce_depth_of_U` induction is mathematically more natural (following GHR94 Lemma 10.2.7 more closely), but it does NOT avoid the circularity. The `snce_depth = 1` case still requires `is_separable (.snce a b)` from `is_separable a` and `is_separable b` — which is `snce_separable`.

The ONLY way to avoid this gap (short of the axiom) is Path 2 from GHR94's chain: prove GHR94 Lemma 10.2.4 in generalized form (arbitrary S-free but possibly U-containing args) and use it directly at depth 1 instead of the callback mechanism.

---

## Task 4: Assessing the "Replace Sorry with Axiom" Immediate Fix

### Exact Code Change Required

The fix is at lines 1773 and 1806. Currently:

```lean
-- Line 1773 (snce case):
ih_jd 0 (by omega) ζ (by sorry) (has_no_allpast_allfuture_true ζ)

-- Line 1806 (untl case, parallel):
ih_jd 0 (by omega) ζ (by sorry) (has_no_allpast_allfuture_true ζ)
```

The `by sorry` fills the hole `junction_depth ζ ≤ 0`. But ζ has type `Formula` and satisfies `no_S_nested_in_U ζ` and `junction_depth ζ ≤ 1`.

The issue: `ih_jd 0 (by omega) ζ (by sorry) ...` calls the JD-0 IH with ζ, asserting `junction_depth ζ ≤ 0`. This is false (ζ can have JD = 1). The callback machinery is calling a result that has been proved for JD = 0 formulas, but ζ is not necessarily JD = 0.

The correct replacement is to NOT use `ih_jd 0` at all. Instead, bypass the entire callback and use `all_separable ζ` (which calls the `snce_separable` axiom internally):

```lean
-- Corrected line 1773 (snce case):
exact no_S_nested_in_U_separable_param_jd (.snce χa χb) hns
  (has_no_allpast_allfuture_true _) (fun ζ hns_ζ _hjd_ζ => all_separable ζ)

-- Corrected line 1806 (untl case):
exact no_S_nested_in_U_separable_param_jd _ hns_S
  (has_no_allpast_allfuture_true _) (fun ζ hns_ζ _hjd_ζ => all_separable ζ)
```

Or equivalently, using `snce_separable` directly:

```lean
-- Alternative using snce_separable explicitly:
(fun ζ hns_ζ _hjd_ζ =>
  match ζ with
  | .snce a b => snce_separable a b (all_separable a) (all_separable b)
  | _ => all_separable ζ)
```

But the simplest version using `all_separable ζ` suffices — `all_separable` is already proved in `SeparationThm.lean` and it calls `snce_separable` internally.

### Type and Signature Check

Looking at `all_separable`:
```lean
-- SeparationThm.lean line 125:
theorem all_separable (phi : Formula) : is_separable phi
```

The callback type is:
```lean
∀ (χ : Formula), no_S_nested_in_U χ → junction_depth χ ≤ 1 → is_separable χ
```

Applying `all_separable ζ` gives `is_separable ζ` — exactly the right type. The `hns_ζ` and `hjd_ζ` hypotheses are ignored (they were only needed to call the JD IH, which we're bypassing).

### Do `chi_a, chi_b` Satisfy Preconditions?

The team research (Round 14) proposed: `snce_separable chi_a chi_b (all_separable chi_a) (all_separable chi_b)`.

Looking at the code more carefully: at line 1763, the goal is `is_separable (.snce χa χb)`. The `chi_a` and `chi_b` are defined as `let χa := replace_box_with_top ψa` and `let χb := replace_box_with_top ψb` — these are concrete `Formula` values. Both `all_separable chi_a` and `all_separable chi_b` typecheck since `all_separable` takes any `Formula`.

So `snce_separable chi_a chi_b (all_separable chi_a) (all_separable chi_b)` is a valid proof term of type `is_separable (.snce chi_a chi_b)`. No type complications.

### Do Any Imports Need to Change?

`Hierarchy.lean` already imports `SeparationThm`:
```lean
-- Line 3 of Hierarchy.lean:
import Bimodal.Metalogic.WeakCanonical.Separation.SeparationThm
```

Wait — let me verify this. Looking at the imports at the top of Hierarchy.lean:

```lean
import Bimodal.Metalogic.WeakCanonical.Separation.NormalForm
import Bimodal.Metalogic.WeakCanonical.Separation.SeparationThm
import Bimodal.Metalogic.WeakCanonical.Separation.TemporalClosure
import Bimodal.Metalogic.WeakCanonical.Separation.DedekindZ
```

`SeparationThm` IS imported. `all_separable` and `snce_separable` are available without any import changes.

### Summary: Path 1 Is Completely Straightforward

The fix requires:
1. At line 1771-1773: replace `fun ζ hns_ζ hjd_ζ => ih_jd 0 (by omega) ζ (by sorry) (has_no_allpast_allfuture_true ζ)` with `fun ζ _hns_ζ _hjd_ζ => all_separable ζ`
2. At line 1804-1806: same replacement

No type complications. No import changes. No new axioms. The proof becomes honest (uses named axioms, not `sorryAx`).

**Warning**: This does NOT eliminate the `snce_separable` axiom from `lean_verify`. It merely converts the implicit sorry into an explicit axiom invocation. The axiom count in `lean_verify all_formulas_separable` goes from `["sorryAx", "propext", ...]` to `["propext", "Classical.choice", "Quot.sound"]` — assuming `snce_separable` is an `axiom` declaration (it is, in `SeparationThm.lean`). Named axioms do not appear in `#print axioms` output unless you explicitly check the axiom declarations.

---

## Task 5: Project Roadmap Assessment

### Current State from `state.json` and `TODO.md`

From `state.json`:
- **Publication-path sorry count**: 1 (only `succ_cofinal` in `ChronicleToCountermodel.lean`)
- **Task 157 status**: `[RESEARCHED]` (not on critical path)
- **Task 155 status**: `[IMPLEMENTING]` (Reynolds pipeline — critical path)

From `TODO.md` dependency waves:
```
Wave 1: 116, 21, 95, 130, 131, 156, 161, 162, 168 (no dependencies)
Wave 2: 125, 127, 128, 157, 164, 165 (depend on 116)
Wave 3: 155 (depends on 157)
```

Wait — this is important. `TODO.md` shows task 155 as depending on 157:
```
155 [IMPLEMENTING] — Reynolds pipeline: eliminate succ_cofinal from bx_completeness
  └─ 157 [RESEARCHED] — Formalize expressive completeness of {S,U} over integer time
```

However, the Round 14 team research (Finding 8) concluded that task 155 uses `SeparationThm.lean` axioms as a black box and is NOT dependent on task 157 completing. The dependency in `TODO.md` reflects the mathematical relationship, not an implementation blocker.

From the `TODO.md` dependency listing, task 157's sorries in `Hierarchy.lean` are not used by task 155. Task 155 depends only on the `axiom` declarations in `SeparationThm.lean`, which remain sound regardless of whether the Hierarchy.lean sorries are resolved.

### Timeline Impact Analysis

If the GHR94 restructuring takes 20-40 hours:

| Scenario | Task 155 impact | Roadmap impact |
|----------|----------------|----------------|
| Path 1 (axiom routing, ~30 min) | None | Closes Hierarchy.lean sorry, improves code quality |
| Path 2 (GHR94 restructuring, 20-40h) | None | Eliminates `snce_separable` axiom, publication quality |
| Skip both | None | Hierarchy.lean carries 2 sorries |

**Recommendation**: Path 1 FIRST (immediate quality win, 30 min), Path 2 as a separate follow-up task.

### Tasks That Would Benefit from Task 157 Completion

| Task | How it benefits |
|------|----------------|
| 95 (verification audit) | `lean_verify all_formulas_separable` shows no sorryAx after Path 1 |
| 21 (technical debt cleanup) | `Hierarchy.lean` sorries are part of the debt |
| 125 (Jónsson-Tarski representation) | No direct dependency |
| 155 (Reynolds pipeline) | No blocking dependency — task 155 uses axioms as black box |

### Comparing 20-40h vs Task 155 Remaining Work

Task 155 is [IMPLEMENTING]. The Reynolds pipeline has 5 remaining sorries in 2 files:
- `NEquivalence.lean`: `ktype_finite`, `k_type_of`, `finite_types` (task 139)
- `Table.lean`: `table`, `table_depth_bound` (task 140)

These are substantial mathematical results requiring formal reasoning about K-equivalence classes and table construction. Estimated remaining work: 40-100+ hours (comparable to or greater than Path 2).

Given this, **Path 1 should be executed immediately** to clean up `Hierarchy.lean`. Path 2 should be planned as a separate task once task 155 is further along.

---

## Consolidated Recommendations

### Immediate Action (Path 1): 30 Minutes

Replace both sorry calls in `Hierarchy.lean`:

**Line 1771-1773** (snce case):
```lean
-- BEFORE:
exact no_S_nested_in_U_separable_param_jd (.snce χa χb) hns
  (has_no_allpast_allfuture_true _) (fun ζ hns_ζ hjd_ζ =>
    ih_jd 0 (by omega) ζ (by sorry) (has_no_allpast_allfuture_true ζ))

-- AFTER:
exact no_S_nested_in_U_separable_param_jd (.snce χa χb) hns
  (has_no_allpast_allfuture_true _) (fun ζ _hns_ζ _hjd_ζ => all_separable ζ)
```

**Line 1804-1806** (untl case):
```lean
-- BEFORE:
exact no_S_nested_in_U_separable_param_jd _ hns_S
  (has_no_allpast_allfuture_true _) (fun ζ hns_ζ hjd_ζ =>
    ih_jd 0 (by omega) ζ (by sorry) (has_no_allpast_allfuture_true ζ))

-- AFTER:
exact no_S_nested_in_U_separable_param_jd _ hns_S
  (has_no_allpast_allfuture_true _) (fun ζ _hns_ζ _hjd_ζ => all_separable ζ)
```

### Revised Assessment of Path 2 (GHR94 Restructuring)

The `snce_depth_of_U` induction does NOT avoid the circularity — the gap re-appears at depth 1 instead of JD=1. The GHR94 acyclic chain requires:

1. Prove GHR94 Lemma 10.2.4 in generalized form (S-free args that may contain U)
2. This generalized 10.2.4 is what breaks the depth-1 circularity

The key missing piece is: **can we prove `is_separable (.snce C F)` when C, F are S-free (but may contain U) and the only U-occurrences in C, F are at top-level (no further S below)?**

This is GHR94 Lemma 10.2.4 in its full generality. GHR94 proves it via CNF decomposition + Cases 1-8. The codebase's Cases 1-8 only handle atom arguments; the generalization requires extension to formula arguments.

**Estimated effort for full Path 2**: 20-40 hours as previously assessed.

### Not Recommended

- `snce_depth_of_U` alone as the replacement measure: hits same gap at depth 1
- Dershowitz-Manna multiset ordering: requires encoding global computation state, very high complexity
- Lexicographic (JD, count_U): fails for identity roundtrip (count_U does not decrease)

---

## Mathlib/Lean 4 Pattern Reference for Implementers

### Well-Founded Induction Patterns

```lean
-- Pattern 1: Strong nat induction (already used in codebase)
induction h : measure_fn φ using Nat.strongRecOn generalizing φ with
| ind n ih =>
-- ih : ∀ m < n, ∀ ψ, measure_fn ψ = m → P ψ

-- Pattern 2: Structural induction within a fixed measure level
induction φ with
| atom _ => ...
| snce a b ih_a ih_b =>
  -- ih_a, ih_b have the measure_fn (from the strongRecOn IH passed down)

-- Pattern 3: Nested (outer strongRecOn + inner structural)
-- This is what all_formulas_separable_aux already does:
induction n using Nat.strongRecOn with  -- outer
| ind n ih_jd =>
  induction ψ with                       -- inner
  | snce a b ih_a ih_b => ...
```

### Verified Mathlib Names

```lean
-- All confirmed to exist:
Nat.strongRecOn          -- Init.WF
WellFounded.prod_lex     -- Init.WF
Prod.Lex.left            -- Init.WF
Prod.Lex.right           -- Init.WF
Multiset.IsDershowitzMannaLT        -- Mathlib.Order.DershowitzManna
Multiset.wellFounded_isDershowitzMannaLT  -- Mathlib.Order.DershowitzManna
Prod.GameAdd.induction   -- Mathlib.Order.GameAdd (via Mathlib.SetTheory.Ordinal.Basic)
```

### `termination_by` vs `Nat.strongRecOn` for Theorems

For `theorem` statements, Lean does NOT check termination (theorems are not computationally extracted). Therefore:

```lean
-- This works without termination annotation:
theorem foo (φ : Formula) (hn : measure φ = n) : P φ := by
  induction n using Nat.strongRecOn generalizing φ with ...
```

For `def` statements, Lean checks termination. Use:

```lean
-- Option A: explicit termination annotation
def separate (φ : Formula) : Formula :=
  ...
termination_by snce_depth_of_U φ
decreasing_by
  simp [snce_depth_of_U]; omega

-- Option B: WellFounded.fix for complex measures
def separate := (measure snce_depth_of_U).wf.fix (fun φ ih => ...)
```

For the current task (theorem proving), `Nat.strongRecOn` is the right tool and already used correctly.
