defmodule CorporatePolicy.EscalationMatrices do
  @moduledoc """
  The EscalationMatrices context — manages master_escalation_matrices records.
  """
  import Ecto.Query, warn: false

  alias CorporatePolicy.Repo
  alias CorporatePolicy.EscalationMatrices.EscalationMatrix

  @doc "Returns all active escalation matrices ordered by id descending."
  def list_escalation_matrices do
    from(m in EscalationMatrix,
      where: is_nil(m.deleted_at),
      order_by: [desc: m.id]
    )
    |> Repo.all()
  end

  @doc "Returns paginated active escalation matrices ordered by id descending."
  def list_escalation_matrices_paginated(opts \\ []) do
    page = Keyword.get(opts, :page, 1)
    limit = Keyword.get(opts, :limit, 10)
    offset = (page - 1) * limit

    query =
      from m in EscalationMatrix,
        where: is_nil(m.deleted_at),
        order_by: [desc: m.id]

    total_count = Repo.aggregate(query, :count, :id)

    records =
      query
      |> limit(^limit)
      |> offset(^offset)
      |> Repo.all()

    records_with_nums =
      records
      |> Enum.with_index()
      |> Enum.map(fn {record, idx} ->
        row_num = offset + idx + 1
        Map.put(record, :row_num, row_num)
      end)

    %{
      records: records_with_nums,
      total_count: total_count,
      total_pages: ceil(total_count / limit)
    }
  end

  @doc "Gets a single escalation_matrix record."
  def get_escalation_matrix!(id) do
    Repo.get!(EscalationMatrix, id)
  end

  @doc "Creates a new escalation_matrix record."
  def create_escalation_matrix(attrs \\ %{}) do
    %EscalationMatrix{}
    |> EscalationMatrix.changeset(attrs)
    |> Repo.insert()
  end

  @doc "Updates an existing escalation_matrix record."
  def update_escalation_matrix(%EscalationMatrix{} = escalation_matrix, attrs) do
    escalation_matrix
    |> EscalationMatrix.changeset(attrs)
    |> Repo.update()
  end

  @doc "Soft deletes an escalation_matrix record by setting deleted_at."
  def delete_escalation_matrix(%EscalationMatrix{} = escalation_matrix) do
    escalation_matrix
    |> EscalationMatrix.changeset(%{deleted_at: DateTime.utc_now()})
    |> Repo.update()
  end

  @doc "Returns a changeset for changing an escalation_matrix record."
  def change_escalation_matrix(%EscalationMatrix{} = escalation_matrix, attrs \\ %{}) do
    EscalationMatrix.changeset(escalation_matrix, attrs)
  end
end
