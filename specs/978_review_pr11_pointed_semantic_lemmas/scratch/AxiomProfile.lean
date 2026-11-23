/- Scratch: axiom profile of every theorem PR #11 adds. Not part of the library. -/
import FormalSystem.Semantics.TemporalRules
import FormalSystem.Semantics.TemporalIntervals
import FormalSystem.Semantics.RankProgress
import FormalSystem.Semantics.PointTransport

open FormalSystem.Semantics

-- TemporalRules
#print axioms FormalSystem.Semantics.TemporalRules.next_iff
#print axioms FormalSystem.Semantics.TemporalRules.prev_iff
#print axioms FormalSystem.Semantics.TemporalRules.next_at
#print axioms FormalSystem.Semantics.TemporalRules.prev_at
#print axioms FormalSystem.Semantics.TemporalRules.allFuture_persist
#print axioms FormalSystem.Semantics.TemporalRules.allPast_persist
#print axioms FormalSystem.Semantics.TemporalRules.someFuture_bind
#print axioms FormalSystem.Semantics.TemporalRules.someFuture_bind_keeping
#print axioms FormalSystem.Semantics.TemporalRules.somePast_bind
#print axioms FormalSystem.Semantics.TemporalRules.somePast_bind_keeping

-- TemporalIntervals
#print axioms FormalSystem.Semantics.TemporalIntervals.inclusiveUntil_iff
#print axioms FormalSystem.Semantics.TemporalIntervals.inclusiveSince_iff
#print axioms FormalSystem.Semantics.TemporalIntervals.release_iff
#print axioms FormalSystem.Semantics.TemporalIntervals.trigger_iff
#print axioms FormalSystem.Semantics.TemporalIntervals.weakUntil_iff
#print axioms FormalSystem.Semantics.TemporalIntervals.weakSince_iff

-- RankProgress
#print axioms FormalSystem.Semantics.RankProgress.rank_progress
#print axioms FormalSystem.Semantics.RankProgress.rank_progress_strict
#print axioms FormalSystem.Semantics.RankProgress.rank_progress_truth
#print axioms FormalSystem.Semantics.RankProgress.rank_progress_truth_strict

-- PointTransport: structural API
#print axioms FormalSystem.Semantics.PointTransport.FactTransport.apply
#print axioms FormalSystem.Semantics.PointTransport.GoalTransport.reduce
#print axioms FormalSystem.Semantics.PointTransport.FactTransport.ofIff
#print axioms FormalSystem.Semantics.PointTransport.GoalTransport.ofIff
#print axioms FormalSystem.Semantics.PointTransport.FactTransport.trans
#print axioms FormalSystem.Semantics.PointTransport.GoalTransport.trans
#print axioms FormalSystem.Semantics.PointTransport.IffTransport.apply
#print axioms FormalSystem.Semantics.PointTransport.IffTransport.fact
#print axioms FormalSystem.Semantics.PointTransport.IffTransport.goal
#print axioms FormalSystem.Semantics.PointTransport.IffTransport.symm
#print axioms FormalSystem.Semantics.PointTransport.SameStateNow.intro
#print axioms FormalSystem.Semantics.PointTransport.SameState.intro
#print axioms FormalSystem.Semantics.PointTransport.AnyPoint.intro
#print axioms FormalSystem.Semantics.PointTransport.Shifted.intro
#print axioms FormalSystem.Semantics.PointTransport.Reflected.intro
#print axioms FormalSystem.Semantics.PointTransport.CorrRel.intro
#print axioms FormalSystem.Semantics.PointTransport.IsoRel.intro
#print axioms FormalSystem.Semantics.PointTransport.AntiIsoRel.intro
#print axioms FormalSystem.Semantics.PointTransport.MorphRel.intro

-- PointTransport: the factories
#print axioms FormalSystem.Semantics.PointTransport.iffTransport_truthCorr
#print axioms FormalSystem.Semantics.PointTransport.iffTransport_truthIso
#print axioms FormalSystem.Semantics.PointTransport.iffTransport_truthAntiIso
#print axioms FormalSystem.Semantics.PointTransport.iffTransport_timeShift
#print axioms FormalSystem.Semantics.PointTransport.iffTransport_rev
#print axioms FormalSystem.Semantics.PointTransport.iffTransport_box
#print axioms FormalSystem.Semantics.PointTransport.plus_iffTransport_timeShift
#print axioms FormalSystem.Semantics.PointTransport.plus_iffTransport_rev
#print axioms FormalSystem.Semantics.PointTransport.plus_iffTransport_box
#print axioms FormalSystem.Semantics.PointTransport.plus_iffTransport_stab
#print axioms FormalSystem.Semantics.PointTransport.plus_iffTransport_stateLocal
#print axioms FormalSystem.Semantics.PointTransport.plus_iffTransport_stateLocalStab
#print axioms FormalSystem.Semantics.PointTransport.plus_iffTransport_histMorphism
