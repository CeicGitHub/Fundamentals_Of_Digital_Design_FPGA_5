`timescale 1ns / 1ps

//! Course: Certificación en diseño de circuitos integrados digitales
//? Client: COCYTEN 2024
//todo Owner: Team9_ 
//** Laboratory9: Events

module tb_event;

  bit p, q;
  event ev;

  always_comb begin
    p = q;
    ->ev;
  end

  initial begin
    repeat (10) begin
      q = 1;
      #1;
      q = 0;
      //wait (ev.triggered);
      @(ev); // This is another alternative
      $display(p);
    end
  end

endmodule
