defmodule CosmicCoral.Scripting.Namespace.Builtin do
  @moduledoc """
  Bulitin module, containing builtin functions in particular."""
  """

  use CosmicCoral.Scripting.Namespace

  deffun function_Entity(script, namespace), [
    {:key, keyword: "key", type: :string, default: nil}
  ] do
    opts = [key: namespace.key]
    {:ok, entity} = CosmicCoral.Record.create_entity(opts)

    {script, entity}
  end
end
