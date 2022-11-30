defmodule PassTest do
  use ExUnit.Case

  describe "generate_json" do
    test "it generates a json string with the pass.json contents" do
      pass = %Passbook.Pass{
        background_color: "rgb(23, 187, 82)",
        foreground_color: "rgb(100, 10, 110)",
        barcode: %Passbook.LowerLevel.Barcode{
          format: :qr,
          alt_text: "1234",
          message: "qr-code-content"
        },
        description: "This is a pass description",
        organization_name: "My Organization",
        pass_type_identifier: "123",
        serial_number: "serial-number-123",
        team_identifier: "team-identifier",
        generic: %Passbook.PassStructure{
          transit_type: :train,
          primary_fields: [
            %Passbook.LowerLevel.Field{
              key: "my-key",
              value: "my-value"
            }
          ]
        }
      }

      assert "{\"background_color\":\"rgb(23, 187, 82)\",\"barcode\":{\"alt_text\":\"1234\",\"format\":\"PKBarcodeFormatQR\",\"message\":\"qr-code-content\",\"message_encoding\":\"iso-8859-1\"},\"boarding_pass\":null,\"coupon\":null,\"description\":\"This is a pass description\",\"event_ticket\":null,\"expiration_date\":null,\"foreground_color\":\"rgb(100, 10, 110)\",\"format_version\":1,\"generic\":{\"auxiliary_fields\":null,\"back_fields\":null,\"header_fields\":null,\"primary_fields\":[{\"attributed_value\":null,\"change_message\":null,\"data_detector_types\":null,\"key\":\"my-key\",\"label\":null,\"text_alignment\":null,\"value\":\"my-value\"}],\"secondary_fields\":null,\"transit_type\":\"PKTransitTypeTrain\"},\"label_color\":null,\"location\":null,\"logo_text\":null,\"organization_name\":\"My Organization\",\"pass_type_identifier\":\"123\",\"serial_number\":\"serial-number-123\",\"store_card\":null,\"team_identifier\":\"team-identifier\"}" =
               Passbook.Pass.generate_json(pass)
    end
  end
end
