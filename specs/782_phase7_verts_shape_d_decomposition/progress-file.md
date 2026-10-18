# Progress File: Task 782 — verification-and-closure round

Dispatch 4 (implement), session sess_1792301223_5bcf1c, 2026-10-18.

## Phase 1: Re-derive the landed Shape D state against the acceptance bar

### Tree state before any check

| Check | Command | Output |
|-------|---------|--------|
| HEAD | `git rev-parse HEAD` | `b5547cef9b0c7a23b3b2f10c53aae5136b192ee4` |
| Latest commit on `Timed.lean` | `git log -1 --format=%h -- FormalSystem/Metalogic/Decidability/PlusSlicedCertificate/Timed.lean` | `fcd3ffcb0` (2026-10-13, `task 716 phase 7: Shape D -- the posAt-hoisted verts and the succT/predT let-hoists`) — as expected |
| Source tree clean | `git status --porcelain FormalSystem/` | empty |
| Foreign build | `ps` sweep for `lake`/`lean` | only LSP workers (`lake serve`, `lean --worker`, `lean --server`); no `lake build` running |

### Body shapes (`Timed.lean`, re-read immediately beforehand)

`grep -n -A6 '^def verts\|^def succT\|^def predT' …/Timed.lean`:

```
164:def verts (G : PlusSlicedCertificate Γ Del) : Finset G.TPos :=
165-  G.winTimes.biUnion (fun t => (G.posAt t).image (fun p => (p, t)))
424:def succT (G : PlusSlicedCertificate Γ Del) (v : G.TPos) : Finset G.TPos :=
425-  let V := G.verts
426-  let u := G.nextTime v.2
427-  let S := G.succP v.2 v.1
428-  V.filter (fun w => w.2 = u ∧ w.1 ∈ S)
431:def predT (G : PlusSlicedCertificate Γ Del) (v : G.TPos) : Finset G.TPos :=
432-  let V := G.verts
433-  let u := G.prevTime v.2
434-  let P := G.predP v.2 v.1
435-  V.filter (fun w => w.2 = u ∧ w.1 ∈ P)
```

`grep -n 'posTable\|posAtC\|find?' …/Timed.lean` — no output, grep exit 1 (nothing matched).

### Statement fidelity (working tree vs `git show 960e39ede:…/Timed.lean`)

For each of `mem_verts`, `mem_succT`, `mem_predT`, `grep -A2 '^theorem NAME '` on both and `diff`:

- `mem_verts` — statement lines (the `theorem` line and its `: v ∈ G.verts ↔ v.2 ∈ G.winTimes ∧ v.1 ∈ G.posAt v.2 := by` continuation) byte-identical. The third line of the `-A2` window is the first PROOF line and differs (`rw [verts, Finset.mem_biUnion]` now vs `simp [verts, Finset.mem_product]` at 960e39ede), which is the expected consequence of the body change and not a statement change.
- `mem_succT` — all three lines identical (`Finset.mem_filter` term proof unchanged).
- `mem_predT` — all three lines identical.

Working-tree statements (lines 167-168, 437-438, 441-442) match the plan's pinned block exactly.

### `withBx` transfer and axiom profiles — `probes/01_shapeD_landed_transfer.lean`

Copied from the parent's `probes/25_shapeD_landed_transfer.lean`; header re-pointed at this task; cap `maxHeartbeats 200000` unchanged.

`timeout 600 lake env lean specs/782_phase7_verts_shape_d_decomposition/probes/01_shapeD_landed_transfer.lean` — **exit 0**, wall **1.846 s** (plan-time re-derivation against d034460fd: 1.9 s). The three `rfl` `example`s and the `mem_verts` control elaborated without error. Axiom lines:

```
'…PlusSlicedCertificate.mem_verts' depends on axioms: [propext, Classical.choice, Quot.sound]
'…PlusSlicedCertificate.mem_succT' depends on axioms: [propext, Classical.choice, Quot.sound]
'…PlusSlicedCertificate.mem_predT' depends on axioms: [propext, Classical.choice, Quot.sound]
```

No `sorryAx`.

### `Complete.lean` surface

- `grep -c 'withBx_' …/Complete.lean` → **27** (CARRIED from iss_1791938399591_KHUXUs; plan-time 27; re-derived here 27).
- `grep -n 'List.find?' …/Complete.lean` → line 198 (`matcher's scrutinee is a \`List.find?\` over a range built from \`G.winLo\` / \`G.winHi\` — projections`), the recorded third instance of the stuck-matcher pattern, non-empty.

### Isolated factor, measured this round (D4) — `probes/02_old_vs_landed_measure.lean`

`vertsOld` re-declared verbatim from 960e39ede line 149: `(Finset.univ ×ˢ G.winTimes).filter (fun v => v.1 ∈ G.posAt v.2)`. Cap `maxHeartbeats 2000000`.

`timeout 600 lake env lean specs/782_phase7_verts_shape_d_decomposition/probes/02_old_vs_landed_measure.lean` — **exit 0**, wall 3.969 s. Output:

| Line | Output | Time |
|------|--------|------|
| `#time #eval (certA.verts).card` (landed Shape D) | `16` | **16 ms** |
| `#time #eval (certA.vertsOld).card` (pre-Shape-D filter) | `16` | **1105 ms** |
| `#time #eval (certA.verts = certA.vertsOld)` | `true` | 1290 ms |

Both cards 16; equality `true`. **This round's factor: ~69x** (1105/16). Beside the carried pairs: **15 ms vs 1093 ms** (task description / parent probe 24, ~73x) and **21 ms vs 1358 ms** (`Timed.lean` `verts` docstring, ~65x). Consistent; recorded, not acted on.

### Decomposition-change record (parent's archived plan)

`grep -n '^### Decomposition Change\|^- \*\*D8\*\*' specs/archive/716_sliced_certificate_liveat_nontermination/plans/02_shape-d-verts-biunion.md`:

```
88:### Decomposition Change (raised, not substituted)
223:- **D8**: `posTable`, `posAtC` and `posAtC_eq` are **dropped** from the Goals and from
```

Both present; cite as `02_shape-d-verts-biunion.md` § "Decomposition Change (raised, not substituted)" (line 88) and D8 (line 223). Nothing added to the parent's archived plan.

### Issue-record attestation (Phase 1)

One `kind: win` entry recorded via `issue-record.sh` (`--phase implement --dispatch-seq 4`): every acceptance check passed first time on the current tree with no second look needed; the measured factor (69x) sits between the two carried figures. No `kind: issue` entry arose in this phase.

### Source scope

`git status --porcelain FormalSystem/` empty after this phase: no `FormalSystem/**` file edited.
