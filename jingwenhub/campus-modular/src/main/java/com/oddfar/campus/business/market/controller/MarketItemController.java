package com.oddfar.campus.business.market.controller;

import com.oddfar.campus.business.market.domain.dto.MarketItemDTO;
import com.oddfar.campus.business.market.domain.vo.MarketItemVO;
import com.oddfar.campus.business.market.service.MarketItemService;
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
 * 二手交易控制器
 */
@Api(tags = "二手交易-商品管理")
@RestController
@RequestMapping("/api/v1/market/items")
public class MarketItemController {

    @Autowired
    private MarketItemService marketItemService;

    @Anonymous
    @ApiOperation("获取商品列表")
    @GetMapping
    public R getItemList(
            @ApiParam("分类ID") @RequestParam(required = false) Long categoryId,
            @RequestParam(defaultValue = "1") Integer pageNum,
            @RequestParam(defaultValue = "10") Integer pageSize) {
        PageResult<MarketItemVO> result = marketItemService.getItemList(categoryId, pageNum, pageSize);
        return R.ok().put(result);
    }

    @Anonymous
    @ApiOperation("获取商品详情")
    @GetMapping("/{itemId}")
    public R getItemDetail(@PathVariable Long itemId) {
        MarketItemVO detail = marketItemService.getItemDetail(itemId);
        return R.ok(detail);
    }

    @ApiOperation("发布商品")
    @PostMapping
    public R publishItem(@RequestBody @Validated MarketItemDTO itemDTO) {
        Long itemId = marketItemService.publishItem(itemDTO);
        return R.ok().put("itemId", itemId);
    }

    @ApiOperation("更新商品")
    @PutMapping("/{itemId}")
    public R updateItem(@PathVariable Long itemId, @RequestBody @Validated MarketItemDTO itemDTO) {
        itemDTO.setItemId(itemId);
        marketItemService.updateItem(itemDTO);
        return R.ok();
    }

    @ApiOperation("删除商品")
    @DeleteMapping("/{itemId}")
    public R deleteItem(@PathVariable Long itemId) {
        marketItemService.deleteItem(itemId);
        return R.ok();
    }

    @ApiOperation("标记为已售")
    @PostMapping("/{itemId}/sold")
    public R markSold(@PathVariable Long itemId) {
        marketItemService.markSold(itemId);
        return R.ok("已标记为已售");
    }

    @ApiOperation("下架商品")
    @PostMapping("/{itemId}/off-shelf")
    public R offShelf(@PathVariable Long itemId) {
        marketItemService.offShelf(itemId);
        return R.ok("已下架");
    }

    @ApiOperation("收藏商品")
    @PostMapping("/{itemId}/collect")
    public R collectItem(@PathVariable Long itemId) {
        marketItemService.collectItem(itemId);
        return R.ok();
    }

    @ApiOperation("取消收藏")
    @DeleteMapping("/{itemId}/collect")
    public R uncollectItem(@PathVariable Long itemId) {
        marketItemService.uncollectItem(itemId);
        return R.ok();
    }

    @ApiOperation("我发布的商品")
    @GetMapping("/mine")
    public R getMyItems(
            @RequestParam(defaultValue = "1") Integer pageNum,
            @RequestParam(defaultValue = "10") Integer pageSize) {
        PageResult<MarketItemVO> result = marketItemService.getMyItems(pageNum, pageSize);
        return R.ok().put(result);
    }

    @ApiOperation("我收藏的商品")
    @GetMapping("/collected")
    public R getMyCollects(
            @RequestParam(defaultValue = "1") Integer pageNum,
            @RequestParam(defaultValue = "10") Integer pageSize) {
        PageResult<MarketItemVO> result = marketItemService.getMyCollects(pageNum, pageSize);
        return R.ok().put(result);
    }

    @Anonymous
    @ApiOperation("搜索商品")
    @GetMapping("/search")
    public R searchItems(
            @ApiParam("关键词") @RequestParam String keyword,
            @RequestParam(defaultValue = "1") Integer pageNum,
            @RequestParam(defaultValue = "10") Integer pageSize) {
        PageResult<MarketItemVO> result = marketItemService.searchItems(keyword, pageNum, pageSize);
        return R.ok().put(result);
    }
}
