module refresher250ms(
  input clk,        // 1 MHz
  input en,         // Enable tín hiệu làm mới
  output measure    // Tín hiệu đo
);
  reg [24:0] counter;

  assign measure = (counter == 25'd250_000);  // Đếm đến 250,000 để có 250 ms

  always @(posedge clk) begin
    if (~en || (counter == 25'd250_000)) // Reset bộ đếm hoặc khi đếm xong
      counter <= 25'd0;
    else
      counter <= counter + 1;  // Tăng bộ đếm mỗi chu kỳ xung
  end
endmodule