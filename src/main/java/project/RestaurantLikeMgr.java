package project;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class RestaurantLikeMgr {
	private DBConnectionMgr pool;
	
	public RestaurantLikeMgr() {
		pool = DBConnectionMgr.getInstance();
	}
	
	public boolean likedCheck(RestaurantLikeBean bean) {
		Connection con = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		boolean result = false;
		String sql = null;
		try {
			con = pool.getConnection();
			sql = "select * from restaurant_like where member_id = ? and rst_id = ?";
			pstmt = con.prepareStatement(sql);
			pstmt.setString(1, bean.getMember_id());
			pstmt.setInt(2, bean.getRst_id());
			rs = pstmt.executeQuery();
			if (rs.next()) {
				result = true;
			}
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			pool.freeConnection(con, pstmt, rs);
		}
		return result;
	}
	
	// 좋아요 기록 검색
		public boolean searchLike(RestaurantLikeBean bean) {
			Connection con = null;
			PreparedStatement pstmt = null;
			ResultSet rs = null;
			String sql = null;
			boolean b = false;
			try {
				con = pool.getConnection();
				sql = "select * from restaurant_like where member_id = ? and rst_id = ?";
				pstmt = con.prepareStatement(sql);
				pstmt.setString(1, bean.getMember_id());
				pstmt.setInt(2, bean.getRst_id());
				rs = pstmt.executeQuery();
				if (rs.next()) {
					b=true;
				}
			} catch (Exception e) {
				e.printStackTrace();
			} finally {
				pool.freeConnection(con, pstmt, rs);
			}
			return b;
		}
		
		// 좋아요
		public void insertReviewLike(RestaurantLikeBean bean) {
			Connection con = null;
			PreparedStatement pstmt = null;
			String sql = null;
			try {
				con = pool.getConnection();
				sql = "insert into restaurant_like (member_id, rst_id) values (?,?)";
				pstmt = con.prepareStatement(sql);
				pstmt.setString(1, bean.getMember_id());
				pstmt.setInt(2, bean.getRst_id());
				pstmt.executeUpdate();

			} catch (Exception e) {
				e.printStackTrace();
			} finally {
				pool.freeConnection(con, pstmt);
			}
		}
		
		// 좋아요 취소
		public void deleteReviewLike(RestaurantLikeBean bean) {
		    Connection con = null;
		    PreparedStatement pstmt = null;
		    String sql = null;
		    try {
		        con = pool.getConnection();
		        sql = "DELETE FROM restaurant_like WHERE member_id = ? AND rst_id = ?";
		        pstmt = con.prepareStatement(sql);
		        pstmt.setString(1, bean.getMember_id());
		        pstmt.setInt(2, bean.getRst_id());
		        pstmt.executeUpdate();
		    } catch (Exception e) {
		        e.printStackTrace();
		    } finally {
		        pool.freeConnection(con, pstmt);
		    }
		}
		
		public boolean toggleLike(RestaurantLikeBean bean) {
		    if (searchLike(bean)) {
		        deleteReviewLike(bean);  // 이미 눌렀으면 삭제
		        return false; // 좋아요 취소됨
		    } else {
		        insertReviewLike(bean);  // 안 눌렀으면 추가
		        return true; // 좋아요 등록됨
		    }
		}

		// 리뷰 좋아요수 count
		public int likeCount(int rst_id) {
			Connection con = null;
			PreparedStatement pstmt = null;
			ResultSet rs = null;
			String sql = null;
			int cnt =0;
			try {
				con = pool.getConnection();
				sql = "select count(*) from restaurant_like where rst_id = ?";
				pstmt = con.prepareStatement(sql);
				pstmt.setInt(1, rst_id);
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
