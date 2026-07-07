# Proof Strategy — Bounded Sub-Anchor Recovery for k=2 Sub-Witness Soundness (Task 326)

**Task**: 326 — bounded point-insertion composition lemma for the k=2 sub-witness (supply `x1 < t`
at the outer→sub wiring)
**Dispatch**: hard-mode lean4 research (H2/H3/H4), `--lit` active
**Session**: sess_1783452940_63339e
**Date**: 2026-07-07
**Focus**: proof strategy + adversarial provability verification
**All file:line references are to the CURRENT tree** (`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/`),
which has been re-numbered since the task-321 audit (report 03) — the audit's line numbers are stale.

---

## VERDICT: **PROVABLE-WITH-CAVEAT**

The lemma is provable, but **NOT by the mechanism the escalation audit assumed, and NOT as literally
scoped ("recover `x1` from the flat `fChainPred @ u`").**

The task-321 divergence audit (report 03) concluded ESCALATE on the premise that the recovered
anchor `x1` must come from the spliced `fChainPred`'s internal chain point (`ptX1`), which is
**genuinely unbounded above** — and that recovering `x1 < t` would therefore require the reverse
Cor 5.4 direction (documented unprovable) or a Rabinovich Lemma 5.1 point-insertion restructure of
the splice (forbidden). **I verified the audit's unboundedness claim is correct for the fChainPred's
internal `ptX1`** (§Make-or-Break) — the transitivity hope `u < w < t ⟹ x1 < t` is a **trap**.

**However, the audit overlooked a second, already-bounded source of the `charK` anchor: the outer
carrier's PIN SLOTS.** `kvE_pinDisjunct` (`NfMultiAnchorBridge.lean:5374-5379`) emits
`⟨charK (nfk_projFresh σ)⟩` as a genuine **outer-bracket witness point type**, spliced into
`slotsFor lL` (`:8236`) — the LEFT list of `bracketFromLists (slotsFor lL) ptW …` (`:8244`). By
bracket monotonicity every left witness is pinned strictly in `(x, w_outer) ⊂ (x, t)`. So the outer
`.holds` **directly supplies a `charK` witness `q` with `x < q < w_outer < t`** — the bounded anchor
`hanchor` + `hx1t`, with **no reverse Cor 5.4 and no splice restructure**. The bound is STRUCTURAL
(the pin slot's position left of the `ptW` slot), satisfying the litmus (never an `x1 < e_i`
literal).

**The caveat** (why not a flat PROVABLE): the new lemma must be stated to consume the **pin-slot
extract** (and use an order-preserving extraction), not solely the `fChainPred @ u` the audit and
the current Phase-10 wiring pass. The single genuinely-unproven step is **`hbelow` assembly** —
showing every `zXU`-positive base type has a `charBase`-witness *below the pin anchor `q`*. This is
discharged by the fChainPred F_0 below-witnesses + permutation coverage (§Skeleton Phase 4), but it
is combinatorially non-trivial and is the make-or-break residual risk.

---

## The Make-or-Break Determination (Task Determination 1) — answered with evidence

**Question**: is the sought `x1` the sub-chain's realized anchor, and does `x1 < t` follow by
transitivity through `w` (`u < w < t`), or does `x1` sit ABOVE `w`?

**Answer**: For the fChainPred's internal anchor `ptX1`, **`x1` sits above `w` in general — the
transitivity route is a trap.** For the pin-slot anchor, **`x1 < w_outer < t` holds structurally.**
Two different points both carry `charK (nfk_projFresh σ)`; the lemma must use the second.

Evidence:

1. **fChainPred layout puts `ptX1` above the base.** `bracketFromLists3` (`:6609-6621`) has point
   types `lXU ++ ptX1 :: lUW ++ ptW :: lWT`, so `ptX1` is at chain index `lXU.length`. `fChainPred`
   = `fChainFrom ⟨0⟩` (`EANegation.lean:567-569`). When `lXU` is **non-empty** (the case that
   matters — `lXU` non-empty is exactly when there are `zXU` below-witnesses, i.e. when `hbelow` is
   non-vacuous), `ptX1` is strictly above the base point `u` and above the `lXU` points, at chain
   distance `≥ 1`.

2. **The chain is unbounded above — the endpoint is DROPPED.** `fChainFrom_base` (`EANegation.lean:583-587`)
   asserts `∃ s, x < s ∧ (∀ r ∈ (x,s), segWT r)` — an `∃ s > x` with **no upper bound**. When a
   bracket is the SOURCE (`bracket_implies_fChainPred` :660, base case :693), the witness supplied
   is the right endpoint `z` (`(hrange ⟨n⟩).2`), but the `fChainFrom_base` **formula never records
   `s = z`**. So a flat `fChainPred` re-evaluated at `u` in the outer witness slot genuinely places
   `ptX1` anywhere above `u`, including above `w_outer` and above `t`. **The audit is correct on
   this point** (report 03 Determination 1, `EANegation.lean:1244-1247`).

3. **The outer `segL` cannot re-impose the bound.** From `k1v_bracket_extract` (`:2150-2162`,
   conjunct 5, `:2159`) the outer `segL` classification covers only `u ∈ (x, w_outer)`. A chain
   point `ptX1` that escapes above `w_outer` is **outside `segL`'s jurisdiction**; `segL` says
   nothing about it. So `segL` cannot bound `x1`.

4. **The pin slot is the bounded charK source the audit missed.** `kvE_pinArrangements σ`
   (`:5364-5366`) = `kvE_consistentZones.map (z => ⟨z, nfk_projFresh σ⟩)`; `kvE_pinDisjunct`
   (`:5374-5379`) returns `([⟨charK a.witnessType⟩], [⟨charK a.witnessType⟩])`. These pin point
   types enter `slotsFor lL` via `ptSub σ ++ pinSlots σ` (`:8233-8236`) → the LEFT list of the outer
   `bracketFromLists` (`:8244`). Bracket monotonicity (the `ws` increasing sequence inside
   `IntervalPattern.holds`, exploited by `k1v_bracket_extract` :2164-2166) forces every left witness
   strictly into `(x, w_outer)`. Since `w_outer < t` (the `ptW` slot, `:2155`), the pin witness `q`
   satisfies `x < q < w_outer < t`. **Bounded, structurally, from `.holds`.**

**Ordering that the sub-anchor must satisfy**: honest order is `x < x1 < w_outer < t` (confirmed by
`kvE_sub2V_zone_consistent` :7522-7526, order `x < x1 < w < t`, and `kvE_subBracket2V`'s zone
layout :6644-6667). The pin anchor `q` realizes `x < q < w_outer < t`; the fChainPred F_0
below-witnesses `u_i` realize `x < u_i < q` (they precede the pins in the same σ-block of
`slotsFor lL`, hence below `q` by monotonicity). This matches the `sound_of_parts` bundle exactly.

---

## H3 — Lemma-Level Mapping Table (5-column, MANDATORY)

| Claim | Lean name | file:line | What it proves | How it discharges a bundle component |
|---|---|---|---|---|
| Consumer needs `(x1, hxx1, hx1t, hanchor, hbelow, hgate)` | `kvE_subBracket2V_sound_of_parts` | `NfMultiAnchorBridge.lean:7449-7504` | the target bundle → `∃x1', nf_eval_nf [x1',w,x,t] σ` | This IS the consumer the new lemma feeds; note `hgate` at `:7462` takes `a<t` as INPUT and yields `a<w` at `:7482` — the gate CANNOT supply `hx1t`, it consumes it |
| Pin slots carry `charK` anchor | `kvE_pinDisjunct` | `:5374-5379` | pin point types = `[⟨charK (nfk_projFresh σ)⟩]` | supplies `hanchor` (charK at `x1`) as a bounded outer witness |
| Pin family is nonempty, one per consistent zone | `kvE_pinArrangements` | `:5364-5366` | `= consistentZones.map (⟨·, nfk_projFresh σ⟩)` | guarantees ≥1 pin slot exists whenever σ ∈ outer `lL` |
| Pins are LEFT outer witnesses (⇒ `< w_outer < t`) | `kvE2_body` (`slotsFor`, `mkDisjunct`) | `:8233-8244` | `slotsFor lL = flatMap (ptSub σ ++ pinSlots σ)`; left of `ptW` | supplies `hxx1` (`x<x1`) + `hx1t` (`x1<t`) STRUCTURALLY via monotonicity |
| Bracket `.holds` → per-witness realization + `w<t` bound | `k1v_bracket_extract` | `:2150-2162` | `.holds → ∃w, x<w<t ∧ (∀p∈lL,∃u∈(x,w), p@u) ∧ segL-class` | gives the pin realization in `(x,w_outer)` and `w_outer<t`; **but forgets ordering** — see caveat |
| fChainPred F_0 = charBase of the arrangement's first `zXU` type | `bracketFromLists3` + `fChainFrom_step` | `:6613-6614`, `EANegation.lean:616-625` | `fChainPred @ u ⟹ (pointTypes 0)@u`; `pointTypes 0 = ⟨charBase χ⟩` | supplies one `hbelow` below-witness per arrangement (`charBase χ @ u_i`) |
| Every `zXU` type is F_0 of some arrangement (perm coverage) | `kvE_subChain2V` | `:6757-6791` | list = `S_XU.permutations.flatMap …`; each χ∈S_XU is first in some perm | supplies `hbelow` coverage: ALL `zXU` types get a below-witness |
| Anchor bound from a GENUINE sub-`.holds` (the intended design) | `kvE_subBracket2V_reaches_zXU` | `:7246-7260` | sub-`.holds` → `∃u w, z0<u<w<z1 ∧ …charK@w` | shows `w<z1=t` is what `.holds`/`extract` gives and the flat splice loses — motivates the pin substitute |
| fChainFrom base drops the upper endpoint (root of unboundedness) | `fChainFrom_base` | `EANegation.lean:580-587` | `F_n(x) ↔ α_n(x) ∧ ∃s>x, seg on (x,s)` | confirms the fChainPred `ptX1` route CANNOT bound `x1` — REFUTES the transitivity hope |
| Reverse `fChainPred → .holds` is unprovable | — (`sorry`) | `EANegation.lean:1249` | (the documented gap) | confirms the pin route is the ONLY viable bounded source (no reverse) |
| `HasAttainedINF` first-occurrence bound (point-insertion) | `HasAttainedINF.first_occ_tp` | `EANegationClosure.lean:58-63` (used :439) | type occurs in `(z0,z1)` → FIRST occurrence in `(z0,z1)` | **NOT usable**: its precondition `∃x∈(z0,z1), type@x` is exactly what the flat extract cannot supply for charK; superseded by the pin route |
| Prop 4.2 negation closure (audit's proposed asset) | `neg_2var_vec_ea` | `EANegationClosure.lean:720-729` | `h_INF → ¬v.holds → ∃v', v'.holds` | **NOT applicable**: a negation-closure lemma producing a NEW carrier; does not bound a GIVEN chain point — refutes audit route 1 |
| Lemma 5.1 negation (audit's proposed asset) | `neg_interval_formula` | `EANegationClosure.lean:401-407` | `h_INF → ¬bf.holds → ∃v VBracket, v.holds` | **NOT applicable** for the same reason; its bound flows from `first_occ_tp`'s occurrence precondition |
| Non-vacuity at honest σ (consume verbatim) | `kvE2_joint_nonvacuous_at_honest` | `:8306-8316` | honest σ → `disjuncts ≠ []` | consumed at the wiring boundary; unaffected |

---

## Proof Skeleton (≤5 phases, each ~one agent run)

**Statement to prove** (new additive lemma, name e.g. `kvE_sub2V_bounded_anchor_of_outer`):

> Given the outer bracket data for a single `σ ∈ posIn zXW` at the soundness site — the outer
> `.holds` (or an order-preserving extract of it) over `(x, t)` with witness `w_outer`
> (`x < w_outer < t`), from which σ's pin slots and σ's `kvE_subChain2V` fChainPred slots are
> realized — produce `∃ x1, x < x1 ∧ x1 < t ∧ hanchor(x1) ∧ hbelow(x1)`, i.e. exactly the
> `(x1, hxx1, hx1t, hanchor, hbelow)` bundle `kvE_subBracket2V_sound_of_parts` (`:7449`) consumes.

- **Phase 1 — Order-preserving outer extraction.** Prove/adapt an extraction stronger than
  `k1v_bracket_extract` (`:2150`) that returns the monotone witness sequence `ws` (the `hmono` from
  `IntervalPattern.holds`, already surfaced in `bracket_implies_fChainPred` :670), not just
  per-element existence. Output: the realized points for σ's block `ptSub σ ++ pinSlots σ` in
  strictly-increasing order, all in `(x, w_outer)`. *~100-200 lines.*

- **Phase 2 — Bounded anchor from a pin.** Select the first pin witness `q` for σ (index
  `|ptSub σ|` within σ's block). Establish `x < q`, `q < w_outer < t` (⇒ `hx1t`), and
  `⟨charK (nfk_projFresh σ)⟩.eval_at q` (⇒ `hanchor`) from the pin point type
  (`kvE_pinDisjunct` :5379). *~60-120 lines.*

- **Phase 3 — fChainPred F_0 below-witnesses.** For each arrangement fChainPred slot realized at
  `u_i` (all `< q`, preceding the pins in σ's block), extract `(pointTypes 0).eval_at u_i` via
  `fChainFrom_step`/`_base` (`EANegation.lean:616`/`583`); identify `pointTypes 0 = ⟨charBase χ_i⟩`
  where `χ_i` is arrangement `i`'s first `zXU` type (`bracketFromLists3` :6613-6614). *~100-180 lines.*

- **Phase 4 — `hbelow` assembly (HARDEST — see below).** For an arbitrary `zXU`-positive `χ`
  (`σ.2 (nf0_assemble kvE_sub2_zXU χ σ.1) = true`, i.e. `χ ∈ S_XU`), exhibit the arrangement whose
  `lXU` permutation starts with `χ` (`List.permutations` coverage over `kvE_subChain2V` :6787-6791),
  read its F_0 below-witness `u_χ < q` from Phase 3, and conclude
  `∃u, x < u < q ∧ ⟨charBase χ⟩.eval_at u`. This is `hbelow(q)`. *~150-250 lines — may need
  a `List.permutations` "each element is some permutation's head" helper.*

- **Phase 5 — Bundle + feed the consumer.** Package `(q, hxx1, hx1t, hanchor, hbelow)` and, with the
  outer gate hypothesis `hgate`, invoke `kvE_subBracket2V_sound_of_parts` (`:7449`). Verify against
  the actual Phase-10 wiring (task 321 v5 `/revise`). *~40-80 lines.*

**The single hardest step**: **Phase 4 (`hbelow` assembly)**. Two independent risks: (a) the
`List.permutations` coverage lemma (every element of `S_XU` heads some permutation) may not exist
locally and needs proof; (b) the order-preserving extraction (Phase 1) must be strong enough to
place ALL fChainPred F_0 points strictly below the chosen pin `q` — this depends on the σ-block
contiguity `ptSub σ ++ pinSlots σ` (`:8236`) surviving the `flatMap`, which is true structurally
but must be threaded through the monotone indexing. If either sub-step fails, the fallback is to
prove `hbelow` from a genuinely bounded sub-`.holds` — which reopens the reverse-Cor-5.4 wall and
would flip the verdict to NOT-PROVABLE-AS-SPEC.

---

## H4 — Adversarial Self-Verification (MANDATORY)

I attempted to REFUTE provability, then to refute my own pin-slot rescue. The pin route survived;
the residual risk is isolated to Phase 4.

### Claim Verification Table

| Claim | Source / Counterexample tried | Verdict |
|---|---|---|
| `hgate` cannot supply `hx1t` (it consumes `a<t`) | Read `:7462` (takes `a<t`) → `:7482` (`hgate x1 hxx1 hx1t hanchor` derives `a<w`). Tried: is `hx1t` derivable inside? No — used as input | **SUPPORTED (High)** |
| fChainPred internal `ptX1` is unbounded above (transitivity trap) | `fChainFrom_base` `:585` is `∃s>x` with no cap; `bracket_implies_fChainPred` base `:693` supplies `z` but the FORMULA drops it. Tried: does `segWT`/the top `Until` bound `s`? No | **SUPPORTED (High)** — audit's core claim is correct for `ptX1` |
| Transitivity `u<w<t ⟹ x1<t` FAILS in general | `ptX1` at chain index `lXU.length ≥ 1` when `lXU` non-empty (`:6613-6614`); non-empty `lXU` = the `hbelow`-relevant case. Only degenerate empty-`lXU` gives `x1=u<w` | **SUPPORTED (High)** — it IS a trap |
| Pin slots carry `charK (nfk_projFresh σ)` as outer witnesses | `kvE_pinDisjunct` `:5379` = `[⟨charK a.witnessType⟩]`; `a.witnessType = nfk_projFresh σ` (`:5366`). Tried: are pins in a DIFFERENT bracket? No — `slotsFor lL` `:8236`, same bracket `:8244` | **SUPPORTED (High)** |
| Pins are pinned in `(x, w_outer) ⊂ (x, t)` (bounded, structural) | Pins ∈ LEFT list, left of `ptW` `:8244`; monotonicity ⇒ `< w_outer`; `w_outer < t` (`k1v_bracket_extract:2155`). Tried: could a pin land ≥ w_outer? No — left witnesses are `< w` by `holds` | **SUPPORTED (High)** |
| Bound is structural, not an `x1<e_i` literal (litmus PASS) | `q < w_outer` from the pin's SLOT POSITION (bracket monotonicity), not any formula literal. No `e`-rebinding, no `w=e_i` | **SUPPORTED (High)** |
| `neg_2var_vec_ea` / `neg_interval_formula` do NOT bound a given chain point (refutes audit route 1) | Read `:720-729`, `:401-407`: shape `¬holds → ∃v', v'.holds`; bound flows from `first_occ_tp` `:439` whose precondition `∃x∈(z0,z1), type@x` is unprovable for charK from the flat extract | **SUPPORTED (High)** — audit's proposed asset is inapplicable; pin route replaces it |
| `hbelow` assembly (all `zXU` types below the pin) is provable | Phase-3 F_0 points + `List.permutations` coverage + σ-block contiguity `:8236`. Tried to refute: could some `zXU` type lack a below-witness < q? Each χ∈S_XU heads some perm ⇒ F_0=charBase χ at u_χ<q. But the perm-coverage + monotone-ordering lemmas are UNBUILT | **PARTIALLY SUPPORTED (Medium)** — the sole residual risk; drives the CAVEAT |
| F4 Z-counterexample (M=Z, p={0}, r={13}, x=10, t=20) still correctly REJECTED | If M=Z has no honest realization, the carrier's `.holds` (unchanged, do-not-edit) is FALSE ⇒ soundness vacuous ⇒ no spurious `x1`. The new lemma only fires WHEN `.holds` holds; rejection lives in `.holds`, not the recovery | **SUPPORTED (High)** — recovery does not weaken counterexample rejection |
| Pin route is compatible with all binding constraints (F3, do-not-edit) | Pins already in `kvE2_body.slotsFor` (unchanged); consuming their extract does NOT edit the splice `kvE_subChain2V`/`bracketFromLists3`. New lemma is additive | **SUPPORTED (High)** |
| Completeness unaffected by the additive soundness lemma | New lemma is soundness-only; completeness closes via `kvE_subBracket2V_complete` `:7717`. Audit's "all-arrangements realizability" MEDIUM risk (`kvE_subChain2V` splices all perms) is INHERITED from task 321, not created here | **PARTIALLY SUPPORTED (Medium)** — inherited risk, flagged not retired |

### Contradiction Log

**Direct contradiction with the task-321 audit (report 03), RESOLVED by machine evidence.**
Report 03 Determination 1 asserts `x1` is "unbounded above and cannot be certified `x1 < t`",
verdict ESCALATE / effectively NOT-PROVABLE-without-restructure. **Resolution via precedence
(machine source > prior analysis):** the audit's claim is TRUE for the fChainPred's internal `ptX1`
(I re-verified it) but the audit **did not consider the pin slots** (`kvE_pinDisjunct` :5374),
which supply a *different*, already-bounded `charK` witness. The audit's H3 table (report 03) maps
only `k1v_bracket_extract`, `sound_of_parts`, and the reverse-Cor-5.4 assets — the pin channel is
absent. The contradiction is resolved: the anchor+bound (`hanchor`, `hx1t`) ARE recoverable
(refuting ESCALATE), while the audit's underlying unboundedness lemma about `ptX1` stands. No
UNRESOLVED contradiction remains; the residual uncertainty is confined to Phase-4 `hbelow`.

### Recommendations modified after verification

- **Initial instinct** (consume the audit verbatim → NOT-PROVABLE / re-escalate). **Retracted**
  after finding the pin slots supply a bounded `charK` anchor. Revised to PROVABLE-WITH-CAVEAT.
- **Audit's route 1** (`neg_2var_vec_ea`/`neg_interval_formula` point-insertion). **Dropped** — these
  are negation-closure lemmas, not chain-point bounders; `first_occ_tp`'s occurrence precondition is
  the very fact the flat extract lacks. The pin route needs NO `HasAttainedINF` gating at all
  (simpler and model-independent for the anchor+bound).
- **Scope correction for the planner**: the new lemma must be STATED against the pin-slot extract
  (and an order-preserving outer extraction), NOT the `fChainPred @ u`-only data the current
  Phase-10 wiring passes. Task 321's v5 `/revise` must extract σ's pin witnesses (already present in
  `.holds`) and thread them in.

### Confidence summary

- Transitivity route is a trap: **High.** Pin slots supply bounded `hanchor`+`hx1t`: **High.**
  Litmus/F4-rejection/constraint-compliance: **High.** `hbelow` fully assembles (Phase 4): **Medium**
  — this is the make-or-break residual and the reason the verdict is PROVABLE-**WITH-CAVEAT** rather
  than flat PROVABLE. If Phase 4 fails, fallback is a bounded sub-`.holds` (reverse-Cor-5.4 wall)
  ⇒ NOT-PROVABLE-AS-SPEC.

---

## Literature Grounding (`--lit`) — Rabinovich 2014 §5 cross-check

- **Lemma 5.1 point-insertion (md:169-171)** `A_i⁻(z0,z) ∧ A_i⁺(z,z1)`: the shared split point `z`
  carries an interior witness's bound structurally. **My pin-slot route is a faithful *instance* of
  this principle** — the pin witness's bound `q < w_outer` is carried by its STRUCTURAL POSITION
  (a bracket witness slot left of the `ptW`=`w_outer` split), exactly the "boundedness via a
  shared/structural endpoint, never a formula assertion" that report 03 (§Literature) and 320 report
  `01`:63-66 identify as the correct mechanism. The pins realize this WITHOUT restructuring the
  splice, because `bracketFromLists` monotonicity already gives the shared-endpoint bound.
- **Cor 5.4 (md:154-157)** biconditional (model-dependent): the reverse `fChainPred → .holds`
  direction remains unprovable (`EANegation.lean:1249` `sorry`) — the pin route **sidesteps it
  entirely** by not recovering the anchor from the chain.
- **Lemma 5.3 (md:137-152)** per-disjunct arrangement: underwrites `kvE_subChain2V`'s
  `S_XU.permutations` structure, which the Phase-4 coverage argument relies on.

The shared-endpoint split genuinely yields the upper bound (md:169-171); the pin slot is that split
point already materialized in the outer carrier.

---

## Memory Candidates

1. **Pin slots are a bounded `charK`-anchor source the F4 audit overlooked.** In `kvE2_body`, the
   per-sub pin slots (`kvE_pinDisjunct` → `⟨charK (nfk_projFresh σ)⟩`, `NfMultiAnchorBridge.lean:5374`)
   are LEFT outer-bracket witnesses (`slotsFor lL`, `:8236`), hence pinned in `(x, w_outer) ⊂ (x, t)`
   by monotonicity. This supplies the bounded sub-anchor (`hanchor`+`hx1t`) that the flat
   `fChainPred`'s internal `ptX1` (unbounded, `fChainFrom_base:585`) cannot — refuting the
   "reverse-Cor-5.4 required" escalation for the anchor. Bound is structural (slot position), not an
   `x1<e_i` literal (litmus PASS).
2. **fChainPred F_0 = the arrangement's first point type, recoverable as a below-witness.** Realizing
   a spliced `(bracketFromLists3 …).fChainPred @ u` yields `(pointTypes 0)@u = ⟨charBase χ⟩@u` via
   `fChainFrom_step` (`EANegation.lean:616`). Over `S_XU.permutations` (`kvE_subChain2V:6787`), every
   `zXU` type is some arrangement's F_0, so the flat chain slots collectively provide a below-witness
   for every `zXU` type — the audit read this all-arrangements splice as a completeness RISK, but for
   soundness `hbelow` it is an ASSET.
3. **`k1v_bracket_extract` forgets ordering; the monotone `ws` lives in `IntervalPattern.holds`.**
   When a proof needs the relative order of two bracket witnesses (e.g. pin above the fChainPred
   below-witnesses), `k1v_bracket_extract` (`:2150`, per-element `∃u`) is insufficient; extract the
   monotone sequence directly as `bracket_implies_fChainPred` (`EANegation.lean:670`) does.
