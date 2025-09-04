
module tb_digital_clock;  // Módulo de prueba para el módulo digital_clock

    // Parámetro para definir el período del reloj de prueba (20 ns = 50 MHz)
    parameter CLK_PERIOD = 20;  // 50 MHz => 20 ns

    // Declaración de señales de prueba
    logic clk;                // Señal de reloj
    logic rstn;               // Señal de reset (activa en bajo)
    logic start_stop;         // Señal para iniciar o detener el reloj
    wire [6:0] hex0, hex1;    // Salidas del display para segundos (unidades y decenas)
    wire [6:0] hex2, hex3;    // Salidas del display para minutos (unidades y decenas)

    // Instancia del módulo bajo prueba (DUT: Device Under Test)
    digital_clock uut (
        .clk(clk),            // Conecta reloj al DUT
        .rstn(rstn),          // Conecta reset al DUT
        .start_stop(start_stop), // Conecta control de inicio/parada
        .hex0(hex0),          // Conecta salida de unidades de segundo
        .hex1(hex1),          // Conecta salida de decenas de segundo
        .hex2(hex2),          // Conecta salida de unidades de minuto
        .hex3(hex3)           // Conecta salida de decenas de minuto
    );

    // Bloque inicial para generar una señal de reloj de 50 MHz
    initial clk = 0;          // Inicializa el reloj en 0
    always #(CLK_PERIOD/2) clk = ~clk;  // Invierte el reloj cada 10 ns para crear un período de 20 ns

    // Bloque inicial para aplicar los estímulos al DUT
    initial begin
        $display("Iniciando simulación..."); // Mensaje de inicio de simulación

        rstn = 0;              // Activa el reset (activo en bajo)
        start_stop = 0;        // Inicializa el control en modo detenido

        #(5 * CLK_PERIOD);     // Espera 5 ciclos de reloj (100 ns aprox.)
        rstn = 1;              // Libera el reset
        $display("Reset liberado");

        #(20 * CLK_PERIOD);    // Espera 20 ciclos de reloj antes de iniciar
        start_stop = 1;        // Activa el reloj (comienza el conteo)
        $display("Start");

        // Deja correr la simulación por suficiente tiempo para observar conteo
        #(3000 * CLK_PERIOD);  // Espera 3000 ciclos de reloj (60 μs aprox. con CLK = 50 MHz)

        // Detiene el reloj
        start_stop = 0;        // Detiene el conteo
        $display("Stop");
        #(100 * CLK_PERIOD);   // Espera un poco antes de continuar

        // Reanuda el reloj
        start_stop = 1;        // Activa nuevamente el conteo
        $display("Start de nuevo");
        #(2000 * CLK_PERIOD);  // Espera adicional para observar el comportamiento

        $finish;               // Finaliza la simulación
    end
    
    //todo: checker sin sva: congelamiento durante la pausa

logic [5:0] seconds_snap, minutes_snap;
logic [6:0] hex0_snap, hex1_snap, hex2_snap, hex3_snap;
logic in_pause;

// Detecta caída a pausa y toma snapshot
always @(posedge uut.clk_signal or negedge rstn) begin
  if (!rstn) begin
    in_pause     <= 1'b0;
    seconds_snap <= '0;
    minutes_snap <= '0;
    hex0_snap    <= '0;
    hex1_snap    <= '0;
    hex2_snap    <= '0;
    hex3_snap    <= '0;
  end else begin
    // entrando a pausa
    if (!start_stop && !in_pause) begin
      in_pause     <= 1'b1;
      seconds_snap <= uut.seconds;
      minutes_snap <= uut.minutes;
      hex0_snap    <= hex0;
      hex1_snap    <= hex1;
      hex2_snap    <= hex2;
      hex3_snap    <= hex3;
    end
    // saliendo de pausa
    if (start_stop && in_pause)
      in_pause <= 1'b0;

    // Mientras esté en pausa, verificar que nada cambie
    if (in_pause) begin
      if (uut.seconds !== seconds_snap || uut.minutes !== minutes_snap)
        $error("[PAUSE] seconds/minutes cambiaron en pausa: got %0d:%0d, exp %0d:%0d",
               uut.minutes, uut.seconds, minutes_snap, seconds_snap);
      if ({hex3,hex2,hex1,hex0} !== {hex3_snap,hex2_snap,hex1_snap,hex0_snap})
        $error("[PAUSE] hex* cambió en pausa");
    end
  end
end

endmodule