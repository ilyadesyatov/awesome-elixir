defmodule AwesomeWeb.CustomHelpers do
  use Phoenix.HTML

  def text_to_id(text) do
    text |> String.downcase() |> String.replace(" ", "-")
  end

  def less_year(days) do
    if days > 365 do
      "outdated"
    else
      ""
    end
  end
end
