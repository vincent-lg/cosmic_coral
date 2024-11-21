defmodule CosmicCoral.Scripting.Namespace.String do
  @moduledoc """
  Module defining the string object with its attributes and methods.

  Note: in Python (and in this scripting language), strings do not have references.
  They don't hold attributes and their methods always return the modified string.
  """

  use CosmicCoral.Scripting.Namespace

  defmet center(script, namespace), [
    {:width, index: 0, type: :int},
    {:fill_char, index: 1, type: :str, default: " "}
  ] do
    {script, adjust(namespace.self, namespace.width, namespace.fill_char, :center)}
  end

  defmet ljust(script, namespace), [
    {:width, index: 0, type: :int},
    {:fill_char, index: 1, type: :str, default: " "}
  ] do
    {script, adjust(namespace.self, namespace.width, namespace.fill_char, :left)}
  end

  defmet lower(script, self, _args, _kwargs) do
    string = Script.get_value(script, self)

    {script, String.downcase(string)}
  end

  defmet lstrip(script, namespace), [
    {:chars, index: 0, type: :str, default: " \n"}
  ] do
    {script, lstrip(namespace.self, namespace.chars)}
  end

  defmet strip(script, namespace), [
    {:chars, index: 0, type: :str, default: " \n"}
  ] do
    {script, strip(namespace.self, namespace.chars)}
  end

  defmet rjust(script, namespace), [
    {:width, index: 0, type: :int},
    {:fill_char, index: 1, type: :str, default: " "}
  ] do
    {script, adjust(namespace.self, namespace.width, namespace.fill_char, :right)}
  end

  defmet rstrip(script, namespace), [
    {:chars, index: 0, type: :str, default: " \n"}
  ] do
    {script, rstrip(namespace.self, namespace.chars)}
  end

  defmet upper(script, self, _args, _kwargs) do
    string = Script.get_value(script, self)

    {script, String.upcase(string)}
  end

  # Helper functions
  defp adjust(string, width, fill_char, dir) do
    adjust(string, width, fill_char, dir, String.length(string))
  end

  defp adjust(string, width, fill, :left, cur) when cur >= width, do: string

  defp adjust(string, width, fill, :right, cur) do
    String.duplicate(fill, width - cur) <> string
  end

  defp adjust(string, width, fill, :left, cur) do
    string <> String.duplicate(fill, width - cur)
  end

  defp adjust(string, width, fill, :center, cur) do
    prefix = String.duplicate(fill, div(width - cur, 2) + rem(width - cur, 2))
    suffix = String.duplicate(fill, div(width - cur, 2))

    prefix <> string <> suffix
  end

  defp strip(string, chars) do
    string
    |> lstrip(chars)
    |> rstrip(chars)
  end

  defp lstrip(string, chars) do
    chars_set = MapSet.new(String.codepoints(chars))

    string
    |> String.codepoints()
    |> ltrim_chars(chars_set)
    |> Enum.join()
  end

  def rstrip(string, chars) do
    chars_set = MapSet.new(String.codepoints(chars))

    string
    |> String.codepoints()
    |> Enum.reverse()
    |> ltrim_chars(chars_set)
    |> Enum.reverse()
    |> Enum.join()
  end

  defp ltrim_chars([], _chars_set), do: []

  defp ltrim_chars([head | tail] = list, chars_set) do
    cond do
      MapSet.member?(chars_set, head) ->
        ltrim_chars(tail, chars_set)

      true ->
        list
    end
  end
end
