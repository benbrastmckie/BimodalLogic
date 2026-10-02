# Implementation Plan: Task #708

- **Task**: 708 - Relay the sliced certificate contract to the model checker
- **Status**: [IMPLEMENTING]
- **Effort**: 5.5 hours
- **Dependencies**: 703 (completed; the landed `PlusSlicedCertificate` tree is the source of truth). Soft: 710 (its probe is the citation source for the incompleteness result), 704 (gates the entry-219 non-vacuity wording), 712 (if it lands the probe's theorems as library declarations, the cited path moves)
- **Research Inputs**: specs/708_relay_sliced_certificate_contract_to_model_checker/reports/01_relay-sliced-certificate-contract.md; specs/710_sliced_class_incompleteness_characterization/reports/01_sliced-class-incompleteness.md (Recommendation 4, via the dispatch's STATUS NOTE ADDENDUM)
- **Artifacts**: plans/01_relay-sliced-certificate-contract.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

Produce, inside this repository only, the ready-to-file relay text that amends the paired
ModelChecker repository's `specs/TODO.md` entries 200 and 219 and its
`theory_lib/bimodal/docs/{ADEQUACY,TRUST_PIPELINE}.md`, naming precisely which entries, rows and
sections each block replaces, confirms or introduces. The deliverable is this task's summary
(`summaries/01_relay-sliced-certificate-contract-summary.md`), shaped exactly as the completed
task-701 relay was: a re-run Verification Snapshot, then one section of ready-to-file text per
amended artifact, with every Lean citation given by fully qualified declaration name and checked
against the live tree, and every paired-repository anchor checked against the live paired tree.
Nothing is written outside `specs/708_*/`; the ModelChecker repository is read-only throughout.
Definition of done: the summary carries all seven relay sections listed under Artifacts & Outputs,
its dangling-citation tables show zero dangling names, and `git status` in both repositories
shows no change outside `specs/708_*/` here and nothing at all there.

### Research Integration

The report's F1 fixes the disposition of the five filed points — (1) and (5) confirm, (2) and (3)
hold with exact shapes, (4) is superseded by the landed `TailStable` — and F2 gives the landed
tail-stability statement the relay must carry. F4 records the HOA decision (no profile; four
reasons; one adopted discipline: a sliced envelope omits `lassos`). F5 fixes the published
vocabulary with two corrections (HWZ Theorem 24 / Lemmas 21, 23, not Def 20; `♯(ϕ)` is not the
slice width; "ultimately periodic" is not Biere et al.'s wording). F6 is the amendment index the
summary reproduces. The dispatch's STATUS NOTE ADDENDUM supersedes one sentence of the report: the
report says the sliced finite model property is "open, not refuted"; task 710's probe has since
machine-checked that the sliced class is **incomplete** for L⁺ (`Probe710.not_sliced_complete`,
`Probe710.not_finite_width_fmp`, witness `Φ := θ' ∧ □(⊡Fp → ¬⊡¬Xp)`, confirmed present and
sorry-free at HEAD `8afcb4256` in
`specs/710_sliced_class_incompleteness_characterization/probes/NoFiniteWidthModel.lean`). Every
place the report's draft text says "until a finite model property is proved" or "the sliced FMP is
still missing" is rewritten in this plan to say the discipline is **permanent** for `⊡`-carrying
targets, citing `Φ`, and that the obstruction is the frame class (finite per-time fibres), not the
checker.

### Prior Plan Reference

No prior plan for this task. The task-701 plan (`specs/701_*/plans/01_*.md`, five sequential
`prose` phases, 4 hours, all completed) is the calibration reference: its Phase 1 re-verification
caught two cross-repository drifts beyond what its research had seen, which is why this plan
re-runs every check at implementation time rather than trusting the report's snapshot.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Ready-to-file replacement text for ModelChecker entry 200's blocker paragraphs and a
  conditional citation amendment for entry 219, each stating what it replaces.
- Ready-to-file amendments for ADEQUACY.md: row A3 and §7.1(iii-e) (bound shape becomes the tuple
  `(n, nb, nm, nf)`), §6.1 (the sliced envelope as a strict extension, proposed and unshipped), a
  new tail-stability item (new information for their side), and one sentence for §7.4; explicit
  confirmation that rows A0, A1, A1-Γ, A2 and SEARCH_COVERAGE.md are unchanged.
- Ready-to-file rewrite of TRUST_PIPELINE.md's "The stability modal" middle paragraphs.
- The HOA decision recorded with its four reasons and the one adopted discipline (omit `lassos`).
- The incompleteness result relayed as permanent: never-report-validity for `⊡` targets is not
  pending a proof; cite `Φ` and the two probe theorems; state that no change to clauses, tails,
  windows or stability rescues the class; the `⊡`-free flagship stays complete.
- Published vocabulary throughout, with F5's two corrections applied.
- Dangling-citation checks on both sides, re-run at implementation time, recorded in the summary.

**Non-Goals**:
- Writing to `/home/benjamin/Projects/ModelChecker` in any way (read-only constraint).
- Editing `BimodalTools/README.md` or any file outside `specs/708_*/` — the report's
  Recommendation 2 (recording the `lassos`-omission rule in this repository's wire documentation)
  belongs to the task that ships the sliced envelope, and is named in the summary as a handoff
  note only.
- Landing the task-710 probe as library theorems (task 710's Recommendation 1 / task 712).
- Committing any bound on the slice width `n`, or configuring one from a formula.
- Asserting whether any `⊡` instance is now certified (task 704's question).
- Fetching the sosy-lab page or re-reading the certifying-literature sources; they are cited as
  the report cites them.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Cross-repository drift: a paired-repository entry, row or section moved or was rewritten since the report's read (the 701 precedent found two such drifts at implementation time) | M | M | Phase 1 re-runs every anchor check against the live paired tree before any text is written; Phase 5 re-runs them after |
| A cited Lean name is renamed or moved (the probe is slated to move into `PlusSlicedCertificate/Limits/NoFiniteWidth.lean` by task 710's Recommendation 1 / task 712) | M | M | Cite the probe by path plus HEAD SHA and say its library home is planned, not landed; Phase 5 greps every backticked name in the written text |
| Name collisions mislead the paired side: `TailStable` (the landed, filtered demand, `Stable.lean`) vs `TailStableRaw` (the refuted raw demand); `PlusSlicedCertificate.Check.Certifies` vs `WitnessFamily.Sharing.Agreement.Certifies`; `PlusSlicedCertificate.Sound.plusRefutes_of_certifies` vs `PlusWitnessFamily`'s theorem of the same short name | H | M | Every citation in the relay text is fully qualified under `FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.*`; the glossary names `TailStableRaw` once, as the refuted demand |
| The probe's compile check at HEAD is corrupted by stale `.olean` caches (the defect logged in `specs/errors.json` on 2026-10-02) | H | L | Phase 1 runs `lake build` to completion before `lake env lean` on the probe and records the `#print axioms` output; a failure is a blocker, not a footnote |
| Sibling task 704 changes what can be said about `⊡` non-vacuity before the relay is filed | M | M | Entry-219 text is written as conditional, with the gate named |
| The paired side reads "incomplete" as a checker defect and tries to repair clauses | H | M | The relay says in one sentence, with the probe's D2 as source, that the refutation is of every model on every finite-`W` `ofSlicedStep` frame, so it survives any checker change |
| Summary text re-propagates a stale status word for a paired-repository task | L | M | Phase 1 reads the live `status` of entries 200 and 219 and the written text uses those words |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Phases within the same wave can execute in parallel. All five phases write the same summary
file, so they are serialized; there is no parallel wave.

### Phase 1: Re-verify cross-repository ground truth and open the summary [COMPLETED]

**Goal**: Establish, at implementation time, that every fact the relay will cite still holds on
both live trees, and open the summary with a Verification Snapshot section recording the checks.

**Tasks**:
- [x] Record the BimodalLogic HEAD SHA and the paired repository's HEAD SHA (`git -C
      /home/benjamin/Projects/ModelChecker rev-parse --short HEAD`) and `git -C ... status
      --porcelain` output (expected empty; if non-empty, record it verbatim as pre-existing and
      do not touch it). *(completed)*
- [x] Confirm each Lean declaration the relay will cite exists as a declaration (not only in
      prose), with its defining file: `PlusSlicedCertificate.PlusSlice`, `.PlusSlicedCertificate`,
      `.PlusGraphPath`, `.onePointCertificate` (`Basic.lean`); `.TailStable`, `.TailStableRaw`,
      `.decidableTailStable`, `.fwdLiveAt`, `.bwdLiveAt` (`Stable.lean`); `.Check.Certifies`,
      `.BoxLiveFaithful` (`Check.lean`); `.Sound.plusRefutes_of_certifies` (`Sound.lean`);
      `.Complete.exists_plusSlicedCertificate_of_tailStable_countermodel` (`Complete.lean`);
      `WitnessFamily.exists_plusSlicedCertificate_of_not_plusValidZTime_ofFormula` and
      `.sliced_tailStable_of_certifies` (`EmbedComplete.lean`); `FixtureStable.not_tailStable_cert`,
      `FixtureStable.not_mem_L₀_pR`, `Fixture.not_tailStable`, `Fixture.live_not_determined_by_slice`;
      `Frame.mem_HF_iff_slicedPath`; `StabFaithful`; `CanonicalWire.decodeOptLassos` and
      `CanonicalWire.parse_print` (`BimodalTools/`). Record the fully qualified name actually
      found for each; where the report's short name differs from the live one, the live one wins. *(completed)*
- [x] Confirm `exists_tailStable_repr` has no declaration site (prose mentions only) — it is
      cited as refuted and must stay dangling. *(completed)*
- [x] Run `lake build` to completion, then `lake env lean
      specs/710_sliced_class_incompleteness_characterization/probes/NoFiniteWidthModel.lean`;
      record exit status, the `#print axioms` lines, and `grep -c sorry` (expected 0). Confirm
      `not_plusValidZTime_neg_Φ`, `no_finite_width_sat`, `not_certifies`, `not_sliced_complete`,
      `not_finite_width_fmp` are present. If the probe does not compile, stop and report
      `blocked` with the output — the relay's central claim is that this is machine-checked. *(completed)*
- [x] Confirm the paired-repository anchors (read-only `grep`/`sed` only): entries 200 and 219 in
      `specs/TODO.md` with their live `status` from their `specs/state.json`; ADEQUACY.md row A3,
      §6.1, §7.1(iii-a), §7.1(iii-e), §7.4, rows A0/A1/A1-Γ/A2; TRUST_PIPELINE.md "The stability
      modal" section and its "In this repository" row; SEARCH_COVERAGE.md §3(b)/§4;
      SETTINGS.md's divisibility caveat; `semantic/certificate.py`'s `raw.get("lassos", [])`;
      repo-wide zero hits for `tail.{0,3}stab`, `Hanoi|\bHOA\b`, `sliced|time-slice`,
      `finite.graph`. *(completed)*
- [x] Open `summaries/01_relay-sliced-certificate-contract-summary.md` with the summary-format.md
      header and a `## Verification Snapshot` section holding the tables above (BimodalLogic
      checks; BimodalLogic dangling-citation checks; probe compile check; ModelChecker checks),
      each row giving the command and the result, as the 701 summary did. *(completed)*

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: prose

**Scope Hypothesis**: The citation list above (about twenty Lean names, one deliberately
dangling) and the eleven paired-repository anchors are the report's F1-F6 enumeration; confirm by
running each check and adding any name or anchor the later phases' text turns out to cite that
is missing from this list.

**Files to modify**:
- `specs/708_relay_sliced_certificate_contract_to_model_checker/summaries/01_relay-sliced-certificate-contract-summary.md` - create; header plus Verification Snapshot

**Verification**:
- Summary file exists with every snapshot table populated; no row reads "not checked".
- Probe compile row shows exit 0, zero `sorry`, and the five theorem names.
- `git -C /home/benjamin/Projects/ModelChecker status --porcelain` output recorded (expected
  empty).

---

### Phase 2: Write the entry 200 replacement paragraphs and the entry 219 conditional amendment [COMPLETED]

**Goal**: Ready-to-file text for ModelChecker `specs/TODO.md` entry 200's blocker paragraphs and
a conditional citation amendment for entry 219, each stating exactly which paragraphs it
replaces and which it keeps verbatim.

**Tasks**:
- [x] Add `## ModelChecker entry 200 — ready-to-file replacement paragraphs`. State what is
      replaced (the blocker paragraphs that say 703 is `not_started`, expect "a compression
      bound" and "the verified side's branching structure", and say there is "no L-plus
      compression subtree") and what is kept verbatim (the shape-mechanism and
      temporal-asymmetry-correction paragraphs, and their `dependencies` flag paragraph, as 701
      did). *(completed)*
- [x] Replacement content, in this order: (a) 703 is completed (date); the branching structure is
      `PlusSlicedCertificate` with `Check.Certifies` (nine conjuncts), soundness
      `Sound.plusRefutes_of_certifies`, relative completeness
      `Complete.exists_plusSlicedCertificate_of_tailStable_countermodel`, embedding
      `WitnessFamily.exists_plusSlicedCertificate_of_not_plusValidZTime_ofFormula` — all fully
      qualified. (b) The lasso family is the `i → i` special case; the wire format is a strict
      extension; nothing shipped breaks; the sliced envelope is proposed and unshipped by both
      sides (pointer to the §6.1 block in Phase 3). (c) The bound is the tuple `(n, nb, nm, nf)`;
      no bound on `n` is proved for any target and none is to be configured from a formula; for
      `⊡`-free targets the lasso contract and the landed L bounds stand unchanged, with the
      embedding theorem as the guarantee that the extension loses nothing. (d) Tail-stability is
      a new accept/reject criterion on their side (pointer to the Phase 3 item). (e) **The
      sliced class is semantically incomplete for L⁺**, machine-checked: `Φ := θ' ∧ □(⊡Fp →
      ¬⊡¬Xp)` lies in the CTL-like fragment, `Φ.neg` is a ℤ-time non-validity
      (`Probe710.not_plusValidZTime_neg_Φ`) that no `PlusSlicedCertificate` certifies
      (`Probe710.not_sliced_complete`), and no certificate class presenting a frame with finite
      per-time fibres can be complete (`Probe710.not_finite_width_fmp`); cite the probe path and
      the HEAD SHA from Phase 1, note its planned library home, and say in one sentence that the
      refutation is of the frame class, so no change to clauses, tails, windows or stability
      rescues it. (f) Consequence for their blocker: for `⊡`-free targets nothing on this side
      blocks them; for `⊡`-carrying targets the sliced class is a sound, strictly larger search
      space with no proved bound on `n` and no completeness, and the never-report-validity
      discipline (their D8) is **permanent** for such targets, not pending a proof. Offer the
      status disposition as a recommendation, not an instruction. *(completed)*
- [x] Add `## ModelChecker entry 219 — conditional citation amendment`. Limit (b)'s wording
      stands; the certificate class to cite is now `PlusSlicedCertificate`, non-vacuous on
      `⊡`-free targets by the embedding theorem. Write the non-vacuity sentence for `⊡` targets
      as conditional on task 704's outcome, naming the gate, and do not assert it. Add the
      observation that `Φ.neg` is a limit of a stronger kind than their criterion (b) describes:
      not "no certificate has yet been constructed" but "no certificate in this class can exist",
      proved; suggest they record it as a distinct kind rather than under (b), without drafting
      their header for them. *(completed)*

**Timing**: 1.25 hours

**Depends on**: 1

**Verification Tier**: prose

**Files to modify**:
- `specs/708_relay_sliced_certificate_contract_to_model_checker/summaries/01_relay-sliced-certificate-contract-summary.md` - append the two entry sections

**Verification**:
- Every Lean name in the two sections is backticked, fully qualified, and appears in Phase 1's
  confirmed list (or is added to it).
- The text contains no sentence of the form "until a finite model property is proved" or "the
  sliced FMP is open"; `grep -n "until a finite model\|FMP is open\|pending a proof"` on the
  summary returns only the sentence that negates them.
- The entry-219 `⊡` non-vacuity sentence is explicitly conditional on task 704.

---

### Phase 3: Write the ADEQUACY.md amendments [COMPLETED]

**Goal**: Ready-to-file amendments for ADEQUACY.md's row A3 and §7.1(iii-e), a new §6.1
subsection for the sliced envelope, a new tail-stability item, one sentence for §7.4, and an
explicit unchanged-list.

**Tasks**:
- [x] Add `## ADEQUACY.md — row A3 and §7.1(iii-e)`: the upstream bound shape is now the
      4-tuple `(n, nb, nm, nf)`; `n` is a new, unbounded search dimension never configured from a
      formula; the three lengths keep the divisibility caveat on `nb`/`nf` (`mid` carries no
      periodicity, SEARCH_COVERAGE §3(b) unchanged); for `⊡`-free targets the L row stands and
      the lasso contract remains the encoding. Carry the report's F3 subtlety in one sentence
      (the sliced presentation of an L countermodel can have `nb`/`nf` up to a common multiple
      of the lassos' periods; immaterial because the lasso contract stays in force for those
      targets) and do not restate the L bound as a sliced-tail bound. *(completed)*
- [x] Add `## ADEQUACY.md — §6.1 sliced envelope (proposed, unshipped)`: the strict extension of
      the lasso envelope, with the field list mirroring the Lean structure exactly — top level
      `target` (unchanged), `bx` (unchanged), `n`, `slices: {back, mid, fwd}` each a list of
      `{edge: n×n bool matrix, lab: length-n list of labels}`, `path: {back, mid, fwd}` each a
      list of `[label, state]` pairs, `target.time` = `targetTime`; key order frozen in that
      sequence; **no `lassos` key**; both keys in one document is forbidden by the contract.
      State that `check_certificate` does not read it today, that neither side has shipped it,
      that the lasso envelope is unchanged byte-for-byte, and that this is a proposal for the
      two repositories to pin together. *(completed)*
- [x] Add `## ADEQUACY.md — new tail-stability item (suggest §7.5 or row A4)`, the report's F2
      restated for a consumer that has never heard of it: what the checker computes (live
      position sets, nested fixpoint over the timed position graph; liveness replaces all-threads
      fulfilment); the demand (`TailStable`, residue-indexed, both tails, filtered by
      `bwdLiveAt`/`fwdLiveAt`; decidable via `decidableTailStable`; cost `NB + NF` transfers);
      why it is needed (`Fixture.live_not_determined_by_slice`); the two failure modes and who
      repairs each (`⊆`: the checker's filter, no search action; `⊇`: pre-period absorbed into
      `mid`, a `mid`-length increase, not a period multiplication,
      `FixtureStable.not_mem_L₀_pR`); what is not promised (`exists_tailStable_repr` refuted and
      stated nowhere; `FixtureStable.not_tailStable_cert`; D8 covers the gap); the embedded case
      (`sliced_tailStable_of_certifies`: never rejects anything the lasso contract accepts); and
      that representability (their exact-modulus folding, §7.1(iii-a)) and tail-stability are
      different questions that compose. *(completed)*
- [x] Add `## ADEQUACY.md — §7.4 one added sentence`: for L⁺ targets containing `⊡`, ground (i)
      holds permanently — the sliced class is incomplete (`Probe710.not_sliced_complete`), and
      every finite-width class is (`Probe710.not_finite_width_fmp`) — so an empty search at any
      `(n, nb, nm, nf)` licenses nothing, and will not after any future bound on `n` either. *(completed)*
- [x] Add `## ADEQUACY.md and SEARCH_COVERAGE.md — unchanged`: rows A0, A1, A1-Γ, A2 and
      SEARCH_COVERAGE.md's bounded sweep, with one note that pre-period absorption is a `mid`
      increase that composes with the `(back', fwd')` sweep. *(completed)*

**Timing**: 1.5 hours

**Depends on**: 2

**Verification Tier**: prose

**Scope Hypothesis**: The amended set is {A3, §7.1(iii-e), §6.1, new item, §7.4} and the
unchanged set is {A0, A1, A1-Γ, A2, SEARCH_COVERAGE}; confirm against the live ADEQUACY.md read in
Phase 1, and if a row has been renumbered or a section split since the report's read, amend the
headings to the live names and note the drift in the Verification Snapshot.

**Files to modify**:
- `specs/708_relay_sliced_certificate_contract_to_model_checker/summaries/01_relay-sliced-certificate-contract-summary.md` - append the five ADEQUACY sections

**Verification**:
- The §6.1 field list names every field of `PlusSlice`, `PlusSlicedCertificate` and
  `PlusGraphPath` as read from `Basic.lean` (`edge`, `lab`, `n`, `back`, `mid`, `fwd`, `bx`,
  `target`, `targetTime`) and no field that is not there; `grep -n "lassos"` in the §6.1 block
  finds only the prohibition.
- The tail-stability item cites `TailStable` (not `TailStableRaw`) as the landed demand and
  names `TailStableRaw` at most once, as the refuted raw form.
- No numeric bound on `n` appears anywhere in the summary.

---

### Phase 4: Write the TRUST_PIPELINE rewrite, the HOA decision record, and the vocabulary glossary [COMPLETED]

**Goal**: Ready-to-file rewrite of TRUST_PIPELINE.md's "The stability modal" middle paragraphs; the
HOA decision recorded with reasons; a published-vocabulary glossary applying F5's corrections and
casting the incompleteness result in HWZ terms.

**Tasks**:
- [x] Add `## TRUST_PIPELINE.md — "The stability modal" rewrite`: replaces "blocked on four
      Lean-side results", "requires re-proving Lemma 2 and redesigning (C3)", decidability
      "paper-level only". New content: the histories characterization is re-proved
      (`Frame.mem_HF_iff_slicedPath`), (C3) is replaced by `BoxLiveFaithful` plus (C3b), (C5)
      `StabFaithful` is added; the sliced class is sound and relatively complete for tail-stable
      countermodels, complete on the `⊡`-free fragment, and **incomplete for L⁺** by `Φ`;
      decidability of full L⁺ remains open with no complete certificate class in sight (the next
      candidate, the regular two-way tree class, is unanalysed — task 710's Recommendation 5,
      stated as this side's position, not theirs); the "honest ceiling" item 3 wording stays,
      with the route named and its limit named. Keep their "In this repository" row's shape. *(completed)*
- [x] Add `## Wire-format decision — no HOA profile`: the four reasons from the report's F4 (wrong
      kind of object — bi-infinite, no start state, acceptance is `Check.Certifies` not
      `Inf`/`Fin`; no canonical byte form versus `CanonicalWire.parse_print` and the echo
      protocol; "strict extension" is a requirement and HOA would be a replacement; labels are
      closure formulas and `bx`/`time`/per-slice `edge` have no HOA slot); the one adopted
      discipline (a consumer that does not understand a semantics-bearing field must error, never
      reinterpret — hence `lassos` omitted, since `decodeOptLassos` and `raw.get("lassos", [])`
      both read absence as `[]` and reject structurally); the optional lossy HOA export of the
      unrolled window graph as a visualisation aid, explicitly not a certificate. Add the
      handoff note that recording this rule in `BimodalTools/README.md` is owed by the task that
      ships the envelope. *(completed)*
- [x] Add `## Published vocabulary`: a table from this repository's terms to the published ones —
      lasso family = (k,l)-loop / lasso-shaped `βγ^ω` (Biere et al. 2006 §2, Def 5.1); slice =
      state candidate (HWZ Def 6) / quasistate (Def 12); slice sequence = state function (Def 10);
      target path = run (Def 11); sliced certificate = quasimodel with named states (Def 12);
      pumping = Lemma 17 splice; liveness + `TailStable` = Lemma 23 conditions / Theorem 24
      periodic state function (**not** Def 20); `⊆`/`⊇` dichotomy = Def 22 suitable pair. The two
      corrections stated as corrections: `n` is not `♯(ϕ)` (equal-label states are distinct here
      and must be, for `⊡`); "ultimately periodic" is standard automata vocabulary but does not
      occur in Biere et al. and is not attributed to them. *(completed)*
- [x] In the same section, cast the incompleteness in HWZ terms (from task 710's report, labelled
      as argued where it is argued): HWZ's Theorem 14 collapse to realised types is sound because
      monodic FOTL has no quantifier over runs; L⁺'s `⊡` is a universal quantifier over runs, and
      any collapse to finitely many states per time adds limit runs — which is why the
      obstruction is width and nothing else, and why their quasimodel technique transfers for
      periodicity but not for completeness. *(completed)*
- [x] State the limit of the certifying literature in one paragraph: soundness only, never
      completeness of a certificate class; it informs the format decision and says nothing about
      point (5). *(completed)*

**Timing**: 1.25 hours

**Depends on**: 3

**Verification Tier**: prose

**Files to modify**:
- `specs/708_relay_sliced_certificate_contract_to_model_checker/summaries/01_relay-sliced-certificate-contract-summary.md` - append the three sections

**Verification**:
- `grep -n "Definition 20\|Def 20\|Def\. 20"` on the summary matches only the sentence that
  corrects the attribution.
- `grep -n "ultimately periodic"` matches only text that disclaims Biere et al. as its source.
- The HOA section carries exactly four numbered reasons and one adopted discipline.

---

### Phase 5: Close the deliverable, re-check citations, and confirm the boundary [COMPLETED]

**Goal**: Add the amendment index and five-point disposition tables, re-run the dangling-citation
checks over the written text, confirm nothing outside `specs/708_*/` changed here and nothing
changed in the paired repository, and finish the summary.

**Tasks**:
- [x] Add `## Amendment index` (the report's F6 as a table, updated for the incompleteness
      result): paired artifact, current state, amendment, kind (confirm / correct / introduce),
      pointing at the section of this summary that carries the text. *(completed)*
- [x] Add `## Disposition of the five filed points`: (1) confirm, (2) holds with exact shapes,
      (3) holds with the `⊡`-free half now a theorem, (4) superseded by the landed `TailStable`,
      (5) confirm — and now permanent, by `Φ`. One row each, with the load-bearing declaration. *(completed)*
- [x] Re-run the dangling-citation check over the summary's own text: extract every backticked
      identifier that looks like a Lean name (`grep -oE` on `[A-Za-z_][A-Za-z0-9_.₀-₉'Φ]*` inside
      backticks, filtered to names containing a dot or starting with a known namespace) and grep
      each against `FormalSystem/`, `BimodalTools/` and the 710 probe for a declaration site;
      record the table; every name must resolve except `exists_tailStable_repr`, which must not. *(completed)*
- [x] Re-run the paired-repository anchor checks from Phase 1 and record any drift since Phase 1. *(completed)*
- [x] Confirm the boundary: `git status --porcelain` here shows changes only under
      `specs/708_relay_sliced_certificate_contract_to_model_checker/`; `git -C
      /home/benjamin/Projects/ModelChecker status --porcelain` is byte-identical to Phase 1's
      recording; `git -C /home/benjamin/Projects/ModelChecker log -1 --format=%H` equals Phase
      1's recording. Record all three in the Verification Snapshot. *(completed)*
- [x] Complete the summary's standard closing sections (what was done, what was deferred with
      owner named — the `BimodalTools/README.md` note, the probe's library landing, the entry-219
      gate on 704 — and the handoff note that the relay is ready to file by hand on the paired
      side). *(completed)*

**Timing**: 0.5 hours

**Depends on**: 4

**Verification Tier**: prose

**Files to modify**:
- `specs/708_relay_sliced_certificate_contract_to_model_checker/summaries/01_relay-sliced-certificate-contract-summary.md` - append the closing sections; update the Verification Snapshot with the post-write checks

**Verification**:
- Dangling-citation table has zero unresolved names other than `exists_tailStable_repr`.
- Boundary rows recorded with matching before/after values.
- `bash .claude/scripts/check-task-references.sh` (if present) reports nothing outside
  `specs/**` — trivially, since no file outside `specs/708_*/` was written.

## Testing & Validation

- [x] The 710 probe compiles at HEAD after a full `lake build` (exit 0, zero `sorry`); the five
      theorem names are present; `#print axioms` output recorded. *(completed)*
- [x] Every fully qualified Lean name in the summary resolves to a declaration site in the live
      tree, except `exists_tailStable_repr`, which resolves to none. *(completed)*
- [x] Every paired-repository entry, row and section the summary names exists in the live paired
      tree at the SHA recorded in the Verification Snapshot. *(completed)*
- [x] The summary contains no numeric bound on `n`, no "pending a proof" or "until a finite model
      property is proved" wording about `⊡` targets, no attribution of the tail condition to HWZ
      Def 20, and no attribution of "ultimately periodic" to Biere et al. *(completed)*
- [x] A sliced envelope in the §6.1 block carries no `lassos` key, and the prohibition on both
      keys in one document is stated. *(completed)*
- [x] `git status --porcelain` in this repository shows only `specs/708_*/` paths; the paired
      repository's `status --porcelain` and `HEAD` are unchanged between Phase 1 and Phase 5. *(completed)*

## Artifacts & Outputs

- `specs/708_relay_sliced_certificate_contract_to_model_checker/plans/01_relay-sliced-certificate-contract.md` (this plan)
- `specs/708_relay_sliced_certificate_contract_to_model_checker/summaries/01_relay-sliced-certificate-contract-summary.md` — the deliverable, carrying, in order: Verification Snapshot; entry 200 replacement paragraphs; entry 219 conditional amendment; ADEQUACY row A3 / §7.1(iii-e); ADEQUACY §6.1 sliced envelope (proposed, unshipped); ADEQUACY new tail-stability item; ADEQUACY §7.4 sentence and the unchanged-list; TRUST_PIPELINE rewrite; HOA decision; published vocabulary and the incompleteness result in HWZ terms; amendment index; five-point disposition; closing sections
- No file outside `specs/708_*/`; no file in `/home/benjamin/Projects/ModelChecker`

## Rollback/Contingency

The only file written is the summary under `specs/708_*/summaries/`. If a phase must be undone,
delete or truncate that file's affected sections and re-run the phase; no snapshot is needed
because no file outside the task directory is touched, and `git` in the paired repository is
never invoked in a writing mode. If Phase 1's probe compile check fails for a non-environmental
reason, stop with status `blocked` naming the failing declaration — the relay cannot say
"machine-checked" on a probe that does not check — and report it to the orchestrator rather than
rewording the claim.
