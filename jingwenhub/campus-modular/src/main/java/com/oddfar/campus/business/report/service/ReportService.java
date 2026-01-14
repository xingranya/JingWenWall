package com.oddfar.campus.business.report.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.oddfar.campus.business.report.domain.dto.ReportDTO;
import com.oddfar.campus.business.report.domain.entity.BusReportEntity;
import com.oddfar.campus.business.report.domain.vo.ReportVO;
import com.oddfar.campus.common.domain.PageResult;

/**
 * 举报服务接口
 */
public interface ReportService extends IService<BusReportEntity> {

    /**
     * 提交举报
     * @param reportDTO 举报信息
     * @return 举报ID
     */
    Long submitReport(ReportDTO reportDTO);

    /**
     * 获取举报列表 (管理员)
     * @param status 状态筛选
     * @param pageNum 页码
     * @param pageSize 每页数量
     * @return 分页结果
     */
    PageResult<ReportVO> getReportList(Integer status, Integer pageNum, Integer pageSize);

    /**
     * 获取举报详情
     * @param reportId 举报ID
     * @return 举报详情
     */
    ReportVO getReportDetail(Long reportId);

    /**
     * 处理举报
     * @param reportId 举报ID
     * @param handled 是否处理(true处理/false忽略)
     * @param remark 处理备注
     */
    void handleReport(Long reportId, boolean handled, String remark);

    // ==================== 管理后台方法 ====================

    /**
     * 获取管理后台举报列表
     * @param status 状态筛选
     * @param targetType 目标类型筛选
     * @param pageNum 页码
     * @param pageSize 每页数量
     * @return 分页结果
     */
    PageResult<ReportVO> getAdminReportList(Integer status, Integer targetType, Integer pageNum, Integer pageSize);

    /**
     * 删除举报记录
     * @param reportId 举报ID
     */
    void deleteReport(Long reportId);

    /**
     * 根据状态获取举报数
     * @param status 状态
     * @return 数量
     */
    Long getCountByStatus(Integer status);

    /**
     * 获取总举报数
     * @return 数量
     */
    Long getTotalCount();
}
