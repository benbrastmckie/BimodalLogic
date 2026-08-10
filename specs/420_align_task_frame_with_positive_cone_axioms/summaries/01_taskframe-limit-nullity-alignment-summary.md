# Implementation Summary: Aligning `TaskFrame` with the Positive-Cone `def:frame`

- **Task**: 420 - align_task_frame_with_positive_cone_limit_nullity
- **Type**: lean4
- **Session**: sess_1785332177_7809d8
- **Date**: 2026-07-29
- **Plan**: `specs/420_align_task_frame_with_positive_cone_limit_nullity/plans/01_taskframe-limit-nullity-alignment.md`
- **Outcome**: Phases 1-5 complete (5 of 6). Phase 6 remains `[BLOCKED]` by design.

## Result

All five in-scope phases landed green, with **zero debt**: no `sorry`, no new axiom, no vacuous
definition, and a green `lake build` at every phase boundary. Phase 6 (the `limit_nullity`
structure field and the tree-wide site discharge) was deliberately not started; it is blocked on
the deterministic-shift replacement for `ParametricCanonicalTaskFrame`.

Reaching 5 of 6 phases is the intended terminus for this dispatch, not a shortfall.

## What Changed, by Phase

### Phase 1 — Re-anchor stale `def:frame` citations [COMPLETED]

All 7 stale `def:frame, line 1835` citations re-anchored to `possible_worlds.tex:2423-2451`
(formal statement) with the body statement at `possible_worlds.tex:908-926` recorded alongside.
The research's asserted count of 7 sites across 4 files was confirmed exactly by the discovery
grep. Post-edit grep for `line 1835` outside `specs/**` returns nothing.

Files: `FormalSystem/Semantics/TaskFrame.lean` (3), `FormalSystem/Examples/TemporalStructures.lean`
(2), `docs/user-guide/architecture.md` (1), `docs/reference/API_REFERENCE.md` (1).

### Phase 2 — Recast docstrings from divergence to agreement [COMPLETED]

The module docstring, the structure docstring, and the `forward_comp` and `converse` field
docstrings were rewritten. The substantive corrections:

- The `Axiomatization Notes` block no longer claims a divergence. It records that the paper has
  adopted the same positive-cone presentation and calls it "its official form"
  (`possible_worlds.tex:964`), states the law as the **lax** inclusion `R_{x+y} ⊇ R_x ∘ R_y`
  (equality would additionally assert interpolation and is not adopted), and reproduces the
  paper's own nondeterminism-collapse argument for why mixed-sign composition must remain
  inexpressible (`possible_worlds.tex:957-959`).
- The `converse` field is now documented as the paper's **definitional converse convention
  packaged as structure data**, not a substantive temporal-symmetry axiom. The prose makes
  explicit that the pair (two-sided `TaskRel`, `converse`) *is* the paper's extended relation
  over a primitive relation on `D⁺`.
- `forward_comp`'s `0 ≤ x`, `0 ≤ y` hypotheses are documented as the expression of the paper's
  domain restriction against a two-sided relation, not as a weakening.
- Reflection (`nullity`) and backward composition (`backward_comp`) are recorded as **derived**,
  matching the paper.
- A **Known gaps** list states plainly, without silently repairing them: `W` is not required
  nonempty; `[Nontrivial D]` is not a structure binder; and *Limit Nullity* is the one paper
  clause still absent, with its intended transcription spelled out as prose.

`git diff` confirms every change sits inside a comment region; no field name, type, or the
structure signature changed.

### Phase 3 — Two reusable Limit Nullity discharge helpers [COMPLETED]

Both landed as standalone theorems in `namespace TaskFrame`, stated against a bare relation
`R : W → D → W → Prop` so they apply whether or not the clause is carried as a field.

```
theorem limit_nullity_of_succOrder [SuccOrder D] [NoMaxOrder D]
    {W : Type} {R : W → D → W → Prop} (hnull : ∀ w u, R w 0 u ↔ w = u) :
    ∀ w u, (∀ x, 0 < x → ∃ y, |y| < x ∧ R w y u) → u = w

theorem limit_nullity_of_shift [Nontrivial D] {W : Type} (pos : W → D)
    {R : W → D → W → Prop}
    (hshift : ∀ w y u, R w y u → pos u = pos w + y)
    (hzero : ∀ w u, R w 0 u → u = w) :
    ∀ w u, (∀ x, 0 < x → ∃ y, |y| < x ∧ R w y u) → u = w
```

**Scope Hypothesis resolved — the shift helper was CONFIRMED, not narrowed.** The plan flagged
`limit_nullity_of_shift` as prose-argued rather than machine-checked. The general `pos`-indexed
form elaborates and proves exactly as stated, with **one added binder**: `[Nontrivial D]`. The
binder is genuinely necessary, not an artifact of the proof — over a trivial duration group no
positive `x` exists, the Limit Nullity hypothesis is vacuous, and the conclusion is false (take
`R := fun _ _ _ => False` on a two-element carrier). The paper independently mandates a
nontrivial totally ordered abelian group for the same reason, and the same binder is what the
research independently found `identityFrame` to need. No narrowing to the concrete three-site
shape was required, and no conclusion was weakened.

The succ-order helper was transcribed verbatim from the research and compiled on the first
attempt. Its docstring records that `NoMaxOrder D` is an instance consequence of `[Nontrivial D]`
on this repo's standard duration binders, so the existing discrete binder bundle in
`SoundnessLemmas/FrameClassVariants.lean` already subsumes both hypotheses and needs nothing new.
`IsSuccArchimedean` is not used.

### Phase 4 — Finite uniform-radius theorem [COMPLETED]

```
theorem exists_uniform_radius_of_finite [Nontrivial D] {W : Type} [Fintype W]
    (R : W → D → W → Prop)
    (hlim : ∀ w u, (∀ x, 0 < x → ∃ y, |y| < x ∧ R w y u) → u = w)
    (w : W) : ∃ x : D, 0 < x ∧ ∀ u y, |y| < x → R w y u → u = w
```

Proved as the research specified: the contrapositive of Limit Nullity supplies a pointwise radius
for each `u`, and `Finset.inf'` over the finite carrier makes it uniform. Its docstring records
the consequence (a finite frame satisfying Limit Nullity over a dense duration type is temporally
rigid, so the filtration and FMP frames cannot remain dense-polymorphic once the axiom lands, and
the move of FMP to `ℤ` is forced rather than convenient) and states why it is the deliberate
substitute for the deferred cone-topology T1 result.

The `push_neg` deprecation warning the research observed was addressed by switching to
`push Not`. `FormalSystem/Semantics/TaskFrame.lean` now builds with **zero diagnostics**.

### Phase 5 — LaTeX Task Frame restatement [COMPLETED]

`latex/subfiles/02-Semantics.tex`'s frame-definition subsection was rewritten to match both the
paper and the live tree. The definition now states: nonempty `W`; a nontrivial totally ordered
abelian group `D`; a primitive relation on the positive cone `D⁺ = {x ∈ D : x ≥ 0}` extended to
negative durations by the converse convention `w ⇒_x u := u ⇒_{-x} w` for `x < 0`; the two-sided
cone `(w)_x`; and three axioms — iff-*Nullity*, positive-cone *Compositionality*, and *Limit
Nullity* `⋂_{x>0} (w)_x = {w}`. The previous one-way Nullity and unrestricted mixed-sign
Compositionality are gone.

Also added: a `\label{def:frame}` (the file previously had zero labels, so nothing cross-references
it and no collision is possible — confirmed by the master build); a corrected primitives table with
a `D⁺` row and separate rows for the primitive and extended relations; a rewritten gloss covering
all three axioms; and a `remark` recording that Reflection and backward composition are derived
and that mixed-sign composition is inexpressible rather than prohibited.

Two macros were added to `latex/assets/bimodal-notation.sty`: `\poscone` → `D^{+}` and
`\taskcone{w}{x}` → `(w)_{x}`. `\taskcone` was chosen over a bare `\cone` to avoid future
collisions. Following the notation constraint, **no converse operator symbol was introduced at
all** — the paper states the convention with subscript negation only, so the restatement does the
same. No breve or smile notation appears anywhere.

## Plan Deviations

- **Phase 3, `limit_nullity_of_shift` — altered (hypothesis set)**: `[Nontrivial D]` added to the
  plan's stated signature. Necessary, not cosmetic (see Phase 3 above). The plan's Scope
  Hypothesis explicitly authorised confirming or adjusting the hypothesis set in Lean.
- **Phase 3, files touched — altered**: three imports were added to `TaskFrame.lean` beyond the
  plan's "two new theorems" description: `Mathlib.Algebra.Order.Group.Abs` (the `|·|` notation
  would not parse without it), `Mathlib.Order.SuccPred.Basic` (`Order.succ`), and, in Phase 4,
  `Mathlib.Data.Finset.Lattice.Fold` (`Finset.inf'`). None were anticipated by the plan; all are
  required for the plan's own transcribed statements to elaborate.
- **Phase 5, macro naming — altered**: `\taskcone` rather than `\cone`, to avoid a plausible
  future collision in a shared notation package.
- **Phase 6 — not started, by design**: left `[BLOCKED]` per the dispatch scope and the plan's
  own Decision Gate resolution (Option B). Nothing in Phases 1-5 touches the `TaskFrame`
  structure signature.

No plan step was skipped without an annotation, and no step was substituted with a different
approach.

## Verification

| Check | Result |
|---|---|
| `lake build` (full, 1983 jobs) | Green |
| `FormalSystem/Semantics/TaskFrame.lean` diagnostics | Zero (no errors, no warnings) |
| `sorry` in files changed by this task | 0 |
| Repo-wide sorry census | 164 lines, identical to the pre-task baseline (all pre-existing, in `Boneyard/`) |
| `axiom` declarations under `FormalSystem/` | 2, identical to baseline — no new axiom |
| `#print axioms` on all three new theorems | `[propext, Classical.choice, Quot.sound]` only |
| Vacuous-definition scan | 1 hit, pre-existing (`TemporalStructures.lean:279`, a genuine `trivial` proof of a `True`-valued domain predicate), not in this task's diff |
| `grep "line 1835"` outside `specs/**` | Nothing |
| Standalone `TEXINPUTS=../assets: pdflatex 02-Semantics.tex` | Clean, 4-page PDF, no undefined control sequences |
| Master `latexmk BimodalReference.tex` | Green, no duplicate-label warning for `def:frame` |
| Task-number citations in changed deliverables | None introduced (two pre-existing hits in `API_REFERENCE.md` at lines 429/714 are outside this task's diff) |

## Why Phase 6 Is Blocked

`ParametricCanonicalTaskFrame` (`Algebraic/ParametricCanonical.lean:207`) is duration-blind above
zero (`if d > 0 then ExistsTask M N`) and genuinely violates Limit Nullity over a dense duration
type — it is literally the paper's own `app:topology-r0` countermodel shape. It is the witness of
the **live** theorem `countermodel_dense_enriched` (`BXCanonical/Completeness.lean:143`, stated
as `∃ (F : TaskFrame Rat) …`), which feeds both `completeness` and `completeness_dense`; it is
also the witness at `ChronicleToCountermodelBasic.lean:839` and is elaboration-probed at `ℝ`.
Adding `[SuccOrder D] [NoMaxOrder D]` to the frame breaks all of these, since `ℚ` and `ℝ` have no
`SuccOrder`.

The sorry-free repair is a deterministic-shift product carrier — precisely the `bundleFlowFrame`
construction (`WorldState := FamIdx × D`) that the maximal-history rebase task already plans. That
refactor discharges this obligation for free via `limit_nullity_of_shift`, which is now in place
and waiting. Adding the field before that lands would break the build with no sorry-free discharge
available, which is why the correct outcome here is a blocked phase rather than a weakened field
or a placeholder.

**Phase 6 is now a mechanical drop-in.** All three discharge routes it needs exist and are
verified: subsingleton carriers close by `Subsingleton.elim`, deterministic-shift frames by
`limit_nullity_of_shift`, discrete frames by `limit_nullity_of_succOrder`.

## Out-of-Scope Items Observed

- `typst/chapters/02-semantics.typ:37` carries the same stale one-way Nullity and unrestricted
  mixed-sign Compositionality that this task just corrected in the LaTeX subfile, and
  `typst/SYNC-MAP.md:230` cites the pre-refactor paper range `possible_worlds.tex:902-907`. Both
  were flagged by the research and declared out of scope; neither was touched. They remain stale.
- `04-Metalogic.tex` and `06-Notes.tex` belong to the identifier-architecture fidelity task and
  were not touched.

## Follow-Ups Recorded (not implemented here)

- The `limit_nullity` structure field and the tree-wide site discharge (Phase 6).
- `[Nontrivial D]` on the `TaskFrame` structure binders rather than per-example — more faithful to
  the paper and would remove the ad-hoc binders scattered through `Metalogic/`, but it is a
  signature change touching every `(F : TaskFrame D)` binder in the tree.
- Enforcing the paper's nonempty-`W` requirement (pre-existing gap, now documented in the
  docstring).
- Collapsing the six duplicated frame bodies into thin wrappers, so the eventual `limit_nullity`
  proof is written once rather than six times.
- The cone-topology T1 result (`app:topology-r0`), for which `exists_uniform_radius_of_finite` is
  the current substitute.
- The two stale typst artifacts noted above.

## Files Modified

| File | Change |
|---|---|
| `FormalSystem/Semantics/TaskFrame.lean` | Anchors, docstring recast, 3 new theorems, 3 new imports |
| `FormalSystem/Examples/TemporalStructures.lean` | Anchors |
| `docs/user-guide/architecture.md` | Anchor |
| `docs/reference/API_REFERENCE.md` | Anchor |
| `latex/subfiles/02-Semantics.tex` | Frame definition restated, primitives table, gloss, remark, `\label{def:frame}` |
| `latex/assets/bimodal-notation.sty` | `\poscone`, `\taskcone` macros |

## Commits

```
334371dfb task 420 phase 1: re-anchor stale def:frame citations
4fc1307a3 task 420 phase 2: recast TaskFrame docstrings from divergence to agreement
cd6856c00 task 420 phase 3: add reusable Limit Nullity discharge helpers
5b22bb957 task 420 phase 4: add finite uniform-radius theorem
322bcd6af task 420 phase 5: restate LaTeX Task Frame definition
```
