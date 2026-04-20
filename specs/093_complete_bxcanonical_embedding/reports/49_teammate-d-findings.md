# Teammate D: Strategic Horizons

## Key Findings

1. **The current architecture has hit a fundamental obstruction** that is intrinsic to ALL Lindenbaum-based chain constructions over integers. After 36 documented dead ends, the root cause is identified: `Classical.choose` in `set_lindenbaum` produces opaque MCS points with no inter-step structural guarantees. No syntactic argument can control what the Lindenbaum extension adds.

2. **The irreflexive semantics switch was necessary but insufficient.** It correctly blocks derivation-level re-entry (`phi -> F(phi)` unprovable), but the Lindenbaum extension operates at the set level, not the derivation level. The switch remains valuable for semantic reasons (cleaner Until/Since semantics, no degenerate X/Y collapse) but does not resolve the chain construction blocker.

3. **The literature identifies two proven approaches for Until/Since completeness over linear orders:**
   - **Step-by-step construction** (Reynolds 2003): Build the model incrementally using a "step" relation that directly encodes the Until/Since coherence requirement
   - **Filtration + finite model property** (Gabbay, Hodkinson, Reynolds 1994): For logics with FMP, reduce completeness to finite model construction

4. **The existing quasimodel infrastructure (2,289 lines, sorry-free) already provides the machinery needed** for an alternative completeness architecture. The key gap is bridging from abstract BXPoint chains to Int-indexed families.

5. **A semantic completeness proof (Goldblatt/GHR style) is the most promising path.** It avoids the syntactic chain construction entirely by building the canonical model with semantic witnesses via well-founded induction on formula complexity.

---

## Architecture Comparison

### Current Approach: Lindenbaum Chain over Integers

**Architecture**: Build an Int-indexed chain of MCS via iterated `set_lindenbaum` calls. Each chain step resolves one F-obligation. Temporal coherence proved syntactically.

**Strengths**:
- Conceptually simple
- Infrastructure largely built (1,681 lines in RootScopedChain.lean)
- Restricted truth lemma reduces requirements to `deferralClosure(root)` only

**Fatal weakness**: Lindenbaum extensions are opaque. Cannot prove:
- `F(phi) in chain(n) -> exists m > n, phi in chain(m)` (forward F-resolution)
- Until step transfer: `(phi U psi) in chain(n+1) AND phi in chain(n) -> (phi U psi) in chain(n)`
- Both require controlling what `.choose` adds, which is impossible by design

### Alternative A: Semantic/Model-Theoretic Construction (Reynolds/Goldblatt)

**Architecture**: Instead of building a single chain and proving properties about it, build the canonical model by defining `truth_at` directly via MCS membership, then prove the model satisfies the frame conditions by well-founded induction on formula depth.

**Key insight from the literature**: Burgess (1984) and Goldblatt (1992) prove completeness by:
1. Define the canonical frame: worlds = all MCS, temporal order = `bx_le`
2. Prove the truth lemma by induction on formula structure
3. For Until/Since: use the quasimodel construction (defect-discharge) as a subroutine to produce witnesses within the canonical frame

**This is exactly what the existing code already does** for the Frame.lean sorries (tasks 98, 102). The quasimodel infrastructure successfully closes `bx_until_eventuality_resolution` and `bx_since_eventuality_resolution`. The issue is that this proof works for the "global" canonical model (all MCS as worlds), but the Int-indexed parametric representation requires a SPECIFIC Int-indexed chain.

**Estimated delta**: Replace `dd_bfmcs` construction with a construction that uses the quasimodel-produced BXPoint witnesses directly, embedding them into an Int-indexed chain via a specific injection from the quasimodel chain endpoints.

### Alternative B: Filtration-Based (FMP Route)

**Architecture**: Show the logic has the finite model property, then reduce completeness to finite model checking.

**Key question**: Does this bimodal S5 + Until/Since logic have FMP?

**Literature assessment**: Pure Until/Since over linear orders (no modality) has FMP (Gabbay et al. 1994). However:
- Adding S5 modality does NOT break FMP for the temporal fragment
- The BX axioms with Until/Since over integers specifically are designed for a logic that has FMP (the subformula closure is finite, all relevant distinctions are captured by sigma-signatures)
- The existing `SubformulaClosure.lean` and `SigmaOrdering.lean` infrastructure already implements the filtration machinery

**Risk**: FMP gives decidability but does NOT directly give the representation theorem (canonical model construction with structural correspondence). The ROAD_MAP explicitly excludes this path for the representation theorem goal.

### Alternative C: Deterministic Chain with Hintikka Transfer

**Architecture**: Build a chain where each step is determined by the sigma-signature of the Hintikka quasimodel, rather than by opaque Lindenbaum extension.

**Key idea**: The quasimodel `QuasimodelChain` (in `Construction.lean`) produces a finite sequence of `HintikkaPoint Sigma` values with:
- G-propagation (guaranteed)
- H-backward (guaranteed)
- Until defect discharge (guaranteed, with termination proof)

If we could LIFT this finite chain to a full MCS chain (injecting each Hintikka point into an MCS that agrees on the sigma-closure), the coherence properties would transfer.

**This is what `Realization.lean` already does** -- it lifts Hintikka chains to BXPoint chains. The gap: the lifted BXPoints are not part of the same BFMCS family.

### Alternative D: Constrained Lindenbaum Extension (Handoff Approach A)

**Architecture**: Modify `set_lindenbaum` to exclude a specified finite set of formulas from the extension, ensuring resolved defects cannot be re-introduced.

**Key requirement**: Prove that excluding `{F(phi) | phi resolved}` from the extension is consistent with the seed `{target} union g_content(M)`.

**Under irreflexive semantics**: `phi -> F(phi)` is not derivable, so `F(phi)` is NOT forced by `g_content(M) union {phi}`. This means the constrained extension should be possible.

**Estimated effort**: 200-300 LOC (per handoff document)

**Risk assessment**: Medium. The constrained Lindenbaum requires proving a "consistent extension with exclusion" lemma, which is non-trivial but mathematically sound. The key lemma: if S is consistent and `psi` is not derivable from S, then S union {neg psi} is consistent (standard). Extended to finite exclusion sets via iterable application.

---

## Literature Assessment

### Burgess (1984) - "Axioms for Tense Logic II"

Burgess's completeness proof for Until/Since over linear orders uses:
1. **Canonical model**: worlds = MCS, ordering = g_content inclusion
2. **Truth lemma**: by induction on formula structure
3. **Until case**: Uses BX5 (self-accumulation) and BX10 (eventuality extraction) to find a witness. The witness is found within the canonical frame (set of all MCS), NOT along a specific chain.

**Critical observation**: Burgess does NOT build an Int-indexed chain. He works with the full canonical frame and uses Zorn's lemma / well-ordering to find witnesses. The Int-indexed chain is a formalization artifact needed for the parametric representation theorem.

### Reynolds (2003) - "An Axiomatization of PLTL"

Reynolds's approach for propositional linear temporal logic with Until:
1. Uses a **step-by-step** construction where each temporal successor is built with specific coherence guarantees
2. The key technique: **induction on the complexity of Until formulas**, resolving them in order of nesting depth
3. Does NOT rely on Lindenbaum extension -- uses direct construction

**Relevance**: Reynolds's approach could inspire a "resolve by complexity" strategy where simpler Until formulas are resolved first, providing witnesses for more complex ones.

### Gabbay, Hodkinson, Reynolds (1994) - "Temporal Logic: Mathematical Foundations and Computational Aspects"

The GHR canonical construction for Since/Until:
1. Works with a "one-step" relation on MCS
2. Builds temporal witnesses using a **dovetailing** construction
3. The key difference from our approach: they prove coherence SEMANTICALLY, not syntactically

**Gap identification**: Our approach tries to prove coherence syntactically (properties of the chain construction), while GHR proves it semantically (using the truth lemma itself in the induction).

### Formal Proof Assistant Literature

**Isabelle/HOL**: No known complete formalization of temporal logic with Until/Since completeness. The Isabelle AFP has LTL model checking but not completeness proofs.

**Coq**: Coq-community has "temporal-logic" with some completeness results for CTL, but not Since/Until over linear orders.

**Lean 4 / Mathlib**: No temporal logic completeness theorems in Mathlib as of April 2026. This formalization would be a first.

---

## Strategic Recommendation

### Primary Recommendation: Constrained Lindenbaum (Approach D)

**Rationale**: This is the smallest delta from the current state. It preserves all existing infrastructure (5,791 lines) and requires only:
1. A `constrained_set_lindenbaum` lemma (~100 LOC)
2. Proof that excluded formulas are not forced by the seed under irreflexive semantics (~100 LOC)
3. Rewiring `fwd_chain` to use constrained extension (~50 LOC)

**Why this works under irreflexive semantics**: The key property is that `F(phi)` is NOT derivable from `g_content(M) union {phi}` (because `phi -> F(phi)` requires BX1, which is removed). Therefore, `neg F(phi)` is consistent with the seed, meaning we can extend to an MCS that includes the seed but excludes `F(phi)`.

**Mathematical justification**: For any consistent set S and formula psi where psi is not derivable from S: S union {neg psi} is consistent. This is the Lindenbaum-with-exclusion principle. Applied iteratively for the finite set of resolved defects (bounded by `|sigma_list|`), we get a constrained extension excluding all of `{F(chi) | chi resolved at this step}`.

### Fallback Recommendation: Semantic Completeness Rewrite

If constrained Lindenbaum fails (due to unforeseen interactions between multiple excluded formulas), the fallback is:

1. **Abandon the Int-indexed chain entirely**
2. **Use the existing quasimodel infrastructure** to produce BXPoint witnesses directly
3. **Build the BFMCS by embedding quasimodel outputs** into integer positions

This requires more refactoring (~500-800 LOC) but has the advantage of reusing the sorry-free quasimodel machinery that already handles Until/Since correctly.

### What NOT to do

1. **Do NOT abandon the BXCanonical approach** -- 5,791 lines of sorry-free infrastructure represents months of work. The architecture is sound; only the chain construction needs fixing.
2. **Do NOT revert to reflexive semantics** -- the irreflexive switch correctly addresses derivation-level re-entry and provides cleaner semantics. The remaining issue (Lindenbaum opacity) exists under both semantics.
3. **Do NOT pursue FMP-based completeness** -- this does not provide the representation theorem which is the project's scientific goal.
4. **Do NOT add new axioms** (like a "next" operator) -- this changes the logic itself and invalidates the soundness theorem.

---

## Minimum Viable Path

**Goal**: Close 5 sorry sites in `RootScopedChain.lean` with minimal code changes.

### Step 1: Prove Constrained Lindenbaum Lemma (Priority: Critical)

```
theorem constrained_lindenbaum (S : Set Formula) (h_cons : SetConsistent S)
    (exclude : Finset Formula) (h_excl : ∀ ψ ∈ exclude, ¬ SetDerivable S ψ) :
    ∃ M : Set Formula, S ⊆ M ∧ SetMaximalConsistent M ∧ ∀ ψ ∈ exclude, ψ ∉ M
```

This requires proving that the standard Lindenbaum enumeration can avoid a finite set of non-derivable formulas. Under irreflexive semantics, `F(phi)` is not derivable from `g_content(M) union {phi}`.

### Step 2: Constrained Forward Step

Replace `fwd_succ` with a version that uses constrained Lindenbaum:
- At resolving step for phi: seed = `{phi} union g_content(M)`, exclude = `{F(chi) | chi in resolved_at_this_step}`
- At non-resolving step: seed = `g_content(M)`, exclude = `{F(chi) | F(chi) in M, chi in sigma_list, chi already resolved}`

### Step 3: Prove Active Defect Decrease

With constrained Lindenbaum:
- `active_defects(chain(n+1)) < active_defects(chain(n))` when defects exist
- Because: resolved phi is in M', F(phi) is EXCLUDED from M', so phi is no longer an active defect
- After at most `|sigma_list|` steps, no active defects remain

### Step 4: Close Forward F-Resolution

Once active defects decrease to zero, all `F(phi)` with `phi in sigma_list` are resolved: there exists a step where phi is present.

### Step 5: Close Until/Since Coherence

Until coherence follows from:
- BX12: `F(psi) -> (top U psi)` converts F-witness to Until-witness
- Forward F-resolution provides the F-witness
- BX5 (self-accumulation) provides the guard property
- Backward Until uses the dual argument with P-resolution

---

## Risk Assessment

| Approach | Success Probability | Effort | Risk Factor |
|----------|-------------------|--------|-------------|
| Constrained Lindenbaum | 65% | 200-300 LOC | Multi-formula exclusion interaction |
| Semantic rewrite (quasimodel embedding) | 75% | 500-800 LOC | BXPoint-to-Int bridging complexity |
| Current approach (no change) | 0% | N/A | Fundamentally blocked (36 dead ends) |
| FMP route | 50% | 1000+ LOC | Does not give representation theorem |
| Full architectural rewrite | 80% | 2000+ LOC | Time cost, regression risk |

### Key Risk for Constrained Lindenbaum

The constrained Lindenbaum principle is mathematically standard (it follows from the deduction theorem applied iteratively). The risk is whether:
1. The excluded set `{F(chi) | chi resolved}` is genuinely not derivable from the seed
2. Multiple exclusions interact (e.g., excluding both F(alpha) and F(beta) simultaneously)

Under irreflexive semantics, (1) holds because `phi -> F(phi)` is not derivable. For (2), the exclusions are independent (each `neg F(chi_i)` is consistent with the seed independently, and their conjunction is also consistent because they are syntactically independent -- no BX axiom derives `F(chi_i)` from `F(chi_j)` for distinct subformulas).

### Key Risk for Semantic Rewrite

The quasimodel infrastructure produces BXPoint chains with correct coherence, but these chains are finite (bounded by defect count). The Int-indexed BFMCS requires an infinite chain. The bridging strategy:
- Embed the finite quasimodel chain into positions [0, k]
- Extend to negative integers via backward dual
- Extend beyond k by repeating the pattern (using schedule surjectivity)

This is technically feasible but requires careful engineering.

---

## Confidence Level

**Overall assessment**: The completeness theorem IS achievable with the current axiom system and infrastructure. The obstruction is in the PROOF TECHNIQUE (Lindenbaum-based chains), not in the MATHEMATICS (the logic is complete over linear orders -- this is a theorem of Burgess 1984).

**Confidence in constrained Lindenbaum approach**: 65%
- Mathematically sound
- Smallest code delta
- Risk: multi-exclusion interaction under complex seeds

**Confidence in semantic rewrite**: 75%
- Proven approach in the literature (GHR 1994)
- Existing sorry-free infrastructure covers most cases
- Risk: engineering complexity of BXPoint-to-Int embedding

**Confidence that SOME approach succeeds within 500 LOC**: 85%

**Recommendation**: Try constrained Lindenbaum first (2-3 days effort). If blocked by multi-exclusion interaction, pivot to semantic rewrite using existing quasimodel infrastructure.
