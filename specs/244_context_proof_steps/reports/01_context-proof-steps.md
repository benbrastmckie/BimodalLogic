# Research Report: Context Proof Steps (Task 244)

## Executive Summary

All 310 registered theorems in the proof step export pipeline derive from **empty context** (`[] ⊢ φ`), meaning the `assumption` and `weakening` inference rules never appear in the extracted training data. This report identifies why, catalogs the infrastructure needed to add contextual theorems, and proposes a concrete approach for creating 50+ registrable contextual derivations that exercise both rules.

**Key finding**: The primary obstacle is computability. Most existing contextual theorems (in `Propositional/Core.lean`, `Propositional/Connectives.lean`, `Propositional/Reasoning.lean`) are wrapped in `noncomputable section` due to the deduction theorem import, but many do not actually require noncomputability. A new dedicated file can house computable contextual derivations built entirely from the computable `DerivationTree` constructors.

## 1. How Theorems Are Currently Registered

### Registry Architecture

The theorem registry lives in `Theories/Bimodal/Automation/ProofStepExport.lean`. Each theorem is a `TheoremEntry` with:
- A `name : String` for identification
- An `extract : Unit -> List ProofStep` thunk that evaluates the `DerivationTree` and walks it to produce proof steps

The `mkEntry` helper creates entries:
```lean
private def mkEntry (name : String) {fc : FrameClass} {Γ : Context} {φ : Formula}
    (tree : DerivationTree fc Γ φ) : TheoremEntry
```

Note: `mkEntry` accepts any context `Γ`, not just `[]`. The infrastructure already supports non-empty contexts in principle.

### Current Composition (310 entries)

| Category | Count | Context |
|----------|-------|---------|
| Original standalone theorems | 36 | `[]` |
| G-wrapped (temporal_necessitation) | 36 | `[]` |
| H-wrapped (temporal_duality o temporal_necessitation) | 36 | `[]` |
| GG-double-wrapped | 12 | `[]` |
| GGG-triple-wrapped | 7 | `[]` |
| Temporal axiom instantiations | 18 | `[]` |
| Multi-instantiation variants | 80 | `[]` |
| Deep temporal chains (depth 4-20) | 85 | `[]` |
| **Total** | **310** | **All `[]`** |

### Why All Contexts Are Empty

1. **Theorems are formalized as theorems**: The project follows the standard modal logic convention where derived results are stated as `⊢ φ` (derivable from no assumptions), not `Γ ⊢ φ` (derivable from context).

2. **Necessitation/duality rules require empty context**: The three temporal wrapping strategies (G, H, GG/GGG) all use `temporal_necessitation` and `temporal_duality`, which only apply to derivations from `[]`:
   ```lean
   | necessitation (φ : Formula)
       (d : DerivationTree fc [] φ) : DerivationTree fc [] (Formula.box φ)
   ```

3. **Computability barrier**: The existing contextual theorems (`ecq`, `ldi`, `rdi`, `lce`, `rce`, `de`, `reverse_deduction`, `classical_merge`) are all inside `noncomputable section` blocks. The `extractStepSequence` function pattern-matches on `DerivationTree` (a `Type`, not `Prop`), so it requires computable derivation tree values. Noncomputable values cannot be evaluated at runtime.

### Extraction Pipeline

`extractStepSequence` recursively walks the `DerivationTree` and emits one `ProofStep` per node:
- The `context` field records the current context `Γ`
- The `rule` field records which constructor was used
- Already handles `assumption` and `weakening` cases correctly

So the extraction infrastructure is ready -- the only gap is the absence of registrable computable contextual derivations.

## 2. How the Derivation System Handles Contexts

### DerivationTree Type (7 constructors)

```lean
inductive DerivationTree (fc : FrameClass) : Context -> Formula -> Type where
  | axiom          -- Γ ⊢ φ if φ is an axiom instance
  | assumption     -- Γ ⊢ φ if φ ∈ Γ
  | modus_ponens   -- Γ ⊢ ψ if Γ ⊢ φ → ψ and Γ ⊢ φ
  | necessitation  -- [] ⊢ □φ if [] ⊢ φ   (EMPTY CONTEXT ONLY)
  | temporal_necessitation  -- [] ⊢ Gφ if [] ⊢ φ   (EMPTY CONTEXT ONLY)
  | temporal_duality       -- [] ⊢ swap(φ) if [] ⊢ φ  (EMPTY CONTEXT ONLY)
  | weakening      -- Δ ⊢ φ if Γ ⊢ φ and Γ ⊆ Δ
```

### Context Rules

- **assumption**: `φ ∈ Γ` implies `Γ ⊢ φ`. This is the "pull from context" rule.
- **weakening**: `Γ ⊢ φ` and `Γ ⊆ Δ` implies `Δ ⊢ φ`. This adds extra unused assumptions.
- **modus_ponens**: Works in any context (both premises must share the same context).
- **axiom**: Works in any context (axioms are universally valid).
- **necessitation/temporal rules**: Only work with empty context `[]`.

### Key Interaction Patterns

1. **Weakening axioms into context**: The most common pattern is `DerivationTree.weakening [] Γ φ (axiom_proof) (List.nil_subset Γ)`. This takes an axiom (proved from `[]`) and weakens it to any `Γ`.

2. **Assumption then modus ponens**: To use a contextual assumption, pull it with `.assumption` then apply `.modus_ponens`.

3. **Deduction theorem**: `(A :: Γ) ⊢ B` implies `Γ ⊢ A → B`. This is noncomputable because the proof uses `Classical.propDecidable` for membership decisions. However, the *reverse* direction (`reverse_deduction`) is computable.

## 3. Categories of Theorems Requiring Non-Empty Contexts

### Category A: Direct Contextual Derivations (Computable)

These directly construct `DerivationTree` values using assumption, modus ponens, weakening, and axiom constructors. No deduction theorem needed.

**A1. Modus Ponens in Context**
```
[p → q, p] ⊢ q        (2 assumptions + 1 MP)
[p → q, q → r, p] ⊢ r (3 assumptions + 2 MP)
[p, p → q → r, q] ⊢ r (3 assumptions + 2 MP)
```

**A2. Ex Contradictione Quodlibet (ECQ)**
```
[A, ¬A] ⊢ B            (assumption + MP + weakening + axiom)
```

**A3. Left/Right Disjunction Introduction**
```
[A] ⊢ A ∨ B            (assumption + weakening + axiom + MP chain)
[B] ⊢ A ∨ B            (assumption + weakening + axiom + MP)
```

**A4. Conjunction Projection**
```
[A ∧ B] ⊢ A            (assumption + weakening + axiom + MP)
[A ∧ B] ⊢ B            (assumption + weakening + axiom + MP)
```

**A5. Axiom Application in Context**
```
Γ ⊢ φ where φ is an axiom instance and Γ is non-empty
(Uses weakening [] → Γ for each axiom used, plus assumptions from Γ)
```

### Category B: Modal/Temporal in Context (Computable)

**B1. Box Elimination in Context** (using modal T axiom)
```
[□A] ⊢ A               (assumption + weakening + axiom(modal_t) + MP)
[□A] ⊢ □□A             (assumption + weakening + axiom(modal_4) + MP)
[□A, □B] ⊢ □A ∧ □B     (uses pairing in context)
```

**B2. Temporal Axiom Application in Context**
```
[G(A → B), G(A)] ⊢ G(B)  (temporal K distribution in context)
[□A] ⊢ G(A)              (modal_future + T axiom in context)
```

**B3. Mixed Modal-Temporal in Context**
```
[□A] ⊢ G(□A)             (temp_future_derived in context)
[□A] ⊢ H(A)              (box_to_past weakened to context)
```

### Category C: Deeper Contextual Chains (Computable)

**C1. Multi-Step Propositional Chains**
```
[A → B, B → C, C → D, A] ⊢ D    (4 assumptions + 3 MP)
[A, A → B, B → C] ⊢ C ∧ A        (assumptions + MPs + pairing in context)
```

**C2. Weakening Variants**
```
For any theorem ⊢ φ, we can generate [ψ₁, ..., ψₙ] ⊢ φ
by weakening from [] to [ψ₁, ..., ψₙ].
```

**C3. Nested Weakening**
```
[A] ⊢ B  implies  [A, C] ⊢ B  (weakening + original derivation)
```

### Category D: G/H Wrapping of Contextual Theorems

G/H wrapping does NOT directly apply to contextual theorems because `temporal_necessitation` and `temporal_duality` require empty context. However, we can create variants:

**D1. Contextual Versions of Wrapped Theorems**
Given `⊢ G(A → A)`, weaken to `[B] ⊢ G(A → A)`.

**D2. Use Axioms to Create Temporal Context Results**
```
[G(A → B)] ⊢ G(A) → G(B)   (temporal K in context)
[H(A → B)] ⊢ H(A) → H(B)   (past K in context)
```

## 4. How G/H Wrapping Would Work for Contextual Theorems

### Direct Wrapping: Not Applicable

Since `temporal_necessitation` requires `DerivationTree fc [] φ`, we cannot wrap `Γ ⊢ φ` (for non-empty `Γ`) into `Γ ⊢ G(φ)`.

### Workaround Strategies

**Strategy 1: Wrap-then-Weaken**
For each theorem `⊢ φ`:
1. G-wrap: `⊢ G(φ)`
2. Weaken: `Γ ⊢ G(φ)` for various non-empty `Γ`

This produces weakening steps but the core derivation is still from `[]`.

**Strategy 2: Temporal Axiom Derivations in Context**
Use temporal K distribution axiom in context:
```
[G(A → B), G(A)] ⊢ G(B)
```
This is a genuine contextual temporal derivation with assumption + weakening + MP.

**Strategy 3: Generalized Necessitation in Context**
The generalized modal K rule gives `□Γ ⊢ □φ` from `Γ ⊢ φ`.
For contextual `Γ ⊢ φ`, this produces `□Γ ⊢ □φ` -- a non-empty context derived result.
However, this uses the deduction theorem (noncomputable). We can replicate specific instances computably by hand.

### Recommended Wrapping Pattern for This Task

For each base contextual theorem `Γ ⊢ φ`, create:
1. The base version `Γ ⊢ φ` (exercises assumption)
2. Weakened versions `Δ ⊢ φ` where `Γ ⊂ Δ` (exercises weakening)
3. "Theorem weakened to context" versions where `⊢ ψ` becomes `Γ ⊢ ψ` (pure weakening)

## 5. Infrastructure Gaps

### Gap 1: Computability of Existing Contextual Theorems

**Problem**: All existing contextual theorems in `Propositional/Core.lean` (ecq, ldi, rdi), `Propositional/Connectives.lean` (classical_merge, iff_intro, lce, rce), and `Propositional/Reasoning.lean` (de, or_elim) are inside `noncomputable section` blocks.

**Root Cause**: The files import `DeductionTheorem.lean` (which uses `Classical.propDecidable`). The `noncomputable section` is a blanket wrapper even though many individual definitions (like `ecq`, `ldi`, `rdi`) only use computable constructors.

**Solution**: Create a new file `Theories/Bimodal/Theorems/ContextualProofs.lean` that:
- Imports only `Bimodal.ProofSystem.Derivation` and `Bimodal.Theorems.Combinators`
- Does NOT import `DeductionTheorem`
- Does NOT use `noncomputable section`
- Contains hand-constructed computable contextual derivations

### Gap 2: Registry Accepts Non-Empty Contexts (Already Supported)

The `mkEntry` helper already accepts any `Γ : Context`. No changes needed to `ProofStepExport.lean` infrastructure, only new entries.

### Gap 3: Extraction Handles All 7 Rules (Already Supported)

`extractStepSequence` already handles all 7 `DerivationTree` constructors including `assumption` and `weakening`. The `ProofStep.toJson` serializes the context field. No extraction changes needed.

### Gap 4: Import Chain for Registration

The new `ContextualProofs.lean` must be imported by `ProofStepExport.lean`. This requires adding one import line:
```lean
import Bimodal.Theorems.ContextualProofs
```

## 6. Recommended Approach

### Phase 1: Create Computable Contextual Theorems

Create `Theories/Bimodal/Theorems/ContextualProofs.lean` with the following categories:

**Category A: Basic Propositional (12 theorems)**
1. `mp_in_context` : `[p → q, p] ⊢ q`
2. `mp_chain_2` : `[p → q, q → r, p] ⊢ r`
3. `mp_chain_3` : `[p → q, q → r, r → s, p] ⊢ s`
4. `ecq_computable` : `[A, ¬A] ⊢ B` (reimplement without noncomputable)
5. `ldi_computable` : `[A] ⊢ A ∨ B`
6. `rdi_computable` : `[B] ⊢ A ∨ B`
7. `conj_proj_left` : `[A ∧ B] ⊢ A`
8. `conj_proj_right` : `[A ∧ B] ⊢ B`
9. `identity_in_ctx` : `[A] ⊢ A`
10. `apply_in_ctx` : `[A, A → B → C, B] ⊢ C`
11. `conj_intro_ctx` : `[A, B] ⊢ A ∧ B`
12. `weakened_axiom` : `[ψ] ⊢ □p → p` (axiom weakened to non-empty context)

**Category B: Modal in Context (8 theorems)**
1. `box_elim_ctx` : `[□A] ⊢ A`
2. `box_4_ctx` : `[□A] ⊢ □□A`
3. `box_b_ctx` : `[A] ⊢ □◇A`
4. `box_to_diamond_ctx` : `[□A] ⊢ ◇A`
5. `k_dist_ctx` : `[□(A → B), □A] ⊢ □B`
6. `box_pair_ctx` : `[□A, □B] ⊢ □A ∧ □B`
7. `diamond_5_ctx` : `[◇A] ⊢ □◇A`
8. `box_to_future_ctx` : `[□A] ⊢ G(A)`

**Category C: Temporal in Context (8 theorems)**
1. `temp_k_ctx` : `[G(A → B), G(A)] ⊢ G(B)`
2. `connect_future_ctx` : `[A] ⊢ G(P(A))`
3. `connect_past_ctx` : `[A] ⊢ H(F(A))`
4. `box_future_ctx` : `[□A] ⊢ G(□A)`
5. `box_past_ctx` : `[□A] ⊢ H(A)`
6. `until_F_ctx` : `[U(ψ,φ)] ⊢ F(ψ)`
7. `since_P_ctx` : `[S(ψ,φ)] ⊢ P(ψ)`
8. `serial_future_ctx` : `[A] ⊢ F(⊤)` (serial_future weakened to context)

### Phase 2: Weakening Variants (20+ theorems)

For each Category A/B/C theorem `Γ ⊢ φ`, create 1-2 weakened versions `Δ ⊢ φ` where `Γ ⊂ Δ`. Example:
- `mp_in_context_weak` : `[p → q, p, r] ⊢ q` (weakened from [p → q, p])
- `box_elim_ctx_weak` : `[□A, B] ⊢ A`

Also create "pure weakening" entries: existing theorems `⊢ φ` weakened to `Γ ⊢ φ` for various small contexts.

### Phase 3: Multi-Instantiation (10+ theorems)

Register each core contextual theorem with 2-3 different formula instantiations (p/q/r/s variants).

### Phase 4: Register in ProofStepExport.lean

Add all new entries to `theoremRegistry` in `ProofStepExport.lean` with the pattern:
```lean
mkEntry "mp_in_context" (mp_in_context (p := p) (q := q)),
mkEntry "mp_in_context_qr" (mp_in_context (p := q) (q := r)),
```

### Expected Step Distribution Impact

Assuming ~50 contextual theorems with average ~5 steps each:
- ~250 new steps total
- Current total: 10,063 steps
- New total: ~10,313 steps

Estimated rule distribution:
- `assumption` steps: Each contextual theorem uses 1-4 assumption steps. 50 theorems x ~2.5 avg = ~125 assumption steps. **125/10313 = 1.2%** -- below the 5% target.

To hit 5% (516 steps), we need approximately 200 assumption steps. This requires either:
- More theorems (~100 instead of 50)
- Larger contexts (3-4 assumptions each)
- Multi-instantiation to multiply the count

**Revised target**: 80+ contextual theorems with average 2.5 assumption steps = 200 assumption steps (2.0%). Combined with weakening variants (additional 150 steps), we approach the targets.

**Alternative scaling strategy**: If we include weakening-only variants (existing `⊢ φ` theorems weakened to `[ψ₁, ψ₂] ⊢ φ`), each such entry adds 1 weakening step. Adding 80 such entries would add 80 weakening steps (0.8%). This is low-effort bulk generation.

### Recommended Scaling to Hit Targets

| Strategy | Entries | Assumption Steps | Weakening Steps |
|----------|---------|------------------|-----------------|
| Core contextual (A/B/C) | 28 | 70 | 28 |
| Weakened variants | 28 | 0 | 56 |
| Multi-instantiation of core | 28 | 70 | 28 |
| Weakened multi-instantiation | 28 | 0 | 56 |
| Pure weakening of existing | 50 | 0 | 50 |
| **Total** | **162** | **140** | **218** |
| **% of ~10,225** | | **1.4%** | **2.1%** |

These percentages fall below the 5%/3% targets. To fully meet them, we would need to either:
1. Create much larger contextual proofs (deeper chains with more assumption uses)
2. Scale to 200+ entries with richer derivations
3. Accept that the targets are aspirational and document the gap

**Realistic assessment**: Achieving assumption >= 5% while keeping proofs natural (not artificially inflated) is challenging given that the existing 10,063 steps overwhelmingly dominate. The most honest approach is to create high-quality contextual proofs and measure the actual percentages, then iterate if needed.

## 7. Computability Analysis

### Computable Constructors (All 7)

All `DerivationTree` constructors are computable:
- `.axiom` -- needs `Axiom φ` witness and `h_fc` proof (computable for concrete instances)
- `.assumption` -- needs `φ ∈ Γ` proof (computable via `by simp` for concrete lists)
- `.modus_ponens` -- recursive (computable if sub-trees are)
- `.necessitation` -- recursive
- `.temporal_necessitation` -- recursive
- `.temporal_duality` -- recursive
- `.weakening` -- needs `Γ ⊆ Δ` proof (computable via `by intro; simp`)

### Why Existing Contextual Theorems Are Noncomputable

The `noncomputable section` in `Propositional/Core.lean` is caused by importing `DeductionTheorem.lean`, which uses `Classical.propDecidable`. This taints the entire section even though many defs (like `ecq`) only use computable operations.

### Solution: Fresh File Without Deduction Theorem

A new file that only imports `Derivation.lean` and `Combinators.lean` will not inherit the noncomputability. We can re-derive `ecq`, `ldi`, `rdi`, etc. as computable versions by directly constructing the `DerivationTree`.

### Verification Strategy

After creating the new file:
1. `lake build Bimodal.Theorems.ContextualProofs` -- verify compilation
2. Register entries in `ProofStepExport.lean` and rebuild
3. Run `lake exe proof_extractor` and verify assumption/weakening steps appear
4. Count step distribution to assess target percentages

## 8. Risk Assessment

| Risk | Impact | Mitigation |
|------|--------|------------|
| Computability issues with `by simp` proofs | Medium | Test each theorem individually before registering |
| Step percentage targets unreachable | Medium | Document actual percentages; iterate if needed |
| Build time increase from 162 new entries | Low | DerivationTree evaluation is fast for small proofs |
| Import cycle from new file | Low | New file only imports Derivation + Combinators (no cycles) |

## Appendix: Existing Contextual Code Patterns

### Pattern 1: ecq (from Core.lean, lines 192-237)
Uses: 2 assumptions, 2 weakening, 3 modus_ponens, 2 axiom = 9 steps total

### Pattern 2: ldi (from Core.lean, lines 357-408)
Uses: 1 assumption, 3 weakening, 4 modus_ponens, 3 axiom = 11 steps total

### Pattern 3: rdi (from Core.lean, lines 420-440)
Uses: 1 assumption, 1 weakening, 1 modus_ponens, 1 axiom = 4 steps total

### Pattern 4: reverse_deduction (from GeneralizedNecessitation.lean, lines 70-76)
Uses: 1 assumption, 1 weakening, 1 modus_ponens = 3 steps total
