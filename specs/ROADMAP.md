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

## Where both fronts now stand

**Stage 1 has a short dispatchable Lean line again; Stage 2 has none.** This is the governing
fact about the current state of the tree, and it is the product of rulings and closed
programmes rather than of unfinished dispatches.

- **Decidability (Stage 1).** 761's hold is **LIFTED** (2026-11-12) and the `hself` disposition is
  **RULED (B), rename to auxiliaries** (2026-11-13, Stage 0 below), so Phases 11.16 and 11.17 are
  now enterable — roughly 2.5 hours of work that closes the idle-insertion cascade's record.
  Everything beyond them, fourteen phases and five of the task's six filed Goals, stays behind
  Phase 11.6's depth-`0` gate, which **no open task owns**. The crux that would decide that gate is
  named in Stage 0 and in `RaySummary/README.md`: whether `ForwardSlackWitnessed` at a POSITIVE
  amount is satisfiable at any state the depth-`0` induction reaches.
- **Completeness (Stage 2).** The Lean programme is **exhausted by ruling, not by exhaustion of
  effort**: every row of 879's 21-row ingredient table is landed, held as paper, or closed, and
  901's Recommendation 8 bars filing a Lean formalization of the Reynolds engine's §§7–15.
- **What remains dispatchable** is the algebraic-representation chain (the only route to the last
  high-priority L⁺ metalogic task), off-critical-path hygiene, build cost, datasets and docs, and
  the L^▷ exploration backlog.

**One item on the critical path is owned by no task**: closedness of the canonical bundle, listed
under "Not batched" below rather than batched, and unfiled by deliberate ruling. The other two this
line used to name are discharged (2026-11-14 rulings, Stage 0): requirement (S)'s residue is
CONFIRMED sufficient as assigned to (W) and reduces to the single named theorem `real_certStabK`,
and the depth-`0` gate's crux is owned by task 934. The `I = 1` idle-run sub-regime was filed as
929 and completed 2026-11-13.

## L^▷: what is landed, and what is parked

L^▷ is a separate inductive embedding L⁺ constructor-to-constructor via `ofPlus`, with its proof
system, both conservativity directions, the `Determined` collapse, `⊡φ ↔ ▷◁φ` on every regular
frame, and the definability split by frame class all in the tree. The ledger of L⁺ headline
results against their L^▷ counterparts is 872's report.

The exploration backlog, every row `priority: low`. 869 heads the line and gates 873, which gates the rest:

| Task | What it investigates | Gate |
|---|---|---|
| 869 | open-modal truth invariance along a ray-agreement lifting; shares `OpenLanguage.lean` and `docs/theorem-index.md` with 873, so it runs ahead of it | 743 |
| 873 | `OpenLanguage/Subformulas.lean` — subformula closure, `Finset`, decidable membership, and `subformulas_ofPlus` | 869 |
| 874 | `OpenLanguage/Substitution.lean` — `substOpen`, `OpenAxiom.ofTMSubst`, and the direct L→L^▷ embedding | 873 |
| 875 | incompleteness at Base, through both conservativity directions; the limit-closure schema in `▷`-form at Base/Dense | 873 |
| 876 | **decision record only**: whether `⊡` *could* be removed as an `OpenFormula` primitive, and at what cost. No removal is attempted | 873 |

**872's six proposals (T1–T6) are not filed.** They stand in its report as the rest of this
backlog; when L^▷ work resumes, T1 (the state-locality fragment) and T3 (non-redundancy of the
new axiom block) are the first two to file.

**Names stay as they are.** The stability-modal language is displayed `L⁺` and the open-modal
language `L^▷`; `OpenFormula`, `OpenAxiom`, `OpenDerivationTree`, `eraseOpen`, `ofPlus` and every
`open`-prefixed declaration keep their Lean names, as does the whole `Plus` family. The
display-name consolidation is abandoned by ruling.

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
    flows), carried by `SeparationOver`.
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
  nothing in MSO syntax and nothing at `S2S`. The acceptance-condition question is **settled as a
  split** (903): a deterministic Muller automaton suffices for the Auxiliary-Atoms rule, which
  carries no acceptance condition, and does **not** suffice for the ban/lull mechanism, whose
  banned list is indexed by the automaton's accepting pairs — so `Muller.toRabin_exists` is
  load-bearing, and the fork's landed `IsRegular.iff_da_muller` is **not** the determinization the
  architecture consumes
  (`specs/archive/903_muller_sufficiency_for_auxiliary_atoms_rule_ztime/reports/01_muller-sufficiency-aa-rule-ban-lull.md`).
- **The citable ZTime decidability theorem is paper, and complete on its own hypotheses.**
  `{φ | PlusValidZTime φ}` is decidable
  (`specs/archive/878_lplus_ztime_decidability_paper_proof_repair/reports/01_lplus-ztime-decidability-proof-repair.md`
  finding 7, hypotheses (H0)–(H6)), with **(H5) fully discharged** — 870's oriented-forest
  Saturation lemma (`saturation_of_orientedForest`) and 897's universal cover, composed with
  `TwoWayBounded.plus_invariance_of_isZTime`. Rabin's theorem is held at `S2S` (Thomas 1997
  Thm 6.20, with 6.19/6.18 supplying the effective automaton translation and a regular witness),
  so `SωS` and Gurevich–Shelah are **not needed**. The theorem gives **no** constructive decision
  procedure, **no** Lean `Decidable (PlusValidZTime φ)` (still Stage 1's own aim), **no**
  elementary complexity bound, and **no** finite model property — a *regular*-model property
  instead (every ZTime-refutable formula is refuted on a finitely presented, not finite, doubly
  serial oriented forest). It is the hedge against the Lean engine and runs beside it.
- **No Lean formalization of the Reynolds engine's §§7–15** (901's Recommendation 8). The
  two-sided chronicle, ban preservation, lulls and hue scheduling, universal non-acceptance, the
  two-sided truth lemma and the final-frame assembly stay a **paper** proof. The CSLib `require`
  question is not to be re-opened on their account either. What this leaves in Lean is the targets
  *stated* (`LCComplete`, `LCRulesComplete`, `LCURulesComplete` in `Metalogic/LCExtension.lean`,
  no proof and no `sorry`) and the soundness half proved (`ext_sound_ztime`, `ext_sound_validIn`).
  Filing a formalization task for any part of §§7–15 is a ruling violation, not a judgement call.
- **The two-sided automata's cross-certification is eliminated, and the bi-infinite alternative is
  closed** (905). Both clause (a)s are subsumed by their own automaton's clause (b) (Theorem 1);
  the one further fact clause (b) cannot supply is seeded from chronicle clause K1 alone (the
  section-8 seed lemma); and the truth lemma's emergent-walk Step 3 is replaced by a four-link
  bootstrap Step 3′. 901's report is the architecture of record and carries the eliminated design.
  The alphabet-shrink expectation is withdrawn. Do not re-introduce a cross-certification clause,
  and do not re-open the bi-infinite-automaton branch.
- **`lcU` is NOT a theorem of TM⁺ + `LC_n` + mirror `LC_n` at Base, Dense or RTime** (906),
  witnessed by the translation frame over ℚ — a regular, deterministic frame on a densely ordered
  carrier where every `LC_n` axiom including the mirror is valid while `lcU` is refuted; the
  extension off Base is by `Sat` antitonicity. **At `.ZTime` the question is open and not
  settleable by any model**: `lcN_plusValidZTime` and `lcU_plusValidZTime` are both compiled, so
  TM⁺+`LC_n` and TM⁺+`IsLCUAxiom` have the same `.ZTime` models by construction, and only a
  proof-theoretic argument could separate or connect them there. **Do not file another
  separating-model task for `.ZTime`.** The guarded-until-form candidate
  `⊡G≤(⟐α → ⟐(⟐β U ⟐α)) → ⟐G≤(⟐α → (⟐β U ⟐α))` survives this countermodel and is recorded in
  `PlusLCSchema.lean` as an open candidate, not a claim.
- **The landed cell schemas bear on the reserved obligation in NEITHER direction**, and may not
  be described as partial progress toward it. This covers all five cell-EQUALITY schemas in
  `LadderCell.lean` — the antitone pair included, each of which says so in its own docstring — and
  the window-regime cell-INCLUSION schema
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

**761 cannot be advanced by any dispatch, and has been demoted accordingly.** All six of its declared edges are discharged, but plan v13 came to rest at 30 of 41 phases closed with **zero enterable**: every remaining phase sits behind Phase 11.6's depth-`0` gate, which no open task owns. Lifting that gate is Stage 0's one unchecked item -- a user ruling, not an `/orchestrate` line. Tasks 929 and 930 are INPUTS to a future revision of that plan and NOT gates of any of its phases, which is why they now head the decidability work and 761 sits well below them.

**761 remains a live scope-collision source.** Its 43 declared paths include `README.md`, `FormalSystem/README.md`, `FormalSystem/Metalogic/README.md` and `typst/generated/status.typ`, every one of which task 803 also declares. That is a plan-level gate, clearable with `--allow-scope-collision` while 761 is not actually running and **not** clearable against a live 761 dispatch.

Only the first batch has to come first -- it is the one that unblocks others. The rest are independent of each other and may be run in any order or interleaved, subject to the batch-gate's live-lock rule.

```
/orchestrate 502, 497, 500, 543 --hard --lit   # The algebraic chain bottom-up to 543, the last high-priority L-plus metalogic task still open
/orchestrate 178, 604, 890, 829   # Four independent deliverables, no shared territory and no edges: examples, zstd, erratum, CI cache
/orchestrate 664, 570 --lit   # Corpus ingest of the ball-space source and the C3 consequence-relation completeness question
/orchestrate 831 --research --lit   # The dense-time dichotomy gating L-R3, the only identified non-ZTime decidability route
/orchestrate 298, 282, 296, 231   # The dataset chain behind the c7 labeling bug; 282, 296 and 231 each carry a 298 edge
/orchestrate 257   # Hugging Face migration for large datasets; externally blocked until the account token exists
/orchestrate 761, 862, 861 --hard --lit   # Ladder realization and its two dependents; parked until the depth-0 gate has an owner
/orchestrate 763 --hard --lit   # The lift and the Decidable (PlusValidZTime phi) corollary; needs 761 terminal first
/orchestrate 481 --hard   # The refuted UnorderedSuccessorLabelClosed residual; a register entry is a complete outcome
/orchestrate 428, 429, 410, 411 --hard   # The tableau spine's middle; needs 428's scope ruled, and 410 already carries a plan
/orchestrate 430, 412, 482 --hard --lit   # The tableau spine's terminus, ending at 482, classified open mathematics and multi-month
/orchestrate 498, 499 --hard   # The Jonsson-Tarski representation's two sides: complex algebra and ultrafilter frame
/orchestrate 125, 501 --hard   # The Jonsson-Tarski capstone and Until/Since on STSA, the representation front's terminus
/orchestrate 177   # Genuinely last in the programme: README, docs/ and module-docstring polish behind 26 edges
/orchestrate 869   # Open-modal truth invariance along a ray-agreement-lifting history morphism; waits on 743 and gates 873
/orchestrate 873, 874, 875, 876   # The L-triangle syntax line: 873 runs first within the batch and gates the other three
```

Why this order:
- FIRST, because it is the only batch here that unblocks other work. 743 is `planned` and gates 803 (-> 804), 787 and 869; 803/804 are the repository's largest measured rebuild cost (SubformulaProperty.lean elaborates in 1103s as one module, about 17 percent of a 414-job incremental rebuild), with research and a landed plan already in hand. It is one batch and not four lines because the members share territory -- `README.md`, `FormalSystem/README.md`, `FormalSystem/Metalogic/README.md`, `typst/generated/status.typ` -- which serializes the batch rather than breaking it. That same territory is what collides with 761's declared scope; see the preamble.
- The head of the decidability front, and a deliberate demotion of 761 beneath it. 929 discharges the I = 1 idle-run sub-regime so `ForwardSlackWitnessed` becomes unconditional rather than conditional on the non-ParamsOk-derivable `IdleRunPumpable`; 930 promotes the two orphan prototypes (`tight-chain-regime-b.lean`, `spanning-divisibility.lean`) that `RaySummary/README.md` cites as the sole authority for two load-bearing refutations while flagging each as "not a wired probe". Both are `ready`, both are depth-0 open-core, and neither is gated on anything. 761's plan v13 derives explicitly that these two are INPUTS to a future revision and NOT gates of any of its phases -- so no dependency edge was added between them and 761, and they are scheduled ahead of it rather than behind it.
- Ordered measurements-then-ruling, which is why the two inputs lead the line. 926 is a decision record that must rule reopen/keep-closed on four routes, and its own text names 927 as "its companion measurement task" for route R2 -- the route it says it "should weigh first", and the only one needing no ruling at all if 927's check comes back positive -- and 928 as "the companion cost-assessment task" whose costing it "consumes". Neither relationship was expressed as a dependency edge; both have been added this pass (926 now carries `dependencies: [927, 928]`). Reversing Recommendation 8's bar on formalizing the Reynolds engine's sections 7-15 is a user ruling, so this batch produces a record, not Lean.
- 543 is reachable ONLY through the edge chain 502 -> 497 -> 500 -> 543, and its first three links are all priority `low`, which is exactly why 543 -- priority `high` -- has never been scheduled on its own. Batching the chain is the only way the high-priority terminus is ever dispatched; the intra-batch edges sequence it into successive waves rather than disqualifying any member.
- Parallel-safe by construction. 178 (priority high) is the publication-quality Examples/ expansion, now `ready` since both its edges archived; 604 adds zstd `.jsonl` dataset support; 890 is `researched` and only needs the GHR94 Lemma 10.2.3 Case 5 erratum written into the Typst reference manual; 829 adds the missing `actions/cache` for `.lake/build`, absent from all three workflows today. This batch previously also named 832, which has since archived.
- Both are literature-shaped and neither touches Lean. 664 closes a measured corpus gap: the manuscript's `def:frame` footnote cites Cmiel2021 for the ball-space claim, and no matching entry exists in the global index or the sub-index. 570 is an open research question, not an implementation task -- whether the logic of C3 equals Burgess-Xu without unboundedness plus S5 -- where only the containment is established and the completeness claim was explicitly declined.
- Verdict-first research, deliberately alone on its line: the deliverable is a verdict plus grounds, not a landed theorem, and it must not be budgeted as a routine task. Every landed and in-flight decidability result in this tree is ZTime-shaped; L-R3 is the only identified route to Base/Dense/RTime, and this record is what makes the review's "NEW, UNFILED" reference resolve.
- Dependency-inclusive and correctly headed by its blocker. 298 is `partial` and fixes the c7 labeling bug at formula ~13750; 282 and 296 are also `partial` and both wait on it, as does 231's regeneration automation. Off both critical paths, so it sits below the decidability and completeness work rather than competing with it.
- Alone on its line and genuinely not dispatchable yet: the blocker is an external credential, not an in-repo predecessor, so no dependency edge can express it and no batch member can clear it.
- Deliberately demoted from the head of the list, where it previously sat. All six of 761's declared edges are discharged, but plan v13 came to rest at 30 of 41 phases closed with ZERO enterable, every remaining phase behind Phase 11.6's depth-`0` gate that no open task owns -- so dispatching this line advances nothing until Stage 0's unchecked ownership item is ruled. 862 and 861 stay batched WITH 761 rather than after it, because their edge is on 761 reaching TERMINAL and a dependent without its out-of-batch blocker is dead weight; both are already `researched` and will land the moment the gate lifts.
- Kept on its own line rather than folded into the batch above, because it needs not merely 761 terminal but the whole chain above it closed. The (S) scope question it turns on is still owned by no task.
- Classified genuinely open -- the predicate is refuted as stated -- so the honest terminal outcome is a register entry recording the refutation, not a discharge. Scheduling it expecting a proof is the failure mode this line exists to prevent.
- The whole Track A/Track B tableau spine is priority `low` and off both critical paths, which is why it sits below the L-plus work despite its size. Dependency-inclusive: 428 is `blocked` and heads the chain it gates (429 -> 410 -> 411).
- Separated from the spine's middle because its terminus is a different kind of work: 482 is classified OPEN MATHEMATICS on a multi-month horizon and must not be scheduled as routine implementation.
- Both hang off 497, which the chain-to-543 batch above already carries, so this line is placed after it rather than duplicating 497. 499 is flagged HARD in its own record.
- 125 is the capstone, reachable only once 498 and 499 both land; 501 extends STSA with Until/Since behind it.
- Carries 26 declared edges, more than any other record in the tree, and is a documentation sweep whose value depends entirely on the work it documents having landed. Running it early guarantees re-running it.
- The only L-triangle task with an out-of-batch gate: its 743 edge is carried by the first batch in this list, so it cannot run until that one closes. It now also gates 873 on shared file scope (FormalSystem/OpenLanguage.lean, docs/theorem-index.md), so it runs ahead of the L-triangle syntax line rather than after it. Small, self-contained, and demoted by the same standing ruling as that batch.
- Placed below every L-plus line by standing user ruling: the repository's aim is completeness and decidability of the stability-modal language L-plus, and L^|> is a secondary line of investigation that is kept but never dispatched ahead of, or batched with, critical-path work. Within the batch, 873 gates 874, 875 and 876, which each carry an edge on it. 873 itself carries an edge on 869 and so runs after the batch above: the two share FormalSystem/OpenLanguage.lean and docs/theorem-index.md, and the edge makes that shared territory an ordered sequence rather than a collision the admission gate refuses. 876 is a decision record only -- no constructor of `OpenFormula` is to be removed.

Each line is one invocation, and batches are dependency-inclusive: a batch holding a blocker together with its dependent is correct, while a dependent named *without* its out-of-batch blocker is dead weight. `MAX_TASKS` is 8 and the work-cycle budget is per task per invocation (5 default, 13 under `--hard`), so **re-run the same line until every member reports terminal**. Shared file scope serializes a batch rather than breaking it, and a collision against a *live* session's lock is not bypassable by `--allow-scope-collision`: wait for the holder, or batch with it. See `.claude/context/patterns/batch-orchestration-guardrails.md`.

**This section is generated and is the authority on run order.** It is rendered from `specs/state.json`'s `roadmap_batches` by `scripts/roadmap-integration.sh`; change the order or the membership through `/roadmap`, never by editing the fence by hand -- a hand edit here is overwritten by the next regeneration. The `## Next batches` section further down is authored prose that no regeneration touches, and its task list has gone stale against the live graph.
**Coverage appendix (uncovered tasks)**:
```
/orchestrate 931,932
```

## Next batches

```bash
# Stage 1 -- decidability of L-plus at ZTime. 761's hold is LIFTED, but no phase of its plan is
#   enterable: Phases 11.12/11.13 are [BLOCKED] on the hself binder drift and everything else is
#   behind Phase 11.9's depth-0 verdict. /revise 761 FIRST (Stage 0). The I = 1 idle-run
#   sub-regime is nobody's task and is not to be filed without reading 924's report
/orchestrate 761,862,861 --hard --lit    # dependency-inclusive, and ONLY after /revise 761. Lifting the hold did not make 862/861 eligible: their edge is on 761 reaching TERMINAL, not on it leaving `hold`, so they batch WITH it rather than after it. 862 is the forward pend/countdown rigidity sharpening feeding the same cell-level arithmetic, 861 the one-sided refutation table row, which also waits on 763
/orchestrate 763 --hard --lit            # the lift and the Decidable (PlusValidZTime phi) corollary -- needs 761 TERMINAL and the chain above closed. Settle the (S) scope question first; it is still nobody's task
# Stage 2 -- completeness of L-plus at ZTime. The Lean programme is CLOSED by ruling; no line
#   remains, and filing one against the Reynolds engine's sections 7-15 is a ruling violation
# Stage 2b -- supporting semantics and metalogic
/orchestrate 664,570 --lit               # corpus ingest and the C3 open question
/orchestrate 830 --hard                  # Gamma-generalize decidableValidZTime; does NOT advance either aim
# Stage 3 -- hygiene, build cost, datasets. Off both critical paths
/orchestrate 298,282,296,231             # the dataset chain behind the c7 labeling bug (298/282/296 partial; 282, 296 and 231 all carry a 298 edge)
/orchestrate 257                          # only once the Stage 0 Hugging Face token exists
# Stage 4 -- the long fronts, off both critical paths
/orchestrate 481 --hard                  # the refuted predicate; a C9 register entry is a complete outcome
/orchestrate 831 --research --lit        # off-spine: the Log(all) = Log(ZTime) cap Log(Dense) dichotomy
/orchestrate 428,429,410,411 --hard      # the tableau spine's middle -- needs 428's scope ruled; 410 planned
/orchestrate 430,412,482 --hard --lit    # the spine's terminus
/orchestrate 498,499,500 --hard          # the representation's two sides and their reconciliation
/orchestrate 125,501 --hard              # the Jonsson-Tarski capstone and Until/Since on STSA
/orchestrate 177                         # last in the programme: README, docs/ and docstring polish. Carries 27 edges and is genuinely last
# Stage 5 -- L-triangle exploration. Secondary, priority low; never ahead of, or batched with,
#   Stages 1-2. What each investigates and its gate: the backlog table above. 873 is dispatched in
#   the parallel line under "Run these next"; 874/875/876 all carry a 873 edge and stay behind it,
#   and 869 carries a 743 edge
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
task with no declared `file_scope` is invisible to the overlap gate, and no open task remediates
that blindness — 19 active records currently carry no `file_scope`, which `validate-state.sh`
reports as warnings. A cross-batch collision against a **live** session's lock is not bypassable
by `--allow-scope-collision`, which clears only the plan-level gate: wait for the holder, or
batch with it. See `.claude/context/patterns/batch-orchestration-guardrails.md`.

## Stage 0 — User rulings (no agent may transition these)

- [x] **761's hold is LIFTED** (2026-11-12, user ruling; `preflight 761 unhold` restored its
      recorded `prior_status`, `implementing`, and cleared `hold_reason`/`held_at`/`prior_status`).
      Both substantive reasons for waiting were discharged and the serialization cost was spent.
      **It did not produce a dispatchable line**, for the reason in the next item
- [x] **The `hself` disposition on Phases 11.12 and 11.13 is RULED: disposition (B), RENAME to
      auxiliaries** (2026-11-13, user ruling). Both phases' declarations are LANDED and sorry-free
      (`exists_ladderPath_at_region_of_idle_past` at `LadderAgree.lean:2227`, the join
      `exists_ladderPath_at_region` at `:2291`), and each carries a self-loop hypothesis
      `hself : ∀ p ≤ a, pend (objAt g p) = false → step (objAt g p) (objAt g p) = true` that
      neither recorded block admits. Disposition (R) is CLOSED on the mathematics: the probe
      `specs/evidence/seam-gluing-ray-product/ladder-self-loop-derivability-decision.lean` compiles
      `hself_not_derivable` — the implication from the recorded binders to the path-local self-loop
      is refuted even with `Fintype Q` assumed, strictly stronger than either landed declaration
      needs — together with `hself_satisfiable_at_an_instance`, so `hself` is neither derivable nor
      refutable and is a genuine INDEPENDENT premise. **(B) is ruled over (A) on four grounds**: the
      module already carries this exact idiom for `exists_spliced_ladderPath_of_idle_past`
      (`LadderAgree.lean:1509`, unclaimed and refuted), so (B) reuses a convention rather than
      adding a softer second one; a premise nothing can discharge from below belongs in the NAME,
      where every use site sees it, not in a caveat held in two other files' docstrings; the
      reserved names stay available for whatever eventually discharges `hself`; and (A)'s cost is an
      unscoped `/revise` round to amend two recorded blocks, where (B)'s extra cost is mechanical
      and already enumerated in Phase 11.16. Phase 11.16's branch (B) is therefore the enterable
      branch, including its instruction to RAISE — not silently take — the one-line scope expansion
      onto `LadderWindow.lean:509-519`
- [x] **The depth-`0` gate's crux is OWNED: task 934 runs the reachability probe** (2026-11-14,
      user ruling). The gate ruling itself is NOT taken here — 934 returns a compiled verdict and
      the disposition stays with the user. Original framing, retained because its detail is still
      live: the `hself` ruling unblocks
      Phases 11.16 and 11.17 only (~2.5h); the other fourteen open phases of 761, and five of its
      six filed Goals (`ladderSound`, `ladderCons_localRun`, `ladderLift`, `Dmax ⊆ Real`,
      `ladderRealized`), sit behind Phase 11.6's depth-`0` gate. That gate lifts on exactly one of
      two events — `cellLE_zero_const_of_kappa_eq` lands as a `sorryAx`-free THEOREM, or
      `CellLEZeroConstOfKappaEq` is refuted under `ParamsOk` — and **no open task owns either**.
      The reserved name is claimed by nothing (five prose sites record it as unclaimed); the schema
      is refuted at the ONE-DEPTH conditions (`ParamsOkPre`, the forty-seventh wired probe) but the
      two-depth `(K4)` dissolves that collision, so under `ParamsOk` it is neither proved nor
      refuted. The gate is nearer than "prove it from scratch": five restricted cell-EQUALITY
      schemas are landed (`_of_forwardSlack`, `_commonShift_`, `_monotone_`, `_antitone_`,
      `_antitone_bounded_`), the monotone/antitone dichotomy is compiled exhaustive with both slices
      inhabited, and `forwardSlackWitnessed_zero` makes the amount-`0` case free.
      `RaySummary/README.md` names the one remaining crux itself: **whether a
      `ForwardSlackWitnessed` hypothesis at a POSITIVE amount is satisfiable at any state the
      depth-`0` induction one layer up reaches**, which "stays open and claimed in neither
      direction". A probe deciding that decides the gate in one direction or the other. **Trap for
      whatever takes it**: the per-path state-level regime is ALREADY refuted
      (`ClimbWitness.hasForwardSlack_refuted_unconditional`); `ForwardSlackWitnessed` survives only
      as an existential over paths, so the existential form is the target and the per-path form is a
      known refutation

      **WHAT 929 CHANGED, and why this is now probe-sized.** The crux above is no longer "claimed
      in neither direction". 929 landed the first cell-level refutation of `ForwardSlackWitnessed`
      (`forwardSlackWitnessed_refuted_I_one`: FALSE at amount `4` at `xState = (true, 2, 0)` on
      `stepOr`, at a state whose pending-forever regime membership is compiled by `xState_regime`),
      together with a compiled bound on its reach. The mechanism is the ceiling
      `hasForwardSlack_amount_le` (`LadderChain.lean:1656`), `(l : ℤ) ≤ (n : ℤ) + cntAt g z + I`.
      The five depth-`0` schemas instantiate `ForwardSlackWitnessed` at ONE shape — state
      `(q, c', n')` with `c' = c + m * (P + 1)` and amount `l = m * (P + 1)`
      (`LadderCell.lean:1503-1508`) — where `cntAt` is `c' ≥ l`, so the ceiling is satisfied for
      free (`ceiling_slack_at_consumer_amount`, `LadderIdle.lean:1306`). **929's refutation
      therefore provably cannot reach the schemas' instantiation**, and all five keep the
      hypothesis for a positive compiled reason. What stays open is the other half: immunity to the
      ceiling is not satisfiability, and `ForwardSlackWitnessed` is a `∀ T ∈ cellAt …, ∃ g τ, …`
      statement (`LadderCell.lean:998-1010`). 934 decides exactly that, at exactly that
      instantiation. **Second trap, from 917**: the pin-layer discharge route is already REFUTED
      and wired (`pin-cascade-straddle.lean`); do not retry it
- [x] **The former "then `/revise 761`" item is DISCHARGED** — plan v12
      (`specs/761_ladder_realization_theorem/plans/12_hself-disposition-gate-settlement.md`) IS that
      revision, and it settled its one live question: 924's relocation of `ForwardSlackWitnessed`
      onto `IdleRunPumpable` does NOT lift Phase 11.6's gate, on four recorded grounds, decisively
      because `forwardSlackWitnessed_of_cell_idleRunPumpable` carries
      `hno : ∀ χ, PlusFormula.stab χ ∉ plusSubformulaClosure φ` at `LadderIdle.lean:1040` — a
      STAB-FREE closure, which is the one restriction a `⊡`-nesting-depth induction cannot start
      from. Clause (i)'s first disjunct genuinely does not fire (the premise is cell-universal); its
      second does. **No dispatch is to re-ask this question.** The next revision of 761 takes the
      depth-`0` crux probe's verdict as its input, not this one
- [ ] Supply the Hugging Face account and token **257** is blocked on
- [ ] Rule on **428**'s scope. Its one edge is discharged and its `blockers` says "paused at
      4/5 cycles, NOT blocked", so the marker is mis-set: `/revise 428` to add phases for its four
      residual hypotheses, or `/spawn 428` to split them out
- [ ] Rule on **821**, whose premise is now false. It exists to make `validate-state.sh --deep`
      Check 12 pass and `state-write.sh --allocate-into` stop refusing; Check 12 **PASSES** as of
      this writing (`next_project_number` is 926, above every archived row), so the measured
      failure it was filed against is gone. Abandon it, or re-scope it to whatever of its report's
      wider counter-hygiene findings survives — but it should not be dispatched as written
- [x] **Requirement (S)'s residue: the assignment to (W) is CONFIRMED SUFFICIENT and no extension
      task is filed** (2026-11-14, user ruling). The residue was re-measured against the LANDED
      TREE rather than against prose, and it is narrower than this item recorded: it is ONE named
      missing theorem, `real_certStabK`. `certAdmK` (`CounterQuotient.lean:1045`) has six
      conditions and `Real` discharges FIVE — `real_certLocK`, `real_certBiInfK`, `real_certFwdK`,
      `real_certBwdK` and `real_certBoxK` are all landed in `LadderRealize.lean` (`:438` for the
      `box` one); `real_certStabK` exists nowhere in `FormalSystem/` or `specs/`. Both halves of
      (S)'s residue are therefore CARRIED BY LANDED CODE rather than merely assigned in prose: the
      `box` half is DISCHARGED outright by `real_certBoxK`, and the "every seam but the one" half
      is carried by `Real`'s existential over the `ℤ` component, which is what lifts past the
      one-seam restriction `presented_modelOf` carries through its explicit `(τ, t)` and anchor
      `hτ`. `LadderCons` (`LadderRealize.lean:245`) is landed and its acceptance criterion is not
      optional — it is `certAdmK ∧ Dmax ⊆ R`, with `certBoxK` pinning the `□` letter as one global
      bit and `certStabK` pinning the `⊡` letter per `(q, κ)`. **Filing a standalone (S) extension
      would duplicate `real_certStabK`**, which is the `Real` condition the depth-`0` gate already
      gates: (S)'s residue and that gate are NOT two independent unowned items, they are one. 917's
      own verdict already named this consequence — `certStabK`'s one unclaimed `Real` condition
      must be RESTATED rather than proved for as long as `ForwardSlackWitnessed` stays carried.
      **What 763 inherits is therefore a verified premise, and the thing to watch there is
      `real_certStabK`, by name** — which is what "do not discover this at 763" was asking for
- [ ] Decide whether the **`I = 1` idle-run sub-regime** is filed. It is the whole distance
      between 924's conditional discharge of `ForwardSlackWitnessed` and an unconditional one, and
      discharging it lifts the `certStabK` restatement obligation. The one route that would make
      `IdleRunPumpable` `ParamsOk`-derivable — amending `(K1)` to quantify `idleCycleLens` — is
      **measured at a blast radius of every wired probe** and is deliberately not admitted without
      its own decision. File neither half without reading 924's report first

**713** is held by ruling (2026-10-03): its argued CTL⋆ 2EXPTIME lower bound is a citable ceiling
with no consumer. **734** is `[HOLD]` on the paywalled *Handbook of Modal Logic* ch. 11
§§5.10–5.11 (Hodkinson & Reynolds, pp. 655–720), absent from the local Zotero library;
reactivation condition `specs/literature-index.json#hodkinson_2006.hazard`. Acquiring it lifts a
hold, not the aim.

## The Stage 1 frontier, and where it sits

The chain, bottom-up, is the whole of what remains on the decidability front.
`CellLEZeroConstOfKappaEq` under `ParamsOk` gates `certStabK`, the one `Real` condition of six not
claimed; which gates `real_certAdmK_of_paramsOk` and `real_subset_dmax`; which gate the ladder
realization theorem; which is (W)'s run layer, the lift from one seam to validity; above which
sits 763's `Decidable (PlusValidZTime φ)`, stated nowhere in the tree.

**The collision case split is fully dispatched on BOTH sides, and what blocks the bottom link is a
frontier with a known location rather than an open question in either direction.**
`kappa_collision_regimes` has three branches, and **five** depth-`0` cell-EQUALITY schemas are
landed against them in `LadderCell.lean`, every one of them carrying `ForwardSlackWitnessed`:
`cellLE_zero_const_of_kappa_eq_of_forwardSlack` (equal register, `:1530`),
`cellLE_zero_const_of_kappa_eq_commonShift_of_forwardSlack` (common shift, register freed,
`:1631`), `cellLE_zero_const_of_kappa_eq_monotone_of_forwardSlack` (monotone, carrying neither
restriction and specializing to both the others' hypotheses, `:1767`),
`cellLE_zero_const_of_kappa_eq_antitone_of_forwardSlack` (`:1910`) and
`cellLE_zero_const_of_kappa_eq_antitone_bounded_of_forwardSlack` (`:1961`). Three findings fix the
frontier:

- **The antitone slice is DISPATCHED, not excluded** (916's own Phases 5-7, which landed after the
  exclusion was first recorded). `kappa_collision_monotone_or_antitone` makes the two slices
  exhaustive with no third case, and the antitone schema closes both orientations of the
  disjunction by `Set.Subset.antisymm` against one pair of inclusions
  (`cellAt_subset_of_antitone_register_shift_of_pend_past` upward and its `_rev` downward), with
  the two pairs' roles swapped — cell equality being symmetric, no third inclusion is needed. With
  the monotone theorem beside it, **every collision in the pending-forever regime above the
  threshold is now covered by one of the two schemas.** The compiled non-vacuity witness
  `kappa_collision_antitone_residue_nonvacuous` at `(4,2)` against `(6,0)` is re-read in-source as
  a demonstration about the slice's *cheaper half*: there `m = 2` and the descent is exactly
  `m · (P + 1)`, which is the bounded corollary's hypothesis
  (`kappa_collision_antitone_bounded_descent_nonvacuous` records precisely that), while
  `kappa_collision_antitone_deep_descent_nonvacuous` inhabits the complement where the general
  schema's upward hypothesis does real work. The reason the free-register raise stops short is
  still compiled: `free_register_anchor_clause_monotone_required` shows the anchor clause's lower
  bound non-removable, and the clause's two bounds pay for opposite directions — that is why the
  antitone case needed its own schema rather than an extension of the monotone one.
- **`ForwardSlackWitnessed`'s deletion route is REFUTED at the pin layer** by a compiled theorem
  rather than merely unproved. `no_deleted_ladderPath_of_straddle_break` (`LadderChain.lean`)
  shows that once the straddling pair breaks at the reduced distance, no deleted ladder path
  exists at all — the primitive's own conclusion is false there. The arithmetic reason is that
  `cascadeBound`'s recurrence `a(k+1) <= 2*a k + J + 1` is attained **with equality** by the
  saturated configuration, so `(K2)`'s budget describes the obstruction rather than dominating it;
  `hanch` falls short by exactly the deleted block's length and `hstraddle` by twice it, measured
  scale-invariantly. The existential-over-paths form survives
  `ClimbWitness.hasForwardSlack_refuted_unconditional` because it is existential, and that
  asymmetry was the only opening.
- **That opening is decided POSITIVELY, conditionally, by a different mechanism, and the route is
  LANDED** (924). `hasForwardSlack_of_idleRunRepeat` (`LadderIdle.lean:909`), `IdleRunPumpable`
  (`:992`) and `forwardSlackWitnessed_of_cell_idleRunPumpable` (`:1035`) are in the library, each
  measured `[propext, Classical.choice, Quot.sound]`, with route-space closure wired as the probe
  `forward-slack-pin-cascade/route-space-closure` (wired total 55). The deletion refutation above
  stands unchanged; the route that succeeds is the **idle pump**, deriving
  `ForwardSlackWitnessed` at **every** amount `l` from one run-local premise — each type in the
  cell realized by a path whose intervening idle run carries an `(objAt, tpOf)`-repeat block —
  built entirely from landed machinery (`idleGapLengtheningOfIdleRunRepeat_holds` plus
  `hasForwardSlack_of_next_region_cnt_le`), with no deletion and no cascade budget spent. It pays
  where deletion could not because the regime asks `K <= n + c + I - l` against a free bound
  `K <= n + c + I`: deletion tried to lower `K`, which a saturated register has already spent,
  while the pump manufactures `d*k` units of `I`, and `I` is bounded above by no pin obligation
  (`idleSplice_pins` is unconditional).
  **It is a conditional discharge, not a removal.** The premise is an object/run datum and is
  **not** `ParamsOk`-derivable — `(K1)` names `prodCycleLens`/`objCycleLens`/`satPeriod` and never
  `idleCycleLens` — so the hypothesis stays on all five depth-`0` schemas.
  **Consequence to carry**: `certStabK`'s condition must still be RESTATED, not proved, and that
  restatement obligation is **PROVISIONAL** rather than permanent, for as long as the hypothesis
  is carried. The remaining gap is exactly the `I = 1` sub-regime (Stage 0, above): paths whose
  intervening idle run has length `1` carry no repeat block, so the pump has nothing to duplicate.

**761's blockers are discharged at the declaration level, with one statement-level residue.** The
Phase 11.12/11.13 gap is closed as mathematics — both declarations are landed and sorry-free — but
both carry the self-loop hypothesis `hself`, which neither recorded block admits and which Phase
11.12's own verification bullet names as disqualifying. That is a statement-level decision owed to
the user (Stage 0), not a proof gap. **The index is settled for one regime, one-directionally.** The
positive factorization is landed for the ordinary window regime `c <= n + 1` in
`RaySummary/LadderWindow.lean` as `CellSubsetOfKappaEqWindowRaise`, proved by
`cellSubset_of_kappa_eq_window_raise`, with `kappa_collision_window_or_pendPast_exhaustive` giving
the regimes' exhaustiveness at a fixed register. It concludes cell **inclusion**, not equality,
and holds **upward only**; its carried condition `WindowIdleRunWitnessed` is existential over
paths in the same shape `ForwardSlackWitnessed` already uses.
**Do not re-attempt the lowering primitive as stated.** It is excluded on a compiled measurement:
the anchor clause reverses direction under deletion and needs a sixth carried hypothesis bounding
the register from above (`nxtAt g z + jP <= cntAt g z + 2*d + 1`), which the collision's lowering
branch does not supply and the path's own bound is short of by exactly the displacement. Landed as
`window_lower_anchor_of_required`, `window_lower_anchor_not_implied` and
`window_lower_anchor_fails_at_tight_bound`. Admitting that sixth hypothesis to buy a
two-directional schema is a standing open **choice**, deliberately recorded rather than taken.

What the refuted index families buy is a **specification**: any index must have a formula-derived
threshold and a modulus that is a multiple of the period of every letter-definable sub-object.

761 is live again (`[IMPLEMENTING]`) and re-imposes serialization on everything sharing the
`RaySummary` library set, `docs/theorem-index.md`, `scripts/check-module-invariants.sh`,
`specs/evidence/seam-gluing-ray-product/`, `specs/state.json` and `specs/TODO.md`. 862, 861 and
763 all sit behind it on a **terminal-status** edge, not on the hold — so they batch with it, and
do not become independently eligible merely because the hold is gone. Nothing else holds that
territory, but any batch that touches it now collides with 761 and must include it.

## Not batched, and why

- **713**, **734** are `HOLD` by ruling. **761 is no longer held** — its hold was lifted
  2026-11-12 — but it is not dispatchable either, and the reason moved rather than cleared: see
  the `hself` disposition and the `/revise` item in Stage 0.
- **Closedness of the canonical bundle is the completeness front's standing open problem and is
  not to be filed.** It is 559 item (c), not `(P1)`: PS/US give paste-closure, MF translation-
  closure, and nothing gives closedness. The cure of record is the until-form `LCU` and its mirror
  plus the Reynolds automaton-and-ban machinery (Reynolds 2001 §11–§13). **Both halves are in hand
  on their own terms** — `lcU` and its mirror are declared and ZTime-valid (`lcU`,
  `lcU_plusValidZTime`, `lcU_reflectTime_plusValidZTime`), and the ban/lull machinery is written
  out as a paper proof — **and the obstruction is still not discharged**, because 901's
  Recommendation 8 keeps §§7–15 out of Lean. Filing it needs a fresh user ruling reversing that.
- **No agent-system work is filed in this repository, and none is to be.** Every
  `task_type: meta` record has been migrated out to the repository that owns the shared source
  store. This repository's `.claude-extensions.json` does not declare a reachable `source_dir`, so
  a record whose edit target resolves only under the source store cannot be executed from here.
  Re-filing one is a ruling violation, not a judgement call. (907 is not such a record: it
  *regenerates* the deploy artifact from the source store, which is exactly the sanctioned
  remedy, and never hand-patches a deployed file.)
- **The blocker-research aux chain is a dead drop with no receipt** — `orchestrate-cycle-plan.sh`
  clears `aux_pending[t]` at emission time, so a fork that never writes `.blocker-research.json`
  emits no `plan-revision` row, `MAX_BLOCKER_ESCALATIONS` never fires, and an `[IMPLEMENTING]`
  task falls back into the known-blocked phase. This is the mechanism behind 761's repeated
  re-entries. Recorded here because no open task owns it.

**Reading the coverage appendix.** It lists *ready* tasks absent from **`## Run these next`**
alone — never computed from `## Next batches` or this section. A Stage 1 task deliberately kept
out of the immediate run list appears there correctly; its presence is not a gap.

**`[RESEARCHED]` does not always mean a report exists.** 781, 821, 861 and 862 each carry
`[RESEARCHED]` with zero linked artifacts and no task directory on disk — their research was done
by a predecessor and folded into the task description, which is where a dispatch must read it
from. Do not go looking for a `reports/` file that was never written.

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
  landed, the antitone collision slice is dispatched by its own two schemas, and whether the
  existential-over-paths form
  admits any route at all is **answered affirmatively** by the idle pump. What remains is the
  `I = 1` sub-regime it does not reach.
- **The plan-specified spine for the register-lowering deletion is not implementable, and the
  landed route is not to be "corrected" back to it.**
  `exists_deleted_ladderPath_overshoot_of_pend_past` pins its slack amount to the shape
  `R*l + budget*l` at the held register in hypothesis *and* conclusion, so the extra displacement
  a lowered anchor needs is destroyed by the loop and cannot be recovered — slack transport is
  exact in both directions, monotonicity runs the wrong way in both arguments, and the increment
  folds into the loop's shape only when the step divides it. The landed route lowers the register
  *before* the surgery via `exists_ladderPath_of_walk_nxt_at` on the path's own walk and countdown,
  then applies the held-register theorem as a black box. Generalizing that loop to a free slack
  amount is a recorded option, needed by nothing landed.
- **The idle-gap lengthening's freed-increment form is refuted**
  (`idleGapLengtheningAllIncrements_refuted`, `LadderIdle.lean`): idle states with a 2-cycle and
  no self-loop admit only even-length runs. The run-local restriction — a block of the idle run
  whose two ends carry the same object state — is **necessary**, not an artifact of the proof, and
  under it the pin condition **discharges outright** rather than merely loosening
  (`idleSplice_pins` carries only `IsLadderPath`, positivity and the block's idleness). Do not
  re-propose the unrestricted form. The spanning-block device is refuted both ways alongside it.
- **`spliceCnt` does not transfer to an idle block.** Its region-raise clause fires vacuously at
  an in-block position and returns the step where zero is forced, which is why `idleSpliceCnt` is
  a separate definition. Do not attempt to reuse `spliceCnt` there.
- **The unconditional `buildTableau_isSome` is FALSE by construction** at the engine's
  `maxBranches := 50000` guard, at any fuel. The whole decidable-branch-gate family collapses to
  `false` on any branch that mints a world, so 429 is a redesign, not a repair.
- **ℤ-time validity of L is already decided** (`Compression.decidableValidZTime`), so the
  deliverable is the four-class `isValid` biconditional, not a first decidability theorem. ZTime
  *provability* of L is decided too (`derivable_iff_validZTime`, `decidableDerivableZTime`),
  without the tableau spine.
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
  which CSLib has in any form.
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
  obligation onto every consumer. A phase may therefore hold itself to "gate exits 0" again — but
  still read the per-check `PASS`/`FAIL` lines when a run is scoped, since `--no-build` skips the
  whole `env_linter` batch and cannot witness C16 either way.
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
- **R3, the doubled AA⊡ rule, is answered by what landed rather than by a task of its own.** The
  chain 894 → 895 → 896 is archived: the cone carrier discharged the Auxiliary-Atoms carrier's
  *Saturation* obligation on 870's lemma (the blocker `NamingRules.lean` recorded is closed, and
  that docstring's "left open" assertion is retired); 895 landed the formula-level rule forward
  and mirror with ZTime soundness; 896 landed the extended system. A separate R3 filing would
  duplicate `aa_sound_ztime`/`aa_reflectTime_sound_ztime` and is not to be made.
- **The one invisible collision across Stages 2 and 5** is the one-line import in
  `FormalSystem/Semantics/Presheaf.lean`, which no task declares. Batch only tasks already
  serialized by a dependency edge, and re-run `lake build` after each aggregator edit.
- **743 is the only live task that gates anything**, and it gates three: 803 (and 804 behind it),
  787 and 869. That is why it heads its own batch rather than sitting in a hygiene line.
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

**`CHANGE_LOG.md` is behind the archive.** Its newest entry is 2026-10-04, while the most recent
archival run moved 36 tasks (28 completed, 8 abandoned) and 28 task directories without writing
an entry. The archived rows survive in `specs/archive/state.json`, so nothing is lost, but the
human-readable record skips that wave — reconstruct it from `specs/archive/state.json` before
relying on `CHANGE_LOG.md` for anything after that date.

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
