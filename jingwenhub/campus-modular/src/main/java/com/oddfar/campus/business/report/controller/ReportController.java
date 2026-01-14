package com.oddfar.campus.business.report.controller;

import com.oddfar.campus.business.report.domain.dto.ReportDTO;
import com.oddfar.campus.business.report.domain.vo.ReportVO;
import com.oddfar.campus.business.report.service.ReportService;
import com.oddfar.campus.common.domain.PageResult;
import com.oddfar.campus.common.domain.R;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import io.swagger.annotations.ApiParam;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

/**
 * 举报控制器
 */
@Api(tags = "举报管理")
@RestController
@RequestMapping("/api/v1/report")
public class ReportController {

    @Autowired
    private ReportService reportService;

    @ApiOperation("提交举报")
    @PostMapping
    public R submitReport(@RequestBody @Validated ReportDTO reportDTO) {
        Long reportId = reportService.submitReport(reportDTO);
        return R.ok().put("reportId", reportId);
    }

    // ==================== 管理员接口 ====================

    @ApiOperation("获取举报列表")
    @PreAuthorize("@ss.hasPermi('report:list')")
    @GetMapping("/list")
    public R getReportList(
            @ApiParam("状态: 0待处理 1已处理 2已忽略") @RequestParam(required = false) Integer status,
            @RequestParam(defaultValue = "1") Integer pageNum,
            @RequestParam(defaultValue = "10") Integer pageSize) {
        PageResult<ReportVO> result = reportService.getReportList(status, pageNum, pageSize);
        return R.ok().put(result);
    }

    @ApiOperation("获取举报详情")
    @PreAuthorize("@ss.hasPermi('report:query')")
    @GetMapping("/{reportId}")
    public R getReportDetail(@PathVariable Long reportId) {
        ReportVO detail = reportService.getReportDetail(reportId);
        return R.ok(detail);
    }

    @ApiOperation("处理举报")
    @PreAuthorize("@ss.hasPermi('report:handle')")
    @PostMapping("/handle/{reportId}")
    public R handleReport(
            @PathVariable Long reportId,
            @ApiParam("是否处理(true处理/false忽略)") @RequestParam Boolean handled,
            @ApiParam("处理备注") @RequestParam(required = false) String remark) {
        reportService.handleReport(reportId, handled, remark);
        return R.ok(handled ? "已处理" : "已忽略");
    }
}
