defmodule UpdateMigrations do
  def run do
    migrations_dir = "priv/repo/migrations"

    File.ls!(migrations_dir)
    |> Enum.filter(&String.ends_with?(&1, ".exs"))
    |> Enum.each(fn file ->
      path = Path.join(migrations_dir, file)
      content = File.read!(path)

      new_content =
        content
        |> String.replace(~r/create table\(/, "create_if_not_exists table(")
        |> String.replace(~r/create index\(/, "create_if_not_exists index(")
        |> String.replace(~r/create unique_index\(/, "create_if_not_exists unique_index(")

      if content != new_content do
        File.write!(path, new_content)
        IO.puts("Updated #{file}")
      end
    end)

    IO.puts("All migrations updated successfully!")
  end
end

UpdateMigrations.run()
