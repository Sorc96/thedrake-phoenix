defmodule DrakeWeb.ViewHelpers do
  def class_list(kw_list) do
    kw_list
    |> Enum.map(fn {class_name, condition} -> {class_name, !!condition} end)
    |> Phoenix.HTML.Tag.attributes_escape()
  end
end
