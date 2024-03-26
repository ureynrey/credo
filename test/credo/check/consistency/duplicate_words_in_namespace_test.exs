defmodule Credo.Check.Consistency.DuplicateWordsInNamespaceTest do
  use Credo.Test.Case
  doctest Credo.Check.Consistency.DuplicateWordsInNamespace
  alias Credo.Check.Consistency.DuplicateWordsInNamespace

  @described_check DuplicateWordsInNamespace

  test "it should report error on duplicate name in module" do
    module = ~S"""
    defmodule Credo.Sample.CredoCheck do
      def hello(), do: :world
    end
    """

    [issue] =
      [module]
      |> to_source_files
      |> run_check(@described_check)
      |> assert_issue()

    assert issue.category == :consistency
    assert issue.check == Credo.Check.Consistency.DuplicateWordsInNamespace

    assert issue.message ==
             "Duplicated word(s), in module, Credo.Sample.CredoCheck detected:\n - Credo\n\nPlease rename your module to avoid duplicate words in your Module's name.\n"
  end
end
