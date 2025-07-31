`timescale 1ns/1ns

module comparator_test_bench;
    reg A, B;
    wire o1,o2,o3;

    comparator cur(
        .A(A),
        .B(B),
        .o1(o1),
        .o2(o2),
        .o3(o3)
    );

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, comparator_test_bench);

        A=0; B=0; #10
        A=0; B=1; #10
        A=1; B=0; #10
        A=1; B=1; #10

        $display("Successful!");

        $finish;
    end

endmodule
