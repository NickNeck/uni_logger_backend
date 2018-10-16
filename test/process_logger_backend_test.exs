defmodule ProcessLoggerBackendTest do
  use ExUnit.Case
  require Logger

  @backend {ProcessLoggerBackend, :console}

  setup do
    {:ok, pid} = Logger.add_backend(@backend)

    Logger.configure_backend(@backend,
      target: self(),
      formatter: nil,
      metadata: []
    )

    on_exit(fn ->
      Logger.remove_backend(@backend)
    end)

    {:ok, pid: pid}
  end

  test "sends messages to processes referenced by name" do
    Process.register(self(), :test_logger_name)

    Logger.configure_backend(@backend, target: :test_logger_name)

    Logger.error("test")
    assert_receive {:error, "test", _, _}
  end

  test "does not crash if no target configured" do
    Logger.configure_backend(@backend, target: nil)
    Logger.error("test")
    refute_receive _
  end

  test "does not crash if process is not found", %{pid: pid} do
    Logger.configure_backend(@backend, target: :not_found)
    Logger.error("test")
    refute_receive _
    assert Process.alive?(pid)
  end

  test "sends a timestamp" do
    Logger.error("test")
    assert_receive {:error, "test", {{_, _, _}, {_, _, _, _}}, _}
  end

  test "sends metadata", context do
    Logger.error("test")
    assert_receive {:error, "test", _, metadata}

    assert [
             pid: self(),
             line: 51,
             function: "#{context.test}/1",
             module: __ENV__.module,
             file: __ENV__.file
           ] == metadata
  end

  test "flush" do
    Logger.flush()
    assert_receive :flush
  end

  test "formatting messages with a function" do
    formatter = fn lvl, msg, ts, meta ->
      {lvl, msg, ts, meta}
    end

    Logger.configure_backend(@backend, formatter: formatter)

    Logger.error("test")
    assert_receive {:error, {:error, "test", ts, meta}, ts, meta}
  end

  test "if formatter raises a error backend does not crash", %{pid: pid} do
    formatter = fn _, _, _, _ ->
      raise "foo"
    end

    Logger.configure_backend(@backend, formatter: formatter)

    Logger.error("test")
    refute_receive _
    assert Process.alive?(pid)
  end

  test "formatting messages with a module and a function" do
    Logger.configure_backend(@backend, formatter: {__MODULE__, :format_msg})

    Logger.error("test")
    assert_receive {:error, {:error, "test", ts, meta}, ts, meta}
  end

  test "adds additional metadata" do
    Logger.configure_backend(@backend, metadata: [foo: "bar"])

    Logger.error("test")
    assert_receive {:error, "test", _, meta}
    assert {:foo, "bar"} in meta
  end

  test "works with functions" do
    pid = self()

    fun = fn level, msg, timestamp, meta ->
      send(pid, {:hello_fun, level, msg, timestamp, meta})
    end

    Logger.configure_backend(@backend, target: fun)
    Logger.error("test")
    assert_receive {:hello_fun, :error, "test", _, _}
  end

  test "works with modules and functions" do
    Logger.configure_backend(@backend, target: {__MODULE__, :log_handler})
    {:ok, pid} = Agent.start_link(fn -> nil end, name: :log_handler)
    Logger.error("test")
    :sys.get_state(pid)

    assert {:error, "test", _, _} =
             Agent.get(:log_handler, fn state -> state end)
  end

  describe "logging on debug" do
    setup do
      Logger.configure_backend(@backend, level: :debug)
    end

    test "receives debug msg" do
      Logger.debug("test")
      assert_receive {:debug, "test", _, _}
    end

    test "receives info msg" do
      Logger.info("test")
      assert_receive {:info, "test", _, _}
    end

    test "receives warn msg" do
      Logger.warn("test")
      assert_receive {:warn, "test", _, _}
    end

    test "receives error msg" do
      Logger.error("test")
      assert_receive {:error, "test", _, _}
    end
  end

  describe "logging on info" do
    setup do
      Logger.configure_backend(@backend, level: :info)
    end

    test "does not receive debug msg" do
      Logger.debug("test")
      refute_receive _
    end

    test "receives info msg" do
      Logger.info("test")
      assert_receive {:info, "test", _, _}
    end

    test "receives warn msg" do
      Logger.warn("test")
      assert_receive {:warn, "test", _, _}
    end

    test "receives error msg" do
      Logger.error("test")
      assert_receive {:error, "test", _, _}
    end
  end

  describe "logging on warn" do
    setup do
      Logger.configure_backend(@backend, level: :warn)
    end

    test "does not receive debug msg" do
      Logger.debug("test")
      refute_receive _
    end

    test "does not receive info msg" do
      Logger.info("test")
      refute_receive _
    end

    test "receives warn msg" do
      Logger.warn("test")
      assert_receive {:warn, "test", _, _}
    end

    test "receives error msg" do
      Logger.error("test")
      assert_receive {:error, "test", _, _}
    end
  end

  describe "logging on error" do
    setup do
      Logger.configure_backend(@backend, level: :error)
    end

    test "does not receive debug msg" do
      Logger.debug("test")
      refute_receive _
    end

    test "does not receive info msg" do
      Logger.info("test")
      refute_receive _
    end

    test "does not receive warn msg" do
      Logger.warn("test")
      refute_receive _
    end

    test "receives error msg" do
      Logger.error("test")
      assert_receive {:error, "test", _, _}
    end
  end

  def format_msg(level, msg, timestamp, meta) do
    {level, msg, timestamp, meta}
  end

  def log_handler(level, msg, timestamp, meta) do
    Agent.update(:log_handler, fn _ -> {level, msg, timestamp, meta} end)
  end
end
