package project;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Vector;

public class MenuMgr {
	private DBConnectionMgr pool;
	
	public MenuMgr() {
		pool = DBConnectionMgr.getInstance();
	}
	
	public Vector<MenuBean> getMenuList(int rstId){
		Connection con = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		String sql = null;
		Vector<MenuBean> vlist = new Vector<MenuBean>();
		try {
			con = pool.getConnection();
			sql = "select * from menu where rst_id = ?";
			pstmt = con.prepareStatement(sql);
			pstmt.setInt(1, rstId);
			rs = pstmt.executeQuery();
			while (rs.next()) {
				MenuBean bean = new MenuBean();
				bean.setMenu_id(rs.getInt("menu_id"));
				bean.setMenu_name(rs.getString("menu_name"));
				bean.setMenu_contents(rs.getString("menu_contents"));
				bean.setMenu_price(rs.getString("menu_price"));
				bean.setMenu_image(rs.getString("menu_image"));
				bean.setMenu_rating(rs.getDouble("menu_rating"));
				bean.setRst_id(rs.getInt("rst_id"));
				vlist.add(bean);
			}
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			pool.freeConnection(con, pstmt, rs);
		}
		return vlist;
	}
	
    
    // 추가: 키워드 기반 메뉴 검색
    public Vector<MenuBean> searchMenus(String keyword) {
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        Vector<MenuBean> vlist = new Vector<MenuBean>();
        String sql = "select * from menu " +
                     "where (menu_name LIKE ? OR menu_contents LIKE ?)";
        try {
            con = pool.getConnection();
            pstmt = con.prepareStatement(sql);
            String likeKeyword = "%" + keyword + "%";
            pstmt.setString(1, likeKeyword);
            pstmt.setString(2, likeKeyword);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                MenuBean bean = new MenuBean();
                bean.setMenu_id(rs.getInt("menu_id"));
                bean.setMenu_name(rs.getString("menu_name"));
                bean.setMenu_contents(rs.getString("menu_contents"));
                bean.setMenu_price(rs.getString("menu_price"));
                bean.setMenu_image(rs.getString("menu_image"));
                bean.setMenu_rating(rs.getDouble("menu_rating"));
                bean.setRst_id(rs.getInt("rst_id"));
                vlist.add(bean);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(con, pstmt, rs);
        }
        return vlist;
    }
    
 // ===== MenuMgr.java =====

 // 3) 메뉴 검색 결과 전체 건수 조회
 public int countSearchMenus(String keyword) {
     int count = 0;
     String sql = "SELECT COUNT(*) FROM menu WHERE menu_name LIKE ? OR menu_contents LIKE ?";
     try (Connection con = pool.getConnection();
          PreparedStatement pstmt = con.prepareStatement(sql)) {
         String likeKeyword = "%" + keyword + "%";
         pstmt.setString(1, likeKeyword);
         pstmt.setString(2, likeKeyword);
         try (ResultSet rs = pstmt.executeQuery()) {
             if (rs.next()) {
                 count = rs.getInt(1);
             }
         }
     } catch (Exception e) {
         e.printStackTrace();
     }
     return count;
 }

 // 4) 메뉴 검색 결과 페이징 조회
 public Vector<MenuBean> searchMenus(String keyword, int offset, int pageSize) {
     Vector<MenuBean> vlist = new Vector<>();
     String sql = "SELECT * FROM menu "
                + "WHERE menu_name LIKE ? OR menu_contents LIKE ? "
                + "ORDER BY menu_name ASC LIMIT ?, ?";
     try (Connection con = pool.getConnection();
          PreparedStatement pstmt = con.prepareStatement(sql)) {
         String likeKeyword = "%" + keyword + "%";
         pstmt.setString(1, likeKeyword);
         pstmt.setString(2, likeKeyword);
         pstmt.setInt(3, offset);
         pstmt.setInt(4, pageSize);
         try (ResultSet rs = pstmt.executeQuery()) {
             while (rs.next()) {
                 MenuBean bean = new MenuBean();
                 bean.setMenu_id(rs.getInt("menu_id"));
                 bean.setMenu_name(rs.getString("menu_name"));
                 bean.setMenu_contents(rs.getString("menu_contents"));
                 bean.setMenu_price(rs.getString("menu_price"));
                 bean.setMenu_image(rs.getString("menu_image"));
                 bean.setMenu_rating(rs.getDouble("menu_rating"));
                 bean.setRst_id(rs.getInt("rst_id"));
                 vlist.add(bean);
             }
         }
     } catch (Exception e) {
         e.printStackTrace();
     }
     return vlist;
 }

	

}
