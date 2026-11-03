package cn.yanghub.myblog.service.impl;

import cn.yanghub.myblog.common.BizException;
import cn.yanghub.myblog.common.PageResult;
import cn.yanghub.myblog.dto.CommentCreateDTO;
import cn.yanghub.myblog.entity.Comment;
import cn.yanghub.myblog.entity.Post;
import cn.yanghub.myblog.entity.User;
import cn.yanghub.myblog.mapper.CommentMapper;
import cn.yanghub.myblog.mapper.PostMapper;
import cn.yanghub.myblog.mapper.UserMapper;
import cn.yanghub.myblog.service.CommentService;
import cn.yanghub.myblog.vo.CommentVO;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.BeanUtils;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * @className: CommentServiceImpl
 * @author: yang
 * @date: 2026/4/9 下午5:46
 * @Version: 1.0
 * @description:
 */
@Service
@RequiredArgsConstructor
public class CommentServiceImpl extends ServiceImpl<CommentMapper, Comment> implements CommentService {

    private final CommentMapper commentMapper;
    private final PostMapper postMapper;
    private final UserMapper userMapper;

    @Override
    public List<CommentVO> getCommentsByPostId(Long postId) {
        List<CommentVO> comments = commentMapper.selectCommentsByPostId(postId);
        for (CommentVO comment : comments) {
            fillDisplayName(comment);
        }
        return buildCommentTree(comments);
    }

    @Override
    public PageResult<CommentVO> getCommentPage(Integer page, Integer size, Long postId, Comment.CommentStatus status) {
        Page<Comment> pageParam = new Page<>(page, size);
        LambdaQueryWrapper<Comment> wrapper = new LambdaQueryWrapper<>();
        if (postId != null) {
            wrapper.eq(Comment::getPostId, postId);
        }
        if (status != null) {
            wrapper.eq(Comment::getStatus, status);
        }
        wrapper.orderByDesc(Comment::getCreatedAt);

        Page<Comment> result = commentMapper.selectPage(pageParam, wrapper);
        List<CommentVO> records = result.getRecords().stream()
                .map(this::convertToVO)
                .collect(Collectors.toList());

        Page<CommentVO> voPage = new Page<>(page, size, result.getTotal());
        voPage.setRecords(records);
        return new PageResult<>(voPage);
    }

    @Override
    @Transactional
    public CommentVO createComment(CommentCreateDTO createDTO) {
        String content = createDTO.getContent() == null ? "" : createDTO.getContent().trim();
        if (!StringUtils.hasText(content)) {
            throw BizException.badRequest("评论内容不能为空");
        }
        if (content.length() > 500) {
            throw BizException.badRequest("评论最多 500 字");
        }
        createDTO.setContent(content);
        if (createDTO.getVisitorName() != null) {
            String visitorName = createDTO.getVisitorName().trim();
            if (visitorName.length() > 50) {
                throw BizException.badRequest("昵称最多 50 字");
            }
            createDTO.setVisitorName(visitorName);
        }
        if (createDTO.getUserAgent() != null && createDTO.getUserAgent().length() > 500) {
            createDTO.setUserAgent(createDTO.getUserAgent().substring(0, 500));
        }
        Post post = postMapper.selectById(createDTO.getPostId());
        if (post == null || post.getStatus() != Post.PostStatus.published
                || (post.getVisibility() != null && post.getVisibility() != Post.Visibility.PUBLIC)) {
            throw BizException.notFound("文章不存在");
        }
        if (post.getAllowComment() != null && post.getAllowComment() == 0) {
            throw BizException.badRequest("该文章不允许评论");
        }

        Comment comment = new Comment();
        BeanUtils.copyProperties(createDTO, comment, "userId");
        comment.setUserId(null);
        comment.setStatus(Comment.CommentStatus.approved);
        comment.setLikeCount(0);
        comment.setReplyCount(0);
        comment.setIsAuthor(0);

        Long currentUserId = getCurrentUserId();
        if (currentUserId != null) {
            comment.setUserId(currentUserId);
            User user = userMapper.selectById(currentUserId);
            if (user != null && post.getAuthorId() != null && post.getAuthorId().equals(currentUserId)) {
                comment.setIsAuthor(1);
            }
        } else if (!StringUtils.hasText(createDTO.getVisitorName())) {
            throw BizException.badRequest("游客评论需填写昵称");
        }

        if (comment.getParentId() != null) {
            Comment parent = commentMapper.selectById(comment.getParentId());
            if (parent == null) {
                throw BizException.notFound("父评论不存在");
            }
            if (!parent.getPostId().equals(createDTO.getPostId())) {
                throw BizException.badRequest("父评论不属于该文章");
            }
            comment.setRootId(parent.getRootId() != null ? parent.getRootId() : parent.getId());
        }

        commentMapper.insert(comment);
        return convertToVO(comment);
    }

    @Override
    @Transactional
    public void updateCommentStatus(Long id, Comment.CommentStatus status) {
        Comment comment = commentMapper.selectById(id);
        if (comment == null) {
            throw BizException.notFound("评论不存在");
        }
        Comment.CommentStatus previous = comment.getStatus();
        comment.setStatus(status);
        commentMapper.updateById(comment);
        adjustPostCommentCount(comment.getPostId(), previous, status);
    }

    @Override
    @Transactional
    public void deleteComment(Long id) {
        Comment comment = commentMapper.selectById(id);
        if (comment == null) {
            throw BizException.notFound("评论不存在");
        }
        commentMapper.deleteById(id);

        if (comment.getParentId() != null) {
            commentMapper.update(null, new LambdaUpdateWrapper<Comment>()
                    .eq(Comment::getId, comment.getParentId())
                    .gt(Comment::getReplyCount, 0)
                    .setSql("reply_count = reply_count - 1"));
        }
    }

    private List<CommentVO> buildCommentTree(List<CommentVO> comments) {
        Map<Long, CommentVO> commentMap = new HashMap<>();
        List<CommentVO> roots = new ArrayList<>();

        for (CommentVO comment : comments) {
            comment.setReplies(new ArrayList<>());
            commentMap.put(comment.getId(), comment);
        }

        for (CommentVO comment : comments) {
            if (comment.getParentId() == null) {
                roots.add(comment);
                continue;
            }
            CommentVO parent = commentMap.get(comment.getParentId());
            if (parent != null) {
                parent.getReplies().add(comment);
            } else {
                roots.add(comment);
            }
        }

        roots.sort((a, b) -> b.getCreatedAt().compareTo(a.getCreatedAt()));
        return roots;
    }

    private CommentVO convertToVO(Comment comment) {
        CommentVO vo = new CommentVO();
        BeanUtils.copyProperties(comment, vo);
        if (comment.getUserId() != null) {
            User user = userMapper.selectById(comment.getUserId());
            if (user != null) {
                vo.setNickname(user.getNickname());
                vo.setAvatarUrl(user.getAvatarUrl());
            }
        } else {
            vo.setNickname(comment.getVisitorName());
        }
        fillDisplayName(vo);
        Post post = postMapper.selectById(comment.getPostId());
        if (post != null) {
            vo.setPostTitle(post.getTitle());
        }
        return vo;
    }

    private void fillDisplayName(CommentVO comment) {
        if (comment != null && !StringUtils.hasText(comment.getNickname())) {
            comment.setNickname(comment.getVisitorName());
        }
    }

    private void adjustPostCommentCount(Long postId, Comment.CommentStatus previous, Comment.CommentStatus current) {
        boolean wasApproved = previous == Comment.CommentStatus.approved;
        boolean nowApproved = current == Comment.CommentStatus.approved;
        if (wasApproved == nowApproved || postId == null) {
            return;
        }
        if (nowApproved) {
            postMapper.incrementCommentCount(postId);
        } else {
            postMapper.decrementCommentCount(postId);
        }
    }

    private Long getCurrentUserId() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated()
                || "anonymousUser".equals(authentication.getPrincipal())) {
            return null;
        }
        User user = userMapper.selectByUsername(authentication.getName());
        return user != null ? user.getId() : null;
    }
}
