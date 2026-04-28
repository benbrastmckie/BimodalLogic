# Teammate D Findings: Strategic Path Analysis for A3a/Lemma 2.3 Blocker

**Task**: 107 — Burgess chronicle construction for BX representation theorem
**Role**: Horizons/Strategic — evaluate options for resolving the Lemma 2.3 blocker
**Date**: 2026-04-28

## Key Findings

### CRITICAL DISCOVERY: A3a IS Valid Under Our Actual Semantics

The claimed counterexample to A3a in `TemporalDerived.lean:519-522` is **WRONG**. It contains two errors:

1. **Wrong guard convention in counterexample**: The counterexample claims "q on [0,2)" using half-open guard, but the actual code (`Truth.lean:127-128`) implements **open guard** `(t, s)`:
   ```lean
   | Formula.untl φ ψ => ∃ s : D, t < s ∧ truth_at M Omega τ s ψ ∧
       ∀ r : D, t < r → r < s → truth_at M Omega τ r φ
   ```

2. **Wrong evaluation point for S(p,r)**: The counterexample evaluates S(p,r) at the starting point u=0, but A3a's conclusion `U(q ∧ S(p,r), r)` requires S(p,r) at the **guard points** in the open interval (t, s), not at t itself.

**Proof that A3a is valid under open guard (t, s)**:

A3a: `p ∧ U(q, r) → U(q ∧ S(p, r), r)` (Burgess convention: U(event, guard))

At time t: Assume p(t) and U(q, r) at t, i.e., ∃ s > t with q(s) and r on (t, s).
Need: U(q ∧ S(p, r), r) at t, i.e., ∃ s' > t with (q ∧ S(p,r))(s') and r on (t, s').

Take s' = s:
- q(s) ✓ (from premise)
- S(p, r) at s: need ∃ v < s with p(v) and r on (v, s)
  - Take v = t: p(t) ✓, r on (t, s) ✓ (from U(q, r) premise)
- r on (t, s') = r on (t, s) ✓

**A3a is semantically valid for all linear orders under open guard (t, s).**

### Documentation Mismatch Is the Root Cause

The codebase has a persistent stale documentation layer that claims "half-open guard [t, s)" in several places, while the actual Lean code implements open guard (t, s):

| Location | Claims | Actual Code |
|----------|--------|-------------|
| `Truth.lean:14` docstring | "half-open guard [t, s)" | `t < r → r < s` = open (t, s) |
| `Truth.lean:72` impl notes | "half-open guards [t,s) / (s,t]" | `t < r → r < s` = open (t, s) |
| `Truth.lean:520` inline comment | "open guard" | ✓ matches code |
| `Truth.lean:623` inline comment | "open guard" | ✓ matches code |
| `Soundness.lean:485` | "half-open guard convention [t, s)" | actual code uses open (t, s) |
| `Soundness.lean:499` | "Under open guard (t,s)" | ✓ matches code |
| `ROADMAP.md:187-189` | "open guard (t, s)" | ✓ matches code |
| `PointInsertion.lean:16` | "not valid under strict semantics" | Based on wrong counterexample |
| `TemporalDerived.lean:515` | "NOT valid under irreflexive" | Wrong counterexample |
| `Axioms.lean:148` BX4 comment | "not valid under half-open guard" | Stale; open guard makes A3a valid |

The stale references date from before task 113 changed the semantics. The "counterexample" was written for half-open guard and was never re-evaluated after the switch to open guard.

### BX4 Was Designed as a Replacement for A3a — But is Strictly Weaker

BX4 (`connect_future: φ → G(P(φ))`) gives `P(α) = S(α, ⊤) ∈ C`, but Lemma 2.3 needs `S(α, β) ∈ C` with a specific guard β. BX4 only provides the trivial guard ⊤. Under open guard, A3a bridges this gap directly.

The PointInsertion.lean comment (line 533) claims "BX4 + BX5 subsume A3a's role" — this is aspirational and has never been demonstrated. The Lemma 2.3 sorry sites are direct evidence that BX4 does NOT subsume A3a.

## Strategic Assessment

### Option A: Add A3a as BX13 — **RECOMMENDED** (HIGH confidence)

**Feasibility**: HIGH. A3a is semantically valid under the actual open guard semantics. Adding it as a new axiom constructor requires:
1. Add `enrichment_until` (or similar) to the `Axiom` inductive type (~5 lines)
2. Add its Since mirror A3b as `enrichment_since` (~5 lines)
3. Prove soundness: `enrichment_until_valid` — straightforward, ~20 lines (take same witness, construct S via the Until guard interval)
4. Wire into the axiom validity dispatch (~2 lines)

**Effort**: 2-4 hours for the axiom addition + soundness proof.

**Impact on existing proofs**: NONE negative. Adding an axiom STRENGTHENS the system. All existing sorry-free proofs remain valid. BX4 remains in the system; A3a (BX13) is an additional axiom.

**Impact on chronicle construction**: TRANSFORMATIVE. With A3a available:
- Lemma 2.3 (burgessR_implies_burgessRSince) becomes provable by Burgess's original one-line proof
- Xu's 3.2.1 works with bidirectional maximality (no restructuring needed)
- Xu's 3.2.2 works directly
- The entire plan v22 becomes feasible without modifications

**Risk**: LOW. The only risk is whether the soundness proof compiles — but the semantic argument is trivial.

### Option B: Derive A3a from Existing Axioms

**Feasibility**: UNKNOWN but likely VERY HARD. A3a connects Until guards to Since guards — a structural property that no other axiom captures. BX4 gives P(p) = S(p, ⊤) but cannot strengthen to S(p, r). BX5 only enriches within the same temporal direction.

**Effort**: Potentially unbounded. The derivation would need to construct S(p, r) from P(p) + guard information, which likely requires the exact semantic content that A3a provides.

**Recommendation**: Skip. Adding A3a directly (Option A) is simpler and correct.

### Option C: Forward-Only Maximality

**Feasibility**: MEDIUM. Restructuring BurgessR3Maximal to forward-only maximality avoids Lemma 2.3 for 3.2.1 but still needs it for 3.2.2 (C4 elimination). The restructuring would touch:
- ChronicleTypes.lean (c2' definition)
- RRelation.lean (exists_from_seed construction)
- CounterexampleElimination.lean (all elimination functions)
- Multiple existing sorry-free proofs

**Effort**: 15-25 hours of restructuring before any sorry sites can be addressed.

**Risk**: HIGH. Even after restructuring, 3.2.2 still needs Lemma 2.3. This option moves the problem rather than solving it.

**Recommendation**: Skip. Option A makes this unnecessary.

### Option D: Avoid Lemma 2.3 Entirely

**Feasibility**: VERY LOW. All published completeness proofs for US-tense logic (Burgess 1982, Xu 1988, Reynolds 1992, Hodkinson-Reynolds 2006) use the forward-backward equivalence. A novel approach would require inventing new mathematics.

**Effort**: Unbounded, high risk of failure.

**Recommendation**: Not viable.

### Option E: Fix Guard Semantics Mismatch

**Feasibility**: NOT NEEDED. The guard semantics are already open guard (t, s) in the code. The mismatch is only in stale documentation. No code changes needed.

**Effort**: 1-2 hours to fix stale docstrings (should be done regardless).

**Recommendation**: Do the documentation fix as part of Option A.

## Recommended Path

**Option A: Add A3a (and A3b mirror) as BX13/BX13'**

### Implementation Steps

1. **Add axiom constructors** to `Axioms.lean`:
   ```lean
   | enrichment_until (φ ψ χ : Formula) :
       Axiom (Formula.and φ (Formula.untl ψ χ) |>.imp
         (Formula.untl (Formula.and ψ (Formula.snce ψ φ)) χ))
   | enrichment_since (φ ψ χ : Formula) :
       Axiom (Formula.and φ (Formula.snce ψ χ) |>.imp
         (Formula.snce (Formula.and ψ (Formula.untl ψ φ)) χ))
   ```
   Note: Need to verify exact formula encoding matches BX convention (guard=first arg, event=second arg).

2. **Prove soundness** in `Soundness.lean`:
   - For `enrichment_until_valid`: Given φ(t) and U(ψ, χ)(t) with witness s and guard ψ on (t,s), show U(ψ ∧ S(ψ, φ), χ)(t) with same witness s, where S(ψ, φ) at s uses witness t: φ(t) and ψ on (t, s). Trivial under open guard.

3. **Prove Lemma 2.3** in `RRelation.lean`:
   - Apply A3a (enrichment_until) directly. The proof follows Burgess's one-line argument.

4. **Complete Xu's 3.2.1** in `RRelation.lean`:
   - The sorry on `burgessR3Maximal_untl_mem_B` resolves via Lemma 2.3 + existing BX5 infrastructure.

5. **Fix stale documentation** in Truth.lean, Soundness.lean, TemporalDerived.lean, PointInsertion.lean, Axioms.lean.

### Estimated Effort

| Step | Hours |
|------|-------|
| Add axiom constructors + soundness | 2-4 |
| Prove Lemma 2.3 (2 sorry sites) | 2-3 |
| Complete Xu 3.2.1 (2 sorry sites) | 3-5 |
| Fix stale documentation | 1-2 |
| **Total** | **8-14** |

This is dramatically less than the current plan's 52 hours because the fundamental blocker is removed.

## Risk Analysis

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Soundness proof fails | VERY LOW | Blocks everything | Semantic argument is trivial; only risk is Lean engineering |
| Adding axiom breaks existing proofs | NONE | N/A | Adding axioms only strengthens the system |
| A3a formula encoding wrong | LOW | Delays 1-2h | Carefully verify untl/snce guard/event convention |
| BX2 redundant conjunct causes issues | NONE | N/A | BX2 remains sound with or without extra conjunct |
| Downstream plan phases need revision | LOW | 5-10h | With A3a available, phases 4-8 should be simpler, not harder |

## Alignment with Project Goals

From `specs/ROADMAP.md`:
- **Primary completeness path**: Chronicle construction (task 107)
- **Goal**: Sorry-free `dd_countermodel_chronicle`
- **Current blockers**: 15 sorry sites, with Lemma 2.3 / Xu 3.2.1 as the root cause

Adding A3a directly unblocks the root cause. It's also mathematically correct — A3a is a standard axiom of every US-tense logic (Xu's axiom (3), part of every `TL_US` by definition). Our system should have included it from the start; it was only excluded due to a stale counterexample.

## Confidence Level

**HIGH (90-95%)**. The semantic validity proof is watertight. The only uncertainty is Lean engineering effort for the soundness proof and axiom wiring.

## Secondary Recommendations

1. **Delete the wrong counterexample** from TemporalDerived.lean:517-522. It has misled 40+ rounds of research.
2. **Update BX4 comment** in Axioms.lean:148 — BX4 no longer "replaces" A3a; both should coexist.
3. **Fix Truth.lean docstring** lines 13-14 and 72 — change "half-open guard" to "open guard".
4. **Consider whether BX4 is still needed** after adding A3a. A3a with ψ=⊤ gives `p ∧ F(φ) → F(φ ∧ P(p))`, which combined with BX10 gives a form of temporal connectedness. BX4 may be derivable from A3a + BX10 + BX12. But this is a separate investigation — keep BX4 for now.
