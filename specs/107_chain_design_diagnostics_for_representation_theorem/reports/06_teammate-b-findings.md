# Teammate B Findings: Minimal Box+G+H Representation Theorem

**Task**: 107 - Chain design diagnostics for representation theorem
**Angle**: Alternative Approaches -- Minimal representation theorem feasibility
**Round**: 6
**Date**: 2026-04-23

## Executive Summary

A minimal representation theorem for the Box+G+H fragment (no Until/Since) is **dramatically simpler** than the full BX system and can be proven using a direct adaptation of Verbrugge's Theorem 1 (Lin completeness). The key insight is that ALL five sorry sites in RootScopedChain.lean are caused by Until/Since coherence obligations -- none arise from Box, G, or H alone. A Box+G+H completeness proof would have **zero sorry sites** using the existing infrastructure plus a standard step-by-step construction. This provides a viable strategy: prove the minimal result first, then layer Until/Since on top.

## Question 1: Standard Completeness Proof for S5 + Kt.4 (Box + G/H)

### The Logic

The system S5 + Kt.4 combines:
- S5 modal logic for Box (reflexive, transitive, symmetric accessibility)
- Tense logic with G (always future) and H (always past) over linear time
- The temporal 4 axiom: G(phi) -> G(G(phi))
- Interaction axioms: Box(phi) -> Box(G(phi)), Box(phi) -> G(Box(phi))

In the BX axiom system, this corresponds to the subset:
- **Propositional** (4): prop_k, prop_s, ex_falso, peirce
- **S5 Modal** (5): modal_t, modal_4, modal_b, modal_5_collapse, modal_k_dist
- **Temporal G/H** (6): temp_k_dist, temp_4, temp_t_future (BX1), temp_t_past (BX1'), temp_linearity (BX11), temp_linearity_past (BX11')
- **Interaction** (2): modal_future, temp_future

**Total**: 17 axioms (versus 37 for full BX)

**Rules**: Modus ponens, modal necessitation, temporal necessitation (G and H).

### The Completeness Proof Structure (Verbrugge Theorem 1)

Verbrugge's proof of Lin completeness (Theorem 1 in the 2004 paper) directly applies:

**Construction**:
1. Given Sigma not-provable phi, extend Sigma union {neg phi} to an MCS Gamma_star via Lindenbaum.
2. Set T_0 = {t_star}, Gamma_{t_star} = Gamma_star.
3. Enumerate all formulas phi_0, phi_1, phi_2, ... (each infinitely often).
4. At Stage n+1: for each t in T_n with neg(G(phi_n)) in Gamma_t:
   - Find the maximal such t.
   - If no t' > t already has neg(phi_n), use Lemma 4 to create a new Gamma = Delta with Gamma_t prec Delta and neg(phi_n) in Delta.
   - Insert Delta as an immediate successor of t in T_n.
   - The non-branching property of prec guarantees linear ordering is maintained.
5. Symmetrically for neg(H(phi_n)).
6. Take T = union of all T_n.

**Why this works**: The prec relation (Gamma prec Delta iff for all G(phi) in Gamma, phi in Delta) is:
- Not branching to the future (from BX11 / temp_linearity)
- Not branching to the past (from BX11' / temp_linearity_past)
- Transitive (from temp_4 / G(phi) -> G(G(phi)))

The inserted Delta fits into the existing order because non-branching forces Delta prec Gamma_{t'} or Gamma_{t'} prec Delta or Delta = Gamma_{t'}, and only one case is consistent with the formulas.

**There is no need for**:
- Chronicles or binary interval functions g(x,y)
- Until/Since witness propagation
- F-preservation or perpetual deferral workarounds
- The BX11 enriched fold mechanism
- Any of the machinery that created the 5 sorry sites

### Lindenbaum-based Canonical Model

Yes, a standard Lindenbaum canonical model works. The construction is:
1. Take all MCS as worlds.
2. Define prec as above.
3. Build a linear chain by iterative point insertion (Verbrugge's method).
4. The chain satisfies conditions (a)-(d) from Theorem 1.
5. The resulting model is a countermodel.

This is the textbook Henkin-style completeness proof for temporal logic.

## Question 2: Why Box+G+H Is Easier Than Box+G+H+U+S

### The Core Difference: No Guard Condition Problem

The fundamental difficulty with Until/Since completeness is the **guard condition**:

- `phi U psi` at time t requires: there exists s >= t with psi(s), AND for all r in [t,s), phi(r).
- The canonical model must produce **both** the witness s AND ensure phi holds at every intermediate point.

For G/H, the analogous requirements are:
- `G(phi)` at time t requires: for all s >= t, phi(s).
- `F(phi)` (= neg G neg phi) at time t requires: there exists s >= t with phi(s).

The F-eventuality requirement is **exactly** what Lemma 4 provides: create one point with the desired formula. There is no guard interval. There is no need to ensure anything about intermediate points.

### Mapping to the Five Sorry Sites

All five sorry sites in RootScopedChain.lean trace back to Until/Since coherence:

| Sorry Site | Line | Obligation | Box+G+H? |
|-----------|------|------------|----------|
| `fwd_chain_forward_F` | 1143 | F(phi) resolution through chain | **Trivial** for G/H: Lemma 4 creates witness directly |
| backward chain F-case | 1170 | F(phi) in backward chain region | **Not needed**: symmetric Lemma 4 for past |
| backward P-resolution | 1177 | P(phi) resolution | **Trivial**: mirror of forward case |
| `dd_bfmcs_restricted_buc` | 1203 | Backward Until/Since coherence | **Does not exist** in Box+G+H fragment |
| `dd_bfmcs_restricted_fuc` | 1210 | Forward Until/Since coherence | **Does not exist** in Box+G+H fragment |

For the Box+G+H fragment:
- Sorry sites 4 and 5 simply do not exist (no Until/Since formulas).
- Sorry sites 1, 2, 3 become trivial because F(phi) resolution requires only inserting a single point (Lemma 4), not managing a chain of guard conditions.

### The F-Propagation Problem Is Specific to Until/Since

The "F-propagation" blocker that blocked the current proof is specific to Until/Since:

**The problem**: When resolving F(phi) by stepping to a new MCS M', the new M' may contain new F-obligations (F(chi)). These obligations can perpetually regenerate, causing "infinite deferral."

**Why this happens with Until**: U(phi, psi) implies F(psi) (by BX10). When we extend the chain to resolve F(psi), the new MCS may contain U(phi', psi') which generates F(psi'). The chain never terminates.

**Why this does NOT happen with just G/H**: F(phi) is the ONLY eventuality. When we insert a point with phi via Lemma 4, the phi is simply a formula -- it does not generate new F-obligations (unless phi itself contains F subformulas, but these are handled by the infinite enumeration). Each formula is treated at some stage, and the insertion is permanent.

### Verbrugge Theorem 1 Works Without Modification

Verbrugge's Theorem 1 (Lin completeness) proves exactly Box+G+H completeness over arbitrary linear orders. The proof works without any modification for the project's reflexive semantics because:

1. Verbrugge uses strict prec (non-reflexive), and the project's semantics for G/H are reflexive (using <=). But the BX1 axiom (G(phi) -> phi) ensures that if G(phi) is in an MCS, then phi is also in that MCS. So reflexivity at the semantic level is handled by the axiom.

2. The interaction axioms (Box(phi) -> Box(G(phi)) and Box(phi) -> G(Box(phi))) are directly present in the BX system as `modal_future` and `temp_future`. These are handled by the standard BFMCS modal coherence construction.

3. The linearity axiom BX11 provides the non-branching property.

## Question 3: How to Add Until/Since AFTER Box+G+H Completeness

### Approach 1: Conservative Extension (NOT viable)

Until/Since is NOT definable in terms of G/H alone. The expressiveness hierarchy is strict: G/H can express "always" and "eventually," but Until requires "bounded eventuality with guard." So there is no conservative extension theorem that would lift G/H completeness to G/H/U/S completeness.

### Approach 2: Layered Representation Theorem (VIABLE)

The parametric representation framework in the project already supports this approach:

**Step 1: Prove Box+G+H representation** (this teammate's proposal).
- Construct a BFMCS with temporally_coherent property (forward_F + backward_P).
- This resolves sorry sites 1, 2, 3.

**Step 2: Strengthen the construction to satisfy Until/Since coherence**.
- Starting from the G/H-coherent linear chain, add Until/Since witness points.
- This is exactly Burgess's approach: start with a chronicle satisfying G/H properties, then fix Until/Since defects by point insertion.

**Step 3: Prove the full representation theorem**.
- Use the parametric_algebraic_representation_conditional with the strengthened BFMCS.

The key advantage of this layered approach: Step 1 produces a **working** completeness result for the G/H fragment, even if Step 2 is still open. This provides:
- A milestone deliverable
- Confidence that the infrastructure works
- A clear interface for what Until/Since coherence must provide

### Approach 3: Burgess Chronicle over G/H Base (MOST PROMISING)

Combine approaches:
1. Use Verbrugge Theorem 1 construction for the G/H backbone.
2. Add Burgess's chronicle structure (binary g(x,y)) for Until/Since.
3. The G/H backbone ensures temporal coherence; the chronicle adds Until/Since coherence.

This avoids the architectural mismatch identified in round 5 (unary g_content vs binary g(x,y)) by building the right structure from the start.

### What the Literature Says

The standard approach in the literature (Burgess 1982, Xu 1988) is to prove completeness for the FULL language including Until/Since all at once. The G/H-only case is considered a simpler special case that appears in earlier work (Segerberg 1971, van Benthem 1983).

There is no published paper that explicitly proves G/H completeness and then extends to Until/Since. However, the Verbrugge paper provides exactly the right intermediate results:
- Theorem 1 (Lin) handles G/H
- The discrete construction (Theorem 6, Z) handles G/H on integers
- Until/Since would be an unpublished extension

## Question 4: Axiom System for Box+G+H over TaskFrames

### Exact Axiom List

**Retain from BX**:
| # | Name | Formula | Status |
|---|------|---------|--------|
| 1 | prop_k | (phi -> (psi -> chi)) -> ((phi -> psi) -> (phi -> chi)) | Keep |
| 2 | prop_s | phi -> (psi -> phi) | Keep |
| 3 | ex_falso | bot -> phi | Keep |
| 4 | peirce | ((phi -> psi) -> phi) -> phi | Keep |
| 5 | modal_t | Box(phi) -> phi | Keep |
| 6 | modal_4 | Box(phi) -> Box(Box(phi)) | Keep |
| 7 | modal_b | phi -> Box(Diamond(phi)) | Keep |
| 8 | modal_5_collapse | Diamond(Box(phi)) -> Box(phi) | Keep |
| 9 | modal_k_dist | Box(phi -> psi) -> (Box(phi) -> Box(psi)) | Keep |
| 10 | temp_k_dist | G(phi -> psi) -> (G(phi) -> G(psi)) | Keep |
| 11 | temp_4 | G(phi) -> G(G(phi)) | Keep |
| 12 | temp_t_future (BX1) | G(phi) -> phi | Keep |
| 13 | temp_t_past (BX1') | H(phi) -> phi | Keep |
| 14 | temp_linearity (BX11) | F(phi) and F(psi) -> F(phi and psi) or F(phi and F(psi)) or F(F(phi) and psi) | Keep |
| 15 | temp_linearity_past (BX11') | (past mirror of BX11) | Keep |
| 16 | modal_future | Box(phi) -> Box(G(phi)) | Keep |
| 17 | temp_future | Box(phi) -> G(Box(phi)) | Keep |

**Drop from BX** (Until/Since specific):
| # | Name | Reason |
|---|------|--------|
| BX2/BX2' | left_mono_until/since | Until/Since only |
| BX3/BX3' | right_mono_until/since | Until/Since only |
| BX4/BX4' | connect_future/past | Uses some_past/some_future with Until/Since |
| BX5/BX5' | self_accum_until/since | Until/Since only |
| BX6/BX6' | absorb_until/since | Until/Since only |
| BX7/BX7' | linear_until/since | Until/Since only |
| BX8/BX8' | refl_intro_until/since | Until/Since only |
| BX9/BX9' | until_elim/since_elim | Until/Since only |
| BX10/BX10' | until_F/since_P | Until/Since only |
| BX12/BX12' | F_until_equiv/P_since_equiv | Until/Since only |

**New axioms needed?**
- **No.** BX4 (connect_future: phi -> G(P(phi))) is definable purely in terms of G/H/F/P and does not require Until/Since. However, in the current formulation it uses `some_past` which is `neg(H(neg(phi)))`, which is expressible in the G/H fragment. So BX4/BX4' SHOULD be kept. Let me reconsider:

**Revised: Keep BX4/BX4'**:
- BX4: `phi -> G(P(phi))` -- uses G, P (= neg H neg), no Until/Since
- BX4': `phi -> H(F(phi))` -- uses H, F (= neg G neg), no Until/Since

These are expressible in the G/H fragment and are needed for the prec relation properties.

**Total for G/H fragment**: 19 axioms (4 propositional + 5 modal + 8 temporal G/H + 2 interaction).

### Comparison with Verbrugge's Lin Axioms

Verbrugge's Lin has:
- All tautologies (covered by prop_k, prop_s, ex_falso, peirce)
- G(phi -> psi) -> (G(phi) -> G(psi)) = temp_k_dist
- H(phi -> psi) -> (H(phi) -> H(psi)) = derivable from past necessitation
- PG(phi) -> phi = equivalent to BX4 + BX1' (past version of connect + T)
- FH(phi) -> phi = mirror
- G(phi) -> GG(phi) = temp_4
- F(phi) -> G(phi or P(phi) or F(phi)) = follows from BX11 + BX4

So the project's BX subset for G/H is a CONSERVATIVE extension of Lin (it adds S5 modal axioms and interaction axioms on top). The temporal core matches exactly.

## Question 5: Reusable Infrastructure

### Direct Reuse (no changes needed)

| Module | Lines | Why Reusable |
|--------|-------|-------------|
| `ParametricRepresentation.lean` | 300 | Parametric D, requires BFMCS + coherence conditions. For G/H, only needs `temporally_coherent` (no Until/Since coherence). |
| `RestrictedParametricTruthLemma.lean` | 200 | Truth lemma. For G/H fragment, the Until/Since cases in the truth lemma are vacuously true (no Until/Since formulas in the subformula closure of a G/H formula). |
| `Completeness.lean` | 528 | MCS properties (conjunction, disjunction, box closure). All G/H compatible. |
| `Frame.lean` | 673 | BXPoint infrastructure, MCS wrappers. Fully general. |
| `WitnessSeed.lean` | 200+ | `forward_temporal_witness_seed_consistent` and `past_temporal_witness_seed_consistent` are the EXACT tools needed for Lemma 4 (point insertion). Sorry-free! |
| `TemporalCoherence.lean` | 620 | `TemporalCoherentFamily`, backward G/H lemmas. The core infrastructure for the G/H truth lemma. |
| `BFMCS.lean` | 150+ | Bundle structure. For G/H, we only need `temporally_coherent`, not `until_since_coherent`. |
| `FMCS.lean` / `FMCSDef.lean` | 80+ | Family of MCS definition. Fully compatible. |
| `ParametricCanonical.lean` | ~300 | D-parametric TaskFrame construction. General purpose. |
| `ParametricHistory.lean` | ~200 | D-parametric history conversion. General purpose. |
| `ParametricTruthLemma.lean` | ~400 | D-parametric truth lemma. G/H cases sorry-free; Until/Since cases would be vacuous. |
| `MaximalConsistent.lean` | ~400 | Lindenbaum lemma, MCS properties. Foundational. |
| `MCSProperties.lean` | ~600 | MCS temporal propagation. Essential for G/H chain construction. |

**Total directly reusable**: ~4000+ lines, all sorry-free.

### Needs Adaptation

| Module | Lines | What Changes |
|--------|-------|-------------|
| `RootScopedChain.lean` | ~1200 | Replace the dovetailed chain with Verbrugge Theorem 1 construction. This is the ONLY file that needs significant rewriting. |
| `OrderedSeedConsistency.lean` | 255 | May simplify: no need for ordered seeds with Until/Since formulas. |

### Not Needed for G/H

| Module | Reason |
|--------|--------|
| `UntilSinceCoherence.lean` | Until/Since specific |
| `Quasimodel/*.lean` (1816 lines) | Until/Since defect tracking |
| `Filtration/*.lean` | Not needed for step-by-step construction |

## Detailed Implementation Proposal

### Phase 1: G/H Chain Construction (25-35 hours)

Replace the dovetailed chain construction with Verbrugge Theorem 1:

1. **Define the prec relation on MCS** (2 hours):
   ```
   def mcs_prec (Gamma Delta : Set Formula) : Prop :=
     ∀ phi, Formula.all_future phi ∈ Gamma → phi ∈ Delta
   ```
   Prove: non-branching (from BX11), transitive (from temp_4).

2. **Point insertion lemma** (= Lemma 4) (4 hours):
   Already essentially proven as `forward_temporal_witness_seed_consistent`.
   Need to wrap it with prec compatibility:
   ```
   theorem point_insertion_forward (Gamma : Set Formula) (h : SetMaximalConsistent Gamma)
       (phi : Formula) (h_neg_G : neg(G(phi)) ∈ Gamma) :
       ∃ Delta, SetMaximalConsistent Delta ∧ mcs_prec Gamma Delta ∧ neg(phi) ∈ Delta
   ```

3. **Non-branching insertion lemma** (4 hours):
   When inserting Delta between Gamma and Gamma', show Delta fits:
   ```
   theorem insertion_fits (Gamma Delta Gamma' : Set Formula) 
       (h_prec : mcs_prec Gamma Gamma') (h_new : mcs_prec Gamma Delta) :
       mcs_prec Delta Gamma' ∨ Delta = Gamma' ∨ mcs_prec Gamma' Delta
   ```
   Uses BX11 (temp_linearity).

4. **Iterative chain construction** (8 hours):
   Build the omega-indexed chain using dovetailing over formula enumeration.
   Each stage inserts at most one point per direction per formula.
   The construction is DETERMINISTIC (no oracle needed).

5. **Wrap as TemporalCoherentFamily** (4 hours):
   Prove forward_F and backward_P from the chain construction.
   This is where the sorry sites would have been, but for G/H they close by construction.

6. **Wrap as BFMCS** (3 hours):
   Construct the modal bundle using existing `ModalSaturation.lean` infrastructure.

### Phase 2: Plug into Parametric Representation (5-8 hours)

1. Provide the `construct_bfmcs` function for `parametric_algebraic_representation_conditional`.
2. Prove `temporally_coherent` for the G/H BFMCS.
3. The Until/Since coherence obligations (`backward_until_since_coherent`, `forward_until_since_coherent`) are vacuously true for formulas in the G/H fragment.

### Phase 3: Completeness Statement (2-3 hours)

State and prove the G/H fragment completeness theorem:
```
theorem gh_completeness (phi : Formula) (h_gh : isGHFormula phi)
    (h_valid : valid phi) : Nonempty (DerivationTree [] phi)
```

### Total Estimate: 32-46 hours

### Risk Assessment

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| BX11 non-branching proof harder than expected | Low | Medium | Well-known result in literature; existing BX11 infrastructure available |
| Insertion lemma requires careful handling of prec | Medium | Low | Standard proof; Verbrugge provides the exact argument |
| Formula enumeration dovetailing issues | Low | Low | Existing dovetailing infrastructure in project |
| Truth lemma Until/Since cases not vacuous | Very Low | High | Verify `isGHFormula` predicate filters correctly |

## Key Insight: The Architecture IS the Problem

The current project's architecture (unary `g_content(M)`, dovetailed chain with BX11 fold for F-resolution) was designed to handle Until/Since simultaneously with G/H. This created an unnecessarily complex construction where the G/H part is "infected" by the Until/Since difficulties.

By separating the concerns:
1. Prove G/H completeness first using the SIMPLE construction (Verbrugge Theorem 1).
2. Then extend to Until/Since using Burgess's chronicle technique.

The separation eliminates 80% of the complexity for the first milestone and provides a clear interface for the second.

## Recommendation

**Strongly recommend pursuing the minimal Box+G+H representation theorem as the immediate next step.** The construction is well-understood, maps directly to existing infrastructure, and produces a working completeness result with zero sorry sites. This unblocks the project's metalogic goals while the harder Until/Since problem is addressed separately.

The estimated effort (32-46 hours) is approximately ONE-THIRD of the full Burgess chronicle approach (105-155 hours from round 5), and the risk profile is dramatically better because the construction is a textbook technique with no novel mathematical challenges.
