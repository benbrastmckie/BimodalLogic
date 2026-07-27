# Re-basing Rabinovich Section 5 onto the faithful Dedekind carrier: measured baseline, landed inventory, and the Lemma 5.3 GO/NO-GO gate

**Date**: 2026-07-27 | **Session**: `sess_1785150996_3c6f1f_378` | **Type**: lean4 research

**Headline**: the Lemma 5.3 gate resolves **GO**, on machine-checked evidence. The printed
three-disjunct `Oₙ₊₁` (PDF p.8) is transcribable over `HasDedekindINF` in `VVecEA2`, sorry-free
and axiom-clean, with **no hypothesis absent from p.8**. The probe that proves it is
`reports/01_lemma53-faithful-gate-probe.lean` (compiles standalone, EXIT 0).

The follow-on work (Lemma 5.1 / Prop 4.2) is **substantially larger than the inherited plan
estimated**, for a reason the plan did not identify: it is a `VBracketFormula → VVecEA2` **type
migration** of a 2,750-line stack, not a hypothesis weakening. Section 6 quantifies this.

---

## 0. Corrections to the dispatch context (verify before relying on the originals)

Several inherited pointers are stale. None invalidate the task; all would misdirect a dispatch.

| Inherited claim | Measured reality |
|---|---|
| Paths under `Theories/Bimodal/…` | The tree is `FormalSystem/…`. `Theories/Bimodal.lean` does not exist; the root module is `FormalSystem.lean`. |
| Baseline `1766 jobs / 239 live modules` | **1883 jobs**; **269** live modules reachable from `FormalSystem.lean` (443 `.lean` files exist under `FormalSystem/`, so 174 are dead). |
| Permitted live sorries `KampPrior:520`, `EANegation:1090`, `:1249` | **All three are gone.** `EANegation.lean` is 694 lines total — `:1090`/`:1249` cannot exist. Live sorry count in `Kamp/` is **0**. Gate vacuously satisfied. |
| `negChainOn` at `OnBuilder.lean:149` | `:179` (`negChainOn_iff` at `:189`, not `:159`) |
| `BracketFormula.negFix_iff` at `NegFix.lean:669` | `:694` |
| `VVecEA2.negFix_iff` at `VecEANegFix.lean:164` | `:183` (`:154` is `def VVecEA2.negFix`) |
| `hasDefinableINF_excludes_kplus` at `Lemma53.lean:282` | `:290` |
| `kplus_formula_correct` at `Lemma53.lean:154` | `:162` |
| `prior_hasAttainedINF` at `PriorINF.lean:224`; `HasAttainedINF.toHasDefinableINF` at `:215` | `:230` and `:221` |
| `BracketFormula.prepend`/`_holds`/`_holds_inv`/`prependAll` at `EANegation.lean:123`/`135`/`223`/`333` | `:93`/`:105`/`:196`/`:312` |
| `negFixList` at `NegFix.lean:424`; `negFixList_iff` at `:495` | `:449` and `:520` |
| `negBoundedRightFix_iff` at `BoundedFix.lean:449`; left mirror at `:768` | `:455` and `:774` |
| `VVecEA2.conjFull`/`_iff` at `VecEAConjFull.lean:491`/`503` | `:498`/`:510` |

Two **in-tree docstrings are also stale** and should be corrected when those files are next
touched (both understate what is available, and both are the kind of stale note this task family
has repeatedly paid for):

- `Lemma53.lean:426-428` says reaching the faithful carrier "additionally needs `BracketFormula.cons`
  … and `TemporalPred` disjunction (`VecEAFormula.lean` has `neg` and `conj` but no `disj`)".
  **Both now exist**: `BracketFormula.prepend` (`EANegation.lean:93`) and `TemporalPred.disj`
  (`ExistsForallNF.lean:87`) with `eval_at_disj` (`VecEAClosure.lean:49`).
- `Section5Correspondence.lean:33,35,41` cites `OnBuilder.lean:159`, `NegFix.lean:669`,
  `VecEANegFix.lean:164` — all drifted (see table).

---

## 1. (a) Measured baseline

All figures re-measured this session, not inherited.

| Metric | Value | How measured |
|---|---|---|
| `lake build` exit | **0** | `lake build` |
| Jobs | **1883** | build tail line |
| Live modules (reachable from `FormalSystem.lean`) | **269** | import-graph walk from `FormalSystem.lean` |
| `.lean` files under `FormalSystem/` | 443 | `find` |
| Boneyard modules reachable | **0** | same walk |
| Tactic-position sorries in `Kamp/` | **4, all dead** | `.claude/scripts/lean-sorry-census.sh` |
| Live sorries in `Kamp/` | **0** | same |

Dead sorry inventory (all under `Kamp/Boneyard/`, compiled by nothing):
`EndpointNegation.lean:164`, `FOToVEA.lean:122`, `EANegationVBracketBackward.lean:452`,
`EANegationVBracketBackward.lean:611`.

**Liveness method**: reachability from `FormalSystem.lean` by transitive `import` walk — not
`lake build <target>`, per the standing warning that `BoneyardArchive` passes vacuously. The walk
confirms `DedekindINF.lean`, `Section5Correspondence.lean`, `Lemma53.lean`, all of
`EANegationFix/`, and `NfMultiAnchorBridge/AggregateOffDiagK1.lean` are **LIVE**, and that **no**
`Boneyard/` module is.

**Sorry-gate status**: the amended gate permits at most three named live sorries. Zero exist. The
gate is **vacuously satisfied**, and the `state.json` wording naming `EANegation.lean:1090`/`:1249`
is factually obsolete (that file is 694 lines) — flagged for correction, not acted on here.

---

## 2. (b) What of Phases 7-8 is ALREADY LANDED vs genuinely absent

### 2.1 Landed and green — build on this

| Item | Location | Status |
|---|---|---|
| `HasDedekindINF` / `HasDedekindSUP` (the faithful eq (5.2) carrier) | `Kamp/DedekindINF.lean:136` / `:153` | live, sorry-free, axiom-clean |
| Four compatibility shims (`HasAttainedINF/HasDefinableINF.toHasDedekindINF` + SUP duals) | `DedekindINF.lean:172`, `:185`, `:200`, `:210` | live, sorry-free |
| `prior_hasDedekindINF` / `prior_hasDedekindSUP` | `DedekindINF.lean:232` / `:240` | live, sorry-free |
| `hasDedekindINF_admits_kplus_shape`, `hasDefinableINF_incompatible_with_kplus` | `DedekindINF.lean:264`, `:283` | live, sorry-free |
| `TemporalPred.disj` + `eval_at_disj` | `ExistsForallNF.lean:87`, `VecEAClosure.lean:49` | live, sorry-free |
| `kplusFormula` + `kplus_formula_correct` | `PriorINF.lean:93`, `Lemma53.lean:162` | live, sorry-free |
| `hasDefinableINF_excludes_kplus` | `Lemma53.lean:290` | live, sorry-free |
| `lemma53` (attained carrier), `lemma53_basis`, `O_zero_correct`, `oOne`, `oZero` | `Lemma53.lean:432`, `:221`, `:196`, `:210`, `:191` | live, sorry-free |
| `negChainOn` / `negChainOn_iff` (two-disjunct, attained) | `OnBuilder.lean:179` / `:189` | live, sorry-free |
| `BracketFormula.prepend` / `_holds` / `_holds_inv` / `VBracketFormula.prependAll` | `EANegation.lean:93` / `:105` / `:196` / `:312` | live, sorry-free |
| `VVecEA2.conjFull` / `_iff`, `VVecEA2.disj` / `_holds`, `VVecEA2.trivialTrue` | `VecEAConjFull.lean:498`/`:510`, `VecEAFormula.lean:288`/`:292`, `VecEAConjFull.lean:549` | live, sorry-free |
| Section 5 correspondence table + `prop42_contentful_of_attained` | `Section5Correspondence.lean` | live, sorry-free |

**Phase 6 is confirmed DONE.** Every task in the inherited Phase 6 list is landed, including the
two primitives its own docstring still claims are missing (see §0).

### 2.2 Genuinely absent

| Missing item | Evidence of absence |
|---|---|
| `negChainOnFaithful` (three-disjunct `Oₙ`, `VVecEA2`) | no such declaration anywhere; `negChainOn` returns `VBracketFormula` and has 2 disjuncts (`OnBuilder.lean:179-183`) |
| A `VVecEA2`-level prepend that absorbs `endpointLeft` | `VVecEA2.prependAll` — **0 hits**; only `VBracketFormula.prependAll` exists |
| `VVecEA2.conjEverywhere` | **0 hits** (`VBracketFormula.conjEverywhere` at `NegFix.lean:78`) |
| `VVecEA2.concatPin` | **0 hits** (`VBracketFormula.concatPin` at `ConcatPin.lean:97`) |
| Faithful analogues of `negBoundedRightFix`/`LeftFix`(`Anchored`), `negFixOne`, `negFixList`, `BracketFormula.negFix`, `VecEA2.negFix`, `VVecEA2.negFix` | all typed `VBracketFormula`/attained; see §6 |
| `prop42_contentful_of_dedekind` | **0 hits** |
| A formalized non-attained Dedekind-complete structure (e.g. `ℝ`) | **0 hits**; `DedekindINF.lean:49-50` states this explicitly |

---

## 3. (c) Page-cited correspondence for the three targets

Source (PDF pages only): `~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.pdf`.
PDF p.8 read directly this session; its text is quoted below verbatim where load-bearing.

### Target 1 — Lemma 5.3, PDF p.8

Printed statement: *"¬∃x₁…xₙ (z₀ < x₁ < ⋯ < xₙ < z₁) ∧ ⋀ᵢ₌₁ⁿ Pᵢ(xᵢ) is equivalent over Dedekind
complete chains to a ∨∃⃗∀ formula Oₙ(P₁,…,Pₙ,z₀,z₁)."*

Inductive step, `Oₙ₊₁` = disjunction of "`(z₀,z₁)` is empty" and:

1. `(∀y)^{<z₁}_{>z₀}¬P₁(y)`
2. `K⁺(P₁)(z₀) ∧ Oₙ(P₂,…,Pₙ,z₀,z₁)`
3. `(∃r₀)^{<z₁}_{>z₀}(INF(z₀,r₀,z₁,P₁) ∧ Oₙ(P₂,…,Pₙ,r₀,z₁))`

with eq (5.2) `INF(z₀,r₀,z₁,P₁) := z₀ < r₀ < z₁ ∧ (∀y)^{<r₀}_{>z₀}¬P₁(y) ∧ (P₁(r₀) ∨ K⁺(P₁)(r₀))`.

Case 2 reads: *"let r₀ = inf{z ∈ (z₀,z₁) | P₁(z)} (such r₀ exists by Dedekind completeness). Note
that r₀ = z₀ iff K⁺(P₁)(z₀)."*

| Paper object (p.8) | In-tree | Status |
|---|---|---|
| Disjunction of the two subcases (`r₀ = z₀` / `r₀ ∈ (z₀,z₁)`) | `HasDedekindINF.first_occ` (`DedekindINF.lean:140`) | landed, **faithful** |
| `K⁺(P₁)` as a predicate | `kplus` (`PriorINF.lean:86`) | landed |
| `K⁺(P₁)` as object-language syntax | `kplusFormula` (`PriorINF.lean:93`) + `kplus_formula_correct` (`Lemma53.lean:162`) | landed |
| `Oₙ` (`∨∃⃗∀` class) | `VVecEA2` (`VecEAFormula.lean:277`) | landed |
| Basis, `n = 1` | `lemma53_basis` (`Lemma53.lean:221`) | landed |
| `O₀` | `oZero` (`Lemma53.lean:191`) | landed |
| Disjunct (1) | `oOne` (`Lemma53.lean:210`) | landed |
| Disjunct (2) | — | **absent from the library; supplied by the probe** |
| Disjunct (3) point type `P₁ ∨ K⁺(P₁)` | `TemporalPred.disj` (`ExistsForallNF.lean:87`) | landed |
| `Oₙ₊₁` builder, all three disjuncts | `negChainOnFaithful` (probe) | **new** |

**One p.8 remark deserves flagging.** Rabinovich justifies disjunct (2) staying in class by:
*"K⁺(P₁)(z₀) is an atomic (and hence a ∨∃⃗∀) formula in the canonical expansion."* This tree has
**no canonical-expansion machinery** — `OnBuilder.lean:26-31` says so outright. That looked like a
genuine encoding gap. It is not: `kplus_formula_correct` (`Lemma53.lean:162`) proves `K⁺(P)` is
**outright TL-definable** here as `¬P ∧ ¬(⊤ U ¬P)`, so it can be carried as a `TemporalPred` in
`VecEA2.endpointLeft` with no expansion. This is the single most important fidelity finding of the
gate, and it is machine-checked (`kplusPred_eval` in the probe).

### Target 2 — Lemma 5.1, PDF pp.9-10

| Paper object | In-tree | Status |
|---|---|---|
| Notation 5.2 `[α₀,β₁,…,βₙ,αₙ](z₀,z₁)` | `BracketFormula` (`VecEAFormula.lean`) | landed |
| Cor 5.4(1)/(2) (p.9) | `negBoundedRightFix_iff` / `negBoundedLeftFix_iff` (`BoundedFix.lean:455`/`:774`) | landed, **attained** |
| `Aᵢ`/`Bᵢ` split + closing induction (pp.10-11) | `negFixList` / `negFixList_iff` (`NegFix.lean:449`/`:520`) | landed, **attained** |
| Lemma 5.1 itself | `BracketFormula.negFix_iff` (`NegFix.lean:694`) | landed, **attained** |
| Faithful re-base | — | **absent** |

### Target 3 — Prop 4.2, PDF p.6

| Paper object | In-tree | Status |
|---|---|---|
| Prop 4.3 De Morgan fold (p.6) | `VVecEA2.negFix` (`VecEANegFix.lean:154`) | landed |
| Prop 4.2 biconditional | `VVecEA2.negFix_iff` (`VecEANegFix.lean:183`) | landed, **attained** |
| Contentful (hoisted) statement | `prop42_contentful_of_attained` (`Section5Correspondence.lean:128`) | landed, **attained** |
| Faithful re-base (`prop42_contentful_of_dedekind`) | — | **absent** |

---

## 4. (d) The Lemma 5.3 GO/NO-GO gate: **GO**

**Artifact**: `specs/378_rebase_section5_onto_faithful_dedekind_carrier/reports/01_lemma53-faithful-gate-probe.lean`
**Result**: `lake env lean <probe>` → **EXIT 0**, `sorry_count: 0` by tactic-position census.

The written kill criterion was: GO iff `negChainOnFaithful_iff` is proved sorry-free under
`HasDedekindINF` in the hoisted shape, non-vacuity confirmed; NO-GO if the carrier cannot discharge
the printed step without a hypothesis absent from p.8, **or** if the `K⁺` disjunct cannot be
expressed in `VVecEA2`. Both NO-GO conditions are **refuted**:

| Gate check | Result |
|---|---|
| `#print axioms negChainOnFaithful_iff` | `[propext, Classical.choice, Quot.sound]` — **no `sorryAx`** |
| `#print axioms lemma53Faithful` (hoisted shape) | `[propext, Classical.choice, Quot.sound]` |
| `#print axioms VVecEA2.prependAllVec_holds` | `[propext, Classical.choice, Quot.sound]` |
| `#print axioms orderedPointsExist_combine_kplus` | `[propext, Classical.choice, Quot.sound]` |
| `#print axioms prior_makes_disjunct2_unreachable` | `[propext]` |
| Result type is `VVecEA2`, not `VBracketFormula` | yes — `endpointLeft` carries `K⁺(P₁)` at `z₀` |
| Hypothesis beyond p.8 required | **none** — only `HasDedekindINF` |
| Hoisted shape (`∃ O, ∀ M atomMap z₀ z₁`) achieved | yes — `lemma53Faithful` |
| Failed-vacuity control recorded | yes — `lemma53Faithful_perPoint_is_VACUOUS` compiles with **no carrier hypothesis at all** |

### 4.1 What the probe contains

- `kplusPred` / `kplusPred_eval` — `K⁺(P)` as a `TemporalPred`, correct by `kplus_formula_correct`.
- `VVecEA2.prependAllVec` / `_holds` — the **one genuinely new construction**. The recursive `Oₙ`
  is a `VVecEA2` carrying its own `endpointLeft` **at `r₀`**; disjunct (3) must absorb it into the
  point type at `r₀` (`ptType.conj d.endpointLeft`). `VBracketFormula.prependAll` cannot do this.
  Proved from `BracketFormula.prepend_holds`/`_holds_inv` — reused, not rebuilt.
- `orderedPointsExist_combine_kplus` — disjunct (2)'s backward half. `K⁺(P₁)(z₀)` says `P₁` occurs
  in *every* interval above `z₀`, so a tail chain on `(z₀,z₁)` always extends downward by one
  `P₁`-point. **This is exactly why p.8's `Subcase r₀ = z₀` recurses on the same interval** rather
  than a shrunken one — the paper's structure is recovered, not worked around.
- `orderedPointsExist_widen_left` — needed by eq (5.2)'s `K⁺(P₁)(r₀)` alternative, where `P₁` does
  **not** hold at `r₀` and the pinned witness must be reported back on the outer interval.
- `negChainOnFaithful` / `negChainOnFaithful_iff` — the three-disjunct builder and its
  biconditional, following `negChainOn_iff`'s induction structure step-by-step with the extra case
  split, per the literature-fidelity rule.
- `lemma53Faithful` — `lemma53` (`Lemma53.lean:432`) verbatim with `HasAttainedINF` weakened to
  `HasDedekindINF`.

### 4.2 Sizing verdict

The gate closed in **one dispatch**, as the plan required. The three-strikes sizing guard does
**not** fire for Phase 7. It says nothing reassuring about Phase 8 — see §6, which finds an
obstruction the plan did not anticipate.

---

## 5. (e) What the faithful carrier EXCLUDES — extended non-vacuity

Strengthening chain (weakest → strongest), unchanged and confirmed:

```
Rabinovich's Dedekind completeness  <  HasDedekindINF  <  HasDefinableINF  <  HasAttainedINF
                                       ^ faithful                              ^ what EANegationFix/ assumes
```

**What `HasDedekindINF` excludes.** Bare Dedekind completeness supplies the *existence* of
`inf{z ∈ (z₀,z₁) | P₁(z)}`. `HasDedekindINF` additionally asserts that infimum is **TL-definable**
in one of the paper's shapes (`K⁺` at `z₀`; attained at an interior `r₀`; or a `K⁺` limit at an
interior `r₀`). It therefore excludes chains where the first-occurrence infimum exists but is none
of those three. This is a definability assumption Rabinovich *derives* rather than assumes, which
is why the carrier sits strictly to the right of his own hypothesis. This is honest and was already
correctly stated at `DedekindINF.lean:63-67`; I confirm it rather than restate it as new.

**What the re-base buys, and where it is observable — the load-bearing finding.**

`prior_makes_disjunct2_unreachable` (probe, axioms `[propext]`) machine-proves:

> On any `SemanticPriorUZ` structure, `kplus M atomMap P z₀` is **impossible** whenever `P` occurs
> in `(z₀,z₁)`.

Chain: `SemanticPriorUZ → HasAttainedINF` (`PriorINF.lean:230`) `→ HasDefinableINF` (`:221`), and
`hasDefinableINF_excludes_kplus` (`Lemma53.lean:290`) then kills `K⁺(P)(z₀)`.

**Consequence**: `negChainOnFaithful`'s disjunct (2) is **provably dead on every Prior structure**.
It fires only on a structure that is not a Prior structure, and **no such structure is constructed
anywhere in this tree** — `DedekindINF.lean:49-50` states there is no `ℝ` `OrderedMonadicStructure`
and my search confirms it.

This is the extended non-vacuity rule applied to itself, and it cuts both ways:

- The re-base is **not vacuous as mathematics**: disjunct (2) is genuinely exercised by
  `negChainOnFaithful_iff`'s proof (the `Subcase r₀ = z₀` branch is taken, and its backward half
  needs real content — `orderedPointsExist_combine_kplus`). The three disjuncts are not dead syntax.
- The re-base is **currently unobservable by any consumer**. Every consumer in the tree runs on
  Prior structures, where the faithful and attained carriers are interderivable. It becomes
  observable **only once a genuinely non-attained Dedekind-complete frame class is built**.

That is precisely the stated project goal (a Dedekind-complete frame class with its own completeness
theorem), so the value case in the task description survives — but it survives as a *prerequisite
for work not yet begun*, not as something the current tree can exercise. I flag this because
"sorry-free + axiom-clean + EXIT 0" is exactly what an over-strong-hypothesis failure also looks
like, and the honest statement is: **the faithful re-base is contentful, and its content is not yet
reachable from any live consumer.**

`hasDedekindINF_admits_kplus_shape` (`DedekindINF.lean:264`) should **not** be cited as evidence
against this. Its proof is `Or.inl h_kplus` — it assumes `kplus` and returns a disjunction
containing it. Its own docstring (`:257-261`) admits it "does not exhibit a structure in which
`K⁺(P)(z₀)` holds". It is a well-typedness check, not a reachability witness.

---

## 6. (f) Phase 8 sizing — an obstruction the inherited plan did not identify

**Flagging this prominently: the inherited Phase 8 estimate of "2-4 dispatches" is not supportable,
for a structural reason, not an optimism reason.**

The inherited plan frames Phase 8 as re-basing `HasAttainedINF → HasDedekindINF` in a sequence of
`_iff` theorems. That framing is wrong. The faithful `Oₙ` **changes type**: `negChainOn` returns
`VBracketFormula`, `negChainOnFaithful` must return `VVecEA2` (disjunct (2) needs an endpoint
predicate). And `negChainOn`'s output is not merely *used* downstream — its `.disjuncts` are
**spliced into `VBracketFormula` literals**:

```
BoundedFix.lean:446-449   negBoundedRightFix … : VBracketFormula :=
  ⟨⟨1, rightPinBracket …⟩ :: (negChainOn (untilChainPreds bf.foldPairs)).disjuncts⟩
```

Four such splice sites: `BoundedFix.lean:449`, `:767`; `BoundedFixAnchored.lean:158`, `:385`.
A `VVecEA2`'s disjuncts are `Σ n, VecEA2 n`; a `VBracketFormula`'s are `Σ n, BracketFormula n`.
**The splice cannot typecheck.** So the faithful route forces the whole sub-stack below the
`VecEA2.negFix` lift point (`VecEANegFix.lean:67`) to migrate to `VVecEA2`.

Scope of that sub-stack:

| File | Lines |
|---|---|
| `EANegationFix/BoundedFix.lean` | 864 |
| `EANegationFix/NegFix.lean` | 706 |
| `EANegationFix/NegFixOne.lean` | 563 |
| `EANegationFix/BoundedFixAnchored.lean` | 490 |
| `EANegationFix/ConcatPin.lean` | 127 |
| **Total** | **2,750** |

Seven `VBracketFormula`-producing definitions (`concatPin`, `negBoundedRightFix`,
`negBoundedLeftFix`, `trivialTrue`, `conjEverywhere`, `conjFull`, `negFixOne`) plus `negFixList`
and `BracketFormula.negFix` all sit inside it. And the plan's own constraint — *"Do not delete or
weaken the attained-carrier versions; the faithful versions are additions"* — means this is a
**parallel stack**, not an in-place edit.

Combinator layer, measured:

| `VVecEA2` combinator | Exists? |
|---|---|
| `disj` / `disj_holds` | yes (`VecEAFormula.lean:288`/`:292`) |
| `conjFull` / `conjFull_iff` | yes (`VecEAConjFull.lean:498`/`:510`) |
| `trivialTrue` | yes (`VecEAConjFull.lean:549`) |
| `enrichEndpoints`, `disjList`, `singleton`, `conjStruct` | yes |
| `prependAll` (endpoint-absorbing) | **no** — supplied by the probe as `prependAllVec` |
| `conjEverywhere` | **no** |
| `concatPin` | **no** |

So roughly half the combinator layer is already at `VVecEA2`. That is the good news, and it is why
I judge Phase 8 **feasible but badly mis-sized** rather than blocked.

**Recommendation**: do not dispatch Phase 8 as one phase. Re-split it before dispatch, exactly as
the inherited plan's own three-strikes guard directs when sizing signals appear. A defensible
decomposition, each unit ~100-500 lines:

1. Land the probe's Lemma 5.3 content into a live module (`negChainOnFaithful`,
   `VVecEA2.prependAllVec`, `orderedPointsExist_combine_kplus`, `orderedPointsExist_widen_left`,
   `negChainOnFaithful_iff`, `lemma53Faithful`). Sorry-free today. **This is Phase 7 and it is
   ready to execute from the probe.**
2. `VVecEA2.conjEverywhere` + `VVecEA2.concatPin` with `_holds` lemmas (the missing combinators).
3. `negBoundedRightFixFaithful` / `negBoundedLeftFixFaithful` (Cor 5.4, p.9) at `VVecEA2`.
4. The anchored mirrors (`BoundedFixAnchored`).
5. `negFixOneFaithful` (Lemma 5.1, `n = 1`).
6. `negFixListFaithful` — the 681-line recursion. **Expect this alone to span multiple dispatches**;
   it is the real cost centre and should carry its own sizing canary.
7. `BracketFormula.negFixFaithful` → `VecEA2.negFixFaithful` → `VVecEA2.negFixFaithful`.
8. `prop42_contentful_of_dedekind` — terminal fidelity milestone.

Stopping at any boundary above with an updated handoff is the correct outcome.

---

## 7. Arity cap: explicitly assessed, and it does **not** constrain Phases 7-8

The dispatch asked for an explicit answer either way. **It does not bind here.**

The adjudication (`specs/377_.../reports/06_kampprior-520-adjudication.md`) locates the obstruction
in the **Section 3/4** machinery: `charF` arity 1 (consumer, `KampPrior.lean:951`) vs `charFib`
arity 4 (producer, `InteriorHrealSupplyK.lean:64`), with `nf4_not_pathShaped` machine-proving the
arity-4 obligation is a `K₄` constraint graph, not a path. That report itself rules (line 179) that
this task is "**Mis-homing** … 378 is scoped to the **Section 5** carrier rebase … Related program,
wrong scope."

That ruling holds, and I can now say *why* on structural grounds rather than by deferring to it.
Rabinovich's caps are: Def 3.1 p.4 (point/interval types **one variable**), Lemma 3.2(2) p.4
(**at most two free variables**), Def 4.1 p.5 (expansion atoms **unary**). Every object Phases 7-8
touch sits inside all three:

| Object | Arity | Cap satisfied |
|---|---|---|
| `TemporalPred` (`ExistsForallNF.lean`) | 1 (bare `Formula` wrapper) | Def 3.1, Def 4.1 |
| `kplusPred` / `kplusFormula` | 1 | Def 4.1 (`K⁺` is a unary E[Σ]-atom) |
| `BracketFormula.holds … z0 z1` | 2 free | Lemma 3.2(2) |
| `VecEA2` (`endpointLeft`, `endpointRight`, `bracket`) | 2 free | Lemma 3.2(2) |
| `HasDedekindINF.first_occ` | `P` unary; `z₀`,`z₁` free; `r₀` **bound** | Lemma 3.2(2) |

`r₀` is existentially bound inside `Oₙ₊₁`, and p.8 states outright that *"∨∃⃗∀ formulas are closed
under conjunction, disjunction and the existential quantification"* — so binding it keeps the
formula in class at two free variables. No arity-3+ joint type arises anywhere in the Phase 7
probe, and none is needed for Phase 8: the whole `EANegationFix/` stack is `VecEA2`-shaped, i.e.
two free variables throughout.

**Verdict: the arity cap is a Section 3/4 boundary. Phases 7-8 stay strictly inside it.** It should
not be cited as a risk in the Phase 7-8 plan.

---

## 8. Three-strikes prohibition: not approached

The standing prohibition targets the model-**independent** Prop 4.2 backward direction at the
`BracketFormula` level. The named sites `EANegation.lean:1090`/`:1249` **no longer exist** (that file
is 694 lines); the content lives at `Boneyard/EANegationVBracketBackward.lean:452`/`:611`, which is
dead (reachable from nothing). Neither was read, cited, or touched.

Nothing in this research constitutes a fourth attempt: `negChainOnFaithful_iff` and the Phase 8
route are **carrier-anchored** (`HasDedekindINF`/`HasDedekindSUP`) throughout, exactly as
`BracketFormula.negFix_iff` is `HasAttainedINF`-anchored. The anchors are what make the direction go
through, which **confirms** the ruling rather than challenging it.

---

## 9. What I could NOT verify

Stated explicitly rather than asserted away.

1. **That Phase 8 closes at all.** I verified the *shape* of the obstruction (type migration, 2,750
   lines, 4 splice sites) and that the combinator layer is half-present. I did **not** prove any
   faithful analogue of `negFixList_iff`. `negFixList`'s Case 2/Case 3 gates are built around the
   attained pin and I did not attempt them. Phase 8 remains genuinely uncertain.
2. **Reachability of disjunct (2) in any concrete model.** I proved the converse — it is
   *unreachable* on Prior structures. Exhibiting a structure where `K⁺(P)(z₀)` actually holds needs
   a formalized non-attained Dedekind-complete chain (`ℝ`), which does not exist in this tree and
   which I did not build.
3. **`HasDedekindINF` vs bare Dedekind completeness, formally.** The claim that `HasDedekindINF` is
   strictly weaker than `HasDefinableINF` **is** machine-checked
   (`hasDefinableINF_incompatible_with_kplus`, `DedekindINF.lean:283`). The claim that it is
   strictly *stronger* than Rabinovich's bare Dedekind completeness is docstring prose only — there
   is no formalized notion of "Dedekind complete chain" in the tree to compare against. I did not
   build one.
4. **The `HasDedekindSUP` / Since-direction mirror of the gate.** The probe covers the `INF`/Until
   direction only. The mirror is expected to be symmetric (`HasDedekindSUP` and `kminus` are landed
   and dual), but I did **not** compile it. Phase 7's landing should include it.
5. **Whether any of the ~174 dead modules under `FormalSystem/` contain relevant prior art.** I
   searched `Kamp/Boneyard/` by name for the target declarations and found none, but did not audit
   the dead tree exhaustively.

---

## 10. Recommended next action

`/plan 378` with Phase 7 scoped to **landing the probe's content into a live module** (it is
sorry-free and axiom-clean today, so this is transcription plus the `SUP` mirror, not discovery),
and Phase 8 **re-split into the eight units of §6** before any implementation dispatch.

The probe is designed to be lifted nearly verbatim. Placement note: it must go somewhere **live**
(reachable from `FormalSystem.lean`), not `Boneyard/`. `DedekindINF.lean` already has the
`NfMultiAnchorBridge` import edge, so a sibling module imported the same way inherits CI protection;
`DedekindINF.lean` itself is a natural host since it already imports `Lemma53` (for `oOne`, `oZero`,
`allTopBracket`) and `PriorINF` (for `kplusFormula`). Adding one live module raises the job count by
exactly 1 (1883 → 1884) and the live-module count by 1 (269 → 270).
