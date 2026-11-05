# Research Report: Task #856

**Task**: 856 - Build the L^▷ proof system: OpenAxiom, OpenDerivationTree, soundness and conservativity
**Started**: 2026-11-05T15:44:00Z
**Completed**: 2026-11-05T16:35:00Z
**Effort**: 1 research round (one compiled-live probe, 263 lines, exit 0, no sorry, no warnings; five landed precedents measured)
**Dependencies**: 854 (completed), 859 (completed) — the ▷-definability gate, both verdicts in
**Sources/Inputs**:
- Codebase: `FormalSystem/OpenLanguage/*` (all six files), `FormalSystem/PlusLanguage/{Axioms,Derivation,Formula,Substitution,PlusPasting,PlusDeterminism,PlusNonValidities}.lean`, `FormalSystem/StarLanguage/{Axioms,Derivation}.lean`, `FormalSystem/MinusLanguage/AxiomDischarge.lean`, `FormalSystem/Metalogic/Conservativity/{Plus,Star}/*`, `FormalSystem/Metalogic/Deterministic/{Erasure,Completeness,System}.lean`, `FormalSystem/Metalogic/Independence/PlusIncompleteness.lean`, `FormalSystem/Semantics/{TruthClauses,FrameProperty}.lean`, `FormalSystem/Theorems/{TemporalDerived,Propositional/Core}.lean`
- Gate scripts: `scripts/measure-refactor-partitions.py` (`LANGUAGE_FILE_LAYERS`), `scripts/check-metalogic-cycles.sh`, `scripts/check-module-invariants.sh` (C14 baseline pair), `docs/theorem-index.md`
- Dependency verdicts: `specs/854_open_future_modal_lplus_definability/reports/01_open-future-definability-verdict.md`, `specs/859_qtime_open_future_definability_base_dense/reports/01_qtime-open-future-definability.md`
- Lean toolchain: direct `lean` compile against the repository's own oleans (lean-lsp not used for search; evidence tier is compiled-live, not index-backed)
**Artifacts**:
- `specs/856_open_language_proof_system_and_soundness/reports/01_open-proof-system-soundness-conservativity.md` (this report)
- `specs/856_open_language_proof_system_and_soundness/probes/01_erasure-collapse-and-discharge.lean` (compiled-live, exit 0, no sorry, no warnings)
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **THE DEPENDENCY GATE IS OPEN, and the task is justified — but only for part of the class
  lattice, and that is the first finding.** Both gating verdicts are landed and completed:
  ▷ **is** L⁺-definable at `.ZTime` and `.RTime` (task 854), and ▷ is **not** L⁺-definable at
  `.Base` or `.Dense` (task 859, by a compiled marker gadget plus a GHR collapse argument). So
  L^▷ is a genuine expressive extension of L⁺ over non-Dedekind-complete time, and a proof system
  for it is not notation for `PlusAxiom`. At `.ZTime`/`.RTime` it *is* notational — which does not
  cancel the task, because `OpenValid` quantifies over every regular task frame (`.Base`), but it
  does mean every docstring must state the class split rather than claim L^▷ is everywhere new.
- **The task description's conservativity premise is wrong, and the correction is forced rather
  than optional.** The description says the definability equation makes two-directional
  conservativity over TM⁺ "statable rather than conditional". Verified false. What makes the hard
  direction statable is a **derivability-preserving translation**, and the ← half of the
  definability equation (`▷◁φ → ⊡φ`) destroys every candidate: it erases to *Determined*, which is
  refuted (`PlusLanguage.refute_determined`). Machine-checked in the probe
  (`definability_bwd_erasure_eq`, `definability_bwd_erasure_not_plusValid`). **Decision D1**: the ←
  half stays a validity (`openValid_ofut_opast_imp_stab`, already landed) and is **not** an
  `OpenAxiom` constructor. With that one exclusion, conservativity over TM⁺ holds in both
  directions, unconditionally and syntactically — strictly better than the TM⋆ precedent, whose
  L⁺-row is a conditional on TM⁺ completeness that is false at `.Base`.
- **One function carries three of the task's deliverables.** `eraseOpen : OpenFormula →
  PlusFormula` (delete `▷` and `◁`, keep `⊡` primitive) is simultaneously (i) the retraction that
  makes forward conservativity over TM⁺ a one-line composition, (ii) the axiom-discharge key, and
  (iii) the *Determined* collapse map. All three are prototyped compiled-live in probe 01:
  `eraseOpen_ofPlus`, `eraseOpen_reflectTime`, nine discharge arms (including the Ockhamist HN
  arm), and `openTruthAt_eraseOpen_of_deterministic` — the last **choice-free** (`[propext]`
  only), matching the semantic halves it lifts.
- **The dominant cost is not the new modals; it is the 53 re-declared TM⁺ schemata.** `OpenAxiom`
  must re-declare every TM⁺ schema at `OpenFormula` parameters (an `ofPlus`-embedding constructor
  would supply only ▷-free instances, and MF at `▷p` is needed). Their **validity** arms cannot be
  transferred by atomization — `Conservativity/Plus/Atomization.lean` rests on `stab_state_only`
  and `▷χ` is not state-local — nor by uniform substitution (TM⁺ is not substitution-closed via
  `atom_stab`). The measured precedent is `Conservativity/Star/StarAxiomValidity.lean` at **1,479
  lines** for exactly this obligation. Their **erasure-discharge** arms, by contrast, are one line
  each, because `eraseOpen` commutes with every constructor.
- **Sizing: ~2,400–2,700 new Lean lines over 7 files and 5 ledger surfaces; 10–12 phases, one
  schema family per phase.** The schema-validity file alone is ~1,400 lines and should be split
  across phases by block (propositional/modal, temporal, uniformity/Prior/Z1/Dedekind, `⊡`, then
  the new ▷/◁ block).

## Context & Scope

**What was researched.** Whether the gate is open; what `OpenAxiom`/`OpenDerivationTree` must
contain and where the files go; which soundness obligations are already landed and which are new;
how each of the three acceptance baselines (soundness, two-directional conservativity over TM⁺,
collapse under *Determined*) can actually be discharged against this tree; and what the gates and
ledgers require. No file under `FormalSystem/`, `Tests/`, `docs/` or `scripts/` was modified: the
only writes are this report, the probe, and the task's own metadata.

**Constraints honoured.** No completeness claim is proposed anywhere. No constructor is proposed
for `PlusFormula`, `PlusAxiom` or `PlusDerivationTree`, and `OpenFormula`'s nine constructors stay
as they are. `OpenFormula.stab` stays primitive. *Determined* stays out of the axiom type and is
reached through the frame-predicate form.

**Evidence tier.** lean-lsp was registered and reachable, but no `lean_local_search` result is
load-bearing in this report: every name cited was read out of the source file that declares it,
and every claim about derivability or truth was either read from a landed proof or compiled in
probe 01.

## Findings

### The dependency gate, and what the two verdicts license

| Class | ▷ L⁺-definable? | Source | Consequence for this task |
|---|---|---|---|
| `.ZTime` | **Yes**, uniformly (Gabbay separation + the compiled elimination `▷(α ∨ β) ↔ α ∨ ⊡β`) | 854 report; `Metalogic/Expressiveness/OpenFutureElimination.lean` | The proof system is notational here; do not claim novelty at this class |
| `.RTime` | **Yes** (Dedekind-complete separation) | 854 report | Same |
| `.Dense` | **No** | 859 report; `Metalogic/Expressiveness/OpenFutureUndefinable` layer | The system is a genuine extension |
| `.Base` | **No** | 859 report | The system is a genuine extension, and `OpenValid` lives here |

Both tasks are `completed` in `specs/state.json`, so the hard gate is satisfied. 859's negative
verdict also closes the only *semantic* route to the hard conservativity direction at `.Base`: if
no truth-preserving translation exists, nothing can be transported through `PlusValid` plus a TM⁺
engine — and there is no TM⁺ engine anyway (`plus_incomplete_base`).

### Codebase patterns: the five precedents this task should copy, named

1. **`PlusLanguage/Axioms.lean` + `Derivation.lean` — the per-constructor cost model.** `PlusAxiom`
   is a closed inductive; exactly three declarations pattern-match on it (`minFrameClass`, and the
   two dispatch lemmas in `Conservativity/Plus/AxiomValidity.lean`), neither dispatch lemma has a
   wildcard arm. `PlusDerivationTree` is a 7-rule mirror of `ProofSystem.DerivationTree`, with
   `⊡`-necessitation **derived** (`stabNecessitation`) rather than an eighth rule. `PlusAxiom.ofTM`
   is the constructor-to-constructor embedding, every arm `rfl`-shaped.
2. **`StarLanguage/{Axioms,Derivation}.lean` + `Conservativity/Star/*` — the full-shape
   precedent, and the cost measurement.** TM⋆ re-declares the same 53 TM⁺ schemata and adds its
   own block; `StarAxiomValidity.lean` is 1,479 lines, `StarSoundness.lean` 177,
   `Star/Forward.lean` 236. Its docstring states, in terms, why neither atomization nor uniform
   substitution is available — both reasons transfer verbatim to L^▷.
3. **`MinusLanguage/AxiomDischarge.lean` (385 lines) — the discharge-table precedent.** A
   layer-0, semantics-free lookup table producing a target-system derivation of the translation of
   every source axiom, consumed by `Conservativity/Backward.lean`'s `translate`. This is the exact
   shape the `eraseOpen` discharge table should take — and the L^▷ table is far cheaper than the
   L⁻ one, because `eraseOpen` commutes with every constructor and with every derived operator
   (`rfl`), so there is no `F`/`P` bridge problem of the kind that made twelve L⁻ rows inexact.
4. **`Metalogic/Deterministic/Erasure.lean` — the collapse precedent, lemma for lemma.**
   `erasePlus : PlusFormula → Formula`, `erasePlus_ofFormula`, `erasePlus_reflectTime`,
   `plusTruthAt_erasePlus_of_deterministic`, and the validity-level corollary pair. The L^▷
   collapse should mirror these five names exactly; probe 01 does.
5. **`Conservativity/Plus/Forward.lean` and `Star/Forward.lean` — the row structure.** Forward over
   TM is soundness + truth transfer + a `WeakCompleteness` engine, instantiated at all four
   classes. The L^▷ row over TM composes `openValid_ofPlus_iff` (landed) with
   `plusValidIn_ofFormula_iff` (landed) and the four engines.

### The schema set, with its soundness witness and its erasure image

Every `OpenValid` name below is **already landed** in `FormalSystem/OpenLanguage/`; the task adds
the constructor, the `minFrameClass` arm, the two dispatch arms and the discharge arm, not the
mathematics. "Image" is `eraseOpen` of the schema; "discharged by" names the TM⁺ asset.

| Schema | Landed validity | Image | Discharged by |
|---|---|---|---|
| `▷`-K `▷(φ→ψ) → (▷φ → ▷ψ)` | `openValid_ofut_k` | `(φ°→ψ°) → (φ°→ψ°)` | `plusIdImp` |
| `▷`-T `▷φ → φ` | `openValid_ofut_t` | `φ° → φ°` | `plusIdImp` |
| `▷`-4 `▷φ → ▷▷φ` | `openValid_ofut_four` | `φ° → φ°` | `plusIdImp` |
| `▷`-5 `▷̂φ → ▷▷̂φ` | `openValid_ofut_five` | `¬¬φ° → ¬¬φ°` | `plusIdImp` |
| `◁`-K/T/4/5 | `openValid_opast_{k,t,four,five}` | same four shapes | `plusIdImp` |
| `□φ → ⊡φ` | `openValid_stab_of_box` | itself | `PlusAxiom.box_stab` |
| `⊡φ → ▷φ` | `openValid_ofut_of_stab` | `⊡φ° → φ°` | `PlusAxiom.stab_t` |
| `⊡φ → ◁φ` | `openValid_opast_of_stab` | `⊡φ° → φ°` | `PlusAxiom.stab_t` |
| HN `Pα → ▷P▷̂α` | `hnOpen_openValid` | `Pα° → P¬¬α°` | `somePastMono (impNegImp …)` via `plusDerivable_substPlus_nil` |
| HN mirror `Fα → ◁F◁̂α` | `openValid_hnOpenPast` / `hnOpenMirror_openValid` | `Fα° → F¬¬α°` | the time reflection of the HN arm |
| definability `⊡φ → ▷◁φ` | `openValid_stab_imp_ofut_opast` | `⊡φ° → φ°` | `PlusAxiom.stab_t`; **also derivable** in the system from `stab_4`, the two bridges, `▷`-K and derived `▷`-necessitation, so it need not be a constructor at all |
| rigidity `◁φ⁺ → φ⁺`, `φ⁺ → ◁φ⁺` (`φ⁺` pure-future) | `PlusLanguage.truth_congr_agreeFrom` (semantic half) | `φ° → φ°` both ways | `plusIdImp` |
| rigidity `▷ψ⁻ → ψ⁻`, `ψ⁻ → ▷ψ⁻` (`ψ⁻` pure-past) | `PlusLanguage.truth_congr_agreeUpTo` (semantic half) | `ψ° → ψ°` both ways | `plusIdImp` |
| **definability `▷◁φ → ⊡φ`** | `openValid_ofut_opast_imp_stab` | `φ° → ⊡φ°` = ***Determined*** | **nothing — refuted** |

Do **not** state HN for `⊡` (`hnStab` is refuted on `sinkFrame`); do **not** state the converses
of the bridges (five landed `not_openValid_*` refutations); `▷` and `◁` are incomparable
(`not_openValid_opast_of_ofut`, `not_openValid_ofut_of_opast`), so no cross-bridge is available.

### Probe 01, compiled-live: what is now machine-checked

`specs/856_open_language_proof_system_and_soundness/probes/01_erasure-collapse-and-discharge.lean`,
namespace `Probe856R01`; exit 0, no sorry, no error, no warning, compiled against the
repository's own oleans.

1. `eraseOpen`, `eraseOpen_ofPlus` (retraction of `ofPlus`), `eraseOpen_reflectTime`, plus four
   `rfl` pins showing erasure commutes with `neg`, `somePast`, `dofut` and `dstab`.
2. `openTruthAt_eraseOpen_of_deterministic` — **the *Determined* collapse**, by induction with the
   history and time binders inside the statement, exactly as `erasePlus`'s counterpart. Determinism
   is consumed **only** in the `ofut`/`opast` cases, through `states_eq_of_deterministic` and the
   landed `truth_congr_ext`; the `stab` case is structural because `eraseOpen` keeps `⊡`.
   Axioms: `[propext]` — choice-free.
   `openTruthAt_erasePlus_eraseOpen_of_deterministic` composes it with
   `plusTruthAt_erasePlus_of_deterministic` to land in L.
3. Nine discharge arms as actual `PlusDerivationTree` terms: `discharge_ofut_{k,t,four,five}`,
   `discharge_opast_t`, `discharge_{ofut,opast}_of_stab`, `discharge_stab_of_box`,
   `discharge_rigidity_fwd`, `discharge_definability_fwd`, plus `plusIdImp` (the identity
   combinator from `prop_k`/`prop_s`).
4. `discharge_hnOpen` — the HN arm, the only one that is not a one-liner: the TM theorem
   `P p → P ¬¬p` (`Theorems.TemporalDerived.somePastMono` of
   `Theorems.Propositional.impNegImp`) transported to arbitrary L⁺ arguments by
   `plusDerivable_substPlus_nil`. The substituted statement is **definitionally** the erasure of
   `hnOpen α`, so the arm is `exact`.
5. `definability_bwd_erasure_eq` (an `rfl`: at `φ := Fp` the erasure of `▷◁φ → ⊡φ` is literally
   `Fp → ⊡Fp`) and `definability_bwd_erasure_not_plusValid` (that formula is not L⁺-valid, by
   `refute_determined`). Since TM⁺ is sound, the image is not a TM⁺ theorem at any class.

### What the architecture has to look like

| File | Layer | ~Lines | Contents |
|---|---|---|---|
| `FormalSystem/OpenLanguage/OpenAxioms.lean` | 0 | 450 | `OpenAxiom`: 53 re-declared TM⁺ schemata + the ~13 ▷/◁ constructors; `OpenAxiom.minFrameClass`; `rfl` pins. Imports `OpenLanguage.Formula` and `ProofSystem.Axioms` only |
| `FormalSystem/OpenLanguage/OpenDerivation.lean` | 0 | 320 | `OpenDerivationTree` (the same 7 rules), `lift`, `height`, `ofWeakeningNil`, the height lemmas, `OpenDerivable`, notation, derived `stabNecessitation` and derived `ofutNecessitation`/`opastNecessitation`, `OpenAxiom.ofPlus` + `minFrameClass_ofPlus`, `OpenDerivationTree.ofPlus`, `openDerivable_of_plusDerivable` — **backward conservativity over TM⁺, free** |
| `FormalSystem/OpenLanguage/OpenErasure.lean` | 0 | 420 | `eraseOpen`, retraction, `reflectTime` commutation, purity-transport, the **discharge table** (one arm per constructor), `OpenDerivationTree.erase`, `plusDerivable_of_openDerivable` — **forward conservativity over TM⁺, unconditional and semantics-free** |
| `FormalSystem/Metalogic/Conservativity/Open/OpenAxiomValidity.lean` | 3 | 1,400 | `openAxiom_validIn_min` and `openAxiom_reflect_time_validIn_min`, no wildcard arm. The ▷/◁ arms are the landed `openValid_*` names; the ◁ arms go through `openValid_reflectTime`; the 53 mirror arms are fresh proofs against `OpenTruthAt` |
| `FormalSystem/Metalogic/Conservativity/Open/OpenSoundness.lean` | 3 | 190 | the companion recursion over `OpenDerivationTree`, `open_soundness_validIn` |
| `FormalSystem/Metalogic/Conservativity/Open/Forward.lean` | 3 | 220 | the TM row (`forward_open` + four engine instantiations + `openDerivable_ofFormula_iff`), and the **TM⁺ row in both directions** by composing `openDerivable_of_plusDerivable` with `plusDerivable_of_openDerivable` and `eraseOpen_ofPlus` |
| `FormalSystem/Metalogic/Deterministic/OpenCollapse.lean` | 3 | 220 | probe 01's §2 promoted, plus the validity-level corollaries and the recovery of `detCompleteness*` through the composite erasure |

`OpenLanguage.lean` and `Metalogic/Conservativity.lean` (plus a new `Conservativity/Open.lean`)
take the import rows. Note that the task's recorded `file_scope` names only `OpenAxioms.lean`,
`OpenDerivation.lean`, the README, the partition script and the theorem index: the four
`Metalogic/` files above are outside it. `file_scope` is descriptive and never validated, so this
is a note for the plan, not a blocker.

### Gates and ledgers, concretely

- **`LANGUAGE_FILE_LAYERS`** (`scripts/measure-refactor-partitions.py`, the `"OpenLanguage"` dict):
  add `"OpenAxioms": 0, "OpenDerivation": 0, "OpenErasure": 0` **in the same phase as the files**,
  or `check-metalogic-cycles.sh` fails naming them. The script also asserts that **no layer-0 file
  imports a layer-1 file**, which is exactly why the discharge table belongs in `OpenErasure.lean`
  at layer 0 (it needs `PlusDerivationTree` and `Theorems/`, never `OpenTruth`) and why the
  validity dispatch must live under `Metalogic/`.
- **`docs/theorem-index.md`**: one row per result — paper label (`—` for all of these; the
  manuscript supplies no logic for the restricted modals), one-line statement, **fully qualified**
  Lean name, file path with no line numbers, frame class, measured axiom set. The OpenLanguage
  section's standing sentence "L^▷ is **semantic only**" must be rewritten, as must the same
  sentence in `FormalSystem/OpenLanguage/README.md`.
- **C14 baseline pair** (`scripts/check-module-invariants.sh`): every `pinned:C14` row needs **two**
  edits — a line in the `C14_BASELINE` heredoc and a matching `#print axioms` line in the Lean
  heredoc; they are compared by exact string equality. Pin at least: the soundness terminus, the
  four conservativity rows, the collapse, and the HN/erasure termini. Expected profiles, from the
  probe: the collapse `[propext]`; the discharge arms `[propext, Quot.sound]`; anything consuming
  `refute_determined` or `OpenValid.of_forall_regular` picks up `Classical.choice`.
- **README inventory**: regenerate, never hand-edit —
  `bash scripts/check-module-invariants.sh --emit-inventory`.
- **Build**: guarded scoped build of `FormalSystem.OpenLanguage` per phase, then the unscoped build
  for final verification; `bash scripts/check-module-invariants.sh` (bare) and
  `bash scripts/check-metalogic-cycles.sh` both green.

### Recommendations

- **R1. Phase by block, smallest-first, with the cheap wins first.** Suggested decomposition:
  (1) `OpenAxioms.lean` ▷/◁ block + `minFrameClass`; (2) the 53 re-declared constructors +
  `rfl` pins; (3) `OpenDerivation.lean` + backward conservativity; (4) `OpenErasure.lean` erasure +
  retraction + reflection + purity transport; (5) the discharge table (ships probe 01's arms
  verbatim) + forward conservativity over TM⁺; (6–9) `OpenAxiomValidity.lean` in four blocks;
  (10) `OpenSoundness.lean`; (11) `Forward.lean` rows over TM; (12) the *Determined* collapse +
  all ledger surfaces.
- **R2. Promote probe 01 rather than re-deriving it.** Its §1, §2 and §3 are the intended contents
  of `OpenErasure.lean` and `OpenCollapse.lean`; the names were chosen to mirror `erasePlus`'s.
- **R3. State the two rigidity schemata as implication pairs, not biconditionals.** Each half then
  erases to an identity and discharges in one line; a biconditional would need and-introduction in
  TM⁺ for no gain.
- **R4. Define the `OpenFormula` purity predicates so that erasure preserves them.** The
  re-declared `paste` and `untl_paste` carry `IsPureFuture`/`IsPurePast` side conditions, so
  `IsPureFutureOpen`/`IsPurePastOpen` are needed. Admit `▷ψ` as pure-past (and `◁ψ` as pure-future)
  **only when `ψ` is itself pure** — recursive, not a blanket leaf clause. A blanket clause is
  semantically true (`▷ψ` is past-determined, 854's `ofut_pastDet`) but breaks
  `IsPurePastOpen φ → IsPurePast (eraseOpen φ)` and with it the discharge table.
- **R5. Add no necessitation rule for `▷` or `◁`.** Both are derived: `necessitation` → `box_stab`
  → the bridge. Keeping the 7-rule mirror is what makes `ofPlus`, `erase` and the soundness
  recursion one case per rule.
- **R6. Say the class split in every docstring that mentions novelty.** At `.ZTime`/`.RTime` this
  system is a notational variant of TM⁺ by 854; the extension is real at `.Base`/`.Dense` by 859.
- **R7. Do not attempt the atomization or uniform-substitution shortcut for the 53 validity arms.**
  Both are closed, for reasons already recorded in `StarAxiomValidity.lean`'s docstring; budget the
  ~1,400 lines instead. A deferred optimisation exists — generic schema-validity lemmas over
  `[TruthEnv L] [StabClauses L]` in `Semantics/TruthClauses.lean`, which would serve L⁺, L⋆ and
  L^▷ at once — but it is a cross-language refactor, not part of this task.

## Decisions

- **D1. `▷◁φ → ⊡φ` is NOT an `OpenAxiom` constructor.** It stays the landed validity
  `openValid_ofut_opast_imp_stab`. Rationale: machine-checked in probe 01 — its erasure is
  *Determined*, refuted; admitting it forfeits unconditional forward conservativity over TM⁺ and
  leaves only a conditional on TM⁺ completeness, which is false at `.Base`
  (`plus_incomplete_base`). The task's "definability equation makes it statable" premise is
  corrected here. Nothing in scope needs the schema: completeness is explicitly out of scope, and
  the `→` half is derivable in the system anyway.
- **D2. Forward conservativity over TM⁺ goes through `eraseOpen`, syntactically, at layer 0** — not
  through soundness plus an engine. This is the only available route: 859 rules out a
  truth-preserving translation at `.Base`, and no TM⁺ engine exists.
- **D3. Conservativity over TM is also delivered**, as the stronger composition
  (`openDerivable_ofFormula_iff` at all four classes), mirroring `Star/Forward.lean` Row 1. It is
  cheap once soundness is in and is the row a reader will look for.
- **D4. The 53 TM⁺ schemata are re-declared, not embedded.** An `ofPlus`-embedding constructor
  yields only ▷-free instances; MF at `▷p` (`□▷p → □G▷p`) is needed. Same argument as
  `PlusAxiom`'s own docstring makes for `ofTM`.
- **D5. The collapse is stated via `eraseOpen`, and `⊡` is not erased by it.** `eraseOpen` deletes
  `▷`/`◁` only; the L-level collapse is the composition with `erasePlus`. This keeps
  `OpenFormula.stab` primitive, as the task requires, and keeps the collapse's `stab` case
  structural.

## Risks & Mitigations

| Risk | Severity | Mitigation |
|---|---|---|
| The ~1,400-line validity dispatch is one file and one phase would overflow | High | Split by schema block across four phases (R1); the two dispatch lemmas can be `sorry`-free per block only if the file compiles as a whole, so stage them as `partial`-closing phases that each add arms and keep the file green by ordering the inductive's constructors to match |
| A constructor added later silently escapes the discharge table | Medium | The discharge table has no wildcard arm, exactly like the two dispatch lemmas; the extension recipe for `OpenAxiom` is therefore **four** arms per constructor, not three. Record that in `OpenAxioms.lean`'s docstring |
| Purity side conditions break the discharge table | Medium | R4: recursive ▷/◁ clauses in the purity predicates, with `IsPurePastOpen φ → IsPurePast (eraseOpen φ)` proved in the same phase as the predicates |
| A reader takes conservativity over TM⁺ for a completeness result | Medium | State in `Forward.lean`'s docstring that conservativity here is a consequence of the axiom choice — the system is deliberately weak on ▷ — and that `blc` stays a non-theorem, `plus_incomplete_base` stands, and an LC_n-style schema is still required |
| Axiom-profile regression (picking up `Classical.choice` where the semantic half was choice-free) | Low | Probe 01 measures the collapse at `[propext]`; pin it in C14 at that value and compare each lifted terminus against the semantic half it lifts |
| `file_scope` omits the four `Metalogic/Conservativity/Open/` files | Low | Note it in the plan; `file_scope` is descriptive and never validated. Sibling task 852 is scoped to `Metalogic/Decidability/RaySummary/` and 865 is unscoped — re-read any shared file immediately before editing |

## Tactic Survey Results

The probe's goals were discharged by explicit term-mode proofs rather than tactic search, which is
what the surrounding modules do; the survey below records what was tried at the two goals where a
tactic was a candidate.

| Goal | Tactic | Result | Premises/Config |
|---|---|---|---|
| `eraseOpen (ofPlus φ) = φ` (7 cases) | `simp only [ofPlus, eraseOpen, ih…]` | success | per-case induction hypotheses, mirroring `erasePlus_ofFormula` |
| `eraseOpen φ.reflectTime = (eraseOpen φ).reflectTime` (9 cases) | `simp only [OpenFormula.reflectTime, eraseOpen, PlusFormula.reflectTime, ih…]` | success | the two `ofut`/`opast` cases need only `eraseOpen` + `ih` |
| the collapse's `untl`/`snce` cases | `exists_congr`/`and_congr_right`/`forall_congr'` chain | success | copied from `plusTruthAt_erasePlus_of_deterministic`; no automation needed |
| the collapse's `ofut`/`opast` cases | explicit `constructor` + `truth_congr_ext` | success | `states_eq_of_deterministic hD (hag t le_rfl)` |
| HN discharge `Pα° → P¬¬α°` | `exact plusDerivable_substPlus_nil σ htm` | success | `somePastMono (impNegImp (atom p) bot)`; the substituted statement is definitionally the target, so no `rw`/`simp` is needed |
| the nine one-line arms | `plusIdImp` / `.axiom … (FrameClass.base_le fc)` | success | `prop_k`, `prop_s`, `stab_t`, `box_stab` |

`aesop`, `omega`, `decide` and `norm_num` were not applicable: every goal is either a syntactic
identity over an inductive family or a `Type`-valued derivation term.

## Context Extension Recommendations

- **Topic**: the axiom-discharge-table pattern as a repository-wide architecture, not a per-language
  accident.
  **Gap**: three languages now use it or should (`MinusLanguage/AxiomDischarge.lean`,
  `Metalogic/Deterministic/Erasure.lean` + `System.lean`, and the proposed `OpenErasure.lean`), and
  no context file states the criterion that decides when it is available: *a translation gives
  unconditional forward conservativity iff every source-axiom image is a target theorem*, which is
  exactly what closed the two L⋆ candidates and what forces D1 here.
  **Recommendation**: add `context/project/lean4/patterns/conservativity-routes.md` recording the
  three routes (constructor embedding; semantic soundness + a target engine; syntactic
  erasure/discharge), the per-route prerequisite, and the four landed instances.
- **Topic**: the per-constructor cost model for a re-declared axiom type.
  **Gap**: `PlusLanguage/README.md`'s recipe says three arms per constructor. With a discharge
  table in the picture it is four, and the fourth is the one that can be *impossible* rather than
  merely laborious.
  **Recommendation**: extend that recipe (and mirror it in `OpenAxioms.lean`'s docstring) to name
  the discharge arm as a first-class obligation.

## Appendix

**Compile command (exit 0, no sorry, no warning)**

```bash
LP=.lake/build/lib/lean; for d in .lake/packages/*/.lake/build/lib/lean; do LP="$LP:$d"; done
LEAN_PATH="$LP" ~/.elan/toolchains/leanprover--lean4---v4.33.0-rc1/bin/lean \
  specs/856_open_language_proof_system_and_soundness/probes/01_erasure-collapse-and-discharge.lean
```

**Measured axiom profiles (probe 01)**

```
Probe856R01.openTruthAt_eraseOpen_of_deterministic            [propext]
Probe856R01.openTruthAt_erasePlus_eraseOpen_of_deterministic  [propext]
Probe856R01.eraseOpen_reflectTime                             [propext]
Probe856R01.discharge_hnOpen                                  [propext, Quot.sound]
Probe856R01.definability_bwd_erasure_not_plusValid            [propext, Classical.choice, Quot.sound]
```

**Searches used**
- `grep` for declaration headers in all six `OpenLanguage/` files, `PlusLanguage/{Axioms,Derivation,Substitution}.lean`, `Theorems/{TemporalDerived,Propositional/Core,GeneralizedNecessitation}.lean`.
- `grep` for `IsPureFuture`/`IsPurePast`, `truth_congr_ext`, `states_eq_of_deterministic`, `stab_state_only`, `AgreeUpTo`, `refute_determined`, `plusDerivable_substPlus_nil`.
- `wc -l` on `Conservativity/{Plus,Star}/*` and `MinusLanguage/*` for the cost measurements.
- `grep` for `LANGUAGE_FILE_LAYERS` and `C14` in `scripts/`, and for the OpenLanguage rows of `docs/theorem-index.md`.
- lean-lsp: not used for search; every name was read from its declaring file and every claim compiled.

**References**
- `specs/854_open_future_modal_lplus_definability/reports/01_open-future-definability-verdict.md` (positive at `.ZTime`/`.RTime`).
- `specs/859_qtime_open_future_definability_base_dense/reports/01_qtime-open-future-definability.md` (negative at `.Base`/`.Dense`).
- `FormalSystem/PlusLanguage/README.md` — "Extension recipe: adding a `PlusAxiom` constructor".
- `FormalSystem/Metalogic/Conservativity/Star/Forward.lean` — the unconditional-over-TM / conditional-over-TM⁺ row pair, and "Why there is no syntactic route" for L⋆.
- `FormalSystem/Metalogic/Independence/PlusIncompleteness.lean` — `plus_incomplete_base`, `not_plus_complete_base`.
