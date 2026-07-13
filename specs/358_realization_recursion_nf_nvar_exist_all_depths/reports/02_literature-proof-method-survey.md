# Literature Proof-Method Survey — Task #358

**Task**: 358 — retire the `nf_nvar_exist_all_depths` within-bracket realizer (`hσ`)
(KampPrior.lean:361 n=1 arm; :364 n+2 arm)
**Agent**: logic-research-agent · **Type**: logic (literature proof-method identification)
**Date**: 2026-07-12 · **Scope**: READ-ONLY literature survey. No Lean/plan edits. A concurrent
agent owns `01_*` (Lean transcription); this report is purely the mathematical-method survey.

---

## TL;DR — the one-line answer

The general-k within-bracket realizer is **Rabinovich 2014, Corollary 5.4(1), the ⇐ direction**,
and its proof method is a **constructive induction on the chain length `n` driven by the `Until`
modality with a two-way `min`/case-split** (`y2 ≤ x_{n+1}` keep `y2`, else keep `x_{n+1}`) — **not**
a raw `inf`/`sup` global choice. The only appeal to Dedekind completeness in the whole realizer is
the *first-point* predicate `INF` (eq. 5.3), which is **first-order definable** and is exactly what
the project already formalizes at k=1 (`fChainFrom`/`fChainPred`). **Verdict: GREEN-VIABLE.** No
non-constructive selection is needed at the realizer step; the k≥2 case is the k=1 template extended
by one Until-driven chain-link. Every surveyed alternative (GHR separation, Hodkinson games, Kamp
1968) is a *different, strictly harder-to-formalize* architecture. **Recommendation: follow
Rabinovich Cor 5.4(1) ⇐ verbatim; do not switch methods.**

---

## 1. The mathematical problem, stated precisely

Reduced to its realizer core (grounding: report 13 §1–2; report 355/01 Q1/Q3):

> Given a marked normal-form σ (an E[Σ]-fold / `∨∃∀` bracket `[α0, β1, α1, …, βn, αn]` of arity ≤ 4
> over anchors `[x1, w, x, t]`) that is required to hold on a single interval, **produce an actual
> witness point `z` strictly inside the bracket `(z0, z1)`** that realizes σ's marked existential
> subformulas, with every intermediate witness kept `> z0` and `< z1`.

This is the `∃ env`-producing obligation `hσ` at KampPrior.lean:361/:364. The k=1 instance is landed
(`fChainFrom`/`fChainPred`); the un-landed mathematics is the general k≥2 within-bracket realizer.

---

## 2. RABINOVICH 2014 — the primary method (extracted verbatim)

Source read directly: `~/Projects/Literature/sources/rabinovich_2014/` chunks 0011–0017 (§4
Prop 4.2 / §5 Lemma 5.1, Lemma 5.3, Cor 5.4). This corroborates and *refines* report 355/01.

### 2.1 Where the realizer lives

- Prop 4.2 (chunk 0012): closure of `¬(∃∀-formula, ≤2 free vars)` under negation over Dedekind-
  complete chains → `∨∃∀`. This is the project's spine (`nf_characterizable_temporal_prior`).
- Reduces (chunk 0013) to **Lemma 5.1**: `¬[α0, β1, …, βn, αn](z0, z1)` is `∨∃∀`. Proved via
  **Lemma 5.3** (all βi = True) → **Cor 5.4** (βn = True) → full Lemma 5.1.
- **Cor 5.4(1)** (chunk 0015) is the *within-bracket existential* the task needs:
  `¬(∃z)^{<z1}_{>z0}[α0, β1, α1, …, αn−1, βn, αn](z0, z)` ≡ `∨∃∀`. The realizer is the **⇐**
  ("there exists such a bounded `z`") half of its supporting observation.

### 2.2 The realizer method (Cor 5.4(1), ⇐), verbatim structure

Rabinovich defines a chain of predicates `F0, F1, …, Fn` (the "F_i chain") and proves the pivotal
observation:

> there is `z ∈ (z0, z1)` with `[α0,…,αn](z0, z)` **iff** `F0(z0)` **and** there is an increasing
> sequence `x1 < ⋯ < xn` in `(z0, z1)` with `Fi(xi)`.

The **⇐ direction is the realizer**, proved **by induction on `n`**:

- **Basis** (`n=0/1`): trivial — the landed `fChainFrom` case.
- **Inductive step `n → n+1`** (chunk 0015, quoted): assume `F0(z0)` and an increasing sequence
  `x1 < ⋯ < x_{n+1}` in `(z0,z1)` with `Fi(xi)`.
  1. By the **induction hypothesis** there is `y1 ∈ (z0, x_{n+1})` satisfying the bracket up to the
     modified top anchor `[α0, β1, …, α_{n−1}, βn, (αn ∧ β_{n+1} Until α_{n+1})](z0, y1)`.
     → *The chain-extension folds the (n+1)-th link's `Until` obligation into the n-th anchor.*
  2. In particular `y1 ⊨ (αn ∧ β_{n+1} Until α_{n+1})`, so **by `Until` semantics** there is
     `y2 > y1` with `y2 ⊨ α_{n+1}` and `β_{n+1}` holding along `(y1, y2)`.
  3. **The witness selection — a two-way `min`/case-split, not a `sup`:**
     - **if `y2 ≤ x_{n+1}`**: the required `z = y2` (done);
     - **else `x_{n+1} < y2`**: then `x_{n+1} ∈ (y1, y2)` and `β_{n+1}` holds along `(y1, x_{n+1})`,
       so the required `z = x_{n+1}`.
  In both branches `z ∈ (z0, z1)` is guaranteed (`y2` bounded by the `Until`-witness inside the
  bracket, `x_{n+1}` bounded by hypothesis). **This is the entire within-bracket witness rule.**

### 2.3 The ONLY place `inf`/`sup` (Dedekind completeness) is used

Not in the realizer step above. The `inf` enters **only** through the *first-point* predicate:

- Lemma 5.3, Case 2 (chunk 0014): `r0 = inf{z ∈ (z0,z1) | P1(z)}`.
- Lemma 5.1, Case 3 (chunk 0016): `r0 = inf{z ∈ (z0,z1) | ¬β1(z)}`, **definable** by the `∨∃∀`
  formula `INF^{¬β1}(z0, z, z1)` (eq. 5.3): `z0 < z < z1 ∧ (∀y)^{<z}_{>z0} β1(y) ∧ (¬β1(z) ∨
  K^+(¬β1)(z))`. Footnote 4: *"We will use only existence and will not use uniqueness."*

**Key faithfulness point (refines report 355/01, and corrects the task-prompt framing):** the
project's shorthand "Cor 5.4 inf/sup bounded witness selection" is only half the picture. The `inf`
is a **first-order-definable first-point** (`INF`, eq. 5.3), already formalized at k=1; the *realizer
recursion itself* is the Until-driven `min`/case-split of §2.2, which is **fully constructive** over
a discrete (integer) domain. There is **no unbounded/global choice** at the realizer step.

### 2.4 Reusable proof recipe (the deliverable for the Lean side)

```
realize(bracket [α0,β1,…,β_{n+1},α_{n+1}], z0, z1, F-chain x1<…<x_{n+1}):
  if n+1 == 1:  return fChainFrom base        -- landed k=1 template
  else:
    y1 := realize([α0,…,α_{n-1},βn,(αn ∧ β_{n+1} Until α_{n+1})], z0, x_{n+1}, x1<…<xn)   -- IH
    y2 := the Until-witness of (β_{n+1} Until α_{n+1}) at y1     -- ∃y2>y1, α_{n+1}(y2), β_{n+1} on (y1,y2)
    return (if y2 ≤ x_{n+1} then y2 else x_{n+1})                -- min/case-split, both ∈ (z0,z1)
```

Closure property that makes it work: `∨∃∀` closed under `∧, ∨, ∃` (Lemma 3.4) + `Until`-witness
existence + decidable `≤` on the domain. Dedekind completeness is consumed *only* to instantiate the
definable `INF` first-point (already available at k=1).

---

## 3. OTHER AUTHORS — the "or others" survey

Corpus searched: `~/Projects/Literature/sources/` (grep + direct reads). Findings per candidate:

| Source (doc_id) | Title / method | Within-bracket witness rule? | More formalizable than Rabinovich Cor 5.4? |
|---|---|---|---|
| **gabbay_1994** (GHR Vol 1, Ch 10) | Separation via **syntactic rewrite/elimination rules** (16 U-elim + 8 S-elim + K±/Γ± elim; Lemmas 10.3.11–10.3.17), induction on **nesting depth** | **No explicit semantic witness** — separation never constructs a point `z`; it rewrites `U`/`S` out syntactically | **No.** Needs ~24 completeness-dependent elimination equivalences transcribed + verified; Stavi `Γ±` connectives for gaps. Different architecture from the project's `∨∃∀`. |
| **hodkinson_2006** (Handbook Ch 11) | Survey; Kamp via **separation** (§4.6) and historically **EF-games** | No — game/rewrite, no bounded point-selection recipe | **No.** Game arguments give non-constructive witnesses; not a drop-in for a constructive realizer. |
| **kamp_1968** (original thesis) | Original expressive-completeness, **>100 pp, EF-games** (per Rabinovich §6, chunk 0018) | No constructive bounded-witness recipe | **No.** Explicitly the least tractable route. |
| **gabbay_1993** ("Expressive Completeness in the Presence of Gaps") | Stavi-connective extension for **gaps** | Tangential — targets the gap problem, not the within-bracket realizer | **No** for the realizer; *relevant only* to the project's separate Reynolds no-gaps bridge. |
| **reynolds_1994 / 2001** | Axiomatization/completeness (RTL, CTL*) | Completeness-side, not the expressive-completeness within-bracket witness | **No** — off-target for `hσ`. |
| **rabinovich_2014** (primary) | Direct `∨∃∀` normal form + closure-under-negation; Cor 5.4 ⇐ Until-driven `min`/case-split | **Yes — §2.2** | Baseline; the project already mirrors it. |

**Adversarial check** (can any alternative give a *cleaner* within-bracket witness?): No. Every
non-Rabinovich route replaces the explicit point-construction with either (i) syntactic elimination
(GHR) that never names a witness, or (ii) games (Kamp/Hodkinson) that are non-constructive. None
offers a bounded within-bracket witness-selection recipe that is more directly formalizable than
Cor 5.4's `min`/case-split induction. Rabinovich 2014 is *itself* the modern, streamlined "A Proof of
Kamp's Theorem"; there is no companion/earlier version in-corpus that supersedes its Cor 5.4 for this
step.

---

## 4. METHOD RECOMMENDATION

**Follow Rabinovich 2014 Corollary 5.4(1), the ⇐ direction, verbatim** (§2.2 recipe). Justification:

- **(a) Faithful to a citable source.** It is the exact lemma already used across the spine
  (Prop 4.2 = `nf_characterizable_temporal_prior`), and report 355/01 Q1 independently confirmed the
  interior/exterior split is Rabinovich's actual seam (Cor 5.4 interior vs. Lemma 7.6 adjacency). No
  new citation surface is introduced.
- **(b) Formalization-tractable.** The realizer is a **structural induction on chain length** that
  extends the **already-landed k=1 `fChainFrom`/`fChainPred` template by one Until-driven link**. The
  witness is a decidable `min`/case-split (`y2 ≤ x_{n+1}`), which is **constructive over the integer
  domain** — no `Classical.choice` at the realizer step, no unbounded search.
- **(c) Matches the arity-≤2 firewall + obligation scaffold the project already has.** The IH folds
  the top link into `(αn ∧ β_{n+1} Until α_{n+1})` — precisely the obligation-carrying reshape that
  tasks **356/357** deliver (`EndIntervalCorrectPrior`, per report 355/01 Q3/Q4). The realizer
  *consumes* that reshape; it does not need a new interior-gate biconditional.

### Lemmas the method secretly needs — flag before implementing

1. **Until-witness extraction** at the folded anchor: from `y1 ⊨ (β_{n+1} Until α_{n+1})` produce
   `y2 > y1`, `α_{n+1}(y2)`, `β_{n+1}` on `(y1, y2)`. Confirm the project's `Until` truth-lemma
   exposes this witness constructively (it should on the integer/Reynolds model). **This is the one
   genuine dependency to verify exists before landing.**
2. **Definable `INF` first-point** (eq. 5.3) at general k — already present at k=1; confirm it
   generalizes (it is a plain `∨∃∀` formula, so closure under `∀/∃` suffices — low risk).
3. **Decidable `≤` / trichotomy** on the domain for the `min` case-split — trivially available on
   the discrete (integer) model; this is why the *discrete* completeness terminus is the right place
   to land it.
4. The **n+2 arm (:364)** is the same induction with `n ≥ 2`; it is the general inductive step of the
   very recipe in §2.4, so landing :361 (n=1 = basis+one step) and the general step retires both.

---

## 5. ESCALATION HONESTY — green-viable vs. BLOCKED

**Verdict: GREEN-VIABLE, not BLOCKED.** The literature does **not** show this step to be a
hard/non-constructive selection. On the contrary, Rabinovich's Cor 5.4 ⇐ is an *explicitly
constructive* induction whose only "selection" is a decidable `min`/case-split, and whose only
completeness appeal is a first-order-*definable* first-point already formalized at k=1. This is a
threading/transcription task (extend the landed k=1 chain-link recursion by the induction of §2.4),
not open mathematics.

**Two honest caveats** (do not block, but scope the plan):
- The realizer *consumes* the task-356/357 obligation-carrying reshape (`EndIntervalCorrectPrior`)
  and the exterior discharge (Lemma 7.6, `hexclExt`). If those reshapes are not actually landed/green
  when 358 starts, 358 re-blocks at the *wiring*, not at the mathematics (report 355/01 Q3). Confirm
  356/357 are green first.
- Dependency #1 (constructive `Until`-witness extraction on the target model) is the single point
  that could turn this hard *if* the project's `Until` semantics only gives classical existence. On
  the discrete integer model it is constructive; verify before committing the plan.

Neither caveat is a mathematical obstruction — both are landed-scaffold checks. **Task 358 should
proceed to plan/implement following the §2.4 recipe.**

---

## Appendix — evidence base (absolute paths)

- Rabinovich 2014: `~/Projects/Literature/sources/rabinovich_2014/chunk_0011.md`–`chunk_0018.md`
  (Prop 4.2, Lemma 5.1, Lemma 5.3 chunk 0014, **Cor 5.4 chunk 0015**, Lemma 5.1 cases chunk 0016–0017,
  §6 Related Works chunk 0018).
- GHR Vol 1: `~/Projects/Literature/sources/gabbay_1994/ch1003_1033-eliminations.md`,
  `ch1004_1034-induction.md` (Lemmas 10.3.11, 10.3.14–10.3.17).
- Hodkinson Handbook Ch 11: `~/Projects/Literature/sources/hodkinson_2006/` (§4.6 Separation).
- Kamp 1968: `~/Projects/Literature/sources/kamp_1968_tense-logic-linear-order/` (EF-game route).
- Gaps: `~/Projects/Literature/sources/gabbay_1993/` (Stavi connectives).
- Grounding: `specs/349_.../reports/13_discrete-completeness-roadmap.md` §1–3;
  `specs/355_.../reports/01_rabinovich-faithfulness-and-deliverable-shape.md` Q1/Q3/Q4.
- Search: `literature-search.sh --toc rabinovich_2014`; corpus grep for
  kamp|gabbay|hodkinson|reynolds|venema across `sources/`.
