# Semantics/Presheaf

The interval site `Int(D)` and the behavior presheaf `Beh(F)` on it: a task frame's convex
histories, packaged as a presheaf on the durations rather than treated one domain at a time.

The objects of `Int(D)` are the durations — the positive cone of a temporal order — and its
morphisms `l' → l` are the **translations** `Tr p`, one for each offset `p` with `p + l' ≤ l`.
`Beh(F)(l)` is the set of partial histories whose domain is exactly `[0, l]`, and restriction
along `Tr p` is `τ ↦ (z ↦ τ(p + z))`. The cluster is built on `Semantics/PartialHistory.lean`
alone and sits strictly **below** `Semantics/Truth.lean`: all three modules close with
`assert_not_exists` on the proof system, so the layering is locked rather than merely observed.

Two clauses of the presheaf dictionary are discharged here. *Germs* identifies the sections over
the zero duration with the world states (`Beh.germEquiv`), and *Sheaf* glues two sections
agreeing at a seam into a unique section over the joined interval (`sheaf_clause`, and
`sheaf_clause_site` in the site's own vocabulary). The gluing argument itself is not local to this
cluster: it is `PartialHistory.rel_across_seam`, shared with history pasting. Both clauses are
choice-free in two measured senses — they use *Compositionality* alone, taken as an explicit
hypothesis rather than a frame bundle, and `#print axioms` reports no `Classical.choice` on any
declaration in the cluster.

## Modules

<!-- BEGIN GENERATED: inventory dir=FormalSystem/Semantics/Presheaf -->
| File | Lines | Description |
|------|------:|-------------|
| `Behavior.lean` | 296 | The behavior presheaf `Beh F`: the sections over a duration, the restriction action at raw data and at a site morphism, presheaf functoriality, and the *Germs* clause `Beh F 0 ≃ F.WorldState` |
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
- `states_eq_of_eq` — reading a state out of an equality of sections, for either domain witness
- `sheaf_clause_site` — the *Sheaf* clause in the site's own vocabulary, along `coverLeft` and
  `coverRight`. Derived from `sheaf_clause` with no transport and no cast
- `restrictTr_coverLeft`, `restrictTr_coverRight` — restriction along either member of the
  covering family **is** the raw-data restriction the clause is stated with. Both `rfl`, which is
  what makes the site-level clause free
- `compat_iff_match` — the coverage's compatible-family condition, as an equality of germ
  sections in `Beh F 0`, is the raw seam hypothesis

## Dependencies

- **Imports from**: `Semantics/TemporalOrder.lean`, `Semantics/PartialHistory.lean`
- **Imported by**: `Semantics/Presheaf.lean` (the cluster aggregator)

## Related Documentation

- [Semantics README](../README.md)
- [`PartialHistory.lean`](../PartialHistory.lean) — the partial histories the sections are drawn
  from, their convexity predicate, and `PartialHistory.rel_across_seam`, the seam argument the
  gluing clause instantiates
- [`TemporalOrder.lean`](../TemporalOrder.lean) — `PositiveCone`, the objects of the site
- [`docs/reference/paper-definitions-of-record.md`](../../../docs/reference/paper-definitions-of-record.md)
  — where `def:interval-site` and `def:behavior-presheaf` resolve, both `DANGLING`: the paper cut
  the containing appendix `app:Structure` in full, and its surviving commented block carries a
  bare `% CHECK`

---

*Last verified: 2026-10-03*
