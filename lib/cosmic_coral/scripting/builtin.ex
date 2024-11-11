defmodule CosmicCoral.Scripting.Builtin do
  @moduledoc """
  A builtin function, a callable which is always available on top-level code.
  """

  @enforce_keys [:name]
  defstruct [:name]

  alias CosmicCoral.Scripting.Builtin

  @typedoc "a builtin callable object in script"
  @type t() :: %Builtin{name: atom()}

  @doc """
  Call the builtin namespace.
  """
  def call(script, %Builtin{name: name}, args \\ []) do
    apply(__MODULE__, name, [script, args, nil])
  end

  def new_entity(script, _args, _kwargs) do
    {:ok, entity} = CosmicCoral.Record.create_entity()

    {script, entity}
  end

  @doc """
  Return the valid builtins.
  """
  def valid() do
    %{
      "Entity" => :new_entity
    }
  end
end
