"""
Quantifier-free finite instantiation encoding of bimodal TM frame axioms and truth conditions.

This module implements the core Z3 encoding for bimodal TM logic:

Frame variables:
  - task_rel[w][d][u]: Bool -- task relation, true when world w reaches world u in d steps
  - atom_val[w][t][a]: Bool -- atom a is true at (world w, time t)

Histories are all functions sigma: {0,...,M-1} -> {0,...,N-1} (N^M total).
A history is valid (respects task relation) when:
  task_rel(sigma(t1), t2-t1, sigma(t2)) for all t1 < t2.

Frame axioms (quantifier-free = finite conjunction over bounded domain):
  1. nullity_identity: task_rel(w, 0, u) <-> (w == u)
  2. forward_comp: task_rel(w, d1+d2, u) <-> Or_v[task_rel(w,d1,v) and task_rel(v,d2,u)]
  3. converse: task_rel(w, -d, u) <-> task_rel(u, d, w)

Truth conditions (by constructor):
  atom(a): atom_val[history[t]][t][a]
  neg(phi): Not(truth(phi))
  and(phi, psi): And(truth(phi), truth(psi))
  or(phi, psi): Or(truth(phi), truth(psi))
  box(phi): And over all histories sigma of truth(phi, sigma, t)
  untl(phi, psi): Or over t' >= t of [truth(psi, sigma, t') and And over t'' in [t,t') of truth(phi, sigma, t'')]
  snce(phi, psi): Or over t' <= t of [truth(psi, sigma, t') and And over t'' in (t', t] of truth(phi, sigma, t'')]
"""

from __future__ import annotations
from itertools import product
from typing import Iterator

import z3

from .formula import (
    Formula, Atom, Neg, And, Or, Box, Until, Since,
)


class FrameEncoder:
    """
    Encodes a finite bimodal TM task frame for Z3.

    A frame has:
      - N worlds: {0, 1, ..., N-1}
      - M time steps: {0, 1, ..., M-1}
      - N^M histories: all functions {0,...,M-1} -> {0,...,N-1}
      - task_rel: Bool variables task_rel[w][d][u] for d in [-(M-1), M-1]
      - atom_val: Bool variables atom_val[w][t][atom_name]
    """

    def __init__(self, N: int, M: int):
        """
        Initialize encoder for N worlds and M time steps.

        Args:
            N: Number of worlds (>= 1)
            M: Number of time steps (>= 1)
        """
        assert N >= 1, "N must be >= 1"
        assert M >= 1, "M must be >= 1"
        self.N = N
        self.M = M

        # Cache for Z3 variables
        self._task_rel_vars: dict[tuple[int, int, int], z3.BoolRef] = {}
        self._atom_vars: dict[tuple[int, int, str], z3.BoolRef] = {}

        # Pre-enumerate all histories
        self._histories: list[tuple[int, ...]] = list(product(range(N), repeat=M))

    # -----------------------------------------------------------------------
    # Variable accessors
    # -----------------------------------------------------------------------

    def task_rel_var(self, w: int, d: int, u: int) -> z3.BoolRef:
        """Get or create Z3 Bool variable for task_rel(w, d, u)."""
        key = (w, d, u)
        if key not in self._task_rel_vars:
            self._task_rel_vars[key] = z3.Bool(f"rel_{w}_d{d}_{'n' if d < 0 else ''}{abs(d)}_{u}")
        return self._task_rel_vars[key]

    def atom_var(self, w: int, t: int, atom_name: str) -> z3.BoolRef:
        """Get or create Z3 Bool variable for atom_val(w, t, atom_name)."""
        key = (w, t, atom_name)
        if key not in self._atom_vars:
            safe_name = atom_name.replace("__", "").replace("-", "_")
            self._atom_vars[key] = z3.Bool(f"atom_{safe_name}_w{w}_t{t}")
        return self._atom_vars[key]

    def all_histories(self) -> list[tuple[int, ...]]:
        """Return all N^M histories as tuples of world indices."""
        return self._histories

    # -----------------------------------------------------------------------
    # Frame axiom constraints
    # -----------------------------------------------------------------------

    def nullity_identity_constraints(self) -> list[z3.BoolRef]:
        """
        Nullity/identity: task_rel(w, 0, u) iff w == u.

        This encodes: the task relation at distance 0 is the identity.
        """
        constraints = []
        for w in range(self.N):
            for u in range(self.N):
                var = self.task_rel_var(w, 0, u)
                if w == u:
                    constraints.append(var)  # task_rel(w, 0, w) = True
                else:
                    constraints.append(z3.Not(var))  # task_rel(w, 0, u) = False for w != u
        return constraints

    def forward_comp_constraints(self) -> list[z3.BoolRef]:
        """
        Forward composition: task_rel(w, d1+d2, u) iff exists v. task_rel(w, d1, v) and task_rel(v, d2, u).

        Only for d1, d2 >= 0 and d1+d2 < M (positive distances).
        """
        constraints = []
        for w in range(self.N):
            for d1 in range(self.M):
                for d2 in range(self.M):
                    d = d1 + d2
                    if d >= self.M:
                        continue  # Out of bounds, skip
                    for u in range(self.N):
                        lhs = self.task_rel_var(w, d, u)
                        # rhs = Or over v of (task_rel(w, d1, v) and task_rel(v, d2, u))
                        intermediates = [
                            z3.And(self.task_rel_var(w, d1, v), self.task_rel_var(v, d2, u))
                            for v in range(self.N)
                        ]
                        rhs = z3.Or(*intermediates) if intermediates else z3.BoolVal(False)
                        constraints.append(lhs == rhs)
        return constraints

    def converse_constraints(self) -> list[z3.BoolRef]:
        """
        Converse: task_rel(w, -d, u) iff task_rel(u, d, w).

        For d in [1, M-1] (negative distances).
        """
        constraints = []
        for w in range(self.N):
            for d in range(1, self.M):  # d >= 1
                for u in range(self.N):
                    bwd = self.task_rel_var(w, -d, u)
                    fwd = self.task_rel_var(u, d, w)
                    constraints.append(bwd == fwd)
        return constraints

    def frame_constraints(self) -> list[z3.BoolRef]:
        """Return all frame axiom constraints combined."""
        return (
            self.nullity_identity_constraints()
            + self.forward_comp_constraints()
            + self.converse_constraints()
        )

    # -----------------------------------------------------------------------
    # Truth encoding
    # -----------------------------------------------------------------------

    def truth(
        self,
        formula: Formula,
        atoms: list[str],
        sigma_idx: int,
        t: int,
    ) -> z3.BoolRef:
        """
        Encode truth of formula at (history sigma_idx, time t) as a Z3 expression.

        Args:
            formula: The formula to encode
            atoms: List of atom names used in the formula (and valuation)
            sigma_idx: Index of the history in self._histories
            t: Time step in [0, M-1]

        Returns:
            Z3 Boolean expression that is True iff the formula holds at (sigma, t)
        """
        if t < 0 or t >= self.M:
            raise ValueError(f"Time step t={t} out of range [0, {self.M-1}]")
        if sigma_idx < 0 or sigma_idx >= len(self._histories):
            raise ValueError(f"History index {sigma_idx} out of range")

        return self._truth_rec(formula, atoms, sigma_idx, t)

    def _truth_rec(
        self,
        formula: Formula,
        atoms: list[str],
        sigma_idx: int,
        t: int,
    ) -> z3.BoolRef:
        """Recursive truth encoding."""
        history = self._histories[sigma_idx]
        w = history[t]  # Current world at time t

        if isinstance(formula, Atom):
            if formula.name.startswith("__"):
                # Synthetic atoms for top/bot:
                # __bot__ is always false
                return z3.BoolVal(False)
            return self.atom_var(w, t, formula.name)

        elif isinstance(formula, Neg):
            return z3.Not(self._truth_rec(formula.inner, atoms, sigma_idx, t))

        elif isinstance(formula, And):
            return z3.And(
                self._truth_rec(formula.left, atoms, sigma_idx, t),
                self._truth_rec(formula.right, atoms, sigma_idx, t),
            )

        elif isinstance(formula, Or):
            return z3.Or(
                self._truth_rec(formula.left, atoms, sigma_idx, t),
                self._truth_rec(formula.right, atoms, sigma_idx, t),
            )

        elif isinstance(formula, Box):
            # box(phi) is true at (sigma, t) iff phi is true at (sigma', t) for ALL histories sigma'
            # Quantifier-free: finite conjunction over all N^M histories
            conjuncts = [
                self._truth_rec(formula.inner, atoms, other_sigma_idx, t)
                for other_sigma_idx in range(len(self._histories))
            ]
            return z3.And(*conjuncts) if conjuncts else z3.BoolVal(True)

        elif isinstance(formula, Until):
            # untl(phi, psi) is true at (sigma, t) iff:
            # exists t' >= t such that psi is true at (sigma, t') and
            #   for all t'' in [t, t'): phi is true at (sigma, t'')
            # Quantifier-free: finite disjunction over t' in [t, M-1]
            disjuncts = []
            for t_prime in range(t, self.M):
                # psi at t'
                psi_at_t_prime = self._truth_rec(formula.right, atoms, sigma_idx, t_prime)
                # phi for all t'' in [t, t')
                phi_conditions = [
                    self._truth_rec(formula.left, atoms, sigma_idx, t_pp)
                    for t_pp in range(t, t_prime)
                ]
                if phi_conditions:
                    disjuncts.append(z3.And(psi_at_t_prime, *phi_conditions))
                else:
                    # t' == t: just psi at t (vacuously true for phi condition)
                    disjuncts.append(psi_at_t_prime)
            return z3.Or(*disjuncts) if disjuncts else z3.BoolVal(False)

        elif isinstance(formula, Since):
            # snce(phi, psi) is true at (sigma, t) iff:
            # exists t' <= t such that psi is true at (sigma, t') and
            #   for all t'' in (t', t]: phi is true at (sigma, t'')
            # Quantifier-free: finite disjunction over t' in [0, t]
            disjuncts = []
            for t_prime in range(0, t + 1):
                # psi at t'
                psi_at_t_prime = self._truth_rec(formula.right, atoms, sigma_idx, t_prime)
                # phi for all t'' in (t', t]
                phi_conditions = [
                    self._truth_rec(formula.left, atoms, sigma_idx, t_pp)
                    for t_pp in range(t_prime + 1, t + 1)
                ]
                if phi_conditions:
                    disjuncts.append(z3.And(psi_at_t_prime, *phi_conditions))
                else:
                    # t' == t: just psi at t (vacuously true for phi condition)
                    disjuncts.append(psi_at_t_prime)
            return z3.Or(*disjuncts) if disjuncts else z3.BoolVal(False)

        else:
            raise ValueError(f"Unknown formula type: {type(formula).__name__}")

    def encode_formula(
        self,
        formula: Formula,
        atoms: list[str],
        sigma_idx: int = 0,
        t: int = 0,
    ) -> tuple[list[z3.BoolRef], z3.BoolRef]:
        """
        Build the full Z3 assertion set for finding a countermodel.

        Returns:
            (frame_constraints, negated_formula_truth)
            where frame_constraints should be added to solver and
            negated_formula_truth = Not(truth(formula, sigma_idx, t))
        """
        frame_cs = self.frame_constraints()
        negated = z3.Not(self.truth(formula, atoms, sigma_idx, t))
        return frame_cs, negated
