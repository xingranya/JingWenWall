package com.oddfar.campus.business.report.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.oddfar.campus.business.report.domain.entity.BusReportEntity;
import com.oddfar.campus.business.report.domain.vo.ReportVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * 举报Mapper
 */
@Mapper
public interface ReportMapper extends BaseMapper<BusReportEntity> {

    /**
     * 查询举报列表
     * @param status 状态筛选
     * @return 举报列表
     */
    List<ReportVO> selectReportList(@Param("status") Integer status);

    /**
     * 查询举报详情
     * @param reportId 举报ID
     * @return 举报详情
     */
    ReportVO selectReportDetail(@Param("reportId") Long reportId);

    /**
     * 检查是否已举报
     * @param reporterId 举报人ID
     * @param targetType 目标类型
     * @param targetId 目标ID
     * @return 数量
     */
    int checkExists(@Param("reporterId") Long reporterId, 
                    @Param("targetType") Integer targetType, 
                    @Param("targetId") Long targetId);

    // ==================== 管理后台方法 ====================

    /**
     * 管理后台-查询举报列表
     * @param status 状态筛选
     * @param targetType 目标类型筛选
     * @return 举报列表
     */
    List<ReportVO> selectAdminReportList(@Param("status") Integer status, 
                                         @Param("targetType") Integer targetType);

    /**
     * 按状态统计举报数
     * @param status 状态
     * @return 数量
     */
    Long countByStatus(@Param("status") Integer status);

    /**
     * 统计总举报数
     * @return 数量
     */
    Long countTotal();
}
