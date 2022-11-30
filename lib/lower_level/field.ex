defmodule Passbook.LowerLevel.Field do
  @moduledoc """
  Keys, used at the lowest level of the pass.json file, that define an individual field.
  """

  defstruct [
    :key,
    :value,
    attributed_value: nil,
    change_message: nil,
    data_detector_types: nil,
    label: nil,
    text_alignment: nil
  ]

  @type text_alignment :: :left | :center | :right | :natural
  @type data_detector_types :: :phone_number | :link | :address | :calendar_event

  @type t() :: %__MODULE__{
          key: String.t(),
          value: String.t(),
          attributed_value: String.t() | nil,
          change_message: String.t() | nil,
          label: String.t() | nil,
          data_detector_types: data_detector_types | nil,
          text_alignment: text_alignment | nil
        }

  defimpl Jason.Encoder do
    @text_alignment_mapping [
      left: "PKTextAlignmentLeft",
      center: "PKTextAlignmentCenter",
      right: "PKTextAlignmentRight",
      natural: "PKTextAlignmentNatural"
    ]

    @data_detector_types_mapping [
      phone_number: "PKDataDetectorTypePhoneNumber",
      link: "PKDataDetectorTypeLink",
      address: "PKDataDetectorTypeAddress",
      calendar_event: "PKDataDetectorTypeCalendarEvent"
    ]
    def encode(struct, opts) do
      Jason.Encode.map(
        %{
          Map.from_struct(struct)
          | data_detector_types: @data_detector_types_mapping[struct.data_detector_types],
            text_alignment: @text_alignment_mapping[struct.text_alignment]
        },
        opts
      )
    end
  end
end
