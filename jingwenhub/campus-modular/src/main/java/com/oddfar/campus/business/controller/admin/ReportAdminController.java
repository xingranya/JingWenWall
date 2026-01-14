package com.oddfar.campus.business.controller.admin;

import com.oddfar.campus.business.report.domain.vo.ReportVO;
import com.oddfar.campus.business.report.service.ReportService;
import com.oddfar.campus.common.annotation.ApiResource;
import com.oddfar.campus.common.domain.PageResult;
import com.oddfar.campus.common.domain.R;
import com.oddfar.campus.common.enums.ResBizTypeEnum;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import io.swagger.annotations.ApiParam;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

/**
 * 举报管理（管理后台）
 */
@Api(tags = "举报管理-后台")
@RestController
@RequestMapping("/admin/report")
@ApiResource(name = "举报管理", appCode = "campus", resBizType = ResBizTypeEnum.BUSINESS)
public class ReportAdminController {

    @Autowired
    private ReportService reportService;

    @ApiOperation("获取举报列表")
    @PreAuthorize("@ss.resourceAuth()")
    @GetMapping(value = "/list", name = "举报列表")
    public R getReportList(
            @ApiParam("状态: 0待处理 1已处理 2已忽略") @RequestParam(required = false) Integer status,
            @ApiParam("举报类型: 0帖子 1评论 2用户 3商品 4兼职") @RequestParam(required = false) Integer targetType,
            @RequestParam(defaultValue = "1") Integer pageNum,
            @RequestParam(defaultValue = "10") Integer pageSize) {
        PageResult<ReportVO> result = reportService.getAdminReportList(status, targetType, pageNum, pageSize);
        return R.ok().put(result);
    }

    @ApiOperation("获取举报详情")
    @PreAuthorize("@ss.resourceAuth()")
    @GetMapping(value = "/{reportId}", name = "举报详情")
    public R getReportDetail(@PathVariable Long reportId) {
        ReportVO detail = reportService.getReportDetail(reportId);
        return R.ok(detail);
    }

    @ApiOperation("处理举报")
    @PreAuthorize("@ss.resourceAuth()")
    @PostMapping(value = "/handle/{reportId}", name = "处理举报")
    public R handleReport(
            @PathVariable Long reportId,
            @ApiParam("处理结果: true-确认违规并处理, false-忽略") @RequestParam Boolean handled,
            @ApiParam("处理备注") @RequestParam(required = false) String remark) {
        reportService.handleReport(reportId, handled, remark);
        return R.ok(handled ? "已处理" : "已忽略");
    }

    @ApiOperation("批量处理举报")
    @PreAuthorize("@ss.resourceAuth()")
    @PostMapping(value = "/batch-handle", name = "批量处理举报")
    public R batchHandleReport(
            @RequestBody Long[] reportIds,
            @ApiParam("处理结果") @RequestParam Boolean handled,
            @ApiParam("处理备注") @RequestParam(required = false) String remark) {
        for (Long reportId : reportIds) {
            reportService.handleReport(reportId, handled, remark);
        }
        return R.ok("批量处理完成");
    }

    @ApiOperation("删除举报记录")
    @PreAuthorize("@ss.resourceAuth()")
    @DeleteMapping(value = "/{reportIds}", name = "删除举报")
    public R deleteReport(@PathVariable Long[] reportIds) {
        for (Long reportId : reportIds) {
            reportService.deleteReport(reportId);
        }
        return R.ok();
    }

    @ApiOperation("获取举报统计")
    @PreAuthorize("@ss.resourceAuth()")
    @GetMapping(value = "/stats", name = "举报统计")
    public R getStats() {
        return R.ok()
                .put("pendingCount", reportService.getCountByStatus(0))
                .put("handledCount", reportService.getCountByStatus(1))
                .put("ignoredCount", reportService.getCountByStatus(2))
                .put("totalCount", reportService.getTotalCount());
    }
}
