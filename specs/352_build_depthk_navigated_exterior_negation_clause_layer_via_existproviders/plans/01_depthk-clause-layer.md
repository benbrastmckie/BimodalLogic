# Implementation Plan: Depth-k Navigated Exterior Negation Clause Layer via ExistProviders

- **Task**: 352 - build_depthk_navigated_exterior_negation_clause_layer_via_existproviders
- **Status**: [IMPLEMENTING]
- **Effort**: 28 hours (~10 dispatch units across 6 phases; hard mode, per-sub-phase dispatch)
- **Dependencies**: task 349 (consumer of this task's interface; producer of the landed
  `ExteriorBracketK.lean` determinacy core, consumed unchanged); task 309 (downstream
  `ExistProviders` shape contract)
- **Research Inputs**:
  - specs/352_build_depthk_navigated_exterior_negation_clause_layer_via_existproviders/reports/01_team-research.md (synthesis, 5 teammates)
  - specs/352_.../reports/01_teammate-e-findings.md (Rabinovich paper->Lean construct map; Lemma 7.8 adjudication)
  - specs/349_build_recursive_endchar_navigated_arity3_endpoint_primitive/handoffs/v7-phase2-blocked-1783882788.json (four-element BLOCKER record)
  - specs/349_.../plans/07_enriched-bracket-carrier.md (Phase 2 block, lines 411-499)
  - specs/349_.../reports/10_q3-uniform-k-probe.md (adversarial section on the ExistProviders channel)
  - Rabinovich 2014, "A Proof of Kamp's Theorem" (~/Projects/Literature/sources/rabinovich_2014/, chunks 0021-0023 for Def 7.5/7.7, Lemma 7.8, Lemma 7.10; PDF pp. 7-11 for Lemma 5.1/5.3, Cor 5.4)
- **Artifacts**: plans/01_depthk-clause-layer.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-formats.md; lean4.md (literature
  fidelity, vacuous-def prohibition); state-management.md
- **Type**: lean4

## Overview

Task 349 v7 Phase 2 is design-level BLOCKED: its four depth-k exterior bracket lemmas
(`kvE_extBracketPast/Fut_sound/_complete`) are unprovable in the prescribed leaf module because
the frozen k=2 clause layer (`kvE2_futPos`/`kvE2_extNegFut` + `_sound`/`_complete`,
ExteriorNegation.lean:1124/1136/1243/1484, plus the Past mirrors
ExteriorNegationPast.lean:461/473/581/855) is depth-hardwired through `nf0_assemble`'s
coordinatization — lossless ONLY for depth-0 subs (NfEFold.lean:549-561), with
`σ : NormalForm sig 1 4` fixed. This task builds the faithful Rabinovich Def-7.5 rung-(k+1)
depth-k clause layer in NEW modules under `NfMultiAnchorBridge/`, parameterized by
`P : ExistProviders sig atomMap k` (PriorInterface.lean:38-46), so that 349 Phase 2's
re-dispatch can construct its brackets and close its four lemmas.

**Definition of done (interface-exposure criterion, verbatim from the task adjudication)**: the
depth-k clause layer (parameterized by `P : ExistProviders sig atomMap k`) is green + sorry-free
+ axiom-clean (`[propext, Classical.choice, Quot.sound]` exactly), and EXPOSES the interface
(bracket-buildable clause facts at depth k, not depth-0-hardwired) that task 349 Phase 2's
re-dispatch consumes to construct `kvE_extBracketPast`/`kvE_extBracketFut` and close their
`_sound`/`_complete` lemmas. This task does NOT close the four bracket lemmas themselves — that
is task 349 Phase 2's own re-dispatch work once this clause layer exists.

**Central design ruling (research Conflict 1, binding)**: the landed determinacy core
(`kvE_subBit`, `kvE_futAnyBit`, `kvE_projFreshD`) is marginal navigation/enumeration
scaffolding, NOT a content channel. The clause's truth-bearing content must be a finite
(Fintype-backed) disjunction of `P.existF 4` applied directly to each full fiber element
`s : NormalForm sig k 5` with `σ.2 s = true` — never a Boolean combination indexed by the
collapsed marginal profile `χ : NormalForm sig k 1`. Violating this reproduces the F2
counterexample (`f2_sub_proj_eq` pattern, RefutationF2.lean:471) one rung up and re-blocks the
task exactly as 349 Phase 2 blocked.

### Research Integration

Integrated: `reports/01_team-research.md` (v1, 2026-07-12) including the Teammate-E addendum.
The addendum resolves the Conflict-3 literature question (Lemma 7.8 consumes only rung-k TL
formulas across the rung boundary — resolution (a) holds, no depth-axis bracket recursion), so
the pre-build gate reduces to the Lean-side F2 separation probe (Phase 1).

### Preserved Assets

The following work is complete and must not regress (all sorry-free, axiom-clean, verified in
349's v7-phase2-blocked handoff):

| Component | File | Status | Verified |
|-----------|------|--------|----------|
| Determinacy core: `nfk_truncD`/`nfk_truncD_atom`/`nf_eval_truncD` | Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorBracketK.lean | [COMPLETED] | 2026-07-12 (commits 34a173e88, af794abcb, c4c5c7eb1) |
| `nf_eval_take` / `nf_eval_projFresh` (depth-general determinacy) | ExteriorBracketK.lean | [COMPLETED] | 2026-07-12 |
| `kvE_sepPos`/`kvE_projFreshD`/`kvE_futAnyBit` + `_correct` (depth-k zone-fact pin) | ExteriorBracketK.lean | [COMPLETED] | 2026-07-12 |
| `kvE_subBit` / `kvE_subBit_iff` (fiber-existential fold read) | ExteriorBracketK.lean | [COMPLETED] | 2026-07-12 |
| k=0-rung recovery layer (`kvE_projFreshD_zero`, `kvE_futAnyBit_zero`, recovery example) | ExteriorBracketK.lean | [COMPLETED] | 2026-07-12 |
| Phase-1 fold bridge `nf_eval_nfk_iff_efold` + `nf_eval_nf_atom_layer` rename | Kamp/NfEFold.lean | [COMPLETED] | 2026-07-12 |
| Frozen k=2 clause layer (proof template, read-only) | Kamp/ExteriorNegation.lean, Kamp/ExteriorNegationPast.lean | [FROZEN] | byte-identical at every commit |
| `ExistProviders` bundle + Prior interface | NfMultiAnchorBridge/PriorInterface.lean:38-46 | [FROZEN] | byte-identical at every commit |
| F2 counterexample machinery (all `private`) | NfMultiAnchorBridge/RefutationF2.lean | [COMPLETED] | untouched by this task |

### Source-to-Implementation Mapping (H3, Tier 1: Rabinovich 2014)

Condensed from teammate E's 5-column construct map (reports/01_teammate-e-findings.md:166-179),
which is the authoritative faithful-transcription reference for Phases 2-4. The frozen k=2
clause layer is cited per row as the byte-identical proof template.

| Rabinovich construct | Paper location | Target Lean (new modules) | k=2 proof template (frozen, read-only) | Notes |
|---|---|---|---|---|
| Def 7.5 rung-(k+1) bracket; entries are rung-k formulas | Def 3.1 (p.4), Notation 5.2 (p.8), Def 7.5 (chunk 0021:17) | `kvE_futPos` over `σ : NormalForm sig (k+1) 4`, entries = full-fiber `P.existF 4`-images | `kvE2_futPos` (ExteriorNegation.lean:1124-1132) | Entries are rung-k FORMULAS, never rung-k brackets — the E-verified resolution-(a) reading |
| Def 4.1/7.7 canonical expansion E[Σ,TL]; idempotent | chunk 0011:5, chunk 0022:5 | `P : ExistProviders sig atomMap k` consumed verbatim (`existF` + UZ/SZ-conditional `correct`) | PriorInterface.lean:38-46; consumer pattern KampPrior.lean:216-223/:351 | Boolean/Until closure of expansion atoms comes free from `Formula`; negated existF-images are legitimate atoms (idempotence) |
| Cor 5.4 `F_i` Until-fold: `F_n := α_n`, `F_{i-1} := α_{i-1} ∧ (β_i Until F_i)` | Cor 5.4 proof (p.9) | `kvE_futChain` (depth-k D-guarded Until chain; guard/profile formulas = fiber-level existF disjunctions) | `kvE2_futChain` (ExteriorNegation.lean:1108-1118) | The exact converter shape PriorInterface.lean:35-36 cites |
| Lemma 5.3 `O_n` obstruction; cases ∀¬P1 / K+ / INF+recurse | Lemma 5.3 (p.8, eq. 5.2) | list recursion inside chain + admissibility-gated permutations disjunction | `kvE2_futPos` permutations disjunction (:1128-1131) | Over discrete orders K+ ≡ False; case-3 inf becomes a minimum — landed min-pick convention is the faithful discrete specialization |
| `r_0 = inf{...}` / INF formula | Lemma 5.3 case 2, Lemma 5.1 case 3 (p.8/p.10) | minimal-witness selection over the finite chain family | `kvE2_futMinPick` (ExteriorNegation.lean:1146-1149, private, `{α : Type}`-generic — replicate, do not import) | Finitary min; needs linearity only |
| Lemma 5.1 = Lemma 7.8 negation closure; `A_i`/`B_i` length induction | pp. 9-11; chunk 0022:9-15; resource inventory chunk 0023:3-7 | `kvE_extNegFut := (kvE_futPos ...).neg` + `_sound`/`_complete`; proofs by list-length induction over chains | `kvE2_extNegFut` :1136, `_sound` :1243, `_complete` :1484; ChainBuild :1180 / ChainDestruct :1435 | `Formula.neg` is faithful-in-effect (TL is negation-closed; the paper needs positivity only for ∨∃∀-FOMLO). Length induction is INTRA-rung (E's sharpening) — Lean analog is the landed list recursion, no depth recursion |
| Cor 5.4(1)/(2) split: `¬F0(z0) ∨ O_n(F1..Fn)` | p.9 | the `_sound`/`_complete` direction split (sound = no chain ⟹ no strictly-exterior realizer; complete = realizer ⟹ chain) | `kvE2_extNegFut_sound`/`_complete` direction structure | This is exactly the shape 349 Phase 2 consumes |
| Lemma 7.10: exterior-zone `[...](z0, ∞)` bracket is plainly TL | chunk 0023:13-17 | exterior ray/end forms as plain `Formula` | `kvE2_futEnd`/`kvE2_futRayForm` (:1098/:1088) | Unbounded exterior zone is the easy zone |
| Past mirror of all of the above | symmetric (Since for Until) | `ExteriorNegationPastK.lean` mirrors | `kvE2_pastPos`/`kvE2_extNegPast` + `_sound`/`_complete` (ExteriorNegationPast.lean:461/473/581/855) | Structural mirror; parallelizable under H7 |
| Prop 3.5 one-free-variable ∨∃∀ -> TL (the provider source) | chunk 0010:11 (p.5) | NOT built here — supplied by `P` at use sites | `nf_succ_char_formula` KampPrior.lean:67/:81 (frozen) | Rule-N1 citation split already recorded in PriorInterface docstring |

## Postmortem Constraints

Binding rules for all implementation dispatches. Derived from the 349 v7 Phase-2 BLOCKER record,
the F2/task-327 refutations, and research report adversarial findings.

**Do NOT**:
1. Do NOT attempt a byte-identical leaf-module generalization of the frozen clause layer or of
   `nf0_assemble`'s coordinatization — provably impossible: `nf0_assemble` is lossless only for
   depth-0 subs (NfEFold.lean:549-561), and the F2 truncation-shadow counterexample
   (`f2_sub_proj_eq` pattern, RefutationF2.lean:471) falsifies `_complete` under a full-bit
   clause selector and `_sound` under a shadow-bit selector (349 BLOCKER elements (i)/(ii)).
2. Do NOT build any clause-content Boolean from marginal bits (guard G6): `kvE_subBit`,
   `kvE_futAnyBit`, `kvE_projFreshD` outputs are permitted ONLY for zone classification,
   admissibility bucketing, and chain-assembly order — never as the source of a
   content-bearing disjunct. Every content-bearing disjunct applies `P.existF` directly to a
   full fiber element.
3. Do NOT index any content disjunction by the collapsed marginal profile
   `χ : NormalForm sig k 1` (teammate B's original `nf_succ_char_formula ... (P.existF 1) χ`
   substitution — overturned by research Conflict 1). Content is indexed by full fiber
   elements `s : NormalForm sig k 5` with `σ.2 s = true`, rendered via `P.existF 4`.
4. Do NOT build a truncation-shadow bracket (frozen clauses evaluated over `nfk_truncD`
   shadows) — architecture A3, independently proven dead by teammates B and C and by the 349
   BLOCKER record.
5. Do NOT edit the 7 frozen providers (SharedWitness.lean, SubBracket2V.lean, OuterGate.lean,
   ExteriorBracket.lean, ExteriorZoneTriage.lean, ExteriorNegation.lean,
   ExteriorNegationPast.lean), KampPrior.lean, or `nf_nvar_exist_all_depths`'s signature.
   `git diff` on all of these must be EMPTY at every commit — verify before each commit.
6. Do NOT rebuild or edit the landed `ExteriorBracketK.lean` determinacy core — consume it
   unchanged. Prefer new modules; edit ExteriorBracketK.lean only additively and only if
   genuinely required by the new interface.
7. Do NOT land a `sorry`, a vacuous/placeholder definition (`def X := True` and variants), or
   a new axiom. If a sub-piece cannot close green, mark the phase [BLOCKED] with the exact
   `lean_goal` state and escalate (`/spawn 352`) instead.
8. Do NOT shortcut a Rabinovich chain step with `simp`/`omega`/`aesop` (guard G5) — manual
   bridges only; follow the paper step-by-step per literature-fidelity policy.
9. Do NOT use `nf_char3_deeper_split` (FORBIDDEN, carried from 349).
10. Do NOT attempt to close the four 349 bracket lemmas
    (`kvE_extBracketPast/Fut_sound/_complete`) in this task — that is 349 Phase 2's
    re-dispatch scope. Building them here is scope creep, not initiative.
11. Do NOT define a bespoke provider bundle — consume the canonical
    `ExistProviders sig atomMap k` record (PriorInterface.lean:38-46) verbatim, or task 309's
    `Nat.rec`-supplied instance will not fit (teammate D's cross-task constraint).
12. Do NOT proceed past Phase 1 if the F2 separation probe fails — the corrected full-fiber
    construction failing to separate `f2qnf`-style pairs falsifies the plan's central design
    ruling; STOP, mark [BLOCKED], and escalate before any Phase 2+ lines are written.

**MUST preserve**:
- Everything in the Preserved Assets table (determinacy core, fold bridge, frozen files).
- The existing whole-tree green build: `lake build` must pass at every phase boundary.
- Axiom inventory: exactly `[propext, Classical.choice, Quot.sound]` on every new headline decl.

**Design decisions are SETTLED** (do not re-open without a concrete counterexample):
- **Resolution (a)** — standalone leaf module(s) parameterized by
  `P : ExistProviders sig atomMap k` — over (b) (mutual recursion with `endIntervalStep`) and
  (c) (weakened statements). Grounds: teammate E's direct-proof reading of Lemma 7.8 (negation
  closure consumes only previous-round TL formulas across the rung boundary; the Lemma 5.1
  Case-3 recursion is intra-rung length induction, not depth recursion) + teammate D's acyclic
  import-DAG finding + PriorInterface.lean:25 (`∀k` fixpoint lives in KampPrior's `Nat.rec`).
- **Content channel = `P.existF 4` over full fiber elements** `NormalForm sig k 5` (research
  Q2 resolved). Marginal machinery is navigation-only (G6).
- **The Lemma-7.8 adversarial literature re-read is DONE** (teammate E addendum). The only
  remaining pre-build gate item is the Lean F2 probe (Phase 1).
- **`Formula.neg` negation closure is faithful-in-effect** — TL formulas are negation-closed;
  the paper's positive-form reconstruction exists only because ∨∃∀-FOMLO is negation-hostile
  (Def 7.7 idempotence). Do not re-derive positive forms.
- **k=0 rung recovery is the agreement criterion** with the frozen layer (research Q6): the
  new layer at k=0 (`σ : NormalForm sig 1 4`) must agree with the frozen `kvE2_*` decls at the
  formula/statement level, mirroring the landed `kvE_futAnyBit_zero` pattern.

## Constraints (verbatim from parent task 349 adjudication)

- CONSUME UNCHANGED the already-landed green Phase-2 determinacy core in ExteriorBracketK.lean
  (nfk_truncD/nf_eval_truncD, nf_eval_take/nf_eval_projFresh, kvE_futAnyBit(_correct),
  kvE_subBit(_iff)) — do not rebuild it, do not edit that file except additively if genuinely
  required by the new interface (prefer a new module).
- Binding guards carried from 349: G1 no arity-1 collapse; G2/G4 anchors subset of {x,t}, at
  most 2, w never a third anchor; G3 non-trivial segment (reuse seg, never TemporalPred.top);
  G5 manual Rabinovich bridges only (no simp/omega/aesop shortcut of a chain step).
- New guard G6 (research, endorsed verbatim): no clause-content position may render a formula
  from a projected/marginal profile (any `kvE_subBit`/`kvE_futAnyBit`/`kvE_projFreshD` output
  used as a Boolean truth-value standing in for a sub's semantic realization). Every
  content-bearing disjunct must apply `P.existF` directly to a full fiber element. Marginal
  reads are permitted only for zone classification, admissibility bucketing, and
  chain-assembly order.
- FORBIDDEN: nf_char3_deeper_split.
- Do NOT edit the 7 frozen providers (SharedWitness.lean, SubBracket2V.lean, OuterGate.lean,
  ExteriorBracket.lean, ExteriorZoneTriage.lean, ExteriorNegation.lean,
  ExteriorNegationPast.lean), KampPrior.lean, or nf_nvar_exist_all_depths's signature. Build
  the new depth-k clause layer in NEW module(s) under NfMultiAnchorBridge/, referencing the
  frozen k=2 clause layer only as a byte-identical proof template (git diff on all 7 frozen
  providers must stay EMPTY at every commit).
- sorry-free; axioms exactly [propext, Classical.choice, Quot.sound]. No vacuous/placeholder
  definitions — if a sub-piece cannot close green, mark BLOCKED and escalate rather than
  landing a sorry or vacuous def.
- task_type = lean4; effort = high; topic = kamp_theorem_formalization.
- Definition of done: the depth-k clause layer (parameterized by P : ExistProviders sig
  atomMap k) is green + sorry-free + axiom-clean, and EXPOSES the interface
  (bracket-buildable clause facts at depth k, not depth-0-hardwired) that task 349 Phase 2's
  re-dispatch consumes to construct kvE_extBracketPast/Fut and close their _sound/_complete
  lemmas. Do NOT close the four bracket lemmas themselves in this task.

## Goals & Non-Goals

- **Goals**:
  - Land the F2-safe full-fiber content channel (`P.existF 4`-disjunction over positive fiber
    elements) with a machine-checked separation proof against the F2 counterexample pattern.
  - Land depth-k Future and Past clause layers (`kvE_futPos`/`kvE_extNegFut` +
    `_sound`/`_complete`, and Past mirrors) in new modules, parameterized by the canonical
    `ExistProviders` bundle, faithful to Rabinovich Def 7.5 / Cor 5.4 / Lemma 5.1-5.3 / 7.8 / 7.10
    per the Source-to-Implementation Mapping.
  - Expose the packaged clause-fact interface (full-fiber `hbelow`-pin shape, per-side
    positive/negative clause facts) that 349 Phase 2's re-dispatch consumes.
  - k=0 rung recovery: agreement of the new layer with the frozen `kvE2_*` layer at k=0.
- **Non-Goals**:
  - Closing `kvE_extBracketPast/Fut_sound/_complete` (349 Phase 2's re-dispatch).
  - Any edit to the 7 frozen providers, KampPrior.lean, or `nf_nvar_exist_all_depths`.
  - Rebuilding the R2 spike section of the frozen layer (ExteriorNegation.lean:221-873) unless
    a decl in it is on the dependency cone of `kvE2_futPos`/`kvE2_extNegFut(_sound/_complete)`
    (verify by usage grep in Phase 3.1 before generalizing anything from it).
  - `endIntervalStep` / recursion-side work (349 Phases 3-6), task 309 naming-drift fixes.

## Risks & Mitigations

- **Risk (Critical, Medium-High likelihood)**: clause content accidentally built over marginal
  bits — the "natural, tempting move" since those bits are green and landed. **Mitigation**:
  guard G6 as a per-phase grep/review obligation; Phase 1 probe validates the corrected
  construction before any clause-layer lines exist; postmortem rules 2-3.
- **Risk (Critical, Low)**: `existF`-converters insufficient for negation closure despite
  teammate E's verdict (residual resolution-(b) risk). **Mitigation**: Phase 1 is a hard
  GO/NO-GO gate; if the probe cannot separate the F2 pair, STOP and escalate (postmortem
  rule 12) — cost is ~300 lines, not ~2500.
- **Risk (Medium, Medium)**: line-count overrun beyond ~3100 if the full-fiber fold needs a
  materially new combinator with its own soundness/completeness obligations. **Mitigation**:
  the fold combinator is Phase 1's deliverable with its own correctness lemma; per-side phases
  are pre-split by proof direction (H8), so overrun surfaces as an extra bounded sub-phase,
  not churn.
- **Risk (High, Low)**: bespoke provider bundle breaking 309's `Nat.rec` consumption chain.
  **Mitigation**: postmortem rule 11; Phase 5 includes an explicit interface audit against
  PriorInterface.lean:38-46.
- **Risk (Medium, Low-Medium)**: `h_UZ`/`h_SZ` fail to propagate to every char-correctness
  site, forcing new hypotheses into `_sound`/`_complete` beyond the `P` parameter (research
  Q3). **Mitigation**: `P.correct` already carries UZ/SZ conditionality; verify propagation
  during Phase 3.1 and record the final hypothesis shape in Phase 5's interface exposition.
- **Risk (Medium, Low)**: a depth-0 hardwiring re-enters via `nf0_zoneSpec` reads on the quant
  layer (research Q4). **Mitigation**: Phase 2 checklist item — confirm every `nf0_zoneSpec`
  use reads `σ.1` (atom layer) only, mirroring the D7 discipline in ExteriorBracketK.
- **Risk (Low)**: `private` frozen decls (e.g. `kvE2_futMinPick`) cannot be imported.
  **Mitigation**: replicate as new decls in the new modules (they are proof templates, not
  imports); never un-`private` a frozen file.

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 (1.1 then 1.2; GO/NO-GO gate) | -- |
| 2 | 2 | 1 (GO verdict required) |
| 3 | 3.1, 4.1 | 2 |
| 4 | 3.2, 4.2 | 3.1 / 4.1 respectively |
| 5 | 3.3, 4.3 | 3.2 / 4.2 respectively |
| 6 | 5 | 3, 4 (both sides complete) |
| 7 | 6 | 5 |

Phases within the same wave can execute in parallel. Waves 3-5 run the Future side (Phase 3.x,
file `ExteriorNegationK.lean`) and the Past side (Phase 4.x, file `ExteriorNegationPastK.lean`)
in parallel under an H7 territory contract: each side owns exactly its own file; the shared
file `ExteriorFiberK.lean` is FROZEN for both sides after Phase 2 (any needed shared addition
is escalated to the orchestrator, never edited concurrently). Within a side, sub-phases are
strictly sequential.

`plan_metadata`: `{"phases": 6, "total_effort_hours": 28, "complexity": "complex",
"research_integrated": true, "plan_version": 1, "dependency_waves": [[1],[2],[3,4],[5],[6]],
"skeleton": false, "follow_up_tasks": []}`

### Phase 1: Full-fiber content channel core + F2 separation probe (GO/NO-GO gate) [COMPLETED]

- **Goal:** Land the F2-safe content channel — the `P.existF`-over-full-fiber disjunction
  combinator with its correctness lemma — and machine-check that it separates the F2
  counterexample pattern that kills every marginal construction. This is the research report's
  mandated pre-build verification gate (Conflict 3, Lean side; the literature side is already
  DONE per teammate E).
- **Sub-phase 1.1 — channel core** (`ExteriorFiberK.lean`, NEW):
  - [x] `kvE_fiber` : the positive-sub fiber of `σ : NormalForm sig (k+1) 4` as a finite
        enumeration of `{s : NormalForm sig k 5 // σ.2 s = true}` (Fintype-backed list, stable
        order; mirror the list conventions of `kvE2_futGapList`, ExteriorNegation.lean:890).
        *(landed with membership unfold `kvE_fiber_mem`)*
  - [x] `kvE_fiberPos` : `Formula` — finite disjunction of `P.existF 4 s` over the fiber
        elements (content position; G6-compliant by construction). Cite Def 7.5 entries +
        Def 7.7 canonical expansion per the mapping table.
  - [x] `kvE_fiberPos_correct` : UZ/SZ-conditional truth characterization via `P.correct 4` —
        `temporal_truth M atomMap t (kvE_fiberPos ...) ↔ ∃ s, σ.2 s = true ∧ ∃ env, nf_eval_nf
        M k 5 (insertEnv env t) s` (exact statement shape fixed by implementer against
        `P.correct`'s shape, PriorInterface.lean:41-45). *(verified: axioms exactly
        `[propext, Classical.choice, Quot.sound]`)*
  - [x] Bucketed variant `kvE_fiberPosOn` (disjunction restricted to a sub-list of the fiber)
        + its correctness lemma — the form the per-zone clause disjuncts will consume.
        *(correctness `kvE_fiberPosOn_correct` proved for ARBITRARY sub-lists — strictly more
        general than fiber-sub-lists, no deviation in consumer shape)*
- **Sub-phase 1.2 — F2 separation probe** (`ExteriorFiberProbeK.lean`, NEW; probe-local):
  - [x] Reconstruct the F2-style pair probe-locally (all `private`): RefutationF2.lean's
        machinery (`f2sig`:92, `F2M`:104, `f2env3`:328, `f2qnf`:332, `f2sub1/2`:335/339,
        `f2qnf'`:343) is entirely `private` — replicate the pair construction as a template
        copy; do NOT edit RefutationF2.lean. *(landed as `p2*` template copies incl. the
        Prior facts `p2_UZ`/`p2_SZ` and the e*-entry lemmas; RefutationF2.lean untouched)*
  - [x] Prove the separation theorem: under a concrete provider instance for the probe
        signature, the corrected full-fiber construction (`kvE_fiberPos`, or the syntactic
        fiber-set fact it induces) assigns the pair members DIFFERENT values — i.e. exactly
        the separating power `f2_carrier_eq` (RefutationF2.lean:582) proves the
        marginal/frozen construction lacks. *(landed THREE separations: semantic
        `kvE_fiberPos_separates_F2` under concrete depth-0 provider `p2P`
        (`nf_nvar_exist_depth0_tl_fn`, sorry-free) — e*-bucket TRUE at t=18 for sub₁, FALSE
        for sub₂; syntactic `kvE_fiber_separates_pair` (with marginal-channel agreement
        `p2_zone_agree`/`p2_projFreshD_agree`); syntactic `kvE_sepPos_separates_qnf_pair`
        at the exact f2_carrier_eq pair shape (qnf vs qnf'))*
  - [x] Record the GO/NO-GO verdict in the phase-completion commit message and the progress
        file. NO-GO ⟹ postmortem rule 12: [BLOCKED] + escalate, no further phases.
        *(VERDICT: GO — all three separation theorems green, axioms exactly
        `[propext, Classical.choice, Quot.sound]`)*
- **Estimated output:** ~450-750 lines total (1.1: ~300-450; 1.2: ~150-300).
- **Bounded-unit stop condition:** 1.1 = `kvE_fiberPos_correct` green OR [BLOCKED] with exact
  `lean_goal`; 1.2 = separation theorem green (GO) OR a machine-checked failure/irreducible
  goal (NO-GO ⟹ [BLOCKED] + `/spawn 352`). One dispatch per sub-phase; no open-ended retries.
- **Timing:** ~5 hours (2 dispatches).
- **Depends on:** none.
- **Done when:** both new files compile (`lake build
  Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorFiberK` + probe module)
  green, sorry-free; correctness + separation theorems verified; frozen diffs EMPTY; commit
  per green sub-step.
- **Files:** `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorFiberK.lean`
  (NEW; imports PriorInterface + ExteriorBracketK + NfEFold),
  `.../NfMultiAnchorBridge/ExteriorFiberProbeK.lean` (NEW; imports ExteriorFiberK; probe-local
  reconstruction, no RefutationF2 edit).

### Phase 2: Shared navigation and fiber-partition layer [COMPLETED]

- **Goal:** Land the side-shared navigation scaffolding both clause layers consume: fiber
  partition by zone/fresh-profile (marginal keys, navigation-only per G6) with honesty lemmas
  tying bucket membership to the landed determinacy core, plus the generic order/min-pick
  combinator. After this phase `ExteriorFiberK.lean` is FROZEN for waves 3-5.
- **Tasks:**
  - [x] Fiber partition: bucket `kvE_fiber` elements by zone classification and fresh profile
        (`nfk_projFresh`-keyed, navigation-only), producing per-bucket sub-lists consumed by
        `kvE_fiberPosOn`. Honesty lemma per bucket via `kvE_subBit_iff`
        (ExteriorBracketK.lean:314) — membership/navigation facts only, never content.
        *(landed `kvE_fiberBucket` + `_mem` + `_nodup` + honesty `kvE_fiberBucket_nonempty_iff`
        (bucket nonempty ↔ actual zone/profile fact, reduced to `kvE_subBit_iff` via
        `kvE_fiber_dropFresh`); G6 clean — no content read)*
  - [x] Chain-assembly ordering helpers: the D-guard/order data the Until/Since chain
        assembly needs, generalized from the frozen list-filter shape (`kvE2_futGapList`/
        `kvE2_futRayList` :890/:895 as template — element source swapped from marginal-profile
        universe to fiber buckets). *(landed side-generic `kvE_fiberZoneList` + `_mem` +
        `_nodup`; each side instantiates its own gap/ray/self zone specs in Phase 3/4)*
  - [x] Replicate the `{α : Type}`-generic min-pick lemma (template: `kvE2_futMinPick`,
        ExteriorNegation.lean:1146-1149, private) as a shared decl (Lemma 5.3 case-2 discrete
        specialization per the mapping table). *(landed `kvE_minPick`, byte-identical replica,
        non-private shared decl)*
  - [x] Q4 check: confirm every `nf0_zoneSpec` read in the new code path is on `σ.1` (atom
        layer) only; record the check in the progress file. *(CONFIRMED: every zone read in the
        Phase-2 code is `nfk_zoneSpec s` on a fiber element `s : NormalForm sig k 5`, which is
        defined as `nf0_zoneSpec s.atom_assgn` (NfEFold.lean:586-588) — atom-layer only. No
        `nf0_zoneSpec` is applied to any quant layer; the only textual `nf0_zoneSpec`
        occurrence is in the section docstring.)*
- **Estimated output:** ~250-400 lines (additive tail of ExteriorFiberK.lean).
- **Bounded-unit stop condition:** all listed decls green OR [BLOCKED] + `lean_goal` on the
  specific decl. One dispatch.
- **Timing:** ~3 hours.
- **Depends on:** 1 (GO verdict).
- **Done when:** scoped `lake build` green, sorry-free; bucket honesty lemmas verified; Q4
  check recorded; frozen diffs EMPTY; commit.
- **Files:** `ExteriorFiberK.lean` (additive tail only).

### Phase 3: Future-side clause layer (`ExteriorNegationK.lean`) [BLOCKED]

**BLOCKER** (Phase 3.2/3.3 — `kvE_extNegFut_sound`/`_complete`):
- **What failed**: Wiring the corrected full-fiber content channel (`kvE_fiberPosOn P` →
  `P.existF 4 s`) into the depth-`k` chain's INTERIOR gap-point positions. After
  `rw [P.correct 4 s M h_UZ h_SZ r]` the obligation is
  `⊢ ∃ env, nf_eval_nf M k (4+1) (insertEnv env r) s` while a realizer supplies
  `hs : nf_eval_nf M k 5 (Fin.cons r (Fin.cons x1 (Fin.cons w (Fin.cons x fun _ ↦ t)))) s`
  (empirically captured via `lean_goal`, 2026-07-12).
- **Root cause (four-element)**: (i) counterexample/mismatch — `P.existF`'s correctness
  (`PriorInterface.lean:41-45`) evaluates a sub's *last* variable (index 4, `insertEnv env t`)
  at the eval point, but σ's fold quant layer (`nf_eval_efold_k`, `NfEFold.lean:608-613`)
  binds the quantified/fresh variable at *index 0* (`Fin.cons x env`). For the FUTURE clause
  evaluated at the right anchor `t` the two coincide (index 4 = `t`), but the chain's interior
  gap points `r` need the gap variable rendered at `r` = index 4, whereas σ realizes those subs
  with the gap point at index 0 and `t` at index 4 — `insertEnv env r = Fin.cons r [x1,w,x,t]`
  forces `r = t`, false for a gap point. (ii) current behavior — no `NormalForm` variable
  reindexing/relabel operation with semantic transport
  (`nf_eval M k 5 env (relabel s) ↔ nf_eval M k 5 (env ∘ perm) s`) exists in the active tree
  (only Boneyard has cross-*model* `∘ skipIdx` transport, a different purpose; grep 2026-07-12).
  (iii) required behavior — either such a reindex bridge (index-0 ↔ index-last permutation), or
  a provider evaluating at index 0, or a re-architected clause that anchors ALL content at the
  fixed `t` (index 4) and orders interior points by marginal navigation only. (iv) isolation —
  the reindex/relabel bridge is SHARED (the Past side, Phase 4.2/4.3, needs the mirror), so per
  H7 it belongs in the FROZEN `ExteriorFiberK.lean` (or `PriorInterface.lean` convention), NOT
  a concurrently-edited side file — hence orchestrator escalation, not in-side construction.
- **What was tried**: full-fiber content defs landed and green (`kvE_futGapD`/`RayD`/`RayForm`/
  `End`/`Chain`/`Pos`/`extNegFut`); the model-side chain device generalized and green
  (`kvE_futChainG`/`BuildG`/`DestructG`, with the distinctness invariant `huniq` abstracted so
  it is NOT the obstruction). The obstruction is strictly the content-channel↔fold variable-slot
  reconciliation above.
- **What is needed**: orchestrator decision + a spawned dependency — add a `NormalForm`
  index-permutation relabel + semantic-transport lemma to the shared FROZEN `ExteriorFiberK.lean`
  (unfreeze for a controlled shared addition, or `/spawn 352`), OR re-scope the clause
  architecture to anchor content at the fixed right anchor. Then re-dispatch 3.2/3.3.
- **Prohibited**: no `sorry`, no `def X := True`, no vacuous placeholder was landed (verified
  `sorry_count = 0`, `lake build` green).

- **Goal:** The depth-k Future clause layer over `P`, faithful to Cor 5.4 / Lemma 5.3 / Lemma
  7.8 per the mapping table, template = ExteriorNegation.lean's non-spike core (:875-1735).
  Before generalizing ANY decl, grep the frozen file to confirm it is on the dependency cone
  of `kvE2_futPos`/`kvE2_extNegFut(_sound/_complete)`; the R2 spike section (:221-873) is
  out of scope unless on that cone.
- **Sub-phase 3.1 — definitions + navigation lemmas** (~200-350 lines):
  - [x] Depth-k analogs of the zone/admissibility layer on the cone: `kvE_futPossibleZones`,
        `kvE_futZoneClass`, `kvE_futAdmissible`, `kvE_futFreshProfile`,
        `kvE_futRealizer_admissible` (templates :902/:915/:983/:996/:1010) — navigation reads
        via Phase-2 buckets + landed core only (G6). *(green, commit c738b9236; deviation —
        admissibility conjunct 4 "self-zone carves exactly the fresh profile" reformulated as
        self-zone profile UNIQUENESS at depth k, because `σ.1` is the depth-0 atom layer so the
        endpoint profile is fiber-borne `nfk_projFresh s : NormalForm sig k 1`, not a `σ.1`
        marginal — see Q3 note below and phase-3-1 handoff)*
  - [x] Clause-form defs: `kvE_futGapD`, `kvE_futRayD`, `kvE_futRayForm`, `kvE_futEnd`,
        `kvE_futChain`, `kvE_futPos`, `kvE_extNegFut := (kvE_futPos ...).neg` (templates
        :1072/:1079/:1088/:1098/:1108/:1124/:1136), parameterized
        `{atomMap} (P : ExistProviders sig atomMap k) (σ : NormalForm sig (k+1) 4)`,
        content positions rendered via `kvE_fiberPosOn` (never marginal χ — postmortem rule 3).
        *(GREEN, commit 782d8764c; `h_surj` dropped — unused since content is `P.existF`, not
        `nf_depth0_char_formula`; visited universe = Phase-2 `kvE_fiberZoneList σ zs4`; the
        model-side chain device generalized to `kvE_futChainG`/`BuildG`/`DestructG` — GREEN,
        commit d27eed7a6 — with the distinctness invariant `huniq` abstracted)*
  - [x] Record the propagated hypothesis shape (Q3): whether `_sound`/`_complete` statements
        need `h_UZ`/`h_SZ` beyond `P` (expected: yes, mirroring `P.correct`). *(partial — Q3
        finding for the zone/admissibility layer: `kvE_futRealizer_admissible` needs NO `h_UZ`/
        `h_SZ` (order-bits only, like frozen `kvE2_futRealizer_admissible`); `kvE_futFreshProfile`
        needs only the atom-layer realization `hatomσ`. `h_UZ`/`h_SZ` will enter at the CONTENT
        layer (3.2/3.3) via `kvE_fiberPosOn_correct` / `P.correct`, as expected. Also: at depth k
        `nf0_assemble` is unavailable (postmortem rule 1), so admissibility reads the fiber via
        `kvE_subBit`; the endpoint fresh profile is fiber-borne (`nfk_projFresh s`), so the
        self-zone conjunct became a uniqueness pin — see phase-3-1 handoff.)*
  - [ ] Clause-form defs (`kvE_futGapD`/`RayD`/`RayForm`/`End`/`Chain`/`Pos`/`extNegFut`) —
        deferred to a follow-up 3.1 dispatch (or folded into 3.2); NOT in the zone/admissibility
        sub-dispatch scope.
- **Sub-phase 3.2 — `kvE_extNegFut_sound`** (~200-300 lines):
  - [x] Chain-destruct helper (template: ChainDestruct region :1435) by intra-rung list-length
        induction. *(landed as generic `kvE_futChainDestructG`, GREEN, commit d27eed7a6)*
  - [ ] `kvE_extNegFut_sound` mirroring :1243's statement shape one fold-layer deeper
        *(deviation: BLOCKED — see the Phase-3 BLOCKER record: content-channel↔fold variable-slot
        reconciliation is missing shared infra; no sorry/vacuous landed)*
- **Sub-phase 3.3 — `kvE_extNegFut_complete`** (~200-300 lines):
  - [x] Chain-build helper (template: ChainBuild region :1180) + min-pick application.
        *(landed as generic `kvE_futChainBuildG`, GREEN, commit d27eed7a6)*
  - [ ] `kvE_extNegFut_complete` mirroring :1484, with the `hbelow`-analog full-fiber pin
        *(deviation: BLOCKED — same content-channel↔fold reconciliation blocker; the full-fiber
        pin `_complete` would consume also requires the reindex bridge; no sorry/vacuous landed)*
- **Estimated output:** ~600-950 lines total across 3 dispatches.
- **Bounded-unit stop condition (each sub-phase):** its named decls green OR [BLOCKED] +
  exact `lean_goal` on the failing decl; commit each green sub-phase before proceeding. If
  3.2 closes and 3.3 blocks, commit 3.2 and block only 3.3.
- **Timing:** ~8 hours (3 dispatches).
- **Depends on:** 2 (3.2 depends on 3.1; 3.3 depends on 3.2). Parallel with Phase 4 (H7:
  owns `ExteriorNegationK.lean` exclusively; must not touch `ExteriorNegationPastK.lean` or
  `ExteriorFiberK.lean`).
- **Done when:** `kvE_futPos`/`kvE_extNegFut` + `_sound`/`_complete` green, sorry-free,
  axiom-clean; scoped `lake build` green; frozen diffs EMPTY; G6 review clean.
- **Files:** `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorNegationK.lean`
  (NEW; imports ExteriorFiberK; frozen ExteriorNegation.lean is a read-only template, NOT
  imported unless Phase 5 recovery requires it there — default is recovery in Phase 5's file).

### Phase 4: Past-side clause layer (`ExteriorNegationPastK.lean`) [IN PROGRESS]

*(re-dispatch 2026-07-12: unblocked by the shared reindex bridge `kvE_fiberPosOnShift`/
`kvE_anchorBridge` now landed in `ExteriorFiberK.lean`; content routed through the shift.)*

- **Goal:** Structural Past mirror of Phase 3 (Since for Until), template =
  ExteriorNegationPast.lean:223-1109.
- **Sub-phase 4.1 — definitions + navigation lemmas** (~200-300 lines): Past analogs
  `kvE_pastPossibleZones`/`ZoneClass`/`Admissible`/`Realizer_admissible` (templates
  :250/:264/:332/:348) and clause-form defs `kvE_pastGapD`/`RayD`/`RayForm`/`End`/`Chain`/
  `kvE_pastPos`/`kvE_extNegPast` (templates :410-:473), same `P`-parameterization and
  full-fiber content discipline as 3.1. *(deviation: zone/admissibility sub-layer COMPLETED
  [commit phase-4.1]; clause-form defs DEFERRED to 4.2 with 3.1, then BLOCKED — see BLOCKER.)*
- **Sub-phase 4.2 — `kvE_extNegPast_sound`** (~200-300 lines): template :581. *(BLOCKED — see
  BLOCKER; chain-assembly navigation prep landed: `kvE_pastGapZone`/`RayZone`/`SelfZone` +
  possible-zones membership + descending `kvE_pastMaxPick`, commit 79edf5320, green.)*
- **Sub-phase 4.3 — `kvE_extNegPast_complete`** (~200-300 lines): template :855; full-fiber
  pin shape for the `hbelow`-analog. *(BLOCKED — depends on the 4.2 pin resolution below.)*

**BLOCKER** (Phase 4.2/4.3 — content-bearing clause layer; navigation prep is green):
- **What failed:** The clause-form defs `kvE_pastGapD/RayD/RayForm/End/Chain/Pos` and their
  `_sound`/`_complete` cannot be faithfully written to be provable, because the depth-`k`
  full-fiber content channel and the fixed-environment realizer use INCOMPATIBLE anchor
  conventions with no landed bridge between them.
- **What was tried / traced (source-grounded, two landed lemma statements):**
  1. `kvE_fiberPos_correct` / `kvE_fiberPosOn_correct` (`ExteriorFiberK.lean:91-130`): the only
     G6-permitted content rendering `kvE_fiberPosOn P l` evaluated at a point `p` unfolds to
     `∃ env : Fin 4 → M.carrier, nf_eval_nf M k 5 (insertEnv env p) s` — the four non-anchor
     points are EXISTENTIALLY FREE, and `insertEnv env p` puts `p` at the LAST anchor (index 4,
     `NfDepth0Generalized.lean:42`).
  2. `nf_eval_nfk_iff_efold` (`NfEFold.lean:627`, `nf_eval_efold_k` :608): σ's realizer pins each
     positive fiber element `s` over the FIXED environment `Fin.cons v (Fin.cons x1 (Fin.cons w
     (Fin.cons x (fun _ => t))))` — the fresh witness `v` at index 0, `[x1,w,x,t]` at indices 1-4.
  3. Reconciliation attempt: `insertEnv [v,x1,w,x] t = Fin.cons v [x1,w,x,t]` holds
     definitionally, so content anchors at `t` with `env[0]=v` (the gap/ray/self witness). BUT
     `env` is existentially free, so `P.existF 4 s` at `t` asserts only "s is realizable at `t`
     with SOME 4 points", NOT "with the actual `[x1,w,x]`". The frozen k=2 layer pins this free
     env via `qnf`/`hbase`/`hbits`/`habove` (`ExteriorNegationPast.lean:855-872`); the depth-`k`
     analog is the deferred "full-fiber pin" whose exact shape is unresolved (research ruling —
     plan Phase 3.3/4.3 note: `kvE_futAnyBit_correct` is "necessary-but-not-sufficient
     scaffolding, not the hypothesis itself"; 4.1 handoff lines 108-111).
  4. Grep for any re-anchoring / anchor-permutation NormalForm operation: none exists.
- **Why stuck:** The frozen Since-chain evaluates each step's content AT the walked-to gap point
  (`nf_depth0_char_formula χ` pins that point's marginal profile, `ExteriorNegationPast.lean:454`).
  At depth `k` the F2 obstruction (postmortem rules 1-3, G6) forbids marginal content, and the
  only full-fiber channel (`P.existF`) anchors at `t` with a free env — it cannot express "this
  gap point realizes sub `s`". So the chain's evaluate-at-walked-point mechanism does not
  transfer; a different clause architecture (content-at-`t` + zone-navigated env pin) is required.
  This is a genuine SEMANTIC DESIGN question, not a tactic failure.
- **What is needed (concrete action to unblock):** Resolve the full-fiber env-pin shape for the
  depth-`k` clause layer — the depth-`k` analog of the frozen `habove`/`hbits` env-pinning
  hypotheses — as a bundle/lemma that ties `P.existF`'s free anchor env to the fixed
  `[x1,w,x,t]` via the zone navigation (`kvE_fiberBucket_nonempty_iff` supplies the
  navigation half; the missing half is the content-env pin). This MUST be symmetrized with the
  Future side (Phase 3.2/3.3, concurrently built, H7-locked) so both sides expose the same
  pin contract for Phase 5 / task 349. Recommend: orchestrator coordinates the pin design across
  both sides (or spawns a short research task on the pin shape) BEFORE re-dispatching 4.2/4.3.
- **Prohibited:** No `sorry`, no `def X := ⊥`/vacuous clause defs, no guessed pin shape that
  diverges from the Future side.
- **Estimated output:** ~550-850 lines total across 3 dispatches.
- **Bounded-unit stop condition:** as Phase 3, per sub-phase.
- **Timing:** ~7 hours (3 dispatches).
- **Depends on:** 2 (4.2 after 4.1; 4.3 after 4.2). Parallel with Phase 3 (H7: owns
  `ExteriorNegationPastK.lean` exclusively).
- **Done when:** `kvE_pastPos`/`kvE_extNegPast` + `_sound`/`_complete` green, sorry-free,
  axiom-clean; scoped `lake build` green; frozen diffs EMPTY; G6 review clean.
- **Files:** `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorNegationPastK.lean` (NEW; imports ExteriorFiberK).

### Phase 5: Interface exposition + k=0 rung recovery [NOT STARTED]

- **Goal:** Package the per-side clause facts into the exact bracket-buildable shape 349
  Phase 2's re-dispatch consumes, and prove the k=0 agreement with the frozen layer
  (research Q6).
- **Tasks:**
  - [ ] Interface module `ExteriorClauseInterfaceK.lean` (NEW, or an additive tail of the two
        side modules if the orchestrator prefers — implementer's call, recorded in progress
        file): per-side clause-fact bundles exposing (i) the positive clause formula, (ii) the
        negative (exterior-negation) formula, (iii) `_sound`/`_complete` in consumer-ready
        form, (iv) the full-fiber `hbelow`-pin lemma shape (the corrected replacement for the
        marginal `kvE_futAnyBit`-only pin — state it so 349 Phase 2 can supply/derive it).
  - [ ] Document (docstring) the exact consumption contract for 349 Phase 2: which decls it
        cites to build `kvE_extBracketPast`/`kvE_extBracketFut`, mirroring the frozen
        consumption pattern ExteriorBracket.lean:432-684.
  - [ ] Canonical-shape audit: every `P` occurrence is the verbatim
        `ExistProviders sig atomMap k` record (PriorInterface.lean:38-46); no bespoke bundle
        (postmortem rule 11). Record Q3's final hypothesis shape (UZ/SZ placement).
  - [ ] k=0 recovery: `example`/theorem-level agreement of the new layer at k=0
        (`σ : NormalForm sig 1 4`) with frozen `kvE2_futPos`/`kvE2_extNegFut` and Past
        mirrors — formula-level agreement or interderivability, mirroring the landed
        `kvE_futAnyBit_zero`/recovery-example pattern (ExteriorBracketK.lean:376-408). No
        edit to any frozen file.
  - [ ] Surface (do not fix) the 349/309 naming-drift note (`endChar_correct` vs
        `endInterval_correct`, research Q5) in the phase summary for the orchestrator handoff.
- **Estimated output:** ~200-350 lines.
- **Bounded-unit stop condition:** interface bundle + recovery examples green OR [BLOCKED] +
  `lean_goal`. One dispatch.
- **Timing:** ~3 hours.
- **Depends on:** 3, 4.
- **Done when:** interface decls green, sorry-free; k=0 recovery verified; consumption
  contract documented; frozen diffs EMPTY; commit.
- **Files:** `.../NfMultiAnchorBridge/ExteriorClauseInterfaceK.lean` (NEW, preferred; may
  import frozen ExteriorNegation/-Past read-only for the recovery statements) or additive
  tails of the two side modules.

### Phase 6: Axiom audit + whole-tree build [NOT STARTED]

- **Goal:** Terminal verification of the definition of done.
- **Tasks:**
  - [ ] Full `lake build` (whole tree) green.
  - [ ] `lean_verify` (axiom check) on every headline decl: `kvE_fiberPos_correct`, the F2
        separation theorem, `kvE_futPos`, `kvE_extNegFut`, `kvE_extNegFut_sound`,
        `kvE_extNegFut_complete`, `kvE_pastPos`, `kvE_extNegPast`, `kvE_extNegPast_sound`,
        `kvE_extNegPast_complete`, interface bundle decls, k=0 recovery decls — each exactly
        `[propext, Classical.choice, Quot.sound]` (equivalently `#print axioms`).
  - [ ] `git diff` EMPTY on all 7 frozen providers + KampPrior.lean + Lemma32Reduction.lean;
        `nf_nvar_exist_all_depths` signature unchanged.
  - [ ] Greps clean: `sorry` (0 in new modules), vacuous-def patterns (0), FORBIDDEN
        `nf_char3_deeper_split` (0 uses), G6 spot-check (no marginal bit in a content
        position — review every `Formula`-valued def's disjunct sources).
  - [ ] Confirm citability by 349 Phase 2: the interface decls resolve from a scratch
        `import ...ExteriorClauseInterfaceK` snippet (lean_run_code or a trivial example).
  - [ ] Final commit + implementation summary with sorry_inventory `[]` and the verification
        block mirroring 349's handoff schema.
- **Estimated output:** ~50-100 lines (audit examples/snippets only).
- **Bounded-unit stop condition:** all checks pass OR [BLOCKED] on the specific failing check.
  One dispatch.
- **Timing:** ~2 hours.
- **Depends on:** 5.
- **Done when:** every checklist item recorded passing; task status advances.
- **Files:** no new modules (audit snippets may live in the probe/interface files).

## Testing & Validation

- Per-phase: scoped `lake build <module>` green; sorry-free (`grep -c sorry` = 0 in new
  files); frozen-file `git diff` EMPTY before every commit; commit per green sub-step
  (git-workflow mandate).
- Phase 1 gate: F2 separation theorem is the machine-checked validation of the plan's central
  design ruling — hard GO/NO-GO.
- Phase 5: k=0 recovery examples validate frozen-layer agreement (Q6); interface snippet
  validates 349-consumability.
- Terminal (Phase 6): whole-tree `lake build`; `lean_verify`/`#print axioms` exactly
  `[propext, Classical.choice, Quot.sound]` on all headline decls; G1-G6 + FORBIDDEN greps
  clean.
- Literature fidelity (G5/lean4.md): every chain-step proof follows the cited paper passage
  in the mapping table; deviations flagged, never silently substituted.

## Artifacts & Outputs

- plans/01_depthk-clause-layer.md (this file)
- Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorFiberK.lean (NEW)
- Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorFiberProbeK.lean (NEW)
- Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorNegationK.lean (NEW)
- Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorNegationPastK.lean (NEW)
- Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorClauseInterfaceK.lean (NEW, Phase 5 preferred form)
- summaries/01_depthk-clause-layer-summary.md (implementation summary, per-phase records +
  final verification block)
- Total estimated Lean output: ~2100-3100 lines (center ~2500), consistent with the research
  Conflict-2 ruling (1800-2600 for the clause layer proper + probe + interface).

## Rollback/Contingency

- All work lands in NEW modules: rollback of any phase = delete/revert the new file(s) touched
  by that phase; no frozen or landed file is ever at risk (verified by the per-commit
  frozen-diff check).
- Phase 1 NO-GO: task -> [BLOCKED] with the machine-checked failure record; escalate via
  `/spawn 352` (candidate re-scopes: resolution (b) mutual-recursion architecture, or a richer
  provider bundle) — per research Conflict-3 contingency. No Phase 2+ lines are written.
- Any sub-phase irreducibly blocked mid-build: commit all green sub-steps (green-substep
  mandate), mark the sub-phase [BLOCKED] with exact `lean_goal`, escalate; sibling-side phases
  (3 vs 4) may continue independently under their territory contract.
- Snapshot before any destructive git operation via `bash .claude/scripts/git-snapshot.sh`
  (git-workflow rule); fix-forward is the default recovery direction.
