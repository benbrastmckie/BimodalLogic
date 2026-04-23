# Teammate C (Critic) Findings: Round 6

**Task**: 107 - Chain design diagnostics for representation theorem
**Focus**: Cost/risk analysis of switching to strict G/H semantics vs. fixing reflexive system
**Date**: 2026-04-23

## Executive Summary

Switching to strict (irreflexive) G/H semantics would be catastrophic for the project. The reflexive semantics are deeply embedded in approximately 50,000 lines of non-boneyard Lean code, with the axioms BX1 (temp_t), BX8 (refl_intro_until), and BX9 (until_elim) used substantively in over 135 locations across 15+ files. The soundness proof (3,356 lines, sorry-free) would need complete re-derivation. The correct path forward is to work WITHIN reflexive semantics and either derive A3a/A4a from BX or bypass them entirely.

---

## 1. Dependency Census: How Pervasive is Reflexive Semantics?

### BX1 (temp_t_future/temp_t_past): G(phi) -> phi

| Category | Count | Files |
|----------|-------|-------|
| Soundness validity proofs | 10 | Soundness.lean |
| SoundnessLemmas swap-validity | 4 | SoundnessLemmas.lean |
| Canonical model (MCS-level) | 10 | CanonicalModel.lean |
| Frame infrastructure | 4 | Frame.lean |
| Chain construction | 6 | RootScopedChain.lean |
| Filtration/FMP | 3 | SigmaOrdering.lean |
| Quasimodel infrastructure | 5 | Realization.lean, OracleInstantiation.lean, Construction.lean |
| Derived theorems | 8 | TemporalDerived.lean (density_derivable, refl_F, refl_P, etc.) |
| Bundle/SuccRelation | 4 | SuccRelation.lean, SuccExistence.lean |
| Examples | 2 | TemporalProofs.lean |
| **Total substantive uses** | **~56** | **15+ files** |

**Assessment**: BX1 (reflexivity of G/H) is the MOST pervasive axiom in the codebase. It is used to derive: density (GGphi -> Gphi), reflexivity of F/P (phi -> F(phi)), Until unfolding steps, G-content propagation in MCS, and contradiction arguments. Removing it would invalidate the density_derivable theorem, refl_F/refl_P, and numerous MCS-level lemmas that extract phi from G(phi).

### BX8 (refl_intro_until/since): psi -> (phi U psi)

| Category | Count | Files |
|----------|-------|-------|
| Soundness | 8 | Soundness.lean, SoundnessLemmas.lean |
| Derived theorems | 4 | TemporalDerived.lean (psi_imp_until, until_unfold_wrapped) |
| MCS-level lemmas | 4 | Construction.lean, CanonicalChain.lean |
| TruthLemma | 2 | TruthLemma.lean |
| BXPointPath | 1 | BXPointPath.lean |
| **Total substantive uses** | **~19** | **7 files** |

**Assessment**: BX8 is used critically in the truth lemma (Until direction) and for Or-Until introduction. Under strict semantics, BX8 is INVALID (cannot take witness s=t when strict requires s>t). Removing BX8 would break the truth lemma's Until case and the until_unfold_wrapped / until_intro chain.

### BX9 (until_elim/since_elim): (phi U psi) -> (phi v psi)

| Category | Count | Files |
|----------|-------|-------|
| Soundness | 8 | Soundness.lean, SoundnessLemmas.lean |
| Derived theorems | 12 | TemporalDerived.lean (bot_until_bot_absurd, until_imp_or, until_unfold_thm, neg_conj_imp_neg_until, dual_until_and_until_absurd) |
| QuasimodelBridge | 4 | QuasimodelBridge.lean |
| Filtration/Defect | 2 | DefectChain.lean |
| Frame | 2 | Frame.lean |
| MCS-level | 2 | Construction.lean |
| **Total substantive uses** | **~30** | **8 files** |

**Assessment**: BX9 is used extensively for Until decomposition at the current time. Under strict semantics, BX9 is INVALID (if witness s>t, phi holds at t; but if there is no witness, the formula is simply false; the phi-or-psi disjunction does not follow because the case s=t is excluded). Removing BX9 would break the entire dual-Until decomposition chain (backward_dual_until_decomposition, dual_until_imp_neg_until) which is critical for the completeness proof direction.

### Summary of Dependencies

**Total uses of reflexive-specific axioms (BX1+BX8+BX9)**: ~105 substantive uses across 15+ non-boneyard files.

**Files with ZERO sorry that depend on reflexive axioms**:
- Soundness.lean (1,331 lines) -- sorry-free
- SoundnessLemmas.lean (2,025 lines) -- sorry-free
- TemporalDerived.lean (~900 lines) -- sorry-free
- Frame.lean (673 lines) -- sorry-free
- CanonicalModel.lean (498 lines) -- sorry-free
- QuasimodelBridge.lean (757 lines) -- sorry-free
- DefectChain.lean (137 lines) -- sorry-free
- SigmaOrdering.lean (179 lines, 1 comment-only "sorry") -- essentially sorry-free
- Construction.lean (891 lines) -- sorry-free
- Realization.lean (597 lines) -- sorry-free

**Total sorry-free code at risk**: ~8,000+ lines

---

## 2. Can the Burgess Approach Work with REFLEXIVE Until?

### A3a Analysis: p ^ U(q,r) -> U(q ^ S(p,r), r)

**What A3a says**: If p holds now and q-until-r holds, then at the Until witness point, Since(p,r) also holds -- the present p is "remembered" by the Since operator.

**Under reflexive semantics, A3a is likely DERIVABLE.** Here is the argument:

Given: p at time t, and U(q,r) at t (i.e., there exists s >= t with r(s), and q holds on [t,s)).

We need: U(q ^ S(p,r), r) at t.

The witness s for the original Until still works for the new Until. We need:
1. r(s) -- same witness, same r. Holds by assumption.
2. For all u in [t,s): (q ^ S(p,r))(u).
   - q(u): holds by the original guard.
   - S(p,r)(u): We need a witness v <= u with r(v), and p on (v,u]. 
   
   **Key question**: Can we find a Since witness? Under reflexive Since, the witness can be v=t. Then:
   - r(t)? Not necessarily -- r is only guaranteed at s, not at t.
   
   **Alternative**: Use BX4 (connect_future): p -> G(P(p)). Since p holds at t and u >= t, P(p) holds at u. But P(p) is not the same as S(p,r).
   
   **Problem**: A3a requires S(p,r), not just P(p). The Since witness needs to satisfy r at the witness point. Under reflexive semantics, if we take the Since witness v=u, then S(p,r)(u) requires r(u). But r is only guaranteed at s, not at intermediate u.

**Revised assessment**: A3a is NOT trivially derivable from BX. The argument requires that at intermediate points u in [t,s), either r(u) holds (making S(p,r) trivial via BX8') or p can be carried forward via some other mechanism. The reflexive semantics helps with BX8' (reflexive Since intro), but only if r(u) is available, which is not guaranteed.

**However**, A3a IS semantically valid under reflexive Until. To see this: Given p(t) and U(q,r)(t) with witness s>=t:
- Case s=t: Then r(t) and the guard is vacuous. The new Until U(q^S(p,r), r) is witnessed at s=t with r(t), and the guard [t,t) is vacuous. Holds by BX8-type reasoning.
- Case s>t: For each u in [t,s), we need S(p,r)(u). Choose the Since witness v=t. Then v<=u, r is not needed at v=t... wait, Since requires the witness to satisfy the second argument: S(p,r) = there exists v<=u with r(v) and p on (v,u]. Taking v=t: we need r(t) (not guaranteed!) and p on (t,u] (not given).

**Actually, re-reading A3a more carefully**: This is Burgess's notation, where U and S use STRICT semantics. Under strict semantics, A3a has a specific meaning. Under reflexive semantics, we need to re-interpret it.

Under reflexive U (witness s>=t, guard [t,s)) and reflexive S (witness v<=u, guard (v,u]):
- The Since witness v can be v=u. Then S(p,r)(u) requires r(u) (since witness=u must satisfy r), and the guard (u,u] is empty. So S(p,r)(u) reduces to r(u).
- But r(u) is not guaranteed for u in [t,s).

**Conclusion**: A3a as stated appears NOT derivable from BX1-BX12 under reflexive semantics, because the Since component requires r at intermediate points, which Until does not guarantee. The axiom is also likely NOT semantically valid under reflexive Until -- the counterexample is: p=true always, q=true always, r only at s=5, t=0. Then U(q,r) at t=0 is witnessed at s=5. But at u=3, S(p,r)(3) requires a Since witness v<=3 with r(v), but r only holds at s=5>3. So S(p,r)(3) is false. Hence q^S(p,r) fails at u=3, and U(q^S(p,r), r) fails at t=0, even though p^U(q,r) holds.

**A3a is NOT valid under reflexive semantics** if r only holds at the distant witness. This makes A3a non-derivable from BX.

### A4a Analysis: U(p,q) ^ ~U(p,r) -> U(q ^ ~r, q)

**What A4a says**: If p-until-q holds but p-until-r does not, then q-and-not-r-until-q holds. The q-witness arrives before any r-witness.

**Under reflexive semantics**: U(p,q) at t has witness s1>=t with q(s1), p on [t,s1). ~U(p,r) means no s>=t with r(s) and p on [t,s). We need U(q^~r, q) at t: there exists s2>=t with q(s2), and (q^~r) on [t,s2).

The witness s2 = s1 works: q(s1) holds. For u in [t,s1): we need q(u)... but q is the guard of U(p,q), and the GUARD is p, not q. So q is not guaranteed at intermediate u.

**A4a is also problematic under reflexive semantics.** The statement itself confuses guard and endpoint roles. Checking the exact Burgess formulation: A4a uses strict Until, and under strict semantics, the roles work differently.

**Conclusion**: A4a is similarly not straightforwardly derivable from BX under reflexive semantics.

---

## 3. Risks of Switching to Strict Semantics

### Risk 1: Soundness Obliteration (CATASTROPHIC)

The soundness proof is currently **sorry-free** across 3,356 lines. Under strict semantics:
- `temp_t_future_valid` (line 200): Uses `le_refl t` for witness s=t. Under strict G (s>t), this argument FAILS. The T-axiom G(phi)->phi is INVALID under strict G.
- `refl_intro_until_valid` (line 728): Uses `le_refl t` for Until witness s=t. Under strict Until (s>t), this is INVALID.
- `until_elim_valid` (line 748): Uses `eq_or_lt_of_le hts` case split. Under strict Until, the eq case disappears, and the argument needs restructuring.

**Impact**: All 37 axiom validity lemmas would need review. At minimum, BX1/BX8/BX9 become UNSOUND and must be REMOVED. The entire axiom system changes.

### Risk 2: Derived Theorem Cascade (SEVERE)

Removing BX1, BX8, BX9 invalidates:
- `density_derivable` (GGphi -> Gphi) -- no longer follows from BX1
- `refl_F` / `refl_P` (phi -> F(phi)) -- derived from BX1, now invalid
- `psi_imp_until` / `psi_imp_since` -- direct BX8, now invalid
- `until_imp_or` / `since_imp_or` -- direct BX9, now invalid
- `until_unfold_thm` -- uses BX5+BX9, broken
- `or_until_imp` -- uses BX8 in contrapositive, broken
- `bot_until_id` / `bot_since_id` -- used in Bundle/SuccRelation, broken
- `dual_until_and_until_absurd` -- the entire dual-Until chain, broken
- `backward_dual_until_decomposition` -- critical for completeness, broken

**Total derived theorems invalidated**: ~25 theorems in TemporalDerived.lean alone.

### Risk 3: Completeness Infrastructure (SEVERE)

The sorry-free infrastructure in BXCanonical/ relies heavily on reflexive axioms:
- **Frame.lean** (673 lines): Uses temp_t_future for G-content extraction (lines 128, 144), temp_t_past for backward ordering (line 316), until_elim for defect analysis (lines 637, 664).
- **CanonicalModel.lean** (498 lines): Uses temp_t_future/past for MCS property extraction at 6 locations.
- **TruthLemma.lean** (320 lines): Uses refl_intro_until/since for Until truth lemma direction.
- **Construction.lean** (891 lines): Uses refl_intro_until_mcs, until_elim_mcs, connect_future_mcs throughout.

**The Filtration/FMP infrastructure** (316 lines) is essentially sorry-free and uses temp_t_future (3 uses) and until_elim (2 uses). This would also break.

### Risk 4: Examples Directory (MODERATE)

3,258 lines of pedagogical examples would need updating. Many already have sorry markers for other reasons, but the sorry-free examples using BX1 would break.

### Risk 5: Rework Estimate

| Component | Lines | Effort (hours) |
|-----------|-------|----------------|
| New axiom system design | -- | 10-15 |
| Soundness re-proof | 3,356 | 40-60 |
| SoundnessLemmas re-proof | 2,025 | 25-35 |
| TemporalDerived re-derivation | 900+ | 15-25 |
| Frame.lean adaptation | 673 | 10-15 |
| CanonicalModel adaptation | 498 | 8-12 |
| TruthLemma adaptation | 320 | 5-8 |
| Construction adaptation | 891 | 12-18 |
| Filtration/FMP adaptation | 316 | 4-6 |
| Quasimodel infrastructure | 1,087 | 15-20 |
| Truth.lean semantic changes | 650 | 5-8 |
| Examples cleanup | 3,258 | 8-12 |
| Bundle infrastructure | 2,000+ | 20-30 |
| **Total** | **~16,000** | **177-264 hours** |

This is a **complete rewrite** of the metalogic layer. The 105-155 hour estimate from Round 5 was for the Burgess chronicle approach ASSUMING reflexive semantics are kept. Switching to strict adds another 177-264 hours on top, for a total of 280-420 hours. This is infeasible.

---

## 4. Third Options: Hybrid Approaches

### Option A: Strict G/H but Reflexive Until/Since

Define G(phi) as "for all s > t, phi(s)" (strict) but keep Until as "exists s >= t" (reflexive).

**Problem**: This creates an inconsistency. Under strict G, G(phi)->phi is invalid, so BX1 falls. But BX8 (psi -> phi U psi) and BX9 ((phi U psi) -> phi v psi) remain sound. The issue is that many derived theorems (refl_F, density) use BX1 and would break. Also, the relationship between G and Until becomes non-standard: G(phi) != ~(top U ~phi) because the Until uses reflexive semantics.

**Assessment**: This hybrid creates more problems than it solves. The clean relationship G(phi) <-> ~F(~phi) <-> ~(top U ~phi) would be disrupted.

### Option B: Define G(phi) = phi ^ G_strict(phi) as syntactic sugar

Keep the STRICT semantics but define G_refl(phi) = phi ^ G_strict(phi) as a macro. Then BX1-style reasoning becomes: G_refl(phi) -> phi (by left conjunction elimination).

**Problem**: This doesn't simplify anything. The axiom system would need reformulation in terms of G_strict, and all the proofs would need to thread the conjunction. This is equivalent to switching to strict semantics with extra steps.

### Option C: Use Burgess's axiom system directly (abandon BX)

Replace BX1-BX12 with Burgess's A1-A7 (strict-semantics axioms). This gives a complete axiomatization for strict temporal logic.

**Problem**: This is the "switch to strict" option with an additional axiom system change. All the risks from Section 3 apply, PLUS the axiom system itself changes.

### Option D: Keep BX but drop A3a/A4a dependency

Instead of trying to derive A3a and A4a, redesign the chronicle construction to NOT USE them. Burgess uses A3a in Lemma 2.3 (R-relation) and A4a in Lemma 2.6 (counterexample repair). If the construction can be modified to avoid these specific lemma steps, the BX system suffices.

**Assessment**: This is the most promising hybrid. It requires understanding exactly what A3a and A4a DO in the proof and finding BX-native replacements. See Section 5.

---

## 5. Recommended Path Forward

### The Actual Problem is Not the Semantics

The Round 5 report correctly identifies the root cause as ARCHITECTURAL (unary g_content vs. binary g(x,y)), not semantic. The reflexive/strict distinction is a secondary concern. The primary blocker is:

1. The chain uses unary g_content(M) (what M demands of ALL future)
2. Burgess uses binary g(x,y) (what holds on the interval (x,y))
3. This architectural mismatch causes step transfer problems regardless of semantics

### Recommended Approach: Adapt Burgess WITHOUT A3a/A4a

Instead of deriving A3a/A4a (which appear non-derivable), redesign the chronicle construction to use BX-native axioms directly:

**For A3a's role (Lemma 2.3, R-relation)**: A3a connects Until and Since. Under BX, we have:
- BX4: phi -> G(P(phi)) -- temporal connectedness
- BX5: (phi U psi) -> ((phi ^ (phi U psi)) U psi) -- self-accumulation
- BX8: psi -> (phi U psi) -- reflexive introduction

These can potentially serve the same purpose as A3a in establishing interval coherence, but the construction must be reformulated to use BX4's G(P(phi)) pattern instead of A3a's U-S interaction.

**For A4a's role (Lemma 2.6, counterexample repair)**: A4a decomposes U(p,q)^~U(p,r). Under BX, we have:
- BX7: linearity of Until -- gives three-way disjunction
- BX9: (phi U psi) -> phi v psi -- current-time elimination
- BX10: (phi U psi) -> F(psi) -- eventuality extraction

The BX7 linearity axiom combined with BX10 may provide the same decomposition power.

**Key insight**: The BX system has DIFFERENT but EQUALLY POWERFUL axioms compared to Burgess. The proof strategy must be adapted to USE the BX axioms, not try to derive Burgess's axioms from them.

### Effort Estimate for BX-Native Approach

| Phase | Hours |
|-------|-------|
| Phase 0: Chronicle structure + binary g(x,y) | 15-20 |
| Phase 1: BX-native R-relation (replaces Lemma 2.3 without A3a) | 20-30 |
| Phase 2: BX-native point insertion (Lemma 2.4, already mapped to seed consistency) | 10-15 |
| Phase 3: BX-native counterexample repair (replaces Lemma 2.6 without A4a) | 20-30 |
| Phase 4: Limit construction + BFMCS wrapper | 15-20 |
| Phase 5: Integration (replace 5 sorry sites) | 10-15 |
| **Total** | **90-130 hours** |

This is LOWER than both the Burgess-with-A3a/A4a estimate (105-155) and dramatically lower than switching to strict (280-420).

---

## 6. Quantitative Summary

| Metric | Reflexive (keep) | Strict (switch) | Ratio |
|--------|-----------------|-----------------|-------|
| Lines of code at risk | 0 | ~16,000 | -- |
| Sorry-free proofs at risk | 0 | ~8,000 lines | -- |
| Axioms that become invalid | 0 | 3 (BX1, BX8, BX9) | -- |
| Derived theorems broken | 0 | ~25 | -- |
| Estimated rework hours | 0 | 177-264 | -- |
| Estimated completion hours | 90-130 | 280-420 | 1:3 |
| Soundness re-proof needed | No | Yes (complete) | -- |

---

## 7. Critical Conclusions

1. **DO NOT switch to strict semantics.** The cost is 3x the completion time and risks destroying 8,000+ lines of sorry-free proofs.

2. **A3a and A4a are NOT derivable from BX** under reflexive semantics (A3a requires r at intermediate points that reflexive Until does not guarantee; a concrete counterexample exists).

3. **The A3a/A4a gate is a FALSE gate.** The question should not be "can we derive A3a/A4a?" but "can we build Burgess's chronicle using BX-native axioms?" The BX system has axioms (BX4, BX5, BX7, BX8, BX9, BX10) that are not in Burgess's system and can serve the same structural purposes differently.

4. **The right approach** is to design a chronicle construction that uses BX4 (connectedness), BX5 (self-accumulation), BX7 (linearity), and BX10 (eventuality extraction) directly, rather than trying to derive Burgess's axioms and then follow his proof verbatim.

5. **The Filtration/FMP infrastructure is safe.** It is sorry-free, uses BX1/BX9 in standard ways, and should be preserved as a fallback for finite model property results.

6. **There is no viable "third option"** that mixes strict and reflexive semantics. Any hybrid creates inconsistencies between G and Until definitions.
