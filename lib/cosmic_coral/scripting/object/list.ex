defmodule CosmicCoral.Scripting.Object.List do
  @moduledoc """
  Module defining the list object with its attributes and methods.
  """

  use CosmicCoral.Scripting.Object

  defmet append(script, self, reference, args, _kwargs) do
    [{value, sub_reference}] = args
    value = sub_reference || value

    Script.update_reference(script, reference, List.insert_at(self, -1, value))
  end
end
