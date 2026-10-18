# Implementation Plan: The *Total Histories* clause — `H_F ≅ lim Beh(F)(2x)`

- **Task**: 566 - Prove `app:presheaf-dictionary`'s Possible Worlds clause: `H_F iso lim Beh(F)(2x)` along the central restrictions
- **Status**: [COMPLETED]
- **Effort**: 6.5 hours
- **Dependencies**: 563 (interval site, behavior presheaf), 565 (Totality, Directed Gluing) — both landed and archived
- **Research Inputs**: `specs/566_possible_worlds_clause_hf_as_limit/reports/01_total-histories-limit-clause.md`; the verified probe `specs/566_possible_worlds_clause_hf_as_limit/total-histories-clause-probe.lean`
- **Artifacts**: plans/01_total-histories-limit-clause.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The clause is a concrete limit statement: a possible world is the same thing as a compatible
family of centred sections `(σ_x)_{x ∈ D⁺}`, `σ_x ∈ Beh(F)(2x)`, each restricting to the next
along the central translation `Tr (x' − x) : 2x → 2x'`. Everything lands in one new module,
`FormalSystem/Semantics/Presheaf/Worlds.lean`: a `Lim F` structure presenting the limit as the
type of compatible families (no `Mathlib.CategoryTheory`, per the cluster's recorded decision),
the forward map `Lim.ofWorld` (cut a world to each centred window through `secOf`), the backward
map `Lim.toWorld` (read each time out of its canonical window `|t|` and glue with
`WorldHistory.ofTotal`), both round trips, the `Equiv`, and the nonemptiness tail. The
isomorphism is **choice-free** (`[propext, Quot.sound]`) and holds at **no** frame constraint;
only the tail `lim_nonempty` reaches `Classical.choice`, through `PartialHistory.hF_nonempty`
and hence Zorn, which is where the paper puts it too (`cor:occurrence`).

Definition of done: all 22 declarations of the `## Lean Challenge Statements` section proved
with the pinned signatures, `lake build FormalSystem` green with no new `sorry` at the end of
every phase, every declaration's axiom profile re-measured with `lean_verify` and written as a
table in the module docstring, the module wired into both aggregators, and every convention
gate of `scripts/check-module-invariants.sh` green.

### Research Integration

The report compiled the whole clause end to end via `lean_run_code` and saved the green,
`sorry`-free, choice-free form at
`specs/566_possible_worlds_clause_hf_as_limit/total-histories-clause-probe.lean`. The
implementation round **transcribes that probe**; it does not rediscover the proofs. Findings
consumed directly:

- **The construction and its ingredients** — `secOf w (-x) (x + x)` as the centred cut,
  `Beh.restrict`/`Beh.restrict_states` as the presheaf action, `states_eq_of_eq` and
  `PartialHistory.states_eq_of_time_eq` as the two reading devices, `WorldHistory.ofTotal` as
  the glue. All exist at the locations the report names (re-verified at plan time by grep:
  `Determinism.lean:194`, `Behavior.lean:146/167`, `Sheaf.lean:226`,
  `PartialHistory.lean:331/533/541/552`, `Extension.lean:356`).
- **The keystone** `read_eq`: every window at least `|t|` reads the same state at `t`. Every
  later proof goes through it rather than through `compat` directly.
- **The two measured `Classical.choice` traps.** `simpa` in the window-bound arithmetic
  (`lo'`, `abs_le_of_mem`) pulls `Classical.choice`; the choice-free forms are explicit
  `rwa [neg_add_cancel]`, `rwa [zero_sub]`, `rwa [add_sub_cancel_right]`. Routing the backward
  map through `Presheaf.directedSup` would import `Classical.choice` for nothing; the canonical
  window index `|t|` is what makes the clause choice-free.
- **Two syntactic hazards** reproduced in the probe: `rw [hL]` under a dependent `states`
  witness fails ("motive is not type correct") — use `states_eq_of_eq hL r h h'`; `rw [readAt]`
  has no equation lemma — state a `rfl` definitional lemma and rewrite with that.
- **The clause does not consume Totality.** The chain of centred windows already covers the
  temporal order, so no extension step is needed. The task description's premise that "the
  limit construction consumes Totality" does not hold; the dependency edge on 565 stays as
  recorded, but nothing from `Presheaf/Directed.lean` is imported or used.
- **`FrameOver.mem_HF_iff_adjacent` is a consequence, not an input**, and is declared at
  `FormalSystem/Semantics/IntNormalForm.lean:348`, not in `IntTransfer.lean` as the task
  description says. It is the ℤ reading of this clause and is cited in the module docstring; the
  adjacency argument is not re-derived.
- **The clause's recorded name is *Total Histories*.** `docs/reference/paper-definitions-of-record.md`
  lists it under *Possible Worlds*; the Lean docstring uses the recorded paper text's name and
  notes the record's name in the same sentence.

**Three corrections to the research artefacts, each verified at plan time by compiling the
pinned statements (`lean_run_code`, 22 declarations, 20 `sorry` warnings, zero errors — once
with the module's own import list, once additionally importing `Presheaf.Directed` to surface
same-namespace clashes):**

1. **`ofWorld` collides.** The probe's forward map is named `ofWorld`, but
   `FormalSystem/Semantics/Presheaf/Directed.lean:234` already declares
   `FormalSystem.Semantics.Presheaf.ofWorld` (the cut of a world to `[0, l]`). Transcribing the
   probe verbatim into the cluster namespace is a duplicate-declaration error once both modules
   sit in the root closure — the same trap the Totality plan hit with `states_eq_of_eq`, and
   invisible to the probe because it lives in its own `Probe566` namespace. **Resolution**: the
   limit's maps and lemmas live in the `Lim` namespace (`Lim.ofWorld`, `Lim.toWorld`,
   `Lim.readAt`, `Lim.read_eq`, `Lim.respects`, and the round trips), which also reads
   naturally with dot notation (`L.toWorld`, `(Lim.ofWorld w).toWorld`). The arithmetic helpers
   are renamed to library-grade identifiers: `fit` → `central_fit`, `lo'` → `window_lo`,
   `hi'` → `window_hi`, `abs_le_of_mem` → `abs_sub_le_of_mem`, `Lim.ext'` → `Lim.ext`.
2. **`readAt_def` is not pinned, and `read_eq`'s hypothesis is stated over `|t|`.** A
   Challenge module pins statements with `sorry` bodies, so `(absObj t).val` does not reduce to
   `|t|` there, and the probe's `read_eq` (hypothesis `(absObj t).val ≤ x.val`, witness built
   from `le_refl (absObj t).val`) does not type-check as a pinned statement. The pinned form is
   `Lim.read_eq … (hx : |t| ≤ x.val)`, which is the paper's own phrasing ("every window at least
   `|t|`") and is **definitionally the same statement** in the real module, where `absObj t`
   unfolds; the probe's proof transcribes unchanged. `absObj`'s content is pinned separately as
   `absObj_val : (absObj t).val = |t|`. `Lim.readAt_def` (`rfl`) remains an **unpinned
   implementation device** the implementer states locally if `rw [Lim.readAt]` fails, exactly as
   the probe did; it is not a Goal.
3. **`centralTr`/`restrictTr_central` are not in the saved probe.** The report's
   recommendations list them as compiled, but the saved probe file does not contain them, so
   their *proofs* are CARRIED-UNVERIFIED from the report. Their *statements* compiled green at
   plan time (above). The expected proofs are one anonymous constructor
   (`⟨x'.val - x.val, sub_nonneg.mpr h, central_fit h⟩`) and `rfl`, mirroring
   `Sheaf.lean`'s `restrictTr_coverLeft`/`restrictTr_coverRight`; see Phase 1's fallback.

One further plan-time decision: the module imports `FormalSystem.Semantics.Presheaf.Determinism`
(which carries `Sheaf`, `Behavior`, `Ray`, `Site` transitively, and `secOf`) and
`FormalSystem.Semantics.Extension.Extension` (for `hF_nonempty`) — **not**
`Presheaf.Directed`, which the probe imported only as a convenient route to `Extension`. Both
imports sit below the cluster's `assert_not_exists` lock (`Directed.lean` already imports
`Extension.Extension` and closes with the lock).

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No roadmap context supplied to this dispatch.

## Goals & Non-Goals

- **Goals**: `central_fit`, `twice`, `centralTr`, `restrictTr_central`, `Lim`, `Lim.ext`,
  `Lim.compat_site`, `window_lo`, `window_hi`, `absObj`, `absObj_val`, `Lim.readAt`,
  `Lim.read_eq`, `Lim.respects`, `Lim.toWorld`, `Lim.ofWorld`, `Lim.toWorld_ofWorld`,
  `abs_sub_le_of_mem`, `Lim.ofWorld_toWorld_sec`, `Lim.ofWorld_toWorld`, `worldsEquiv`,
  `lim_nonempty`
- **Goals (non-Lean)**: the measured axiom table in the module docstring, with the two `simpa`
  prohibitions and the `directedSup` prohibition recorded as Implementation Notes; the ℤ
  reading pointer to `FrameOver.mem_HF_iff_adjacent`; the cluster README's clause and module
  counts corrected and a fourth recorded verdict added; the `app:presheaf-dictionary` row of
  `docs/reference/paper-definitions-of-record.md` extended to cite the new declarations; every
  convention gate green.
- **Non-Goals**:
  - Importing or touching `Presheaf/Directed.lean`, `Presheaf.directedSup`, or any Totality
    declaration. The clause does not consume Totality; routing through `directedSup` would make
    it choice-dependent for no gain.
  - Re-deriving `FrameOver.mem_HF_iff_adjacent` or anything in `Semantics/IntNormalForm.lean`.
    It is cited as the ℤ reading, nothing more.
  - Introducing `Mathlib.CategoryTheory` or a `Category` instance. The limit is presented
    concretely, as `sheaf_clause` presents the sheaf condition concretely.
  - Bundling `[F.IsRegular]` onto `worldsEquiv`. The isomorphism holds at no frame constraint;
    only `lim_nonempty` carries the binder.
  - Widening `file_scope` to the aggregators `FormalSystem/Semantics/Presheaf.lean` and
    `FormalSystem.lean`, or to the READMEs. These are SHARED TOUCHES handled under the
    territory contract, not scope.
  - Reviving `app:Structure` or `app:presheaf-dictionary` in the paper; both are cut and are
    cited as `DANGLING` exactly as the three sibling clause modules cite them.
  - Filling the `<!-- TODO: add description -->` placeholder on the `Sheaf.lean` row of the
    cluster README's inventory block. Pre-existing, not this task's.
  - Settling any route question of the gluing-route seed report (`specs/archive/718_…`); its
    §§1 and 3 are context only.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A `simpa` (or any `*_iff_*` round trip) in the window-bound arithmetic silently imports `Classical.choice`, turning the choice-free clause into a choice-dependent one while the build stays green | H | M | Transcribe the probe's `rwa [neg_add_cancel]` / `rwa [zero_sub]` / `rwa [add_sub_cancel_right]` forms verbatim; Phase 3 measures **every** declaration with `lean_verify` and the phase is not complete while `worldsEquiv` measures anything but `[propext, Quot.sound]` |
| Aggregator import line, root import line, or a README count sentence clobbered by a concurrently dispatched sibling (616 `Duration.lean`, 617 `Reflection.lean` — both on this directory this cycle), invisibly to the collision gate | H | M | Re-read `FormalSystem/Semantics/Presheaf.lean`, `FormalSystem.lean`, and both READMEs immediately before each edit and again before each commit; stage only this task's own hunks with an explicit file list; re-run the guarded build after each aggregator edit; on a foreign commit, foreign uncommitted modification, or a build not started here, check `git log` and STOP and report (`context/contracts/territory.md`, Cross-Task Territory) |
| Duplicate-declaration error from the probe's `ofWorld` | H | — | Already resolved: all maps live in the `Lim` namespace; pinned statements compiled with `Presheaf.Directed` imported and no clash |
| C33 failure from forgetting the **root** `FormalSystem.lean`, or inserting the line out of code-point order | H | M | Named as an explicit Phase 1 task with the insertion rule (sorted by dotted module name; `…Presheaf.Worlds` sorts after `…Presheaf.Site`); `check-module-invariants.sh --no-build` run before the Phase 1 commit |
| INV failure from the cluster README's generated inventory block going stale the moment the file is added | M | H | Regenerate with `bash scripts/check-module-invariants.sh --emit-inventory` in Phase 1 (and again in Phase 4 once the line count settles); never edit the block by hand |
| `restrictTr_central`'s `rfl` proof fails (its proof is carried from the report, not from the saved probe) | M | L | Fallback: `Beh.ext (partialHistory_ext rfl (fun _ _ _ => rfl))`, or unfold `Beh.restrictTr` first; `Tr`'s two `Prop` fields are proof-irrelevant and `twice` is an `abbrev`, so the two sides are definitionally equal |
| Dependent-rewrite failure ("motive is not type correct") in `Lim.ofWorld_toWorld_sec` | M | H | Reproduced in research; use `states_eq_of_eq hL r hr hsec`, never `rw [hL]` |
| `rw [Lim.readAt]` fails for lack of an equation lemma | L | H | State `Lim.readAt_def … := rfl` locally and rewrite with it (unpinned helper, as in the probe) |
| A `[F.IsRegular]` binder on `lim_nonempty` without an honest marker trips C34b, or an under-listed marker trips C34a | M | M | Marker `Constraints consumed: Compositionality, Seriality, Limit, Saturation` — an all-four list claims nothing and is exempt by construction, and it is honest: the tail routes through `occurrence`/Zorn |
| Naming drift between the task (*Possible Worlds*), the recorded paper text (*Total Histories*), and the record | L | H | Docstring title uses *Total Histories* and names the record's *Possible Worlds* in the same sentence; the record row is extended, not renamed |
| A README claim left false after landing ("Four clauses", "six modules", "`Presheaf/Directed.lean` only" imports `Extension/`, the `Semantics/README.md` file count) | M | M | All are explicit Phase 4 tasks with the quoted phrases to grep for before editing |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel. These four are strictly sequential: each
phase's declarations are stated in terms of the previous phase's, and Phase 4's record quotes
Phase 3's measurements.

---

### Phase 1: The site-side arithmetic, the limit type, and the wiring [COMPLETED]

**Goal**: `FormalSystem/Semantics/Presheaf/Worlds.lean` exists with the cluster's established
shape, carries the central restriction and the `Lim` structure with its extensionality and
site-form compatibility, is wired into both aggregators, and `lake build FormalSystem` is green
with no new `sorry` and every structural gate passing.

**Tasks**:
- [x] Create `FormalSystem/Semantics/Presheaf/Worlds.lean`: copyright header (2026, Benjamin
      Brast-McKie, Apache 2.0), module docstring skeleton with `## Main Definitions` /
      `## Main Results` / `## Implementation Notes` / `## References` / `## Tags` (filled in
      Phase 4), `namespace FormalSystem.Semantics.Presheaf`, `variable {F : TaskFrame}`, and the
      closing `assert_not_exists FormalSystem.ProofSystem.Axiom FormalSystem.ProofSystem.DerivationTree`.
- [x] Imports: `FormalSystem.Init`, `FormalSystem.Semantics.Presheaf.Determinism`,
      `FormalSystem.Semantics.Extension.Extension`. Not `Presheaf.Directed`.
- [x] `central_fit`: `x' - x + (x + x) ≤ x' + x'` from `x ≤ x'`, by `abel` then
      `add_le_add (le_refl x') h`. Never `(add_le_add_iff_left _).mpr` — that idiom measures
      `Classical.choice` (recorded in `Directed.lean`'s Implementation Notes).
- [x] `twice` (`abbrev`): the object `2x` of the site, `⟨x.val + x.val, add_nonneg x.property x.property⟩`.
      There is no `OfNat F.Duration 2` on an abstract temporal order, which is why `2x` is
      written `x.val + x.val` throughout.
- [x] `centralTr`: the central morphism `Tr (twice x) (twice x')` with shift `x'.val - x.val`,
      from `sub_nonneg.mpr h` and `central_fit h`.
- [x] `restrictTr_central`: restriction along `centralTr h` **is** the raw-data
      `Beh.restrict (x'.val - x.val) (x.val + x.val) …`. Expected `rfl`, mirroring
      `restrictTr_coverLeft`/`restrictTr_coverRight`; fallback per the risk table.
- [x] `structure Lim (F : TaskFrame)` with `sec : ∀ x : Obj F.Duration, Beh F (x.val + x.val)`
      and the `Prop` field `compat` stating the raw-data central-restriction equation (pinned
      form below). The raw form is what the proofs consume; the site form is derived.
- [x] `Lim.ext`: pointwise equality of `sec` gives equality of limits — `obtain`, `funext`,
      `rfl` (proof irrelevance closes `compat`). No `@[ext]` attribute, so no second
      auto-generated `Lim.ext`.
- [x] `Lim.compat_site`: `Beh.restrictTr (centralTr h) (L.sec x') = L.sec x`, from
      `restrictTr_central` and `L.compat h`. The clause's compatibility in the site's own
      vocabulary, with no transport and no cast.
- [x] `window_lo`, `window_hi`: `0 ≤ s + x` and `s + x ≤ x + x` from `|s| ≤ x`. **`window_lo`
      is written with explicit `rwa [neg_add_cancel]`, never `simpa`** — the `simpa` form was
      measured to pull `Classical.choice`.
- [x] `absObj t := ⟨|t|, abs_nonneg t⟩` and `absObj_val : (absObj t).val = |t| := rfl`.
- [x] Re-read `FormalSystem/Semantics/Presheaf.lean` immediately beforehand, then add
      `import FormalSystem.Semantics.Presheaf.Worlds` (sorted — after `…Presheaf.Site`) and a
      `## Modules` bullet (`Presheaf.Worlds` — the *Total Histories* clause).
- [x] Re-read `FormalSystem.lean` immediately beforehand, then add
      `import FormalSystem.Semantics.Presheaf.Worlds` in code-point order (after
      `import FormalSystem.Semantics.Presheaf.Site`). C33 asserts this file is byte-for-byte
      `lake exe mk_all --lib FormalSystem` output; omitting the line fails C33 **and** leaves
      the module outside C24's root-closure walk.
- [x] `bash scripts/check-module-invariants.sh --emit-inventory` to regenerate the cluster
      README's `<!-- BEGIN GENERATED: inventory … -->` block (the INV check fails as soon as a
      file is added). Add the `Worlds.lean` row's hand-written trailing description.
- [x] Commit per green sub-step with explicit per-file `git add` lists (the module once it
      builds; then each aggregator edit; then the inventory regeneration).

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: interface

**Scope Hypothesis**: this phase asserts **eleven** new declarations (`central_fit`, `twice`,
`centralTr`, `restrictTr_central`, `Lim`, `Lim.ext`, `Lim.compat_site`, `window_lo`,
`window_hi`, `absObj`, `absObj_val`) in exactly **one** new file plus **two** aggregator
one-liners and **one** regenerated inventory block, and that the root insertion point is
immediately after `import FormalSystem.Semantics.Presheaf.Site` (observed at
`FormalSystem.lean:634` at plan time). Confirm at implementation time by counting declarations
against the `## Lean Challenge Statements` identifier set, by `git diff --stat` showing no file
outside the four named, and by re-reading `FormalSystem.lean` around the insertion point
*before* editing — siblings 616 (`…Presheaf.Duration`) and 617 (`…Presheaf.Reflection`) insert
their own lines into the same sorted block, so the line number is a pre-edit observation, not a
guarantee.

**Tier Justification**: the new module's only direct dependents are the two aggregators, so a
guarded `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem`
(the root dependent, which the task constraint requires green at every phase end anyway) plus
`bash scripts/check-module-invariants.sh --no-build` (C33 on the root, INV on the README block)
is the complete covering check; no other module imports `Worlds`.

**Files to modify**:
- `FormalSystem/Semantics/Presheaf/Worlds.lean` - created; header, imports, `central_fit`,
  `twice`, `centralTr`, `restrictTr_central`, `Lim`, `Lim.ext`, `Lim.compat_site`,
  `window_lo`, `window_hi`, `absObj`, `absObj_val`, closing lock
- `FormalSystem/Semantics/Presheaf.lean` - one sorted `import` line, one `## Modules` bullet
  (SHARED TOUCH outside `file_scope` — siblings 616 and 617 need the same block)
- `FormalSystem.lean` - one sorted `import` line (SHARED TOUCH outside `file_scope`; C33-gated
  byte-exact)
- `FormalSystem/Semantics/Presheaf/README.md` - regenerated inventory block only (SHARED TOUCH;
  the prose amendments are Phase 4's)

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem` exits 0
  (foreground `timeout` form with the Bash tool ceiling raised, or detached with the bounded
  waiter of `context/patterns/bounded-build-waiter.md`), re-run after **each** aggregator edit.
- No new `sorry`: `grep -n sorry FormalSystem/Semantics/Presheaf/Worlds.lean` is empty.
- `bash scripts/check-module-invariants.sh --no-build` green, in particular C33 (root
  byte-current), INV (inventory block current), C24's import-line prerequisite, C31/C32 trivially
  (no references yet), C34 (no bracketed binder yet).
- `lean_verify FormalSystem.Semantics.Presheaf.restrictTr_central` and
  `…Presheaf.Lim.compat_site` report no `sorry` and no `Classical.choice`.

---

### Phase 2: The two maps and the keystone [COMPLETED]

**Goal**: the backward map `Lim.toWorld` and the forward map `Lim.ofWorld` exist, the keystone
reading lemma and task-respect are proved, and `lake build FormalSystem` is green with no new
`sorry`.

**Tasks**:
- [x] `Lim.readAt L t`: the state at `t` read out of the canonical window `absObj t` at
      position `t + |t|`, with the domain witness `Beh.mem_dom _ (window_lo (le_refl _)) (window_hi (le_refl _))`.
- [x] If `rw [Lim.readAt]` is needed and fails for lack of an equation lemma, state the
      **unpinned** helper `Lim.readAt_def … := rfl` and rewrite with it, as the probe does.
- [x] `Lim.read_eq` — **the keystone**: for any `x` with `|t| ≤ x.val`,
      `L.readAt t = (L.sec x).val.states (t + x.val) …`. Transcribe the probe: `L.compat` at
      `(absObj t, x)` read at one point through `states_eq_of_eq`, then `Beh.restrict_states`,
      then one `PartialHistory.states_eq_of_time_eq` across
      `x - |t| + (t + |t|) = t + x` (`abel`). `(absObj t).val` is definitionally `|t|`, so the
      pinned `|t| ≤ x.val` hypothesis feeds `compat` directly.
- [x] `Lim.respects`: task-respect for `readAt`, reading both times out of the common window
      `⟨max |s| |t|, _⟩` via two `read_eq`s and the section's own `respects_task`; the time
      difference survives because `(t + m) - (s + m) = t - s` (`abel`).
- [x] `Lim.toWorld L := WorldHistory.ofTotal F L.readAt L.respects`. Totality is structural;
      no extension step, no `thm:extension`.
- [x] `Lim.ofWorld w` (`noncomputable`, because `secOf` is): `sec x := secOf w (-x.val) (x.val + x.val) …`,
      `compat` by `Beh.ext (partialHistory_ext rfl _)`, `Beh.restrict_states`, two
      `secOf_states`, and one `w.state_congr (by abel)`.
- [x] Commit per green sub-step with explicit per-file `git add`.

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: this phase asserts **five** pinned declarations (`Lim.readAt`,
`Lim.read_eq`, `Lim.respects`, `Lim.toWorld`, `Lim.ofWorld`) plus at most one unpinned `rfl`
helper, all in `Worlds.lean` alone. Confirm by counting against the Challenge identifier set
and by `git diff --stat` naming only `Worlds.lean`.

**Tier Justification**: every edit is confined to `Worlds.lean` and adds declarations without
changing any existing signature, so
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.Presheaf.Worlds`
plus `lean_verify` on each new declaration is the complete covering check; the aggregators only
re-export the module and no other module imports it.

**Files to modify**:
- `FormalSystem/Semantics/Presheaf/Worlds.lean` - `Lim.readAt`, (`Lim.readAt_def`),
  `Lim.read_eq`, `Lim.respects`, `Lim.toWorld`, `Lim.ofWorld`

**Verification**:
- Scoped guarded build of `FormalSystem.Semantics.Presheaf.Worlds` green after each
  declaration; `lake build FormalSystem` (guarded) green at phase end, per the task constraint.
- No new `sorry`.
- `lean_verify` on `Lim.read_eq`, `Lim.respects`, `Lim.toWorld`, `Lim.ofWorld` each measures
  `[propext, Quot.sound]` — **no `Classical.choice`**. If `Classical.choice` appears, a
  `simpa`/`*_iff_*` form has crept into `window_lo` or the arithmetic; fix before closing.

---

### Phase 3: The round trips, the clause, and the tail [COMPLETED]

**Goal**: both round trips, `worldsEquiv`, and `lim_nonempty` are proved; every declaration in
the module is measured with `lean_verify`; the isomorphism path measures `[propext, Quot.sound]`
and only `lim_nonempty` measures `Classical.choice`.

**Tasks**:
- [x] `Lim.toWorld_ofWorld`: `WorldHistory.ext_state`, then `secOf_states` and
      `w.state_congr (by abel)` at each `t`. Use `change`, not `show`, when restating the goal.
- [x] `abs_sub_le_of_mem`: `|r - x| ≤ x` on `[0, 2x]`, by `abs_le.mpr` with two
      `sub_le_sub_right` and **explicit `rwa [zero_sub]` / `rwa [add_sub_cancel_right]`, never
      `simpa`** (measured to pull `Classical.choice`).
- [x] `Lim.ofWorld_toWorld_sec`: `Beh.ext (partialHistory_ext _ _)`; the domain half is
      `propext` of the two section conditions; the states half reads through
      `states_eq_of_eq hL r hr hsec` (**never `rw [hL]`**), `secOf_states`, then `Lim.read_eq`
      at `|r + -x.val| ≤ x.val` from `abs_sub_le_of_mem`, closing with
      `PartialHistory.states_eq_of_time_eq … (by abel)`.
- [x] `Lim.ofWorld_toWorld := Lim.ext (Lim.ofWorld_toWorld_sec L)`.
- [x] `worldsEquiv F : WorldHistory F ≃ Lim F` (`noncomputable`): `toFun := Lim.ofWorld`,
      `invFun := Lim.toWorld`, the two round trips. **At no frame constraint** — do not add
      `[F.IsRegular]`.
- [x] `lim_nonempty F [F.IsRegular] (w : F.WorldState) : Nonempty (Lim F)` from
      `PartialHistory.hF_nonempty F w` and `Lim.ofWorld`. Docstring marker
      `Constraints consumed: Compositionality, Seriality, Limit, Saturation`.
- [x] Measure **every** declaration of the module with `lean_verify` (fully qualified names)
      and record the results for Phase 4's table. Expected: all of Phase 1–3 except
      `lim_nonempty` at `[propext, Quot.sound]` (or `[propext]`); `lim_nonempty` at
      `[propext, Classical.choice, Quot.sound]`.
- [x] Commit per green sub-step with explicit per-file `git add`.

**Timing**: 1.5 hours

**Depends on**: 2

**Verification Tier**: local

**Scope Hypothesis**: this phase asserts **six** pinned declarations (`Lim.toWorld_ofWorld`,
`abs_sub_le_of_mem`, `Lim.ofWorld_toWorld_sec`, `Lim.ofWorld_toWorld`, `worldsEquiv`,
`lim_nonempty`) in `Worlds.lean` alone, and that the axiom profile carried from the report
(`worldsEquiv` at `[propext, Quot.sound]`; `lim_nonempty` at
`[propext, Classical.choice, Quot.sound]`) reproduces. Confirm by counting against the Challenge
identifier set and by the `lean_verify` sweep — a row that does not reproduce is a defect in
the transcription, not a measurement to be recorded as-is.

**Tier Justification**: every edit is confined to `Worlds.lean` and changes no existing
signature, so the scoped guarded build
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.Presheaf.Worlds`
plus the per-declaration `lean_verify` sweep is the complete covering check; nothing outside
the aggregators imports the module.

**Files to modify**:
- `FormalSystem/Semantics/Presheaf/Worlds.lean` - `Lim.toWorld_ofWorld`, `abs_sub_le_of_mem`,
  `Lim.ofWorld_toWorld_sec`, `Lim.ofWorld_toWorld`, `worldsEquiv`, `lim_nonempty`

**Verification**:
- Scoped guarded build green; `lake build FormalSystem` (guarded) green at phase end.
- No new `sorry`.
- `lean_verify FormalSystem.Semantics.Presheaf.worldsEquiv` → `[propext, Quot.sound]`. This is
  the result; the phase is not complete while it reads otherwise.
- `lean_verify FormalSystem.Semantics.Presheaf.lim_nonempty` →
  `[propext, Classical.choice, Quot.sound]`.
- `lean_verify` on every other declaration of the module: no `Classical.choice`.
- `lean_verify` on every pinned declaration reports no `sorry`.

---

### Phase 4: The record, the citations, and the gate [COMPLETED]

**Goal**: the module's docstring carries the measured axiom table and the Implementation Notes
that protect it, the References block resolves, the cluster and parent READMEs and the
definitions-of-record row are true after landing, and the complete gate set is green.

**Tasks**:
- [x] Module docstring: title the clause *Total Histories* and name the record's *Possible
      Worlds* in the same sentence; state the clause verbatim as recorded
      (`H_F ≅ lim_{x ∈ D⁺} Beh(F)(2x)` along `Tr (x' − x) : 2x → 2x'`, and nonempty) and that
      the statement was read from the sentinel commit `docs/reference/paper-definitions-of-record.md`
      pins, since the live paper no longer defines the label. `## Main Definitions`
      (`twice`, `centralTr`, `Lim`, `absObj`, `Lim.readAt`, `Lim.toWorld`, `Lim.ofWorld`) and
      `## Main Results` (`restrictTr_central`, `Lim.compat_site`, `Lim.read_eq`,
      `Lim.respects`, both round trips, `worldsEquiv`, `lim_nonempty`).
- [x] Docstring: **the measured axiom table**, two columns (`Declaration` | `Measured axioms`)
      as `Directed.lean` renders it, every row from Phase 3's `lean_verify` sweep, not a sample;
      the reading that the isomorphism is choice-free and only the tail reaches Zorn, through
      `PartialHistory.hF_nonempty`, where the paper also puts it (`cor:occurrence`); and the
      note that this clause joins *Germs*, *Sheaf* and the ray layer on the choice-free side of
      the cluster's recorded split while its tail joins *Totality* and *Directed Gluing*.
- [x] Docstring `## Implementation Notes`: (i) the two `simpa` prohibitions in `window_lo` and
      `abs_sub_le_of_mem` with their `rwa` replacements, measured both ways; (ii) why the
      backward map reads the canonical window `|t|` rather than routing through
      `Presheaf.directedSup`, which is independently non-constructive; (iii) why Totality is
      not consumed — the centred chain already covers the order, so `WorldHistory.ofTotal`
      supplies totality structurally; (iv) the `states_eq_of_eq`-not-`rw` and `readAt_def`
      devices; (v) the ℤ reading: `FrameOver.mem_HF_iff_adjacent`
      (`FormalSystem/Semantics/IntNormalForm.lean`) is the same identification of `H_F`
      specialised to discrete time, a consequence of this clause's shape rather than an input,
      cited and not re-derived.
- [x] `## References` in the normal form of `docs/development/REFERENCE_NORMAL_FORM.md`:
      `[schultz2020]` (§3.2 Def. 3.2.1 and §3.1 Defs. 3.1.1–3.1.5) resolving in the root
      `references.bib`; `app:presheaf-dictionary`, `def:interval-site`, `def:behavior-presheaf`,
      `app:Structure` each marked **`DANGLING`** with the cut stated at the site, copying the
      sibling modules' form; `cor:occurrence` cited plainly; module cross-references to
      `Behavior.lean`, `Site.lean`, `Sheaf.lean`, `Determinism.lean`, `PartialHistory.lean`,
      `Extension/Extension.lean`, `IntNormalForm.lean`. `## Tags` line.
- [x] `FormalSystem/Semantics/Presheaf/README.md` (re-read immediately before editing; grep each
      quoted phrase first — a sibling may already have amended it): "Four of the six modules
      are built on …" and "all six modules close with `assert_not_exists`" → the actual module
      count after this and any landed sibling; "Four clauses of the presheaf dictionary are
      discharged here" → five, adding a sentence on *Total Histories*; the Dependencies
      section's "`Presheaf/Directed.lean` only" imports `Extension/` → `Directed.lean` and
      `Worlds.lean`; extend `## Key Definitions` and `## Key Results`; add a fourth
      `## Recorded verdicts` subsection "The *Total Histories* clause is choice-free; only its
      nonemptiness tail is not", with the table; re-run
      `bash scripts/check-module-invariants.sh --emit-inventory` once the module's line count
      has settled, and fill the `Worlds.lean` row's trailing description.
- [x] `FormalSystem/Semantics/README.md`: minimally extend the hand-written `Presheaf/` row
      (observed at line 68 at plan time: lists `Site`, `Behavior`, `Sheaf`, `Ray`, `Directed`
      "(5 files)" — already stale by `Determinism`): add `Worlds`, correct the file count to the
      actual number, one sentence on the clause. Minimal addition only (SHARED TOUCH).
- [x] `docs/reference/paper-definitions-of-record.md`: extend the `app:presheaf-dictionary`
      `DANGLING` row's description (observed at line 2498) with one sentence citing
      `worldsEquiv`, `Lim.compat_site`/`centralTr`, and `lim_nonempty`
      (`FormalSystem/Semantics/Presheaf/Worlds.lean`), naming *Total Histories* as the recorded
      text's name for the record's *Possible Worlds* clause and the choice split. The row is
      `DANGLING`, carries no hash, and stays unpinned; no pipe characters inside the description.
- [x] Run the complete gate set (Verification below); fix forward on any finding. *(deviation: altered — the agent-system gates `verify-deploy.sh`/`run-all.sh` were deferred to the batch stage per the dispatch's Batch Gate Deferral directive (no touched file is under `.claude/`); every repository gate — full guarded `lake build`, `check-module-invariants.sh` with build, `check-task-references.sh`, `typst-sync-check.sh` — ran in this dispatch and is green; `lean-challenge-snapshot.sh --check` could not run because no Challenge manifest was snapshotted at plan time (advisory))*
- [x] Commit per green sub-step with explicit per-file `git add`; final commit
      `task 566: complete implementation` per `rules/git-workflow.md`. *(deviation: altered — the summary rides in the phase 4 commit per the phase-closure contract's single-commit-per-phase ruling; the `task 566: complete implementation` commit is the orchestrator postflight's)*

**Timing**: 2 hours

**Depends on**: 3

**Verification Tier**: full

**Scope Hypothesis**: this phase asserts **three** now-stale README sentences at the quoted
locations in `Presheaf/README.md` (lines 9, 14, 17 at plan time), **one** stale row in
`Semantics/README.md` (line 68), **one** record row (line 2498), and **zero** new Lean
declarations. Confirm by grepping each quoted phrase *before* editing (siblings 616/617 edit the
same sentences this cycle, so an already-amended sentence makes this edit a count correction,
not a second amendment) and by `lean_verify`'s identifier count matching the 22 pinned names.

**Files to modify**:
- `FormalSystem/Semantics/Presheaf/Worlds.lean` - docstring record, Implementation Notes,
  References, Tags, `Constraints consumed:` marker
- `FormalSystem/Semantics/Presheaf/README.md` - count amendments, Key Definitions/Results,
  fourth recorded verdict, regenerated inventory block (SHARED TOUCH)
- `FormalSystem/Semantics/README.md` - minimal extension of the `Presheaf/` row (SHARED TOUCH)
- `docs/reference/paper-definitions-of-record.md` - one-sentence extension of the
  `app:presheaf-dictionary` row's description

**Verification** (the complete gate set for this repository, every item observed green in this
dispatch):
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` — the **full**
  project build (final verification), exit 0.
- No new `sorry` anywhere: `grep -rn sorry FormalSystem/Semantics/Presheaf/Worlds.lean` empty.
- `bash scripts/check-module-invariants.sh` (full, with build) green: C8, C15, C24, C26, C28
  (a new file adds zero warnings — no `scripts/warning-budget.txt` row), C31 (every bibkey
  resolves), C32 (every relative link resolves), C33 (root byte-current), C34a/b (the
  `lim_nonempty` marker), INV (inventory block current).
- `bash .claude/scripts/check-task-references.sh` clean: no "task N" citation in any
  deliverable outside `specs/**`; the docstring cites files and declarations, never task numbers.
- `bash .claude/scripts/verify-deploy.sh` exit 0 (the agent-system gate aggregator; it governs
  the `.claude/` tree, not the Lean sources, and runs for completeness of the declared `full`
  tier).
- `bash .claude/scripts/lean-challenge-snapshot.sh --check` reports no signature drift against
  the `## Lean Challenge Statements` section (advisory — a finding is investigated, never
  silently reconciled in either direction).
- `lean_verify` reproducing **every** row of the docstring table, not a sample. A row that does
  not reproduce means the table is wrong and the phase is not complete.

---

## Lean Challenge Statements

Every signature below was compiled standalone against the live tree at plan time
(`lean_run_code`: 22 declarations, 20 `sorry` warnings, zero errors — the two `abbrev`/
`structure` declarations carry no `sorry`), and compiled again with
`import FormalSystem.Semantics.Presheaf.Directed` added, to confirm that no identifier collides
with anything in the cluster namespace (`Presheaf.ofWorld` is the one the probe would have
collided with). The `Directed` import is a plan-time collision check only and is **not** part
of the module's import list.

```lean
import FormalSystem.Init
import FormalSystem.Semantics.Presheaf.Determinism
import FormalSystem.Semantics.Extension.Extension

namespace FormalSystem.Semantics.Presheaf

variable {F : TaskFrame}

theorem central_fit {x x' : F.Duration} (h : x ≤ x') : x' - x + (x + x) ≤ x' + x' := sorry

abbrev twice (x : Obj F.Duration) : Obj F.Duration :=
  ⟨x.val + x.val, add_nonneg x.property x.property⟩

def centralTr {x x' : Obj F.Duration} (h : x.val ≤ x'.val) : Tr (twice x) (twice x') := sorry

theorem restrictTr_central {x x' : Obj F.Duration} (h : x.val ≤ x'.val)
    (σ : Beh F (x'.val + x'.val)) :
    Beh.restrictTr (centralTr h) σ
      = Beh.restrict (x'.val - x.val) (x.val + x.val) (sub_nonneg.mpr h)
          (add_nonneg x.property x.property) (central_fit h) σ := sorry

structure Lim (F : TaskFrame) where
  sec : ∀ x : Obj F.Duration, Beh F (x.val + x.val)
  compat : ∀ {x x' : Obj F.Duration} (h : x.val ≤ x'.val),
    Beh.restrict (x'.val - x.val) (x.val + x.val) (sub_nonneg.mpr h)
      (add_nonneg x.property x.property) (central_fit h) (sec x') = sec x

theorem Lim.ext {L L' : Lim F} (h : ∀ x, L.sec x = L'.sec x) : L = L' := sorry

theorem Lim.compat_site (L : Lim F) {x x' : Obj F.Duration} (h : x.val ≤ x'.val) :
    Beh.restrictTr (centralTr h) (L.sec x') = L.sec x := sorry

theorem window_lo {s x : F.Duration} (h : |s| ≤ x) : 0 ≤ s + x := sorry

theorem window_hi {s x : F.Duration} (h : |s| ≤ x) : s + x ≤ x + x := sorry

def absObj (t : F.Duration) : Obj F.Duration := sorry

theorem absObj_val (t : F.Duration) : (absObj t).val = |t| := sorry

def Lim.readAt (L : Lim F) (t : F.Duration) : F.WorldState := sorry

theorem Lim.read_eq (L : Lim F) (t : F.Duration) (x : Obj F.Duration) (hx : |t| ≤ x.val) :
    L.readAt t = (L.sec x).val.states (t + x.val) (Beh.mem_dom _ (window_lo hx) (window_hi hx)) :=
  sorry

theorem Lim.respects (L : Lim F) (s t : F.Duration) :
    F.TaskRel (L.readAt s) (t - s) (L.readAt t) := sorry

def Lim.toWorld (L : Lim F) : WorldHistory F := sorry

noncomputable def Lim.ofWorld (w : WorldHistory F) : Lim F := sorry

theorem Lim.toWorld_ofWorld (w : WorldHistory F) : (Lim.ofWorld w).toWorld = w := sorry

theorem abs_sub_le_of_mem (r x : F.Duration) (h0 : 0 ≤ r) (h1 : r ≤ x + x) : |r - x| ≤ x := sorry

theorem Lim.ofWorld_toWorld_sec (L : Lim F) (x : Obj F.Duration) :
    (Lim.ofWorld L.toWorld).sec x = L.sec x := sorry

theorem Lim.ofWorld_toWorld (L : Lim F) : Lim.ofWorld L.toWorld = L := sorry

noncomputable def worldsEquiv (F : TaskFrame) : WorldHistory F ≃ Lim F := sorry

theorem lim_nonempty (F : TaskFrame) [F.IsRegular] (w : F.WorldState) : Nonempty (Lim F) := sorry

end FormalSystem.Semantics.Presheaf
```

**Statement fidelity notes** (per `rules/plan-compliance.md`'s Statement Fidelity section):
`worldsEquiv` is pinned at **no** frame constraint — bundling `[F.IsRegular]` onto it because
the tail needs it would claim strictly less than the recorded clause. `lim_nonempty` is pinned
at `[F.IsRegular]` with an explicit `w : F.WorldState`, mirroring `PartialHistory.hF_nonempty`'s
own deliberate explicit argument. `Lim.read_eq`'s hypothesis is `|t| ≤ x.val`, not
`(absObj t).val ≤ x.val`; the two are definitionally equal in the real module (see Research
Integration, correction 2). `Lim.readAt_def` is deliberately **absent** from this set: it is an
unpinned `rfl` rewriting device, not a result.

## Testing & Validation

- [ ] `lake build FormalSystem` (guarded) green at the end of every phase; full project build
      green at the end of Phase 4.
- [ ] Zero `sorry` in `Worlds.lean` at every phase boundary; no vacuous definition
      (`rules/lean4.md`).
- [ ] `lean_verify` on all 22 pinned declarations: no `sorry`; `worldsEquiv` and every
      declaration on the isomorphism path at `[propext, Quot.sound]` (or `[propext]`);
      `lim_nonempty` at `[propext, Classical.choice, Quot.sound]`.
- [ ] `bash scripts/check-module-invariants.sh` green (C8, C15, C24, C26, C28, C31, C32, C33,
      C34a/b, INV).
- [ ] `bash .claude/scripts/check-task-references.sh` clean.
- [ ] `bash .claude/scripts/lean-challenge-snapshot.sh --check`: no drift against the pinned
      signatures (advisory).
- [ ] Every README sentence this plan names as stale is grepped before and after editing and
      reads true after landing.

## Artifacts & Outputs

- `FormalSystem/Semantics/Presheaf/Worlds.lean` — the *Total Histories* clause module (new)
- `FormalSystem/Semantics/Presheaf.lean` — one import line, one `## Modules` bullet
- `FormalSystem.lean` — one import line (regenerated root)
- `FormalSystem/Semantics/Presheaf/README.md` — count amendments, Key Definitions/Results, fourth
  recorded verdict, regenerated inventory block
- `FormalSystem/Semantics/README.md` — extended `Presheaf/` row
- `docs/reference/paper-definitions-of-record.md` — extended `app:presheaf-dictionary` row
- `specs/566_possible_worlds_clause_hf_as_limit/summaries/01_total-histories-limit-clause-summary.md`
  — the implementation summary, written by the implementation round

## Rollback/Contingency

Every phase commits only green sub-steps with explicit per-file `git add` lists, so the tree is
never left with a half-applied phase. If a phase cannot close as written, mark it `[BLOCKED]`
with what was tried and the goal state reached, and escalate rather than substitute a different
decomposition or a weaker statement (`rules/plan-compliance.md`); never write a vacuous
placeholder. An ordinary defensive checkpoint before risky work uses
`bash .claude/scripts/git-snapshot.sh 566 --no-revert`; the reverting default form is reserved
for a genuine rollback and must **never** be run on this shared tree while siblings 616/617 are
dispatched (`context/contracts/territory.md`). To revert the module entirely: remove
`Worlds.lean`, remove its two import lines, regenerate the root with
`lake exe mk_all --lib FormalSystem`, re-run `check-module-invariants.sh --emit-inventory`, and
restore the three prose edits from `git diff` — each is a single-hunk change.
