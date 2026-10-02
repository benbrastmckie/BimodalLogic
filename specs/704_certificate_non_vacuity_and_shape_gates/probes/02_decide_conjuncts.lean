/-
Probe 704 (research round 1): per-conjunct `#eval` readout of `Certifies` at the embedded
snce probe family, plus closure/width/liveness readouts at the embedded live family.
Same stale-build caveat as 01_decide_sliced_inhabitant.lean. Lines 17-18 and 22 of the
original scratch were mis-qualified and error out; they are kept verbatim as run.
-/
import FormalSystem
open FormalSystem.Metalogic.Decidability
open FormalSystem.Metalogic.Decidability.WitnessFamily

-- which conjunct of Certifies fails at the snce probe family's embedding?
#eval decide (SnceProbe.snceProbeLiveFamily.sliced 0).BiSerial
#eval decide (SnceProbe.snceProbeLiveFamily.sliced 0).TailStable
#eval decide (SnceProbe.snceProbeLiveFamily.sliced 0).BoxLabelFaithful
#eval decide ((SnceProbe.snceProbeLiveFamily.sliced 0).targetTime ∈ (SnceProbe.snceProbeLiveFamily.sliced 0).winTimes)
#eval decide (SnceProbe.snceProbeLiveFamily.sliced 0).TargetPathPos
#eval decide ((SnceProbe.snceProbeLiveFamily.sliced 0).targetPos (SnceProbe.snceProbeLiveFamily.sliced 0).targetTime ∈ (SnceProbe.snceProbeLiveFamily.sliced 0).liveAt (SnceProbe.snceProbeLiveFamily.sliced 0).targetTime)
#eval decide (SnceProbe.snceProbeLiveFamily.sliced 0).StabFaithful
#eval decide (SnceProbe.snceProbeLiveFamily.sliced 0).BoxLiveFaithful
#eval decide (SnceProbe.snceProbeLiveFamily.sliced 0).Target
-- other landed families, embedded
#eval decide (SnceProbe.snceProbeLiveFamily.sliced 1).Certifies
#eval decide (BotTargets.botUntlFamily.sliced 0).Certifies
#eval decide (BotTargets.botSnceFamily.sliced 0).Certifies
#eval decide (Embedded.emptyFamily.sliced 0).Certifies
#eval decide (Embedded.liveFamily.sliced (-1)).Certifies
-- closure sizes (degeneracy check)
#eval (plusClosureOf (([] : PlusContext) ++ [FormalSystem.PlusLanguage.ofFormula Embedded.evTarget])).card
#eval (Embedded.liveFamily.sliced (-1)).n
#eval (Embedded.liveFamily.sliced (-1)).winTimes.card
