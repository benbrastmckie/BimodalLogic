# Divergence Audit — kvE2_body Joint-Channel Redesign Viability (Task 321, Phase 10)

**Task**: 321 — implement corrected k=2 carrier and close the correctness gate (F4 resolution)
**Dispatch**: hard-mode blocker research / divergence audit (H2/H3/H4/H5), `--lit` active
**Session**: sess_1783452940_63339e
**Date**: 2026-07-07
**Focus**: divergence audit — kvE2_body joint-channel redesign viability (soundness vs completeness bidirectional `.holds`)

---

## VERDICT (the deliverable)

**Option 1 is NOT viable. Option 2 is NOT viable at the flat-carrier / BracketFormula level.
Task 321 must ESCALATE — spawn a prerequisite lemma task (specified in §Determination 3).**

The residual is now isolated to a **single irreducible datum**: `kvE_subBracket2V_sound_of_parts`
(the landed Phase-10 consumer, `NfMultiAnchorBridge.lean:7449`) requires the hypothesis
**`hx1t : x1 < t`** (`:7456`) — an *upper* bound on the recovered sub-anchor inside the outer
interval. Everything else soundness needs is recoverable:

| sound_of_parts input (:7456-7476) | Recoverable from the flat-spliced `fChainPred @ u`? | Basis |
|---|---|---|
| `x1` with `charK (nfk_projFresh σ)` (anchor) | YES — unfold chain to `ptX1` position | `fChainFrom_step` :616 |
| `hxx1 : x < x1` | YES — `x1 > u > x` (u from outer extract) | `k1v_bracket_extract` :2150 |
| `hbelow` (zXU witnesses in `(x, x1)`) | YES — `lXU` block precedes `ptX1` in the increasing chain | `bracketFromLists3` layout :6614 |
| `hgate` (6-conjunct ∀-a bundle) | YES — supplied by the outer `kvE_gate` | `kvE2_body` gate :8245 |
| **`hx1t : x1 < t`** | **NO — the chain is strictly upward and UNBOUNDED ABOVE** | `fChainFrom_base` :585 / `_step` :622 |

The `fChainPred` chain asserts, at each step, `∃ s > x` with **no a priori upper bound**
(`fChainFrom_base` :585 `∃ s, x < s ∧ …`; `fChainFrom_step` :622 `∃ s, x < s ∧ F_{i+1}(s) ∧ …`).
So a `fChainPred` spliced as a flat point-type in the outer witness list can place `x1` *above*
`u`, but can never certify `x1 < t`. This is **identical** to the documented obstruction at
`EANegation.lean:1232-1242` ("the Until witnesses give points `s > x0` … but there is no a priori
bound `s < z1`"), now surfacing at the outer→sub wiring rather than at the negation-closure step.

**Why this is the same wall a fourth time (320 → 324 → 325 → 321-P10):** bounding a temporal
witness *from above* inside an interval is a **structural bracket operation** (Rabinovich Lemma 5.1
point-insertion split `A_i⁻(z₀,z) ∧ A_i⁺(z,z₁)`, md:169-171), **not** something a single-point
formula in a flat witness slot can assert. Completeness gets `x1 < t` for free — the witnessing
honest model supplies the bound (`kvE_subBracket2V_complete` :7717 destructures a *given* honest
realization). Soundness must *recover* the bound from an unbounded formula, and cannot. That
asymmetry is the entire F4 saga in one line.

---

## H3 — Lemma-Level Mapping Table (5-column)

| Claim | Lean identifier | file:line | Direction it proves | Closes the gate obligation? |
|---|---|---|---|---|
| Outer bracket `.holds` decomposes to per-slot single-point realizations | `k1v_bracket_extract` | `NfMultiAnchorBridge.lean:2150` | outer `.holds` → `∀ p ∈ lL, ∃u∈(x,w), p.eval_at u` | Partial — yields `fChainPred @ u`, NOT `.holds` |
| Sub-bracket `.holds` → honest realization (needs `.holds`) | `kvE_subBracket2V_sound` | `:7370` | sub `.holds` → `∃x1, nf_eval σ` | Would close IF `.holds` were available (it is not) |
| Same, `.holds`-free — needs `(x1<t, anchor, hbelow, hgate)` | `kvE_subBracket2V_sound_of_parts` | `:7449` | `(x1, hxx1, hx1t, hanchor, hbelow, hgate)` → `∃x1', nf_eval σ` | Would close IF `hx1t : x1<t` were derivable (it is not) |
| Every zXU-positive bit → below-anchor witness (needs `.holds`) | `kvE_subBracket2V_reaches_zXU` | `:7246` | sub `.holds` → `∃u<w, charBase χ @ u` | Requires `.holds` input — same gap |
| Honest realization → sub `.holds` (produces `.holds`) | `kvE_subBracket2V_complete` | `:7717` | honest σ → sub `.holds` | Closes COMPLETENESS (forward); irrelevant to soundness |
| Bracket `.holds` → fChainPred (forward Cor 5.4) | `BracketFormula.bracket_implies_fChainPred` | `EANegation.lean:660` | `.holds` → `fChainPred @ x0` | Forward only — wrong direction for soundness |
| fChainPred → bracket `.holds` (reverse Cor 5.4) | *none — `sorry`* | `EANegation.lean:1217-1249` | fChainPred → `.holds` | **DOCUMENTED UNPROVABLE** (model-independent, interior-witness convention) |
| fChain step semantics (unbounded-above witness) | `fChainFrom_base` / `fChainFrom_step` | `EANegation.lean:580` / `:616` | `F_i(x) ↔ α_i(x) ∧ ∃s>x, …` | Root cause: `∃s>x` has no upper bound |
| Model-dependent negation-closure (Cor 5.4 fwd, model-dep) | `neg_bounded_exists` | `EANegationClosure.lean:492` | `¬(∃z bf.holds) → ∃v VBracket.holds` | Not a `fChainPred→bracket` reverse; does not help |
| VVecEA2 negation/composition (Prop 4.2, model-dep) | `neg_2var_vec_ea` | `EANegationClosure.lean:720` | `¬vea.holds → ∃v VVecEA2.holds` | Point-insertion machinery; candidate for a nested carrier, not the current flat wiring |
| Splice site (321-owned, editable) | `kvE2_body` `ptSub` | `NfMultiAnchorBridge.lean:8232` | `ptSub σ := kvE_subChain2V σ` (flat fChainPred list) | The channel under audit |
| Non-vacuity at honest σ (Phase 8, landed green) | `kvE2_joint_nonvacuous_at_honest` | `:8306` | honest σ → `disjuncts ≠ []` | Holds; unaffected by verdict |

**Grep-confirmed:** no lemma of shape `fChainPred → holds` / `orderedPointsExist → holds` /
`holds_of_fChainPred` exists anywhere in `Kamp/*.lean`. The reverse direction is a `sorry`
(`EANegation.lean:1249`) and is the only such gap.

---

## H5 — Divergence Table (churn on the k=2 sub-witness boundedness target)

| Attempt | Approach | Where it broke | Failure reason (file:line) |
|---|---|---|---|
| Task 320 (b1/b2/b3 probes) | pin provider `e` to anchors / uniqueness / nested F_i | design | b1/b2 solve a non-problem; b3 (nested F_i) named as the only faithful route (320 report `01`:25-29) |
| Task 321 v3 Phase 8 (orig `kvE_subBracket`) | single upward `Until` chain from σ-slot `u` | soundness | chain cannot reach `zXU` *below* `u`; `kvE_subBracket_implies_subChain` runs bracket→chain (wrong direction) (`02_spawn-analysis.md`:5-11, 30-43) |
| Task 324 | (superseded by 325) | — | same F4 root cause |
| Task 325 | built `kvE_subBracket2V` + matched `.holds` sound/complete pair; `kvE_subChain2V` reaches all three zones | delivered the sub-kit, left wiring | the sub-kit is a matched `.holds` pair; getting `.holds` at the *outer* slot was never in scope |
| Task 321 v4 Phase 8 re-point | point `ptSub` at `kvE_subChain2V σ` (flat fChainPred list, `++`-spliced one-point-per-entry) | Phase 10 soundness | extraction yields `fChainPred @ u`, not `.holds`; reverse `fChainPred→.holds` unprovable (`.orchestrator-handoff.json` blockers[0]) |
| Task 321 v4 Phase 10 (this audit's subject) | feed `kvE_subBracket2V_sound` / redesign to expose `(anchor, hbelow)` | soundness | **isolated residual = `x1 < t`; unbounded-above fChainPred cannot supply it** (this report) |

**Postmortem — root cause:** every attempt has tried to carry a **bounded interior sub-witness**
(`x < x1 < w < t`) through a **flat, single-point temporal-formula slot** of the outer carrier.
The temporal object language can assert "a witness exists *above* here" (`Until`/`∃s>x`) but not
"a witness exists *below* `t`" without the structural point-insertion split (Lemma 5.1). The flat
`VVecEA2`/`bracketFromLists` carrier has no split hook. Four dispatches have re-encountered this
same upper-boundedness wall under different names (zXU-reachability, direction-mismatch,
`.holds`-recovery, `x1<t`).

---

## Determination 1 — Is Option 1 architecturally coherent? **NO.**

Option 1 asks: can the outer bracket witness list carry a genuine `(kvE_subBracket2V σ).holds`
per sub, so `k1v_bracket_extract` on the joint slot yields `.holds` (not a flat point)?

**Type-level impossible.** The outer carrier `kvE2_body : VVecEA2` is a disjunction of flat
`VecEA2 n` brackets built by `bracketFromLists (slotsFor lL) ptW (slotsFor lR) segL segR`
(`:8244`). Its witness list `slotsFor lL : List TemporalPred` (`:8235`) holds **point types**
(`TemporalPred = { formula : Formula }`, evaluated at a single point via `eval_at`).
`k1v_bracket_extract` (`:2150-2162`) decomposes such a bracket into, per entry `p`,
`∃ u, x < u ∧ u < w ∧ p.eval_at M atomMap u` — a **single-point evaluation**, never a `.holds`.
A `VVecEA2.holds` is a nested existence statement over a sub-interval; it cannot be an element of
`List TemporalPred`, and it cannot be the output of `eval_at` at one point.

The only thing a point slot *can* carry is a `Formula` (which may contain `Until`/`Since`, e.g.
`fChainPred`). Recovering `(kvE_subBracket2V σ).holds` from any single-point `Formula` evaluation
is exactly the reverse Cor 5.4 direction `fChainPred → .holds`, **documented unprovable**
model-independently (`EANegation.lean:1217-1249`). No choice of slot Formula escapes this: it is a
property of the flat-carrier *shape*, not of the particular content.

Even the weaker, model-*dependent* route (unfold the `fChainPred` `Until`s at the specific model
`M` to recover the ordered witnesses, à la Rabinovich md:60-61 "recover the increasing sequence by
unfolding the nested Until") recovers `hbelow` and the anchor **but not `x1 < t`** — the chain
walks strictly upward and unbounded (`fChainFrom_base` :585, `_step` :622). Since
`sound_of_parts` (`:7456`) takes `hx1t : x1 < t` as a hard hypothesis, and it is used immediately
(`:7482` `hgate x1 hxx1 hx1t hanchor` to derive `x1 < w`), the residual cannot be discharged.

The carrier type `BracketEndCharCarrierV sig 2` / `VVecEA2` is on the **byte-identical
do-not-edit** list (task-325 VVecEA2 block; F3 anchor-cap fixes two anchors at 2). So the
genuinely-nested carrier that *would* carry a bounded `.holds` (bracket-of-brackets with a
shared-endpoint split, Lemma 5.1 md:169-171) cannot be introduced by editing `kvE2_body` alone —
`kvE2_body` must return a `VVecEA2`, whose slots are unavoidably flat point types.

**Conclusion:** Option 1 is incoherent within task 321's fixed constraints. The `reaches_zXU`
route (`:7246`) it names *requires `.holds` as input* (`:7253`), which is exactly what cannot be
manufactured at a flat slot.

---

## Determination 2 — Ripple / the bidirectional crux. **A single flat slot cannot satisfy both directions.**

The forward completeness direction (Phases 12-14) consumes `kvE_subBracket2V_complete` (`:7717`),
which *produces* `.holds` from a **given** honest realization — the honest model hands it the
bounded `x < x1 < w < t` (`:7737-7745`). Forward is provable precisely because boundedness is
*given*, not *recovered*: the direction used is `bracket_implies_fChainPred` (`EANegation:660`,
forward). This is why the flat `kvE_subChain2V` splice makes completeness closeable while soundness
is blocked — the exact split the handoff reports.

The crux the F4 saga circles: **can ONE joint-channel shape satisfy both directions?** No — and
here is the model-independent reason. A single flat point-type slot `p` is *one Formula*.
Soundness needs `p.eval_at u → (bounded sub-structure)` (reverse). Completeness needs
`(bounded sub-structure) → p.eval_at u` (forward). Having both, model-independently at the
BracketFormula level, **is** the Cor 5.4 biconditional that report 18 §10.3 ruled out
(`EANegation.lean:1220-1223`). Any Option-1 redesign that strengthens the slot to make soundness's
reverse work must, by that biconditional's unprovability, either (a) break the forward direction,
or (b) smuggle in the boundedness the reverse needs — which a flat slot structurally cannot hold.

Additional completeness risk for Option-1-style redesigns (MEDIUM confidence): `kvE_subChain2V σ`
is the list of **all** arrangement `fChainPred`s (`:6787-6791`, a `flatMap` over
`S_XU.permutations × S_UW.permutations × S_WT.permutations`), and `slotsFor` splices the whole
list as **required** outer witnesses (`:8235-8236`). An honest σ realizes only the *sorted*
arrangement; other orderings' `fChainPred`s are not realizable at the honest points. Any redesign
that makes soundness recover per-arrangement structure risks converting this latent tension into an
outright completeness break. `kvE2_joint_nonvacuous_at_honest` (`:8306`) proves only non-emptiness
of `disjuncts`, not simultaneous realizability of every spliced chain — so it does not retire this
risk.

**Conclusion:** the redesign that fixes soundness (carry bounded structure) is exactly the one that
endangers the forward completeness that currently closes. The two directions cannot be reconciled
inside a single flat point-type slot.

---

## Determination 3 — Verdict and escalation spec

Neither Option 1 nor Option 2 is viable within task 321's binding constraints (F3, G1-G6,
Corrected Anchor-Cap, fixed `VVecEA2` carrier, byte-identical task-325 block). **Escalate.**

### What to spawn (recommended: ONE prerequisite lean4 task)

**Title:** *Bounded point-insertion composition for the k=2 sub-witness (supply `x1 < t` at the
outer→sub wiring).*

**Task type:** lean4. **Depends on:** none (task 321 depends on it; resume via `/revise 321` v5).

**Sole deliverable — one standalone, machine-verified lemma** (name at implementer's discretion,
e.g. `kvE_subBracket2V_holds_of_outer` or `kvE2_sub_bounded_recover`), stated against the outer
bracket data, proving:

> Given the outer bracket's soundness-side data over `(x, t)` — the outer witness `w` with
> `x < w < t`, the per-slot extract `fChainPred @ u` for the sub σ's spliced chain with
> `u ∈ (x, w)`, the outer segment classification on `(x, w)` (`segL`), and the outer gate —
> produce the **bounded** sub-anchor: `∃ x1, x < x1 ∧ x1 < t ∧ (charK (nfk_projFresh σ)).eval_at x1
> ∧ hbelow(x1)`, i.e. exactly the `(x1, hxx1, hx1t, hanchor, hbelow)` bundle that
> `kvE_subBracket2V_sound_of_parts` (`:7449`) consumes.

The proof MUST establish `x1 < t` structurally, not from the unbounded `fChainPred` alone. The two
literature-faithful mechanisms to investigate (in priority order):

1. **Point-insertion split (Rabinovich Lemma 5.1, md:169-171; Prop 4.2).** Restructure the
   outer→sub relationship as a *shared-endpoint composition* `A⁻(x, x1) ∧ A⁺(x1, t)` where the
   sub-bracket lives in the bounded left factor. Candidate landed asset to consume:
   `neg_2var_vec_ea` (`EANegationClosure.lean:720`) / `neg_interval_formula` (`:398`) — the
   VVecEA2 point-insertion/negation machinery. This is model-dependent (needs `HasAttainedINF`),
   which is available at the soundness site and is exactly the regime the codebase's own note
   sanctions (`EANegation.lean:1244-1247`: "the model-DEPENDENT version … proves both directions
   sorry-free").
2. **Bounded-above `Until` from the outer `w`-anchor.** Use the outer witness `w` (with `w < t`)
   plus the outer left-segment `segL` on `(x, w)` to cap the sub-chain: if the sub-anchor's
   `charK` type can only occur below `w` (forced by `segL`'s exclusion literals), then `x1 < w < t`
   follows. This must be checked against `segL`'s actual content (`:8212-8215`); if `segL` does not
   exclude `charK`-carrying points, this route fails and route 1 is mandatory.

**Litmus gate (from 320 report `01`:210-212, restated):** the delivered lemma is GO only if it
carries the boundedness by an **evaluation-point / structural split** (Rabinovich), NOT by a
single-point relative-position assertion between independently-bound variables. `x1 < t` recovered
via `neg_2var_vec_ea` composition PASSES; `x1 < t` asserted as a formula literal `x1 < e_i` FAILS
(that is the F4 flattening relapse).

**After it lands:** `/revise 321` to a v5 that re-points Phase 10 at the new lemma → feed
`kvE_subBracket2V_sound_of_parts` (already landed) → Stage C soundness closes. Phases 12-14
(completeness) are unaffected (they already close via `kvE_subBracket2V_complete`), **provided**
the v5 revision does NOT alter the `kvE_subChain2V` splice shape — the new lemma must consume the
*existing* flat splice's extract, not require a new joint-channel shape (which would reopen the
Determination-2 completeness risk).

### Why NOT Option 2 as a standalone

Option 2 ("reverse `fChainPred → bracket` under a non-interior-witness convention") is a **strict
subset** of the escalation and is insufficient alone: any *model-independent* reverse at the
BracketFormula level is the §10.3-refuted biconditional; a *model-dependent* reverse still leaves
the `x1 < t` boundedness gap unless it is a *bounded* (point-insertion) reverse. The escalation
above IS the correct, bounded, model-dependent form of Option 2 — folded together with the
composition restructure so the boundedness is delivered, not merely the ordered witnesses.

### Compliance check on the recommended route

- **F3 (no provider pinning):** route 1 uses interval composition, no `e`-rebinding, no
  `w = e_i` literal. PASS.
- **G4 / Anchor-Cap (two anchors fixed at 2):** the outer anchors stay `{x, t}`; `x1`, `w` remain
  bracket *witnesses*. PASS.
- **G3 (no trivial-top segments):** unaffected; `segL`/`segR` retained verbatim.
- **Carrier = Cor 5.4 recursive construction, not single-point relative position:** the litmus
  gate enforces this. PASS by construction.
- **Non-vacuity:** consume `kvE2_joint_nonvacuous_at_honest` (`:8306`) at the wiring boundary as
  Phase 8 already does.
- **Do-not-edit:** the new lemma is additive; `kvE2_body`/`bracketEndChar_kvE2`/`two_eq` remain
  321-owned and are touched only by the later v5 re-point, not by the spawned task.

---

## Literature Grounding (--lit) — cross-check

Rabinovich 2014 (`.../rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.md`) and the 320
alignment audit (`specs/320_.../reports/01_literature-alignment.md`) confirm the obstruction is
**fundamental to the flat-splice encoding, not to the mathematics**:

- **Cor 5.4 (md:154-157)** states the biconditional `[α_0,…,α_n](z_0,z) holds iff ∃ increasing
  sequence with F_0(z_0)` **for a fixed structure** (model-dependent). The paper recovers the
  sequence "by unfolding the nested Until" (320 report `01`:60-61) — a model-dependent operation.
  It never claims the *model-independent* reverse, which is exactly the `EANegation:1249` `sorry`.
- **Lemma 5.1 point-insertion (md:169-171)** is where boundedness lives: the bracket splits as
  `A_i⁻(z_0,z) ∧ A_i⁺(z,z_1)`, each factor sharing the split point `z`. Boundedness of an interior
  witness is carried by the **shared endpoint of a structural split**, never by a formula
  assertion (320 report `01`:63-66). This is precisely the `x1 < t` mechanism the flat splice
  lacks.
- Rabinovich (composition) and Gabbay (separation, 320 report `01`:123-160) **both** avoid asserting
  a bounded interior witness inside a single-point formula. The F4 flat-splice is the outlier in the
  entire corpus (320 report `01`:31-37, 149-150).

So: the prior art carries the nested content **bidirectionally only via structural nesting /
shared-endpoint splits**, and its reverse direction is **model-dependent unfolding, not a
single-point formula reverse**. This confirms the flat one-point-per-entry splice is a genuine
departure that cannot be repaired in place — the obstruction is in the encoding, and the fix
(structural point-insertion composition) is exactly what the escalation task must build.

---

## H4 — Adversarial Self-Verification

I attempted to REFUTE the verdict (i.e. to show Option 1 *is* viable) before endorsing escalation.

### Claim Verification Table

| Claim | Source / Counterexample tried | Verification Method | Verdict |
|---|---|---|---|
| `k1v_bracket_extract` yields point-eval, never `.holds` | Tried: could a `TemporalPred` slot encode a nested `.holds`? No — `eval_at` is single-point | `lean_hover_info`-equivalent: read signature `:2154-2162` | SUPPORTED (High) |
| Outer carrier is flat `VVecEA2`; slots are `List TemporalPred` | Tried: is there a nested-bracket disjunct variant? `bracketFromLists`/`VecEA2` are flat | Read `kvE2_body` `:8235-8244`, `bracketFromLists3` `:6609-6621` | SUPPORTED (High) |
| Reverse `fChainPred → .holds` is unprovable model-independently | Tried: grep for any reverse lemma across `Kamp/*.lean` | grep — only the `:1249` `sorry` matches | SUPPORTED (High) |
| `sound_of_parts` requires `hx1t : x1 < t` | Could it be optional / derivable inside? Read body: used at `:7482` to derive `x1 < w` | Read signature `:7456` + body `:7482` | SUPPORTED (High) |
| `fChainPred` chain is unbounded above (`∃ s > x`, no upper bound) | Could the top `Until (β Until top)` bound it? `top` gives any `s`; no cap | Read `fChainFrom_base` `:585`, `fChainFrom_step` `:622` | SUPPORTED (High) |
| Model-dependent unfold recovers `hbelow` + anchor but not `x1 < t` | Could `x1 < t` come from the outer left region `(x,w)`? `x1` is *above* `u` in the sub-chain, unbounded; nothing forces `x1 < w` or `< t` | Deductive from chain monotonicity + `bracketFromLists3` layout `:6614` | SUPPORTED (High) |
| A single flat slot cannot satisfy both directions | Is the Cor 5.4 biconditional provable somewhere? §10.3 ruled it out at BracketFormula level | Read `EANegation:1220-1223` | SUPPORTED (High) |
| `neg_2var_vec_ea` is the point-insertion asset for the escalation | Does it directly give the forward bounded wiring? It is a *negation*-closure lemma, not forward composition | Read `:720` header + `neg_bounded_exists` `:492` | SUPPORTED as *candidate to investigate* (Medium) — the spawned task must confirm it yields a forward bounded recover |
| Completeness of the flat splice is currently closeable | Could splicing ALL arrangement `fChainPred`s break it? Genuine tension; not proven either way here | Read `kvE_subChain2V` `:6787`, `slotsFor` `:8235`; handoff asserts fwd closes | PARTIALLY SUPPORTED (Medium) — flagged as a MEDIUM risk, not asserted as a break |
| The obstruction is encoding-level, not mathematical | Does Rabinovich carry `.holds` bidirectionally flat? No — via structural split (md:169-171) | 320 report `01`:31-37, 60-66; Rabinovich md:154-171 | SUPPORTED (High) |

### Contradiction Log

No hard contradictions between sources. One tension resolved by precedence:

- **Machine source vs. task framing.** The task framing entertains Option 1 as "preferred if
  viable." The machine evidence (`sound_of_parts:7456` hard `hx1t` hypothesis + `fChainFrom`
  unbounded-above semantics) overrides the framing: Option 1's named route (`reaches_zXU` off a
  carried `.holds`) is type-level unavailable. **Resolution:** machine/source evidence outranks
  task-prompt optimism; verdict = not viable. No unresolved contradiction.

### Recommendations modified after verification

- Initially considered endorsing a pure model-dependent `fChainPred`-unfold lemma as "Option 2
  viable." **Retracted** after confirming the unfold cannot supply `x1 < t` (unbounded chain).
  Revised to require a *bounded* point-insertion composition (escalation route 1), of which the
  unfold is only a component.
- Downgraded the completeness-break claim from "breaks" to "MEDIUM risk / must-not-alter-splice
  constraint on the v5 revision," since I could not machine-verify simultaneous non-realizability
  of all spliced arrangements.

### Confidence summary

- Option 1 not viable: **High.** Option 2 (standalone) not viable: **High.** Escalation required:
  **High.** Recommended escalation *route 1 (point-insertion) closes it*: **Medium** — the spawned
  task must confirm `neg_2var_vec_ea`/`neg_interval_formula` compose into a forward bounded recover;
  this is the one genuinely-unbuilt piece and could itself surface a further obstruction (in which
  case the carrier-type-change escalation, or abandoning the flat-carrier route, becomes the
  fallback).

---

## Memory Candidates

1. **F4 boundedness crux (task 321 P10):** the entire k=2 soundness residual reduces to one datum
   — `x1 < t` (upper bound on the interior sub-anchor). A `fChainPred` spliced into a flat outer
   witness slot recovers the anchor, `x < x1`, and `hbelow` (via model-dependent Until-unfold) but
   NEVER `x1 < t`, because `fChainFrom_base/_step` assert `∃ s > x` with no upper bound. Bounding a
   temporal witness from above is a structural bracket operation (Rabinovich Lemma 5.1
   point-insertion, md:169-171), not a single-point formula assertion — this is why 320/324/325/321
   all hit the same wall.
2. **Flat-slot bidirectionality is the §10.3 biconditional.** Requiring one flat point-type slot
   `p` to satisfy both `p.eval_at u → bounded sub-structure` (soundness reverse) and the forward
   (completeness) IS the Cor 5.4 biconditional at BracketFormula level, ruled unprovable
   model-independently (`EANegation:1220-1223`). Completeness closes only because the honest model
   *gives* the bound; soundness must *recover* it and cannot. Diagnostic: if a carrier redesign
   claims to fix soundness by strengthening a flat slot, it either breaks completeness or smuggles
   in boundedness a flat slot cannot hold.
