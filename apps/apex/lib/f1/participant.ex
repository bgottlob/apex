defmodule F1.ParticipantPacket do
  import F1.DataTypes

  defstruct [
    :header,
    :num_active_cars,
    :participants
  ]

  def from_binary(data, header = %F1.PacketHeader{}) do
    {struct, data} = {%__MODULE__{header: header}, data}
                     |> uint8(:num_active_cars)
    {participants, _} = F1.Parser.parse_tuple(data, F1.Participant, 20)
    Map.put(struct, :participants, participants)
  end
end

defmodule F1.Participant do
  import F1.DataTypes

  defstruct [
    :ai_controlled,
    :driver_id,
    :team_id,
    :race_number,
    :nationality,
    :name,
    :your_telemetry
  ]

  def from_binary(data) do
    {struct, data} = {%__MODULE__{}, data}
                     |> uint8(:ai_controlled)
                     |> uint8(:driver_id)
                     |> uint8(:team_id)
                     |> uint8(:race_number)
                     |> uint8(:nationality)
    
    <<name::little-binary-size(48), data::binary>> = data

    {%{struct | name: name |> String.upcase}, data}
    |> uint8(:your_telemetry)
  end
end
