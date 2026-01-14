package com.oddfar.campus.business.controller.admin;

import com.oddfar.campus.business.market.domain.vo.MarketItemVO;
import com.oddfar.campus.business.market.service.MarketItemService;
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
 * 二手商品管理（管理后台）
 */
@Api(tags = "二手市场管理-后台")
@RestController
@RequestMapping("/admin/market")
@ApiResource(name = "二手商品管理", appCode = "campus", resBizType = ResBizTypeEnum.BUSINESS)
public class MarketAdminController {

    @Autowired
    private MarketItemService marketItemService;

    @ApiOperation("获取商品列表")
    @PreAuthorize("@ss.resourceAuth()")
    @GetMapping(value = "/list", name = "商品列表")
    public R getItemList(
            @ApiParam("商品状态: 0在售 1已售 2下架") @RequestParam(required = false) Integer status,
            @ApiParam("分类ID") @RequestParam(required = false) Long categoryId,
            @ApiParam("关键词") @RequestParam(required = false) String keyword,
            @RequestParam(defaultValue = "1") Integer pageNum,
            @RequestParam(defaultValue = "10") Integer pageSize) {
        PageResult<MarketItemVO> result = marketItemService.getAdminItemList(status, categoryId, keyword, pageNum, pageSize);
        return R.ok().put(result);
    }

    @ApiOperation("获取商品详情")
    @PreAuthorize("@ss.resourceAuth()")
    @GetMapping(value = "/{itemId}", name = "获取商品详情")
    public R getItemDetail(@PathVariable Long itemId) {
        MarketItemVO detail = marketItemService.getItemDetail(itemId);
        return R.ok(detail);
    }

    @ApiOperation("下架商品")
    @PreAuthorize("@ss.resourceAuth()")
    @PostMapping(value = "/{itemId}/off-shelf", name = "下架商品")
    public R offShelfItem(
            @PathVariable Long itemId,
            @ApiParam("下架原因") @RequestParam(required = false) String reason) {
        marketItemService.adminOffShelf(itemId, reason);
        return R.ok("已下架");
    }

    @ApiOperation("恢复上架")
    @PreAuthorize("@ss.resourceAuth()")
    @PostMapping(value = "/{itemId}/on-shelf", name = "恢复上架")
    public R onShelfItem(@PathVariable Long itemId) {
        marketItemService.adminOnShelf(itemId);
        return R.ok("已上架");
    }

    @ApiOperation("删除商品")
    @PreAuthorize("@ss.resourceAuth()")
    @DeleteMapping(value = "/{itemIds}", name = "删除商品")
    public R deleteItem(@PathVariable Long[] itemIds) {
        for (Long itemId : itemIds) {
            marketItemService.adminDeleteItem(itemId);
        }
        return R.ok();
    }

    @ApiOperation("获取统计数据")
    @PreAuthorize("@ss.resourceAuth()")
    @GetMapping(value = "/stats", name = "商品统计")
    public R getStats() {
        // 返回商品数量统计
        return R.ok()
                .put("totalCount", marketItemService.getTotalCount())
                .put("onSaleCount", marketItemService.getCountByStatus(0))
                .put("soldCount", marketItemService.getCountByStatus(1))
                .put("offShelfCount", marketItemService.getCountByStatus(2));
    }
}
