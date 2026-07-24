import Bimodal.Metalogic.WeakCanonical.Kamp.EANegationFix.OnBuilder
import Bimodal.Metalogic.WeakCanonical.Kamp.EANegationFix.BoundedFix
import Bimodal.Metalogic.WeakCanonical.Kamp.EANegationFix.BoundedFixAnchored
import Bimodal.Metalogic.WeakCanonical.Kamp.EANegationFix.ConcatPin
import Bimodal.Metalogic.WeakCanonical.Kamp.EANegationFix.NegFixOne
import Bimodal.Metalogic.WeakCanonical.Kamp.EANegationFix.NegFix
import Bimodal.Metalogic.WeakCanonical.Kamp.EANegationFix.VecEANegFix

/-!
# Fixed-Formula Negation Kit: re-export shim

Thin re-export aggregator for the `Kamp/EANegationFix/` module DAG. The
negation kit formerly lived in this single file (~2,900 ln); Phase R1 split it
into leaves in linear, cycle-free import order:

`OnBuilder → BoundedFix → {BoundedFixAnchored, ConcatPin} → NegFixOne → NegFix → VecEANegFix`

- `OnBuilder.lean` — witness-combination kit + `negChainOn(_iff)` (Lemma 5.3)
- `BoundedFix.lean` — Until/Since folds + `negBounded{Right,Left}Fix(_iff)` (Cor 5.4)
- `BoundedFixAnchored.lean` — anchored mirrors `negBounded{Right,Left}FixAnchored(_iff)`
- `ConcatPin.lean` — `BracketFormula.concatPin(_holds_iff)` pin gluing (Lemma 7.6)
- `NegFixOne.lean` — `negFixOne_cover/_iff` n = 1 instance + `NegFixGateProbe` (Lemma 5.1 n=1)
- `NegFix.lean` — `BracketFormula.negFix(_iff)` general recursion (Lemma 5.1)
- `VecEANegFix.lean` — `VecEA2.negFix(_iff)` + `VVecEA2.negFix(_iff)` De Morgan
  fold (Prop 4.2/4.3, Phase 11)

Downstream consumers (`NfMultiAnchorBridge.lean`) import this shim
and are unaffected by the split. Leaves never import this shim.
-/
