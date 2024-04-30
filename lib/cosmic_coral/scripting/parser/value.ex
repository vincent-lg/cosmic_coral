defmodule CosmicCoral.Scripting.Parser.Value do
  @moduledoc """
  Parser used to parse a value.

  Grammar:
    <value>      ::= <globals> | <number> | <id_value> | <str>
    <globals>  ::= "true" | "false"
    <number>   ::= <int> | <float>
    <int>      ::= ["-"]<digit>{<digit>}
    <float>    ::= ["-"]<digit>{<digit>}"."<digit>{<digit>}
    <id>       ::= <letter> {<letter> | <valid_ct>}
    <id_value> ::= ["-"]<id>
    <str>      ::= <single> | <double>
    <single>   ::= "'" <any letter> "'"
    <double>   ::= """ <any letter> """
    <digit>    ::= "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9"
    <letter>   ::= (utf-8 letter)
    <valid_Ct> ::= (utf-8 coutinuation)

  Note: this is NOT to be used to parse an expression (see
  `CosmicCoral.Scripting.Parser.Expression`).
  """

  import NimbleParsec

  import CosmicCoral.Scripting.Parser.Constants, only: [id: 0, isolate: 1]

  globals =
    choice([
      string("true") |> replace(true),
      string("false") |> replace(false),
    ])
    |> isolate()
    |> label("global name")

  digits =
    ascii_string([?0..?9], min: 1)
    |> label("digits")

  int =
    optional(string("-"))
    |> concat(digits)
    |> isolate()
    |> reduce(:to_integer)
    |> label("integer")

  defp to_integer(acc), do: acc |> Enum.join() |> String.to_integer(10)

  float =
    optional(string("-"))
    |> concat(digits)
    |> ascii_string([?.], 1)
    |> concat(digits)
    |> isolate()
    |> reduce(:to_float)
    |> label("float")

  defp to_float(acc), do: acc |> Enum.join() |> String.to_float()

  number =
    choice([float, int])
    |> label("number")

  str_single =
    ignore(ascii_char([?']))
    |> repeat_while(
      utf8_char([{:not, ?\n}]),
      {CosmicCoral.Scripting.Parser.String, :handle_single, []}
    )
    |> ignore(ascii_char([?']))
    |> reduce({List, :to_string, []})
    |> post_traverse({CosmicCoral.Scripting.Parser.String, :process, []})
    |> label("string")
    |> isolate()

  str_double =
    ignore(ascii_char([?"]))
    |> repeat_while(
      utf8_char([{:not, ?\n}]),
      {CosmicCoral.Scripting.Parser.String, :handle_double, []}
    )
    |> ignore(ascii_char([?"]))
    |> reduce({List, :to_string, []})
    |> post_traverse({CosmicCoral.Scripting.Parser.String, :process, []})
    |> label("string")
    |> isolate()

  str =
    choice([str_single, str_double])
    |> label("string")

  id_value =
    choice([
      ignore(string("-")) |> concat(id()) |> tag(:neg),
      id()
    ])
    |> label("variable")

  defcombinator(
    :value,
    choice([globals, number, id_value, str])
  )
end
