# Teammate D Findings: Boneyard Strategy and Phased Rebuild Architecture

## Summary

This report designs the Boneyard archival strategy and phased rebuild plan for switching
Until/Since semantics from half-closed guard `[t, s)` / `(s, t]` to open guard `(t, s)` /
`(s, t)`. The user's stated requirement is "no patches or bridges — archive dead elements
to Boneyard/ and rebuild as necessary."

The key semantic change is in `Truth.lean` lines 127-130:
```
-- CURRENT (half-closed):
| Formula.untl φ ψ => ∃ s, t < s ∧ M,τ,s ⊨ ψ ∧ ∀ r, t ≤ r → r < s → M,τ,r ⊨ φ
| Formula.snce φ ψ => ∃ s, s < t ∧ M,τ,s ⊨ ψ ∧ ∀ r, s < r → r ≤ t → M,τ,r ⊨ φ

-- TARGET (open):
| Formula.untl φ ψ => ∃ s, t < s ∧ M,τ,s ⊨ ψ ∧ ∀ r, t < r → r < s → M,τ,r ⊨ φ
| Formula.snce φ ψ => ∃ s, s < t ∧ M,τ,s ⊨ ψ ∧ ∀ r, s < r → r < t → M,τ,r ⊨ φ
```

This single change (`≤` to `<` at the guard boundary) renders two axiom constructors
unsound and requires targeted surgery across 7 files.

---

## Section 1: Classification of All Affected Code

### 1.1 ARCHIVE to Boneyard (dead under open guard, cannot be rebuilt)

#### `Axioms.lean` — 2 constructors

| Constructor | Statement | Why Dead |
|------------|-----------|----------|
| `until_guard` | `(φ U ψ) → φ` | Under open guard `(t,s)`, t ∉ (t,s), so φ(t) is not guaranteed. **Unsound.** |
| `since_guard` | `(φ S ψ) → φ` | Under open guard `(s,t)`, t ∉ (s,t), so φ(t) is not guaranteed. **Unsound.** |

These two constructors cannot exist in the axiom type at all under open guard semantics.
They must be removed from the `Axiom` inductive type, not merely commented out.

**Note**: The existing comment block (lines 260-274) already anticipates this: it says
"Under half-open guard semantics... Since t ≤ t and t < s, the guard gives φ(t)". Under
open guard, `t ≤ t` (i.e. `t ∈ [t,s)`) is exactly what fails.

#### `SoundnessLemmas.lean` — 4 theorems + 8 match arms

The two standalone validity theorems are dead:

| Theorem | Lines | Why Dead |
|---------|-------|----------|
| `until_guard_valid` | 757-762 | Proves `(φ U ψ) → φ` valid using `le_rfl`. Under open guard, `h_guard t le_rfl hts` fails since `t ≤ t` (not `t < t`). |
| `since_guard_valid` | 767-772 | Mirror: fails because `h_guard t hst le_rfl` requires `t ≤ t`. |

These two theorems have no open-guard analogue — they simply do not hold. Archive both.

The 8 match arms in `SoundnessLemmas.lean` that route `until_guard` and `since_guard`
through the swap/validity traversals (lines 792-799, 1274-1284, 1689-1700, 1897-1910) are
**deleted without archiving** — they are trivial dispatch arms that disappear automatically
when the axiom constructors are removed.

#### `Soundness.lean` — 8 match arms

The 8 match arms at lines 860-861, 868-869, 903-904, 911-912, 947-948, 955-956, 1053-1054,
1211-1212 that dispatch `until_guard` and `since_guard` to the now-deleted validators are
**deleted without archiving** — they are pure routing boilerplate.

#### `RRelation.lean` — 2 lemmas + 2 uses

| Lemma | Lines (approx) | Why Dead |
|-------|---------------|----------|
| `until_guard_in_mcs` | ~86-93 | Derives `γ ∈ A` from `γ U δ ∈ A` via `Axiom.until_guard`. Dead when constructor removed. |
| `since_guard_in_mcs` | ~99-106 | Mirror via `Axiom.since_guard`. Dead. |

**Downstream uses** that call these (not archivable — they need rebuild):
- `burgessR3Maximal_exists_from_seed` line ~1193 uses `until_guard_in_mcs` to derive `η ∈ A`
- `untl_absorb_nested` / `snce_absorb_nested` lines ~1235-1260 use the guard axioms directly
- `PointInsertion.lean` line 673 uses `until_guard_in_mcs`

Archive `until_guard_in_mcs` and `since_guard_in_mcs` themselves.

#### `TemporalDerived.lean` — guard-dependent theorems already sorry'd

The theorems `psi_imp_until` and `psi_imp_since` (the BX8/BX8' reflexive intro, lines 233-244)
are already marked sorry with a comment "Under irreflexive semantics, ψ → (φ U ψ) is NOT valid".
Under open guard this remains invalid. These are already acknowledged as dead code.

`refl_F` and `refl_P` (lines 431-441) are likewise already sorry'd as invalid under strict semantics.

`until_unfold_wrapped`, `since_unfold_wrapped`, `until_intro`, `since_intro`, `until_F_expansion`,
`since_P_expansion`, `or_until_imp`, `or_since_imp` (lines 343-418, 459-514) all depend on
`psi_imp_until` / `psi_imp_since` (BX8/BX8'). Under open guard BX8/BX8' do not exist, so
these entire derived theorem chains are dead. Archive the sorry-chain.

`G_implies_topUntil` (line 164) depends on BX8. Dead.

#### `Substitution.lean` — 2 pattern match arms (already mismatched)

Lines 328-333 reference `Axiom.refl_intro_until` and `Axiom.refl_intro_since`, which are
**already missing from the current `Axioms.lean`** (they were removed in a prior BX refactor
but Substitution.lean was not updated). The file also references `Axiom.temp_t_future` and
`Axiom.temp_t_past` (lines 286-291) which similarly do not exist. This file does not compile
today. When `until_guard`/`since_guard` are removed, there will be 4 additional stale arms.
The entire Substitution.lean file needs a clean rebuild to track the current axiom set.

---

### 1.2 REBUILD in Place (correct formulation exists under open guard)

#### `Truth.lean` — 2-character surgical change

Change `t ≤ r` to `t < r` in the Until guard quantifier, and `r ≤ t` to `r < t` in the
Since guard quantifier. This is the one-line semantic foundation change. Everything else
flows from it.

#### `SoundnessLemmas.lean` — 2 theorems need new proofs

`until_elim_valid` (lines 777-783) and `since_elim_valid` (788-794) currently prove
`(φ U ψ) → (φ ∨ ψ)` by extracting `φ(t)` from the guard using `h_guard t le_rfl hts`.
Under open guard, `t` is no longer in the guard interval. The axiom `until_elim` (BX9)
still exists, but its *soundness proof* must change.

Under open guard `(t,s)`: φ U ψ at t gives ψ(s) at some s > t. The guard only covers
`(t,s)` strictly — so we cannot extract φ(t) from the guard. The disjunction `φ ∨ ψ`
holds only if `ψ ∈ A` (via BX10, eventuality) or we have separate justification. This
means **BX9 is not sound under open guard** as currently formulated. The axiom constructor
`until_elim` and its soundness proof both require review.

The key question (requiring Teammate B's input): under strict open guard `(t,s)`, is
`(φ U ψ) → (φ ∨ ψ)` still a theorem? Under this semantics φ does not hold at t from
the guard alone. This may need to be replaced with a weaker axiom.

#### `RRelation.lean` — repair `burgessR3Maximal_exists_from_seed`

The proof of `burgessR3Maximal_exists_from_seed` uses `until_guard_in_mcs` to establish
`η ∈ A` (Step 1, line ~1193). Under open guard, the argument must change. The rebuild
strategy: use `until_disjunction_in_mcs` (which derives `γ ∨ δ ∈ A` from `γ U δ ∈ A`
via BX9) combined with MCS negation completeness. If `γ U δ ∈ A` and `γ ∨ δ ∈ A`, then
either `γ ∈ A` or `δ ∈ A`. This is weaker than the guard argument — it gives a disjunction,
not a direct `γ ∈ A`. The proof obligation shifts to showing the disjunction suffices for
seed consistency.

#### `RRelation.lean` — repair `untl_absorb_nested` / `snce_absorb_nested`

These proofs (lines ~1232-1265) use the guard axioms in Step 1 to build the conjunction
`untl(γ,δ) → γ ∧ untl(γ,δ)`. Under open guard, the first half fails. The rebuild uses
BX5 (self_accum_until) directly: `untl(γ,δ) → (γ ∧ untl(γ,δ)) U δ`. Then apply
`rce_imp` to extract `γ` from the conjunction. This is longer but avoids the guard axiom.

#### `PointInsertion.lean` — repair use of `until_guard_in_mcs`

Line 673 calls `until_guard_in_mcs h_mcs_A h_utl_bot` to derive `bot ∈ A`. Under open
guard, derive this differently: `bot U gamma ∈ A` → by BX9 `bot ∨ gamma ∈ A` → since
`bot ∨ gamma = gamma`, `gamma ∈ A`. But the goal was to derive `bot ∈ A` specifically.
The argument needs to use the structural contradiction differently — via BX2 monotonicity
to reduce to a known-false formula and then reach contradiction via MCS inconsistency.

#### `Frame.lean` — minimal impact

The single `until_elim` use in `bx_until_eventuality_resolution` (line 690) is via
`Axiom.until_elim` (BX9), not `until_guard`. If BX9 remains sound under open guard (per
Teammate B's analysis), this proof is unchanged. Flag for verification.

#### `Construction.lean` — 0 guard dependencies

The grep found no direct `until_guard` / `since_guard` references in Construction.lean.
The `until_elim_mcs` usages referenced in the task brief likely refer to BX9 (which is
a different axiom). No archival needed.

#### `DefectChain.lean` — 0 guard dependencies

Same as Construction.lean — the file uses `until_elim` (BX9) and `since_elim` (BX9'),
not the guard axioms. These remain valid under open guard (subject to BX9 soundness review).

---

### 1.3 DELETE Without Archiving (trivial boilerplate that disappears with constructor removal)

1. All `| until_guard φ ψ => ...` match arms in SoundnessLemmas.lean (4 locations)
2. All `| since_guard φ ψ => ...` match arms in SoundnessLemmas.lean (4 locations)
3. All `| until_guard φ ψ => ...` match arms in Soundness.lean (4 locations)
4. All `| since_guard φ ψ => ...` match arms in Soundness.lean (4 locations)
5. The `| refl_intro_until` and `| refl_intro_since` stale arms in Substitution.lean
6. The `| temp_t_future` and `| temp_t_past` stale arms in Substitution.lean

These are pure routing dispatch that become compile errors when their constructors are removed.
They carry no independent content worth preserving.

---

## Section 2: Boneyard Directory Name

Following the established naming convention:
- `Boneyard/StrictSemanticsLegacy/` — 107 files archived when semantics switched to strict
- `Boneyard/OracleCoherence.lean` — oracle replacement code archived 2026-04-18

The new archive should be:

**`Theories/Bimodal/Boneyard/ClosedGuardLegacy/`**

Rationale: the current guard `[t,s)` / `(s,t]` is "half-closed" or "closed-at-t". The
direction is from closed-guard to open-guard. This mirrors `StrictSemanticsLegacy/` in
naming pattern (descriptive of what is being replaced, not what it is being replaced with).

Files to archive under `Boneyard/ClosedGuardLegacy/`:
- `ClosedGuardAxioms.lean` — the two axiom constructors `until_guard` + `since_guard` with
  their docstrings, extracted from `Axioms.lean`
- `ClosedGuardSoundness.lean` — the two validity theorems `until_guard_valid` +
  `since_guard_valid` extracted from `SoundnessLemmas.lean`
- `ClosedGuardRRelation.lean` — the two MCS-level lemmas `until_guard_in_mcs` +
  `since_guard_in_mcs` extracted from `RRelation.lean`
- `ClosedGuardTemporalDerived.lean` — the dead BX8/BX8' derived theorem chain from
  `TemporalDerived.lean` (psi_imp_until, psi_imp_since, refl_F, refl_P, and their
  dependents: or_until_imp, or_since_imp, until_unfold_wrapped, etc.)

The archive is documentation + safety net. It should compile independently if possible
(add `import` stubs to the boneyard files noting the archived axioms no longer exist in
the live system), or simply be marked with a header noting they are non-compiling artifacts
preserved for historical reference — matching the pattern in `StrictSemanticsLegacy/README.md`.

---

## Section 3: Phased Implementation Plan

The design principle: each phase ends with `lake build` passing. Phases must be strictly
sequential because Truth.lean is the foundation — touching it breaks everything simultaneously.
The strategy is therefore to first stub the affected downstream code (introduce `sorry`
placeholders where guard proofs used to be), then rebuild phase by phase.

### Phase 0: Prerequisite Audit (0 files changed, 0 new sorry)

Before making any changes:
1. Verify `lake build` currently passes (confirm baseline)
2. Run `grep -rn "until_guard\|since_guard"` to confirm all 7 affected files
3. Record the current sorry count as baseline

Estimated effort: 30 minutes. Verification: `lake build` passes, sorry count recorded.

### Phase 1: Truth.lean semantic change + Axioms.lean constructor removal

**Files changed**: `Truth.lean`, `Axioms.lean`
**Boneyard action**: Extract `until_guard`/`since_guard` constructors to
  `Boneyard/ClosedGuardLegacy/ClosedGuardAxioms.lean` before deleting from `Axioms.lean`

Steps:
1. In `Truth.lean` lines 127-130: change `t ≤ r` to `t < r` (Until), `r ≤ t` to `r < t` (Since)
2. In `Axioms.lean` lines 264-274: remove the `until_guard` and `since_guard` constructor blocks
3. Update the module docstring axiom count (37 → 35) and the Layer 3c comment block

After this phase, `Axioms.lean` and `Truth.lean` compile, but every file that pattern-matches
on `Axiom` will have missing cases. Introduce `sorry` stubs in:
- `SoundnessLemmas.lean` (remove the 8 guard match arms, replace with `| _ => sorry` stubs)
- `Soundness.lean` (remove the 8 guard match arms similarly)
- `Substitution.lean` (already broken — introduce `sorry` for all stale arms)

Verification: `lake build` passes with sorry warnings.

### Phase 2: Soundness infrastructure

**Files changed**: `SoundnessLemmas.lean`, `Soundness.lean`
**Boneyard action**: Extract `until_guard_valid` + `since_guard_valid` to
  `Boneyard/ClosedGuardLegacy/ClosedGuardSoundness.lean`

Steps:
1. Remove `until_guard_valid` and `since_guard_valid` from `SoundnessLemmas.lean`
2. Remove all 8 match arms for `until_guard`/`since_guard` from `SoundnessLemmas.lean`
3. Remove all 8 match arms from `Soundness.lean`
4. Rebuild `until_elim_valid` proof: under open guard, BX9 soundness must be re-examined.
   The current proof uses `h_guard t le_rfl hts` — this must change. The new proof must
   derive `φ(t)` by another route, or BX9 must be reformulated. (Key question for Teammate B.)
   If BX9 is reformulated, update its match arm accordingly.

Verification: `lake build` passes (all soundness match arms now exhaustive).

### Phase 3: Chronicle r-relation infrastructure

**Files changed**: `RRelation.lean`, `PointInsertion.lean`
**Boneyard action**: Extract `until_guard_in_mcs` + `since_guard_in_mcs` to
  `Boneyard/ClosedGuardLegacy/ClosedGuardRRelation.lean`

Steps:
1. Remove `until_guard_in_mcs` and `since_guard_in_mcs` from `RRelation.lean`
2. Rebuild `burgessR3Maximal_exists_from_seed`: replace Step 1 (formerly `until_guard_in_mcs`)
   with a disjunction-based argument using `until_disjunction_in_mcs` + MCS completeness
3. Rebuild `untl_absorb_nested` / `snce_absorb_nested`: replace Step 1 (guard conjunction)
   with a BX5-based derivation
4. In `PointInsertion.lean` line 673: rebuild the `h_bot` derivation without `until_guard_in_mcs`

Estimated effort: 3-4 hours (three separate proof rebuilds, each nontrivial).

Verification: `lake build` passes for Chronicle/*.lean files.

### Phase 4: TemporalDerived cleanup

**Files changed**: `TemporalDerived.lean`
**Boneyard action**: Extract dead BX8/BX8' theorem chain to
  `Boneyard/ClosedGuardLegacy/ClosedGuardTemporalDerived.lean`

Steps:
1. Remove `psi_imp_until`, `psi_imp_since` (already sorry'd as invalid)
2. Remove all theorems that depend on them: `or_until_imp`, `or_since_imp`,
   `until_unfold_wrapped`, `since_unfold_wrapped`, `until_intro`, `since_intro`,
   `until_F_expansion`, `since_P_expansion`, `G_implies_topUntil`
3. Remove `refl_F`, `refl_P` (already sorry'd as invalid under strict semantics)
4. Also remove `density_derivable` and `past_density_derivable` (already sorry'd: "requires
   density, not just BX1")

Any downstream code that called these theorems must be updated. Check with:
```
grep -rn "psi_imp_until\|psi_imp_since\|or_until_imp\|or_since_imp\|until_unfold_wrapped\|until_intro\|since_intro\|until_F_expansion\|since_P_expansion\|refl_F\|refl_P\|G_implies_topUntil\|density_derivable" Theories/Bimodal/
```

Verification: `lake build` passes, no sorry count increase (these were already sorry'd).

### Phase 5: Substitution.lean clean rebuild

**Files changed**: `Substitution.lean`

Steps:
1. Audit the full match in `Substitution.lean` against the current 35-constructor `Axiom` type
2. Remove: `refl_intro_until`, `refl_intro_since`, `temp_t_future`, `temp_t_past`,
   `until_guard`, `since_guard` arms (6 stale arms total)
3. Verify match is now exhaustive and compiles

Estimated effort: 1 hour.

Verification: `lake build` passes, Substitution.lean is sorry-free.

---

## Section 4: Risk Analysis and Dependency Map

### Critical Risk: BX9 Soundness Under Open Guard

The most significant architectural risk is BX9 (`until_elim`: `(φ U ψ) → (φ ∨ ψ)`).

Under **half-closed** guard `[t,s)`: φ holds at t (since t ∈ [t,s)), so `φ ∨ ψ` holds via Left.

Under **open** guard `(t,s)`: φ does NOT hold at t from the guard. The only guarantee is
ψ(s) at the witness. So `(φ U ψ) → (φ ∨ ψ)` requires a separate argument for φ(t), or
the axiom must be dropped/weakened to just `(φ U ψ) → F(ψ)` (which is BX10).

This affects:
- `SoundnessLemmas.lean` `until_elim_valid` / `since_elim_valid`
- `TemporalDerived.lean` `until_imp_or` / `since_imp_or` / `bot_until_id` / `bot_since_id`
- `Frame.lean` `bx_until_eventuality_resolution` (uses `Axiom.until_elim`)
- `RRelation.lean` `until_disjunction_in_mcs` / `since_disjunction_in_mcs`
- `DefectChain.lean` similar use

**Recommendation**: Teammate B must determine whether BX9 survives under open guard. If not,
BX9 must also be archived and Phases 2-3 become significantly larger. If BX9 holds under
open guard (with a different soundness proof), Phases 2-3 remain tractable.

### Secondary Risk: `until_elim` in BXCanonical canonical frame

`Frame.lean` line 690 uses `Axiom.until_elim` for eventuality resolution in `bx_until_eventuality_resolution`. This is purely a syntactic derivability use inside a MCS. If
BX9 remains a theorem (even if its soundness proof changes), this use is unaffected.

### Substitution.lean Already Broken

The current Substitution.lean references `Axiom.refl_intro_until` and `Axiom.refl_intro_since`
which do not exist in the live `Axioms.lean`. This is a pre-existing error — the file does not
compile now. Phase 5 fixes this entirely. This is an independent cleanup unrelated to the guard change.

---

## Section 5: Verification Criteria Per Phase

| Phase | Files Changed | Boneyard Created | Build Status | Sorry Delta |
|-------|--------------|-----------------|--------------|-------------|
| 0 | 0 | 0 | PASS (baseline) | 0 |
| 1 | Truth.lean, Axioms.lean | ClosedGuardAxioms.lean | PASS (stubs) | +few (stub sorries) |
| 2 | SoundnessLemmas.lean, Soundness.lean | ClosedGuardSoundness.lean | PASS | -8 arms, ±soundness |
| 3 | RRelation.lean, PointInsertion.lean | ClosedGuardRRelation.lean | PASS | -2 lemmas, rebuild 3 |
| 4 | TemporalDerived.lean | ClosedGuardTemporalDerived.lean | PASS | -9 sorry (removed) |
| 5 | Substitution.lean | none | PASS, sorry-free | 0 |

Total estimated calendar effort: 2-3 working days for an experienced Lean 4 developer.
The critical unknown is BX9 soundness under open guard (Teammate B's domain).

---

## Section 6: Non-Affected Files (Confirmed Safe)

These files were audited and have no guard-dependent code:

- `Construction.lean` — uses only BX9/BX10, no `until_guard`/`since_guard`
- `DefectChain.lean` — uses BX9/BX10 for eventuality resolution only
- `ChronicleTypes.lean` — guard comment at line 42/132 is documentation only; the live
  proof at line 554 uses `Axiom.until_elim` (BX9), not `until_guard`
- `ChronicleConstruction.lean` — no guard axiom usage
- `ChronicleToCountermodel.lean` — no guard axiom usage
- `CounterexampleElimination.lean` — no guard axiom usage
- All files in `Metalogic/BXCanonical/` outside Chronicle/ — no guard axiom usage (per grep)
- All files in `Theorems/` except `TemporalDerived.lean`

---

*Report authored by Teammate D. Date: 2026-04-27.*
