defmodule SwarmEngine.Connectors.LocalFile do
  @type t :: {module, Map.t, Keyword.t}

  def create(params, options \\ []) do
    {__MODULE__, params, options}
  end

  def request({__MODULE__, %{path: path}, _opts}) do
    File.stream!(path, [], 2048)
  end

  def request_metadata({__MODULE__, %{path: path}, opts} = source) do
    with  {:ok, info} <-
            File.stat(path, opts)
    do
      {:ok, %{filename: Path.basename(path),
              size: info.size,
              modified_at: info.mtime |> Calendar.NaiveDateTime.to_date_time_utc,
              source: source
            }
      }
    else
      {:error, reason} -> {:error, reason}
    end
  end
end
