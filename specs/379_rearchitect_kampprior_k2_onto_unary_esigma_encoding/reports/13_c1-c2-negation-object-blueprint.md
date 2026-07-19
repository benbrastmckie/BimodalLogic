# Construction Blueprint: c1 `efSat_negation_diagonal` (arity-1) & c2 `efSat_negation_existence` (arity-0)

Task 379, Phase 10b-ii, sub-parts c1/c2. Hard-mode grounding research (H2 anti-analysis, H3
reference grounding, H4 adversarial self-verification). **Research only — no implementation source
edited.**

## Reference grounding tier

**Tier 1 (literature-backed):** Rabinovich, *A Proof of Kamp's Theorem* (2014), Prop 3.5 (PDF p.5,
one-free-variable ∃∀ ↔ TL translation) and Prop 4.3 ¬-case (PDF p.6). Every "adapt existing lemma"
claim below was checked against the actual `.lean` source (file:line), not against the corrupt
companion markdown.

## Executive verdict

- **c1 (arity-1) is constructible from existing content.** No new mathematical content, no
  nonemptiness assumption, no `VVecEA2 → VeeExistsForall` bridge. ~45 lines.
- **c2 (arity-0) is constructible from existing content, BUT the theorem as currently stated is
  provably FALSE and must gain a `Nonempty N.carrier` hypothesis.** With that one signature change
  it is elementary (order trichotomy + capture). ~100 lines. This is a signature change, not new
  math, but it is **mandatory** — see the H4 section.
- **The reverse Prop 3.5 map (`Formula → VeeExistsForall sig F 1`) is NOT needed for either** and
  should not be built. The reverse direction is discharged *semantically* by `hCapture`, exactly as
  the landed arity-2 bridge already does it.

---

## Key structural facts (verified against source)

- `VeeExistsForall sig F r := List (ExistsForallFormula sig F r)`, and
  `veeSat N env Ψ := ∃ ψ ∈ Ψ, efSat N env ψ` — `VeeExistsForall.lean:35,39`.
- `efSat N env ψ` (`ExistsForallFormula.lean:125`): `∃ x : Fin (ψ.n+1) → carrier, StrictMono x ∧
  (∀ k, env k = x (ψ.pin k)) ∧ (∀ j, unaryHolds (ψ.pointType j) (x j)) ∧ before-cap ∧ between ∧
  after-cap`. For `n = 0` the "between" clause is vacuous (`Fin 0`) and `StrictMono` on `Fin 1` is
  trivially true.
- `intervalHolds N S y := ∃ τ ∈ S, unaryHolds N τ y` where `IntervalType := Finset (UnaryType)` —
  `ExistsForallFormula.lean:87,93`. This is the exact shape of `veeSat` over a `map`ped `Finset.toList`.
- `hCapture : ∀ A : Formula, ∃ S : IntervalType, ∀ y, intervalHolds N S y ↔ temporal_truth N atomMap y A`
  — the hypothesis both c1 and c2 already carry (threaded, never discharged; discharge is Phase ζ).
- `translateProp35_correct` (`Prop35Assembly.lean:153`):
  `efSat N env ψ ↔ temporal_truth N atomMap (env 0) (translateProp35 atomMap h_surj ψ)` at arity 1.
  **Forward only.** No reverse map exists (grep-confirmed; only referenced as "unmapped" in
  docstrings at `EFSatNegationGeneral.lean:36,130`).
- `temporal_truth_neg` (`Translation.lean:41`): `temporal_truth ... φ.neg ↔ ¬ temporal_truth ... φ`.
- `intervalHolds_intervalTop` (`VVecEA2Collapse.lean:128`): `intervalTop` holds at every point —
  makes the two unbounded caps vacuous. Transitively imported by `EFSatNegationGeneral`
  (via `EFSatNegation → VVecEA2Collapse`).
- `OrderedMonadicStructure` carries `LinearOrder carrier` (`MonadicFO.lean:104-108`) but **no
  `Nonempty`/`Inhabited` constraint**.

---

## The central insight: the reverse Prop 3.5 is discharged by `hCapture`, not by a syntactic map

The skeleton docstrings frame c1/c2 as blocked on "the reverse of `translateProp35_correct`
(`Formula → VeeExistsForall sig F 1`), genuinely unmapped in the tree." That framing is **too
pessimistic**. The reverse direction needed is *semantic*, and it already exists as `hCapture`:

For any target formula `A`, `hCapture A` yields an `IntervalType S` (a finite *union* of complete
`UnaryType`s) with `intervalHolds N S y ↔ temporal_truth N atomMap y A`. Each complete `UnaryType`
`τ ∈ S` is realized by a **degenerate single-point ∃∀-object** whose `efSat` collapses to
`unaryHolds τ`. Disjoining over the completions `τ ∈ S` gives a `VeeExistsForall` whose `veeSat`
equals `intervalHolds N S = temporal_truth ... A`. This is the identical "expand-into-a-disjunction-
over-admissible-completions" move the landed arity-2 bridge performs (`vvecea2_collapse_bridge`,
`bracket_completion_iff`, `VVecEA2Collapse.lean:181,355`) — just at a single point instead of a
bracket. **No `VVecEA2` layer, and no syntactic reverse translation, is required at arity 0/1.**

This means the task's hypothesized seed path (route c1 through `negLeftClause`/`negRightClause` +
a new `VVecEA2 → VeeExistsForall` arity-1 bridge) is viable but **strictly more work** than the
direct capture construction, because it would force building the missing arity-1 collapse bridge
(the landed one is hard-wired to arity 2 via `collapseEF`'s two-endpoint pin). Recommend the direct
construction below and do **not** build the arity-1 bridge.

---

## c1 — `efSat_negation_diagonal` (arity-1)

### Target type signature (unchanged from skeleton, `EFSatNegationGeneral.lean:134`)

```lean
theorem efSat_negation_diagonal
    (N : OrderedMonadicStructure (sigE sig F))
    (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p, ∃ a : Atom, atomMap (.atom a) = p)
    (h_INF : HasAttainedINF N atomMap) (h_SUP : HasAttainedSUP N atomMap)
    (hCapture : ∀ A : Formula, ∃ S : IntervalType sig F,
        ∀ y, intervalHolds N S y ↔ temporal_truth N atomMap y A)
    (ξ : ExistsForallFormula sig F 1) :
    ∃ Φ : VeeExistsForall sig F 1, ∀ env : Fin 1 → N.carrier,
      (veeSat N env Φ ↔ ¬ efSat N env ξ)
```

No `Nonempty` needed: `Φ` is built env-independently, and the `∀ env : Fin 1 → carrier` becomes
vacuously true on an empty carrier (there is no such `env`).

### 5-column lemma-mapping table (c1)

| Obligation | Target type signature | Existing lemma/def to adapt | File:line | Gap / new-construction-needed |
|---|---|---|---|---|
| Degenerate single-point object | `pointEF1 (τ : UnaryType sig F) : ExistsForallFormula sig F 1` with `n:=0, pin:=![0], pointType:=![τ], intervalType:=![intervalTop, intervalTop]` | pattern of `collapseEF` (`VVecEA2Collapse.lean:279`), `diagProject` (`EFSatNegationGeneral.lean:74`) | new (~6 lines) | NEW def. No `n:=0` degenerate object exists (grep-confirmed). Trivial. |
| Point-object correctness | `efSat N env (pointEF1 τ) ↔ unaryHolds N τ (env 0)` | `intervalHolds_intervalTop` (`VVecEA2Collapse.lean:128`), `Fin.forall_fin_one`, efSat unfold (`ExistsForallFormula.lean:125`) | new (~18 lines) | NEW lemma. Witness `x := fun _ => env 0`; `StrictMono` on `Fin 1` trivial; caps via `intervalHolds_intervalTop`. |
| Negated forward translation | `A := Formula.neg (translateProp35 atomMap h_surj ξ)`; `¬ efSat N env ξ ↔ temporal_truth N atomMap (env 0) A` | `translateProp35_correct` (`Prop35Assembly.lean:153`), `temporal_truth_neg` (`Translation.lean:41`) | reuse | none — both landed. Same move as `negLeftClause_holds:95-100`. |
| Capture as IntervalType | `S := (hCapture A).choose`, `hS : intervalHolds N S y ↔ temporal_truth N atomMap y A` | `hCapture` (hypothesis) | reuse | none. |
| Assembly | `Φ := S.toList.map (fun τ => pointEF1 τ)`; final biconditional | `veeSat`/`intervalHolds` defs, `Finset.mem_toList`, `List.mem_map` | new (~22 lines) | NEW. Chain: `veeSat = ∃τ∈S.toList, efSat(pointEF1 τ) = ∃τ∈S, unaryHolds τ (env 0) = intervalHolds S (env 0) = temporal_truth A = ¬efSat ξ`. |

### Construction strategy (c1)

1. `A := Formula.neg (translateProp35 atomMap h_surj ξ)` — depends only on `ξ`.
2. `obtain ⟨S, hS⟩ := hCapture A`.
3. `refine ⟨S.toList.map (fun τ => pointEF1 τ), fun env => ?_⟩`.
4. Rewrite `veeSat` (`∃ ψ ∈ list, efSat`) via `List.mem_map` + `Finset.mem_toList` +
   `pointEF1_efSat` into `∃ τ ∈ S, unaryHolds N τ (env 0)` = `intervalHolds N S (env 0)`.
5. `rw [hS (env 0)]`; then `A`'s truth = `¬ temporal_truth ... (translateProp35 ξ)`
   (`temporal_truth_neg`) = `¬ efSat N env ξ` (`translateProp35_correct`, using `env 0` /
   `Matrix.cons_val_zero` bookkeeping as in `negLeftClause_holds:95`).

**Estimate: ~45 lines total** (6 + 18 + 21 assembly). Confidence: High. Every non-new lemma
was read and confirmed.

---

## c2 — `efSat_negation_existence` (arity-0)

### Target type signature — REQUIRES ONE ADDED HYPOTHESIS

Current skeleton (`EFSatNegationGeneral.lean:153`):

```lean
theorem efSat_negation_existence
    (N) (atomMap) (h_surj) (h_INF) (h_SUP) (hCapture)
    (ξ : ExistsForallFormula sig F 0) :
    ∃ Φ : VeeExistsForall sig F 0, veeSat N ![] Φ ↔ ¬ efSat N ![] ξ
```

**Required corrected signature** (add nonemptiness):

```lean
theorem efSat_negation_existence
    (N) (atomMap) (h_surj) (h_INF) (h_SUP) (hCapture)
    (hne : Nonempty N.carrier)              -- ← NEW, mandatory (see H4)
    (ξ : ExistsForallFormula sig F 0) :
    ∃ Φ : VeeExistsForall sig F 0, veeSat N ![] Φ ↔ ¬ efSat N ![] ξ
```

### Why the added hypothesis is mandatory (not optional)

On an empty carrier: `efSat N ![] ξ` needs `x : Fin (ξ.n+1) → carrier` with nonempty domain and
empty codomain — impossible — so `efSat = False`, hence `¬ efSat = True`. But for *every*
`Φ : VeeExistsForall sig F 0`, `veeSat N ![] Φ = ∃ ψ ∈ Φ, efSat N ![] ψ = False` (same reason).
So the biconditional is `True ↔ False = False`. **No construction whatsoever can satisfy c2 on an
empty carrier.** `h_INF`/`h_SUP` do NOT rescue this — they are `∀ z0 z1, z0 < z1 → …`, vacuously
true on the empty carrier (`PriorINF.lean:202,254`). c1 escapes this precisely because its `∀ env :
Fin 1 → carrier` makes it vacuous on empty carriers; c2's `env` is the fixed `![]`, so it is not
vacuous. The next implementer MUST add `hne` and discharge it at the call site (in c3 at `r ≥ 1`
from `env 0`; the concrete completeness structure is always nonempty).

### 5-column lemma-mapping table (c2)

| Obligation | Target type signature | Existing lemma/def to adapt | File:line | Gap / new-construction-needed |
|---|---|---|---|---|
| Pin the sentence to point 0 | `pinFirst (ξ : …F 0) : ExistsForallFormula sig F 1` = `{ξ with pin := ![0]}` | `existenceSentence` inverse pattern (`ExistsForallLemmas.lean:327`) | new (~6 lines) | NEW def. No such helper exists (grep-confirmed). |
| Sentence ↔ ∃-pin | `efSat N ![] ξ ↔ ∃ z, efSat N ![z] (pinFirst ξ)` | efSat unfold (`ExistsForallFormula.lean:125`); mirrors `existenceSentence_of_efSat` (`ExistsForallLemmas.lean:356`) | new (~15 lines) | NEW lemma. `∃z` absorbs the `z = x 0` pin clause. |
| Negated fwd translation | `A := Formula.neg (translateProp35 atomMap h_surj (pinFirst ξ))`; `¬ efSat N ![z] (pinFirst ξ) ↔ temporal_truth N atomMap z A` | `translateProp35_correct`, `temporal_truth_neg` | reuse | none. |
| Capture | `S := (hCapture A).choose` | `hCapture` | reuse | none. |
| Universal single-point sentence | `univSentence (τ : UnaryType) (S : IntervalType) : ExistsForallFormula sig F 0` = `{n:=0, pin:=Fin.elim0, pointType:=![τ], intervalType:=![S, S]}` | `collapseEF` pin/cap pattern | new (~7 lines) | NEW def (caps carry `S`, not `intervalTop`). |
| Sentence-object correctness | `efSat N ![] (univSentence τ S) ↔ ∃ x0, unaryHolds N τ x0 ∧ (∀y<x0, intervalHolds N S y) ∧ (∀y>x0, intervalHolds N S y)` | efSat unfold; `StrictMono`-on-`Fin 1` triviality | new (~20 lines) | NEW lemma. |
| Order-trichotomy bridge | `(∃ x0, Q x0 ∧ (∀y<x0, Q y) ∧ (∀y>x0, Q y)) ↔ ∀ z, Q z` (here `Q := intervalHolds N S`) | `LinearOrder N.carrier` (`MonadicFO.lean:104`), `lt_trichotomy`, `hne` | new (~18 lines) | NEW lemma. ⟸ needs `hne` (pick any anchor); ⟹ uses `lt_trichotomy z x0`. **This is the only place `hne` is used.** |
| Assembly | `Φ := S.toList.map (fun τ => univSentence τ S)`; final biconditional | `veeSat`, `List.mem_map`, `Finset.mem_toList`, reorder `∃x0 ∃τ∈S` ↔ `∃τ∈S ∃x0` | new (~30 lines) | NEW. |

### Construction strategy (c2)

1. `ξ' := pinFirst ξ`; `A := Formula.neg (translateProp35 atomMap h_surj ξ')`.
2. `obtain ⟨S, hS⟩ := hCapture A`; `refine ⟨S.toList.map (fun τ => univSentence τ S), ?_⟩`.
3. Reduce goal `veeSat N ![] Φ ↔ ¬ efSat N ![] ξ`:
   - RHS: `¬ efSat N ![] ξ ↔ ∀ z, ¬ efSat N ![z] ξ'` (`sentence ↔ ∃-pin` + De Morgan
     `not_exists`) `↔ ∀ z, temporal_truth N atomMap z A` (`translateProp35_correct` +
     `temporal_truth_neg`) `↔ ∀ z, intervalHolds N S z` (`hS`).
   - LHS: `veeSat N ![] Φ ↔ ∃ τ ∈ S, ∃ x0, unaryHolds τ x0 ∧ below ∧ above`
     (`univSentence` correctness) `↔ ∃ x0, intervalHolds N S x0 ∧ (∀y<x0, …) ∧ (∀y>x0, …)`
     (swap `∃τ∈S`/`∃x0`, fold `∃τ∈S, unaryHolds τ x0` into `intervalHolds N S x0`).
   - Close by the order-trichotomy bridge with `Q := intervalHolds N S`.

**Estimate: ~100 lines total.** Confidence: High on the math; the added `hne` hypothesis is the one
structural change the implementer must make. If the implementer is forbidden from changing the
signature, c2 is **[BLOCKED]** — escalate rather than attempt a sorry-free proof of a false
statement.

---

## Question 3: is a `VVecEA2 → VeeExistsForall` arity-1 bridge a shared prerequisite?

**No.** Neither c1 nor c2 needs it. The `VVecEA2` layer is the arity-2 engine's internal two-endpoint
representation; the landed `vvecea2_collapse_bridge` (`VVecEA2Collapse.lean:355`) is hard-wired to
arity 2 (`collapseEF` pins two endpoints, gate `env 0 < env 1`, output `VeeExistsForall sig F 2`).
Building an arity-1 analogue would be *more* work than the direct capture construction and would
duplicate machinery. The genuine shared prerequisite is instead the **degenerate single-point
∃∀-object + capture-to-disjunction pattern** (`pointEF1`/`univSentence`), which is small and new.
`negLeftClause`/`negRightClause` (`Prop42NegationGeneral.lean:76,111`) are *confirmed* to realize
`¬ efSat` of an arity-1 object, but as `VVecEA2` clauses destined for the arity-2 pipeline — they
are the wrong shape to feed a `VeeExistsForall sig F 1` output and should not be the c1 seed.

---

## Adversarial Self-Verification (H4)

### Claim Verification Table

| Claim | Source / Counterexample | Verification Method | Verdict |
|---|---|---|---|
| `negLeftClause`/`negRightClause` realize `¬ efSat` of an arity-1 object | `Prop42NegationGeneral.lean:76-141` | read source (`_holds` lemmas green) | VERIFIED |
| No reverse Prop 3.5 syntactic map exists in tree | grep `Formula → VeeExistsForall/ExistsForall` — only docstring mentions at `EFSatNegationGeneral.lean:36,130` | `lean_local_search`/grep miss | VERIFIED |
| `translateProp35_correct` is forward-only, arity 1, `efSat ↔ temporal_truth (env 0) (…)` | `Prop35Assembly.lean:153-158` | read signature | VERIFIED |
| `hCapture` supplies `IntervalType S` with `intervalHolds ↔ temporal_truth A` for arbitrary `A` | hypothesis in c1/c2 (`EFSatNegationGeneral.lean:139,158`); mirrored by `intervalType_captures_temporalPred` (`VVecEA2Collapse.lean:112`) | read source | VERIFIED |
| `intervalHolds N S y = ∃ τ ∈ S, unaryHolds N τ y` matches `veeSat` over `Finset.toList.map` | `ExistsForallFormula.lean:93`, `VeeExistsForall.lean:39` | read defs | VERIFIED |
| `intervalHolds_intervalTop` available + makes caps vacuous | `VVecEA2Collapse.lean:128`; import chain `EFSatNegationGeneral → EFSatNegation → VVecEA2Collapse` | read source + import graph | VERIFIED |
| c1 needs no nonemptiness (vacuous `∀ env` on empty carrier) | `efSat_negation_diagonal` goal has `∀ env : Fin 1 → carrier` | type-level reasoning | VERIFIED |
| **c2 as stated is FALSE on empty carrier; needs `Nonempty N.carrier`** | Empty carrier: `¬efSat = True`, every `veeSat N ![] Φ = False` ⟹ `True ↔ False` | vacuity argument + `OrderedMonadicStructure` has no `Nonempty` (`MonadicFO.lean:103-104`) | VERIFIED |
| `h_INF`/`h_SUP` do NOT force nonemptiness | `∀ z0 z1, z0 < z1 → …` vacuous on empty carrier | read `PriorINF.lean:202-212,254-264` | VERIFIED |
| `N.carrier` has `LinearOrder` (needed for c2 trichotomy) | `MonadicFO.lean:104,108` | read source | VERIFIED |
| `temporal_truth_neg : temporal_truth φ.neg ↔ ¬ temporal_truth φ` | `Translation.lean:41-45` | read source | VERIFIED |
| No degenerate `n:=0` single-point EF object / `pinFirst` helper already exists | grep `n := 0` in Kamp dir → none; grep `pinFirst` → none | grep miss | VERIFIED |
| Reverse Prop 3.5 is "genuinely new mathematical content" (skeleton's framing) | **Counterexample:** `hCapture` + degenerate object discharges the reverse *semantically* | reasoning from landed arity-2 bridge pattern | **REFUTED** — reverse map is neither needed nor new; c1/c2 are constructible without it |

### Explicit reverse-Prop-3.5 determination (required by task)

The reverse of `translateProp35_correct` as a **syntactic map** `Formula → VeeExistsForall sig F 1`
does not exist and is **not needed**. The reverse *semantic* direction the negation objects require
is already provided by `hCapture` (a `TL` formula's truth-set is an admissible-completion
`IntervalType`). This is the identical device the landed arity-2 `vvecea2_collapse_bridge` uses.
Therefore c1/c2 require **no genuinely new mathematical content** — only small new
plumbing definitions (`pointEF1`, `univSentence`, `pinFirst`) and, for c2, the `Nonempty` hypothesis.
I state plainly: there is no hidden deep theorem here; the earlier "genuinely unmapped / Prop 3.5
negation-closure" framing in the skeleton docstrings overstates the difficulty.

### Contradiction log

One contradiction found and resolved. The skeleton docstrings
(`EFSatNegationGeneral.lean:129-133,148-152`) assert both objects are blocked on an unmapped reverse
Prop 3.5. Precedence: **direct source reading of the available primitives** (`hCapture`,
`translateProp35_correct`, `intervalHolds` shape) outranks a docstring's self-assessment. Resolution:
the docstrings describe the *syntactic* reverse map (absent) but miss the *semantic* capture route
(present). No UNRESOLVED contradictions.

### Recommendations modified after verification

1. **Do not** seed c1 from `negLeftClause` + a new arity-1 `VVecEA2` bridge (task's hypothesis);
   use the direct `hCapture`+`pointEF1` construction — fewer new pieces, no arity-1 bridge.
2. **c2 must gain `(hne : Nonempty N.carrier)`** — this was not in the skeleton and is mandatory;
   without it the theorem is false. Flag to c3's implementer that nonemptiness must be threaded
   (available from `env 0` at `r ≥ 1`).

---

## Memory candidates

1. In this ∃∀/∨∃∀ development, the "reverse Prop 3.5" (`Formula → VeeExistsForall`) is discharged
   semantically by `hCapture` + a degenerate single-point object disjoined over admissible
   completions — never as a syntactic translation. (Pattern; reusable for any arity-0/1 negation object.)
2. Negation-of-a-*sentence* obligations (`VeeExistsForall sig F 0`) are FALSE on an empty carrier and
   require an explicit `Nonempty N.carrier` hypothesis; `HasAttainedINF/SUP` are vacuous there and do
   not supply it. Arity-`≥1` obligations with a `∀ env`/`env : Fin r→carrier` hypothesis escape this.
