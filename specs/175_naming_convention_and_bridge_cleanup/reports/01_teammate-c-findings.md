# Teammate C Findings: Critic Analysis — Naming Cleanup Risks

**Task**: 175 — Naming convention and bridge/wrapper cleanup
**Role**: Critic (gaps, risks, blind spots)
**Date**: 2026-05-22

## Key Findings

The naming cleanup task has **high blast radius** — the most-used names (`lce_imp`: 101 refs, `rce_imp`: 92 refs, `BFMCS`: 145 refs, `FMCS`: 115 refs, `imp_trans`: 189 refs, `dni`: 50 refs) are deeply embedded in critical proof infrastructure. This is not a cosmetic rename — it requires coordinated updates across 50+ files. Task 174 (file splitting) creates a major ordering conflict.

## Build-Breaking Risks (specific examples)

### 1. Metaprogramming Hardcoded Names (HIGH RISK)

`Tactics.lean:540-553` contains a hardcoded list of axiom constructor names used in the `apply_axiom` tactic:

```lean
let axiomCtors : List Name := [
  ``Axiom.modal_t,
  ``Axiom.modal_4,
  ``Axiom.modal_b,
  ``Axiom.modal_5_collapse,
  ``Axiom.modal_k_dist,
  ``Axiom.serial_future,
  ``Axiom.serial_past,
  ``Axiom.modal_future,
  ``Axiom.prop_k,
  ``Axiom.prop_s,
  ``Axiom.ex_falso,
  ``Axiom.peirce
]
```

Also `Tactics.lean:512`: `````Bimodal.Theorems.Combinators.temp_future_derived``` is referenced by fully-qualified name. If the axiom constructors in `Axioms.lean` or theorem names in `Combinators.lean` are renamed, these ````name` references will silently fail (the tactic will not find matching constructors, producing incorrect behavior rather than a compile error).

### 2. Aesop Rule Names (MEDIUM RISK)

`AesopRules.lean` defines `@[aesop safe apply]` and `@[aesop safe forward]` rules with names like `axiom_modal_t`, `modal_t_forward`, `temp_4_forward`, `temp_a_forward`. If the underlying axiom constructors are renamed (e.g., `connect_future` instead of `temp_a`), the Aesop rules need updating. The `@[aesop]` attributes are registered by name — if the defs change but the attribute registrations aren't updated, `aesop (rule_sets [TMLogic])` silently loses rules.

### 3. String-Based Pattern Matching in SuccessPatterns (LOW RISK)

`SuccessPatterns.lean:399-404` uses string literals for strategy inference:
```lean
| .imp (.box _) _ => .Axiom "modal_t"
| .imp _ (.box (.box _)) => .Axiom "modal_4"  
| .imp (.all_future _) _ => .Axiom "temp_k"
```
These are pattern-matched on formula *structure*, not names, so they won't break. But the string labels (`"modal_t"`, `"modal_4"`) become inconsistent if the actual axiom names change.

### 4. Bridge.lean Dual Definitions (HIGH RISK)

`Bridge.lean` re-defines `lce_imp` and `rce_imp` (lines 510, 517) which already exist in `Propositional.lean` (lines 737, 755). Both are in different namespaces:
- `Bimodal.Theorems.Perpetuity.lce_imp`
- `Bimodal.Theorems.Propositional.lce_imp`

Files like `PointInsertion.lean` (100+ unqualified references) resolve these via the `open Bimodal.Metalogic.BXCanonical` namespace chain — they DON'T open `Perpetuity` directly but pick up lce_imp from a transitive import. **When Bridge.lean is removed, unqualified `lce_imp`/`rce_imp` calls must be checked to see which definition they're resolving to.** If they resolve to Bridge's version (via Perpetuity namespace), removing Bridge breaks them silently because Propositional's version may not be in scope.

### 5. Namespace Collision Risk with `and_left` / `and_right` (MEDIUM RISK)

Proposed Mathlib-style renames `lce` → `and_left`, `rce` → `and_right` risk collision with:
- `PointInsertion.lean:1193`: `private noncomputable def and_left_impl`  
- `Hierarchy.lean:2463`: `private theorem and_left_congr_hier`
- `DedekindZ.lean:691`: `private theorem and_left_congr`

Also, Lean 4 core has `And.left` and `And.right` — while these are in a different namespace, `open`-heavy code could create ambiguity.

## Automation Dependencies

### Tactics that reference specific names

| Tactic | Names Referenced | Reference Type |
|--------|-----------------|----------------|
| `apply_axiom` | All `Axiom.*` constructors | ```` `` ```` backtick names (Tactics.lean:540-553) |
| `apply_axiom` | `temp_future_derived` | ```` `` ```` backtick name (Tactics.lean:512) |
| `modal_search` | `DerivationTree.axiom`, `DerivationTree.assumption`, `DerivationTree.modus_ponens` | ```` `` ```` backtick + `mkConst` |
| `TMLogic` rules | `axiom_modal_t`, `axiom_prop_k`, etc. | `@[aesop]` attributes |
| `ProofSearch` | None — uses structural pattern matching, not name-based | Safe |
| `SuccessPatterns` | String labels like `"modal_t"` | Cosmetic only |

### simp Lemmas

18 files have `@[simp]` lemmas. Key ones in renaming scope:
- `CanonicalFrame.lean:70`: `@[simp] lemma ExistsTask_def` 
- `CanonicalFrame.lean:82`: `@[simp] lemma ExistsTask_past_def`
- These use `g_content` and `h_content` — potential rename targets

No `@[simp]` lemmas use the abbreviated names (`ecq`, `lce`, etc.) directly.

## Task Dependency Conflicts

### Task 174 (Split Oversized Files) — CRITICAL CONFLICT

Task 174 splits 9 files including:
- **Propositional.lean** (1712 lines) — where `ecq`, `raa`, `efq`, `lce`, `rce`, `ldi`, `rdi` are defined
- **Tactics.lean** (1416 lines) — where metaprogramming backtick references live
- **RestrictedMCS.lean** (1413 lines) — heavy `dni` user
- **ProofSearch.lean** (1384 lines) — automation infrastructure

**If task 174 runs FIRST**: The rename in task 175 must target the NEW split files (unknown filenames). All grep-based tooling and rename scripts must be redone.

**If task 175 runs FIRST**: Task 174's splits must account for the new names. File splitting is name-independent so this ordering is safer, but merge conflicts are likely if both have uncommitted changes.

**Recommendation**: Task 175 BEFORE task 174. Rename first, then split. This avoids having to rename across twice as many files.

### Task 168 (Parameterize DerivationTree over FrameClass) — MODERATE CONFLICT

Task 168 adds a frame class parameter to `DerivationTree`. This changes the TYPE signature of every derived theorem:
- Current: `def ecq (A B : Formula) : [A, A.neg] ⊢ B`
- After 168: `def ecq (A B : Formula) : @DerivationTree FC [A, A.neg] B` (or similar)

If 168 runs first, task 175 renames happen on the parameterized signatures. If 175 runs first, 168 must update the new names. Both orderings work, but whoever runs second has more context to load.

**Recommendation**: Either order works. Running 175 first is marginally easier since names are simpler to grep than type signatures.

## Ordering Recommendations

1. **Task 175 first** (naming cleanup), then 174 (file splitting), then 168 (parameterization)
2. Within task 175, rename in dependency order:
   - Phase 1: Core definitions (`Propositional.lean`, `Combinators.lean`) 
   - Phase 2: Bridge removal (after verifying all Bridge refs resolve to Propositional)
   - Phase 3: Metalogic abbreviations (`BFMCS`, `FMCS`, `cud_`)
   - Phase 4: Automation updates (Tactics backtick names, AesopRules)
   - Phase 5: Tests
   - Phase 6: Tombstone comment purge
3. Build after EVERY phase — do not batch renames

## Questions That Should Be Asked

1. **Should `imp_trans` be renamed?** It has 189 references and is arguably already descriptive. The blast radius is enormous. Mathlib uses `Trans.trans` — does this project want to follow that pattern?

2. **What should `BFMCS` become?** The full expansion "BundledFinitelyMaximalConsistentSet" is 41 characters. Mathlib would likely use something like `MCS.Bundle` (namespace-qualified). This needs a naming decision — it's 145 references.

3. **Should `bx_` prefix names be renamed?** Names like `bx_until_eventuality_resolution` are already descriptive. The `bx_` prefix indicates "BX axiom system" context. Is this an opaque abbreviation or a domain-specific namespace qualifier?

4. **What happens to documentation references?** The task description mentions 81 tombstone comments, but I found only ~21 matching `REMOVED|ARCHIVED|SUPERSEDED`. Were many already purged?

5. **Should `Boneyard/` code break?** Boneyard has references to `lce` (2), `rce` (4), `dni` (4). If Boneyard is dead code, breaking it is fine. But if it's referenced for historical comparison or revival, these breaks matter.

6. **Is `temp_` → `temporal_` worth the blast radius?** `temp_linearity`, `temp_4_derived`, `temp_k_dist_derived` collectively have 78+ references. The axiom constructors themselves (`Axiom.temp_linearity`, `Axiom.temp_linearity_past`) are used in pattern matching across ConservativeExtension, Lifting, and OrderedSeedConsistency. Renaming `temp_` to `temporal_` in axiom constructors propagates into every match arm.

7. **Should the duplicate `lce_imp`/`rce_imp` in Bridge vs Propositional be unified BEFORE Bridge removal?** A gradual migration (alias → replace → remove) is safer than a single-step deletion.

## Confidence Level

**High** — The risks identified are concrete (specific files, line numbers, reference counts). The blast radius numbers are exact grep counts. The metaprogramming risk in Tactics.lean is the most critical finding — backtick names fail silently when the target is renamed.
