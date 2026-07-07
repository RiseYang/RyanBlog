package cn.yanghub.myblog.service;

import cn.yanghub.myblog.common.PageResult;
import cn.yanghub.myblog.dto.CommentCreateDTO;
import cn.yanghub.myblog.entity.Comment;
import cn.yanghub.myblog.vo.CommentVO;
import com.baomidou.mybatisplus.extension.service.IService;

import java.util.List;

public interface CommentService extends IService<Comment> {

    List<CommentVO> getCommentsByPostId(Long postId);

    PageResult<CommentVO> getCommentPage(Integer page, Integer size, Long postId, Comment.CommentStatus status);

    CommentVO createComment(CommentCreateDTO createDTO);

    void updateCommentStatus(Long id, Comment.CommentStatus status);

    void deleteComment(Long id);
}
