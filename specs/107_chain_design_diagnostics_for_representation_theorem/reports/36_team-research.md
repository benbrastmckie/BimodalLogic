# Research Report: Task #107

**Task**: 107 - Burgess chronicle construction for BX representation theorem
**Date**: 2026-04-27
**Mode**: Team Research (4 teammates)
**Session**: sess_1777349941_ed4386

## Summary

Four-teammate investigation reveals the **root cause** of the D₀ consistency impasse: a **guard semantics divergence** between our formalization and Burgess 1982. Burgess uses open-interval guards `(t,s)` for Until and `(s,t)` for Since, while our code uses half-open guards `[t,s)` and `(s,t]`. This seemingly minor difference invalidates Burgess's axioms A3a and A4a in our system — the exact axioms needed for the D₀ consistency proof. The claim "BX5+BX7 subsume A4a" (PointInsertion.lean:21-22) is an **unproven comment, likely false** for the D₀ use case, and has been the root cause of 35+ research rounds of false starts.

Three strategic options emerge: (A) align guard semantics with Burgess, (B) find novel BX-only replacements, or (C) restructure the seed construction. Following the user's directive to "match Burgess's approach, cutting no corners," Option A deserves serious investigation.

## Key Findings

### 1. ROOT CAUSE: Guard Semantics Divergence (HIGH CONFIDENCE — unanimous)

**Our semantics** (Truth.lean:127-130):
```
untl φ ψ => ∃ s > t, ψ(s) ∧ ∀r, t ≤ r → r < s → φ(r)    -- guard on [t,s)
snce φ ψ => ∃ s < t, ψ(s) ∧ ∀r, s < r → r ≤ t → φ(r)    -- guard on (s,t]
```

**Burgess's semantics** (Burgess 1982, §1.2):
```
U(α,β) = {x : ∃y > x, α(y) ∧ ∀z(x < z < y → β(z))}      -- guard on (x,y)
S(α,β) = {x : ∃y < x, α(y) ∧ ∀z(y < z < x → β(z))}      -- guard on (y,x)
```

The difference: our Until guard covers `[t,s)` (includes current point t, excludes witness s), while Burgess's covers `(x,y)` (excludes both endpoints). Our Since guard covers `(s,t]` (includes current point t), while Burgess's covers `(y,x)` (excludes both).

**Why this breaks A3a**: Burgess's A3a says `α ∧ U(q,r) → U(q∧S(α,r), r)`. Under Burgess's semantics, at the Until witness y: `S(α,r)` at y needs `∃w<y, α(w) ∧ r on (w,y)`. Taking w=x gives `α(x)` (hypothesis) and `r on (x,y)` (from the Until guard). This works because Burgess's Since guard covers the open interval (w,y), which is exactly the Until guard interval.

Under our semantics: `snce(r,α)` at s needs `∃s'<s, α(s') ∧ r on (s',s]`. Taking s'=t: `α(t)` OK, but `r on (t,s]` requires `r(s)`. Our Until guard only gives `r on [t,s)`, which does NOT include s. **A3a fails.**

The counterexample at TemporalDerived.lean:521-526 confirms this: times {0,1,2}, p true at 0 only. Under our half-open guard, `S(p,r)` at time 0 needs a strictly past witness — none exists. Under Burgess's open guard, the guard check at time 0 is vacuously skipped.

### 2. "BX5+BX7 Subsume A4a" Is Unproven and Likely False (HIGH CONFIDENCE — C, A agree)

The header comments in PointInsertion.lean:21-22 and TemporalDerived.lean:537-538 assert:
> "BX5 + BX6 + BX7 subsume A4a's role"

**This has never been formally proved.** No lemma in the codebase derives A4a or its consequences from BX axioms.

The claim is **likely false for the D₀ use case** because of a syntactic mismatch:
- **A4a** takes one positive Until and one **negative** Until → produces a new positive Until
- **BX7** (linearity) requires **two positive Untils** as input

The maximality witness from `BurgessR3Maximal_maximality_combined` gives `¬untl(β∧δ, γ) ∈ A` (negative). BX7 cannot accept this as input. The existing `left_mono_contrapositive_neg_delta` partially compensates (derives ¬δ∈A ∨ F(¬δ)∈A), but this is insufficient to complete the D₀ proof.

### 3. The Mixed A/C Problem IS Real (HIGH CONFIDENCE — A, C agree)

Burgess's D₀ = {S(α,β):α∈A,β∈B} ∪ B ∪ {¬δ} ∪ {U(γ,β):γ∈C,β∈B} mixes elements from MCS A (Until formulas, B) and MCS C (Since formulas, B). Proving joint consistency requires A3a to inject Since formulas into Until events within a single MCS.

Burgess's proof chain: A5a enriches the Until guard → A4a injects ¬δ → A3a injects S(α,β) → Lemma 2.2 (consistency criterion) concludes. Without A3a, the final injection step has no BX replacement.

Teammate A's detailed analysis (finding 7) shows that BX4+BX3 can enrich Until events with `P(α)` but NOT with `snce(β,α)`, because `P(α)` follows from `G(P(α))` (via BX4), while `snce(β,α)` at the witness point requires `β(s)` which the guard doesn't provide.

### 4. No Alternative Completeness Proof Exists in the Literature (HIGH CONFIDENCE — B)

All papers (Xu 1988, Reynolds 1992, Venema 1993, Hodkinson & Reynolds 2006, Verbrugge 2004) build on Burgess's chronicle construction for Until/Since completeness:
- **Xu 1988**: Simplifies the seed but his Lemma 2.3 uses A3a
- **Reynolds 1992**: Uses Burgess-Xu unchanged, adds Doets' theorem for reals
- **Venema 1993**: Uses Burgess as a lemma for well-orderings
- **Verbrugge 2004**: Only handles G/H (no Until/Since)

There is no alternative proof technique that avoids A3a/A4a entirely.

### 5. Xu's Simpler Seed Still Requires A3a (HIGH CONFIDENCE — A, B)

Xu 1988 Lemma 2.4 uses seed `B* ∪ {¬β}` (much simpler than Burgess's D₀), with consistency trivially proven. However, the subsequent step — establishing `r(A, ⊤, D)` — requires Xu's Lemma 2.3 which proves `P(α)∈B` and `F(γ)∈B` for all α∈A, γ∈C. **Xu's Lemma 2.3 proof explicitly uses axiom (3) = A3a.** So even the simplified Xu approach is blocked under our semantics.

### 6. Convention Alignment: Keep Kamp Guard-First (HIGH CONFIDENCE — D)

All literature uses Burgess's event-first convention. Our code uses Kamp guard-first. The semantic roles are identical (B=GUARD everywhere). Switching convention gains nothing mathematical and costs ~1300 lines of refactoring. The user's "match Burgess" directive should mean matching proof structure and mathematical content, with a documented mapping table, not swapping argument order.

## Synthesis

### Conflicts Resolved

| Conflict | Resolution |
|----------|-----------|
| Teammate D claims A3a might be valid under our semantics | **Resolved**: A3a IS valid under Burgess's open-interval semantics but NOT under our half-open semantics. The guard coverage difference is the cause. The counterexample at TemporalDerived.lean:521-526 is correct for our system. |
| Teammate A initially says mixed A/C problem is dissolved, then corrects | **Resolved**: Following Burgess carefully DOES dissolve it — but only under Burgess's semantics. Under ours, the A3a step fails, making the mixed A/C problem real. |
| Teammate D says "BX5+BX6+BX7 genuinely replace A4a's role" | **Resolved by Teammate C**: This is an unproven claim. BX7's input type (two positive Untils) doesn't match A4a's use case (positive + negative Until). The claim should be either formally proved or retracted. |

### Gaps Identified

1. **No formal proof that any BX combination achieves A4a's effect** — the plan assumes this without evidence
2. **Guard semantics choice was never evaluated against completeness proof requirements** — half-open guards were chosen for their axiom strength (until_guard, since_guard) without checking impact on A3a/A4a
3. **Xu Lemma 2.3 analog has never been attempted under BX axioms** — proving `P(α)∈B` and `F(γ)∈B` from BurgessR3Maximal using only BX axioms

### The Three Strategic Options

**Option A: Align Guard Semantics with Burgess (open intervals)**

Change from half-open `[t,s)` / `(s,t]` to open `(t,s)` / `(s,t)`. This recovers A3a and A4a, making Burgess's proof directly applicable.

- **Gains**: A3a and A4a become valid; Burgess's proof works verbatim; all 10 remaining sorries become straightforward
- **Costs**: Loses `until_guard` (untl(φ,ψ)→φ) and `since_guard` (snce(φ,ψ)→φ) axioms; requires auditing all sorry-free proofs that use these axioms; guard-at-current-point reasoning must be restructured; potentially large refactor
- **Risk**: Unknown scope of until_guard/since_guard dependencies
- **Alignment**: Directly matches Burgess's approach

**Option B: Find Novel BX-Only Replacements for A3a/A4a**

Keep current semantics, develop new axiom chains specific to the D₀ use case.

- **Gains**: Preserves all existing infrastructure; no refactor
- **Costs**: Uncharted mathematical territory; 35+ rounds have not found these replacements; "BX5+BX7 subsume A4a" is likely false
- **Risk**: High — may be mathematically impossible
- **Alignment**: Diverges from Burgess where his axioms fail

**Option C: Restructured Seed Construction**

Replace Burgess's D₀ with a simpler seed (e.g., B∪{¬δ}) and different downstream lemmas.

- **Gains**: Avoids the mixed A/C problem entirely; `dcs_neg_union_consistent` already proves seed consistency
- **Costs**: Requires proving burgessR3 conditions for the Lindenbaum extension D, which likely needs Xu Lemma 2.3 (blocked by A3a); diverges from Burgess's proof structure; downstream lemmas (2.7, 2.8, 2.9, 2.10) assume D₀ structure
- **Risk**: Medium-high — may relocate the problem rather than solve it
- **Alignment**: "Cutting corners" on D₀, which the user's directive discourages

## Recommendations

### 1. DECISIVE TEST: Check A4a Derivability (Immediate — 2-4 hours)

Before choosing a path, formally test whether `untl(β,γ) ∧ ¬untl(β∧δ,γ) → untl(β, β∧¬δ)` is derivable from BX axioms. Use `lean_multi_attempt` or a scratch proof. If derivable, Option B is viable. If not, it's dead.

### 2. DECISIVE TEST: Audit until_guard/since_guard Usage (Immediate — 2-4 hours)

Count how many sorry-free proofs depend on `until_guard` and `since_guard`. This determines the feasibility and cost of Option A. If the dependency is shallow (only used in a few lemmas with easy alternatives), Option A becomes strongly preferred.

### 3. RECOMMENDED PATH: Option A (Guard Semantics Alignment)

The user's directive to "follow Burgess's approach, cutting no corners" points directly at Option A. Burgess's proof is proven correct under his guard semantics. Aligning our semantics with his eliminates the fundamental obstacle. The cost is a refactor; the gain is mathematical certainty.

If the audit (test 2) shows until_guard/since_guard have deep dependencies, Option A should be done incrementally: first isolate the chronicle construction with Burgess-compatible semantics, then bridge to the rest of the codebase.

### 4. FALLBACK: Option C with Xu-Style Seed

If Option A is prohibitively expensive AND the A4a test (test 1) fails, investigate whether `P(α)∈B` and `F(γ)∈B` can be proved from BurgessR3Maximal without A3a. Teammate A's analysis suggests F(γ)∈A follows from BX10 on the r-relation, which is a starting point. If a BX-only proof of Xu Lemma 2.3 exists, the simpler seed B∪{¬δ} becomes viable.

### 5. Convention: Document, Don't Switch

Add a convention mapping table to PointInsertion.lean header. Map every Burgess reference to our notation. Do not switch to event-first.

### 6. Accept Realistic Timeline

Estimated remaining effort: 80-120 hours (with Option A); unknown (with Option B); 60-90 hours (with Option C). The 55-hour estimate in plan v21 is unrealistic given historical patterns.

## Teammate Contributions

| Teammate | Angle | Status | Key Finding | Confidence |
|----------|-------|--------|-------------|------------|
| A | Primary (Burgess proof) | completed | A3a invalid due to Since guard including current point; BX4+BX3 can enrich events with P(α) but not snce(β,α); Xu approach also blocked | HIGH |
| B | Alternatives | completed | No alternative to Burgess exists; Xu has simpler seed but depends on A3a; Reynolds uses Burgess unchanged | HIGH |
| C | Critic | completed | "BX5+BX7 subsume A4a" is unproven and likely false (syntactic mismatch: pos+neg vs pos+pos); mixed A/C problem is real; 35 rounds of false starts trace to this | HIGH |
| D | Horizons | completed | Chronicle is correct path (36 dead ends); A3a/A4a validity is THE decisive question; keep Kamp convention; 55h estimate too low; "cutting no corners" = use Burgess's D₀ | HIGH |

## References

- Burgess 1982: §1.2 (semantics), §2 (completeness), Lemma 2.6 (D₀ construction)
- Xu 1988: Lemma 2.3 (P(α)∈B, F(γ)∈B), Lemma 2.4 (simplified C4 insertion)
- Reynolds 1992: Uses Burgess-Xu as black box + Doets' theorem
- Truth.lean:127-130: Our guard semantics definition
- TemporalDerived.lean:517-541: A3a/A4a invalidity documentation
- PointInsertion.lean:21-22: Unproven "BX subsumes" claims
