package cn.yanghub.myblog.service;

import cn.yanghub.myblog.entity.User;
import cn.yanghub.myblog.mapper.UserMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.DisabledException;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class CustomUserDetailsService implements UserDetailsService {

    private final UserMapper userMapper;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        User user = userMapper.selectByUsernameOrEmail(username, username);
        if (user == null) {
            throw new UsernameNotFoundException("用户不存在: " + username);
        }

        if (user.getStatus() != 1) {
            throw new DisabledException("用户已被禁用");
        }

        List<SimpleGrantedAuthority> authorities = buildAuthorities(user);

        return new org.springframework.security.core.userdetails.User(
                user.getUsername(),
                user.getPasswordHash(),
                authorities
        );
    }

    private List<SimpleGrantedAuthority> buildAuthorities(User user) {
        User.UserRole userRole = user.getRole() != null ? user.getRole() : User.UserRole.subscriber;
        return List.of(new SimpleGrantedAuthority(toRoleAuthority(userRole.name())));
    }

    /** 与 @PreAuthorize hasRole('admin') 等形式保持一致：ROLE_ + 角色名（小写） */
    private String toRoleAuthority(String role) {
        return "ROLE_" + role;
    }
}
