# Teammate C Findings: Quasimodel Method and Synthesis

**Task**: 84 -- Establish Until/Since Coherence for Bundle Completeness
**Focus**: Quasimodel method analysis and approach synthesis
**Date**: 2026-04-08

## Key Findings

1. **Quasimodels do not directly apply to this system** due to strict temporal semantics (G(phi) -> phi invalid). The standard GHR 1994 construction relies on reflexive semantics where g_content(M) includes all formulas in M that are under G. Under strict semantics, Until formulas are X-liftable but not G-liftable, breaking Until persistence through detour steps. (HIGH confidence)

2. **The backward Until direction has a working proof pattern in the Boneyard** (`DeterministicFMCS.lean:340-395`), using `until_intro` + induction on chain distance. The proof is complete except for two `sorry` sites where `until_intro` was removed from the BX axiom system. (HIGH confidence)

3. **`until_intro` IS derivable under reflexive Until semantics** via `or_until_in_mcs` (`SuccRelation.lean:578-594`). The key insight: under BX8 (reflexive Until), `X(psi or (phi and (phi U psi))) -> (phi U psi)` reduces to `(psi or (phi and (phi U psi))) -> (phi U psi)`, which is provable from BX8 + conjunction elimination. (HIGH confidence)

4. **The X-vs-G mismatch is irrelevant for backward Until** because backward Until does not need g_content propagation at all. It works by backward induction on the discrete chain, using `until_intro` at each step. (HIGH confidence)

5. **Forward Until remains the harder direction** but the enriched seed approach (Approach D from report 01) is viable. Under BX1 (reflexive G), `g_content(u) subset u` holds, making the enriched seed `g_content(w_n) union {active Untils in w_n}` trivially consistent as a subset of `w_n`. (MEDIUM-HIGH confidence)

## Quasimodel Method Analysis

### What Quasimodels Are

A quasimodel (GHR 1994) is a structure `(W, R, L)` with states, successor relation, and labeling satisfying local consistency, next-step coherence, and eventuality resolution. The key idea: instead of building a single linear model, build a graph with built-in witnesses for all eventualities, then extract a linear path.

### Why They Fail Here

The quasimodel approach was studied in detail in task 83 report 24. Three failure modes:

1. **Detour Until breakage**: When the path detours from `x_content(M_n)` to a witness MCS `W` to resolve an F-obligation, Until formulas in `M_n` are not preserved in `W`. The witness `W` satisfies `g_content(M_n) subset W`, but `(phi U psi) in M_n` does NOT imply `G(phi U psi) in M_n` (strict semantics), so `(phi U psi)` is not in `g_content(M_n)`, so it may not be in `W`.

2. **Enriched seed G-lift failure**: Attempting to enrich the Lindenbaum seed with Until deferrals fails because the deferrals are X-liftable but not G-liftable. The consistency argument for `{target} union g_content(M) union until_deferrals` requires G-lifting all seed elements, which fails for the Until deferrals.

3. **Non-deterministic successor impossibility**: If `target not in x_content(M)`, then `neg(target) in x_content(M)` (MCS completeness), so no single MCS can be both x_content-compatible and contain the target.

### How Published Proofs Avoid This

Published proofs (Burgess 1984, GHR 1994) use **reflexive** temporal semantics where `G(phi) -> phi` is valid (the T-axiom for G). Under reflexive semantics:
- `g_content(M) includes all formulas in M` that are under G, and `g_content(M) subset M`
- If `(phi U psi)` persists indefinitely in an MCS chain, `G(phi U psi)` can be derived
- The meta-to-object conversion (`temporal_backward_G`) works without forward_F

This project uses **strict** semantics where `G(phi)` means `phi` at all **strictly** future times. The T-axiom is invalid. This breaks the quasimodel construction fundamentally.

## Applicability to BX Framework

### What Works Despite Strict Semantics

The BX axiom system has reflexive **Until/Since** semantics (BX8: `psi -> (phi U psi)`, meaning the witness can be the current time). This is distinct from the strict G/H semantics. Several key consequences:

1. **`or_until_in_mcs` is provable** (`SuccRelation.lean:578-594`): `(psi or (phi and (phi U psi))) in M -> (phi U psi) in M`. This replaces `until_intro` in the BX system.

2. **BX9 (Until elimination)**: `(phi U psi) -> (phi or psi)` -- gives the current-time property.

3. **BX5 (Self-accumulation)**: `(phi U psi) -> ((phi and (phi U psi)) U psi)` -- the eventuality enriches its own guard.

4. **BX10 (Eventuality extraction)**: `(phi U psi) -> F(psi)` -- connects Until to F.

### What the Deterministic Chain Already Has

The Boneyard `DeterministicFMCS.lean` demonstrates that for the deterministic chain (`chain(n+1) = x_content(chain(n))`):

- **Forward G/H**: sorry-free (via g_content/h_content propagation)
- **Backward Until**: sorry-free modulo `until_intro` (lines 340-395) -- uses induction on chain distance
- **Backward Since**: sorry-free modulo `since_intro` (lines 399-440) -- symmetric
- **Forward Until**: sorry (depends on forward_F)
- **Forward Since**: sorry (depends on backward_P)
- **Forward F/Backward P**: sorry (the core circularity)

### The `until_intro` Gap Is Closable

The `backward_until_chain` proof needs `until_intro: X(psi or (phi and (phi U psi))) -> (phi U psi)`. In the Boneyard, this was an axiom that was removed. But under BX8 (reflexive Until):

- `X(alpha) = bot U alpha` by definition
- `bot U alpha` implies `bot or alpha` by BX9
- `bot or alpha` implies `alpha` (propositional)
- So `X(alpha) -> alpha` is derivable for any `alpha`

Therefore: `X(psi or (phi and (phi U psi))) -> psi or (phi and (phi U psi))` is derivable. Composing with `or_until_in_mcs` gives `until_intro`.

**This closes the backward Until/Since gap completely.** The two `sorry /- until_intro removed in BX -/` sites at lines 371 and 395 can be replaced with the derivation above.

## Concrete Proposals for Overcoming Blockers

### Proposal 1: Port Backward Until/Since from DeterministicFMCS (HIGH priority)

The Boneyard has complete backward Until/Since proofs modulo `until_intro`. Since `until_intro` is derivable (see above), the backward direction is immediately available:

1. Derive `until_intro: X(psi or (phi and (phi U psi))) -> (phi U psi)` from BX8 + BX9
2. Derive `since_intro` symmetrically from BX8' + BX9'
3. Port `backward_until_chain` and `backward_since_chain` to the active codebase
4. These work for ANY chain with x_content linkage (deterministic or dovetailed)

**Effort**: ~200 lines. **Confidence**: 90%.

### Proposal 2: Forward Until via Enriched Seed + Dovetailing

For the forward direction, use the enriched seed approach (report 01, Approach D):

1. Seed at each step: `g_content(w_n) union {phi U psi : (phi U psi) in w_n and psi not in w_n}`
2. Consistency: Under BX1, `g_content(w_n) subset w_n`. Active Untils are in `w_n`. So enriched seed subset `w_n`, which is consistent.
3. Until persistence: Lindenbaum preserves the seed, so `(phi U psi)` persists.
4. Witness resolution: Dovetailed scheduling eventually injects `psi`. At that step, Lindenbaum either includes `psi` (resolving the Until) or rejects it (but then `psi` is in the seed and must be preserved -- need careful analysis here).
5. Guard verification: For intermediate steps, `(phi U psi) in w_r` and `psi not in w_r` implies `phi in w_r` by BX9.

**Key risk**: Step 4 -- whether the dovetailed target `psi` can coexist with `g_content union active_untils`. The joint consistency of `{psi} union g_content(w_n) union active_untils` needs explicit verification. The standard G-lift covers `{psi} union g_content(w_n)`. The active Untils are in `w_n` and do not interfere with the G-lift argument because they are added AFTER the G-lift.

**Effort**: ~400-600 lines. **Confidence**: 65%.

### Proposal 3: Split Definition (Fallback)

If forward Until proves intractable, split `until_since_coherent` into:
- `forward_until_since_coherent`: the forward directions only
- `backward_until_since_coherent`: the backward directions only

The truth lemma can potentially be restructured to use each direction independently. The backward direction is immediately provable (Proposal 1). The forward direction could be left as a weaker sorry while still making progress.

**Effort**: ~300 lines refactoring. **Confidence**: 80% (for the split itself).

## Recommended Approach

**Phase 1 (Immediate, high-confidence)**: Derive `until_intro`/`since_intro` from BX axioms and port backward Until/Since from DeterministicFMCS. This closes 2 of the 4 conjuncts in `until_since_coherent` for all three sorry sites.

**Phase 2 (Medium-confidence)**: Build enriched dovetailed chain for forward Until/Since. Target the dovetailed completeness path (line 450) first since it already has sorry-free temporal coherence.

**Phase 3 (Fallback)**: If Phase 2 stalls, implement the split definition approach. Close backward-only for all paths, and leave forward as a more precisely scoped sorry.

**Rationale**: Phase 1 is nearly risk-free and provides immediate value. The backward Until/Since pattern is fully worked out in the Boneyard; only the `until_intro` derivation is missing, and that derivation is straightforward under BX8+BX9. Phase 2 is the main technical challenge but builds on well-understood infrastructure. Phase 3 provides a graceful degradation path.

## Confidence Levels

| Finding | Confidence |
|---------|------------|
| Quasimodels inapplicable to strict semantics | HIGH (95%) |
| `until_intro` derivable from BX8+BX9 | HIGH (90%) |
| Backward Until/Since closable via ported proof | HIGH (85%) |
| Forward Until via enriched seed viable | MEDIUM (65%) |
| Joint seed consistency with dovetailed target | MEDIUM (55%) |
| Split definition as fallback | HIGH (80%) |

## References

- `SuccRelation.lean:558-594` -- `or_until_in_mcs` (reflexive until_intro)
- `DeterministicFMCS.lean:338-395` -- `backward_until_chain` (Boneyard)
- `DeterministicFMCS.lean:397-440` -- `backward_since_chain` (Boneyard)
- `DeterministicFMCS.lean:477-504` -- `usc` theorem wiring
- `TemporalCoherence.lean:466-479` -- `until_since_coherent` definition
- `Axioms.lean:196-201` -- BX8 (reflexive Until intro)
- `Axioms.lean:208-213` -- BX9 (Until elimination)
- Task 83 report 24 -- Full quasimodel/filtration study
- Task 84 reports 01, 02 -- Prior research synthesis and team findings
