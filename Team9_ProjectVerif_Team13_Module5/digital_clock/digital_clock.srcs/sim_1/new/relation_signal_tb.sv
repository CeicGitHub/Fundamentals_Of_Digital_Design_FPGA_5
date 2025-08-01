`timescale 1ns/1ps

module tb_digital_clock_verificacion;

    parameter CLK_PERIOD = 20; // 50 MHz
    reg clk;
    reg rstn;
    reg start_stop;
    wire [6:0] hex0, hex1, hex2, hex3;

    // Instancia del DUT
    digital_clock uut (
        .clk(clk),
        .rstn(rstn),
        .start_stop(start_stop),
        .hex0(hex0),
        .hex1(hex1),
        .hex2(hex2),
        .hex3(hex3)
    );

    // Generación del reloj
    initial clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;

    // Función para obtener patrón esperado según dígito BCD
    function [6:0] expected_seg(input [3:0] bcd);
        case (bcd)
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
            default: expected_seg = 7'b1111111; // apagado
        endcase
    endfunction

    initial begin
        $display("Iniciando verificación del reloj digital con valores BCD y salida 7 segmentos...");
        
        // Reset inicial
        rstn = 0; start_stop = 0;
        #(5*CLK_PERIOD);
        rstn = 1;

        // Activar reloj
        start_stop = 1;

        // Esperamos suficiente tiempo para cubrir 0:00 hasta al menos 1 minuto
        // Cada incremento de segundo depende del divisor en clk_div (ajústalo si es necesario para simulación rápida)
        repeat (70) begin // 70 incrementos para probar múltiples valores
            #(200); // Tiempo simbólico para permitir cambio (ajusta según divisor en DUT)
            
            // Aserciones para hex0, hex1, hex2, hex3
            assert(hex0 == expected_seg(uut.sec_units))
                else $error("Error en hex0 (segundos unidad) esperado=%b obtenido=%b", expected_seg(uut.sec_units), hex0);

            assert(hex1 == expected_seg(uut.sec_tens))
                else $error("Error en hex1 (segundos decena) esperado=%b obtenido=%b", expected_seg(uut.sec_tens), hex1);

            assert(hex2 == expected_seg(uut.min_units))
                else $error("Error en hex2 (minutos unidad) esperado=%b obtenido=%b", expected_seg(uut.min_units), hex2);

            assert(hex3 == expected_seg(uut.min_tens))
                else $error("Error en hex3 (minutos decena) esperado=%b obtenido=%b", expected_seg(uut.min_tens), hex3);
        end

        $display("Verificación completada sin errores (si no se mostraron mensajes de fallo).");
        $finish;
    end

endmodule
