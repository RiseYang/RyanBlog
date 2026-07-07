/*
 Navicat Premium Dump SQL

 Source Server         : test
 Source Server Type    : MySQL
 Source Server Version : 80036 (8.0.36)
 Source Host           : localhost:3306
 Source Schema         : blog_db

 Target Server Type    : MySQL
 Target Server Version : 80036 (8.0.36)
 File Encoding         : 65001

 Date: 07/07/2026 22:21:57
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for article
-- ----------------------------
DROP TABLE IF EXISTS `article`;
CREATE TABLE `article`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '文章ID',
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '文章标题',
  `summary` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '文章摘要',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '文章内容',
  `cover_image` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '封面图片',
  `author_id` bigint NOT NULL COMMENT '作者ID',
  `category_id` bigint NULL DEFAULT NULL COMMENT '分类ID',
  `status` tinyint(1) NULL DEFAULT 0 COMMENT '文章状态：0-草稿，1-已发布，2-已删除',
  `is_top` tinyint(1) NULL DEFAULT 0 COMMENT '是否置顶：0-否，1-是',
  `view_count` int NULL DEFAULT 0 COMMENT '浏览量',
  `like_count` int NULL DEFAULT 0 COMMENT '点赞数',
  `comment_count` int NULL DEFAULT 0 COMMENT '评论数',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_author_id`(`author_id` ASC) USING BTREE,
  INDEX `idx_category_id`(`category_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_create_time`(`create_time` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '文章表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of article
-- ----------------------------
INSERT INTO `article` VALUES (1, 'Spring Boot入门教程', 'Spring Boot快速入门', 'Spring Boot是一个用于创建Spring应用的框架...', NULL, 1, 2, 1, 0, 100, 0, 0, '2026-05-05 04:28:29', '2026-05-05 04:28:29');
INSERT INTO `article` VALUES (2, 'MyBatis-Plus使用指南', 'MyBatis-Plus是MyBatis的增强工具', 'MyBatis-Plus在MyBatis的基础上只做增强不做改变...', NULL, 1, 3, 1, 0, 50, 0, 0, '2026-05-05 04:28:29', '2026-05-05 04:28:29');

-- ----------------------------
-- Table structure for article_tag
-- ----------------------------
DROP TABLE IF EXISTS `article_tag`;
CREATE TABLE `article_tag`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `article_id` bigint NOT NULL COMMENT '文章ID',
  `tag_id` bigint NOT NULL COMMENT '标签ID',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_article_tag`(`article_id` ASC, `tag_id` ASC) USING BTREE,
  INDEX `idx_article_id`(`article_id` ASC) USING BTREE,
  INDEX `idx_tag_id`(`tag_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '文章标签关联表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of article_tag
-- ----------------------------

-- ----------------------------
-- Table structure for categories
-- ----------------------------
DROP TABLE IF EXISTS `categories`;
CREATE TABLE `categories`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `slug` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `parent_id` bigint UNSIGNED NULL DEFAULT NULL,
  `level` tinyint UNSIGNED NULL DEFAULT 1,
  `path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `icon` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `color` varchar(7) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '#3b82f6',
  `sort_order` int NULL DEFAULT 0,
  `is_nav` tinyint UNSIGNED NULL DEFAULT 1,
  `is_featured` tinyint UNSIGNED NULL DEFAULT 0,
  `post_count` int UNSIGNED NULL DEFAULT 0,
  `meta_title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `meta_description` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_slug`(`slug` ASC) USING BTREE,
  INDEX `idx_parent_sort`(`parent_id` ASC, `sort_order` ASC) USING BTREE,
  CONSTRAINT `fk_category_parent` FOREIGN KEY (`parent_id`) REFERENCES `categories` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '分类表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of categories
-- ----------------------------
INSERT INTO `categories` VALUES (1, '技术教程', 'tech', '编程开发与技术分享456', NULL, 1, '1', NULL, '#3b82f6', 1, 1, 0, 0, NULL, NULL, '2026-04-03 12:05:30', '2026-04-03 12:05:30');
INSERT INTO `categories` VALUES (2, '测试123', 'frontend', 'HTML/CSS/JavaScript/Vue/React', NULL, 2, '1,2', NULL, '#3b82f6', 1, 1, 0, 1, NULL, NULL, '2026-04-03 12:05:30', '2026-07-07 21:20:04');
INSERT INTO `categories` VALUES (3, '后端开发', 'backend', 'Java/PHP/Python/Go/Node.js', NULL, 2, '1,3', NULL, '#3b82f6', 2, 1, 0, 0, NULL, NULL, '2026-04-03 12:05:30', '2026-04-03 12:05:30');
INSERT INTO `categories` VALUES (4, '生活随笔', 'life', '日常记录与思考', NULL, 1, '4', NULL, '#3b82f6', 2, 1, 0, 0, NULL, NULL, '2026-04-03 12:05:30', '2026-04-03 12:05:30');
INSERT INTO `categories` VALUES (5, '读书笔记', 'reading', '阅读分享与书评', NULL, 1, '5', NULL, '#3b82f6', 3, 1, 0, 0, NULL, NULL, '2026-04-03 12:05:30', '2026-04-03 12:05:30');

-- ----------------------------
-- Table structure for collection_folders
-- ----------------------------
DROP TABLE IF EXISTS `collection_folders`;
CREATE TABLE `collection_folders`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` bigint UNSIGNED NOT NULL,
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `is_public` tinyint UNSIGNED NULL DEFAULT 0,
  `sort_order` int NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_sort`(`user_id` ASC, `sort_order` ASC) USING BTREE,
  CONSTRAINT `fk_folder_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '收藏夹' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of collection_folders
-- ----------------------------

-- ----------------------------
-- Table structure for collections
-- ----------------------------
DROP TABLE IF EXISTS `collections`;
CREATE TABLE `collections`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` bigint UNSIGNED NOT NULL,
  `post_id` bigint UNSIGNED NOT NULL,
  `folder_id` bigint UNSIGNED NULL DEFAULT NULL,
  `note` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_user_post`(`user_id` ASC, `post_id` ASC) USING BTREE,
  INDEX `idx_user_created`(`user_id` ASC, `created_at` ASC) USING BTREE,
  INDEX `fk_collect_post`(`post_id` ASC) USING BTREE,
  CONSTRAINT `fk_collect_post` FOREIGN KEY (`post_id`) REFERENCES `posts` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_collect_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '收藏表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of collections
-- ----------------------------

-- ----------------------------
-- Table structure for comment
-- ----------------------------
DROP TABLE IF EXISTS `comment`;
CREATE TABLE `comment`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '评论ID',
  `article_id` bigint NOT NULL COMMENT '文章ID',
  `nickname` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '评论人昵称',
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '评论人邮箱',
  `website` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '评论人网站',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '评论内容',
  `parent_id` bigint NULL DEFAULT NULL COMMENT '父评论ID',
  `reply_user_id` bigint NULL DEFAULT NULL COMMENT '回复的评论ID',
  `status` tinyint(1) NULL DEFAULT 0 COMMENT '评论状态：0-待审核，1-已通过，2-已拒绝',
  `ip` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'IP地址',
  `create_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_article_id`(`article_id` ASC) USING BTREE,
  INDEX `idx_parent_id`(`parent_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '评论表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of comment
-- ----------------------------

-- ----------------------------
-- Table structure for comments
-- ----------------------------
DROP TABLE IF EXISTS `comments`;
CREATE TABLE `comments`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `post_id` bigint UNSIGNED NOT NULL,
  `parent_id` bigint UNSIGNED NULL DEFAULT NULL,
  `root_id` bigint UNSIGNED NULL DEFAULT NULL,
  `user_id` bigint UNSIGNED NULL DEFAULT NULL,
  `visitor_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `visitor_email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `visitor_website` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `visitor_ip` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `content_html` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `is_author` tinyint UNSIGNED NULL DEFAULT 0,
  `status` enum('pending','approved','rejected','spam') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'pending',
  `like_count` int UNSIGNED NULL DEFAULT 0,
  `reply_count` int UNSIGNED NULL DEFAULT 0,
  `user_agent` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_post_status`(`post_id` ASC, `status` ASC, `created_at` ASC) USING BTREE,
  INDEX `idx_root_id`(`root_id` ASC, `created_at` ASC) USING BTREE,
  INDEX `idx_parent_id`(`parent_id` ASC) USING BTREE,
  INDEX `fk_comment_user`(`user_id` ASC) USING BTREE,
  FULLTEXT INDEX `idx_content`(`content`),
  CONSTRAINT `fk_comment_parent` FOREIGN KEY (`parent_id`) REFERENCES `comments` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_comment_post` FOREIGN KEY (`post_id`) REFERENCES `posts` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_comment_root` FOREIGN KEY (`root_id`) REFERENCES `comments` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_comment_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '评论表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of comments
-- ----------------------------

-- ----------------------------
-- Table structure for follows
-- ----------------------------
DROP TABLE IF EXISTS `follows`;
CREATE TABLE `follows`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `follower_id` bigint UNSIGNED NOT NULL,
  `following_id` bigint UNSIGNED NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_follow`(`follower_id` ASC, `following_id` ASC) USING BTREE,
  INDEX `idx_following`(`following_id` ASC, `created_at` ASC) USING BTREE,
  CONSTRAINT `fk_follower` FOREIGN KEY (`follower_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_following` FOREIGN KEY (`following_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '关注表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of follows
-- ----------------------------

-- ----------------------------
-- Table structure for likes
-- ----------------------------
DROP TABLE IF EXISTS `likes`;
CREATE TABLE `likes`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` bigint UNSIGNED NULL DEFAULT NULL,
  `likeable_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `likeable_id` bigint UNSIGNED NOT NULL,
  `visitor_ip` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `user_agent` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_user_likeable`(`user_id` ASC, `likeable_type` ASC, `likeable_id` ASC) USING BTREE,
  UNIQUE INDEX `uk_ip_likeable`(`visitor_ip` ASC, `likeable_type` ASC, `likeable_id` ASC) USING BTREE,
  INDEX `idx_likeable`(`likeable_type` ASC, `likeable_id` ASC, `created_at` ASC) USING BTREE,
  CONSTRAINT `fk_like_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '点赞表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of likes
-- ----------------------------

-- ----------------------------
-- Table structure for links
-- ----------------------------
DROP TABLE IF EXISTS `links`;
CREATE TABLE `links`  (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `logo` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `contact_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `contact_email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `sort_order` int NULL DEFAULT 0,
  `status` tinyint UNSIGNED NULL DEFAULT 1,
  `nofollow` tinyint UNSIGNED NULL DEFAULT 1,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_status_sort`(`status` ASC, `sort_order` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '友链表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of links
-- ----------------------------

-- ----------------------------
-- Table structure for media
-- ----------------------------
DROP TABLE IF EXISTS `media`;
CREATE TABLE `media`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` bigint UNSIGNED NULL DEFAULT NULL,
  `filename` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `original_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `file_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_type` enum('image','video','audio','document','other') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'image',
  `mime_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `file_size` bigint UNSIGNED NULL DEFAULT 0,
  `width` int UNSIGNED NULL DEFAULT NULL,
  `height` int UNSIGNED NULL DEFAULT NULL,
  `thumbnails` json NULL,
  `alt_text` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `caption` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `usage_count` int UNSIGNED NULL DEFAULT 0,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `storage_type` enum('local','oss','cos','s3','cdn') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'local',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_type`(`user_id` ASC, `file_type` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '媒体表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of media
-- ----------------------------

-- ----------------------------
-- Table structure for menus
-- ----------------------------
DROP TABLE IF EXISTS `menus`;
CREATE TABLE `menus`  (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `location` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `parent_id` int UNSIGNED NULL DEFAULT NULL,
  `level` tinyint UNSIGNED NULL DEFAULT 1,
  `title` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `target` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '_self',
  `icon` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `sort_order` int NULL DEFAULT 0,
  `is_active` tinyint UNSIGNED NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_location_sort`(`location` ASC, `sort_order` ASC) USING BTREE,
  INDEX `idx_parent`(`parent_id` ASC) USING BTREE,
  CONSTRAINT `fk_menu_parent` FOREIGN KEY (`parent_id`) REFERENCES `menus` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '菜单表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of menus
-- ----------------------------
INSERT INTO `menus` VALUES (1, '首页', 'header', NULL, 1, '首页', '/', '_self', NULL, 1, 1, '2026-04-03 12:05:30');
INSERT INTO `menus` VALUES (2, '归档', 'header', NULL, 1, '归档', '/archives', '_self', NULL, 2, 1, '2026-04-03 12:05:30');
INSERT INTO `menus` VALUES (3, '标签', 'header', NULL, 1, '标签', '/tags', '_self', NULL, 3, 1, '2026-04-03 12:05:30');
INSERT INTO `menus` VALUES (4, '关于', 'header', NULL, 1, '关于', '/about', '_self', NULL, 4, 1, '2026-04-03 12:05:30');

-- ----------------------------
-- Table structure for notifications
-- ----------------------------
DROP TABLE IF EXISTS `notifications`;
CREATE TABLE `notifications`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` bigint UNSIGNED NOT NULL,
  `sender_id` bigint UNSIGNED NULL DEFAULT NULL,
  `type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `action_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `action_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `target_id` bigint UNSIGNED NULL DEFAULT NULL,
  `target_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `is_read` tinyint UNSIGNED NULL DEFAULT 0,
  `read_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_read`(`user_id` ASC, `is_read` ASC, `created_at` ASC) USING BTREE,
  INDEX `idx_type`(`type` ASC) USING BTREE,
  INDEX `fk_notify_sender`(`sender_id` ASC) USING BTREE,
  CONSTRAINT `fk_notify_sender` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `fk_notify_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '通知表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of notifications
-- ----------------------------

-- ----------------------------
-- Table structure for pages
-- ----------------------------
DROP TABLE IF EXISTS `pages`;
CREATE TABLE `pages`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `author_id` bigint UNSIGNED NOT NULL,
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `slug` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `content` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `content_type` enum('markdown','html','rich_text') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'markdown',
  `template` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'default',
  `status` enum('draft','published','hidden') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'draft',
  `is_show_nav` tinyint UNSIGNED NULL DEFAULT 0,
  `is_show_footer` tinyint UNSIGNED NULL DEFAULT 0,
  `sort_order` int NULL DEFAULT 0,
  `view_count` int UNSIGNED NULL DEFAULT 0,
  `meta_title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `meta_description` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_slug`(`slug` ASC) USING BTREE,
  INDEX `idx_status_nav`(`status` ASC, `is_show_nav` ASC, `sort_order` ASC) USING BTREE,
  INDEX `fk_page_author`(`author_id` ASC) USING BTREE,
  CONSTRAINT `fk_page_author` FOREIGN KEY (`author_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '页面表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of pages
-- ----------------------------

-- ----------------------------
-- Table structure for post_media
-- ----------------------------
DROP TABLE IF EXISTS `post_media`;
CREATE TABLE `post_media`  (
  `post_id` bigint UNSIGNED NOT NULL,
  `media_id` bigint UNSIGNED NOT NULL,
  `sort_order` int NULL DEFAULT 0,
  `is_cover` tinyint UNSIGNED NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`post_id`, `media_id`) USING BTREE,
  INDEX `fk_pm_media`(`media_id` ASC) USING BTREE,
  CONSTRAINT `fk_pm_media` FOREIGN KEY (`media_id`) REFERENCES `media` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_pm_post` FOREIGN KEY (`post_id`) REFERENCES `posts` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '文章媒体关联' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of post_media
-- ----------------------------

-- ----------------------------
-- Table structure for post_tags
-- ----------------------------
DROP TABLE IF EXISTS `post_tags`;
CREATE TABLE `post_tags`  (
  `post_id` bigint UNSIGNED NOT NULL,
  `tag_id` bigint UNSIGNED NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`post_id`, `tag_id`) USING BTREE,
  INDEX `idx_tag_post`(`tag_id` ASC, `created_at` ASC) USING BTREE,
  CONSTRAINT `fk_pt_post` FOREIGN KEY (`post_id`) REFERENCES `posts` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_pt_tag` FOREIGN KEY (`tag_id`) REFERENCES `tags` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '文章标签关联' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of post_tags
-- ----------------------------

-- ----------------------------
-- Table structure for posts
-- ----------------------------
DROP TABLE IF EXISTS `posts`;
CREATE TABLE `posts`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `author_id` bigint UNSIGNED NOT NULL,
  `category_id` bigint UNSIGNED NULL DEFAULT NULL,
  `title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `slug` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `excerpt` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `content` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `content_type` enum('markdown','html','rich_text','block') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'markdown',
  `cover_image` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `cover_thumb` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status` enum('draft','published','archived','scheduled','private') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'draft',
  `visibility` enum('public','password','private','paid') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'public',
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `scheduled_at` timestamp NULL DEFAULT NULL,
  `published_at` timestamp NULL DEFAULT NULL,
  `is_top` tinyint UNSIGNED NULL DEFAULT 0,
  `is_featured` tinyint UNSIGNED NULL DEFAULT 0,
  `is_original` tinyint UNSIGNED NULL DEFAULT 1,
  `source_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `source_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `allow_comment` tinyint UNSIGNED NULL DEFAULT 1,
  `allow_like` tinyint UNSIGNED NULL DEFAULT 1,
  `allow_share` tinyint UNSIGNED NULL DEFAULT 1,
  `view_count` int UNSIGNED NULL DEFAULT 0,
  `like_count` int UNSIGNED NULL DEFAULT 0,
  `comment_count` int UNSIGNED NULL DEFAULT 0,
  `collect_count` int UNSIGNED NULL DEFAULT 0,
  `word_count` int UNSIGNED NULL DEFAULT 0,
  `reading_time` int UNSIGNED NULL DEFAULT 0,
  `meta_title` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `meta_description` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `meta_keywords` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `canonical_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_slug`(`slug` ASC) USING BTREE,
  INDEX `idx_author_status`(`author_id` ASC, `status` ASC) USING BTREE,
  INDEX `idx_category_status`(`category_id` ASC, `status` ASC) USING BTREE,
  INDEX `idx_status_published`(`status` ASC, `published_at` ASC) USING BTREE,
  INDEX `idx_is_top`(`is_top` ASC, `published_at` ASC) USING BTREE,
  FULLTEXT INDEX `idx_title_content`(`title`, `content`),
  CONSTRAINT `fk_post_author` FOREIGN KEY (`author_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `fk_post_category` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '文章表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of posts
-- ----------------------------
INSERT INTO `posts` VALUES (1, 1, 2, '测试', '测试', '1213', 'hhjkshks', 'markdown', '', NULL, 'published', 'public', NULL, NULL, '2026-07-07 21:20:05', 0, 0, 1, NULL, NULL, 1, 1, 1, 0, 0, 0, 0, 8, 1, NULL, NULL, NULL, NULL, '2026-07-07 21:20:05', '2026-07-07 21:20:05', NULL);

-- ----------------------------
-- Table structure for settings
-- ----------------------------
DROP TABLE IF EXISTS `settings`;
CREATE TABLE `settings`  (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `type` enum('string','text','number','boolean','json','array') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'string',
  `group` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'general',
  `label` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `options` json NULL,
  `is_public` tinyint UNSIGNED NULL DEFAULT 0,
  `is_system` tinyint UNSIGNED NULL DEFAULT 0,
  `sort_order` int NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_key`(`key` ASC) USING BTREE,
  INDEX `idx_group`(`group` ASC, `sort_order` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 16 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '配置表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of settings
-- ----------------------------
INSERT INTO `settings` VALUES (1, 'site_name', '我的博客', 'string', 'general', '站点名称', '网站标题', NULL, 1, 1, 0, '2026-04-03 12:05:30', '2026-04-03 12:05:30');
INSERT INTO `settings` VALUES (2, 'site_description', '记录生活，分享技术', 'string', 'general', '站点描述', 'SEO描述', NULL, 1, 1, 0, '2026-04-03 12:05:30', '2026-04-03 12:05:30');
INSERT INTO `settings` VALUES (3, 'site_logo', '/images/logo.png', 'string', 'general', '站点Logo', '', NULL, 1, 0, 0, '2026-04-03 12:05:30', '2026-04-03 12:05:30');
INSERT INTO `settings` VALUES (4, 'site_favicon', '/favicon.ico', 'string', 'general', '站点图标', '', NULL, 1, 0, 0, '2026-04-03 12:05:30', '2026-04-03 12:05:30');
INSERT INTO `settings` VALUES (5, 'site_icp', '', 'string', 'general', '备案号', 'ICP备案信息', NULL, 1, 0, 0, '2026-04-03 12:05:30', '2026-04-03 12:05:30');
INSERT INTO `settings` VALUES (6, 'posts_per_page', '12', 'number', 'general', '每页文章数', '', NULL, 1, 0, 0, '2026-04-03 12:05:30', '2026-04-03 12:05:30');
INSERT INTO `settings` VALUES (7, 'theme', 'default', 'string', 'appearance', '主题', '当前使用主题', NULL, 1, 0, 0, '2026-04-03 12:05:30', '2026-04-03 12:05:30');
INSERT INTO `settings` VALUES (8, 'comment_need_approve', '1', 'boolean', 'comment', '评论需审核', '评论是否需要审核', NULL, 0, 0, 0, '2026-04-03 12:05:30', '2026-04-03 12:05:30');
INSERT INTO `settings` VALUES (9, 'comment_allow_anonymous', '1', 'boolean', 'comment', '允许游客评论', '', NULL, 1, 0, 0, '2026-04-03 12:05:30', '2026-04-03 12:05:30');
INSERT INTO `settings` VALUES (10, 'allow_register', '0', 'boolean', 'user', '开放注册', '是否允许新用户注册', NULL, 0, 0, 0, '2026-04-03 12:05:30', '2026-04-03 12:05:30');
INSERT INTO `settings` VALUES (11, 'seo_title_format', '{title} - {site_name}', 'string', 'seo', '标题格式', 'SEO标题模板', NULL, 0, 0, 0, '2026-04-03 12:05:30', '2026-04-03 12:05:30');
INSERT INTO `settings` VALUES (12, 'analytics_baidu', '', 'text', 'analytics', '百度统计代码', '', NULL, 0, 0, 0, '2026-04-03 12:05:30', '2026-04-03 12:05:30');
INSERT INTO `settings` VALUES (13, 'analytics_google', '', 'text', 'analytics', 'Google统计代码', '', NULL, 0, 0, 0, '2026-04-03 12:05:30', '2026-04-03 12:05:30');
INSERT INTO `settings` VALUES (14, 'smtp_host', '', 'string', 'smtp', 'SMTP服务器', '邮件发送配置', NULL, 0, 0, 0, '2026-04-03 12:05:30', '2026-04-03 12:05:30');
INSERT INTO `settings` VALUES (15, 'cdn_domain', '', 'string', 'storage', 'CDN域名', '静态资源加速域名', NULL, 0, 0, 0, '2026-04-03 12:05:30', '2026-04-03 12:05:30');

-- ----------------------------
-- Table structure for tags
-- ----------------------------
DROP TABLE IF EXISTS `tags`;
CREATE TABLE `tags`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `slug` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `color` varchar(7) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '#10b981',
  `description` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `post_count` int UNSIGNED NULL DEFAULT 0,
  `is_featured` tinyint UNSIGNED NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_slug`(`slug` ASC) USING BTREE,
  INDEX `idx_featured_count`(`is_featured` ASC, `post_count` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '标签表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of tags
-- ----------------------------
INSERT INTO `tags` VALUES (1, '后端', '后端', '#0d9488', '123', 0, 0, '2026-07-07 21:15:19');
INSERT INTO `tags` VALUES (2, '前端', '前端', '#940d24', 'dsds', 0, 0, '2026-07-07 21:15:49');

-- ----------------------------
-- Table structure for users
-- ----------------------------
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户名',
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '邮箱',
  `password_hash` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `nickname` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `avatar_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `bio` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `website` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `role` enum('super_admin','admin','editor','author','subscriber') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'subscriber',
  `status` tinyint UNSIGNED NULL DEFAULT 1,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `last_login_at` timestamp NULL DEFAULT NULL,
  `last_login_ip` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `login_fail_count` tinyint UNSIGNED NULL DEFAULT 0,
  `locked_until` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` int UNSIGNED NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_username`(`username` ASC) USING BTREE,
  UNIQUE INDEX `uk_email`(`email` ASC) USING BTREE,
  INDEX `idx_status_role`(`status` ASC, `role` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '用户表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of users
-- ----------------------------
INSERT INTO `users` VALUES (1, 'admin', 'admin@example.com', '$2a$10$2eGr0lbLgSJ2JvGPH7XBpORBjiEZYaMqCMub8lMRTh8fQGyupDlvu', '管理员', NULL, NULL, NULL, 'super_admin', 1, '2026-04-03 12:05:30', '2026-07-07 22:09:20', '127.0.0.1', 0, NULL, '2026-04-03 12:05:30', '2026-04-16 21:21:07', 0);
INSERT INTO `users` VALUES (2, 'zhangsan', 'test@test.com', '$2a$10$2eGr0lbLgSJ2JvGPH7XBpORBjiEZYaMqCMub8lMRTh8fQGyupDlvu', NULL, NULL, NULL, NULL, 'subscriber', 1, NULL, '2026-04-16 21:05:33', '127.0.0.1', 0, NULL, '2026-04-15 22:41:24', '2026-04-15 23:14:57', 0);
INSERT INTO `users` VALUES (3, '阳阳3333', '1562275143@qq.com', '$2a$10$oT.h04jDmXAmObQRNADkUeZmHnqe4bnEVQ9fn2Ndk6hJmFdzQsQJm', 'py123', NULL, NULL, NULL, 'subscriber', 1, NULL, NULL, NULL, 0, NULL, '2026-07-07 20:16:19', '2026-07-07 20:23:44', 0);
INSERT INTO `users` VALUES (4, 'py123', 'py123@test.com', '$2a$10$cw7fQtBnAL8Va1p1x6BF4O1deydjwQSKV91v7iD0FSDMwy7KLfcjS', 'py123', NULL, NULL, NULL, 'subscriber', 1, NULL, '2026-07-07 22:03:57', '127.0.0.1', 0, NULL, '2026-07-07 20:22:26', '2026-07-07 20:22:26', 0);

-- ----------------------------
-- Table structure for visit_stats_daily
-- ----------------------------
DROP TABLE IF EXISTS `visit_stats_daily`;
CREATE TABLE `visit_stats_daily`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `stat_date` date NOT NULL,
  `post_id` bigint UNSIGNED NULL DEFAULT NULL,
  `page_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'post',
  `pv` int UNSIGNED NULL DEFAULT 0,
  `uv` int UNSIGNED NULL DEFAULT 0,
  `ip_count` int UNSIGNED NULL DEFAULT 0,
  `new_visitors` int UNSIGNED NULL DEFAULT 0,
  `avg_duration` int UNSIGNED NULL DEFAULT 0,
  `bounce_rate` decimal(5, 2) NULL DEFAULT 0.00,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_date_post`(`stat_date` ASC, `post_id` ASC) USING BTREE,
  INDEX `idx_date`(`stat_date` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '每日统计' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of visit_stats_daily
-- ----------------------------

-- ----------------------------
-- Table structure for visits
-- ----------------------------
DROP TABLE IF EXISTS `visits`;
CREATE TABLE `visits`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `post_id` bigint UNSIGNED NULL DEFAULT NULL COMMENT '文章ID，应用层确保有效性',
  `page_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'post',
  `visitor_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `user_id` bigint UNSIGNED NULL DEFAULT NULL COMMENT '关联users.id，无FK约束',
  `ip_address` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_agent` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `referrer` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `country` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `city` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `device_type` enum('desktop','mobile','tablet','other') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'other',
  `browser` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `os` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`, `created_at`) USING BTREE,
  INDEX `idx_post_created`(`post_id` ASC, `created_at` ASC) USING BTREE,
  INDEX `idx_user_created`(`user_id` ASC, `created_at` ASC) USING BTREE,
  INDEX `idx_visitor_created`(`visitor_id` ASC, `created_at` ASC) USING BTREE,
  INDEX `idx_created`(`created_at` ASC) USING BTREE,
  INDEX `idx_ip`(`ip_address` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '访问日志-分区表' ROW_FORMAT = Dynamic PARTITION BY RANGE (year(`created_at`))
PARTITIONS 4
(PARTITION `p2024` VALUES LESS THAN (2025) ENGINE = InnoDB MAX_ROWS = 0 MIN_ROWS = 0 ,
PARTITION `p2025` VALUES LESS THAN (2026) ENGINE = InnoDB MAX_ROWS = 0 MIN_ROWS = 0 ,
PARTITION `p2026` VALUES LESS THAN (2027) ENGINE = InnoDB MAX_ROWS = 0 MIN_ROWS = 0 ,
PARTITION `pfuture` VALUES LESS THAN (MAXVALUE) ENGINE = InnoDB MAX_ROWS = 0 MIN_ROWS = 0 )
;

-- ----------------------------
-- Records of visits
-- ----------------------------

-- ----------------------------
-- View structure for v_posts_list
-- ----------------------------
DROP VIEW IF EXISTS `v_posts_list`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `v_posts_list` AS select `p`.`id` AS `id`,`p`.`title` AS `title`,`p`.`slug` AS `slug`,`p`.`excerpt` AS `excerpt`,`p`.`cover_image` AS `cover_image`,`p`.`cover_thumb` AS `cover_thumb`,`p`.`status` AS `status`,`p`.`is_top` AS `is_top`,`p`.`is_featured` AS `is_featured`,`p`.`is_original` AS `is_original`,`p`.`view_count` AS `view_count`,`p`.`like_count` AS `like_count`,`p`.`comment_count` AS `comment_count`,`p`.`word_count` AS `word_count`,`p`.`reading_time` AS `reading_time`,`p`.`published_at` AS `published_at`,`p`.`created_at` AS `created_at`,`u`.`id` AS `author_id`,`u`.`nickname` AS `author_name`,`u`.`avatar_url` AS `author_avatar`,`c`.`id` AS `category_id`,`c`.`name` AS `category_name`,`c`.`slug` AS `category_slug`,`c`.`color` AS `category_color` from ((`posts` `p` left join `users` `u` on((`p`.`author_id` = `u`.`id`))) left join `categories` `c` on((`p`.`category_id` = `c`.`id`))) where (`p`.`deleted_at` is null);

-- ----------------------------
-- View structure for v_posts_with_tags
-- ----------------------------
DROP VIEW IF EXISTS `v_posts_with_tags`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `v_posts_with_tags` AS select `p`.`id` AS `id`,`p`.`title` AS `title`,`p`.`slug` AS `slug`,`p`.`excerpt` AS `excerpt`,`p`.`cover_image` AS `cover_image`,`p`.`cover_thumb` AS `cover_thumb`,`p`.`status` AS `status`,`p`.`is_top` AS `is_top`,`p`.`is_featured` AS `is_featured`,`p`.`is_original` AS `is_original`,`p`.`view_count` AS `view_count`,`p`.`like_count` AS `like_count`,`p`.`comment_count` AS `comment_count`,`p`.`word_count` AS `word_count`,`p`.`reading_time` AS `reading_time`,`p`.`published_at` AS `published_at`,`p`.`created_at` AS `created_at`,`p`.`author_id` AS `author_id`,`p`.`author_name` AS `author_name`,`p`.`author_avatar` AS `author_avatar`,`p`.`category_id` AS `category_id`,`p`.`category_name` AS `category_name`,`p`.`category_slug` AS `category_slug`,`p`.`category_color` AS `category_color`,group_concat(distinct `t`.`name` order by `pt`.`created_at` ASC separator ',') AS `tag_names`,group_concat(distinct `t`.`slug` order by `pt`.`created_at` ASC separator ',') AS `tag_slugs`,group_concat(distinct `t`.`color` order by `pt`.`created_at` ASC separator ',') AS `tag_colors` from ((`v_posts_list` `p` left join `post_tags` `pt` on((`p`.`id` = `pt`.`post_id`))) left join `tags` `t` on((`pt`.`tag_id` = `t`.`id`))) group by `p`.`id`;

-- ----------------------------
-- Triggers structure for table comments
-- ----------------------------
DROP TRIGGER IF EXISTS `trg_comment_insert_count`;
delimiter ;;
CREATE TRIGGER `trg_comment_insert_count` AFTER INSERT ON `comments` FOR EACH ROW BEGIN
    IF NEW.status = 'approved' THEN
        UPDATE `posts` SET `comment_count` = `comment_count` + 1 WHERE `id` = NEW.post_id;
        IF NEW.parent_id IS NOT NULL THEN
            UPDATE `comments` SET `reply_count` = `reply_count` + 1 WHERE `id` = NEW.parent_id;
        END IF;
    END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table comments
-- ----------------------------
DROP TRIGGER IF EXISTS `trg_comment_delete_count`;
delimiter ;;
CREATE TRIGGER `trg_comment_delete_count` AFTER DELETE ON `comments` FOR EACH ROW BEGIN
    IF OLD.status = 'approved' THEN
        UPDATE `posts` SET `comment_count` = `comment_count` - 1 WHERE `id` = OLD.post_id;
    END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table post_tags
-- ----------------------------
DROP TRIGGER IF EXISTS `trg_post_tag_insert`;
delimiter ;;
CREATE TRIGGER `trg_post_tag_insert` AFTER INSERT ON `post_tags` FOR EACH ROW BEGIN
    UPDATE `tags` SET `post_count` = `post_count` + 1 WHERE `id` = NEW.tag_id;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table post_tags
-- ----------------------------
DROP TRIGGER IF EXISTS `trg_post_tag_delete`;
delimiter ;;
CREATE TRIGGER `trg_post_tag_delete` AFTER DELETE ON `post_tags` FOR EACH ROW BEGIN
    UPDATE `tags` SET `post_count` = `post_count` - 1 WHERE `id` = OLD.tag_id;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table posts
-- ----------------------------
DROP TRIGGER IF EXISTS `trg_post_insert_category_count`;
delimiter ;;
CREATE TRIGGER `trg_post_insert_category_count` AFTER INSERT ON `posts` FOR EACH ROW BEGIN
    IF NEW.category_id IS NOT NULL AND NEW.status = 'published' THEN
        UPDATE `categories` SET `post_count` = `post_count` + 1 WHERE `id` = NEW.category_id;
    END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table posts
-- ----------------------------
DROP TRIGGER IF EXISTS `trg_post_update_category_count`;
delimiter ;;
CREATE TRIGGER `trg_post_update_category_count` AFTER UPDATE ON `posts` FOR EACH ROW BEGIN
    IF OLD.status != 'published' AND NEW.status = 'published' THEN
        IF NEW.category_id IS NOT NULL THEN
            UPDATE `categories` SET `post_count` = `post_count` + 1 WHERE `id` = NEW.category_id;
        END IF;
    ELSEIF OLD.status = 'published' AND NEW.status != 'published' THEN
        IF OLD.category_id IS NOT NULL THEN
            UPDATE `categories` SET `post_count` = `post_count` - 1 WHERE `id` = OLD.category_id;
        END IF;
    ELSEIF OLD.status = 'published' AND NEW.status = 'published' AND OLD.category_id != NEW.category_id THEN
        IF OLD.category_id IS NOT NULL THEN
            UPDATE `categories` SET `post_count` = `post_count` - 1 WHERE `id` = OLD.category_id;
        END IF;
        IF NEW.category_id IS NOT NULL THEN
            UPDATE `categories` SET `post_count` = `post_count` + 1 WHERE `id` = NEW.category_id;
        END IF;
    END IF;
END
;;
delimiter ;

-- ----------------------------
-- Triggers structure for table posts
-- ----------------------------
DROP TRIGGER IF EXISTS `trg_post_delete_category_count`;
delimiter ;;
CREATE TRIGGER `trg_post_delete_category_count` AFTER DELETE ON `posts` FOR EACH ROW BEGIN
    IF OLD.category_id IS NOT NULL AND OLD.status = 'published' THEN
        UPDATE `categories` SET `post_count` = `post_count` - 1 WHERE `id` = OLD.category_id;
    END IF;
END
;;
delimiter ;

SET FOREIGN_KEY_CHECKS = 1;
