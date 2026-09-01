# Resolving the orphaned `FormalSystem/FrameConditions/` layer

**Verdict: DELETE — confirmed.** Every premise supporting deletion re-verified at HEAD
`b7ccf6702`. Four of the pre-registered brief's factual claims are stale and are corrected
below; three execution blockers the brief did not identify are recorded, one of which is a
gate that is *already red* at HEAD.

---

## 1. Verdict grounding

### 1.1 No paper counterpart

`specs/paper-definitions-of-record.md:786-796` pins `def:frame-validity`:

> A well-formed sentence `φ` of BL is *valid over a task frame* `F = ⟨W, D, ⇒⟩`, written
> `⊨_F φ`, iff `M,τ,x ⊨ φ` for every model `M` over `F`, world `τ ∈ H_F`, and time `x ∈ D`.

Validity is indexed by a **whole task frame**, and `def:logical-consequence` gives `⊨_C` per
frame *class*. Neither is indexed by a carrier type `D` carrying typeclass constraints. The
carrier-typeclass layer has no counterpart in the source paper.

### 1.2 The replacement layer is complete and strictly better

| Concern | FrameConditions/ | Live replacement |
|---|---|---|
| Frame condition | inlined instance-binder list, hand-maintained | `FrameClass.Sat : FrameClass → TaskFrame → Prop` (`Semantics/FrameClassValidity.lean:112`) |
| Class-indexed validity | `ValidLinear`/`ValidDenseFc`/… (already deleted) | `ValidIn fc φ` (`Semantics/Validity.lean:284`), `valid := ValidIn .Base` (`:324`) |
| Frame properties | marker classes on `D` | `TaskFrame.IsDense` / `IsSuccArchDiscrete` / `IsDedekind` (`Semantics/FrameProperty.lean:71,118,172`) |
| Axiom ↔ class | `AxiomLinearCompatible` + 12 instances | `Axiom.minFrameClass` ("the single source of truth") |

`Sat` maps `.Base ↦ True`, `.Dense ↦ IsDense`, `.Discrete ↦ IsSuccArchDiscrete`,
`.Dedekind ↦ IsDedekind`.

### 1.3 The layer is not merely redundant — it is unsound-leaning

Two independent in-tree records say the marker classes denote the *wrong* frame collections:

- `Semantics/FrameProperty.lean:100-105`: interpreting `FrameClass.Discrete` by `IsDiscrete`
  "would silently widen the class under `soundness_discrete` — **the same defect the
  `FrameConditions/` marker-typeclass layer carries**."
- `FrameConditions/Validity.lean`'s own retirement docstring: `DiscreteTemporalFrame` omits
  `IsPredArchimedean` (so it ranged over a **wider** class than `ValidDiscrete`), while
  `DenseTemporalFrame` adds `NoMaxOrder`/`NoMinOrder` (narrowing).

### 1.4 No promotion candidate exists

The one plausible future consumer was task 511, whose construction spec
(`reports/02 §9:540-542`) targeted `FormalSystem/FrameConditions/Correspondence/Density.lean`,
calling `FrameConditions/` "report 01's M1 layer and where a per-frame condition belongs."

That collision is **dead**:
- Task 511 is `[EXPANDED]` (terminal), with an explicit board note: "do not dispatch `/plan 511`."
- Its successor, task 513, targets `Semantics/Correspondence/Galois.lean`. The string
  `FrameConditions` does not occur anywhere in task 513's TODO entry.
- Even at its most ambitious, 511 wanted the **directory as a location** for per-frame
  conditions — it explicitly "does not add a validity predicate" and keeps `FwdRec` out of the
  `Valid*` namespace. It never proposed consuming the marker typeclasses.

**Promotion is off the table on measured evidence, not by pre-registration.**

---

## 2. Corrections to the brief

### C1 — Size: 853 `.lean` lines, not 906

| File | Lines |
|---|---:|
| `FormalSystem/FrameConditions.lean` (aggregator) | 74 |
| `FrameConditions/FrameClass.lean` | 292 |
| `FrameConditions/Soundness.lean` | 207 |
| `FrameConditions/Compatibility.lean` | 199 |
| `FrameConditions/Validity.lean` | 81 |
| **`.lean` total** | **853** |
| `FrameConditions/README.md` | 98 |

The review's 906 predates commit `e5a9ba40f`. The directory's own README is separately stale:
it claims 892 lines total and `Validity.lean` at 209 lines (it is 81), and lists a key
definition `valid_over` that does not exist.

### C2 — Brief item (b) is already done; there is no fourth validity vocabulary

`Validity.lean` no longer contains `ValidOver`, `ValidLinear`, `ValidDenseFc`,
`ValidDiscreteFc`, or `ValidOverInt`. Commit `e5a9ba40f` ("task 507 phases 2-3: FrameClass.Sat,
ValidIn, one monotonicity lemma; **dead FrameConditions surface retired**") deleted all twelve
declarations. The 81-line file holds exactly two fibration bridges — `valid_of_forall_valid_over`
and `valid_over_of_valid` — which are statements about the `FrameOver D` fibration, not about
any frame class. The brief's line numbers (`:59,:79,:89,:100,:199`) come from the 2026-08-31
review and no longer resolve.

### C3 — Brief item (c): 14 instances, not ~40

`Compatibility.lean` has 14 `instance` declarations: 2 monotonicity instances
(`Linear → Dense`, `Linear → Discrete`) and 12 per-axiom `AxiomLinearCompatible` instances. The
file's own docstring already states this: "Twelve explicit `AxiomLinearCompatible` instances …
**not** one per axiom." The `Axiom.minFrameClass` duplication is real, just an order of
magnitude smaller than briefed.

### C4 — The C6 acceptance criterion does not apply

`FormalSystem.FrameConditions` is **reachable** (`FormalSystem/FormalSystem.lean:13`), so
`lake build` compiles it and it is correctly *absent* from
`scripts/module-invariants-manifest.txt`. C6 counts *unreachable* live modules. Deleting
reachable modules cannot change that count.

Baseline: `PASS C6 all 17 unreachable live module(s) are manifested`. **Post-deletion: still
17. No manifest edit is required, and adding one would fail C6** (the manifest rejects entries
naming modules that do not exist).

What actually moves is **C7**, the informational live inventory, which is *never asserted*:

| C7 field | Before | After |
|---|---:|---:|
| live `.lean` files | 479 | 474 |
| FormalSystem | 424 | 419 |
| `(loose)` | 10 | 9 |
| `FrameConditions` | 4 | row removed |

The acceptance criterion "C6 unreachable-module count updated and manifested" should be
restated as **"C6 still passes at 17 with no manifest edit; C7 inventory shifts as tabulated."**

### C5 — The silent regression is a relocation, not a deletion

Two of the three identifiers **are present in the tree**:

| Identifier | Status |
|---|---|
| `completeness_over_Int` | present — `Boneyard/StrictSemanticsLegacy/FrameConditions/Completeness.lean:530` |
| `discrete_completeness_fc` | present — same file, `:549` |
| `dovetailed_bundle` | **genuinely absent** — 0 occurrences tree-wide |

Accurate statement of the regression: *the completeness wiring was archived to the Boneyard
rather than removed; it is unreachable from every Lake target root, so no build compiles it and
the "DONE" claim is no longer true of the live tree. Two of the three identifiers survive as
archived record; `dovetailed_bundle` is gone outright.*

---

## 3. Execution blockers not in the brief

### B1 — C11 fails on deletion (must be handled in the same commit)

`FormalSystem/Boneyard/StrictSemanticsLegacy/FrameConditions/Completeness.lean:1` reads:

```
import FormalSystem.FrameConditions.Compatibility
```

C11 asserts every archived import resolves on disk. Baseline:
`PASS C11 all 497 archived import lines in 156 archived file(s) resolve (6 waived)`. Deleting
the directory makes this import dangle → **C11 FAILS**.

**Fix**: append `FormalSystem.FrameConditions.Compatibility` to
`scripts/boneyard-import-waivers.txt` with a comment naming the deletion commit. This is
precisely that file's documented "deleted outright, reviving is out of scope" category, matching
the existing `ParametricCanonical` block, and satisfies its guard ("prove there is no unique
target file on disk" — after deletion there is none).

**Do not delete the Boneyard file instead.** It is the archived record of
`completeness_over_Int` / `discrete_completeness_fc` on which finding C5 rests.

### B2 — `typst-sync-check.sh` is ALREADY RED at HEAD, and deletion makes it worse

Baseline run at `b7ccf6702`:

```
== Check 1: backtick name resolution ==
VIOLATION: `ValidOver`    -- identifier not found ... (in: typst/chapters/p2-frame-classes.typ)
VIOLATION: `ValidOverInt` -- identifier not found ... (in: typst/chapters/p2-frame-classes.typ)
TOTAL_VIOLATIONS=2
typst-sync-check.sh: FAIL
```

This is **inherited debt** from the task-507 trim (C2 above), not caused by this task — but this
task is the natural place to clear it, since both violations sit in the same paragraph that
deletion must rewrite anyway.

Deletion newly breaks these backticked identifiers in `typst/chapters/p2-frame-classes.typ`
(`:96-102, :107, :151, :160`): `LinearTemporalFrame`, `SerialFrame`, `DenseTemporalFrame`,
`DiscreteTemporalFrame`, `soundness_linear`, `AxiomLinearCompatible`, `AxiomDenseCompatible`,
`AxiomDiscreteCompatible`.

**Subtle trap — three more than a naive count predicts.** `ValidLinear`, `ValidDenseFc` and
`ValidDiscreteFc` currently *pass* check 1 only because the retirement **prose** in
`FormalSystem/FrameConditions.lean` and `FrameConditions/Validity.lean` still mentions them:
the checker is a plain text grep over `.lean` files and does not require a *declaration*.
Deleting those two files removes the prose and converts three passing names into violations.
Projected post-deletion total is therefore **~13 violations** unless `p2-frame-classes.typ`'s
frame-class section is rewritten in the same change.

`soundness_dense` / `soundness_discrete` **survive**: `Metalogic/Soundness.lean:1329,:1477`
declare homonyms. This homonymy is also why a naive `grep -c` for FrameConditions symbols
reports 20+ "external references" that are not references to this directory at all — the
correct measurement is by *import*, and by that measure the live consumer count is **one**.

### B3 — 11 dangling `#leansrc` book pointers (silent, not gated)

`typst/FormalFoundations.typ` points the compiled book's *Frame properties* definition and
*Soundness* theorem at FrameConditions symbols:

| Line(s) | Pointer |
|---|---|
| `:420-422` | `DenseTemporalFrame`, `DiscreteTemporalFrame`, `DedekindTemporalFrame` |
| `:621-624` | `soundness_linear`, `soundness_dense`, `soundness_discrete`, `soundness_Int` |
| `:1252, :1255` | `FrameConditions.Soundness.soundness_linear`, `…soundness_Int` |

`#leansrc(module, name)` takes **string arguments**, so `typst-sync-check.sh` check 1 (which
scans backticked spans) does **not** validate them. They fail *silently*, rendering dangling
source citations in the compiled book rather than failing a gate. Repoint targets:

- `DenseTemporalFrame` / `DiscreteTemporalFrame` / `DedekindTemporalFrame` →
  `Semantics.FrameProperty`'s `TaskFrame.IsDense` / `TaskFrame.IsSuccArchDiscrete` /
  `TaskFrame.IsDedekind`
- `soundness_linear` / `soundness_dense` / `soundness_discrete` / `soundness_Int` →
  `Metalogic.Soundness`'s `soundness` / `soundness_dense` / `soundness_discrete` /
  `soundness_dedekind`

### B4 — `readme-lint.sh` check 3 gates broken relative links

`FormalSystem/Metalogic/README.md:295` links `../FrameConditions/README.md`;
`FormalSystem/Metalogic/SoundnessLemmas/README.md:33` links `../../FrameConditions/README.md`.
Check 3 ("no broken relative file references") is exit-code-affecting. Invariant **C5** (`all
module-shaped paths in 1323 markdown files resolve`) separately covers `typst/SYNC-MAP.md` and
`docs/`.

---

## 4. Deletion and edit inventory

### 4.1 Delete (6 paths)

```
FormalSystem/FrameConditions.lean              (74 lines, aggregator)
FormalSystem/FrameConditions/FrameClass.lean   (292)
FormalSystem/FrameConditions/Validity.lean     (81)
FormalSystem/FrameConditions/Soundness.lean    (207)
FormalSystem/FrameConditions/Compatibility.lean (199)
FormalSystem/FrameConditions/README.md         (98)
```

Both the directory and its sibling aggregator must go together, or **C8** ("every
`FormalSystem/` subdirectory has exactly one sibling aggregator") fails.

Nothing is lost: `FrameConditions/Soundness.lean`'s five theorems are thin `D`-parameterised
wrappers around `Metalogic.soundness{,_dense,_discrete}`; `Compatibility.lean`'s classes
duplicate `Axiom.minFrameClass`; `Validity.lean`'s two surviving bridges are about the
`FrameOver D` fibration and have zero consumers. Zero sorries are involved (C3 passes tree-wide).

### 4.2 Edit

| File | Lines | Change |
|---|---|---|
| `FormalSystem/FormalSystem.lean` | `:13`, `:45-48`, `:96` | drop import + 3 docstring/inventory entries |
| `FormalSystem/README.md` | `:228`, `:247`, `:280`, `:329` | 4 inventory-table rows |
| `FormalSystem/Metalogic/README.md` | `:288-295` | delete "Position of `FrameConditions/`" section |
| `FormalSystem/Metalogic/SoundnessLemmas/README.md` | `:27`, `:33` | false import claim + broken link |
| `README.md` | `:113` | tree-diagram row |
| `docs/development/MODULE_ORGANIZATION.md` | `:20`, `:29` | 2 tree rows |
| `docs/user-guide/architecture.md` | `:1105` | tree row |
| `typst/SYNC-MAP.md` | `:195`, `:358-359` | 3 refs |
| `typst/chapters/p2-frame-classes.typ` | `:94-102`, `:107`, `:151`, `:153`, `:160` | rewrite frame-class section onto `Sat`/`ValidIn` |
| `typst/chapters/00-introduction.typ` | `:158` | directory listing |
| `typst/chapters/04-metalogic.typ` | `:41` | prose |
| `typst/FormalFoundations.typ` | `:420-422`, `:621-624`, `:1252`, `:1255` | 11 `#leansrc` repoints |
| `scripts/boneyard-import-waivers.txt` | append | C11 waiver (B1) |

**Bonus stale-doc findings**, worth fixing while in these files: `Metalogic/README.md:292` and
`SoundnessLemmas/README.md:27` use the dead `Bimodal.` namespace prefix (the project namespace is
`FormalSystem.`), and `SoundnessLemmas/README.md:27`'s claim "Imports from … `Bimodal.FrameConditions`"
is simply **false** — no file under `SoundnessLemmas/` imports it (verified against all five
files' import lines).

---

## 5. Acceptance criteria, restated against measurement

| # | Criterion | Note |
|---|---|---|
| A1 | No orphaned validity vocabulary remains | Largely pre-satisfied by `e5a9ba40f` (C2); deletion finishes it |
| A2 | `lake build` green | Detached + guarded per `long-builds.md`. **Baseline not captured this cycle (§6) — capture it before deleting.** Only the aggregator import is removed from the live graph |
| A3 | `check-module-invariants.sh` green | **C6 stays at 17 with no manifest edit** (C4). Live risks are C11 (B1), C5 and C8 |
| A4 | `typst-sync-check.sh` green | **Currently FAILS at HEAD with 2 violations** (B2). Target: 0, clearing inherited debt |
| A5 | `readme-lint.sh` green | Two broken links to repair (B4) |
| A6 | Silent regression recorded | Record the corrected form (C5): archived, not deleted; `dovetailed_bundle` alone is gone |

---

## 6. Baselines captured at `b7ccf6702`

```
check-module-invariants.sh --no-build : ALL CHECKS PASSED
  C4  1472 import lines resolve
  C6  17 unreachable live modules, all manifested
  C7  479 live .lean (424 FormalSystem / 54 Tests); 462 reachable, 17 unreachable
  C11 497 archived import lines in 156 files resolve (6 waived)
typst-sync-check.sh                   : FAIL (Check 1: TOTAL_VIOLATIONS=2)
                                        Checks 2 and 3 pass (MISMATCH_COUNT=0, MA_COUNT_MISMATCHES=0)
lake build                            : NOT CAPTURED — see below
```

**`lake build` baseline was not captured in this cycle.** A guarded build was dispatched
(`lake-build-guard.sh build --timeout 1800 -- build`) but sat queued behind a concurrent
guarded build held by another session (`lake-build-guard: in-flight guarded build detected
(holder pid 2151663)`), which is the guard behaving exactly as designed. The implementation
cycle must capture the green baseline itself before deleting anything, so that a post-deletion
failure can be attributed.

Two indirect signals suggest HEAD is green, but neither is a substitute: `check-module-invariants.sh`
passes C3 (structural sorry inventory is zero tree-wide) and C4 (all 1472 import lines resolve),
and `.lake/build/lib/lean/FormalSystem/FrameConditions/*.olean` are present and current
(built 09:13 today). Neither establishes a whole-tree green build.
