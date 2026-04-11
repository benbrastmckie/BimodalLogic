# Implementation Plan: BXPoint-backed HintikkaStepOracle

- **Task**: 99 - bxpoint_backed_hintikka_oracle
- **Status**: [COMPLETED]
- **Effort**: 10-15 hours
- **Dependencies**: None (parent task 98 Phase 4 blocked on this)
- **Research Inputs**: specs/099_bxpoint_backed_hintikka_oracle/reports/01_spawn-analysis.md
- **Artifacts**: specs/099_bxpoint_backed_hintikka_oracle/plans/01_bxpoint-backed-oracle.md
- **Standards**:
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/context/formats/plan-format.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Task 98 Phase 4 is blocked: `chain_step_seed_consistent` cannot be proved against the current `HintikkaPoint` abstraction, whose `locally_consistent` field is only a pairwise property and does not yield the derivation-level consistency required by Teammate A's §3.3 reduction. This task implements Round 4 Option 4a (Teammate B): strengthen `HintikkaStepOracle` (`Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Construction.lean:452`) so every output Hintikka point carries a concrete `BXPoint` witness `w` with `h.formulas = sigma_signature w`, thread `bx_forward_witness` (`Frame.lean:164`) through `hintikka_chain_exists`, and discharge `chain_step_seed_consistent` via a one-line subset witness into `w.is_mcs.1`, mirroring the `h_neg_in = false` branch of `enriched_seed_consistent_until` (`Realization.lean:271-276`). Scope is strictly `Construction.lean` plus any downstream caller adjustments; Phases 5-8 of plan v3 are untouched. Definition of done: `lake build` clean, zero new `sorry`s, zero new axioms, `chain_step_seed_consistent` fully proved, zero-debt compliant.

### Research Integration

The spawn analysis (`reports/01_spawn-analysis.md`) identifies the structural root cause and the exact fix pattern:

- **Teammate B** (Round 4): `SetConsistent` is defined as "every finite subset is consistent", so any subset of an MCS is trivially consistent. Making the chain carry a `BXPoint` witness at construction time collapses the proof to a subset witness.
- **Teammate C**: The MCS-subset pattern is already realized in `enriched_seed_consistent_until` lines 226-276. The `h_neg_in = false` branch (lines 271-276) is the direct template.
- **Template shape** (Realization.lean:271-276):
  ```
  have h_L_in_w : ∀ α ∈ L, α ∈ w.formulas := ...
  exact w.is_mcs.1 L h_L_in_w ⟨d⟩
  ```
- **Threading point**: `bx_forward_witness w ψ h_F` returns `⟨v, h_wv, h_ψv⟩` (used in Realization.lean:347), giving the `BXPoint` witness needed for each successor.
- **Buffer**: Teammate C flagged a possible scope fix to `enriched_g_neg_bigconj_mem` — included as contingency.

### Prior Plan Reference

No prior plan for task 99. Parent task 98's plan v3 (`specs/098_research_filtration_quasimodel_pivot/plans/03_filtration-quasimodel-pivot.md`) is referenced only to know which obligation (`chain_step_seed_consistent`) this task must discharge. This plan does not copy or modify plan v3.

### Roadmap Alignment

`specs/ROAD_MAP.md` not inspected for this scoped unblocker task; advancing this task advances the parent roadmap item represented by task 98 (filtration quasimodel pivot, Until/Since chain construction). No independent roadmap items.

## Goals & Non-Goals

**Goals**:
- Modify `HintikkaStepOracle` in `Construction.lean` so its existential witness carries a `BXPoint` backing `w` with `h'.formulas = sigma_signature w` (or equivalent equality/coercion).
- Thread `bx_forward_witness` through `hintikka_chain_exists` so every point in the constructed `HintikkaRawChain` has a reachable `BXPoint` witness.
- Prove `chain_step_seed_consistent` via the one-line MCS-subset route, mirroring `enriched_seed_consistent_until`'s `h_neg_in = false` branch.
- Leave Phases 5-8 of parent plan v3 structurally untouched (call sites adjust to the new signature but semantics are preserved).
- Zero-debt: `lake build` clean, 0 new `sorry`, 0 new `axiom`.

**Non-Goals**:
- Not addressing Phase 5 realization lifting (`realize_chain_step`) — that belongs to parent plan v3 Phase 5 (and plan v4 revision via sibling task 100/2).
- Not addressing Phase 6 locus-control exhaustiveness.
- Not modifying `HintikkaPoint`, `hintikka_step`, or `defect_count` definitions.
- Not touching `Since` dual (`HintikkaStepOracleSince`, Construction.lean:603) in this task — the Until fix establishes the pattern; the Since dual is mechanical and deferred to parent plan v3 Phase 4 completion or a follow-up.
- Not discharging the `HintikkaStepOracle` itself (that is the Phase 5 Lindenbaum construction).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Changing `HintikkaStepOracle` signature breaks downstream callers (`hintikka_chain_exists`, Phase 4 users) | M | H | Phase 2 explicitly threads through the recursion; Phase 4 buffers for downstream repair. |
| `h.formulas = sigma_signature w` equality is too rigid; an existential coercion or refinement field is needed | M | M | Prefer a refinement field `witness : BXPoint` with an equality/subset proposition rather than a def-level rewrite. Adjust in Phase 1 if type-check pressure appears. |
| `bx_forward_witness` does not directly produce a successor matching `hintikka_step` relation | M | M | Use existing pattern from Realization.lean:347; the `bx_le w v` witness already feeds into the `g/h_content` lemmas that discharge `hintikka_step`. |
| `enriched_g_neg_bigconj_mem` scope fix (Teammate C §C.2) becomes necessary | L | M | Phase 4 is a dedicated buffer phase for exactly this contingency. |
| `chain_step_seed_consistent` statement itself needs refinement to reference the new witness field | L | H | Phase 3 adjusts the statement to universally quantify over the witness produced by Phase 1. |
| Scope creep into `HintikkaStepOracleSince` dual | L | M | Non-Goals explicitly excludes it; leave a TODO comment pointing to this task's pattern for future work. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Phases within the same wave can execute in parallel.

### Phase 1: Strengthen `HintikkaStepOracle` output type with BXPoint witness [COMPLETED]

- **Goal:** Modify the `HintikkaStepOracle` definition in `Construction.lean:452` so every output point carries a concrete `BXPoint` witness `w` with a structural link `h'.formulas = sigma_signature w` (or a refinement predicate of equivalent strength). Type-checks only; no proofs yet.
- **Tasks:**
  - [ ] Read `Construction.lean:448-458` and identify the existential shape of `HintikkaStepOracle`.
  - [ ] Confirm the import availability of `BXPoint` and `sigma_signature` in `Construction.lean` (add imports if missing, staying within `BXCanonical.Quasimodel`).
  - [ ] Rewrite `HintikkaStepOracle` to add an additional existential component: `∃ w : BXPoint, h'.formulas = sigma_signature w` (or equivalent) alongside the current `hintikka_step h h'` and disjunctive clauses.
  - [ ] Decide between (a) in-place existential or (b) introducing a small helper structure `WitnessedHintikka` carrying `(h : HintikkaPoint, w : BXPoint, eq : h.formulas = sigma_signature w)`; prefer (a) unless type-check ergonomics force (b).
  - [ ] `lean_goal` / type-check the definition in isolation; do not yet touch `hintikka_chain_exists`.
- **Timing:** 2h
- **Depends on:** none

### Phase 2: Thread `bx_forward_witness` through `hintikka_chain_exists` [COMPLETED]

- **Goal:** Update `hintikka_chain_exists` (`Construction.lean:556-598`) so the recursion constructs each successor via the oracle and carries the `BXPoint` witness forward. Every point in the returned `HintikkaRawChain` is backed by an explicit `BXPoint`.
- **Tasks:**
  - [ ] Adjust the `obtain` pattern at `Construction.lean:581` to destructure the new witness component from the oracle output (`obtain ⟨h', w', h_eq, h_step, h_cases⟩ := oracle h0 h_target h_psi`).
  - [ ] In the two recursive branches (witness-reached and defect-decreased), carry `w'` forward — either as an auxiliary existential returned by the main theorem or as a side-condition propagated via the strong induction.
  - [ ] Strengthen the theorem statement of `hintikka_chain_exists` to also produce, for every point in the chain, a `BXPoint` witness. Two shapes to consider:
    - (a) Add a predicate `ChainWitnessed : HintikkaRawChain Sigma → Prop` requiring every point is sigma-signature of some `BXPoint`, and return `∃ c, ... ∧ ChainWitnessed c`.
    - (b) Strengthen `HintikkaRawChain` to bundle the witnesses directly (prefer only if (a) causes rewrite churn).
  - [ ] Re-run type-check on the updated `hintikka_chain_exists`; ensure the strong-induction step still goes through.
  - [ ] Keep the existing `HintikkaRawChain.singleton` / `cons` helpers usable; add new witnessed-chain smart constructors only if strictly necessary.
- **Timing:** 2-3h
- **Depends on:** 1

### Phase 3: Prove `chain_step_seed_consistent` via MCS-subset route [COMPLETED]

- **Goal:** Introduce (or relocate from parent plan v3 Phase 4 scaffolding) the lemma `chain_step_seed_consistent` and discharge it using the `w.is_mcs.1` subset witness, mirroring `enriched_seed_consistent_until`'s `h_neg_in = false` branch (Realization.lean:271-276).
- **Tasks:**
  - [ ] Locate any stub for `chain_step_seed_consistent` left by task 98 Phase 4 scaffolding (search `Construction.lean`, `Realization.lean`, and adjacent modules).
  - [ ] State the lemma in terms of the Phase 2 witnessed chain: given a chain point `h_i` with BXPoint witness `w_i`, its `SetConsistent` obligation against the seed required by Phase 4 follows from `w_i.is_mcs.1`.
  - [ ] Write the proof body mirroring Realization.lean:271-276:
    - `intro L hL ⟨d⟩`
    - Build `h_L_in_w : ∀ α ∈ L, α ∈ w_i.formulas` via `h_i.formulas = sigma_signature w_i` and the seed membership hypothesis.
    - Close with `exact w_i.is_mcs.1 L h_L_in_w ⟨d⟩`.
  - [ ] Use `lean_multi_attempt` to test the final `exact` closing tactic before committing to the file.
  - [ ] Ensure no `sorry` is introduced (search the updated file for `sorry`, expect 0 new).
- **Timing:** 2-3h
- **Depends on:** 2

### Phase 4: Repair downstream callers and apply `enriched_g_neg_bigconj_mem` buffer fix if needed [COMPLETED]

- **Goal:** Restore `lake build` by adjusting any direct callers of the changed `HintikkaStepOracle` / `hintikka_chain_exists` signatures. Apply Teammate C §C.2 scope fix to `enriched_g_neg_bigconj_mem` only if the updated type-check flags a concrete gap.
- **Tasks:**
  - [ ] `grep -r "HintikkaStepOracle\|hintikka_chain_exists" Theories/` to enumerate callers.
  - [ ] For each caller: adapt the destructure to consume (or ignore) the new witness component; no semantic change.
  - [ ] If `enriched_g_neg_bigconj_mem` shows a scope error, apply Teammate C's §C.2 fix (localized to `EnrichedClosure.lean` or `Realization.lean` as appropriate). Otherwise, skip.
  - [ ] Confirm Phase 5/6/7/8 files of parent plan v3 are untouched (scope check).
  - [ ] Add brief TODO comment near `HintikkaStepOracleSince` (Construction.lean:603) noting the same witness-strengthening is required for the Since dual, pointing back to task 99.
- **Timing:** 2-3h
- **Depends on:** 3

### Phase 5: Zero-debt verification [COMPLETED]

- **Goal:** Prove the build is clean and zero-debt: `lake build` clean, 0 new `sorry`, 0 new axioms, `chain_step_seed_consistent` actually closed.
- **Tasks:**
  - [ ] Run `lake build` on the full project (or `lake build Theories.Bimodal.Metalogic.BXCanonical.Quasimodel.Construction` as a narrower first pass).
  - [ ] `grep -c "sorry" Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Construction.lean` — compare against baseline to confirm 0 new.
  - [ ] Run `lean_verify chain_step_seed_consistent` (MCP) to confirm it is closed and has no fresh axioms beyond the standard classical/choice baseline already accepted by the project.
  - [ ] `lean_verify HintikkaStepOracle` and `lean_verify hintikka_chain_exists` for axiom health.
  - [ ] Record the final axiom set in a short note at the end of the plan's own artifact record or in the summary.
- **Timing:** 1-2h
- **Depends on:** 4

## Testing & Validation

- [ ] `lake build` completes with 0 errors and 0 new warnings in `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Construction.lean`.
- [ ] `grep -c "sorry" Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Construction.lean` returns the baseline count (no new sorries).
- [ ] `lean_verify Bimodal.Metalogic.BXCanonical.Quasimodel.chain_step_seed_consistent` reports closed and lists only the baseline axioms used elsewhere in the project.
- [ ] `lean_verify Bimodal.Metalogic.BXCanonical.Quasimodel.HintikkaStepOracle` and `hintikka_chain_exists` pass without new axioms.
- [ ] No changes outside `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Construction.lean` (plus an optional `EnrichedClosure.lean` / `Realization.lean` touch for the §C.2 buffer fix, only if needed).

## Artifacts & Outputs

- Modified: `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Construction.lean`
- Optional (only if Phase 4 buffer fires): `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/EnrichedClosure.lean` or `Realization.lean` (localized §C.2 scope fix).
- Summary: `specs/099_bxpoint_backed_hintikka_oracle/summaries/01_bxpoint-backed-oracle-summary.md` (post-implementation).

## Rollback/Contingency

- Each phase is a single logical edit to `Construction.lean`. If a phase fails to type-check and cannot be rescued within its 2-3h budget:
  - `git restore Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Construction.lean` to revert that phase's edits.
  - Mark the phase `[PARTIAL]` and record the obstruction in the task's errors.json entry.
- If Phase 1's in-place existential causes excessive destructure churn in Phase 2, fall back to a small `WitnessedHintikka` helper structure (noted as mitigation in the risks table) and re-run Phases 1-2.
- If `enriched_g_neg_bigconj_mem` requires a non-trivial scope fix beyond the Teammate C §C.2 one-liner, stop, mark this task `[BLOCKED]`, and spawn a new task targeting that specific fix — do not expand scope here.
- If the Until fix works but exposes that the Since dual is also needed to close parent plan v3 Phase 4, leave the Since dual as a follow-up task (explicitly out of scope per Non-Goals); parent plan v3 Phase 4 will receive its own completion pass.
