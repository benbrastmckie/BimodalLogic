# Round 34 — Route (Q-1): the read-off / construction pair, and the evidence wiring

Phase 19 of `plans/34_readoff-construction-pair-restatement.md`, Ruling 35. This round wires the
four refutation units that the chain's exclusion records cite but that existed only in report
appendices. Nothing is re-derived, re-proved, renamed or repaired: every declaration below is the
report's own text, copied verbatim.

## 0. Entry gate, and why this phase ran instead of the one the dispatch named

Dispatch 83 was issued `Implement phase 12.5 only`. That selection was the product of a known
orchestration defect, re-measured at this phase's entry rather than assumed:

- The working-tree plan file carried **four** closed phase headings downgraded to `[PARTIAL]` —
  12.5 (`[COMPLETED]`), 12.6 (`[COMPLETED]`), 15.2 and 16 (both
  `[COMPLETED WITH EXCLUSIONS]`) — against the committed plan at `96db600f9`.
- Measured marker counts: HEAD = 36 `[COMPLETED]` + 27 `[COMPLETED WITH EXCLUSIONS]` + 12
  `[NOT STARTED]` + 2 `[PARTIAL]` = 77 headings, i.e. **63 closed**. Working tree = 34 + 25 + 12 +
  6 = 77, i.e. **59 closed**. The plan's own metadata line states `63 of 77 phases closed`.
- The surviving `.orchestrator-handoff.json` is **dispatch 82's**, written for Phase 11.49, before
  five research rounds and the v34 revision. Its `phases_completed` is **59**. The four
  downgrades are exactly the number needed to force the plan's count down to that stale figure.
- This is the H1 marker/handoff gate defect already recorded as `iss_1794847364431_bAgQCh`,
  whose recorded remedy is: when the revision sentinel is newer than the handoff, **the plan
  markers are authoritative** and the handoff count is resynced, rather than plan headings being
  edited. `.plan-revised.json` carries `revised_at: 1794872246`, newer than the handoff.
- Phase 12.5's three deliverables are landed and committed: `real_certBiInfK`
  (`LadderRealize.lean:549`), `real_certFwdK` (`:571`), `real_certBwdK` (`:610`).

The four headings were reverted to their committed values (the plan file is byte-identical to
`HEAD` on that account), and this dispatch executed the plan's genuinely live phase. Phase 19
carries `Depends on: none`, sits at **wave 1**, and the Dependency Analysis names it "the first
thing any dispatch should run".

**Escalation note.** Previous observations of this defect were one heading per revision. This one
is four, because the v34 revision closed four phases by exclusion at once. Ruling 28's structural
fix (relocate `[PARTIAL]` headings past every open phase) does **not** cover it: that ruling
relocates genuinely-`[PARTIAL]` headings, whereas this gate *manufactures* new `[PARTIAL]`
headings at arbitrary file positions, ahead of the relocation barrier.

## 1. The four units, their sources and their destinations

| # | Source | Destination | Lines |
|---|---|---|---|
| 1 | `reports/29_row-link-route-viability.md` Appendix A, lines 153–393 | **NEW** `specs/evidence/seam-gluing-ray-product/ladder-gap-jump-refutation.lean` | 241 |
| 2 | `reports/29_row-link-route-viability.md` Appendix B, lines 401–446 | appended to `ladder-cell-agreement-refutation.lean` | 46 |
| 3 | `reports/32_laddermodel-construction-falsifier.md` Appendix, lines 175–323 | appended to the same file, **after** unit 2 | 149 |
| 4 | `reports/33_exponential-clip-cell-constancy.md` Appendix, lines 163–683 | **NEW** `specs/evidence/seam-gluing-ray-product/ladder-chain-object-clip-refutation.lean` | 521 |

Each extraction was taken at exactly the plan's stated line range and the resulting line counts
(241 / 46 / 149 / 521) match the plan's figures exactly. Unit 3 `open`s `Probe761C`, so it is
appended after unit 2; the existing file's final `end Probe761C` is followed by unit 2 reopening
that namespace, which is legal and compiles.

## 2. The import correction, confirmed against the live modules

Report 32 instructs replacing the import with `LadderRealize`; report 29 Appendix B instructs
`LadderStepFrag`. Units 2 and 3 land in the same file, so neither literal instruction serves both.
The import graph was re-read from each module's own `import` lines at this phase's entry:

```
LadderStepFrag → LadderRealize → LadderChain → LadderPump → LadderAgree
```

So the single line `import FormalSystem.Metalogic.Decidability.RaySummary.LadderStepFrag`
transitively supplies `typeOfCl` (via `LadderRealize`), `mem_cellAt_ladder_iff` (via
`LadderAgree`) **and** `Mrel`. That is the line this phase wrote at line 68, replacing
`…LadderAgree`. **It compiled on the first attempt with both units present**, which is the
derivation's confirmation: the plan's one derived departure from both reports was correct, and a
dispatch following either report literally would have broken the other unit.

## 3. Compilation and axiom profiles

All three files compiled through `lake-build-guard.sh`, each `exit_status=0` with zero warnings.
**No block required any repair**: there is no drift to record between the commits the appendices
compiled against and the tree at `96db600f9`.

Unit 1 — `ladder-gap-jump-refutation.lean`:

```
'ProbeGapJump.region_exit_register'            [propext, Classical.choice, Quot.sound]
'ProbeGapJump.no_rowLinked_path_gap'           [propext, Classical.choice, Quot.sound]
'ProbeGapJump.exists_rowLinked_path_K1_refuted' [propext, Classical.choice, Quot.sound]
'ProbeGapJump.no_rowLinked_path_gap_any_room'  [propext, Classical.choice, Quot.sound]
```

Unit 4 — `ladder-chain-object-clip-refutation.lean`:

```
'Probe761G.chainC_cell_ne'                [propext, Classical.choice, Quot.sound]
'Probe761G.gap_clip_refuted_at_every_clip' [propext, Classical.choice, Quot.sound]
'Probe761G.no_formula_only_clip'          [propext, Classical.choice, Quot.sound]
'Probe761G.exponential_clip_refuted'      [propext, Classical.choice, Quot.sound]
```

Units 2 and 3 — appended to `ladder-cell-agreement-refutation.lean`:

```
'Probe761C.cell_agreement_over_Mrel_refuted'           [propext, Classical.choice, Quot.sound]
'Probe761C.cell_agreement_over_Mrel_refuted_at_depths' [propext, Classical.choice, Quot.sound]
'Probe761F.no_keyed_cell_map'                          [propext, Classical.choice, Quot.sound]
'Probe761F.no_construction_receives_ladderModel'       [propext, Classical.choice, Quot.sound]
'Probe761F.no_dmax_construction_receives_ladderModel'  [propext, Classical.choice, Quot.sound]
'Probe761F.ladderModel_realizes_no_set'                [propext, Classical.choice, Quot.sound]
'Probe761F.no_keyed_cell_map_below_exponential'        [propext, Classical.choice, Quot.sound]
'Probe761F.no_slice_respecting_injection'              [propext, Classical.choice, Quot.sound]
'Probe761F.no_slice_respecting_injection_into_set'     [propext, Classical.choice, Quot.sound]
```

Every profile is a subset of `[propext, Classical.choice, Quot.sound]`. No `sorryAx`, no custom
axiom, no `native_decide`, in any of the three files.

## 4. The citation map — which phase's exclusion record each unit holds in place

| Declaration | Wired at | The phase whose record cites it |
|---|---|---|
| `exists_rowLinked_path_K1_refuted` | `ladder-gap-jump-refutation.lean` (unit 1) | **11.49**, closed by exclusion: the path forth is false at that phase's own two-hypothesis signature |
| `no_rowLinked_path_gap_any_room` | same file (unit 1) | **11.40**, closed by exclusion: equal countdowns of arbitrary size, so no countdown-side repair revives the route |
| `cell_agreement_over_Mrel_refuted` | `ladder-cell-agreement-refutation.lean` (unit 2) | **15.2**, closed by exclusion: the route's own projected end result |
| `no_dmax_construction_receives_ladderModel`, `ladderModel_realizes_no_set` | same file (unit 3) | **16**, closed by exclusion: falsifier (4) failed with a compiled reason |
| `no_keyed_cell_map_below_exponential` | same file (unit 3) | **16** and **22**: the sub-exponential boundary of the open question |
| `no_formula_only_clip`, `exponential_clip_refuted` | `ladder-chain-object-clip-refutation.lean` (unit 4) | **16**, closed by exclusion, and **22**, which records the object-dependent clip as a NAMED OPEN QUESTION with exactly this compiled boundary |

## 5. Ruling 35's mechanical check

Before this phase:

```
grep -rnE '(theorem|lemma) +(no_keyed_cell_map_below_exponential|no_formula_only_clip|exists_rowLinked_path_K1_refuted|cell_agreement_over_Mrel_refuted)\b' specs/evidence/
```

returned **no hits**, re-run at this phase's entry and confirmed. After this phase it returns
**four hits**, one per declaration. Both new files are **tracked** (`git ls-files
--error-unmatch` exits 0 on each), which `check_probe` tests and reports as a failure otherwise.

`bash scripts/check-evidence-probes.sh` exits **0**: `PASS  all 67 wired probe(s) compile`, with
both new probes named PASS in its output and zero FAIL rows.

## 6. What this round does NOT do

It wires evidence; it changes no mathematics. No declaration was re-proved, restated, renamed,
weakened or strengthened; nothing was moved out of `specs/evidence/`; nothing was landed in
`FormalSystem/`. The read-off half (Phase 20) and the construction half (Phase 21) are untouched
and remain unwritten, and the object-dependent clip remains the one unrefuted route and an open
question, not a closed one.

---

# Phase 22 — The object-dependent clip, recorded as a NAMED OPEN QUESTION

Phase 22 of `plans/34_readoff-construction-pair-restatement.md`, decision 26 obligation 5,
Ruling 36. **This section records a question and does not answer it.** No clip is adopted, no
agreement is attempted, no Lean declaration is landed, and `paramsOkK4`, `Bof` and `ParamsOk` are
not edited. The object-dependent clip `B(Q, φ)` is **the one route in this chain that is not
refuted**; recording it as dead would be as wrong as adopting it untested, and this task has spent
five rounds learning the cost of the second error.

## 7. The boundary, stated exactly

Every row carries COMPILED, INFERRED or OPEN, and every COMPILED row cites a **wired** probe path
under `specs/evidence/` together with the declaration name. Each line number below was re-measured
against the live file in this dispatch, not quoted from the plan.

| Claim | Status |
|---|---|
| Every clip that is a function of the FORMULA alone fails, at every `(Tc, Tn, P)` | **COMPILED** — `no_formula_only_clip (E : PlusFormula → ℕ)`, quantified over ALL `E`, wired at `specs/evidence/seam-gluing-ray-product/ladder-chain-object-clip-refutation.lean:521` |
| The exponential clip `E φ := 2 ^ (dBack φ + 1)` fails | **COMPILED** — `exponential_clip_refuted`, its instance, wired at `specs/evidence/seam-gluing-ray-product/ladder-chain-object-clip-refutation.lean:555` |
| On `Qc`, every clip `B` with `B + 1 ≤ 2 ^ (j + 1)` fails at `dblC j` | **COMPILED** — `gap_clip_below_exponential_refuted`, wired at `specs/evidence/seam-gluing-ray-product/ladder-cell-agreement-refutation.lean:3295` |
| The same, for the keyed cell map rather than the agreement | **COMPILED** — `no_keyed_cell_map_below_exponential`, wired at `specs/evidence/seam-gluing-ray-product/ladder-cell-agreement-refutation.lean:3482` |
| The refuting chain family reaches up to `card Q − 2` and no further | **COMPILED** — at `Qm m` (`…/ladder-chain-object-clip-refutation.lean:70`, `abbrev Qm (m : ℕ) := Fin (m + 3)`, so `card Q = m + 3`), `chainC_cell_ne` (`:433`) separates gap `m + 1` from gap `≥ m + 2` under `hgap : c + m + 2 ≤ n'`. A `kappa`-collision needs both gaps saturated at the clip, so the family speaks only for `B ≤ m + 1 = card Q − 2` and is **silent at `B ≥ m + 2`** |
| Any surviving clip is of order `card Q · 2 ^ (dBack φ)` | **INFERRED, NOT COMPILED** — report 33 F4 did not build the `lvlC` induction over `Qm m`. **No record states this as compiled, and this one does not either.** |
| Cells are constant on `kappa`-classes at some `B(Q, φ)` | **OPEN** — neither proved nor refuted, by anyone, anywhere |

**The accurate scope sentence, which supersedes any shorter one**: below `2 ^ (dBack + 1)` refuted
on `Qc`; at every formula-only clip refuted on the chain family; an object-dependent clip OPEN.

**A correct clip EXCEEDS the clips at which the filed families separate; it never reproduces
them.** `Bof thetaC = 3` and `Bof (mixC (k + 2) k) = 2 · k + 5` are the clips that FAIL; the
compiled non-collision results stand at `B ≥ 4` and `B ≥ 3 · k + 5`.

## 8. The missing piece for a positive result, named

A closure theorem for definable register sets on ARBITRARY finite objects:

1. **which sets of idle registers are definable at each operator depth** — conjecture: eventually
   periodic with period dividing `P + 1` and threshold `≤ T(Q, depth)`;
2. **closure of that class under the four jump moves and under `⊡`'s re-selection**, with `T`
   solving Ruling 32's jump recurrences;
3. **the same for pending states**, where the gap is converted to an exit register.

`grep` finds no statement of (i)–(iii) anywhere in the tree, re-run at this phase's entry. The
nearest compiled objects are probe-level and object-specific: `stepFrag_gap_depth_exact`
(`specs/evidence/seam-gluing-ray-product/ladder-step-fragment-gap-depth.lean:1160`), **step
fragment only** — the step fragment admits `untl`/`snce` only at the guard `⊥`, and `thetaC` and
`mixC` each use one jump and are therefore **NOT covered** by it — and `nxt_le_double`
(`specs/evidence/seam-gluing-ray-product/ladder-cell-agreement-refutation.lean:3018`), on `Qc`
only.

**This is Phase 11.7 at a larger clip — a theorem-sized programme, not a missing lemma.** Phase
11.7's own `#### Reasoned Exclusions` record (this plan, under
`### Phase 11.7: The Agreement cellAt_const_of_kappa_eq [COMPLETED WITH EXCLUSIONS]`) closed the
filed Goal at the filed clip and again at the repaired clip, and its third row records that no
weakened, regime-narrowed or same-named restatement may be landed under
`cellAt_const_of_kappa_eq`. Nothing in this section relaxes that; the open question here is a
DIFFERENT claim — a clip reading the OBJECT — under a signature that does not yet exist.

## 9. The signature cost, and why taking it is a user decision

| Object | Where | What it reads today |
|---|---|---|
| `paramsOkK4 (φ : PlusFormula) (B : ℕ)` | `FormalSystem/Metalogic/Decidability/RaySummary/CounterQuotient.lean:920` | the FORMULA and the clip; no object binder |
| `Bof` | same file, `:854` | `max (2 * dBack φ + 1) (max (2 * dFwd φ + 1) 2)` — the FORMULA alone; its three object binders are documented in its own body as unused |
| `paramsOk_params` | same file, `:938` | the discharge lemma for the whole tuple |
| every statement carrying `ParamsOk` as a hypothesis | across `RaySummary/` | the tuple as filed |

An object-dependent clip edits a pinned predicate and its discharge lemma, hence every consumer.
**That is a Statement Fidelity change** (`.claude/rules/plan-compliance.md`): the theorem text of
the Challenge block would be unchanged while `ParamsOk`'s MEANING changed. It is therefore routed
to the user and is not taken by any phase of this plan.

**The order of `K` is NOT the obstacle.** `K = (Tc + 1) · (P + 1)² · (Tn + 1) · (2 B + 1)`, and
`Tcof` (`CounterQuotient.lean:820`) already carries
`Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * (Pof + 1) * (stabDepth sup + 1)` — so `K`
is already exponential in the formula and already reads `card Q`. The worry that an
object-dependent clip would make `K` exponential is moot: it is exponential today.

## 10. What an attack-first round would do, if the user ever takes it

Ruling 31's discipline applies: **attack before adopt**. Every hypothesis adopted untested in this
task (`Zrel`, `Srel`, `Mrel` as filed) turned out refuted; the two rounds that attacked first
(11.44, 11.48) are the ones whose hypotheses survived. So such a round would, in this order:

1. **First compile the composed `card Q · 2 ^ (dBack φ)` lower bound** — the `lvlC` induction
   re-proved over `Qm m` — so that the figure stops being INFERRED. Until that compiles, no clip
   is even stated.
2. **Then attack**, with two families the chain family does not reach: two-chain objects of
   DIFFERENT lengths joined at the pending state, and objects whose pending region must traverse a
   cycle.
3. **Only then**, and only if both attacks fail, a proof attempt — which would owe (i)–(iii) of
   §8 and the signature change of §9.

## 11. The scope-sentence sweep, and a plan defect found while running it

The sweep is for the stale sentence saying that the sub-exponential refutations `leave(s) the
exponential clip open`. It returns **no assertion of that sentence anywhere in the tree**. The
only hits were inside Phase 22's OWN text in the plan: the task bullet that quoted the sentence in
order to ask for its correction, and the verification criterion, whose filed form spelled the
pattern out as two literal alternatives. **That criterion was unsatisfiable by construction** — it
greps a directory that contains the grep, so writing the criterion down falsifies it, and so does
writing down any faithful record of having run it.

The repair is a pattern, not an exclusion list: the criterion now uses the single regex
`leaves? the exponential clip open`, which matches both inflections while **not itself being a
literal occurrence of either**, so the criterion line, this record and the task bullet are all
exempt by construction rather than by a `grep -v` that could also hide a genuine hit. The one
carved-out path is `issues.jsonl`, the machine capture log, whose entry on this very defect quotes
the sentence as its content; it is a capture log, not prose. The substantive check the criterion
exists to make — that nothing in the tree ASSERTS the stale sentence — is discharged and passes.
Nothing else in the tree's prose was edited, because nothing else said it.

## 12. What this section does NOT do

No clip is adopted. No agreement is attempted. No phase of this plan takes this route. The
question is not described as settled, likely, nearly-settled or dead, and the
`card Q · 2 ^ (dBack φ)` figure is not stated as compiled. `paramsOkK4`, `Bof` and `ParamsOk` are
unedited, Phase 11.7 is not re-opened, and no `sorry`, `axiom` or vacuous definition was written.

---

# Phase 21 — The CONSTRUCTION half: THE CARRIER, STATED FIRST

**Dispatch 86. This section was written and committed BEFORE any Lean of this phase, which is
Phase 21's own first verification item ("the record names the carrier and its slice cardinality
before the frame's definition in commit order; a phase whose first commit is a frame fails this
check").**

## 13. Which phase this dispatch ran, and why it is not the one the Phase Mission named

Dispatch 86's Phase Mission named **Phase 11.44**. That heading's `RE-ENTRY NOTICE` is a RULE and
not a number: *"a dispatch that selects this heading because `[PARTIAL]` parses as open executes
THE FIRST OPEN PHASE AT OR AFTER 11.48 IN FILE ORDER — evaluated against the live file — and says
in its record that it did so."* Evaluated against the live plan, the phases at or after 11.48 in
file order are 11.48 `[COMPLETED]`, 11.49 and 11.40 `[COMPLETED WITH EXCLUSIONS]`, 12.1
`[COMPLETED WITH EXCLUSIONS]`, then **12.2 `[BLOCKED]`** — the first open one.

Phase 12.2 is not entered. Its own `BLOCKER` record says, in its "What is needed" line, that what
it needs is **a route decision (a `/revise`)**. Decision 27 — cycle 2, `2026-11-17T00:51:09Z`, the
most recent recorded decision and the only one in the dispatch's `## Prior Decisions` block NOT
marked POTENTIALLY SUPERSEDED — IS that route decision, and it routes past 12.2 by name:

> **(C) Enter the CONSTRUCTION half (Phase 21) first and defer the READ-OFF half**: Phase 21
> takes `certAdmK` as an EXPLICIT hypothesis on an arbitrary `R` and is untouched by this
> refutation, so it is enterable now; the READ-OFF half's target is then chosen with the
> construction's output in hand.

Its Obligation: *"Land Phase 21's CONSTRUCTION half (`certAdmK` as explicit hypothesis on an
arbitrary `R`), then choose Phase 20's READ-OFF right-hand side using the constructed model as
evidence; do NOT restate the READ-OFF target (option B) before the construction exists."* This
dispatch therefore ran **Phase 21**, and this paragraph is the record that it did so.

## 14. THE CARRIER

**Stated before any Lean, as the phase requires.**

```lean
/-- The construction's carrier slice: the KEYS realized in `R`. -/
def ConKey {Q : Type} (φ : PlusFormula) (Tc Tn P B : ℕ)
    (R : Set (Q × ClType φ × CK Tc Tn P B)) : Type :=
  {s : Q × CK Tc Tn P B // ∃ S : ClType φ, (s.1, S, s.2) ∈ R}
```

The frame's world-state type is then `ℤ × ConKey φ Tc Tn P B R`, through
`ofSlicedStepFinBranch`, and the key map the pinned statement asks for is **the subtype
projection**:

```lean
key : ℤ × ConKey … → Q × CK Tc Tn P B := fun u => u.2.val
```

**Slice cardinality — FINITE, and the exact count.**
`ConKey` embeds into `Q × CK Tc Tn P B`, so

> `card (ConKey φ Tc Tn P B R) ≤ card Q · (Tc + 1) · (P + 1) · (Tn + 1) · (P + 1) · (2B + 1)`

a COUNT of candidate keys and no bound on anything. The world-state type `ℤ × ConKey` is
infinite — through `ℤ`, exactly as `ofSlicedStepFinBranch_not_finite_worldState` records for
every frame of this scheme — but **the SLICE is finite**, and §19 below records that as this
phase's width finding rather than repairing it with an assumption.

**Why it is NOT the `frameOf` idiom.** `frameOf`/`modelOf` (`RaySummary/Realize.lean:689`, `:725`)
takes the certified set ITSELF as its slice: its points carry the closure type as a coordinate.
`ConKey`'s points do not — **the closure-type coordinate is projected away, and that projection is
the whole content of the carrier choice** (§15). The four counts Phase 21's body already records
against `frameOf`/`modelOf` are unaffected and are not restated here; this is a fifth and
independent reason, and it is the one that bites: a carrier whose points carry a closure type
cannot satisfy the pinned cell equation at all, by §15.

**Why it is not the ladder carrier `LadderState Q pend`.** The pinned statement's FIRST conjunct is
coverage — `∀ x ∈ R, ∃ u, key u = (x.1, x.2.2)` — so every counter CLASS occurring in `R` must be
the key of some carrier point. Over the ladder carrier the key of `(q, c, n)` can only be
`(q, kappa Tc Tn P B (c, n))`, and `kappa` is not surjective onto `CK Tc Tn P B`: its first two
coordinates are `min c Tc` and `c % (P + 1)`, which are not independent below the threshold, so
e.g. a class whose first coordinate is `2 < Tc` and whose second is not `2 % (P + 1)` has no
preimage. `certAdmK` places no constraint confining `R`'s classes to `kappa`'s image, so coverage
over the ladder carrier is not available for an arbitrary certified `R`. (Status: the
non-surjectivity is elementary arithmetic and is stated here as such; the step from it to "some
certified `R` actually contains an off-image class" is NOT compiled and is NOT claimed — what is
claimed is only that `certAdmK` does not rule it out.)

## 15. WHY THE CARRIER IS FORCED TO BE KEY-LEVEL — and why the runs-based carrier Phase 21's body expects does NOT satisfy the pinned equation

Phase 21's body says *"a runs-based carrier — GKWZ's `W × R` with `R` a set of runs, which is not
finite — is the shape the literature uses"*. **That orientation does not survive contact with the
pinned statement, and this is this dispatch's principal finding.** The reason is the semantics of
`cellAt`, not a preference:

`cellAt M φ u 0 = {tpOf M φ σ 0 | σ.state 0 = u}` — the cell at a world state is the set of types
realized by the histories THROUGH THAT STATE. The pinned conclusion demands

> `cellAt M φ u 0 = {T | ∃ S, typeOfCl S = T ∧ ((key u).1, S, (key u).2) ∈ R}`

i.e. the cell is the WHOLE fibre of `R` over `key u`. A fibre with two distinct closure types
therefore forces **two histories through the one world state `u` realizing two different types**.

Now take the runs carrier in its literal form — world states the runs of `R` (bi-infinite
`relK`-paths inside `R`), stepped by the SHIFT, which is the only step relation that makes a run a
run. That relation is deterministic in both directions, so by
`ofSlicedStepFinBranch_mem_HF_iff` the history through a world state is UNIQUE and every cell is a
singleton. The pinned equation would then force every fibre of `R` to be a singleton — which
`certStabK` not only fails to give but is interesting precisely when it fails, since its clause
quantifies over the fibre. **The runs-with-shift carrier therefore cannot satisfy the pinned
equation for a general certified `R`.** (Compiled status: §18. The general design observation that
follows — any carrier whose world state DETERMINES a member of `R`, under a truth lemma reading
the type off that member, collapses the cell to a singleton — is INFERRED, not compiled, and is
marked as such wherever it is used.)

What the argument leaves is forced: the world state may determine the KEY and must not determine
the member; the type multiplicity has to come from the frame's BRANCHING. `ConKey` is that
carrier. The three certificate clauses then read exactly as the model-side facts they have to
match, which is the independent reason to believe the keying is right rather than merely forced:

| Certificate clause | Model-side equation | Match |
|---|---|---|
| `certStabK`: `⊡ψ ∈ x.2.1 ↔ ∀ y ∈ R, y.1 = x.1 → y.2.2 = x.2.2 → argOf ψ ∈ y.2.1` | `stab_mem_tpOf_iff`: `⊡ψ ∈ tpOf(σ,z) ↔ ∀ σ' through `σ.state z`, ψ ∈ tpOf(σ',z)` | the `⊡` bit is read off the fibre over `(q, κ)` on one side and off the cell of one world state on the other — the SAME object exactly when the cell is that fibre |
| `certBoxK`: `□ψ ∈ x.2.1 ↔ ∀ y ∈ R, argOf ψ ∈ y.2.1` | `box_mem_tpOf_iff`: one GLOBAL bit over all histories and times | matches when the model's points are exactly `R`'s keys |
| `certLocK` | the valuation reads `lab` at the object coordinate | matches, atoms depending on `q` alone |

A consequence worth recording, because it is what makes the keying CONSISTENT rather than merely
forced: by `certStabK` and `certBoxK`, all members of one fibre agree on every `⊡`-letter and
every `□`-letter, and by `certLocK` they agree on atoms. **Members of a fibre can differ only in
temporal (`untl`/`snce`) content** — which is precisely the content a branching frame can
distinguish between histories through one state.

## 16. THE STEP RELATION — two candidates, and the tension that is this phase's real obstruction

Both candidates are the projection of `relK` along the key map; they differ in the quantifier.

```lean
-- WEAK (existential): the image of relK on keys
conStep s s' := ∃ x ∈ R, ∃ y ∈ R, key x = s ∧ key y = s' ∧ relK … x y

-- STRONG (uniform): every member at s steps to some member at s', and conversely
conStepStrong s s' := (∀ x ∈ R, key x = s → ∃ y ∈ R, key y = s' ∧ relK … x y)
                    ∧ (∀ y ∈ R, key y = s' → ∃ x ∈ R, key x = s ∧ relK … x y)
```

- **The WEAK relation is SERIAL** — directly from `certBiInfK`, which hands every member a
  successor and a predecessor inside `R` — **but it is not LIFTABLE.** The truth lemma's `⊆`
  direction needs every bi-infinite `conStep`-path through `s` to lift to a `relK`-path inside
  `R`, and a chain of individually-witnessed edges need not compose: the witness `y` chosen for the
  step `s → s'` and the witness chosen for `s' → s''` may disagree at `s'`, and nothing in
  `certAdmK` reconciles them.
- **The STRONG relation is LIFTABLE** — by dependent choice a `conStepStrong`-path lifts forward
  and backward from ANY chosen member of the fibre at position `0`, which gives BOTH directions of
  the truth lemma at once (`⊇`: lift through the chosen `x`; `⊆`: lift through some `x`, and its
  type is in the fibre by construction) — **but its seriality is not available.** It asks for a
  single key `s'` that serves EVERY member over `s` at once, and `certBiInfK` gives only a
  per-member successor.

**This tension is the construction's open content**, and it is where GKWZ's own machinery sits:
their maximal set is obtained *by elimination*, and elimination is exactly the device that would
make the uniform relation serial on what survives. Here `R` is an arbitrary `certAdmK`-certified
set carried as an explicit hypothesis, so no elimination has been run on it, and restricting `R`
is not available — the pinned equation names the fibres of the GIVEN `R`.

## 17. WHAT THIS DISPATCH LANDED

See §18 for the compiled inventory and §20 for what is not claimed.

## 18. (Filled in after the Lean of this phase — see the Phase 21 compiled inventory below.)

## 19. ADMISSIBILITY AND WIDTH — this phase's finding, recorded rather than repaired

Phase 21's own task list asks for this, and the answer is recorded as a finding and not repaired
by an assumption: **the constructed frame's SLICE is finite** (§14), so the model has finite
width, and guardrail (b)'s "infinite width, no fibre bound" is NOT met by this carrier. Three
things follow, and none of them is papered over:

1. No finite-width or finite-fibre HYPOTHESIS was added anywhere — the finiteness is a property of
   the constructed output, not an assumption on an input. `R ⊆ Q × ClType φ × CK Tc Tn P B` is
   finite whenever the object is, which is a COUNT of candidates and the same count
   `CounterQuotient.lean` already records for `Dmax`'s family.
2. The finiteness is FORCED by §15 together with the pinned key map, not chosen: the carrier may
   not carry the closure type, and the key coordinate `Q × CK` is finite by construction.
   `Probe747.modelOf_incomplete`'s WIDTH fact is therefore not contradicted but inherited — a
   model of this shape is not a candidate for the decidability consumer, and no record here says
   it is.
3. `ZTime`-admissibility is NOT claimed for the constructed model in this dispatch. The frame is
   regular (`ofSlicedStepFinBranch_isRegular`); nothing further is asserted.

**The consequence for the read-off/construction pair, stated plainly**: half (ii) at this carrier
is a statement about `certAdmK`-certified sets and their fibres, and it is NOT a construction of a
countermodel for a decidability argument. Whether a carrier exists that satisfies the pinned
equation AND has infinite width is open and is asserted nowhere.

## 20. WHAT THIS PHASE DOES NOT ESTABLISH

`ladderConstruct` is NOT landed: its second conjunct, the cell equation, is the truth lemma and is
open, blocked at the tension of §16. Nothing is landed under `ladderRealized` or
`cellAt_const_of_kappa_eq`, both of which remain unclaimed in `FormalSystem/` and `Tests/`. No
construction is stated at `Dmax` — `dmax_certStabK` and `dmax_certBoxK` still have no hits, and
whether to attempt them is reported, not taken. The constructed model is not claimed to be, or to
be isomorphic to, `ladderModel`; that is refuted
(`no_dmax_construction_receives_ladderModel`, `ladderModel_realizes_no_set`, wired by Phase 19).
The transfer to GKWZ is BY SHAPE: `certStabK` reading as `(qm1)`, `cellAt` as the quasistate
read-off and `Dmax` as the maximal satisfying set is an identification of shape, and **no theorem
of GKWZ §5.2 (Theorem 5.22, Lemma 5.24, Theorem 6.61) or of HWZ 2000 applies to this semantics** —
HWZ has no `□` and no `⊡` at all, and this setting is not PTL × S5 (`stab_state_only`). No
`sorry`, `axiom`, `native_decide` or vacuous definition was written.
