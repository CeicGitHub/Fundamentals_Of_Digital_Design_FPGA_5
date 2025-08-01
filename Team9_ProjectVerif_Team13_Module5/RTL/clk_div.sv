module clk_div(
    input wire clk_in,  //  Señal de reloj entrante, propia del sistema
    input wire rstn,    //  Señal de reset
    output reg clk_out  //  Señal de reloj saliente
);
    parameter DIVISOR = 2;  //  Parametro division de señal
    reg [25:0] count = 0;   //  Tamaño para 50M (Tomando la DE115 como base)

    always @(posedge clk_in, negedge rstn) begin
        if (!rstn) begin                        //  Cuando el reset se activa
            count <= 0;                         //  La cuenta se regresa
            clk_out <= 0;                       //  Y la señal de salida se pone en bajo
        end else begin                          //  Si reset no se activa
            count <= count + 1;                 //  Sumar uno a la cuenta
            if (count == DIVISOR/2 - 1) begin   //  Si llega al final
                clk_out <= ~clk_out;            //  Cambiamos el valor de la señal de salida
                count <= 0;                     //  Reseteamos la cuenta
            end
        end
    end
endmodule
