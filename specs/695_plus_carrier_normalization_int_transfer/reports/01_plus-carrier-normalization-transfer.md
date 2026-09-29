# Research Report: Task #695

**Task**: 695 - plus_carrier_normalization_int_transfer
**Started**: 2026-09-28T22:31:24Z
**Completed**: 2026-09-28T23:14:00Z
**Effort**: small (the whole route is machine-verified below; the remaining work is siting,
docstrings and gate bookkeeping, not mathematics)
**Dependencies**: None
**Sources/Inputs**:
- Codebase: `FormalSystem/Semantics/IntTransfer.lean`, `FormalSystem/Semantics/TruthTransport.lean`,
  `FormalSystem/Semantics/TruthClauses.lean`, `FormalSystem/Semantics/Frames/TranslationProduct.lean`,
  `FormalSystem/PlusLanguage/PlusTruth.lean`, `FormalSystem/PlusLanguage/PlusValidity.lean`,
  `FormalSystem/PlusLanguage/README.md`, `FormalSystem/PlusLanguage.lean`
- Gate sources: `scripts/check-module-invariants.sh` (C2, C8, C14, C15, C17, C28, C33, C34),
  `docs/theorem-index.md`, `docs/development/CI_CD_PROCESS.md`
- Tooling: `lake env lean` against the built library (`#print axioms`); no Mathlib search tool
  was needed — every API used is already in `IntTransfer.lean`
- No literature source is referenced by this task, so the literature-extraction protocol does not apply
**Artifacts**:
- `specs/695_plus_carrier_normalization_int_transfer/reports/01_plus-carrier-normalization-transfer.md`
- `specs/695_plus_carrier_normalization_int_transfer/probes/01_plus_int_transfer_probe.lean`
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The route is not a conjecture any more. It is compiled.** A 111-line probe
  (`specs/695_plus_carrier_normalization_int_transfer/probes/01_plus_int_transfer_probe.lean`)
  proves both `plusTruthAt_map` (the seven-case `PlusFormula` twin of `Semantics.truthAt_map`) and
  `plusValidZTime_iff_plusValidInt` against the built library with `lake env lean`: **zero errors,
  zero warnings, zero sorries, no new axiom**. `#print axioms` reports
  `[propext, Classical.choice, Quot.sound]` (`pcq`) for both.
- **Take the direct seven-case `plusTruthAt_map`, not a `PlusTruthCorr` structure.** The decisive
  reason is not proof length — the seven-case induction is paid either way, because `PlusTruthAt`
  is a native recursion on a *different* inductive and cannot delegate to
  `Truth.truthAt_of_truthCorr` for any constructor except `atom`. It is that
  `Semantics/TruthClauses.lean`'s design contract already forbids the generic home such a
  structure would want ("**No recursor** … Nothing provable only by `induction φ` belongs here"),
  and the repository's three landed L⁺/L⋆ transports (`plusTruthAt_timeShift`, `plus_invariance`,
  `star_invariance`) are all direct inductions for exactly this reason, which `PlusTruth.lean`'s
  own module docstring records.
- **The `stab` case is as cheap as the task description predicted, and cheaper than the `box` case.**
  Because `(FrameOver.map F e).toTaskFrame.WorldState` is *definitionally* `F.WorldState`, both
  sides of the state-agreement side condition are the **same** equation in one type; the bridge is
  two `rfl`-adjacent facts (`σ'.state (e t) = σ.state t` from `Aligned`, and
  `ρ'.state (e t) = (WorldHistory.comap e ρ').state t` by `rfl`). No `HEq`, no transport, no
  world-state bijection.
- **Siting recommendation: a new module `FormalSystem/PlusLanguage/PlusIntTransfer.lean`.**
  This extends the task's declared `file_scope`, which names no new file — see *Decisions* D3 and
  the enumerated gate consequences in *Findings → Gate and bookkeeping surface*.
- **Two gate facts the plan must carry.** (i) `validZTime_iff_validInt`, the L-side twin, is
  **not** itself pinned by C2 or C14 and has **no** `docs/theorem-index.md` row, so this task
  creates the L⁺ pin first — an asymmetry worth a deliberate decision (D5). (ii) C2 does **not run
  in CI** (`--no-build` mode; `docs/development/CI_CD_PROCESS.md`, "Known Not-in-CI Gaps"), so the
  new pin fires only in the full local gate.

## Context & Scope

Researched: whether `plusValidZTime_iff_plusValidInt` is reachable today, by which of the two
shapes the task description leaves open, where the declaration should live, and what the
zero-debt deliverable (C2 pin + `docs/theorem-index.md` row, zero sorries, no new axiom) costs in
gate bookkeeping.

Constraints honoured: no library file was created or edited — this is the research phase, and
`FormalSystem/**` edits belong to implementation. Verification was done with a task-scoped probe
under `specs/695_.../probes/`, compiled with `lake env lean` against the existing `.olean`
artifacts. No sibling task's declared `file_scope` was touched (siblings 697–700 own
`scripts/typst-*.sh`, `typst/generated/status.typ`, `specs/state.json`, and their own task
directories).

## Findings

### The verified route (machine-checked, not sketched)

`specs/695_plus_carrier_normalization_int_transfer/probes/01_plus_int_transfer_probe.lean`,
111 lines, compiles clean. It declares, in `namespace FormalSystem.PlusLanguage`:

1. `plusTruthAt_map (e : ↑D ≃+o ↑E) (M : TaskModel F.toTaskFrame) (φ : PlusFormula)` —
   `∀ σ σ', Aligned e σ σ' → ∀ t, PlusTruthAt M σ t φ ↔ PlusTruthAt (TaskModel.map M e) σ' (e t) φ`
2. `PlusValidInt (φ : PlusFormula)` — binder-for-binder `ValidInt`, over `FrameOver intOrder`
3. `plusValidZTime_iff_plusValidInt (φ : PlusFormula) : PlusValidZTime φ ↔ PlusValidInt φ`

Declaration (3) is `validZTime_iff_validInt`'s proof **line for line**, with `truthAt_map`
replaced by `plusTruthAt_map`: the same `sat_intro hF`, the same
`let e : ↑F.Duration ≃+o ↑intOrder := intIso`, the same `(D := F.Duration) (E := intOrder)
(F := F.toFibre)` ascriptions (still needed for the same recorded reason — Lean cannot invert
`↑E ≟ ℤ` to recover `E := intOrder`), and the same `⟨inferInstance,
TaskFrame.isZTime_of_instances _⟩` in the forward direction.

`#print axioms`, emitted by the probe itself:

```
'FormalSystem.PlusLanguage.plusTruthAt_map' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.PlusLanguage.plusValidZTime_iff_plusValidInt' depends on axioms: [propext, Classical.choice, Quot.sound]
```

### Codebase Patterns

**The six inherited cases cannot delegate, except `atom`.** `Truth.truthAt_of_truthCorr` is an
`induction φ` over `Formula`; `PlusTruthAt`'s `box`/`untl`/`snce` clauses recurse on
`PlusFormula` arguments, so there is no `Formula` to hand the generic lemma at any of them. The
one case that *does* delegate is `atom`, and the probe delegates it: `(alignedCorr e M).atom σ σ' h t p`
discharges it outright, because `alignedCorr`'s `Rel` field **is** `Aligned e` and its `atom`
field is exactly the valuation agreement wanted. (A `have I := alignedCorr e M` binding does
*not* work — `I.Rel σ σ'` then fails to unify with `Aligned e σ σ'`; the instance must be written
inline so the projection reduces.) This is the one genuine reuse available and it is taken.

**`map_lt_map_iff e` and `e.surjective` are the only order API the temporal cases need**, both
already used by `FrameOver.map` in `IntTransfer.lean`. The `untl`/`snce` cases are
`truthAt_of_truthCorr`'s bodies with `I.dur.lt_iff_lt` → `map_lt_map_iff e` and
`I.dur.surjective` → `e.surjective`.

**The `stab` case, in full.** Goal after `intro σ σ' ha t`:

```
(∀ ρ, σ.state t = ρ.state t → PlusTruthAt M ρ t a)
  ↔ (∀ ρ', σ'.state (e t) = ρ'.state (e t) → PlusTruthAt (TaskModel.map M e) ρ' (e t) a)
```

One shared fact, `hσ : σ'.state (e t) = σ.state t`, from `ha (e t)` rewritten by
`e.symm_apply_apply`. Then:

- forward: witness `WorldHistory.comap e ρ'`, related by `aligned_comap e ρ'`; the state bridge
  `ρ'.state (e t) = (WorldHistory.comap e ρ').state t` holds **by `rfl`**, because
  `PartialHistory.comap`'s `states` field is literally `fun t h => σ'.states (e t) h`;
- backward: witness `ρ.map e`, related by `aligned_map e ρ`; the state bridge
  `(ρ.map e).state (e t) = ρ.state t` is `show ρ.state (e.symm (e t)) = ρ.state t` closed by
  `e.symm_apply_apply`.

Both side conditions then follow from the hypothesis by rewriting with `hσ` and the bridge. This
is the entire cost of the seventh clause: eight lines.

**Placement precedent.** `FormalSystem/PlusLanguage/README.md`'s "Syntax before semantics"
section states the rule: L⁺'s *semantic* modules (`PlusTruth`, `PlusValidity`, `PlusPasting`,
`PlusNonValidities`, `PlusDeterminism`, `PlusStateLocal`, `PlusLimitClosure`) live in
`PlusLanguage/`, and only genuine **two-family** bridges stay at the `Semantics/` root —
it names exactly two (`Semantics/DeterministicBridge.lean`, `Semantics/StateLocalTransfer.lean`).
An L⁺-only carrier normalization is not a two-family bridge.

**Namespace.** `FormalSystem.PlusLanguage`, verified by `#check`: `PlusTruthAt` and
`PlusValidZTime` are both `FormalSystem.PlusLanguage.*`, as are `plusTruthAt_ofFormula` and
`plusTruthAt_timeShift`. (`ValidInt` / `validZTime_iff_validInt` are `FormalSystem.Semantics.*`;
that asymmetry is correct — the L side's namespace is `Semantics`.) C2's own baseline already
carries `'FormalSystem.PlusLanguage.plusValidIn_ofFormula_iff'`-shaped names via C14, so a
`FormalSystem.PlusLanguage.` prefix is nothing new to the harness.

**Import direction is clean, verified mechanically.** The transitive `FormalSystem.*` import
closure of `Semantics.IntTransfer` is 26 modules and contains **no** `PlusLanguage.*` and no
`StarLanguage.*` module, so `PlusLanguage/PlusIntTransfer.lean` may import
`FormalSystem.Semantics.IntTransfer` with no cycle. Only two live modules import
`Semantics.IntTransfer` today: `FormalSystem/Semantics.lean` (the aggregator) and
`FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Family.lean`.

### External Resources

No Mathlib search was required. Every external lemma the route uses is already imported and used
by `Semantics/IntTransfer.lean`: `map_lt_map_iff`, `OrderAddMonoidIso`'s
`symm_apply_apply`/`apply_symm_apply`/`surjective`, and `≃+o` itself (`Mathlib.Algebra.Order.Hom.Monoid`).
`intIso` is local (`Semantics/DurationClassification.lean`). The recorded trap in
`IntTransfer.lean`'s docstring — `linarith` does not fire on the bare `AddCommGroup` +
`LinearOrder` bundle — never arises here, because the temporal cases go through
`map_lt_map_iff`, not arithmetic.

### Gate and bookkeeping surface

Everything below was read out of `scripts/check-module-invariants.sh` and confirmed against a
`--no-build` run of it.

**C2 (the required pin)** — four coordinated edits in `scripts/check-module-invariants.sh`:

1. the `AXIOM_BASELINE` heredoc gains, verbatim,
   `'FormalSystem.PlusLanguage.plusValidZTime_iff_plusValidInt' depends on axioms: [propext, Classical.choice, Quot.sound]`
   (the comparison is exact string equality on the whole block, so **order matters** — append at
   the end unless the `#print axioms` order is changed in step 2 to match);
2. the `AX_SRC` heredoc gains `#print axioms FormalSystem.PlusLanguage.plusValidZTime_iff_plusValidInt`
   **in the same position**;
3. `pass C2 "all fourteen pinned axiom sets match baseline"` → `"all fifteen …"` (this is the only
   place in the repository where C2's row count is spelled out — `grep -rn fourteen` confirms it);
4. the C2 block's header prose ("The first four rows are the completeness/countermodel flagships.
   The ten that follow pin the branching witness-family stack…") gains a clause for the
   fifteenth row.

**C15, second assertion** — every `docs/theorem-index.md` row must carry its anchor at the
declaration. The new declaration's own `/-- … -/` block therefore MUST contain a line matching
`^\s*Paper: (.+)$` whose value **starts with `— (`** (since the row's Paper-label cell will be
`—`). The landed model to copy is in `PlusValidity.lean`:
`Paper: — (formalization-native; L⁺ is the ⊡-only fragment of the paper's \BL^\star, for which the paper supplies no logic)`.
Omitting this line is a hard C15 failure, not a style nit.

**C33 + `lake exe mk_all`** — a new file requires the repository-root `FormalSystem.lean` to be
regenerated (`lake exe mk_all --lib FormalSystem`); C33 asserts it is byte-current and runs even
under `--no-build`, so this cannot be deferred.

**Aggregator and README bookkeeping** for a new file: `FormalSystem/PlusLanguage.lean` needs the
`import` line **and** a bullet in its `## Semantic modules` list; `FormalSystem/PlusLanguage/README.md`
has a *generated* inventory block (regenerate with
`bash scripts/check-module-invariants.sh --emit-inventory`, verify with `--emit-inventory --check`)
**and** a separate hand-maintained "What it carries" table that needs a row; the root `README.md`
and `FormalSystem/README.md` carry generated `dir=FormalSystem` inventory blocks that the same
`--emit-inventory` run updates.

**C34b — a docstring trap.** `plusTruthAt_map` carries a bracketed `[F.IsRegular]` binder, so it
is in C34b's population. C34b fires when the declaration's own doc block names one of
*Compositionality*, *Seriality*, *Limit*, *Saturation* **and** carries negation or
consumption vocabulary (`not`, `never`, `no`, `without`, `free of`, `independent`, `consumed`,
`spends`, …). `IntTransfer.lean`'s *module* docstring discusses *Limit* and *Saturation* at
length, and copying that prose into the new **declaration** docstring would trip C34b, whose only
remedy is a `Constraints consumed:` marker. Keep constraint names out of the three declaration
doc blocks (module-level `/-! … -/` prose is out of C34b's scope).

**C17 (dead-declaration scan)** is satisfied without extra work: `PlusValidInt` occurs in
`plusValidZTime_iff_plusValidInt`'s statement, `plusTruthAt_map` in its proof, and
`plusValidZTime_iff_plusValidInt` in both `docs/theorem-index.md` and
`scripts/check-module-invariants.sh` (markdown and `scripts/*.sh` are in C17's scope).

**Pre-existing gate red, NOT this task's** — `bash scripts/check-module-invariants.sh --no-build`
already fails C28 at HEAD:
`NEW 1 FormalSystem/Version.lean linter.style.longLine (no baseline entry)`. `Version.lean` is
unmodified in the working tree, so this is committed, pre-existing, and outside 695's
`file_scope`. The implementer must not read it as a regression of their own, and must not
`--update` the warning budget (that would bless it).

**C2 is not run in CI.** `docs/development/CI_CD_PROCESS.md` ("Known Not-in-CI Gaps") records
that CI runs the harness in `--no-build` mode, which skips C1/C2/C6/C24. The new pin therefore
protects the full local gate only.

### Recommendations

1. **Shape: direct seven-case `plusTruthAt_map`.** No `PlusTruthCorr` structure. Reasons in
   *Decisions* D1.
2. **Site: new module `FormalSystem/PlusLanguage/PlusIntTransfer.lean`**, importing
   `FormalSystem.Semantics.IntTransfer` and `FormalSystem.PlusLanguage.PlusValidity`; namespace
   `FormalSystem.PlusLanguage`; three declarations in the order
   `plusTruthAt_map`, `PlusValidInt`, `plusValidZTime_iff_plusValidInt`. Expect ~180–220 lines
   with docstrings (the proof bodies are ~75 lines; the probe is the transcription source).
3. **Lift the probe verbatim.** The plan should treat
   `specs/695_plus_carrier_normalization_int_transfer/probes/01_plus_int_transfer_probe.lean` as
   the source text and spend its effort on docstrings, the `Paper: — (…)` lines, and the
   bookkeeping list above — not on re-deriving proofs. There is **no sorry-free risk left to
   discharge**: the sorry-free path is compiled.
4. **One phase is enough.** The work is a single agent run: create the module, regenerate
   `FormalSystem.lean`, edit the two aggregator/README surfaces, add the C2 rows, add the
   `docs/theorem-index.md` row, then `lake build` + full `check-module-invariants.sh`.
5. **`docs/theorem-index.md` row**: put it in `### Decidability`, immediately **before** the
   `SharingSkeleton.total_eq_thread` row that opens the branching L⁺ stack, since carrier
   normalization is that stack's prerequisite. Cells: Paper label `—`; Lean name
   `FormalSystem.PlusLanguage.plusValidZTime_iff_plusValidInt`; File
   `FormalSystem/PlusLanguage/PlusIntTransfer.lean`; Frame class `ZTime`; Axioms `pcq pinned:C2`.

## Decisions

- **D1 — Direct `plusTruthAt_map`, not a `PlusTruthCorr`.** Three independent reasons, in
  descending force. (a) `Semantics/TruthClauses.lean`'s stated extension contract closes the only
  generic home: "**No recursor.** These classes abstract the truth *relation* and the operator
  *constructors*, not the inductive type. Nothing provable only by `induction φ` belongs here."
  A `PlusTruthCorr` transport is provable only by `induction φ`, so it could not live at the
  abstract clause layer and would have to be a `PlusLanguage`-local structure serving one
  instance. (b) The structure discharges **no** proof obligation: because `PlusTruthAt` recurses
  on `PlusFormula`, the seven-case induction is written either way, and the structure only moves
  it. (c) The repository has decided this three times already, for exactly this reason, and
  recorded it: `plusTruthAt_timeShift` (whose docstring says "proved directly because `TruthCorr`
  is `Formula`-only"), `plus_invariance` and `star_invariance` are all direct inductions.
  *What the rejected option would have cost, for the record*: `TruthCorr` + one field. The minimal
  field is state agreement across the relation,
  `stateAgree : ∀ σ σ' ρ ρ', Rel σ σ' → Rel ρ ρ' → ∀ t, (σ.state t = ρ.state t ↔ σ'.state (dur t) = ρ'.state (dur t))`,
  which `Aligned` satisfies because both sides are the same equation. A world-state map
  (`st : F.WorldState → F'.WorldState` plus `Function.Injective st`) also works but is strictly
  more data — injectivity is needed only in the forward `stab` direction, and `Aligned`'s `st` is
  the identity anyway.
- **D2 — Reuse `alignedCorr` for the `atom` case only.** It is the one constructor where the
  existing `TruthCorr` instance discharges the goal outright; writing it inline (not via `have`)
  is required for the `Rel` projection to reduce.
- **D3 — `file_scope` extension is required and should be recorded in the plan.** The task's
  declared `file_scope` is
  `["FormalSystem/Semantics/IntTransfer.lean", "FormalSystem/Semantics/TruthTransport.lean", "FormalSystem/Semantics/Frames/TranslationProduct.lean", "docs/theorem-index.md", "scripts/check-module-invariants.sh"]`.
  The recommended siting adds `FormalSystem/PlusLanguage/PlusIntTransfer.lean` (new),
  `FormalSystem/PlusLanguage.lean`, `FormalSystem.lean`, `FormalSystem/PlusLanguage/README.md`,
  `FormalSystem/README.md` and `README.md` (the last three are generated-block updates), and
  touches **neither** `TruthTransport.lean` **nor** `TranslationProduct.lean` — those two were
  anticipated as the shape's home and as the template, and D1 retires the first while the second
  is read-only precedent. `file_scope` is descriptive, not filesystem-validated
  (`.claude/rules/state-management.md`), so widening it in the plan is routine.
- **D4 — `PlusValidInt` is a `def`, mirroring `ValidInt`**, with the same eight-binder collapse
  note in its docstring. It is *not* folded into the iff's statement: a named predicate is what
  downstream L⁺ decidability work will quantify over, exactly as `ValidInt` is on the L side.
- **D5 — Open question for the plan (non-blocking): pin the L-side twin too?**
  `validZTime_iff_validInt` is pinned by neither C2 nor C14 and has no `docs/theorem-index.md`
  row. Adding it alongside costs two more lines in each C2 heredoc and one more index row, and
  removes the odd state where the L⁺ twin is ledgered and the L twin it mirrors is not. It is
  **outside** the task's stated deliverable, so the plan should either do it deliberately (C2 goes
  to sixteen rows, and the `"all fourteen"` string becomes `"all sixteen"`) or decline it in one
  sentence. Recommendation: do it — it is the same edit, and the asymmetry is the kind of drift
  C14's existence is a complaint about.

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| C2's baseline is compared by **exact whole-block string equality**; a row appended to one heredoc but not the other, or in a different position, fails the gate with a confusing "diverged" message | Edit `AXIOM_BASELINE` and `AX_SRC` in the same edit, at the same position, and re-run the full (non-`--no-build`) harness before committing. The two heredocs' contract is spelled out in C14's header comment ("Edit them together, appending to both") and holds for C2 identically |
| C15 second assertion fails because the new declaration's doc block has no `Paper:` line | Copy `PlusValidity.lean`'s `Paper: — (formalization-native; …)` form. The row's label cell is `—`, so the value must begin `— (` |
| C34b fires on `plusTruthAt_map` because its docstring inherits `IntTransfer.lean`'s prose about *Limit* / *Saturation* | Keep constraint names out of the three `/-- … -/` blocks; put any such discussion in the module-level `/-! … -/` header, which C34b does not read |
| Forgetting `lake exe mk_all --lib FormalSystem` after adding the file → C33 red | C33 runs build-free and therefore in CI too, so it cannot be missed for long; still, regenerate in the same commit as the new file |
| A `--emit-inventory` run rewrites generated blocks in files outside this task's work (other READMEs) and over-stages | Run `--emit-inventory`, then `git status --short` and stage **only** the inventory blocks this new file actually changed; never `git add -A` or a directory pathspec (`.claude/rules/git-workflow.md`) |
| The pre-existing C28 failure (`FormalSystem/Version.lean`, `linter.style.longLine`) is mistaken for a regression, or "fixed" by `--update` | Recorded above as pre-existing at HEAD and outside `file_scope`. Do not run `warning-budget.py --update`; report the red as inherited |
| Concurrent siblings 697–700 are on the same working tree this cycle | Their declared scopes (`scripts/typst-*.sh`, `typst/generated/status.typ`, `specs/state.json`, own task dirs) are disjoint from this task's, except `specs/state.json` — which only status-sync writes. Re-read before editing, commit only own hunks |
| C2 does not run in CI, so the new pin's protection is local-gate-only | Documented, not fixable here. `docs/development/CI_CD_PROCESS.md` records the upgrade path (drop `--no-build`); out of scope for this task |

## Tactic Survey Results

- Not applicable (no tactic survey performed). The route is entirely structural — a seven-case
  `induction φ` whose cases close by `Iff.rfl`, `Iff.imp`, `constructor`/`refine`, `rintro`, and
  two named rewrites (`e.symm_apply_apply`, `map_lt_map_iff e`). No goal in the probe was a
  candidate for `simp`/`omega`/`aesop`/`decide`/`norm_num`, and none of the LeanHammer portfolio
  was invoked; `lean_multi_attempt` and `lean_hammer_premise` had nothing to bite on. The
  empirical result that matters is stronger than a tactic survey: the whole proof compiles as
  written, with zero warnings, which is recorded above and reproducible with
  `lake env lean specs/695_plus_carrier_normalization_int_transfer/probes/01_plus_int_transfer_probe.lean`.

## Context Extension Recommendations

- **Topic**: The C2/C14 axiom-baseline edit protocol.
- **Gap**: Adding a row to C2 requires four coordinated edits (two heredocs kept positionally
  aligned, one spelled-out count string, one prose paragraph), and the only statement of that
  contract lives in a comment inside C14's block in `scripts/check-module-invariants.sh`. Nothing
  under `.claude/context/project/lean4/` records it, so every task that pins a new theorem
  rediscovers it.
- **Recommendation**: add `context/project/lean4/operations/axiom-baseline-pinning.md` recording
  the four-edit protocol, the exact-string-equality comparison, the `Paper: — (reason)` C15
  obligation that travels with every new `docs/theorem-index.md` row, and the fact that C2 is not
  run in CI.

## Appendix

### Commands run (all read-only except the probe file)

```bash
lake env lean specs/695_plus_carrier_normalization_int_transfer/probes/01_plus_int_transfer_probe.lean
bash scripts/check-module-invariants.sh --no-build
```

### Searches and lookups

- `lean_local_search` / rate-limited Mathlib search tools: **not used** — no new Mathlib lemma is
  needed; the order-isomorphism API the route consumes is already imported and exercised by
  `Semantics/IntTransfer.lean`. Recorded as a deliberate finding, not an omission: the L⁺ twin's
  whole point is that it reuses the L side's transport machinery unchanged.
- `#check` probe confirming fully qualified names: `FormalSystem.PlusLanguage.PlusTruthAt`,
  `FormalSystem.PlusLanguage.PlusValidZTime`, `FormalSystem.Semantics.ValidInt`,
  `FormalSystem.Semantics.validZTime_iff_validInt`.
- Import-closure computation over `Semantics.IntTransfer` (26 modules, no `PlusLanguage.*`,
  `FormalSystem.Init` present — so C24 is satisfied through the existing chain).

### Reference points in the tree

- `FormalSystem/Semantics/IntTransfer.lean` — `FrameOver.map`, `TaskModel.map`,
  `WorldHistory.map`/`comap`, `Aligned`, `aligned_map`, `aligned_comap`, `alignedCorr`,
  `truthAt_map`, `ValidInt`, `validZTime_iff_validInt`
- `FormalSystem/Semantics/TruthTransport.lean` — `TruthCorr`, `Truth.truthAt_of_truthCorr`
- `FormalSystem/Semantics/TruthClauses.lean` — the "No recursor" extension contract
- `FormalSystem/PlusLanguage/PlusTruth.lean` — `PlusTruthAt`'s seven clauses,
  `plusTruthAt_timeShift` (the direct-induction precedent), `stab_state_only`
- `FormalSystem/PlusLanguage/PlusValidity.lean` — `PlusValidZTime`, and the `Paper: — (…)` model
- `FormalSystem/Semantics/Frames/TranslationProduct.lean` — `plus_invariance`, the seven-case
  template the task named
