defmodule CosmicCoral.Scripting.StringTest do
  @moduledoc """
  Module to test the string API.
  """

  use CosmicCoral.ScriptingCase

  describe "lower" do
    test "affectation of lower on ASCCII letters" do
      script =
        run("""
        s = "THIS".lower()
        """)

      assert Script.get_variable_value(script, "s") == "this"
    end

    test "a string with only uppercase ASCII letters" do
      script =
        run("""
        s = "THIS"
        s = s.lower()
        """)

      assert Script.get_variable_value(script, "s") == "this"
    end

    test "a string with ASCII uppercase and lowercase letters" do
      script =
        run("""
        s = "ThaT"
        s = s.lower()
        """)

      assert Script.get_variable_value(script, "s") == "that"
    end

    test "a string with ASCII uppercase and lowercase letters and other characters" do
      script =
        run("""
        s = " It SHould WorK="
        s = s.lower()
        """)

      assert Script.get_variable_value(script, "s") == " it should work="
    end

    test "a string with only uppercase non-ASCII letters" do
      script =
        run("""
        s = "OLÁ"
        s = s.lower()
        """)

      assert Script.get_variable_value(script, "s") == "olá"
    end

    test "a string with non-ASCII uppercase and lowercase letters" do
      script =
        run("""
        s = "ÉRic"
        s = s.lower()
        """)

      assert Script.get_variable_value(script, "s") == "éric"
    end

    test "a string with non-ASCII uppercase and lowercase letters and other characters" do
      script =
        run("""
        s = ' rÜCKSIcHTSLOS-'
        s = s.lower()
        """)

      assert Script.get_variable_value(script, "s") == " rücksichtslos-"
    end
  end

  describe "lstrip" do
    test "left-stripping spaces from ASCII characters" do
      script =
        run("""
        s = "  this ".lstrip()
        """)

      assert Script.get_variable_value(script, "s") == "this "
    end

    test "left-stripping one delimiter from ASCII characters" do
      script =
        run("""
        s = ";;this;".lstrip(";")
        """)

      assert Script.get_variable_value(script, "s") == "this;"
    end

    test "left-stripping delimiters from ASCII characters" do
      script =
        run("""
        s = ";-;this-;".lstrip("-;")
        """)

      assert Script.get_variable_value(script, "s") == "this-;"
    end

    test "left-stripping spaces from non-ASCII characters" do
      script =
        run("""
        s = "  ère ".lstrip()
        """)

      assert Script.get_variable_value(script, "s") == "ère "
    end

    test "stripping one delimiter from non-ASCII characters" do
      script =
        run("""
        s = ";;rêve;".lstrip(";")
        """)

      assert Script.get_variable_value(script, "s") == "rêve;"
    end

    test "left-stripping delimiters from non-ASCII characters" do
      script =
        run("""
        s = ";-;maïs-;".lstrip("-;")
        """)

      assert Script.get_variable_value(script, "s") == "maïs-;"
    end
  end

  describe "rstrip" do
    test "right-stripping spaces from ASCII characters" do
      script =
        run("""
        s = "  this ".rstrip()
        """)

      assert Script.get_variable_value(script, "s") == "  this"
    end

    test "right-stripping one delimiter from ASCII characters" do
      script =
        run("""
        s = ";;this;".rstrip(";")
        """)

      assert Script.get_variable_value(script, "s") == ";;this"
    end

    test "right-stripping delimiters from ASCII characters" do
      script =
        run("""
        s = ";-;this-;".rstrip("-;")
        """)

      assert Script.get_variable_value(script, "s") == ";-;this"
    end

    test "right-stripping spaces from non-ASCII characters" do
      script =
        run("""
        s = "  ère ".rstrip()
        """)

      assert Script.get_variable_value(script, "s") == "  ère"
    end

    test "right-stripping one delimiter from non-ASCII characters" do
      script =
        run("""
        s = ";;rêve;".rstrip(";")
        """)

      assert Script.get_variable_value(script, "s") == ";;rêve"
    end

    test "right-stripping delimiters from non-ASCII characters" do
      script =
        run("""
        s = ";-;maïs-;".rstrip("-;")
        """)

      assert Script.get_variable_value(script, "s") == ";-;maïs"
    end
  end

  describe "strip" do
    test "stripping spaces from ASCII characters" do
      script =
        run("""
        s = "  this ".strip()
        """)

      assert Script.get_variable_value(script, "s") == "this"
    end

    test "stripping one delimiter from ASCII characters" do
      script =
        run("""
        s = ";;this;".strip(";")
        """)

      assert Script.get_variable_value(script, "s") == "this"
    end

    test "stripping delimiters from ASCII characters" do
      script =
        run("""
        s = ";-;this-;".strip("-;")
        """)

      assert Script.get_variable_value(script, "s") == "this"
    end

    test "stripping spaces from non-ASCII characters" do
      script =
        run("""
        s = "  ère ".strip()
        """)

      assert Script.get_variable_value(script, "s") == "ère"
    end

    test "stripping one delimiter from non-ASCII characters" do
      script =
        run("""
        s = ";;rêve;".strip(";")
        """)

      assert Script.get_variable_value(script, "s") == "rêve"
    end

    test "stripping delimiters from non-ASCII characters" do
      script =
        run("""
        s = ";-;maïs-;".strip("-;")
        """)

      assert Script.get_variable_value(script, "s") == "maïs"
    end
  end

  describe "upper" do
    test "affectation of upper on ASCCII letters" do
      script =
        run("""
        s = "this".upper()
        """)

      assert Script.get_variable_value(script, "s") == "THIS"
    end

    test "a string with only lowercase ASCII letters" do
      script =
        run("""
        s = "this"
        s = s.upper()
        """)

      assert Script.get_variable_value(script, "s") == "THIS"
    end

    test "a string with ASCII uppercase and lowercase letters" do
      script =
        run("""
        s = "ThaT"
        s = s.upper()
        """)

      assert Script.get_variable_value(script, "s") == "THAT"
    end

    test "a string with ASCII uppercase and lowercase letters and other characters" do
      script =
        run("""
        s = " It SHould WorK="
        s = s.upper()
        """)

      assert Script.get_variable_value(script, "s") == " IT SHOULD WORK="
    end

    test "a string with only lowercase non-ASCII letters" do
      script =
        run("""
        s = "olá"
        s = s.upper()
        """)

      assert Script.get_variable_value(script, "s") == "OLÁ"
    end

    test "a string with non-ASCII uppercase and lowercase letters" do
      script =
        run("""
        s = "éRic"
        s = s.upper()
        """)

      assert Script.get_variable_value(script, "s") == "ÉRIC"
    end

    test "a string with non-ASCII uppercase and lowercase letters and other characters" do
      script =
        run("""
        s = ' rüCKSIcHTSLoS-'
        s = s.upper()
        """)

      assert Script.get_variable_value(script, "s") == " RÜCKSICHTSLOS-"
    end
  end
end