package com.oddfar.campus.business.controller.admin;

import com.oddfar.campus.business.errand.domain.vo.ErrandOrderVO;
import com.oddfar.campus.business.errand.domain.vo.RunnerVO;
import com.oddfar.campus.business.errand.service.ErrandOrderService;
import com.oddfar.campus.business.errand.service.ErrandRunnerService;
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
 * 跑腿订单管理（管理后台）
 */
@Api(tags = "跑腿管理-后台")
@RestController
@RequestMapping("/admin/errand")
@ApiResource(name = "跑腿订单管理", appCode = "campus", resBizType = ResBizTypeEnum.BUSINESS)
public class ErrandAdminController {

    @Autowired
    private ErrandOrderService errandOrderService;
    
    @Autowired
    private ErrandRunnerService errandRunnerService;

    // ==================== 订单管理 ====================
    
    @ApiOperation("获取订单列表")
    @PreAuthorize("@ss.resourceAuth()")
    @GetMapping(value = "/order/list", name = "跑腿订单列表")
    public R getOrderList(
            @ApiParam("订单状态") @RequestParam(required = false) Integer status,
            @RequestParam(defaultValue = "1") Integer pageNum,
            @RequestParam(defaultValue = "10") Integer pageSize) {
        PageResult<ErrandOrderVO> result = errandOrderService.getAdminOrderList(status, pageNum, pageSize);
        return R.ok().put(result);
    }

    @ApiOperation("获取订单详情")
    @PreAuthorize("@ss.resourceAuth()")
    @GetMapping(value = "/order/{orderId}", name = "获取订单详情")
    public R getOrderDetail(@PathVariable Long orderId) {
        ErrandOrderVO detail = errandOrderService.getOrderDetail(orderId);
        return R.ok(detail);
    }

    @ApiOperation("取消订单")
    @PreAuthorize("@ss.resourceAuth()")
    @PostMapping(value = "/order/{orderId}/cancel", name = "管理员取消订单")
    public R cancelOrder(
            @PathVariable Long orderId,
            @ApiParam("取消原因") @RequestParam(required = false) String reason) {
        errandOrderService.adminCancelOrder(orderId, reason);
        return R.ok("订单已取消");
    }

    @ApiOperation("删除订单")
    @PreAuthorize("@ss.resourceAuth()")
    @DeleteMapping(value = "/order/{orderIds}", name = "删除订单")
    public R deleteOrder(@PathVariable Long[] orderIds) {
        for (Long orderId : orderIds) {
            errandOrderService.deleteOrder(orderId);
        }
        return R.ok();
    }

    // ==================== 骑手管理 ====================
    
    @ApiOperation("获取骑手列表")
    @PreAuthorize("@ss.resourceAuth()")
    @GetMapping(value = "/runner/list", name = "骑手列表")
    public R getRunnerList(
            @ApiParam("状态: 0待审核 1通过 2拒绝 3禁用") @RequestParam(required = false) Integer status,
            @RequestParam(defaultValue = "1") Integer pageNum,
            @RequestParam(defaultValue = "10") Integer pageSize) {
        PageResult<RunnerVO> result = errandRunnerService.getRunnerList(status, pageNum, pageSize);
        return R.ok().put(result);
    }

    @ApiOperation("审核骑手")
    @PreAuthorize("@ss.resourceAuth()")
    @PostMapping(value = "/runner/audit/{runnerId}", name = "审核骑手")
    public R auditRunner(
            @PathVariable Long runnerId,
            @ApiParam("是否通过") @RequestParam Boolean passed,
            @ApiParam("审核备注") @RequestParam(required = false) String remark) {
        errandRunnerService.auditRunner(runnerId, passed, remark);
        return R.ok(passed ? "审核通过" : "审核拒绝");
    }

    @ApiOperation("禁用骑手")
    @PreAuthorize("@ss.resourceAuth()")
    @PostMapping(value = "/runner/disable/{runnerId}", name = "禁用骑手")
    public R disableRunner(
            @PathVariable Long runnerId,
            @ApiParam("禁用原因") @RequestParam(required = false) String reason) {
        errandRunnerService.disableRunner(runnerId, reason);
        return R.ok("已禁用");
    }

    @ApiOperation("启用骑手")
    @PreAuthorize("@ss.resourceAuth()")
    @PostMapping(value = "/runner/enable/{runnerId}", name = "启用骑手")
    public R enableRunner(@PathVariable Long runnerId) {
        errandRunnerService.enableRunner(runnerId);
        return R.ok("已启用");
    }
}
