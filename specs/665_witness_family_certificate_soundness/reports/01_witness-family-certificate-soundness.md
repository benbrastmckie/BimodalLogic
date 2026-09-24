# Research Report: Task #665

**Task**: 665 - Witness-family certificate soundness (the quasimodel / ShiftSet route, soundness half)
**Started**: 2026-09-24T00:00:00Z
**Completed**: 2026-09-24T00:00:00Z
**Effort**: Large (~1,600 new Lean lines across 6-7 phases)
**Dependencies**: None blocking. Held-stable neighbour: `BiLasso/Basic.lean`. Sibling in flight this cycle: task 667 (no declared file scope).
**Sources/Inputs**:
- Codebase (`FormalSystem/Metalogic/Decidability/BiLasso/**`, `FormalSystem/Semantics/ShiftSet.lean`, `FormalSystem/Semantics/Validity.lean`, `FormalSystem/Semantics/FrameClassValidity.lean`, `FormalSystem/Semantics/FrameProperty.lean`, `FormalSystem/Syntax/SubformulaClosure/Closure.lean`)
- lean-lsp MCP (`lean_run_code`), plus compiled spikes through `lake env lean`
- Design rationale: `~/Projects/ModelChecker/specs/184_refactor_bimodal_theory_tests_green_and_paper_lean_aligned/reports/02_partial-model-formal-results.md` (referenced by the dispatch; not re-derived here)
- Refutation on record: `specs/archive/476_box_faithful_small_model_theorem/evidence/fmp-hypothesis-is-false.lean`

**Artifacts**:
- `specs/665_witness_family_certificate_soundness/reports/01_witness-family-certificate-soundness.md` (this report)
- `specs/665_witness_family_certificate_soundness/evidence/t1-agreement-spike.lean` (compiled spike: T1, T1', joint form, all sorry-free)

**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **T1 and T1' are not a research risk — they are already machine-checked.** A 262-line spike
  (`evidence/t1-agreement-spike.lean`) builds the `ShiftSet intOrder`, proves the agreement
  theorem by induction through `ShiftSet.forward_repr`, and derives all three consequence
  corollaries. It compiles clean against the live tree with **zero `sorry`** and measures
  `[propext, Classical.choice, Quot.sound]` — inside the task's declared axiom budget. The
  implementation phase for T1/T1' is transcription plus docstrings, not discovery.
- **The one genuinely new step is trivial.** The `box` case needs only that `sh · t` is a
  bijection of the carrier at each fixed duration (`(i, s) ↦ (i, s + t)`), which converts
  `∀ v, χ ∈ lab (sh v t)` into `∀ u, χ ∈ lab u`, i.e. exactly `BoxFaithful`'s right-hand side.
  Three lines. The reason it is easy is `total_eq_orbit`, already consumed inside
  `forward_repr`'s own `box` case.
- **T2 is the bulk of the work and is a transposition, not a proof effort.** Every window-collapse
  lemma in `BiLasso/Decide.lean` (lines 76-270 and 477-920, ~650 lines) reads **only** the label
  function and the three segment lengths — never the presentation. `LocalCoherentLab` is strictly
  *easier* than `LocalCoherent` because it drops the atom and state clauses, so
  `unroll_congr_back` / `unroll_congr_fwd` are not needed at all. `BoxFaithful`'s own collapse is
  two existing lemmas (`mem_all_neg_of_period`, `mem_all_fwd_of_period`) plus the `mid` window.
- **T3's second half is computationally infeasible as written, and this needs a decision.**
  `subformulaClosure (MF.neg)` has **card 10**, so `2^10 = 1024` label choices per position; a
  family with all segment lengths ≤ 2 spans up to 6 positions, giving up to `1024^6 ≈ 1.2 × 10^18`
  candidates for a *single* lasso before the `bx` and multi-lasso factors. `Enumerate.lean`'s own
  docstring already records that its enumeration is "astronomically impractical" and confines its
  smoke tests to a two-formula closure at `n = 1`. See **Risks & Mitigations** for the
  recommended substitute; this is flagged as a `user_decision`.
- **Recommended placement**: `FormalSystem/Metalogic/Decidability/WitnessFamily/` with the sibling
  aggregator `WitnessFamily.lean` (check C8/C33). The family is presentation-free and depends on
  `BiLasso/Periodic.lean` only — which is itself declared directory-independent by design — so it
  does not belong inside `BiLasso/`.

## Context & Scope

Researched: what already exists in the tree that T1-T3 can stand on; which parts are new
mathematics versus transposition; and which of the dispatch's stated shapes survive contact with
the elaborator. Constraints honoured throughout: sorry-free, axioms within
`[propext, Classical.choice, Quot.sound]`, `Basic.lean` held stable, no completeness/compression
direction (that stays with task 623).

Not researched: the compression direction; the ModelChecker JSON schema itself (only the
consequence that field names should be stable); `docs/` prose updates beyond the two README
tables the acceptance criteria name.

## Findings

### Codebase Patterns

**The truth-lemma template is `BiLasso/TruthLemma.lean`, and it transposes almost verbatim.**
`truth_along_annot` splits into an outer induction on the formula generalised over the time, and
two inner distance inductions isolated as `untl_mem_label_of_witness` /
`snce_mem_label_of_witness`. The spike reproduces exactly this shape with `ℤ` replaced by
"position along lasso `i`", and the inner lemmas are near-identical apart from the extra `i`
argument.

**The generalisation the `box` case forces.** The dispatch states T1 at `std.hist (i, 0)`. That
statement is not directly inductive: `ShiftTruth`'s `box` clause quantifies over the whole
carrier, which includes points `(j, s)` with `s ≠ 0`. The inductive statement must therefore be

```
∀ ψ ∈ closure, ∀ (w : std.Carrier) (t : ℤ),
  ShiftTruth std w t ψ ↔ ψ ∈ L w.1 (w.2 + t)
```

and the dispatch's form is this at `w := (i, 0)`. Proving it against `ShiftTruth` and *then*
composing with `ShiftSet.forward_repr` is what keeps the `box` case to three lines: `forward_repr`
has already discharged the `TruthAt`-vs-orbit transfer through `total_eq_orbit`.

**The label decoding is already written.** `Periodic.unrollOf` (`BiLasso/Periodic.lean`) is
stated at an arbitrary `[Inhabited α]` precisely so a second consumer can instantiate it at
`Finset Formula`, with `unrollOf_sub_back_length` / `unrollOf_add_fwd_length` supplying both
periodicities. `LabelledLasso` should be defined on it directly. `Annot` already does exactly
this, so the alignment bookkeeping (`readIndex`, `label_unroll_aligned`) is **not** needed:
that lemma exists only to align labels with *states*, and a `LabelledLasso` has no states.

**`Decide.lean` is label-only where it matters.** Verified by reading: `label_reduce_fwd`,
`label_reduce_back`, `label_congr_fwd`, `label_congr_back`, `scan_forward`, `scan_backward`,
`mem_all_neg_of_period`, `mem_all_fwd_of_period`, `UntlObl`/`SnceObl`/`UntlOblB`/`SnceOblB`,
`untlObl_descend`, `snceObl_descend`, `untlObl_iff_bounded`, `snceObl_iff_bounded`, the four
shift lemmas, `eventClauseAt`, `FulfilAt`, `fulfilling_iff_forall`, `fulfilling_iff_window` —
every one of these reads only `A.label`, `A.nb`, `A.nm`, `A.nf` and the two periodicities. The
window constants `-2·nb` and `nm + 2·nf` carry over unchanged.

**The enumeration side is already presentation-free.** `Enumerate.lean`'s `ListEnum.ofLen` /
`ListEnum.upTo` are generic over `α`; `closureSubsets`, `mem_closureSubsets` and `rawLabels` take
no `IntPresentation` at all. Only `rawLassos` / `boundedBiLassos` are presentation-indexed, and a
`LabelledLasso` needs no state lists, so its bounded enumeration is `rawLabels` filtered — strictly
simpler than `boundedAnnots`.

**The non-vacuity precedent is `BiLasso/Examples.lean`**: a hand-built positive witness discharged
by `#guard decide (...)` against the compiled `Decidable` instances, plus a hand-built witness that
is locally coherent and *not* fulfilling. That second witness is the load-bearing one — it is what
rules out the silent collapse of the greatest-fixpoint / least-fixpoint distinction.

### External Resources

**Mathlib instances for the ℤ-time membership.** `TaskFrame.isZTime_of_instances`
(`Semantics/FrameProperty.lean:279`) needs `SuccOrder`, `PredOrder`, `IsSuccArchimedean`,
`IsPredArchimedean` at the frame's duration. At `ℤ` these come from **two** imports that must
both be present:

- `Mathlib.Data.Int.SuccPred` — `SuccOrder ℤ`, `PredOrder ℤ`
- `Mathlib.Order.SuccPred.LinearLocallyFinite` — `IsSuccArchimedean ℤ`, `IsPredArchimedean ℤ`

Verified by bisection: neither alone suffices.

**`FrameClass.Sat.anti`** (`Semantics/FrameClassValidity.lean:242`) discharges the
`.ZTime → .Base` descent with `by decide` on the order hypothesis; verified working in the spike.

**`Int.abs_lt_one_iff`** is the lemma that closes `sep`. Verified: `abs_lt_one_iff_eq_zero` does
not exist; `abs_lt` plus `omega` fails at `↑intOrder` (see Tactic Survey Results).

### Recommendations

A sorry-free path exists for T1, T1' and T2, and for the first half of T3. The following is the
recommended decomposition; each phase is sized to one agent run.

**Phase 1 — `WitnessFamily/Closure.lean` (~90 lines).** The set-level closure the certificate's
target set needs, since `subformulaClosure` is single-formula only:

```lean
def closureOf (S : List Formula) : Finset Formula := (S.map subformulaClosure).foldr (· ∪ ·) ∅
theorem mem_closureOf : ψ ∈ closureOf S ↔ ∃ χ ∈ S, ψ ∈ subformulaClosure χ
```

plus `self_mem_closureOf` and six projections (`closureOf_imp_left/right`, `closureOf_box`,
`closureOf_untl_left/right`, `closureOf_snce_left/right`), each three lines from the corresponding
single-formula lemma, plus the `DecidablePred` instance. **Verified compiling** (spike run through
`lean_run_code`; `mem_closureOf` needs the explicit `constructor`/`rintro` proof given there —
`tauto` after `simp` fails on the `foldr` fold-back).

*Fallback if this proves awkward*: index the family by a single `φ : Formula` exactly as
`Annot P φ` does, and have the ModelChecker emit the conjunction. The T1 spike was written this
way and compiles; the cost is an unnatural field for the JSON export, not a proof obstacle.

**Phase 2 — `WitnessFamily/Basic.lean` (~180 lines).** `LabelledLasso` over `Periodic.unrollOf`
at `Finset Formula`:

```lean
structure LabelledLasso (C : Finset Formula) where
  back mid fwd : List (Finset Formula)
  back_ne : back ≠ []
  fwd_ne  : fwd ≠ []
  label_sub : ∀ X ∈ back ++ mid ++ fwd, X ⊆ C
```

with `L := Periodic.unrollOf back mid fwd`, `nb/nm/nf`, the two periodicities (by
`Periodic.unrollOf_sub_back_length` / `_add_fwd_length`), and `L_subset` (the decoded form of
`label_sub`, mirroring `Annot.label_subset_closure`). Then

```lean
structure WitnessFamily (Γ Δ : Context) where
  bx : Formula → Bool
  lassos : List (LabelledLasso (closureOf (Γ ++ Δ)))
  lassos_ne : lassos ≠ []
```

with `k`, `L : Fin (k+1) → ℤ → Finset Formula` and `main := L 0` derived. Keep field names
stable — the ModelChecker JSON export mirrors them.

**Phase 3 — `WitnessFamily/Predicates.lean` (~110 lines).** `LocalCoherentLab`, `FulfillingLab`,
`BoxFaithful`, `Target`, exactly as in the spike (`evidence/t1-agreement-spike.lean`, lines
58-82). Note: **no atom clause and no `bot`-in-closure guard** — `bot ∉ L i t` is unconditional,
and atoms are unconstrained because the valuation *is* the atom part of the label.

**Phase 4 — `WitnessFamily/Std.lean` (~120 lines).** `WitnessFamily.std : ShiftSet intOrder`,
`std_isZTime`, `std_sat_ztime`, `std_sat_base`, `sh_surj`. All five verified in the spike.

**Phase 5 — `WitnessFamily/Agreement.lean` (~230 lines).** `untl_mem_of_witness`,
`snce_mem_of_witness`, `shiftTruth_iff_mem` (T1's inductive form), `truth_iff_mem` (T1 as
dispatched), then T1': `not_consequence_ztime`, `not_consequence_base`, `joint_countermodel`.
**All verified sorry-free in the spike** — this phase is transcription with docstrings.

**Phase 6 — `WitnessFamily/Decide.lean` (~650 lines).** The T2 transposition. Take
`Decide.lean`'s lemmas in order, deleting the state-level ones:

| `Decide.lean` | Transposes as | Note |
|---|---|---|
| `nb/nm/nf`, `label_sub_nf`, `label_add_nb` | verbatim | label-only |
| `label_reduce_fwd/back`, `label_congr_fwd/back` | verbatim | label-only |
| `scan_forward` / `scan_backward` | verbatim | label-only |
| `mem_all_neg_of_period` / `mem_all_fwd_of_period` | verbatim | **also serve `BoxFaithful`** |
| `unroll_congr_back` / `unroll_congr_fwd` | **drop** | no states in a `LabelledLasso` |
| `clauseAt` | drop the `atom` case (`True`) | `bot` case stays `True` |
| `LocalCoherentAt`, `localCoherent_iff_forall`, `localCoherentAt_congr`, `localCoherent_iff_window` | simplified | congruence now needs only label periodicity |
| `cohWindowLo/Hi = -2·nb, nm + 2·nf` | unchanged | bounds carry over |
| the whole fulfilment block (lines 477-909) | verbatim modulo `A.label → Λ.L` | the largest single chunk |

`BoxFaithful`'s own collapse is new but small: `(∀ t : ℤ, χ ∈ L i t) ↔ (∀ t ∈ Finset.Ico (-nb) (nm + nf), χ ∈ L i t)`,
by `mem_all_neg_of_period` on the left, the `mid` window in the middle, and
`mem_all_fwd_of_period` on the right. `Target` is decidable outright (two `List.all`s over `Γ`/`Δ`).

**Do not refactor `Decide.lean` itself in this task.** `Basic.lean` is held stable and
`Decide.lean` is consumed by the live `check`; a shared abstraction over an abstract periodic
label sequence is the right long-term shape, but introducing it here would put a large refactor
under a concurrent sibling's feet. Record the duplication the way `Periodic.lean` already records
its duplication against `Basic.lean` — a "Deliberate duplication" docstring section naming the
**retirement trigger**: *once a shared periodic-label presentation lands, `Annot`'s window
collapses and `LabelledLasso`'s should be redefined as its two instances and the duplicated
arithmetic deleted.*

**Phase 7 — `WitnessFamily/Examples.lean` (~250 lines).** T3's positive half, following
`BiLasso/Examples.lean` exactly: a hand-built one-lasso family for
`□(p ∨ Fp ∨ Pp) ∧ □(p → ¬Pp)` with `p` only at `0`, accepted by the Phase-6 instances via
`#guard decide (...)`; plus a family that is `LocalCoherentLab` and **not** `FulfillingLab`,
mirroring `negAnnot`. See **Risks & Mitigations** for the negative half.

*Consistency check performed by hand on the positive target*: at `t < 0` the disjunct `Fp` holds
(witness `0`); at `t = 0`, `p`; at `t > 0`, `Pp` (witness `0`). `¬Pp` at `0` holds because `p`
occurs nowhere earlier. `Formula.top = bot.imp bot` is forced into every label by the `imp` clause
together with `bot ∉ L i t`, so `someFuture`/`somePast`'s guard is automatic.
`subformulaClosure` of this target has card **16**, so the hand-built labels are 16-element-bounded
`Finset`s — well inside what `decide` evaluates.

## Decisions

1. **Prove the agreement theorem against `ShiftTruth`, then compose with `forward_repr`** — not
   directly against `TruthAt`. Verified; this is what keeps the `box` case to three lines.
2. **Generalise the inductive statement over the carrier point**, not over the lasso index alone.
   Forced by the `box` clause; the dispatch's stated form is the instance at `(i, 0)`.
3. **`WitnessFamily.std` must NOT be `@[reducible]`.** Making it reducible breaks synthesis of
   `ShiftSet.frame_isRegular` (the goal unfolds past the instance's key). Verified both ways.
   Instead, ascribe carrier points explicitly — `((i, 0) : W.std.Carrier)` — and close the last
   step with `Iff.trans` rather than `rw [ShiftSet.forward_repr]`.
4. **Place the work in `Metalogic/Decidability/WitnessFamily/`, not inside `BiLasso/`.** The
   family is presentation-free; its only BiLasso dependency is `Periodic.lean`, which is
   deliberately directory-independent. Add the sibling aggregator `WitnessFamily.lean` (C8) and
   regenerate the root aggregator with `lake exe mk_all --lib FormalSystem` (C33).
5. **Index by a set-level `closureOf (Γ ++ Δ)`, not by a single formula.** Verified cheap
   (~90 lines). Single-`φ` indexing remains the documented fallback.
6. **Do not touch `Decide.lean` or `Basic.lean`.** Duplication is recorded with a named retirement
   trigger instead.

## Risks & Mitigations

**R1 (blocking, needs a decision) — T3's negative `#guard` is infeasible by ~12 orders of
magnitude.** Measured: `(subformulaClosure MF.neg).card = 10`, so `2^10 = 1024` label choices per
position. "All segment lengths ≤ 2" allows `back, fwd ∈ {1,2}`, `mid ∈ {0,1,2}` — up to 6
positions — giving up to `1024^6 ≈ 1.2 × 10^18` label triples for one lasso, before multiplying
by the `bx` choices and by the (unbounded, in the dispatch's phrasing) number of lassos in a
family. `Enumerate.lean` already records that this enumeration is "astronomically impractical" and
confines its own `#eval` smoke tests to a two-formula closure at `n = 1`.

*Recommended substitute, in preference order*:
  1. **A proved theorem** `no_witnessFamily_of_MF_neg` by a direct argument (MF's negation needs a
     point where `□φ` holds and `□Gφ` fails; `BoxFaithful` makes `bx` a global constant, so the
     two box clauses at a single family are contradictory) — this is the statement that actually
     carries content, and it costs no enumeration.
  2. **A hand-built negative witness**: a specific family rejected by the Phase-6 instances,
     `#guard !decide (...)`, mirroring `negAnnot`. This is what `BiLasso/Examples.lean` does and
     it is what establishes predicate separation.
  3. **A drastically reduced bound**: segment lengths exactly `(1, 0, 1)` over a hand-picked
     2-formula sub-closure, purely as a smoke test.

Options 1 and 2 together deliver everything T3 was reaching for. Option 3 alone would be a
smoke test dressed as a theorem. **Flagged as `user_decision`** — it is a scope change to a
stated acceptance criterion, not a judgment research can make unilaterally.

**R2 — `Σ` is a reserved token.** A binder named `Σs` (the obvious transcription of the
dispatch's `Σ`) fails to parse: `unexpected token 'Σ'`. Use `Δ`/`Del` for the conclusion set.
Cost: one rename; cost if missed: a confusing parse error far from its cause.

**R3 — `omega` does not see through `↑intOrder`.** Hypotheses of the form `t < s` at
`↑intOrder` are invisible to `omega`, and `abs_lt` at `↑intOrder` produces components `omega`
cannot use either. Mitigation is the idiom `TruthLemma.lean` and `Unfold.lean` already use:
`have h : @LT.lt ℤ _ t s := hts` and `replace hguard : ∀ r : ℤ, @LT.lt ℤ _ t r → … := hguard`
before any `omega`, and `show @LT.lt ℤ _ a b by omega` when the *goal* is the inequality.
For `sep`, coerce first (`have h : (|(y : ℤ)| : ℤ) < 1 := hy`) and finish with
`Int.abs_lt_one_iff`. All verified.

**R4 — `haveI` shadows the `SuccOrder` instance the Archimedean classes are indexed by.**
`haveI : SuccOrder W.std.frame.Duration := inferInstanceAs (SuccOrder ℤ)` followed by
`haveI : IsSuccArchimedean …` fails: `IsSuccArchimedean` is indexed by the `SuccOrder` instance,
and the opaque local shadows the Mathlib one. This is the exact trap
`FrameClassValidity.lean`'s `sat_intro` docstring warns about ("use `@`, never `haveI`").
Mitigation, verified:

```lean
theorem std_isZTime (W : WitnessFamily Γ Δ) : W.std.frame.IsZTime :=
  @TaskFrame.isZTime_of_instances W.std.frame
    (inferInstanceAs (SuccOrder ℤ)) (inferInstanceAs (PredOrder ℤ))
    (inferInstanceAs (IsSuccArchimedean ℤ)) (inferInstanceAs (IsPredArchimedean ℤ))
```

Note also that bare `inferInstance` for `SuccOrder S.frame.Duration` **fails** even though
`S.frame.Duration = intOrder` holds by `rfl` and `ShiftSet.frame` is `@[reducible]` —
instance-search keying does not reduce through it. `S.fibre.toTaskFrame.Duration` does work.
Do not spend time "fixing" this; use the explicit `@`-application.

**R5 — module-invariant gates (`scripts/check-module-invariants.sh`).** New modules must satisfy:
C33 (root `FormalSystem.lean` byte-identical to `lake exe mk_all --lib FormalSystem` output —
regenerate, do not hand-edit), C8 (sibling aggregator), C3 (zero `sorry`), C9 (no task numbers
under `FormalSystem/`), C14 (documented axiom counts must match — new flagship theorems may need
baseline rows), C17 (dead-declaration scan: every new declaration must be referenced outside its
own declaring line, so cite the lemma names in the README tables or tests), C19 (90% docstring
coverage), C28 (per-file warning budget — the spike carries two `unusedVariables` warnings that
must be cleaned before landing), C20 (`file.lean:NNN` citations must be in range and land on the
named declaration).

**R6 — concurrent sibling (task 667, no declared file scope).** Per the dispatch's territory
block: re-read any file immediately before editing, stage only this task's own hunks (never a
directory or glob `git add`), never run `git-snapshot.sh` in its reverting default mode, and treat
an unexpected build failure outside `WitnessFamily/` as possibly a sibling's in-flight edit. At
the time of this research the working tree carried only task-management modifications
(`specs/TODO.md`, `specs/events.jsonl`, `specs/state.json`) — no foreign source edits.

**R7 — README tables.** Acceptance names two: the BiLasso README module table
(`FormalSystem/Metalogic/Decidability/BiLasso/README.md`) and the Decidability README
(`FormalSystem/Metalogic/Decidability/README.md`, "Modules" table, lines 33-48). The BiLasso
table's row count and its `Basic.lean is held stable` section both need a pointer to the new
directory. Note a pre-existing tension the update should not propagate: the Decidability README
describes `BiLasso/` as "outside the build graph, compile-checked by the C6 rot guard", while the
root `FormalSystem.lean` imports every BiLasso module directly (lines 115-124) and the BiLasso
README states nothing there is in `scripts/module-invariants-manifest.txt`. Verify which is
current before copying either phrasing into a new row.

## Tactic Survey Results

Tactics were exercised against the live tree through compiled spikes rather than
`lean_multi_attempt`, because the goals of interest only arise inside a multi-hundred-line
development. Findings:

| Goal | Tactic | Result | Premises/Config |
|------|--------|--------|-----------------|
| `sep` for the `Fin (k+1) × ℤ` shift set | `omega` after `abs_lt.mp` | fail | inequalities live at `↑intOrder`, invisible to `omega` |
| same | `exact Int.abs_lt_one_iff.mp h` | success | after `have h : (\|(y : ℤ)\| : ℤ) < 1 := hy` |
| same | `abs_lt_one_iff_eq_zero` | fail | declaration does not exist |
| `sh_zero`, `sh_add` for the shift set | `simp` / `simp [add_assoc]` | success | default simp set |
| `W.std.frame.IsZTime` | `exact TaskFrame.isZTime_of_instances _` | fail | `SuccOrder S.frame.Duration` unsynthesizable |
| same | `haveI`-then-`exact` | fail | `haveI` shadows the indexed `SuccOrder` (R4) |
| same | explicit `@`-application with `inferInstanceAs` | success | needs both ℤ-SuccPred imports |
| `.ZTime ≤ .Base` order side condition | `decide` | success | `FrameClass`'s `DecidableRel` instance |
| untl/snce distance inductions | `induction d with … omega` | success | mirrors `TruthLemma.lean` verbatim |
| temporal-case time bookkeeping | `omega` | fail then success | needs `@LT.lt ℤ _`-typed `have`/`replace`/`show` first (R3) |
| `box` case surjectivity | `cases u; simp [Fam.std]` | success | unfolds the shift-set literal |
| final `TruthAt` transfer | `rw [ShiftSet.forward_repr]` | fail | motive's `?w : ?S.Carrier` will not match syntactically |
| same | `(ShiftSet.forward_repr …).trans (by simpa using …)` | success | works up to defeq |
| `mem_closureOf` cons case | `simp [...] at *; tauto` | fail | `tauto` cannot fold `foldr` back |
| same | explicit `constructor`/`rintro` | success | see Phase 1 |

Axiom measurement on the spike: `truth_iff_mem`, `not_consequence_ztime` and
`joint_countermodel` each report `[propext, Classical.choice, Quot.sound]`.

## Context Extension Recommendations

- **Topic**: instance synthesis through `@[reducible]` bundled-structure projections.
  **Gap**: `context/project/lean4/` has no note on the failure mode where `rfl` succeeds and
  `inferInstance` fails on the same reduction chain (here: `ShiftSet.frame.Duration`), nor on the
  `haveI`-shadowing trap for classes indexed by another instance. Both cost a debugging cycle in
  this research and both are already documented *in Lean source docstrings*
  (`IntPresentation.lean`'s `@[reducible]` note, `FrameClassValidity.lean`'s `sat_intro` note)
  rather than anywhere an agent would look first.
  **Recommendation**: add `context/project/lean4/patterns/instance-synthesis-through-projections.md`
  citing both in-tree docstrings and the `@`-application workaround.

- **Topic**: the `↑TemporalOrder` / `ℤ` elaboration boundary.
  **Gap**: the `@LT.lt ℤ _ a b` re-ascription idiom is used throughout `BiLasso/Unfold.lean` and
  `TruthLemma.lean` but is documented nowhere outside those files, and it is not discoverable from
  the error `omega` emits.
  **Recommendation**: a short `context/project/lean4/patterns/temporal-order-coercion.md`, or a
  paragraph in the existing Lean rules file.

## Appendix

### Spike

`specs/665_witness_family_certificate_soundness/evidence/t1-agreement-spike.lean` — 262 lines,
compiles clean under `lake env lean` (two `unusedVariables` warnings, no errors, no `sorry`).
It is a *spike*, not a deliverable: it uses a `Fam` stand-in for `WitnessFamily` with the decoded
label function taken as data rather than derived from three lists, so that the T1 argument is
isolated from the (independently established) periodic-decoding layer. Phases 2 and 5 replace
`Fam.L` by `LabelledLasso`'s decoding; nothing else in the argument changes.

It is **not** wired into any Lake target and `lake build` will not compile it. If it is kept, it
belongs alongside the other semantic-FMP evidence probes and would be wired through
`scripts/check-evidence-probes.sh` (the same mechanism the C6 rot guard uses).

### Declarations read

`BiLasso/`: `Basic.lean` (BiLasso, cyc, unrollOf, windowTime, the two periodicities),
`Periodic.lean` (whole file), `Annotation.lean` (whole file), `TruthLemma.lean` (whole file),
`Unfold.lean` (`truth_untl_succ`, `truth_snce_pred`), `Decide.lean` (structure + the lemmas
tabulated above), `Enumerate.lean` (`ListEnum`, `closureSubsets`, `rawLabels`),
`Check.lean` (`SatAtState`, `checkAt`), `Assembly.lean` (whole file), `Agreement.lean`
(the three limits), `Examples.lean` (structure), `README.md`.
`Semantics/`: `ShiftSet.lean` (whole file), `Validity.lean` (`ConsequenceOnFrames`,
`SemanticConsequenceIn`, `ValidZTime`), `FrameClassValidity.lean` (`FrameClass.Sat`,
`sat_intro`, `Sat.isRegular`, `Sat.anti`), `FrameProperty.lean` (`IsZTime`,
`isZTime_of_instances`, `IsZTime.elim`), `TemporalOrder.lean` (`intOrder`),
`TaskFrame.lean` (`TaskFrame`, `FrameOver.toTaskFrame`).
`Syntax/`: `SubformulaClosure/Closure.lean` (`subformulaClosure` and the six projections),
`Formula.lean` (`neg`, `and`, `or`, `someFuture`, `somePast`, `allFuture`),
`Context.lean` (`Context := List Formula`), `BigConj.lean`.
`ProofSystem/Axioms.lean` (`FrameClass`, `Axiom.modal_future`).

### Measurements

- `(subformulaClosure (MF.neg)).card = 10`
- `(subformulaClosure (□(p ∨ Fp ∨ Pp) ∧ □(p → ¬Pp))).card = 16`
- `BiLasso/Decide.lean` = 920 lines, of which ~650 transpose to `LabelledLasso`
- `BiLasso/Enumerate.lean` = 329 lines, of which `ListEnum` + `closureSubsets` + `rawLabels`
  (~150 lines) are reusable as-is

### Searches performed

Codebase greps for `SemanticConsequenceIn`, `FrameClass.Sat`, `isZTime_of_instances`, `intOrder`,
`SubformulaClosed`/`closureOfList` (none exist), `modal_future`, `MF`; `lean_local_search` was not
needed because every candidate resolved by grep; `lean_run_code` used for six verification
snippets; `lake env lean` used for the five progressively larger spikes. No rate-limited search
tool was called — no lemma discovery over Mathlib was required beyond `Int.abs_lt_one_iff`, which
was found by direct attempt.
