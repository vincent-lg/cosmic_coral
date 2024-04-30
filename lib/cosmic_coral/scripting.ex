defmodule CosmicCoral.Scripting do
  @moduledoc """
  Scripting module, a higher-level module to manipulate scripts.

  This module groups the parser and interpreter together.
  It is designed to parse a string, generate AST, bytecode and execute
  the script.
  """

  alias CosmicCoral.Scripting.{Interpreter, Parser}

  @doc """
  Executes the given instructions and returns a script structure.

  This function will parse the given string and turn it into an
  Abstract Syntax Tree (AST), turn the AST into bytecode and
  execute this bytecode, returning the executed script.
  """
  @spec run(binary()) :: {:ok, Interpreter.Script.t()} | {:error, term()}
  def run(code, debug \\ false) do
    {:ok, ast} = Parser.exec(code)

    script =
      [ast]
      |> Interpreter.AST.convert()

    ((debug && %{script | debugger: Interpreter.Debugger.new()}) || script)
    |> Interpreter.Script.execute()
  end
end
