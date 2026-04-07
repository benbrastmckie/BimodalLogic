# Teammate D Findings: Critical Analysis and Implementation Feasibility

**Task**: 83 - Close Restricted Coherence Sorries
**Date**: 2026-04-07
**Role**: Devil's Advocate and Implementation Feasibility
**Artifact**: 33

---

## Key Findings

### 1. Pattern of Failure Analysis

After reviewing reports 24-32, a clear pattern emerges in WHY approaches fail. Every attempt since round 1 has collided with the same structural wall, but each time it has been dressed in different clothing.

**The recurring pattern** (observed in at least 8 distinct forms):

| Round(s) | Approach | How It Hit the Wall |
|----------|----------|-------------------|
| 1-23 | DovetailedChain Lindenbaum | g_content subset insufficient; x_content needed for Until |
| 24 | Quasimodel (GHR 1994) | Deterministic type graph reduces to the same chain |
| 25 | Root cause analysis | Confirmed structural: meta-to-object G gap |
| 28 | FiniteDeferral cycle | Pigeonhole gives cycle but backward_G still circular |
| 29 | F-nesting induction | neg(neg(psi)) preserves F-depth; no strictly decreasing measure |
| 29 | Decidability bypass | Correctness.lean uses Classical.em; not a real procedure |
| 30 | Tuple construction | Existential constraints solvable; universal constraints unchanged |
| 31 | Option E' axiom fix | Fixes soundness but explicitly does NOT close forward_F |

**The invariant failure signature**: Every approach that attempts to derive `G(neg(psi)) in chain(t)` from the meta-level fact "neg(psi) in chain(s) for all s > t" is blocked by the same circularity. The conversion requires `temporal_backward_G_with_fwd_F`, which takes `forward_F` as a hypothesis.

**Is the tuple-based construction (Report 30/32) genuinely different?** Partially. The tuple/constraint framing correctly separates existential (F/P witness placement) from universal (G/H propagation) concerns. The Bellman-Ford satisfiability of the constraint DAG is a real positive result. However, Report 30 Teammate C and the synthesis both explicitly state: the universal-to-existential gap is NOT resolved. The construction handles "pull" (witness placement) but the "push-to-object" conversion (meta-level "at all times" to object-level "G(phi)") remains.

**Is the Burgess-Xu system (Report 32) genuinely different?** This is the most promising departure. By removing Next/Previous and working directly with BX5 (self-accumulation) and BX6 (absorption), the completeness proof bypasses the deterministic chain entirely. The eventuality resolution mechanism is fundamentally different: instead of stepping through positions one-by-one and hoping F-witnesses appear, the BX axioms directly constrain Until-formulas to eventually resolve. This is NOT the same wall. However, the completeness proof for this system has its own difficulties (see Risk #1 below).

**Confidence**: HIGH that the pattern identification is correct. MEDIUM that BX represents a genuine departure.

---

### 2. Specific Risk Assessment

#### 2.1 Tuple-Based Construction

**Where it might break:**
- The constraint-satisfaction framing handles F/P witnesses well (DAG structure, Bellman-Ford). But G(F(psi)) creates infinitely many task instances (finitely many types but infinitely many placement instances). Report 30 Section 3.2 identifies this but does not resolve it.
- Until/Since intermediate-position constraints are underspecified. Until requires phi to hold at ALL intermediate points, not just endpoints. Formalizing this as difference constraints is possible but complex.
- The truth lemma remains the hardest part (estimated 500 lines by Report 30). It will face the same meta-to-object G gap unless the construction architecture is fundamentally different from the deterministic chain.

**Confidence**: LOW (25-35%) for closing forward_F via this approach alone.

#### 2.2 New Axiom System (Burgess-Xu)

**What if an axiom is wrong?**

Report 32 performs semantic verification for BX1-BX7 (Section 8). I note the following concerns:

1. **BX4 (Connectedness)**: The semantic verification in Section 8.4 is incomplete. The report starts working through the guard interval analysis and gets tangled in the half-open interval boundaries. The check is left partially unfinished with "Wait -- we need chi on (t, s]..." This is precisely the kind of boundary case that causes soundness sorries. The guard interval for reflexive U is [t, s) but for reflexive S is (s, t]. Getting these boundaries exactly right in Lean is notoriously difficult.

2. **BX7 (Linearity)**: This is a complex disjunctive axiom. The semantic verification is not included in the report. Linearity axioms are historically where subtle errors creep in (the current `temp_linearity` and `until_linearity` are both Discrete-class axioms with complex formulations).

3. **F_until_equiv becomes a theorem**: Report 32 claims F(phi) <-> top U phi under reflexive semantics. This is correct semantically. But DERIVING it from the BX axioms purely syntactically requires careful work. The report does not provide the derivation.

4. **Derived principles**: Report 32 Section 1.4 claims G-distribution, G-transitivity, and Temporal-A are derivable from BX. The claim "G(phi) = phi U phi" is stated but not proven. If this identification fails, G-distribution may need to be an axiom.

**Mitigation**: Implement soundness proofs for BX axioms FIRST, before rebuilding completeness. If any axiom fails soundness, catch it before investing in completeness infrastructure.

**Confidence**: MEDIUM (60-70%) that the axiom system is correct. HIGH that at least one soundness proof will be harder than expected.

#### 2.3 Reflexive Semantics

**Traps:**

1. **The X operator catastrophe**: Report 31 confirms unanimously that reflexive Until destroys `X(phi) = bot U phi` (it collapses to `phi`). This means the entire deterministic chain construction (x_content, y_content) must be abandoned or fundamentally reconceived. There are 204 references to x_content/y_content across 24 files. All of these become dead code under BX.

2. **Guard interval precision**: Under reflexive U, the guard interval is [t, s) -- half-open. Under strict U (current), it is (t, s) -- open. The half-open interval requires extreme care in Lean formalization. A single off-by-one in the interval boundary will produce a soundness sorry.

3. **Since guard asymmetry**: U uses [t, s) but S uses (s, t]. This asymmetry is correct but easy to get wrong. Every mirror pair (BX2/BX2', BX3/BX3', etc.) has this asymmetry in the guard, and mistakes in the mirror are historically common.

4. **Interaction with S5**: The modal-temporal interaction axioms (modal_future, temp_future) must be re-verified under reflexive semantics. Report 32 states they "remain valid" but does not provide proofs. Since G's semantics does not change (already reflexive), this should be fine, but U/S interactions with Box need checking.

**Confidence**: MEDIUM that reflexive semantics can be implemented without new soundness issues.

#### 2.4 Forward-F Resolution

**Is the proposed fix truly circular-free?**

Under BX, there IS no forward_F. The completeness proof uses a completely different mechanism:
- No deterministic chain
- No x_content/y_content
- Eventuality resolution via BX5 (self-accumulation) + BX6 (absorption)
- Zorn's lemma or transfinite construction for maximal chains

This genuinely avoids the forward_F circularity because it avoids the construction that creates the circularity. However, it introduces a NEW challenge: the completeness proof for BX over all linear orders is substantially harder than a discrete completeness proof. The Burgess proof uses:
1. A canonical frame with a partial order on MCSes
2. BX7 to show the order is linear on connected components
3. BX5+BX6 for eventuality resolution (the "hard new part")
4. Zorn's lemma to extend to a maximal chain

Steps 3 and 4 are novel Lean formalization challenges. Nobody has formalized Burgess completeness in Lean (or Coq/Isabelle, to my knowledge).

**Confidence**: MEDIUM (50-60%) that BX avoids the circularity. LOW (30-40%) that the new completeness proof can be completed in reasonable time.

---

### 3. Implementation Scope Reality Check

#### 3.1 Current Codebase Metrics

| Metric | Count |
|--------|-------|
| Total lines in Theories/ | 62,665 |
| Total lines in Metalogic/ | 39,315 |
| Lines in chain construction files | 7,408 |
| Files with x_content/y_content refs | 24 |
| x_content/y_content references | 204 |
| Files with untl/snce pattern matches | 8 |
| untl/snce pattern match cases | 60 |
| Active sorry statements (non-comment) | ~45 (project files, excluding deprecated) |
| Axiom constructors (current) | 35 |
| Axiom constructors (proposed BX) | 25 |
| Test files | 20 |

#### 3.2 Scope by Approach

**Option A: Minimal fix (Option E' from Report 31)**
- Replace 2 unsound axioms with 4 sound ones
- Estimated: 150-250 LOC changes
- Timeline: 1-2 days
- What it achieves: Sound axiom system, does NOT close forward_F
- What it does NOT achieve: Completeness

**Option B: Full Burgess-Xu refactor**
- Replace 35 axiom constructors with 25
- Rewrite semantics for U/S (reflexive)
- Delete chain construction (7,408 lines become dead code)
- Write new completeness proof from scratch
- Rewrite all soundness proofs for temporal axioms (~22 cases)
- Update 60 pattern match sites for any Formula constructor changes
- Estimated: 5,000-10,000 LOC (new) + deletion of 7,000+ LOC (chain machinery)
- Timeline: 2-4 months of focused work
- Risk: The new completeness proof may hit its own walls

**Option C: Keep current axioms + BX-style completeness**
- Hybrid: keep Formula type (including untl/snce), keep some axioms
- Add BX5, BX6 as new axioms
- Attempt BX-style completeness with current infrastructure
- Estimated: 2,000-4,000 LOC
- Timeline: 1-2 months
- Risk: Franken-logic with no published reference

**Option D: Drop U/S entirely**
- Remove untl/snce from Formula inductive type
- Delete 60 pattern match cases + 2,500 lines of U/S infrastructure
- Target Kt.S5 completeness (no Until, no Since)
- Estimated: -2,500 LOC (deletion) + 1,000-2,000 LOC (Kt completeness)
- Timeline: 2-4 weeks
- Risk: Reduced logic (no temporal operators beyond G/H/F/P)

#### 3.3 Minimum Viable Change

The minimum viable change is Option A (Option E' axiom fix): 150-250 LOC, 1-2 days. This achieves a sound axiom system with sorry-free soundness, which is valuable independently. It does not close completeness but removes confirmed unsoundness.

The minimum viable completeness change is Option D (drop U/S, target Kt.S5): 2-4 weeks. This gives a sorry-free completeness theorem for a smaller but still interesting logic.

**Confidence**: HIGH for scope estimates of Options A and D. MEDIUM for B and C (large refactors have historically exceeded estimates in this project).

---

### 4. What Could Go Wrong: Top 5 Risks

#### Risk 1: BX Completeness Proof Is Harder Than It Looks (Probability: 70%)

**Description**: The Burgess completeness proof has never been formalized in any proof assistant. The Zorn's lemma step, the BX5+BX6 eventuality resolution, and the linearity argument (BX7) are each substantial. The pen-and-paper proof occupies several pages in Burgess (1982) and is known to be technically involved.

**Why this could cause failure**: This project has already spent 31 research rounds failing to close completeness for a SIMPLER setup (discrete, with Next). Moving to a HARDER target (all linear orders) with a MORE COMPLEX proof technique is a significant escalation.

**Mitigation**: Before committing to full BX completeness, formalize ONLY the BX axiom soundness proofs and the key lemma "G(phi) = phi U phi" (or prove it is derivable). If these succeed, proceed. If they fail, stop and reassess.

**Early detection**: If BX axiom soundness proofs take more than 200 LOC each, the full completeness is likely infeasible.

#### Risk 2: Reflexive U/S Semantics Creates New Soundness Gaps (Probability: 50%)

**Description**: Changing U/S from strict to reflexive is a semantic change that touches every temporal operator. The half-open guard intervals [t, s) for U and (s, t] for S introduce boundary precision requirements that have historically been the source of sorries in this codebase.

**Why this could cause failure**: The current F_until_equiv sorry is exactly this type of boundary issue. Switching to reflexive semantics solves F_until_equiv but may create analogous issues elsewhere.

**Mitigation**: Write a comprehensive semantic test suite (model-checking of all BX axioms on small finite models) BEFORE attempting any proofs. Implement reflexive U/S semantics first, prove soundness of all BX axioms, and only then proceed to completeness.

**Early detection**: If `truth_at` changes produce unexpected failures in existing tests, stop immediately.

#### Risk 3: Loss of Discrete-Specific Results (Probability: 90%)

**Description**: The BX system targets all linear orders. The current codebase has substantial infrastructure for discrete frames (Next, Previous, deterministic chains). Switching to BX means this infrastructure becomes dead code. If the BX completeness proof fails, there is no fallback.

**Why this could cause failure**: Not a direct failure, but a catastrophic loss of option value. If BX completeness stalls at 60% completion, the project has no completeness theorem at all.

**Mitigation**: Do NOT delete chain infrastructure during the refactor. Keep it in a Boneyard/ directory. Implement BX as a parallel module that can be abandoned without destroying existing work.

**Early detection**: Not applicable -- this is a process risk, not a technical one.

#### Risk 4: The "Just One More Round" Trap (Probability: 60%)

**Description**: This project has a documented pattern of "the next approach will fix it." Reports 24-32 each propose a new direction with 30-75% confidence. None have worked. The BX proposal has 50-60% confidence (my assessment), which is in the same range as previous proposals that failed.

**Why this could cause failure**: If BX completeness stalls, there will be a temptation to do "one more research round" instead of accepting the partial result or choosing a simpler target. This has already happened 31 times.

**Mitigation**: Set a hard time budget (e.g., 2 weeks for BX axiom soundness + key lemma). If the key lemma is not proven within the budget, abandon BX and choose Option D (drop U/S, Kt.S5 completeness).

**Early detection**: Track progress weekly. If soundness proofs are not complete after 1 week, the timeline is slipping.

#### Risk 5: Formula Constructor Changes Cascade Unpredictably (Probability: 40%)

**Description**: If the Formula inductive type changes (adding/removing constructors, or changing U/S semantics), every pattern match on Formula must be updated. There are 60+ pattern match sites for untl/snce alone. Changes can cascade through the entire codebase.

**Why this could cause failure**: A single change to the Formula type can break compilation of the entire project, requiring many hours of mechanical fixes before any meaningful progress can be made.

**Mitigation**: If the Formula type is changed, do it in a SINGLE commit with ALL pattern matches updated. Use `lake build` to catch all breakage before proceeding. Better yet: keep the Formula type unchanged and only change semantics and axioms (Option B' instead of full B).

**Early detection**: If the first `lake build` after Formula changes produces more than 100 errors, reassess the approach.

---

### 5. Recommended Approach

**Confidence**: HIGH for the strategy; MEDIUM for specific estimates.

#### Phase 0: Immediate cleanup (1-2 days)

Apply Option E' (Report 31): Replace `F_until_equiv` and `P_since_equiv` with 4 sound axioms. This is pure engineering with no mathematical risk. Achieves sorry-free soundness regardless of what happens next.

#### Phase 1: BX feasibility probe (1-2 weeks)

Without changing any existing code, create a NEW module `Theories/Bimodal/Experimental/BurgessXu/`:
1. Define the BX axiom schemas (new inductive type, not modifying existing Axiom)
2. Implement reflexive U/S semantics (new `truth_at_reflexive` alongside existing `truth_at`)
3. Prove soundness of all 14 BX axioms under reflexive semantics
4. Prove the key derived principle: G(phi) = phi U phi (or equivalent)
5. Prove F(phi) <-> top U phi from BX axioms

**Decision gate**: If Phase 1 succeeds within 2 weeks, proceed to Phase 2. If it stalls, abandon BX and proceed to Phase 3-alt.

#### Phase 2: BX completeness (4-8 weeks)

Still in the experimental module:
1. Build canonical frame with BX ordering on MCSes
2. Prove linearity from BX7
3. Prove eventuality resolution from BX5+BX6
4. Build complete truth lemma
5. Prove completeness theorem

#### Phase 3: Integration (1-2 weeks)

If Phase 2 succeeds:
1. Replace Axiom type with BX axioms
2. Update pattern matches
3. Move chain infrastructure to Boneyard/
4. Update tests

#### Phase 3-alt: Fallback to Kt.S5 (2-4 weeks)

If Phase 1 fails:
1. Drop U/S from the logic
2. Delete untl/snce and associated infrastructure
3. Prove Kt.S5 completeness (well-established, no circularity)
4. Document the partial result

**Key principles**:
1. Never modify existing working code until the new approach is proven in isolation
2. Set hard time budgets with decision gates
3. Keep all options open until the last possible moment
4. Prefer a provable theorem about a smaller logic over a sorry-laden theorem about a larger logic

---

## Evidence/Examples

### Evidence 1: The circularity signature

The exact same dependency chain appears in every failed approach:

```
forward_F(psi)
  -> need: G(neg(psi)) in chain(t)
  -> need: temporal_backward_G_with_fwd_F
  -> need: forward_F(neg(neg(psi)))
  -> sizeof increases: sizeof(neg(neg(psi))) = sizeof(psi) + 4
  -> induction fails
```

This appears in: Report 25 (root cause), Report 28 (forward-F blocker), Report 29 (cycle), Report 30 (all teammates), Report 31 (all teammates). It is the defining feature of the problem.

### Evidence 2: Unsound axiom confirmed

`Soundness.lean:770` contains a literal `sorry` for `F_until_equiv_valid`. This is not a proof gap -- it is a genuine semantic invalidity. The comment reads: "SEMANTIC GAP: Under reflexive semantics, F(psi) includes present but Until requires strict future."

### Evidence 3: Codebase scale

- 39,315 lines in Metalogic/ alone
- 7,408 lines in chain construction files
- 204 references to x_content/y_content
- 35 axiom constructors

A "clean-break refactor" touching all of this is a multi-month project, not a multi-week one.

### Evidence 4: BX4 verification gap

Report 32 Section 8.4 contains an incomplete semantic verification for BX4 (Connectedness). The author gets tangled in half-open interval boundaries and does not finish the check. This is a microcosm of the broader risk: reflexive semantics with half-open intervals is genuinely harder to reason about than strict semantics with open intervals.

### Evidence 5: No precedent for formalized BX completeness

No proof assistant (Lean, Coq, Isabelle, Agda) has a formalized Burgess-Xu completeness proof. The project would be pioneering this formalization. Pioneering formalizations typically take 3-5x longer than adaptations of existing formalizations.

---

## Confidence Levels

| Section | Confidence |
|---------|------------|
| Pattern of failure analysis | HIGH |
| Tuple-based construction risk | HIGH |
| BX axiom system risk | MEDIUM |
| Reflexive semantics risk | MEDIUM |
| Forward-F resolution assessment | MEDIUM |
| Implementation scope (Options A, D) | HIGH |
| Implementation scope (Options B, C) | MEDIUM |
| Top 5 risks identification | HIGH |
| Recommended approach (strategy) | HIGH |
| Recommended approach (timelines) | LOW-MEDIUM |
