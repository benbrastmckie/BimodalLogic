# Research Report: Totality and Directed Gluing as wrappers on the Extension Theorem

- **Task**: 565 - Prove `app:presheaf-dictionary`'s Totality and Directed Gluing clauses
- **Started**: 2026-10-03T00:00:00Z
- **Completed**: 2026-10-03T00:00:00Z
- **Effort**: 2 phases
- **Dependencies**: 563 (interval site and behavior presheaf — landed)
- **Sources/Inputs**:
  - Paper source: `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex` lines
    4061-4095 — `app:presheaf-dictionary`'s statement and proof, commented out inside the
    `% SECTION CUT` block holding `app:Structure`
  - `FormalSystem/Semantics/Presheaf/{Site,Behavior,Sheaf,Ray}.lean` and the cluster `README.md`
  - `FormalSystem/Semantics/Extension/{Extension,Completion}.lean` and `Extension/README.md`
  - `FormalSystem/Semantics/{PartialHistory,PartialHistoryOrder}.lean`
  - `specs/archive/553_decide_convex_history_layer_collapse/reports/01_convex-correlate-and-consequence.md`
    §5.1 (the `app:Structure` → tree dictionary)
  - `specs/718_omega_sequence_decidability_full_lplus/reports/01_gluing-route-seed.md` §6 (the
    binary/directed split)
  - `docs/development/{MODULE_INVARIANTS,REFERENCE_NORMAL_FORM}.md`,
    `docs/reference/paper-definitions-of-record.md`
  - lean-lsp MCP: `lean_verify`, `lean_run_code` (six compiled probes), `lean_local_search`
- **Artifacts**:
  - `specs/565_totality_and_directed_gluing_from_extension_theorem/reports/01_totality-directed-gluing-wrappers.md`
- **Standards**: report-format.md, subagent-return.md

## Project Context

- **Upstream Dependencies**: `FormalSystem/Semantics/Presheaf/Behavior.lean` (`Beh`,
  `Beh.restrict`, `Beh.restrictTr`, `partialHistory_ext`), `FormalSystem/Semantics/Presheaf/Site.lean`
  (`Interval`, `Obj`, `Tr`), `FormalSystem/Semantics/Extension/Extension.lean`
  (`PartialHistory.extension`, `isRestriction_of_isRegular`),
  `FormalSystem/Semantics/Extension/Completion.lean` (`extension_of_completion`,
  `extension_of_isZTime`), `FormalSystem/Semantics/PartialHistoryOrder.lean` (the extension
  preorder, `le_def`)
- **Downstream Dependents**: none yet. The remaining dictionary clauses (Possible Worlds,
  Determinism, Reflection) do not consume these two.
- **Alternative Paths**: `PeriodicExtension.lean`'s constructive ℤ-time route was considered and
  is not needed — `Completion.lean`'s `extension_of_isZTime` already delivers the same
  Saturation-free conclusion in general form and composes with the engine below for free.
- **Potential Extensions**: the directed union of partial histories belongs in
  `PartialHistoryOrder.lean` beside `chainSup`, with `chainSup` derivable from it. This task's
  hard constraint forbids touching that file, so the union lands locally and the consolidation is
  recorded as a follow-up.

## Executive Summary

- **Both clauses are wrappers, and the wrappers are now machine-checked.** Every declaration
  sketched below was compiled through `lean_run_code` against the live tree: the translate
  (`place`), the cut (`ofWorld`), the agreement bridge (`restrict_ofWorld`), Totality in engine
  form, at `[F.IsRegular]`, over ℤ-time and at bare *Completion*, the directed union
  (`directedSup`) with its two supporting lemmas, Directed Gluing's existence half, its
  uniqueness half under covering, and the paper's "any two restrict a third" bridge
  (`place_le_place`). No step is conjectural and no `sorry` is needed anywhere.
- **The choice record is a four-row table, not a two-row one, and the measurements are exact.**
  `sheaf_clause` measures `[propext, Quot.sound]`; `PartialHistory.extension` measures
  `[propext, Classical.choice, Quot.sound]`; the Totality **engine** — the extension property
  taken as a hypothesis — measures `[propext, Quot.sound]`, so the `Classical.choice` in Totality
  is attributable *exactly* to `thm:extension` and to nothing in the wrapper; `directedSup`
  measures `[propext, Classical.choice]` on its own, so Directed Gluing's choice is **doubly**
  sourced. That is a sharper statement than "Sheaf is choice-free, Directed Gluing is not".
- **Parameterizing on the extension property is the load-bearing design decision.** It buys the
  exact choice attribution above, it buys the minimal-hypothesis variants (`Completion`, ℤ-time)
  for one line each, and it is what keeps invariant C34a green: the binder-free engine is the
  twin that each `[F.IsRegular]` corollary delegates to.
- **One trap found and avoided.** `(add_le_add_iff_left p).mpr` drags `Classical.choice` into an
  otherwise choice-free proof (measured). `add_le_add (le_refl p) h` — the idiom `Beh.restrict`
  already uses — does not. Using the wrong one silently destroys the attribution result above.
- **Three shared touches outside the declared `file_scope`**, each required and each a collision
  risk with the concurrently dispatched sibling: `FormalSystem/Semantics/Presheaf.lean` (cluster
  aggregator), `FormalSystem.lean` (root aggregator, gated byte-exact by C33), and
  `FormalSystem/Semantics/README.md`. The cluster README additionally carries a **now-false**
  sentence that must be amended.

## Context & Scope

Researched: how to discharge `app:presheaf-dictionary`'s *Totality* and *Directed Gluing* clauses
as consumers of `thm:extension`, which clauses are choice-free, and what the repository's
convention gates require of a new module in `FormalSystem/Semantics/Presheaf/`.

Constraints taken as given from the dispatch:

- `PartialHistory.lean`, `PartialHistoryOrder.lean` and the `Extension/` cluster are untouched.
  The task consumes `thm:extension`; it does not restate, strengthen or reprove it.
- `lake build FormalSystem` green, no new `sorry`, at the end of every phase.
- The declared `file_scope` is the single module `FormalSystem/Semantics/Presheaf/Directed.lean`.
- The choice-freeness split must be recorded explicitly rather than left implicit in proof terms.

### Paper state of the two clauses

Both are **cut**. `app:Structure` was removed from the paper in full under an explicit
`% SECTION CUT` record and the surviving commented block carries a bare `% CHECK`.
`app:presheaf-dictionary` has a `DANGLING` row at
`docs/reference/paper-definitions-of-record.md:2120`; `scripts/check-paper-definitions.sh --resolve`
structurally cannot pin a commented-out label, so nothing is pinnable. Every citation of it in the
tree must state the cut at the citation site —
`FormalSystem/Semantics/Presheaf/Behavior.lean`'s "Paper state: the source appendix is cut"
paragraph is the form of record to copy. By contrast `thm:extension` and `cor:occurrence` are
**live and pinned** (MANIFEST rows at `:2038` and `:2039`), and `app:gluing` is
**LIVE-UNPINNED** (`:2104`).

The two clauses verbatim from the cut `Tthm` (paper lines 4066-4067):

> *Directed Gluing:* Compatible sections over an upward directed family of subintervals of
> `[0, ℓ]` — any two members lying within a third — extend to a section over `[0, ℓ]` in ZFC,
> uniquely when the family covers `[0, ℓ]`.
>
> *Totality:* Every restriction map `Beh(F)(ℓ) → Beh(F)(ℓ')` is surjective.

And the two proof paragraphs (paper lines 4076, 4078) are, in order: translate the sections to
their subintervals; observe that upward directedness makes any two of them restrict a third, so
their union is a partial history; extend by `thm:extension`; restrict to `[0, ℓ]`. The paper's own
Totality paragraph names its cost — "`thm:extension` rests on *Seriality* and *Saturation* through
`lem:step`" — and its Directed Gluing clause says "in ZFC" exactly where the *Sheaf* clause says
"choice-free". The contrast is the paper's, not this report's.

## Findings

### F1. The translate and the cut, compiled

Two definitions carry the whole geometric content, and both are choice-free.

`place p hm σ : PartialHistory F` translates a section over `m` onto the window `[p, p + m]`:
domain `Interval p (p + m)`, states `t ↦ σ(t - p)`, with `respects_task` discharged by
`sub_sub_sub_cancel_right` because `(t - p) - (s - p) = t - s`. **Measured `[propext, Quot.sound]`.**

`ofWorld h l hl : Beh F l` cuts the section over `[0, l]` out of a possible world: it is
`PartialHistory.restrict h (Interval 0 l) ⟨0, le_refl 0, hl⟩` with its `Beh` property discharged
by `fun _ => Iff.rfl`. **Measured `[propext]`.** That `Iff.rfl` is not luck — it works because
`Beh` carries a pointwise `Iff` against the same predicate `Interval` is built from, which
`Behavior.lean`'s Implementation Notes already flag as load-bearing.

`PartialHistory.timeShift` was **considered and rejected** for the translate. Its domain at `z` is
`τ.domain (z + Δ)`, so placing a section at offset `p` means `Δ = -p` and every subsequent
arithmetic step carries a negation. `place` is written directly against `Interval p (p + m)`
instead, which keeps the domain equations `rfl` and the arithmetic negation-free.

### F2. Totality: the clause, and what it costs

The bridge lemma is `restrict_ofWorld`: if a possible world `h` extends `place p hm σ`, then
`Beh.restrict p m hp hm hfit (ofWorld h l hl) = σ`. Compiled. Its only interesting step is moving
a state across `p + r - p = r` through `PartialHistory.states_eq_of_time_eq`, the same device
`Behavior.lean`'s `restrict_id`/`restrict_comp` already use.

The clause then has one engine and three instantiations, all compiled:

| Declaration | Hypothesis on extension | Measured axioms |
|---|---|---|
| `totality_of_isRestriction` | `∀ τ, PartialHistory.IsRestriction τ` (explicit) | `[propext, Quot.sound]` |
| `totality_clause` | `[F.IsRegular]`, via `isRestriction_of_isRegular` | `[propext, Classical.choice, Quot.sound]` |
| `totality_of_isZTime` | `F.IsZTime` + Compositionality + Seriality + Limit, via `extension_of_isZTime` | not separately measured (inherits the engine plus its instantiating theorem) |
| `totality_of_completion` | Seriality + Limit + `Completion F`, via `extension_of_completion` | not separately measured (as above) |

The engine's conclusion is `Function.Surjective (Beh.restrict p m hp hm hfit : Beh F l → Beh F m)`
— the paper's "every restriction map is surjective", literally. The site-vocabulary form
`totality_clause_site` is one line: `totality_clause F l.property f.shift f.shift_nonneg
l'.property f.shift_add_le` for `f : Tr l' l`. Compiled.

### F3. The directed union, which is the one genuinely new piece of machinery

`thm:extension` consumes a *single* partial history, so Directed Gluing needs the union of the
translates and there is no route around it. `PartialHistoryOrder.lean`'s `chainSup` is the shape
to copy but is **not reusable**: it is stated for `IsChain` and the family here is only
`Directed (· ≤ ·)`. Its proof, however, uses `hc.total` solely to find a comparison, and a
directed family supplies a common upper bound instead — so the generalization is mechanical.

Three declarations, all compiled:

- `directed_states_agree` — two members of a directed family agree wherever both are defined.
  **Measured `[propext]`.**
- `directedSup fam hdir` — domain `fun t => ∃ i, (fam i).domain t`, states via `Classical.choose`,
  `respects_task` routed through a common upper bound of the two chosen witnesses.
  **Measured `[propext, Classical.choice]`.** `noncomputable`, as `chainSup` is.
- `le_directedSup` — every member is below the union.

`Nonempty I` is required, for exactly the reason `chainSup` requires a nonempty chain:
`nonempty_domain` is a field, and the empty family's union has empty domain.

`Directed` needs no extra import — it arrives transitively through `Mathlib.Order.Zorn`, verified
by compilation.

### F4. Directed Gluing: existence, uniqueness, and the paper's own hypothesis form

Existence (`directed_gluing_of_isRestriction`, compiled): take the union of the translates, extend
it to a possible world by the hypothesis, cut over `[0, l]`. Each translate is below the union and
the union below the world, so `restrict_ofWorld` applies at every index. Statement shape:

```
(p m : I → F.Duration) (hp : ∀ i, 0 ≤ p i) (hm : ∀ i, 0 ≤ m i) (hfit : ∀ i, p i + m i ≤ l)
(σ : ∀ i, Beh F (m i)) (hdir : Directed (· ≤ ·) fun i => place (p i) (hm i) (σ i))
⊢ ∃ τ : Beh F l, ∀ i, Beh.restrict (p i) (m i) (hp i) (hm i) (hfit i) τ = σ i
```

`hdir` is the paper's two hypotheses — upward directedness of the subintervals, and compatibility
on overlaps — fused into the single thing the proof consumes. That fusion is the paper's own
inference ("any two of which restrict a third since the family is upward directed"), and it is
discharged in the paper's own vocabulary by `place_le_place` (compiled,
**measured `[propext, Quot.sound]`**): if the `i`-th window sits inside the `k`-th
(`p k ≤ p i`, `p i + m i ≤ p k + m k`) and `σ i` is `σ k` restricted along the inclusion, then
`place (p i) _ (σ i) ≤ place (p k) _ (σ k)`.

Uniqueness under covering (`directed_gluing_unique`, compiled) takes
`hcov : ∀ t, 0 ≤ t → t ≤ l → ∃ i, p i ≤ t ∧ t ≤ p i + m i` and concludes `τ = τ'` from the two
restriction families. The proof is the paper's "sections are functions on points": at each
`t ∈ [0, l]` pick a covering index, read both sections at `t - p i` through a local
`states_eq_of_eq`, and move back across `p i + (r - p i) = r`.

A **dependent-rewrite hazard is recorded**: `rw [h i]` on a goal whose domain witness mentions the
rewritten section fails with "motive is not type correct" (reproduced). The remedy is the
one-line `states_eq_of_eq` lemma `Sheaf.lean:221` already carries (`subst h; rfl`), restated
locally so the new module need not import `Sheaf.lean`.

### F5. The choice record, stated as the measurements make it

All four rows machine-measured in this round.

| Clause / step | Measured axioms | Reading |
|---|---|---|
| *Sheaf* (`sheaf_clause`, landed) | `[propext, Quot.sound]` | choice-free |
| *Totality*, wrapper only (`totality_of_isRestriction`) | `[propext, Quot.sound]` | choice-free |
| `thm:extension` (`PartialHistory.extension`, landed) | `[propext, Classical.choice, Quot.sound]` | Zorn |
| *Totality* at `[F.IsRegular]` | `[propext, Classical.choice, Quot.sound]` | choice **only** via `thm:extension` |
| The directed union (`directedSup`) | `[propext, Classical.choice]` | choice in the union itself |
| *Directed Gluing* at `[F.IsRegular]` | `[propext, Classical.choice, Quot.sound]` | choice from **both** sources |

The engine rows are what make this a record rather than an observation: because the wrapper is
choice-free with the extension property as a hypothesis, the `Classical.choice` in Totality is
*attributable*, not merely *present*. Directed Gluing cannot be given the same clean attribution,
because its union is independently non-constructive.

**Do not import the binary case's choice-freeness into the directed case.** `app:gluing`'s
footnote supplies a counterexample proving *Saturation* is genuinely required for the directed
case — `D = ℚ`, `W = {q ∈ ℚ : q > 0}`, `r ⇒ₓ r'` iff `|r' − r| ≤ x`, where the restrictions of
`τ(t) = 1 − t` to `(0, b]` for `b < 1` form an increasing chain whose union admits no value at
time 1 (verified in
`specs/718_omega_sequence_decidability_full_lplus/reports/01_gluing-route-seed.md` §6). This is a
mathematical obstruction to the clause, not a Lean artifact, and it is the reason the paper writes
"in ZFC" there.

**One measurement trap, and it is live.** `(add_le_add_iff_left p).mpr h`, proving
`p + r ≤ p + m` from `r ≤ m`, **measures `[propext, Classical.choice, Quot.sound]`**. The
choice-free alternatives measured in this round are `add_le_add (le_refl p) h` and
`by rw [add_comm p r, add_comm p m]; exact add_le_add_left h p`. The first is the idiom
`Beh.restrict` already uses in `Behavior.lean`. With the wrong one in place, the engine row above
reads `Classical.choice` and the whole attribution result is silently lost while the build stays
green.

### F6. Layering, namespace and convention gates

- **Imports.** `FormalSystem.Init`, `FormalSystem.Semantics.Presheaf.Behavior`,
  `FormalSystem.Semantics.Extension.Extension`, and — for the two minimal-hypothesis variants —
  `FormalSystem.Semantics.Extension.Completion`. Verified acyclic: nothing in the `Extension/`
  chain (`Constraint → Admissible → Step`, plus `FrameAxioms`, `FrameProperty`,
  `PartialHistoryOrder`) imports anything under `Presheaf/`.
- **`assert_not_exists` still holds.** The whole new import closure was traced and contains no
  `FormalSystem.ProofSystem.*`, so the cluster's closing
  `assert_not_exists FormalSystem.ProofSystem.Axiom FormalSystem.ProofSystem.DerivationTree` can
  be carried unchanged, and the cluster stays provably below `Semantics/Truth.lean`.
- **The cluster README's layering claim becomes false and must be amended.** It currently says the
  cluster "is built on `Semantics/PartialHistory.lean` alone". The new module imports the
  `Extension/` cluster. The sentence that matters more is the next one: "Both clauses are
  choice-free in two measured senses — ... and `#print axioms` reports no `Classical.choice` on
  **any declaration in the cluster**." That is **false** the moment this module lands. `Ray.lean`'s
  own narrower claim ("every one of `Ray.lean`'s declarations measures `[propext]` or
  `[propext, Quot.sound]`") stays true and needs no change.
- **C34a / C34b (`Constraints consumed:` markers).** The `[F.IsRegular]` corollaries
  (`totality_clause`, `totality_clause_site`, `directed_gluing_clause`) take the four-constraint
  list `Compositionality, Seriality, Limit, Saturation`, which C34a rule 1 exempts by
  construction ("the marker omits nothing and so claims nothing"). The binder-free engines take
  `Constraints consumed: None`; `totality_of_completion` takes `Seriality, Limit`;
  `totality_of_isZTime` takes `Compositionality, Seriality, Limit`. None of these is a
  marker-over-a-supplying-binder conjunction, so C34a is green by design rather than by
  allowlist. The engine/corollary split is also exactly C34a's rule-2 delegation pattern.
- **C26** forbids an underscore inside a `def`/`abbrev` name component. `place`, `ofWorld` and
  `directedSup` comply; `directed_sup` would not. Theorem names are unaffected and take the
  repository's snake_case (`sheaf_clause` is the precedent, hence `totality_clause`,
  `directed_gluing_clause`).
- **C15 / C31 (`## References`).** Normal form per `docs/development/REFERENCE_NORMAL_FORM.md`:
  `app:presheaf-dictionary` and `def:behavior-presheaf` cited with their `DANGLING` status stated
  at the site; `thm:extension`, `cor:occurrence` and `app:gluing` cited plainly;
  `[schultz2020]` is the live `references.bib` key (`Behavior.lean` already uses it — do not
  write the paper's `Schultz2020`).
- **Name collisions: none.** A tree-wide grep found no `ofWorld`, `directedSup`, `directedGluing`,
  `place_le_place` or `totality`, and the four `def place…` hits are
  `placedCode`/`placeF`/`placeP`/`placedOfWindow` in unrelated namespaces.
- **Sorry baseline.** No structural `sorry` in `FormalSystem/`; every textual hit is prose.
  `FormalSystem/Metalogic/WeakCanonical.lean:107` records the inventory as ZERO, while
  `MODULE_INVARIANTS.md`'s C3 row still reads "exactly one"; the authoritative value is whatever
  `scripts/check-module-invariants.sh` asserts, and this task adds none on either reading.

### F7. The three shared touches, and the collision exposure

None is in the declared `file_scope`, and all three are required.

1. `FormalSystem/Semantics/Presheaf.lean` — one `import` line plus a `## Modules` bullet. This is
   the aggregator contention the dispatch flags: concurrently dispatched sibling 567
   (`Presheaf/Determinism.lean`) needs the same line, and the collision gate cannot see it.
2. `FormalSystem.lean` — the **root** aggregator. C33 asserts it is byte-for-byte
   `lake exe mk_all --lib FormalSystem` output: one sorted `import` per module, 648 today. The new
   line sorts between `…Presheaf.Behavior` (`:577`) and `…Presheaf.Ray` (`:578`). Omitting it
   fails C33 **and** C24's root-closure walk. This touch is as shared as the first and is easier
   to forget.
3. `FormalSystem/Semantics/README.md:63` — the hand-written `Presheaf/` row. Already stale: it
   says "(2 files)" and names only `Site` and `Behavior`, so tasks 563/564 left it behind. Minimal
   addition only; a rewrite would collide broadly.

Plus the cluster's own `FormalSystem/Semantics/Presheaf/README.md`: the generated inventory block
(regenerate with `bash scripts/check-module-invariants.sh --emit-inventory`, never by hand), the
`Key Definitions` / `Key Results` lists, the two amendments in F6, and a third recorded verdict
carrying F5's table.

Optionally, `docs/reference/paper-definitions-of-record.md:2120` — the `app:presheaf-dictionary`
row's description currently names only *Germs* and *Sheaf* as formalized. Adding *Totality* and
*Directed Gluing* keeps the record true. The row carries no hash (it is `DANGLING`), so editing
the description is safe.

## Decisions

1. **Parameterize on the extension property, instantiate afterwards.** The engines take
   `∀ τ, PartialHistory.IsRestriction τ`; the `[F.IsRegular]`, `Completion` and ℤ-time forms are
   one-line corollaries. Decided because it simultaneously delivers the choice attribution (F5),
   the minimal-hypothesis record, and C34a compliance by delegation (F6).
2. **Write the translate as `place` against `Interval p (p + m)`**, not as
   `PartialHistory.timeShift σ (-p)` — negation-free arithmetic and `rfl` domain equations (F1).
3. **State Directed Gluing's hypothesis as `Directed (· ≤ ·) (place ∘ …)`**, with
   `place_le_place` supplied as the bridge from the paper's two-hypothesis phrasing. Decided
   because that single hypothesis is exactly what the proof consumes, and the bridge keeps the
   clause readable as the paper's (F4).
4. **The directed union lands locally, in the `Presheaf` namespace**, following
   `Behavior.lean`'s `partialHistory_ext` precedent: natural home named, consolidation into
   `PartialHistoryOrder.lean` (beside `chainSup`, which could then be derived from it) recorded as
   a follow-up rather than done. Required by the hard constraint.
5. **No `sorry` is required at any point**, so no deferral arises. Every step is compiled.

## Recommendations

Two phases, each bounded and each ending green.

### Phase 1 — Totality

- Create `FormalSystem/Semantics/Presheaf/Directed.lean`: copyright header, module docstring with
  `## Main Definitions` / `## Main Results` / `## Implementation Notes` / `## References` in the
  cluster's established shape, closing `assert_not_exists`.
- Declarations: `place`, `place_mem`, `ofWorld`, `restrict_ofWorld`, `states_eq_of_eq` (local
  restatement), `totality_of_isRestriction`, `totality_clause`, `totality_clause_site`,
  `totality_of_isZTime`, `totality_of_completion`.
- Use `add_le_add (le_refl p) h`, never `(add_le_add_iff_left p).mpr h` (F5). Use `change`, not
  `show`, where the goal is being restated — `show` trips `linter.style.show` and C28 is budgeted
  per file.
- Both aggregator lines (F7 items 1 and 2), each file re-read immediately before editing per the
  territory contract.
- Verify: `lake build FormalSystem` green via the detached, guarded route
  (`context/project/lean4/operations/long-builds.md`,
  `context/patterns/bounded-build-waiter.md`); `lean_verify` on `totality_of_isRestriction` and
  `totality_clause` reproducing the F5 rows.

### Phase 2 — Directed Gluing, and the record

- `directed_states_agree`, `directedSup` (`noncomputable`), `le_directedSup`, `place_le_place`,
  `directed_gluing_of_isRestriction`, `directed_gluing_unique`, and the `∃!` packaging
  `directed_gluing_clause` under the covering hypothesis.
- The choice record: F5's table in the module docstring, and as a third recorded verdict in
  `FormalSystem/Semantics/Presheaf/README.md` — stating that *Sheaf* is choice-free, that
  Totality's choice is attributable exactly to `thm:extension` because the wrapper is measured
  choice-free, and that Directed Gluing's is doubly sourced and genuinely required by
  `app:gluing`'s ℚ counterexample.
- README amendments (F6): the "built on `PartialHistory.lean` alone" claim, and the false
  cluster-wide no-`Classical.choice` sentence.
- Regenerate the inventory block with `--emit-inventory`; extend `Key Definitions` and
  `Key Results`; minimally extend `FormalSystem/Semantics/README.md:63`.
- Optionally update `docs/reference/paper-definitions-of-record.md:2120`'s description.
- Verify: `lake build FormalSystem` green; `lean_verify` reproducing every F5 row;
  `bash scripts/check-module-invariants.sh` (C8, C15, C24, C26, C31, C32, C33, C34a/b, INV).

### Sequencing note

Do not widen `file_scope` to cover the aggregators — the dispatch is explicit that doing so would
make the collision gate defer this whole front every cycle. Dispatch this task singly or paired at
most with one sibling, and re-run `lake build` after each aggregator edit.

## Risks & Mitigations

| Risk | Mitigation |
|---|---|
| Aggregator edit clobbered by the concurrent sibling (567), invisibly to the collision gate | Re-read `FormalSystem/Semantics/Presheaf.lean` and `FormalSystem.lean` immediately before editing; stage only this task's own hunks; re-run `lake build` after each; if a foreign commit or modification appears, check `git log` and stop and report rather than proceed |
| C33 failure from forgetting the root aggregator | Named explicitly as F7 item 2, with the exact insertion point (between `:577` and `:578`) |
| The `add_le_add_iff_left` trap silently destroying the choice attribution | F5 names the defect and both remedies; phase verification re-measures the engine row with `lean_verify` rather than trusting the build |
| Dependent-rewrite failure in the uniqueness proof | F4 records the reproduced failure and the `states_eq_of_eq` remedy |
| Scope creep into `PartialHistoryOrder.lean` to put `directedSup` "where it belongs" | Decision 4: local, with the consolidation recorded as a follow-up. The hard constraint forbids the edit |
| A README claim left false after landing | F6 names both sentences; phase 2 lists them as deliverables, not as polish |

## Tactic Survey Results

Tactic candidates were exercised through compiled probes rather than through
`lean_multi_attempt`, since every goal here sits inside a construction this round was writing from
scratch and no in-tree proof position existed to attempt against.

| Goal | Tactic / term | Result | Notes |
|---|---|---|---|
| `t - p - (s - p) = t - s` (`place`'s `respects_task`) | `rwa [sub_sub_sub_cancel_right]` | success | exact-name rewrite, no search needed |
| `p + r ≤ p + m` from `r ≤ m` | `(add_le_add_iff_left p).mpr` | success but **rejected** | measures `Classical.choice` |
| same | `add_le_add (le_refl p) h` | success | `[propext, Quot.sound]`; chosen |
| same | `rw [add_comm …]; exact add_le_add_left h p` | success | `[propext, Quot.sound]`; alternative |
| `t - p ≤ m` from `t ≤ p + m` | `sub_le_iff_le_add'.mpr` | success | `[propext, Quot.sound]` |
| `p i - p k + m i ≤ m k` | `calc … by abel / sub_le_sub_right … / by abel` | success | plain `rw [sub_add_eq_sub_sub_swap]` failed — pattern absent |
| `p + (r - p) = r`, `t - pk = pi - pk + (t - pi)` | `abel` | success | `ring` not attempted; `abel` is the right tool over an `AddCommGroup` carrier |
| `restrict … τ = σ i` read at a point | `rw [h i]` | **fail** | "motive is not type correct"; `states_eq_of_eq` used instead |
| whole-goal closers (`simp`, `omega`, `decide`, `aesop`) | — | not attempted | every goal is a dependent-record construction or an equality of dependent `states` projections; `hammer_premise` was not consulted because no proof position existed in the tree yet |

## Context Extension Recommendations

- **Topic**: `Classical.choice` leaking in from Mathlib order lemmas.
- **Gap**: nothing in `context/project/lean4/` warns that an innocuous order-API lemma
  (`add_le_add_iff_left`) carries `Classical.choice` while its sibling (`add_le_add`) does not.
  This repository runs an axiom-measurement gate (C2, C14) and a cluster that advertises
  choice-freedom, so the hazard is live and recurring, and it is invisible to a green build.
- **Recommendation**: add a short note to
  `.claude/context/project/lean4/patterns/` recording the measured pair and the general advice —
  when a declaration's axiom measurement is load-bearing, measure the arithmetic helpers too, and
  prefer `add_le_add`/`le_add_of_nonneg_right`-shaped terms over `*_iff_*` round-trips.

## Appendix

### Probes run (all via `lean_run_code` against the live tree)

1. `place` + `ofWorld` + `restrict_ofWorld` — one error (`add_le_add_left` orientation), then green.
2. `directed_states_agree` + `directedSup` + `le_directedSup` — green, one unused-variable lint
   (bind as `_t`).
3. Existence half of Directed Gluing + a first uniqueness attempt — existence green, uniqueness
   failed on the dependent rewrite.
4. Uniqueness via `states_eq_of_eq` — green.
5. Full Totality stack with `#print axioms` on five declarations.
6. Axiom bisection of the arithmetic helpers (`probeA`–`probeD`, `alt1`–`alt5`), isolating
   `add_le_add_iff_left`.
7. `place_le_place` with `shift_fit` — green.

Plus `lean_verify` on `FormalSystem.Semantics.PartialHistory.extension` and
`FormalSystem.Semantics.Presheaf.sheaf_clause`.

### Paper locations

`/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex` — `app:presheaf-dictionary`
statement at lines 4061-4073, proof at 4075-4090, both commented out; the `% SECTION CUT` manifest
naming the anchors at 3964.

### References

* `FormalSystem/Semantics/Presheaf/Behavior.lean` — `Beh`, `Beh.restrict`, `Beh.restrictTr`,
  `partialHistory_ext`, and the pointwise-`Iff` Implementation Note the new module relies on
* `FormalSystem/Semantics/Presheaf/Sheaf.lean` — `sheaf_clause`, and `states_eq_of_eq`, the
  dependent-witness lemma restated locally
* `FormalSystem/Semantics/Extension/Extension.lean` — `PartialHistory.extension`,
  `isRestriction_of_isRegular`, `exists_restrict_eq`
* `FormalSystem/Semantics/Extension/Completion.lean` — `Completion`, `extension_of_completion`,
  `extension_of_isZTime`
* `FormalSystem/Semantics/PartialHistoryOrder.lean` — the extension preorder, `chain_states_agree`,
  `chainSup`, the shape the directed union generalizes
* `docs/development/MODULE_INVARIANTS.md` — C8, C15, C24, C26, C31, C32, C33, C34a/C34b
* `docs/development/REFERENCE_NORMAL_FORM.md` — the three reference forms and §3's
  constraint-consumption line
* `docs/reference/paper-definitions-of-record.md` — `thm:extension` (`:2038`), `cor:occurrence`
  (`:2039`), `app:gluing` (`:2104`), `app:presheaf-dictionary` (`:2120`),
  `def:behavior-presheaf` (`:2130`), `def:interval-site` (`:2132`)
