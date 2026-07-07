package cn.yanghub.myblog.service;

import cn.yanghub.myblog.dto.UserAdminDTO;
import cn.yanghub.myblog.dto.UserDTO;
import cn.yanghub.myblog.dto.UserLoginDTO;
import cn.yanghub.myblog.dto.UserRegisterDTO;
import cn.yanghub.myblog.entity.User;
import cn.yanghub.myblog.vo.UserVO;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.service.IService;

import java.util.Map;

public interface UserService extends IService<User> {
    UserVO register(UserRegisterDTO registerDTO);
    Map<String, String> login(UserLoginDTO loginDTO);
    UserVO getCurrentUser();
    UserVO updateProfile(UserDTO userDTO);

    IPage<UserVO> getUserPage(Integer page, Integer size, String keyword, User.UserRole role, Integer status);
    UserVO getUserById(Long id);
    UserVO createUser(UserAdminDTO dto);
    UserVO updateUser(Long id, UserAdminDTO dto);
    void deleteUser(Long id);
}

