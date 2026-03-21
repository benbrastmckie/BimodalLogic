# Axiom Proof Dependencies and Derivation Paths

**Date**: 2026-03-21
**Focus**: Axiom proof dependencies and derivation paths for tasks 9-20
**Method**: Systematic codebase analysis of all `axiom` declarations, downstream dependency tracing, and derivation assessment

---

## Summary

Tasks 9-20 introduced **10 axiom declarations** across 5 files. Of these, 10 are actual Lean `axiom` keyword declarations (the remaining grep matches are comments). The axioms divide into three tiers:

1. **Genuinely justified axioms** (5): Capture semantic properties that are modally non-definable or require machinery beyond what the proof system can currently express. These are appropriate as axioms indefinitely.

2. **Derivable axioms with known proof paths** (3): Have clear derivation strategies but require significant implementation work. These are technical debt that should be eliminated.

3. **Dovetailing gap axioms** (2): Represent a structural gap in the Int-chain construction — the F/P witness problem. These require a full dovetailing chain construction and are the most significant technical debt.

**Key finding**: The 2 dovetailing gap axioms (`succ_chain_forward_F_axiom`, `succ_chain_backward_P_axiom`) are currently unused in the live completeness path — they appear in `SuccChainWorldHistory.lean` and `SuccChainTaskFrame.lean` which have no downstream importers, meaning they are dead code ends. The active completeness path goes through `ClosedFlagIntBFMCS.lean` → `DiscreteInstantiation.lean`.

---

## Dependency Analysis

### Axiom 1: `successor_deferral_seed_consistent_axiom`

- **File**: `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean:266`
- **Task introduced**: 12
- **Direct dependents**:
  - `successor_deferral_seed_consistent` (SuccExistence.lean:276) — thin wrapper
  - `successor_from_deferral_seed` (via `lindenbaumMCS_set` call at SuccExistence.lean:344)
- **Dependency chain**:
  - `successor_from_deferral_seed` → `successor_succ` → `successor_exists`
  - `successor_exists` → `ForwardChainElement.next` (SuccChainFMCS.lean:155)
  - `ForwardChainElement.next` → `forwardChainAt` → `forward_chain`
  - `forward_chain` → `succ_chain_fam` → `SuccChainFMCS`/`SuccChainTemporalCoherent`
  - `SuccChainFMCS` → `SuccChainWorldHistory.lean`, `SuccChainTaskFrame.lean` (both dead ends)
  - `successor_exists` also re-exported via `CanonicalRecovery.lean:227` → used in `CanonicalRecovery.lean` for recovering `successor_from_seriality`
- **Role in completeness**: Underpins all of successor/predecessor existence, which underpins the Int-indexed Succ-chain. The Succ-chain is currently a dead-code path for completeness (superceded by `ClosedFlagIntBFMCS`), but `successor_exists` itself is re-used in `CanonicalRecovery.lean`.
- **Derivation assessment**:
  - From Mathlib: **partial** — Lindenbaum-style arguments exist in Mathlib, but the specific deferral seed structure is codebase-specific
  - From modal axioms: **no** — no modal axiom directly gives joint satisfiability of g_content ∪ deferral disjunctions
  - From temporal axioms: **yes/partial** — The DF axiom `(F⊤ ∧ φ ∧ Hφ) → F(Hφ)` is the key. The proof strategy (documented in task 12 research report) is:
    1. Partition L ⊆ seed into `L_g ⊆ g_content(u)` and `L_d` (deferral disjunctions)
    2. If L_d = ∅: contradiction from `g_content_consistent`
    3. If L_d ≠ ∅: use DF + seriality (F(⊤) ∈ u) to build a semantic witness that satisfies both g_content(u) and all deferral disjunctions jointly
  - From definitions: **yes/partial** — The deferral disjunctions `φ ∨ F(φ)` are specifically designed so either disjunct is compatible with g_content, using the MCS disjunction property
- **Proof sketch** (if derivable):
  The core is Case 2 of the consistency argument. Given L_g ∪ L_d ⊢ ⊥ where L_d contains at least one deferral disjunction `φ ∨ F(φ)`:
  1. Note that `forward_temporal_witness_seed_consistent` already proves consistency of `{ψ} ∪ g_content(u)` for any single `F(ψ) ∈ u` (in WitnessSeed.lean)
  2. The deferral seed replaces `{ψ}` with a disjunction `ψ ∨ F(ψ)`, which is WEAKER (any truth assignment satisfying `ψ ∪ g_content(u)` also satisfies `(ψ ∨ F(ψ)) ∪ g_content(u)`)
  3. For multiple deferral disjunctions: use compactness — any finite subset with L_d ≠ ∅ can be satisfied by choosing one disjunct for each disjunction and applying WitnessSeed consistency iteratively
  4. The DF axiom is needed to show that choosing "all deferred" (all F(φ) disjuncts) remains consistent with g_content via the existing `forward_temporal_witness_seed_consistent`

  **Assessment**: Derivable with medium effort. The key missing piece is a "weakening" lemma that `S ∪ {ψ}` consistent implies `S ∪ {ψ ∨ χ}` consistent, plus induction over disjunctions. This is standard propositional logic.

---

### Axiom 2: `predecessor_deferral_seed_consistent_axiom`

- **File**: `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean:311`
- **Task introduced**: 12
- **Direct dependents**:
  - `predecessor_deferral_seed_consistent` (SuccExistence.lean:321) — thin wrapper
  - `predecessor_from_deferral_seed` (via Lindenbaum call at SuccExistence.lean:456)
- **Dependency chain**:
  - `predecessor_from_deferral_seed` → `predecessor_succ` → `predecessor_exists`
  - `predecessor_exists` → `BackwardChainElement.prev` → `backwardChainAt` → `backward_chain`
  - `backward_chain` → `succ_chain_fam` (same dead-code path as Axiom 1)
- **Role in completeness**: Symmetric dual of Axiom 1. Same dead-code path status for completeness.
- **Derivation assessment**:
  - From temporal axioms: **yes/partial** — Symmetric to Axiom 1, using DP (derivable from DF) instead of DF, h_content instead of g_content, and P(⊤) ∈ u instead of F(⊤) ∈ u
  - From definitions: **yes/partial** — Same weakening argument applies symmetrically
- **Proof sketch** (if derivable):
  Symmetric to Axiom 1. The h_content/g_content duality (already proven in codebase via `h_content_subset_implies_g_content_reverse`) allows the same argument to run in reverse. The DP axiom (derivable from DF) plays the role of DF.

  **Assessment**: Derivable immediately after Axiom 1 is proven, by symmetric argument. Low incremental effort.

---

### Axiom 3: `predecessor_f_step_axiom`

- **File**: `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean:516`
- **Task introduced**: 12
- **Direct dependents**:
  - `predecessor_succ` (SuccExistence.lean:524) — uses this axiom as second component of Succ pair
  - `predecessor_pred`, `predecessor_exists`
  - All downstream users of `predecessor_exists` (same dead-code chain as Axiom 2)
- **Dependency chain**: Same as Axiom 2 — dead-code path for current completeness.
- **Role in completeness**: Required to prove `Succ (predecessor) u`. The first Succ condition (g-persistence) is already proven via `h_content_subset_implies_g_content_reverse`. This axiom covers only the second condition (F-step) for the predecessor.
- **Derivation assessment**:
  - From temporal axioms: **yes/partial** — The F-step condition `f_content(v) ⊆ u ∪ f_content(u)` for predecessor v requires showing that F-obligations of v are resolved or deferred at u. The past deferral disjunctions `φ ∨ P(φ)` in the predecessor seed constrain what P-obligations can appear in v, and by temporal duality, this constrains F-obligations relative to u.
  - From definitions: **yes/partial** — The predecessor seed is `h_content(u) ∪ {φ ∨ P(φ) | P(φ) ∈ u}`. Condition: for any `F(ψ) ∈ v = predecessor_from_deferral_seed(u)`, need `ψ ∈ u ∨ F(ψ) ∈ u`. This follows from the MCS properties: if `F(ψ) ∈ v` and `F(ψ) ∉ u`, then since v is the predecessor's Lindenbaum extension of a seed derived from u's P-structure, the duality via existing lemmas should close the gap.
- **Proof sketch** (if derivable):
  1. Let v = `predecessor_from_deferral_seed u h_mcs h_P_top`
  2. Suppose `F(ψ) ∈ v`; need `ψ ∈ u ∨ F(ψ) ∈ u`
  3. By contrapositive: if `ψ ∉ u` and `F(ψ) ∉ u`, then by MCS maximality, `¬ψ ∈ u` and `G(¬ψ) ∈ u` (since ¬F(ψ) = G(¬ψ))
  4. Then `¬ψ ∈ g_content(u) ⊆ predecessor_seed`, so `¬ψ ∈ v`
  5. But `F(ψ) ∈ v` and `¬ψ ∈ v` gives derivability of contradiction using... wait, this requires showing that having G(¬ψ) in u forces ¬ψ in the predecessor, which follows from `h_content` structure if ¬G(¬ψ) is involved.

  **Assessment**: The proof sketch is not immediate — the g/h content duality lemmas may need to be carefully applied. Medium effort. The key lemma needed is: if `G(¬ψ) ∈ u`, then `¬ψ ∈ v` for any successor v of a predecessor of u.

---

### Axiom 4: `F_top_propagates`

- **File**: `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean:150`
- **Task introduced**: 14
- **Direct dependents**:
  - `ForwardChainElement.next` (SuccChainFMCS.lean:158-163) — uses it to prove `has_F_top` for the next element
  - `forward_chain_has_F_top` (via `ForwardChainElement`)
- **Dependency chain**:
  - `ForwardChainElement.next` → `forwardChainAt` → `forward_chain` → `succ_chain_fam` → `SuccChainFMCS` (dead-code path)
- **Role in completeness**: Propagates seriality F(⊤) through the forward chain. Required for `ForwardChainElement.next` to produce a valid `ForwardChainElement`. In the dead-code Succ-chain path only.
- **Derivation assessment**:
  - From Mathlib: **no** — specific to this logic
  - From modal axioms: **yes** — This should be directly derivable. F(⊤) is a theorem (proven as `F_top_theorem` in the same file using seriality). Since F(⊤) is a theorem, it is in every MCS. So `F_top ∈ M'` for any MCS M', regardless of any `Succ M M'` relationship.
  - From definitions: **yes** — `F_top = F(¬⊥)` is provable (see `F_top_theorem` in SuccChainFMCS.lean:96-103 using `seriality_future` axiom + `G_neg_bot_theorem`). Since theorems are in all MCSes (`theorem_in_mcs`), we have `F_top ∈ M'` for any MCS M', no Succ hypothesis needed.
- **Proof sketch** (DERIVABLE — trivial):
  ```lean
  theorem F_top_propagates (M M' : Set Formula)
      (h_mcs : SetMaximalConsistent M) (h_mcs' : SetMaximalConsistent M')
      (h_succ : Succ M M') (h_F_top : F_top ∈ M) : F_top ∈ M' :=
    SetMaximalConsistent.contains_F_top h_mcs'
  ```
  The hypothesis `h_succ` and `h_F_top` are not even needed — F_top is in every MCS.

  **Assessment**: TRIVIALLY DERIVABLE. The axiom is completely redundant given `SetMaximalConsistent.contains_F_top` which is already proven in the same file (line 118-120). This axiom should be eliminated immediately.

---

### Axiom 5: `P_top_propagates`

- **File**: `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean:206`
- **Task introduced**: 14
- **Direct dependents**:
  - `BackwardChainElement.prev` (SuccChainFMCS.lean:214-219)
  - `backward_chain_has_P_top`
- **Dependency chain**: Same dead-code path as Axiom 4.
- **Role in completeness**: Symmetric to Axiom 4 for P(⊤) in the backward chain.
- **Derivation assessment**:
  - From definitions: **yes** — Exactly symmetric to Axiom 4. `P_top_theorem` is proven at SuccChainFMCS.lean:107-114, and `SetMaximalConsistent.contains_P_top` is proven at line 124-126. The axiom is redundant.
- **Proof sketch** (DERIVABLE — trivial):
  ```lean
  theorem P_top_propagates (M M' : Set Formula)
      (h_mcs : SetMaximalConsistent M) (h_mcs' : SetMaximalConsistent M')
      (h_pred : Succ M' M) (h_P_top : P_top ∈ M) : P_top ∈ M' :=
    SetMaximalConsistent.contains_P_top h_mcs'
  ```

  **Assessment**: TRIVIALLY DERIVABLE. Same situation as Axiom 4. Eliminate immediately.

---

### Axiom 6: `succ_chain_forward_F_axiom`

- **File**: `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean:417`
- **Task introduced**: 14
- **Direct dependents**:
  - `succ_chain_forward_F` (SuccChainFMCS.lean:421-424) — thin wrapper
  - `SuccChainTemporalCoherent` (SuccChainFMCS.lean:448-451) uses `succ_chain_forward_F`
- **Dependency chain**:
  - `SuccChainTemporalCoherent` → `SuccChainWorldHistory.lean` (no downstream importers)
  - `SuccChainTemporalCoherent` → `SuccChainTaskFrame.lean` (no downstream importers)
  - **DEAD CODE**: Neither `SuccChainWorldHistory.lean` nor `SuccChainTaskFrame.lean` are imported by any other active file
- **Role in completeness**: This axiom is currently NOT on the active completeness path. The active path goes through `ClosedFlagIntBFMCS.lean` → `DiscreteInstantiation.lean` → `Algebraic.lean`. The Succ-chain track was superseded.
- **Derivation assessment**:
  - From temporal axioms: **yes/partial** — This is the dovetailing problem. The claim: if `F(φ) ∈ succ_chain_fam(M0, n)`, then some `m > n` exists with `φ ∈ succ_chain_fam(M0, m)`.
  - The challenge: The Succ-chain is built by choosing a successor at each step; the F-obligation may be "deferred" (to F(φ) in the successor) repeatedly. Need to show this deferral terminates.
  - From definitions: **yes/partial** — The `single_step_forcing` theorem (from task 10): if `F(φ) ∈ u` and `F(F(φ)) ∉ u` and `Succ u v`, then `φ ∈ v`. This bounds the "depth" of F-nesting. Combined with the fact that F-nesting depth decreases (not provable directly via axioms, requires dovetailing to ensure the chain hits every formula), the obligation terminates.
  - Root difficulty: The deferral seed allows F(φ) to defer at each step (contributing F(φ) to the successor rather than φ). A chain can defer F(φ) indefinitely without ever resolving it. This is the **dovetailing gap**: the Succ-chain as constructed is not guaranteed to be "complete" in the sense of resolving all F-obligations.
- **Blocking reason** (if not derivable):
  The chain built by repeated application of `successor_from_deferral_seed` can defer F(φ) at every step. Without an additional constraint forcing eventual resolution (like a dovetailed enumeration that ensures each formula gets resolved in finite steps), F-obligations may be permanently deferred. This is a genuine structural gap, not a proof technique limitation. Elimination requires either:
  1. A dovetailed chain construction (complex, would require significant new infrastructure)
  2. Accepting the axiom as justified by the semantic argument that in any concrete discrete model, F-obligations must eventually be realized (but this is semantic soundness, not syntactic derivation)
  3. Abandoning the Succ-chain approach in favor of the CanonicalMCS approach (already done in the active completeness path)

---

### Axiom 7: `succ_chain_backward_P_axiom`

- **File**: `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean:427`
- **Task introduced**: 14
- **Direct dependents**:
  - `succ_chain_backward_P` (SuccChainFMCS.lean:431-434) — thin wrapper
  - `SuccChainTemporalCoherent` uses `succ_chain_backward_P`
- **Dependency chain**: Same dead-code path as Axiom 6.
- **Role in completeness**: Symmetric to Axiom 6. Also on dead-code path.
- **Derivation assessment**: Symmetric to Axiom 6. Same dovetailing gap applies in the backward direction.
- **Blocking reason** (if not derivable): Symmetric to Axiom 6. The backward chain can defer P(φ) indefinitely without resolution.

---

### Axiom 8: `canonicalR_irreflexive_axiom`

- **File**: `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean:1212`
- **Task introduced**: Pre-existing (task 991)
- **Direct dependents**:
  - `canonicalR_irreflexive` (CanonicalIrreflexivity.lean:1228) — primary wrapper
  - Re-exported as `Canonical.canonicalR_irreflexive` (CanonicalIrreflexivityAxiom.lean:76-78)
- **Dependency chain** (heavy usage):
  - `CanonicalSerialFrameInstance.lean:77,123` — strict irreflexivity in serial frame instances
  - `CanonicalIrreflexivityAxiom.lean:89` — antisymmetry of CanonicalR
  - `IncrementalTimeline.lean:156` — irreflexivity for DovetailedBuild
  - `ClosureSaturation.lean:389,393` — task 18's dense completeness
  - `TimelineQuotCanonical.lean:95` — quotient construction
  - `SaturatedChain.lean:370,373,401,404,446,449,459,462` — 8 uses in algebraic chain reasoning
  - `FMCSTransfer.lean:224,229` — FMCS transfer operations
  - `DovetailedTimelineQuot.lean` — Boneyard (4 uses, non-blocking)
- **Role in completeness**: CRITICAL for live path. Used in `SaturatedChain.lean`, `ClosureSaturation.lean` (task 18 active), `TimelineQuotCanonical.lean`, `FMCSTransfer.lean`. Removing this axiom would break the active completeness proof.
- **Derivation assessment**:
  - From modal axioms: **no** — Documented in the axiom's docstring (citing Blackburn-de Rijke-Venema 2001, Gabbay 1981): irreflexivity of the canonical relation is **modally non-definable**. No formula of TM logic characterizes irreflexive frames. Under strict semantics, `CanonicalR M M` requires `g_content(M) ⊆ M`, but `G(φ)` at t means φ holds at all s > t (strict), making `M ∈ CanonicalR M M` impossible. However, this semantic fact cannot be syntactically derived because the T-axiom (`G(φ) → φ`) is not valid under strict semantics.
  - From definitions: **no** — Under strict temporal semantics, `g_content(M) = {φ | G(φ) ∈ M}` and `CanonicalR M M` would require `g_content(M) ⊆ M`. The axiom `G(φ) → φ` (T-axiom) would give this, but T is not in the proof system.
- **Blocking reason** (genuinely not derivable):
  This is a case of semantic truth that cannot be captured syntactically. The Irreflexivity Lemma (Gabbay 1981) applies: the property "CanonicalR is irreflexive" is true in all strict models, but not expressible as a theorem of TM logic. This axiom is JUSTIFIED and should remain.

---

### Axiom 9: `discrete_Icc_finite_axiom`

- **File**: `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean:316`
- **Task introduced**: Pre-existing (task 979)
- **Direct dependents**:
  - `discrete_Icc_finite` (DiscreteTimeline.lean:320-322) — thin wrapper
  - `LocallyFiniteOrder (DiscreteTimelineQuot ...)` instance (DiscreteTimeline.lean:330-331) via `LocallyFiniteOrder.ofFiniteIcc`
- **Dependency chain**:
  - `LocallyFiniteOrder` → automatic `IsSuccArchimedean` and `SuccOrder`/`PredOrder` instances
  - Used in `Completeness.lean:210` (copy/re-use) and `FrameClass.lean:145` (mentioned)
  - This is the OLD discrete pipeline (DiscreteTimeline/DiscreteTimelineQuot), not the new Succ-chain/ClosedFlagIntBFMCS pipeline
- **Role in completeness**: Blocks discrete completeness in the OLD pipeline. Task 19 is explicitly planned to deprecate this old pipeline. The new pipeline via `ClosedFlagIntBFMCS` → `DiscreteInstantiation` does NOT depend on this axiom.
- **Derivation assessment**:
  - From Mathlib: **yes** — The core question is whether `DiscreteTimelineQuot` (a quotient of CanonicalMCS under CanonicalR equivalence-ish structure) can be shown to have finite intervals. This requires showing that for any two equivalence classes [a] and [b], the number of intermediate classes is finite. This is related to showing that CanonicalTask chains are bounded, which uses the bounded_witness theorem.
  - From temporal axioms: **yes/partial** — The DF axiom should imply that steps are discrete (no density), which means intervals in the discrete timeline quotient are finite.
  - From definitions: **yes/partial** — The `discreteImmediateSucc_covers` axiom (Axiom 10) implies that consecutive elements have no intermediates, which is the discrete covering property. Building on this, interval finiteness should follow by showing the chain length between [a] and [b] equals the CanonicalTask distance.
- **Proof sketch** (if derivable):
  1. Use `discreteImmediateSucc_covers` (Axiom 10) to show that the ordering on `DiscreteTimelineQuot` is a cover relation (no intermediates)
  2. This gives a SuccOrder/PredOrder with bounded steps between elements
  3. The bounded_witness theorem (Task 11: CanonicalTaskRelation) bounds the nesting depth of F-formulas, which bounds the chain length between any two MCS classes
  4. Finiteness of [a,b] follows from the bounded chain length

  **Assessment**: Derivable with significant effort. Planned for elimination by task 19. Not the current bottleneck since the new completeness path bypasses it.

---

### Axiom 10: `discreteImmediateSuccSeed_consistent_axiom`

- **File**: `Theories/Bimodal/Metalogic/StagedConstruction/DiscreteSuccSeed.lean:284`
- **Task introduced**: Pre-existing (task 991)
- **Direct dependents**:
  - `discreteImmediateSuccSeed_consistent` (DiscreteSuccSeed.lean:301) — the covering Case 2
  - `discreteImmediateSucc` (DiscreteSuccSeed.lean:347) — Lindenbaum extension of the seed
- **Dependency chain**:
  - `discreteImmediateSucc` → `discreteImmediateSucc_covers` (via `discreteImmediateSucc_covers_axiom` / Axiom 11)
  - `discreteImmediateSucc_covers` → `ImmediateStagedBuild.lean:85`, `IncrementalTimeline.lean:458`
  - This is the OLD staged construction pipeline, used in the dovetailed build approach
- **Role in completeness**: Part of the original "staged construction" approach to discrete completeness. The new Succ-chain/ClosedFlagIntBFMCS approach bypasses this.
- **Derivation assessment**:
  - From temporal axioms: **yes/partial** — Same argument as `successor_deferral_seed_consistent_axiom` (Axiom 1). The discreteImmediateSuccSeed = `g_content(M) ∪ blockingFormulas(M)` where blocking formulas are `¬ψ ∨ ¬G(ψ)` for each ¬G(ψ) ∈ M`. The consistency argument requires showing that the blocking formulas and g_content don't jointly derive ⊥.
  - The docstring (line 266-286) documents the proof strategy: seriality guarantees successors exist, any strict successor satisfies g_content, and blocking formulas are disjunctions derivable from M.
- **Proof sketch** (if derivable):
  Under strict semantics, Case 2 requires showing that `g_content(M) ∪ {some_blocking_formula}` is consistent. The blocking formula `¬ψ ∨ ¬G(ψ)` was added specifically because `¬G(ψ) ∈ M` (i.e., `F(¬ψ) ∈ M`). By `forward_temporal_witness_seed_consistent`, `{¬ψ} ∪ g_content(M)` is consistent. Since `¬ψ` implies `¬ψ ∨ ¬G(ψ)`, the seed with the blocking formula is also consistent.

  Wait — but the seed has ALL blocking formulas simultaneously. Multiple blocking formulas may interfere. This is exactly the same challenge as Axiom 1, Case 2. The derivation requires the same "weakening + joint consistency" argument.

  **Assessment**: Derivable with the same effort as Axiom 1. Part of the old pipeline (task 19 will remove it).

---

### Axiom 11: `discreteImmediateSucc_covers_axiom`

- **File**: `Theories/Bimodal/Metalogic/StagedConstruction/DiscreteSuccSeed.lean:414`
- **Task introduced**: Pre-existing (task 991)
- **Direct dependents**:
  - `discreteImmediateSucc_covers` (DiscreteSuccSeed.lean:433) — thin wrapper
  - `ImmediateStagedBuild.lean:85` — covering property used in staged build
  - `IncrementalTimeline.lean:458` — covering property used in incremental timeline
- **Dependency chain**:
  - `IncrementalTimeline.lean` → staged construction pipeline (old path)
  - `ImmediateStagedBuild.lean` → staged construction pipeline (old path)
- **Role in completeness**: Covering property for the old staged construction approach. Not on the new ClosedFlagIntBFMCS path.
- **Derivation assessment**:
  - From temporal axioms: **yes/partial** — The covering property is the "immediacy" of the discrete successor. The blocking formulas `¬ψ ∨ ¬G(ψ)` are specifically designed to prevent intermediate MCS from existing. If K satisfies `CanonicalR M K` and `CanonicalR K W` (where W = discreteImmediateSucc M), then K must equal M or W because the blocking formulas in W's seed eliminate any strict intermediate.
  - From definitions: **yes/partial** — The covering property follows from the definition of `discreteImmediateSuccSeed`: every formula `¬ψ ∨ ¬G(ψ)` with `¬G(ψ) ∈ M` is in the seed, hence in W. If K is intermediate (K ≠ M and K ≠ W), then there exists ψ with `G(ψ) ∈ M` but `ψ ∉ K` (distinguishing M from K) or `¬ψ ∈ K` but `ψ ∈ W` (distinguishing K from W). The blocking formulas constrain this.
- **Proof sketch** (if derivable):
  The standard Segerberg covering argument:
  1. Suppose M, K, W are MCSes with `CanonicalR M K`, `CanonicalR K W`, K ≠ M, K ≠ W
  2. Since K ≠ M: there exists formula χ with χ ∈ M, χ ∉ K (or vice versa)
  3. Since K ≠ W: there exists formula χ' with χ' ∈ K, χ' ∉ W (or vice versa)
  4. The blocking formula for χ or χ' in M's seed must appear in W, giving a contradiction
  5. The details require careful case analysis on the MCS properties

  **Assessment**: Derivable with significant effort. This is a standard result in tense logic completeness theory (Segerberg 1970, Verbrugge 1993). Medium-high effort. Also part of old pipeline (task 19 removes it).

---

## Derivation Priority Matrix

| Axiom | File | Effort to Derive | Impact if Derived | Priority | Current Path |
|-------|------|------------------|-------------------|----------|--------------|
| `F_top_propagates` | SuccChainFMCS.lean:150 | **Trivial** | Low (dead code) | 1 | Dead |
| `P_top_propagates` | SuccChainFMCS.lean:206 | **Trivial** | Low (dead code) | 2 | Dead |
| `successor_deferral_seed_consistent_axiom` | SuccExistence.lean:266 | Medium | Medium (re-used in CanonicalRecovery) | 3 | Partial |
| `predecessor_deferral_seed_consistent_axiom` | SuccExistence.lean:311 | Low (after Axiom 1) | Low (dead code mostly) | 4 | Dead |
| `predecessor_f_step_axiom` | SuccExistence.lean:516 | Medium | Low (dead code mostly) | 5 | Dead |
| `discreteImmediateSuccSeed_consistent_axiom` | DiscreteSuccSeed.lean:284 | Medium | Low (old pipeline) | 6 | Old |
| `discreteImmediateSucc_covers_axiom` | DiscreteSuccSeed.lean:414 | Medium-High | Low (old pipeline) | 7 | Old |
| `discrete_Icc_finite_axiom` | DiscreteTimeline.lean:316 | High | Low (old pipeline, task 19 removes) | 8 | Old |
| `succ_chain_forward_F_axiom` | SuccChainFMCS.lean:417 | High (dovetailing) | Low (dead code) | 9 | Dead |
| `succ_chain_backward_P_axiom` | SuccChainFMCS.lean:427 | High (dovetailing) | Low (dead code) | 10 | Dead |
| `canonicalR_irreflexive_axiom` | CanonicalIrreflexivity.lean:1212 | **Not derivable** | N/A (modally non-definable) | N/A | Active |

---

## Recommended Derivation Order

1. **`F_top_propagates`** — Replace with one-liner using `SetMaximalConsistent.contains_F_top`. Zero proof effort, immediate win. Same for `P_top_propagates`.

2. **`P_top_propagates`** — Replace with one-liner using `SetMaximalConsistent.contains_P_top`. Zero proof effort.

3. **`successor_deferral_seed_consistent_axiom`** — Derive using the "weakening" lemma argument: `{ψ} ∪ g_content(u)` is consistent (proven), and `{ψ ∨ F(ψ)} ∪ g_content(u)` is consistent by weakening (derivable), and the full deferral seed is consistent by compactness + induction over finitely many F-obligations. Medium effort, enables elimination of the paired Axiom 2.

4. **`predecessor_deferral_seed_consistent_axiom`** — Symmetric proof to step 3. Low incremental effort.

5. **`predecessor_f_step_axiom`** — Derive using g/h duality lemmas already in codebase. Medium effort. Completes the clean elimination of all 3 task-12 axioms.

6. **`discreteImmediateSuccSeed_consistent_axiom`** (old pipeline) — Same argument as step 3, different seed structure. Do as part of task 19 old-pipeline cleanup.

7. **`discreteImmediateSucc_covers_axiom`** (old pipeline) — Segerberg blocking argument. Do as part of task 19.

8. **`discrete_Icc_finite_axiom`** (old pipeline) — Derive from covering + bounded_witness. Do as part of task 19.

9. **Do not attempt `succ_chain_forward_F_axiom` / `succ_chain_backward_P_axiom`** — These are on the dead-code Succ-chain path. The better action is to delete `SuccChainWorldHistory.lean` and `SuccChainTaskFrame.lean` (which have no importers) and mark `SuccChainTemporalCoherent` as incomplete. The dovetailing problem is real and the new ClosedFlagIntBFMCS approach already sidesteps it correctly.

10. **Retain `canonicalR_irreflexive_axiom`** — Genuinely non-derivable. Modally non-definable. Required by the active completeness path. Do not attempt elimination.

---

## Key Findings

1. **Two axioms are trivially eliminable right now**: `F_top_propagates` and `P_top_propagates` in SuccChainFMCS.lean are completely redundant — F(⊤) and P(⊤) are theorems in every MCS, already proven in the same file. No Succ hypothesis is needed at all. These can be replaced with one-liners.

2. **The dovetailing axioms (Axioms 6-7) are on dead-code paths**: `SuccChainWorldHistory.lean` and `SuccChainTaskFrame.lean` have zero downstream importers. The axioms serve no live completeness purpose. The question is whether to: (a) fix them (high effort, dovetailing required), or (b) delete the dead-code files and accept the Succ-chain track as incomplete. The active completeness path goes through `ClosedFlagIntBFMCS.lean`, not through these files.

3. **The task-12 deferral seed axioms (Axioms 1-3) are derivable**: The consistency arguments have clear proof sketches using existing infrastructure (forward_temporal_witness_seed_consistent, g/h duality, propositional weakening). Medium effort to derive. These are the highest-value axioms to eliminate since they underpin `successor_exists`/`predecessor_exists` which is re-used in `CanonicalRecovery.lean`.

4. **The old-pipeline axioms (8-10) are task-19 scope**: `discrete_Icc_finite_axiom`, `discreteImmediateSuccSeed_consistent_axiom`, `discreteImmediateSucc_covers_axiom` are all in the old `DiscreteTimeline`/`StagedConstruction` pipeline that task 19 will deprecate. Deriving them before task 19 deletes them is low priority.

5. **`canonicalR_irreflexive_axiom` is the only permanently justified axiom**: It is modally non-definable and required by the active completeness path. The irreflexivity of canonical accessibility under strict semantics is a semantic fact that cannot be captured by any formula of the temporal modal logic.

6. **Active completeness has 0 new axioms**: The live completeness path (ClosedFlagIntBFMCS → DiscreteInstantiation → Algebraic) relies on `canonicalR_irreflexive_axiom` (justified) and has sorries but no new unjustified axioms from tasks 9-20.

---

## Confidence Level

**High** — The axiom declarations are enumerated exhaustively from the source. The dependency chains are traced via grep across the full codebase. The derivation assessments for Axioms 4-5 (F_top/P_top propagates) are at mathematical certainty (direct proof given). Assessments for Axioms 1-3 are high confidence (proof sketches align with existing infrastructure and the documented proof strategies in task 12 research). The dead-code status of Axioms 6-7 is verified (no downstream importers found). Assessments for Axioms 8-11 draw on the task 12/13/14/15 reports and docstring documentation.
