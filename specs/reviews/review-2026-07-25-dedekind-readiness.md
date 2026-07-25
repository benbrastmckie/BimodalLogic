# Review: Readiness for Dedekind-Complete Completeness

**Date**: 2026-07-25
**Scope**: Preparation state for a completeness theorem for the Dedekind-complete extension of the base logic
**Method**: Empirical `lake build`, three parallel codebase/backlog/literature surveys, direct verification of headline claims

---

## Summary

| Severity | Count |
|----------|-------|
| Critical | 3 |
| High | 4 |
| Medium | 4 |
| Low | 3 |

The single most important finding is not a defect but a **scope ambiguity**: the phrase
"Dedekind complete" denotes two unrelated things in this repository, and the only task
currently labelled "the dedicated complete proof system work" implements the *other* one.
See Critical-1.

---

## Critical Issues

### C1. "Dedekind complete" is two different projects, and task 378 is not the one this goal names

**Files**: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/DedekindINF.lean`,
`Theories/Bimodal/ProofSystem/Axioms.lean:424-464`, `specs/state.json` (task 378)

Two distinct senses are in play:

1. **Expressive-completeness sense (Rabinovich/Kamp).** `HasDedekindINF` / `HasDedekindSUP`
   (`DedekindINF.lean:130,147`) are Rabinovich 2014 eq (5.2) — the "infimum is TL-definable"
   carrier used to prove Kamp's theorem (TL(U,S) = FOMLO over Dedekind-complete chains).
   This is a **property of the expressiveness argument**, not a frame class for the modal
   logic. Task **378** owns exactly this, and its own description states it is
   *"fidelity-only, ZERO OPERATIONAL VALUE"* because the live chain runs on Prior structures
   where attainment holds outright via `prior_hasAttainedINF` (`PriorINF.lean:224`).

2. **Frame-class sense.** A `FrameClass.Dedekind` with
   `completeness_dedekind : valid_dedekind φ → Derivable FrameClass.Dedekind [] φ`,
   parallel to the existing `completeness_dense` / `completeness_discrete`.
   **This does not exist in any form** — no constructor, no axiom, no validity predicate,
   no soundness theorem, no countermodel.

Verified: `FrameClass` has exactly three constructors (`Axioms.lean:424-427`):
`Base | Dense | Discrete`. `FrameClass` is referenced 1,649 times across 118 live files.

**Impact**: If the goal is sense 2, task 378 is *not* the on-path task, and anyone reading
378's "ZERO OPERATIONAL VALUE" banner will correctly de-prioritize it — while the actual
work has no task at all. If the goal is sense 1, then 378 is the task and no new frame
class is needed. These lead to entirely disjoint task plans.

**Recommended fix**: Resolve the ambiguity before creating any tasks. If sense 2, rewrite
378's charter (its value calculus was written for the old goal and inverts under the new
one) and open a new task for the frame class itself.

### C2. The build is red; a concurrent session is mid-migration

**Evidence**: `lake build` → `BUILD_EXIT=1`, 17 errors, frontier 1865/1877.

Failing modules:
- `Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorBracket.lean` — committed red at
  `006c96c10`; 2 `Decidable` synthesis failures (`:130`, `:143`) + 8 `Fin.cons` simp-normal-form
  mismatches (`:211`, `:245`, `:764`, `:767`, `:770`, `:867`, `:1137`, `:1140`)
- `Metalogic/WeakCanonical/Expressiveness/SplitPoint.lean` — dirty in the working tree, so
  likely work-in-progress rather than a committed regression

Cause: task **291**, a Lean v4.27 → v4.33-rc1 + Mathlib re-pin, is `implementing` at priority
`critical`. During this review HEAD advanced 30 commits (`e0158da5e` → `d5af53ff7`) — another
session is actively working. Its own handoff records Phase 5 `[PARTIAL]` ("5 errors in 1 file,
root cause identified"), Phase 6 `[IN PROGRESS]`, Phases 7-10 `[NOT STARTED]`.

**Impact**: A multi-week proof effort must not start across a toolchain migration. This is
the gating item, ahead of literature.

**Recommended fix**: Finish 291 through its Phase 8 gates. Do not begin new proof work, and
do not edit files in the Kamp tree, until the tree is green.

### C3. The project's ground-truth source for this theorem is silently corrupted, and the index says it is verified

**Files**: `~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.md`,
`~/Projects/Literature/index.json`

The converted Rabinovich markdown contains **zero `≠` characters** across the whole 16-page
paper, while `≤` (4) and `≥` (3) survived. The converter dropped the glyph, so every
inequality reads as an equality. At `:199` this renders Prop 4.2's case split as:

> "We consider two cases. In the first case k = m, i.e., z0 = z1 and in the second k = m."

and at `:201`: "If k = m, w.l.o.g. we assume that m < k."

This is Section 5 / Proposition 4.2 — **precisely the "equivalent over Dedekind complete
chains" material** the next theorem rests on. The failure mode is the dangerous one: not
garbled text a reader would notice, but a clean, readable, logically inverted statement.

Compounding it:
- `index.json` sets `path` to the corrupt `.md`, **not** the PDF.
- It tags the entry `provenance_fidelity: "verified_conversion"`.
- 11 of its chunks are live in the FTS5 index, so `--lit` briefings serve this text.
- The entry is 2,721 tokens for 16 pages — all displayed equations were dropped too.

The repo-local `specs/literature-index.json` **does** record the hazard (including 89
known-dangling `md:NN` citations in `SharedWitness.lean`). The two indices contradict each
other, and the global one is what `--lit` reads.

**Recommended fix**: Re-convert from the PDF with equation preservation; until then, flip the
global entry's `provenance_fidelity` off `verified_conversion` and repoint `path` at the PDF.
Task 378 already mandates PDF-page citation only — that constraint should be global, not
per-task.

---

## High Priority Issues

### H1. Dedekind-completeness breaks the `FrameClass` partial order as currently designed

`Axioms.lean:430-438` defines `LE` with `Base ≤ everything`, `Dense`/`Discrete` reflexive
only and mutually incomparable. A Dedekind-complete order is *a fortiori* dense, so it
validates both `density` (`Axioms.lean:387`) and `dense_indicator` (`:399`). A new
`Dedekind` constructor therefore sits **above `Dense`**, which the current three-element
order does not anticipate. The `LE` instance, the `PartialOrder` proof (`:440`), and the
`minFrameClass ≤ fc` invariant enforced in `DerivationTree.axiom` (`Derivation.lean:92`)
all need rework — and that gate is upstream of every derivation and soundness proof.

### H2. A countable chronicle limit domain cannot be Dedekind-complete, dense, and unbounded

`ROADMAP.md:1477` describes the limit domain X as a **countable** linear order (sparse
X ⊂ ℚ for Base, ℚ for Dense, ≅ ℤ for Discrete). `ROADMAP.md:317-320` additionally warns that
dense domains like ℚ are *wrong* for general completeness. But a Dedekind-complete, dense,
unbounded linear order is order-isomorphic to ℝ, hence uncountable.

So the existing chronicle/canonical-model route cannot directly yield a Dedekind-complete
carrier; the construction needs either a completion step or a different argument.
`ROADMAP.md:1414`'s "Representation Theorem Goal" enumerates `D' = Rat`, `Rat`, `Int` —
**no ℝ row exists**. `DedekindINF.lean:44` states flatly that no ℝ `OrderedMonadicStructure`
is constructed anywhere in the tree.

This is the mathematical core of the effort and it is currently unscoped.

### H3. The most on-point literature source is unadjudicated and has a hole in the middle

GHR 1994 Vol. 1, Ch. 10 §10.3 "Separation over Dedekind Complete Flows" is the single most
relevant text. Corpus state:
- §10.3.1, §10.3.3, §10.3.4 present but **`provenance_fidelity: null`** (unverified)
- **§10.3.2 is entirely absent** — a gap in the middle of the chapter, though the ch10 PDF
  is on disk, so this is a conversion gap, not an acquisition gap
- Vol. 2 (Gabbay & Reynolds 2000) PDF present but conversion **rejected**, zero tokens
- Reynolds 1992 *…over the Reals* — §5 and §9 missing from an otherwise converted paper.
  Worth checking whether those are the sections bearing on H2.
- Hodkinson & Reynolds 2006 Handbook Ch. 11: 2,094 tokens for 65 pages (stub)
- Burgess 1984 §4: 982 tokens for 11 pages (stub) — and it is one of the 12 sub-index pointers

### H4. `completeness_dense` and base `completeness` are less finished than the roadmap headline implies

Only `completeness_discrete` and `completeness_dense` byte-verify to the pristine axiom set.
Base `completeness` still carries `sorryAx` residue from the deprecated
`WeakCanonical.countermodel_discrete` (`Transfer.lean:1277`). Tasks 169 and 170 exist
specifically to retire remaining sorries under `completeness` and `completeness_dense`.

`Completeness.lean:168-179` documents why: a Base-MCS is not automatically Discrete-consistent,
so the sorry-free Reynolds pipeline cannot be reused. **A Dedekind variant will hit the
structurally identical problem** — it must build a countermodel from an MCS of its own class
and cannot borrow `countermodel_dense_enriched` unless Dedekind MCSes are Dense-consistent.

---

## Medium Priority Issues

### M1. Tasks 131 and 161 are on a collision course with a long proof effort

- **161** (rename `Theories/Bimodal/` → `FormalSystem/`) touches the import line of all 278
  live `.lean` files plus `lakefile.lean`, README, Tests. It depends on 291, so the one cheap
  window is immediately after the toolchain lands.
- **131** (restructure `Metalogic/` into `Soundness/` and `Completeness/`) moves the exact
  files a Dedekind proof would live in, and depends on 341.

ROADMAP ranks both as post-completeness (items 9-10). That line should hold.

### M2. Task 131's description is stale enough to mis-scope any plan generated from it

Claims "130 live .lean files across 7 top-level directories"; actual count is **278**. Lists a
`ConservativeExtension/` subdirectory that no longer exists. Omits `WeakCanonical/` entirely —
125 live files, ~18k lines, the bulk of the Metalogic tree and the home of all Kamp work.

### M3. Task 383 is blocked on an unspawned sub-task; its stated scope is superseded

Dependency 382 is satisfied (archived). The real blocker is an arity mismatch: the negation
engine (`Prop42NegationGeneral.lean`, Phases 1-6, green and sorry-free) supplies a 2-variable
negation gated on `z0 < z1`, while the actual Phase-7 gap at `KampPrior.lean:562` needs a
model-independent **arity-m** negation. The `augTarget_iff` seam
(`ExistsForallLemmas.lean:696`) has zero live consumers.

The record recommends `/spawn` for one of two remedies; **neither has been created**.
Separately, 382's verdict was RECONCILE, not GO, so 383's leading GO-branch scope
(~870-1230 lines) is retired and must not be used for planning.

### M4. `repository_health.build_errors` is wrong

`specs/state.json` records `build_errors: 0, status: "healthy"`, last assessed
2026-07-25T06:13Z. The empirical build is red (C2). I did not correct it in place because a
concurrent session holds `state.json`; correcting it risks clobbering active work.

---

## Low Priority Issues

### L1. `CLAUDE.md:25` documents the wrong toolchain
States "v4.27.0-rc1 with Mathlib v4.27.0-rc1"; `lean-toolchain` pins
`leanprover/lean4:v4.33.0-rc1` since commit `29b9cea6f`.

### L2. The completeness cone is split across three topic strings
`completeness` (95, 165), `strong_completeness` (169, 170, 361, 362), `kamp-completeness`
(377, 378, 383), plus `kamp_theorem_formalization` (321, 341). Filtering by topic will not
find the cone.

### L3. state.json schema and hygiene drift
- Task 378's status is `"not started"` (space) vs canonical `"not_started"` — consequential
  because 378 is the most on-path task and strict-equality filters will drop it
- Task 321 (`expanded`) is absent from TODO.md's wave table and topic groupings
- `task_counts.active: 43` vs 37 actual entries; `metadata.total_tasks: 29`;
  `metadata.last_sync: 2026-06-08`; top-level `last_updated: 2026-04-12`
- Empty `description` fields on tasks 179, 180, 186, 192, 193, 257, 282

---

## What Already Exists and Is Reusable

Verified live and sorry-free — a Dedekind variant would reuse these verbatim:

| Component | Location | Genericity |
|---|---|---|
| `ParametricCanonicalTaskFrame D` | `Algebraic/ParametricCanonical.lean:200` | any `D` |
| `ParametricCanonicalTaskModel D` | `Algebraic/ParametricTruthLemma.lean:101` | any `D` |
| `parametric_canonical_truth_lemma` | `Algebraic/ParametricTruthLemma.lean:226` | any `D` |
| `restricted_parametric_shifted_truth_lemma` | `Algebraic/RestrictedParametricTruthLemma.lean:109` | `{fc}`, any `D` |
| `fully_restricted_parametric_completeness_from_neg_membership` | `.../RestrictedParametricTruthLemma.lean:394` | the single funnel both live countermodels use |
| `neg_consistent_of_not_derivable` | `BXCanonical/Completeness.lean:66` | `{fc}` |
| `mcs_mixed_case_absurd` | `Chronicle/MCSMixedCase.lean:34` | takes `fc` explicitly |
| `structure Gap` | `EFGames/Defs.lean:230` | the right object to phrase "no Dedekind gaps" |
| `Axiom.minFrameClass` gate | `Axioms.lean:458` | single-point extension mechanism |

The canonical model stack is already parameterized over both the duration type and the frame
class. The frame-class-specific pieces are only (a) carrier choice + BFMCS construction, and
(b) the step-5 branch-elimination argument.

## What Must Be Newly Written (frame-class sense)

1. `FrameClass.Dedekind` + `LE` / `PartialOrder` / `minFrameClass` updates
2. An axiom characterizing Dedekind completeness — no candidate exists in the `Axiom` inductive
3. `valid_dedekind` in `Semantics/Validity.lean` + the `valid → valid_dedekind` bridge
4. `soundness_dedekind` + per-axiom validity lemmas
5. **The countermodel on a Dedekind-complete carrier** — the real work, and the part H2 says
   the existing chronicle route cannot supply
6. The step-5 dichotomy argument from Dedekind-class axioms
7. A resolution of `Dense` vs `Dedekind` in the frame-class order (H1)

---

## Recommended Sequence

1. **Resolve C1** — decide which sense of "Dedekind complete" is the goal. Everything below
   assumes the frame-class sense.
2. **Finish task 291.** Do not start new proof work on a red tree.
3. **Fix C3** — re-convert Rabinovich from PDF, correct the global index fidelity flag.
   Do this before any `--lit` dispatch on this topic.
4. **Run task 95** (unblocked now, cheap) for an authoritative sorry/axiom baseline.
5. **Decide 161** — run it in the post-291 window or formally defer it. Do not leave it ambient.
6. **Close the H3 literature gaps** — GHR94 §10.3.2, adjudicate the §10.3.x cluster, convert
   Gabbay & Reynolds Vol. 2, recover Reynolds 1992 §5/§9.
7. **Scope H2** — the countable-carrier obstruction is the mathematical crux and needs a
   research task before any implementation plan.
8. Only then open the frame-class implementation tasks.

## Code Quality Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Build | exit 1, 17 errors, 2 modules | **Fail** (mid-migration) |
| TODO count | 1 | OK |
| FIXME count | 0 | OK |
| `axiom` declarations in live code | 0 | OK |
| Live sorries (grep, Boneyard excluded) | 16 across 4 files | See §5a of survey |
| Active tasks | 37 | — |
