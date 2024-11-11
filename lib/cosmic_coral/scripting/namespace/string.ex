defmodule CosmicCoral.Scripting.Namespace.String do
  @moduledoc """
  Module defining the string object with its attributes and methods.

  Note: in Python (and in this scripting language), strings do not have references.
  They don't hold attributes and their methods always return the modified string.
  """

  use CosmicCoral.Scripting.Namespace

  defmet lower(script, self, _args, _kwargs) do
    string = Script.get_value(script, self)

    {script, String.downcase(string)}
  end

  defmet upper(script, self, _args, _kwargs) do
    string = Script.get_value(script, self)

    {script, String.upcase(string)}
  end
end
