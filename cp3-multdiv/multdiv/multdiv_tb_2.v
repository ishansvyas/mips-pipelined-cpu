`timescale 1ns/100ps
module multdiv_tb_2;

    // module inputs
    reg clock = 0, ctrl_Mult, ctrl_Div, interrupt;
    reg signed [31:0] operandA, operandB;

    // expected module outputs
    reg exp_except;
    reg signed [31:0] exp_result;

    // module outputs
    wire ready, except;
    wire signed [31:0] result;

	// TEST
	wire [65:0] reg_PROD_out_test, sra_in_mxa, sra_out_mxa;
	wire [32:0] plus2m_mxa, plusm_mxa, minusm_mxa, minus2m_mxa;

    // Instantiate multdiv
    multdiv tester(operandA, operandB, ctrl_Mult, ctrl_Div, clock,
        result, except, ready, reg_PROD_out_test, 
		// test
		plus2m_mxa, plusm_mxa, minusm_mxa, minus2m_mxa, sra_in_mxa, sra_out_mxa);

	// Initialize our strings
	reg[511:0] testName, outDir;

	// Where to store file error codes
	integer 	expFile,		diffFile, 	  actFile,
				expScan;

	// Metadata
	integer errors = 0,
			tests = 0;

	reg[7:0] counter = 0;
	integer i = 0;

	initial begin
		// Assign Command Line Arguments to the Inputs
		if(! $value$plusargs("test=%s", testName)) begin
			$display("Please specify the test");
			$finish;
		end

		// Output file name
        $dumpfile({testName, ".vcd"});
        // Module to capture and what level, 0 means all wires
        $dumpvars(0, multdiv_tb_2);

		// Read the expected file
		expFile = $fopen({testName, "_exp.csv"}, "r");

		// Check for any errors in opening the file
		if(!expFile) begin
			$display("Couldn't read the output file.",
				"\nMake sure you are in the right directory and the %0s_exp.csv file exists.", testName);
			$finish;
		end

		// Create the files to store the output
		actFile   = $fopen({testName, "_actual.csv"},   "w");
		diffFile  = $fopen({testName, "_diff.csv"},  "w");

		// Add the headers to the Actual and Difference files
		$fdisplay(actFile, "OperandA, OperandB, Result, Exception");
		$fdisplay(diffFile, "Test Number, OperandA, OperandB, Result, Exception, Exp Result, Exp Exception");

		// Ignore the header of the Expected file
		expScan = $fscanf(expFile, "%s,%s,%s,%s,%s,%s,%s,%s", 
			operandA, operandB, 
			ctrl_Mult, ctrl_Div, interrupt, 
			exp_result, exp_except);

		if(expScan == 0) begin
			$display("Error reading the %0s file.\nMake sure there are no spaces in your file.\nYou can check by opening it in a text editor.", {testName, "_exp.csv"});
		end

		// Get the first line of the expected file
		expScan = $fscanf(expFile, "%d,%d,%d,%d,%d,%d,%d", 
			operandA, operandB, 
			ctrl_Mult, ctrl_Div, interrupt,
			exp_result, exp_except);

		// Iterate until reaching the end of the file
		while(expScan == 7) begin

			tests = tests + 1;

			@(negedge clock);
			{ctrl_Mult, ctrl_Div} = 0;

			if(interrupt) begin
				for (i = 0; i < 5; i = i + 1) begin
					@(negedge clock);
				end
			end else begin
				for (i = 0; i < 100; i = i + 1) begin
					@(negedge clock);

					if(ready) begin
						i = 150;
					end
				end

                if (i == 100) begin
                    $display("Test %3d: Timed Out", tests);
    
                    // Write the timed out module outputs to the actual file
				    $fdisplay(actFile, "%d,%d,Timed Out, Timed Out",
                        operandA, operandB);

                    // Increment the Errors
                    errors = errors + 1;

                    // Output any differences to the difference file
                    $fdisplay(diffFile, "%0d,%d,%d,Timed Out,Timed Out,%d,%d",
                        tests,
                        operandA, operandB, 
                        exp_result, exp_except);

                end else begin
                    // Write the actual module outputs to the actual file
                    $fdisplay(actFile, "%d,%d,%d,%d",
                        operandA, operandB, 
                        result, except);
        
				
                    // Check for any inaccuracies in the module output and the expected output
                    if((result !== exp_result) | (except !== exp_except)) begin

                        // Increment the Errors
                        errors = errors + 1;

                        // Output any differences to the difference file
                        $fdisplay(diffFile, "%0d,%d,%d,%d,%d,%d,%d",
                            tests,
                            operandA, operandB, 
                            result, except,
                            exp_result, exp_except);
                        $display("Test %3d: FAILED", tests);
                    end else begin
                        $display("Test %3d: PASSED", tests);
                    end
                end

				@(negedge clock);
			end

			// Read the next line
			expScan = $fscanf(expFile, "%d,%d,%d,%d,%d,%d,%d", 
				operandA, operandB, 
				ctrl_Mult, ctrl_Div, interrupt,
				exp_result, exp_except);
		end

		// Close the Files
		$fclose(expFile);
		$fclose(actFile);
		$fclose(diffFile);

		// Display the tests and errors
		$display("Finished %0d test%c with %0d error%c \n", tests, "s"*(tests != 1), errors, "s"*(errors != 1));

		#100;
		$finish;
	end

    always 
    	#20 clock = !clock;

endmodule
