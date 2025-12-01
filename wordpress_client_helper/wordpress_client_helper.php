<?php
/**
 * Plugin Name:        Wordpress Client Helper
 * Plugin URI:         https://github.com/ArunPrakashG/wordpress_client
 * Description:        This plugin include user meta and other help data into the WordPress REST API (v2) without additional API requests.
 *
 *
 * Author:             Arun Prakash
 * Version:            0.0.3
 * Author URI:         https://arunprakashg.com
 *
 * License:            GPL v3
 *
 * Text Domain:        Wordpress Client Helper
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 **/

if (!defined('WPINC')) {
    die;
}

class wordpress_client_helper
{
    /**
     * Set the featured image size
     *
     * 'thumbnail'  Thumbnail (Note: different to Post Thumbnail)
     * 'medium'     Medium resolution
     * 'large'      Large resolution
     * 'full'       Original resolution
     *
     * @var string $image_size
     */
    private $image_size = 'full';

    public function __construct()
    {
        register_rest_route(
            'wpc/v2',
            '/related-posts/(?P<post_id>[\d]+)',
            array(
                'methods' => 'GET',
                'callback' => function ($request) {
                    return $this->on_related_posts($request);
                },
                'permission_callback' => '__return_true'
            )
        );

        register_rest_field('post', 'author_meta', [
            'get_callback' => array($this, 'get_author_meta'),
            'update_callback' => 'null',
            'schema' => 'null',
        ]);

        register_rest_field(
            'post',
            'featured_image_url',
            array(
                'get_callback' => function ($post) {
                    return $this->featured_media_src($post);
                },
                'update_callback' => null,
                'schema' => null,
            )
        );

        register_rest_field(
            'search-result',
            'featured_image_src',
            array(
                'get_callback' => function ($post_arr) {
                    $image_src_arr = get_the_post_thumbnail_url($post_arr['id']);
                    return $image_src_arr;
                },
                'update_callback' => null,
                'schema' => null
            )
        );
    }

    public function featured_media_src($post = null)
    {
        $media = array_key_exists('featured_media', $post);

        if ($media) {
            $media_src = wp_get_attachment_image_src($post['featured_media'], $this->image_size);
            return $media_src[0];
        }

        return null;
    }

    public function get_author_meta($object, $field_name, $request)
    {
        $user_data = get_userdata($object['author']); // get user data from author ID.

        $array_data = (array) ($user_data->data); // object to array conversion.

        $array_data['first_name'] = get_user_meta($object['author'], 'first_name', true);
        $array_data['last_name'] = get_user_meta($object['author'], 'last_name', true);

        // prevent user enumeration.
        unset($array_data['user_login']);
        unset($array_data['user_registered']);
        unset($array_data['user_email']);
        unset($array_data['user_pass']);
        unset($array_data['user_activation_key']);

        $user_data = null; // free memory.
        return array_filter($array_data);
    }

    function on_related_posts($request)
    {
        $post_id = $request->get_param('id');

        $related_posts = get_posts(
            array(
                'post_type' => 'post',
                'category__in' => wp_get_post_categories($post_id),
                'posts_per_page' => 6,
                'post__not_in' => array($post_id),
            )
        );

        $post_id = null; // free memory.
        return $related_posts;
    }
}

add_action('rest_api_init', function () {
    $wordpress_client_helper = new wordpress_client_helper;
});
