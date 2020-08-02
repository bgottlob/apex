# %Series{ name: "brake", values: [float], color: "red" }
defmodule ApexDash.Series do
  @moduledoc """
  Struct for storing chart data for a single series of data
  """
  @derive Jason.Encoder
  defstruct [:color, :values]

  # Adds a new value by evicting the oldest value
  def add_value(series, value, :replace) do
    %{series | values: [value | List.delete_at(series.values, -1)]}
  end

  # Adds a new value
  def add_value(series, value, :add) do
    %{series | values: [value | series.values]}
  end
end

defimpl Jason.Encoder, for: [ApexDash.ChartData] do
  def encode(struct, opts) do
    series = Enum.map(struct.series, fn {key, series} -> Map.put(series, :name, key) end)
    Map.put(struct, :series, series) |> Jason.Encode.map(opts)
  end
end

# Struct:
# %ApexDash.ChartData{
#   length: int,
#   series: [
#     %Series{ name: "brake", values: [float], color: "red" },
#     %Series{ name: "throttle", values: [float], color: "steelblue" }
#   ],
#   brake: list(float),
#   throttle: list(float)
# }
defmodule ApexDash.ChartData do
  @moduledoc """
  Struct storing series data for rendering in a D3 visualization
  """

  alias ApexDash.Series

  defstruct [:length, :series, :min_domain, :max_domain, :min_range, :max_range]

  def add_entry(cd, series_key, value) do
    type = cond do
      cd.length == cd.max_domain -> :replace
      cd.length < cd.max_domain -> :add
    end

    Map.update!(
      cd,
      :series,
      # Find the Series struct with the given key and add a value to it
      fn series ->
        Map.update!(series, series_key, fn subseries ->
          Series.add_value(subseries, value, type)
        end)
      end
    )
  end

  def increment(cd) do
    Map.update!(
      cd,
      :length,
      fn length ->
        cond do
          length == cd.max_domain -> length
          length < cd.max_domain  -> length + 1
        end
      end
    )
  end
end

