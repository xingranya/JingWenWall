package com.oddfar.campus.business.errand.controller;

import com.oddfar.campus.business.errand.domain.dto.ErrandOrderDTO;
import com.oddfar.campus.business.errand.domain.vo.ErrandOrderVO;
import com.oddfar.campus.business.errand.service.ErrandOrderService;
import com.oddfar.campus.common.annotation.Anonymous;
import com.oddfar.campus.common.domain.PageResult;
import com.oddfar.campus.common.domain.R;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import io.swagger.annotations.ApiParam;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

/**
 * 跑腿订单控制器
 */
@Api(tags = "跑腿-订单管理")
@RestController
@RequestMapping("/api/v1/errand/orders")
public class ErrandOrderController {

    @Autowired
    private ErrandOrderService errandOrderService;

    @Anonymous
    @ApiOperation("获取待接单列表")
    @GetMapping("/waiting")
    public R getWaitingOrders(
            @ApiParam("页码") @RequestParam(defaultValue = "1") Integer pageNum,
            @ApiParam("每页数量") @RequestParam(defaultValue = "10") Integer pageSize) {
        PageResult<ErrandOrderVO> result = errandOrderService.getWaitingOrders(pageNum, pageSize);
        return R.ok().put(result);
    }

    @ApiOperation("获取订单详情")
    @GetMapping("/{orderId}")
    public R getOrderDetail(@PathVariable Long orderId) {
        ErrandOrderVO detail = errandOrderService.getOrderDetail(orderId);
        return R.ok(detail);
    }

    @ApiOperation("创建订单")
    @PostMapping
    public R createOrder(@RequestBody @Validated ErrandOrderDTO orderDTO) {
        Long orderId = errandOrderService.createOrder(orderDTO);
        return R.ok().put("orderId", orderId);
    }

    @ApiOperation("接单/抢单")
    @PostMapping("/{orderId}/accept")
    public R acceptOrder(@PathVariable Long orderId) {
        errandOrderService.acceptOrder(orderId);
        return R.ok("接单成功");
    }

    @ApiOperation("更新订单状态")
    @PutMapping("/{orderId}/status")
    public R updateOrderStatus(
            @PathVariable Long orderId,
            @ApiParam("新状态: 2取件中 3配送中 4待确认") @RequestParam Integer status) {
        errandOrderService.updateOrderStatus(orderId, status);
        return R.ok();
    }

    @ApiOperation("取消订单")
    @PostMapping("/{orderId}/cancel")
    public R cancelOrder(
            @PathVariable Long orderId,
            @ApiParam("取消原因") @RequestParam(required = false) String reason) {
        errandOrderService.cancelOrder(orderId, reason);
        return R.ok("订单已取消");
    }

    @ApiOperation("确认完成")
    @PostMapping("/{orderId}/confirm")
    public R confirmComplete(@PathVariable Long orderId) {
        errandOrderService.confirmComplete(orderId);
        return R.ok("订单已完成");
    }

    @ApiOperation("我发布的订单")
    @GetMapping("/published")
    public R getMyPublishedOrders(
            @RequestParam(defaultValue = "1") Integer pageNum,
            @RequestParam(defaultValue = "10") Integer pageSize) {
        PageResult<ErrandOrderVO> result = errandOrderService.getMyPublishedOrders(pageNum, pageSize);
        return R.ok().put(result);
    }

    @ApiOperation("我接的订单")
    @GetMapping("/accepted")
    public R getMyAcceptedOrders(
            @RequestParam(defaultValue = "1") Integer pageNum,
            @RequestParam(defaultValue = "10") Integer pageSize) {
        PageResult<ErrandOrderVO> result = errandOrderService.getMyAcceptedOrders(pageNum, pageSize);
        return R.ok().put(result);
    }

    @ApiOperation("模拟支付成功(测试用)")
    @PostMapping("/{orderId}/mock-pay")
    public R mockPaySuccess(@PathVariable Long orderId) {
        errandOrderService.mockPaySuccess(orderId);
        return R.ok("支付成功");
    }
}
