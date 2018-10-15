defmodule ProcessLoggerBackende do
  @moduledoc """
  Documentation for ProcessLoggerBackende.
  """

  @behaviour :gen_event

  @enforce_keys [:name]
  defstruct level: :info, pid: nil, meta: [], name: nil, format: nil

  def init({__MODULE__, name}) do
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
    if process_alive?(state.pid) do
      send(state.pid, :flush)
    end

    {:ok, state}
  end

  def handle_event({_level, group_leader, _info}, state)
      when node(group_leader) != node() do
    {:ok, state}
  end

  def handle_event(_, %{pid: nil} = state) do
    {:ok, state}
  end

  def handle_event({level, _, {Logger, msg, timestamp, meta}}, state) do
    with true <- should_log?(state, level),
         true <- process_alive?(state.pid),
         {:ok, msg} <- format(state.format, [level, msg, timestamp, meta]) do
      send(state.pid, {level, msg, timestamp, meta})
    end

    {:ok, state}
  end

  defp should_log?(%{level: right}, left),
    do: :lt != Logger.compare_levels(left, right)

  defp process_alive?(pid) when is_pid(pid), do: Process.alive?(pid)
  defp process_alive?(name) when is_atom(name), do: Process.whereis(name) != nil

  defp format(nil, [_, msg, _, _]), do: {:ok, msg}
  defp format({mod, fun}, args), do: do_apply(mod, fun, args)
  defp format(fun, args), do: do_apply(fun, args)

  defp do_apply(fun, args) do
    {:ok, apply(fun, args)}
  rescue
    _ -> :error
  end

  defp do_apply(mod, fun, args) do
    {:ok, apply(mod, fun, args)}
  rescue
    _ -> :error
  end

  def handle_info(_msg, state) do
    {:ok, state}
  end
end
