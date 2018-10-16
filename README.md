# UniLoggerBackend

A logger backend that allows to log to processes or functions.

## Installation

The package can be installed by adding `uni_logger_backend` to your list of
dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:uni_logger_backend, "~> 0.1.0"}
  ]
end
```

## Using a process as target

First configure the logger to use the `UniLoggerBackend`

```elixir
# config/config.exs

config :logger, :backends, [{UniLoggerBackend, :console}]

config :logger, level: :info
```

Then configure the backend at runtime by giving a pid or process name as target:

```elixir
Logger.configure_backend({UniLoggerBackend, :console}, target: self())
```

Or provive the process name in the config:

```elixir
# config/config.exs
config :logger, :console, [target: :your_process]
```
Be aware that the process must handle two different kinds of messages. It
receives a tuple with the log level, the message, a timestamp and the metadata
in a tuple for all log messages and receives `:flush` if the logger should be
flushed.

## Using a function as target

Configure the logger to use the `UniLoggerBackend` and provide a function as
target. The function can either be given as a function reference or by passing
a tuple with a module and a function name.

```elixir
# config/config.exs

config :logger, :backends, [{UniLoggerBackend, :console}]

config :logger, :console, [level: :info, target: {YourMod, :your_fun}]
```

The function can also be given at runtime:

```elixir
Logger.configure_backend({UniLoggerBackend, :console}, target: some_fun/4)
```

Note that the arity of the function must be 4. It receives the log level, the
message, a timestamp and the metadata as arguments.

## Additional configuration

```elixir
# config/config.exs

config :logger, :console,
  level: :info,
  formatter: {YourMod, :your_fun},
  meta: [any: "thing"]
```

* Log level can be set by adding the `level` option.
* A formatter to refine log messages before forwarding can be set with the
  `formatter` option. Can be either a tuple with a module and a function name or
  a function. The function must have arity 4 and receives the leve, the message,
  the timestam and the metadata as arguments.
* Any additional metadata can be added with the `meta` option. The regular
  metadata will be merged with the given metadata before sending or formatting.

## Documentation

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/fun_logger_backend](https://hexdocs.pm/fun_logger_backend).

