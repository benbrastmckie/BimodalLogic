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

**Stage 1 has NO dispatchable Lean line; Stage 2 has none either.** This is the governing
fact about the current state of the tree, and it is the product of rulings and closed
programmes rather than of unfinished dispatches.

- **Decidability (Stage 1).** 761's hold was **LIFTED** (2026-11-12) and the `hself` disposition
  was **RULED (B), rename to auxiliaries** (2026-11-13, Stage 0 below) — and that ruling was
  EXECUTED, not merely enabling: Phases 11.15, 11.16 and 11.17 closed `[COMPLETED]`, and Phases
  11.12 and 11.13 were promoted `[BLOCKED]` → `[COMPLETED WITH EXCLUSIONS]` on Phase 11.15's own
  authority. Plan v13
  (`specs/761_ladder_realization_theorem/plans/13_depth-zero-gate-rest-state.md`) records the
  result: 30 of 41 phases closed, **ZERO phases enterable**. Every remaining phase — ten
  `[NOT STARTED]` plus Phase 11.8 `[BLOCKED]` — and five of the task's six filed Goals, sits
  behind Phase 11.6's depth-`0` gate, which **no open task owns**. The crux that would decide
  that gate is restated, with the landed evidence on its satisfiable side, in Stage 0 below
  (the depth-`0` gate bullet) and in `RaySummary/README.md`; it is not restated a second time
  here.
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
and the depth-`0` gate's crux has a landed verdict rather than an open owner: task 934
completed 2026-11-14 and is archived, having compiled that the gate's crux IS satisfiable at
the consumer-shape instantiation the five depth-`0` schemas use — existence evidence only, the
gate ruling itself still not taken. See Stage 0's depth-`0` gate bullet below for the full
statement; it is not restated here. The `I = 1` idle-run sub-regime was filed as 929 and
completed 2026-11-13.

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

**The list is reconstructed on the instruction to clear repository hygiene first and then orchestrate the proof-mode programme.** One hygiene line leads: 604, the dataset readers the c7 zstd compression left broken. The twenty-four-record proof-mode programme follows in eleven lines: the operator-family layout move stands alone at the head, its implementation held by three open pull requests, then the pre-gate streams run to the adequacy gate, and what follows is split again at the interface join where the five streams meet. Below that sit the half-finished dataset clean-up and the externally blocked Hugging Face migration; the L⁺ fronts keep their existing relative order beneath those, and the L^▷ exploration backlog stays last by the standing 2026-11-05 ruling.

**The runnable hygiene front is exactly one line wide, and saying otherwise would be padding.** Measured against live state, the open non-terminal records that are genuinely clean-up, docs or housekeeping are 604, 177, 257 and the dataset PARTIAL line (298, 282, 296, 231) — and only 604 can run before the proof-mode work. A fifth, the test-coverage gap for `FormalSystem/NomicLanguage/`, `ForMathlib/` and `Tactic/`, led this list when the pass began and reached `completed` MID-PASS in the concurrent session that held it; it is retired from the list rather than reordered within it. The three remaining hygiene items are each unreachable by reordering, stated here rather than hidden by placing them first as if they could run. 177 still has ten non-terminal predecessors (178, 282, 296, 298, 428, 429, 430, 481, 482, 543), one of which — 482 — its own record classifies as OPEN MATHEMATICS on a multi-month horizon, and raising a *final* documentation sweep would only guarantee re-running it. 257 waits on a Hugging Face account token that only the owner can supply: the one hygiene blocker a dispatch cannot clear but a person can. The dataset line's head needs a full native compile (410 generated `.c` files, two of them around 45 minutes each at 2-7GB clang RSS) and 282 additionally needs explicit user approval for multi-hour compute. The front's earlier lead line (941 and 943: the local mirror of `ci.yml`'s nine checks, and the root-level gitignore and loose-file gaps) closed before this pass. `active_goal` reads "Close the residual repository-hygiene backlog"; on this measurement that backlog is one dispatchable line plus three items waiting on something no dispatch provides.

**The proof-mode programme is split at its two gates and at the two records nothing may run beside, and it is no longer one chain.** Its twenty-four records run as five streams out of 960 that join at 952, exactly the shape `records/proof-mode.md`'s Dependency picture draws; where each rule and tactic belongs is fixed by `records/proof-mode-architecture.md`. The filed edges are 969<-960; 944<-960; 945<-944; 946<-945,969; 955<-958,960; 961<-960; 954<-960; 947<-946,955,961; 949<-947; 950<-949; 948<-947,949,950; 951<-947; 963<-954,947; 964<-963; 965<-947; 952<-948,951,963,964,969; 953<-952,962; 956<-948,950,952; 957<-956; 966<-955,952; 967<-957,966; 968<-948,952 -- with 960 and 962 carrying no predecessor at all. This pass added NO edge and removed none; the three edges around the new views record (969<-960, and 969 feeding 946 and 952) were filed with the record itself. 947 is GATE ONE: its report at `docs/development/proof-mode-adequacy-perpetuity.md` must OPEN with an explicit GO or RE-PLAN verdict, and on RE-PLAN every record after it is held until its own record is revised, including 951, 963 and 964, whose 947 edge is sequencing-only and exists for precisely that purpose. 949 independently re-reads the verdict and stops if it says RE-PLAN. Only 960, 969, 954, 961 and 962 do not wait on the verdict: they change no rule, and a view proves nothing. 948 is GATE TWO and has NO verdict as filed -- its output is a measured report plus a missing-rule list, each item either added there or named with a proposed follow-up description, and 952, 956 and 968 each take the rule set after it as their input. The first streams therefore END at 947. **One condition is not in the graph at all**: three pull requests from a collaborator are open against the files 960 moves, 960's IMPLEMENTATION must not be dispatched while #7 or #8 is open (research and planning may proceed), and 950, 954, 956 and 961 each carry a conditional scope depending on the answer. It is stated in full on the first proof-mode line below, where neither a dispatch nor a re-ordering of this list can clear it, and it is a statement rather than a status: no hold is set.

**Measured: all twenty-four proof-mode records declare a `file_scope`, and every one of their paths is now written in the family scheme, which changes what the admission gate can see and how these lines dispatch.** The `absent_file_scope` serialization that used to govern every proof-mode line applies to NONE of them: an implementation co-dispatch is admitted on scope overlap, not one record per cycle. Three kinds of shared file remain, and they SERIALIZE a line without ordering it -- the aggregators (`Tests/BimodalTest/Automation/ProofModeTest.lean`, `FormalSystem/Automation/ProofMode.lean`, `FormalSystem/Theorems/ProofMode.lean`), the guide index `docs/user-guide/derivation-proof-mode.md`, and the two ProofMode READMEs -- each edited one line at a time, with `FormalSystem/Automation/ProofMode/Meta.lean` a fourth such file across the scope and frame records. TWO records declare directories on purpose rather than coarsely, and they are exactly the two lines of one on this list: 960 names all four of `FormalSystem/Theorems/ProofMode/`, `FormalSystem/Automation/ProofMode/`, `Tests/BimodalTest/Automation/ProofMode/` and `docs/user-guide/proof-mode/`, because it rewrites the first two and CREATES the last two; and 952 names the first two, because it is the interface join that restates every pure rule and rewrites every elaborator. Every other proof-mode record declares at least one file inside those directories, so nothing may run beside either. The 178 adjacency is VISIBLE to the admission check instead of invisible: 947 declares `FormalSystem/Examples/ProofMode/Perpetuity.lean`, 948 declares `.../Temporal.lean` and 965 declares `.../Adoption.lean`, all under the `FormalSystem/Examples/` directory 178 declares. It remains ADJACENCY, not dependency -- neither record presupposes the other -- so no edge was filed.

**Unfiled observation -- the admission gate is blind on 17 of the 65 open non-terminal records, and no longer on a majority.** A `jq` count against live state measures 17 records carrying no `file_scope` key at all: 125, 231, 411, 412, 497, 498, 499, 500, 501, 502, 570, 604, 664, 713, 831, 890 and 935. The proof-mode programme has left that set entirely -- all twenty-four of its records declare one, the new views record included -- so the count held steady even as the number of open records rose. For each of the seventeen, the creation-time overlap check has nothing to compare and an implementation co-dispatch falls back to the `absent_file_scope` gate. Nine open records declare a whole DIRECTORY rather than paths, which is deliberate in three cases and coarse in the rest: 960's four ProofMode, test and guide directories and 952's two ProofMode directories are deliberate, as is 953's `FormalSystem/Automation/ProofMode/Instances/`; the coarse ones are 178's `FormalSystem/Examples/`, 177's `FormalSystem/Metalogic/Expressiveness/Kamp/` and `FormalSystem/Metalogic/Decidability/`, 257's `data/hf-dataset/`, 482's `FormalSystem/Metalogic/Decidability/Verified/Refutation/`, 875's `FormalSystem/Metalogic/Independence/`, and 876's `FormalSystem/OpenLanguage/`, which overlaps 869, 873, 874 and 962. This is an OBSERVATION only -- the remedy is a one-line `state.json` edit per record, no task is filed for it, and this pass did not invent one.

**761 cannot be advanced by any dispatch, and the graph can no longer say so.** All seven of its declared edges are terminal — including the `934` edge a prior pass added on the strength of Stage 0's own statement that 761's next revision takes the depth-`0` probe's verdict as its input, now archived with that record. Plan v13 came to rest at 30 of 41 phases closed with **zero enterable**: every remaining phase sits behind Phase 11.6's depth-`0` gate, which NO open record owns, so no dependency edge can express the blocker and none was invented to replace the one that aged out. Its own status rests at `PARTIAL`, which is all the record can now say. 934's verdict is in hand and is **existence evidence only**: `ForwardSlackWitnessed` is satisfiable at the consumer instantiation the five depth-`0` cell-equality schemas use, which is neither a discharge of the hypothesis nor a lift of the gate, and `certStabK`'s restatement obligation is unchanged. The gate's disposition remains a Stage 0 user ruling.

**761's live scope collisions.** The overlap is with 543 (`README.md`, `FormalSystem/README.md`, `FormalSystem.lean`), with 763/861/862 inside its own line, with 869 and 932 (`typst/generated/status.typ`, `docs/theorem-index.md`), and with 410 and 177. Shared territory serializes those lines against each other; it never breaks a batch.

**Edges: this pass added none, and said so rather than manufacturing one.** Four candidate pairs were examined and each rejected on the same ground -- the territory is shared but neither record presupposes the other, and co-membership in a batch is this list's own ordering judgment, never evidence of a graph gap. They were: the proof-mode programme against the just-completed test-coverage record (shared test directory), 947 and 948 against 178 (shared `FormalSystem/Examples/` directory), 604 against 257 (shared `data/README.md`), and 604 against the dataset clean-up line (shared `data/` tooling, but no record there presupposes the compression fix). The split of 960 off the head of the proof-mode programme is the same kind of judgment in the other direction: it rests on 960's measured directory-granular scope colliding with all eight pre-gate members, not on any edge, and no edge was filed to express it. Four cross-line edges DO run between the proof-mode lines, and each is an ORDERING CONSTRAINT rather than a gap: 953's edge on 962, which is why 962 sits on its own line early; 967's edge on 957, which is why 966 and 967 are batched WITH 956 and 957 instead of below them; the single edge every pre-gate member carries onto 960, which is why that line is named as this list's one out-of-line blocker rather than silently relied on; and the five edges 952 carries onto 948, 951, 963, 964 and 969 -- one from each post-gate line and one from the views tier on the pre-gate line -- which is why the join is a line of its own. The gate split at 947 additionally leaves 949, 951, 963 and 965 naming an out-of-batch blocker on purpose, so that a RE-PLAN verdict can still cancel them. Beyond those, the lines are independent and may be run in any order or interleaved, subject to the batch gate's live-lock rule; the order below is a priority judgment, not a dependency.

```
/orchestrate 604   # Restore the dataset readers the c7 zstd compression broke; the only runnable hygiene line
/orchestrate 960   # The operator-family layout every later record files into; held while PRs #7 and #8 are open
/orchestrate 969, 944, 945, 946, 955, 961, 954, 947   # All five pre-gate streams, views now among them, run up to 947's GO / RE-PLAN gate
/orchestrate 962   # Deduction theorems for Star and Open: no predecessors, off the gate, Open half demoted
/orchestrate 949, 950, 948   # The linear-time rules and gate two's measured report; enterable only on a GO verdict at 947
/orchestrate 951   # Frame coverage at Dense and RTime, held by the gate but needing nothing else from it
/orchestrate 963, 964   # The usability stream: nested intro patterns, then the goal display designed against them
/orchestrate 965   # Adoption after a GO verdict, pending the user ruling on what default means for the mode
/orchestrate 952   # The join: one class per family and per interaction, with nothing else editing ProofMode
/orchestrate 953   # The Minus instance and the per-language accounting, whose honest outcome may be a written reason
/orchestrate 956, 957, 966, 967   # Verification architecture: the liveness rules, the report that hinges it, and the two closers
/orchestrate 968   # The reference-manual chapter, written against the declaration names 952 leaves standing
/orchestrate 298, 282, 296, 231   # Half-finished dataset work: three PARTIAL records behind 298's c7 bug, plus 231's automation
/orchestrate 257   # Hugging Face migration for large datasets; externally blocked until the account token exists
/orchestrate 935 --hard --lit   # Route R3: does a determinization-free progress measure for L-plus ZTime completeness exist
/orchestrate 831 --research --lit   # The dense-time dichotomy gating L-R3, the only identified non-ZTime decidability route
/orchestrate 502, 497, 500, 543 --hard --lit   # The algebraic chain bottom-up to 543, the last high-priority L-plus metalogic task still open
/orchestrate 890, 570 --lit   # The two completeness-side records: the GHR94 erratum and the open C3 completeness question
/orchestrate 761, 862, 861 --hard --lit   # Ladder realization and its two dependents, parked behind a depth-0 gate no open task owns
/orchestrate 763 --hard --lit   # The lift to Decidable (PlusValidZTime phi); watch real_certStabK by name, not by discovery
/orchestrate 178   # The publication-quality Examples/ expansion; ready, and adjacent to the proof-mode modules
/orchestrate 664 --lit   # Corpus ingest of the Cmiel ball-space source the manuscript's def:frame footnote cites
/orchestrate 481 --hard   # The refuted UnorderedSuccessorLabelClosed residual; a register entry is a complete outcome
/orchestrate 428, 429, 410, 411 --hard   # The tableau spine's middle; needs 428's scope ruled, and 410 already carries a plan
/orchestrate 430, 412, 482 --hard --lit   # The tableau spine's terminus, ending at 482, classified open mathematics and multi-month
/orchestrate 498, 499 --hard   # The Jonsson-Tarski representation's two sides: complex algebra and ultrafilter frame
/orchestrate 125, 501 --hard   # The Jonsson-Tarski capstone and Until/Since on STSA, the representation front's terminus
/orchestrate 177   # README, docs/ and module-docstring polish; last in the mainline programme behind 27 edges
/orchestrate 869, 932   # Open-modal invariance and the IntNormalForm API behind it; 869's own gates are discharged
/orchestrate 873, 874, 875, 876   # The L-triangle syntax line: 873 runs first within the batch and gates the other three
```

Why this order:
- FIRST on the instruction to attend to repository hygiene before the proof-mode programme, and now the ONLY item on this list that is both genuinely clean-up and dispatchable at all. The test-coverage line that led this list when the pass began -- three `FormalSystem/` module groups with zero referencing tests anywhere under `Tests/` -- reached `completed` MID-PASS, in the concurrent session that held it, so it is retired from this list rather than reordered within it; that is also why nothing now precedes this line.

  Raised out of the examples/zstd pair it used to share a line with, because that pairing called it an additive format capability and its own record says something stronger: `data/bmlogic-c7.jsonl` was compressed to `data/bmlogic-c7.jsonl.zst` (17G -> 153M, lossless, sha256 of the decompressed stream verified identical), and CONSUMERS THAT HARDCODE THE UNCOMPRESSED PATH ARE CURRENTLY BROKEN. A repository with broken readers is the most literal hygiene finding available here, and unlike every other hygiene candidate it has no unmet predecessor: both its edges (631, 632) are archived and it sits in wave 1.

  Research-first by its own record: inventory every reader and writer of `.jsonl` datasets before changing any of them -- the Python validators and curators, the shell runners, the Lean executables, and the `path` fields in `data/*_metadata.json` -- then choose one shared `open_dataset()` helper handling both `.jsonl` and `.jsonl.zst` (and how that dependency is provided), and decide how the Lean executables reach compressed data given that Lean has no native zstd. Plain `.jsonl` must keep working, and every updated consumer is verified against the compressed file.

  Two stale-path traps annotated in its own description, worth re-deriving rather than trusting: `migrate_schema_v2.py` and `standardize_metadata.py` were DELETED by an archived predecessor, so drop them from the inventory step; and the Lean executables it names as `FormalSystem/Automation/*Main.lean` are now `BimodalTools/*Main.lean` with tests under `Tests/BimodalToolsTest/`, built by `lake build BimodalTools` rather than a default `lake build`.

  Alone on its line because it declares no `file_scope` of its own, so an implementation co-dispatch reaches it only through the `absent_file_scope` gate, which admits the lowest-numbered absent-scope candidate per cycle. Its reconciliation with 257 (the externally blocked Hugging Face migration) is a design question this task ANSWERS, not an edge: both reach `data/README.md`, 257 cannot run until a credential exists, and nothing here waits on it.
- **AN EXTERNAL CONDITION SITS ON THIS LINE AND NO DISPATCH CAN CLEAR IT.** Three pull requests from a collaborator are open against exactly the files 960 moves: #7 (checked logical rewriting `lrewrite` / `lsimp` and the congruence kit), #8 (Until/Since introduction, folding and ZTime unfolding, `linduction`, whole-judgment time reflection, `keeping`, strict leads-to rules) and #9 (a semantic mode, asked to be re-proposed separately). #7 and #8 edit the single guide, both ProofMode READMEs, `Meta.lean`, `Modal.lean` and `Temporal.lean`, add a shared test file, and overlap 950 and 956 in content as well. 960's own record is explicit: do NOT dispatch its IMPLEMENTATION while #7 or #8 is open -- run it after each is merged or declined, and move whatever they added into the same layout. RESEARCH AND PLANNING MAY PROCEED. Only the owner merging or declining those pull requests clears this; nothing on this list, and no re-ordering of it, can. It is recorded here as a condition on dispatch and NOT as a status: no hold is set on 960 or on any other proof-mode record.

  **Four later records carry a scope that depends on the same answer, each stated in its own record rather than guessed at dispatch time.** 950: if #8 has merged it already delivers Until/Since introduction, folding at every frame class and unfolding at ZTime, and `linduction` over the existing `futureBackwardInduction`; what REMAINS there is the general introduction form, the Until/Since induction rule `forwardInvariantRule` is an instance of, refiling the contributed rules into the family modules, and the Since, past-direction and TM-plus tests the contribution lacks. 954: #7 and #8 together add about 90 `throwError` sites with no message-asserting test, so the 65-site measurement in its own text goes stale and it must RE-MEASURE before backfilling. 956: #8 supplies `leadsToConsequence`, `leadsToTrans` and `progressCases` on the STRICT form, which does not settle the present-inclusive definition -- the strict rules become the layer underneath it and must not be proved a second time. 961: if #7 has merged, one nested logical rewrite joins the cost baseline, since composed congruence certificates are the terms most likely to be large and the contribution recorded no baseline of its own.

  IT IS A LINE OF ONE BY MEASUREMENT, NOT BY PREFERENCE. 960's `file_scope` names four paths at DIRECTORY granularity on purpose -- `FormalSystem/Theorems/ProofMode/`, `FormalSystem/Automation/ProofMode/`, `Tests/BimodalTest/Automation/ProofMode/` and `docs/user-guide/proof-mode/` -- because it rewrites the first two and CREATES the last two. Every other open proof-mode record declares at least one file inside one of those four, so nothing may run beside it, exactly as nothing may run beside 952 at the join. Raising it out of the pre-gate line also leaves that line at exactly `MAX_TASKS` rather than one over it, which is what the views record filed since the last pass made necessary.

  WHAT IT DOES, now the operator-family layout and no longer only a test-and-guide split. Every rule, tactic, test file and guide page is filed by the operators its statement names: the families Boolean, Modal, Stability (TM-plus) and Temporal; interactions as their own modules named for the families they join, Boolean included -- ModalBoolean, TemporalBoolean, ModalTemporal, ModalTemporalBoolean, StabilityModal; frame class as a suffix -- TemporalZTime, TemporalDense, TemporalRTime. One scheme used five times: pure-rule modules, tactic modules, test files, guide pages, and later the interface classes 952 extracts. The checkable filing criterion is that A PURE FAMILY MODULE CONTAINS NO IMPLICATION IN ANY STATEMENT -- scope introduction carries a context of box-facts to a box-conclusion and names no connective, where K names both and is therefore ModalBoolean, not Modal. DONE WHEN `lake build` and `lake test` pass with all 31 existing examples unchanged, no statement, proof or tactic behaviour has changed, every module name follows the scheme, and every open proof-mode record's `file_scope` names paths that exist or that the record will create: that last deliverable is why the file paths quoted anywhere on this list are the ones 960 produces.

  The architecture it implements is `records/proof-mode-architecture.md`; the milestones and gates are `records/proof-mode.md`. What the layout BUYS is worth keeping in view against the cost of more modules: a new operator family -- a counterfactual, a metric operator, a nominal -- adds its own pure module and class, its Boolean interaction, and one interaction per existing family it has a rule with, and changes no existing module, class, test file or guide page.
- THE PRE-GATE SET IS NINE RECORDS AND `MAX_TASKS` IS 8, so it is split -- and 960 is what came out, for the reason stated on the line above: its four directory-granular scope entries collide with all eight members here, so it could never have run beside them in any case. What remains is exactly `MAX_TASKS` wide and DEPENDENCY-INCLUSIVE but for one named out-of-line blocker, 960 immediately above. (955's second edge, 958, is already terminal -- which is also why `modal_search` is functional again rather than hard-failing on every bimodal goal.)

  Once 960 lands, the intra-line edges sequence these eight into FOUR waves: 944, 969, 955, 961 and 954 open together; then 945; then 946; then 947. That is what the live wave table shows (960 in wave 1, those five in wave 2, 945 in wave 3, 946 in wave 4, 947 in wave 5). Re-run the line until every member reports terminal.

  969 IS NEW ON THIS LINE AND IS THE PROGRAMME'S BOTTOM TIER. M16 adds the tactics that change only how a formula is WRITTEN: a fold and an unfold for every defined operator (negation, conjunction, disjunction, the biconditional, diamond, F, G, P, H, X, Y, always, sometimes, the inclusive and weak Until and Since forms, and the TM-plus counterparts), plus replacing a formula by one that is equal as a Lean term. A view uses DEFINITIONS AND FORMULA EQUALITIES ONLY -- no axiom, no derivation rule, no object context, no frame class -- leaves the judgment unchanged up to definitional equality or a cast, and can fail only because the formula has the wrong shape. It sits BELOW the derivation tactics and imports none of them, so a later semantic mode can use it too. It is pre-gate for the same reason 954 is: a view proves nothing, so the adequacy verdict cannot invalidate it. Two records are ordered AFTER it because both state rules about defined operators directly -- 946, where `sometimes` is the case in point, and 952, where views are deliberately outside every class. Its plan settles the tactic naming (one fold/unfold pair taking an operator name, or one tactic per view: open decision 1 of the architecture record) and where the tier lives.

  THE BOUNDARY THAT MAKES 969 WORTH A RECORD OF ITS OWN. Unfolding `diamond A` to `not box not A`, or an inclusive Until to its strict form, changes no content and can fail only on the wrong shape. Replacing `A` by `B` under `box` because `box (A iff B)` is derivable USES MODAL K, needs evidence that survives the scope, and respects polarity. The first is a view; the second is derivation-tier logical rewriting under a different tactic name. That second half is M17, which has NO filed record -- it is the contributed `lrewrite` / `lsimp` work in pull request #7, under review -- and whether its tactics may be used in the gate-one scripts is an open decision of the architecture record, not something this list can settle. 969's own text says to EXTRACT the views already buried inside #7 and #8 if they merge rather than write a second copy.

  THIS LINE STOPS AT 947 BECAUSE 947 IS A GATE, NOT A MILESTONE. GO requires the proof-mode scripts to be shorter in aggregate and for a clear majority of declarations, with no declaration needing a raw term-mode escape longer than its original; otherwise the verdict is RE-PLAN, the report at `docs/development/proof-mode-adequacy-perpetuity.md` recommends how each later record should change, and the work stops for user review so that nothing downstream is dispatched on an unrevised plan. Batching anything after 947 into this line would be scheduling exactly the work the gate exists to be able to cancel; on RE-PLAN the next action is `/revise` against the report's per-record recommendations, not the next line.

  THE OTHER FOUR STREAMS, WITH THEIR TRAPS. (1) The bimodal scope core 944 -> 945 -> 946, each extending the scope rules the one before adds. 944 makes a box scope S5-aware, carrying `box A` and `diamond A` into the body -- the axiom `modal_5_collapse` is `diamond box A -> box A`, NOT 5, so `diamond A -> box diamond A` must be DERIVED -- with STRIPPING kept as the default so existing scripts keep their meaning. 945 lets box hypotheses cross into G and H scopes by MF and derived TF, used nowhere in the mode today. 946 adds the always/sometimes scope rules and the P1-P6 acceptance scripts, and carries the trap that explains its new edge: `sometimes` is DEFINED as a negation, not a disjunction, so operator matching sees a negation and the `P or phi or F phi` form must be proved as a pure rule first -- which is exactly the kind of step the views tier owns. (2) 955, the leaf closer: `propDecide`, reflective and kernel-`decide`-only, which must first discharge the goal's object assumptions into implications because it proves closed theorems and weakens; `modal_search` is admissible ONLY as a bounded fallback for single-modality leaves, never as the default, and `native_decide` is forbidden. (3) 961, trust and cost: an axiom-set assertion per tactic family in TM and TM-plus on the pattern of `Tests/BimodalTest/WalkthroughAxioms.lean`, plus a recorded derivation-size and elaboration-time baseline with the command that reproduces it, now reported PER TIER (views, derivation). Its edge into 947 is sequencing-only and exists so the gate report can QUOTE a cost figure rather than assert one. (4) 954, error-message coverage: a `#guard_msgs` negative test for every `throwError` site in `FormalSystem/Automation/ProofMode/`, or a listing as unreachable with a reason, plus a check that fails when a site is added without a test. It is pre-gate deliberately -- it tests the tactics as merged and changes no rule -- and once its check is in, every later record covers its own error sites as it adds them.

  Two integrity constraints run through the whole line and are what keep the gate from being self-confirming: no pure rule may restate one of P1-P6 or exist only to make one of them a one-liner, and no script may cite anything in `FormalSystem/Theorems/Perpetuity/`. That second constraint is also why 944 and 945 are forbidden from importing it -- `modal5`, `boxToPast` and friends are precisely the lemmas 947 re-proves. `Theorems/` must not import `Automation/`, and every tactic must assemble native `DerivationTree` / `PlusDerivationTree` constructors and proved rules only; nothing semantic may stand in for a derivation.

  SCHEDULING. Every member declares a `file_scope`, so the `absent_file_scope` serialization does not apply to this line at all. What remains is ordinary overlap on the shared files `records/proof-mode.md` names -- the aggregators `Tests/BimodalTest/Automation/ProofModeTest.lean`, `FormalSystem/Automation/ProofMode.lean` and `FormalSystem/Theorems/ProofMode.lean`, the guide index `docs/user-guide/derivation-proof-mode.md`, the two ProofMode READMEs, and `FormalSystem/Automation/ProofMode/Meta.lean`, which 944, 945 and 969's neighbours all touch -- each edited one line at a time, which SERIALIZES implementation without ordering it. Research and planning are not serialized. The 178 adjacency is visible to the admission check: 947 declares `FormalSystem/Examples/ProofMode/Perpetuity.lean`, under the `FormalSystem/Examples/` directory 178 declares; that is shared territory with neither record presupposing the other, so no edge is warranted.
- ON ITS OWN LINE BECAUSE IT SITS OUTSIDE THE PROGRAMME'S SPINE ENTIRELY. 962 is M9b: a proved deduction theorem, generalized K and context substitution for each of the Star and Open calculi, OR a written reason why it cannot be had. It carries NO predecessor -- it is metatheory about two calculi and needs no interface, no scope rule and no gate verdict -- and nothing depends on it except 953, whose language accounting cites either its theorem or its written obstruction. It is in wave 1 of the live graph alongside 960.

  It is placed here rather than raised above the pre-gate line for one reason stated plainly: its OPEN half falls under the standing 2026-11-05 ruling that places the L-triangle line behind L-plus critical-path work, so it is kept and visible but not dispatched ahead of the rule set the gate measures. Its Star half carries no such demotion and could be taken at any time.

  It collides with nothing. Its `file_scope` is `FormalSystem/StarLanguage/StarDeduction.lean`, `FormalSystem/OpenLanguage/OpenDeduction.lean`, the two language aggregators and their READMEs -- no ProofMode file, no test aggregator, no guide index -- so it can run beside any other line on this list, including the pre-gate line above. Note the live overlap with 876, which declares `FormalSystem/OpenLanguage/` at directory granularity: that serializes the two, it does not order them, and no edge is warranted in either direction.

  Schedule it expecting a WRITTEN REASON as a legitimate terminal outcome for either calculus. A deduction theorem that cannot be proved for a calculus is a result about that calculus, not a failed task.
- ENTERABLE ONLY ON A GO VERDICT AT 947, which is why this is a separate line rather than the tail of the one above. 949's own record instructs it to read `docs/development/proof-mode-adequacy-perpetuity.md` FIRST and, if the verdict is RE-PLAN, to stop and report instead of implementing. On RE-PLAN the correct next action is `/revise` against the gate's per-record recommendations, not this line.

  **950's SCOPE IS CONDITIONAL ON PULL REQUEST #8, and the condition is not in the graph.** If #8 has merged it already delivers Until/Since introduction (`untilIntro`, `sinceIntro`), folding at every frame class and unfolding at ZTime -- that split is to be adopted in place of the single ZTime equivalence 950's own text asks for -- and `linduction`, which exposes the backward-induction rule the library already had (`futureBackwardInduction`). What then REMAINS here is the general introduction form from `untl chi psi` and `G(chi -> phi)`; the Until/Since induction rule of which `forwardInvariantRule` is an instance, with `linvariant` expressed through it, which backward induction is NOT; refiling the contributed rules into the family modules; and tests for every Since form, the past direction and TM-plus, which the contribution lacks. If #8 has not merged, the deliverable is as its own text states. Either way 960 must have moved the files first.

  The three members are the chain 949 -> 950 -> 948 and they are the temporal half of the rule set whose perpetuity half the pre-gate line reached. 949 opens TL's and CN's three ordered cases from two eventualities or two Until/Since facts, in `TemporalLinearity.lean` and its `Plus` copy, and must PERMUTE `tempLinearity`'s disjuncts into CN's order (together, first earlier, second earlier) rather than exposing TL's own different order to the user. 950 works in `Temporal.lean` and `TemporalZTime.lean` with their `Plus` copies and the two matching elaborator modules: Until/Since introduction, one-step ZTime unfolding -- lifted along a `ZTime <= fc` certificate the way `lstep` does, because the unfolding theorems are stated at the fixed class with no `...At` variant -- and the induction rule of which the existing `forwardInvariantRule` is the special case. Whether the linearity case split is actually NEEDED for that induction rule is an OPEN DECISION in `records/proof-mode.md`: introduction and unfolding provably do not need it (`left_mono_until_G`, `unfoldForward`, `unfoldBackward` and `unfoldBackwardSince` take no linearity premise), and the question is settled the moment 950's plan states the induction rule's formula. State the formula before proving anything.

  948 is GATE TWO, and it has NO VERDICT as filed. Its output is a measured report plus a missing-rule list, each item either added there or named with a proposed follow-up description; 952, 956 and 968 each take the rule set after it as their input. The slice is fixed IN ADVANCE so it cannot be chosen for ease: at least four declarations from each of `FormalSystem/Theorems/TemporalDerived.lean`, `ConnectDerived.lean` and `LinearityDerived.lean`, including `tempLinearity`, with the chosen list stated in the plan and no script citing the declaration it re-proves. Do not let the missing-rule list land without a declared consumer for each item.

  The 178 adjacency is VISIBLE to the admission check rather than invisible: 948 declares `FormalSystem/Examples/ProofMode/Temporal.lean`, under the `FormalSystem/Examples/` directory 178 declares at directory granularity (as 947 does with `.../Perpetuity.lean`). That is shared territory with NEITHER record presupposing the other, so no edge was filed and none is warranted; it serializes the two lines against each other and nothing more.
- ALONE, AND INTERLEAVABLE WITH THE LINE ABOVE. M7 has NO hard dependency: `density` takes `Dense <= fc`, `coDerived` takes `RTime <= fc`, `prior_U_gap` and `sep` are axiom constructors at RTime, and the certificate pattern is the one `lstep` already has. Its only edge, onto 947, is SEQUENCING-ONLY and was filed for a single reason -- so that a RE-PLAN verdict can hold a record that adds new tactics. Nothing in its deliverable uses an Until or Since rule from the linear-time line or anything from the usability line, so on a GO verdict it runs beside both.

  Its territory confirms that, in the names 960 produces: the pure rules in `FormalSystem/Theorems/ProofMode/{TemporalDense,PlusTemporalDense,TemporalRTime,PlusTemporalRTime}.lean`, the elaborators in `FormalSystem/Automation/ProofMode/{TemporalDense,TemporalRTime}.lean`, and `Tests/BimodalTest/Automation/ProofMode/{TemporalDenseTest,TemporalRTimeTest}.lean` with a guide page each. Those are disjoint from 949's `TemporalLinearity` files, from 950's `Temporal` and `TemporalZTime` files, and from 963/964's `Boolean` and `Display` files. The overlap is confined to `FormalSystem/Automation/ProofMode/Meta.lean`, the aggregators and the two READMEs, which serialize rather than order.

  Deliverable: DN at Dense, and PU, SEP and CO at RTime, each with a pure rule and a tactic whose frame certificate is SOLVED when reflexive and otherwise surfaced as an ordinary Lean goal, tested at a concrete and at an abstract frame class in TM and TM-plus. The frame class is a SUFFIX on the family in the architecture's scheme, not a family of its own, which is why these rules sit in `Temporal`-prefixed modules and take their certificate as an explicit premise.

  One filed POSITION worth knowing, reversible by changing one edge: 951 runs BEFORE 952, which means its rules are written twice (TM and TM-plus) and 952 then removes the copies. The exchange is an interface designed having seen a Dense and an RTime rule. The alternative -- writing these rules once over the interface -- is a real option, not an oversight, and it is a user call, not this list's.
- ONE STREAM, TWO RECORDS, STACKED. Neither has a hard dependency -- both work on the elaborators as they stand -- and both are held by gate one for the same reason 951 is: they add tactic behaviour a RE-PLAN verdict could change. 963 additionally carries a 954 edge, which is the one edge in this pair that does real work: the error-coverage check from the pre-gate line is what 963's new error sites must pass, so the check lands before the sites do. 964 then carries 963, stacked in the same stream and designed against the scripts gate one's module actually produces rather than against invented ones.

  963 lets `lcases` and `lintro` take nested patterns, with tests and a guide section. 964's deliverable carries the constraint that makes it worth filing separately: a goal view may elide a hypothesis's object context ONLY when it EQUALS the goal's context, and must keep a differing context visibly marked -- a differing context is exactly what makes `lexact`/`lapply` reject a hypothesis inside a new scope, so eliding it would hide the one fact a user needs to debug the rejection.

  Territory, in the names 960 produces: 963 declares `Boolean.lean`, `Meta.lean`, `BooleanTest.lean` and `ErrorTest.lean`; 964 declares `Display.lean`, `DisplayTest.lean` and `docs/user-guide/proof-mode/display.md`. They share only the `FormalSystem/Automation/ProofMode.lean` aggregator, the guide index and the Automation README -- edited one line at a time, which serializes the pair rather than breaking it. Both feed 952, which rewrites every elaborator they touch, so neither may be left open when the join is dispatched.
- ALONE, AND BLOCKED ON A RULING NO DISPATCH SUPPLIES. M12's only hard dependency is gate one with a GO verdict -- it carries no rule-set dependency at all, so it opens the moment the verdict lands and is NOT held behind the linear-time, frame or usability work. That is why it is a line of its own and not the tail of any of them.

  What it does need first is OPEN DECISION 2 in `records/proof-mode.md`: what "default" means. Three candidates are on the table and they are materially different pieces of work -- new example and case-study modules MUST use the mode; or new derived theorems get a proof-mode companion under `FormalSystem/Examples/`; or the mode stays OPTIONAL and this record only fixes where proof-mode proofs live. The constraint any ruling must respect is the layer order: proofs under `FormalSystem/Theorems/` CANNOT be written in the mode, so "default everywhere" is not among the options. Dispatching this record before the ruling lands means guessing the deliverable.

  Its done-when is otherwise concrete: the guide states where proof-mode proofs live and which kinds of new derivation are to be written in the mode, and at least one module OUTSIDE the tests and the two adequacy modules is proved in the mode. Its territory (`docs/user-guide/derivation-proof-mode.md`, `FormalSystem/Examples/ProofMode/Adoption.lean`, `FormalSystem/Examples.lean`, `FormalSystem/Examples/README.md`) overlaps 947 and 948 under `FormalSystem/Examples/` and 178's directory declaration, which serializes it against those lines without ordering it further.
- THE JOIN, AND THE SERIALIZATION POINT OF THE WHOLE PROGRAMME. 952 carries FIVE edges, one from each line that feeds it -- 948, 951, 963 and 964 from the post-gate lines, and 969 from the views tier on the pre-gate line -- which is a faithful rendering of what M8 is: the single point where the streams meet. Today every rule exists once for TM and once for TM-plus (about 620 lines of copies under `FormalSystem/Theorems/ProofMode/Plus*.lean`) with the elaborators dispatching through hard-coded name pairs.

  THE INTERFACE SHAPE IS NOW FIXED BY `records/proof-mode-architecture.md` AND IT IS NOT ONE CLASS. It is ONE CLASS PER OPERATOR FAMILY carrying that family's pure rules (Boolean, Modal, Stability, Temporal) and ONE CLASS PER INTERACTION extending exactly the families it joins (ModalBoolean, TemporalBoolean, ModalTemporal, ModalTemporalBoolean, StabilityModal), with frame-specific rules taking their certificate as a premise and each class also carrying its operators' congruence steps for logical rewriting. A language is an instance of the classes for the operators it HAS: TM has no Stability instance, and a later language extension adds a family class and the interaction classes it needs without touching an existing one. The truth-clause classes on the semantic side, one per operator, are the model for this. VIEWS ARE OUTSIDE EVERY CLASS -- they come from 969, which is why that edge exists. Equally explicit and unchanged: a META-LEVEL REGISTRY OF NAME PAIRS DOES NOT SATISFY THIS RECORD, the classes are object-level over the formula type and its derivation family with the instance resolved from the goal, and the interface is extracted from the rule set AS IT STANDS AFTER THE ADEQUACY TESTS rather than designed ahead of them. That is why it sits below both gates instead of being hoisted up as foundational refactoring, and why language-specific capabilities (the TM-only leaf closer, TM-plus stability scopes) belong in optional members or separate classes, never as exceptions written back into elaborators. If pull request #7 has merged, its `Kit` and `Step` structures in `Congruence.lean` are already generic over the language and then instantiated twice and selected by name pairs: make them fields of these classes and delete the pairs.

  IT IS ALONE ON ITS LINE BY MEASUREMENT, NOT PREFERENCE. 952 declares BOTH `FormalSystem/Theorems/ProofMode/` and `FormalSystem/Automation/ProofMode/` at DIRECTORY granularity, and it does so on purpose: it restates every pure rule and rewrites every elaborator, so nothing that edits either directory may run beside it. Every other open proof-mode record declares at least one file under one of those two. Batching anything with it would be declaring a collision, and placing a later record on the same line would have it wait anyway. 960 is the only other record on this list with the same property, which is why that one is a line of one too.

  One ruling is better taken before this record than discovered inside it: where the Minus instance lives. Its deduction theorem is `FormalSystem/Metalogic/Conservativity/MinusDeduction.lean` at layer 3 and imports only the Minus derivation module, so either the instance sits at layer 3 or that module moves down -- and that bears directly on how the interface is laid out here, not only on 953 where it surfaces.
- FIRST OF THE FOUR LINES THE JOIN OPENS. M9a gives the Minus calculus a proof-mode instance with acceptance tests, and accounts for EVERY directory matching `FormalSystem/*Language/` in the guide -- by an instance or by a stated reason. It is the record where the programme says what it does NOT cover, which is why it must not be scheduled as uniformly implementation.

  Its two edges are both load-bearing. On 952, because an instance is an instance OF the interface. On 962, because the Star and Open rows of the accounting cite either 962's proved deduction theorem or 962's written obstruction -- that edge is the whole reason 962 sits on its own line early rather than here. Hybrid, Nomic, Quant and Source have no derivation calculus at all and get one line each saying so; Minus already has a deduction theorem and is the expected first instance.

  The layer problem is real and is OPEN DECISION 3: `MinusDeduction.lean` lives at layer 3 under `FormalSystem/Metalogic/Conservativity/`, so the instance cannot sit under `FormalSystem/Theorems/` the way the TM and TM-plus rules do -- either it sits at layer 3 or that module moves down. The record declares `FormalSystem/Automation/ProofMode/Instances/` for its own code, which overlaps 952's directory declaration and so stays strictly after it.

  Expect a WRITTEN REASON rather than code for at least some languages, and do not expand this record to close a gap it only names: the instruction in its own record is to record the reason in the user guide and propose a follow-up task.
- FOUR MEMBERS, TWO KINDS OF DELIVERABLE, AND 957 IS THE HINGE -- which is exactly why 966 and 967 are batched HERE rather than on a line of their own. 967's hard dependency is M11, whose report fixes the division of labour with the ModelChecker, and its sequencing dependency is M14a so that an unclosed leaf is measured against the FULL closer. Splitting 966 -> 967 onto a separate line would name 967 without its out-of-batch blocker 957, which is dead weight by this list's own rule. Batched together, the intra-batch edges sequence cleanly: 956 and 966 open at once, then 957, then 967.

  956 is Lean work: extend `lprogress` and `linvariant` to the standard TLA/UNITY safety and liveness set -- invariance, leads-to transitivity and disjunction, well-founded progress -- each as a pure rule with a tactic for TM and TM-plus, filed under the Temporal-with-Boolean interaction for leads-to (its statement is an implication under a temporal operator) and under Temporal at ZTime for invariance and progress, with the user-facing tactic family and guide page named liveness. Two definitional points must be settled IN THE PLAN before any rule is proved, and both are traps rather than formalities. (1) G and F are STRICT here, so the existing `G(A -> F B)` is irreflexive and says nothing about the present, which makes standard rules such as leads-to reflexivity simply FALSE for it; leads-to must be defined as a named abbreviation over PRESENT-INCLUSIVE operators -- a view, supplied by 969 -- stated explicitly, and related to the strict form `lprogress` uses. (2) The object language has NO QUANTIFIERS, so well-founded progress is the FINITE-family lattice rule -- a metalevel induction over a `Fin n` or list-indexed family with a finite disjunction -- not an ordinal-indexed schema. **956's scope is also conditional on pull request #8**: if it has merged it supplies `leadsToConsequence`, `leadsToTrans` and `progressCases` on the strict form, those become the layer underneath the present-inclusive definition, and no second copy of them may be proved here.

  957 is research, no Lean required, and its single deliverable is the report `docs/development/proof-mode-transition-systems.md`: how a transition system is presented as a TM theory or model, which proof-mode rules carry the safety and liveness arguments, what the Veil integration the user guide names as separate work would involve, and the division of labour with the ModelChecker -- countermodels from one side, derivations from the other. It must end with a recommended architecture, the smallest worthwhile first case study, and proposed descriptions for the work that follows. It reads 956's output as its premise, so it cannot be drafted ahead of the rules it assesses.

  966 extends the leaf closer with the proved decision procedures, and its FIRST half is research, not implementation: establish WHICH procedures under `FormalSystem/Metalogic/Decidability/` return a DERIVATION and not merely a validity verdict. For each that does, the closer uses it and yields a native derivation, with tests and no `native_decide`. Completeness of proof extraction is NOT a prerequisite -- a closer may fail, and that is a permitted outcome. 967 then exports a failed leaf in a form the ModelChecker accepts and reports the countermodel against the leaf. A COUNTERMODEL IS A DIAGNOSTIC; it never closes a goal, and nothing in 967 may be built as if it could.

  Budget the four members unevenly: 957 is a report, 966 is half research, 956 and 967 are Lean. Re-run the line until all four report terminal.
- LAST, AND LAST FOR A CHECKABLE REASON RATHER THAN BY DEFAULT. M15's hard dependency is gate two (948): the chapter documents the rule set as it stands after BOTH gates. Its other edge, onto 952, is sequencing-only and is the one that fixes its position here -- 952 deletes the TM-plus rule copies and restates every rule over the interface, and a chapter grounded in declaration names must be written against the names that REMAIN. Writing it earlier guarantees rewriting it.

  It is the only `typst` record in the programme and must not be budgeted as Lean work. Deliverable: a chapter under `typst/` stating the rules the tactics implement and the scope-safety guarantee, which compiles and passes the chapter-quality check (`bash .claude/scripts/chapter-quality-check.sh --verbose`). Its `file_scope` -- `typst/chapters/p4-proof-mode.typ`, `typst/BimodalReference.typ`, `typst/SYNC-MAP.md`, `typst/chapters/README.md` -- shares no file with any other open proof-mode record, so it collides with nothing and can run beside 953 or the verification-architecture line once both its edges are discharged. It is placed below them on priority, not on dependency.
- DEMOTED BELOW THE PROOF-MODE PROGRAMME, and the demotion is the honest reading of the hygiene instruction rather than a departure from it. This is the largest body of half-finished work in the tree -- 298, 282 and 296 all rest at PARTIAL -- so it is clean-up in the most literal sense available on this list. But it is NOT repository hygiene that can be cleared BEFORE the proof-mode work, and placing it there would stall that work indefinitely for no hygiene gain. 298's phases 1-3 are genuinely complete and committed (the code fix landed, build green) and its residual is ENVIRONMENTAL rather than a defect: `dataset_generator` needs a full native compile -- 410 Lean-generated `.c` files, with `Formula.c` and `FormulaEnumerator.c` each around 45 minutes at 2-7GB clang RSS -- before the c7 regeneration run can produce its 77,272 records, and the toolchain has since moved to v4.33.0-rc1, so any prior compile state is stale. 282's remaining path then runs through the deferred c9 feasibility probe and, only on a GO verdict AND explicit user approval for the multi-hour compute, c8/c9 exhaustive regeneration and republication -- an approval this line cannot take for itself. A multi-hour compile campaign plus a pending user compute decision is not a precondition anything else should wait behind, so it sits here instead, startable in parallel: it shares no file territory with any proof-mode record and no edge runs between them.

  Correctly headed by its blocker: 282, 296 and 231 each carry a 298 edge, so the intra-batch edges sequence the line into successive waves rather than disqualifying any member. Do NOT restore the plan-era `IO.cancel` design; a stronger cooperative `abortRef` superseded it.

  Every path in these records' plans and handoffs that names a tooling module is STALE: the 25 tooling modules moved from `FormalSystem/Automation/` to the root-level `BimodalTools` lean_lib, namespace `BimodalTools`, with tests under `Tests/BimodalToolsTest/`. Re-derive paths before resuming rather than trusting a recorded one. 296 is the one member with no compute gate of its own -- re-adding the six derived binary temporal operators so they survive deduplication, where the four candidate approaches are recorded in the task -- but it carries a 298 edge and follows it regardless.

  231 is priority `high` and declares no `file_scope`, so an implementation co-dispatch reaches it only through the `absent_file_scope` gate, which admits the lowest-numbered candidate per cycle. That is an ORDERING CONSTRAINT, not an exclusion. Re-run the line until all four members report terminal.
- Alone on its line and genuinely not dispatchable yet: the blocker is an external credential, not an in-repo predecessor, so no dependency edge can express it and no batch member can clear it. Raised to sit with the dataset family it belongs to, because under a hygiene-first instruction it is worth naming rather than burying -- it is one of three hygiene items this ordering cannot reach by reordering, and the ONLY one the owner can clear directly. Supplying the Hugging Face account token is the whole of what stands between this record and an ordinary dispatch; prior work already removed the Git LFS tracking and repointed `data/README.md` at the Hub, leaving only the upload itself, its validation, and the `PUBLISHING.md` status header. It and 604 above both reach `data/README.md`, which is adjacency, not an edge in either direction: 604 answers the on-disk format question independently of where the data is hosted.
- The completeness front's only substantive live item, and the reason that front is no longer exhausted by ruling: the completeness-line reopen decision record's Reopening Terms table left R3 open on stated terms, and this is the task filed on them. Verdict-first and paper-only -- a verdict plus grounds, and on a positive verdict a DESIGN, never a theorem and never a Lean declaration; a negative verdict is a COMPLETE outcome, not a failure. Flagged `--hard --lit` because the question is open mathematics resting on read sources (the determinization construction of record is the appearance-record route, Thomas 1997 section 6.1 Theorem 6.5 with Remark 6.6) rather than on anything in this tree. Three standing limits it is scheduled under, not against: R1 (`Muller.toRabin_exists`) stays KEEP CLOSED and no task is filed against it in this repository; Recommendation 8 still bars a Lean filing of the engine's sections 7-15 whatever this task designs, reversible only by the user; and `FILE SCOPE: none` is structural, so it contends with no live line's territory and cannot collide with the ladder line, the final-frame tasks or the algebraic chain. NO dependency edge was filed onto 931 despite the shared report: the record states explicitly that it collides with the final-frame tasks by construction, and what it reads as premise is the architecture and section 15.2's Saturation assessment, neither of which 931 touches. Its `R3` is the reopen record's label and is NOT 831's `L-R3`, a decidability route; the two are unrelated and must not be conflated.
- Verdict-first research, deliberately alone on its line: the deliverable is a verdict plus grounds, not a landed theorem, and it must not be budgeted as a routine task. Every landed and in-flight decidability result in this tree is ZTime-shaped; L-R3 is the only identified route to Base/Dense/RTime, where r.e.-ness itself is still open and Craig remains the only instrument. It sits directly below the two fronts because it is the decidability front's only other live direction. `L-R3` here is the 721 review's followup-scope-spec label for that route and is NOT the completeness-line reopen record's `R3`, which 935 owns -- the labels collide by accident and name unrelated questions. Off the tableau spine by its own record: it is not to be folded into 428/429/430/412/482, and not scheduled as a substitute for the ladder line, which it does not advance. The gate's absence from `FormalSystem/` is a filing-time measurement to re-confirm before anything is written; if a declaration has since appeared, the task's premise is stale and it stops.
- 543 is reachable ONLY through the edge chain 502 -> 497 -> 500 -> 543, and its first three links are all priority `low`, which is exactly why 543 -- priority `high` -- has never been scheduled on its own. Batching the chain is the only way the high-priority terminus is ever dispatched; the intra-batch edges sequence it into successive waves rather than disqualifying any member. Kept high among the mathematics fronts because 543 is L-plus metalogic, which is what this ordering prioritizes once the hygiene and proof-mode lines above it are accounted for. Note the live territory overlap with 761 (`README.md`, `FormalSystem/README.md`, `FormalSystem.lean`): that serializes the two lines against each other, it does not break either.
- Grouped because both are completeness-side metalogic records that touch no Lean, and placed above the off-critical-path lines below on that subject rather than on their size. 890 is already `researched` and needs only the GHR94 Lemma 10.2.3 Case 5 erratum written into the Typst reference manual. 570 is an OPEN RESEARCH QUESTION, not an implementation task -- whether the logic of C3 equals Burgess-Xu without unboundedness plus S5 -- where only the containment is established and the completeness claim was explicitly declined; its honest terminal outcome is a recorded verdict, not a theorem.
- Parked, and no dispatch can change that. Plan v13 came to rest at 30 of 41 phases closed with ZERO enterable: every remaining phase sits behind Phase 11.6's depth-`0` gate, whose disposition is a Stage 0 user ruling. All seven of 761's declared edges are now terminal -- including the `934` edge a prior pass added on the strength of Stage 0's own statement that 761's next revision takes the depth-`0` probe's verdict as its input -- so the dependency graph no longer carries the blocker, and no edge was invented to replace it, because no OPEN task owns the gate. 934's verdict is in hand and is EXISTENCE EVIDENCE ONLY: `ForwardSlackWitnessed` is satisfiable at the consumer instantiation the five depth-`0` schemas use, which is neither a discharge of the hypothesis nor a lift of the gate, and `certStabK`'s restatement obligation is unchanged. What 761 waits on is therefore a `/revise` taking that verdict as input, behind the ruling. 862 and 861 stay batched WITH 761 rather than after it, because their edge is on 761 reaching TERMINAL and a dependent named without its out-of-batch blocker is dead weight; both are already `researched`. The line is kept on the list rather than retired so the parked front stays visible.
- Kept on its own line rather than folded into the batch above, because it needs not merely 761 terminal but the whole chain above it closed. The (S) scope question it used to turn on is SETTLED: the assignment to requirement (W) is confirmed sufficient and no extension task is filed (user ruling, 2026-11-14), so what 763 inherits is a verified premise. The one thing to watch there is `real_certStabK` by name -- five of `certAdmK`'s six conditions are discharged by `real_certLocK`, `real_certBiInfK`, `real_certFwdK`, `real_certBwdK` and `real_certBoxK` in `LadderRealize.lean`, and `real_certStabK` exists nowhere in the tree. `Decidable (PlusValidZTime phi)` is stated nowhere yet.
- Now alone on its line: the zstd dataset task it used to share a line with has been raised into the hygiene front above, on the grounds that its consumers are currently broken rather than merely unextended, and 178 has no such urgency of its own. It is priority `high` and `ready` -- both its edges archived -- and its deliverable is the publication-quality `Examples/` expansion.

  One adjacency to state, because the admission gate cannot see it: 178 declares `FormalSystem/Examples/` at DIRECTORY granularity, and the proof-mode programme's two adequacy tests add `FormalSystem/Examples/ProofMode/Perpetuity.lean` (947) and `.../Temporal.lean` (948) underneath it, while declaring no `file_scope` at all. That is shared territory with NEITHER record presupposing the other -- 178's expansion does not need the proof-mode examples to exist, and the adequacy tests do not need 178's expansion -- so no edge was filed and none is warranted. The one edge that does exist here runs the other way: 177 already depends on 178, the two sharing `FormalSystem/Examples/TemporalStructures.lean`, so the documentation sweep stays ordered after it.
- Literature-shaped and touching no Lean. It closes a measured corpus gap: the manuscript's `def:frame` footnote cites Cmiel2021 for the ball-space claim, and no matching entry exists in the global index or the sub-index. It is a corpus acquisition rather than a research question, which is why it is not grouped with 570 despite both carrying `--lit`.
- Classified genuinely open -- the predicate is refuted as stated -- so the honest terminal outcome is a register entry recording the refutation, not a discharge. Scheduling it expecting a proof is the failure mode this line exists to prevent.
- The whole Track A/Track B tableau spine is priority `low` and off both critical paths, which is why it sits below the L-plus work despite its size. Dependency-inclusive: 428 is `blocked` and heads the chain it gates (429 -> 410 -> 411). Ruling on 428's scope is an open Stage 0 item -- its one edge is discharged and its `blockers` says "paused at 4/5 cycles, NOT blocked" -- so this line is not enterable as filed until that ruling lands.
- Separated from the spine's middle because its terminus is a different kind of work: 482 is classified OPEN MATHEMATICS on a multi-month horizon and must not be scheduled as routine implementation. It is also, quietly, the reason the documentation sweep at 177 cannot be treated as reachable hygiene: 177 carries an edge on 482, so a multi-month open-mathematics question sits between the hygiene instruction and that record.
- Both hang off 497, which the chain-to-543 batch above already carries, so this line is placed after it rather than duplicating 497. 499 is flagged HARD in its own record.
- 125 is the capstone, reachable only once 498 and 499 both land; 501 extends STSA with Until/Since behind it.
- Carries 27 declared edges, more than any other record in the tree, and is a documentation sweep whose value depends entirely on the work it documents having landed. Running it early guarantees re-running it.

  It is the ONE hygiene item the instruction this pass was run on cannot be honoured for by reordering, which is worth stating plainly rather than hiding by placing it up top as though it could run. It is genuinely hygiene -- README, `docs/` and module-docstring drift -- and it is genuinely unreachable: ten of its declared predecessors are still non-terminal (178, 282, 296, 298, 428, 429, 430, 481, 482, 543), and one of them, 482, is classified by its own record as open mathematics on a multi-month horizon. Its test-coverage edge discharged mid-pass, which moved the count without moving the verdict. Raising it would not reach its findings either, because the edges are what make a FINAL sweep worth running at all; a sweep run now is a sweep that must be re-run.

  The concrete parked finding: the repo-health review folded a LIVE README.md hygiene item into this record's description rather than filing a task for it, on the grounds that 177 already declares README.md in its `file_scope`. The Project Structure diagram at `README.md:103-138` omits `ForMathlib/`, `NomicLanguage/` and `Tactic/`, all three of which exist on disk, and the fix is to re-render that tree from the filesystem rather than hand-patch three lines. Closing it sooner would need its own small task, which this pass did not file. ORGANISATION.md is NOT stale on the same point.

  One trap in this record's own `file_scope`: it declares `specs/ROADMAP.md`, whose run-order section is GENERATED from `roadmap_batches` by `scripts/roadmap-integration.sh`. A hand edit inside that section is overwritten by the next regeneration; only the authored prose outside it is editable by this task.

  It is last in the MAINLINE programme; the two L-triangle lines below it sit lower only by the standing 2026-11-05 demotion ruling, not because they gate it or it them.
- 869's `743` and `898` edges are both archived, so it is `ready`. 932 joins it rather than sitting uncovered: it carries an `869` edge and is a frame-presentation API refactor in `IntNormalForm.lean` whose five declarations and one equation lemma are transcribed verbatim in 927's report, all six already elaborated sorry-free. Dependency-inclusive. Demoted beneath every L-plus line by the standing 2026-11-05 ruling, and 869 additionally gates 873 on shared file scope (`FormalSystem/OpenLanguage.lean`, `docs/theorem-index.md`), so it runs ahead of the syntax line.
- Placed below every L-plus line by standing user ruling: the repository's aim is completeness and decidability of the stability-modal language L-plus, and L-triangle is a secondary line of investigation that is kept but never dispatched ahead of, or batched with, critical-path work. Within the batch, 873 gates 874, 875 and 876, which each carry an edge on it. 873 itself carries an edge on 869 and so runs after the batch above: the two share `FormalSystem/OpenLanguage.lean` and `docs/theorem-index.md`, and the edge makes that shared territory an ordered sequence rather than a collision the admission gate refuses. 876 is a decision record only -- no constructor of `OpenFormula` is to be removed.

Each line is one invocation, and batches are dependency-inclusive: a batch holding a blocker together with its dependent is correct, while a dependent named *without* its out-of-batch blocker is dead weight. `MAX_TASKS` is 8 and the work-cycle budget is per task per invocation (5 default, 13 under `--hard`), so **re-run the same line until every member reports terminal** -- the eleven proof-mode lines are NO LONGER subject to the `absent_file_scope` gate, every one of their twenty-four members declaring a `file_scope` now, but the pre-gate line is exactly `MAX_TASKS` wide (which is why the layout move was raised to a line of its own once the views record made the set nine), and its own intra-batch edges sequence it into four waves after that move lands, so it needs repeated invocations regardless. Shared file scope serializes a batch rather than breaking it, and a collision against a *live* session's lock is not bypassable by `--allow-scope-collision`: wait for the holder, or batch with it. See `.claude/context/patterns/batch-orchestration-guardrails.md`.

**This section is generated and is the authority on run order.** It is rendered from `specs/state.json`'s `roadmap_batches` by `scripts/roadmap-integration.sh`; change the order or the membership through `/roadmap`, never by editing the fence by hand -- a hand edit here is overwritten by the next regeneration. The `## Next batches` section further down is authored prose that no regeneration touches, and it has gone stale against the live graph: it names archived records, describes 761's hold as newly lifted, lists the L^▷ lines individually, and predates the proof-mode programme entirely, so it names none of the proof-mode records, neither 944-957 nor 960-969. No task is filed for that correction, though 177 is the one record that declares `specs/ROADMAP.md` in its own `file_scope` and whose residual scope -- re-auditing touched documentation for accumulated drift -- would cover it; it is parked behind that record's remaining edges along with its README finding.

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
      Phases 11.16 and 11.17 only (~2.5h — SPENT: both phases closed `[COMPLETED]` under plan v13,
      `specs/761_ladder_realization_theorem/plans/13_depth-zero-gate-rest-state.md`; the figure
      describes work already done, not work still open); the other fourteen open phases of 761, and five of its
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
      statement (`LadderCell.lean:998-1010`).

      **WHAT 934 LANDED (2026-11-14), and what it still leaves open.** Task 934 ran the
      reachability probe at exactly that instantiation and completed, archived at
      `specs/archive/934_depth_zero_reachability_probe/`
      (`summaries/01_consumer-shape-reachability-probe-summary.md`). **The compiled answer:
      satisfiable.** `specs/evidence/forward-slack-pin-cascade/consumer-shape-witness.lean`
      compiles `fsw_consumer_shape` — the hypothesis holds at the consumer-shape instantiation
      `(q, c + m*(P+1), n)` at amount `m*(P+1)`, for every `c`, `m`, `P`, at `φ = ⊥` on `stepOr`
      — together with `plateau_next_region` (the slack premise is non-vacuous: a genuine next
      region exists at idle-run length `1`) and `consumer_fires`, which applies
      `cellLE_zero_const_of_kappa_eq_of_forwardSlack` under `ParamsOk` to give the cell equality.
      This is **EXISTENCE EVIDENCE ONLY** for `cellLE_zero_const_of_kappa_eq` landing as a
      `sorryAx`-free theorem: it does not bring that lifting event about. All four of 934's own
      stated limits still hold: (a) it is NOT a general discharge of `ForwardSlackWitnessed` —
      the cell at `φ = ⊥` is the singleton `{∅}`, so one path witnesses every type; (b) it does
      NOT refute `CellLEZeroConstOfKappaEq` under `ParamsOk`; (c) the reserved name
      `cellLE_zero_const_of_kappa_eq` is claimed by nothing and all five depth-`0` schemas still
      carry the hypothesis; (d) `certStabK`'s restatement obligation is unchanged. **The failure
      direction is ARGUED, NOT COMPILED** (934's own point 5): research found no non-ceiling
      failure mechanism and no concrete refuting object, which is an argument in the probe's
      report, not a compiled result. The gate ruling is NOT taken by 934 or here — per 934's own
      point 6, this bullet's "stays open and claimed in neither direction" framing is left for
      the user or a `/roadmap` pass to revise; the disposition stays exactly where Stage 0's own
      header puts it. **Second trap, from 917**: the pin-layer discharge route is already REFUTED
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
- [x] **Decide whether the `I = 1` idle-run sub-regime is filed** (2026-11-19, citing task 929's
      summary). It was filed as task 929 and completed 2026-11-13, archived at
      `specs/archive/929_idle_run_length_one_forward_slack_discharge/`
      (`summaries/01_idle-run-one-forward-slack-summary.md`). Its own standing instruction — "File
      neither half without reading 924's report first" — was honored, not bypassed. **Honest
      outcome: a refutation, not a discharge.** 929 did not make `ForwardSlackWitnessed`
      unconditional; it REFUTED the hypothesis at a POSITIVE amount
      (`forwardSlackWitnessed_refuted_I_one`: FALSE at amount `4` at `xState = (true, 2, 0)` on
      `stepOr`, at a state whose pending-forever regime membership is compiled by
      `xState_regime`), together with a compiled bound on the refutation's reach
      (`ceiling_slack_at_consumer_amount`), under which all five depth-`0` cell-equality schemas
      of `LadderCell.lean` keep `ForwardSlackWitnessed` for a positive compiled reason. The
      `certStabK` restatement obligation this item names is therefore UNCHANGED, not lifted; see
      this stage's depth-`0` gate bullet below for the full mechanism and its relation to task
      934's later probe

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
