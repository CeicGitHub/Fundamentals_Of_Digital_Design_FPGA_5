module digital_clock(
    input wire clk,         // Señal de reloj
    input wire rstn,        // Señal de reset
    input wire start_stop,  // Señal de activación
    output wire [6:0] hex0, // Unidades de segundo
    output wire [6:0] hex1, // Decenas de segundo
    output wire [6:0] hex2, // Unidades de minuto
    output wire [6:0] hex3  // Decenas de minuto
);

wire clk_signal;        //  Señal de reloj para el conteo 

/* Genera una señal de reloj a partir del reloj base
y un parámetro de conteo de ciclos de reloj*/
clk_div clk_div_1 (
    .clk_in(clk),       //  Entra la señal del reloj original
    .rstn(rstn),        //  Señal de reset
    .clk_out(clk_signal)//  Señal de frecuencia reducida
);

// Registros para segundos y minutos
reg [5:0] seconds = 0;  //  6 bits para contar hasta 59
reg [5:0] minutes = 0;  //  6 bits para contar hasta 59

always @(posedge clk_signal, negedge rstn) begin
    if (!rstn) begin
        seconds <= 0;                   //  regresa el conteo a 0
        minutes <= 0;
    end else if (start_stop) begin      // funciona como un enable
        if (seconds == 59) begin        //  hace conteo hasta llegar al último valor
            seconds <= 0;               //  y resetea
            if (minutes == 59)          // Es necesario preguntar cual es el conteo de min
                minutes <= 0;           // Si este llego al final hay que resetear tambien
            else
                minutes <= minutes + 1; // Si si no ha llegado al final aumnetar 1 al conteo
        end else begin
            seconds <= seconds + 1;     // Si no ha ocurrido nada de lo anterior sumar a seg
        end
    end else if (!start_stop) begin     //
        seconds <= seconds;             // La cuenta se debe mantener
        minutes <= minutes;             // igual aqui
    end
end

// Conversión a dígitos BCD
wire [3:0] sec_units = seconds % 10;    //  el residuo de la div entre 10 la cuenta dara las undiades de seg
wire [3:0] sec_tens  = seconds / 10;    //  la división entre diez dara las decenas de seg
wire [3:0] min_units = minutes % 10;    //  Misma logica para unidades de minutos
wire [3:0] min_tens  = minutes / 10;    //  E igual para decenas de minutos

// Decodificadores BCD a 7 segmentos
bcd_to_7seg bcd0 (.bcd(sec_units), .seg(hex0)); // segundos unidades
bcd_to_7seg bcd1 (.bcd(sec_tens),  .seg(hex1)); // segundos decenas
bcd_to_7seg bcd2 (.bcd(min_units), .seg(hex2)); // minutos unidades
bcd_to_7seg bcd3 (.bcd(min_tens),  .seg(hex3)); // minutos decenas

endmodule