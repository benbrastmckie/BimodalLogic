# Implementation Plan: Task #856

- **Task**: 856 - Build the L^▷ proof system: OpenAxiom, OpenDerivationTree, soundness and conservativity
- **Status**: [IMPLEMENTING]
- **Effort**: 29 hours
- **Dependencies**: 854 (completed), 859 (completed) — the ▷-definability gate, both verdicts in
- **Research Inputs**: `specs/856_open_language_proof_system_and_soundness/reports/01_open-proof-system-soundness-conservativity.md`; `specs/856_open_language_proof_system_and_soundness/probes/01_erasure-collapse-and-discharge.lean` (255 lines, compiled-live, sorry-free)
- **Artifacts**: plans/01_open-proof-system-soundness.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

`FormalSystem/OpenLanguage/` carries a complete semantic account of L^▷ and no proof system. This
plan builds the proof system beside it: a closed `OpenAxiom` inductive, a seven-rule
`OpenDerivationTree` mirroring `PlusDerivationTree`, a syntactic erasure `eraseOpen` with its
axiom-discharge table, the two dispatch lemmas and the soundness recursion, conservativity over
TM⁺ in both directions and over TM at all four classes, and the collapse under `Determined`. The
mathematics is largely landed — every ▷/◁ soundness obligation is an existing `openValid_*`
theorem in `OpenLanguage/` — so the work is axiom-type construction, a 53-arm validity dispatch
against `OpenTruthAt`, and ledger discipline.

Definition of done: fifteen phases closed, zero `sorry`, zero vacuous definitions, the unscoped
guarded build green, `bash scripts/check-module-invariants.sh` (bare) and
`bash scripts/check-metalogic-cycles.sh` both green, and every new result carrying a
`docs/theorem-index.md` row with a measured axiom profile. No completeness claim is made anywhere.

### Research Integration

Findings carried directly into the plan:

- **The dependency gate is open, with a class split.** ▷ is L⁺-definable at `.ZTime`/`.RTime`
  (854) and not at `.Base`/`.Dense` (859). `OpenValid` quantifies over `.Base`, so the system is
  a genuine extension where it is stated. Every docstring that mentions novelty states the split
  (report R6); this is Phase 15's docstring audit, not an afterthought.
- **D1 is adopted without re-litigation.** The definability backward half `▷◁φ → ⊡φ` is NOT an
  `OpenAxiom` constructor. Probe 01 machine-checks that its erasure is *Determined*, which
  `PlusLanguage.refute_determined` refutes, so admitting it forfeits unconditional forward
  conservativity. It stays the landed validity `openValid_ofut_opast_imp_stab`. The task
  description's premise that the definability equation makes two-directional conservativity
  "statable rather than conditional" is corrected: what makes it statable is the
  derivability-preserving erasure, and only with this one exclusion.
- **D2/D4/D5 fix the architecture.** Forward conservativity goes through `eraseOpen`
  syntactically at layer 0 (the only available route: 859 rules out a truth-preserving
  translation at `.Base`, and there is no TM⁺ engine); the 53 TM⁺ schemata are re-declared, not
  embedded, because MF at `▷p` is needed; the collapse is stated via `eraseOpen`, which keeps `⊡`.
- **R2 is adopted with one correction.** Probe 01's §1-§3 are promoted rather than re-derived —
  but NOT verbatim: see Risk 2 below and Phase 5. Its `Type`-valued discharge terms are named
  `discharge_ofut_k`, `discharge_stab_of_box` and so on, and `check-module-invariants.sh` C26
  flags any live `def`/`abbrev` whose last name component carries a non-trailing underscore. Every
  discharge `def` is renamed to lowerCamelCase at promotion time, following
  `MinusLanguage/AxiomDischarge.lean` (`dischargePropK`, `dischargeModalT`, `dischargeAxiom`).
- **R3/R4/R5 are adopted.** Rigidity is stated as implication pairs, never biconditionals; the
  `OpenFormula` purity predicates admit `▷ψ`/`◁ψ` recursively (never as blanket leaves), with the
  erasure-preservation lemma proved alongside them; no necessitation rule is added for ▷ or ◁ —
  both are derived through `necessitation`, `box_stab` and the bridge.
- **R7 is adopted.** No atomization and no uniform-substitution shortcut for the 53 validity arms
  (`Conservativity/Plus/Atomization.lean` rests on `stab_state_only` and `▷χ` is not state-local;
  TM⁺ is not substitution-closed via `atom_stab`). The ~1,400 lines are budgeted across Phases
  6-11.
- **One correction to the report's own staging mitigation.** The report proposes staging the
  1,400-line validity dispatch as "`partial`-closing phases". That would leave a `sorry` in the
  tree between phases and fail C3, which asserts zero structural `sorry` by content. Phases 6-10
  instead land **per-block helper theorems**, each independently complete, and Phase 11 assembles
  the two wildcard-free dispatch lemmas from them. Every phase is sorry-free at its own close.

### Prior Plan Reference

No prior plan. This is round 1.

### Roadmap Alignment

No `roadmap_path` was provided in this dispatch and `roadmap_flag` is not set, so no roadmap
review or update phases are added, and `specs/ROADMAP.md` is not read or written by this plan.

### Gates This Plan Discovered That Research Did Not

Two gate collisions were found at plan-authoring time, both confirmed by reading the gate scripts
and both now carried by a specific phase. They are recorded in `issues.jsonl`.

- **`check-metalogic-cycles.sh` assertion B is an equality, not a ceiling.** Its `ALLOWLIST`
  (`scripts/check-metalogic-cycles.sh`, beside `_SRC`) holds exactly eight lines, all
  `FormalSystem.MinusLanguage.AxiomDischarge` (layer 0) importing a `FormalSystem.Theorems.*`
  module (layer 2), and the assertion **fails on a surplus as well as a shortfall**. The new
  `OpenErasure.lean` sits at layer 0 and must import `Theorems` for the HN discharge arm, so it
  produces surplus upward edges. Phase 5 extends the allowlist in the same phase as the imports,
  with the entries derived by running `measure-refactor-partitions.py upward-edges` rather than
  hand-copied from this plan — the script's own standing instruction. Keeping `OpenErasure` at
  layer 0 with an allowlist entry is the precedent-faithful choice: `AxiomDischarge` is itself
  allowlisted, and the layer table's docstring explicitly rejects reclassifying a file by content
  judgement to empty the allowlist.
- **C26 forbids non-trailing underscores in `def` names.** See the R2 correction above.

Neither `scripts/check-metalogic-cycles.sh` nor the four `Metalogic/` files this plan creates
appear in the task's recorded `file_scope`
(`FormalSystem/OpenLanguage/OpenAxioms.lean`, `OpenDerivation.lean`,
`FormalSystem/OpenLanguage/README.md`, `scripts/measure-refactor-partitions.py`,
`docs/theorem-index.md`). `file_scope` is descriptive and never filesystem-validated, so this is
a note rather than a blocker; each phase's `Files to modify` block below is the authoritative
footprint and is what `plan-file-scope-harvest.sh` will harvest at plan postflight.

## Goals & Non-Goals

**Goals**:

- `minFrameClass` — the axiom type's frame-class floor, one arm per constructor, no wildcard.
- `OpenDerivable` — Prop-valued derivability in the L^▷ system, mirroring the TM⁺ equivalent.
- `eraseOpen` — the ▷/◁-deleting retraction of the L⁺ embedding, carrying forward
  conservativity, the discharge table and the deterministic collapse.
- `openDerivable_of_plusDerivable` — backward conservativity over TM⁺, by constructor embedding.
- `plusDerivable_of_openDerivable` — forward conservativity over TM⁺, unconditional, syntactic,
  at layer 0, with no engine and no completeness hypothesis.
- `openAxiom_validIn_min` and `openAxiom_reflect_time_validIn_min` — the two dispatch lemmas,
  neither with a wildcard arm.
- `open_soundness_validIn` — soundness of the L^▷ system at every frame class.
- `openDerivable_ofFormula_iff` — conservativity over TM, both directions, at a class with a
  weak-completeness engine.
- `openTruthAt_eraseOpen_of_deterministic` — the collapse on a deterministic frame, choice-free.

**Non-Goals**:

- Any completeness claim for L^▷, at any frame class, in any form — including a docstring
  sentence that could be read as one. `plus_incomplete_base` stands as proved, `blc` stays a
  non-theorem, and an LC_n-style schema is still required in L^▷ exactly as in L⁺.
- Adding any constructor to `PlusFormula`, `PlusAxiom` or `PlusDerivationTree`, or altering
  `OpenFormula`'s nine constructors.
- Defining `⊡` away as `▷◁`. `OpenFormula.stab` stays primitive.
- Admitting `▷◁φ → ⊡φ` to the axiom type (D1), or admitting any schema whose validity needs a
  frame class no `FrameClass` tag denotes — `Determined` is reached through the frame-predicate
  form only.
- Stating HN for `⊡` (refuted by `hnStab_refuted_sinkFrame`), or the converse of any bridge (five
  landed `not_openValid_*` refutations), or any ▷/◁ cross-bridge (they are incomparable).
- The deferred cross-language optimisation the report names under R7 — generic schema-validity
  lemmas over `[TruthEnv L] [StabClauses L]` in `Semantics/TruthClauses.lean`. That refactor
  would serve L⁺, L⋆ and L^▷ at once and is a separate task.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The ~1,400-line validity dispatch overflows a single phase | H | H | Phases 6-10 land independently complete per-block helper theorems; Phase 11 assembles the two dispatch lemmas. No phase closes with a `sorry`, so C3 stays green throughout (this supersedes the report's `partial`-closing proposal) |
| Probe 01 promoted verbatim fails C26 on `discharge_ofut_k`-style `def` names | M | H | Phase 5 renames every `Type`-valued discharge term to lowerCamelCase before landing it, following `AxiomDischarge.lean`; `theorem` names keep snake_case (C26 exempts `theorem`, and C23 forbids `lemma` entirely) |
| `OpenErasure.lean`'s `Theorems` imports trip `check-metalogic-cycles.sh` assertion B | M | H | Phase 5 extends `ALLOWLIST` in the same phase as the imports, deriving entries from `measure-refactor-partitions.py upward-edges`; Phase 5's verification runs that script, not only the build |
| A later constructor silently escapes the discharge table | M | M | The discharge table has no wildcard arm, exactly like the two dispatch lemmas. The extension recipe for `OpenAxiom` is therefore **four** arms per constructor, not three; Phase 1 records that in `OpenAxioms.lean`'s docstring |
| Purity side conditions break the discharge table | M | M | Phase 1 defines `IsPureFutureOpen`/`IsPurePastOpen` with recursive ▷/◁ clauses (never blanket leaves — a blanket clause is semantically true but breaks the erasure-preservation lemma); Phase 4 proves `IsPurePastOpen φ → IsPurePast (eraseOpen φ)` and its mirror |
| A reader takes conservativity over TM⁺ for a completeness result | M | M | Phase 13's `Forward.lean` docstring states that conservativity here is a consequence of the axiom choice — the system is deliberately weak on ▷ — and names `plus_incomplete_base`, `blc` and the still-required LC_n schema |
| Axiom-profile regression: picking up `Classical.choice` where the semantic half was choice-free | L | M | Probe 01 measures the collapse at `[propext]`. Phase 14 pins it at that value and each lifted terminus is compared against the semantic half it lifts, per phase, not only at the end |
| Sibling-task collision on the shared working tree | M | M | The overlap with task 852 is real, not avoidable: `plan-file-scope-harvest.sh` appends the generated surfaces any `.lean` edit forces — `typst/generated/status.typ` and every ancestor-chain README with a generated inventory block — and 852 declares `typst/generated/status.typ`, `README.md`, `FormalSystem/README.md` and `FormalSystem/Metalogic/README.md` too. Serializing the two tasks is the correct outcome, which the harvester's own note states; task 865 is undeclared and may touch anything. Mitigation is procedural: re-read each shared file immediately before editing it, stage only this task's own hunks (never a directory or glob pathspec), never run `git-snapshot.sh` in its reverting default mode, and treat a build failure outside this plan's own footprint as possibly a sibling's in-flight edit |
| `Formula.lean` has module invariants and is outside `file_scope` | L | L | `abbrev OpenContext := List OpenFormula` is declared in `OpenDerivation.lean` rather than beside `OpenFormula` (where `PlusContext` sits relative to `PlusFormula`), so `Formula.lean` is never edited. Phase 3 records the divergence and its reason in the module docstring |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 4, 6 | 1 |
| 3 | 3, 7, 14 | 2, 4, 6 |
| 4 | 5, 8 | 2, 3, 4, 7 |
| 5 | 9 | 8 |
| 6 | 10 | 2, 9 |
| 7 | 11 | 2, 10 |
| 8 | 12 | 3, 11 |
| 9 | 13 | 5, 12 |
| 10 | 15 | 13, 14 |

Phases within the same wave can execute in parallel. Phases 7-11 all write
`OpenAxiomValidity.lean` and are therefore chained sequentially on purpose rather than grouped
into one wave: the serialization is same-file territory discipline, not a mathematical dependency.

---

### Phase 1: `OpenAxioms.lean` — purity predicates, the ▷/◁ block, `minFrameClass` [COMPLETED]

**Goal**: Create the axiom type with its restricted-modal constructors only, so the module
compiles standalone and every later phase has a target to extend.

**Tasks**:

- [x] Create `FormalSystem/OpenLanguage/OpenAxioms.lean` importing `FormalSystem.OpenLanguage.Formula`
  and `FormalSystem.ProofSystem.Axioms` and nothing else — no `FormalSystem.Semantics.*`, no
  semantic module of any language (the directory's module invariant).
- [x] *(deviation: altered — this bullet's literal sample clause `| ofut {φ} : IsPureFutureOpen φ → IsPureFutureOpen (.ofut φ)` contradicts the next bullet and is unsound; `▷` is past-determined, not future-determined, so admitting it as pure-future would falsify `paste`. Implemented the next bullet's crossed direction: `IsPureFutureOpen` admits `.opast` under a recursive guard, `IsPurePastOpen` admits `.ofut`.)* Declare `IsPureFutureOpen` and `IsPurePastOpen` as inductives mirroring
  `PlusFormula.IsPureFuture`/`IsPurePast` (`FormalSystem/PlusLanguage/Formula.lean:309-318`),
  adding `| ofut {φ} : IsPureFutureOpen φ → IsPureFutureOpen (.ofut φ)` and the matching
  recursive `opast` clauses. Admit `▷ψ` as pure-past and `◁ψ` as pure-future **only when `ψ` is
  itself pure** — a blanket leaf clause is semantically true but breaks Phase 4's
  erasure-preservation lemma.
- [x] Declare `inductive OpenAxiom : OpenFormula → Type` carrying the restricted-modal block
  only: `ofut_k`, `ofut_t`, `ofut_four`, `ofut_five`; `opast_k`, `opast_t`, `opast_four`,
  `opast_five`; `stab_of_box`, `ofut_of_stab`, `opast_of_stab`; `hn_open`, `hn_open_mirror`;
  `rigidity_opast_fwd`, `rigidity_opast_bwd` (guarded by `IsPureFutureOpen`),
  `rigidity_ofut_fwd`, `rigidity_ofut_bwd` (guarded by `IsPurePastOpen`);
  `definability_fwd` (`⊡φ → ▷◁φ`).
- [x] Do NOT declare `definability_bwd` (`▷◁φ → ⊡φ`) — D1. Record in the constructor-block
  docstring that it is excluded, that its erasure is *Determined* and refuted by
  `PlusLanguage.refute_determined`, and that the forward half is anyway derivable in the system
  from `stab_4`, the two bridges, `▷`-K and derived `▷`-necessitation.
- [x] Declare `namespace OpenAxiom` / `def minFrameClass {φ : OpenFormula} : OpenAxiom φ → FrameClass`
  with one arm per constructor and no wildcard. Every arm above is `.Base`. Spell it
  `namespace OpenAxiom` + `def minFrameClass` rather than `def OpenAxiom.minFrameClass` (the
  `PlusAxiom` spelling) so the bare name resolves for `lean-plan-compliance-check.sh`'s
  declaration grep.
- [x] Add `rfl` pins (as `example`, not `theorem`) showing `minFrameClass` on the ▷/◁ block.
- [x] Write the module docstring: the four-arms-per-constructor extension recipe (constructor,
  `minFrameClass` arm, validity arm, reflection-validity arm, **plus** the discharge arm — five
  surfaces, which is one more than `PlusLanguage/README.md`'s recipe states, because the
  discharge arm can be impossible rather than merely laborious); the class split (notational at
  `.ZTime`/`.RTime` by 854, a genuine extension at `.Base`/`.Dense` by 859); and an explicit "no
  completeness is claimed" sentence.
- [x] Add `"OpenAxioms": 0` to the `"OpenLanguage"` dict of `LANGUAGE_FILE_LAYERS` in
  `scripts/measure-refactor-partitions.py`.
- [x] Add `import FormalSystem.OpenLanguage.OpenAxioms` to `FormalSystem/OpenLanguage.lean` and a
  module bullet to its `## Modules` list.

**Timing**: 2 hours

**Depends on**: none

**Verification Tier**: interface

**Tier Justification**: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.OpenLanguage`
elaborates the new module together with its one-hop dependent, the `OpenLanguage.lean` aggregator,
and `bash scripts/check-metalogic-cycles.sh` covers the layer-table row and the syntax-before-semantics
edge — together the complete covering set for a new layer-0 module plus one aggregator import.

**Scope Hypothesis**: the restricted-modal block is hypothesised at 18 constructors, enumerated
in the task list above and derived from the report's schema table (minus `definability_bwd` per
D1). Confirm by counting `^  | ` lines in the `OpenAxiom` block and checking the count equals the
number of `minFrameClass` arms; a mismatch means a constructor escaped the dispatch.

**Files to modify**:

- `FormalSystem/OpenLanguage/OpenAxioms.lean` - new: purity predicates, `OpenAxiom` ▷/◁ block, `minFrameClass`, `rfl` pins, module docstring
- `FormalSystem/OpenLanguage.lean` - add the import and the `## Modules` bullet
- `scripts/measure-refactor-partitions.py` - add `"OpenAxioms": 0` to the `OpenLanguage` layer dict

**Verification**:

- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.OpenLanguage` exits 0.
- `bash scripts/check-metalogic-cycles.sh` exits 0 (assertions A, B and C all pass — B must not
  report a surplus or a stale row; C must not report a syntax-imports-semantics edge).
- `grep -c '^  | ' ` over the `OpenAxiom` block equals the `minFrameClass` arm count.
- No `sorry`, no `lemma`, no `def`/`abbrev` name with a non-trailing underscore in the new file.

---

### Phase 2: `OpenAxioms.lean` — the re-declared TM⁺ schemata [COMPLETED]

**Goal**: Re-declare every TM⁺ schema at `OpenFormula` parameters, so MF at `▷p` and every other
▷-containing instance is available, and extend `minFrameClass` to cover them.

**Tasks**:

- [x] For each constructor of `PlusAxiom` (`FormalSystem/PlusLanguage/Axioms.lean:107-338`),
  add the corresponding `OpenAxiom` constructor at `OpenFormula` parameters, keeping the
  constructor name and argument order identical so the Phase 3 embedding and the Phase 5
  discharge table are constructor-to-constructor.
- [x] Carry the purity side conditions across: `paste` takes `IsPureFutureOpen φ` and
  `IsPurePastOpen ψ`; `untl_paste` takes `IsPurePastOpen α` and `IsPureFutureOpen φ`.
- [x] Extend `minFrameClass` with one arm per new constructor, matching
  `PlusAxiom.minFrameClass`'s assignment exactly: `.Dense` for `density` and `dense_indicator`;
  `.ZTime` for `prior_UZ`, `prior_SZ`, `z1`; `.RTime` for `prior_U_gap` and the remaining
  Dedekind rows; `.Base` otherwise. Read the `PlusAxiom.minFrameClass` arms directly rather than
  reproducing them from this plan.
- [x] Add `rfl` pins (as `example`) for one representative constructor at each of the four frame
  classes.
- [x] *(deviation: altered — `OpenFormula.kPlus`/`kMinus` had to be declared in this file for `prior_U_gap`, `prior_S_gap` and `sep` to be statable at all; `OpenLanguage/Formula.lean` carries neither and is out of scope by plan design.)* Record in the docstring why the schemata are re-declared rather than embedded (D4): an
  `ofPlus`-embedding constructor supplies only ▷-free instances, and `□▷p → □G▷p` is needed.

**Timing**: 2 hours

**Depends on**: 1

**Verification Tier**: local

**Tier Justification**: the edit is confined to `OpenAxioms.lean` and changes no externally
visible signature (`OpenAxiom` and `minFrameClass` are already public from Phase 1), so
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.OpenLanguage.OpenAxioms`
is the complete covering check.

**Scope Hypothesis**: 53 re-declared constructors. Re-derived at plan-authoring time, not carried:
`sed -n '107,340p' FormalSystem/PlusLanguage/Axioms.lean | grep -cE '^\s{2}\| [a-zA-Z]'` returns
53 (the research report's figure, independently confirmed). Confirm at implementation time by
re-running that command and checking the new `OpenAxiom` block gained exactly that many
constructors and that many `minFrameClass` arms.

**Files to modify**:

- `FormalSystem/OpenLanguage/OpenAxioms.lean` - add the 53 TM⁺ mirror constructors, their `minFrameClass` arms, the four-class `rfl` pins and the D4 docstring note

**Verification**:

- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.OpenLanguage.OpenAxioms` exits 0.
- The `OpenAxiom` constructor count equals the `minFrameClass` arm count, and the TM⁺ mirror
  portion equals 53.
- Every `minFrameClass` arm's frame class matches its `PlusAxiom.minFrameClass` counterpart,
  checked arm by arm against `FormalSystem/PlusLanguage/Axioms.lean:320` onward.
- No `sorry` and no wildcard (`| _ =>`) arm in `minFrameClass`.

---

### Phase 3: `OpenDerivation.lean` and backward conservativity over TM⁺ [COMPLETED]

**Goal**: Land the seven-rule derivation tree, derived necessitation for `⊡`, `▷` and `◁`, and
backward conservativity over TM⁺ as a free consequence of the constructor embedding.

**Tasks**:

- [x] Create `FormalSystem/OpenLanguage/OpenDerivation.lean` importing
  `FormalSystem.OpenLanguage.OpenAxioms`, `FormalSystem.PlusLanguage.Derivation` and
  `FormalSystem.ProofSystem.Derivation`/`Derivable`.
- [x] Declare `abbrev OpenContext := List OpenFormula` here rather than in `Formula.lean`, and
  record in the docstring that this diverges from `PlusContext`'s placement beside `PlusFormula`
  deliberately, to leave `OpenLanguage/Formula.lean` and its module invariants untouched.
- [x] Declare `inductive OpenDerivationTree (fc : FrameClass) : OpenContext → OpenFormula → Type`
  with exactly the seven rules of `PlusDerivationTree`
  (`FormalSystem/PlusLanguage/Derivation.lean:72-94`): `axiom` (gated by
  `h.minFrameClass ≤ fc`), `assumption`, `modus_ponens`, `necessitation`,
  `temporal_necessitation`, `time_reflection`, `weakening`. Add no eighth rule (R5).
- [x] Add `lift`, `height`, `ofWeakeningNil` and the height lemmas, mirroring the
  `PlusDerivationTree` namespace block.
- [x] Declare `def OpenDerivable (fc : FrameClass) (Γ : OpenContext) (φ : OpenFormula) : Prop :=
  Nonempty (OpenDerivationTree fc Γ φ)`, the two `notation:50` forms mirroring `⊢⁺[fc]`, and
  `OpenDerivable.mono`.
- [x] Prove the three derived necessitation rules as `theorem`s: `stabNecessitation` (via
  `necessitation` then `stab_of_box`), `ofutNecessitation` and `opastNecessitation` (via
  `stabNecessitation` then the corresponding bridge). Record in the docstring that this is why
  the tree carries no rule for `⊡`, `▷` or `◁`.
- [x] *(deviation: altered — stated as `OpenAxiom (embPlus φ)` with `abbrev embPlus := ofPlus`, a reducible alias, because the declaration's own short name `ofPlus` shadows the formula-level embedding inside its own body; the two types are the same to the elaborator. The two purity transports are named `isPureFutureOpen_ofPlus`/`isPurePastOpen_ofPlus` for the same reason, and they are additions the plan's task list did not enumerate but `paste`/`untl_paste` make unavoidable.)* Prove `OpenAxiom.ofPlus : PlusAxiom φ → OpenAxiom (ofPlus φ)` constructor-to-constructor,
  and `minFrameClass_ofPlus : (OpenAxiom.ofPlus h).minFrameClass = h.minFrameClass`.
- [x] Prove `OpenDerivationTree.ofPlus : PlusDerivationTree fc Γ φ → OpenDerivationTree fc (Γ.map ofPlus) (ofPlus φ)`,
  one case per rule.
- [x] Prove `openDerivable_of_plusDerivable` — backward conservativity over TM⁺ — plus the four
  class rows at the empty context, mirroring `plus_backward_base`/`_dense`/`_ztime`/`_rtime`.
- [x] Add `"OpenDerivation": 0` to `LANGUAGE_FILE_LAYERS`, the import to
  `FormalSystem/OpenLanguage.lean`, and the `## Modules` bullet.

**Timing**: 2 hours

**Depends on**: 2

**Verification Tier**: interface

**Tier Justification**: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.OpenLanguage`
plus `bash scripts/check-metalogic-cycles.sh` covers the new layer-0 module, its new aggregator
import edge and its layer-table row — the same one-hop dependent set as Phase 1, and no module
outside `OpenLanguage/` imports anything from this directory yet.

**Scope Hypothesis**: seven derivation rules and one `ofPlus` case per rule. Confirm by checking
that `OpenDerivationTree.ofPlus`, `lift` and `height` each have exactly seven match arms and no
wildcard, against the seven constructors of `PlusDerivationTree`.

**Files to modify**:

- `FormalSystem/OpenLanguage/OpenDerivation.lean` - new: `OpenContext`, `OpenDerivationTree`, `lift`/`height`/`ofWeakeningNil`, `OpenDerivable` and notation, the three derived necessitation rules, `OpenAxiom.ofPlus`, `OpenDerivationTree.ofPlus`, `openDerivable_of_plusDerivable`
- `FormalSystem/OpenLanguage.lean` - add the import and the `## Modules` bullet
- `scripts/measure-refactor-partitions.py` - add `"OpenDerivation": 0`

**Verification**:

- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.OpenLanguage` exits 0.
- `bash scripts/check-metalogic-cycles.sh` exits 0.
- `lean_verify FormalSystem.OpenLanguage.openDerivable_of_plusDerivable` reports zero `sorry` and
  an axiom profile no wider than `PlusLanguage`'s own `plusDerivable_of_derivable`.
- No `lemma`, no underscored `def`/`abbrev` name, no `sorry`.

---

### Phase 4: `OpenErasure.lean` — erasure, retraction, reflection, purity transport [COMPLETED]

**Goal**: Land `eraseOpen` and its three structural properties, with no `Theorems` import yet, so
the allowlist question is isolated in Phase 5.

**Tasks**:

- [x] Create `FormalSystem/OpenLanguage/OpenErasure.lean` importing
  `FormalSystem.OpenLanguage.OpenAxioms` and `FormalSystem.PlusLanguage.Formula` only — no
  `FormalSystem.Theorems.*` in this phase.
- [x] Promote probe 01 §1: `def eraseOpen : OpenFormula → PlusFormula` deleting `▷` and `◁` and
  keeping `⊡` and the six L constructors; `@[simp] theorem eraseOpen_ofPlus` (the retraction);
  `theorem eraseOpen_reflectTime`. Carry the probe's proofs unweakened.
- [x] Add the four `rfl` pins (as `example`) showing erasure commutes with `neg`, `somePast`,
  `dofut` and `dstab`.
- [x] Prove the purity transport (R4): `theorem isPureFuture_eraseOpen` and
  `theorem isPurePast_eraseOpen`, i.e. `IsPureFutureOpen φ → IsPureFuture (eraseOpen φ)` and its
  past mirror, by induction over the predicates. Record in the docstring that this is what the
  recursive ▷/◁ purity clauses of Phase 1 buy, and that a blanket leaf clause would break it.
- [x] Add `"OpenErasure": 0` to `LANGUAGE_FILE_LAYERS`, the import to
  `FormalSystem/OpenLanguage.lean`, and the `## Modules` bullet.

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: interface

**Tier Justification**: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.OpenLanguage`
plus `bash scripts/check-metalogic-cycles.sh` covers the new layer-0 module, its aggregator import
edge and its layer-table row; the phase deliberately adds no upward import, so assertion B's
allowlist is unaffected and no wider check is owed here.

**Scope Hypothesis**: `eraseOpen` has nine match arms, one per `OpenFormula` constructor
(`FormalSystem/OpenLanguage/Formula.lean:85` onward), with `ofut` and `opast` both recursing
without re-wrapping. Confirm by arm count and by checking no wildcard arm is present.

**Files to modify**:

- `FormalSystem/OpenLanguage/OpenErasure.lean` - new: `eraseOpen`, `eraseOpen_ofPlus`, `eraseOpen_reflectTime`, the four `rfl` pins, `isPureFuture_eraseOpen`, `isPurePast_eraseOpen`
- `FormalSystem/OpenLanguage.lean` - add the import and the `## Modules` bullet
- `scripts/measure-refactor-partitions.py` - add `"OpenErasure": 0`

**Verification**:

- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.OpenLanguage` exits 0.
- `bash scripts/check-metalogic-cycles.sh` exits 0, with assertion B still reporting exactly its
  eight recorded lines (this phase must add none).
- `lean_verify FormalSystem.OpenLanguage.eraseOpen_reflectTime` reports `[propext]`, matching
  probe 01's measured profile.
- No `sorry`, no `lemma`, no underscored `def`/`abbrev` name.

---

### Phase 5: the discharge table, forward conservativity over TM⁺, and the allowlist [COMPLETED]

**Goal**: Land the axiom-discharge table and the erasure of derivations, giving unconditional
forward conservativity over TM⁺ at layer 0, and record the upward import edges the table forces.

**Tasks**:

- [x] Add the `FormalSystem.Theorems.*` imports `OpenErasure.lean` actually needs — at minimum
  `Theorems.Propositional.Core` and `Theorems.TemporalDerived` for the HN arm — plus
  `FormalSystem.PlusLanguage.Derivation` and `FormalSystem.PlusLanguage.Substitution`. Add only
  the imports the file uses; an unused import is a surplus allowlist line for nothing.
- [x] Promote probe 01 §3-§4, **renaming every `Type`-valued term to lowerCamelCase** so C26
  passes: `plusIdImp` (already conformant), `dischargeOfutK`, `dischargeOfutT`,
  `dischargeOfutFour`, `dischargeOfutFive`, `dischargeOpastT`, `dischargeOfutOfStab`,
  `dischargeOpastOfStab`, `dischargeStabOfBox`, `dischargeRigidityFwd`,
  `dischargeDefinabilityFwd`, `dischargeHnOpen`. Follow
  `FormalSystem/MinusLanguage/AxiomDischarge.lean`'s naming (`dischargePropK`, `dischargeModalT`,
  `dischargeAxiom`) rather than the probe's snake_case.
- [x] *(deviation: altered — the four `opast` S5 arms are discharged by `plusIdImp` directly, not through `reflectTime`: each erases to the identity `φ° → φ°` exactly as its `▷` twin does, which probe 01's `discharge_opast_t` already establishes, so a `reflectTime` transport would add a step and prove the same thing. A `dischargeHnOpenMirror` arm was added for `hn_open_mirror`, which the plan's named list omitted, and `OpenDerivation` had to be imported for `OpenDerivationTree.erase` to be statable.)* Add the remaining discharge arms: the four `opast` S5 arms via the `reflectTime` route, the
  `opast`/`ofut` rigidity arms, and one arm per re-declared TM⁺ constructor. Each TM⁺ mirror arm
  is one line, because `eraseOpen` commutes with every constructor and with every derived
  operator by `rfl`.
- [x] Declare `def dischargeAxiom {fc} {φ : OpenFormula} (h : OpenAxiom φ) (h_fc : h.minFrameClass ≤ fc) : ⊢⁺[fc] eraseOpen φ`
  with **one arm per constructor and no wildcard**, mirroring `AxiomDischarge.dischargeAxiom`.
- [x] Prove `def OpenDerivationTree.erase : OpenDerivationTree fc Γ φ → PlusDerivationTree fc (Γ.map eraseOpen) (eraseOpen φ)`,
  one case per rule, routing `axiom` through `dischargeAxiom` and `time_reflection` through
  `eraseOpen_reflectTime`.
- [x] Prove `theorem plusDerivable_of_openDerivable` — forward conservativity over TM⁺ — and the
  round trip `theorem plusDerivable_openDerivable_iff` at the empty context, composing it with
  Phase 3's `openDerivable_of_plusDerivable` through `eraseOpen_ofPlus`.
- [x] Record in the docstring that this route is forced (D2): 859 rules out a truth-preserving
  translation at `.Base`, there is no TM⁺ engine (`plus_incomplete_base`), and the result is
  therefore **not** modelled on `Conservativity.starConservative_of_plusComplete`, whose
  hypothesis is false at `.Base`. Record also that the table's wildcard-free shape is what makes
  a missed constructor a build error rather than a silent gap.
- [x] Run `python3 scripts/measure-refactor-partitions.py upward-edges` and add exactly the
  reported new `FormalSystem.OpenLanguage.OpenErasure -> FormalSystem.Theorems.*` lines to the
  `ALLOWLIST` frozenset in `scripts/check-metalogic-cycles.sh`, beside the existing `_SRC` block.
  Extend the comment above it to record the second source and why the file sits at layer 0 (the
  layer table's docstring forbids reclassifying by content judgement). Derive the entries from
  the script's output; do not hand-copy them from this plan.

**Timing**: 2 hours

**Depends on**: 2, 3, 4

**Verification Tier**: interface

**Tier Justification**: the only cross-file surface is `scripts/check-metalogic-cycles.sh`'s
allowlist, whose own covering check is `bash scripts/check-metalogic-cycles.sh` run together with
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.OpenLanguage`
for the new imports; nothing in `check-module-invariants.sh` reads that allowlist, so no broader
tier adds coverage here.

**Scope Hypothesis**: the discharge table has one arm per `OpenAxiom` constructor — hypothesised
at 71 (18 from Phase 1 plus 53 from Phase 2), and the HN arm is the only one that is not a
one-liner. Confirm at implementation time by checking that `dischargeAxiom`'s arm count equals the
`OpenAxiom` constructor count with no wildcard, and that
`python3 scripts/measure-refactor-partitions.py upward-edges` reports exactly the import lines
actually added.

**Files to modify**:

- `FormalSystem/OpenLanguage/OpenErasure.lean` - add the `Theorems`/`Substitution`/`Derivation` imports, the lowerCamelCase discharge terms, `dischargeAxiom`, `OpenDerivationTree.erase`, `plusDerivable_of_openDerivable`, `plusDerivable_openDerivable_iff` and the D2 docstring
- `scripts/check-metalogic-cycles.sh` - extend `ALLOWLIST` with the new `OpenErasure -> Theorems.*` upward edges and the explanatory comment

**Verification**:

- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.OpenLanguage` exits 0.
- `bash scripts/check-metalogic-cycles.sh` exits 0 — assertion B reports neither a surplus nor a
  shortfall against the extended allowlist. This is the phase's primary gate: a non-zero exit here
  means the allowlist edit and the import set disagree.
- `dischargeAxiom` has no wildcard arm and its arm count equals the `OpenAxiom` constructor count.
- No live `def`/`abbrev` in the file carries a non-trailing underscore (C26's rule), checked by
  grepping the new declaration headers.
- `lean_verify FormalSystem.OpenLanguage.plusDerivable_of_openDerivable` reports zero `sorry`.

---

### Phase 6: `Conservativity/Open/` scaffolding and the ▷/◁ validity block [COMPLETED]

**Goal**: Create the validity directory and land the restricted-modal validity and
reflection-validity block helpers, which are the cheap ones: every obligation is an existing
`openValid_*` theorem.

**Tasks**:

- [x] Create `FormalSystem/Metalogic/Conservativity/Open/` with
  `OpenAxiomValidity.lean`, a sibling aggregator `FormalSystem/Metalogic/Conservativity/Open.lean`
  (per C8's aggregator convention: sibling `X.lean` beside `X/`, never `X/X.lean`), a directory
  `README.md` carrying the module table, and the import row in
  `FormalSystem/Metalogic/Conservativity.lean`.
- [x] *(deviation: altered — the block is landed as fourteen per-constructor theorems plus a named conjunction aggregate, and the four rigidity halves are split into their own `openAxiomValidIn_rigidityBlock` aggregate; a single fourteen-way conjunction with no per-constructor names would force Phase 11 to project with nested `.2`s.)* In `OpenAxiomValidity.lean`, land `theorem openAxiomValidIn_ofutBlock` and
  `theorem openAxiomReflectValidIn_ofutBlock`: for each restricted-modal constructor of Phase 1,
  `OpenValidIn .Base` of the schema and of its `reflectTime`. Discharge each from the landed
  names: `openValid_ofut_k`, `openValid_ofut_t`, `openValid_ofut_four`, `openValid_ofut_five`,
  `openValid_opast_k`, `openValid_opast_t`, `openValid_opast_four`, `openValid_opast_five`,
  `openValid_stab_of_box`, `openValid_ofut_of_stab`, `openValid_opast_of_stab`,
  `hnOpen_openValid`, `hnOpenMirror_openValid` / `openValid_hnOpenPast`,
  `openValid_stab_imp_ofut_opast`.
- [x] Route every `◁` obligation through `openValid_reflectTime` from its `▷` twin — `reflectTime`
  fixes `⊡` and exchanges `▷` with `◁`, so each is one line.
- [x] *(deviation: altered — the landed `PlusLanguage.truth_congr_agreeFrom`/`truth_congr_agreeUpTo` are statements about `PlusTruthAt` and a pure L^▷ formula may carry the crossed restricted modal, so they do not apply; the file instead lands their L^▷ counterparts `openTruthAt_congr_agreeFrom`/`openTruthAt_congr_agreeUpTo`, whose seven shared arms transcribe the L⁺ proofs verbatim and whose one new arm each needs no induction hypothesis. The implication-pair shape (R3) is kept.)* Derive the two rigidity blocks from the landed semantic halves
  `PlusLanguage.truth_congr_agreeFrom` and `truth_congr_agreeUpTo`, stated as implication pairs
  rather than biconditionals (R3), using Phase 1's purity predicates as the guards.
- [x] Record in the module docstring that `definability_bwd` is absent from the axiom type (D1)
  while `openValid_ofut_opast_imp_stab` remains a landed validity, and that no completeness
  claim follows from anything in the file.

**Timing**: 2 hours

**Depends on**: 1

**Verification Tier**: interface

**Tier Justification**: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Conservativity`
elaborates the new module together with its one-hop dependents, the new `Open.lean` aggregator and
the `Conservativity.lean` aggregator that imports it, which is the full set this phase's new import
edges reach.

**Scope Hypothesis**: two block helpers covering the 18 restricted-modal constructors hypothesised
in Phase 1. Confirm that the helpers' case coverage matches that constructor list exactly, with
nothing left for Phase 11 to invent.

**Files to modify**:

- `FormalSystem/Metalogic/Conservativity/Open/OpenAxiomValidity.lean` - new: the ▷/◁ validity and reflection-validity block helpers, the rigidity blocks, the D1 docstring
- `FormalSystem/Metalogic/Conservativity/Open/README.md` - new: directory README with the module table
- `FormalSystem/Metalogic/Conservativity/Open.lean` - new: sibling aggregator
- `FormalSystem/Metalogic/Conservativity.lean` - add the `Open` import row

**Verification**:

- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Conservativity` exits 0.
- `bash scripts/check-metalogic-cycles.sh` exits 0 — assertion A still reports exactly one
  directory-level cycle in `Metalogic/` (the new `Conservativity -> ...` edges must not create a
  second).
- No `sorry`, no `lemma`, no underscored `def`/`abbrev` name.

---

### Phase 7: validity block — propositional and modal schemata [COMPLETED]

**Goal**: Land the block helpers for the propositional and S5-modal mirror constructors.

**Tasks**:

- [x] Land `theorem openAxiomValidIn_propBlock` and `theorem openAxiomReflectValidIn_propBlock`
  covering `prop_k`, `prop_s`, `ex_falso`, `peirce`.
- [x] Land `theorem openAxiomValidIn_modalBlock` and
  `theorem openAxiomReflectValidIn_modalBlock` covering `modal_t`, `modal_4`, `modal_b`,
  `modal_5_collapse`, `modal_k_dist`, `modal_future`. *(deviation: altered — two supporting
  theorems added in the same file, `openTruthAt_congr_ext` and `openTruthAt_timeShift`, because
  the `modal_future` arm moves the time of evaluation and no L^▷ `timeShift` lemma existed; a
  `## Clause-lemma re-exports` section was added for the same reason, `OpenTruth` carrying no
  `allFuture_iff`/`diamond_iff` of its own)*
- [x] Prove each arm directly against `OpenTruthAt`. Do not route through
  `Conservativity/Plus/Atomization.lean` or uniform substitution (R7): atomization rests on
  `stab_state_only` and `▷χ` is not state-local, and TM⁺ is not substitution-closed via
  `atom_stab`. Record that in the block docstring so the shortcut is not re-attempted.
- [x] Use `openValid_reflectTime` for each reflection arm where the schema's `reflectTime` image
  is the schema itself or another schema already in the block.

**Timing**: 2 hours

**Depends on**: 6

**Verification Tier**: local

**Tier Justification**: the edit is confined to `OpenAxiomValidity.lean` and adds no symbol any
module outside it calls yet, so
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Conservativity.Open.OpenAxiomValidity`
is the complete covering check.

**Scope Hypothesis**: ten constructors in this phase (four propositional, six modal), read off the
`PlusAxiom` block at `FormalSystem/PlusLanguage/Axioms.lean:107-230`. Confirm by checking the two
block helpers together cover exactly those ten names and no others.

**Files to modify**:

- `FormalSystem/Metalogic/Conservativity/Open/OpenAxiomValidity.lean` - add the propositional and modal block helpers and the R7 docstring note

**Verification**:

- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Conservativity.Open.OpenAxiomValidity` exits 0.
- Each block helper's covered constructor names are enumerated in its docstring and match the
  `OpenAxiom` constructors of the same names.
- No `sorry`, no `lemma`.

---

### Phase 8: validity block — temporal schemata, part 1 [COMPLETED]

**Goal**: Land the block helpers for the monotonicity, connection, enrichment, accumulation and
absorption schemata.

**Tasks**:

- [x] Land `theorem openAxiomValidIn_tempMonoBlock` / `openAxiomReflectValidIn_tempMonoBlock`
  covering `left_mono_until_G`, `left_mono_since_H`, `right_mono_until`, `right_mono_since`,
  `connect_future`, `connect_past`, `serial_future`, `serial_past`.
- [x] Land `theorem openAxiomValidIn_tempAccumBlock` /
  `openAxiomReflectValidIn_tempAccumBlock` covering `enrichment_until`, `enrichment_since`,
  `self_accum_until`, `self_accum_since`, `absorb_until`, `absorb_since`.
- [x] Pair each future schema with its past mirror through `openValid_reflectTime` so only one of
  each pair is proved from scratch. *(deviation: altered — `openValid_reflectTime` pairs each
  schema with the REFLECTION of itself, which is what the dispatch's reflection arm owes; the
  past-mirror CONSTRUCTORS (`left_mono_since_H`, `right_mono_since`, `connect_past`,
  `enrichment_since`, `self_accum_since`, `absorb_since`) are separate `OpenAxiom` constructors
  needing their own validity arms, so each was proved directly as in
  `StarAxiomValidity.lean`; only the sixteen reflection halves are one-liners)*

**Timing**: 2.5 hours

**Depends on**: 7

**Verification Tier**: local

**Tier Justification**: same single-module confinement as Phase 7 —
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Conservativity.Open.OpenAxiomValidity`
covers it, since no other module imports these helpers until Phase 11.

**Scope Hypothesis**: fourteen constructors in this phase. Confirm against the `PlusAxiom` block
and record in each helper's docstring which names it covers, so Phase 11 can check the union is
total.

**Files to modify**:

- `FormalSystem/Metalogic/Conservativity/Open/OpenAxiomValidity.lean` - add the temporal monotonicity and accumulation block helpers

**Verification**:

- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Conservativity.Open.OpenAxiomValidity` exits 0.
- Every past-mirror arm routes through `openValid_reflectTime` rather than repeating its twin's
  proof.
- No `sorry`, no `lemma`.

---

### Phase 9: validity block — temporal schemata, part 2 [NOT STARTED]

**Goal**: Land the block helpers for the linearity schemata and the `F`/`P` equivalences.

**Tasks**:

- [ ] Land `theorem openAxiomValidIn_linearityBlock` /
  `openAxiomReflectValidIn_linearityBlock` covering `linear_until`, `linear_since`,
  `temp_linearity`, `temp_linearity_past`.
- [ ] Land `theorem openAxiomValidIn_tempEquivBlock` /
  `openAxiomReflectValidIn_tempEquivBlock` covering `until_F`, `since_P`, `F_until_equiv`,
  `P_since_equiv`.
- [ ] Pair future and past schemata through `openValid_reflectTime` as in Phase 8.

**Timing**: 2.5 hours

**Depends on**: 8

**Verification Tier**: local

**Tier Justification**: same single-module confinement as Phases 7-8 —
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Conservativity.Open.OpenAxiomValidity`
is the complete covering check while these helpers have no consumer.

**Scope Hypothesis**: eight constructors in this phase. Confirm against the `PlusAxiom` block and
record the covered names in each helper's docstring.

**Files to modify**:

- `FormalSystem/Metalogic/Conservativity/Open/OpenAxiomValidity.lean` - add the linearity and temporal-equivalence block helpers

**Verification**:

- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Conservativity.Open.OpenAxiomValidity` exits 0.
- No `sorry`, no `lemma`.

---

### Phase 10: validity block — discrete, Prior, Dedekind, `⊡` and pasting [NOT STARTED]

**Goal**: Land the remaining block helpers: the class-restricted schemata and the stability block,
closing the constructor set.

**Tasks**:

- [ ] Land `theorem openAxiomValidIn_discreteBlock` / its reflection twin covering
  `discrete_symm_fwd`, `discrete_symm_bwd`, `discrete_propagate_fwd`,
  `discrete_propagate_bwd`, `discrete_box_necessity`.
- [ ] Land `theorem openAxiomValidIn_priorBlock` / twin covering `prior_UZ`, `prior_SZ`, `z1`,
  `prior_U_gap`, `prior_S_gap`, `sep`.
- [ ] Land `theorem openAxiomValidIn_denseBlock` / twin covering `density`, `dense_indicator`.
- [ ] Land `theorem openAxiomValidIn_stabBlock` / twin covering `stab_k`, `stab_t`, `stab_4`,
  `stab_5`, `box_stab`, `atom_stab`.
- [ ] Land `theorem openAxiomValidIn_pasteBlock` / twin covering `paste` and `untl_paste`,
  consuming Phase 1's purity predicates and the landed
  `PlusLanguage.truth_congr_agreeFrom`/`truth_congr_agreeUpTo` halves.
- [ ] State each class-restricted helper at the frame class its `minFrameClass` arm names
  (`.Dense`, `.ZTime`, `.RTime`), never at `.Base`. A schema valid only over a restricted class
  that no `FrameClass` tag denotes is not here at all: it goes through the frame-predicate form,
  as `PlusLanguage`'s recipe directs for `Determined`.

**Timing**: 2.5 hours

**Depends on**: 2, 9

**Verification Tier**: local

**Tier Justification**: same single-module confinement as Phases 7-9 —
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Conservativity.Open.OpenAxiomValidity`
is the complete covering check; the helpers still have no consumer until Phase 11.

**Scope Hypothesis**: twenty-one constructors in this phase, which with Phases 6-9 is hypothesised
to exhaust the `OpenAxiom` constructor set (18 + 10 + 14 + 8 + 21 = 71). Confirm by taking the
union of the covered-name lists recorded in every block helper's docstring and checking it equals
the `OpenAxiom` constructor list exactly — this is the check Phase 11 depends on, and a shortfall
found here is far cheaper than one found in the dispatch.

**Files to modify**:

- `FormalSystem/Metalogic/Conservativity/Open/OpenAxiomValidity.lean` - add the discrete, Prior, dense, stability and pasting block helpers

**Verification**:

- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Conservativity.Open.OpenAxiomValidity` exits 0.
- The union of covered constructor names across all block helpers equals the `OpenAxiom`
  constructor list, with no name covered twice and none missing.
- Each class-restricted helper is stated at the frame class its `minFrameClass` arm names.
- No `sorry`, no `lemma`.

---

### Phase 11: assemble the two dispatch lemmas [NOT STARTED]

**Goal**: Land `openAxiom_validIn_min` and `openAxiom_reflect_time_validIn_min` as wildcard-free
dispatches over every constructor, routing each arm to its Phase 6-10 block helper.

**Tasks**:

- [ ] Prove `theorem openAxiom_validIn_min {φ : OpenFormula} (ax : OpenAxiom φ) : OpenValidIn ax.minFrameClass φ`
  by `cases ax`, with **one arm per constructor and no wildcard arm**, mirroring
  `plusAxiom_validIn_min` (`FormalSystem/Metalogic/Conservativity/Plus/AxiomValidity.lean:74`).
- [ ] Prove `theorem openAxiom_reflect_time_validIn_min {φ : OpenFormula} (ax : OpenAxiom φ) : OpenValidIn ax.minFrameClass φ.reflectTime`
  the same way, mirroring `plusAxiom_reflect_time_validIn_min` (same file, line 191).
- [ ] Record in the docstring that neither lemma carries a wildcard, that this is what makes a
  future constructor a build error rather than a silent gap, and that the full per-constructor
  obligation is five arms (constructor, `minFrameClass`, validity, reflection-validity,
  discharge).

**Timing**: 1.5 hours

**Depends on**: 2, 10

**Verification Tier**: interface

**Tier Justification**: these two lemmas are the public entry point every later phase imports —
Phase 12's soundness recursion consumes both — so the covering build is
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Conservativity`,
which elaborates the module plus the two aggregators that re-export it.

**Scope Hypothesis**: both dispatches have exactly as many arms as `OpenAxiom` has constructors
(hypothesised 71 per Phase 5). Confirm by arm count on each lemma and by the absence of any `| _ =>`
arm; Lean's own exhaustiveness check is the primary confirmation, and the arm count is the guard
against a wildcard having been added to satisfy it.

**Files to modify**:

- `FormalSystem/Metalogic/Conservativity/Open/OpenAxiomValidity.lean` - add `openAxiom_validIn_min`, `openAxiom_reflect_time_validIn_min` and the no-wildcard docstring

**Verification**:

- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Conservativity` exits 0.
- Neither dispatch lemma contains a wildcard arm (grep the two `cases ax with` blocks for `| _`).
- `lean_verify` on both names reports zero `sorry`.
- No `lemma`, no `sorry`.

---

### Phase 12: `OpenSoundness.lean` [NOT STARTED]

**Goal**: Land the soundness recursion over `OpenDerivationTree` and the class rows.

**Tasks**:

- [ ] Create `FormalSystem/Metalogic/Conservativity/Open/OpenSoundness.lean` and add its import
  to `FormalSystem/Metalogic/Conservativity/Open.lean` and the directory README's module table.
- [ ] Prove `theorem open_derivable_valid_and_reflect_time_validIn`, the simultaneous recursion
  over the seven rules, mirroring `star_derivable_valid_and_reflect_time_validIn`
  (`FormalSystem/Metalogic/Conservativity/Star/StarSoundness.lean:71`). The `time_reflection` rule
  is what forces the conjunction; the `axiom` rule consumes both Phase 11 dispatch lemmas with
  `OpenValidIn.mono` against the rule's `minFrameClass ≤ fc` gate.
- [ ] Prove `theorem open_soundness_validIn {fc} {φ} (h : OpenDerivable fc [] φ) : OpenValidIn fc φ`.
- [ ] Prove the four class rows — `open_soundness_valid`, `open_soundness_dense`,
  `open_soundness_ztime`, `open_soundness_rtime` — and the non-triviality row
  `open_not_derivable_nil_bot`, mirroring `StarSoundness.lean`'s own row block.
- [ ] Prove the context form `open_soundness_in`, mirroring `plus_soundness_in`.
- [ ] State in the docstring that soundness is all this file claims: no completeness, in any form,
  for any class.

**Timing**: 1.5 hours

**Depends on**: 3, 11

**Verification Tier**: interface

**Tier Justification**: the soundness terminus is consumed by Phase 13's `Forward.lean`, so the
covering build is
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Conservativity`,
which elaborates the new module plus the two aggregators that re-export it.

**Scope Hypothesis**: the recursion has seven cases, one per `OpenDerivationTree` rule, with no
wildcard. Confirm by case count against Phase 3's rule list.

**Files to modify**:

- `FormalSystem/Metalogic/Conservativity/Open/OpenSoundness.lean` - new: the simultaneous recursion, `open_soundness_validIn`, the four class rows, `open_soundness_in`, `open_not_derivable_nil_bot`
- `FormalSystem/Metalogic/Conservativity/Open.lean` - add the import
- `FormalSystem/Metalogic/Conservativity/Open/README.md` - add the module-table row

**Verification**:

- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Conservativity` exits 0.
- `lean_verify FormalSystem.Metalogic.open_soundness_validIn` reports zero `sorry` and an axiom
  profile no wider than `star_soundness_validIn`'s.
- The recursion has seven cases and no wildcard.
- No `lemma`, no `sorry`.

---

### Phase 13: `Forward.lean` — conservativity over TM and the TM⁺ row [NOT STARTED]

**Goal**: Land the TM rows at all four classes and state the TM⁺ row in both directions.

**Tasks**:

- [ ] Create `FormalSystem/Metalogic/Conservativity/Open/Forward.lean`, add its import to
  `Open.lean` and its README module-table row.
- [ ] Prove `theorem forward_open {fc} (engine : WeakCompleteness fc) (φ : Formula) (h : OpenDerivable fc [] (ofPlus (ofFormula φ))) : ProofSystem.Derivable fc [] φ`,
  mirroring `forward_star` (`FormalSystem/Metalogic/Conservativity/Star/Forward.lean:103`):
  soundness, then `openValid_ofPlus_iff`/`openValidIn_ofPlus_iff`, then
  `plusValidIn_ofFormula_iff`, then the engine.
- [ ] Instantiate at the four classes (`forward_open_base`, `_dense`, `_ztime`, `_rtime`) with
  `completeness_base`/`_dense`/`_ztime`/`_rtime`.
- [ ] Prove `theorem openDerivable_ofFormula_iff {fc} (engine : WeakCompleteness fc) (φ : Formula) : OpenDerivable fc [] (ofPlus (ofFormula φ)) ↔ ProofSystem.Derivable fc [] φ`
  and its four class instantiations.
- [ ] State the TM⁺ row in both directions as `theorem openDerivable_ofPlus_iff`, composing Phase
  3's `openDerivable_of_plusDerivable` with Phase 5's `plusDerivable_of_openDerivable` through
  `eraseOpen_ofPlus`. It is unconditional and syntactic: no engine, no completeness hypothesis.
- [ ] Write the docstring guard (Risk 6): conservativity here is a consequence of the axiom choice
  — the system is deliberately weak on `▷` — and it is **not** modelled on
  `starConservative_of_plusComplete`, whose hypothesis is false at `.Base`. Name
  `plus_incomplete_base`, record that `blc` stays a non-theorem, and record that an LC_n-style
  schema is still required in L^▷ exactly as in L⁺.

**Timing**: 1.5 hours

**Depends on**: 5, 12

**Verification Tier**: interface

**Tier Justification**: the new module's public rows are re-exported through two aggregators and
reach `FormalSystem.lean`'s closure, so
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Conservativity`
plus the import check in `bash scripts/check-metalogic-cycles.sh` (assertion A, the one
directory-level cycle) is the covering set for this one-hop dependent fan-out.

**Scope Hypothesis**: four TM class rows plus one TM⁺ row. Confirm that each class row names the
engine its class requires and that the TM⁺ row takes no engine argument at all — an engine
parameter on the TM⁺ row would mean the syntactic route was abandoned.

**Files to modify**:

- `FormalSystem/Metalogic/Conservativity/Open/Forward.lean` - new: `forward_open` and its four instantiations, `openDerivable_ofFormula_iff` and its four instantiations, `openDerivable_ofPlus_iff`, the no-completeness docstring guard
- `FormalSystem/Metalogic/Conservativity/Open.lean` - add the import
- `FormalSystem/Metalogic/Conservativity/Open/README.md` - add the module-table row

**Verification**:

- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Conservativity` exits 0.
- `bash scripts/check-metalogic-cycles.sh` exits 0 with assertion A still reporting exactly one
  cycle.
- `openDerivable_ofPlus_iff`'s signature contains no `WeakCompleteness` argument.
- `grep -niE 'complete' ` over the new file finds no sentence asserting completeness of the L^▷
  system; every hit is either a `WeakCompleteness` engine reference or part of the explicit
  no-completeness guard.
- No `lemma`, no `sorry`.

---

### Phase 14: `OpenCollapse.lean` — the collapse under `Determined` [COMPLETED]

**Goal**: Land the deterministic collapse and recover the landed deterministic completeness
through the composite erasure.

**Tasks**:

- [x] Create `FormalSystem/Metalogic/Deterministic/OpenCollapse.lean` and add its import to
  `FormalSystem/Metalogic/Deterministic.lean` (or the directory's aggregator as it is named) and
  the `Deterministic/README.md` module table.
- [x] Promote probe 01 §2: `theorem openTruthAt_eraseOpen_of_deterministic`, by induction with the
  history and time binders inside the statement, exactly as
  `plusTruthAt_erasePlus_of_deterministic` (`FormalSystem/Metalogic/Deterministic/Erasure.lean:133`).
  Determinism is consumed **only** in the `ofut`/`opast` cases, through
  `states_eq_of_deterministic` and the landed `truth_congr_ext`; the `stab` case is structural
  because `eraseOpen` keeps `⊡`.
- [x] Prove `theorem openTruthAt_erasePlus_eraseOpen_of_deterministic`, the composition with
  `plusTruthAt_erasePlus_of_deterministic` landing in L.
- [x] *(deviation: altered — no `OpenValidDetIn` existed, so the file declares it (`OpenValidOnFrames` at `DetSat fc`) with its two binder adapters before the corollary pair, mirroring `PlusValidDetIn`'s own shape in `Deterministic/Validity.lean`. A second composite `iff` down to L was added alongside.)* Prove the validity-level corollary pair and the `iff`, mirroring
  `validDetIn_erasePlus_of_plusValidDetIn`, `plusValidDetIn_of_validDetIn_erasePlus` and
  `plusValidDetIn_iff_validDetIn_erasePlus` in `Erasure.lean`.
- [x] Recover the landed deterministic completeness through the composite erasure, naming the
  `Deterministic/Completeness.lean` row recovered. Record in the docstring that `⊡ = ▷ = ◁ = id`
  on a deterministic frame is what makes this work, and that `Determined` is reached through the
  frame-predicate form only — it is not and must not become an `OpenAxiom` constructor.

**Timing**: 1.5 hours

**Depends on**: 4

**Verification Tier**: interface

**Tier Justification**: the new module is re-exported by the `Deterministic` aggregator and its
collapse rows are consumed by the existing deterministic-completeness block, so
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Deterministic`
elaborates the module plus exactly that one-hop dependent set.

**Scope Hypothesis**: the collapse induction has nine cases, one per `OpenFormula` constructor,
with determinism consumed in exactly two of them. Confirm by case count and by checking that
`hD` appears only in the `ofut` and `opast` cases — a `stab` case that consumes determinism means
`eraseOpen` was changed to erase `⊡`, which D5 forbids.

**Files to modify**:

- `FormalSystem/Metalogic/Deterministic/OpenCollapse.lean` - new: `openTruthAt_eraseOpen_of_deterministic`, the composite, the validity-level corollary pair and `iff`, the deterministic-completeness recovery
- `FormalSystem/Metalogic/Deterministic.lean` - add the import
- `FormalSystem/Metalogic/Deterministic/README.md` - add the module-table row

**Verification**:

- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Deterministic` exits 0.
- `lean_verify FormalSystem.Metalogic.openTruthAt_eraseOpen_of_deterministic` reports `[propext]`
  — choice-free, matching probe 01's measured profile and the semantic half it lifts. A wider
  profile is a regression to investigate, not a new baseline.
- Determinism (`hD`) is consumed in exactly the `ofut` and `opast` cases.
- No `lemma`, no `sorry`.

---

### Phase 15: ledger surfaces and the full gate [NOT STARTED]

**Goal**: Record every new result on the ledger surfaces it owes, rewrite the three "semantic
only" claims that this task falsifies, and run the complete gate set.

**Tasks**:

- [ ] Re-read `docs/theorem-index.md` immediately before editing (sibling-task concurrency), then
  add one row per new result to its `OpenLanguage` section and a new `Conservativity/Open`
  block: paper label `—` for all of them (the manuscript supplies no logic for the restricted
  modals), one-line statement, **fully qualified** Lean name, file path with no line numbers,
  frame class, and the measured axiom set. Measure each profile with `lean_verify`; do not type a
  value from this plan or from the research report.
- [ ] Rewrite the standing "L^▷ is **semantic only**: it has no proof system" sentence in all
  three places it occurs: `docs/theorem-index.md:558`, `FormalSystem/OpenLanguage.lean:81`, and
  `FormalSystem/OpenLanguage/README.md:17`. Replace each with the proof system's actual scope: a
  sound system, conservative over TM⁺ in both directions and over TM at all four classes, with no
  completeness claim.
- [ ] Add the class-split sentence (R6) to every docstring that mentions novelty: notational at
  `.ZTime`/`.RTime` by the open-future elimination result, a genuine extension at `.Base`/`.Dense`
  by the non-definability result. Cite the landed module names, not task numbers.
- [ ] Add the C14 baseline pair for each `pinned:C14` row — one line in the `C14_BASELINE` heredoc
  (`scripts/check-module-invariants.sh:2237`) and a matching `#print axioms` line in the Lean
  heredoc; they are compared by exact string equality, so both edits are required for each row.
  Pin at least: the soundness terminus, the four conservativity rows, the collapse, and the HN and
  erasure termini.
- [ ] Add the `OpenLanguage/README.md` module-table rows for the three new `OpenLanguage/` files,
  and update `FormalSystem/README.md` and the root `README.md` only if they carry a stale claim
  this task falsifies — re-read each immediately before editing.
- [ ] Regenerate the README inventory blocks: `bash scripts/check-module-invariants.sh --emit-inventory`.
  Never hand-edit a generated inventory block.
- [ ] Run the unscoped guarded build for final verification.
- [ ] Run the bare `bash scripts/check-module-invariants.sh` and repair every finding. A flagged
  subset's exit 0 is not the whole gate. Expect attention on C14 (the new baseline pairs), C15
  (paper-anchor round trip for every new docstring `Paper:` line), C16 (`env_linter`: `simpNF`,
  `docBlame`, `unusedArguments` over the new declarations), C17 (dead declarations — every block
  helper must be reached by a dispatch lemma), C19 (the 90% docstring-coverage floor), C23
  (zero live `lemma`, no `Uppercase_x` names), C26 (no non-trailing underscore in any new
  `def`/`abbrev`), C28 (per-file warning budgets for the new files), C35
  (`scripts/lean-citation-manifest.json` byte-currency) and C21/C24.
- [ ] Run `bash scripts/check-metalogic-cycles.sh` and confirm all three assertions.
- [ ] Final audit sweep: `grep` the new files for any sentence that could be read as a
  completeness claim for L^▷, and confirm `plus_incomplete_base` and `blc`'s non-theoremhood are
  stated as standing, unperturbed.

**Timing**: 2 hours

**Depends on**: 13, 14

**Verification Tier**: full

**Scope Hypothesis**: seven new Lean files (three under `FormalSystem/OpenLanguage/`, three under
`FormalSystem/Metalogic/Conservativity/Open/`, one under `FormalSystem/Metalogic/Deterministic/`)
and three occurrences of the "semantic only" sentence. The three occurrences were located at
plan-authoring time at `docs/theorem-index.md:558`, `FormalSystem/OpenLanguage.lean:81` and
`FormalSystem/OpenLanguage/README.md:17`; re-run
`grep -rn 'semantic only' docs/ FormalSystem/ README.md` at implementation time rather than
trusting those line numbers, since sibling tasks share this tree. A fourth occurrence outside
this task's subject matter (`docs/theorem-index.md:595`, concerning a frame-level section) must be
left alone.

**Files to modify**:

- `docs/theorem-index.md` - new rows for every result; rewrite the "semantic only" claim
- `FormalSystem/OpenLanguage.lean` - rewrite the "semantic only" design-decision paragraph; class-split sentence
- `FormalSystem/OpenLanguage/README.md` - rewrite the "semantic only" claim; module-table rows for the three new files
- `FormalSystem/README.md` - regenerated inventory block (`--emit-inventory`); update any claim this task falsifies. Shared with task 852 -- re-read immediately before editing
- `README.md` - regenerated inventory block (`--emit-inventory`); update any claim this task falsifies. Shared with task 852 -- re-read immediately before editing
- `scripts/check-module-invariants.sh` - add the C14 baseline pair for each pinned row
- `scripts/lean-citation-manifest.json` - regenerate if C35 reports it stale
- `FormalSystem/Metalogic/Conservativity/Open/README.md` - final module-table state

**Verification**:

- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` (unscoped, final
  verification) exits 0.
- `bash scripts/check-module-invariants.sh` — bare, no flags, no subset — exits 0.
- `bash scripts/check-metalogic-cycles.sh` exits 0 with all three assertions reported passing.
- `bash scripts/check-module-invariants.sh --emit-inventory --check` exits 0 (no generated
  inventory block would change).
- `bash .claude/scripts/lean-sorry-census.sh` reports zero `sorry` across the new files.
- Every new `docs/theorem-index.md` row's axiom set equals the value `lean_verify` reports for
  that fully qualified name, and each lifted terminus is no wider than the semantic half it lifts.
- No new file contains a completeness claim for the L^▷ system.

---

## Lean Challenge Statements

These are the signatures the task commits to, pinned before implementation. The four `inductive`
declarations are scaffolding — they are what makes the block type-check standalone, and their
constructor sets are fixed by Phases 1-3's task lists rather than here (the ▷/◁ block is shown;
the 53 TM⁺ mirror constructors of Phase 2 are elided, which changes none of the theorem signatures
below, every one of which quantifies over `OpenAxiom φ` rather than over a constructor). Each
declaration's body is `sorry` here **only** so the signature is machine-comparable.

```lean
import FormalSystem.OpenLanguage
import FormalSystem.PlusLanguage
import FormalSystem.Metalogic.Conservativity.Plus
import FormalSystem.Metalogic.Deterministic

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.ProofSystem
open FormalSystem.PlusLanguage FormalSystem.OpenLanguage

namespace FormalSystem.OpenLanguage

inductive IsPureFutureOpen : OpenFormula → Prop
  | atom (p : Atom) : IsPureFutureOpen (.atom p)
  | bot : IsPureFutureOpen .bot
  | imp {φ ψ : OpenFormula} : IsPureFutureOpen φ → IsPureFutureOpen ψ →
      IsPureFutureOpen (.imp φ ψ)
  | box (φ : OpenFormula) : IsPureFutureOpen (.box φ)
  | stab (φ : OpenFormula) : IsPureFutureOpen (.stab φ)
  | untl {ψ φ : OpenFormula} : IsPureFutureOpen ψ → IsPureFutureOpen φ →
      IsPureFutureOpen (.untl ψ φ)
  | opast {φ : OpenFormula} : IsPureFutureOpen φ → IsPureFutureOpen (.opast φ)

inductive IsPurePastOpen : OpenFormula → Prop
  | atom (p : Atom) : IsPurePastOpen (.atom p)
  | bot : IsPurePastOpen .bot
  | imp {φ ψ : OpenFormula} : IsPurePastOpen φ → IsPurePastOpen ψ → IsPurePastOpen (.imp φ ψ)
  | box (φ : OpenFormula) : IsPurePastOpen (.box φ)
  | stab (φ : OpenFormula) : IsPurePastOpen (.stab φ)
  | snce {ψ φ : OpenFormula} : IsPurePastOpen ψ → IsPurePastOpen φ → IsPurePastOpen (.snce ψ φ)
  | ofut {φ : OpenFormula} : IsPurePastOpen φ → IsPurePastOpen (.ofut φ)

inductive OpenAxiom : OpenFormula → Type where
  | ofut_k (φ ψ : OpenFormula) :
      OpenAxiom ((OpenFormula.ofut (φ.imp ψ)).imp ((OpenFormula.ofut φ).imp (OpenFormula.ofut ψ)))
  | ofut_t (φ : OpenFormula) : OpenAxiom ((OpenFormula.ofut φ).imp φ)
  | ofut_four (φ : OpenFormula) :
      OpenAxiom ((OpenFormula.ofut φ).imp (OpenFormula.ofut (OpenFormula.ofut φ)))
  | ofut_five (φ : OpenFormula) :
      OpenAxiom ((OpenFormula.dofut φ).imp (OpenFormula.ofut (OpenFormula.dofut φ)))
  | opast_k (φ ψ : OpenFormula) :
      OpenAxiom ((OpenFormula.opast (φ.imp ψ)).imp
        ((OpenFormula.opast φ).imp (OpenFormula.opast ψ)))
  | opast_t (φ : OpenFormula) : OpenAxiom ((OpenFormula.opast φ).imp φ)
  | opast_four (φ : OpenFormula) :
      OpenAxiom ((OpenFormula.opast φ).imp (OpenFormula.opast (OpenFormula.opast φ)))
  | opast_five (φ : OpenFormula) :
      OpenAxiom ((OpenFormula.dopast φ).imp (OpenFormula.opast (OpenFormula.dopast φ)))
  | stab_of_box (φ : OpenFormula) : OpenAxiom ((OpenFormula.box φ).imp (OpenFormula.stab φ))
  | ofut_of_stab (φ : OpenFormula) : OpenAxiom ((OpenFormula.stab φ).imp (OpenFormula.ofut φ))
  | opast_of_stab (φ : OpenFormula) : OpenAxiom ((OpenFormula.stab φ).imp (OpenFormula.opast φ))
  | hn_open (α : OpenFormula) :
      OpenAxiom ((OpenFormula.somePast α).imp
        (OpenFormula.ofut (OpenFormula.somePast (OpenFormula.dofut α))))
  | hn_open_mirror (α : OpenFormula) :
      OpenAxiom ((OpenFormula.someFuture α).imp
        (OpenFormula.opast (OpenFormula.someFuture (OpenFormula.dopast α))))
  | rigidity_opast_fwd (φ : OpenFormula) (h : IsPureFutureOpen φ) :
      OpenAxiom ((OpenFormula.opast φ).imp φ)
  | rigidity_opast_bwd (φ : OpenFormula) (h : IsPureFutureOpen φ) :
      OpenAxiom (φ.imp (OpenFormula.opast φ))
  | rigidity_ofut_fwd (ψ : OpenFormula) (h : IsPurePastOpen ψ) :
      OpenAxiom ((OpenFormula.ofut ψ).imp ψ)
  | rigidity_ofut_bwd (ψ : OpenFormula) (h : IsPurePastOpen ψ) :
      OpenAxiom (ψ.imp (OpenFormula.ofut ψ))
  | definability_fwd (φ : OpenFormula) :
      OpenAxiom ((OpenFormula.stab φ).imp (OpenFormula.ofut (OpenFormula.opast φ)))

namespace OpenAxiom

def minFrameClass {φ : OpenFormula} : OpenAxiom φ → FrameClass := sorry

end OpenAxiom

abbrev OpenContext := List OpenFormula

inductive OpenDerivationTree (fc : FrameClass) : OpenContext → OpenFormula → Type where
  | axiom (Γ : OpenContext) (φ : OpenFormula) (h : OpenAxiom φ)
      (h_fc : h.minFrameClass ≤ fc) : OpenDerivationTree fc Γ φ
  | assumption (Γ : OpenContext) (φ : OpenFormula) (h : φ ∈ Γ) : OpenDerivationTree fc Γ φ
  | modus_ponens (Γ : OpenContext) (φ ψ : OpenFormula)
      (d1 : OpenDerivationTree fc Γ (φ.imp ψ))
      (d2 : OpenDerivationTree fc Γ φ) : OpenDerivationTree fc Γ ψ
  | necessitation (φ : OpenFormula)
      (d : OpenDerivationTree fc [] φ) : OpenDerivationTree fc [] (OpenFormula.box φ)
  | temporal_necessitation (φ : OpenFormula)
      (d : OpenDerivationTree fc [] φ) : OpenDerivationTree fc [] (OpenFormula.allFuture φ)
  | time_reflection (φ : OpenFormula)
      (d : OpenDerivationTree fc [] φ) : OpenDerivationTree fc [] φ.reflectTime
  | weakening (Γ Δ : OpenContext) (φ : OpenFormula)
      (d : OpenDerivationTree fc Γ φ) (h : Γ ⊆ Δ) : OpenDerivationTree fc Δ φ

def OpenDerivable (fc : FrameClass) (Γ : OpenContext) (φ : OpenFormula) : Prop :=
  Nonempty (OpenDerivationTree fc Γ φ)

def eraseOpen : OpenFormula → PlusFormula := sorry

theorem openDerivable_of_plusDerivable {fc : FrameClass} {Γ : PlusContext} {φ : PlusFormula}
    (h : PlusDerivable fc Γ φ) : OpenDerivable fc (Γ.map ofPlus) (ofPlus φ) := sorry

theorem plusDerivable_of_openDerivable {fc : FrameClass} {Γ : OpenContext} {φ : OpenFormula}
    (h : OpenDerivable fc Γ φ) : PlusDerivable fc (Γ.map eraseOpen) (eraseOpen φ) := sorry

end FormalSystem.OpenLanguage

namespace FormalSystem.Metalogic

open FormalSystem.OpenLanguage

theorem openAxiom_validIn_min {φ : OpenFormula} (ax : OpenAxiom φ) :
    OpenValidIn ax.minFrameClass φ := sorry

theorem openAxiom_reflect_time_validIn_min {φ : OpenFormula} (ax : OpenAxiom φ) :
    OpenValidIn ax.minFrameClass φ.reflectTime := sorry

theorem open_soundness_validIn {fc : FrameClass} {φ : OpenFormula}
    (h : OpenDerivable fc [] φ) : OpenValidIn fc φ := sorry

theorem openDerivable_ofFormula_iff {fc : FrameClass} (engine : WeakCompleteness fc)
    (φ : Formula) :
    OpenDerivable fc [] (ofPlus (ofFormula φ)) ↔ ProofSystem.Derivable fc [] φ := sorry

theorem openTruthAt_eraseOpen_of_deterministic {F : TaskFrame} (hD : F.Deterministic)
    (M : TaskModel F) (φ : OpenFormula) :
    ∀ (τ : WorldHistory F) (t : F.Duration),
      OpenTruthAt M τ t φ ↔ PlusTruthAt M τ t (eraseOpen φ) := sorry

end FormalSystem.Metalogic
```

## Testing & Validation

- [ ] Every phase's scoped guarded build exits 0 at its own close; the unscoped guarded build
  exits 0 in Phase 15.
- [ ] `bash scripts/check-module-invariants.sh` (bare) exits 0.
- [ ] `bash scripts/check-metalogic-cycles.sh` exits 0, all three assertions passing — assertion B
  reporting neither surplus nor shortfall against the allowlist as extended in Phase 5.
- [ ] Zero `sorry` and zero vacuous definitions (`def X := True`/`Unit`/`trivial`, or any
  `noncomputable` `Decidable`-valued declaration) across all seven new Lean files.
- [ ] `minFrameClass`, `dischargeAxiom`, `openAxiom_validIn_min` and
  `openAxiom_reflect_time_validIn_min` each have one arm per `OpenAxiom` constructor and no
  wildcard arm.
- [ ] Each lifted terminus's measured axiom profile is no wider than the semantic half it lifts;
  the collapse measures `[propext]`.
- [ ] `docs/theorem-index.md` carries a row for every new public result, with a measured axiom set.
- [ ] No completeness claim for L^▷ appears in any new file, in any form.
- [ ] Every docstring mentioning novelty states the `.ZTime`/`.RTime` versus `.Base`/`.Dense`
  class split.

## Artifacts & Outputs

- `FormalSystem/OpenLanguage/OpenAxioms.lean` — purity predicates, `OpenAxiom`, `minFrameClass`
- `FormalSystem/OpenLanguage/OpenDerivation.lean` — `OpenContext`, `OpenDerivationTree`,
  `OpenDerivable`, derived necessitation, backward conservativity over TM⁺
- `FormalSystem/OpenLanguage/OpenErasure.lean` — `eraseOpen`, the discharge table, forward
  conservativity over TM⁺
- `FormalSystem/Metalogic/Conservativity/Open/OpenAxiomValidity.lean` — the block helpers and the
  two wildcard-free dispatch lemmas
- `FormalSystem/Metalogic/Conservativity/Open/OpenSoundness.lean` — the soundness recursion and
  the four class rows
- `FormalSystem/Metalogic/Conservativity/Open/Forward.lean` — conservativity over TM at four
  classes and the TM⁺ row in both directions
- `FormalSystem/Metalogic/Conservativity/Open/README.md`,
  `FormalSystem/Metalogic/Conservativity/Open.lean` — directory README and aggregator
- `FormalSystem/Metalogic/Deterministic/OpenCollapse.lean` — the `Determined` collapse and the
  deterministic-completeness recovery
- Edits: `FormalSystem/OpenLanguage.lean`, `FormalSystem/Metalogic/Conservativity.lean`,
  `FormalSystem/Metalogic/Deterministic.lean` and its README,
  `scripts/measure-refactor-partitions.py` (three layer rows),
  `scripts/check-metalogic-cycles.sh` (allowlist), `scripts/check-module-invariants.sh` (C14
  baseline pairs), `docs/theorem-index.md`, `FormalSystem/OpenLanguage/README.md`,
  `FormalSystem/README.md`, `README.md`, `scripts/lean-citation-manifest.json`

## Rollback/Contingency

Each phase is one commit, scoped to that phase's own `Files to modify` list, so reverting a phase
is `git revert` of its commit — no working-tree discard is needed and none is sanctioned here.
Before any phase whose edit is genuinely risky to the working tree, take a **non-reverting**
checkpoint: `bash .claude/scripts/git-snapshot.sh 856 --no-revert`. Do not emit the default
reverting form as a routine precaution; that invocation belongs only to a genuine rollback, whose
procedure (including its out-of-scope override flag) is in `context/contracts/recovery.md`'s
rollback rung.

Two contingencies are worth naming because they would otherwise invite an unsanctioned shortcut:

- **A validity arm in Phases 7-10 resists proof.** Do not add a wildcard arm, do not weaken the
  schema, and do not route through atomization or uniform substitution (R7 forbids both for stated
  reasons). Mark the phase `[BLOCKED]`, record the goal state reached, and raise it — per
  `rules/plan-compliance.md`, a would-be deviation on a `.lean` file is escalated, not annotated.
- **The allowlist extension in Phase 5 does not make assertion B green.** The failure mode to
  avoid is substituting a content-judgement layer row (`"OpenErasure": 2`) to dodge the allowlist;
  the layer table's own docstring rejects that move by name. If the edges cannot be allowlisted,
  the fallback is to split the HN discharge arm into a separate layer-2 module outside
  `OpenLanguage/`, which is a plan revision, not an implementation decision.
