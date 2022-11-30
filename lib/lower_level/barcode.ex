defmodule Passbook.LowerLevel.Barcode do
  @moduledoc """
  Information about a location beacon.

  Available in iOS 7.0.
  """

  defstruct [:format, :message, message_encoding: "iso-8859-1", alt_text: nil]

  @type barcode_format :: :qr | :pdf_417 | :aztec | :code_128

  @type t() :: %__MODULE__{
          format: barcode_format,
          message: String.t(),
          message_encoding: String.t(),
          alt_text: String.t() | nil
        }

  defimpl Jason.Encoder do
    @format_mapping [
      qr: "PKBarcodeFormatQR",
      pdf_417: "PKBarcodeFormatPDF417",
      aztec: "PKBarcodeFormatAztec",
      code_128: "PKBarcodeFormatCode128"
    ]
    def encode(struct, opts) do
      Jason.Encode.map(
        %{
          struct
          | format: @format_mapping[struct.format]
        },
        opts
      )
    end
  end
end
