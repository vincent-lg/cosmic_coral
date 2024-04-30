defmodule CosmicCoral.Scripting.Parser.Statement do
  @moduledoc """
  Parser to parse a statement.

  Grammar:
    <nested> ::= "(" <expr> ")" | <value>
    <expr>  ::= <term0> {"+" | "-" <term0>}
  """

  import NimbleParsec
  import CosmicCoral.Scripting.Parser.Constants, only: [id: 0, isolate: 1, isolate: 2]

  newline = ascii_char([?\n]) |> replace(:line) |> label("newline") |> isolate(check: false)

  equal = ascii_char([?=]) |> label("=") |> isolate(check: false)
  colon = ascii_char([?:]) |> label(":") |> replace(:":") |> isolate(check: false)
  if_kw = string("if") |> label("if") |> replace(:if) |> isolate(space: true)
  else_kw = string("else") |> label("else") |> replace(:else) |> isolate()
  while_kw = string("while") |> label("while") |> replace(:while) |> isolate(space: true)
  endif = string("endif") |> label("endif") |> replace(:endif) |> isolate()
  done = string("done") |> label("done") |> replace(:done) |> isolate()
  for_kw = string("for") |> label("for") |> replace(:for) |> isolate(space: true)
  in_kw = string("in") |> label("in") |> replace(:in) |> isolate(space: true)

  assignment =
    id()
    |> concat(ignore(equal))
    |> parsec({CosmicCoral.Scripting.Parser.Expression, :expr})
    |> reduce(:reduce_assign)
    |> label("assignment")

  defp reduce_assign([{:var, var}, value]), do: {:=, var, value}

  if_stmt =
    if_kw
    |> parsec({CosmicCoral.Scripting.Parser.Expression, :expr})
    |> ignore(colon)
    |> ignore(newline)
    |> parsec(:statement_list)
    |> optional(
      ignore(else_kw)
      |> ignore(colon)
      |> ignore(newline)
      |> parsec(:statement_list)
    )
    |> concat(endif)
    |> reduce(:reduce_if)

  def reduce_if([:if, condition, {:stmt_list, then}, :endif]), do: {:if, condition, then, nil}
  def reduce_if([:if, condition, {:stmt_list, then}, {:stmt_list, otherwise}, :endif]), do: {:if, condition, then, otherwise}

  while_stmt =
    while_kw
    |> parsec({CosmicCoral.Scripting.Parser.Expression, :expr})
    |> ignore(colon)
    |> ignore(newline)
    |> parsec(:statement_list)
    |> concat(done)
    |> reduce(:reduce_while)

  def reduce_while([:while, condition, {:stmt_list, block}, :done]), do: {:while, condition, block}

  for_stmt =
    for_kw
    |> concat(id())
    |> concat(in_kw)
    |> parsec({CosmicCoral.Scripting.Parser.Expression, :expr})
    |> ignore(colon)
    |> ignore(newline)
    |> parsec(:statement_list)
    |> concat(done)
    |> reduce(:reduce_for)

  def reduce_for([:for, {:var, variable}, :in, expression, {:stmt_list, block}, :done]) do
    {:for, variable, expression, block}
  end

  defparsecp(
    :statement_list,
    ignore(repeat(newline))
    |> parsec(:statement)
    |> repeat(
      ignore(times(newline, min: 1))
      |> parsec(:statement)
    )
    |> tag(:stmt_list)
    |> ignore(repeat(newline))
  )

  defcombinatorp(
    :statement,
    choice([
      assignment,
      if_stmt,
      while_stmt,
      for_stmt
    ])
  )

  def exec(string) do
    statement_list(string)
  end
end
