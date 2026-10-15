# Research Report: Task #616

**Task**: 616 - duration_monoid_twisted_arrow_interval_site
**Started**: 2026-10-13T09:45:00Z
**Completed**: 2026-10-13T09:58:00Z
**Effort**: ~15 minutes
**Dependencies**: Task 563 (landed — `FormalSystem/Semantics/Presheaf/Site.lean` exists)
**Sources/Inputs**:
- Codebase: `FormalSystem/Semantics/Presheaf/Site.lean`, `FormalSystem/Semantics/TemporalOrder.lean`,
  `FormalSystem/Semantics/Presheaf.lean`, `FormalSystem/Semantics/Presheaf/README.md`,
  `FormalSystem.lean`, `docs/reference/paper-definitions-of-record.md`,
  `docs/development/REFERENCE_NORMAL_FORM.md`, `docs/development/MODULE_INVARIANTS.md`
- Paper (verbatim statements of record): `~/Philosophy/Papers/PossibleWorlds/JPL/appendix_cut_material.tex`
  lines 250–313 (`def:interval-site`, `def:behavior-presheaf`, `def:twisted-arrow`,
  `lem:interval-twisted-arrow` with its proof)
- Verification report of record:
  `~/Philosophy/Papers/PossibleWorlds/specs/archive/111_verify_interval_twisted_arrow_lemma/reports/01_verify-twisted-arrow-lemma.md`
- lean-lsp MCP: `lean_run_code` (compiled probes), `lean_loogle`, `lean_local_search`
**Artifacts**:
- `specs/616_duration_monoid_twisted_arrow_interval_site/reports/01_duration-monoid-twisted-arrow.md`
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The whole module compiles today, with zero sorries and no new import.** Every deliverable —
  the duration monoid's three laws, the factorization category with both halves of
  factorization-linearity, the twisted-arrow category with all three category laws, the hom-set
  bijection in both directions, functoriality, and both coverage-transport equations — was
  prototyped end to end in `lean_run_code` against `FormalSystem.Semantics.Presheaf.Site` alone.
  Implementation is transcription, not discovery.
- **The design decision the task asks to record has already been made, by Site.lean, and should be
  followed rather than re-litigated.** `Site.lean`'s Implementation Notes record the
  concrete-structures/no-`Mathlib.CategoryTheory` choice with three reasons, and explicitly
  nominate "the duration monoid `BD⁺` and the twisted-arrow description of this site" as the
  candidates that should "add the instance beside these declarations and reconcile with this note,
  rather than restating the site under a second encoding." The reconciliation is the deliverable;
  a fresh decision is not.
- **The Mathlib route would buy almost nothing here.** Mathlib has no twisted-arrow category, no
  factorization category, and no factorization-linearity: `loogle "Twisted"` returns nothing, and
  all four of `Fact`, `Tw`, factorization-linearity and the Johnstone coverage would have to be
  defined by hand either way. What Mathlib supplies (`CategoryTheory.SingleObj`,
  `CategoryTheory.Coverage`) is bookkeeping this module does not need, and `SingleObj` is
  multiplicative while the duration monoid is additive.
- **Task 563 landed only the `Int(D)` side, so this task does not narrow.** No factorization,
  twisted-arrow or duration-monoid material exists anywhere under `FormalSystem/Semantics/Presheaf/`
  — the only occurrences are the Site docstring's forward references. Full scope stands.
- **Scope gap: four files outside the declared `file_scope` must be touched.** Beyond the aggregator
  the task already anticipates, check C33 forces a `FormalSystem.lean` regeneration and enforced
  check C15 forces three new rows in `docs/reference/paper-definitions-of-record.md`.
- **Two concrete pitfalls found by compiled probe**: `Fact` collides with Mathlib's `Fact` class,
  and `add_right_cancel` at `↑D` drags `Classical.choice` into the axiom footprint where a commuted
  `add_left_cancel` stays at `[propext]`.

## Context & Scope

The task formalizes `def:twisted-arrow` and `lem:interval-twisted-arrow`: that the duration monoid
`BD⁺` is factorization-linear, and that its twisted-arrow category is isomorphic to the interval
category `Int(D)` by an isomorphism carrying the Johnstone coverage of one to the other. The
constraint is `lake build FormalSystem` green with no new sorry at the end of every phase.

Research covered four questions: where the paper's statements of record now live; whether task 563
pre-empted any of this; whether the concrete or the Mathlib encoding is right, on evidence rather
than preference; and whether each required proof actually goes through in this tree's Lean and
Mathlib pins.

Two dispatch pointers are stale and were re-resolved. The dispatch says the three anchors are
commented out inside a `% SECTION CUT` block in `JPL/possible_worlds.tex`; they are not in that
file at all any more. The entire cut block was relocated to `JPL/appendix_cut_material.tex`, and
the statements were read there. The dispatch's path for the verification report is also stale; it
now sits under `specs/archive/111_verify_interval_twisted_arrow_lemma/`.

## Literature Proof Structure

**Source**: `def:twisted-arrow` and `lem:interval-twisted-arrow` with its proof,
`~/Philosophy/Papers/PossibleWorlds/JPL/appendix_cut_material.tex:278–313`; the statement of
record for their correctness is the archived verification report named under Sources.

**Strategy**: direct construction. Factorization-linearity is proved from totality plus
cancellation; the isomorphism is built as an identity-on-objects, bijective-on-homs assignment and
then checked functorial and coverage-preserving.

The paper's proof is already the post-fix version: the verification report's recommendations R1
and R2 have been applied, so the duration monoid is now defined as an item of `def:interval-site`,
the proof runs one paragraph per sub-claim, and the final paragraph supplies the
covering-families-correspond-bijectively step that the report flagged as missing.

### Step Map

1. **Duration monoid.** `BD⁺` is the one-object category whose morphisms are the durations
   `ℓ ∈ D⁺`, composing by addition with identity `0` — `def:interval-site`, *Duration Monoid* item.
2. **Factorization category.** `Fact(ℓ)` has as objects the factorizations `ℓ = x + y` with
   `x, y ∈ D⁺`, and as morphisms `(x, y) → (x', y')` the durations `z ∈ D⁺` with `z + x = x'` and
   `y = z + y'` — `def:twisted-arrow`, *Factorization Category* item.
3. **Factorization-linearity, at most one.** Any such `z` is forced to equal `x' - x` by
   cancellation, so there is at most one morphism between two objects.
4. **Factorization-linearity, at least one.** Totality of `≤` on `D` gives `x ≤ x'` or `x' ≤ x`;
   in the first case `z := x' - x` lies in `D⁺` and cancellation yields `y = z + y'`.
5. **Twisted-arrow category.** `Tw(BD⁺)` has as objects the durations and as morphisms `ℓ' → ℓ`
   the pairs `(p, q) ∈ D⁺ × D⁺` with `p + ℓ' + q = ℓ`, composing
   `(p, q) ∘ (p', q') := (p + p', q' + q)` with identities `(0, 0)`.
6. **Hom-set bijection.** `(p, q) ↦ Tr p` lands among the translations because `p + ℓ' + q = ℓ`
   with `q ∈ D⁺` gives `p + ℓ' ≤ ℓ`; it is injective because `Tr p = Tr p'` gives `p = p'` and
   then cancellation gives `q = q'`; it is surjective because `q := ℓ - p - ℓ'` lies in `D⁺`.
7. **Functoriality.** The composite `(p + p', q' + q)` goes to `Tr (p + p') = Tr p ∘ Tr p'`, and
   `(0, 0)` goes to `Tr 0`. Identity on objects plus bijective on homs gives an isomorphism.
8. **Coverage transport.** A covering family of `Tw(BD⁺)` at a factorization `ℓ = p + q` is
   `(0, q) : p → ℓ` and `(p, 0) : q → ℓ`, carried to `Tr 0 : p → ℓ` and `Tr p : ℓ - p → ℓ`.
9. **Coverage bijection.** The factorizations of `ℓ` correspond bijectively to the cut points
   `p ∈ [0, ℓ]`, with `q = ℓ - p`, so the correspondence of covering families is itself a
   bijection and the isomorphism is one of sites.

### Dependencies

- Steps 3 and 4 depend on step 2's morphism identification. The verification report records this
  as defect D1 in an earlier draft of the paper's proof: the inference to "linear preorder" is
  not visible without naming the morphisms of `Fact(ℓ)` first. The Lean module must therefore
  carry `Factorization.Hom` as a declaration, not fold it into the two theorems.
- Step 6's injectivity and surjectivity both depend on group cancellation; step 4 depends on
  totality. The two conjuncts of the lemma are not redundant — totality is needed only for
  factorization-linearity.
- Step 9 depends on step 8 and is what upgrades "isomorphism of categories" to "isomorphism of
  sites". The verification report records its absence as defect D2; it is present in the current
  paper text and must be present in the Lean module.

### Potential Formalization Challenges

- **Step 8's object mismatch.** `Site.lean`'s `coverRight` is indexed by the cut point `p` and
  types its source object as `⟨l.val - p, _⟩`. A `Tw` cover indexed by an independent `q` would
  give a source object `⟨q, _⟩` that is only propositionally equal to it, so the transport
  equation would not typecheck without a transport. Resolution: index the `Tw` coverage by the cut
  point exactly as `Site.lean` does, taking `q := l - p`. Verified below — both transport
  equations then close by `ext; rfl`.
- **Step 9's encoding.** Stating "factorizations correspond bijectively to cut points" as a
  full `Equiv` requires both objects in one type; stating it as `Factorization.fst_le` plus
  `ofCut` plus the two round trips is lighter and stays in `Site.lean`'s idiom. Verified below.
- **Nothing else translates awkwardly.** The construction uses only what `TemporalOrder` supplies
  — totality, translation-invariance, group inverses, commutativity — and the verification report
  confirms no hidden hypothesis beyond those.

## Findings

### Codebase Patterns

**`Site.lean` has already fixed the encoding, and it fits this task exactly.** Objects are
`abbrev Obj (D) := TemporalOrder.PositiveCone D`; morphisms are a one-field-extensional
`structure Tr` carrying `shift : ↑D` plus `0 ≤ shift` plus `shift + l'.val ≤ l.val`; the three
category laws are plain theorems proved `by ext; simp`; the coverage is two named morphisms plus
`cover_germ_composites`. Durations are handled as elements of `↑D` with a nonnegativity side
condition, never as subtype arithmetic.

Two consequences for this task. First, the objects of `Int(D)` *are* the morphisms of `BD⁺` in
this encoding, so `Obj D` plays both roles and the twisted-arrow identification needs no second
duration type. Second, `Site.lean`'s Implementation Note on `shift + l' ≤ l` versus the
factorization equation is precisely the hom-set bijection of step 6, recorded in prose; this
module turns that note into theorems.

**The task's design decision is a reconciliation, not an open question.** `Site.lean:55–66`
records the concrete choice with three reasons — no category theory is imported anywhere in the
live tree, the content of the site is three composition laws plus a coverage, and the concrete
route keeps the module buildable from `TemporalOrder.lean` alone — and then says the decision is
reversible without changing a definition, naming `BD⁺` and the twisted-arrow description as the
natural places an instance would be added. Re-opening the question here would contradict the
"made once" instruction in the task description, since it was made once already, one module over.

**Nothing has been pre-empted.** `grep` over `FormalSystem/Semantics/Presheaf/*.lean` for
factorization, twisted-arrow and duration-monoid vocabulary returns only `Site.lean`'s docstring
forward references. Task 563 landed `Int(D)` and the coverage and stopped there.

**Four files outside `file_scope` are structurally required.**

| File | Why | Gate |
|---|---|---|
| `FormalSystem.lean` | must be byte-exact `lake exe mk_all --lib FormalSystem` output | C33, enforced |
| `FormalSystem/Semantics/Presheaf.lean` | aggregator import plus a `## Modules` bullet | C24 root closure; repo convention |
| `docs/reference/paper-definitions-of-record.md` | three anchors have no row | C15, enforced |
| `FormalSystem/Semantics/Presheaf/README.md` | module table row | convention, ungated |

`def:twisted-arrow` has no row at all; `lem:interval-twisted-arrow` and `lem:factorization-linear`
appear only in that file's prose, as two of "the remaining nine" appendix anchors it deliberately
left untracked. `REFERENCE_NORMAL_FORM.md` is explicit that the row goes in before the citation,
never after, and all three must be `DANGLING` rows because the appendix is cut and
`check-paper-definitions.sh --resolve` cannot read text off a commented-out `\label{}`.

The two bibliography keys the docstring needs, `schultz2020` and `johnstone1999`, already resolve
in the root `references.bib`, so C31 needs nothing.

### External Resources

**Mathlib has no twisted-arrow category and no factorization-linearity.** `loogle "Twisted"`
returns zero results. A compiled probe confirms what Mathlib does have:
`CategoryTheory.SingleObj : Type u → Type` with `SingleObj.category` requiring `[Monoid M]`,
`CategoryTheory.Coverage`, and `CategoryTheory.Comma`. None of `Fact`, `Tw`,
factorization-linearity or the Johnstone coverage is available, so the Mathlib route would still
require all four by hand and would additionally need `Multiplicative (PositiveCone D)` to reach
`SingleObj`, since `SingleObj` is multiplicative and the duration monoid is additive.

**Mathlib's nonneg-subtype algebra is available but not needed.** `Mathlib.Algebra.Order.Nonneg.Basic`
gives `AddCommMonoid (TemporalOrder.PositiveCone D)` and `LinearOrder` on it, with
`(a + b).val = a.val + b.val` by `rfl`, all verified by probe. It is not imported by
`TemporalOrder.lean` or `Site.lean`. It would let `BD⁺` be literally Mathlib's monoid instead of a
hand-rolled `comp`/`id` pair, but it is not required: the hand-rolled version compiles too, and
adding an `AddCommMonoid` instance on `Obj D` propagates to every later importer of this module and
could change how `+` elaborates in tasks 564–567. See Decisions.

**Hypotheses used, per the verification report.** Total order (only for factorization-linearity),
group cancellation and inverses, translation-invariance, and commutativity. Not used:
Archimedeanness, discreteness, density, Dedekind completeness, divisibility, or nontriviality.
The report's verdict is that the lemma is correct as stated and the generality claim is not an
overstatement, so no narrowing of the Lean statement is warranted.

### Recommendations

**A sorry-free path exists and is verified.** Every declaration below compiled in a `lean_run_code`
probe against `import FormalSystem.Semantics.Presheaf.Site` and nothing else. No new import, no
`sorry`, no axiom introduction. The recommended shape of
`FormalSystem/Semantics/Presheaf/Duration.lean`:

1. **`Dur D`** — `abbrev Dur (D : TemporalOrder) : Type := TemporalOrder.PositiveCone D`, the
   morphisms of `BD⁺`. Equal to `Obj D` by design; the alias exists so the docstring can say which
   role is in play. With `Dur.comp a b := ⟨a.val + b.val, add_nonneg a.2 b.2⟩`, `Dur.id`,
   `comp_val`/`id_val` as `@[simp] rfl` lemmas, and `id_comp`/`comp_id`/`comp_assoc`/`comp_comm`
   each `by ext; simp [...]`.
2. **`Factorization l`** — a structure over `(l : Obj D)` with `fst snd : ↑D`, `fst_nonneg`,
   `snd_nonneg`, `add_eq : fst + snd = l.val`. `@[ext]` extensionality **on `fst` alone**: a
   factorization is determined by its first summand, by `add_left_cancel`.
3. **`Factorization.Hom a b`** — `z : ↑D`, `z_nonneg`, `left : z + a.fst = b.fst`,
   `right : a.snd = z + b.snd`. A named declaration, not folded into the theorems, because the
   morphism identification is the load-bearing step the paper's earlier draft omitted.
4. **`Factorization.hom_unique`** — at most one morphism. Via a commuted `add_left_cancel`, not
   `add_right_cancel`; see Risks.
5. **`Factorization.homOfLe`** — the comparison morphism when `a.fst ≤ b.fst`, with
   `z := b.fst - a.fst`. `left` is `sub_add_cancel`; `right` is
   `rw [sub_add_eq_add_sub, eq_sub_iff_add_eq, add_comm a.snd a.fst]` then
   `a.add_eq.trans b.add_eq.symm`.
6. **`Factorization.hom_total`** — at least one morphism in one direction or the other, by
   `le_total a.fst b.fst`. Items 4 and 6 together are factorization-linearity.
7. **`Factorization.fst_le`, `Factorization.ofCut`, `Factorization.ofCut_fst_self`** — the
   bijection between factorizations of `l` and cut points `p ∈ [0, l]`, which is step 9.
8. **`Tw l' l`** — a structure with `pre post : ↑D`, `pre_nonneg`, `post_nonneg`,
   `factors : pre + l'.val + post = l.val`, with `@[ext]` on both components.
9. **`Tw.id`, `Tw.comp`** — `⟨0, 0, …⟩` and `⟨f.pre + g.pre, g.post + f.post, …⟩`, the second
   component in the paper's order. `Tw.comp`'s `factors` field closes by a three-step `calc`
   whose first step is `by simp only [add_assoc]`.
10. **`Tw.comp_pre`, `Tw.comp_post`, `Tw.id_pre`, `Tw.id_post`** — `@[simp] rfl`; then
    `Tw.id_comp`, `Tw.comp_id`, `Tw.comp_assoc` each `by ext <;> simp [...]`.
11. **`Tw.toTr`, `Tw.ofTr`** — `(p, q) ↦ Tr p` and `Tr p ↦ (p, l - p - l')`. `toTr`'s
    `shift_add_le` is `rw [← f.factors]; exact le_add_of_nonneg_right f.post_nonneg`; `ofTr`'s
    `post_nonneg` is `sub_nonneg.mpr (le_sub_iff_add_le'.mpr f.shift_add_le)` and its `factors`
    is `rw [sub_sub, add_sub_cancel]`.
12. **`Tw.toTr_ofTr`, `Tw.ofTr_toTr`** — the hom-set bijection, both directions. The second needs
    `change` (not `show`, per the style linter) to `l.val - f.pre - l'.val = f.post`, then
    `rw [sub_sub, ← f.factors]` and `add_sub_cancel_left`.
13. **`Tw.toTr_comp`, `Tw.toTr_id`** — functoriality, both `by ext; simp`.
14. **`Tw.coverLeft`, `Tw.coverRight`** — the Johnstone coverage of `Tw(BD⁺)`, indexed by the cut
    point `p` with `q := l - p`, mirroring `Site.lean`'s indexing so the transport equations
    typecheck without a transport.
15. **`Tw.toTr_coverLeft`, `Tw.toTr_coverRight`** — the coverage transport, both `by ext; rfl`.

**Record the design decision as a reconciliation.** The module docstring's Implementation Notes
should state the trade-off, name the choice, and point at `Site.lean`'s note as the place the
decision was first recorded — which is what that note asks for. The reasoning to record: Mathlib
supplies no twisted-arrow category, no factorization category and no factorization-linearity, so
the Mathlib route would hand-roll all four regardless and would additionally need
`Multiplicative` to reach `SingleObj`; what it would buy is `Category` bookkeeping for three laws
this module proves in three lines each, at the cost of being the import that introduces category
theory to the live tree. The concrete route also keeps this module buildable from `Site.lean`
alone, which is what keeps it below `Semantics/Truth.lean` in the layering. The decision stays
reversible for the same reason `Site.lean` gives: `Tw.id`, `Tw.comp` and the three laws are
exactly the fields a `Category` instance on `Obj D` would need.

**Plan the out-of-scope touches explicitly, and do the anchor rows first.** Add the three
`DANGLING` rows to `docs/reference/paper-definitions-of-record.md` before writing any docstring
citation, because C15 is enforced and `REFERENCE_NORMAL_FORM.md` requires the row first. Then
the module, then the aggregator line and its `## Modules` bullet, then
`lake exe mk_all --lib FormalSystem` to regenerate `FormalSystem.lean`, then the README table row.
Do not widen `file_scope` to the aggregator — the dispatch is explicit that doing so would make
the collision gate defer the whole categorical front every cycle.

## Decisions

- **Concrete Lean structures, no `Mathlib.CategoryTheory`** — following and reconciling with
  `Site.lean`'s recorded decision rather than making a new one. Grounds: Mathlib has none of the
  four notions this module needs, `SingleObj` is multiplicative where the duration monoid is
  additive, and the concrete route keeps the module buildable from `Site.lean` alone.
- **Index the `Tw` coverage by the cut point, not by an independent second summand.** Forced by
  typechecking against `Site.lean`'s `coverRight`, whose source object is `⟨l.val - p, _⟩`.
- **Do not import `Mathlib.Algebra.Order.Nonneg.Basic`.** It works, and it would make `BD⁺`
  literally Mathlib's `AddCommMonoid` on the positive cone, but the hand-rolled `comp`/`id` pair
  compiles with no new import at all, matches `Site.lean`'s `↑D`-with-side-conditions idiom, and
  avoids putting an `AddCommMonoid (Obj D)` instance in scope for every later importer. Recorded
  as a trade-off rather than a non-option: if tasks 564–567 later want subtype arithmetic on the
  cone, this is the import to add, and adding it then changes no definition here.
- **Name the factorization category `Factorization`, not `Fact`.** `Fact` is Mathlib's
  typeclass-carried-proposition class (`Fact : Prop → Prop`); a namespace-local `Fact` would
  shadow it and make `Fact.out` ambiguous inside the namespace. `Factorization` and `Tw` are both
  free, verified by probe.
- **Carry `Factorization.Hom` as its own declaration.** The verification report's defect D1 is
  exactly the omission of this identification; folding it into the two linear-preorder theorems
  would reproduce the defect in Lean.
- **State factorization-linearity as the two separate theorems the paper's definition names**
  (at most one morphism; at least one in one direction or the other), not as a single bundled
  predicate. That keeps each half citable on its own, which matters because only the second uses
  totality.

## Risks & Mitigations

- **Risk**: `add_right_cancel` at `↑D` silently widens the axiom footprint. Probe:
  `(h : z + a = b) (h' : z' + a = b) ⊢ z = z'` proved by `add_right_cancel (h.trans h'.symm)`
  reports `[propext, Classical.choice, Quot.sound]`, while the same goal proved by a commuted
  `add_left_cancel` reports `[propext]`. **Mitigation**: use the commuted `add_left_cancel` form
  in `hom_unique`, and `#print axioms` each new theorem before closing the phase. The Presheaf
  README carries a per-declaration axiom-footprint table, so an unnecessary `Classical.choice`
  would land in published documentation.
- **Risk**: the aggregator line is a shared touch with every other task on this front, and the
  collision gate cannot see it because the path is in no task's `file_scope`. **Mitigation**:
  the dispatch's own instruction — orchestrate this front singly or in pairs, re-read the
  aggregator immediately before editing it, stage only this task's hunks, and re-run the build
  after the aggregator edit.
- **Risk**: `FormalSystem.lean` is regenerated, not hand-edited, and a hand-added import line
  fails C33 byte-exactness. **Mitigation**: run `lake exe mk_all --lib FormalSystem` and commit
  its output verbatim; `lake exe mk_all --lib FormalSystem --check` is the cross-check.
- **Risk**: C15 fails the build if a docstring cites an anchor with no row. **Mitigation**: add
  the three `DANGLING` rows as the first implementation step, before any docstring is written.
- **Risk**: the paper anchors are unpinnable, so the Lean statements' correspondence to the paper
  rests on a record rather than on live text, and the surviving commented block carries a bare
  `% CHECK` — the author has not finished reviewing this material. **Mitigation**: the same
  posture `Site.lean` already takes. Say so at each citation site, cite
  `docs/reference/paper-definitions-of-record.md` as the source of record rather than the `.tex`
  file, and note that the mathematics is Lean-checked regardless of the appendix's fate.
- **Risk**: the dispatch's paper paths are stale (the cut block has moved to
  `appendix_cut_material.tex`; the verification report has moved to `specs/archive/`), so a later
  phase following the dispatch literally will find nothing and may conclude the material never
  existed. **Mitigation**: both corrected paths are recorded under Sources above, and the
  relocation is logged in this task's issue log.

## Tactic Survey Results

Tactics were exercised against the real goals of the recommended declarations, inside
`lean_run_code` probes rather than `lean_multi_attempt`, because every goal sits inside a
structure field or a fresh declaration rather than at a position in an existing file.

| Goal | Tactic | Result | Premises/Config |
|------|--------|--------|-----------------|
| `Dur` monoid laws (`id_comp`, `comp_id`, `comp_assoc`, `comp_comm`) | `ext; simp [...]` | success | `add_assoc`, `add_comm` |
| `Factorization.ext` on `fst` alone | `obtain`/`subst` + `add_left_cancel` | success | `[propext]` footprint |
| `Factorization.hom_unique` | `add_right_cancel` | success, rejected | drags `Classical.choice` |
| `Factorization.hom_unique` | commuted `add_left_cancel` | success, adopted | `[propext]` footprint |
| `homOfLe.right` | `rw [sub_add_eq_add_sub, eq_sub_iff_add_eq, add_comm]` | success | explicit, no `linarith` |
| `homOfLe.right` | `linarith` | fail | tactic unavailable in this import closure |
| `homOfLe.right` | `abel` | fail | tactic unavailable in this import closure |
| `Factorization.hom_total` | `rcases le_total …` + `homOfLe` | success | — |
| `Tw.comp.factors` | three-step `calc`, first step `simp only [add_assoc]` | success | plain `rw [add_assoc, …]` left a goal |
| `Tw` category laws | `ext <;> simp [add_assoc]` | success | — |
| `Tw.toTr` `shift_add_le` | `rw [← factors]; exact le_add_of_nonneg_right _` | success | — |
| `Tw.ofTr` `post_nonneg` | `sub_nonneg.mpr (le_sub_iff_add_le'.mpr _)` | success | — |
| `Tw.ofTr` `factors` | `rw [sub_sub, add_sub_cancel]` | success | — |
| `Tw.toTr_ofTr` | `ext; simp` | success | — |
| `Tw.ofTr_toTr` | `ext` + `change` + `rw [sub_sub, ← factors]` + `add_sub_cancel_left` | success | `show` trips the style linter; use `change` |
| `Tw.toTr_comp`, `Tw.toTr_id` | `ext; simp` | success | — |
| `Tw.toTr_coverLeft`, `Tw.toTr_coverRight` | `ext; rfl` | success | requires cut-point indexing |

`lean_hammer_premise` and `lean_state_search` were not used: no goal resisted a first attempt, so
premise discovery had nothing to contribute. `lean_local_search` was attempted once and returned
`index: warming`, which is not proof of absence; name-freedom for `Factorization` and `Tw` was
therefore established by compiled `#check` probes instead, which is the stronger evidence tier.

## Context Extension Recommendations

- **Topic**: the out-of-scope file set a new `FormalSystem/` module unavoidably drags in.
- **Gap**: nothing in the Lean context documents that adding one module requires a
  `FormalSystem.lean` regeneration (C33), a sibling aggregator edit (C24), and a
  paper-definitions row per cited anchor (C15). Each is documented in its own place; the
  *checklist* is not. This task's declared `file_scope` named one file and the real answer is
  five, and the same miss will recur on tasks 564–567.
- **Recommendation**: add `context/project/lean4/patterns/new-module-checklist.md` naming the four
  companion edits, the order they must happen in (anchor rows before docstrings), and the
  regeneration command, cross-referenced from the lean extension's rules file.

## Appendix

**Search queries used**

- `lean_loogle "Twisted"` — zero results; Mathlib has no twisted-arrow category.
- `lean_loogle "SingleObj"` — only `HomologicalComplex.singleObj*` hits; the one-object-category
  construction was then confirmed by `#check @CategoryTheory.SingleObj`.
- `lean_local_search "Nonneg.orderedAddCommMonoid"` — `index: warming`, no conclusion drawn.
- Compiled probes: nonneg-subtype instance synthesis with and without
  `Mathlib.Algebra.Order.Nonneg.Basic`; `CategoryTheory.SingleObj`/`Coverage`/`Comma` existence;
  `Fact`/`Factorization`/`Tw` name freedom; the full module prototype in four parts; and
  `#print axioms` on the factorization declarations and on the two cancellation routes.
- `grep` sweeps: `CategoryTheory` across `FormalSystem/` (nothing live, as the task description
  states); factorization/twisted/duration-monoid vocabulary across
  `FormalSystem/Semantics/Presheaf/`; anchor rows in `docs/reference/paper-definitions-of-record.md`;
  `schultz2020`/`johnstone1999` in `references.bib`.

**References to documentation**

- `FormalSystem/Semantics/Presheaf/Site.lean` — the encoding this module extends, and the
  Implementation Note that nominates this task as its reconciliation site
- `FormalSystem/Semantics/TemporalOrder.lean` — `TemporalOrder`, `PositiveCone`
- `docs/development/REFERENCE_NORMAL_FORM.md` — the `## References` block form, and the
  row-before-citation rule for paper anchors
- `docs/development/MODULE_INVARIANTS.md` — C15, C24, C31, C33
- `docs/reference/paper-definitions-of-record.md` — the citation source of record; the paragraph
  listing the nine still-untracked appendix anchors
- `~/Philosophy/Papers/PossibleWorlds/JPL/appendix_cut_material.tex:250–313` — the verbatim
  statements
- `~/Philosophy/Papers/PossibleWorlds/specs/archive/111_verify_interval_twisted_arrow_lemma/reports/01_verify-twisted-arrow-lemma.md`
  — the statement of record for the lemma's correctness, its defect inventory, and the exact
  hypotheses the construction uses
