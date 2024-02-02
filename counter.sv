module counter(input logic[7:0] in, output logic[2:0] sum);
    integer i;
    always @(in) begin
        sum = 0;
        for (i = 0; i < 8; i = i + 1)
            sum = sum + in[i];
    end
endmodule: counter

