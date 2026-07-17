# Phase 4 unblock — concrete construction plan for the Phase-3-object conjunction/negation stack

**Task 379, research dispatch (read-and-plan only; no `Theories/` edits).** The Phase 7 blocker is
CONFIRMED upstream and not re-litigated here: Prop 4.3's negation case feeds arbitrary-pin,
non-trivial-cap `ExistsForallFormula … 2` objects (`pairProject` output) to a negation engine
(`prop42_veeSat_negation`) that only accepts `EndpointPinnedCapTrivial` inputs. This report is the
actionable build plan an implementer transcribes.

## Grounding: what exists vs. what is missing

**Object under induction** — `ExistsForallFormula sig F r`
(`ExistsForallFormula.lean:81-90`): fields `n : Nat`, `pin : Fin r → Fin (n+1)`,
`pointType : Fin (n+1) → UnaryType`, `intervalType : Fin (n+2) → UnaryType`. Satisfaction
`efSat` (`:100-127`) = ∃ strictly-monotone `x : Fin (n+1) → carrier` with pins, point types, and
before/between/after interval types.

**Present foundations (reuse):**
- `VeeExistsForall = List (ExistsForallFormula …)`, `veeSat` = "some disjunct holds"
  (`VeeExistsForall.lean:35-43`); `veeSat_append` disjunction closure (`:69`).
- `ConjExistsForall = List (Fin r × Fin r × ExistsForallFormula … 2)`, `conjSat` = "every tagged
  conjunct holds on `![env k, env l]`" (`ExistsForallLemmas.lean:74-84`); `conjSat_nil/cons/append`
  (`:90-`).
- `pairProject ψ k l` (`ExistsForallLemmas.lean:129`) and `pairwiseProjections`
  (`:143`); `lemma_32_2_forward` (`:161`) — **forward only**; backward reconstruction is the open
  chain-merge.
- Legacy arity-2 conjunction on the OTHER representation: `BracketFormula.conjFull` +
  `conjFull_iff` (`VecEAConjFull.lean:325,352`), `VVecEA2.conjFull` (Cartesian-product lift). These
  operate on bracket/`VVecEA2`, **not** on `ExistsForallFormula`, and bake in the endpoint-pinned
  assumption.

**Missing (must be built):** a *native* Lemma 3.2(1) on `ExistsForallFormula` (conjunction of two
`efSat` ⟺ disjunction of `efSat`), a native Lemma 3.4 ∧-closure, and a native arbitrary-pin Prop
4.2 negation. None exist on the Phase-3 object.

---

## 1. Native Lemma 3.2(1): conjunction closure via order-preserving interleavings

**Statement to prove (Lean signature):**
```lean
/-- The interleaving-disjunction of two ∃∀-formulas: all order-preserving merges of the two
    ordered witness chains, with point/interval types conjoined per merge pattern. -/
def conjInterleave {sig F r} (ψ₁ ψ₂ : ExistsForallFormula sig F r) : VeeExistsForall sig F r

theorem conjInterleave_iff {sig F r}
    (N : OrderedMonadicStructure (sigE sig F)) (env : Fin r → N.carrier)
    (ψ₁ ψ₂ : ExistsForallFormula sig F r) :
    (efSat N env ψ₁ ∧ efSat N env ψ₂) ↔ veeSat N env (conjInterleave ψ₁ ψ₂)
```

**Construction.** Both `efSat`s, when they hold, live in the *same* carrier `N` with a *single*
linear order. Two strictly-monotone chains `x : Fin (n₁+1) → carrier` and `y : Fin (n₂+1) → carrier`
therefore sit in a determinate relative arrangement: each `xᵢ` is `<`, `=`, or `>` each `yⱼ`, with
`=` forced exactly where a shared free variable pins both (`env k = x (ψ₁.pin k) = y (ψ₂.pin k)`).
Enumerate every **order-preserving merge pattern** of `Fin (n₁+1) ⊎ Fin (n₂+1)` (a monotone
surjection onto a merged index set `Fin (m+1)`, `max n₁ n₂ ≤ m ≤ n₁+n₂+1`, that identifies exactly
the coincident positions). For each pattern build one `ExistsForallFormula sig F r` whose:
- `n := m`, merged chain length;
- `pin k` := the merged position of `ψ₁.pin k` (equivalently `ψ₂.pin k`; the pattern forces
  agreement at shared pins — patterns violating this are dropped from the enumeration);
- `pointType j` := conjunction (`UnaryType`-level `∧`) of the two source point types landing at
  merged slot `j` (one side may contribute a *cap/interval* type when only the other has a point
  there — see below);
- `intervalType i` := conjunction of the interval types the two sources assert on the merged open
  interval `i`.

The disjunction over all patterns is `conjInterleave`.

**Proof skeleton.**
- **(→)** Given both hold with chains `x`, `y`: the actual relative order of `x`,`y` in `N`
  *is* one enumerated pattern `p*` (decide each `xᵢ ⋚ yⱼ` by trichotomy on the linear order;
  coincidences occur only at shared pins by `StrictMono` injectivity + the pin equations). Build the
  merged witness chain `z` for `p*`, show `StrictMono z`, and discharge each conjoined point/interval
  type from the corresponding source obligation. `veeSat` is witnessed by disjunct `p*`.
- **(←)** Given `veeSat` witnessed by pattern `p`'s formula with chain `z`: project `z` back to
  `x` (the `ψ₁`-positions of `p`) and `y` (the `ψ₂`-positions); monotonicity and the per-side
  half of each conjoined type give `efSat … ψ₁` and `efSat … ψ₂`.
- **Key case splits:** trichotomy `xᵢ < yⱼ | = | >` at each comparison; within a pattern, the four
  interval-origin cases (interval-vs-interval, point-vs-interval, interval-vs-point, point-vs-point
  at a coincidence). Induction runs on `n₁ + n₂` (merge one head at a time) — mirrors the recursion
  shape of `BracketFormula.conjFull` (`VecEAConjFull.lean:325`), which is the legacy analogue and a
  useful reference for the type-conjunction bookkeeping.

**Foundation for `UnaryType`-level conjunction:** confirm/reuse the pointwise `∧` on `UnaryType`
already used by `BracketFormula.conjFull`'s segment merge (`VecEAConjFull.lean:219-` "conjoining a
segment type everywhere"); if it is bracket-specific, lift the same `unaryHolds (a ∧ b) y ↔
unaryHolds a y ∧ unaryHolds b y` fact to `ExistsForallFormula`'s `pointType`/`intervalType`.

**Line estimate:** ~500–650 lines. The enumeration of order-preserving merges with pin-coincidence
constraints and the four-way type-origin bookkeeping are the bulk; the (←) direction is short once
the pattern datatype is right. **This is the irreducible combinatorial core of the whole unblock.**

## 2. Native Lemma 3.4 ∧-closure (depends on §1)

**Statement:**
```lean
def veeConj {sig F r} (Φ Ψ : VeeExistsForall sig F r) : VeeExistsForall sig F r
theorem veeConj_iff {sig F r} (N) (env) (Φ Ψ : VeeExistsForall sig F r) :
    (veeSat N env Φ ∧ veeSat N env Ψ) ↔ veeSat N env (veeConj Φ Ψ)
```
**Construction/skeleton:** distribute ∧ over ∨ — `veeConj Φ Ψ := Φ.flatMap (fun φ => Ψ.map (fun ψ =>
... conjInterleave φ ψ ...))`, flattening the resulting `List (VeeExistsForall)` by `List.flatten`.
Correctness: `veeSat` of a flatMap = ∃ φ ∈ Φ, ∃ ψ ∈ Ψ, `veeSat (conjInterleave φ ψ)`; apply
`conjInterleave_iff` pointwise and `veeSat_append`/`List.mem_flatten`. **~120–180 lines**, mechanical
once §1 lands.

## 3. Arbitrary-pin negation bridge — option (b) is the only SOUND route

**Adjudication (important — prevents a dead end):** Option (a) "canonicalize an arbitrary-pin r=2
object to `EndpointPinnedCapTrivial` by projecting to the 2-endpoint bracket" is **UNSOUND for the
negation case.** `EndpointPinnedCapTrivial` (`Prop42ExistsForall.lean:75-`) requires the exterior
caps `intervalType 0` and `intervalType (last)` to be *semantically trivial* (`∀ y, unaryHolds …`).
A generic `pairProject` object's exterior/interior caps carry real content (arbitrary `UnaryType`s);
folding them to trivial caps *discards the very predicate content that negation must invert*.
Negating the folded object is not equivalent to negating the original. Option (a) can only work for
objects whose caps are already trivial — exactly the class the Phase-6 engine already covers — so it
cannot extend coverage. **Do not pursue (a).**

**Option (b) — direct arbitrary-pin Prop 4.2 negation (recommended):**
```lean
/-- Prop 4.2 on the Phase-3 object WITHOUT the endpoint-pinned restriction: the complement of a
    ∨∃∀ over strictly-increasing environments is again a ∨∃∀. Consumes §1/§2. -/
theorem prop42_veeSat_negation_general {sig F}
    (N : OrderedMonadicStructure (sigE sig F))
    (Ψ : VeeExistsForall sig F 2) :
    ∃ Φ : VeeExistsForall sig F 2,
      ∀ env : Fin 2 → N.carrier, env 0 < env 1 →
        (¬ veeSat N env Ψ ↔ veeSat N env Φ)
```
**Proof skeleton (Rabinovich p.5–6 method, transcribed onto the Phase-3 object):**
1. `¬ veeSat (∨ᵢ ψᵢ)` ⟺ `⋀ᵢ ¬ efSat ψᵢ` (De Morgan over the disjunct list; `veeSat` = ∃-mem).
2. `¬ efSat ψᵢ` for a *single* arbitrary-pin ∃∀ ⟺ a ∨∃∀ `Nᵢ`. This is Prop 4.2 for one object:
   negate "there is an ordered chain with these point/interval types" by the standard case analysis
   over the finite set of order patterns the two pinned points and the caps can take — the same
   completeness of arrangements enumerated in §1. (The endpoint-pinned `prop42_veeSat_negation`,
   `:435`, is the trivial-cap special case; generalize its proof by not assuming `pinLeft/pinRight`
   and carrying the caps as content to be negated.)
3. Re-assemble `⋀ᵢ Nᵢ` into one ∨∃∀ by **§2 (`veeConj_iff`), iterated** — this is precisely the
   "closed under conjunction (Lemma 3.4)" step the paper invokes in the negation case, and the
   concrete point at which §1/§2 become load-bearing.

**Line estimate:** ~250–400 lines (step 2 single-object negation is the substantial part; steps 1
and 3 are glue over §2). Recommend landing step 2 as its own lemma
(`efSat_negation_general : ∃ Φ, ¬ efSat ψ ↔ veeSat Φ`) first.

---

## 4. Recommended sequencing and dispatch count

Strict dependency chain — **not** one dispatch. Land each green + sorry-free + committed, off the
live import path (new file(s) under `.../Kamp/`, imported by nothing live until Phase 7 rewire),
mirroring how `Prop43.lean`/`Prop42ExistsForall.lean` already sit off-path:

| Step | Deliverable | Depends on | Est. lines | Dispatch |
|------|-------------|-----------|-----------|----------|
| A | `conjInterleave` + `conjInterleave_iff` (§1) | foundations only | 500–650 | 1 (its own; likely 2 sub-dispatches: def+forward, then backward) |
| B | `veeConj` + `veeConj_iff` (§2) | A | 120–180 | shares dispatch with C or its own |
| C | `efSat_negation_general` then `prop42_veeSat_negation_general` (§3, option b) | A, B | 250–400 | 1 |
| D | Re-attempt Phase 7 Prop 4.3 negation case using C; then Phase 8 DoD | A–C | (Phase 7/8) | 1+ |

**Honest assessment:** this is **3–4 implementation dispatches of genuinely new mathematics**
before Phase 7's negation case can close, plus Phase 7/8 themselves. Step A is the critical path and
the highest-risk item (novel combinatorics, no scaffolding). The `BracketFormula.conjFull` recursion
is the closest existing template for A's type-merge bookkeeping and should be read first.

**Recommended orchestration:** create a dedicated Phase-4-completion task (steps A–C) via `/spawn
379` — this matches the Phase 7 handoff's own recommendation — then resume Phase 7 (step D) only
after A–C are green. Do NOT force Phase 7 with a `sorry`/vacuous placeholder; the spine's value is
staying green with the isolated `KampPrior.lean:562` sorry until a genuine structural path lands.

## Key citations (file:line)
- `ExistsForallFormula.lean:81-127` (structure + `efSat`); `VeeExistsForall.lean:35-69`
  (`veeSat`, `veeSat_append`); `ExistsForallLemmas.lean:74-161` (`conjSat`, `pairProject`,
  `pairwiseProjections`, `lemma_32_2_forward`); `Prop42ExistsForall.lean:75-,435-`
  (`EndpointPinnedCapTrivial`, `prop42_veeSat_negation`); `VecEAConjFull.lean:219-,325,352`
  (legacy `conjFull` template + `UnaryType` segment-conjunction); `Prop43.lean:1-40`
  (induction-case map). Rabinovich 2014 Lemma 3.2(1) p.4, Lemma 3.4 p.5, Prop 4.2 p.5, Prop 4.3
  negation case p.6.
