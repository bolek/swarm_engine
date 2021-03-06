defmodule SwarmEngine.DatasetTest do
  use ExUnit.Case, async: true

  doctest SwarmEngine.Dataset

  alias SwarmEngine.{Dataset, DataVault}
  alias Ecto.Adapters.SQL

  setup do
    # Explicitly get a connection before each test
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(DataVault)
  end

  test "creating a postgres table for a dataset" do
    dataset = %Dataset{name: "test_table", columns: [
        %{name: "column_1", type: "varchar"},
        %{name: "column_2", type: "integer"}
      ]
    }

    assert :ok = Dataset.create(dataset)

    assert {:ok, [
      %{order: 1, name: "swarm_id", type: "uuid"},
      %{order: 2, name: "column_1", type: "character varying"},
      %{order: 3, name: "column_2", type: "integer"},
      %{order: 4, name: "swarm_created_at", type: "timestamp with time zone"},
    ]} = Dataset.columns(dataset)

    assert Dataset.exists?(dataset)
  end

  test "creating a dataset that already exists" do
    dataset = %Dataset{name: "test_table", columns: [
        %{name: "column_1", type: "varchar"},
        %{name: "column_2", type: "integer"}
      ]
    }

    Dataset.create(dataset)
    assert :ok = Dataset.create(dataset)
  end

  test "exists? returns false when table does not exist" do
    dataset = %Dataset{name: "dummy_table", columns: []}

    refute Dataset.exists?(dataset)
  end

  test "columns for a dataset without a table" do
    dataset = %Dataset{name: "dummy_table", columns: []}

    assert {:error, :dataset_without_table} = Dataset.columns(dataset)
  end

  test "inserting into a database" do
    dataset = %Dataset{name: "test_table", columns: [
        %{name: "column_1", type: "varchar"},
        %{name: "column_2", type: "integer"}
      ]
    }

    data = [["foo", 123], ["bar", 234], ["car", 345], ["tar", 456]]

    Dataset.create(dataset)
    Dataset.insert(dataset, data)

    assert {:ok,
            %{
              num_rows: 4,
              columns: ["swarm_id", "column_1", "column_2", "swarm_created_at"],
              rows: [
                [<<239, 35, 142, 160, 10, 38, 82, 141, 228, 15, 242, 49, 229, 169, 127, 80>>, "foo", 123, _],
                [<<146, 133, 207, 198, 58, 39, 183, 29, 135, 228, 210, 35, 155, 232, 147, 130>>, "bar", 234, _],
                [<<245, 229, 38, 130, 173, 136, 244, 190, 161, 221, 177, 65, 220, 212, 222, 206>>, "car", 345, _],
                [<<189, 123, 180, 16, 6, 121, 214, 121, 40, 9, 42, 66, 170, 225, 62, 218>>, "tar", 456, _]
              ]
            }
          } = SQL.query(DataVault, "SELECT * FROM test_table")

    assert {:ok,
            %{
              num_rows: 4,
              columns: ["swarm_id", "loaded_at"],
              rows: [
                [<<239, 35, 142, 160, 10, 38, 82, 141, 228, 15, 242, 49, 229, 169, 127, 80>>, _],
                [<<146, 133, 207, 198, 58, 39, 183, 29, 135, 228, 210, 35, 155, 232, 147, 130>>, _],
                [<<245, 229, 38, 130, 173, 136, 244, 190, 161, 221, 177, 65, 220, 212, 222, 206>>, _],
                [<<189, 123, 180, 16, 6, 121, 214, 121, 40, 9, 42, 66, 170, 225, 62, 218>>, _]
              ]
            }
          } = SQL.query(DataVault, "SELECT * FROM test_table_v")
  end

  test "inserting duplicates inserts unique records" do
    dataset = %Dataset{name: "test_table", columns: [
        %{name: "column_1", type: "varchar"},
        %{name: "column_2", type: "integer"}
      ]
    }

    data = [["foo", 123], ["foo", 123]]

    Dataset.create(dataset)
    Dataset.insert(dataset, data)

    assert {:ok,
            %{
              num_rows: 1,
              columns: ["swarm_id", "column_1", "column_2", "swarm_created_at"],
              rows: [
                [<<239, 35, 142, 160, 10, 38, 82, 141, 228, 15, 242, 49, 229, 169, 127, 80>>, "foo", 123, _]
              ]
            }
          } = SQL.query(DataVault, "SELECT * FROM test_table")

    assert {:ok,
            %{
              num_rows: 2,
              columns: ["swarm_id", "loaded_at"],
              rows: [
                [<<239, 35, 142, 160, 10, 38, 82, 141, 228, 15, 242, 49, 229, 169, 127, 80>>, _],
                [<<239, 35, 142, 160, 10, 38, 82, 141, 228, 15, 242, 49, 229, 169, 127, 80>>, _]
              ]
            }
          } = SQL.query(DataVault, "SELECT * FROM test_table_v")
  end
end
