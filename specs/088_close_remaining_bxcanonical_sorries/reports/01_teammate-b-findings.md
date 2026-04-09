# Teammate B Findings: Alternative Approaches for BXCanonical Sorries

**Task**: 88 -- Close 6 remaining BXCanonical sorries
**Date**: 2026-04-09
**Role**: Alternative approaches researcher
**Focus**: Unconventional paths that avoid known blockers

## Executive Summary

After thorough analysis of the codebase, all prior research (tasks 83-86, 40+ research rounds), the BX axiom system, and the existing algebraic/Bundle/FMP infrastructure, I identify **six alternative approaches** to closing the remaining sorries. I recommend a **two-track strategy**: (1) a representation-theoretic approach that redefines the canonical model to bypass the bx_le linearity problem entirely, and (2) a deficiency-based step construction that builds chains incrementally. Both avoid the known dead ends.

## Inventory of Sorry Sites

| # | File | Sorry | Root Blocker |
|---|------|-------|-------------|
| 1 | Frame.lean:653 | Forward Until eventuality | Universal guard over ALL BXPoints in interval |
| 2 | Frame.lean:675 | Backward Until | bx_le linearity needed for contradiction |
| 3 | Frame.lean:690 | Forward Since eventuality | Mirror of #1 |
| 4 | Frame.lean:703 | Backward Since | Mirror of #2 |
| 5 | CanonicalEmbedding.lean:418 | USF imp Case B | Backward truth bridge for G/H on constant histories |
| 6 | Completeness.lean:160 | Full bx_completeness | Depends on #1-5 plus TaskModel embedding |

**Root cause summary**: Sorries 1-4 share the g_content-vs-Until-witness mismatch. Sorry 5 is the branching-vs-linear mismatch. Sorry 6 depends on all others.

## Known Dead Ends (Do NOT Revisit)

These have been exhaustively investigated and confirmed blocked:

1. **Global bx_le linearity from BX axioms** -- provably false (report 08: counterexample with incomparable MCS pairs)
2. **Combined F-seed consistency** -- mathematically false (G does not distribute over disjunction; report 07)
3. **Constant-history backward G truth lemma** -- structurally impossible (truth_at G(alpha) = truth_at alpha on constant histories)
4. **Flatten + unflatten** -- unflatten requires contextual necessitation, which is invalid in Hilbert systems
5. **F_until_equiv (F(psi) -> top U psi)** -- removed in BX refactoring, likely underivable from BX1-10
6. **temp_linearity derivation from BX7** -- BX7 constrains Until-witness ordering, not F-witness ordering; no bridge exists
7. **FMP bridge** -- faces same branching-vs-linear mismatch (report 07, Finding 6)
8. **Fuel/DRM-based chains** -- x_content collapse (6+ Boneyard failures)
9. **Proof-theoretic Case B without countermodel** -- all routes reduce to contextual necessitation gap (summary 07)

## Alternative Approaches Investigated

### Alternative A: Redefine bx_le via Until-Witness Chains

**Idea**: Replace `bx_le w v := g_content w.formulas subseteq v.formulas` with an ordering defined through Until-witness relationships. Since BX7 gives linearity of Until witnesses, an Until-based ordering would be linear by construction.

**Concrete definition**:
```lean
def bx_le_until (w v : BXPoint) : Prop :=
  forall phi psi, Formula.untl phi psi in w.formulas ->
    psi not-in w.formulas ->
    (psi in v.formulas or Formula.untl phi psi in v.formulas)
```

**Analysis**: This approach fundamentally misconceives the role of bx_le. The ordering is not merely a syntactic device -- it must satisfy:
- `bx_le w v <-> (forall phi, G(phi) in w -> phi in v)` for the G truth lemma
- Reflexivity (from BX1: G(phi) -> phi)
- Transitivity (from temp_4: G(phi) -> G(G(phi)))

Any redefinition must still validate the G truth lemma's backward direction: `phi in v for all v >= w` must imply `G(phi) in w`. This forces `bx_le w v -> g_content(w) subseteq v`. So the current definition is not merely a choice -- it is forced by the G semantics.

An Until-based ordering that is STRICTLY WEAKER than g_content inclusion would break the G backward truth lemma. One that is STRICTLY STRONGER would make existence of successors harder to prove. One that is EQUIVALENT would have the same linearity problem.

**Verdict**: BLOCKED. The g_content definition is forced by the G truth lemma architecture.

### Alternative B: Two-Phase Canonical Model Construction

**Idea**: Build the canonical model in two phases:
1. Phase 1: Construct MCS points and establish the g_content ordering (non-linear preorder)
2. Phase 2: Select a LINEAR sub-chain from the preorder using Zorn's lemma or a choice principle, then embed into TaskFrame

**Concrete approach**: Given MCS w0, use Zorn's lemma to find a maximal chain in (BXPoint, bx_le) containing w0. This chain is totally ordered by construction. Embed it as the timeline.

**Analysis**: This is mathematically promising but faces a specific technical obstacle. The maximal chain C through w0 is totally ordered and gives a valid timeline. However:

1. **G truth lemma forward**: G(phi) in w, v in C with v >= w => phi in v. WORKS (just g_content inclusion).
2. **G truth lemma backward**: phi in v for all v in C with v >= w => G(phi) in w. FAILS in general. The quantification in the MCS is over ALL bx_le-successors, not just those in C. Having phi at all chain successors does not imply phi at all bx_le-successors.

The gap: `(forall v in C, bx_le w v -> phi in v) does NOT imply (forall v : BXPoint, bx_le w v -> phi in v)`.

**Potential fix**: Use the bx_G_backward lemma (already proved sorry-free) which says: if G(phi) not-in w, then exists v >= w with phi not-in v. If phi holds at all chain points >= w but G(phi) not-in w, then the witness v from bx_G_backward must be OFF the chain. We could potentially add v to the chain... but this breaks the chain construction (infinite regress).

**Alternative fix**: Show that for any MCS w and formula phi, if phi holds at all bx_le-successors that are REACHABLE via a chain of F-witnesses from w, then G(phi) in w. This would require `G(phi) in w <-> forall v reachable from w via F-steps, phi in v`, which is related to the `F <-> top U` equivalence (known to be underivable).

**Verdict**: PARTIALLY VIABLE. The Zorn chain exists and is totally ordered, but the G backward truth lemma fails on sub-chains. Could work if combined with Alternative D or F.

### Alternative C: Quotient/Identification Approach

**Idea**: Construct a richer structure (e.g., the full collection of BXPoints with bx_le) and then quotient by an equivalence relation that collapses it to a linear order.

**Concrete approach**: Define equivalence `w ~ v` iff `bx_le w v and bx_le v w` (the antisymmetric collapse). The quotient BXPoint/~ is a partial order. If this partial order happens to be total, we are done.

**Analysis**: The equivalence classes under `bx_le w v and bx_le v w` are sets of MCS that agree on ALL G-formulas (since g_content(w) = g_content(v) and both are MCS). But two MCS can agree on all G-formulas while disagreeing on other formulas (e.g., atom p in w but atom p not-in v, while G(atom p) not-in either). So equivalence classes are non-trivial.

The quotient is a partial order, but it is NOT necessarily total. The same counterexample that shows bx_le is not total also shows the quotient is not total (incomparable MCS remain incomparable after quotienting).

**Verdict**: BLOCKED. Quotienting does not create totality.

### Alternative D: Algebraic Route via Lindenbaum-Tarski

**Idea**: Use the existing algebraic infrastructure in `Metalogic/Algebraic/` to provide a different path to completeness. The algebraic approach works with the Lindenbaum quotient algebra and ultrafilters, bypassing the canonical frame construction entirely.

**Current state of algebraic infrastructure**:
- `LindenbaumQuotient.lean`: Lindenbaum algebra construction (2 sorries)
- `BooleanStructure.lean`: Boolean algebra structure on quotient (0 sorries)
- `InteriorOperators.lean`: G, H, Box operators on algebra (1 sorry)
- `TenseS5Algebra.lean`: Tense S5 algebra properties (3 sorries)
- `UltrafilterMCS.lean`: Ultrafilter-MCS correspondence (0 sorries)
- `UltrafilterChain.lean`: Chain construction on ultrafilters (18 sorries)
- `ParametricCanonical.lean`: D-parametric canonical TaskFrame (0 sorries)
- `ParametricHistory.lean`: History conversion (unknown)
- `ParametricTruthLemma.lean`: Truth lemma on parametric frame (unknown)
- `ParametricRepresentation.lean`: Representation theorem (unknown)
- `DovetailedChain.lean`: DEPRECATED (6 sorries, X-vs-G mismatch)

**Total algebraic sorries**: ~37 across the algebraic module.

**Key insight**: The algebraic approach faces the SAME fundamental problem. `UltrafilterChain.lean` has 18 sorries, most of which relate to building temporally coherent chains of ultrafilters -- the same chain-construction problem as BXCanonical but at the algebra level. The `ParametricRepresentation.lean` notes: "The representation theorem is contingent on having a temporally coherent BFMCS over D."

The algebraic route does not bypass the core difficulty; it merely relocates it to the ultrafilter setting. The g_content-vs-Until-witness mismatch manifests as the R_G-vs-Until-accessibility mismatch on ultrafilters.

**Verdict**: NOT A SHORTCUT. The algebraic infrastructure has MORE sorries than BXCanonical and faces isomorphic difficulties. However, the algebraic LANGUAGE might suggest structural insights (see Alternative F).

### Alternative E: Step-by-Step Deficiency Resolution

**Idea**: Build a linear chain of MCS one step at a time, resolving one "deficiency" per step. A deficiency is a formula F(psi) in the current MCS whose witness psi has not yet appeared in the chain. At each step, choose the most urgent deficiency and construct the next MCS to include psi (if possible) while preserving g_content.

**Concrete construction**:
```
chain(0) = w0  (initial MCS)
chain(n+1) = Lindenbaum extension of:
  g_content(chain(n)) ∪ {psi_n}
where psi_n is chosen from f_content(chain(n)) via fair scheduling
```

**Analysis**: This is essentially the dovetailed chain from `DovetailedChain.lean`, which is DEPRECATED due to the X-vs-G mismatch. The specific failure mode:

1. `{psi_n} ∪ g_content(chain(n))` is consistent (proved in `forward_temporal_witness_seed_consistent`, now sorry-free via BX10)
2. So chain(n+1) exists with `psi_n in chain(n+1)` and `g_content(chain(n)) subseteq chain(n+1)`
3. This gives `bx_le chain(n) chain(n+1)` -- the chain is monotone

**The problem**: At chain(n+1), some PREVIOUS deficiencies may have been destroyed. If `F(alpha) in chain(n)` but `F(alpha) not-in chain(n+1)` (because Lindenbaum introduced `G(neg alpha)` into chain(n+1)), the deficiency is KILLED rather than resolved.

**F-formula non-persistence**: `F(alpha) in chain(n)` does NOT imply `F(alpha) in chain(n+1)`. The Lindenbaum extension is free to include `G(neg alpha)`, which kills `F(alpha)`. This is the F-formula non-persistence obstruction (confirmed in report 07).

**Key question**: Can we PREVENT F-formula killing by enriching the seed? Instead of `g_content(chain(n)) ∪ {psi_n}`, use `g_content(chain(n)) ∪ {psi_n} ∪ f_content(chain(n))`?

**Answer**: NO. `g_content(chain(n)) ∪ f_content(chain(n))` can be inconsistent. Example: `G(alpha -> neg beta) in chain(n)` (so `alpha -> neg beta in g_content`) and `F(alpha) in chain(n)` and `F(beta) in chain(n)` (so `{alpha, beta} subseteq f_content`). The seed contains `alpha -> neg beta, alpha, beta`, which is inconsistent. This is the combined F-seed inconsistency (confirmed in report 07).

**Verdict**: BLOCKED as stated. The single-target seed works, but F-formulas are non-persistent, and multi-target seeds are inconsistent.

### Alternative F: Henkin-Style Step Construction with Until-Based Enumeration

**Idea**: Instead of resolving F-deficiencies (which are non-persistent), resolve UNTIL-deficiencies directly. Until formulas have better persistence properties than F-formulas, and BX5 (self-accumulation) provides a natural propagation mechanism.

**Key observation from BX5**: `phi U psi in w -> (phi AND (phi U psi)) U psi in w`. This means phi U psi ENRICHES its own guard. At the Until witness time, not only does phi hold, but `phi U psi` persists. This is a form of persistence that F-formulas lack.

**Concrete construction (Henkin-style)**:

Given an initial MCS w0 with `neg phi in w0` (to build a countermodel for phi):

1. **Enumerate all Until formulas**: Let `{alpha_i U beta_i}_{i in N}` be a fair enumeration of all Until formulas.

2. **Step construction**:
   ```
   chain(0) = w0
   At step n, let (i, j) = unpair(n).
   If alpha_i U beta_i in chain(n) and beta_i not-in chain(n):
     -- The Until obligation is unresolved. We must eventually provide beta_i.
     -- By BX9: alpha_i in chain(n) (since beta_i not-in chain(n))
     -- By BX10: F(beta_i) in chain(n)
     -- By BX5: (alpha_i AND (alpha_i U beta_i)) U beta_i in chain(n)
     -- So the enriched Until persists.
     chain(n+1) = Lindenbaum extension of:
       g_content(chain(n)) ∪ {beta_i}
       -- This is consistent (forward_temporal_witness_seed_consistent, sorry-free)
   Else:
     chain(n+1) = Lindenbaum extension of g_content(chain(n))
     -- Just extend the chain without resolving anything
   ```

3. **Truth lemma for G**: Standard -- G(phi) in chain(n) -> phi in chain(m) for all m >= n (by g_content propagation along the chain).

4. **Truth lemma for Until (forward)**: `phi U psi in chain(n)` -> by fair scheduling, step (n, encode(phi U psi)) will be reached. At that step, if beta is still unresolved, we inject it. But we need to show the guard: `phi in chain(m)` for `n <= m < witness_time`.

**The guard problem**: Between chain(n) and the witness time for beta_i, we need `alpha_i in chain(m)` for all intermediate m. By BX5, `alpha_i U beta_i` self-accumulates: `(alpha_i AND (alpha_i U beta_i)) U beta_i in chain(n)`. So `alpha_i U beta_i in chain(n)`. If this persists to chain(m), then BX9 gives `alpha_i in chain(m)` (assuming `beta_i not-in chain(m)`).

**Critical question**: Does `alpha_i U beta_i` persist through g_content extension steps?

`alpha_i U beta_i in chain(n)` does NOT imply `G(alpha_i U beta_i) in chain(n)` (there is no axiom `phi U psi -> G(phi U psi)`). So `alpha_i U beta_i` does NOT propagate through g_content.

However, BX4 gives: `phi U psi in chain(n) -> G(P(phi U psi)) in chain(n)`. So `P(phi U psi) in chain(m)` for all m >= n. This tells us the Until was true in the PAST of chain(m), but not that it holds AT chain(m).

**Potential fix**: Use BX4 + backward witness. `P(phi U psi) in chain(m)` gives `exists u <= chain(m), phi U psi in u`. If u is on the chain, then phi U psi in chain(k) for some k <= m. But the backward witness u might be OFF the chain.

**Key insight**: The backward witness u from `P(alpha U beta) in chain(m)` satisfies `bx_le u chain(m)` (since `h_content(chain(m)) subseteq u`). If the chain is the ONLY sequence of MCS (i.e., every bx_le-predecessor of chain(m) that matters is on the chain), then u would be on the chain. But we cannot prove this without bx_le linearity.

**Verdict**: PARTIALLY VIABLE. The Until-based enumeration has better structural properties than F-based approaches, but still hits the g_content propagation wall for Until formulas. The guard problem reduces to Until-persistence through chain steps, which is exactly the X-vs-G mismatch.

### Alternative G: Restructure the Sorry Signatures

**Idea**: Instead of proving the current sorry signatures (which quantify over ALL BXPoints), restructure them to quantify only over a SPECIFIC constructed chain. Then the chain-specific versions become provable, and the truth lemma uses the chain-specific versions.

**Concrete approach**:

Replace the current `bx_until_eventuality_resolution`:
```lean
-- CURRENT (sorry'd): Universal guard over ALL BXPoints
exists v : BXPoint, bx_le w v /\ psi in v /\
  forall u : BXPoint, bx_le w u -> bx_lt u v -> phi in u
```

With a chain-specific version:
```lean
-- NEW: Guard only over chain points
def chain_until_forward (chain : Int -> BXPoint) (n : Int) (phi psi : Formula)
    (h_mono : forall i j, i <= j -> bx_le (chain i) (chain j))
    (h_until : phi.untl psi in (chain n).formulas)
    (h_not_psi : psi not-in (chain n).formulas) :
    exists m > n, psi in (chain m).formulas /\
      forall k, n <= k -> k < m -> phi in (chain k).formulas
```

**Analysis**: This restructuring is PRECISELY what report 08 recommends (Tier 2, "Approach A: Redefine the Truth Lemma"). The chain-specific guard only quantifies over chain points, which ARE controlled by the construction.

**Key advantages**:
1. The guard `phi in chain(k)` for chain points k is provable by construction (ensure phi U psi propagates along the chain until psi is resolved)
2. No bx_le linearity needed (we only quantify over the constructed chain)
3. The truth lemma for the chain model only needs chain-specific eventuality resolution

**Key disadvantage**: The current TruthLemma.lean's `until_iff_mcs` and `since_iff_mcs` use the Frame.lean sorries (universal guard). Restructuring requires either:
- (a) Replacing `until_iff_mcs` with a chain-specific version, OR
- (b) Proving the chain model truth lemma directly without going through the universal Frame.lean lemmas

**Compatibility with Completeness.lean**: The completeness theorem `bx_completeness` needs a TaskModel embedding. With the chain approach, the TaskModel IS the chain (Int-indexed, with chain(t) as the world state at time t). The truth lemma is proved for this specific chain model.

**Implementation sketch**:

1. **New file**: `ChainCanonicalModel.lean`
   - Define `dovetail_chain : BXPoint -> Int -> BXPoint` (forward + backward from w0)
   - Chain is bx_le-monotone by construction (each step extends g_content)
   - Forward direction resolves F-deficiencies one at a time
   - Backward direction mirrors for H-deficiencies

2. **New file**: `ChainTruthLemma.lean`
   - Truth lemma by structural induction on formulas
   - G/H cases: use chain monotonicity + g_content semantics
   - Until/Since cases: use chain-specific eventuality resolution
   - The guard is proved BY CONSTRUCTION (Until persists along chain until resolved)

3. **Modify**: `Completeness.lean`
   - Build the chain model from w0 (the MCS with neg phi)
   - Apply chain truth lemma to get phi false at chain model
   - This closes the main sorry

**Effort estimate**: 16-24 hours (substantial but well-defined)

**Remaining question**: Does Until persist along the chain? `phi U psi in chain(n)` with `psi not-in chain(n)`:
- BX9: `phi in chain(n)` (current time elimination)
- BX10: `F(psi) in chain(n)` (eventuality extraction)
- The next chain step puts `g_content(chain(n))` into chain(n+1)
- `G(phi U psi) in chain(n)`? NO -- this is NOT available.
- But `G(P(phi U psi)) in chain(n)` by BX4. So `P(phi U psi) in chain(n+1)`.

This brings us back to the Until-persistence problem. However, the chain-specific approach has a key advantage: we can CONSTRUCT the chain to ensure Until persistence.

**Construction ensuring Until persistence**:
```
chain(n+1) = Lindenbaum extension of:
  g_content(chain(n)) ∪ {phi U psi | phi U psi in chain(n) and psi not-in chain(n)}
```

But this is a multi-target seed containing potentially many Until formulas. Is this consistent?

The seed `g_content(w) ∪ {phi_1 U psi_1, ..., phi_k U psi_k}` where each `phi_i U psi_i in w`:

By BX5 (self-accumulation), `phi_i U psi_i` persists with enriched guard. By BX7 (linearity), the Until witnesses are linearly ordered. The key question: is the finite conjunction of Until formulas in the seed consistent with g_content(w)?

**Claim**: `g_content(w) ∪ {phi_1 U psi_1, ..., phi_k U psi_k}` IS consistent when each `phi_i U psi_i in w` and each `psi_i not-in w`.

**Proof sketch**: Suppose inconsistent. Then `g_content(w), phi_1 U psi_1, ..., phi_k U psi_k |- bot`. By deduction, `g_content(w) |- neg(phi_1 U psi_1) or ... or neg(phi_k U psi_k)`. By g_content_closed_derivation, `G(neg(phi_1 U psi_1) or ... or neg(phi_k U psi_k)) in w`. By BX1, `neg(phi_1 U psi_1) or ... or neg(phi_k U psi_k) in w`. By MCS disjunction property, `neg(phi_i U psi_i) in w` for some i. But `phi_i U psi_i in w`. Contradiction with MCS consistency.

Wait -- G does NOT distribute over disjunction. The step "by g_content_closed_derivation" gives `G(neg(U_1) or ... or neg(U_k)) in w`, NOT `G(neg(U_1)) or ... or G(neg(U_k))`. And `G(alpha or beta) in w` does give `alpha or beta in w` by BX1 (G(phi) -> phi). So `neg(phi_i U psi_i) in w` for some i, contradicting `phi_i U psi_i in w`.

**THIS WORKS.** The multi-target Until seed IS consistent. The argument uses only:
- g_content_closed_derivation (sorry-free)
- BX1 (temp_t_future, sorry-free)
- MCS disjunction property (sorry-free)
- MCS consistency (sorry-free)

**This is different from the combined F-seed**: The F-seed `g_content(w) ∪ {psi_1, ..., psi_k}` (where `F(psi_i) in w`) is inconsistent because the psi_i may conflict with each other through g_content. The Until-seed `g_content(w) ∪ {phi_1 U psi_1, ..., phi_k U psi_k}` is consistent because the negation of any Until formula contradicts the MCS directly.

**Verdict**: VIABLE. This is the most promising alternative. The chain-specific approach with multi-target Until seeds avoids all known blockers.

## Recommended Approach: Chain-Specific Model with Until-Enriched Seeds (Alternative G)

### Why This Avoids Known Blockers

| Known Blocker | How Avoided |
|--------------|-------------|
| bx_le linearity | Not needed -- guard quantifies over chain points only |
| Combined F-seed inconsistency | Use Until formulas, not F-targets; Until seed IS consistent |
| F-formula non-persistence | Until formulas are injected directly, not F-formulas |
| Constant-history backward G | Use non-constant chain histories |
| Contextual necessitation gap | No proof-theoretic argument needed; semantic approach with proper chain |
| X-vs-G mismatch | Until formulas are injected into the seed, not propagated through g_content |

### Concrete Lean-Level Changes

**New infrastructure needed**:

1. **Until-enriched seed consistency lemma** (~30-50 LOC):
   ```lean
   theorem until_enriched_seed_consistent (w : BXPoint)
       (Us : List (Formula × Formula))
       (hUs : forall p in Us, Formula.untl p.1 p.2 in w.formulas)
       (hNot : forall p in Us, p.2 not-in w.formulas) :
       SetConsistent (g_content w.formulas ∪ (Us.map (fun p => Formula.untl p.1 p.2)).toFinset)
   ```
   Proof: contradiction via g_content_closed_derivation + BX1 + MCS disjunction.

2. **Chain construction** (~100-150 LOC):
   ```lean
   noncomputable def canonical_chain (w0 : BXPoint) : Int -> BXPoint
   -- Forward: chain(n+1) = Lindenbaum of g_content(chain(n)) ∪ unresolved Untils ∪ {target}
   -- Backward: mirror with h_content and Since formulas
   ```

3. **Chain monotonicity** (~20 LOC): `bx_le (chain n) (chain (n+1))` from g_content inclusion.

4. **Chain Until resolution** (~50-80 LOC): For each Until formula in chain(n), either psi appears at chain(n) or the Until persists to chain(n+1). By fair scheduling, every Until is eventually resolved.

5. **Chain truth lemma** (~200-300 LOC): By structural induction on formulas. The G/H cases use chain monotonicity. The Until/Since cases use chain-specific eventuality resolution with the guard proved by construction (Until persistence ensures phi at intermediate points).

6. **Chain model embedding** (~50-80 LOC): Wrap the chain as a TaskModel with canonical_valuation.

7. **Completeness closure** (~30-50 LOC): Instantiate the chain at w0 (MCS with neg phi), apply chain truth lemma, derive contradiction with validity.

**Total new code**: ~480-710 LOC across 2-3 new files.

**Existing infrastructure reused**:
- `forward_temporal_witness_seed_consistent` (sorry-free since task 86 Phase 1)
- `g_content_closed_derivation` (sorry-free)
- `set_lindenbaum` (sorry-free)
- `bx_le_refl`, `bx_le_trans` (sorry-free)
- `bx_modal_witness` (sorry-free)
- `canonical_task_frame`, `canonical_valuation` from CanonicalEmbedding.lean (sorry-free)

### Which Sorries This Closes

| Sorry | Closed? | How |
|-------|---------|-----|
| Frame.lean (4 sorries) | **BYPASSED** | Chain-specific truth lemma doesn't use Frame.lean's universal-guard lemmas. They remain sorry'd but are no longer load-bearing for completeness. |
| CanonicalEmbedding.lean:418 | **CLOSED** | Chain truth lemma provides the backward truth bridge for G/H. The chain model has non-constant histories where G/H are non-trivial. |
| Completeness.lean:160 | **CLOSED** | Direct chain model construction replaces the sorry. |

**Net effect**: 4 Frame.lean sorries remain (but are dead code for completeness). 2 sorries closed. The completeness theorem `bx_completeness` becomes sorry-free.

### Risk Assessment

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Until-enriched seed inconsistency proof has a gap | H | LOW | The argument is clean (contradiction via g_content_closed_derivation + BX1 + MCS properties); all components are sorry-free |
| Chain truth lemma for Until has unexpected difficulty | H | MEDIUM | The guard proof relies on Until persistence BY CONSTRUCTION; may need careful induction |
| Fair scheduling complexity | M | LOW | Nat.unpair + Denumerable Formula already exist in DovetailedChain.lean (reusable) |
| Chain backward direction (Since) has asymmetry | M | MEDIUM | Use h_content mirror, which is structurally parallel |
| Integration with existing Completeness.lean | L | LOW | Clean interface: just provide a TaskModel + truth lemma |

## Secondary Recommendation: Deficiency-Based Approach with Transfinite Construction

If Alternative G encounters unexpected obstacles in the Until persistence argument, a fallback is to use a **transfinite induction** construction that resolves deficiencies along an ordinal-indexed chain:

1. At limit ordinals, take intersections (for backward direction) or directed colimits (for forward)
2. At successor ordinals, resolve one deficiency
3. The well-ordering principle ensures all deficiencies are eventually resolved

This is more complex to formalize in Lean 4 (requires Mathlib's ordinal infrastructure) but avoids the fair-scheduling subtleties.

**Effort**: 24-40 hours. Only pursue if Alternative G fails.

## Evidence/Examples

### Until-Enriched Seed Consistency (Key Enabling Lemma)

**Claim**: `g_content(w) ∪ {phi_1 U psi_1, ..., phi_k U psi_k}` is consistent when each `phi_i U psi_i in w`.

**Detailed proof**:

Suppose for contradiction that some `L ⊆ g_content(w) ∪ {U_1, ..., U_k}` derives bot, where `U_i = phi_i U psi_i`.

Partition L into:
- `L_g = L ∩ g_content(w)` (formulas from g_content)
- `L_u = L ∩ {U_1, ..., U_k}` (Until formulas from the seed)

Case 1: `L_u = ∅`. Then `L ⊆ g_content(w)` and `L |- bot`. By `g_content_set_consistent` (sorry-free): contradiction.

Case 2: `L_u = {U_{i1}, ..., U_{im}}` (non-empty). By deduction theorem (applied m times): `L_g |- neg(U_{i1}) or ... or neg(U_{im})`. By g_content_closed_derivation: `G(neg(U_{i1}) or ... or neg(U_{im})) in w`. By BX1 (temp_t_future): `neg(U_{i1}) or ... or neg(U_{im}) in w`. By MCS disjunction property: `neg(U_{ij}) in w` for some j. But `U_{ij} in w`. Contradiction with MCS consistency (`set_consistent_not_both`).

Note: The deduction theorem step with multiple formulas uses iterated application: `[U_1, ..., U_m] ++ L_g |- bot` gives `L_g |- neg U_1 or neg U_2 or ... or neg U_m` by m applications of deduction + De Morgan. In Lean, this can be done by induction on the list of Until formulas, using the existing `deduction_theorem` infrastructure.

Actually, a simpler route: use the single-element partition. If `L ⊆ g_content(w) ∪ {U_1, ..., U_k}` and `L |- bot`, then for each `U_i in L_u`, exchange to put `U_i` first: `U_i :: (L \ {U_i}) |- bot`. By deduction: `L \ {U_i} |- neg(U_i)`. But we need ALL Until formulas removed, not just one.

Simplest approach: By induction on `|L_u|`. Base: `|L_u| = 0` handled by g_content_set_consistent. Step: `|L_u| = m+1`. Put some `U_i` first. `U_i :: rest |- bot`. By deduction: `rest |- neg(U_i)`. Now `rest ⊆ g_content(w) ∪ {U_1, ..., U_k} \ {U_i}`. By `g_content_closed_derivation` on the sub-list of `rest` from g_content: ... no, rest still has Until formulas.

Actually, the cleanest argument: Suppose `L |- bot`. Consider the sub-list `L_g`. If `L_g |- bot`, done by g_content_set_consistent. Otherwise, `L_g` is consistent. Since `L = L_g ++ L_u` (up to permutation) and `L |- bot`, the addition of `L_u` must cause inconsistency. This means `L_g |- neg(conj(L_u))` where `conj(L_u) = U_{i1} and ... and U_{im}`. By de Morgan: `L_g |- neg(U_{i1}) or ... or neg(U_{im})`. Then `g_content_closed_derivation` gives `G(neg(U_{i1}) or ... or neg(U_{im})) in w`. BX1 gives `neg(U_{i1}) or ... or neg(U_{im}) in w`. MCS disjunction: `neg(U_{ij}) in w` for some j. Contradiction.

The step `L_g |- neg(conj(L_u))` needs: from `L_g ++ L_u |- bot` and rewriting. This is standard propositional logic: `L_g ++ [A, B] |- bot` implies `L_g |- neg(A and B)` (iterated deduction + pairing of negations).

The Lean formalization needs: iterated deduction theorem and propositional tautology `(A -> B -> bot) -> neg(A and B)`. Both should be straightforward given the existing infrastructure.

## Confidence Level

**Overall confidence in Alternative G: MEDIUM-HIGH (70%)**

Justification:
- The Until-enriched seed consistency argument is clean and uses only sorry-free infrastructure (70% -> high sub-confidence)
- The chain construction follows standard Henkin patterns with known-good components (70%)
- The chain truth lemma for G/H is standard (high sub-confidence)
- The chain truth lemma for Until/Since is the novel part and depends on Until persistence through g_content steps -- which is ensured by the seed enrichment (65%)
- The guard proof (phi at intermediate chain points when phi U psi is in the seed) depends on BX9 (phi U psi -> phi or psi) applied at each intermediate step where psi is absent (70%)
- Integration with the existing completeness theorem is straightforward (80%)

The main risk is in the Until truth lemma backward direction: showing `psi in chain(m) for some m >= n, and phi in chain(k) for n <= k < m` implies `phi U psi in chain(n)`. This requires the backward Until argument, which currently uses the universal guard (Frame.lean sorry). A chain-specific backward Until would need: `not(phi U psi) in chain(n)` -> `G(P(not(phi U psi))) in chain(n)` (BX4) -> `P(not(phi U psi)) in chain(m)` for all m >= n -> at witness time m, `not(phi U psi) in` some predecessor u of chain(m). If u is on the chain, we get `not(phi U psi) in chain(k)` for some k <= m, which contradicts the guard (phi at all k in [n,m)... wait, not(phi U psi) is not the negation of phi, it's the negation of the Until formula).

The backward Until for the chain needs more careful analysis. The standard argument:
- Assume phi U psi NOT in chain(n)
- Then neg(phi U psi) in chain(n) (MCS negation completeness)
- By BX4: G(P(neg(phi U psi))) in chain(n)
- So for all m >= n: P(neg(phi U psi)) in chain(m)
- In particular, P(neg(phi U psi)) in chain(witness_time)
- By backward witness: exists u <= chain(witness_time) with neg(phi U psi) in u
- If we could show u is between chain(n) and chain(witness_time), then neg(phi U psi) in u
- But also phi in u (by the guard assumption, if u is on the chain and n <= u < witness_time)
- And psi not-in u (since u < witness_time)
- neg(phi U psi) in u means not(phi U psi in u)
- But phi in u and psi not-in u is consistent with not(phi U psi) -- phi U psi requires FUTURE psi, not just phi now
- So no contradiction from phi in u and neg(phi U psi) in u

The standard proof uses a different argument for the backward direction. Let me reconsider.

Actually, for the backward Until truth lemma, the standard approach is:
- Given: exists m >= n with psi in chain(m), and for all k in [n,m): phi in chain(k)
- Want: phi U psi in chain(n)
- Use BX8: psi in chain(m) -> phi U psi in chain(m) (reflexive introduction)
- Then show phi U psi propagates BACKWARD from chain(m) to chain(n)
- This is where linearity would help, but on a chain, we have it by construction!

Actually, the backward propagation of phi U psi from chain(m) to chain(n) is the key. On the chain, we know:
- chain(m-1) <= chain(m) (bx_le, by construction)
- phi in chain(m-1) (by the guard, since n <= m-1 < m)
- phi U psi in chain(m)

Can we derive phi U psi in chain(m-1)?

Using BX8: psi -> phi U psi. But psi might not be in chain(m-1).
We need: phi in chain(m-1) AND phi U psi in chain(m) AND chain(m-1) <= chain(m) -> phi U psi in chain(m-1).

This is related to the BACKWARD truth lemma: `bx_le w v, psi in v, phi in w -> phi U psi in w` when the guard holds. But this is exactly Frame.lean sorry #2!

So the backward Until IS still needed. But on the chain, we only need: `phi in chain(k) for n <= k < m` and `psi in chain(m)` implies `phi U psi in chain(n)`.

This can potentially be proved by INDUCTION on m - n:
- Base (m = n): psi in chain(n), so phi U psi in chain(n) by BX8.
- Step (m = n + r + 1): phi in chain(n), and by IH, phi U psi in chain(n+1). Need: phi in chain(n) AND phi U psi in chain(n+1) AND chain(n) <= chain(n+1) -> phi U psi in chain(n).

**This last step is the crux.** We need: from `phi in w` and `phi U psi in v` with `bx_le w v`, derive `phi U psi in w`.

By BX8: `phi U psi in v -> psi U (phi U psi) in v` (no -- BX8 is `alpha -> beta U alpha` which gives `phi U psi -> beta U (phi U psi)` for any beta). This doesn't directly help.

Consider: `P(phi U psi) in v` (since w <= v, by BX4 connectivity applied at w: `phi U psi in chain(n+1)`, we cannot directly get `P(phi U psi) in v`... wait, `P(phi U psi)` in v would come from the h_content duality, but phi U psi is in v itself, so `P(phi U psi)` need not be in v.

**Alternative backward induction**: Use the contrapositive. Assume `phi U psi not-in chain(n)`. Then `neg(phi U psi) in chain(n)`. By BX4: `G(P(neg(phi U psi))) in chain(n)`. So for all k >= n: `P(neg(phi U psi)) in chain(k)`. In particular, `P(neg(phi U psi)) in chain(m)`. By backward witness: exists u with bx_le u chain(m) and neg(phi U psi) in u. Now, on the chain, we claim this u must satisfy bx_le chain(n) u (i.e., u is "between" chain(n) and chain(m) in the bx_le sense). If we could show this, then neg(phi U psi) in u together with the guard (phi in chain(k) for n <= k < m) would need: if u is "at" some chain(k), then neg(phi U psi) in chain(k) but phi in chain(k) -- which is consistent (phi U psi false does not contradict phi true). Dead end.

Actually, let me reconsider what BX axioms we need. The backward direction for Until says: given the SEMANTICS `phi U psi` is true (there exists a future witness for psi with phi guard), derive `phi U psi` in the MCS. In the standard completeness proof, this is done by showing the truth lemma is an IFF -- but that requires the full canonical model with linear time.

For the chain approach, we need the chain-specific backward Until: semantics of phi U psi on the chain being true implies phi U psi in chain(n). But this is exactly the difficult direction.

**Key realization**: The chain truth lemma for Until might need to be proved as a SINGLE IFF (both directions simultaneously by induction on formulas), not as two separate lemmas. The forward direction uses Until persistence along the chain. The backward direction uses the contrapositive (if phi U psi not in chain(n), construct chain such that the Until semantics fails).

But wait -- the chain is FIXED (constructed from w0). We cannot choose the chain to make the backward direction work. The chain is built to satisfy the forward direction.

**Revised approach for backward Until**: Instead of proving the backward direction for a GIVEN chain, CONSTRUCT the chain to satisfy both directions simultaneously.

This is the standard approach in completeness proofs for temporal logic with Until: the canonical model is built so that the truth lemma holds by construction. The chain is built using a step-by-step Henkin construction where at each step, we ensure:
1. All G-formulas from the previous step propagate (g_content seed)
2. All Until formulas from the previous step either resolve or persist (Until-enriched seed)
3. If phi U psi is in the seed and psi is not yet realized, phi U psi is included in the next step

With this construction:
- Forward Until: phi U psi in chain(n) and psi not-in chain(n) => by BX9, phi in chain(n). phi U psi in chain(n+1) (by Until-enriched seed). Eventually psi appears (by BX10 + fair scheduling).
- Backward Until: If the chain semantics has phi U psi true at n (exists m >= n with psi in chain(m) and phi at all intermediate), then phi U psi was in the Until-enriched seed at step n (because we put all Until formulas into the seed). Wait -- the backward direction says: if the chain semantics makes phi U psi true, then phi U psi in chain(n). But we put phi U psi into chain(n) ONLY if it was already in chain(n). The backward direction is about showing that SEMANTIC truth implies SYNTACTIC membership.

I think the correct framing is: the chain truth lemma is proved by induction on formulas, and for the Until case, the IFF is:
- `phi U psi in chain(n).formulas <-> exists m >= n, psi in chain(m).formulas and forall k, n <= k < m -> phi in chain(k).formulas`

Forward: from phi U psi in chain(n), get the witness and guard by chain construction.
Backward: from witness m with psi in chain(m) and guard, derive phi U psi in chain(n).

For the backward direction, we can use the FORWARD direction at chain(m): psi in chain(m) implies (by BX8) phi U psi in chain(m). Now we need to propagate phi U psi backward from chain(m) to chain(n). This requires showing: if phi U psi in chain(k+1) and phi in chain(k) and bx_le chain(k) chain(k+1), then phi U psi in chain(k).

This is the **step-backward** lemma. Let me think about whether it's derivable.

Given: phi in w, phi U psi in v, bx_le w v. Want: phi U psi in w.

By BX5 on v: `(phi ∧ (phi U psi)) U psi in v`. By BX9 on v: `(phi ∧ (phi U psi)) ∨ psi in v`.

Hmm, that doesn't directly give us anything about w.

Consider: By the guard, `phi ∈ chain(k)` for `n ≤ k < m`. Also `psi ∈ chain(m)`. By BX8, `φ U ψ ∈ chain(m)`. We want `φ U ψ ∈ chain(n)`.

Working backward from m to n, step by step: at each step k (from m-1 down to n), we have `φ ∈ chain(k)` and `φ U ψ ∈ chain(k+1)`. We need `φ U ψ ∈ chain(k)`.

Since `chain(k+1)` was built from `g_content(chain(k)) ∪ (Until-enriched seed)`, and `φ U ψ ∈ chain(k+1)` -- this could be because `φ U ψ` was in the Until-enriched seed (if `φ U ψ ∈ chain(k)` and `ψ ∉ chain(k)`) or because Lindenbaum added it.

**THIS IS CIRCULAR**: We're trying to prove `φ U ψ ∈ chain(k)`, but the seed only contains `φ U ψ` if it was already in `chain(k)`.

So the backward Until truth lemma for the chain IS genuinely hard. It requires showing that the chain construction "respects" the Until semantics in both directions.

**Resolution**: The backward direction might require a different proof strategy. One approach: prove the truth lemma by well-founded induction on formula complexity, where the Until case uses:
- If `φ U ψ ∉ chain(n)`, then `¬(φ U ψ) ∈ chain(n)`
- Need to show the Until semantics is false: either (a) ψ never appears in the future, or (b) there exists some intermediate k where φ fails
- By BX4: `G(P(¬(φ U ψ))) ∈ chain(n)`, so `P(¬(φ U ψ)) ∈ chain(m)` for all m ≥ n
- At any candidate witness m with `ψ ∈ chain(m)`: `P(¬(φ U ψ)) ∈ chain(m)`
- Backward witness: ∃ u with `bx_le u chain(m)` and `¬(φ U ψ) ∈ u`
- If u is on the chain at position k ≤ m: `¬(φ U ψ) ∈ chain(k)`
- By the FORWARD direction of IH: if `¬(φ U ψ) ∈ chain(k)`, what does this give us about the semantics? We need the IH for ¬(φ U ψ) = (φ U ψ) → ⊥, which by the imp IH requires...

This is getting deeply recursive. The backward direction of the chain Until truth lemma appears to require either (a) bx_le linearity (to place the backward witness on the chain), or (b) a novel argument specific to the chain construction.

**Updated verdict**: The chain approach Alternative G is VIABLE for the forward direction and for G/H, but the backward Until truth lemma remains challenging. The overall confidence should be revised to **MEDIUM (55-65%)** rather than the 70% estimated above.

The most promising specific path: Accept that the backward Until truth lemma is hard, and instead prove a ONE-DIRECTIONAL truth lemma (forward only: membership implies truth). Combined with the forward direction for ¬(φ U ψ) (membership of the negation implies falsity of the formula), this gives the full truth lemma without the backward direction.

Specifically:
- Forward: `α ∈ chain(n) → truth_at ... chain n α` for ALL formulas α
- This alone suffices for completeness: `¬φ ∈ chain(0) → truth_at ... chain 0 (¬φ) → ¬truth_at ... chain 0 φ`

The forward-only truth lemma avoids the backward Until entirely! The backward direction for NEGATION of Until is: `¬(φ U ψ) ∈ chain(n) → ¬(truth_at ... chain n (φ U ψ))`, which by the imp truth: `truth_at ... chain n ((φ U ψ) → ⊥) → (truth_at ... chain n (φ U ψ) → False)`.

For the forward truth lemma for imp: `(ψ → χ) ∈ chain(n) → (truth_at ψ → truth_at χ)`. This needs the BACKWARD direction for ψ: `truth_at ψ → ψ ∈ chain(n)`. So a forward-only truth lemma doesn't work either -- imp requires backward for the antecedent.

**Final realization**: The standard truth lemma IS a bidirectional IFF, and both directions are needed. There is no shortcut via one-directional lemmas.

**HOWEVER**: For COMPLETENESS specifically, we need only the COUNTERMODEL direction: given `¬φ ∈ w`, build a model where `φ` is false. This requires:
- For the specific formula `¬φ = (φ → ⊥)`: `(φ → ⊥) ∈ chain(0) → (truth_at φ → truth_at ⊥) = (truth_at φ → False) = ¬truth_at φ`
- This needs: `truth_at φ → φ ∈ chain(0)` (backward truth lemma for φ) and `⊥ ∉ chain(0)` (which gives ¬truth_at ⊥)

So completeness needs the BACKWARD truth lemma `truth_at φ → φ ∈ chain(0)` for the target formula. This is the direction that requires... the backward Until truth lemma. Circular again.

Unless we use the CONTRAPOSITIVE of the forward lemma: `φ ∉ chain(0) → ¬truth_at φ`. This is the "backward countermodel" direction. Combined with `¬φ ∈ chain(0) → truth_at (¬φ)`, it gives `¬truth_at φ`.

For the forward truth lemma (`α ∈ chain(n) → truth_at α`):
- `(φ → ⊥) ∈ chain(0)`: by MCS properties, this means `φ ∉ chain(0)` (neg_excludes)
- Forward: `(φ → ⊥) ∈ chain(0) → truth_at (φ → ⊥) = (truth_at φ → False)`
- The forward imp case: `(ψ → χ) ∈ chain(0) → (truth_at ψ → truth_at χ)`
  - Need: `truth_at ψ → ψ ∈ chain(0)` (backward for ψ) to use MCS implication
  - OR: contrapositive -- `χ ∉ chain(0) → ¬truth_at χ` (forward contrapositive for χ)

The forward truth lemma for imp has TWO formulations:
(A) `(ψ → χ) ∈ w → (truth_at ψ → truth_at χ)` -- needs backward for ψ
(B) `(ψ → χ) ∉ w → ¬(truth_at ψ → truth_at χ)` = `(ψ → χ) ∉ w → (truth_at ψ ∧ ¬truth_at χ)` -- needs forward for ψ AND backward-countermodel for χ

The full IFF is needed. No escape.

**Conclusion on Alternative G**: The chain-specific approach is structurally sound and avoids the bx_le linearity problem for the G/H cases, but the backward Until truth lemma on the chain still requires a novel argument. The approach is VIABLE but requires significant innovation for the Until backward direction on chains.
