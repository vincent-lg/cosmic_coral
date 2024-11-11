defmodule CosmicCoral.Scripting.Callable do
  @doc """
  A callable structure, representing a need to call a functio/method.
  """

  @enforce_keys [:module, :object, :name]
  defstruct [:module, :object, :name]

  alias CosmicCoral.Scripting.Callable

  @typedoc "a callable object in script"
  @type t() :: %Callable{
                         module: module(),
                         object: term(),
                         name: String.t()
                      }

  @doc """
  Call the namespace.
  """
  def call(script, %Callable{} = callable, args \\ []) do
    apply(callable.module, callable.name, [script, callable.object, args, nil])
  end
end
