defmodule CosmicCoral.Scripting.Interpreter.AST do
  @moduledoc """
  A module to convert an Abstract-Syntax Tree (AST) into a script structure.
  """

  alias CosmicCoral.Scripting.Interpreter.Script

  @doc """
  Convert an AST into a script structure with its bytecode.
  """
  @spec convert(list()) :: Script.t()
  def convert(ast) do
    bytecode =
      ast
      |> Enum.reduce(:queue.new, &process_ast/2)
      |> :queue.to_list()

    %Script{bytecode: bytecode}
  end

  defp process_ast(ast, code) do
    read_ast(code, ast)
  end

  defp read_ast(code, global) when global in [true, false] do
    code
    |> add({:put, global})
  end

  defp read_ast(code, num) when is_number(num) do
    code
    |> add({:put, num})
  end

  defp read_ast(code, str) when is_binary(str) do
    code
    |> add({:put, str})
  end

  defp read_ast(code, seq) when is_list(seq) do
    Enum.reduce(seq, code, fn element, code -> read_ast(code, element) end)
    |> add({:list, length(seq)})
  end

  defp read_ast(code, {:var, var}) when is_binary(var) do
    code
    |> add({:read, var})
  end

  defp read_ast(code, {op, [left, right]}) when op in [:+, :-, :*, :/] do
    code
    |> read_ast(left)
    |> read_ast(right)
    |> add(op)
  end

  defp read_ast(code, {cmp, [left, right]}) when cmp in [:<, :<=, :>, :>=, :==, :!=] do
    ref = make_ref()

    Enum.reduce([left, right], code, fn part, code ->
      case part do
        {cmp, [_left_part, right_part]} when cmp in [:<, :<=, :>, :>=, :==, :!=] ->
          code
          |> read_ast(part)
          |> add({:unset, ref})
          |> read_ast(right_part)

        _ ->
          code
          |> read_ast(part)
      end
    end)
    |> add(cmp)
    |> replace({:unset, ref}, fn code -> {:iffalse, length_code(code)} end)
  end

  defp read_ast(code, {:and, [left, right]}) do
    ref = make_ref()

    code
    |> read_ast(left)
    |> add({:unset, ref})
    |> read_ast(right)
    |> replace({:unset, ref}, fn code -> {:iffalse, length_code(code)} end)
  end

  defp read_ast(code, {:or, [left, right]}) do
    ref = make_ref()

    code
    |> read_ast(left)
    |> add({:unset, ref})
    |> read_ast(right)
    |> replace({:unset, ref}, fn code -> {:iftrue, length_code(code)} end)
  end

  defp read_ast(code, {:not, [ast]}) do
    code
    |> read_ast(ast)
    |> add(:not)
  end

  defp read_ast(code, {:stmt_list, statements}) when is_list(statements) do
    Enum.reduce(statements, code, fn statement, code ->
      read_ast(code, statement)
    end)
  end

  defp read_ast(code, {:=, variable, value}) do
    code
    |> read_ast(value)
    |> add({:store, variable})
  end

  defp read_ast(code, {:if, condition, then, nil}) do
    end_block = make_ref()

    code
    |> read_ast(condition)
    |> add({:unset, end_block})
    |> read_asts(then)
    |> replace({:unset, end_block}, fn code -> {:popiffalse, length_code(code)} end)
  end

  defp read_ast(code, {:if, condition, then, otherwise}) do
    else_block = make_ref()
    end_block = make_ref()

    code
    |> read_ast(condition)
    |> add({:unset, else_block})
    |> read_asts(then)
    |> add({:unset, end_block})
    |> replace({:unset, else_block}, fn code -> {:popiffalse, length_code(code)} end)
    |> read_asts(otherwise)
    |> replace({:unset, end_block}, fn code -> {:goto, length_code(code)} end)
  end

  defp read_ast(code, {:while, condition, block}) do
    before = length_code(code)
    end_block = make_ref()

    code
    |> read_ast(condition)
    |> add({:unset, end_block})
    |> read_asts(block)
    |> add({:goto, before})
    |> replace({:unset, end_block}, fn code -> {:popiffalse, length_code(code)} end)
  end

  defp read_ast(code, {:for, variable, iterate, block}) do
    code =
      code
      |> read_ast(iterate)
      |> add(:mkiter)

    before = length_code(code)
    end_block = make_ref()

    code
    |> add({:unset, end_block})
    |> add({:store, variable})
    |> read_asts(block)
    |> add({:goto, before})
    |> replace({:unset, end_block}, fn code -> {:iter, length_code(code)} end)
  end

  defp read_ast(_code, unknown) do
    raise "unknown AST portion: #{inspect(unknown)}"
  end

  def read_asts(code, asts) do
    Enum.reduce(asts, code, fn ast, code -> read_ast(code, ast) end)
  end

  defp length_code(code) do
    :queue.len(code)
  end

  defp add(code, value) do
    :queue.in(value, code)
  end

  defp replace(code, what, by) do
    :queue.filtermap(fn bytecode ->
      case bytecode do
        ^what -> {true, by.(code)}
        _ -> true
      end
    end, code)
  end
end
