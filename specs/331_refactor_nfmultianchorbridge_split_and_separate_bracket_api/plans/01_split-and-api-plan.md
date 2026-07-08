# Implementation Plan: Split NfMultiAnchorBridge.lean and Surface the Separate-Bracket API

- **Task**: 331 - refactor_nfmultianchorbridge_split_and_separate_bracket_api
- **Status**: [IMPLEMENTING]
- **Effort**: 8 hours (8 phases, one agent dispatch each)
- **Dependencies**: None (task 321 depends on THIS task)
- **Research Inputs**: specs/331_refactor_nfmultianchorbridge_split_and_separate_bracket_api/reports/01_split-structure-research.md
- **Artifacts**: plans/01_split-and-api-plan.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-formats.md; git-workflow.md; lean4 reference-grounding.md (H3 Tier 1)
- **Type**: lean4

## Overview

`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` (9,249 lines, verified)
is split into **10 content modules + 1 umbrella file** along the exact line ranges verified in the
research report (all seven task-cited anchors exact, zero drift). The old path becomes an
import-only umbrella, so the single real consumer (`KampPrior.lean:4`, which uses zero bridge
symbols) needs **zero changes**. This is a SEMANTICS-PRESERVING relocation: the only sanctioned
token edits anywhere are (a) removing `private ` from the 11 inventoried helpers and (b) one
token-identical relocation of `nf_eval_depth1_fold_iff` (orig. :5344) into `CarrierKv.lean`.
New text is additive only: per-file provenance headers, `import` lines, namespace/`open`
scaffold, and API/QUARANTINE doc banners. Done = same theorems, same axiom profile
`[propext, Classical.choice, Quot.sound]`, `lake build` exit 0 after every phase commit, no
`sorry` introduced, faithful separate-bracket API documented in `SubBracket2V.lean` /
`NavigatedSpine.lean`, merged-route machinery quarantined in `MergedQuarantine.lean`.

**Line-coordinate convention**: All line numbers `:N` in this plan refer to the PRE-TASK file.
Phase 1 records the pre-task commit as `ORIG_SHA`; every slab extraction and byte-identity check
runs against `git show $ORIG_SHA:Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean`,
so coordinates never drift as the monolith shrinks.

### Research Integration

- `reports/01_split-structure-research.md` (v1, integrated 2026-07-07): section map (Finding 2),
  import DAG (Finding 3), de-privatization inventory (Finding 4), consumer inventory (Finding 5),
  scoping audit (Finding 6), 11-step extraction order (Finding 7), API surface (Finding 8).
  Adopted verbatim; the 11 steps group into Phases 1-7 below (max 2 modules / ~2,500 relocated
  lines per phase).

### Source-to-Implementation Mapping (H3 Tier 1)

Reproduced from the research report (Rabinovich 2014, Literature chunk
`/home/benjamin/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.md`).
This table is the content basis for the API doc banners written in Phases 4, 6, and 7 — the
implementer copies from here, and does NOT re-derive from the paper. All items are already
`transcribed` (landed, sorry-free); this task only relocates them.

| Source (Rabinovich 2014) | Prop/Location | Lean Identifier | Type Signature (abbrev.) | Status |
|---|---|---|---|---|
| Def 3.1 exists-forall bracket (md:61-74) | interval decomposition | `bracketFromLists` :1896 (shared plumbing, de-privatized); `bracketFromLists3` :6766 (stays private in SubBracket2V); `kvE_subBracket2V` :6833 | `bracketFromLists : List TemporalPred → ... → BracketFormula _` | transcribed |
| Lemma 3.2(2) 2-var reduction (md:78) | closure: <=2 free vars | `neg_2var_vec_ea` (external, `EANegationClosure.lean:722`) | negation of 2-var exists-forall is V-exists-forall | transcribed (external; cross-reference only) |
| Lemma 3.4 V-exists-forall closure (md:84-85) | disj/conj/exists closure | `VVecEA2.disjList` :8938, `VVecEA2.disjList_holds` :8947; `VVecEA2.conj_struct` (external, `VecEAClosure.lean:195`) | `disjList_holds : (disjList vs).holds ... ↔ ∃ v ∈ vs, v.holds ...` | transcribed |
| Prop 3.5 folding / F_i chain (md:87-94) | exists-forall → nested Until/Since | `kvE_fold_navigated` :8881; `kvE_nonInterior_z{PastX,FutT,AtX,AtT,AtW}_{sound,complete}` :9055-:9176 | fold via `kvE_subBracket2V_correctness_pair` | transcribed |
| Prop 4.2 negation closure (md:100-101) | hard case of induction | `reflatten_neg_step` :8976 | negation step | transcribed |
| Prop 4.3 structural induction (md:103-110) | FO → V-exists-forall | `reflatten_prop43` :8991 | induction over formula structure | transcribed |
| Lemma 5.1 point insertion (md:134-135, 159-173) | quantifier-free point types | `kvE_subBracket2V_correctness_pair` :8549 (per-σ); no-nesting audit rule :8841-8846 | `... ↔ ∃ x1, nf_eval_nf M 1 4 ... σ` | transcribed (per-σ half; shared-w conjunction is TASK 321, not built here) |
| Cor 5.4 F_i-chain reduction (md:154-157) | chain predicate over bracket | `kvE_subChain2V` :6955 (protected); `kvE_subChain` :5964; `kvE_subChain2` :6179 | per-arrangement chain as single `TemporalPred` | transcribed |
| (merged route — VIOLATES Lemma 5.1 point-type rule) | bracket-whose-points-are-brackets | `kvE2_body` :8608, `bracketEndChar_kvE2` :8712, `kvE'_body` :5562, `kvE_gate` :5172, pin/excl channels :5507-:5560 | two-level carrier | transcribed; QUARANTINED, byte-identical, do not delete |

### Preserved Assets

The following work is complete and must not regress (byte-identical relocation only):

| Component | Location (pre-task) | Status | Protection |
|-----------|--------------------|--------|------------|
| Task 325/326 landed block (kvE_subBracket2V kit incl. `_sound_of_outer` :7910, `_complete` :8159, `_correctness_pair` :8549) | :6734-:8607 | [COMPLETED] | byte-identical, do-not-edit |
| kvE2 splice (`kvE2_body` :8608, `bracketEndChar_kvE2` :8712) + task-327 gate record | :8608-:8826 | [COMPLETED] | byte-identical, do-not-edit |
| `kvE_subChain2V` :6955 | :6955 | [COMPLETED] | byte-identical, do-not-edit |
| `BracketCarrierCorrectVPrior` / prior interface | :4988-:5076 | [COMPLETED] | byte-identical, do-not-edit |
| F1-F4 negative-result records (incl. `f2_relativized_refutation` :4884, verdict record :6038-:6106) | :4041-:4987, :6038-:6106 | [COMPLETED] | byte-identical, do-not-edit |
| Task 321 v6 spine (`kvE_fold_navigated`, `reflatten_prop43`, dischargers, Phase-7 rescope record) | :8827-:9249 | [COMPLETED] | byte-identical, do-not-edit |
| In-file do-not-edit records | :5866, :6098 | [COMPLETED] | byte-identical |
| `KampPrior.lean` (incl. :351-353 strategic-sorry hook) | separate file | [COMPLETED] | do not touch at all |

## Postmortem Constraints

Binding rules for all implementation dispatches. Derived from the research report's adversarial
verification, its three documented divergences from the task text, and the task's binding
constraints.

**Do NOT**:
- Do NOT edit any landed lemma/def statement, proof term, docstring, or whitespace. The ONLY
  sanctioned token edits in the entire task: removing `private ` from exactly the 11 inventoried
  helpers (table in Phase notes below), and relocating `nf_eval_depth1_fold_iff` (:5344 block)
  token-identically into `CarrierKv.lean`. Everything else moves as byte-copied slabs
  (`sed -n 'A,Bp'` against `$ORIG_SHA`).
- Do NOT fix, update, or "improve" stale `:NNNN` line references inside relocated docstrings or
  comments — cosmetic edits inside protected slabs violate byte-identity (research Risk 3).
- Do NOT split `MergedQuarantine.lean`'s two parts (:5077-:5856 and :8608-:8826) into separate
  files. They must share one file: splitting would force de-privatizing `kvE_pinDisjunct` /
  `kvE_exclConj`, which ARE on the in-file do-not-edit records (:5866, :6098). (Research
  Finding 4, closing paragraph.)
- Do NOT close the Phase-7 gate, build the shared-interior-witness conjunction (`∃ w, ⋀_σ ...`),
  or run Phase-8. Those are task 321. This task adds ZERO new mathematical content.
- Do NOT modify `KampPrior.lean`, `lakefile.lean`, or anything under `Kamp/Boneyard/`
  (separate lake target, research Risk 6). No lakefile change is needed — `roots := #[`Bimodal]`
  builds new files exactly when reachable via the umbrella's imports.
- Do NOT de-privatize anything beyond the 11 inventoried helpers. In particular
  `bracketFromLists3`, `k1v_sorted_realization3`, `k1v_bracket_construct3`,
  `bracketFromLists_flatMap_subchain_below_pin`, all `f2*`, `kv_body`, and the `kvE_*`
  gate/pin/excl family stay `private` (all their apparent crossings are comments — research
  Finding 4).
- Do NOT use `git add -A` / `git commit -am`; stage only the two files touched per extraction
  step plus state/plan files. Do NOT run destructive git on a dirty tree without
  `bash .claude/scripts/git-snapshot.sh` first.
- Do NOT keep a phase open to polish: when `lake build` is green and byte-identity checks pass,
  commit and end the dispatch.

**MUST preserve**:
- Every landed theorem with identical statement and proof term; axiom profile
  `[propext, Classical.choice, Quot.sound]` on the flagship theorems.
- `lake build` exit 0 after EACH phase (incremental discipline — never batch two phases into one
  commit).
- The `NfMultiAnchorBridge.lean` import path (umbrella file) so `KampPrior.lean:4` never changes.
- Zero `sorry` introduced anywhere (byte-copy guarantees this; final phase re-verifies).

**Design decisions are SETTLED** (do not re-open without a concrete `lake build` counterexample):
1. **`bracketFromLists_flatMap_subchain_below_pin` (:7793) lives in `SubBracket2V.lean`** (the
   FAITHFUL module), NOT the quarantine — despite the task text's item 1(f). Its only code
   consumers are the task-326 `_of_outer` closers (:7876, :7910) in the same module, and it is
   `private`; moving it to quarantine would force de-privatization AND a faithful→quarantine
   import. (Research divergence 1.)
2. **"Quarantining `slotsFor`" means quarantining `kvE'_body` (:5562) and `kvE2_body` (:8608)**
   — `slotsFor` is a local `let` inside those two bodies (:5632, :8677), not a top-level def.
   (Research divergence 2.)
3. **The task's "VVecEA2.conj" is `VVecEA2.conj_struct`** (`VecEAClosure.lean:195`, external to
   the monolith). It is cross-referenced in the API banner, not relocated. (Research
   divergence 3.)
4. **Umbrella strategy over consumer rewrites**: `NfMultiAnchorBridge.lean` stays at its path as
   header docstring (:30-:79 retained) + 10 imports. Lean imports are transitive, so KampPrior
   sees every symbol unchanged. No `export`/alias shims anywhere.
5. **`nf_eval_depth1_fold_iff` relocates to `CarrierKv.lean`** so no faithful module ever imports
   the quarantine. Contingency ONLY if an unexpected additional code-crossing from the 5077-5766
   region surfaces at build time: faithful modules import `MergedQuarantine` (ugly but correct) —
   record the deviation in the summary; do not improvise a third option. (Research Risk 2.)
6. **Extraction is top-down** (Base first, spine last) so the shrinking monolith always compiles:
   everything below an extraction point depends only upward. Phase order is NOT reorderable.

## Goals & Non-Goals

- **Goals**:
  - 10 modules under `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/`, each
    ~90-2,100 lines, plus umbrella `NfMultiAnchorBridge.lean` (~90 lines).
  - Faithful separate-bracket API documented with Rabinovich citations in `SubBracket2V.lean`
    and `NavigatedSpine.lean` banners; QUARANTINE banners on `RefutationF2.lean` and
    `MergedQuarantine.lean`.
  - Green `lake build` + one commit per phase; final axiom/sorry/consumer gates pass.
- **Non-Goals**: any new lemma, any proof change, closing the Phase-7 gate, the shared-w
  combinator, Phase-8, deleting merged-route code, renaming symbols, changing namespaces,
  lakefile edits, fixing stale comment line-refs.

## Risks & Mitigations

- **Risk**: a missed code-crossing `private` fails the build mid-phase. **Mitigation**: research
  enumerated all 117 privates; a miss fails loudly at that phase's `lake build` — de-privatize
  the single offender (verify it is not on the do-not-edit records :5866/:6098 first), note it in
  the summary. This is fix-forward, not a plan revision.
- **Risk**: byte-identity accidentally broken during slab surgery. **Mitigation**: mandatory
  per-phase slab diff against `$ORIG_SHA` (procedure in Phase 1); expected diff is empty (or
  exactly the inventoried `private ` removals).
- **Risk**: proof-term drift across files (elaboration context). **Mitigation**: research
  Finding 6 verified no `section`/`variable`/`attribute`/`set_option` exist; `open Classical in`
  travels per-declaration; per-phase `lake build` + final axiom check catch any residual.
- **Risk**: context exhaustion mid-phase. **Mitigation**: phases are sized to one dispatch; if
  interrupted, the last green commit is the resume point — the monolith + extracted modules are
  always consistent at every commit.

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |
| 6 | 6 | 5 |
| 7 | 7 | 6 |
| 8 | 8 | 7 |

Strictly sequential — no parallel opportunities exist. Every phase deletes a slab from the same
shrinking monolith, so H7 territory is trivially exclusive:
`NfMultiAnchorBridge.lean` + the new module file(s) named in the phase.

**Shared per-phase procedure** (referenced as "standard extraction" below; each phase names its
own parameters):

1. Extract slab(s) from the pre-task snapshot:
   `git show $ORIG_SHA:Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean | sed -n 'A,Bp' > <newfile-body>`.
2. Assemble the new module: provenance header comment
   (`/-! Extracted from NfMultiAnchorBridge.lean lines A-B (task 331). <role banner> -/`),
   `import` lines (Base carries the monolith's full original import block :1-:28-ish; every later
   module imports its DAG predecessors per the phase spec — transitivity supplies the rest),
   `namespace Bimodal.Metalogic.WeakCanonical.Kamp`, the three `open`s (copy :82-:84), slab body,
   `end Bimodal.Metalogic.WeakCanonical.Kamp`. Mirror the import-path prefix used by the
   monolith's own existing import lines (lakefile roots-based; do not guess a new convention).
3. Delete the same line range from the working-tree monolith; add
   `import ...NfMultiAnchorBridge.<Module>` to the monolith's import block.
4. Apply the phase's sanctioned token edits ONLY (listed per phase; most phases have none).
5. **Byte-identity check**: diff the slab file from step 1 against the new module's body region
   (skip header/import/namespace/open lines; e.g. `diff <(tail -n +K NewFile.lean | head -n L) slab.txt`
   — implementer picks exact offsets). Expected: empty diff, or exactly the phase's inventoried
   `private ` removals. ANY other hunk = STOP, fix before proceeding.
6. `lake build` — must exit 0 (use `lake build` at repo root; LSP restart via `lean_build` if
   MCP diagnostics are needed).
7. Commit (message per phase below; stage only the monolith, the new module file(s), and this
   plan file's status-marker update). Session ID `sess_1783475175_afdf09` in the body.

**Rollback/contingency (applies to every phase)**: fix-forward first — a broken build after an
extraction is almost always a missed import or a missed de-privatization; fix the new module or
add the inventoried edit. If the phase must be abandoned mid-edit, run
`bash .claude/scripts/git-snapshot.sh` FIRST, then restore to the previous green commit. Never
`git reset --hard` / `git checkout --` on a dirty tree without the snapshot.

### Phase 1: Extract Base.lean (:88-:1522) and record ORIG_SHA [COMPLETED]
- **Goal:** Create module directory + `Base.lean` (~1,435 lines relocated); pin the pre-task
  snapshot all later phases diff against.
- **Tasks:**
  - [x] `git rev-parse HEAD` → write to
        `specs/331_refactor_nfmultianchorbridge_split_and_separate_bracket_api/.orig-sha`
        (verify tree is clean first; if dirty, commit or snapshot before pinning).
        *(deviation: altered — tree had unrelated dirty files (pre-existing README.md edit +
        preflight status files), but the monolith itself was verified byte-identical to HEAD
        (`git diff HEAD -- <monolith>` empty), so ORIG_SHA=2146e9c05 is a valid pin.)*
  - [x] `mkdir -p Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/`.
  - [x] Standard extraction: slab :88-:1522 → `Base.lean`. Imports: copy the monolith's full
        original import block. Contents: phases 1-7 plumbing (`cons_const_apply` :143,
        `nf_char2_*` :213-:544, `nf_zone_flatten_navigable` :712, `A_diag` :786,
        `nf_char3_endpoint_tl` :914, `endChar0` :1040, `seg` :1172, off-diag formulas
        :1252/:1451).
  - [x] Token edits this phase: NONE.
  - [x] Byte-identity check (expected: empty diff — PASSED; full-monolith reconstruction diff
        also empty), `lake build` exit 0 (1710 jobs, "Build completed successfully").
- **Estimated output:** ~1,435 lines relocated; ~15 new scaffold lines. One bounded unit
  (one module file, fixed slab).
- **Done when:** `lake build` exit 0; `Base.lean` slab diff empty; `.orig-sha` written.
- **Commit:** `task 331 phase 1: extract Base module`
- **Timing:** ~45 min
- **Depends on:** none

### Phase 2: Extract CarrierK1V.lean (:1523-:3603) with 6 de-privatizations [COMPLETED]
- **Goal:** Relocate the k=1 V-carrier kit (~2,081 lines), the largest single module.
- **Tasks:**
  - [x] Standard extraction: slab :1523-:3603 → `CarrierK1V.lean`. Imports: `Base`.
        Contents: `bracketEndChar_k0` :1580, `_k1` :1687, `bracketFromLists` :1896,
        `bracketEndChar_k1v` :1940, k1v helper kit :2032-:3135, `_sound` :2495,
        `_complete` :3136, `_correct` :3548.
  - [x] Token edits this phase — remove `private ` from exactly these 6 (research Finding 4):
        `bracketFromLists` :1896, `k1v_bool_eq_false` :2032, `k1v_not_of_iff_false` :2465,
        `k1v_bracket_extract_mono` :2274, `getElem_append3_mid` :2300,
        `k1v_sorted_realization` :2954.
  - [x] Byte-identity check (expected diff: exactly the 6 `private ` removals — PASSED: 6 hunks,
        12 diff lines, all leading-`private ` removals; monolith tail :3604-:9249 byte-identical),
        `lake build` exit 0 (1711 jobs, "Build completed successfully").
  - [x] Optional split at :2836 (research Risk 5) is NOT taken — 2,081 lines is accepted;
        do not re-open.
- **Estimated output:** ~2,081 lines relocated; ~15 scaffold lines; 6 token edits.
- **Done when:** `lake build` exit 0; slab diff shows only the 6 sanctioned edits.
- **Commit:** `task 331 phase 2: extract CarrierK1V module`
- **Timing:** ~60 min
- **Depends on:** 1

### Phase 3: Extract CarrierKv.lean (+ fold_iff relocation) and RefutationF2.lean [COMPLETED]
- **Goal:** Relocate depth-k carrier (~455 lines incl. the one cross-region relocation) and the
  self-contained F2 refutation record (~947 lines).
- **Tasks:**
  - [x] Standard extraction: slab :3604-:4040 → `CarrierKv.lean`. Imports: `CarrierK1V`.
        Contents: `atomKind_castLE` :3640, `nfk_take` :3656, `nfk_projFresh` :3668, `kv_body`
        :3738, `bracketEndChar_kv` :3824, `_correct_zero` :3953, `_correct_one` :3981,
        `_factors` :4008.
  - [x] **Sanctioned relocation**: cut the `nf_eval_depth1_fold_iff` block (docstring + theorem,
        orig. :5344 — determine exact block bounds from `$ORIG_SHA`) out of the monolith and
        append it token-identically to the end of `CarrierKv.lean` (before `end`). Byte-identity
        of the block itself: extract the block's line range from `$ORIG_SHA` and diff.
        *(block bounds determined: orig :5333-:5358 (docstring :5333, theorem :5344-:5358);
        excised from monolith with trailing blank :5359; block diff EMPTY)*
  - [x] Token edit: remove `private ` from `atomKind_castLE` :3640 (used at :4520 in the f2
        block). Total sanctioned edits this phase: 1 de-privatization + 1 relocation.
  - [x] Standard extraction: slab :4041-:4987 → `RefutationF2.lean`. Imports: `CarrierKv`.
        Header banner: `QUARANTINE / NEGATIVE-RESULT RECORD (F1-F4): merged-route refutation
        machinery; retained byte-identical, do not extend`. Contents: F1 finding record :4041,
        `f2*` probe machinery :4117-:4822 (self-contained), `f2_relativized_refutation` :4884.
  - [x] Byte-identity checks for both slabs (CarrierKv slab: exactly the 1 private-removal hunk;
        fold_iff block: empty; RefutationF2 slab: empty; monolith remainder vs orig :4988-:5332
        and :5360-:9249: both empty); `lake build` exit 0 (1713 jobs).
- **Estimated output:** ~1,410 lines relocated; ~35 scaffold/banner lines; 2 sanctioned edits.
  Two bounded units, each a fixed slab.
- **Done when:** `lake build` exit 0; both slab diffs show only sanctioned edits; monolith no
  longer contains `nf_eval_depth1_fold_iff`.
- **Commit:** `task 331 phase 3: extract CarrierKv and RefutationF2 modules`
- **Timing:** ~60 min
- **Depends on:** 2

### Phase 4: Extract PriorInterface.lean [COMPLETED]

**Amendment (2026-07-07, orchestrator-accepted resolution option i)**: this phase originally
also covered MergedQuarantine part 1 (:5077-:5856 minus fold_iff). That extraction is
structurally impossible before Phase 7: Lean `private` is file-scoped, and part 2
(:8608-:8826, in the monolith until Phase 7) consumes part 1's private helpers (`kvE_gate`
:5172, `kvE_body` :5193, `kvE_pinArrangements` :5521, `kvE_pinDisjunct` :5531, `kvE_exclConj`
:5544, `kvE'_body` :5562 — same-module reuse assumption documented at orig :8588-:8589).
Pulling part 2 forward was rejected (import cycle: `kvE2_body` :8608 uses `kvE_subChain2V`
:6955, which is SubBracket2V territory extracted only in Phase 6, so MergedQuarantine would
import the monolith while the monolith imports MergedQuarantine); de-privatizing the helpers
was rejected (binding do-not-edit/private constraint). The attempted extraction was executed
byte-identically, went RED on the four part-2 references (orig :8653/:8676/:8687/:8700), and
was fixed forward to green: part-1 slab restored byte-identically to the monolith,
`MergedQuarantine.lean` removed. Resolution: the ENTIRE MergedQuarantine extraction (parts
1+2 together) moves to Phase 7, where SubBracket2V exists — zero token edits ever, one-file
settled decision preserved. This phase is therefore PriorInterface only, which landed GREEN
(commit f1cae4b57; fix-forward monolith restore committed green at d21d6f0dc).

- **Goal:** Relocate the protected prior interface (~89 lines).
- **Tasks:**
  - [x] Standard extraction: slab :4988-:5076 → `PriorInterface.lean`. Imports: `CarrierKv`.
        Contents: `ExistProviders` :5010, `BracketCarrierCorrectVPrior` :5032,
        `bracketEndChar_kv_correct_{zero,one}_prior` :5052/:5067. Protected byte-identical —
        token edits: NONE.
  - [x] Byte-identity checks (PriorInterface slab diff vs ORIG_SHA EMPTY; monolith remainder
        vs orig :1-:28, :29-:87, :5077-:5332, :5360-:9249 all EMPTY); `lake build` exit 0
        (1714 jobs).
  - [x] ~~MergedQuarantine part 1 extraction~~ *(deviation: deferred to Phase 7 per accepted
        amendment above — full quarantine file extracted there as parts 1+2 together)*
- **Estimated output:** ~89 lines relocated; ~16 scaffold lines; 0 token edits.
- **Done when:** `lake build` exit 0; PriorInterface slab diff empty.
- **Commit:** `task 331 phase 4: extract PriorInterface` (landed as f1cae4b57 + d21d6f0dc)
- **Timing:** ~60 min
- **Depends on:** 3

### Phase 5: Extract SubBracket.lean and SubBracket2.lean with 4 de-privatizations [COMPLETED]
- **Goal:** Relocate the faithful foundation modules (~250 + ~627 lines).
- **Tasks:**
  - [x] Standard extraction: slab :5857-:6106 → `SubBracket.lean`. Imports: `PriorInterface`
        (NOT MergedQuarantine — faithful modules never import the quarantine). Contents: task-321
        F4 resolution: `kvE_subFoldBits` :5885, `kvE_subInteriorZones` :5908, `kvE_subBracket`
        :5936, `kvE_subChain` :5964, discrimination :6012-:6037, verdict record :6038-:6106.
        Includes do-not-edit record :5866 and :6098 — byte-identical.
  - [x] Standard extraction: slab :6107-:6733 → `SubBracket2.lean`. Imports: `SubBracket`.
        Contents: task 324: `kvE_subBracket2` :6133, `kvE_subChain2` :6179, zone specs
        `kvE_sub2_z{XU,UW,WT}` :6213-:6221, kill-switch/soundness/completeness kit :6246-:6733.
  - [x] Token edits — remove `private ` from exactly these 4 (research Finding 4):
        `kvE_sub2_zXU` :6213, `kvE_sub2_zUW` :6217, `kvE_sub2_zWT` :6221,
        `kvE_sub2_zoneHolds_cons_iff` :6628.
  - [x] Byte-identity checks (SubBracket: empty diff — PASSED; SubBracket2: exactly the 4
        `private ` removals — PASSED, 4 hunks/16 diff lines; monolith git diff = +2 import
        lines, -877 slab lines, nothing else; sorry-mention parity exact, prose-only);
        `lake build` exit 0 (1716 jobs, "Build completed successfully").
- **Estimated output:** ~880 lines relocated; ~30 scaffold lines; 4 token edits.
- **Done when:** `lake build` exit 0; slab diffs show only sanctioned edits; neither file
  imports `MergedQuarantine`.
- **Commit:** `task 331 phase 5: extract SubBracket and SubBracket2 modules`
- **Timing:** ~60 min
- **Depends on:** 4

### Phase 6: Extract SubBracket2V.lean (protected faithful-API slab) [COMPLETED]
- **Goal:** Relocate the task-325/326 protected block (~1,874 lines) as one byte-identical slab
  and write the faithful separate-bracket API banner.
- **Tasks:**
  - [x] Standard extraction: slab :6734-:8607 → `SubBracket2V.lean`. Imports: `SubBracket2`.
        *(deviation: altered — cut shifted to :6734-:8585; orig :8586-:8607 is `open Classical
        in` + the `/-- ... -/` doc comment of `kvE2_body` :8608, which cannot dangle at module
        end, so those 22 lines stay with their declaration in the monolith and move with
        quarantine part 2 in Phase 7 (part 2 becomes :8586-:8826). Partition change only;
        every line byte-identical.)*
        Contents (all protected byte-identical): `bracketFromLists3` :6766 (stays private),
        `kvE_subBracket2V` :6833, `kvE_subChain2V` :6955, `k1v_sorted_realization3` :7073,
        `k1v_bracket_construct3` :7149, `_sound` :7640, `_sound_of_parts` :7719,
        `bracketFromLists_flatMap_subchain_below_pin` :7793 (SETTLED decision 1: stays here,
        stays private), `_bounded_anchor_of_outer` :7876, `_sound_of_outer` :7910,
        `_gate_holds_of_honest` :8086, `_nonvacuous` :8119, `_complete` :8159,
        `_correctness_pair` :8549.
  - [x] Header banner (new additive text, from the H3 mapping table above): `FAITHFUL
        SEPARATE-BRACKET API (Rabinovich 2014)` naming: Def 3.1 (md:61-74) → `kvE_subBracket2V`;
        Cor 5.4 (md:154-157) → `kvE_subChain2V`; Lemma 5.1 per-σ half (md:134-135) →
        `kvE_subBracket2V_correctness_pair`; correctness kit `_sound`/`_sound_of_parts`/
        `_sound_of_outer`/`_gate_holds_of_honest`/`_nonvacuous`/`_complete`; cross-references
        to external combinators `neg_2var_vec_ea` (`EANegationClosure.lean:722`, Lemma 3.2(2),
        md:78) and `VVecEA2.conj_struct` (`VecEAClosure.lean:195`, Lemma 3.4, md:84-85); and an
        explicit note that the shared-interior-witness conjunction (`∃ w, ⋀_σ ...`) is the one
        unbuilt object, owned by task 321.
  - [x] Token edits inside the slab: NONE. (All 6 module-2 privates it consumes were already
        de-privatized in Phase 2; the 4 module-7 privates in Phase 5.)
  - [x] Byte-identity check (expected: EMPTY diff — this is the highest-value protected slab);
        `lake build` exit 0. *(verified: slab :6734-:8585 EMPTY vs ORIG_SHA; monolith remainder
        EMPTY in five segments; lake build exit 0, 1717 jobs)*
- **Estimated output:** ~1,874 lines relocated; ~45 banner/scaffold lines; 0 token edits. One
  bounded unit.
- **Done when:** `lake build` exit 0; slab diff EMPTY; banner cites Rabinovich items with md
  line refs.
- **Commit:** `task 331 phase 6: extract SubBracket2V faithful API module`
- **Timing:** ~60 min
- **Depends on:** 5

### Phase 7: Extract MergedQuarantine.lean (parts 1+2), NavigatedSpine.lean, umbrella reduction [COMPLETED]
- **Goal:** Extract the ENTIRE quarantine file in one step (parts 1+2 together, per the
  Phase-4 amendment), relocate the spine (~423 lines), and reduce the monolith to the
  umbrella file.
- **Tasks:**
  - [x] Standard extraction: `MergedQuarantine.lean` = slab :5077-:5856 **minus the
        already-relocated `nf_eval_depth1_fold_iff` block (:5333-:5359, excised in Phase 3 —
        extract as two sub-slabs :5077-:5332 and :5360-:5856)** followed by slab :8608-:8826,
        all byte-identical. Imports: `PriorInterface` + `SubBracket2V` (verified acyclic:
        SubBracket2V does not import MergedQuarantine; `kvE2_body` :8677 uses `kvE_subChain2V`
        :6955 and `kvE2_joint_nonvacuous_at_honest` :8757 uses `_nonvacuous` :8119). Header
        banner: `QUARANTINE / DEAD-CODE: merged-bracket route
        (bracket-whose-points-are-brackets) — violates the no-nesting audit rule and Rabinovich
        2014 Lemma 5.1 quantifier-free point-type requirement (md:134-135). Retained
        byte-identical for the record; task 321 retires it once the faithful route lands. Do
        not import from faithful modules.` Contents part 1: `kvE_gate` :5172, `kvE_body`
        :5193, `bracketEndChar_kvE` :5307, pin/excl channels :5507-:5560, `kvE'_body` :5562
        (with `slotsFor` local let :5632), `bracketEndChar_kvE'` :5667, task-320 probes
        :5767-:5856. Contents part 2: `kvE2_body` :8608, `bracketEndChar_kvE2` :8712,
        `kvE2_joint_nonvacuous_at_honest` :8748, task-327 gate record :8760-:8826. Token
        edits: NONE — extracting both parts together restores same-module `private` reuse
        (`kvE_gate`/`kvE_pinArrangements`/`kvE_pinDisjunct`/`kvE_exclConj` stay private).
        *(deviation: altered — part 2 slab is :8586-:8826, not :8608-:8826, per the binding
        Phase-6 boundary amendment: :8586-:8607 is `open Classical in` + the `kvE2_body` doc
        comment, which moves with its declaration; byte-identity unchanged)*
  - [x] Standard extraction: slab :8827-:9249 → `NavigatedSpine.lean`. Imports: `SubBracket2V`
        (NOT MergedQuarantine — all kvE2 mentions in this range are comments, verified :9006,
        :9015, :9187-:9243). Contents: audit record :8827-:8858 (incl. no-nesting rule
        :8841-:8846), `kvE_fold_navigated` :8881, `VVecEA2.disjList`/`disjList_holds`
        :8938/:8947, `reflatten_neg_step` :8976, `reflatten_prop43` :8991,
        `VVecEA2.holds_flatMap_map` :9018, 5+5 dischargers :9055-:9176, Phase-7 rescope record
        :9183-:9249.
  - [x] `NavigatedSpine.lean` header banner (additive, from the H3 table): `FAITHFUL API —
        SPINE + PROP 4.3 ENGINE (Rabinovich 2014)`: Prop 3.5 fold (md:87-94) →
        `kvE_fold_navigated` + dischargers; Lemma 3.4 (md:84-85) → `VVecEA2.disjList_holds`;
        Prop 4.2 (md:100-101) → `reflatten_neg_step`; Prop 4.3 (md:103-110) →
        `reflatten_prop43`.
  - [x] Reduce `NfMultiAnchorBridge.lean` to the umbrella: retain header module docstring
        :30-:79, replace all remaining content with the 10 `import` lines (Base, CarrierK1V,
        CarrierKv, RefutationF2, PriorInterface, MergedQuarantine, SubBracket, SubBracket2,
        SubBracket2V, NavigatedSpine). Target ~90 lines. Namespace block no longer needed in the
        umbrella (imports only).
  - [x] Token edits: NONE. Byte-identity checks on all slabs (quarantine sub-slabs
        :5077-:5332, :5360-:5856, :8608-:8826; spine :8827-:9249 — expected: empty diffs);
        `lake build` exit 0 (this also proves `KampPrior.lean` still compiles unchanged).
        *(verified: all four slab diffs vs ORIG_SHA EMPTY (part 2 checked as :8586-:8826);
        umbrella docstring orig :29-:78 EMPTY diff; `lake build` exit 0, 1719 jobs)*
- **Estimated output:** ~1,395 lines relocated; ~55 banner/umbrella lines. Two module files +
  one mechanical umbrella rewrite, all fixed-scope.
- **Done when:** `lake build` exit 0; monolith is imports+docstring only (~90 lines); all slab
  diffs empty; `git diff $ORIG_SHA -- .../KampPrior.lean` is empty.
- **Commit:** `task 331 phase 7: extract MergedQuarantine, NavigatedSpine, umbrella file`
- **Timing:** ~90 min
- **Depends on:** 6

### Phase 8: Final verification gates and summary [NOT STARTED]
- **Goal:** Prove the refactor is semantics-preserving end-to-end and write the summary. No file
  relocation in this phase.
- **Tasks:**
  - [ ] Full `lake build` at repo root: exit 0.
  - [ ] Axiom check on the 4 flagship theorems via `lean_verify` (or `#print axioms` in a scratch
        snippet): `kvE_subBracket2V_correctness_pair`, `reflatten_prop43`,
        `bracketEndChar_kvE2_two_eq`, `f2_relativized_refutation` — each must report exactly
        `[propext, Classical.choice, Quot.sound]`.
  - [ ] Sorry gate: `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/` —
        occurrence count and locations must match `git show $ORIG_SHA:...NfMultiAnchorBridge.lean | grep -c "sorry"`
        (pre-existing comment/record mentions only; zero new).
  - [ ] Consumer gate: `git diff $ORIG_SHA -- Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean`
        empty; `grep -rn "NfMultiAnchorBridge" Theories/ Tests/` still shows exactly 1 import
        (KampPrior.lean:4) + pre-existing comment refs.
  - [ ] Reconciliation line-count audit: `wc -l` of umbrella + 10 modules; sum of relocated
        bodies ≈ 9,249 minus excised nothing (all content preserved); every module <= ~2,100
        lines; report the table in the summary.
  - [ ] De-privatization audit: confirm exactly 11 `private ` removals total across all module
        diffs vs `$ORIG_SHA` slabs (list them in the summary).
  - [ ] Write `specs/331_refactor_nfmultianchorbridge_split_and_separate_bracket_api/summaries/01_split-summary.md`:
        module table (file, line count, role), the 11 de-privatizations, the one relocation, the
        three settled divergences carried forward, gate results, and the pointer for task 321 v7
        (API surface = SubBracket2V + NavigatedSpine banners).
- **Estimated output:** ~150 lines (summary file) + gate command outputs. One bounded
  verification unit with a fixed checklist.
- **Done when:** all five gates pass and the summary exists.
- **Commit:** `task 331 phase 8: final verification gates and summary` (then task-level
  `task 331: complete implementation` per orchestrator convention)
- **Timing:** ~45 min
- **Depends on:** 7

## Testing & Validation

- [ ] `lake build` exit 0 after EVERY phase (1-8) — never batch.
- [ ] Byte-identity slab diff per phase against `$ORIG_SHA` (empty, or exactly the phase's
      inventoried `private ` removals).
- [ ] Phase 8 gates: axiom check (4 flagship theorems), sorry count parity, KampPrior untouched,
      exactly-11 de-privatization audit, line-count reconciliation.
- [ ] No test-suite changes expected; `Tests/BimodalTest` builds as part of `lake build` if in
      the default targets (do not add tests — this task is relocation-only).

## Artifacts & Outputs

- `plans/01_split-and-api-plan.md` (this file)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/{Base,CarrierK1V,CarrierKv,RefutationF2,PriorInterface,MergedQuarantine,SubBracket,SubBracket2,SubBracket2V,NavigatedSpine}.lean`
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` (reduced to umbrella)
- `specs/331_.../.orig-sha` (pre-task snapshot pin, Phase 1)
- `summaries/01_split-summary.md` (Phase 8)

## Rollback/Contingency

- Fix-forward is the default: missed import or missed de-privatization → fix the new module in
  place, re-run `lake build`.
- Every phase ends at a green commit, so the blast radius of any failure is one phase. To
  abandon a broken phase: `bash .claude/scripts/git-snapshot.sh`, then restore the previous
  green commit; the plan resumes at the same phase.
- If the Risk-2 contingency fires (unexpected code-crossing from the quarantine region), apply
  SETTLED decision 5's fallback (faithful modules import `MergedQuarantine`), flag it in the
  summary, and continue — do not redesign the module map mid-implementation.
- Full-task rollback (not expected): the umbrella strategy means reverting all task commits
  restores the original monolith exactly; no consumer ever changed.
