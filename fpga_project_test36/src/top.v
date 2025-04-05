module top(
    input           clk,          // Clock hệ thống 100 MHz
    input           rst_n,        // Reset active low

    output          lcd_scl,      // SCL cho LCD
    inout           lcd_sda,      // SDA cho LCD

    output          sensor_trig,  // Trig của HC-SR04
    input           sensor_echo,  // Echo của HC-SR04

    output          buzzer        // Còi báo động
);

    // ------------------------------------------
    // Tạo clock 1 MHz từ clock gốc 100 MHz
    // ------------------------------------------
    wire clk_1MHz;
    clk_divider clk_1MHz_gen (
        .clk      (clk),
        .clk_1MHz (clk_1MHz)
    );

    // ------------------------------------------
    // Tạo tín hiệu đo khoảng cách mỗi 250ms
    // ------------------------------------------
    wire measure_signal;
    refresher250ms refresher_inst (
        .clk     (clk_1MHz),
        .en      (1'b1),
        .measure (measure_signal)
    );

    // ------------------------------------------
    // Kết nối cảm biến HC-SR04
    // ------------------------------------------
    wire [21:0] distance_raw;
    wire sensor_ready;
    wire [1:0] sensor_state;
    hc_sr04 #(.ten_us(10'd10)) sensor_inst (
        .clk_1MHz    (clk_1MHz),
        .rst         (~rst_n),
        .measure     (measure_signal),
        .state       (sensor_state),
        .ready       (sensor_ready),
        .echo        (sensor_echo),
        .trig        (sensor_trig),
        .distanceRAW (distance_raw)
    );

    // ------------------------------------------
    // Chuyển đổi dữ liệu cảm biến sang ASCII
    // ------------------------------------------
    wire [127:0] ascii_data;
    sensor_data_to_ascii sensor_to_ascii_inst (
        .sensor_data(distance_raw[15:0]),
        .ascii_row  (ascii_data)
    );

    // ------------------------------------------
    // Tạo chuỗi hiển thị cho LCD dựa trên giá trị từ sensor (theo ASCII)
    // ------------------------------------------
    // Giả sử sensor_raw được tính theo đơn vị tương ứng:
    // - 1 m ≈ 580 đơn vị
    // - Khi đo được ≥ 1m, hiển thị "SAFE" (hàng thứ nhất) và hàng thứ hai trống.
    // - Khi đo dưới 1m, hiển thị "DANGER" (hàng thứ nhất) và hiển thị giá trị cảm biến ở hàng thứ hai.
    wire [127:0] row1;
    wire [127:0] row2;
    
    assign row1 = (distance_raw >= 16'd1000)              ? "SAFE            "  :
              ((distance_raw >= 16'd500)             ? "WARNING         "  :
                                                       "DANGER          ");

    assign row2 = (distance_raw <  16'd1000)              ? ascii_data        :
                                                       "                ";

    // ------------------------------------------
    // Kích hoạt còi khi khoảng cách dưới 20cm.
    // Theo giả sử 20cm tương đương khoảng 116 đơn vị (điều chỉnh nếu cần)
    // ------------------------------------------
    assign buzzer = (distance_raw[15:0] <= 16'd500) ? 1'b1 : 1'b0;

    // ------------------------------------------
    // State machine điều phối cập nhật LCD
    // ------------------------------------------
    reg [1:0] lcd_state;
    localparam IDLE   = 2'd0,
               UPDATE = 2'd1,
               DONE   = 2'd2;

    always @(posedge clk_1MHz or negedge rst_n) begin
        if (!rst_n)
            lcd_state <= IDLE;
        else begin
            case (lcd_state)
                IDLE: begin
                    if (sensor_ready)
                        lcd_state <= UPDATE;
                end
                UPDATE: begin
                    if (lcd_done)
                        lcd_state <= DONE;
                end
                DONE: begin
                    lcd_state <= IDLE;
                end
            endcase
        end
    end

    wire lcd_en = (lcd_state == UPDATE);

    // ------------------------------------------
    // Giao tiếp LCD qua I2C
    // ------------------------------------------
    wire lcd_done;
    wire [7:0] lcd_data;
    wire lcd_cmd_data;
    wire lcd_ena;

    lcd_display lcd_display_inst (
        .clk_1MHz   (clk_1MHz),
        .rst_n      (rst_n),
        .ena        (lcd_en),
        .done_write (lcd_done),
        .row1       (row1),
        .row2       (row2),
        .data       (lcd_data),
        .cmd_data   (lcd_cmd_data),
        .ena_write  (lcd_ena)
    );

    lcd_write_cmd_data lcd_write_cmd_data_inst (
        .clk_1MHz   (clk_1MHz),
        .rst_n      (rst_n),
        .data       (lcd_data),
        .cmd_data   (lcd_cmd_data),
        .ena        (lcd_ena),
        .i2c_addr   (7'h27),
        .sda        (lcd_sda),
        .scl        (lcd_scl),
        .done       (lcd_done)
    );

endmodule
