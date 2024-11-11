defmodule CosmicCoral do
  @moduledoc """
  CosmicCoral keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.


  """
  import NimbleParsec

  defparsec(:t1, string("one"))
  defparsec(:t2, string("one") |> line())
  defparsec(:t3, string("two") |> tag(:two) |> line())
  defparsec(:t4, string("three") |> line() |> tag(:three))
end
