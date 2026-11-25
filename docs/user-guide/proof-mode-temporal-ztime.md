# Adjacent temporal steps

| Command | Obligations |
| --- | --- |
| `luntil contract`, `lsince contract` | `X e ∨ X(g ∧ U g e)` or the Y/S mirror |
| `luntil expand h as he hc`, `lsince expand h as he hc` | Both one-step branches proving the same conclusion |
| `linduction future` or `past` | Discrete backward induction with its persistent step and eventual base |

Contraction works in any frame class. Expansion, `lstep`, invariance and backward
induction reuse an exact local `FrameClass.ZTime ≤ fc` certificate or decide a concrete
frame class. An abstract certificate becomes an explicit goal.

[Derivation proof mode](derivation-proof-mode.md)
