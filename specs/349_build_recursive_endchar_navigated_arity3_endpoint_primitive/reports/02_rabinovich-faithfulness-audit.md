# Report 02 — Rabinovich Faithfulness Audit of `blk-349-p5-inner-navresidual` (task 349, H5 divergence audit)

- **Task**: 349 — Build the recursive navigated arity-3 endpoint primitive `endChar` + `endChar_correct`
- **Type**: lean4 (hard-mode; H2 anti-analysis, H3 reference grounding, H4 adversarial self-verification, H5 divergence audit)
- **Session**: sess_1783824622_947f0b
- **Reference grounding tier**: Tier 1 (literature-backed — Rabinovich 2014, `--lit` ground truth)
- **Blocker under audit**: `blk-349-p5-inner-navresidual`; verbatim open goal `NavResidual M sub (Fin.cons (env 0) env)`
- **Primary source (read in full this session)**: `~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.md` (lines 1–495)
- **Lean assets source-read this session**: `Base.lean:150-206` (`nf_char2_diag_exist_tl`/`_correct`, the template), `Base.lean:655-706` (original arity-3 `nf_zone_flatten_navigable`/`_correct`), `Base.lean:741-786` (`A_diag`/`_correct`), `Base.lean:1608-1633` (`NavResidual`, `navResidual_base_eq_hRes`), `Base.lean:1658-1710` (`nfN_locus0`, `endCharN0`, `endCharN0_wlocus_correct`), `Base.lean:1780-1899` (`navBrickForm`/`_correct`, `atomPartN`, `nf_endpoint_tl_gen`/`_correct`)

---

## BOTTOM LINE (read first)

**`/revise 349` IS warranted.** Unblock option **A as written is FAITHFUL-in-part but NOT unblocking**;
option **B is forbidden AND insufficient**; the correct fix is a **superset of C** that reopens
Phases 2, 3 **and** 4.

The blocker's local diagnosis ("nothing supplies `NavResidual M sub (Fin.cons w' env)`") is correct
but **under-deep**. The root divergence is **not** the missing residual and **not** primarily the
`rec sub` interior. It is that **`navBrickForm` is structurally the DIAGONAL converter
`nf_char2_diag_exist_tl` (Base.lean:168) — a SINGLE-anchor object valid only when all anchors coincide
at one point — reused for a GENERAL MULTI-ANCHOR target** `∃ w', nf_eval_nf M k (n+1) (Fin.cons w' env) sub`
where `env` is `n` *distinct* anchors. A `Formula` evaluated at the one accessible anchor `env 0`
**provably cannot** certify the predicate layer at the other `n-1` anchors (it cannot read
`M.interp p (env j)` for `j ≥ 1`), and for the **universally-quantified** `sub` of the quant layer that
predicate layer is arbitrary. `NavResidual` papers over this by *assuming* the anchor layers match —
an assumption that is FALSE for most `sub`, while the biconditional the quant layer needs is
**unconditional**. Option A relocates that false assumption from the IH onto the brick's own
forward-direction proof, where it is the *same* non-theorem.

**Faithful fix**: the inner converter must be a **multi-anchor navigating characteristic** (nested
`Since`/`Until` that reaches each enclosing anchor, matching the FULL-eval hook shape of the *green*
arity-3 `nf_zone_flatten_navigable`, Base.lean:687-697), so the anchor layer is **discharged by the
navigation** rather than assumed. Only then does a per-witness `NavResidual` (option A) become
dischargeable — the navigation *establishes* it. Single-anchor + option A never closes.

---

## Rabinovich construction — what the source actually says

The navigated decomposition lives in **Corollary 5.4** (md:255-279) and **Lemma 5.1 / Lemma 5.3**
(md:207-335). The chain (md:261-263, transcribed):

```
F_n     := α_n
F_{i-1} := α_{i-1} ∧ (β_i Until F_i)
```

with the characterization (md:263): `∃ z ∈ (z0,z1). [α0,β1,α1,…,αn](z0,z)` iff `F0(z0)` **and** there
is an increasing sequence `x1 < … < xn` in `(z0,z1)` with `Fi(xi)`.

Three structural facts read directly off the source, each load-bearing for the adjudication:

**(S1) The characterization is bounded to ≤ 2 free variables — always exactly `(z0, z1)`.** Lemma
3.2(2) (md:119): "Every `∃∀`-formula is equivalent to a conjunction of `∃∀`-formulas with **at most
two free variables**." Proposition 4.2 (md:165) and all of §5 (Lemma 5.1, Cor 5.4, Notation 5.2
md:219) operate on `(z0, z1)` — two anchors, never more. The witnesses `x1 < … < xn` are **bound**
(introduced one at a time as bound points of nested `Until`s), never simultaneously free. This ≤2-cap
is not incidental: it is *why* the construction is expressible in `TL(Until, Since)` at all.

**(S2) The per-witness ordering residual is carried by the `Until`/`Since` modality itself, and the
ordering against non-adjacent anchors is TRANSITIVE.** `X Until Y` at `t` means (md:79) "∃ t′ > t with
`Y(t′)` and `X` on `(t, t′)`". So in `F_{i-1} = α_{i-1} ∧ (β_i Until F_i)`, the inner `F_i` is evaluated
at a point `t′ > t` that the `Until` **intrinsically orders after `t`**; the ordering `x_i > x_{i-1}` is
established by that modality, and `x_i > x_{i-2} > … > z0` and `x_i < z1` follow by **transitivity +
the outer bound `z1`** (md:267-273: the inductive step navigates `y1 → y2 > y1` with the interior
holding on `(y1,y2)`, then relocates `z` to `y2` or `x_{n+1}`). There is **no free-standing
per-witness residual hypothesis** — the ordering is *produced* by the nested navigation.

**(S3) The interior of each navigated interval is the β-SEGMENT, a quantifier-free formula — NOT the
recursive characteristic.** The `Until` interior condition is "`β_i` holds on the open interval
`(x_{i-1}, x_i)`" (md:79, md:269-273 "β_{n+1} holds along (y1,y2)"). Figure 1 (md:299) makes this
explicit: `B2(z0,z,z1) := [α0,β1,α1,β2,β2](z0,z) ∧ [β2,β2,α2,β3,α3](z,z1)` — the `β`'s occupy the
interior slots; the recursive characteristic (the `F_i`/`α_i` endpoint data) sits at the **endpoint**
`x_i`, never smeared across the interior.

---

## Answers to the four adjudication questions

### Q1 — Does each deeper existential carry a per-witness ordering/anchor residual? Does it map to `NavResidual M sub (Fin.cons w' env)` on the hooks (option A)?

**YES for the ordering part; NO for the anchor-PREDICATE part — and `NavResidual` conflates the two.**

By **(S2)**, each navigated witness carries an ordering constraint relative to the *immediately
enclosing* anchor, discharged by the `Until`/`Since` modality; ordering against the other anchors is
transitive. That maps onto the ordering fragment of `NavResidual` and is genuinely dischargeable by
navigation — **this half of option A is faithful.**

But `NavResidual M qnf env` (Base.lean:1608-1613) is defined as

```lean
∀ atom : AtomKind sig n, (∀ p, atom ≠ AtomKind.pred p (0 : Fin n)) →
    (atom_eval M env atom ↔ (qnf.atom_assgn atom = true))
```

i.e. it pins **every** non-position-0 atom — that includes the **predicate atoms at positions
`1 … n-1`** (`atom_eval M env (pred p j) = M.interp p (env j)`), not just order atoms. Rabinovich has
**no analogue** of a per-witness *predicate*-layer residual at the enclosing anchors: his `F_i` are
one-free-variable formulas (local + forward-navigating) and the only anchor predicate constraint is
`α0(z0)` at the *single* origin (md:263, md:285 Case 1). The multi-anchor predicate layer is an
artifact of the Lean `NormalForm` encoding (which prepends a fresh witness and re-tags all prior
positions as predicate/order atoms), **not** of the paper. So the `NavResidual`-on-hooks shape of
option A demands, per witness, something Rabinovich never establishes and that single-anchor
navigation cannot produce — see the H4 refutation.

### Q2 — Faithful interior: non-trivial `BracketFormula.trivial (rec sub)`, or `TemporalPred.top`?

**Neither as used. Rabinovich's interior is the β-SEGMENT (`seg`), a simple predicate — not the
recursive characteristic `rec sub`, and not literally `⊤`.** By **(S3)**:

- Phase-4's `BracketFormula.trivial (rec sub)` (Base.lean:1810-1813, 1834/1840) puts the **endpoint
  characteristic in the interior**. This is the direct cause of the "unprovable interior conjunct"
  half of the blocker: it demands `∀ y ∈ (w', env 0), (endCharRec…k sub).eval_at y`, which
  `nf_eval_nf` at the single endpoint never implies. **DIVERGENT** — and it also contradicts the
  plan, which specified `seg` (Base.lean:1127) as the interior (plan v2 Phase 4, task bullet 1:
  "using … `seg` … as the non-trivial bounded interior (G3)").
- `BracketFormula.trivial TemporalPred.top` is what the **green** diagonal template
  `nf_char2_diag_exist_tl` (Base.lean:173/176) and the original arity-3 brick
  `nf_zone_flatten_navigable` (Base.lean:673/678) use — and they are correct, because there the
  β-segment is carried **elsewhere** (the honest full-env `nf_eval_nf` residual zones, or the
  segment-carrying `A_past`/`A_future`). `⊤` is right *for the bracket-navigation interior slot*, with
  the real segment in `seg`.
- Faithful: interior = the β-segment `seg`. Phase 4 deviated from both Rabinovich and its own plan.

**Caveat (decisive):** fixing the interior alone does **not** unblock. Even with the green template's
`⊤` interior, the `h_now`/`h_past`/`h_fut` hooks still demand the per-witness biconditional to the
general multi-anchor `nf_eval_nf`, whose *predicate* layer at `env 1…n-1` remains uncertifiable from
`env 0`. The interior is a **secondary** divergence; the primary one is single-anchor-vs-multi-anchor
(Q3).

### Q3 — Is the single-anchor 3-zone converter a faithful realization of Rabinovich's navigation one arity up?

**NO. It is faithful only for the DIAGONAL (all-anchors-coincident) case, and it is being applied to a
general multi-anchor target.** The smoking gun is that `navBrickForm` (Base.lean:1806-1813) is a
verbatim structural copy of the **diagonal** converter `nf_char2_diag_exist_tl` (Base.lean:168-176):

| | `nf_char2_diag_exist_tl` (green, Base.lean:168) | `navBrickForm` (Phase 4, Base.lean:1806) |
|---|---|---|
| target existential | `∃ w, nf_eval_nf M k 3 (Fin.cons w (fun _ => t)) qnf` — env `[w, t, t]`, **anchors collapsed to one point `t`** | `∃ w', nf_eval_nf M k (n+1) (Fin.cons w' env) sub` — env `[w', env0, …, env(n-1)]`, **`n` distinct anchors** |
| evaluated at | the single point `t` (= both anchors) | the single anchor `a = env 0` |
| can it read all anchors? | **YES** — all anchors ARE `t`, one point | **NO** — `env 1…n-1` are distinct and unreadable from `env 0` |

The diagonal template works precisely because on `[w,t,t]` there is effectively **one** anchor, so a
`Formula` at `t` certifies the whole env. Rabinovich's *actual* navigation (S1) is a **two-anchor**
span `(x_{i-1}, x_i)` / `(z0, z1)` — the `Since`/`Until` reaches *from* one anchor *to* another,
checking the segment in between. A single-anchor 3-zone `Formula` cannot express that two-anchor span,
let alone an `n`-anchor one. The Phase-4 summary itself concedes the obstruction ("A formula at one
point cannot reference the other n-1 env positions semantically") but resolves it by *dropping* to the
diagonal shape — which silently changes the object being characterized. **This is the root divergence.**

Faithful navigation one arity up requires the characteristic to **navigate to each enclosing anchor**
(nested `Since`/`Until`, one modality per anchor — exactly Rabinovich's nesting), so the anchor layer
is certified by reaching it. That is the FULL-eval hook shape the *green* arity-3
`nf_zone_flatten_navigable` already has (`h_past`/`h_fut` characterize the **full** `nf_eval_nf M k 3
(zoneEnv3 w x t) q`, Base.lean:692-697) — a **two-anchor Prop**, not a single-anchor Formula. Option A
+ multi-anchor characteristic is what makes the residual dischargeable.

### Q4 — Adjudicate A / B / C; give corrected signatures for `/revise 349`

**Option A (reshape `navBrickForm`/`_correct` hooks to carry per-witness `NavResidual`): FAITHFUL-IN-PART,
NOT UNBLOCKING as a standalone fix.** It correctly recognizes the per-witness ordering residual (S2),
but (i) the `NavResidual` it carries also pins the anchor *predicate* layer, which Rabinovich never
establishes per-witness (Q1); and (ii) it merely moves the obligation from the IH into
`navBrickForm_correct`'s **own forward direction**, where — for the universally-quantified `sub` whose
anchor-predicate layer disagrees with `env` — the LHS `temporal_truth a (navBrickForm rec sub)` is
TRUE (the single-anchor `rec sub` reads only position 0, `endCharN0_wlocus_correct` Base.lean:1694)
while the RHS `∃ w', nf_eval_nf … sub` is FALSE. **The brick biconditional is itself a non-theorem for
such `sub`; no hook reshape repairs a false conclusion.** (H4 refutation below.)

**Option B (thread inner-witness `NavResidual` through the frozen `endCharRec_correct` statement):
FORBIDDEN by the freeze AND insufficient.** Even granting the statement change, `endCharRec_correct`'s
conclusion is consumed by `nf_endpoint_tl_gen_correct`'s `h_inner`, which is an **unconditional**
`∀ sub` biconditional (Base.lean:1893-1899 + the quant-clause shape). A `sub`-indexed residual
hypothesis on the conclusion cannot satisfy an unconditional consumer; the predicate-layer
non-theorem (Q3) survives.

**Option C (`/revise 349`, reopen Phase-4 and/or Phase-2 frozen interfaces): NECESSARY but must be a
SUPERSET — reopen Phases 2, 3, AND 4.** Phase 3's `endCharN0`/`nfN_locus0` (single-anchor, reads only
`pred p 0`, Base.lean:1664-1668) is itself part of the divergence and must change; Phase 4's
single-anchor 3-zone `navBrickForm` must be replaced by a multi-anchor navigating characteristic;
Phase 2's `NavResidual` should be split into an (order-only, per-witness, dischargeable) fragment plus
an (anchor-predicate, established-by-navigation) obligation.

#### Corrected lean-ready targets

**1. Inner converter must be multi-anchor navigating (replaces the single-anchor `navBrickForm`).** The
converter that discharges `h_inner` must reach every enclosing anchor. The faithful shape is the
`Formula`-valued generalization of the *green* two-anchor `nf_zone_flatten_navigable` whose hooks
characterize the FULL eval (not the diagonal template). Concretely the hooks must have the full-eval
shape (per-witness ordering supplied by the zone, anchor layer certified by navigation):

```lean
-- REPLACE navBrickForm / navBrickForm_correct with a multi-anchor navigating form whose hooks are:
theorem navMultiAnchorForm_correct
    (rec : NormalForm sig k (n+1) → TemporalPred) (sub : NormalForm sig k (n+1))
    (env : Fin n → M.carrier)
    -- each exterior zone certifies the FULL arity-(n+1) eval at its witness, INCLUDING the
    -- anchor-predicate layer, by NAVIGATING to env 1 … env (n-1); no free-standing NavResidual:
    (h_past : ∀ w' : M.carrier, w' < env 0 →
      ((rec sub).eval_at M atomMap w' ↔ nf_eval_nf M k (n+1) (Fin.cons w' env) sub))
    (h_now  : (rec sub).eval_at M atomMap (env 0) ↔ nf_eval_nf M k (n+1) (Fin.cons (env 0) env) sub)
    (h_fut  : ∀ w' : M.carrier, env 0 < w' →
      ((rec sub).eval_at M atomMap w' ↔ nf_eval_nf M k (n+1) (Fin.cons w' env) sub)) :
    temporal_truth M atomMap (env 0) (navMultiAnchorForm rec env sub) ↔
      ∃ w', nf_eval_nf M k (n+1) (Fin.cons w' env) sub
```

The interior slot in `navMultiAnchorForm` is the β-segment `seg` (Q2), NOT `BracketFormula.trivial
(rec sub)` and NOT `⊤`-with-no-segment. Note the hooks are **unconditional biconditionals to the full
eval** — matching Base.lean:692-697 — which is only achievable if `rec sub` (i.e. `endCharRec k sub`)
**navigates to and certifies** `env 1 … env(n-1)` (target 2).

**2. `endCharRec` / `endCharN0` must certify the anchor layer by navigation, not read only position 0.**
The current base (Base.lean:1664-1686) reads solely `nf (.pred p (0 : Fin n))`. The corrected base
must, at the navigated witness, additionally navigate (nested `Since`/`Until`) to each anchor position
and certify its predicate + order layer — i.e. `endCharRec k sub` must satisfy the *unconditional*
full-eval biconditional of target 1, discharging what `NavResidual` currently only assumes. This makes
`NavResidual` (as a hypothesis) **unnecessary at the inner witnesses** (it is proved, not assumed) and
the frozen `endCharRec_correct` statement can shed its inner-residual gap.

**3. Corrected `endCharRec_correct` (outer residual retained only for the top-level anchors, if at
all).** With target 2 in place the biconditional becomes:

```lean
theorem endCharRec_correct (M) (atomMap) (h_surj) :
    ∀ (k : Nat) {n : Nat} [NeZero n] (qnf : NormalForm sig k n) (env : Fin n → M.carrier),
      (endCharRec atomMap h_surj k qnf).eval_at M atomMap (env 0) ↔ nf_eval_nf M k n env qnf
```

— i.e. **unconditional** (no `h_nav`), because the navigating characteristic certifies the full env
itself. (If a residual is still needed at the two genuine top-level anchors, it is the *order-only*
fragment of `NavResidual`, not the predicate fragment; keep it strictly ≤ the two Rabinovich anchors,
S1.)

**4. If the multi-anchor navigating characteristic proves not to exist within `TL(Until,Since)` at the
climbing arity, the correct conclusion is that the Lean encoding must apply Rabinovich's Lemma 3.2(2)
≤2-free-variable REDUCTION (md:119) before navigating** — keeping the recursion at arity ≤ 3 (two
anchors + witness) as the *green* arity-3 `nf_zone_flatten_navigable` line does. This is the
alternative faithful architecture; it requires a Lean analogue of Lemma 3.2(2) (does not currently
exist in-tree — mark uncertain).

**Reusable as-is under the revise**: `nf_endpoint_tl_gen`/`_correct` (Base.lean:1879/1893, the
atom-layer + quant-clause assembly is arity-generic and correct), `atomPartN` (Base.lean:1866),
`endCharN0`'s *atom-literal* machinery (the `nf_depth0_char_formula` core), `seg`/`seg_holds_coupled`
(Base.lean:1127/1150), and the green two-anchor `nf_zone_flatten_navigable`/`_correct` shape as the
FULL-eval hook template to generalize.

---

## H3 Lemma-Mapping Table (Tier 1, Rabinovich 2014)

| Rabinovich construct | Source location | Current Lean asset | Faithful / Divergent | Corrected asset |
|---|---|---|---|---|
| `F_{i-1} := α_{i-1} ∧ (β_i Until F_i)` — inner char carried as `Until` endpoint, one free var, local+forward | md:261-263 | `endCharRec k sub` via `endCharN0`/`nfN_locus0` (reads only `pred p 0`, Base.lean:1664-1686) | **Partially faithful** (local+forward ✓) **but Divergent** (single-anchor: cannot certify the other `n-1` anchors the Lean env demands) | target 2: navigating characteristic that reaches each anchor |
| ≤ 2 free variables throughout (`(z0,z1)`); witnesses bound one-at-a-time | md:119 (Lem 3.2(2)), md:165, md:219 | `navBrickForm` single anchor `a`; report 01's "arity-general, free anchors ≤2" thesis | **Divergent in realization**: the arity climbs to `n+1` distinct anchors with no ≤2 reduction; single-anchor Formula cannot span even 2 | Lemma-3.2(2) reduction (target 4) OR genuine two-anchor navigating hooks (target 1) |
| Per-witness ordering `x_i > x_{i-1}` discharged by the `Until`; other orderings transitive; outer bound `z1` | md:79, md:267-273 | `NavResidual` order-atom fragment (Base.lean:1612) | **Faithful** (order fragment) | keep as the *order-only* per-witness residual; discharge via zone (S2) |
| Anchor predicate constraint is `α0(z0)` at the SINGLE origin only | md:263, md:285 (Case 1) | `NavResidual` predicate fragment at positions `1…n-1` (Base.lean:1612-1613) | **Divergent**: no per-witness multi-anchor predicate residual exists in the paper; it is a `NormalForm`-encoding artifact | certify anchor predicates by navigation (target 2), not by residual hypothesis |
| Interior of `(x_{i-1}, x_i)` = β-segment (qf), endpoint carries `F_i` | md:79, md:269-273, md:299 (Fig 1) | `BracketFormula.trivial (rec sub)` interior (Base.lean:1810-1813) | **Divergent** (endpoint characteristic smeared into interior → unprovable interior conjunct); also violates plan (which specified `seg`) | interior = `seg` (Base.lean:1127); `rec sub` at endpoint only |
| Two-anchor navigated flatten with FULL-eval endpoint hooks | md:255-279 (Cor 5.4) | `nf_zone_flatten_navigable`/`_correct` (Base.lean:667/687), **Prop-valued, hooks = full eval** | **Faithful** (this is the correct template) | generalize its full-eval hook shape to the `Formula`-valued inner converter (target 1) |
| Diagonal (`z0=z1`) special case | md:199 (`k=m` case) | `nf_char2_diag_exist_tl`/`A_diag` (Base.lean:168/741), `TemporalPred.top` interior | **Faithful** (diagonal only) | keep; do NOT reuse its single-anchor shape off-diagonal (root divergence) |
| depth-`(k+1)` arity-`n` eval unfolds to atom layer + arity-`(n+1)` inner `∃w'` | (Lean type fact) | `nf_eval_nf_step_unfold`, `nf_endpoint_tl_gen`/`_correct` (Base.lean:1488, 1879/1893) | **Faithful** (arity-generic assembly is correct) | reuse verbatim under revise |

---

## Adversarial Self-Verification (H4)

Per the contract's Claim Verification Bar; `Verification Method` uses lean4 domain values
(`source read of type/signature`, `literature read`, `Iff.rfl type fact`, `structural diff`).
The two refutation targets mandated by the dispatch are attacked first.

### Refutation target 1 — "Option A is faithful AND unblocking"

**Attempted proof that A unblocks**: make `navBrickForm_correct`'s hooks carry
`NavResidual M sub (Fin.cons w' env)`; then discharging each hook = applying the IH under exactly the
hypothesis the IH wants; the `h_now` residual goal closes. *This closes the HOOK-DISCHARGE step.*

**Refutation (survives)**: making the hooks conditional forces `navBrickForm_correct`'s **own forward
direction** to *establish* `NavResidual M sub (Fin.cons w' env)` at the navigated `w'`. `NavResidual`
pins `sub`'s predicate atoms at positions `1…n-1`, i.e. `M.interp p (env j) ↔ sub.atom_assgn (pred p (j+1)) = true`
— a fact about `env` and the arbitrary `sub`, **independent of `w'`**, that the navigation cannot
influence. For any `sub` in the quant-layer `∀`-range whose anchor-predicate layer disagrees with
`env`: RHS `∃ w', nf_eval_nf … sub` is **false** (anchor atoms fail for every `w'`), yet LHS
`temporal_truth (env 0) (navBrickForm rec sub)` is **true** (the single-anchor `rec sub = endCharRec k sub`
reads only `pred p 0`, `endCharN0_wlocus_correct` Base.lean:1694-1710, so a zone witness satisfies it).
A biconditional with a provably-true LHS and provably-false RHS is a **non-theorem**; no reshaping of
hook hypotheses repairs a false conclusion. **VERDICT: "A is unblocking" is REFUTED. "A is faithful"
survives only for the order-atom fragment (S2), not the predicate fragment.**

### Refutation target 2 — "the trivial interior is the source of divergence"

**Attempted proof**: the open goal's second half is the interior conjunct `∀ y ∈ (w', env 0),
(endCharRec…k sub).eval_at y`, which comes exactly from `BracketFormula.trivial (rec sub)`
(Base.lean:1810); replace it with `TemporalPred.top` (green in `nf_char2_diag_exist_tl`,
Base.lean:173) and the conjunct vanishes → blocker gone.

**Refutation (survives partially)**: the `rec sub` interior IS *a* source of divergence — it is the
provenance of the interior-conjunct half of the blocker, and it contradicts both Rabinovich (S3) and
the plan (which specified `seg`). **That much survives.** BUT it is NOT *the* source: with the `⊤`
interior, `h_now` alone is still `(rec sub).eval_at (env 0) ↔ nf_eval_nf M k (n+1) (Fin.cons (env 0) env) sub`
(Base.lean:1836-1837), whose forward direction remains the predicate-layer non-theorem of target 1
(no interior conjunct involved). **VERDICT: "trivial interior is A source" — TRUE; "trivial interior
is THE source" — REFUTED. The root is single-anchor-vs-multi-anchor (Q3).**

### Claim Verification Table

| Claim | Source / Counterexample | Verification Method | Confidence |
|---|---|---|---|
| `navBrickForm` is a structural copy of the diagonal converter `nf_char2_diag_exist_tl`, applied to a general (non-diagonal) target | Base.lean:1806-1813 vs 168-176; targets `Fin.cons w' env` (distinct) vs `Fin.cons w (fun _ => t)` (collapsed) | structural diff of two signatures | High |
| `endCharRec`/`endCharN0` read only the position-0 predicate layer | `nfN_locus0` reads `nf (.pred p (0:Fin n))` (Base.lean:1666-1667); `endCharN0_wlocus_correct` RHS quantifies only `pred p 0` (Base.lean:1699-1700) | source read of def + theorem | High |
| `NavResidual` pins the anchor-PREDICATE layer at positions 1…n-1 (not just order atoms) | `atom ≠ pred p 0` includes `pred p j`, `j≥1` (Base.lean:1612-1613) | source read of def | High |
| For a `sub` whose anchor-predicate layer disagrees with env: LHS true, RHS false → brick biconditional is a non-theorem | blocker `lean_goal` evidence + `endCharN0_wlocus_correct`; matches handoff `missing_lemma` | Iff.rfl/type reasoning + source read | High |
| `sub` in `h_inner` is universally quantified and arbitrary (quant-layer `∀ sub`) | `nf_endpoint_tl_gen` maps over `Finset.univ.toList : List (NormalForm sig k (n+1))` (Base.lean:1883-1885); `h_inner` is `∀ sub` unconditional | source read of signature | High |
| Rabinovich stays at ≤ 2 free variables throughout | md:119 (Lem 3.2(2)), md:165, md:219 | literature read | High |
| Rabinovich's per-witness ordering is discharged by `Until`/`Since`, non-adjacent by transitivity | md:79, md:267-273 | literature read | High |
| Rabinovich's interior is the β-segment, not the recursive characteristic | md:79, md:269-273, md:299 (Fig 1) | literature read | High |
| Rabinovich has NO per-witness multi-anchor predicate residual (only `α0(z0)` at one origin) | md:263, md:285 (Case 1) — no such construct appears | literature read (absence) | Medium-High |
| The green two-anchor `nf_zone_flatten_navigable` hooks DO characterize the full arity-3 eval (the faithful template) | Base.lean:692-697 (`h_past`/`h_fut` RHS = `nf_eval_nf M k 3 (zoneEnv3 w x t) q`) | source read of signature | High |
| Option A (per-witness residual on hooks) does not unblock; relocates the non-theorem | refutation target 1 above | analytic composition of source-read signatures | High |
| `rec sub` interior is a (secondary) source of the blocker; `seg` is the faithful interior | Base.lean:1810 vs md:299 (Fig 1) vs plan v2 Phase 4 bullet 1 | source read + literature + plan | High |
| The faithful fix (multi-anchor navigating characteristic) is BUILDABLE within TL(Until,Since) | reasoning from Rabinovich nested Until/Since; NOT yet realized in-tree | analytic; no in-tree witness | **Medium** (flagged uncertain) |
| Lemma-3.2(2) reduction alternative requires a Lean analogue that does not exist in-tree | md:119; grep of NfMultiAnchorBridge (no such lemma read this session) | literature read + absence-of-asset | Medium (uncertain — not exhaustively grepped) |

### Contradiction Log

- **Report 01 "arity-general, hooks = IH, closes (Medium-High)" vs. this report "single-anchor
  characteristic cannot certify the multi-anchor eval; does NOT close".** Resolved by precedence
  *actual Lean type/goal-state > prior analytic prediction*: report 01's §3.3 assumed "the other `n-1`
  env positions are frozen bracket witnesses from the enclosing navigation" — but the enclosing
  navigation does **not** inject those positions into the inner `Formula`; `innerConv sub` is evaluated
  at `env 0` with no access to `env 1…n-1` (Base.lean:1836 `h_now`, evaluated at `env 0`). Report 01
  was correct that arity climbs (type fact, undisputed) and that Rabinovich navigates rather than
  collapses; it was wrong that a *single-anchor* Formula suffices for the navigation. **The Phase-5
  blocker is precisely the refutation of report 01's Medium-High closure claim.** Downstream risk if
  ignored: a 7th strike re-attempting single-anchor navBrick reshapes (option A) that cannot close.
- **Blocker note "reconsider `rec sub` vs `⊤` interior (option A parenthetical)" vs. this report "the
  interior is secondary; the root is single-anchor".** Resolved: both the interior AND the anchor layer
  are broken; the interior fix is necessary-not-sufficient. No contradiction on the interior being
  wrong; contradiction only on it being the *primary* blocker — refuted (H4 target 2).

### Forbidden-output check

No "mathlib likely has this" (all claims cite `Base.lean:line` or `md:line`, source-read this
session). No `sorry`/vacuous/axiom recommendation. `nf_char3_deeper_split` not recommended (it grows
anchors — the very failure mode). The recommendation is a concrete re-architecture with named
corrected signatures, not a deferral.

### Recommendations modified after verification

Option A was downgraded from the blocker's "candidate faithful fix" to **"faithful only for the order
fragment; NOT unblocking; must be combined with a multi-anchor navigating characteristic"**. The
audit's own initial hypothesis that "restoring `seg`/`⊤` interior might unblock" was **refuted** (H4
target 2) and downgraded to "necessary secondary fix".

---

## Memory Candidates

1. *(lean4, Kamp/Rabinovich)* A `Formula` evaluated at a single anchor `env 0` **cannot** certify the
   predicate layer at other env positions `env 1…n-1` (it cannot read `M.interp p (env j)`, `j≥1`). A
   navigated single-anchor converter is faithful **only** for the diagonal (all-anchors-coincident)
   case (`nf_char2_diag_exist_tl`, env `[w,t,t]`). Reusing that diagonal shape for a general
   multi-anchor `∃w', nf_eval_nf (Fin.cons w' env) sub` is a silent non-theorem, papered over by a
   `NavResidual`-style hypothesis that is FALSE for the universally-quantified sub of the quant layer.
2. *(lean4, proof architecture)* Rabinovich Cor 5.4 keeps ≤ 2 free variables **throughout** (Lem
   3.2(2)); the per-witness ordering is discharged by the `Until`/`Since` modality (non-adjacent by
   transitivity), and the interval interior is the **β-SEGMENT**, not the recursive characteristic
   (which sits at the endpoint). Putting the recursive characteristic into the interior
   (`BracketFormula.trivial (rec sub)`) manufactures an unprovable "characteristic-holds-throughout"
   conjunct — a divergence detectable by comparing to Figure 1's `B2` interior slots.
3. *(lean4, audit method)* When a hook-discharge blocker leaves an "unprovable residual `H` for
   universally-quantified `sub`", check whether making `H` a hook *hypothesis* merely relocates it into
   the parent lemma's forward direction as the same non-theorem. If the parent's conclusion has a
   provably-true LHS and provably-false RHS for some `sub`, no hook reshape closes it — the object being
   characterized is wrong, not the hypotheses.
