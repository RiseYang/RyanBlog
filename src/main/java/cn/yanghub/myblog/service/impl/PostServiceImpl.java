package cn.yanghub.myblog.service.impl;


import cn.yanghub.myblog.common.BizException;
import cn.yanghub.myblog.dto.PostCreateDTO;
import cn.yanghub.myblog.dto.PostUpdateDTO;
import cn.yanghub.myblog.entity.Category;
import cn.yanghub.myblog.entity.Post;
import cn.yanghub.myblog.entity.Tag;
import cn.yanghub.myblog.mapper.CategoryMapper;
import cn.yanghub.myblog.mapper.PostMapper;
import cn.yanghub.myblog.mapper.TagMapper;
import cn.yanghub.myblog.mapper.UserMapper;
import cn.yanghub.myblog.security.SecurityUtils;
import cn.yanghub.myblog.service.PostService;
import cn.yanghub.myblog.vo.PostVO;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

/**
 * @className: PostServiceImpl
 * @author: yang
 * @date: 2026/4/9 下午5:22
 * @Version: 1.0
 * @description:
 */
@Service
@RequiredArgsConstructor
public class PostServiceImpl extends ServiceImpl<PostMapper, Post> implements PostService {

    private final PostMapper postMapper;
    private final UserMapper userMapper;
    private final TagMapper tagMapper;
    private final CategoryMapper categoryMapper;

    @Override
    public PostVO getPostById(Long id) {
        PostVO postVO = loadPostDetail(id);
        if (!isPubliclyVisible(postVO) && !canViewRestricted(id)) {
            throw BizException.notFound("文章不存在");
        }
        if (isPubliclyVisible(postVO)) {
            postMapper.incrementViewCount(id);
            int current = postVO.getViewCount() == null ? 0 : postVO.getViewCount();
            postVO.setViewCount(current + 1);
        }
        return postVO;
    }

    @Override
    public PostVO getPostBySlug(String slug) {
        PostVO postVO = postMapper.selectPostVOBySlug(slug);
        if (postVO == null) {
            throw BizException.notFound("文章不存在");
        }
        postMapper.incrementViewCount(postVO.getId());
        int current = postVO.getViewCount() == null ? 0 : postVO.getViewCount();
        postVO.setViewCount(current + 1);
        fillTags(postVO);
        return postVO;
    }

    @Override
    public IPage<PostVO> getPostPage(Integer page, Integer size, Long categoryId, String keyword) {
        Page<PostVO> pageParam = new Page<>(page, size);
        LambdaQueryWrapper<Post> wrapper = new LambdaQueryWrapper<>();

        wrapper.eq(Post::getStatus, Post.PostStatus.published)
                .and(w -> w.eq(Post::getVisibility, Post.Visibility.PUBLIC).or().isNull(Post::getVisibility))
                .isNull(Post::getDeletedAt);

        if (categoryId != null) {
            wrapper.eq(Post::getCategoryId, categoryId);
        }

        if (keyword != null && !keyword.isEmpty()) {
            wrapper.and(w -> w.like(Post::getTitle, keyword)
                    .or()
                    .like(Post::getExcerpt, keyword));
        }

        IPage<PostVO> result = postMapper.selectPostVOPage(pageParam, wrapper);
        fillTags(result.getRecords());
        return result;
    }

    @Override
    public IPage<PostVO> getAdminPostPage(Integer page, Integer size, Long categoryId, String keyword, Post.PostStatus status) {
        Page<PostVO> pageParam = new Page<>(page, size);
        LambdaQueryWrapper<Post> wrapper = new LambdaQueryWrapper<>();
        wrapper.isNull(Post::getDeletedAt);

        if (status != null) {
            wrapper.eq(Post::getStatus, status);
        }
        if (categoryId != null) {
            wrapper.eq(Post::getCategoryId, categoryId);
        }
        if (keyword != null && !keyword.isEmpty()) {
            wrapper.and(w -> w.like(Post::getTitle, keyword).or().like(Post::getExcerpt, keyword));
        }
        if (SecurityUtils.isSubscriber() && !SecurityUtils.isSuperAdmin()) {
            Long userId = SecurityUtils.getCurrentUserId(userMapper);
            if (userId == null) {
                throw new org.springframework.security.access.AccessDeniedException("未登录");
            }
            wrapper.eq(Post::getAuthorId, userId);
        }

        IPage<PostVO> result = postMapper.selectPostVOPage(pageParam, wrapper);
        fillTags(result.getRecords());
        return result;
    }

    @Override
    @Transactional
    public PostVO createPost(PostCreateDTO createDTO) {
        Post post = new Post();
        BeanUtils.copyProperties(createDTO, post);

        if (post.getVisibility() == null) {
            post.setVisibility(Post.Visibility.PUBLIC);
        }
        if (post.getStatus() == null) {
            post.setStatus(Post.PostStatus.draft);
        }
        if (post.getContentType() == null) {
            post.setContentType(Post.ContentType.markdown);
        }

        Long authorId = SecurityUtils.getCurrentUserId(userMapper);
        if (authorId == null) {
            throw BizException.badRequest("未登录，无法创建文章");
        }
        post.setAuthorId(authorId);
        post.setSlug(resolveSlug(createDTO.getSlug(), createDTO.getTitle(), null));
        ensureCategoryExists(post.getCategoryId());

        if (post.getStatus() == Post.PostStatus.published) {
            post.setPublishedAt(LocalDateTime.now());
        }

        applyContentStats(post);

        postMapper.insert(post);
        if (createDTO.getTagIds() != null) {
            replacePostTags(post.getId(), createDTO.getTagIds());
        }
        refreshCategoryCount(post.getCategoryId());
        return loadPostDetail(post.getId());
    }

    @Override
    @Transactional
    public PostVO updatePost(Long id, @Valid PostUpdateDTO updateDTO) {
        Post post = postMapper.selectById(id);
        if (post == null) {
            throw BizException.notFound("文章不存在");
        }

        SecurityUtils.requirePostOwnerOrSuperAdmin(post, userMapper);

        Long oldCategoryId = post.getCategoryId();
        String previousSlug = post.getSlug();
        Post.PostStatus previousStatus = post.getStatus();
        Post.Visibility previousVisibility = post.getVisibility();
        Post.ContentType previousContentType = post.getContentType();
        BeanUtils.copyProperties(updateDTO, post, "id", "authorId", "createdAt");
        if (post.getStatus() == null) {
            post.setStatus(previousStatus);
        }
        if (post.getVisibility() == null) {
            post.setVisibility(previousVisibility);
        }
        if (post.getContentType() == null) {
            post.setContentType(previousContentType);
        }
        if (StringUtils.hasText(updateDTO.getSlug())) {
            post.setSlug(resolveSlug(updateDTO.getSlug(), updateDTO.getTitle(), id));
        } else {
            post.setSlug(previousSlug);
        }
        ensureCategoryExists(post.getCategoryId());

        if (post.getStatus() == Post.PostStatus.published && post.getPublishedAt() == null) {
            post.setPublishedAt(LocalDateTime.now());
        }
        applyContentStats(post);

        postMapper.updateById(post);
        if (updateDTO.getTagIds() != null) {
            replacePostTags(id, updateDTO.getTagIds());
        }
        refreshCategoryCount(oldCategoryId);
        refreshCategoryCount(post.getCategoryId());
        return loadPostDetail(id);
    }

    @Override
    @Transactional
    public void deletePost(Long id) {
        SecurityUtils.requireSuperAdmin();
        Post post = postMapper.selectById(id);
        if (post == null) {
            throw BizException.notFound("文章不存在");
        }
        Long categoryId = post.getCategoryId();
        postMapper.deletePostTags(id);
        postMapper.deleteById(id);
        refreshCategoryCount(categoryId);
    }

    @Override
    public List<PostVO> getFeaturedPosts(Integer limit) {
        List<PostVO> posts = postMapper.selectFeaturedPosts(limit);
        fillTags(posts);
        return posts;
    }

    @Override
    public List<PostVO> getTopPosts(Integer limit) {
        List<PostVO> posts = postMapper.selectTopPosts(limit);
        fillTags(posts);
        return posts;
    }

    private PostVO loadPostDetail(Long id) {
        PostVO postVO = postMapper.selectPostVOById(id);
        if (postVO == null) {
            throw BizException.notFound("文章不存在");
        }
        fillTags(postVO);
        return postVO;
    }

    private boolean isPubliclyVisible(PostVO postVO) {
        boolean published = postVO.getStatus() == Post.PostStatus.published;
        boolean publicVisibility = postVO.getVisibility() == null
                || postVO.getVisibility() == Post.Visibility.PUBLIC;
        return published && publicVisibility;
    }

    private boolean canViewRestricted(Long postId) {
        if (!SecurityUtils.isAuthenticated()) {
            return false;
        }
        if (SecurityUtils.isSuperAdmin()) {
            return true;
        }
        Post post = postMapper.selectById(postId);
        if (post == null) {
            return false;
        }
        Long userId = SecurityUtils.getCurrentUserId(userMapper);
        return userId != null && userId.equals(post.getAuthorId());
    }

    private void applyContentStats(Post post) {
        if (post.getContent() == null) {
            return;
        }
        int wordCount = post.getContent().length();
        post.setWordCount(wordCount);
        post.setReadingTime(Math.max(1, wordCount / 200));
    }

    private String resolveSlug(String requested, String title, Long excludeId) {
        if (StringUtils.hasText(requested)) {
            String slug = sanitizeSlug(requested);
            if (postMapper.countBySlug(slug, excludeId) > 0) {
                throw BizException.badRequest("文章别名已存在");
            }
            return slug;
        }
        String base = sanitizeSlug(title);
        String candidate = base;
        int index = 2;
        while (postMapper.countBySlug(candidate, excludeId) > 0) {
            String suffix = "-" + index++;
            int maxBase = Math.max(1, 200 - suffix.length());
            String trimmed = base.length() > maxBase ? base.substring(0, maxBase) : base;
            candidate = trimmed + suffix;
            if (index > 1000) {
                throw BizException.badRequest("无法生成唯一别名");
            }
        }
        return candidate;
    }

    private String sanitizeSlug(String raw) {
        if (!StringUtils.hasText(raw)) {
            throw BizException.badRequest("文章别名不能为空");
        }
        String slug = raw.trim().replaceAll("\\s+", "-");
        if (!StringUtils.hasText(slug)) {
            throw BizException.badRequest("文章别名不能为空");
        }
        if (slug.length() > 200) {
            slug = slug.substring(0, 200);
        }
        return slug;
    }

    private void ensureCategoryExists(Long categoryId) {
        if (categoryId == null) {
            return;
        }
        Category category = categoryMapper.selectById(categoryId);
        if (category == null) {
            throw BizException.badRequest("分类不存在");
        }
    }

    private void replacePostTags(Long postId, List<Long> tagIds) {
        postMapper.deletePostTags(postId);
        if (tagIds == null || tagIds.isEmpty()) {
            return;
        }
        Set<Long> uniqueIds = new LinkedHashSet<>(tagIds);
        for (Long tagId : uniqueIds) {
            if (tagId == null) {
                continue;
            }
            Tag tag = tagMapper.selectById(tagId);
            if (tag == null) {
                throw BizException.badRequest("标签不存在");
            }
            postMapper.insertPostTag(postId, tagId);
        }
    }

    private void refreshCategoryCount(Long categoryId) {
        if (categoryId != null) {
            categoryMapper.refreshPostCount(categoryId);
        }
    }

    private void fillTags(List<PostVO> posts) {
        if (posts == null) {
            return;
        }
        for (PostVO post : posts) {
            fillTags(post);
        }
    }

    private void fillTags(PostVO post) {
        if (post == null || post.getId() == null) {
            return;
        }
        List<Tag> tags = tagMapper.selectTagsByPostId(post.getId());
        List<String> names = new ArrayList<>();
        List<String> slugs = new ArrayList<>();
        for (Tag tag : tags) {
            names.add(tag.getName());
            slugs.add(tag.getSlug());
        }
        post.setTagNames(names);
        post.setTagSlugs(slugs);
    }
}
