# Handoff: Plan 06 until_neg_carry Approach is Mathematically Flawed

## Session
- **Task**: 93
- **Session ID**: sess_1776107176_04850a
- **Date**: 2026-04-13
- **Agent**: lean-implementation-agent

## Finding

The Plan 06 approach of adding `until_neg_carry(M)` to the `fwd_succ` seed to achieve forward stability of negated Until formulas is **mathematically flawed** in two independent ways:

### Flaw 1: Forward Stability is Semantically Invalid

The claim that `neg(phi U psi) in chain(t) -> neg(phi U psi) in chain(t+1)` is NOT semantically valid over linear temporal orders.

**Counterexample**: Let phi be false at time 0, true at times >= 1. Let psi be true at time 2.
- At time 0: `(phi U psi)` requires psi at some t >= 0 with phi on [0, t). For t=2: need phi on [0,2) = {0,1}, but phi false at 0. So `neg(phi U psi)` holds at 0.
- At time 1: `(phi U psi)` requires psi at some t >= 1 with phi on [1, t). For t=2: phi on [1,2) = {1}, phi true at 1. And psi at 2. So `(phi U psi)` holds at 1.

Therefore `neg(phi U psi)` at 0 does NOT imply `neg(phi U psi)` at 1. Forward stability fails.

### Flaw 2: Consistency of Enriched Resolving Seed

Even if forward stability were valid, the resolving seed `{psi} union g_content(M) union until_neg_carry(M)` can be INCONSISTENT.

**Proof**: BX8 (refl_intro_until) gives `psi -> (phi U psi)`. Contrapositive: `neg(phi U psi) -> neg psi`. So `{psi, neg(phi U psi)}` derives bot.

If `neg(phi U psi) in until_neg_carry(M)` and we're resolving F(psi), then both psi and neg(phi U psi) are in the seed, making it inconsistent. We cannot call `set_lindenbaum` on an inconsistent seed.

The plan's claim "Consistency is trivial: until_neg_carry(M) subset M" is wrong for the resolving branch because `{psi}` is NOT a subset of M (psi may not be in M; only F(psi) is).

### Flaw 3: Unconditional Step Transfer Fails

Even the GUARDED step transfer `(phi U psi) in chain(r+1) and phi in chain(r) -> (phi U psi) in chain(r)` fails when the step from r to r+1 is a resolving step that resolves formula c = (phi U psi) itself (putting it directly in chain(r+1) while neg(phi U psi) in chain(r)).

## Impact

- **Phase 1** is BLOCKED: the core mechanism is invalid
- **Phase 2** depends on Phase 1 (step transfer for backward Until): BLOCKED
- **Phase 4** depends on Phase 2 (guard argument for forward Until): BLOCKED
- **Phases 3 and 5** may be partially independent

## Alternative Approaches

### Option A: Deterministic Chain
Use the `DeterministicChain` (Boneyard) approach which builds chain(t+1) = x_content(chain(t)) where x_content = {alpha | (bot U alpha) in chain(t)}. This gives the X-operator property needed for backward Until (already proven sorry-free in DeterministicFMCS.lean). The challenge is proving forward_F for this chain (also sorry there).

### Option B: Hybrid Chain
Combine the scheduling-based chain (for forward_F) with the X-operator property (for backward Until). This requires showing g_content subset x_content, which fails because `G(alpha) -> (bot U alpha)` is not derivable in BX (it fails over dense time).

### Option C: Direct Backward Until Without Step Transfer
Prove backward Until coherence directly for the scheduling chain without step transfer. This would require a fundamentally new proof technique that we haven't identified yet.

### Option D: Strengthen the Chain Construction
Define a new chain where:
1. The non-resolving seed includes `{alpha | (bot U alpha) in chain(t)}` (x_content) in addition to g_content and f_carry
2. The resolving seed also includes x_content
3. This gives a weak form of the X-operator property while preserving the scheduling mechanism

The consistency of this augmented seed needs verification. Since x_content(M) subset M (by BX8 applied to bot U: `alpha -> (bot U alpha)` is provable, so `(bot U alpha) in M -> alpha in M` by T-axiom for bot U... wait, is T for bot U provable? `(bot U alpha) -> alpha` says the next step alpha holds now, which is NOT generally derivable without reflexivity of bot U).

Actually x_content(M) may NOT be a subset of M in the BX system.

### Recommended Path: Option A (port DeterministicChain)

The deterministic chain already has backward Until/Since proved sorry-free. The remaining challenge (forward_F) is shared with the current approach. Porting the deterministic chain to the active codebase and combining it with the deferral seed approach for restricted forward_F seems the most promising path.

## Files Examined
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` (lines 49-660)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/UntilSinceCoherence.lean` (backward_until_from_step)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/WitnessSeed.lean` (forward_temporal_witness_seed_consistent)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Boneyard/ChainCompleteness/Algebraic/DeterministicFMCS.lean` (backward_until_chain)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/ProofSystem/Axioms.lean` (BX axiom inventory)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Theorems/TemporalDerived.lean` (until_intro)

## Prior Research Flaw
The team research (Report 06, all 4 teammates) endorsed the until_neg_carry approach. Teammate D's confidence of 95% on seed consistency was incorrect. The specific error was assuming `{psi} union g_content(M) union until_neg_carry(M) subset M` which fails because `{psi} not subset M` in the resolving branch. The semantic invalidity of forward stability (Flaw 1) was also missed by all teammates.
