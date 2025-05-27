package project;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class LikeMgr {
    private DBConnectionMgr pool;

    public LikeMgr() {
        pool = DBConnectionMgr.getInstance();
    }

    public boolean toggleLike(String memberId, String likeType, int targetId) {
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        boolean liked = false;

        try {
            con = pool.getConnection();

            String checkSql = "SELECT * FROM likes WHERE member_id = ? AND target_type = ? AND target_id = ?";
            pstmt = con.prepareStatement(checkSql);
            pstmt.setString(1, memberId);
            pstmt.setString(2, likeType);
            pstmt.setInt(3, targetId);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                pstmt.close();
                String deleteSql = "DELETE FROM likes WHERE member_id = ? AND target_type = ? AND target_id = ?";
                pstmt = con.prepareStatement(deleteSql);
                pstmt.setString(1, memberId);
                pstmt.setString(2, likeType);
                pstmt.setInt(3, targetId);
                pstmt.executeUpdate();
                liked = false;
            } else {
                pstmt.close();
                String insertSql = "INSERT INTO likes (member_id, target_type, target_id) VALUES (?, ?, ?)";
                pstmt = con.prepareStatement(insertSql);
                pstmt.setString(1, memberId);
                pstmt.setString(2, likeType);
                pstmt.setInt(3, targetId);
                pstmt.executeUpdate();
                liked = true;
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(con, pstmt, rs);
        }
        return liked;
    }

    public int getLikeCount(String likeType, int targetId) {
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int count = 0;

        try {
            con = pool.getConnection();
            String sql = "SELECT COUNT(*) FROM likes WHERE target_type = ? AND target_id = ?";
            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, likeType);
            pstmt.setInt(2, targetId);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                count = rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(con, pstmt, rs);
        }

        return count;
    }

    // ✅ 사용자 좋아요 여부 확인
    public boolean hasUserLiked(String likeType, int targetId, String memberId) {
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        boolean liked = false;

        try {
            con = pool.getConnection();
            String sql = "SELECT 1 FROM likes WHERE member_id = ? AND target_type = ? AND target_id = ?";
            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, memberId);
            pstmt.setString(2, likeType);
            pstmt.setInt(3, targetId);
            rs = pstmt.executeQuery();
            liked = rs.next();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(con, pstmt, rs);
        }

        return liked;
    }
}
