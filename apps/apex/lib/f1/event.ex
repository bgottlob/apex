defmodule F1.EventPacket do
  import F1.DataTypes

  defstruct [
    :header,
    :event_string_code,
    :event_details
  ]

  def from_binary(data, header = %F1.PacketHeader{}) do
    {struct, data} = {%__MODULE__{header: header}, data}
                     |> uint8(:event_string_code, 4)

    struct = Map.update(struct, :event_string_code, "", fn tuple ->
      tuple |> Tuple.to_list |> List.to_string
    end)

    event_type = case struct.event_string_code do
      "SSTA" -> F1.Event.SessionStarted
      "SEND" -> F1.Event.SessionEnded
      "FTLP" -> F1.Event.FastestLap
      "RTMT" -> F1.Event.Retirement
      "DRSE" -> F1.Event.DRSEnabled
      "DRSD" -> F1.Event.DRSDisabled
      "TMPT" -> F1.Event.ChequeredFlag
      "RCWN" -> F1.Event.RaceWinner
    end

    Map.put(struct, :event_details, event_type.from_binary(data))
  end
end

defmodule F1.Event.SessionStarted do
  defstruct []

  def from_binary(_) do
    %__MODULE__{}
  end
end

defmodule F1.Event.SessionEnded do
  defstruct []

  def from_binary(_) do
    %__MODULE__{}
  end
end

defmodule F1.Event.DRSEnabled do
  defstruct []

  def from_binary(_) do
    %__MODULE__{}
  end
end

defmodule F1.Event.DRSDisabled do
  defstruct []

  def from_binary(_) do
    %__MODULE__{}
  end
end

defmodule F1.Event.ChequeredFlag do
  defstruct []

  def from_binary(_) do
    %__MODULE__{}
  end
end

defmodule F1.Event.FastestLap do
  import F1.DataTypes

  defstruct [
    :vehicle_index,
    :lap_time
  ]

  def from_binary(data) do
    {%__MODULE__{}, data}
    |> uint8(:vehicle_index)
    |> float32(:lap_time)
  end
end

defmodule F1.Event.Retirement do
  import F1.DataTypes

  defstruct [:vehicle_index]

  def from_binary(data) do
    {%__MODULE__{}, data}
    |> uint8(:vehicle_index)
  end
end

defmodule F1.Event.TeamMateInPits do
  import F1.DataTypes

  defstruct [:vehicle_index]

  def from_binary(data) do
    {%__MODULE__{}, data}
    |> uint8(:vehicle_index)
  end
end

defmodule F1.Event.RaceWinner do
  import F1.DataTypes

  defstruct [:vehicle_index]

  def from_binary(data) do
    {%__MODULE__{}, data}
    |> uint8(:vehicle_index)
  end
end
