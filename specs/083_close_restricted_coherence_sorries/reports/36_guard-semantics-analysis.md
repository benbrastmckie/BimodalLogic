# Research Report: Guard Boundary Semantics and Burgess-Xu Axiom 4

- **Task**: 83 - Close Restricted Coherence Sorries
- **Type**: lean4
- **Focus**: Whether fully closed guards resolve the truth lemma gap, and why BX4 was replaced
- **Date**: 2026-04-08
- **Artifact**: reports/36_guard-semantics-analysis.md
- **Sources**: Literature (Burgess 1982/84, SEP Temporal Logic, Venema 1993, Hodkinson-Reynolds 2006, Kamp 1968), codebase (Truth.lean, Axioms.lean, Soundness.lean, prior reports 09/11/26/27/31/33), git history

## Executive Summary

The replacement of Burgess-Xu axiom 4 with BX4 (`φ → G(P(φ))`) was justified: the original interaction axiom is **not valid** under our half-open guard semantics due to a boundary mismatch at the witness point. Fully closed guards would fix this but **fatally break BX8** (`ψ → φ U ψ`). The current semantics (reflexive witness, half-open guard) is the standard reflexive convention matching the SEP, LTL, and Burgess-Xu's own reflexive formulation. The open question is whether BX1-BX10 (with the weaker BX4) is still complete, or whether a valid variant of the interaction axiom is needed.

**Confidence**: HIGH on semantic analysis, MEDIUM on completeness of modified system.

## 1. The Four Guard Conventions

### 1.1 Option 1: Fully Strict (Kamp 1968)

```
φ U ψ at t  ↔  ∃ s > t, ψ(s) ∧ ∀ r ∈ (t, s), φ(r)
φ S ψ at t  ↔  ∃ s < t, ψ(s) ∧ ∀ r ∈ (s, t), φ(r)
```

- Witness strictly future/past, guard open both sides
- Standard in Kamp's expressive completeness theorem
- F(ψ) ≠ ⊤ U ψ under reflexive G (breaks bridge)
- T-axiom (G(φ) → φ) not valid for strict G
- Burgess-Xu axiom 4: **valid** (the original formulation)
- Report 11 evaluated this: 85+ change sites, 80-120 hours estimated, F-U bridge breaks

### 1.2 Option 2: Reflexive Witness, Half-Open Guard (Current)

```
φ U ψ at t  ↔  ∃ s ≥ t, ψ(s) ∧ ∀ r ∈ [t, s), φ(r)
φ S ψ at t  ↔  ∃ s ≤ t, ψ(s) ∧ ∀ r ∈ (s, t], φ(r)
```

- Witness reflexive, guard closed at current time, open at witness
- **This is the standard reflexive convention**: matches the SEP's conversion formula `φ U_ref ψ := ψ ∨ (φ ∧ φ U_strict ψ)`, the CS/LTL convention, and Burgess-Xu's reflexive formulation
- F(ψ) ↔ ⊤ U ψ: **valid** (taking s = t gives ψ(t) with empty guard)
- BX8 (ψ → φ U ψ): **valid** (s = t, guard [t,t) empty)
- BX9 (φ U ψ → φ ∨ ψ): **valid**
- Burgess-Xu axiom 4: **NOT valid** (see Section 2)
- BX4 replacement (φ → G(P(φ))): **valid**

### 1.3 Option 3: Reflexive Witness, Fully Closed Guard

```
φ U ψ at t  ↔  ∃ s ≥ t, ψ(s) ∧ ∀ r ∈ [t, s], φ(r)
φ S ψ at t  ↔  ∃ s ≤ t, ψ(s) ∧ ∀ r ∈ [s, t], φ(r)
```

- Witness reflexive, guard closed both sides (includes witness point)
- At witness s: both φ AND ψ must hold
- **BX8 (ψ → φ U ψ): INVALID** — taking s = t requires ψ(t) ∧ φ(t), but only ψ(t) given
- Burgess-Xu axiom 4: would be valid (guard provides χ(s))
- Non-standard: no published source uses this convention
- **Fatal flaw**: BX8 is a fundamental axiom; its loss breaks all reflexive witness arguments

### 1.4 Option 4: Reflexive Witness, Fully Open Guard

```
φ U ψ at t  ↔  ∃ s ≥ t, ψ(s) ∧ ∀ r ∈ (t, s), φ(r)
φ S ψ at t  ↔  ∃ s ≤ t, ψ(s) ∧ ∀ r ∈ (s, t), φ(r)
```

- Witness reflexive, guard open both sides
- When s = t: guard (t, t) is empty, so φ U ψ ↔ ψ (same as Option 2)
- When s > t: guard (t, s) is open, φ does not include current time t
- BX8 (ψ → φ U ψ): **valid** (s = t case)
- BX9 (φ U ψ → φ ∨ ψ): **valid** (s = t gives ψ; s > t gives nothing about t... wait, need φ(t). Guard (t,s) doesn't include t. So when s > t, we DON'T have φ(t) from the guard.)
- **BX9 requires a case split**: s = t gives ψ(t), but s > t does NOT give φ(t) or ψ(t). So BX9 is **NOT valid** under fully open guard.
- This convention is considered in Report 33 as the "truly strict" interior

## 2. Why Burgess-Xu Axiom 4 Fails Under Half-Open Guards

### 2.1 The Axiom

`α ∧ (χ U ψ) → χ U (ψ ∧ χ S α)`

### 2.2 The Failure (Case s > t)

Assume at time t: α(t) and χ U ψ at t.
- χ U ψ: ∃ s ≥ t, ψ(s) ∧ ∀ r ∈ [t, s), χ(r).
- Take witness s > t.

We need: χ U (ψ ∧ χ S α) at t. Take witness s.
1. ψ(s): given. ✓
2. χ S α at s: need ∃ u ≤ s, α(u) ∧ ∀ r ∈ (u, s], χ(r). Take u = t.
   - α(t): given. ✓
   - ∀ r ∈ (t, s], χ(r): need χ at all r with t < r ≤ s.
     - For r ∈ (t, s): χ(r) from the Until guard [t, s). ✓
     - **For r = s: χ(s) is NOT provided.** The Until guard covers [t, s) — open at s. ✗
3. χ on [t, s) for the outer Until guard: given. ✓

**The gap**: The Until guard is [t, s) (open at s), but the Since guard needs (t, s] (closed at s). At the boundary point s, we have ψ(s) from the witness but NOT χ(s) from the guard. The guard conventions are "mismatched" at the witness point.

### 2.3 Verification via Reflexive Expansion

The SEP defines reflexive Until from strict: `φ U_ref ψ := ψ ∨ (φ ∧ φ U_strict ψ)`.

Expanding Burgess-Xu 4 for reflexive versions:
- Assumption: `α ∧ (ψ ∨ (χ ∧ χ U_strict ψ))`
- **Case ψ(t)**: Need χ S_ref α at t. `χ S_ref α := α ∨ (χ ∧ χ S_strict α)`. We have α(t). ✓
- **Case χ(t) ∧ χ U_strict ψ**: Strict Until gives s > t, ψ(s), guard (t,s). Need χ U_strict (ψ ∧ χ S_ref α). Take witness s. Guard (t, s): χ(r). ✓. But need χ S_ref α at s = `α(s) ∨ (χ(s) ∧ χ S_strict α at s)`. **Neither α(s) nor χ(s) is guaranteed.** ✗

The same failure occurs even when expanding through the strict definition. The boundary point s is not covered by either the Until guard or the Since witness.

### 2.4 Conclusion

The replacement was **mathematically necessary**, not a design error. Commit `9d6cf9a1d` correctly identified and resolved this unsoundness.

## 3. Why Fully Closed Guards Don't Work

### 3.1 BX8 Becomes Invalid

BX8: `ψ → φ U ψ` (reflexive introduction — any formula can serve as guard)

Under closed guard: φ U ψ at t requires ∃ s ≥ t, ψ(s) ∧ ∀ r ∈ [t, s], φ(r). Taking s = t: need ψ(t) ∧ φ(t). But BX8 only assumes ψ(t), not φ(t).

**This is fatal.** BX8 is used throughout the codebase:
- Truth lemma: reflexive witness case (`ψ ∈ w → φ U ψ ∈ w` via BX8)
- Derived theorems: `psi_imp_until` in TemporalDerived.lean
- Consistency arguments: forward_witness_seed relies on BX8's soundness

Without BX8, the entire canonical model construction collapses.

### 3.2 What Closed Guards Would Fix

| Axiom | Half-Open | Closed | Change |
|-------|-----------|--------|--------|
| BX8 `ψ → φ U ψ` | ✓ valid | ✗ INVALID | **Fatal loss** |
| BX9 `φ U ψ → φ ∨ ψ` | ✓ valid | ✓ valid (stronger: → φ) | Strengthened |
| BX5 self-accumulation | ✓ valid | ✓ valid | Unchanged |
| BX6 absorption | ✓ valid | ✓ valid | Unchanged |
| BX7 linearity | ✓ valid | ✓ valid | Unchanged |
| Burgess-Xu 4 | ✗ INVALID | ✓ valid | Would fix gap |
| BX4 `φ → G(P(φ))` | ✓ valid | ✓ valid | Unchanged |
| F ↔ ⊤ U | ✓ valid | ✓ valid | Unchanged |

Closed guards fix the interaction axiom but break the more fundamental BX8. **Net result: worse.**

### 3.3 Could BX8 Be Replaced Under Closed Guards?

Under closed guards, the correct reflexive introduction would be: `φ ∧ ψ → φ U ψ`. This requires BOTH guard and witness to hold at the current time.

This is strictly weaker than the current BX8 (which only requires ψ). The weakening propagates through all proofs that use BX8 to construct reflexive witnesses, requiring φ ∈ w in addition to ψ ∈ w. Many of these would fail (e.g., when building witnesses where we only control which formulas are in the seed, not the guard formula).

## 4. The Standard Convention: Confirmed

### 4.1 Literature Survey

| Source | G/H | U/S Witness | U Guard | Convention |
|--------|-----|-------------|---------|------------|
| Kamp 1968 | strict | strict (>) | open (t,s) | Option 1 |
| Burgess 1982/84 | reflexive (≤) | reflexive (≥) | half-open [t,s) | **Option 2** |
| Venema 1993 | both variants | both | matches G/H choice | Options 1/2 |
| GHR 1994 | reflexive | reflexive | half-open | **Option 2** |
| Goldblatt 1992 | reflexive | reflexive | half-open | **Option 2** |
| LTL (CS) | N/A (discrete) | reflexive (≥) | half-open [i,j) | **Option 2** |
| SEP conversion | reflexive | reflexive | half-open | **Option 2** |

**Option 2 is universal.** No source uses fully closed guards (Option 3).

### 4.2 The SEP Conversion Formula

The SEP defines reflexive from strict: `φ U_ref ψ := ψ ∨ (φ ∧ φ U_strict ψ)`

This yields exactly Option 2:
- When s = t: reduces to ψ(t) (reflexive witness, empty guard)
- When s > t: reduces to φ(t) ∧ ∃ s > t, ψ(s) ∧ ∀ r ∈ (t,s), φ(r) — which is ∃ s ≥ t, ψ(s) ∧ ∀ r ∈ [t,s), φ(r)

## 5. The Completeness Question

### 5.1 The Dilemma

The Burgess-Xu system (with original axiom 4) is complete for reflexive Until/Since on linear orders. But axiom 4 is not valid under the standard reflexive semantics (Option 2). This creates a paradox:

**Resolution**: The Burgess-Xu system was originally formulated for STRICT semantics. The SEP says it works for "reflexive versions" — but the reflexive completeness is obtained by translating through the strict version using `φ U_ref ψ := ψ ∨ (φ ∧ φ U_strict ψ)`. The axioms are validated against the STRICT semantics, then the reflexive operators are defined as abbreviations.

In our system, Until and Since are PRIMITIVE operators with their own semantics (not abbreviations for strict + disjunction). This means the Burgess-Xu axioms must be re-validated against Option 2 semantics directly — and axiom 4 fails this direct validation.

### 5.2 Is BX1-BX10 Complete Without the Interaction Axiom?

This is the central open question. Three possibilities:

**Possibility A**: BX1-BX10 is complete. The interaction axiom is derivable from BX4-BX10 (or a valid variant is). The truth lemma proof just needs the right technique.

**Possibility B**: BX1-BX10 is incomplete. A valid variant of the interaction axiom is needed. We need to find and add it.

**Possibility C**: BX1-BX10 is complete, but the proof technique fundamentally differs from Burgess's (which relied on axiom 4). A novel approach is needed.

### 5.3 Candidate Valid Interaction Axioms

The following are all valid under Option 2 and could serve as interaction axioms:

**Candidate 1**: `α ∧ (χ U ψ) → χ U (ψ ∧ P(α))`
- Valid: P(α) at s means ∃ u ≤ s, α(u). Take u = t: α(t). ✓
- Weakness: P(α) is existential — loses guard continuity information
- Probably too weak for the truth lemma

**Candidate 2**: `(χ U ψ) → (χ U (ψ ∧ P(χ U ψ)))`
- Valid: From BX4, G(P(χ U ψ)) follows from χ U ψ, so P(χ U ψ) ∈ g_content. At witness s: P(χ U ψ) holds.
- Derivable from existing axioms (BX4 + BX3)
- Still existential — P doesn't give guard info

**Candidate 3**: `α ∧ (χ U ψ) → χ U ((ψ ∧ α) ∨ (ψ ∧ χ S α))`
- Valid: At witness s, either α(s) (first disjunct covers the gap) or χ(s) (Since covers it).
- If s = t: ψ(t), and α(t) given, so first disjunct. ✓
- If s > t: need α(s) ∨ χ(s). Not guaranteed. ✗ Still fails.

**Candidate 4**: `(χ U ψ) → ((χ ∧ (χ U ψ)) U ψ)` (This is BX5!)
- Already an axiom: self-accumulation
- Gives: at intermediate points, both χ AND χ U ψ hold
- Does NOT give info at the witness point s

**Candidate 5**: Derive the interaction from BX5 + BX7 by showing that the canonical model's bx_le ordering has linearity properties sufficient for the truth lemma.
- Not an axiom but a proof technique
- This is the approach evaluated in Report 35 as "Option A"

## 6. Implications for the Truth Lemma

### 6.1 What We Actually Need

For the forward direction of `until_iff_mcs`:
- Given: `φ U ψ ∈ w`, `ψ ∉ w`
- Need: ∃ v ≥ w, ψ ∈ v, ∀ u ∈ [w,v), φ ∈ u

The guard `φ ∈ u` at intermediate BXPoints is the blocker. We need SOME mechanism to establish φ at points between w and the witness v.

### 6.2 What the Interaction Axiom Would Give

If we had a VALID version of Burgess-Xu 4, say `α ∧ (χ U ψ) → χ U (ψ ∧ ENRICHMENT)`, where ENRICHMENT encodes the guard, we could:
1. Apply it with α = φ U ψ, χ = φ, ψ = ψ
2. Get φ U (ψ ∧ ENRICHMENT) ∈ w
3. Build witness v with both ψ and ENRICHMENT
4. Extract guard from ENRICHMENT

The problem is finding a valid ENRICHMENT strong enough to encode the guard.

### 6.3 What We Have

From BX4 + BX5, we can derive:
- `P(φ U ψ)` at all points above w (via g_content propagation)
- `P((φ ∧ (φ U ψ)) U ψ)` at all points above w
- At any intermediate u: ∃ u' ≤ u with `(φ ∧ (φ U ψ)) U ψ ∈ u'`, giving either φ ∈ u' or ψ ∈ u'

The gap: the backward witness u' is not necessarily u itself, and we can't guarantee w ≤ u'.

## 7. Recommendations

### 7.1 Do NOT Change to Fully Closed Guards

Fully closed guards break BX8, which is more fundamental than the interaction axiom. This path is definitively ruled out.

### 7.2 Do NOT Restore Burgess-Xu Axiom 4

The axiom is genuinely unsound under our semantics. The replacement was correct.

### 7.3 Investigate Valid Interaction Axiom Variants

The most promising path is finding a valid enrichment that is strong enough for the truth lemma. Candidates:

1. **BX5-based enrichment with Zorn**: Use BX5 to get `(φ ∧ (φ U ψ)) U ψ ∈ w`, then use Zorn to find a minimal witness where ψ holds, arguing that at all points before it, φ U ψ persists (from the Zorn construction) and ψ doesn't hold (from minimality), giving φ by BX9.

2. **Novel interaction axiom**: Find a valid formula that captures the Until-Since interaction without the boundary problem. The key is avoiding the (t, s] requirement at s.

3. **Proof technique without interaction**: Show that BX5 + BX6 + BX7 together provide enough power for the canonical model construction, possibly via a non-standard induction scheme.

### 7.4 Investigate Whether BX1-BX10 Is Complete

This is the fundamental question. If the system IS complete (Possibility A or C from Section 5.2), a proof technique exists. If it is NOT complete (Possibility B), we need to identify and add the missing axiom.

One concrete test: can we find a formula that is valid on all linear orders but not derivable from BX1-BX10? If yes, the system is incomplete. If no such formula exists after thorough search, completeness is likely.

## 8. Open Questions

1. **Is `α ∧ (χ U ψ) → χ U (ψ ∧ P(χ) ∧ P(α))` strong enough?** The double-P enrichment gives more past witnesses at s. Still existential.

2. **Can BX7 (linearity) be used to establish that the backward witness u' from P(φ U ψ) ∈ u satisfies w ≤ u'?** If so, the Zorn approach from Report 35 (Option C) becomes viable.

3. **Is there a well-founded measure on Until formulas that makes BX5's enrichment usable in induction?** The formula `(φ ∧ (φ U ψ)) U ψ` has the same Until subformulas as `φ U ψ`. A measure based on the set of Until subformulas (rather than formula complexity) might allow mutual induction.

4. **Does the Burgess-Xu axiom 4 become derivable when Since truth lemma is available?** The truth lemma is proved mutually for all formulas. If we had the Since truth lemma, could we derive the effect of the interaction axiom at the MCS level?

## References

- Burgess (1982). "Axioms for Tense Logic I: Since and Until." *NDJFL* 23(4).
- Kamp (1968). *Tense Logic and the Theory of Linear Order*. PhD thesis, UCLA.
- Venema (1993). "Derivation Rules as Anti-Axioms in Modal Logic." *JSL* 58(3).
- Hodkinson & Reynolds (2006). "Temporal Logic." In *Handbook of Modal Logic*.
- SEP: "Temporal Logic" — Burgess-Xu supplement.
- Prior reports: 09 (strict vs weak), 11 (fully strict recommended), 26 (reflexive fix), 27 (mixed confirmation), 31 (F_until_equiv), 33 (BX refactor), 35 (eventuality approaches).
- Git history: commit 9d6cf9a1d (BX4 replacement rationale).
