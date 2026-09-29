# Research Report: Task #701

**Task**: 701 - port_substrate_lessons_to_model_checker
**Started**: 2026-09-29T17:00:00Z
**Completed**: 2026-09-29T18:15:00Z
**Effort**: ~2.5 hours research (cross-repository, no code changes)
**Dependencies**: 696 (stability_modal_substrate_design, BimodalLogic — **completed**, confirmed
landed in the tree during this research pass; see Finding F0)
**Sources/Inputs**: - BimodalLogic `specs/696_stability_modal_substrate_design/reports/{01,02}_*.md`
(read in full), `specs/696.../probes/*.lean` (listing), `FormalSystem/Metalogic/Decidability/
WitnessFamily/Sharing/README.md`'s "Hand-off to the consuming model checker" section, live
`FormalSystem/Metalogic/Decidability/{WitnessFamily/Sharing,PlusWitnessFamily}/*.lean` (grep +
read to confirm landing), BimodalLogic `specs/state.json` (tasks 696, 700, 703, 701); ModelChecker
`code/src/model_checker/theory_lib/bimodal/semantic/{certificate,witness_registry,
witness_constraints,formula}.py` (read in full), `docs/{ADEQUACY,ARCHITECTURE}.md` (read in full),
`README.md`'s Known Limitations, `tests/fixtures/certificates/*.json`, `tests/integration/
test_certificate_lean_agreement.py`, `examples.py`'s THEORY-LIMITS group (read in full), ModelChecker
`specs/state.json` (tasks 200, 219, 703 archive check)
**Artifacts**: - `specs/701_port_substrate_lessons_to_model_checker/reports/01_substrate-lessons-for-model-checker.md` (this report)
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **BimodalLogic task 696 landed during this research pass — the phasing question the dispatch
  poses ("what to change now vs. when the redesign lands") has a different answer than the
  dispatch assumed.** The dispatch describes 696 as research whose lessons should be "drawn from
  the landed redesign." A live-tree check (Finding F0) confirms the redesign is not merely
  designed but **implemented**: `transBack`/`transMid`/`transFwd`/`LiftableRaw`/`Liftable` exist
  in `Sharing/Skeleton.lean`, wired through `Basic.lean`/`Decide.lean`/`Fulfil.lean` on both the
  `WitnessFamily` and `PlusWitnessFamily` sides, and the two gate families from round 2's report
  (`famA`, `famB`) are landed in `Examples.lean` with `plusCertifies_stabSnce_example : (famA
  p).PlusCertifies 0` and `plusCertifies_stabUntl_example : (famB p).PlusCertifies 0` — the
  certificate class is **no longer empty** for either target schema. `BimodalLogic/specs/
  state.json` shows task 696 `status: "completed"`, `last_updated` several hours after ModelChecker
  task 200's own most recent re-scoping edit. **Consequence**: ModelChecker task 200's current
  text (already re-scoped once, see Finding F7) is itself now one step stale — it still says
  696 is "implementing" — and ModelChecker task 219's THEORY-LIMITS group in `examples.py` is now
  substantively wrong, not just incomplete (Finding F8).
- **Q1 — what this theory's certificate search assumes, and what replaces it.** The assumption is
  named explicitly in the model checker's own `docs/ADEQUACY.md` ("Why the design is
  deterministic") and `docs/ARCHITECTURE.md`: histories are exactly the lasso orbits
  (`ShiftSet.total_eq_orbit`, Lemma 2), which is what makes `\Box`'s range exactly the certified
  histories (Corollary 2.2) and what the Box case of the truth lemma (Lemma 4) consumes. That
  fact is a direct consequence of **determinism** — no two lassos ever share a state — which is
  itself what makes Saturation free (every fibre a singleton). The verified thread/`trans`/
  `Liftable` account replaces exactly this: `total_eq_thread` (the Lean analogue of
  `total_eq_orbit`) is now proved *from* the `Liftable` field rather than from determinism, and a
  frame history is a **thread** (a `trans`-connected sequence across lassos) rather than a lasso
  orbit. Nothing else in the assumption set — Compositionality, Seriality, Limit — depends on
  determinism (`docs/ADEQUACY.md`'s own analysis already separates these).
- **Q2 — which lessons port, and where.** Four lessons, each with a concrete file target in
  `semantic/`: (a) separate state identity (a `share` **equivalence**, needed for `stab`) from
  one-step succession (a `trans` **relation**, needed for `\Since`/`\Until`/`\Box` under sharing)
  — this is the single load-bearing correction the whole BimodalLogic redesign exists to make,
  and it is the first design decision ModelChecker's own future sharing extension must not skip;
  (b) shape the search space so closure is cheap — splice-closed lasso families, not arbitrary
  arrival renaming — is the cheap sufficient condition to reach for first, matching
  `WitnessRegistry`'s existing preference for round-robin/bounded structures over unconstrained
  search; (c) emit `trans*` fields beside `rep*` when sharing lands, additive and optional,
  mirroring exactly the shape `LabelledLasso`'s `back`/`mid`/`fwd` already has; (d) the
  pure-Python `recheck` in `certificate.py` will need its own independent thread/`Liftable`
  characterization when sharing lands, to keep S3's "decided twice, independently" discipline
  (`docs/ADEQUACY.md` §2) intact — it cannot simply trust the Z3 encoder's own thread construction.
- **Q3 — re-scoping task 200 and amending task 219.** Task 200 is already substantially re-scoped
  (an earlier pass evidently used round 1/round 2 of 696's research) but is now one increment
  stale: it says 696 is "implementing" when it is complete, and its blocking rationale should be
  narrowed to task 703 (`lplus_compression_and_completeness`, BimodalLogic, status
  `researching`) alone. Task 219's `examples.py` THEORY-LIMITS group has two defects, not one:
  it records only the `Since`-side gap (never mentions the `Until`-side schema or
  `not_plusCertifies_stabUntl`/`stabUntlTarget` at all), and it frames the empty-certificate-class
  fact as a standing, open-ended "STANDING CONSEQUENCE" rather than a fact about a since-repaired
  substrate — both defects are now sharper because the substrate has, in fact, been repaired:
  `famA`/`famB` are living counterexamples to "the certificate class is EMPTY," landed in the
  same tree the group cites.
- **Q4 — the wire-level contract is additive, confirmed, nothing must change now.** The three
  proposed `trans*` fields land in exactly one place on the ModelChecker side —
  `LabelledLasso`/`WitnessFamily`'s `to_json`/`_lasso_from_wire`/`recheck_json` in
  `semantic/certificate.py` — never in `semantic/formula.py` (which encodes only `Formula` ASTs,
  not lasso/label structure) and never in `WitnessRegistry`/`WitnessConstraintGenerator`'s Z3
  variable layer unless and until a sharing search is actually built. No existing fixture in
  `tests/fixtures/certificates/*.json` needs to change, and `test_certificate_lean_agreement.py`'s
  bytewise echo comparison against `lake exe check_certificate` continues to pass unmodified,
  because "absent means full" on both sides (BimodalLogic's `Sharing/README.md` hand-off section;
  confirmed as the intended Lean-side default via `transMatOf_full`, Finding F5).
- **Q5 — restating the Box case over threads ahead of sharing.** Yes, and it is a
  documentation-only, zero-risk change available today: `docs/ADEQUACY.md`'s Lemma 2/Corollary 2.2
  can be re-derived as the *specialization* of the verified side's `total_eq_tthread_of_liftable`
  + `TThread.toThread` to the trivial case `trans := share`-full (which is exactly what
  `total_eq_orbit` already is, per `liftable_of_full`'s role in round 1's report). Doing this now
  turns a future sharing extension into a refinement of an existing proof sketch rather than a
  rewrite, at zero cost, since it changes no Lean or Python code — only which argument shape
  `ADEQUACY.md` presents.

## Context & Scope

This is a cross-repository research task: BimodalLogic hosts the verified design (task 696,
`specs/696_stability_modal_substrate_design/`), ModelChecker hosts the consuming bimodal theory
(`code/src/model_checker/theory_lib/bimodal/`) and its own task system (ModelChecker
`specs/state.json`, tasks 200 and 219). Per the dispatch's repository boundary, this report reads
both repositories but the deliverable — this report — lives only under BimodalLogic's
`specs/701_.../reports/`. No file under `~/Projects/ModelChecker` or elsewhere in
`~/Projects/BimodalLogic` outside this task's own `specs/` subtree was modified.

Read in full: BimodalLogic's 696 round-1 and round-2 reports (2,900+ lines combined), the Sharing
README's hand-off section; ModelChecker's `certificate.py` (565 lines), `witness_registry.py`
(192 lines), `witness_constraints.py` (252 lines), `formula.py`'s module docstring and codec
functions, `docs/ADEQUACY.md` (911 lines, read in full including "Why the design is
deterministic"), `docs/ARCHITECTURE.md`'s relevant sections, `README.md`'s Known Limitations,
`examples.py`'s THEORY-LIMITS group (lines 1335-1500) and its `TL_CM_1`/`TL_CM_2` entries, both
task descriptions for ModelChecker 200 and 219 in full, and a live-tree grep confirming 696's
landing state in `FormalSystem/Metalogic/Decidability/{WitnessFamily/Sharing,PlusWitnessFamily}/`.

## Findings

### Codebase Patterns

**F0. BimodalLogic task 696 is `completed`, not `implementing`, as of this research pass.**
`specs/state.json` (BimodalLogic): `{"project_number": 696, "status": "completed",
"last_updated": "2026-09-29T16:18:36Z"}`. A live grep confirms the redesign is in the tree, not
just designed: `Sharing/Skeleton.lean` (`transMatOf`, `transOf`, `LiftableRaw`, lines 179-340+)
carries the `trans*` datum and the `Liftable` field exactly as round 1/round 2 specified;
`PlusWitnessFamily/Examples.lean` carries `famA`/`famB` (from line ~543) with
`plusCertifies_stabSnce_example : (famA p).PlusCertifies 0` (line 816) and
`plusCertifies_stabUntl_example : (famB p).PlusCertifies 0` (line 1192);
`PlusWitnessFamily/Incompleteness.lean` retains `not_snce_share_congr`/
`not_untl_shift_share_congr` (the *congruence-refuted* theorems, lines 115, 149) and both
`not_plusValidZTime_stab{Snce,Untl}` (lines 181, 212), but **no longer contains**
`not_plusCertifies_stabSnce`/`not_plusCertifies_stabSnce_premise`/`not_plusCertifies_stabUntl` —
exactly the Phase-4 replacement round 1's report prescribed (report 01 §"Phasing" step 4).

**F1. ModelChecker's certificate datatype is explicitly, deliberately non-sharing today.**
`semantic/certificate.py`'s module docstring, "Extension point: lasso state sharing (not
implemented)": `WitnessFamily.lassos` is "a plain tuple of independent `LabelledLasso`s —
lassos never share positions," and the docstring already names the exact reason: determinism
"is what makes `ShiftSet.total_eq_orbit` ... true," which "is what makes Box's range exactly the
certified histories," which "is what makes the Box case of the certificate truth lemma go
through." This is the *same* diagnosis 696's reports independently reach for the Lean side
(round 1 F1/F2, round 2 F1), stated for the Python/Z3 side already, unprompted by this task — the
model checker's own authors anticipated exactly this dependency before 701 was dispatched.

**F2. `docs/ADEQUACY.md`'s "Why the design is deterministic" section is the precise, pre-existing
answer to Q1, already in the tree.** Lines ~340-375: "The real obstruction to state-sharing is
not Limit or Saturation — it is Lemma 2 and the Box case of Lemma 4," and: "If two lassos shared
a state, a history could cross from one lasso to another at the shared state, `total_eq_orbit`
would fail, Corollary 2.2 ... would fail with it, and the Box case of Lemma 4 would fail." This
is word-for-word the mechanism BimodalLogic round 1's F4 and round 2's F5
(`stabFamily_not_liftable`) machine-check on the Lean side: a frame `Step`-path exists that no
single lasso traces, so "every frame history is a thread" needs a genuine closure obligation
(`Liftable`), not an automatic consequence. `docs/ARCHITECTURE.md` (~line 186-195) restates the
same finding as a table row and cites `README.md`'s Known Limitations, which states: "certified
frames have no branching at a shared state ... a future stability-modal extension would need
branching witness families, which is open research and not promised here."

**F3. `docs/ADEQUACY.md`'s own list of what does *not* depend on determinism matches BimodalLogic's
Q1 answer exactly.** Compositionality and Seriality are proved from `𝔇`'s group structure alone;
Limit is "genuinely non-free" but is discharged from discreteness (`ShiftSet.ofIntAction`/
`sep_of_succOrder`), not from determinism; only Saturation ("free only from subsingleton
fibres") and the histories characterization (Lemma 2) rest on determinism. This confirms
BimodalLogic round 1's A1-A10 criteria (Sharing must supply a `share` equivalence for `stab`,
free predecessor/successor sets for `snce`/`untl`, and a `Liftable`-shaped closure obligation for
`box`/`stab`) map onto the model-checker side one-for-one: A1 (`share`) ↔ the model checker's
"lassos never share positions" restriction being lifted; A4/A5 (`Liftable`) ↔ "the real
obstruction ... is Lemma 2 and the Box case of Lemma 4"; A2/A3 (free succession) has no current
model-checker analogue because nothing in `witness_registry.py`/`witness_constraints.py` encodes
succession at all today — `Untl`/`Snce`'s clauses in `_coherence_clause_at` read `bit(lasso, t+1,
…)`/`bit(lasso, t-1, …)` on the **same** lasso index, i.e. succession is currently *identity on
the lasso index*, an even more restrictive special case than BimodalLogic's pre-696 "succession is
the whole `share`-class" — it is "succession is a single fixed point," because there is no sharing
relation on the model-checker side to begin with.

**F4. `WitnessRegistry`'s witness-lasso allocation already distinguishes "may share" from
"forced to share," which is the right shape for the `trans` design's own "additive, decidable
sufficient condition" posture.** `allocate_witness_lasso`'s docstring: witness lassos "*may* be
shared ... but are never *required* to be"; `max_witnesses`, if given, "*forces* sharing rather
than merely permitting it," trading completeness for bound search, and "never affects soundness."
This is structurally the same posture BimodalLogic's `Liftable` sufficient lemmas take: `full`
(today's determinism, i.e. no sharing) and `spliceClosed` (a decidable, sufficient — not
necessary — condition) are both *safe over-approximations* a producer can pick, never load-bearing
for soundness. A future sharing extension to `WitnessRegistry` should keep this shape: default to
no sharing (`full`), offer a bounded/round-robin-style splice-closed mode as an opt-in search
restriction, exactly mirroring `max_witnesses`'s existing completeness-for-boundedness trade.

**F5. The export contract's "absent means full" default is present on both sides, independently,
and agrees.** BimodalLogic `Sharing/README.md`'s hand-off section: "Absent means full. A checker
that omits the three succession lists is read as supplying the all-true matrix at every time,
which is exactly the pre-redesign substrate." The Lean-side mechanism for this is
`transMatOf_full` (`Skeleton.lean:286-290`): `(hall : ∀ r ∈ transBack ++ transMid ++ transFwd, ∀
i j, r i j = true) → transMatOf ... u i j = true` — i.e., a producer that supplies the all-true
matrices satisfies the "full" case decidably, and `Liftable`'s `liftable_of_full` sufficient lemma
(round 1 report, Recommendations Q2 step 3) discharges the new closure obligation for that case
with no new proof burden. On the ModelChecker side, since no `trans*` fields exist in the wire
format at all today (confirmed against all four `tests/fixtures/certificates/*.json` files and
`certificate.py`'s `WitnessFamily.to_json`), "absent" is not a special case to implement — it is
simply "the field is not there yet," which is the same thing as "full" by construction. No
present-day fixture, `to_json` output, or `recheck`/`recheck_json` code path needs to change for
this default to hold.

**F6. The wire-level fields that would carry `trans*` are precisely identified, and are distinct
from `formula.py`'s codec.** `certificate.py`'s `LabelledLasso` (frozen dataclass, `back`/`mid`/
`fwd: Tuple[Label, ...]`) is the Python mirror of Lean's `LabelledLasso`; its `to_json` emits
`{"back": [...], "mid": [...], "fwd": [...]}`. The three new fields — `transBack`/`transMid`/
`transFwd`, "three lists of `|lassos| x |lassos|` Boolean matrices with lengths equal to the
corresponding `rep` list" (`Sharing/README.md`) — are **skeleton-level** data (per-frame, shared
across all lassos of a `WitnessFamily`, since `SharingSkeleton` sits below the family in Lean),
not per-`LabelledLasso` data. On the Python side this means the natural landing spot is
`WitnessFamily` (the dataclass holding `bx` and `lassos: Tuple[LabelledLasso, ...]`), as a new
optional field alongside `lassos`, not inside `LabelledLasso` itself — mirroring the Lean shape,
where `trans*` are fields of the `SharingSkeleton`/`PlusSharingWitnessFamily`, not of an
individual `LabelledLasso`. `formula.py`'s `to_json`/`from_json` encode only the `Formula` ADT
(`atom | bot | imp | box | untl | snce`) and are untouched by any of this — confirmed by reading
both files in full; nothing in `formula.py` references lassos, labels, or sharing.

**F7. ModelChecker task 200 has already been re-scoped once, using BimodalLogic's round-1 and
round-2 findings, but is one increment behind the current tree state.** Task 200's live
description (ModelChecker `specs/state.json`, `last_updated: 2026-09-29T11:28:06Z`, i.e. ~5 hours
before 696's completion at `16:18:36Z`) already: (a) states the correct shape mechanism (an
invariance-across-equivalence-class argument, not a temporal asymmetry — matching round 2's F8
refutation of candidate B); (b) names the `untl`-side gate family and cites
`untl_shift_share_congr`/`not_plusCertifies_stabUntl`/`not_plusValidZTime_stabUntl` as "machine-
checked ... but lives only in the design-authority task's own archived probe files, not yet
landed"; (c) correctly narrows the blocker from four originally-named upstream tasks to two
(696 for the design, BimodalLogic 703 for the compression bound), noting 694 was folded into 696
and 695 is complete; (d) explicitly says "as of this writing its status is implementing (its
research rounds are complete; the redesign implementation is in progress, not yet complete)."
Statement (d) and the framing built on it ("no design for the corrected substrate is complete
(696, implementing)") are now false: 696 is complete (F0), the `untl`-side family is landed in
`Examples.lean` (not merely archived probes), and the specific claim "lives only in ... archived
probe files" is superseded — `famB`/`plusCertifies_stabUntl_example` are landed, tree-checked
theorems, not probes.

**F8. ModelChecker task 219's `examples.py` THEORY-LIMITS group (lines 1335-1500) has two
defects against the now-landed tree, one of omission and one of framing.** Omission: the entire
group — its inclusion criterion, "FACT 1"/"FACT 2" header comments, and both `TL_CM_1`/`TL_CM_2`
entries — discusses only `(g S e) -> [stab](g S e)` (the `Since`-side schema,
`not_plusValidZTime_stabSnce`); a full-file grep for `Untl`/`stabUntl`/`Fp ->` inside
`examples.py` finds zero occurrences outside three docstring lines that *mention* `untl` only to
say it collapses "the same way" — the `Until`-side schema (`Fp -> (p \/ [stab]Fp)`,
`stabUntlTarget`) is never named, and no probe/example analogue to `TL_CM_1`/`TL_CM_2` exists for
it, despite round 1's report (F3, machine-checked) establishing the `untl`-side collapse as an
equally genuine, independently-discovered defect, not a corollary of the `snce`-side one. Framing:
"FACT 2" and the "STANDING CONSEQUENCE" comment block present "the certificate class is EMPTY for
this schema" and "the verified side has a SEMI-decision procedure, not a decision procedure" as
open-ended, indefinite facts about the verified side's design — true when task 219 was written
(against 696 "researched"/"implementing"), **false now**: `famA`/`plusCertifies_stabSnce_example`
is a landed, tree-checked proof that the certificate class for this exact schema is non-empty
(F0). The comment's own inclusion criterion (b) — "a completeness gap in the VERIFIED side's own
certificate system ... for which no certificate meeting that system's conditions exists at any
time or size" — is the literal claim that no longer holds for the `Since`-side schema at `t=0`,
`trans=eq`.

### External Resources

This task is internally scoped (BimodalLogic <-> ModelChecker cross-repository transcription); no
new external literature search was performed beyond what BimodalLogic's 696 reports already cite
(Burgess 1982 for the `U`/`S` truth-clause shape, and the Emerson-Halpern/Reynolds pointers on
closure). Those citations are reused here only as background for Q1/Q2's mechanism explanation,
not re-verified independently — 696's reports already did that verification.

### Recommendations

**Q1 — what this theory's certificate search assumes, and what replaces it.**

| Assumption (today) | Where encoded | What replaces it |
|---|---|---|
| Histories are lasso orbits (`H_F = {t -> (i,t+c)}`) | `docs/ADEQUACY.md` Lemma 2, `ShiftSet.total_eq_orbit` | `total_eq_thread`, proved from `Liftable` rather than from determinism (BimodalLogic `total_eq_tthread_of_liftable`) |
| Every fibre a singleton (determinism) makes Saturation free | `docs/ADEQUACY.md` Lemma 1 | Unaffected by sharing in general — Saturation is a fact about `𝔇`'s shift relation, not about lasso independence; BimodalLogic's redesign leaves the frame section of `Skeleton.lean` byte-identical (round 1 F5) for exactly this reason |
| `\Box`'s range is exactly the certified histories (Corollary 2.2), so (C3)/`box_faithfulness_constraints` can be a finite conjunction over lasso positions | `docs/ADEQUACY.md` Corollary 2.2; `witness_constraints.py`'s `box_faithfulness_constraints` | Requires `Liftable` (every frame `Step`-path is a thread's trace) to keep the analogous "Box's range is exactly the certified threads" property once sharing exists |
| Succession is identity-on-lasso-index (`Untl`/`Snce`'s clauses in `_coherence_clause_at` read the *same* lasso's `t+1`/`t-1`) | `witness_constraints.py::_coherence_clause_at` | A `trans`-indexed successor/predecessor lookup, `bit(trans-successor-lasso(lasso,t), t+1, …)`, once sharing lands — today's Python code has no analogue of "arrival renaming" at all, since there is currently no cross-lasso relation of any kind |

**Q2 — which lessons port, and to which files.**

1. **Separate state identity from succession.** The single load-bearing correction of the whole
   696 redesign (round 1 Executive Summary, root cause) is that state-sharing needs an
   equivalence (`share`) and succession needs a possibly-unrelated relation (`trans`), and that
   conflating them (succession-as-a-class) forces every (C1)-style local clause to collapse to a
   class invariant. **Port target**: any future ModelChecker `share`-bearing extension of
   `WitnessRegistry`/`certificate.py` must introduce two separate relations from the start — a
   per-time equivalence on lasso indices for `stab`, and an independent per-time relation for
   one-step succession consumed by `Until`/`Since`/`Box`'s neighbour lookups in
   `witness_constraints.py::_coherence_clause_at` and `certificate.py::_coherent_at` — never a
   single relation asked to do both jobs. This is the one mistake BimodalLogic's round 1 spent a
   full research round discovering was still present in the *first* redesign attempt (task 694's
   folded-in proposal lacked exactly this separation per round 1's Phasing note); ModelChecker's
   design should not repeat that detour.
2. **Shape the search space so closure is cheap.** BimodalLogic's `Liftable` obligation needed a
   genuinely new closure argument (F4, "why a general succession relation needs a closure
   condition"); the two sufficient conditions that avoid an expensive general procedure are
   `full` (no sharing — today's model-checker behavior, free) and `spliceClosed` (a decidable,
   pigeonhole-backed condition, cheap for the concrete gate families). **Port target**:
   `WitnessRegistry`'s `max_witnesses` round-robin mechanism (F4 above) is already the right
   shape for a bounded, decidable, sufficient-not-necessary restriction; a future sharing search
   should add a splice-closed-style constraint generator to `witness_constraints.py` as an
   *additional, optional* constraint family, analogous to how `max_witnesses` bounds witness-lasso
   count today, rather than attempting the general `Liftable` decision procedure (BimodalLogic's
   own report defers that to a separate follow-up task, "exact closure," not yet started).
3. **Emit `trans*` beside `rep*` when sharing lands.** Confirmed additive at the wire level (Q4
   below); **port target**: `WitnessFamily` in `certificate.py` (not `LabelledLasso` — F6), gaining
   optional `trans_back`/`trans_mid`/`trans_fwd: Optional[Tuple[Tuple[Tuple[bool, ...], ...],
   ...]]` fields defaulting to `None` (read as "full"), with `to_json` omitting them entirely when
   `None` and `_lasso_from_wire`/`recheck_json`(via a new `_family_from_wire`) reading them when
   present. This is a **future** task, not something this report recommends starting now — see
   the phased proposal below.
4. **Whether `recheck` needs a thread-based history characterization to stay independent.** Yes,
   necessarily, once sharing lands. Today `recheck`'s four checks (`_coherent_at`, `_fulfil_at`,
   `_box_faithful`, `_target_holds`) never construct or inspect a thread/history at all — they are
   purely label-local (per-lasso, per-position) checks, which is sound today only because
   Lemma 2/Corollary 2.2 hold automatically under determinism. Once `Liftable` becomes a real
   closure obligation, box faithfulness's "actual" computation in `_box_faithful` (`all(f.child in
   lasso.label(t) for lasso in family.lassos for t in _box_window(lasso))`) is checking the wrong
   thing: it ranges over *lassos*, but under sharing `\Box`'s truth condition ranges over
   *threads*, which may visit a position not "belonging" to any single lasso's own window in the
   way `_box_window` assumes. `recheck` would need its own, independently-written thread
   enumeration/`Liftable` check (mirroring `total_eq_tthread_of_liftable`'s two-part argument:
   extract the frame `Step`-path, then require `Liftable` to lift it) — reusing the Z3 encoder's
   thread construction here would break S3's independent-re-decision discipline
   (`docs/ADEQUACY.md` §2, "S3 is the architectural point of the whole design").

**Q3 — re-scoping task 200 and amending task 219.**

*Task 200 (ModelChecker, `extend_bimodal_to_stability_modal`, currently `blocked`).* The existing
re-scoped text (F7) is structurally correct and should **not** be rewritten from scratch; it needs
a narrow, dated update:

- Replace "Upstream project 696 ... as of this writing its status is implementing (its research
  rounds are complete; the redesign implementation is in progress, not yet complete)" with: 696
  is **completed** (BimodalLogic `specs/state.json`, `last_updated: 2026-09-29T16:18:36Z`); the
  `trans`/`Liftable` design is landed in `FormalSystem/Metalogic/Decidability/WitnessFamily/
  Sharing/Skeleton.lean` and wired through both `WitnessFamily` and `PlusWitnessFamily`; both gate
  families (`famA`/`famB`) are landed with `PlusCertifies` proofs, so the design authority this
  task was waiting on now exists as a concrete, machine-checked reference shape (Finding F0), not
  as a recommendation.
- The blocker itself does **not** lift: task 200's remaining upstream dependency is BimodalLogic
  703 (`lplus_compression_and_completeness`, status `researching`), which the 696 report's own
  Recommendations already separate from the design question — 200 needs a compression/enumeration
  bound for the *general* case (arbitrary countermodels, not just the two hand-built gate
  families) before a bounded Z3 search over a branching structure can be built responsibly.
  Restate the blocker as: "blocked on BimodalLogic 703 alone (696's design dependency is
  discharged); 703 supplies the compression bound this task's search-bound design needs, and per
  696's own decision record, no L-plus compression work should proceed before 696 lands — which
  it now has, so 703 is unblocked to proceed, but 703 itself remains `researching`, not
  `completed`."
- Add a forward pointer to this report (by title/date, not task number, per
  `no-task-references-in-deliverables.md`'s deliverable-boundary rule — ModelChecker's own task
  system is `specs/**` and may cite task numbers freely there) as the source for the file-level
  targets in Q1/Q2 above, so whoever plans task 200's implementation has the `certificate.py`/
  `witness_registry.py`/`witness_constraints.py` mapping in hand rather than re-deriving it.

*Task 219 (ModelChecker, `bimodal_theory_limits_example_group`, currently `completed`).* This
task's own deliverable (the `examples.py` THEORY-LIMITS group) is now factually wrong on the
"STANDING CONSEQUENCE" framing and incomplete on scope (F8). Recommend **re-opening** it (status
`completed` -> reopened, a permitted non-terminal transition) for a follow-up amendment, not a
full task rewrite, scoped to exactly two changes:

1. Add the `Until`-side schema. `Fp -> (p \/ [stab]Fp)` (equivalently `(¬p ∧ Fp) -> [stab]Fp`,
   `stabUntlTarget` in BimodalLogic) needs its own "FACT 1"/"FACT 2" pair in the header comment
   (the Until-side ZTime non-validity is `not_plusValidZTime_stabUntl`; the — now-obsolete, see
   below — non-certification claim would have cited `not_plusCertifies_stabUntl`, which no longer
   exists in the tree) and its own nearest-expressible Box-analogue probe entries, mirroring
   `TL_CM_1`/`TL_CM_2`'s pattern (e.g. a `TL_CM_3`/`TL_CM_4` pair substituting `\Box` for `[stab]`
   in the Until-side schema).
2. **Correct the framing, not just extend it.** Both schemas' certificate classes are no longer
   empty (F0, F8) — `famA`/`famB` are landed counterexamples to the group's own "FACT 2" as
   currently worded. The group's header must be rewritten to say: as of BimodalLogic's landed
   `trans`/`Liftable` redesign, the certificate class for these two *specific* atomic schemas
   (`Pp -> [stab]Pp`, `Fp -> (p \/ [stab]Fp)`) is **non-empty** — concrete certifying families
   exist (`famA`/`famB`) — so this is no longer a standing completeness gap for these instances;
   what remains open is whether a *general*, guard/event-parametric family exists for every
   instance of the schema (an enumeration/compression question, BimodalLogic task 703's scope,
   not yet settled). The THEORY-LIMITS group's own inclusion criterion (b) — "no certificate ...
   exists at any time or size" — should be either dropped for these two entries or explicitly
   re-scoped to "no certificate has yet been constructed for every instance," with the two
   concrete instances moved out of "permanent theory limit" framing entirely, since they are not
   limits of the theory or of the verified side any more — they are a historical record of a
   defect that has since been repaired. This is exactly the distinction the dispatch itself
   draws: "the group's wording must distinguish a limit of the theory from a limit of a
   since-repaired certificate system," and the repair has now landed.

**Q4 — the wire-level contract, exact fields and defaults, nothing changes now.**

Confirmed against `semantic/certificate.py`, `semantic/formula.py`, all four
`tests/fixtures/certificates/*.json`, and `tests/integration/test_certificate_lean_agreement.py`:

- **`semantic/formula.py`**: no change, ever, for this extension. Its JSON codec (`to_json`/
  `from_json`, lines 236-392) covers only the `Formula` ADT (`atom | bot | imp | box | untl |
  snce`); `trans*` describes lasso-index succession, not formula structure, and has no formula.py
  analogue.
- **`semantic/certificate.py`**: the eventual landing spot, on `WitnessFamily` (not
  `LabelledLasso`; F6) — three new **optional** fields (`trans_back`/`trans_mid`/`trans_fwd`,
  defaulting to `None`), a corresponding optional key set in `WitnessFamily.to_json`'s output
  dict (omitted entirely when `None`, matching the Lean side's "absent means full"), and a
  corresponding optional read in `_lasso_from_wire`'s sibling for `WitnessFamily` (today
  `recheck_json` builds `WitnessFamily` directly from `raw.get("bx", [])`/`raw.get("lassos",
  [])`; a `trans*` triple would be a third `raw.get(...)` alongside those two, defaulting to
  `None`). No change needed today.
- **`tests/fixtures/certificates/*.json`**: none of the four fixtures carries a `trans*` key
  today (confirmed by reading all four); none needs to gain one now, and none would break if a
  `trans*`-aware decoder were added, since `raw.get("transBack", None)` on a fixture lacking the
  key returns `None`, the correct "full" default.
- **`test_certificate_lean_agreement.py`**: its bytewise echo comparison
  (`_lean_check.assert_echo_matches_sent`) compares whatever bytes `canonical_wire_bytes` sends
  against `lake exe check_certificate`'s parse-and-reprint; since `WitnessFamily.to_json` would
  omit `trans*` keys entirely when unset, the bytes sent for every existing fixture are unchanged
  bit-for-bit, so this test needs no change now and would not need one when the fields are added,
  provided the "omit when None" contract is honored (not "include as `null`" — Lean's canonical
  parser is documented elsewhere in this module's own docstring as rejecting interior whitespace
  and being sensitive to exact byte shape, so an explicit `null` key is a different wire payload
  from an absent key and should be avoided).
- **Confirmed nothing must change now**: no test, fixture, or production code path in
  ModelChecker's bimodal theory references `trans`, `Liftable`, or any sharing-shaped field
  anywhere in the tree today (grepped `semantic/`, `tests/`, `docs/` for `trans\b|Liftable|share`
  outside the already-quoted "extension point"/"Known Limitations" prose).

**Q5 — restating the Box case over threads ahead of sharing, as a refinement not a rewrite.**

Yes, and concretely: `docs/ADEQUACY.md`'s Lemma 2 (`H_F = {t -> (i, t+c)}`, i.e. `total_eq_orbit`)
is, in BimodalLogic's own vocabulary, exactly the statement `liftable_of_full` (round 1's
Recommendations Q2 step 3) discharges — "every current export is recovered by `transRaw := fun _
_ => true`" (round 1 F5) is the Lean-side mirror of "every fibre a singleton, no sharing." A
documentation-only restatement of Lemma 2 as "`total_eq_thread` specialized to the trivial
`trans := full` case" would: (a) require no Lean or Python code change; (b) make the eventual
extension (when and if ModelChecker chooses to build a sharing search) a matter of relaxing one
named special case rather than replacing an argument shape; (c) directly mirror
`ADEQUACY.md`'s own "Why the design is deterministic" section, which already gestures at this
("Adding state-sharing ... requires re-proving Lemma 2 and redesigning condition (C3)... citing
`total_eq_orbit` and the Box case of Lemma 4, not Limit and Saturation") without yet stating the
specialization explicitly. Recommend this as a **future**, low-priority documentation task on the
ModelChecker side (not this task's own deliverable to write, since this report's repository
boundary is research-only) — see the phased proposal below for its placement.

**Phased proposal: what to change now vs. later.**

| Phase | What | Why now / why later |
|---|---|---|
| **Now (this task)** | This report. Nothing else. | Research-first per the dispatch; the wire contract is additive so nothing is blocking. |
| **Next, low-cost, no dependency** | File the task-200 update and the task-219 reopen-and-amend (Q3), as ready-to-file ModelChecker task text — see below | Both are corrections to *already-written* ModelChecker artifacts that are now factually stale against the landed tree (F0); doing this promptly avoids the group's incorrect "STANDING CONSEQUENCE" framing propagating into anyone reading `examples.py` in the meantime. Independent of any certificate-search code change. |
| **Next, low-cost, no dependency** | The `docs/ADEQUACY.md` Q5 restatement (Lemma 2 as `total_eq_thread` specialized to `full`) | Documentation-only, zero regression risk, makes a real future extension cheaper. Not urgent, but cheap enough to bundle with the task-219 amendment pass. |
| **Blocked on BimodalLogic 703** | Any `WitnessRegistry`/`witness_constraints.py` sharing search (the actual Q2 items 1-2 as executable Z3 code) | Building a bounded sharing search without a compression/enumeration bound risks the same "searched object refutes the paper's own axiom" failure `docs/ARCHITECTURE.md`'s "Retired Designs" section already records for the window-and-abundance encoding — do not repeat that mistake by search-bounding a branching structure ad hoc. |
| **Blocked on the above, and on a ModelChecker-side decision to pursue sharing at all** | The `trans*` wire fields (Q2 item 3 / Q4) in `certificate.py`, `WitnessRegistry`, `WitnessConstraintGenerator` | Additive and safe to add early in isolation, but adding the fields before there is a producer that emits them or a consumer that needs them is dead code; sequence it with the search-code phase above, not before it. |

## Decisions

- This report treats BimodalLogic task 696 as **completed** for all purposes (F0), superseding the
  dispatch's own framing ("drawn from the landed redesign" — now literally true rather than
  aspirational) and ModelChecker task 200's still-`implementing` framing (F7).
- The `trans*` wire fields belong on `WitnessFamily`, not `LabelledLasso`, in
  `semantic/certificate.py` (F6) — this is a concrete implementation detail for whenever that
  phase is undertaken, recorded here so a future plan does not have to re-derive it.
- Task 219's amendment is scoped as a **reopen-and-amend**, not a full rewrite: the existing
  `TL_CM_1`/`TL_CM_2` entries, their measurements, and the correct (round-2) shape-mechanism
  explanation are all still accurate and should be kept verbatim; only the missing Until-side
  entries and the "STANDING CONSEQUENCE" framing need to change.
- No ModelChecker file was edited by this task. The re-scoped task-200 text and the task-219
  amendment above are research findings, stated as ready-to-file text for whoever next touches
  ModelChecker's own task system (per the dispatch's repository boundary, this task's
  implementation phase also edits no ModelChecker source directly).

## Risks & Mitigations

- **Risk**: this report's claim that 696 is "completed" could itself go stale if a further round
  of work reopens it. **Mitigation**: the claim is backed by both `specs/state.json`'s status
  field and a live grep of the landed theorems (F0), not merely a status label; a future reader
  should re-run the same grep (`grep -rn "transBack\|Liftable\|famA\|famB" FormalSystem/
  Metalogic/Decidability/{WitnessFamily/Sharing,PlusWitnessFamily}/`) before relying on this
  report's Q3 recommendations verbatim.
- **Risk**: recommending a `WitnessFamily`-level (not `LabelledLasso`-level) home for `trans*`
  fields is an inference from the Lean side's `SharingSkeleton`/family structure, not something
  BimodalLogic's hand-off README states explicitly for the Python side. **Mitigation**: flagged
  as a concrete implementation detail in Decisions above, not asserted as settled; a planner
  should re-confirm against whatever the Lean `SharingSkeleton` field placement looks like at
  implementation time, since 703's own work may reshape it further.
- **Risk**: the task-219 amendment recommendation (reopen a `completed` task) is a status
  transition the dispatch did not explicitly authorize this research task to perform, and this
  report does not perform it — it only recommends it. **Mitigation**: stated plainly as a
  recommendation for ModelChecker's own task system to execute, not an action this task took.

## Context Extension Recommendations

- **Topic**: cross-repository staleness detection for re-scoped tasks that cite another
  repository's task status. **Gap**: ModelChecker task 200's re-scoped text names BimodalLogic
  696's status as of a specific timestamp, and went stale within roughly five hours because 696
  completed shortly after. No mechanism currently flags "a task description asserts another
  repository's task status as of time T; that status has since changed." **Recommendation**: not
  a candidate for this report to resolve, but worth naming for a future `.claude/context/`
  pattern on cross-repository dependency tasks, if this project pattern recurs.

## Appendix

- Live-tree verification commands (BimodalLogic): `grep -n "transBack\|transMid\|transFwd\|
  Liftable" FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Skeleton.lean`;
  `grep -n "famA\|famB\|not_plusCertifies_stabSnce\|not_plusCertifies_stabUntl" FormalSystem/
  Metalogic/Decidability/PlusWitnessFamily/{Examples,Incompleteness}.lean`; `jq -r
  '.active_projects[] | select(.project_number==696) | {status,last_updated}' specs/state.json`.
- Live-tree verification commands (ModelChecker): `grep -n -i "untl\|stabUntl" examples.py`
  (zero relevant hits outside docstring prose); `grep -rn "trans\b|Liftable|share"
  semantic/ tests/ docs/` (only the already-quoted "extension point"/"Known Limitations" prose);
  `jq -r '.active_projects[] | select(.project_number==200 or .project_number==219) |
  {project_number,status,last_updated}' specs/state.json`.
- Files read in full, BimodalLogic: `specs/696_stability_modal_substrate_design/reports/
  01_stability-modal-substrate-design.md` (194 lines), `.../02_trans-redesign-gate-verification.md`
  (165 lines), `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/README.md`'s hand-off
  section.
- Files read in full, ModelChecker: `semantic/certificate.py` (565 lines), `semantic/
  witness_registry.py` (192 lines), `semantic/witness_constraints.py` (252 lines),
  `semantic/formula.py`'s docstring/codec, `docs/ADEQUACY.md` (911 lines), relevant sections of
  `docs/ARCHITECTURE.md`, `README.md`'s Known Limitations, `examples.py` lines 1335-1500, ModelChecker
  tasks 200 and 219 in full (`specs/state.json`), `tests/integration/
  test_certificate_lean_agreement.py`'s module docstring and wire-comparison logic,
  `tests/fixtures/certificates/*.json` (all four).
- Sibling tasks (this orchestrate cycle, per the dispatch's Territory block): BimodalLogic 703
  (`lplus_compression_and_completeness`, `FormalSystem/Metalogic/Decidability/
  PlusWitnessFamily/Compression/` file scope) and 650 (undeclared scope) — neither repository
  file was touched by this research task, consistent with the territory contract.
