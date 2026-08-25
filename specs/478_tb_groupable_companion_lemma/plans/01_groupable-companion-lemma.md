# Implementation Plan: T-B — The Groupable Companion Lemma

- **Task**: 478 - T-B: The Groupable Companion Lemma
- **Status**: [NOT STARTED]
- **Effort**: 16 hours (4 single-dispatch phases, ~2.1-3.3k lines total)
- **Dependencies**: Task 477 (T-A, COMPLETED — `GroupModel/GoodGroupable.lean` vocabulary)
- **Research Inputs**: reports/01_groupable-companion-feasibility.md
- **Artifacts**: plans/01_groupable-companion-lemma.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Prove the general groupable companion lemma: for every finite signature `sig`, depth `k`, and
countable discrete (Succ/Pred) unbounded-both-ways `OrderedMonadicStructure sig M`, there is an
`OrderedMonadicStructure sig N` with carrier `ℚ ×ₗ ℤ` such that `KEquiv sig k M N` — i.e.
`goodGroupable sig k M` in the vocabulary of `GroupModel/GoodGroupable.lean`. The route is
transfer-not-construction: Z-block decomposition → per-block inflation (Ramsey factorization +
tail absorption) → monochromatic discrete completeness via `BackForth` → ℚ-condensation →
assembly, then instantiation at `limitdomMonadicStructure` (`CompanionChronicle`, the Base
analogue of `limitdom_is_good`). Done means: `lake build` green, companion lemma sorry-free with
clean `#print axioms`, and the sole structural sorry remains `countermodel_discrete`
(`Transfer.lean:1102`).

### Research Integration

Report 01 (feasibility) is the governing input. Its findings this plan consumes without
re-derivation:

- Sub-phase (1) of the original brief (KEquiv composition over ordered sums) is **already
  landed sorry-free**: `doets_lemma_1_4` (`OrderedSum.lean:46`), the mixing lemma
  `kEquiv_orderedSum_of_kEquiv_colour` (`MixedSum.lean:543`, same depth `k` both sides), and
  the EF engine `BackForth`/`kEquiv_iff_backForth` (`BackAndForth.lean:62,227`). All
  `#print axioms` clean.
- Two risks retired by compiled probes (both compile via `lake env lean`):
  `verification/tb_ramsey_probe.lean` proves `infinite_ramsey_pairs` from scratch (117 lines,
  clean axioms; infinite Ramsey for pairs is **absent** from Mathlib at this pin);
  `verification/tb_statement_probe.lean` proves `sumQZOrderIso` (ordered sum of ℤ-fibers over
  ℚ `≃o` `ℚ ×ₗ ℤ`) and elaborates the full statement suite with zero errors.
- The index order `I` is carried verbatim to the target by ℚ-condensation
  (`Order.iso_of_countable_dense`, verified present) — **no Läuchli–Leonard normal-form
  machinery is needed**.
- Stale doc note found: the `OrderedSum.lean` header calls `doets_lemma_1_5` a "strategic
  sorry"; this is stale (it is proved via the mixing lemma) and is corrected in Phase 1.
- Probe tactic facts to carry forward verbatim (do not re-discover):
  - Sigma-lex → Prod-lex: `have h : Sigma.Lex (· < ·) (fun _ => (· < ·)) x y := hlt` (defeq),
    then `cases h with | left … | right …` — an `rcases` anonymous pattern hits a
    dependent-elimination failure on ℤ internals.
  - `Prod.Lex.lt_iff` needs the sigma-side target type ascribed to the `orderedSum` carrier or
    the family metavariable does not resolve.
  - `Nat.Subtype.ofNat` + `strictMono_nat_of_lt_succ` + `lt_succ_self` for monotone
    enumeration — `Mathlib.Data.Nat.Nth` is **not in the built cache**; do not plan around
    `Nat.nth`.
  - `Set.finite_le_nat` (not `Set.finite_Iic`) for ℕ-finiteness; `Set.finite_iUnion` requires
    importing `Mathlib.Data.Set.Finite.Lattice`.
  - `Prod.Lex.right _ (by simp)` closes unboundedness goals at `ℚ ×ₗ ℤ`; `omega` FAILS there.
    Required import: `Mathlib.Algebra.Order.Monoid.Prod` (T-A carry-forward).

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md found (not provided in delegation context; roadmap flag not set).

### Binding constraints from T-A (predecessor, COMPLETED)

Target vocabulary is `FormalSystem/Metalogic/WeakCanonical/GroupModel/GoodGroupable.lean`
(`QZStructure`, `toMonadic`, `toOrdered`, `toOrdered_carrier`, `goodGroupable`,
`goodGroupable_of_kEquiv`, `goodGroupable_of_orderIso`, NoMax/NoMin instances,
`noMaxOrder_of_goodGroupable`/`noMinOrder_of_goodGroupable`). Two design rulings are binding:

1. The carrier is used in FULL, never as an Option-bounds interval type — ord-connected
   subsets of `ℚ ×ₗ ℤ` are not endpoint-determined, and an interval of the carrier is not a
   group. Segments appear only as `orderedSum` summands and via `subinterval`.
2. There is deliberately NO `veryGoodGroupable` (unsatisfiable at `k ≥ 2`). Do not build or
   quantify goodness over closed subintervals.

## Goals & Non-Goals

**Goals**:
- Land `CompanionGeneral` sorry-free: arbitrary countable discrete unbounded `M` is
  `goodGroupable sig k` at carrier `ℚ ×ₗ ℤ`.
- Land `CompanionChronicle`: instantiation at `M := limitdomMonadicStructure A h_mcs φ` for a
  Base-MCS `A` with `box nextTop ∈ A` — the deliverable the successor task consumes,
  header-documented as the Base analogue of `limitdom_is_good`.
- Promote the probes' proved content (`infinite_ramsey_pairs`, `sumQZOrderIso`) into the
  module tree by transcription, not re-proof.
- Correct the stale `doets_lemma_1_5` "strategic sorry" note in the `OrderedSum.lean` header.
- Preserve the zero-debt invariant: no new sorry, no new axiom, sole structural sorry remains
  `countermodel_discrete`.

**Non-Goals**:
- Do NOT re-attempt the O1 isomorphism or `succ_cofinal` — both settled negatively and FINAL.
- Do NOT modify `countermodel_discrete` (`Transfer.lean:1102`) — that is the successor task.
- Do NOT do construction-level work in `ChronicleConstruction.lean` or `PointInsertion.lean`.
- No `veryGoodGroupable` analogue; no interval carrier type (T-A rulings).
- No aggregator module; no task-number citations in `.lean` deliverables — cite Doets thesis
  pages and sibling module names instead (per repo lint rules).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Phase 2 threshold-invariant EF proof (the task's hardest new proof) exceeds one dispatch | M | M | Pre-declared split boundary inside Phase 2 (master no-endpoints lemma first, endpoint variants second); close `[PARTIAL]` at the boundary and resume — never a sorry |
| Density/unboundedness instances on `ℚ ⊕ₗ (I ×ₗ (1+ℚ))`-shaped orders are fiddly and unprobed (~100–250 lines) | M | M | Isolated as an explicit early sub-step of Phase 4; `Order.iso_of_countable_dense` itself verified present; `sumQZOrderIso` transcription gives the glue-iso pattern |
| Segment/`subinterval` plumbing in Ramsey factorization balloons | M | M | Ramsey itself already proved (probe 2, transcribe); factorization stated over ω-indexed segment sums where `doets_lemma_1_4` and the mixing lemma already operate |
| Counterexample emerges (companion lemma is SUFFICIENT, NOT KNOWN NECESSARY, unproved) | H | L | This is a FIRST-CLASS RESULT, not a failure: stop, document the counterexample precisely (which classical step fails and the witness colouring), mark the phase `[BLOCKED]` with the finding, and report — it settles the Base discrete branch negatively and is as valuable as a proof |
| Region-condensation (Phase 4) stalls | M | L | Escape hatch (below): chronicle-specific weakening confined to the inflation piece; requires explicit docstring recording, never silent |
| Mathlib-cache gaps beyond those probed | L | L | All external dependencies were probed this session (`Order.iso_of_countable_dense` present; Ramsey absent and self-proved; `Nat.Nth` known-unbuilt with working alternative) |

### Escape hatch (plan for it; do NOT take it preemptively)

If Phase 2's threshold EF proof or Phase 4's condensation/assembly stalls after genuine
attempts, the chronicle interface coherence facts (C4/C4'/C5/C5') permit a WEAKER,
CHRONICLE-SPECIFIC companion (restrict inflation to the block colourings a Base-MCS chronicle
actually produces) that still satisfies the downstream consumer. Taking it REQUIRES: (a) the
weakened statement is explicitly named (not reusing `CompanionGeneral`'s name), (b) the
weakening and its reason are recorded in the module docstring of `GroupableCompanion.lean`,
and (c) the plan/summary artifacts record the decision. The statement MUST NEVER be silently
weakened. Research §7: the hatch is available but NOT currently needed.

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 2 |
| 3 | 4 | 1, 2, 3 |

Phases within the same wave can execute in parallel (Phases 1 and 2 are mathematically
independent: block decomposition never mentions the EF invariant, and monochromatic
completeness never mentions the quotient).

All new modules are siblings of `GoodGroupable.lean` under
`FormalSystem/Metalogic/WeakCanonical/GroupModel/`, each wired with a "CI edge only" import in
`WeakCanonical.lean` in the phase that creates it, until the successor task consumes them. Every
phase ends with the unchanged full gate: `lake build` green, `grep`-verified no new `sorry`,
`#print axioms` clean on the phase's landed theorems (expected axiom set exactly
`[propext, Classical.choice, Quot.sound]`), and a phase-scoped commit.

### Phase 1: Block decomposition (S2) [NOT STARTED]

**Goal**: For countable discrete (Succ/Pred) unbounded `M`, land `BlockDecomposition`:
`M ≃o Σ_{i∈I} (ℤ, cᵢ)` for a countable nonempty index order `I`, with predicates transported —
the finite-distance equivalence has convex classes, each order-isomorphic to a coloured ℤ (no
ω/ω*/finite blocks can occur under Succ/Pred + NoMax/NoMin).

**Tasks**:
- [ ] Create `FormalSystem/Metalogic/WeakCanonical/GroupModel/BlockDecomposition.lean` with a
      module docstring citing Doets 1987 ch. 3 (pp. 36–57) and ch. 7 step 9 (p. 91)
- [ ] Define the finite-distance (succ-reachability) equivalence on an abstract countable
      discrete unbounded order; prove its classes convex — template: `succ_orbit_convex` and
      the succ/pred ℤ-action in `ChronicleToCountermodelBasic.lean:876–1170` (sorry-free,
      limitdom-specific; generalize, do not import the limitdom hypotheses)
- [ ] Build the quotient index order `I` with its `LinearOrder` — direct template:
      `IsConvexEquiv.ClassQuot`/`classLt` in `DoetsTheorem.lean:690–843` (dense branch)
- [ ] Prove each class `≃o ℤ` via the Succ/Pred ℤ-action; define the block colouring `cᵢ`
      from the transported predicates
- [ ] Prove `Countable I` and `Nonempty I`; assemble the sigma reassembly order iso and land
      `BlockDecomposition` (statement shape from `verification/tb_statement_probe.lean`,
      transcribed — it elaborates against the live tree)
- [ ] Correct the stale `OrderedSum.lean` header note calling `doets_lemma_1_5` a
      "documented strategic sorry" (it is proved via `kEquiv_orderedSum_of_kEquiv_colour`;
      comment-only edit, no code change)
- [ ] Wire the CI-edge import of `BlockDecomposition.lean` in `WeakCanonical.lean`

**Timing**: 3-4 hours (one dispatch)

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: ~500-700 lines, one new module plus two comment/import-only touches
(`OrderedSum.lean` header, `WeakCanonical.lean` import). Research rates this plumbing-heavy
with no math risk. Implementer confirms by building the module early and often; if the
abstract generalization of the limitdom ℤ-action fights, that is a size signal, not a math
blocker — checkpoint and resume.

**Files to modify**:
- `FormalSystem/Metalogic/WeakCanonical/GroupModel/BlockDecomposition.lean` - new module (the phase's substance)
- `FormalSystem/Metalogic/WeakCanonical/RealModel/OrderedSum.lean` - header comment fix only (no code)
- `FormalSystem/Metalogic/WeakCanonical.lean` - one CI-edge import line

(If `OrderedSum.lean` lives at a different path than `RealModel/`, locate by
`grep -rn "doets_lemma_1_4" FormalSystem/` and edit the file that declares it at line 46.)

**Verification**:
- `lake build` green; `BlockDecomposition` proved with no `sorry`
- `#print axioms` on the main iso and on `BlockDecomposition`: exactly `[propext, Classical.choice, Quot.sound]`
- `grep -rn "strategic sorry" FormalSystem/` no longer flags `doets_lemma_1_5`
- Sorry census unchanged: `Transfer.lean:1102` is still the sole bare sorry in the tree

---

### Phase 2: Monochromatic discrete completeness at depth k [NOT STARTED]

**Goal**: Land `MonoDiscreteNoEnds`, `MonoDiscreteMinNoMax`, and the max-no-min dual: any two
monochromatic (single-colour) discrete linear orders with the same endpoint profile from
{none, min-only, max-only} are `KEquiv` at every depth `k`. This is the task's hardest single
new proof (classical content: Doets 1.0.2/1.0.3, pp. 1–22; Th(ℤ,<)/Th(ω,<) completeness).

**Tasks**:
- [ ] Create `FormalSystem/Metalogic/WeakCanonical/GroupModel/MonoDiscrete.lean` citing Doets
      1987 1.0.2 (back/forth for linear orders) and 1.0.3(i) `m ≡ⁿ ω + ω*` for `m ≥ 2ⁿ − 1`,
      (ii) `ω ≡ⁿ ω + ζ`
- [ ] Define the truncated succ-distance: the *partial* "reachable in ≤ N succ-steps"
      function on an abstract non-Archimedean discrete order (the threshold invariant only
      ever needs it in truncated form — never define a total distance)
- [ ] State the Duplicator invariant: with `d` rounds remaining, matched tuples have pairwise
      succ-distances equal or both `≥ 2^d`, and likewise distances to the endpoint where one
      exists
- [ ] Prove the master no-endpoints lemma (`MonoDiscreteNoEnds`) as an explicit `BackForth`
      strategy, converting via `kEquiv_iff_backForth` (use `backForth_symm`/`_pad`/`_mono`
      helpers from `BackAndForth.lean` as needed)
      — **pre-declared split boundary: if the dispatch is running long, this is the
      checkpoint: commit, mark the phase `[PARTIAL]` here, resume for the variants**
- [ ] Prove the two endpoint variants (`MonoDiscreteMinNoMax` and the max-no-min dual) by
      adapting the invariant with the endpoint-distance clause (the both-ends case is
      deliberately absent: bounded segments are handled by literal isomorphism downstream)
- [ ] Corollaries at `colourSig` for constant colourings (the form Phase 3 consumes)
- [ ] Wire the CI-edge import in `WeakCanonical.lean`

**Timing**: 4-6 hours (one dispatch; split boundary pre-declared above)

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: ~600-1000 lines — the widest and least-probed estimate in the plan (only
the statements were probe-elaborated, not the proofs). Research explicitly names this the
phase to split across two dispatches if any needs it. Implementer confirms scope after the
master lemma lands: if it alone consumed most of the budget, take the declared `[PARTIAL]`
checkpoint rather than compressing the variants.

**Files to modify**:
- `FormalSystem/Metalogic/WeakCanonical/GroupModel/MonoDiscrete.lean` - new module
- `FormalSystem/Metalogic/WeakCanonical.lean` - one CI-edge import line

**Verification**:
- `lake build` green; all three variants + `colourSig` corollaries proved, no `sorry`
- `#print axioms` clean on all landed theorems
- Statements match the elaborated shapes in `verification/tb_statement_probe.lean`
- Sorry census unchanged (`Transfer.lean:1102` sole)

---

### Phase 3: Ramsey factorization, tail absorption, and per-block inflation [NOT STARTED]

**Goal**: Land `TailAbsorption` (both duals) and per-block inflation `Inflate`: for each block
`(ℤ, cᵢ)` there is a colouring `e` of `ℚ ×ₗ ℤ` with `(ℤ, cᵢ) ≡ₖ ℤ + (ℚ ×ₗ ℤ, e)`-shaped
inflations at the SAME depth `k` (the mixing lemma loses no depth).

**Tasks**:
- [ ] Create `FormalSystem/Metalogic/WeakCanonical/GroupModel/RamseyFactorization.lean`;
      transcribe `infinite_ramsey_pairs` from `verification/tb_ramsey_probe.lean` (117 lines,
      fully proved, axioms clean) — transcription, not re-proof; keep the probe's imports:
      `Mathlib.Logic.Denumerable` (for `Nat.Subtype.ofNat`), `Mathlib.Data.Set.Finite.Lattice`
      (for `Set.finite_iUnion`); use `Set.finite_le_nat`, NOT `Set.finite_Iic`; do NOT use
      `Nat.nth`
- [ ] Segment factorization of an ω-block: colour pairs `a < b` of ℕ by the k-type of segment
      `[B_a, B_b)`; apply Ramsey to get `n₀ < n₁ < ⋯` with all segments of one type `τ`;
      prove idempotence `τ ⊕ τ = τ` from `[n₀,n₂) = [n₀,n₁)+[n₁,n₂)`; conclude
      `B ≅ prefix + Σ_ω Sⱼ` with every `Sⱼ ≡ₖ S := [n₀,n₁)`
- [ ] Periodic fiber colouring: define `e` colouring each ℚ-fiber's ℤ periodically by the
      finite word of `S` (each fiber = `Σ_ζ S`)
- [ ] Tail absorption: `B ≡ₖ B + (ℚ ×ₗ ℤ, e)` — reduce via the mixing lemma
      (`kEquiv_orderedSum_of_kEquiv_colour`) to k-equivalence of the k-type-coloured index
      orders `ω` vs `ω + ℚ ×ₗ ζ`, both monochromatic (all summands share type `τ`) and
      discrete with min and no max — closed by Phase 2's `MonoDiscreteMinNoMax`
- [ ] The ω* dual of tail absorption (consumed by Phase 4's minimum-fiber case) via the
      max-no-min variant
- [ ] Per-block inflation: split `(ℤ, cᵢ) = A + B` at 0 (ω*-part + ω-part); shared-index
      composition `doets_lemma_1_4` over a 2-element index reduces inflation to the two tail
      absorptions; land `Inflate`
- [ ] Wire the CI-edge import in `WeakCanonical.lean`

**Timing**: 3-5 hours (one dispatch)

**Depends on**: 2

**Verification Tier**: local

**Scope Hypothesis**: ~500-800 lines, of which ~117 are transcription (Ramsey, already
proved). The unprobed portion is segment/`subinterval` plumbing and the periodic-fiber
colouring definition; the k-equivalence content is all delegated to landed lemmas + Phase 2.
Implementer confirms by landing the Ramsey transcription and segment factorization first —
they are independent of the colouring definition.

**Files to modify**:
- `FormalSystem/Metalogic/WeakCanonical/GroupModel/RamseyFactorization.lean` - new module
- `FormalSystem/Metalogic/WeakCanonical.lean` - one CI-edge import line

**Verification**:
- `lake build` green; `infinite_ramsey_pairs`, `TailAbsorption` (both duals), `Inflate`
  proved, no `sorry`
- `#print axioms` clean (Ramsey's probe set is exactly `[propext, Classical.choice, Quot.sound]`)
- All reductions verified at the SAME depth `k` (no depth loss anywhere in the chain)
- Sorry census unchanged

---

### Phase 4: ℚ-condensation, assembly, and chronicle instantiation [NOT STARTED]

**Goal**: Land `CondensationOfQ`, `CompanionGeneral`, and `CompanionChronicle` — the full
companion lemma at carrier `ℚ ×ₗ ℤ` and its instantiation at
`limitdomMonadicStructure A h_mcs φ`, completing the task's acceptance criteria.

**Tasks**:
- [ ] Create `FormalSystem/Metalogic/WeakCanonical/GroupModel/GroupableCompanion.lean` with a
      module docstring stating the general lemma, citing Doets ch. 7 (pp. 89–93) and the
      inflation-not-compression reading (Löb enters only at compression steps 10–11, which
      the `ℚ ×ₗ ℤ` target replaces), and naming it the Base analogue of `limitdom_is_good`
      (the deliverable the successor consumes) — NO task-number citations
- [ ] ℚ-condensation (`CondensationOfQ`): for countable nonempty `I`, build
      `L := I ×ₗ (1+ℚ)` (ℚ prepended into the minimum fiber when `I` has one, giving shape
      `ℚ+1+ℚ`); prove `L` countable, dense, unbounded; conclude `L ≃o ℚ` by
      `Order.iso_of_countable_dense` (`Mathlib.Order.CountableDenseLinearOrder`, verified
      present). **The density/unboundedness instances on `ℚ ⊕ₗ (I ×ₗ (1+ℚ))`-shaped orders
      are this phase's fiddle (~100-250 lines, unprobed) — do them first**
- [ ] Partition glue iso: fibers give an `I`-indexed convex partition `{Cᵢ}` of ℚ with
      `Cᵢ ≃o 1+ℚ` (resp. `ℚ+1+ℚ`), so `Σ_{i∈I} (Cᵢ ×ₗ ℤ) ≃o ℚ ×ₗ ℤ` — generalize the PROVED
      `sumQZOrderIso` from `verification/tb_statement_probe.lean` (transcribe its proof and
      its tactic gotchas: the defeq `have` + `cases … with | left | right` pattern, the type
      ascription for `Prod.Lex.lt_iff`); the minimum-fiber case consumes Phase 3's ω* dual
- [ ] Assemble `CompanionGeneral`: `M ≃o Σ_I blocks` (Phase 1) → `≡ₖ Σ_I inflated-segments`
      (Phase 3, via `doets_lemma_1_4` at shared index `I`) → `≃o` a colouring of `ℚ ×ₗ ℤ`
      (condensation + glue) → `goodGroupable sig k M` via `k_equiv_of_iso` + `KEquiv.trans`
      (`KEquiv` is `Eq`, so `trans`/`symm` are free) + T-A's `goodGroupable`;
      unboundedness side goals close with `Prod.Lex.right _ (by simp)` (NOT `omega`; import
      `Mathlib.Algebra.Order.Monoid.Prod`)
- [ ] `CompanionChronicle`: instantiate at `M := limitdomMonadicStructure A h_mcs φ`; the five
      instance obligations are landed and fc-generic (`limitdom_monadic_structure_countable`,
      Succ/Pred from `box_discrete_gives_discreteness` — takes `h_box` directly, no
      `Discrete ≤ fc` hypothesis — noMax/noMin, `zero_mem`-nonempty); mirror
      `limitdom_is_good`'s preamble (`ReynoldsBridge.lean:361–385`) with the Discrete-only
      links dropped
- [ ] Wire the CI-edge import in `WeakCanonical.lean`; final acceptance audit (below)

**Timing**: 3-4 hours (one dispatch)

**Depends on**: 1, 2, 3

**Verification Tier**: full

**Scope Hypothesis**: ~500-800 lines. The load-bearing unknown is the density/unboundedness
instance block (~100-250 lines); the glue iso generalizes an already-proved probe. Implementer
confirms by attacking the instance block first — if it exceeds ~300 lines, checkpoint before
assembly rather than after.

**Files to modify**:
- `FormalSystem/Metalogic/WeakCanonical/GroupModel/GroupableCompanion.lean` - new module
- `FormalSystem/Metalogic/WeakCanonical.lean` - one CI-edge import line

**Verification** (= task acceptance):
- `lake build` green across the whole tree; no new `sorry`; no new axiom
- `CompanionGeneral` and `CompanionChronicle` sorry-free at carrier `ℚ ×ₗ ℤ`;
  `#print axioms` on both: exactly `[propext, Classical.choice, Quot.sound]`
- Sole structural sorry remains `countermodel_discrete` (`Transfer.lean:1102`); count
  unchanged
- If (and only if) the escape hatch was taken: the fallback/weakening is explicitly recorded
  in the `GroupableCompanion.lean` module docstring and the statement is named distinctly —
  verify no silent weakening of `CompanionGeneral`

## Testing & Validation

- [ ] After every phase: `lake build` green (full gate — tiering never weakens this)
- [ ] After every phase: `grep -rn "sorry" FormalSystem/ | grep -v "\-\-"` shows only
      `Transfer.lean:1102` (or equivalent census via the repo's audit convention)
- [ ] After every phase: `#print axioms` on all newly landed theorems — expected set exactly
      `[propext, Classical.choice, Quot.sound]`; anything else is a stop-and-investigate
- [ ] Phase 4: `lean_verify` (or `#print axioms` + source scan) on `CompanionGeneral` and
      `CompanionChronicle` by fully qualified name
- [ ] Repo lints: no task-number references in `.lean` files; no `veryGoodGroupable`; no
      interval carrier type introduced
- [ ] Counterexample protocol: if any classical step is refuted during implementation, STOP,
      write the counterexample up precisely (failing step + witness), mark phase `[BLOCKED]`
      with the finding as a first-class result — do NOT push through with a sorry and do NOT
      treat it as failure

## Artifacts & Outputs

- `FormalSystem/Metalogic/WeakCanonical/GroupModel/BlockDecomposition.lean` (Phase 1)
- `FormalSystem/Metalogic/WeakCanonical/GroupModel/MonoDiscrete.lean` (Phase 2)
- `FormalSystem/Metalogic/WeakCanonical/GroupModel/RamseyFactorization.lean` (Phase 3)
- `FormalSystem/Metalogic/WeakCanonical/GroupModel/GroupableCompanion.lean` (Phase 4)
- CI-edge imports in `FormalSystem/Metalogic/WeakCanonical.lean` (one line per phase)
- Header comment fix in the module declaring `doets_lemma_1_4` (Phase 1)
- `specs/478_tb_groupable_companion_lemma/summaries/01_execution-summary.md` (postflight)

## Rollback/Contingency

- Each phase is a self-contained new module plus a one-line import: rollback = revert the
  phase's commits (module file + import line), leaving the tree exactly at the previous green
  state. No existing proof is modified anywhere in the plan (the only touches to existing
  files are one comment fix and import lines), so rollback can never destabilize landed work.
- Commit-per-green-substep applies throughout; use `git-snapshot.sh 478` before any
  intentional destructive git operation.
- If Phase 2 or Phase 4 stalls after genuine attempts: escalate to the escape hatch per its
  recorded conditions (explicit distinct name + docstring recording), or mark `[BLOCKED]`
  with the precise obstruction — never a silent weakening, never a new sorry.
