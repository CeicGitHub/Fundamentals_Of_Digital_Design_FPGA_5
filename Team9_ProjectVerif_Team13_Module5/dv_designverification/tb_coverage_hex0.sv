`timescale 1ns/1ps
module tb_coverage_hex0;

  // ===== Reloj base y DUT =====
  parameter int CLK_PERIOD = 20; // 50 MHz
  logic clk, rstn, start_stop;
  wire [6:0] hex0, hex1, hex2, hex3;

  digital_clock uut (
    .clk(clk), .rstn(rstn), .start_stop(start_stop),
    .hex0(hex0), .hex1(hex1), .hex2(hex2), .hex3(hex3)
  );

  initial clk = 0;
  always #(CLK_PERIOD/2) clk = ~clk;

  //7-seg (ánodo común) -> BCD 
  function automatic [3:0] seg_to_bcd(input [6:0] s);
    case (s)
      7'b1000000: seg_to_bcd = 4'd0; // 0x40
      7'b1111001: seg_to_bcd = 4'd1; // 0x79
      7'b0100100: seg_to_bcd = 4'd2; // 0x24
      7'b0110000: seg_to_bcd = 4'd3; // 0x30
      7'b0011001: seg_to_bcd = 4'd4; // 0x19
      7'b0010010: seg_to_bcd = 4'd5; // 0x12
      7'b0000010: seg_to_bcd = 4'd6; // 0x02
      7'b1111000: seg_to_bcd = 4'd7; // 0x78
      7'b0000000: seg_to_bcd = 4'd8; // 0x00
      7'b0011000: seg_to_bcd = 4'd9; // 0x18
      default:    seg_to_bcd = 4'hF; // inválido
    endcase
  endfunction

  // Variables a samplear
  logic [3:0] digit_sampled;
  bit         en_sampled;

  // ===== Covergroup mínimo (1 coverpoint) =====
  // Objetivo: ver TODOS los dígitos 0..9 en hex0 => 100% cobertura.
  covergroup cg_hex0;
    option.per_instance = 1;
    cp_digits: coverpoint digit_sampled iff (en_sampled) {
      bins digits[] = {[0:9]};
     
    }
  endgroup

  cg_hex0 cov = new();

  // Muestreo manual en posedge del reloj dividido (paso natural del conteo)
  always @(posedge uut.clk_signal) begin
    digit_sampled = seg_to_bcd(hex0);
    en_sampled    = (rstn && start_stop && (digit_sampled != 4'hF));
    cov.sample();
  end

  // ===== Estímulos =====
  initial begin
    rstn = 0; start_stop = 0;
    repeat (5) @(posedge clk);
    rstn = 1; start_stop = 1;

    repeat (30) @(posedge uut.clk_signal);

    $display("Cobertura cg_hex0 = %0.2f%%", cov.get_inst_coverage());
    $finish;
  end

endmodule


