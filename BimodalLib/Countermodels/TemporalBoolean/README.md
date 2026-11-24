# TemporalBoolean

Refuted inferences whose operators are temporal and no modal operator appears. One file per
frame class the model lives at.

| Path | Description |
|------|-------------|
| `ZTime.lean` | Models at the integer-time class. Each row is a documented constant of type `CountermodelEntry Formula` |
| `RTime.lean` | Models at the real-time class. Both rows are `RTime`-maximal: each inference is a `ZTime` principle, valid there and refuted here |
| `Dense.lean` | Models at the dense class. Both rows are `Dense`-maximal: each inference is an `RTime` principle, valid there and refuted here |

*Last verified: 2026-11-24*
