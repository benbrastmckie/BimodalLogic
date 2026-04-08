# Teammate B Research: Simultaneous Well-Founded Induction on forward_F + forward_Until

**Task**: #85 - Until/Since chain coherence approaches
**Direction**: 2 - Simultaneous well-founded induction on forward_F + forward_Until
**Date**: 2026-04-08

## Key Findings

### Finding 1: The Two Architectures Have DIFFERENT Circularity Profiles

The codebase contains two distinct chain architectures, and they have fundamentally different circularity structures:

**Architecture A: Deterministic Chain (Boneyard)**
- File: `Theories/Bimodal/Boneyard/ChainCompleteness/Algebraic/DeterministicChain.lean`
- Chain: `chain(n+1) = x_content(chain(n))` (deterministic successor via X operator)
- Circularity: `forward_F(psi)` needs `backward_G(neg psi)` which needs `forward_F(neg(neg(psi)))` (genuine circular dependency, `complexity(neg(neg(psi))) = complexity(psi) + 4`)
- Status: **Boneyard** - archived with `forward_F_via_deferral` as sorry (line 381)

**Architecture B: Restricted Succ-Chain (Active)**
- File: `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`
- Chain: Built from `DeferralRestrictedSerialMCS` with F-nesting bounded by `closure_F_bound`
- Key theorem: `restricted_forward_chain_forward_F` (line 3128) is **PROVEN** for the forward Nat-indexed chain
- The proof uses F-nesting boundaries from `deferralClosure` finiteness, NOT backward_G
- Remaining sorries are in: (a) fuel=0 unreachable cases (3042, 5589, 5747), (b) BX axiom derivations, (c) WitnessSeed until/since_induction

**CRITICAL INSIGHT**: Architecture B already avoids the forward_F / backward_G circularity for the forward chain. The `restricted_forward_chain_forward_F` proof works by:
1. Getting F-nesting boundary from `restricted_forward_chain_F_bounded`
2. Applying `restricted_forward_bounded_witness` which uses fuel-based descent
3. At each step, either F-nesting depth decreases (resolution) or chain position advances (deferral)
4. Termination is by fuel consumption, not by formula complexity descent

### Finding 2: sizeof/complexity Analysis of the Circularity

**Formula complexity values** (from `Formula.complexity` and auto-generated `sizeOf`):

| Formula | complexity | sizeOf (auto) |
|---------|-----------|---------------|
| `psi` | c | s |
| `neg(psi) = imp psi bot` | c + 2 | s + 2 |
| `all_future(psi)` | c + 1 | s + 1 |
| `some_future(psi) = neg(all_future(neg psi))` | c + 5 | s + 5 |
| `neg(neg(psi))` | c + 4 | s + 4 |

The Architecture A circularity traced precisely:
- `forward_F(psi)`: need `F(psi) in chain(t) => exists s > t, psi in chain(s)`
- Uses contraposition: assume psi never appears, derive G(neg psi) in chain(t)
- `backward_G(neg psi)` needs `forward_F(neg(neg(psi)))` (so `F(neg(neg(psi)))` at chain(t) implies witness)
- `complexity(neg(neg(psi))) = complexity(psi) + 4` -- NO DESCENT

This means NO complexity-based measure works for Architecture A's circularity because the dependency goes from `psi` to `neg(neg(psi))` with STRICTLY INCREASING complexity.

### Finding 3: Subformula Depth vs sizeof -- DOES NOT HELP for Architecture A

**Question asked**: Does `neg(neg(psi))` have the same subformula depth as `psi`?

**Answer**: In the subformula DAG (the `subformulaClosure` from `SubformulaClosure.lean`), `neg(neg(psi))` is NOT a subformula of any formula containing `psi`. The subformula closure computes the structural subformulas by recursing through constructors. Since `neg(neg(psi)) = imp (imp psi bot) bot` contains `imp psi bot` which contains `psi`, the direction goes:
- `psi` IS a subformula of `neg(neg(psi))`
- `neg(neg(psi))` is NOT a subformula of `psi`

There is no double-negation identification in the subformula closure. The `deferralClosure` adds negations but does not identify `neg(neg(psi))` with `psi`.

**However**: The BX axiom system includes double-negation elimination (`peirce` axiom gives classical logic, enabling `dne_theorem: neg(neg(phi)) -> phi`). So in any MCS, `neg(neg(psi)) in M <=> psi in M`. This means we could define an EQUIVALENCE CLASS measure that identifies `psi` with `neg(neg(psi))`, but this would be a custom well-founded relation, not the standard `sizeOf`.

### Finding 4: Formula Pairing Induction -- DOES NOT BREAK THE CIRCULARITY for Architecture A

**Question asked**: Consider proving `forall (phi psi : Formula), sizeof phi + sizeof psi <= n -> forward_F(phi) AND forward_Until(phi, psi)` by strong induction on n.

**Analysis**: The dependency chain for Architecture A is:
1. `forward_F(psi)` at bound `n = sizeof(psi)`
2. Needs `backward_G(neg(psi))` which needs `forward_F(neg(neg(psi)))` at bound `sizeof(neg(neg(psi))) = sizeof(psi) + 4`
3. So `forward_F` at bound `n` needs `forward_F` at bound `n + 4`

This goes UPWARD, not downward. No repackaging into pairs helps because the dependency is unbounded -- it goes `n -> n+4 -> n+8 -> ...`.

The pairing approach could work if the second parameter decreased while the first increased by a bounded amount, but here there IS no second parameter to decrease.

### Finding 5: Architecture B Already Has the Right Structure -- The Remaining Sorries Are Elsewhere

**The restricted chain construction in SuccChainFMCS.lean avoids backward_G entirely.** Here is how:

The proof of `restricted_forward_chain_forward_F` (line 3128) works as follows:
1. Given `F(psi) in chain(n)`, find the F-nesting boundary: `iter_F d psi in chain(n)` with `iter_F (d+1) psi not in chain(n)`, for some `d >= 1`.
2. Apply `restricted_forward_bounded_witness` (line 3110) which uses:
   - **F_step_witness** (line ~3050): Either `iter_F k theta in chain(k+1)` (resolution: depth decreases) or `F(iter_F k theta) in chain(k+1)` (deferral: position advances).
   - Fuel-based recursion: termination by `fuel` parameter, NOT by formula complexity.
3. The key property: within `deferralClosure(root)`, F-nesting is bounded by `closure_F_bound phi`, so the fuel bound `B * B + 1` suffices.

**This means the circularity is ALREADY BROKEN in Architecture B.** The remaining issues are:

**Sorry type 1: Fuel exhaustion (lines 3042, 5589, 5747)**
These are `fuel = 0` branches marked "semantically unreachable." They would be eliminated by proving that `B * B + 1` fuel always suffices. This is a TERMINATION argument, not a circularity argument.

**Sorry type 2: BX axiom derivations (CanonicalFrame:259, SuccChainFMCS:125,135,420)**
- `temp_4` (G(phi) -> G(G(phi))) needs derivation from BX axioms
- `seriality_future/past` needs derivation from BX axioms
These are standalone proof obligations, not related to the forward_F circularity.

**Sorry type 3: Removed axioms (WitnessSeed:450,569; TemporalContent:274,306,351,415)**
- `until_induction`, `x_k_dist`, `y_k_dist`, `x_det`, `y_det` were removed in "BX" refactor
- These need re-derivation from the new BX axiom system
- CRITICAL: `until_induction` is used in WitnessSeed.lean for proving that the Until witness seed is consistent

**Sorry type 4: Cross-chain F/P witness (lines 5939-5943)**
- `restricted_backward_to_combined_F_witness` for backward-chain elements uses the combined bounded witness, which has a fuel=0 sorry

**Sorry type 5: `until_persists_through_succ` (SuccRelation:548)**
- (phi U psi) in u and neg(psi) in u does NOT imply (phi U psi) in v where Succ(u,v)
- Under reflexive Until, ψ → (φ U ψ) is an axiom (BX8), but if psi is NOT in v, we need the self-accumulation route
- This is BLOCKED because the Succ relation only propagates g_content and f_content, not Until formulas directly

**Sorry type 6: Forward Until coherence (TemporalCoherence.lean: lines 487-494)**
- Research conclusively shows forward Until/Since coherence is blocked by Lindenbaum extension freedom
- Only backward Until/Since coherence is proven

### Finding 6: F_until_equiv Is NOT Used in Architecture B

**Question asked**: Does the finite deferral approach depend on F_until_equiv?

**In Architecture A (Boneyard)**: YES. `F_to_until_in_mcs` (FiniteDeferral.lean:44) explicitly uses `F_until_equiv` with a sorry on line 48. The entire Boneyard approach chains: `F(psi) -> (T U psi) -> persistence -> pigeonhole -> contradiction`.

**In Architecture B (Active)**: NO. The `restricted_forward_chain_forward_F` proof does NOT use `F_until_equiv`. It uses F-step deferral directly through the successor construction:
- F-step witness: `F(theta) in chain(n)` implies `theta in chain(n+1)` OR `F(theta) in chain(n+1)`
- This comes from the Succ relation's f_content propagation, not from Until axioms.

The BX axiom system does have `until_F` (BX10: `(phi U psi) -> F(psi)`), which goes in the OPPOSITE direction (Until implies F, not F implies Until). This is sound under reflexive Until semantics and does NOT have a soundness issue.

### Finding 7: The Actual Critical Path for Sorry Elimination

The sorry sites in the active codebase (Architecture B) fall into these categories:

**Category A: BX Axiom Derivations (5 sorries)**
- temp_4, seriality_future, seriality_past, temp_4 (duplicate)
- These need pure proof-theoretic work: derive these from BX1-BX10 axioms
- Confidence: HIGH that these are derivable (they are valid in the semantics)

**Category B: Removed Discrete Axiom Derivations (6 sorries)**
- x_k_dist, y_k_dist, x_det, y_det (TemporalContent)
- until_induction, since_induction (WitnessSeed)
- These were axioms in the old system, removed in BX refactor
- x_k_dist: `X(a -> b) -> (X(a) -> X(b))` where `X(phi) = bot U phi`
  - Derivable from BX2 (left_mono_until) + BX3 (right_mono_until) + BX axioms
- until_induction: `G(psi -> chi) AND G((phi AND (chi U chi)) -> chi) -> ((phi U psi) -> (chi U chi))`
  - This is a deep theorem; derivability from BX1-BX10 is NOT obvious

**Category C: Fuel Exhaustion (3 sorries)**
- Lines 3042, 5589, 5747
- Need proof that fuel B*B+1 suffices
- Requires showing that the total number of F-step deferrals + resolutions is bounded

**Category D: Forward Until Coherence (structural impossibility)**
- Research shows this cannot be proven for the current Lindenbaum-based architecture
- Either needs a different construction or a different truth lemma approach

**Category E: until_persists_through_succ (1 sorry)**
- May be provable using the self-accumulation axiom BX5

## Concrete Proof Sketch for Breaking the Remaining Sorries

### Approach: Work Within Architecture B, Close Category A+B+C

**Step 1**: Derive `temp_4` from BX axioms.
- `G(phi) -> G(G(phi))` under reflexive Until semantics with connect_future (BX4).
- BX4: `phi -> G(P(phi))`. From `G(phi)`, we need `G(G(phi))`.
- Take any s > t where G(phi) holds at t. Then phi holds at s (by G(phi) at t).
  Actually, G(phi) -> G(G(phi)) IS temp_4 which is already a BX axiom! The sorry may be an error -- let me check.

Actually looking at the axiom list, `temp_4` IS a BX base axiom (line 745 in Soundness.lean). The sorry at CanonicalFrame.lean:259 says "BX: derive temp_4 from BX1" which appears to be a mistake -- temp_4 is already an axiom, not something that needs derivation from BX1.

**Step 2**: Derive `x_k_dist: X(a -> b) -> (X(a) -> X(b))` from BX axioms.
- `X(phi) = bot U phi`
- Need: `(bot U (a -> b)) -> ((bot U a) -> (bot U b))`
- From `bot U (a -> b)` at t: exists s >= t with `a -> b` at s, and bot holds on (t, s) (vacuously since bot is always false, so s = t).
- Under reflexive Until: `bot U phi` at t means there exists s >= t with phi at s and bot on [t,s). Since bot is never true, the guard forces s = t. So `bot U phi` at t iff phi at t.
- Therefore `X(phi)` is equivalent to `phi` in any MCS! This follows from BX8 (`psi -> phi U psi`) and BX9 (`phi U psi -> phi or psi`).
- So x_k_dist reduces to `(a -> b) -> (a -> b)`, which is trivially derivable.

**THIS IS THE KEY INSIGHT**: Under the BX system with reflexive Until semantics, `X(phi) = bot U phi` is equivalent to `phi` itself. The "next step" operator degenerates. This means:
- x_k_dist is trivial
- y_k_dist is trivial (by symmetry)
- x_det and y_det are trivial
- The entire x_content/y_content machinery may need revision

**Wait -- this changes everything.** If X(phi) = phi, then x_content(M) = M (every formula in M has X(it) in M, which is just itself). The entire deterministic chain degenerates: chain(n) = chain(0) for all n. This would mean temporal operators are trivial, which contradicts the intended semantics.

**Resolution**: The BX system has REFLEXIVE Until (witness s >= t), which makes X(phi) = bot U phi equivalent to phi. But the actual semantics in Truth.lean uses STRICT Until (witness s > t for the guard interval). Let me verify...

Looking at `Axioms.lean` line 197-199: BX8 says `psi -> (phi U psi)` with comment "Under reflexive Until semantics, the witness s = t (current time) always works." And the Soundness proof at `refl_intro_until_valid` (referenced at line 760) confirms this.

But Truth.lean's semantics for Until -- let me check:

Actually, from `CanonicalConstruction.lean` line 84:
```
theorem canonical_truth_lemma ... : phi in fam.mcs t <-> truth_at ...
```

And the Until clause in truth_at would use the frame's Until semantics. The key issue: the BX axioms are designed for reflexive Until (s >= t witness), but the truth evaluation uses whatever semantics the frame prescribes.

The reflexive/strict distinction is crucial. If BX8 is an axiom (reflexive intro), then in any MCS, `psi -> (phi U psi)` holds, so `psi in M => phi U psi in M`. Combined with BX9 (`phi U psi -> phi or psi`), this gives `phi U psi <=> phi or psi` modulo logical equivalence in any MCS... No, that's wrong. BX9 gives `phi U psi => phi or psi`, and we can get `psi => phi U psi` from BX8, but `phi => phi U psi` is NOT derivable from BX8 alone.

However, `bot U psi` under BX8 gives: `psi => bot U psi`. Under BX9: `bot U psi => bot or psi => psi` (since `bot or psi = neg(bot) -> psi` which with `neg(bot)` being a tautology gives psi). So indeed `bot U psi <=> psi` in any MCS.

**This means X(phi) = phi in any MCS.** The "next step" collapses.

This has profound implications:
1. The x_content/y_content construction becomes trivial (or degenerate)
2. The deterministic chain collapses to a single point
3. The Until semantics must be strict (s > t) for non-trivial temporal behavior
4. The BX axioms (particularly BX8: reflexive intro) create a tension with strict semantics

### Updated Assessment After X(phi) = phi Discovery

This finding fundamentally changes the analysis. Under reflexive Until (BX8), the next-step operator is trivial, so the deterministic chain approach (Architecture A) is built on a degenerate construction.

Architecture B works differently -- it uses the `Succ` relation from `SuccRelation.lean` which is NOT based on x_content/y_content alone. The Succ relation captures `f_content(u) subset v` and `g_content(u) subset v`, where:
- `f_content(M) = {phi : F(phi) in M}` (existential future witnesses)
- `g_content(M) = {phi : G(phi) in M}` (universal future formulas)

This is independent of the X operator, so Architecture B's chain construction is NOT degenerate.

However, the sorry sites in TemporalContent.lean (x_k_dist, y_k_dist, x_det, y_det) and WitnessSeed.lean (until_induction, since_induction) use the X/Y operators. If X(phi) = phi, these become trivial or need restating.

## Gaps and Risks

### Gap 1: X(phi) = phi Degeneracy
The equivalence `X(phi) = bot U phi <=> phi` under BX8 + BX9 means all X-based infrastructure is trivially true but potentially vacuous. The WitnessSeed proof of Until witness consistency uses `until_induction` which is stated in terms of X. If X is trivial, the proof may simplify dramatically -- or the entire approach may need rethinking.

**Risk**: MEDIUM. The X degeneracy is mathematically correct under reflexive Until, but the codebase may have been written assuming X is non-trivial (strict Until). The BX axiom set may be inconsistent with the strict semantics used in Truth.lean.

### Gap 2: Reflexive vs Strict Semantics Tension
BX8 (`psi -> phi U psi`) is valid under REFLEXIVE Until (s >= t witness) but NOT under strict Until (s > t witness, guard on (t,s)). The Soundness.lean proof (line 760) proves it for reflexive semantics. But if the truth lemma uses strict Until semantics, there is a fundamental mismatch.

**Risk**: HIGH. This may be the ROOT CAUSE of all the sorries -- the axiom system and semantics may be subtly incompatible. If Until is strict in the model but reflexive in the axioms, the truth lemma cannot hold for Until formulas.

### Gap 3: Forward Until Coherence
Even with Architecture B's forward_F proven, forward Until coherence (the semantic witness for `phi U psi` with guard condition) remains blocked. Research from task 84 shows this is structural: Lindenbaum extensions break Until persistence.

**Risk**: HIGH. This is the hardest remaining sorry category.

### Gap 4: Fuel Exhaustion Proofs
The fuel=0 sorries are "semantically unreachable" but need formal proof that `B * B + 1` fuel suffices.

**Risk**: LOW. Standard argument about bounded deferral within finite closure.

## Confidence Level

**Overall confidence in simultaneous well-founded induction approach**: LOW for Architecture A, NOT NEEDED for Architecture B.

- Architecture A's circularity is GENUINE and cannot be broken by any formula-complexity measure (Finding 2, 4). The dependency goes `n -> n+4 -> n+8 -> ...` which is strictly increasing. No well-founded induction on formula complexity/size/depth can work.

- Architecture B ALREADY AVOIDS the circularity for forward_F (Finding 1, 5). The remaining sorries are in different categories (BX derivations, fuel exhaustion, forward Until coherence, X-degeneracy implications).

- The X(phi) = phi discovery (Finding 7) reveals a potentially fundamental issue with the axiom system's compatibility with strict semantics, which may be the root cause of many difficulties.

## Recommendation

### Primary Recommendation: Investigate the Reflexive/Strict Until Tension

Before pursuing any specific sorry-fixing strategy, the team should resolve the fundamental question: **Does the BX axiom system match the Truth.lean semantics for Until?**

If Until is reflexive in the axioms (BX8) and reflexive in the semantics, then X(phi) = phi and much of the x_content/y_content infrastructure trivializes. The chain construction needs rebuilding around f_content/g_content (which is what Architecture B does).

If Until is reflexive in the axioms but strict in the semantics, there is a soundness gap, and the entire completeness approach needs revision.

### Secondary Recommendation: Focus on Architecture B's Remaining Sorries

Assuming the reflexive/strict issue is resolved:

1. **Derive BX axioms** (temp_4 is already an axiom -- remove the sorry that asks to "derive" it). Derive seriality from frame conditions.

2. **Prove fuel sufficiency** for the bounded witness lemmas. This is routine but requires tracking the F-nesting bound through the recursion.

3. **For forward Until coherence**: Consider the quasimodel approach (as recommended in FiniteDeferral.lean:375-376) which builds explicit witness sets globally rather than incrementally. This avoids the Lindenbaum extension problem entirely.

4. **For x_k_dist/y_k_dist**: If X(phi) = phi, these are trivial. Prove the equivalence `bot U phi <=> phi` in MCS and use it to simplify all X/Y-based sorries.

### Do NOT Pursue: Simultaneous Well-Founded Induction for Architecture A

The circularity in Architecture A is genuine and unbreakable by complexity measures. Architecture B already solves this differently. Investing further in Architecture A's approach has zero expected return.
