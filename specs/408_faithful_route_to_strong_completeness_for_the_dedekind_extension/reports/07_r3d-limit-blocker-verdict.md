# Blocker Verdict — R3d limit transport refuted: invariant repair vs the Doets route

- **Task**: 408 — faithful_route_to_strong_completeness_for_the_dedekind_extension
- **Phase**: 7.9 (R3d-5) blocker escalation, route-level
- **Type**: lean4, hard mode, blocker research (read-only; no Lean source edited)
- **Date**: 2026-07-28
- **Session**: sess_1785243543_9dde88
- **Reference-grounding tier**: **Tier 1 (literature-backed)** — Reynolds 1992, Burgess 1984
  §2.7, Burgess 1982 I, Doets 1987 ch.3, all read verbatim from the local corpus.
- **Artifact numbering note**: this report takes `07` rather than the first-free `06` so that it
  pairs with the plan revision it recommends (`plans/07_…-v7.md`), per the shared-round
  convention in `.claude/rules/artifact-formats.md`.

---

## 0. Verdict (one paragraph)

**(b) — the Doets route, and it preserves the pinned terminus.** Completion-by-limits for
`U`/`S` has no source in the corpus, is now refuted at the data level by a landed theorem, and
has **no known repair**: all three Dedekind axioms have been individually checked against the
two-sided accumulation and none supplies the missing content. The literature's actual route —
Burgess–Xu rational model, then Doets' theorem — never completes the rational order and
therefore never incurs the obligation. Critically, the "Doets route delivers weak completeness
only, so it reopens the terminus" worry recorded in the Phase 7.9 handoff is **unfounded**:
Reynolds' own definition of weak completeness is *"every finite consistent set of formulas, or
equivalently every single consistent formula, is satisfiable"*, and the pinned
`consequence_completeness_dedekind_of_engine` takes a **per-formula** engine, so both
`completeness_dedekind` and `consequence_completeness_dedekind` fall out of the already-landed
Phase 2 deduction chain with **no change to the pinned signature**. However — and this is the
part the verdict must not soften — the Doets route is **not cheap and not already done**. The
plan's stated reason for killing it (expressive completeness of `{U,S}` "is absent from this
tree and from Mathlib") is **factually false about the tree**, but the landed expressive-
completeness theorem is pinned at a hypothesis that is *vacuous on dense flows*, so it must be
re-based before it can be used. That re-base is already scoped, named and deferred in the tree's
own docstrings.

---

## 1. Findings

### 1.1 Source-to-implementation mapping (H3 Tier 1, 5-column)

| Source | Prop / Location (printed page) | Lean identifier | Type signature / statement | Status |
|---|---|---|---|---|
| Reynolds 1992 | §2, **p.168** — `Sep: K⁺p ∧ ¬K⁺(p ∧ U(p,¬p)) → K⁺(K⁺p ∧ K⁻p)` | `Axiom.sep` | `Axioms.lean:390,398` — docstring states the axiom **character-for-character** as printed | LANDED, sound; **consumed nowhere on the completeness route** — becomes load-bearing for the first time under (b), as Reynolds Theorem 5 |
| Reynolds 1992 | §2, **p.168** — `Prior-U: U(⊤,p) ∧ F¬p → U(¬p ∨ K⁺(¬p), p)`; `Prior-S` dual | `Axiom.prior_U_gap`, `Axiom.prior_S_gap` | `Axioms.lean:377,387` | LANDED, sound; consumed by 6.2/6.3/7.3/7.4 |
| Reynolds 1992 | §4, **Corollary 1** — rational-flowed `M` with `M ⊨ A(0)` and all instances of Prior-U/Prior-S/Sep valid | `Chronicle.cantorBfmcsDense` + `cantor_bfmcs_dense_restricted_tc/_buc/_fuc` | `ChronicleToCountermodelBasic.lean:552,629,680,755` | LANDED sorry-free. **This is step 1 of the Doets route, already in the tree** |
| Reynolds 1992 | §5, **Theorem 3, p.176** — `{U,S}` expressively complete over Prior structures | `uSExpressivelyCompleteOverPrior` | `PriorExpressiveness.lean:359`; verified `#print axioms = [propext, Classical.choice, Quot.sound]` | LANDED sorry-free — **but pinned at `SemanticPriorUZ/SZ`, which is FALSE on dense flows** (§1.4). Needs re-base |
| Rabinovich 2014 | Lemma 5.3 / eq (5.2), PDF p.8 | `Kamp.kampPriorExpressiveCompleteness`; faithful carrier `HasDedekindINF` | `KampPrior.lean:672`; `DedekindINF.lean:125` | Chain LANDED sorry-free at the **attained** carrier; the re-base onto `HasDedekindINF` is **explicitly DEFERRED** with three named targets (`DedekindINF.lean:75-103`) |
| Reynolds 1992 | §6, **Theorem 4, ≈p.178** — "the ∼-classes do not end at gaps" on a Prior structure | *(discrete instance only)* `no_gaps_discrete_model_surgery`, `gap_contradicts_prior` | `IntegerModel/GoodStructuresModelSurgery.lean` | Discrete instance LANDED sorry-free. **Dense/real instance NOT built** |
| Reynolds 1992 | §7, **Theorem 5, pp.184-185** — Sep ⇒ dense set of singleton classes | — | — | **NOT built.** Requires `Axiom.sep` + expressive completeness |
| Reynolds 1992 | §8, **Theorem 6 (Doets), pp.185-188**; Lemmas 11-13 | *(partial)* `good`, `VeryGood`, `ContempEquiv`, `KEquiv`, `truth_transfer`, `doets_lemma_1_4` | `IntegerModel/GoodStructures.lean`; `NEquivalence.lean:81`; `OrderedSum.lean:41` | Machinery LANDED sorry-free **at ℤ-intervals**. ℝ-interval analogue, shuffles, and the dense ordered-sum variant (`doets_lemma_1_5`, sorried, archived) **NOT built** |
| Doets 1987 | **3.3.9** — *"If M is definably-I, definably complete and densely ordered without endpoints, then it has n-equivalents of order type λ for each n."* | — | — | The theorem Reynolds' §8 restates; not separately formalized |
| Reynolds 1992 | §9, **Theorem 7, p.189** — US/R sound and **weakly** complete over real flow | `consequence_completeness_dedekind_of_engine` (the `engine` binder) | `StrongCompleteness.lean:274-279` | Terminus LANDED, pinned; engine binder is **exactly** Theorem 7's shape |
| Burgess 1984 | §2.7, **pp.109-110** — the completion-at-a-gap lemma | *(the R3d arc)* `BFMCS.LimitGuardEventual`, `NoGuardAccumulation` | `Bundle/RealExtensionBundle.lean:369`; `ChronicleGuardAccumulation.lean` | Adapted-from only. **Burgess's completion is `¬,∧,G,H`-only (p.116); it carries no guard** |

### 1.2 Literature proof structure — Reynolds' actual route to a real-flowed model

Verified verbatim from `/home/benjamin/Projects/Literature/sources/reynolds_1992/`:

1. **§4, Theorem 1 + Corollary 1** — Burgess–Xu gives a rational-flowed `M` with, verbatim:
   *"1. the flow of time of M is the rationals, 2. for all A ∈ Γ, M ⊨ A(0) and 3. all
   substitution instances of the axioms Prior-U, Prior-S and Sep are valid in M."*
2. **§3, the framing sentence that settles this blocker** — *"Both [8] and us then arrive at a
   model of the formula, which has a rational flow of time but which is **definably Dedekind
   complete** and in which all substitution instances of the respective Sep axioms are valid.
   Both proofs then finish off by applying a result of Kees Doets in [4] for finding a
   real-flowed model of the formula."* (printed p.171 for the second sentence.)
3. **§6, Theorem 4** — *"Suppose that ∼ is a contemporaneous equivalence relation on a Prior
   structure M. Then the ∼-classes do not end at gaps."* Obtained via Lemma 2, whose proof line
   is *"Now by the expressive completeness of U and S there is temporal R true in any Prior
   structure exactly where ρ(x) is."*
4. **§7, Theorem 5** — Sep ⇒ `M/∼` has a dense set of singletons; its critical line is *"Let the
   temporal formula C be true exactly at points who are the left hand end points of their
   classes. **We use expressive completeness here.**"*
5. **§8, Theorem 6 (Doets)** — D1 + D2 ⇒ for all `k`, a real-flowed structure `≡ₖ M`. Proof by
   lexicographic sums (Lemma 11), the definable contemporaneity relation (Lemma 12), closed
   classes (Lemma 13), and a shuffle over ℝ. Reynolds proves the shuffle's flow *"is Dedekind
   complete … because any subset bounded above intersects a last summand"*, then adds a countable
   dense subflow to conclude it *"must be isomorphic to the reals."*
6. **§9, Theorem 7** — set `k` one greater than the quantifier depth of `A₀`'s table; transfer.

**The decisive structural fact**: at no point does Reynolds insert points at gaps of the
rational model. The real structure is a *different* structure, only `≡ₖ`-equivalent, and `k`
depends on the single formula. Hence no analogue of `BFMCS.LimitGuardEventual` ever arises. The
"definable Dedekind completeness" the rational model needs is a **theorem about Prior
structures** (Theorem 4), derived from the axioms via expressive completeness — not a property
that must be engineered into the chronicle construction.

### 1.3 Why (a) — invariant repair at 7.5 — has no known repair

The repaired invariant would have to carry, on top of `NoGuardAccumulation`'s order-theoretic
content, **axiom-level content about the MCS values at freshly inserted points** of the
following exact shape: *for each guard `ψ` in the closure, the set of `¬ψ`-points inserted by
`c5_forward_walk` / `c5_backward_walk` / the inline C4 branches admits no ascending sequence
bounded above in `dom` along which `untl φ ψ` (or `snce φ ψ`) also holds cofinally*. Three
independent checks say this content is not available:

1. **`prior_U_gap` is satisfied by the counterexample pattern, not violated by it.** At `t`
   below the gap the antecedent `U(⊤,ψ) ∧ F¬ψ` holds and the conclusion
   `U(¬ψ ∨ K⁺(¬ψ), ψ)` is discharged by the *next* guard-failure point, which the accumulating
   pattern supplies at every stage. This is the 7.9 finding; it is hand-checked, not formalized,
   and I confirm it is consistent with the axiom as printed (Reynolds p.168) and as landed
   (`Axioms.lean:377`).
2. **`prior_S_gap` is silent on the two-sided pattern — CONFIRMED against the literature.**
   Prior-S's antecedent is `S(⊤, p) ∧ P¬p`. If the guard fails cofinally *above* the gap as well
   as below it, `S(⊤,ψ)` never holds in any right-neighbourhood of the gap, so the axiom has no
   antecedent to fire on. The two-sided configuration therefore satisfies Prior-U and Prior-S at
   every rational, and by Reynolds p.176 (*"It is easy to see that then there are no definable
   gaps"*) it has **no definable gap** — the accumulation is invisible to the entire Prior
   apparatus. The 7.9 agent's hand-check is confirmed; it remains unformalized, and I did not
   formalize it either (it needs a ℚ-flow semantics module the tree lacks).
3. **`sep` cannot reach it either — this is new to this report.** Reynolds' own validity proof
   for Sep (Lemma 10, §7) derives its contradiction from *"an uncountable set of pairwise
   disjoint non-singleton intervals of ℝ. Impossible."* Sep's failure at a point forces
   guard-interval structure at **every** point of an interval, yielding uncountably many disjoint
   intervals. A single-gap accumulation produces **one** accumulation point and therefore
   countably many intervals — it escapes the cardinality argument cleanly. So the third and last
   Dedekind axiom is also silent.

With all three axioms exhausted, the missing content would have to come from the *construction*
(a redesigned witness-placement discipline in `CounterexampleElimination.lean`), and whether such
a discipline can exist is precisely the Ehrenfeucht-Fraïssé realizability question that Phase 7.5
recorded as out of scope and the Postmortem Constraints forbade the machinery for. **No repair is
known.** Under the user's no-needless-bridges constraint, an invariant whose only purpose is to
carry an unsourced construction property across a seam the literature never crosses is exactly
the evidence-of-wrong-route the constraint names.

### 1.4 Why (b) is reachable — and the one thing the plan got factually wrong

The Postmortem Constraints state: *"Do NOT build any part of the Reynolds transfer route. No
monadic-FO translation layer, no Stavi connectives U'/S', no expressive-completeness theorem, no
EF games, no shuffles, no ≡ₖ … Reynolds' Theorems 4 and 5 invoke expressive completeness of
{U,S} at seven verbatim sites, which reduces to Kamp/Stavi — a result Reynolds cites without
proof and **which is absent from this tree and from Mathlib**."*

That last clause is **false about this tree**, and it is the sole load-bearing premise for
killing R2 at Phase 7.2. Verified by `lean_verify` in this dispatch:

| Declaration | File | `#print axioms` |
|---|---|---|
| `uSExpressivelyCompleteOverPrior` | `WeakCanonical/PriorExpressiveness.lean` | `[propext, Classical.choice, Quot.sound]` |
| `doets_lemma_1_4` (ordered sums preserve `≡ₖ`) | `WeakCanonical/OrderedSum.lean` | `[propext, Classical.choice, Quot.sound]` |
| `countermodel_discrete_reynolds_v2` | `WeakCanonical/IntegerModel/ReynoldsBridge.lean` | `[propext, Classical.choice, Quot.sound]` |

The tree contains a **complete, sorry-free, Reynolds/Doets-shaped transfer pipeline** — at the
Discrete class. `completeness_discrete`'s own audit block records the chain
(`Completeness.lean:381`): `countermodel_discrete_reynolds_v2 → limitdom_is_good →
no_gaps_discrete_model_surgery → uSExpressivelyCompleteOverPrior → kampPriorExpressiveCompleteness
→ nfCharacterizableTemporalPrior → nf_nvar_exist_all_depths`. It includes Reynolds' `good` /
`VeryGood` / `ContempEquiv` vocabulary verbatim, `KEquiv`, `truth_transfer`, and Doets 1989
Lemma 1.4.

**It also answers the bimodality objection**, which I raised against my own verdict and which
turns out to be already solved in the tree: `mkSigFrom φ` builds a *finite* monadic signature
from `φ.predFormulas` — atoms **and box-subformulas** as unary predicates — and
`countermodel_discrete_reynolds_v2` packages the modal dimension as
`WorldState = FamIdx × ℤ` with `multiFamOmega` shift-closed
(`multiFamOmega_shiftClosed`, `ReynoldsBridge.lean:708`). So "Doets' theorem is about monadic FO
over a linear order, but TM is bimodal" is **not** an obstruction: the existing engine already
transfers a bimodal TM countermodel through a monadic-FO `≡ₖ` argument.

**The honest cost, stated without softening.** `SemanticPriorUZ` as landed
(`PriorDefs.lean:28`) says *every future occurrence of ψ has a first occurrence with ¬ψ strictly
between*. That is **false on any dense flow** (take ψ true throughout `(t,∞)`), so
`uSExpressivelyCompleteOverPrior` is **vacuous** over ℚ and ℝ and cannot be applied to the
Dedekind route as it stands. The tree already knows this and says so precisely
(`DedekindINF.lean:56-103`): the strengthening chain is
`Rabinovich's Dedekind completeness < HasDedekindINF < HasDefinableINF < HasAttainedINF`, with
"what is LANDED" at the strongest end, and the docstring warns *"An over-strong hypothesis
passes sorry-free, axiom-clean and EXIT 0 exactly as a vacuous conclusion does — the pattern
that recurred three times undetected in this development."* The re-base onto `HasDedekindINF` is
**deferred, not abandoned**, with three named targets (Lemma 5.3 / Lemma 5.1 / Prop 4.2). Note
that `HasDedekindINF`'s left disjunct is literally `K⁺(P)(z₀)` — the same `K⁺` shape as
Reynolds' Prior-U — and `prior_hasDedekindINF` (`DedekindINF.lean:232`) already closes that
boundary. The re-base is therefore aimed exactly where the Dedekind route needs it.

### 1.5 Does (b) reach BOTH `completeness_dedekind` and `consequence_completeness_dedekind`?

**Yes, and the pinned signature is untouched.** Three independent confirmations:

1. **Reynolds' own definition** (§2, the paragraph immediately preceding the compactness remark
   the 7.9 handoff attributes to printed p.169): *"It is **weakly** (or **finitely**) **complete**
   if and only if every finite consistent set of formulas, or equivalently every single
   consistent formula, is satisfiable."* The finite-context form is not a strengthening of weak
   completeness; it *is* weak completeness.
2. **The pinned engine binder is per-formula.** `consequence_completeness_dedekind_of_engine`
   (`StrongCompleteness.lean:274`) takes
   `engine : ∀ ψ : Formula, ValidDedekindDense ψ → Derivable FrameClass.Dedekind [] ψ`
   and produces `Derivable FrameClass.Dedekind Γ φ` via
   `(derivable_foldr_imp_iff Γ φ).mpr (engine _ ((semantic_deduction_dedekind_dense Γ φ).mp h))`.
   Reynolds' Theorem 7 produces a real-flowed countermodel **per formula**, with `k` chosen from
   that formula's table — which is precisely the engine's shape. Nothing about the Doets route
   requires a uniform model, and nothing about the engine asks for one.
3. **The semantic target is already the reals.** `SemanticConsequenceDedekindDense` quantifies
   over `D` with `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [DenselyOrdered D]
   [Nontrivial D]` plus the lub property. A Dedekind-complete, densely ordered, nontrivial
   ordered abelian group is order-isomorphic to ℝ (Hölder), so the countermodel obligation *is*
   Reynolds' real-flow obligation. `completeness_dedekind_of_engine` is already the `Γ := []`
   instance and is already landed.

**The terminus is therefore preserved verbatim under (b). Nothing in Phase 2 is reopened.**

---

## 2. Claim-verification table

| # | Load-bearing claim | Verbatim source (printed page) or Lean declaration | Verification method |
|---|---|---|---|
| C1 | The Dedekind axioms as landed are Reynolds' verbatim | Reynolds §2, p.168: `Sep: K⁺p ∧ ¬K⁺(p ∧ U(p,¬p)) → K⁺(K⁺p ∧ K⁻p)` vs `Axioms.lean:390` docstring — character-for-character | corpus read + file read |
| C2 | Weak completeness *includes* the finite-context form | Reynolds §2: *"It is weakly (or finitely) complete if and only if every finite consistent set of formulas, or equivalently every single consistent formula, is satisfiable."* | corpus read, verbatim |
| C3 | No strongly complete axiomatization exists for `{U,S}` over ℝ | Reynolds §2, p.169: *"in the case of U and S over the reals, there can be no strongly complete axiomatization … because the compactness property fails"* | corpus read, verbatim; matches the settled Reframing Note |
| C4 | The literature's route ends at Doets, never at a completion | Reynolds §3, p.171: *"Both proofs then finish off by applying a result of Kees Doets in [4] for finding a real-flowed model of the formula."* | corpus read, verbatim |
| C5 | The rational model is *definably* Dedekind complete, not completed | Reynolds §3: *"a model … which has a rational flow of time but which is definably Dedekind complete"* | corpus read, verbatim |
| C6 | Step 1 of the route is exactly what `cantorBfmcsDense` already delivers | Reynolds §4 Corollary 1 (three numbered clauses, quoted §1.2 above) vs `ChronicleToCountermodelBasic.lean:552,629,680,755` | corpus read + file read |
| C7 | D1 is a theorem about Prior structures, not a construction property | Reynolds §6 Theorem 4: *"Suppose that ∼ is a contemporaneous equivalence relation on a Prior structure M. Then the ∼-classes do not end at gaps."* | corpus read, verbatim |
| C8 | D1 and D2 are obtained *by expressive completeness* | Reynolds §6 Lemma 2: *"Now by the expressive completeness of U and S there is temporal R…"*; §7 Theorem 5: *"We use expressive completeness here."* | corpus read, verbatim |
| C9 | Doets' theorem is EF/`≡ₖ`-based and yields a shuffle whose flow is Dedekind complete | Reynolds §8: *"In fact R is Dedekind complete. This is true because any subset bounded above intersects a last summand."*; Doets 1987 **3.3.9**: *"If M is definably-I, definably complete and densely ordered without endpoints, then it has n-equivalents of order type λ for each n."* | corpus read, verbatim (both) |
| C10 | Burgess's completion-by-limits is `¬,∧,G,H`-only | Burgess 1984 §2.7, pp.109-110 (the `C(Y,Z)` lemma, quoted in the 7.9 handoff) + p.116: *"All the systems discussed so far have been based on the primitives ~, ∧, G, H."* | corpus read, verbatim (OCR renders `¬` as `~`, `∧` as `A`) |
| C11 | Expressive completeness of `{U,S}` over Prior structures IS in this tree, sorry-free | `uSExpressivelyCompleteOverPrior` → `[propext, Classical.choice, Quot.sound]` | `lean_verify`, this dispatch |
| C12 | Doets 1989 Lemma 1.4 (sums preserve `≡ₖ`) is in this tree, sorry-free | `doets_lemma_1_4` → `[propext, Classical.choice, Quot.sound]` | `lean_verify`, this dispatch |
| C13 | A full Reynolds-shaped bimodal transfer pipeline exists, sorry-free, at `.Discrete` | `countermodel_discrete_reynolds_v2` → `[propext, Classical.choice, Quot.sound]`; chain documented at `Completeness.lean:381` | `lean_verify` + file read |
| C14 | The bimodal dimension is handled by `mkSigFrom`/`predFormulas` + `multiFamOmega` | `ReynoldsBridge.lean:708,739ff`; `multiFamOmega_shiftClosed` | file read |
| C15 | The landed expressive-completeness theorem is **vacuous on dense flows** | `SemanticPriorUZ` (`PriorDefs.lean:28`) demands a first occurrence with `¬ψ` strictly between — unsatisfiable when `ψ` holds on an open right-neighbourhood | file read + direct semantic check |
| C16 | The needed re-base is already scoped and deferred in-tree | `DedekindINF.lean:75-103`, three named targets; strengthening chain at `:56-61`; `prior_hasDedekindINF` at `:232` | file read |
| C17 | The refutation at 7.9 is a landed theorem, not a hunch | `noGuardAccumulation_not_implied_by_limit_data` → `[propext, Classical.choice, Quot.sound]` | `lean_verify`, this dispatch |
| C18 | The pinned terminus consumes a per-formula engine | `consequence_completeness_dedekind_of_engine` binder `engine : ∀ ψ, ValidDedekindDense ψ → Derivable FrameClass.Dedekind [] ψ` (`StrongCompleteness.lean:275`) | file read |
| C19 | `sep` cannot exclude a single-gap accumulation | Reynolds §7 Lemma 10: the contradiction is *"an uncountable set of pairwise disjoint non-singleton intervals of ℝ. Impossible."* — a cardinality argument requiring failure at every point of an interval | corpus read + derivation stated in §1.3(3) |

---

## Adversarial Self-Verification

I attempted to refute the verdict on five fronts before filing it. Two attacks landed and
changed the report; three failed.

| Claim under attack | Source / Counterexample tried | Verification method | Outcome | Confidence |
|---|---|---|---|---|
| "The Doets route is faithful and reachable" | **Attack**: Doets' theorem is monadic FO over a *linear order*; TM is bimodal, `□` has no monadic table over the flow, so Reynolds' "table" translation does not exist for TM formulas | Read `mkSigFrom`/`predFormulas`, `multiFamTaskFrame`, `multiFamOmega_shiftClosed`, `countermodel_discrete_reynolds_v2` | **Attack FAILED.** Box-subformulas are already encoded as unary predicates and the modal dimension as a family index; the tree already ships a bimodal `≡ₖ` transfer at `.Discrete` | High |
| "Expressive completeness is available" | **Attack**: the landed `uSExpressivelyCompleteOverPrior` is pinned at `SemanticPriorUZ/SZ`, which is a *discrete*-flavoured (first-occurrence) hypothesis | Read `PriorDefs.lean:28-45`, `DedekindINF.lean:56-103` | **Attack SUCCEEDED — verdict amended.** The theorem is vacuous on dense flows and must be re-based to `HasDedekindINF`. §1.4 and the cost statement were rewritten; the "already 60-70% done" framing I first drafted was **deleted** as overclaiming | High |
| "(a) is dead" | **Attack**: only Prior-U and Prior-S were checked at 7.9; `Axiom.sep` was dismissed in report 05 §4.1 on a one-line ground and never re-examined against the two-sided pattern | Re-read Reynolds §7 Lemma 10 verbatim and reconstructed its cardinality argument | **Attack FAILED, and strengthened the verdict.** Sep's force is an uncountability argument that needs failure throughout an interval; one accumulation point escapes it. All three axioms are now exhausted **individually**, not by appeal to 7.9's summary | High |
| "The terminus is preserved" | **Attack**: Reynolds Theorem 7 is *weak* completeness; `consequence_completeness_dedekind` quantifies over arbitrary finite `Γ`, so a formula-by-formula construction (with `k` depending on the formula) may not suffice | Read the pinned binder at `StrongCompleteness.lean:274-279`; read Reynolds' definition of weak completeness verbatim | **Attack FAILED.** The engine binder is per-formula by construction, and Reynolds' own definition of weak completeness *is* the finite-set form. The 7.9 handoff's "reopens the terminus" note is superseded | High |
| "(b) is a plan revision, not a restart" | **Attack**: if the ℝ-completion arc dies, Phases 3-7.9 are ~all dead weight, so this is a restart in disguise and the user's no-needless-bridges constraint indicts the recommendation too | Built the asset ledger in §3 against the plan's Preserved Assets table | **Attack PARTLY SUCCEEDED.** Roughly the whole Phase 3-7.9 ℝ-extension layer becomes dead weight. §3 states this plainly rather than minimizing it. The *rational* chronicle (Phases up to `cantorBfmcsDense`) and the *entire* Phase 1/2 terminus layer survive intact, so it is not a restart — but the honest characterization is "a large mid-route amputation", not "a revision" | High |

**Contradiction log.**

- **Resolved.** Plan Postmortem Constraints (*"no expressive-completeness theorem … absent from
  this tree"*) **vs** `uSExpressivelyCompleteOverPrior` landed sorry-free. Precedence: a
  machine-checked `#print axioms` outranks a plan-time prose inventory. The plan clause is
  factually wrong and must be revised (§4, item 1).
- **Resolved.** Plan Preserved Assets (*"`EFGames/**`, `Kamp/**`, `MonadicFO.lean` — Route B
  needs none of it"*) **vs** the verdict, which makes that stack primary machinery. Precedence:
  the literature's route (Reynolds §6-§9) outranks a plan premise, per the standing user
  directive. Revise the plan (§4, item 2).
- **Not a contradiction, recorded to prevent one.** The 7.9 handoff's `next_dispatch_target`
  frames (b) as "entails weak rather than strong completeness and therefore reopens this task's
  terminus." Under the settled Reframing Note the headline result **already is** weak
  completeness, so (b) entails no downgrade. No contradiction with the plan; a contradiction only
  with the handoff's framing, which this report supersedes.
- **UNRESOLVED, flagged.** The two-sided-accumulation defeat of Prior-S remains **hand-checked,
  not formalized**, at 7.9 and again here. Downstream risk: if it is wrong, (a) might be
  revivable. The resolving check not yet performed: a ℚ-flow semantics module in which
  `Axiom.prior_S_gap`'s validity can be evaluated against an explicit two-sided family. This does
  not change the verdict — (b) is the faithful route regardless of whether (a) is merely unknown
  or actually dead — but it is the one claim in this report that rests on unformalized reasoning.

---

## 3. Asset ledger — genuinely reused vs dead weight under (b)

Per the user's no-needless-bridges constraint, stated without minimization.

### 3.1 Genuinely reused (survives (b) unchanged)

| Asset | Role under (b) |
|---|---|
| `SemanticConsequenceDedekindDense`, `truthAt_foldr_imp`, `semantic_deduction_dedekind_dense`, `derivable_foldr_imp_iff`, **`consequence_completeness_dedekind_of_engine`**, `soundness_dedekind_consequence`, `completeness_dedekind_of_engine` (`StrongCompleteness.lean`, Phase 2, commit `bd9ae0ac1`) | **The terminus, untouched.** The engine binder is Reynolds Theorem 7's shape exactly |
| `dedekind_box_dense_mem`, `real_lub_of_bddAbove`, the `CarrierProbe` examples (Phase 1) | The `D := ℝ` instantiation facts the countermodel still needs |
| `set_lindenbaum`, `neg_consistent_of_not_derivable`, `SetMaximalConsistent.*`, `theorem_in_mcs`, `conj_mcs` | Unchanged; step 0 of any route |
| **`Chronicle.cantorBfmcsDense`**, `rootedCantorFmcsDense`, `cantor_bfmcs_dense_restricted_tc/_buc/_fuc`, `limit_F_resolution`, `limit_satisfies_c4/_c4'`, **`limit_satisfies_c5_strong`/`_c5'_strong`**, **`cantorIsoDense`** | **The single largest reused asset.** This *is* Reynolds' Corollary 1 — the rational-flowed model with all axiom instances valid. (b) consumes it as step 1 and stops there |
| `Axiom.prior_U_gap`, `Axiom.prior_S_gap`, **`Axiom.sep`** + their soundness | Reused. `sep` becomes load-bearing for the first time on this route, as Reynolds Theorem 5 |
| `countermodel_dense_enriched`, `fully_restricted_parametric_completeness_from_neg_membership`, `ParametricCanonical*`, `BFMCS`/`FMCS` structures, the six coherence predicates | Unchanged; generic in `D`/`fc` |
| **`WeakCanonical/` monadic-FO + EF + Kamp + `IntegerModel/` stack** — `mkSigFrom`, `predFormulas`, `NormalForm`, `KEquiv`, `truth_transfer`, `ContempEquiv`, `good`/`VeryGood`, `doets_lemma_1_4`, `multiFamTaskFrame`/`multiFamOmega`, `countermodel_discrete_reynolds_v2` | **Promoted from "explicitly not touched" to primary machinery and template.** The `.Discrete` instance is the worked example of the exact argument (b) must run at `.Dedekind` |
| `uSExpressivelyCompleteOverPrior` / `kampPriorExpressiveCompleteness` chain | Reused **after re-base** to `HasDedekindINF`; the carrier and shims (`DedekindINF.lean`, `prior_hasDedekindINF`) already exist |

### 3.2 Dead weight under (b) (retains documentary, not proof, value)

| Asset | Landed by | Disposition |
|---|---|---|
| `limitSetBelow/Above` + 10 lemmas; `limitMCSBelow`, `limitMCSBelow_cofinal_below`, `limitMCSLindenbaum*` (+14) | Phases 3-4 | Dead. The ℝ-completion of the rational order is not performed under (b) |
| The 11 `LimitMCSCoherence` case lemmas | Phases 5-6 | Dead |
| `realLimitMCS*`, `FMCS.toReal*`, `BFMCS.toRealBundle` (both modal fields), `toRealBundle_restricted_temporally_coherent` | Phases 6, 6.1 | Dead |
| `limitFutureWitness_of_priorU`, `limitGuardBelow_of_priorS`, `limitGuardAbove_of_priorU`, `boundedWitness_of_limitGuardBelow` and their `cantor_bfmcs_dense_*` instances | Phases 6.2, 6.3, 7.3, 7.4 | Dead **as route**; individually they are correct, sourced Prior-U/Prior-S consequences and are the best evidence in the tree that the axioms behave as Reynolds says |
| `BFMCS.LimitFutureWitness`, `BFMCS.LimitGuardBelow`, **`BFMCS.LimitGuardEventual`** | Phases 6.2, 6.3, 7.4 | Dead. `LimitGuardEventual` is the obligation (b) exists to avoid |
| `toRealBundle_forward/backward_until_since` (both directions) and the ~17 supporting declarations in `ChronicleRealExtension.lean` | Phases 7.1′, 7.2, 7.4 | Dead |
| **All of `ChronicleGuardAccumulation.lean`** — `NoGuardAccumulation`, `AscendsToGap`, `CofinalBelowGap`, `limitGuardEventual_of_noGuardAccumulation`, **`noGuardAccumulation_transport`**, `familyQ_violates_noGuardAccumulation`, `guardAccumFamily_*`, `noGuardAccumulation_not_implied_by_limit_data` | Phases 7.5, 7.9 | Dead as machinery. **`noGuardAccumulation_not_implied_by_limit_data` must be retained** as the archived, machine-checked record of *why* the completion route was abandoned — it is the closing argument of this task's postmortem |
| The 7.6/7.7 invariant-preservation material appended to `CounterexampleElimination.lean` | Phases 7.6, 7.7 | Dead. If it is invasive to the walk regions, prefer archival over deletion so the chronicle stays byte-stable |

**Net**: Phases 1, 2 and the rational chronicle survive whole. Phases 3 through 7.9 — the entire
ℝ-extension-by-limits layer — become dead weight. That is a large amputation and the plan
revision must say so in its Revision Rationale rather than presenting (b) as continuous with v6.

---

## 4. Plan sections that MUST be revised before any further implement dispatch

Against `plans/06_strong-completeness-dedekind-v6.md`. Line anchors are as of this reading.

1. **Postmortem Constraints — bullet "Do NOT build any part of the Reynolds transfer route"
   (≈L820-826).** **REVERSE.** Its stated premise ("expressive-completeness theorem … absent
   from this tree and from Mathlib") is refuted by `uSExpressivelyCompleteOverPrior`
   (`PriorExpressiveness.lean:359`, axiom-clean). The replacement clause must carry the *real*
   constraint discovered here: the landed theorem is pinned at a hypothesis vacuous on dense
   flows and may not be applied at `.Dedekind` until re-based to `HasDedekindINF`.
2. **Preserved Assets — "Explicitly NOT touched by any phase of this plan" list (≈L767-771).**
   The rows `Metalogic/WeakCanonical/EFGames/**`, `Kamp/**`, `MonadicFO.lean` ("Route B needs
   none of it") and `IntegerModel/**` must move from *not touched* to *primary machinery and
   template*. `Transfer.lean:1242` stays untouched and out of scope.
3. **Postmortem Constraints — "Do NOT use `countermodel_discrete_reynolds_v2` as a template"
   (≈L849-852).** **REVERSE with a narrowing.** Its objection (hard-coded `.Discrete`,
   `SuccOrder`/`PredOrder`/`IsSuccArchimedean` in the existential) is about the *statement*; the
   *method* — `mkSigFrom` + multi-family `≡ₖ` transfer + `multiFamOmega` — is exactly the
   template (b) needs. `countermodel_dense_enriched` remains the template for the terminus
   plumbing.
4. **Phase 7.2 RESOLUTION — "Rung elected: R4 (honest floor), with R2 eliminated on source
   evidence" (≈L3006-3016)** and **the fallback ladder's R2 clause (≈L3120-3128).** R2 was
   eliminated solely by the constraint in item 1. With that constraint corrected, **R2 is live
   and is the elected rung.** Rewrite both blocks; keep the verbatim Reynolds quotations, which
   are correct and now read as a route *specification* rather than a prohibition.
5. **Source-to-Implementation Mapping (H3) — rows at ≈L784, L790, L799, L803.** These classify
   Reynolds §6/§7 material as "constraint check — nothing built" and "FORBIDDEN". Re-map to
   implementation targets (Theorem 4 → the dense instance of `no_gaps_*`; Theorem 5 → the first
   consumer of `Axiom.sep`; Theorem 6 → the ℝ-interval `good`).
6. **Goals & Non-Goals (≈L1355) and the Risk block (≈L1345-1357)** — remove "requires the EF /
   modal-depth machinery the Postmortem Constraints forbid and that killed R2".
7. **Risk block at ≈L1460-1475** — its closing sentence (*"Reynolds … routes through
   contemporaneous equivalence classes, Doets' theorem and `Axiom.sep` — **not** through a
   Dedekind completion of a rational chronicle"*) is **correct and prescient**; promote it from
   a risk note to the route statement.
8. **R3d umbrella charter (≈L3501) and Phases 7.5-7.9.** Mark the **route** retired, citing
   `noGuardAccumulation_not_implied_by_limit_data`. The `[COMPLETED]` markers on 7.5-7.8 describe
   landed sorry-free Lean and stay; add a disposition line to each recording that the material is
   superseded. Phase 7.9 stays `[BLOCKED]` and becomes the postmortem's exhibit.
9. **Phase 8 (≈L4305-4430).** Replace the precondition "discharge of `BFMCS.LimitGuardEventual`"
   with the Doets-route engine precondition. **The `consequence_completeness_dedekind_of_engine`
   pinned signature and commit `bd9ae0ac1` carry over unchanged** — this is the one thing v7 must
   not touch.
10. **Overview (≈L619-640), phase count (≈L78-84), Revision Rationale.** New phase set; the
    Revision Rationale must state plainly that Phases 3-7.9 become dead weight (§3.2) and that
    the trigger was a factual error in v6's own Postmortem Constraints, not a change of ambition.

**Recommended first dispatch after the revision is NOT Lean on the chronicle.** It is the
`HasDedekindINF` re-base scoping already written out at `DedekindINF.lean:87-97` (Lemma 5.3 →
Lemma 5.1 → Prop 4.2), because everything downstream in (b) is vacuous until that lands.

---

## 5. Status

`phases_completed` remains **17/19**. Nothing was marked complete, blocked, or otherwise
transitioned by this dispatch; no `.lean` file was read for edit or modified. Status transitions
belong to the orchestrator.

---

## 6. Verification performed in this dispatch

| Check | Result |
|---|---|
| `lean_verify uSExpressivelyCompleteOverPrior` | `[propext, Classical.choice, Quot.sound]`, no warnings |
| `lean_verify doets_lemma_1_4` | `[propext, Classical.choice, Quot.sound]`, no warnings |
| `lean_verify countermodel_discrete_reynolds_v2` | `[propext, Classical.choice, Quot.sound]`; one `opaque` source-scan note at `ReynoldsBridge.lean:651` |
| `lean_verify noGuardAccumulation_not_implied_by_limit_data` | `[propext, Classical.choice, Quot.sound]`, no warnings |
| Lean files edited | **0** |
| Corpus documents read verbatim | Reynolds 1992 §5, §6, §7, §8, §9 and the §2/§3 framing; Burgess 1984 §2.7 and the `¬,∧,G,H` line; Doets 1987 ch.3 §3.3 |
