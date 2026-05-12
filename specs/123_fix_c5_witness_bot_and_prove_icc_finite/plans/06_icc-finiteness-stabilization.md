# Implementation Plan: Icc Finiteness via Stabilization and Cascade Bounding

- **Task**: 123 - fix_c5_witness_bot_and_prove_icc_finite
- **Status**: [NOT STARTED]
- **Effort**: 5-8 hours
- **Dependencies**: None (all prerequisite infrastructure exists sorry-free)
- **Research Inputs**:
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/04_team-research.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/05_team-research.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/05_teammate-a-findings.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/05_teammate-b-findings.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/05_teammate-c-findings.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/05_teammate-d-findings.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/06_team-research.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/06_teammate-a-findings.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/06_teammate-b-findings.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/06_teammate-c-findings.md
  - specs/123_fix_c5_witness_bot_and_prove_icc_finite/reports/06_teammate-d-findings.md
- **Artifacts**: plans/06_icc-finiteness-stabilization.md (this file)
- **Standards**:
  - .claude/context/formats/plan-format.md
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/rules/lean4.md
- **Type**: lean4
- **Lean Intent**: true

### Research Integration

**Rounds 4-5** (prior plan v5): Confirmed convergence approach to limit L is mathematically sound for Steps 1-6 but has genuine gap at Step 7 (L-not-in-domain case). Pure order theory + real analysis convergence cannot close the sorry alone.

**Round 6** (`06_team-research.md`, 4 teammates): Critical revision of plan v5. Key findings:
- **Teammate A**: Verbrugge sidesteps our problem entirely (builds Z directly). Stabilization argument is sound but hard to formalize (~200+ lines). C5 insertions are local (witness placed near reference point). The `exists c, c.val = L` suffices is "too strong."
- **Teammate B**: All literature alternatives (Doets modified-Lob, Blackburn completeness-via-completeness, Reynolds k-equivalence) require prohibitive formalization infrastructure (Kamp's theorem, expressive completeness). Surjectivity and IsSuccArchimedean are logically equivalent -- no bypass possible.
- **Teammate C**: The naive stabilization assumption "finitely many counterexamples target [a,b]" is IMPRECISE -- x-coordinates range over all rationals, not just domain points. However, only counterexamples at domain points are effective (non-domain x is vacuously resolved). C4 counterexamples ARE relevant in discrete case. All three approaches A/B/C from plan v5 reduce to the same unsolved question. MCS periodicity along orbits is the most promising unexplored direction.
- **Teammate D**: IsSuccArchimedean is correctly prioritized. Alternative architectures cost 400-1000+ lines with the same core difficulty. 85% confidence the sorry is provable. Mixed case (task 122) is the real bottleneck beyond task 123.

**What plan v5 got right** (PRESERVED):
- Phase 1 [COMPLETED]: Mathlib imports + Order.succ/pred equality (`rfl` proofs)
- The convergence framework (Steps 1-6) compiles and is correct
- The `suffices` block (L-in-domain case contradiction) compiles
- Files to modify, definition of done

**What plan v5 got wrong** (REVISED):
- Approach A (convergence + L-in-domain): Has genuine mathematical gap. The gap-at-L scenario is order-theoretically consistent. The `exists c, c.val = L` reduction locks the proof into the hardest path.
- Approach B (Icc finiteness): Right direction but lacked cascade bounding analysis and concrete proof structure.
- Approach C (WellFoundedGT): Provably FALSE for LimitDomSubtype (has NoMaxOrder). Removed.

### Prior Plan Reference

Plan v5 (`05_construction-specific.md`) had 2 phases:
- **Phase 1** [COMPLETED]: Mathlib imports + `order_succ_eq` / `order_pred_eq` (both `rfl`)
- **Phase 2** [PARTIAL]: IsSuccArchimedean proof -- sorry remains at line 1303

Plan v4 (`04_issucc-archimedean.md`) had 3 phases:
- **Phase 1** [COMPLETED]: Same as v5 Phase 1
- **Phase 2** [PARTIAL]: Same as v5 Phase 2
- **Phase 3** [COMPLETED]: `succ_embed_surjective` rewritten to use IsSuccArchimedean

### Roadmap Alignment

This plan advances:
- "Discrete completeness: 1 sorry remains (task 122)" -- closing `succ_embed_surjective` makes the discrete countermodel sorry-free
- "Full `bx_completeness`: Blocked by 1 sorry in discrete case" -- unblocking the discrete case moves toward sorry-free `bx_completeness`

## Overview

This plan replaces Phase 2 from plan v5 with a restructured proof strategy based on round 6 research findings. The sole remaining sorry is at line 1303 of `ChronicleToCountermodel.lean`: given `a b : LimitDomSubtype` with `a <= b` and `forall n, succ^[n](a) < b`, derive `False`.

The revised strategy abandons the `exists c, c.val = L` reduction (plan v5's Approach A) because:
1. It requires proving L is rational AND in limit_dom -- two independent hard problems.
2. The gap-at-L scenario (two infinite orbits converging from opposite sides with no domain point at L) is order-theoretically consistent.
3. All round 6 teammates agreed this is "too strong" and "may lock the proof into the hardest path."

Instead, the primary approach proves `Set.Finite (Set.Icc a b)` for `LimitDomSubtype` directly, then derives `IsSuccArchimedean` via Mathlib's `LocallyFiniteOrder` pipeline. The Icc finiteness argument uses construction-specific properties: each omega-chain stage adds at most one domain point (`omega_chain_dom_new_unique`), resolved counterexamples do not re-fire (`omega_chain_c5_forward_resolved_no_new`), and only counterexamples at domain points are effective (non-domain x-coordinates are vacuously resolved). The finite subformula closure bounds the formula dimension; cascade bounding handles C4 interactions.

A secondary approach via MCS periodicity along orbits is available if the primary hits a formalization barrier.

**Definition of done**: `limitDomSubtype_isSuccArchimedean` at line 1303 is sorry-free. `succ_embed_surjective` is sorry-free. `dd_countermodel_chronicle_discrete` is sorry-free. The only remaining sorry sites in `ChronicleToCountermodel.lean` are `dd_countermodel_chronicle_nondense_sorry` (line 839) and `dd_countermodel_chronicle_mixed_sorry` (line 2730).

## Goals & Non-Goals

**Goals:**
- Close the sorry at line 1303 (`limitDomSubtype_isSuccArchimedean`)
- Replace the current `suffices h_exists_at_L` block with a direct Icc finiteness argument (or restructure the proof body entirely if needed)
- Make `dd_countermodel_chronicle_discrete` sorry-free

**Non-Goals:**
- Modifying the omega-chain construction (`ChronicleConstruction.lean`) -- only add new lemmas, never modify existing ones
- Modifying BUC (already sorry-free)
- Solving the mixed case (`dd_countermodel_chronicle_mixed_sorry`)
- Modifying Phase 1 from plan v5 (already [COMPLETED])
- Implementing the full "completeness via completeness" approach (requires prohibitive infrastructure)
- Proving WellFoundedGT (provably false for LimitDomSubtype)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Cascade bounding for C4 counterexamples is harder than expected | H | M | Use "only domain-point counterexamples are effective" to sidestep non-domain x-coordinates; bound formula dimension via finite subformula closure |
| Stabilization bound requires tracking which stages insert into [a,b] | H | M | Use omega_chain_dom_mono + dom_new_unique: domain is monotone and each step adds at most one point, so count the relevant stages |
| The proof restructuring (replacing suffices block) breaks existing compiled code | M | L | Keep the convergence framework (Steps 1-6) as helper lemmas; only replace the sorry region (line 1303) |
| Icc finiteness cannot be proved within time budget | H | L | Fall back to MCS periodicity approach (secondary); or leave sorry with detailed documentation and return partial |
| MCS periodicity approach also requires construction-specific reasoning | M | M | The periodicity argument uses pigeonhole on finitely many MCS values, which is more elementary than the stabilization argument |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

Phases within the same wave can execute in parallel.

### Phase 1: Add Imports and Prove Order.succ Equality [COMPLETED]

**Goal**: Add the two missing Mathlib imports and prove that `Order.succ` equals `limitDomSubtype_succ` when the `SuccOrder` instance is registered via `letI`.

**Tasks**:
- [x] Add `import Mathlib.Topology.Instances.Real.Lemmas` (already present, line 11)
- [x] Add `import Mathlib.Data.Rat.Cast.Order` (already present, line 12)
- [x] Prove `order_succ_eq` (line 1006, `rfl`)
- [x] Prove `order_pred_eq` (line 1017, `rfl`)

**Timing**: 0.5-1 hour (completed)

**Depends on**: none

**Completed**: 2026-05-11

---

### Phase 2: Prove Icc Finiteness and Derive IsSuccArchimedean [NOT STARTED]

**Goal**: Replace the `sorry` at line 1303 with a valid proof. The current proof has:
- Steps 1-6 (convergence framework): compiled and correct, establish monotone convergence of succ-orbit and pred-chain to the same limit L.
- A `suffices h_exists_at_L` block (lines 1270-1297): compiled, derives contradiction from a hypothetical domain point c at L.
- The sorry (line 1303): needs to produce `exists c : LimitDomSubtype, (c.val : R) = L /\ forall n, s^[n] a < c`.

**Revised strategy**: The implementation agent should replace the entire proof body after the `by` keyword of `limitDomSubtype_isSuccArchimedean` (or replace just the sorry at line 1303 if the Icc finiteness argument can produce the required existential). The agent has two ordered approaches.

#### Approach A (Primary): Icc Finiteness via Construction Stabilization

**Mathematical argument**: Prove `Set.Finite (Set.Icc a b)` for `LimitDomSubtype`, then derive contradiction with the injection of N into Icc a b (the succ-orbit `n |-> succ^[n](a)` is a strict injection by `limitDomSubtype_succ_iter_mono`).

**Step A.1**: Define the relevant interval and the injection.
- Define `orbit_in_Icc : N -> Set.Icc a b` mapping `n |-> succ^[n](a)` (well-defined by `h_not_cofinal` giving `succ^[n](a) < b` and `limitDomSubtype_succ_iter_mono` giving `a <= succ^[n](a)`).
- Show this map is injective (strict monotonicity from `limitDomSubtype_succ_iter_strict_mono` or from `succ_ne_self` + monotonicity).

**Step A.2**: Prove `Set.Finite (Set.Icc a b)` for `LimitDomSubtype`.
This is the core. The argument proceeds:

**(A.2.1) Stage tracking**: Each element `w : LimitDomSubtype` has `w.val in limit_dom`. By definition, `limit_dom = Union_n (omega_chain_val A h_mcs n).dom`. So `w.val in (omega_chain_val A h_mcs n_w).dom` for some finite stage `n_w`. Define `entry_stage(w) = min {n | w.val in (omega_chain_val A h_mcs n).dom}`.

**(A.2.2) Bound on insertions**: At each stage `n`, at most one new domain point is added (`omega_chain_dom_new_unique`). So the set of domain points in `[a.val, b.val]` at stage n has cardinality at most n + |dom_0|. The question is whether the total number of stages that insert a point into `[a.val, b.val]` is finite.

**(A.2.3) Effective counterexamples only**: A counterexample `(x, y, xi, eta, kind)` at stage n+1 can only insert a new point if:
- The counterexample is not already resolved at stage n (by `omega_chain_c5_forward_resolved_no_new` / `omega_chain_c5_backward_resolved_no_new`)
- For C5: `x` must be in `dom(n)` and the relevant formula `U(eta, xi)` or `S(eta, xi)` must be in `f_n(x)`. If `x` is not in `dom(n)`, the counterexample is vacuous.
- For C4: both `x` and `y` (or a derived pair) must be in `dom(n)`.

**(A.2.4) Formula-bounded counterexamples**: For a domain point `w` with `w.val in [a.val, b.val]`, the formulas in `f(w)` that can trigger C5 insertions targeting the interval `[a.val, b.val]` are of the form `U(eta, xi)` where `xi, eta` range over all formulas. However, C5 insertions are LOCAL: the witness is placed near `w` (specifically, between `w` and the next domain point in the direction of the witness). This means:
- C5 forward at `w`: inserts a point `y` with `w < y` and `y` is the immediate next domain point after `w` (in the `U(T, bot)` case) or placed between `w` and the next existing domain point that terminates the walk.
- A C5 insertion into `[a.val, b.val]` can only come from a counterexample at a domain point `w` with `w.val in [a.val, b.val]` (or slightly below a.val with the witness landing in the interval).

**(A.2.5) Stabilization**: Combine the above: each domain point `w` in `[a.val, b.val]` generates at most `|Sub(A)|^2` formula-type counterexamples (where `Sub(A)` is the subformula closure of the initial formula `A`). Each counterexample resolves at most once. New domain points inserted into the interval create new counterexamples, but each of those also resolves at most once and involves the same finite set of formula types. The total number of insertions is bounded by a function of `|Sub(A)|` and the initial number of domain points in the interval.

**(A.2.6) C4 cascade bounding**: C4 insertions split adjacent pairs, creating new pairs that may trigger new C4 counterexamples. Each C4 insertion resolves a specific counterexample `(x, y, xi, eta, c4_forward)`. The new pairs `(x, z)` and `(z, y)` can trigger counterexamples for formulas in `f(x), f(z), f(y)`. Since the formulas at any point are a subset of the set of all formulas, and the relevant formulas for C4 are `neg(U(eta, xi))` types (finitely many in any MCS), the cascade terminates. Key constraint: in the discrete case, `neg(U(T, bot))` is never in any MCS (since `U(T, bot)` is in every MCS by `h_discrete`), so C4 for `(T, bot)` never fires.

**Step A.3**: Derive contradiction.
- `Set.Finite (Set.Icc a b)` + injection of N into `Set.Icc a b` contradicts `Set.Finite.not_injOn_of_ncard_lt` or similar Mathlib result.

**Alternative sub-approach (A-alt)**: If the direct stabilization bound is too hard to formalize, use the Icc finiteness to derive `LocallyFiniteOrder` via `LocallyFiniteOrder.ofFiniteIcc`, then get `IsSuccArchimedean` from the Mathlib instance chain. This may require checking that `LocallyFiniteOrder.ofFiniteIcc` is available or constructing the `Fintype (Set.Icc a b)` instance.

**Key existing lemmas**:
- `omega_chain_dom_new_unique` (ChronicleConstruction.lean:1196): each stage adds at most one point
- `omega_chain_c5_forward_resolved_no_new` (ChronicleConstruction.lean:1212): resolved C5 does not re-fire
- `omega_chain_c5_backward_resolved_no_new` (ChronicleConstruction.lean:1235): mirror for backward
- `omega_chain_dom_mono` (ChronicleConstruction.lean:314): domain monotonicity
- `omega_chain_dom_mono_le` (ChronicleConstruction.lean:334): domain monotonicity (le version)
- `counterexample_enum_surjective` (ChronicleConstruction.lean:209): enumeration is surjective
- `counterexample_enum_surjective_above` (ChronicleConstruction.lean:223): enumeration surjective above any stage
- `limitDomSubtype_succ_iter_mono` (ChronicleToCountermodel.lean): succ-orbit is monotone
- `limitDomSubtype_pred_lt` (ChronicleToCountermodel.lean): pred is strictly less

**Key Mathlib lemmas**:
- `Set.Finite.injOn` or `Set.Finite.not_injective_of_ncard_lt`: finite set + injection contradiction
- `Set.Finite.ofFinset`: construct finite set from Finset
- `LocallyFiniteOrder.ofFiniteIcc`: construct LocallyFiniteOrder from finite Icc

#### Approach B (Secondary): MCS Periodicity Along Orbits

If Approach A hits a formalization barrier at the cascade bounding step, pivot to MCS periodicity.

**Mathematical argument**: The subformula closure `Sub(A)` is finite, so there are at most `2^|Sub(A)|` distinct MCS values. Along the succ-orbit `succ^[n](a)`, the MCS values `f(succ^[n](a))` must eventually repeat (pigeonhole). If `f(succ^[m](a)) = f(succ^[m+p](a))` for some period `p`, then the construction treats these points identically -- subsequent counterexample processing generates the same witnesses relative to each. This periodicity may force structural constraints that directly give `succ^[N](a) = b` for some N, or may give Icc finiteness by a different route.

**Caution**: This approach is less developed than Approach A. The "construction treats them identically" claim needs careful formalization. The MCS values determine what counterexamples arise, but the witnesses depend on the surrounding domain structure, not just the MCS at the reference point.

**Tasks for Approach B**:
- [ ] Prove MCS values along the orbit are periodic: exists m, p with `limit_f (succ^[m](a).val) = limit_f (succ^[m+p](a).val)`
- [ ] Analyze what structural constraints periodicity imposes on the orbit-pred gap
- [ ] Derive Icc finiteness or direct contradiction from periodicity

#### Decision Criteria

- If Approach A proves `Set.Finite (Set.Icc a b)` within ~3 hours, the sorry closes via the injection contradiction.
- If Approach A encounters a barrier at cascade bounding (cannot bound the number of C4 insertions triggered by C5 insertions), pivot to Approach B.
- If both A and B fail within the time budget, leave the sorry with a detailed comment and return status `partial`.

**Tasks for Phase 2**:
- [ ] Analyze whether the existing `suffices h_exists_at_L` block should be kept or replaced
- [ ] If replacing: restructure the proof body to use Icc finiteness directly
- [ ] If keeping: prove the existential by first proving Icc finiteness, then extracting a domain point at L
- [ ] Implement Step A.1: define orbit injection into Icc
- [ ] Implement Step A.2: prove Icc finiteness using construction properties
- [ ] Implement Step A.3: derive contradiction (or derive IsSuccArchimedean via LocallyFiniteOrder)
- [ ] If A fails: attempt Approach B (MCS periodicity)
- [ ] Verify: `lean_goal` at each proof step, `lean_verify` on `limitDomSubtype_isSuccArchimedean`

**Timing**: 3-6 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- replace sorry at line 1303 with proof body (~100-200 lines)
- Possibly `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` -- new helper lemmas only (no modifications to existing code)

---

### Phase 3: Verification and Cleanup [NOT STARTED]

**Goal**: Verify the proof compiles, confirm sorry elimination downstream, and clean up any temporary scaffolding.

**Tasks**:
- [ ] `lake build ChronicleToCountermodel` passes
- [ ] `lean_verify` on `limitDomSubtype_isSuccArchimedean` confirms no sorry
- [ ] `lean_verify` on `succ_embed_surjective` confirms no sorry
- [ ] `lean_verify` on `dd_countermodel_chronicle_discrete` confirms no sorry
- [ ] `lean_verify` on `cantor_bfmcs_discrete_restricted_tc` confirms no sorry
- [ ] `lean_verify` on `cantor_bfmcs_discrete_restricted_fuc` confirms no sorry
- [ ] Grep for sorry in `ChronicleToCountermodel.lean` confirms only nondense and mixed stubs remain
- [ ] Full `lake build` passes
- [ ] Remove any temporary `#check` or `#eval` scaffolding

**Timing**: 0.5-1 hour

**Depends on**: 2

## Testing & Validation

- [ ] `lake build ChronicleToCountermodel` passes after Phase 2
- [ ] `lean_verify` on `limitDomSubtype_isSuccArchimedean` confirms no sorry
- [ ] `lean_verify` on `succ_embed_surjective` confirms no sorry
- [ ] `lean_verify` on `dd_countermodel_chronicle_discrete` confirms no sorry
- [ ] `lean_verify` on `cantor_bfmcs_discrete_restricted_tc` confirms no sorry
- [ ] `lean_verify` on `cantor_bfmcs_discrete_restricted_fuc` confirms no sorry
- [ ] Grep for sorry in `ChronicleToCountermodel.lean` shows only `dd_countermodel_chronicle_nondense_sorry` and `dd_countermodel_chronicle_mixed_sorry`
- [ ] Full `lake build` passes

## Artifacts & Outputs

- **Plan**: `specs/123_fix_c5_witness_bot_and_prove_icc_finite/plans/06_icc-finiteness-stabilization.md` (this file)
- **Modified files**:
  - `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (IsSuccArchimedean proof body, ~100-200 lines replacing sorry at line 1303)
  - Possibly `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` (new helper lemmas only)
- **Summary**: `specs/123_fix_c5_witness_bot_and_prove_icc_finite/summaries/06_icc-finiteness-summary.md` (after implementation)

## Rollback/Contingency

All changes are in a single file (`ChronicleToCountermodel.lean`), with potential additions to `ChronicleConstruction.lean`. The theorem statement of `limitDomSubtype_isSuccArchimedean` is unchanged -- only the proof body (currently `sorry`) is replaced. Reverting: restore the sorry at line 1303 and remove any new helper lemmas.

If both approaches fail:
1. **Document the gap**: Write a detailed comment at the sorry site explaining the mathematical gap and the three approaches attempted (convergence/L-in-domain from plan v5, Icc finiteness, MCS periodicity).
2. **Keep the sorry**: The sorry is well-localized and does not affect the overall architecture. `succ_embed_surjective` is already sorry-free conditional on this instance.
3. **Partial progress**: Keep any successfully proved helper lemmas (Icc finiteness sub-lemmas, MCS periodicity lemma, stabilization bounds) as they reduce the sorry to a smaller gap.
4. **Consider task splitting**: If the cascade bounding requires significant new infrastructure in `ChronicleConstruction.lean`, create a subtask for that infrastructure.
