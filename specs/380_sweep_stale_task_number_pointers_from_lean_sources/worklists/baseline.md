# Gate Baselines (Phase 1, recorded 2026-07-24)

Recorded on the clean working tree at HEAD `2b315b64a` (Theories/ content unchanged since
research baseline `c12eab1d6`; `git status --porcelain Theories` empty). All later phase
gates reconcile against the numbers below.

## Build

- `lake build` → **EXIT 0**, `Build completed successfully (1789 jobs).`
- Exactly ONE pre-existing warning (must remain byte-identical through the sweep):
  `Theories/Bimodal/Automation/DatasetGenerator.lean:2174:6: unused variable 'q'`

## Sorry census (invariant at every gate)

```bash
grep -rn '\bsorry\b' Theories --include='*.lean' | wc -l                                  # 906
grep -rn '\bsorry\b' Theories --include='*.lean' | grep -vE '^\S+:[0-9]+:\s*--' | wc -l   # 820
grep -rn 'sorryAx' Theories --include='*.lean' | wc -l                                    # 26
```

Reproduced this session: **906 / 820 / 26** — identical to the research report §5.

## Sweep-pattern baseline

```bash
grep -rE '\b[Tt]asks?[ #-]?[0-9]{1,4}\b' Theories --include='*.lean' | wc -l   # 1549
grep -rlE '\b[Tt]asks?[ #-]?[0-9]{1,4}\b' Theories --include='*.lean' | wc -l  # 192
```

Reproduced this session via `rewrite_task_refs.py --count Theories`: **1,549 lines / 192
files** — identical to the research inventory (report §1). Also cross-checked per-file:
SharedWitness.lean scoped `--count` = 261 (matches report histogram top row).

## Declaration-count baseline (for Phase 8 reconciliation)

```bash
grep -rEc '^\s*(theorem|lemma|def|noncomputable def|instance|structure|inductive)\b' \
  Theories --include='*.lean' -h | awk '{s+=$1} END {print s}'
```

(Phase 8 may alternatively rely on `--check-diff --base c12eab1d6`, which proves
comment-only hunks directly; recorded command kept for the spot-check option.)

## check-diff gate

`rewrite_task_refs.py --check-diff --base HEAD Theories` on the clean tree:
`0 changed .lean file(s), 0 failure(s)`, EXIT 0.
