# Implementation Plan: The nomic operator, its uniformity theorem, and axiom 4

- **Task**: 795 - Formalize the nomic operator and its three results, on the nomic frames of task 794
- **Status**: [IMPLEMENTING]
- **Effort**: 10 hours
- **Dependencies**: Task 794 (completed) — `FormalSystem/Semantics/Nomic/` supplies the frames, law-histories, occurrence, recovery, the ℤ-time presentation and the three hierarchy witnesses
- **Research Inputs**: specs/795_nomic_operator_uniformity_axiom_four/reports/01_nomic-operator-uniformity-axiom-four.md
- **Artifacts**: plans/01_nomic-operator-uniformity-axiom-four.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Land the language half of the paper's nomic appendix on top of task 794's frame-level cluster, in
two places: a new `FormalSystem/Semantics/Nomic/Uniformity.lean` for `thm:nomic-uniform`'s six
conditions (which mention no object language at all), and a new top-level semantic-only component
`FormalSystem/NomicLanguage/` for the operator itself — `NomicFormula`, the truth recursion with
`def:nomic-frame`'s Nomic clause, `prop:nomic-tense-free`'s state-set bridge, validity, seriality,
and `app:nomic-four` over ℤ-time. Nothing nomic-operator-shaped exists in the tree today, so every
phase is additive; four prose sites currently record the operator as deliberately excluded and are
repointed in the final phase, once the formalization they describe exists. Definition of done:
`lake build FormalSystem` green with zero new `sorry` at the end of every phase (the task's stated
constraint), `scripts/check-module-invariants.sh` exits 0, and `bash .claude/scripts/verify-deploy.sh`
exits 0.

### Research Integration

The research report compiled, sorry-free, **every one of the six deliverables** against the built
project in nine `lean_run_code` probes, with `#print axioms` measured per result. There is no
design question left open and no deliverable at risk of needing a placeholder. The plan is
therefore siting, naming, phase sequencing and gate choreography, not proof discovery. Six report
findings are load-bearing and are not re-litigated here:

1. **`Semantics/TruthClauses.lean` is unusable.** Every clause class in it is hard-bound to
   `TaskFrame`/`WorldHistory F`/`TaskModel F`; a nomic evaluation point is a *bare function*
   `↑D → F.World` over a `NomicFrame D`, and `H_F = ⋃_w H_F^w` is the world-history set of no
   single task frame once the frame is non-uniform. The derived-operator clause layer is therefore
   re-derived natively (nine short lemmas), and the duplication plus its cause is recorded in the
   truth module's docstring rather than left to look like carelessness.
2. **The `satSet` shape is copied, including its ignoring-set `box` clause.**
   `Metalogic/Independence/StateSetTruth.lean` already carries a forward pointer written for this
   port. Its `| .box φ => {_w | ∀ v, v ∈ satSet V φ}` form is reused for **both** `box` and
   `nomic`, which is exactly what makes `S_{◈φ} = S_{□φ}` hold by `rfl`; the alternative
   `if … = Set.univ then univ else ∅` would pull `Classical.choice` into the *definition*.
3. **`TenseFree` is a `Prop`-valued inductive over a total recursion.** A `Prop` predicate cannot
   be recursed into `Set W` (no large elimination), so the state-set recursion is total on the
   full formula type with `∅` at the two temporal clauses, and the bridge theorem carries
   `TenseFree φ` as a hypothesis, discharging those cases by `cases h`. This is a documented
   partial-function convention on a total recursion; no `def Foo := True`/`Unit`/`trivial` clause
   appears anywhere in the design.
4. **The bridge is stated for arbitrary `τ`, with no `τ ∈ F.HF` hypothesis** — strictly stronger
   than the paper's statement and free in the proof, because the `box`/`nomic` clauses quantify
   over `H_F`/`H_F^{τ(x)}` and the `atom` clause reads only `τ x`.
5. **The uniformity collapse needs no induction.** `change` the two clause sets and `rw [h (τ x)]`;
   it holds for every `φ` at `[propext]` only. Use `change`, never `show` (`linter.style.show` is
   blocking).
6. **`rw` must not cross the `↑intOrder` / `ℤ` carrier boundary** — 794's recorded hazard. The one
   place it matters here is lifting `ρ ∉ F.lawHist v` to `¬ IsStepPath (F.at v) ρ`; use the
   `exact`-shaped term form, not `rw`.

Two plan-time corrections to the report's recommendations, both verified by reading the tree:

- **Derived-operator naming.** The report's `nneg`/`nand`/`nalways`/`nnext` spellings were probe
  artifacts needed to avoid clashes inside one standalone snippet. House style across
  `Syntax/Formula.lean`, `OpenLanguage/Formula.lean` and `StarLanguage/Formula.lean` is dotted
  names inside the type's own namespace, so this component uses `NomicFormula.neg`, `.and`,
  `.iff`, `.always`, `.next`, `.allFuture`, `.allPast`, `.someFuture`, `.somePast`, `.top`,
  `.or`, `.diamond`. `OpenFormula` has no `next`; `Formula.next φ = untl bot φ` is the right-hand
  side to copy.
- **`NomicHierarchy.F3` is a plain `def`, not `@[reducible]`**, so `[F3.IsRegular]` does **not**
  synthesize — 794 never needed it, because `Static`/`Lawful`/`Uniform` take no instance. The
  `app:nomic-four` invalidity statement therefore uses `nomic_hierarchy`'s own
  `∃ _ : F.IsRegular` bundling shape, with the instance supplied as the bare term
  `NomicFrame.ofStepFamily_isRegular NomicHierarchy.R3 NomicHierarchy.R3.fwd NomicHierarchy.R3.bwd`
  exactly as `nomic_hierarchy` does.

### Prior Plan Reference

No prior plan for this task. Task 794's plan is the structural model followed here (phase-per-module,
record rows first, gate sweep last, Challenge statements pinning the frame-level API while leaving
declarations whose statements cannot exist before their carriers unpinned), and its recorded effort
calibration — 7 phases, 11 hours, every phase additive — is what this plan's 10-hour estimate is
anchored to.

### Roadmap Alignment

This dispatch carried no `roadmap_path`, so `specs/ROADMAP.md` was not consulted and no
roadmap-review or roadmap-update phase is included.

### Siting Decision (a two-directory split)

**Frame-level half → `FormalSystem/Semantics/Nomic/Uniformity.lean`.** `thm:nomic-uniform`'s
conditions (1)–(6) mention no object language, no formula and no model: they are conditions on the
accessibility relation that `def:nomic-frame`'s own closing sentence specifies at the frame level.
Siting them inside 794's cluster keeps them beside `lem:nomic-recovery`, which the (5)⇔(6) step
consumes, and lets the language component import one aggregator.

**Language half → `FormalSystem/NomicLanguage/`, a new top-level component.** `OpenLanguage/` is
the tree's only semantic-only language component — no proof system, no axiomatisation, no
soundness or completeness claim — and the dispatch names it as the precedent. Following it means:
a separate `inductive` with a constructor-to-constructor embedding from `Formula` (not a new
constructor on an existing type, which would change the type every existing L/L⁺ theorem is
stated at); `Formula.lean` importing nothing from `Semantics/` (the "syntax before semantics"
invariant that `scripts/check-metalogic-cycles.sh` assertion C enforces); a row per file in
`LANGUAGE_FILE_LAYERS`; a sibling aggregator `FormalSystem/NomicLanguage.lean`; and a directory
README.

**The cost, stated plainly**: the operator lives in a different directory from the uniformity
conditions it collapses under, so the appendix's two halves are not co-located and the language
component carries one extra import. The deciding argument is the import direction — a
language-free frame condition must not have to live in a formula directory.

### Namespace and layer facts the implementer needs (verified at plan time by reading the tree)

- `LANGUAGE_FILE_LAYERS` in `scripts/measure-refactor-partitions.py` keys on the directory name
  and then the file basename; `layer_of` **raises** `UnlayeredModuleError` for a file with no row,
  and a row naming a vanished file fails assertion B of `check-metalogic-cycles.sh`. The new
  `"NomicLanguage"` dict entry is `{"Formula": 0, "NomicTruth": 1, "NomicTenseFree": 1,
  "NomicValidity": 1, "NomicFour": 1}`. The directory set `check-metalogic-cycles.sh` assertion C
  uses is read **off that table**, so no edit to that script is needed.
- `FormalSystem/NomicLanguage/NomicValidity.lean` declares `NomicFrame.NomicValidOn` dotted inside
  a `namespace FormalSystem.Semantics` block, following `OpenLanguage/OpenValidity.lean`'s
  `TaskFrame.OpenValidOn`. **Open `namespace FormalSystem.NomicLanguage` first**, before that
  block, exactly as `OpenValidity.lean` does: `measure-refactor-partitions.py`'s `namespace-audit`
  reads a file's *first* namespace, and `OpenValidity.lean` stays out of the unrelated-namespace
  bucket precisely because of that ordering.
- `readme-lint.sh`: check 1 (every directory containing `.lean` files has a `README.md`) and
  check 3 (no broken relative markdown reference) are **gated**; check 2 (every `.lean` file
  listed in its directory README) and check 4 (`Last verified` freshness) are reported, not gated.
  So `FormalSystem/NomicLanguage/README.md` is mandatory, and the `NomicLanguage.lean` row in
  `FormalSystem/README.md` is a nicety — which matters, because that file is inside sibling task
  802's declared `file_scope`.
- `C15`'s gated anchor-prefix set is `(def|thm|lem|cor|app|rmk):`. `prop:` is **not** gated, so
  `prop:nomic-tense-free`'s stale "NOT FORMALIZED" row will not fail a gate — it is repointed
  anyway, because a silently wrong record entry is the defect C15 exists to prevent.
- `NomicFrame.lawHist` is `{τ | ∀ x y, F.TaskRel w (τ x) (y - x) (τ y)}` over bare
  `↑D → F.World`; `HF` is `⋃ w, F.lawHist w`; `Uniform` is `∀ w, F.lawHist w = F.HF`. Condition
  (4) of `thm:nomic-uniform` — `H_F^{τ(x)} = H_F` for all `τ ∈ H_F` and all `x` — is a *weaker*
  statement than `Uniform` as written (it quantifies only over occupied states), which is why
  (5)⇒(4) is immediate and (4)⇒(1)(2)(3) is choice-free at `[propext]`.

## Goals & Non-Goals

**Goals**:
- `lawHist_subset_HF`, `exists_mem_HF_eq`, `lawHist_nonempty`, `accRel`, `TransAt`, `SymmAt`,
  `EuclAt`, `PointUniform`, `uniform_of_transAt`, `uniform_of_symmAt`, `uniform_of_euclAt`,
  `pointUniform_of_uniform`, `transAt_of_pointUniform`, `symmAt_of_pointUniform`,
  `euclAt_of_pointUniform`, `uniform_iff_taskRel_indep`, `accRel_eq_of_uniform`,
  `accRel_equivalence_of_uniform`, `nomic_uniform`, `TransAtState`, `transAtState_iff`,
  `uniform_iff_forall_transAtState`, `NomicFormula`, `NomicModel`, `NomicTruthAt`,
  `nomic_iff_box_of_uniform`, `TenseFree`, `nomicSatSet`, `tenseFree_satSet_iff`,
  `nomic_iff_box_tenseFree`, `nomic_k_tenseFree`, `nomic_t_tenseFree`, `nomic_four_tenseFree`,
  `nomic_five_tenseFree`, `nomic_b_tenseFree`, `NomicValidOn`, `nomic_serial`,
  `four_validOn_iff_uniform`, `nomic_iff_box_validOn_iff_uniform`, `not_four_nomicValid` — the
  identifier set pinned under `## Lean Challenge Statements` below, exactly, no more and no fewer
- The derived-operator layer on the new formula type (top, negation, conjunction, disjunction,
  biconditional, diamond, the two existential and two universal tense operators, always, next),
  the constructor-to-constructor embedding from the base language with its injectivity, the seven
  primitive clause lemmas and the nine derived clause lemmas including the two collapsed forms.
  These are deliberately **not** in the Challenge set: they are transcriptions whose names mirror
  `Syntax/Formula.lean` and `Semantics/TruthClauses.lean` name-for-name, and pinning sixteen
  one-to-eight-line restatements would triple the Challenge block without fixing a single
  statement a reader could get wrong. Their names are fixed in Phases 3 and 4
- The `app:nomic-four` countermodel's own internals — the two atoms, the two-clause valuation, the
  witness sentence, the one-step violation extraction, and the two satisfaction claims. Not pinned
  for the same reason inverted to 794's witnesses: their statements mention the local `let`-bound
  model and sentence, which cannot exist before the phase that builds them. The three pinned
  `app:nomic-four` theorems carry their joint content
- A five-module component with its sibling aggregator and README, a `LANGUAGE_FILE_LAYERS` entry,
  and a regenerated library root, so the component is in the build graph and gated
- Five rows in `docs/reference/paper-definitions-of-record.md`: `thm:nomic-uniform` and
  `app:nomic-four` added as `LIVE-UNPINNED` (both gated by C15), `rmk:nomic-uniform` added as
  `DANGLING` (gated; cut material, so `--resolve` structurally cannot read it), and
  `def:nomic-frame` and `prop:nomic-tense-free` repointed to their new Lean homes
- Four prose repoints, so the tree stops asserting that the nomic operator has no formalization:
  `FormalSystem/OpenLanguage/README.md`'s "Manuscript operators without a formalization" row,
  `FormalSystem/StarLanguage/README.md`'s correspondence row,
  `FormalSystem/Metalogic/Independence/StateSetTruth.lean`'s `## References` forward pointer, and
  `docs/reference/paper-definitions-of-record.md`'s `sub:RestrictedModalities` note
- Docstrings that record the choice dependence honestly (`rmk:choice`): every occurrence-consuming
  result is a theorem of ZFC through `thm:extension`'s Zorn appeal and must not be advertised as
  choice-free. The two genuinely choice-free results — the uniformity collapse and
  (4)⇒(1)(2)(3) — measure at `[propext]` and are pinned as such

**Non-Goals**:
- Any proof system, axiomatisation, soundness or completeness claim for the nomic operator. The
  paper offers none, exactly as for the open-future and open-past modals; this component is
  semantic-only, in `OpenLanguage/`'s pattern
- Truth-level conservativity over the base language. It is **not statable** here: the base truth
  relation lives over `TaskFrame`, the nomic recursion does not, and a bridge exists only under
  uniformity — which would make conservativity a corollary of the collapse rather than a general
  fact. Recorded as an explicit exclusion with that reason in the component README
- The stability modal. `prop:nomic-tense-free`'s fragment is exactly atoms, falsum, implication,
  box and the nomic operator; the paper deliberately leaves the stability modal out of it. Adding
  it would force a decision the paper does not make and would add a state-set clause for no result
  in scope. Recorded in the component README
- The dense-time case of `app:nomic-four`. The paper's own commented remark leaves it open and the
  dispatch forbids attempting it. The ℤ-time hypothesis is recorded as load-bearing in the final
  module's docstring: without a duration-indexed tense operator, a violation at a general duration
  cannot be localized at adjacent times, which is exactly what the one-step extraction needs
- Generalising `Semantics/TruthClauses.lean` over the point structure. A six-component refactor,
  recommended against by the research, and not this task's business. The duplication is recorded
  with its cause instead
- `docs/theorem-index.md` rows for the new declarations. C15's second assertion checks only
  *existing* rows, so omitting them is gate-clean, and the file is inside sibling task 802's
  declared `file_scope`
- Any edit to `possible_worlds.tex` — clearing the `% PORT:` markers under `prop:nomic-tense-free`,
  `thm:nomic-uniform` and `app:nomic-four` and closing their proofs with `\leanproof{}`. A
  different repository, read-only input here; the declaration names are fixed in Phases 2 and 4–7
  so a later `\leanproof{\texttt{…}}` needs no rename. Listed as a follow-up for the author
- Absorbing the ten pre-existing drifted anchors that already make
  `scripts/check-paper-definitions.sh` exit 1, or re-pinning the record file's whole-file
  `FILE_CHECKSUM`/`PINNED_COMMIT` sentinels. Unrelated to this task and explicitly not a
  regression of it; the sentinels are re-pinned only when absorbing a drift *correction*

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `scripts/warning-budget.txt` has a **zero** baseline with every listed class `blocking`, and a linter class with **no disposition row exits 2**, not softly. The probes tripped `linter.style.show`, `linter.unusedTactic`, `linter.unusedVariables` and `linter.unnecessarySimpa` — and `linter.unnecessarySimpa` has no row | H | H | `change` where the goal changes, never `show`; drop the no-op `congr 1` from the next-operator proof; `_`-prefix every unused binder; reflow to 100 columns. Never leave a `simpa` where `simp` closes the goal — `Order.succ x = x + 1` at `↑intOrder` is exactly such a site (`simp`, not `simpa using Order.succ_eq_add_one x`). If `linter.unnecessarySimpa` is genuinely unavoidable, a reasoned disposition row must land in the same change, never a bare suppression |
| Deprecated-API warnings are `blocking` (`disposition deprecated blocking`) | M | H | `push Not`, not `push_neg`; `LE.le.ssubset_of_ne`, not `HasSubset.Subset.ssubset_of_ne`. Both verified in probes. 794 hit the same class with `Int.le_induction` → `Int.leInduction` |
| Sibling task 802's declared `file_scope` (36 files) claims `docs/reference/paper-definitions-of-record.md`, `docs/theorem-index.md` and `FormalSystem/README.md`; sibling 797 declares **no** `file_scope` at all and may touch any file | M | H | The record file is the only one of the three this task *must* edit. Re-read it immediately before editing and again immediately before committing; stage with an explicit path list (`git add -- <file>`), never a directory or glob; commit the five rows as a single tightly scoped hunk. `docs/theorem-index.md` is a Non-Goal. The `FormalSystem/README.md` row is readme-lint check 2 (reported, not gated): if the file carries foreign uncommitted edits, record the row as a reasoned exclusion rather than absorbing them. Treat an unexpected build failure outside this task's own files as possibly a sibling's in-flight edit, and never run `git-snapshot.sh` in its reverting default mode |
| `[NomicHierarchy.F3.IsRegular]` does not synthesize: `F3` is a plain `def`, so the instance head is not syntactically `ofStepFamily …` until `F3` unfolds | M | H | Verified at plan time by reading `Witnesses.lean`: nothing in 794 ever needed the instance, and `nomic_hierarchy` supplies it as the bare term `NomicFrame.ofStepFamily_isRegular NomicHierarchy.R3 R3.fwd R3.bwd` inside its `∃ _ : F.IsRegular` slot. The pinned invalidity statement uses that same shape; inside the proof, bind it with `haveI` before any call to `occurrence` |
| `rw` across the `↑intOrder` / `ℤ` carrier boundary — 794's recorded hazard, which bit it twice | M | M | Route every such step through `exact`/`refine`/`Iff.trans`/`Set.ext_iff`, never `rw`. The one site here is lifting `ρ ∉ F.lawHist v` to `¬ IsStepPath (F.at v) ρ`; the probed term is `fun hs => hρv ((NomicFrame.mem_lawHist_iff_isStepPath F v ρ).mpr hs)`. Inside the two satisfaction claims `rw [hpz, hqz] at hstep` *does* work — `μ z` and `ρ n` are both `F.World`, so no boundary is crossed |
| A new module not reachable from the generated root is not built by `lake build FormalSystem`, so "green" would be vacuous | H | M | The root is regenerated by `lake exe mk_all --lib FormalSystem` in the same phase as each new file, and the aggregator import line is added in that same phase, so every subsequent phase's build actually compiles the new code. `mk_all` is deliberately not deferred to the final phase |
| C16 (`docBlame`) requires a docstring on **every** declaration, including each of `TransAt`/`SymmAt`/`EuclAt`/`PointUniform`/`TransAtState` and each of the sixteen clause lemmas | M | M | Docstrings are written as each declaration is written, never retrofitted. C19's 90% coverage floor then follows for free |
| C34a/C34b (`Constraints consumed:` markers) fire on the new `[F.IsRegular]`-taking declarations | M | M | Every new declaration carrying `[F.IsRegular]` and reading as a constraint claim gets a `Constraints consumed:` line naming all four (through `thm:extension`). `nomic_iff_box_of_uniform` and the (4)⇒(1)(2)(3) direction take no instance and consume none — do not mark them |
| C26 forbids an underscore inside a `def`/`abbrev` name component | L | M | `nomicSatSet`, `accRel`, `PointUniform`, `TransAtState`, `NomicValidOn`, `NomicTruthAt` are all clean. Theorems are unaffected, so `uniform_iff_taskRel_indep` and friends are fine. C23 additionally forbids `lemma` and an `Uppercase_x` name whose prefix is a real declaration — 794 hit this (`F1_static` rejected, `F1.static` accepted) |
| `check-paper-definitions.sh` already exits 1 on ten inherited drifted anchors before this task starts | L | H | Advisory here, exactly as 794's plan treated it. Verify only the nomic anchors individually with `--resolve '<anchor>\|env\|-\|-'`; the four resolved `sha256` values are recorded in Phase 1's tasks so a row can be promoted to a pinned `MANIFEST` row if a docstring ever quotes anchor text |
| Module length (the 1500-line linter) if the component lands as one file | L | L | Five modules by construction: `Formula`, `NomicTruth`, `NomicTenseFree`, `NomicValidity`, `NomicFour` |
| A transient `import FormalSystem.Semantics.Nomic` failure reported "unknown namespace `FormalSystem.Syntax`" although the aggregator and every `.olean` were current; the identical import succeeded on retry | L | L | Retry once before concluding an aggregator is missing or the build is stale. Importing the leaf modules directly (`…Nomic.Frame`, `…Nomic.ZTime`, `…Nomic.Witnesses`) is the workaround |
| `lean_local_search`'s index was `warming` throughout research, so the absence findings rest on grep sweeps | L | L | Announced rather than treated as a negative finding. Re-run `lean_local_search "NomicFormula"` at implementation time and treat an empty result as proof of absence only under `index: consulted` |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 3 |
| 4 | 5, 6 | 4 (and 2, for Phase 6) |
| 5 | 7 | 5, 6 |

Phases within the same wave can execute in parallel.

### Phase 1: Record rows for the new anchors [COMPLETED]

**Goal**: C15 resolves every anchor the new docstrings will cite, before any docstring cites one.

**Tasks**:
- [ ] Re-read `docs/reference/paper-definitions-of-record.md` immediately before editing — it is
      inside sibling task 802's declared `file_scope`
- [ ] Add a `KNOWN-ANCHORS` `LIVE-UNPINNED` row for `thm:nomic-uniform`: the six equivalent
      conditions on a nomic frame's accessibility relation, naming `FormalSystem/Semantics/Nomic/Uniformity.lean`
      as the Lean home, and noting that the tree cites it by name and quotes no text
- [ ] Add a `KNOWN-ANCHORS` `LIVE-UNPINNED` row for `app:nomic-four`: axiom 4 for the nomic
      operator is valid over ℤ-time exactly on the Uniform frames, naming
      `FormalSystem/NomicLanguage/NomicFour.lean`
- [ ] Add a `DANGLING` row for `rmk:nomic-uniform`, following the `thm:nomic-primitive` row's
      wording verbatim in structure: cut material living in
      `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/appendix_cut_material.tex` under its own
      header, which this record does not track, so `--resolve` structurally cannot read it; marked
      `DANGLING` on that ground rather than because the label went away; its content (per-state
      transitivity) IS formalized as the side lemma in `Uniformity.lean`, cited by file and header
      rather than as a paper anchor
- [ ] Repoint `def:nomic-frame`'s existing row: extend the note to name the Nomic clause's Lean
      home (the truth recursion's `nomic` clause in `FormalSystem/NomicLanguage/NomicTruth.lean`)
      alongside the frame-level declarations it already names
- [ ] Repoint `prop:nomic-tense-free`'s existing row, which today reads "NOT FORMALIZED: no nomic
      machinery exists in this tree". Replace that with the new declarations
      (`FormalSystem/NomicLanguage/NomicTenseFree.lean`). `prop:` is outside C15's gated prefix
      set, so this is correctness, not gate compliance
- [ ] Do **not** touch the whole-file `FILE_CHECKSUM`/`PINNED_COMMIT` sentinels. If a docstring
      ends up quoting an anchor verbatim, promote that row to a `MANIFEST` row
      `<anchor>|env|-|-|<sha>` with the sha resolved during research: `def:nomic-frame`
      `60fdc0699603f6fd5f2a10f4e6ee8e17e96d569657e24e8b888849f6d914f60f`;
      `prop:nomic-tense-free`
      `606d1c6fca3f72c502a7d34b0896bb239652ef635608cc2bd350750a4e46e7d5`; `thm:nomic-uniform`
      `614ddcaa6433bede6548634a442ddbcb3b18f8ca0e57e8e8e38d489e167cafaf`; `app:nomic-four`
      `34f753111d4ea9244464bdcc20b73a94f3e7ce7345689b2da67ce1f11a4f8bd8`
- [ ] Stage with `git add -- docs/reference/paper-definitions-of-record.md` only

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: the hypothesis is **three rows to add and two to repoint**, carried from the
research report's "Record rows needed" table. Confirm immediately before editing with
`grep -nE 'nomic-(uniform|four)|nomic-tense-free|def:nomic-frame' docs/reference/paper-definitions-of-record.md`:
a row that already exists is not added twice, and an anchor no new docstring actually cites needs
no row at all. The `sub:RestrictedModalities` note on the same file also claims the nomic operator
is unformalized, but it is repointed in Phase 7 rather than here, once the formalization exists —
so this phase's own edit count is five, not six.

**Tier Justification**: this phase touches one markdown record file with no compile surface, and
its only gated consumer is C15, so
`bash scripts/check-module-invariants.sh 2>&1 | grep -A5 'C15'` run with the script's own exit
status checked covers the whole blast radius; no module changes, so no build is implicated.

**Files to modify**:
- `docs/reference/paper-definitions-of-record.md` - three new rows, two repointed notes

**Verification**:
- `bash scripts/check-module-invariants.sh` exits 0 (C15's first assertion now resolves the two
  new gated anchors and the one new `DANGLING` one), with the script's exit status checked
  directly rather than inferred from stdout
- `grep -nE '^(thm:nomic-uniform|app:nomic-four|rmk:nomic-uniform)\|' docs/reference/paper-definitions-of-record.md`
  shows exactly three new rows, the third marked `DANGLING`
- `grep -n 'prop:nomic-tense-free' docs/reference/paper-definitions-of-record.md` no longer
  contains "NOT FORMALIZED"
- `git diff --staged --name-only` lists exactly one file

---

### Phase 2: `thm:nomic-uniform` and the cut remark's side lemma [IN PROGRESS]

**Goal**: the frame-level half — the four small facts 794 lacks, the accessibility relation, the
six conditions as a cycle of implications, the `H_F × H_F` identification, and the per-state
transitivity side lemma the cut `rmk:nomic-uniform` specifies.

**Tasks**:
- [ ] Create `FormalSystem/Semantics/Nomic/Uniformity.lean` with the four-line Apache copyright
      header, a `/-! … -/` module docstring, and `namespace FormalSystem.Semantics` /
      `namespace NomicFrame`
- [ ] The four small facts 794 does not have: `lawHist_subset_HF` (`Set.subset_iUnion _ w`),
      `exists_mem_HF_eq` (every world state is `τ' x` for some `τ' ∈ H_F`; by `occurrence` then
      `Set.mem_iUnion.mpr`), `lawHist_nonempty` (the content of seriality; `occurrence w w x`
      supplies the witness)
- [ ] `def accRel`: the accessibility relation of `def:nomic-frame`'s closing sentence — at `x`, it
      relates `τ` to each `σ ∈ F.lawHist (τ x)`
- [ ] `def TransAt`, `def SymmAt`, `def EuclAt` — conditions (1)–(3), each stated at a **single**
      time `x`, so the hypothesis is the existential reading; `def PointUniform` — condition (4),
      `∀ τ ∈ F.HF, ∀ x, F.lawHist (τ x) = F.HF`. Record in each docstring that (4)⇒(1)(2)(3) is
      what licenses reading the `x`-quantifier in (1)–(3) either existentially or universally
- [ ] `uniform_of_transAt`: with `w := τ x`, `occurrence` gives `σ ∈ F.lawHist w` with `σ x = u`
      for arbitrary `u`; transitivity carries every `ρ ∈ F.lawHist u = F.lawHist (σ x)` into
      `F.lawHist w`; hence `F.HF ⊆ F.lawHist w ⊆ F.HF` by `Set.Subset.antisymm` and
      `Set.mem_iUnion.mp`; every `w'` is some `τ' x` by `exists_mem_HF_eq`, so `F.lawHist w' = F.HF`
      throughout
- [ ] `uniform_of_symmAt` and `uniform_of_euclAt` on the same `w, τ, u, σ` construction: symmetry
      gives `τ ∈ F.lawHist u`, the Euclidean condition gives `F.lawHist w ⊆ F.lawHist u` for all
      `w, u`
- [ ] `pointUniform_of_uniform` ((5)⇒(4), immediate: `Uniform` quantifies over all world states,
      (4) only over occupied ones) and `transAt_of_pointUniform`, `symmAt_of_pointUniform`,
      `euclAt_of_pointUniform` ((4)⇒(1)(2)(3), by `rw [h τ hτ x] at …`; **choice-free, `[propext]`
      only** — these take no `[F.IsRegular]` instance and get **no** `Constraints consumed:` line)
- [ ] `uniform_iff_taskRel_indep` ((5)⇔(6)) through 794's `lawHist_eq_iff_taskRel_eq` in both
      directions, with `▸` on the `mpr` leg rather than `rw`
- [ ] `accRel_eq_of_uniform` (under uniformity the relation is `H_F × H_F`) and
      `accRel_equivalence_of_uniform` (so it is reflexive, symmetric, transitive and Euclidean)
- [ ] `nomic_uniform`: the bundled six-way equivalence, assembled from the cycle — for every `x`,
      each of `TransAt x`, `SymmAt x`, `EuclAt x`, `PointUniform` and task-relation independence
      is equivalent to `Uniform`. A one-line assembly from the implications above, in
      `nomic_hierarchy`'s bundling style
- [ ] The cut remark's side lemma: `def TransAtState`
      (`∀ σ ∈ F.lawHist w, ∀ x, F.lawHist (σ x) ⊆ F.lawHist w`), `transAtState_iff` (equivalent to
      `∀ u, F.lawHist u ⊆ F.lawHist w`; the `⇒` leg is the remark's "every world state `u` is the
      state `σ x` of some such `σ`" step, which is `occurrence w u 0`) and
      `uniform_iff_forall_transAtState`. Cite the cut by **file and header**
      (`appendix_cut_material.tex`, "the cut `rmk:nomic-uniform`"), exactly as
      `NomicFrame.static_iff_taskRel_eq` cites `thm:nomic-primitive` — not as a paper authority
- [ ] A `Constraints consumed:` line on every `[F.IsRegular]`-taking declaration here, naming all
      four constraints through `thm:extension`, plus the `rmk:choice` note: the
      occurrence-consuming results are theorems of ZFC and must not be advertised as choice-free.
      `transAt_of_pointUniform` and its two siblings are the exceptions and are pinned at
      `[propext]`
- [ ] Add `import FormalSystem.Semantics.Nomic.Uniformity` to `FormalSystem/Semantics/Nomic.lean`
      with one `## Modules` bullet, extend `FormalSystem/Semantics/Nomic/README.md` with the fifth
      module and refresh its `Last verified` date, then `lake exe mk_all --lib FormalSystem` and
      inspect `git diff -- FormalSystem.lean` before staging

**Timing**: 2 hours

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Tier Justification**: `Uniformity.lean` is a new leaf inside 794's cluster whose only dependent
is `FormalSystem/Semantics/Nomic.lean`, so
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.Nomic`
builds the module and that aggregator and covers every call site this phase creates.

**Files to modify**:
- `FormalSystem/Semantics/Nomic/Uniformity.lean` - new: the four small facts, `accRel`, conditions (1)-(6), the cycle, the `H_F × H_F` identification, the cut remark's side lemma
- `FormalSystem/Semantics/Nomic.lean` - one import line and one `## Modules` bullet
- `FormalSystem/Semantics/Nomic/README.md` - fifth module row, refreshed `Last verified`
- `FormalSystem.lean` - regenerated by `lake exe mk_all --lib FormalSystem`

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.Nomic`
  exits 0, run detached with the guard's exit status captured un-piped
- `grep -c 'sorry' FormalSystem/Semantics/Nomic/Uniformity.lean` reports 0
- `mcp__lean-lsp__lean_verify FormalSystem.Semantics.NomicFrame.transAt_of_pointUniform` reports
  `[propext]`, confirming the choice-free claim its docstring makes
- `mcp__lean-lsp__lean_verify FormalSystem.Semantics.NomicFrame.uniform_of_transAt` reports a set
  containing `Classical.choice`, confirming the `rmk:choice` docstring claim rather than asserting
  choice-freedom
- `bash scripts/readme-lint.sh FormalSystem` exits 0

---

### Phase 3: The `NomicLanguage` component and its syntax [NOT STARTED]

**Goal**: the new top-level component exists, is in the build graph, is gated, and carries the
formula type with its derived operators and the embedding from the base language.

**Tasks**:
- [ ] Create `FormalSystem/NomicLanguage/Formula.lean`: copyright header, module docstring,
      `namespace FormalSystem.NomicLanguage`, and `inductive NomicFormula` with the base
      language's six constructors (`atom`, `bot`, `imp`, `box`, `untl`, `snce`) plus `nomic`.
      **It must import nothing from `Semantics/` and no semantic module of any language** — the
      "syntax before semantics" invariant that `check-metalogic-cycles.sh` assertion C enforces
- [ ] The derived-operator layer in `namespace NomicFormula`, dotted house style, each right-hand
      side copied verbatim from `Syntax/Formula.lean` so the embedding commutes by `rfl`: `top`,
      `neg`, `someFuture`, `somePast`, `allFuture`, `allPast`, `and`, `or`, `iff`, `diamond`,
      `always` (`φ.allPast.and (φ.and φ.allFuture)`), `next` (`untl bot φ` — `OpenFormula` has no
      `next`, so copy `Formula.next`)
- [ ] `def ofFormula : Formula → NomicFormula`, constructor-to-constructor, and
      `theorem ofFormula_injective`, mirroring `OpenLanguage`'s `ofPlus`/`ofPlus_injective`. Record
      in its docstring that no result in this task consumes it and why it is kept anyway: it is
      what makes "this language extends the base language" a theorem rather than a claim in prose,
      and C17's dead-declaration scan is reporting-only
- [ ] Create `FormalSystem/NomicLanguage.lean`, the sibling aggregator (C8), importing
      `FormalSystem.NomicLanguage.Formula` and carrying a `## Modules` docstring list to be
      extended by each later phase
- [ ] Create `FormalSystem/NomicLanguage/README.md` (readme-lint check 1, **gated**): the
      component's semantic-only contract in `OpenLanguage/README.md`'s house style, the five
      planned modules, the paper-label correspondence table, and the three recorded exclusions
      with their reasons — no proof system, no truth-level conservativity over the base language
      (different frame type), and the stability modal deliberately outside the tense-free
      fragment. Every relative markdown link must resolve on disk (readme-lint check 3 and C13
      are both gated)
- [ ] Add the `"NomicLanguage"` entry to `LANGUAGE_FILE_LAYERS` in
      `scripts/measure-refactor-partitions.py`: `{"Formula": 0, "NomicTruth": 1,
      "NomicTenseFree": 1, "NomicValidity": 1, "NomicFour": 1}`. All five rows go in now, in one
      edit, so no later phase can land a file with no row and make `layer_of` raise — assertion B
      reports a row whose file is missing as *stale*, which is a reported condition, whereas a
      file with no row is a hard raise
- [ ] `lake exe mk_all --lib FormalSystem`, then inspect `git diff -- FormalSystem.lean` before
      staging: expect exactly the `FormalSystem.NomicLanguage` and
      `FormalSystem.NomicLanguage.Formula` lines in sorted position

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: interface

**Commit Mode**: per-substep

**Scope Hypothesis**: the hypothesis is **five `LANGUAGE_FILE_LAYERS` rows**, one per planned
module, carried from this plan's own module decomposition (itself carried from the research
report's seven-phase table). Confirm at the end of Phase 7 with
`python3 scripts/measure-refactor-partitions.py` exiting 0 and reporting no stale language rows:
a planned module that does not get written leaves a stale row, and a module written under a
different basename has no row at all.

**Tier Justification**: this phase adds a new top-level directory, so its blast radius reaches
beyond the module itself into three enumerated out-of-module consumers — the generated root, the
layer table read by `check-metalogic-cycles.sh` assertion C, and `readme-lint.sh`'s
per-directory check 1 — and
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.NomicLanguage`
plus `bash scripts/check-metalogic-cycles.sh` plus `bash scripts/readme-lint.sh FormalSystem`
covers exactly that one-hop set.

**Files to modify**:
- `FormalSystem/NomicLanguage/Formula.lean` - new: `NomicFormula`, the derived operators, `ofFormula` and its injectivity
- `FormalSystem/NomicLanguage.lean` - new: sibling aggregator (C8)
- `FormalSystem/NomicLanguage/README.md` - new: component README with the three recorded exclusions (readme-lint check 1)
- `scripts/measure-refactor-partitions.py` - the `"NomicLanguage"` `LANGUAGE_FILE_LAYERS` entry, all five rows
- `FormalSystem.lean` - regenerated

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.NomicLanguage`
  exits 0
- `bash scripts/check-metalogic-cycles.sh` exits 0 — assertion C sees the new directory's layer-0
  syntax file and does not report a degenerate (empty) module set, and assertion B reports the
  four not-yet-written rows as stale rather than raising
- `python3 scripts/measure-refactor-partitions.py` exits 0 and does not raise
  `UnlayeredModuleError`
- `bash scripts/readme-lint.sh FormalSystem` exits 0 (check 1 satisfied by the new README, check 3
  by its links resolving)
- `grep -c 'sorry' FormalSystem/NomicLanguage/Formula.lean` reports 0
- `grep -nE '^import' FormalSystem/NomicLanguage/Formula.lean` shows no `Semantics` import

---

### Phase 4: `NomicModel`, the truth recursion, and the clause layer [NOT STARTED]

**Goal**: `def:nomic-frame`'s Nomic clause as a Lean truth relation, with the full clause layer
re-derived natively and the uniformity collapse.

**Tasks**:
- [ ] Create `FormalSystem/NomicLanguage/NomicTruth.lean` importing
      `FormalSystem.NomicLanguage.Formula` and `FormalSystem.Semantics.Nomic`
- [ ] `structure NomicModel (F : NomicFrame D)` with one field, the valuation
      `F.World → Atom → Prop`
- [ ] `def NomicTruthAt (M : NomicModel F) (τ : ↑D → F.World) (x : ↑D) : NomicFormula → Prop`,
      the recursion. **`τ` is a bare function with no membership proof** — 794 already pays this
      cost at the frame level, and inheriting it means the recursion threads no proof and needs no
      transport anywhere. Clauses: `atom` reads `M.valuation (τ x)`; `bot` is `False`; `imp` is
      implication; `box` is `∀ σ ∈ F.HF, NomicTruthAt M σ x φ`; `untl`/`snce` are the usual
      strict-future/strict-past clauses over `↑D`'s order; **`nomic` is
      `∀ σ ∈ F.lawHist (τ x), NomicTruthAt M σ x φ`** — the dispatch's clause verbatim, so the
      accessibility relation at `x` relates `τ` to the law-histories at its current state
- [ ] The module docstring records, prominently, **why this layer is duplicated rather than
      instantiated**: every clause class in `Semantics/TruthClauses.lean` is bound to
      `TaskFrame`/`TaskModel F`/`WorldHistory F`/`F.Duration`, and `H_F` is a union of law-history
      sets which, for a non-uniform frame, is the world-history set of no task frame, so the
      `WorldHistory F` binder cannot be met. Name `TruthClauses.lean` explicitly and record that
      generalising it over the point structure is a six-component refactor, deliberately not
      attempted here — so a future reader does not take the duplication for carelessness
- [ ] The seven primitive clause lemmas in `namespace NomicTruth`, following `OpenTruth`'s
      `atom_iff`/`box_iff` naming: `atom_iff`, `bot_iff`, `imp_iff`, `box_iff`, `untl_iff`,
      `snce_iff`, `nomic_iff`
- [ ] The nine derived clause lemmas: `neg_iff`, `and_iff` (`simp only [and, neg, NomicTruthAt];
      tauto` — `tauto` closes the classical step), `iff_iff`, `someFuture_iff`, `allFuture_iff`,
      `somePast_iff`, `allPast_iff`, and the two collapsed forms that carry real content:
      `always_iff` (the three-conjunct introduction form straight to the `∀ y` normal form, by
      `rcases lt_trichotomy y x`, using `↑D`'s `LinearOrder` carried by `TemporalOrder`) and
      `next_iff_succ` (transcribed from `Metalogic/DiscreteNonCompactness.lean`'s
      `truthAt_next_iff`, under `[SuccOrder (↑D : Type)]` and `[NoMaxOrder (↑D : Type)]`), plus
      the ℤ specialisation `next_iff_add_one` closing with `rw [next_iff_succ …]; simp`
- [ ] **Three linter traps, each already measured**: no intervening `congr 1` in the
      `next_iff_add_one` proof (it does nothing and trips `linter.unusedTactic`); `simp`, never
      `simpa using Order.succ_eq_add_one x` (`linter.unnecessarySimpa` has **no disposition row**
      in `scripts/warning-budget.txt`, so it exits 2 rather than failing softly); unfold the
      biconditional before any `rw [and_iff]` in `iff_iff`
- [ ] `nomic_iff_box_of_uniform`: the full collapse, for **every** `φ`, no induction —
      `change (∀ σ ∈ F.lawHist (τ x), …) ↔ ∀ σ ∈ F.HF, …` then `rw [h (τ x)]`. **`change`, never
      `show`**: the tactic alters the goal and `linter.style.show` is blocking. The docstring
      records that the paper's "by induction on `φ`" is not needed once the clause sets are equated,
      and that this measures at `[propext]` — genuinely choice-free, and it takes no
      `[F.IsRegular]` instance, so **no** `Constraints consumed:` line
- [ ] Add the import and `## Modules` bullet to `FormalSystem/NomicLanguage.lean`, add the module
      row to the component README, then `lake exe mk_all --lib FormalSystem` and the
      `git diff -- FormalSystem.lean` inspection

**Timing**: 2 hours

**Depends on**: 3

**Verification Tier**: local

**Commit Mode**: per-substep

**Tier Justification**: `NomicTruth.lean` is a new leaf whose only dependent is
`FormalSystem/NomicLanguage.lean` (the three modules of Phases 5-7 that will import it do not
exist yet), so
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.NomicLanguage`
builds the module and that aggregator and covers every call site this phase creates.

**Files to modify**:
- `FormalSystem/NomicLanguage/NomicTruth.lean` - new: `NomicModel`, `NomicTruthAt`, the seven primitive and nine derived clause lemmas, `nomic_iff_box_of_uniform`
- `FormalSystem/NomicLanguage.lean` - one import line and one `## Modules` bullet
- `FormalSystem/NomicLanguage/README.md` - module row
- `FormalSystem.lean` - regenerated

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.NomicLanguage`
  exits 0
- `grep -c 'sorry' FormalSystem/NomicLanguage/NomicTruth.lean` reports 0
- `grep -nE '\bshow\b|simpa|congr 1' FormalSystem/NomicLanguage/NomicTruth.lean` returns no
  tactic-position hit (the three measured linter traps)
- `mcp__lean-lsp__lean_verify FormalSystem.NomicLanguage.nomic_iff_box_of_uniform` reports
  `[propext]`, confirming the choice-free claim its docstring makes
- `bash scripts/check-module-invariants.sh` exits 0 — in particular C16 (`docBlame`: a docstring on
  every one of the sixteen clause lemmas), C26 (no underscore in `NomicTruthAt`/`NomicModel`), and
  C34a/C34b (no spurious `Constraints consumed:` line on the two instance-free declarations)

---

### Phase 5: `prop:nomic-tense-free` and the S5 schemata on the fragment [NOT STARTED]

**Goal**: the state-set bridge, the fragment collapse, and the five S5 schemata it makes one line
each.

**Tasks**:
- [ ] Create `FormalSystem/NomicLanguage/NomicTenseFree.lean`
- [ ] `inductive TenseFree : NomicFormula → Prop` with exactly five constructors — `atom`, `bot`,
      `imp`, `box`, `nomic`. The fragment is the paper's, no more
- [ ] `def nomicSatSet (V : F.World → Atom → Prop) : NomicFormula → Set F.World`, total on the
      full formula type. **Copy `StateSetTruth.lean`'s ignoring-set form verbatim** for **both**
      `box` and `nomic`: `{_w | ∀ v : F.World, v ∈ nomicSatSet V φ}`. The docstring records why,
      citing `StateSetTruth.lean`: the alternative `if nomicSatSet V φ = Set.univ then univ else ∅`
      would have to decide a set equality and would pull `Classical.choice` into the *definition*.
      Using one form for both operators is exactly what makes `S_{◈φ} = S_{□φ}` hold by `rfl`
- [ ] The `untl`/`snce` clauses get `∅`, with a docstring paragraph recording this as a documented
      partial-function convention on a total recursion, not a vacuous definition: a `Prop`-valued
      `TenseFree` cannot be recursed into `Set F.World` (no large elimination), so the recursion is
      total and the theorem is restricted instead. **No `def Foo := True`/`Unit`/`trivial` clause
      anywhere**
- [ ] No `[LinearOrder F.World]` binder: `satSet` needs the order only for its `untl`/`snce`
      clauses and the tense-free fragment has none, so this recursion takes a bare world type
- [ ] `tenseFree_satSet_iff`, the bridge: for every `φ` with `TenseFree φ`, every **arbitrary**
      bare `τ : ↑D → F.World` and every `x`, `NomicTruthAt M τ x φ ↔ τ x ∈ nomicSatSet M.valuation φ`.
      Both the `box` and `nomic` cases run the same three lines —
      `obtain … := F.occurrence (τ x) v x` then `rwa [hv]` for the forward direction, `h (σ x)` for
      the converse — the `box` case additionally lifting `σ ∈ F.lawHist (τ x)` to `σ ∈ F.HF` by
      `Set.mem_iUnion.mpr ⟨τ x, hσ⟩`. The `untl`/`snce` cases are `intro h; cases h`
- [ ] The docstring records the **formalization-native strengthening**: the paper states the
      proposition for `τ ∈ H_F`, but the Lean statement holds for an arbitrary bare `τ`, because
      the `box`/`nomic` clauses quantify over `H_F`/`H_F^{τ(x)}` and the `atom` clause reads only
      `τ x`. Strictly stronger, free in the proof, recorded rather than silently taken
- [ ] `nomic_iff_box_tenseFree`: the fragment collapse, two lines from the bridge, since
      `nomicSatSet V (.nomic φ)` and `nomicSatSet V (.box φ)` are the same set by `rfl`
- [ ] The five S5 schemata on the fragment, one line each from the collapse plus the box clause:
      `nomic_k_tenseFree`, `nomic_t_tenseFree`, `nomic_four_tenseFree`, `nomic_five_tenseFree`,
      `nomic_b_tenseFree`. The module docstring records the one genuine surprise worth recording:
      **T holds on the tense-free fragment over every nomic frame, including non-*Lawful* ones**,
      because the collapse already degenerates the nomic operator into the box. The paper's remark
      that *Nomologically lawful* validates T for the nomic operator is about the **full**
      language; on the fragment T is free. This is `prop:nomic-tense-free`'s closing sentence ("any
      refutation must use the stability or the until/since operators") read for T rather than for
      4, and it is a consistency check against `prop:nomic-hierarchy`'s first witness
- [ ] `Constraints consumed:` lines plus the `rmk:choice` note on the bridge and every schema that
      consumes `occurrence`; they are theorems of ZFC through `thm:extension`
- [ ] Add the import and `## Modules` bullet to `FormalSystem/NomicLanguage.lean`, add the module
      row to the component README, then `lake exe mk_all --lib FormalSystem` and the
      `git diff -- FormalSystem.lean` inspection

**Timing**: 1.5 hours

**Depends on**: 4

**Verification Tier**: local

**Commit Mode**: per-substep

**Tier Justification**: `NomicTenseFree.lean` is a new leaf whose only dependent is
`FormalSystem/NomicLanguage.lean` — Phase 7's `NomicFour.lean` imports `NomicValidity`, not this
module — so
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.NomicLanguage`
covers the whole edit.

**Files to modify**:
- `FormalSystem/NomicLanguage/NomicTenseFree.lean` - new: `TenseFree`, `nomicSatSet`, the bridge, the fragment collapse, the five S5 schemata
- `FormalSystem/NomicLanguage.lean` - one import line and one `## Modules` bullet
- `FormalSystem/NomicLanguage/README.md` - module row
- `FormalSystem.lean` - regenerated

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.NomicLanguage`
  exits 0
- `grep -c 'sorry' FormalSystem/NomicLanguage/NomicTenseFree.lean` reports 0
- `grep -nE ':= *(True|Unit|trivial|Trivial)\s*$' FormalSystem/NomicLanguage/NomicTenseFree.lean`
  returns nothing (the vacuous-definition prohibition, which the two `∅` clauses must not be
  mistaken for)
- An `example` pins `nomicSatSet V (.nomic φ) = nomicSatSet V (.box φ)` as `rfl`, which is the
  identity the collapse rests on
- `mcp__lean-lsp__lean_verify FormalSystem.NomicLanguage.tenseFree_satSet_iff` reports a set
  containing `Classical.choice`, confirming the `rmk:choice` docstring claim
- `bash scripts/check-module-invariants.sh` exits 0

---

### Phase 6: Validity and seriality [NOT STARTED]

**Goal**: the validity notion the schema results are stated at, and seriality of the nomic
operator over **every** nomic frame.

**Tasks**:
- [ ] Create `FormalSystem/NomicLanguage/NomicValidity.lean`. **Open
      `namespace FormalSystem.NomicLanguage` first**, then a nested `namespace FormalSystem.Semantics`
      block for the dotted definition, exactly as `OpenLanguage/OpenValidity.lean` is ordered —
      `measure-refactor-partitions.py`'s `namespace-audit` reads a file's *first* namespace, and
      `OpenValidity.lean` stays out of the unrelated-namespace bucket for that reason
- [ ] `def NomicFrame.NomicValidOn (F : NomicFrame D) (φ : NomicFormula) : Prop` — truth at every
      time along every nomologically possible world: `∀ M τ, τ ∈ F.HF → ∀ x, NomicTruthAt M τ x φ`.
      **Validity, not truth, is where `τ ∈ F.HF` enters** — the recorded consequence of letting the
      truth recursion range over bare functions
- [ ] `nomic_serial`: **D** for the nomic operator holds over every nomic frame, independently of
      conditions (1)–(6), since `F.lawHist (τ x)` is never empty. An explicit term on Phase 2's
      `lawHist_nonempty`, whose witness comes from `occurrence w w x`. The docstring records that
      this is the one schema in scope that needs no uniformity hypothesis at all
- [ ] `nomic_iff_box_validOn_iff_uniform` is **not** written here — it is an `app:nomic-four`
      result and belongs with its countermodel in Phase 7. What this phase adds instead is the
      collapse *as a validity*: the uniform-frame consequence of Phase 4's
      `nomic_iff_box_of_uniform`, so Phase 7's forward direction is a one-liner
- [ ] The accessibility-relation statement as a validity-level remark in the docstring, pointing at
      Phase 2's `accRel_eq_of_uniform` and `accRel_equivalence_of_uniform` rather than restating
      them: under uniformity the relation is `H_F × H_F`, an equivalence relation, which is the
      frame-level reason every S5 schema holds for the operator on the full language there
- [ ] `Constraints consumed:` plus the `rmk:choice` note on `nomic_serial` — it reaches
      `occurrence`
- [ ] Add the import and `## Modules` bullet to `FormalSystem/NomicLanguage.lean`, add the module
      row to the component README, then `lake exe mk_all --lib FormalSystem` and the
      `git diff -- FormalSystem.lean` inspection

**Timing**: 1 hour

**Depends on**: 2, 4

**Verification Tier**: local

**Commit Mode**: per-substep

**Tier Justification**: `NomicValidity.lean` is a new leaf whose only dependent is
`FormalSystem/NomicLanguage.lean` (Phase 7's module, its one real consumer, does not exist yet),
so
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.NomicLanguage`
covers the whole edit.

**Files to modify**:
- `FormalSystem/NomicLanguage/NomicValidity.lean` - new: `NomicValidOn`, `nomic_serial`, the collapse as a validity
- `FormalSystem/NomicLanguage.lean` - one import line and one `## Modules` bullet
- `FormalSystem/NomicLanguage/README.md` - module row
- `FormalSystem.lean` - regenerated

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.NomicLanguage`
  exits 0
- `grep -c 'sorry' FormalSystem/NomicLanguage/NomicValidity.lean` reports 0
- `grep -nE '^namespace' FormalSystem/NomicLanguage/NomicValidity.lean | head -1` shows
  `namespace FormalSystem.NomicLanguage`, not `FormalSystem.Semantics`
- `python3 scripts/measure-refactor-partitions.py` exits 0 and its `namespace-audit` count is
  unchanged from its pre-phase value (the new file must not join the unrelated-namespace bucket)
- `mcp__lean-lsp__lean_verify FormalSystem.NomicLanguage.nomic_serial` reports a set containing
  `Classical.choice`, confirming the `rmk:choice` docstring claim
- `bash scripts/check-module-invariants.sh` exits 0

---

### Phase 7: `app:nomic-four`, the prose repoints, and the full gate set [NOT STARTED]

**Goal**: axiom 4 for the nomic operator over ℤ-time is valid exactly on the Uniform frames, the
tree stops asserting that the nomic operator has no formalization, and the repository is green
under its complete gate set.

**Tasks**:
- [ ] Create `FormalSystem/NomicLanguage/NomicFour.lean` importing
      `FormalSystem.NomicLanguage.NomicValidity` and `FormalSystem.Semantics.Nomic`
- [ ] The `(⇐)` direction: under `F.Uniform`, `F.lawHist (τ x) = F.HF` for every `τ` and `x`, so
      the nomic and box clauses are literally the same and the nested consequent reduces to the
      antecedent. **No induction at all** — Phase 4's `nomic_iff_box_of_uniform` and Phase 6's
      validity-level collapse do the work
- [ ] The `(⇒)` direction's three delicate steps, each with its probed spelling:
      (a) `¬ F.Uniform → ∃ v, F.lawHist v ≠ F.HF` by `by_contra; push Not at hc` — **`push Not`,
      not the deprecated `push_neg`**;
      (b) `∃ ρ ∈ F.HF, ρ ∉ F.lawHist v` by
      `Set.exists_of_ssubset (LE.le.ssubset_of_ne (lawHist_subset_HF F v) hv)` —
      **`LE.le.ssubset_of_ne`, not the deprecated `HasSubset.Subset.ssubset_of_ne`**;
      (c) `¬ IsStepPath (F.at v) ρ` from `ρ ∉ F.lawHist v` as the `exact`-shaped term
      `fun hs => hρv ((NomicFrame.mem_lawHist_iff_isStepPath F v ρ).mpr hs)` — deliberately **not**
      a `rw`, for 794's recorded carrier-boundary reason — then `by_contra; push Not at hc` for the
      `n` with `¬ (F.at v).step (ρ n) (ρ (n+1))`
- [ ] The countermodel: two atoms `⟨"p", none⟩` and `⟨"q", none⟩`, distinct `by decide` (`Atom`
      derives `DecidableEq`); the two-clause disjunctive valuation
      `fun u a => (a = pA ∧ u = ρ n) ∨ (a = qA ∧ u = ρ (n + 1))`; the witness sentence
      `always (neg (and (atom pA) (next (atom qA))))`; and the two readback lemmas, which need the
      atoms' distinctness. Inside the two satisfaction claims `rw [hpz, hqz] at hstep` **does**
      work — `μ z` and `ρ n` are both `F.World`, so no carrier boundary is crossed
- [ ] The closing argument: `F.occurrence v v 0` gives `τ ∈ F.lawHist v` with `τ 0 = v` and
      `F.occurrence v w 0` gives `σ ∈ F.lawHist v` with `σ 0 = w`; then `rw [hτ0] at hμ` /
      `rw [hσ0]` move between `F.lawHist (τ 0)` and `F.lawHist v`. The nomic operator holds at
      `(τ, 0)`, fails at `(σ, 0)`, and `σ ∈ F.lawHist (τ 0)`, so the nested form fails at `(τ, 0)`
- [ ] `four_validOn_iff_uniform` and `nomic_iff_box_validOn_iff_uniform`: **the same `φ`** separates
      the nomic operator from the box at `(τ, 0)`, since `ρ ∈ F.HF` falsifies it, so both schemata
      are valid over ℤ-time exactly on the Uniform frames
- [ ] `not_four_nomicValid`: the invalidity claim, in `nomic_hierarchy`'s
      `∃ F : NomicFrame intOrder, ∃ _ : F.IsRegular, F.Static ∧ F.Lawful ∧ ¬ …` shape, instantiated
      at `NomicHierarchy.F3` with the instance supplied as the **bare term**
      `NomicFrame.ofStepFamily_isRegular NomicHierarchy.R3 NomicHierarchy.R3.fwd NomicHierarchy.R3.bwd`
      — `F3` is a plain `def`, so `[F3.IsRegular]` does not synthesize. Inside the proof, bind it
      with `haveI` before any call to `occurrence`. The three facts consumed are `F3.static`,
      `F3.lawful` and `F3.not_uniform`
- [ ] The module docstring records the **ℤ-time hypothesis as load-bearing**: without a
      duration-indexed tense operator, a violation at a general duration cannot be localized at
      adjacent times, which is exactly what the one-step extraction needs. The dense case is open
      in the paper's own commented remark and is **not attempted**
- [ ] Repoint the four prose sites now that the formalization exists:
      `FormalSystem/OpenLanguage/README.md`'s "Manuscript operators without a formalization" row
      (today: "**Excluded.** No formalization in this tree");
      `FormalSystem/StarLanguage/README.md`'s correspondence row (today: "The nomic operator stays
      **excluded**: a manuscript operator with no formalization in this tree");
      `FormalSystem/Metalogic/Independence/StateSetTruth.lean`'s `## References` forward pointer
      (today: "No nomic machinery exists in this tree"), which should now name
      `tenseFree_satSet_iff` as the induction it anticipated; and
      `docs/reference/paper-definitions-of-record.md`'s `sub:RestrictedModalities` note (today:
      "while the nomic operator is not"). **Re-read the record file immediately before editing** —
      sibling 802 claims it
- [ ] Add a `NomicLanguage/` row to `FormalSystem/README.md` (readme-lint check 2, **reported not
      gated**). This file is inside sibling 802's declared `file_scope`: re-read it immediately
      before editing, and if it carries foreign uncommitted edits, record the row as a
      `#### Reasoned Exclusions` entry rather than absorbing them
- [ ] Finalize `FormalSystem/NomicLanguage/README.md`: the five modules, the paper anchors each one
      ports, the siting decision and its recorded cost, the three exclusions with their reasons,
      the choice-dependence note, and a `Last verified` date
- [ ] Final `lake exe mk_all --lib FormalSystem` and the `git diff -- FormalSystem.lean`
      inspection
- [ ] Run the full gate set below and fix only this task's own findings; a finding in a file
      outside this task's own file set is possibly a sibling's in-flight edit and is **reported,
      not silently repaired**

**Timing**: 2 hours

**Depends on**: 5, 6

**Verification Tier**: full

**Commit Mode**: per-substep

**Files to modify**:
- `FormalSystem/NomicLanguage/NomicFour.lean` - new: `app:nomic-four` both directions, both schemata, the `F3` instantiation
- `FormalSystem/NomicLanguage.lean` - one import line and one `## Modules` bullet
- `FormalSystem/NomicLanguage/README.md` - finalized
- `FormalSystem/OpenLanguage/README.md` - the excluded-operator row repointed
- `FormalSystem/StarLanguage/README.md` - the correspondence row repointed
- `FormalSystem/Metalogic/Independence/StateSetTruth.lean` - the `## References` forward pointer repointed
- `docs/reference/paper-definitions-of-record.md` - the `sub:RestrictedModalities` note repointed
- `FormalSystem/README.md` - one `NomicLanguage/` row (readme-lint check 2, reported not gated)
- `FormalSystem.lean` - regenerated

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` (full project,
  unscoped) exits 0, run detached with the guard's exit status captured un-piped
- `bash .claude/scripts/verify-deploy.sh` — the complete repository gate set this tier requires —
  exits 0
- `bash scripts/check-module-invariants.sh` exits 0: C1, C3 (zero structural `sorry`, asserted by
  content), C4, C5, C8 (the new sibling aggregator `FormalSystem/NomicLanguage.lean`), C9, C14,
  C15 (the three new anchors and the two repointed rows), C16 (`docBlame` on every new
  declaration), C19 (docstring-coverage floor), C23, C24 (every new module transitively imports
  `FormalSystem.Init`), C26, C28 (the **zero** warning budget), C33 (byte-current generated root),
  C34a/C34b (`Constraints consumed:` honesty)
- `bash scripts/check-metalogic-cycles.sh` exits 0: assertion B reports **no** stale
  `LANGUAGE_FILE_LAYERS` row (all five planned modules exist), and assertion C sees the component's
  layer-0 syntax file and layer-1 semantic files with no upward edge
- `python3 scripts/measure-refactor-partitions.py` exits 0 with no `UnlayeredModuleError`
- `bash scripts/readme-lint.sh FormalSystem` exits 0
- `bash scripts/check-copyright-headers.sh --strict FormalSystem` exits 0
- `bash scripts/typst-sync-check.sh` exits 0
- `grep -c 'sorry' FormalSystem/NomicLanguage/NomicFour.lean` reports 0
- `grep -rn 'push_neg\|HasSubset.Subset.ssubset_of_ne' FormalSystem/NomicLanguage/` returns
  nothing (both spellings are deprecated and `deprecated` is a `blocking` disposition)
- `grep -rni 'no formalization in this tree\|No nomic machinery exists' FormalSystem/` returns no
  hit about the nomic operator — the four prose repoints landed
- `mcp__lean-lsp__lean_verify FormalSystem.NomicLanguage.not_four_nomicValid` reports a set
  containing `Classical.choice`, stated in the docstring as ZFC per `rmk:choice`
- `bash scripts/check-paper-definitions.sh` is **advisory here only**: it is already red with ten
  pre-existing drifted anchors unrelated to this task. Assert only that the four nomic anchors
  themselves resolve under `--resolve '<anchor>|env|-|-'`; do not absorb the drift wave and do not
  re-pin the whole-file sentinels
- Every command's exit status is checked directly; a diff of captured stdout against a baseline is
  not accepted as evidence for any of them
- `git log --oneline` shows one commit per phase with no foreign commit interleaved into this
  task's range

## Lean Challenge Statements

The pinned set is the frame-level uniformity API, the formula type and truth relation, the
tense-free bridge with its five S5 schemata, validity with seriality, and the three
`app:nomic-four` results. Four declarations below deliberately carry **real bodies** rather than
`sorry`: `NomicFormula` and `TenseFree` are `inductive`s, which have no body to replace and whose
constructors every statement below quantifies over; `NomicModel` is a one-field `structure`, and a
`sorry` for it makes `M.valuation` opaque; and `NomicFormula`'s constructor set must be present or
none of the statements mentioning `.nomic`, `.box` or `.imp` elaborates. The derived-operator
layer, the sixteen clause lemmas, the embedding from the base language, and the `app:nomic-four`
countermodel's internals are **not** pinned — the first three are name-for-name transcriptions of
`Syntax/Formula.lean` and `Semantics/TruthClauses.lean`, and the fourth's statements mention
locally bound models and sentences that cannot exist before the phase that builds them. The three
pinned `app:nomic-four` theorems carry the countermodel's joint content.

```lean
import FormalSystem.Semantics.Nomic

namespace FormalSystem.Semantics

variable {D : TemporalOrder}

namespace NomicFrame

/-- Every law-history set is contained in their union. -/
theorem lawHist_subset_HF (F : NomicFrame D) (w : F.World) : F.lawHist w ⊆ F.HF := sorry

/-- Every world state is the state occupied at `x` by some nomologically possible world. -/
theorem exists_mem_HF_eq (F : NomicFrame D) [F.IsRegular] (w : F.World) (x : ↑D) :
    ∃ τ ∈ F.HF, τ x = w := sorry

/-- The law-histories at any state are nonempty -- the content of seriality. -/
theorem lawHist_nonempty (F : NomicFrame D) [F.IsRegular] (w : F.World) (x : ↑D) :
    (F.lawHist w).Nonempty := sorry

/-- `def:nomic-frame`'s accessibility relation at `x`. -/
def accRel (F : NomicFrame D) (x : ↑D) (τ σ : ↑D → F.World) : Prop := sorry

/-- Condition (1) of `thm:nomic-uniform`: transitivity of `accRel` at the time `x`. -/
def TransAt (F : NomicFrame D) (x : ↑D) : Prop := sorry

/-- Condition (2): symmetry of `accRel` at the time `x`. -/
def SymmAt (F : NomicFrame D) (x : ↑D) : Prop := sorry

/-- Condition (3): the Euclidean condition on `accRel` at the time `x`. -/
def EuclAt (F : NomicFrame D) (x : ↑D) : Prop := sorry

/-- Condition (4): `H_F^{τ(x)} = H_F` for every nomologically possible `τ` and every `x`. -/
def PointUniform (F : NomicFrame D) : Prop := sorry

/-- (1) implies (5). -/
theorem uniform_of_transAt (F : NomicFrame D) [F.IsRegular] {x : ↑D} (h : F.TransAt x) :
    F.Uniform := sorry

/-- (2) implies (5). -/
theorem uniform_of_symmAt (F : NomicFrame D) [F.IsRegular] {x : ↑D} (h : F.SymmAt x) :
    F.Uniform := sorry

/-- (3) implies (5). -/
theorem uniform_of_euclAt (F : NomicFrame D) [F.IsRegular] {x : ↑D} (h : F.EuclAt x) :
    F.Uniform := sorry

/-- (5) implies (4). -/
theorem pointUniform_of_uniform {F : NomicFrame D} (h : F.Uniform) : F.PointUniform := sorry

/-- (4) implies (1), at every time. Choice-free. -/
theorem transAt_of_pointUniform {F : NomicFrame D} (h : F.PointUniform) (x : ↑D) :
    F.TransAt x := sorry

/-- (4) implies (2), at every time. Choice-free. -/
theorem symmAt_of_pointUniform {F : NomicFrame D} (h : F.PointUniform) (x : ↑D) :
    F.SymmAt x := sorry

/-- (4) implies (3), at every time. Choice-free. -/
theorem euclAt_of_pointUniform {F : NomicFrame D} (h : F.PointUniform) (x : ↑D) :
    F.EuclAt x := sorry

/-- (5) iff (6): *Uniform* holds exactly when the relativized task relation is independent of the
world state. -/
theorem uniform_iff_taskRel_indep (F : NomicFrame D) [F.IsRegular] :
    F.Uniform ↔ ∀ w u : F.World, F.TaskRel w = F.TaskRel u := sorry

/-- Under uniformity the accessibility relation is `H_F × H_F`. -/
theorem accRel_eq_of_uniform (F : NomicFrame D) (h : F.Uniform) (x : ↑D) :
    ∀ τ σ : ↑D → F.World, F.accRel x τ σ ↔ σ ∈ F.HF := sorry

/-- Under uniformity the accessibility relation restricted to `H_F` is an equivalence relation. -/
theorem accRel_equivalence_of_uniform (F : NomicFrame D) (h : F.Uniform) (x : ↑D) :
    (∀ τ ∈ F.HF, F.accRel x τ τ) ∧
      (∀ τ σ, τ ∈ F.HF → σ ∈ F.HF → F.accRel x τ σ → F.accRel x σ τ) ∧
      (∀ τ σ ρ, F.accRel x τ σ → F.accRel x σ ρ → F.accRel x τ ρ) := sorry

/-- `thm:nomic-uniform`, bundled: conditions (1)-(6) are equivalent. -/
theorem nomic_uniform (F : NomicFrame D) [F.IsRegular] (x : ↑D) :
    (F.TransAt x ↔ F.Uniform) ∧ (F.SymmAt x ↔ F.Uniform) ∧ (F.EuclAt x ↔ F.Uniform) ∧
      (F.PointUniform ↔ F.Uniform) ∧
      ((∀ w u : F.World, F.TaskRel w = F.TaskRel u) ↔ F.Uniform) := sorry

/-- The cut `rmk:nomic-uniform`'s per-state transitivity. -/
def TransAtState (F : NomicFrame D) (w : F.World) : Prop := sorry

/-- Per-state transitivity at `w` is containment of every law-history set in `H_F^w`. -/
theorem transAtState_iff (F : NomicFrame D) [F.IsRegular] (w : F.World) :
    F.TransAtState w ↔ ∀ u : F.World, F.lawHist u ⊆ F.lawHist w := sorry

/-- Per-state transitivity everywhere is *Uniform*. -/
theorem uniform_iff_forall_transAtState (F : NomicFrame D) [F.IsRegular] :
    (∀ w : F.World, F.TransAtState w) ↔ F.Uniform := sorry

end NomicFrame

end FormalSystem.Semantics

namespace FormalSystem.NomicLanguage

open FormalSystem.Syntax FormalSystem.Semantics

/-- The language of the base system plus the nomic operator. -/
inductive NomicFormula : Type where
  | atom : Atom → NomicFormula
  | bot : NomicFormula
  | imp : NomicFormula → NomicFormula → NomicFormula
  | box : NomicFormula → NomicFormula
  | untl : NomicFormula → NomicFormula → NomicFormula
  | snce : NomicFormula → NomicFormula → NomicFormula
  | nomic : NomicFormula → NomicFormula

variable {D : TemporalOrder}

/-- A model on a nomic frame: a valuation on world states. -/
structure NomicModel (F : NomicFrame D) where
  valuation : F.World → Atom → Prop

/-- Truth at a bare state function and a time, with `def:nomic-frame`'s Nomic clause. -/
def NomicTruthAt {F : NomicFrame D} (M : NomicModel F) (τ : ↑D → F.World) (x : ↑D) :
    NomicFormula → Prop := sorry

/-- Under uniformity the nomic operator and the box agree on every formula. Choice-free. -/
theorem nomic_iff_box_of_uniform {F : NomicFrame D} (h : F.Uniform) (M : NomicModel F)
    (τ : ↑D → F.World) (x : ↑D) (φ : NomicFormula) :
    NomicTruthAt M τ x (.nomic φ) ↔ NomicTruthAt M τ x (.box φ) := sorry

/-- `prop:nomic-tense-free`'s fragment: atoms, falsum, implication, box and the nomic operator. -/
inductive TenseFree : NomicFormula → Prop where
  | atom (p : Atom) : TenseFree (.atom p)
  | bot : TenseFree .bot
  | imp {φ ψ} : TenseFree φ → TenseFree ψ → TenseFree (.imp φ ψ)
  | box {φ} : TenseFree φ → TenseFree (.box φ)
  | nomic {φ} : TenseFree φ → TenseFree (.nomic φ)

/-- The state set of a formula, total on the full type, with the ignoring-set clause of
`StateSetTruth.lean` for both the box and the nomic operator. -/
def nomicSatSet {F : NomicFrame D} (V : F.World → Atom → Prop) :
    NomicFormula → Set F.World := sorry

/-- `prop:nomic-tense-free`'s bridge, for an arbitrary bare `τ` -- strictly stronger than the
paper's statement, which assumes `τ ∈ H_F`. -/
theorem tenseFree_satSet_iff {F : NomicFrame D} [F.IsRegular] (M : NomicModel F) :
    ∀ φ : NomicFormula, TenseFree φ → ∀ (τ : ↑D → F.World) (x : ↑D),
      NomicTruthAt M τ x φ ↔ τ x ∈ nomicSatSet M.valuation φ := sorry

/-- The nomic operator and the box agree on the tense-free fragment, over every nomic frame. -/
theorem nomic_iff_box_tenseFree {F : NomicFrame D} [F.IsRegular] (M : NomicModel F)
    {φ : NomicFormula} (hφ : TenseFree φ) (τ : ↑D → F.World) (x : ↑D) :
    NomicTruthAt M τ x (.nomic φ) ↔ NomicTruthAt M τ x (.box φ) := sorry

/-- K for the nomic operator on the fragment. -/
theorem nomic_k_tenseFree {F : NomicFrame D} [F.IsRegular] (M : NomicModel F)
    {φ ψ : NomicFormula} (hφ : TenseFree φ) (hψ : TenseFree ψ) (τ : ↑D → F.World) (x : ↑D) :
    NomicTruthAt M τ x (.imp (.nomic (.imp φ ψ)) (.imp (.nomic φ) (.nomic ψ))) := sorry

/-- T for the nomic operator on the fragment, over every nomic frame -- including the non-*Lawful*
ones, since the fragment collapse already degenerates the operator into the box. -/
theorem nomic_t_tenseFree {F : NomicFrame D} [F.IsRegular] (M : NomicModel F)
    {φ : NomicFormula} (hφ : TenseFree φ) (τ : ↑D → F.World) (x : ↑D) :
    NomicTruthAt M τ x (.imp (.nomic φ) φ) := sorry

/-- 4 for the nomic operator on the fragment. -/
theorem nomic_four_tenseFree {F : NomicFrame D} [F.IsRegular] (M : NomicModel F)
    {φ : NomicFormula} (hφ : TenseFree φ) (τ : ↑D → F.World) (x : ↑D) :
    NomicTruthAt M τ x (.imp (.nomic φ) (.nomic (.nomic φ))) := sorry

/-- 5 for the nomic operator on the fragment. -/
theorem nomic_five_tenseFree {F : NomicFrame D} [F.IsRegular] (M : NomicModel F)
    {φ : NomicFormula} (hφ : TenseFree φ) (τ : ↑D → F.World) (x : ↑D) :
    NomicTruthAt M τ x (.imp (.imp (.nomic φ) .bot)
      (.nomic (.imp (.nomic φ) .bot))) := sorry

/-- B for the nomic operator on the fragment. -/
theorem nomic_b_tenseFree {F : NomicFrame D} [F.IsRegular] (M : NomicModel F)
    {φ : NomicFormula} (hφ : TenseFree φ) (τ : ↑D → F.World) (x : ↑D) :
    NomicTruthAt M τ x (.imp φ (.nomic (.imp (.nomic (.imp φ .bot)) .bot))) := sorry

end FormalSystem.NomicLanguage

namespace FormalSystem.Semantics

open FormalSystem.NomicLanguage

/-- Validity on a nomic frame: truth at every time along every nomologically possible world. -/
def NomicFrame.NomicValidOn {D : TemporalOrder} (F : NomicFrame D) (φ : NomicFormula) : Prop :=
  sorry

/-- D for the nomic operator, over every nomic frame, independently of conditions (1)-(6). -/
theorem nomic_serial {D : TemporalOrder} (F : NomicFrame D) [F.IsRegular] (φ : NomicFormula) :
    F.NomicValidOn (.imp (.nomic φ) (.imp (.nomic (.imp φ .bot)) .bot)) := sorry

/-- `app:nomic-four`: over ℤ-time, axiom 4 for the nomic operator is valid exactly on the Uniform
frames. -/
theorem four_validOn_iff_uniform (F : NomicFrame intOrder) [F.IsRegular] :
    (∀ φ : NomicFormula, F.NomicValidOn (.imp (.nomic φ) (.nomic (.nomic φ)))) ↔ F.Uniform :=
  sorry

/-- `app:nomic-four`: over ℤ-time, the nomic operator and the box are interderivable exactly on
the Uniform frames. -/
theorem nomic_iff_box_validOn_iff_uniform (F : NomicFrame intOrder) [F.IsRegular] :
    (∀ φ : NomicFormula, F.NomicValidOn (.imp (.nomic φ) (.box φ)) ∧
        F.NomicValidOn (.imp (.box φ) (.nomic φ))) ↔ F.Uniform :=
  sorry

/-- `app:nomic-four`'s invalidity claim: axiom 4 for the nomic operator fails over a *Static* and
*Lawful* ℤ-time frame -- the static-and-lawful witness of `prop:nomic-hierarchy`. -/
theorem not_four_nomicValid :
    ∃ F : NomicFrame intOrder, ∃ _ : F.IsRegular,
      F.Static ∧ F.Lawful ∧
        ¬ ∀ φ : NomicFormula, F.NomicValidOn (.imp (.nomic φ) (.nomic (.nomic φ))) := sorry

end FormalSystem.Semantics
```

## Testing & Validation

- [ ] `lake build FormalSystem` green with zero new `sorry` at the end of **every** phase (the
      task's stated constraint), checked by `grep -c 'sorry'` per new file and by C3 at the end
- [ ] `nomicSatSet V (.nomic φ) = nomicSatSet V (.box φ)` pinned as `rfl` by an `example` — the
      identity the whole fragment collapse rests on
- [ ] The tense-free bridge exercised in both directions at both the `box` and the `nomic` clause,
      and its `untl`/`snce` cases reached (they are `intro h; cases h`, so a change to `TenseFree`
      that admitted a temporal constructor would break here rather than silently)
- [ ] All six conditions of `thm:nomic-uniform` reached as named theorems, in both directions of
      the cycle, following `Semantics/FrameConstraintIndependence.lean`'s per-condition house style
      rather than only a bundled statement; `nomic_uniform` sits on top of them
- [ ] Both directions of `app:nomic-four` proved, and the same witness sentence shown to separate
      the nomic operator from the box — not two different sentences
- [ ] Seriality proved as its own theorem, with its docstring recording that it needs no condition
      from `thm:nomic-uniform`
- [ ] `lean_verify` run on `transAt_of_pointUniform` and `nomic_iff_box_of_uniform` (expect
      `[propext]`, the two genuinely choice-free results) and on `tenseFree_satSet_iff`,
      `uniform_of_transAt`, `nomic_serial` and `not_four_nomicValid` (expect `Classical.choice`
      present), with every measured set stated in the corresponding docstring — ZFC, never
      advertised as choice-free
- [ ] `bash scripts/check-module-invariants.sh` exits 0 (Phases 1, 4, 5, 6 and 7)
- [ ] `bash scripts/check-metalogic-cycles.sh` exits 0 with no stale `LANGUAGE_FILE_LAYERS` row
      (Phases 3 and 7)
- [ ] `bash scripts/readme-lint.sh FormalSystem` exits 0 (Phases 2, 3 and 7)
- [ ] `bash .claude/scripts/verify-deploy.sh` exits 0 (Phase 7)

## Artifacts & Outputs

- `FormalSystem/Semantics/Nomic/Uniformity.lean` — `thm:nomic-uniform`'s six conditions, the
  `H_F × H_F` identification, and the cut `rmk:nomic-uniform`'s side lemma
- `FormalSystem/NomicLanguage/Formula.lean` — `NomicFormula`, the derived operators, and the
  embedding from the base language
- `FormalSystem/NomicLanguage/NomicTruth.lean` — `NomicModel`, `NomicTruthAt` with
  `def:nomic-frame`'s Nomic clause, the sixteen clause lemmas, and the uniformity collapse
- `FormalSystem/NomicLanguage/NomicTenseFree.lean` — `prop:nomic-tense-free`: `TenseFree`,
  `nomicSatSet`, the bridge, the fragment collapse, and the five S5 schemata
- `FormalSystem/NomicLanguage/NomicValidity.lean` — `NomicValidOn` and seriality
- `FormalSystem/NomicLanguage/NomicFour.lean` — `app:nomic-four`, both directions, both schemata,
  and the `F3` instantiation
- `FormalSystem/NomicLanguage.lean` — the sibling aggregator
- `FormalSystem/NomicLanguage/README.md` — the component README, carrying the siting decision and
  the three recorded exclusions
- `FormalSystem/Semantics/Nomic.lean`, `FormalSystem/Semantics/Nomic/README.md`,
  `FormalSystem/README.md`, `FormalSystem.lean` — wiring
- `scripts/measure-refactor-partitions.py` — the `"NomicLanguage"` `LANGUAGE_FILE_LAYERS` entry
- `docs/reference/paper-definitions-of-record.md` — three new rows, three repointed notes
- `FormalSystem/OpenLanguage/README.md`, `FormalSystem/StarLanguage/README.md`,
  `FormalSystem/Metalogic/Independence/StateSetTruth.lean` — the three prose repoints
- `specs/795_nomic_operator_uniformity_axiom_four/summaries/01_nomic-operator-uniformity-axiom-four-summary.md`
  — the implementation summary

## Rollback/Contingency

Every phase is additive: six new modules, one new aggregator, one new README, one Python dict
entry, and a handful of single-line inserts and note repoints in existing files. A phase that
fails is rolled back by deleting its new file(s) and reverting its one aggregator/root line, which
leaves the tree exactly as the previous phase's commit left it — no destructive git operation is
needed for the ordinary case, and none should be run, because two sibling tasks are live on this
same working tree and one of them (797) declares no `file_scope` at all.

If a genuine working-tree rollback becomes unavoidable, take the snapshot first per
`context/contracts/recovery.md`'s rollback rung and use the invocation shape recorded there. Do
**not** run `git-snapshot.sh` in its reverting default mode as a precaution — it can discard a
concurrent sibling's in-flight edits along with this task's rollback target. For an ordinary
defensive checkpoint before Phase 7's countermodel work, use
`bash .claude/scripts/git-snapshot.sh 795 --no-revert`, which is durable without touching the
working tree.

Contingency branches already built into the plan:

- **Phase 7's `(⇒)` direction stalls.** Phases 1-6 have already landed the whole of
  `thm:nomic-uniform`, `prop:nomic-tense-free`, seriality and the uniformity collapse, and the
  `(⇐)` direction of `app:nomic-four` is a one-liner from Phase 6. Mark the phase `[BLOCKED]` and
  raise it, with the three schema theorems and the `F3` instantiation outstanding — never a
  `sorry`, and never a vacuous placeholder.
- **`FormalSystem/README.md` carries foreign uncommitted edits in Phase 7.** The row is
  readme-lint check 2, reported and not gated, so close the phase with a
  `#### Reasoned Exclusions` record naming the row, the sibling-territory reason, and
  `git status --short -- FormalSystem/README.md` as the evidence, rather than absorbing another
  task's edits.
- **`linter.unnecessarySimpa` proves unavoidable somewhere.** It has no disposition row in
  `scripts/warning-budget.txt` and therefore exits 2 rather than failing softly, so the branch is
  to land a reasoned disposition row in the same change — not to suppress the warning locally and
  not to leave it unlisted.
