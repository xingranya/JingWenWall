package com.oddfar.campus.business.errand.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.oddfar.campus.business.errand.domain.dto.RunnerApplyDTO;
import com.oddfar.campus.business.errand.domain.entity.BusErrandRunnerEntity;
import com.oddfar.campus.business.errand.domain.vo.RunnerVO;
import com.oddfar.campus.common.domain.PageResult;

/**
 * 骑手认证服务接口
 */
public interface ErrandRunnerService extends IService<BusErrandRunnerEntity> {

    /**
     * 申请成为骑手
     * @param applyDTO 申请信息
     * @return 骑手ID
     */
    Long applyRunner(RunnerApplyDTO applyDTO);

    /**
     * 获取当前用户的骑手信息
     * @return 骑手信息
     */
    RunnerVO getMyRunnerInfo();

    /**
     * 检查当前用户是否是认证骑手
     * @return 是否是骑手
     */
    boolean isRunner();

    /**
     * 审核骑手申请 (管理员)
     * @param runnerId 骑手ID
     * @param passed 是否通过
     * @param remark 审核备注
     */
    void auditRunner(Long runnerId, boolean passed, String remark);

    /**
     * 获取待审核骑手列表 (管理员)
     * @param pageNum 页码
     * @param pageSize 每页数量
     * @return 分页结果
     */
    PageResult<RunnerVO> getPendingRunners(Integer pageNum, Integer pageSize);

    /**
     * 获取所有骑手列表 (管理员)
     * @param status 状态筛选
     * @param pageNum 页码
     * @param pageSize 每页数量
     * @return 分页结果
     */
    PageResult<RunnerVO> getRunnerList(Integer status, Integer pageNum, Integer pageSize);

    /**
     * 禁用骑手 (管理员)
     * @param runnerId 骑手ID
     * @param reason 禁用原因
     */
    void disableRunner(Long runnerId, String reason);

    /**
     * 启用骑手 (管理员)
     * @param runnerId 骑手ID
     */
    void enableRunner(Long runnerId);
}
