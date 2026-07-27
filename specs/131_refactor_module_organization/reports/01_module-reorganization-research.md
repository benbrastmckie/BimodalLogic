# Module Reorganization Research

**Task**: 131 — refactor_module_organization
**Date**: 2026-07-26
**Baseline commit**: e832cc72a (working tree clean)
**Build state at research time**: `lake build` GREEN — "Build completed successfully (1884 jobs)", exit 0

---

## 0. Re-measurement (charter figures were stale again)

The charter instructed re-measurement because predecessors move files. They did. Every headline
figure in the charter is now wrong:

| Quantity | Charter says | **Measured 2026-07-26** | Delta |
|---|---|---|---|
| Live `.lean` files (excl. Boneyard) | 277 | **288** | +11 |
| Top-level entries under `Theories/Bimodal/` | 12 | **12** (9 code dirs + docs/latex/typst) | ok |
| `Metalogic/` subdirectories | 8 | **8** | ok |
| `Metalogic/` loose `.lean` files | 5 | **5** | ok |
| Boneyard files | 92 files / 58,476 lines | **154 files / 85,870 lines** | +62 files |

### The Boneyard figure was wrong because there are TWO Boneyards

```
Theories/Bimodal/Boneyard                                92 files / 58,476 lines
Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Boneyard   62 files / 27,394 lines
```

The charter counted only the first. Any tooling, count, or `find` in the implementation plan must
exclude **both** — a plan that greps `-not -path '*/Boneyard/*'` is fine; one that excludes only
`Theories/Bimodal/Boneyard` will silently sweep 27k lines of archived Kamp material into "live"
counts.

### Measured size distribution (live only)

| Top-level dir | Files | Lines | Share of live source |
|---|---:|---:|---:|
| **Metalogic** | **270** | **176,210** | **93.8%** |
| Automation | 35 | 21,576 | 11.5% |
| Theorems | 13 | 7,017 | 3.7% |
| Syntax | 8 | 3,404 | 1.8% |
| Semantics | 5 | 1,856 | 1.0% |
| ProofSystem | 4 | 1,142 | 0.6% |
| FrameConditions | 4 | 816 | 0.4% |
| Examples | 2 | 533 | 0.3% |

(Percentages exceed 100% because Metalogic's 270 counts nested files; the point stands — this is a
Metalogic-shaped repository with a thin shell around it.)

### Metalogic internals

| Subtree | Files | Lines |
|---|---:|---:|
| `WeakCanonical/` | 197 | 133,396 |
| `BXCanonical/` | 21 | 18,561 |
| `Decidability/` | 19 | 9,263 |
| `Bundle/` | 12 | 4,650 |
| `Algebraic/` | 9 | 3,748 |
| `Core/` | 4 | 2,048 |
| `SoundnessLemmas/` | 3 | 2,461 |
| **`Relational/`** | **0** | **0** |

Loose files: `Soundness.lean` (1394), `Completeness.lean` (534), `Metalogic.lean` (90),
`Decidability.lean` (52), `WeakCanonical.lean` (13).

`WeakCanonical/` decomposes as `Kamp/` (161 files, of which 62 are its own Boneyard → **99 live**,
71,246 lines), `EFGames/` (8), `IntegerModel/` (6), `Expressiveness/` (5), `Separation/` (3), plus
14 loose files. Inside `Kamp/`: `NfMultiAnchorBridge/` (43 files / 41,859 lines) and
`EANegationFix/` (7 files / 3,227 lines).

**`Relational/` is empty** — it contains only a `README.md` describing itself as a placeholder,
tracked in git, with zero `.lean` files. The charter listed it as a live subdirectory.

---

## 1. Verification anchors (establish these before any move)

### The sole live sorry — located BY CONTENT as instructed

Exactly **one** structural `sorry` exists in live source. Naive `grep -rn '\bsorry\b'` returns 273
hits and is useless — the overwhelming majority are prose in docstrings ("sorry-free",
"the sorry chain", "3 sorry sites"). The structural count uses:

```bash
grep -rnE --include='*.lean' \
  '(^[[:space:]]*sorry[[:space:]]*$)|(:=[[:space:]]*sorry[[:space:]]*$)|(\bexact sorry\b)|(<;> sorry)' \
  Theories | grep -v '/Boneyard/'
# -> exactly 1 hit
```

**Content anchor** (never a line number):

- File: `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean`
- Enclosing declaration: `theorem countermodel_discrete`
- Namespace: `Bimodal.Metalogic.WeakCanonical`
- Signature head: `(A : Set Formula) (h_mcs : SetMaximalConsistent (fc := FrameClass.Base) A) (φ : Formula) (h_neg_in : φ.neg ∈ A) (h_box_discrete : Formula.box next_top ∈ A)`
- Preceding comment marker: `-- SORRY: open obligation. This was formerly proved through the BX pipeline`

The build independently confirms it: `warning: Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean:1225:8: declaration uses 'sorry'` — one such warning, no others.

### Axiom-level anchors (stronger than sorry counting)

The build emits `#print axioms` results that pin the flagship theorems. Capture these verbatim as
the phase-boundary gate:

```
completeness_dense    depends on axioms: [propext, Classical.choice, Quot.sound]
completeness_discrete depends on axioms: [propext, Classical.choice, Quot.sound]
completeness          depends on axioms: [propext, sorryAx, Classical.choice, Quot.sound]
countermodel_dense    depends on axioms: [propext, Classical.choice, Quot.sound]
```

A file move that accidentally changes an import can silently reroute a proof; the axiom lines catch
that where a sorry count would not. **Recommend the plan use these four lines as the invariant**,
not just "sorry count unchanged".

### `BimodalTest` green is a weaker gate than it appears

8 test modules are unreachable from `Tests/BimodalTest.lean` and therefore never compile:

```
BimodalTest.Automation.FormulaMutatorTest      (190 lines)
BimodalTest.Automation.InterestingnessTest     (349)
BimodalTest.Automation.ProofFirstTests         (228)
BimodalTest.ProofSystem.DerivationBenchmark    (369)
BimodalTest.Semantics.SemanticBenchmark        (351)
BimodalTest.TraceCertificateTest               (220)
BimodalTest.TraceExportTest                    (167)
BimodalTest.TraceExporterE2ETest               (146)
```

These will not catch a broken import. The plan should either wire them in (out of scope — they are
name-stable, so this does not conflict with the naming task) or explicitly acknowledge that the
test gate does not cover them.

---

## 2. Findings that change the shape of the task

### Finding A — Goal (2) is ~99% already done; the real defect is doc *accuracy*, not coverage

287 of 288 live files already carry a `/-!` module-doc block near the top. The only file without
one is `Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean`.

Namespace/directory alignment is likewise near-perfect: exactly **one** file's namespace disagrees
with its path — `Theories/Bimodal/Automation/EFGameTactics.lean` declares
`namespace Bimodal.Metalogic.WeakCanonical`. That is a genuine misplacement (a Metalogic file
living in Automation) and is the one file whose *location* the docs goal actually implicates.

What is badly broken is that the existing documentation describes a repository that no longer
exists:

- **`Metalogic/README.md`** claims these files, none of which exist: `Core/Core.lean`,
  `Bundle/SuccExistence.lean`, `Bundle/Completeness.lean`, `Bundle/TruthLemma.lean`,
  `Bundle/BFMCSTruth.lean`, `Algebraic/AlgebraicCompleteness.lean`, `Decidability/FMP.lean`,
  `WeakCanonical/ExpressiveCompleteness/`. Its dependency flowcharts are drawn over those
  non-existent modules. It describes `WeakCanonical/Separation/` as "11+ files" (it has 3) and
  **omits `Kamp/` entirely** — 99 live files and 71,246 lines, the single largest thing in the
  repository, is absent from the architecture map.
- **`Metalogic/Metalogic.lean`** docstring's "Module Structure" block lists `SoundnessLemmas.lean`
  as a file (it is a directory) and `BXCanonical/Filtration/`, `Decidability/FMP/`,
  `WeakCanonical/Separation/` without `Kamp/`.
- **`FrameConditions.lean`** docstring lists `Completeness.lean` in its structure block;
  `FrameConditions/` contains only `FrameClass.lean`, `Validity.lean`, `Soundness.lean`,
  `Compatibility.lean`, `README.md`.

**Implication for the plan**: budget the documentation phase for *rewriting stale maps*, not for
*adding missing docstrings*. The latter is a one-file job.

### Finding B — Directory-level import cycles block the obvious reorganization

The charter's goal (1) asks to "group completeness files". The naive execution — create
`Metalogic/Completeness/{BXCanonical,WeakCanonical,Algebraic}/` — assumes those three are
siblings in a layered DAG. **They are not.** Measured cross-subtree edges:

```
Bundle          -> Core             18
BXCanonical     -> Bundle            9
Algebraic       -> Bundle            6
BXCanonical     -> Core              4
WeakCanonical   -> Algebraic         4
WeakCanonical   -> BXCanonical       4     <-- mutual
Algebraic       -> Core              3
Decidability    -> Core              3
BXCanonical     -> WeakCanonical     2     <-- mutual
BXCanonical     -> Algebraic         2
WeakCanonical   -> Core              2
WeakCanonical   -> Bundle            2
Decidability    -> Soundness         2
Core            -> Bundle            1     <-- mutual
Soundness       -> SoundnessLemmas   1
```

Two directory-level cycles exist:

1. **`BXCanonical` ↔ `WeakCanonical`** (4 edges one way, 2 the other). Exact edges:
   - `WeakCanonical/ChronicleExtraction.lean` → `BXCanonical.Chronicle.ChronicleConstruction`, `BXCanonical.Chronicle.ChronicleToCountermodelBasic`
   - `WeakCanonical/ReflexiveCanonical.lean` → `BXCanonical.OrderedSeedConsistency`
   - `WeakCanonical/Transfer.lean` → `BXCanonical.Chronicle.ChronicleToCountermodel`
   - `BXCanonical/Completeness.lean` → `Bimodal.Metalogic.WeakCanonical`
   - `BXCanonical/Chronicle/ChronicleToCountermodel.lean` → `WeakCanonical.IntegerModel.GoodStructuresModelSurgery`
2. **`Core` ↔ `Bundle`** (1 back-edge): `Core/RestrictedMCS/Basic.lean` →
   `Bundle.CanonicalTaskRelation`.

Lean permits this (cycles are at the *directory* level, not the module level — the module DAG is
acyclic, which is why it builds). But it means the three-way relationship the charter identifies as
"the central organizing question" is genuinely tangled, and **directory nesting cannot express it**.
Any proposal that nests BXCanonical under WeakCanonical or vice versa will produce a directory whose
contents import upward out of it.

**Recommended reading of goal (1)**: the deliverable is a *documented* three-way relationship (a
correct architecture map plus aggregator-level API boundaries), not a physical regrouping that the
dependency graph will not support. A physical regroup is defensible only for the genuinely-layered
part: `Core` → `Bundle` → {`Algebraic`, `BXCanonical`, `WeakCanonical`}, with the two back-edges
called out as known exceptions or resolved by moving the two offending files.

The one cheap structural win: `Core/RestrictedMCS/Basic.lean` is the *sole* Core→Bundle edge.
Relocating that one file (e.g. to `Bundle/RestrictedMCS/`) makes `Core` a true leaf foundation and
removes one of the two cycles. Blast radius is small — see §3.

### Finding C — Three incompatible aggregator conventions coexist (goal 3)

| Pattern | Where | Count |
|---|---|---|
| Sibling `Bimodal/X.lean` next to `Bimodal/X/` | Syntax, ProofSystem, Semantics, FrameConditions, Theorems, Automation, Examples | 7 |
| Self-named inner `X/X.lean` | `Metalogic/Metalogic.lean`, `BXCanonical/BXCanonical.lean`, `WeakCanonical/WeakCanonical.lean` | 3 |
| **Both at once** | `Metalogic/WeakCanonical.lean` (13-line stub) **and** `WeakCanonical/WeakCanonical.lean` (80 lines) | 1 |
| **None** | `Metalogic/Core/`, `Metalogic/Bundle/`, `Metalogic/Algebraic/`, `Metalogic/SoundnessLemmas/`, `Metalogic/Relational/` | 5 |

The asymmetry surfaces in the root file: `Bimodal.lean` imports `Bimodal.Syntax`,
`Bimodal.ProofSystem`, `Bimodal.Semantics`, `Bimodal.FrameConditions`, … but
`Bimodal.Metalogic.Metalogic` — the one qualified odd-man-out. `Bimodal.lean`'s own References
section then links `[Metalogic.lean](Metalogic.lean)`, a path that does not exist.

**Mathlib comparison** (checked against the vendored `v4.33.0-rc1` at
`.lake/packages/mathlib/`): Mathlib uses **neither** convention. There is no
`Mathlib/Order.lean` beside `Mathlib/Order/`, and no self-named `Mathlib/X/X.lean` anywhere. Its
single root `Mathlib.lean` is a flat 8,274-line list of `public import` lines covering every module.

So there is no upstream authority to appeal to — the sibling pattern is a local convention. Since
7 of 8 top-level directories already follow it, **standardize on sibling aggregators**:
`Metalogic.lean` moves out to sit beside `Metalogic/`, the 13-line `Metalogic/WeakCanonical.lean`
stub and `WeakCanonical/WeakCanonical.lean` collapse into one, and the 5 aggregator-less
subdirectories gain one each. That satisfies goal (3) with a rule that is checkable by script.

### Finding D — Dead modules

Reachability computed from all real roots (`Bimodal`, `BimodalTest`, and all 12 `lean_exe` roots
declared in `lakefile.lean`) leaves these live-tree modules unreachable:

| Module | Lines | Note |
|---|---:|---|
| `Bimodal.Metalogic.Completeness` | 534 | Loose Metalogic file. Nothing live imports it — the only import line anywhere is from a Boneyard file. Yet `Metalogic/README.md` and `Metalogic.lean` both document it as live. |
| `Bimodal.ProofSystem.LinearityDerivedFacts` | 88 | |
| `Bimodal.Automation.ProofFirstBenchmark` | 173 | Not an `lean_exe` root. |

`Metalogic/Completeness.lean` is the notable one: 534 lines of documented-as-live, actually-dead
code sitting in the directory the task is chartered to clarify. Resolving it (wire in, or archive
to Boneyard) is squarely in scope and is a pure-move operation.

### Finding E — FrameConditions sits ABOVE Metalogic; do not merge it in (goal 4)

Measured layering is unambiguous:

- Files in `Metalogic/` that import `Bimodal.FrameConditions`: **0**
- `FrameConditions/` imports `Bimodal.Metalogic.Soundness`, `Bimodal.ProofSystem.Axioms`,
  `Bimodal.Semantics.Validity`, plus 5 Mathlib modules
- Nothing outside `FrameConditions/` imports it except `Bimodal.lean` (the root)

FrameConditions is a thin (4 files / 816 lines) typeclass-API layer that *consumes* Metalogic and is
consumed only by the library root. Merging it into `Metalogic/` would invert the dependency
direction and manufacture a new cycle.

One disambiguation the plan must not get wrong: the 97 files referencing the identifier `FrameClass`
are referencing `Bimodal.ProofSystem.Axioms.FrameClass` — an `inductive` declared at
`ProofSystem/Axioms.lean:378`, used as `FrameClass.Base` / `FrameClass.Discrete`. That is a
*different thing* from `FrameConditions/FrameClass.lean`, which declares the typeclasses
`LinearTemporalFrame`, `SerialFrame`, `DenseTemporalFrame`, `DiscreteTemporalFrame`. A name-based
audit will conflate them.

**Recommendation for goal (4): keep `FrameConditions/` separate.** The evidence is a clean
one-directional layering, not a judgement call.

### Finding F — 79 task-number references inside `Theories/` violate a project rule

`.claude/rules/no-task-references-in-deliverables.md` forbids task-number citations outside
`specs/**`. `Theories/` currently contains 79. Fourteen of them are notes planted *for this task*:

```
> **Note**: This README was last verified before task 131 (module reorg) -- verify
> file list is still current after that task completes.
```

…in `Theories/Bimodal/README.md`, `Metalogic/README.md`, and 11 subdirectory READMEs. The rest are
inline citations such as `(task 309 Phase 8)` in `Kamp/NfMultiAnchorBridge/Base.lean`,
`## Reflexive G/H Semantics (Task 29)` in `Bundle/README.md`, and
`moved to Boneyard/UltrafilterFrame/, task 21` in `Algebraic/README.md`.

Since this task is already rewriting those exact READMEs, stripping the citations (replacing them
with durable anchors per the rule) is nearly free here and expensive later. **This does not conflict
with the naming task** — it touches prose, not declarations.

### Finding G — Goal (6): a root `docs/` already exists

`Theories/Bimodal/docs/` (30 md files, 404K) is **not** the only docs tree — the repository root
already has `docs/` (with `docs/README.md`, `docs/project-info/`). The root one cross-links into the
source-tree one using `../Theories/Bimodal/docs/...` relative paths.

External references that break if `docs/`, `latex/`, or `typst/` move out of the source root:

| Referencing file | Count | Kind |
|---|---:|---|
| `docs/README.md` | 14 | relative markdown links |
| `README.md` (root) | 5 | markdown links incl. `Theories/Bimodal/latex/BimodalReference.pdf` |
| `scripts/typst-machine-appendix.sh` | 3 | hardcoded `GEN_DIR` path |
| `scripts/typst-status-counts.sh` | 1 | comment |
| `scripts/typst-sync-check.sh` | 1 | comment |
| `lakefile.lean` | 1 | doc comment on `machine_appendix` exe |
| `docs/project-info/FEATURE_REGISTRY.md`, `docs/project-info/MAINTENANCE.md` | 2 | links |

Also note `Theories/Bimodal/BimodalReference.pdf` sits loose in the source root while
`README.md` links it at `Theories/Bimodal/latex/BimodalReference.pdf` — a pre-existing broken
link worth fixing regardless.

`typst/` is 2.0M and contains a generated-artifact subdirectory (`generated/`) plus a `.gitignore`,
a `.jsonl`, and a `.pdf`. These are build outputs living inside a Lean source root.

**Recommendation**: move all three to the project root (`docs/bimodal/` or merge into existing
`docs/`, plus root-level `latex/` and `typst/`). Rationale grounded in measurement, not taste:
(a) `srcDir := "Theories"` means Lake treats this tree as source, and 2.4M of non-Lean assets sit
inside it; (b) a root `docs/` already exists, so the current split is *already* incoherent;
(c) the update cost is ~27 references in 8 files, all mechanical. Per the charter this decision is
made here and the source-root rename is left to the naming task.

---

## 3. Blast radius (sizes each candidate move)

Import lines referencing each Metalogic subtree, live `.lean` + `Tests` only:

| Subtree | Import lines | Files touched |
|---|---:|---:|
| `WeakCanonical` | **581** | **137** |
| `Decidability` | 73 | 28 |
| `BXCanonical` | 67 | 23 |
| `Core` | 60 | 24 |
| `Bundle` | 102 | 23 |
| `Algebraic` | 38 | 10 |
| `Metalogic` (the aggregator) | 7 | 7 |
| `Soundness` | 7 | 5 |
| `SoundnessLemmas` | 3 | 3 |
| `Completeness` | 1 | 0 (Boneyard only — dead) |

Totals: **561 live import lines** mention `Bimodal.Metalogic` (939 including Boneyard). **28
markdown files** additionally reference `Bimodal.Metalogic.*` module paths in prose and code fences
— these will not be caught by a `.lean`-only rewrite and are the most likely source of a
"complete-looking but actually partial" move.

Read this table as a cost ranking. Renaming/moving `WeakCanonical` is a 581-line, 137-file
operation and is the single riskiest thing the plan could attempt; `SoundnessLemmas`, `Soundness`,
and the aggregator restructure are 3–7 lines each.

---

## 4. Recommended scope, ordered by value/risk

Ranked cheapest-and-safest first. Every item is a file move, a doc edit, or an aggregator addition —
**no declaration renames**, per the charter's hard constraint.

**Tier 1 — high value, near-zero risk (≤7 import lines each)**
1. Standardize aggregators: move `Metalogic/Metalogic.lean` → `Theories/Bimodal/Metalogic.lean`;
   collapse the duplicate `Metalogic/WeakCanonical.lean` stub + `WeakCanonical/WeakCanonical.lean`;
   fold `BXCanonical/BXCanonical.lean` to the sibling position; add missing aggregators for `Core`,
   `Bundle`, `Algebraic`, `SoundnessLemmas`. Update `Bimodal.lean`'s import to `Bimodal.Metalogic`.
2. Resolve dead modules: `Metalogic/Completeness.lean` (534 lines), `ProofSystem/LinearityDerivedFacts.lean`,
   `Automation/ProofFirstBenchmark.lean` — wire in or archive.
3. Move `Automation/EFGameTactics.lean` into `Metalogic/WeakCanonical/` to match its declared namespace.
4. Delete or populate the empty `Metalogic/Relational/` (README-only placeholder).
5. Add the one missing module docstring (`Kamp/NfMultiAnchorBridge.lean`).

**Tier 2 — the actual documentation work**
6. Rewrite `Metalogic/README.md` against measured reality: correct the file lists, redraw the
   dependency maps over modules that exist, and **add the `Kamp/` subtree** (99 live files / 71,246
   lines) which is currently absent.
7. Rewrite the `Metalogic.lean` and `FrameConditions.lean` structure blocks.
8. Strip the 79 task-number references, replacing them with durable anchors.
9. Add READMEs for the 5 uncovered directories (`Kamp/`, `Kamp/NfMultiAnchorBridge/`,
   `Kamp/EANegationFix/`, `Kamp/NfMultiAnchorBridge/SharedWitness/`, `Decidability/Propositional/`).

**Tier 3 — decisions, cheap to execute**
10. Goal (4): keep `FrameConditions/` separate — record the layering evidence.
11. Goal (6): move `docs/`, `latex/`, `typst/` to project root; update ~27 references in 8 files.
12. Goal (5): Boneyard audit — 154 files / 85,870 lines across two locations; at minimum document
    that the Kamp-local Boneyard exists, since every count in the repo currently misses it.

**Tier 4 — only if the plan wants structural change, and only with eyes open**
13. Relocate `Core/RestrictedMCS/Basic.lean` to break the `Core` ↔ `Bundle` cycle (1 edge).
14. Any physical regrouping of `BXCanonical` / `WeakCanonical` / `Algebraic`. **Recommend deferring
    or declining**: the mutual cycle means directory nesting cannot express the relationship, and the
    `WeakCanonical` blast radius (581 import lines / 137 files) is where a partial move — the failure
    mode the charter explicitly names as "worse than no move" — is most likely.

---

## 5. Constraints for the planner

- **No declaration renames.** Every operation above is `git mv` + import rewrite + prose. The
  systematic naming upgrade runs after this task and will churn twice if names move now.
- **Verification at every phase boundary**: `lake build` green (baseline: 1884 jobs, exit 0);
  the four `#print axioms` lines in §1 unchanged; the single structural `sorry` still located by
  content at `theorem countermodel_discrete` in `WeakCanonical/Transfer.lean`.
- **Import completeness**: `.lean` import rewriting is necessary but not sufficient — 28 markdown
  files reference `Bimodal.Metalogic.*` paths. A phase that updates only `.lean` files will leave
  documentation dangling, which is the same defect class the charter warns about.
- **Exclude both Boneyards** in every count, script, and `find`.
- **Prefer `git mv`** so history follows the files.

---

## 6. Open questions for the plan

1. Should `Metalogic/Completeness.lean` (dead, 534 lines) be revived or archived? It is documented as
   live in two places, which suggests its deadness is accidental rather than intended.
2. Do the 8 orphaned test modules get wired into `BimodalTest.lean`? They are name-stable so this
   does not collide with the naming task, but it widens scope.
3. For goal (6), does `Theories/Bimodal/docs/` merge into the existing root `docs/` or become a
   sibling (`docs/bimodal/`)? The former eliminates the current two-tree incoherence; the latter is
   a smaller diff.
