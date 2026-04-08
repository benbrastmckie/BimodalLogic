# Teammate C: Critical Risk Analysis and Path Comparison

- **Task**: 83 - Close Restricted Coherence Sorries
- **Role**: Critical Analyst -- risk assessment, path comparison, hidden risks
- **Date**: 2026-04-07
- **Session**: sess_1775625087_9b0bc5
- **Sources**: Reports 6, 17, 22, 28, 37, 38; FMCSDef.lean, BFMCS.lean, Frame.lean, TruthLemma.lean, Completeness.lean, CanonicalConstruction.lean, SuccChainFMCS.lean; Boneyard analysis

---

## Key Findings

### 1. FMCS Coherence Audit: What Matches and What Is Missing

**FMCSDef.lean** defines FMCS with exactly two coherence conditions:
- `forward_G`: G(phi) in mcs(t), t <= t' implies phi in mcs(t')
- `backward_H`: H(phi) in mcs(t), t' <= t implies phi in mcs(t')

**What this covers**: Burgess's g_content propagation (G-formulas travel forward, H-formulas travel backward). This is the base temporal persistence mechanism.

**What is MISSING from FMCS**:
- **No Until/Since resolution**: There is no field requiring F(psi) in mcs(t) to eventually yield psi in some mcs(s) for s > t. The TemporalCoherence module adds this as a separate `TemporallyCoherent` predicate, but it is NOT part of FMCS itself.
- **No x_content linkage**: FMCS does not require chain(n+1) = x_content(chain(n)). The deterministic chain (in Boneyard) had this, which enabled sorry-free Until persistence. FMCS families built via Lindenbaum extension do NOT have x_content linkage.
- **No eventuality scheduling**: There is no mechanism in the FMCS structure to ensure dovetailed resolution of multiple Until/Since obligations.

**Assessment**: FMCS captures the EASY half of Burgess's chain construction (G/H propagation). The HARD half (Until/Since resolution via enriched seeds + dovetailing) is completely absent from the type definition. Any "Path A" approach must either (a) add new fields to FMCS for Until/Since coherence, or (b) prove Until/Since coherence as external predicates on existing FMCS families. Option (b) is what TemporalCoherence.lean attempts, but filling those proofs is exactly the problem we have been stuck on for 38 rounds.

### 2. Why Prior Enriched-Seed Attempts Failed (Reports 6, 17, 22)

**Report 6 (Until/Since Enrichment)**: Proposed adding Burgess-Xu axioms (BX1-BX10) and enriching seeds with Until formulas. The report correctly identified the key mechanisms (BX5 self-accumulation, BX9 guard extraction, BX10 witness existence). However:
- **No implementation was attempted.** The report was theoretical analysis only.
- The report used REFLEXIVE semantics for Until (s >= t), which differs from the codebase's half-open convention. This mismatch was not identified until report 37.

**Report 17 (Chain Unification)**: Attempted to unify the restricted chain (DRM-based, with forward_F) with the deterministic chain (x_content-based, with Until persistence). Found:
- **Approach A (transfer forward_F between chains)**: BLOCKED -- different chains produce different MCS sequences.
- **Approach B (prove forward_F for deterministic chain)**: IMPOSSIBLE in general -- F-deferral fixed points exist.
- **Approach C (different chains for different properties)**: IMPOSSIBLE -- parametric truth lemma requires both h_tc and h_uc on the SAME BFMCS.
- **Approach D (seed = x_content)**: COLLAPSES -- x_content is already maximal, can't enrich.

**Report 22 (Global Canonical Model)**: Proposed closing deterministic_forward_F via finite deferral cycle contradiction. The approach had substantial infrastructure (pigeonhole, Until persistence for n steps). But the final step -- the cycle contradiction -- required either backward_G (which requires forward_F -- circular) or a restricted truth lemma for a periodic model (never formalized).

**Root cause of all failures**: Every attempt within the Bundle/BFMCS framework hits the same obstruction: **the Lindenbaum extension detour breaks x_content linkage**. When chain(n+1) is constructed via Lindenbaum extension of g_content(chain(n)) UNION {target}, the result is an arbitrary MCS that is NOT x_content(chain(n)). Without x_content linkage, Until/Since formulas cannot propagate through the chain via the `until_unfold` axiom.

The deterministic chain (chain(n+1) = x_content(chain(n))) has x_content linkage but cannot resolve F-obligations because it has no control over which MCS it arrives at -- it is fully determined by the starting MCS.

**This is a genuine dilemma, not a proof gap.** The two properties (F-resolution and Until persistence) appear to require contradictory construction methods within the BFMCS framework.

### 3. Risk Analysis: Path A (Bundle Fix with Enriched Chains)

**What Path A proposes**: Improve the FMCS/BFMCS infrastructure to support Burgess-style enriched chains. Build chains where each step includes g_content PLUS active Until formulas in the Lindenbaum seed.

**Prior failure count**: 6 Boneyard files with 56 combined sorries (TargetedChain, ResolvingChain, MCSWitnessChain, DeterministicFMCS, DeterministicChain, FiniteDeferral).

**Risk 3.1: Enriching seeds breaks BFMCS modal coherence?**

No -- enriching seeds does not affect modal coherence. BFMCS modal coherence (modal_forward, modal_backward) operates WITHIN a time slice across families. The seed enrichment changes how families are constructed ALONG time but does not affect the cross-family Box/Diamond properties at a fixed time point. The existing Omega construction (CanonicalOmega) handles modal coherence independently.

**Risk 3.2: Can enriched seeds be proved consistent?**

YES -- this is the one part that clearly works. Given F(psi) in chain(n), the seed {psi} UNION g_content(chain(n)) is consistent because:
- If inconsistent: g_content(chain(n)) |- neg(psi)
- By g_content_closed_derivation: G(neg(psi)) in chain(n)
- But F(psi) = neg(G(neg(psi))) in chain(n), contradicting consistency of chain(n)

This argument is correct and well-established. Report 38 (Teammate A) confirmed this.

**Risk 3.3: The guard verification problem**

This is where Path A gets hard. For `phi U psi in w`, the truth lemma requires `phi in u` for all u BETWEEN w and the witness v. In the BXCanonical framework, "between" means all BXPoints u with bx_le w u and bx_lt u v. In a chain construction, "between" means all chain members w_i with 0 <= i < witness_index.

For chain members: BX5 (self-accumulation) + BX9 (guard extraction) give phi at each intermediate step. This is correct and confirmed by report 37 (Section 1.4).

For NON-chain BXPoints: Path A (via Bundle) avoids this problem entirely because the truth lemma quantifies over chain members (integers) not abstract BXPoints. **This is a genuine advantage of Path A over Path B.**

**Risk 3.4: The backward direction**

Report 38 identified two approaches:
- (a) Step-by-step backward induction using BX5+BX6
- (b) Contradiction via negation unfolding

Approach (b) was recommended: Assume neg(phi U psi) in w. Since phi in w (from guard at w), by negation unfolding neg(phi U psi) implies neg(psi) AND (neg(phi) OR G(neg(phi U psi))). Since phi in w, neg(phi) not in w, so G(neg(phi U psi)) in w. This propagates neg(phi U psi) to all future points via g_content. At the witness v: neg(phi U psi) in v. But psi in v implies phi U psi in v by BX8. Contradiction.

**CRITICAL QUESTION**: Is `neg(phi U psi) -> neg(psi) AND (neg(phi) OR G(neg(phi U psi)))` derivable from BX1-BX10?

This is equivalent to: `(phi U psi) <- psi OR (phi AND F(phi U psi))`. The left-to-right direction is BX9 (sort of -- BX9 gives phi OR psi, and the additional F(phi U psi) comes from BX4+BX10). The right-to-left requires `phi AND F(phi U psi) -> phi U psi`, which is essentially BX6 (absorption): `phi AND F(phi U psi) -> phi U psi`. **BX6 IS in our axiom set.** So the backward direction IS feasible.

**Risk 3.5: Integration with existing Bundle infrastructure**

Path A requires:
1. New chain construction module (replacing SuccChainFMCS or parallel to it)
2. Proving the chain satisfies FMCS coherence (forward_G, backward_H) -- straightforward
3. Proving temporal coherence (forward_F, backward_P) -- the chain resolves F/P by construction
4. Proving Until/Since coherence -- the main new work
5. Wiring through BFMCS -> CanonicalConstruction -> truth lemma -> completeness

Steps 1-3 are straightforward. Step 4 is the core challenge. Step 5 involves threading through the existing (complex) Bundle wiring, which has its own sorry landscape.

**Estimated LOC for Path A**: 800-1200 new lines, modifying ~300 existing lines across CanonicalConstruction, TemporalCoherence, SuccChainFMCS.

### 4. Risk Analysis: Path B (Port Chain into BXCanonical)

**What Path B proposes**: Build the enriched chain construction directly in BXCanonical by modifying Frame.lean to use chains instead of abstract BXPoints for the Until/Since truth lemma.

**Risk 4.1: The universal quantifier over BXPoints**

The 4 sorry stubs in Frame.lean have this signature:
```lean
∀ u : BXPoint, bx_le w u → bx_le u v ∧ ¬bx_le v u → φ ∈ u.formulas
```

This requires phi at ALL BXPoints between w and v, not just chain members. A chain construction gives phi only at chain members (w_0, w_1, ..., w_n). An arbitrary BXPoint between w and v (in the g_content preorder) is not necessarily on the chain.

**Can this be resolved?** Only if the BXCanonical ordering is LINEAR on the interval [w, v]. Report 37 proved this is NOT the case: the g_content preorder is not linear in general. There can be BXPoints u, u' with bx_le w u, bx_le w u', but neither bx_le u u' nor bx_le u' u.

**Impact**: The 4 sorry stubs in Frame.lean are UNFILLABLE as currently stated. The BXCanonical truth lemma for Until quantifies over a space that is too large. The chain construction provides witnesses in a LINEAR sub-order, but the truth lemma asks for witnesses in the full PREORDER.

**This is the fundamental blocker for Path B.** To make it work, you would need to:
- Change the BXCanonical truth lemma to quantify over chain members only (which transforms it into the Bundle approach)
- OR prove linearity of bx_le on intervals (which is false)
- OR add a linearity axiom (which would change the logic)

**Risk 4.2: Completeness.lean in BXCanonical**

BXCanonical/Completeness.lean has a single sorry for the entire TaskModel construction. Even if the 4 Frame sorries were closed, the Completeness sorry requires building a TaskModel from the BXCanonical frame -- mapping BXPoints to WorldHistories, constructing Omega, etc. This is essentially the Bundle construction repeated in a different framework.

**Estimated LOC for Path B**: 600-1000 new lines (smaller than Path A because BXCanonical has less wiring), BUT with the fundamental BXPoint universal quantifier problem unsolved.

### 5. Path Comparison Matrix

| Criterion | Path A (Bundle Fix) | Path B (BXCanonical Port) |
|-----------|-------------------|--------------------------|
| **Core files to modify** | CanonicalConstruction.lean, TemporalCoherence.lean, new Chain.lean | Frame.lean, Completeness.lean, new Chain.lean |
| **LOC (new)** | 800-1200 | 600-1000 |
| **LOC (existing modifications)** | ~300 | ~200 |
| **Leaf sorry count to close** | 6 (CanonicalConstruction: 4 U/S, TemporalCoherence: 2 F/P) | 5 (Frame: 4 U/S, Completeness: 1) |
| **Mathematical risk** | MEDIUM -- chain construction is standard; backward direction needs BX6 derivation | CRITICAL -- BXPoint universal quantifier is fundamentally unfillable |
| **Prior failures** | 6 Boneyard files, 56 sorries -- but all from DRM-based chains, not full MCS chains | No prior attempts (BXCanonical is newer) |
| **Infrastructure reuse** | HIGH -- BFMCS, CanonicalOmega, shifted truth lemma, parametric truth lemma | LOW -- most Bundle infrastructure is irrelevant |
| **Integration complexity** | HIGH -- must thread through BFMCS -> CanonicalConstruction wiring | MEDIUM -- simpler architecture but needs TaskModel bridge |
| **Backward direction feasibility** | FEASIBLE -- contradiction via BX6 in a linear chain | BLOCKED -- requires linearity of bx_le |
| **Dense extension path** | Separate module, shares g_content/MCS infrastructure | Same |
| **Time estimate** | 2-4 weeks | 2-3 weeks IF BXPoint problem solved; INFINITE otherwise |

### 6. Hidden Risks

**Risk 6.1: Circular dependency between forward_F and backward_G**

Report 28 identified this: proving forward_F (F(psi) in chain(t) implies psi in some chain(s), s > t) requires backward_G (neg(psi) at all future positions implies G(neg(psi)) in chain(t)), which requires forward_F for neg(neg(psi)). The formula sizes INCREASE through the dependency chain, preventing well-founded induction.

**The chain construction sidesteps this entirely** by resolving F-obligations via seed enrichment (putting the target formula directly into the Lindenbaum seed). This does not require backward_G. The consistency argument uses g_content_closed_derivation, which is sorry-free.

**Risk 6.2: CanonicalConstruction.lean wiring complexity**

CanonicalConstruction.lean is 1071 lines with 6 sorry occurrences (4 in the truth lemma Until/Since cases, 2 in the restricted truth lemma). The file threads through multiple layers: BFMCS -> CanonicalOmega -> shifted evaluation -> truth lemma. Modifying this file carries high risk of breaking existing sorry-free proofs.

**Mitigation**: Build the chain truth lemma in a NEW file (e.g., ChainTruthLemma.lean) that provides alternative proofs for the Until/Since cases. Wire the completeness theorem through the new file. Do not modify CanonicalConstruction.lean directly.

**Risk 6.3: TaskFrame/WorldHistory integration**

The chain construction produces a Z-indexed sequence of MCS. Converting this to a WorldHistory requires:
- A domain predicate (trivially `fun _ => True` for Z-indexed chains)
- A states function mapping time points to WorldStates
- Proof that the history `respects_task` (g_content propagation for non-consecutive indices)

The `respects_task` obligation for non-consecutive indices (|t - s| > 1) follows from transitivity of g_content via temp_4 (G(phi) -> G(G(phi))). This is standard and should not be problematic.

**Risk 6.4: BFMCS bundle construction with chains**

Each chain produces ONE history. For Box/Diamond, we need MULTIPLE histories forming a BFMCS. The standard construction: for each MCS M at time 0, build a chain starting from M. The set of all such chains forms the bundle. Modal coherence follows from: if Box(phi) in M, then phi in every modally-equivalent M', so phi is in the starting MCS of every chain in the box-class.

**Potential issue**: Different chains through M may resolve Until formulas differently (different dovetailing schedules). This does NOT affect correctness -- the truth lemma holds for EACH chain independently. The modal coherence at each time slice is determined by the MCS values, not the chain construction path.

**Risk 6.5: SuccChainFMCS.lean bloat**

SuccChainFMCS.lean is 6138 lines with 22 sorries. Much of this is legacy infrastructure (F/P nesting bounds that are mathematically false for arbitrary MCS, as documented in the file header). The new chain construction should NOT build on SuccChainFMCS. It should be a fresh module that replaces the chain construction while reusing lower-level infrastructure (SuccExistence, TemporalContent, WitnessSeed).

---

## Recommended Approach

**Path A (Bundle Fix) is the only viable path.** Path B is blocked by the BXPoint universal quantifier problem (Risk 4.1), which is a fundamental architectural mismatch, not a proof gap.

Within Path A, the recommended implementation strategy:

1. **New module**: Create `Metalogic/Bundle/EnrichedChain.lean` (or `ChainCanonical/Chain.lean` as report 38 suggested) containing:
   - Enriched-Succ chain construction (g_content + active Until formulas in seed)
   - Seed consistency proof (using g_content_closed_derivation)
   - Dovetailing scheduler over finite subformula closure
   - Proof that the chain satisfies FMCS coherence

2. **New truth lemma**: Create a new truth lemma file that handles Until/Since cases using the chain, calling the existing truth lemma infrastructure for all other cases.

3. **Wire completeness**: Route the completeness theorem through the new chain-based truth lemma. Keep existing CanonicalConstruction as-is (its non-Until/Since cases are fine).

4. **Verify backward direction first**: Before any coding, formally derive `neg(phi U psi) -> neg(psi) AND (neg(phi) OR G(neg(phi U psi)))` from BX1-BX10. If this derivation fails, the backward direction needs a different approach.

**What NOT to do**:
- Do NOT attempt to fill BXCanonical Frame.lean sorries (they are unfillable)
- Do NOT build DRM-based chains (the consistent lesson from 6 Boneyard failures)
- Do NOT modify FMCS/BFMCS type definitions (risk of cascading breakage)
- Do NOT attempt to prove forward_F for the deterministic chain via finite deferral (circular dependency, as shown in reports 22, 28)

---

## Confidence Level

- **Path B is blocked**: HIGH confidence (95%). The universal quantifier over BXPoints is a proven structural impossibility (report 37 + the 3-point countermodel for BX axiom 4).
- **Path A is feasible**: MEDIUM-HIGH confidence (75%). The mathematical argument is sound (Burgess 1984 proves completeness via exactly this chain construction). The implementation risk lies in the backward direction derivation and the Bundle wiring complexity. Prior Boneyard failures were all from DRM-based chains -- no full-MCS enriched chain has been attempted yet.
- **LOC estimate**: MEDIUM confidence (60%). Could range from 800 to 1500 depending on how much existing infrastructure can be reused vs. how much wiring needs to change.
- **Backward direction**: MEDIUM confidence (70%). The BX6-based contradiction argument appears sound on paper, but has not been formally verified in Lean. Report 38 flagged this as the subtlest part.

---

## Evidence Summary

| Claim | Evidence |
|-------|----------|
| BXCanonical sorries are unfillable | Report 37: BX axiom 4 semantically invalid; Frame.lean guard quantifies over all BXPoints |
| DRM-based chains always fail | Boneyard: 6 files, 56 sorries, all from DRM-to-MCS lifting |
| Enriched seed consistency works | g_content_closed_derivation (sorry-free in Frame.lean:79-94); F(psi) + G(neg(psi)) contradiction |
| Guard verification works for chains | BX5 self-accumulation + BX9 guard extraction (report 37 Section 1.4) |
| Backward direction via BX6 | BX6 (absorption) in Axioms.lean; negation unfolding propagates via g_content |
| Forward_F circularity in deterministic chain | Report 28 Section 2.3: backward_G requires forward_F; formula size increases |
| No prior full-MCS enriched chain attempt | Boneyard audit: all 6 chain files used DRM or x_content, none used enriched Lindenbaum |
