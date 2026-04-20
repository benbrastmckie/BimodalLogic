# Teammate D Findings: Round 47 - Horizons (Strategic Assessment)

**Task**: 93 - Complete BXCanonical embedding
**Date**: 2026-04-19
**Role**: Horizons (strategic assessment, quasimodel concatenation, long-term alignment)
**Session**: Round 47 team research

---

## Key Findings

### 1. ROADMAP Assessment

No `specs/ROADMAP.md` file exists. Cross-task dependency information is embedded in TODO.md and state.json. Based on the round 46 synthesis and code review:

**Tasks currently blocked by task 93:**
- Task 18 (`dense_representation_theorem`) — needs base completeness first
- Task 95 (#print axioms audit) — can be partially run now to document sorry dependencies, but cannot reach the target `{propext, Classical.choice, Quot.sound}` output

**Tasks that can proceed independently:**
- Task 64 (critical path review) — independent
- Task 68 (dense completeness via rationals) — different canonical model
- Task 82 (FMP TruthPreservation) — appears to already be sorry-free (boneyard archive)
- Task 89 (eventuality sorries in Frame) — Frame.lean has only one sorry (modal witness)
- Task 104 (cleanup) — independent
- Task 105 (comment updates) — independent

**Semantics choice impact on downstream tasks:**
Switching from reflexive to irreflexive semantics affects ALL tasks through the axiom system. Task 18 (dense representation) uses the same BX axiom base — if BX1 (`G(p) -> p`) is removed, the dense completeness proof must also be revised. However, the user has indicated this is preferred. See section 3 for detailed analysis.

### 2. Quasimodel Chain Concatenation: Deep Study

The sorry-free quasimodel infrastructure in `Construction.lean` (887 lines) produces finite chains via `hintikka_chain_exists`. The question from round 46 was: can these finite chains be concatenated/periodically extended to cover all of Int?

**Construction.lean chain structure:**
- `QuasimodelChain`: finite list of HintikkaPoints, consecutive pairs satisfy `hintikka_step`
- `hintikka_chain_exists`: given a step oracle + initial point, produces finite chain ending with witness
- Chain terminates because `defect_count` strictly decreases (bounded by |Sigma|)
- Maximum chain length: |Sigma| = |SubformulaClosure(target)|

**The sigma-signature cycling idea:**
The key insight from round 46: sigma-signatures (assignments of Sigma formulas to Boolean values consistent with BX axioms) are finite — bounded by `2^|Sigma|`. Any infinite sequence of HintikkaPoints from `sigma_signature` calls must eventually repeat a sigma-signature. This periodicity can be leveraged:

```
Finite quasimodel chain: h0 -> h1 -> ... -> hN (resolves all Until/Since defects)
sigma-signature cycling: after at most 2^|Sigma| steps, sigma_sig(h_i) = sigma_sig(h_j) for i < j
Periodic extension: define chain(k) = chain(k mod period) for k >= some threshold
```

**Critical analysis of whether this works:**

POSITIVE: The `SigmaOrdering.lean` infrastructure (179 lines, sorry-free) already defines `sigma_le`, `sigma_strict`, and `sigma_equiv`. The `sigma_equiv` relation captures exactly the "same sigma-signature" condition. If two BXPoints have the same sigma-signature, they are semantically indistinguishable at the Sigma level.

NEGATIVE (the key obstruction): For periodic extension to give a valid TaskModel, the temporal ordering on the extended chain must be a LINEAR ORDER (no cycles). A periodic chain like `h0 -> h1 -> ... -> hN -> h0 -> h1 -> ...` creates a CYCLE in the temporal ordering, which violates linearity. The TaskModel requires `Int` as the time domain (a linear order without cycles).

**Resolution attempt — aperiodic extension:**
Instead of cycling back to h0, one could REPEAT the finite chain infinitely but with fresh BXPoints at each copy:
```
Level 0: h0 -> h1 -> ... -> hN
Level 1: h0' -> h1' -> ... -> hN' (with h0' >= hN, same sigma-signature as h0)
Level 2: h0'' -> h1'' -> ... -> hN'' (same pattern)
...
```

This requires:
1. Constructing fresh BXPoints with the same sigma-signature (possible via Lindenbaum extension)
2. Connecting hN to h0' via `bx_le` (this requires sigma_sig(hN) to contain g_content compatible with sigma_sig(h0'))
3. Proving the whole Int-indexed chain satisfies restricted temporal coherence

**Why this is harder than it looks:**
The connection step (hN to h0') requires sigma_sig(hN).g_content ⊆ sigma_sig(h0'). But sigma_sig(hN) has discharged all Until/Since defects (that's the point), so it may contain G-formulas that are NOT in sigma_sig(h0). This breaks the periodic extension: the "fresh copy" h0' must contain everything from g_content(hN), which may differ from g_content(h0).

**Conclusion on quasimodel concatenation:**
The sigma-signature cycling idea works for establishing the EXISTENCE of infinitely many BXPoints related by `bx_le` (this follows from `qm_oracle_step_bx_le` applied repeatedly). What fails is converting this into an Int-indexed chain with the correct temporal coherence properties (restricted_tc, restricted_buc, restricted_fuc). The same obstructions from the round 46 `dd_chain` architecture reappear, just at a different level.

**Confidence this unblocks task 93: 20-30%.** The approach is mathematically interesting but has its own form of the Lindenbaum opacity problem.

### 3. Literature Alignment: Reflexive vs Irreflexive Semantics

**Standard literature preference:**

The Burgess (1982) paper "Axioms for Tense Logic I: Since and Until" (Notre Dame J. Formal Logic 23, 367-374) uses STRICT (irreflexive) semantics for Until/Since. The axioms from that paper do NOT include `G(p) -> p` (reflexivity of G) because G is also strict: `G(p)` means "at all STRICTLY FUTURE times, p".

The Xu (1988) extension follows the same convention. The Gabbay-Hodkinson-Reynolds (1994) "Temporal Logic" textbook uses irreflexive semantics throughout Part I (linear time).

**The IRR rule in GHR 1994:**
The Irreflexivity Rule (IRR) has form: from `(p ∧ H¬p) → φ` derive `φ`, where p is a fresh atom not occurring in φ. This forces irreflexivity of the temporal accessibility relation. Key facts:
- IRR is used to PROVE completeness for the strict/irreflexive temporal operators
- IRR is admissible (does not extend the theorem set if the logic is already complete without it)
- Reynolds (1992) "An axiomatization for Until and Since over the reals without the IRR rule" (Studia Logica 51, 165-193) showed IRR is NOT NEEDED for completeness over the reals — but this is for the REAL number line, not arbitrary linear orders

**The existing IRR rule in this project:**
The project ALREADY has an IRR rule! It is implemented in `ExtDerivationTree` (ConservativeExtension/ExtDerivation.lean) and proven sound in `IRRSoundness.lean` (referenced in Soundness.lean). The conservative extension infrastructure (ExtFormula.lean, ExtDerivation.lean, Lifting.lean, Substitution.lean) implements exactly the GHR 1994 approach: extend to a logic with a fresh atom, use IRR to prove a stronger result, then lift back.

**CRITICAL FINDING**: The IRR rule is already implemented and proven sound. The question is whether it can be USED to close the completeness sorry sites. Previous rounds investigated this but the verdict from round 46 was: IRR soundness under reflexive semantics is unverified. With IRREFLEXIVE semantics, this concern disappears — IRR is designed for irreflexive temporal logic.

### 4. Strategic Analysis of Switching to Irreflexive Semantics

**What "irreflexive semantics" means for this project:**

Current reflexive semantics (BX system):
- `G(p)` means "at all times ≥ t (including t), p holds" — semantics: `∀ s ≥ t, p(s)`
- `p U q` means "there exists s ≥ t with q(s) and for all t ≤ r < s, p(r)" — reflexive witness
- BX1: `G(p) → p` — valid because s = t is included
- BX8: `q → (p U q)` — valid because s = t witness works

Irreflexive semantics (strict system):
- `G(p)` means "at all times > t (strictly future), p holds" — semantics: `∀ s > t, p(s)`
- `p U q` means "there exists s > t with q(s) and for all t < r < s (or r = t?), p(r)" — strict witness
- BX1 (`G(p) → p`) is NOT valid — G(p) says nothing about the CURRENT time
- BX8 (`q → (p U q)`) is NOT valid — the witness must be strictly future
- New axiom needed: `G(p) → F(p)` or similar seriality axiom

**In what sense is irreflexive "more expressive"?**

The Stanford Encyclopedia confirms: strict (irreflexive) Until/Since are more expressive than reflexive variants. Specifically:
1. On forward-discrete linear orders, strict U/S allow defining the NEXT operator X: `X(p) = ¬p U p` (the first strictly future time where p holds, with ¬p holding until then). This is NOT possible with reflexive U/S.
2. Reflexive U/S can be DEFINED from strict U/S: `p U_refl q = q ∨ (p U_strict q)` (either q holds now, or there's a strictly future q with p until then).
3. But strict U/S CANNOT be defined from reflexive U/S alone (no finite combination works on all linear orders).

Therefore: strict/irreflexive is a STRICTLY more expressive semantics. A complete axiomatization for irreflexive semantics immediately gives completeness for reflexive semantics (reflexive U is just a special case), but not vice versa.

**Axiom changes required:**

Dropping from reflexive to irreflexive:
- Remove BX1 (`temp_t_future`, `temp_t_past`): `G(p) → p`
- Remove BX8 (`refl_intro_until`, `refl_intro_since`): `q → (p U q)`
- Remove BX9 (`until_elim`, `since_elim`): `(p U q) → (p ∨ q)` — this requires s ≥ t but strict Until doesn't guarantee this

Add for irreflexive system:
- Seriality: `F(⊤)` — there is always a strictly future time (open-ended order)
- Strict Until expansion: `(p U q) ↔ q ∨ (p ∧ F(p U q))` — strict inductive characterization
- G-seriality: `G(p) → F(G(p))` — past is not the only time G holds

**Does switching make completeness EASIER?**

YES, in one specific way: the IRR rule (already implemented in this project) is designed for IRREFLEXIVE temporal logic. The standard proof of completeness for irreflexive Since/Until (Burgess 1982, GHR 1994) uses:
1. Extend to logic with fresh atom p (new variable not in φ)
2. Apply IRR: from `(p ∧ H¬p) → φ` derive φ
3. The formula `(p ∧ H¬p)` holds exactly at the FIRST moment in p's history — this simulates "now is the beginning" and makes the temporal structure well-founded
4. Prove completeness in the extended logic (easier because the fresh atom marks the beginning)
5. Lift back via conservative extension

This project has STEPS 4 AND 5 already implemented (IRR soundness + conservative extension). Step 1-3 is the IRR rule in `ExtDerivationTree`. What has NOT been done is step 4: the actual completeness proof in the extended irreflexive logic. But the infrastructure is ready.

**Effect on the 5 sorry sites:**

The 5 sorry sites are in `RootScopedChain.lean`, all in `dd_bfmcs_restricted_tc`, `dd_bfmcs_restricted_buc`, `dd_bfmcs_restricted_fuc`. These depend on the `dd_chain` architecture (round-robin forward/backward chains). With irreflexive semantics, the chain architecture would need to change anyway (no more reflexive witnesses), so the sorry sites would be RE-WRITTEN rather than simply fixed.

The GOOD NEWS: under strict semantics, the until-unfolding axiom `(p U q) → q ∨ (p ∧ F(p U q))` is PROVABLE from the strict axioms (unlike the reflexive case where it required the IR gap). This directly addresses sorry #4 (`restricted_buc`) and sorry #5 (`restricted_fuc`), which were blocked by an axiom gap.

### 5. Long-Term Project Alignment

**Effect on soundness (already proved):**
Soundness.lean is sorry-free. Switching to irreflexive semantics would require revising ALL soundness lemmas because the semantic clauses for G, H, U, S change. This is substantial work (Soundness.lean is ~1,140 lines). However, the STRUCTURE of the soundness proof is preserved — the same induction and the same proof patterns apply, just with strict inequalities.

**Effect on decidability results:**
Decidability (if proved) would be unaffected. Both reflexive and irreflexive Since/Until temporal logic over linear orders are decidable. The quasimodel/filtration approach works for both.

**Supporting BOTH semantics:**
This is possible via a PARAMETRIC approach: define a parameter `sem : Bool` where `False` = reflexive, `True` = strict. The semantic clauses branch on `sem`. The axiom system is parametrized similarly. This is non-trivial but architecturally clean. However, the user's preference for irreflexive suggests this dual approach is not needed.

**Can reflexive completeness be derived from irreflexive completeness?**
YES, in principle:
1. Prove `irreflexive_completeness : ¬provable_strict(φ) → ∃ countermodel_strict(φ)`
2. Note: `reflexive_semantics ⊆ strict_semantics` (any strict model is also a reflexive model, after adjusting the semantics)
3. Define `reflexive_from_strict : strict_countermodel → reflexive_countermodel` via the translation `p U_refl q = q ∨ (p U_strict q)`
4. Conclude `reflexive_completeness`

This reduction works mathematically but requires formalizing the translation between semantics — another 200-400 lines of Lean code.

### 6. Creative/Unconventional Approaches

**Approach A: Prove irreflexive completeness first, derive reflexive as corollary**

Strategy:
1. Revise axioms to remove BX1, BX8, BX9 (reflexive axioms); add strict system axioms
2. Use the existing IRR rule infrastructure to prove completeness in the extended strict logic
3. Apply conservative extension (Lifting.lean) to lift back to base strict logic
4. Derive reflexive completeness via the `q ∨ (p U_strict q) = p U_refl q` translation

Estimated effort: 600-1000 lines of new code (axiom revision + strict completeness + translation)
Confidence: 50-60%. The IRR rule infrastructure exists and is sound. The strict axiom system is well-studied.

**Approach B: Use `bx_forward_witness` + `bx_backward_witness` directly**

These are sorry-free (Frame.lean:164, 176). They provide:
- `bx_forward_witness`: F(ψ) ∈ w → ∃ v ≥ w, ψ ∈ v
- `bx_backward_witness`: P(ψ) ∈ w → ∃ v ≤ w, ψ ∈ v

The Goldblatt approach uses these directly in the truth lemma without building a chain. For Until: `p U q ∈ w → F(q) ∈ w → ∃ v ≥ w, q ∈ v`. The guard `p` at all intermediate points requires the BX5/BX10/BX11 argument. This is precisely what `bx_until_eventuality_resolution` in Frame.lean claims to prove — but it has an unsound signature (the guard property cannot be established without a fixed intermediate chain).

Under irreflexive semantics, the Until truth lemma direction (from MCS membership to semantic truth) would use strict witnesses and the strict axioms — which remove the guard issue because `p U q` at t under strict semantics is a strictly-future witness, not a possibly-present one.

**Approach C: Int chain with fresh-atom periodicity**

Use the IRR rule's fresh atom p to mark the "beginning" of each finite quasimodel chain block. Define:
```
chain(k) for k in Z:
  - for k >= 0: use the forward quasimodel chain from Construction.lean
  - for k < 0: use the backward (Since) quasimodel chain
  - p holds at k = 0 and nowhere else (fresh atom marks the beginning)
```

The IRR rule then says: anything provable in the extended logic (with fresh p marking the start) is provable in the base logic. This gives the temporal induction principle needed for F-eventuality (sorry #1).

This is exactly the GHR 1994 strategy applied to the existing quasimodel infrastructure.
Estimated effort: 300-500 lines
Confidence: 55-65% under irreflexive semantics, 30-40% under reflexive semantics (the BX1 interaction with fresh atom is the unresolved issue from round 46)

### 7. Recommended Strategy

**Primary recommendation: Switch to irreflexive semantics and use IRR rule with existing infrastructure.**

Rationale:
1. User preference: "irreflexive is even preferred as it is more expressive" — this is mathematically correct (confirmed by Stanford Encyclopedia and literature)
2. The IRR rule infrastructure is already implemented and sound (ConservativeExtension module)
3. Irreflexive semantics removes the BX1-BX8 interactions that created the guard obstruction in sorry #4-5
4. Standard literature (Burgess 1982, GHR 1994) uses irreflexive semantics — switching aligns with proven completeness proof techniques
5. The Until unfolding axiom `(p U q) → q ∨ (p ∧ F(p U q))` is provable in strict systems, addressing the core axiom gap

**Execution path:**
1. (Phase 1, ~100 lines) Revise Axioms.lean: remove BX1 (temp_t_future/past), BX8 (refl_intro), BX9 (elim); add strict variants; add seriality axiom `F(T)`.
2. (Phase 2, ~200 lines) Revise Soundness.lean to match strict semantics. The structure is preserved, inequalities change from `≤` to `<`.
3. (Phase 3, ~100 lines) Use the IRR rule (already in ExtDerivationTree) plus Approach C above to construct the Int-indexed chain from quasimodel blocks.
4. (Phase 4, ~200 lines) Prove restricted coherence using the strict Until axiom (now provable).
5. (Phase 5, ~50 lines) Wire into `dd_countermodel` to close all 5 sorry sites.

**Alternative if Phase 1-2 are too disruptive: Apply IRR + quasimodel concatenation to the existing REFLEXIVE system.**

The IRR rule is sound under reflexive semantics (confirmed in Soundness.lean references). The IRR rule forces a STRICT beginning-of-time: `(p ∧ H¬p) → φ` uses `H¬p` (at all past times, ¬p), which is meaningful even in reflexive semantics (H is H-past, not including current time? No — H is also reflexive under current semantics). This is the soundness interaction that round 46 left unresolved.

Actually: under the current reflexive semantics, `H(¬p)` means "at all past-or-present times, ¬p". Combined with `p`, this means "p holds now AND ¬p holds at all times ≤ now" — contradiction! The IRR rule would be unsound (from contradiction, derive anything). This confirms round 46's concern.

Under IRREFLEXIVE semantics, `H(¬p)` means "at all STRICTLY PAST times, ¬p". Combined with `p`, this means "p holds now AND ¬p holds at all strictly past times" — consistent (p holds for the first time now). The IRR rule is sound.

This provides the definitive answer: **switching to irreflexive semantics is necessary for the IRR rule to be applicable**, and the IRR rule is the key to closing the completeness gap.

---

## Confidence Level

| Assessment | Confidence |
|------------|-----------|
| IRR rule is unsound under current reflexive semantics | 90% |
| Irreflexive semantics makes IRR rule sound | 95% |
| Standard literature (Burgess/GHR) uses irreflexive semantics | 95% |
| Switching to irreflexive semantics enables IRR-based completeness proof | 65% |
| Quasimodel concatenation (periodic extension) closes all 5 sorries | 20-30% |
| Switching semantics + IRR closes all 5 sorries in < 600 new LOC | 45% |
| Goldblatt restructure closes all 5 sorries | 45% |
| Current reflexive `dd_chain` architecture closes all 5 sorries | 5% |

---

## Summary

**The fundamental finding**: The IRR rule (already implemented in this project) is UNSOUND under the current reflexive semantics but becomes SOUND under irreflexive semantics. The user's preference for irreflexive semantics is mathematically justified (strictly more expressive) AND removes the core obstruction to using the IRR rule.

**Quasimodel concatenation**: The sigma-signature cycling idea is mathematically interesting but hits the same Lindenbaum opacity obstruction at a different level. The finite chains from `Construction.lean` cannot be naively periodically extended to Int without creating cycles in the temporal order. Aperiodic repetition is possible but requires fresh Lindenbaum extensions at each level — the same opacity problem returns.

**Recommended action**: Switch to irreflexive semantics (removing BX1, BX8, BX9; adding strict variants), then use the existing IRR rule infrastructure to construct an Int-indexed chain via temporal induction (Approach C). This aligns with the standard Burgess/GHR proof technique, uses existing sorry-free infrastructure, and directly addresses the sorry sites' root causes.

**Cross-task impact of semantics switch**:
- Task 18 (dense completeness): Requires revision of dense axioms for irreflexive system
- Task 68 (dense completeness via rationals): Uses same base — needs revision
- Task 89 (eventuality sorries): Benefits from strict semantics (strict witnesses simpler)
- Soundness.lean (1,140 lines): Requires revision but structural work preserved
- All quasimodel infrastructure: Remains valid (HintikkaPoints, defect-discharge work in both semantics)

**Long-term**: An irreflexive completeness proof + reduction to reflexive (via `p U_refl q = q ∨ (p U_strict q)`) would provide BOTH results with less total effort than direct reflexive completeness.
