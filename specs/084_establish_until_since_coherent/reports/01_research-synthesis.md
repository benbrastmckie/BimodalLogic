# Research Synthesis: Establishing `until_since_coherent` for Chain Constructions

- **Task**: 84 - Establish Until/Since Coherence for Bundle Completeness
- **Type**: research
- **Sources**: Task 83 reports 20, 22, 24, 28, 34, 37, 38, 39 + task 83 implementation summary 39

## Problem Statement

Three `sorry` sites remain in `FrameConditions/Completeness.lean` (lines 322, 356, 450) where the completeness proofs require `B.until_since_coherent` — the property that each FMCS family in a BFMCS resolves Until/Since eventuality obligations with correct guard intervals. These are structurally parallel to the `temporally_coherent` sorries (forward_G/backward_H/forward_F/backward_P) and block sorry-free completeness over Int.

### Definition of `until_since_coherent`

From `TemporalCoherence.lean:466-479`:

```lean
def BFMCS.until_since_coherent (B : BFMCS D) : Prop :=
  ∀ fam ∈ B.families,
    -- Forward Until: (φ U ψ) ∈ fam.mcs t → ∃ s ≥ t, ψ at s ∧ φ on [t,s)
    (∀ t : D, ∀ φ ψ : Formula,
      Formula.untl φ ψ ∈ fam.mcs t →
      ∃ s : D, t ≤ s ∧ ψ ∈ fam.mcs s ∧ ∀ r : D, t ≤ r → r < s → φ ∈ fam.mcs r) ∧
    -- Backward Until: witness exists → (φ U ψ) ∈ fam.mcs t
    (∀ t : D, ∀ φ ψ : Formula,
      (∃ s : D, t ≤ s ∧ ψ ∈ fam.mcs s ∧ ∀ r : D, t ≤ r → r < s → φ ∈ fam.mcs r) →
      Formula.untl φ ψ ∈ fam.mcs t) ∧
    -- Forward Since: (φ S ψ) ∈ fam.mcs t → ∃ s ≤ t, ψ at s ∧ φ on (s,t]
    (∀ t : D, ∀ φ ψ : Formula,
      Formula.snce φ ψ ∈ fam.mcs t →
      ∃ s : D, s ≤ t ∧ ψ ∈ fam.mcs s ∧ ∀ r : D, s < r → r ≤ t → φ ∈ fam.mcs r) ∧
    -- Backward Since: witness exists → (φ S ψ) ∈ fam.mcs t
    (∀ t : D, ∀ φ ψ : Formula,
      (∃ s : D, s ≤ t ∧ ψ ∈ fam.mcs s ∧ ∀ r : D, s < r → r ≤ t → φ ∈ fam.mcs r) →
      Formula.snce φ ψ ∈ fam.mcs t)
```

### The Three Sorry Sites

| Line | Theorem | Chain Type | Notes |
|------|---------|------------|-------|
| 322 | `bundle_validity_implies_provability` | UltrafilterChain (`construct_bfmcs_bundle`) | Also needs `temporally_coherent` (sorry at line 239) |
| 356 | `restricted_bundle_validity_implies_provability` | UltrafilterChain (restricted) | Uses `bfmcs_restricted_temporally_coherent` (sorry-free) |
| 450 | dovetailed completeness | DovetailedChain (`construct_dovetailed_bfmcs_bundle`) | Uses `dovetailed_bfmcs_restricted_temporally_coherent` (sorry-free) |

Note: Lines 356 and 450 have sorry-free `temporally_coherent` — only `until_since_coherent` remains. Line 322 has both `temporally_coherent` and `until_since_coherent` as sorry.

## Why Previous Chain Approaches Failed

Task 83 explored ~38 research iterations and 33 plan versions attempting to close these sorries. The key failure modes, distilled from reports:

### 1. X-vs-G Mismatch (Reports 28, 38)

The fundamental obstacle: Until unfolds via **X** (next-step), but chain seeds propagate via **G** (all-future):

- Until Unfold (BX9): `(φ U ψ) → ψ ∨ (φ ∧ X(φ U ψ))`
- Chain seeds use: `g_content(w) = {α : G(α) ∈ w}`, giving `g_content(w) ⊆ w_{n+1}`
- But `x_content(w) = {α : X(α) ∈ w}` and `x_content(w) ≠ g_content(w)`

So when `X(φ U ψ) ∈ w_n` from Until unfolding, this does NOT guarantee `(φ U ψ) ∈ w_{n+1}` because `(φ U ψ)` may not be in `g_content(w_n)`. Lindenbaum extension from `g_content` seeds can consistently choose `¬(φ U ψ)` at the next step.

### 2. forward_F/backward_G Circularity (Report 28)

To prove `F(ψ) ∈ chain(n) → ∃ s > n, ψ ∈ chain(s)` requires showing that F-obligations eventually resolve. The standard argument uses `temporal_backward_G_with_fwd_F` which itself requires forward_F as a hypothesis — circular.

### 3. Quasimodel/Filtration Failure (Report 24)

Both quasimodel (GHR 1994) and filtration approaches fail at the same X-vs-G mismatch. Enriching witness seeds with Until deferrals fails because Until deferrals are X-liftable but NOT G-liftable.

### 4. BX4 Invalidity (Report 37)

The interaction axiom BX4 (`G(φ → X(ψ)) → φ U ψ`) is semantically invalid under the project's strict guard semantics. No valid variant suffices. This rules out approaches relying on BX4.

### 5. Backward Until Derivation Invalid (Task 83 Implementation Summary 39)

Plan v39 proposed deriving `¬(φ U ψ) → ¬ψ ∧ (¬φ ∨ G(¬(φ U ψ)))` from BX axioms. This was proven **semantically invalid** by countermodel: p true at 0, false at 1; q false everywhere except true at 2. So `¬(p U q)` holds at 0 but neither `¬p` nor `G(¬(p U q))` holds.

## Viable Approaches

### Approach A: Enriched-Succ Chain with Dovetailed Scheduling (Reports 38, 39)

**Core idea**: Include active Until formulas directly in the Lindenbaum seed at each step:

```
seed(w_i) = g_content(w_i) ∪ active_untils(w_i, i)
```

Where `active_untils` injects Until target formulas via round-robin over the finite subformula closure.

**Why it works**:
- Seed consistency: `targeted_g_content_seed_consistent` (SuccChainFMCS.lean:2040) already provides this
- Forward Until: By dovetailing, each `ψ` (the Until target) is eventually scheduled for seed injection. At that step, `ψ ∈ chain(s)` because the seed includes it and Lindenbaum preserves supersets.
- Guard verification: For `r ∈ [t,s)`: `(φ U ψ) ∈ chain(r)` (by seed propagation via g_content, since `G(φ U ψ)` or the self-accumulated form persists). When `ψ ∉ chain(r)`, BX9 gives `φ ∈ chain(r)`.

**Key challenge**: The guard verification step. Must show that `(φ U ψ)` persists in intermediate chain positions. Self-accumulation via BX5 (`φ U ψ → (φ ∧ (φ U ψ)) U ψ`) helps but requires that `(φ U ψ)` doesn't get killed by Lindenbaum at intermediate steps.

**Risk**: Medium (40%). The persistence of Until through g_content seeds is the crux — if `G(φ U ψ) ∉ w_n` (which is typical), then `(φ U ψ)` is not in `g_content(w_n)` and may be lost at step n+1.

### Approach B: Finite Deferral Cycle Contradiction (Reports 22, 24)

**Core idea**: Show that within a finite subformula closure, an Until obligation `(φ U ψ)` cannot be deferred indefinitely. Use pigeonhole: the chain visits only finitely many distinct theories (restricted to subformula closure), so it must cycle, and a cycle with `(φ U ψ)` but never `ψ` leads to contradiction.

**Challenge**: Requires a restricted periodic truth lemma and careful handling of the cycle structure.

**Risk**: Medium-High (50%). Reports 22, 24 showed this approach has the same X-vs-G issue at the cycle boundary.

### Approach C: Deterministic Chain with X-content Linkage (Report 14, Boneyard)

**Core idea**: Build chains where each step uses `x_content` (not `g_content`) as the seed. This directly preserves Until unfolding.

**Challenge**: `x_content` seeds may not be consistent (need `G(α) → X(α)` which is not generally derivable). The Boneyard `DeterministicFMCS.lean` attempted this but has sorry for `until_since_coherent` (line 478).

**Risk**: High (60%). The X-K axiom (`G(φ) → X(φ)`) is needed but not available as a BX axiom.

### Approach D: Hybrid — Enriched Seed with Until-Specific Scheduling

**Core idea**: Combine Approach A's dovetailing with a tighter argument. Instead of proving Until persistence through g_content (which fails), prove it **directly**: at each step where `(φ U ψ) ∈ w_n` and `ψ ∉ w_n`, explicitly include both `φ` and `(φ U ψ)` in the seed for step n+1 (not just via g_content, but via the Until unfolding rule applied at the MCS level).

**Key insight**: `(φ U ψ) ∈ w_n` and `ψ ∉ w_n` implies by BX9 + MCS maximality that `φ ∈ w_n` and `X(φ U ψ) ∈ w_n`. We cannot use `x_content` directly, but we CAN include `(φ U ψ)` in the enriched seed (not via g_content, but as an explicit additional element). The question is: is `g_content(w_n) ∪ {φ U ψ}` consistent for Lindenbaum?

**Consistency argument**: If `g_content(w_n) ∪ {φ U ψ}` were inconsistent, then `g_content(w_n) ⊢ ¬(φ U ψ)`. But `g_content(w_n) ⊆ w_n` and `(φ U ψ) ∈ w_n`, so by MCS consistency of `w_n`, `g_content(w_n) ∪ {φ U ψ}` IS consistent.

**This appears to be the cleanest path.** The seed `g_content(w_n) ∪ {active Until formulas still in w_n}` is consistent because all elements are in `w_n` (a consistent set). Lindenbaum extension then preserves this seed, guaranteeing Until persistence.

**Risk**: Low-Medium (25%). The consistency argument is clean. The main risk is that the enriched seed interacts badly with the dovetailing for F-resolution, creating a larger seed that's harder to manage.

## Recommended Path

**Approach D (Hybrid Enriched Seed)** is recommended as primary, with **Approach A** as fallback:

1. **De-risk**: Verify that `g_content(w) ∪ {φ U ψ : (φ U ψ) ∈ w ∧ ψ ∉ w}` is consistent (should follow from subset-of-w argument)
2. **Build enriched chain**: At each step, seed = `g_content(w_n) ∪ {active Until formulas in w_n}`
3. **Prove forward Until**: (φ U ψ) persists in chain until ψ appears (by seed inclusion). Dovetailing ensures ψ eventually appears.
4. **Prove backward Until**: By contradiction using MCS properties of intermediate positions
5. **Mirror for Since**: Symmetric via h_content
6. **Wire completeness**: Pass `until_since_coherent` proof to the 3 sorry sites

## Existing Infrastructure

| Component | Location | Reusability |
|-----------|----------|-------------|
| `targeted_g_content_seed_consistent` | SuccChainFMCS.lean:2040 | Direct — proves seed consistency for targeted enrichment |
| `construct_bfmcs_bundle` | UltrafilterChain.lean | Framework — builds BFMCS from MCS |
| `construct_dovetailed_bfmcs_bundle` | DovetailedChain.lean | Framework — dovetailed variant |
| `deferral_restricted_lindenbaum` | LindenBaum.lean | Core — Lindenbaum extension for enriched seeds |
| BX axioms (BX5, BX6, BX8, BX9, BX10) | BXCanonical/Frame.lean | Required — Until manipulation |
| `until_unfold_in_mcs` | Various | Derived — `(φ U ψ) ∈ MCS → ψ ∈ MCS ∨ (φ ∈ MCS ∧ X(φ U ψ) ∈ MCS)` |
| `since_unfold_in_mcs` | Various | Derived — mirror for Since |
| DovetailedChain scheduling | DovetailedChain.lean | Pattern — `Nat.unpair` over subformula closure |
| `canonical_truth_lemma` (now sorry-free for U/S) | CanonicalConstruction.lean | Direct — truth lemma accepts `h_uc` hypothesis |
| `shifted_truth_lemma` (now sorry-free for U/S) | CanonicalConstruction.lean | Direct — shifted variant |

## Relationship to `temporally_coherent` Sorry

The `bfmcs_from_mcs_temporally_coherent` sorry (line 239) blocks the same completeness path (line 304). If `until_since_coherent` is established via an enriched chain that ALSO satisfies `temporally_coherent`, both sorries could be closed simultaneously. The enriched chain approach naturally provides forward_G/backward_H (via g_content/h_content seeds) and forward_F/backward_P (via dovetailing), so this unification is architecturally natural.

**Recommendation**: Address both `temporally_coherent` and `until_since_coherent` together via a single enriched chain construction that provides all coherence properties.
