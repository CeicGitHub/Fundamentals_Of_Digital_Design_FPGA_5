`timescale 1ns / 1ps

//! Course: Certificación en diseño de circuitos integrados digitales
//? Client: COCYTEN 2024
//todo Owner: Team9_ 
//** Laboratory: message_class_sv

// This is a class, which is a user-defined data type
class message_class;

  string message; // Class property
  
  // The new method is the constructor of the class in SystemVerilog
  // The constructor method is used to create an object of this class type
  function new();
    message = "Hello world! This Is The First Lab Module 5 CINVESTAV";
  endfunction

  // Method to print the message member
  function void print_message();
    $display("%S", this.message);
  endfunction

endclass

// message_class2 is extended from the message_class, therefore
// this class (message_class2) inherits all the members from the parent class (message_class)
class message_class2 extends message_class;
  
  string message2; // Class property
  
  // The new method is the constructor of the class in SystemVerilog
  // The constructor method is used to create an object of this class type
  function new();
    super.new(); // Invokes the message_class constructor method
    message2 = "We are Team9";
  endfunction

  // Method to print the message2 member
  // This method also calls the print_message method inherited from parent class
  function void print_message2();
    this.print_message(); // Invokes the inherited print_message method
    $display("%S", this.message2);
  endfunction
  
endclass

module tb;

  // Creates a handler for a variable called printer_, of message_class2 type
  message_class2 printer_;
  
  initial begin
    // Creates an object of message_class2 type, and links the object printer_ handler using the constructor
    printer_ = new();
    
    // Invokes the print_message2 method of printer_ object for printing the messages members
    printer_.print_message2();
    
    // Assign a new value to message member of printer_ object
    printer_.message = "Testing print message1....";
    
    // Assign a new value to message2 member of printer_ object
    printer_.message2 = "Finishing Testing print message...";
    
    // Print the message member of printer_ object
    $display("%s", printer_.message);
    
    // Print the message2 member of printer_ object
    $display("%s", printer_.message2);
    
    // Finishes the simulation
    $finish;
    
  end

endmodule
