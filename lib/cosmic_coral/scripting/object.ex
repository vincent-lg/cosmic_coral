defmodule CosmicCoral.Scripting.Object do
  @moduledoc """
  Defines an object (a namespace with attributes and methods) for an object.
  This defines a namespace for builtin objects (like lists and dicts).
  """

  defmacro __using__(_opts) do
    quote do
      Module.register_attribute(__MODULE__, :attribute, persist: true)
      Module.register_attribute(__MODULE__, :method, accumulate: true, persist: true)
      Module.register_attribute(__MODULE__, :methods, persist: true)

      import CosmicCoral.Scripting.Object
      alias CosmicCoral.Scripting.Interpreter.Script

      @before_compile CosmicCoral.Scripting.Object
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      @methods @method |> Enum.map(fn name -> {name, String.to_existing_atom("m_#{name}")} end) |> Map.new()

      @doc false
      def methods do
        @methods
      end
    end
  end

  defmacro defmet({name, _, args}, do: block) do
    quote do
      @method to_string(unquote(name))
      def unquote(String.to_atom("m_#{name}"))(unquote_splicing(args)) do
        unquote(block)
      end
    end
  end

  @doc """
  Call a method of this namespace.

  This method takes a script structure and returns it in any case.
  """
  def call(module, name, script, self, reference, args \\ nil, kwargs \\ nil) do
    method = Map.get(module.methods(), name)

    apply(module, method, [script, self, reference, args, kwargs])
  end
end
