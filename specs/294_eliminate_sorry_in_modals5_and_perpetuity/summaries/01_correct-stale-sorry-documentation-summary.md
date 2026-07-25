# Implementation Summary: Task #294

- **Task**: 294 - Correct stale sorry/incompleteness documentation in ModalS5.lean and
  Perpetuity/Principles.lean
- **Plan**: `specs/294_eliminate_sorry_in_modals5_and_perpetuity/plans/01_correct-stale-sorry-documentation.md`
- **Status**: Both phases [COMPLETED]
- **Session**: sess_1784999032_8d6f8f_294
- **Type**: lean4 (documentation-only — no proof work)

## Outcome

Six stale documentation claims across three files were corrected. All are comment/docstring
text; no tactic, proof term, declaration signature, or `simp only` argument was modified
anywhere. `lake build` passes on the full project (1877 jobs) with zero errors and zero
`declaration uses 'sorry'` warnings.

The task's original title ("eliminate sorry in ModalS5 and Perpetuity") rested on a premise that
research had already disproved: there were no sorries to eliminate. The residual work was making
the documentation tell the truth.

## Zero-Sorry Evidence (re-confirmed before editing)

Three independent confirmations, all re-run at Phase 1 start rather than taken on the plan's word:

1. **Scoped build**: `lake build Bimodal.Theorems.ModalS5 Bimodal.Theorems.Perpetuity.Principles`
   → success, 696 jobs, **0** `declaration uses 'sorry'` warnings. 21 pre-existing
   `unusedSimpArgs` warnings (untouched — see Territory below).
2. **Baseline grep**: `grep -n sorry` on both target files returned exactly the 4 hits the plan
   predicted (`ModalS5.lean:485`, `Principles.lean:103`, `:686`, `:889`) — all four comment prose,
   none a `sorry` term.
3. **Axiom audits** via `lean_verify` on every declaration whose status was being rewritten — no
   `sorryAx` in any of them (individual results recorded per line below).

Additionally: `grep -rnE "^axiom [A-Za-z]" Theories/` returns **0** — the repo declares no
axioms, so no "AXIOMATIZED" claim can be true. Full-project build closure is sorry-free; the
`sorry` occurrences that do exist repo-wide are confined to `Theories/Bimodal/Boneyard/`, which
is not reachable from the root module and is not built.

## Corrections Applied

### Phase 1 — `Theories/Bimodal/Theorems/ModalS5.lean` (section block at :481-486)

**Before**:
```
## Biconditional Theorems (Infrastructure Pending)

The following theorems require biconditional introduction/elimination infrastructure
which needs deduction theorem support. Marked as sorry pending Phase 3.
```

**After**:
```
## Biconditional Theorems

The biconditional connective `iff` is defined below, together with the S5 biconditional
theorems built on it. All carry complete derivations: `box_conj_iff`, `diamond_disj_iff`,
`s5_diamond_box`, and `s5_diamond_box_to_truth`. They are proved from `box_iff_intro`
(above) plus the `box_mono`, `imp_trans`, `pairing`, and `box_conj_intro` infrastructure
already available — no deduction theorem support is required.
```

**Evidence**: all four biconditionals present at the cited lines and audit clean —
`box_conj_iff` (:502) and `diamond_disj_iff` (:609) → `[propext, Classical.choice, Quot.sound]`;
`s5_diamond_box` (:793) and `s5_diamond_box_to_truth` (:853) → `[propext]`. The named
infrastructure was verified by grepping the section (:491-863) rather than asserted: it uses
`box_iff_intro` (defined :366), `box_mono` (×7), `imp_trans` (×7), `pairing` (×6),
`box_conj_intro` (×4), and **no** deduction-theorem call.

### Phase 1 — `Theories/Bimodal/Theorems/Perpetuity/Principles.lean` (`contraposition` docstring)

Three changes inside the one doc block:

**(a) Line 89 — inaccurate axiom attribution.**

- Before: `Derived using double negation elimination (DNE) axiom.`
- After: `Derived from the `prop_k` and `prop_s` propositional axioms.`
- Evidence: the proof body (:109-220) uses only `Axiom.prop_k` (×2, at :169 and :203) and
  `Axiom.prop_s` (×2, at :174 and :214). Grep for `dne`/`double_neg` across the body returns
  nothing. This correction was **not** in the plan's task list — see Plan Deviations.

**(b) Lines 98-104 — the incompleteness claim (the plan's named target).**

- Before:
  ```
  This requires propositional reasoning patterns that are complex to encode in
  the current TM proof system. The key challenge is handling the nested implications
  and bottom (⊥) correctly.

  **Note**: This proof uses DNE axiom added in Phase 3. The full derivation requires
  careful manipulation of negations and implications, which is left as sorry for the
  MVP. The semantic justification remains sound.
  ```
- After:
  ```
  Steps 2-4 give the informal justification. Since TM is a Hilbert system with no
  assumption discharge available here, the derivation below realises the same implication
  combinator-style: it builds the commuted B-combinator
  `(B → ⊥) → (A → B) → (A → ⊥)` from `prop_s` and `prop_k`, then finishes with two
  modus ponens steps.

  **Implementation Status**: FULLY DERIVED — complete Hilbert-style derivation, audits to
  `[propext]` only.
  ```
- Evidence: `contraposition` (:109, now :110) audits to `[propext]` only. The proof ends in
  `exact DerivationTree.modus_ponens ...` at :220 — a complete derivation.
- The numbered proof-strategy steps (:91-96) and the **Usage** line were kept verbatim per plan.

**(c) Proof-body comment (originally :115-119) — residual future-tense framing.**

- Before: `-- The full proof requires:` … `-- 3. By B combinator (composition): (B → ⊥) → (A → B) → (A → ⊥)`
- After: `-- Proof outline:` … `-- 3. Via the commuted B-combinator form (B → ⊥) → (A → B) → (A → ⊥),` / `--    derived below from the prop_s and prop_k axioms`
- Evidence: the derivation does not route through the `bc`/`b_combinator` binding; it builds
  `comm_bc` independently via `imp_trans s_b s_inst` (:179-180) from `prop_s`/`prop_k`. No tactic
  was touched — the now-unused `bc` binding at :122 was deliberately left in place because
  removing it would be a proof-body edit.

### Phase 2 — `Theories/Bimodal/Theorems.lean` (`## Status` block, declared scope extension)

Four lines corrected; each verified stale before editing.

| Line | Before | After | Evidence |
|------|--------|-------|----------|
| 31 | `Modal S5 Phase 2: PARTIAL (4/6 proven, biconditionals pending)` | `Modal S5 Phase 2: COMPLETE (11 derivations + `iff` connective, zero sorry)` | 12 declarations present: 11 derivations (type contains `⊢`) + the `iff` connective (`: Formula`). Neither "4" nor "6" matched anything in the file. All audit clean; scoped build emits no sorry warning. |
| 32 | `Modal S4 Phase 4: NOT STARTED (0/4 theorems)` | `Modal S4 Phase 4: COMPLETE (4/4 theorems, zero sorry)` | All 4 declarations present at `ModalS4.lean:64, 156, 179, 310`. `lake build Bimodal.Theorems.ModalS4` → success (697 jobs), no sorry warning. Audits: `s4_diamond_box_conj` → `[propext, Classical.choice, Quot.sound]`, `s4_box_diamond_box` → `[propext]`, `s4_diamond_box_diamond` → `[propext]`, `s5_diamond_conj_diamond` → `[propext, Classical.choice, Quot.sound]`. |
| 39 | `P5: `◇▽φ → △◇φ` - THEOREM (using modal_5, 1 technical sorry)` | `P5: `◇▽φ → △◇φ` - PROVEN (zero sorry)` | `perpetuity_5` (`Principles.lean:904`) → `[propext, Classical.choice, Quot.sound]`, no `sorryAx`. `Bridge.lean:980` independently states "P5: ✓ FULLY PROVEN (zero sorry, via P4 + persistence)". |
| 40 | `P6: `▽□φ → □△φ` - AXIOMATIZED (semantic justification)` | `P6: `▽□φ → □△φ` - PROVEN (zero sorry)` | `perpetuity_6` (`Bridge.lean:894`) is a `def ... := by` with a real derivation, → `[propext, Classical.choice, Quot.sound]`. Not an `axiom` (repo declares none). `Bridge.lean:981` states "P6: ✓ FULLY PROVEN (zero sorry, via P5(¬φ) + bridge lemmas + double_contrapose)". |

**Line 32 note**: the plan flagged this as needing verification and said to leave it alone if
inconclusive. Verification was **conclusive** (declarations present, module builds, all four
audit clean with no `sorryAx`), so the line was corrected.

The edit is a single diff hunk spanning lines 28-40, entirely inside the `## Status` block. The
import list, `## Submodules`, `## Usage`, and `## References` sections were not touched.

## Verified Accurate and Left Unchanged

- `Principles.lean:686` → now `:688` (+2 line shift): "**Implementation Status**: FULLY DERIVED
  (zero sorry) using complete deduction theorem". Read and confirmed accurate; left
  byte-identical.
- `Principles.lean:889` → now `:891`: "**Implementation Status**: FULLY PROVEN (zero sorry)".
  Read and confirmed accurate; left byte-identical.
- `Theorems.lean` lines 27, 28, 35-38 (Combinators, Propositional Phase 1, P1-P4): already read
  COMPLETE/PROVEN (zero sorry); consistent with the clean build. Left byte-identical per plan.
- `Theories/Bimodal/Theorems/Perpetuity/README.md`: grepped for
  `sorry|PARTIAL|pending|AXIOMATIZED|NOT STARTED` — **no** stale claims found. No edit needed.
- `Bridge.lean:975-983`: its P1-P6 status block already reads "FULLY PROVEN (zero sorry)" for all
  six and "ALL 6 PERPETUITY PRINCIPLES FULLY PROVEN (100% completion)". Accurate, and it is
  linter-task territory — not touched.

## Stale Documentation Found Elsewhere but Deliberately NOT Touched

Reported rather than acted on, per the plan's Non-Goals:

1. **`Theories/Bimodal/Theorems/ModalS5.lean:54-62`** — the `classical_merge` docstring states
   "**Status**: Complex deduction theorem dependency. Marked as infrastructure gap", lists three
   options "This requires", and offers a "**Workaround**". `classical_merge` (:64) is in fact
   fully proven in one line: `exact Propositional.classical_merge P Q`. This is the same class of
   staleness this task fixed, but it sits **outside** the plan's declared ModalS5 edit range
   (:481-486, "plus optional wording touch-ups strictly inside that doc block"), so it was left
   unchanged. **Recommend a follow-up task** — it is the strongest remaining candidate.
2. **`Theories/Bimodal/docs/user-guide/architecture.md:229-236`** — illustrative code blocks
   present `perpetuity_4`, `perpetuity_5`, and `perpetuity_6` as `theorem ... := by sorry`, which
   misrepresents all three as unproven. Explicitly out of scope (`docs/` listed in Non-Goals).
3. **`CLAUDE.md` Lean/Mathlib version line** — the research report noted a mismatch incidentally.
   Explicitly excluded by the plan.

## Territory / Exclusions Honored

- **No `unusedSimpArgs` fix anywhere.** All 21 pre-existing warnings remain, including the 5 in
  `Principles.lean` and the 3 in `Bridge.lean` that the research report flagged. These belong to
  the concurrent linter-compliance task that owns `Theories/Bimodal/Theorems/`.
- **`Bridge.lean` not touched at all** — `git diff --stat` shows exactly 3 files under
  `Theories/`, and `Bridge.lean` is absent. Its P5/P6 text was used as corroborating evidence
  only.
- **No proof code touched.** `git diff` across all three files is entirely inside `/-! -/`,
  `/-- -/`, and `--` comment blocks.

## Verification Results

| Check | Result |
|-------|--------|
| `lake build Bimodal.Theorems.ModalS5 Bimodal.Theorems.Perpetuity.Principles` | Success, 696 jobs, 0 sorry warnings |
| `lake build Bimodal.Theorems.ModalS4` | Success, 697 jobs, 0 sorry warnings |
| `lake build` (full project) | **Success, 1877 jobs, 0 errors, 0 sorry warnings** |
| Warning set vs baseline | Unchanged. Only delta: the 5 `Principles.lean` `unusedSimpArgs` warnings shifted +2 lines (400/667/744/810/846 → 402/669/746/812/848), matching the net docstring delta exactly. `ModalS5.lean` and `Theorems.lean` emit no warnings. |
| `sorry` usage in the 3 modified files | 0 (all `sorry` text is "zero sorry" prose) |
| Vacuous definitions in the 3 modified files | 0 |
| Real axiom declarations repo-wide | 0 (unchanged) |
| `git diff --stat` under `Theories/` | Exactly 3 files, comment-only, 21 insertions / 16 deletions |
| Plan compliance spot-check | Passed (`contraposition` found in `Theories/`) |

## Plan Deviations

- **Phase 1, task 4 — altered.** The plan's task named the `Principles.lean:98-104` block. In
  addition to that block, line 89 of the same docstring was corrected: it claimed `contraposition`
  was "Derived using double negation elimination (DNE) axiom", but the proof body uses only
  `Axiom.prop_k` (×2) and `Axiom.prop_s` (×2), with no DNE reference anywhere in lines 109-220.
  Leaving it would have meant knowingly shipping a false claim inside the very doc block being
  corrected for false claims, against the plan's own definition of done ("every remaining claim in
  the touched files is factually true"). This is additive accuracy work inside the block already
  being rewritten — no planned step was skipped, substituted, or deferred, and no proof code was
  involved.
- No other deviations. The proof-outline comment adjustment (Phase 1 task 5) and the `Theorems.lean:32`
  correction (Phase 2) were both explicitly authorized by the plan, conditional on verification
  that was performed and passed.

## Commits

- `60de27dce` — task 294 phase 1: correct stale sorry/incompleteness claims in ModalS5 and Principles
- (phase 2 commit follows this summary)
