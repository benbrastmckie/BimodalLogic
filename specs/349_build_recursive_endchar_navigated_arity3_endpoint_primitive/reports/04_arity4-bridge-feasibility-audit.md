# Report 04 — Arity-4-Enclosing-Pair Navigation Bridge: Feasibility Audit (H4/H5)

- **Task**: 349 — Build the recursive navigated arity-3 endpoint primitive `endChar` + `endChar_correct`
- **Type**: lean4 (hard-mode; H2 anti-analysis, H3 reference grounding, H4 adversarial self-verification, H5 divergence audit)
- **Session**: sess_1783841542_df767b
- **Dispatch**: divergence audit + feasibility verification of the Phase-3 blocker (`navPieceForm_correct` deferral)
- **Reference grounding tier**: Tier 1 (literature-backed — Rabinovich 2014, report 02 §1.4 / Cor 5.4)
- **Agent**: lean-research-hard-agent

---

## VERDICT (read first)

**NON-THEOREM.** The arity-4-enclosing-pair navigation bridge **as it must be stated to discharge
`navPieceForm_correct` / the `h_inner` hook of `nf_char3_endpoint_tl_correct`** — a single closed
`Formula` (`navPieceForm rec sub`, `innerConv sub`) read at the **one** point `y`, characterizing
`∃ w, nf_eval_nf M k 4 (Fin.cons w (zoneEnv3 y x t)) sub` **unconditionally over `sub`**, for
**arbitrary, uncoupled** free anchors `x, t` — is refuted. It is the arity-4 reincarnation of the
already-machine-checked non-theorem `endCharN0_correct_infeasible` (Base.lean:1779).

**Crucially, the implementer's stated escape is refuting the WRONG obstruction.** The claim
(Lemma32Reduction.lean:302-305; blocker note) is that "a disjunction over enclosing pairs with a
threaded witness is NOT world-local because it navigates via the order," so it escapes the wall
that kills the single-pair form. That statement is **true but irrelevant**. The obstruction that
actually kills the bridge is **not world-locality** (which navigation does escape) — it is
**parameter-independence**: `navPieceForm rec sub` does not take `x, t` as arguments, so it is a
**constant** function of `(x, t)`, while the right-hand existential `∃ w, nf_eval_nf M k 4 [w,y,x,t] sub`
is a **non-constant** function of `(x, t)`. A constant function cannot equal a non-constant one. No
amount of order-navigation repairs this, because navigation lets the formula *read* other worlds but
gives it no way to *select the specific free parameters* `x, t` appearing in the RHS.

**Consequence for the plan**: YES — task 349's v4 Phase-3 architecture (and the `endChar` recursion
built on `nf_char3_endpoint_tl`) needs revision. This is the *same* root divergence report 02 already
adjudicated (Q3: a `Formula` read at one point cannot characterize a genuinely multi-anchor target;
the faithful object is the **Prop-valued** two-anchor `nf_zone_flatten_navigable`, which takes `x, t`
as **explicit arguments** and reads *at* `x` and *at* `t`). Phase 3 re-imported that error one arity
up. The alternative is sketched in §5.

---

## 1. The exact object under audit

The `lean_goal`-captured stuck target (NavigatedEndChar.lean:226-230) is

```
(∃ w, nfEvalRHS M k 4 (Fin.cons w (zoneEnv3 y x t)) sub) ↔ temporal_truth M atomMap y (navPieceForm rec sub)
```

which, via `navPiece_reduce` (NavigatedEndChar.lean:215-220, GREEN), is inter-derivable with the
form actually demanded by the consumer:

```
temporal_truth M atomMap y (navPieceForm rec sub) ↔ ∃ w, nf_eval_nf M k 4 (Fin.cons w (zoneEnv3 y x t)) sub
```

This is **exactly** the `h_inner` hypothesis of `nf_char3_endpoint_tl_correct`
(Base.lean:893-895), instantiated `innerConv := navPieceForm rec`:

```lean
h_inner : ∀ sub : NormalForm sig k 4,
    temporal_truth M atomMap y (innerConv sub) ↔
      ∃ w : M.carrier, nf_eval_nf M k 4 (Fin.cons w (zoneEnv3 y x t)) sub
```

Anchor layout (NfZoneDepthK.lean:203-209): `zoneEnv3 y x t = [y, x, t]`; `Fin.cons w (zoneEnv3 y x t)
= [w, y, x, t]` — four anchors `{w, y, x, t}`, of which **`w` is the bound witness**, **`y` is the
read point**, and **`x, t` are free, arbitrary carrier anchors**. `nf_char3_endpoint_tl_correct`
quantifies over `y x t : M.carrier` with **no** order hypothesis and **no** coupling relating
`x, t` to `y` or to the model (Base.lean:885-887).

The three inputs to the LHS formula:
- `navPieceForm : (NormalForm sig k 3 → TemporalPred) → NormalForm sig k 4 → Formula`
  (NavigatedEndChar.lean:196-202) — arguments `rec`, `sub` **only**.
- `innerConv : NormalForm sig k 4 → Formula` (Base.lean:871) — argument `sub` **only**.
- `rec` is the depth-`(k−1)` IH hook, independent of `x, t`.

**None of `navPieceForm rec sub`, `innerConv sub`, or `rec` takes `x` or `t` as an argument.** This
is the single fact the refutation turns on, and it is verified directly from the signatures.

---

## 2. The refutation (adversarial — H4)

### 2.1 The parameter-independence argument (airtight, model-independent)

Fix `sig`, `k`, `rec`, and a specific `sub` for which the reduced form reads a predicate atom at
env-position `2` (the `x` slot) — such `sub` exists (e.g. any `sub` whose atom layer pins
`AtomKind.pred p 2`; the atom layer of `nf_eval_nf` reads `M.interp p (env 2) = M.interp p x`, cf.
`nf_eval_atom_layer` used at NfZoneDepthK.lean:223 and the position-1 read in
`endCharN0_correct_infeasible`, Base.lean:1794-1802).

Now fix any model `M` and read point `y`, and consider the two functions of `(x, t)`:

- `L(x,t) := temporal_truth M atomMap y (navPieceForm rec sub)` — **constant** in `(x, t)` (the
  formula does not mention `x` or `t`).
- `R(x,t) := ∃ w, nf_eval_nf M k 4 (Fin.cons w (zoneEnv3 y x t)) sub` — **non-constant** in `(x, t)`
  in general: choosing `x0, x1` with `M.interp p x0 ≠ M.interp p x1` changes the value of the
  position-2 predicate atom that `sub` pins, hence changes `R`.

`h_inner` demands `L(x,t) ↔ R(x,t)` for **all** `x, t` (and all `sub`). But a constant `L` cannot be
equivalent to a non-constant `R`. Therefore `∀ x t, (L ↔ R)` is **false**. ∎

This argument uses navigation nowhere and is therefore immune to the "it navigates, so it is not
world-local" escape: the escape defeats a *different* obstruction.

### 2.2 It is `endCharN0_correct_infeasible` one arity up (machine-checked anchor)

`endCharN0_correct_infeasible` (Base.lean:1779-1803, sorry-free) refutes the depth-0, arity-`n`
analogue: no `base` gives `(base qnf).eval_at (env 0) ↔ nf_eval_nf M 0 n env qnf` for all `qnf, env`,
because a term read at `env 0` cannot track `env 1`. Its engine
`endCharN0_correct_world_local_obstruction` (Base.lean:1745-1753) formalizes the invariance: two envs
agreeing at position `0` force `nf_eval_nf` to agree, contradicting a position-1 predicate difference
(`![false,false]` vs `![false,true]`, Base.lean:1785-1803).

The present target is the same shape with the read anchor promoted from `env 0` to `y` and the
tracked free anchor being the `x` (position-2) slot: `navPieceForm rec sub` is read at `y` and must
track `M.interp p x`. **The only new element is that `navPieceForm` navigates** (it is a
`bracketBuildLeft/Right` disjunction, NavigatedEndChar.lean:200-202). §2.1 shows navigation does not
help, because the deficiency is not "cannot read `x`" but "cannot know *which* read point is the
free parameter `x` of the RHS." Hence the machine-checked infeasibility transfers.

### 2.3 Why the *single-pair* refutation and *this* refutation are distinct — and both hold

Lemma32Reduction.lean:290-306 refutes the **fixed single-pair arity-`(n+1)`→3 collapse** (the arity-3
restriction *forgets* the non-pair anchors, so the pair-restricted existential is strictly *weaker*).
That is a **projection/forgetting** obstruction on the RHS reduction. The obstruction here is
**different and additional**: it is on the LHS **converter shape** (a closed `Formula` read at one
point cannot reference free parameters). The implementer correctly noted the enclosing-pair
*disjunction over the RHS* escapes the *forgetting* obstruction — and it does (see §3, the Prop-valued
merge is real). But escaping the forgetting obstruction does nothing about the converter-shape
obstruction, which is what actually blocks `navPieceForm_correct`.

### 2.4 Where the world-locality wall is / is not

- The **single-point-read** wall (`endCharN0_...`) **does** apply to `navPieceForm_correct`, in the
  refined parameter-independence form of §2.1 — because `navPieceForm` read at `y` is a fixed formula
  and `x, t` are free RHS parameters.
- A **Prop-valued** object that takes `x, t` as explicit arguments and reads *at* `x` and *at* `t`
  (e.g. `nf_zone_flatten_navigable`, Base.lean:667-678, whose body literally contains
  `temporal_truth M atomMap x (…)`, `nf_eval_nf M k 3 (zoneEnv3 x x t) q`,
  `temporal_truth M atomMap t (…)`) **does** escape the wall — legitimately — and *that* is why it is
  GREEN. The escape is "reference `x, t` directly," **not** "navigate." Navigation supplies the
  *interior/exterior segment* content; the *anchor identification* is supplied by taking `x, t` as
  arguments.

---

## 3. Claim Verification Table (H4 — `| Claim | Source/Counterexample | Verdict |`)

| Claim | Source / Counterexample | Verdict |
|-------|------------------------|---------|
| `navPieceForm rec sub` / `innerConv sub` are independent of `x, t` | NavigatedEndChar.lean:196-202; Base.lean:871 (signatures) | **CONFIRMED** |
| `nf_char3_endpoint_tl_correct` demands `h_inner` unconditionally over `sub`, for arbitrary uncoupled `y x t` | Base.lean:885-895 | **CONFIRMED** |
| RHS `∃ w, nf_eval_nf M k 4 [w,y,x,t] sub` depends on `x` (reads `M.interp p x` at position 2) | NfZoneDepthK.lean:203-209, 223; Base.lean:1794-1802 (position-read precedent) | **CONFIRMED** |
| A constant-in-`(x,t)` LHS cannot equal a non-constant-in-`(x,t)` RHS ⇒ `∀ x t, h_inner` is false | §2.1 (parameter-independence); generalizes `endCharN0_correct_infeasible` (Base.lean:1779) | **CONFIRMED — bridge is NON-THEOREM** |
| The escape "navigates via order ⇒ not world-local ⇒ theorem" | Lemma32Reduction.lean:302-305; blocker note | **REFUTED** — true premise, wrong obstruction; defeats world-locality, not parameter-independence (§2.1, §2.3) |
| The single-pair arity-4→3 collapse is a distinct (forgetting) non-theorem, not the operative one | Lemma32Reduction.lean:290-306 vs §2.3 | **CONFIRMED (both non-theorems, different causes)** |
| The Prop-valued enclosing-pair merge (`nf_zone_flatten_navigable`, `x,t` explicit) IS a theorem | Base.lean:667-706 (GREEN, sorry-free) | **CONFIRMED (feasible — but it is a different object than `navPieceForm`)** |
| A *Formula-valued* arity-4 bridge read at `y` for arbitrary free `x,t` exists among green assets | search of Lemma32Reduction/NavigatedEndChar/Base; `nfEval_pair_arity3_flatten/_interior` navigate a FIXED explicit pair only (Lemma32Reduction.lean:318,344) | **CONFIRMED ABSENT — and provably cannot exist (§2.1)** |
| Phase-3 architecture needs revision (v4 plan) | §5; matches report 02 Q3/Q4 `/revise 349` finding | **CONFIRMED** |

**Contradiction Log**: none unresolved. The apparent contradiction — "the codebase says the
enclosing-zone disjunction is the correct route (Lemma32Reduction.lean:302-305), yet the bridge is a
non-theorem" — resolves cleanly: that comment is correct **about the Prop-valued merge** (which is
green: `nf_zone_flatten_navigable`), and the non-theorem is the **Formula-valued single-point-read
packaging** demanded by `nf_char3_endpoint_tl`. Different objects; both statements true.

---

## 4. Why this is a NON-THEOREM, not merely UNDETERMINED

Per H4, the default is "not yet established," and I attempted hardest to find a *feasible* reading.
The only feasible reading requires **changing the interface** so the converter takes `x, t` as
arguments (Prop-valued, à la `nf_zone_flatten_navigable`). Under the interface actually fixed by
`nf_char3_endpoint_tl` (`innerConv : … → Formula`, `h_inner` read at `y`, arbitrary `x, t`), §2.1 is
a *proof* of falsity, not an unresolved gap. Hence the verdict is the stronger NON-THEOREM, and it is
anchored to a sorry-free machine-checked precedent (`endCharN0_correct_infeasible`).

I also confirmed the two secondary gaps I initially suspected are *subsumed* by this primary one and
need not be separately adjudicated: (a) "straddling" interior segments for non-adjacent Fin-4 pairs,
and (b) the arity-5 quant-layer ceiling at `k+1` (NavigatedEndChar.lean:92-102, 233). Both are
downstream of the converter-shape obstruction; fixing the shape (§5) reframes them.

---

## 5. Since NON-THEOREM: architecture revision + faithful alternative (deliverable 3)

### 5.1 Scope of revision
`/revise 349` (or `/spawn 349` scoped to the interface, **not** to "the missing arity-4 bridge
lemma" — that lemma provably cannot exist). The revision must reopen the Phase-3 interface, because
the defect is in `nf_char3_endpoint_tl`'s `innerConv : NormalForm sig k 4 → Formula` +
single-point-read `h_inner`, not in `navPieceForm`'s internals. This is a **superset of report 02's
already-recommended `/revise 349`** (report 02 Q4/Q3), now confirmed to recur at the v4 Phase-3 layer.

### 5.2 The faithful shape (Rabinovich Cor 5.4 fidelity — report 02 §1.4, S1)
Report 02 S1 established that Rabinovich keeps **≤ 2 free variables throughout** (Lemma 3.2(2),
md:119; Cor 5.4, md:255-279): the witnesses `x1 < … < xn` are **bound** points of nested `Until`/
`Since`, never simultaneously free. The arity-4 target has **three** free anchors `{y, x, t}` — one
too many. The single-point-`Formula` conversion is being applied **before** the free-anchor count is
brought to ≤ 1. Faithful architecture:

1. Keep the inner converter **Prop-valued over its two enclosing anchors**, exactly the GREEN
   `nf_zone_flatten_navigable` (Base.lean:667) / `nfEval_pair_arity3_flatten`/`_interior`
   (Lemma32Reduction.lean:318/344) shape — `x, t` are **explicit arguments**, evaluation happens
   *at* `x` and *at* `t`, and the endpoint hooks `h_past`/`h_fut` (Base.lean:692-697) carry the
   coupling. This is the "disjunction over enclosing pairs threading one witness" the codebase
   comment intends — and it is **already green**, keeping anchor arity ≤ 3.
2. Only the **outermost** level, where the free-anchor count is ≤ 1, becomes a single-point
   `Formula` (Kamp's actual conclusion). Intermediate levels stay Prop-valued/multi-argument.
3. Thread the recursion through the **Prop-valued endpoint hooks** (as `nf_zone_flatten_navigable_correct`
   already does), not through a `Formula`-valued `innerConv`.

Under this shape, guards are respected: G1 (no arity-1 collapse — residuals stay arity 3), G2/G4
(`w` and enclosing witnesses stay bracket witnesses; free anchors ≤ 2 because `x, t` are the explicit
enclosing pair, never a third free anchor), G3 (interior is the genuine `seg`, Base.lean:1150), G5
(manual `or_congr`/`exists_congr`/`and_congr_right`), no `nf_char3_deeper_split`, no arity-4 collapse.
Note this is *not* a new bridge lemma to spawn — the green `nf_zone_flatten_navigable(_correct)`
**already is** the arity-3, ≤2-free, Prop-valued enclosing-pair merge; the revision is to **stop
wrapping it in a single-point `Formula` at arity 4** and to restructure `endChar`/`nf_char3_endpoint_tl`
so the free-anchor count never exceeds Rabinovich's ≤ 2 cap before the final formula conversion.

### 5.3 What must NOT be attempted (all provably closed)
- A single-pair arity-4→3 collapse (Lemma32Reduction.lean:290-306, forgetting non-theorem).
- A per-pair `∀ij ∃w` distribution (SETTLED non-theorem; witnesses do not merge for free).
- Any `Formula`-valued converter read at one point purporting to characterize a target with ≥ 2 free
  anchors it cannot reference (§2.1, this report — the operative non-theorem).

---

## 6. Divergence audit (H5)

| Target | Churn | Last-attempted approach | Failure reason |
|--------|-------|-------------------------|----------------|
| inner multi-anchor converter (arity `n+1`) | 3+ (`navBrickForm` → removed; `navMultiAnchorForm` frozen; `navPieceForm` deferred) | closed `Formula` read at one point characterizing a multi-anchor eval | single-point read cannot reference the other free anchors (report 02 Q3; **this report §2.1**) |
| `navPieceForm_correct` (Phase 3b) | 1 (deferred) | `Formula` read at `y` for arbitrary free `x, t` | **parameter-independence non-theorem** (§2) |

**Root cause (postmortem)**: repeated attempts package a **≥2-free-anchor** target as a
**single-point-read `Formula`** before reducing the free-anchor count to ≤ 1. Each attempt renames
the same object (`navBrickForm` → `navMultiAnchorForm` → `navPieceForm`) without changing its
**shape**, so each re-inherits the `endCharN0_correct_infeasible` obstruction one arity up. The fix
is a **shape** change (Prop-valued, explicit enclosing anchors, ≤2 free throughout), not another
bridge lemma.

**Sorry inventory**: 0 sorries in landed assets (`navPieceForm` def + `navPiece_reduce` are green;
`navPieceForm_correct` was *deferred*, never stubbed — verified: `.return-meta.json` `sorry_count: 0`,
`build_passed: true`).

**Type-mismatch analysis**:

| Object | Demanded type | Faithful type | Mismatch |
|--------|---------------|---------------|----------|
| inner converter | `NormalForm sig k 4 → Formula` (read at `y`) — Base.lean:871 | `(x t : carrier) → … → Prop` reading at `x, t` — Base.lean:667 | `Formula`-at-one-point vs `Prop`-with-explicit-anchors; the former cannot reference `x, t` |

**Corrected lean-ready targets** (for the revision dispatch): do **not** state
`navPieceForm_correct`. Instead re-point `nf_char3_endpoint_tl`'s inner obligation onto the green
Prop-valued `nf_zone_flatten_navigable_correct M atomMap x t pastEnd futureEnd q` (Base.lean:687),
supplying its `h_past`/`h_fut` from the depth IH, and restructure `endChar` so the top-level formula
conversion occurs only at ≤ 1 free anchor.

---

## Adversarial Self-Verification

- **Challenged every recommendation**: The one "positive" claim (Prop-valued merge is feasible) is
  backed by a GREEN theorem (`nf_zone_flatten_navigable_correct`, Base.lean:687), not instinct. The
  negative verdict is backed by a machine-checked precedent (`endCharN0_correct_infeasible`) plus a
  model-independent parameter-independence argument (§2.1) — not by "mathlib likely has this" or any
  unsearched claim.
- **Forbidden verification outputs check**: none present. No "different approach needed" without an
  alternative (the alternative is the green Prop-valued asset, §5). No type-mismatch claim without the
  goal state (the goal is the `lean_goal`-captured target, §1). No sorry/axiom recommendation.
- **Uncertain-claim flags**: The parameter-independence refutation (§2.1) is a semantic argument I did
  not mechanize as a new Lean `theorem` this dispatch; confidence is **High** because it is a strict
  generalization of the sorry-free `endCharN0_correct_infeasible` and turns only on signatures I
  verified by direct read. A follow-up could formalize `navPieceForm_correct_infeasible` (mirroring
  Base.lean:1779) at arity 4 as a fail-fast guard, but it is not required to act on this verdict.

**Recommendations modified after verification**: initial working hypothesis was "UNDETERMINED, leaning
feasible" (based on the codebase comment endorsing the enclosing-zone disjunction). Adversarial
verification against the `h_inner` signature (Base.lean:893) and the `navPieceForm` signature
(NavigatedEndChar.lean:196) upgraded this to **NON-THEOREM**, because the codebase comment is about the
Prop-valued merge while the blocked goal is the Formula-valued single-point-read packaging.

---

## Reference Grounding (Tier 1)

| Source | Prop / Location | Lean Identifier | Type Signature (verified read) | Status |
|--------|-----------------|-----------------|-------------------------------|--------|
| codebase | Lemma32Reduction.lean:1779… wait: Base.lean:1779 | `endCharN0_correct_infeasible` | `¬ ∃ base, ∀ n qnf env, (base qnf).eval_at (env 0) ↔ nf_eval_nf M 0 n env qnf` | GREEN precedent (refutation anchor) |
| codebase | Base.lean:1745 | `endCharN0_correct_world_local_obstruction` | single-point invariance engine | GREEN |
| codebase | Base.lean:667 / 687 | `nf_zone_flatten_navigable` / `_correct` | Prop over explicit `(x t)`, hooks `h_past`/`h_fut` | GREEN (faithful object) |
| codebase | Lemma32Reduction.lean:318 / 344 | `nfEval_pair_arity3_flatten` / `_interior` | fixed explicit arity-3 pair navigation | GREEN |
| codebase | Lemma32Reduction.lean:535 | `nfEval_le2_reduction` | arity-`n` → ≤2-anchor conjunction (Rabinovich Lem 3.2(2)) | GREEN (task 351) |
| codebase | Base.lean:869 / 885 | `nf_char3_endpoint_tl` / `_correct` | `innerConv : … → Formula`, `h_inner` read at `y` (defective interface) | GREEN conditional; hypotheses jointly unsatisfiable for arbitrary `x,t` |
| codebase | NavigatedEndChar.lean:196 / 215 | `navPieceForm` / `navPiece_reduce` | `Formula` indep. of `x,t`; witness-outside reduction | GREEN (3a); `_correct` NON-THEOREM |
| Rabinovich 2014 | Cor 5.4 (md:255-279), Lem 3.2(2) (md:119) | — | ≤ 2 free variables throughout | report 02 §1.4 / S1 |

---

*Report 04. Verdict: NON-THEOREM (refuted; parameter-independence, generalizing
`endCharN0_correct_infeasible`). Action: `/revise 349` — Prop-valued enclosing-anchor architecture,
≤ 2 free anchors throughout; the green `nf_zone_flatten_navigable_correct` already is the merge.*
