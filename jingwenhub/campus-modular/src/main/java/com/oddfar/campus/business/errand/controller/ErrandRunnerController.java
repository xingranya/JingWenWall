package com.oddfar.campus.business.errand.controller;

import com.oddfar.campus.business.errand.domain.dto.RunnerApplyDTO;
import com.oddfar.campus.business.errand.domain.vo.RunnerVO;
import com.oddfar.campus.business.errand.service.ErrandRunnerService;
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
 * 骑手认证控制器
 */
@Api(tags = "跑腿-骑手管理")
@RestController
@RequestMapping("/api/v1/errand/runner")
public class ErrandRunnerController {

    @Autowired
    private ErrandRunnerService runnerService;

    @ApiOperation("申请成为骑手")
    @PostMapping("/apply")
    public R applyRunner(@RequestBody @Validated RunnerApplyDTO applyDTO) {
        Long runnerId = runnerService.applyRunner(applyDTO);
        return R.ok().put("runnerId", runnerId);
    }

    @ApiOperation("获取我的骑手信息")
    @GetMapping("/mine")
    public R getMyRunnerInfo() {
        RunnerVO vo = runnerService.getMyRunnerInfo();
        return R.ok(vo);
    }

    @ApiOperation("检查是否是骑手")
    @GetMapping("/check")
    public R checkIsRunner() {
        boolean isRunner = runnerService.isRunner();
        return R.ok().put("isRunner", isRunner);
    }

    // ==================== 管理员接口 ====================

    @ApiOperation("审核骑手申请")
    @PreAuthorize("@ss.hasPermi('errand:runner:audit')")
    @PostMapping("/audit/{runnerId}")
    public R auditRunner(
            @PathVariable Long runnerId,
            @ApiParam("是否通过") @RequestParam Boolean passed,
            @ApiParam("审核备注") @RequestParam(required = false) String remark) {
        runnerService.auditRunner(runnerId, passed, remark);
        return R.ok(passed ? "审核通过" : "审核拒绝");
    }

    @ApiOperation("获取待审核骑手列表")
    @PreAuthorize("@ss.hasPermi('errand:runner:list')")
    @GetMapping("/pending")
    public R getPendingRunners(
            @RequestParam(defaultValue = "1") Integer pageNum,
            @RequestParam(defaultValue = "10") Integer pageSize) {
        PageResult<RunnerVO> result = runnerService.getPendingRunners(pageNum, pageSize);
        return R.ok().put(result);
    }

    @ApiOperation("获取骑手列表")
    @PreAuthorize("@ss.hasPermi('errand:runner:list')")
    @GetMapping("/list")
    public R getRunnerList(
            @ApiParam("状态: 0待审核 1通过 2拒绝 3禁用") @RequestParam(required = false) Integer status,
            @RequestParam(defaultValue = "1") Integer pageNum,
            @RequestParam(defaultValue = "10") Integer pageSize) {
        PageResult<RunnerVO> result = runnerService.getRunnerList(status, pageNum, pageSize);
        return R.ok().put(result);
    }

    @ApiOperation("禁用骑手")
    @PreAuthorize("@ss.hasPermi('errand:runner:disable')")
    @PostMapping("/disable/{runnerId}")
    public R disableRunner(
            @PathVariable Long runnerId,
            @ApiParam("禁用原因") @RequestParam(required = false) String reason) {
        runnerService.disableRunner(runnerId, reason);
        return R.ok("已禁用");
    }

    @ApiOperation("启用骑手")
    @PreAuthorize("@ss.hasPermi('errand:runner:enable')")
    @PostMapping("/enable/{runnerId}")
    public R enableRunner(@PathVariable Long runnerId) {
        runnerService.enableRunner(runnerId);
        return R.ok("已启用");
    }
}
