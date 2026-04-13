# Implementation Plan: Close BXCanonical TaskModel Embedding Sorry

- **Task**: 93 - Complete BXCanonical embedding
- **Status**: [IN PROGRESS]
- **Effort**: 6 hours estimated, ~4 hours spent
- **Dependencies**: Task 92 (truth lemma)
- **Research Inputs**: reports/01_taskmodel-embedding.md, reports/02_team-research.md
- **Artifacts**: plans/02_bxcanonical-embedding.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Close the sole remaining active-path sorry at `BXCanonical/Completeness.lean:154` by constructing a BFMCS from BXCanonical witnesses and bridging to the existing parametric canonical infrastructure. The approach (Strategy B, unanimously confirmed by team research) builds a dovetailed Int-indexed chain of BXPoints as an FMCS, packages it into a BFMCS with modal saturation, and applies `parametric_algebraic_representation_conditional` to derive a countermodel contradicting `valid phi`. Definition of done: `lake build` succeeds with zero sorry on the active completeness path, and `#print axioms bx_completeness` lists only `propext`, `Classical.choice`, `Quot.sound`.

### Research Integration

Two research reports were integrated:

- **01_taskmodel-embedding.md**: Identified Strategy B (bridge to parametric infrastructure) as preferred approach. Established that BXPoint is structurally identical to ParametricCanonicalWorldState, that all BXCanonical witnesses are sorry-free, and that `Denumerable Formula` is available for dovetailing. Identified the constant-history anti-pattern and showed non-constant FMCS chains are required.

- **02_team-research.md** (4 teammates): Unanimously confirmed Strategy B. Corrected the guard-interval "vacuity" claim (guard is non-vacuous but trivially satisfied via BX9). Identified multi-obligation Until interleaving as hidden difficulty. Confirmed parametric infrastructure is fully D-generic and sorry-free. Revised line estimate to 550-850.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

- Closes the sole remaining active-path sorry (1 of 1) blocking `bx_completeness`
- Advances roadmap item: "TaskModel embedding (final step)" from OPEN to DONE
- Once complete, `completeness_over_Int` becomes sorry-free via BXCanonical

## Goals & Non-Goals

**Goals**:
- Close the sorry at `Completeness.lean:154` with a verified proof
- Construct a BFMCS from BXCanonical witnesses for `D = Int`
- Bridge BXCanonical and parametric canonical infrastructure
- Achieve `lake build` with zero active-path sorry
- Verify `#print axioms bx_completeness` shows only `propext`, `Classical.choice`, `Quot.sound`

**Non-Goals**:
- Dense time completeness (`D = Rat`), which is a separate task (68)
- Closing sorries in the Algebraic module outside the parametric path (TenseS5Algebra, LindenbaumQuotient, InteriorOperators)
- Refactoring the parametric infrastructure
- Performance optimization of the proof

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| F(ψ) persistence through resolving steps (**REALIZED**) | H | H | The dovetailed chain loses F-obligations at resolving steps. See "Blocker" section below. Three mitigation paths identified. |
| Multi-obligation Until interleaving complexity exceeds estimate | H | M | Use priority-based chain: resolve Until at t+1 (guard trivially satisfied since `[t, t+1)` in Int contains only `r = t`), then F/P via standard dovetailing. Seed unresolved Until formulas into Lindenbaum extensions. |
| Modal saturation requires more boilerplate than estimated | M | M | **Resolved**: Shifted FMCS families solved the time-offset problem. |
| Forward/backward Until/Since coherence proofs are harder than expected | H | M | Blocked on forward_F. Once chain construction is resolved, these may follow from the same enriched chain. |
| Axiom contamination from unexpected sorry in import chain | H | L | Team research verified zero sorry in Frame.lean, ParametricCanonical.lean, ParametricTruthLemma.lean, ParametricHistory.lean, ParametricRepresentation.lean. Run `#print axioms` after each phase. |

## Blocker: F(ψ) Persistence in Dovetailed Chain

**Discovered 2026-04-13 during implementation.**

The dovetailed chain construction (`fwd_succ` / `bwd_pred`) uses Lindenbaum extensions of `{σ} ∪ g_content(M)` at resolving steps (where `F(σ) ∈ M`). The Lindenbaum lemma produces an arbitrary MCS extending this seed, and the extension may include `G(¬ψ)` for other formulas ψ with `F(ψ) ∈ M`, permanently killing `F(ψ)`.

**What was tried**:
1. **f_carry enrichment** (implemented): Added `f_carry(M) = {F(χ) ∈ M}` to the non-resolving seed (`g_content(M) ∪ f_carry(M)`). This preserves F-obligations through non-resolving steps. However, the enriched RESOLVING seed `{σ} ∪ g_content(M) ∪ f_carry(M)` can be genuinely inconsistent (e.g., when `G(F(χ) → ¬σ) ∈ M`), so f_carry cannot be added to resolving steps.
2. **Classical contradiction argument**: Attempted showing that if `ψ ∉ chain(s)` for all `s > t`, then `G(¬ψ) ∈ chain(t)`, contradicting `F(ψ) ∈ chain(t)`. But deriving `G(¬ψ) ∈ chain(t)` from `¬ψ ∈ chain(s)` for all `s > t` requires backward_G, which itself requires forward_F — circular.
3. **BX linearity argument**: Applying BX11 (`F(α) ∧ F(β) → F(α ∧ β) ∨ ...`) to the conflicting F-obligations. This produces structurally larger F-formulas at each resolving step, creating an infinite regress that never terminates.

**Viable mitigation paths (not yet attempted)**:
1. **Biased Lindenbaum**: Build a custom `biased_set_lindenbaum` that, when extending a seed S, preferentially includes formulas from a "bias set" P (e.g., f_carry) whenever consistent. This ensures F(ψ) survives resolving steps unless forced out by inconsistency — and if forced out, `G(¬ψ)` is derivable from the seed, giving a contradiction argument.
2. **Canonical frame approach**: Instead of a linear Int-indexed chain, use the canonical frame's accessibility relation from `CanonicalFrame.lean` where forward_F is trivial (each F-obligation gets a fresh witness). Requires restructuring the BFMCS construction.
3. **Restricted temporal coherence**: Use `BFMCS.restricted_temporally_coherent` (already defined in Bundle/) which only requires forward_F for formulas in `deferralClosure(root)`. This scopes the obligation to finitely many formulas, making a priority-based resolution schedule feasible.

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Dovetailed FMCS Chain Construction [PARTIAL]

**Goal**: Build an `Int -> BXPoint` chain from a starting MCS, satisfying `forward_G` and `backward_H`, with temporal coherence (`forward_F`, `backward_P`) and Until/Since forward coherence.

**Completed work**:
- [x] Create `BXCanonical/CanonicalModel.lean` with appropriate imports
- [x] Define the obligation enumeration using `Denumerable Formula` (`schedule`, `schedule_surjective_above`)
- [x] Define `fwd_succ` / `bwd_pred` chain step functions with f_carry / p_carry enrichment for non-resolving steps
- [x] Build `fwd_chain`, `bwd_chain`, `int_chain` combining forward/backward into `Int → Set Formula`
- [x] Construct `bx_fmcs : FMCS Int` with `forward_G` proved via g_content transitivity
- [x] Prove `backward_H` via h_content reverse duality
- [x] Prove g_content/h_content propagation across full Int chain (`int_chain_g_content`, `int_chain_h_content`)
- [x] Prove `g_content_subset_self`, `h_content_subset_self` (T-axiom reflexivity)
- [x] Prove `fwd_succ_f_carry` / `bwd_pred_p_carry` (F/P persistence through non-resolving steps)

**Remaining work (blocked — see Blocker section)**:
- [ ] Prove `bx_fmcs_forward_F` (line 491): F(ψ) ∈ chain(t) → ∃ s > t, ψ ∈ chain(s)
- [ ] Prove `bx_fmcs_backward_P` (line 497): P(ψ) ∈ chain(t) → ∃ s < t, ψ ∈ chain(s)

**Timing**: 2 hours estimated, ~2 hours spent, **blocked**

**Depends on**: none (but blocked on chain construction design)

**Files modified**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` — ~490 lines: chain construction, FMCS structure, all non-temporal-coherence proofs

**Verification**:
- `lake build` compiles with 4 sorry warnings (forward_F, backward_P, buc, fuc)

---

### Phase 2: BFMCS Packaging with Modal Saturation [COMPLETED]

**Goal**: Construct a `BFMCS Int` from the FMCS chain by adding modal witness families, satisfying modal saturation and all coherence conditions.

**Completed work**:
- [x] Define `shifted_bx_fmcs`: time-shifted FMCS placing chain origin at arbitrary time offset `s`
- [x] Prove `box_stable_in_int_chain`: Box φ ∈ chain(t) ↔ Box φ ∈ M₀ for all t (key helper)
- [x] Prove `box_stable_in_shifted_fmcs`: corollary for shifted families
- [x] Define `bx_bfmcs` with shifted families: `{ shifted_bx_fmcs N h_N s | N modal-equiv M₀, s : Int }`
- [x] Prove `modal_forward`: Box φ at any family → φ at all families (via box stability + T-axiom)
- [x] Prove `modal_backward`: φ at all families → Box φ (contrapositive via `bx_modal_witness` + shifted families)
- [x] Wire `bx_construct_bfmcs`, `bx_countermodel` with shifted families
- [x] Update `Completeness.lean` for shifted family API

**Design change**: Families set changed from `{ bx_fmcs N h_N | matching Box }` to `{ shifted_bx_fmcs N h_N s | matching Box, s : Int }`. This was necessary because `bx_modal_witness` produces witnesses at the chain origin (time 0), but modal_backward requires witnesses at arbitrary time t. Shifted families place the witness MCS at the needed time position.

**Timing**: 1.5 hours estimated, ~1.5 hours spent

**Depends on**: 1

**Files modified**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` — Added ~100 lines: shifted_bx_fmcs, box_stable helpers, modal proofs
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` — Updated to use shifted family API

**Verification**:
- `modal_forward` and `modal_backward` have no sorry ✓
- `lake build` succeeds (with 4 remaining sorry in temporal/coherence proofs)

---

### Phase 2b: Until/Since Coherence [NOT STARTED]

**Goal**: Prove backward and forward Until/Since coherence for the BFMCS.

**Remaining sorries**:
- `bx_bfmcs_buc` (line 581): backward Until/Since coherence — given witness pattern, derive Until/Since membership
- `bx_bfmcs_fuc` (line 586): forward Until/Since coherence — given Until/Since membership, produce witness

**Note**: These depend on Phase 1 (forward_F/backward_P) being resolved, since the coherence proofs operate over families that must be temporally coherent. However, backward Until coherence (`buc`) may be provable independently using `backward_until_from_step` from `UntilSinceCoherence.lean` if a step-transfer property can be established for the chain.

**Timing**: 1.5 hours estimated

**Depends on**: 1 (for temporal coherence), but buc may be partially independent

---

### Phase 3: Bridge Proof Infrastructure [COMPLETED]

**Goal**: Connect `construct_bfmcs` to `parametric_algebraic_representation_conditional` to produce a concrete TaskModel where MCS membership corresponds to semantic truth.

**Status**: Fully implemented. `bx_construct_bfmcs` returns a `Σ'` bundle with BFMCS, coherence proofs, evaluation family, and membership proof. `bx_countermodel` applies `parametric_representation_from_neg_membership` to produce a countermodel.

**Note**: Both `bx_construct_bfmcs` and `bx_countermodel` compile and type-check, but they transitively depend on the sorry-bearing coherence proofs from Phases 1 and 2b.

**Files modified**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` — bridge section (~30 lines)

---

### Phase 4: Close the Sorry at Completeness.lean [COMPLETED]

**Goal**: Replace the sorry with a proof that derives `False` from `valid phi` and `phi not_in M`.

**Status**: Fully implemented. `bx_completeness` proves `valid φ → Nonempty (DerivationTree [] φ)` via contrapositive using `bx_countermodel`.

**Note**: The proof compiles but transitively depends on sorry through `bx_countermodel → bx_bfmcs_tc → bx_fmcs_forward_F`.

**Files modified**:
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` — complete rewrite (~150 lines)

## Current Sorry Inventory (4 remaining)

| Sorry | File:Line | Phase | Blocker |
|-------|-----------|-------|---------|
| `bx_fmcs_forward_F` | CanonicalModel.lean:495 | 1 | F(ψ) persistence (see Blocker) |
| `bx_fmcs_backward_P` | CanonicalModel.lean:501 | 1 | P(ψ) persistence (symmetric) |
| `bx_bfmcs_buc` | CanonicalModel.lean:584 | 2b | Step transfer property |
| `bx_bfmcs_fuc` | CanonicalModel.lean:589 | 2b | Forward eventuality extraction |

## Testing & Validation

- [x] `lake build` completes successfully with zero errors (4 sorry warnings)
- [ ] `grep -r "sorry" Theories/Bimodal/Metalogic/BXCanonical/` returns no matches
- [ ] `#print axioms bx_completeness` lists only `propext`, `Classical.choice`, `Quot.sound`
- [ ] No regressions in existing tests: `lake build` for the full project

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` — New file (~625 lines): FMCS chain construction, BFMCS packaging, bridge lemma
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` — Modified: sorry replaced with proof using `bx_countermodel` (~150 lines)
- `specs/093_complete_bxcanonical_embedding/summaries/02_bxcanonical-embedding-summary.md` — Implementation summary (pending)

## Rollback/Contingency

- The only modified existing file is `Completeness.lean` (a few lines). Revert with `git checkout -- Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean`.
- The new file `CanonicalModel.lean` can be deleted entirely without affecting existing code.
- If the BFMCS construction proves too complex for Int, fall back to a simpler construction using restricted coherence conditions (`restricted_forward_until_since_coherent`) which narrows the Until/Since burden to subformulas of the target formula.
- **Primary contingency for forward_F blocker**: Use the biased Lindenbaum approach (see Blocker section, path 1). This requires ~100 lines of new infrastructure but is a targeted fix.
- **Fallback contingency**: Use restricted temporal coherence (path 3), which limits the forward_F obligation to finitely many formulas within `deferralClosure(root)`, making priority-based resolution feasible.
