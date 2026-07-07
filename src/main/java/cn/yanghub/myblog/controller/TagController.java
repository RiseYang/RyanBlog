package cn.yanghub.myblog.controller;

import cn.yanghub.myblog.common.Result;
import cn.yanghub.myblog.entity.Tag;
import cn.yanghub.myblog.service.TagService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/tags")
@RequiredArgsConstructor
@io.swagger.v3.oas.annotations.tags.Tag(name = "标签管理", description = "文章标签的增删查")
public class TagController {

    private final TagService tagService;

    @GetMapping
    @Operation(summary = "获取全部标签")
    public Result<List<Tag>> list() {
        List<Tag> tags = tagService.list();
        return Result.success(tags);
    }

    @GetMapping("/hot")
    @Operation(summary = "获取热门标签", description = "按使用频率返回热门标签")
    public Result<List<Tag>> getHotTags(
            @Parameter(description = "返回条数") @RequestParam(defaultValue = "20") Integer limit) {
        List<Tag> tags = tagService.getHotTags(limit);
        return Result.success(tags);
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('super_admin', 'subscriber')")
    @Operation(summary = "创建标签")
    public Result<Tag> create(@RequestBody Tag tag) {
        tagService.save(tag);
        return Result.success(tag);
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('super_admin', 'subscriber')")
    @Operation(summary = "更新标签")
    public Result<Tag> update(@PathVariable Long id, @RequestBody Tag tag) {
        tag.setId(id);
        tagService.updateById(tag);
        return Result.success(tag);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('super_admin')")
    @Operation(summary = "删除标签", description = "仅超级管理员可删除")
    public Result<Void> delete(@Parameter(description = "标签 ID") @PathVariable Long id) {
        tagService.removeById(id);
        return Result.success();
    }
}
