# Phase 12 (δ `translate`) — ex/all Reordering-Closure Resolution

**Task**: 379 · **Phase**: 12 (δ `translate`, `translate_correct` ex/all cases)
**Agent**: lean-research-hard-agent · **Mode**: H2/H3/H4 hard
**Anchors read**: `Prop43Translate.lean` (all 191 lines), `MonadicFO.lean:63-395`,
`ExistsForallFormula.lean:105-159`, `ExistsForallLemmas.lean:172-226`, `LiftPair.lean`
(signatures + `liftPair_forward/backward/iff`), `Prop43.lean` (BLOCKED notes, 1-193),
`VeeConj.lean:61-78`, `VeeSatNegation.lean:88-117`, `EFSatNegationGeneral.lean:369-378`.

---

## Reference Grounding — Tier 1 (literature-backed: Rabinovich 2014, Lemma 3.4 / Prop 4.3)

The ex/all cases correspond to **Rabinovich, Lemma 3.4** ("the ∨∃∀ fragment is closed under a
single existential quantifier"). The module docstring itself quotes the paper's proof idea:
*"split the witness over the m+1 order positions."* That instruction is the crux and is
evaluated literally below.

| Source (Rabinovich 2014) | Prop/Location | Lean identifier | Type signature (verified) | Status |
|---|---|---|---|---|
| Lemma 3.2(3), p.4 | ∃ over pinned z₀ = drop pin | `dropPin` / `lemma_32_3` | `(∃ a, efSat N (Fin.cons a env) ψ) ↔ efSat N env (dropPin ψ)` | LANDED (ExistsForallLemmas.lean:179,192) |
| Lemma 3.4, p.5 | ∨∃∀ closed under ∃ (veeSat side) | `veeSat_exists` | `(∃ a, veeSat N (Fin.cons a env) Ψ) ↔ veeSat N env (Ψ.map dropPin)` — **no StrictMono hyp** | LANDED (ExistsForallLemmas.lean:214) |
| Def 3.1, p.4 | ∃∀-object satisfaction | `efSat` | witness chain `x` StrictMono; `pin : Fin r → Fin (n+1)` **not injective** | LANDED (ExistsForallFormula.lean:125) |
| Prop 4.3, p.6 | structural translate | `translate_correct` | `∃ Ψ, ∀ env, StrictMono env → (veeSat N env Ψ ↔ eval N env φ)` | 4/6 cases landed; ex/all `sorry` at `:186`,`:189` |
| — | eval semantics of `.ex`/`.all` | `eval` (MonadicFO) | `.ex α => ∃ x, eval M (Fin.cons x env) α` (witness at index 0, **order-unconstrained**) | LANDED (MonadicFO.lean:223) |
| — | De Bruijn weakening + eval-naturality | `lift`/`weaken`, `lift_eval`/`weaken_eval` | `eval M (Fin.cons x env) α.weaken = eval M env α` | LANDED (MonadicFO.lean:244,333,365) |

---

## 1. Recommendation

**Recommend the GOAL of path (a) — a position-split existential closure over the m+1 order
gaps (plus the m tie positions) — but REJECT path (a)'s proposed VEHICLE (liftPair
sorted-union merge + `veeSat_exists` + `dropPin`). The correct vehicle is new *eval-side*
infrastructure (`MonadicFormula.rename` + a variable-identification `subst` + their
eval-naturality lemmas + well-founded induction on formula size). Reject path (b)
(arbitrary-env generalization) as strictly larger and higher-risk: it forces re-deriving the
entire StrictMono-gated negation chain.**

Call this corrected construction **path (c)**. It is "path (a) done right": same paper-faithful
idea (split the witness over the m+1 positions), but the closure lives on the `eval` side where
the actual obstruction is, not on the `veeSat` side where the handoff's named template operates.

### 1.1 The obstruction, stated precisely

For the `.ex` case, `α : MonadicFormula (sigE sig F) (m+1)`, `env : Fin m → carrier`, and the IH is

```
hα : ∀ env' : Fin (m+1) → carrier, StrictMono env' → (veeSat N env' Ψα ↔ eval N env' α)
```

The goal reduces (via `veeSat_exists`, which needs no StrictMono) to bridging

```
(∃ a, veeSat N (Fin.cons a env) Ψα)   ↔   (∃ x, eval N (Fin.cons x env) α)
```

The only tool relating `veeSat _ Ψα` to `eval _ α` is `hα`, and it fires **only when
`Fin.cons a env` is StrictMono** — i.e. only when `a` is strictly below `env 0` (the *leftmost*
gap). For every other witness position `hα` is silent. This is the entire gap; the `veeSat`
side is already closed by `veeSat_exists`/`dropPin`.

### 1.2 Why the handoff's path-(a) vehicle does NOT close it

`liftPair`, `liftPair_forward/backward/iff`, and the "sorted-union merge" all operate on the
**veeSat / ExistsForallFormula** side:

- `liftPair_iff : veeSat N env (liftPair ξ k l) ↔ efSat N ![env k, env l] ξ` — a *projection*
  lift (Lemma 3.2(2), pairwise), used to make the **conjunction** case complete. Its sorted-union
  merge inserts *skeleton/context* points into a *witness chain*, at the formula level.
- `veeSat_exists`/`dropPin` — the veeSat-side ∃-closure, already landed and already used.

None of these produce, for a non-least witness `a`, the missing fact
`veeSat N (Fin.cons a env) Ψα ↔ eval N (Fin.cons a env) α`. That fact is about the **eval
side** and is exactly what `hα`'s StrictMono gate withholds. The handoff's analogy ("both
involve inserting a point into a sorted chain") is a surface match; the machines act on
opposite sides of the iff. **Path (a) as proposed is not constructible from the named
template** — confirmed against source in §4.

### 1.3 Why path (a)'s "reorder into a StrictMono position" re-hits the obstruction

Two independent walls (this is the H4 stress-test the task demanded):

1. **Ties admit no StrictMono reordering.** The witness `x` can equal an existing point
   (`x = env i`); the source language expresses equality as `¬(z<z')∧¬(z'<z)`, so `α` can
   *force* it. Then `Fin.cons x env` has a repeated value and **no permutation makes it
   StrictMono** (StrictMono ⇒ injective). Any "sort the witness into a strict position"
   strategy is undefined on the tie locus, which is a genuine part of `∃x`.

2. **Structural induction gives no IH for a permuted subformula.** Even for a strict (distinct)
   witness in gap `p>0`, sorting needs a permutation `π_p` with `(Fin.cons x env)∘π_p`
   StrictMono, and then `eval (Fin.cons x env) α = eval ((cons x env)∘π_p) (α.rename π_p⁻¹)`.
   But `hα` is the IH for `α`, **not** for `α.rename π_p⁻¹`. Structural induction over the
   formula does not hand you an IH for renamed subformulas. So the reorder trick cannot invoke
   `hα`.

Wall 2 is the seam that path (c) resolves: replace structural induction by **well-founded
induction on formula size**, under which `α.rename ρ` (size-preserving) and `α.subst`
(size-non-increasing) are strictly smaller than `.ex α` (size `1 + size α`), so the outer IH
*does* apply to them. Wall 1 (ties) is resolved by handling the `m` tie positions with a
variable-identification `subst` at arity `m` (a strict-mono `env`), never asking for a
StrictMono chain through a repeated point.

### 1.4 Why path (b) is larger

Path (b) = restate `translate_correct` for arbitrary `env` (drop the StrictMono gate). Blast
radius, verified against source:

- `and` — `veeConj_iff` (VeeConj.lean:61) is **already env-agnostic** (no StrictMono). Survives free.
- `lt` — must become an order-disjunction over pin arrangements. Moderate.
- `atom` — `atomEmit_iff`/`skelDisjunct_efSat` both consume `hmono` (the witness chain *is*
  `env`, forced strict-mono). Needs an "all order-types" skeleton. Large.
- `not` — `veeSat_negation` **is StrictMono-gated** (VeeSatNegation.lean:97) and is built on
  `efSat_negation_general`, **also StrictMono-gated** (EFSatNegationGeneral.lean:378). This is
  the single largest and hardest asset in the whole Prop 4.3 effort, and its interval-complement
  / INF–SUP reasoning plausibly *depends* on a strict-mono chain (empty open intervals appear
  once points coincide). Generalizing it is high-risk and possibly itself blocked.

Path (b) therefore re-opens the negation construction. Path (c) re-derives **zero** landed
cases (atom, lt, and, not all preserved verbatim). Path (c) is smaller and lower-risk.

---

## 2. Lemma-mapping table for the recommended path (c)

| Obligation | Target type signature | Existing lemma/def to adapt | File:line | Gap / new-construction |
|---|---|---|---|---|
| Variable rename with eval-naturality | `MonadicFormula.rename (ρ : Fin n → Fin n') : MonadicFormula sig n → MonadicFormula sig n'` and `eval M env' (α.rename ρ) = eval M (env' ∘ ρ) α` | `MonadicFormula.lift`/`finLift` + `lift_eval` (rename is `lift` generalized from `finLift` to an arbitrary index map) | MonadicFO.lean:232,244,333 | NEW (generalize landed lift; ~60 lines) |
| Witness-tie substitution | `subst0 (i : Fin m) : MonadicFormula sig (m+1) → MonadicFormula sig m` with `eval M env (α.subst0 i) = eval M (Fin.cons (env i) env) α` | mirror `weaken`/`weaken_eval`; here `ρ_i : Fin (m+1)→Fin m`, `0↦i`, `j+1↦j`, so `subst0 i = rename ρ_i` | MonadicFO.lean:260,365 | NEW, but a special case of `rename` (~30 lines once `rename` exists) |
| Gap reindex permutation | `insertPerm (p : Fin (m+1)) : Fin (m+1) ≃ Fin (m+1)` s.t. `(Fin.cons x env) ∘ insertPerm p` is StrictMono when `x` sits in gap `p` | `Fin.succAbove` / `Fin.cycleRange`; `insertEnv` (MonadicFO) already inserts at a cutoff | MonadicFO.lean (`insertEnv`, used by `lift_eval`) | NEW assembly (~40 lines) |
| ∃-closure at a fixed rank (veeSat side) | reuse as-is | `veeSat_exists`, `dropPin` | ExistsForallLemmas.lean:214,179 | LANDED — reuse unchanged |
| WF recursion on formula size | `translate_correct` restated via `termination_by`/`WellFoundedRecursion` on `sizeOf φ` (or a custom `MonadicFormula.size`) | `quantifier_depth` exists as a measure precedent; Lean auto-`sizeOf` on the inductive | MonadicFO.lean:63,76 | NEW induction scaffold (moderate; the 4 landed cases move under it unchanged) |
| `exClosure` core lemma | see §3 | assembles the above + `veeSat_exists` | — | NEW (~200-300 lines, the load-bearing piece) |
| `all` case | `.all α`: `¬∃¬` at eval level, then landed `not` ∘ `exClosure` ∘ landed `not` | `veeSat_negation` (twice) + eval De Morgan bridge | VeeSatNegation.lean:88 | NEW glue (~40 lines); reuses landed negation |
| atom / lt / and / not | unchanged | `atomEmit_iff`, index-decided `lt`, `veeConj`, `veeSat_negation` | Prop43Translate.lean:105,158,178,172 | PRESERVED (0 re-derivation) |

---

## 3. Object(s) to build — exact signatures, strategy, line estimates

### 3.1 `rename` + eval-naturality (generalizes landed `lift`)

```lean
def MonadicFormula.rename {sig n n'} (ρ : Fin n → Fin n') :
    MonadicFormula sig n → MonadicFormula sig n'
  | .atom p i => .atom p (ρ i)
  | .lt i j   => .lt (ρ i) (ρ j)
  | .not α    => .not (α.rename ρ)
  | .and α β  => .and (α.rename ρ) (β.rename ρ)
  | .all α    => .all (α.rename (Fin.cases 0 (Fin.succ ∘ ρ)))   -- lift ρ under the binder
  | .ex  α    => .ex  (α.rename (Fin.cases 0 (Fin.succ ∘ ρ)))

theorem eval_rename {sig n n'} (M) (ρ : Fin n → Fin n') (env' : Fin n' → M.carrier)
    (α : MonadicFormula sig n) : eval M env' (α.rename ρ) = eval M (env' ∘ ρ) α
```

Proof mirrors `lift_eval` (MonadicFO.lean:333) verbatim — the binder case uses the same
`Fin.cons`/`insertEnv` bridge already proven there. `size (α.rename ρ) = size α` (rename touches
only leaves and index maps), which is what makes the WF-size IH fire. **~60 lines.**

### 3.2 `exClosure` core (the load-bearing lemma)

```lean
-- Inside translate_correct's `.ex` case, WF-recursion on `sizeOf`.
-- IH available (size-smaller) at: α.rename (insertPerm p)⁻¹ (arity m+1, size = size α)
--                            and: α.subst0 i         (arity m,   size ≤ size α)
-- Target:
--   ∃ Ψ, ∀ env, StrictMono env → (veeSat N env Ψ ↔ ∃ x, eval N (Fin.cons x env) α)
```

Strategy — the paper's "split over m+1 positions", made total by adding the `m` ties:

1. Classify witness `x` against strict-mono `env` (m points): `x < env 0` (gap 0), each open
   interval `env (k-1) < x < env k` (gaps `1..m-1`), `x > env (m-1)` (gap m), or `x = env i`
   (ties `i : Fin m`). Total `m+1` gaps + `m` ties. Classification is total on a linear order
   (`lt_trichotomy` disjunct-wise).
2. **Gap p**: `Fin.cons x env` reorders by `insertPerm p` to a strict-mono `(m+1)`-chain;
   `eval (cons x env) α = eval (chain) (α.rename (insertPerm p)⁻¹)` via `eval_rename`. The
   renamed body is size-`= size α < size (.ex α)` at arity `m+1`; WF-size IH gives its
   translation `Ψ_p`; the witness now sits at a fixed rank, so `∃x`-in-gap-`p` closes on the
   veeSat side via `veeSat_exists`/`dropPin` ⇒ disjunct `Ψ_p.map dropPin`.
3. **Tie i**: `eval (cons (env i) env) α = eval env (α.subst0 i)` via `eval_rename`/`subst0`;
   arity `m`, size `≤ size α`; WF-size IH at strict-mono `env` gives disjunct `Ψ_i` directly
   (no further ∃-closure — the point is pinned to `env i`).
4. `Ψ := (⋃_{p} Ψ_p.map dropPin) ++ (⋃_{i} Ψ_i)` (list concat of `VeeExistsForall`). Forward:
   any satisfied disjunct yields a witness of the right order type. Backward: the trichotomy
   classification of the eval-witness selects the matching disjunct.

**~200-300 lines** (the position/tie enumeration and the two-direction assembly dominate).

### 3.3 `all` case (dual, reuses landed negation)

```lean
-- eval bridge (eval unfolding + classical): eval env (.all α) ↔ ¬ ∃ x, eval (cons x env) (.not α)
obtain ⟨Ψα,  hα ⟩ := IH α                         -- size-smaller
obtain ⟨Ψnα, hnα⟩ := veeSat_negation … Ψα          -- landed, StrictMono-gated (env strict-mono ✓)
obtain ⟨Ψex, hex⟩ := exClosure (body := .not α) …  -- §3.2 on ¬α
obtain ⟨Ψall,hall⟩ := veeSat_negation … Ψex         -- landed
```

Uses only the landed `not` machinery + `exClosure`; no new negation content. **~40 lines** plus
the eval De Morgan bridge (~20 lines). Note: express `.all` via `exClosure`-as-a-lemma
(consuming a provided translation), **not** by recursing on the syntactically larger
`.not (.ex (.not α))`, to respect the size measure.

### 3.4 Total

New content ≈ **360-520 lines**, all localized to eval-side ops + ex/all. **Zero** re-derivation
of atom/lt/and/not. Contrast path (b): 1000-2000 lines re-opening the negation chain.

---

## 4. H4 — Adversarial Self-Verification

Every load-bearing claim below was checked against the actual source (line-cited), per the
Claim Verification Bar. Verification methods: `read` = direct source read at cited line;
`lean_hover`-class facts are noted where a signature was the evidence.

| Claim | Source / Counterexample | Verification method | Verdict | Confidence |
|---|---|---|---|---|
| The ex/all gap is on the *eval* side, not the veeSat side | `veeSat_exists` closes the veeSat side with **no StrictMono hyp** | read ExistsForallLemmas.lean:214-217 | CONFIRMED | High |
| `hα` (IH) fires only for the leftmost gap (`a < env 0`) | `translate_correct` conclusion gated `StrictMono env`; `Fin.cons a env` StrictMono ⟺ `a < env 0` | read Prop43Translate.lean:145; eval def MonadicFO.lean:223 | CONFIRMED | High |
| Path (a)'s template (liftPair/veeSat_exists/dropPin) cannot supply the missing eval-side fact | `liftPair_iff` is a projection lift on the veeSat side; produces `efSat`↔`veeSat`, never `veeSat`↔`eval` | read LiftPair.lean:540; :277 (`liftPair_forward` merges chains, not eval) | CONFIRMED — path (a) as proposed **not constructible from named template** | High |
| Ties (`x = env i`) are reachable and admit no StrictMono reorder | equality expressible as `¬(z<z')∧¬(z'<z)` in the source language (has `not`,`lt`,`and`); StrictMono ⇒ injective | read MonadicFO.lean:63-69 (constructors); Def efSat StrictMono `x` at ExistsForallFormula.lean:129 | CONFIRMED — the reorder closure **re-hits** the obstruction on the tie locus | High |
| Structural induction gives no IH for `α.rename σ`; needs WF-size induction | IH in `induction φ` is for immediate subformula `α` only; `α.rename σ` is a different term | read Prop43Translate.lean:148 (`induction φ`); rename size-preserving by construction | CONFIRMED | High |
| `rename` + `eval_rename` is a modest generalization of landed code | `lift`=rename by `finLift`; `lift_eval` is exactly the eval-naturality shape, binder case already proven | read MonadicFO.lean:244,333-351 | CONFIRMED | High |
| Path (b) re-opens the StrictMono-gated negation chain | `veeSat_negation` gated (`StrictMono env`); built on `efSat_negation_general`, also gated | read VeeSatNegation.lean:97; EFSatNegationGeneral.lean:378 | CONFIRMED | High |
| `and` survives path (b)/(c) generalization for free | `veeConj_iff` has no StrictMono hyp | read VeeConj.lean:61-63 | CONFIRMED | High |
| efSat can natively express tied/arbitrary environments (supports the *feasibility* of position-split) | `pin : Fin r → Fin (n+1)` not required injective; two free vars may pin to one chain point | read ExistsForallFormula.lean:108-109 | CONFIRMED | High |
| `Prop43.lean`/`existClosure` confirms only a *rightward* absorption exists | that file is the **old** VVecEA_m/Boneyard framework; `existClosure` (`VecEA_m.lean:208`) absorbs the rightmost var only | read Prop43.lean:155-163 | CONFIRMED (but note: old framework — informative, not directly reusable) | Medium |
| The per-gap "reindex-then-close" assembly (`Ψ_p.map dropPin` at a fixed rank) is correct | Reasoned from `veeSat_exists` + `dropPin` pin semantics; **not yet mechanized** | design-level derivation only | UNVERIFIED — the exact pin-rank bookkeeping in step 3.2(2) is the one piece not reduced to a landed lemma | Medium |
| `all` via `¬∃¬` composition respects the size measure when `exClosure` is a lemma | If `exClosure` consumes a provided `Ψ` (not a recursive call), no size obligation on `.not(.ex(.not α))` | design-level | Plausible; UNVERIFIED in Lean | Medium |

### Contradiction log

No contradictions among confirmed claims. One **tension** surfaced and resolved: the handoff
frames (a) and (b) as the only options and pairs (a) with the liftPair template. Verification
shows the liftPair template is on the wrong side of the iff (High confidence), so the binary is
false — the constructible route is (a)'s *goal* with a *different vehicle* (path c). Resolved by
precedence rule "source signature beats handoff narrative": the signatures of `liftPair_iff`
(veeSat↔efSat) and `hα` (StrictMono-gated veeSat↔eval) are dispositive.

### Single most load-bearing risk (flagged)

The `UNVERIFIED` row — **the per-gap reindex-then-∃-close bookkeeping (§3.2 step 2)**: getting
`veeSat_exists`/`dropPin` to close the open-interval existential *at the fixed rank produced by
`insertPerm p`* is the one sub-step not backed by an already-landed lemma. If that pin-rank
bookkeeping proves harder than the tie case, the fallback is to translate *all* `2m+1` order
types uniformly through `subst`/`rename` at the appropriate arity (treating each gap like a tie
into an inserted fresh point via a density/witness lemma), avoiding `dropPin` entirely. Path (b)
remains the ultimate fallback if the eval-side infra stalls.

---

## 5. Memory candidates

1. *(pattern, lean4)* When a structural-induction proof over a formula type is gated on an
   order hypothesis (`StrictMono env`) that binder cases break, the fix is well-founded
   induction on formula size + a size-preserving `rename`/`subst` with eval-naturality — not a
   "reorder the environment" trick, which dies on ties (equality is expressible) and cannot get
   an IH for the renamed subformula.
2. *(fact, task-379)* In the Kamp E[Σ] ∨∃∀ framework, the ex/all obstruction is on the **eval**
   side; `veeSat_exists`/`dropPin` already close the veeSat side unconditionally. `liftPair` is a
   *projection* lift (Lemma 3.2(2)) for conjunction completeness, not an existential-insertion
   tool — do not reach for it to close ex/all.
3. *(fact, task-379)* `efSat`'s `pin : Fin r → Fin (n+1)` is non-injective by design
   (ExistsForallFormula.lean:109), so `veeSat` can express arbitrary/tied environments; the
   StrictMono gate in `translate_correct` is a *convenience* for atom/lt, not a semantic limit.

---

## 6. Verdict (3 lines)

- **Recommended path**: (a)'s GOAL (position-split closure over the m+1 gaps + m ties) — call it
  **(c)** — but with a corrected vehicle; **reject (a)'s liftPair/veeSat_exists template**
  (wrong side of the iff) and **reject (b)** (re-opens the StrictMono-gated negation chain).
- **Constructible from existing?** Needs NEW eval-side content (`MonadicFormula.rename`+`subst`+
  eval-naturality + WF-size induction, ~360-520 lines) that *generalizes landed* `lift`/`lift_eval`;
  atom/lt/and/not preserved with zero re-derivation. Not turnkey from named assets, but low-risk.
- **Load-bearing risk**: the per-gap reindex-then-∃-close pin-rank bookkeeping (§3.2 step 2) — the
  one step not reducible to a landed lemma; fallback is uniform `subst`/`rename` over all 2m+1
  order types, or path (b) as last resort.
