package cn.yanghub.myblog.controller;

import cn.yanghub.myblog.common.PageResult;
import cn.yanghub.myblog.common.Result;
import cn.yanghub.myblog.dto.CommentCreateDTO;
import cn.yanghub.myblog.entity.Comment;
import cn.yanghub.myblog.service.CommentService;
import cn.yanghub.myblog.vo.CommentVO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/comments")
@RequiredArgsConstructor
@Tag(name = "评论管理", description = "文章评论的查询、发表与删除")
public class CommentController {

    private final CommentService commentService;

    @GetMapping("/manage")
    @PreAuthorize("hasRole('super_admin')")
    @Operation(summary = "管理端分页查询评论")
    @SecurityRequirement(name = "Bearer")
    public Result<PageResult<CommentVO>> manageList(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size,
            @RequestParam(required = false) Long postId,
            @RequestParam(required = false) Comment.CommentStatus status) {
        return Result.success(commentService.getCommentPage(page, size, postId, status));
    }

    @GetMapping("/post/{postId}")
    @Operation(summary = "获取文章评论", description = "返回指定文章的已审核评论（树形结构）")
    public Result<List<CommentVO>> listByPost(
            @Parameter(description = "文章 ID") @PathVariable Long postId) {
        List<CommentVO> comments = commentService.getCommentsByPostId(postId);
        return Result.success(comments);
    }

    @PostMapping
    @Operation(summary = "发表评论", description = "游客需填写 visitorName；登录用户自动关联账号")
    public Result<CommentVO> create(@Valid @RequestBody CommentCreateDTO createDTO,
                                    HttpServletRequest request) {
        if (createDTO.getVisitorIp() == null) {
            createDTO.setVisitorIp(request.getRemoteAddr());
        }
        if (createDTO.getUserAgent() == null) {
            createDTO.setUserAgent(request.getHeader("User-Agent"));
        }
        CommentVO comment = commentService.createComment(createDTO);
        return Result.success(comment);
    }

    @PutMapping("/{id}/status")
    @PreAuthorize("hasRole('super_admin')")
    @Operation(summary = "更新评论状态")
    @SecurityRequirement(name = "Bearer")
    public Result<Void> updateStatus(
            @PathVariable Long id,
            @RequestParam Comment.CommentStatus status) {
        commentService.updateCommentStatus(id, status);
        return Result.success();
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('super_admin')")
    @Operation(summary = "删除评论", description = "仅超级管理员可删除")
    @SecurityRequirement(name = "Bearer")
    public Result<Void> delete(@Parameter(description = "评论 ID") @PathVariable Long id) {
        commentService.deleteComment(id);
        return Result.success();
    }
}
