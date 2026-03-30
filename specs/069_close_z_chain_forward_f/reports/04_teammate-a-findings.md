# Modal Semantics Analysis: F-Satisfaction

**Task**: 69 - close_z_chain_forward_f
**Date**: 2026-03-30
**Focus**: Semantic meaning of F (some_future) operator and the strict s > t requirement

## Key Findings

### 1. The Project Uses Reflexive Temporal Semantics

The semantic definition in `Theories/Bimodal/Semantics/Truth.lean:124-125` is:

```
| Formula.all_past φ  => ∀ (s : D), s ≤ t → truth_at M Omega τ s φ
| Formula.all_future φ => ∀ (s : D), t ≤ s → truth_at M Omega τ s φ
```

G (all_future) uses **reflexive** `t ≤ s`, meaning "now and all future times". This is deliberate and documented: the file header explicitly states "Reflexive Temporal Semantics" using `≤` instead of `<`, enabling the T-axiom `Gφ → φ`.

### 2. F Is Derived as ¬G¬φ

F (some_future) is defined in `Theories/Bimodal/Syntax/Formula.lean:394` as:

```
def some_future (φ : Formula) : Formula := φ.neg.all_future.neg
```

That is: `F(φ) = ¬G(¬φ)`. Under the reflexive semantics where `G(ψ)` at time `t` means `∀s ≥ t, ψ(s)`, this gives:

```
F(φ) at t  ≡  ¬G(¬φ) at t
           ≡  ¬(∀s ≥ t, ¬φ(s))
           ≡  ∃s ≥ t, φ(s)
```

**Critical implication**: `F(φ)` is satisfied at `t` if and only if `∃s ≥ t, φ(s)`. This **includes s = t itself**. Therefore, when `φ ∈ chain(t)` (i.e., φ is true at t), F(φ) is semantically satisfied at t, with witness s = t.

### 3. The T-Axiom Confirms Reflexivity

`Theories/Bimodal/ProofSystem/Axioms.lean:290`:

```
| temp_t_future (φ : Formula) : Axiom (φ.all_future.imp φ)
```

The axiom `Gφ → φ` is provable precisely because the semantics uses `t ≤ s` (including s = t). The axiom comments explicitly state: "This axiom was added when switching from strict to reflexive temporal semantics."

### 4. The Blocker Is Semantic, Not Just Technical

The sorry in `omega_F_preserving_forward_F_resolution` at line ~4509 arises when:
- `phi ∈ chain(t)` (φ is true at t)
- `F(phi) ∈ chain(t)` (satisfied by s = t, reflexively)
- `G(phi) ∉ chain(t)` (φ is not always true in the future)

The theorem demands: `∃ s, t < s ∧ phi ∈ chain(s)` — a **strict** future witness.

But semantically, the F-obligation is **already satisfied at t itself**. No strictly future witness is required by the semantics. The MCS chain can consistently have:
- `F(phi) ∈ chain(t)`
- `phi ∈ chain(t)`
- `phi ∉ chain(s)` for all s > t

This is the corner case: phi is true now (and therefore F(phi) is satisfied now) but not at any strictly future time. This is a **valid semantic configuration**.

### 5. Standard Temporal Logic Background

In standard Prior-style tense logic and linear temporal logic (LTL), there are two conventions:
- **Strict semantics**: F(φ) means `∃s > t, φ(s)` (accessibility is irreflexive)
- **Reflexive semantics**: F(φ) means `∃s ≥ t, φ(s)` (accessibility is reflexive)

The project explicitly chose reflexive semantics (as documented in Truth.lean) to enable the T-axioms `Gφ → φ` and `Hφ → φ`. Under reflexive semantics, the derived operator F inherits this reflexivity: F(φ) is satisfied at t when φ holds at t itself.

Under strict semantics, `temporal_coherence` requiring `∃s > t, phi ∈ chain(s)` would always be achievable because strict F-satisfaction means there is a strictly future witness by definition. But the project uses reflexive semantics, creating this mismatch.

### 6. The Temporal Coherence Definition Needs to Match Semantics

The temporal coherence property currently requires strictly future witnesses (`t < s`). But under reflexive semantics, a model where F(φ) is satisfied by the current time is perfectly valid. The completeness proof requires that canonical model families satisfy the semantic conditions — but the semantic condition for reflexive F is `∃s ≥ t, φ(s)`, not `∃s > t, φ(s)`.

Evidence from the code: `boxClassFamilies_temporally_coherent` at line 2166 and `construct_bfmcs_bundle_temporally_coherent` at line 3223 both use the strict `t < s` condition, and both currently have sorrys or depend on blocked proofs.

## Recommended Approach

**Option 1 (Recommended): Weaken temporal coherence to `s ≥ t`**

Change the temporal coherence condition from:
```
∃ s, t < s ∧ phi ∈ fam.mcs s
```
to:
```
∃ s, t ≤ s ∧ phi ∈ fam.mcs s
```

This directly matches the reflexive semantics. The case `phi ∈ chain(t)` is immediately discharged by `s = t`. The non-trivial case `phi ∉ chain(t)` still requires finding `s > t` and is handled by the existing persistence argument.

**Rationale**: This is mathematically correct for reflexive semantics. F(φ) at t is defined as `∃s ≥ t, φ(s)`. The canonical model satisfies F(φ) at t iff `∃s ≥ t, phi ∈ chain(s)`. The strict version asks for more than semantics requires.

**Impact assessment**: Changing `t < s` to `t ≤ s` in temporal coherence would require:
1. Updating the `temporally_coherent` predicate definition in BFMCS (wherever it is defined)
2. Verifying the truth lemma still holds (it should, since reflexive F-semantics matches `s ≥ t`)
3. Checking that all downstream uses of temporal coherence are still valid

**Option 2: Modify the F-preserving construction to ensure phi reappears**

In `omega_step_forward_F_preserving`, when building the witness MCS for F(phi), explicitly include phi in the seed even when phi ∈ chain(t). This would force phi into chain(t+1), giving a strict s > t witness.

This is less natural but avoids changing the temporal coherence definition.

**Option 3: Separate the cases formally**

Prove two separate temporal coherence properties:
- Weak: `F(phi) ∈ chain(t) → ∃s ≥ t, phi ∈ chain(s)` (provable)
- Strong: `F(phi) ∈ chain(t) ∧ phi ∉ chain(t) → ∃s > t, phi ∈ chain(s)` (also provable, since persistence handles the `phi ∉ chain(t)` case)

This avoids changing any definitions but requires updating theorem statements and any callers.

## Evidence and Examples

**Semantic validity of the corner case**:
Consider a linear model with times {0, 1, 2, ...} where:
- φ is true at time 0 only
- G(φ) is false at 0 (φ not always future)
- F(φ) is true at 0 (reflexively, since φ is true at 0)

This is a perfectly valid model under reflexive G/F semantics. The MCS at time 0 would contain `F(phi)` and `phi` but not `G(phi)`. There is no future time with phi.

**From Truth.lean:48**:
> ✓ Future: `∀ (s : D), t ≤ s → truth_at M τ s φ` uses reflexive ordering (now and all future times)

**From Axioms.lean:288**:
> Semantically: `Gφ` at t means ∀s ≥ t, φ(s). Since t ≥ t (reflexivity), φ(t).

**The F-satisfying-at-t case from UltrafilterChain.lean:4480-4509**:
> "This is a genuine semantic possibility that the construction handles by satisfying F(phi) at t itself. The strict s > t temporal coherence is stronger than semantic validity requires."

This confirms the code author already identified the issue: the strict requirement is stronger than semantics demands.

## Confidence Level

**High**. The analysis is based on:
1. Direct reading of the semantic definition in Truth.lean (reflexive `≤`)
2. The derived definition of `some_future` as `¬G¬φ` (which inherits reflexivity)
3. The T-axiom in Axioms.lean explicitly confirming reflexive semantics
4. The code comments in UltrafilterChain.lean at the sorry site confirming the semantic analysis
5. Standard temporal logic theory: reflexive G gives reflexive F (by duality), meaning F(φ) is satisfied at the current time when φ holds there

The recommended fix (Option 1: weaken to `s ≥ t`) is mathematically justified and directly resolves the blocker.
