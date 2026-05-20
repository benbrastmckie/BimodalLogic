# Implementation Plan: Task #157 -- GHR94-Aligned Oracle Elimination (v25)

- **Task**: 157 - Formalize expressive completeness of {S,U} over integer time
- **Status**: [BLOCKED]
- **Effort**: 6 hours
- **Dependencies**: Phase A completed (plan v22)
- **Research Inputs**: reports/24_blocker-research.md, literature/Gabbay_Hodkinson_Reynolds_1994_Temporal_Logic_Foundations_Vol1_ch10.md
- **Artifacts**: plans/25_ghr94-aligned-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

---

## STRICT COMPLIANCE CONTRACT

**This plan is a BINDING CONTRACT. Implementation agents MUST follow it EXACTLY.**

### Absolute Prohibitions

1. **NO ORACLE PARAMETERS**: Do not add, keep, or thread oracle parameters in any new or modified theorem. The entire point is eliminating them.
2. **NO `all_separable` / `snce_separable` / `untl_separable`**: These are axiom-backed. Never reference them in new or modified code.
3. **NO `sorry`**: Do not introduce any new `sorry`.
4. **NO vacuous definitions**: Do not use `def X := True` or similar.
5. **NO new functions not specified in this plan**.
6. **NO modifying `snce_depth_of_U`, `junction_depth`, or `count_U_subformulas` definitions**: These existing measures are kept as-is.

### Escalation Protocol

If stuck for more than 20 minutes on any single task:
1. STOP immediately
2. Write a handoff to `specs/157_expressive_completeness_su_integer/handoffs/`
3. Mark the phase `[BLOCKED]`

---

## Overview

### Root Cause Analysis (from plan v24 review)

Plan v24 failed because it tried to change the oracle TYPE in 10.2.5 from `junction_depth chi ≤ 1` to `U_nesting_depth chi < d`. This creates a bug at `d = 1`: the oracle is called on formulas with `U_nesting_depth = 1`, but `1 < 1` is false. The deeper issue is that the Lean code's 10.2.5 departs from GHR94 in two ways:

1. **10.2.5 uses IH-on-children + oracle** instead of GHR94's self-contained approach (apply 10.2.4 to the innermost S, reducing S-nesting depth).
2. **10.2.7 uses surface-level abstraction + oracle** instead of GHR94's two-level abstraction (which reduces U-nesting depth for callbacks).

Both departures create oracle dependencies that GHR94 does not have.

### Strategy: Follow GHR94's Dependency Chain Exactly

```
10.2.3 (Cases 1-8)  ← already done
    ↓
10.2.4 (single S, depth-0 U)  ← strengthen to preserve has_single_U_type
    ↓
10.2.5 (single U-type)  ← REWRITE as self-contained (no oracle)
    ↓
10.2.6 (multiple U-types, UND ≤ 1)  ← oracle-free via 10.2.5
    ↓
10.2.7 (no S nested in U)  ← oracle-free via 10.2.6 + extract_innermost_U_type
    ↓
10.2.8 (full separation, JD induction)  ← fix n=1 fallback
```

Each step depends ONLY on the previous step. No circular dependencies. No oracles.

### Key Insight: Self-Contained 10.2.5

GHR94's 10.2.5 says: "D is equivalent to a syntactically separated wff in which U only appears as the formula U(A, B)."

The proof is by induction on k = max S-nesting above U(A,B). At k > 0: "Apply [10.2.4] to each of the most deeply nested S(C, F) in which U(A, B) appear." This reduces k. IH handles the rest. No oracle.

The Lean implementation achieves this by strengthening the IH to produce separated forms that PRESERVE `has_single_U_type`. The critical trick for the `.box` case: return `.imp .bot .bot` (semantically True, same as `.box` over integers). This eliminates the box-normalization mismatch without changing any definitions.

### Adapting GHR94 to the Bimodal System

GHR94's language has {atom, ⊥, →, U, S}. Our `Formula` type adds `.box` (modal necessity), with `int_truth M t (.box _) = True` (degenerate over integer time). This creates one structural issue and requires one adaptation:

**The box loophole**: `is_syntactically_separated (.box _) = true` for any content, but `snce_depth_of_U` passes through `.box` transparently. So `.box (.snce (.untl A B) q)` is syntactically separated yet has `snce_depth_of_U = 1`. A separated formula can have `snce_depth_of_U > 0`.

**The adaptation**: In the self-contained 10.2.5, the `.box a` case returns `.imp .bot .bot` (⊤) instead of `.box a`. Both are True over integers. The output is box-free, separated, and vacuously has `has_single_U_type _ A B`. This ensures ALL IH outputs have `snce_depth_of_U = 0` without altering A, B or any definitions.

**What `.box` does NOT affect**:
- A, B (the U-type args) may contain `.box` — the case proofs only need `is_U_free A` and `is_S_free A`
- `abstract_untl`, `extract_innermost_U_type`, and all callbacks pass through `.box` transparently, matching `is_U_free`, `is_S_free`, `no_S_nested_in_U`
- The 10.2.4 case proofs never introduce `.box` constructors, so their outputs are box-free when inputs (a, q from IH) are box-free
- The duality mechanism for `.untl` in 10.2.8 is unchanged

### Prior Plan Reference

Plan v24 identified the correct infrastructure (`count_U_total`, `extract_innermost_U_type`) but had a flawed oracle-type-change approach. This plan keeps v24's infrastructure (Phase 3) but replaces the flawed Phases 1-2 with the GHR94-aligned self-contained 10.2.5.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Strengthen 10.2.4 to output `has_single_U_type` on the separated form
- Rewrite 10.2.5 as self-contained (no oracle parameter)
- Define `count_U_total`, `extract_innermost_U_type` with companion lemmas
- Create oracle-free `no_S_nested_sep` (combined 10.2.6+10.2.7)
- Fix `all_formulas_separable_aux` n=1 to use oracle-free path
- Replace 9 axioms in SeparationThm.lean with theorems

**Non-Goals**:
- Modifying definitions of `snce_depth_of_U`, `junction_depth`, `count_U_subformulas`
- Restructuring 10.2.8 beyond the n=1 fix
- Preserving `has_single_U_type` through the temporal duality (`.untl` case in 10.2.8)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Strengthening 10.2.4 cases requires extensive proof | H | M | Each case constructs explicit formulas from atoms + U(A,B) + S-terms; `has_single_U_type` follows structurally. Start with Case 1 as template. |
| `snce_depth_of_U C' = 0` for IH output C' requires careful verification | M | L | IH output never contains `.box` wrapping `.snce`-with-U (`.box` returns `.imp .bot .bot`; 10.2.4 output is box-free). Prove by induction on IH construction. |
| `extract_innermost_U_type` termination is complex | M | L | Use `count_U_total` as well-founded measure; the function recurses into `.untl` args only when they're not U-free, strictly decreasing count_U_total. |
| Import reversal creates cycle | H | L | Remove SeparationThm import from Hierarchy BEFORE adding Hierarchy import to SeparationThm |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 3 | -- (independent) |
| 2 | 2 | 1 |
| 3 | 4 | 2, 3 |
| 4 | 5 | 4 |

Phases 1 and 3 are independent and can run in parallel.

---

### Phase 1: Strengthen 10.2.4 to Preserve Single-U-Type [BLOCKED]

**BLOCKER** (Phase 1):
- **What failed**: Task 1.3 asks to prove `is_separable_preserving_U` for Cases 2, 5, 7. Case 2's output (`elim_case_2_gen`) contains `Formula.all_future (Formula.neg A)` which expands to `.imp (.untl (.imp A .bot) (.imp .bot .bot)) .bot`. This `.untl` has args `(¬A, ⊤)`, NOT `(A, B)`. So `has_single_U_type _ A B` is FALSE for the Case 2 output.
- **What was tried**: Traced through `elim_case_2_gen` (Eliminations.lean:354-420), verified `psi_l` contains `G(¬A)` = `¬U(¬A, ⊤)`. Verified `psi1 = case1_psi a q (¬A ∧ ¬B) (¬A)` also has wrong U-type args.
- **Why it's stuck**: GHR94's language has `{atom, ⊥, →, U, S}` where `¬U(A,B)` keeps the same U-type. Our Lean encoding uses `G = ¬U(¬·, ⊤)` which introduces a different U-type. Cases 2, 5-8 use this encoding and therefore do NOT preserve single-U-type.
- **What is needed**: Either (a) rewrite cases 2, 5-8 without `all_future`/`all_past` (massive redesign), or (b) find an alternative approach that doesn't need single-U-type preservation through 10.2.4.
- **Prohibited workarounds**: Do NOT use `sorry`, `def X := True`, or any vacuous placeholder.

**Goal**: Prove that `snce_single_U_depth_one_separable` produces a separated formula that also has `has_single_U_type _ A B`. This is GHR94 Lemma 10.2.4's explicit conclusion: "U only appears as the formula U(A, B)."

**GHR94 Reference**: Lemma 10.2.4, p. 575: "S(C, F) is equivalent to a syntactically separated wff in which U only appears as the formula U(A, B)."

**Tasks**:

- [ ] Task 1.1: Define the stronger result type
  - **File**: `Hierarchy.lean`
  - **Location**: Before `snce_single_U_depth_one_separable` (before line 1881)
  - **Code**:
    ```lean
    /-- Separability result that also preserves single-U-type.
        GHR94 10.2.4/10.2.5 produce separated forms where U only appears as U(A,B). -/
    def is_separable_preserving_U (phi A B : Formula) : Prop :=
      ∃ psi, is_syntactically_separated psi = true ∧
             has_single_U_type psi A B ∧ int_equiv phi psi
    ```

- [ ] Task 1.2: Prove `is_separable_preserving_U` for Case 1
  - **File**: `Hierarchy.lean`
  - **Location**: After `case1_separable_gen`
  - **Statement**: Same hypotheses as `case1_separable_gen`, conclusion `is_separable_preserving_U`
  - **Proof strategy**: The Case 1 output formula is:
    ```
    S(a, q) ∧ S(a, B) ∧ B ∧ U(A, B)
    ∨ [A ∧ S(a, B) ∧ S(a, q)]
    ∨ S(A ∧ q ∧ S(a, B) ∧ S(a, q), q)
    ```
    where a, q, A, B are U-free atoms/formulas. All `.untl` nodes in the output have args A, B (only U(A,B) appears). All `.snce` nodes have U-free args (a, q, A, B, S-subterms are all U-free when a, q are U-free). So `has_single_U_type _ A B` holds. Verify by structural induction on the output formula.

- [ ] Task 1.3: Prove `is_separable_preserving_U` for Cases 2, 5, 7 *(deviation: blocked — Case 2 output contains `.all_future (¬A)` which introduces U-type `(¬A, ⊤)` different from `(A, B)`, so `has_single_U_type _ A B` is NOT preserved. See handoff for analysis.)*
  - Same pattern as Task 1.2 for each case used by `snce_single_U_depth_one_separable`.
  - Cases 2, 5, 7 are the cases invoked in the positive and negative branches.

- [ ] Task 1.4: Create `snce_single_U_depth_one_sep_preserving`
  - **File**: `Hierarchy.lean`
  - **Location**: After `snce_single_U_depth_one_separable`
  - **Statement**:
    ```lean
    theorem snce_single_U_depth_one_sep_preserving (C F A B : Formula)
        (hA_sf : is_S_free A = true) (hB_sf : is_S_free B = true)
        (hA_uf : is_U_free A = true) (hB_uf : is_U_free B = true)
        (hsingle_C : has_single_U_type C A B)
        (hsingle_F : has_single_U_type F A B)
        (hdC : snce_depth_of_U C = 0) (hdF : snce_depth_of_U F = 0)
        (hexp_C : has_no_allpast_allfuture C = true)
        (hexp_F : has_no_allpast_allfuture F = true) :
        is_separable_preserving_U (.snce C F) A B
    ```
  - **Proof**: Follow the same structure as `snce_single_U_depth_one_separable` but use the preserving versions of the case lemmas from Tasks 1.2-1.3.

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` -- add `is_separable_preserving_U`, preserving case lemmas, `snce_single_U_depth_one_sep_preserving`

**Verification**:
- `lake build` succeeds
- All new theorems type-check without `sorry`

---

### Phase 2: Rewrite 10.2.5 as Self-Contained [BLOCKED]

**Goal**: Create an oracle-free version of `single_U_formula_separable_noax_param` by strengthening the IH to produce separated forms that preserve `has_single_U_type`. This follows GHR94 Lemma 10.2.5 precisely.

**GHR94 Reference**: Lemma 10.2.5, p. 575-576: "D is equivalent to a syntactically separated wff in which U only appears as the formula U(A, B)." Proof by induction on k = max S-nesting above U(A,B). At k > 0, apply 10.2.4 to innermost S. IH handles the rest.

**Key Insight**: The `.box` case returns `.imp .bot .bot` (semantically True ≡ `.box x` over integers). This eliminates the box-normalization mismatch: the IH output never wraps `.snce`-with-U inside `.box`, so `snce_depth_of_U (IH_output) = 0` for all separated IH outputs.

**Why `snce_depth_of_U = 0` for IH outputs**:
- `.atom`, `.bot`: trivially 0
- `.imp c' d'`: `max(0, 0) = 0` by IH on subterms
- `.box a`: returns `.imp .bot .bot`, which has depth 0
- `.untl A B`: depth 0 by definition
- `.snce C F` via 10.2.4: output is a boolean combination of atoms, U(A,B), and S(X,Y) with U-free X,Y. Each has depth 0. No `.box` in 10.2.4 output.

**Tasks**:

- [ ] Task 2.1: Prove helper: separated + box-free formulas have `snce_depth_of_U = 0`
  - **File**: `Hierarchy.lean`
  - **Statement**:
    ```lean
    /-- A box-free syntactically separated formula has snce_depth_of_U = 0.
        This is the bridge lemma that makes 10.2.5 self-contained: the IH
        produces box-free separated formulas (via the .box → .imp .bot .bot trick),
        and snce_depth_of_U = 0 enables direct application of 10.2.4.

        Note: `is_box_free` is a property of the IH OUTPUTS (which are box-free
        by construction), NOT of A, B or the input formula. A, B (the U-type args)
        may contain .box and are passed to 10.2.4 unchanged — the case proofs only
        require is_U_free A and is_S_free A, not is_box_free A. -/
    private theorem sep_boxfree_depth_zero (psi : Formula)
        (hsep : is_syntactically_separated psi = true)
        (hboxfree : is_box_free psi = true) :
        snce_depth_of_U psi = 0
    ```
  - Requires `is_box_free : Formula → Bool` (returns true iff no `.box` constructor appears).
  - **Proof**: By structural induction. `.snce c d`: `hsep` gives `is_U_free c ∧ is_U_free d`, so the if-branch in `snce_depth_of_U` gives 0. `.untl`: definition gives 0. `.imp`: max of IH results = 0. `.box`: contradicts `hboxfree`. `.atom`, `.bot`: trivially 0.
  - **Why box-free suffices (no has_single_U_type needed)**: The only way `snce_depth_of_U > 0` in a separated formula is `.box (.snce ...)` with U inside. If the formula is box-free, this pattern cannot occur. `has_single_U_type` is irrelevant here.

- [ ] Task 2.2: Prove that 10.2.4 output is box-free
  - **File**: `Hierarchy.lean`
  - **Statement**: `snce_single_U_depth_one_sep_preserving` output has `is_box_free = true`
  - **Proof**: The case proofs construct formulas from atoms, `.imp`, `.untl A B`, `.snce`, `.bot`. No `.box` constructor is ever introduced.
  - Alternative: prove `is_box_free` for each case output formula. Since a, q are U-free (hence no restriction on box-freeness -- actually they're atoms in the original 10.2.3). In the generalized versions, a and q might contain `.box`. Hmm.
  - **Fallback**: If the case outputs aren't always box-free (because input a, q might contain `.box`), then box-normalize the 10.2.4 output instead. Use `replace_box_with_top` on the 10.2.4 output and prove `has_single_U_type (replace_box_with_top psi) (replace_box_with_top A) (replace_box_with_top B)`.

- [ ] Task 2.3: Create `single_U_formula_separable_no_oracle`
  - **File**: `Hierarchy.lean`
  - **Location**: After `single_U_formula_separable_noax_param`
  - **Statement**:
    ```lean
    /-- GHR94 Lemma 10.2.5 (oracle-free):
        If A, B are S-free and U-free, and phi has single U-type U(A,B),
        then phi is separable. No oracle parameter.

        Proof by strong induction on snce_depth_of_U.
        The IH produces separated forms with has_single_U_type, enabling
        direct application of 10.2.4 at the .snce case without any oracle.
        The .box case returns .imp .bot .bot (True over integers). -/
    theorem single_U_formula_separable_no_oracle (phi A B : Formula)
        (hA_sf : is_S_free A = true) (hB_sf : is_S_free B = true)
        (hA_uf : is_U_free A = true) (hB_uf : is_U_free B = true)
        (h_single : has_single_U_type phi A B) :
        is_separable phi
    ```
  - **Proof architecture**:
    ```lean
    := by
      -- Internal helper with stronger IH
      suffices h : ∀ (n : Nat) (ψ : Formula), snce_depth_of_U ψ ≤ n →
          has_single_U_type ψ A B →
          is_separable_preserving_U ψ A B from
        let ⟨psi, hsep, _, hequiv⟩ := h (snce_depth_of_U phi) phi (le_refl _) h_single
        ⟨psi, hsep, hequiv⟩
      intro n
      induction n using Nat.strongRecOn with | ind n ih_depth =>
      intro ψ hdepth h_single_ψ
      induction ψ with
      | atom a => exact ⟨.atom a, rfl, by simp [has_single_U_type], int_equiv_refl _⟩
      | bot => exact ⟨.bot, rfl, by simp [has_single_U_type], int_equiv_refl _⟩
      | imp c d ih_c ih_d =>
        -- IH gives c', d' with sep + single-U-type
        have hle_c := ... -- snce_depth_of_U c ≤ n
        have hle_d := ...
        obtain ⟨c', hc_sep, hc_single, hc_equiv⟩ := ih_c hle_c h_single_ψ.1
        obtain ⟨d', hd_sep, hd_single, hd_equiv⟩ := ih_d hle_d h_single_ψ.2
        exact ⟨.imp c' d', by simp [is_syntactically_separated, hc_sep, hd_sep],
               ⟨hc_single, hd_single⟩,
               imp_congr hc_equiv hd_equiv⟩
      | box a =>
        -- KEY: return .imp .bot .bot (True ≡ .box a over integers)
        exact ⟨.imp .bot .bot,
               by simp [is_syntactically_separated],
               ⟨trivial, trivial⟩,  -- has_single_U_type vacuously
               box_equiv_true a⟩     -- .box a ≡ .imp .bot .bot over Z
      | untl c d =>
        -- h_single gives c = A, d = B
        have ⟨hc, hd⟩ := h_single_ψ; subst hc; subst hd
        exact ⟨.untl A B,
               by simp [is_syntactically_separated, hA_sf, hB_sf],
               ⟨rfl, rfl⟩,
               int_equiv_refl _⟩
      | snce C F ih_C ih_F =>
        by_cases huf : is_U_free C = true ∧ is_U_free F = true
        · -- U-free: already separated
          exact ⟨.snce C F,
                 by simp [is_syntactically_separated, huf.1, huf.2],
                 h_single_ψ,
                 int_equiv_refl _⟩
        · -- Contains U: depth ≥ 1
          -- Step 1: IH on C, F (structurally smaller, same n)
          have hle_C : snce_depth_of_U C ≤ n := ...
          have hle_F : snce_depth_of_U F ≤ n := ...
          obtain ⟨C', hC_sep, hC_single, hC_equiv⟩ := ih_C hle_C h_single_ψ.1
          obtain ⟨F', hF_sep, hF_single, hF_equiv⟩ := ih_F hle_F h_single_ψ.2
          -- Step 2: C', F' have snce_depth_of_U = 0
          -- (from sep_single_U_boxfree_depth_zero or equivalent)
          have hdC' : snce_depth_of_U C' = 0 := ...
          have hdF' : snce_depth_of_U F' = 0 := ...
          -- Step 3: Apply strengthened 10.2.4
          have h_sep := snce_single_U_depth_one_sep_preserving C' F' A B
            hA_sf hB_sf hA_uf hB_uf hC_single hF_single hdC' hdF'
            (has_no_allpast_allfuture_true C') (has_no_allpast_allfuture_true F')
          obtain ⟨psi, hpsi_sep, hpsi_single, hpsi_equiv⟩ := h_sep
          -- Step 4: Chain equivalence
          exact ⟨psi, hpsi_sep, hpsi_single,
                 int_equiv_trans (snce_congr hC_equiv hF_equiv) hpsi_equiv⟩
    ```
  - **Important**: The `.snce` case uses the STRUCTURAL IH (`ih_C`, `ih_F`), not the strong recursion IH (`ih_depth`). The strong recursion on `n` is only needed to bound `snce_depth_of_U`. In GHR94 terms: at the `.snce C F` node, C and F have smaller `snce_depth_of_U`, so the IH applies at the same `n` level. The strong recursion is technically not needed since structural induction suffices — but using `Nat.strongRecOn` simplifies the depth bookkeeping.
  - **Actually**: The structural IH gives `is_separable_preserving_U` for structurally smaller formulas at the SAME `n`. This is valid because `snce_depth_of_U C ≤ n` (from depth monotonicity) and the structural IH is within the `Nat.strongRecOn` body.

- [ ] Task 2.4: Prove `box_equiv_true` helper
  - **File**: `Hierarchy.lean`
  - **Statement**: `int_equiv (.box a) (.imp .bot .bot)` for any `a`
  - **Proof**: Both sides are True under `int_truth` over integers.

- [ ] Task 2.5: Handle the `snce_depth_of_U C' = 0` proof
  - Either via `sep_single_U_boxfree_depth_zero` (Task 2.1) or by proving directly that the IH construction produces formulas with depth 0. The direct proof observes:
    - At `.atom`, `.bot`: output has depth 0 ✓
    - At `.imp c' d'`: `max(0, 0) = 0` ✓
    - At `.box`: output is `.imp .bot .bot`, depth 0 ✓
    - At `.untl A B`: depth 0 by definition ✓
    - At `.snce` via 10.2.4: output is boolean combo of atoms, U(A,B), S(X,Y)-U-free. Each has depth 0. ✓
  - If 10.2.4 output contains `.box` (from input a, q that might have `.box`), apply `replace_box_with_top` to the 10.2.4 output and adjust the equivalence chain. The `replace_box_preserves_single_U_type` lemma (line 2259) handles the single-U-type tracking.

**Timing**: 2 hours

**Depends on**: Phase 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` -- add helpers, create `single_U_formula_separable_no_oracle`

**Verification**:
- `lake build` succeeds
- `single_U_formula_separable_no_oracle` has NO oracle parameter
- No `sorry`

---

### Phase 3: New Measure Infrastructure [NOT STARTED]

**Goal**: Define `count_U_total`, `extract_innermost_U_type`, and companion lemmas needed for the oracle-free 10.2.7.

**GHR94 Reference**: Lemma 10.2.7, p. 577-578. GHR94 uses "the level of nesting of U in U(Aᵢ, Bᵢ) must be strictly greater than that in its subformula U(Xᵢⱼ, Yᵢⱼ)" — our `extract_innermost_U_type` + `count_U_total` captures this one-at-a-time.

**Tasks**:

- [ ] Task 3.1: Define `count_U_total` in `Defs.lean`
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Defs.lean`
  - **Location**: After `count_U_subformulas` (after line 371)
  - **Code**:
    ```lean
    def count_U_total : Formula → Nat
      | .atom _ => 0
      | .bot => 0
      | .imp φ ψ => count_U_total φ + count_U_total ψ
      | .box φ => count_U_total φ
      | .untl φ ψ => 1 + count_U_total φ + count_U_total ψ
      | .snce φ ψ => count_U_total φ + count_U_total ψ
    ```

- [ ] Task 3.2: Define `contains_untl_deep` in `Hierarchy.lean`
  - **File**: `Hierarchy.lean`
  - **Location**: After `abstract_untl_count_lt_of_contains_surface` (after line 1111)
  - **Code**:
    ```lean
    def contains_untl_deep : Formula → Formula → Formula → Prop
      | .atom _, _, _ => False
      | .bot, _, _ => False
      | .imp c d, A, B => contains_untl_deep c A B ∨ contains_untl_deep d A B
      | .box c, A, B => contains_untl_deep c A B
      | .untl c d, A, B => (c = A ∧ d = B) ∨ contains_untl_deep c A B ∨ contains_untl_deep d A B
      | .snce c d, A, B => contains_untl_deep c A B ∨ contains_untl_deep d A B
    ```

- [ ] Task 3.3: Prove `abstract_untl_count_total_le` and `abstract_untl_count_total_lt_of_contains_deep`
  - Non-increase: `count_U_total (abstract_untl phi A B p) ≤ count_U_total phi`
  - Strict decrease when `contains_untl_deep`: `count_U_total (abstract_untl phi A B p) < count_U_total phi`
  - **Proof**: Same pattern as `abstract_untl_count_le` / `abstract_untl_count_lt_of_contains_surface` but recurses into `.untl` children.

- [ ] Task 3.4: Define `extract_innermost_U_type` and companion lemmas
  - **File**: `Hierarchy.lean`
  - **Code**: As specified in plan v24, Task 1.5 (the function definition is correct).
  - **Helper**: `s_free_implies_no_S_nested` (~5 LOC)
  - **Companion lemmas**:
    - `extract_innermost_U_type_S_free`: result args are S-free
    - `extract_innermost_U_type_U_free`: result args are U-free (KEY: the `.untl` case only returns when both args are U-free)
    - `extract_innermost_U_type_contains_deep`: result satisfies `contains_untl_deep`

- [ ] Task 3.5: Prove `contains_untl_surface_implies_deep`
  - If `contains_untl_surface phi A B` then `contains_untl_deep phi A B`.
  - ~5 LOC structural induction.

**Timing**: 1.5 hours

**Depends on**: none (independent of Phase 1)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Defs.lean` -- add `count_U_total`
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` -- add `contains_untl_deep`, decrease lemmas, `extract_innermost_U_type`, companion lemmas

**Verification**:
- `lake build` succeeds

---

### Phase 4: Oracle-Free `no_S_nested_sep` [BLOCKED]

**BLOCKER** (Phase 4):
- **What failed**: The double induction on `(U_nesting_depth, count_U_total)` has a termination gap. At `UND ≤ 1`, `lemma_10_2_6_no_oracle` internally calls `single_U_formula_separable_noax_param`. The oracle from that function at `snce_depth_of_U ≥ 2` produces formulas with unbounded `U_nesting_depth`, breaking the outer induction.
- **What was tried**: (1) Attempted to show oracle formula has `UND ≤ 1` -- false, constructed counterexample where callback `.snce (subst c p (.untl A B)) (subst d p (.untl A B))` with c = `.snce (.snce (.atom p) (.atom x)) (.atom y)` gives `snce_depth_of_U = 2`. (2) Attempted fuel-based approach -- infinite regress. (3) Attempted lex order `(JD, count_U, sizeOf)` -- oracle formulas can be larger.
- **Why it's stuck**: The oracle chain from `single_U_formula_separable_noax_param` can grow arbitrarily deep due to back-substitution creating nested `.snce` with U inside. No simple well-founded measure captures the termination.
- **What is needed**: A fundamentally different termination argument. Possible approaches: (a) restructure 10.2.5 to avoid the oracle chain, (b) use GHR94-faithful case proofs that don't introduce new U-types, (c) find a refined measure that captures the bounded nesting.
- **Prohibited workarounds**: Do NOT use `sorry`, `def X := True`, or any vacuous placeholder.

**Goal**: Create a single oracle-free theorem combining 10.2.6 and 10.2.7 logic. Uses oracle-free 10.2.5 (Phase 2) at `U_nesting_depth ≤ 1`, and `extract_innermost_U_type` (Phase 3) at `U_nesting_depth ≥ 2`.

**GHR94 Reference**:
- 10.2.6 (p. 576-577): Induction on n = number of U-types. At n > 1, abstract all but one U-type, apply 10.2.5, back-substitute, IH on past parts.
- 10.2.7 (p. 577-578): Induction on U-nesting depth. At depth > 1, flatten inner U-subformulas from outer U-type args, apply 10.2.6, back-substitute, IH on past parts.

**Our encoding**: Double strong induction on `(U_nesting_depth, count_U_total)`. This captures both 10.2.6 (inner induction on count) and 10.2.7 (outer induction on nesting depth) in one theorem. Abstracting one innermost U at a time (via `extract_innermost_U_type`) decreases `count_U_total` for the inner IH. Callbacks from back-substitution have `U_nesting_depth ≤ 1` (since the extracted U has U-free args), handled by the outer IH.

**Tasks**:

- [ ] Task 4.1: Create oracle-free 10.2.6 wrapper
  - **File**: `Hierarchy.lean`
  - **Location**: After `lemma_10_2_6_self_contained_param`
  - **Statement**:
    ```lean
    /-- GHR94 Lemma 10.2.6 (oracle-free):
        A formula with no_S_nested_in_U and U_nesting_depth ≤ 1 is separable.
        Uses oracle-free 10.2.5 for the single-U-type callback. -/
    theorem lemma_10_2_6_no_oracle (phi : Formula)
        (hns : no_S_nested_in_U phi)
        (hd : U_nesting_depth phi ≤ 1) :
        is_separable phi
    ```
  - **Proof**: Same structure as `lemma_10_2_6_self_contained_param` but:
    - Replace the oracle parameter with direct calls to `single_U_formula_separable_no_oracle`
    - Use `subst_in_separated_separable_typed` with callback `= fun χ _hns hsingle => single_U_formula_separable_no_oracle χ AB.1 AB.2 hAB_sf.1 hAB_sf.2 hAB_uf.1 hAB_uf.2 hsingle`
    - This works because `extract_U_type_U_free` (line 2313) gives U-free args at `U_nesting_depth ≤ 1`, and the callback has `has_single_U_type chi AB.1 AB.2`

- [ ] Task 4.2: Create `no_S_nested_sep`
  - **File**: `Hierarchy.lean`
  - **Location**: After `no_S_nested_in_U_separable_direct_param`
  - **Statement**:
    ```lean
    /-- GHR94 Lemmas 10.2.6 + 10.2.7 (oracle-free):
        A formula with no_S_nested_in_U is separable.
        Double strong induction on (U_nesting_depth, count_U_total).

        At U_nesting_depth ≤ 1: apply lemma_10_2_6_no_oracle.
        At U_nesting_depth ≥ 2: extract innermost U(X,Y) with U-free X,Y,
        abstract globally, inner IH on count_U_total, back-substitute via
        subst_in_separated_separable_depth. Callbacks have U_nesting_depth ≤ 1
        (since X,Y are U-free), handled by outer IH. -/
    theorem no_S_nested_sep (phi : Formula)
        (hns : no_S_nested_in_U phi) : is_separable phi
    ```
  - **Proof architecture**:
    ```lean
    := by
      have : ∀ (d c : Nat) (psi : Formula), U_nesting_depth psi ≤ d →
          count_U_total psi ≤ c → no_S_nested_in_U psi → is_separable psi := by
        intro d
        induction d using Nat.strongRecOn with | ind d ih_d =>
        intro c
        induction c using Nat.strongRecOn with | ind c ih_c =>
        intro psi hd hc hns_psi
        by_cases huf : is_U_free psi = true
        · -- U-free: trivially separated
          exact separated_imp_separable psi (restricted_u_free_separated psi _ huf)
        · by_cases hd1 : U_nesting_depth psi ≤ 1
          · -- UND ≤ 1: apply lemma_10_2_6_no_oracle
            exact lemma_10_2_6_no_oracle psi hns_psi hd1
          · -- UND ≥ 2: extract innermost U with U-free args
            push_neg at hd1
            -- extract_innermost_U_type gives (X, Y) with X, Y U-free and S-free
            -- abstract_untl psi X Y p gives psi' with count_U_total < count_U_total psi
            -- ih_c on psi' (same d, smaller c) gives psi' separable
            -- subst_in_separated_separable_depth for back-substitution
            -- callback has no_S_nested_in_U and U_nesting_depth ≤ 1
            -- ih_d at d' ≤ 1 < d handles callback
            sorry -- detailed proof follows pattern of no_S_nested_in_U_separable_direct_param
      exact this (U_nesting_depth phi) (count_U_total phi) phi (le_refl _) (le_refl _) hns
    ```
  - **UND ≥ 2 case detail**:
    1. `extract_innermost_U_type psi huf' hns_psi` → `(X, Y)` with `is_U_free X ∧ is_U_free Y` and `is_S_free X ∧ is_S_free Y`
    2. `abstract_untl psi X Y p` → `psi'`
    3. `abstract_untl_count_total_lt_of_contains_deep` → `count_U_total psi' < count_U_total psi`
    4. `abstract_untl_preserves_no_S_nested` → `no_S_nested_in_U psi'`
    5. `ih_c (count_U_total psi') (hc ▸ ...) psi' ... hns'` → `is_separable psi'`
    6. Get separated `sep` with `int_equiv psi' sep`
    7. `abstract_subst_roundtrip` → `subst_formula psi' p (.untl X Y) = psi`
    8. `subst_in_separated_separable_depth sep p X Y hX_sf hY_sf hX_uf hY_uf hsep_sep callback`
       where `callback = fun chi hns_chi hd_chi => ih_d 1 (by omega) (count_U_total chi) chi (by omega) (le_refl _) hns_chi`
    9. Callback works because: `U_nesting_depth chi ≤ 1` (from `callback_U_nesting_depth_le_one`, since X, Y are U-free) and `1 < d` (since `U_nesting_depth psi ≥ 2` and `d ≥ U_nesting_depth psi ≥ 2`).

- [ ] Task 4.3: Update `no_S_nested_in_U_separable_direct` wrapper
  - **File**: `Hierarchy.lean`
  - **Location**: Line 2655
  - Change to call `no_S_nested_sep` instead of `no_S_nested_in_U_separable_direct_param` with `all_separable`.

**Timing**: 1.5 hours

**Depends on**: Phases 2 and 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`

**Verification**:
- `lake build` succeeds
- `no_S_nested_sep` has NO oracle parameter
- No `sorry`

---

### Phase 5: Fix 10.2.8, Import Reversal, Axiom Replacement [BLOCKED]

**Goal**: Replace the n=1 fallback in `all_formulas_separable_aux` with `no_S_nested_sep`, reverse the import, and replace axioms with theorems.

**GHR94 Reference**: Lemma 10.2.8 (p. 578-580) uses 10.2.7 at junction depth ≥ 1. Our fix eliminates the n=1 special case by using the oracle-free `no_S_nested_sep`.

**Tasks**:

- [ ] Task 5.1: Replace n=1 `.snce` fallback
  - **File**: `Hierarchy.lean`
  - **Location**: Line 2783-2784
  - OLD: `exact no_S_nested_in_U_separable_direct (.snce χa χb) hns`
  - NEW: `exact no_S_nested_sep (.snce χa χb) hns`

- [ ] Task 5.2: Replace n=1 `.untl` fallback
  - **File**: `Hierarchy.lean`
  - **Location**: Line 2820
  - OLD: `exact no_S_nested_in_U_separable_direct _ hns_S`
  - NEW: `exact no_S_nested_sep _ hns_S`

- [ ] Task 5.3: Remove remaining `all_separable` references from `Hierarchy.lean`
  - Audit all occurrences. Replace backward-compatible wrappers that use `all_separable` as oracle. Goal: ZERO references to `all_separable` in Hierarchy.lean.

- [ ] Task 5.4: Remove `import SeparationThm` from Hierarchy.lean
  - **File**: `Hierarchy.lean`, Line 2
  - Delete: `import Bimodal.Metalogic.WeakCanonical.Separation.SeparationThm`

- [ ] Task 5.5: Verify `lake build` for Hierarchy.lean

- [ ] Task 5.6: Add Hierarchy import to SeparationThm.lean
  - **File**: `SeparationThm.lean`, after existing imports
  - Add: `import Bimodal.Metalogic.WeakCanonical.Separation.Hierarchy`

- [ ] Task 5.7: Replace 4 temporal closure axioms with theorems
  - `all_past_separable` (line 89): `theorem ... := all_formulas_separable_aux _ _`
  - `all_future_separable` (line 93): same pattern
  - `untl_separable` (line 97): same pattern
  - `snce_separable` (line 101): same pattern
  - Note: the `is_separable φ` hypothesis is UNUSED. The result is unconditional.

- [ ] Task 5.8: Replace 4 proper separation axioms with theorems
  - Lines 220-237: derive from non-proper versions + `proper_separation_preserves_atoms`

- [ ] Task 5.9: Verify only `proper_separation_preserves_atoms` remains as axiom
  - `grep -n "^axiom" SeparationThm.lean`

- [ ] Task 5.10: Final verification
  - `lake build` succeeds
  - `lean_verify all_formulas_separable` shows only standard Lean axioms + `proper_separation_preserves_atoms`

**Timing**: 1 hour

**Depends on**: Phase 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` -- remove import, remove `all_separable` refs
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` -- add import, replace axioms

**Verification**:
- `lake build` succeeds with zero errors
- `grep -rn "^axiom" SeparationThm.lean` returns at most 1 line
- No `sorry`: `grep -rn "sorry" Hierarchy.lean SeparationThm.lean` returns 0

---

## Testing & Validation

- [ ] `lake build` succeeds with zero errors
- [ ] `grep -rn "^axiom" SeparationThm.lean` returns at most 1 line (`proper_separation_preserves_atoms`)
- [ ] `lean_verify all_formulas_separable` shows only standard Lean axioms
- [ ] No `sorry`: `grep -rn "sorry" Hierarchy.lean SeparationThm.lean Defs.lean` returns 0

## Artifacts & Outputs

- `plans/25_ghr94-aligned-plan.md` (this file)
- Modified `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Defs.lean`
- Modified `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean`
- Modified `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean`

## Rollback/Contingency

- `git stash` or `git checkout` the three modified files
- Phase 1 is additive (new theorems alongside existing ones), safe to keep
- Phase 3 is additive (new definitions and lemmas), safe to keep
- If Phase 2 blocks on `snce_depth_of_U = 0` for IH outputs, fall back to box-normalizing the 10.2.4 output and tracking `has_single_U_type _ (replace_box A) (replace_box B)` (more complex but still correct)
- If Phase 4 blocks on `extract_innermost_U_type` termination, use the existing surface-level `extract_U_type` at UND ≥ 2 with `count_U_total` as measure (same as plan v24's approach minus the oracle type change)
