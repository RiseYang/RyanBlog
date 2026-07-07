package cn.yanghub.myblog.controller;

import cn.yanghub.myblog.common.Result;
import cn.yanghub.myblog.entity.Category;
import cn.yanghub.myblog.service.CategoryService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/categories")
@RequiredArgsConstructor
@Tag(name = "分类管理", description = "文章分类的增删改查")
public class CategoryController {

    private final CategoryService categoryService;

    @GetMapping
    @Operation(summary = "获取全部分类", description = "返回所有分类列表")
    public Result<List<Category>> list() {
        List<Category> categories = categoryService.list();
        return Result.success(categories);
    }

    @GetMapping("/nav")
    @Operation(summary = "获取导航分类", description = "返回用于导航栏展示的分类")
    public Result<List<Category>> getNavCategories() {
        List<Category> categories = categoryService.getNavCategories();
        return Result.success(categories);
    }

    @GetMapping("/{id}")
    @Operation(summary = "根据 ID 获取分类")
    public Result<Category> getById(@Parameter(description = "分类 ID") @PathVariable Long id) {
        Category category = categoryService.getById(id);
        return Result.success(category);
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('super_admin', 'subscriber')")
    @Operation(summary = "创建分类")
    public Result<Category> create(@RequestBody Category category) {
        categoryService.save(category);
        return Result.success(category);
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('super_admin', 'subscriber')")
    @Operation(summary = "更新分类")
    public Result<Category> update(
            @Parameter(description = "分类 ID") @PathVariable Long id,
            @RequestBody Category category) {
        category.setId(id);
        categoryService.updateById(category);
        return Result.success(category);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('super_admin')")
    @Operation(summary = "删除分类", description = "仅超级管理员可删除")
    public Result<Void> delete(@Parameter(description = "分类 ID") @PathVariable Long id) {
        categoryService.removeById(id);
        return Result.success();
    }
}
