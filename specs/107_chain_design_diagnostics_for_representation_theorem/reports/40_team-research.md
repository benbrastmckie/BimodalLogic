# Research Report: Task #107 — A3a Validity and Lemma 2.3 Resolution

**Task**: 107 - Burgess chronicle construction for BX representation theorem
**Started**: 2026-04-28T18:24:00Z
**Completed**: 2026-04-28T19:30:00Z
**Task Type**: lean4
**Domains**: logic
**Mode**: Team Research (4 teammates)

## Executive Summary

**BREAKTHROUGH**: The A3a axiom (`p ∧ U(q, r) → U(q ∧ S(p, r), r)`) IS semantically valid under our open-guard `(t, s)` semantics. The counterexample that led to its exclusion from our BX system was **wrong** — it evaluated `S(p, r)` at the current time `t` instead of at the Until witness `s`. This error, originating from stale documentation written for the old half-open guard `[t, s)` semantics, has been the root cause of 40+ rounds of misdirected research on task 107.

**Resolution**: Add A3a (and its mirror A3b) as new BX axioms. This immediately unblocks Burgess Lemma 2.3, which unblocks Xu's Lemma 3.2.1, which unblocks the entire chronicle construction. The current plan (v22) becomes fully viable without restructuring.

## 1. The Guard Semantics Are Open (t, s), Not Half-Open [t, s)

**Unanimous finding (all 4 teammates).**

The actual truth definition in `Truth.lean:127-130`:

```lean
| Formula.untl φ ψ => ∃ s : D, t < s ∧ truth_at M Omega τ s ψ ∧
    ∀ r : D, t < r → r < s → truth_at M Omega τ r φ
```

The guard interval is `t < r → r < s` — strictly open **(t, s)**. Neither endpoint is included.

However, multiple documentation locations incorrectly claim "half-open guard [t, s)":
- `Truth.lean:13-14` (docstring)
- `Truth.lean:72` (implementation notes)
- `Soundness.lean:485`
- `Axioms.lean:148` (BX4 comment)

These stale comments date from before task 113 changed the semantics. The `Boneyard/ClosedGuardLegacy/ClosedGuardAxioms.lean:4-7` correctly documents that task 113 adopted "open guard semantics (t,s) to match Kamp 1968, Burgess 1982, Xu 1988."

## 2. A3a Is Semantically Valid Under Open Guard

**Unanimous finding (all 4 teammates, independently verified).**

**A3a** (Burgess): `p ∧ U(q, r) → U(q ∧ S(p, r), r)` (Burgess convention: U(event, guard))
**In our code**: `p ∧ untl(r, q) → untl(r, q ∧ snce(r, p))` (our convention: untl(guard, event))

**Proof of validity at time t**: Assume `p(t)` and `untl(r, q)(t)`, i.e., ∃ s > t with `q(s)` and `r` on `(t, s)`.

Show `untl(r, q ∧ snce(r, p))(t)`. Take the same witness s:
1. `q(s)` ✓ (from the Until premise)
2. `snce(r, p)(s)`: need ∃ u < s with `p(u)` and `r` on `(u, s)`. Take **u = t**:
   - `t < s` ✓
   - `p(t)` ✓
   - `r` on `(t, s)` ✓ — **this is exactly the Until guard from the hypothesis**
3. Guard: `r` on `(t, s)` ✓ (same as hypothesis)

**The crucial semantic point**: Under open guard, the Until interval `(t, s)` and the Since interval `(t, s)` at the witness are **identical**. This is why A3a is valid for open guard but invalid for half-open guard (where Until gives `[t, s)` but Since needs `(t, s]` — the endpoint `s` is missing).

## 3. The Counterexample Was Wrong

**Unanimous finding (all 4 teammates).**

The counterexample in `TemporalDerived.lean:519-522` and handoff `03_phase3-lemma23-blocker.md`:

> "times {0, 1, 2}, p true at 0, q at 0-1, r at 2. At time 0: p ∧ U(q,r) holds. But U(q ∧ S(p,r), r) fails at 0 because S(p,r) at u=0 requires v < 0 with r(v)."

**Errors**:
1. **Wrong witness**: The counterexample uses witness s=2, but q(2) is false. The correct witness is s=1.
2. **Wrong evaluation point**: S(p, r) is evaluated at u=0 (the current time), but A3a puts S(p, r) inside the Until EVENT, so it's evaluated at the **witness** s, not at t.
3. **Stale guard convention**: The counterexample was written for half-open guard [t, s) and was never re-evaluated after task 113 changed to open guard (t, s).

**Correct evaluation**: With witness s=1: `q(1)` ✓. `snce(r, p)(1)` with witness u=0: `p(0)` ✓, `r` on `(0, 1)` = vacuous ✓. A3a holds. ✓

## 4. A3a Is NOT Derivable from BX1-BX12

**Finding (Teammates A, B, C).**

BX4 (`connect_future: φ → G(P(φ))`) gives `P(p) = snce(⊤, p)` at future points — with **trivial guard ⊤**. A3a needs `snce(r, p)` — with **specific guard r**. No combination of BX axioms can STRENGTHEN a Since guard from ⊤ to r:

- BX2'/BX3' (Since monotonicity) WEAKEN guards (go from strong to weak)
- BX5' (self_accum_since) enriches with Since formulas, not Until formulas
- BX12' (P → S(·, ⊤)) only gives trivial guard

The "shared interval" property — that the Until guard (t, s) provides the Since guard at the witness — is fundamentally new information not captured by any existing axiom.

**Note** (Teammate C): Despite A3a being semantically valid on ALL frames, this does NOT mean it's derivable from BX1-BX12, because the BX system may be incomplete for non-linear frames. A3a is a base axiom of every US-tense logic — it was never intended to be derived from other axioms.

## 5. Report 39's Mapping "A3a = (3) = BX4" Was WRONG

**Finding (Teammates A, C, D).**

Report 39 (the research basis for plan v22) claimed:

| Burgess J0 | Xu Sigma4 | Our BX |
|-----------|-----------|--------|
| A3a | (3) | BX4 |

This is **incorrect**:
- **BX4** = `connect_future` = `φ → G(P(φ))` (present is in the past of the future)
- **A3a** = `p ∧ U(q, r) → U(q ∧ S(p, r), r)` (Until event enrichment with Since)

These are completely different axioms. BX4 is strictly weaker than A3a. This misidentification is why report 39 concluded "no new math needed" — it assumed A3a was available under the name BX4.

## 6. A4a Is Also Valid Under Open Guard

**Finding (Teammate A).**

A4a: `U(p, q) ∧ ¬U(p, r) → U(q ∧ ¬r, q)`. Valid under open guard. However, A4a is only needed for Burgess's Lemma 2.6 (D0 consistency). Xu's approach (3.2.2) replaces 2.6 entirely using 3.2.1 + 2.1, avoiding A4a. So **A4a is not needed if we follow Xu's construction** (which the plan specifies). It could optionally be added for completeness.

## 7. Impact on Plan v22

With A3a added as a new axiom:

| Phase | Status | Impact |
|-------|--------|--------|
| 1 (Review) | COMPLETED | Unaffected |
| 2 (Cleanup) | COMPLETED | Unaffected |
| 3 (C2' + Xu 3.2.1) | BLOCKED → **UNBLOCKED** | Lemma 2.3 provable by Burgess's 1-line proof; 3.2.1 follows |
| 4 (C4 elimination) | NOT STARTED → **UNBLOCKED** | Xu's BX6-based approach works; 3.2.2 available via 3.2.1 + 2.1 |
| 5 (C5 + Lemma 2.10) | NOT STARTED → **UNBLOCKED** | Lemmas 2.7/2.8 use A3a directly; now available |
| 6 (FUC/truth lemma) | NOT STARTED | Likely unaffected (uses C5 + C3) |
| 7-8 | NOT STARTED | Depend on 3-6 |

**The plan v22 becomes fully viable with one prerequisite**: adding A3a/A3b as BX axioms.

## 8. Recommended Implementation Steps

### Phase 0 (New): Add A3a/A3b Axioms (2-4 hours)

1. **Add axiom constructors** to `Axioms.lean`:
   ```lean
   /-- BX enrichment (Until-Since): p ∧ (φ U ψ) → (φ ∧ S(p, φ)) U ψ.
   Enriches the Until event with Since information from the current point.
   Valid under open guard (t,s): the Until guard (t,s) provides the Since guard
   at the witness since the intervals are identical. Burgess A3a, Xu axiom (3). -/
   | enrichment_until (φ ψ p : Formula) :
       Axiom (Formula.and p (Formula.untl φ ψ) |>.imp
         (Formula.untl φ (Formula.and ψ (Formula.snce φ p))))
   
   /-- BX enrichment (Since-Until): mirror of enrichment_until.
   Burgess A3b, Xu axiom (4). -/
   | enrichment_since (φ ψ p : Formula) :
       Axiom (Formula.and p (Formula.snce φ ψ) |>.imp
         (Formula.snce φ (Formula.and ψ (Formula.untl φ p))))
   ```

2. **Prove soundness** in `Soundness.lean` (~20 lines): Take the same Until/Since witness; construct the S/U formula using the shared guard interval.

3. **Fix stale documentation**: Update `Truth.lean:13-14,72`, `Soundness.lean:485`, `Axioms.lean:148`, `TemporalDerived.lean:513-536`, `PointInsertion.lean:16-17`.

### Then continue plan v22 Phases 3-8

With A3a available, Lemma 2.3 becomes a 3-line proof (Burgess's original argument), which unblocks everything downstream.

## Conflicts Resolved

| Conflict | Resolution |
|----------|-----------|
| A3a valid or invalid? | **VALID** under open guard; counterexample was wrong |
| A3a = BX4? | **NO** — completely different axioms |
| Lemma 2.3 provable? | **YES** once A3a is added |
| Need forward-only maximality? | **NO** — bidirectional maximality works with A3a |
| Plan v22 viable? | **YES** with A3a addition as Phase 0 |

## Gaps Identified

1. **Formula encoding**: The exact Lean encoding of A3a needs careful verification against our untl/snce convention (guard first, event second). The teammate reports show slightly different formulations — must confirm which is correct.
2. **BX2 redundant conjunct**: Under open guard, BX2's extra `(φ→χ)` conjunct is unnecessary. This is a separate cleanup task.
3. **BX4 redundancy**: With A3a available, BX4 (connect_future) may be derivable from A3a + BX10 + BX12. Separate investigation.

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key contribution |
|----------|-------|--------|------------|-----------------|
| A | Guard semantics | Completed | HIGH (95%) | Definitive: open guard (t,s) from Truth.lean:127-130; A3a validity proof; wrong counterexample identified; BX2 redundant conjunct |
| B | Xu 3.2.1 mechanics | Completed | HIGH | Bidirectional maximality analysis; forward direction proved; backward failure = A3a wall; all paths require A3a |
| C | Critic/gap analysis | Completed | HIGH (95%) | Complete A3a dependency trace through Burgess/Xu; plan phase-by-phase assessment; A3a is base axiom not derivable from BX |
| D | Strategic path | Completed | HIGH (90-95%) | Option comparison; recommended add-A3a path; effort estimate 8-14h; documentation mismatch audit |

## References

### Codebase
- `Truth.lean:127-130` — open guard semantics definition
- `Truth.lean:13-14,72` — stale "half-open" docstrings
- `Axioms.lean:67-262` — BX axiom definitions
- `Axioms.lean:148` — stale BX4 comment about A3a
- `TemporalDerived.lean:513-536` — wrong counterexample to A3a
- `ClosedGuardAxioms.lean:4-7` — correct open guard documentation
- `RRelation.lean:1186-1243` — Lemma 2.3 blocked proofs
- `RRelation.lean:1283-1365` — sorry-free burgessR3_untl_conj_in_A

### Literature
- Burgess 1982, Lemma 2.3 (p.140): forward-backward equivalence using A3a
- Xu 1988, Lemma 2.1 (p.83): same equivalence, cited as "due to Burgess"
- Xu 1988, Lemma 3.2.1 (p.221): B closure using BX5 + maximality
- Xu 1988, axioms (3)/(4) (p.47): A3a/A3b as base axioms of every US-tense logic

### Teammate Reports
- [40_teammate-a-findings.md] — Guard semantics and A3a validity
- [40_teammate-b-findings.md] — Xu 3.2.1 proof mechanics
- [40_teammate-c-findings.md] — A3a dependency trace and plan assessment
- [40_teammate-d-findings.md] — Strategic path analysis
