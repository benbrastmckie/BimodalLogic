# Decision Record: Counter/Archive Numbering Reconciliation

- **Record**: 01_numbering-remedy-decision.md
- **Status**: measurements and decision below; BEFORE reading captured here, AFTER reading
  appended at close of the implementing plan's final phase.

## Discharge Attestation (BEFORE Reading)

Measured directly, not inferred:

| Quantity | Measured value |
|----------|----------------|
| `bash .claude/scripts/validate-state.sh --deep specs/state.json` exit code | 0 |
| Check 12 line | `[PASS] Check 12: next_project_number (926) names a free number` |
| Overall tally | 19 passed / 19 warnings / 0 failed |
| `specs/state.json` `next_project_number` | 926 |
| Maximum active `project_number` | 907 |
| Archive `project_number` values above 843 | 78 total: dense 844-925 (73 archived values; the
  8 numbers 861, 862, 869, 873, 874, 875, 876, 890 in that span belong to live active tasks, not
  archive gaps) plus five isolated outliers: 949, 953, 992, 998, 1054 |
| `state-write.sh --allocate-into --dry-run` probe, non-mutating filter that records the issued
  number into a new `active_projects` entry | Derives **926** — the dense next-free number, not a
  value stranded above the archive maximum of 1054. The call is refused, but by the **unrelated
  audit-evidence gate** (`exit 5`, "this write would introduce 1 new active_projects entry(ies);
  1 of them carry no covering --audit-verdict entry and no --audit-override") — never by the
  allocator itself, and never by Check 12's invariant. |

Both consequences the task description named are therefore confirmed discharged:
`state-write.sh --allocate-into` no longer refuses on the counter-vs-archive relation (its only
refusal in this probe is the audit-evidence gate, a wholly separate mechanism gating *new task
creation*, not number allocation), and `validate-state.sh --deep` is no longer permanently red —
it exits 0 with Check 12 passing, so a future genuine finding there will move the exit code again.

This discharge was NOT produced by this record: `scripts/lib/project-number-inuse.sh` (the
membership-based shared definition both `state-write.sh`'s `--allocate-into` prefix and
`validate-state.sh`'s Check 12 now consume) is already deployed in this repository, as the
implementing plan's Overview states. This record attests to that discharge with its own
independent measurements above, rather than re-implementing the remedy.

## Outlier Row Evidence (Re-Measured)

| Number | Archived directory | `project_name` | `status` (archive/state.json) |
|--------|--------------------|-----------------|-------------------------------|
| 949 | `specs/archive/949_update_demo_lean_bimodal_logic` | `update_demo_lean_bimodal_logic` | `abandoned` |
| 953 | `specs/archive/953_refactor_proof_system_to_bilateral` | `refactor_proof_system_to_bilateral` | `abandoned` |
| 992 | `specs/archive/992_shift_closed_tense_s5_algebra` | `shift_closed_tense_s5_algebra` | `abandoned` |
| 998 | none | `fmp_redesign_strict_temporal` | `abandoned` |
| 1054 | `specs/archive/1054_splitting_seed_consistent` | `splitting_seed_consistent` | `orphan_archived` |

This confirms the task description's claim: four of the five outliers carry a real archived
directory, the fifth (998) does not and is an ordinary abandoned task that never reached a
directory — not a defect to backfill (plan Non-Goals already rules out creating one).

## Guardrails Confirmed Still Held

- **No live task renumbered.** This record modifies no `active_projects` entry and no
  `project_number`. `specs/state.json`'s `next_project_number` (926) is read-only in this task.
- **Archive untouched.** `specs/archive/state.json` and every `specs/archive/{N}_*` directory
  listed above are read-only in this task; no row is modified or relocated by this record.
- **Fallback allocation route intact.** `commands/task.md` Step 1 reads `next_project_number`
  via `jq -r '.next_project_number' specs/state.json` into `$next_num`, which flows into Step 6's
  `state-write.sh` call (`.next_project_number = {NEW_NUMBER}`, `"project_number": {N}`) without
  going through `--allocate-into`. This route is unmodified by this task and remains the route
  every task creation in this repository currently uses.

## Vault-Relocation Remedy: Decision

**Decision: DECLINE.** The five pre-reset-era rows stay exactly where they are in
`specs/archive/state.json`; none is relocated to `specs/vault/`.

**Evidence for declining:**

`scripts/lib/project-number-inuse.sh`'s own header states the exclusion's purpose precisely:
`specs/vault/**` is kept outside every in-use definition "because a vault operation renumbers
active tasks down and resets the counter, [and] counting a vaulted number here would make every
post-vault state permanently unable to allocate" — i.e., the exclusion exists so a **vault
operation** (`commands/todo.md` Step 5.7) can deliberately *recycle* a number range it has just
vacated by renumbering.

Relocating these five rows to `specs/vault/` would invoke that exact recycling mechanism on
numbers that are not vacated in the sense the mechanism assumes:
- Four of the five (949, 953, 992, 1054) are cited by committed git history and by real on-disk
  archived directories carrying real artifacts — they are not an orphaned, superseded numbering
  epoch a vault operation swept clean, but specific, individually addressable historical tasks.
- Making them re-issuable would let a future `/task` creation collide a brand-new task's number
  with one of these four directories' own number, corrupting the one-directory-per-number
  invariant the rest of the archive relies on.
- The membership-based allocator (already deployed, confirmed in the Discharge Attestation above)
  already achieves every practical goal a relocation would have bought: dense allocation (926,
  not 1055), with the five outliers correctly excluded from blocking that density. Relocation
  would trade a now-working mechanism for a riskier one, for no measurable gain.

No countervailing evidence was found during this record's own measurements: none of the five
rows exhibits any sign of being a vacated, deliberately-reset numbering epoch (each has a unique
real history, distinct `project_name`, and in four of five cases a real archived directory) —
the opposite of what the vault-recycling exclusion is for. Remedy (i) — the membership-based
allocation bound, already implemented and deployed — remains the sole remedy applied; remedy (ii)
is considered on its merits here and declined, not passed over silently.

## Statement: No Archived Row Modified or Relocated

This record confirms explicitly: no row in `specs/archive/state.json`, and no directory under
`specs/archive/`, is modified, relocated, or otherwise mutated by this task. Every production
edit made under this task's implementing plan lands in `agent-system/extensions/core/scripts/state-write.sh`
(a comment-only correction), `agent-system/extensions/core/context/reference/state-management-schema.md`
(a new documentation subsection), the coupled `index-entries.json` regeneration, and this
`specs/**` record itself.

## AFTER Reading

Captured in this plan's final phase, after the source-store edits were committed and this
repository's deployed `.claude/` tree was redeployed:

- `bash .claude/scripts/validate-state.sh --deep specs/state.json` AFTER exit code: **0**
  (identical to the BEFORE exit code — no regression).
- Check 12 line: `[PASS] Check 12: next_project_number (926) names a free number` (identical to
  BEFORE).
- Overall tally: 19 passed / 19 warnings / 0 failed (identical to BEFORE — no check regressed).
- `timeout 540 bash .claude/scripts/deploy-headless.sh`: `RESULT=landed_verify_clean`, with its
  own bundled `verify-deploy.sh` run (deploy-consumer gates only, `--skip-slow`) reporting
  `[verify-deploy] PASS -- 15 check(s), 0 failure(s)`.
- **Batch Gate Deferral, scoped discharge**: this dispatch's own Batch Gate Deferral directive
  asks for a narrowing invocation (`run-all.sh --only SUITE[,...]` or `verify-deploy.sh
  --only-gate N[,...]`) covering the files this phase touched, in place of independently running
  the complete gate set. Neither narrowing form reaches this task's actual edits from this
  repository: `verify-deploy.sh`'s source-store-only gates (3, 4, 6, 7, 12, and others) `[SKIP]`
  unconditionally in a deploy-consumer repository that lacks its own `agent-system/extensions`
  tree — confirmed directly in the `deploy-headless.sh` output above, which shows exactly that
  skip reason on every such gate. The substantive scoped check for this task's edited files
  (`state-write.sh`, `state-management-schema.md`, `index-entries.json`) is therefore the
  six-suite `run-all.sh --only test-context-reachability.sh,test-deploy-orphans.sh,test-index-entries-schema.sh,test-install-uninstall-extension.sh,test-manifest-scripts-sync.sh,test-orchestrate-build-dispatch.sh`
  subset already run from the source-store repository root in Phase 3 (6 passed, 0 failed) — the
  UNMAPPABLE CRITERION path, since the two narrowing forms, run from this repository, cannot
  express it. The complete gate set itself still runs once, for the whole batch, at the end of
  this `/orchestrate` invocation, per the directive.
- `specs/state.json`'s `next_project_number` confirmed unchanged across the whole task: 926 at
  both BEFORE and AFTER.
- `specs/archive/state.json` confirmed byte-unchanged across the whole task (`git diff --stat --
  specs/archive/` reports no change; no archived row touched).
- Deployed copies of both edited source-store files confirmed byte-identical to their
  source-store originals (`diff` exits 0 for both `state-write.sh` and
  `state-management-schema.md`).
- `commands/task.md`'s Step 1 `jq -r '.next_project_number'` read, flowing into Step 6's write,
  confirmed present and unmodified.
