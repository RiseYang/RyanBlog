package cn.yanghub.myblog.controller;

import cn.yanghub.myblog.common.Result;
import cn.yanghub.myblog.dto.UserLoginDTO;
import cn.yanghub.myblog.dto.UserRegisterDTO;
import cn.yanghub.myblog.service.UserService;
import cn.yanghub.myblog.vo.UserVO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
@Tag(name = "认证管理", description = "用户注册、登录、登出及当前用户信息")
public class AuthController {

    private final UserService userService;

    @PostMapping("/login")
    @Operation(summary = "用户登录", description = "登录成功返回 JWT token，用于后续需要认证的接口")
    public Result<Map<String, String>> login(@Valid @RequestBody UserLoginDTO loginDTO) {
        Map<String, String> result = userService.login(loginDTO);
        return Result.success(result);
    }

    @PostMapping("/register")
    @Operation(summary = "用户注册", description = "注册新用户账号")
    public Result<UserVO> register(@Valid @RequestBody UserRegisterDTO registerDTO) {
        UserVO user = userService.register(registerDTO);
        return Result.success(user);
    }

    @GetMapping("/me")
    @Operation(summary = "获取当前用户", description = "获取当前登录用户的详细信息")
    @SecurityRequirement(name = "Bearer")
    public Result<UserVO> getCurrentUser(Authentication authentication) {
        UserVO user = userService.getCurrentUser();
        return Result.success(user);
    }

    @PostMapping("/logout")
    @Operation(summary = "用户登出", description = "JWT 无状态，客户端清除 token 即可")
    @SecurityRequirement(name = "Bearer")
    public Result<Void> logout() {
        return Result.success();
    }
}
