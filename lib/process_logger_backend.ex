defmodule ProcessLoggerBackende do
  @moduledoc """
  Documentation for ProcessLoggerBackende.
  """

  @behaviour :gen_event

  @enforce_keys [:name]
  defstruct level: :info, pid: nil, meta: [], name: nil

  def init({__MODULE__, name} = opts) do
    {:ok, configure(name, [])}
  end

  def handle_call({:configure, opts}, %{name: name}) do
    {:ok, :ok, configure(name, opts)}
  end

  defp configure(name, opts) do
    applied_opts =
      :logger
      |> Application.get_env(name, [])
      |> Keyword.merge(opts)
      |> Keyword.put(:name, name)

    Application.put_env(:logger, name, applied_opts)

    struct!(__MODULE__, applied_opts)
  end

  def handle_event(:flush, state) do
    {:ok, state}
  end

  def handle_event({_level, group_leader, _info}, state)
      when node(group_leader) != node() do
    {:ok, state}
  end

  def handle_event(_, %{pid: nil} = state) do
    {:ok, state}
  end

  def handle_event({level, group_leader, {Logger, msg, timestamp, meta}}, state) do
    with res when res != :lt <- Logger.compare_levels(level, state.level),
         true <- process_alive?(state.pid) do
      send(state.pid, {level, msg, timestamp, meta})
    end

    {:ok, state}
  end

  defp process_alive?(pid) when is_pid(pid), do: Process.alive?(pid)
  defp process_alive?(name) when is_atom(name), do: Process.whereis(name) != nil

  def handle_info(_msg, state) do
    {:ok, state}
  end
end
