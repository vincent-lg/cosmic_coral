defmodule CosmicCoral.Scripting.Namespace do
  @moduledoc """
  Defines a namespace, with methods and attributes, for an object.
  """

  alias CosmicCoral.Scripting.Callable
  alias CosmicCoral.Scripting.Namespace
  alias CosmicCoral.Scripting.Interpreter.Script

  defmacro __using__(_opts) do
    quote do
      Module.register_attribute(__MODULE__, :attribute, accumulate: true, persist: true)
      Module.register_attribute(__MODULE__, :method, accumulate: true, persist: true)
      Module.register_attribute(__MODULE__, :attributes, persist: true)
      Module.register_attribute(__MODULE__, :methods, persist: true)

      import CosmicCoral.Scripting.Namespace
      alias CosmicCoral.Scripting.Interpreter.Script

      @before_compile CosmicCoral.Scripting.Namespace
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      @attributes @attribute
                  |> Enum.map(fn name -> {name, String.to_existing_atom("a_#{name}")} end)
                  |> Map.new()
      @methods @method
               |> Enum.map(fn name -> {name, String.to_existing_atom("m_#{name}")} end)
               |> Map.new()

      @doc false
      def attributes do
        @attributes
      end

      @doc false
      def methods do
        @methods
      end

      @doc false
      def getattr(script, self, name) do
        Map.get(attributes(), name)
        |> case do
          nil ->
            method = Map.get(methods(), name)

            %Callable{module: __MODULE__, object: self, name: method}

          attribute ->
            apply(__MODULE__, attribute, [script, self])
        end
      end
    end
  end

  defmacro defattr({name, _, args}, do: block) do
    quote do
      @attribute to_string(unquote(name))
      def unquote(String.to_atom("a_#{name}"))(unquote_splicing(args)) do
        unquote(block)
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
  Locate the namespace matching a given value.
  """
  @spec locate(term()) :: module()
  def locate(value) do
    case value do
      list when is_list(list) -> Namespace.List
      str when is_binary(str) -> Namespace.String
      %CosmicCoral.Entity{} -> Namespace.Entity
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
