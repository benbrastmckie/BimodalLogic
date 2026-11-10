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
  That question was 865's, discharged as research; its owner is now **879**, with 870, 871 and
  867 as prerequisites.
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
- **Presentation (a) for 761** (819): the set-valued per-state datum in maximum-certified form
  (`D` over `Q × ClType φ × K`, `ladderRealized` the fibre equation). **No tuple index is to be
  stated at any parameters.**
- **Route B, over `cohBi`** (815): the certificate is sufficient at the label level over the
  strict-since relation, both arms existential. The two-sided claim for `coh` is refuted — **no
  backward propagation theorem is ever to be claimed for `coh`**. Route A (generalized-Büchi
  nonemptiness) is not to be entered without a decision record.

## Run these next

```bash
/orchestrate 894,895,896 --hard --lit   # Stage 2: P2 -> P3 -> P4 of 879's ingredient table. Already dependency-ordered; dry-run clean. Lands soundness of the whole T3 system as a theorem
/orchestrate 909,910 --hard --lit       # Stage 1's live open core: the register-lowering deletion and the saturated-gap residue. Needs the 909 -> 910 edge first (they share LadderCell.lean). A compiled refutation is as good an outcome as a proof
/orchestrate 899,900 --hard             # P7/P8: the cut product lemma and the linear bridge. Both defer against 894 on docs/theorem-index.md -- run after it, or add serializing edges
/orchestrate 905,906                    # the two research questions 901 filed: cross-certification elimination, and lcU-from-LC_n (879's Q1). Report only, no Lean
/orchestrate 912,913,914                # agent-system: coupled generated surfaces in plan authoring, V10 pair paths, batch-gate narrowing. Off both fronts
/todo                                   # 11 completed tasks read the open count high; CHANGE_LOG's last entry is 2026-10-04
```

**(H5) is fully discharged.** 870 landed `saturation_of_orientedForest` and 897 landed the
universal cover, so 878's paper theorem that `{φ | PlusValidZTime φ}` is decidable now stands on
(H0)–(H4) and (H6) alone. It still yields no Lean `Decidable` instance, no complexity bound and
no finite model property — a *regular*-model property instead. It is the hedge beside the engine,
not a substitute for it.

**The Stage 1 chain, bottom-up, is the whole of what remains on the decidability front.**
`CellLEZeroConstOfKappaEq` under `ParamsOk` (refuted at the frozen `ParamsOkPre`, neither proved
nor refuted under the real one — the live open core) gates `certStabK`, the one `Real` condition
of six not claimed; which gates `real_certAdmK_of_paramsOk` and `real_subset_dmax`; which gate the
ladder realization theorem; which is (W)'s run layer, the lift from one seam to validity; above
which sits 763's `Decidable (PlusValidZTime φ)`, stated nowhere in the tree. The reserved name
`cellLE_zero_const_of_kappa_eq` sits at the bottom of that chain, claimed by nothing. 909 and 910
attack the core; 911 is the idle-cycle sharpening beside it.

**761 stays `[HOLD]`, and lifting it buys nothing yet.** 853 discharged what its plan still marks
`[NOT STARTED]` at Phases 11.12 and 11.13 (`exists_ladderPath_at_region_of_idle_past` and the
unconditional join), but 761 remains `[BLOCKED]` on two independent obligations — the cell
agreement above and the open ladder-cell index — and resuming re-imposes serialization on
everything sharing the `RaySummary` library set, `docs/theorem-index.md`,
`scripts/check-module-invariants.sh`, `specs/evidence/seam-gluing-ray-product/`,
`specs/state.json` and `specs/TODO.md`. Wait for 909/910 to report.

**The 838 chain is spent and closed.** 838 is `[COMPLETED]` at 10/10 phases: the restricted
obligation `cellLE_zero_const_of_kappa_eq_of_forwardSlack` landed as a theorem concluding cell
equality, and two decision gates returned compiled FAIL verdicts (the spanning-block device both
ways, and the idle-gap lengthening — refuted one level below the pin condition, by `step` itself).
Re-planning the area from 838's two-sided framing is barred; its residue is 909/910/911.
**Coverage appendix (uncovered tasks)**:
```
/orchestrate 178,502,570,604,664,714,743,781
/orchestrate 817,818,821,829,830,831,832,873
/orchestrate 890,907,908,911,915
```

## Next batches

```bash
# Stage 1 — decidability of L⁺ at ZTime: the binding front
/orchestrate 909,910 --hard --lit        # the live open core: register-lowering deletion, saturated-gap residue. Needs the 909 -> 910 edge (shared LadderCell.lean)
/orchestrate 911 --hard --lit            # the idle-cycle sharpening: where the object's idle states carry a reachable cycle, the lengthening IS available
/orchestrate 763 --hard --lit            # the lift and the Decidable (PlusValidZTime φ) corollary — needs 761 resumed AND the chain above closed
/orchestrate 714,781 --hard              # sliced-certificate internals (781 researched)
# Stage 2 — completeness of L⁺ at ZTime: TM⁺ plus the until-form schema
/orchestrate 894,895,896 --hard --lit    # P2/P3/P4 of 879's ingredient table, already dependency-ordered. Ends with T3 soundness a theorem
/orchestrate 899,900 --hard              # P7/P8: the cut product lemma and the linear bridge. Defer against 894 on docs/theorem-index.md
/orchestrate 905,906                     # the two questions 901 filed: cross-certification elimination; lcU-from-LC_n (Q1). Report only
# Stage 2b — supporting semantics and metalogic
/orchestrate 664,570 --lit               # corpus ingest and the C3 open question
/orchestrate 830 --hard                  # Γ-generalize decidableValidZTime; does NOT advance either aim
# Stage 3 — hygiene, build cost, datasets, docs. Off both critical paths
/orchestrate 912,913,914                 # agent-system: coupled generated surfaces in plan authoring, V10 pair paths, batch-gate narrowing
/orchestrate 803,804,829                 # build-cost front: SubformulaProperty elaboration (research + plan landed), fan-in, .lake/build CI cache
/orchestrate 298,282,296,231             # the dataset chain behind the c7 labeling bug (298/282/296 partial)
/orchestrate 178,604,743                 # worked Examples/ pipeline, zstd .jsonl, typst-sync namespace resolution
/orchestrate 817,818,821                 # phantom-row inventory, directory-rollup tables (821 researched)
/orchestrate 787,832                     # unguarded .lake reader audit; local-disk reclamation (user decision on data/'s .partial files)
/orchestrate 907,908                     # redeploy the stale .claude/ tree; constraints-consumed marker accuracy
/orchestrate 890                         # GHR Lemma 10.2.3 case 5 erratum reference
/orchestrate 257                         # only once the Stage 0 token exists
# Stage 4 — the long fronts, off both critical paths
/orchestrate 481 --hard                  # the refuted predicate; a C9 register entry is a complete outcome
/orchestrate 831 --research --lit        # off-spine: the Log(all) = Log(ZTime) ∩ Log(Dense) dichotomy
/orchestrate 428,429,410,411 --hard      # the tableau spine's middle — needs 428's scope ruled; 410 planned
/orchestrate 430,412,482 --hard --lit    # the spine's terminus
/orchestrate 502,497 --research --lit    # the STSA literature gate, then the G-operator gap
/orchestrate 498,499,500 --hard          # the representation's two sides and their reconciliation
/orchestrate 125,501,543 --hard          # the Jónsson–Tarski capstone, Until/Since on STSA, MF correspondence
/orchestrate 177                         # last in the programme: README, docs/ and docstring polish
# Stage 5 — L^▷ exploration. Secondary, priority low; never ahead of, or batched with, Stages 1–2
/orchestrate 873                         # subformula closure (ungated)
/orchestrate 874                         # substitution closure and the direct L→L^▷ embedding
/orchestrate 875                         # incompleteness transfer; the limit-closure schema in ▷-form at Base/Dense (its 871 gate is discharged)
/orchestrate 869                         # open-modal invariance along a ray-agreement lifting
/orchestrate 876                         # decision record only: could ⊡ go as an OpenFormula primitive, and at what cost. No removal
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

- [ ] **Decide when 761 comes off `[HOLD]`.** Resuming it re-serializes the Stage 1 front behind
      its 40-path scope; 763 is gated on it. 853 is done, so the Phase 11.12/11.13 reason for
      waiting is discharged — but 761 is still `[BLOCKED]` on the cell agreement and the open
      ladder-cell index, so there is a second reason to wait. Recommended: let 909/910 report first
- [ ] Supply the Hugging Face account and token **257** is blocked on
- [ ] Rule on **428**'s scope. Its one edge is discharged and its `blockers` says "paused at
      4/5 cycles, NOT blocked", so the marker is mis-set: `/revise 428` to add phases for its four
      residual hypotheses, or `/spawn 428` to split them out
- [ ] Rule on whether the 2026-11-06 meta-backlog pruning sweep was deliberate policy on its
      class. Three records covering the plan-authoring/gate-collision ground were abandoned in one
      70-second sweep with no per-record reason; the class then recurred with 10 fresh citations
      across 838 and 853, and 912–914 were filed on that recurrence. If the pruning was policy,
      abandon 912–914 explicitly rather than implementing them

**713** is held by ruling (2026-10-03): its argued CTL⋆ 2EXPTIME lower bound is a citable ceiling
with no consumer. **734** is `[HOLD]` on the paywalled *Handbook of Modal Logic* ch. 11
§§5.10–5.11 (Hodkinson & Reynolds, pp. 655–720), absent from the local Zotero library;
reactivation condition `specs/literature-index.json#hodkinson_2006.hazard`. Acquiring it lifts a
hold, not the aim.

## Not batched, and why

- **713**, **734** are `HOLD` by ruling, **761** by the Stage 0 item above.
- **The agent-system freeze is resolved.** The records that declared edit targets resolving only
  under the source store (`~/.config/nvim/agent-system/**`) have been migrated out of this
  repository's task space and are gone from `specs/state.json`. Tasks 912–914 are the live
  successors, and they declare absolute source-store paths in their own `file_scope` rather than
  relying on a `source_dir` this repo's `.claude-extensions.json` does not declare.
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
  Drift-level invariant to isolate. **Do not re-attempt route (a).** The live route is the one
  `LadderChain.lean` already occupies: the upward cell inclusion
  `cellAt_subset_of_shift_of_pend_past` and the path-level downward inclusion
  `mem_cellAt_of_shift_of_hasForwardSlack_exact`, with the gap to `CellLEZeroConstOfKappaEq` being
  the tight (doubling) chain of pins — not a one-sidedness gap.
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
- **R3, the doubled AA⊡ rule: its 870 gate is discharged and 867 has landed; still not filed.**
  It belongs to the programme 879 owns, which files it if its ingredient table calls for it.
  Filed instead: 894 (the cone carrier), 895 (the formula-level rule, gated on 894) and 896 (the
  extended system, gated on 895). The Auxiliary-Atoms carrier's *Saturation* obligation is what
  894 discharges, on 870's lemma; `NamingRules.lean` lines 57–82 record the blocker it closes.
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
