# Research Report: Shift-Closure Requirement for Temporal/Tense Logic Completeness

**Task**: Ad-hoc research -- shift-closure for completeness with duration
**Started**: 2026-03-14
**Completed**: 2026-03-14
**Effort**: Deep mathematical analysis
**Dependencies**: Existing BFMCS infrastructure, D-from-syntax pipeline
**Sources/Inputs**: Codebase (Theories/Bimodal/), Goldblatt 1992, SEP Temporal Logic, prior research reports
**Artifacts**: This report

## Executive Summary

- **Shift-closure** is the property that if a world history tau belongs to Omega (the set of admissible histories), then for every duration Delta in D, the shifted history tau_Delta(t) := tau(t + Delta) also belongs to Omega.
- Shift-closure is **already defined** in the codebase as `ShiftClosed` in `Truth.lean` and is **already required** by `valid`, `semantic_consequence`, and `time_shift_preserves_truth`.
- Shift-closure is needed for completeness because the **box case** of `time_shift_preserves_truth` requires shifted histories to remain in Omega. Without it, the soundness of the MF (modal-future interaction) axiom fails.
- For the canonical model, shift-closure of CanonicalOmega is **automatic** from how FMCS families are defined -- the shifted FMCS family inherits all coherence conditions by translation invariance of the temporal ordering.
- The "same history" simplification for the truth lemma (quantifying over times in the same history rather than cross-history accessibility) is the approach already taken by BFMCS truth (`bmcs_truth_at`), and it works precisely because each FMCS represents a complete timeline.
- The key theorem to prove is: **if fam is a canonical FMCS, then fam_Delta (the shifted family) is also a canonical FMCS**.

## Context & Scope

### The Setting

We have a bimodal temporal logic TM with operators:
- **Box** (necessity): quantifies over all histories at a given time
- **G** (always future): quantifies over all strictly future times t' > t in the same history
- **H** (always past): quantifies over all strictly past times t' < t in the same history

The duration domain D is an ordered additive group. The semantic framework uses:
- A TaskFrame F with WorldState, task_rel, nullity, compositionality
- WorldHistories: functions from D to F.WorldState (with domain, convexity, task_rel respect)
- Omega: a set of admissible world histories (ShiftClosed)
- truth_at M Omega tau t phi: recursive truth evaluation

### The Completeness Goal

**Standard Completeness**: If Gamma does not prove phi (Gamma not-proves phi), then there exists a model where all of Gamma is true but phi is false.

The canonical model construction must produce:
1. A TaskFrame F
2. A TaskModel M (F + valuation)
3. A set Omega of WorldHistories (shift-closed)
4. A specific history tau_0 in Omega
5. A time t_0 such that all of Gamma is true and phi is false at (M, Omega, tau_0, t_0)

### What This Report Investigates

The precise role of shift-closure in making steps 3-5 work, with mathematical detail.

## Findings

### 1. What Is Shift-Closure? (Precise Definition)

**Definition (from Truth.lean, line 231)**:
```lean
def ShiftClosed (Omega : Set (WorldHistory F)) : Prop :=
  forall sigma in Omega, forall (Delta : D), WorldHistory.time_shift sigma Delta in Omega
```

Where `time_shift` is defined (WorldHistory.lean, line 236):
```lean
def time_shift (sigma : WorldHistory F) (Delta : D) : WorldHistory F where
  domain := fun z => sigma.domain (z + Delta)
  states := fun z hz => sigma.states (z + Delta) hz
  respects_task := [proven by translation invariance of t - s]
```

**Mathematical statement**: A set Omega of world histories is shift-closed iff for every sigma in Omega and every Delta in D, the shifted history sigma_Delta defined by sigma_Delta(t) := sigma(t + Delta) is also in Omega.

**Properties of time_shift (already proven in the codebase)**:
- Domain shifts: (time_shift sigma Delta).domain z iff sigma.domain (z + Delta)
- States shift: (time_shift sigma Delta).states z = sigma.states (z + Delta)
- Task relation respect is preserved (since t - s is invariant under translation)
- Convexity is preserved (since order is invariant under translation)
- Double shift cancels: time_shift (time_shift sigma Delta) (-Delta) has same states as sigma
- time_shift sigma 0 has same domain as sigma

### 2. Why Shift-Closure Is Needed for Completeness

Shift-closure is needed at **two distinct levels**:

#### Level A: Soundness of Axioms (time_shift_preserves_truth)

The theorem `time_shift_preserves_truth` (Truth.lean, line 344) states:
```
truth_at M Omega (time_shift sigma (y - x)) x phi <-> truth_at M Omega sigma y phi
```

This theorem is used to prove the MF (modal-future) and TF (temporal-future) interaction axioms sound. The **box case** of this proof is where ShiftClosed is needed:

**Box case (forward direction)**:
- Assume: for all rho in Omega, truth_at M Omega rho x phi (truth at shifted history)
- Need: for all rho in Omega, truth_at M Omega rho y phi (truth at original time)
- Strategy: Given rho in Omega, shift it by (y - x) to get time_shift rho (y - x) in Omega
- Apply the box hypothesis to this shifted rho
- Use the IH to transfer truth from x to y
- **Requires**: time_shift rho (y - x) in Omega, which is exactly ShiftClosed

**Box case (backward direction)**:
- Similar: given rho in Omega, shift by (x - y) to get time_shift rho (x - y) in Omega
- Then apply double-shift cancellation to get back

Without ShiftClosed, the bijection between "histories at time x" and "histories at time y" breaks down for the box modality. The temporal operators (G, H) do NOT need ShiftClosed because they quantify over times in the SAME history, not over different histories.

#### Level B: Canonical Model Must Be a Legitimate Model

For completeness, we build a counter-model. This model must be legitimate:
- It must be a proper TaskFrame (nullity, compositionality)
- Its Omega must be ShiftClosed
- Each history in Omega must be a proper WorldHistory (domain, convexity, task_rel respect)

The definition of `valid` (Validity.lean) and `semantic_consequence` both quantify over ALL shift-closed Omega:
```lean
def valid (phi : Formula) : Prop :=
  forall D ... (Omega : Set (WorldHistory F)) (h_sc : ShiftClosed Omega) ..., truth_at M Omega tau t phi
```

So when we prove completeness contrapositively (not-valid implies not-provable, or equivalently, provable implies valid), we must show validity holds for ALL shift-closed Omega. Conversely, to REFUTE validity (build a counter-model), we can choose ANY shift-closed Omega. But we must choose one that IS shift-closed.

#### Level C: The Counter-Model Construction

The completeness argument:
1. Gamma not-proves phi
2. Gamma union {neg phi} is consistent
3. Extend to MCS w_0 containing Gamma union {neg phi} (Lindenbaum)
4. Build a canonical FMCS fam_0 with fam_0(0) = w_0
5. Build a canonical TaskFrame F
6. Build Omega = CanonicalOmega = {all canonical histories}
7. Build valuation V from MCS membership
8. Show: truth_at M CanonicalOmega tau_0 0 psi iff psi in w_0 for all psi (truth lemma)
9. Conclude: all of Gamma is true but phi is false at (M, CanonicalOmega, tau_0, 0)

Step 6 requires CanonicalOmega to be ShiftClosed. If it is not, then `valid` quantifies over shift-closed Omega and our counter-model does not match the quantifier.

### 3. The BFMCS Approach vs. The Standard History Approach

The current codebase uses **two different semantics**:

**Standard semantics** (Truth.lean): truth_at M Omega tau t phi
- Box quantifies over ALL histories in Omega
- G/H quantify over times in the SAME history tau
- Requires ShiftClosed Omega for time_shift_preserves_truth

**BFMCS semantics** (BFMCSTruth.lean): bmcs_truth_at B fam t phi
- Box quantifies over all FMCS families in the bundle B
- G/H quantify over times in the SAME family fam
- Does NOT directly use ShiftClosed (because it does not use WorldHistory/Omega)

The BFMCS truth lemma is ALREADY PROVEN (sorry-free for the truth lemma itself). It shows:
```
phi in fam.mcs t <-> bmcs_truth_at B fam t phi
```

**The gap**: The BFMCS semantics and the standard semantics are NOT yet connected. To prove standard completeness, one must either:
(a) Show BFMCS semantics is a special case of standard semantics (by constructing WorldHistories from FMCS families), or
(b) Prove completeness directly for BFMCS semantics (Henkin-style)

For approach (a), shift-closure of the canonical Omega is needed. For approach (b), it is not directly needed (BFMCS handles it internally).

### 4. How to Prove Shift-Closure of CanonicalOmega

#### 4.1 What Is CanonicalOmega?

In the standard approach, CanonicalOmega would be the set of all WorldHistories that arise from canonical FMCS families. Each FMCS family fam : D -> Set Formula induces a WorldHistory:
- Domain: all of D (full domain)
- States: mapping from D to WorldState (= MCS = Set Formula)
- fam(t) gives the MCS at time t
- respects_task by the canonical task relation

CanonicalOmega = { tau_fam | fam is a canonical FMCS }

#### 4.2 Shift-Closure Proof Strategy

**Claim**: If fam is a canonical FMCS (satisfying forward_G, backward_H, is_mcs for all t, and the temporal coherence properties forward_F, backward_P), then the shifted family fam_Delta defined by:

```
fam_Delta(t) := fam(t + Delta)
```

is also a canonical FMCS.

**Proof sketch**:

1. **is_mcs**: fam_Delta(t) = fam(t + Delta), which is an MCS because fam(t + Delta) is an MCS. (TRIVIAL)

2. **forward_G**: Need: if t < t' and G phi in fam_Delta(t), then phi in fam_Delta(t').
   - fam_Delta(t) = fam(t + Delta) and fam_Delta(t') = fam(t' + Delta)
   - G phi in fam(t + Delta)
   - t < t' implies t + Delta < t' + Delta (order-preserving translation)
   - By fam.forward_G: phi in fam(t' + Delta) = fam_Delta(t')
   - DONE. (TRIVIAL by order-preservation)

3. **backward_H**: Symmetric to forward_G.
   - Need: if t' < t and H phi in fam_Delta(t), then phi in fam_Delta(t').
   - fam_Delta(t) = fam(t + Delta), fam_Delta(t') = fam(t' + Delta)
   - H phi in fam(t + Delta)
   - t' < t implies t' + Delta < t + Delta
   - By fam.backward_H: phi in fam(t' + Delta) = fam_Delta(t')
   - DONE.

4. **forward_F** (if required): Need: if F phi in fam_Delta(t), then exists s > t with phi in fam_Delta(s).
   - F phi in fam(t + Delta)
   - By fam.forward_F: exists s' > t + Delta with phi in fam(s')
   - Let s = s' - Delta. Then s > t (since s' > t + Delta implies s' - Delta > t) and
     fam_Delta(s) = fam(s + Delta) = fam(s') which has phi.
   - DONE.

5. **backward_P** (if required): Symmetric to forward_F.

**Key insight**: ALL coherence conditions transfer because they are purely order-theoretic, and the order on D is translation-invariant (it is an ordered additive group). Shifting by Delta is an order automorphism, so all order-based properties are preserved.

#### 4.3 The Lindenbaum Perspective

From the Lindenbaum algebra viewpoint:
- The G operator corresponds to a topological interior operator on the Stone space of the algebra
- Shifting by Delta corresponds to the automorphism tau_Delta on the algebra
- The canonical model's MCS families are ultrafilters of the algebra
- Shift-closure of the canonical space follows from the fact that the algebra is closed under G and H, and the automorphism group acts on the space

More precisely: the Lindenbaum-Tarski algebra of TM formulas is a Boolean algebra with operators G and H. The maximal consistent sets are the ultrafilters. The canonical relation CanonicalR is defined by:
```
CanonicalR M M' iff GContent(M) subset M'
```
This relation IS invariant under the "shift" induced by G/H: if M CanonicalR M', then applying "G-shift" to both yields another pair in the relation. This is because the 4-axiom (G phi -> GG phi) ensures G is transitive, and the K-distribution (G(phi -> psi) -> (G phi -> G psi)) ensures shift-coherence.

#### 4.4 Precise Theorem Statement

**Theorem (Shift-Closure of Canonical FMCS Families)**:

Let D be an ordered additive group. Let FMCS(D) be the set of all families fam : D -> Set Formula satisfying:
(a) For all t : D, fam(t) is a maximal consistent set
(b) forward_G: for all t < t' and phi, G phi in fam(t) implies phi in fam(t')
(c) backward_H: for all t' < t and phi, H phi in fam(t) implies phi in fam(t')

Then FMCS(D) is shift-closed: for any fam in FMCS(D) and Delta in D, the family fam_Delta(t) := fam(t + Delta) is also in FMCS(D).

**Proof**: As sketched in 4.2 above. Each condition transfers by translation invariance.

### 5. Relationship to the Converse Property

The user asks about the converse property: task_rel w d u iff task_rel u (-d) w.

In the current codebase, `WorldHistory.respects_task` uses a guard `s <= t`:
```lean
respects_task : forall (s t : D) (hs : domain s) (ht : domain t),
    s <= t -> F.task_rel (states s hs) (t - s) (states t ht)
```

If we add the converse property (task_rel w d u iff task_rel u (-d) w) and drop the s <= t guard, making respects_task symmetric:
```
forall s t, domain s -> domain t -> F.task_rel (states s) (t - s) (states t)
```

This does NOT change what shift-closure means. Shift-closure is about the SET of histories Omega being closed under time translation, not about the internal structure of individual histories. The converse property affects individual histories (making them "bidirectional"), but shift-closure is a property of collections of histories.

However, the converse property simplifies the definition of `respects_task` by removing directionality, which means histories are defined on all of D without a preferred direction. This interacts well with shift-closure: shifted histories automatically respect the task relation in both directions if the original does, because:
- task_rel (sigma(s + Delta)) ((t + Delta) - (s + Delta)) (sigma(t + Delta))
- = task_rel (sigma(s + Delta)) (t - s) (sigma(t + Delta))
- which is exactly sigma's task_rel respect applied at s + Delta, t + Delta.

### 6. semantic_consequence vs satisfiable

The user asks whether we can sidestep shift-closure by targeting satisfiability instead of semantic_consequence.

**No, we cannot.** Here is why:

**Semantic consequence** (Validity.lean):
```lean
def semantic_consequence (Gamma : Context) (phi : Formula) : Prop :=
  forall D ... (Omega : Set (WorldHistory F)) (h_sc : ShiftClosed Omega) (tau in Omega) (t : D),
    (forall psi in Gamma, truth_at M Omega tau t psi) -> truth_at M Omega tau t phi
```

**Completeness for semantic_consequence**:
Gamma proves phi implies Gamma semantically-entails phi (soundness, already done).
Contrapositively: Gamma not-semantically-entails phi implies Gamma not-proves phi.
Equivalently: Gamma proves phi iff Gamma semantically-entails phi.

To show NOT(Gamma sem-entails phi), we need:
- A SPECIFIC D, F, M, Omega (shift-closed!), tau in Omega, t
- Where all of Gamma is true but phi is false

The counter-model's Omega MUST be shift-closed because that's what the quantifier in semantic_consequence requires.

**Satisfiability**:
```lean
def satisfiable (D : Type*) [...] (Gamma : Context) : Prop :=
  exists (F : TaskFrame D) (M : TaskModel F) (Omega : Set (WorldHistory F))
    (tau : WorldHistory F) (_ : tau in Omega) (t : D),
    forall phi in Gamma, truth_at M Omega tau t phi
```

Note: `satisfiable` does NOT explicitly require ShiftClosed(Omega) in its definition. However, truth_at depends on Omega for the box case. If Omega is not shift-closed, then the truth values of formulas involving box may not satisfy the expected axioms.

More precisely: if we build a model with non-shift-closed Omega, the MF axiom might not be sound in that model. So formulas provable from Gamma (which include MF instances) might not be true, contradicting the premise that "all of Gamma is true."

The fundamental issue: our proof system includes axioms (like MF: box(G phi -> G psi) -> G(box phi -> box psi)) whose soundness depends on ShiftClosed. If Gamma contains or derives MF instances, their truth in the model requires ShiftClosed.

**Bottom line**: Shift-closure is not a technicality we can avoid. It is a structural requirement that makes the interaction between box (cross-history) and G/H (intra-history) operators well-behaved. Without it, the axioms governing these interactions would be unsound, and the canonical model would not validate all theorems of TM.

### 7. BFMCS as a Workaround

The BFMCS approach (current codebase) effectively BYPASSES the shift-closure issue by defining truth differently:
- bmcs_truth_at quantifies box over FMCS families in a bundle, not WorldHistories in Omega
- G/H quantify over times in the same FMCS family
- There is no Omega, no WorldHistory, no ShiftClosed requirement

This is why the BFMCS truth lemma is proven sorry-free. But to connect BFMCS completeness to standard completeness, one must show that BFMCS truth coincides with standard truth for some appropriate Omega. This is where shift-closure re-enters.

The connection would be:
1. Given a BFMCS B, construct WorldHistories from FMCS families
2. Let Omega = { worldHistory(fam) | fam in B.families }
3. Show Omega is ShiftClosed (by Theorem in section 4)
4. Show bmcs_truth_at B fam t phi iff truth_at M Omega (worldHistory(fam)) t phi
5. Standard completeness follows from BFMCS completeness + this bridge

### 8. Constructing WorldHistories from FMCS Families

For each FMCS family fam, construct a WorldHistory:

```
worldHistory(fam) : WorldHistory F where
  domain := fun t => True  -- full domain (all times)
  convex := trivially true (full domain)
  states := fun t _ => fam.mcs t  -- the MCS at time t IS the world state
  respects_task := ???  -- THIS is the hard part
```

The `respects_task` field requires: for all s <= t,
  F.task_rel (fam.mcs s) (t - s) (fam.mcs t)

This is exactly what the canonical task relation should provide. In the D-from-syntax pipeline, the task relation on the canonical frame is defined so that this holds by construction.

### 9. Summary of Required Theorems

**Theorem 1 (Shift-Closure of FMCS Families)**:
```
If fam : FMCS D, then for any Delta : D,
  fam_shift(t) := fam(t + Delta) is also an FMCS D.
```
Proof: Translation invariance of the order on D.

**Theorem 2 (Shift-Closure of TemporalCoherentFamily)**:
```
If fam is a TemporalCoherentFamily (has forward_F and backward_P),
then fam_shift is also a TemporalCoherentFamily.
```
Proof: forward_F and backward_P transfer by the same translation argument as forward_G and backward_H.

**Theorem 3 (Shift-Closure of BFMCS Families)**:
```
If B is a BFMCS and fam in B.families, then fam_shift in B.families.
```
This requires B.families to be shift-closed. This is a DESIGN CHOICE: we need to construct B so that its families are shift-closed.

**Theorem 4 (BFMCS-to-Standard Bridge)**:
```
For a shift-closed BFMCS B with canonical WorldHistories,
bmcs_truth_at B fam t phi <-> truth_at M Omega (worldHistory(fam)) t phi
```
This connects the two semantics.

## ROAD_MAP.md Reflection

### Pitfalls Checked

| Dead End | Relevance | Impact on Recommendations |
|----------|-----------|--------------------------|
| All Int/Rat Import Approaches | Medium | Shift-closure does not depend on choice of D; applies equally to D-from-syntax |
| Product Domain Trivialization | Low | Not related to shift-closure |
| TranslationGroup Holder's chain | Low | Not related to shift-closure |

### Strategy Alignment

| Strategy | Status | Relevance |
|----------|--------|-----------|
| D Construction from Canonical Timeline | ACTIVE | Shift-closure proof must work for D discovered from syntax |
| Indexed MCS Family Approach | ACTIVE | FMCS shift-closure is the core theorem needed |
| Algebraic Verification Path | PAUSED | Algebraic perspective validates shift-closure automatically |

The D-from-syntax strategy is directly relevant: once D is constructed from the canonical timeline (via Cantor isomorphism T cong Q), the FMCS families are defined over this D, and shift-closure follows from the translation invariance of the order discovered via Cantor.

## Context Extension Recommendations

### Discovered Concepts Requiring Documentation

| Concept | Report Section | Currently Documented? | Gap Type |
|---------|----------------|----------------------|----------|
| Shift-closure definition and role | Sections 1-2 | Partial (code comments only) | extension |
| BFMCS-to-standard bridge | Section 7 | No | new_file |
| Translation invariance of canonical order | Section 4 | No | extension |
| WorldHistory from FMCS construction | Section 8 | No | new_file |

### New Context File Recommendations

| Filename | Directory | Content Scope | Priority | Create Task? |
|----------|-----------|---------------|----------|--------------|
| `shift-closure-analysis.md` | `domain/` | Full analysis of shift-closure: definition, role, proof strategy | Medium | No |
| `bfmcs-standard-bridge.md` | `processes/` | Connecting BFMCS and standard semantics | High | No |

### Summary

- **New files needed**: 2
- **Extensions needed**: 2
- **Tasks to create**: 0 (research-only, no context extension tasks for an ad-hoc report)
- **High priority gaps**: 1 (BFMCS-to-standard bridge)

## Decisions

1. **Shift-closure of FMCS families is trivial**: The proof transfers coherence conditions by translation invariance of the ordered group. This is a straightforward mathematical fact.

2. **The real challenge is respects_task**: Constructing WorldHistories from FMCS families requires the canonical task relation to satisfy respects_task. This is where the D-from-syntax pipeline is essential.

3. **BFMCS bypasses shift-closure for the truth lemma**: But connecting to standard semantics reintroduces it.

4. **Shift-closure cannot be avoided**: It is structural, not optional. The interaction axioms (MF, TF) are unsound without it.

## Risks & Mitigations

1. **Risk**: BFMCS shift-closure (Theorem 3) requires B.families to be closed under shifting. Current BFMCS construction may not guarantee this.
   **Mitigation**: Design the BFMCS construction to explicitly close under shifts. Since FMCS shift-closure is trivial (Theorem 1), this amounts to taking the closure of B.families under shifting.

2. **Risk**: The BFMCS-to-standard bridge (Theorem 4) may have subtle issues with the box case where BFMCS quantifies over families but standard truth quantifies over WorldHistories.
   **Mitigation**: If each WorldHistory corresponds to exactly one FMCS family (bijection), the bridge follows. If not, careful argument is needed.

3. **Risk**: respects_task for canonical WorldHistories depends on the canonical task relation definition, which is part of the D-from-syntax pipeline and not yet complete.
   **Mitigation**: The shift-closure theorem is independent of respects_task. It can be proven now even before the canonical task relation is finalized.

## Appendix

### A. Summary of Codebase Definitions

| Definition | File | Purpose |
|------------|------|---------|
| `ShiftClosed` | Truth.lean:231 | Property of Omega being closed under time_shift |
| `time_shift` | WorldHistory.lean:236 | Shift a WorldHistory by duration Delta |
| `time_shift_preserves_truth` | Truth.lean:344 | Truth at shifted history corresponds to truth at original |
| `FMCS` | FMCSDef.lean:80 | Family of MCS with forward_G, backward_H |
| `BFMCS` | BFMCS.lean:88 | Bundle of FMCS families with modal coherence |
| `bmcs_truth_at` | BFMCSTruth.lean:86 | BFMCS truth evaluation |
| `bmcs_truth_lemma` | TruthLemma.lean:260 | Main truth lemma (sorry-free) |
| `valid` | Validity.lean:72 | Standard validity (quantifies over ShiftClosed Omega) |
| `semantic_consequence` | Validity.lean:95 | Standard semantic consequence |
| `CanonicalMCS` | CanonicalFMCS.lean:77 | Type of all MCSs |
| `CanonicalTimeline` | CanonicalTimeline.lean:63 | Bidirectionally reachable MCSs from root |

### B. Key Mathematical References

- Goldblatt, R. (1992). *Logics of Time and Computation*, 2nd ed. CSLI Lecture Notes.
- Blackburn, P., de Rijke, M., Venema, Y. (2001). *Modal Logic*. Cambridge University Press.
- Burgess, J. (1979). "Logic and time." *Journal of Symbolic Logic* 44, 556-582.
- Stanford Encyclopedia of Philosophy: [Temporal Logic](https://plato.stanford.edu/entries/logic-temporal/)
- Stanford Encyclopedia of Philosophy: [Branching Time](https://plato.stanford.edu/entries/branching-time/)

### C. Search Queries Used

1. Codebase: `ShiftClosed|shift.?closed|shift_closed|CanonicalOmega` in *.lean
2. Codebase: `Representation|representation` in *.lean
3. Codebase: `respects_task|task_rel.*canonical` in *.lean
4. Web: "shift closure temporal logic canonical model completeness Kripke tense logic"
5. Web: "Goldblatt logics of time and computation canonical model temporal completeness shift invariance"
6. Web: "canonical history shift closed temporal logic completeness"
7. Web: "Burgess tense logic completeness canonical model time translation invariant histories"
