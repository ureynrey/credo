defmodule Credo.Check.Consistency.DuplicateWordsInNamespace do
  use Credo.Check,
    id: "EX1009",
    run_on_all: true,
    base_priority: :normal,
    tags: [:controversial],
    explanations: [
      check: """
      Ensure that there are no duplicate words in a module.

      This Credo check would not allow for modules with duplicate words within you application or declared scope.

      For Example:
        `defmodule MyApp.Service.AppName, do: :ok`

      Would fail to pass this credo check due to the duplicate `App` in the module name.
      """
    ]

  @doc false
  @impl true
  def run(source_files, params) do
    issue_meta = Credo.IssueMeta.for(source_files, params)
    ast = Credo.Code.ast(source_files)

    {_ast, issues} =
      Macro.postwalk(ast, [], fn ast_node, acc -> traverse(ast_node, acc, issue_meta) end)

    issues
  end

  @spec traverse(Macro.t(), [Credo.IssueMeta.t()] | [], Credo.IssueMeta.t()) ::
          {Macro.t(), [Credo.IssueMeta.t()]}
  defp traverse(
         {:__aliases__ = _expression, _metadata, module_name = _arg} = node,
         acc,
         issue_meta
       ) do
    module_string_name = Enum.join(module_name, ".")

    duplicated_words =
      module_name
      |> Enum.map(fn name ->
        name
        |> Atom.to_string()
        |> String.split(~r/([A-Z])/, include_captures: true, trim: true)
        |> Enum.chunk_every(2)
        |> Enum.map(&Enum.join(&1, ""))
      end)
      |> List.flatten()
      |> find_duplicated_words()

    acc =
      if Enum.empty?(duplicated_words),
        do: acc,
        else: [flag_issue(issue_meta, duplicated_words, module_string_name) | acc]

    {node, acc}
  end

  defp traverse(acc_node, acc, _issue_meta), do: {acc_node, acc}

  # Provided a list of strings. `find_duplicated_words/2` returns a list of duplicated strings.
  @spec find_duplicated_words([String.t()]) :: [String.t()] | []
  defp find_duplicated_words(module_as_list_string) do
    deduped_name = Enum.uniq(module_as_list_string)

    if deduped_name == module_as_list_string,
      do: [],
      else: Enum.reduce(deduped_name, module_as_list_string, &List.delete(&2, &1))
  end

  defp flag_issue(issue_meta, duplicate_words, module_string_name) do
    duplicate_words_list =
      for word <- duplicate_words do
        " - #{word}\n"
      end

    format_issue(issue_meta,
      message: """
      Duplicated word(s), in module, #{module_string_name} detected:
      #{duplicate_words_list}
      Please rename your module to avoid duplicate words in your Module's name.
      """
    )
  end
end
