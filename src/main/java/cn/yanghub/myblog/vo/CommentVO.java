package cn.yanghub.myblog.vo;

import cn.yanghub.myblog.entity.Comment;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

/**
 * @className: CommentVO
 * @author: yang
 * @date: 2026/4/9 下午5:43
 * @Version: 1.0
 * @description:
 */
@Data
public class CommentVO {

    private Long id;
    private Long postId;
    private Long parentId;
    private Long rootId;
    private Long userId;

    private String visitorName;
    private String visitorEmail;
    private String visitorWebsite;

    private String content;
    private String contentHtml;
    private Integer isAuthor;
    private Comment.CommentStatus status;

    private Integer likeCount;
    private Integer replyCount;
    private LocalDateTime createdAt;

    private String nickname;
    private String avatarUrl;

    private List<CommentVO> replies;

    private String postTitle;
}
