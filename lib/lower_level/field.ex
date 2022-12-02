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
    text_alignment: nil,
    date_style: nil,
    ignores_time_zone: nil,
    is_relative: nil,
    time_style: nil
  ]

  @type text_alignment :: :left | :center | :right | :natural
  @type data_detector_types :: :phone_number | :link | :address | :calendar_event
  @type date_time_styles :: :none | :short | :medium | :long | :full

  @type t() :: %__MODULE__{
          key: String.t(),
          value: String.t(),
          attributed_value: String.t() | nil,
          change_message: String.t() | nil,
          label: String.t() | nil,
          data_detector_types: data_detector_types | nil,
          text_alignment: text_alignment | nil,
          date_style: date_time_styles | nil,
          ignores_time_zone: boolean() | nil,
          is_relative: boolean() | nil,
          time_style: date_time_styles | nil
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

    @date_time_styles_mapping [
      none: "PKDateStyleNone",
      short: "PKDateStyleShort",
      medium: "PKDateStyleMedium",
      long: "PKDateStyleLong",
      full: "PKDateStyleFull"
    ]
    def encode(struct, opts) do
      Jason.Encode.map(
        %{
          struct
          | data_detector_types: @data_detector_types_mapping[struct.data_detector_types],
            text_alignment: @text_alignment_mapping[struct.text_alignment],
            date_style: @date_time_styles_mapping[struct.date_style],
            time_style: @date_time_styles_mapping[struct.time_style]
        },
        opts
      )
    end
  end
end
