`timescale 1ns/1ps

module tb_check_hex0_every2cycles;

  // Reloj del sistema (al DUT le entra este clk; internamente divide a clk_out)
  parameter int CLK_PERIOD = 20; // 50 MHz
  logic clk, rstn, start_stop;
  wire [6:0] hex0, hex1, hex2, hex3;

  // DUT
  digital_clock uut (
    .clk(clk),
    .rstn(rstn),
    .start_stop(start_stop),
    .hex0(hex0), .hex1(hex1), .hex2(hex2), .hex3(hex3)
  );

  //Generación del reloj
  initial clk = 0;
  always #(CLK_PERIOD/2) clk = ~clk;

  //Decodificador inverso: 7-seg (ánodo común, activos en bajo)
  function automatic [3:0] seg_to_bcd(input [6:0] s);
    case (s)
      7'b1000000: seg_to_bcd = 4'd0;
      7'b1111001: seg_to_bcd = 4'd1;
      7'b0100100: seg_to_bcd = 4'd2;
      7'b0110000: seg_to_bcd = 4'd3;
      7'b0011001: seg_to_bcd = 4'd4;
      7'b0010010: seg_to_bcd = 4'd5;
      7'b0000010: seg_to_bcd = 4'd6;
      7'b1111000: seg_to_bcd = 4'd7;
      7'b0000000: seg_to_bcd = 4'd8;
      7'b0011000: seg_to_bcd = 4'd9;
      default:    seg_to_bcd = 4'hF; //inválido
    endcase
  endfunction

  //! --------- CHECK: hex0 incrementa cada 2 ciclos de clk_out (clk_signal) ---------
  //! * Interpretamos "ciclo" de clk_out como media oscilación (flanco a flanco).
  //!  Por eso contamos ambos flancos (posedge/negedge): 2 flancos = 1 periodo.
  //!  Tras 2 flancos, hex0 debe INCREMENTAR (0..9), entre medias debe mantenerse.

  int edge_cnt;           // cuenta de flancos de clk_out (clk_signal)
  int last_digit;         // dígito previo (0..9)
  int curr_digit;         // dígito actual (0..9)
  int increments_seen;    // cuántos incrementos válidos vimos

  initial begin
    // Reset y arranque
    rstn = 0; start_stop = 0;
    repeat (5) @(posedge clk);
    rstn = 1; start_stop = 1;

    // Esperar a que hex0 muestre un patrón válido y tomar referencia
    wait (seg_to_bcd(hex0) != 4'hF);
    last_digit       = seg_to_bcd(hex0);
    edge_cnt         = 0;
    increments_seen  = 0;

    // Monitorear el reloj dividido interno del DUT
    // (clk_out del divisor se llama clk_signal dentro de digital_clock)
    repeat (40) begin // 40 flancos -> 20 periodos -> >=10 incrementos
      @(posedge uut.clk_signal or negedge uut.clk_signal);
      edge_cnt++;

      curr_digit = seg_to_bcd(hex0);
      assert (curr_digit != 4'hF)
        else $fatal("Patrón 7-seg inválido en hex0=%b", hex0);

      if ((edge_cnt % 2) == 0) begin
        // Cada 2 flancos (1 periodo completo) debe INCREMENTAR 0..9
        int expected = (last_digit + 1) % 10;
        assert (curr_digit == expected)
          else $error("hex0 NO incrementó cada 2 ciclos: esp=%0d obt=%0d (hex0=%b, flancos=%0d)",
                      expected, curr_digit, hex0, edge_cnt);
        last_digit = curr_digit;
        increments_seen++;
      end
      else begin
        // Entre medias debe mantenerse
        assert (curr_digit == last_digit)
          else $error("hex0 cambió ANTES de completar 2 ciclos: prev=%0d ahora=%0d (flancos=%0d)",
                      last_digit, curr_digit, edge_cnt);
      end
    end

    // Debe haber recorrido al menos 0..9
    assert (increments_seen >= 10)
      else $error("Se esperaban >=10 incrementos (0..9). Vistos=%0d", increments_seen);

    $display("CHECK OK: hex0 incrementa cada 2 ciclos de clk_out y recorre 0..9 en 7-seg.");
    $finish;
  end

endmodule

