package com.oddfar.campus.business.report.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;
import com.oddfar.campus.business.report.domain.dto.ReportDTO;
import com.oddfar.campus.business.report.domain.entity.BusReportEntity;
import com.oddfar.campus.business.report.domain.vo.ReportVO;
import com.oddfar.campus.business.report.enums.ReportTargetType;
import com.oddfar.campus.business.report.mapper.ReportMapper;
import com.oddfar.campus.business.report.service.ReportService;
import com.oddfar.campus.common.domain.PageResult;
import com.oddfar.campus.common.exception.ServiceException;
import com.oddfar.campus.common.utils.SecurityUtils;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Date;
import java.util.List;

/**
 * 举报服务实现
 */
@Slf4j
@Service
public class ReportServiceImpl extends ServiceImpl<ReportMapper, BusReportEntity>
        implements ReportService {

    /** 状态: 待处理 */
    private static final int STATUS_PENDING = 0;
    /** 状态: 已处理 */
    private static final int STATUS_HANDLED = 1;
    /** 状态: 已忽略 */
    private static final int STATUS_IGNORED = 2;

    @Autowired
    private ReportMapper reportMapper;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Long submitReport(ReportDTO reportDTO) {
        Long userId = SecurityUtils.getUserId();
        
        // 检查是否已举报过
        int count = reportMapper.checkExists(userId, reportDTO.getTargetType(), reportDTO.getTargetId());
        if (count > 0) {
            throw new ServiceException("您已举报过此内容，请勿重复举报");
        }
        
        // 创建举报记录
        BusReportEntity entity = new BusReportEntity();
        BeanUtils.copyProperties(reportDTO, entity);
        entity.setReporterId(userId);
        entity.setStatus(STATUS_PENDING);
        entity.setDelFlag(0);
        entity.setCreateTime(new Date());
        
        this.save(entity);
        
        log.info("举报提交成功, reportId: {}, targetType: {}, targetId: {}", 
                entity.getReportId(), reportDTO.getTargetType(), reportDTO.getTargetId());
        return entity.getReportId();
    }

    @Override
    public PageResult<ReportVO> getReportList(Integer status, Integer pageNum, Integer pageSize) {
        PageHelper.startPage(pageNum, pageSize);
        List<ReportVO> list = reportMapper.selectReportList(status);
        fillDesc(list);
        PageInfo<ReportVO> pageInfo = new PageInfo<>(list);
        return new PageResult<>(pageInfo.getList(), pageInfo.getTotal());
    }

    @Override
    public ReportVO getReportDetail(Long reportId) {
        ReportVO vo = reportMapper.selectReportDetail(reportId);
        if (vo == null) {
            throw new ServiceException("举报记录不存在");
        }
        fillDesc(vo);
        return vo;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void handleReport(Long reportId, boolean handled, String remark) {
        BusReportEntity entity = this.getById(reportId);
        if (entity == null) {
            throw new ServiceException("举报记录不存在");
        }
        
        if (entity.getStatus() != STATUS_PENDING) {
            throw new ServiceException("该举报已处理");
        }
        
        entity.setStatus(handled ? STATUS_HANDLED : STATUS_IGNORED);
        entity.setHandleRemark(remark);
        entity.setHandleUserId(SecurityUtils.getUserId());
        entity.setHandleTime(new Date());
        this.updateById(entity);
        
        // TODO: 如果handled为true，可以在此处对被举报内容进行处理（如下架帖子、禁言用户等）
        
        log.info("举报处理完成, reportId: {}, handled: {}", reportId, handled);
    }

    /**
     * 填充描述信息
     */
    private void fillDesc(List<ReportVO> list) {
        list.forEach(this::fillDesc);
    }

    private void fillDesc(ReportVO vo) {
        vo.setTargetTypeDesc(ReportTargetType.getDescByCode(vo.getTargetType()));
        
        switch (vo.getStatus()) {
            case STATUS_PENDING:
                vo.setStatusDesc("待处理");
                break;
            case STATUS_HANDLED:
                vo.setStatusDesc("已处理");
                break;
            case STATUS_IGNORED:
                vo.setStatusDesc("已忽略");
                break;
            default:
                vo.setStatusDesc("未知");
        }
    }

    // ==================== 管理后台方法 ====================

    @Override
    public PageResult<ReportVO> getAdminReportList(Integer status, Integer targetType, Integer pageNum, Integer pageSize) {
        PageHelper.startPage(pageNum, pageSize);
        List<ReportVO> list = reportMapper.selectAdminReportList(status, targetType);
        fillDesc(list);
        PageInfo<ReportVO> pageInfo = new PageInfo<>(list);
        return new PageResult<>(pageInfo.getList(), pageInfo.getTotal());
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteReport(Long reportId) {
        BusReportEntity entity = this.getById(reportId);
        if (entity == null) {
            throw new ServiceException("举报记录不存在");
        }
        
        entity.setDelFlag(1);
        this.updateById(entity);
        
        log.info("举报记录已删除, reportId: {}", reportId);
    }

    @Override
    public Long getCountByStatus(Integer status) {
        return reportMapper.countByStatus(status);
    }

    @Override
    public Long getTotalCount() {
        return reportMapper.countTotal();
    }
}
