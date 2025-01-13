defmodule Aoc2024.Common do
  @type pos() :: {non_neg_integer(), non_neg_integer()}
  @type pos_delta() :: {integer(), integer()}

  @spec pos_add(pos_delta(), pos_delta()) :: pos_delta()
  def pos_add({r1, c1}, {r2, c2}), do: {r1 + r2, c1 + c2}

  @spec pos_sub(pos_delta(), pos_delta()) :: pos_delta()
  def pos_sub({r1, c1}, {r2, c2}), do: {r1 - r2, c1 - c2}

  @spec pos_mul(pos_delta(), integer()) :: pos_delta()
  def pos_mul({r, c}, n), do: {r * n, c * n}

  @spec pos_inv(pos_delta()) :: pos_delta()
  def pos_inv({r, c}), do: {r * -1, c * -1}
end
