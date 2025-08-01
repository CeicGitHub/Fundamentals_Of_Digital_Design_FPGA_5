module bcd_to_7seg(
    input [3:0] bcd,        //  Las entradas a esto serán las unidades o decenas de seg o min del 0 a 9 (4 bits son suficientes)
    output reg [6:0] seg    //  La salida es un display de 7 segmentos
);
    always @(*) begin
        case (bcd)                  //  Para la entrada bcd y con un display anodo común
            4'd0: seg = 7'b1000000; //  0x40 (Asi se ven normalmente en la sim)
            4'd1: seg = 7'b1111001; //  0x79
            4'd2: seg = 7'b0100100; //  0x24
            4'd3: seg = 7'b0110000; //  0x30
            4'd4: seg = 7'b0011001; //  0x19
            4'd5: seg = 7'b0010010; //  0x12
            4'd6: seg = 7'b0000010; //  0x02
            4'd7: seg = 7'b1111000; //  0x78
            4'd8: seg = 7'b0000000; //  0x00
            4'd9: seg = 7'b0011000; //  0x18
            default: seg = 7'b1111111; // 0xFF (apagado)
        endcase
    end
endmodule