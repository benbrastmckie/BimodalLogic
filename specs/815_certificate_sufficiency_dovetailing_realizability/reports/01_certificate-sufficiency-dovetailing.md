# Research Report: Certificate sufficiency -- the dovetailing argument as a theorem, the backward arm as a refutation, and the repair

- **Task**: 815 - Certificate sufficiency: dovetailing, realizability (the SUFFICIENCY half of realizable-type adequacy)
- **Started**: 2026-10-17T14:58:34Z
- **Completed**: 2026-10-17T15:32:16Z
- **Effort**: one research round; one new wired probe compiled (1655 lines, 13 printed theorems), four compile cycles to a clean file
- **Dependencies**: 809 (predecessor: the certificate presentation and the uncompiled section-6 argument); 806 (the countdown-profile round); 761 (parent, `[BLOCKED]`, gated on this)
- **Sources/Inputs**:
  - Compiled ground, read in full this session: `specs/evidence/seam-gluing-ray-product/realizable-type-certificate.lean` (namespace `Probe809C`), `specs/evidence/seam-gluing-ray-product/realizable-type-adequacy-gap.lean` (namespace `Probe809`), `specs/evidence/seam-gluing-ray-product/ladder-liveness-forward-only.lean` (header)
  - Predecessor record: `specs/809_realizable_type_adequacy_countdown_profile/reports/01_realizable-type-adequacy.md`, sections 6 and 7
  - Library, read at the named lines: `FormalSystem/Metalogic/Decidability/BiLasso/GoodCycle.lean:100-166` (`untl_propagates_to_end`, `snce_propagates_to_start`), `FormalSystem/PlusLanguage/Subformulas.lean:187` (`plusSubformulaClosure`), `FormalSystem/PlusLanguage/Formula.lean:91-103,137,158` (`PlusFormula`, `neg`, `and`)
  - Guard: `scripts/check-evidence-probes.sh` (header convention, `check_probe`, `WIRED`, the `wired_total` line)
  - Toolchain: `lake env lean` on Lean v4.33.0-rc1, this session; every Lean claim below is a compiled fact of this round's probe or a direct read of the named source line
  - lean-lsp MCP: registered and reported reachable, **not consulted**; the rate-limited search tools were not used (see External Resources)
  - Literature: no literature source is referenced by the task, so the Literature Extraction Protocol is not invoked; the two standard analogues of the construction are named in Findings 8 as orientation only
- **Artifacts**:
  - `specs/815_certificate_sufficiency_dovetailing_realizability/reports/01_certificate-sufficiency-dovetailing.md` (this report)
  - `specs/evidence/seam-gluing-ray-product/certificate-sufficiency-dovetailing.lean` (namespace `Probe815`; the twenty-third probe of the collection; sorry-free; registered in `scripts/check-evidence-probes.sh` as the fortieth `WIRED` entry)
- **Standards**: report-format.md, subagent-return.md, plan-compliance.md (Statement Fidelity), artifact-formats.md, status-markers.md

## Executive Summary

- **(a) The dovetailing argument is a theorem.** `Probe815.exists_dovetail_chain` states it over an
  arbitrary finite graph with no formula, label or object: from any vertex of a finite carrier
  there is an infinite chain along which every eventuality of a finite list carried at any position
  is delivered strictly later under its guard. Its forward instance for the compiled certificate,
  `forward_chain_of_certAdm`, is **forward-only sufficiency** for the certificate as compiled, and
  is labelled forward-only.
- **(c) The full sufficiency claim is REFUTED for the certificate as compiled, and the failure is
  the backward arm alone.** `sufficiency_refuted` is the section-6 claim with its quantifiers as
  stated -- for every object, labelling, formula and candidate set, acceptance implies label-level
  realizability of every member -- and it is false: on a three-state object with
  `phi3 = (⊤ S a1) ∧ (⊤ S a2)`, the certificate accepts `R3 = {x0, x1, x2}` (`cert_accepts_R3`)
  while no bi-infinite `cohR`-chain through `x0` fulfils both `snce` obligations at `x0`
  (`no_bwdFulfilling_through_x0`). The mechanism is exactly the one the compiled certificate's
  header predicted: condition (4) supplies one discharge path per obligation, and with
  `linkPred` constraining no backward arm nothing relates the two paths, so they cannot be taken
  together.
- **The repair is the missing arm and nothing else, and it costs nothing on the fixture.**
  `cohBi` is `coh` plus `linkPredB`, the strict-since unfolding of the later type in terms of the
  earlier one (the mirror of `linkPred`). Under it the certificate IS sufficient:
  `realizes_of_certAdm_cohBi` splices the forward and backward half-chains at `x` and carries each
  obligation across `0` by propagation along the half that does not own it. On a `snce`-free
  closure `cohBi` and `coh` are the same function (`cohBi_eq_coh_of_snce_free`), and the fixture's
  `chi` is `snce`-free, so every theorem and every gate verdict of the compiled certificate probe
  stands verbatim under the strengthened relation.
- **The hypothesis section 6's prose omitted, and section 7 wrongly supplied from the L layer, is
  the ONE-STEP LINK, not the discharge path.** `exists_dovetail_chain` needs, per eventuality, a
  discharge path (conditions (3)/(4)) *and* `LinkStep`: carried at `v` means delivered or carried
  on under the guard at every successor. The link is what carries an obligation picked up at an
  interior position of some other eventuality's discharge path to the next boundary at which its
  own round comes up. `snce_propagates_to_start` has it at the L layer only because
  `LocalCoherentSeq` has a `snce` clause; `linkPred` has it for `untl` only.
- **(b) The length bound is derived, and consumed by nothing.** `eu_mem_lfp_path_le_card`: a
  member of the existential fixpoint has a delivering path of at most `|V|` steps, because the
  iteration is already stable at index `|V|` (`eu_lfp_eq_iter_card`). The dovetailing uses a
  finite path of any length and condition (3)'s decidability is by the iteration, so the bound the
  predecessor called "the obvious one rather than a derived one" was a corollary, and nothing is
  assumed.
- **What sufficiency establishes is LABEL-LEVEL realizability** -- a bi-infinite `cohR`-chain
  fulfilling every `untl`/`snce` obligation at every position, the condition
  `evRay_unfulfilled` negates -- and not semantic realizability through `PlusTruthAt`/`cellAt`.
  No gate verdict is changed; gate 8 stays SIDESTEPPED (the `stab`/`box` clauses are conjuncts of
  the certificate and are consumed by nothing at the label level, which is itself a finding).

## Context & Scope

This round executes the dispatch's three open items against the compiled ground it names as
settled, and re-derives none of that ground: the certificate presentation (`Probe809C`, eighteen
theorems), the universal/existential separation (`au_lfp_ne_eu_lfp_on_exit_graph`), the compiled
adequacy gap (`Probe809.evRay_unfulfilled`), Route B as the chosen route, and closure-indexed
eventual periodicity. Route A is not entered. `ULive`, `SLive`, `Disch`, `DischBwd` are not
transplanted; both arms of every fulfilment condition in this round remain existential.

Scope boundaries honoured and checkable by `git status`: nothing under `FormalSystem/` or `Tests/`
is touched. Three files are written or edited -- this report, one probe under
`specs/evidence/seam-gluing-ray-product/`, and that probe's registration in
`scripts/check-evidence-probes.sh`. No `ladderRealized`, `LadderCons` or `ladderCons_localRun`
under those names or any others, hence no `LadderCons` without the `box`/`stab` clause; no tuple
coordinate; no fixture whose closure has a `stab` member (that is a separate deliverable and gate
8 is not reported as passed); gates 1, 2, 3 and 9 untouched; obligations (b), (c), (d) untouched;
the letter-level `sig.preds` translation of `evRay` not attempted.

The refutation is not followed by a weakened same-named substitute. `sufficiency_refuted` is the
claim as stated; the positive results carry other names and are labelled: `forward_chain_of_certAdm`
(forward-only, compiled relation) and `realizes_of_certAdm_cohBi` (two-sided, strengthened
relation).

## Findings

### Codebase Patterns

#### 1. Verified starting state

Every row was checked this session at the cited declaration or by compiling. Re-check cheaply; do
not re-derive.

| Claim | How it was verified this session |
|---|---|
| `linkPred` constrains the forward-until arm and nothing else; in particular no `snce` arm | `realizable-type-certificate.lean:620-623`, read directly; the `_ => true` fallthrough covers `snce` |
| `untl_propagates_along_coh` is the only propagation theorem in the certificate probe, and its header says no backward mirror is stated and why | `:755-793` and `:63-69`, read directly |
| At the L layer, `snce_propagates_to_start` consumes `LocalCoherentSeq`'s **`snce` clause** -- the `(hco u).2.2.2.2.2` projection -- by leftward `Int.leftInduction` | `BiLasso/GoodCycle.lean:141-166`, read directly; `untl_propagates_to_end` is the same proof on `.2.2.2.2.1` |
| So the 809 report's section-7 sentence "the mirror holds backward through `snce_propagates_to_start`" cites a lemma whose hypothesis the product relation does not satisfy | consequence of the two rows above; compiled as false by this round's `sufficiency_refuted` |
| Condition (3) as compiled is membership in `euLfp R (succR R) _ _`, with no length bound in its statement | `realizable-type-certificate.lean:869-872`, `cert_fwd_iff_eu_lfp` at `:919-924` |
| `euLfp V … = euIter V … (V.card + 1)`, with `eu_exists_stab` giving a stabilization index `≤ V.card` | `:309-336`, read directly; this is what makes the bound derivable |
| `plusSubformulaClosure φ = (PlusFormula.subformulas φ).toFinset` -- subformulas only, no added negations | `Subformulas.lean:187-188` |
| `.and φ ψ = (φ.imp ψ.neg).neg`, `.neg φ = φ.imp .bot` | `Formula.lean:137,158` -- fixes the nine members of `phi3`'s closure |
| The certificate probe compiles in 19 s wall-clock on this machine | `time lake env lean …`, this session (`real 0m19.323s`) |
| The guard tests `git ls-files --error-unmatch` before compiling, so an untracked probe fails as `untracked` and is never compiled | `scripts/check-evidence-probes.sh`, `check_probe`, read directly |
| The research-phase postflight stages only the task directory, and the predecessor round tracked its probe through a dedicated scoped commit | `git-staging-scope.md` `### research`; `git log -- …/realizable-type-adequacy-gap.lean` shows exactly one commit, `76dc24588 task 809: register the adequacy-gap evidence probe`, carrying the probe and the guard edit |

#### 2. What was put on compiled ground this round

`specs/evidence/seam-gluing-ray-product/certificate-sufficiency-dovetailing.lean`, namespace
`Probe815`, 1655 lines. Compiles under `lake env lean` with no errors and no warnings this session
(14.5 s wall-clock on the final file). `#print axioms` on all thirteen printed theorems reports
`[propext, Classical.choice, Quot.sound]`: no `sorryAx`, no `ofReduceBool`. `grep` for `sorry`,
`native_decide`, `maxRecDepth`, `admit` returns nothing. The one `#eval` prints `9`, the closure
cardinality of `phi3`. Registered in `scripts/check-evidence-probes.sh` with a decision-row block
and a `WIRED` entry (the fortieth; with the one-entry `WIRED_REPO` the guard prints a total of 41).

| Declaration | What it establishes |
|---|---|
| `euStep` … `eu_lfp_eq_empty_of_no_event` | the existential fixpoint, ported verbatim from `Probe809C` (probes do not import probes) |
| `eu_lfp_eq_iter_card` | the fixpoint equals the `V.card`-th iterate |
| `eu_iter_path_le` | `eu_iter_path` with the path length recorded: a member of the `k`-th iterate has a delivering path of `≤ k` steps |
| `eu_mem_lfp_path_le_card` | **(b)**: a member of the fixpoint has a guarded delivering path inside `V` of at most `V.card` steps |
| `LinkStep` | the one-step link for one eventuality: carried at `v` means delivered or carried on under the guard at every successor |
| `propagates` | `untl_propagates_along_coh` with the relation abstracted into `LinkStep`, over a chain that need only be a chain up to `n` |
| `Segment`, `DischargedAtBase`, `HasDischargePath` | the shapes the round lemma speaks in; `HasDischargePath` is exactly `eu_mem_lfp_iff_exists_path`'s right-hand side |
| `exists_round` | **one round**: from any `x ∈ V` a positive-length segment inside `V` discharging every eventuality of `L` carried at `x`; induction on `L`, the head's obligation carried to the tail's segment end by `propagates` and discharged from there |
| `baseSeq`, `bnd`, `roundOf`, `chain`, `chain_eq` | the bookkeeping of concatenating rounds: boundary states, boundary positions (`Nat.find` for the round of a position), and the one fact needed -- on `[bnd r, bnd (r+1)]` the chain is the `r`-th segment, endpoint included |
| `exists_dovetail_chain` | **(a), the theorem**: an infinite `succ`-chain inside `V` from `x` along which every eventuality of `L` carried at any position is delivered strictly later under its guard |
| `ClType` … `argOf`, `coh_iff`, `loc_*`, `link_untl` | the product layer, ported verbatim |
| `succR`, `preR`, `cohR`, `certLoc` … `certAdm`, `certAdm_iff` | the certificate, field for field and name for name as compiled, with the relation made a parameter |
| `forward_chain_of_certFwd_rel` | forward sufficiency from conditions (2) and (3) for any relation implying `coh` -- `exists_dovetail_chain` at `succR`, link from `link_untl`, paths from condition (3) |
| `forward_chain_of_certAdm` | **forward-only sufficiency for the compiled certificate**, labelled forward-only |
| `linkPredB`, `snceLink`, `cohBi`, `cohBi_iff`, `link_snce` | the backward arm, the two-arm relation, and the reading lemma mirroring `link_untl` |
| `cohBi_eq_coh_of_snce_free` | **the cost elsewhere**: on a `snce`-free closure `cohBi = coh` as functions |
| `backward_chain_of_certBwd` | backward sufficiency from conditions (2) and (4) over `cohBi` -- `exists_dovetail_chain` at `preR`, link from `link_snce` |
| `IsChain`, `FwdFulfilling`, `BwdFulfilling`, `Realizes` | label-level realizability over `ℤ`, the thing section 6 claims the conditions imply |
| `phi3`, `Q3`, `step3`, `pend3`, `lab3`, `T0`/`T1`/`T2`, `x0`/`x1`/`x2`, `R3` | the refuting fixture |
| `phi3_closure_untl_box_stab_free`, `t0_snce_only`, `t1_snce_free`, `t2_snce_free` | the closure facts, by `decide` on one closure type at a time |
| `certLoc_R3` … `certBox_R3`, `cert_accepts_R3` | **the certificate accepts `R3`**, each condition by hand through `mem_R3`, landed before every negative statement |
| `stuck_x1`, `stuck_x2`, `eq_x1_of_atom1`, `eq_x2_of_atom2` | into the past a chain at `x1` was always at `x1`; only `x1` carries `a1` |
| `no_bwdFulfilling_through_x0` | **the obstruction**: no `cohR coh3 R3`-chain through `x0` is backward-fulfilling |
| `sufficiency_refuted` | **(c), the refutation**: the section-6 claim with its quantifiers as stated is false |
| `coh3_accepts_x1_x0`, `cohBi_rejects_x1_x0` | the exact edge the backward arm forbids: `x1 → x0` is a `coh3`-edge and not a `cohBi`-edge |
| `splice`, `splice_ofNat`, `splice_nonneg`, `splice_negNat`, `splice_neg` | the two-sided chain from a forward and a backward half |
| `realizes_of_certAdm_cohBi` | **(c), the repair**: under `cohBi` every member of an accepted candidate set is label-level realizable inside it |

#### 3. The theorem, and where the link enters

`exists_dovetail_chain` has four hypotheses: the carrier is closed under `succ`; every vertex has a
successor; for every eventuality in `L`, `LinkStep`; for every eventuality in `L` and every vertex
carrying it, `HasDischargePath`. Its conclusion is a total chain `f : ℕ → α` from `x` with
`∀ k, ∀ ψ ∈ L, car ψ (f k) → ∃ j > k, evt ψ (f j) ∧ ∀ r ∈ (k, j), grd ψ (f r)`.

The construction is the report's round-robin, made concrete. `exists_round` builds, for a base
vertex `v`, one segment discharging every eventuality carried **at `v`**; it is an induction on
`L`, and the induction step is where the link enters the first time: the head eventuality `ψ`,
carried at `v`, is propagated along the tail's segment (`propagates`), and is either delivered
inside it or still carried at its end with the guard held throughout -- in which case the head's
own discharge path, from that end, is appended. The assembly then concatenates rounds, base to
base, and the link enters the second time: an obligation at an **interior** position `k` of round
`r` is propagated to the boundary `bnd (r+1)`, where round `r+1`'s segment discharges it; the two
guard ranges abut. Without `LinkStep` neither step is available, and that is the whole reason the
backward arm fails for `coh`: the paths of condition (4) exist, but an obligation at an interior
position of someone else's path has no reason to survive to its own round.

The bookkeeping is deliberately dumb. `bnd` is the running sum of round lengths, `roundOf k` is
`Nat.find` of the first round whose upper boundary exceeds `k`, and `chain_eq` -- the chain
agrees with the `r`-th segment on `[bnd r, bnd (r+1)]`, endpoint included -- is the only fact
the main proof consumes about it. The endpoint case is exactly the next round's base, by
definition of `baseSeq`.

#### 4. The refutation, and why it is minimal

`R3` is built so that the backward arm fails and nothing else can: the closure of `phi3` has no
`untl`, `box` or `stab` member (`phi3_closure_untl_box_stab_free`), so conditions (3), (5) and (6)
are vacuous, and the forward arm is not in play. The object graph is the self-loops plus `1 → 0`
and `2 → 0`, so into the past `1` and `2` are absorbing (`stuck_x1`, `stuck_x2`). Condition (4)
holds at `x0` because `⊤ S a1` has the one-step predecessor path `x0 ← x1` and `⊤ S a2` has
`x0 ← x2`, each inside `R3` (`certBwd_R3`); `x1` and `x2` carry no `snce` member, so condition
(4) is vacuous there. Condition (2) holds by the self-loops and the two edges into `0`. Hence
`cert_accepts_R3`.

The obstruction is then two lines of arithmetic on `ℤ`: backward fulfilment at `0` puts `x1` at
some `j1 < 0` and `x2` at some `j2 < 0` (only `x1` carries `a1`, only `x2` carries `a2`), and
whichever is earlier is, by absorption, at the other's position too -- a contradiction read off
the object coordinate (`congrArg Prod.fst`), never by `decide` on closure types.

The edge the two-arm relation rejects is named: `coh3 x1 x0 = true` although `T1` carries neither
`a2` nor `⊤ S a2`, which `linkPredB` forbids (`cohBi_rejects_x1_x0`). So under `cohBi` the set
`R3` fails condition (2) at `x0` -- as it must, since `realizes_of_certAdm_cohBi` would otherwise
contradict `no_bwdFulfilling_through_x0`.

#### 5. The repair, and its cost

`cohBi step pend lab φ x y := coh step pend lab φ x y && snceLink φ x.2 y.2`, where `snceLink`
checks `linkPredB` at every closure member: for `ψ = snce g e`,
`ψ ∈ T' ↔ e ∈ T ∨ (g ∈ T ∧ ψ ∈ T)`, the later type `T'` unfolded in terms of the earlier `T`.
`link_snce` reads it off exactly as `link_untl` reads `linkPred`.

The positive theorem has three parts, all compiled. `forward_chain_of_certFwd_rel` is the forward
instance for any relation implying `coh` (the hypothesis `hrel`), so it serves `coh` and `cohBi`
alike. `backward_chain_of_certBwd` is the backward instance at `preR (cohBi …) R`, link from
`link_snce`. `realizes_of_certAdm_cohBi` splices: `f z = F z` for `z ≥ 0`, `B (-z)` for `z < 0`;
`IsChain` is immediate from the two halves; an `untl` at `z < 0` is propagated forward along
`B (-z), …, B 0 = x` by `propagates` with the `untl` link, then discharged by `F`; a `snce` at
`z > 0` is propagated backward along `F z, …, F 0 = x` with the `snce` link, then discharged by
`B`; the guard ranges abut at `0`. Both crossings need the arm in question, which is why the
theorem is for `cohBi` and the refutation for `coh`.

The cost elsewhere is stated as a theorem rather than argued. On a `snce`-free closure,
`linkPredB` is `true` at every closure member, so `snceLink` is `true` and `cohBi = coh`
pointwise (`cohBi_eq_coh_of_snce_free`). The fixture's `chi` is `snce`-free by the compiled
certificate probe's `chi_closure_box_snce_stab_free`, so `coh6 = cohBi step5 pend5 lab6 chi` as
functions, and every theorem of that probe -- `cert_accepts_Rchi`, `cert_rejects_Rev`, the
restricted profile's period, the gate-6 separation -- holds under `cohBi` with no re-run. On a
closure that does have `snce` members, `cohBi` is a sub-relation of `coh`, so every negative result
proved through `coh` transfers and no positive one does; no such fixture exists in the collection
yet, so nothing needs re-running today, and the first such fixture is the next deliverable
(Recommendation 3).

#### 6. The bound

`eu_exists_stab` gives a stabilization index `n ≤ V.card`; `eu_iter_stab` then identifies the
`V.card`-th and `(V.card + 1)`-th iterates with the `n`-th (`eu_lfp_eq_iter_card`), and
`eu_iter_path_le` -- `eu_iter_path` re-proved with `n ≤ k` carried through its induction -- gives a
path of at most `V.card` steps from membership in the `V.card`-th iterate
(`eu_mem_lfp_path_le_card`). No theorem of this file or of the certificate probe consumes it. So
the predecessor's phrase "of length at most `|R|`" in condition (3) is a true corollary of the
condition as compiled, not an assumption built into it; a plan may keep or drop the phrase and
nothing changes.

#### 7. What sufficiency does and does not establish

`Realizes rel R x` is: a chain `f : ℤ → ProdState Q φ` with `f 0 = x`, every edge a `cohR rel R`
edge, every `untl` at every position delivered strictly later under its guard, every `snce`
strictly earlier. That is the label-level reading of `PlusTruthAt`'s two temporal clauses -- the
condition `Probe809.evRay_unfulfilled` negates, and the shape of `Fulfilling` and
`PlusThreadFulfilling`. It is what section 6 claimed the conditions imply, and it is what this
round proves (for `cohBi`) and refutes (for `coh`).

Two things it is not, stated so a plan does not inherit them. It is not semantic realizability:
no declaration of the probe mentions `PlusTruthAt`, `tpOf`, `cellAt`, `anchorCells`, a
`WorldHistory`, a world, a model or a cell; the step from a fulfilling label chain to membership
of a type in a cell is standing obligation (d) and the anchor layer's `box_mem_tpOf_iff` /
`stab_mem_tpOf_iff` business, untouched. And it does not consume conditions (5) and (6):
`realizes_of_certAdm_cohBi` projects `certLoc`, `certStab` and `certBox` away in its first line
(`obtain ⟨-, hbi, hfwd, hbwd, -, -⟩`). That is a finding, not an oversight: the `stab`/`box`
biconditionals have no content at the label level, and the place they are consumed is exactly the
semantic step above. Gate 8 therefore stays SIDESTEPPED, and the honest description of what the
certificate's six conditions buy is: (2), (3), (4) buy label-level realizability under `cohBi`;
(1) is implied by (2) through `coh`'s own `locCoh` conjuncts; (5), (6) are carried for the
semantic step and exercised by nothing yet.

#### 8. Analogues, named for orientation only

No literature source is referenced by the task, and none was consulted for the construction. For
the planner's orientation: the round-robin is the standard construction of a *run* through a
quasimodel (Hodkinson–Wolter–Zakharyaschev 2000, Def. 11, in the corpus as
`hodkinson_wolter_zakharyaschev_2000_decidable_fragments_fotl`) and of a chronicle in Burgess
1984 §1 (`burgess_1984`), where the one-step link is a clause of local coherence from the start.
The repository's own L-layer version is `LocalCoherentSeq` with `untl_propagates_to_end` /
`snce_propagates_to_start`. These are analogues, not sources, and nothing in the probe is extracted
from them.

### External Resources

No web search and no external documentation were consulted. The rate-limited Mathlib search
tools (`lean_leansearch`, `lean_loogle`, `lean_leanfinder`, `lean_state_search`,
`lean_hammer_premise`) and `lean_local_search` were not used: every question this round asked was
"does the tree contain X" (`grep` over `FormalSystem/` and the collection answered it) or "does
this compile" (`lake env lean` answered it). The evidence tier for every Lean claim in this
report is therefore a compiled file or a direct read of a named source line, never an index
lookup; per the dispatch's `lean-readiness-context`, no empty-result claim is made at any tier.

Three Mathlib facts were learned by compiling rather than searching and are recorded for the
implementer: `le_or_lt`/`lt_or_le` are `le_or_gt`/`lt_or_ge` at this pin; `List.mem_cons_self`
and `List.not_mem_nil` take their arguments implicitly; `omega` handles `Int.toNat` and `ℕ → ℤ`
casts directly, which is what makes the `ℤ`-splice proofs short.

### Recommendations

Prioritised; owner is the next dispatch on this record unless stated.

1. **Adopt `cohBi` as Route B's relation, by name, in the plan.** It is the compiled relation plus
   the one arm the compiled relation lacks, it is a theorem rather than a reading that the
   fixture's results survive it (`cohBi_eq_coh_of_snce_free` composed with
   `chi_closure_box_snce_stab_free`), and under it sufficiency is compiled. A plan carrying a
   `## Lean Challenge Statements` section should pin `realizes_of_certAdm_cohBi`'s signature and
   `sufficiency_refuted`'s, so that neither can drift into a same-named weaker statement.
2. **Cite this probe for the backward arm; never restate section 7's mirror sentence.** The
   sentence "the mirror holds backward through `snce_propagates_to_start`" is false for `coh` and
   is now compiled as false. The correct sentence is: the mirror holds for `cohBi` through
   `link_snce`, and for `coh` there is a counterexample.
3. **The next fixture is one whose closure carries BOTH an `untl` and a `snce` member**, on which
   the two-arm certificate accepts a non-empty candidate set non-vacuously in both arms. Every
   fixture in the collection exercises at most one arm (`chi`: `untl` only; `phi3`: `snce` only),
   so the two-sided theorem has a compiled instance on neither. This is a non-vacuity obligation,
   separate from the `stab` fixture gate 8 needs, and the two should not be bundled.
4. **State in every downstream artifact that the sufficiency is label-level**, and name the
   semantic step as the remaining adequacy obligation. Findings 7 says what the six conditions buy
   and which two are consumed by nothing at this level. A plan that writes "adequacy discharged"
   without the qualifier would overstate this round by exactly the distance between a label chain
   and a cell.
5. **Keep both arms existential.** `cohBi` adds a one-step Hintikka link, not a liveness
   condition; `ULive`/`SLive` remain the wrong strength (`au_lfp_ne_eu_lfp_on_exit_graph` stands).
   The risk is a reader who sees "backward arm constrained" and reaches for `SLive`.
6. **Upstream the two generic pieces as a move, not a rewrite, in a separate task**: the
   existential fixpoint (`euStep` … `eu_mem_lfp_path_le_card`) at an arbitrary `DecidableEq`
   carrier, and the dovetailing theorem (`LinkStep` … `exists_dovetail_chain`) at an arbitrary
   finite graph. Neither mentions a formula. The natural homes are beside `AUFix` in
   `WitnessFamily/Sharing/Fulfil.lean` and in a new `Decidability/Dovetail.lean`.
7. **Track the probe through the dedicated scoped commit this round makes**, as the predecessor
   did (`76dc24588`): the research-phase postflight stages only the task directory, and the guard
   refuses an untracked probe before compiling it.

## Decisions

1. **Refute, and do not weaken.** The claim under test is section 6's, with its quantifiers as
   stated; `sufficiency_refuted` states exactly that and nothing narrower. The positive theorems
   are given different names and explicit labels (forward-only; two-sided for `cohBi`), per the
   dispatch's Statement Fidelity instruction.
2. **State the dovetailing theorem over an arbitrary finite graph, not over the product.** It
   mentions no formula, so the forward arm of the compiled certificate and the backward arm of the
   strengthened one are both instances at `succR` and `preR`, and the backward instance costs
   forty lines rather than a second proof. This is also what makes the missing hypothesis visible
   as a hypothesis (`LinkStep`) rather than as a step in a prose argument.
3. **Make the certificate's relation a parameter.** The compiled certificate fixes `coh6`; a
   theorem about "the certificate under `cohBi`" needs the fields over a relation. The fields are
   restated name for name so the correspondence is a diff, and the report says plainly that no
   cross-probe equality can be stated.
4. **Repair by strengthening the relation, not by proving a mirror for `coh`.** The dispatch's
   first option. The second (a backward propagation theorem for `coh` on its own terms) is
   foreclosed by the counterexample; the third (report unavailable) is subsumed by refuting and
   repairing.
5. **Define realizability at the label level and say so in the probe's header, in `Realizes`'s
   docstring, and in Findings 7.** The alternative -- leaving "realizability" undefined and
   letting the reader supply the semantic notion -- is how an overstatement would enter.
6. **Compile the refutation on a fixture that isolates one arm.** `phi3`'s closure has no `untl`,
   so conditions (3), (5), (6) are vacuous and the exhibit cannot be read as a forward failure.
7. **No `decide` over a candidate set or a `ClType`; no `native_decide`; no `maxRecDepth`.** The
   compiled certificate probe's discipline, kept verbatim; the obstruction's contradiction is read
   off the object coordinate.
8. **Track the probe now, by a dedicated scoped commit**, following the predecessor's
   `76dc24588`; the guard's `untracked` class makes this a correctness matter, not housekeeping.
9. **Record the predecessor record's section-7 defect in the issue log as `minor`**, not as a
   blocker: it is resolved by the repair, and the log entry exists so a plan does not inherit the
   sentence.

## Risks & Mitigations

- **Risk: `cohBi` is read as "the backward mirror now holds for the compiled relation".** It does
  not; `sufficiency_refuted` is permanent for `coh`. *Mitigation*: the probe's header and
  `cohBi_rejects_x1_x0` name the exact edge the two relations differ on; Recommendation 2.
- **Risk: "sufficiency compiled" is read as semantic adequacy discharged.** *Mitigation*:
  Findings 7 and the probe's first "What this does NOT say" bullet; Recommendation 4; the
  observation that conditions (5), (6) are consumed by nothing at the label level is stated as a
  finding so it cannot be missed.
- **Risk: the two-sided theorem has no non-vacuous compiled instance** -- every fixture exercises
  one arm. *Mitigation*: Recommendation 3 names the fixture as the next deliverable; the
  refutation and the forward instance are each non-vacuous on their own fixture.
- **Risk: the generic certificate drifts from the compiled one.** Probes do not import probes, so
  the fields are restated. *Mitigation*: name-for-name restatement; the report says the
  correspondence is a diff and not a theorem; a plan may add, when the certificate probe is next
  edited, a one-line `rfl`-level remark that its `certAdm` is `Probe815.certAdm lab6 coh6`.
- **Risk: the forward theorem's `hrel` hypothesis is instantiated with a relation that does not
  imply `coh`.** It cannot be -- `hrel` is a hypothesis -- but a reader may think the theorem
  covers arbitrary relations. *Mitigation*: the docstring says "for any relation that implies the
  compiled one".
- **Risk: the guard's printed total is misread.** *Mitigation*: the dispatch's own note is
  repeated here -- `WIRED` has 40 entries after this round, `WIRED_REPO` one, and the guard prints
  41.
- **Risk: the probe is left untracked and the guard goes red as `untracked`.** *Mitigation*:
  Decision 8; the Appendix records the commit.
- **Risk: a seventh mechanism exists that none of this exercises.** The standing lesson binds: a
  gate probing one coordinate certifies one coordinate only; this round changes no gate verdict.

## Tactic Survey Results

Surveyed against this round's probe; all results from this session's compiles. `lean_multi_attempt`
and `lean_hammer_premise` were not used -- every goal was either a `decide` on a concrete fixture,
an `omega` arithmetic obligation, or structural.

| Goal | Tactic | Result | Premises/Config |
|---|---|---|---|
| closure facts on `phi3` (9 members): `phi3_closure_untl_box_stab_free`, `t0_snce_only`, `t1_snce_free`, memberships, `coh3`/`cohBi` edge facts | `decide` | success | `mkT3` as a `filter`; never on a goal over `R3` or `ClType phi3` |
| the six conditions on `R3` | hand proofs through `mem_R3`, `Finset.card_pos.mpr`, `Finset.mem_filter.mpr`, `eu_mem_lfp_iff … .mpr` | success | mirrors `certFwd_Rchi`'s shape at `preR` |
| `ℤ` arithmetic with `Int.toNat` and `ℕ → ℤ` casts throughout `stuck_x1`, `no_bwdFulfilling_through_x0`, `realizes_of_certAdm_cohBi` | `omega` | success | handles `(j2 - j1).toNat`, `(-z).toNat`, `z + ↑(k+1) = z + ↑k + 1` directly; `push_cast; ring` used where the goal is an equation to rewrite with |
| the round-boundary bookkeeping (`roundOf_eq`, `roundOf_spec`) | `Nat.find_eq_iff`, `Nat.find_spec`, `Nat.find_min` + `omega` | success | decidability of `k < bnd (r+1)` is automatic |
| `decide (…) = true` ↔ membership conversions | `simpa [argsOf]` | **fail** (leaves `decide … = true` unreduced) | use `decide_eq_true` / `of_decide_eq_true`, which close by definitional unfolding of `argsOf` |
| `chain_eq`, endpoint case | `simp only [chain, hr, Nat.sub_self, hR0]; rfl` | success after reordering | the rewrite `hb : bnd r + n = bnd (r+1)` must precede the `roundOf` rewrite, not be folded into it |
| `∈ succ (…)` goals under `conv_rhs` | `conv_rhs` | **fail** | `a ∈ s` is `Membership.mem s a`, so `rhs` is the element; use `have e : … := …; rw [e]` instead |
| `isUntl ψ = true → ∃ g e, ψ = .untl g e` | `cases ψ <;> first \| exact ⟨_, _, rfl⟩ \| simp [isUntl] at h` | success | one line, no per-constructor alternatives |
| `splice_negNat`, `n > 0` case | `simp [splice, h]` | **fail** (`simp` rewrites the guard to `n = 0` before using `h`) | `rw [splice, if_neg h]; simp` |
| the whole file | `lake env lean` | success; no errors, no warnings | four cycles from first draft to clean; axioms `[propext, Classical.choice, Quot.sound]` on all thirteen printed theorems |
| any goal | `native_decide` | not attempted, deliberately | would add `ofReduceBool` |

## Context Extension Recommendations

- **Topic**: the one-step link as a hypothesis distinct from the discharge path, in the lean4
  context tree (`context/project/lean4/domain/`, beside the note the predecessor round recommended
  on fulfilment strengths; in the source store per `.claude-extensions.json`'s `source_dir`, never
  in the deployed `.claude/` mirror).
- **Gap**: the predecessor recommended a note on "fulfilment: two strengths, and which one a cell
  needs". This round adds the second thing a plan is most likely to get wrong by default: a
  dovetailing/run construction needs, per eventuality, a *discharge path* **and** a *one-step
  link*, and a relation that has the link for one temporal direction only yields sufficiency for
  that direction only -- with a compiled three-state counterexample for the other. The L-layer
  propagation lemmas carry the link inside `LocalCoherentSeq` and cannot be cited at a layer whose
  relation lacks the clause.
- **Recommendation**: extend the recommended note with a short "one-step link versus discharge
  path" paragraph pointing at `Probe815.LinkStep`, `exists_dovetail_chain` and
  `sufficiency_refuted`, and listing the three Mathlib facts under External Resources (the
  `le_or_gt` rename, the implicit-argument `List.mem_cons_self`, `omega` on `Int.toNat`). Needs
  its own commit outside this repository.
- **Separately**: the deploy-freshness block on this dispatch reports the deployed `.claude/` tree
  STALE for `core`, `lean` and `typst`. Nothing in this round depended on a documented command
  from those extensions; the remedy (`timeout 540 bash .claude/scripts/deploy-headless.sh`) is an
  operator action.

## Appendix

**Probe.** `specs/evidence/seam-gluing-ray-product/certificate-sufficiency-dovetailing.lean`,
namespace `Probe815`, 1655 lines, thirteen `#print axioms` lines. Compile command, as in its header:
`lake env lean specs/evidence/seam-gluing-ray-product/certificate-sufficiency-dovetailing.lean`.
Final clean run this session: 14.5 s wall-clock, no errors, no warnings, one `#eval` output (`9`).

**Registration.** `scripts/check-evidence-probes.sh` gains one boxed decision-row comment block
above the `WIRED` array and one entry at its end,
`"seam-gluing-ray-product/certificate-sufficiency-dovetailing"`. `bash -n` on the edited script
passes. `WIRED` now has 40 entries; with `WIRED_REPO`'s one, the guard prints a total of 41. The
full guard run and the tracking commit are recorded below.

**Guard run.** `bash scripts/check-evidence-probes.sh`, this session, with the probe staged:
`PASS  all 41 wired probe(s) compile`, the new entry's line reading
`seam-gluing-ray-product/certificate-sufficiency-dovetailing    PASS`; 41 `PASS` lines counted;
2m02s wall-clock for the whole collection; exit 0.

**Tracking commit.** `aba02ff69 task 815: register the certificate-sufficiency evidence probe`,
made through `.claude/scripts/git-commit-scoped.sh` with this dispatch's session id, carrying
exactly the probe and `scripts/check-evidence-probes.sh` (2 files, 1690 insertions) -- the
predecessor's `76dc24588` pattern. This report and the task's metadata are left for the
research-phase postflight's own scoped commit.

**Declarations leaned on and not touched.** In the compiled certificate probe: `euStep`, `euIter`,
`euLfp`, `eu_mem_lfp_iff`, `eu_mem_lfp_iff_exists_path`, `eu_lfp_eq_empty_of_no_event`,
`au_lfp_ne_eu_lfp_on_exit_graph`, `coh`, `coh_iff`, `link_untl`, `untl_propagates_along_coh`,
`certAdm`, `cert_fwd_iff_eu_lfp`, `cert_accepts_Rchi`, `cert_rejects_Rev`,
`chi_closure_box_snce_stab_free`, `profR_separates_gate6_pair`. In the adequacy-gap probe:
`evRay_unfulfilled`, `prof6_ev_witness`. In the library: `plusSubformulaClosure`,
`PlusFormula.and`, `PlusFormula.neg`, `LocalCoherentSeq`, `untl_propagates_to_end`,
`snce_propagates_to_start`, `AUFix.*`, `Fulfilling`, `PlusThreadFulfilling`, `ULive`, `SLive`,
`box_mem_tpOf_iff`, `stab_mem_tpOf_iff`, `anchorCells_finite`, `anchorCells_ncard_le`.

**Carried figures.** Every gate verdict reproduced in this report and in the probe's header is
CARRIED from the compiled certificate probe's and the nineteenth probe's headers, read at their
cited paths this session and not re-established by re-running their theorems
[CARRIED-UNVERIFIED: `specs/evidence/seam-gluing-ray-product/realizable-type-certificate.lean`,
header sections "Gate 1" through "Gate 9"; `specs/evidence/seam-gluing-ray-product/nside-modulus-gate.lean`,
Branch N-VERIFIED]. The predecessor's "eighteen theorems" count for the certificate probe is read
from its `#print axioms` block, not re-counted [CARRIED-UNVERIFIED:
`realizable-type-certificate.lean:1309-1326`]. Every figure about this round's own probe was
measured this session.

**Search queries used.** None. `grep -rn "untl_propagates_along_coh\|snce_propagates_to_start"
--include=*.lean` located the three sites named in Findings 1; `grep -n "def plusSubformulaClosure"`
and `grep -n "inductive PlusFormula" -A 12` located the two library definitions.
