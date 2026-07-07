package cn.yanghub.myblog.service.impl;

import cn.yanghub.myblog.dto.UserAdminDTO;
import cn.yanghub.myblog.dto.UserDTO;
import cn.yanghub.myblog.dto.UserLoginDTO;
import cn.yanghub.myblog.dto.UserRegisterDTO;
import cn.yanghub.myblog.entity.User;
import cn.yanghub.myblog.mapper.UserMapper;
import cn.yanghub.myblog.service.UserService;
import cn.yanghub.myblog.utils.JwtUtil;
import cn.yanghub.myblog.vo.UserVO;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.BeanUtils;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * @className: UserServiceImpl
 * @author: yang
 * @date: 2026/4/9 下午5:19
 * @Version: 1.0
 * @description:
 */

@Service
@RequiredArgsConstructor
public class UserServiceImpl extends ServiceImpl<UserMapper, User> implements UserService {

    private final UserMapper userMapper;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;
    private final AuthenticationManager authenticationManager;

    @Override
    @Transactional
    public UserVO register(UserRegisterDTO registerDTO) {
        // 检查用户名
        if (userMapper.selectByUsername(registerDTO.getUsername()) != null) {
            throw new RuntimeException("用户名已存在");
        }

        // 检查邮箱
        if (userMapper.selectByEmail(registerDTO.getEmail()) != null) {
            throw new RuntimeException("邮箱已被注册");
        }

        User user = new User();
        user.setUsername(registerDTO.getUsername());
        user.setEmail(registerDTO.getEmail());
        user.setPasswordHash(passwordEncoder.encode(registerDTO.getPassword()));
        user.setNickname(registerDTO.getNickname());
        user.setRole(User.UserRole.subscriber);
        user.setStatus(1);
        user.setDeletedAt(0);
        user.setCreatedAt(LocalDateTime.now());
        user.setUpdatedAt(LocalDateTime.now());

        userMapper.insert(user);

        return convertToVO(user);
    }

    @Override
    public Map<String, String> login(UserLoginDTO loginDTO) {
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        loginDTO.getUsername(),
                        loginDTO.getPassword()
                )
        );

        SecurityContextHolder.getContext().setAuthentication(authentication);

        org.springframework.security.core.userdetails.User userDetails =
                (org.springframework.security.core.userdetails.User) authentication.getPrincipal();

        String token = jwtUtil.generateToken(userDetails);

        // 更新登录信息
        User user = userMapper.selectByUsername(userDetails.getUsername());
        if (user == null) {
            // 这里可以选择抛出一个自定义异常，或者直接返回错误信息
            // 既然已经登录成功了（authentication 通过了），说明用户肯定存在
            // 如果这里为 null，说明可能是逻辑删除导致的查询失败
            throw new RuntimeException("用户不存在或已被删除，无法更新登录信息");
        }
        user.setLastLoginAt(LocalDateTime.now());
        user.setLastLoginIp(getClientIp());
        userMapper.updateById(user);

        Map<String, String> result = new HashMap<>();
        result.put("token", token);
        result.put("id", String.valueOf(user.getId()));
        result.put("username", user.getUsername());
        result.put("nickname", user.getNickname());
        result.put("avatar", user.getAvatarUrl());
        result.put("role", user.getRole().name());

        return result;
    }

    @Override
    public UserVO getCurrentUser() {
        var authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated()
                || "anonymousUser".equals(authentication.getName())) {
            throw new org.springframework.security.authentication.InsufficientAuthenticationException("未登录");
        }
        User user = userMapper.selectByUsername(authentication.getName());
        if (user == null) {
            throw new RuntimeException("用户不存在");
        }
        return convertToVO(user);
    }

    @Override
    @Transactional
    public UserVO updateProfile(UserDTO userDTO) {
        String username = SecurityContextHolder.getContext().getAuthentication().getName();
        User user = userMapper.selectByUsername(username);

        BeanUtils.copyProperties(userDTO, user, "id", "username", "email", "role", "status");
        userMapper.updateById(user);

        return convertToVO(user);
    }

    @Override
    public IPage<UserVO> getUserPage(Integer page, Integer size, String keyword, User.UserRole role, Integer status) {
        Page<User> pageParam = new Page<>(page, size);
        LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();

        if (StringUtils.hasText(keyword)) {
            wrapper.and(w -> w.like(User::getUsername, keyword)
                    .or().like(User::getEmail, keyword)
                    .or().like(User::getNickname, keyword));
        }
        if (role != null) {
            wrapper.eq(User::getRole, role);
        }
        if (status != null) {
            wrapper.eq(User::getStatus, status);
        }
        wrapper.orderByDesc(User::getCreatedAt);

        Page<User> result = userMapper.selectPage(pageParam, wrapper);
        Page<UserVO> voPage = new Page<>(page, size, result.getTotal());
        voPage.setRecords(result.getRecords().stream().map(this::convertToVO).collect(Collectors.toList()));
        return voPage;
    }

    @Override
    public UserVO getUserById(Long id) {
        User user = userMapper.selectById(id);
        if (user == null) {
            throw new RuntimeException("用户不存在");
        }
        return convertToVO(user);
    }

    @Override
    @Transactional
    public UserVO createUser(UserAdminDTO dto) {
        if (userMapper.selectByUsername(dto.getUsername()) != null) {
            throw new RuntimeException("用户名已存在");
        }
        if (userMapper.selectByEmail(dto.getEmail()) != null) {
            throw new RuntimeException("邮箱已被注册");
        }
        if (!StringUtils.hasText(dto.getPassword())) {
            throw new RuntimeException("密码不能为空");
        }
        if (dto.getPassword().length() < 6) {
            throw new RuntimeException("密码长度至少6位");
        }

        User user = new User();
        user.setUsername(dto.getUsername());
        user.setEmail(dto.getEmail());
        user.setPasswordHash(passwordEncoder.encode(dto.getPassword()));
        user.setNickname(StringUtils.hasText(dto.getNickname()) ? dto.getNickname() : dto.getUsername());
        user.setRole(dto.getRole() != null ? dto.getRole() : User.UserRole.subscriber);
        user.setStatus(dto.getStatus() != null ? dto.getStatus() : 1);
        user.setDeletedAt(0);
        user.setCreatedAt(LocalDateTime.now());
        user.setUpdatedAt(LocalDateTime.now());

        userMapper.insert(user);
        return convertToVO(user);
    }

    @Override
    @Transactional
    public UserVO updateUser(Long id, UserAdminDTO dto) {
        User user = userMapper.selectById(id);
        if (user == null) {
            throw new RuntimeException("用户不存在");
        }

        User existingUsername = userMapper.selectByUsername(dto.getUsername());
        if (existingUsername != null && !existingUsername.getId().equals(id)) {
            throw new RuntimeException("用户名已存在");
        }
        User existingEmail = userMapper.selectByEmail(dto.getEmail());
        if (existingEmail != null && !existingEmail.getId().equals(id)) {
            throw new RuntimeException("邮箱已被注册");
        }

        user.setUsername(dto.getUsername());
        user.setEmail(dto.getEmail());
        user.setNickname(dto.getNickname());
        if (dto.getRole() != null) {
            user.setRole(dto.getRole());
        }
        if (dto.getStatus() != null) {
            user.setStatus(dto.getStatus());
        }
        if (StringUtils.hasText(dto.getPassword())) {
            if (dto.getPassword().length() < 6) {
                throw new RuntimeException("密码长度至少6位");
            }
            user.setPasswordHash(passwordEncoder.encode(dto.getPassword()));
        }
        user.setUpdatedAt(LocalDateTime.now());

        userMapper.updateById(user);
        return convertToVO(user);
    }

    @Override
    @Transactional
    public void deleteUser(Long id) {
        User user = userMapper.selectById(id);
        if (user == null) {
            throw new RuntimeException("用户不存在");
        }
        String currentUsername = SecurityContextHolder.getContext().getAuthentication().getName();
        if (user.getUsername().equals(currentUsername)) {
            throw new RuntimeException("不能删除当前登录用户");
        }
        userMapper.deleteById(id);
    }

    private UserVO convertToVO(User user) {
        UserVO vo = new UserVO();
        BeanUtils.copyProperties(user, vo);
        return vo;
    }

    private String getClientIp() {
        // 简化实现，实际应从Request获取
        return "127.0.0.1";
    }
}