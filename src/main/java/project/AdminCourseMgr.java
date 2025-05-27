package project;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Vector;


public class AdminCourseMgr {
    private DBConnectionMgr pool;
    
    public AdminCourseMgr() {
        pool = DBConnectionMgr.getInstance();
    }

    public boolean insertCourse(AdminCourseBean bean) {
        Connection con = null;
        PreparedStatement pstmt = null;
        boolean result = false;
        try {
            con = pool.getConnection();           
            String sql = "INSERT INTO rst_course (course_title, description, course_tag, stores, course_watch, course_like, image_path) " +
                         "VALUES (?, ?, ?, ?, ?, ?, ?)";
            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, bean.getCourseTitle());
            pstmt.setString(2, bean.getDescription());
            pstmt.setString(3, bean.getCourseTag());
            pstmt.setString(4, bean.getStores());
            pstmt.setInt(5, bean.getCourseWatch());
            pstmt.setInt(6, bean.getCourseLike());
            pstmt.setString(7, bean.getImagePath());
            int cnt = pstmt.executeUpdate();
            if(cnt > 0) {
                result = true;
            }
        } catch(Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(con, pstmt);
        }
        return result;
    }
    

    public Vector<AdminCourseBean> getCourseList(int startRow, int pageSize, String order) {
        Vector<AdminCourseBean> list = new Vector<>();
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            con = pool.getConnection();

            String sql;
            if ("popular".equals(order)) {
                sql = "SELECT c.*, COUNT(l.like_id) AS like_count " +
                      "FROM rst_course c " +
                      "LEFT JOIN likes l ON c.course_id = l.target_id AND l.target_type = 'course' " +
                      "GROUP BY c.course_id " +
                      "ORDER BY like_count DESC " +
                      "LIMIT ?, ?";
            } else {
                sql = "SELECT * FROM rst_course ORDER BY course_id DESC LIMIT ?, ?";
            }

            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, startRow);
            pstmt.setInt(2, pageSize);

            rs = pstmt.executeQuery();
            while (rs.next()) {
                AdminCourseBean bean = new AdminCourseBean();
                bean.setCourseId(rs.getInt("course_id"));
                bean.setCourseTitle(rs.getString("course_title"));
                bean.setDescription(rs.getString("description"));
                bean.setCourseTag(rs.getString("course_tag"));
                bean.setStores(rs.getString("stores"));
                bean.setCourseWatch(rs.getInt("course_watch"));
                bean.setCourseLike(rs.getInt("course_like"));
                bean.setImagePath(rs.getString("image_path"));
                list.add(bean);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(con, pstmt, rs);
        }
        return list;
    }

    

	// 코스 ID로 코스 1개 가져오기
	public AdminCourseBean getCourseById(int courseId) {
		Connection con = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		AdminCourseBean bean = new AdminCourseBean();
		String sql = "SELECT * FROM rst_course WHERE course_id = ?";
		try {
			con = pool.getConnection();
			pstmt = con.prepareStatement(sql);
			pstmt.setInt(1, courseId);
			rs = pstmt.executeQuery();
			if (rs.next()) {
				bean.setCourseId(rs.getInt("course_id"));
				bean.setCourseTitle(rs.getString("course_title"));
				bean.setDescription(rs.getString("description"));
				bean.setCourseTag(rs.getString("course_tag"));
				bean.setStores(rs.getString("stores"));
				bean.setCourseWatch(rs.getInt("course_watch"));
				bean.setCourseLike(rs.getInt("course_like"));
			}
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			pool.freeConnection(con, pstmt, rs);
		}
		return bean;
	}


    public int getCourseCount() {
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int count = 0;
        try {
            con = pool.getConnection();
            String sql = "SELECT COUNT(*) FROM rst_course";
            pstmt = con.prepareStatement(sql);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                count = rs.getInt(1);
            }
        } catch(Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(con, pstmt, rs);
        }
        return count;
    }

    public void incrementCourseWatch(int courseId) {
        Connection con = null;
        PreparedStatement pstmt = null;
        String sql = "UPDATE rst_course SET course_watch = course_watch + 1 WHERE course_id = ?";

        try {
            con = pool.getConnection();
            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, courseId);
            pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(con, pstmt);
        }
    }
    
    public Vector<AdminCourseBean> getBookmarkedCoursesByMember(String memberId, int start, int pageSize) {
        Vector<AdminCourseBean> list = new Vector<>();
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

		String sql = "SELECT c.* FROM rst_course c JOIN rst_course_bookmark b ON c.course_id = b.course_id "
				+ "WHERE b.member_id = ? ORDER BY b.course_bookmark_at DESC LIMIT ?, ?";

        try {
            con = pool.getConnection();
            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, memberId);
            pstmt.setInt(2, start);
            pstmt.setInt(3, pageSize);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                AdminCourseBean bean = new AdminCourseBean();
                bean.setCourseId(rs.getInt("course_id"));
                bean.setCourseTitle(rs.getString("course_title"));
                bean.setDescription(rs.getString("description"));
                bean.setImagePath(rs.getString("image_path")); // 이미지 필드 이름 확인
                list.add(bean);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(con, pstmt, rs);
        }

        return list;
    }

    
    public int getBookmarkCourseCountByMember(String member_id) {
		Connection con = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		String sql = null;
		int cnt=0;
		try {
			con = pool.getConnection();
			sql = "select count(*) from rst_course_bookmark where member_id = ?";
			pstmt = con.prepareStatement(sql);
			pstmt.setString(1, member_id);
			rs = pstmt.executeQuery();
			if (rs.next()) {
				cnt = rs.getInt(1);
			}
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			pool.freeConnection(con, pstmt, rs);
		}
		return cnt;
	}
}
