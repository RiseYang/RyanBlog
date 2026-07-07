package cn.yanghub.myblog.security;

import cn.yanghub.myblog.entity.Post;
import cn.yanghub.myblog.entity.User;
import cn.yanghub.myblog.mapper.UserMapper;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;

public final class SecurityUtils {

    private SecurityUtils() {
    }

    public static Authentication getAuthentication() {
        return SecurityContextHolder.getContext().getAuthentication();
    }

    public static boolean isAuthenticated() {
        Authentication authentication = getAuthentication();
        return authentication != null
                && authentication.isAuthenticated()
                && !"anonymousUser".equals(authentication.getPrincipal());
    }

    public static boolean hasRole(String role) {
        Authentication authentication = getAuthentication();
        if (authentication == null) {
            return false;
        }
        String roleAuthority = "ROLE_" + role;
        for (GrantedAuthority authority : authentication.getAuthorities()) {
            if (roleAuthority.equals(authority.getAuthority())) {
                return true;
            }
        }
        return false;
    }

    public static boolean isSuperAdmin() {
        return hasRole("super_admin");
    }

    public static boolean isSubscriber() {
        return hasRole("subscriber");
    }

    public static User getCurrentUser(UserMapper userMapper) {
        Authentication authentication = getAuthentication();
        if (!isAuthenticated()) {
            return null;
        }
        return userMapper.selectByUsername(authentication.getName());
    }

    public static Long getCurrentUserId(UserMapper userMapper) {
        User user = getCurrentUser(userMapper);
        return user != null ? user.getId() : null;
    }

    public static void requireSuperAdmin() {
        if (!isSuperAdmin()) {
            throw new AccessDeniedException("需要超级管理员权限");
        }
    }

    public static void requirePostOwnerOrSuperAdmin(Post post, UserMapper userMapper) {
        if (isSuperAdmin()) {
            return;
        }
        Long userId = getCurrentUserId(userMapper);
        if (userId == null || post.getAuthorId() == null || !userId.equals(post.getAuthorId())) {
            throw new AccessDeniedException("无权操作他人文章");
        }
    }
}
