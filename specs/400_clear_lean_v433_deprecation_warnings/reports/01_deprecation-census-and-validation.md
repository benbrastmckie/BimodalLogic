# Deprecation Census and `push Not` Validation

**Task**: 400 — clear_lean_v433_deprecation_warnings
**Session**: sess_1785074764_351b3f_400
**Toolchain**: Lean v4.33.0-rc1, Mathlib tag `v4.33.0-rc1`
**Status**: Research complete. No source files were mutated; all validation ran on scratch copies.

---

## 1. Verified Baseline

`lake build` from a clean tree:

```
Build completed successfully (1875 jobs).
```

| Invariant | Value |
|-----------|-------|
| Errors | **0** |
| Live sorries | **1** |
| Sorry location | `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean:1225:8` |

The sorry line has drifted from the 1242 quoted in the task brief to **1225**. Identify it by
content, not line number. It is the only `declaration uses \`sorry\`` emission in the whole build,
and `Bimodal.Metalogic.BXCanonical.completeness` is the single declaration whose axiom set
includes `sorryAx`.

`Tests/` is not part of the default target (`@[default_target] lean_lib Bimodal`) and contains
zero `push_neg` occurrences, so it is out of scope.

---

## 2. Re-derived Deprecation Census

**553 deprecation warnings across 60 files.** Every warning maps to exactly one distinct
`(file, line, col)` site — see §5.

| Deprecated symbol | Count | Replacement | Kind |
|---|---:|---|---|
| `push_neg` | **505** | `push Not` | pure substitution |
| `Fin.coe_castSucc` | 17 | `Fin.val_castSucc` | statement-identical alias |
| `Fin.lt_iff_val_lt_val` | 10 | `Fin.lt_def` | statement-identical alias |
| `List.Chain` | 6 | `List.IsChain` | **shape change** |
| `List.chain_cons` | 4 | `List.isChain_cons_cons` | statement-identical alias |
| `Finset.le_iff_subset` | 4 | *(delete — now a syntactic tautology)* | wrapper removal |
| `List.Chain.cons` | 2 | `List.IsChain.cons_cons` | **shape change** |
| `Option.iget` | 1 | `Option.getD default` | semantic choice |
| `Encodable.surjective_decode_iget` | 1 | `Encodable.surjective_decode_getD` | semantic choice |
| `List.take_succ` | 1 | `List.take_add_one` | statement-identical alias |
| `List.Chain.nil` | 1 | `List.IsChain.singleton _` | **shape change** |
| `Mathlib.Data.Finite.Card` (import) | 1 | `Mathlib.SetTheory.Cardinal.NatCard` | import swap |
| **Total** | **553** | | |

### Delta against prior measurements

| Measurement | Total | `push_neg` | Delta vs. now |
|---|---:|---:|---|
| Original task brief | 554 | 506 | −1 total, −1 `push_neg` |
| Tier-3-era figure | — | 521 | −16 `push_neg` |
| **This census** | **553** | **505** | — |

The **554 → 553** delta is a single `push_neg` site, consistent with archival to
`Boneyard/`. `Boneyard/` still holds 176 `push_neg` occurrences (685 total in-tree minus 509
outside it); those are unbuilt and inert, and must **not** be touched.

The **521** figure does not reconcile with either 505 or 506 and appears to have been a partial
or mid-sweep count. Treat **505** as authoritative; it is derived from the full build log and
cross-checks exactly against the source (§5).

The brief's claim of "1 in Automation/" is **stale**: `Theories/Bimodal/Automation/` now has
**zero** deprecations. All 553 are under `Metalogic/`.

---

## 3. Central Risk Resolved: `push Not` Is Provably a Pure Substitution

This is not merely an empirical finding. `Mathlib/Tactic/Push.lean` shows the two tactics
dispatch to **the same function with the same arguments**:

```lean
-- push  (line 247)                          -- push_neg (line 281)
elab "push" cfg disch? head loc : tactic     elab "push_neg" cfg loc : tactic
  let disch? ← disch?.mapM elabDischarger      logWarning "...deprecated..."
  let loc := (loc.map expandLocation)          let loc := (loc.map expandLocation)
              .getD (.targets #[] true)                    .getD (.targets #[] true)
  push (← elabPushConfig cfg) disch?           push (← elabPushConfig cfg) none
       (← elabHead head) loc                        (.const ``Not) loc
```

`elabHead` on the term `Not` returns exactly `.const \`\`Not`, and an absent `(disch := …)` gives
`none`. Config elaboration, location expansion, and the default `ifUnchanged := .error` are
identical. **The sole behavioural difference is the `logWarning` call.** The conv-mode `push_neg`
is literally `evalTactic (← \`(conv| push $cfg Not))`.

Mathlib's own deprecation message states the intended equivalence as a macro:

```lean
macro "push_neg" cfg:optConfig loc:(location)? : tactic =>
  `(tactic| push $cfg:optConfig Not $[$loc]?)
```

### Empirical confirmation

All **56** files containing `push_neg` were copied to scratch, had all **505** sites substituted
at exact `(line, col)` positions, and were elaborated with the lakefile's `leanOptions` applied:

```
files probed        : 56
files fully clean   : 56
push_neg warnings removed: 505
problems            : 0
```

The gate was **category-count differential**, not silence: for each file, every non-`push_neg`
message category (including `declaration uses \`sorry\``) had to hold its exact count between the
build-log baseline and the substituted elaboration. Zero categories drifted. Zero errors.

This covers the "goal subsequently manipulated" case by construction — e.g. all eight bare
`push_neg` sites are immediately followed by `intro` on the transformed goal, and
`SplitPoint.lean` alone has 65 sites inside long tactic blocks.

### Codebase-specific hazards checked and cleared

| Hazard | Finding |
|---|---|
| `Not` shadowed by a local declaration (would silently re-target `push`) | **None.** No declaration named `Not` anywhere in `Theories/`. |
| `push_neg` with config (`+distrib`) — arg order differs (`push +distrib Not`) | **Zero** uses. |
| `push_neg at *` | **Zero** uses. |
| conv-mode `push_neg` | **Zero** uses. |
| `push_neg <;> …` | **Zero** uses. |
| `colGt` absorption: bare `push Not` swallowing the next line as its `head` argument | **Zero at risk.** All 8 bare sites are followed by a line at *equal* indentation; `colGt` requires strictly greater. |
| Line-length regression (tier-3 `longLine` compliance) | **None possible.** `push_neg` and `push Not` are both **8 characters** — column positions are preserved exactly. |

---

## 4. The 48-Warning Non-`push_neg` Remainder

Every one of these was fixed and validated on scratch copies. **All 10 affected files elaborate
clean with zero remaining deprecations, zero errors, and no new warnings.**

### 4a. Statement-identical aliases (32 sites) — token swap

Verified by `#check` that the deprecated and replacement names have *character-identical*
statements:

```
@Fin.coe_castSucc      : ∀ {n} (i : Fin n), ↑i.castSucc = ↑i
@Fin.val_castSucc      : ∀ {n} (i : Fin n), ↑i.castSucc = ↑i
@Fin.lt_iff_val_lt_val : ∀ {n} {a b : Fin n}, a < b ↔ ↑a < ↑b
@Fin.lt_def            : ∀ {n} {a b : Fin n}, a < b ↔ ↑a < ↑b
@List.take_succ        : List.take (i+1) l = List.take i l ++ l[i]?.toList
@List.take_add_one     : List.take (i+1) l = List.take i l ++ l[i]?.toList
@List.chain_cons       : List.IsChain R (a::b::l) ↔ R a b ∧ List.IsChain R (b::l)
@List.isChain_cons_cons: List.IsChain R (a::b::l) ↔ R a b ∧ List.IsChain R (b::l)
```

Note `List.chain_cons` is *already* stated in terms of `IsChain`.

### 4b. `List.Chain` cluster (13 sites, all in `SharedWitness.lean`) — shape change

`List.Chain` takes the head element separately; `List.IsChain` takes one list. The bridge holds
**definitionally**:

```lean
example (R : α → α → Prop) (a : α) (l : List α) :
    List.Chain R a l = List.IsChain R (a :: l) := rfl   -- ✓ accepted
```

Both coercion directions also typecheck by `exact h`, so proofs survive the statement rewrite.
Transformations applied:

| From | To |
|---|---|
| `List.Chain (· < ·) lo (mid ++ [hi])` | `List.IsChain (· < ·) (lo :: (mid ++ [hi]))` |
| `List.Chain.cons` | `List.IsChain.cons_cons` |
| `List.Chain.nil` | `(List.IsChain.singleton _)` |

Four of the six `List.Chain` occurrences sit in **theorem statements**
(`kvE2_sepGapRegions_pos`, `kvE2_sepChain_lt_between`, `kvE2_sepGapRegions_lo_le`,
`kvE2_sepGapRegions_hi_le`). All of their call sites are **inside `SharedWitness.lean` itself**
— no downstream module references them, so the API change is fully contained. Resulting lines
peak at 79 characters, well under the 100-char `longLine` limit.

### 4c. `Finset.le_iff_subset` (4 sites, 2 files) — wrapper deletion

The lemma is now the tautology `s₁ ⊆ s₂ ↔ s₁ ⊆ s₂` (Mathlib marks it
`@[deprecated "This is now a syntactic equality", nolint synTaut]`). All four uses have the form
`Finset.le_iff_subset.mp (Finset.le_sup …)`; deleting the string `"Finset.le_iff_subset.mp "`
leaves `(Finset.le_sup …)`, which typechecks directly. `VVecEA2Collapse.lean` and
`ZetaUniformExtract.lean` contain near-identical duplicated blocks.

### 4d. `Option.iget` pair (2 adjacent sites, `ShiftAndGlue.lean:143-144`)

```lean
-- from
let enum : ℕ → α := fun n => (Encodable.decode (α := α) n).iget
have h_surj : Function.Surjective enum := Encodable.surjective_decode_iget α
-- to
let enum : ℕ → α := fun n => (Encodable.decode (α := α) n).getD default
have h_surj : Function.Surjective enum := Encodable.surjective_decode_getD α default
```

`surjective_decode_getD` requires an explicit default; an `Inhabited α` instance is already in
scope three lines above, so `default` resolves.

### 4e. Import (1 site) — reported position is misleading

The warning reads `MonadicFO.lean:7:0`, but **line 7 is `import Mathlib.Data.Fintype.Card`**.
Lean reports module-level import deprecations at the header position. The actual edit target is
**line 10**, `import Mathlib.Data.Finite.Card` → `import Mathlib.SetTheory.Cardinal.NatCard`.
Risk is low: the deprecated module is a pure shim whose entire body is
`public import Mathlib.SetTheory.Cardinal.NatCard` + `deprecated_module`. Eight modules import
`MonadicFO`, so this is the one edit with genuine cross-file reach — the full-build gate covers it.

---

## 5. Phase Sizing — by Distinct Sites

**Raw warning emissions equal distinct sites 1:1 here.** This differs from the tier-3 experience
(78 raw → 41 distinct): 505 `push_neg` warnings map to 505 unique `(file, line, col)` triples.
Cross-check against source: 509 source lines contain `push_neg` outside `Boneyard/`; the 4
non-warning lines are **all prose** — three doc-comments and one comment recording that
"`push_neg` no longer fires here". **These four must not be rewritten**; two of them are
explanatory notes whose accuracy depends on naming the old tactic.

**Total: 553 sites across 60 files** (56 `push_neg` files ∪ 10 non-`push_neg` files, overlap 6).

Distribution is extremely top-heavy — 4 files hold 315 of 553 sites (57%):

| File | `push_neg` | other | total |
|---|---:|---:|---:|
| `WeakCanonical/EFGames/GapDetection.lean` | 201 | 0 | **201** |
| `WeakCanonical/Expressiveness/SplitPoint.lean` | 65 | 0 | **65** |
| `BXCanonical/Chronicle/CounterexampleElimination.lean` | 26 | 0 | **26** |
| `WeakCanonical/IntegerModel/GoodStructuresModelSurgery.lean` | 23 | 0 | **23** |
| `Kamp/NfMultiAnchorBridge/SharedWitness.lean` | 4 | 14 | **18** |
| `Expressiveness/Claim1.lean` | 15 | 0 | 15 |
| `SoundnessLemmas/DenseValidity.lean` | 12 | 0 | 12 |
| `Kamp/EANegation.lean` | 4 | 8 | 12 |
| `Kamp/LiftPair.lean` | 6 | 6 | 12 |
| `Kamp/ConjInterleave.lean` | 3 | 8 | 11 |
| *(50 further files)* | | | 1–10 each |

### Recommended phases

The mechanical substitution is uniform, so phases should be cut by **risk class**, not by site
count. Sizing note: each phase's edit is a scripted pass, so the agent-run cost is dominated by
elaboration, not by lines written.

| Phase | Scope | Sites | Files | Risk |
|---|---|---:|---:|---|
| 1 | `push_neg` → `push Not`, all files | 505 | 56 | very low — proven equivalent |
| 2 | Statement-identical aliases (`Fin.*`, `List.take_succ`, `List.chain_cons`) | 32 | 7 | very low |
| 3 | `Finset.le_iff_subset` deletion + `Option.iget` pair + import | 7 | 4 | low |
| 4 | `List.Chain` → `List.IsChain` in `SharedWitness.lean` | 13 | 1 | moderate — statement change |
| 5 | Full `lake build` gate + sorry-count assertion | — | — | mandatory |

Phase 1 is a single scripted pass; splitting it by file buys nothing because every site is
independently verified and the whole set already passed. Phase 4 is the only phase needing
careful per-edit reasoning and should not be merged with the others.

---

## 6. Tier-3 Toolkit Reuse — Recommended, With Three Required Adaptations

The harness at `specs/399_mathlib_linter_compliance_tier3_metalogic/tools/` is a **good fit** and
should be reused rather than rebuilt. Evidence:

- `lintlib.py`'s `POS_RE` already parses the raw `lean` CLI format correctly.
- `lintlib.py` **already has a `(deprecation)` category** in `classify()`; it is currently listed
  in `OUT_OF_SCOPE_FROZEN` precisely because tier-3 deliberately excluded this task's territory.
  Flipping it to `IN_SCOPE` is a one-line change.
- `census()` already counts **distinct `(file,line,col)` sites**, which is the correct sizing unit.
- `sweep.py` already implements the per-file revert-on-regression gate: revert unless in-scope
  categories reach zero, no other category rises, and no error appears. That is exactly the gate
  this task needs.

Required adaptations:

1. **`run_lint` does not pass the lakefile's `leanOptions`.** It runs
   `lake env lean -Dlinter.mathlibStandardSet=true <path>` with no `-DautoImplicit=false`. Since
   `lean_lib Bimodal` sets `autoImplicit := false`, the harness elaborates under a **strictly more
   permissive** setting than `lake build`, which can mask an error. Add
   `-DautoImplicit=false -Dpp.unicode.fun=true`. (I used these throughout; this is likely a
   contributing factor to the `DecidablePred` divergence the prior task hit.)
2. **Add a position-anchored deprecation fixer** to `fixers.py` (see §7 — this is not optional).
3. `POS_RE` anchors on `^Theories/`, so the harness must sweep **in place with revert**, as
   `sweep.py` already does, rather than on scratch copies.

Keep using `runlinter.py` for `runLinter` output; do not write a new parser.

---

## 7. Mandatory Implementation Constraint: Position-Anchored Replacement

**Global substring replacement is unsafe and must be prohibited.** I hit this during validation:

`List.take_succ` is a **prefix of `List.take_succ_cons`** — a distinct, *non-deprecated* lemma
used at `SharedWitness.lean:9721`. A global `text.replace("List.take_succ", "List.take_add_one")`
silently rewrote it to the nonexistent `List.take_add_one_cons`, producing:

```
SharedWitness.lean:9722:28: error: Tactic `rewrite` failed:
Did not find an occurrence of the pattern List.take (List.length ?m + ?m) ?m
```

The failure surfaced ~1 line away from the corruption and also induced a spurious
`This simp argument is unused` warning. Re-running position-anchored (replace only at the exact
reported `(line, col)`, asserting the expected token is present) made the file clean.

A codebase-wide collision scan found **exactly one** such collision (`List.take_succ_cons`).
Notably `push_neg` has **no** collisions — but the discipline should be uniform:

> Replace only at the exact `(line, col)` positions the compiler reported, asserting the
> expected token is present before substituting, and apply edits bottom-up.

This also automatically protects the four prose mentions of `push_neg` in §5, which carry no
warning and therefore no position.

---

## 8. Residual Risk

`lake env lean` on a single file is **not** a substitute for `lake build` — this is established
prior art and I preserved it as a constraint rather than re-testing it. Per-file probes cannot
observe cross-module effects. Mitigating factors:

- Tactic-body substitutions cannot change any theorem's *statement*, so 540 of 553 sites have no
  cross-module surface at all.
- The 13 statement-affecting sites (`List.Chain`) are confined to `SharedWitness.lean`, whose
  affected theorems have no external callers (verified).
- The import swap is the one edit with real cross-module reach (8 importers).

**A full `lake build` gate at the end of every phase remains mandatory**, asserting:
`0 errors`, `1875 jobs`, and **exactly 1** `declaration uses \`sorry\`` at `Transfer.lean`.

## 9. Scope Boundaries

Untouched, per the task's territory rules — these belong to a sibling task and their counts must
stay frozen: `linter.defProp` (~35 `Definition … is a proposition; use theorem instead of def`),
`linter.dupNamespace` (13, all `Chronicle.Chronicle.*`), and `defsWithUnderscore`. No declaration
is renamed and no `def` becomes a `theorem`. `Boneyard/` is not touched.

---

## Appendix: Reproduction

Artifacts under
`/tmp/claude-1000/-home-benjamin-Projects-BimodalLogic/d076aad2-adb5-4166-af34-bc1643b30a58/scratchpad/`
(ephemeral):

| File | Purpose |
|---|---|
| `build_full.log` | Full `lake build` baseline log |
| `warn_sites.txt` | 505 `push_neg` sites, `file\|line\|col` |
| `other_sites.txt` | 48 non-`push_neg` sites, `file\|line\|col\|symbol` |
| `probe2.py` | Position-anchored substitution + differential census |
| `fix_other.py` | Full end-state fixer for the 10 non-`push_neg` files |

The two site lists are worth regenerating rather than trusting, via:
`grep '^warning:' build.log | grep 'has been deprecated'`.
