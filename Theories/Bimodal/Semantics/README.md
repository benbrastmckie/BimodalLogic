# Semantics

Task frame semantics for TM bimodal logic.

## Contents

| File | Description |
|------|-------------|
| TaskFrame.lean | Task frame structure (worlds, times, accessibility) |
| TaskModel.lean | Task models with valuation functions |
| WorldHistory.lean | World histories for temporal evaluation |
| Truth.lean | Truth relation for formula evaluation |
| Validity.lean | Validity and semantic consequence |

## Key Definitions

- `TaskFrame`: Frame structure with world-time pairs and accessibility
- `TaskModel`: Frame with valuation function for atoms
- `WorldHistory`: Infinite sequence of worlds indexed by time
- `truth_at`: Truth of formula at world-history and time
- `valid`: Formula true in all models at all world-histories

## Related Documentation

- [Parent README](../README.md)
- [Metalogic/Soundness](../Metalogic/Soundness/README.md) - Uses semantics for soundness

---

*Last Updated: 2026-03-16*
