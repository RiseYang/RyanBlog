package cn.yanghub.myblog.controller;

import cn.yanghub.myblog.common.PageResult;
import cn.yanghub.myblog.common.Result;
import cn.yanghub.myblog.dto.UserAdminDTO;
import cn.yanghub.myblog.entity.User;
import cn.yanghub.myblog.service.UserService;
import cn.yanghub.myblog.vo.UserVO;
import com.baomidou.mybatisplus.core.metadata.IPage;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/users")
@RequiredArgsConstructor
@Tag(name = "用户管理", description = "后台用户增删改查")
@PreAuthorize("hasRole('super_admin')")
@SecurityRequirement(name = "Bearer")
public class UserController {

    private final UserService userService;

    @GetMapping
    @Operation(summary = "分页查询用户")
    public Result<PageResult<UserVO>> list(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer size,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) User.UserRole role,
            @RequestParam(required = false) Integer status) {
        IPage<UserVO> userPage = userService.getUserPage(page, size, keyword, role, status);
        return Result.success(new PageResult<>(userPage));
    }

    @GetMapping("/{id}")
    @Operation(summary = "获取用户详情")
    public Result<UserVO> getById(@PathVariable Long id) {
        return Result.success(userService.getUserById(id));
    }

    @PostMapping
    @Operation(summary = "创建用户")
    public Result<UserVO> create(@Valid @RequestBody UserAdminDTO dto) {
        return Result.success(userService.createUser(dto));
    }

    @PutMapping("/{id}")
    @Operation(summary = "更新用户")
    public Result<UserVO> update(@PathVariable Long id, @Valid @RequestBody UserAdminDTO dto) {
        return Result.success(userService.updateUser(id, dto));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "删除用户")
    public Result<Void> delete(@PathVariable Long id) {
        userService.deleteUser(id);
        return Result.success();
    }
}
