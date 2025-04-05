module sensor_data_to_ascii(
    input wire [21:0] sensor_data,  // Giá trị raw từ cảm biến (đơn vị µs)
    output wire [127:0] ascii_row   // Chuỗi ASCII hiển thị trên LCD
);
    reg [15:0] cm_value;   // Giá trị khoảng cách tính theo cm (sau khi chuyển đổi)
    reg [7:0] thousands, hundreds, tens, ones;
    reg [15:0] temp;

    always @(*) begin
        // Chuyển đổi từ µs sang cm theo công thức:
        // distanceCm = sensor_data * 0.034/2 = sensor_data * 0.017
        // Ta xấp xỉ bằng cách: cm_value ≈ sensor_data / 58
        cm_value = sensor_data / 16;
        temp = cm_value;
        thousands = temp / 1000;
        temp = temp % 1000;
        hundreds  = temp / 100;
        temp = temp % 100;
        tens      = temp / 10;
        ones      = temp % 10;
    end

    // Tạo chuỗi ASCII gồm tiền tố "SENS: " và giá trị đo theo cm, kèm đơn vị " cm"
    assign ascii_row = { "SENS: ",
                         8'd48 + thousands, 
                         8'd48 + hundreds, 
                         8'd48 + tens, 
                         8'd48 + ones, 
                         " cm   " };
endmodule
