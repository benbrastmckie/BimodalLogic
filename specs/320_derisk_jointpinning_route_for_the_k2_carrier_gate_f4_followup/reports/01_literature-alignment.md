# Literature-Alignment Audit: Tasks 320/321 (routes b1/b2/b3) vs. Kamp's-Theorem Prior Art

**Task**: 320 — de-risk the joint-pinning route for the k=2 carrier gate (F4 follow-up)
**Audit target**: routes (b1)/(b2)/(b3) from spawn analysis `specs/309_.../reports/06_spawn-analysis-f4.md`,
and the goal statements of spawned tasks 320 and 321.
**Date**: 2026-07-07
**Task Type**: logic (literature alignment)

Sources consulted (navigated on demand, not dumped):
- PRIMARY: `/home/benjamin/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.md`
  (read in full) — Def 3.1 (md:61-74), Lemma 3.2 (md:76-79), Prop 3.5 (md:87-94), Prop 4.2 (md:100-101),
  Lemma 5.1 (md:134-135), Lemma 5.3 (md:137-152), Cor 5.4 (md:154-157).
- COMPARISON: `/home/benjamin/Projects/Literature/sources/gabbay_1994/ch902_93-separation-equals-expressive-complete.md`
  (Thm 9.3.1 separation⇒expressive completeness, md:1-112; Lemma 9.3.2 md:118-154; Cor 9.3.3 md:160-162);
  `.../ch1001_chapter-10-expressive-completeness-of-si.md` (§10.2 separation via eliminations, md:7-228).
- LOCAL: `specs/309_.../reports/06_spawn-analysis-f4.md`; the F4 verdict record
  `Theories/Bimodal/.../Kamp/NfMultiAnchorBridge.lean` (final section after :5533); tasks 320/321 in `state.json`.

---

## Summary Verdict

| Item | Verdict | One-line basis |
|------|---------|----------------|
| Route **b1** (repair pin channel to consume `witnessZone`) | **PARTIALLY ALIGNED** | Def 3.1 pinning is real, but it pins σ's OWN witnesses inside σ's OWN bracket — it has no counterpart for pinning across the provider/`e` boundary, which is the actual F4 gap. Expected NO-GO; valuable only as an F5-generator. |
| Route **b2** (structural-identity via `nf_eval_unique`/`nfPred_correct`) | **MISALIGNED** (as literature mechanism) | Neither Rabinovich nor Gabbay ever uses "uniqueness of the realizing environment" to fix a point. It is a Lean-encoding trick, not the paper's construction; and it inherits the same σ.2-exposure problem that defeats b1. |
| Route **b3** (nested F_i-chain / bracket recursion, Cor 5.4) | **ALIGNED** (literature-faithful) | Cor 5.4's `F_{i-1} := α_{i-1} ∧ (β_i Until F_i)` is exactly the nesting the paper uses; position identity rides the Until evaluation point, never a formula assertion. Cross-validated by Gabbay's single-anchor separation induction. |
| **Task 320** (probe ladder + GO-gate) | **PARTIALLY ALIGNED** | Right deliverable (a design spec), wrong order: it front-loads the two *least* faithful routes. Recommend promoting b3, boxing b1 as a fast falsifier, demoting b2. |
| **Task 321** (corrected carrier closes k=2 gate) | **ALIGNED, with a framing caveat** | Correct unit ONLY if "carrier" is read as "the Cor 5.4 recursive construction." Its description already leaves room for a "nested-bracket carrier," so it is not misaligned — but the flat-carrier reading would be. |

**Headline**: The F4 "flattening" defect is a genuine departure from *both* traditions in the corpus.
Rabinovich (composition) and Gabbay (separation) independently avoid ever asserting a joint
two-anchor positional identity inside a single-point formula. Rabinovich carries it via the
**nested Until evaluation point**; Gabbay carries it via **monadic re-coloring + single-anchor
reduction + separation elimination**. Route b3 is the faithful fix within the codebase's chosen
(Rabinovich) frame; b1/b2 are formalization-engineering patches that try to *solve* a problem the
literature *never creates*.

---

## Q1 — Is (b3) a faithful reading of Rabinovich's actual mechanism?

**Yes — b3 is faithful, and the F4 flattening is a genuine departure the paper never makes.**

Rabinovich conveys joint positional content between the two anchors by **nesting**, in three
layered mechanisms, none of which is a single-point positional assertion:

1. **Prop 3.5 (md:87-94) — single-free-variable core.** An exists-forall formula with *one* free
   variable at position `z_k` is translated to
   `A_k ∧ (B_{k+1} Until (A_{k+1} ∧ (B_{k+2} Until … (A_n ∧ □B_{n+1})…)))` (and the dual Since
   chain). The paper states the mechanism explicitly (md:94): "the interval decomposition directly
   maps to nested Until/Since." Crucially, each `A_{i}` is *evaluated at the point the previous
   Until step reached* — by the strict-Until semantics (md:41: "there exists t′>t such that F₂ at t′
   and F₁ on (t,t′)"). Position identity between successive anchors is carried **by the evaluation
   point**, never written as an equation in a formula.

2. **Cor 5.4 (md:154-157) — the exact shape route b3 names.** `F_n := α_n`,
   `F_{i-1} := α_{i-1} ∧ (β_i Until F_i)`. This is the same nesting specialised to the
   negation-closure recursion. "`[α_0,…,α_n](z_0,z)` holds iff there is an increasing sequence in
   `(z_0,z_1)` with `F_0(z_0)` holding" (md:157). The increasing sequence is recovered by *unfolding
   the nested Until*, so each `α_i` lands at its own witness position automatically.

3. **Prop 4.2 / Lemma 5.1 point-insertion (md:100-101, 159-173).** When a new point `z` is inserted,
   the bracket splits as `A_i⁻(z_0,z) ∧ A_i⁺(z,z_1)` (md:169-171). Each sub-bracket shares **exactly
   one** endpoint with the split point `z`; the joint content across the split rides the *shared
   endpoint z*, again a position, not an asserted identity.

The F4 defect ("flattening") is the landed `kvE'` design cramming an interior positive sub's joint
content into a *single* TL provider literal `P.existF 3 σ` evaluated at the one point `t`
(F4 record, NfMultiAnchorBridge.lean after :5533, "Machine probe B"). That literal's own private
existential `e : Fin 3 → M.carrier` rebinds `u/w/x`, producing the unpinnable residual `w = e 1`,
`x = e 2`. **Rabinovich never builds such an object.** In his construction the anchors are held
fixed *by the nesting*, so no formula ever needs to assert that an independently-bound point equals
a fixed anchor. b3 = "build what Cor 5.4 actually builds" is therefore a faithful reading, and the
refuted flattened design is something the paper does not do.

> Load-bearing citation chain: md:41 (Until semantics) → md:87-94 (Prop 3.5 nesting) →
> md:154-157 (Cor 5.4) → md:169-171 (Lemma 5.1 point-insertion split). Each step is the same
> "position-by-evaluation-point" principle.

---

## Q2 — Do (b1) and (b2) have any counterpart in the prior art?

**b1 — partial and misapplied.** Def 3.1 (md:61-74) is a real pinning discipline: "each `α_j(x_j)`
holds at `x_j`" and "each `β_j` holds along `(x_{j-1}, x_j)`" — every existentially chosen point
carries its point type *and* both adjacent interval types. So the *idea* the b1 repair invokes
(consume `witnessZone` + adjacent segment types per Def 3.1) is literature-grounded. **But Def 3.1
pins σ's own existential witnesses inside σ's own bracket's interval decomposition.** It says nothing
about, and provides no mechanism for, forcing an *externally supplied* environment (the provider's
`e`) to coincide with σ's witnesses. The provider/`e` boundary is a Lean-encoding artifact
(`ExistProviders.correct`, :4856) absent from the paper. The spawn analysis already anticipates this
("a zone-faithful pin only constrains σ's OWN fresh witness placement, not the provider's
independently-bound `e`", 320 description; report 06 lines 83-88). Verdict: b1 has a *partial*
counterpart (Def 3.1) that does not reach the actual F4 gap → expected NO-GO, but its refutation is
a legitimate, documentable F5-candidate.

**b2 — no counterpart as a construction.** Deriving `e 1 = w`, `e 2 = x` from
uniqueness-of-complete-types (`nf_eval_unique` NormalForm:245 / `nfPred_correct` NfToVecEA:69) has
**no analogue in Rabinovich or Gabbay**. Neither proof ever needs type-realization uniqueness,
because neither ever lets a second environment rebind the anchors: the anchors stay fixed by
construction (nesting for Rabinovich, monadic coloring for Gabbay — see Q3). b2 is a pure
formalization-engineering shortcut. Moreover it inherits the *same* obstruction that sinks b1: the
carrier only sees `nfk_projFresh σ` (the σ.1-level fresh type), and the F4 counterexample is
built precisely so the dishonest `σ'' = char[14,16,11,20]` shares σ.1 (`type(14)=type(15)`) with the
honest `char[14,15,10,20]` while differing at σ.2 (the joint inner structure) — F4 record, probe A.
`nf_eval_unique` operates on the *full* type σ, but the discriminating content lives in σ.2, which
the carrier collapses. So b2 would additionally require new plumbing to expose σ.2 — i.e. it does not
escape the joint-content problem, it relocates it.

**Is probing b1→b2→b3 a good use of the de-risking budget? No — it is inverted.** The order tests
the two *least* literature-faithful routes first, after F3→F4 already burned two consecutive
"add-another-channel-and-hope" rounds on flattening-style repairs. Both the primary source (Cor 5.4)
and the comparison source (Gabbay separation, Q3) point unambiguously at the nested/single-anchor
structure that only b3 embodies. Recommended reframing in Q4/Recommendations: keep b1 as a *tightly
boxed fast falsifier* (its NO-GO is cheap and its documentation strengthens the b3 case),
**demote b2** to a short conditional check (pursue only if the upstream selection lemma "σ IS the
honest quadruple's complete type at this obligation site" is already present — the spawn analysis
flags this is unverified, report 06 lines 96-99), and **lead the design work with b3**.

---

## Q3 — Does separation-based prior art suggest an alternative that avoids joint two-anchor pinning?

**Yes, and it confirms the diagnosis: the fix is structural (single-anchor per step), not a better pin.**

Gabbay's separation route (Thm 9.3.1, ch902 md:1-112) handles the inductive step `∃z ψ(t,z,Q̄)` — a
genuinely two-point (fixed `t`, bound `z`) problem — *without ever pinning `z` to `t`*:

1. **Convert the fixed anchor into monadic coloring** (ch902 md:17-21): introduce unary predicates
   `R_=(y)=(t=y)`, `R_>(y)=(t>y)`, `R_<(y)=(t<y)`. The relation of any point to the fixed anchor `t`
   becomes background *monadic* data, not a two-place constraint.
2. **Reduce to a single-anchor evaluation** (md:31-43): `∃z ψ'` is rewritten as
   `⋁_j [α_j(t) ∧ ∃z ψ_j(z, Q̄, R_=,R_>,R_<)]`, where each `ψ_j` has `z` as its *only* free variable.
   The induction hypothesis then supplies a temporal wff `A_j` evaluated **at z alone**, and `Q_∃`
   (`Pq ∨ q ∨ Fq`, "somewhere") does the existential (md:45).
3. **Eliminate the auxiliary anchor-coloring by separation** (md:69-112): the `r_=,r_>,r_<` atoms are
   removed by substituting the pure-past/pure-present/pure-future values licensed by the separation
   property — because at `t` the past/present/future coloring of `t` is determined.

The §10.2 integer proof (ch1001 md:7-228) realises separation *syntactically* as "pull every U out
from under every S and vice versa" (md:11, Lemma 10.2.8 junction-depth induction) — again the joint
nesting is *dissolved into pure-past/pure-future components*, never asserted as a cross-point identity.

**Direct answer to the sub-questions.** The GPSS/separation proofs *never* pin an existentially
chosen point to two fixed anchors. They structure the induction so every temporal step is
**single-anchor** (evaluate at one point over an expanded, monadically-recolored signature). This is
the *same* principle as Rabinovich's Prop 3.5 nesting (Q1): joint content is carried by evaluation
position / background coloring, never by a single-point positional equation. The F4 architecture is
the outlier in the entire corpus.

**Would the Gabbay alternative be a smaller or larger departure than b3?** **Larger.** The
task-308/309 asset base is committed to Rabinovich's *composition* method — every landed asset is
Rabinovich-shaped (`A_past`/`A_future`, `VVecEA2`, `bracketFromLists`, and notably
`fChainFrom`/`fChainPred` which the codebase itself labels "Cor 5.4 candidate shapes",
task 320 constraints). Adopting Gabbay separation would mean re-architecting to the eliminations +
monadic-recoloring machinery, which the codebase does not have. So the *practically* smaller
departure is **b3 (nested F_i chain), reusing the landed Cor 5.4-shaped assets** — with Gabbay's
single-anchor principle used only as independent cross-validation that b3 is the right target, not as
a construction to import.

---

## Q4 — Verdict per spawned task

### (a) Task 320 — probe ladder and GO-gate deliverable

**PARTIALLY ALIGNED.** The *deliverable* (a machine-checked GO/NO-GO per route plus a concrete design
spec for the viable route, or an F5 defect record) is well-conceived and matches the F1-F4 house
style. The *ordering* is misaligned with the prior art: b1→b2→b3 probes the least-faithful routes
first. Recommended, citation-grounded, reframing:

1. **Keep b1, but box it as a fast falsifier** (≤~20% of probe budget). Its expected NO-GO is a
   legitimate F5-candidate (Def 3.1 pins within-bracket, not across the provider boundary — md:61-74),
   and documenting *why* strengthens the b3 decision. Do not invest in "making b1 work."
2. **Demote b2 to a conditional micro-check.** Only pursue if the upstream selection fact ("σ is the
   honest quadruple's complete type at the per-sub obligation site") is *already* derivable; the
   spawn analysis flags this as unverified (report 06 lines 96-99). b2 has no construction-level
   literature backing (Q2) and inherits the σ.2-exposure obstruction (F4 probe A). If the selection
   fact is absent, record it and move on — do not build new plumbing speculatively.
3. **Promote b3 to the primary design target from the start** (Cor 5.4 md:154-157, cross-validated by
   Gabbay single-anchor separation, ch902 md:17-45).
4. **Add a litmus criterion to the GO-gate**: a route is GO only if it carries the joint content by an
   **evaluation point / nesting** (Rabinovich) rather than by a single-point formula assertion. This
   is the exact property that separates a faithful fix from another flattening patch, and it would
   have predicted the F3→F4 failures a priori.

### (b) Task 321 — is "corrected carrier closing the k=2 gate" the right unit?

**ALIGNED, with a framing caveat.** If b3 wins (as the prior art strongly indicates), the fix is a
**recursive formula construction** (the Cor 5.4 F_i-chain for positive interior subs), *not* a better
static "carrier." Rabinovich's own resolution is a recursion, not a richer per-sub literal collection
(md:154-157). So the phrase "corrected carrier" *would* be a misalignment **if** read as "a flat
carrier with more channels" — that reading is exactly the F1→F4 failure mode. However, task 321's
description already anticipates the nested outcome ("or an appropriately named nested-bracket carrier
per Task 0's spec"), so the *unit* is acceptable: it is a single implementation task consuming task
320's design spec, with the mandatory F4 ℤ-counterexample as the adversarial gate. Recommendation:
in task 321's eventual plan, make explicit that "carrier" denotes the Cor 5.4 recursive construction
(a formula-building recursion over interior subs), so the "carrier" abstraction is not mistaken for
another flattening round. The abstraction is not itself the misalignment — *a flat reading of it
would be.*

---

## Recommendations for Task 320's Plan (actionable)

1. **Reorder the probe ladder to b1(fast-falsify) → [b2 conditional micro-check] → b3(primary design).**
   Rationale: Cor 5.4 (md:154-157) + Gabbay separation (ch902 md:17-45) both single-anchor; b1/b2 are
   the least faithful and should not consume the bulk of the budget.
2. **Adopt the "position-by-evaluation-point" litmus** as the GO criterion (Q4a.4). Any candidate that
   asserts a two-anchor positional identity inside a one-point formula is a flattening patch and should
   be rejected on sight, before machine-probing.
3. **Scope the b3 probe to a minimal nested-Until sub-bracket** using the landed `fChainFrom`/
   `fChainPred` (EANegation:552/:567, the codebase's Cor 5.4 candidate shapes) — demonstrate that
   evaluating the nested chain at the honest point recovers the honest positions *without* any
   `e`-to-anchor equation. This is the demonstrated-closed crux goal task 321 needs.
4. **Cite per G5 at each chain step**: Def 3.1 (md:61-74) for the pinning discipline, Prop 3.5
   (md:87-94) for the single-free-variable nesting, Cor 5.4 (md:154-157) for the F_i recursion,
   Lemma 5.1 (md:159-173) for the point-insertion split. Use Gabbay ch902 md:17-45 as a margin note
   that the single-anchor reduction is corpus-wide, not Rabinovich-idiosyncratic.
5. **If b1 and b2 NO-GO (expected):** record the F5 defect with the sharpened diagnosis "the joint
   content is inexpressible in the flattened per-sub-literal `ExistProviders` architecture because the
   literature carries it structurally (nesting / monadic coloring), never by single-point assertion" —
   and route directly to b3 rather than a third channel round.

---

## Adversarial Self-Verification

| # | Claim (load-bearing) | Source / Counterexample | Verdict |
|---|----------------------|-------------------------|---------|
| 1 | Rabinovich Prop 3.5 translates a **single-free-variable** exists-forall formula, via nested Until/Since. | Rabinovich md:87-94 ("Every V-exists-forall formula with **one free variable** … equivalent to a TL formula"; explicit nested `Until` chain md:91). | **SUPPORTED** |
| 2 | Cor 5.4 nesting carries position by the **evaluation point**, not a formula assertion. | Cor 5.4 md:154-157 (`F_{i-1}:=α_{i-1}∧(β_i Until F_i)`) + Until semantics md:41 (`F_i` holds at the reached `t′`). Deductive, not stated verbatim as "position identity" — but follows directly from strict-Until semantics. | **SUPPORTED (inferential)** |
| 3 | Gabbay converts the fixed anchor `t` into **monadic** predicates `R_=,R_>,R_<` and reduces `∃z ψ` to a **single-free-variable** eval at `z`. | Gabbay ch902 md:17-45 (verbatim: introduce `R_=(y)=(t=y)` etc.; `ψ_j(z,…)` with `z` the only bound; `A_j` evaluated at `z`; `Q_∃`). | **SUPPORTED (verbatim)** |
| 4 | Def 3.1 pinning constrains σ's **own** witnesses within σ's **own** bracket, not an external environment; the provider/`e` boundary is absent from the paper. | Def 3.1 md:61-74 (`ψ(z_0,…,z_m)` with existential `x_i`, `α_j(x_j)`, `β_j` on `(x_{j-1},x_j)` — one formula's internal decomposition). No environment/provider notion anywhere in the paper. | **SUPPORTED** |
| 5 | b2's uniqueness-of-realization has **no** construction-level counterpart in Rabinovich or Gabbay. | Absence check across Rabinovich (full read) and Gabbay ch902/ch1001: neither uses type-realization uniqueness; both keep anchors fixed by construction. Absence-of-evidence, so stated as "no counterpart as a *construction*," not "impossible." | **SUPPORTED (as scoped)** |
| 6 | b3 is a **smaller** departure than Gabbay because the codebase is Rabinovich-shaped, incl. `fChainFrom`/`fChainPred` = "Cor 5.4 candidate shapes." | Task 320 constraints + report 06 lines 199-200 label these assets as Cor 5.4 shapes. This is the **codebase's own** labelling; I did not independently read `EANegation.lean:552/:567`. | **SUPPORTED w/ MEDIUM confidence** (relies on codebase self-description; a task-320 probe should confirm the shapes actually match Cor 5.4 before full build) |
| 7 | The F4 counterexample's `σ''` shares σ.1 (fresh type) with the honest sub but differs at σ.2, so σ.1-only channels can't discriminate — defeating b1 and complicating b2. | F4 record, probe A (`type(14)=type(15)`, byte-identical channel-(i) content) + spawn report 06 lines 20-26, 42-47. | **SUPPORTED** |
| 8 | b1/b2 are "solving a problem the literature never creates." | Synthesis of claims 2,3,4: both traditions keep anchors fixed by construction, so the rebinding-`e` residual `w=e1,x=e2` is an artifact of the flattened Lean encoding, not an intrinsic feature of Kamp's theorem. | **SUPPORTED (inferential synthesis)** |

**Residual risks to the audit's own conclusions:**
- Claim 6 (MEDIUM): the "smaller departure" recommendation assumes `fChainFrom`/`fChainPred` genuinely
  match Cor 5.4. If a task-320 probe finds they do not, b3's cost estimate rises (though its *faithfulness*
  verdict is unaffected — that rests on Cor 5.4 md:154-157 directly).
- Claim 2 (inferential): "position by evaluation point" is derived from Until semantics, not quoted as a
  sentence in Rabinovich. The inference is standard TL semantics and low-risk, but it is an inference.
- b2 verdict is scoped to "not the literature's *mechanism*." It does **not** claim b2 is mathematically
  unsound — it may close if an upstream selection lemma exists. The audit's recommendation (conditional
  micro-check) is calibrated to that uncertainty rather than a flat rejection.
