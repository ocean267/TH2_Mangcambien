module hc_sr04#(parameter ten_us = 10'd10)(
  input clk_1MHz, // Sử dụng xung 1 MHz
  input rst,
  input measure,
  output reg [1:0] state,
  output ready,
  // HC-SR04 signals
  input echo,
  output trig,
  output reg [21:0] distanceRAW
);

  localparam IDLE = 2'b00,
             TRIGGER = 2'b01,
             WAIT = 2'b11,
             COUNTECHO = 2'b10;

  wire inIDLE, inTRIGGER, inWAIT, inCOUNTECHO;
  reg [9:0] counter;
  wire trigcountDONE;

  // Ready
  assign ready = inIDLE;
  
  // Decode states
  assign inIDLE = (state == IDLE);
  assign inTRIGGER = (state == TRIGGER);
  assign inWAIT = (state == WAIT);
  assign inCOUNTECHO = (state == COUNTECHO);

  // State transitions
  always @(posedge clk_1MHz or posedge rst) begin
    if (rst)
      state <= IDLE;
    else begin
      case (state)
        IDLE: state <= (measure & ready) ? TRIGGER : state;
        TRIGGER: state <= (trigcountDONE) ? WAIT : state;
        WAIT: state <= (echo) ? COUNTECHO : state;
        COUNTECHO: state <= (echo) ? state : IDLE;
      endcase
    end
  end

  // Trigger signal
  assign trig = inTRIGGER;

  // Counter for pulse width (10us trigger pulse)
  always @(posedge clk_1MHz) begin
    if (inIDLE)
      counter <= 10'd0;
    else if (inTRIGGER)
      counter <= counter + 1;
  end
  assign trigcountDONE = (counter == ten_us);

  // Capture distance value based on echo signal
  always @(posedge clk_1MHz) begin
    if (inWAIT)
      distanceRAW <= 22'd0;
    else if (inCOUNTECHO)
      distanceRAW <= distanceRAW + 1; // Tăng dần khi echo còn mức cao
  end

endmodule
