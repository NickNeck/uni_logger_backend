defmodule ProcessLoggerBackendeTest do
  use ExUnit.Case
  require Logger

  @backend {ProcessLoggerBackende, :console}

  setup_all do
    {:ok, pid} = Logger.add_backend(@backend)
    {:ok, pid: pid}
  end

  setup do
    Logger.configure_backend(@backend, pid: self())
  end

  test "sends messages to processes referenced by name", %{test: name} do
    Process.register(self(), :test_logger_name)

    Logger.configure_backend(@backend, pid: :test_logger_name)

    Logger.error("test")
    assert_receive {:error, "test", _, _}
  end

  test "does not crash if no pid configured" do
    Logger.configure_backend(@backend, pid: nil)
    Logger.error("test")
    refute_receive _
  end

  test "does not crash if process is not found", %{pid: pid} do
    Logger.configure_backend(@backend, pid: :not_found)
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
    assert_receive {:error, "test", _, meta}

    assert [
             pid: self(),
             line: 44,
             function: "#{context.test}/1",
             module: __ENV__.module,
             file: __ENV__.file
           ] == meta
  end

  describe "logging on debug" do
    setup do
      Logger.configure_backend(@backend, pid: self(), level: :debug)
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
      Logger.configure_backend(@backend, pid: self(), level: :info)
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
      Logger.configure_backend(@backend, pid: self(), level: :warn)
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
      Logger.configure_backend(@backend, pid: self(), level: :error)
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
end
