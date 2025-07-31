`timescale 1ns / 1ps

// Company: CINVESTAV - Team9
// Create Date: 06/18/2025 05:16:25 PM
// Design Name: Project Module5
// Module Name: pwm_8bit_500hz
// Project Name: 8-bit Pulse-Width Modulation (PWM) 500 Hz 
// Target Devices: AMD Zynq™ UltraScale+™ MPSoC ZCU104 Evaluation Kit
// Tool Versions: VIVADO
// Description:  Genera una señal PWM de 8 bits a 500 Hz utilizando contadores y comparación.

//**Revision: 01
//**Additional Comments:

module pwm_8bit_500hz #( parameter CLK_FREQ_HZ = 50_000_000)  //! Frecuencia del reloj del sistema en Hz )

(
    input  logic        clk,            //! Señal Del Reloj del Sistema
    input  logic        rst,            //! Señal De Reinicio Sincronico (Activo en alto)
    input  logic [7:0]  duty_cycle,     //! Señal ciclo de trabajo de PWM (0–255)

    output logic        pwm_out         //! Señal De Salida del PWM
);
    //* NOTA: Aqui no usamos bit [7:0] pwm_counter, por que si existiera un error de logica no podriamos detectar "X" por que bit no detecta "X".

    //! Numero maximo de pasos del contados PWM (resolucion de 8-bit = 256 niveles)
    localparam int PWM_RESOLUTION   = 256; 

    //! Aqui se calcula cuantos ciclos de reloj se requieren por cada paso del contador PWM
    //! Esto asegura la frecuencia del PWM deseada
    localparam int PWM_TARGET_FREQ  = 500; 
    localparam int TICKS_PER_STEP   = CLK_FREQ_HZ / (PWM_TARGET_FREQ * PWM_RESOLUTION);
    
    //! Tamaño De Ancho De Bit Necesario para contar hasta TICKS_PER_STEP
    localparam int TICK_COUNTER_WIDTH = $clog2(TICKS_PER_STEP);

    //! Contador que acumula los ciclos de reloj hasta alcanzar un paso del PWM
    logic [TICK_COUNTER_WIDTH-1:0] tick_counter;

    //! Contador de 8 bits que determina el valor actual del PWM (0–255)
    logic [7:0] pwm_counter;

    //* Logica Secuencial Principal (Maneja conteo de ticks e incremento contador PWM)
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            //! Si se activa "reset", se reinician ambos contadores
            //? tiempo ejecución
            tick_counter <= 0;
            pwm_counter  <= 0;
            //? tiempo ejecución
        end else begin
            if (tick_counter == TICKS_PER_STEP - 1) begin
                //! Cuando se alcanza el número de ticks por paso, se reinicia el "contador de ticks"
                //! tambien se incremente el contador PWM
                tick_counter <= 0;
                pwm_counter  <= pwm_counter + 1;
            end else begin
                //! Se incrementa tick_counter hasta alcanzar TICKS_PER_STEP (si aun no llega, sigue contando ticks)
                tick_counter <= tick_counter + 1;
            end
        end
    end

    //* Logica Combinacional De Salida (Se genera la salida PWM comparando el "contador" con el "duty_cycle")
    always_comb begin
        //! Si el valor "contador" es menor al ciclo de trabajo, la salida es alta 
        //! de lo contrario la salida es baja
        pwm_out = (pwm_counter < duty_cycle);  
    end

endmodule


