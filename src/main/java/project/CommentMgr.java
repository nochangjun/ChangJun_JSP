package project;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Vector;

public class CommentMgr {

    private DBConnectionMgr pool;

    public CommentMgr() {
        pool = DBConnectionMgr.getInstance();
    }

    // 댓글 추가
    public boolean insertComment(CommentBean bean) {
        // 신고 제한 상태라면 댓글 작성 불가 처리
        MemberMgr memberMgr = new MemberMgr();
        if (!memberMgr.canPerformActions(bean.getMember_id())) {
            System.out.println("신고 제한 상태입니다. 댓글을 작성할 수 없습니다.");
            return false;
        }
        
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String sql = null;
        boolean flag = false;
        
        try {
            con = pool.getConnection();
            con.setAutoCommit(false); // 트랜잭션 처리 시작
            
            // 댓글 삽입: 일반 댓글과 대댓글 분리 처리
            if (bean.getParent_comment_id() == null) {
                // 일반 댓글
                sql = "INSERT INTO comment (board_id, member_id, comment_content) VALUES (?,?,?)";
                pstmt = con.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS);
                pstmt.setInt(1, bean.getBoard_id());
                pstmt.setString(2, bean.getMember_id());
                pstmt.setString(3, bean.getComment_content());
            } else {
                // 대댓글
                sql = "INSERT INTO comment (board_id, member_id, comment_content, parent_comment_id) VALUES (?,?,?,?)";
                pstmt = con.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS);
                pstmt.setInt(1, bean.getBoard_id());
                pstmt.setString(2, bean.getMember_id());
                pstmt.setString(3, bean.getComment_content());
                pstmt.setInt(4, bean.getParent_comment_id());
            }
            
            int rows = pstmt.executeUpdate();
            if (rows != 1) throw new Exception("댓글 저장 실패");
            
            // 생성된 comment_id 가져오기
            int commentId = 0;
            rs = pstmt.getGeneratedKeys();
            if (rs.next()) {
                commentId = rs.getInt(1);
            }
            
            // 일반 댓글일 경우, 게시글 작성자에게 알림 추가
            if (bean.getParent_comment_id() == null) {
                sql = "SELECT member_id FROM board WHERE board_id = ?";
                pstmt = con.prepareStatement(sql);
                pstmt.setInt(1, bean.getBoard_id());
                rs = pstmt.executeQuery();
                if (rs.next()) {
                    String boardWriter = rs.getString("member_id");
                    if (!boardWriter.equals(bean.getMember_id())) {
                        sql = "INSERT INTO notice (comment_id, member_id) VALUES (?, ?)";
                        pstmt = con.prepareStatement(sql);
                        pstmt.setInt(1, commentId);
                        pstmt.setString(2, boardWriter);
                        pstmt.executeUpdate();
                    }
                }
            } else {
                // 대댓글일 경우, 부모 댓글 작성자에게 알림 추가
                sql = "SELECT member_id FROM comment WHERE comment_id = ?";
                pstmt = con.prepareStatement(sql);
                pstmt.setInt(1, bean.getParent_comment_id());
                rs = pstmt.executeQuery();
                if (rs.next()) {
                    String parentCommentWriter = rs.getString("member_id");
                    if (!parentCommentWriter.equals(bean.getMember_id())) {
                        sql = "INSERT INTO notice (comment_id, member_id) VALUES (?, ?)";
                        pstmt = con.prepareStatement(sql);
                        pstmt.setInt(1, commentId);
                        pstmt.setString(2, parentCommentWriter);
                        pstmt.executeUpdate();
                    }
                }
            }
            
            con.commit(); // 트랜잭션 커밋
            flag = true;
            
        } catch (Exception e) {
            try { if (con != null) con.rollback(); } catch (Exception ignore) {}
            e.printStackTrace();
        } finally {
            try { if (con != null) con.setAutoCommit(true); } catch (Exception ignore) {}
            pool.freeConnection(con, pstmt, rs);
        }
        
        return flag;
    }


    // 댓글 수정
    public boolean updateComment(CommentBean bean) {
        Connection con = null;
        PreparedStatement pstmt = null;
        String sql = null;
        boolean flag = false;
        
        try {
            con = pool.getConnection();
            sql = "update comment set comment_content=? where comment_id=? and member_id=?";
            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, bean.getComment_content());
            pstmt.setInt(2, bean.getComment_id());
            pstmt.setString(3, bean.getMember_id());
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

    // 댓글 삭제
    public boolean deleteComment(int comment_id, String member_id) {
        Connection con = null;
        PreparedStatement pstmt = null;
        String sql = null;
        boolean flag = false;
        
        try {
            con = pool.getConnection();
            sql = "delete from comment where comment_id=? and member_id=?";
            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, comment_id);
            pstmt.setString(2, member_id);
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

    	
    // 좋아요 증가
    public boolean incrementLike(int comment_id) {
        Connection con = null;
        PreparedStatement pstmt = null;
        String sql = null;
        boolean flag = false;
        
        
        try {
            con = pool.getConnection();
            sql = "update comment set comment_like = comment_like + 1 where comment_id=?";
            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, comment_id);
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
    
    // 좋아요 감소 (취소)
    public boolean decrementLike(int comment_id) {
        Connection con = null;
        PreparedStatement pstmt = null;
        String sql = null;
        boolean flag = false;
        
        try {
            con = pool.getConnection();
            sql = "update comment set comment_like = GREATEST(0, comment_like - 1) where comment_id=?";
            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, comment_id);
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

    // 특정 게시글의 댓글 목록 가져오기 (계층형으로) - 순서 수정: 대댓글 오래된 순으로
    public Vector<CommentBean> getCommentList(int board_id) {
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        Vector<CommentBean> vlist = new Vector<>();

        try {
            con = pool.getConnection();
            // 부모 댓글 순으로 정렬하고, 대댓글은 오래된 순(ASC)으로 표시
            String sql = "SELECT c.*, m.member_nickname FROM comment c " +
                         "JOIN member m ON c.member_id = m.member_id " +
                         "WHERE c.board_id = ? " +
                         "ORDER BY COALESCE(c.parent_comment_id, c.comment_id), " +
                         "CASE WHEN c.parent_comment_id IS NULL THEN 0 ELSE 1 END, " +
                         "c.comment_id ASC";  // 수정: DESC에서 ASC로 변경
            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, board_id);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                CommentBean bean = new CommentBean();
                bean.setComment_id(rs.getInt("comment_id"));
                bean.setBoard_id(rs.getInt("board_id"));
                bean.setMember_id(rs.getString("member_id"));
                bean.setComment_content(rs.getString("comment_content"));
                bean.setComment_at(rs.getString("comment_at"));
                bean.setComment_like(rs.getInt("comment_like"));
                
                // parent_comment_id가 NULL이면 null로 설정
                int parentId = rs.getInt("parent_comment_id");
                if (rs.wasNull()) {
                    bean.setParent_comment_id(null);
                } else {
                    bean.setParent_comment_id(parentId);
                }
                
                bean.setMember_nickname(rs.getString("member_nickname"));
                vlist.addElement(bean);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(con, pstmt, rs);
        }
        return vlist;
    }
    
    // 특정 댓글의 대댓글 목록 가져오기 - 순서 수정: 오래된 순으로
    public Vector<CommentBean> getReplies(int parent_comment_id) {
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        Vector<CommentBean> vlist = new Vector<>();

        try {
            con = pool.getConnection();
            String sql = "SELECT c.*, m.member_nickname FROM comment c " +
                         "JOIN member m ON c.member_id = m.member_id " +
                         "WHERE c.parent_comment_id = ? " +
                         "ORDER BY c.comment_id ASC";  // 수정: DESC에서 ASC로 변경
            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, parent_comment_id);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                CommentBean bean = new CommentBean();
                bean.setComment_id(rs.getInt("comment_id"));
                bean.setBoard_id(rs.getInt("board_id"));
                bean.setMember_id(rs.getString("member_id"));
                bean.setComment_content(rs.getString("comment_content"));
                bean.setComment_at(rs.getString("comment_at"));
                bean.setComment_like(rs.getInt("comment_like"));
                bean.setParent_comment_id(rs.getInt("parent_comment_id"));
                bean.setMember_nickname(rs.getString("member_nickname"));
                vlist.addElement(bean);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(con, pstmt, rs);
        }
        return vlist;
    }
    
    // 특정 댓글 정보 가져오기
    public CommentBean getComment(int comment_id) {
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        CommentBean bean = null;

        try {
            con = pool.getConnection();
            String sql = "SELECT c.*, m.member_nickname FROM comment c " +
                         "JOIN member m ON c.member_id = m.member_id " +
                         "WHERE c.comment_id = ?";
            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, comment_id);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                bean = new CommentBean();
                bean.setComment_id(rs.getInt("comment_id"));
                bean.setBoard_id(rs.getInt("board_id"));
                bean.setMember_id(rs.getString("member_id"));
                bean.setComment_content(rs.getString("comment_content"));
                bean.setComment_at(rs.getString("comment_at"));
                bean.setComment_like(rs.getInt("comment_like"));
                
                // parent_comment_id가 NULL이면 null로 설정
                int parentId = rs.getInt("parent_comment_id");
                if (rs.wasNull()) {
                    bean.setParent_comment_id(null);
                } else {
                    bean.setParent_comment_id(parentId);
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
    
    // 특정 게시글의 댓글 수 가져오기
    public int getCommentCount(int board_id) {
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int count = 0;

        try {
            con = pool.getConnection();
            String sql = "SELECT COUNT(*) FROM comment WHERE board_id = ?";
            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, board_id);
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
    
    // 특정 사용자의 댓글 목록 가져오기
    public Vector<CommentBean> getUserCommentList(String member_id) {
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        Vector<CommentBean> vlist = new Vector<>();

        try {
            con = pool.getConnection();
            String sql = "SELECT c.*, m.member_nickname FROM comment c " +
                         "JOIN member m ON c.member_id = m.member_id " +
                         "WHERE c.member_id = ? " +
                         "ORDER BY c.comment_id DESC";
            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, member_id);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                CommentBean bean = new CommentBean();
                bean.setComment_id(rs.getInt("comment_id"));
                bean.setBoard_id(rs.getInt("board_id"));
                bean.setMember_id(rs.getString("member_id"));
                bean.setComment_content(rs.getString("comment_content"));
                bean.setComment_at(rs.getString("comment_at"));
                bean.setComment_like(rs.getInt("comment_like"));
                
                // parent_comment_id가 NULL이면 null로 설정
                int parentId = rs.getInt("parent_comment_id");
                if (rs.wasNull()) {
                    bean.setParent_comment_id(null);
                } else {
                    bean.setParent_comment_id(parentId);
                }
                
                bean.setMember_nickname(rs.getString("member_nickname"));
                vlist.addElement(bean);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            pool.freeConnection(con, pstmt, rs);
        }
        return vlist;
    }
    
    public boolean deleteComment(int commentId) {
        Connection con = null;
        PreparedStatement pstmt = null;
        boolean success = false;
        String sql = "DELETE FROM comment WHERE comment_id = ?";
        
        try {
            con = pool.getConnection();
            if (con == null) {
                System.out.println("deleteComment 에러: 데이터베이스 연결 실패");
                return false;
            }
            pstmt = con.prepareStatement(sql);
            pstmt.setInt(1, commentId);
            int cnt = pstmt.executeUpdate();
            if (cnt > 0) {
                success = true;
                System.out.println("deleteComment 성공: comment_id=" + commentId);
            } else {
                System.out.println("deleteComment 실패: 삭제된 행 없음 - comment_id=" + commentId);
            }
        } catch (Exception e) {
            System.out.println("deleteComment 에러: " + e.getMessage());
            e.printStackTrace();
        } finally {
            pool.freeConnection(con, pstmt);
        }
        return success;
    }
}