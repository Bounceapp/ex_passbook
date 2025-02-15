defmodule Passbook.PassStructure do
  @moduledoc """
  Keys that define the structure of the pass.

  These keys are used for all pass styles and partition the fields into the various parts of the pass.
  """

  defstruct auxiliary_fields: nil,
            back_fields: nil,
            header_fields: nil,
            primary_fields: nil,
            secondary_fields: nil,
            transit_type: nil

  @type transit_type :: :air | :boat | :bus | :generic | :train
  @type field :: map()

  @type t() :: %__MODULE__{
          auxiliary_fields: list(Passbook.LowerLevel.Field.t()) | nil,
          back_fields: list(Passbook.LowerLevel.Field.t()) | nil,
          header_fields: list(Passbook.LowerLevel.Field.t()) | nil,
          primary_fields: list(Passbook.LowerLevel.Field.t()) | nil,
          secondary_fields: list(Passbook.LowerLevel.Field.t()) | nil,
          transit_type: transit_type | nil
        }

  defimpl Jason.Encoder do
    @transit_mapping [
      air: "PKTransitTypeAir",
      boat: "PKTransitTypeBoat",
      bus: "PKTransitTypeBus",
      generic: "PKTransitTypeGeneric",
      train: "PKTransitTypeTrain"
    ]
    def encode(struct, opts) do
      Jason.Encode.map(
        %{struct | transit_type: @transit_mapping[struct.transit_type]},
        opts
      )
    end
  end
end
