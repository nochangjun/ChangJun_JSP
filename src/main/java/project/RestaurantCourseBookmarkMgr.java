package project;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class RestaurantCourseBookmarkMgr {
	private DBConnectionMgr pool;
	
	public RestaurantCourseBookmarkMgr() {
		pool = DBConnectionMgr.getInstance();
	}
	
	// 사용자 아이디로 코스 찜 했는지 체크
	public boolean checkCourseBookmark(String memberid, int course_id) {
		Connection con = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		String sql = null;
		boolean check = false;
		try {
			con = pool.getConnection();
			sql = "select * from rst_course_bookmark where member_id = ? and course_id = ?";
			pstmt = con.prepareStatement(sql);
			pstmt.setString(1, memberid);
			pstmt.setInt(2, course_id);
			rs = pstmt.executeQuery();
			if (rs.next()) {
				check = true;
			}
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			pool.freeConnection(con, pstmt, rs);
		}
		return check;
	}
	
	public int countCourseBookmark(int course_id) {
		Connection con = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		String sql = null;
		int cnt=0;
		try {
			con = pool.getConnection();
			sql = "select count(*) from rst_course_bookmark where course_id = ?";
			pstmt = con.prepareStatement(sql);
			pstmt.setInt(1, course_id);
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
	
	public boolean removeCourseBookmark(String memberId, int courseId) {
		Connection con = null;
		PreparedStatement pstmt = null;
		String sql = null;
		boolean result = false;
		try {
			con = pool.getConnection();
			sql = "DELETE FROM rst_course_bookmark WHERE member_id = ? AND course_id = ?";
			pstmt = con.prepareStatement(sql);
			pstmt.setString(1, memberId);
			pstmt.setInt(2, courseId);
			if (pstmt.executeUpdate() >0) {
				result = true;
			}
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			pool.freeConnection(con, pstmt);
		}
		return result;
	}
	
	public boolean addCourseBookmark(String memberId, int courseId) {
	    Connection con = null;
	    PreparedStatement pstmt = null;
	    String sql = null;
	    boolean result = false;
	    try {
	        con = pool.getConnection();
	        sql = "INSERT INTO rst_course_bookmark (member_id, course_id) VALUES (?, ?)";
	        pstmt = con.prepareStatement(sql);
	        pstmt.setString(1, memberId);
	        pstmt.setInt(2, courseId);
	        if ( pstmt.executeUpdate() >0) {
				result = true;
			}
	    } catch (Exception e) {
	        e.printStackTrace();
	    } finally {
	        pool.freeConnection(con, pstmt);
	    }
	    return result;
	}

}
