# Teammate A Findings: Proof System Impact of Removing IRR

## Key Findings

1. **IRR is defined as a constructor of `DerivationTree`** in `Theories/Bimodal/ProofSystem/Derivation.lean:149`. It encodes the Gabbay Irreflexivity Rule: from `⊢ (p ∧ H(¬p)) → φ` where `p ∉ φ.atoms`, infer `⊢ φ`.

2. **IRR is fundamentally unsound under reflexive semantics.** The antecedent `p ∧ H(¬p)` is unsatisfiable when H quantifies over `s ≤ t` (reflexive), because `H(¬p)` at time `t` requires `¬p` at `t`, contradicting `p` at `t`. The IRR soundness proof (`IRRSoundness.lean:322`) already has a `sorry` with a comment explicitly noting this (lines 310-321).

3. **The `canonicalR_irreflexive_axiom` is the completeness-side counterpart.** It is declared as a Lean `axiom` in `CanonicalIrreflexivity.lean:1492` and is used extensively (~40+ call sites) across the canonical model construction, staged construction, and algebraic modules.

4. **Task 25 already began the replacement strategy.** `CanonicalIrreflexivity.lean:1226-1259` contains a "Fresh G-Atom Per-Witness Strictness" section that proves per-witness strictness using T-axioms instead of universal irreflexivity, which is the correct approach under reflexive semantics.

5. **T-axioms are already present.** `temp_t_future` (Gφ → φ) and `temp_t_past` (Hφ → φ) are defined in `Axioms.lean:290,304` with documentation explicitly linking them to Task 29.

## IRR Reference Inventory

### Core Proof System (must change)

| File | Line | Type | Impact of Removal |
|------|------|------|-------------------|
| `ProofSystem/Derivation.lean` | 149-154 | Constructor definition | Remove `irr` constructor from `DerivationTree` |
| `ProofSystem/Derivation.lean` | 200 | Height function case | Remove pattern match arm |
| `ProofSystem/Derivation.lean` | 291 | `isDenseCompatible` case | Remove pattern match arm |
| `ProofSystem/Derivation.lean` | 308 | `isDiscreteCompatible` case | Remove pattern match arm |
| `ProofSystem/Substitution.lean` | 366 | `derivation_subst` case | Remove pattern match arm |

### Soundness (simplifies)

| File | Line | Type | Impact of Removal |
|------|------|------|-------------------|
| `Metalogic/IRRSoundness.lean` | 1-324 | Entire module | **Delete entirely** - product frame construction no longer needed |
| `Metalogic/Soundness.lean` | 671-688 | `soundness_dense_valid` IRR case | Remove case (eliminates a `sorry`) |
| `Metalogic/Soundness.lean` | 796-801 | `soundness_dense` IRR case | Remove case |
| `Metalogic/SoundnessLemmas.lean` | 961-963 | `derivable_valid_and_swap_valid` IRR case | Remove case (eliminates a `sorry`) |

### Deduction Theorem & MCS (trivially simplifies)

| File | Line | Type | Impact of Removal |
|------|------|------|-------------------|
| `Metalogic/Core/DeductionTheorem.lean` | 259-262 | Pattern match on `.irr` | Remove arm (was vacuous: `simp at hA`) |
| `Metalogic/Core/MaximalConsistent.lean` | 150 | `usedFormulas` case | Remove pattern match arm |

### Conservative Extension (must change)

| File | Line | Type | Impact of Removal |
|------|------|------|-------------------|
| `ConservativeExtension/ExtDerivation.lean` | 100 | `ExtDerivationTree.irr` constructor | Remove constructor |
| `ConservativeExtension/ExtDerivation.lean` | 175-176 | Embedding of `irr` | Remove case |
| `ConservativeExtension/Lifting.lean` | 141-147 | `substDerivation` IRR cases | Remove cases |
| `ConservativeExtension/Lifting.lean` | 351 | `collectDerivInl` IRR case | Remove case |
| `ConservativeExtension/Lifting.lean` | 379-382 | `collectDerivInl_sub_irr` lemma | Delete lemma |
| `ConservativeExtension/Lifting.lean` | 397-502 | IRR freshness preservation | Delete section |
| `ConservativeExtension/Lifting.lean` | 563-580 | `unembedDerivation` IRR cases | Remove cases |
| `ConservativeExtension/ExtFormula.lean` | 306 | IRR embedding atom lemma | Delete if unused |

### Canonical Model / Completeness (requires replacement strategy)

| File | Line | Type | Impact of Removal |
|------|------|------|-------------------|
| `Bundle/CanonicalIrreflexivity.lean` | 1-1501 | **Entire module** | Major rework needed; keep T-axiom-based section (lines 1200+), delete IRR-based proofs |
| `Bundle/CanonicalIrreflexivity.lean` | 1492-1498 | `canonicalR_irreflexive_axiom` | **Delete axiom** - this is unsound under reflexive semantics |
| `Canonical/CanonicalIrreflexivityAxiom.lean` | 76-78 | Re-export of axiom | Delete or replace with per-witness strictness |
| `Bundle/DirectIrreflexivity.lean` | entire | Direct irreflexivity analysis | Archive to Boneyard |
| `Algebraic/SaturatedChain.lean` | 370,373,401,404,446,449,459,462 | Uses of `canonicalR_irreflexive` | Replace with per-witness strictness or reflexive canonical R |
| `StagedConstruction/*.lean` | multiple | ~15 uses of `canonicalR_irreflexive` | Replace with reflexive canonical relation |
| `Bundle/FMCSTransfer.lean` | 234,239 | Uses of `canonicalR_irreflexive` | Replace |
| `Canonical/CanonicalSerialFrameInstance.lean` | 77,123 | Uses of `canonicalR_irreflexive` | Replace |
| `Domain/CanonicalDomain.lean` | multiple | Relies on axiom for NoMaxOrder/NoMinOrder | Re-prove using T-axiom + seriality |
| `Domain/DiscreteTimeline.lean` | 127+ | Relies on axiom | Re-prove |

### Automation & Examples (pattern matches)

| File | Line | Type | Impact of Removal |
|------|------|------|-------------------|
| `Automation/ProofSearch.lean` | various | May reference IRR | Check and remove |
| `Examples/*.lean` | various | May construct IRR terms | Check and remove |

### Boneyard (no action needed)

Multiple files in `Boneyard/` reference IRR and `canonicalR_irreflexive`. These are archived and need no changes.

## Soundness Analysis

**Current state**: The soundness proof has **two `sorry`s** directly caused by IRR:

1. `Soundness.lean:688` - In `soundness_dense_valid`, the IRR case has a `sorry` for the non-domain subcase. The domain case calls `IRRSoundness.irr_sound_dense_at_domain`.

2. `SoundnessLemmas.lean:963` - In `derivable_valid_and_swap_valid`, the IRR case is entirely `sorry`.

3. `IRRSoundness.lean:322` - The `irr_sound_dense_at_domain` theorem itself ends with `sorry` because the antecedent `p ∧ H(¬p)` is unsatisfiable under reflexive semantics (as noted in the code comments at lines 310-321).

**Impact of removal**: Removing IRR from `DerivationTree` eliminates all three `sorry`s. The soundness proof becomes cleaner because there is no longer a need for the product frame construction or the `irr_sound_dense_at_domain` machinery. **Confidence: HIGH**

## Completeness Analysis

**The completeness proof does NOT directly use IRR rule applications.** Searching `Completeness.lean` and `BaseCompleteness.lean` for `irr`/`IRR`/`irrefl` yields zero matches. The completeness theorem itself is IRR-free.

**However, the canonical model construction relies heavily on `canonicalR_irreflexive`** (the axiom, not the IRR rule). This axiom asserts that the canonical accessibility relation is irreflexive: `¬CanonicalR M M` for all MCS M. This is used to:

1. **Establish strictness of canonical ordering** - converting `CanonicalR` into a strict partial order (~40 call sites in StagedConstruction, Algebraic, Bundle modules)
2. **Prove NoMaxOrder/NoMinOrder** on the canonical domain (Domain/CanonicalDomain.lean)
3. **Distinguish forward/backward witnesses** in seriality arguments

**Under reflexive semantics, `CanonicalR M M` HOLDS** (since `g_content M ⊆ M` follows from the T-axiom `Gφ → φ`). So the axiom `¬CanonicalR M M` is **false** under reflexive semantics. It must be removed.

**Replacement strategy** (already partially implemented in Task 25):
- `CanonicalR` becomes a non-strict (reflexive) preorder
- Per-witness strictness replaces universal irreflexivity: for any MCS M, there EXISTS W with `CanonicalR M W ∧ ¬CanonicalR W M`
- NoMaxOrder/NoMinOrder follow from seriality + per-witness strictness
- The canonical frame becomes a reflexive linear order (matching the intended semantics)

**Confidence: HIGH** (the mathematical theory is well-understood; the main effort is engineering)

## T-Axiom Assessment

**T-axioms are already present and correctly implemented:**

- `Axiom.temp_t_future` (Gφ → φ) at `Axioms.lean:290`
- `Axiom.temp_t_past` (Hφ → φ) at `Axioms.lean:304`

Both have detailed documentation explaining their validity under reflexive semantics and their connection to Task 29.

**T-axioms provide what IRR was intended to achieve:**

1. **Canonical model reflexivity**: T-axiom `Hφ → φ` gives `h_content M ⊆ M`, proving `CanonicalR M M` (reflexivity). This is already proved in `CanonicalIrreflexivity.lean` (the `h_content_subset` section around line 1220).

2. **MCS properties**: The T-axiom enables `Gφ ∈ M ⟹ φ ∈ M` and `Hφ ∈ M ⟹ φ ∈ M`, which are the key closure properties needed for the truth lemma.

3. **Per-witness strictness**: Using T-axiom + fresh atom arguments, one can show that for any MCS M, there exists a strictly accessible W. This is sketched in `CanonicalIrreflexivity.lean:1226-1259`.

**The T-axiom does NOT need to be added** - it is already present. What is needed is to:
- Remove IRR from DerivationTree
- Remove the `canonicalR_irreflexive_axiom`
- Complete the per-witness strictness proof (Task 25 partial work)
- Update all ~40 call sites from universal irreflexivity to per-witness strictness or reflexive `CanonicalR`

**Confidence: HIGH**

## Recommended Approach

### Phase 1: Remove IRR from proof system (low risk, high reward)
1. Remove `irr` constructor from `DerivationTree` and `ExtDerivationTree`
2. Remove all pattern match arms for `.irr` across the codebase (~15 locations)
3. Delete `IRRSoundness.lean` entirely
4. This immediately eliminates 3 `sorry`s in soundness

### Phase 2: Remove `canonicalR_irreflexive_axiom` (high effort)
1. Delete the axiom declaration and its re-exports
2. Make `CanonicalR` explicitly reflexive (prove `CanonicalR M M` from T-axiom)
3. Complete the per-witness strictness proof from Task 25
4. Update all ~40 call sites in canonical model construction

### Phase 3: Clean up (medium effort)
1. Archive `DirectIrreflexivity.lean` and `CanonicalIrreflexivity.lean` IRR sections to Boneyard
2. Update conservative extension modules
3. Remove Boneyard cross-references if desired

### Risk Assessment
- **Phase 1**: Very low risk. Purely removes dead/unsound code. May cause build errors from missing pattern match arms, but these are straightforward to fix.
- **Phase 2**: Medium risk. The per-witness strictness proof is mathematically clear but engineering-intensive. The ~40 call sites each need individual analysis for whether they need universal irreflexivity (and must be restructured) or just need a strict witness (and can use per-witness strictness).
- **Phase 3**: Low risk. Cleanup only.

## Confidence Levels

| Finding | Confidence |
|---------|------------|
| IRR is unsound under reflexive semantics | **HIGH** - mathematically proven, code comments confirm |
| Removing IRR eliminates 3 soundness `sorry`s | **HIGH** - directly verified in code |
| Completeness does not use IRR rule directly | **HIGH** - grep confirms zero matches |
| `canonicalR_irreflexive_axiom` is false under reflexive semantics | **HIGH** - T-axiom proves the opposite |
| T-axioms are already present and correct | **HIGH** - verified in Axioms.lean |
| Per-witness strictness can replace universal irreflexivity | **HIGH** - mathematically standard, partial proof exists |
| ~40 call sites need updating for Phase 2 | **MEDIUM** - count is approximate, some may be in dead code paths |
