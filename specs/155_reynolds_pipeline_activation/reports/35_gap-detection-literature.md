# Gap Detection Interval Locality: GHR93 Proof Strategy

## GHR93 Cases III/IV (pp. 118-119)

In the proof of Theorem 6, Cases III and IV handle when `a_n` is a gap definable on the left (III) or right (IV) by some formula `D` of rank ≤ r.

**Case III structure** (p. 118): Given selections `a_0,...,a_n` in `(c', y')_r` with `a_n` a left-D-definable gap, the proof defines:

- `B = X_{a_n}` (the type formula at `a_n`)
- `δ = A ∧ ¬D ∧ U(right(B,D), A)` — a formula of rank ≤ r+3
- `d' = sup{t ∈ (x', y') : N ⊨ ¬D(t)}` — the supremum of ¬D-points above x'
- `g' = sup{t ∈ (x', d') : N ⊨ δ(t)}` — the supremum of δ-points in (x', d')

Then `d, g ∈ M_{r+3}` are defined similarly. The proof uses Lemma 9 to get a gap `e_n` in `(t, d)_r` (an interval of M) at which rank-r formulas match `a_n`.

## The Interval Locality Argument

**Key insight**: GHR93 does NOT use a global gap detection. Instead:

1. The supremum `d' = sup{t ∈ (x', y') : N ⊨ ¬D(t)}` is **interval-restricted** — it's defined within `(x', y')`.
2. The gap `e_n` is found via **Lemma 9** (p. 111), which says: if `m ∈ M_r` and `M_r ⊨ left(A,D)^μ(m)`, then there is a gap `γ` to the LEFT of `m` with (a) `γ > m`, (b) `D` holds in `(m, γ)`, and (c) `M_r ⊨ A^μ(γ)`.
3. Since `d` and `g` are defined as suprema within `[x, y]` (the M-side interval), and `e_n` is found relative to these bounded points, `e_n` is automatically within `[x, y]`.

Specifically: `e_n ∈ (e_{n-1}, t)` where `t` is a point in `[x, y]`, so `e_n` is bounded by points already known to be in `[x, y]`.

## Translation to Lean Formalization

The formalization's `left_formula_gap_detection` corresponds to Lemma 9, but finds a gap **globally** above a reference point — it lacks the interval restriction.

**Fix**: The GHR93 proof constrains the gap's location not by restricting gap detection itself, but by choosing the reference point `m` carefully within `[x, y]` and using the supremum definitions `d, g` (which are bounded by `y`). Since `e_n` is between `m` and the supremum of ¬D-points (which is ≤ y because D holds throughout the interval beyond it), the gap is automatically in `[x, y]`.

**Concrete approach**: Rather than modifying `left_formula_gap_detection`, add a lemma showing: if reference point `m ∈ [x, y]` and formula `D` holds at all points in `(γ, y]` (i.e., `D` defines the gap's right boundary within `[x, y]`), then `γ ≤ y`. This follows because `γ = sup{t : ¬D(t)}` — if `D` holds everywhere above some point below `y`, the supremum is below `y`.

## Key Difference from Formalization

GHR93 defines `d'` and `g'` as explicit suprema, giving structural control over the gap's location. The formalization uses `left_formula_gap_detection` which existentially produces a gap without positional control. The fix is to either (a) add the supremum-based construction, or (b) derive the interval bound from the formula agreement: since `D` characterizes the gap's boundary and the forward game transfers `D`-truth, the gap in M must be bounded by the same `D`-boundary as in N.
