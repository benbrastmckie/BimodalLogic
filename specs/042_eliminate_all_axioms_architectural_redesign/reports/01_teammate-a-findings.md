# Metalogic Audit: Axioms, Architecture, and Semantic Confusion

**Teammate A findings** — Task 42 research phase

---

## Key Findings

- There are **9 axioms** in production Metalogic code (excluding Boneyard/Examples) across 5 files
- `ExistsTask` is `CanonicalR` renamed — it is the basic modal accessibility relation (`g_content M ⊆ M'`), NOT the integer-indexed task reachability relation
- `CanonicalTask` is the semantically correct integer-indexed task relation, but it is used only in infrastructure files and is NOT plumbed into the main completeness path
- **W=D conflation is explicitly documented** in `CanonicalConstruction.lean` — a deprecated `DurationTransfer` approach conflates WorldState with D; the current `CanonicalTaskFrame` separates them but has an incorrect `d < 0 → False` design
- The `existsTask_irreflexive_axiom` is **logically inconsistent** with `existsTask_reflexive` (both are in the same file under reflexive semantics); the file acknowledges this
- The primary completeness path (`SuccChainCompleteness.lean`) depends on 5 axioms and 1 sorry, all in the critical path
- `succ_chain_fam_p_step` has an active `sorry` for the forward-chain case (n ≥ 0) that is on the completeness path

---

## Axiom Analysis

| Axiom Name | File | Property Asserted | Used By | Why Not Proven | Elimination Path |
|------------|------|-------------------|---------|----------------|-----------------|
| `successor_deferral_seed_consistent_axiom` | `SuccExistence.lean:266` | Deferral seed `g_content(u) ∪ {φ ∨ F(φ) \| F(φ) ∈ u}` is consistent when `F(⊤) ∈ u` | `successor_exists` → `SuccChainFMCS` → completeness | Requires showing g_content + deferral disjunctions are jointly satisfiable; g_content ⊈ M under strict semantics blocks naive proof | Prove directly: each deferral disjunction `φ ∨ F(φ)` is derivable from `F(φ) ∈ u`; the seed consistency follows from g_content consistency + derivability of each disjunction from existing content |
| `predecessor_deferral_seed_consistent_axiom` | `SuccExistence.lean:311` | Symmetric: predecessor seed consistent when `P(⊤) ∈ u` | `predecessor_exists` → completeness | Same obstruction as above, past direction | Same elimination path, past direction |
| `predecessor_f_step_axiom` | `SuccExistence.lean:516` | F-obligations of predecessor resolve into u or f_content(u) | `predecessor_succ` → completeness | Requires showing f_content(predecessor) ⊆ u ∪ f_content(u); the seed construction constrains P not F | Requires either: (1) derive from temporal duality (H/P symmetry + past seed constraints), or (2) redesign predecessor construction to directly satisfy F-step |
| `f_nesting_boundary` | `SuccChainFMCS.lean:615` | Given F(φ) ∈ M, ∃ d ≥ 1: iter_F d φ ∈ M ∧ iter_F(d+1) φ ∉ M | `succ_chain_forward_F` → completeness | Requires well-founded recursion on F-nesting; infinite F-nesting is inconsistent but proving the boundary exists needs structural induction on formula complexity | Prove by induction on formula complexity; F-nesting depth is bounded by formula complexity in an MCS; use `finite_subformula_property` or MCS consistency |
| `p_nesting_boundary` | `SuccChainFMCS.lean:727` | Symmetric: P-nesting boundary exists | `succ_chain_backward_P` → completeness | Symmetric to f_nesting_boundary | Symmetric elimination path |
| `existsTask_irreflexive_axiom` | `CanonicalIrreflexivity.lean:279` | `¬ExistsTask M M` for all MCS M | `DiscreteTimeline`, `CantorApplication`, `DovetailedTimelineQuot` | **Semantically FALSE** under reflexive semantics; contradicts the proven `existsTask_reflexive` | Delete or replace with per-construction strictness (the file already provides `strict_of_formula_in_g_content_not_in_source` for this) |
| `discrete_Icc_finite_axiom` | `Domain/DiscreteTimeline.lean:319` | Closed intervals in DiscreteTimelineQuot are finite | `LocallyFiniteOrder` instance, `SuccOrder` | Task 979 exhaustively explored; syntactic DF → structural covering bridge fails for canonical MCS construction | The SuccChain approach (current completeness path) does NOT use this; it is only needed for the old DiscreteTimeline quotient path which is superseded |
| `discreteImmediateSuccSeed_consistent_axiom` | `StagedConstruction/DiscreteSuccSeed.lean:300` | Seed for discrete immediate successor is consistent | Old staged construction (StagedConstruction path) | Under strict semantics, g_content(M) ⊈ M obstructs direct proof | Not on current completeness path; may be eliminable if StagedConstruction path is dropped |
| `discreteImmediateSucc_covers_axiom` | `StagedConstruction/DiscreteSuccSeed.lean:430` | No MCS exists strictly between M and its discrete immediate successor | Old staged construction path | Syntactic → structural covering bridge fails; documented as fundamental gap | Not on current completeness path; drop with StagedConstruction if abandoned |

---

## ExistsTask vs CanonicalTask Analysis

### Definitions

**ExistsTask** (defined in `CanonicalFrame.lean:68`):
```lean
def ExistsTask (M M' : Set Formula) : Prop :=
  g_content M ⊆ M'
```
This is the **basic modal accessibility relation** — `M'` is G-accessible from `M`. It is exactly `CanonicalR` (which is an `abbrev` alias for it). The name "ExistsTask" was chosen because "there exists a temporal task connecting M to M'", but this is misleading: ExistsTask is a binary predicate on MCS pairs, not an integer-indexed relation.

**CanonicalTask** (defined in `CanonicalTaskRelation.lean:167`):
```lean
def CanonicalTask (u : Set Formula) (n : Int) (v : Set Formula) : Prop :=
  match n with
  | Int.ofNat k     => CanonicalTask_forward u k v
  | Int.negSucc k   => CanonicalTask_backward u (k + 1) v
```
This is the **integer-indexed task reachability relation** — "v is reachable from u in exactly n Succ steps." This is what the `TaskFrame.task_rel` semantics requires: `task_rel w d u` relates worlds connected by a task of duration d.

### Semantic Difference

- `ExistsTask M M'` = M' is a temporal successor of M (non-deterministic, no duration)
- `CanonicalTask u n v` = v is exactly n steps from u via the Succ chain (deterministic, integer duration)

For completeness, **CanonicalTask is what matters**. The TaskFrame semantics requires `task_rel w d u`, and `CanonicalTask` is exactly the canonical instantiation of `task_rel`. `ExistsTask` is used as the accessibility relation for G/H coherence (correctly), but calling it "ExistsTask" (implying task semantics) is confusing.

### Where ExistsTask Is Wrongly Primary

The `CanonicalTaskFrame` in `CanonicalConstruction.lean` defines:
```lean
canonical_task_rel M d N :=
  if d > 0 then CanonicalR M.val N.val   -- ExistsTask!
  else if d < 0 then CanonicalR N.val M.val
  else M = N
```

**This uses ExistsTask (= CanonicalR = g_content inclusion) as the task_rel for d > 0.** This is architecturally wrong: the task relation should use CanonicalTask (the n-step Succ chain), not the single-step G-accessibility. The consequence is that `CanonicalTaskFrame.task_rel M 1 N` holds iff `CanonicalR M N` (any G-accessible N), rather than iff N is exactly 1 Succ step from M.

A separate, correct `CanonicalTaskTaskFrame` exists in `SuccChainTaskFrame.lean` using `CanonicalTask` properly. However, the main completeness path (`CanonicalConstruction.lean`) uses the ExistsTask-based frame.

### Impact on Completeness

The SuccChain completeness path (`SuccChainCompleteness.lean`) uses:
- `SuccChainFMCS` — correctly built from Succ chains
- `SuccChainTaskFrame` — correctly uses `CanonicalTask` via `CanonicalTaskTaskFrame`
- The truth lemma operates on `succ_chain_fam` which is indexed by Int and correctly aligned with `CanonicalTask`

The older `CanonicalConstruction` path uses the ExistsTask-based frame and is semantically weaker (the preorder structure conflates 1-step and n-step accessibility).

---

## W=D Conflation Evidence

**Direct documentation in `CanonicalConstruction.lean:70-74`**:
```
The fully algebraic task relation (w + d = w', with WorldState = D) is constructed
separately in `DurationTransfer.canonicalTaskFrame`. That construction achieves
compositionality via `add_assoc` on the group structure, but conflates WorldState
with D. The canonical construction here keeps WorldState = MCS (the semantically
natural choice)...
```

**`DurationTransfer.lean`** implements the conflation: it treats the canonical timeline quotient T as both the WorldState type AND the duration type D. The pipeline is: `T ≃o ℤ` → transfer group structure to T → use T as both worlds and durations. This means "world w at time d is world w + d" — worlds are identified with time positions.

**Why this is wrong**: In the task semantics, worlds (MCSs, truth-configurations) and durations (integers, elapsed time) are conceptually distinct. `w · d = w'` means "executing task of duration d from world w can reach world w'". If W = D, then every duration d is also a world, and the task relation becomes a group action, losing the non-determinism of the actual task relation.

**Current status**: The W=D conflation is in `DurationTransfer.canonicalTaskFrame`, which exists in the codebase but is not on the primary completeness path. The primary path uses `CanonicalTaskFrame` (ExistsTask-based, W ≠ D) or `CanonicalTaskTaskFrame` (CanonicalTask-based, W ≠ D, SuccChain path). The W=D version appears to be legacy/experimental.

**Additional conflation**: The ExistsTask-based `CanonicalTaskFrame` partially conflates the concerns: it uses `d > 0 → CanonicalR M N` which conflates "duration > 0" with "any G-accessibility step" regardless of actual step count. The correct CanonicalTask separates these.

---

## Sorry Analysis

### Production sorries (excluding Boneyard/Examples):

| Location | Formula | On Completeness Path? | Root Cause |
|----------|---------|----------------------|------------|
| `SuccChainFMCS.lean:350` | `sorry` in `succ_chain_fam_p_step`, forward case (n ≥ 0) | **YES** — used by `succ_chain_backward_P` | P-step for forward chain elements: `successor_satisfies_p_step` not proven; needs temporal duality between F-step and P-step |
| `SuccChainTruth.lean:254` | `sorry` in Box backward case | No — comment says "not needed for completeness" | Modal backward requires BFMCS structure; singleton Omega doesn't support it |
| `DirectMultiFamilyBFMCS.lean:308,311` | Modal forward cross-family sorries | No — DirectMultiFamilyBFMCS not on primary path | Cross-family modal coherence at t≠0 requires S5, not present in TM |
| `DirectMultiFamilyBFMCS.lean:421` | Modal backward at t≠0 | No — same | Same root cause |
| `Canonical/CanonicalTimeline.lean:183` | `density_of_canonicalR` | No — CanonicalTimeline path not active | `Fφ → FFφ` derivation from `GGψ → Gψ` density axiom; proof direction issue |
| `Soundness.lean:572,576,579,582` | density, discreteness_forward, seriality_future, seriality_past | No — frame-restricted soundness still works | General soundness proof needs frame constraints; not connected to completeness |
| `Soundness.lean:602` | temporal_duality | No | Extension axiom swap soundness |

### Critical completeness path sorries:

Only `succ_chain_fam_p_step` (line 350 of `SuccChainFMCS.lean`) is on the active completeness path. The comment documents the issue: the forward chain is built via `successor_from_deferral_seed` which only ensures F-step, not P-step. P-step for forward-constructed elements requires proving temporal duality at the seed level.

---

## Recommended Architectural Changes

### Priority 1: Fix the sorry on the completeness path

**`succ_chain_fam_p_step` for n ≥ 0** (`SuccChainFMCS.lean:341`):

The forward chain satisfies F-step by construction (deferral seeds). To prove P-step, we need:
```
p_content(forward_chain k+1) ⊆ forward_chain k ∪ p_content(forward_chain k)
```

This should follow from the `Succ` definition itself: `Succ u v` requires `f_content u ⊆ v ∪ f_content v`, which by the temp_4/temp_4_past duality (G(φ) → G(G(φ))) implies the backward P-step. Specifically, since `Succ (forward_chain k) (forward_chain k+1)` holds, the `h_content_reverse` already proven in `SuccRelation.lean` should give the P-step.

### Priority 2: Prove the SuccExistence axioms

The three axioms in `SuccExistence.lean` are on the completeness path. The most approachable is:

**`successor_deferral_seed_consistent_axiom`**: The proof strategy is:
1. `g_content u` is consistent (existing theorem)
2. Each deferral disjunction `φ ∨ F(φ)` is derivable from `F(φ) ∈ u` (already proven as `deferral_disjunction_from_F`)
3. The full seed = g_content + derivable formulas, so consistency follows from g_content consistency + MCS closure
The gap is step 3: combining g_content consistency with the new disjunctions. This requires showing that adding derivable consequences of existing content preserves consistency — which should follow from the deduction theorem.

**`predecessor_f_step_axiom`**: More complex. Consider redesigning so the predecessor is constructed with an explicit F-step guarantee in its seed, analogous to how the successor seed guarantees F-step.

**`f_nesting_boundary` / `p_nesting_boundary`**: Prove by induction on the rank/complexity of φ. Every MCS has the finite model property (FMP), so F-nesting is bounded by formula complexity. Alternatively, use MCS negation completeness: if all iter_F n φ ∈ M, then M contains an infinite family of distinct formulas, violating that the proof system has formulas of bounded complexity. Note: formulas are not bounded in practice (they can be arbitrarily large), so this needs a more careful argument.

### Priority 3: Resolve the ExistsTask naming/architectural confusion

`ExistsTask` should be renamed back to `CanonicalR` or `GAccessibility` to clarify it is the G-modal accessibility relation, NOT the task relation. The task relation is `CanonicalTask`.

The `CanonicalTaskFrame` in `CanonicalConstruction.lean` uses `ExistsTask` (g_content inclusion) as the d > 0 relation. For a rigorous completeness theorem, the primary path should use `CanonicalTaskTaskFrame` (SuccChainTaskFrame) which correctly uses `CanonicalTask`.

### Priority 4: Delete the inconsistent irreflexivity axiom

`existsTask_irreflexive_axiom` (CanonicalIrreflexivity.lean:279) contradicts `existsTask_reflexive` (proven in the same file). Its three uses (DiscreteTimeline, CantorApplication, DovetailedTimelineQuot) are in non-primary construction paths. Replace with `strict_of_formula_in_g_content_not_in_source` (already provided) on a per-call-site basis.

### Priority 5: Classify/archive dead construction paths

The following are not on the SuccChain completeness path and carry most of the axiom burden:
- `StagedConstruction/` (DiscreteSuccSeed, DovetailedBuild, etc.) — 2 axioms
- `Domain/DiscreteTimeline.lean` — 1 axiom
- `Domain/DurationTransfer.lean` — W=D conflation
- `Canonical/CanonicalTimeline.lean` — 1 sorry
- `DirectMultiFamilyBFMCS.lean` — 3 sorries

Archiving these to Boneyard would reduce the visible axiom count by 3 and the sorry count by ~4.

---

## Confidence Level

**High confidence** on:
- Axiom inventory and file locations (direct code reading)
- ExistsTask vs CanonicalTask distinction (clear from definitions)
- W=D conflation evidence (directly documented in code)
- Which sorries/axioms are on the completeness path (tracing through imports)
- The inconsistency between `existsTask_irreflexive_axiom` and `existsTask_reflexive`

**Medium confidence** on:
- Elimination paths for the SuccExistence axioms (directions are sound, but difficulty of actual proof is unknown)
- Whether `f_nesting_boundary` is provable by formula-complexity induction (depends on the proof system's formal structure)
- The exact role of `succ_chain_fam_p_step` sorry vs whether `Succ` already implies P-step (needs more investigation into `SuccRelation.lean` definition)

**Low confidence** on:
- Whether the `DirectMultiFamilyBFMCS` modal sorries are fundamental or just missing lemmas (the analysis of modal backward at t≠0 suggests they may be fundamental given TM uses T/4, not T/4/5)
