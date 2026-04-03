# Teammate A Findings: Strict vs Weak Temporal Semantics Transition Analysis

**Task**: 83 - Close Restricted Coherence Sorries
**Focus**: Full scope analysis of switching from weak (reflexive) to strict temporal semantics for G/H
**Date**: 2026-04-03

## Current Semantics (Exact Definitions from Code)

From `Theories/Bimodal/Semantics/Truth.lean` lines 118-129:

```lean
def truth_at (M : TaskModel F) (Omega : Set (WorldHistory F))
    (τ : WorldHistory F) (t : D) : Formula → Prop
  | Formula.all_past φ => ∀ (s : D), s ≤ t → truth_at M Omega τ s φ     -- H: reflexive (≤)
  | Formula.all_future φ => ∀ (s : D), t ≤ s → truth_at M Omega τ s φ   -- G: reflexive (≤)
  | Formula.untl φ ψ => ∃ s : D, t ≤ s ∧ truth_at M Omega τ s ψ ∧
      ∀ r : D, t ≤ r → r < s → truth_at M Omega τ r φ                   -- Until: half-open [t,s)
  | Formula.snce φ ψ => ∃ s : D, s ≤ t ∧ truth_at M Omega τ s ψ ∧
      ∀ r : D, s < r → r ≤ t → truth_at M Omega τ r φ                   -- Since: half-open (s,t]
```

**Summary**: G and H use reflexive (≤), meaning "now and all future/past times". Until and Since already use half-open intervals with strict `<` for the guard side. The Until/Since definitions were recently changed from closed to half-open as part of plan v7 (Phase 1 completed).

**Derived operators** (from `Syntax/Formula.lean`):
- `some_future φ = ¬G(¬φ)` -- F: "exists s ≥ t with φ(s)" (reflexive)
- `some_past φ = ¬H(¬φ)` -- P: "exists s ≤ t with φ(s)" (reflexive)

Under strict semantics these would become:
- G: `∀ s > t, φ(s)` -- strictly future
- H: `∀ s < t, φ(s)` -- strictly past
- F: `∃ s > t, φ(s)` -- strictly future existential
- P: `∃ s < t, φ(s)` -- strictly past existential

## ROADMAP Concerns About Strict Semantics

The ROADMAP.md does NOT explicitly discuss the strict-vs-reflexive semantics decision at length. However, the Truth.lean module header (lines 10-18) provides the historical rationale:

> **Historical Note**: A previous version used strict semantics (<) which required an axiom for canonicalR irreflexivity. The current version uses reflexive semantics to eliminate this axiom and simplify the metalogic.

The concerns documented across the codebase:

1. **CanonicalR irreflexivity problem**: Under strict semantics, the canonical frame's accessibility relation should be irreflexive (t cannot access itself temporally). But irreflexivity is NOT modally definable (Blackburn, de Rijke, Venema). The `typst/chapters/06-notes.typ` line 187 states: "The fundamental obstacle is that *irreflexivity is not modally definable*: no temporal formula holds in exactly those frames where the accessibility relation is irreflexive."

2. **T-axiom dependency**: Switching to reflexive semantics allowed adding `temp_t_future` (Gφ → φ) and `temp_t_past` (Hφ → φ) as axioms, which dramatically simplified multiple proof components. The T-axioms make `ExistsTask M M` trivially true (canonical frame reflexivity), eliminating complex irreflexivity arguments.

3. **Density axiom becomes trivial**: Under reflexive semantics, `GGφ → Gφ` is trivially valid by taking `r = s` (Soundness.lean line 330). Under strict semantics, this genuinely requires `DenselyOrdered D`.

4. **Seriality axioms become trivial**: Under reflexive semantics, `Gφ → Fφ` is proved by taking `s = t` (using `le_refl`). Under strict semantics, this requires `NoMaxOrder D` / `NoMinOrder D`.

5. **Interior operator structure**: The `InteriorOperators.lean` module explicitly notes that under strict semantics, G and H are NOT interior operators (no deflationary property), only Box remains one.

## Boneyard Prior Attempts

Two archived directories in `Theories/Bimodal/Boneyard/`:

### UltrafilterDeadCode/ (4,423 lines, 23 sorries eliminated)
Archived 2026-03-31. Contains documentation stubs for approaches that hit fundamental mathematical barriers:
- **F-Preserving Seed**: Proved FALSE by Task 69
- **Bidirectional Seed**: `H(a) -> G(H(a))` is NOT derivable in TM
- **Z_chain Construction**: Cross-direction G/H coherence has circular dependencies
- **CoherentZChain**: Same structural gaps
- **True Dovetailed**: `F(phi)` vanishes case unfixable

Several of these (FPreservingSeed.lean lines 106, 680, 784) use `Axiom.temp_t_future` directly, meaning they were written DURING the reflexive semantics era and depend on it.

### BundleTemporalCoherence/ (reference documentation)
Archived as "semantically wrong" -- bundle-level coherence allows witnesses in different histories, but TM temporal operators require same-history witnesses. The code uses reflexive semantics (`t ≤ s`) in its Truth.lean quotation.

**Key finding**: The Boneyard code does NOT contain prior strict-semantics attempts. The switch to reflexive semantics happened earlier (pre-boneyard era), and all archived code was written under reflexive semantics. The strict semantics era artifacts were likely removed before the boneyard was established.

However, the `WitnessSeed.lean` file (still active, NOT boneyard) explicitly notes at line 31: "These proofs work with irreflexive temporal semantics (G/H use strict `<`). The seed consistency proofs do NOT use the T-axiom." This is significant -- it means some infrastructure was deliberately written to be strict-semantics-compatible.

## Half-Open Semantics Interaction with Strict G/H

The plan at `plans/08_half-open-semantics.md` defines Until/Since with half-open intervals. Currently:

- Until: witness `s ≥ t` (reflexive), guard `t ≤ r < s` (half-open)
- Since: witness `s ≤ t` (reflexive), guard `s < r ≤ t` (half-open)

Under strict G/H, Until/Since semantics could be formulated as:
- **Option A (current half-open, keep)**: Until witness `s ≥ t`, guard `t ≤ r < s` -- no change needed since Until/Since are independent operators from G/H
- **Option B (full strict)**: Until witness `s > t`, guard `t ≤ r < s` -- would require `psi` at a STRICTLY future time

**Analysis**: The Until/Since semantics are **independent** of whether G/H are strict or reflexive. The half-open interval is a standard Kamp (1968) choice that works under both. The key interaction is through the **axioms**, not the semantic definitions:

1. `until_unfold`: `(φ U ψ) → ψ ∨ (φ ∧ G(φ U ψ))` -- Currently UNSOUND (noted in Soundness.lean line 518-519). Under strict G, `G(φ U ψ)` at time t means `(φ U ψ)` at all s > t. This is actually CLOSER to being sound because G is weaker (doesn't include t itself), but the fundamental issue persists: the Until witness only covers `[t, s_w]`, not all future times.

2. `until_intro`: `ψ ∨ (φ ∧ G(φ U ψ)) → (φ U ψ)` -- Currently SOUND under half-open (proved at Soundness.lean lines 524-538). Under strict G: Case 1 (ψ at t) still works. Case 2: `G(φ U ψ)(t)` means `(φ U ψ)(s)` for all `s > t`, which does NOT include `(φ U ψ)(t)` -- so we can't extract `(φ U ψ)(t)` from `G(φ U ψ)(t)`. The current proof at line 538 uses `h_G t (le_refl t)` which requires reflexive G. **Until_intro becomes UNSOUND under strict G** for the second disjunct.

3. `since_intro`: Same issue symmetrically.

**Critical finding**: Switching G/H to strict semantics BREAKS the already-proved `until_intro` and `since_intro` soundness proofs. The second disjunct relies on `G(φ U ψ)(t) → (φ U ψ)(t)` which is exactly the T-axiom pattern.

**Interaction summary**: Half-open Until/Since are compatible with strict G/H at the semantic level, but the **axiom system** for Until/Since (particularly `until_intro` and `since_intro`) must be reformulated. A natural replacement would be: `ψ ∨ (φ ∧ (φ U ψ) ∧ G(φ U ψ)) → (φ U ψ)` is trivially true but unhelpful. The standard discrete approach uses a next-time operator X rather than G, but TM doesn't have X.

## Complete File Change Catalog

### TIER 1: Semantic Definition (must change)

| File | Changes Required |
|------|-----------------|
| `Semantics/Truth.lean` (lines 124-125) | Change `s ≤ t` to `s < t` and `t ≤ s` to `t < s` for `all_past`/`all_future` |
| `Semantics/Truth.lean` (lines 209-234) | Update `past_iff`, `future_iff` theorem statements and proofs |

### TIER 2: Axiom System (must change)

| File | Changes Required |
|------|-----------------|
| `ProofSystem/Axioms.lean` (lines 279-304) | **Remove** `temp_t_future` and `temp_t_past` axiom constructors |
| `ProofSystem/Axioms.lean` (lines 459-471) | **Reformulate** `until_intro` (currently uses G, needs alternative under strict semantics) |
| `ProofSystem/Axioms.lean` (lines 501-512) | **Reformulate** `since_intro` (symmetric) |
| `ProofSystem/Axioms.lean` (line 642-643) | Update `isBase` classification (remove temp_t entries) |
| `ProofSystem/Substitution.lean` (lines 298-303) | Remove `temp_t_future`/`temp_t_past` substitution cases |

### TIER 3: Soundness Proofs (must rewrite)

| File | Changes Required |
|------|-----------------|
| `Metalogic/Soundness.lean` (lines 245-265) | **Delete** `temp_t_future_valid` and `temp_t_past_valid` |
| `Metalogic/Soundness.lean` (lines 318-331) | **Rewrite** `density_valid` -- no longer trivial, needs `DenselyOrdered` proof |
| `Metalogic/Soundness.lean` (lines 332-379) | **Rewrite** `discreteness_forward_valid`, `seriality_future_valid`, `seriality_past_valid` -- need actual frame conditions |
| `Metalogic/Soundness.lean` (lines 381-512) | **Rewrite** `axiom_base_valid`, `axiom_valid_dense`, `axiom_valid_discrete` -- remove temp_t entries, restructure |
| `Metalogic/Soundness.lean` (lines 524-538) | **Rewrite** `until_intro` soundness -- current proof broken by strict G |
| `Metalogic/Soundness.lean` (lines 578-591) | **Rewrite** `since_intro` soundness -- same |
| `Metalogic/SoundnessLemmas.lean` (lines 601-617) | Remove `temp_t_future`/`temp_t_past` swap preservation cases |
| `FrameConditions/Soundness.lean` | Update axiom classification references |

### TIER 4: Canonical Model / Completeness (heavy rewrite)

| File | Changes Required |
|------|-----------------|
| `Metalogic/Bundle/CanonicalIrreflexivity.lean` (lines 137-159) | **Rewrite entirely** -- `existsTask_reflexive` proof uses T-axiom; must prove reflexivity by other means or accept irreflexivity |
| `Metalogic/Bundle/TargetedChain.lean` (4 uses) | Replace all T-axiom applications with alternative proofs |
| `Metalogic/Algebraic/DovetailedChain.lean` (9 uses) | Replace all T-axiom applications; this is the core chain construction |
| `Metalogic/Algebraic/UltrafilterChain.lean` (14 uses) | Replace all T-axiom applications |
| `Metalogic/Algebraic/TenseS5Algebra.lean` (4 uses) | Rewrite `always` decomposition proof (uses Gφ → φ) |
| `Metalogic/Bundle/SuccChainFMCS.lean` (8 uses) | Replace T-axiom in succ chain properties |
| `Metalogic/Bundle/MCSWitnessSuccessor.lean` (2 uses) | Replace T-axiom applications |
| `Metalogic/Bundle/SuccExistence.lean` (4 uses) | Replace T-axiom applications |
| `Metalogic/Bundle/CanonicalConstruction.lean` (3 uses) | Truth lemma cases that use T-axiom |
| `Metalogic/Algebraic/InteriorOperators.lean` | G and H no longer interior operators (already noted in comments) |
| `Metalogic/Algebraic/LindenbaumQuotient.lean` | May need adjustments to quotient structure |
| `Metalogic/Completeness.lean` | May need structural changes to completeness proof |
| `Metalogic/DenseCompleteness.lean` | Density now genuinely required |
| `Metalogic/DiscreteCompleteness.lean` | Discreteness axiom proofs change |

### TIER 5: Derived Facts / Theorems (moderate changes)

| File | Changes Required |
|------|-----------------|
| `ProofSystem/LinearityDerivedFacts.lean` | Update references to temp_t_future/past |
| `ProofSystem/Derivation.lean` | If derivation tree references T-axiom |
| `Theorems/Discreteness.lean` | May use T-axiom |
| `Theorems/GeneralizedNecessitation.lean` | May reference temporal operators |

### TIER 6: Decidability / FMP (affected)

| File | Changes Required |
|------|-----------------|
| `Metalogic/Decidability/FMP/TruthPreservation.lean` | Temporal truth preservation changes |
| `Metalogic/Decidability/SignedFormula.lean` | May reference G/H semantics |
| `Metalogic/Decidability/Tableau.lean` | Tableau rules for strict G/H |

### TIER 7: Documentation / Non-Lean (update)

| File | Changes Required |
|------|-----------------|
| `typst/chapters/06-notes.typ` | Update interior operator discussion |
| `latex/subfiles/04-Metalogic.tex` | Already mentions irreflexive; update for consistency |
| `Boneyard/UltrafilterDeadCode/FPreservingSeed.lean` | Dead code, but 3 T-axiom references |

### TIER 8: Conservative Extension (check)

| File | Changes Required |
|------|-----------------|
| `Metalogic/ConservativeExtension/ExtDerivation.lean` | Check for T-axiom references |
| `Metalogic/ConservativeExtension/ExtFormula.lean` | Check formula extensions |
| `Metalogic/ConservativeExtension/Lifting.lean` | Check lifting proofs |
| `Metalogic/ConservativeExtension/Substitution.lean` | Check substitution |

**Total affected files**: At minimum 18 Lean files with code changes, plus documentation. The 87 total occurrences of `temp_t_future`/`temp_t_past` across 18 files give the lower bound on individual edit sites.

## Axiom System Changes Required

### Axioms to REMOVE

1. **`temp_t_future` (Gφ → φ)**: Invalid under strict semantics. G quantifies over s > t only; t itself is not included.
2. **`temp_t_past` (Hφ → φ)**: Invalid under strict semantics. H quantifies over s < t only.

### Axioms that CHANGE MEANING but remain valid

1. **`temp_4` (Gφ → GGφ)**: Still valid. If φ at all s > t, then for any r > t, φ at all s > r (subset).
2. **`temp_a` (φ → G(Pφ))**: Still valid. If φ at t, then for all s > t, exists r < s (namely t) with φ(r).
3. **`temp_l` (△φ → G(Hφ))**: Still valid but proof changes. "Always φ" now means H(φ) ∧ φ ∧ G(φ), and G(Hφ) at t means for all s > t, for all r < s, φ(r).
4. **`temp_k_dist` (G(φ→ψ) → (Gφ→Gψ))**: Still valid. Distribution over strict future.
5. **`modal_future` (□φ → □Gφ)**: Still valid. Necessary truths remain necessary at strictly future times.
6. **`temp_future` (□φ → G□φ)**: Still valid.
7. **`temp_linearity`**: Still valid -- linear order trichotomy on witnesses.

### Axioms that become GENUINELY frame-dependent

1. **`density` (GGφ → Gφ)**: Now genuinely requires `DenselyOrdered D`. Under strict semantics, for s > t, need u with t < u < s to chain GG → G. This is the textbook density axiom.
2. **`seriality_future` (Gφ → Fφ)**: Now genuinely requires `NoMaxOrder D`. Need to know there EXISTS some s > t.
3. **`seriality_past` (Hφ → Pφ)**: Now genuinely requires `NoMinOrder D`.
4. **`discreteness_forward`**: Now genuinely requires `SuccOrder`. Need immediate successors.

### Axioms that become UNSOUND

1. **`until_intro` (ψ ∨ (φ ∧ G(φ U ψ)) → φ U ψ)**: The second disjunct case currently uses `G(φ U ψ)(t) → (φ U ψ)(t)` (T-axiom pattern). Under strict G, `G(φ U ψ)(t)` only gives `(φ U ψ)(s)` for s > t. **The axiom needs reformulation.** Options:
   - Replace G with "φ ∧ G": `ψ ∨ (φ ∧ (φ U ψ) ∧ G(φ U ψ)) → φ U ψ` (but this is circular/vacuous)
   - Use a discrete next-step: `ψ ∨ (φ ∧ X(φ U ψ)) → φ U ψ` (requires adding X operator)
   - Reformulate: `ψ ∨ (φ ∧ F(φ U ψ)) → φ U ψ` (might be sound for discrete, weaker than G version)

2. **`since_intro`**: Symmetric issue.

### New axioms potentially NEEDED

Under strict semantics, the following may be needed to recover deductive power:
- **Irreflexivity schemes**: Difficult (irreflexivity not modally definable)
- **Interaction axioms**: `φ → G(Pφ)` becomes `φ → G(φ ∨ Pφ)` or similar
- **Stronger temporal connectedness**: To relate strict G/H to the present

## Metalogic Impact Analysis

### Soundness

**Impact: HIGH**. The soundness proof file (Soundness.lean) requires extensive rewriting:
- 12 direct references to `temp_t_future`/`temp_t_past` across validity proofs
- The `density_valid`, `seriality_future_valid`, `seriality_past_valid` proofs are currently trivial under reflexive semantics (all use `le_refl` / `t ≥ t`) and would need genuine frame condition arguments
- The `until_intro`/`since_intro` soundness proofs at lines 524-591 use `le_refl` critically
- SoundnessLemmas.lean has 4 cases for T-axiom swap preservation

### Completeness

**Impact: VERY HIGH**. The completeness proof is the most heavily impacted:

1. **Canonical frame reflexivity** (`CanonicalIrreflexivity.lean`): The theorem `existsTask_reflexive` DIRECTLY uses the T-axiom to prove `g_content(M) ⊆ M`. Without T-axiom, `ExistsTask M M` is FALSE in general (g_content(M) is NOT a subset of M under strict semantics). The canonical accessibility relation becomes IRREFLEXIVE, which is the correct behavior but requires a different proof strategy.

2. **DovetailedChain.lean** (9 uses): The dovetailed chain construction -- the core sorry-free infrastructure for task 83 -- uses the T-axiom in 9 places. These are in critical properties like G-content propagation and H-content propagation. Replacing these requires finding alternative derivation paths that avoid Gφ → φ.

3. **UltrafilterChain.lean** (14 uses): The most T-axiom-dependent file. Used in boxClassFamilies construction, modal backward proofs, and temporal coherence arguments.

4. **SuccChainFMCS.lean** (8 uses): Succ chain properties depend on T-axiom for relating consecutive MCS elements.

5. **Truth lemma**: The restricted shifted truth lemma in CanonicalConstruction.lean uses T-axiom in 3 places. The forward and backward cases for G/H would need restructuring since the semantics of the quantifiers changes.

6. **TenseS5Algebra.lean** (4 uses): The `always` decomposition `Hφ ∧ Gφ → Hφ ∧ φ ∧ Gφ` uses Gφ → φ directly. Under strict semantics, `always` would need to be redefined as `Hφ ∧ φ ∧ Gφ` explicitly (which it already is at the syntactic level, so the impact is in the algebraic proofs that pattern-match).

### FMP / Decidability

**Impact: MODERATE**. TruthPreservation.lean references temporal semantics, but the FMP approach through filtration is less dependent on reflexivity than the canonical model approach.

### WitnessSeed Infrastructure

**Impact: LOW**. The WitnessSeed.lean file was explicitly written to be irreflexive-compatible (noted at line 31). This is a positive sign -- some infrastructure was proactively designed for a potential strict-semantics switch.

## Confidence Level

| Section | Confidence | Notes |
|---------|-----------|-------|
| Current Semantics | **HIGH** | Read directly from source code |
| ROADMAP Concerns | **HIGH** | Documented in code comments across multiple files |
| Boneyard Prior Attempts | **HIGH** | Read all READMEs; confirmed no strict-semantics era code remains |
| Half-Open Interaction | **HIGH** | Traced through soundness proofs; identified specific breakage points |
| File Change Catalog | **HIGH** | Used grep to count all 87 occurrences across 18 files |
| Axiom System Changes | **HIGH** | Analyzed each axiom's semantic validity under strict interpretation |
| Metalogic Impact | **MEDIUM-HIGH** | Identified specific line numbers and proof strategies, but cannot predict all downstream cascading failures without actually attempting the change |

## Summary Assessment

Switching from reflexive to strict temporal semantics is a **major architectural change** affecting at minimum 18 Lean files with 87+ edit sites. The most critical challenges are:

1. **Loss of T-axiom** breaks canonical frame reflexivity, requiring a fundamentally different canonical model construction approach (or accepting irreflexive canonical frames with IRR-rule-style workarounds)

2. **Until/Since axiom incompatibility**: `until_intro` becomes unsound under strict G, requiring axiom reformulation that may involve adding a next-time operator or finding alternative axiom systems

3. **Density/seriality proofs become non-trivial**: Currently trivial proofs become genuine frame-condition arguments

4. **DovetailedChain infrastructure**: 9 T-axiom uses in the core sorry-free chain construction would need replacement, potentially requiring significant proof rework

The WitnessSeed infrastructure being already strict-compatible is encouraging, but the overall effort is estimated at **40-80 hours** of proof engineering, with HIGH risk of cascading failures during the transition.
