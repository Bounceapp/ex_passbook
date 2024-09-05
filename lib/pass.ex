defmodule Passbook.Pass do
  @moduledoc """
  The top level of the pass.json file is a dictionary.

  More info at: https://developer.apple.com/library/archive/documentation/UserExperience/Reference/PassKit_Bundle/Chapters/TopLevel.html#//apple_ref/doc/uid/TP40012026-CH2-SW1
  """

  @derive Jason.Encoder
  defstruct [
    :description,
    :organization_name,
    :pass_type_identifier,
    :serial_number,
    :team_identifier,
    format_version: 1,
    boarding_pass: nil,
    coupon: nil,
    event_ticket: nil,
    generic: nil,
    store_card: nil,
    barcode: nil,
    barcodes: nil,
    expiration_date: nil,
    relevant_date: nil,
    location: nil,
    locations: nil,
    background_color: nil,
    foreground_color: nil,
    label_color: nil,
    logo_text: nil,
    web_service_url: nil,
  ]

  @type t() :: %__MODULE__{
          description: String.t(),
          format_version: integer(),
          organization_name: String.t(),
          pass_type_identifier: String.t(),
          serial_number: String.t(),
          team_identifier: String.t(),
          boarding_pass: Passbook.PassStructure.t() | nil,
          coupon: Passbook.PassStructure.t() | nil,
          event_ticket: Passbook.PassStructure.t() | nil,
          generic: Passbook.PassStructure.t() | nil,
          store_card: Passbook.PassStructure.t() | nil,
          barcodes: list(Passbook.LowerLevel.Barcode.t()) | nil,
          barcode: Passbook.LowerLevel.Barcode.t() | nil,
          relevant_date: String.t() | nil,
          expiration_date: String.t() | nil,
          locations: list(Passbook.LowerLevel.Location.t()) | nil,
          location: Passbook.LowerLevel.Location.t() | nil,
          background_color: String.t() | nil,
          foreground_color: String.t() | nil,
          label_color: String.t() | nil,
          logo_text: String.t() | nil,
          web_service_url: String.t() | nil
        }

  def generate_json(%Passbook.Pass{} = pass) do
    # TODO: validations (only one type of pass is present, date formats, etc...)

    Jason.encode!(pass)
    |> Jason.decode!()
    |> NestedFilter.drop_by_key(["__struct__"])
    |> NestedFilter.drop_by_value([nil, %{}])
    |> Passbook.Helpers.camelize()
    |> Jason.encode!()
  end
end
