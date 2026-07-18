# Phase 2 faithfulness gate — Rabinovich Section 5 cross-check

**Verdict: FAITHFUL. Gate PASSES. No structural drift.** The TL-level decomposition lemma
`efSat ψ ↔ belowHolds(z₀) ∧ bracketHolds(z₀,z₁) ∧ aboveHolds(z₁)` is a faithful TL-encoding-vehicle
restatement of Rabinovich's own Section-5 three-piece chain split `ψ ≡ ψ₀(z₀) ∧ φ(z₀,z₁) ∧ ψ₁(z₁)`,
negated by the disjunction `¬ψ₀ ∨ ¬φ ∨ ¬ψ₁`. Reading done directly from the PDF (pp.4-11); the
`.md`/`.md.bak` transcription is corrupt and was not used.

Source: Rabinovich, *A Proof of Kamp's Theorem* (2014).

## The object being decomposed (PDF p.7, top)

ψ(z₀,z₁) is the ∃∀-formula `∃xₙ…∃x₀[z₀=x_m ∧ z₁=x_k ∧ (x₀<…<xₙ) ∧ ⋀ⱼαⱼ(xⱼ) ∧
⋀ⱼ(∀y)^{<xⱼ}_{>xⱼ₋₁}βⱼ(y) ∧ (∀y)^{<x₀}β₀(y) ∧ (∀y)_{>xₙ}βₙ₊₁(y)]`. Arbitrary pins z₀=x_m, z₁=x_k;
contentful before-cap β₀ and after-cap β_{n+1}. This matches the repo's `efSat` object (before-cap
= 4th conjunct, after-cap = 6th conjunct) up to the encoding vehicle.

## Per-piece correspondence (all confirmed against the PDF)

| Plan piece | Rabinovich object (PDF) | Confirmed |
|-----------|-------------------------|-----------|
| below `α_m ∧ buildLeft(x_{m-1}..x₀, β₀)`, free var at right end x_m=z₀ | ψ₀(z₀), formula (1) p.7: points x₀<…<x_m, carries before-cap β₀ **only**, no after-cap; a one-free-var ∃∀ | YES |
| above `α_k ∧ buildRight(x_{k+1}..x_n, β_{n+1})`, free var at left end x_k=z₁ | ψ₁(z₁), formula (2) p.7: points x_k<…<x_n, carries after-cap β_{n+1} **only**, no before-cap; one-free-var ∃∀ | YES |
| middle `middleBracket`: endpoints α_m,α_k; interior α_{m+1}..α_{k-1}; interval caps β_{m+1}..β_k; **cap-free** | φ(z₀,z₁), formula (3) p.7 = Lemma 5.1 object (eq 5.1): z₀=x_m<…<x_k=z₁, both pins at its own endpoints, **no** β₀/β_{n+1}, only interior interval caps | YES |
| reassembly `VVecEA2.disj` giving `¬ψ₀ ∨ ¬φ ∨ ¬ψ₁` | ¬(ψ₀∧φ∧ψ₁) = ¬ψ₀ ∨ ¬φ ∨ ¬ψ₁ (De Morgan; "sufficient to show the negation of the third formula is a disjunction of ∃∀-formulas", p.7) | YES |

## Cap absorption is content-preserving (the load-bearing check)

The plan's claim — "absorb `efSat`'s before-cap into `buildLeft`'s `H(β₀)` terminal and after-cap
into `buildRight`'s `G(β_{n+1})` terminal" — is exactly Rabinovich's own Prop 3.5 translation (p.5),
not a reinvention:

- In Rabinovich's split the before-cap `(∀y)^{<x₀}β₀(y)` appears **only** in ψ₀ (formula 1), and
  the after-cap `(∀y)_{>xₙ}βₙ₊₁(y)` appears **only** in ψ₁ (formula 2). The caps are not dropped;
  they belong to the below/above pieces respectively. φ is genuinely cap-free.
- Prop 3.5 (p.5) gives, for a one-free-var ∃∀ with the free variable at the **top** endpoint (the
  below piece ψ₀), the pure **Since** chain `A_m ∧ (B_{m-1} Since (A_{m-1} ∧ … (A₁ ∧ (B₁ Since
  (A₀ ∧ ◫B₀)))…))` — the before-cap β₀ realized as the past-box terminal `◫B₀` (= `H(β₀)`). The
  plan's `buildLeft` with terminal `H(β₀)` is precisely this.
- Symmetrically, the free variable at the **bottom** endpoint (the above piece ψ₁) gives the pure
  **Until** chain `A_k ∧ (B_{k+1} Until (A_{k+1} ∧ … (A_n ∧ □B_{n+1}))…)` — the after-cap β_{n+1}
  realized as the future-box terminal `□B_{n+1}` (= `G(β_{n+1})`). The plan's `buildRight` with
  terminal `G(β_{n+1})` matches.

## Middle negation ¬φ (Lemma 5.1, pp.8-11)

φ's negation is Rabinovich's Lemma 5.1 (eq 5.1). His proof is Lemma 5.3 (all βᵢ True; induction on
n; `Oₙ`, `INF` (eq 5.2), `K⁺`), then Cor 5.4 (βₙ True), then the full Lemma 5.1 (three cases;
`INF^{¬β₁}` eq 5.3; `A_i`/`B_i` decomposition, induction on n). The engine used is the repo's
`VVecEA2.negFix_iff` (`EANegationFix/VecEANegFix.lean:177`), gated on `HasAttainedINF`/
`HasAttainedSUP` — the Lean image of Dedekind completeness supplying the inf/sup that `INF`/`K⁺`
require. Faithful; the negation engine is the existing legacy engine, not a new construction.

## Degenerate k=m branch (PDF p.7)

Rabinovich: if k=m then ψ ≡ z₀=z₁ ∧ ψ'(z₀), a single one-free-var piece, and ¬ψ ≡ z₀<z₁ ∨ z₁<z₀ ∨
∃x₀[z₀=x₀ ∧ z₁=x₀ ∧ ¬A'(x₀)]. Matches the plan's `k=m` degenerate branch (no middle bracket, single
one-free-var object). The `wlog m>k` symmetry wrapper mirrors Rabinovich's "w.l.o.g. m<k".

## Drift findings

None structural. One encoding-vehicle note (not a faithfulness drift): the existing Phase-1 module
docstring still carries the v1 framing that the middle φ is negated "via the existing engine
`prop42_veeSat_negation`" through `EndpointPinnedCapTrivial`. Under v2 the SAME Rabinovich object
(Lemma 5.1's cap-free endpoint-pinned middle) is instead negated by `VVecEA2.negFix_iff`. This is a
Lean-engine change, not a change to the Rabinovich object; the docstring is to be updated to the v2
per-piece grounding in Phase 3 (already scheduled). No correction to the planned lemma *shape* is
required — the PDF's decomposition and the planned lemma statement coincide.

## Gate conclusion

The planned decomposition matches Rabinovich Section 5 piece-for-piece (below↔ψ₀ formula (1),
above↔ψ₁ formula (2), middle↔φ formula (3)=Lemma 5.1, reassembly↔¬ψ₀∨¬φ∨¬ψ₁, cap absorption↔Prop
3.5 terminals, degenerate↔k=m branch). Proceed to Phase 3 with the planned lemma statement
unchanged.
