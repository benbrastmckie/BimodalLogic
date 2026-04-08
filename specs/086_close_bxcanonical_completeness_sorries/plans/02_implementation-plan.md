# Implementation Plan: Close BXCanonical Completeness Sorry #5

- **Task**: 86 - Close BXCanonical completeness sorries
- **Status**: [NOT STARTED]
- **Effort**: 14 hours
- **Dependencies**: None (all prerequisite infrastructure is sorry-free)
- **Research Inputs**: reports/01_team-research.md, reports/02_team-research.md
- **Artifacts**: plans/02_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Close sorry #5 at `Completeness.lean:144` by constructing a canonical TaskModel from BXPoints and proving a truth lemma bridge that lifts MCS membership to semantic `truth_at`. The approach uses tailored per-formula countermodel construction (not a single universal canonical model) to avoid the G/H surjectivity problem identified in Round 2 research. The scope is fragment completeness for {atom, bot, imp, box, G, H} -- the fragment whose MCS-level truth lemma is entirely sorry-free. The 4 Frame.lean Until/Since sorries are explicitly out of scope.

### Research Integration

- **Round 1** (01_team-research.md): Confirmed bx_le redefinition and FMP bridge are non-viable. Identified fragment completeness (80% confidence) and Until-induction derivation (medium-term) as paths forward.
- **Round 2** (02_team-research.md): Confirmed fragment truth lemma is completely proved with zero Until/Since dependencies. Identified permissive task_rel as solution to nullity_identity. Identified G/H surjectivity as key obstacle and tailored embedding by induction on phi as resolution. Estimated 100-200 LOC.

## Goals & Non-Goals

**Goals**:
- Define `Formula.untilSinceFree` predicate for the {atom, bot, imp, box, G, H} fragment
- Construct a countermodel function: given MCS M and formula phi with phi not in M, build TaskModel + Omega + history + time where `not (truth_at ... phi)`
- Prove `fragment_completeness`: for Until/Since-free phi, `valid phi -> Nonempty (DerivationTree [] phi)`
- Close sorry #5 in `Completeness.lean:144` for the fragment (or refactor `bx_completeness` to call fragment completeness for the fragment, leaving full completeness as a separate theorem)

**Non-Goals**:
- Close the 4 Frame.lean Until/Since sorries (#1-4)
- Derive Until-induction from BX5+BX6+BX7
- Build a single universal canonical model (surjectivity problem)
- Pursue FMP bridge or bx_le redefinition
- Prove full completeness for formulas containing Until/Since

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Box case requires all histories in Omega to satisfy truth lemma simultaneously | H | M | Use singleton Omega with shift-closure; box quantifies over shifts of one base history |
| G truth requires history to visit all bx_le-successors (surjectivity) | H | H | Tailored construction: for G(psi) not in M, only need one bx_le-successor v with psi not in v; build 2-point history {M,v} |
| ShiftClosed constraint forces Omega to contain all time-shifts | M | M | Build Omega as shift-closure of a single base history; all shifts visit same BXPoints |
| Dependent type complexity in WorldHistory (domain proofs, states proofs) | M | H | Use permissive task_rel (d != 0 or w = u) so respects_task is trivially satisfiable; use full domain (fun _ => True) |
| truth_at for atoms requires domain membership proof | L | L | Full domain makes this trivial |

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

### Phase 1: Foundation -- UntilSinceFree Predicate and Canonical TaskFrame [NOT STARTED]

**Goal**: Define the formula fragment predicate and the canonical TaskFrame that all countermodels will use.

**Tasks**:
- [ ] Define `Formula.untilSinceFree : Formula -> Prop` as an inductive predicate on formula structure (true for atom, bot, imp, box, all_past, all_future; false for untl, snce)
- [ ] Define `canonical_task_frame : TaskFrame Int` using the permissive task_rel pattern from `nat_frame`: `task_rel w d u := d != 0 or w = u` where `WorldState = BXPoint`
- [ ] Prove all three TaskFrame axioms (nullity_identity, forward_comp, converse) for `canonical_task_frame` -- these follow the exact same proof pattern as `nat_frame`
- [ ] Place definitions in a new file `Theories/Bimodal/Metalogic/BXCanonical/CanonicalEmbedding.lean`

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalEmbedding.lean` (new) -- canonical TaskFrame + fragment predicate
- `Theories/Bimodal/Syntax/Formula.lean` -- add `untilSinceFree` predicate (or place in new file)

**Verification**:
- `lake build` succeeds with no errors on the new file
- `untilSinceFree` correctly classifies all 8 formula constructors
- `canonical_task_frame` type-checks as `TaskFrame Int`

---

### Phase 2: WorldHistory and Omega Construction Toolkit [NOT STARTED]

**Goal**: Build the machinery for constructing WorldHistory values from BXPoint sequences and their shift-closed Omega sets.

**Tasks**:
- [ ] Define `bxpoint_constant_history (w : BXPoint) : WorldHistory canonical_task_frame` -- constant history through w with full domain (domain := fun _ => True). Respects_task follows from permissive task_rel (right disjunct: w = w)
- [ ] Define `bxpoint_two_history (w v : BXPoint) (pivot : Int) : WorldHistory canonical_task_frame` -- history that is w for t < pivot and v for t >= pivot. Respects_task: for s < t, if both map to same BXPoint then right disjunct; if different BXPoints then t - s != 0 so left disjunct
- [ ] Define `shift_closure (base : WorldHistory canonical_task_frame) : Set (WorldHistory canonical_task_frame)` as `{ sigma | exists delta : Int, sigma = WorldHistory.time_shift base delta }`
- [ ] Prove `shift_closure_is_shift_closed : ShiftClosed (shift_closure base)` -- composition of time shifts
- [ ] Prove `base_mem_shift_closure : base in shift_closure base` -- shift by 0
- [ ] Define `canonical_valuation : TaskModel canonical_task_frame` as `{ valuation := fun w p => atom p in w.formulas }`

**Timing**: 3 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalEmbedding.lean` -- history constructors, shift closure, valuation

**Verification**:
- All definitions type-check
- `shift_closure_is_shift_closed` is sorry-free
- `bxpoint_two_history` respects_task proof is sorry-free

---

### Phase 3: Truth Lemma Bridge for Fragment Connectives [NOT STARTED]

**Goal**: Prove that for each fragment connective, MCS membership corresponds to truth_at in the tailored countermodel. This is the core mathematical content.

**Tasks**:
- [ ] Prove `atom_truth_bridge`: for constant history through w, `truth_at canonical_valuation Omega tau t (atom p) <-> atom p in w.formulas` (where tau maps all times to w). Follows from full domain + valuation definition
- [ ] Prove `bot_truth_bridge`: `truth_at ... bot <-> False` and `bot not_in w.formulas` for MCS w. Both are definitional
- [ ] Prove `imp_truth_bridge`: `truth_at ... (phi.imp psi) <-> (truth_at ... phi -> truth_at ... psi)` is definitional; combine with `imp_iff_mcs` for the MCS direction
- [ ] Prove `box_countermodel`: given w : BXPoint and phi with box(phi) not in w.formulas, use `bx_modal_witness` to get v with `bx_modal_equiv w v` and `phi not in v.formulas`. Build countermodel using constant history through v in a separate Omega. Key insight: box quantifies over ALL sigma in Omega, so we need Omega to contain a history through v. Use shift_closure of constant history through v; all shifts also go through v
- [ ] Prove `G_countermodel`: given w : BXPoint and G(phi) not in w.formulas, by backward direction of `G_iff_mcs`, there exists v with `bx_le w v` and `phi not in v.formulas`. Build two-point history (w at t<0, v at t>=0) in shift_closure. At time 0, state is w; at time 1, state is v; truth_at at time 1 gives `not (truth_at ... phi)` by induction. So `not (truth_at ... (G phi))` at time 0
- [ ] Prove `H_countermodel`: mirror of G using bx_le v w and two-point history (v at t<=0, w at t>0)
- [ ] Prove the main inductive theorem `fragment_countermodel`: for any MCS w and untilSinceFree phi with phi not in w.formulas, there exist D, F, M, Omega (shift-closed), tau in Omega, t such that `not (truth_at M Omega tau t phi)`. By structural induction on phi, dispatching to the above cases

**Timing**: 4 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalEmbedding.lean` -- truth bridges and countermodel theorem

**Verification**:
- Each bridge lemma is sorry-free
- `fragment_countermodel` is sorry-free
- `lake build` succeeds

---

### Phase 4: Fragment Completeness Theorem [NOT STARTED]

**Goal**: Assemble the fragment completeness theorem from the countermodel construction.

**Tasks**:
- [ ] State `fragment_completeness : (phi : Formula) -> phi.untilSinceFree -> valid phi -> Nonempty (DerivationTree [] phi)`
- [ ] Prove by contrapositive: assume not derivable, get MCS M with neg(phi) in M (reusing `neg_consistent_of_not_derivable` + `set_lindenbaum`), then phi not in M, then by `fragment_countermodel` get a model where phi is false, contradicting `valid phi`
- [ ] Verify the proof handles the universe level: `valid` quantifies over `D : Type` while our countermodel uses `D = Int`. The existential witness `Int` must satisfy the universal in `valid`. Since `valid phi` gives truth at ALL (D, F, M, Omega, tau, t), negating gives existence of ONE such tuple where phi fails -- but we need the forward direction: we CONSTRUCT the countermodel, then `h_valid` applied to our specific Int model gives `truth_at ...`, contradicting our `not (truth_at ...)`. This works directly.

**Timing**: 2 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalEmbedding.lean` -- fragment completeness theorem
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- add comment referencing fragment completeness

**Verification**:
- `fragment_completeness` is sorry-free
- `lake build` succeeds on entire project

---

### Phase 5: Integration and Documentation [NOT STARTED]

**Goal**: Connect fragment completeness to the existing codebase, document limitations, and set up for future Until/Since work.

**Tasks**:
- [ ] Add `import Bimodal.Metalogic.BXCanonical.CanonicalEmbedding` to `Completeness.lean`
- [ ] Add a comment at sorry #5 in `bx_completeness` explaining that `fragment_completeness` covers the Until/Since-free case, and the remaining sorry requires Until/Since eventuality resolution
- [ ] Optionally: refactor `bx_completeness` to use `fragment_completeness` when phi is Until/Since-free, leaving sorry only for the Until/Since case (this makes the sorry scope smaller and more precise)
- [ ] Update module docstrings in CanonicalEmbedding.lean and Completeness.lean
- [ ] Run `lake build` on full project to verify no regressions
- [ ] Document in the plan what remains: the 4 Frame.lean sorries + the Until/Since case of bx_completeness

**Timing**: 1.5 hours

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- import, comments, optional refactor
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalEmbedding.lean` -- docstrings

**Verification**:
- `lake build` succeeds with zero new sorries introduced
- `fragment_completeness` appears in the module and is sorry-free
- The sorry count in BXCanonical is unchanged (5) or reduced if refactoring narrows scope

## Testing & Validation

- [ ] `lake build` succeeds on full project with no new errors
- [ ] `fragment_completeness` is sorry-free (verify with `lean_verify` or `#check @fragment_completeness`)
- [ ] `untilSinceFree` correctly rejects `Formula.untl` and `Formula.snce`
- [ ] `canonical_task_frame` satisfies all three TaskFrame axioms (sorry-free)
- [ ] All WorldHistory constructions (constant, two-point) have sorry-free `respects_task` proofs
- [ ] `shift_closure_is_shift_closed` is sorry-free
- [ ] No regressions in existing BXCanonical proofs

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalEmbedding.lean` -- new file (~200-300 lines)
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- minor updates
- `Theories/Bimodal/Syntax/Formula.lean` -- `untilSinceFree` predicate (if placed here)
- `specs/086_close_bxcanonical_completeness_sorries/plans/02_implementation-plan.md` -- this plan
- `specs/086_close_bxcanonical_completeness_sorries/summaries/02_execution-summary.md` -- post-implementation

## Rollback/Contingency

- **If tailored countermodel fails for box case**: The box case is the most complex because it requires Omega to contain histories through different BXPoints. Fallback: use `Set.univ` as Omega (trivially shift-closed) and build countermodel histories as needed. This changes the proof structure but not the mathematical content.
- **If two-point history respects_task proof fails**: The permissive task_rel should make this trivial (left disjunct: d != 0 for transitions between different states). If issues arise, simplify to constant histories and handle G/H via a different countermodel strategy.
- **If universe level issues block the proof**: The `valid` definition uses `Type` (not `Type*`), and `Int : Type`. This should work. If not, prove fragment completeness for a fixed `D = Int` first, then lift.
- **Full revert**: Delete `CanonicalEmbedding.lean`, revert changes to `Completeness.lean` and `Formula.lean`. No existing proofs are modified destructively.
