# Teammate B Findings: Alternative Approaches to Until/Since Coherence

**Task**: 84 -- Establish `until_since_coherent` for Bundle Completeness
**Focus**: Alternative approaches that bypass enriched seed construction
**Date**: 2026-04-07

## 1. Boneyard DeterministicFMCS Analysis

**File**: `Theories/Bimodal/Boneyard/ChainCompleteness/Algebraic/DeterministicFMCS.lean`

### What Was Attempted

The deterministic chain approach builds a single chain of MCS indexed by integers, where each step is fully deterministic (no Lindenbaum choices). The `usc` theorem at line 477 attempts to prove `until_since_coherent` with a 4-way split:

1. **Forward Until** (line 483): `sorry` -- needs to find a witness s >= t where psi holds
2. **Backward Until** (lines 485-493): **Proved** using `backward_until_chain` + backward induction
3. **Forward Since** (line 495): `sorry` -- symmetric to forward Until
4. **Backward Since** (lines 497-504): **Proved** using `backward_since_chain` + backward induction

### Why It Failed

Two independent blocking issues:

**Issue A -- Forward directions need eventuality resolution**: Forward Until requires finding s >= t with psi at s. The deterministic chain has `(phi U psi)` at t but needs to argue psi eventually holds somewhere along the chain. This is precisely the same eventuality resolution problem that appears in all approaches. The FiniteDeferral module (also in Boneyard) attempted to bound the deferral distance using BX5 (self-accumulation) + BX6 (absorption) but got stuck.

**Issue B -- `until_intro` / `since_intro` are no longer axioms**: The backward directions use `sorry /- until_intro removed in BX -/` at lines 371, 395, 427, 451. The old axiom system had explicit `until_intro: X(psi v (phi ^ (phi U psi))) -> (phi U psi)` and `since_intro: Y(psi v (phi ^ (phi S psi))) -> (phi S psi)`. These were removed when the axiom system was refactored to BX1-BX10. The backward proofs are structurally correct but blocked on deriving `until_intro`/`since_intro` from the current BX axioms.

### Salvageable Infrastructure

- `backward_until_chain` and `backward_since_chain`: correct proof structure for backward directions, just need the `until_intro`/`since_intro` derived rules
- `until_unfold_x_in_mcs` / `since_unfold_y_in_mcs`: useful for propagating obligations
- `deterministic_chain_mcs`: every position on the chain is MCS (sorry-free)
- `x_mem_chain_general` / `y_mem_chain_general`: X/Y content propagation

**Feasibility**: MARGINAL -- backward directions are close to done if `until_intro`/`since_intro` can be derived from BX axioms; forward directions need independent eventuality resolution work.

**Effort**: 2-4 days for backward (deriving `until_intro`/`since_intro`), unknown for forward.

---

## 2. FMP (Finite Model Property) Path

### Existing Infrastructure

The FMP module (`Theories/Bimodal/Metalogic/Decidability/FMP/`) has:

- `ClosureMCS`: Closure-restricted MCS
- `Filtration`: Quotient construction by closure equivalence
- `FiniteModel`: Finiteness proof (size <= 2^|closure(phi)|)
- `TruthPreservation`: Infrastructure only (not completed)
- `FMP.lean`: Main theorems: `mcs_finite_model_property`, `fmp_contrapositive`

### Can FMP Give Completeness Without Chain Construction?

**Short answer: No, not in current state.**

The FMP module proves MCS-level results: "if phi not provable, there exists a closure MCS where phi is absent, and the set of such MCS is finite." The `fmp_contrapositive` theorem (line 206) says: if phi is in ALL closure MCS, then phi is provable.

However, this does NOT give completeness. Completeness requires: if phi is valid (true in all *models*), then provable. The gap is:
- FMP works at the MCS membership level
- Completeness needs truth in semantic models (TaskFrame, TaskModel, truth_at)
- The connection between MCS membership and truth_at IS the truth lemma, which IS what needs `until_since_coherent`

The `TruthPreservation.lean` module only has infrastructure stubs -- it defines `mcsTruth` (membership) and `filteredMcsTruth` (lifted to quotient) but does not have a full filtration lemma. The filtration lemma for Until/Since would need the same eventuality resolution.

### Could FMP + Decidability Imply Completeness?

Theoretically: if TM has FMP and is decidable, then completeness follows by: "enumerate finite models up to size 2^|closure(phi)|; if phi valid, it's true in all finite models, so by FMP contrapositive it's provable."

In practice this is **circular**: the `fmp_contrapositive` already gives this, but it requires proving that MCS membership = truth, which is the truth lemma, which needs Until/Since coherence.

**Feasibility**: BLOCKED -- FMP does not bypass the truth lemma gap.

**Effort**: Not applicable.

---

## 3. Published Proofs and BXCanonical Path

### Axiom System

The axiom system is BX1-BX10 (with primed variants for past direction), totaling 22 temporal axioms. Key Until/Since axioms:

| Axiom | Statement | Role |
|-------|-----------|------|
| BX5 | `(phi U psi) -> ((phi ^ (phi U psi)) U psi)` | Self-accumulation: enriches guard with eventuality |
| BX6 | `(phi U (phi ^ (phi U psi))) -> (phi U psi)` | Absorption: prevents infinite deferral |
| BX7 | `(phi U psi) ^ (chi U theta) -> ...` | Linearity: witnesses are totally ordered |
| BX8 | `psi -> (phi U psi)` | Reflexive introduction (s = t witness) |
| BX9 | `(phi U psi) -> (phi v psi)` | Elimination: current time is guard or witness |
| BX10 | `(phi U psi) -> F(psi)` | Eventuality extraction |

### BXCanonical Approach (Theories/Bimodal/Metalogic/BXCanonical/)

The BXCanonical module takes a different approach from the Bundle path:
- Points are individual BXPoints (wrapping MCS)
- Temporal ordering: w <= v iff g_content(w) subset v
- Does NOT use FMCS chains at all

The truth lemma (TruthLemma.lean) is complete for atom, bot, imp, box, G, H. For Until/Since, it delegates to:
- `bx_until_eventuality_resolution` (Frame.lean line 541): sorry
- `bx_since_eventuality_resolution` (Frame.lean line 583): sorry

These use a Zorn-based argument: given `(phi U psi)` at w with psi not at w, find a <=maximal v above w where psi is still deferred. Then BX10 gives F(psi) at v, so psi must hold somewhere above v. The gap is **proving linearity of bx_le on the interval [w, v]**, which is needed to use the BX7 (linearity) and guard arguments.

The BXCanonical completeness theorem (`bx_completeness`, line 124) is sorry'd pending the canonical model embedding.

### Key Insight About BXCanonical vs Bundle

The BXCanonical path has a fundamentally different structure from the Bundle path:
- BXCanonical works with individual MCS points and a partial order
- Bundle works with FMCS families (chains of MCS)
- BXCanonical's eventuality resolution is a Zorn/maximality argument
- Bundle's eventuality resolution is a chain construction argument

Both hit the same fundamental obstacle: **proving that the canonical temporal ordering is total (linear) on relevant intervals**. This is mathematically equivalent -- BX7 (linearity axiom) should give this, but extracting it requires careful handling.

**Feasibility**: MARGINAL -- BXCanonical is a genuine alternative path but hits the same mathematical obstacle (linearity).

**Effort**: 5-10 days to complete the BXCanonical path from scratch.

---

## 4. Weakening `until_since_coherent`

### Current Definition

The full definition (TemporalCoherence.lean line 466) requires for each family, all four directions:
1. Forward Until: `(phi U psi) in fam.mcs t -> exists s >= t, psi at s, phi on [t,s)`
2. Backward Until: witness exists -> `(phi U psi) in fam.mcs t`
3. Forward Since: `(phi S psi) in fam.mcs t -> exists s <= t, psi at s, phi on (s,t]`
4. Backward Since: witness exists -> `(phi S psi) in fam.mcs t`

### How `h_uc` Is Actually Used in the Truth Lemma

Reading `restricted_shifted_truth_lemma` (CanonicalConstruction.lean lines 973-1002):

**Until case (untl phi psi)**:
- Forward direction (MCS -> truth): uses `h_fwd_U` (forward Until) to get witness s, then applies IH
- Backward direction (truth -> MCS): uses `h_bwd_U` (backward Until) to convert semantic witness back to MCS membership

**Since case (snce phi psi)**:
- Forward direction: uses `h_fwd_S` (forward Since)
- Backward direction: uses `h_bwd_S` (backward Since)

**All four components are used.** Both directions of both operators.

### Could Only Forward Until/Since Suffice?

No. The backward directions (truth -> MCS) are needed for the completeness argument. The validity hypothesis gives truth_at, and we need to convert back to MCS membership to reach contradiction.

### Could We Restrict to Subformulas of Root?

**This is promising.** The restricted truth lemma already restricts to `phi in subformulaClosure root`. A `restricted_until_since_coherent` would only need to handle Until/Since formulas that appear in the subformula closure. This means:

- Only finitely many Until/Since obligations (bounded by |subformulaClosure(root)|)
- Each obligation involves specific phi, psi that are subformulas of root
- The enriched seed approach already works formula-by-formula

However, **no `restricted_until_since_coherent` definition exists yet** in the codebase. Creating one is straightforward but requires modifying the restricted truth lemma signature.

**Feasibility**: VIABLE as a simplification of the main approach, not a bypass.

**Effort**: 1 day to define + wire, but does not eliminate the core difficulty.

---

## 5. Direct Proof via MCS Properties (No Chain Construction)

### What BX Axioms Give for a Single MCS

Given `(phi U psi) in w` for MCS w:

| Axiom | Derived Fact |
|-------|-------------|
| BX9 (until_elim) | `phi v psi in w` (either guard or witness at current time) |
| BX10 (until_F) | `F(psi) in w` (psi eventually holds) |
| BX5 (self_accum) | `((phi ^ (phi U psi)) U psi) in w` (enriched guard) |
| BX8 (refl_intro) | If `psi in w`, then `(phi U psi) in w` (trivially) |

The critical question: can we derive the full interval semantics from single-MCS properties alone?

**Answer: No.** The forward direction requires finding a *specific time s* in the *same family* where psi holds, with phi holding at all intermediate times. This is inherently a multi-step property that cannot be derived from any single MCS. The BX10 axiom gives `F(psi) in w`, which means "there exists some future time with psi," but this witness is at the F/P level, not at the interval level.

The chain construction is needed precisely to turn `F(psi) in w` into "psi at specific chain position s" and then argue that phi persists on the interval [t, s).

### Could Backward Until Be Proved Without Chains?

Partially. Given `psi at s` and `phi on [t,s)` in the same family, we need `(phi U psi) at t`. This requires:
- The `until_intro` derived rule: `X(psi v (phi ^ (phi U psi))) -> (phi U psi)`
- Which needs x_content chain structure (consecutive MCS in the family)

So even backward Until needs the FMCS chain structure (not arbitrary MCS).

**Feasibility**: BLOCKED -- interval semantics fundamentally requires chain structure.

**Effort**: Not applicable.

---

## 6. Restricted Approach Analysis

### Current State of `restricted_bundle_validity_implies_provability`

The restricted completeness theorem (FrameConditions/Completeness.lean line 341) has:
- `h_tc : B.restricted_temporally_coherent phi` -- **sorry-free** (via dovetailed chain, line 447)
- `h_uc : B.until_since_coherent` -- **sorry** (line 356/450)

The restricted temporal coherence works because the dovetailed chain has sorry-free `forward_F` and `backward_P`. But `until_since_coherent` is NOT restricted -- it's the full version.

### Could `until_since_coherent` Be Restricted?

Yes, and this is the most promising alternative simplification. A `restricted_until_since_coherent root` would only require the four Until/Since directions for formulas `phi, psi` that are subformulas of `root`.

**What this buys**:
- Only finitely many Until/Since obligations (those appearing as subformulas)
- The enriched seed only needs to handle these specific formulas
- The chain construction only needs to resolve specific eventualities

**What this does NOT buy**:
- The core difficulty (forward Until eventuality resolution) remains identical
- The mathematical argument for finding psi-witnesses is the same
- The Lindenbaum extension / x-content propagation issues persist

### The Dovetailed Path

The dovetailed completeness (`dovetailed_bundle_validity_implies_provability`, line 435) already uses restricted temporal coherence (sorry-free) but still needs unrestricted `until_since_coherent`. If restricted_uc were sufficient, the change would be:

1. Define `BFMCS.restricted_until_since_coherent (B : BFMCS D) (root : Formula) : Prop`
2. Modify `restricted_shifted_truth_lemma` to accept `restricted_until_since_coherent root` instead of `until_since_coherent`
3. Prove `dovetailed_restricted_until_since_coherent` for the dovetailed chain

Step 2 is straightforward since the truth lemma already restricts to subformulas. Step 3 has the same difficulty as the unrestricted version.

**Feasibility**: VIABLE as a cleanup (matches restricted_tc pattern) but does not reduce core difficulty.

**Effort**: 1-2 days for definition + wiring; core proof effort unchanged.

---

## Summary of Alternatives

| # | Approach | Feasibility | Core Difficulty Bypass? | Effort |
|---|----------|-------------|------------------------|--------|
| 1a | DeterministicFMCS backward dirs | Marginal | No (needs `until_intro` derivation) | 2-4 days |
| 1b | DeterministicFMCS forward dirs | Blocked | No (same eventuality resolution) | Unknown |
| 2 | FMP path | Blocked | No (still needs truth lemma) | N/A |
| 3 | BXCanonical path | Marginal | No (same linearity obstacle) | 5-10 days |
| 4 | Weakened definition | Viable (cleanup) | No (simplifies, doesn't bypass) | 1-2 days |
| 5 | Direct MCS proof | Blocked | N/A (interval semantics needs chains) | N/A |
| 6 | Restricted `until_since_coherent` | Viable (cleanup) | No (matches restricted_tc pattern) | 1-2 days |

### Key Conclusion

**There is no viable alternative that bypasses the core mathematical difficulty.** All paths converge on the same obstacle: proving that if `(phi U psi)` is in an MCS at time t, then psi eventually holds at some s >= t in the same chain/family, with phi holding on the interval.

The most productive "alternative" work is:

1. **Derive `until_intro`/`since_intro` from BX axioms** -- this unblocks the backward directions in the DeterministicFMCS approach and is independently useful. The derivation should use BX5 (self-accumulation) + BX8 (reflexive intro) + BX9 (elimination).

2. **Define `restricted_until_since_coherent`** -- this is a clean architectural improvement matching the existing `restricted_temporally_coherent` pattern, even though it does not reduce the proof burden.

3. **Focus on the enriched seed approach** (Teammate A's area) -- the alternatives analysis confirms that chain construction with enriched seeds is the correct path. No shortcut exists.
