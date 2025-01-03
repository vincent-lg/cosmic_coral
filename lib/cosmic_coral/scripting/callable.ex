defmodule CosmicCoral.Scripting.Callable do
  @doc """
  A callable structure, representing a need to call a functio/method.
  """

  @enforce_keys [:module, :object, :name]
  defstruct [:module, :object, :name]

  alias CosmicCoral.Scripting.Callable
  alias CosmicCoral.Scripting.Interpreter.Script

  @typedoc "a callable object in script"
  @type t() :: %Callable{
          module: module(),
          object: term(),
          name: String.t()
        }

  @doc """
  Call the namespace.
  """
  def call(script, %Callable{} = callable, args \\ [], kwargs \\ %{}) do
    apply(callable.module, callable.name, find_arguments(script, callable, args, kwargs))
  end

  defp find_arguments(script, %{object: nil} = callable, args, kwargs) do
    [script, args, kwargs]
  end

  defp find_arguments(script, callable, args, kwargs) do
    [script, callable.object, args, kwargs]
  end
end
