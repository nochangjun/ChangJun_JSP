package project;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Vector;

public class BookmarkMgr {
	private DBConnectionMgr pool;
	
	public BookmarkMgr() {
		pool = DBConnectionMgr.getInstance();
	}
	
	// 사용자 아이디로 식당 찜 했는지 체크
	public boolean checkBookmark(String memberid, int rst_id) {
		Connection con = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		String sql = null;
		boolean check = false;
		try {
			con = pool.getConnection();
			sql = "select * from bookmark where member_id = ? and rst_id = ?";
			pstmt = con.prepareStatement(sql);
			pstmt.setString(1, memberid);
			pstmt.setInt(2, rst_id);
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
	
	public int countBookmark(int rst_id) {
		Connection con = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		String sql = null;
		int cnt=0;
		try {
			con = pool.getConnection();
			sql = "select count(*) from bookmark where rst_id = ?";
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
	
	public boolean removeBookmark(String memberId, int rstId) {
		Connection con = null;
		PreparedStatement pstmt = null;
		String sql = null;
		boolean result = false;
		try {
			con = pool.getConnection();
			sql = "DELETE FROM bookmark WHERE member_id = ? AND rst_id = ?";
			pstmt = con.prepareStatement(sql);
			pstmt.setString(1, memberId);
			pstmt.setInt(2, rstId);
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
	
	public boolean addBookmark(String memberId, int rstId) {
	    Connection con = null;
	    PreparedStatement pstmt = null;
	    String sql = null;
	    boolean result = false;
	    try {
	        con = pool.getConnection();
	        sql = "INSERT INTO bookmark (member_id, rst_id) VALUES (?, ?)";
	        pstmt = con.prepareStatement(sql);
	        pstmt.setString(1, memberId);
	        pstmt.setInt(2, rstId);
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
	
	// 찜한 맛집 개수 조회
	public int countBookmarkByMember(String memberId) {
		Connection con = null;
	    PreparedStatement pstmt = null;
	    String sql = null;
	    int count = 0;
	    try {
	    	con = pool.getConnection();
	    	sql = "SELECT COUNT(*) FROM bookmark WHERE member_id = ?";
	    	pstmt = con.prepareStatement(sql); 
	        pstmt.setString(1, memberId);
	        ResultSet rs = pstmt.executeQuery();
	        if (rs.next()) {
	            count = rs.getInt(1);
	        }
	    } catch (Exception e) {
	        e.printStackTrace();
	    }
	    return count;
	}

	// 찜한 맛집 리스트 조회 (페이징)
	public Vector<RestaurantBean> getBookmarksByMember(String memberId, int start, int count) {
		Connection con = null;
	    PreparedStatement pstmt = null;
	    String sql = null;
	    Vector<RestaurantBean> list = new Vector<>();
	    
	    try {
	    	con = pool.getConnection();
	    	sql = "SELECT r.* FROM restaurant r JOIN bookmark b ON r.rst_id = b.rst_id WHERE b.member_id = ? ORDER BY b.bookmark_at DESC LIMIT ?, ?";
	    	pstmt = con.prepareStatement(sql); 
	        pstmt.setString(1, memberId);
	        pstmt.setInt(2, start);
	        pstmt.setInt(3, count);
	        ResultSet rs = pstmt.executeQuery();
	        while (rs.next()) {
	        	RestaurantBean bean = new RestaurantBean();
				bean.setRst_id(rs.getInt("rst_id"));
				bean.setRst_status(rs.getString("rst_status"));
				bean.setRst_name(rs.getString("rst_name"));
				bean.setRst_introduction(rs.getString("rst_introduction"));
				bean.setRst_address(rs.getString("rst_address"));
				bean.setRst_phonenumber(rs.getString("rst_phonenumber"));
				bean.setRst_rating(rs.getDouble("rst_rating"));
				bean.setRst_lat(rs.getDouble("rst_lat"));
				bean.setRst_long(rs.getDouble("rst_long"));
				bean.setRst_tag(rs.getString("rst_tag"));
				bean.setRegionLabel(rs.getString("regionLabel"));
				bean.setRegion2Label(rs.getString("region2Label"));
				bean.setImgpath(rs.getString("imgpath"));
				bean.setRst_like(rs.getObject("rst_like") != null ? rs.getInt("rst_like") : null);
				bean.setCreated_at(rs.getString("created_at"));
				bean.setMember_id(rs.getString("member_id"));
	            list.add(bean);
	        }
	    } catch (Exception e) {
	        e.printStackTrace();
	    }
	    return list;
	}
	
	public int getBookmarkCountByMember(String member_id) {
		Connection con = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		String sql = null;
		int cnt=0;
		try {
			con = pool.getConnection();
			sql = "select count(*) from bookmark where member_id = ?";
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
