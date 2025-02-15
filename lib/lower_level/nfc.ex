defmodule Passbook.LowerLevel.Nfc do
  @moduledoc """
  Information about a NFC.
  """

  @derive Jason.Encoder
  defstruct encryption_public_key: nil,
            message: nil

  @type t() :: %__MODULE__{
          encryption_public_key: String.t() | nil,
          message: String.t() | nil
        }
end
