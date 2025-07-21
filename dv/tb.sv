`timescale 1ns / 1ps

// Course: Certificación en diseño de circuitos integrados digitales
// Client: COCYTEN 2024
// Owner: Team9
// Laboratory 8: parameterized_class_sv

// This is a class, which is a user-defined data type
class base_class #(parameter SIZE = 2, MAX_VALUE = 100);

  string name;
	rand bit      [SIZE - 1 : 0] var1; // Class property
  protected bit [SIZE - 2 : 0] var2; // Class property

	constraint var1_max {var1 <= MAX_VALUE;};
  
  // The new method is the constructor of the class in SystemVerilog
  // The constructor method is used to create an object of this class type
  function new(string name = "");
		// Assign name input argument to name member of base_class
		this.name = name; 
  endfunction

  // Inherited post_randomize method
  function void post_randomize();
    $display("the value of var1 for object %s in post_randomize is:\n %d", this.name, var1);
  //$display("the value of var1 for object %s in post_randomize is:\n %d", this.name, var2); //!uncooment for see the protected bit 
  endfunction

endclass

module tb;

  // Creates a handler for a variable called obj1, of base_class type
  base_class#( 4, 9) obj1;
  base_class#( .SIZE(8), .MAX_VALUE(200)) obj2;
  
  initial begin
    // Creates an object of base_class type, and links the object obj1 handler using the constructor
    obj1 = new("obj1");
    // Creates an object of base_class type, and links the object obj2 handler using the constructor
    obj2 = new("obj2");
    
    repeat(3) begin
        // Invokes the default randomization method that is inherited in all classes created in SystemVerilog
        obj1.randomize();
        obj2.randomize();
    end
    // Finishes the simulation
    $finish;
    
  end

endmodule


