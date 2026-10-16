# Research Report: The set-valued cell over a quotient — step (1), the closure-indexed periodicity gate

- **Task**: 806 - Set-valued cell over a quotient index (research-first successor to the refuted cell-index line)
- **Started**: 2026-10-16T00:00:00Z
- **Completed**: 2026-10-16T00:00:00Z
- **Effort**: one research round (round 1 of this record); step (1) costed and partly discharged on compiled ground
- **Dependencies**: 761 (parent, `[BLOCKED]`); 805 (predecessor, refuted); 773, 775 (archived predecessors)
- **Sources/Inputs**:
  - Library: `FormalSystem/Metalogic/Decidability/RaySummary/{RunLayer,LadderModel,AnchorLayer,Profile}.lean`, `RaySummary/README.md`, `FormalSystem/PlusLanguage/{Formula,Subformulas}.lean`
  - Probes: `specs/evidence/seam-gluing-ray-product/ladder-joint-index-refutation.lean` (header + `ladderIndexJnt`, `psi2`, `chi`, `nextPow`)
  - Prototype predecessor: `specs/archive/773_ladder_cell_index_factorization/prototype/reach-eventual-periodicity.lean`
  - Records: `specs/805_jointly_derived_cell_index_gate/reports/0{1,2}_*.md`, `specs/reviews/review-20261016.md`, `specs/761_ladder_realization_theorem/reports/02_spawn-analysis.md`
  - Toolchain: `lake env lean` on Lean v4.33.0-rc1 (compiled this session)
  - lean-lsp MCP: not consulted this round (evidence tier for every Lean claim below is a **compiled file**, not an index lookup)
- **Artifacts**:
  - `specs/806_set_valued_cell_quotient_index/reports/01_closure-indexed-periodicity-gate.md` (this report)
  - `specs/806_set_valued_cell_quotient_index/prototype/closure-indexed-periodicity.lean` (238 lines, sorry-free, compiles clean)
- **Standards**: report-format.md, artifact-management.md, status-markers.md, plan-compliance.md (Statement Fidelity), subagent-return.md

## Executive Summary

- **Step (1) survives, and it is cheaper than the dispatch's framing suggests — but only one half of
  it is.** Eventual periodicity of the countdown over the object-closure product is an instance of
  `iterate_eventually_periodic` at the carrier `Finset (Q × ClType φ)`; the only thing that could
  have failed in Lean — finiteness of the closure-indexed carrier — does not fail. Compiled this
  round, sorry-free, no new axiom.
- **The expensive half of step (1) is not periodicity but ADEQUACY**: constructing the coherence
  relation whose iteration actually computes the *realizable* types (not merely the locally coherent
  ones), and relating it to `PlusTruthAt`. Periodicity is robust under every enlargement of that
  carrier that stays finite, which is exactly why it is the cheap half. This reframing is the main
  finding of the round and it changes how step (1) should be planned.
- **The closure-indexed replacement is a strict refinement of the letter-indexed one**, and this is
  now on compiled ground in miniature: an object whose full-graph reach set is constant from step 4
  (period 1) carries a product whose minimal period is 3 and is not 1. A modulus covering the
  object's exhibited period therefore need not cover the product's — the gap gate 6 exhibited, in
  general form.
- **The candidate presentation is named and its quotient is pinned**: the datum is the
  *closure-indexed countdown profile*, a SUBSET of the finite product `Q × ClType φ`, and the
  quotient is by the **kernel of that profile map**, not by any arithmetic congruence fixed in
  advance. There is no modulus parameter, so the mechanism every one of gates 4, 5 and 6 attacked —
  a parameter chosen before the witness — has no target.
- **Two gates the set-valued shape invites that the four tuple shapes did not** are identified here
  and must be added to the table before any sufficiency attempt: a **non-circularity gate** (a
  set-valued datum can be made to "succeed" by being the cell, which is vacuous) and a **`stab`
  self-reference gate** (`stab_mem_tpOf_iff` puts the cell on both sides of the datum's own defining
  equation, at definition time rather than proof time).
- **Gate 1 is not addressed by step (1) and must not be reported as passed by it.** Gate 1's pair
  has equal countdown and differing next deadline; the countdown profile reads the countdown only.
  That is obligation (c), the `Drift` coupling, and it is untouched.

## Context & Scope

This is round 1 of the research-first successor record opened after the sixteenth wired probe
refuted the six-coordinate index at rule-derived parameters. The dispatch orders five work items;
this round executes items (1) and (2) and prepares item (3), which is what a research round can
carry. Items (4) and (5) are explicitly downstream: (4) is the wired probe, and (5) is conditional
on the gate being survived in full, which it is not yet — only its first obligation is.

Scope boundaries honoured, and verifiable by `git status`: nothing under `FormalSystem/` or
`Tests/` is touched; the one new file is a prototype under this task's own directory. No
`ladderRealized`, no `LadderCons`, no `ladderCons_localRun`, under those names or any others; no
seventh tuple coordinate is proposed; no positive factorization lemma is stated, sketched or
implied anywhere in this report or in the prototype.

What is NOT re-attacked, per the dispatch: the finiteness and bound on the SET of cells
(`anchorCells_finite`, `anchorCells_ncard_le`) is settled and untouched; the four refuted index
shapes are not re-derived.

## Findings

### 1. Verified starting state

Every row was checked against the tree this session. Re-check cheaply; do not re-derive.

| Claim | How it was verified this session |
|---|---|
| `PlusFormula` has six constructors and **no primitive next** | `FormalSystem/PlusLanguage/Formula.lean:91-108` read directly: `atom`, `bot`, `imp`, `box`, `untl`, `snce`, `stab`, `deriving Repr, DecidableEq, Countable` |
| `X` is derived, hence **inside the closure** | `nextPow` in `ladder-joint-index-refutation.lean:242-244` is `.untl .bot (nextPow k chi)`; so a nested-next pattern is a subformula chain and `plusSubformulaClosure` tracks it |
| `plusSubformulaClosure φ` is a `Finset` | `FormalSystem/PlusLanguage/Subformulas.lean:187-188`: `(PlusFormula.subformulas φ).toFinset` |
| Subsets of the closure form a **`Fintype` with `DecidableEq`** | compiled: `{T : Finset PlusFormula // T ∈ (plusSubformulaClosure φ).powerset}` resolves both instances by `inferInstance`, and so does `Fintype (Finset (Q × ClType φ))` |
| `reachN_eventually_periodic` and `iterate_eventually_periodic` exist **only** in the archived prototype and in probe copies, not under `FormalSystem/` | `grep -rn 'reachN_eventually_periodic' .` returns hits only in `specs/**` and in README prose |
| The countdown measures distance to a region end exactly | `Count` (`RunLayer.lean`): `py ∧ px → c' + 1 = c`; `py ∧ ¬px → c' = n`; `¬py → c' = 0 ∧ (px → c = 0)`. No early discharge |
| The valuation reads the object component only | `ladderModel` (`LadderModel.lean`): `valuation := fun w p => lab w.2.1.1 p = true` |
| `⊡` is a per-cell bit, not a per-state-component bit | `stab_mem_tpOf_iff` (`AnchorLayer.lean:208-223`): `⊡ψ ∈ tpOf σ z ↔ ∀ σ', σ.state z = σ'.state z → ψ ∈ tpOf σ' z` |
| The refuted index body is six arithmetic coordinates | `ladderIndexJnt` (`ladder-joint-index-refutation.lean:174-181`): `(q, min c T, c % (P+1), min n T, n % (P+1), min (n+B-c) (2B))` |
| The repo already contains one **set-valued factorization**, at another layer | `Profile.lean:164` `abbrev Profile := KType × (KType → KType → KType → Bool)`, with `profileFintype`, `card_profile` (documentary only), and `kTypeOf_eq_of_profile_eq` |

### 2. Step (1) restated precisely, and split into a cheap half and an expensive half

The dispatch's wording is: *eventual periodicity of the realizable types in the countdown over the
product of the object with the closure*, with the restriction required to be **closure-indexed, not
letter-indexed**. Unpacked against the tree, that is three separable claims:

1. **(Carrier finiteness.)** The product `Q × ClType φ` is finite whenever the object is.
2. **(Periodicity.)** Any endofunction of `Finset (Q × ClType φ)` has eventually periodic iterates,
   with a positive period.
3. **(Adequacy.)** The set of *realizable* closure types at countdown `c` **is** the `c`-th iterate
   of such an endofunction applied to a fixed region-end set.

Claims 1 and 2 are discharged this round (§3). Claim 3 is **not**, and it is where the work is:

- A plain subset iteration over a *locally coherent* step relation computes the types that survive
  the one-step fixpoint equations. That **over-approximates** realizability, because `untl` and
  `snce` additionally require their eventualities to be *fulfilled* — a Büchi-style acceptance
  condition on the infinite ray, not a local condition. The standard repair is to enlarge the
  product state by a fulfilment-flag component; the enlarged carrier is still finite, so **claim 2
  survives every such repair**. That is precisely why periodicity is the cheap half and should not
  be mistaken for the gate.
- A second scope caveat, independent of the first: `Prof(c) = pre^[c] E` holds only if the
  region-end set `E` is **fixed**. `Count`'s region-start clause is `c' = n`, so which region-end
  product states are admissible depends on the next-deadline value at that moment, which `Drift`
  moves by at most one per step. Over a fixed `E`, the countdown profile over-approximates. This is
  obligation (c) and it is untouched.

**Verdict on step (1): survived, with its content relocated.** Nothing refutes closure-indexed
eventual periodicity; what the round establishes is that the obligation's difficulty lives in
adequacy, not in periodicity, and that the adequacy half is not costable in one round for the same
reason the dispatch already says the full sufficiency attempt is not.

### 3. What was put on compiled ground this round

`specs/806_set_valued_cell_quotient_index/prototype/closure-indexed-periodicity.lean` — 238 lines,
`sorry`-free, compiles with no errors and no warnings under `lake env lean`; `#print axioms` on all
seven named theorems reports `[propext, Classical.choice, Quot.sound]`, i.e. **no new axiom**, no
`sorryAx`, no `ofReduceBool` (`native_decide` is deliberately not used).

| Declaration | What it establishes |
|---|---|
| `iterate_eventually_periodic` | ported byte-for-byte from the archived prototype, which is untouched; restated so the file stands alone |
| `ClType φ`, `ProdState Q φ`, `instFintypeProdState`, `instDecEqProdState` | the closure-indexed carrier is finite with decidable equality — the one thing that could have failed |
| `prodReachN_eventually_periodic` | forward reach over the product is eventually periodic |
| `prodPreN_eventually_periodic` | **the operator the countdown actually iterates** (predecessors of a set) is eventually periodic |
| `prodReach_fst_subset` | for any `pstep` lying over the object's `step`, the product never over-approximates the object: `((prodReachStep pstep)^[k] S).image Prod.fst ⊆ (reachStep step)^[k] (S.image Prod.fst)` |
| `strict_object_period_one`, `strict_product_period_three`, `strict_product_not_period_one` | the refinement is **strict**: on a 3-cycle-plus-2-cycle object the full graph's reach set is constant from step 4 (period 1), while a product over it has period 3 and not period 1 |

The strictness witness is deliberately framed as a witness to the **shape** of gate 6, not an
instance of it: its context component is a bare `Bool` standing in for a closure component, and no
formula, closure or coherence relation is constructed. It settles exactly one thing — that the
product period and the object period are independent, so a modulus covering the latter need not
cover the former.

The prototype's own header carries the full "what this does NOT say" list, in the convention of the
probe collection.

### 4. Step (2): the candidate presentation, and what the quotient quotients BY

**The datum.** Fix the object `(Q, step, pend, lab)` and the formula `φ`. Write `Cl := plusSubformulaClosure φ`
and `ClType φ` for its subsets. Let `coh : ProdState Q φ → ProdState Q φ → Bool` be the coherence
relation of the object-closure product — **a parameter at this stage, not a construction**; it is
the object of claim 3 above. Let `E ⊆ ProdState Q φ` be the admissible region-end set. Then

- the **countdown profile** at distance `k` is `Prof(k) := (prodPreStep coh)^[k] E`, a subset of a
  finite set;
- the **set-valued per-state datum** at a ladder state `x = (q, c, n)` is the fibre
  `D(x) := {T | (q, T) ∈ Prof(c)}` — a SET of closure types, not a tuple of residues — together
  with the next-deadline-side datum that obligation (c) owes.

**What the quotient is quotienting BY** — the dispatch asks this explicitly, and the answer is the
whole content of the proposal: the quotient is by the **kernel of the profile map**, i.e. two
countdown values are identified exactly when they have the same closure-indexed profile, and two
ladder states are identified exactly when their object component and their profiles agree. It is
**not** a quotient by an arithmetic congruence chosen in advance. By §3 the kernel has finitely many
classes, with a threshold and a period that are *consequences* of pigeonhole on the product, never
parameters offered to the construction.

**Why finiteness is free here and was expensive before.** Every refuted shape needed a modulus to
force its index type finite, and the modulus was a side condition that had to be stated, justified
and defended — gates 5 and 6 are exactly attacks on that side condition. The profile's codomain is a
powerset of a finite set, so finiteness is structural and there is no clause to defend.

### 5. Which of the four refuted shapes this is not a re-presentation of, and why

All four refuted shapes are maps `LadderState Q pend → (a fixed finite tuple type)` whose value is an
**arithmetic function of the two counters** under parameters `(T, P, B)` fixed before the witness is
chosen: (1) counter-pair clipping; (2) gap-carrying clipping; (3) the six-coordinate residue body at
object-exhibited `(T, P)`; (4) the same body at rule-derived `(T, P, B)`. Each refutation has the
same schema — *fix the parameters, then exhibit two counter pairs with equal index and different
cells*.

The countdown profile is not of that family, for three reasons that should be stated separately
because they fail independently:

- **It is set-valued, not tuple-valued.** Its codomain is `Finset (ProdState Q φ)`, whose elements
  carry closure information. No refuted shape's codomain mentions the closure at all.
- **It has no parameter.** The refutation schema needs a parameter to fix. A collision of profiles
  would be a genuine collision, not a bad parameter choice — which is a different and harder thing
  to exhibit, and is the point of changing presentation.
- **It is the candidate the sixteenth probe's header explicitly held open.** That header records: *"A
  candidate whose modulus is derived from the object-closure product is a DIFFERENT candidate, not
  gated here."* This record is that candidate's first round.

**The reading to guard against, stated so a reviewer need not find it.** Because the profile induces
a threshold and a period, one could re-present it as `(q, min c T*, c % (P*+1), …)` and land back in
the tuple family. That re-presentation is **not** what is proposed, and the report does not claim it
would survive. The datum is the set; the threshold and period are facts *about* the set's orbit, not
the index.

### 6. Why the gate-6 pattern-definable sub-object does not re-refute this presentation

Gate 6's separating formula is `chi := ¬psi2 ∧ ¬(⊤ U psi2)` with `psi2 := (p ∧ ℓ_a) ∧ X X (p ∧ ℓ_a)`,
and `X` is `⊥ U ·` (`nextPow`). Therefore `psi2`, `X (p ∧ ℓ_a)`, `(p ∧ ℓ_a)` and `⊤ U psi2` are all
**subformulas of `chi`**, hence all members of `plusSubformulaClosure chi`.

Consequence: the closure component of `ProdState Q chi` carries a bit for each of them, and any
coherence relation worth the name propagates those bits along a step. On the coprime-cycle object the
2-cycle `a → d → a` is exactly what makes `psi2` true, so the `chi`-consistent part of the product
contains no transition through `d`, and its live set cycles with period 3. A condition of the form
*the quotient must respect the product's period* therefore **forces** the divisibility that the
letter rule failed to force. Gate 6's mechanism is internalised rather than evaded.

Two honest qualifications, both load-bearing:

- This argument is about a coherence relation **not yet constructed**. What is compiled is the
  general fact that a context component can produce a period the object's own graph does not exhibit
  (§3). Running it on the actual coprime-cycle fixture with the actual closure of `chi` is probe
  work, and it is the single most informative thing the next round can do.
- Internalising mechanism (6) says nothing about a seventh mechanism. The standing lesson of this
  line — *a gate probing one coordinate certifies one coordinate* — applies verbatim, and with more
  force here, because this candidate is precisely the one that would reach a seventh gate.

### 7. Step (3): the gate table rebuilt against the new presentation

Rebuilt before any sufficiency attempt, as the dispatch requires. "Disarmed by construction" is
recorded below as a **claim to be exhibited in the probe**, never as a pass.

| Gate | Mechanism | Status against the countdown profile |
|---|---|---|
| 1 | gap pair `(B, B+1)` vs `(B, B+2)` — equal countdown, differing next deadline | **NOT ADDRESSED.** The countdown profile reads `c` only. Needs the next-deadline-side datum; that is obligation (c). Must not be reported as passed by step (1). |
| 2 | residue pair `(2B, 4B+2)` vs `(2B+1, 4B+2)` | Expected to separate, because below the product's threshold the profile is countdown-exact. To be probed, not assumed. |
| 3 | second region, past direction | Unchanged and still finds no refutation: the verdict there does not read the index's parameters at all (`Count false false` holds the countdown at `0` through an idle interval of any length). |
| 4 | object-exhibited threshold, via the depth-`(T+1)` next-chain | **Disarmed by construction (claim).** No threshold is a parameter. Moreover the witness formula's own `untl`-depth enlarges the closure, hence the product, hence the profile — the diagonal moves the carrier rather than escaping a bound. |
| 5 | full-graph reach-set period | **Disarmed by construction (claim).** The profile is taken over the product, never over the full step graph; §3's strictness witness is the general statement of why these differ. |
| 6 | pattern-definable sub-object | **Internalised (claim).** §6. The pattern is a subformula, hence in the closure, hence tracked by the product. |
| **7 (new)** | **Non-circularity / non-vacuity** | A set-valued datum can be made to "succeed" by *being* the cell. The datum must be definable from `(Q, step, pend, lab, φ)` alone, with no quantification over histories of the infinite carrier. The four tuple shapes could not fail this way; this shape can, and it is the characteristic failure mode it invites. |
| **8 (new)** | **`stab` self-reference** | `stab_mem_tpOf_iff` makes `⊡ψ`'s bit a function of the CELL at the state. So the datum occurs on both sides of its own defining equation — a fixpoint obligation that bites this shape at *definition* time, not, as for the tuple shapes, at proof time inside obligation (d). |

Gates 7 and 8 are the round's second substantive finding: the change of presentation does not merely
move the existing gates, it adds two. Neither can be deferred to a sufficiency attempt, because both
are obstructions to *stating* the candidate rather than to proving it sufficient.

### 8. In-repo precedent for a set-valued factorization

`RaySummary/Profile.lean` is the repository's own worked example of the move 806 proposes, at the
seam layer rather than the ladder layer: an arithmetic summary is replaced by `Profile := KType ×
(KType → KType → KType → Bool)` — a type paired with a Bool table, i.e. a set-valued datum — with
`profileFintype`/`profileDecidableEq` discharged by hand (instance search does not reach three
nested function levels), `card_profile` kept **documentary only**, and `kTypeOf_eq_of_profile_eq`
the factorization lemma that equality of profiles buys.

What transfers: the shape of the datum, the discipline of keeping the cardinality a count, the
expectation that `Fintype` instances at nested levels need hand-holding, and the composition lemmas
(`starProfile_append`, `profile_append_congr`) as the template for obligation (b)'s pumping lemma.

What does **not** transfer, and must not be read as precedent: `Profile` summarises **finite words**
with a decidable local notion; the ladder datum must summarise **bi-infinite rays through an infinite
carrier**, where the fulfilment conditions of §2 have no counterpart in the seam layer. The precedent
is architectural, not mathematical.

### 9. Costing step (4)

Promoting this round's prototype to a wired probe is cheap and should be scheduled: add a decision-row
comment block and one `WIRED` array entry in `scripts/check-evidence-probes.sh`, and move the file to
`specs/evidence/seam-gluing-ray-product/`. That script's own header documents why this matters —
probes left in a task directory were lost to `.gitignore` when `/todo` archived the task, and the
guard then failed against a path that no longer existed. **This round's prototype is sitting in
exactly that position.**

The probe that would carry the full step-(1)-through-(3) verdict additionally needs: the coherence
relation for at least the `psi2` pattern; the coprime-cycle fixture's frame/regularity/history layer
ported (label-generic, so it ports verbatim per the dispatch); and gates 4, 5 and 6 exhibited rather
than asserted. On the density of the three predecessor probes (24k-78k on disk each), that is a
multi-hundred-line file and a round of its own.

## Decisions

1. **Report step (1) as survived, and relocate its content.** The periodicity half is discharged on
   compiled ground; the adequacy half is named, scoped and left open. Reporting "step (1) is done"
   without that split would overstate the round.
2. **Keep the deliverable a prototype this round, not a wired probe.** Precedent is the archived
   round's `prototype/` directory, and a half-wired probe that must be re-edited next round is worse
   than a clearly-labelled prototype plus a scheduled promotion (§9). The archive-loss risk is
   recorded as a risk, not ignored.
3. **Do not construct the coherence relation this round.** It is the adequacy obligation; building it
   speculatively, before the gate table of §7 is agreed, is how the tuple-widening loop was entered.
4. **Record gates 7 and 8 now, before any construction.** Both are obstructions to stating the
   candidate; discovering them after a definition exists would invite a weakened definition to fit.
5. **No weakened substitute, under any name.** No `ladderRealized`, no `LadderCons`, nothing without
   the `box`/`stab` clause, in the report or the prototype.
6. **Use `decide`, never `native_decide`, on the strictness witness.** `native_decide` would add
   `ofReduceBool` and break the no-new-axiom discipline every probe in the collection keeps.

## Recommendations

Prioritised; owner is the next dispatch on this record unless stated.

1. **Promote the prototype to `specs/evidence/seam-gluing-ray-product/` and register it in
   `scripts/check-evidence-probes.sh`** before this task can be archived. Cheap, and it is the one
   action with a known failure mode if skipped (§9).
2. **Next round's single most informative probe: run §6 on the real fixture.** Define the coherence
   relation for `chi`'s closure on the coprime-cycle object and show the `chi`-consistent product has
   period 3 where the full graph has period 1. This converts §6 from claim to compiled fact and is
   the direct successor of gate 6.
3. **Attack gate 7 (non-circularity) before gate 1.** A datum that fails gate 7 cannot be fixed by
   adding the next-deadline component, and gate 1 cannot be assessed until the datum is definable.
4. **Treat gate 8 (`stab` self-reference) as a definitional obligation of this shape**, and keep it
   out of obligation (d), which is about proving the `box`/`stab` letters, not about whether the
   datum is well-defined.
5. **Leave obligations (b), (c), (d) named and unmet**, as the dispatch directs: the region-length
   pumping lemma for `untl`/`snce`-depth-bounded formulas; the next deadline's coupling through
   `Drift`; the `box`/`stab` letters through `box_mem_tpOf_iff` and `stab_mem_tpOf_iff`.
6. **Do not re-enter the tuple family** by re-presenting the profile's threshold and period as index
   coordinates (§5, final paragraph).

## Risks & Mitigations

- **Risk: "step (1) is cheap" is read as "the obligation is discharged".** It is not; only
  periodicity is. *Mitigation*: §2 splits the obligation into three claims and marks claim 3 open;
  the prototype header says the product step relation is a parameter and that no clause of
  `PlusTruthAt` is unfolded.
- **Risk: the prototype is lost to `.gitignore` when this task is archived**, reproducing the exact
  failure `check-evidence-probes.sh`'s header documents. *Mitigation*: Recommendation 1, scheduled
  rather than deferred; the risk is named in the plan's first phase.
- **Risk: the strictness witness is read as an instance of gate 6.** It is a witness to the shape,
  with a `Bool` context rather than a closure. *Mitigation*: stated in the prototype header, in §3
  and in §6's first qualification.
- **Risk: the set-valued datum is defined circularly and the circularity is not noticed**, because a
  circular definition still type-checks and still "factors" the cell. *Mitigation*: gate 7 is in the
  table and is recommended to run first.
- **Risk: adequacy is quietly weakened to local coherence**, which is a strictly weaker property that
  a subset iteration computes and that looks like success. *Mitigation*: §2 names fulfilment as the
  gap and names the finite repair (flag component) that keeps periodicity intact, so the weakening
  has no cost-saving motive.
- **Risk: a seventh mechanism exists and this round's optimism about gate 6 masks it.**
  *Mitigation*: §6's second qualification restates the standing lesson; the gate table marks every
  "disarmed by construction" as a claim to exhibit.

## Tactic Survey Results

Surveyed against the prototype's four non-trivial goals. All results are from this session's
compiles.

| Goal | Tactic | Result | Premises/Config |
|---|---|---|---|
| `Fintype`/`DecidableEq` for `ClType φ`, `ProdState Q φ`, `Finset (ProdState Q φ)` | `inferInstance` | success | no hand-supplied intermediate instances needed, unlike `Profile.lean`'s three-nested-function case |
| `iterate_eventually_periodic` | pigeonhole + `omega` | success (ported) | `Finite.exists_ne_map_eq_of_infinite`, `Function.iterate_add_apply` |
| `prodReach_fst_subset` | induction on `k`, generalised over both the product set and the object set | success | `Function.iterate_succ_apply`; `simp only [Finset.mem_image, Finset.mem_biUnion, Finset.mem_filter, Finset.mem_univ, true_and]` |
| same, first attempt | `Finset.iterate_subset_iterate_of_subset` | **fail** — unknown constant | monotone-iterate lemma does not exist under that name; generalising the induction over the target set removes the need for one entirely |
| `strict_object_period_one` / `strict_product_period_three` / `strict_product_not_period_one` | `decide` | success on an 8-element product carrier | first attempt stated the wrong threshold (3, not 4) and the wrong start set (a singleton, not the fibre) and `decide` **disproved** both — a useful property of stating periodicity claims with concrete bounds |
| same | `native_decide` | not attempted, deliberately | would add `ofReduceBool`; see Decision 6 |

`lean_multi_attempt` and the rate-limited search tools were not used: every goal here is either a
port or a `decide` on a concrete finite fixture, and the one search question (does a monotone-iterate
lemma exist for `Finset`?) was answered faster by the compiler rejecting the guessed name.

## Context Extension Recommendations

- **Topic**: the parameter-origin rule and gate table for a ladder cell index
  (`context/project/lean4/domain/ladder-counter-observables.md`, in the source store at
  `~/.config/nvim/agent-system/extensions/lean/...`).
- **Gap**: the note's gate table is written for *tuple* candidates with parameters. It has no row for
  a set-valued candidate, and therefore no counterpart to gates 7 and 8 — the two obstructions that
  are specific to a datum whose codomain is a powerset.
- **Recommendation**: add a short section "gates specific to a set-valued presentation" carrying the
  non-circularity gate and the `stab` self-reference gate, and a sentence recording that for a
  set-valued datum finiteness of the index type is structural, so the modulus clause the note spends
  most of its length on does not apply. Must be edited in the source store, not in the deployed
  `.claude/` mirror (`source-store-deploy-boundary.md`); it needs its own commit outside this
  repository and cannot ride this task's scoped commit.

## Appendix

**Prototype.** `specs/806_set_valued_cell_quotient_index/prototype/closure-indexed-periodicity.lean`,
namespaces `ClosureIndexedPeriodicity` and `StrictnessWitness`, 238 lines. Compile command is in its
header:
`lake env lean specs/806_set_valued_cell_quotient_index/prototype/closure-indexed-periodicity.lean`.
Clean run this session: no errors, no warnings. `#print axioms` on all seven named theorems:
`[propext, Classical.choice, Quot.sound]`.

**Registration shape for the promotion in Recommendation 1.** `scripts/check-evidence-probes.sh`
carries, for each probe, a boxed comment row (`# <path> | <the decision it holds in place>`) above the
`WIRED` array, and one string entry inside it; the guard additionally requires the file to be *tracked*
by git, not merely present (`git ls-files --error-unmatch`).

**Declarations leaned on and not touched.** `anchorCells_finite`, `anchorCells_ncard_le`,
`box_mem_tpOf_iff`, `stab_mem_tpOf_iff`, `cellAt_eq_cellAt`, `Rlad`, `Count`, `Drift`,
`Rlad_slice_infinite`, `ladderFrameAdm_isRegular`, `ladderModel`, `plusSubformulaClosure`,
`Profile`/`card_profile`/`kTypeOf_eq_of_profile_eq`.

**Predecessor records cited and not re-derived.** `ladder-cell-refutation.lean` (shape 1),
`ladder-cell-index-obstructions.lean` (shapes 2-3, gates 1-3),
`ladder-residue-index-refutation.lean` (shape 3's parameters, mechanisms 4-5),
`ladder-joint-index-refutation.lean` (shape 4, gates 4-6, `psi2`/`chi`/`nextPow`),
`specs/archive/773_ladder_cell_index_factorization/prototype/reach-eventual-periodicity.lean`
(`iterate_eventually_periodic`, ported).

**Carried figures.** The per-gate mechanism descriptions in §7's rows 1-3 and the sixteenth probe's
gate outcomes are taken from that probe's header, read at its cited path this session but not
re-derived by re-running its theorems [CARRIED-UNVERIFIED:
`specs/evidence/seam-gluing-ray-product/ladder-joint-index-refutation.lean`, header sections "Gates
1-3: passed" through "Gate 6"]. The statement that the coprime-cycle object's reach sets are constant
from threshold 4 with period 1 is likewise read, not re-run [CARRIED-UNVERIFIED:
`FormalSystem/Metalogic/Decidability/RaySummary/README.md`, requirement (W) section,
`reach5_eventually_constant`]. Every figure about this round's own prototype was measured this
session.
