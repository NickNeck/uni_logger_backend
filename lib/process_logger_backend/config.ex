defmodule ProcessLoggerBackend.Config do
  @moduledoc """
  Configuration and internal state of the `LoggerBackend`.
  """

  @enforce_keys [:name]
  defstruct level: :info, pid: nil, metadata: [], name: nil, formatter: nil
end
