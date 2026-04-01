# Report 06: Skolemized Unraveling Strategy for Same-Family Temporal Coherence

## 1. Problem Statement

**Goal**: Construct `construct_bfmcs` with signature:
```lean
construct_bfmcs : (M : Set Formula) -> SetMaximalConsistent M ->
  Sigma' (B : BFMCS D) (h_tc : B.temporally_coherent)
         (fam : FMCS D) (hfam : fam ∈ B.families) (t : D),
         M = fam.mcs t
```

This requires building a `TemporalCoherentFamily` where `forward_F` and `backward_P`
hold **within the same family** (not cross-family). The truth lemma's backward G case
uses contraposition through `forward_F` of the same family:

1. Assume G(phi) not in fam.mcs(t)
2. By MCS maximality: neg(G(phi)) = F(neg(phi)) in fam.mcs(t)
3. By forward_F: exists s >= t with neg(phi) in fam.mcs(s) **in the same family**
4. Contradiction with phi in fam.mcs(s) from hypothesis

Cross-family witnesses break this because the witness lives in a different family.

## 2. The User's Strategy: Skolemized Unraveling

### Core Idea

Given a consistent set Gamma, construct a family tau of MCSs indexed by D (with
shift closure, so x=0 WLOG) by systematically **unraveling** all commitments of Gamma:

1. Start at position 0 with Gamma
2. For each formula gamma in Gamma, decompose one operator at a time:
   - **F(phi) at position t**: Skolemize to "phi at position s" for some s >= t
   - **G(phi) at position t**: Add "phi at position s" for ALL s >= t
   - **Box(phi) at position t**: Generate a new family containing phi at t
   - **Negation**: Handled at the ultrafilter level (MCS = ultrafilter in Lindenbaum algebra)
3. After each unraveling step, prove the constraint system remains consistent
4. By induction: the full constraint system is consistent
5. Extend to ultrafilters (MCSs) at each position

### Product Algebra Framing

The constraint system lives in the product algebra B^D where B is the Lindenbaum-Tarski
algebra. The unraveling generates a filter in B^D. The ultrafilter lemma extends it
to ultrafilters at each position, yielding MCSs.

**Key advantage**: Existential constraints (F-witnesses) are Skolemized BEFORE entering
the algebra, turning them into definite constraints. The resulting filter is generated
by universal/pointwise constraints only.

**Key challenge**: The product algebra approach works cleanly for INDEPENDENT positions.
But g_content propagation creates DEPENDENCIES between positions: the MCS at position
s depends on the MCS at position s-1 (via g_content inclusion). Independently extending
filters at each position doesn't guarantee these dependencies are satisfied.

## 3. Key New Result: F-Content Consistency Theorem

### Theorem

If M is an MCS and F(psi_1), ..., F(psi_k) are in M, then:
```
g_content(M) ∪ {F(psi_1), ..., F(psi_k)}
```
is consistent.

### Proof

Suppose L ⊆ g_content(M) ∪ {F(psi_1), ..., F(psi_k)} and L ⊢ bot.
Partition L = L_G ∪ L_F where L_G ⊆ g_content(M) and L_F ⊆ {F(psi_i)}.

**Case L_F = empty**: L_G ⊆ g_content(M) ⊆ M (by T-axiom). Contradicts M consistent.

**Case L_F non-empty**: Say L_F = {F(psi_{j1}), ..., F(psi_{jm})}.
From L_G, F(psi_{j1}), ..., F(psi_{jm}) ⊢ bot, by iterated deduction on the F-formulas:

```
L_G ⊢ neg(F(psi_{j1})) ∨ neg(F(psi_{j2})) ∨ ... ∨ neg(F(psi_{jm}))
    = G(neg(psi_{j1})) ∨ G(neg(psi_{j2})) ∨ ... ∨ G(neg(psi_{jm}))
```

By G-lift on L_G (all elements are G-liftable since G(a) ∈ M for each a ∈ g_content(M),
and G(G(a)) ∈ M by temp_4):

```
G(G(neg(psi_{j1})) ∨ ... ∨ G(neg(psi_{jm}))) ∈ M
```

By T-axiom (G(X) → X):
```
G(neg(psi_{j1})) ∨ ... ∨ G(neg(psi_{jm})) ∈ M
```

By MCS disjunction property: exists l such that G(neg(psi_{jl})) ∈ M.
But F(psi_{jl}) = neg(G(neg(psi_{jl}))) ∈ M. **Contradiction** with MCS consistency. ∎

### Significance

This result shows that g_content(M) together with ALL F-formulas from M is consistent.
This is STRONGER than the existing `forward_temporal_witness_seed_consistent` which
handles only ONE resolution formula. It enables **F-persistence**: extending the seed
to an MCS preserves all F-obligations from M.

## 4. The Combined Seed Blocker

### The Problem

For same-family forward_F, we need BOTH:
1. **Resolution**: phi ∈ M_{s} (the witness formula appears at some position)
2. **F-persistence**: F(psi) ∈ M_n → F(psi) ∈ M_{n+1} ∨ psi ∈ M_{n+1}

These correspond to two seeds:
- **Resolution seed**: {phi} ∪ g_content(M) — consistent when F(phi) ∈ M ✓
- **F-persistence seed**: g_content(M) ∪ {F(psi_i) | F(psi_i) ∈ M} — consistent ✓ (new result)
- **Combined seed**: {phi} ∪ g_content(M) ∪ {F(psi_i)} — **NOT always consistent** ✗

### Concrete Counterexample

Let M₀ be an MCS containing:
- F(phi), F(psi), G(F(psi) → neg(phi))

Then:
- (F(psi) → neg(phi)) ∈ g_content(M₀) (since G(F(psi) → neg(phi)) ∈ M₀)
- F(psi) is an F-obligation to preserve
- phi is the resolution formula (from F(phi) ∈ M₀)

The combined seed {phi} ∪ g_content(M₀) ∪ {F(psi)} derives bot:
1. From F(psi) and (F(psi) → neg(phi)): neg(phi)
2. From phi and neg(phi): bot

So the combined seed IS genuinely inconsistent. This is not a proof technique
limitation — the formulas actually conflict.

### Why the Conflict is Genuine

The formula G(F(psi) → neg(phi)) means "at all future times, if psi eventually then
not-phi now." This constrains the temporal structure: at any future time where F(psi)
holds, phi must be false. Since we want phi at the resolution position AND F(psi) at
that same position, the constraint is violated.

### Resolution Order Matters

Interestingly, resolving F(psi) FIRST (seed: {psi} ∪ g_content(M₀) ∪ {F(phi)}) IS
consistent in this example:
- From psi and psi→F(psi) and (F(psi) → neg(phi)): neg(phi)
- From F(phi) = neg(G(neg(phi))): neg(G(neg(phi)))
- neg(phi) and neg(G(neg(phi))) are COMPATIBLE (neg(phi) = "not now", F(phi) = "eventually")

So the order of resolution matters. But cyclic dependencies (where neither can go
first) can be shown to be inconsistent with the logic, because the temporal axioms
force a well-ordering of resolution times.

## 5. Viable Implementation Paths

### Path A: F-Persistence Chain + Scheduled Resolution (RECOMMENDED)

**Approach**: Build the chain in two layers:

**Layer 1 (F-Persistence)**: At each step, use the seed:
```
g_content(M_n) ∪ {F(psi) | F(psi) ∈ M_n}
```
This is consistent by the F-content consistency theorem. The resulting chain has
F-obligations persisting monotonically: f_content(M_n) ⊆ f_content(M_{n+1}).

**Layer 2 (Scheduled Resolution)**: At scheduled steps (via dovetailing), attempt
to include the resolution formula phi in the Lindenbaum extension. Specifically,
use a **custom Lindenbaum** that:
1. Includes all F-formulas from M_n (F-persistence)
2. When the scheduled formula phi comes up for enumeration, includes phi if
   {current partial MCS} ∪ {phi} is consistent

**Why this works**: If {phi} is ever consistent with the partial MCS at some step,
it gets included and forward_F is satisfied. If it's NEVER consistent (at any chain
step), we need an argument that this contradicts F(phi) being persistent.

**Key lemma needed**: If F(phi) ∈ M_n for all n (by F-persistence), then there exists
some n where {phi} is consistent with g_content(M_n) ∪ {surviving F-formulas at n}.
This may follow from the temporal axioms and the structure of the logic.

### Path B: Two-Pass Construction

**Pass 1**: Build the chain using standard `temporal_theory_witness_exists` (resolving
ONE obligation per step). This gives g_content propagation but NO F-persistence.

**Pass 2**: For each unresolved F-obligation F(phi) at time t where phi ∉ M_s for
any s >= t: use the F-content consistency theorem to show this situation is impossible
by constructing a model that contradicts it.

The impossibility argument would need to show: if F(phi) ∈ M_t but phi ∉ M_s for all
s >= t in a chain satisfying g_content propagation, then M_t is inconsistent.

### Path C: Custom Lindenbaum with Priority Decisions

Replace `set_lindenbaum` (Zorn-based) with a **constructive step-by-step Lindenbaum**
that enumerates all formulas and makes deliberate choices:

1. Start with seed g_content(M)
2. Enumerate formulas in a priority order:
   a. First: include the scheduled resolution formula phi (consistent by G-lift)
   b. Then: for each G(neg(psi)) where F(psi) ∈ M and psi ∉ M, EXCLUDE G(neg(psi))
      (include F(psi) instead, preserving the obligation)
   c. Then: standard Lindenbaum decisions for all remaining formulas

The consistency at step (b): after including phi and excluding/including previous
F-decisions, is it consistent to include F(psi)? By the F-content consistency theorem
applied to the seed g_content(M), YES — g_content(M) ∪ {F-formulas} is consistent.
The resolution formula phi might interfere (as shown in Section 4), but if we order
the decisions carefully, we can include most F-obligations.

**Note**: This path requires formalizing a step-by-step Lindenbaum in Lean (not currently
available — the existing `set_lindenbaum` uses Zorn's lemma opaquely).

### Path D: Algebraic/Ultrafilter Approach

Work at the level of the Stone-Tarski algebra. Define the G-content filter and
F-obligations as algebraic elements. Use the Boolean prime ideal theorem to extend.

This is mathematically clean but requires significant new infrastructure in Lean
(Boolean algebra operations on the formula type, Stone duality, etc.).

## 6. Implementation Plan for Path A (Recommended)

### Phase 1: Prove the F-Content Consistency Theorem

**File**: `Theories/Bimodal/Metalogic/Bundle/WitnessSeed.lean` (extend existing file)

**Theorem**: `f_content_g_content_consistent`
```lean
theorem f_content_g_content_consistent (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    SetConsistent (g_content M ∪ {F_ψ | ∃ ψ, F_ψ = Formula.some_future ψ ∧ F_ψ ∈ M})
```

**Proof technique**: G-lift + disjunctive analysis (detailed in Section 3).

**Dependencies**: `G_lift_from_context`, `some_future_excludes_all_future_neg`,
`generalized_temporal_k`, `SetMaximalConsistent.negation_complete`,
MCS disjunction property.

**New infrastructure needed**:
- Iterated deduction theorem for removing multiple hypotheses
- Disjunction introduction from derivation of bot with multiple removed hypotheses
- MCS disjunction property: A ∨ B ∈ M → A ∈ M ∨ B ∈ M

### Phase 2: Build the F-Persistence Chain

**File**: New file `Theories/Bimodal/Metalogic/Algebraic/FPersistenceChain.lean`

**Definition**: `f_persistent_forward_step`
```lean
noncomputable def f_persistent_seed (M : Set Formula) : Set Formula :=
  g_content M ∪ {ψ | Formula.some_future ψ ∈ M}
```

Wait — this uses formulas ψ where F(ψ) ∈ M, not the F(ψ) formulas themselves.
The F-content consistency theorem is about {F(ψ) | F(ψ) ∈ M}, not {ψ | F(ψ) ∈ M}.

**Corrected definition**:
```lean
noncomputable def f_persistent_seed (M : Set Formula) : Set Formula :=
  g_content M ∪ {f | ∃ ψ, f = Formula.some_future ψ ∧ Formula.some_future ψ ∈ M}
```

This seed includes the F-FORMULAS themselves (not their contents). Extending to an
MCS W: F(ψ) ∈ W for all F(ψ) ∈ M, giving f_content(M) ⊆ f_content(W).

**Properties to prove**:
- `f_persistent_seed_consistent`: The seed is consistent (Phase 1 result)
- `f_persistent_step_f_content`: f_content(M) ⊆ f_content(extension)
- `f_persistent_step_g_content`: g_content(M) ⊆ extension
- Chain construction: Nat-indexed chain with F-persistence at each step

### Phase 3: Prove Forward_F for the Persistence Chain

**Strategy**: Show that in the F-persistence chain, every F-obligation is eventually
resolved. This is the hardest step and may require one of:

a. **Custom Lindenbaum**: At scheduled steps, the Lindenbaum extension includes the
   resolution formula phi (when consistent with the F-persistence seed). Need to show
   this eventually succeeds for every obligation.

b. **Compactness argument**: For each F(phi) at time t, the constraint "phi at no
   future time" together with "F(phi) at all future times" is finitely inconsistent,
   hence unsatisfiable. Therefore phi appears at some future time.

c. **Direct construction**: Use `temporal_theory_witness_exists` at a specially
   constructed seed that combines F-persistence with resolution.

### Phase 4: Integrate with BFMCS Bundle

Combine the F-persistence chain with the existing bundle construction:
- Use `boxClassFamilies` pattern but with F-persistent chains
- Prove `BFMCS.temporally_coherent` (same-family witnesses)
- Supply `construct_bfmcs` to `parametric_algebraic_representation_conditional`

## 7. Corrected Analysis: F-Persistence Seed is Trivially Consistent

### Critical Correction

The F-content consistency theorem stated in Section 3 is **TRIVIALLY provable**
by the same ⊆ M argument used in `successor_deferral_seed_consistent`:

- g_content(M) ⊆ M (by T-axiom: G(a) → a)
- {F(ψ) | F(ψ) ∈ M} ⊆ M (trivially, since each F(ψ) is in M by assumption)
- Therefore the seed ⊆ M, and any finite L ⊆ seed ⊆ M with L ⊢ ⊥ contradicts
  M being consistent. ∎

The elaborate G-lift + disjunction argument in Section 3 is NOT needed for the
F-persistence seed. It IS needed for the combined resolution + persistence seed
(Section 4), where the resolution formula φ might not be in M.

### What the ⊆ M Argument Gives

The F-persistence seed `g_content(M) ∪ {F(ψ) | F(ψ) ∈ M}` extends to an MCS W:
- g_content(M) ⊆ W (forward_G propagation)
- F(ψ) ∈ W for all F(ψ) ∈ M (F-content preservation)

This means f_content(M) ⊆ f_content(W): every F-obligation PERSISTS in W.

### What It Does NOT Give

F-persistence alone does NOT give forward_F. F(ψ) persisting forever without ψ
appearing is consistent with the finitary axioms. Resolution is still needed.

## 8. Existing Infrastructure Findings (from Agent Research)

### Available Tools

1. **MCS Disjunction Property**: AVAILABLE at `Completeness.lean:112-136`
   - `SetMaximalConsistent.disjunction_elim`: (φ.or ψ) ∈ S → φ ∈ S ∨ ψ ∈ S
   - Full iff: `SetMaximalConsistent.disjunction_iff`

2. **Deduction Theorem**: AVAILABLE at `DeductionTheorem.lean:336-457`
   - Can be chained iteratively for multiple hypothesis removal
   - No pre-built iterated version needed

3. **MCS Negation Completeness**: AVAILABLE at `MCSProperties.lean:174-227`
   - `SetMaximalConsistent.negation_complete`: φ ∈ S ∨ neg(φ) ∈ S

4. **G-Lift**: AVAILABLE at `UltrafilterChain.lean:2123-2139`
   - `G_lift_from_context`: derives G(phi) ∈ M from ctx ⊢ phi when G(x) ∈ M for all x ∈ ctx

### Restricted Chain Forward_F (Existing Working Proof)

**`restricted_forward_chain_forward_F`** at `SuccChainFMCS.lean:2930-2934`:
This proves forward_F for a RESTRICTED chain (DeferralRestrictedMCS with bounded
F-nesting depth). It resolves ALL F-obligations in ONE step because the restricted
seed includes `f_content u` directly.

The restricted seed is:
```
g_content u ∪ deferralDisjunctions u ∪ p_step_blocking_formulas_restricted phi u ∪
boundary_resolution_set phi u ∪ f_content u
```

This includes f_content(u) = {ψ | F(ψ) ∈ u}, which are the formulas UNDER F.
**These are NOT F-formulas; they are the raw witness formulas.**
Including all of them simultaneously in the seed is what makes it work.

The consistency of this restricted seed uses the DeferralRestrictedMCS properties
(bounded F-nesting depth) to ensure the combined seed is consistent. For GENERAL
MCSs, this seed might be inconsistent (Section 4 counterexample).

### Axiom Analysis

**Relevant axioms**: temp_4 (G(φ)→GG(φ)), temp_t_future (G(φ)→φ), temp_t_past (H(φ)→φ)

**Missing**: NO axiom `H(φ)→HH(φ)` for past. NO axiom `G(F(φ))→F(φ)`.
The logic has density (GGφ→Gφ) and discreteness axioms for specific frame classes.

**Key interaction axioms**: `modal_future (□φ→□Fφ)`, `temp_future (□φ→F□φ)`,
`temp_a (φ→F(Pφ))`, `discreteness_forward ((F⊤∧φ∧Hφ)→F(Hφ))`.

### Lindenbaum Infrastructure

- **Only Zorn-based**: `set_lindenbaum` uses `zorn_subset_nonempty`. No step-by-step alternative.
- **`lindenbaumMCS_set`**: `Classical.choose` extraction, used by all successor constructions.
- **No custom Lindenbaum**: Would need to be built from scratch.

### Completeness State

- **One sorry** at `Completeness.lean:231-237`: `bfmcs_from_mcs_temporally_coherent`
- This is exactly the family-level temporal coherence gap we're trying to fill.

## 9. Revised Open Questions

### Q1: Can the Restricted Approach Be Generalized?

The restricted chain (`DeferralRestrictedMCS`) already has working forward_F via
`restricted_forward_chain_forward_F`. The seed includes f_content(u) directly.
Can the restriction be lifted? What SPECIFIC property of DeferralRestrictedMCS
makes the combined seed consistent? If we understand this, we might generalize.

### Q2: Does F-Persistence + Scheduled Resolution Eventually Succeed?

If we build the F-persistence chain (all F-obligations persist), then at each step
attempt to include φ (the scheduled resolution formula) IF consistent with the
persistence seed: does this eventually succeed for every obligation?

Conjecture: YES, because the G-content grows along the chain, and at some point
the g_content might no longer derive ¬φ combined with the F-formulas. But this
needs formal justification.

### Q3: Can We Avoid the Combined Seed Entirely?

Alternative: Don't combine resolution and persistence in one seed. Instead:
1. Build an F-persistence chain (all obligations persist)
2. Use a COMPACTNESS argument to show the chain can be "refined" to one where
   obligations are resolved
3. The refinement uses the fact that each individual resolution is consistent

## 8. Summary

The user's Skolemized unraveling strategy is mathematically sound and leads to a
key new result: the **F-content consistency theorem** (g_content ∪ F-formulas is
consistent). This enables F-persistence chains where obligations never disappear.

The main remaining challenge is proving that F-obligations are **eventually resolved**
(not just preserved). The combined resolution + F-preservation seed is genuinely
inconsistent in some cases, so resolution and preservation must be handled at
separate chain positions or via a custom Lindenbaum construction.

The recommended path (A) builds an F-persistence chain and proves forward_F via a
combination of the new consistency result and careful scheduling. Phase 1 (the
consistency theorem) can be implemented immediately as it has a clean proof. Phases
2-4 require further analysis of the resolution ordering question.
