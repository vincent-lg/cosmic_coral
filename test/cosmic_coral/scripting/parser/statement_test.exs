defmodule CosmicCoral.Scripting.Parser.StatementTest do
  @moduledoc """
  Module to test that statements are properly parsed.
  """

  use CosmicCoral.ScriptingCase

  test "assigning a simple int value" do
    ast = exec_ok("value = 2")
    assert ast == {:stmt_list, [{:=, "value", 2}]}
  end

  test "assigning a simple float value" do
    ast = exec_ok("Éric = 51.4")
    assert ast == {:stmt_list, [{:=, "Éric", 51.4}]}
  end

  test "assigning an addition" do
    ast = exec_ok("value = 1 + 2")
    assert ast == {:stmt_list, [{:=, "value", {:+, [1, 2]}}]}
  end

  test "assigning a subtraction" do
    ast = exec_ok("value = 18 - 2.2")
    assert ast == {:stmt_list, [{:=, "value", {:-, [18, 2.2]}}]}
  end

  test "assigning a multiplication" do
    ast = exec_ok("Éric = -5  *    138")
    assert ast == {:stmt_list, [{:=, "Éric", {:*, [-5, 138]}}]}
  end

  test "assigning a division" do
    ast = exec_ok("value = 10/2")
    assert ast == {:stmt_list, [{:=, "value", {:/, [10, 2]}}]}
  end

  test "assigning an expressions with parents" do
    ast = exec_ok("value = (1 + 2) * 3")
    assert ast == {:stmt_list, [{:=, "value", {:*, [{:+, [1, 2]}, 3]}}]}
  end
end
