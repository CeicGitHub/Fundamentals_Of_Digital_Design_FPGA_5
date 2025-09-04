`timescale 1ns/1ps

// ==================
//  SVA BIND MODULE
// ==================
module sec_units_overflow_sva (
  input  logic        clk_signal,
  input  logic        rstn,
  input  logic        start_stop,
  input  logic [3:0]  sec_units,
  input  logic [3:0]  sec_tens
);

  // Si el ciclo anterior era 9, ahora debe ser 0 y decenas debe +1
  property units_overflow_increments_tens;
    @(posedge clk_signal) disable iff (!rstn || !start_stop)
      ($past(sec_units) == 4'd9) |-> (sec_units == 4'd0 && sec_tens == $past(sec_tens) + 1);
  endproperty

  a_units_overflow_increments_tens: assert property (units_overflow_increments_tens)
    else $error("[SEC] sec_tens no incrementó cuando sec_units pasó de 9->0");

  c_units_overflow_increments_tens: cover property (units_overflow_increments_tens);

endmodule

// Hace el bind y CONECTA los puertos al ámbito interno del DUT
bind digital_clock sec_units_overflow_sva u_sva_overflow (
  .clk_signal (clk_signal),
  .rstn       (rstn),
  .start_stop (start_stop),
  .sec_units  (sec_units),
  .sec_tens   (sec_tens)
);


// ==================
//  TESTBENCH
// ==================
module tb_overflow_sec_units;

  localparam int CLK_PERIOD = 20; // 50 MHz

  logic clk;
  logic rstn;
  logic start_stop;
  wire [6:0] hex0, hex1, hex2, hex3;

  digital_clock uut (
    .clk        (clk),
    .rstn       (rstn),
    .start_stop (start_stop),
    .hex0       (hex0),
    .hex1       (hex1),
    .hex2       (hex2),
    .hex3       (hex3)
  );

  initial clk = 1'b0;
  always #(CLK_PERIOD/2) clk = ~clk;

  initial begin
    $display("[%0t] Inicia simulación", $time);
    rstn        = 1'b0;
    start_stop  = 1'b0;

    repeat (5) @(posedge clk);
    rstn = 1'b1;  $display("[%0t] Reset liberado", $time);

    repeat (2) @(posedge clk);
    start_stop = 1'b1;  $display("[%0t] start_stop=1 (enable)", $time);

    // Deja tiempo suficiente para ver 09->10 varias veces
    repeat (500) @(posedge clk);

    start_stop = 1'b0;  $display("[%0t] start_stop=0 (pause)", $time);
    repeat (20) @(posedge clk);
    start_stop = 1'b1;  $display("[%0t] start_stop=1 (resume)", $time);
    repeat (500) @(posedge clk);

    $display("[%0t] Fin de simulación", $time);
    $finish;
  end

  // Traza opcional en el reloj de conteo del DUT
  logic [3:0] last_sec_units, last_sec_tens;
  always @(posedge uut.clk_signal or negedge rstn) begin
    if (!rstn) begin
      last_sec_units <= '0;
      last_sec_tens  <= '0;
    end else if (start_stop) begin
      if (uut.sec_units != last_sec_units || uut.sec_tens != last_sec_tens) begin
        $display("[%0t] seg=%0d%0d", $time, uut.sec_tens, uut.sec_units);
        last_sec_units <= uut.sec_units;
        last_sec_tens  <= uut.sec_tens;
      end
    end
  end

endmodule
