# Research Report: Task #723

**Task**: 723 - Pin witness family decidability rows c14 baseline
**Started**: 2026-10-04T00:00:00Z
**Completed**: 2026-10-04T00:00:00Z
**Effort**: Small (mechanical, two-heredoc edit + one verification run)
**Dependencies**: Task 706 (file_scope collision on `scripts/check-module-invariants.sh`; schedule in a different cycle)
**Sources/Inputs**:
- `docs/theorem-index.md`
- `scripts/check-module-invariants.sh` (C14 check + C23 shadowing allowlist + C21/C36 consumers)
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Family.lean`
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Assembly.lean`
- `specs/TODO.md` (task 724, dependency check)
- Direct `lake env lean` / `#print axioms` probe (this session)
**Artifacts**:
- `specs/723_pin_witness_family_decidability_rows_c14_baseline/reports/01_c14-witness-family-pin.md` (this report)
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- The defect is CONFIRMED, not a false alarm: `grep -nE 'Compression\.|decidableValidZTime|validZTime_iff_noCertifiedCandidate|exists_witnessFamily_of_not_validZTime' scripts/check-module-invariants.sh` hits only the C23 outer-shadows-inner `SHADOW_PAIR_ALLOW` entry for `decidableValidZTime` (lines ~3467-3470) — never a C14 `#print axioms` line or baseline entry. The three `docs/theorem-index.md` rows at lines 151-153 carry `pcq pinned:C14` cells that assert a check which does not run.
- The **baseline route is the correct fix**, not the row-correction alternative: a direct `lake env lean` probe of all three declarations (this session, against the live tree) returns exactly `[propext, Classical.choice, Quot.sound]` for each — the `pcq` value the rows already claim. There is no scoping reason to exclude this module from C14; the check simply never had these three names added to it.
- The fourth, related declaration (`Decidable (Derivable FrameClass.ZTime [] φ)`, filed as task 724, `Dependencies: Task 723`) has **not landed**: `grep -rn --include='*.lean' 'Decidable (Derivable' FormalSystem/` returns zero hits. Per the dispatch's fold-in instruction, this task should leave a comment naming the pending declaration rather than attempt to pin a fourth entry now.
- Recommended fix: append three lines to each of the `C14_BASELINE` and `C14LEAN` heredocs in `scripts/check-module-invariants.sh` (same order in both, since C14 does exact string-equality comparison), immediately after the existing `FormalSystem.Metalogic.Independence.z1_validIn_iff_ztime` line that currently closes each heredoc. No Lean source changes needed; no existing baseline entry is touched.

## Context & Scope

Task 723 exists to resolve a documentation/verification mismatch: `docs/theorem-index.md`'s legend (line 18) defines `pinned:C14` as "names the check in `scripts/check-module-invariants.sh` that asserts the value on every build." Three rows (151-153) carry this cell for the witness-family decidability route, but the review that filed this task observed the check never mentions these three names outside an unrelated allowlist. The dispatch requires: (1) re-verify the grep before touching anything, (2) if confirmed, add the three names to the C14 baseline pair following the existing entries' exact shape, (3) confirm `check-module-invariants.sh` still passes, (4) if the baseline route turns out wrong, correct the rows instead, (5) fold in the related pending declaration from task 724 if landed, else leave a pointing comment. Hard constraints: no Lean source changes, no weakening of existing baseline entries, no new `pinned:` cell for an unverified pin.

This is a research-phase dispatch; the actual file edits belong to the implementation phase. This report establishes and documents the ground truth needed to execute that edit with no further investigation required.

## Findings

### Codebase Patterns

**The three affected `docs/theorem-index.md` rows** (lines 151-153):

```
151: | — | Every ℤ-time countermodel compresses to a bounded, canonically guessed witness family that certifies the refutation | `FormalSystem.Metalogic.Decidability.exists_witnessFamily_of_not_validZTime` | `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Family.lean` | ZTime | pcq pinned:C14 |
152: | — | `φ` is ℤ-valid iff no enumerated candidate family certifies a refutation in the bounded window | `FormalSystem.Metalogic.Decidability.validZTime_iff_noCertifiedCandidate` | `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Assembly.lean` | ZTime | pcq pinned:C14 |
153: | — | Decidability of ℤ-time validity, via the witness-family certificate route | `FormalSystem.Metalogic.Decidability.Compression.decidableValidZTime` | `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Assembly.lean` | ZTime | pcq pinned:C14 |
```

**Re-verification grep** (exact command from the dispatch, re-run this session):

```
$ grep -nE 'Compression\.|decidableValidZTime|validZTime_iff_noCertifiedCandidate|exists_witnessFamily_of_not_validZTime' scripts/check-module-invariants.sh
3465:    # decidableValidZTime: the shadowing IS the sub-namespacing deliberately chosen to avoid a
3469:    ("decidableValidZTime", "FormalSystem.Metalogic.Decidability",
3470:     "FormalSystem.Metalogic.Decidability.Compression"),
```

This is the C23 `SHADOW_PAIR_ALLOW` entry explaining why `Compression.decidableValidZTime` is permitted to shadow the outer `BiLasso/Assembly.lean` `decidableValidZTime` — an entirely different check (C23, name-collision hygiene) from C14 (axiom-baseline pinning). **No C14 baseline line and no `#print axioms` directive exists for any of the three names.** The defect is confirmed exactly as described; this is not a false alarm.

**The C14 mechanism** (`scripts/check-module-invariants.sh` lines ~2009-2464): two heredocs compared by exact string equality —
- `C14_BASELINE` (`<<'C14BASE'`, opens line 2044, closes line 2243): one line per pinned declaration, format `'<fully.qualified.Name>' depends on axioms: [axiom, list]`.
- `C14LEAN` (`<<'C14LEAN'`, opens line 2246, closes line 2447): one `#print axioms <fully.qualified.Name>` directive per line, **same order** as `C14_BASELINE` (the script's own comment at line 2009-2010 states this requirement explicitly: "they must list the same declarations in the same order. Edit them together, appending to both.").

At `RUN_BUILD=1` (the default; `--no-build` skips this half), the script runs `lake env lean` on the `C14LEAN` source, pipes the output through a line-unwrapping `sed` filter (`sed -e ':a' -e '$!N' -e 's/\n / /' -e 'ta' -e 'P' -e 'D'`) that rejoins Lean's pretty-printer line wrapping into one line per declaration, filters to `grep 'depends on axioms'`, and compares the result to `$C14_BASELINE` by exact string equality (line 2452: `if [ "$C14_OUT" = "$C14_BASELINE" ]`). A mismatch is a **hard failure** (line 2456-2457: `fail C14 "axiom sets diverged from baseline -- this is a HARD STOP, not a new baseline"`), not an auto-update — so appending to only one heredoc, or appending in a different relative order between the two, breaks C14 rather than silently passing.

**Current baseline already includes a Decidability-namespace precedent**: the very first line of `C14_BASELINE` is `'FormalSystem.Metalogic.Decidability.sound_of_isValid' depends on axioms: [propext, Classical.choice, Quot.sound]` — confirming this namespace is already inside C14's intended scope, which rules out "the check is deliberately scoped to exclude this module" as a live alternative-outcome reason.

**Insertion point**: both heredocs currently end with the `Independence` block. `C14_BASELINE`'s last content line (2242, immediately before the `C14BASE` terminator on 2243) is:
```
'FormalSystem.Metalogic.Independence.z1_validIn_iff_ztime' depends on axioms: [propext, Classical.choice, Quot.sound]
```
`C14LEAN`'s last content line (2446, immediately before the `C14LEAN` terminator on 2447) is:
```
#print axioms FormalSystem.Metalogic.Independence.z1_validIn_iff_ztime
```
The three new lines append cleanly after each of these, in the same declaration order, with no reordering of existing content.

**Downstream consumers are all dynamic, not hardcoded-count**: C21 (every `MainResults.lean` advertised result is axiom-pinned) computes `C21_PINNED` by parsing the `AXIOM_BASELINE`/`C14_BASELINE` heredoc text at run time (line 4166) rather than asserting a fixed total. C36 (certifying-predicate anti-silence guard) likewise parses both heredocs from the script's own source text via regex (lines 6677-6696) to build its `pinned` set. Neither will break from a 3-line baseline growth. The only non-mechanical artifact is a **descriptive, non-enforced comment** at line 4144 ("C2 pins four declarations ... and C14 pins the rest, 105 between them") whose count will become stale by 3; this is cosmetic and not part of the task's acceptance criteria, but worth a one-line touch-up for the implementer since it sits directly above the code this task's diff touches.

### Direct verification: the three declarations actually satisfy `pcq`

This session ran, against the live (unmodified) tree:

```lean
import FormalSystem
#print axioms FormalSystem.Metalogic.Decidability.exists_witnessFamily_of_not_validZTime
#print axioms FormalSystem.Metalogic.Decidability.validZTime_iff_noCertifiedCandidate
#print axioms FormalSystem.Metalogic.Decidability.Compression.decidableValidZTime
```

via `lake env lean <file>`. Output (after the same line-rejoin `sed` the script itself uses, confirming exact-match format):

```
'FormalSystem.Metalogic.Decidability.exists_witnessFamily_of_not_validZTime' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.Decidability.validZTime_iff_noCertifiedCandidate' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.Decidability.Compression.decidableValidZTime' depends on axioms: [propext, Classical.choice, Quot.sound]
```

All three are exactly `pcq` (`[propext, Classical.choice, Quot.sound]`), matching the value the `docs/theorem-index.md` rows already claim. Note `Compression.decidableValidZTime` is a `def` (not a `theorem`), per its own docstring at `Assembly.lean:31` and the `BiLasso/Assembly.lean` precedent it mirrors (`decidableValidZTimeFamily`); `#print axioms` works identically on `def`s and `theorem`s, and the C14 baseline already carries other non-`theorem` entries by the same mechanism, so this is not an obstacle.

### The fourth (pending) declaration — fold-in check

The dispatch asks to pin a fourth declaration if the separately-filed corollary task has already landed. `specs/TODO.md` task 724 ("Decidable ztime provability witness family corollary") lists `Dependencies: Task 723` and `Status: [NOT STARTED]`. Its own re-verification instruction (`grep -rn --include='*.lean' 'Decidable (Derivable' FormalSystem/` must return zero hits) was re-run this session and still returns **zero hits** in `FormalSystem/` (the only tree-wide hit is a documentation "not built" row in `FormalSystem/Metalogic/Decidability/Verified/README.md`, not a declaration). The declaration (`Decidable (Derivable FrameClass.ZTime [] φ)`) has not landed. Per the dispatch's instruction, this task should **leave a comment naming it** rather than invent a fourth baseline entry.

**Constraint**: per `.claude/rules/no-task-references-in-deliverables.md`, `scripts/check-module-invariants.sh` and `docs/theorem-index.md` are deliverable files outside `specs/**`, so the comment must name the pending declaration by its Lean signature/description, never by task number (no "task 724" in the comment).

### External Resources

None consulted; this is a purely internal, mechanical codebase-grounding task with no external-library or documentation dependency.

## Recommendations

1. **Append three lines to `C14_BASELINE`** (after line 2242, the `z1_validIn_iff_ztime` line, before the `C14BASE` terminator), in this order:
   ```
   'FormalSystem.Metalogic.Decidability.exists_witnessFamily_of_not_validZTime' depends on axioms: [propext, Classical.choice, Quot.sound]
   'FormalSystem.Metalogic.Decidability.validZTime_iff_noCertifiedCandidate' depends on axioms: [propext, Classical.choice, Quot.sound]
   'FormalSystem.Metalogic.Decidability.Compression.decidableValidZTime' depends on axioms: [propext, Classical.choice, Quot.sound]
   ```
2. **Append the matching three `#print axioms` directives to `C14LEAN`** (after line 2446, before the `C14LEAN` terminator), in the identical order:
   ```
   #print axioms FormalSystem.Metalogic.Decidability.exists_witnessFamily_of_not_validZTime
   #print axioms FormalSystem.Metalogic.Decidability.validZTime_iff_noCertifiedCandidate
   #print axioms FormalSystem.Metalogic.Decidability.Compression.decidableValidZTime
   ```
3. **Add a short comment near the new lines** (not a task-number reference) noting that a fourth declaration — `Decidable (Derivable FrameClass.ZTime [] φ)`, the witness-family corollary for Z-time derivability — is planned as a sibling pin once it lands, so the follow-up addition is a one-line copy of this block's shape rather than a rediscovery.
4. **Do not touch the three `docs/theorem-index.md` rows' content** — they already state the correct `pcq pinned:C14` value; the row-correction alternative outcome does not apply here, since the check CAN and, once the baseline is updated, WILL verify exactly what the rows claim.
5. **Optional, non-blocking**: update the descriptive (non-enforced) count in the C21 comment block ("105 between them", line 4144) to reflect the baseline growing by three, since the implementer's diff sits directly adjacent to it — cosmetic only, not an acceptance-criterion item.
6. **Verification step for the implementation phase**: run `bash scripts/check-module-invariants.sh` (full build, `RUN_BUILD=1` default) after the edit and confirm C14 reports `pass` with the new lines echoed in its `note` output, and that no other check (`C21`, `C23`, `C36`) regresses. A `--no-build` pass alone is insufficient since it skips the `#print axioms` half of C14 entirely (line 2464).

## Decisions

- **Baseline route confirmed as correct**, not the row-correction alternative: live `#print axioms` probes on all three declarations return exactly `pcq`, matching what the rows already assert, and the Decidability namespace is already inside C14's scope (via the pre-existing `sound_of_isValid` entry). There is no tree-revealed reason this module should be excluded from C14.
- **Fourth declaration is not pinned now**: confirmed unlanded via a fresh `grep -rn --include='*.lean' 'Decidable (Derivable' FormalSystem/` (zero hits); a comment naming it (without a task-number reference) is the correct fold-in per the dispatch's explicit either/or instruction.
- **Insertion point is the end of both heredocs** (after the `Independence` block), preserving existing-entry order and requiring no reordering, consistent with the append-only convention the script's own header comment (lines 2009-2010) mandates.

## Risks & Mitigations

- **Risk**: pasting the three new lines into only one of the two heredocs, or in a different relative order between them, causes C14 to fail outright (exact string equality) rather than silently pass. **Mitigation**: the exact line text and insertion point for both heredocs is given verbatim above; the implementer should diff both blocks side-by-side before running the check.
- **Risk**: running `lake env lean` directly (as done in this research pass) without first confirming a clean/current build could pick up a stale `.olean` cache and report misleading axiom sets. **Mitigation**: this session's probe imported `FormalSystem` (the umbrella module) and succeeded without errors, which is strong evidence the tree is buildable and current; the implementation phase should still run the full `check-module-invariants.sh` (which itself runs `lake build` under `RUN_BUILD=1`, per C1) as the authoritative verification rather than relying solely on this probe.
- **Risk**: scheduling collision — task 706 declares `file_scope` on the same script file. **Mitigation**: already called out in the dispatch; schedule this task's implementation in a cycle that does not overlap 705/706.

## Context Extension Recommendations

- **Topic**: C14 baseline edit procedure
- **Gap**: there is no standalone context file documenting "how to add a declaration to the C14 baseline pair" as a repeatable procedure (the only documentation is the inline script comment at lines 2009-2037). Several open TODO.md tasks (e.g. task 724) will need to repeat this exact mechanical procedure.
- **Recommendation**: if this pattern recurs (it is about to, via task 724), consider adding a short `context/project/lean4/patterns/c14-baseline-pin.md` documenting the two-heredoc, exact-order, exact-string-equality contract, so future dispatches do not need to re-derive it from the script's comments each time.

## Appendix

### Search queries / commands used

```bash
grep -nE 'Compression\.|decidableValidZTime|validZTime_iff_noCertifiedCandidate|exists_witnessFamily_of_not_validZTime' scripts/check-module-invariants.sh
grep -n "C14" scripts/check-module-invariants.sh
grep -n "exists_witnessFamily_of_not_validZTime\|validZTime_iff_noCertifiedCandidate|decidableValidZTime|Decidable (Derivable" docs/theorem-index.md
grep -rn --include='*.lean' 'Decidable (Derivable' FormalSystem/
# direct lake env lean probe (this session, against the live, unmodified tree):
cat > /tmp/.../c14_probe.lean <<'EOF'
import FormalSystem
#print axioms FormalSystem.Metalogic.Decidability.exists_witnessFamily_of_not_validZTime
#print axioms FormalSystem.Metalogic.Decidability.validZTime_iff_noCertifiedCandidate
#print axioms FormalSystem.Metalogic.Decidability.Compression.decidableValidZTime
EOF
lake env lean /tmp/.../c14_probe.lean
```

### References

- `docs/theorem-index.md` lines 18 (legend), 151-153 (the three affected rows)
- `scripts/check-module-invariants.sh` lines 2009-2464 (C14 mechanism), 3461-3471 (C23 shadow allowlist hit), 4130-4181 (C21), 6670-6745 (C36)
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Family.lean` lines 67, 153 (`exists_witnessFamily_of_not_validZTime`)
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Assembly.lean` lines 16, 31-32, 88-89, 105, 113, 124, 137, 147-148, 163 (`validZTime_iff_noCertifiedCandidate`, `decidableValidZTime`)
- `specs/TODO.md` lines 277-298 (task 724, the fold-in dependency)
