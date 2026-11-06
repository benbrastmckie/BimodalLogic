# Implementation Plan: Task #881

- **Task**: 881 - Generic schema-validity layer over TruthEnv/StabClauses
- **Status**: [IMPLEMENTING]
- **Effort**: 19.5 hours
- **Dependencies**: None
- **Research Inputs**: None (no `research_path` supplied; Stage 1.5 opening assessment
  concluded the description plus direct codebase reads suffice — see "Why no research round"
  below)
- **Artifacts**: plans/01_generic-schema-validity-layer.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

State each TM⁺ mirror schema **once**, pointwise, over the existing
`[TruthEnv L]` / `[StabClauses L]` clause interface in a new module
`FormalSystem/Metalogic/SoundnessLemmas/GenericSchemata.lean`, then turn the per-language
`starValid_*` and `openValidIn_*` theorem **bodies** into one-line delegations while keeping
every per-language name, statement and attribute exactly as it is today. This is the third
application of a refactoring pattern this repository has already performed twice and documented
as an extension contract: `Semantics/ValidityLayer.lean` (validity layer over `PointTruth`) and
`Semantics/TruthClauses.lean` (clause layer over `TruthEnv`), each of which states explicitly
that "the per-language theorems become one-line delegations". The generic statements are
**pointwise** (`TruthEnv.T M τ t e …`), not validity-level, so a wrapper is one
`Valid.of_forall fun F M τ x [v] => generic_… M τ x [v] …` line and no `PointTruth`/`TruthEnv`
bridge class is needed.

### Why no research round

Stage 1.5's bar is narrow: research is requested only when the plan would otherwise rest on
guesses an agent must go investigate. Everything load-bearing here was settled by targeted reads
inside this dispatch:

- `Semantics/TruthClauses.lean` (677 lines) already carries `TruthEnv`, `BotClause`,
  `ImpClause`, `BoxClause`, `UntlClause`, `SnceClause`, `StabClause` and the bundles
  `BoolClauses`/`UntlClauses`/`TenseClauses`/`StabClauses`, with the full extension contract
  written from landed instantiations.
- `StabClauses` instances already exist for **four** languages, not two:
  `PlusLanguage/PlusTruth.lean:106`, `StarLanguage/StarTruth.lean:144`,
  `OpenLanguage/OpenTruth.lean:107`, `HybridLanguage/HybridTruth.lean:108`; `TruthEnv` also for
  `MinusFormula` and `QuantFormula`. The generic layer therefore serves more consumers than the
  task description anticipated.
- Every mirror arm read in `Star/StarAxiomValidity.lean` and `Open/OpenAxiomValidity.lean` is a
  `simp only [<Lang>Truth.*_iff]` + `rintro`/`rcases lt_trichotomy` proof over clause lemmas that
  are already per-language wrappers of the generic `TruthClauses.*_iff` family. The
  generalisation is mechanical.
- The order-theoretic inputs are **already** abstract over a predicate:
  `SoundnessLemmas/DiscreteOrder.lean`'s `exists_nearest_gt` / `exists_nearest_lt` /
  `forall_gt_of_succ_step` / `forall_lt_of_pred_step` and `SoundnessLemmas/Separability.lean`'s
  `sep_order` / `sep_order_mirror` all quantify `P : D → Prop`.
- The two named obstructions from the task description were both confirmed directly (see
  "The two recorded obstructions" below).

The only genuinely open items are implementation-time confirmations (exact arm counts, exact
line savings), which are recorded as **Scope Hypothesis** lines on the phases that assert them
rather than deferred to a research dispatch.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` supplied in the delegation context; `specs/ROADMAP.md` was not consulted and
is not modified by this plan.

### The two recorded obstructions, confirmed

**1 — `openTruthAt_timeShift`.** Confirmed landed at
`FormalSystem/Metalogic/Conservativity/Open/OpenAxiomValidity.lean:604`, with
`openTruthAt_congr_ext` at `:567`. Time shift is explicitly listed in `ValidityLayer.lean`'s
"What is NOT inherited — the honest boundary" because its *statement* differs per language
(L⋆'s shifts the stored-time vector alongside the history). It therefore **cannot** become a
clause-class field. The plan's response (Phase 8) is to state `generic_modal_future` with the
homogeneity fact as an **explicit hypothesis argument**, which each language discharges from its
own `*TruthAt_timeShift` lemma. This preserves the boundary rather than violating it.

**2 — non-uniform disjunct nesting.** Confirmed, and more precisely than the description states.
Two distinct axes are involved:

| Family | Variant A | Variant B | Difference |
|--------|-----------|-----------|------------|
| `linear_until` / `linear_since` | `or (or A B) C` | `or A (or B C)` | genuine **nesting** |
| `temp_linearity` / `temp_linearity_past` | `or A (or B C)` | `or A (or B C)` | **disjunct order only** |

`StarAxiomValidity.lean` carries both variants for both families (`starValid_linear_until` /
`starValid_linear_until_paper`, `starValid_linear_since` / `starValid_linear_since_paper`,
`starValid_temp_linearity` / `starValid_temp_linearity_paper`,
`starValid_temp_linearity_past` / `starValid_temp_linearity_past_paper`).
`OpenAxiomValidity.lean:1243`'s own section docstring records that `OpenAxiom.linear_until` and
`temp_linearity` take the right-associated/paper disjunction while `linear_since` and
`temp_linearity_past` take the other, and transcribes each from whichever `starValid_*` theorem
matches. **The generic layer must supply all four variant pairs** (Phase 4 and Phase 5), so each
language picks the shape its own axiom type declares. No language is asked to change its
statement.

## Goals & Non-Goals

**Goals**:
- `kPlus_iff` -- the Reynolds forward gap operator unfolded once over the clause interface.
- `kMinus_iff` -- its past mirror, replacing the four per-language gap transcriptions.
- `generic_atom_stab` -- the AS schema over a new atom-clause interface.
- `generic_linear_until_paper` -- CN in the right-associated nesting.
- `generic_linear_since` -- BX7' in the left-associated nesting, pinned so neither language's
  statement is silently re-associated.
- `generic_temp_linearity_paper` -- TL in the paper's disjunct order.
- `generic_temp_linearity_past` -- BX11' in the other disjunct order.

Two further outcomes are goals of the task but name no new identifier, so they are stated here
rather than as Goals bullets: every per-language validity theorem keeps its name, statement and
attributes unchanged (only bodies shrink), and the generic statements live in one new module,
`FormalSystem/Metalogic/SoundnessLemmas/GenericSchemata.lean`, carrying an extension-contract
docstring in the style of the two existing layers.

**Non-Goals**:
- Deleting or renaming any `starValid_*`, `openValidIn_*`, `openAxiomValidIn_*Block`, or
  dispatch-lemma identifier. The dispatchers' arm lists are the contract; only proof bodies
  change.
- Generalising the **pasting** schemata (`paste`, `untl_paste` and their duals). They consume
  per-language purity predicates (`StarIsPureFuture`/`StarIsPurePast`, `IsPureFutureOpen`/
  `IsPurePastOpen`) and the per-language pasting congruences, all of which are proved by
  `induction φ` — the exact boundary `ValidityLayer.lean` declares not inheritable. Their
  current bodies are already one line each, so there is nothing to recover.
- Generalising the L^▷ restricted-modal block (`ofut`/`opast`), the rigidity block, or the
  L⋆ register block. These are not TM⁺ mirror schemata.
- Deleting `Conservativity/Plus/Atomization.lean` or dismantling the L⁺ atomization route.
- Any edit to `scripts/nolints.json` (held by concurrent task 889 — see Risks).
- Redeploying the stale `.claude/` tree flagged in the dispatch's
  `<deploy-freshness-context>`. That is an agent-system concern, orthogonal to this Lean task,
  and is deliberately left alone.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Deleting ~1,500 lines invalidates `file.lean:NNN` citations elsewhere, tripping `check-module-invariants.sh` C20 | M | H | Run `python3 scripts/reanchor-lean-citations.py --by-name --files <target>` in Phase 12 and read the diff; never add a key to `scripts/c20-declaration-baseline.txt` to quiet a new failure |
| A generic lemma is not *definitionally* the per-language statement (the `rfl` bridge fails), forcing a `show` at each call site | H | M | Phase 1 adds `example … := rfl` pins for every new bridge (`kPlus`, `kMinus`, `atom`) to `Tests/BimodalTest/Semantics/ValidityLayerTest.lean`, alongside the ~40 pins already there; a failing pin is the signal to keep that one lemma per-language |
| Axiom-profile drift: a generic proof reaches for a classical tactic and adds `Classical.choice` to wrappers that were `[propext]` | M | M | Follow `TruthClauses.lean`'s stated classical discipline (`rw` + explicit terms, never `by_contra`/`push Not` where avoidable); spot-check with `lean_verify` on the rewired wrappers in Phases 9–11 |
| Placing generic content in `Semantics/` would be an upward import of `Metalogic/SoundnessLemmas/`, breaking `check-metalogic-cycles.sh` assertion B (8-line upward allowlist) | H | L | Module is placed in `Metalogic/SoundnessLemmas/`, which already imports `Semantics/` downward and from which `Conservativity/` already imports — no new directory edge |
| Concurrent sibling task 837 has **no declared `file_scope`** and may touch any file | M | M | Re-read every target file immediately before editing; stage explicit file lists only (never `git add -A`/directory/glob); treat an unexpected failure outside this plan's file list as possibly a sibling's in-flight edit and report rather than "fix" it |
| A lint finding appears that would normally be waived in `scripts/nolints.json`, which task 889 holds | L | M | Fix the code instead of the waiver file; if genuinely unfixable, mark the phase `[BLOCKED]` and report rather than editing `nolints.json` |
| Phase 9/10 rewires (69 and ~100 arms) overrun their 2h budget | L | M | Each rewire is independently committable per block; if a phase overruns, close it `[PARTIAL]` at a block boundary with a green build and resume |
| Adding a new class to `TruthClauses.lean` perturbs instance resolution in an unrelated consumer | M | L | `AtomClause` is purely additive with no `extends` into an existing bundle; Phase 1's `local` build covers every current `TruthEnv` instance site |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |
| 6 | 6 | 5 |
| 7 | 7 | 6 |
| 8 | 8 | 7 |
| 9 | 9, 10, 11 | 8 |
| 10 | 12 | 9, 10, 11 |

Phases within the same wave can execute in parallel. Phases 2–8 are deliberately serialized
despite having no logical dependency on one another: they all edit the single file
`GenericSchemata.lean`, and parallel edits to one file manufacture conflicts for no gain.
Phases 9, 10 and 11 edit three *different* files and are genuinely parallel.

---

### Phase 1: Clause-interface extensions — `AtomClause`, `kPlus`/`kMinus` [COMPLETED]

**Goal**: Extend `Semantics/TruthClauses.lean` with the two pieces of clause-layer vocabulary the
generic schemata need and that it does not yet carry, and instantiate them.

**Tasks**:
- [x] Add `class AtomClause (L : Type) [TruthEnv L]` with fields `atom : Atom → L` and
      `atom_clause : ∀ {F} (M : TaskModel F) (τ) (t) (e) (p : Atom),
      TruthEnv.T M τ t e (atom p) ↔ M.valuation (τ.state t) p`. Confirmed identical clause shape
      in `Semantics/Truth.lean:299`, `PlusLanguage/PlusTruth.lean:126`,
      `StarLanguage/StarTruth.lean:162`, `OpenLanguage/OpenTruth.lean:127`.
- [x] Add `abbrev kPlus (φ : L) : L := neg (UntlClause.untl (neg φ) top)` and
      `abbrev kMinus (φ : L) : L := neg (SnceClause.snce (neg φ) top)` in the `untl`/`snce`
      tiers. Confirmed definitionally identical in `Syntax/Formula.lean:197,210`,
      `PlusLanguage/Formula.lean:152,155`, `StarLanguage/Formula.lean:170,173`,
      `OpenLanguage/OpenAxioms.lean:114,117`.
- [x] Prove `TruthClauses.kPlus_iff` and `TruthClauses.kMinus_iff` (statements pinned under
      `## Lean Challenge Statements`), transcribing the argument from
      `StarAxiomValidity.lean:830` / `:845` with `StarTruthAt M τ t v ↦ TruthEnv.T M τ t e`.
- [x] Declare `AtomClause` instances (every field `Iff.rfl`) in `Semantics/Truth.lean`,
      `MinusLanguage/MinusTruth.lean`, `PlusLanguage/PlusTruth.lean`,
      `StarLanguage/StarTruth.lean`, `OpenLanguage/OpenTruth.lean`,
      `HybridLanguage/HybridTruth.lean`, `QuantLanguage/QuantTruth.lean`.
- [x] Add `example … := rfl` bridge pins for `kPlus`, `kMinus` and `atom` in each language to
      `Tests/BimodalTest/Semantics/ValidityLayerTest.lean`, matching the ~40 pins already there.
- [x] Extend `TruthClauses.lean`'s "Design Invariants — the extension contract" section: add
      `AtomClause` to the tier table, record the new `rfl` bridges, and note that the generic
      lemmas still carry **no** attributes.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: atomic-batch

**Scope Hypothesis**: Seven languages are asserted to have an `atom` constructor with the
`M.valuation (τ.state t) p` clause. Four were read directly; `MinusFormula`, `HybridFormula` and
`QuantFormula` are inferred from the shared `TaskModel` valuation signature. Confirm at
implementation time with
`grep -n "theorem atom_iff" -A3 FormalSystem/MinusLanguage/MinusTruth.lean
FormalSystem/HybridLanguage/HybridTruth.lean FormalSystem/QuantLanguage/QuantTruth.lean`; drop
any language whose clause shape differs and say so in the handoff.

**Tier Justification**: A scoped
`lake build FormalSystem.Semantics.TruthClauses FormalSystem.Semantics.Truth
FormalSystem.MinusLanguage.MinusTruth FormalSystem.PlusLanguage.PlusTruth
FormalSystem.StarLanguage.StarTruth FormalSystem.OpenLanguage.OpenTruth
FormalSystem.HybridLanguage.HybridTruth FormalSystem.QuantLanguage.QuantTruth
BimodalTest.Semantics.ValidityLayerTest` compiles every site that declares or consumes the new
class and abbrevs, and nothing outside that set references names that do not yet exist.

**Files to modify**:
- `FormalSystem/Semantics/TruthClauses.lean` - `AtomClause` class, `kPlus`/`kMinus` abbrevs,
  `kPlus_iff`/`kMinus_iff`, extension-contract docstring update
- `FormalSystem/Semantics/Truth.lean` - `AtomClause Formula` instance
- `FormalSystem/MinusLanguage/MinusTruth.lean` - `AtomClause MinusFormula` instance
- `FormalSystem/PlusLanguage/PlusTruth.lean` - `AtomClause PlusFormula` instance
- `FormalSystem/StarLanguage/StarTruth.lean` - `AtomClause StarFormula` instance
- `FormalSystem/OpenLanguage/OpenTruth.lean` - `AtomClause OpenFormula` instance
- `FormalSystem/HybridLanguage/HybridTruth.lean` - `AtomClause HybridFormula` instance
- `FormalSystem/QuantLanguage/QuantTruth.lean` - `AtomClause QuantFormula` instance
- `Tests/BimodalTest/Semantics/ValidityLayerTest.lean` - `rfl` bridge pins for the new operators

**Verification**:
- Scoped build above is green.
- Every new `example … := rfl` pin elaborates (a failure is a real finding, not a nuisance —
  record which bridge failed).
- `lean_verify FormalSystem.Semantics.TruthClauses.kPlus_iff` reports no axiom beyond `propext`.
  *(measured: `[propext, Classical.choice, Quot.sound]` — the classical `¬∀ ⇒ ∃` step is
  irreducible, and the lemma this replaces, `starKPlus_iff`, has the identical profile, so
  no axiom is gained. The plan's `[propext]` prediction was unmeasured.)*

---

### Phase 2: New module + the Boolean, S5-modal and `⊡` tier [NOT STARTED]

**Goal**: Create `GenericSchemata.lean` with its extension-contract docstring and the fifteen
schemata that need only `BotClause`/`ImpClause`/`BoxClause`/`StabClause`/`AtomClause`.

**Tasks**:
- [ ] Create `FormalSystem/Metalogic/SoundnessLemmas/GenericSchemata.lean` in namespace
      `FormalSystem.Metalogic.SoundnessLemmas`, importing
      `FormalSystem.Semantics.TruthClauses`. All new names carry the `generic_` prefix,
      mirroring `ValidityLayer.lean`'s `Generic*` convention; no new namespace is introduced
      (C23 no-bare-namesake).
- [ ] Write the module docstring in the house style of `TruthClauses.lean`: Main Results, the
      pointwise-not-validity design decision, the per-language one-line-wrapper shape for both
      point shapes (`fun F M τ x => …` and `fun F M τ x v => …`), and an explicit
      "What is NOT generic" boundary naming the pasting schemata and time shift.
- [ ] Prove the fifteen: `generic_prop_k`, `generic_prop_s`, `generic_ex_falso`,
      `generic_peirce`, `generic_modal_t`, `generic_modal_4`, `generic_modal_b`,
      `generic_modal_5_collapse`, `generic_modal_k_dist`, `generic_stab_k`, `generic_stab_t`,
      `generic_stab_4`, `generic_stab_5`, `generic_box_stab`, `generic_atom_stab`.
- [ ] Each lemma names only the operator classes its proof consumes — never a bundle — per
      `TruthClauses.lean`'s stated grain invariant.
- [ ] Add the module to `FormalSystem/Metalogic/SoundnessLemmas.lean`'s import list.
- [ ] Carry **no** attributes on any generic lemma.

**Timing**: 2 hours

**Depends on**: 2 requires 1

**Verification Tier**: local

**Tier Justification**: `lake build FormalSystem.Metalogic.SoundnessLemmas` compiles the new
module and its one aggregator edge in full; nothing else imports it yet, so no wider surface
exists to regress.

**Files to modify**:
- `FormalSystem/Metalogic/SoundnessLemmas/GenericSchemata.lean` - new module, docstring, fifteen
  Boolean/modal/`⊡` schemata
- `FormalSystem/Metalogic/SoundnessLemmas.lean` - import the new module

**Verification**:
- Scoped build green.
- No `sorry` and no vacuous definition in the new module
  (`grep -n "sorry\|:= True\|:= trivial" FormalSystem/Metalogic/SoundnessLemmas/GenericSchemata.lean`
  returns nothing).

---

### Phase 3: Seriality, monotonicity and connection tier [NOT STARTED]

**Goal**: Ten more generic schemata, the first group to consume a frame constraint.

**Tasks**:
- [ ] `generic_serial_future`, `generic_serial_future_imp`, `generic_serial_past`,
      `generic_serial_past_bare` — each taking `[F.IsRegular]`, reading `F.serial` off the frame
      rather than transporting through `ofPlus`. (The L⋆ and L^▷ arms currently reach these by
      transport because the formulas are closed; the generic form removes the detour and serves
      languages with no `ofPlus` embedding.)
- [ ] `generic_left_mono_until_G`, `generic_left_mono_since_H`, `generic_right_mono_until`,
      `generic_right_mono_since` — transcribed from `StarAxiomValidity.lean:369`–`:396`.
- [ ] `generic_connect_future`, `generic_connect_past` — from `:405`/`:413`.

**Timing**: 1.5 hours

**Depends on**: 2

**Verification Tier**: local

**Tier Justification**: Same single-module surface as Phase 2 —
`lake build FormalSystem.Metalogic.SoundnessLemmas` is the complete covering check while no
consumer imports the module.

**Files to modify**:
- `FormalSystem/Metalogic/SoundnessLemmas/GenericSchemata.lean` - seriality / monotonicity /
  connection section

**Verification**:
- Scoped build green.
- The four seriality lemmas genuinely consume `F.IsRegular` (deleting the instance binder breaks
  the build) — this is the load-bearing-hypothesis check `lean4.md`'s vacuity rule asks for.

---

### Phase 4: Enrichment, self-accumulation, absorption and `U`/`S` linearity [NOT STARTED]

**Goal**: The heaviest BX group, including **both** nesting variants of CN/BX7.

**Tasks**:
- [ ] `generic_enrichment_until`, `generic_enrichment_since`, `generic_self_accum_until`,
      `generic_self_accum_since`, `generic_absorb_until`, `generic_absorb_since`.
- [ ] `generic_linear_until` (left-associated, `or (or A B) C`) and
      `generic_linear_until_paper` (right-associated, `or A (or B C)`).
- [ ] `generic_linear_since` (left-associated) and `generic_linear_since_paper`
      (right-associated).
- [ ] Record in the section docstring that all four exist on purpose, that `OpenAxiom` takes the
      paper nesting for `linear_until` and the other for `linear_since` while `StarAxiom`
      carries both, and that **no language's statement is re-associated by this refactor**.

**Timing**: 2 hours

**Depends on**: 3

**Verification Tier**: local

**Tier Justification**: Same single-module surface; `lake build
FormalSystem.Metalogic.SoundnessLemmas` covers every declaration added here and the module has
no importers yet.

**Files to modify**:
- `FormalSystem/Metalogic/SoundnessLemmas/GenericSchemata.lean` - enrichment / accumulation /
  absorption / linearity section

**Verification**:
- Scoped build green.
- The four linearity statements match, term for term, `starValid_linear_until`,
  `starValid_linear_until_paper`, `starValid_linear_since`, `starValid_linear_since_paper`
  under the substitution `StarFormula.X ↦ TruthClauses.X`. Check by eye against
  `StarAxiomValidity.lean:492`, `:511`, `:530`, `:549` — a nesting slip here is exactly the
  defect `plan-compliance.md`'s Statement Fidelity section exists to catch.

---

### Phase 5: `until_F`/`since_P`, temporal linearity and the `F`/`P` equivalences [NOT STARTED]

**Goal**: Eight more schemata, including **both** disjunct orderings of TL/BX11.

**Tasks**:
- [ ] `generic_until_F`, `generic_since_P`.
- [ ] `generic_temp_linearity`, `generic_temp_linearity_paper` (future; differ in disjunct
      order, both `or A (or B C)`).
- [ ] `generic_temp_linearity_past`, `generic_temp_linearity_past_paper` (past mirrors).
- [ ] `generic_F_until_equiv`, `generic_P_since_equiv`.
- [ ] Note in the section docstring that the two TL variants differ in disjunct **order**, not
      nesting — unlike the CN pair in Phase 4 — so a reader does not conflate the two axes.

**Timing**: 1.5 hours

**Depends on**: 4

**Verification Tier**: local

**Tier Justification**: Same single-module surface; the scoped
`lake build FormalSystem.Metalogic.SoundnessLemmas` is the complete covering check.

**Files to modify**:
- `FormalSystem/Metalogic/SoundnessLemmas/GenericSchemata.lean` - `until_F` / temporal-linearity
  / equivalence section

**Verification**:
- Scoped build green.
- Statements match `StarAxiomValidity.lean:570`, `:578`, `:586`, `:600`, `:614`, `:628`, `:642`,
  `:651` term for term under the clause-layer substitution.

---

### Phase 6: Discrete uniformity, density, Prior-Z and Z1 [NOT STARTED]

**Goal**: The frame-class-restricted tier, consuming `SoundnessLemmas/DiscreteOrder.lean`.

**Tasks**:
- [ ] The five closed uniformity schemata plus the three duals with no sibling constructor:
      `generic_discrete_symm_fwd`, `generic_discrete_symm_bwd`,
      `generic_discrete_propagate_fwd`, `generic_discrete_propagate_fwd_reflect_time`,
      `generic_discrete_propagate_bwd`, `generic_discrete_propagate_bwd_reflect_time`,
      `generic_discrete_box_necessity`, `generic_discrete_box_necessity_reflect_time`.
      These are closed formulas; state them with the frame constraints as instance binders
      rather than transporting through any language's `ofPlus`.
- [ ] `generic_density`, `generic_density_reflect_time` under `[DenselyOrdered F.Duration]`.
- [ ] `generic_dense_indicator`, `generic_dense_indicator_reflect_time`.
- [ ] `generic_prior_UZ`, `generic_prior_SZ` through `SoundnessLemmas.exists_nearest_gt` /
      `exists_nearest_lt` at `P := fun x => TruthEnv.T M τ x e φ`.
- [ ] `generic_z1`, `generic_z1_reflect_time` through `forall_gt_of_succ_step` /
      `forall_lt_of_pred_step` at the same predicate.
- [ ] Add the `DiscreteOrder` import. Record in the docstring that the order content is **not**
      inlined — the same invariant `StarAxiomValidity.lean`'s own docstring asserts.

**Timing**: 2 hours

**Depends on**: 5

**Verification Tier**: local

**Tier Justification**: The new import is `FormalSystem.Metalogic.SoundnessLemmas.DiscreteOrder`,
a sibling inside the directory the scoped `lake build FormalSystem.Metalogic.SoundnessLemmas`
already compiles, so that one build still covers the whole changed surface.

**Scope Hypothesis**: Sixteen declarations are asserted for this tier, read off
`StarAxiomValidity.lean:680`–`:815`. Confirm at implementation time that each has a matching
`openValidIn_*` in `OpenAxiomValidity.lean:1561`–`2026`; if the two languages' sets differ, state
the generic form once per distinct statement and record the asymmetry in the section docstring.

**Files to modify**:
- `FormalSystem/Metalogic/SoundnessLemmas/GenericSchemata.lean` - discrete / density / Prior-Z /
  Z1 section, plus the `DiscreteOrder` import

**Verification**:
- Scoped build green.
- Each frame-class hypothesis is load-bearing: removing `[DenselyOrdered F.Duration]` from
  `generic_density` must break the build.

---

### Phase 7: The Reynolds Dedekind tier — gap operators and `sep` [NOT STARTED]

**Goal**: The four hardest order-dependent schemata, consuming
`SoundnessLemmas/Separability.lean` and Phase 1's `kPlus_iff`/`kMinus_iff`.

**Tasks**:
- [ ] `generic_prior_U_gap`, `generic_prior_S_gap` — transcribed from
      `StarAxiomValidity.lean:896`/`:940`, with `starKPlus_iff` replaced by Phase 1's
      `TruthClauses.kPlus_iff`.
- [ ] `generic_sep`, `generic_sep_reflect_time` — from `:984`/`:1038`, consuming
      `SoundnessLemmas.sep_order` / `sep_order_mirror` at
      `P := fun x => TruthEnv.T M τ x e φ`.
- [ ] Add the `Separability` import.

**Timing**: 2 hours

**Depends on**: 1, 6

**Verification Tier**: local

**Tier Justification**: `Separability.lean` is another sibling inside
`Metalogic/SoundnessLemmas/`, so `lake build FormalSystem.Metalogic.SoundnessLemmas` still
compiles every file this phase touches or newly depends on.

**Files to modify**:
- `FormalSystem/Metalogic/SoundnessLemmas/GenericSchemata.lean` - Dedekind section, plus the
  `Separability` import

**Verification**:
- Scoped build green.
- The `sep` proofs route through `sep_order`/`sep_order_mirror` rather than re-deriving the
  nested-interval argument (`grep -c "sep_order"` in the new section is at least 2).

---

### Phase 8: `modal_future` — generic core with an explicit homogeneity hypothesis [NOT STARTED]

**Goal**: Recover MF generically without violating `ValidityLayer.lean`'s "time shift is not
inherited" boundary.

**Tasks**:
- [ ] State `generic_modal_future` taking the homogeneity fact as an **explicit hypothesis**,
      shaped so that each language discharges it from its own time-shift lemma:
      `(hhom : ∀ (σ : WorldHistory F) (s : F.Duration), t < s →
      (∀ ρ : WorldHistory F, TruthEnv.T M ρ t e φ) → TruthEnv.T M σ s e φ)`, concluding
      `TruthEnv.T M τ t e (ImpClause.imp (BoxClause.box φ) (BoxClause.box (allFuture φ)))`.
- [ ] State `generic_modal_future_reflect_time` the same way over `allPast`.
- [ ] Record in the docstring **why** the hypothesis is explicit rather than a class field: the
      three languages' time-shift statements genuinely differ (L⋆'s drags the stored-time vector
      along, L^▷'s needed a bespoke `openTruthAt_congr_ext`), which is the documented reason
      time shift sits outside both existing layers.
- [ ] Verify the hypothesis is dischargeable from each landed lemma **before** rewiring:
      `plusTruthAt_timeShift`, `starTruthAt_timeShift` (+ `recallFree_vector_irrelevant` for the
      `RecallFree` side condition), `openTruthAt_timeShift`.

**Timing**: 1.5 hours

**Depends on**: 7

**Verification Tier**: local

**Tier Justification**: The generic core adds no import and no consumer, so the scoped
`lake build FormalSystem.Metalogic.SoundnessLemmas` covers it; the per-language discharge is
checked inside Phases 9–11, which carry the wider tier.

**Decision gate**: if the hypothesis shape cannot be discharged uniformly from all three
languages' time-shift lemmas, do **not** force a weaker statement. Leave `modal_future`
per-language in all three files, record the finding in the handoff and in the module docstring's
"What is NOT generic" list, and continue to Phase 9 — the rest of the plan does not depend on
this phase's outcome.

**Files to modify**:
- `FormalSystem/Metalogic/SoundnessLemmas/GenericSchemata.lean` - `modal_future` section

**Verification**:
- Scoped build green.
- The hypothesis is load-bearing (the lemma does not elaborate with it removed).

---

### Phase 9: Rewire L⋆ — `StarAxiomValidity.lean` [NOT STARTED]

**Goal**: Replace every generic-subsumed mirror-arm proof body with a one-line delegation,
preserving all names and statements.

**Tasks**:
- [ ] Add the `GenericSchemata` import.
- [ ] Rewrite each subsumed `starValid_*` body as
      `StarValid.of_forall fun F M τ x v => generic_… M τ x v …` (or
      `of_forall_regular` where the arm consumes a frame constraint).
- [ ] Delete `starKPlus_iff` / `starKMinus_iff` only if no consumer outside this file remains;
      otherwise keep them as one-line delegations to `TruthClauses.kPlus_iff`/`kMinus_iff`.
      Check first with `grep -rn "starKPlus_iff\|starKMinus_iff" FormalSystem/ Tests/`.
- [ ] Leave untouched: the sixteen register schemata, `recallFree_vector_irrelevant`, the four
      pasting arms, and the two dispatch lemmas' arm structure.
- [ ] Trim the module docstring's "How the arms close" section to describe the delegation rather
      than the (now removed) direct transcriptions, keeping the "no atomization, no uniform
      substitution" invariant statement, which is still true and still load-bearing.

**Timing**: 2 hours

**Depends on**: 8

**Verification Tier**: interface

**Scope Hypothesis**: Roughly 55–60 of the file's ~69 named mirror theorems are asserted
subsumable (the task description says 53; the file's own docstring says 53 arms, while the
theorem count including named `*_reflect_time` duals is higher). Confirm at implementation time
by listing `grep -c "^theorem starValid_"` before and after and reporting both numbers plus the
line delta in the handoff; do not assert a count that was not measured.

**Tier Justification**: Statements are preserved but bodies, axiom profiles and the file's import
set all change, and `Conservativity/Star/StarSoundness.lean` plus
`Conservativity/Star/Forward.lean` consume the dispatch lemmas — so
`lake build FormalSystem.Metalogic.Conservativity.Star` is the cheapest check that covers every
consumer, and a `local` build of the one file would miss them.

**Files to modify**:
- `FormalSystem/Metalogic/Conservativity/Star/StarAxiomValidity.lean` - mirror-arm bodies become
  delegations; import added; docstring updated

**Verification**:
- `lake build FormalSystem.Metalogic.Conservativity.Star` green.
- `starAxiom_validIn_min` and `starAxiom_reflect_time_validIn_min` still have one arm per
  constructor and **no wildcard arm**.
- `lean_verify FormalSystem.Metalogic.Conservativity.starAxiom_validIn_min` shows no axiom gained
  relative to the pre-phase profile (capture it before editing).

---

### Phase 10: Rewire L^▷ — `OpenAxiomValidity.lean` [NOT STARTED]

**Goal**: The same rewire for the largest of the three files.

**Tasks**:
- [ ] Add the `GenericSchemata` import.
- [ ] Rewrite the subsumed bodies in the propositional, S5-modal, temporal-monotonicity,
      temporal-accumulation, linearity, `F`/`P`-equivalence, discrete, Prior/Dedekind, density
      and stability blocks as one-line delegations.
- [ ] Replace the nine `openTruth_*_iff` clause re-exports (`:480`–`:546`) with delegations to
      the generic `TruthClauses.*_iff` family, or delete them if the rewired bodies no longer
      need the local names (`grep -rn "openTruth_imp_iff" FormalSystem/ Tests/` first).
- [ ] Collapse `openKPlus_iff`/`openKMinus_iff` onto `TruthClauses.kPlus_iff`/`kMinus_iff` under
      the same consumer check as Phase 9.
- [ ] Leave untouched: the restricted-modal (`▷`/`◁`) block, the rigidity block, the two purity
      congruences, `openTruthAt_congr_ext`, `openTruthAt_timeShift`, the pasting block, the
      thirteen block aggregates' covered-name lists, and the two 71-arm dispatchers.
- [ ] Update the module docstring's Main Results list to reflect any removed re-export names.

**Timing**: 2 hours

**Depends on**: 8

**Verification Tier**: interface

**Scope Hypothesis**: The ten generic-subsumed blocks are asserted to cover roughly 100 of the
file's named `openValidIn_*` theorems and roughly 1,370 of its 2,587 lines, read off the section
boundaries at `:708`–`:1525` and `:1561`–`:2114`. Confirm by measuring the before/after
`wc -l` and `grep -c "^theorem openValidIn_"` and reporting both in the handoff.

**Tier Justification**: `Conservativity/Open/OpenSoundness.lean` and
`Conservativity/Open/Forward.lean` consume the two dispatch lemmas, and the thirteen block
aggregates must still partition all 71 constructors — so
`lake build FormalSystem.Metalogic.Conservativity.Open` is the cheapest check covering every
consumer of the changed declarations.

**Files to modify**:
- `FormalSystem/Metalogic/Conservativity/Open/OpenAxiomValidity.lean` - subsumed block bodies
  become delegations; import added; docstring updated

**Verification**:
- `lake build FormalSystem.Metalogic.Conservativity.Open` green.
- The thirteen block aggregates' covered-name lists still union to all 71 `OpenAxiom`
  constructors, none twice and none missing — the invariant the file's own docstring asserts.
- `openAxiom_validIn_min` / `openAxiom_reflect_time_validIn_min` remain wildcard-free.

---

### Phase 11: L⁺ adoption, measured [NOT STARTED]

**Goal**: Make L⁺ a consumer of the generic layer where that is a genuine simplification, and
record honestly where it is not.

**Tasks**:
- [ ] Rewire the six S5/bridge `⊡` arms of `plusAxiom_validIn_min` and
      `plusAxiom_reflect_time_validIn_min` onto `generic_stab_k`, `generic_stab_t`,
      `generic_stab_4`, `generic_stab_5`, `generic_box_stab`, `generic_atom_stab`. For
      `atom_stab` this replaces the `stab_of_stateLocal` + `stateLocal_atom` route with the
      direct atom-clause argument; keep `PlusStateLocal.lean` intact, since the state-locality
      fragment has other consumers (confirm with
      `grep -rn "stab_of_stateLocal\|stateLocal_atom" FormalSystem/`).
- [ ] Do **not** replace the 45 TM-schema arms' atomization route. Those arms carry real
      provenance — each is the landed L-level schema transported through
      `Conservativity/Plus/Atomization.lean` under one fixed encoding — and are already one line
      apiece, so a generic rewrite would cost that provenance and recover no lines. Record this
      decision, with that reason, in the module docstring's "How the arms close" section.
- [ ] Add the `GenericSchemata` import.

**Timing**: 1 hour

**Depends on**: 8

**Verification Tier**: interface

**Tier Justification**: `Conservativity/Plus/PlusSoundness.lean`, `Corollaries.lean` and
`Forward.lean` all consume `plusAxiom_validIn_min`, so
`lake build FormalSystem.Metalogic.Conservativity.Plus` is the cheapest check that reaches every
consumer of the arms being rewired.

**Files to modify**:
- `FormalSystem/Metalogic/Conservativity/Plus/AxiomValidity.lean` - six `⊡` arms rewired; import
  added; docstring records the deliberate non-adoption of the TM arms

**Verification**:
- `lake build FormalSystem.Metalogic.Conservativity.Plus` green.
- `Conservativity/Plus/Atomization.lean` still compiles and still has consumers.
- Both dispatch lemmas remain wildcard-free with one arm per constructor.

---

### Phase 12: Documentation, inventories and the full gate sweep [NOT STARTED]

**Goal**: Bring every generated and hand-written record into line, and clear the whole CI gate
set.

**Tasks**:
- [ ] Regenerate the `<!-- BEGIN GENERATED: inventory -->` blocks for
      `FormalSystem/Metalogic/SoundnessLemmas/README.md`, `FormalSystem/Semantics/README.md`,
      `FormalSystem/Metalogic/Conservativity/Star/README.md` and
      `FormalSystem/Metalogic/Conservativity/Open/README.md`, and refresh each README's
      "Last verified" date.
- [ ] Update `docs/theorem-index.md` rows whose files changed size or whose proof route changed.
- [ ] Run `python3 scripts/reanchor-lean-citations.py --by-name --files <each changed .lean>`
      and read the diff; repair rather than baseline any C20 finding.
- [ ] Full gate sweep, each run and each result reported:
      `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build`;
      `bash scripts/check-evidence-probes.sh`;
      `bash scripts/check-module-invariants.sh --no-build`;
      `bash scripts/check-copyright-headers.sh --strict FormalSystem BimodalTools`;
      `bash scripts/readme-lint.sh FormalSystem BimodalTools`;
      `bash scripts/check-metalogic-cycles.sh`;
      `bash scripts/typst-sync-check.sh`;
      `bash scripts/check-paper-definitions.sh`;
      the `BimodalTest` test driver; and the warning budget
      (`python3 scripts/warning-budget.py`).
- [ ] Measure and report the actual net line delta across the three rewired files against the
      new module, replacing the plan's ~1,500-line hypothesis with a measured number.

**Timing**: 1.5 hours

**Depends on**: 9, 10, 11

**Verification Tier**: full

**Scope Hypothesis**: Four README inventory blocks and one `docs/theorem-index.md` are asserted
to need regeneration. Confirm by running `bash scripts/readme-lint.sh FormalSystem BimodalTools`
first and acting on what it reports, rather than on this list.

**Files to modify**:
- `FormalSystem/Metalogic/SoundnessLemmas/README.md` - inventory block, Last verified
- `FormalSystem/Semantics/README.md` - inventory block, Last verified
- `FormalSystem/Metalogic/Conservativity/Star/README.md` - inventory block, Last verified
- `FormalSystem/Metalogic/Conservativity/Open/README.md` - inventory block, Last verified
- `docs/theorem-index.md` - rows for the changed modules

**Verification**:
- Every gate above exits 0; any that does not is reported with its output verbatim, not
  summarised as "mostly passing".
- `scripts/c20-declaration-baseline.txt` has not grown.
- `scripts/nolints.json` is unmodified.
- No `sorry` anywhere in the changed files.

---

## Lean Challenge Statements

```lean
import FormalSystem.Semantics.TruthClauses

open FormalSystem.Semantics
open FormalSystem.Syntax

namespace FormalSystem.Semantics.TruthClauses

variable {L : Type} [TruthEnv L] [BotClause L] [ImpClause L] {F : TaskFrame}

section
variable [UntlClause L]

/-- `K⁺φ` at `t`: every point above `t` has a `φ`-point strictly between. -/
theorem kPlus_iff (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ : L) :
    TruthEnv.T M τ t e (kPlus φ) ↔
      ∀ s : F.Duration, t < s → ∃ r : F.Duration, t < r ∧ r < s ∧ TruthEnv.T M τ r e φ :=
  sorry

end

section
variable [SnceClause L]

/-- `K⁻φ` at `t`: the past mirror of `kPlus_iff`. -/
theorem kMinus_iff (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ : L) :
    TruthEnv.T M τ t e (kMinus φ) ↔
      ∀ s : F.Duration, s < t → ∃ r : F.Duration, s < r ∧ r < t ∧ TruthEnv.T M τ r e φ :=
  sorry

end

end FormalSystem.Semantics.TruthClauses

namespace FormalSystem.Metalogic.SoundnessLemmas

open FormalSystem.Semantics
open FormalSystem.Semantics.TruthClauses

variable {L : Type} [TruthEnv L] [BotClause L] [ImpClause L] {F : TaskFrame}

section
variable [AtomClause L] [StabClause L]

/-- AS, stated once: the atom clause reads the world state alone, which the `stab` clause
fixes. -/
theorem generic_atom_stab (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (p : Atom) :
    TruthEnv.T M τ t e
      (ImpClause.imp (AtomClause.atom p) (StabClause.stab (AtomClause.atom p))) :=
  sorry

end

section
variable [UntlClause L]

/-- The paper's CN, **right-associated** (`OpenAxiom.linear_until`'s nesting). -/
theorem generic_linear_until_paper (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ ψ χ θ : L) :
    TruthEnv.T M τ t e
      (ImpClause.imp (and (UntlClause.untl φ ψ) (UntlClause.untl χ θ))
        (or (UntlClause.untl (and φ χ) (and ψ θ))
          (or (UntlClause.untl (and φ χ) (and ψ χ))
            (UntlClause.untl (and φ χ) (and φ θ))))) :=
  sorry

/-- The paper's TL, in the disjunct order `OpenAxiom.temp_linearity` declares. -/
theorem generic_temp_linearity_paper (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ ψ : L) :
    TruthEnv.T M τ t e
      (ImpClause.imp (and (someFuture φ) (someFuture ψ))
        (or (someFuture (and (someFuture φ) ψ))
          (or (someFuture (and φ ψ))
            (someFuture (and φ (someFuture ψ)))))) :=
  sorry

end

section
variable [SnceClause L]

/-- BX7', **left-associated** (`OpenAxiom.linear_since`'s nesting). -/
theorem generic_linear_since (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ ψ χ θ : L) :
    TruthEnv.T M τ t e
      (ImpClause.imp (and (SnceClause.snce φ ψ) (SnceClause.snce χ θ))
        (or (or (SnceClause.snce (and φ χ) (and ψ θ))
              (SnceClause.snce (and φ χ) (and ψ χ)))
          (SnceClause.snce (and φ χ) (and φ θ)))) :=
  sorry

/-- BX11', in the disjunct order `OpenAxiom.temp_linearity_past` declares. -/
theorem generic_temp_linearity_past (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (e : TruthEnv.Env L F) (φ ψ : L) :
    TruthEnv.T M τ t e
      (ImpClause.imp (and (somePast φ) (somePast ψ))
        (or (somePast (and φ ψ))
          (or (somePast (and φ (somePast ψ)))
            (somePast (and (somePast φ) ψ))))) :=
  sorry

end

end FormalSystem.Metalogic.SoundnessLemmas
```

## Testing & Validation

- [ ] `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` — full project
      green.
- [ ] `BimodalTest` driver green, including the extended
      `Tests/BimodalTest/Semantics/ValidityLayerTest.lean` `rfl` bridge pins.
- [ ] `bash scripts/check-module-invariants.sh --no-build` — in particular C20 (no new
      declaration-span citation failures) and C6 (no newly unreachable module).
- [ ] `bash scripts/check-metalogic-cycles.sh` — still exactly one directory-level cycle in
      `Metalogic/`, and the upward-import allowlist unchanged at 8 lines.
- [ ] `bash scripts/readme-lint.sh FormalSystem BimodalTools` — every directory with `.lean`
      files has a README listing its files, with a current Last-verified date.
- [ ] `bash scripts/check-copyright-headers.sh --strict FormalSystem BimodalTools`.
- [ ] `bash scripts/check-evidence-probes.sh`, `bash scripts/typst-sync-check.sh`,
      `bash scripts/check-paper-definitions.sh`.
- [ ] `python3 scripts/warning-budget.py` within budget; `scripts/nolints.json` unmodified.
- [ ] `grep -rn "sorry" FormalSystem/Metalogic/SoundnessLemmas/GenericSchemata.lean` empty.
- [ ] Axiom-profile spot-check: `lean_verify` on `starAxiom_validIn_min`,
      `openAxiom_validIn_min` and `plusAxiom_validIn_min` shows no axiom gained relative to the
      profiles captured before Phase 9.

## Artifacts & Outputs

- `FormalSystem/Metalogic/SoundnessLemmas/GenericSchemata.lean` — the new generic schema layer
  (~55–60 pointwise lemmas plus an extension-contract docstring).
- Extended `FormalSystem/Semantics/TruthClauses.lean` (`AtomClause`, `kPlus`/`kMinus`,
  `kPlus_iff`/`kMinus_iff`).
- Seven `AtomClause` instances across the language modules.
- Rewired `Star/StarAxiomValidity.lean`, `Open/OpenAxiomValidity.lean`,
  `Plus/AxiomValidity.lean`.
- Extended `Tests/BimodalTest/Semantics/ValidityLayerTest.lean`.
- Refreshed READMEs and `docs/theorem-index.md`.
- A measured net line delta, reported in the final handoff, replacing the ~1,500-line
  hypothesis.

## Rollback/Contingency

Each phase commits independently, so the ordinary recovery is to stop at the last green commit
and report — the plan's later phases depend on the earlier ones but no earlier phase depends on
a later one, so a partial landing is coherent.

If a phase must be abandoned mid-edit with a dirty tree, take a **non-reverting** checkpoint
first (`bash .claude/scripts/git-snapshot.sh 881 --no-revert`), which preserves the work without
touching the working tree, then fix forward per `context/contracts/recovery.md`'s ladder. Only a
genuine rollback decision uses `git-snapshot.sh`'s default reverting mode, and only after that
decision is recorded.

Because three sibling tasks share this working tree this cycle (889, 860, and the
scope-undeclared 837), never use a directory or glob `git add`: stage this task's files by
explicit name only, and re-read each file immediately before editing it.

The cheapest full revert, if the whole approach is abandoned, is to delete
`FormalSystem/Metalogic/SoundnessLemmas/GenericSchemata.lean`, drop its import from the three
`*AxiomValidity.lean` files and the `SoundnessLemmas.lean` aggregator, and revert those files to
their pre-Phase-9 state; the Phase 1 clause-interface additions are purely additive and may be
kept regardless, since nothing in the tree is weakened by their presence.
