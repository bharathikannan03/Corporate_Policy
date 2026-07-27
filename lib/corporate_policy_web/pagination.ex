defmodule CorporatePolicyWeb.Pagination do
  @moduledoc false

  @page_size 15

  def page_size, do: @page_size

  def paginate_list(entries, page_param, opts \\ []) when is_list(entries) do
    page_size = Keyword.get(opts, :page_size, @page_size)
    total_entries = length(entries)

    total_pages =
      max(div(max(total_entries, 1) + @page_size - 1, @page_size), 1)

    page = normalize_page(page_param, total_pages)

    paged_entries =
      entries
      |> Enum.slice((page - 1) * page_size, page_size)
      |> Kernel.||([])

    %{
      entries: paged_entries,
      page: page,
      page_size: page_size,
      total_entries: total_entries,
      total_pages: total_pages
    }
  end

  def normalize_page(page_param, total_pages) do
    page =
      case page_param do
        value when is_integer(value) ->
          value

        value when is_binary(value) ->
          case Integer.parse(value) do
            {parsed, ""} -> parsed
            _ -> 1
          end

        _ ->
          1
      end

    page
    |> max(1)
    |> min(max(total_pages, 1))
  end

  def page_window(current_page, total_pages, window_size \\ 5) do
    total_pages = max(total_pages, 1)
    window_size = max(window_size, 1)
    half_window = div(window_size, 2)

    start_page =
      current_page
      |> Kernel.-(half_window)
      |> max(1)
      |> min(max(total_pages - window_size + 1, 1))

    end_page = min(start_page + window_size - 1, total_pages)
    Enum.to_list(start_page..end_page)
  end
end
