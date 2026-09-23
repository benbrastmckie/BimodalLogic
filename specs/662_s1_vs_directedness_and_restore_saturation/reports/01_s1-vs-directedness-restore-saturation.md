# Research Report: Task #662

**Task**: 662 - Settle whether plain S1 suffices or directedness is forced, search for a better
fourth frame constraint, and otherwise restore Saturation as the def:frame constraint in place of
Completion
**Started**: 2026-09-23T19:31:00Z
**Completed**: 2026-09-23T19:52:00Z
**Effort**: ~20 min research; recommended implementation 3-4 phases (moderate), plus one
explicitly deferred non-goal
**Dependencies**: None blocking. Builds on the machine-checked results of the prior
`Completion` wave (`FormalSystem/Semantics/Extension/Completion.lean`,
`FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean`).
**Sources/Inputs**:
- Codebase: `FormalSystem/Semantics/TaskFrame.lean`, `FormalSystem/Semantics/FrameAxioms.lean`,
  `FormalSystem/Semantics/Extension/{Constraint,Step,Completion}.lean`,
  `FormalSystem/Semantics/StateTopology/{ConstraintWitnesses,MetricFrame}.lean`
- `docs/reference/paper-definitions-of-record.md` (the ball-space footnote of record)
- Prior task artifacts (657 audit, 659 witnesses, 661 separation, 503 representation literature)
- Mathlib search via `lean_local_search` (`IsChain`; absence of spherical-completeness and
  Hölder-embedding API)
**Artifacts**:
- `specs/662_s1_vs_directedness_and_restore_saturation/reports/01_s1-vs-directedness-restore-saturation.md`
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Question 1 is settled negatively in the regime that matters, and the obstruction in the
  remaining regime is identified exactly.** The `⊇`-directedness of `S₁ᵈ` is **not** forced over
  any duration type the development instantiates (`ℤ`, `ℚ`, `ℝ`, and every temporal order of
  countable order-character): over those, the nest condition `S₁` provably suffices for
  `lem:step`. Directedness can only be forced over a temporal order admitting **mismatched
  one-sided cofinal characters** at a point — which requires a non-archimedean `D` whose positive
  cone has uncountable coinitiality (e.g. a Hahn group over `ω₁`). No such witness is cheap, and
  none exists in Mathlib to build on.
- **But "not forced" does not mean "should be dropped", and under this task's own governing
  criterion the verdict flips.** Recommended answer to Question 1: **keep `S₁ᵈ`.** Three
  independent naturalness grounds, detailed in "Question 1" below: (i) `lem:constraint` — the
  paper's own lemma — *produces a `⊇`-directed family*, so `S₁ᵈ` is the exact shape of what the
  development hands the axiom, while `S₁` would require a cofinal-nest extraction step that does
  not exist in the paper; (ii) adopting `S₁` would make `def:frame`'s adequacy depend on a
  **cofinality property of `D`**, a hypothesis `def:frame` currently does not carry and must not
  acquire; (iii) `S₁ᵈ` is not a bespoke strengthening — it is a *named* member of the same
  Ćmiel–Kuhlmann–Kuhlmann hierarchy, and it is the filter-base form ("any consistent shrinking
  system of balls meets"), of which the nest form is the indexing-artifact restriction.
- **A correction to a standing assumption.** Both existing `¬ Saturation` witnesses
  (`SeparatingFrame.straddle`, `RationalTwoOrigins.straddleFamily`) fail **`S₁` as well as
  `S₁ᵈ`**: their straddle families contain a cofinal nest (`[φ n, ν n]` with `φ ↑ √2`, `ν ↓ √2`,
  both sequences already in the tree). So neither witness separates the nest form from the
  directed form, and this is worth landing as a theorem — it is the machine-checked statement
  that the existing sharpness result is about `S₁`, not merely about `S₁ᵈ`.
- **Question 2: nothing better than Saturation is available.** Every candidate assessed fails at
  least one criterion, and three (`TotalComp`, `Triangle`, determinism) were already rejected on
  compiled grounds by the prior audit. Saturation is the only candidate with **two** recognized
  genus memberships carrying transferable theory: ball spaces (`S₁ᵈ`) and modal-algebraic
  compactness (BdRV Def. 5.65 restricted to fibers and segments). One new sharpness fact is worth
  landing: **segments are load-bearing** — a fibers-only `S₁ᵈ` is inadequate, and
  `SeparatingFrame` is very likely the witness.
- **Question 3: yes — restore Saturation, in the `S₁ᵈ` form, exactly as the dispatch's target
  architecture describes.** The reversal is prose, siting and one new derivation lemma; no
  theorem and neither witness is lost. `FrameOver.IsRegular` still carries `saturation` and no
  `completion` (verified: four fields, `TaskFrame.lean:1051,1056,1062,1068`), and
  `TaskFrame.Completion` is used nowhere as a field or instance, so **no proof needs undoing**.
  The reversal surface is measured below: **15 `.lean` prose regions across 5 files, 3 markdown
  regions, 0 ADR sites, 0 manuscript sites, 0 code changes.**

## Context & Scope

Three questions, in dependency order, over the Lean library and in-tree documentation only
(manuscript edits out of scope):

1. Is the `⊇`-directed form `S₁ᵈ` of `def:frame`'s fourth constraint **forced**, or would the
   textbook nest condition `S₁` (spherical completeness) suffice?
2. Under a naturalness criterion that overrides minimality, is there anything **better** than
   Saturation available as `def:frame`'s fourth constraint?
3. If not, restore Saturation and demote Completion.

The governing criterion, restated so the analysis can be checked against it: a frame constraint
must be a property of the structure `⟨W, D, ⇒⟩` *as such*; tight hypotheses belong in theorems,
natural closure conditions belong in definitions; the test is what a condition is **about**, not
what vocabulary it is written in.

Verified rather than trusted, before anything else (all four confirmed):

| Claim | Verification |
|---|---|
| `FrameOver.IsRegular` still carries a `saturation` field | `FormalSystem/Semantics/TaskFrame.lean:1068` — `saturation : TaskFrame.Saturation F.TaskRel`; no `completion` field anywhere |
| `TaskFrame.Completion` is a sibling bare-relation definition | `FormalSystem/Semantics/TaskFrame.lean:755`, in the "frame axioms in bare-relation form" section beside `Saturation:639`, `Serial:654`, `Limit:720` |
| Both witnesses are in `ConstraintWitnesses.lean` | `SeparatingFrame` at `:882`; `RationalTwoOrigins` at `:370` |
| In-tree prose presents the replacement as adopted | `TaskFrame.lean:744-753` — "it is the clause **recommended** as `def:frame`'s fourth constraint in place of *Saturation*" |

So the mathematics is intact and the reversal is positioning, siting and prose — as the dispatch
states.

## Findings

### Codebase Patterns

#### The exact shape of the family `lem:step` feeds to Saturation

This is the whole of Question 1, and the tree answers it precisely.

`PartialHistory.Constraints τ z` (`FormalSystem/Semantics/FrameAxioms.lean:191`) has two clauses:

- **segments** `[τ t, τ s]_{z-t}^{s-z} = Fib(τ t, z-t) ∩ Fib(τ s, z-s)`, for every pair
  `t, s ∈ X` with `t < z < s`;
- **fibers** `Fib(τ t, z-t)`, for every `t ∈ X` that is not *paired* about `z`
  (`IsPaired`, `FrameAxioms.lean:167`).

`IsPaired`'s own docstring records the global collapse (`FrameAxioms.lean:161-165`): if `X` has
times both below and above `z`, **every** `t` is paired and the family is segments only; if `X`
lies entirely on one side, no `t` is paired and the family is fibers only. So there are exactly
two regimes, and they have different index dimensions:

| Regime | Family | Index | Is it a nest? |
|---|---|---|---|
| `X` entirely on one side of `z` | `{Fib(τ t, z-t)}_{t ∈ X}` | the chain `X` | **Yes** — a chain, by Compositionality |
| `X` straddles `z` | `{F(t) ∩ G(s)}_{t ∈ A, s ∈ B}` where `A = X ∩ (-∞,z)`, `B = X ∩ (z,∞)`, `F(t) = Fib(τ t, z-t)`, `G(s) = Fib(τ s, z-s)` | `A × Bᵒᵖ` (product order) | **Not in general** |

`PartialHistory.exists_mem_subset_inter` (`Extension/Constraint.lean:317`) makes the two-dimensional
index explicit and machine-checked: the segment/segment branch refines `(t₁,s₁)` and `(t₂,s₂)` by
**`(max t₁ t₂, min s₁ s₂)`** (`Constraint.lean:322-336`), while the fiber/fiber branch refines by
`max` alone below `z` or `min` alone above (`Constraint.lean:374,388`). That is exactly the
dispatch's unverified sketch, and it is **confirmed**: the segments pairing a below-constraint
with an above-constraint are indexed by a pair and directed by `(max, min)`; the fibers are
indexed by a single time and are totally ordered.

Monotonicity, which the sketch also asserts, likewise holds and is already exploited: by
Compositionality, `t₁ < t₂ < z ⟹ F(t₂) ⊆ F(t₁)` (compose `τ t₁ ⇒_{t₂-t₁} τ t₂` with
`τ t₂ ⇒_{z-t₂} u`), and dually for `G`. `seg_subset_seg` is the tree's packaging of this.

#### The decisive order-theoretic fact

Let `A`, `B` be the two sides. The family of **sets** has a cofinal **nest** whenever the index
poset `A × Bᵒᵖ` has a cofinal **chain**, and then `S₁` suffices: take `u` in every member of the
cofinal nest (a nest of nonempty segments); for arbitrary `(t,s)` pick a nest member below
`F(t) ∩ G(s)`; `u` lies in it, hence in `F(t) ∩ G(s)`; so `u ∈ ⋂₀ Constraints τ z`.

For a product of two linear orders, a cofinal chain exists **iff the two cofinal characters
match**:

- If `A` has a greatest element `t*`, `{F(t*) ∩ G(s)}_{s ∈ B}` is a cofinal chain. Dually if `B`
  has a least element. (This is the paper's own closing remark on `lem:step` — "when the family
  has a `⊆`-least member, that member already contains a candidate" — generalized from a least
  member to a cofinal nest.)
- Otherwise, with `cf(A) = κ` and `coinit(B) = λ` regular: a cofinal chain exists iff `κ = λ`.
  The `κ ≠ λ` half is the standard `ω × ω₁` argument — a chain in the product is increasing in
  both coordinates; its `ω₁`-tail has eventually-constant first coordinate (a non-decreasing
  `ω₁`-sequence into a set of cofinality `ω` is bounded, else its bound at a countable sup would
  be a maximum), so the chain is cofinal only in a single `{t} × B`.

Consequence, and this is the **positive half of Question 1**:

> **Over every temporal order of countable order-character — in particular `ℤ`, `ℚ` and `ℝ` —
> `S₁` + Seriality + Compositionality + Limit implies `lem:step`, hence Completion, hence
> `thm:extension`.** Directedness buys nothing there.

Over `ℤ` it is even more immediate: `HasNearest ℤ` (`Extension/Completion.lean:323`) already gives
the family a `⊆`-least member, so neither `S₁` nor `S₁ᵈ` is used at all
(`extension_of_isZTime`, `:533`).

Consequence, and this is the **negative half**:

> Any frame separating `S₁` from `S₁ᵈ` at `lem:step` must live over a duration type in which
> some `A` below `z` and some `B` above `z` have **different** cofinal characters. In an ordered
> abelian group this forces the positive cone to have uncountable coinitiality — i.e. a
> non-archimedean `D` with an `ω₁`-descending chain of positive elements (a Hahn group
> `⊕_{α<ω₁} ℝ` with lexicographic order is the canonical example). Take
> `A = {z - e_n : n < ω}`, `B = {z + e_α : α < ω₁}`; then `A × Bᵒᵖ ≅ ω × ω₁`, which has no cofinal
> chain.

Even with that `D` in hand, the counterexample needs an actual frame: `P = ⋂_{t∈A} F(t)` and
`Q = ⋂_{s∈B} G(s)` must each be nonempty (forced by `S₁` on the fiber nests), `P ∩ G(b_α)` must be
nonempty for every `α < ω₁` (forced by `S₁` on every chain inside the family), and
`P ∩ Q = ∅`. That configuration is consistent — the `ω₁`-decreasing sequence of nonempty sets
`P ∩ G(b_α)` is **not** a chain of balls, so `S₁` never reaches it — but constructing `W`, `⇒`,
and verifying `S₁` for *all* nests of fibers and segments plus Seriality, Compositionality and
Limit is a research-scale Lean project. See "Risks & Mitigations".

#### Both existing `¬ Saturation` witnesses also refute `S₁`

`SeparatingFrame.straddle` (`ConstraintWitnesses.lean:1104`) is
`{[a,b] : 1 ≤ a, a² < 2 < b², 1 ≤ b ≤ 2}`, realized as `Seg srel (b-1) (a+1) 1 1`
(`mem_sseg:1087`). Its index is `{a} × {b}ᵒᵖ` with both sides of **countable** character —
`cf = coinit = ω` — so by the fact above it has a cofinal nest. The tree already contains both
sequences: `RationalTwoOrigins.nt` (`:655`, `nt_antitone:701`, `nt_sq_gt:692`, `nt_le_start:703`)
descends to `√2` from above, and `phi` (`:727`, `phi_mono:735`, `phi_pos:737`) ascends to it from
below. So `{[φ n, ν n]}_{n}` is a `⊆`-decreasing sequence of nonempty segments with empty
intersection, and hence:

> `¬ TaskFrame.NestSaturation srel` — the separating frame satisfies *Completion* while failing
> **`S₁`**, not merely `S₁ᵈ`.

The same holds for `RationalTwoOrigins.straddleFamily` (`:539`, `not_rel_saturation:565`). This
sharpens the existing separation result and closes off the tempting inference that the existing
witnesses say something about directedness. It is cheap (the analytic content is already proved)
and is the single highest-value new theorem this task can land.

#### Where a field swap would and would not cost

`step` (`Extension/Step.lean:170`) is the **sole elimination** site of Saturation; the other five
`F.saturation` applications are transports (`FrameOver.rev_isRegular`, `FrameOver.map`,
`FrameOver.translationProduct`, `regionFrame_saturation`, `zTaskFrameV2_saturation`), enumerated in
`Step.lean`'s docstring. A swap to `S₁` would leave every one of those five needing an `S₁`
transport instead, and would leave `step` needing a **new hypothesis on `D`** that `def:frame`
does not currently carry. That is the practical form of naturalness ground (ii).

#### Mathlib support

- `IsChain` exists (`Mathlib/Order/Preorder/Chain.lean`) and is the right spelling for a nest:
  `IsChain (· ⊆ ·) S`.
- **Mathlib has no spherical completeness and no ball-space API.** A local search for
  `spherically` returns nothing relevant; `S₁` must be defined in-tree.
- **Mathlib has no Hölder embedding** (`archimedean LinearOrderedAddCommGroup → ℝ`); the only
  hit under `LinearOrderedAddCommGroup.exists…` is `Subgroup.exists_neg_generator`. So the
  sufficiency theorem must **not** be stated with an `Archimedean D` hypothesis — it would
  require proving Hölder first.
- `IsCompact.nonempty_iInter_of_directed_nonempty_isCompact_isClosed` is already wrapped in-tree
  as `TaskFrame.exists_mem_image_of_directedFamily` (`TaskFrame.lean:521`) and its `Set.Icc`
  specialization; the `S₁` analogue needs no new Mathlib.

### External Resources

- **`def:frame`'s ball-space footnote of record** (`docs/reference/paper-definitions-of-record.md:947`,
  verbatim): "The nonempty fibers and segments form a *ball space* on `W` in the sense of Ćmiel,
  Kuhlmann, and Kuhlmann. *Saturation* is the downward-directed-intersection condition `S₁ᵈ` of
  the ball-space hierarchy — the nest condition `S₁` with a `⊇`-directed system of balls in place
  of a nest — and so is at least as strong as the standard *spherically complete* condition,
  which is `S₁` itself."
  Two things follow. First, `S₁ᵈ` is a **named** point of a published hierarchy, not a bespoke
  strengthening: it is inside the recognized genus, not a deviation from it. Second, the paper's
  2026-09 wave **withdrew** the strictness claim ("strictly stronger" → "at least as strong as");
  `TaskFrame.lean:614-617` carries an explicit in-source instruction not to restore it. This
  task's findings do **not** license restoring it either: `S₁ᵈ ⇒ S₁` is asserted, and the strict
  converse remains open exactly as the paper leaves it. Nothing below should be written as
  settling it.
- **Second genus membership** (from the prior representation-literature work): Saturation is, in
  shape, Blackburn–de Rijke–Venema's `compact` condition on a general frame (Definition 5.65) —
  a `⊇`-directed family is exactly a family with witnessed finite intersections — restricted in
  the TM case to fibers and segments rather than all admissible sets, with Proposition 5.83(v)
  proving a Saturation-shaped conclusion for every descriptive general frame. This is a *second*
  body of transferable theory, and no other candidate has one at all.

### Recommendations

#### Question 1: keep `S₁ᵈ`. The directedness is motivated, and `S₁` would cost more than it saves.

The honest mathematical answer is split, so state both halves and let the criterion decide:

- **`S₁` suffices for `lem:step` over every `D` of countable order-character** (`ℤ`, `ℚ`, `ℝ`),
  provably. So the directedness is **not forced** by anything the development instantiates.
- **`S₁` does not suffice in general**, and the obstruction is exact: mismatched one-sided
  cofinal characters, which require a non-archimedean `D` of uncountable coinitiality. This half
  is argued here, not machine-checked; the witness is a research-scale construction.

Under the governing criterion the verdict is nonetheless **keep `S₁ᵈ`**, on three grounds:

1. **`S₁ᵈ` is the exact shape of what the development produces.** `lem:constraint`, the paper's
   own lemma, concludes: "the constraints imposed on `z` form a **directed** family of nonempty
   sets". Directed-family-in, directed-condition-out. Adopting `S₁` would require inserting a
   cofinal-nest-extraction lemma between `lem:constraint` and `lem:step` that has no counterpart
   in the paper and whose only content is an indexing artifact.
2. **`S₁` would import a cofinality hypothesis on `D` into `def:frame`'s adequacy.** `def:frame`
   currently constrains `⟨W, D, ⇒⟩` and nothing else; `thm:extension` holds over every temporal
   order. With `S₁` in the definition, `lem:step` would hold only over temporal orders of matched
   character, so either `def:frame` acquires an order-theoretic side condition on `D` (a property
   of the *index*, not of the structure — precisely the aboutness failure the criterion forbids)
   or `thm:extension` silently narrows. Both are worse than a strengthening that is free.
3. **The nest restriction is the artifact, not the directedness.** A `⊇`-directed family is a
   filter base: "a consistent system of constraints". `S₁ᵈ` says the induced ball geometry has no
   gaps against any consistent shrinking system. `S₁` says it has no gaps against systems that
   happen to be *totally ordered by inclusion* — a condition on how the family is indexed, not on
   the geometry. Under "the test is what a condition is ABOUT", `S₁ᵈ` is the cleaner statement,
   and the tree's own witness families (`straddle`, `Constraints`) are naturally directed and
   only accidentally nest-reducible.

Ground 3 also disposes of the dispatch's own worry ("a strengthening of the textbook notion looks
like a liability unless it is forced"): `S₁ᵈ` is not a strengthening *away from* the textbook
notion, it is another named entry *in the same textbook hierarchy*, and the sufficiency theorem
above is what converts the worry into a recorded **sharpness result** rather than a liability —
exactly the move the dispatch makes for the Completion results.

#### Question 2: nothing better than Saturation is available.

Assessment against the four criteria — (S) statable in `W`, `D`, `⇒` or the relation's own
induced geometry, before `def:world-history`; (G) recognized genus with transferable theory;
(R) robustness beyond this one extension theorem; (M) intuitive motivation not routing through
the theory's own constructions.

| Candidate | S | G | R | M | Verdict |
|---|---|---|---|---|---|
| **Saturation (`S₁ᵈ`)** | yes — `Fib`/`Seg` are `⇒` repackaged as subsets | **two**: ball spaces (`S₁ᵈ`), BdRV compactness (Def. 5.65 / Prop. 5.83(v)) | yes — a condition on the induced ball geometry, indifferent to what consumes it | yes — "the geometry `⇒` induces has no gaps" | **keep** |
| Completion | *nominally* yes; its hypothesis clause **is** `def:world-history`'s clause verbatim, and it forward-references `def:frame` → `def:world-history` | none — sui generis | no — `completion_iff_onePointExtension` makes it provably "the construction `thm:extension` performs succeeds" | no — routes entirely through the theory's own construction | **reject** (dispatch premise, confirmed) |
| Nest form (`S₁`) | yes | yes — same hierarchy | **no** — adequacy depends on `cf`/`coinit` of subsets of `D` | yes, but weaker: gaps only against totally-ordered systems | **reject** (Question 1) |
| Fibers-only `S₁ᵈ` | yes | partial | **no** — inadequate; the straddling regime is segments only | no motivation for excluding segments | **reject** (new; see below) |
| Compactness of the induced state topology | **no** — `StateTopology` is constructed downstream of `def:frame`; same forward-reference sin as Completion, plus it is about a derived object | yes (topology) | — | — | **reject** |
| Mixed-sign composition (`TotalComp`) | yes | — | — | — | **already rejected** on compiled grounds: excludes the drift frame `app:drift` needs |
| `Triangle` | yes | — | — | — | **already rejected**: sufficient but not necessary for `𝒯_F = 𝒩_F` |
| Determinism | yes | yes | — | — | **already rejected**: collapses the independence results |

The one genuinely new finding here is the fourth row, and it is worth landing:

> **Segments are load-bearing.** A fibers-only `S₁ᵈ` cannot replace Saturation, because the
> straddling regime of `Constraints τ z` contains no fibers at all. `SeparatingFrame` is very
> likely the witness: its fibers are `Fib srel w x = [w - |x|, w + |x|]` with `x : ℤ`, so every
> non-degenerate fiber has width `≥ 2` and a directed family of them cannot pinch a Dedekind cut,
> while its *segments* can and do (`not_srel_saturation`). Stated as
> `srel` satisfies fiber-only `S₁ᵈ` and fails full `S₁ᵈ`, this is an inexpensive sharpness
> theorem. **Flagged as plausible, not verified** — the degenerate `x = 0` case (singleton fibers)
> needs checking, and this is an implementation-phase obligation, not a settled result.

#### Question 3: restore Saturation, in the `S₁ᵈ` form, per the dispatch's target architecture.

Target architecture, unchanged from the dispatch except that Question 1 resolves the
parenthetical in favour of `S₁ᵈ`:

- `def:frame` carries **Saturation (`S₁ᵈ`)** as its fourth constraint. **No Lean change is
  required for this**: `FrameOver.IsRegular.saturation` is already the operative field. The work
  is prose.
- `lem:completion` derives *Completion* in the **bare** form immediately before `lem:step` — i.e.
  re-site the existing `completion_of_isRegular` narrative so *Completion* is presented as a
  **derived** condition, not a proposed constraint.
- `thm:extension` takes *Completion* as an explicit hypothesis, recording the minimality where
  minimality belongs. `extension_of_completion` (`Extension/Completion.lean:283`) already
  elaborates with **no `[F.IsRegular]` instance binder** — the machine-checked form of exactly
  that claim. No change needed; only the prose framing.
- A remark records that Saturation is **strictly stronger** than *Completion*, citing
  `SeparatingFrame` (`srel_completion` + `not_srel_saturation`) as the witness, with the
  ball-space footnote attached there. Note the asymmetry carefully: *Saturation strictly stronger
  than Completion* is settled and machine-checked; *`S₁ᵈ` strictly stronger than `S₁`* is **not**,
  and the in-source instruction at `TaskFrame.lean:614-617` forbids asserting it.
- Keep every theorem and both witnesses. They are the sharpness result.

#### Reversal surface — the exact sites Question 3 must re-word

Measured, not estimated. **Zero Lean code changes and zero manuscript changes are required**; the
reversal is prose, plus the new declarations listed in the Appendix.

**`.lean` docstring / prose regions (5 files, 15 regions):**

| File | Lines | What it says |
|---|---|---|
| `Semantics/TaskFrame.lean` | `:273-274` | linter comment: "`TaskFrame.Completion`, the proposed fourth constraint" |
| | `:576-578` | section docstring: "`Completion`, the **proposed replacement** for the fourth of them" |
| | `:723-724` | `def Completion` opening: "`def:frame`'s **proposed** fourth constraint" |
| | `:744-750` | **strongest advocacy in the tree**: "the weakest of the two that `thm:extension` can be run from … the clause **recommended** as `def:frame`'s fourth constraint in place of *Saturation*" |
| | `:752-753` | `Paper:` line: "a proposed replacement for `def:frame`'s fourth constraint" |
| `Semantics/Extension/Completion.lean` | `:14-19`, `:26-30` | module docstring framing *Completion* as the condition `thm:extension` consumes, sited at `def:frame`'s level |
| | `:104-110` | the explicit case for replacement: "**The primitives-level reading favours the bare `TaskFrame.Completion` clause as `def:frame`'s fourth constraint.** … Strictness plus the primitives criterion is the whole case for the replacement." |
| | `:112-125` | **the architecture-target block** — states the target as *pending follow-up*: the manuscript pass (demote *Saturation* to a remark) and the `IsRegular` field swap |
| | `:164-170` | `CoherentCompletion`: "the shape in which the condition is stated inside `def:frame` itself if the replacement option is taken, and the audit's **recommendation is that it should be**" |
| | `:213-215`, `:271` | "*Completion* witness in place of the *Saturation* witness"; "`thm:extension` in full, with *Saturation* replaced by *Completion*" |
| `Semantics/StateTopology/ConstraintWitnesses.lean` | `:67-69`, `:107-116`, `:798-799`, `:997-998` | four regions calling *Completion* "the audit's **proposed replacement** for `def:frame`'s fourth constraint" |
| `Semantics/Extension/Step.lean` | `:58-63`, `:68-75` | "What `step` actually consumes: *Completion*"; "the only thing `def:frame`'s *Saturation* buys the development, it buys through a strictly weaker condition that **could have been assumed instead**" |
| `Semantics/Extension/Extension.lean` | `:241-243` | weaker: "*Completion* may stand in for *Saturation*" |

**Markdown (3 regions):** `docs/theorem-index.md:192` (the one docs advocacy line: "`def:frame`'s
proposed fourth constraint"), plus supporting rows `:187-193, 227-229`;
`FormalSystem/Semantics/Extension/README.md:22-32`;
`FormalSystem/Semantics/StateTopology/README.md:49-56`.

**Zero ADR sites.** Nothing in `docs/architecture/` ever adopted *Completion* — there is no
decision record to reverse, only prose. **Zero manuscript sites**:
`typst/chapters/02-semantics.typ:118-124` still lists *Saturation* as `def:frame`'s fourth item
verbatim, and the `Directed Family` definition a *Completion* adoption would have deleted
(`:112-114`) is still present. **No in-tree site currently states the reversed target
architecture** — that formulation exists only in task-management artifacts, so the reversal is
additive prose as well as corrective.

Two framings must be kept, not reversed, because they are true and machine-checked: *Completion*
is what `step` **actually consumes** (that is the sharpness result), and
`Completion → Saturation` is **false**. What changes is the *modal* register — "proposed fourth
constraint", "recommended in place of", "could have been assumed instead" become "derived
condition", "records the minimality", "is what the axiom buys".

## Literature Proof Structure

Not applicable in the extraction sense — no paper proof is being transcribed. The one literature
object in play is `def:frame`'s ball-space footnote, quoted verbatim under "External Resources"
above, and its placement of Saturation as `S₁ᵈ` in the Ćmiel–Kuhlmann–Kuhlmann hierarchy. The
second genus (BdRV Def. 5.65 / Prop. 5.83(v)) is recorded there too. Neither supplies a proof
structure this task must follow.

## Decisions

- **D1.** Answer Question 1 as **keep `S₁ᵈ`**, and record the split mathematical finding
  (`S₁` suffices over countable-character `D`; the obstruction in general is mismatched cofinal
  characters) as a **sharpness result about a definition worth keeping** — the same reading the
  dispatch applies to the Completion results.
- **D2.** Do **not** attempt the `S₁`-vs-`S₁ᵈ` separating frame in this task. It requires a Hahn
  group over `ω₁` as duration type plus a bespoke `W` and `⇒` with `S₁` verified against *all*
  nests; Mathlib supplies neither spherical completeness nor the ordered-group machinery. Declare
  it an explicit non-goal and record the construction recipe so it is recoverable.
- **D3.** Do **not** state the sufficiency theorem with an `Archimedean D` hypothesis. Mathlib has
  no Hölder embedding, so that route costs a theorem before it starts. Use a directly-stated
  order-character predicate, following the tree's own `NearestAt` / `HasNearest` pattern in
  `Extension/Completion.lean:305,319` — a `CountableCofinal`-style predicate with discharges for
  `ℤ` (via `HasNearest`), countable `D` (covers `ℚ`), and `ℝ`.
- **D4.** Land `¬ NestSaturation srel` (and the `RationalTwoOrigins` analogue if cheap). It is the
  highest-value new theorem available: it corrects a standing assumption at low cost and sharpens
  the existing separation.
- **D5.** Answer Question 2 as **no better candidate**, and land the fibers-only inadequacy
  sharpness fact if it verifies. Do not re-explore `TotalComp`, `Triangle`, determinism, finitary
  or two-point forms of Completion, or dense-time drift separators — all recorded dead ends.
- **D6.** Answer Question 3 as **yes**, with the target architecture above. The reversal touches
  prose, siting and one derivation-lemma presentation; it undoes no mathematics. Scope is
  measured, not estimated: see "Reversal surface". The `Extension/Completion.lean:112-125`
  architecture-target block is the canonical site and must be rewritten first — it is the one
  place that states the *Completion*-adopted target, and every other advocacy site echoes it.
- **D7.** Do **not** restore "strictly stronger" in the ball-space footnote's in-tree rendering.
  The positive half of Question 1 shows `S₁` suffices in the concrete regimes, which if anything
  weakens the case for strictness; and the in-source instruction is explicit.

## Risks & Mitigations

- **Risk: the sufficiency theorem is stated too ambitiously and stalls.** The general
  `S₁ → Saturation` is **false** (uncountable directed families of balls need not reduce to
  nests); only the *targeted* `S₁ → lem:step under a character hypothesis` is true.
  *Mitigation*: state the reduction as a property of `Constraints τ z` (existence of a cofinal
  `⊆`-chain inside it), prove `step` from `S₁` + that property, and discharge the property
  separately per carrier. Never state a frame-level `S₁ → Saturation`.
- **Risk: the `ω × ω₁` argument gets pulled into Lean.** It is the negative half and is not
  needed for any recommendation. *Mitigation*: D2 — keep it as recorded prose in the Saturation
  docstring, as the *reason* directedness is not provably redundant, and do not formalize it.
- **Risk: the fibers-only sharpness claim does not verify.** The `x = 0` singleton-fiber case may
  break the width-`≥ 2` argument. *Mitigation*: it is explicitly flagged as plausible-not-verified;
  the phase that attempts it must be allowed to close as "not established" without blocking D6,
  which does not depend on it.
- **Risk: prose reversal drifts into asserting more than is settled.** Three distinct strength
  relations are in play and only two are settled: `Saturation → Completion` (true, machine-checked),
  `Completion → Saturation` (false, machine-checked), `S₁ᵈ` vs `S₁` (**open**). *Mitigation*: every
  rewritten docstring must keep the third one open, and the existing "do not restore *strictly
  stronger*" instruction must survive the rewrite verbatim.
- **Risk: zero-debt.** Every recommended deliverable has a sorry-free path: `NestSaturation` is a
  definition; `¬ NestSaturation srel` reuses `nt`/`phi`, both fully proved; the cofinal-chain
  reduction is order-theoretic and uses only `IsChain`. Nothing here requires `sorry`, a new
  axiom, or an Option-B deferral. The one item that could not be completed sorry-free — the
  separating frame — is declared a non-goal (D2), not deferred with a placeholder.

## Tactic Survey Results

No tactic survey was performed. No proof obligation was opened during this dispatch: the research
was definition-reading, index-structure analysis and order-theoretic reasoning, with Mathlib
availability checked by `lean_local_search` only. No goal state existed against which
`lean_multi_attempt` or `lean_hammer_premise` could be run, and no `lake build` was needed — the
tree is unmodified.

| Goal | Tactic | Result | Premises/Config |
|------|--------|--------|-----------------|
| — (no proof obligation opened) | — | not applicable | — |

Tactic expectations for the implementation phases, recorded as guidance rather than results: the
`¬ NestSaturation srel` proof is `linarith`/`nlinarith` over `ℚ` in the same register as
`not_srel_saturation` (`ConstraintWitnesses.lean:1125`), and the cofinal-chain construction is a
`Nat.rec`-style recursion with `IsChain` discharged by `monotone_nat_of_le_succ`-shaped lemmas.

## Context Extension Recommendations

- **Topic**: Ball-space conditions (`S₁`, `S₁ᵈ`) and their relation to `def:frame`'s fourth
  constraint.
  **Gap**: `.claude/context/project/lean4/` has no note on this project's ball-space vocabulary,
  and the three distinct strength relations (`Saturation`/`Completion`, `S₁ᵈ`/`S₁`) are easy to
  conflate — the dispatch itself had to spell out which are settled. Every future agent touching
  `def:frame` re-derives the distinction.
  **Recommendation**: add a short domain note recording the three relations, which are settled,
  which is open, and the standing "do not restore *strictly stronger*" instruction with its
  source location.
- **Topic**: Order-character hypotheses on the duration type.
  **Gap**: `HasNearest` already exists as the discrete-time hypothesis pattern
  (`Extension/Completion.lean:319`); a countable-cofinality sibling is about to exist. Nothing
  records the pattern ("state the order property directly; do not route through Mathlib
  structure classes Mathlib does not have, e.g. Hölder").
  **Recommendation**: record the pattern beside the existing Lean context notes so the next
  carrier-dependent hypothesis follows it.

## Appendix

### Search queries and tools used

- `lean_local_search`: `IsChain` (found, `Mathlib/Order/Preorder/Chain.lean`);
  `spherically` (no relevant hits — Mathlib has no ball-space or spherical-completeness API);
  `LinearOrderedAddCommGroup.exists` (only `Subgroup.exists_neg_generator` — no Hölder embedding).
- `lean_leansearch`: attempted for the Hölder embedding; the service returned HTTP 500. Per the
  MCP fallback table, continued with `lean_local_search`, which answered the question negatively
  and sufficed. No finding in this report depends on the failed query.
- Codebase: `grep` over `FormalSystem/**.lean` for `Saturation`, `Completion`, `nest`,
  `spherical`, `Fib`, `Seg`, `DirectedFamily`, `Constraints`, `IsPaired`.
- Prior-artifact survey over `specs/**` and `specs/archive/**` for the Completion/Saturation
  lineage, recorded dead ends, and previously-assessed alternative constraints.

### Key file references

| Object | Location |
|---|---|
| `TaskFrame.Saturation` (`S₁ᵈ`) | `FormalSystem/Semantics/TaskFrame.lean:639` (docstring `:601-638`, ball-space footnote `:607-617`) |
| `TaskFrame.Completion` | `FormalSystem/Semantics/TaskFrame.lean:755` (docstring `:722-753` — the prose to reverse) |
| `TaskFrame.Fib` / `cone` / `Seg` / `DirectedFamily` | `TaskFrame.lean:416` / `:444` / `:466` / `:496` |
| `FrameOver.IsRegular.saturation` | `TaskFrame.lean:1068`; accessor `:1108` |
| `PartialHistory.IsPaired` / `Constraints` | `FormalSystem/Semantics/FrameAxioms.lean:167` / `:191` |
| `exists_mem_subset_inter` (the `(max, min)` directedness) | `FormalSystem/Semantics/Extension/Constraint.lean:317` |
| `constraint` (`lem:constraint`) | `Extension/Constraint.lean:436` |
| `step` (`lem:step`, sole elimination site) | `FormalSystem/Semantics/Extension/Step.lean:170` |
| `completion_of_isRegular` / `extension_of_completion` | `Extension/Completion.lean:265` / `:283` |
| `NearestAt` / `HasNearest` / `hasNearest_int` | `Extension/Completion.lean:305` / `:319` / `:323` |
| `SeparatingFrame.srel` / `srel_completion` / `straddle` / `not_srel_saturation` | `FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean:925` / `:1000` / `:1104` / `:1125` |
| `RationalTwoOrigins.nt` / `phi` / `not_rel_saturation` / `not_rel_completion` | `ConstraintWitnesses.lean:655` / `:727` / `:565` / `:801` |
| Ball-space footnote of record | `docs/reference/paper-definitions-of-record.md:947` |

### Recommended new declarations (for the planner)

```lean
/-- The nest condition `S₁` (spherical completeness), over a bare task relation. -/
def NestSaturation {W : Type} (R : W → D → W → Prop) : Prop :=
  ∀ S : Set (Set W), S.Nonempty → IsChain (· ⊆ ·) S →
    (∀ s ∈ S, (IsFiber R s ∨ IsSegment R s) ∧ s.Nonempty) → (⋂₀ S).Nonempty
```

- `TaskFrame.nestSaturation_of_saturation` — `S₁ᵈ → S₁` (the footnote's asserted implication,
  now machine-checked; a chain is `⊇`-directed).
- `PartialHistory.HasCofinalNest τ z` — `Constraints τ z` contains a nonempty `⊆`-chain that is
  cofinal in it (i.e. refines every member).
- `PartialHistory.step_of_nestSaturation` — `lem:step` from `NestSaturation` plus
  `HasCofinalNest`; then `completion_of_nestSaturation` by the existing
  `completion_of_onePointExtension` route.
- `PartialHistory.hasCofinalNest_of_oneSided` — the fibers-only regime, free (already a chain).
- `PartialHistory.hasCofinalNest_of_hasNearest` — from the existing `HasNearest` (`ℤ`), free.
- `PartialHistory.hasCofinalNest_of_countable` — from `[Countable ↑D]` (covers `ℚ`): a countable
  `⊇`-directed family always has a cofinal chain, by recursion.
- `StateTopology.SeparatingFrame.not_srel_nestSaturation` — **D4**, the headline new theorem;
  reuse `nt`, `phi`, `mem_sseg`, and the Newton step from `not_srel_saturation`.
- Optional, flagged unverified: `SeparatingFrame` satisfies a fibers-only `S₁ᵈ`.

### Explicitly out of scope

- The `S₁`-vs-`S₁ᵈ` separating frame over a Hahn group with `ω₁`-coinitial positive cone (D2).
  Recipe recorded above for recoverability: `D = ⊕_{α<ω₁} ℝ` lexicographic,
  `A = {z - e_n : n < ω}`, `B = {z + e_α : α < ω₁}`, index `≅ ω × ω₁`, and the frame must arrange
  `P ∩ G(b_α) ≠ ∅` for all `α` with `P ∩ Q = ∅`.
- All manuscript edits.
- Re-exploration of `TotalComp`, `Triangle`, determinism, finitary/two-point Completion forms,
  and dense-time drift separators.
