# Research Report: Task #916 (Root Cause Analysis and Candidate Review)

**Task**: Close forward_F and backward_P sorries in DovetailingChain.lean
**Date**: 2026-02-21
**Focus**: Set up the problem precisely, identify root cause, review candidate solutions
**Session**: sess_1771703435_e72148

---

## 1. The Precise Problem Statement

### 1.1 What We Need to Prove

Two lemmas in `DovetailingChain.lean` (lines 1749-1761) remain as sorry:

```lean
-- forward_F (line 1750):
forall t : Int, forall phi : Formula,
  phi.some_future in (buildDovetailingChainFamily Gamma h_cons).mcs t ->
    exists s, t < s /\ phi in (buildDovetailingChainFamily Gamma h_cons).mcs s

-- backward_P (line 1757):
forall t : Int, forall phi : Formula,
  phi.some_past in (buildDovetailingChainFamily Gamma h_cons).mcs t ->
    exists s < t, phi in (buildDovetailingChainFamily Gamma h_cons).mcs s
```

These are **existential** statements: given an F-formula (or P-formula) at a time t, find a STRICTLY future (or past) time where the sub-formula holds. Backward_P is symmetric to forward_F, so this report focuses on forward_F.

### 1.2 What Has Already Been Proven

The codebase has extensive infrastructure for the chain construction (1788 lines). The following are fully proven (sorry-free):

| Property | Status | Lines |
|----------|--------|-------|
| forward_G (non-negative indices) | PROVEN | 920-929 |
| forward_G (negative indices, cross-sign) | PROVEN | 958-1000 |
| backward_H (non-positive indices) | PROVEN | 931-943 |
| backward_H (non-negative indices, cross-sign) | PROVEN | 1002-1037 |
| Witness seed consistency (`forward_temporal_witness_seed_consistent`) | PROVEN | 398-459 |
| Past witness seed consistency | PROVEN | 303-355 |
| GContent/HContent duality lemmas | PROVEN | 692-749 |
| Witness placement (if F(psi) alive at encoding step, psi enters chain) | PROVEN | 1195-1227 |
| Coverage (encoding surjectivity) | PROVEN | 1367-1380 |
| F-dichotomy (at each step, either F(psi) or G(neg psi)) | PROVEN | 1406-1425 |
| G-persistence (G-formulas propagate forward forever) | PROVEN | 1427-1434 |
| F-persistence conditioned on G(neg) absence | PROVEN | 1450-1488 |
| Coverage with persistence (if F(psi) at step n and encode(psi) <= n) | PROVEN | 1528-1553 |
| Six derivation-theoretic structural lemmas (Phase 1) | PROVEN | 1556-1686 |

### 1.3 What Remains

The existing machinery handles the case where `encodeFormula(psi) >= n` (the encoding step is in the future or at the current step). The gap is when `encodeFormula(psi) < n` -- the encoding step is already in the PAST.

More fundamentally: **even if F(psi) persists indefinitely through the chain, the one-shot witness mechanism only places psi at step `encodeFormula(psi) + 1`, which is in the past relative to step n.**

---

## 2. Root Cause: Why ALL Approaches Fail

### 2.1 The Structural Mismatch

The chain construction builds a single linear sequence of MCSs, indexed by Int. For G-formulas, this works perfectly: G(phi) at time t implies G(G(phi)) at time t (4-axiom), so G(phi) propagates to GContent and enters all future MCSs.

For F-formulas, the situation is fundamentally different:

| Property | G (universal) | F (existential) |
|----------|---------------|-----------------|
| Self-propagation axiom | G(phi) -> G(G(phi)) (derivable) | F(phi) -> G(F(phi)) (NOT derivable) |
| Seed mechanism | GContent directly propagates | F-formulas invisible to GContent |
| One-step guarantee | G(phi) at t => G(phi) at t+1 | F(phi) at t => ??? at t+1 |

**The root cause**: The Lindenbaum extension at each chain step makes a CHOICE (via Zorn's lemma) about which formulas to include. For each formula phi, exactly one of phi or neg(phi) enters the MCS. The choice is opaque and cannot be controlled.

When the seed is `GContent(chain(n))` and Lindenbaum extends it to an MCS, the resulting MCS:
- MUST include all of GContent(chain(n)) (seed preservation)
- MIGHT include F(psi) = neg(G(neg psi)), OR might include G(neg psi)
- The choice is arbitrary, consistent with the seed

Since F(psi) is NOT in the seed, Lindenbaum is free to kill it.

### 2.2 The Two Sub-Problems

The forward_F proof requires solving TWO problems, not just one:

**Sub-problem A (Persistence)**: Given F(psi) at step n, ensure F(psi) survives to step k = encodeFormula(psi). This requires F(psi) to persist through steps n, n+1, ..., k-1.

**Sub-problem B (Past-encoding)**: If encodeFormula(psi) < n, the witness step is in the past. Even with perfect persistence, psi enters at step encodeFormula(psi) + 1 < n, which is NOT a strictly future time relative to n.

Prior research focused almost exclusively on sub-problem A (persistence). Sub-problem B has not been previously identified as a separate obstacle.

### 2.3 Why Sub-Problem B is Fatal for One-Shot Enumeration

The one-shot enumeration processes each formula exactly once. If F(psi) is at chain(n) and encodeFormula(psi) < n, then:

1. The witness step already fired at step encodeFormula(psi). If F(psi) was alive then, psi entered chain(encodeFormula(psi) + 1).
2. But encodeFormula(psi) + 1 <= n, so psi is at a PAST time relative to n.
3. psi doesn't propagate forward (it's not a G-formula), so psi might not be at any time > n.
4. The F-obligation at time n requires psi at some s > n. No such s is guaranteed.

**This means the one-shot enumeration is structurally insufficient for forward_F**, independent of the persistence problem.

### 2.4 Why Each Specific Approach Fails

| Approach | Blocker | Report |
|----------|---------|--------|
| Omega^2 directed limit | Generalized seed consistency is mathematically FALSE | v004 |
| FPreservingSeed ({psi} + GContent + FContent) | Seed is inconsistent in general (explicit counterexample) | v005 |
| Derivation surgery | Counterexample refutes the conjecture it tries to prove | v005/v007 |
| Semantic model | Fatally circular (needs completeness to prove completeness) | v007 |
| G-lifting for F-formulas | Structurally impossible (F -> GF not derivable) | v007 |
| One-shot enumeration (current) | Sub-problem B: past-encoding gap (this report) | v008 |

The counterexample that blocks the FPreservingSeed approach (v005 Phase 2):
- Integer time model: q false at time 0, q true at time 1, r true only at time 0
- At time 0: F(q) and F(r) hold, neg(q) holds
- G(F(r) -> neg(q)) holds at time 0 (F(r) fails at all future times)
- Seed {q} union GContent(M) union {F(r)} derives bot:
  - F(r) from FContent, (F(r) -> neg(q)) from GContent, neg(q) by modus ponens, contradiction with q

---

## 3. Candidate Solutions

### 3.1 Approach: Fair Enumeration (Repeated Witnessing)

**Idea**: Replace the one-shot enumeration (using `decodeFormula n`) with a fair enumeration where every formula is processed infinitely often. Use `Nat.unpair n` to get `(round, formula_index)`, so formula psi is processed at steps `Nat.pair(0, encodeFormula psi), Nat.pair(1, encodeFormula psi), ...`

**What it solves**: Sub-problem B. For any F(psi) at step n, there exists a step m > n where psi is processed.

**What it does NOT solve**: Sub-problem A (persistence). F(psi) still needs to survive from step n to step m. The Lindenbaum extensions at intermediate steps are free to kill F(psi).

**Assessment**: Necessary but not sufficient. Solves one sub-problem but not both.

### 3.2 Approach: FContent-Preserving Non-Witness Steps

**Idea**: At non-witness steps, use seed `GContent(chain(n)) union FContent(chain(n))` (consistent since both are subsets of MCS chain(n)). At witness steps, use the proven `{psi} union GContent(chain(n))` seed.

**What it solves**: F-persistence through non-witness steps (FContent in seed prevents Lindenbaum from killing F-formulas).

**What it does NOT solve**: F-persistence through witness steps. At witness steps for OTHER formulas chi, the seed is `{chi} union GContent(chain(n))` without FContent. Lindenbaum can kill F(psi) at these steps.

**Assessment**: Partial solution. Combined with fair enumeration (3.1), this reduces the persistence gap to: F(psi) must survive through at most one witness step between consecutive processing rounds. But the counterexample shows this is not guaranteed.

### 3.3 Approach: Controlled Lindenbaum Extension

**Idea**: Instead of standard Lindenbaum (which makes arbitrary choices), use a modified extension that prioritizes F-formulas from the previous MCS. After seeding, first add all F-formulas from the previous MCS that are individually consistent with the current seed. Then complete to an MCS via standard Lindenbaum.

**What it solves**: Maximizes F-formula survival. Every F-formula that CAN survive DOES survive.

**What it does NOT solve**: F-formulas that are genuinely inconsistent with the current seed still die. The counterexample shows this can happen.

**Feasibility**: Requires proving a new Lindenbaum variant. The standard `set_lindenbaum` in the codebase uses Zorn's lemma and doesn't control enumeration order. A modified version would need to:
1. Define a priority-augmented Lindenbaum
2. Prove it produces an MCS
3. Prove seed preservation
4. Prove F-priority preservation

**Assessment**: Technically feasible but does not resolve the fundamental issue. Controlled Lindenbaum can prevent UNNECESSARY killing of F-formulas, but NECESSARY killing (where F(alpha) genuinely conflicts with the seed) still occurs.

### 3.4 Approach: Canonical Model (Not Linear Chain)

**Idea**: Abandon the linear chain construction entirely. Use the standard canonical model approach where ALL maximal consistent sets form the time domain, with the canonical relation `u R v iff GContent(u) subset v`.

**How it solves forward_F**: If F(psi) in MCS u, then `{psi} union GContent(u)` is consistent (proven as `forward_temporal_witness_seed_consistent`). By Lindenbaum, there exists an MCS v with `{psi} union GContent(u) subset v`. Then u R v and psi in v. So there exists a future time where psi holds.

**What changes**: The entire completeness proof architecture. Currently:
- The chain is indexed by Int (linear time)
- The BFMCS structure requires a function `Int -> Set Formula`
- The TruthLemma and all downstream proofs assume Int-indexed linear time

With the canonical model approach:
- Time points are MCSs (not integers)
- The accessibility relation is not necessarily linear
- Need to verify the frame conditions match TM's axioms

**Feasibility**: This is the approach that ACTUALLY WORKS in the mathematical literature. The reason the codebase uses a linear chain is presumably for simplicity and to match the intended semantics (linear time). Converting would require:
1. New time domain type (set of MCSs instead of Int)
2. New accessibility relation definition
3. Proving the canonical frame satisfies TM's axioms (S5 modal + linear temporal)
4. Adapting the TruthLemma
5. Adapting the completeness theorem

**Assessment**: Mathematically correct but requires major refactoring. Estimated effort: 40-80 hours. The canonical model approach handles F/P naturally because the witness MCS is constructed on-demand (one per F-obligation), not fitted into a pre-existing linear chain.

### 3.5 Approach: Omega^2 Iteration with Selective Seed

**Idea**: Build an omega^2 chain. The outer index i represents "rounds" and the inner index j represents chain positions within round i. At each round, rebuild the chain from scratch, using the PREVIOUS round's chain to guide witness placement.

Round 0: Build chain_0 using standard GContent seeds.
Round i+1: Build chain_{i+1} where at step j, if F(psi) was alive at chain_i(j), include psi in the seed for chain_{i+1}(j+1).

The limit chain (if it converges) should satisfy forward_F.

**What it solves**: The past-encoding gap (sub-problem B), because each round can witness formulas that the previous round missed.

**Blocker**: The generalized seed consistency lemma (needed for round i+1) was proven FALSE (research v004). The seed at round i+1 includes formulas from chain_i that may conflict with the current seed.

**Assessment**: Blocked by the same mathematical falsity as the original omega^2 approach.

### 3.6 Approach: Accept Sorry Debt

**Rationale**: The forward_F and backward_P sorries are the last remaining proof obligations for the completeness theorem. All other components (forward_G, backward_H, cross-sign propagation, truth lemma, soundness) are fully proven. The sorry debt is:
- Honest (explicitly marked, not hidden by axioms)
- Localized (2 specific lemmas)
- Mathematically sound (the properties ARE true -- they hold in the intended semantics)
- Structurally isolated (no other proof depends on the internal structure of these lemmas)

The sorries replaced a previous AXIOM (`temporal_coherent_family_exists`), which is a strictly worse form of proof debt (axioms are in the trusted kernel; sorries are not).

**Assessment**: The pragmatic option. The proof gap is a genuine mathematical difficulty in formalizing temporal logic completeness via linear chain constructions. The canonical model approach (3.4) is the correct mathematical solution but requires significant refactoring.

---

## 4. Why the Linear Chain Construction Is Fundamentally Limited

### 4.1 The Canonical Model vs Linear Chain

The standard completeness proof for temporal logics uses the **canonical model**: all MCSs as time points, with accessibility relation `u R v iff GContent(u) subset v`. In this setting:

- **forward_G**: immediate from the definition of R and GContent
- **forward_F**: by Lindenbaum applied to `{psi} union GContent(u)` (proven consistent)
- **backward_H**: by the dual construction using HContent
- **backward_P**: by Lindenbaum applied to `{psi} union HContent(u)` (proven consistent)

The linear chain construction SPECIALIZES this by choosing a specific sequence of MCSs u_0, u_1, u_2, ... where u_n R u_{n+1}. This specialization loses the freedom to choose different witness MCSs for different F-obligations.

### 4.2 The Freedom Lost by Linearization

In the canonical model, when F(psi) is in u, the witness v (with psi in v) is constructed BY LINDENBAUM specifically for this F-obligation. Different F-obligations in u can have DIFFERENT witnesses:

```
F(psi_1) in u  -->  v_1 (where psi_1 in v_1, u R v_1)
F(psi_2) in u  -->  v_2 (where psi_2 in v_2, u R v_2)
```

v_1 and v_2 are generally DIFFERENT MCSs. In the linear chain, we need ALL F-obligations from u to be satisfied in the SAME future subsequence. This is much more constrained.

### 4.3 Why the Constraints Interact

The counterexample (v005 Phase 2) demonstrates that F-obligations can INTERACT: witnessing psi_1 can kill F(psi_2). In the canonical model, this is fine -- psi_1's witness v_1 is separate from psi_2's witness v_2. In the linear chain, they share the same future, so killing F(psi_2) at v_1's position means psi_2 might never appear.

### 4.4 The Linear Chain CAN Work (In Principle)

Despite the above, the linear chain construction IS valid for the intended semantics (linear time over integers). The mathematical proof goes roughly:

1. For F(psi) in chain(n), consider the set `{psi} union GContent(chain(n))`.
2. This is consistent (proven).
3. By Lindenbaum, there exists an MCS M extending this set.
4. M is NOT necessarily chain(n+1) or any chain position.
5. BUT: we can choose chain(n+1) to be such an M (for ONE formula psi).
6. The problem is handling MULTIPLE F-obligations simultaneously.

The solution in the literature: process F-obligations one at a time, in a fair order. At each step, witness ONE obligation. The key is showing that unwitnessed obligations are not permanently destroyed.

The difficulty in formalization: proving that Lindenbaum's arbitrary choices don't permanently destroy obligations. This requires either:
- Controlling Lindenbaum's choices (difficult in ZFC/Lean)
- Showing that destruction is always recoverable (the derivation surgery argument, which fails due to the counterexample)
- Using the full canonical model (which avoids the issue entirely)

---

## 5. Recommendations

### 5.1 Primary Recommendation: Accept Sorry Debt (Short Term)

Given that:
- 7 research rounds and 1 implementation attempt have failed to close these sorries
- The FPreservingSeed conjecture is provably FALSE
- The root cause is a fundamental mismatch between linear chains and existential obligations
- The sorry debt is honest, localized, and replaces a previous axiom

**Recommendation**: Accept the sorry debt with documentation. The 2 sorries are mathematically sound and structurally isolated.

### 5.2 Secondary Recommendation: Canonical Model Refactoring (Long Term)

For a sorry-free completeness proof, refactor to use the canonical model approach:

1. Define a canonical frame where worlds are MCSs, not integers
2. Define the temporal accessibility relation as `u R v iff GContent(u) subset v`
3. Prove the canonical frame satisfies TM's axioms
4. Adapt the truth lemma to the canonical model
5. Forward_F follows immediately from `forward_temporal_witness_seed_consistent` + Lindenbaum

**Estimated effort**: 40-80 hours (new task). This is the mathematically correct approach and would eliminate all sorry debt from the completeness proof.

**Risk**: The canonical model uses a non-linear time structure. The existing completeness proof infrastructure assumes Int-indexed linear time. Adapting may require significant architectural changes to TruthLemma.lean, BMCSTruth.lean, and Representation.lean.

### 5.3 Tertiary Recommendation: Controlled Lindenbaum (Exploratory)

If a future attempt is made to close the sorries within the current linear chain architecture:

1. Implement a priority-augmented Lindenbaum that preserves specified formulas
2. Use fair enumeration (Nat.unpair) for repeated witness attempts
3. At each step, the seed is `GContent(chain(n)) union Preserved_F(chain(n))` where `Preserved_F` is the maximal consistent subset of FContent that is consistent with the witness seed
4. Prove that every F-obligation is eventually witnessed (by fair scheduling) or permanently killed (by G(neg psi) entering the chain, which means the obligation is actually unsatisfiable from that point forward)

**Key open question**: If F(psi) is killed at step m (G(neg psi) enters), was F(psi) already satisfiable at some earlier step? If psi was placed at step encodeFormula(psi) + 1 < m, then psi at time encodeFormula(psi) + 1 satisfies F(psi) at time n < encodeFormula(psi) + 1 -- but only if n < encodeFormula(psi) + 1. This is the past-encoding sub-problem.

**Assessment**: This approach is speculative and may not work. The controlled Lindenbaum infrastructure would take 15-25 hours to implement and might still fail at the key step (showing killed F-obligations were already satisfied).

---

## 6. Summary of Findings

### 6.1 Root Cause

The forward_F/backward_P sorry gap has TWO independent root causes:

1. **F-formula persistence** (sub-problem A): F-formulas are not preserved by the GContent seed mechanism, and adding FContent to the seed can create inconsistency (proven by counterexample).

2. **Past-encoding** (sub-problem B, newly identified): Even with perfect persistence, the one-shot enumeration places witnesses at step `encodeFormula(psi) + 1`, which can be in the PAST relative to where F(psi) currently is. There is no mechanism to propagate psi to future chain positions.

Both sub-problems stem from a fundamental mismatch: the linear chain construction handles UNIVERSAL temporal properties (G, H) naturally via GContent/HContent propagation, but EXISTENTIAL properties (F, P) require per-obligation witnesses that the linear chain cannot accommodate without either controlling Lindenbaum or abandoning the linear architecture.

### 6.2 Mathematical Correctness

The properties forward_F and backward_P ARE mathematically true for the TM logic. They are validated by:
- The sorry-free soundness proof (Soundness.lean)
- The standard canonical model construction (which proves completeness without a linear chain)
- The intended semantics (reflexive G/H/F/P over integer time)

The difficulty is purely one of FORMALIZATION: fitting the proof into the existing linear chain architecture.

### 6.3 Verdict

| Approach | Feasibility | Effort | Solves Both Sub-problems |
|----------|-------------|--------|--------------------------|
| Accept sorry debt | Immediate | 0 hours | N/A (workaround) |
| Canonical model refactoring | High | 40-80 hours | Yes |
| Controlled Lindenbaum + fair enum | Uncertain | 15-25 hours | Maybe |
| FPreservingSeed | Impossible | N/A | Refuted |
| Derivation surgery | Impossible | N/A | Refuted |
| Omega^2 construction | Impossible | N/A | Refuted |

---

## 7. References

### Project Files
- `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` -- Chain construction (2 sorries)
- `Theories/Bimodal/Metalogic/Bundle/TemporalContent.lean` -- GContent/HContent definitions
- `Theories/Bimodal/Metalogic/Bundle/BFMCS.lean` -- BFMCS structure
- `Theories/Bimodal/ProofSystem/Axioms.lean` -- TM axiom system
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` -- Temporal coherence
- `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean` -- Truth lemma

### Prior Research
- `specs/916_.../reports/research-001.md` through `research-007.md` -- Previous research rounds
- `specs/916_.../plans/implementation-005.md` -- Latest plan with counterexample

### External References
- [Temporal Logic (Stanford Encyclopedia of Philosophy)](https://plato.stanford.edu/entries/logic-temporal/)
- [Chapter 10: TEMPORAL LOGIC by Yde Venema](https://staff.science.uva.nl/y.venema/papers/TempLog.pdf)
- [Canonical models for normal logics (Imperial College)](https://www.doc.ic.ac.uk/~mjs/teaching/ModalTemporal499/CanonicalNormal_499_v0809_2up.pdf)
- Goldblatt, R. (1992). *Logics of Time and Computation*. CSLI Publications.
- Burgess, J.P. (1979). "Logic and time". *Journal of Symbolic Logic*.
