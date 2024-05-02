defmodule CosmicCoral.Scripting.Interpreter.Script do
  @doc """
  A script structure, representing an ongoing execution.

  It has a cursor, a stack, a map of variables and, of course,
  a list of bytecodes to execute.

  """

  @enforce_keys [:bytecode]
  defstruct [:bytecode, cursor: 0, stack: [], references: %{}, variables: %{}, debugger: nil]

  alias CosmicCoral.Scripting.Interpreter.{Debugger, Iterator, Script}
  alias CosmicCoral.Scripting.Object

  @typedoc "a script with bytecode"
  @type t() :: %Script{
                        bytecode: list(),
                        cursor: integer(),
                        stack: list(),
                        references: map(),
                        variables: map(),
                        debugger: nil | %Debugger{}
                      }

  @ops %{+: &+/2, -: &-/2, *: &*/2, /: &//2}
  @cmps %{<: &</2, <=: &<=/2, >: &>/2, >=: &>=/2, ==: &==/2, !=: &!=/2}

  @doc """
  Write a variable in the script, overriding a variable of the same name.

  If the variavle value should have a reference, creates one.
  """
  @spec write_variable(t(), binary(), term()) :: t()
  def write_variable(script, variable, value) do
    script
    |> store(variable, value)
  end

  @doc """
  Update the reference value for an object.
  """
  @spec update_reference(Script.t(), reference(), term()) :: Script.t()
  def update_reference(%{references: references} = script, reference, value) do
    references = Map.put(references, reference, value)
    %{script | references: references}
    |> debug("ref #{inspect(reference)} set to #{inspect(value)}")
  end

  @doc """
  Gets the value of a variable.

  If the variable is a reference, recursively search for a value.
  """
  def get_variable_value(script, name) do
    Map.get(script.variables, name)
    |> reference_to_value(script)
  end

  @doc """
  Execute the given script.
  """
  @spec execute(Script.t()) :: Script.t()
  def execute(script) do
    script
    |> run()
  end

  defp run(%{bytecode: bytecode} = script) do
    bytecode
    |> Stream.with_index()
    |> Stream.map(fn {op, index} -> {index, op} end)
    |> Map.new()
    |> run_next_bytecode(script)
  end

  defp run_next_bytecode(bytecode, %{cursor: cursor} = script) do
    case Map.get(bytecode, cursor) do
      nil -> script
      op ->
        script =
          script
          |> move_ahead()
          |> handle(op)

        run_next_bytecode(bytecode, script)
    end
  end

  defp move_ahead(%Script{cursor: cursor} = script) do
    %{script | cursor: cursor + 1}
  end

  defp handle(script, {:put, value}) do
    script
    |> put_stack(value)
  end

  defp handle(script, op) when op in [:+, :-, :*, :/] do
    operation = Map.get(@ops, op)

    {script, value2} = get_stack(script)
    {script, value1} = get_stack(script)

    script
    |> put_stack(operation.(value1, value2))
  end

  defp handle(script, cmp) when cmp in [:<, :<=, :>, :>=, :==, :!=] do
    operation = Map.get(@cmps, cmp)

    {script, value2} = get_stack(script)
    {script, value1} = get_stack(script)

    script
    |> put_stack(operation.(value1, value2))
  end

  defp handle(script, {:list, len}) do
    {script, values} =
      if len > 0 do
        Enum.reduce(1..len, {script, []}, fn _, {script, values} ->
          {script, {value, reference}} = get_stack(script, :reference)

          case reference do
            nil -> {script, [value | values]}
            _ -> {script, [reference | values]}
          end
        end)
      else
        {script, []}
      end

    script
    |> put_stack(values)
  end

  defp handle(script, {:iffalse, line}) do
    {script, value} = get_stack(script)

    if value do
      script
      |> debug("is true")
    else
      script
      |> put_stack(value)
      |> debug("is false so jump")
      |> jump(line)
    end
  end

  defp handle(script, {:iftrue, line}) do
    {script, value} = get_stack(script)

    if value do
      script
      |> put_stack(value)
      |> debug("is true so jump")
      |> jump(line)
    else
      script
      |> debug("is false")
    end
  end

  defp handle(script, {:popiffalse, line}) do
    {script, value} = get_stack(script)

    if value do
      script
      |> debug("is true")
    else
      script
      |> debug("is false so jump")
      |> jump(line)
    end
  end

  defp handle(script, {:popiftrue, line}) do
    {script, value} = get_stack(script)

    if value do
      script
      |> debug("is true so jump")
      |> jump(line)
    else
      script
      |> debug("is false")
    end
  end

  defp handle(script, {:goto, line}) do
    script
    |> jump(line)
  end

  defp handle(script, :not) do
    {script, value} = get_stack(script)

    script
    |> put_stack(!value)
  end

  defp handle(%{variables: variables} = script, {:read, variable}) do
    value = Map.get(variables, variable)

    script
    |> put_stack(value)
  end

  defp handle(script, {:store, variable}) do
    {script, {value, reference}} = get_stack(script, :reference)
    value = reference || value

    store(script, variable, value)
  end

  defp handle(script, :mkiter) do
    {script, value} = get_stack(script)
    iterator = Iterator.new(script, value)

    script
    |> put_stack(iterator)
  end

  defp handle(script, {:iter, line}) do
    {script, {iterator, reference}} = get_stack(script, :reference)

    case Iterator.next(script, reference, iterator) do
      :stop -> jump(script, line)
      {:cont, script, value} ->
        script
        |> put_stack(reference)
        |> put_stack(value)
    end
  end

  defp handle(script, {:method, len}) do
    {script, name} = get_stack(script)

    {script, args} =
      Enum.reduce(1..len, {script, []}, fn _, {script, values} ->
        {script, group} = get_stack(script, :reference)

        {script, [group | values]}
      end)

    {script, {object, reference}} = get_stack(script, :reference)

    namespace =
      case object do
        list when is_list(list) -> Object.List
      end

    Object.call(namespace, name, script, object, reference, args)
    |> put_stack(true)
  end

  defp handle(script, :pop) do
    {script, _} = get_stack(script)

    script
  end
  defp handle(_script, unknown) do
    raise "unknown bytecode: #{inspect(unknown)}"
  end

  defp put_stack(%{stack: stack} = script, value) do
    {script, value} = (references?(value) && reference(script, value)) || {script, value}

    %{script | stack: [value | stack]}
    |> debug("in stack: #{inspect(value)}")
  end

  defp get_stack(script, retrieve \\ :value)
  defp get_stack(%{stack: [first | next], references: references} = script, retrieve) do
    first =
      case retrieve do
        :value -> (is_reference(first) && Map.get(references, first)) || first
        :reference -> (is_reference(first) && {Map.get(references, first), first}) || {first, nil}
      end

    script =
      script
      |> debug("from stack: #{inspect(first)}")

    {%{script | stack: next}, first}
  end

  defp get_stack(script, _retrieve) do
    raise "stack is empty, #{inspect(script)}"
  end

  defp store(%{variables: variables} = script, variable, value) do
    variables = Map.put(variables, variable, value)

    %{script | variables: variables}
    |> debug("store #{variable} = #{inspect(value)}")
  end

  defp jump(script, line) do
    script =
      script
      |> debug("jump to #{line}")

    %{script | cursor: line}
  end

  defp reference(%{references: references} = script, value) do
    reference = make_ref()
    references = Map.put(references, reference, value)

    script =
      script
      |> debug("create ref #{inspect(reference)} = #{inspect(value)}")

    {%{script | references: references}, reference}
  end

  defp references?(value) when is_reference(value), do: false
  defp references?(value) when is_number(value), do: false
  defp references?(value) when is_boolean(value), do: false
  defp references?(value) when is_binary(value), do: false
  defp references?(_value), do: true

  defp reference_to_value(value, script) when is_reference(value) do
    Map.get(script.references, value)
    |> reference_to_value(script)
  end

  defp reference_to_value(value, script) when is_list(value) do
    Enum.map(value, fn element -> reference_to_value(element, script) end)
  end

  defp reference_to_value(value, _script), do: value

  defp debug(%{debugger: %Debugger{} = debugger} = script, text) do
    debugger = Debugger.add(debugger, script.cursor - 1, text)

    %{script | debugger: debugger}
  end
  defp debug(script, _text), do: script
end
