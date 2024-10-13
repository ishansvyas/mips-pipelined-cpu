module d_latch(Q, notQ, data, enable);
    input data, enable;
    output Q, notQ;

    wire not_data, w1l2, w1l3, w2l2, w2l3;

    // layer 1
    not l1not(not_data, data);

    // layer 2
    nand nand1(w1l2, data, enable);
    nand nand2(w2l2, not_data, enable);

    // layer 3
    nand nand3(w1l3, w1l2, w2l3);
    nand nand4(w2l3, w2l2, w1l3);

    // outputs
    assign Q = w1l3;
    assign notQ = w2l3;

endmodule