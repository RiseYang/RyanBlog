package cn.yanghub.myblog.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDateTime;

/**
 * @className: Comment
 * @author: yang
 * @date: 2026/7/7 下午7:21
 * @Version: 1.0
 * @description:
 */
@Data
@EqualsAndHashCode(callSuper = false)
@TableName("comments")
public class Comment {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long postId;
    private Long parentId;
    private Long rootId;
    private Long userId;

    private String visitorName;
    private String visitorEmail;
    private String visitorWebsite;
    private String visitorIp;

    private String content;
    private String contentHtml;

    private Integer isAuthor;

    @TableField("status")
    private CommentStatus status;

    private Integer likeCount;
    private Integer replyCount;

    private String userAgent;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;

    public enum CommentStatus {
        pending, approved, rejected, spam, trash
    }
}
