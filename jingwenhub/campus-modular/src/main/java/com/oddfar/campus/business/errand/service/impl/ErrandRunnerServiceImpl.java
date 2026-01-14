package com.oddfar.campus.business.errand.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;
import com.oddfar.campus.business.domain.entity.BusStudentEntity;
import com.oddfar.campus.business.errand.domain.dto.RunnerApplyDTO;
import com.oddfar.campus.business.errand.domain.entity.BusErrandRunnerEntity;
import com.oddfar.campus.business.errand.domain.vo.RunnerVO;
import com.oddfar.campus.business.errand.mapper.ErrandRunnerMapper;
import com.oddfar.campus.business.errand.service.ErrandRunnerService;
import com.oddfar.campus.business.mapper.BusStudentMapper;
import com.oddfar.campus.common.domain.PageResult;
import com.oddfar.campus.common.exception.ServiceException;
import com.oddfar.campus.common.utils.SecurityUtils;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.Date;
import java.util.List;

/**
 * 骑手认证服务实现
 */
@Slf4j
@Service
@SuppressWarnings("null")
public class ErrandRunnerServiceImpl extends ServiceImpl<ErrandRunnerMapper, BusErrandRunnerEntity>
        implements ErrandRunnerService {

    /** 骑手状态: 待审核 */
    private static final int RUNNER_STATUS_PENDING = 0;
    /** 骑手状态: 已通过 */
    private static final int RUNNER_STATUS_APPROVED = 1;
    /** 骑手状态: 已拒绝 */
    private static final int RUNNER_STATUS_REJECTED = 2;
    /** 骑手状态: 已禁用 */
    private static final int RUNNER_STATUS_DISABLED = 3;

    @Autowired
    private ErrandRunnerMapper runnerMapper;

    @Autowired
    private BusStudentMapper studentMapper;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Long applyRunner(RunnerApplyDTO applyDTO) {
        Long userId = SecurityUtils.getUserId();
        
        // 检查是否已申请过
        BusErrandRunnerEntity existRunner = runnerMapper.selectByUserId(userId);
        if (existRunner != null) {
            if (existRunner.getStatus() == RUNNER_STATUS_PENDING) {
                throw new ServiceException("您已提交申请，请等待审核");
            } else if (existRunner.getStatus() == RUNNER_STATUS_APPROVED) {
                throw new ServiceException("您已是认证骑手");
            } else if (existRunner.getStatus() == RUNNER_STATUS_REJECTED) {
                // 允许重新申请，更新信息
                BeanUtils.copyProperties(applyDTO, existRunner);
                existRunner.setStatus(RUNNER_STATUS_PENDING);
                existRunner.setAuditRemark(null);
                existRunner.setUpdateTime(new Date());
                this.updateById(existRunner);
                log.info("骑手重新申请, userId: {}, runnerId: {}", userId, existRunner.getRunnerId());
                return existRunner.getRunnerId();
            }
        }
        
        // 创建新申请
        BusErrandRunnerEntity runner = new BusErrandRunnerEntity();
        BeanUtils.copyProperties(applyDTO, runner);
        runner.setUserId(userId);
        runner.setStatus(RUNNER_STATUS_PENDING);
        runner.setTotalOrders(0);
        runner.setTotalIncome(BigDecimal.ZERO);
        runner.setRating(new BigDecimal("5.00"));
        runner.setDelFlag(0);
        runner.setCreateTime(new Date());
        
        this.save(runner);
        
        log.info("骑手申请提交成功, userId: {}, runnerId: {}", userId, runner.getRunnerId());
        return runner.getRunnerId();
    }

    @Override
    public RunnerVO getMyRunnerInfo() {
        Long userId = SecurityUtils.getUserId();
        RunnerVO vo = runnerMapper.selectRunnerDetail(userId);
        if (vo != null) {
            fillStatusDesc(vo);
        }
        return vo;
    }

    @Override
    public boolean isRunner() {
        Long userId = SecurityUtils.getUserId();
        BusErrandRunnerEntity runner = runnerMapper.selectByUserId(userId);
        return runner != null && runner.getStatus() == RUNNER_STATUS_APPROVED;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void auditRunner(Long runnerId, boolean passed, String remark) {
        BusErrandRunnerEntity runner = this.getById(runnerId);
        if (runner == null) {
            throw new ServiceException("骑手信息不存在");
        }
        
        if (runner.getStatus() != RUNNER_STATUS_PENDING) {
            throw new ServiceException("该申请已处理");
        }
        
        runner.setStatus(passed ? RUNNER_STATUS_APPROVED : RUNNER_STATUS_REJECTED);
        runner.setAuditRemark(remark);
        runner.setUpdateTime(new Date());
        this.updateById(runner);
        
        // 如果通过，更新学生表的骑手标识
        if (passed) {
            BusStudentEntity student = studentMapper.selectByUserId(runner.getUserId());
            if (student != null) {
                student.setIsRunner(1);
                studentMapper.updateById(student);
            }
        }
        
        log.info("骑手审核完成, runnerId: {}, passed: {}", runnerId, passed);
    }

    @Override
    public PageResult<RunnerVO> getPendingRunners(Integer pageNum, Integer pageSize) {
        PageHelper.startPage(pageNum, pageSize);
        List<RunnerVO> list = runnerMapper.selectPendingRunners();
        list.forEach(this::fillStatusDesc);
        PageInfo<RunnerVO> pageInfo = new PageInfo<>(list);
        return new PageResult<>(pageInfo.getList(), pageInfo.getTotal());
    }

    @Override
    public PageResult<RunnerVO> getRunnerList(Integer status, Integer pageNum, Integer pageSize) {
        PageHelper.startPage(pageNum, pageSize);
        List<RunnerVO> list = runnerMapper.selectRunnerList(status);
        list.forEach(this::fillStatusDesc);
        PageInfo<RunnerVO> pageInfo = new PageInfo<>(list);
        return new PageResult<>(pageInfo.getList(), pageInfo.getTotal());
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void disableRunner(Long runnerId, String reason) {
        BusErrandRunnerEntity runner = this.getById(runnerId);
        if (runner == null) {
            throw new ServiceException("骑手信息不存在");
        }
        
        runner.setStatus(RUNNER_STATUS_DISABLED);
        runner.setAuditRemark(reason);
        runner.setUpdateTime(new Date());
        this.updateById(runner);
        
        // 更新学生表
        BusStudentEntity student = studentMapper.selectByUserId(runner.getUserId());
        if (student != null) {
            student.setIsRunner(0);
            studentMapper.updateById(student);
        }
        
        log.info("骑手已禁用, runnerId: {}, reason: {}", runnerId, reason);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void enableRunner(Long runnerId) {
        BusErrandRunnerEntity runner = this.getById(runnerId);
        if (runner == null) {
            throw new ServiceException("骑手信息不存在");
        }
        
        if (runner.getStatus() != RUNNER_STATUS_DISABLED) {
            throw new ServiceException("骑手状态不正确");
        }
        
        runner.setStatus(RUNNER_STATUS_APPROVED);
        runner.setUpdateTime(new Date());
        this.updateById(runner);
        
        // 更新学生表
        BusStudentEntity student = studentMapper.selectByUserId(runner.getUserId());
        if (student != null) {
            student.setIsRunner(1);
            studentMapper.updateById(student);
        }
        
        log.info("骑手已启用, runnerId: {}", runnerId);
    }

    /**
     * 填充状态描述
     */
    private void fillStatusDesc(RunnerVO vo) {
        switch (vo.getStatus()) {
            case RUNNER_STATUS_PENDING:
                vo.setStatusDesc("待审核");
                break;
            case RUNNER_STATUS_APPROVED:
                vo.setStatusDesc("已认证");
                break;
            case RUNNER_STATUS_REJECTED:
                vo.setStatusDesc("已拒绝");
                break;
            case RUNNER_STATUS_DISABLED:
                vo.setStatusDesc("已禁用");
                break;
            default:
                vo.setStatusDesc("未知");
        }
    }
}
