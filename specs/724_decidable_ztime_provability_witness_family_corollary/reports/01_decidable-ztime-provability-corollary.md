# Research Report: Task #724

**Task**: 724 - Decidability of Z-time provability as a corollary of `Compression.decidableValidZTime`
**Started**: 2026-10-04T00:00:00Z
**Completed**: 2026-10-04T00:00:00Z
**Effort**: Small (the corollary is ~6 lines; the surrounding gate obligations are the bulk)
**Dependencies**: Task 723 (completed — its C14 baseline rows are the shape this task extends)
**Sources/Inputs**:
- Codebase: `FormalSystem/Metalogic/Soundness.lean`, `FormalSystem/Metalogic/BXCanonical/Completeness.lean`, `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Assembly.lean`, `FormalSystem/ProofSystem/Derivable.lean`
- Gates: `scripts/check-module-invariants.sh` (B0–B3, C1–C37), `docs/theorem-index.md`
- lean-lsp MCP: `lean_run_code` (two compiled probes, both green)
- Computed import-graph analysis over all `FormalSystem/**/*.lean` import lines
- No literature source is referenced by this task; the Literature Extraction Protocol does not apply.

**Artifacts**:
- `specs/724_decidable_ztime_provability_witness_family_corollary/reports/01_decidable-ztime-provability-corollary.md`

**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **All three composing declarations re-verified by `#check` against the built library.** Exact
  signatures recorded below; none had drifted from the dispatch's description.
- **The corollary is confirmed unwritten.** `grep -rn --include='*.lean' 'Decidable (Derivable'
  FormalSystem/` returns zero hits (exit 1). The only unrestricted hits are a `not built`
  documentation row in `FormalSystem/Metalogic/Decidability/Verified/README.md`, a forward-looking
  comment in `scripts/check-module-invariants.sh`, `specs/ROADMAP.md` and `specs/state.json` — no
  declaration.
- **The full composition compiles, sorry-free, and its axiom set is already measured.** A
  `lean_run_code` probe in the exact proposed namespace and `open` set returns
  `[propext, Classical.choice, Quot.sound]` for both the iff leg and the `Decidable` def — so the
  new C14 baseline lines can be written before the file is.
- **Placement must NOT be `Compression/Assembly.lean` nor a sibling under
  `WitnessFamily/Compression/`.** Measured: that placement pulls **+331 net-new transitive
  imports** into an 84-module file and **+318** into both `WitnessFamily.lean` and
  `BimodalTools/CertificateImport.lean`. Recommended placement
  `FormalSystem/Metalogic/ZTimeProvability.lean` costs **+2** net-new imports into
  `Metalogic.lean` and **zero** elsewhere. No cycle exists in any option.
- **The dispatch's docstring wording conflicts with C9.** "remain task 412's" cannot be written
  into `FormalSystem/**`; durable anchors are supplied below.
- **Recommended approach achieves zero sorries and introduces no axiom.** No `sorry`-deferral or
  axiom-introduction path was considered or is needed.

## Context & Scope

Researched: whether `Decidable (Derivable FrameClass.ZTime [] φ)` composes from the three named
pieces; where the resulting module can live without a cyclic import or an import-weight
regression; and every mechanical gate obligation that landing it triggers
(`check-module-invariants.sh`, `docs/theorem-index.md`, the two per-directory README tables).

Out of scope, per the dispatch's hard constraints: the tableau spine, any complexity claim, any
unqualified "TM is decidable" statement, and the C9 do-not-re-attempt register. None was touched.

## Findings

### Codebase Patterns

#### 1. The three composing declarations — re-verified by `#check`

All three exist at the paths the dispatch names. `#check` output against the built library:

| Declaration | Verified signature |
|---|---|
| `FormalSystem.Metalogic.soundness_ztime_valid` | `∀ {phi : Formula} (d : ⊢[FrameClass.ZTime] phi), Semantics.ValidZTime phi` |
| `FormalSystem.Metalogic.BXCanonical.derivable_of_validZTime` | `∀ (φ : Formula), Semantics.ValidZTime φ → \|-![FrameClass.ZTime] φ` |
| `FormalSystem.Metalogic.Decidability.Compression.decidableValidZTime` | `(φ : Formula) → Decidable (Semantics.ValidZTime φ)` |
| `FormalSystem.ProofSystem.Derivable` | `FrameClass → Context → Formula → Prop` |

Confirmations of the dispatch's own claims:
- `Compression.decidableValidZTime` is a `def`, not an `instance`
  (`Compression/Assembly.lean:147`), deliberately — a global instance would change resolution
  repository-wide. Callers `letI` it. **The new corollary must follow the same `def`-not-`instance`
  discipline.**
- `Derivable fc G p` is literally `Nonempty (DerivationTree fc G p)`
  (`FormalSystem/ProofSystem/Derivable.lean:69-70`), so the soundness leg needs a `Nonempty`
  elimination. `h.elim (fun d => soundness_ztime_valid d)` discharges it (target is a `Prop`).
- `ValidZTime` lives in `FormalSystem.Semantics`, not `FormalSystem.Metalogic`.

#### 2. The corollary is unwritten, not duplicated

- `grep -rn --include='*.lean' 'Decidable (Derivable' FormalSystem/` → **zero hits** (exit 1).
- Unrestricted hits, all non-declarations: `FormalSystem/Metalogic/Decidability/Verified/README.md:62`
  (a `not built` table row for the never-created `Provable.lean`, Track B's
  `Decidable (Derivable fc [] φ)` *parameterized over `fc`* via the tableau spine);
  `scripts/check-module-invariants.sh:2043-2048` (a forward-looking comment expecting exactly this
  declaration); `specs/ROADMAP.md:317`; `specs/state.json`.
- No name collision: `decidableDerivableZTime`, `derivable_iff_validZTime`,
  `decidableProvableZTime` and `provableZTime` are all absent from `FormalSystem/`.

#### 3. The compiled probe — both legs, in situ, green

`lean_run_code`, importing `Metalogic/Soundness.lean`, `Metalogic/BXCanonical/Completeness.lean`
and `Decidability/WitnessFamily/Compression/Assembly.lean`, inside `namespace
FormalSystem.Metalogic` with `open FormalSystem.Syntax FormalSystem.ProofSystem
FormalSystem.Semantics`:

```lean
theorem derivable_iff_validZTime (φ : Formula) :
    Derivable FrameClass.ZTime [] φ ↔ ValidZTime φ :=
  ⟨fun h => h.elim (fun d => soundness_ztime_valid d),
   BXCanonical.derivable_of_validZTime φ⟩

def decidableDerivableZTime (φ : Formula) :
    Decidable (Derivable FrameClass.ZTime [] φ) :=
  letI := Decidability.Compression.decidableValidZTime φ
  decidable_of_iff (ValidZTime φ) (derivable_iff_validZTime φ).symm
```

Result: `success: true`, no errors, no warnings, and

```
'FormalSystem.Metalogic.derivable_iff_validZTime' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.decidableDerivableZTime' depends on axioms: [propext, Classical.choice, Quot.sound]
```

A third probe confirmed `decidableDerivableZTime φ` also inhabits
`Decidable (Nonempty (DerivationTree FrameClass.ZTime [] φ))` directly, since `Derivable` is a
`def` that unfolds.

Evidence tier: compiled-probe (LSP-backed `lean_run_code` against the built `.olean`s, all three
present and dated 2026-10-03). Not degraded.

**One failure mode found and recorded, so the implementer does not rediscover it**:
`decidable_of_iff (a) (h : a ↔ b) : Decidable b`. The target is `Decidable (Derivable …)`, so
`h` must be `ValidZTime φ ↔ Derivable … φ` — i.e. `(derivable_iff_validZTime φ).symm`, with the
`.symm` on the *iff*, not on the `decidable_of_iff` application. Writing it the other way round
gives `Application type mismatch`.

#### 4. Import-graph analysis — placement is the one real decision

Computed over every `import` line under `FormalSystem/` plus `FormalSystem.lean` and
`BimodalTools/CertificateImport.lean`.

**No cycle exists in any option.** Neither `Metalogic/Soundness.lean` nor
`Metalogic/BXCanonical/Completeness.lean` transitively imports *any* module under
`Metalogic/Decidability/`, and `Compression/Assembly.lean`'s closure contains no `BXCanonical`
module. The dispatch's cyclic-import worry is resolved negatively: there is no cycle to avoid.

What there *is* instead is an import-weight question, and it is large. The corollary's own
required closure is **415 modules** (union of the three legs' closures).

| Placement | Host aggregator affected | Host's current closure | Net-new modules the host gains |
|---|---|---|---|
| Inside `Compression/Assembly.lean` | the file itself | 84 | **+331** |
| New sibling under `WitnessFamily/Compression/`, imported by `WitnessFamily.lean` | `WitnessFamily.lean` | 111 | **+318** |
| ″ (knock-on) | `BimodalTools/CertificateImport.lean` | 115 | **+318** |
| New module under `Decidability/`, imported by `Decidability.lean` | `Decidability.lean` | 341 | **+232** |
| **`FormalSystem/Metalogic/ZTimeProvability.lean`, imported by `Metalogic.lean`** | `Metalogic.lean` | 719 | **+2** |

The +2 are exactly `…WitnessFamily.Compression.Assembly` and
`…WitnessFamily.Compression.Enumerate`; both are already in the `FormalSystem.lean` root closure,
so repository-wide build cost is unchanged.

Two further arguments against the `Decidability/`-interior options:
- `Compression/README.md:95-103` records the subtree's dependency invariants explicitly ("its only
  dependency on `../BiLasso/` is `Periodic.lean`", widened to two and *recorded rather than
  hidden*). Pulling the whole BXCanonical canonical-model completeness engine into that subtree is
  a far larger change to the same invariant, and would have to be re-documented there.
- `BimodalTools/CertificateImport.lean` imports `…Decidability.WitnessFamily`. Any placement that
  `WitnessFamily.lean` imports makes the tooling split pay for the completeness engine.

`Metalogic.lean` already directly imports both `FormalSystem.Metalogic.Decidability` and
`FormalSystem.Metalogic.BXCanonical`, so `Metalogic/` is where these two programmes already meet.
Importers of `FormalSystem.Metalogic` are `MainResults`, `Examples.Walkthrough` and
`FormalSystem` — none of which is imported by either leg, so adding the import is cycle-free.

#### 5. Gate obligations triggered by a new module (all mechanically enforced)

Read off `scripts/check-module-invariants.sh`'s own check list:

| Check | Obligation |
|---|---|
| **C33** | `FormalSystem.lean` must be byte-for-byte `lake exe mk_all --lib FormalSystem` output — one sorted `import` line per `.lean` under `FormalSystem/`. **The new module must be inserted in sorted position.** Build-free, runs in CI. |
| **C14** | Append **one matched pair** of lines — one to the `C14_BASELINE` heredoc (ends at `scripts/check-module-invariants.sh:2256`) and one to the `C14LEAN` `#print axioms` heredoc (ends at `:2463`) — in the **same trailing position**, after `…Compression.decidableValidZTime`. The baseline compares concatenated output in emission order, so position must match. The value is already measured: `[propext, Classical.choice, Quot.sound]`. The comment at `:2043-2048` pre-authorizes exactly this edit. |
| **C15** | Every `docs/theorem-index.md` row must carry its anchor *at the declaration itself*: either `Paper: <anchor>` or the literal `Paper: —` **plus a reason**. Mirror `Compression.decidableValidZTime`'s docstring form. |
| **C9** | **Zero task-number citations under `FormalSystem/`.** See Decisions below. |
| **C26** | No live `def`/`abbrev` name may carry a non-trailing underscore. `decidableDerivableZTime` conforms; `decidable_derivable_ztime` would FAIL. (The companion `theorem` may use underscores — C26 scopes to `def`/`abbrev`.) |
| **C17** | Dead-declaration scan over `FormalSystem/` + `Tests/` + repo-wide markdown + `typst/**/*.typ` + `scripts/*.sh`. The `def` is covered by its `docs/theorem-index.md` row and its C14 baseline lines; the companion `theorem` is covered by the `def`'s body reference. Both are safe **only if the index row and baseline lines land in the same change**. |
| **C37** | Scans `def`/`abbrev`/`structure`/`class` under `WitnessFamily/` (among two other roots) whose **comment-masked body** contains a `↔`, failing any unlisted hit as an unreviewed biconditional clause. Two independent reasons this is a non-issue: the recommended placement is outside all three certificate roots, and keeping the iff in a separate `theorem` (not inlined into the `def`) leaves no `↔` token in any `def` body. **Do not inline the biconditional into the `def`.** |
| **C27** | A live `#check`/`#print`/`#eval` in library code fails unless the file has a `scripts/debug-artifact-allowlist.txt` entry. Neither `BXCanonical/Completeness.lean` nor `Compression/Assembly.lean` has one — their "Axiom Audit" `#print axioms` lines sit inside `/-! … -/` docstrings, which C27 masks. **Put any axiom-audit block in a docstring, as those two files do.** |
| **C24** | Every module in the root closure must transitively import `FormalSystem.Init`. Verified: all three legs reach it, so the new module does too. |
| **C8** | Aggregator convention walks only `FormalSystem/`, `Metalogic/`, `Syntax/`, `Semantics/`, and requires `X.lean` beside `X/`. A new *file* (not directory) triggers nothing. |
| **C28** | Warning budget is per-file and only lists files that have warnings; a zero-warning new file needs no entry. The probe produced no warnings. |
| **C23** | No new outer-shadows-inner bare-declaration pair. Placing the `def` in `FormalSystem.Metalogic` (not in a `Compression` sub-namespace) creates no shadow pair, so `SHADOW_PAIR_ALLOW` needs no new entry. |

#### 6. Documentation surfaces that need a row

- `docs/theorem-index.md`, `### Decidability` section, immediately after the
  `Compression.decidableValidZTime` row (line 153). Column contract from the file's own "How to
  read a row": Paper label `—`; Statement one line; Lean name **fully qualified, always**; File
  **path only, no line numbers**; Frame class `ZTime`; Axioms `pcq pinned:C14` (`pcq` abbreviates
  exactly `[propext, Classical.choice, Quot.sound]`; the column is generated from the baselines,
  never typed). Note the page's own standing claim: *"Every declaration listed here is
  machine-pinned"* — so anything given a row must get a C14 pair.
- `FormalSystem/Metalogic/Decidability/WitnessFamily/README.md` (module table, line ~100) and
  `…/Compression/README.md` (module table, line ~43): **no row needed under the recommended
  placement**, since the new module is not in that subtree. If placement changes, both tables
  need a row, and `Compression/README.md`'s "One sub-namespaced declaration" section (line ~107)
  would need rewriting if a second declaration joined the `Compression` namespace.
- `docs/` carries **no** prose asserting decidability of provability is unestablished, so no
  reconciliation debt there. Searched `docs/`, `README.md`,
  `FormalSystem/Metalogic/Decidability.lean`: no hit.
- `specs/ROADMAP.md:317` checkbox may be ticked (a `specs/` artifact; task numbers are permitted
  there).

### External Resources

No Mathlib search was required: the only Mathlib-side ingredient is `decidable_of_iff`, already
in use at `Compression/Assembly.lean:148` and `:165`. No rate-limited search tool was called, so
no fallback or rate-limit handling was exercised.

### Recommendations

A zero-`sorry`, zero-new-axiom path exists and is already compiled. Recommended implementation, in
order:

1. **Create `FormalSystem/Metalogic/ZTimeProvability.lean`** with the three imports
   (`FormalSystem.Metalogic.Soundness`, `FormalSystem.Metalogic.BXCanonical.Completeness`,
   `FormalSystem.Metalogic.Decidability.WitnessFamily.Compression.Assembly`), `namespace
   FormalSystem.Metalogic`, `open FormalSystem.Syntax FormalSystem.ProofSystem
   FormalSystem.Semantics`, and the two declarations exactly as probed:
   `theorem derivable_iff_validZTime` then `def decidableDerivableZTime`.
2. **Write the docstrings** carrying the required qualifiers (`FrameClass.ZTime`; `Formula`, which
   has no stability operator — that is `PlusFormula`'s `⊡`; empty premises `[]`), the
   "without the spine" record using the durable anchors in Decisions below, `Paper: —` plus a
   reason for C15, and an axiom-audit note **inside a `/-! … -/` block** for C27. Never the phrase
   "TM is decidable"; no complexity claim (`Compression/Assembly.lean`'s own header already states
   the cost honestly and points at [GKWZ] 2003 §6.5 — cite it, do not restate a bound).
3. **Insert the import into `FormalSystem.lean`** in sorted position (C33). Verify with
   `lake exe mk_all --lib FormalSystem` and diff, not by eye.
4. **Add the import to `FormalSystem/Metalogic.lean`.** If a SORRY-FREE bullet is added to that
   file's module docstring, name **only** declarations that get C14 baseline lines — the
   `:2033-2035` comment makes an unpinned SORRY-FREE bullet exactly the drift C14's second block
   exists to catch.
5. **Append the C14 matched pair** to both heredocs, trailing position, value
   `[propext, Classical.choice, Quot.sound]`.
6. **Add the `docs/theorem-index.md` row.**
7. **Run `lake build` detached and guarded** per
   `context/project/lean4/operations/long-builds.md` and
   `context/patterns/bounded-build-waiter.md` (hard timeout, `kill -0` on the captured PID, one
   waiter per log). Then `bash scripts/check-module-invariants.sh` for C9/C14/C15/C17/C26/C33.
8. **Commit per green sub-step**, not once at the end.

Suggested one-line index Statement, honouring every qualifier:
*"Decidability of ℤ-time provability: `Derivable FrameClass.ZTime [] φ` is decidable, by
soundness and completeness composed with the witness-family validity procedure"*.

## Decisions

- **`FormalSystem/Metalogic/ZTimeProvability.lean`, not `Compression/Assembly.lean`.** The
  dispatch offers `Assembly.lean` "or a sibling module under `WitnessFamily/Compression/`" and asks
  that the import graph be resolved first. It was: both offered options cost +331/+318 net-new
  transitive imports and would propagate into `BimodalTools/CertificateImport.lean`, against +2
  for `Metalogic/`. `Metalogic.lean` is already the one aggregator importing both `Decidability`
  and `BXCanonical`. This is a deliberate, measured departure from the dispatch's suggested
  location, not an oversight; the dispatch's stated *requirement* — resolve placement before
  writing, not after a cyclic-import error — is met, and there is no cycle in any option.
- **Two declarations, not one.** Keeping `derivable_iff_validZTime` as a separate `theorem` (a) is
  independently valuable — it is the soundness-plus-completeness biconditional at `ZTime` — and
  (b) keeps every `↔` out of any `def` body, which matters if placement ever moves under a
  certificate root (C37).
- **`def`, not `instance`,** mirroring `Compression.decidableValidZTime` and
  `BiLasso/Assembly.lean`'s `decidableValidZTimeFamily`. A global
  `Decidable (Derivable FrameClass.ZTime [] φ)` instance would change resolution repository-wide.
- **Namespace `FormalSystem.Metalogic`, not `…Decidability.Compression`.** Three reasons: no
  shadow pair, so C23's `SHADOW_PAIR_ALLOW` needs no new entry; `Compression/README.md:107`'s
  standing statement that `Compression.decidableValidZTime` is *the only* sub-namespaced
  declaration in that subdirectory stays true; and the result is a metalogic corollary, not part
  of the compression route.
- **The docstring must NOT say "task 412's".** The dispatch's DOCSTRING REQUIREMENT asks for it,
  but C9 asserts zero task-number citations under `FormalSystem/` and
  `.claude/rules/no-task-references-in-deliverables.md` forbids them outright, with `specs/**`,
  commit messages and PR metadata the only exemptions. Substitute these durable anchors, which
  were verified to resolve:
  - `FormalSystem/Metalogic/Decidability/Verified/README.md`'s `Provable.lean` row — "Track B:
    `Decidable (Derivable fc [] φ)` and the completeness corollaries | not built" — the
    `fc`-parameterized spine deliverable this corollary does *not* supply.
  - `FormalSystem/Metalogic/Decidability/Correctness.lean`'s section
    "`validity_decidable` / `validity_has_decision_procedure` — Retired as vacuous".
  - `FormalSystem/Metalogic/Decidability.lean`'s Status section, which records that the
    completeness direction and "the `Decidable (⊨ φ)` instances for the four frame classes" are
    **open**.
  Recommended phrasing shape: *"This closes decidability of provability over ℤ — one of the four
  frame-class deliverables the tableau spine was to supply — without the spine. The other three
  (`Base`, `Dense`, `RTime`) remain owed by the spine's completeness direction: see
  `Decidability/Verified/README.md`'s `Provable.lean` row and `Decidability/Correctness.lean`'s
  'Retired as vacuous' section."*
- **`Verified/README.md:62` stays as it is.** Its `not built` verdict is about the never-created
  `Provable.lean` and about `Decidable (Derivable fc [] φ)` parameterized over `fc` via the
  tableau spine — still accurate, and editing it is adjacent to the "do not touch the tableau
  spine" constraint. An *optional* one-sentence cross-reference there (noting that the `ZTime`
  instance of that shape now exists by a different route) would reduce misreading; left to the
  implementer, and not required by acceptance.

## Risks & Mitigations

| Risk | Mitigation |
|---|---|
| Implementer follows the dispatch's suggested `Assembly.lean` placement and lands a +331-import regression | The measured table in Findings §4 is the evidence; the plan must name `FormalSystem/Metalogic/ZTimeProvability.lean` explicitly |
| Implementer writes "task 412" into the docstring, failing C9 | Durable anchors and recommended phrasing supplied in Decisions |
| `FormalSystem.lean` import inserted out of sorted order → C33 fails | Regenerate with `lake exe mk_all --lib FormalSystem` and diff rather than hand-editing |
| C14 pair appended to only one heredoc, or at mismatched positions | Both line anchors given (`:2256` baseline tail, `:2463` `#print axioms` tail); the baseline compares concatenated output in emission order |
| `def` lands with no index row or baseline line in the same change → C17 flags it dead | Land the Lean file, the index row and the C14 pair in one change set |
| `#print axioms` written as a live line in the new file → C27 fails (no allowlist entry) | Keep it inside a `/-! … -/` docstring, as `Completeness.lean` and `Compression/Assembly.lean` do |
| `decidable_of_iff` direction mismatch | Exact working term recorded in Findings §3, with the failure mode spelled out |
| A SORRY-FREE bullet added to `Metalogic.lean` naming an unpinned declaration | Name only what the C14 pair pins |
| `lake build` is long and may overrun a dispatch | Detached + guarded per `long-builds.md` / `bounded-build-waiter.md`; the mathematics is already verified by compiled probe, so a build timeout is a gate risk, not a correctness risk |

**Zero-debt compliance**: the recommended path is fully proved. No `sorry`, no placeholder, no new
axiom, no Option-B deferral. The axiom set is `[propext, Classical.choice, Quot.sound]` —
identical to every other declaration in the C14 trailing block, so not a regression.

## Tactic Survey Results

Survey run via compiled `lean_run_code` probes rather than `lean_multi_attempt`, because both
declarations are term-mode one-liners and the whole goal is a single application each. No
`lean_hammer_premise` call was needed.

| Goal | Tactic / term | Result | Premises/Config |
|---|---|---|---|
| `Derivable FrameClass.ZTime [] φ ↔ ValidZTime φ` | anonymous constructor `⟨_, _⟩` | success | forward leg `h.elim (fun d => soundness_ztime_valid d)`; backward leg `BXCanonical.derivable_of_validZTime φ` |
| forward leg: `Derivable … φ → ValidZTime φ` | `Nonempty.elim` (as `h.elim`) | success | needed because `Derivable` is `Nonempty (DerivationTree …)`; target is a `Prop`, so no `Classical.choice` is introduced by this step |
| `Decidable (Derivable FrameClass.ZTime [] φ)` | `decidable_of_iff (ValidZTime φ) (derivable_iff_validZTime φ).symm` | success | requires `letI := Decidability.Compression.decidableValidZTime φ` in scope first |
| same goal, `.symm` omitted | `decidable_of_iff _ (derivable_iff_validZTime φ)` | **fail** | `Application type mismatch`: `decidable_of_iff (a) (h : a ↔ b) : Decidable b`, so `h` must run `ValidZTime → Derivable` |
| `Decidable (Nonempty (DerivationTree FrameClass.ZTime [] φ))` | `decidableDerivableZTime φ` | success | confirms `Derivable` unfolds, so the corollary covers the `DerivationTree`-shaped statement too |

No automation tactic (`simp`, `omega`, `decide`, `aesop`) is applicable or needed: the goal is
`Decidable`-valued data, not a `Prop` to be searched. APOLLO-style decomposition is not warranted
for a six-line term.

## Context Extension Recommendations

- **Topic**: Import-weight budgeting as a placement criterion for Lean modules in this tree.
- **Gap**: `context/project/lean4/` covers MCP tooling, blocked tools, dependency tracing and
  Comparator trust, but nothing tells an agent to *measure* net-new transitive imports before
  choosing a module's directory. This task's dispatch suggested a placement that measurement
  rejected by a factor of 165 (+331 vs +2), and the same question will recur every time a
  corollary joins two previously disjoint subtrees.
- **Recommendation**: add `context/project/lean4/patterns/module-placement-import-weight.md`
  recording the procedure (parse every `import` line under the library root, compute transitive
  closures, tabulate net-new per candidate host aggregator, and check knock-on hosts such as
  `BimodalTools/`), plus the two standing constraints that interact with it — C33's
  `mk_all`-byte-exactness and C8's aggregator convention. Cross-reference from
  `context/project/lean4/patterns/dependency-tracing.md`.

## Appendix

### Search queries and probes used

- `grep -rn --include='*.lean' 'Decidable (Derivable' FormalSystem/` → 0 hits (the dispatch's
  negative check, confirmed)
- `grep -rn 'Decidable (Derivable' .` (unrestricted) → 4 non-declaration hits, enumerated in
  Findings §2
- `grep -rn 'soundness_ztime_valid|derivable_of_validZTime|decidableValidZTime' FormalSystem/`
- `grep -rn 'decidableDerivableZTime|derivable_iff_validZTime|decidableProvableZTime|provableZTime' FormalSystem/` → 0 hits (collision check)
- Transitive-import closure computation over all `FormalSystem/**/*.lean`, `FormalSystem.lean`,
  `BimodalTools/CertificateImport.lean`
- `lean_run_code` probe 1: `#check` on all four symbols plus a first composition attempt (caught
  the `decidable_of_iff` direction error)
- `lean_run_code` probe 2: in-situ namespace/open-set version of both declarations plus
  `#print axioms` on each — green
- Gate reading: `scripts/check-module-invariants.sh` check list (lines 1-170), C14 heredoc tails
  (`:2245-2275`, `:2450-2480`), `SHADOW_PAIR_ALLOW` (`:3480-3490`), C37 header and
  `scripts/clause-shape-allowlist.txt` admission bar, `scripts/debug-artifact-allowlist.txt`
  header, `scripts/warning-budget.txt` header

### Durable references

- `FormalSystem/Metalogic/Soundness.lean` — `soundness_ztime_valid`
- `FormalSystem/Metalogic/BXCanonical/Completeness.lean` — `derivable_of_validZTime`
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Assembly.lean` —
  `Compression.decidableValidZTime`, and the module header's honest complexity statement
- `FormalSystem/ProofSystem/Derivable.lean` — `Derivable` as `Nonempty (DerivationTree …)`
- `FormalSystem/Metalogic/Decidability.lean` — Status section; the four-frame-class `Decidable (⊨ φ)`
  instances recorded as open
- `FormalSystem/Metalogic/Decidability/Verified/README.md` — the `Provable.lean` `not built` row
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/README.md` — module table,
  subtree dependency invariants, "One sub-namespaced declaration"
- `docs/theorem-index.md` — "How to read a row", `### Decidability` table
- `scripts/check-module-invariants.sh` — C8, C9, C14, C15, C17, C23, C24, C26, C27, C28, C33, C37
- `.claude/rules/no-task-references-in-deliverables.md`;
  `.claude/context/standards/task-reference-exemptions.md`
- `context/project/lean4/operations/long-builds.md`; `context/patterns/bounded-build-waiter.md`
