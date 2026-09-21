# Metalogic/ConvexConsequence

The metatheory of **C3** and **C4**, the convex-index consequence relations defined in
[`../../Semantics/ConvexTruth.lean`](../../Semantics/ConvexTruth.lean).

C3 evaluates a sentence at a convex history `τ` and a time in `dom τ`, lets `□` range over the
convex histories through that time, and restricts the tense clauses to `dom τ`. C4 restricts the
index further to closed bounded interval domains. The library's own consequence relation (C1)
is left untouched by everything here.

What C3 is: TM's S5 modal layer over a bounded-interval tense logic. Every TM axiom that fails
under C3 is an existence assertion about the temporal order, and a bounded domain is what makes
an existence assertion fail. No identification of the C3 validities with a known axiomatic
system is claimed in this directory; that is a completeness question.

## Modules

<!-- BEGIN GENERATED: inventory dir=FormalSystem/Metalogic/ConvexConsequence -->
| File | Lines | Description |
|------|------:|-------------|
| `AxiomSurvival.lean` | 398 | One theorem per base-class axiom of TM: C3-valid on every frame (`c3_*`) or refuted on the integer-time frame (`refute_C3_*`). The six failures — both seriality axioms, both discrete-symmetry axioms, forward gap propagation and gap necessity — are all existence assertions about the temporal order |
| `FrameClassSurvival.lean` | 317 | The six frame-class axioms of TM each survive C3 on their own class: `c3_prior_UZ`, `c3_z1` (ℤ-time), `c3_density`, `c3_dense_indicator` (dense), `c3_prior_U_gap` (complete, no density needed), `c3_sep` (ℝ-time, reusing `SoundnessLemmas.sep_order`); class-level corollaries at `ValidC3In`; the endpoint behaviour of `K⁺` |
| `Separations.lean` | 182 | The integer-time fixtures `NF`, `bdd`, `bdd01`, `totalNF`, and the separations: `F⊤` is C1-valid and refuted under C3 and C4; `lastPoint` (`F⊤ → F G⊥`) is C4-valid and refuted under C3, so the containment of C3 in C4 is strict |
<!-- END GENERATED -->
