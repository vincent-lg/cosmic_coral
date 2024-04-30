defmodule CosmicCoral.Scripting.Parser.GlobalsTest do
  @moduledoc """
  Module to test that globals are properly parsed.
  """

  use CosmicCoral.ScriptingCase

  test "true should parse" do
    ast = eval_ok("true")
    assert ast == true
  end

  test "false should parse" do
    ast = eval_ok("false")
    assert ast == false
  end
end
