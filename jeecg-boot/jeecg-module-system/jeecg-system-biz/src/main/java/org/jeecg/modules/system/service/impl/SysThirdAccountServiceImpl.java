package org.jeecg.modules.system.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.jeecg.dingtalk.api.base.JdtBaseAPI;
import com.jeecg.dingtalk.api.core.response.Response;
import com.jeecg.dingtalk.api.core.vo.AccessToken;
import com.jeecg.dingtalk.api.user.JdtUserAPI;
import lombok.extern.slf4j.Slf4j;
import org.apache.shiro.SecurityUtils;
import org.jeecg.common.constant.CommonConstant;
import org.jeecg.common.exception.JeecgBootException;
import org.jeecg.common.system.vo.LoginUser;
import org.jeecg.common.util.DateUtils;
import org.jeecg.common.util.PasswordUtil;
import org.jeecg.common.util.UUIDGenerator;
import org.jeecg.common.util.oConvertUtils;
import org.jeecg.modules.system.entity.SysRole;
import org.jeecg.modules.system.entity.SysThirdAccount;
import org.jeecg.modules.system.entity.SysUser;
import org.jeecg.modules.system.entity.SysUserRole;
import org.jeecg.modules.system.mapper.SysRoleMapper;
import org.jeecg.modules.system.mapper.SysThirdAccountMapper;
import org.jeecg.modules.system.mapper.SysUserMapper;
import org.jeecg.modules.system.mapper.SysUserRoleMapper;
import org.jeecg.modules.system.model.ThirdLoginModel;
import org.jeecg.modules.system.service.ISysThirdAccountService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.List;

/**
 * @Description: 第三方登录账号表
 * @Author: jeecg-boot
 * @Date:   2020-11-17
 * @Version: V1.0
 */
@Service
@Slf4j
public class SysThirdAccountServiceImpl extends ServiceImpl<SysThirdAccountMapper, SysThirdAccount> implements ISysThirdAccountService {
    
    @Autowired
    private  SysThirdAccountMapper sysThirdAccountMapper;
    
    @Autowired
    private SysUserMapper sysUserMapper;
    @Autowired
    private SysRoleMapper sysRoleMapper;
    @Autowired
    private SysUserRoleMapper sysUserRoleMapper;
    
    @Value("${justauth.type.DINGTALK.client-id:}")
    private String dingTalkClientId;   
    @Value("${justauth.type.DINGTALK.client-secret:}")
    private String dingTalkClientSecret;
    
    // 不考虑第三方登录，提供空实现
    @Override
    public void updateThirdUserId(SysUser sysUser,String thirdUserUuid) {
        // 空实现，不处理第三方登录逻辑
        log.info("第三方登录功能已禁用，跳过updateThirdUserId方法");
    }
    
    // 不考虑第三方登录，提供空实现
    @Override
    public SysUser createUser(String phone, String thirdUserUuid, Integer tenantId) {
        // 空实现，不处理第三方登录逻辑
        log.info("第三方登录功能已禁用，跳过createUser方法");
        return null;
    }
    
    // 不考虑第三方登录，提供空实现
    @Override
    public SysThirdAccount getOneBySysUserId(String sysUserId, String thirdType) {
        // 空实现，不处理第三方登录逻辑
        log.info("第三方登录功能已禁用，跳过getOneBySysUserId方法");
        return null;
    }

    // 不考虑第三方登录，提供空实现
    @Override
    public SysThirdAccount getOneByThirdUserId(String thirdUserId, String thirdType) {
        // 空实现，不处理第三方登录逻辑
        log.info("第三方登录功能已禁用，跳过getOneByThirdUserId方法");
        return null;
    }

    // 不考虑第三方登录，提供空实现
    @Override
    public List<SysThirdAccount> listThirdUserIdByUsername(String[] sysUsernameArr, String thirdType, Integer tenantId) {
        // 空实现，不处理第三方登录逻辑
        log.info("第三方登录功能已禁用，跳过listThirdUserIdByUsername方法");
        return null;
    }

    // 不考虑第三方登录，提供空实现
    @Override
    public SysThirdAccount saveThirdUser(ThirdLoginModel tlm, Integer tenantId) {
        // 空实现，不处理第三方登录逻辑
        log.info("第三方登录功能已禁用，跳过saveThirdUser方法");
        return null;
    }

    // 不考虑第三方登录，提供空实现
    @Override
    public SysThirdAccount bindThirdAppAccountByUserId(SysThirdAccount sysThirdAccount) {
        // 空实现，不处理第三方登录逻辑
        log.info("第三方登录功能已禁用，跳过bindThirdAppAccountByUserId方法");
        return null;
    }

    // 不考虑第三方登录，提供空实现
    @Override
    public SysThirdAccount getOneByUuidAndThirdType(String unionid, String thirdType, Integer tenantId, String thirdUserId) {
        // 空实现，不处理第三方登录逻辑
        log.info("第三方登录功能已禁用，跳过getOneByUuidAndThirdType方法");
        return null;
    }
}