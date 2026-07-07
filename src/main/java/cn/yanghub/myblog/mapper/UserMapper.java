package cn.yanghub.myblog.mapper;

import cn.yanghub.myblog.entity.User;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

@Mapper
public interface UserMapper extends BaseMapper<User> {

    String NOT_DELETED = "(deleted_at IS NULL OR deleted_at = 0)";

    @Select("SELECT * FROM users WHERE username = #{username} AND " + NOT_DELETED)
    User selectByUsername(String username);

    @Select("SELECT * FROM users WHERE email = #{email} AND " + NOT_DELETED)
    User selectByEmail(String email);

    @Select("SELECT * FROM users WHERE " + NOT_DELETED + " AND (username = #{username} OR email = #{email})")
    User selectByUsernameOrEmail(@Param("username") String username, @Param("email") String email);

    @Update("UPDATE users SET deleted_at = 0 WHERE deleted_at IS NULL")
    int normalizeDeletedAt();
}
