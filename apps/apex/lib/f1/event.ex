defmodule F1.EventPacket do
  @moduledoc """
  A struct representing data for various types of events.
  """

  import F1.DataTypes

  @derive Jason.Encoder
  defstruct [
    :header,
    :event_string_code,
    :event_details
  ]

  def from_binary(data, %F1.PacketHeader{} = header) do
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
  @moduledoc """
  A struct representing session started events.
  """

  @derive Jason.Encoder
  defstruct []

  def from_binary(_) do
    %__MODULE__{}
  end
end

defmodule F1.Event.SessionEnded do
  @moduledoc """
  A struct representing session ended events.
  """

  @derive Jason.Encoder
  defstruct []

  def from_binary(_) do
    %__MODULE__{}
  end
end

defmodule F1.Event.DRSEnabled do
  @moduledoc """
  A struct representing DRS enabled events.
  """

  @derive Jason.Encoder
  defstruct []

  def from_binary(_) do
    %__MODULE__{}
  end
end

defmodule F1.Event.DRSDisabled do
  @moduledoc """
  A struct representing DRS disabled events.
  """

  @derive Jason.Encoder
  defstruct []

  def from_binary(_) do
    %__MODULE__{}
  end
end

defmodule F1.Event.ChequeredFlag do
  @moduledoc """
  A struct representing chequered flag events.
  """

  @derive Jason.Encoder
  defstruct []

  def from_binary(_) do
    %__MODULE__{}
  end
end

defmodule F1.Event.FastestLap do
  @moduledoc """
  A struct representing fastest lap events.
  """

  import F1.DataTypes

  @derive Jason.Encoder
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
  @moduledoc """
  A struct representing retirement events.
  """

  import F1.DataTypes

  @derive Jason.Encoder
  defstruct [:vehicle_index]

  def from_binary(data) do
    {%__MODULE__{}, data}
    |> uint8(:vehicle_index)
  end
end

defmodule F1.Event.TeamMateInPits do
  @moduledoc """
  A struct representing team mate in pits events.
  """

  import F1.DataTypes

  @derive Jason.Encoder
  defstruct [:vehicle_index]

  def from_binary(data) do
    {%__MODULE__{}, data}
    |> uint8(:vehicle_index)
  end
end

defmodule F1.Event.RaceWinner do
  @moduledoc """
  A struct representing race winner events.
  """

  import F1.DataTypes

  @derive Jason.Encoder
  defstruct [:vehicle_index]

  def from_binary(data) do
    {%__MODULE__{}, data}
    |> uint8(:vehicle_index)
  end
end
