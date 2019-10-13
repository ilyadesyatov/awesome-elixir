defmodule AwesomeToolbox.ParserTest do
  use AwesomeWeb.ConnCase

  setup_all do
    {:ok, link: Application.get_env(:awesome, :link_for_parse)}
  end

  describe "AwesomeToolbox.Github.repo_info/1" do
    test "data from github page", state do
      assert match?({:ok, _}, AwesomeToolbox.Github.repo_info(state[:link])),
             "function should return :ok"
      {:ok, %{"url" => url} = conn} = AwesomeToolbox.Github.repo_info(state[:link])
      assert is_map(conn)
      assert url == "https://api.github.com/repos/#{state[:link]}",
             "in response should be data of url"
    end
  end

  describe "AwesomeToolbox.Github.readme/1" do
    test "body data from github page", state do
      assert match?({:ok, _}, AwesomeToolbox.Github.readme(state[:link])),
             "function should return :ok"
      {:ok, conn} = AwesomeToolbox.Github.readme(state[:link])
      assert is_bitstring(conn)
      assert conn =~ "Awesome Elixir",
             "response should includes test 'Awesome Elixir'"
    end
  end

  describe "AwesomeToolbox.Github.repo_last_commit_info/1" do
    test "body data from github page", state do
      assert match?({:ok, _}, AwesomeToolbox.Github.repo_last_commit_info(state[:link])),
             "function should return :ok"
      {:ok, conn} = AwesomeToolbox.Github.repo_last_commit_info(state[:link])
      assert is_map(conn)
      assert Map.has_key?(conn["commit"]["author"], "date"),
             "response should have key 'date' in commit"
    end
  end

  describe "AwesomeToolbox.parse_readme/1" do
    test "main parse function 'parse_readme'", state do
      assert match?({:ok, _, _}, AwesomeToolbox.parse_readme(state[:link])),
             "function should return :ok"
      {:ok, tuple_readme, html_readme} = AwesomeToolbox.parse_readme(state[:link])
      assert is_list(tuple_readme),
             "markdown should be list after parse"
      assert html_readme =~ "Awesome Elixir",
             "markdown after parse to html should includes 'Awesome Elixir'"
    end
  end

  describe "AwesomeToolbox.parse_sections/1" do

    defp parse_sections_result(link) do
      with  {:ok, tuple_readme, html_readme} <- AwesomeToolbox.parse_readme(link),
            {:ok, sections_parse_result} <- AwesomeToolbox.parse_sections(html_readme) do
              {:ok, tuple_readme, hd(sections_parse_result)}
      end
    end

    test "must return 'li a'", state do
        {:ok, _, first_item} = parse_sections_result(state[:link])

        {element, section_element, section_name} = first_item
        assert (is_bitstring(element) && element == "a"),
               "has tag 'a'"
        assert (is_list(section_element) && section_element |> hd |> elem(0) == "href"),
               "has attr 'href'"
        assert is_list(section_name)
      end

    test "create one section", state do
      {:ok, tuple_readme, first_item} = parse_sections_result(state[:link])

      {_, _, section_name} = first_item
      title = hd section_name
      assert match?({:ok, _}, AwesomeToolbox.create_section(title, tuple_readme)),
             "section was not create"
      {:ok, section} = AwesomeToolbox.create_section(title, tuple_readme)
      assert section.name == title,
             "found section name from markdown and section name from the database did not match"

      {:ok, packages_title} = AwesomeToolbox.section_packages(title, tuple_readme)

      found_packages = packages_title |> Enum.map(fn x -> Map.get(x, :name) end)
      inserted_packages = section.packages |> Enum.map(fn x -> Map.get(x, :name) end)

      assert found_packages == inserted_packages,
             "found packages from markdown and packages from the database did not match"
    end
  end
end