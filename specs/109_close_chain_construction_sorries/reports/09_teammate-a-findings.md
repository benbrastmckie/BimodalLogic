# Teammate A Findings: First-Principles Semantic Analysis

## Key Findings

### 1. psi_imp_until is semantically invalid and irreparable under irreflexive Until (Confidence: CERTAIN)

Under the A2 guard convention (Truth.lean:127-128), `phi U psi` at time t means:
```
exists s : D, t < s /\ truth(psi, s) /\ forall r, t <= r -> r < s -> truth(phi, r)
```

The witness s must be **strictly future** (t < s). Therefore `psi` holding at the current time t provides no witness for `phi U psi` at t. The theorem `psi -> (phi U psi)` (BX8) is definitionally unsound.

**No weaker replacement works as a direct substitute.** The candidates:
- `phi /\ F(psi) -> phi U psi`: UNSOUND. Having phi at t and psi at some s > t does not guarantee phi holds on the open interval (t, s). The guard covers [t, s), so phi at t is covered, but nothing guarantees phi at intermediate points.
- `F(psi) -> top U psi`: This IS BX12, already an axiom. But it only gives `top U psi`, not `phi U psi`.
- `psi /\ F(psi) -> phi U psi`: UNSOUND for the same intermediate-point reason.

### 2. Full impact chain of BX8 removal (Confidence: HIGH)

Tracing the dependency graph from `psi_imp_until` (TemporalDerived.lean:232):

**Direct dependents (sorry'd):**
- `psi_imp_until` (line 232) -- sorry'd
- `psi_imp_since` (line 242) -- sorry'd (dual)

**Downstream consumers that transitively depend on psi_imp_until:**
1. `or_until_imp` (line 343): Uses `psi_imp_until` in its proof via contrapositive argument. This is `(psi \/ (phi /\ (phi U psi))) -> (phi U psi)`.
2. `or_since_imp` (line 360): Dual, uses `psi_imp_since`.
3. `until_unfold_wrapped` (line 395): Composes `until_unfold_thm` with `psi_imp_until bot`.
4. `since_unfold_wrapped` (line 401): Dual.
5. `until_intro` (line 409): Composes `bot_until_id` with `or_until_imp`. Key rule for backward Until induction.
6. `since_intro` (line 415): Dual.
7. `refl_F` (line 431): `alpha -> F(alpha)` -- sorry'd independently (also invalid under irreflexive semantics).
8. `refl_P` (line 440): Dual, sorry'd.
9. `until_F_expansion` (line 459): Uses `refl_F`.
10. `since_P_expansion` (line 492): Uses `refl_P`.
11. `backward_until_reflexive` (UntilSinceCoherence.lean:81): Direct consumer of `psi_imp_until`.
12. `backward_since_reflexive` (UntilSinceCoherence.lean:91): Dual.
13. `backward_until_from_step` (UntilSinceCoherence.lean:111): Base case at line 130 calls `backward_until_reflexive`.
14. `backward_since_from_step` (UntilSinceCoherence.lean:145): Dual.
15. SuccRelation.lean:580 -- `psi_imp_until_in_mcs`
16. SuccRelation.lean:601 -- `psi_imp_since_in_mcs`

**Critical observation**: The base case of `backward_until_from_step` (when s = t, the witness is at the same position as the target) requires `psi -> (phi U psi)`. Under irreflexive Until, this base case **cannot occur** because the Until witness must be strictly future. So the induction structure must change: the base case should be s = t + 1 (one step ahead), not s = t.

### 3. The BX axiom system is likely incomplete for the intended irreflexive semantics (Confidence: HIGH)

The 35 axioms in Axioms.lean were designed for a system where BX8 was present (reflexive Until). The removal of BX8 without adding a replacement axiom creates a gap.

**Evidence of incompleteness:**

(a) `psi -> (phi U psi)` is the only way to introduce Until formulas from non-Until hypotheses in the current axiom system. BX12 (`F(phi) -> top U phi`) introduces Until from F-formulas, but with a trivially true guard. BX5 and BX6 transform existing Until formulas. BX9 and BX10 eliminate Until. Without BX8, there is no axiom that introduces `phi U psi` from `phi` and `psi` separately (at different times).

(b) The intended semantics (strict Until on dense linear orders without endpoints) is the semantics of Burgess-Xu for strict temporal logic. The standard Burgess-Xu axiomatization for **strict** Until explicitly includes axioms like:
```
phi /\ F(psi) /\ G(phi \/ psi) -> phi U psi
```
This says: if phi holds now, psi holds somewhere in the future, and at every future point either phi or psi holds, then phi U psi. This is sound under strict Until because the guard [t, s) is covered by: phi at t (from the first conjunct), and for any r in (t, s), either phi(r) or psi(r); since psi first occurs at s, phi must hold at all r in (t, s).

(c) The BX axiom system also lacks `alpha -> F(alpha)` (refl_F), which is invalid under strict semantics but is derivable in reflexive systems from `G(phi) -> phi` (BX1 in reflexive form). Under irreflexive semantics, seriality (BX1: `top -> F(top)`) does NOT give `alpha -> F(alpha)`. These are fundamentally different: seriality says every time has a successor, while reflexivity of F says the current time witnesses its own future.

### 4. g_content propagation problem: precise characterization (Confidence: CERTAIN)

`g_content(M) = {alpha | G(alpha) in M}`.

Under irreflexive G, `G(alpha) in M` does NOT imply `alpha in M`. So `g_content(M)` is NOT a subset of M. This is explicitly used in the codebase: `g_content_set_consistent` (Frame.lean:122) proves consistency of g_content(M) using seriality, not by appealing to M's consistency via subset inclusion.

**What IS preserved across chain steps:**
- If `G(alpha) in chain(n)`, then by temp_4 (`G(alpha) -> G(G(alpha))`), `G(G(alpha)) in chain(n)`. So `G(alpha) in g_content(chain(n))`. Therefore `G(alpha) in chain(n+1)` by `fwd_succ_g_content`. So **G-formulas propagate forward**.
- By the same argument, `alpha in chain(n+1)` (from `G(alpha) in chain(n)` via g_content).

**What is NOT preserved:**
- `F(alpha) in chain(n)` does NOT imply `F(alpha) in chain(n+1)`. F-formulas are not G-formulas, so they are invisible to g_content.
- `(phi U psi) in chain(n)` does NOT imply `(phi U psi) in chain(n+1)`. Until formulas are not G-formulas either.
- `alpha in chain(n)` (bare formulas) do NOT propagate forward. Only formulas wrapped in G do.

**F-obligation monotonicity (proved, RootScopedChain.lean:113-143):** Once F(phi) LEAVES the chain, it never returns. This is because if F(phi) is not in chain(n), then G(neg(phi)) is in chain(n), and G(neg(phi)) propagates forward via g_content (since G(G(neg(phi))) in chain(n) by temp_4), ensuring F(phi) stays absent.

This monotonicity means F-obligations can only be lost, never regained. The chain construction must resolve them before they are lost.

### 5. The Ordered Seed Consistency Theorem from report 13: mostly correct but has a gap (Confidence: HIGH)

**Claim (report 13, Section 2.1):** If `F(psi_1 /\ F(psi_2)) in M`, then `{psi_1, F(psi_2)} union g_content(M)` is consistent.

**Verification of the proof sketch:**

The proof proceeds by contradiction. Assume `{psi_1, F(psi_2)} union L_g derives bot` where L_g is from g_content(M).

Step 1: By deduction, `{psi_1} union L_g derives neg(F(psi_2))`, i.e., `{psi_1} union L_g derives G(neg(psi_2))`. **Correct** -- F(psi_2) = neg(G(neg(psi_2))), so neg(F(psi_2)) = neg(neg(G(neg(psi_2)))) which is equivalent to G(neg(psi_2)) via double negation.

Wait -- this is subtle. `neg(F(psi_2)) = neg(neg(G(neg(psi_2))))`. The deduction gives us `L_g derives psi_1 -> neg(neg(G(neg(psi_2))))`. To get `G(neg(psi_2))`, we need DNE. Then `L_g derives psi_1 -> G(neg(psi_2))`. **Correct** (DNE is available in classical logic, and the proof system includes Peirce's law).

Step 2-3: `L_g derives psi_1 -> G(neg(psi_2))`. By generalized temporal K on L_g (all in g_content): `G(psi_1 -> G(neg(psi_2))) in M`. **Correct** -- generalized temporal K distributes G over derivations, and each element of L_g has its G-wrapped version in M.

Step 4-5: `G(psi_1 -> G(neg(psi_2)))` implies `G(psi_1 -> neg(F(psi_2)))` which equals `G(neg(psi_1 /\ F(psi_2)))`. **Correct** -- since `G(neg(psi_2)) = neg(F(psi_2))` definitionally, and `(A -> neg(B))` is equivalent to `neg(A /\ B)`.

Step 6-7: `F(psi_1 /\ F(psi_2)) in M` contradicts `G(neg(psi_1 /\ F(psi_2))) in M`. **Correct** -- these are negations of each other.

**The theorem is correct.**

**However, the gap is in report 13's claim about how BX11 provides the ordering.** Report 13 claims (Section 2.2) that BX11 always produces `F(psi_j /\ bigwedge_{k != j} F(psi_k))` for some j. This requires iterating BX11 over all pairs and showing a consistent ordering emerges. The BX11 axiom gives three disjuncts for each pair, and MCS maximality selects one. But the claim that the selections are globally consistent (producing a total order on witnesses) needs a more careful argument. With 2 witnesses it's fine (BX11 directly gives the order). With k > 2 witnesses, one needs to show transitivity of the "earlier witness" relation, which requires additional BX11 applications and MCS case analysis.

**This is technically feasible but nontrivial to formalize.**

### 6. forward_temporal_witness_seed analysis (Confidence: CERTAIN)

`forward_temporal_witness_seed M psi = {psi} union g_content(M)` (WitnessSeed.lean:50).

The seed contains:
- The target formula psi
- All formulas alpha such that G(alpha) is in M

The consistency proof (WitnessSeed.lean:81-178) is **correct and sorry-free**. It works under irreflexive semantics because it never uses the T-axiom (G(phi) -> phi). Instead, it derives contradictions via generalized temporal K and seriality.

**Can the seed be enriched?** The report 13 approach enriches it to `{psi_j} union g_content(M) union {F(psi_k) | k != j}`. The Ordered Seed Consistency Theorem (Finding 5) shows this is consistent when the ordering is right.

**Further enrichment with Until formulas is problematic.** As report 13 analyzes in detail (Part 2, around the u_forward discussion), adding Until formulas from M to the seed can break consistency because the target psi_j may conflict with Until formulas via g_content derivations. The seed `{psi_j} union chain(r)` is always inconsistent when psi_j is not in chain(r) (since neg(psi_j) is in chain(r) by MCS maximality). So only carefully selected subsets of chain(r) can be added.

### 7. The backward Until coherence problem is fundamentally distinct from F-resolution (Confidence: HIGH)

The three sorry sites in RootScopedChain.lean address two different problems:

**Problem A (F/P resolution -- sorry site 1, `bx_bfmcs_restricted_tc`):** Given F(phi) in chain(t), find s > t with phi in chain(s). This is the "F-formula loss" problem: the Lindenbaum extension at each chain step may destroy F-obligations.

**Problem B (Until/Since coherence -- sorry sites 2-3, `bx_bfmcs_restricted_buc` and `bx_bfmcs_restricted_fuc`):**

- **Forward Until coherence (fuc):** Given `(phi U psi) in chain(t)`, find witness s > t with psi in chain(s) and phi in chain(r) for all r in [t, s). This requires both resolving the psi-witness (similar to F-resolution) AND maintaining the phi-guard at intermediate positions.

- **Backward Until coherence (buc):** Given psi in chain(s) and phi in chain(r) for all r in [t, s), derive `(phi U psi) in chain(t)`. Under irreflexive Until, the base case (s = t) CANNOT occur (the witness must be strictly future). The induction must start from `s = t + 1`: psi in chain(t+1) and phi in chain(t) should give `(phi U psi) in chain(t)`.

**The step transfer problem for buc:** We need: `(phi U psi) in chain(r+1)` and `phi in chain(r)` implies `(phi U psi) in chain(r)`. This is semantically valid (the witness for Until at r+1 plus the guard phi at r gives a witness for Until at r). But it is NOT syntactically derivable from just g_content propagation. The chain only guarantees `g_content(chain(r)) subset chain(r+1)`, which gives forward G-propagation but no backward Until-propagation.

Report 13's analysis of this (Part 2, long discussion starting "The step transfer for backward Until coherence") correctly identifies this as a separate obstacle from F-resolution.

### 8. The irreflexive base case for backward Until induction (Confidence: CERTAIN)

Under irreflexive Until, `backward_until_from_step` (UntilSinceCoherence.lean:111-138) has a structural problem in its base case. The induction on `d = s - t` with:
- Base case d = 0 (s = t): calls `backward_until_reflexive` which calls `psi_imp_until` -- sorry'd.
- Inductive case d = d' + 1: calls the step transfer hypothesis.

Under irreflexive semantics, the base case d = 0 should be IMPOSSIBLE because the Until witness must be strictly future (t < s, so d >= 1). The correct induction structure should be:
- Base case d = 1 (s = t + 1): psi in chain(t+1), guard is vacuous (no r with t <= r < t+1 in Int), so we just need `(phi U psi) in chain(t)`. But how? We have psi one step ahead. Under irreflexive Until, `phi U psi` at t requires a witness s > t with psi(s) and phi on [t, s). With s = t+1, the guard is phi on [t, t+1) = {t}, so phi(t) is needed. So we need: phi in chain(t) AND psi in chain(t+1) implies (phi U psi) in chain(t). This IS the step transfer from UntilSinceCoherence.lean, but for the s = t+1 case specifically.

So the entire backward Until coherence reduces to the step transfer hypothesis for the specific chain construction.

## Recommended Approach

1. **Accept that the BX axiom system needs augmentation for irreflexive semantics.** At minimum, a replacement for BX8 that is sound under strict Until is needed. The most natural candidate is an axiom like:
   ```
   G(phi \/ psi) /\ phi /\ F(psi) -> phi U psi
   ```
   This says: if at every future time either phi or psi holds, and phi holds now, and psi eventually holds, then phi U psi. This is sound under strict Until with half-open guard.

2. **Alternatively, work within the existing axiom system by proving a conditional step transfer.** The chain construction can potentially provide `(phi U psi) in chain(r)` from `phi in chain(r)` and `psi in chain(r+1)` if the seed for chain(r+1) is enriched to include Until-relevant information. But this requires the enriched seed consistency proof from the Ordered Seed Consistency approach.

3. **The F-resolution problem (sorry site 1) and the Until coherence problems (sorry sites 2-3) should be attacked together** via a unified chain construction that:
   - Resolves F-defects via ordered defect discharge (report 13 approach)
   - Carries Until formulas forward through the chain
   - Provides the step transfer property structurally

## Evidence/Examples

**Example: psi_imp_until failure under irreflexive Until**

Consider D = Int, t = 0. Let psi = p (atom). Under irreflexive Until, `p U p` at time 0 requires: exists s > 0 with p(s) and p on [0, s). If p is true only at time 0 and false at all times > 0, then `p U p` is false at 0 even though p is true at 0. So `psi -> (phi U psi)` fails.

**Example: g_content propagation failure for F-formulas**

Let chain(0) = M0 with F(alpha) in M0. g_content(M0) = {beta | G(beta) in M0}. F(alpha) = neg(G(neg(alpha))). This is NOT of the form G(gamma) for any gamma. So F(alpha) is not in g_content(M0). The Lindenbaum extension for chain(1) has seed {target} union g_content(M0), which does not contain F(alpha). The extension may freely include G(neg(alpha)), making F(alpha) permanently lost.

**Example: step transfer semantic validity**

At time r: phi holds. At time r+1: phi U psi holds, meaning exists s > r+1 with psi(s) and phi on [r+1, s). Then at time r: phi on [r, r+1) = {r} is given. phi on [r+1, s) from the Until at r+1. So phi on [r, s) total. And psi(s) with s > r+1 > r. So phi U psi at r. Semantically valid.

## Confidence Level

**Overall confidence: HIGH.** The semantic analysis is based directly on the formal definitions in Truth.lean and Axioms.lean. The dependency tracing is exhaustive (verified by grep). The main uncertainty is in Finding 3 (completeness of the BX system) -- while I am confident the system is incomplete for the intended semantics, a definitive proof of incompleteness would require constructing a countermodel (a formula valid in all strict linear temporal frames but not provable in the 35-axiom system).
