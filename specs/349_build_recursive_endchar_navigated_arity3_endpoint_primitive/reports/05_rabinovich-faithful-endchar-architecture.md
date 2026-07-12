# Report 05 — Rabinovich-Faithful `endChar` Architecture (parameter-dependence-correct)

**Task**: 349 — build recursive `endChar : (k) → EndCharCarrier sig k` + `endChar_correct`
(navigated arity-3 endpoint primitive)
**Mode**: `--hard` (H2/H3/H4/H5), `--lit` (primary source: `rabinovich_2014`)
**Session**: sess_1783841542_df767b
**Reference grounding tier**: Tier 1 (literature-backed, lean4 strict) — grounded in
`~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.md`
(read in full, line numbers cited as `md:NNN`).

---

## 0. Executive summary

Three successive architectures (`navBrickForm` → `navMultiAnchorForm` → `navPieceForm`) have been
machine-refuted (report 04). The refutation is **parameter-independence**: a `Formula`-valued
converter fixed *before* the free anchors `(x,t)` are universally quantified is a **constant**
function of `(x,t)`, while its target `∃w, nf_eval_nf M k 4 [w,y,x,t] sub` is **non-constant** in
`(x,t)`. Constant ≢ non-constant, so the correctness biconditional is false for arbitrary anchors.

Rabinovich's proof of Kamp's theorem **never performs this collapse**. Its invariant, made precise
below, is: the object carrying ≥2 free variables is always the interval formula
`[α0,β1,…,αn](z0,z1)` which takes **both endpoints `z0,z1` as explicit free variables**; the
collapse to a single-point temporal formula (Proposition 3.5) happens **only when exactly one free
variable remains**. Navigation introduces a fresh point `r0 = inf{…}` that is existentially bound
and **immediately re-anchors an endpoint** — it is never a third free variable (Lemma 5.3, md:233–247).

The corrected Lean architecture mirrors this exactly and is **already ~80% green in named assets**:
- Keep the ≥2-anchor object **Prop-valued with `x,t` as explicit arguments** —
  `nf_zone_flatten_navigable(_correct)` (Base.lean:667/687), whose correctness has `x,t` on *both*
  sides and is therefore immune to the constant-vs-non-constant refutation.
- Reduce the arity-4 inner existential to a **≤2-free-anchor (≤ arity-3) conjunction FIRST** via
  Rabinovich Lemma 3.2(2) = `nfEval_le2_reduction` (Lemma32Reduction.lean:535) / `navPiece_reduce`
  (NavigatedEndChar.lean:215), **before** any Formula conversion.
- State `endChar_correct` at **every** `k` with the **anchor-residual hypothesis `h_res`** that
  pins the non-position-0 atoms (generalizing the already-green `endChar0_correct`, Base.lean:1056).
  `h_res` is the Lean encoding of Rabinovich's "the anchor layer is supplied by the enclosing
  bracket witnesses". **Without `h_res` the statement is the refuted `endCharN0_correct_infeasible`
  (Base.lean:1779); with it, `k=0` is green.**
- Collapse to a closed `Formula`/`TemporalPred` **only at `endChar0`** (base, ≤1 free locus via
  `nf3_locus0`), the Proposition 3.5 analog.

**FORBIDDEN and to be deleted from the critical path**: `nf_char3_endpoint_tl` with a
`Formula`-valued `innerConv` fixed before `∀ y x t` (Base.lean:869/885) — this is the exact defect
site; `navPieceForm` as an inner *converter* (its `navPiece_reduce` reduction is retained, its
`_correct` is a non-theorem and must not be stated); `nf_char3_deeper_split` (Base.lean:603,
arity-4 collapse); per-pair `∀ij∃w` distribution; arity-collapsing `nfRestrict`.

**Honest feasibility verdict (H4)**: the corrected correctness statement **survives** every
constant-vs-non-constant / world-locality test that killed the prior three (§5). The **one
remaining open obligation** is *residual threading* — whether the `k+1` step can supply `h_res` for
its sub-pieces from its own `h_res` plus the bracket-exterior navigation. This is **not** a
non-theorem (the base case proves the mechanism; `nf_zone_flatten_navigable_correct` proves the
x,t-explicit flatten), but it is **not yet proven for the step** → **FEASIBLE-PENDING-RESIDUAL-THREADING**,
not GREEN. Confidence Medium-High. Details in §5 and Phase 4.

---

## 1. Faithful reconstruction of Rabinovich's construction (Tier-1, cited)

### 1.1 The three-level type discipline that bounds free variables

Rabinovich's normal form is the `∃∀`-formula (Definition 3.1, md:109–111, paper p.4):

> a prefix of `n+1` existential quantifiers, all `αj, βj` quantifier-free **with one variable**,
> and `m+1` free variables `z0,…,zm`.

The witnesses (`n+1` existentials) are **bound points**; the `zj` are the **free variables**. The
entire proof is organized so that three distinct operations happen at three distinct free-variable
counts:

| Free vars | Operation | Paper | Lean analog (green) |
|---|---|---|---|
| any `n` | reduce to ≤2-free conjunction | **Lemma 3.2(2)** (md:119) | `nfEval_le2_reduction` (Lemma32Reduction.lean:535) |
| exactly **2** | **negation / navigation** (the hard part) | **Prop 4.2 + §5** (md:165, 195–335) | `nf_zone_flatten_navigable(_correct)` (Base.lean:667/687) |
| exactly **1** | **collapse to a temporal formula** | **Prop 3.5** (md:137–143) | `endChar0` / `endCharNav0_correct` (Base.lean:995; NavigatedEndChar.lean:118) |

The load-bearing fact — **and the one the three refuted architectures violated** — is that the
collapse to a single-point temporal formula (Proposition 3.5, md:137: "Every `∨∃∀`-formula with
**one free variable** is equivalent to a `TL(Until,Since)` formula") is applied **only at one free
variable**. Everything with two free variables stays an `∃∀`-formula, i.e. a predicate over its two
explicit endpoints; it is **never** read as a closed formula at a single point.

### 1.2 §5: the interval formula keeps both endpoints explicit

Notation 5.2 (md:219, p.7) writes the two-free-variable `∃∀`-formula as
`[α0, β1, α1, β2, …, αn−1, βn, αn](z0, z1)`. Its meaning (unpacked at md:263, Cor 5.4 proof):

> there is an increasing sequence `z0 < x1 < ··· < xn < z1` with `αi(xi)` and `βi` holding along
> each open sub-interval.

`z0` and `z1` are the **enclosing pair**; the `αi` are point predicates at the intermediate
(bound) points `xi`; the `βi` are "holds-along-the-interval" predicates. **Both `z0` and `z1`
appear as explicit free variables of the formula at all times.**

**Navigation = re-anchoring, never a third free variable.** In Lemma 5.3 (md:225–247, p.8), the
induction `n ↦ n+1` computes

> `r0 = inf{z ∈ (z0,z1) | P1(z)}` (exists by Dedekind completeness, md:233),

which is **definable by a `∨∃∀` formula `INF(z0,r0,z1,P1)`** (md:245), then **recurses with
`On(P2,…,Pn, r0, z1)`** (md:237): the past endpoint `z0` is **replaced by the navigated point
`r0`**. The witness `r0` is existentially bound and instantly becomes the new endpoint. The
free-variable count stays exactly 2. This is the exact template for "the escape is *referencing the
anchors directly*, produced by navigation, not carried by a free parameter" (report 02 §S2).

**Interval splitting = adjacent two-endpoint pieces glued by a bound point.** Lemma 5.1 / Figure 1
(md:297–299, p.10):

> `B2(z0, z, z1) := [α0,β1,α1,β2,β2](z0, z) ∧ [β2,β2,α2,β3,α3](z, z1)`

An intermediate `z` (bound by `∃z`) **splits** `(z0,z1)` into two two-endpoint interval formulas
sharing endpoint `z`. The full negation (md:285–335) does casework on whether the first
`¬β1`-point `r0 = inf{z ∈ (z0,z1) | ¬β1(z)}` exists (`INF^{¬β1}`, eq (5.3), md:301–303), navigating
to `r0` and recursing — again re-anchoring, never adding a free variable. §7 Lemma 7.6 (md:413)
makes the gluing explicit: if `ϕ1` is a `(z0,z1)`-formula and `ϕ2` a `(z1,z2)`-formula, then
`(∃z1)_{z0}^{z2}(ϕ1 ∧ ϕ2)` is a `(z0,z2)`-formula.

### 1.3 The Cor 5.4 endpoint chain (the recursion motive)

Cor 5.4 (md:255–279, p.9) builds the characteristic by the descending chain (md:261, report 02):

```
F_n     := α_n
F_{i-1} := α_{i-1} ∧ (β_i Until F_i)
```

Each `F_i` is a **single-point** predicate at the endpoint `xi`; the interior between `x_{i-1}` and
`xi` is the **`β_i` segment**, a quantifier-free "holds-along" predicate — **not** the recursive
characteristic (report 02 §S3). The recursive characteristic sits **at the endpoint**, never
smeared across the interior.

### 1.4 Mapping the enclosing-pair/interval decomposition to the Lean anchor structure

| Rabinovich (§5) | Lean (arity-3, env `[·, x, t]`) |
|---|---|
| enclosing pair `(z0, z1)` | free anchors `(x, t)` — the two positions `1,2` of `zoneEnv3 · x t` |
| interval `(z0, z1)` | open interval `{y : x < y < t}` |
| bound intermediate point `xi` (`∃xi`) | bracket witness `y`/`w` at position 0 (`Fin.cons`), never a free anchor (G2/G4) |
| point predicate `αi(xi)` at endpoint | `endChar k`-locus at the read point (`endChar0` at base) |
| interval predicate `βi` (holds-along) | `seg` interior segment (Base.lean:1127), non-trivial (G3) |
| navigate `r0 = inf/sup`, re-anchor `z0 ↦ r0` | `bracketBuildLeft/Right` exterior reach; the past/future endpoint hooks of `nf_zone_flatten_navigable` |
| split `B2(z0,z,z1)` at bound `z` | five-zone split of `nf_zone_flatten_navigable` (past ∨ at-x ∨ interior-∃w ∨ at-t ∨ future) |
| glue `(∃z1)(ϕ1∧ϕ2)` (Lemma 7.6) | composition of adjacent zones in the five-zone disjunction |
| collapse to TL at **one** free var (Prop 3.5) | `endChar0` closed `TemporalPred` at base only |

`nf_eval_nf` env convention (NormalForm.lean:198): position 0 is the read/navigated point;
enclosing anchors follow in the tail; a fresh witness is prepended at position 0 via `Fin.cons w
env` (so `[y,x,t]` → `[w,y,x,t]` descending one depth). Thus **arity-3 = read-point + 2 free
anchors {x,t}** — an exact match to Rabinovich's "navigated point inside the enclosing pair
`(z0,z1)`".

---

## 2. The refutation, restated at the source level (why the prior three died)

`nf_char3_endpoint_tl_correct` (Base.lean:885) quantifies `(y x t : M.carrier)` **outside** a
`Formula`-valued `innerConv : NormalForm sig k 4 → Formula` chosen **before** `x,t`, and demands
(the `h_inner` obligation, Base.lean:893):

```
h_inner : ∀ sub, temporal_truth M atomMap y (innerConv sub) ↔
                 ∃ w, nf_eval_nf M k 4 (Fin.cons w (zoneEnv3 y x t)) sub
```

- LHS `L(x,t) := temporal_truth M atomMap y (innerConv sub)` — `innerConv` does not take `x,t`;
  `Formula` captures no carrier values → **constant** in `(x,t)`.
- RHS `R(x,t) := ∃ w, nf_eval_nf M k 4 [w,y,x,t] sub` — pins predicate atoms at positions 2,3
  (`x,t`) → **non-constant** in `(x,t)`.

`∀ x t, (L ↔ R)` is false (report 04 §2.1). This is `endCharN0_correct_infeasible` (Base.lean:1779)
one arity up. In Rabinovich terms: it applies the **Proposition 3.5 collapse** (single-point TL
formula) to an object with **two** free variables `(x,t)` — forbidden; Prop 3.5 requires exactly
one.

`navPieceForm : (NormalForm sig k 3 → TemporalPred) → NormalForm sig k 4 → Formula`
(NavigatedEndChar.lean:196) is precisely such a fixed `Formula` converter; its `navPiece_reduce`
(the arity-4 → nfEvalRHS *reduction*, NavigatedEndChar.lean:215) is **green and retained**, but its
`_correct` (the biconditional with the single-point read) is the **non-theorem** and must never be
stated.

---

## 3. Corrected Lean architecture

### 3.1 Types (frozen `EndCharCarrier` respected)

```lean
-- FROZEN (Base.lean:1007), unchanged:
abbrev EndCharCarrier (sig : MonadicSignature) (k : Nat) : Type :=
  NormalForm sig k 3 → TemporalPred

-- Deliverable:
noncomputable def endChar {sig} (atomMap) (h_surj) : (k : Nat) → EndCharCarrier sig k
```

`endChar k qnf : TemporalPred` is a **closed** single-world object. It characterizes a multi-anchor
target **only through navigation** (`bracketBuild*` reaching `x,t` from the read point via the
order) **plus the residual `h_res`** that pins the anchor layer — exactly as `endChar0_correct`
(green) already does at `k=0`. The frozen carrier is compatible with the fix because the correctness
statement is **residual-conditioned**, not unconditional.

### 3.2 The correctness statement at every `k` (generalizes the green `endChar0_correct`)

```lean
theorem endChar_correct {sig} (M) (atomMap)
    (h_surj : ∀ p, ∃ a : Atom, atomMap (.atom a) = p) :
    ∀ (k : Nat) (qnf : NormalForm sig k 3) (w x t : M.carrier)
      (h_res : ∀ atom : AtomKind sig 3, (∀ p, atom ≠ AtomKind.pred p 0) →
        (atom_eval M (zoneEnv3 w x t) atom ↔ (qnf atom = true))),
    (endChar atomMap h_surj k qnf).eval_at M atomMap w ↔
      nf_eval_nf M k 3 (zoneEnv3 w x t) qnf
```

This is `endChar0_correct` (Base.lean:1056) with `k` generalized. **`h_res` is the ≤2-free-anchor
discipline made concrete**: the anchors `x,t` appear on the RHS but are *pinned* by `h_res`
(supplied by the enclosing bracket witnesses), never free-and-uncoupled. Under `h_res` the RHS's
`x,t`-dependent atoms are fixed to `qnf`'s constant bits, so the biconditional is between a function
of `w` (LHS) and a function of `w` (pinned RHS) — **consistent**, and green at the base.

### 3.3 The recursion (`Nat.rec` on `k`, arity fixed at 3)

```
endChar 0       qnf = endChar0 atomMap h_surj qnf                     -- Prop 3.5 collapse, ≤1 free
endChar (k+1)   qnf = endCharStep (endChar k) qnf                     -- new builder (§3.4)
```

The arity index is **fixed at 3** (frozen carrier); the depth `k` descends. This is faithful to
Rabinovich's structural induction (Prop 4.3, md:171–181) with the two-endpoint interval as the
invariant motive.

### 3.4 `endCharStep` — the replacement for `nf_char3_endpoint_tl` (the fix)

`endChar (k+1) qnf : TemporalPred` must, read at `w` under `h_res`, characterize
`nf_eval_nf M (k+1) 3 [w,x,t] qnf`, which unfolds (NormalForm.lean:198) to:

1. **atom layer** at `[w,x,t]` — position-0 locus (endChar0-style) + `h_res` for positions 1,2;
2. per `sub : NormalForm sig k 4`, the **arity-4 inner existential**
   `(∃v, nf_eval_nf M k 4 [v,w,x,t] sub) ↔ qnf.2 sub`.

The **fix** discharges (2) in Rabinovich order:

- **Step A — Lemma 3.2(2) FIRST (reduce arity before any Formula conversion).** Apply
  `navPiece_reduce` (NavigatedEndChar.lean:215) / `nfEval_le2_reduction` (Lemma32Reduction.lean:535):
  ```
  (∃v, nf_eval_nf M k 4 [v,w,x,t] sub) ↔ (∃v, nfEvalRHS M k 4 [v,w,x,t] sub)
  ```
  where `nfEvalRHS` is a finite conjunction of `nf_eval_nf` facts each of **anchor arity ≤ 3**
  (≤ 2 free anchors + read point). This is the ≤2-free-variable cap of Lemma 3.2(2), md:119.
- **Step B — characterize each ≤2-anchor conjunct with `x,t` EXPLICIT (Prop-valued).** Use
  `nf_zone_flatten_navigable_correct M atomMap x t pastEnd futureEnd q` (Base.lean:687), whose LHS
  `(∃w, nf_eval_nf M k 3 [w,x,t] q)` and RHS both carry `x,t` **explicitly** → immune to the
  refutation. The endpoint hooks are `pastEnd := endChar k`, `futureEnd := endChar k`; their
  correctness `h_past`/`h_fut` **is the depth-`k` IH `endChar_correct k`** (residual form) at the
  navigated witness.
- **Step C — interior segment.** The bounded interior rides `seg` via `seg_holds_coupled`
  (Base.lean:1150), whose `h_endChar` hook is again `endChar_correct k`. The interior predicate is
  the genuine `endChar k qnf` (G3: non-trivial, never `TemporalPred.top`).
- **Step D — collapse only at the base.** The position-0 atom layer is `endChar0`'s locus
  (`nf3_locus0`); anchors pinned by `h_res`. This is the single-free-variable Proposition 3.5
  collapse — the **only** place a closed `Formula` is read.

`endCharStep (rec) qnf` is therefore assembled from `bracketBuildLeft/Right` (navigation) + `seg`
(interior) + the position-0 locus, with **`x,t` flowing as explicit parameters of the Prop-valued
`nf_zone_flatten_navigable` at every ≥2-anchor level**, and no `Formula`-valued converter fixed
before the anchors.

### 3.5 Green assets consumed, by name

| Asset | File:line | Role in the fix | Status |
|---|---|---|---|
| `nfEval_le2_reduction` | Lemma32Reduction.lean:535 | Step A — Rabinovich Lem 3.2(2) arity-4→≤3 | GREEN (task 351) |
| `navPiece_reduce` | NavigatedEndChar.lean:215 | Step A specialization (witness-outside) | GREEN |
| `nfEval3_reduction` | NavigatedEndChar.lean:75 | arity-3 reduction specialization | GREEN |
| `nf_zone_flatten_navigable` | Base.lean:667 | Step B — Prop-valued, x,t explicit | GREEN |
| `nf_zone_flatten_navigable_correct` | Base.lean:687 | Step B correctness (x,t on both sides) | GREEN |
| `nf_zone_flatten_navigable_brick` | Base.lean:813 | Step B one-line corollary | GREEN |
| `seg` / `seg_holds_correct` / `seg_holds_coupled` | Base.lean:1127/1136/1150 | Step C — β-segment interior (G3) | GREEN |
| `endChar0` | Base.lean:995 | Step D — Prop 3.5 collapse (base) | GREEN |
| `endChar0_correct` | Base.lean:1056 | base case of `endChar_correct` (`h_res` shape) | GREEN |
| `endCharNav0_correct` | NavigatedEndChar.lean:118 | reduced-RHS base (composes with nfEval3_reduction) | GREEN |
| `nf3_locus0` / `nf_depth0_char_formula(_correct)` | Base.lean:982/999 | position-0 locus | GREEN |
| `endCharN0_correct_infeasible` | Base.lean:1779 | negative guardrail (no-`h_res` refutation) | GREEN (refutation) |

**Deleted from the critical path (FORBIDDEN):** `nf_char3_endpoint_tl` + Formula-`innerConv`
(Base.lean:869/885 — the defect site), `navPieceForm` as inner converter,
`navPieceForm_correct` (must not be stated), `nf_char3_deeper_split` (Base.lean:603).

---

## 4. Faithfulness mapping table (H3, 5-column)

| Rabinovich construct (paper §/lemma) | Role | Lean target (name) | Green asset consumed | Guard compliance (G1–G5) |
|---|---|---|---|---|
| Def 3.1 `∃∀`-formula, md:109 | normal form, n+1 bound witnesses | `NormalForm sig k 3` (arity-3 = read-pt + 2 anchors) | `nf_eval_nf` (NormalForm.lean:198) | G1: arity fixed 3, no arity-1 collapse |
| Lemma 3.2(2) ≤2 free vars, md:119 | reduce arity-n → ≤2-free conjunction | Step A of `endCharStep` | `nfEval_le2_reduction` (Lemma32Reduction:535), `navPiece_reduce` (NavEndChar:215) | G2/G4: witness `v` stays bound; anchors ⊆ {x,t}, ≤2 |
| Prop 4.2 + §5 negation/navigation at 2 free, md:165/195 | two-endpoint characterization | Step B of `endCharStep` | `nf_zone_flatten_navigable(_correct)` (Base:667/687) | G2/G4: x,t explicit on both sides, ≤2 free |
| §5 Notation 5.2 `[…](z0,z1)`, md:219 | enclosing-pair interval formula | `nf_zone_flatten_navigable M atomMap x t …` | Base:687 (x,t = z0,z1) | G4: x,t are the enclosing pair, not a 3rd anchor |
| Lemma 5.3 `r0=inf`, re-anchor, md:233–247 | navigate + re-anchor endpoint | `bracketBuildLeft/Right` exterior hooks (`pastEnd`/`futureEnd`) | `nf_zone_flatten_navigable_correct` h_past/h_fut | G2/G4: `w` bracket witness, never free |
| Cor 5.4 chain `F_{i-1}:=α_{i-1}∧(β_i Until F_i)`, md:261 | endpoint characteristic chain | `endChar k` recursion hook | `endChar_correct k` (IH) | G5: manual `or_congr`/`exists_congr`, no simp shortcut |
| Cor 5.4 `β_i` interval predicate, md:263 | interior "holds-along" segment | `seg` interior | `seg_holds_coupled` (Base:1150) | G3: `seg` interior = `endChar qnf`, never `⊤` |
| Lemma 5.1 / Fig 1 split `B2(z0,z,z1)`, md:297 | interval split at bound `z` | five-zone split of flatten | `nf_zone_flatten_navigable` (Base:667) | G1: env arity stays 3 across zones |
| §7 Lemma 7.6 glue `(∃z1)(ϕ1∧ϕ2)`, md:413 | compose adjacent intervals | zone composition in flatten | Base:687 | G4: shared endpoint `z1` bound |
| Prop 3.5 collapse at **1** free, md:137 | TL formula at one point | `endChar0` (base only) | `endChar0_correct` (Base:1056), `endCharNav0_correct` (NavEndChar:118) | G1: collapse only at base, ≤1 free locus |

---

## 5. Adversarial self-verification (H4)

Every load-bearing claim was re-challenged with the **same** constant-vs-non-constant /
world-locality tests that refuted `navBrickForm`/`navMultiAnchorForm`/`navPieceForm`.

### 5.1 Claim Verification Table

| # | Claim | Adversarial counterexample attempted | Verification method | Confidence |
|---|---|---|---|---|
| 1 | `nf_zone_flatten_navigable_correct` is immune to the parameter-independence refutation | Try: is either side constant in `(x,t)` while the other is not? | `lean_hover_info`/read Base.lean:687–706: **both** `(∃w, nf_eval_nf M k 3 (zoneEnv3 w x t) q)` and `nf_zone_flatten_navigable M atomMap x t … q` take `x t` explicitly → both non-constant. GREEN, proof body present. | High |
| 2 | Residual-conditioned `endChar_correct` at `k=0` is a theorem, not a non-theorem | Try the report-04 refutation: drop `h_res`, choose `qnf(.pred p 1)=true` while `M.interp p x=false` | Read Base.lean:1036–1064: `endChar0_correct` **with `h_res`** is GREEN; `endCharN0_correct_infeasible` (Base.lean:1779) refutes the **no-`h_res`** form. The discriminator is exactly `h_res`. | High |
| 3 | Arity-4 inner existential reduces to ≤2-free-anchor conjunction before any Formula conversion | Try: does the reduction smuggle a single-point read? | Read NavigatedEndChar.lean:215 + Lemma32Reduction.lean:535: `navPiece_reduce`/`nfEval_le2_reduction` are `Iff` between two `nf_eval_nf`/`nfEvalRHS` **Props** (witness `v` stays existential, outside) — no `temporal_truth … Formula` on either side. GREEN. | High |
| 4 | Step B endpoint hooks `h_past`/`h_fut` are dischargeable by the IH (not a hidden constant-vs-non-constant) | Try: `pastEnd q = endChar k q` is closed → is `(endChar k q).eval_at w ↔ nf_eval_nf M k 3 [w,x,t] q` a `navPieceForm`-style non-theorem? | Analysis: it **would** be, *unless* conditioned by a residual for positions 1,2. The hook must be discharged as `endChar_correct k` **with a residual threaded from the enclosing bracket exterior**, not the bare unconditional form. This is the open obligation (row 6). Not refuted; not yet proven. | Medium |
| 5 | `seg` interior via `seg_holds_coupled` is faithful and non-trivial (G3) | Try report-02 §Q2: is the interior `BracketFormula.trivial (rec sub)` (endpoint-in-interior divergence)? | Read Base.lean:1127–1162: `seg` interior type is `endChar qnf` (the genuine interior characteristic), coupled via `h_endChar`. The report-02 divergence was the *Phase-4 `BracketFormula.trivial (rec sub)`* pattern, which this architecture does **not** use. GREEN. | High |
| 6 | **The whole `k+1` step is feasible (residual threads through the recursion)** | Try: can `endCharStep`'s invocation of `endChar_correct k` on sub-pieces obtain their `h_res` from its own `h_res` + bracket-exterior structure? | **NOT machine-verified.** The base case (row 2) proves the mechanism; `nf_zone_flatten_navigable_correct` (row 1) proves the x,t-explicit carrier; but the *threading* of `h_res` from level `k+1` to the sub-pieces at level `k` is unproven. **This is the sole feasibility gate.** No refutation exists (unlike the Formula-converter path). | Medium |
| 7 | Frozen `EndCharCarrier` (TemporalPred-valued) is compatible with the fix | Try: a closed `TemporalPred` cannot reference `x,t`, so isn't every arity-≥2 characterization doomed? | Base.lean:1056 (`endChar0_correct`) demonstrates a **closed** `TemporalPred` characterizing a 2-anchor eval **under `h_res`** via navigation. Compatible. The carrier need not change. | High |

### 5.2 Contradiction log

**Apparent contradiction** (precedence-resolved): Report 04 concludes "any `Formula`-valued
converter read at one point characterizing a ≥2-free-anchor target is a non-theorem"; yet this
architecture uses a **closed `TemporalPred`** `endChar k qnf` read at a point. Resolution
(precedence: machine-checked green asset > analysis): the discriminator is the **residual
hypothesis `h_res`** and **explicit `x,t` on the Prop-valued flatten**. `endChar0_correct` (green,
Base.lean:1056) is a closed `TemporalPred` read at a point characterizing a 2-anchor eval **under
`h_res`** — so the report-04 prohibition applies specifically to the **unconditional, x,t-implicit**
form (`nf_char3_endpoint_tl`'s `h_inner`, `navPieceForm_correct`), **not** to the residual-
conditioned form. No unresolved contradiction. The report-04 non-theorem and this proposal are
consistent: they differ exactly on `h_res` + x,t-explicitness.

**UNRESOLVED (flagged, not a contradiction, an open obligation)**: row 6 residual-threading. The
resolving check not yet performed: a `lean_multi_attempt`/`lean_goal` construction of the `k+1`
step showing `h_res` at level `k+1` yields `h_res` for each ≤2-anchor sub-piece. **Downstream
risk**: if threading fails, Phase 4 is `[BLOCKED]` (escalate, do not stub) — but this is a
*proof-engineering* risk on a well-typed, non-refuted statement, categorically different from the
three prior *non-theorem* dead-ends.

### 5.3 Recommendations modified after verification

- Downgraded the step from "GREEN/feasible" to **FEASIBLE-PENDING-RESIDUAL-THREADING** (row 6).
- Elevated `h_res` from an implementation detail to the **central invariant** of every correctness
  statement (rows 2, 4, 7): the plan must state `endChar_correct` with `h_res` at *every* `k`, never
  the unconditional form.
- Confirmed `navPiece_reduce` is **retained** (Step A) even though `navPieceForm` (the converter)
  and `navPieceForm_correct` are forbidden — they are different objects (row 3).

---

## 6. Phase breakdown for `/revise` (v5)

Each phase ≈ one agent-run (100–500 lines). **PRESERVED** = do not rebuild; **CHANGE/NEW** =
revision target.

### PRESERVED (Phase-1/2 + green machinery — do NOT rebuild)
- `nfEval3_reduction` (NavigatedEndChar.lean:75), `endCharNav0_correct` (NavigatedEndChar.lean:118)
  — the delegation's "Phase-1/2 assets already GREEN". **Preserve verbatim.**
- `endChar0` / `endChar0_correct` (Base.lean:995/1056), `endChar0_wlocus_correct` (Base.lean:1015).
- `seg` / `seg_holds_correct` / `seg_holds_coupled` (Base.lean:1127/1136/1150).
- `nf_zone_flatten_navigable` / `_correct` / `_brick` (Base.lean:667/687/813).
- `nfEval_le2_reduction` (Lemma32Reduction.lean:535), `navPiece_reduce` (NavigatedEndChar.lean:215).
- `nf3_locus0`, `nf_depth0_char_formula(_correct)`, `atomPartN`, `EndCharCarrier` (frozen type),
  `endCharN0_correct_infeasible` (negative guardrail).

### MUST CHANGE (v4 Phase 3–5 → v5)

**v5 Phase 1 — Spec freeze (≈100–150 lines).** State `endChar_correct` (§3.2) as the
residual-conditioned biconditional at general `k`, and the `endChar : (k) → EndCharCarrier` skeleton
with `endChar 0 = endChar0`. Prove the **base case** by `exact endChar0_correct …` (already green).
Leave the step as a named hole to be filled in Phase 3. Deliverable: types + base + statement
compile; no `sorry` in the base. *(Replaces v4 Phase-3 interface, which was built on the defective
`nf_char3_endpoint_tl`.)*

**v5 Phase 2 — `endCharStep` Step A (≈150–250 lines).** Build the arity-4 → nfEvalRHS reduction
wiring inside the step: for each `sub : NormalForm sig k 4`, apply `navPiece_reduce` /
`nfEval_le2_reduction` to expose the ≤2-free-anchor conjunction. Prove the reduction lemma the step
consumes. **Guard**: no `Formula`-valued converter yet; witness `v` stays existential (G2/G4).
*(This is where v4 went wrong by converting to `Formula` first; here reduction is first.)*

**v5 Phase 3 — `endCharStep` Steps B–D + step correctness (≈300–500 lines).** Assemble
`endCharStep (endChar k) qnf : TemporalPred` from `nf_zone_flatten_navigable` (x,t explicit) +
`seg` interior + position-0 locus. Prove the `k+1` case of `endChar_correct`, discharging
`h_past`/`h_fut`/`h_endChar` from the IH `endChar_correct k` **with the threaded residual** (the
row-6 obligation). **This phase is the feasibility gate**: if the residual cannot be threaded
through the bracket exteriors, mark `[BLOCKED]`, document the exact goal state, escalate — **do NOT
stub with `sorry` or a vacuous def**. *(Replaces v4 Phases 3b/4/5.)*

**v5 Phase 4 — Recursion close + audit (≈100–200 lines).** Define `endChar` by `Nat.rec` (base
`endChar0`, step `endCharStep`), prove `endChar_correct` by induction on `k` (base + step from
Phases 1/3). Whole-project `lake build`; axiom audit (`lean_verify` — expect only `propext`,
`Classical.choice`, `Quot.sound`; **no new axioms, no `sorry`**). Confirm G1–G5 and the FORBIDDEN
list are absent from the final term.

### Wave / territory note
Phases are **sequential** (each depends on the prior's `endChar_correct` shape). Territory: additive
edits to `Base.lean` (new `endCharStep`, `endChar`, `endChar_correct`) and `NavigatedEndChar.lean`;
**no edits** to the seven frozen providers, `KampPrior.lean`, `Lemma32Reduction.lean`, or
`nf_nvar_exist_all_depths`'s signature.

---

## 7. Memory candidates

1. Rabinovich's proof of Kamp's theorem enforces a strict three-level free-variable discipline:
   Lemma 3.2(2) reduces to ≤2 free variables (md:119), Prop 4.2/§5 does negation/navigation **only
   at 2** free variables keeping both endpoints `(z0,z1)` explicit (md:165/219), and Prop 3.5
   collapses to a single-point temporal formula **only at 1** free variable (md:137). A Lean port
   must mirror this: the ≥2-anchor object is Prop-valued with anchors explicit; the closed-formula
   collapse happens only at the ≤1-anchor base.
2. The refutation that killed `navBrickForm`/`navMultiAnchorForm`/`navPieceForm` is escaped **not**
   by changing the converter's internals but by (a) reducing arity **first** (Rabinovich Lem 3.2(2)
   = `nfEval_le2_reduction`) and (b) conditioning the correctness biconditional on an
   anchor-residual `h_res` that pins the non-read-point atoms. `endChar0_correct` (green, with
   `h_res`) vs `endCharN0_correct_infeasible` (refuted, without `h_res`) is the exact discriminator.
3. `nf_zone_flatten_navigable_correct` (Base.lean:687) is the faithful ≤2-free, Prop-valued,
   x,t-explicit enclosing-pair merge (= Rabinovich `[…](z0,z1)`); its endpoint hooks are the depth
   recursion IH. It is **not** a new bridge lemma to spawn — it already exists and is green.

---

## 8. Verification status

- Reference tier: **Tier 1** applied; 5-column faithfulness table present (§4).
- Adversarial verification (H4): **triggered**; Claim Verification Table + Contradiction Log (§5).
  One statement downgraded to FEASIBLE-PENDING-RESIDUAL-THREADING; no claim asserted GREEN beyond
  machine-checked assets.
- H5 divergence audit context: root cause (Formula-collapse-before-≤1-free) identified and mapped to
  the corrected phase plan (§6); the corrected lean-ready target is the residual-conditioned
  `endChar_correct` (§3.2), not a new arity-4 bridge.
- Zero-debt: no `sorry`/axiom recommended; Phase 3 feasibility gate escalates to `[BLOCKED]` rather
  than stub if residual threading fails.
