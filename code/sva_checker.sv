module sva_checker #(
    parameter int DATA_WIDTH = 32,
    parameter int MAXWAIT    = 16
)(
    axi_intf axi
);

    // =========================================================================
    // 1. WRITE ADDRESS CHANNEL (AW) ASSERTIONS
    // =========================================================================

    // AWVALID và AWREADY không được mang giá trị X/Z khi có reset hoặc hoạt động
    AXI_WA_HANDSHAKING_CHECK: assert property (
        @(posedge axi.ACLK) disable iff (!axi.ARESETn)
        !$isunknown({axi.AWVALID, axi.AWREADY})
    ) else $error("[FAIL] time: %t | (%m) AXI_WA_HANDSHAKING_CHECK: X/Z detected on AWVALID or AWREADY", $realtime);

    // Khi AWVALID bật, các tín hiệu điều khiển/địa chỉ phải ổn định cho đến khi AWREADY bật
    AXI_WA_STABLE_SIGNALS_CHECK: assert property (
        @(posedge axi.ACLK) disable iff (!axi.ARESETn)
        (axi.AWVALID && !axi.AWREADY) |=> ((axi.AWVALID &&
                                           $stable({axi.AWID, axi.AWADDR, axi.AWLEN, axi.AWSIZE,
                                                    axi.AWBURST, axi.AWLOCK, axi.AWPROT}))
                                           until_with axi.AWREADY)
    ) else $error("[FAIL] time: %t | (%m) AXI_WA_STABLE_SIGNALS_CHECK: AW payload changed while waiting for AWREADY", $realtime);

    // Không được có giá trị X/Z trên payload của kênh AW khi AWVALID HIGH
    AXI_WA_UNKNOWN_VALUE_CHECK: assert property (
        @(posedge axi.ACLK) disable iff (!axi.ARESETn)
        axi.AWVALID |-> !$isunknown({axi.AWID, axi.AWADDR, axi.AWLEN, axi.AWSIZE, 
                                    axi.AWBURST, axi.AWLOCK, axi.AWPROT})
    ) else $error("[FAIL] time: %t | (%m) AXI_WA_UNKNOWN_VALUE_CHECK: Unknown (X/Z) value on AW payload", $realtime);

    // AWVALID phải giữ nguyên cho đến khi AWREADY HIGH
    AXI_WA_VALID_STABLE_CHECK: assert property (
        @(posedge axi.ACLK) disable iff (!axi.ARESETn)
        (axi.AWVALID && !axi.AWREADY) |=> (axi.AWVALID until_with axi.AWREADY)
    ) else $error("[FAIL] time: %t | (%m) AXI_WA_VALID_STABLE_CHECK: AWVALID dropped before AWREADY", $realtime);

    // AWREADY phải được phản hồi trong vòng MAXWAIT chu kỳ
    AXI_WA_MAX_WAIT_CHECK: assert property (
        @(posedge axi.ACLK) disable iff (!axi.ARESETn)
        (axi.AWVALID && !axi.AWREADY) |-> ##[1:MAXWAIT] axi.AWREADY
    ) else $error("[FAIL] time: %t | (%m) AXI_WA_MAX_WAIT_CHECK: AWREADY timeout (>%0d cycles)", $realtime, MAXWAIT);

    // Không cho phép mã burst = 2'b11 (Reserved)
    AXI_WA_BURST_CHECK: assert property (
        @(posedge axi.ACLK) disable iff (!axi.ARESETn)
        axi.AWVALID |-> (axi.AWBURST != 2'b11)
    ) else $error("[FAIL] time: %t | (%m) AXI_WA_BURST_CHECK: AWBURST uses reserved value 2'b11", $realtime);

    // Kiểm tra kích thước AWSIZE không vượt quá độ rộng bus dữ liệu
    AXI_WA_SIZE_CHECK: assert property (
        @(posedge axi.ACLK) disable iff (!axi.ARESETn)
        axi.AWVALID |-> ((1 << axi.AWSIZE) <= (DATA_WIDTH / 8))
    ) else $error("[FAIL] time: %t | (%m) AXI_WA_SIZE_CHECK: AWSIZE exceeds data bus width", $realtime);


    // =========================================================================
    // 2. WRITE DATA CHANNEL (W) ASSERTIONS
    // =========================================================================

    AXI_WD_HANDSHAKING_CHECK: assert property (
        @(posedge axi.ACLK) disable iff (!axi.ARESETn)
        !$isunknown({axi.WVALID, axi.WREADY})
    ) else $error("[FAIL] time: %t | (%m) AXI_WD_HANDSHAKING_CHECK: X/Z on WVALID/WREADY", $realtime);

    //WDATA and WSTRB remains stable when WVALID is asserted and WREADY is LOW
   AXI_WD_STABLE_SIGNALS_CHECK: assert property (
    @(posedge axi.ACLK) disable iff (!axi.ARESETn)
    (axi.WVALID && !axi.WREADY)
    |=> (axi.WVALID &&
         $stable({axi.WDATA, axi.WSTRB, axi.WLAST}))
        until_with axi.WREADY
    ) else $error(
        "[FAIL] time: %t | (%m) AXI_WD_STABLE_SIGNALS_CHECK: WDATA/WSTRB/WLAST changed while WREADY is LOW", $realtime
    );

    AXI_WD_UNKNOWN_SIGNALS_CHECK: assert property (
        @(posedge axi.ACLK) disable iff (!axi.ARESETn)
        axi.WVALID |-> (!$isunknown(axi.WSTRB) && !$isunknown(axi.WLAST))
    ) else $error("[FAIL] time: %t | (%m) AXI_WD_UNKNOWN_SIGNALS_CHECK: Unknown value on WSTRB or WLAST", $realtime);

    AXI_WD_MAX_WAIT_CHECK: assert property (
        @(posedge axi.ACLK) disable iff (!axi.ARESETn)
        (axi.WVALID && !axi.WREADY) |-> ##[1:MAXWAIT] axi.WREADY
    ) else $error("[FAIL] time: %t | (%m) AXI_WD_MAX_WAIT_CHECK: WREADY timeout", $realtime);


    // =========================================================================
    // 3. WRITE RESPONSE CHANNEL (B) ASSERTIONS [BỔ SUNG QUAN TRỌNG]
    // =========================================================================

    AXI_WR_HANDSHAKING_CHECK: assert property (
        @(posedge axi.ACLK) disable iff (!axi.ARESETn)
        !$isunknown({axi.BVALID, axi.BREADY})
    ) else $error("[FAIL] time: %t | (%m) AXI_WR_HANDSHAKING_CHECK: X/Z on BVALID/BREADY", $realtime);

    AXI_WR_STABLE_SIGNALS_CHECK: assert property (
        @(posedge axi.ACLK) disable iff (!axi.ARESETn)
        (axi.BVALID && !axi.BREADY) |=> ((axi.BVALID && $stable({axi.BID, axi.BRESP}))
                                         until_with axi.BREADY)
    ) else $error("[FAIL] time: %t | (%m) AXI_WR_STABLE_SIGNALS_CHECK: BID or BRESP changed while waiting for BREADY", $realtime);

    AXI_WR_UNKNOWN_SIGNALS_CHECK: assert property (
        @(posedge axi.ACLK) disable iff (!axi.ARESETn)
        axi.BVALID |-> !$isunknown({axi.BID, axi.BRESP})
    ) else $error("[FAIL] time: %t | (%m) AXI_WR_UNKNOWN_SIGNALS_CHECK: Unknown value on BID or BRESP", $realtime);


    // =========================================================================
    // 4. READ ADDRESS CHANNEL (AR) ASSERTIONS
    // =========================================================================

    AXI_RA_HANDSHAKING_CHECK: assert property (
        @(posedge axi.ACLK) disable iff (!axi.ARESETn)
        !$isunknown({axi.ARVALID, axi.ARREADY})
    ) else $error("[FAIL] time: %t | (%m) AXI_RA_HANDSHAKING_CHECK: X/Z on ARVALID/ARREADY", $realtime);

    AXI_RA_STABLE_SIGNALS_CHECK: assert property (
        @(posedge axi.ACLK) disable iff (!axi.ARESETn)
        (axi.ARVALID && !axi.ARREADY) |-> ($stable(axi.ARID)    && $stable(axi.ARADDR) && 
                                           $stable(axi.ARLEN)   && $stable(axi.ARSIZE) &&
                                           $stable(axi.ARBURST) && $stable(axi.ARLOCK) && 
                                           $stable(axi.ARPROT)  && $stable(axi.ARVALID)) until axi.ARREADY
    ) else $error("[FAIL] time: %t | (%m) AXI_RA_STABLE_SIGNALS_CHECK: AR payload changed while waiting for ARREADY", $realtime);

    AXI_RA_MAX_WAIT_CHECK: assert property (
        @(posedge axi.ACLK) disable iff (!axi.ARESETn)
        (axi.ARVALID && !axi.ARREADY) |-> ##[1:MAXWAIT] axi.ARREADY
    ) else $error("[FAIL] time: %t | (%m) axi_ra_max_wait_check: ARREADY timeout", $realtime);


    // =========================================================================
    // 5. READ DATA CHANNEL (R) ASSERTIONS & OUTSTANDING TRACKING
    // =========================================================================

    AXI_RD_STABLE_SIGNALS_CHECK: assert property (
        @(posedge axi.ACLK) disable iff (!axi.ARESETn)
        (axi.RVALID && !axi.RREADY) |-> ($stable(axi.RID)   && $stable(axi.RDATA) && 
                                           $stable(axi.RRESP) && $stable(axi.RLAST) &&
                                           $stable(axi.RVALID)) until axi.RREADY
    ) else $error("[FAIL] time: %t | (%m) AXI_RD_STABLE_SIGNALS_CHECK: Read data payload changed while waiting for RREADY", $realtime);

    AXI_RD_UNKNOWN_SIGNALS_CHECK: assert property (
        @(posedge axi.ACLK) disable iff (!axi.ARESETn)
        axi.RVALID |-> !$isunknown({axi.RID, axi.RDATA, axi.RRESP, axi.RLAST})
    ) else $error("[FAIL] time: %t | (%m) AXI_RD_UNKNOWN_SIGNALS_CHECK: Unknown value on Read Data channel", $realtime);


    // --- Outstanding Read Tracker (Kiểm tra khớp ID và số nhịp ARLEN) ---
    typedef struct {
        logic [7:0] arid;
        logic [7:0] arlen;
        int         r_count;
    } read_trans_t;

    read_trans_t outstanding_reads[$];

    always_ff @(posedge axi.ACLK or negedge axi.ARESETn) begin
        if (!axi.ARESETn) begin
            outstanding_reads.delete();
        end else begin
            // 1. Bắt giao dịch AR thành công
            if (axi.ARVALID && axi.ARREADY) begin
                read_trans_t tr;
                tr.arid    = axi.ARID;
                tr.arlen   = axi.ARLEN;
                tr.r_count = 0;
                outstanding_reads.push_back(tr);
            end

            // 2. Bắt giao dịch R dữ liệu trả về
            if (axi.RVALID && axi.RREADY) begin
                if (outstanding_reads.size() > 0) begin
                    // Kiểm tra RID khớp với transaction đầu tiên trong hàng đợi
                    assert (axi.RID == outstanding_reads[0].arid)
                        else $error("[FAIL] time: %t | (%m) AXI_RD_RID_CHECK: RID (=%0h) does not match expected ARID (=%0h)", $realtime, axi.RID, outstanding_reads[0].arid);

                    outstanding_reads[0].r_count++;

                    if (axi.RLAST) begin
                        // Kiểm tra tổng số nhịp dữ liệu khớp với ARLEN
                        assert ((outstanding_reads[0].r_count - 1) == outstanding_reads[0].arlen)
                            else $error("[FAIL] time: %t | (%m) AXI_RD_RDATA_COUNT_CHECK: RLAST received but beat count does not match ARLEN", $realtime);
                        
                        void'(outstanding_reads.pop_front());
                    end
                end else begin
                    $error("[FAIL] time: %t | (%m) AXI_RD_RID_CHECK: RVALID received without any pending read transaction", $realtime);
                end
            end
        end
    end

    // Kiểm tra cuối mô phỏng xem còn sót transaction đọc nào không hoàn tất không
    final begin
        assert (outstanding_reads.size() == 0)
            else $error("[FAIL] (%m) AXI_RD_RLAST_ALL_DONE: Simulation ended with %0d uncompleted read bursts", outstanding_reads.size());
    end

endmodule
