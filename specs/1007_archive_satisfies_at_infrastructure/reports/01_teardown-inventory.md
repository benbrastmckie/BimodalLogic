# Research Report: Task #1007

**Task**: Archive satisfies_at and FlagBFMCS completeness infrastructure to Boneyard
**Date**: 2026-03-20
**Focus**: Precise inventory of what to archive, preserve, and fix

## Summary

The `satisfies_at` relation in FlagBFMCSTruthLemma.lean is a custom Kripke-style satisfaction relation that is structurally different from the official `truth_at` semantics. It does not involve a duration domain D, TaskFrame, WorldHistory, task relation, or convexity. All attempts to bridge `satisfies_at` to `truth_at` have failed because: (1) the convexity obligation is provably false (scattered chain images in Rat are not convex), and (2) temporal quantification domains differ (MCS positions vs all of D). The entire FlagBFMCS completeness pipeline is self-contained with zero external consumers and can be cleanly archived.

## Findings

### Why `satisfies_at` Is Not a Legitimate Completeness Result

| Aspect | `truth_at` (official) | `satisfies_at` (FlagBFMCS) |
|--------|----------------------|---------------------------|
| Time domain | `D` — ordered abelian group | CanonicalMCS positions — preorder, no group |
| World states | `F.WorldState` via TaskFrame | MCS worlds directly — no TaskFrame |
| Atom evaluation | Domain check + valuation | Syntactic MCS membership |
| Box (□) | Quantifies over WorldHistories in Omega | Box-content inclusion between MCS positions |
| G (all_future) | All `s : D` with `t < s` — includes non-domain times | Only MCS-occupied Flag positions |
| WorldHistory | Convex domain, respects task relation | Absent entirely |

The sorry at FlagBFMCSRatBundle.lean:364 (convexity) is **mathematically false** — the comment in the source code acknowledges this: "This is false in general: the image of a discrete chain in Rat is not convex."

### Files to Archive Entirely (6 files)

All are in `Theories/Bimodal/Metalogic/Bundle/`:

| File | Lines | Sorries | Content |
|------|-------|---------|---------|
| `FlagBFMCS.lean` | ~320 | 0 | FlagBFMCS structure, canonicalFlagBFMCS, allFlagsBFMCS, accessors |
| `FlagBFMCSTruthLemma.lean` | ~400 | 0 | `satisfies_at` definition, truth lemma `satisfies_at_iff_mem` |
| `FlagBFMCSCompleteness.lean` | ~130 | 0 | `FlagBFMCS_completeness_set`, `FlagBFMCS_completeness` |
| `FlagBFMCSValidityBridge.lean` | ~250 | 1 | `algebraic_base_completeness_flagbfmcs` (sorry bridge) |
| `FlagBFMCSIntBundle.lean` | ~220 | 2 | `fmcs_from_flag` forward_G/backward_H (blocked) |
| `FlagBFMCSRatBundle.lean` | ~510 | 2 | `shiftedFlagWorldHistory` (convexity false), `shifted_truth_lemma` |

**Total**: ~1830 lines, 5 sorries (2 provably false, 3 blocked)

### Definitions to Extract Before Archiving

These are genuinely useful lemmas that happen to live in FlagBFMCS files but are about general canonical infrastructure:

#### From FlagBFMCSTruthLemma.lean (relocate to MCS theory)

1. **`g_content_propagation`** (line 96): `G(phi) in M.world` and `M < M'` implies `phi in M'.world`. Natural fact about CanonicalMCS ordering, independent of FlagBFMCS. Relocate near `canonical_forward_G` in CanonicalFrame.lean.

2. **`h_content_propagation`** (line ~110): Symmetric for H/past. Relocate near `canonical_backward_H`.

3. **`allFlags_temporally_complete`** (line 63): Every CanonicalMCS is in some Flag. Already proven independently via `canonicalMCS_in_some_flag` — this is just a wrapper. Can be dropped.

#### From FlagBFMCSRatBundle.lean (relocate to order infrastructure)

4. **`canonicalMCS_preorder_antisymm`** (line ~60): CanonicalMCS Preorder is antisymmetric. Useful for upgrading to PartialOrder.

5. **`instance : PartialOrder CanonicalMCS`** (line ~70): Important general infrastructure.

6. **`instLinearOrderChainFMCSDomain`** (line ~90): LinearOrder on ChainFMCSDomain (elements of a Flag form a linear order). Natural consequence of Flag definition.

7. **`flag_embed`** (line ~95): Order embedding ChainFMCSDomain → Rat via Cantor's theorem. Potentially useful for future approaches.

### Import Fix Required (1 file)

**`Theories/Bimodal/Metalogic/Metalogic.lean` line 5:**
```lean
import Bimodal.Metalogic.Bundle.FlagBFMCSCompleteness  -- REMOVE THIS LINE
```
This is the only external import. No other files outside the FlagBFMCS family import any of these modules. The StagedConstruction completeness pipeline is completely independent.

### Boneyard Location

Based on existing Boneyard structure:
```
Boneyard/Metalogic/Bundle/FlagBFMCSCompleteness/
  FlagBFMCS.lean
  FlagBFMCSTruthLemma.lean
  FlagBFMCSCompleteness.lean
  FlagBFMCSValidityBridge.lean
  FlagBFMCSIntBundle.lean
  FlagBFMCSRatBundle.lean
  README.md
```

The README should document:
- Why archived (satisfies_at is structurally different from truth_at)
- What was preserved (extracted lemmas with new locations)
- Date archived and related tasks (1006, 997, 988)

### Dependency Graph (No External Consumers)

```
External world
  │
  └── Metalogic.lean (line 5 import — REMOVE)
        │
        └── FlagBFMCSCompleteness.lean
              │
              ├── FlagBFMCSTruthLemma.lean (defines satisfies_at)
              │     └── FlagBFMCS.lean (structure)
              │
              ├── FlagBFMCSValidityBridge.lean (sorry bridge)
              ├── FlagBFMCSIntBundle.lean (blocked)
              └── FlagBFMCSRatBundle.lean (convexity false)
```

All upstream dependencies (ChainFMCS, CanonicalFMCS, Flags, MCS core) remain untouched.

## Recommendations

1. **Extract 4-5 reusable lemmas first** (g/h_content_propagation, PartialOrder instances) — these are simple and can also be re-derived if preferred
2. **Archive all 6 files to Boneyard** in a single operation
3. **Remove the Metalogic.lean import** — the only breaking change
4. **Run `lake build`** to verify no other breakage
5. **Add deprecation README** explaining the architectural decision

## Next Steps

Proceed to `/plan 1007` to create the implementation plan for the archival operation. This is a straightforward mechanical task with low risk.
