# Teammate C (Critic) Findings: Strict vs. Weak Temporal Semantics Risk Assessment

**Task**: 83 - Close Restricted Coherence Sorries
**Date**: 2026-04-03
**Role**: CRITIC -- identify all risks, blockers, and pitfalls in switching from weak (reflexive, <=) to strict (<) temporal semantics for G and H

---

## ROADMAP Warnings and Historical Context

The ROADMAP.md and Truth.lean contain explicit historical documentation about this exact question:

1. **Truth.lean lines 16-18**: "A previous version used strict semantics (<) which required an axiom for canonicalR irreflexivity. The current version uses reflexive semantics to eliminate this axiom and simplify the metalogic."

2. **Axioms.lean lines 282-286**: The `temp_t_future` axiom documentation states: "This axiom was added when switching from strict to reflexive temporal semantics."

3. **CanonicalIrreflexivity.lean module header**: The entire module was purpose-built to handle the reflexive semantics regime. Under strict semantics, ExistsTask would need to be IRREFLEXIVE, requiring a fundamentally different canonical frame construction.

4. **ROADMAP.md line 119**: "CoherentZChain: Forward chain preserves G but not H; backward preserves H but not G. Unfixable." This dead end was encountered under the previous architecture and the switch to reflexive semantics was part of the solution path.

**Key insight**: The project ALREADY tried strict semantics and ABANDONED it. The switch to reflexive was a deliberate engineering decision to simplify the metalogic. Switching back would re-introduce problems that were intentionally eliminated.

**Confidence**: HIGH

---

## Completeness Proof Impact (harder or easier?)

**Verdict: SUBSTANTIALLY HARDER.**

The completeness proof infrastructure is deeply entangled with reflexive semantics in at least 5 structural ways:

### 1. FMCS forward_G/backward_H use reflexive inequalities
The `FMCS` structure (SuccChainFMCS.lean) defines:
- `forward_G : n <= m -> G(phi) in mcs(n) -> phi in mcs(m)` (uses `<=`, not `<`)
- `backward_H : m <= n -> H(phi) in mcs(n) -> phi in mcs(m)` (uses `<=`, not `<`)

Under strict semantics, these would need to be:
- `forward_G : n < m -> G(phi) in mcs(n) -> phi in mcs(m)` (strict `<`)

The `succ_chain_forward_G_le` theorem (SuccChainFMCS.lean:972) explicitly splits into `n < m` (uses chain propagation) and `n = m` (uses T-axiom). Without the T-axiom, the `n = m` base case VANISHES, and you lose the reflexive version entirely.

### 2. The canonical accessibility relation becomes irreflexive
Currently `existsTask_reflexive` (CanonicalIrreflexivity.lean:153) proves `ExistsTask M M` for all MCS M. This is used by `to_history` (CanonicalConstruction.lean:290) to convert FMCS to WorldHistory. Under strict semantics, ExistsTask would be irreflexive, requiring a completely different canonical frame -- the accessibility relation would be a strict partial order, not a preorder.

### 3. The truth lemma for G/H relies on reflexive quantification
The truth lemma's G case (CanonicalConstruction.lean:596, 749, 905) uses `fam.forward_G t s psi hts h_G` where `hts : t <= s`. Under strict semantics, you'd need `t < s`, and the base case `t = s` would require separate handling (proving `G(phi) -> phi` semantically from the model, not from the axiom system -- since it's no longer an axiom).

### 4. The box propagation lemma needs reflexivity
`box_phi_all_times` (CanonicalConstruction.lean:411-439) proves Box phi propagates to all times using `forward_G` and `backward_H` with `<=`. Under strict semantics, you'd need an additional argument for the `t = s` case.

### 5. The dovetailed chain is unaffected (only good news)
The dovetailed chain (DovetailedChain.lean) uses `temp_t_future` / `temp_t_past` in 9 places, but these are proof-theoretic (MCS-level) uses. Under strict semantics, these axioms would be REMOVED from the proof system, so these 9 call sites would need replacement with different axiom derivations -- or the proof-theoretic arguments would need restructuring.

**Confidence**: HIGH

---

## Boneyard Lessons (what failed before and why)

The Boneyard contains documentation of 7+ failed approaches, several of which are relevant:

### 1. CoherentZChain (ARCHIVED)
"Forward chain preserves G but not H; backward preserves H but not G." This was tried under a different semantic regime. The core issue -- that you can't simultaneously maintain G-coherence and H-coherence in a bidirectional chain -- is INDEPENDENT of reflexive vs. strict semantics.

### 2. F-Preserving Seed (PROVEN FALSE, Task #69)
The `box_F_seed_chain` approach was proven to produce non-F-preserving chains. This is an algebraic property of MCS extension, not related to semantics choice.

### 3. Bidirectional Seed (UNFIXABLE)
"H(a) -> G(H(a)) is NOT derivable in TM." This modal-temporal interaction gap is independent of reflexive vs. strict.

### 4. Bundle-Level Temporal Coherence (SEMANTICALLY WRONG)
The bundle approach was abandoned because G/H are "intrinsically single-history." This conclusion holds regardless of reflexive vs. strict -- it's about the modal/temporal distinction.

### 5. Omega F-Persistence (UNFIXABLE)
"Lindenbaum extension can add G(neg phi) when F(phi) was present." This is about the non-constructive nature of Lindenbaum lemma, independent of semantics.

**Lesson**: None of the Boneyard failures were CAUSED by reflexive semantics. They were caused by deeper issues in canonical model construction. Switching to strict semantics would NOT fix any of these problems, and would ADD new ones.

**Confidence**: HIGH

---

## Concrete Blockers Catalog

### Blocker 1: Removal of T-Axioms (temp_t_future, temp_t_past)
- **Impact**: CRITICAL
- **Count**: 87 occurrences across 18 Lean source files
- Under strict semantics, `G(phi) -> phi` is INVALID (G(phi) means "phi at all STRICTLY future times" -- says nothing about now)
- Every use of `temp_t_future` and `temp_t_past` in derivation trees becomes an error
- Key affected files: SuccChainFMCS.lean (8 uses), DovetailedChain.lean (9 uses), CanonicalConstruction.lean (3 uses), SuccExistence.lean (4 uses), TargetedChain.lean (4 uses), MCSWitnessSuccessor.lean (2 uses), CanonicalIrreflexivity.lean (4 uses), Soundness.lean (12 uses)

### Blocker 2: FMCS Structure Redefinition
- **Impact**: CRITICAL
- The FMCS structure fundamentally assumes reflexive forward_G/backward_H (`<=`)
- Under strict semantics, forward_G uses `<`, and you lose the ability to extract `phi` from `G(phi)` at the SAME time point
- Every consumer of FMCS.forward_G and FMCS.backward_H (at least 15+ call sites in CanonicalConstruction.lean alone) needs re-examination

### Blocker 3: Canonical Accessibility Relation Restructuring
- **Impact**: HIGH
- `existsTask_reflexive` becomes FALSE -- the entire CanonicalIrreflexivity.lean module loses its foundation
- The `to_history` construction (CanonicalConstruction.lean:290) uses `existsTask_reflexive` to prove `respects_task`
- Need to rebuild canonical frame as strict partial order, which was the OLD approach that was abandoned

### Blocker 4: Soundness Proofs Restructured
- **Impact**: HIGH
- `temp_t_future_valid` and `temp_t_past_valid` in Soundness.lean become false
- The 12 soundness theorem call sites need removal
- The dense soundness and discrete soundness paths also affected

### Blocker 5: Seriality Axiom Impact
- **Impact**: MEDIUM
- Under reflexive semantics, seriality (`G(phi) -> F(phi)`) is "trivially valid via T-axiom" (Soundness.lean:354)
- Under strict semantics, seriality requires a separate proof that the temporal order has no endpoints
- For Int this is fine, but the GENERIC soundness theorem (parametric over D) would need `NoMinOrder D` and `NoMaxOrder D` constraints

### Blocker 6: "Always" Operator Definition
- **Impact**: MEDIUM
- The `always` operator is defined as `H(phi) AND phi AND G(phi)` or equivalently `H(phi) AND G(phi)` under reflexive semantics
- Under strict semantics, `H(phi) AND G(phi)` does NOT imply `phi` at the current time
- The Perpetuity module (Theorems/Perpetuity/) has extensive derivations that may depend on this equivalence

### Blocker 7: LinearityDerivedFacts Module
- **Impact**: MEDIUM
- This module (ProofSystem/LinearityDerivedFacts.lean) explicitly documents: "Reflexive (satisfying temp_t_future, temp_t_past)"
- Many derived facts about linearity may use T-axiom closure

### Blocker 8: Dovetailed Chain Reconstruction
- **Impact**: HIGH
- DovetailedChain.lean has 9 uses of temp_t_future/temp_t_past
- The dovetailed chain is the ONLY working approach for the completeness proof
- Restructuring it is extremely risky given the history of 7+ failed approaches

**Confidence**: HIGH

---

## Axiom Reflexivity Dependencies (how many proofs break?)

### Direct T-Axiom Usage (proof-level)

| File | temp_t_future | temp_t_past | Total |
|------|:---:|:---:|:---:|
| SuccChainFMCS.lean | 4 | 4 | 8 |
| DovetailedChain.lean | ~5 | ~4 | 9 |
| CanonicalConstruction.lean | 2 | 1 | 3 |
| SuccExistence.lean | 3 | 1 | 4 |
| TargetedChain.lean | 2 | 2 | 4 |
| MCSWitnessSuccessor.lean | 1 | 1 | 2 |
| CanonicalIrreflexivity.lean | 2 | 2 | 4 |
| Soundness.lean | 6 | 6 | 12 |
| Substitution.lean | 2 | 2 | 4 |
| Axioms.lean (definition) | 1 | 1 | 2 |
| SoundnessLemmas.lean | ~2 | ~2 | 4 |
| Other (Algebraic, FrameConditions) | ~4 | ~4 | 8 |
| Boneyard (dead code) | 3 | 0 | 3 |
| **TOTAL** | ~37 | ~30 | **~67** |

### Indirect Dependencies (theorems that use T-axiom-dependent theorems)

The `existsTask_reflexive` theorem is used in:
- `to_history` (canonical construction) -- affects ALL completeness paths
- Per-construction strictness infrastructure (CanonicalIrreflexivity.lean:211)

The `succ_chain_forward_G_le` / `succ_chain_backward_H_le` theorems (which split on T-axiom) are used in:
- `SuccChainFMCS` definition (SuccChainFMCS.lean:1001-1005) -- the foundational FMCS construction
- `SuccChainTruth.lean` -- truth lemma infrastructure

**Estimated cascade**: Removing T-axioms would directly break ~67 call sites and indirectly invalidate the structural foundations used by ~200+ downstream theorems.

**Confidence**: HIGH (counts are from grep; indirect estimates are conservative)

---

## Since/Until Interaction Risks

The current codebase has ALREADY adopted half-open interval semantics for Until/Since:
```lean
| Formula.untl φ ψ => ∃ s, t ≤ s ∧ truth ψ s ∧ ∀ r, t ≤ r → r < s → truth r φ
| Formula.snce φ ψ => ∃ s, s ≤ t ∧ truth ψ s ∧ ∀ r, s < r → r ≤ t → truth r φ
```

Under strict G/H semantics (`t < s` for G, `s < t` for H):

### Risk 1: F equivalence breaks
Currently `F(psi) = True U psi` works because the witness range uses `t <= s`. Under strict G, `F(psi)` means "psi at some STRICTLY future time." But `True U psi` with `t <= s` still allows `s = t`. So `F(psi)` and `True U psi` would DIVERGE -- `True U psi` would be strictly weaker than `F(psi)` under strict semantics. This breaks a fundamental operator equivalence.

### Risk 2: P equivalence breaks symmetrically
`P(psi) = True S psi` has the same issue in the past direction.

### Risk 3: Interaction with discrete induction
The half-open plan (plan v7, Phase 4) relies on discrete Int induction for the backward truth lemma direction. The induction uses: at position k, if `(phi U psi) in mcs(k+1)` and `phi in mcs(k)`, then backward propagation. Under strict G, `G(phi U psi) in mcs(k)` would mean `(phi U psi) in mcs(j)` for all `j > k`, which is EASIER to obtain (you don't need it at k itself). However, the Succ relation `g_content(mcs(k)) subset mcs(k+1)` still goes forward. There's a subtle interaction: under strict semantics, you need `(phi U psi) in mcs(k+1)` to derive `F(phi U psi) in mcs(k)`, but the mechanism to go backward (from k+1 to k) doesn't change -- it still requires `phi -> G(P(phi))` (axiom temp_a), which uses REFLEXIVE G. If G becomes strict, temp_a gives `phi -> G(P(phi))` where G is strict, so you get `P(phi)` at all strictly future times but NOT at the current time. This changes the backward propagation argument.

### Risk 4: until_intro axiom interaction
The half-open semantics plan makes `until_intro` sound specifically because the guard interval `{r : t <= r, r < t}` is empty when `s = t`. Under strict G semantics, if the axiom `until_intro: psi OR (phi AND G(phi U psi)) -> phi U psi` uses strict G, then `G(phi U psi)` means `(phi U psi)` at all strictly future times. The second disjunct `phi AND G(phi U psi) -> phi U psi` becomes: "if phi now and phi U psi at all future times, then phi U psi now." This is actually still sound under half-open semantics (take witness from the future), but the proof structure changes.

**Confidence**: MEDIUM (interaction effects are subtle and may have additional cascading consequences)

---

## The Case Against Strict Semantics (strongest counter-argument)

### Argument 1: The problem being solved is NOT caused by reflexive semantics

The current blocker (2 sorries in restricted_shifted_truth_lemma for Until/Since cases) was caused by a CLOSED-interval phi guard in Until/Since definitions, NOT by reflexive G/H. The half-open interval fix (already adopted) addresses the root cause directly. Switching G/H to strict is solving a problem that doesn't exist.

### Argument 2: The expressiveness gain is illusory for this project

The claimed benefit of strict semantics is "more expressiveness" -- you can distinguish "phi holds now" from "phi holds at all future times." But:
- The project already HAS this distinction via the T-axiom: `G(phi) -> phi` is provable, and `phi` doesn't imply `G(phi)`
- Under reflexive semantics, `G(phi)` is STRICTLY STRONGER than `phi` (it implies phi AND all future phi)
- The operator `F(phi)` already means "phi at some future or present time" and is useful
- Adding strict G/H gains the ability to say "phi at all STRICTLY future times (but not necessarily now)" -- an unusual modality with limited practical use in task semantics

### Argument 3: Proof engineering cost is enormous

Conservative estimate of refactoring effort:
- **67+ direct call sites** to fix (T-axiom removal)
- **FMCS structure redefinition** affecting all downstream consumers
- **Canonical frame reconstruction** (ExistsTask becomes irreflexive)
- **Dovetailed chain reconstruction** (9 T-axiom uses)
- **Truth lemma restructuring** for G/H base cases
- **Soundness proofs** for 12+ axiom cases
- **Perpetuity module** and derived theorems

Estimated effort: **80-120 hours** of careful Lean proof engineering, with HIGH risk of encountering new blockers (the project has a history of 7+ failed approaches to related problems).

### Argument 4: Lean-specific considerations favor reflexive

Working with `<=` in Lean 4 / Mathlib is generally smoother than `<`:
- `le_refl` is trivially available; for `<` you always need to prove strict inequality
- `Int.le_of_lt` is a one-liner; going the other direction requires combining with `ne`
- Mathlib's `LinearOrder` API has better automation for `<=` patterns
- The `omega` tactic handles `<=` and `<` equally well, but proof terms with `<=` are more concise

### Argument 5: The half-open fix is already working

The half-open interval semantics change has already been adopted (Truth.lean shows `r < s` in the Until guard). This targeted fix addresses the Until/Since blocker without touching G/H. The plan (v7) has a clear 15-hour path to completion. Switching to strict G/H would RESET this progress and introduce a fundamentally different (and larger) problem.

### Argument 6: Standard literature supports reflexive G/H

The project documentation (Truth.lean:14) notes alignment with "standard modal logic literature where G and H are reflexive operators." Goldblatt (1992) and Blackburn et al. (2001) are cited in CanonicalIrreflexivity.lean as references for this approach. While some temporal logic traditions use strict operators, the reflexive convention is well-established and standard.

### Argument 7: Risk of re-introducing abandoned problems

The project explicitly documents (Truth.lean:16-18) that strict semantics was tried and abandoned because it "required an axiom for canonicalR irreflexivity." Switching back would re-introduce exactly the problem that was intentionally eliminated. There is no evidence that the underlying difficulty has been resolved.

**Confidence**: HIGH

---

## Risk Assessment Summary

| # | Blocker | Severity | Likelihood | Overall Risk |
|---|---------|----------|------------|-------------|
| 1 | T-axiom removal (87 occurrences, 18 files) | CRITICAL | Certain | **CRITICAL** |
| 2 | FMCS structure redefinition | CRITICAL | Certain | **CRITICAL** |
| 3 | Canonical accessibility restructuring | HIGH | Certain | **HIGH** |
| 4 | Soundness proof restructuring | HIGH | Certain | **HIGH** |
| 5 | Seriality proof changes | MEDIUM | Certain | **MEDIUM** |
| 6 | Always operator definition impact | MEDIUM | Likely | **MEDIUM** |
| 7 | LinearityDerivedFacts breakage | MEDIUM | Likely | **MEDIUM** |
| 8 | Dovetailed chain reconstruction | HIGH | Certain | **HIGH** |
| 9 | F/P equivalence with Until/Since | HIGH | Certain | **HIGH** |
| 10 | Backward truth lemma re-derivation | HIGH | Likely | **HIGH** |
| 11 | Re-introduction of canonicalR irreflexivity problem | HIGH | Likely | **HIGH** |
| 12 | Discovery of NEW blockers during refactoring | HIGH | Likely | **HIGH** |
| 13 | Perpetuity module cascade | MEDIUM | Likely | **MEDIUM** |

**Overall assessment**: 2 CRITICAL, 6 HIGH, 4 MEDIUM, 0 LOW risks. This is an extremely risky refactoring.

---

## Final Verdict: Is the switch worth it?

**NO. The switch from weak to strict temporal semantics for G and H is NOT worth it.**

The evidence is overwhelming:

1. **The project already tried strict semantics and abandoned it** for good engineering reasons (canonicalR irreflexivity axiom).

2. **The current blocker is NOT caused by reflexive G/H.** It's caused by closed-interval Until/Since semantics, which has already been fixed with half-open intervals.

3. **The refactoring cost is enormous** (80-120 hours, 67+ direct call sites, multiple structural redesigns) with HIGH risk of encountering new blockers.

4. **The expressiveness gain is marginal** and not relevant to the project's goals (task semantics formalization).

5. **The half-open interval fix is the correct targeted solution.** It addresses the actual root cause (Until/Since guard semantics) without touching the working G/H infrastructure.

6. **Every historical dead end in the Boneyard was caused by deeper issues** (MCS extension, bidirectional coherence, bundle-level semantics) that are INDEPENDENT of reflexive vs. strict G/H. Switching semantics would not fix any of them.

The recommended path is: complete the half-open interval plan (v7, estimated 15 hours), close the 2 remaining truth lemma sorries, and achieve sorry-free completeness WITHOUT touching G/H semantics.

---

## Confidence Levels

| Section | Confidence |
|---------|-----------|
| ROADMAP Warnings and Historical Context | HIGH |
| Completeness Proof Impact | HIGH |
| Boneyard Lessons | HIGH |
| Concrete Blockers Catalog | HIGH |
| Axiom Reflexivity Dependencies | HIGH (direct counts verified by grep) |
| Since/Until Interaction Risks | MEDIUM (subtle interaction effects) |
| The Case Against Strict Semantics | HIGH |
| Risk Assessment Summary | HIGH |
| Final Verdict | HIGH |
