`timescale 1ns/1ps

// Aqui esperamos comprobrar comprobar que el decodificador 
//bcd_to_7seg produce exactamente los patrones 0–9 de la tabla, en orden.

module tb_bcd_to_7seg_tableII;

  logic [3:0] bcd;
  wire  [6:0] seg;

  // DUT
  bcd_to_7seg dut(.bcd(bcd), .seg(seg));

  // Tabla II (ánodo común, activos en bajo)
  function automatic [6:0] expected_seg(input [3:0] v);
    case (v)
      4'd0: expected_seg = 7'b1000000;
      4'd1: expected_seg = 7'b1111001;
      4'd2: expected_seg = 7'b0100100;
      4'd3: expected_seg = 7'b0110000;
      4'd4: expected_seg = 7'b0011001;
      4'd5: expected_seg = 7'b0010010;
      4'd6: expected_seg = 7'b0000010;
      4'd7: expected_seg = 7'b1111000;
      4'd8: expected_seg = 7'b0000000;
      4'd9: expected_seg = 7'b0011000;
      default: expected_seg = 7'b1111111;
    endcase
  endfunction

  initial begin
    $display("=== Testcase Tabla II: barrer 0..9 en orden ===");
    // Barrido en ORDEN 0->9
    foreach (bcd[i]) begin end // evita warnings
    for (int i = 0; i <= 9; i++) begin
      bcd = i[3:0];
      #1; // delta para propagar
      assert (seg == expected_seg(bcd))
        else $error("Tabla II fallo: bcd=%0d seg=%b esperado=%b", bcd, seg, expected_seg(bcd));
    end
    $display("Tabla II verificada (0..9 en orden).");
    $finish;
  end

endmodule
