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
    authentication_token: nil
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
          web_service_url: String.t() | nil,
          authentication_token: String.t() | nil
        }

  @doc """
  Generates a JSON string representation of a Pass struct, following Apple's pass.json format.

  ## Examples

      iex> pass = %Passbook.Pass{
      ...>   description: "Ticket",
      ...>   organization_name: "ACME Corp",
      ...>   pass_type_identifier: "pass.com.acme.tickets",
      ...>   serial_number: "123456",
      ...>   team_identifier: "ABC123",
      ...>   web_service_url: "https://example.com/passes/",
      ...>   authentication_token: "vxwxd7J8AlNNFPS8k0a0FfUFtq0ewzFdc"
      ...> }
      iex> Passbook.Pass.generate_json(pass)
      ~s({"authenticationToken":"vxwxd7J8AlNNFPS8k0a0FfUFtq0ewzFdc","description":"Ticket","formatVersion":1,"organizationName":"ACME Corp","passTypeIdentifier":"pass.com.acme.tickets","serialNumber":"123456","teamIdentifier":"ABC123","webServiceURL":"https://example.com/passes/"})

      iex> pass = %Passbook.Pass{
      ...>   description: "Event Pass",
      ...>   organization_name: "ACME Corp",
      ...>   pass_type_identifier: "pass.com.acme.events",
      ...>   serial_number: "789012",
      ...>   team_identifier: "ABC123",
      ...>   event_ticket: %Passbook.PassStructure{
      ...>     primary_fields: [%{key: "event", value: "Concert"}]
      ...>   }
      ...> }
      iex> Passbook.Pass.generate_json(pass)
      ~s({"description":"Event Pass","eventTicket":{"primaryFields":[{"key":"event","value":"Concert"}]},"formatVersion":1,"organizationName":"ACME Corp","passTypeIdentifier":"pass.com.acme.events","serialNumber":"789012","teamIdentifier":"ABC123"})
  """
  def generate_json(%Passbook.Pass{} = pass) do
    # TODO: validations (only one type of pass is present, date formats, etc...)

    json =
      pass
      |> Jason.encode!()
      |> Jason.decode!()
      |> NestedFilter.drop_by_key(["__struct__"])
      |> NestedFilter.drop_by_value([nil, %{}])
      |> Passbook.Helpers.camelize()

    json =
      case Map.get(pass, :web_service_url) do
        nil ->
          json

        url ->
          json
          |> Map.put("webServiceURL", url)
          |> Map.delete("webServiceUrl")
      end

    Jason.encode!(json)
  end
end
