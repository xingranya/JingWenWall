package com.oddfar.campus.business.errand.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.oddfar.campus.business.errand.domain.entity.BusErrandRunnerEntity;
import com.oddfar.campus.business.errand.domain.vo.RunnerVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * 骑手认证Mapper
 */
@Mapper
public interface ErrandRunnerMapper extends BaseMapper<BusErrandRunnerEntity> {

    /**
     * 根据用户ID查询骑手信息
     * @param userId 用户ID
     * @return 骑手实体
     */
    BusErrandRunnerEntity selectByUserId(@Param("userId") Long userId);

    /**
     * 查询骑手详情(带用户信息)
     * @param userId 用户ID
     * @return 骑手VO
     */
    RunnerVO selectRunnerDetail(@Param("userId") Long userId);

    /**
     * 查询待审核的骑手列表
     * @return 骑手列表
     */
    List<RunnerVO> selectPendingRunners();

    /**
     * 查询所有骑手列表(管理员用)
     * @param status 状态筛选
     * @return 骑手列表
     */
    List<RunnerVO> selectRunnerList(@Param("status") Integer status);

    /**
     * 更新骑手统计信息
     * @param userId 用户ID
     * @param orderCount 增加的订单数
     * @param income 增加的收入
     * @return 影响行数
     */
    int updateRunnerStats(@Param("userId") Long userId, 
                          @Param("orderCount") Integer orderCount,
                          @Param("income") java.math.BigDecimal income);
}
