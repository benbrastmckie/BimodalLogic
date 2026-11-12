# Roadmap

*Open work only, hand-maintained: batch ordering and the rulings that gate it, nothing else. The
mathematics and the (C)/(S)/(W) verdict table live in
`FormalSystem/Metalogic/Decidability/RaySummary/README.md` (the authority); per-task detail in
`specs/TODO.md`; finished work in `specs/CHANGE_LOG.md` and `specs/archive/`.*

**The aim is completeness and decidability of L⁺**, the stability-modal language: L plus `⊡`.
The repository presents L and L⁺ as its two fronts. L⁺ is the fragment of the Logos theory's
counterfactuals with trivial constitutive antecedents — `□φ` is `⊤ □→ φ` and `⊡φ` is
`¬⊥ □→ φ`, the antecedent verified by every state and by the null state alone respectively — and
`⊡`'s state-locality is the one anchor every decidability engine in this tree rests on.

**L^▷ is a secondary line of investigation, kept and not abandoned** (user ruling, 2026-11-05).
At ZTime and RTime its results arrive from L⁺ by translation; at Base and Dense `▷` says strictly
more and is a research problem of its own, strictly harder than the L⁺ one. Its tasks sit in the
last stage below and are never dispatched ahead of, or batched with, L⁺ critical-path work.

## L^▷: what is landed, and what is parked

L^▷ is a separate inductive embedding L⁺ constructor-to-constructor via `ofPlus`. Landed: the proof system with soundness, conservativity over TM⁺ in both directions and
over TM, and the collapse under `Determined` (856); `⊡φ ↔ ▷◁φ` on every regular frame (833); the
definability split by frame class (854, 859); the conditional transfer corollaries (868). The
ledger of L⁺ headline results against their L^▷ counterparts is 872's report.

The exploration backlog, every row `priority: low`:

| Task | What it investigates | Gate |
|---|---|---|
| 873 | `OpenLanguage/Subformulas.lean` — subformula closure, `Finset`, decidable membership, and `subformulas_ofPlus` | none |
| 874 | `OpenLanguage/Substitution.lean` — `substOpen`, `OpenAxiom.ofTMSubst`, and the direct L→L^▷ embedding | none (856 landed) |
| 875 | incompleteness at Base, through both conservativity directions; the limit-closure schema in `▷`-form at Base/Dense | none (856, 871 landed) |
| 869 | open-modal truth invariance along a ray-agreement lifting | none |
| 876 | **decision record only**: whether `⊡` *could* be removed as an `OpenFormula` primitive, and at what cost. No removal is attempted | none (856 landed) |

**872's six proposals (T1–T6) are not filed.** They stand in its report as the rest of this
backlog; when L^▷ work resumes, T1 (the state-locality fragment) and T3 (non-redundancy of the
new axiom block) are the first two to file.

**Names stay as they are.** The stability-modal language is displayed `L⁺` and the open-modal
language `L^▷`; `OpenFormula`, `OpenAxiom`, `OpenDerivationTree`, `eraseOpen`, `ofPlus` and every
`open`-prefixed declaration keep their Lean names, as does the whole `Plus` family. The
display-name consolidation (877) is abandoned by ruling.

## Rulings in force

Each is a user ruling or a recorded decision an agent may not override. The argument lives in the
cited record, not here.

- **L⁺ is the front; L^▷ is secondary** (2026-11-05). Three grounds, each on record: both L^▷
  gaps reduce to L⁺ (below); the open modals are closed on the decidability front (855); and
  `⊡`, like `□`, is a Logos counterfactual with a trivial constitutive antecedent, where `▷`/`◁`
  need the tensed-antecedent clause. L^▷ tasks are demoted, not abandoned.
- **Decidability before completeness** (2026-11-02). Deciding validity makes the valid set r.e.,
  and Craig then gives a recursive axiomatization. Caveat: Craig buys *an* axiomatization, not a
  natural one. **Sharpened at ZTime (878):** deciding validity makes the valid set **recursive**
  outright, which is directly its own recursive axiom set — Craig is not needed where decidability
  is already in hand. Craig remains the instrument for the weaker r.e.-only case, which is the
  situation at Base, Dense and RTime, where r.e.-ness itself is open.
- **No constructor is added to `PlusFormula`, `PlusAxiom` or `PlusDerivationTree`, and the
  stability-modal language is not renamed in Lean.** Absorb-and-rename is REFUSED: mutating that
  inductive would turn `plus_incomplete_base`, `blc_not_plusDerivable_base` and
  `not_plus_complete_base` into statements about a different language.
- **`⊡` stays primitive in both languages** (2026-11-05). "Definable" means the proved
  biconditional `⊡φ ↔ ▷◁φ` (833) with the primitive retained. Two obstructions to removal are on
  record: the biconditional's `←` half needs `[F.IsRegular]`, so an abbreviation changes `⊡`'s
  truth conditions **off the regular class**; and the decidability front's one working anchor
  for `⊡` is state-locality (`stab_mem_tpOf_iff_cell`, one bit per cell), which `▷`/`◁` do not
  have. 876 is a decision record measuring both, not a removal.
- **`▷`'s definability is SETTLED, and the verdict splits by frame class** (854, then 859).
  - **ZTime/RTime: POSITIVE.** `▷`/`◁` are definable uniformly in their argument — a translation
    `tr` with `OpenTruthAt M τ t φ ↔ PlusTruthAt M τ t (tr φ)` at every model, world and time.
    The paper half is Gabbay separation (GHR Thm 10.2.9 over ℤ, 10.3.20 over Dedekind-complete
    flows), carried by `SeparationOver` and discharged by 867.
  - **Base/Dense: NEGATIVE.** `▷` is a genuine expressive extension, landed as the fourteenth
    numbered Independence result (`Metalogic/Independence/OpenFutureUndefinable.lean`, 33
    declarations, sorry-free). The mechanism, the marker gadget and the one paper step of record
    (GHR Lemma 12.4.2 transposed to `ℚ`) are in 859's report; the reduction theorem that consumes
    it is conditional and says so.
  - **`hinexpr` is deliberately not filed.** Formalizing it would harden an expressiveness record
    whose verdict is already settled, and advances neither front. 859's R3 states its own terms
    if a consumer ever appears.
  - **Spend nothing further on a ℤ-time separation.** `sinkFrame` and every `.ZTime` frame are
    excluded as separators. Any future Base/Dense attempt starts from `colourClock`/`colourFibre`,
    which discharges *Limit* and *Saturation*; the naive permissive ℚ-frame is forbidden.
- **The Stage 1 retarget is answered negatively.** Over ℤ every L^▷ formula *is* a
  stability-language formula under an effective translation, so there is no expressive gain to
  retarget Stage 1 onto. Expressiveness only — no decidability or completeness claim either way.
- **The open modals are closed on the decidability front** (855). The one-sided `▷`/`◁`
  factorization does not crack the transport condition: all six refutation mechanisms survive it,
  two strictly harder. **Two-line test for any successor**: name the half-line the counter is read
  from and the one the formula is read from; if both are "forward",
  `cntAt_eq_of_pend_eq_fwd` plus mechanism 5 already refutes it.
- **No `▷`/`◁` clause is added to `clSig`, `LocalRun` or `Anchored`.** The containment is about the
  Stage 1 engine's own definitions, not about how many L^▷ tasks exist. 873's closure is
  syntactic and no engine consumes it yet.
- **Both L^▷ gaps bottom out in the stability-modal language.** 856 owes L^▷ a proof system, but
  only at Base/Dense where 859 showed `▷` says strictly more; at ZTime/RTime 854's definability
  makes TM⁺ already the proof system through `tr`. Past that, L^▷ completeness reduces to a
  question answered negatively or not at all: TM⁺ is **incomplete** at Base
  (`plus_incomplete_base`) and completeness of any recursive extension is open at every class.
  That question was 865's, discharged as research; **879 carried it and is closed**, its 21-row
  ingredient table reduced to items 8 and 9 (899, 900) with everything else landed or held as
  paper.
- **Gate asymmetry.** `(P1)` gates at Base/Dense/RTime, where its r.e. status is open with a
  located obstruction. At ZTime it is settled affirmatively *on paper*, so `(P2)` is gated on
  `(P0b)` alone, **not** on Stage 1, which adds a constructive settlement there.
- **Stage 1 runs R1 (the gluing route) alone; there is no fallback.** 734 (R2, mosaics) is a
  *consumer* of R1 — deciding mosaics presupposes deciding `⊡`. Nothing on the critical path may
  be gated on it.
- **The MSO/Rabin route reaches ZTime only, and stays a paper result** (866). `▷`/`◁` **do ride**
  step 4's encoding, at the cost of an amendment at step 1. Mathlib has no MSO, no ω-automata and
  no Rabin tree theorem, so step 5 is refused outright rather than deferred. **That refusal is
  carried by the MSO-syntax and Rabin-tree-theorem clauses specifically, not by the ω-automata
  clause** (902): CSLib upstream carries the ω-regular closure lattice including a proved
  `IsRegular.compl`, and the local CSLib fork carries `IsRegular.iff_da_muller` proved in both
  directions, sorry-free and measured clean on this project's own toolchain — while CSLib has
  nothing in MSO syntax and nothing at `S2S`. The acceptance-condition question is **settled as a split** (903): a deterministic Muller
  automaton suffices for the Auxiliary-Atoms rule, which carries no acceptance condition, and
  does **not** suffice for the ban/lull mechanism, whose banned list is indexed by the
  automaton's accepting pairs — so `Muller.toRabin_exists` is load-bearing, and the fork's landed
  `IsRegular.iff_da_muller` is **not** the determinization the architecture consumes
  (`specs/903_muller_sufficiency_for_auxiliary_atoms_rule_ztime/reports/01_muller-sufficiency-aa-rule-ban-lull.md`).
  It does **not** close
  `Decidable (PlusValidZTime φ)` constructively, which is still Stage 1's aim. **878 made the
  paper argument a proof, conditional on (H5)**: both gaps are repaired — G1 by re-justification
  via the compiled `stab_state_only`/`box_global` state-indexed witness closure, G2 by an explicit
  new-root coding with a load-bearing `¬Rt(meet(y,x))` guard on `⊑` — and Rabin's theorem is held
  at `S2S` (Thomas 1997 Thm 6.20, with 6.19/6.18 supplying the effective automaton translation
  and a regular witness), so `SωS` and Gurevich-Shelah are **not needed**. **The citable theorem**:
  `{φ | PlusValidZTime φ}` is decidable
  (`specs/878_lplus_ztime_decidability_paper_proof_repair/reports/01_lplus-ztime-decidability-proof-repair.md`
  finding 7's statement and hypothesis list (H0)-(H6)), a **paper** theorem whose
  **(H5)** is now **fully discharged** — both halves landed: 870's oriented-forest Saturation
  lemma (`saturation_of_orientedForest`) and 897's universal-cover construction, composed with
  `TwoWayBounded.plus_invariance_of_isZTime`. The theorem accordingly stands on (H0)-(H4) and
  (H6) alone. It gives **no** constructive decision procedure, **no** Lean
  `Decidable (PlusValidZTime φ)` (still Stage 1's own aim), **no** elementary complexity bound,
  and **no** finite model property — a *regular*-model property instead (every ZTime-refutable
  formula is refuted on a finitely presented, not finite, doubly serial oriented forest). It is
  the hedge against the Lean engine and runs beside it.
- **No Lean formalization of the Reynolds engine's §§7–15** (901's Recommendation 8). The
  two-sided chronicle, ban preservation, lulls and hue scheduling, universal non-acceptance, the
  two-sided truth lemma and the final-frame assembly stay a **paper** proof. The CSLib `require`
  question is not to be re-opened on their account either; both conclusions are inherited and
  901 strengthens neither direction. What this leaves in Lean is the targets *stated*
  (`LCComplete`, `LCRulesComplete`, `LCURulesComplete` in `Metalogic/LCExtension.lean`, no proof
  and no `sorry`) and the soundness half proved (`ext_sound_ztime`, `ext_sound_validIn`). Filing
  a formalization task for any part of §§7–15 is a ruling violation, not a judgement call.
- **The landed cell schemas bear on the reserved obligation in NEITHER direction**, and may not
  be described as partial progress toward it. This covers the three cell-EQUALITY schemas in
  `LadderCell.lean` and the window-regime cell-INCLUSION schema
  `CellSubsetOfKappaEqWindowRaise` in `LadderWindow.lean` alike. Each is strictly stronger in
  hypotheses than `CellLEZeroConstOfKappaEq` under `ParamsOk`, because each carries an
  existential-over-paths witnessing condition (`ForwardSlackWitnessed`, or
  `WindowIdleRunWitnessed` for the window schema) and its own room bounds.
  `cellLE_zero_const_of_kappa_eq` has **no declaration site** under `FormalSystem/` and nothing
  may land under it until the discharge actually succeeds.
- **The refuted ladder-cell index candidates are not to be re-attempted** (the fourteenth and
  fifteenth wired probes). A clipped-coordinate index, a bounded carrier as a general route, and
  any candidate whose threshold is object-exhibited or whose modulus is not a multiple of every
  letter-definable sub-object's period are each already refuted by a compiled witness. The landed
  window-regime factorization works under the surviving specification, not around it; any
  successor must do the same.
- **Presentation (a) for 761** (819): the set-valued per-state datum in maximum-certified form
  (`D` over `Q × ClType φ × K`, `ladderRealized` the fibre equation). **No tuple index is to be
  stated at any parameters.**
- **Route B, over `cohBi`** (815): the certificate is sufficient at the label level over the
  strict-since relation, both arms existential. The two-sided claim for `coh` is refuted — **no
  backward propagation theorem is ever to be claimed for `coh`**. Route A (generalized-Büchi
  nonemptiness) is not to be entered without a decision record.

## Run these next

```bash
/orchestrate 899,900,905,906 --hard        # the binding front, now that Stage 1's open core is closed and its continuation is a Stage 0 ruling rather than a dispatch. Stage 2's close-out: 899/900 are the LAST two compiled ingredients of 879's table (cut product lemma, linear bridge), 900 edged behind 899 on docs/theorem-index.md; 905/906 are 901's two questions, report only, no Lean and no shared territory
/orchestrate 502,497,500,543 --hard --lit  # the algebraic-representation chain, bottom-up, ending at the one remaining HIGH-priority L-plus metalogic task. 543 is not startable alone: its edge runs 502 -> 497 -> 500 -> 543 and the first three are all low priority, which is why 543 has sat unscheduled
/orchestrate 714,781,873,907               # off both critical paths, all four parallel on disjoint territory: sliced-certificate internals (781 researched), open-language subformula closure, stale deploy-tree redeploy
/todo                                      # 32 terminal tasks read the open count high; CHANGE_LOG's last entry is 2026-10-04
```

**Stage 2's Lean programme is all but exhausted, by ruling and not by exhaustion of effort.**
Every row of 879's 21-row ingredient table is now landed, held as paper, or one of two small
lemmas: items 4, 5 and 6 landed as the cone carrier (`coneFrame`, `exists_coneUnravelling`, the
two-layer *Saturation* split), the formula-level AA⊡ rule with ZTime soundness
(`FormalSystem/Metalogic/AuxiliaryAtoms.lean`: `aa_sound_int`, `aa_sound_ztime`,
`aa_reflectTime_sound_ztime`) and the extended system
(`FormalSystem/Metalogic/LCExtension.lean`: the ten-constructor `ExtDerivation`,
`ext_sound_ztime`, `ext_sound_validIn`, and `LCComplete`/`LCRulesComplete`/`LCURulesComplete`
stated with no proof and no `sorry`). Items 13 and 15 landed as the base-*Saturation*-free
invariance and the universal cover. **Only items 8 and 9 remain — 899 and 900, both small.**
Items 17–21 are paper, and 901's Recommendation 8 is a standing ruling: **do not file a Lean
formalization of any part of its §§7–15**, and do not re-open the CSLib `require` question.
So completeness now has its targets *stated* in Lean for the first time, its soundness half a
theorem, and its proof deliberately on paper.

**The one live external gap on the completeness front is a determinization, not a lemma of
ours.** `Muller.toRabin_exists` (local CSLib fork, `DA/Conversions.lean`) is a `proof_wanted`
and is the single remaining determinization gap; its named consumer is the ban/lull mechanism,
per 903's split verdict. Nothing in this repository is blocked on it, because §§7–15 are not
being formalized.

**(H5) is fully discharged.** 870 landed `saturation_of_orientedForest` and 897 landed the
universal cover, so 878's paper theorem that `{φ | PlusValidZTime φ}` is decidable now stands on
(H0)–(H4) and (H6) alone. It still yields no Lean `Decidable` instance, no complexity bound and
no finite model property — a *regular*-model property instead. It is the hedge beside the engine,
not a substitute for it.

**The Stage 1 chain, bottom-up, is the whole of what remains on the decidability front, and it
still has two independent live links.** `CellLEZeroConstOfKappaEq` under `ParamsOk` gates
`certStabK`, the one `Real` condition of six not claimed; which gates
`real_certAdmK_of_paramsOk` and `real_subset_dmax`; which gate the ladder realization theorem;
which is (W)'s run layer, the lift from one seam to validity; above which sits 763's
`Decidable (PlusValidZTime φ)`, stated nowhere in the tree.

**The collision case split is fully dispatched, and what blocks the bottom link is no longer an
open question in either direction — it is a frontier with a known location.**
`kappa_collision_regimes` has three branches, and three depth-`0` cell-EQUALITY
schemas are landed against them in `LadderCell.lean`:
`cellLE_zero_const_of_kappa_eq_of_forwardSlack` (equal register),
`cellLE_zero_const_of_kappa_eq_commonShift_of_forwardSlack` (common shift, register freed) and
`cellLE_zero_const_of_kappa_eq_monotone_of_forwardSlack` (monotone, carrying neither restriction
and specializing to both the others' hypotheses). Three findings fix where the frontier now sits,
and each is separately owned:

- **The antitone slice is EXCLUDED, not refuted** (916). `kappa_collision_monotone_or_antitone`
  makes the two slices exhaustive with no third case, and
  `kappa_collision_antitone_residue_nonvacuous` inhabits the excluded one at `(4,2)` against
  `(6,0)` inside the pending-forever regime above the threshold. The reason the free-register
  raise stops there is compiled: `free_register_anchor_clause_monotone_required` shows the
  anchor clause's lower bound non-removable, and the clause's two bounds pay for opposite
  directions. The route the slice would need — forward-slack witnessing at the LOWER pair — is
  named and claimed in neither direction.
- **`ForwardSlackWitnessed`'s discharge route is REFUTED at the pin layer**, and the hypothesis
  itself is neither discharged nor refuted. All five schemas still carry it as a hypothesis a
  consumer must supply, so `cellLE_zero_const_of_kappa_eq` still has no declaration site anywhere
  under `FormalSystem/`. What changed is that the route is now closed by a compiled theorem rather
  than merely unproved: `no_deleted_ladderPath_of_straddle_break` (`LadderChain.lean`) shows that
  once the straddling pair breaks at the reduced distance, no deleted ladder path exists at all —
  the primitive's own conclusion is false there. The arithmetic reason is that `cascadeBound`'s
  recurrence `a(k+1) <= 2*a k + J + 1` is attained **with equality** by the saturated
  configuration, so `(K2)`'s budget describes the obstruction rather than dominating it; `hanch`
  falls short by exactly the deleted block's length and `hstraddle` by twice it, measured
  scale-invariantly and preserved under the task's own `evidence/`. The existential-over-paths
  form still survives `ClimbWitness.hasForwardSlack_refuted_unconditional` because it is
  existential, and that asymmetry was the only opening.
- **That opening is now decided POSITIVELY, conditionally, by a different mechanism, and the
  route is LANDED** (924, closed). `hasForwardSlack_of_idleRunRepeat` (`LadderIdle.lean:909`),
  `IdleRunPumpable` (`:992`) and `forwardSlackWitnessed_of_cell_idleRunPumpable` (`:1035`) are in
  the library, each measured `[propext, Classical.choice, Quot.sound]`, and the route-space
  closure is wired as the probe `forward-slack-pin-cascade/route-space-closure` (wired total 55).
  The refutation above closes the *deletion* route and stands unchanged; the route
  that succeeds is the *idle pump*. `forwardSlackWitnessed_of_cell_idleRunPumpable` derives
  `ForwardSlackWitnessed` at **every** amount `l` from one run-local premise — each type in the
  cell realized by a path whose intervening idle run carries an `(objAt, tpOf)`-repeat block —
  built entirely from already-landed machinery (`idleGapLengtheningOfIdleRunRepeat_holds` in
  `LadderIdle.lean` plus `hasForwardSlack_of_next_region_cnt_le`), with no deletion and no
  cascade budget spent. It pays where deletion could not because the regime asks
  `K <= n + c + I - l` against a free bound `K <= n + c + I`: deletion tried to lower `K`, which a
  saturated register has already spent, while the pump manufactures `d*k` units of `I`, and `I` is
  bounded above by no pin obligation (`idleSplice_pins` is unconditional).
  **It is a conditional discharge, not a removal.** The premise is an object/run datum and is
  **not** `ParamsOk`-derivable — `(K1)` names `prodCycleLens`/`objCycleLens`/`satPeriod` and never
  `idleCycleLens` — so the hypothesis stays on all five depth-`0` schemas, which 924 did not edit.
  What changed is that the frontier is **relocated** from an opaque existential over paths at a
  given amount onto a checkable, amount-free condition on one idle run.
  **Consequence to carry**: `certStabK`'s condition must still be RESTATED, not proved, and that
  restatement obligation stays **PROVISIONAL** rather than permanent, for as long as the
  hypothesis is carried.
  **The remaining gap is exactly one named sub-regime, and it is nobody's task.** Paths whose
  intervening idle run has length `1` carry no repeat block, so the pump has nothing to duplicate;
  that is the whole distance between the landed conditional discharge and an unconditional one.
  Discharging it lifts the `certStabK` restatement obligation. The one route that would make
  `IdleRunPumpable` `ParamsOk`-derivable — amending `(K1)` to quantify `idleCycleLens` — is
  **measured at a blast radius of every wired probe** and is deliberately not admitted without
  its own decision. File neither half without reading 924's report first.

**761's blockers are discharged.** 853 closed what its plan still marks `[NOT STARTED]` at
Phases 11.12 and 11.13 (`exists_ladderPath_at_region_of_idle_past` and the unconditional join);
the cell agreement was 916/917's and the ladder-cell index 918's. The index problem was always
genuinely independent of the agreement — the
clipped-coordinate family is refuted at the countdown coordinate by the fourteenth wired probe
(`ladder-cell-index-obstructions.lean`: the region's first idle state sits at distance exactly
`c + 1`, where the countdown's parity is observable), the bounded-carrier alternative is closed
as a general route by the same probe, and the residue-carrying candidate is refuted at both of
its object-exhibited parameters by the fifteenth (`ladder-residue-index-refutation.lean`). What
those refutations buy is a **specification**: any index must have a formula-derived threshold
and a modulus that is a multiple of the period of every letter-definable sub-object.

**The index is now settled for one regime, one-directionally, and the other direction is CLOSED
rather than open.** The positive factorization is landed for the ordinary window regime
`c <= n + 1` in `RaySummary/LadderWindow.lean` as `CellSubsetOfKappaEqWindowRaise`, proved by
`cellSubset_of_kappa_eq_window_raise`, with `kappa_collision_window_or_pendPast_exhaustive`
giving the regimes' exhaustiveness at a fixed register. It concludes cell **inclusion**, not
equality, and holds **upward only**; its carried condition `WindowIdleRunWitnessed` is
existential over paths in the same shape `ForwardSlackWitnessed` already uses.
**Do not re-attempt the lowering primitive as stated.** It is excluded on a compiled
measurement: the anchor clause reverses direction under deletion and needs a sixth carried
hypothesis bounding the register from above (`nxtAt g z + jP <= cntAt g z + 2*d + 1`), which the
collision's lowering branch does not supply and the path's own bound is short of by exactly the
displacement. Landed as `window_lower_anchor_of_required`, `window_lower_anchor_not_implied` and
`window_lower_anchor_fails_at_tight_bound`. Admitting that sixth hypothesis to buy a
two-directional schema is a standing open **choice**, deliberately recorded rather than taken.
`cellLE_zero_const_of_kappa_eq` still has **no declaration site** under `FormalSystem/`.

Resuming 761 re-imposes serialization on everything sharing the `RaySummary` library set,
`docs/theorem-index.md`, `scripts/check-module-invariants.sh`,
`specs/evidence/seam-gluing-ray-product/`, `specs/state.json` and `specs/TODO.md`. 862, 861 and
763 all sit behind it, and as of 924/925's close nothing else holds that territory.

**A gap that is nobody's task and should be decided before 763 is attempted.** Requirement (S)
is discharged only for `box`/`stab`-free `φ` at ONE seam (`presented_modelOf`,
`hitCl_modelOf_eq_hitOf`). `box`/`stab`-bearing `φ` and every other seam are open, and
`Decidable (PlusValidZTime φ)` needs (C), (S) and (W) together. (C) is settled in general
(`exists_hitPresented`). (W) is what 916, 917, 918 and 924 attacked, and all four are now closed,
so no live task touches it either; (S)'s remaining scope is assigned to (W) in
`RaySummary/README.md`'s own accounting, but no filed task carries it. Either confirm that
assignment is sufficient or file the extension — do not discover this at 763. With the whole
916/917/918/924/925 wave terminal, this is the LARGEST unowned item on the decidability front.

**The 838 chain is spent and closed, and re-planning the area from its two-sided framing is
barred.** What it settled: the restricted obligation
`cellLE_zero_const_of_kappa_eq_of_forwardSlack` landed as a theorem concluding cell equality, and
two decision gates returned compiled FAIL verdicts — the spanning-block device both ways, and the
unrestricted idle-gap lengthening, refuted one level below the pin condition by `step` itself.

**The idle-cycle sharpening is the one piece of that chain the live front still consumes.** Where
the object's idle states carry a reachable cycle, the lengthening IS available
(`idleGapLengtheningOfIdleRunRepeat_holds`, `LadderIdle.lean`), and the pin condition does not
merely loosen but **discharges outright** for an idle block. The freed-increment form is refuted
alongside it (`idleGapLengtheningAllIncrements_refuted`), so the run-local restriction is
necessary and not an artifact of the proof. This lemma is what 924's idle pump is built from.
**Coverage appendix (uncovered tasks)**:
```
/orchestrate 178,570,604,664,743,817,818,821
/orchestrate 829,830,831,832,890
```

## Next batches

```bash
# Stage 1 — decidability of L⁺ at ZTime. NO DISPATCHABLE LINE REMAINS: 908, 916, 917, 918, 924
#   and 925 are all CLOSED, and every successor sits behind 761's hold, which only a user ruling
#   lifts (Stage 0, first item). The I = 1 sub-regime that 924 relocated the frontier onto is
#   nobody's task and is not to be filed without reading 924's report.
/orchestrate 862,861 --hard --lit        # the first line that becomes live the moment 761 is lifted: 862 is the forward pend/countdown rigidity sharpening (researched) feeding the same cell-level arithmetic, 861 the one-sided refutation table row (researched), which also waits on 763. Both are gated on 761 alone now that its substantive lift conditions are discharged
/orchestrate 763 --hard --lit            # the lift and the Decidable (PlusValidZTime φ) corollary — needs 761 resumed AND the chain above closed. Settle the (S) scope question first; it is still nobody's task
/orchestrate 714,781,873,907             # sliced-certificate internals (781 researched), open-language subformula closure, stale deploy-tree redeploy. All four parallel on disjoint territory; 873's docs/theorem-index.md row is why it is not batched with 899/900
# Stage 2 — completeness of L⁺ at ZTime: TM⁺ plus the until-form schema
/orchestrate 899,900,905,906 --hard      # P7/P8, the LAST two compiled ingredients of 879's table: the cut product lemma and the linear bridge, 900 edged behind 899 on docs/theorem-index.md. Batched with 901's two report-only questions, which collide with nothing
/orchestrate 502,497,500,543 --hard --lit # MF correspondence rigidity, the only remaining high-priority L⁺ metalogic task — reachable ONLY through its own edge chain 502 -> 497 -> 500 -> 543. All three predecessors are low priority, which is why 543 never got scheduled on its own
# Stage 2b — supporting semantics and metalogic
/orchestrate 664,570 --lit               # corpus ingest and the C3 open question
/orchestrate 830 --hard                  # Γ-generalize decidableValidZTime; does NOT advance either aim
# Stage 3 — hygiene, build cost, datasets, docs. Off both critical paths
/orchestrate 803,804,829                 # build-cost front: SubformulaProperty elaboration (research + plan landed), fan-in, .lake/build CI cache
/orchestrate 298,282,296,231             # the dataset chain behind the c7 labeling bug (298/282/296 partial)
/orchestrate 178,604,743                 # worked Examples/ pipeline, zstd .jsonl, typst-sync namespace resolution
/orchestrate 817,818,821                 # phantom-row inventory, directory-rollup tables (821 researched)
/orchestrate 787,832                     # unguarded .lake reader audit; local-disk reclamation (user decision on data/'s .partial files)
/orchestrate 890                         # GHR Lemma 10.2.3 case 5 erratum reference
/orchestrate 257                         # only once the Stage 0 token exists
# Stage 4 — the long fronts, off both critical paths
/orchestrate 481 --hard                  # the refuted predicate; a C9 register entry is a complete outcome
/orchestrate 831 --research --lit        # off-spine: the Log(all) = Log(ZTime) ∩ Log(Dense) dichotomy
/orchestrate 428,429,410,411 --hard      # the tableau spine's middle — needs 428's scope ruled; 410 planned
/orchestrate 430,412,482 --hard --lit    # the spine's terminus
/orchestrate 502,497 --research --lit    # the STSA literature gate, then the G-operator gap
/orchestrate 498,499,500 --hard          # the representation's two sides and their reconciliation
/orchestrate 125,501 --hard              # the Jónsson–Tarski capstone and Until/Since on STSA (543 moved to Stage 2, where its consumer is)
/orchestrate 177                         # last in the programme: README, docs/ and docstring polish
# Stage 5 — L^▷ exploration. Secondary, priority low; never ahead of, or batched with, Stages 1–2
#   What each one investigates and its gate: the backlog table under "L^▷: what is landed, and what is parked"
#   873 is not repeated here: it is already dispatched in Stage 1's four-way parallel line above,
#   and 874/875/876 all carry a 873 edge, so they stay behind it
/orchestrate 874
/orchestrate 875
/orchestrate 869
/orchestrate 876
```

Each line is one invocation. Batches are dependency-inclusive — the engine re-derives eligibility
every cycle, so a batch holding a blocker and its dependent is correct, and one holding a
dependent *without* its out-of-batch blocker is dead weight. `MAX_TASKS` is 8; the work-cycle
budget is per task, per invocation (5 default, 13 under `--hard`), so **re-run the same line until
every member reports terminal**. Shared file scope serializes a batch rather than breaking it; a
task with no declared `file_scope` is invisible to the overlap gate, and no open task
remediates that blindness. A cross-batch collision against a **live** session's lock is not bypassable by
`--allow-scope-collision`, which clears only the plan-level gate: wait for the holder, or batch
with it. See `.claude/context/patterns/batch-orchestration-guardrails.md`.

## Stage 0 — User rulings (no agent may transition these)

- [ ] **Decide whether 761 comes off `[HOLD]` — THE RECOMMENDED CONDITION IS NOW MET, and this is
      the only thing standing between Stage 1 and a dispatchable line.** Both substantive reasons
      for waiting were already discharged (853 closed the Phase 11.12/11.13 gap; 916/917/918
      reported on the cell agreement and the ladder-cell index), and the cost reason is spent too:
      the recommendation was to lift it once 924 and 925 reported terminal, and both are now
      `[COMPLETED]`, so nothing else currently holds the `RaySummary` and generated-surface
      territory 761 would re-serialize. Lifting it unblocks 862, 861 and 763 at once. An operator
      lifts a hold via `update-task-status.sh preflight 761 ... unhold`; an
      `/orchestrate 761 --implement` override admits it for one dispatch and preserves the hold
- [ ] Supply the Hugging Face account and token **257** is blocked on
- [ ] Rule on **428**'s scope. Its one edge is discharged and its `blockers` says "paused at
      4/5 cycles, NOT blocked", so the marker is mis-set: `/revise 428` to add phases for its four
      residual hypotheses, or `/spawn 428` to split them out

**713** is held by ruling (2026-10-03): its argued CTL⋆ 2EXPTIME lower bound is a citable ceiling
with no consumer. **734** is `[HOLD]` on the paywalled *Handbook of Modal Logic* ch. 11
§§5.10–5.11 (Hodkinson & Reynolds, pp. 655–720), absent from the local Zotero library;
reactivation condition `specs/literature-index.json#hodkinson_2006.hazard`. Acquiring it lifts a
hold, not the aim.

## Not batched, and why

- **713**, **734** are `HOLD` by ruling, **761** by the Stage 0 item above. 761's two blockers are
  now both discharged — the cell agreement by 916/917, the ladder-cell index by 918 — and the
  serialization cost that kept the hold in force past that is spent as well, since 924 and 925
  are closed and no live task holds the `RaySummary` territory. The hold now rests on nothing but
  the absent ruling.
- **No agent-system work is filed in this repository, and none is to be.** Every `task_type: meta`
  record has been migrated out to the repository that owns the shared source store, including the
  three plan-authoring/gate-collision successors most recently filed here. This repository's
  `.claude-extensions.json` does not declare a reachable `source_dir`, so a record whose edit
  target resolves only under the source store cannot be executed from here. Re-filing one is a
  ruling violation, not a judgement call.
- **The blocker-research aux chain is a dead drop with no receipt** — `orchestrate-cycle-plan.sh`
  clears `aux_pending[t]` at emission time, so a fork that never writes `.blocker-research.json`
  emits no `plan-revision` row, `MAX_BLOCKER_ESCALATIONS` never fires, and an `[IMPLEMENTING]`
  task falls back into the known-blocked phase. This is the mechanism behind 761's repeated
  re-entries. Recorded here because no open task owns it.

**Reading the coverage appendix.** It lists *ready* tasks absent from **`## Run these next`**
alone — never computed from `## Next batches` or this section. A Stage 1 task deliberately kept
out of the immediate run list appears there correctly; its presence is not a gap.

## Do not re-attempt

- **Four tuple-shaped index shapes for `ladderRealized` are refuted on compiled ground**
  (`ladder-cell-refutation`, `ladder-cell-index-obstructions`, `ladder-residue-index-refutation`,
  `ladder-joint-index-refutation`). The tuple-widening line is spent; **no seventh coordinate is
  to be proposed.**
- **The pointwise transport line is spent too, one-sided forms included** — see the 855 ruling
  above and its two-line half-line test before proposing any successor.
- **A ▷-specific elimination avoiding full separation is refuted** (859's R3b). At `.Base`/`.Dense`
  there is no elimination to find; at ZTime/RTime 854 already has one.
- **Gate 8 is sidestepped, not passed** — the `stab`/`box` clauses are present but unexercised.
- **`HasForwardSlack` is a genuine regime, not a missing lemma.** The upper residual inequality is
  refuted by a climbing-register ladder path (`ClimbWitness` in `LadderChain.lean`); there is no
  Drift-level invariant to isolate, and `hasForwardSlack_refuted_unconditional` refutes the
  per-path state-level regime outright. **Do not re-attempt route (a).** The surviving form is
  `ForwardSlackWitnessed` (`LadderCell.lean`) — an existential over paths, which is exactly why
  it escapes that refutation. The gap to `CellLEZeroConstOfKappaEq` is **no longer the tight
  (doubling) chain of pins**: the register-lowering deletion and the free-register raise are both
  landed. The antitone collision slice is settled (excluded, not refuted), and the question of
  whether the existential-over-paths form admits any route at all is **answered affirmatively**:
  the idle pump avoids the doubling cascade entirely (see the collision case-split section above).
  What remains is landing it, and the `I = 1` sub-regime it does not reach.
- **The plan-specified spine for the register-lowering deletion is not implementable, and the
  landed route is not to be "corrected" back to it.** `exists_deleted_ladderPath_overshoot_of_pend_past`
  pins its slack amount to the shape `R*l + budget*l` at the held register in hypothesis *and*
  conclusion, so the extra displacement a lowered anchor needs is destroyed by the loop and
  cannot be recovered — slack transport is exact in both directions, monotonicity runs the wrong
  way in both arguments, and the increment folds into the loop's shape only when the step
  divides it. The landed route lowers the register *before* the surgery via
  `exists_ladderPath_of_walk_nxt_at` on the path's own walk and countdown, then applies the
  held-register theorem as a black box. Generalizing that loop to a free slack amount is a
  recorded option, needed by nothing landed.
- **The idle-gap lengthening's freed-increment form is refuted**
  (`idleGapLengtheningAllIncrements_refuted`, `LadderIdle.lean`): idle states with a 2-cycle and
  no self-loop admit only even-length runs. The run-local restriction — a block of the idle run
  whose two ends carry the same object state — is **necessary**, not an artifact of the proof, and
  under it the pin condition **discharges outright** rather than merely loosening
  (`idleSplice_pins` carries only `IsLadderPath`, positivity and the block's idleness). Do not
  re-propose the unrestricted form.
- **`spliceCnt` does not transfer to an idle block.** Its region-raise clause fires vacuously at
  an in-block position and returns the step where zero is forced, which is why `idleSpliceCnt` is
  a separate definition. Do not attempt to reuse `spliceCnt` there.
- **The unconditional `buildTableau_isSome` is FALSE by construction** at the engine's
  `maxBranches := 50000` guard, at any fuel. The whole decidable-branch-gate family collapses to
  `false` on any branch that mints a world, so 429 is a redesign, not a repair.
- **ℤ-time validity of L is already decided** (`Compression.decidableValidZTime`), so the
  deliverable is the four-class `isValid` biconditional, not a first decidability theorem.
- **481's obstruction is precise**: `universeClosedAt_signedUniverse_of_propositional` is not
  stateable, because `UniverseClosedAt`'s clause 1 universally quantifies an unconstrained `ord`
  while every route through the time coordinate carries `OrdTimesKnown b ord`, non-removable
  in-source. **482 must re-verify its own anchors first**: `Verified/Refutation/` does not exist
  and `ProofExtraction.lean` holds no verifier declaration.
- **The MSO decidability formalization is refused outright, not deferred** (866's R2, 865's R4),
  **unchanged by 878's repair and not resting on it**. The refusal rests on Mathlib's inventory —
  no MSO syntax, no ω-automata, no determinization of ω-automata, no Rabin tree theorem (866
  finding 8, held) — not on gap G1. **Two of those four grounds are true of Mathlib but false of
  the reachable Lean ecosystem** (902, re-verified against `.lake/packages/mathlib` at
  `79d0395a`): ω-automata and determinization of ω-automata are landed in CSLib — the closure
  lattice with complementation upstream, McNaughton determinization to Muller in the local fork —
  so the refusal now rests on the MSO-syntax and Rabin-tree-theorem clauses alone, neither of
  which CSLib has in any form. 878 discharged the precondition this entry previously stated
  (gap G1 in report 03 §1.3 needed a paper repair); the refusal itself stands on its own grounds
  regardless.
- On any `C16` unused-binder red, prefer the signature edit to a `scripts/nolints.json` entry,
  check call sites first, and **do not run `lake exe runLinter --update`**.
- **A verification claim is only as wide as the flags it was made under.**
  `check-module-invariants.sh --emit-inventory --check` exits 0 while the bare invocation exits 1;
  prefer the bare form whenever the question is "is the tree green". The warning budget's counts
  are a ceiling that may only decrease — never reach for `--update`.
- **The bare gate is GREEN, and the one standing exception is closed.** The `FAIL C16`
  (env_linter `unusedArguments`) at `RaySummary/LadderPump.lean` is cleared by two different
  dispositions — `exists_idleSpliced_ladderPath` GENERALIZED (both dead instance binders deleted,
  so it now holds at an arbitrary `Q : Type`), `exists_idleTypeBlock_of_budget_le_run` kept with
  an in-source `@[nolint unusedArguments]` and a reasoned `scripts/nolint-attribute-allowlist.txt`
  entry, because its unused argument is an EXPLICIT hypothesis whose deletion would relocate the
  obligation onto every consumer. The bare invocation ends `ALL CHECKS PASSED` (925, then
  independently 924's full gate run). A phase may therefore hold itself to "gate exits 0" again —
  but still read the per-check `PASS`/`FAIL` lines when a run is scoped, since
  `--no-build` skips the whole `env_linter` batch and cannot witness C16 either way.
- **A probe is only measured once it is tracked.** `check_probe` tests
  `git ls-files --error-unmatch` *after* its presence test, so a new probe must be `git add`-ed in
  the same round or the gate reports `FAIL (untracked: ...)`. Probes compile outside the Lake
  module graph, so **no probe can import another** — shared objects are re-derived verbatim.

## Cross-stage sequencing

- **559 is a TM⁺ task, not TM⋆** (its directory name is a legacy misnomer). `(P0a)` is 833,
  **landed**; `(P0b)` is 854+859, **closed both ways**, so (n1)–(n2) survive at ZTime only as
  restatements — (n2)'s rigidity schema `▷ψ⁻ ↔ ψ⁻` is `ofutP_of_pastDet`, its companion is
  `ofutP_of_futDet` — while (n3) is answered negatively at Base/Dense. `(P0c)` is unaffected
  (invariance, not definability). `(P0d)` (`LC_n` in `▷`-form at ZTime) is a stability-language
  question by `openValidIn_ztime_iff_tr`; at Base/Dense it is 875's.
- **559 is not to build the proof system** — its own constraints forbid changes under
  `FormalSystem/`. That is 856. Its three acceptance baselines are 559's: soundness over the
  class, conservativity over TM⁺ in both directions, and collapse under `Determined`. No
  completeness statement about L^▷ is stateable until it lands.
- **Do not open `(P2)` while 761 is live** — coordination, not the gate: `(P2)` and the
  certificate line's agreement lemma target the same mathematics from two directions. Whichever
  front reaches it first states it in reusable form and the other cites it.
- **The binding obstruction on the completeness front is closedness of the canonical bundle**
  (559 item (c)), not `(P1)`. PS/US give paste-closure, MF translation-closure, and nothing gives
  closedness. The cure of record is the until-form `LCU` and its mirror plus the Reynolds
  automaton-and-ban machinery (Reynolds 2001 §11–§13), per 879's report finding 2.3; `LC_n`'s
  role in a language with `untl`/`snce` primitive is open (879's Q1, now owned by 906).
  **Both halves of that cure are now in hand on their own terms** — `LCU` and its mirror are
  declared and ZTime-valid (`lcU`, `lcU_plusValidZTime`, `lcU_reflectTime_plusValidZTime`), and
  the ban/lull machinery is written out as a paper proof — **and the obstruction is still not
  discharged**, because the ruling above keeps §§7–15 out of Lean. Closedness is therefore the
  front's standing open problem, owned by no task and not to be filed as one without a fresh
  user ruling that reverses 901's Recommendation 8.
- **R3, the doubled AA⊡ rule, is answered by what landed rather than by a task of its own.** The
  chain 894 → 895 → 896 is `[COMPLETED]`: the cone carrier discharged the Auxiliary-Atoms
  carrier's *Saturation* obligation on 870's lemma (the blocker `NamingRules.lean` recorded is
  closed, and that docstring's "left open" assertion is retired); 895 landed the formula-level
  rule forward and mirror with ZTime soundness; 896 landed the extended system. A separate R3
  filing would duplicate `aa_sound_ztime`/`aa_reflectTime_sound_ztime` and is not to be made.
- **The one invisible collision across Stages 2 and 5** is the one-line import in
  `FormalSystem/Semantics/Presheaf.lean`, which no task declares. Batch only tasks already
  serialized by a dependency edge, and re-run `lake build` after each aggregator edit.
- **803/804** both touch `Verified/Termination/SubformulaProperty.lean` and serialize inside one
  batch — the repository's largest rebuild cost (1103s on a full guarded build). Research and a
  9-phase plan are landed: the module's own inline diagnosis is wrong, the cost is the
  `simp_all` cascade rather than `unfold applyRule`, and the remedy is the pre-generated
  `applyRule.eq_N` equation lemmas (measured 32×–14,278× per theorem). 829 is a different lever
  and does not serialize with them.
- **Stage 4**: 411, 412 and every algebraic task declare an empty or absent `file_scope` — scope
  them at plan time before running any wave concurrently. The spine's head is clear (428's one
  edge is discharged); it starts at its Stage 0 scope ruling.

## Not scoped as tasks

**Strong completeness over ℚ-time**: weak completeness is done (`derivable_of_validQTime`), but
compactness goes through ultrapowers of ℚ, which are dense yet no longer ℚ-time — Cantor gives an
order isomorphism, not a group one. Unlike Discrete and Dedekind it is not known to be impossible.
**Genuine `Set Formula` strong completeness** for Base and Dense: its gate, the shift-set
representation theorem, is passed, but the ultraproduct work behind it is unfiled.
**Formalizing 859's collapse step** (GHR Lemma 12.4.2 over `ℚ`) would discharge the hypothesis
`ofut_not_plusDefinable_of_deltaProp_inexpressible` carries; the frame to build it on is
`colourFibre`.

`app:gluing` is live in `~/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex` and proved in
full generality (`FormalSystem/Semantics/Gluing.lean`). `app:Structure` and
`app:presheaf-dictionary` are **cut** — treat a cut clause as a specification to implement, never
as a theorem to cite.

## Maintenance

Hand-curated: completed items are removed by hand when a stage is revised; the durable record is
`specs/CHANGE_LOG.md` and `specs/archive/`. Update the batches when `/task --expand`, `/spawn` or
a dependency change alters the graph, and treat any claim here that no check can reproduce as a
defect in this file rather than a fact about the tree.

`roadmap-integration.sh --regenerate` is safe against this file: it retains every `## ` section
byte-for-byte **except** the run-order section (`## Run these next` — the first holding a fenced
`/orchestrate` block), whose body it round-trips, stripping the generated coverage appendix and
appending a fresh one. `/orchestrate`'s conclusion stage runs it as a mandated step, so do not
delete the appended block by hand.

**THE ONE WAY TO LOSE AUTHORED WORK HERE.** `strip_coverage_appendix` stops reading at the
`**Coverage appendix (uncovered tasks)**:` marker and discards everything after it *within the
run-order section*. Keep authored content above that marker, and leave the appendix last in its
section.

`--prune` reaches only the run-order section and drops terminal tasks from run lines; it is kept
out of unattended runs because it removes content outright. The decidability inventory (PROVED /
NOT ESTABLISHED / WITHDRAWN / REFUTED) is regenerated and diffed from the tree by
`scripts/generate-decidability-inventory.sh --diff`.

## Related

- `.claude/context/patterns/batch-orchestration-guardrails.md` — batching and contention model
- `specs/TODO.md` — task records, Task Order and dependency waves
- `specs/literature/README.md` — the corpus and the L⁺ literature position
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` — the (C)/(S)/(W) verdict table and every guardrail
- `FormalSystem/Metalogic/Independence/README.md` — the fourteen underivability and undefinability results
- `FormalSystem/OpenLanguage/README.md` — the paper-label correspondence table for `▷`/`◁`
- `README.md` — the BX axiom layers, the irreflexive semantics and the architecture
