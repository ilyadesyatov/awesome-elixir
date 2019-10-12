defmodule AwesomeWeb.PageControllerTest do
  use AwesomeWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Awesome Elixir"
  end

  test "with any number of stars", %{conn: conn} do
    section_struct = %{more_zero: 3, more_10: 5, more_50: 2, more_100: 11, more_500: 9, more_1000: 6}
    sections = insert_pair(:section, colletion: section_struct) ++ insert_pair(:section)
    conn = get(conn, "/")

    main_test(conn, sections, 0)
  end

  test "all filters", %{conn: conn}  do
    filters = [10, 50, 100, 500, 1000]
    Enum.each(filters, fn filter ->
        section_struct_1 = %{more_zero: 2, more_10: 6, more_50: 3, more_100: 11, more_500: 22, more_1000: 1}
        section_struct_2 = %{more_100: 11, more_1000: 1}
        sections =
          insert_pair(:section, colletion: section_struct_1)
          ++ insert_pair(:section)
          ++ insert_pair(:section, colletion: section_struct_2)

        conn = get(conn, "/?min_stars=#{filter}")

        main_test(conn, sections, filter)
    end)
  end

  defp main_test(conn, sections, star_case) do
    for section <- sections do
      if Enum.any?(section.packages, fn(%{:stars => stars}) -> stars >= star_case end) do
        assert html_response(conn, 200) =~ section.name,
          "section includes packages with >= than #{star_case} stars, but it's not on the page"

        for package <- section.packages do
          assert ((html_response(conn, 200) =~ package.name) && package.stars >= star_case),
            "package with >= than #{star_case} stars, but it's not on the page"
        end
      end

      if Enum.all?(section.packages, fn(%{:stars => stars}) -> stars < star_case end) do
        refute html_response(conn, 200) =~ section.name,
          "section includes all packages with < than #{star_case} stars, should not be on the page"
      end
    end
  end
end
