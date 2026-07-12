# Task 352 — Teammate C (Critic) Findings

**Role**: Adversarial pressure-test of the whole premise. Read-only; no `.lean` edits.
**Mode**: lean-research-hard critic (H4 adversarial). Default posture: skepticism.
**Grounding**: `RefutationF2.lean` (whole file read), `ExteriorBracketK.lean` (whole file read),
`ExteriorBracket.lean:432-470` (frozen bracket lemma), `PriorInterface.lean:38-46`
(`ExistProviders`), `OuterGate.lean:120-176`, v7-phase2-blocked handoff, reports 10 & 11,
Rabinovich 2014 §5/§7 (Prop 4.2, Cor 5.4, Def 7.5, Lemmas 7.6/7.8/7.10, Def 7.7).

---

## Key Findings

1. **The F2 obstruction is CORRECT and machine-checked.** I reproduced it against the real
   definitions. It is not a heuristic worry; `f2_relativized_refutation` is a sorry-free,
   UZ/SZ-satisfying counterexample. The frozen carrier's read channel is provably coarser than
   semantic equality at depth ≥ 1.

2. **Resolution (a) CAN escape F2 — but only under a condition the spawn framing does not state
   sharply.** The escape requires the depth-`k` clause layer to pin each exterior sub's **full
   joint quant-layer content** via `existF`-converters folded over the sub's own fiber. If 352
   instead builds the clause on the landed determinacy core's **marginal** bits
   (`kvE_futAnyBit` / `kvE_subBit`, both keyed on `χ : NormalForm sig k 1`), the **identical F2
   counterexample reappears one rung up** and 352 re-blocks. This is the single most important
   thing the plan must get right, and it is currently implicit.

3. **The landed determinacy core is scaffolding, not a load-bearing content channel for the
   brackets.** Every core read (`kvE_futAnyBit`, `kvE_projFreshD`, `kvE_subBit`) is a *marginal*
   (zone × depth-`k` 1-type) read that routes through `nfk_projFresh` — the exact G1-forbidden
   F2 discriminator — and is defended only as a "coordinate label." It is correct *as a marginal*
   but marginals are insufficient to drive bracket sound+complete at `k ≥ 1`. The hard part (the
   joint-content clause via `existF`) is entirely unbuilt.

4. **The `~2000-line` estimate is justified, arguably conservative.** The frozen k=2 clause layer
   is `ExteriorNegation.lean` (1735) + `ExteriorNegationPast.lean` (1109) = **2844 lines**. The
   depth-`k` version adds inductive scaffolding, `existF` threading, UZ/SZ relativization, and
   k=0 recovery lemmas on top of that shape. `~2000+` is not inflated.

5. **"Byte-identical statement shape" is NOT actually required by 349 Phase 2 — and cannot hold.**
   The frozen `kvE2_extBracketFut_sound` (ExteriorBracket.lean:432) has no `P` parameter and its
   `hbelow` hypothesis is a *marginal* `kvE2_futAnyBit` pin. Resolution (a) must add `P` AND
   replace the marginal `hbelow` with a full-joint-content pin. So the statement shape *must*
   change. The byte-identical constraint that genuinely binds is the **7 frozen providers +
   KampPrior.lean + Lemma32Reduction.lean** (files), not the bracket lemma statements (new).

---

## Is the F2 obstruction argument correct?

**Yes. Verified against the real definitions, not the handoff's word.**

The mechanism (RefutationF2.lean, whole file):
- `f2sub1 ≠ f2sub2` (`f2_sub_ne`:413) are two distinct depth-1 arity-4 subs.
- They **share every read channel the carrier uses**: same atom/ordering layer
  (`f2_sub_atom_eq`:371) and, decisively, **equal fresh projection**
  (`f2_sub_proj_eq`:471, `nfk_projFresh f2sub1 = nfk_projFresh f2sub2`). They differ only in a
  deeper **joint** coordinate (the depth-0 5-type "P z ∧ x<z<fresh" realized below u₁ but not u₂).
- `f2qnf' := (f2qnf.1, fun σ => if σ = f2sub2 then false else f2qnf.2 σ)` un-marks `sub2`.
- `f2_carrier_eq`:582 machine-proves the carrier gives `f2qnf` and `f2qnf'` the **same value**
  (via `bracketEndChar_kv_factors`: the off-fiber clause is unaffected, and the fiber-existential
  read keeps `sub1` alive on `sub2`'s shared fiber). Yet `f2qnf` is realized and `f2qnf'` is not
  (in this chain) — the target `↔` therefore fails the **soundness** (LHS→RHS) direction.

The diagnosis at RefutationF2.lean:51-67 is the crux and it is exactly right: at `k+1 ≥ 2` a
fiber `(zs, χ)` over `qnf.1` contains **≥ 2 subs differing in deeper joint layers** (D7,
`NfEFold:373` — no pointwise assemble at depth ≥ 1), and the per-sub biconditional of
`nf_eval_nf` distinguishes markings the carrier cannot see. The `k=1` rung is saved *only* by the
depth-0 split-kit **bijection** (`nf0_split_assemble`, singleton fibers) — i.e. at depth 0
marginal = joint. **This is a property of `nf0_assemble` losslessness at depth 0, and nothing
else.** Every deeper rung loses it.

**Independent confirmation from Rabinovich 2014**: the diagnosis "project subs to plain
base-signature 1-types (`nfk_projFresh`), discarding joint structure" maps precisely onto
Rabinovich's requirement (Def 7.7, Cor 5.4, PDF p.7) that the bracket's `α_j`/`β_j` be formulas
over the **canonical TL-expansion** `E[Σ, TL]` — i.e. the *enriched* vocabulary that includes the
previous round's TL-definable content, **not** base-signature types. The F2 refutation and the
paper agree on the disease. Confidence: **High.**

---

## Does resolution (a) actually escape it? (refutation attempt)

**Structural property the clause layer MUST have** (stated precisely): for each exterior sub
`σ : NormalForm sig (k+1) 4`, the emitted exclusion clause must be truth-equivalent to a
predicate that **separates any two subs with distinct full quant layers** `σ.2` — i.e. the clause
content must be a function of the *entire* fiber `{ s : NormalForm sig k 5 | σ.2 s = true }`, each
element pinned losslessly, not of any marginal projection `(zone, nfk_projFresh)`.

**Why `P : ExistProviders sig atomMap k` supplies exactly this (the case FOR (a)):**
`existF : (n) → NormalForm sig k (n+1) → Formula` with
`correct : temporal_truth M t (existF n sub) ↔ ∃ env, nf_eval_nf M k (n+1) (insertEnv env t) sub`
(PriorInterface.lean:40-46) is a **lossless full-arity depth-`k` converter**. `OuterGate.lean:129`
confirms the `n=0` instance: `temporal_truth u (P.existF 0 χ) ↔ nf_eval_nf M 1 1 (fun _=>u) χ`.
Rabinovich Prop 4.2 / Lemma 7.8 (negation closure) and Lemma 7.6 (bracket composition) both stay
*within* the canonical-expansion vocabulary, and `NormalForm sig k n` is a `Fintype`, so the
complement clause is a **finite Boolean combination of `existF` over the characteristic set** —
`existF` (converter-level) is closed enough; no richer bundle field is needed. So in principle
the depth-`(k+1)` clause built as an `existF`-fold over `σ`'s full fiber is F2-immune, and `P`
at depth `k` is the correct and sufficient channel. This matches Rabinovich's actual recursion:
**Def 7.5's rung-`(k+1)` bracket consumes rung-`k` FORMULAS (canonical-expansion predicates =
`existF`), not rung-`k` brackets.** I checked Def 7.5 / 7.6 / 7.8 / 7.10 directly — the α/β are
formulas, and 7.14's induction is "by Lemmas 7.6, 7.8(2), 7.10 and a straightforward structural
induction." **This is the one genuine reason (a) is not circular.**

**Refutation attempt 1 — does the joint-coupling counterexample reappear one level up? YES, if
the core's marginal bits are used as clause content.** `kvE_futAnyBit` (ExteriorBracketK.lean:218)
and `kvE_subBit` (:302) both key on `χ : NormalForm sig k 1` — an **arity-1 marginal**. Two subs
sharing `(zs4, χ)` but differing in a 2-variable joint layer collapse under these bits at `k ≥ 1`
— literally the F2 pattern. `kvE_futAnyBit_correct` and `kvE_subBit_iff` are *proven*, but they
are correct statements about an **insufficient quantity**: each is a biconditional *relative to the
marginal `χ`*, honest about the shadow, silent about joint content. **If 352 wires the bracket's
exclusion clause to these bits (the natural, tempting move because they are the landed, green
assets), it re-blocks with F2.** The determinacy core can serve only as the *zone-navigation
label*; the content pin must go through the full-fiber `existF` fold (`nf_eval_nfk_iff_efold`,
NfEFold:627, which the core consumes only for `kvE_subBit` and only marginally). **Verdict: (a)
escapes F2 only under a discipline the spawn does not state; the refutation succeeds against the
naive reading and fails against the disciplined one.**

**Refutation attempt 2 — is `P : ExistProviders` at depth `k` sufficient, or does 352 need the
recursive BRACKET (⇒ resolution (b))?** I pressed this hardest because it is where (a) would truly
die. Answer: **converters suffice**, on both the Lean side (finite Boolean closure of `existF`
realizes the negation clause; Fintype instances exist at symbolic `k` — the core already uses
`Finset.univ.toList (NormalForm sig k 5)`) and the paper side (7.8/7.10 are stated over the
canonical expansion, whose predicates are exactly `existF` images; the recursion in 7.14 threads
formulas, not brackets). So resolution (a)'s bundle choice is correct and NOT secretly (b).
Confidence **Medium-High** — this is the claim most worth an independent second read (see Open
Questions Q1).

**Net:** resolution (a) is **structurally sound**, the user's adjudication is defensible, and the
work is genuinely constructive (not blocked by a proved obstruction). The risk is entirely in
*execution discipline*, not in a hidden wall.

---

## Unvalidated assumptions & blind spots

**In report 10 (the GO probe):**
- Report 10's GO is **honestly scoped** — I tried to catch it over-claiming and could not. It
  bounds GO to the *interior determinacy wall* (co-satisfaction ⇒ equality at full arity 4,
  `nf_eval_unique M k`), which is real, and it explicitly defers the exterior-bracket
  joint-pinning to "the exterior bracket's own recursive fold" (§2 rebuttal) — the very thing now
  blocked. **Blind spot, not error:** report 10's C4/C5/C6 argue "carrier 3 reads at full arity 4,
  never `nfk_projFresh`" — but that is about the **interior gate**. The **exterior bracket** *does*
  marginalize (the landed core uses `nfk_projFresh` at ExteriorBracketK.lean:200/307). A casual
  reader of report 10 could conclude "F2 is fully defeated" when only the interior half is.
  Report 11 and the plan inherit this optimism.
- Report 10 §2's load-bearing phrase is "**provided determinacy holds at each layer**." Determinacy
  does hold. But determinacy ⇏ the *clause construction* threads the joint content; it only makes
  it *possible*. The gap between "possible" and "built" is the entire 352 task.

**In report 11 (spawn analysis):**
- Report 11 asserts the depth-`k` clause layer "removes the depth-hardwiring (root cause 1) and
  supplies the rung-`k` recursive formula input (root cause 3)" — **true but it does not name the
  marginal-vs-joint discipline** (Key Finding 2) that separates a clause layer that works from one
  that re-blocks. A 352 implementer following report 11 literally could build over the marginal
  core bits and fail.
- Report 11 treats "byte-identical statement shape" as a real constraint on the bracket lemmas
  (lines 5-9, 40-46). It is not — resolution (a) *necessarily* changes the statement (adds `P`,
  replaces the marginal `hbelow`). Only the frozen *files* must stay byte-identical.

**Cross-cutting:**
- **The landed core uses `nfk_projFresh`, the G1-forbidden channel** (`kvE_projFreshD`:200,
  `kvE_subBit`:307). The plan's own G1 says "no `nfk_projFresh` on any sub … the F2
  discriminator" (plan:342, 667). The core is defended as "coordinate label only" (docstring:196).
  This distinction is **real but fragile** — it means the green core sits one careless edit away
  from a G1 violation, and it means the core does *not* discharge the F2-sensitive part of the
  work. Anyone auditing 352 for G1 compliance must understand the "label vs content" split or will
  either wrongly flag the core or wrongly bless a marginal clause.

---

## Confidence

| Claim | Verification | Confidence |
|-------|--------------|:----------:|
| F2 obstruction is correct (soundness direction fails at k=2) | Direct read of `f2_carrier_eq`/`f2_sub_proj_eq`/`f2_relativized_refutation`; matches Rabinovich Cor 5.4 | **High** |
| Landed core reads are marginal (`χ : NormalForm sig k 1`), route through `nfk_projFresh` | Direct read ExteriorBracketK.lean:200,218,302-307 | **High** |
| Marginal bits as clause content ⇒ F2 recurs at rung k+1 | Structural (F2 mechanism + marginal read) | **High** |
| `existF` (converter-level) is sufficient; (a) is not secretly (b) | Rabinovich 7.6/7.8/7.10/7.14 thread formulas; finite Fintype Boolean closure | **Medium-High** |
| `~2000+`-line estimate justified | Frozen clause layer = 2844 lines measured | **High** |
| "Byte-identical statement shape" not required for bracket lemmas | Frozen `kvE2_extBracketFut_sound` has no `P`; marginal `hbelow` must change | **High** |
| k=0 rung works because `nf0_assemble` lossless at depth 0 only (marginal=joint) | RefutationF2.lean:57-59 + blocker root cause 1 | **High** |

**Overall**: resolution (a) is sound and the premise of task 352 is valid. My skepticism did not
find a hidden wall — it found an **execution trap** (marginal-vs-joint) and a **mis-stated
constraint** (byte-identical). Both are correctable in the plan.

---

## Questions nobody is asking (and where 352 could ALSO block)

**Q1 (top open question — verify before large build).** *Does Rabinovich Def 7.5's rung-`(k+1)`
bracket, when negated (Lemma 7.8) and closed (Lemma 7.10), consume ONLY canonical-expansion
predicates (⇒ `P.existF` suffices, resolution (a)), or does any step consume the rung-`k`
bracket's own `_sound`/`_complete` (⇒ `P : ExistProviders` is insufficient and 352 needs a richer
bundle carrying recursive bracket correctness, i.e. resolution (b))?* My read says converters
suffice, but this is the load-bearing assumption of the entire task and deserves one dedicated
adversarial re-read of Lemma 7.8's proof (RefutationF2 §5 markdown lines 283-335, the Case 1-3 +
induction structure) before ~2000 lines are committed. **If wrong, 352 re-blocks at the same
place, one abstraction higher.**

**Q2.** *Which channel does the plan wire the bracket's exclusion clause to?* The plan MUST
mandate: content pin = `existF`-fold over the full fiber; determinacy core = zone label ONLY.
Absent this, an implementer reaches for the green `kvE_subBit`/`kvE_futAnyBit` and re-blocks.
This should be a G-guard (call it G6: "no marginal bit in any clause-content position").

**Q3.** *Can `ExistProviders.correct`'s UZ/SZ conditionality discharge every bracket obligation?*
The converter correctness is gated on `semantic_prior_UZ`/`semantic_prior_SZ`. If any step of the
navigated sound/complete argument needs an **unconditional** converter equivalence (or a converter
at a point where UZ/SZ is not yet established), `ExistProviders` cannot supply it. Rabinovich's
Lemma 7.8 needs **Dedekind completeness** — verify the UZ/SZ predicates are the faithful Lean
proxy at *every* use, not just at the top level.

**Q4.** *Depth parameter mismatch.* The bracket's subs are depth `(k+1)` (`NormalForm sig (k+1)
4`); their fiber elements are depth `k` (`NormalForm sig k 5`). `P : ExistProviders … k` converts
the depth-`k` fiber elements — correct. But the **outer** qnf is depth `(k+2)` and endIntervalStep
recurses on `k`. Confirm the plan takes `P` at depth `k` (fiber level), not `k+1`, and that the
KampPrior `Nat.rec` actually supplies a depth-`k` bundle at the rung where 349 re-dispatches. A
one-off in the depth index silently makes `correct` untypecheckable.

**Q5.** *Is resolution (c) genuinely dead, or cheaper?* (c) — weaken the bracket statement with an
explicit joint-content hypothesis discharged in Phase 4 — is in the *same difficulty class* only
if the hypothesis is dischargeable. F2 shows "marginal ⇒ full exclusion" is FALSE in general, so
(c)'s hypothesis is discharge-able only in the restricted realized-bracket-zone setting, i.e. it
**relocates** the joint-content obligation to Phase 4 rather than removing it. The user chose (a),
which is the honest choice; but if 352 stalls, note that (c) does **not** avoid the joint-content
work — it just moves it, and could re-block Phase 4. Nobody has checked whether Phase 4 has the
structure to discharge it.

**Q6.** *k=0 recovery for the full bracket FORMULA, not just the bit.* The core proves
`kvE_futAnyBit_zero`/`kvE_projFreshD_zero` (bit-level agreement with frozen k=2). But 352 must
also show the depth-`k` bracket FORMULA degrades to the frozen `kvE2_extBracketFut` at `k=0`
(defeq or an agreement lemma), or the k=2 consumer in 349 won't accept it. This is an extra
obligation the spawn does not budget.

---

### Bottom line for the plan
Resolution (a) is sound; task 352's premise survives adversarial scrutiny. The two things that
will actually sink it are **discipline failures, not walls**: (i) building the clause over the
marginal determinacy-core bits (add a G6 guard forbidding it), and (ii) an unverified assumption
that `existF`-converters suffice for Lemma 7.8's negation closure (verify Q1 before the big
build). Budget `~2500` lines, not `~2000`.
