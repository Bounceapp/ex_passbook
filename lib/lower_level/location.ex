defmodule Passbook.LowerLevel.Location do
  @moduledoc """
  Information about a location.
  """

  defstruct altitude: nil,
            latitude: nil,
            longitude: nil,
            relevant_text: nil

  @type t() :: %__MODULE__{
          altitude: number() | nil,
          latitude: number() | nil,
          longitude: number() | nil,
          relevant_text: String.t() | nil
        }
end
