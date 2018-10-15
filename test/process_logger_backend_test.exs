defmodule ProcessLoggerBackendeTest do
  use ExUnit.Case
  require Logger

  @backend {ProcessLoggerBackende, :console}

  setup_all do
    {:ok, _pid} = Logger.add_backend(@backend)
    :ok
  end

  test "sends messages to processes referenced by name", %{test: name} do
    Process.register(self(), :test_logger_name)

    Logger.configure_backend(@backend, pid: :test_logger_name)

    Logger.error("test")
    assert_receive {:error, "test"}
  end

  test "does not crash if no pid configured" do
    Logger.configure_backend(@backend, pid: nil)
    Logger.error("test")
    refute_receive _
  end

  describe "logging on debug" do
    setup do
      Logger.configure_backend(@backend, pid: self(), level: :debug)
    end

    test "receives debug msg" do
      Logger.debug("test")
      assert_receive {:debug, "test"}
    end

    test "receives info msg" do
      Logger.info("test")
      assert_receive {:info, "test"}
    end

    test "receives warn msg" do
      Logger.warn("test")
      assert_receive {:warn, "test"}
    end

    test "receives error msg" do
      Logger.error("test")
      assert_receive {:error, "test"}
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
      assert_receive {:info, "test"}
    end

    test "receives warn msg" do
      Logger.warn("test")
      assert_receive {:warn, "test"}
    end

    test "receives error msg" do
      Logger.error("test")
      assert_receive {:error, "test"}
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
      assert_receive {:warn, "test"}
    end

    test "receives error msg" do
      Logger.error("test")
      assert_receive {:error, "test"}
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
      assert_receive {:error, "test"}
    end
  end
end
