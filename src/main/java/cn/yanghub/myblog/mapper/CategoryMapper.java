package cn.yanghub.myblog.mapper;

import cn.yanghub.myblog.entity.Category;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import java.util.List;

@Mapper
public interface CategoryMapper extends BaseMapper<Category> {

    @Select("SELECT * FROM categories WHERE is_nav = 1 ORDER BY sort_order")
    List<Category> selectNavCategories();

    @Select("SELECT * FROM categories WHERE parent_id IS NULL ORDER BY sort_order")
    List<Category> selectRootCategories();

    @Select("SELECT * FROM categories WHERE parent_id = #{parentId} ORDER BY sort_order")
    List<Category> selectChildren(Long parentId);

    @Update("UPDATE categories SET post_count = (" +
            "SELECT COUNT(*) FROM posts WHERE category_id = #{categoryId} " +
            "AND status = 'published' AND deleted_at IS NULL) WHERE id = #{categoryId}")
    int refreshPostCount(@Param("categoryId") Long categoryId);
}