`timescale 1ns/1ns

module comparator_4bit_tb;
    reg [3:0] A,B;
    wire C;

    comparator_4bit cur(
        .A(A),
        .B(B),
        .C(C)
    );

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, comparator_4bit_tb);

        A = 4'b0000; B = 4'b0000; #10;
        A = 4'b1010; B = 4'b1010; #10;
        A = 4'b1111; B = 4'b0000; #10;
        A = 4'b0101; B = 4'b1010; #10;

        $display("successful");

        $finish;
    end
endmodule

