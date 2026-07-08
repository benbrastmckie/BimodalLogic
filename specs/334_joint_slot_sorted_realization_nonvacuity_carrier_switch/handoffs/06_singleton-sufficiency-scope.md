# Task 334 Handoff 06 — Singleton-vs-Joint scope: faithfulness-first verdict

- **Agent**: lean-research-hard-agent (H2+H3+H4+H5), read-only. No `Theories/` edits.
- **Priority frame (coordinator reframe)**: decide by what **Rabinovich's proof actually does** at
  the relevant depth (Cor 5.4 / Lemma 3.2 at n≤1), NOT by the cheapest Lean route. Recommend
  singleton only if it is the faithful transcription.
- **Primary sources**: Rabinovich 2014 (`Literature/sources/rabinovich_2014/…md`), read at the
  cited lines; codebase at HEAD `8e2c8abf7`.

---

## 1. VERDICT (one line)

**JOINT REQUIRED** — multi-owner (≥2 positive-sub) characterization is genuine Rabinovich content
(**Lemma 3.2(1)**, md:77) and is **not faithfully available anywhere in the codebase**; the
singleton fragment characterizes only a proper subclass and is a cost-driven **divergence**, not a
faithful transcription. **But** the specific joint construction tasks 333/334 built — the monolithic
joint *sort* over a flatMap slot list validated by the **additive open-zone compat filter
`kvE2_sepValid`** — is itself a **Lean-convenient divergence**, not the faithful realization. The
faithful rebuild is the **roadmap fallback / Option B** (order-type disjunction + region partition +
point-type channel, per handoff 04), **not Option A** (disjunctive filter on the existing carrier).

Net: *the multi-owner problem is on the critical path; the 333/334 carrier that tried to solve it is
not.* Do NOT retreat to singleton, and do NOT rebuild the additive filter.

---

## 2. Precise dependency trace (code + paper, file:line)

**Root goal.** `completeness_discrete` — `BXCanonical/Completeness.lean:276`. Blocked by exactly
two live sorries, both in `nf_nvar_exist_all_depths` (`KampPrior.lean:212`):

- **`KampPrior.lean:351`** — the `n = 1` arm: build a temporal formula for
  `∃ env : Fin 1, nf_eval_nf M (k+1) 2 (insertEnv env t) sub_nf`, i.e. characterize a **depth-(k+1)
  arity-2 NF** as a two-anchor bracket. ROADMAP:30/51 labels this exactly **"the depth-k≥2 Cor 5.4
  F_i-chain converter."**
- **`KampPrior.lean:354`** — the `n+2` arm, commented off-critical-path (caller needs only n=0,1).

**The bridge is imported but unconsumed.** `KampPrior.lean:4` imports `NfMultiAnchorBridge`; the
only occurrence of the bridge in `KampPrior.lean` is that import line (grep-confirmed). Every
`kvE2_sep*` lemma has **zero live consumers** outside `SharedWitness.lean` (grep over `Theories/`).
The wiring that will consume it is the not-yet-attempted **task 309 Phase 13.4/14** (ROADMAP:36). So
the singleton-vs-joint branch is decided by the *intended design*, reasoned from the paper, not by
current call edges.

**Where the branch is decided — the positive-sub count of the qnf.** In the bridge, the object
characterized is `qnf : NormalForm sig 2 3`; its quantifier layer `qnf.2 : NormalForm sig 1 4 → Bool`
records, per depth-1 arity-4 sub-type σ, whether a witness of type σ exists. The "owners" are the
positive subs `kvE2_sepPos qnf` (`SharedWitness.lean:193`). The branch predicate is:

- `kvE2_sepSingleton qnf := ∀ σ σ', qnf.2 σ = true → qnf.2 σ' = true → σ = σ'` — **at most one
  positive sub** (`SharedWitness.lean:1944`).

The general carrier `kvE2_sepBody` (`:685`) admits arbitrarily many positive subs; the joint
obligation is `kvE2_sepBody_nonvacuous` (`:1191`) over `kvE2_sepArrL/R` (`:474/:479`) filtered by
`kvE2_sepValid` (`:466`). The Phase-10 decision gate **retreated to N2 = singleton**
(`SharedWitness.lean:1922-1939`) precisely because the multi-owner "O4" obligation FAILed under the
additive filter. Consequences visible in the current code:

- There is **no general `kvE2_sepBody_complete`** — grep count 0. Multi-owner completeness was never
  even stated after the O4 failure.
- `kvE2_sepBody_singleton := kvE2_sepBody` **definitionally** (`:1962`, `rfl`). "Singleton" is a
  *scope predicate* on the same monolithic carrier, **not** a per-owner building block.
- The two remaining strategic sorries are both singleton lemmas: `kvE2_sepSingleton_coverage_left`
  (`:2069`, sorry `:2093`) and `kvE2_sepBody_singleton_complete_left` (`:2212`, sorry `:2225`).

**Why the branch resolves to JOINT (paper).** A depth-(k+1) NF's quantifier layer is an *unordered*
set of positive witness-type requirements: `⋀_{σ positive} (∃x, type_σ(x))` conjoined with the
universal (β / negative) constraints over all of (x,t). Converting an unordered conjunction of
existentials into (V-)exists-forall brackets is exactly **Rabinovich Lemma 3.2(1)** — "conjunction
of exists-forall ≡ **disjunction** of exists-forall" (md:77) — i.e. a finite disjunction over the
*consistent relative orderings/merges* of the owners' witnesses, with interval (β) types merged on
overlaps. This is genuinely invoked whenever `qnf` has ≥2 positive subs, which arbitrary formulas
produce (the two-owner σ,τ instance is exhibited in handoff 05). The singleton restriction covers
only the one-positive-sub subclass.

**Cor 5.4 vs Lemma 3.2(1) — the layer distinction (why :351's label is not the whole story).**
Cor 5.4's F_i chain (`F_n:=α_n`, `F_{i-1}:=α_{i-1} ∧ (β_i Until F_i)`, md:154-157) is the
translation of a **single** bracket `[α_0,…,α_n]` — one owner, many ordered points, handled by a
nested Until. The **multi-owner** combination is a *different* paper step, Lemma 3.2(1), used above
the F_i chain (in Lemma 5.1's induction `A_i = A_i^- ∧ A_i^+`, md:168-173, and Prop 4.3's
conjunction closure). :351 is labelled the Cor 5.4 converter, but the arity-2 NF it must characterize
carries an unordered multi-positive-sub quantifier layer, so the converter's completeness pulls in
Lemma 3.2(1). The two are not substitutes.

---

## 3. H4 adversarial pass — what it changed (and the reversal it survived)

I pursued, then **refuted**, a "singleton suffices faithfully" line:

- **Hypothesis (steelman for SINGLETON):** Rabinovich builds each owner's bracket separately and
  combines them by Lemma 3.2(1)/3.4 conjunction closure — which the codebase already has,
  **sorry-free**, in `VecEAClosure.lean` ("Conjunction Closure (Lemma 3.2.1 + 3.4)", `:42`). If so,
  the per-owner (≈singleton) bracket is the faithful unit and the monolithic joint carrier is
  unnecessary.
- **Refutation (decisive, code-cited):** `VecEAClosure`'s conjunction closure is **lossy and
  forward-only**. In the general case where *both* owners have witnesses
  (`BracketFormula.conj_to_bracket_exists`, `:87-98`; `conjStruct`, `:121-122` / proof `:163-169`):
  it `obtain`s `h2` and then **discards it** (`obtain ⟨_,_,_,_,_,_,_⟩ := h2`), keeps only bf1's
  points, and sets **every** merged segment type to `TemporalPred.top` (the comment even says "The
  existential only requires SOME bracket formula to hold"). That proves only
  *conjunction ⟹ a weaker bracket holds*, **not the equivalence** Lemma 3.2(1) asserts. It is
  sorry-free only because it serves the weaker **negation-closure induction** (docstring `:102-104`),
  where one implication suffices. It does **not** merge the two owners' interval decompositions.

So the faithful Lemma 3.2(1) merge (as an equivalence, with interval-type merge and coincidence
handling) is **genuinely absent** from the codebase. That kills the "singleton + existing
conjunction closure" route and confirms **JOINT REQUIRED**.

Adversarial check in the other direction (is joint an over-strong artifact, like the refuted
mergeSort?): **partly yes, about the *carrier*, not the *requirement*.** Handoff 04's full-paper
audit already established (HIGH confidence) that the paper has **no joint total sort** (md:77,
168-173); the monolithic joint *sort* and the flatMap slot list are the divergence. But that audit
also concludes the multi-owner *combination itself* is required and faithfully realized as an
**order-type disjunction** (Option B), not dropped. My VecEAClosure finding independently confirms
the requirement cannot be discharged by the existing closure. Both agree: requirement real, 333/334
carrier wrong.

**What the pass changed:** it moved me off an initial "SINGLETON SUFFICES (via VecEAClosure)"
draft after reading `VecEAClosure.lean:87-98/163-169` and finding the general-case conjunction
vacuously weak. The verdict is JOINT REQUIRED with the carrier caveat below.

---

## 4. Is the additive open-zone filter a faithful realization of Lemma 3.2(1)? — NO

Coordinator's explicit ask. The current Lean carrier is `kvE2_sepSlotsL := (kvE2_sepPos qnf).flatMap
kvE2_sepSlotsLFor` (a single flat slot list over all owners), whose permutations are validated by
`kvE2_sepValid` reading, per cross-owner pair, one owner's **open-zone** fold bit
(`kvE2_sepCompat_lX1_eq`: `.lX1 σ` reads `zXU`; `_after_eq`: reads `zUW`). Faithfulness assessment
(corroborated by handoff 04 §3 divergence table and handoff 05's Lean-checked refutation):

- **Rabinovich Lemma 3.2(1)/Def 3.1 (md:61-74, 77):** owners combine by a **disjunction over
  relative order-types** of the merged point set; coincident witnesses are **identified into one
  shared point carrying the meet type** (§5, md:168-173). There is **no total sort** and no
  open-only zone bookkeeping.
- **Lean carrier:** a **fixed** flat slot list (foreign slot `.lXU τ χ` is *permanently present*),
  a single total point order, and **strict-open-only** extractor channels (`SubBracket2.lean:614-624`,
  `x<v<x1`, `x1<v<w`, …) with **no closed/point channel**. It structurally cannot represent
  point-identification.
- **The Lean-checked refutation (handoff 05):** the faithful coincident-anchor discharge produces
  σ's **closed** self-zone bit `zAtX1L`, but `kvE2_sepValid` reads σ's **open** bits `zXU`/`zUW`;
  `zAtX1L=(false,false)·…` vs `zXU=(true,false)·…` differ in coordinate 0 ⇒ `nf0_assemble` distinct
  keys ⇒ independent bits ⇒ `exact h` type-mismatches at the type-checker; `kvE2_sepBody_nonvacuous`
  is FALSE for the full carrier.

**Conclusion:** the additive open-zone compat filter is a **Lean-convenient divergence**, faithful
only in its ⇒ (soundness) direction (compat = exact fold bit, handoff 03 ledger) but unable to
express the ⇐ / coincidence merge that Lemma 3.2(1) requires.

---

## 5. Which rebuild is faithful — Option B (roadmap fallback), not Option A

- **Option A (disjunctive filter zXU ∨ zAtX1L ∨ zUW on the existing carrier):** adds the at-anchor
  disjunct so the closed-zone bit can be consumed. It encodes "before/at/after placement" (a step
  toward the order-type disjunction) but **keeps the divergent flatMap slot list and additive-filter
  framing** — the very structures handoff 04 §3 flagged as having no paper analogue. It patches the
  symptom, not the architecture. **Not the faithful choice.**
- **Option B (roadmap fallback, re-scoped per handoff 04 §4):** replace the single joint sort with a
  **disjunction over the finite relative order-types of the merged anchor set**
  `{x1_σ : σ ∈ kvE2_sepPos} ∪ {w}`; within each disjunct reuse the **already-faithful, already-proven
  region partition** `k1v_sorted_realization3` (`SubBracket2V.lean:379`) + per-region insertion
  `k1v_sorted_realization` (`CarrierK1V.lean:1447`) over the merged anchors; add a **closed/point-type
  channel** to `kvE_subBracket2_complete_extract` (`SubBracket2.lean:606`) discharging coincidences
  via "x1_σ realizes χ" (`charK` is existential — the fact that made the coincidence *unpreventable*
  is exactly what *discharges* it). This is the direct transcription of **Def 3.1 (interval
  decomposition) + Lemma 3.2(1) (order-type disjunction) + §5 (meet-type coincidence)**. Size
  ~700-1050 lines (305/reports/37 §4.4), but it reuses the proven region engine — not a green-field
  fifth carrier.

**Recommendation:** `/revise 334` onto **Option B**. Abandon the additive-filter carrier
(kvE2_sepValid/kvE2_sepArrL/R/joint sort) and the singleton retreat. Preserve as reusable inputs:
`k1v_sorted_realization`/`_3`, `kvE2_sepHonestBundleL`, the four compat leaves (correct per
disjunct), `kvE_subBracket2_complete_extract`, and `kvE_subBracket2V`'s single-owner correctness
pair (each owner's bracket).

---

## 6. On the "prior finding" (two terminal blockers are singleton lemmas)

Factually correct about the **current code** (`kvE2_sepSingleton_coverage_left` :2093 and
`kvE2_sepBody_singleton_complete_left` :2225 are the two open strategic sorries on the intended
wiring). But this reflects the codebase's **N2 retreat to singleton** after the O4/nonvacuity
failure — a cost-driven divergence — **not** faithful sufficiency. "Terminal blocker is singleton"
is a *symptom* of the divergence, and does not support "singleton suffices."

---

## 7. Confidence + what would raise it

**Confidence: MEDIUM-HIGH.**

Strong support: paper (Lemma 3.2(1) md:77; Def 3.1 md:61-74; Cor 5.4 md:154-157; §5 coincidence
md:168-173); handoff 04's independent full-paper audit (HIGH); the decisive code fact that
`VecEAClosure`'s general-case conjunction is lossy/forward-only (`:87-98`, `:163-169`); absence of
any general `kvE2_sepBody_complete`; handoff 05's type-checker refutation of the additive filter.

Residual uncertainty (why not HIGH): the live outer gate `bracketEndChar_kvE2` / `kvE2_body` is a
**stale-monolith reference** (docstrings cite `:5032`/`:8608`/`:8712`, which do not exist in the
split files; no live `def` anywhere — grep-confirmed) — it has not yet been rebuilt by task 321 v4.
Its stated fold `kvE2_outer_fold` (NavigatedSpine `:66`) is `atomLayer ∧ ∀σ, (∃x1, …)`. If, once
rebuilt, the gate's **completeness** direction genuinely reduces to *independent* per-σ witnesses
without cross-σ interval-type consistency, a per-σ route could suffice and the verdict would soften
toward "singleton per-owner + a real conjunction closure." The whole 333/334 effort, the retrospective
root obstruction ("a joint two-point/interval/relative-order property cannot be a single-point
formula", 322/reports/02:25), and the refuted nonvacuity all indicate the joint interval-consistency
IS needed — hence MEDIUM-HIGH, not lower.

**What would raise to HIGH:** (a) rebuild/read the live `bracketEndChar_kvE2`/`kvE2_body` def (task
321 v4) and confirm its completeness direction requires cross-σ region consistency (joint) rather
than only per-σ existence; (b) a Lean spike proving the point-type/closed channel on
`kvE_subBracket2_complete_extract` at `v = x1_σ` closes (handoff 04's own confidence-raiser), which
also de-risks Option B.
