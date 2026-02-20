# Implementation Plan: Task #912

- **Task**: 912 - review_completeness_proof_metalogic_state
- **Version**: 001
- **Created**: 2026-02-19
- **Status**: [NOT STARTED]
- **Effort**: 10-14 hours
- **Dependencies**: None
- **Research Inputs**: specs/912_review_completeness_proof_metalogic_state/reports/research-001.md, specs/912_review_completeness_proof_metalogic_state/reports/research-002.md
- **Artifacts**: specs/912_review_completeness_proof_metalogic_state/plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

---

## Overview

This plan addresses the systematic review and refactoring of the Bimodal metalogic
(`Theories/Bimodal/Metalogic/`). The primary goal is to resolve the two `sorry`
placeholders in `Representation.lean` that block standard completeness (with respect
to the canonical `valid` definition using `Omega = Set.univ`), while archiving
superseded experimental code to reduce the active sorry count by approximately 30.

The plan proceeds in five phases: (1) codebase audit and archival of dead code,
(2) a careful mathematical investigation of what makes the Omega-mismatch hard and
what the locality property for the canonical model actually says, (3) proving the
locality/state-determination property that makes `canonicalOmega = Set.univ` effective,
(4) discharging the two `sorry` placeholders in `Representation.lean` using the
locality result, and (5) final verification and documentation cleanup.

---

## Mathematical Analysis

This section provides the mathematical substance underlying the implementation choices.
It is essential reading before any code changes to `Validity.lean`, `Soundness.lean`,
or `Representation.lean`.

### 1. What Is at Stake with `Omega = Set.univ`

The current definition in `Validity.lean` is:

```lean
def valid (φ : Formula) : Prop :=
  ∀ (D : Type) ... (F : TaskFrame D) (M : TaskModel F)
    (τ : WorldHistory F) (t : D),
    truth_at M Set.univ τ t φ
```

The `Set.univ` here means that the box modality quantifies over ALL world histories in
the frame. This is the standard semantic definition for normal modal logics and is the
definition that appears in the JPL paper (the `Ω` parameter is the full set of
admissible histories, which for validity is the universal set).

**If `valid` is changed to use a smaller Omega**, say a bundle-specific Omega, the
resulting notion of validity is strictly WEAKER: a formula can be "valid" in the new
sense while being false at some standard `(M, Set.univ, τ, t)` triple. A completeness
proof for the weaker notion would NOT establish completeness for the standard notion.
This is not a technical inconvenience — it is a change to the mathematical content
of the theorem. The result would be a formally verified statement of a different and
weaker claim.

**The canonical definition must be preserved.** The path forward is to show that the
canonical model constructed from the BMCS satisfies the standard validity predicate
directly, without weakening `valid`.

### 2. The Omega-Mismatch: A Precise Diagnosis

The two `sorry` placeholders in `Representation.lean` (lines 401 and 435) arise
because of the following gap:

- `standard_representation` establishes:
  `satisfiable Int [φ.neg]`, which means there exist `F`, `M`, `Omega`, `τ` with
  `τ ∈ Omega` and `truth_at M Omega τ t φ.neg`.

- The witness is `Omega = canonicalOmega B`, a set containing only canonical histories
  (one per family in the BMCS `B`).

- `valid φ` asserts `truth_at M Set.univ τ t φ` for ALL `τ` and ALL frames.
  When instantiated at the canonical model, it gives
  `truth_at (canonicalModel B) Set.univ τ t φ` for ALL `τ`.

- The contradiction attempt requires: `truth_at (canonicalModel B) (canonicalOmega B) τ t φ`
  (from the satisfiability witness) and `truth_at (canonicalModel B) Set.univ τ t φ.neg`
  (from validity), but these use different Omega parameters and thus both sides cannot be
  directly combined.

Truth is NOT monotone in Omega because of the box case:
- If `Omega1 ⊆ Omega2`, then `truth_at M Omega1 τ t (box φ)` implies
  `truth_at M Omega2 τ t (box φ)` (more histories to check, still all pass).
- BUT for `imp`: `truth_at M Omega τ t (box φ → ψ)` changes non-monotonically as
  Omega grows, because a larger Omega makes `box φ` harder to satisfy (more witnesses
  needed), which makes the antecedent weaker, which can make the implication easier
  to satisfy. This interplay makes truth neither globally monotone nor antitone in Omega.
- Therefore, there is no shortcut: one cannot derive `truth_at M Omega1 τ t φ.neg` from
  `truth_at M Omega2 τ t φ.neg` for arbitrary formulas `φ`.

### 3. The Elegant Solution: State-Determination in the Canonical Model

The key insight, identified in research-002.md Section 5.3, is the following:

**State-determination principle**: In the canonical model `(canonicalFrame B, canonicalModel B)`,
truth at any world history `σ` at any time `t` depends only on `σ.states t` — the
world state (i.e., an MCS) at time `t`.

More precisely:

```
For any σ₁, σ₂ : WorldHistory (canonicalFrame B),
if σ₁.states t ht₁ = σ₂.states t ht₂ (as CanonicalWorldState B values),
then for all φ: truth_at (canonicalModel B) Omega σ₁ t φ ↔ truth_at (canonicalModel B) Omega σ₂ t φ
```

**Why this is plausible**: Examine the truth clauses:
- `atom p`: depends on `σ.states t`, not on `σ` at other times. Independent of history structure beyond time `t`.
- `bot`: always `False`. Independent of history.
- `imp`: depends recursively on the same `(σ, t)`. If atoms and box are state-determined at `t`, so is `imp`.
- `box φ`: depends on `∀ σ' ∈ Omega, truth_at M Omega σ' t φ`. This is INDEPENDENT of the current history `σ` entirely. The box case does not depend on `σ` at all.
- `all_past φ`: depends on `∀ s ≤ t, truth_at M Omega σ s φ`. This involves `σ` at times `s ≤ t`, not just at `t`. So state-determination at `t` alone does NOT hold for `all_past` — truth at `(σ, t)` involves the whole history below `t`.
- `all_future φ`: similarly involves `σ` at times `s ≥ t`.

**This is a crucial observation**: the full state-determination principle (truth at `t` depends only on state at `t`) FAILS for formulas containing `all_past` or `all_future`. The temporal operators genuinely depend on the history at other times.

However, we can salvage the approach by examining what `canonicalOmega B` contains:

**Key Lemma Candidate**: For any world history `σ : WorldHistory (canonicalFrame B)`,
there exists a canonical history `τ = canonicalHistory B fam hfam` in `canonicalOmega B`
such that `σ.states t ht = τ.states t ht'` (as `CanonicalWorldState B` values).

This would mean: every history in `Set.univ` (for the canonical frame) has the same
state at time `t` as SOME canonical history in `canonicalOmega B`. Combined with the
state-determination of the box and atom cases, this would show that the box quantification
over `Set.univ` is equivalent to quantification over `canonicalOmega B`, since additional
histories in `Set.univ \ canonicalOmega B` contribute the same truth values as their
canonical counterparts.

**Why this requires careful investigation**:
1. A world history `σ : WorldHistory (canonicalFrame B)` has `states : D → (canonical_domain t → CanonicalWorldState B)`. With the universal domain (`domain = fun _ => True`), every state `σ.states t trivial : CanonicalWorldState B` is some MCS.
2. `CanonicalWorldState B = {S : Set Formula // SetMaximalConsistent S}`.
3. Every MCS in the canonical frame is of this type. Is every MCS in the type actually
   a `fam.mcs t` for some family `fam ∈ B.families`?

This is the question that determines whether `canonicalOmega B = Set.univ`:
- If `B.families` covers all MCSes (every MCS appears as `fam.mcs t` for some `fam`),
  then every history in `Set.univ` maps to a state already represented in `canonicalOmega B`,
  and the two Omega sets are semantically equivalent for truth evaluation.
- If `B.families` covers only some MCSes, then non-canonical histories may have states
  at time `t` that differ from all canonical histories, and the truth values for those
  histories must be computed separately.

### 4. The Locality Property and Its Precise Statement

The locality property, as identified in the research, concerns making truth at `(σ, t)`
depend only on the world state at time `t`. The correct precise statement for the canonical
model is:

**Proposition (State-Dependence of Box and Atoms)**:
For the canonical model, `truth_at (canonicalModel B) Omega σ t φ` depends on `σ` only
through `σ.states t` for the `atom` case, and is entirely independent of `σ` for the
`box` case (box quantifies over Omega, not over the current history).

**Corollary**: If `σ₁.states t = σ₂.states t` (as elements of `CanonicalWorldState B`),
then:
- `truth_at (canonicalModel B) Omega σ₁ t (atom p) ↔ truth_at (canonicalModel B) Omega σ₂ t (atom p)`
- `truth_at (canonicalModel B) Omega σ₁ t (box φ) ↔ truth_at (canonicalModel B) Omega σ₂ t (box φ)` (trivially, as box ignores `σ`)

**But this corollary DOES NOT extend to `all_past` and `all_future`**, because those
cases are `∀ s ≤ t, truth_at M Omega σ s φ`, which depends on the history at ALL past times.

**Consequence**: The "locality" approach works for modal-only fragments of the logic but
NOT for the full bimodal (modal + temporal) logic. A formula like `H(Box p)` ("at all past
times, necessarily p") depends on the history at past times, not just at `t`.

### 5. The Viable Path Forward: Proving `canonicalOmega B = Set.univ` via Saturation

The research (002, Section 5.3) suggests that the viable path is to prove that for the
canonical model, quantification over `Set.univ` is equivalent to quantification over
`canonicalOmega B` because **every state in `CanonicalWorldState B` appears as the
state of some canonical history at every time `t`**.

This would be established by:
1. **Coverage**: For any MCS `S` (a `CanonicalWorldState B` value), there exists a family
   `fam ∈ B.families` and a time `t` such that `fam.mcs t = S.val`.
2. **History construction**: For any `σ : WorldHistory (canonicalFrame B)` and any time
   `t`, the state `σ.states t trivial` is some MCS `S`, and by coverage, there is a
   canonical history mapping `t` to that state.
3. **Equivalence**: Truth with `Set.univ` equals truth with `canonicalOmega B` for formulas
   not involving temporal operators applied to atoms — but for temporal operators, the
   dependency on history structure at other times must be handled separately.

**The Full Equivalence Attempt**: One approach is to try to prove directly:
```
canonical_truth_lemma_all_univ : ∀ φ fam hfam t,
  φ ∈ fam.mcs t ↔ truth_at (canonicalModel B) Set.univ (canonicalHistory B fam hfam) t φ
```

This is a stronger version of the existing `canonical_truth_lemma_all` (which uses
`canonicalOmega B` instead of `Set.univ`). The proof would proceed by induction on `φ`.

- **atom**: ✓ Same proof as for `canonicalOmega B`.
- **bot**: ✓ Same proof.
- **imp**: ✓ By IH.
- **box**: The forward direction uses `modal_forward` as before but now must handle
  arbitrary `σ ∈ Set.univ` (not just canonical ones). For an arbitrary `σ`, we need
  to show `φ ∈ σ.states t trivial` in some suitable sense, then apply IH. But `σ.states t trivial`
  is a `CanonicalWorldState B`, hence a `{S // SetMaximalConsistent S}`. For IH to
  apply, we need `σ.states t trivial = mkCanonicalWorldState B fam' t` for some family `fam'`.
  This holds iff the MCS of `σ` at time `t` is `fam'.mcs t` for some `fam' ∈ B.families`.
  This is exactly the coverage question.
- **all_past, all_future**: The backward direction will use temporal coherence as before;
  the forward direction will now quantify over all `s ≤ t` and arbitrary histories `σ`.
  For temporal operators, the IH must work at arbitrary histories at arbitrary times, which
  again requires coverage at all times.

**Summary**: The critical lemma is:
```
∀ (S : CanonicalWorldState B), ∃ fam ∈ B.families, ∃ t, fam.mcs t = S.val
```

Whether this is provable depends on how `B.families` is constructed in
`TemporalCoherentConstruction.lean`. If `fully_saturated_bmcs_exists_int` (the upstream
sorry) provides families that cover all MCSes, then this is trivially true given the sorry.
However, if it does NOT guarantee coverage, then even discharging the sorry would not
make this lemma true.

**The research conclusion** (002, Section 5.3) suggests that because the canonical model
uses `CanonicalWorldState B` as its world state type — which is literally `{S // SetMaximalConsistent S}` —
and because the valuation is MCS membership, any world state in the frame IS an MCS.
Furthermore, the saturation of the BMCS ensures that every MCS that could possibly be a
world state already appears in the bundle families (by the Lindenbaum construction that
builds the bundle). This makes the coverage lemma provable (given the upstream sorry).

### 6. The MF/TF Axiom Problem with Arbitrary Omega

An important constraint identified in research-002, Section 5.1, is that the soundness
proofs for MF and TF axioms (`Box φ → G φ` and `Box φ → H φ`) depend crucially on
`ShiftClosed Omega` or `Omega = Set.univ`. The current proof uses `Set.univ` (which is
shift-closed by `Set.univ_shift_closed`), so soundness holds.

**This constraint means**: If we were to change `valid` to quantify over arbitrary Omega
with a `ShiftClosed Omega` condition, soundness would still work, but the canonical model
would need to provide a shift-closed Omega. Since `canonicalOmega B` is NOT shift-closed
(as documented in `Representation.lean` line 127-128), this approach would not work without
additional construction of a shift-closed canonical Omega.

**The approach preserved by this plan**: Keep `valid` with `Set.univ` unchanged. Instead
of weakening validity, prove that the canonical model's truth lemma works with `Set.univ`
directly (as discussed in Section 5 above). Soundness is unaffected.

---

## Goals and Non-Goals

**Goals**:
- Archive superseded experimental code (RecursiveSeed, SeedCompletion, SeedBMCS, deprecated
  sections of Construction.lean and TruthLemma.lean) to `Boneyard/Bundle/`
- Fix stale documentation in `FMP/FiniteWorldState.lean` (strict vs reflexive temporal semantics)
- Investigate and attempt to prove the state-determination/coverage lemma for the canonical model
- Attempt to discharge the two `sorry` placeholders in `Representation.lean` using a
  stronger truth lemma for `Set.univ`
- If the sorry discharge requires the upstream sorry from `fully_saturated_bmcs_exists_int`,
  document this dependency explicitly and verify the logic is sound
- Preserve `valid` with `Set.univ` (no weakening of the completeness statement)

**Non-Goals**:
- Resolving the upstream sorry in `fully_saturated_bmcs_exists_int` (that is a separate task)
- Modifying the definition of `valid` or `semantic_consequence` to use a smaller Omega
- Proving the DovetailingChain sorries (separate concern)
- Namespace reorganization beyond what is necessary for archival
- Improving performance or reducing build times

---

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Coverage lemma is unprovable without discharging `fully_saturated_bmcs_exists_int` | High | Medium | The coverage lemma may inherit the upstream sorry; document clearly and proceed conditionally |
| Truth lemma for `Set.univ` fails in the temporal cases (all_past, all_future) | High | High | The temporal cases may require a fundamentally different approach (see Phase 3 analysis); fallback is to document the obstruction precisely |
| RecursiveSeed archival breaks imports in active files | Medium | Low | Check all imports before archiving; update `Metalogic.lean` and other re-export files |
| FMP documentation fix introduces inconsistency with formal semantics | Low | Very Low | Read the actual semantics in Truth.lean to verify reflexive `≤` before modifying |
| Strengthening truth lemma to `Set.univ` invalidates the existing `canonicalOmega` proof | Low | Very Low | The `canonicalOmega` proof is a special case; strengthening to `Set.univ` subsumes it |
| All_past/all_future cases require full history determination, not just state at `t` | High | High | This is the central mathematical risk; Phase 3 must address it carefully before writing Lean code |

---

## Implementation Phases

### Phase 1: Codebase Audit, Archival, and Documentation Fixes [NOT STARTED]

- **Dependencies**: None
- **Goal**: Reduce the active sorry count by archiving dead code and fix stale documentation.

**Objectives**:
1. Archive `Bundle/RecursiveSeed/` (all 5 files, ~11,932 lines, ~28 sorries) to `Boneyard/Bundle/RecursiveSeed/`
2. Archive `Bundle/SeedCompletion.lean` (~374 lines, 5 sorries) to `Boneyard/Bundle/`
3. Archive `Bundle/SeedBMCS.lean` (~246 lines, 6 sorries) to `Boneyard/Bundle/`
4. Archive the deprecated `singleFamilyBMCS` section from `Bundle/Construction.lean` (1 sorry) or mark with `@[deprecated]` and delete
5. Archive the `eval_bmcs_truth_lemma` section of `Bundle/TruthLemma.lean` (~110 lines, 4 sorries)
6. Archive `Bundle/RecursiveSeed.lean` (the top-level module re-export file)
7. Fix the stale comment in `FMP/FiniteWorldState.lean` (lines ~81-86) describing strict `<` semantics when the actual semantics uses reflexive `≤`
8. Update `Metalogic.lean` and any other module that re-exports or imports archived files

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/Construction.lean` - Remove or archive deprecated `singleFamilyBMCS`
- `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean` - Remove or archive EvalBMCS section
- `Theories/Bimodal/Metalogic/FMP/FiniteWorldState.lean` - Fix stale documentation comment
- `Theories/Bimodal/Metalogic/Metalogic.lean` - Remove imports of archived files
- `Theories/Bimodal/Boneyard/Bundle/` - Destination for archived files

**Steps**:
1. Run `lake build` to establish a baseline and confirm the current sorry count
2. Identify all files importing RecursiveSeed, SeedCompletion, SeedBMCS (grep for imports)
3. Move RecursiveSeed directory, SeedCompletion.lean, SeedBMCS.lean, RecursiveSeed.lean to `Boneyard/Bundle/`
4. Extract and archive deprecated `singleFamilyBMCS` from Construction.lean (keep `ContextConsistent`, `lindenbaumMCS`, and non-deprecated helpers)
5. Extract and archive EvalBMCS section from TruthLemma.lean
6. Fix FiniteWorldState.lean documentation comment
7. Update all import statements; verify `lake build` succeeds after each step
8. Document archival decisions with brief comments in Boneyard files

**Timing**: 2-3 hours

**Verification**:
- `lake build` succeeds
- Sorry count decreases by approximately 34 (from ~47 to ~13 in the active codebase)
- No sorry or axiom is introduced that was not previously present

---

### Phase 2: Mathematical Investigation of the Omega-Mismatch [NOT STARTED]

- **Dependencies**: Phase 1
- **Goal**: Precisely characterize what is needed to discharge the two `sorry` placeholders
  in `Representation.lean`, through careful reading of the code and small exploratory proofs.

**Objectives**:
1. Examine exactly what `CanonicalWorldState B` contains — is it all MCSes, or only those that appear in some family?
2. Examine the structure of `BMCS.families` to determine whether coverage is guaranteed by the BMCS saturation conditions
3. Formulate the precise coverage lemma: `∀ S : CanonicalWorldState B, ∃ fam ∈ B.families, ∃ t : Int, fam.mcs t = S.val`
4. Attempt a proof of the coverage lemma in a scratch file or directly in Representation.lean
5. Examine the `all_past` and `all_future` cases of the potential `Set.univ` truth lemma and determine whether they can be proved or represent a fundamental obstruction
6. Determine the precise proof strategy for the two sorry cases (lines 401 and 435)

**Files to read/investigate**:
- `Theories/Bimodal/Metalogic/Bundle/Representation.lean` - Current sorry locations
- `Theories/Bimodal/Metalogic/Bundle/BMCS.lean` - BMCS structure and saturation conditions
- `Theories/Bimodal/Metalogic/Bundle/IndexedMCSFamily.lean` - Family structure
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` - How families are built
- `Theories/Bimodal/Metalogic/Bundle/CoherentConstruction.lean` - Modal saturation

**Steps**:
1. Read `IndexedMCSFamily.lean` to understand the structure of families and their MCS functions
2. Read the modal saturation conditions in `BMCS.lean` to understand what `modal_backward` requires
3. Formulate the coverage conjecture as a Lean statement and check if it type-checks
4. Attempt to prove coverage using the BMCS modal saturation (or identify why it fails)
5. Attempt the `all_past`/`all_future` cases of `canonical_truth_lemma_all_univ` — either prove them or identify the precise obstruction
6. Write up findings in a `-- ANALYSIS:` comment block at the top of the relevant section of Representation.lean
7. Based on findings, choose between:
   a. Proving the full `canonical_truth_lemma_all_univ` (with Set.univ)
   b. Proving a restricted truth lemma for modal-only formulas (if temporal cases are obstructed)
   c. A different proof strategy for the sorry cases (e.g., using coverage + separate analysis)

**Timing**: 3-4 hours

**Verification**:
- A clear mathematical determination of whether the coverage lemma is provable
- A clear determination of whether the `all_past`/`all_future` cases can be handled
- A written proof sketch (even if using sorry stubs) that can be implemented in Phase 3
- `lake build` still succeeds (no new sorries introduced in production code)

---

### Phase 3: Prove the Locality/Coverage Property [NOT STARTED]

- **Dependencies**: Phase 2
- **Goal**: Prove the key mathematical lemma identified in Phase 2 that bridges the
  Omega-mismatch, and prove a strengthened truth lemma suitable for discharging the sorries.

This phase will differ based on the findings of Phase 2:

**Path A (if coverage is provable)**: Prove `canonical_truth_lemma_all_univ` — the
strengthened truth lemma with `Set.univ` instead of `canonicalOmega B`. Add this to
`Representation.lean` alongside the existing `canonical_truth_lemma_all`.

**Path B (if temporal cases are obstructed)**: Prove coverage + state-determination only
for the relevant cases. This may mean proving that for any history `σ : WorldHistory (canonicalFrame B)`,
the function `t ↦ σ.states t trivial` is itself a canonical history (i.e., equals `canonicalHistory B fam hfam`
for some `fam`). This would be the key uniqueness/surjectivity lemma for canonical histories.

**Path C (if `canonicalOmega = Set.univ` directly)**: Prove that `canonicalOmega B = Set.univ`
as sets. This requires showing:
- Every canonical history is in Set.univ (trivial, all elements of any type are in Set.univ)
- Every history σ : WorldHistory (canonicalFrame B) is a canonical history

The second point holds iff every world history over the canonical frame is equal to
`canonicalHistory B fam hfam` for some family. This would require that the history's
state function is the MCS function of some family — a strong requirement that may not hold
for arbitrary histories constructed from the type theory.

**Expected outcome based on research**: The research (002, Section 5.3) suggests that the
`canonical_truth_lemma_all_univ` approach (Path A) is viable IF we accept that the upstream
sorry from `fully_saturated_bmcs_exists_int` provides sufficient saturation. The box case
can be handled if every state at any time `t` in any canonical-frame history is `fam.mcs t`
for some `fam ∈ B.families`. The temporal cases may require the additional insight that any
history's state sequence is a valid family (all MCS families are in the bundle by saturation).

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/Representation.lean` - Add coverage lemma and/or strengthened truth lemma

**Timing**: 3-4 hours

**Verification**:
- The key lemma is proved (or clearly sorry-marked if it depends only on the upstream sorry)
- The proof is type-checked by Lean
- No new axioms are introduced

---

### Phase 4: Discharge the Representation Sorry Placeholders [NOT STARTED]

- **Dependencies**: Phase 3
- **Goal**: Replace the two `sorry` placeholders in `Representation.lean` with actual proofs
  using the results from Phase 3.

**Objectives**:
1. Replace the `sorry` in `standard_weak_completeness` (line 401) with a proof using the
   strengthened truth lemma (or coverage result) from Phase 3
2. Replace the `sorry` in `standard_strong_completeness` (line 435) similarly
3. Update the module documentation to accurately reflect the dependency chain

**Proof structure for `standard_weak_completeness`**:
```
1. Suppose ⊬ φ
2. Then [φ.neg] is consistent (by not_derivable_implies_neg_consistent)
3. By standard_representation: ∃ B, F, M, canonicalOmega B, τ ∈ canonicalOmega B, t,
   truth_at M (canonicalOmega B) τ t φ.neg
4. Using strengthened truth lemma (or coverage): truth_at M Set.univ τ t φ.neg
   [This step is where the Omega-mismatch sorry is replaced]
5. From valid φ: truth_at M Set.univ τ t φ (instantiated at the canonical model/history/time)
6. Contradiction: truth_at M Set.univ τ t φ and truth_at M Set.univ τ t φ.neg
   (the latter is ¬truth_at M Set.univ τ t φ)
```

The key is Step 4: showing that `truth_at M (canonicalOmega B) τ t φ.neg` implies
`truth_at M Set.univ τ t φ.neg`. OR alternatively, showing that `valid φ` gives
`truth_at M (canonicalOmega B) τ t φ` (by showing the canonical model is a valid
instantiation with Omega = canonicalOmega B).

**Alternative approach (if `canonical_truth_lemma_all_univ` was proved)**:
Use it to replace Step 3-4: since the truth lemma holds with Set.univ, the satisfiability
witness can be stated with Omega = Set.univ directly.

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/Representation.lean` - Replace the two sorry placeholders

**Timing**: 1-2 hours

**Verification**:
- `lake build` succeeds
- `grep -r "sorry" Theories/Bimodal/Metalogic/Bundle/Representation.lean` returns no results
  (or only commented sorries)
- The theorems `standard_weak_completeness` and `standard_strong_completeness` have type
  signatures identical to before (no signature weakening)

---

### Phase 5: Final Verification and Documentation [NOT STARTED]

- **Dependencies**: Phase 4
- **Goal**: Verify the full codebase builds cleanly, update sorry counts, and document
  the mathematical state of the completeness proof for future work.

**Objectives**:
1. Run `lake build` and verify zero build errors
2. Count remaining sorries and axioms in the active codebase (excluding Boneyard/)
3. Update the module documentation in `Metalogic.lean` and `Representation.lean` to
   accurately reflect the theorem status
4. Write a brief summary of what was accomplished and what remains open
5. Update `specs/state.json` and `specs/TODO.md` to reflect completion

**Files to modify**:
- `Theories/Bimodal/Metalogic/Metalogic.lean` - Update module-level comments
- `Theories/Bimodal/Metalogic/Bundle/Representation.lean` - Update status comments
- `Theories/Bimodal/Metalogic/Bundle/Completeness.lean` - Update cross-references if needed
- `specs/state.json` - Update completion_summary and repository_health
- `specs/TODO.md` - Mark task 912 as completed

**Steps**:
1. `lake build` — confirm success
2. `grep -r "sorry" Theories/Bimodal/Metalogic/ --include="*.lean" | grep -v Boneyard | wc -l` — count sorries
3. `grep -r "^axiom" Theories/Bimodal/ --include="*.lean" | grep -v Boneyard | wc -l` — count axioms
4. Update module docstrings with current status
5. Update state.json repository_health
6. Commit changes

**Timing**: 1 hour

**Verification**:
- `lake build` exits with status 0
- Sorry count is approximately 13 or fewer in active code (down from ~47 before this task)
- All principal completeness theorems are documented with their exact proof status

---

## Testing and Validation

- [ ] `lake build` succeeds with zero build errors after each phase
- [ ] No new `sorry` or `axiom` declarations appear in active files (Boneyard/ excluded)
- [ ] `standard_weak_completeness` and `standard_strong_completeness` have their sorry
      placeholders replaced with actual proof terms (or sorry stubs that inherit only from
      `fully_saturated_bmcs_exists_int`)
- [ ] The type signatures of `standard_weak_completeness` and `standard_strong_completeness`
      remain exactly: `valid φ → Nonempty (DerivationTree [] φ)` and
      `semantic_consequence Γ φ → ContextDerivable Γ φ`
- [ ] The stale FMP documentation comment is corrected
- [ ] Archived files are in `Boneyard/Bundle/` and not imported by any active file
- [ ] `grep -r "RecursiveSeed\|SeedCompletion\|SeedBMCS" Theories/Bimodal/Metalogic/ --include="*.lean"` returns no results

---

## Artifacts and Outputs

- `specs/912_review_completeness_proof_metalogic_state/plans/implementation-001.md` (this file)
- `Theories/Bimodal/Boneyard/Bundle/RecursiveSeed/` (archived files)
- `Theories/Bimodal/Boneyard/Bundle/SeedCompletion.lean` (archived)
- `Theories/Bimodal/Boneyard/Bundle/SeedBMCS.lean` (archived)
- Updated `Theories/Bimodal/Metalogic/Bundle/Representation.lean` (sorries discharged or reduced)
- Updated `Theories/Bimodal/Metalogic/FMP/FiniteWorldState.lean` (stale comment fixed)
- `specs/912_review_completeness_proof_metalogic_state/summaries/implementation-summary-{DATE}.md`

---

## Rollback and Contingency

**If Phase 3 cannot be completed** (the coverage/locality lemma cannot be proved):
- The Phase 1 archival and Phase 2 analysis still constitute valuable work
- The sorry placeholders remain but are better documented
- Write a detailed obstruction analysis in `Representation.lean` explaining what would be
  needed to discharge the sorries
- The plan becomes a "partial" completion with concrete findings for future work

**If archival in Phase 1 breaks the build**:
- Revert the specific archival step that caused the breakage
- Determine which imports were missed and fix them before archiving
- The build must pass after each archival step before proceeding to the next

**If the upstream sorry from `fully_saturated_bmcs_exists_int` is the only obstacle**:
- The sorry placeholders in Representation.lean can be replaced with proofs that inherit
  from the upstream sorry (using `construct_saturated_bmcs_int` and the truth lemma)
- This is acceptable: the dependency chain is then clearly documented, and the
  Representation.lean sorries are no longer independent obstacles
- Document this clearly in the sorry-free claim matrix

---

## Open Questions for Phase 2

The following mathematical questions must be resolved during Phase 2 investigation
before committing to a proof strategy in Phase 3:

1. **Coverage question**: Does every `CanonicalWorldState B` (i.e., every SetMaximalConsistent
   set of formulas) appear as `fam.mcs t` for some `fam ∈ B.families` and some `t : Int`?
   - If YES: the `canonical_truth_lemma_all_univ` approach is viable
   - If NO: a different approach is needed (e.g., restricting to modal-only formulas,
     or using a different characterization of `Set.univ` for the canonical frame)

2. **Temporal obstruction**: In the `all_past` case of `canonical_truth_lemma_all_univ`,
   the backward direction requires: if `∀ s ≤ t, truth_at M Set.univ (canonicalHistory B fam hfam) s ψ`,
   then `H ψ ∈ fam.mcs t`. The proof uses temporal coherence via `backward_P`. Does this
   proof still work when the box case of the IH is strengthened to `Set.univ`? Specifically:
   does the IH for `ψ` work at the strengthened Omega `Set.univ`?

3. **Surjectivity question**: Is `canonicalHistory B fam hfam` injective (different families
   give different histories)? Is it surjective onto `canonicalOmega B`? These are needed to
   understand the relationship between families and canonical histories.

4. **MCS coverage by BMCS saturation**: The BMCS `modal_backward` says that if `φ ∈ fam'.mcs t`
   for all `fam' ∈ B.families`, then `Box φ ∈ fam.mcs t`. Does modal saturation guarantee
   that the families collectively contain EVERY MCS (as a time-indexed set), or only the MCSes
   that appear in the specific Lindenbaum construction?
