# Semantics/Presheaf

The interval site `Int(D)` and the behavior presheaf `Beh(F)` on it: a task frame's convex
histories, packaged as a presheaf on the durations rather than treated one domain at a time.

The objects of `Int(D)` are the durations — the positive cone of a temporal order — and its
morphisms `l' → l` are the **translations** `Tr p`, one for each offset `p` with `p + l' ≤ l`.
`Beh(F)(l)` is the set of partial histories whose domain is exactly `[0, l]`, and restriction
along `Tr p` is `τ ↦ (z ↦ τ(p + z))`. Four of the six modules are built on
`Semantics/PartialHistory.lean` alone; `Presheaf/Directed.lean` additionally imports the
`Semantics/Extension/` cluster, because the two clauses it discharges are wrappers on
`thm:extension`, and `Presheaf/Determinism.lean` additionally imports
`Semantics/FrameProperty.lean` for `TaskFrame.Deterministic` alone. The cluster sits strictly
**below** `Semantics/Truth.lean` regardless: all six modules close with `assert_not_exists` on the
proof system, so the layering is locked rather than merely observed.

Four clauses of the presheaf dictionary are discharged here. *Germs* identifies the sections over
the zero duration with the world states (`Beh.germEquiv`), and *Sheaf* glues two sections
agreeing at a seam into a unique section over the joined interval (`sheaf_clause`, and
`sheaf_clause_site` in the site's own vocabulary). The gluing argument itself is not local to this
cluster: it is `PartialHistory.rel_across_seam`, shared with history pasting. *Totality* makes
every restriction map surjective (`totality_clause`, `totality_clause_site`) and *Directed Gluing*
extends a directed compatible family to the whole interval (`directed_gluing_clause`); both are
wrappers on `thm:extension`, and `Presheaf/Directed.lean` is where that is made visible.

*Germs* and *Sheaf* are choice-free in two measured senses — they use *Compositionality* alone,
taken as an explicit hypothesis rather than a frame bundle, and `#print axioms` reports no
`Classical.choice` on either. **That is no longer a cluster-wide claim**, and it was one before
`Presheaf/Directed.lean` landed: `totality_clause`, `directedSup` and `directed_gluing_clause` all
measure `Classical.choice`. The split, and what each clause's choice is attributable to, is the
third recorded verdict below.

`Presheaf/Ray.lean` adds the **ray layer**, the half-line counterpart of the bounded sections. A
section `Beh F l` has domain exactly `[0, l]`; a possible world does not, and what a seam-local
construction quantifies over is the pair of rays at a seam time — `(-∞, t]` backward and
`[t, ∞)` forward. Those are `PastRay F t` and `FutRay F t`, presented as dependent functions on
the time subtypes so that ray equality is `funext`, with `toPH` reading the same ray as a
`PartialHistory` on a half-line domain and `FutRay.toBeh` cutting a bounded section out of a
forward ray. No new structure is introduced for either: `PartialHistory`'s `domain` field is an
arbitrary predicate, so a half-line is already expressible. The colimit-of-bounded-sections
presentation of a ray is deliberately not taken, because it is the route that incurs *Saturation*.

One asymmetry with the two clauses above is worth stating rather than leaving to be noticed. The
*Germs* and *Sheaf* declarations take *Compositionality* as an **explicit hypothesis**; the ray
layer's gluing operator and keystone instead carry the bracketed `[F.IsRegular]` bundle, which
supplies more than they consume. That is deliberate and not an oversight: the keystone is a
promoted probe result and its statements are kept hypothesis for hypothesis, so a reader checking
them against the probe finds them unchanged. The binder-free form of the content they actually
use is `PartialHistory.rel_across_seam`'s own signature, which the seam step delegates to. The
second measured sense of choice-freedom is unaffected and holds across the whole cluster: every
one of `Ray.lean`'s declarations measures `[propext]` or `[propext, Quot.sound]`.

## Modules

<!-- BEGIN GENERATED: inventory dir=FormalSystem/Semantics/Presheaf -->
| File | Lines | Description |
|------|------:|-------------|
| `Behavior.lean` | 296 | The behavior presheaf `Beh F`: the sections over a duration, the restriction action at raw data and at a site morphism, presheaf functoriality, and the *Germs* clause `Beh F 0 ≃ F.WorldState` |
| `Determinism.lean` | 187 | The *Determinism* clause below the layering lock: `Separated` as injectivity of every restriction map, the choice-free (⇒) half, the world-to-section bridge `secOf`, and the converse's frame-side conclusion with `SingletonClasses` unfolded |
| `Directed.lean` | 515 | The *Totality* and *Directed Gluing* clauses as wrappers on `thm:extension`: the translate `place`, the cut `ofWorld`, the directed union `directedSup`, both clauses in binder-free engine form with their instantiations, and the choice record |
| `Ray.lean` | 438 | The ray layer: the half-line sections `PastRay`/`FutRay` at a seam, their seam projections and bridges, and the ray-layer gluing operator with its reading equations, restriction identities, uniqueness and totality |
| `Sheaf.lean` | 434 | <!-- TODO: add description --> |
| `Site.lean` | 191 | The interval site `Int(D)`: the translations `Tr p`, the three category laws, and the Johnstone coverage |
<!-- END GENERATED -->

## Key Definitions

- `Obj D`, `Tr l' l` — the objects and morphisms of the interval site `Int(D)`
- `Tr.id`, `Tr.comp` — the identity `Tr 0` and composition, which adds offsets
- `coverLeft`, `coverRight` — the two members of the Johnstone covering family of `l` at a cut
  point `p ≤ l`
- `Beh F l` — the sections of the behavior presheaf over `l`: the partial histories whose domain
  is exactly `[0, l]`
- `Beh.restrict`, `Beh.restrictTr` — the presheaf action, at raw data and indexed by a morphism of
  the site
- `Beh.germ`, `Beh.ofGerm`, `Beh.germEquiv` — a section over `0` and its single world state, and
  the bijection between them
- `glue` — the glued section: `τ₁` over `p` and `τ₂` over `l - p`, agreeing at the seam, read as
  one section over `l`
- `PastRay F t`, `FutRay F t` — the ray layer: the half-line sections at a seam time `t`, as
  dependent functions on the time subtypes `{x // x ≤ t}` and `{x // t ≤ x}` carrying the
  unconditional all-pairs task constraint
- `PastRay.seam`, `FutRay.seam` — a ray's state at the seam: the right endpoint of a past ray, the
  left endpoint of a future ray
- `pastOf`, `futOf` — the two restrictions of a possible world to its rays at a time
- `PastRay.toPH`, `FutRay.toPH` — the same rays read as `PartialHistory F` on a half-line domain,
  the form that reaches the shared `PartialHistory` API
- `FutRay.toBeh` — the ray-layer-to-`Beh` restriction: a forward ray at `0` cut down to the
  bounded section over `l`
- `StabFibre F t s`, `RayPair F t s` — the `⊡` quantification domain at `(t, s)`, and the fibre
  product of the past-ray and future-ray spaces over the seam state
- `Separated F` — separatedness of `Beh F`: every restriction map is injective. At `l' = 0` this
  is injectivity of the germ maps, the form every consumer uses
- `secOf` — the world-to-section bridge: a possible world cut down to the section over `[0, l]`
  based at a time `m`, through which the `Beh`-level clause meets the total-history statement
  `PlusLanguage.states_eq_of_deterministic`
- `place` — the translate: a section over `m` placed at offset `p`, as a partial history with
  domain `Interval p (p + m)`. Written against the interval rather than through
  `PartialHistory.timeShift`, which keeps the arithmetic negation-free
- `ofWorld` — the cut: a possible world restricted to `[0, l]`, as a section of `Beh F l`. Its
  section condition is `fun _ => Iff.rfl`, which is what `Beh`'s pointwise-`Iff` design buys
- `directedSup` — the union of a **directed** family of partial histories, `noncomputable` as
  `PartialHistory.chainSup` is. The one piece of genuinely new machinery either new clause needs,
  since `thm:extension` consumes a single history. Its natural home is beside `chainSup` in
  `Semantics/PartialHistoryOrder.lean`, from which `chainSup` could then be derived; that
  consolidation is recorded as a follow-up in `Presheaf/Directed.lean`'s Implementation Notes

## Key Results

- `Tr.id_comp`, `Tr.comp_id`, `Tr.comp_assoc` — the three category laws of `Int(D)`
- `Tr.le_of_hom` — a morphism `l' → l` witnesses `l' ≤ l`
- `cover_germ_composites` — the two covering morphisms have equal composite shift with the germ,
  which is what makes the sheaf condition on this coverage a two-section gluing statement
- `Beh.restrict_id`, `Beh.restrict_comp` — presheaf functoriality at raw data
- `Beh.restrictTr_id`, `Beh.restrictTr_comp` — the same at the site, where the contravariance is
  visible: `restrictTr (Tr.comp f g) = restrictTr g ∘ restrictTr f`
- `Beh.germ_ofGerm`, `Beh.ofGerm_germ` — the two round trips of `Beh.germEquiv`, the *Germs*
  clause. The only results here that reach a frame constraint, through `[F.IsRegular]`
- `Beh.isConvex`, `Beh.domain_eq_interval` — a section is convex, and its domain is `Interval 0 l`
- `partialHistory_ext` — extensionality for partial histories, written by hand because the
  `states` field is dependent on `domain` and no `@[ext]` lemma is generated
- `sheaf_clause` — the *Sheaf* clause: two sections agreeing at the seam glue to a **unique**
  section over the joined interval, stated in cut form as an `∃!`
- `restrict_glue_left`, `restrict_glue_right` — the two restriction identities of `glue`. The
  right one is where the seam hypothesis is consumed, because the branch test is true at the
  right interval's own origin
- `glue_states_le`, `glue_states_not_le` — the two reading equations of `glue`, one per branch of
  its dependent `if`; every proof about `glue` goes through these rather than unfolding it
- `glue_unique` — any section restricting to `τ₁` and `τ₂` is `glue`
- `Ray.seamGlue` — the ray-layer gluing operator: a past ray and a future ray agreeing at the seam,
  read as one possible world. The paper's own seam operator in the case its pasting passage
  applies it in, with `PlusLanguage.PlusPasting.paste` as its total-history instance
- `Ray.seamGlue_states_le`, `Ray.seamGlue_states_not_le` — the two reading equations of
  `Ray.seamGlue`, one per branch of its dependent `if`
- `Ray.seamGlue_rel_le_lt`, `Ray.seamGlue_rel` — task-respect for the glued state function; the
  seam step is delegated to `PartialHistory.rel_across_seam`, and the mixed-orientation case
  goes through the off-zero `TaskFrame.reflection_of_ne`, which is what keeps the whole
  ray-layer path clear of `Classical.choice`
- `Ray.pastOf_seamGlue`, `Ray.futOf_seamGlue` — the two restriction identities of
  `Ray.seamGlue`. The second is where the seam hypothesis is consumed, the branch test being
  true at the seam point itself
- `Ray.seamGlue_unique`, `Ray.seamGlue_clause` — uniqueness, and the `∃!` the restriction identities
  and uniqueness package
- `Ray.seamGlue_isTotal` — totality: the glued object is total on all of `F.Duration`
- `seamFibreEquiv` — **the keystone**: the `⊡` fibre over a seam state **is** the fibre product
  of the past-ray and future-ray spaces over that state. Forward: restrict. Backward: glue. The
  two round trips are `WorldHistory.ext_state` and funext, at any duration, and the whole path
  measures `[propext, Quot.sound]`. Its `⊡`-clause readings — over ray pairs and over pairs of
  ω-indexed step sequences — are `PlusLanguage/PlusRayFibre.lean`'s, which sits above
  `Semantics/Truth.lean` and so cannot live in this cluster
- `states_eq_of_eq` — reading a state out of an equality of sections, for either domain witness
- `sheaf_clause_site` — the *Sheaf* clause in the site's own vocabulary, along `coverLeft` and
  `coverRight`. Derived from `sheaf_clause` with no transport and no cast
- `restrictTr_coverLeft`, `restrictTr_coverRight` — restriction along either member of the
  covering family **is** the raw-data restriction the clause is stated with. Both `rfl`, which is
  what makes the site-level clause free
- `compat_iff_match` — the coverage's compatible-family condition, as an equality of germ
  sections in `Beh F 0`, is the raw seam hypothesis
- `separated_of_deterministic` — the (⇒) half of the *Determinism* clause: a deterministic frame
  has separated behavior. Choice-free (`[propext, Quot.sound]`), and it consumes only the germ at
  the offset
- `states_eq_of_deterministic_sec` — the section-level singleton bridge, `[propext]`: the
  `Beh`-layer counterpart of `PlusLanguage.states_eq_of_deterministic` by the same three-step
  proof, not an instance of it
- `states_eq_of_separated` — the (⇐) half's frame-side conclusion with `TaskFrame.SingletonClasses`
  unfolded, because that name sits above this cluster's lock. The biconditional itself is
  `Semantics/DeterministicBridge.lean`'s `deterministic_iff_separated`
- `restrict_ofWorld` — the bridge both new clauses share: if a possible world extends
  `place p hm σ`, restricting its cut over `[0, l]` along the translation by `p` returns `σ`
- `totality_of_isRestriction` — the *Totality* clause's **engine**: every restriction map of the
  behavior presheaf is surjective, with the extension property taken as an explicit hypothesis and
  therefore no frame constraint at all. Measures `[propext, Quot.sound]`, which is what makes the
  choice in `totality_clause` attributable rather than merely co-present
- `totality_clause`, `totality_clause_site` — the *Totality* clause at `[F.IsRegular]`, at raw
  offsets and along a site morphism `f : Tr l' l`
- `totality_of_isZTime`, `totality_of_completion` — the two **Saturation-free** forms, over
  discrete ℤ-time and at bare *Completion*. Saturation-free is not choice-free: both still route
  through Zorn
- `directed_states_agree` — two members of a directed family agree wherever both are defined; the
  directed analogue of `PartialHistory.chain_states_agree`, with a common upper bound in place of
  `IsChain.total`
- `le_directedSup` — every member of a directed family is below its union
- `place_le_place` — the paper's "any two restrict a third" bridge, from its two hypotheses
  (directedness of the windows, compatibility on overlaps) to the single `Directed (· ≤ ·)` the
  gluing proof consumes
- `directed_gluing_of_isRestriction` — the *Directed Gluing* clause's existence half in engine
  form: union the translates, extend, cut. Unlike *Totality*'s engine this one **still** measures
  `Classical.choice`, because `directedSup` is independently non-constructive
- `directed_gluing_unique` — the uniqueness half, under a covering hypothesis. Needs neither
  directedness nor any frame constraint; sections are functions on points
- `directed_gluing_clause` — the *Directed Gluing* clause itself, as the `∃!` the two halves
  package

## Recorded verdicts

### The ray gluing stands in for a Zorn argument without subsuming the Extension Theorem

`Ray.seamGlue` produces a **total** world history from a pair of agreeing half-line rays, with no
Zorn argument and no choice: `Ray.seamGlue`, its two reading equations, its two restriction
identities, `Ray.seamGlue_unique`, `Ray.seamGlue_clause` and `Ray.seamGlue_isTotal` all measure
`[propext, Quot.sound]`.

The **positive** half of the verdict. That is the role the bi-lasso Tier A effective extension
theorem plays — `Metalogic/Decidability/BiLasso/Orbit.lean`'s `IntPresentation.extend_periodic`
and `IntPresentation.extend_periodic_of_icc`, whose *no Zorn* property `BiLasso/Agreement.lean`
exists in part to preserve — an effective total-history construction standing in for a Zorn
argument. `Ray.seamGlue` supplies such a construction for **every** pair of agreeing half-line
rays at a regular frame, not only for the bi-lasso case the orbit construction was built for.

The two properties are distinct, and the bi-lasso modules distinguish them explicitly:
`BiLasso/Agreement.lean` preserves the paper's "without appeal to Zorn's lemma" *exactly and only
as **no Zorn***, and records that it is **not** preserved as choice-freedom in Lean's sense —
`IntPresentation.extend_periodic` itself measures `Classical.choice`, for a reason internal to the
decoding module. The ray gluing has both properties at once: no Zorn, **and**
`[propext, Quot.sound]`.

The **limit**, stated as the verdict's other half and not as full subsumption. The general
Extension Theorem (`Semantics/Extension/Extension.lean`'s `extension`, routed through
`Semantics/PartialHistoryOrder.lean`'s `PartialHistory.exists_maximal_extension`, which is Zorn's
lemma over the extension order) handles a strictly wider class of inputs, and it is not
displaced. The gap is precisely locatable. A pair of half-line rays at `t` has two properties that
an arbitrary partial history does not: its domain **covers** all of `F.Duration`, and the two
halves **meet in exactly one point**. `Ray.seamGlueFun`'s total case split on `s ≤ t` is available
only because of those two facts. A `PartialHistory`'s `domain` is an arbitrary predicate on
`F.Duration` — neither total nor convex nor meeting any other domain in one point — so there is no
analogue of that case split there, and the maximal-extension route remains the only general one.
Deliverable 4 therefore closes **affirmatively with an explicit gap statement**, not by reasoned
exclusion.

### The choice record splits, and the split is the honest form

The ray layer is choice-free, as measured above. The ℤ/ω presentation in
`PlusLanguage/PlusRayFibre.lean` is **not**: `seamOmegaEquiv` and `plusStab_iff_omega` measure
`Classical.choice`, and the cause is upstream and named — `FrameOver.worldHistoryOfStepPath`,
reached through `pathFibreEquiv` to build a possible world out of a bare bi-infinite step path.
Rerouting that declaration is out of scope here: it is a core `Semantics/IntNormalForm.lean`
declaration with consumers on several independent fronts. A uniform claim in either direction
would be false; the split is the record.

### The dictionary's four clauses split on choice, and the split is attributable

The two clauses `Presheaf/Directed.lean` discharges are **wrappers** on `thm:extension`, and
stating them as a binder-free engine plus instantiations is what turns the choice measurement from
an observation into an attribution. Every row below was measured with `lean_verify` or
`#print axioms`; the module's own docstring carries the same table.

| Declaration | Measured axioms |
|---|---|
| `sheaf_clause` (binary *Sheaf*) | `[propext, Quot.sound]` |
| `ofWorld`, `directed_states_agree` | `[propext]` |
| `place`, `place_le_place`, `restrict_ofWorld` | `[propext, Quot.sound]` |
| `totality_of_isRestriction` (engine) | `[propext, Quot.sound]` |
| `PartialHistory.extension` | `[propext, Classical.choice, Quot.sound]` |
| `totality_clause`, `totality_clause_site` | `[propext, Classical.choice, Quot.sound]` |
| `totality_of_isZTime`, `totality_of_completion` | `[propext, Classical.choice, Quot.sound]` |
| `directedSup`, `le_directedSup` | `[propext, Classical.choice]` |
| `directed_gluing_unique` | `[propext, Quot.sound]` |
| `directed_gluing_of_isRestriction` (engine) | `[propext, Classical.choice, Quot.sound]` |
| `directed_gluing_clause` | `[propext, Classical.choice, Quot.sound]` |

Reading the four values: `[propext]` and `[propext, Quot.sound]` are **choice-free**;
`[propext, Classical.choice]` is the directed union's own non-constructivity; and
`[propext, Classical.choice, Quot.sound]` is everything that reaches Zorn's lemma, directly or
through the union.

*Totality*'s engine is measured choice-free *with the extension property as an explicit
hypothesis*, so the `Classical.choice` in `totality_clause` is **attributable** — exactly to
`thm:extension` and to nothing in the geometry of translating and cutting. *Directed Gluing* admits
no such attribution, and the contrast between the two engine rows is the evidence:
`directed_gluing_of_isRestriction` measures `Classical.choice` *even with the extension property
hypothesized away*, because the directed union `directedSup` is independently non-constructive.
Its choice is **doubly** sourced.

The non-constructivity of the directed case is a mathematical obstruction, not a Lean artifact.
`app:gluing`'s footnote supplies a counterexample proving *Saturation* is genuinely required there:
over `D = ℚ` with `W = {q ∈ ℚ : q > 0}` and `r ⇒ₓ r'` iff `|r' − r| ≤ x`, the restrictions of
`τ(t) = 1 − t` to `(0, b]` for `b < 1` form an increasing chain whose union admits no value at time
`1`. This is why the paper writes "in ZFC" at *Directed Gluing* and "choice-free" at *Sheaf*, and
why the binary case's choice-freeness **must not** be imported into the directed case.

`totality_of_isZTime` and `totality_of_completion` are **Saturation-free** — a statement about
`def:frame`'s fourth constraint, not a claim of choice-freedom. Both still route through Zorn's
lemma and both measure `[propext, Classical.choice, Quot.sound]`.

### What a decidable stability check on the path-space presentation requires

`plusStab_iff_rays` and `plusStab_iff_omega` present `⊡` as a quantifier over a **product of two
path spaces**, one factor running backward from the seam and one forward. Three things follow
about any device that would summarise that quantification finitely, and they are stated here as a
**requirement** and not as a design: nothing below is built, selected or funded by this cluster.

- The device must be **universal over both factors**, hence complementation-shaped. A
  nondeterministic per-path summary does not supply it, and the divergence is elementary and
  finite rather than automata-theoretic: on a total, hence genuinely branching, step graph on
  `Bool`, `Probe718PathQuantifier.exists_ne_stab` and
  `Probe718PathQuantifier.exists_ne_universal` show the existential per-path summary to be `True`
  everywhere while the real value of the stability-of-eventually formula is `False` everywhere
  (`Probe718PathQuantifier.decide_will`).
- Its **backward** factor must be summarised on its own terms rather than obtained by
  time-reversing the forward one. The forward finite-graph summary
  (`Probe718FiniteGraph.will_iff_allPathsMeet`, `Probe718FiniteGraph.decide_will`) is proved on a
  fixture whose relation is symmetric under time reversal, and the finite-width obstruction lives
  in the backward factor, so that fixture cannot see it. `Probe719Backward` supplies the backward
  dual on a time-asymmetric fixture and records its own limit: that fixture is backward
  *deterministic*, so its backward factor is a singleton.
- **No complexity claim is committed here.** The CTL\* 2EXPTIME lower bound is the sanity check
  on any bound a future device might carry; this cluster asserts none.

Which candidate device supplies the requirement is settled nowhere and is **not** asserted here —
not determinization, not a Safraless procedure, not an MSO-over-ℤ route, not a Ramsey-coloured
summary.

The path-category reading of the forward structure — the identification of `Path(F)` as the free
category on the one-step graph when the duration is ℤ, which would be the "root paths of a finite
class graph" presentation a decidable check is usually stated over — is likewise **not landed**.
No free-category presentation of `Path(F)` exists anywhere under `FormalSystem/`, and the paper's
own labels for it sit in the appendix block that
`docs/reference/paper-definitions-of-record.md` records as *deliberately not pinned*; they are
deliberately not named here either, since naming them is what would make them load-bearing and
widen that record's maintenance surface for a region the tree does not depend on. The
free-category reading must never be cited as landed.

### This presentation bounds nothing

`PlusSlicedCertificate.NoFiniteWidth.not_finite_width_fmp` stands exactly as proved. The
ray-product presentation is the **mechanism behind** that refutation rather than an escape from
it: a product of two path spaces cannot be a finite fibre. No width, tail-period or complexity
bound is committed anywhere in this cluster, and soundness is untouched.

## Dependencies

- **Imports from**: `Semantics/TemporalOrder.lean`, `Semantics/PartialHistory.lean`, and —
  `Presheaf/Directed.lean` only — `Semantics/Extension/Extension.lean` and
  `Semantics/Extension/Completion.lean`
- **Imported by**: `Semantics/Presheaf.lean` (the cluster aggregator), and
  `PlusLanguage/PlusRayFibre.lean`, which imports `Presheaf/Ray.lean` directly to read the `⊡`
  clause through `seamFibreEquiv`

## Related Documentation

- [Semantics README](../README.md)
- [`PartialHistory.lean`](../PartialHistory.lean) — the partial histories the sections are drawn
  from, their convexity predicate, and `PartialHistory.rel_across_seam`, the seam argument the
  gluing clause instantiates
- [`TemporalOrder.lean`](../TemporalOrder.lean) — `PositiveCone`, the objects of the site
- [`PlusLanguage/PlusRayFibre.lean`](../../PlusLanguage/PlusRayFibre.lean) — the `⊡`-clause
  readings of `seamFibreEquiv`, over ray pairs and over pairs of ω-indexed step sequences. It
  sits above `Semantics/Truth.lean` and so cannot live in this cluster
- [`docs/reference/paper-definitions-of-record.md`](../../../docs/reference/paper-definitions-of-record.md)
  — where `def:interval-site` and `def:behavior-presheaf` resolve, both `DANGLING`: the paper cut
  the containing appendix `app:Structure` in full, and its surviving commented block carries a
  bare `% CHECK`

---

*Last verified: 2026-10-03*
