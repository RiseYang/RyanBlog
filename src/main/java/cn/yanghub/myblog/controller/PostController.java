package cn.yanghub.myblog.controller;

import cn.yanghub.myblog.common.PageResult;
import cn.yanghub.myblog.common.Result;
import cn.yanghub.myblog.dto.PostCreateDTO;
import cn.yanghub.myblog.dto.PostUpdateDTO;
import cn.yanghub.myblog.entity.Post;
import cn.yanghub.myblog.service.PostService;
import cn.yanghub.myblog.vo.PostVO;
import com.baomidou.mybatisplus.core.metadata.IPage;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/posts")
@RequiredArgsConstructor
@Tag(name = "文章管理", description = "文章的增删改查及推荐、置顶列表")
public class PostController {

    private final PostService postService;

    @GetMapping
    @Operation(summary = "分页查询文章", description = "支持按分类、关键词筛选已发布文章")
    public Result<PageResult<PostVO>> list(
            @Parameter(description = "页码，从 1 开始") @RequestParam(defaultValue = "1") Integer page,
            @Parameter(description = "每页条数") @RequestParam(defaultValue = "10") Integer size,
            @Parameter(description = "分类 ID") @RequestParam(required = false) Long categoryId,
            @Parameter(description = "搜索关键词") @RequestParam(required = false) String keyword) {

        IPage<PostVO> postPage = postService.getPostPage(page, size, categoryId, keyword);
        return Result.success(new PageResult<>(postPage));
    }

    @GetMapping("/slug/{slug}")
    @Operation(summary = "根据 slug 获取文章", description = "通过 URL 别名获取已发布文章")
    public Result<PostVO> getBySlug(@Parameter(description = "文章 slug") @PathVariable String slug) {
        PostVO post = postService.getPostBySlug(slug);
        return Result.success(post);
    }

    @GetMapping("/manage")
    @PreAuthorize("hasAnyRole('super_admin', 'subscriber')")
    @Operation(summary = "管理端分页查询文章", description = "超级管理员查看全部，订阅者仅查看自己的文章")
    @SecurityRequirement(name = "Bearer")
    public Result<PageResult<PostVO>> manageList(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size,
            @RequestParam(required = false) Long categoryId,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) Post.PostStatus status) {
        IPage<PostVO> postPage = postService.getAdminPostPage(page, size, categoryId, keyword, status);
        return Result.success(new PageResult<>(postPage));
    }

    @GetMapping("/featured")
    @Operation(summary = "获取推荐文章", description = "获取精选推荐文章列表")
    public Result<List<PostVO>> getFeatured(
            @Parameter(description = "返回条数") @RequestParam(defaultValue = "5") Integer limit) {
        List<PostVO> posts = postService.getFeaturedPosts(limit);
        return Result.success(posts);
    }

    @GetMapping("/top")
    @Operation(summary = "获取置顶文章", description = "获取置顶文章列表")
    public Result<List<PostVO>> getTop(
            @Parameter(description = "返回条数") @RequestParam(defaultValue = "5") Integer limit) {
        List<PostVO> posts = postService.getTopPosts(limit);
        return Result.success(posts);
    }

    @GetMapping("/{id}")
    @Operation(summary = "根据 ID 获取文章", description = "获取文章详情并增加浏览量")
    public Result<PostVO> getById(@Parameter(description = "文章 ID") @PathVariable Long id) {
        PostVO post = postService.getPostById(id);
        return Result.success(post);
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('super_admin', 'subscriber')")
    @Operation(summary = "创建文章", description = "超级管理员或订阅者可创建")
    @SecurityRequirement(name = "Bearer")
    public Result<PostVO> create(@Valid @RequestBody PostCreateDTO createDTO) {
        PostVO post = postService.createPost(createDTO);
        return Result.success(post);
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('super_admin', 'subscriber')")
    @Operation(summary = "更新文章", description = "订阅者仅可编辑自己的文章")
    @SecurityRequirement(name = "Bearer")
    public Result<PostVO> update(
            @Parameter(description = "文章 ID") @PathVariable Long id,
            @Valid @RequestBody PostUpdateDTO updateDTO) {
        PostVO post = postService.updatePost(id, updateDTO);
        return Result.success(post);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('super_admin')")
    @Operation(summary = "删除文章", description = "仅超级管理员可删除")
    @SecurityRequirement(name = "Bearer")
    public Result<Void> delete(@Parameter(description = "文章 ID") @PathVariable Long id) {
        postService.deletePost(id);
        return Result.success();
    }
}
