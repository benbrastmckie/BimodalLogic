"""
StructuredCountermodel data structure and Z3 model extraction.

A StructuredCountermodel encodes:
  - n_worlds: number of world states (N)
  - m_steps: number of time steps (M)
  - worlds: list of world state indices [0..N-1]
  - task_rel: dict mapping (w, d, u) -> bool for task relation
  - histories: list of histories (each is a list of N^M world indices)
  - valuation: dict mapping (w, t, atom_name) -> bool
  - falsifying_history: index of the history that falsifies the formula
  - falsifying_time: time step where formula is false

This module is fully implemented in Phase 3.
"""

from __future__ import annotations
from dataclasses import dataclass, field
from typing import Optional, TYPE_CHECKING
import json

if TYPE_CHECKING:
    from .encoding import FrameEncoder
    from .formula import Formula


@dataclass
class StructuredCountermodel:
    """
    A structured countermodel for a bimodal TM formula.

    Represents a finite task frame with:
      - N worlds and M time steps
      - Task relation task_rel(w, d, u) encoding accessibility
      - All N^M histories (shift-closed by construction)
      - Atom valuation at each (world, time) pair
      - A specific (history, time) pair where the formula is false
    """
    n_worlds: int
    m_steps: int
    worlds: list[int]
    task_rel: dict  # (w: int, d: int, u: int) -> bool, d in range(-m_steps+1, m_steps)
    histories: list[list[int]]  # Each history: list of world indices, length m_steps
    valuation: dict  # (w: int, t: int, atom_name: str) -> bool
    falsifying_history: int  # Index into self.histories
    falsifying_time: int  # Time step in [0, m_steps-1]

    def to_json(self) -> dict:
        """Serialize to JSON-compatible dict."""
        return {
            "n_worlds": self.n_worlds,
            "m_steps": self.m_steps,
            "worlds": self.worlds,
            "task_rel": [
                {"w": k[0], "d": k[1], "u": k[2], "val": v}
                for k, v in self.task_rel.items()
                if v  # Only store True entries for compactness
            ],
            "histories": self.histories,
            "valuation": [
                {"w": k[0], "t": k[1], "atom": k[2], "val": v}
                for k, v in self.valuation.items()
                if v  # Only store True entries for compactness
            ],
            "falsifying_history": self.falsifying_history,
            "falsifying_time": self.falsifying_time,
        }

    @classmethod
    def from_json(cls, data: dict) -> "StructuredCountermodel":
        """Deserialize from JSON-compatible dict."""
        task_rel = {}
        for entry in data.get("task_rel", []):
            task_rel[(entry["w"], entry["d"], entry["u"])] = entry["val"]

        valuation = {}
        for entry in data.get("valuation", []):
            valuation[(entry["w"], entry["t"], entry["atom"])] = entry["val"]

        return cls(
            n_worlds=data["n_worlds"],
            m_steps=data["m_steps"],
            worlds=data["worlds"],
            task_rel=task_rel,
            histories=data["histories"],
            valuation=valuation,
            falsifying_history=data["falsifying_history"],
            falsifying_time=data["falsifying_time"],
        )

    def validate(self) -> list[str]:
        """
        Validate that the countermodel satisfies frame axioms.
        Returns a list of violation strings (empty if valid).
        """
        errors = []
        N = self.n_worlds
        M = self.m_steps

        def rel(w, d, u) -> bool:
            return self.task_rel.get((w, d, u), False)

        # Nullity/identity: task_rel(w, 0, u) iff w == u
        for w in range(N):
            for u in range(N):
                expected = (w == u)
                actual = rel(w, 0, u)
                if actual != expected:
                    errors.append(
                        f"nullity_identity violation: task_rel({w}, 0, {u}) = {actual}, expected {expected}"
                    )

        # Forward composition: task_rel(w, d1+d2, u) iff exists v. task_rel(w, d1, v) and task_rel(v, d2, u)
        for w in range(N):
            for d1 in range(0, M):
                for d2 in range(0, M):
                    if d1 + d2 >= M:
                        continue
                    for u in range(N):
                        actual = rel(w, d1 + d2, u)
                        expected = any(rel(w, d1, v) and rel(v, d2, u) for v in range(N))
                        if actual != expected:
                            errors.append(
                                f"forward_comp violation: task_rel({w}, {d1+d2}, {u}) = {actual}, "
                                f"expected {expected} (d1={d1}, d2={d2})"
                            )

        # Converse: task_rel(w, -d, u) iff task_rel(u, d, w)
        for w in range(N):
            for d in range(1, M):
                for u in range(N):
                    fwd = rel(u, d, w)
                    bwd = rel(w, -d, u)
                    if fwd != bwd:
                        errors.append(
                            f"converse violation: task_rel({w}, -{d}, {u}) = {bwd}, "
                            f"expected {fwd} (= task_rel({u}, {d}, {w}))"
                        )

        # Histories respect task relation
        for sigma_idx, history in enumerate(self.histories):
            if len(history) != M:
                errors.append(f"History {sigma_idx} has length {len(history)}, expected {M}")
                continue
            for t1 in range(M):
                for t2 in range(t1 + 1, min(t1 + M, M)):
                    d = t2 - t1
                    w = history[t1]
                    u = history[t2]
                    if not rel(w, d, u):
                        errors.append(
                            f"History {sigma_idx} violates task_rel: "
                            f"history[{t1}]={w} -> history[{t2}]={u} "
                            f"but task_rel({w}, {d}, {u}) = False"
                        )

        return errors


def extract_countermodel(
    model,  # z3.ModelRef
    encoder: "FrameEncoder",
    formula: "Formula",
    atoms: list[str],
    falsifying_history: int,
    falsifying_time: int,
) -> StructuredCountermodel:
    """
    Extract a StructuredCountermodel from a Z3 satisfying model.

    Args:
        model: Z3 ModelRef from solver.model()
        encoder: The FrameEncoder used to build the encoding
        formula: The formula that was falsified
        atoms: List of atom names used in the encoding
        falsifying_history: Index of the history where formula is false
        falsifying_time: Time step where formula is false

    Returns:
        StructuredCountermodel with all frame data extracted
    """
    import z3

    N = encoder.N
    M = encoder.M

    def get_bool(z3_expr) -> bool:
        """Evaluate a Z3 Boolean expression in the model."""
        val = model.evaluate(z3_expr, model_completion=True)
        return z3.is_true(val)

    # Extract task_rel
    task_rel = {}
    for w in range(N):
        for d in range(-(M-1), M):  # d in range [-(M-1), M-1]
            for u in range(N):
                task_rel_var = encoder.task_rel_var(w, d, u)
                task_rel[(w, d, u)] = get_bool(task_rel_var)

    # Extract atom valuation
    valuation = {}
    for w in range(N):
        for t in range(M):
            for atom_name in atoms:
                atom_var = encoder.atom_var(w, t, atom_name)
                valuation[(w, t, atom_name)] = get_bool(atom_var)

    # Extract histories -- only include those that respect the task_rel
    # A history sigma respects task_rel when task_rel(sigma(t1), t2-t1, sigma(t2)) for all t1 < t2
    histories = []
    all_histories = list(encoder.all_histories())
    falsifying_history_in_filtered = 0  # Will be updated below

    for sigma_i, history in enumerate(all_histories):
        valid = True
        for t1 in range(M):
            for t2 in range(t1 + 1, M):
                d = t2 - t1
                w = history[t1]
                u = history[t2]
                if not task_rel.get((w, d, u), False):
                    valid = False
                    break
            if not valid:
                break
        if valid:
            if sigma_i == falsifying_history:
                falsifying_history_in_filtered = len(histories)
            histories.append(list(history))

    # If no valid histories were found (or the falsifying history is not in them),
    # include all histories and use the original index as fallback
    if not histories:
        histories = [list(h) for h in all_histories]
        falsifying_history_in_filtered = falsifying_history

    worlds = list(range(N))

    return StructuredCountermodel(
        n_worlds=N,
        m_steps=M,
        worlds=worlds,
        task_rel=task_rel,
        histories=histories,
        valuation=valuation,
        falsifying_history=falsifying_history_in_filtered,
        falsifying_time=falsifying_time,
    )
