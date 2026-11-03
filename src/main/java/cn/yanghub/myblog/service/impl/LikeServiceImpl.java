package cn.yanghub.myblog.service.impl;

import cn.yanghub.myblog.common.BizException;
import cn.yanghub.myblog.service.LikeService;
import cn.yanghub.myblog.vo.LikeState;
import lombok.RequiredArgsConstructor;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.regex.Pattern;

@Service
@RequiredArgsConstructor
public class LikeServiceImpl implements LikeService {

    private static final Pattern CLIENT_ID = Pattern.compile("^[A-Za-z0-9_-]{8,64}$");
    private static final String ABOUT_PAGE = "about";

    private final JdbcTemplate jdbcTemplate;

    @Override
    public LikeState getPostLike(Long postId, String clientId) {
        assertClient(clientId);
        assertPublicPost(postId);
        return postState(postId, clientId);
    }

    @Override
    @Transactional
    public LikeState togglePostLike(Long postId, String clientId) {
        assertClient(clientId);
        assertPublicPost(postId);
        toggle("post_likes", "post_id", postId, clientId);
        jdbcTemplate.update(
                "UPDATE posts SET like_count = (SELECT COUNT(*) FROM post_likes WHERE post_id = ?) WHERE id = ? AND deleted_at IS NULL",
                postId, postId);
        return postState(postId, clientId);
    }

    @Override
    public LikeState getPageLike(String pageKey, String clientId) {
        assertClient(clientId);
        assertPage(pageKey);
        return pageState(pageKey, clientId);
    }

    @Override
    @Transactional
    public LikeState togglePageLike(String pageKey, String clientId) {
        assertClient(clientId);
        assertPage(pageKey);
        toggle("page_likes", "page_key", pageKey, clientId);
        return pageState(pageKey, clientId);
    }

    private boolean toggle(String table, String keyColumn, Object key, String clientId) {
        int removed = jdbcTemplate.update(
                "DELETE FROM " + table + " WHERE " + keyColumn + " = ? AND client_id = ?",
                key, clientId);
        if (removed > 0) {
            return false;
        }
        try {
            jdbcTemplate.update(
                    "INSERT INTO " + table + " (" + keyColumn + ", client_id) VALUES (?, ?)",
                    key, clientId);
        } catch (DuplicateKeyException ignored) {
            return true;
        }
        return true;
    }

    private LikeState postState(Long postId, String clientId) {
        Number count = jdbcTemplate.queryForObject(
                "SELECT like_count FROM posts WHERE id = ? AND deleted_at IS NULL",
                Number.class, postId);
        Number mine = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM post_likes WHERE post_id = ? AND client_id = ?",
                Number.class, postId, clientId);
        return state(count, mine);
    }

    private LikeState pageState(String pageKey, String clientId) {
        Number count = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM page_likes WHERE page_key = ?",
                Number.class, pageKey);
        Number mine = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM page_likes WHERE page_key = ? AND client_id = ?",
                Number.class, pageKey, clientId);
        return state(count, mine);
    }

    private LikeState state(Number count, Number mine) {
        LikeState state = new LikeState();
        state.setCount(count == null ? 0 : count.intValue());
        state.setLiked(mine != null && mine.intValue() > 0);
        return state;
    }

    private void assertPublicPost(Long postId) {
        List<Map<String, Object>> rows = jdbcTemplate.queryForList(
                "SELECT status, visibility FROM posts WHERE id = ? AND deleted_at IS NULL",
                postId);
        if (rows.isEmpty()) {
            throw BizException.notFound("文章不存在");
        }
        Map<String, Object> row = rows.get(0);
        if (!"published".equals(String.valueOf(row.get("status")))) {
            throw BizException.notFound("文章不存在");
        }
        Object visibility = row.get("visibility");
        if (visibility != null && !"public".equals(String.valueOf(visibility))) {
            throw BizException.notFound("文章不存在");
        }
    }

    private void assertPage(String pageKey) {
        if (!ABOUT_PAGE.equals(pageKey)) {
            throw BizException.notFound("页面不存在");
        }
    }

    private void assertClient(String clientId) {
        if (clientId == null || !CLIENT_ID.matcher(clientId).matches()) {
            throw BizException.badRequest("无法识别这台设备");
        }
    }
}
