`timescale 1ns/1ps

module tb_reset_asincrono;

    parameter CLK_PERIOD = 20; // 50 MHz

    // Señales de prueba
    reg clk;
    reg rstn;
    reg start_stop;
    wire [6:0] hex0, hex1, hex2, hex3;

    // Instancia del módulo bajo prueba
    digital_clock uut (
        .clk(clk),
        .rstn(rstn),
        .start_stop(start_stop),
        .hex0(hex0),
        .hex1(hex1),
        .hex2(hex2),
        .hex3(hex3)
    );

    // Generador de reloj
    initial clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;

    // Test principal
    initial begin
        $display("Iniciando test de reset asíncrono...");

        // Paso 1: iniciar normalmente
        rstn = 1;
        start_stop = 1;
        #(200); // Esperar un tiempo para que el reloj cuente

        // Paso 2: aplicar reset en un punto no sincronizado
        $display("Aplicando reset asíncrono...");
        rstn = 0;
        #(10);  // Esperar un poco (simulación)

        // Comprobación visual con asserts
        assert(hex0 == 7'b1000000) else $error("Fallo en hex0 (esperado 0)");
        assert(hex1 == 7'b1000000) else $error("Fallo en hex1 (esperado 0)");
        assert(hex2 == 7'b1000000) else $error("Fallo en hex2 (esperado 0)");
        assert(hex3 == 7'b1000000) else $error("Fallo en hex3 (esperado 0)");

        $display("Reset asíncrono verificado correctamente.");
        $finish;
    end

endmodule