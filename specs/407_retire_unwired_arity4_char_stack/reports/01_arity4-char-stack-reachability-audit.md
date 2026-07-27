# Research Report: Dead-code reachability audit for the unwired arity-4 characteristic-formula stack

- **Task**: 407 - retire the unwired arity-4 characteristic-formula stack
- **Started**: 2026-07-27T18:20:00Z
- **Completed**: 2026-07-27T19:05:00Z
- **Effort**: medium
- **Dependencies**: None (task 379 already landed the winning zeta route)
- **Sources/Inputs**:
  - Codebase: `FormalSystem/Metalogic/WeakCanonical/Kamp/KampPrior.lean`,
    `.../Kamp/NfMultiAnchorBridge/{CarrierKv,InteriorGateGeneralK,ExteriorGateAssembleK}.lean`
  - Codebase (must-not-touch): `.../Kamp/NfMultiAnchorBridge/{ExteriorFiberK,ExteriorFiberDeepAnchorK,ExteriorNegationK,ExteriorNegationPastK,ExteriorPinnedConverseK}.lean`
  - Archive: `.../Kamp/Boneyard/{InteriorHrealSupplyK,SeamPairRefutationProbe,ZoneSeamCrossContextProbe}.lean`, `.../Kamp/Boneyard/README.md`
  - Build config: `lakefile.lean`, `FormalSystem.lean`, `scripts/check-module-invariants.sh`, `scripts/module-invariants-manifest.txt`, `scripts/readme-lint.sh`
  - Adjudication: `specs/377_transcribe_rabinovich_faithful_nf_encoding/reports/06_kampprior-520-adjudication.md` section 6 item 3
  - Live verification: `lake env lean` probe with a bogus-identifier control (see Appendix A)
- **Artifacts**: this report
- **Standards**: status-markers.md, artifact-management.md, tasks.md, report-format.md

## Executive Summary

- The arity-4 characteristic-formula stack is a **closed reference island of exactly 30
  declarations** across the four in-scope files. Every consumer of every member is itself a
  member. No live declaration, in `FormalSystem/` or `Tests/`, references any of them.
- The island occupies **four contiguous, cleanly-delimited source blocks totalling 1,736 lines**;
  each block begins at a section-header comment and ends immediately before a `end`/blank
  boundary, so removal is four whole-block deletions with no interleaving of live code.
- The `Fib` name-collision trap in the task description is **confirmed and slightly larger than
  stated**: `igOffFiber` (`InteriorGateGeneralK.lean:329`) is listed in the task as family (a) but
  is in fact **LIVE** — consumed by three arity-1 theorems. It must NOT be deleted. `igAllSubs`
  (`:1439`), not listed in the task, **is** dead and must be included.
- Baseline verified live, not assumed: `completeness_discrete` and `kampPriorExpressiveCompleteness`
  both report `[propext, Classical.choice, Quot.sound]`; the live sorry census is exactly 5
  (4 in `Soundness.lean` at 1461/1472/1486/1509, 1 in `Transfer.lean:1242`). A deliberately bogus
  identifier in the same probe errored with `lean.unknownIdentifier`, so the probe is trustworthy.
- **Recommendation: Boneyard, not raw excise.** Three already-archived members of this same stack
  (`Boneyard/InteriorHrealSupplyK.lean`, `SeamPairRefutationProbe.lean`,
  `ZoneSeamCrossContextProbe.lean`) still name eight of the island's symbols; relocating the code
  into a co-located `Kamp/Boneyard/` file keeps the archive internally coherent, which the Boneyard
  README explicitly asks for.
- **Two prose records must be relocated, not deleted** — they document LIVE code and would be lost
  in a blind block deletion: the machine-confirmed circularity record at
  `InteriorGateGeneralK.lean:1646-1670` (which names `igFoldBit_realize_iff`, live at `:611`) and
  the M1/F1 fold-information-loss refutation record at `CarrierKv.lean:503-516` (which explains why
  the live frozen `bracketEndCharKv` folds).

## Context & Scope

The routing question this stack belonged to is settled. Task 379 discharged the `KampPrior` k>=2
residual through the zeta wire (`kampArm_zeta`, `Kamp/ZetaUniformExtract.lean`) using Rabinovich's
faithful unary `E[Sigma]`-atom encoding, keeping `charF` arity-1 end-to-end. The arity-4 stack is
the losing branch. The 377 Phase 9 adjudication (section 6 item 3) directed that it "be excised or
Boneyarded, not consumed".

This report answers exactly one question: **which declarations can be removed without breaking
anything, and what must be preserved instead of deleted?** It proposes no mathematics, no wiring,
and no repair — those are the task's explicit non-goals.

Scope boundary respected: no findings below propose edits to `FormalSystem/Metalogic/Soundness.lean`
(owned by two concurrent tasks). It is referenced only as a read-only sorry-census baseline.

## Findings

### 1. Method: reference-closure over the build graph, not name patterns

The audit was performed by (a) computing the transitive import closure of the Lake roots, (b)
stripping Lean comments and docstrings from every file in that closure, (c) attributing every
identifier occurrence to its enclosing declaration, and (d) computing, for each candidate, the set
of declarations that reference it.

Two properties of that method matter:

- **Docstrings and comments are excluded from the reference graph.** The four in-scope files are
  unusually prose-heavy; a raw `grep` reports 104 hits for `igFoldBitFib` where only 57 are code.
  Prose references are tracked separately (finding 6) because they are a documentation obligation,
  not a build obligation.
- **Attribution is conservative.** Text between two declaration headers is attributed to the
  earlier declaration, so an unnamed `example` or a stray `set_option ... in` block cannot hide a
  reference. This is what caught `InteriorGateGeneralK.lean:1417`, an unnamed `example` that
  consumes the LIVE arity-1 `bracketEndChar_kv_correct_prior` and sits 7 lines above the island's
  first line.

### 2. The build graph: Boneyard is never compiled; all four in-scope files are

`lakefile.lean` declares `lean_lib FormalSystem` with `roots := #[`FormalSystem]` and
`lean_lib BimodalTest` with `roots := #[`BimodalTest]` — no `globs`. The transitive import closure
of those two roots is **318 modules, of which zero are under any `Boneyard/` directory**. All four
in-scope files are in the closure. This matches the Kamp Boneyard README's stated policy: "Boneyard
code is never compiled... liveness equals reachability."

Consequence: references to island symbols from `Boneyard/InteriorHrealSupplyK.lean` and
`Boneyard/ZoneSeamCrossContextProbe.lean` are **not build edges** and do not block deletion. They
are, however, an archive-coherence consideration (finding 7).

### 3. The excision set: 30 declarations, closed under "is-referenced-by"

Every declaration below was checked for consumers across the full 318-module closure. In every
case, all consumers are themselves members of this list. Four members have no consumer at all and
are the island's sinks.

| # | Declaration | Kind | File : line |
|---|---|---|---|
| 1 | `kvFib_body` (private) | def | CarrierKv.lean:526 |
| 2 | `bracketEndCharKvFib` | def | CarrierKv.lean:603 |
| 3 | `igAllSubs` | def | InteriorGateGeneralK.lean:1439 |
| 4 | `igFoldBitFib` | def | InteriorGateGeneralK.lean:1451 |
| 5 | `igEpLFib` | def | InteriorGateGeneralK.lean:1459 |
| 6 | `igEpRFib` | def | InteriorGateGeneralK.lean:1469 |
| 7 | `igSegLFib` | def | InteriorGateGeneralK.lean:1479 |
| 8 | `igSegRFib` | def | InteriorGateGeneralK.lean:1486 |
| 9 | `igPtWFib` | def | InteriorGateGeneralK.lean:1493 |
| 10 | `igGateFib` | def | InteriorGateGeneralK.lean:1501 |
| 11 | `igSLFib` | def | InteriorGateGeneralK.lean:1510 |
| 12 | `igSRFib` | def | InteriorGateGeneralK.lean:1515 |
| 13 | `igCharPFib` | def | InteriorGateGeneralK.lean:1520 |
| 14 | `igMkDisjunctFib` | def | InteriorGateGeneralK.lean:1525 |
| 15 | `igBodyFib` | def | InteriorGateGeneralK.lean:1539 |
| 16 | `igBodyFib_holds_iff` | theorem | InteriorGateGeneralK.lean:1555 |
| 17 | `bracketEndChar_kvFib_succ_eq` | theorem | InteriorGateGeneralK.lean:1588 |
| 18 | `bracketEndChar_kvFib_succ_holds_iff` | theorem | InteriorGateGeneralK.lean:1625 |
| 19 | `bracketEndChar_kvFib_realize_futT` | theorem | InteriorGateGeneralK.lean:1687 **(sink)** |
| 20 | `bracketEndChar_kvFib_realize_pastX` | theorem | InteriorGateGeneralK.lean:1742 **(sink)** |
| 21 | `igk_sorted_realization_fib` | theorem | InteriorGateGeneralK.lean:1819 |
| 22 | `bracketEndChar_kvFib_step_gate` | theorem | InteriorGateGeneralK.lean:1861 |
| 23 | `bracketEndChar_kvFib_step_complete` | theorem | InteriorGateGeneralK.lean:1907 |
| 24 | `bracketEndChar_kvFib_step_sound` | theorem | InteriorGateGeneralK.lean:2293 |
| 25 | `bracketEndChar_kvFib_step_correct` | theorem | InteriorGateGeneralK.lean:2480 **(sink)** |
| 26 | `bracketEndCharKvExtFib` | def | ExteriorGateAssembleK.lean:468 |
| 27 | `bracketEndChar_kvExtFib_holds_iff` | theorem | ExteriorGateAssembleK.lean:483 |
| 28 | `kvExtFib_gate_henv` | theorem | ExteriorGateAssembleK.lean:515 |
| 29 | `bracketEndChar_kvExtFib_correct_prior` | theorem | ExteriorGateAssembleK.lean:582 |
| 30 | `kampPrior_site_rungKFib_gate_match` | theorem | KampPrior.lean:1098 **(sink)** |

Sinks 19 and 20 have no consumer anywhere in the closure; their only historical consumers are in
`Boneyard/InteriorHrealSupplyK.lean` (lines 135, 207) — i.e. the already-retired
`kampPrior_hreal_supply`. Sinks 25 and 30 are terminal certificates that were never wired.

Structural confirmations:

- **No attributes.** No `@[simp]`, `@[instance]`, `attribute`, or `deriving` appears anywhere in
  the four blocks, so nothing can leak into a live `simp` set or instance search.
- **No private-name leakage.** The only `private` member is `kvFib_body`, referenced only by
  `bracketEndCharKvFib` in the same file. No live file `open private`s any island name.
- **`open private` lines stay needed.** `InteriorGateGeneralK.lean:679` and `:1100` open eight
  `k1v_*` privates from `CarrierK1V`. All eight are still used by arity-1 proofs outside the
  island, so both lines must remain after deletion.

### 4. Contiguity: four whole-block deletions, no interleaving

Exact, verified boundaries. Each range starts at a `/-!` section header (or a `set_option ... in`)
and ends at the line before an existing blank/`end`, so no brace, `section`, or `namespace` pairing
is disturbed.

| File | Delete lines | Count | File before / after | First live line kept before | First live line kept after |
|---|---|---|---|---|---|
| `KampPrior.lean` | 1082-1232 | 151 | 1985 / 1834 | 1080 (end of `..._rungK_gate_match`) | 1233 (`/-- **F-i positive exhibit...`) |
| `NfMultiAnchorBridge/ExteriorGateAssembleK.lean` | 447-790 | 344 | 791 / 447 | 445 | 791 (`end FormalSystem...`) |
| `NfMultiAnchorBridge/InteriorGateGeneralK.lean` | 1424-2550 | 1127 | 2553 / 1426 | 1422 (`example ... := bracketEndChar_kv_correct_prior ...`) | 2551 (`end`, closing `noncomputable section` at :197) |
| `NfMultiAnchorBridge/CarrierKv.lean` | 503-616 | 114 | 617 / 503 | 501 | 617 (`end FormalSystem...`) |

Total: **1,736 lines**. In `InteriorGateGeneralK.lean` the deleted range is the file's entire tail
below the arity-1 Phase 8 consumability `example`; the `end` at 2551 closes the `noncomputable
section` opened at 197 and must be retained.

### 5. Family (b) — LIVE fiber machinery, explicitly excluded

The task warned that `*Fib` is ambiguous. Confirmed, with one correction and one addition.

**Correction — `igOffFiber` is LIVE, not dead.** The task description lists `igOffFiber` under
family (a). It is at `InteriorGateGeneralK.lean:329`, well above the island, and is consumed by
three **arity-1** theorems: `bracketEndChar_kv_succ_eq` (:372), `bracketEndChar_kv_succ_holds_iff`
(:439), `bracketEndChar_kv_step_gate` (:555). Deleting it breaks the build. It is outside all four
deletion ranges, so a whole-block deletion is safe; a name-driven sweep would not be.

**Addition — `igAllSubs` is DEAD and must be included.** Not named in the task description (it has
no `Fib` suffix), but it is defined at the head of the M2 block (:1439) and every one of its
consumers is an island member. It falls inside the block range, so a block deletion already
catches it.

Confirmed LIVE and untouched (family (b) and the arity-1 siblings):

- `kvEFiber` and the `kvEFiber*` family — consumed across `ExteriorFiberK.lean` (8 sites) and
  `ExteriorPinnedConverseK.lean`.
- `kvEDeepOnFiber` and the `kvE_deepOnFiber_*` family — consumed by `ExteriorFiberDeepAnchorK.lean`,
  `ExteriorBracketAssembleK.lean` (7 sites), `EndIntervalConsumerK.lean`, and both arity-1 and
  (currently) the arity-4 site certificates in `KampPrior.lean`.
- `igFoldBit` (:346), `igOffFiber` (:329), `bracketEndCharKvExt`, `bracketEndChar_kvExt_correct_prior`,
  `kampPrior_site_rungK_gate_match`, `bracketEndChar_kv_step_correct`, `bracketEndChar_kv_correct_prior`,
  `InteriorGateAllK`, `kvEAmbientGuardForm`, `kvE_ambientGuardForm_truth`, `kvExt_gate_henv`.

Note for the planner: `kampPrior_site_rungK_gate_match` (the LIVE arity-1 sibling) also has zero
consumers in the closure. **Zero-consumer status is therefore not the deletion criterion in this
tree** — several site certificates are deliberately consumer-free records. The authority for
removing the island is the 377 adjudication plus the fact that its competing route landed, not
consumer count alone.

### 6. Preservation obligations — two prose records document LIVE code

Both sit inside the deletion ranges and would be silently lost.

- **`InteriorGateGeneralK.lean:1646-1670`** (inside range 1424-2550). The "Phase 3 — render-free
  endpoint→arity-4 realizer extraction" header records that the LIVE frozen bridge
  `igFoldBit_realize_iff` (`:611`, outside the range) requires the deep render
  `NfEvalNf M (k+1) 3 [w,x,t] qnf` as an explicit hypothesis, which makes the firing route for the
  already-retired `kampPrior_hreal_supply` **machine-confirmed circular**. This is the comment the
  task description points at as `:1653`. The task said "leave or update"; because it is inside the
  block, the implementer must consciously **relocate** it — a condensed 3-5 line note attached to
  `igFoldBit_realize_iff` at `:611`, cross-referencing `Boneyard/InteriorHrealSupplyK.lean`.
- **`CarrierKv.lean:503-516`** (inside range 503-616). Records that the LIVE frozen
  `bracketEndCharKv` folds each marked arity-4 fiber down to `(nf0ZoneSpec (atomAssgn sub),
  nfkProjFresh sub)` — the F1 information loss that constitutes the M1 refutation record. The
  refutation is about live code and should survive as a condensed note near `bracketEndCharKv`
  (`:248`); only the "the M2 fix is the sibling carrier below" sentence goes with the archive.

No other prose obligation exists: an explicit scan for all 22 island identifiers plus the strings
`de-folded`, `De-folded`, `M2 (Option B)`, and `hcharFib` across every non-Boneyard `.lean` and
`.md` under `FormalSystem/` found **zero occurrences outside the four deletion ranges**. The many
`arity-4` prose hits elsewhere in the tree refer to the general arity-4 *concept* (Rabinovich Def
3.1 environments), not to this stack, and must be left alone.

### 7. Boneyard versus raw excise

The Boneyard README's archival criterion is met exactly: "A file belongs here when it is unreachable
from every Lake target root and is not intended to become reachable." The stack is adjudicated dead,
not merely-not-yet-wired, so `scripts/module-invariants-manifest.txt` (the alternative home, which
compile-checks its entries) is the wrong destination.

Boneyarding is preferable to raw deletion for one concrete reason: three already-archived members of
this same stack still name eight island symbols, and would otherwise dangle into deleted history —

| Archived file | Lines | Island symbols it names |
|---|---|---|
| `Boneyard/InteriorHrealSupplyK.lean` (`kampPrior_hreal_supply`) | 212 | `igAllSubs`, `igFoldBitFib`, `igEpLFib`, `igEpRFib`, `igPtWFib`, `bracketEndChar_kvFib_realize_futT`, `bracketEndChar_kvFib_realize_pastX`, `charFib` |
| `Boneyard/ZoneSeamCrossContextProbe.lean` | 293 | `igFoldBitFib`, `igEpLFib`, `igEpRFib`, `igPtWFib`, `charFib` |
| `Boneyard/SeamPairRefutationProbe.lean` | 177 | `charFib` |

The Boneyard README asks that "import lines inside archived files are... kept coherent with file
locations where cheap". Landing the definitions beside their existing archived consumers is exactly
that.

### 8. Verification gates — measured baselines the implementer must preserve

Measured live (Appendix A), not assumed:

| Gate | Current value |
|---|---|
| `#print axioms FormalSystem.Metalogic.BXCanonical.completeness_discrete` | `[propext, Classical.choice, Quot.sound]` |
| `#print axioms FormalSystem.Metalogic.WeakCanonical.Kamp.kampPriorExpressiveCompleteness` | `[propext, Classical.choice, Quot.sound]` |
| Live sorry terms (non-Boneyard, comment-stripped) | **5** — `Soundness.lean:1461,1472,1486,1509`; `Transfer.lean:1242` |
| `scripts/check-module-invariants.sh` C3 pattern hit count | 3 (its narrower regex matches only 2 of the 4 Soundness sorries) |

Two notes on the task's DONE-WHEN wording:

- The DONE-WHEN cites `WeakCanonical/Transfer.lean:1225`. That line is the `theorem
  countermodel_discrete` **header**; the `sorry` term itself is at `:1242`. Same sorry, different
  anchor — no discrepancy.
- `scripts/check-module-invariants.sh` C3 asserts **exactly one** structural sorry and will
  currently report 3, i.e. C3 is already red before this task touches anything. This is a
  pre-existing condition owned by the concurrent `Soundness.lean` work, **not** a regression this
  task may introduce. The implementer should record C3's pre-state before starting and compare
  after, rather than treating a red C3 as its own failure.

Other invariant checks and their exposure to this change:

- **C1 (`lake build`)**, **C2 (four flagship axiom sets)** — must stay green; the deletion should
  not touch them, and that is the primary post-condition.
- **C4 (dangling imports)**, **C6 (unreachable-module manifest)**, **C7 (live inventory)**,
  **C8 (aggregator convention)** — all three walk `FormalSystem/` and `Tests/` with `Boneyard`
  pruned, so a new file under `Kamp/Boneyard/` is invisible to them. C7 is informational and its
  live line count will drop by ~1,736.
- **`scripts/readme-lint.sh`** — checks 1 and 2 both `continue` on any path containing `Boneyard`,
  so a new archive file needs no README inventory row. The Kamp Boneyard README's own summary table
  ("62 files, 27,394 lines") becomes stale by one file; updating it is courtesy, not enforcement.

## Decisions

- **D1.** The excision set is the 30 declarations in finding 3, delivered as four whole-block
  deletions at the exact ranges in finding 4. No name-pattern sweep.
- **D2.** `igOffFiber` is reclassified from the task description's family (a) to family (b) — LIVE,
  do not touch. `igAllSubs` is added to the excision set.
- **D3.** Boneyard rather than raw excise, per finding 7.
- **D4.** The two prose records in finding 6 are relocation obligations, not deletions.
- **D5.** No mathematics is proposed. No wiring, no arity-4 realization engine, no
  Feferman-Vaught — the task's three non-goals are respected and nothing in this report requires
  revisiting them.

## Recommendations

Prioritized, sized for one agent run per phase.

1. **Phase 1 — land the archive file.** Create
   `FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/Arity4CharStackK.lean` containing all 30
   declarations in dependency order (`kvFib_body` → `bracketEndCharKvFib` → `igAllSubs` → the
   `ig*Fib` defs → the `bracketEndChar_kvFib_*` theorems → the `*ExtFib` block →
   `kampPrior_site_rungKFib_gate_match`), carrying their docstrings and the two `set_option
   maxHeartbeats 1600000 in` lines verbatim. Reproduce the `open private k1v_*` lines the moved
   proofs need. Header must record: provenance (which file/lines each block came from), the 377
   adjudication verdict, and the "landed, unwired, circular, fiber-refuted" status. Boneyard code is
   never compiled, so a single file is acceptable and lower-risk than three; splitting per origin is
   a defensible alternative if the planner prefers 1:1 traceability.
2. **Phase 2 — relocate the two prose records** (finding 6) into the live files, *before* deleting
   the blocks, so the records are never absent from the tree in any intermediate commit.
3. **Phase 3 — delete the four blocks** at the exact ranges in finding 4, one file per edit.
   Verify `end` pairing in `InteriorGateGeneralK.lean` (the `end` at old-2551 closes the
   `noncomputable section` at `:197`).
4. **Phase 4 — verify.** `lake build` and `lake build BimodalTest` exit 0; re-run the Appendix A
   probe (keeping the bogus-identifier control) and confirm both axiom sets are unchanged; re-run
   the sorry census and confirm it is still 5; re-run `scripts/check-module-invariants.sh` and
   confirm no check moved from green to red relative to the pre-state recorded in Phase 0.
5. **Phase 5 — housekeeping (optional).** Update the Kamp Boneyard README's file/line table and add
   `Arity4CharStackK.lean` to its retirement narrative alongside the three existing members.

## Risks & Mitigations

| Risk | Likelihood | Mitigation |
|---|---|---|
| A name-driven sweep deletes `igOffFiber` or a `kvEFiber*`/`kvE_deepOnFiber_*` member | Medium — the trap is real and the task description itself mis-files `igOffFiber` | Use the four line ranges in finding 4 verbatim; never grep for `*Fib` |
| The circularity record at `:1653` is lost | High if the block is deleted naively — the task text ("leave the comment") implies it is outside the block, but it is inside | Phase 2 relocates it before Phase 3 deletes |
| Red C3 after the change is misread as a regression | Medium | C3 is already red (3 hits vs 1 expected) from concurrent `Soundness.lean` work; record the pre-state in Phase 0 |
| Line numbers drift because a concurrent task edits one of the four files | Low — `KampPrior.lean` and the three bridge files are owned by this task; `Soundness.lean` is not in scope | Re-confirm each block's first and last line by content (not number) immediately before deleting |
| Moved Boneyard code silently rots | Certain, and accepted | The Boneyard README states this explicitly; the stack is adjudicated dead, so rot is the intended outcome |

## Appendix

### A. Verification probe and its control

Per the task's verification note, `lean_run_code` was not used. The probe was run with
`lake env lean` against the built library:

```
import FormalSystem
#print axioms FormalSystem.Metalogic.BXCanonical.completeness_discrete
#print axioms FormalSystem.Metalogic.WeakCanonical.Kamp.kampPriorExpressiveCompleteness
#check @FormalSystem.Metalogic.WeakCanonical.Kamp.kampPrior_site_rungKFib_gate_match
#check @FormalSystem.Metalogic.WeakCanonical.Kamp.bracketEndChar_kvFib_step_correct
#check @FormalSystem.Metalogic.WeakCanonical.Kamp.bracketEndCharKvFib
#check @FormalSystem.Metalogic.WeakCanonical.Kamp.kvEFiber
#check @FormalSystem.Metalogic.WeakCanonical.Kamp.THIS_IDENTIFIER_IS_DELIBERATELY_BOGUS_407
```

All five real identifiers resolved with full signatures. The control failed as required:
`error(lean.unknownIdentifier): Unknown identifier
'FormalSystem.Metalogic.WeakCanonical.Kamp.THIS_IDENTIFIER_IS_DELIBERATELY_BOGUS_407'`. Both axiom
lines printed `[propext, Classical.choice, Quot.sound]` with no `sorryAx`.

### B. References

- `specs/377_transcribe_rabinovich_faithful_nf_encoding/reports/06_kampprior-520-adjudication.md`,
  section 6 item 3 — "a retirement/quarantine ledger for the arity-4 Fib stack... landed, unwired,
  circular, fiber-refuted. It should be excised or Boneyarded, not consumed."
- `FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard/README.md` — archival criterion, never-compiled
  build policy, and the two-Boneyard warning.
- `scripts/check-module-invariants.sh` — B0/C1-C10 invariant definitions; `scripts/readme-lint.sh`
  checks 1-4.
- Commits `9b3bfa100`, `10fe1d939` — the zeta wire that won the routing question.

### C. Tactic survey

Not applicable. This task closes no proof goals; it removes declarations. No tactic was tried and
none is needed. The single Lean-tool operation performed was the read-only `lake env lean` probe in
Appendix A.
