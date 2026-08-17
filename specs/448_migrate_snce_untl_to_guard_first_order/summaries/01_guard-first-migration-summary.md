# Implementation Summary: Guard-First Migration of `snce`/`untl`

- **Task**: 448 — Migrate the Lean tree's `snce`/`untl` constructors from event-first (Burgess) to
  guard-first (paper) argument order
- **Plan**: `specs/448_migrate_snce_untl_to_guard_first_order/plans/01_guard-first-migration.md`
- **Status**: COMPLETED — all 13 phases closed
- **Session**: sess_1786995652_39d0c1

## What was done

`Formula.untl` and `Formula.snce` now take the **guard first and the event second**, matching
`def:BLplus-semantics`'s `(since)` / `(until)` clauses and the already-guard-first Typst manual.
The migration was a uniform argument swap of the two constructors and every call site — 3,711
occurrences across 152 files of live scope — executed as a rename-forced migration: the
constructors were renamed to `untlQ`/`snceQ` at the moment of the swap so that any unmigrated
reference became a hard compiler error rather than a silent meaning change, then renamed back
under identifier-boundary-anchored matching once the tree was green.

A uniform swap of a binary constructor's two arguments, applied to the definition and to every
site that builds or destructures it, is an isomorphism on the term algebra. Nothing about the
logic changed: no proof changed shape, no `sorry` was introduced, and the role-keyed JSON oracle
regenerates byte-identically.

## Phases

| Phase | Outcome |
|---|---|
| 1 | Baseline snapshot and migration ledger |
| 2 | Rewriter hardened (four report-identified defects) |
| 3 | Root migration — `Formula.lean`, `Syntax`, `Truth.lean` |
| 4 | Mechanical rewrite of the live tree |
| 5-7 | Repair in topological order — ProofSystem/Theorems/Automation, Metalogic/BXCanonical, WeakCanonical/Kamp/Decidability |
| 8 | Tests repaired, first full green build (COMPLETED WITH EXCLUSIONS) |
| 9 | Definitional audit — two-gate oracle, byte-exact |
| 10 | Rename back, final verification build |
| 11 | Role-naming comment and docstring migration |
| 12 | Typst regeneration and sync |
| 13 | Record closure and prose repairs |

Phases 11-13 were completed in this dispatch; 1-10 in earlier dispatches.

## Acceptance criteria

| # | Criterion | Result |
|---|---|---|
| 1 | Constructors guard-first, docstrings naming roles and citing `def:BLplus-semantics` | Met — `Formula.lean:85-106` |
| 2 | `Truth.lean` clauses and docstring match, stale footnote quotation replaced | Met — clauses at `Truth.lean:165-168`; the docstring now derives its text from the footnote-free anchor and retracts the old event-first claim |
| 3 | `lake build` green with zero new `sorry`, verified per-file | Met — 2,457 jobs exit 0; per-file `sorry` census byte-identical to baseline (335 occurrences, 98 files); axioms unchanged at 7 |
| 4 | `somePast`/`someFuture`/`next`/`prev` verified against `def:BLplus-defined` | Met — all four match the paper anchor character for character; the two universal operators corroborate |
| 5 | Decision record closed as DECIDED with the erroneous argument retracted | Met |
| 6 | `typst-sync-check.sh` PASS and machine-appendix artifacts regenerated | Met — PASS 3/3 |

## Verification

- **`lake build`**: green, 2,457 jobs, exit 0 — the exact job count of the Phase 1 baseline.
- **`sorry`**: 335 occurrences across 98 files, per-file counts byte-identical to
  `baseline/sorry-baseline.txt`. Census method is `grep -o '\bsorry\b'` (occurrences, not lines).
- **Axioms**: 7 in live scope, 9 repo-wide — unchanged.
- **Gate A** (role-keyed `toJson`): regenerated `machine-appendix.jsonl` differs from the
  pre-migration baseline on exactly one line, the metadata stamp.
- **Gate B** (`schema_string`): byte-identical with **no** transform applied.
- **`untlQ`/`snceQ` residue**: 0. `untlGuard(s)`/`snceGuard(s)` intact.
- **`scripts/typst-sync-check.sh`**: PASS on all three checks.
- **`typst compile BimodalReference.typ`**: exit 0.
- **`python3 scripts/swap_untl_snce.py --test`**: all roundtrip cases pass.
- **`lake build BimodalTest`**: exits 1 with exactly the 7 pre-existing pinned-stale
  `#guard_msgs` docstring mismatches recorded at Phases 8 and 10 — zero new failures, in three
  modules none of which this task touched. Both named probes build clean and all round-trip
  suites pass.
- **`scripts/check-paper-definitions.sh`**: exits 1 on four drifted anchors — `def:TMplus`,
  `cor:tm-completeness`, `def:id`, `def:strongest` — all pre-existing and unrelated (the paper's
  own `Obj`-predicate retirement). Confirmed pre-existing by re-running against the `HEAD` version
  of the record: identical four anchors. Neither `def:BLplus-semantics` nor `def:BLplus-defined`
  drifted; zero drift introduced.

## Three renderings now coexist, and each is named where it appears

The most confusing thing about this area is that the codebase carries three orderings of the same
two roles. All three are legitimate; the defect was never that they differed but that comments
named a "convention" without saying which rendering they meant.

| Rendering | Order | Source |
|---|---|---|
| `untl(g, e)`, `snce(g, e)` | guard first | the constructor (`Syntax/Formula.lean`) |
| `U(e, g)`, `S(e, g)` prefix | event first | `Formula.prettyPrint`, `schema_string`, `asUntil?`/`asSince?`'s returned pair |
| `φ U ψ`, `φ S ψ` infix | guard first | the paper and the Typst manual |

## Plan Deviations

- **Phase 11 — altered.** The plan's D4 role-word predicate under-covers. Measured 204
  mandatory-tier lines across 43 files against the plan-time hypothesis of 115/22, and two whole
  classes of stale line carry **no role word** and were invisible to the predicate: constant-form
  constructor expressions inside comments (`untl φ (imp bot bot)` for `someFuture`) and paren-form
  renderings (`untl(γ, β∧xi)`). Both classes were enumerated by dedicated comment-region scanners
  (79 and 343 candidates) and each hit reviewed against the declaration it describes.
- **Phase 11 — altered.** `RRelation.lean:1527`, named in the plan as one of two hard cases,
  needed **no** rewrite: its cross-notation mapping was already stated guard-first and matches the
  migrated code. `RRelation.lean` required zero edits overall. `SoundnessLemmas/Core.lean:91`,
  the other named hard case, was corrected. Conversely `Lemma53FaithfulPast.lean:191` was wrong in
  the *opposite* direction and needed fixing.
- **Phase 12 — altered.** Gate B's documented `U(a,b)→U(b,a)` transform turned out to be the
  **identity**, because `prettyPrint` was made role-stable rather than left positional. Both gates
  therefore reduce to byte-identity — stronger than the plan required.
- **Phase 13 — altered.** The superseded footnote quotation was **retired** rather than merely
  annotated, to satisfy this phase's own verification criterion: the verbatim LaTeX was removed
  from the decision record and replaced with a description plus the three wave hashes.
- **Phase 13 — altered.** Two present-tense claims about the removed footnote were found in
  `paper-definitions-of-record.md` *outside* the 573-600 range the plan named, and also needed
  repair. Both received `**Superseded 2026-08-17**` notes in the file's own existing supersession
  idiom rather than being rewritten, so the dated historical record stays legible.

## Follow-on work (deferred by design, recorded in the closed decision record)

1. **Identifier-name hygiene (D2)** — 219 distinct identifiers in live scope carry an
   `untl_`/`snce_` segment encoding a position that has moved (`untl_left_mono_thm` now names the
   guard; `snce_event_congr` now names position 2). 219 is the starting inventory.
2. **`toJson` key-order flip (D1)** — a dataset-format version bump with real downstream
   consumers; orthogonal to argument order, and flipping it would have destroyed the byte-identity
   gate that made this task auditable.
3. **Incidental comment tier (D4)** — 391 order-neutral prose mentions left untouched.
4. **Optional `prettyPrint` infix rendering** — to match the manual's `(φ U ψ)` form.

Both Boneyard trees (1,934 occurrences across 51 files, uncompiled) were excluded by design and
now carry convention banners warning that their contents read event-first and must be swapped
before any file is resurrected.
