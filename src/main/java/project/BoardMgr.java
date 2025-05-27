package project;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Vector;

public class BoardMgr {

    private DBConnectionMgr pool;

    public BoardMgr() {
        pool = DBConnectionMgr.getInstance();
    }

    //insert 
    public void insertBoard(BoardBean bean) {
        Connection con = null;
        PreparedStatement pstmt = null;
        String sql = null;
        try {
            con = pool.getConnection();
            sql = "insert into board (board_title, board_content, member_id, board_views) values (?,?,?,0)";
            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, bean.getBoard_title());
            pstmt.setString(2, bean.getBoard_content());
            pstmt.setString(3, bean.getMember_id());
            pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(con, pstmt);
        }
    }

    //delete
    public void deleteBoard(int board_id) {
        Connection con = null;
        PreparedStatement pstmt = null;
        String sql = null;
        try {
            con = pool.getConnection();
            // With ON DELETE CASCADE, we don't need to manually delete comments
            
            // Delete the board
            sql = "delete from board where board_id = ?";
            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, board_id);
            pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(con, pstmt);
        }
    }

    //update
    public boolean updateBoard(BoardBean bean) {
        Connection con = null;
        PreparedStatement pstmt = null;
        String sql = null;
        boolean flag = false;
        try {
            con = pool.getConnection();
            sql = "update board set board_title=?, board_content=? where board_id=?";
            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, bean.getBoard_title());
            pstmt.setString(2, bean.getBoard_content());
            pstmt.setInt(3, bean.getBoard_id());
            if (pstmt.executeUpdate() == 1) {
                flag = true;
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(con, pstmt);
        }
        return flag;
    }

    // 게시글 목록 가져오기
    public Vector<BoardBean> getBoardList(int start, int limit, String keyword) {
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        Vector<BoardBean> vlist = new Vector<>();
        
        try {
            con = pool.getConnection();
            String sql = "SELECT b.*, m.member_nickname, " +
                         "(SELECT COUNT(*) FROM comment c WHERE c.board_id = b.board_id) AS comment_count " +
                         "FROM board b JOIN member m ON b.member_id = m.member_id";
            
            // 검색어가 있는 경우 WHERE 절 추가
            if (keyword != null && !keyword.trim().equals("")) {
                sql += " WHERE b.board_title LIKE ? OR b.board_content LIKE ?";
            }
            
            sql += " ORDER BY b.board_id DESC LIMIT ?, ?";
            
            pstmt = con.prepareStatement(sql);
            
            int index = 1;
            if (keyword != null && !keyword.trim().equals("")) {
                pstmt.setString(index++, "%" + keyword + "%");
                pstmt.setString(index++, "%" + keyword + "%");
            }
            
            pstmt.setInt(index++, start);
            pstmt.setInt(index, limit);
            
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                BoardBean bean = new BoardBean();
                bean.setBoard_id(rs.getInt("board_id"));
                bean.setBoard_title(rs.getString("board_title"));
                bean.setBoard_content(rs.getString("board_content"));
                bean.setBoard_at(rs.getString("board_at"));
                bean.setMember_id(rs.getString("member_id"));
                bean.setBoard_views(rs.getInt("board_views"));
                
                // Handle nullable board_like field
                if (rs.getObject("board_like") != null) {
                    bean.setBoard_like(rs.getInt("board_like"));
                }
                
                bean.setMember_nickname(rs.getString("member_nickname"));
                bean.setComment_count(rs.getInt("comment_count"));
                vlist.addElement(bean);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(con, pstmt, rs);
        }
        return vlist;
    }
    
    // 게시글 총 개수 구하기
    public int getBoardCount(String keyword) {
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int count = 0;
        
        try {
            con = pool.getConnection();
            String sql = "SELECT COUNT(*) FROM board";
            
            // 검색어가 있는 경우 WHERE 절 추가
            if (keyword != null && !keyword.trim().equals("")) {
                sql += " WHERE board_title LIKE ? OR board_content LIKE ?";
            }
            
            pstmt = con.prepareStatement(sql);
            
            if (keyword != null && !keyword.trim().equals("")) {
                pstmt.setString(1, "%" + keyword + "%");
                pstmt.setString(2, "%" + keyword + "%");
            }
            
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
    
    // 게시글 상세 정보 가져오기
    public BoardBean getBoard(int boardId) {
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        BoardBean bean = null;
        
        try {
            con = pool.getConnection();
            String sql = "SELECT b.*, m.member_nickname FROM board b " +
                         "JOIN member m ON b.member_id = m.member_id " +
                         "WHERE b.board_id = ?";
            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, boardId);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                bean = new BoardBean();
                bean.setBoard_id(rs.getInt("board_id"));
                bean.setBoard_title(rs.getString("board_title"));
                bean.setBoard_content(rs.getString("board_content"));
                bean.setBoard_at(rs.getString("board_at"));
                bean.setMember_id(rs.getString("member_id"));
                bean.setBoard_views(rs.getInt("board_views"));
                
                // Handle nullable board_like field
                if (rs.getObject("board_like") != null) {
                    bean.setBoard_like(rs.getInt("board_like"));
                }
                
                bean.setMember_nickname(rs.getString("member_nickname"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(con, pstmt, rs);
        }
        return bean;
    }
    
 // 다음 게시글 가져오기 (현재 게시글보다 ID가 큰 게시글 중 가장 작은 ID)
    public BoardBean getNextBoard(int currentBoardId) {
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        BoardBean bean = null;
        
        try {
            con = pool.getConnection();
            String sql = "SELECT b.*, m.member_nickname FROM board b " +
                         "JOIN member m ON b.member_id = m.member_id " +
                         "WHERE b.board_id > ? " +
                         "ORDER BY b.board_id ASC LIMIT 1";
            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, currentBoardId);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                bean = new BoardBean();
                bean.setBoard_id(rs.getInt("board_id"));
                bean.setBoard_title(rs.getString("board_title"));
                bean.setBoard_content(rs.getString("board_content"));
                bean.setBoard_at(rs.getString("board_at"));
                bean.setMember_id(rs.getString("member_id"));
                bean.setBoard_views(rs.getInt("board_views"));
                
                // Handle nullable board_like field
                if (rs.getObject("board_like") != null) {
                    bean.setBoard_like(rs.getInt("board_like"));
                }
                
                bean.setMember_nickname(rs.getString("member_nickname"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(con, pstmt, rs);
        }
        return bean;
    }

    // 이전 게시글 가져오기 (현재 게시글보다 ID가 작은 게시글 중 가장 큰 ID)
    public BoardBean getPrevBoard(int currentBoardId) {
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        BoardBean bean = null;
        
        try {
            con = pool.getConnection();
            String sql = "SELECT b.*, m.member_nickname FROM board b " +
                         "JOIN member m ON b.member_id = m.member_id " +
                         "WHERE b.board_id < ? " +
                         "ORDER BY b.board_id DESC LIMIT 1";
            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, currentBoardId);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                bean = new BoardBean();
                bean.setBoard_id(rs.getInt("board_id"));
                bean.setBoard_title(rs.getString("board_title"));
                bean.setBoard_content(rs.getString("board_content"));
                bean.setBoard_at(rs.getString("board_at"));
                bean.setMember_id(rs.getString("member_id"));
                bean.setBoard_views(rs.getInt("board_views"));
                
                // Handle nullable board_like field
                if (rs.getObject("board_like") != null) {
                    bean.setBoard_like(rs.getInt("board_like"));
                }
                
                bean.setMember_nickname(rs.getString("member_nickname"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(con, pstmt, rs);
        }
        return bean;
    }
    
    // 조회수 증가
    public void increaseViewCount(int boardId) {
        Connection con = null;
        PreparedStatement pstmt = null;
        String sql = null;
        
        try {
            con = pool.getConnection();
            sql = "UPDATE board SET board_views = board_views + 1 WHERE board_id = ?";
            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, boardId);
            pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(con, pstmt);
        }
    }
    
    // 댓글 개수 가져오기
    public int getCommentCount(int boardId) {
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int count = 0;
        
        try {
            con = pool.getConnection();
            String sql = "SELECT COUNT(*) FROM comment WHERE board_id = ?";
            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, boardId);
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
    
    // 게시글 좋아요 업데이트
    public boolean updateBoardLike(int boardId, int likeCount) {
        Connection con = null;
        PreparedStatement pstmt = null;
        String sql = null;
        boolean flag = false;
        
        try {
            con = pool.getConnection();
            sql = "UPDATE board SET board_like = ? WHERE board_id = ?";
            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, likeCount);
            pstmt.setInt(2, boardId);
            if (pstmt.executeUpdate() == 1) {
                flag = true;
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(con, pstmt);
        }
        return flag;
    }
    
    public boolean admindeleteBoard(int boardId) {
        Connection con = null;
        PreparedStatement pstmt = null;
        boolean success = false;
        String sql = "DELETE FROM board WHERE board_id = ?";
        
        try {
            con = pool.getConnection();
            if (con == null) {
                System.out.println("deleteBoard 에러: 데이터베이스 연결 실패");
                return false;
            }
            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, boardId);
            int cnt = pstmt.executeUpdate();
            if (cnt > 0) {
                success = true;
                System.out.println("deleteBoard 성공: board_id=" + boardId);
            } else {
                System.out.println("deleteBoard 실패: 삭제된 행 없음 - board_id=" + boardId);
            }
        } catch (Exception e) {
            System.out.println("deleteBoard 에러: " + e.getMessage());
            e.printStackTrace();
        } finally {
            pool.freeConnection(con, pstmt);
        }
        return success;
    }
}
